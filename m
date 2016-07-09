From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net-next 6/6] sctp: implement prsctp PRIO policy
Date: Sat,  9 Jul 2016 19:47:45 +0800
Message-ID: <c570e8ec835bd267843c13acaa84976bbe48d76e.1468064737.git.lucien.xin@gmail.com>
References: <cover.1468064737.git.lucien.xin@gmail.com>
 <121aa41aceff56b3dda51c41b8f3c4d8662d65b7.1468064737.git.lucien.xin@gmail.com>
 <2b9ceacb55912e29c2d970772d0267e465c33dff.1468064737.git.lucien.xin@gmail.com>
 <63a9a850836134ba72b9377e8b99694d869e3fba.1468064737.git.lucien.xin@gmail.com>
 <bb59be49cce6ce873c75e43f1ba8f772dd5eed58.1468064737.git.lucien.xin@gmail.com>
 <fd515720bebb78f127cc0998887cd96cc458b487.1468064737.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	Vlad Yasevich <vyasevich@gmail.com>, daniel@iogearbox.net,
	davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:36556 "EHLO
	mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933054AbcGILsS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Jul 2016 07:48:18 -0400
In-Reply-To: <fd515720bebb78f127cc0998887cd96cc458b487.1468064737.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1468064737.git.lucien.xin@gmail.com>
References: <cover.1468064737.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

prsctp PRIO policy is a policy to abandon lower priority chunks when
asoc doesn't have enough snd buffer, so that the current chunk with
higher priority can be queued successfully.

Similar to TTL/RTX policy, we will set the priority of the chunk to
prsctp_param with sinfo->sinfo_timetolive in sctp_set_prsctp_policy().
So if PRIO policy is enabled, msg->expire_at won't work.

asoc->sent_cnt_removable will record how many chunks can be checked to
remove. If priority policy is enabled, when the chunk is queued into
the out_queue, we will increase sent_cnt_removable. When the chunk is
moved to abandon_queue or dequeue and free, we will decrease
sent_cnt_removable.

In sctp_sendmsg, we will check if there is enough snd buffer for current
msg and if sent_cnt_removable is not 0. Then try to abandon chunks in
sctp_prune_prsctp when sendmsg from the retransmit/transmited queue, and
free chunks from out_queue in right order until the abandon+free size >
msg_len - sctp_wfree. For the abandon size, we have to wait until it
sends FORWARD TSN, receives the sack and the chunks are really freed.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/net/sctp/structs.h |  4 ++
 net/sctp/chunk.c           |  1 +
 net/sctp/outqueue.c        | 99 ++++++++++++++++++++++++++++++++++++++++++++++
 net/sctp/sm_make_chunk.c   |  3 +-
 net/sctp/socket.c          |  3 ++
 5 files changed, 109 insertions(+), 1 deletion(-)

diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index 6bcda71..8626bdd 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -1084,6 +1084,8 @@ void sctp_retransmit(struct sctp_outq *, struct sctp_transport *,
 		     sctp_retransmit_reason_t);
 void sctp_retransmit_mark(struct sctp_outq *, struct sctp_transport *, __u8);
 int sctp_outq_uncork(struct sctp_outq *, gfp_t gfp);
+void sctp_prsctp_prune(struct sctp_association *asoc,
+		       struct sctp_sndrcvinfo *sinfo, int msg_len);
 /* Uncork and flush an outqueue.  */
 static inline void sctp_outq_cork(struct sctp_outq *q)
 {
@@ -1864,6 +1866,8 @@ struct sctp_association {
 
 	struct sctp_priv_assoc_stats stats;
 
+	int sent_cnt_removable;
+
 	__u64 abandoned_unsent[SCTP_PR_INDEX(MAX) + 1];
 	__u64 abandoned_sent[SCTP_PR_INDEX(MAX) + 1];
 };
diff --git a/net/sctp/chunk.c b/net/sctp/chunk.c
index b3692b5..a55e547 100644
--- a/net/sctp/chunk.c
+++ b/net/sctp/chunk.c
@@ -360,6 +360,7 @@ int sctp_chunk_abandoned(struct sctp_chunk *chunk)
 		chunk->asoc->abandoned_sent[SCTP_PR_INDEX(RTX)]++;
 		return 1;
 	}
+	/* PRIO policy is processed by sendmsg, not here */
 
 	return 0;
 }
diff --git a/net/sctp/outqueue.c b/net/sctp/outqueue.c
index 084718f..72e54a4 100644
--- a/net/sctp/outqueue.c
+++ b/net/sctp/outqueue.c
@@ -326,6 +326,9 @@ int sctp_outq_tail(struct sctp_outq *q, struct sctp_chunk *chunk, gfp_t gfp)
 
 			sctp_chunk_hold(chunk);
 			sctp_outq_tail_data(q, chunk);
+			if (chunk->asoc->prsctp_enable &&
+			    SCTP_PR_PRIO_ENABLED(chunk->sinfo.sinfo_flags))
+				chunk->asoc->sent_cnt_removable++;
 			if (chunk->chunk_hdr->flags & SCTP_DATA_UNORDERED)
 				SCTP_INC_STATS(net, SCTP_MIB_OUTUNORDERCHUNKS);
 			else
@@ -372,6 +375,96 @@ static void sctp_insert_list(struct list_head *head, struct list_head *new)
 		list_add_tail(new, head);
 }
 
+static int sctp_prsctp_prune_sent(struct sctp_association *asoc,
+				  struct sctp_sndrcvinfo *sinfo,
+				  struct list_head *queue, int msg_len)
+{
+	struct sctp_chunk *chk, *temp;
+
+	list_for_each_entry_safe(chk, temp, queue, transmitted_list) {
+		if (!SCTP_PR_PRIO_ENABLED(chk->sinfo.sinfo_flags) ||
+		    chk->prsctp_param <= sinfo->sinfo_timetolive)
+			continue;
+
+		list_del_init(&chk->transmitted_list);
+		sctp_insert_list(&asoc->outqueue.abandoned,
+				 &chk->transmitted_list);
+
+		asoc->sent_cnt_removable--;
+		asoc->abandoned_sent[SCTP_PR_INDEX(PRIO)]++;
+
+		if (!chk->tsn_gap_acked) {
+			if (chk->transport)
+				chk->transport->flight_size -=
+						sctp_data_size(chk);
+			asoc->outqueue.outstanding_bytes -= sctp_data_size(chk);
+		}
+
+		msg_len -= SCTP_DATA_SNDSIZE(chk) +
+			   sizeof(struct sk_buff) +
+			   sizeof(struct sctp_chunk);
+		if (msg_len <= 0)
+			break;
+	}
+
+	return msg_len;
+}
+
+static int sctp_prsctp_prune_unsent(struct sctp_association *asoc,
+				    struct sctp_sndrcvinfo *sinfo,
+				    struct list_head *queue, int msg_len)
+{
+	struct sctp_chunk *chk, *temp;
+
+	list_for_each_entry_safe(chk, temp, queue, list) {
+		if (!SCTP_PR_PRIO_ENABLED(chk->sinfo.sinfo_flags) ||
+		    chk->prsctp_param <= sinfo->sinfo_timetolive)
+			continue;
+
+		list_del_init(&chk->list);
+		asoc->sent_cnt_removable--;
+		asoc->abandoned_unsent[SCTP_PR_INDEX(PRIO)]++;
+
+		msg_len -= SCTP_DATA_SNDSIZE(chk) +
+			   sizeof(struct sk_buff) +
+			   sizeof(struct sctp_chunk);
+		sctp_chunk_free(chk);
+		if (msg_len <= 0)
+			break;
+	}
+
+	return msg_len;
+}
+
+/* Abandon the chunks according their priorities */
+void sctp_prsctp_prune(struct sctp_association *asoc,
+		       struct sctp_sndrcvinfo *sinfo, int msg_len)
+{
+	struct sctp_transport *transport;
+
+	if (!asoc->prsctp_enable || !asoc->sent_cnt_removable)
+		return;
+
+	msg_len = sctp_prsctp_prune_sent(asoc, sinfo,
+					 &asoc->outqueue.retransmit,
+					 msg_len);
+	if (msg_len <= 0)
+		return;
+
+	list_for_each_entry(transport, &asoc->peer.transport_addr_list,
+			    transports) {
+		msg_len = sctp_prsctp_prune_sent(asoc, sinfo,
+						 &transport->transmitted,
+						 msg_len);
+		if (msg_len <= 0)
+			return;
+	}
+
+	sctp_prsctp_prune_unsent(asoc, sinfo,
+				 &asoc->outqueue.out_chunk_list,
+				 msg_len);
+}
+
 /* Mark all the eligible packets on a transport for retransmission.  */
 void sctp_retransmit_mark(struct sctp_outq *q,
 			  struct sctp_transport *transport,
@@ -962,6 +1055,9 @@ static int sctp_outq_flush(struct sctp_outq *q, int rtx_timeout, gfp_t gfp)
 
 				/* Mark as failed send. */
 				sctp_chunk_fail(chunk, SCTP_ERROR_INV_STRM);
+				if (asoc->prsctp_enable &&
+				    SCTP_PR_PRIO_ENABLED(chunk->sinfo.sinfo_flags))
+					asoc->sent_cnt_removable--;
 				sctp_chunk_free(chunk);
 				continue;
 			}
@@ -1251,6 +1347,9 @@ int sctp_outq_sack(struct sctp_outq *q, struct sctp_chunk *chunk)
 		tsn = ntohl(tchunk->subh.data_hdr->tsn);
 		if (TSN_lte(tsn, ctsn)) {
 			list_del_init(&tchunk->transmitted_list);
+			if (asoc->prsctp_enable &&
+			    SCTP_PR_PRIO_ENABLED(chunk->sinfo.sinfo_flags))
+				asoc->sent_cnt_removable--;
 			sctp_chunk_free(tchunk);
 		}
 	}
diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index cfde934..1c96f47 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -720,7 +720,8 @@ static void sctp_set_prsctp_policy(struct sctp_chunk *chunk,
 	if (SCTP_PR_TTL_ENABLED(sinfo->sinfo_flags))
 		chunk->prsctp_param =
 			jiffies + msecs_to_jiffies(sinfo->sinfo_timetolive);
-	else if (SCTP_PR_RTX_ENABLED(sinfo->sinfo_flags))
+	else if (SCTP_PR_RTX_ENABLED(sinfo->sinfo_flags) ||
+		 SCTP_PR_PRIO_ENABLED(sinfo->sinfo_flags))
 		chunk->prsctp_param = sinfo->sinfo_timetolive;
 }
 
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 0861429..71c7dc5 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -1914,6 +1914,9 @@ static int sctp_sendmsg(struct sock *sk, struct msghdr *msg, size_t msg_len)
 		goto out_free;
 	}
 
+	if (sctp_wspace(asoc) < msg_len)
+		sctp_prsctp_prune(asoc, sinfo, msg_len - sctp_wspace(asoc));
+
 	timeo = sock_sndtimeo(sk, msg->msg_flags & MSG_DONTWAIT);
 	if (!sctp_wspace(asoc)) {
 		err = sctp_wait_for_sndbuf(asoc, &timeo, msg_len);
-- 
2.1.0
