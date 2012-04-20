From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 04/16] tipc: Update node-scope publications when network address is assigned
Date: Fri, 20 Apr 2012 17:05:12 -0400
Message-ID: <1334955924-907-5-git-send-email-paul.gortmaker@windriver.com>
References: <1334955924-907-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <allan.stephens@windriver.com>,
	<ying.xue@windriver.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:62190 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753856Ab2DTVFb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Apr 2012 17:05:31 -0400
In-Reply-To: <1334955924-907-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Ensures that node-scope name publications that exist prior to the
configuration of a node's network address are properly re-initialized
with that address when it is assigned. TIPC's node-scope publications
are now tracked using a publications list like the lists used for
cluster-scope and zone-scope publications so they can be easily updated
when required.

The inclusion of node scope name publications in a conventional publication
list means that they must now also be withdrawn, just like cluster and zone
scope publications are currently withdrawn.  So some conditional tests on
scope ==/!= TIPC_NODE_SCOPE are inserted/removed accordingly.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/name_distr.c |   14 ++++++++++----
 net/tipc/name_table.c |    5 ++---
 2 files changed, 12 insertions(+), 7 deletions(-)

diff --git a/net/tipc/name_distr.c b/net/tipc/name_distr.c
index 8751ea5..211c172 100644
--- a/net/tipc/name_distr.c
+++ b/net/tipc/name_distr.c
@@ -160,6 +160,9 @@ void tipc_named_publish(struct publication *publ)
 	list_add_tail(&publ->local_list, &publ_lists[publ->scope]->list);
 	publ_lists[publ->scope]->size++;
 
+	if (publ->scope == TIPC_NODE_SCOPE)
+		return;
+
 	buf = named_prepare_buf(PUBLICATION, ITEM_SIZE, 0);
 	if (!buf) {
 		warn("Publication distribution failure\n");
@@ -183,6 +186,9 @@ void tipc_named_withdraw(struct publication *publ)
 	list_del(&publ->local_list);
 	publ_lists[publ->scope]->size--;
 
+	if (publ->scope == TIPC_NODE_SCOPE)
+		return;
+
 	buf = named_prepare_buf(WITHDRAWAL, ITEM_SIZE, 0);
 	if (!buf) {
 		warn("Withdrawal distribution failure\n");
@@ -349,11 +355,11 @@ void tipc_named_recv(struct sk_buff *buf)
 }
 
 /**
- * tipc_named_reinit - re-initialize local publication list
+ * tipc_named_reinit - re-initialize local publications
  *
  * This routine is called whenever TIPC networking is enabled.
- * All existing publications by this node that have "cluster" or "zone" scope
- * are updated to reflect the node's new network address.
+ * All name table entries published by this node are updated to reflect
+ * the node's new network address.
  */
 
 void tipc_named_reinit(void)
@@ -363,7 +369,7 @@ void tipc_named_reinit(void)
 
 	write_lock_bh(&tipc_nametbl_lock);
 
-	for (scope = TIPC_ZONE_SCOPE; scope <= TIPC_CLUSTER_SCOPE; scope++)
+	for (scope = TIPC_ZONE_SCOPE; scope <= TIPC_NODE_SCOPE; scope++)
 		list_for_each_entry(publ, &publ_lists[scope]->list, local_list)
 			publ->node = tipc_own_addr;
 
diff --git a/net/tipc/name_table.c b/net/tipc/name_table.c
index c6a1ae3..bd80d80 100644
--- a/net/tipc/name_table.c
+++ b/net/tipc/name_table.c
@@ -698,7 +698,7 @@ struct publication *tipc_nametbl_publish(u32 type, u32 lower, u32 upper,
 	table.local_publ_count++;
 	publ = tipc_nametbl_insert_publ(type, lower, upper, scope,
 				   tipc_own_addr, port_ref, key);
-	if (publ && (scope != TIPC_NODE_SCOPE))
+	if (likely(publ))
 		tipc_named_publish(publ);
 	write_unlock_bh(&tipc_nametbl_lock);
 	return publ;
@@ -716,8 +716,7 @@ int tipc_nametbl_withdraw(u32 type, u32 lower, u32 ref, u32 key)
 	publ = tipc_nametbl_remove_publ(type, lower, tipc_own_addr, ref, key);
 	if (likely(publ)) {
 		table.local_publ_count--;
-		if (publ->scope != TIPC_NODE_SCOPE)
-			tipc_named_withdraw(publ);
+		tipc_named_withdraw(publ);
 		write_unlock_bh(&tipc_nametbl_lock);
 		list_del_init(&publ->pport_list);
 		kfree(publ);
-- 
1.7.9.3
