From: Michele Baldessari <michele@acksyn.org>
Subject: [PATCH v4 net-next] sctp: Add support to per-association statistics via a new SCTP_GET_ASSOC_STATS call
Date: Sat,  1 Dec 2012 15:49:42 +0100
Message-ID: <1354373382-15230-1-git-send-email-michele@acksyn.org>
Cc: michele@acksyn.org, Neil Horman <nhorman@tuxdriver.com>,
	Thomas Graf <tgraf@suug.ch>,
	Vlad Yasevich <vyasevich@gmail.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from palahniuk.acksyn.org ([5.9.7.26]:38661 "EHLO
	palahniuk.acksyn.org" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751812Ab2LAOuI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Dec 2012 09:50:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The current SCTP stack is lacking a mechanism to have per association
statistics. This is an implementation modeled after OpenSolaris'
SCTP_GET_ASSOC_STATS.

Userspace part will follow on lksctp if/when there is a general ACK on
this.
V4:
- Move ipackets++ before q->immediate.func() for consistency reasons
- Move sctp_max_rto() at the end of sctp_transport_update_rto() to avoid
  returning bogus RTO values
- return asoc->rto_min when max_obs_rto value has not changed

V3:
- Increase ictrlchunks in sctp_assoc_bh_rcv() as well
- Move ipackets++ to sctp_inq_push()
- return 0 when no rto updates took place since the last call

V2:
- Implement partial retrieval of stat struct to cope for future expansion
- Kill the rtxpackets counter as it cannot be precise anyway
- Rename outseqtsns to outofseqtsns to make it clearer that these are out
  of sequence unexpected TSNs
- Move asoc->ipackets++ under a lock to avoid potential miscounts
- Fold asoc->opackets++ into the already existing asoc check
- Kill unneeded (q->asoc) test when increasing rtxchunks
- Do not count octrlchunks if sending failed (SCTP_XMIT_OK != 0)
- Don't count SHUTDOWNs as SACKs
- Move SCTP_GET_ASSOC_STATS to the private space API
- Adjust the len check in sctp_getsockopt_assoc_stats() to allow for
  future struct growth
- Move association statistics in their own struct
- Update idupchunks when we send a SACK with dup TSNs
- return min_rto in max_rto when RTO has not changed. Also return the
  transport when max_rto last changed.

Signed-off: Michele Baldessari <michele@acksyn.org>
---
 include/net/sctp/sctp.h    | 12 ++++++++
 include/net/sctp/structs.h | 36 ++++++++++++++++++++++++
 include/net/sctp/user.h    | 27 ++++++++++++++++++
 net/sctp/associola.c       | 10 ++++++-
 net/sctp/endpointola.c     |  5 +++-
 net/sctp/inqueue.c         |  2 ++
 net/sctp/output.c          | 14 ++++++----
 net/sctp/outqueue.c        | 12 ++++++--
 net/sctp/sm_make_chunk.c   |  5 ++--
 net/sctp/sm_sideeffect.c   |  1 +
 net/sctp/sm_statefuns.c    | 10 +++++--
 net/sctp/socket.c          | 69 ++++++++++++++++++++++++++++++++++++++++++++++
 net/sctp/transport.c       |  2 ++
 13 files changed, 192 insertions(+), 13 deletions(-)

diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
index 9c6414f..7fdf298 100644
--- a/include/net/sctp/sctp.h
+++ b/include/net/sctp/sctp.h
@@ -272,6 +272,18 @@ struct sctp_mib {
         unsigned long   mibs[SCTP_MIB_MAX];
 };
 
+/* helper function to track stats about max rto and related transport */
+static inline void sctp_max_rto(struct sctp_association *asoc,
+				struct sctp_transport *trans)
+{
+	if (asoc->stats.max_obs_rto < (__u64)trans->rto) {
+		asoc->stats.max_obs_rto = trans->rto;
+		memset(&asoc->stats.obs_rto_ipaddr, 0,
+			sizeof(struct sockaddr_storage));
+		memcpy(&asoc->stats.obs_rto_ipaddr, &trans->ipaddr,
+			trans->af_specific->sockaddr_len);
+	}
+}
 
 /* Print debugging messages.  */
 #if SCTP_DEBUG
diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index 2b2f61d..c252101 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -1312,6 +1312,40 @@ struct sctp_inithdr_host {
 	__u32 initial_tsn;
 };
 
+/* SCTP_GET_ASSOC_STATS counters */
+struct sctp_priv_assoc_stats {
+	/* Maximum observed rto in the association during subsequent
+	 * observations. Value is set to 0 if no RTO measurement took place
+	 * The transport where the max_rto was observed is returned in
+	 * obs_rto_ipaddr
+	 */
+	struct sockaddr_storage obs_rto_ipaddr;
+	__u64 max_obs_rto;
+	/* Total In and Out SACKs received and sent */
+	__u64 isacks;
+	__u64 osacks;
+	/* Total In and Out packets received and sent */
+	__u64 opackets;
+	__u64 ipackets;
+	/* Total retransmitted chunks */
+	__u64 rtxchunks;
+	/* TSN received > next expected */
+	__u64 outofseqtsns;
+	/* Duplicate Chunks received */
+	__u64 idupchunks;
+	/* Gap Ack Blocks received */
+	__u64 gapcnt;
+	/* Unordered data chunks sent and received */
+	__u64 ouodchunks;
+	__u64 iuodchunks;
+	/* Ordered data chunks sent and received */
+	__u64 oodchunks;
+	__u64 iodchunks;
+	/* Control chunks sent and received */
+	__u64 octrlchunks;
+	__u64 ictrlchunks;
+};
+
 /* RFC2960
  *
  * 12. Recommended Transmission Control Block (TCB) Parameters
@@ -1830,6 +1864,8 @@ struct sctp_association {
 
 	__u8 need_ecne:1,	/* Need to send an ECNE Chunk? */
 	     temp:1;		/* Is it a temporary association? */
+
+	struct sctp_priv_assoc_stats stats;
 };
 
 
diff --git a/include/net/sctp/user.h b/include/net/sctp/user.h
index 1b02d7a..9a0ae09 100644
--- a/include/net/sctp/user.h
+++ b/include/net/sctp/user.h
@@ -107,6 +107,7 @@ typedef __s32 sctp_assoc_t;
 #define SCTP_GET_LOCAL_ADDRS	109		/* Get all local address. */
 #define SCTP_SOCKOPT_CONNECTX	110		/* CONNECTX requests. */
 #define SCTP_SOCKOPT_CONNECTX3	111	/* CONNECTX requests (updated) */
+#define SCTP_GET_ASSOC_STATS	112	/* Read only */
 
 /*
  * 5.2.1 SCTP Initiation Structure (SCTP_INIT)
@@ -719,6 +720,32 @@ struct sctp_getaddrs {
 	__u8			addrs[0]; /*output, variable size*/
 };
 
+/* A socket user request obtained via SCTP_GET_ASSOC_STATS that retrieves
+ * association stats. All stats are counts except sas_maxrto and
+ * sas_obs_rto_ipaddr. maxrto is the max observed rto + transport since
+ * the last call. Will return 0 when RTO was not update since last call
+ */
+struct sctp_assoc_stats {
+	sctp_assoc_t	sas_assoc_id;    /* Input */
+					 /* Transport of observed max RTO */
+	struct sockaddr_storage sas_obs_rto_ipaddr;
+	__u64		sas_maxrto;      /* Maximum Observed RTO for period */
+	__u64		sas_isacks;	 /* SACKs received */
+	__u64		sas_osacks;	 /* SACKs sent */
+	__u64		sas_opackets;	 /* Packets sent */
+	__u64		sas_ipackets;	 /* Packets received */
+	__u64		sas_rtxchunks;   /* Retransmitted Chunks */
+	__u64		sas_outofseqtsns;/* TSN received > next expected */
+	__u64		sas_idupchunks;  /* Dups received (ordered+unordered) */
+	__u64		sas_gapcnt;      /* Gap Acknowledgements Received */
+	__u64		sas_ouodchunks;  /* Unordered data chunks sent */
+	__u64		sas_iuodchunks;  /* Unordered data chunks received */
+	__u64		sas_oodchunks;	 /* Ordered data chunks sent */
+	__u64		sas_iodchunks;	 /* Ordered data chunks received */
+	__u64		sas_octrlchunks; /* Control chunks sent */
+	__u64		sas_ictrlchunks; /* Control chunks received */
+};
+
 /* These are bit fields for msghdr->msg_flags.  See section 5.1.  */
 /* On user space Linux, these live in <bits/socket.h> as an enum.  */
 enum sctp_msg_flags {
diff --git a/net/sctp/associola.c b/net/sctp/associola.c
index b1ef3bc..ba3f9cc 100644
--- a/net/sctp/associola.c
+++ b/net/sctp/associola.c
@@ -321,6 +321,9 @@ static struct sctp_association *sctp_association_init(struct sctp_association *a
 	asoc->default_timetolive = sp->default_timetolive;
 	asoc->default_rcv_context = sp->default_rcv_context;
 
+	/* SCTP_GET_ASSOC_STATS COUNTERS */
+	memset(&asoc->stats, 0, sizeof(struct sctp_priv_assoc_stats));
+
 	/* AUTH related initializations */
 	INIT_LIST_HEAD(&asoc->endpoint_shared_keys);
 	err = sctp_auth_asoc_copy_shkeys(ep, asoc, gfp);
@@ -760,6 +763,7 @@ struct sctp_transport *sctp_assoc_add_peer(struct sctp_association *asoc,
 
 	/* Set the transport's RTO.initial value */
 	peer->rto = asoc->rto_initial;
+	sctp_max_rto(asoc, peer);
 
 	/* Set the peer's active state. */
 	peer->state = peer_state;
@@ -1152,8 +1156,12 @@ static void sctp_assoc_bh_rcv(struct work_struct *work)
 		 */
 		if (sctp_chunk_is_data(chunk))
 			asoc->peer.last_data_from = chunk->transport;
-		else
+		else {
 			SCTP_INC_STATS(net, SCTP_MIB_INCTRLCHUNKS);
+			asoc->stats.ictrlchunks++;
+			if (chunk->chunk_hdr->type == SCTP_CID_SACK)
+				asoc->stats.isacks++;
+		}
 
 		if (chunk->transport)
 			chunk->transport->last_time_heard = jiffies;
diff --git a/net/sctp/endpointola.c b/net/sctp/endpointola.c
index 1859e2b..32ab55b 100644
--- a/net/sctp/endpointola.c
+++ b/net/sctp/endpointola.c
@@ -480,8 +480,11 @@ normal:
 		 */
 		if (asoc && sctp_chunk_is_data(chunk))
 			asoc->peer.last_data_from = chunk->transport;
-		else
+		else {
 			SCTP_INC_STATS(sock_net(ep->base.sk), SCTP_MIB_INCTRLCHUNKS);
+			if (asoc)
+				asoc->stats.ictrlchunks++;
+		}
 
 		if (chunk->transport)
 			chunk->transport->last_time_heard = jiffies;
diff --git a/net/sctp/inqueue.c b/net/sctp/inqueue.c
index 397296f..2d5ad28 100644
--- a/net/sctp/inqueue.c
+++ b/net/sctp/inqueue.c
@@ -104,6 +104,8 @@ void sctp_inq_push(struct sctp_inq *q, struct sctp_chunk *chunk)
 	 * on the BH related data structures.
 	 */
 	list_add_tail(&chunk->list, &q->in_chunk_list);
+	if (chunk->asoc)
+		chunk->asoc->stats.ipackets++;
 	q->immediate.func(&q->immediate);
 }
 
diff --git a/net/sctp/output.c b/net/sctp/output.c
index 4e90188bf..f5200a2 100644
--- a/net/sctp/output.c
+++ b/net/sctp/output.c
@@ -311,6 +311,8 @@ static sctp_xmit_t __sctp_packet_append_chunk(struct sctp_packet *packet,
 
 	    case SCTP_CID_SACK:
 		packet->has_sack = 1;
+		if (chunk->asoc)
+			chunk->asoc->stats.osacks++;
 		break;
 
 	    case SCTP_CID_AUTH:
@@ -584,11 +586,13 @@ int sctp_packet_transmit(struct sctp_packet *packet)
 	 */
 
 	/* Dump that on IP!  */
-	if (asoc && asoc->peer.last_sent_to != tp) {
-		/* Considering the multiple CPU scenario, this is a
-		 * "correcter" place for last_sent_to.  --xguo
-		 */
-		asoc->peer.last_sent_to = tp;
+	if (asoc) {
+		asoc->stats.opackets++;
+		if (asoc->peer.last_sent_to != tp)
+			/* Considering the multiple CPU scenario, this is a
+			 * "correcter" place for last_sent_to.  --xguo
+			 */
+			asoc->peer.last_sent_to = tp;
 	}
 
 	if (has_data) {
diff --git a/net/sctp/outqueue.c b/net/sctp/outqueue.c
index 1b4a7f8..379c81d 100644
--- a/net/sctp/outqueue.c
+++ b/net/sctp/outqueue.c
@@ -667,6 +667,7 @@ redo:
 				chunk->fast_retransmit = SCTP_DONT_FRTX;
 
 			q->empty = 0;
+			q->asoc->stats.rtxchunks++;
 			break;
 		}
 
@@ -876,12 +877,14 @@ static int sctp_outq_flush(struct sctp_outq *q, int rtx_timeout)
 			if (status  != SCTP_XMIT_OK) {
 				/* put the chunk back */
 				list_add(&chunk->list, &q->control_chunk_list);
-			} else if (chunk->chunk_hdr->type == SCTP_CID_FWD_TSN) {
+			} else {
+				asoc->stats.octrlchunks++;
 				/* PR-SCTP C5) If a FORWARD TSN is sent, the
 				 * sender MUST assure that at least one T3-rtx
 				 * timer is running.
 				 */
-				sctp_transport_reset_timers(transport);
+				if (chunk->chunk_hdr->type == SCTP_CID_FWD_TSN)
+					sctp_transport_reset_timers(transport);
 			}
 			break;
 
@@ -1055,6 +1058,10 @@ static int sctp_outq_flush(struct sctp_outq *q, int rtx_timeout)
 				 */
 				if (asoc->state == SCTP_STATE_SHUTDOWN_PENDING)
 					chunk->chunk_hdr->flags |= SCTP_DATA_SACK_IMM;
+				if (chunk->chunk_hdr->flags & SCTP_DATA_UNORDERED)
+					asoc->stats.ouodchunks++;
+				else
+					asoc->stats.oodchunks++;
 
 				break;
 
@@ -1162,6 +1169,7 @@ int sctp_outq_sack(struct sctp_outq *q, struct sctp_chunk *chunk)
 
 	sack_ctsn = ntohl(sack->cum_tsn_ack);
 	gap_ack_blocks = ntohs(sack->num_gap_ack_blocks);
+	asoc->stats.gapcnt += gap_ack_blocks;
 	/*
 	 * SFR-CACC algorithm:
 	 * On receipt of a SACK the sender SHOULD execute the
diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index e0f01a4..e1c5fc2 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -804,10 +804,11 @@ struct sctp_chunk *sctp_make_sack(const struct sctp_association *asoc)
 				 gabs);
 
 	/* Add the duplicate TSN information.  */
-	if (num_dup_tsns)
+	if (num_dup_tsns) {
+		aptr->stats.idupchunks += num_dup_tsns;
 		sctp_addto_chunk(retval, sizeof(__u32) * num_dup_tsns,
 				 sctp_tsnmap_get_dups(map));
-
+	}
 	/* Once we have a sack generated, check to see what our sack
 	 * generation is, if its 0, reset the transports to 0, and reset
 	 * the association generation to 1
diff --git a/net/sctp/sm_sideeffect.c b/net/sctp/sm_sideeffect.c
index c076956..c957775 100644
--- a/net/sctp/sm_sideeffect.c
+++ b/net/sctp/sm_sideeffect.c
@@ -542,6 +542,7 @@ static void sctp_do_8_2_transport_strike(sctp_cmd_seq_t *commands,
 	 */
 	if (!is_hb || transport->hb_sent) {
 		transport->rto = min((transport->rto * 2), transport->asoc->rto_max);
+		sctp_max_rto(asoc, transport);
 	}
 }
 
diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index b6adef8..ecf7a17 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -6127,6 +6127,8 @@ static int sctp_eat_data(const struct sctp_association *asoc,
 		/* The TSN is too high--silently discard the chunk and
 		 * count on it getting retransmitted later.
 		 */
+		if (chunk->asoc)
+			chunk->asoc->stats.outofseqtsns++;
 		return SCTP_IERROR_HIGH_TSN;
 	} else if (tmp > 0) {
 		/* This is a duplicate.  Record it.  */
@@ -6226,10 +6228,14 @@ static int sctp_eat_data(const struct sctp_association *asoc,
 	/* Note: Some chunks may get overcounted (if we drop) or overcounted
 	 * if we renege and the chunk arrives again.
 	 */
-	if (chunk->chunk_hdr->flags & SCTP_DATA_UNORDERED)
+	if (chunk->chunk_hdr->flags & SCTP_DATA_UNORDERED) {
 		SCTP_INC_STATS(net, SCTP_MIB_INUNORDERCHUNKS);
-	else {
+		if (chunk->asoc)
+			chunk->asoc->stats.iuodchunks++;
+	} else {
 		SCTP_INC_STATS(net, SCTP_MIB_INORDERCHUNKS);
+		if (chunk->asoc)
+			chunk->asoc->stats.iodchunks++;
 		ordered = 1;
 	}
 
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 2e89706..7b8d01a 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -611,6 +611,7 @@ static int sctp_send_asconf_add_ip(struct sock		*sk,
 				    2*asoc->pathmtu, 4380));
 				trans->ssthresh = asoc->peer.i.a_rwnd;
 				trans->rto = asoc->rto_initial;
+				sctp_max_rto(asoc, trans);
 				trans->rtt = trans->srtt = trans->rttvar = 0;
 				sctp_transport_route(trans, NULL,
 				    sctp_sk(asoc->base.sk));
@@ -5635,6 +5636,71 @@ static int sctp_getsockopt_paddr_thresholds(struct sock *sk,
 	return 0;
 }
 
+/*
+ * SCTP_GET_ASSOC_STATS
+ *
+ * This option retrieves local per endpoint statistics. It is modeled
+ * after OpenSolaris' implementation
+ */
+static int sctp_getsockopt_assoc_stats(struct sock *sk, int len,
+				       char __user *optval,
+				       int __user *optlen)
+{
+	struct sctp_assoc_stats sas;
+	struct sctp_association *asoc = NULL;
+
+	/* User must provide at least the assoc id */
+	if (len < sizeof(sctp_assoc_t))
+		return -EINVAL;
+
+	if (copy_from_user(&sas, optval, len))
+		return -EFAULT;
+
+	asoc = sctp_id2assoc(sk, sas.sas_assoc_id);
+	if (!asoc)
+		return -EINVAL;
+
+	sas.sas_rtxchunks = asoc->stats.rtxchunks;
+	sas.sas_gapcnt = asoc->stats.gapcnt;
+	sas.sas_outofseqtsns = asoc->stats.outofseqtsns;
+	sas.sas_osacks = asoc->stats.osacks;
+	sas.sas_isacks = asoc->stats.isacks;
+	sas.sas_octrlchunks = asoc->stats.octrlchunks;
+	sas.sas_ictrlchunks = asoc->stats.ictrlchunks;
+	sas.sas_oodchunks = asoc->stats.oodchunks;
+	sas.sas_iodchunks = asoc->stats.iodchunks;
+	sas.sas_ouodchunks = asoc->stats.ouodchunks;
+	sas.sas_iuodchunks = asoc->stats.iuodchunks;
+	sas.sas_idupchunks = asoc->stats.idupchunks;
+	sas.sas_opackets = asoc->stats.opackets;
+	sas.sas_ipackets = asoc->stats.ipackets;
+
+	/* New high max rto observed, will return 0 if not a single
+	 * RTO update took place. obs_rto_ipaddr will be bogus
+	 * in such a case
+	 */
+	sas.sas_maxrto = asoc->stats.max_obs_rto;
+	memcpy(&sas.sas_obs_rto_ipaddr, &asoc->stats.obs_rto_ipaddr,
+		sizeof(struct sockaddr_storage));
+
+	/* Mark beginning of a new observation period */
+	asoc->stats.max_obs_rto = asoc->rto_min;
+
+	/* Allow the struct to grow and fill in as much as possible */
+	len = min_t(size_t, len, sizeof(sas));
+
+	if (put_user(len, optlen))
+		return -EFAULT;
+
+	SCTP_DEBUG_PRINTK("sctp_getsockopt_assoc_stat(%d): %d\n",
+			  len, sas.sas_assoc_id);
+
+	if (copy_to_user(optval, &sas, len))
+		return -EFAULT;
+
+	return 0;
+}
+
 SCTP_STATIC int sctp_getsockopt(struct sock *sk, int level, int optname,
 				char __user *optval, int __user *optlen)
 {
@@ -5776,6 +5842,9 @@ SCTP_STATIC int sctp_getsockopt(struct sock *sk, int level, int optname,
 	case SCTP_PEER_ADDR_THLDS:
 		retval = sctp_getsockopt_paddr_thresholds(sk, optval, len, optlen);
 		break;
+	case SCTP_GET_ASSOC_STATS:
+		retval = sctp_getsockopt_assoc_stats(sk, len, optval, optlen);
+		break;
 	default:
 		retval = -ENOPROTOOPT;
 		break;
diff --git a/net/sctp/transport.c b/net/sctp/transport.c
index 953c21e..40574ad 100644
--- a/net/sctp/transport.c
+++ b/net/sctp/transport.c
@@ -363,6 +363,7 @@ void sctp_transport_update_rto(struct sctp_transport *tp, __u32 rtt)
 	if (tp->rto > tp->asoc->rto_max)
 		tp->rto = tp->asoc->rto_max;
 
+	sctp_max_rto(tp->asoc, tp);
 	tp->rtt = rtt;
 
 	/* Reset rto_pending so that a new RTT measurement is started when a
@@ -620,6 +621,7 @@ void sctp_transport_reset(struct sctp_transport *t)
 	t->burst_limited = 0;
 	t->ssthresh = asoc->peer.i.a_rwnd;
 	t->rto = asoc->rto_initial;
+	sctp_max_rto(asoc, t);
 	t->rtt = 0;
 	t->srtt = 0;
 	t->rttvar = 0;
-- 
1.8.0.1
