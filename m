From: Simon Wunderlich <sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>
Subject: [PATCH 06/19] batman-adv: Revert "postpone sysfs
	removal when unregistering"
Date: Fri, 12 Aug 2016 10:56:42 +0200
Message-ID: <1470992215-11009-7-git-send-email-sw@simonwunderlich.de>
References: <1470992215-11009-1-git-send-email-sw@simonwunderlich.de>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org,
 Marek Lindner <mareklindner-rVWd3aGhH2z5bpWLKbzFeg@public.gmane.org>
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1470992215-11009-1-git-send-email-sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n/>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Sender: "B.A.T.M.A.N" <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Id: netdev.vger.kernel.org

From: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>

Postponing the removal of the interface breaks the expected behavior of
NETDEV_UNREGISTER and NETDEV_PRE_TYPE_CHANGE. This is especially
problematic when an interface is removed and added in quick succession.

This reverts commit 5bc44dc8458c ("batman-adv: postpone sysfs removal when
unregistering").

Signed-off-by: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Signed-off-by: Marek Lindner <mareklindner-rVWd3aGhH2z5bpWLKbzFeg@public.gmane.org>
Signed-off-by: Simon Wunderlich <sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>
---
 net/batman-adv/hard-interface.c | 26 +++---------------------
 net/batman-adv/soft-interface.c | 44 ++++++++++++-----------------------------
 net/batman-adv/types.h          |  4 ----
 3 files changed, 16 insertions(+), 58 deletions(-)

diff --git a/net/batman-adv/hard-interface.c b/net/batman-adv/hard-interface.c
index 1f90808..714af8e 100644
--- a/net/batman-adv/hard-interface.c
+++ b/net/batman-adv/hard-interface.c
@@ -35,7 +35,6 @@
 #include <linux/rtnetlink.h>
 #include <linux/slab.h>
 #include <linux/spinlock.h>
-#include <linux/workqueue.h>
 
 #include "bat_v.h"
 #include "bridge_loop_avoidance.h"
@@ -625,25 +624,6 @@ out:
 		batadv_hardif_put(primary_if);
 }
 
-/**
- * batadv_hardif_remove_interface_finish - cleans up the remains of a hardif
- * @work: work queue item
- *
- * Free the parts of the hard interface which can not be removed under
- * rtnl lock (to prevent deadlock situations).
- */
-static void batadv_hardif_remove_interface_finish(struct work_struct *work)
-{
-	struct batadv_hard_iface *hard_iface;
-
-	hard_iface = container_of(work, struct batadv_hard_iface,
-				  cleanup_work);
-
-	batadv_debugfs_del_hardif(hard_iface);
-	batadv_sysfs_del_hardif(&hard_iface->hardif_obj);
-	batadv_hardif_put(hard_iface);
-}
-
 static struct batadv_hard_iface *
 batadv_hardif_add_interface(struct net_device *net_dev)
 {
@@ -676,8 +656,6 @@ batadv_hardif_add_interface(struct net_device *net_dev)
 
 	INIT_LIST_HEAD(&hard_iface->list);
 	INIT_HLIST_HEAD(&hard_iface->neigh_list);
-	INIT_WORK(&hard_iface->cleanup_work,
-		  batadv_hardif_remove_interface_finish);
 
 	spin_lock_init(&hard_iface->neigh_list_lock);
 
@@ -719,7 +697,9 @@ static void batadv_hardif_remove_interface(struct batadv_hard_iface *hard_iface)
 		return;
 
 	hard_iface->if_status = BATADV_IF_TO_BE_REMOVED;
-	queue_work(batadv_event_workqueue, &hard_iface->cleanup_work);
+	batadv_debugfs_del_hardif(hard_iface);
+	batadv_sysfs_del_hardif(&hard_iface->hardif_obj);
+	batadv_hardif_put(hard_iface);
 }
 
 void batadv_hardif_remove_interfaces(void)
diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index 7527c06..216ac03 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -39,6 +39,7 @@
 #include <linux/random.h>
 #include <linux/rculist.h>
 #include <linux/rcupdate.h>
+#include <linux/rtnetlink.h>
 #include <linux/skbuff.h>
 #include <linux/slab.h>
 #include <linux/socket.h>
@@ -46,7 +47,6 @@
 #include <linux/stddef.h>
 #include <linux/string.h>
 #include <linux/types.h>
-#include <linux/workqueue.h>
 
 #include "bat_algo.h"
 #include "bridge_loop_avoidance.h"
@@ -747,34 +747,6 @@ static void batadv_set_lockdep_class(struct net_device *dev)
 }
 
 /**
- * batadv_softif_destroy_finish - cleans up the remains of a softif
- * @work: work queue item
- *
- * Free the parts of the soft interface which can not be removed under
- * rtnl lock (to prevent deadlock situations).
- */
-static void batadv_softif_destroy_finish(struct work_struct *work)
-{
-	struct batadv_softif_vlan *vlan;
-	struct batadv_priv *bat_priv;
-	struct net_device *soft_iface;
-
-	bat_priv = container_of(work, struct batadv_priv,
-				cleanup_work);
-	soft_iface = bat_priv->soft_iface;
-
-	/* destroy the "untagged" VLAN */
-	vlan = batadv_softif_vlan_get(bat_priv, BATADV_NO_FLAGS);
-	if (vlan) {
-		batadv_softif_destroy_vlan(bat_priv, vlan);
-		batadv_softif_vlan_put(vlan);
-	}
-
-	batadv_sysfs_del_meshif(soft_iface);
-	unregister_netdev(soft_iface);
-}
-
-/**
  * batadv_softif_init_late - late stage initialization of soft interface
  * @dev: registered network device to modify
  *
@@ -791,7 +763,6 @@ static int batadv_softif_init_late(struct net_device *dev)
 
 	bat_priv = netdev_priv(dev);
 	bat_priv->soft_iface = dev;
-	INIT_WORK(&bat_priv->cleanup_work, batadv_softif_destroy_finish);
 
 	/* batadv_interface_stats() needs to be available as soon as
 	 * register_netdevice() has been called
@@ -1028,8 +999,19 @@ struct net_device *batadv_softif_create(struct net *net, const char *name)
 void batadv_softif_destroy_sysfs(struct net_device *soft_iface)
 {
 	struct batadv_priv *bat_priv = netdev_priv(soft_iface);
+	struct batadv_softif_vlan *vlan;
+
+	ASSERT_RTNL();
+
+	/* destroy the "untagged" VLAN */
+	vlan = batadv_softif_vlan_get(bat_priv, BATADV_NO_FLAGS);
+	if (vlan) {
+		batadv_softif_destroy_vlan(bat_priv, vlan);
+		batadv_softif_vlan_put(vlan);
+	}
 
-	queue_work(batadv_event_workqueue, &bat_priv->cleanup_work);
+	batadv_sysfs_del_meshif(soft_iface);
+	unregister_netdevice(soft_iface);
 }
 
 /**
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index 23c9577..96af6da 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -132,7 +132,6 @@ struct batadv_hard_iface_bat_v {
  * @rcu: struct used for freeing in an RCU-safe manner
  * @bat_iv: per hard-interface B.A.T.M.A.N. IV data
  * @bat_v: per hard-interface B.A.T.M.A.N. V data
- * @cleanup_work: work queue callback item for hard-interface deinit
  * @debug_dir: dentry for nc subdir in batman-adv directory in debugfs
  * @neigh_list: list of unique single hop neighbors via this interface
  * @neigh_list_lock: lock protecting neigh_list
@@ -152,7 +151,6 @@ struct batadv_hard_iface {
 #ifdef CONFIG_BATMAN_ADV_BATMAN_V
 	struct batadv_hard_iface_bat_v bat_v;
 #endif
-	struct work_struct cleanup_work;
 	struct dentry *debug_dir;
 	struct hlist_head neigh_list;
 	/* neigh_list_lock protects: neigh_list */
@@ -1015,7 +1013,6 @@ struct batadv_priv_bat_v {
  * @forw_bcast_list_lock: lock protecting forw_bcast_list
  * @tp_list_lock: spinlock protecting @tp_list
  * @orig_work: work queue callback item for orig node purging
- * @cleanup_work: work queue callback item for soft-interface deinit
  * @primary_if: one of the hard-interfaces assigned to this mesh interface
  *  becomes the primary interface
  * @algo_ops: routing algorithm used by this mesh interface
@@ -1074,7 +1071,6 @@ struct batadv_priv {
 	spinlock_t tp_list_lock; /* protects tp_list */
 	atomic_t tp_num;
 	struct delayed_work orig_work;
-	struct work_struct cleanup_work;
 	struct batadv_hard_iface __rcu *primary_if;  /* rcu protected pointer */
 	struct batadv_algo_ops *algo_ops;
 	struct hlist_head softif_vlan_list;
-- 
2.8.1
