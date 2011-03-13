From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 11/26] tipc: manually inline net_start/stop, make assoc. vars static
Date: Sun, 13 Mar 2011 17:33:59 -0400
Message-ID: <1300052054-7531-12-git-send-email-paul.gortmaker@windriver.com>
References: <1300052054-7531-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, Allan.Stephens@windriver.com,
	Allan Stephens <allan.stephens@windriver.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:49893 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755951Ab1CMVeo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Mar 2011 17:34:44 -0400
In-Reply-To: <1300052054-7531-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Relocates network-related variables into the subsystem files where
they are now primarily used (following the recent rework of TIPC's
node table), and converts globals into locals where possible. Changes
the initialization of tipc_num_links from run-time to compile-time,
and eliminates the net_start routine that becomes empty as a result.
Also eliminates the corresponding net_stop routine by moving its
(trivial) content into the one location that called the routine.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/net.c  |   25 ++++---------------------
 net/tipc/net.h  |    2 --
 net/tipc/node.c |    2 ++
 3 files changed, 6 insertions(+), 23 deletions(-)

diff --git a/net/tipc/net.c b/net/tipc/net.c
index cce8d08..8fbc7e6 100644
--- a/net/tipc/net.c
+++ b/net/tipc/net.c
@@ -109,22 +109,6 @@
 */
 
 DEFINE_RWLOCK(tipc_net_lock);
-atomic_t tipc_num_links;
-
-static int net_start(void)
-{
-	atomic_set(&tipc_num_links, 0);
-
-	return 0;
-}
-
-static void net_stop(void)
-{
-	struct tipc_node *node, *t_node;
-
-	list_for_each_entry_safe(node, t_node, &tipc_node_list, list)
-		tipc_node_delete(node);
-}
 
 static void net_route_named_msg(struct sk_buff *buf)
 {
@@ -214,9 +198,6 @@ int tipc_net_start(u32 addr)
 	tipc_named_reinit();
 	tipc_port_reinit();
 
-	res = net_start();
-	if (res)
-		return res;
 	res = tipc_bclink_init();
 	if (res)
 		return res;
@@ -232,14 +213,16 @@ int tipc_net_start(u32 addr)
 
 void tipc_net_stop(void)
 {
+	struct tipc_node *node, *t_node;
+
 	if (tipc_mode != TIPC_NET_MODE)
 		return;
 	write_lock_bh(&tipc_net_lock);
 	tipc_bearer_stop();
 	tipc_mode = TIPC_NODE_MODE;
 	tipc_bclink_stop();
-	net_stop();
+	list_for_each_entry_safe(node, t_node, &tipc_node_list, list);
+		tipc_node_delete(node);
 	write_unlock_bh(&tipc_net_lock);
 	info("Left network mode\n");
 }
-
diff --git a/net/tipc/net.h b/net/tipc/net.h
index 0ba6093..9eb4b9e 100644
--- a/net/tipc/net.h
+++ b/net/tipc/net.h
@@ -37,8 +37,6 @@
 #ifndef _TIPC_NET_H
 #define _TIPC_NET_H
 
-extern atomic_t tipc_num_links;
-
 extern rwlock_t tipc_net_lock;
 
 void tipc_net_route_msg(struct sk_buff *buf);
diff --git a/net/tipc/node.c b/net/tipc/node.c
index 22aeb2b..66099cb 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -47,6 +47,8 @@ static DEFINE_SPINLOCK(node_create_lock);
 static struct hlist_head node_htable[NODE_HTABLE_SIZE];
 LIST_HEAD(tipc_node_list);
 static u32 tipc_num_nodes;
+
+static atomic_t tipc_num_links = ATOMIC_INIT(0);
 u32 tipc_own_tag;
 
 /**
-- 
1.7.3.3

