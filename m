From: Michele Baldessari <michele@acksyn.org>
Subject: Re: [PATCH v2 net-next] sctp: Add support to per-association
 statistics via a new SCTP_GET_ASSOC_STATS call
Date: Tue, 27 Nov 2012 23:08:10 +0100
Message-ID: <20121127220810.GB3869@fante.int.rhx>
References: <1352991680-12289-1-git-send-email-michele@acksyn.org>
 <50AA57EA.4000907@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-sctp@vger.kernel.org, Neil Horman <nhorman@tuxdriver.com>,
	Thomas Graf <tgraf@suug.ch>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Vlad Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palahniuk.acksyn.org ([5.9.7.26]:49619 "EHLO
	palahniuk.acksyn.org" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752728Ab2K0WId (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Nov 2012 17:08:33 -0500
Content-Disposition: inline
In-Reply-To: <50AA57EA.4000907@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Vlad,

thanks a lot for your review.

On Mon, Nov 19, 2012 at 11:01:46AM -0500, Vlad Yasevich wrote:
<snip>
> >@@ -1152,8 +1156,11 @@ static void sctp_assoc_bh_rcv(struct work_struct *work)
> >  		 */
> >  		if (sctp_chunk_is_data(chunk))
> >  			asoc->peer.last_data_from = chunk->transport;
> >-		else
> >+		else {
> >  			SCTP_INC_STATS(net, SCTP_MIB_INCTRLCHUNKS);
> >+			if (chunk->chunk_hdr->type == SCTP_CID_SACK)
> >+				asoc->stats.isacks++;
> >+		}
> 
> Should the above include asoc->stats.ictrlchunks++; just like ep_bh_rcv()?

Indeed, I will add that.

> >
> >  		if (chunk->transport)
> >  			chunk->transport->last_time_heard = jiffies;
> >diff --git a/net/sctp/endpointola.c b/net/sctp/endpointola.c
> >index 1859e2b..32ab55b 100644
> >--- a/net/sctp/endpointola.c
> >+++ b/net/sctp/endpointola.c
> >@@ -480,8 +480,11 @@ normal:
> >  		 */
> >  		if (asoc && sctp_chunk_is_data(chunk))
> >  			asoc->peer.last_data_from = chunk->transport;
> >-		else
> >+		else {
> >  			SCTP_INC_STATS(sock_net(ep->base.sk), SCTP_MIB_INCTRLCHUNKS);
> >+			if (asoc)
> >+				asoc->stats.ictrlchunks++;
> >+		}
> >
> >  		if (chunk->transport)
> >  			chunk->transport->last_time_heard = jiffies;
> >diff --git a/net/sctp/input.c b/net/sctp/input.c
> >index 8bd3c27..54c449b 100644
> >--- a/net/sctp/input.c
> >+++ b/net/sctp/input.c
> >@@ -281,6 +281,8 @@ int sctp_rcv(struct sk_buff *skb)
> >  		SCTP_INC_STATS_BH(net, SCTP_MIB_IN_PKT_SOFTIRQ);
> >  		sctp_inq_push(&chunk->rcvr->inqueue, chunk);
> >  	}
> >+	if (asoc)
> >+		asoc->stats.ipackets++;
> >
> >  	sctp_bh_unlock_sock(sk);
> 
> This needs a bit more thought.  Current counting behaves differently
> depending on whether the user holds a socket lock or not.
> If the user holds the lock, we'll end counting the packet before it is
> processed.  If the user isn't holding the lock, we'll count the packet after
> it is processed.

I see. What do you prefer: use atomic64 for this specific counter or
since it is a temporary miscount we go ahead and ignore it or do you
have other approaches in mind?

> >
> >diff --git a/net/sctp/output.c b/net/sctp/output.c
> >index 4e90188bf..f5200a2 100644
> >--- a/net/sctp/output.c
> >+++ b/net/sctp/output.c
> >@@ -311,6 +311,8 @@ static sctp_xmit_t __sctp_packet_append_chunk(struct sctp_packet *packet,
> >
> >  	    case SCTP_CID_SACK:
> >  		packet->has_sack = 1;
> >+		if (chunk->asoc)
> >+			chunk->asoc->stats.osacks++;
> >  		break;
> >
> >  	    case SCTP_CID_AUTH:
> >@@ -584,11 +586,13 @@ int sctp_packet_transmit(struct sctp_packet *packet)
> >  	 */
> >
> >  	/* Dump that on IP!  */
> >-	if (asoc && asoc->peer.last_sent_to != tp) {
> >-		/* Considering the multiple CPU scenario, this is a
> >-		 * "correcter" place for last_sent_to.  --xguo
> >-		 */
> >-		asoc->peer.last_sent_to = tp;
> >+	if (asoc) {
> >+		asoc->stats.opackets++;
> >+		if (asoc->peer.last_sent_to != tp)
> >+			/* Considering the multiple CPU scenario, this is a
> >+			 * "correcter" place for last_sent_to.  --xguo
> >+			 */
> >+			asoc->peer.last_sent_to = tp;
> >  	}
> >
> >  	if (has_data) {
> >diff --git a/net/sctp/outqueue.c b/net/sctp/outqueue.c
> >index 1b4a7f8..379c81d 100644
> >--- a/net/sctp/outqueue.c
> >+++ b/net/sctp/outqueue.c
> >@@ -667,6 +667,7 @@ redo:
> >  				chunk->fast_retransmit = SCTP_DONT_FRTX;
> >
> >  			q->empty = 0;
> >+			q->asoc->stats.rtxchunks++;
> >  			break;
> >  		}
> >
> >@@ -876,12 +877,14 @@ static int sctp_outq_flush(struct sctp_outq *q, int rtx_timeout)
> >  			if (status  != SCTP_XMIT_OK) {
> >  				/* put the chunk back */
> >  				list_add(&chunk->list, &q->control_chunk_list);
> >-			} else if (chunk->chunk_hdr->type == SCTP_CID_FWD_TSN) {
> >+			} else {
> >+				asoc->stats.octrlchunks++;
> >  				/* PR-SCTP C5) If a FORWARD TSN is sent, the
> >  				 * sender MUST assure that at least one T3-rtx
> >  				 * timer is running.
> >  				 */
> >-				sctp_transport_reset_timers(transport);
> >+				if (chunk->chunk_hdr->type == SCTP_CID_FWD_TSN)
> >+					sctp_transport_reset_timers(transport);
> >  			}
> >  			break;
> >
> >@@ -1055,6 +1058,10 @@ static int sctp_outq_flush(struct sctp_outq *q, int rtx_timeout)
> >  				 */
> >  				if (asoc->state == SCTP_STATE_SHUTDOWN_PENDING)
> >  					chunk->chunk_hdr->flags |= SCTP_DATA_SACK_IMM;
> >+				if (chunk->chunk_hdr->flags & SCTP_DATA_UNORDERED)
> >+					asoc->stats.ouodchunks++;
> >+				else
> >+					asoc->stats.oodchunks++;
> >
> >  				break;
> >
> >@@ -1162,6 +1169,7 @@ int sctp_outq_sack(struct sctp_outq *q, struct sctp_chunk *chunk)
> >
> >  	sack_ctsn = ntohl(sack->cum_tsn_ack);
> >  	gap_ack_blocks = ntohs(sack->num_gap_ack_blocks);
> >+	asoc->stats.gapcnt += gap_ack_blocks;
> >  	/*
> >  	 * SFR-CACC algorithm:
> >  	 * On receipt of a SACK the sender SHOULD execute the
> >diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
> >index fbe1636..eb7633f 100644
> >--- a/net/sctp/sm_make_chunk.c
> >+++ b/net/sctp/sm_make_chunk.c
> >@@ -804,10 +804,11 @@ struct sctp_chunk *sctp_make_sack(const struct sctp_association *asoc)
> >  				 gabs);
> >
> >  	/* Add the duplicate TSN information.  */
> >-	if (num_dup_tsns)
> >+	if (num_dup_tsns) {
> >+		aptr->stats.idupchunks += num_dup_tsns;
> >  		sctp_addto_chunk(retval, sizeof(__u32) * num_dup_tsns,
> >  				 sctp_tsnmap_get_dups(map));
> >-
> >+	}
> >  	/* Once we have a sack generated, check to see what our sack
> >  	 * generation is, if its 0, reset the transports to 0, and reset
> >  	 * the association generation to 1
> >diff --git a/net/sctp/sm_sideeffect.c b/net/sctp/sm_sideeffect.c
> >index 6eecf7e..363727e 100644
> >--- a/net/sctp/sm_sideeffect.c
> >+++ b/net/sctp/sm_sideeffect.c
> >@@ -542,6 +542,7 @@ static void sctp_do_8_2_transport_strike(sctp_cmd_seq_t *commands,
> >  	 */
> >  	if (!is_hb || transport->hb_sent) {
> >  		transport->rto = min((transport->rto * 2), transport->asoc->rto_max);
> >+		sctp_max_rto(asoc, transport);
> >  	}
> >  }
> >
> >diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
> >index b6adef8..ecf7a17 100644
> >--- a/net/sctp/sm_statefuns.c
> >+++ b/net/sctp/sm_statefuns.c
> >@@ -6127,6 +6127,8 @@ static int sctp_eat_data(const struct sctp_association *asoc,
> >  		/* The TSN is too high--silently discard the chunk and
> >  		 * count on it getting retransmitted later.
> >  		 */
> >+		if (chunk->asoc)
> >+			chunk->asoc->stats.outofseqtsns++;
> >  		return SCTP_IERROR_HIGH_TSN;
> >  	} else if (tmp > 0) {
> >  		/* This is a duplicate.  Record it.  */
> >@@ -6226,10 +6228,14 @@ static int sctp_eat_data(const struct sctp_association *asoc,
> >  	/* Note: Some chunks may get overcounted (if we drop) or overcounted
> >  	 * if we renege and the chunk arrives again.
> >  	 */
> >-	if (chunk->chunk_hdr->flags & SCTP_DATA_UNORDERED)
> >+	if (chunk->chunk_hdr->flags & SCTP_DATA_UNORDERED) {
> >  		SCTP_INC_STATS(net, SCTP_MIB_INUNORDERCHUNKS);
> >-	else {
> >+		if (chunk->asoc)
> >+			chunk->asoc->stats.iuodchunks++;
> >+	} else {
> >  		SCTP_INC_STATS(net, SCTP_MIB_INORDERCHUNKS);
> >+		if (chunk->asoc)
> >+			chunk->asoc->stats.iodchunks++;
> >  		ordered = 1;
> >  	}
> >
> >diff --git a/net/sctp/socket.c b/net/sctp/socket.c
> >index 15379ac..8113249 100644
> >--- a/net/sctp/socket.c
> >+++ b/net/sctp/socket.c
> >@@ -609,6 +609,7 @@ static int sctp_send_asconf_add_ip(struct sock		*sk,
> >  				    2*asoc->pathmtu, 4380));
> >  				trans->ssthresh = asoc->peer.i.a_rwnd;
> >  				trans->rto = asoc->rto_initial;
> >+				sctp_max_rto(asoc, trans);
> >  				trans->rtt = trans->srtt = trans->rttvar = 0;
> >  				sctp_transport_route(trans, NULL,
> >  				    sctp_sk(asoc->base.sk));
> >@@ -5633,6 +5634,74 @@ static int sctp_getsockopt_paddr_thresholds(struct sock *sk,
> >  	return 0;
> >  }
> >
> >+/*
> >+ * SCTP_GET_ASSOC_STATS
> >+ *
> >+ * This option retrieves local per endpoint statistics. It is modeled
> >+ * after OpenSolaris' implementation
> >+ */
> >+static int sctp_getsockopt_assoc_stats(struct sock *sk, int len,
> >+				       char __user *optval,
> >+				       int __user *optlen)
> >+{
> >+	struct sctp_assoc_stats sas;
> >+	struct sctp_association *asoc = NULL;
> >+
> >+	/* User must provide at least the assoc id */
> >+	if (len < sizeof(sctp_assoc_t))
> >+		return -EINVAL;
> >+
> >+	if (copy_from_user(&sas, optval, len))
> >+		return -EFAULT;
> >+
> >+	asoc = sctp_id2assoc(sk, sas.sas_assoc_id);
> >+	if (!asoc)
> >+		return -EINVAL;
> >+
> >+	sas.sas_rtxchunks = asoc->stats.rtxchunks;
> >+	sas.sas_gapcnt = asoc->stats.gapcnt;
> >+	sas.sas_outofseqtsns = asoc->stats.outofseqtsns;
> >+	sas.sas_osacks = asoc->stats.osacks;
> >+	sas.sas_isacks = asoc->stats.isacks;
> >+	sas.sas_octrlchunks = asoc->stats.octrlchunks;
> >+	sas.sas_ictrlchunks = asoc->stats.ictrlchunks;
> >+	sas.sas_oodchunks = asoc->stats.oodchunks;
> >+	sas.sas_iodchunks = asoc->stats.iodchunks;
> >+	sas.sas_ouodchunks = asoc->stats.ouodchunks;
> >+	sas.sas_iuodchunks = asoc->stats.iuodchunks;
> >+	sas.sas_idupchunks = asoc->stats.idupchunks;
> >+	sas.sas_opackets = asoc->stats.opackets;
> >+	sas.sas_ipackets = asoc->stats.ipackets;
> >+
> >+	memcpy(&sas.sas_obs_rto_ipaddr, &asoc->stats.obs_rto_ipaddr,
> >+		sizeof(struct sockaddr_storage));
> >+	/* New high max rto observed */
> >+	if (asoc->stats.max_obs_rto > asoc->stats.max_prev_obs_rto)
> >+		sas.sas_maxrto = asoc->stats.max_obs_rto;
> >+	else /* return min_rto since max rto has not changed */
> >+		sas.sas_maxrto = asoc->rto_min;
> >+
> >+	/* Record the value sent to the user this period */
> >+	asoc->stats.max_prev_obs_rto = sas.sas_maxrto;
> >+
> >+	/* Mark beginning of a new observation period */
> >+	asoc->stats.max_obs_rto = 0;
> 
> I don't think the logic above behaves correctly.  The fact that max_obs_rto
> < max_prev_obs_rto doesn't not mean that max_obs_rto has
> not changed.  It just means that the networks had smaller latency this this
> time slice then it had in the privouse one.  Returning rto_min is
> mis-information in this case.

Ack. I will look into fixing this as well.

Thanks again and regards,
Michele

> 
> -vlad
> 
> >+
> >+	/* Allow the struct to grow and fill in as much as possible */
> >+	len = min_t(size_t, len, sizeof(sas));
> >+
> >+	if (put_user(len, optlen))
> >+		return -EFAULT;
> >+
> >+	SCTP_DEBUG_PRINTK("sctp_getsockopt_assoc_stat(%d): %d\n",
> >+			  len, sas.sas_assoc_id);
> >+
> >+	if (copy_to_user(optval, &sas, len))
> >+		return -EFAULT;
> >+
> >+	return 0;
> >+}
> >+
> >  SCTP_STATIC int sctp_getsockopt(struct sock *sk, int level, int optname,
> >  				char __user *optval, int __user *optlen)
> >  {
> >@@ -5774,6 +5843,9 @@ SCTP_STATIC int sctp_getsockopt(struct sock *sk, int level, int optname,
> >  	case SCTP_PEER_ADDR_THLDS:
> >  		retval = sctp_getsockopt_paddr_thresholds(sk, optval, len, optlen);
> >  		break;
> >+	case SCTP_GET_ASSOC_STATS:
> >+		retval = sctp_getsockopt_assoc_stats(sk, len, optval, optlen);
> >+		break;
> >  	default:
> >  		retval = -ENOPROTOOPT;
> >  		break;
> >diff --git a/net/sctp/transport.c b/net/sctp/transport.c
> >index 953c21e..8c6920d 100644
> >--- a/net/sctp/transport.c
> >+++ b/net/sctp/transport.c
> >@@ -350,6 +350,7 @@ void sctp_transport_update_rto(struct sctp_transport *tp, __u32 rtt)
> >
> >  	/* 6.3.1 C3) After the computation, update RTO <- SRTT + 4 * RTTVAR. */
> >  	tp->rto = tp->srtt + (tp->rttvar << 2);
> >+	sctp_max_rto(tp->asoc, tp);
> >
> >  	/* 6.3.1 C6) Whenever RTO is computed, if it is less than RTO.Min
> >  	 * seconds then it is rounded up to RTO.Min seconds.
> >@@ -620,6 +621,7 @@ void sctp_transport_reset(struct sctp_transport *t)
> >  	t->burst_limited = 0;
> >  	t->ssthresh = asoc->peer.i.a_rwnd;
> >  	t->rto = asoc->rto_initial;
> >+	sctp_max_rto(asoc, t);
> >  	t->rtt = 0;
> >  	t->srtt = 0;
> >  	t->rttvar = 0;
> >
> 

-- 
Michele Baldessari            <michele@acksyn.org>
C2A5 9DA3 9961 4FFB E01B  D0BC DDD4 DCCB 7515 5C6D
