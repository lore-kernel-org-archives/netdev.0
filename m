From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 1/1] tipc: fix bug in multicast congestion handling
Date: Tue,  7 Oct 2014 12:18:35 -0400
Message-ID: <1412698715-9838-1-git-send-email-jon.maloy@ericsson.com>
Cc: netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	erik.hugne@ericsson.com, ying.xue@windriver.com, maloy@donjonn.com,
	tipc-discussion@lists.sourceforge.net,
	Jon Maloy <jon.maloy@ericsson.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp107.biz.mail.bf1.yahoo.com ([98.139.244.55]:44094 "EHLO
	smtp107.biz.mail.bf1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753915AbaJGQZW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2014 12:25:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

One aim of commit 50100a5e39461b2a61d6040e73c384766c29975d ("tipc:
use pseudo message to wake up sockets after link congestion") was
to handle link congestion abatement in a uniform way for both unicast
and multicast transmit. However, the latter doesn't work correctly,
and has been broken since the referenced commit was applied.

If a user now sends a burst of multicast messages that is big
enough to cause broadcast link congestion, it will be put to sleep,
and not be waked up when the congestion abates as it should be.

This has two reasons. First, the flag that is used, TIPC_WAKEUP_USERS,
is set correctly, but in the wrong field. Instead of setting it in the
'action_flags' field of the arrival node struct, it is by mistake set
in the dummy node struct that is owned by the broadcast link, where it
will never tested for. Second, we cannot use the same flag for waking
up unicast and multicast users, since the function tipc_node_unlock()
needs to pick the wakeup pseudo messages to deliver from different
queues. It must hence be able to distinguish between the two cases.

This commit solves this problem by adding a new flag
TIPC_WAKEUP_BCAST_USERS, and a new function tipc_bclink_wakeup_user().
The latter is to be called by tipc_node_unlock() when the named flag,
now set in the correct field, is encountered.

Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/bcast.c | 14 +++++++++++++-
 net/tipc/bcast.h |  2 +-
 net/tipc/node.c  |  5 +++++
 net/tipc/node.h  |  3 ++-
 4 files changed, 21 insertions(+), 3 deletions(-)

diff --git a/net/tipc/bcast.c b/net/tipc/bcast.c
index b2bbe69..b8670bf 100644
--- a/net/tipc/bcast.c
+++ b/net/tipc/bcast.c
@@ -226,6 +226,17 @@ static void bclink_retransmit_pkt(u32 after, u32 to)
 }
 
 /**
+ * tipc_bclink_wakeup_users - wake up pending users
+ *
+ * Called with no locks taken
+ */
+void tipc_bclink_wakeup_users(void)
+{
+	while (skb_queue_len(&bclink->link.waiting_sks))
+		tipc_sk_rcv(skb_dequeue(&bclink->link.waiting_sks));
+}
+
+/**
  * tipc_bclink_acknowledge - handle acknowledgement of broadcast packets
  * @n_ptr: node that sent acknowledgement info
  * @acked: broadcast sequence # that has been acknowledged
@@ -300,7 +311,8 @@ void tipc_bclink_acknowledge(struct tipc_node *n_ptr, u32 acked)
 		bclink_set_last_sent();
 	}
 	if (unlikely(released && !skb_queue_empty(&bcl->waiting_sks)))
-		bclink->node.action_flags |= TIPC_WAKEUP_USERS;
+		n_ptr->action_flags |= TIPC_WAKEUP_BCAST_USERS;
+
 exit:
 	tipc_bclink_unlock();
 }
diff --git a/net/tipc/bcast.h b/net/tipc/bcast.h
index 4875d95..e7b0f85 100644
--- a/net/tipc/bcast.h
+++ b/net/tipc/bcast.h
@@ -99,5 +99,5 @@ int  tipc_bclink_set_queue_limits(u32 limit);
 void tipc_bcbearer_sort(struct tipc_node_map *nm_ptr, u32 node, bool action);
 uint  tipc_bclink_get_mtu(void);
 int tipc_bclink_xmit(struct sk_buff *buf);
-
+void tipc_bclink_wakeup_users(void);
 #endif
diff --git a/net/tipc/node.c b/net/tipc/node.c
index 17e6378..54950ac 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -552,6 +552,7 @@ void tipc_node_unlock(struct tipc_node *node)
 	LIST_HEAD(conn_sks);
 	struct sk_buff_head waiting_sks;
 	u32 addr = 0;
+	uint flags = node->action_flags;
 
 	if (likely(!node->action_flags)) {
 		spin_unlock_bh(&node->lock);
@@ -572,6 +573,7 @@ void tipc_node_unlock(struct tipc_node *node)
 		node->action_flags &= ~TIPC_NOTIFY_NODE_UP;
 		addr = node->addr;
 	}
+	node->action_flags &= ~TIPC_WAKEUP_BCAST_USERS;
 	spin_unlock_bh(&node->lock);
 
 	while (!skb_queue_empty(&waiting_sks))
@@ -583,6 +585,9 @@ void tipc_node_unlock(struct tipc_node *node)
 	if (!list_empty(&nsub_list))
 		tipc_nodesub_notify(&nsub_list);
 
+	if (flags & TIPC_WAKEUP_BCAST_USERS)
+		tipc_bclink_wakeup_users();
+
 	if (addr)
 		tipc_named_node_up(addr);
 }
diff --git a/net/tipc/node.h b/net/tipc/node.h
index 522d6f3..67513c3 100644
--- a/net/tipc/node.h
+++ b/net/tipc/node.h
@@ -59,7 +59,8 @@ enum {
 	TIPC_WAIT_OWN_LINKS_DOWN	= (1 << 2),
 	TIPC_NOTIFY_NODE_DOWN		= (1 << 3),
 	TIPC_NOTIFY_NODE_UP		= (1 << 4),
-	TIPC_WAKEUP_USERS		= (1 << 5)
+	TIPC_WAKEUP_USERS		= (1 << 5),
+	TIPC_WAKEUP_BCAST_USERS		= (1 << 6)
 };
 
 /**
-- 
1.9.1
