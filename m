From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 04/13] tipc: make link mtu easily accessible from socket
Date: Wed, 25 Jun 2014 20:41:33 -0500
Message-ID: <1403746902-20408-5-git-send-email-jon.maloy@ericsson.com>
References: <1403746902-20408-1-git-send-email-jon.maloy@ericsson.com>
Cc: netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	erik.hugne@ericsson.com, ying.xue@windriver.com, maloy@donjonn.com,
	tipc-discussion@lists.sourceforge.net,
	Jon Maloy <jon.maloy@ericsson.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp105.biz.mail.ne1.yahoo.com ([98.138.207.12]:24143 "HELO
	smtp105.biz.mail.ne1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1756874AbaFZBsv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jun 2014 21:48:51 -0400
In-Reply-To: <1403746902-20408-1-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Message fragmentation is currently performed at link level, inside
the protection of node_lock. This potentially binds up the sending
link structure for a long time, instead of letting it do other tasks,
such as handle reception of new packets.

In this commit, we make the MTUs of each active link become easily
accessible from the socket level, i.e., without taking any spinlock
or dereferencing the target link pointer. This way, we make it possible
to perform fragmentation in the sending socket, before sending the
whole fragment chain to the link for transport.

Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
Reviewed-by: Ying Xue <ying.xue@windriver.com>
---
 net/tipc/node.c |   25 +++++++++++++++++++++----
 net/tipc/node.h |   17 +++++++++++++++++
 2 files changed, 38 insertions(+), 4 deletions(-)

diff --git a/net/tipc/node.c b/net/tipc/node.c
index 5b44c30..d959343 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -1,7 +1,7 @@
 /*
  * net/tipc/node.c: TIPC node management routines
  *
- * Copyright (c) 2000-2006, 2012 Ericsson AB
+ * Copyright (c) 2000-2006, 2012-2014, Ericsson AB
  * Copyright (c) 2005-2006, 2010-2014, Wind River Systems
  * All rights reserved.
  *
@@ -155,21 +155,25 @@ void tipc_node_link_up(struct tipc_node *n_ptr, struct tipc_link *l_ptr)
 	if (!active[0]) {
 		active[0] = active[1] = l_ptr;
 		node_established_contact(n_ptr);
-		return;
+		goto exit;
 	}
 	if (l_ptr->priority < active[0]->priority) {
 		pr_info("New link <%s> becomes standby\n", l_ptr->name);
-		return;
+		goto exit;
 	}
 	tipc_link_dup_queue_xmit(active[0], l_ptr);
 	if (l_ptr->priority == active[0]->priority) {
 		active[0] = l_ptr;
-		return;
+		goto exit;
 	}
 	pr_info("Old link <%s> becomes standby\n", active[0]->name);
 	if (active[1] != active[0])
 		pr_info("Old link <%s> becomes standby\n", active[1]->name);
 	active[0] = active[1] = l_ptr;
+exit:
+	/* Leave room for changeover header when returning 'mtu' to users: */
+	n_ptr->act_mtus[0] = active[0]->max_pkt - INT_H_SIZE;
+	n_ptr->act_mtus[1] = active[1]->max_pkt - INT_H_SIZE;
 }
 
 /**
@@ -229,6 +233,19 @@ void tipc_node_link_down(struct tipc_node *n_ptr, struct tipc_link *l_ptr)
 		tipc_link_failover_send_queue(l_ptr);
 	else
 		node_lost_contact(n_ptr);
+
+	/* Leave room for changeover header when returning 'mtu' to users: */
+	if (active[0]) {
+		n_ptr->act_mtus[0] = active[0]->max_pkt - INT_H_SIZE;
+		n_ptr->act_mtus[1] = active[1]->max_pkt - INT_H_SIZE;
+		return;
+	}
+
+	/* Loopback link went down? No fragmentation needed from now on. */
+	if (n_ptr->addr == tipc_own_addr) {
+		n_ptr->act_mtus[0] = MAX_MSG_SIZE;
+		n_ptr->act_mtus[1] = MAX_MSG_SIZE;
+	}
 }
 
 int tipc_node_active_links(struct tipc_node *n_ptr)
diff --git a/net/tipc/node.h b/net/tipc/node.h
index 9087063..b61716a 100644
--- a/net/tipc/node.h
+++ b/net/tipc/node.h
@@ -41,6 +41,7 @@
 #include "addr.h"
 #include "net.h"
 #include "bearer.h"
+#include "msg.h"
 
 /*
  * Out-of-range value for node signature
@@ -105,6 +106,7 @@ struct tipc_node {
 	spinlock_t lock;
 	struct hlist_node hash;
 	struct tipc_link *active_links[2];
+	u32 act_mtus[2];
 	struct tipc_link *links[MAX_BEARERS];
 	unsigned int action_flags;
 	struct tipc_node_bclink bclink;
@@ -143,4 +145,19 @@ static inline bool tipc_node_blocked(struct tipc_node *node)
 		TIPC_NOTIFY_NODE_DOWN | TIPC_WAIT_OWN_LINKS_DOWN));
 }
 
+static inline uint tipc_node_get_mtu(u32 addr, u32 selector)
+{
+	struct tipc_node *node;
+	u32 mtu;
+
+	node = tipc_node_find(addr);
+
+	if (likely(node))
+		mtu = node->act_mtus[selector & 1];
+	else
+		mtu = MAX_MSG_SIZE;
+
+	return mtu;
+}
+
 #endif
-- 
1.7.9.5
