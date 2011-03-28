From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: Re: [PATCH net-next-2.6] sctp: Add Auto-ASCONF support
Date: Mon, 28 Mar 2011 13:30:11 +0800
Message-ID: <4D901CE3.60501@cn.fujitsu.com>
References: <D2DF7729-C887-443A-A159-EBE58120B4E2@sfc.wide.ad.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
To: Michio Honda <micchie@sfc.wide.ad.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:61173 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751940Ab1C1FaE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Mar 2011 01:30:04 -0400
In-Reply-To: <D2DF7729-C887-443A-A159-EBE58120B4E2@sfc.wide.ad.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> SCTP can reconfigure the IP addresses in the association by using ASCONF chunks as mentioned in RFC5061.  
> For example, we can start to use the newly configured IP address in the existing association.  
> This operation is invoked in two ways: 
> First is operation at the user land to call sctp_bindx() system call.  
> Second is automatic operation in the SCTP stack with address events in the host computer (called auto_asconf) .  
> The former is already implemented, but the latter is not yet. This patch enables it with one sysctl parameter.  

Socket API defined SCTP_AUTO_ASCONF options to enable/disable this
feature, http://tools.ietf.org/html/draft-ietf-tsvwg-sctpsocket-27#page-76

8.1.23.  Set or Get the Auto ASCONF Flag (SCTP_AUTO_ASCONF)

   This option will enable or disable the use of the automatic
   generation of ASCONF chunks to add and delete addresses to an
   existing association.  Note that this option has two caveats namely:
   a) it only affects sockets that are bound to all addresses available
   to the SCTP stack, and b) the system administrator may have an
   overriding control that turns the ASCONF feature off no matter what
   setting the socket option may have.

   This option expects an integer boolean flag, where a non-zero value
   turns on the option, and a zero value turns off the option.

Can you implement it with this option?

Also, your patch should be check first by ./scripts/checkpatch.pl under
kernel sorce.


> Signed-off-by: Michio Honda <micchie@sfc.wide.ad.jp>
> ---
> diff --git a/include/linux/sysctl.h b/include/linux/sysctl.h
> index 11684d9..11c3060 100644
> --- a/include/linux/sysctl.h
> +++ b/include/linux/sysctl.h
> @@ -767,6 +767,7 @@ enum {
>  	NET_SCTP_SNDBUF_POLICY		 = 15,
>  	NET_SCTP_SACK_TIMEOUT		 = 16,
>  	NET_SCTP_RCVBUF_POLICY		 = 17,
> +	NET_SCTP_AUTO_ASCONF_ENABLE	 = 18,
>  };
>  
>  /* /proc/sys/net/bridge */
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
> +
>  #endif /* __sctp_constants_h__ */
> diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
> index 505845d..7161932 100644
> --- a/include/net/sctp/sctp.h
> +++ b/include/net/sctp/sctp.h
> @@ -121,6 +121,7 @@ extern int sctp_copy_local_addr_list(struct sctp_bind_addr *,
>  				     int flags);
>  extern struct sctp_pf *sctp_get_pf_specific(sa_family_t family);
>  extern int sctp_register_pf(struct sctp_pf *, sa_family_t);
> +void sctp_addr_wq_mgmt(union sctp_addr *, int);
>  
>  /*
>   * sctp/socket.c
> @@ -135,6 +136,8 @@ void sctp_sock_rfree(struct sk_buff *skb);
>  void sctp_copy_sock(struct sock *newsk, struct sock *sk,
>  		    struct sctp_association *asoc);
>  extern struct percpu_counter sctp_sockets_allocated;
> +int sctp_asconf_mgmt(struct sctp_endpoint *, struct sock *sk);
> +void sctp_add_addr_to_laddr(struct sockaddr *, struct sctp_association *);
>  
>  /*
>   * sctp/primitive.c
> diff --git a/include/net/sctp/sm.h b/include/net/sctp/sm.h
> index 9352d12..498a3cf 100644
> --- a/include/net/sctp/sm.h
> +++ b/include/net/sctp/sm.h
> @@ -259,6 +259,7 @@ struct sctp_chunk *sctp_process_asconf(struct sctp_association *asoc,
>  				       struct sctp_chunk *asconf);
>  int sctp_process_asconf_ack(struct sctp_association *asoc,
>  			    struct sctp_chunk *asconf_ack);
> +void sctp_path_check_and_react(struct sctp_association *, struct sockaddr *);
>  struct sctp_chunk *sctp_make_fwdtsn(const struct sctp_association *asoc,
>  				    __u32 new_cum_tsn, size_t nstreams,
>  				    struct sctp_fwdtsn_skip *skiplist);
> diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
> index cc9185c..0c6a6f4 100644
> --- a/include/net/sctp/structs.h
> +++ b/include/net/sctp/structs.h
> @@ -205,6 +205,11 @@ extern struct sctp_globals {
>  	 * It is a list of sctp_sockaddr_entry.
>  	 */
>  	struct list_head local_addr_list;
> +	int auto_asconf_enable;
> +	struct list_head addr_waitq;
> +	struct timer_list addr_wq_timer;
> +	struct list_head auto_asconf_eplist;
> +	spinlock_t addr_wq_lock;
>  
>  	/* Lock that protects the local_addr_list writers */
>  	spinlock_t addr_list_lock;
> @@ -264,6 +269,11 @@ extern struct sctp_globals {
>  #define sctp_port_hashtable		(sctp_globals.port_hashtable)
>  #define sctp_local_addr_list		(sctp_globals.local_addr_list)
>  #define sctp_local_addr_lock		(sctp_globals.addr_list_lock)
> +#define sctp_auto_asconf_eplist		(sctp_globals.auto_asconf_eplist)
> +#define sctp_addr_waitq			(sctp_globals.addr_waitq)
> +#define sctp_addr_wq_timer		(sctp_globals.addr_wq_timer)
> +#define sctp_addr_wq_lock		(sctp_globals.addr_wq_lock)
> +#define sctp_auto_asconf_enable		(sctp_globals.auto_asconf_enable)
>  #define sctp_scope_policy		(sctp_globals.ipv4_scope_policy)
>  #define sctp_addip_enable		(sctp_globals.addip_enable)
>  #define sctp_addip_noauth		(sctp_globals.addip_noauth_enable)
> @@ -796,6 +806,16 @@ struct sctp_sockaddr_entry {
>  	__u8 valid;
>  };
>  
> +#define SCTP_NEWADDR	1
> +#define SCTP_DELADDR	2
> +#define SCTP_ADDRESS_TICK_DELAY	500
> +struct sctp_addr_wait {
> +	struct list_head list;
> +	struct rcu_head rcu;
> +	union sctp_addr a;
> +	int	cmd;
> +};
> +
>  typedef struct sctp_chunk *(sctp_packet_phandler_t)(struct sctp_association *);
>  
>  /* This structure holds lists of chunks as we are assembling for
> @@ -1239,6 +1259,7 @@ sctp_scope_t sctp_scope(const union sctp_addr *);
>  int sctp_in_scope(const union sctp_addr *addr, const sctp_scope_t scope);
>  int sctp_is_any(struct sock *sk, const union sctp_addr *addr);
>  int sctp_addr_is_valid(const union sctp_addr *addr);
> +int sctp_is_ep_boundall(struct sock *sk);
>  
>  
>  /* What type of endpoint?  */
> @@ -1267,6 +1288,7 @@ struct sctp_ep_common {
>  	/* Fields to help us manage our entries in the hash tables. */
>  	struct hlist_node node;
>  	int hashent;
> +	struct list_head auto_asconf_list;
>  
>  	/* Runtime type information.  What kind of endpoint is this? */
>  	sctp_endpoint_type_t type;
> @@ -1901,6 +1923,17 @@ struct sctp_association {
>  	 * after reaching 4294967295.
>  	 */
>  	__u32 addip_serial;
> +	/* list of valid addresses in association local 
> +	 * This list is needed to ensure base.bind_addr being a valid address 
> +	 * list of the endpoint-wide.  When one of associations receives 
> +	 * ASCONF-ACK, that address is added to this list.  When all 
> +	 * associations belonging to the same endpoint receive ASCONF-ACKs, 
> +	 * that address is added to base.bind_addr
> +	 */
> +	struct list_head asoc_laddr_list; 
> +	union sctp_addr *asconf_addr_del_pending;
> +	__u32 asconf_del_pending_cid;
> +	int src_out_of_asoc_ok;
>  
>  	/* SCTP AUTH: list of the endpoint shared keys.  These
>  	 * keys are provided out of band by the user applicaton
> diff --git a/net/sctp/associola.c b/net/sctp/associola.c
> index 6b04287..2811f12 100644
> --- a/net/sctp/associola.c
> +++ b/net/sctp/associola.c
> @@ -280,6 +280,10 @@ static struct sctp_association *sctp_association_init(struct sctp_association *a
>  	if (sctp_addip_noauth)
>  		asoc->peer.asconf_capable = 1;
>  
> +	asoc->asconf_addr_del_pending = NULL;
> +	asoc->asconf_del_pending_cid = 0;
> +	asoc->src_out_of_asoc_ok = 0;
> +	INIT_LIST_HEAD(&asoc->asoc_laddr_list);
>  	/* Create an input queue.  */
>  	sctp_inq_init(&asoc->base.inqueue);
>  	sctp_inq_set_th_handler(&asoc->base.inqueue, sctp_assoc_bh_rcv);
> @@ -446,6 +450,17 @@ void sctp_association_free(struct sctp_association *asoc)
>  	/* Free any cached ASCONF_ACK chunk. */
>  	sctp_assoc_free_asconf_acks(asoc);
>  
> +	/* Free pending address space being deleted */
> +	if (asoc->asconf_addr_del_pending != NULL) 
> +		kfree(asoc->asconf_addr_del_pending);
> +	if (!list_empty(&asoc->asoc_laddr_list)) {
> +		struct sctp_sockaddr_entry *laddr, *tmp;
> +		list_for_each_entry_safe(laddr, tmp, &asoc->asoc_laddr_list, list) {
> +			list_del(&laddr->list);
> +			kfree(laddr);
> +		}
> +	}
> +
>  	/* Free any cached ASCONF chunk. */
>  	if (asoc->addip_last_asconf)
>  		sctp_chunk_free(asoc->addip_last_asconf);
> @@ -620,6 +635,7 @@ void sctp_assoc_rm_peer(struct sctp_association *asoc,
>  			if (!mod_timer(&active->T3_rtx_timer,
>  					jiffies + active->rto))
>  				sctp_transport_hold(active);
> +		active->flight_size += peer->flight_size;
>  	}
>  
>  	asoc->peer.transport_count--;
> @@ -1277,7 +1293,7 @@ void sctp_assoc_update(struct sctp_association *asoc,
>   */
>  void sctp_assoc_update_retran_path(struct sctp_association *asoc)
>  {
> -	struct sctp_transport *t, *next;
> +	struct sctp_transport *t, *next, *unconfirmed;
>  	struct list_head *head = &asoc->peer.transport_addr_list;
>  	struct list_head *pos;
>  
> @@ -1287,7 +1303,7 @@ void sctp_assoc_update_retran_path(struct sctp_association *asoc)
>  	/* Find the next transport in a round-robin fashion. */
>  	t = asoc->peer.retran_path;
>  	pos = &t->transports;
> -	next = NULL;
> +	next = unconfirmed = NULL;
>  
>  	while (1) {
>  		/* Skip the head. */
> @@ -1318,11 +1334,15 @@ void sctp_assoc_update_retran_path(struct sctp_association *asoc)
>  			 */
>  			if (t->state != SCTP_UNCONFIRMED && !next)
>  				next = t;
> +			else if (t->state == SCTP_UNCONFIRMED) 
> +				unconfirmed = t;
>  		}
>  	}
>  
>  	if (t)
>  		asoc->peer.retran_path = t;
> +	else if (unconfirmed) 
> +		asoc->peer.retran_path = t = unconfirmed;
>  
>  	SCTP_DEBUG_PRINTK_IPADDR("sctp_assoc_update_retran_path:association"
>  				 " %p addr: ",
> diff --git a/net/sctp/bind_addr.c b/net/sctp/bind_addr.c
> index faf71d1..ef6d0c5 100644
> --- a/net/sctp/bind_addr.c
> +++ b/net/sctp/bind_addr.c
> @@ -536,6 +536,24 @@ int sctp_in_scope(const union sctp_addr *addr, sctp_scope_t scope)
>  	return 0;
>  }
>  
> +int sctp_is_ep_boundall(struct sock *sk)
> +{
> +	struct sctp_bind_addr *bp;
> +	struct sctp_sockaddr_entry *addr;
> +
> +	if (!sk) 
> +		return 0;
> +      
> +	bp = &sctp_sk(sk)->ep->base.bind_addr;
> +	if (sctp_list_single_entry(&bp->address_list)) {
> +		addr = list_entry(bp->address_list.next,
> +				  struct sctp_sockaddr_entry, list);
> +		if (sctp_is_any(sk, &addr->a)) 
> +			return 1;
> +	}
> +	return 0;
> +}
> +
>  /********************************************************************
>   * 3rd Level Abstractions
>   ********************************************************************/
> diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
> index 865ce7b..471facd 100644
> --- a/net/sctp/ipv6.c
> +++ b/net/sctp/ipv6.c
> @@ -105,6 +105,7 @@ static int sctp_inet6addr_event(struct notifier_block *this, unsigned long ev,
>  			addr->valid = 1;
>  			spin_lock_bh(&sctp_local_addr_lock);
>  			list_add_tail_rcu(&addr->list, &sctp_local_addr_list);
> +			sctp_addr_wq_mgmt(&addr->a, SCTP_NEWADDR);
>  			spin_unlock_bh(&sctp_local_addr_lock);
>  		}
>  		break;
> @@ -115,6 +116,7 @@ static int sctp_inet6addr_event(struct notifier_block *this, unsigned long ev,
>  			if (addr->a.sa.sa_family == AF_INET6 &&
>  					ipv6_addr_equal(&addr->a.v6.sin6_addr,
>  						&ifa->addr)) {
> +				sctp_addr_wq_mgmt(&addr->a, SCTP_DELADDR);
>  				found = 1;
>  				addr->valid = 0;
>  				list_del_rcu(&addr->list);
> @@ -332,8 +334,26 @@ static void sctp_v6_get_saddr(struct sctp_sock *sk,
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
> +	}
> +	if (baddr == NULL) {
> +		/* We don't have a valid src addr in "endpoint-wide".  
> +		 * Looking up in assoc-locally valid address list.  
> +		 */
> +		list_for_each_entry(laddr, &asoc->asoc_laddr_list, list) {
> +			bmatchlen = sctp_v6_addr_match_len(daddr, &laddr->a);
> +			if (!baddr || (matchlen < bmatchlen)) {
> +				baddr = &laddr->a;
> +				matchlen = bmatchlen;
> +			}
> +		}
>  	}
> -
>  	if (baddr) {
>  		memcpy(saddr, baddr, sizeof(union sctp_addr));
>  		SCTP_DEBUG_PRINTK("saddr: %pI6\n", &saddr->v6.sin6_addr);
> diff --git a/net/sctp/outqueue.c b/net/sctp/outqueue.c
> index 26dc005..f32fa65 100644
> --- a/net/sctp/outqueue.c
> +++ b/net/sctp/outqueue.c
> @@ -344,7 +344,13 @@ int sctp_outq_tail(struct sctp_outq *q, struct sctp_chunk *chunk)
>  			break;
>  		}
>  	} else {
> -		list_add_tail(&chunk->list, &q->control_chunk_list);
> +		/* We add the ASCONF for the only one newly added address at 
> +		 * the front of the queue 
> +		 */
> +		if (q->asoc->src_out_of_asoc_ok && chunk->chunk_hdr->type == SCTP_CID_ASCONF)
> +			list_add(&chunk->list, &q->control_chunk_list);
> +		else
> +			list_add_tail(&chunk->list, &q->control_chunk_list);
>  		SCTP_INC_STATS(SCTP_MIB_OUTCTRLCHUNKS);
>  	}
>  
> @@ -850,6 +856,24 @@ static int sctp_outq_flush(struct sctp_outq *q, int rtx_timeout)
>  		case SCTP_CID_SHUTDOWN:
>  		case SCTP_CID_ECN_ECNE:
>  		case SCTP_CID_ASCONF:
> +			/* RFC 5061, 5.3
> +			 * F1) This means that until such time as the ASCONF 
> +			 * containing the add is acknowledged, the sender MUST 
> +			 * NOT use the new IP address as a source for ANY SCTP 
> +			 * packet except on carrying an ASCONF Chunk.
> +			 */
> +			if (asoc->src_out_of_asoc_ok) {
> +				SCTP_DEBUG_PRINTK("outq_flush: out_of_asoc_ok, transmit chunk type %d\n", chunk->chunk_hdr->type);
> +				packet = &transport->packet;
> +				sctp_packet_config(packet, vtag, 
> +						asoc->peer.ecn_capable);
> +				sctp_packet_append_chunk(packet, chunk);
> +				error = sctp_packet_transmit(packet);
> +				if (error < 0) {
> +					return error;
> +				}
> +				goto sctp_flush_out;
> +			}
>  		case SCTP_CID_FWD_TSN:
>  			status = sctp_packet_transmit_chunk(packet, chunk,
>  							    one_packet);
> diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
> index 152976e..163c422 100644
> --- a/net/sctp/protocol.c
> +++ b/net/sctp/protocol.c
> @@ -510,12 +510,19 @@ static struct dst_entry *sctp_v4_get_dst(struct sctp_association *asoc,
>  		sctp_v4_dst_saddr(&dst_saddr, dst, htons(bp->port));
>  		rcu_read_lock();
>  		list_for_each_entry_rcu(laddr, &bp->address_list, list) {
> -			if (!laddr->valid || (laddr->state != SCTP_ADDR_SRC))
> +			if (!laddr->valid || ((laddr->state != SCTP_ADDR_SRC) && (asoc->src_out_of_asoc_ok == 0)))
>  				continue;
>  			if (sctp_v4_cmp_addr(&dst_saddr, &laddr->a))
>  				goto out_unlock;
>  		}
>  		rcu_read_unlock();
> +		/* We don't have a valid src addr in "endpoint-wide".  
> +		 * Looking up in assoc-locally valid address list.  
> +		 */
> +		list_for_each_entry(laddr, &asoc->asoc_laddr_list, list) {
> +			if (sctp_v4_cmp_addr(&dst_saddr, &laddr->a))
> +				goto out_unlock;
> +		}
>  
>  		/* None of the bound addresses match the source address of the
>  		 * dst. So release it.
> @@ -636,6 +643,170 @@ static void sctp_v4_ecn_capable(struct sock *sk)
>  	INET_ECN_xmit(sk);
>  }
>  
> +void sctp_addr_wq_timeout_handler(unsigned long arg)
> +{
> +	struct sctp_addr_wait *addrw = NULL;
> +	union sctp_addr *addr = NULL;
> +	struct sctp_ep_common *epb = NULL;
> +	struct sctp_endpoint *ep = NULL;
> +	int cnt=0;
> +
> +	spin_lock_bh(&sctp_addr_wq_lock);
> +retry_wq:
> +	if (list_empty(&sctp_addr_waitq)) {
> +		SCTP_DEBUG_PRINTK("sctp_addrwq_timo_handler: nothing in addr waitq\n");
> +		spin_unlock_bh(&sctp_addr_wq_lock);
> +		return;
> +	}
> +	addrw = list_first_entry(&sctp_addr_waitq, struct sctp_addr_wait, list);
> +	if (addrw->cmd != SCTP_NEWADDR && addrw->cmd != SCTP_DELADDR) {
> +		SCTP_DEBUG_PRINTK("sctp_addrwq_timo_handler: Huh, cmd is neither NEWADDR nor DELADDR\n");
> +		list_del(&addrw->list);
> +		kfree(addrw);
> +		goto retry_wq;
> +	}
> +
> +	addr = &addrw->a;
> +	SCTP_DEBUG_PRINTK_IPADDR("sctp_addrwq_timo_handler: the first ent in wq %p is "," for cmd %d at entry %p\n", &sctp_addr_waitq, addr, addrw->cmd, addrw);
> +
> +	/* Now we send an ASCONF for each association */
> +	/* Note. we currently don't handle link local IPv6 addressees */
> +	if (addr->sa.sa_family == AF_INET6) {
> +		struct in6_addr *in6 = (struct in6_addr *)&addr->v6.sin6_addr;
> +
> +		if (ipv6_addr_type(&addr->v6.sin6_addr) & IPV6_ADDR_LINKLOCAL) {
> +			SCTP_DEBUG_PRINTK("sctp_timo_handler: link local, hence don't tell eps\n");
> +			list_del(&addrw->list);
> +			kfree(addrw);
> +			goto retry_wq;
> +		}
> +		if (ipv6_chk_addr(&init_net, in6, NULL, 0) == 0 && addrw->cmd == SCTP_NEWADDR) {
> +			unsigned long timeo_val;
> +
> +			SCTP_DEBUG_PRINTK("sctp_timo_handler: this is on DAD, trying %d sec later\n", SCTP_ADDRESS_TICK_DELAY);
> +			timeo_val = jiffies;
> +			timeo_val += msecs_to_jiffies(SCTP_ADDRESS_TICK_DELAY);
> +			(void)mod_timer(&sctp_addr_wq_timer, timeo_val);
> +			spin_unlock_bh(&sctp_addr_wq_lock);
> +			return;
> +		}
> +	}
> +	list_for_each_entry(epb, &sctp_auto_asconf_eplist, auto_asconf_list) {
> +		if (epb == NULL) {
> +			SCTP_DEBUG_PRINTK("addrwq_timo_handler: no epb\n");
> +			continue;
> +		}
> +		if (!sctp_is_ep_boundall(epb->sk)) 
> +			/* ignore bound-specific endpoints */
> +			continue;
> +		ep = sctp_ep(epb);
> +		sctp_bh_lock_sock(epb->sk);
> +		if (sctp_asconf_mgmt(ep, epb->sk) < 0) {
> +			SCTP_DEBUG_PRINTK("sctp_addrwq_timo_handler: sctp_asconf_mgmt failed\n");
> +			sctp_bh_unlock_sock(epb->sk);
> +			continue;
> +		}
> +		sctp_bh_unlock_sock(epb->sk);
> +		++cnt;
> +	}
> +
> +	list_del(&addrw->list);
> +	kfree(addrw);
> +
> +	if (list_empty(&sctp_addr_waitq)) {
> +		spin_unlock_bh(&sctp_addr_wq_lock);
> +		return;
> +	} else 
> +		goto retry_wq;
> +
> +	spin_unlock_bh(&sctp_addr_wq_lock);
> +}
> +
> +void sctp_addr_wq_mgmt(union sctp_addr *reqaddr, int cmd)
> +{
> +	struct sctp_addr_wait *addrw = NULL;
> +	struct sctp_addr_wait *addrw_new = NULL;
> +	unsigned long timeo_val;
> +	union sctp_addr *tmpaddr; // for debugging
> +
> +	/* first, we check if an opposite message already exist in the queue.  
> +	 * If we found such message, it is removed.  
> +	 * This operation is a bit stupid, but the DHCP client attaches the 
> +	 * new address after a couple of addition and deletion of that address
> +	 */
> +
> +	if (reqaddr == NULL) {
> +		SCTP_DEBUG_PRINTK("sctp_addr_wq_mgmt: no address message?\n");
> +		return;
> +	}
> +	
> +	spin_lock_bh(&sctp_addr_wq_lock);
> +	/* Offsets existing events in addr_wq */
> +	list_for_each_entry(addrw, &sctp_addr_waitq, list) {
> +		if (addrw->a.sa.sa_family != reqaddr->sa.sa_family) 
> +			continue;
> +		if (reqaddr->sa.sa_family == AF_INET) {
> +			if (reqaddr->v4.sin_addr.s_addr == addrw->a.v4.sin_addr.s_addr) {
> +				if (cmd != addrw->cmd) {
> +					tmpaddr = &addrw->a;
> +					SCTP_DEBUG_PRINTK_IPADDR("sctp_addr_wq_mgmt offsets existing entry for %d "," in waitq %p\n", addrw->cmd, tmpaddr, &sctp_addr_waitq);
> +					list_del(&addrw->list);
> +					kfree(addrw);
> +					/* nothing to do anymore */
> +					spin_unlock_bh(&sctp_addr_wq_lock);
> +					return;
> +				}
> +			}
> +		}
> +		else if (reqaddr->sa.sa_family == AF_INET6) {
> +			if (ipv6_addr_equal(&reqaddr->v6.sin6_addr, &addrw->a.v6.sin6_addr)) {
> +				if (cmd != addrw->cmd) {
> +					tmpaddr = &addrw->a;
> +					SCTP_DEBUG_PRINTK_IPADDR("sctp_addr_wq_mgmt: offsets existing entry for %d "," in waitq %p\n", addrw->cmd, tmpaddr, &sctp_addr_waitq);
> +					list_del(&addrw->list);
> +					kfree(addrw);
> +					spin_unlock_bh(&sctp_addr_wq_lock);
> +					return;
> +				}
> +			}
> +		}
> +	}
> +				
> +	/* OK, we have to add the new address to the wait queue */
> +	addrw_new = kzalloc(sizeof(struct sctp_addr_wait), GFP_ATOMIC);
> +	if (addrw_new == NULL) {
> +		SCTP_DEBUG_PRINTK("sctp_addr_weitq_mgmt no memory? return\n");
> +		spin_unlock_bh(&sctp_addr_wq_lock);
> +		return;
> +	}
> +	if (reqaddr->sa.sa_family == AF_INET) {
> +		addrw_new->a.v4.sin_family = AF_INET;
> +		addrw_new->a.v4.sin_addr.s_addr = reqaddr->v4.sin_addr.s_addr;
> +	} else if (reqaddr->sa.sa_family == AF_INET6) {
> +		addrw_new->a.v6.sin6_family = AF_INET6;
> +		ipv6_addr_copy(&addrw_new->a.v6.sin6_addr, &reqaddr->v6.sin6_addr);
> +	} else {
> +		SCTP_DEBUG_PRINTK("sctp_addr_waitq_mgmt: Unknown family of request addr, return\n");
> +		kfree(addrw_new);
> +		spin_unlock_bh(&sctp_addr_wq_lock);
> +		return;
> +	}
> +	addrw_new->cmd = cmd;
> +	list_add_tail(&addrw_new->list, &sctp_addr_waitq);
> +	tmpaddr = &addrw_new->a;
> +	SCTP_DEBUG_PRINTK_IPADDR("sctp_addr_wq_mgmt add new entry for cmd:%d "," in waitq %p, start a timer\n", addrw_new->cmd, tmpaddr, &sctp_addr_waitq);
> +
> +	if (timer_pending(&sctp_addr_wq_timer)) {
> +		SCTP_DEBUG_PRINTK("sctp_addr_wq_mgmt: addr_wq timer is already running\n");
> +		spin_unlock_bh(&sctp_addr_wq_lock);
> +		return;
> +	}
> +	timeo_val = jiffies;
> +	timeo_val += msecs_to_jiffies(SCTP_ADDRESS_TICK_DELAY);
> +	(void)mod_timer(&sctp_addr_wq_timer, timeo_val);
> +	spin_unlock_bh(&sctp_addr_wq_lock);
> +}
> +
>  /* Event handler for inet address addition/deletion events.
>   * The sctp_local_addr_list needs to be protocted by a spin lock since
>   * multiple notifiers (say IPv4 and IPv6) may be running at the same
> @@ -663,6 +834,7 @@ static int sctp_inetaddr_event(struct notifier_block *this, unsigned long ev,
>  			addr->valid = 1;
>  			spin_lock_bh(&sctp_local_addr_lock);
>  			list_add_tail_rcu(&addr->list, &sctp_local_addr_list);
> +			sctp_addr_wq_mgmt(&addr->a, SCTP_NEWADDR);
>  			spin_unlock_bh(&sctp_local_addr_lock);
>  		}
>  		break;
> @@ -673,6 +845,7 @@ static int sctp_inetaddr_event(struct notifier_block *this, unsigned long ev,
>  			if (addr->a.sa.sa_family == AF_INET &&
>  					addr->a.v4.sin_addr.s_addr ==
>  					ifa->ifa_local) {
> +				sctp_addr_wq_mgmt(&addr->a, SCTP_DELADDR);
>  				found = 1;
>  				addr->valid = 0;
>  				list_del_rcu(&addr->list);
> @@ -1277,6 +1450,11 @@ SCTP_STATIC __init int sctp_init(void)
>  
>  	/* Initialize the local address list. */
>  	INIT_LIST_HEAD(&sctp_local_addr_list);
> +	INIT_LIST_HEAD(&sctp_addr_waitq);
> +	INIT_LIST_HEAD(&sctp_auto_asconf_eplist);
> +	spin_lock_init(&sctp_addr_wq_lock);
> +	sctp_addr_wq_timer.expires = 0;
> +	setup_timer(&sctp_addr_wq_timer, sctp_addr_wq_timeout_handler, (unsigned long)NULL); 
>  	spin_lock_init(&sctp_local_addr_lock);
>  	sctp_get_local_addr_list();
>  
> diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
> index de98665..9e15f49 100644
> --- a/net/sctp/sm_make_chunk.c
> +++ b/net/sctp/sm_make_chunk.c
> @@ -2651,6 +2651,56 @@ __u32 sctp_generate_tsn(const struct sctp_endpoint *ep)
>  	return retval;
>  }
>  
> +void
> +sctp_path_check_and_react(struct sctp_association *asoc, struct sockaddr *sa)
> +{
> +	struct sctp_transport *trans;
> +	int addrnum, family;
> +	struct sctp_sockaddr_entry *saddr;
> +	struct sctp_bind_addr *bp;
> +	union sctp_addr *tmpaddr;
> +
> +	family = sa->sa_family;
> +	bp = &asoc->base.bind_addr;
> +	addrnum = 0;
> +	/* count up the number of local addresses in the same family */
> +	list_for_each_entry(saddr, &bp->address_list, list) {
> +		if (saddr->a.sa.sa_family == family) {
> +			tmpaddr = &saddr->a;
> +			if (family == AF_INET6 && 
> +			    ipv6_addr_type(&tmpaddr->v6.sin6_addr) & 
> +			    IPV6_ADDR_LINKLOCAL) {
> +				continue;
> +			}
> +			addrnum++;
> +		}
> +	}
> +	if (addrnum == 1) {
> +		union sctp_addr *tmpaddr;
> +		tmpaddr = (union sctp_addr *)sa;
> +		SCTP_DEBUG_PRINTK_IPADDR("pcheck_react: only 1 local addr in asoc %p "," family %d\n", asoc, tmpaddr, family);
> +		list_for_each_entry(trans, &asoc->peer.transport_addr_list, transports) {
> +			/* reset path information and release refcount to the 
> +			 * dst_entry  based on the src change */
> +			sctp_transport_hold(trans);
> +			trans->cwnd = min(4*asoc->pathmtu, max_t(__u32, 2*asoc->pathmtu, 4380));
> +			trans->ssthresh = asoc->peer.i.a_rwnd;
> +			trans->rtt = 0;
> +			trans->srtt = 0;
> +			trans->rttvar = 0;
> +			trans->rto = asoc->rto_initial;
> +			dst_release(trans->dst);
> +			trans->dst = NULL;
> +			memset(&trans->saddr, 0, sizeof(union sctp_addr));
> +			sctp_transport_route(trans, NULL, sctp_sk(asoc->base.sk));
> +			SCTP_DEBUG_PRINTK_IPADDR("we freed dst_entry (asoc: %p dst: "," trans: %p)\n", asoc, (&trans->ipaddr), trans);
> +			trans->rto_pending = 1;
> +			sctp_transport_put(trans);
> +		}
> +	}
> +	return;
> +}
> +
>  /*
>   * ADDIP 3.1.1 Address Configuration Change Chunk (ASCONF)
>   *      0                   1                   2                   3
> @@ -2744,11 +2794,29 @@ struct sctp_chunk *sctp_make_asconf_update_ip(struct sctp_association *asoc,
>  	int			addr_param_len = 0;
>  	int 			totallen = 0;
>  	int 			i;
> +	sctp_addip_param_t del_param; /* 8 Bytes (Type 0xC002, Len and CrrID) */
> +	sctp_addip_param_t spr_param;
> +	struct sctp_af *del_af;
> +	struct sctp_af *spr_af;
> +	int del_addr_param_len = 0;
> +	int spr_addr_param_len = 0;
> +	int del_paramlen = sizeof(sctp_addip_param_t);
> +	int spr_paramlen = sizeof(sctp_addip_param_t);
> +	union sctp_addr_param del_addr_param; // (v4) 8 Bytes, (v6) 20 Bytes
> +	union sctp_addr_param spr_addr_param;
> +	int			v4 = 0;
> +	int			v6 = 0;
>  
>  	/* Get total length of all the address parameters. */
>  	addr_buf = addrs;
>  	for (i = 0; i < addrcnt; i++) {
>  		addr = (union sctp_addr *)addr_buf;
> +		if (addr != NULL) {
> +			if (addr->sa.sa_family == AF_INET) 
> +				v4 = 1;
> +			else if (addr->sa.sa_family == AF_INET6) 
> +				v6 = 1;
> +		}
>  		af = sctp_get_af_specific(addr->v4.sin_family);
>  		addr_param_len = af->to_addr_param(addr, &addr_param);
>  
> @@ -2757,6 +2825,34 @@ struct sctp_chunk *sctp_make_asconf_update_ip(struct sctp_association *asoc,
>  
>  		addr_buf += af->sockaddr_len;
>  	}
> +	/* Add the length of a pending address being deleted */
> +	if (flags == SCTP_PARAM_ADD_IP && asoc->asconf_addr_del_pending) {
> +		if ((asoc->asconf_addr_del_pending->sa.sa_family == AF_INET 
> +		    && v4) || 
> +		    (asoc->asconf_addr_del_pending->sa.sa_family == AF_INET6
> +		    && v6)) {
> +			del_af = sctp_get_af_specific(asoc->asconf_addr_del_pending->sa.sa_family);
> +			del_addr_param_len = del_af->to_addr_param(asoc->asconf_addr_del_pending, &del_addr_param);
> +			totallen += del_paramlen;
> +			totallen += del_addr_param_len;
> +			SCTP_DEBUG_PRINTK("mkasconf_update_ip: now we picked del_pending addr, totallen for all addresses is %d\n", totallen);
> +			/* for Set Primary (equal size as del parameters */
> +			totallen += del_paramlen;
> +			totallen += del_addr_param_len;
> +		}
> +		if (v4) {
> +			if (totallen != 32 && totallen != 48) {
> +				SCTP_DEBUG_PRINTK("mkasconf_update_ip: incorrect total length of ASCONF parameters, del + add MUST be 32 bytes, but %d bytes\n", totallen);
> +			return NULL;
> +			}
> +		} else if (v6) {
> +			if (totallen != 56 && totallen != 84) {
> +				SCTP_DEBUG_PRINTK("mkasconf_update_ip: incorrect total length of ASCONF parameters, del + add MUST be 56 bytes, but %d bytes\n", totallen);
> +			return NULL;
> +			}
> +		}
> +	}
> +	SCTP_DEBUG_PRINTK("mkasconf_update_ip: call mkasconf() for %d bytes\n", totallen);
>  
>  	/* Create an asconf chunk with the required length. */
>  	retval = sctp_make_asconf(asoc, laddr, totallen);
> @@ -2778,6 +2874,28 @@ struct sctp_chunk *sctp_make_asconf_update_ip(struct sctp_association *asoc,
>  
>  		addr_buf += af->sockaddr_len;
>  	}
> +	if (flags == SCTP_PARAM_ADD_IP && asoc->asconf_addr_del_pending) {
> +		addr = asoc->asconf_addr_del_pending;
> +		del_af = sctp_get_af_specific(addr->v4.sin_family);
> +		del_addr_param_len = del_af->to_addr_param(addr, &del_addr_param);
> +		del_param.param_hdr.type = SCTP_PARAM_DEL_IP;
> +		del_param.param_hdr.length = htons(del_paramlen + del_addr_param_len);
> +		del_param.crr_id = i;
> +		asoc->asconf_del_pending_cid = i;
> +
> +		sctp_addto_chunk(retval, del_paramlen, &del_param);
> +		sctp_addto_chunk(retval, del_addr_param_len, &del_addr_param);
> +		/* For SET_PRIMARY */
> +		addr_buf = addrs;
> +		addr = (union sctp_addr *)addr_buf;
> +		spr_af = sctp_get_af_specific(addr->v4.sin_family);
> +		spr_addr_param_len = spr_af->to_addr_param(addr, &spr_addr_param);
> +		spr_param.param_hdr.type = SCTP_PARAM_SET_PRIMARY;
> +		spr_param.param_hdr.length = htons(spr_paramlen + spr_addr_param_len);
> +		spr_param.crr_id = (i+1);
> +		sctp_addto_chunk(retval, spr_paramlen, &spr_param);
> +		sctp_addto_chunk(retval, spr_addr_param_len, &spr_addr_param);
> +	}
>  	return retval;
>  }
>  
> @@ -2990,7 +3108,7 @@ static __be16 sctp_process_asconf_param(struct sctp_association *asoc,
>  		 * an Error Cause TLV set to the new error code 'Request to
>  		 * Delete Source IP Address'
>  		 */
> -		if (sctp_cmp_addr_exact(sctp_source(asconf), &addr))
> +		if (sctp_cmp_addr_exact(&asconf->source, &addr))
>  			return SCTP_ERROR_DEL_SRC_IP;
>  
>  		/* Section 4.2.2
> @@ -3171,7 +3289,6 @@ static void sctp_asconf_param_success(struct sctp_association *asoc,
>  	struct sctp_bind_addr *bp = &asoc->base.bind_addr;
>  	union sctp_addr_param *addr_param;
>  	struct sctp_transport *transport;
> -	struct sctp_sockaddr_entry *saddr;
>  
>  	addr_param = (union sctp_addr_param *)
>  			((void *)asconf_param + sizeof(sctp_addip_param_t));
> @@ -3186,9 +3303,17 @@ static void sctp_asconf_param_success(struct sctp_association *asoc,
>  		 * held, so the list can not change.
>  		 */
>  		local_bh_disable();
> -		list_for_each_entry(saddr, &bp->address_list, list) {
> -			if (sctp_cmp_addr_exact(&saddr->a, &addr))
> -				saddr->state = SCTP_ADDR_SRC;
> +		/* Until this ASCONF is acked on all associations, we cannot 
> +		 * consider this address as ADDR_SRC that means available for
> +		 * all association belonging to the same endpoint
> +		 */
> +		asoc->src_out_of_asoc_ok = 0;
> +		sctp_add_addr_to_laddr(&addr.sa, asoc);
> +		list_for_each_entry(transport, &asoc->peer.transport_addr_list,
> +				transports) {
> +			dst_release(transport->dst);
> +			sctp_transport_route(transport, NULL,
> +					     sctp_sk(asoc->base.sk));
>  		}
>  		local_bh_enable();
>  		list_for_each_entry(transport, &asoc->peer.transport_addr_list,
> @@ -3203,6 +3328,26 @@ static void sctp_asconf_param_success(struct sctp_association *asoc,
>  	case SCTP_PARAM_DEL_IP:
>  		local_bh_disable();
>  		sctp_del_bind_addr(bp, &addr);
> +		if (asoc->asconf_addr_del_pending != NULL) {
> +			if ((addr.sa.sa_family == AF_INET) && 
> +			    (asoc->asconf_addr_del_pending->sa.sa_family == 
> +			     AF_INET)) {
> +				if (asoc->asconf_addr_del_pending->v4.sin_addr.s_addr == addr.v4.sin_addr.s_addr) {
> +					kfree(asoc->asconf_addr_del_pending);
> +					asoc->asconf_del_pending_cid = 0;
> +					asoc->asconf_addr_del_pending = NULL;
> +				}
> +			} 
> +			else if ((addr.sa.sa_family == AF_INET6) && 
> +				(asoc->asconf_addr_del_pending->sa.sa_family == 
> +				 AF_INET6)) {
> +				if (ipv6_addr_equal(&asoc->asconf_addr_del_pending->v6.sin6_addr, &addr.v6.sin6_addr)) {
> +					kfree(asoc->asconf_addr_del_pending);
> +					asoc->asconf_del_pending_cid = 0;
> +					asoc->asconf_addr_del_pending = NULL;
> +				}
> +			}
> +		}
>  		local_bh_enable();
>  		list_for_each_entry(transport, &asoc->peer.transport_addr_list,
>  				transports) {
> @@ -3293,6 +3438,8 @@ int sctp_process_asconf_ack(struct sctp_association *asoc,
>  	int	no_err = 1;
>  	int	retval = 0;
>  	__be16	err_code = SCTP_ERROR_NO_ERROR;
> +	sctp_addip_param_t *first_asconf_param = NULL;
> +	int first_asconf_paramlen;
>  
>  	/* Skip the chunkhdr and addiphdr from the last asconf sent and store
>  	 * a pointer to address parameter.
> @@ -3307,6 +3454,8 @@ int sctp_process_asconf_ack(struct sctp_association *asoc,
>  	length = ntohs(addr_param->v4.param_hdr.length);
>  	asconf_param = (sctp_addip_param_t *)((void *)addr_param + length);
>  	asconf_len -= length;
> +	first_asconf_param = asconf_param;
> +	first_asconf_paramlen = ntohs(first_asconf_param->param_hdr.length);
>  
>  	/* ADDIP 4.1
>  	 * A8) If there is no response(s) to specific TLV parameter(s), and no
> @@ -3361,6 +3510,34 @@ int sctp_process_asconf_ack(struct sctp_association *asoc,
>  		asconf_len -= length;
>  	}
>  
> +	/* When the source address obviously changes to newly added one, we 
> +	   reset the cwnd to re-probe the path condition
> +	*/
> +	if (no_err && (first_asconf_param->param_hdr.type == SCTP_PARAM_ADD_IP)) {
> +		if (first_asconf_paramlen == SCTP_ASCONF_V4_PARAM_LEN) {
> +			struct sockaddr_in sin;
> +
> +			memset(&sin, 0, sizeof(struct sockaddr_in));
> +			sin.sin_family = AF_INET;
> +			memcpy(&sin.sin_addr.s_addr, first_asconf_param + 1, 
> +					sizeof(struct in_addr));
> +			sctp_path_check_and_react(asoc, 
> +					(struct sockaddr *)&sin);
> +
> +		} else if (first_asconf_paramlen == SCTP_ASCONF_V6_PARAM_LEN) {
> +			struct sockaddr_in6 sin6;
> +
> +			memset(&sin6, 0, sizeof(struct sockaddr_in6));
> +			sin6.sin6_family = AF_INET6;
> +			memcpy(&sin6.sin6_addr, first_asconf_param + 1, 
> +					sizeof(struct in6_addr));
> +			sctp_path_check_and_react(asoc, 
> +					(struct sockaddr *)&sin6);
> +		} else {
> +			SCTP_DEBUG_PRINTK("funny asconf_paramlen? (%d)\n", first_asconf_paramlen);
> +		}
> +	}
> +
>  	/* Free the cached last sent asconf chunk. */
>  	list_del_init(&asconf->transmitted_list);
>  	sctp_chunk_free(asconf);
> diff --git a/net/sctp/socket.c b/net/sctp/socket.c
> index 3951a10..079cdeb 100644
> --- a/net/sctp/socket.c
> +++ b/net/sctp/socket.c
> @@ -527,6 +527,7 @@ static int sctp_send_asconf_add_ip(struct sock		*sk,
>  	struct list_head		*p;
>  	int 				i;
>  	int 				retval = 0;
> +	struct sctp_transport 		*trans = NULL;
>  
>  	if (!sctp_addip_enable)
>  		return retval;
> @@ -583,13 +584,10 @@ static int sctp_send_asconf_add_ip(struct sock		*sk,
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
> +		SCTP_DEBUG_PRINTK("snd_asconf_addip: next, add_bind_addr with ADDR_NEW flag\n");
>  		addr_buf = addrs;
>  		for (i = 0; i < addrcnt; i++) {
>  			addr = (union sctp_addr *)addr_buf;
> @@ -599,6 +597,25 @@ static int sctp_send_asconf_add_ip(struct sock		*sk,
>  						    SCTP_ADDR_NEW, GFP_ATOMIC);
>  			addr_buf += af->sockaddr_len;
>  		}
> +		list_for_each_entry(trans, &asoc->peer.transport_addr_list, transports) {
> +			if (asoc->asconf_addr_del_pending != NULL) 
> +				/* This ADDIP ASCONF piggybacks DELIP for the 
> +				 * last address, so need to select src addr 
> +				 * from the out_of_asoc addrs 
> +				 */
> +				asoc->src_out_of_asoc_ok = 1;
> +			/* Clear the source and route cache in the path */
> +			memset(&trans->saddr, 0, sizeof(union sctp_addr));
> +			dst_release(trans->dst);
> +			trans->cwnd = min(4*asoc->pathmtu, max_t(__u32, 2*asoc->pathmtu, 4380));
> +			trans->ssthresh = asoc->peer.i.a_rwnd;
> +			trans->rto = asoc->rto_initial;
> +			trans->rtt = 0;
> +			trans->srtt = 0;
> +			trans->rttvar = 0;
> +			sctp_transport_route(trans, NULL, sctp_sk(asoc->base.sk));
> +		}
> +		retval = sctp_send_asconf(asoc, chunk);
>  	}
>  
>  out:
> @@ -711,7 +728,9 @@ static int sctp_send_asconf_del_ip(struct sock		*sk,
>  	struct sctp_sockaddr_entry *saddr;
>  	int 			i;
>  	int 			retval = 0;
> +	int			stored = 0;
>  
> +	chunk = NULL;
>  	if (!sctp_addip_enable)
>  		return retval;
>  
> @@ -762,8 +781,35 @@ static int sctp_send_asconf_del_ip(struct sock		*sk,
>  		bp = &asoc->base.bind_addr;
>  		laddr = sctp_find_unmatch_addr(bp, (union sctp_addr *)addrs,
>  					       addrcnt, sp);
> -		if (!laddr)
> -			continue;
> +		if ((laddr == NULL) && (addrcnt == 1)) {
> +			union sctp_addr *sa_addr = NULL;
> +
> +			if (asoc->asconf_addr_del_pending == NULL) {
> +				asoc->asconf_addr_del_pending = kmalloc(sizeof(union sctp_addr), GFP_ATOMIC);
> +				memset(asoc->asconf_addr_del_pending, 0, 
> +						sizeof(union sctp_addr));
> +				if (addrs->sa_family == AF_INET) {
> +					struct sockaddr_in *sin;
> +
> +					sin = (struct sockaddr_in *)addrs;
> +					asoc->asconf_addr_del_pending->v4.sin_family = AF_INET;
> +					memcpy(&asoc->asconf_addr_del_pending->v4.sin_addr, &sin->sin_addr, sizeof(struct in_addr));
> +				} else if (addrs->sa_family == AF_INET6) {
> +					struct sockaddr_in6 *sin6;
> +
> +					sin6 = (struct sockaddr_in6 *)addrs;
> +					asoc->asconf_addr_del_pending->v6.sin6_family = AF_INET6;
> +					memcpy(&asoc->asconf_addr_del_pending->v6.sin6_addr, &sin6->sin6_addr, sizeof(struct in6_addr));
> +				}
> +				sa_addr = (union sctp_addr *)addrs;
> +				SCTP_DEBUG_PRINTK_IPADDR("send_asconf_del_ip: keep the last address asoc: %p "," at %p\n", asoc, sa_addr, asoc->asconf_addr_del_pending);
> +				stored = 1;
> +				goto skip_mkasconf;
> +			} else {
> +				SCTP_DEBUG_PRINTK_IPADDR("send_asconf_del_ip: asoc %p, deleting last address "," is already stored at %p\n", asoc, asoc->asconf_addr_del_pending, asoc->asconf_addr_del_pending);
> +				continue;
> +			}
> +		}
>  
>  		/* We do not need RCU protection throughout this loop
>  		 * because this is done under a socket lock from the
> @@ -776,6 +822,7 @@ static int sctp_send_asconf_del_ip(struct sock		*sk,
>  			goto out;
>  		}
>  
> +skip_mkasconf:
>  		/* Reset use_as_src flag for the addresses in the bind address
>  		 * list that are to be deleted.
>  		 */
> @@ -797,16 +844,217 @@ static int sctp_send_asconf_del_ip(struct sock		*sk,
>  		list_for_each_entry(transport, &asoc->peer.transport_addr_list,
>  					transports) {
>  			dst_release(transport->dst);
> +			/* Clear source address cache */
> +			memset(&transport->saddr, 0, sizeof(union sctp_addr));
>  			sctp_transport_route(transport, NULL,
>  					     sctp_sk(asoc->base.sk));
>  		}
>  
> +		if (stored) {
> +			/* We don't need to transmit ASCONF */
> +			continue;
> +		}
>  		retval = sctp_send_asconf(asoc, chunk);
>  	}
>  out:
>  	return retval;
>  }
>  
> +/* Add a new address to the list contains available addresses only in the 
> + * association.  If the new address is also available on the other associations 
> + * on the endpoint, it is marked as SCTP_ADDR_SRC in the bind address list on 
> + * the endpoint.  This situation is possible when some of associations receive
> + * ASCONF-ACK for ADD_IP at the endpoint
> + */
> +void
> +sctp_add_addr_to_laddr(struct sockaddr *sa, struct sctp_association *asoc)
> +{
> +	struct sctp_endpoint *ep = asoc->ep;
> +	struct sctp_association *tmp = NULL;
> +	struct sctp_bind_addr *bp;
> +	struct sctp_sockaddr_entry *addr;
> +	struct sockaddr_in *sin = NULL;
> +	struct sockaddr_in6 *sin6 = NULL;
> +	int local;
> +	int found;
> +
> +	union sctp_addr *tmpaddr = NULL;
> +	tmpaddr = (union sctp_addr *)sa;
> +	SCTP_DEBUG_PRINTK_IPADDR("add_addr_to_laddr: asoc: %p "," ep: %p", asoc, tmpaddr, ep);
> +	if (sa->sa_family == AF_INET) {
> +		sin = (struct sockaddr_in *)sa;
> +	} else if (sa->sa_family == AF_INET6) {
> +		sin6 = (struct sockaddr_in6 *)sa;
> +	}
> +
> +	/* Check if this address is locally available in the other asocs */
> +	local = 0;
> +	list_for_each_entry(tmp, &ep->asocs, asocs) {
> +		if (tmp == asoc) {
> +			continue;
> +		}
> +		found = 0;
> +		list_for_each_entry(addr, &tmp->asoc_laddr_list, list) {
> +			tmpaddr = &addr->a;
> +			if (sa->sa_family != addr->a.sa.sa_family) {
> +				continue;
> +			}
> +			if (sa->sa_family == AF_INET) {
> +				if (sin->sin_addr.s_addr == addr->a.v4.sin_addr.s_addr) {
> +					found = 1;
> +				}
> +			} else if (sa->sa_family == AF_INET6) {
> +				if (ipv6_addr_equal(&sin6->sin6_addr, &addr->a.v6.sin6_addr)) {
> +					found = 1;
> +
> +				}
> +			}
> +		}
> +		if (!found) {
> +			SCTP_DEBUG_PRINTK("add_addr_to_laddr: not found in asoc %p\n", tmp);
> +			local = 1;
> +			break;
> +		}
> +	}
> +	addr = NULL;
> +
> +	if (local) {
> +		/* this address is not available in some of the other 
> +		 * associations.  So add as locally-available in this 
> +		 * asocciation 
> +		 */
> +		addr = kmalloc(sizeof(struct sctp_sockaddr_entry), GFP_ATOMIC);
> +		if  (addr == NULL) {
> +			SCTP_DEBUG_PRINTK("add_addr_to_laddr: failed to allocate memory for this address\n");
> +			return;
> +		}
> +		memset(addr, 0, sizeof(struct sctp_sockaddr_entry));
> +		if (sa->sa_family == AF_INET) {
> +			addr->a.sa.sa_family = AF_INET;
> +			addr->a.v4.sin_port = sin->sin_port;
> +			addr->a.v4.sin_addr.s_addr = sin->sin_addr.s_addr;
> +		} else if (sa->sa_family == AF_INET6) {
> +			addr->a.sa.sa_family = AF_INET6;
> +			addr->a.v6.sin6_port = sin6->sin6_port;
> +			memcpy(&addr->a.v6.sin6_addr, &sin6->sin6_addr, sizeof(struct in6_addr));
> +		}
> +		list_add_tail(&addr->list, &asoc->asoc_laddr_list);
> +		SCTP_DEBUG_PRINTK("add_addr_to_laddr: now we added this address to the local list on asoc %p\n", asoc);
> +	} else {
> +		/* this address is also available in all other asocs.  So set 
> +		 * it as ADDR_SRC in the bind-addr list in the endpoint, then 
> +		 * remove from the asoc_laddr_list on the associations.  
> +		 */
> +		SCTP_DEBUG_PRINTK("add_addr_to_laddr: this address is available in all other asocs\n");
> +		bp = &asoc->base.bind_addr;
> +
> +		/* change state of the new address in the bind list */
> +		list_for_each_entry(addr, &bp->address_list, list) {
> +			if (addr->state != SCTP_ADDR_NEW) {
> +				continue;
> +			}
> +			if (addr->a.sa.sa_family != sa->sa_family) {
> +				continue;
> +			}
> +			if (addr->a.sa.sa_family == AF_INET) {
> +				if (sin->sin_port != addr->a.v4.sin_port) {
> +					continue;
> +				}
> +				if (sin->sin_addr.s_addr != 
> +				    addr->a.v4.sin_addr.s_addr) {
> +					continue;
> +				}
> +			} else if (addr->a.sa.sa_family == AF_INET6) {
> +				if (sin6->sin6_port != addr->a.v6.sin6_port) {
> +					continue;
> +				}
> +				if (!ipv6_addr_equal(&sin6->sin6_addr, 
> +				    &addr->a.v6.sin6_addr)) {
> +					continue;
> +				}
> +			}
> +			SCTP_DEBUG_PRINTK("add_addr_to_laddr: found the entry for this address with ADDR_NEW flag, set to ADDR_SRC\n");
> +			addr->state = SCTP_ADDR_SRC;
> +		}
> +
> +		/* remove the entry of this address from the asoc-local list */
> +		list_for_each_entry(tmp, &ep->asocs, asocs) {
> +			if (tmp == asoc) {
> +				continue;
> +			}
> +			addr = NULL;
> +			list_for_each_entry(addr, &tmp->asoc_laddr_list, list) {
> +				if (sa->sa_family != addr->a.sa.sa_family) {
> +					continue;
> +				}
> +				if (sa->sa_family == AF_INET) {
> +					if (sin->sin_addr.s_addr != addr->a.v4.sin_addr.s_addr) {
> +						continue;
> +					}
> +				} else if (sa->sa_family == AF_INET6) {
> +					if (!ipv6_addr_equal(&sin6->sin6_addr, \
> +					    &addr->a.v6.sin6_addr)) {
> +						continue;
> +					}
> +				}
> +				break;
> +			}
> +			if (addr == NULL) {
> +				SCTP_DEBUG_PRINTK("add_addr_to_laddr: Huh, asoc %p doesn't have the entry for this address?\n", asoc);
> +				continue;
> +			}
> +			list_del(&addr->list);
> +			kfree(addr);
> +		}
> +	}
> +}
> +
> +/* set addr events to assocs in the endpoint.  ep and addr_wq must be locked */
> +int
> +sctp_asconf_mgmt(struct sctp_endpoint *ep, struct sock *sk)
> +{
> +	struct sctp_addr_wait *addrw = NULL;
> +	union sctp_addr *addr = NULL;
> +	int cmd;
> +	int error = 0;
> +
> +	if (!sctp_auto_asconf_enable) 
> +		return 0;
> +	if ((ep == NULL) || (sk == NULL)) 
> +		return -EINVAL;
> +	if (list_empty(&sctp_addr_waitq)) {
> +		SCTP_DEBUG_PRINTK("asconf_mgmt: nothing in the wq\n");
> +		return -EINVAL;
> +	}
> +	addrw = list_first_entry(&sctp_addr_waitq, struct sctp_addr_wait, list);
> +	if (addrw->cmd != SCTP_NEWADDR && addrw->cmd != SCTP_DELADDR) 
> +		return -EINVAL;
> +	addr = &addrw->a;
> +	cmd = addrw->cmd;
> +
> +	if (addr->sa.sa_family == AF_INET) 
> +		addr->v4.sin_port = htons(ep->base.bind_addr.port);
> +	else if (addr->sa.sa_family == AF_INET6) 
> +		addr->v6.sin6_port = htons(ep->base.bind_addr.port);
> +
> +	SCTP_DEBUG_PRINTK("sctp_asconf_mgmt sk:%p ep:%p\n", sk, ep);
> +	if (cmd == SCTP_NEWADDR) {
> +		error = sctp_send_asconf_add_ip(sk, (struct sockaddr *)addr, 1);
> +		if (error) {
> +			SCTP_DEBUG_PRINTK("asconf_mgmt: send_asconf_add_ip returns %d\n", error);
> +			return error;
> +		}
> +	} else if (cmd == SCTP_DELADDR) {
> +		error = sctp_send_asconf_del_ip(sk, (struct sockaddr *)addr, 1);
> +		if (error) {
> +			SCTP_DEBUG_PRINTK("asconf_mgmt: send_asconf_del_ip returns %d\n", error);
> +			return error;
> +		}
> +	}
> +
> +	return 0;
> +}
> +
>  /* Helper for tunneling sctp_bindx() requests through sctp_setsockopt()
>   *
>   * API 8.1
> @@ -3770,6 +4018,8 @@ SCTP_STATIC int sctp_init_sock(struct sock *sk)
>  	local_bh_disable();
>  	percpu_counter_inc(&sctp_sockets_allocated);
>  	sock_prot_inuse_add(sock_net(sk), sk->sk_prot, 1);
> +	list_add_tail(&ep->base.auto_asconf_list, &sctp_auto_asconf_eplist);
> +	SCTP_DEBUG_PRINTK("sctp_init_sk sk:%p ep:%p\n", sk, ep);
>  	local_bh_enable();
>  
>  	return 0;
> @@ -3784,6 +4034,7 @@ SCTP_STATIC void sctp_destroy_sock(struct sock *sk)
>  
>  	/* Release our hold on the endpoint. */
>  	ep = sctp_sk(sk)->ep;
> +	list_del(&ep->base.auto_asconf_list);
>  	sctp_endpoint_free(ep);
>  	local_bh_disable();
>  	percpu_counter_dec(&sctp_sockets_allocated);
> diff --git a/net/sctp/sysctl.c b/net/sctp/sysctl.c
> index 50cb57f..df39789 100644
> --- a/net/sctp/sysctl.c
> +++ b/net/sctp/sysctl.c
> @@ -183,6 +183,13 @@ static ctl_table sctp_table[] = {
>  		.proc_handler	= proc_dointvec,
>  	},
>  	{
> +		.procname	= "auto_asconf_enable",
> +		.data		= &sctp_auto_asconf_enable,
> +		.maxlen		= sizeof(int),
> +		.mode		= 0644,
> +		.proc_handler	= proc_dointvec,
> +	},
> +	{
>  		.procname	= "prsctp_enable",
>  		.data		= &sctp_prsctp_enable,
>  		.maxlen		= sizeof(int),
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
