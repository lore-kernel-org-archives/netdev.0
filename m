From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH net-next] sctp: clean up sctp_packet_transmit
Date: Tue, 1 Nov 2016 14:01:21 -0400
Message-ID: <20161101180121.GB10666@hmsreliant.think-freely.org>
References: <407056b761e77ecbd43603a17099bb9309a9a8ac.1477932581.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Vlad Yasevich <vyasevich@gmail.com>, davem@davemloft.net
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:60648 "EHLO
        smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751317AbcKASB6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Nov 2016 14:01:58 -0400
Content-Disposition: inline
In-Reply-To: <407056b761e77ecbd43603a17099bb9309a9a8ac.1477932581.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 01, 2016 at 12:49:41AM +0800, Xin Long wrote:
> After adding sctp gso, sctp_packet_transmit is a quite big function now.
> 
> This patch is to extract the codes for packing packet to sctp_packet_pack
> from sctp_packet_transmit, and add some comments, simplify the err path by
> freeing auth chunk when freeing packet chunk_list in out path and freeing
> head skb early if it fails to pack packet.
> 
> Signed-off-by: Xin Long <lucien.xin@gmail.com>
> ---
>  net/sctp/output.c | 435 ++++++++++++++++++++----------------------------------
>  1 file changed, 158 insertions(+), 277 deletions(-)
> 
> diff --git a/net/sctp/output.c b/net/sctp/output.c
> index 7b50e43..f5320a8 100644
> --- a/net/sctp/output.c
> +++ b/net/sctp/output.c
> @@ -399,187 +399,72 @@ static void sctp_packet_set_owner_w(struct sk_buff *skb, struct sock *sk)
>  	atomic_inc(&sk->sk_wmem_alloc);
>  }
>  
> -/* All packets are sent to the network through this function from
> - * sctp_outq_tail().
> - *
> - * The return value is a normal kernel error return value.
> - */
> -int sctp_packet_transmit(struct sctp_packet *packet, gfp_t gfp)
> +static int sctp_packet_pack(struct sctp_packet *packet,
> +			    struct sk_buff *head, int gso, gfp_t gfp)
>  {
>  	struct sctp_transport *tp = packet->transport;
> -	struct sctp_association *asoc = tp->asoc;
> -	struct sctphdr *sh;
> -	struct sk_buff *nskb = NULL, *head = NULL;
> +	struct sctp_auth_chunk *auth = NULL;
>  	struct sctp_chunk *chunk, *tmp;
> -	struct sock *sk;
> -	int err = 0;
> -	int padding;		/* How much padding do we need?  */
> -	int pkt_size;
> -	__u8 has_data = 0;
> -	int gso = 0;
> -	int pktcount = 0;
> +	int pkt_count = 0, pkt_size;
> +	struct sock *sk = head->sk;
> +	struct sk_buff *nskb;
>  	int auth_len = 0;
> -	struct dst_entry *dst;
> -	unsigned char *auth = NULL;	/* pointer to auth in skb data */
> -
> -	pr_debug("%s: packet:%p\n", __func__, packet);
>  
> -	/* Do NOT generate a chunkless packet. */
> -	if (list_empty(&packet->chunk_list))
> -		return err;
> -
> -	/* Set up convenience variables... */
> -	chunk = list_entry(packet->chunk_list.next, struct sctp_chunk, list);
> -	sk = chunk->skb->sk;
> -
> -	/* Allocate the head skb, or main one if not in GSO */
> -	if (packet->size > tp->pathmtu && !packet->ipfragok) {
> -		if (sk_can_gso(sk)) {
> -			gso = 1;
> -			pkt_size = packet->overhead;
> -		} else {
> -			/* If this happens, we trash this packet and try
> -			 * to build a new one, hopefully correct this
> -			 * time. Application may notice this error.
> -			 */
> -			pr_err_once("Trying to GSO but underlying device doesn't support it.");
> -			goto err;
> -		}
> -	} else {
> -		pkt_size = packet->size;
> -	}
> -	head = alloc_skb(pkt_size + MAX_HEADER, gfp);
> -	if (!head)
> -		goto err;
>  	if (gso) {
> -		NAPI_GRO_CB(head)->last = head;
>  		skb_shinfo(head)->gso_type = sk->sk_gso_type;
> +		NAPI_GRO_CB(head)->last = head;
> +	} else {
> +		nskb = head;
> +		pkt_size = packet->size;
> +		goto merge;
>  	}
>  
> -	/* Make sure the outbound skb has enough header room reserved. */
> -	skb_reserve(head, packet->overhead + MAX_HEADER);
> -
> -	/* Set the owning socket so that we know where to get the
> -	 * destination IP address.
> -	 */
> -	sctp_packet_set_owner_w(head, sk);
> -
> -	if (!sctp_transport_dst_check(tp)) {
> -		sctp_transport_route(tp, NULL, sctp_sk(sk));
> -		if (asoc && (asoc->param_flags & SPP_PMTUD_ENABLE)) {
> -			sctp_assoc_sync_pmtu(sk, asoc);
> -		}
> -	}
> -	dst = dst_clone(tp->dst);
> -	if (!dst) {
> -		if (asoc)
> -			IP_INC_STATS(sock_net(asoc->base.sk),
> -				     IPSTATS_MIB_OUTNOROUTES);
> -		goto nodst;
> -	}
> -	skb_dst_set(head, dst);
> -
> -	/* Build the SCTP header.  */
> -	sh = (struct sctphdr *)skb_push(head, sizeof(struct sctphdr));
> -	skb_reset_transport_header(head);
> -	sh->source = htons(packet->source_port);
> -	sh->dest   = htons(packet->destination_port);
> -
> -	/* From 6.8 Adler-32 Checksum Calculation:
> -	 * After the packet is constructed (containing the SCTP common
> -	 * header and one or more control or DATA chunks), the
> -	 * transmitter shall:
> -	 *
> -	 * 1) Fill in the proper Verification Tag in the SCTP common
> -	 *    header and initialize the checksum field to 0's.
> -	 */
> -	sh->vtag     = htonl(packet->vtag);
> -	sh->checksum = 0;
> -
> -	pr_debug("***sctp_transmit_packet***\n");
> -
>  	do {
> -		/* Set up convenience variables... */
> -		chunk = list_entry(packet->chunk_list.next, struct sctp_chunk, list);
> -		pktcount++;
> -
> -		/* Calculate packet size, so it fits in PMTU. Leave
> -		 * other chunks for the next packets.
> -		 */
> -		if (gso) {
> -			pkt_size = packet->overhead;
> -			list_for_each_entry(chunk, &packet->chunk_list, list) {
> -				int padded = SCTP_PAD4(chunk->skb->len);
> -
> -				if (chunk == packet->auth)
> -					auth_len = padded;
> -				else if (auth_len + padded + packet->overhead >
> -					 tp->pathmtu)
> -					goto nomem;
> -				else if (pkt_size + padded > tp->pathmtu)
> -					break;
> -				pkt_size += padded;
> -			}
> -
> -			/* Allocate a new skb. */
> -			nskb = alloc_skb(pkt_size + MAX_HEADER, gfp);
> -			if (!nskb)
> -				goto nomem;
> +		/* calculate the pkt_size and alloc nskb */
> +		pkt_size = packet->overhead;
> +		list_for_each_entry_safe(chunk, tmp, &packet->chunk_list,
> +					 list) {
> +			int padded = SCTP_PAD4(chunk->skb->len);
>  
> -			/* Make sure the outbound skb has enough header
> -			 * room reserved.
> -			 */
> -			skb_reserve(nskb, packet->overhead + MAX_HEADER);
> -		} else {
> -			nskb = head;
> +			if (chunk == packet->auth)
> +				auth_len = padded;
> +			else if (auth_len + padded + packet->overhead >
> +				 tp->pathmtu)
> +				return 0;
> +			else if (pkt_size + padded > tp->pathmtu)
> +				break;
> +			pkt_size += padded;
>  		}
> +		nskb = alloc_skb(pkt_size + MAX_HEADER, gfp);
> +		if (!nskb)
> +			return 0;
> +		skb_reserve(nskb, packet->overhead + MAX_HEADER);
>  
> -		/**
> -		 * 3.2  Chunk Field Descriptions
> -		 *
> -		 * The total length of a chunk (including Type, Length and
> -		 * Value fields) MUST be a multiple of 4 bytes.  If the length
> -		 * of the chunk is not a multiple of 4 bytes, the sender MUST
> -		 * pad the chunk with all zero bytes and this padding is not
> -		 * included in the chunk length field.  The sender should
> -		 * never pad with more than 3 bytes.
> -		 *
> -		 * [This whole comment explains SCTP_PAD4() below.]
> -		 */
> -
> +merge:
> +		/* merge chunks into nskb and append nskb into head list */
>  		pkt_size -= packet->overhead;
>  		list_for_each_entry_safe(chunk, tmp, &packet->chunk_list, list) {
> +			int padding;
> +
>  			list_del_init(&chunk->list);
>  			if (sctp_chunk_is_data(chunk)) {
> -				/* 6.3.1 C4) When data is in flight and when allowed
> -				 * by rule C5, a new RTT measurement MUST be made each
> -				 * round trip.  Furthermore, new RTT measurements
> -				 * SHOULD be made no more than once per round-trip
> -				 * for a given destination transport address.
> -				 */
> -
>  				if (!sctp_chunk_retransmitted(chunk) &&
>  				    !tp->rto_pending) {
>  					chunk->rtt_in_progress = 1;
>  					tp->rto_pending = 1;
>  				}
> -
> -				has_data = 1;
>  			}
>  
>  			padding = SCTP_PAD4(chunk->skb->len) - chunk->skb->len;
>  			if (padding)
>  				memset(skb_put(chunk->skb, padding), 0, padding);
>  
> -			/* if this is the auth chunk that we are adding,
> -			 * store pointer where it will be added and put
> -			 * the auth into the packet.
> -			 */
>  			if (chunk == packet->auth)
> -				auth = skb_tail_pointer(nskb);
> +				auth = (struct sctp_auth_chunk *)
> +							skb_tail_pointer(nskb);
>  
> -			memcpy(skb_put(nskb, chunk->skb->len),
> -			       chunk->skb->data, chunk->skb->len);
> +			memcpy(skb_put(nskb, chunk->skb->len), chunk->skb->data,
> +			       chunk->skb->len);
>  
>  			pr_debug("*** Chunk:%p[%s] %s 0x%x, length:%d, chunk->skb->len:%d, rtt_in_progress:%d\n",
>  				 chunk,
> @@ -589,11 +474,6 @@ int sctp_packet_transmit(struct sctp_packet *packet, gfp_t gfp)
>  				 ntohs(chunk->chunk_hdr->length), chunk->skb->len,
>  				 chunk->rtt_in_progress);
>  
> -			/* If this is a control chunk, this is our last
> -			 * reference. Free data chunks after they've been
> -			 * acknowledged or have failed.
> -			 * Re-queue auth chunks if needed.
> -			 */
>  			pkt_size -= SCTP_PAD4(chunk->skb->len);
>  
>  			if (!sctp_chunk_is_data(chunk) && chunk != packet->auth)
> @@ -603,160 +483,161 @@ int sctp_packet_transmit(struct sctp_packet *packet, gfp_t gfp)
>  				break;
>  		}
>  
> -		/* SCTP-AUTH, Section 6.2
> -		 *    The sender MUST calculate the MAC as described in RFC2104 [2]
> -		 *    using the hash function H as described by the MAC Identifier and
> -		 *    the shared association key K based on the endpoint pair shared key
> -		 *    described by the shared key identifier.  The 'data' used for the
> -		 *    computation of the AUTH-chunk is given by the AUTH chunk with its
> -		 *    HMAC field set to zero (as shown in Figure 6) followed by all
> -		 *    chunks that are placed after the AUTH chunk in the SCTP packet.
> -		 */
> -		if (auth)
> -			sctp_auth_calculate_hmac(asoc, nskb,
> -						 (struct sctp_auth_chunk *)auth,
> -						 gfp);
> -
> -		if (packet->auth) {
> -			if (!list_empty(&packet->chunk_list)) {
> -				/* We will generate more packets, so re-queue
> -				 * auth chunk.
> -				 */
> +		if (auth) {
> +			sctp_auth_calculate_hmac(tp->asoc, nskb, auth, gfp);
> +			/* free auth if no more chunks, or add it back */
> +			if (list_empty(&packet->chunk_list))
> +				sctp_chunk_free(packet->auth);
> +			else
>  				list_add(&packet->auth->list,
>  					 &packet->chunk_list);
> -			} else {
> -				sctp_chunk_free(packet->auth);
> -				packet->auth = NULL;
> -			}
>  		}
>  
> -		if (!gso)
> -			break;
> -
> -		if (skb_gro_receive(&head, nskb)) {
> -			kfree_skb(nskb);
> -			goto nomem;
> +		if (gso) {
> +			if (skb_gro_receive(&head, nskb)) {
> +				kfree_skb(nskb);
> +				return 0;
> +			}
> +			if (WARN_ON_ONCE(skb_shinfo(head)->gso_segs >=
> +					 sk->sk_gso_max_segs))
> +				return 0;
>  		}
> -		nskb = NULL;
> -		if (WARN_ON_ONCE(skb_shinfo(head)->gso_segs >=
> -				 sk->sk_gso_max_segs))
> -			goto nomem;
> +
> +		pkt_count++;
>  	} while (!list_empty(&packet->chunk_list));
>  
> -	/* 2) Calculate the Adler-32 checksum of the whole packet,
> -	 *    including the SCTP common header and all the
> -	 *    chunks.
> -	 *
> -	 * Note: Adler-32 is no longer applicable, as has been replaced
> -	 * by CRC32-C as described in <draft-ietf-tsvwg-sctpcsum-02.txt>.
> -	 *
> -	 * If it's a GSO packet, it's postponed to sctp_skb_segment.
> -	 */
> -	if (!sctp_checksum_disable || gso) {
> -		if (!gso && (!(dst->dev->features & NETIF_F_SCTP_CRC) ||
> -			     dst_xfrm(dst) || packet->ipfragok)) {
> -			sh->checksum = sctp_compute_cksum(head, 0);
> -		} else {
> -			/* no need to seed pseudo checksum for SCTP */
> -			head->ip_summed = CHECKSUM_PARTIAL;
> -			head->csum_start = skb_transport_header(head) - head->head;
> -			head->csum_offset = offsetof(struct sctphdr, checksum);
> +	if (gso) {
> +		memset(head->cb, 0, max(sizeof(struct inet_skb_parm),
> +					sizeof(struct inet6_skb_parm)));
> +		skb_shinfo(head)->gso_segs = pkt_count;
> +		skb_shinfo(head)->gso_size = GSO_BY_FRAGS;
> +		rcu_read_lock();
> +		if (skb_dst(head) != tp->dst) {
> +			dst_hold(tp->dst);
> +			sk_setup_caps(sk, tp->dst);
>  		}
> +		rcu_read_unlock();
> +		goto chksum;
>  	}
>  
> -	/* IP layer ECN support
> -	 * From RFC 2481
> -	 *  "The ECN-Capable Transport (ECT) bit would be set by the
> -	 *   data sender to indicate that the end-points of the
> -	 *   transport protocol are ECN-capable."
> -	 *
> -	 * Now setting the ECT bit all the time, as it should not cause
> -	 * any problems protocol-wise even if our peer ignores it.
> -	 *
> -	 * Note: The works for IPv6 layer checks this bit too later
> -	 * in transmission.  See IP6_ECN_flow_xmit().
> -	 */
> -	tp->af_specific->ecn_capable(sk);
> +	if (sctp_checksum_disable)
> +		return 1;
>  
> -	/* Set up the IP options.  */
> -	/* BUG: not implemented
> -	 * For v4 this all lives somewhere in sk->sk_opt...
> -	 */
> +	if (!(skb_dst(head)->dev->features & NETIF_F_SCTP_CRC) ||
> +	    dst_xfrm(skb_dst(head)) || packet->ipfragok) {
> +		struct sctphdr *sh =
> +			(struct sctphdr *)skb_transport_header(head);
>  
> -	/* Dump that on IP!  */
> -	if (asoc) {
> -		asoc->stats.opackets += pktcount;
> -		if (asoc->peer.last_sent_to != tp)
> -			/* Considering the multiple CPU scenario, this is a
> -			 * "correcter" place for last_sent_to.  --xguo
> -			 */
> -			asoc->peer.last_sent_to = tp;
> +		sh->checksum = sctp_compute_cksum(head, 0);
> +	} else {
> +chksum:
> +		head->ip_summed = CHECKSUM_PARTIAL;
> +		head->csum_start = skb_transport_header(head) - head->head;
> +		head->csum_offset = offsetof(struct sctphdr, checksum);
>  	}
>  
> -	if (has_data) {
> -		struct timer_list *timer;
> -		unsigned long timeout;
> +	return pkt_count;
> +}
> +
> +/* All packets are sent to the network through this function from
> + * sctp_outq_tail().
> + *
> + * The return value is always 0 for now.
> + */
> +int sctp_packet_transmit(struct sctp_packet *packet, gfp_t gfp)
> +{
> +	struct sctp_transport *tp = packet->transport;
> +	struct sctp_association *asoc = tp->asoc;
> +	struct sctp_chunk *chunk, *tmp;
> +	int pkt_count, gso = 0;
> +	struct dst_entry *dst;
> +	struct sk_buff *head;
> +	struct sctphdr *sh;
> +	struct sock *sk;
>  
> -		/* Restart the AUTOCLOSE timer when sending data. */
> -		if (sctp_state(asoc, ESTABLISHED) &&
> -		    asoc->timeouts[SCTP_EVENT_TIMEOUT_AUTOCLOSE]) {
> -			timer = &asoc->timers[SCTP_EVENT_TIMEOUT_AUTOCLOSE];
> -			timeout = asoc->timeouts[SCTP_EVENT_TIMEOUT_AUTOCLOSE];
> +	pr_debug("%s: packet:%p\n", __func__, packet);
> +	if (list_empty(&packet->chunk_list))
> +		return 0;
> +	chunk = list_entry(packet->chunk_list.next, struct sctp_chunk, list);
> +	sk = chunk->skb->sk;
>  
> -			if (!mod_timer(timer, jiffies + timeout))
> -				sctp_association_hold(asoc);
> +	/* check gso */
> +	if (packet->size > tp->pathmtu && !packet->ipfragok) {
> +		if (!sk_can_gso(sk)) {
> +			pr_err_once("Trying to GSO but underlying device doesn't support it.");
> +			goto out;
>  		}
> +		gso = 1;
> +	}
> +
> +	/* alloc head skb */
> +	head = alloc_skb((gso ? packet->overhead : packet->size) +
> +			 MAX_HEADER, gfp);
> +	if (!head)
> +		goto out;
> +	skb_reserve(head, packet->overhead + MAX_HEADER);
> +	sctp_packet_set_owner_w(head, sk);
> +
> +	/* set sctp header */
> +	sh = (struct sctphdr *)skb_push(head, sizeof(struct sctphdr));
> +	skb_reset_transport_header(head);
> +	sh->source = htons(packet->source_port);
> +	sh->dest = htons(packet->destination_port);
> +	sh->vtag = htonl(packet->vtag);
> +	sh->checksum = 0;
> +
> +	/* update dst if in need */
> +	if (!sctp_transport_dst_check(tp)) {
> +		sctp_transport_route(tp, NULL, sctp_sk(sk));
> +		if (asoc && asoc->param_flags & SPP_PMTUD_ENABLE)
> +			sctp_assoc_sync_pmtu(sk, asoc);
>  	}
> +	dst = dst_clone(tp->dst);
> +	if (!dst) {
> +		IP_INC_STATS(sock_net(sk), IPSTATS_MIB_OUTNOROUTES);
> +		kfree_skb(head);
> +		goto out;
> +	}
> +	skb_dst_set(head, dst);
>  
> +	/* pack up chunks */
> +	pkt_count = sctp_packet_pack(packet, head, gso, gfp);
> +	if (!pkt_count) {
> +		kfree_skb(head);
> +		goto out;
> +	}
>  	pr_debug("***sctp_transmit_packet*** skb->len:%d\n", head->len);
>  
> -	if (gso) {
> -		/* Cleanup our debris for IP stacks */
> -		memset(head->cb, 0, max(sizeof(struct inet_skb_parm),
> -					sizeof(struct inet6_skb_parm)));
> +	/* start autoclose timer */
> +	if (packet->has_data && sctp_state(asoc, ESTABLISHED) &&
> +	    asoc->timeouts[SCTP_EVENT_TIMEOUT_AUTOCLOSE]) {
> +		struct timer_list *timer =
> +			&asoc->timers[SCTP_EVENT_TIMEOUT_AUTOCLOSE];
> +		unsigned long timeout =
> +			asoc->timeouts[SCTP_EVENT_TIMEOUT_AUTOCLOSE];
>  
> -		skb_shinfo(head)->gso_segs = pktcount;
> -		skb_shinfo(head)->gso_size = GSO_BY_FRAGS;
> +		if (!mod_timer(timer, jiffies + timeout))
> +			sctp_association_hold(asoc);
> +	}
>  
> -		/* We have to refresh this in case we are xmiting to
> -		 * more than one transport at a time
> -		 */
> -		rcu_read_lock();
> -		if (__sk_dst_get(sk) != tp->dst) {
> -			dst_hold(tp->dst);
> -			sk_setup_caps(sk, tp->dst);
> -		}
> -		rcu_read_unlock();
> +	/* sctp xmit */
> +	tp->af_specific->ecn_capable(sk);
> +	if (asoc) {
> +		asoc->stats.opackets += pkt_count;
> +		if (asoc->peer.last_sent_to != tp)
> +			asoc->peer.last_sent_to = tp;
>  	}
>  	head->ignore_df = packet->ipfragok;
>  	tp->af_specific->sctp_xmit(head, tp);
> -	goto out;
> -
> -nomem:
> -	if (packet->auth && list_empty(&packet->auth->list))
> -		sctp_chunk_free(packet->auth);
> -
> -nodst:
> -	/* FIXME: Returning the 'err' will effect all the associations
> -	 * associated with a socket, although only one of the paths of the
> -	 * association is unreachable.
> -	 * The real failure of a transport or association can be passed on
> -	 * to the user via notifications. So setting this error may not be
> -	 * required.
> -	 */
> -	 /* err = -EHOSTUNREACH; */
> -	kfree_skb(head);
>  
> -err:
> +out:
>  	list_for_each_entry_safe(chunk, tmp, &packet->chunk_list, list) {
>  		list_del_init(&chunk->list);
>  		if (!sctp_chunk_is_data(chunk))
>  			sctp_chunk_free(chunk);
>  	}
> -
> -out:
>  	sctp_packet_reset(packet);
> -	return err;
> +	return 0;
>  }
>  
>  /********************************************************************
> -- 
> 2.1.0
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
Acked-by: Neil Horman <nhorman@tuxdriver.com>
 
