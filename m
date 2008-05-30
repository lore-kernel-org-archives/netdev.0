From: Allan Stephens <allan.stephens@windriver.com>
Subject: [PATCH 05/13 net-next-2.6] [TIPC]: Minor optimizations to received message processing
Date: Fri, 30 May 2008 14:20:40 -0400
Message-ID: <1212171648-27122-6-git-send-email-allan.stephens@windriver.com>
References: <1212171648-27122-1-git-send-email-allan.stephens@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:50512 "EHLO mail.wrs.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753052AbYE3SXI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 May 2008 14:23:08 -0400
In-Reply-To: <1212171648-27122-1-git-send-email-allan.stephens@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch enhances TIPC's handler for incoming messages in two
ways:
- the trivial, single-use routine for processing non-sequenced
  messages has been merged into the main handler
- the interface that received a message is now identified without
  having to access and/or modify the associated sk_buff

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
---
 net/tipc/discover.c |    4 ++--
 net/tipc/discover.h |    2 +-
 net/tipc/link.c     |   27 +++++----------------------
 3 files changed, 8 insertions(+), 25 deletions(-)

diff --git a/net/tipc/discover.c b/net/tipc/discover.c
index faeaf06..ada213a 100644
--- a/net/tipc/discover.c
+++ b/net/tipc/discover.c
@@ -156,11 +156,11 @@ static void disc_dupl_alert(struct bearer *b_ptr, u32 node_addr,
 /**
  * tipc_disc_recv_msg - handle incoming link setup message (request or response)
  * @buf: buffer containing message
+ * @b_ptr: bearer that message arrived on
  */
 
-void tipc_disc_recv_msg(struct sk_buff *buf)
+void tipc_disc_recv_msg(struct sk_buff *buf, struct bearer *b_ptr)
 {
-	struct bearer *b_ptr = (struct bearer *)TIPC_SKB_CB(buf)->handle;
 	struct link *link;
 	struct tipc_media_addr media_addr;
 	struct tipc_msg *msg = buf_msg(buf);
diff --git a/net/tipc/discover.h b/net/tipc/discover.h
index 9fd7587..c36eaeb 100644
--- a/net/tipc/discover.h
+++ b/net/tipc/discover.h
@@ -48,7 +48,7 @@ struct link_req *tipc_disc_init_link_req(struct bearer *b_ptr,
 void tipc_disc_update_link_req(struct link_req *req);
 void tipc_disc_stop_link_req(struct link_req *req);
 
-void tipc_disc_recv_msg(struct sk_buff *buf);
+void tipc_disc_recv_msg(struct sk_buff *buf, struct bearer *b_ptr);
 
 void tipc_disc_link_event(u32 addr, char *name, int up);
 #if 0
diff --git a/net/tipc/link.c b/net/tipc/link.c
index b8c1231..c62ebfe 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -1766,21 +1766,6 @@ void tipc_link_retransmit(struct link *l_ptr, struct sk_buff *buf,
 	l_ptr->retransm_queue_head = l_ptr->retransm_queue_size = 0;
 }
 
-/*
- * link_recv_non_seq: Receive packets which are outside
- *                    the link sequence flow
- */
-
-static void link_recv_non_seq(struct sk_buff *buf)
-{
-	struct tipc_msg *msg = buf_msg(buf);
-
-	if (msg_user(msg) ==  LINK_CONFIG)
-		tipc_disc_recv_msg(buf);
-	else
-		tipc_bclink_recv_pkt(buf);
-}
-
 /**
  * link_insert_deferred_queue - insert deferred messages back into receive chain
  */
@@ -1857,7 +1842,7 @@ void tipc_recv_msg(struct sk_buff *head, struct tipc_bearer *tb_ptr)
 {
 	read_lock_bh(&tipc_net_lock);
 	while (head) {
-		struct bearer *b_ptr;
+		struct bearer *b_ptr = (struct bearer *)tb_ptr;
 		struct node *n_ptr;
 		struct link *l_ptr;
 		struct sk_buff *crs;
@@ -1868,9 +1853,6 @@ void tipc_recv_msg(struct sk_buff *head, struct tipc_bearer *tb_ptr)
 		u32 released = 0;
 		int type;
 
-		b_ptr = (struct bearer *)tb_ptr;
-		TIPC_SKB_CB(buf)->handle = b_ptr;
-
 		head = head->next;
 
 		/* Ensure message is well-formed */
@@ -1889,7 +1871,10 @@ void tipc_recv_msg(struct sk_buff *head, struct tipc_bearer *tb_ptr)
 		msg = buf_msg(buf);
 
 		if (unlikely(msg_non_seq(msg))) {
-			link_recv_non_seq(buf);
+			if (msg_user(msg) ==  LINK_CONFIG)
+				tipc_disc_recv_msg(buf, b_ptr);
+			else
+				tipc_bclink_recv_pkt(buf);
 			continue;
 		}
 
@@ -1996,8 +1981,6 @@ deliver:
 						if (link_recv_changeover_msg(&l_ptr, &buf)) {
 							msg = buf_msg(buf);
 							seq_no = msg_seqno(msg);
-							TIPC_SKB_CB(buf)->handle
-								= b_ptr;
 							if (type == ORIGINAL_MSG)
 								goto deliver;
 							goto protocol_check;
-- 
1.5.3.2

