From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 01/15] tipc: improve the link deferred queue insertion algorithm
Date: Mon,  6 Feb 2012 19:52:34 -0500
Message-ID: <1328575968-20643-2-git-send-email-paul.gortmaker@windriver.com>
References: <1328575968-20643-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com,
	ying.xue@windriver.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:50169 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753820Ab2BGAxK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2012 19:53:10 -0500
In-Reply-To: <1328575968-20643-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Re-code the algorithm for inserting an out-of-sequence message into
a unicast or broadcast link's deferred message queue.  It remains
functionally equivalent but should be easier to understand/maintain.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/link.c |   48 +++++++++++++++++++++++-------------------------
 1 files changed, 23 insertions(+), 25 deletions(-)

diff --git a/net/tipc/link.c b/net/tipc/link.c
index ac1832a..c317abf 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -1853,17 +1853,16 @@ cont:
 }
 
 /*
- * link_defer_buf(): Sort a received out-of-sequence packet
- *                   into the deferred reception queue.
- * Returns the increase of the queue length,i.e. 0 or 1
+ * tipc_link_defer_pkt - Add out-of-sequence message to deferred reception queue
+ *
+ * Returns increase in queue length (i.e. 0 or 1)
  */
 
-u32 tipc_link_defer_pkt(struct sk_buff **head,
-			struct sk_buff **tail,
+u32 tipc_link_defer_pkt(struct sk_buff **head, struct sk_buff **tail,
 			struct sk_buff *buf)
 {
-	struct sk_buff *prev = NULL;
-	struct sk_buff *crs = *head;
+	struct sk_buff *queue_buf;
+	struct sk_buff **prev;
 	u32 seq_no = buf_seqno(buf);
 
 	buf->next = NULL;
@@ -1881,31 +1880,30 @@ u32 tipc_link_defer_pkt(struct sk_buff **head,
 		return 1;
 	}
 
-	/* Scan through queue and sort it in */
-	do {
-		struct tipc_msg *msg = buf_msg(crs);
+	/* Locate insertion point in queue, then insert; discard if duplicate */
+	prev = head;
+	queue_buf = *head;
+	for (;;) {
+		u32 curr_seqno = buf_seqno(queue_buf);
 
-		if (less(seq_no, msg_seqno(msg))) {
-			buf->next = crs;
-			if (prev)
-				prev->next = buf;
-			else
-				*head = buf;
-			return 1;
+		if (seq_no == curr_seqno) {
+			buf_discard(buf);
+			return 0;
 		}
-		if (seq_no == msg_seqno(msg))
+
+		if (less(seq_no, curr_seqno))
 			break;
-		prev = crs;
-		crs = crs->next;
-	} while (crs);
 
-	/* Message is a duplicate of an existing message */
+		prev = &queue_buf->next;
+		queue_buf = queue_buf->next;
+	}
 
-	buf_discard(buf);
-	return 0;
+	buf->next = queue_buf;
+	*prev = buf;
+	return 1;
 }
 
-/**
+/*
  * link_handle_out_of_seq_msg - handle arrival of out-of-sequence packet
  */
 
-- 
1.7.9
