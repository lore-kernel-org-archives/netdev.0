From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 04/26] tipc: Prevent null pointer error when removing a node subscription
Date: Sun, 13 Mar 2011 17:33:52 -0400
Message-ID: <1300052054-7531-5-git-send-email-paul.gortmaker@windriver.com>
References: <1300052054-7531-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, Allan.Stephens@windriver.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:49862 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755951Ab1CMVee (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Mar 2011 17:34:34 -0400
In-Reply-To: <1300052054-7531-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <Allan.Stephens@windriver.com>

Prevents a null pointer dereference from occurring if a node subscription
is triggered at the same time that the subscribing port or publication is
terminating the subscription. The problem arises if the triggering routine
asynchronously activates and deregisters the node subscription while
deregistration is already underway -- the deregistration routine may find
that the pointer it has just verified to be non-NULL is now NULL.
To avoid this race condition the triggering routine now simply marks the
node subscription as defunct (to prevent it from re-activating)
instead of deregistering it. The subscription is now both deregistered
and destroyed only when the subscribing port or publication code terminates
the node subscription.

Signed-off-by: Allan Stephens <Allan.Stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/name_distr.c |    5 +++--
 net/tipc/node.c       |   13 +++++++------
 2 files changed, 10 insertions(+), 8 deletions(-)

diff --git a/net/tipc/name_distr.c b/net/tipc/name_distr.c
index 483c226..1d4a18a 100644
--- a/net/tipc/name_distr.c
+++ b/net/tipc/name_distr.c
@@ -2,7 +2,7 @@
  * net/tipc/name_distr.c: TIPC name distribution code
  *
  * Copyright (c) 2000-2006, Ericsson AB
- * Copyright (c) 2005, Wind River Systems
+ * Copyright (c) 2005, 2010-2011, Wind River Systems
  * All rights reserved.
  *
  * Redistribution and use in source and binary forms, with or without
@@ -221,7 +221,6 @@ exit:
  * In rare cases the link may have come back up again when this
  * function is called, and we have two items representing the same
  * publication. Nudge this item's key to distinguish it from the other.
- * (Note: Publication's node subscription is already unsubscribed.)
  */
 
 static void node_is_down(struct publication *publ)
@@ -232,6 +231,8 @@ static void node_is_down(struct publication *publ)
 	publ->key += 1222345;
 	p = tipc_nametbl_remove_publ(publ->type, publ->lower,
 				     publ->node, publ->ref, publ->key);
+	if (p)
+		tipc_nodesub_unsubscribe(&p->subscr);
 	write_unlock_bh(&tipc_nametbl_lock);
 
 	if (p != publ) {
diff --git a/net/tipc/node.c b/net/tipc/node.c
index 14f98c8..8926caa 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -327,7 +327,7 @@ static void node_cleanup_finished(unsigned long node_addr)
 
 static void node_lost_contact(struct tipc_node *n_ptr)
 {
-	struct tipc_node_subscr *ns, *tns;
+	struct tipc_node_subscr *ns;
 	char addr_string[16];
 	u32 i;
 
@@ -365,11 +365,12 @@ static void node_lost_contact(struct tipc_node *n_ptr)
 	}
 
 	/* Notify subscribers */
-	list_for_each_entry_safe(ns, tns, &n_ptr->nsub, nodesub_list) {
-		ns->node = NULL;
-		list_del_init(&ns->nodesub_list);
-		tipc_k_signal((Handler)ns->handle_node_down,
-			      (unsigned long)ns->usr_handle);
+	list_for_each_entry(ns, &n_ptr->nsub, nodesub_list) {
+		if (ns->handle_node_down) {
+			tipc_k_signal((Handler)ns->handle_node_down,
+				      (unsigned long)ns->usr_handle);
+			ns->handle_node_down = NULL;
+		}
 	}
 
 	/* Prevent re-contact with node until all cleanup is done */
-- 
1.7.3.3

