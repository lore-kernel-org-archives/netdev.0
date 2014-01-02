From: Vlad Yasevich <vyasevich@gmail.com>
Subject: [PATCH net] sctp: Remove outqueue empty state
Date: Thu,  2 Jan 2014 14:39:44 -0500
Message-ID: <1388691584-11211-1-git-send-email-vyasevich@gmail.com>
Cc: nhorman@tuxdriver.com, jhs@mojatatu.com,
	Vlad Yasevich <vyasevich@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f171.google.com ([209.85.216.171]:46067 "EHLO
	mail-qc0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750814AbaABTj6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jan 2014 14:39:58 -0500
Received: by mail-qc0-f171.google.com with SMTP id c9so14124050qcz.30
        for <netdev@vger.kernel.org>; Thu, 02 Jan 2014 11:39:58 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The SCTP outqueue structure maintains a data chunks
that are pending transmission, the list of chunks that
are pending a retransmission and a length of data in
flight.  It also tries to keep the emtpy state so that
it can performe shutdown sequence or notify user.

The problem is that the empy state is inconsistently
tracked.  It is possible to completely drain the queue
without sending anything when using PR-SCTP.  In this
case, the empty state will not be correctly state as
report by Jamal Hadi Salim <jhs@mojatatu.com>.  This
can cause an association to be perminantly stuck in the
SHUTDOWN_PENDING state.

Additionally, SCTP is incredibly inefficient when setting
the empty state.  Even though all the data is availaible
in the outqueue structure, we ignore it and walk a list
of trasnports.

In the end, we can completely remove the extra empty
state and figure out if the queue is empty by looking
at 3 things:  length of pending data, length of in-flight
data, and exisiting of retransmit data.  All of these
are already in the strucutre.

Reported-by: Jamal Hadi Salim <jhs@mojatatu.com>
Signed-off-by: Vlad Yasevich <vyasevich@gmail.com>
---
 include/net/sctp/structs.h |  3 ---
 net/sctp/outqueue.c        | 32 +++++++-------------------------
 2 files changed, 7 insertions(+), 28 deletions(-)

diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index 67b5d00..0a248b3 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -1046,9 +1046,6 @@ struct sctp_outq {
 
 	/* Corked? */
 	char cork;
-
-	/* Is this structure empty?  */
-	char empty;
 };
 
 void sctp_outq_init(struct sctp_association *, struct sctp_outq *);
diff --git a/net/sctp/outqueue.c b/net/sctp/outqueue.c
index f51ba98..9ba3b82 100644
--- a/net/sctp/outqueue.c
+++ b/net/sctp/outqueue.c
@@ -208,8 +208,6 @@ void sctp_outq_init(struct sctp_association *asoc, struct sctp_outq *q)
 	INIT_LIST_HEAD(&q->retransmit);
 	INIT_LIST_HEAD(&q->sacked);
 	INIT_LIST_HEAD(&q->abandoned);
-
-	q->empty = 1;
 }
 
 /* Free the outqueue structure and any related pending chunks.
@@ -332,7 +330,6 @@ int sctp_outq_tail(struct sctp_outq *q, struct sctp_chunk *chunk)
 				SCTP_INC_STATS(net, SCTP_MIB_OUTUNORDERCHUNKS);
 			else
 				SCTP_INC_STATS(net, SCTP_MIB_OUTORDERCHUNKS);
-			q->empty = 0;
 			break;
 		}
 	} else {
@@ -654,7 +651,6 @@ redo:
 			if (chunk->fast_retransmit == SCTP_NEED_FRTX)
 				chunk->fast_retransmit = SCTP_DONT_FRTX;
 
-			q->empty = 0;
 			q->asoc->stats.rtxchunks++;
 			break;
 		}
@@ -1065,8 +1061,6 @@ static int sctp_outq_flush(struct sctp_outq *q, int rtx_timeout)
 
 			sctp_transport_reset_timers(transport);
 
-			q->empty = 0;
-
 			/* Only let one DATA chunk get bundled with a
 			 * COOKIE-ECHO chunk.
 			 */
@@ -1275,29 +1269,17 @@ int sctp_outq_sack(struct sctp_outq *q, struct sctp_chunk *chunk)
 		 "advertised peer ack point:0x%x\n", __func__, asoc, ctsn,
 		 asoc->adv_peer_ack_point);
 
-	/* See if all chunks are acked.
-	 * Make sure the empty queue handler will get run later.
-	 */
-	q->empty = (list_empty(&q->out_chunk_list) &&
-		    list_empty(&q->retransmit));
-	if (!q->empty)
-		goto finish;
-
-	list_for_each_entry(transport, transport_list, transports) {
-		q->empty = q->empty && list_empty(&transport->transmitted);
-		if (!q->empty)
-			goto finish;
-	}
-
-	pr_debug("%s: sack queue is empty\n", __func__);
-finish:
-	return q->empty;
+	return sctp_outq_is_empty(q);
 }
 
-/* Is the outqueue empty?  */
+/* Is the outqueue empty?
+ * The queue is empty when we have not pending data, no in-flight data
+ * and nothing pending retransmissions.
+ */ 
 int sctp_outq_is_empty(const struct sctp_outq *q)
 {
-	return q->empty;
+	return q->out_qlen == 0 && q->outstanding_bytes == 0 &&
+	       list_empty(&q->retransmit);
 }
 
 /********************************************************************
-- 
1.8.4.2
