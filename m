From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: [PATCH] sctp: allow sctp_transmit_packet and others to use gfp
Date: Thu, 10 Mar 2016 18:33:07 -0300
Message-ID: <90a118e4ca996adb067290a6c45fca6564a77423.1457644344.git.marcelo.leitner@gmail.com>
Cc: Vlad Yasevich <vyasevich@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>, linux-sctp@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59034 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932180AbcCJVdY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Mar 2016 16:33:24 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently sctp_sendmsg() triggers some calls that will allocate memory
with GFP_ATOMIC even when not necessary. In the case of
sctp_packet_transmit it will allocate a linear skb that will be used to
construct the packet and this may cause sends to fail due to ENOMEM more
often than anticipated specially with big MTUs.

This patch thus allows it to inherit gfp flags from upper calls so that
it can use GFP_KERNEL if it was triggered by a sctp_sendmsg call or
similar. All others, like retransmits or flushes started from BH, are
still allocated using GFP_ATOMIC.

In netperf tests this didn't result in any performance drawbacks when
memory is not too fragmented and made it trigger ENOMEM way less often.

Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
---
 include/net/sctp/sm.h      |  2 +-
 include/net/sctp/structs.h | 10 +++---
 net/sctp/associola.c       |  2 +-
 net/sctp/chunk.c           |  6 ++--
 net/sctp/input.c           |  2 +-
 net/sctp/output.c          |  6 ++--
 net/sctp/outqueue.c        | 30 ++++++++---------
 net/sctp/sm_make_chunk.c   | 80 +++++++++++++++++++++++++++-------------------
 net/sctp/sm_sideeffect.c   | 23 ++++++-------
 9 files changed, 89 insertions(+), 72 deletions(-)

diff --git a/include/net/sctp/sm.h b/include/net/sctp/sm.h
index 487ef34bbd63ff1cfe511c7ee8b1501593a14de3..efc01743b9d641bf6b16a37780ee0df34b4ec698 100644
--- a/include/net/sctp/sm.h
+++ b/include/net/sctp/sm.h
@@ -201,7 +201,7 @@ struct sctp_chunk *sctp_make_cwr(const struct sctp_association *,
 struct sctp_chunk * sctp_make_datafrag_empty(struct sctp_association *,
 					const struct sctp_sndrcvinfo *sinfo,
 					int len, const __u8 flags,
-					__u16 ssn);
+					__u16 ssn, gfp_t gfp);
 struct sctp_chunk *sctp_make_ecne(const struct sctp_association *,
 				  const __u32);
 struct sctp_chunk *sctp_make_sack(const struct sctp_association *);
diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index 205630bb5010b8ac76b84651b302e488fc1c76ff..0b65c16bbc2a837b2fd2aca4aa8cee5686feaf33 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -656,7 +656,7 @@ void sctp_chunk_free(struct sctp_chunk *);
 void  *sctp_addto_chunk(struct sctp_chunk *, int len, const void *data);
 struct sctp_chunk *sctp_chunkify(struct sk_buff *,
 				 const struct sctp_association *,
-				 struct sock *);
+				 struct sock *, gfp_t gfp);
 void sctp_init_addrs(struct sctp_chunk *, union sctp_addr *,
 		     union sctp_addr *);
 const union sctp_addr *sctp_source(const struct sctp_chunk *chunk);
@@ -718,10 +718,10 @@ struct sctp_packet *sctp_packet_init(struct sctp_packet *,
 				     __u16 sport, __u16 dport);
 struct sctp_packet *sctp_packet_config(struct sctp_packet *, __u32 vtag, int);
 sctp_xmit_t sctp_packet_transmit_chunk(struct sctp_packet *,
-                                       struct sctp_chunk *, int);
+				       struct sctp_chunk *, int, gfp_t);
 sctp_xmit_t sctp_packet_append_chunk(struct sctp_packet *,
                                      struct sctp_chunk *);
-int sctp_packet_transmit(struct sctp_packet *);
+int sctp_packet_transmit(struct sctp_packet *, gfp_t);
 void sctp_packet_free(struct sctp_packet *);
 
 static inline int sctp_packet_empty(struct sctp_packet *packet)
@@ -1054,7 +1054,7 @@ struct sctp_outq {
 void sctp_outq_init(struct sctp_association *, struct sctp_outq *);
 void sctp_outq_teardown(struct sctp_outq *);
 void sctp_outq_free(struct sctp_outq*);
-int sctp_outq_tail(struct sctp_outq *, struct sctp_chunk *chunk);
+int sctp_outq_tail(struct sctp_outq *, struct sctp_chunk *chunk, gfp_t);
 int sctp_outq_sack(struct sctp_outq *, struct sctp_chunk *);
 int sctp_outq_is_empty(const struct sctp_outq *);
 void sctp_outq_restart(struct sctp_outq *);
@@ -1062,7 +1062,7 @@ void sctp_outq_restart(struct sctp_outq *);
 void sctp_retransmit(struct sctp_outq *, struct sctp_transport *,
 		     sctp_retransmit_reason_t);
 void sctp_retransmit_mark(struct sctp_outq *, struct sctp_transport *, __u8);
-int sctp_outq_uncork(struct sctp_outq *);
+int sctp_outq_uncork(struct sctp_outq *, gfp_t gfp);
 /* Uncork and flush an outqueue.  */
 static inline void sctp_outq_cork(struct sctp_outq *q)
 {
diff --git a/net/sctp/associola.c b/net/sctp/associola.c
index 2bf8ec92dde482ed6ab59275aad492d5abc5385e..24d2f6fffbc52bedbcd4efec82eaf834f0c75613 100644
--- a/net/sctp/associola.c
+++ b/net/sctp/associola.c
@@ -1493,7 +1493,7 @@ void sctp_assoc_rwnd_increase(struct sctp_association *asoc, unsigned int len)
 
 		asoc->peer.sack_needed = 0;
 
-		sctp_outq_tail(&asoc->outqueue, sack);
+		sctp_outq_tail(&asoc->outqueue, sack, GFP_ATOMIC);
 
 		/* Stop the SACK timer.  */
 		timer = &asoc->timers[SCTP_EVENT_TIMEOUT_SACK];
diff --git a/net/sctp/chunk.c b/net/sctp/chunk.c
index a3380917f1973dba6c43507bc16b4f3fbc090c8a..a706a1d1d628c95af27f99ccb349ede218f933ec 100644
--- a/net/sctp/chunk.c
+++ b/net/sctp/chunk.c
@@ -273,7 +273,8 @@ struct sctp_datamsg *sctp_datamsg_from_user(struct sctp_association *asoc,
 				frag |= SCTP_DATA_SACK_IMM;
 		}
 
-		chunk = sctp_make_datafrag_empty(asoc, sinfo, len, frag, 0);
+		chunk = sctp_make_datafrag_empty(asoc, sinfo, len, frag,
+						 0, GFP_KERNEL);
 
 		if (!chunk) {
 			err = -ENOMEM;
@@ -309,7 +310,8 @@ struct sctp_datamsg *sctp_datamsg_from_user(struct sctp_association *asoc,
 		    (sinfo->sinfo_flags & SCTP_SACK_IMMEDIATELY))
 			frag |= SCTP_DATA_SACK_IMM;
 
-		chunk = sctp_make_datafrag_empty(asoc, sinfo, over, frag, 0);
+		chunk = sctp_make_datafrag_empty(asoc, sinfo, over, frag,
+						 0, GFP_KERNEL);
 
 		if (!chunk) {
 			err = -ENOMEM;
diff --git a/net/sctp/input.c b/net/sctp/input.c
index 49d2cc751386f3208c67eed17ec9c3f15b801f50..0270914c1b54e306a7929ed192a532e7865f2880 100644
--- a/net/sctp/input.c
+++ b/net/sctp/input.c
@@ -221,7 +221,7 @@ int sctp_rcv(struct sk_buff *skb)
 		goto discard_release;
 
 	/* Create an SCTP packet structure. */
-	chunk = sctp_chunkify(skb, asoc, sk);
+	chunk = sctp_chunkify(skb, asoc, sk, GFP_ATOMIC);
 	if (!chunk)
 		goto discard_release;
 	SCTP_INPUT_CB(skb)->chunk = chunk;
diff --git a/net/sctp/output.c b/net/sctp/output.c
index 9d610eddd19ef2320fc34ae9d91e7426ae5f50f9..736c004abfbc2787a3c50fa85168ebdf3b112787 100644
--- a/net/sctp/output.c
+++ b/net/sctp/output.c
@@ -153,7 +153,7 @@ void sctp_packet_free(struct sctp_packet *packet)
  */
 sctp_xmit_t sctp_packet_transmit_chunk(struct sctp_packet *packet,
 				       struct sctp_chunk *chunk,
-				       int one_packet)
+				       int one_packet, gfp_t gfp)
 {
 	sctp_xmit_t retval;
 	int error = 0;
@@ -163,7 +163,7 @@ sctp_xmit_t sctp_packet_transmit_chunk(struct sctp_packet *packet,
 	switch ((retval = (sctp_packet_append_chunk(packet, chunk)))) {
 	case SCTP_XMIT_PMTU_FULL:
 		if (!packet->has_cookie_echo) {
-			error = sctp_packet_transmit(packet);
+			error = sctp_packet_transmit(packet, gfp);
 			if (error < 0)
 				chunk->skb->sk->sk_err = -error;
 
@@ -376,7 +376,7 @@ static void sctp_packet_set_owner_w(struct sk_buff *skb, struct sock *sk)
  *
  * The return value is a normal kernel error return value.
  */
-int sctp_packet_transmit(struct sctp_packet *packet)
+int sctp_packet_transmit(struct sctp_packet *packet, gfp_t gfp)
 {
 	struct sctp_transport *tp = packet->transport;
 	struct sctp_association *asoc = tp->asoc;
diff --git a/net/sctp/outqueue.c b/net/sctp/outqueue.c
index c0380cfb16ae4eb77bdab457e8310c0cb15a1c4a..f03541d0f12d052d1f58901d57852be46f18a15a 100644
--- a/net/sctp/outqueue.c
+++ b/net/sctp/outqueue.c
@@ -68,7 +68,7 @@ static void sctp_mark_missing(struct sctp_outq *q,
 
 static void sctp_generate_fwdtsn(struct sctp_outq *q, __u32 sack_ctsn);
 
-static int sctp_outq_flush(struct sctp_outq *q, int rtx_timeout);
+static int sctp_outq_flush(struct sctp_outq *q, int rtx_timeout, gfp_t gfp);
 
 /* Add data to the front of the queue. */
 static inline void sctp_outq_head_data(struct sctp_outq *q,
@@ -285,7 +285,7 @@ void sctp_outq_free(struct sctp_outq *q)
 }
 
 /* Put a new chunk in an sctp_outq.  */
-int sctp_outq_tail(struct sctp_outq *q, struct sctp_chunk *chunk)
+int sctp_outq_tail(struct sctp_outq *q, struct sctp_chunk *chunk, gfp_t gfp)
 {
 	struct net *net = sock_net(q->asoc->base.sk);
 	int error = 0;
@@ -341,7 +341,7 @@ int sctp_outq_tail(struct sctp_outq *q, struct sctp_chunk *chunk)
 		return error;
 
 	if (!q->cork)
-		error = sctp_outq_flush(q, 0);
+		error = sctp_outq_flush(q, 0, gfp);
 
 	return error;
 }
@@ -510,7 +510,7 @@ void sctp_retransmit(struct sctp_outq *q, struct sctp_transport *transport,
 	 * will be flushed at the end.
 	 */
 	if (reason != SCTP_RTXR_FAST_RTX)
-		error = sctp_outq_flush(q, /* rtx_timeout */ 1);
+		error = sctp_outq_flush(q, /* rtx_timeout */ 1, GFP_ATOMIC);
 
 	if (error)
 		q->asoc->base.sk->sk_err = -error;
@@ -601,12 +601,12 @@ redo:
 				 * control chunks are already freed so there
 				 * is nothing we can do.
 				 */
-				sctp_packet_transmit(pkt);
+				sctp_packet_transmit(pkt, GFP_ATOMIC);
 				goto redo;
 			}
 
 			/* Send this packet.  */
-			error = sctp_packet_transmit(pkt);
+			error = sctp_packet_transmit(pkt, GFP_ATOMIC);
 
 			/* If we are retransmitting, we should only
 			 * send a single packet.
@@ -622,7 +622,7 @@ redo:
 
 		case SCTP_XMIT_RWND_FULL:
 			/* Send this packet. */
-			error = sctp_packet_transmit(pkt);
+			error = sctp_packet_transmit(pkt, GFP_ATOMIC);
 
 			/* Stop sending DATA as there is no more room
 			 * at the receiver.
@@ -632,7 +632,7 @@ redo:
 
 		case SCTP_XMIT_DELAY:
 			/* Send this packet. */
-			error = sctp_packet_transmit(pkt);
+			error = sctp_packet_transmit(pkt, GFP_ATOMIC);
 
 			/* Stop sending DATA because of nagle delay. */
 			done = 1;
@@ -685,12 +685,12 @@ redo:
 }
 
 /* Cork the outqueue so queued chunks are really queued. */
-int sctp_outq_uncork(struct sctp_outq *q)
+int sctp_outq_uncork(struct sctp_outq *q, gfp_t gfp)
 {
 	if (q->cork)
 		q->cork = 0;
 
-	return sctp_outq_flush(q, 0);
+	return sctp_outq_flush(q, 0, gfp);
 }
 
 
@@ -703,7 +703,7 @@ int sctp_outq_uncork(struct sctp_outq *q)
  * locking concerns must be made.  Today we use the sock lock to protect
  * this function.
  */
-static int sctp_outq_flush(struct sctp_outq *q, int rtx_timeout)
+static int sctp_outq_flush(struct sctp_outq *q, int rtx_timeout, gfp_t gfp)
 {
 	struct sctp_packet *packet;
 	struct sctp_packet singleton;
@@ -825,7 +825,7 @@ static int sctp_outq_flush(struct sctp_outq *q, int rtx_timeout)
 			sctp_packet_init(&singleton, transport, sport, dport);
 			sctp_packet_config(&singleton, vtag, 0);
 			sctp_packet_append_chunk(&singleton, chunk);
-			error = sctp_packet_transmit(&singleton);
+			error = sctp_packet_transmit(&singleton, gfp);
 			if (error < 0)
 				return error;
 			break;
@@ -856,7 +856,7 @@ static int sctp_outq_flush(struct sctp_outq *q, int rtx_timeout)
 		case SCTP_CID_ASCONF:
 		case SCTP_CID_FWD_TSN:
 			status = sctp_packet_transmit_chunk(packet, chunk,
-							    one_packet);
+							    one_packet, gfp);
 			if (status  != SCTP_XMIT_OK) {
 				/* put the chunk back */
 				list_add(&chunk->list, &q->control_chunk_list);
@@ -1011,7 +1011,7 @@ static int sctp_outq_flush(struct sctp_outq *q, int rtx_timeout)
 				 atomic_read(&chunk->skb->users) : -1);
 
 			/* Add the chunk to the packet.  */
-			status = sctp_packet_transmit_chunk(packet, chunk, 0);
+			status = sctp_packet_transmit_chunk(packet, chunk, 0, gfp);
 
 			switch (status) {
 			case SCTP_XMIT_PMTU_FULL:
@@ -1088,7 +1088,7 @@ sctp_flush_out:
 						      send_ready);
 		packet = &t->packet;
 		if (!sctp_packet_empty(packet))
-			error = sctp_packet_transmit(packet);
+			error = sctp_packet_transmit(packet, gfp);
 
 		/* Clear the burst limited state, if any */
 		sctp_transport_burst_reset(t);
diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index 5d6a03fad3789a12290f5f14c5a7efa69c98f41a..8449ca26aa0bfd9e787670e5a2eea5afd85773b6 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -62,11 +62,13 @@
 #include <net/sctp/sm.h>
 
 static struct sctp_chunk *sctp_make_control(const struct sctp_association *asoc,
-					    __u8 type, __u8 flags, int paylen);
+					    __u8 type, __u8 flags, int paylen,
+					    gfp_t gfp);
 static struct sctp_chunk *sctp_make_data(const struct sctp_association *asoc,
-					 __u8 flags, int paylen);
+					 __u8 flags, int paylen, gfp_t gfp);
 static struct sctp_chunk *_sctp_make_chunk(const struct sctp_association *asoc,
-					   __u8 type, __u8 flags, int paylen);
+					   __u8 type, __u8 flags, int paylen,
+					   gfp_t gfp);
 static sctp_cookie_param_t *sctp_pack_cookie(const struct sctp_endpoint *ep,
 					const struct sctp_association *asoc,
 					const struct sctp_chunk *init_chunk,
@@ -318,7 +320,7 @@ struct sctp_chunk *sctp_make_init(const struct sctp_association *asoc,
 	 * PLEASE DO NOT FIXME [This version does not support Host Name.]
 	 */
 
-	retval = sctp_make_control(asoc, SCTP_CID_INIT, 0, chunksize);
+	retval = sctp_make_control(asoc, SCTP_CID_INIT, 0, chunksize, gfp);
 	if (!retval)
 		goto nodata;
 
@@ -465,7 +467,7 @@ struct sctp_chunk *sctp_make_init_ack(const struct sctp_association *asoc,
 					num_ext);
 
 	/* Now allocate and fill out the chunk.  */
-	retval = sctp_make_control(asoc, SCTP_CID_INIT_ACK, 0, chunksize);
+	retval = sctp_make_control(asoc, SCTP_CID_INIT_ACK, 0, chunksize, gfp);
 	if (!retval)
 		goto nomem_chunk;
 
@@ -570,7 +572,8 @@ struct sctp_chunk *sctp_make_cookie_echo(const struct sctp_association *asoc,
 	cookie_len = asoc->peer.cookie_len;
 
 	/* Build a cookie echo chunk.  */
-	retval = sctp_make_control(asoc, SCTP_CID_COOKIE_ECHO, 0, cookie_len);
+	retval = sctp_make_control(asoc, SCTP_CID_COOKIE_ECHO, 0,
+				   cookie_len, GFP_ATOMIC);
 	if (!retval)
 		goto nodata;
 	retval->subh.cookie_hdr =
@@ -615,7 +618,7 @@ struct sctp_chunk *sctp_make_cookie_ack(const struct sctp_association *asoc,
 {
 	struct sctp_chunk *retval;
 
-	retval = sctp_make_control(asoc, SCTP_CID_COOKIE_ACK, 0, 0);
+	retval = sctp_make_control(asoc, SCTP_CID_COOKIE_ACK, 0, 0, GFP_ATOMIC);
 
 	/* RFC 2960 6.4 Multi-homed SCTP Endpoints
 	 *
@@ -664,7 +667,7 @@ struct sctp_chunk *sctp_make_cwr(const struct sctp_association *asoc,
 
 	cwr.lowest_tsn = htonl(lowest_tsn);
 	retval = sctp_make_control(asoc, SCTP_CID_ECN_CWR, 0,
-				   sizeof(sctp_cwrhdr_t));
+				   sizeof(sctp_cwrhdr_t), GFP_ATOMIC);
 
 	if (!retval)
 		goto nodata;
@@ -698,7 +701,7 @@ struct sctp_chunk *sctp_make_ecne(const struct sctp_association *asoc,
 
 	ecne.lowest_tsn = htonl(lowest_tsn);
 	retval = sctp_make_control(asoc, SCTP_CID_ECN_ECNE, 0,
-				   sizeof(sctp_ecnehdr_t));
+				   sizeof(sctp_ecnehdr_t), GFP_ATOMIC);
 	if (!retval)
 		goto nodata;
 	retval->subh.ecne_hdr =
@@ -713,7 +716,8 @@ nodata:
  */
 struct sctp_chunk *sctp_make_datafrag_empty(struct sctp_association *asoc,
 				       const struct sctp_sndrcvinfo *sinfo,
-				       int data_len, __u8 flags, __u16 ssn)
+				       int data_len, __u8 flags, __u16 ssn,
+				       gfp_t gfp)
 {
 	struct sctp_chunk *retval;
 	struct sctp_datahdr dp;
@@ -734,7 +738,7 @@ struct sctp_chunk *sctp_make_datafrag_empty(struct sctp_association *asoc,
 		dp.ssn = htons(ssn);
 
 	chunk_len = sizeof(dp) + data_len;
-	retval = sctp_make_data(asoc, flags, chunk_len);
+	retval = sctp_make_data(asoc, flags, chunk_len, gfp);
 	if (!retval)
 		goto nodata;
 
@@ -781,7 +785,7 @@ struct sctp_chunk *sctp_make_sack(const struct sctp_association *asoc)
 		+ sizeof(__u32) * num_dup_tsns;
 
 	/* Create the chunk.  */
-	retval = sctp_make_control(asoc, SCTP_CID_SACK, 0, len);
+	retval = sctp_make_control(asoc, SCTP_CID_SACK, 0, len, GFP_ATOMIC);
 	if (!retval)
 		goto nodata;
 
@@ -861,7 +865,7 @@ struct sctp_chunk *sctp_make_shutdown(const struct sctp_association *asoc,
 	shut.cum_tsn_ack = htonl(ctsn);
 
 	retval = sctp_make_control(asoc, SCTP_CID_SHUTDOWN, 0,
-				   sizeof(sctp_shutdownhdr_t));
+				   sizeof(sctp_shutdownhdr_t), GFP_ATOMIC);
 	if (!retval)
 		goto nodata;
 
@@ -879,7 +883,8 @@ struct sctp_chunk *sctp_make_shutdown_ack(const struct sctp_association *asoc,
 {
 	struct sctp_chunk *retval;
 
-	retval = sctp_make_control(asoc, SCTP_CID_SHUTDOWN_ACK, 0, 0);
+	retval = sctp_make_control(asoc, SCTP_CID_SHUTDOWN_ACK, 0, 0,
+				   GFP_ATOMIC);
 
 	/* RFC 2960 6.4 Multi-homed SCTP Endpoints
 	 *
@@ -908,7 +913,8 @@ struct sctp_chunk *sctp_make_shutdown_complete(
 	 */
 	flags |= asoc ? 0 : SCTP_CHUNK_FLAG_T;
 
-	retval = sctp_make_control(asoc, SCTP_CID_SHUTDOWN_COMPLETE, flags, 0);
+	retval = sctp_make_control(asoc, SCTP_CID_SHUTDOWN_COMPLETE, flags,
+				   0, GFP_ATOMIC);
 
 	/* RFC 2960 6.4 Multi-homed SCTP Endpoints
 	 *
@@ -947,7 +953,8 @@ struct sctp_chunk *sctp_make_abort(const struct sctp_association *asoc,
 			flags = SCTP_CHUNK_FLAG_T;
 	}
 
-	retval = sctp_make_control(asoc, SCTP_CID_ABORT, flags, hint);
+	retval = sctp_make_control(asoc, SCTP_CID_ABORT, flags, hint,
+				   GFP_ATOMIC);
 
 	/* RFC 2960 6.4 Multi-homed SCTP Endpoints
 	 *
@@ -1139,7 +1146,8 @@ struct sctp_chunk *sctp_make_heartbeat(const struct sctp_association *asoc,
 	struct sctp_chunk *retval;
 	sctp_sender_hb_info_t hbinfo;
 
-	retval = sctp_make_control(asoc, SCTP_CID_HEARTBEAT, 0, sizeof(hbinfo));
+	retval = sctp_make_control(asoc, SCTP_CID_HEARTBEAT, 0,
+				   sizeof(hbinfo), GFP_ATOMIC);
 
 	if (!retval)
 		goto nodata;
@@ -1167,7 +1175,8 @@ struct sctp_chunk *sctp_make_heartbeat_ack(const struct sctp_association *asoc,
 {
 	struct sctp_chunk *retval;
 
-	retval  = sctp_make_control(asoc, SCTP_CID_HEARTBEAT_ACK, 0, paylen);
+	retval  = sctp_make_control(asoc, SCTP_CID_HEARTBEAT_ACK, 0, paylen,
+				    GFP_ATOMIC);
 	if (!retval)
 		goto nodata;
 
@@ -1200,7 +1209,7 @@ static struct sctp_chunk *sctp_make_op_error_space(
 	struct sctp_chunk *retval;
 
 	retval = sctp_make_control(asoc, SCTP_CID_ERROR, 0,
-				   sizeof(sctp_errhdr_t) + size);
+				   sizeof(sctp_errhdr_t) + size, GFP_ATOMIC);
 	if (!retval)
 		goto nodata;
 
@@ -1271,7 +1280,8 @@ struct sctp_chunk *sctp_make_auth(const struct sctp_association *asoc)
 		return NULL;
 
 	retval = sctp_make_control(asoc, SCTP_CID_AUTH, 0,
-			hmac_desc->hmac_len + sizeof(sctp_authhdr_t));
+			hmac_desc->hmac_len + sizeof(sctp_authhdr_t),
+			GFP_ATOMIC);
 	if (!retval)
 		return NULL;
 
@@ -1309,11 +1319,11 @@ struct sctp_chunk *sctp_make_auth(const struct sctp_association *asoc)
  */
 struct sctp_chunk *sctp_chunkify(struct sk_buff *skb,
 			    const struct sctp_association *asoc,
-			    struct sock *sk)
+			    struct sock *sk, gfp_t gfp)
 {
 	struct sctp_chunk *retval;
 
-	retval = kmem_cache_zalloc(sctp_chunk_cachep, GFP_ATOMIC);
+	retval = kmem_cache_zalloc(sctp_chunk_cachep, gfp);
 
 	if (!retval)
 		goto nodata;
@@ -1361,7 +1371,8 @@ const union sctp_addr *sctp_source(const struct sctp_chunk *chunk)
  * arguments, reserving enough space for a 'paylen' byte payload.
  */
 static struct sctp_chunk *_sctp_make_chunk(const struct sctp_association *asoc,
-					    __u8 type, __u8 flags, int paylen)
+					    __u8 type, __u8 flags, int paylen,
+					    gfp_t gfp)
 {
 	struct sctp_chunk *retval;
 	sctp_chunkhdr_t *chunk_hdr;
@@ -1369,8 +1380,7 @@ static struct sctp_chunk *_sctp_make_chunk(const struct sctp_association *asoc,
 	struct sock *sk;
 
 	/* No need to allocate LL here, as this is only a chunk. */
-	skb = alloc_skb(WORD_ROUND(sizeof(sctp_chunkhdr_t) + paylen),
-			GFP_ATOMIC);
+	skb = alloc_skb(WORD_ROUND(sizeof(sctp_chunkhdr_t) + paylen), gfp);
 	if (!skb)
 		goto nodata;
 
@@ -1381,7 +1391,7 @@ static struct sctp_chunk *_sctp_make_chunk(const struct sctp_association *asoc,
 	chunk_hdr->length = htons(sizeof(sctp_chunkhdr_t));
 
 	sk = asoc ? asoc->base.sk : NULL;
-	retval = sctp_chunkify(skb, asoc, sk);
+	retval = sctp_chunkify(skb, asoc, sk, gfp);
 	if (!retval) {
 		kfree_skb(skb);
 		goto nodata;
@@ -1400,16 +1410,18 @@ nodata:
 }
 
 static struct sctp_chunk *sctp_make_data(const struct sctp_association *asoc,
-					 __u8 flags, int paylen)
+					 __u8 flags, int paylen, gfp_t gfp)
 {
-	return _sctp_make_chunk(asoc, SCTP_CID_DATA, flags, paylen);
+	return _sctp_make_chunk(asoc, SCTP_CID_DATA, flags, paylen, gfp);
 }
 
 static struct sctp_chunk *sctp_make_control(const struct sctp_association *asoc,
-					    __u8 type, __u8 flags, int paylen)
+					    __u8 type, __u8 flags, int paylen,
+					    gfp_t gfp)
 {
-	struct sctp_chunk *chunk = _sctp_make_chunk(asoc, type, flags, paylen);
+	struct sctp_chunk *chunk;
 
+	chunk = _sctp_make_chunk(asoc, type, flags, paylen, gfp);
 	if (chunk)
 		sctp_control_set_owner_w(chunk);
 
@@ -2756,7 +2768,8 @@ static struct sctp_chunk *sctp_make_asconf(struct sctp_association *asoc,
 	length += addrlen;
 
 	/* Create the chunk.  */
-	retval = sctp_make_control(asoc, SCTP_CID_ASCONF, 0, length);
+	retval = sctp_make_control(asoc, SCTP_CID_ASCONF, 0, length,
+				   GFP_ATOMIC);
 	if (!retval)
 		return NULL;
 
@@ -2940,7 +2953,8 @@ static struct sctp_chunk *sctp_make_asconf_ack(const struct sctp_association *as
 	int			length = sizeof(asconf) + vparam_len;
 
 	/* Create the chunk.  */
-	retval = sctp_make_control(asoc, SCTP_CID_ASCONF_ACK, 0, length);
+	retval = sctp_make_control(asoc, SCTP_CID_ASCONF_ACK, 0, length,
+				   GFP_ATOMIC);
 	if (!retval)
 		return NULL;
 
@@ -3500,7 +3514,7 @@ struct sctp_chunk *sctp_make_fwdtsn(const struct sctp_association *asoc,
 
 	hint = (nstreams + 1) * sizeof(__u32);
 
-	retval = sctp_make_control(asoc, SCTP_CID_FWD_TSN, 0, hint);
+	retval = sctp_make_control(asoc, SCTP_CID_FWD_TSN, 0, hint, GFP_ATOMIC);
 
 	if (!retval)
 		return NULL;
diff --git a/net/sctp/sm_sideeffect.c b/net/sctp/sm_sideeffect.c
index b5327bb77458f3ae68e0098c45d00307a56ed2c5..3c22c41a2bc2dc128d651f64b1a81036be22b9b3 100644
--- a/net/sctp/sm_sideeffect.c
+++ b/net/sctp/sm_sideeffect.c
@@ -1019,13 +1019,13 @@ static void sctp_cmd_t1_timer_update(struct sctp_association *asoc,
  * encouraged for small fragments.
  */
 static int sctp_cmd_send_msg(struct sctp_association *asoc,
-				struct sctp_datamsg *msg)
+				struct sctp_datamsg *msg, gfp_t gfp)
 {
 	struct sctp_chunk *chunk;
 	int error = 0;
 
 	list_for_each_entry(chunk, &msg->chunks, frag_list) {
-		error = sctp_outq_tail(&asoc->outqueue, chunk);
+		error = sctp_outq_tail(&asoc->outqueue, chunk, gfp);
 		if (error)
 			break;
 	}
@@ -1249,7 +1249,7 @@ static int sctp_cmd_interpreter(sctp_event_t event_type,
 		case SCTP_CMD_NEW_ASOC:
 			/* Register a new association.  */
 			if (local_cork) {
-				sctp_outq_uncork(&asoc->outqueue);
+				sctp_outq_uncork(&asoc->outqueue, gfp);
 				local_cork = 0;
 			}
 
@@ -1269,7 +1269,7 @@ static int sctp_cmd_interpreter(sctp_event_t event_type,
 
 		case SCTP_CMD_DELETE_TCB:
 			if (local_cork) {
-				sctp_outq_uncork(&asoc->outqueue);
+				sctp_outq_uncork(&asoc->outqueue, gfp);
 				local_cork = 0;
 			}
 			/* Delete the current association.  */
@@ -1423,13 +1423,14 @@ static int sctp_cmd_interpreter(sctp_event_t event_type,
 				local_cork = 1;
 			}
 			/* Send a chunk to our peer.  */
-			error = sctp_outq_tail(&asoc->outqueue, cmd->obj.chunk);
+			error = sctp_outq_tail(&asoc->outqueue, cmd->obj.chunk,
+					       gfp);
 			break;
 
 		case SCTP_CMD_SEND_PKT:
 			/* Send a full packet to our peer.  */
 			packet = cmd->obj.packet;
-			sctp_packet_transmit(packet);
+			sctp_packet_transmit(packet, gfp);
 			sctp_ootb_pkt_free(packet);
 			break;
 
@@ -1639,7 +1640,7 @@ static int sctp_cmd_interpreter(sctp_event_t event_type,
 			 */
 			chunk->pdiscard = 1;
 			if (asoc) {
-				sctp_outq_uncork(&asoc->outqueue);
+				sctp_outq_uncork(&asoc->outqueue, gfp);
 				local_cork = 0;
 			}
 			break;
@@ -1677,7 +1678,7 @@ static int sctp_cmd_interpreter(sctp_event_t event_type,
 		case SCTP_CMD_FORCE_PRIM_RETRAN:
 			t = asoc->peer.retran_path;
 			asoc->peer.retran_path = asoc->peer.primary_path;
-			error = sctp_outq_uncork(&asoc->outqueue);
+			error = sctp_outq_uncork(&asoc->outqueue, gfp);
 			local_cork = 0;
 			asoc->peer.retran_path = t;
 			break;
@@ -1704,7 +1705,7 @@ static int sctp_cmd_interpreter(sctp_event_t event_type,
 				sctp_outq_cork(&asoc->outqueue);
 				local_cork = 1;
 			}
-			error = sctp_cmd_send_msg(asoc, cmd->obj.msg);
+			error = sctp_cmd_send_msg(asoc, cmd->obj.msg, gfp);
 			break;
 		case SCTP_CMD_SEND_NEXT_ASCONF:
 			sctp_cmd_send_asconf(asoc);
@@ -1734,9 +1735,9 @@ out:
 	 */
 	if (asoc && SCTP_EVENT_T_CHUNK == event_type && chunk) {
 		if (chunk->end_of_packet || chunk->singleton)
-			error = sctp_outq_uncork(&asoc->outqueue);
+			error = sctp_outq_uncork(&asoc->outqueue, gfp);
 	} else if (local_cork)
-		error = sctp_outq_uncork(&asoc->outqueue);
+		error = sctp_outq_uncork(&asoc->outqueue, gfp);
 	return error;
 nomem:
 	error = -ENOMEM;
-- 
2.5.0
