From: Antonio Quartulli <a@unstable.cc>
Subject: [PATCH 8/8] batman-adv: Drop immediate orig_node free function
Date: Sun, 17 Jan 2016 13:24:41 +0800
Message-ID: <1453008281-15396-9-git-send-email-a@unstable.cc>
References: <1453008281-15396-1-git-send-email-a@unstable.cc>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <a@unstable.cc>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s1.neomailbox.net ([5.148.176.57]:39765 "EHLO s1.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751331AbcAQF1I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 17 Jan 2016 00:27:08 -0500
In-Reply-To: <1453008281-15396-1-git-send-email-a@unstable.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

It is not allowed to free the memory of an object which is part of a list
which is protected by rcu-read-side-critical sections without making sure
that no other context is accessing the object anymore. This usually happens
by removing the references to this object and then waiting until the rcu
grace period is over and no one (allowedly) accesses it anymore.

But the _now functions ignore this completely. They free the object
directly even when a different context still tries to access it. This has
to be avoided and thus these functions must be removed and all functions
have to use batadv_orig_node_free_ref.

Fixes: 72822225bd41 ("batman-adv: Fix rcu_barrier() miss due to double call_rcu() in TT code")
Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <a@unstable.cc>
---
 net/batman-adv/originator.c        | 11 -----------
 net/batman-adv/originator.h        |  1 -
 net/batman-adv/translation-table.c | 28 +++++++++++++---------------
 3 files changed, 13 insertions(+), 27 deletions(-)

diff --git a/net/batman-adv/originator.c b/net/batman-adv/originator.c
index 6fdef842ba2a..fe578f75c391 100644
--- a/net/batman-adv/originator.c
+++ b/net/batman-adv/originator.c
@@ -781,17 +781,6 @@ void batadv_orig_node_free_ref(struct batadv_orig_node *orig_node)
 		batadv_orig_node_release(orig_node);
 }
 
-/**
- * batadv_orig_node_free_ref_now - decrement the orig node refcounter and
- * possibly free it (without rcu callback)
- * @orig_node: the orig node to free
- */
-void batadv_orig_node_free_ref_now(struct batadv_orig_node *orig_node)
-{
-	if (atomic_dec_and_test(&orig_node->refcount))
-		batadv_orig_node_free_rcu(&orig_node->rcu);
-}
-
 void batadv_originator_free(struct batadv_priv *bat_priv)
 {
 	struct batadv_hashtable *hash = bat_priv->orig_hash;
diff --git a/net/batman-adv/originator.h b/net/batman-adv/originator.h
index 29557753d552..cf0730414ed2 100644
--- a/net/batman-adv/originator.h
+++ b/net/batman-adv/originator.h
@@ -38,7 +38,6 @@ int batadv_originator_init(struct batadv_priv *bat_priv);
 void batadv_originator_free(struct batadv_priv *bat_priv);
 void batadv_purge_orig_ref(struct batadv_priv *bat_priv);
 void batadv_orig_node_free_ref(struct batadv_orig_node *orig_node);
-void batadv_orig_node_free_ref_now(struct batadv_orig_node *orig_node);
 struct batadv_orig_node *batadv_orig_node_new(struct batadv_priv *bat_priv,
 					      const u8 *addr);
 struct batadv_hardif_neigh_node *
diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index a22080c53401..cdfc85fa2743 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -240,20 +240,6 @@ int batadv_tt_global_hash_count(struct batadv_priv *bat_priv,
 	return count;
 }
 
-static void batadv_tt_orig_list_entry_free_rcu(struct rcu_head *rcu)
-{
-	struct batadv_tt_orig_list_entry *orig_entry;
-
-	orig_entry = container_of(rcu, struct batadv_tt_orig_list_entry, rcu);
-
-	/* We are in an rcu callback here, therefore we cannot use
-	 * batadv_orig_node_free_ref() and its call_rcu():
-	 * An rcu_barrier() wouldn't wait for that to finish
-	 */
-	batadv_orig_node_free_ref_now(orig_entry->orig_node);
-	kfree(orig_entry);
-}
-
 /**
  * batadv_tt_local_size_mod - change the size by v of the local table identified
  *  by vid
@@ -349,13 +335,25 @@ static void batadv_tt_global_size_dec(struct batadv_orig_node *orig_node,
 	batadv_tt_global_size_mod(orig_node, vid, -1);
 }
 
+/**
+ * batadv_tt_orig_list_entry_release - release tt orig entry from lists and
+ *  queue for free after rcu grace period
+ * @orig_entry: tt orig entry to be free'd
+ */
+static void
+batadv_tt_orig_list_entry_release(struct batadv_tt_orig_list_entry *orig_entry)
+{
+	batadv_orig_node_free_ref(orig_entry->orig_node);
+	kfree_rcu(orig_entry, rcu);
+}
+
 static void
 batadv_tt_orig_list_entry_free_ref(struct batadv_tt_orig_list_entry *orig_entry)
 {
 	if (!atomic_dec_and_test(&orig_entry->refcount))
 		return;
 
-	call_rcu(&orig_entry->rcu, batadv_tt_orig_list_entry_free_rcu);
+	batadv_tt_orig_list_entry_release(orig_entry);
 }
 
 /**
-- 
2.7.0
