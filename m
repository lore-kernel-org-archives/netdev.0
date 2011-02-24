From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 08/17] tipc: Clean up tracking of node requesting a broadcast retransmit
Date: Wed, 23 Feb 2011 20:26:36 -0500
Message-ID: <1298510805-20630-9-git-send-email-paul.gortmaker@windriver.com>
References: <1298510805-20630-1-git-send-email-paul.gortmaker@windriver.com>
Cc: allan.stephens@windriver.com, netdev@vger.kernel.org,
	Allan Stephens <Allan.Stephens@windriver.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:34505 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932098Ab1BXB1K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Feb 2011 20:27:10 -0500
In-Reply-To: <1298510805-20630-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <Allan.Stephens@windriver.com>

Allows the broadcast link to track the node that is requesting a retransmit
in a new field dedicated to that purpose. This replaces the existing
mechanism that (ab)uses an existing node structure linked list field to do
the tracking.

Signed-off-by: Allan Stephens <Allan.Stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/bcast.c |   16 ++++++++++++++--
 net/tipc/bcast.h |    3 ++-
 net/tipc/link.c  |    2 +-
 3 files changed, 17 insertions(+), 4 deletions(-)

diff --git a/net/tipc/bcast.c b/net/tipc/bcast.c
index b4d659d..a5eb7db 100644
--- a/net/tipc/bcast.c
+++ b/net/tipc/bcast.c
@@ -93,6 +93,7 @@ struct bcbearer {
  * struct bclink - link used for broadcast messages
  * @link: (non-standard) broadcast link structure
  * @node: (non-standard) node structure representing b'cast link's peer node
+ * @retransmit_to: node that most recently requested a retransmit
  *
  * Handles sequence numbering, fragmentation, bundling, etc.
  */
@@ -100,6 +101,7 @@ struct bcbearer {
 struct bclink {
 	struct link link;
 	struct tipc_node node;
+	struct tipc_node *retransmit_to;
 };
 
 
@@ -184,6 +186,17 @@ static int bclink_ack_allowed(u32 n)
 
 
 /**
+ * tipc_bclink_retransmit_to - get most recent node to request retransmission
+ *
+ * Called with bc_lock locked
+ */
+
+struct tipc_node *tipc_bclink_retransmit_to(void)
+{
+	return bclink->retransmit_to;
+}
+
+/**
  * bclink_retransmit_pkt - retransmit broadcast packets
  * @after: sequence number of last packet to *not* retransmit
  * @to: sequence number of last packet to retransmit
@@ -444,10 +457,9 @@ void tipc_bclink_recv_pkt(struct sk_buff *buf)
 			tipc_node_unlock(node);
 			spin_lock_bh(&bc_lock);
 			bcl->stats.recv_nacks++;
-			bcl->owner->next = node;   /* remember requestor */
+			bclink->retransmit_to = node;
 			bclink_retransmit_pkt(msg_bcgap_after(msg),
 					      msg_bcgap_to(msg));
-			bcl->owner->next = NULL;
 			spin_unlock_bh(&bc_lock);
 		} else {
 			tipc_bclink_peek_nack(msg_destnode(msg),
diff --git a/net/tipc/bcast.h b/net/tipc/bcast.h
index 51f8c53..500c97f 100644
--- a/net/tipc/bcast.h
+++ b/net/tipc/bcast.h
@@ -2,7 +2,7 @@
  * net/tipc/bcast.h: Include file for TIPC broadcast code
  *
  * Copyright (c) 2003-2006, Ericsson AB
- * Copyright (c) 2005, Wind River Systems
+ * Copyright (c) 2005, 2010-2011, Wind River Systems
  * All rights reserved.
  *
  * Redistribution and use in source and binary forms, with or without
@@ -90,6 +90,7 @@ void tipc_port_list_free(struct port_list *pl_ptr);
 
 int  tipc_bclink_init(void);
 void tipc_bclink_stop(void);
+struct tipc_node *tipc_bclink_retransmit_to(void);
 void tipc_bclink_acknowledge(struct tipc_node *n_ptr, u32 acked);
 int  tipc_bclink_send_msg(struct sk_buff *buf);
 void tipc_bclink_recv_pkt(struct sk_buff *buf);
diff --git a/net/tipc/link.c b/net/tipc/link.c
index d586265..0cb773b 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -1441,7 +1441,7 @@ static void link_retransmit_failure(struct link *l_ptr, struct sk_buff *buf)
 		info("Outstanding acks: %lu\n",
 		     (unsigned long) TIPC_SKB_CB(buf)->handle);
 
-		n_ptr = l_ptr->owner->next;
+		n_ptr = tipc_bclink_retransmit_to();
 		tipc_node_lock(n_ptr);
 
 		tipc_addr_string_fill(addr_string, n_ptr->addr);
-- 
1.7.3.3

