From: Antonio Quartulli <a@unstable.cc>
Subject: [PATCH 5/8] batman-adv: Drop immediate batadv_hardif_neigh_node free function
Date: Sun, 17 Jan 2016 13:24:38 +0800
Message-ID: <1453008281-15396-6-git-send-email-a__30880.9001617648$1453008471$gmane$org@unstable.cc>
References: <1453008281-15396-1-git-send-email-a@unstable.cc>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <a@unstable.cc>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s1.neomailbox.net ([5.148.176.57]:28448 "EHLO s1.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751238AbcAQF06 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 17 Jan 2016 00:26:58 -0500
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
have to use batadv_hardif_neigh_free_ref.

Fixes: cef63419f7db ("batman-adv: add list of unique single hop neighbors per hard-interface")
Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <a@unstable.cc>
---
 net/batman-adv/originator.c | 46 +++++++++++++--------------------------------
 1 file changed, 13 insertions(+), 33 deletions(-)

diff --git a/net/batman-adv/originator.c b/net/batman-adv/originator.c
index 78fd4eab2169..0b7ab38e74fc 100644
--- a/net/batman-adv/originator.c
+++ b/net/batman-adv/originator.c
@@ -202,50 +202,30 @@ void batadv_neigh_ifinfo_free_ref(struct batadv_neigh_ifinfo *neigh_ifinfo)
 }
 
 /**
- * batadv_hardif_neigh_free_rcu - free the hardif neigh_node
- * @rcu: rcu pointer of the neigh_node
- */
-static void batadv_hardif_neigh_free_rcu(struct rcu_head *rcu)
-{
-	struct batadv_hardif_neigh_node *hardif_neigh;
-
-	hardif_neigh = container_of(rcu, struct batadv_hardif_neigh_node, rcu);
-
-	batadv_hardif_free_ref_now(hardif_neigh->if_incoming);
-	kfree(hardif_neigh);
-}
-
-/**
- * batadv_hardif_neigh_free_now - decrement the hardif neighbors refcounter
- *  and possibly free it (without rcu callback)
+ * batadv_hardif_neigh_release - release hardif neigh node from lists and
+ *  queue for free after rcu grace period
  * @hardif_neigh: hardif neigh neighbor to free
  */
 static void
-batadv_hardif_neigh_free_now(struct batadv_hardif_neigh_node *hardif_neigh)
+batadv_hardif_neigh_release(struct batadv_hardif_neigh_node *hardif_neigh)
 {
-	if (atomic_dec_and_test(&hardif_neigh->refcount)) {
-		spin_lock_bh(&hardif_neigh->if_incoming->neigh_list_lock);
-		hlist_del_init_rcu(&hardif_neigh->list);
-		spin_unlock_bh(&hardif_neigh->if_incoming->neigh_list_lock);
+	spin_lock_bh(&hardif_neigh->if_incoming->neigh_list_lock);
+	hlist_del_init_rcu(&hardif_neigh->list);
+	spin_unlock_bh(&hardif_neigh->if_incoming->neigh_list_lock);
 
-		batadv_hardif_neigh_free_rcu(&hardif_neigh->rcu);
-	}
+	batadv_hardif_free_ref(hardif_neigh->if_incoming);
+	kfree_rcu(hardif_neigh, rcu);
 }
 
 /**
  * batadv_hardif_neigh_free_ref - decrement the hardif neighbors refcounter
- *  and possibly free it
+ *  and possibly release it
  * @hardif_neigh: hardif neigh neighbor to free
  */
 void batadv_hardif_neigh_free_ref(struct batadv_hardif_neigh_node *hardif_neigh)
 {
-	if (atomic_dec_and_test(&hardif_neigh->refcount)) {
-		spin_lock_bh(&hardif_neigh->if_incoming->neigh_list_lock);
-		hlist_del_init_rcu(&hardif_neigh->list);
-		spin_unlock_bh(&hardif_neigh->if_incoming->neigh_list_lock);
-
-		call_rcu(&hardif_neigh->rcu, batadv_hardif_neigh_free_rcu);
-	}
+	if (atomic_dec_and_test(&hardif_neigh->refcount))
+		batadv_hardif_neigh_release(hardif_neigh);
 }
 
 /**
@@ -272,8 +252,8 @@ static void batadv_neigh_node_free_rcu(struct rcu_head *rcu)
 					       neigh_node->addr);
 	if (hardif_neigh) {
 		/* batadv_hardif_neigh_get() increases refcount too */
-		batadv_hardif_neigh_free_now(hardif_neigh);
-		batadv_hardif_neigh_free_now(hardif_neigh);
+		batadv_hardif_neigh_free_ref(hardif_neigh);
+		batadv_hardif_neigh_free_ref(hardif_neigh);
 	}
 
 	if (bao->bat_neigh_free)
-- 
2.7.0
