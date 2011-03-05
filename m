From: Sven Eckelmann <sven@narfation.org>
Subject: [PATCH 12/28] batman-adv: Correct rcu refcounting for gw_node
Date: Sat,  5 Mar 2011 13:28:26 +0100
Message-ID: <1299328122-21468-13-git-send-email-sven@narfation.org>
References: <1299328122-21468-1-git-send-email-sven@narfation.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Marek Lindner <lindner_marek@yahoo.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from narfation.org ([79.140.41.39]:36298 "EHLO v3-1039.vlinux.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753242Ab1CEM3v (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Mar 2011 07:29:51 -0500
In-Reply-To: <1299328122-21468-1-git-send-email-sven@narfation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marek Lindner <lindner_marek@yahoo.de>

It might be possible that 2 threads access the same data in the same
rcu grace period. The first thread calls call_rcu() to decrement the
refcount and free the data while the second thread increases the
refcount to use the data. To avoid this race condition all refcount
operations have to be atomic.

Reported-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
---
 net/batman-adv/gateway_client.c |   37 ++++++++++++++++---------------------
 net/batman-adv/types.h          |    2 +-
 2 files changed, 17 insertions(+), 22 deletions(-)

diff --git a/net/batman-adv/gateway_client.c b/net/batman-adv/gateway_client.c
index 429a013..517e001 100644
--- a/net/batman-adv/gateway_client.c
+++ b/net/batman-adv/gateway_client.c
@@ -28,20 +28,18 @@
 #include <linux/udp.h>
 #include <linux/if_vlan.h>
 
-static void gw_node_free_ref(struct kref *refcount)
+static void gw_node_free_rcu(struct rcu_head *rcu)
 {
 	struct gw_node *gw_node;
 
-	gw_node = container_of(refcount, struct gw_node, refcount);
+	gw_node = container_of(rcu, struct gw_node, rcu);
 	kfree(gw_node);
 }
 
-static void gw_node_free_rcu(struct rcu_head *rcu)
+static void gw_node_free_ref(struct gw_node *gw_node)
 {
-	struct gw_node *gw_node;
-
-	gw_node = container_of(rcu, struct gw_node, rcu);
-	kref_put(&gw_node->refcount, gw_node_free_ref);
+	if (atomic_dec_and_test(&gw_node->refcount))
+		call_rcu(&gw_node->rcu, gw_node_free_rcu);
 }
 
 void *gw_get_selected(struct bat_priv *bat_priv)
@@ -61,25 +59,26 @@ void gw_deselect(struct bat_priv *bat_priv)
 	bat_priv->curr_gw = NULL;
 
 	if (gw_node)
-		kref_put(&gw_node->refcount, gw_node_free_ref);
+		gw_node_free_ref(gw_node);
 }
 
-static struct gw_node *gw_select(struct bat_priv *bat_priv,
-			  struct gw_node *new_gw_node)
+static void gw_select(struct bat_priv *bat_priv, struct gw_node *new_gw_node)
 {
 	struct gw_node *curr_gw_node = bat_priv->curr_gw;
 
-	if (new_gw_node)
-		kref_get(&new_gw_node->refcount);
+	if (new_gw_node && !atomic_inc_not_zero(&new_gw_node->refcount))
+		new_gw_node = NULL;
 
 	bat_priv->curr_gw = new_gw_node;
-	return curr_gw_node;
+
+	if (curr_gw_node)
+		gw_node_free_ref(curr_gw_node);
 }
 
 void gw_election(struct bat_priv *bat_priv)
 {
 	struct hlist_node *node;
-	struct gw_node *gw_node, *curr_gw_tmp = NULL, *old_gw_node = NULL;
+	struct gw_node *gw_node, *curr_gw_tmp = NULL;
 	uint8_t max_tq = 0;
 	uint32_t max_gw_factor = 0, tmp_gw_factor = 0;
 	int down, up;
@@ -174,14 +173,10 @@ void gw_election(struct bat_priv *bat_priv)
 				curr_gw_tmp->orig_node->gw_flags,
 				curr_gw_tmp->orig_node->router->tq_avg);
 
-		old_gw_node = gw_select(bat_priv, curr_gw_tmp);
+		gw_select(bat_priv, curr_gw_tmp);
 	}
 
 	rcu_read_unlock();
-
-	/* the kfree() has to be outside of the rcu lock */
-	if (old_gw_node)
-		kref_put(&old_gw_node->refcount, gw_node_free_ref);
 }
 
 void gw_check_election(struct bat_priv *bat_priv, struct orig_node *orig_node)
@@ -242,7 +237,7 @@ static void gw_node_add(struct bat_priv *bat_priv,
 	memset(gw_node, 0, sizeof(struct gw_node));
 	INIT_HLIST_NODE(&gw_node->list);
 	gw_node->orig_node = orig_node;
-	kref_init(&gw_node->refcount);
+	atomic_set(&gw_node->refcount, 1);
 
 	spin_lock_bh(&bat_priv->gw_list_lock);
 	hlist_add_head_rcu(&gw_node->list, &bat_priv->gw_list);
@@ -325,7 +320,7 @@ void gw_node_purge(struct bat_priv *bat_priv)
 			gw_deselect(bat_priv);
 
 		hlist_del_rcu(&gw_node->list);
-		call_rcu(&gw_node->rcu, gw_node_free_rcu);
+		gw_node_free_ref(gw_node);
 	}
 
 
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index 084604a..cfbeb45 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -98,7 +98,7 @@ struct gw_node {
 	struct hlist_node list;
 	struct orig_node *orig_node;
 	unsigned long deleted;
-	struct kref refcount;
+	atomic_t refcount;
 	struct rcu_head rcu;
 };
 
-- 
1.7.2.3

