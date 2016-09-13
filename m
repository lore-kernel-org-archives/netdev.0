From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCHv2 net 1/6] sctp: remove the unnecessary state check in sctp_outq_tail
Date: Wed, 14 Sep 2016 02:04:18 +0800
Message-ID: <4f21a8880a3f8e7daed8a53f10649a1d4dfbb12a.1473789537.git.lucien.xin@gmail.com>
References: <cover.1473789537.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Vlad Yasevich <vyasevich@gmail.com>, daniel@iogearbox.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f65.google.com ([209.85.220.65]:34824 "EHLO
        mail-pa0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752439AbcIMSEi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Sep 2016 14:04:38 -0400
In-Reply-To: <cover.1473789537.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1473789537.git.lucien.xin@gmail.com>
References: <cover.1473789537.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Data Chunks are only sent by sctp_primitive_SEND, in which sctp checks
the asoc's state through statetable before calling sctp_outq_tail. So
there's no need to check the asoc's state again in sctp_outq_tail.

Besides, sctp_do_sm is protected by lock_sock, even if sending msg is
interrupted by timer events, the event's processes still need to acquire
lock_sock first. It means no others CMDs can be enqueue into side effect
list before CMD_SEND_MSG to change asoc->state, so it's safe to remove it.

This patch is to remove redundant asoc->state check from sctp_outq_tail.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 net/sctp/outqueue.c | 53 ++++++++++++++---------------------------------------
 1 file changed, 14 insertions(+), 39 deletions(-)

diff --git a/net/sctp/outqueue.c b/net/sctp/outqueue.c
index 72e54a4..da2418b 100644
--- a/net/sctp/outqueue.c
+++ b/net/sctp/outqueue.c
@@ -299,50 +299,25 @@ int sctp_outq_tail(struct sctp_outq *q, struct sctp_chunk *chunk, gfp_t gfp)
 	 * immediately.
 	 */
 	if (sctp_chunk_is_data(chunk)) {
-		/* Is it OK to queue data chunks?  */
-		/* From 9. Termination of Association
-		 *
-		 * When either endpoint performs a shutdown, the
-		 * association on each peer will stop accepting new
-		 * data from its user and only deliver data in queue
-		 * at the time of sending or receiving the SHUTDOWN
-		 * chunk.
-		 */
-		switch (q->asoc->state) {
-		case SCTP_STATE_CLOSED:
-		case SCTP_STATE_SHUTDOWN_PENDING:
-		case SCTP_STATE_SHUTDOWN_SENT:
-		case SCTP_STATE_SHUTDOWN_RECEIVED:
-		case SCTP_STATE_SHUTDOWN_ACK_SENT:
-			/* Cannot send after transport endpoint shutdown */
-			error = -ESHUTDOWN;
-			break;
-
-		default:
-			pr_debug("%s: outqueueing: outq:%p, chunk:%p[%s])\n",
-				 __func__, q, chunk, chunk && chunk->chunk_hdr ?
-				 sctp_cname(SCTP_ST_CHUNK(chunk->chunk_hdr->type)) :
-				 "illegal chunk");
-
-			sctp_chunk_hold(chunk);
-			sctp_outq_tail_data(q, chunk);
-			if (chunk->asoc->prsctp_enable &&
-			    SCTP_PR_PRIO_ENABLED(chunk->sinfo.sinfo_flags))
-				chunk->asoc->sent_cnt_removable++;
-			if (chunk->chunk_hdr->flags & SCTP_DATA_UNORDERED)
-				SCTP_INC_STATS(net, SCTP_MIB_OUTUNORDERCHUNKS);
-			else
-				SCTP_INC_STATS(net, SCTP_MIB_OUTORDERCHUNKS);
-			break;
-		}
+		pr_debug("%s: outqueueing: outq:%p, chunk:%p[%s])\n",
+			 __func__, q, chunk, chunk && chunk->chunk_hdr ?
+			 sctp_cname(SCTP_ST_CHUNK(chunk->chunk_hdr->type)) :
+			 "illegal chunk");
+
+		sctp_chunk_hold(chunk);
+		sctp_outq_tail_data(q, chunk);
+		if (chunk->asoc->prsctp_enable &&
+		    SCTP_PR_PRIO_ENABLED(chunk->sinfo.sinfo_flags))
+			chunk->asoc->sent_cnt_removable++;
+		if (chunk->chunk_hdr->flags & SCTP_DATA_UNORDERED)
+			SCTP_INC_STATS(net, SCTP_MIB_OUTUNORDERCHUNKS);
+		else
+			SCTP_INC_STATS(net, SCTP_MIB_OUTORDERCHUNKS);
 	} else {
 		list_add_tail(&chunk->list, &q->control_chunk_list);
 		SCTP_INC_STATS(net, SCTP_MIB_OUTCTRLCHUNKS);
 	}
 
-	if (error < 0)
-		return error;
-
 	if (!q->cork)
 		error = sctp_outq_flush(q, 0, gfp);
 
-- 
2.1.0
