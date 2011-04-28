From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: Re: [PATCH 6/6 v8] sctp: Add ASCONF operation on the single-homed
 host
Date: Thu, 28 Apr 2011 12:52:23 +0800
Message-ID: <4DB8F287.2070000@cn.fujitsu.com>
References: <4947D5B3-9FCA-42AA-81D0-9D55594108F1@sfc.wide.ad.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: Michio Honda <micchie@sfc.wide.ad.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:51471 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752819Ab1D1Ewo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Apr 2011 00:52:44 -0400
In-Reply-To: <4947D5B3-9FCA-42AA-81D0-9D55594108F1@sfc.wide.ad.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> From 983b3d3f2ffe0173f0e63af029610ce301ff397c Mon Sep 17 00:00:00 2001
> From: Michio Honda <micchie@sfc.wide.ad.jp>
> Date: Tue, 26 Apr 2011 20:19:36 +0900
> Subject: [PATCH 6/6 v8] sctp: Add ASCONF operation on the single-homed host
>
> In this case, the SCTP association transmits an ASCONF packet
> including addition of the new IP address and deletion of the old
> address.  This patch implements this functionality.
> In this case, the ASCONF chunk is added to the beginning of the
> queue, because the other chunks cannot be transmitted in this state.
>
> Signed-off-by: Michio Honda <micchie@sfc.wide.ad.jp>
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> ---
>  include/net/sctp/structs.h |    2 +
>  net/sctp/associola.c       |    6 ++++
>  net/sctp/ipv6.c            |    7 +++++
>  net/sctp/outqueue.c        |   13 ++++++++++
>  net/sctp/protocol.c        |    4 ++-
>  net/sctp/sm_make_chunk.c   |   38 ++++++++++++++++++++++++++++++
>  net/sctp/socket.c          |   55 +++++++++++++++++++++++++++++++++++++++----
>  7 files changed, 118 insertions(+), 7 deletions(-)
>
> diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
> index f7f6add..095f698 100644
> --- a/include/net/sctp/structs.h
> +++ b/include/net/sctp/structs.h
> @@ -1916,6 +1916,8 @@ struct sctp_association {
>  	 * after reaching 4294967295.
>  	 */
>  	__u32 addip_serial;
> +	union sctp_addr *asconf_addr_del_pending;
> +	int src_out_of_asoc_ok;
>  
>  	/* SCTP AUTH: list of the endpoint shared keys.  These
>  	 * keys are provided out of band by the user applicaton
> diff --git a/net/sctp/associola.c b/net/sctp/associola.c
> index 1a21c57..10dc059 100644
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
> index 233eb3a..b493916 100644
> --- a/net/sctp/ipv6.c
> +++ b/net/sctp/ipv6.c
> @@ -334,6 +334,13 @@ static void sctp_v6_get_saddr(struct sctp_sock *sk,
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
> index 1c88c89..edc7532 100644
> --- a/net/sctp/outqueue.c
> +++ b/net/sctp/outqueue.c
> @@ -754,6 +754,16 @@ static int sctp_outq_flush(struct sctp_outq *q, int rtx_timeout)
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
> @@ -881,6 +891,9 @@ static int sctp_outq_flush(struct sctp_outq *q, int rtx_timeout)
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
> index b58a820..d7309927 100644
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
> index 3740603..6363c46 100644
> --- a/net/sctp/sm_make_chunk.c
> +++ b/net/sctp/sm_make_chunk.c
> @@ -2768,6 +2768,12 @@ struct sctp_chunk *sctp_make_asconf_update_ip(struct sctp_association *asoc,
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
> @@ -2780,6 +2786,17 @@ struct sctp_chunk *sctp_make_asconf_update_ip(struct sctp_association *asoc,
>  		totallen += addr_param_len;
>  
>  		addr_buf += af->sockaddr_len;
> +		if (asoc->asconf_addr_del_pending && !del_pickup) {
> +			if (!sctp_in_scope(asoc->asconf_addr_del_pending,
> +			    sctp_scope(addr)))
> +				continue;

scope should olny be check before address is added to the asoc.
delete does not need this, since we have checked that the address
be deleted is existed in the asoc.

You can test with the last test commands I send to your, instead,
ifdown/up the lo device.
$ ifdown lo && ifup lo

> +			/* reuse the parameter length from the same scope one */
> +			totallen += paramlen;
> +			totallen += addr_param_len;
> +			del_pickup = 1;
> +			asoc->src_out_of_asoc_ok = 1;

src_out_of_asoc_ok should be marked when the last address is
assigned to asoc->asconf_addr_del_pending?

> +			SCTP_DEBUG_PRINTK("mkasconf_update_ip: picked same-scope del_pending addr, totallen for all addresses is %d\n", totallen);
> +		}
>  	}
>  
>  	/* Create an asconf chunk with the required length. */
> @@ -2802,6 +2819,19 @@ struct sctp_chunk *sctp_make_asconf_update_ip(struct sctp_association *asoc,
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

How about clean up this part as:

+       if (...) {
+               addr = asoc->asconf_addr_del_pending;
+               af = sctp_get_af_specific(addr->v4.sin_family);
+               addr_param_len = af->to_addr_param(addr, &addr_param);
+               totallen += paramlen;
+               totallen += addr_param_len;
+		...
+       }
+
        /* Create an asconf chunk with the required length. */
        retval = sctp_make_asconf(asoc, laddr, totallen);
        if (!retval)
@@ -2802,6 +2812,18 @@ struct sctp_chunk *sctp_make_asconf_update_ip(struct sctp_association *asoc,
 
                addr_buf += af->sockaddr_len;
        }
+
+       if (...) {
+               addr = asoc->asconf_addr_del_pending;
+               af = sctp_get_af_specific(addr->v4.sin_family);
+               addr_param_len = af->to_addr_param(addr, &addr_param);
+               param.param_hdr.type = SCTP_PARAM_DEL_IP;
+               param.param_hdr.length = htons(paramlen + addr_param_len);
+               param.crr_id = i;
+
+               sctp_addto_chunk(retval, paramlen, &param);
+               sctp_addto_chunk(retval, addr_param_len, &addr_param);
+       }


>  
> @@ -3224,6 +3254,11 @@ static void sctp_asconf_param_success(struct sctp_association *asoc,
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
> @@ -3381,6 +3416,9 @@ int sctp_process_asconf_ack(struct sctp_association *asoc,
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
> index bfa4e8f..d9d9fc2 100644
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
> @@ -715,7 +728,9 @@ static int sctp_send_asconf_del_ip(struct sock		*sk,
>  	struct sctp_sockaddr_entry *saddr;
>  	int 			i;
>  	int 			retval = 0;
> +	int			stored = 0;
>  
> +	chunk = NULL;
>  	if (!sctp_addip_enable)
>  		return retval;
>  
> @@ -766,8 +781,32 @@ static int sctp_send_asconf_del_ip(struct sock		*sk,
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
> @@ -780,6 +819,7 @@ static int sctp_send_asconf_del_ip(struct sock		*sk,
>  			goto out;
>  		}
>  
> +skip_mkasconf:
>  		/* Reset use_as_src flag for the addresses in the bind address
>  		 * list that are to be deleted.
>  		 */
> @@ -805,6 +845,9 @@ static int sctp_send_asconf_del_ip(struct sock		*sk,
>  					     sctp_sk(asoc->base.sk));
>  		}
>  
> +		if (stored)
> +			/* We don't need to transmit ASCONF */
> +			continue;
>  		retval = sctp_send_asconf(asoc, chunk);
>  	}
>  out:
