From: Antonio Quartulli <a@unstable.cc>
Subject: [PATCH 04/21] batman-adv: Convert batadv_hardif_neigh_node to kref
Date: Wed, 10 Feb 2016 23:57:10 +0800
Message-ID: <1455119847-5862-5-git-send-email-a@unstable.cc>
References: <1455119847-5862-1-git-send-email-a@unstable.cc>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <a@unstable.cc>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s2.neomailbox.net ([5.148.176.60]:35786 "EHLO s2.neomailbox.net"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752390AbcBJQAE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Feb 2016 11:00:04 -0500
In-Reply-To: <1455119847-5862-1-git-send-email-a@unstable.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

batman-adv uses a self-written reference implementation which is just based
on atomic_t. This is less obvious when reading the code than kref and
therefore increases the change that the reference counting will be missed.

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <a@unstable.cc>
---
 net/batman-adv/originator.c | 20 ++++++++++++--------
 net/batman-adv/types.h      |  3 ++-
 2 files changed, 14 insertions(+), 9 deletions(-)

diff --git a/net/batman-adv/originator.c b/net/batman-adv/originator.c
index d4a30db0158a..7710595ffc42 100644
--- a/net/batman-adv/originator.c
+++ b/net/batman-adv/originator.c
@@ -23,6 +23,7 @@
 #include <linux/fs.h>
 #include <linux/jiffies.h>
 #include <linux/kernel.h>
+#include <linux/kref.h>
 #include <linux/list.h>
 #include <linux/lockdep.h>
 #include <linux/netdevice.h>
@@ -196,11 +197,15 @@ void batadv_neigh_ifinfo_free_ref(struct batadv_neigh_ifinfo *neigh_ifinfo)
 /**
  * batadv_hardif_neigh_release - release hardif neigh node from lists and
  *  queue for free after rcu grace period
- * @hardif_neigh: hardif neigh neighbor to free
+ * @ref: kref pointer of the neigh_node
  */
-static void
-batadv_hardif_neigh_release(struct batadv_hardif_neigh_node *hardif_neigh)
+static void batadv_hardif_neigh_release(struct kref *ref)
 {
+	struct batadv_hardif_neigh_node *hardif_neigh;
+
+	hardif_neigh = container_of(ref, struct batadv_hardif_neigh_node,
+				    refcount);
+
 	spin_lock_bh(&hardif_neigh->if_incoming->neigh_list_lock);
 	hlist_del_init_rcu(&hardif_neigh->list);
 	spin_unlock_bh(&hardif_neigh->if_incoming->neigh_list_lock);
@@ -216,8 +221,7 @@ batadv_hardif_neigh_release(struct batadv_hardif_neigh_node *hardif_neigh)
  */
 void batadv_hardif_neigh_free_ref(struct batadv_hardif_neigh_node *hardif_neigh)
 {
-	if (atomic_dec_and_test(&hardif_neigh->refcount))
-		batadv_hardif_neigh_release(hardif_neigh);
+	kref_put(&hardif_neigh->refcount, batadv_hardif_neigh_release);
 }
 
 /**
@@ -529,7 +533,7 @@ batadv_hardif_neigh_create(struct batadv_hard_iface *hard_iface,
 	hardif_neigh->if_incoming = hard_iface;
 	hardif_neigh->last_seen = jiffies;
 
-	atomic_set(&hardif_neigh->refcount, 1);
+	kref_init(&hardif_neigh->refcount);
 
 	if (bat_priv->bat_algo_ops->bat_hardif_neigh_init)
 		bat_priv->bat_algo_ops->bat_hardif_neigh_init(hardif_neigh);
@@ -584,7 +588,7 @@ batadv_hardif_neigh_get(const struct batadv_hard_iface *hard_iface,
 		if (!batadv_compare_eth(tmp_hardif_neigh->addr, neigh_addr))
 			continue;
 
-		if (!atomic_inc_not_zero(&tmp_hardif_neigh->refcount))
+		if (!kref_get_unless_zero(&tmp_hardif_neigh->refcount))
 			continue;
 
 		hardif_neigh = tmp_hardif_neigh;
@@ -648,7 +652,7 @@ batadv_neigh_node_new(struct batadv_orig_node *orig_node,
 	spin_unlock_bh(&orig_node->neigh_list_lock);
 
 	/* increment unique neighbor refcount */
-	atomic_inc(&hardif_neigh->refcount);
+	kref_get(&hardif_neigh->refcount);
 
 	batadv_dbg(BATADV_DBG_BATMAN, orig_node->bat_priv,
 		   "Creating new neighbor %pM for orig_node %pM on interface %s\n",
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index 8974bc0dc15c..ace7900347d4 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -25,6 +25,7 @@
 #include <linux/bitops.h>
 #include <linux/compiler.h>
 #include <linux/if_ether.h>
+#include <linux/kref.h>
 #include <linux/netdevice.h>
 #include <linux/sched.h> /* for linux/wait.h */
 #include <linux/spinlock.h>
@@ -359,7 +360,7 @@ struct batadv_hardif_neigh_node {
 	u8 addr[ETH_ALEN];
 	struct batadv_hard_iface *if_incoming;
 	unsigned long last_seen;
-	atomic_t refcount;
+	struct kref refcount;
 	struct rcu_head rcu;
 };
 
-- 
2.7.1
