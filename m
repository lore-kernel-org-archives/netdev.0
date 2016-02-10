From: Antonio Quartulli <a@unstable.cc>
Subject: [PATCH 07/21] batman-adv: Convert batadv_bla_backbone_gw to kref
Date: Wed, 10 Feb 2016 23:57:13 +0800
Message-ID: <1455119847-5862-8-git-send-email-a@unstable.cc>
References: <1455119847-5862-1-git-send-email-a@unstable.cc>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <a@unstable.cc>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s2.neomailbox.net ([5.148.176.60]:16003 "EHLO s2.neomailbox.net"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752506AbcBJQAQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Feb 2016 11:00:16 -0500
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
 net/batman-adv/bridge_loop_avoidance.c | 29 +++++++++++++++++++++++------
 net/batman-adv/types.h                 |  2 +-
 2 files changed, 24 insertions(+), 7 deletions(-)

diff --git a/net/batman-adv/bridge_loop_avoidance.c b/net/batman-adv/bridge_loop_avoidance.c
index 779160934844..41116e4c2e34 100644
--- a/net/batman-adv/bridge_loop_avoidance.c
+++ b/net/batman-adv/bridge_loop_avoidance.c
@@ -31,6 +31,7 @@
 #include <linux/jhash.h>
 #include <linux/jiffies.h>
 #include <linux/kernel.h>
+#include <linux/kref.h>
 #include <linux/list.h>
 #include <linux/lockdep.h>
 #include <linux/netdevice.h>
@@ -143,14 +144,29 @@ static int batadv_compare_claim(const struct hlist_node *node,
 }
 
 /**
- * batadv_compare_backbone_gw - free backbone gw
+ * batadv_backbone_gw_release - release backbone gw from lists and queue for
+ *  free after rcu grace period
+ * @ref: kref pointer of the backbone gw
+ */
+static void batadv_backbone_gw_release(struct kref *ref)
+{
+	struct batadv_bla_backbone_gw *backbone_gw;
+
+	backbone_gw = container_of(ref, struct batadv_bla_backbone_gw,
+				   refcount);
+
+	kfree_rcu(backbone_gw, rcu);
+}
+
+/**
+ * batadv_backbone_gw_free_ref - decrement the backbone gw refcounter and
+ *  possibly release it
  * @backbone_gw: backbone gateway to be free'd
  */
 static void
 batadv_backbone_gw_free_ref(struct batadv_bla_backbone_gw *backbone_gw)
 {
-	if (atomic_dec_and_test(&backbone_gw->refcount))
-		kfree_rcu(backbone_gw, rcu);
+	kref_put(&backbone_gw->refcount, batadv_backbone_gw_release);
 }
 
 /**
@@ -247,7 +263,7 @@ batadv_backbone_hash_find(struct batadv_priv *bat_priv, u8 *addr,
 						&search_entry))
 			continue;
 
-		if (!atomic_inc_not_zero(&backbone_gw->refcount))
+		if (!kref_get_unless_zero(&backbone_gw->refcount))
 			continue;
 
 		backbone_gw_tmp = backbone_gw;
@@ -448,7 +464,8 @@ batadv_bla_get_backbone_gw(struct batadv_priv *bat_priv, u8 *orig,
 	ether_addr_copy(entry->orig, orig);
 
 	/* one for the hash, one for returning */
-	atomic_set(&entry->refcount, 2);
+	kref_init(&entry->refcount);
+	kref_get(&entry->refcount);
 
 	hash_added = batadv_hash_add(bat_priv->bla.backbone_hash,
 				     batadv_compare_backbone_gw,
@@ -664,7 +681,7 @@ static void batadv_bla_add_claim(struct batadv_priv *bat_priv,
 		batadv_backbone_gw_free_ref(claim->backbone_gw);
 	}
 	/* set (new) backbone gw */
-	atomic_inc(&backbone_gw->refcount);
+	kref_get(&backbone_gw->refcount);
 	claim->backbone_gw = backbone_gw;
 
 	spin_lock_bh(&backbone_gw->crc_lock);
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index 868f6b592b7c..595f52400b1f 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -930,7 +930,7 @@ struct batadv_bla_backbone_gw {
 	atomic_t request_sent;
 	u16 crc;
 	spinlock_t crc_lock; /* protects crc */
-	atomic_t refcount;
+	struct kref refcount;
 	struct rcu_head rcu;
 };
 
-- 
2.7.1
