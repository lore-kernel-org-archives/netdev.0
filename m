From: Antonio Quartulli <a@unstable.cc>
Subject: [PATCH 06/21] batman-adv: Convert batadv_softif_vlan to kref
Date: Wed, 10 Feb 2016 23:57:12 +0800
Message-ID: <1455119847-5862-7-git-send-email-a@unstable.cc>
References: <1455119847-5862-1-git-send-email-a@unstable.cc>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <a@unstable.cc>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s2.neomailbox.net ([5.148.176.60]:7927 "EHLO s2.neomailbox.net"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752468AbcBJQAO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Feb 2016 11:00:14 -0500
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
 net/batman-adv/soft-interface.c | 33 +++++++++++++++++++++++----------
 net/batman-adv/sysfs.c          |  3 ++-
 net/batman-adv/types.h          |  2 +-
 3 files changed, 26 insertions(+), 12 deletions(-)

diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index 4bf35b8c3d23..d4490ff75edd 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -30,6 +30,7 @@
 #include <linux/if_vlan.h>
 #include <linux/jiffies.h>
 #include <linux/kernel.h>
+#include <linux/kref.h>
 #include <linux/list.h>
 #include <linux/lockdep.h>
 #include <linux/netdevice.h>
@@ -478,8 +479,26 @@ out:
 }
 
 /**
+ * batadv_softif_vlan_release - release vlan from lists and queue for free after
+ *  rcu grace period
+ * @ref: kref pointer of the vlan object
+ */
+static void batadv_softif_vlan_release(struct kref *ref)
+{
+	struct batadv_softif_vlan *vlan;
+
+	vlan = container_of(ref, struct batadv_softif_vlan, refcount);
+
+	spin_lock_bh(&vlan->bat_priv->softif_vlan_list_lock);
+	hlist_del_rcu(&vlan->list);
+	spin_unlock_bh(&vlan->bat_priv->softif_vlan_list_lock);
+
+	kfree_rcu(vlan, rcu);
+}
+
+/**
  * batadv_softif_vlan_free_ref - decrease the vlan object refcounter and
- *  possibly free it
+ *  possibly release it
  * @vlan: the vlan object to release
  */
 void batadv_softif_vlan_free_ref(struct batadv_softif_vlan *vlan)
@@ -487,13 +506,7 @@ void batadv_softif_vlan_free_ref(struct batadv_softif_vlan *vlan)
 	if (!vlan)
 		return;
 
-	if (atomic_dec_and_test(&vlan->refcount)) {
-		spin_lock_bh(&vlan->bat_priv->softif_vlan_list_lock);
-		hlist_del_rcu(&vlan->list);
-		spin_unlock_bh(&vlan->bat_priv->softif_vlan_list_lock);
-
-		kfree_rcu(vlan, rcu);
-	}
+	kref_put(&vlan->refcount, batadv_softif_vlan_release);
 }
 
 /**
@@ -514,7 +527,7 @@ struct batadv_softif_vlan *batadv_softif_vlan_get(struct batadv_priv *bat_priv,
 		if (vlan_tmp->vid != vid)
 			continue;
 
-		if (!atomic_inc_not_zero(&vlan_tmp->refcount))
+		if (!kref_get_unless_zero(&vlan_tmp->refcount))
 			continue;
 
 		vlan = vlan_tmp;
@@ -549,7 +562,7 @@ int batadv_softif_create_vlan(struct batadv_priv *bat_priv, unsigned short vid)
 
 	vlan->bat_priv = bat_priv;
 	vlan->vid = vid;
-	atomic_set(&vlan->refcount, 1);
+	kref_init(&vlan->refcount);
 
 	atomic_set(&vlan->ap_isolation, 0);
 
diff --git a/net/batman-adv/sysfs.c b/net/batman-adv/sysfs.c
index 964fc5986b2c..ab4382ba3855 100644
--- a/net/batman-adv/sysfs.c
+++ b/net/batman-adv/sysfs.c
@@ -25,6 +25,7 @@
 #include <linux/fs.h>
 #include <linux/if.h>
 #include <linux/if_vlan.h>
+#include <linux/kref.h>
 #include <linux/kernel.h>
 #include <linux/netdevice.h>
 #include <linux/printk.h>
@@ -97,7 +98,7 @@ batadv_kobj_to_vlan(struct batadv_priv *bat_priv, struct kobject *obj)
 		if (vlan_tmp->kobj != obj)
 			continue;
 
-		if (!atomic_inc_not_zero(&vlan_tmp->refcount))
+		if (!kref_get_unless_zero(&vlan_tmp->refcount))
 			continue;
 
 		vlan = vlan_tmp;
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index 06c38881e382..868f6b592b7c 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -746,7 +746,7 @@ struct batadv_softif_vlan {
 	atomic_t ap_isolation;		/* boolean */
 	struct batadv_vlan_tt tt;
 	struct hlist_node list;
-	atomic_t refcount;
+	struct kref refcount;
 	struct rcu_head rcu;
 };
 
-- 
2.7.1
