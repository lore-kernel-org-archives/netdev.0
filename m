From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: Re: [PATCH net-next-2.6 v5 5/5] sctp: Add ASCONF operation on the
 single-homed host
Date: Tue, 26 Apr 2011 11:28:13 +0800
Message-ID: <4DB63BCD.70201@cn.fujitsu.com>
References: <0D29144A-E384-4E7D-AA04-4CC330A2D3AF@sfc.wide.ad.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
To: Michio Honda <micchie@sfc.wide.ad.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:64194 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1757935Ab1DZD21 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Apr 2011 23:28:27 -0400
In-Reply-To: <0D29144A-E384-4E7D-AA04-4CC330A2D3AF@sfc.wide.ad.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> SCTP can change the IP address on the single-homed host.  
> In this case, the SCTP association transmits an ASCONF packet including addition of the new IP address and deletion of the old address.  This patch implements this functionality.  
> In this case, the ASCONF chunk is added to the beginning of the queue, because the other chunks cannot be transmitted in this state.  
>
> Signed-off-by: Michio Honda <micchie@sfc.wide.ad.jp>
> ---
> diff --git a/include/net/sctp/constants.h b/include/net/sctp/constants.h
> index c70d8cc..d7a4ee3 100644
> --- a/include/net/sctp/constants.h
> +++ b/include/net/sctp/constants.h
> @@ -441,4 +441,8 @@ enum {
>   */
>  #define SCTP_AUTH_RANDOM_LENGTH 32
>  
> +/* ASCONF PARAMETERS */
> +#define SCTP_ASCONF_V4_PARAM_LEN 16
> +#define SCTP_ASCONF_V6_PARAM_LEN 28

useless defines.

> +
>  #endif /* __sctp_constants_h__ */
> diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
> index cc9185c..db4e9d0 100644
> --- a/include/net/sctp/structs.h
> +++ b/include/net/sctp/structs.h
> @@ -1901,6 +1901,8 @@ struct sctp_association {
>  	 * after reaching 4294967295.
>  	 */
>  	__u32 addip_serial;
> +	union sctp_addr *asconf_addr_del_pending;
> +	int src_out_of_asoc_ok;
>  
>  	/* SCTP AUTH: list of the endpoint shared keys.  These
>  	 * keys are provided out of band by the user applicaton
> diff --git a/net/sctp/associola.c b/net/sctp/associola.c
> index 6b04287..2082d0a 100644
> --- a/net/sctp/associola.c
> +++ b/net/sctp/associola.c
> @@ -279,6 +279,8 @@ static struct sctp_association *sctp_association_init(struct sctp_association *a
>  	asoc->peer.asconf_capable = 0;
>  	if (sctp_addip_noauth)
>  		asoc->peer.asconf_capable = 1;
> +	asoc->asconf_addr_del_pending = NULL;
> +	asoc->src_out_of_asoc_ok = 0;
>  
>  	/* Create an input queue.  */
>  	sctp_inq_init(&asoc->base.inqueue);
> @@ -443,6 +445,10 @@ void sctp_association_free(struct sctp_association *asoc)
>  
>  	asoc->peer.transport_count = 0;
>  
> +	/* Free pending address space being deleted */
> +	if (asoc->asconf_addr_del_pending != NULL)
> +		kfree(asoc->asconf_addr_del_pending);
> +
>  	/* Free any cached ASCONF_ACK chunk. */
>  	sctp_assoc_free_asconf_acks(asoc);
>  
> diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
> index 865ce7b..56c97ce 100644
> --- a/net/sctp/ipv6.c
> +++ b/net/sctp/ipv6.c
> @@ -332,6 +332,13 @@ static void sctp_v6_get_saddr(struct sctp_sock *sk,
>  				matchlen = bmatchlen;
>  			}
>  		}
> +		if (laddr->state == SCTP_ADDR_NEW && asoc->src_out_of_asoc_ok) {
> +			bmatchlen = sctp_v6_addr_match_len(daddr, &laddr->a);
> +			if (!baddr || (matchlen < bmatchlen)) {
> +				baddr = &laddr->a;
> +				matchlen = bmatchlen;
> +			}
> +		}
>  	}
>  
>  	if (baddr) {
> diff --git a/net/sctp/outqueue.c b/net/sctp/outqueue.c
> index 26dc005..28bccde 100644
> --- a/net/sctp/outqueue.c
> +++ b/net/sctp/outqueue.c
> @@ -744,6 +744,16 @@ static int sctp_outq_flush(struct sctp_outq *q, int rtx_timeout)
>  	 */
>  
>  	list_for_each_entry_safe(chunk, tmp, &q->control_chunk_list, list) {
> +		/* RFC 5061, 5.3
> +		 * F1) This means that until such time as the ASCONF
> +		 * containing the add is acknowledged, the sender MUST
> +		 * NOT use the new IP address as a source for ANY SCTP
> +		 * packet except on carrying an ASCONF Chunk.
> +		 */
> +		if (asoc->src_out_of_asoc_ok &&
> +		    chunk->chunk_hdr->type != SCTP_CID_ASCONF)
> +			continue;
> +
>  		list_del_init(&chunk->list);
>  
>  		/* Pick the right transport to use. */
> @@ -871,6 +881,9 @@ static int sctp_outq_flush(struct sctp_outq *q, int rtx_timeout)
>  		}
>  	}
>  
> +	if (q->asoc->src_out_of_asoc_ok)
> +		goto sctp_flush_out;
> +
>  	/* Is it OK to send data chunks?  */
>  	switch (asoc->state) {
>  	case SCTP_STATE_COOKIE_ECHOED:
> diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
> index 152976e..0733273 100644
> --- a/net/sctp/protocol.c
> +++ b/net/sctp/protocol.c
> @@ -510,7 +510,9 @@ static struct dst_entry *sctp_v4_get_dst(struct sctp_association *asoc,
>  		sctp_v4_dst_saddr(&dst_saddr, dst, htons(bp->port));
>  		rcu_read_lock();
>  		list_for_each_entry_rcu(laddr, &bp->address_list, list) {
> -			if (!laddr->valid || (laddr->state != SCTP_ADDR_SRC))
> +			if (!laddr->valid || (laddr->state == SCTP_ADDR_DEL) ||
> +			    (laddr->state != SCTP_ADDR_SRC &&
> +			    !asoc->src_out_of_asoc_ok))
>  				continue;
>  			if (sctp_v4_cmp_addr(&dst_saddr, &laddr->a))
>  				goto out_unlock;
> diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
> index de98665..f341ab2 100644
> --- a/net/sctp/sm_make_chunk.c
> +++ b/net/sctp/sm_make_chunk.c
> @@ -2744,6 +2744,12 @@ struct sctp_chunk *sctp_make_asconf_update_ip(struct sctp_association *asoc,
>  	int			addr_param_len = 0;
>  	int 			totallen = 0;
>  	int 			i;
> +	sctp_addip_param_t del_param; /* 8 Bytes (Type 0xC002, Len and CrrID) */
> +	struct sctp_af *del_af;
> +	int del_addr_param_len = 0;
> +	int del_paramlen = sizeof(sctp_addip_param_t);
> +	union sctp_addr_param del_addr_param; /* (v4) 8 Bytes, (v6) 20 Bytes */
> +	int			del_pickup = 0;
>  
>  	/* Get total length of all the address parameters. */
>  	addr_buf = addrs;
> @@ -2756,6 +2762,17 @@ struct sctp_chunk *sctp_make_asconf_update_ip(struct sctp_association *asoc,
>  		totallen += addr_param_len;
>  
>  		addr_buf += af->sockaddr_len;
> +		if (asoc->asconf_addr_del_pending && !del_pickup) {
> +			if (!sctp_in_scope(asoc->asconf_addr_del_pending,
> +			    sctp_scope(addr)))
> +				continue;
> +			/* reuse the parameter length from the same scope one */
> +			totallen += paramlen;
> +			totallen += addr_param_len;
> +			del_pickup = 1;
> +			asoc->src_out_of_asoc_ok = 1;
> +			SCTP_DEBUG_PRINTK("mkasconf_update_ip: picked same-scope del_pending addr, totallen for all addresses is %d\n", totallen);
> +		}
>  	}
>  
>  	/* Create an asconf chunk with the required length. */
> @@ -2778,6 +2795,19 @@ struct sctp_chunk *sctp_make_asconf_update_ip(struct sctp_association *asoc,
>  
>  		addr_buf += af->sockaddr_len;
>  	}
> +	if (flags == SCTP_PARAM_ADD_IP && del_pickup) {
> +		addr = asoc->asconf_addr_del_pending;
> +		del_af = sctp_get_af_specific(addr->v4.sin_family);
> +		del_addr_param_len = del_af->to_addr_param(addr,
> +		    &del_addr_param);
> +		del_param.param_hdr.type = SCTP_PARAM_DEL_IP;
> +		del_param.param_hdr.length = htons(del_paramlen +
> +		    del_addr_param_len);
> +		del_param.crr_id = i;
> +
> +		sctp_addto_chunk(retval, del_paramlen, &del_param);
> +		sctp_addto_chunk(retval, del_addr_param_len, &del_addr_param);
> +	}
>  	return retval;
>  }
>  
> @@ -3193,7 +3223,8 @@ static void sctp_asconf_param_success(struct sctp_association *asoc,
>  		local_bh_enable();
>  		list_for_each_entry(transport, &asoc->peer.transport_addr_list,
>  				transports) {
> -			if (transport->state == SCTP_ACTIVE)
> +			if (transport->state == SCTP_ACTIVE &&
> +			    !asoc->src_out_of_asoc_ok)
>  				continue;
>  			dst_release(transport->dst);
>  			sctp_transport_route(transport, NULL,
> @@ -3203,6 +3234,11 @@ static void sctp_asconf_param_success(struct sctp_association *asoc,
>  	case SCTP_PARAM_DEL_IP:
>  		local_bh_disable();
>  		sctp_del_bind_addr(bp, &addr);
> +		if (asoc->asconf_addr_del_pending != NULL &&
> +		    sctp_cmp_addr_exact(asoc->asconf_addr_del_pending, &addr)) {
> +			kfree(asoc->asconf_addr_del_pending);
> +			asoc->asconf_addr_del_pending = NULL;
> +		}
>  		local_bh_enable();
>  		list_for_each_entry(transport, &asoc->peer.transport_addr_list,
>  				transports) {
> @@ -3361,6 +3397,9 @@ int sctp_process_asconf_ack(struct sctp_association *asoc,
>  		asconf_len -= length;
>  	}
>  
> +	if (no_err && asoc->src_out_of_asoc_ok)
> +		asoc->src_out_of_asoc_ok = 0;
> +
>  	/* Free the cached last sent asconf chunk. */
>  	list_del_init(&asconf->transmitted_list);
>  	sctp_chunk_free(asconf);
> diff --git a/net/sctp/socket.c b/net/sctp/socket.c
> index 3951a10..481293d 100644
> --- a/net/sctp/socket.c
> +++ b/net/sctp/socket.c
> @@ -583,10 +583,6 @@ static int sctp_send_asconf_add_ip(struct sock		*sk,
>  			goto out;
>  		}
>  
> -		retval = sctp_send_asconf(asoc, chunk);
> -		if (retval)
> -			goto out;
> -
>  		/* Add the new addresses to the bind address list with
>  		 * use_as_src set to 0.
>  		 */
> @@ -599,6 +595,23 @@ static int sctp_send_asconf_add_ip(struct sock		*sk,
>  						    SCTP_ADDR_NEW, GFP_ATOMIC);
>  			addr_buf += af->sockaddr_len;
>  		}
> +		if (asoc->src_out_of_asoc_ok) {
> +			struct sctp_transport *trans;
> +
> +			list_for_each_entry(trans,
> +			    &asoc->peer.transport_addr_list, transports) {
> +				/* Clear the source and route cache */
> +				dst_release(trans->dst);
> +				trans->cwnd = min(4*asoc->pathmtu, max_t(__u32,
> +				    2*asoc->pathmtu, 4380));
> +				trans->ssthresh = asoc->peer.i.a_rwnd;
> +				trans->rto = asoc->rto_initial;
> +				trans->rtt = trans->srtt = trans->rttvar = 0;
> +				sctp_transport_route(trans, NULL,
> +				    sctp_sk(asoc->base.sk));
> +			}
> +		}
> +		retval = sctp_send_asconf(asoc, chunk);
>  	}
>  
>  out:
> @@ -711,7 +724,9 @@ static int sctp_send_asconf_del_ip(struct sock		*sk,
>  	struct sctp_sockaddr_entry *saddr;
>  	int 			i;
>  	int 			retval = 0;
> +	int			stored = 0;
>  
> +	chunk = NULL;
>  	if (!sctp_addip_enable)
>  		return retval;
>  
> @@ -762,8 +777,32 @@ static int sctp_send_asconf_del_ip(struct sock		*sk,
>  		bp = &asoc->base.bind_addr;
>  		laddr = sctp_find_unmatch_addr(bp, (union sctp_addr *)addrs,
>  					       addrcnt, sp);
> -		if (!laddr)
> -			continue;
> +		if ((laddr == NULL) && (addrcnt == 1)) {
> +			if (asoc->asconf_addr_del_pending)
> +				continue;
> +			asoc->asconf_addr_del_pending =
> +			    kzalloc(sizeof(union sctp_addr), GFP_ATOMIC);
> +			asoc->asconf_addr_del_pending->sa.sa_family =
> +				    addrs->sa_family;
> +			asoc->asconf_addr_del_pending->v4.sin_port =
> +				    htons(bp->port);
> +			if (addrs->sa_family == AF_INET) {
> +				struct sockaddr_in *sin;
> +
> +				sin = (struct sockaddr_in *)addrs;
> +				asoc->asconf_addr_del_pending->v4.sin_addr.s_addr = sin->sin_addr.s_addr;
> +			} else if (addrs->sa_family == AF_INET6) {
> +				struct sockaddr_in6 *sin6;
> +
> +				sin6 = (struct sockaddr_in6 *)addrs;
> +				ipv6_addr_copy(&asoc->asconf_addr_del_pending->v6.sin6_addr, &sin6->sin6_addr);
> +			}
> +			SCTP_DEBUG_PRINTK_IPADDR("send_asconf_del_ip: keep the last address asoc: %p ",
> +			    " at %p\n", asoc, asoc->asconf_addr_del_pending,
> +			    asoc->asconf_addr_del_pending);
> +			stored = 1;
> +			goto skip_mkasconf;
> +		}
>  
>  		/* We do not need RCU protection throughout this loop
>  		 * because this is done under a socket lock from the
> @@ -776,6 +815,7 @@ static int sctp_send_asconf_del_ip(struct sock		*sk,
>  			goto out;
>  		}
>  
> +skip_mkasconf:
>  		/* Reset use_as_src flag for the addresses in the bind address
>  		 * list that are to be deleted.
>  		 */
> @@ -801,6 +841,9 @@ static int sctp_send_asconf_del_ip(struct sock		*sk,
>  					     sctp_sk(asoc->base.sk));
>  		}
>  
> +		if (stored)
> +			/* We don't need to transmit ASCONF */
> +			continue;
>  		retval = sctp_send_asconf(asoc, chunk);
>  	}
>  out:
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
