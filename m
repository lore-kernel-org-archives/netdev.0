From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCHv2 net 5/6] sctp: make sctp_outq_flush/tail/uncork return void
Date: Wed, 14 Sep 2016 02:04:22 +0800
Message-ID: <6599cec72f3ff913d3b99e60d5f2014df26915de.1473789537.git.lucien.xin@gmail.com>
References: <cover.1473789537.git.lucien.xin@gmail.com>
 <4f21a8880a3f8e7daed8a53f10649a1d4dfbb12a.1473789537.git.lucien.xin@gmail.com>
 <10622d6256e2c49fa7ec555dec3bd35b47a50b2b.1473789537.git.lucien.xin@gmail.com>
 <6b43f456f94dfcaeabc8071806f0609fed59a595.1473789537.git.lucien.xin@gmail.com>
 <f4f0d53e93368c69f55df9f4aba4da2148fcca7e.1473789537.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Vlad Yasevich <vyasevich@gmail.com>, daniel@iogearbox.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f66.google.com ([209.85.220.66]:34040 "EHLO
        mail-pa0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1759756AbcIMSEt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Sep 2016 14:04:49 -0400
In-Reply-To: <f4f0d53e93368c69f55df9f4aba4da2148fcca7e.1473789537.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1473789537.git.lucien.xin@gmail.com>
References: <cover.1473789537.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sctp_outq_flush return value is meaningless now, this patch is
to make sctp_outq_flush return void, as well as sctp_outq_fail
and sctp_outq_uncork.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/net/sctp/structs.h |  4 ++--
 net/sctp/outqueue.c        | 19 +++++++------------
 net/sctp/sm_sideeffect.c   |  9 ++++-----
 3 files changed, 13 insertions(+), 19 deletions(-)

diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index f61fb7c..8693dc4 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -1077,7 +1077,7 @@ struct sctp_outq {
 void sctp_outq_init(struct sctp_association *, struct sctp_outq *);
 void sctp_outq_teardown(struct sctp_outq *);
 void sctp_outq_free(struct sctp_outq*);
-int sctp_outq_tail(struct sctp_outq *, struct sctp_chunk *chunk, gfp_t);
+void sctp_outq_tail(struct sctp_outq *, struct sctp_chunk *chunk, gfp_t);
 int sctp_outq_sack(struct sctp_outq *, struct sctp_chunk *);
 int sctp_outq_is_empty(const struct sctp_outq *);
 void sctp_outq_restart(struct sctp_outq *);
@@ -1085,7 +1085,7 @@ void sctp_outq_restart(struct sctp_outq *);
 void sctp_retransmit(struct sctp_outq *, struct sctp_transport *,
 		     sctp_retransmit_reason_t);
 void sctp_retransmit_mark(struct sctp_outq *, struct sctp_transport *, __u8);
-int sctp_outq_uncork(struct sctp_outq *, gfp_t gfp);
+void sctp_outq_uncork(struct sctp_outq *, gfp_t gfp);
 void sctp_prsctp_prune(struct sctp_association *asoc,
 		       struct sctp_sndrcvinfo *sinfo, int msg_len);
 /* Uncork and flush an outqueue.  */
diff --git a/net/sctp/outqueue.c b/net/sctp/outqueue.c
index 052a479..8c3f446 100644
--- a/net/sctp/outqueue.c
+++ b/net/sctp/outqueue.c
@@ -68,7 +68,7 @@ static void sctp_mark_missing(struct sctp_outq *q,
 
 static void sctp_generate_fwdtsn(struct sctp_outq *q, __u32 sack_ctsn);
 
-static int sctp_outq_flush(struct sctp_outq *q, int rtx_timeout, gfp_t gfp);
+static void sctp_outq_flush(struct sctp_outq *q, int rtx_timeout, gfp_t gfp);
 
 /* Add data to the front of the queue. */
 static inline void sctp_outq_head_data(struct sctp_outq *q,
@@ -285,10 +285,9 @@ void sctp_outq_free(struct sctp_outq *q)
 }
 
 /* Put a new chunk in an sctp_outq.  */
-int sctp_outq_tail(struct sctp_outq *q, struct sctp_chunk *chunk, gfp_t gfp)
+void sctp_outq_tail(struct sctp_outq *q, struct sctp_chunk *chunk, gfp_t gfp)
 {
 	struct net *net = sock_net(q->asoc->base.sk);
-	int error = 0;
 
 	pr_debug("%s: outq:%p, chunk:%p[%s]\n", __func__, q, chunk,
 		 chunk && chunk->chunk_hdr ?
@@ -318,9 +317,7 @@ int sctp_outq_tail(struct sctp_outq *q, struct sctp_chunk *chunk, gfp_t gfp)
 	}
 
 	if (!q->cork)
-		error = sctp_outq_flush(q, 0, gfp);
-
-	return error;
+		sctp_outq_flush(q, 0, gfp);
 }
 
 /* Insert a chunk into the sorted list based on the TSNs.  The retransmit list
@@ -748,12 +745,12 @@ redo:
 }
 
 /* Cork the outqueue so queued chunks are really queued. */
-int sctp_outq_uncork(struct sctp_outq *q, gfp_t gfp)
+void sctp_outq_uncork(struct sctp_outq *q, gfp_t gfp)
 {
 	if (q->cork)
 		q->cork = 0;
 
-	return sctp_outq_flush(q, 0, gfp);
+	sctp_outq_flush(q, 0, gfp);
 }
 
 
@@ -766,7 +763,7 @@ int sctp_outq_uncork(struct sctp_outq *q, gfp_t gfp)
  * locking concerns must be made.  Today we use the sock lock to protect
  * this function.
  */
-static int sctp_outq_flush(struct sctp_outq *q, int rtx_timeout, gfp_t gfp)
+static void sctp_outq_flush(struct sctp_outq *q, int rtx_timeout, gfp_t gfp)
 {
 	struct sctp_packet *packet;
 	struct sctp_packet singleton;
@@ -891,7 +888,7 @@ static int sctp_outq_flush(struct sctp_outq *q, int rtx_timeout, gfp_t gfp)
 			error = sctp_packet_transmit(&singleton, gfp);
 			if (error < 0) {
 				asoc->base.sk->sk_err = -error;
-				return 0;
+				return;
 			}
 			break;
 
@@ -1175,8 +1172,6 @@ sctp_flush_out:
 		/* Clear the burst limited state, if any */
 		sctp_transport_burst_reset(t);
 	}
-
-	return 0;
 }
 
 /* Update unack_data based on the incoming SACK chunk */
diff --git a/net/sctp/sm_sideeffect.c b/net/sctp/sm_sideeffect.c
index cf6e4f0..c345bf1 100644
--- a/net/sctp/sm_sideeffect.c
+++ b/net/sctp/sm_sideeffect.c
@@ -1421,8 +1421,7 @@ static int sctp_cmd_interpreter(sctp_event_t event_type,
 				local_cork = 1;
 			}
 			/* Send a chunk to our peer.  */
-			error = sctp_outq_tail(&asoc->outqueue, cmd->obj.chunk,
-					       gfp);
+			sctp_outq_tail(&asoc->outqueue, cmd->obj.chunk, gfp);
 			break;
 
 		case SCTP_CMD_SEND_PKT:
@@ -1676,7 +1675,7 @@ static int sctp_cmd_interpreter(sctp_event_t event_type,
 		case SCTP_CMD_FORCE_PRIM_RETRAN:
 			t = asoc->peer.retran_path;
 			asoc->peer.retran_path = asoc->peer.primary_path;
-			error = sctp_outq_uncork(&asoc->outqueue, gfp);
+			sctp_outq_uncork(&asoc->outqueue, gfp);
 			local_cork = 0;
 			asoc->peer.retran_path = t;
 			break;
@@ -1733,9 +1732,9 @@ out:
 	 */
 	if (asoc && SCTP_EVENT_T_CHUNK == event_type && chunk) {
 		if (chunk->end_of_packet || chunk->singleton)
-			error = sctp_outq_uncork(&asoc->outqueue, gfp);
+			sctp_outq_uncork(&asoc->outqueue, gfp);
 	} else if (local_cork)
-		error = sctp_outq_uncork(&asoc->outqueue, gfp);
+		sctp_outq_uncork(&asoc->outqueue, gfp);
 
 	if (sp->data_ready_signalled)
 		sp->data_ready_signalled = 0;
-- 
2.1.0
