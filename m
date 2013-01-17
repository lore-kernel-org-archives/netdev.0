From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCH] sctp: refactor sctp_outq_teardown to insure proper re-initalization
Date: Thu, 17 Jan 2013 16:15:08 -0500
Message-ID: <1358457308-6407-1-git-send-email-nhorman@tuxdriver.com>
Cc: Neil Horman <nhorman@tuxdriver.com>,
	Jamie Parsons <Jamie.Parsons@metaswitch.com>,
	Vlad Yasevich <vyasevich@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:41276 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754663Ab3AQVPl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jan 2013 16:15:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jamie Parsons reported a problem recently, in which the re-initalization of an
association (The duplicate init case), resulted in a loss of receive window
space.  He tracked down the root cause to sctp_outq_teardown, which discarded
all the data on an outq during a re-initalization of the corresponding
association, but never reset the outq->outstanding_data field to zero.  I wrote,
and he tested this fix, which does a proper full re-initalization of the outq,
fixing this problem, and hopefully future proofing us from simmilar issues down
the road.

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
Reported-by: Jamie Parsons <Jamie.Parsons@metaswitch.com>
Tested-by: Jamie Parsons <Jamie.Parsons@metaswitch.com>
CC: Jamie Parsons <Jamie.Parsons@metaswitch.com>
CC: Vlad Yasevich <vyasevich@gmail.com>
CC: "David S. Miller" <davem@davemloft.net>
CC: netdev@vger.kernel.org
---
 net/sctp/outqueue.c | 12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

diff --git a/net/sctp/outqueue.c b/net/sctp/outqueue.c
index 379c81d..9bcdbd0 100644
--- a/net/sctp/outqueue.c
+++ b/net/sctp/outqueue.c
@@ -224,7 +224,7 @@ void sctp_outq_init(struct sctp_association *asoc, struct sctp_outq *q)
 
 /* Free the outqueue structure and any related pending chunks.
  */
-void sctp_outq_teardown(struct sctp_outq *q)
+static void __sctp_outq_teardown(struct sctp_outq *q)
 {
 	struct sctp_transport *transport;
 	struct list_head *lchunk, *temp;
@@ -277,8 +277,6 @@ void sctp_outq_teardown(struct sctp_outq *q)
 		sctp_chunk_free(chunk);
 	}
 
-	q->error = 0;
-
 	/* Throw away any leftover control chunks. */
 	list_for_each_entry_safe(chunk, tmp, &q->control_chunk_list, list) {
 		list_del_init(&chunk->list);
@@ -286,11 +284,17 @@ void sctp_outq_teardown(struct sctp_outq *q)
 	}
 }
 
+void sctp_outq_teardown(struct sctp_outq *q)
+{
+	__sctp_outq_teardown(q);
+	sctp_outq_init(q->asoc, q);
+}
+
 /* Free the outqueue structure and any related pending chunks.  */
 void sctp_outq_free(struct sctp_outq *q)
 {
 	/* Throw away leftover chunks. */
-	sctp_outq_teardown(q);
+	__sctp_outq_teardown(q);
 
 	/* If we were kmalloc()'d, free the memory.  */
 	if (q->malloced)
-- 
1.7.11.7
