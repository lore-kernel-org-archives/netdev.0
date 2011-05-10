From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 17/21] tipc: Introduce routine to enqueue a chain of messages on link tx queue
Date: Tue, 10 May 2011 16:44:33 -0400
Message-ID: <1305060277-15600-18-git-send-email-paul.gortmaker@windriver.com>
References: <1305060277-15600-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, Allan.Stephens@windriver.com,
	Allan Stephens <allan.stephens@windriver.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:52450 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752680Ab1EJUpJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2011 16:45:09 -0400
In-Reply-To: <1305060277-15600-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Create a helper routine to enqueue a chain of sk_buffs to a link's
transmit queue.  It improves readability and the new function is
anticipated to be used more than just once in the future as well.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/link.c |   38 ++++++++++++++++++++++----------------
 1 files changed, 22 insertions(+), 16 deletions(-)

diff --git a/net/tipc/link.c b/net/tipc/link.c
index 4bab139..5ed4b4f 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -843,6 +843,25 @@ static void link_add_to_outqueue(struct link *l_ptr,
 		l_ptr->stats.max_queue_sz = l_ptr->out_queue_size;
 }
 
+static void link_add_chain_to_outqueue(struct link *l_ptr,
+				       struct sk_buff *buf_chain,
+				       u32 long_msgno)
+{
+	struct sk_buff *buf;
+	struct tipc_msg *msg;
+
+	if (!l_ptr->next_out)
+		l_ptr->next_out = buf_chain;
+	while (buf_chain) {
+		buf = buf_chain;
+		buf_chain = buf_chain->next;
+
+		msg = buf_msg(buf);
+		msg_set_long_msgno(msg, long_msgno);
+		link_add_to_outqueue(l_ptr, buf, msg);
+	}
+}
+
 /*
  * tipc_link_send_buf() is the 'full path' for messages, called from
  * inside TIPC when the 'fast path' in tipc_send_buf
@@ -1276,25 +1295,12 @@ reject:
 						 total_len, TIPC_ERR_NO_NODE);
 	}
 
-	/* Append whole chain to send queue: */
+	/* Append chain of fragments to send queue & send them */
 
-	buf = buf_chain;
 	l_ptr->long_msg_seq_no++;
-	if (!l_ptr->next_out)
-		l_ptr->next_out = buf_chain;
+	link_add_chain_to_outqueue(l_ptr, buf_chain, l_ptr->long_msg_seq_no);
+	l_ptr->stats.sent_fragments += fragm_no;
 	l_ptr->stats.sent_fragmented++;
-	while (buf) {
-		struct sk_buff *next = buf->next;
-		struct tipc_msg *msg = buf_msg(buf);
-
-		l_ptr->stats.sent_fragments++;
-		msg_set_long_msgno(msg, l_ptr->long_msg_seq_no);
-		link_add_to_outqueue(l_ptr, buf, msg);
-		buf = next;
-	}
-
-	/* Send it, if possible: */
-
 	tipc_link_push_queue(l_ptr);
 	tipc_node_unlock(node);
 	return dsz;
-- 
1.7.4.4

