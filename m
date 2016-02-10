From: Antonio Quartulli <a@unstable.cc>
Subject: [PATCH 05/21] batman-adv: Convert batadv_gw_node to kref
Date: Wed, 10 Feb 2016 23:57:11 +0800
Message-ID: <1455119847-5862-6-git-send-email-a@unstable.cc>
References: <1455119847-5862-1-git-send-email-a@unstable.cc>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <a@unstable.cc>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s2.neomailbox.net ([5.148.176.60]:2991 "EHLO s2.neomailbox.net"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752463AbcBJQAM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Feb 2016 11:00:12 -0500
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
 net/batman-adv/gateway_client.c | 40 +++++++++++++++++++++++++++++-----------
 net/batman-adv/types.h          |  2 +-
 2 files changed, 30 insertions(+), 12 deletions(-)

diff --git a/net/batman-adv/gateway_client.c b/net/batman-adv/gateway_client.c
index 5950974de7b1..1f3847c61db8 100644
--- a/net/batman-adv/gateway_client.c
+++ b/net/batman-adv/gateway_client.c
@@ -28,6 +28,7 @@
 #include <linux/ip.h>
 #include <linux/ipv6.h>
 #include <linux/kernel.h>
+#include <linux/kref.h>
 #include <linux/list.h>
 #include <linux/netdevice.h>
 #include <linux/rculist.h>
@@ -59,12 +60,29 @@
  */
 #define BATADV_DHCP_CHADDR_OFFSET	28
 
+/**
+ * batadv_gw_node_release - release gw_node from lists and queue for free after
+ *  rcu grace period
+ * @ref: kref pointer of the gw_node
+ */
+static void batadv_gw_node_release(struct kref *ref)
+{
+	struct batadv_gw_node *gw_node;
+
+	gw_node = container_of(ref, struct batadv_gw_node, refcount);
+
+	batadv_orig_node_free_ref(gw_node->orig_node);
+	kfree_rcu(gw_node, rcu);
+}
+
+/**
+ * batadv_gw_node_free_ref - decrement the gw_node refcounter and possibly
+ *  release it
+ * @gw_node: gateway node to free
+ */
 static void batadv_gw_node_free_ref(struct batadv_gw_node *gw_node)
 {
-	if (atomic_dec_and_test(&gw_node->refcount)) {
-		batadv_orig_node_free_ref(gw_node->orig_node);
-		kfree_rcu(gw_node, rcu);
-	}
+	kref_put(&gw_node->refcount, batadv_gw_node_release);
 }
 
 static struct batadv_gw_node *
@@ -77,7 +95,7 @@ batadv_gw_get_selected_gw_node(struct batadv_priv *bat_priv)
 	if (!gw_node)
 		goto out;
 
-	if (!atomic_inc_not_zero(&gw_node->refcount))
+	if (!kref_get_unless_zero(&gw_node->refcount))
 		gw_node = NULL;
 
 out:
@@ -118,7 +136,7 @@ static void batadv_gw_select(struct batadv_priv *bat_priv,
 
 	spin_lock_bh(&bat_priv->gw.list_lock);
 
-	if (new_gw_node && !atomic_inc_not_zero(&new_gw_node->refcount))
+	if (new_gw_node && !kref_get_unless_zero(&new_gw_node->refcount))
 		new_gw_node = NULL;
 
 	curr_gw_node = rcu_dereference_protected(bat_priv->gw.curr_gw, 1);
@@ -170,7 +188,7 @@ batadv_gw_get_best_gw_node(struct batadv_priv *bat_priv)
 		if (!router_ifinfo)
 			goto next;
 
-		if (!atomic_inc_not_zero(&gw_node->refcount))
+		if (!kref_get_unless_zero(&gw_node->refcount))
 			goto next;
 
 		tq_avg = router_ifinfo->bat_iv.tq_avg;
@@ -188,7 +206,7 @@ batadv_gw_get_best_gw_node(struct batadv_priv *bat_priv)
 				if (curr_gw)
 					batadv_gw_node_free_ref(curr_gw);
 				curr_gw = gw_node;
-				atomic_inc(&curr_gw->refcount);
+				kref_get(&curr_gw->refcount);
 			}
 			break;
 
@@ -203,7 +221,7 @@ batadv_gw_get_best_gw_node(struct batadv_priv *bat_priv)
 				if (curr_gw)
 					batadv_gw_node_free_ref(curr_gw);
 				curr_gw = gw_node;
-				atomic_inc(&curr_gw->refcount);
+				kref_get(&curr_gw->refcount);
 			}
 			break;
 		}
@@ -436,7 +454,7 @@ static void batadv_gw_node_add(struct batadv_priv *bat_priv,
 	gw_node->orig_node = orig_node;
 	gw_node->bandwidth_down = ntohl(gateway->bandwidth_down);
 	gw_node->bandwidth_up = ntohl(gateway->bandwidth_up);
-	atomic_set(&gw_node->refcount, 1);
+	kref_init(&gw_node->refcount);
 
 	spin_lock_bh(&bat_priv->gw.list_lock);
 	hlist_add_head_rcu(&gw_node->list, &bat_priv->gw.list);
@@ -469,7 +487,7 @@ batadv_gw_node_get(struct batadv_priv *bat_priv,
 		if (gw_node_tmp->orig_node != orig_node)
 			continue;
 
-		if (!atomic_inc_not_zero(&gw_node_tmp->refcount))
+		if (!kref_get_unless_zero(&gw_node_tmp->refcount))
 			continue;
 
 		gw_node = gw_node_tmp;
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index ace7900347d4..06c38881e382 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -342,7 +342,7 @@ struct batadv_gw_node {
 	struct batadv_orig_node *orig_node;
 	u32 bandwidth_down;
 	u32 bandwidth_up;
-	atomic_t refcount;
+	struct kref refcount;
 	struct rcu_head rcu;
 };
 
-- 
2.7.1
