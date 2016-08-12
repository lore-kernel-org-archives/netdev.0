From: Simon Wunderlich <sw@simonwunderlich.de>
Subject: [PATCH 16/19] batman-adv: use kmem_cache for translation table
Date: Fri, 12 Aug 2016 10:56:52 +0200
Message-ID: <1470992215-11009-17-git-send-email-sw@simonwunderlich.de>
References: <1470992215-11009-1-git-send-email-sw@simonwunderlich.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Simon Wunderlich <sw@simonwunderlich.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from packetmixer.de ([79.140.42.25]:34987 "EHLO
	mail.mail.packetmixer.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752422AbcHLI5k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Aug 2016 04:57:40 -0400
In-Reply-To: <1470992215-11009-1-git-send-email-sw@simonwunderlich.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

The translation table (global, local) is usually the part of batman-adv
which has the most dynamical allocated objects. Most of them
(tt_local_entry, tt_global_entry, tt_orig_list_entry, tt_change_node,
tt_req_node, tt_roam_node) are equally sized. So it makes sense to have
them allocated from a kmem_cache for each type.

This approach allowed a small wireless router (TP-Link TL-841NDv8; SLUB
allocator) to store 34% more translation table entries compared to the
current implementation.

[1] https://open-mesh.org/projects/batman-adv/wiki/Kmalloc-kmem-cache-tests

Reported-by: Linus Lüssing <linus.luessing@c0d3.blue>
Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Simon Wunderlich <sw@simonwunderlich.de>
---
 net/batman-adv/main.c              |  16 +++-
 net/batman-adv/translation-table.c | 169 +++++++++++++++++++++++++++++++++----
 net/batman-adv/translation-table.h |   3 +
 3 files changed, 169 insertions(+), 19 deletions(-)

diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index f61479b..ef07e5b 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -82,6 +82,12 @@ static void batadv_recv_handler_init(void);
 
 static int __init batadv_init(void)
 {
+	int ret;
+
+	ret = batadv_tt_cache_init();
+	if (ret < 0)
+		return ret;
+
 	INIT_LIST_HEAD(&batadv_hardif_list);
 	batadv_algo_init();
 
@@ -93,9 +99,8 @@ static int __init batadv_init(void)
 	batadv_tp_meter_init();
 
 	batadv_event_workqueue = create_singlethread_workqueue("bat_events");
-
 	if (!batadv_event_workqueue)
-		return -ENOMEM;
+		goto err_create_wq;
 
 	batadv_socket_init();
 	batadv_debugfs_init();
@@ -108,6 +113,11 @@ static int __init batadv_init(void)
 		BATADV_SOURCE_VERSION, BATADV_COMPAT_VERSION);
 
 	return 0;
+
+err_create_wq:
+	batadv_tt_cache_destroy();
+
+	return -ENOMEM;
 }
 
 static void __exit batadv_exit(void)
@@ -123,6 +133,8 @@ static void __exit batadv_exit(void)
 	batadv_event_workqueue = NULL;
 
 	rcu_barrier();
+
+	batadv_tt_cache_destroy();
 }
 
 int batadv_mesh_init(struct net_device *soft_iface)
diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index 7e6df7a..af2bfef 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -22,12 +22,14 @@
 #include <linux/bitops.h>
 #include <linux/bug.h>
 #include <linux/byteorder/generic.h>
+#include <linux/cache.h>
 #include <linux/compiler.h>
 #include <linux/crc32c.h>
 #include <linux/errno.h>
 #include <linux/etherdevice.h>
 #include <linux/fs.h>
 #include <linux/if_ether.h>
+#include <linux/init.h>
 #include <linux/jhash.h>
 #include <linux/jiffies.h>
 #include <linux/kernel.h>
@@ -54,6 +56,13 @@
 #include "soft-interface.h"
 #include "tvlv.h"
 
+static struct kmem_cache *batadv_tl_cache __read_mostly;
+static struct kmem_cache *batadv_tg_cache __read_mostly;
+static struct kmem_cache *batadv_tt_orig_cache __read_mostly;
+static struct kmem_cache *batadv_tt_change_cache __read_mostly;
+static struct kmem_cache *batadv_tt_req_cache __read_mostly;
+static struct kmem_cache *batadv_tt_roam_cache __read_mostly;
+
 /* hash class keys */
 static struct lock_class_key batadv_tt_local_hash_lock_class_key;
 static struct lock_class_key batadv_tt_global_hash_lock_class_key;
@@ -205,6 +214,20 @@ batadv_tt_global_hash_find(struct batadv_priv *bat_priv, const u8 *addr,
 }
 
 /**
+ * batadv_tt_local_entry_free_rcu - free the tt_local_entry
+ * @rcu: rcu pointer of the tt_local_entry
+ */
+static void batadv_tt_local_entry_free_rcu(struct rcu_head *rcu)
+{
+	struct batadv_tt_local_entry *tt_local_entry;
+
+	tt_local_entry = container_of(rcu, struct batadv_tt_local_entry,
+				      common.rcu);
+
+	kmem_cache_free(batadv_tl_cache, tt_local_entry);
+}
+
+/**
  * batadv_tt_local_entry_release - release tt_local_entry from lists and queue
  *  for free after rcu grace period
  * @ref: kref pointer of the nc_node
@@ -218,7 +241,7 @@ static void batadv_tt_local_entry_release(struct kref *ref)
 
 	batadv_softif_vlan_put(tt_local_entry->vlan);
 
-	kfree_rcu(tt_local_entry, common.rcu);
+	call_rcu(&tt_local_entry->common.rcu, batadv_tt_local_entry_free_rcu);
 }
 
 /**
@@ -234,6 +257,20 @@ batadv_tt_local_entry_put(struct batadv_tt_local_entry *tt_local_entry)
 }
 
 /**
+ * batadv_tt_global_entry_free_rcu - free the tt_global_entry
+ * @rcu: rcu pointer of the tt_global_entry
+ */
+static void batadv_tt_global_entry_free_rcu(struct rcu_head *rcu)
+{
+	struct batadv_tt_global_entry *tt_global_entry;
+
+	tt_global_entry = container_of(rcu, struct batadv_tt_global_entry,
+				       common.rcu);
+
+	kmem_cache_free(batadv_tg_cache, tt_global_entry);
+}
+
+/**
  * batadv_tt_global_entry_release - release tt_global_entry from lists and queue
  *  for free after rcu grace period
  * @ref: kref pointer of the nc_node
@@ -246,7 +283,8 @@ static void batadv_tt_global_entry_release(struct kref *ref)
 				       common.refcount);
 
 	batadv_tt_global_del_orig_list(tt_global_entry);
-	kfree_rcu(tt_global_entry, common.rcu);
+
+	call_rcu(&tt_global_entry->common.rcu, batadv_tt_global_entry_free_rcu);
 }
 
 /**
@@ -384,6 +422,19 @@ static void batadv_tt_global_size_dec(struct batadv_orig_node *orig_node,
 }
 
 /**
+ * batadv_tt_orig_list_entry_free_rcu - free the orig_entry
+ * @rcu: rcu pointer of the orig_entry
+ */
+static void batadv_tt_orig_list_entry_free_rcu(struct rcu_head *rcu)
+{
+	struct batadv_tt_orig_list_entry *orig_entry;
+
+	orig_entry = container_of(rcu, struct batadv_tt_orig_list_entry, rcu);
+
+	kmem_cache_free(batadv_tt_orig_cache, orig_entry);
+}
+
+/**
  * batadv_tt_orig_list_entry_release - release tt orig entry from lists and
  *  queue for free after rcu grace period
  * @ref: kref pointer of the tt orig entry
@@ -396,7 +447,7 @@ static void batadv_tt_orig_list_entry_release(struct kref *ref)
 				  refcount);
 
 	batadv_orig_node_put(orig_entry->orig_node);
-	kfree_rcu(orig_entry, rcu);
+	call_rcu(&orig_entry->rcu, batadv_tt_orig_list_entry_free_rcu);
 }
 
 /**
@@ -426,7 +477,7 @@ static void batadv_tt_local_event(struct batadv_priv *bat_priv,
 	bool event_removed = false;
 	bool del_op_requested, del_op_entry;
 
-	tt_change_node = kmalloc(sizeof(*tt_change_node), GFP_ATOMIC);
+	tt_change_node = kmem_cache_alloc(batadv_tt_change_cache, GFP_ATOMIC);
 	if (!tt_change_node)
 		return;
 
@@ -467,8 +518,8 @@ static void batadv_tt_local_event(struct batadv_priv *bat_priv,
 		continue;
 del:
 		list_del(&entry->list);
-		kfree(entry);
-		kfree(tt_change_node);
+		kmem_cache_free(batadv_tt_change_cache, entry);
+		kmem_cache_free(batadv_tt_change_cache, tt_change_node);
 		event_removed = true;
 		goto unlock;
 	}
@@ -646,7 +697,7 @@ bool batadv_tt_local_add(struct net_device *soft_iface, const u8 *addr,
 		goto out;
 	}
 
-	tt_local = kmalloc(sizeof(*tt_local), GFP_ATOMIC);
+	tt_local = kmem_cache_alloc(batadv_tl_cache, GFP_ATOMIC);
 	if (!tt_local)
 		goto out;
 
@@ -656,7 +707,7 @@ bool batadv_tt_local_add(struct net_device *soft_iface, const u8 *addr,
 		net_ratelimited_function(batadv_info, soft_iface,
 					 "adding TT local entry %pM to non-existent VLAN %d\n",
 					 addr, BATADV_PRINT_VID(vid));
-		kfree(tt_local);
+		kmem_cache_free(batadv_tl_cache, tt_local);
 		tt_local = NULL;
 		goto out;
 	}
@@ -959,7 +1010,7 @@ static void batadv_tt_tvlv_container_update(struct batadv_priv *bat_priv)
 			tt_diff_entries_count++;
 		}
 		list_del(&entry->list);
-		kfree(entry);
+		kmem_cache_free(batadv_tt_change_cache, entry);
 	}
 	spin_unlock_bh(&bat_priv->tt.changes_list_lock);
 
@@ -1259,7 +1310,7 @@ static void batadv_tt_changes_list_free(struct batadv_priv *bat_priv)
 	list_for_each_entry_safe(entry, safe, &bat_priv->tt.changes_list,
 				 list) {
 		list_del(&entry->list);
-		kfree(entry);
+		kmem_cache_free(batadv_tt_change_cache, entry);
 	}
 
 	atomic_set(&bat_priv->tt.local_changes, 0);
@@ -1341,7 +1392,7 @@ batadv_tt_global_orig_entry_add(struct batadv_tt_global_entry *tt_global,
 		goto out;
 	}
 
-	orig_entry = kzalloc(sizeof(*orig_entry), GFP_ATOMIC);
+	orig_entry = kmem_cache_zalloc(batadv_tt_orig_cache, GFP_ATOMIC);
 	if (!orig_entry)
 		goto out;
 
@@ -1411,7 +1462,8 @@ static bool batadv_tt_global_add(struct batadv_priv *bat_priv,
 		goto out;
 
 	if (!tt_global_entry) {
-		tt_global_entry = kzalloc(sizeof(*tt_global_entry), GFP_ATOMIC);
+		tt_global_entry = kmem_cache_zalloc(batadv_tg_cache,
+						    GFP_ATOMIC);
 		if (!tt_global_entry)
 			goto out;
 
@@ -2280,7 +2332,7 @@ static void batadv_tt_req_node_release(struct kref *ref)
 
 	tt_req_node = container_of(ref, struct batadv_tt_req_node, refcount);
 
-	kfree(tt_req_node);
+	kmem_cache_free(batadv_tt_req_cache, tt_req_node);
 }
 
 /**
@@ -2367,7 +2419,7 @@ batadv_tt_req_node_new(struct batadv_priv *bat_priv,
 			goto unlock;
 	}
 
-	tt_req_node = kmalloc(sizeof(*tt_req_node), GFP_ATOMIC);
+	tt_req_node = kmem_cache_alloc(batadv_tt_req_cache, GFP_ATOMIC);
 	if (!tt_req_node)
 		goto unlock;
 
@@ -3104,7 +3156,7 @@ static void batadv_tt_roam_list_free(struct batadv_priv *bat_priv)
 
 	list_for_each_entry_safe(node, safe, &bat_priv->tt.roam_list, list) {
 		list_del(&node->list);
-		kfree(node);
+		kmem_cache_free(batadv_tt_roam_cache, node);
 	}
 
 	spin_unlock_bh(&bat_priv->tt.roam_list_lock);
@@ -3121,7 +3173,7 @@ static void batadv_tt_roam_purge(struct batadv_priv *bat_priv)
 			continue;
 
 		list_del(&node->list);
-		kfree(node);
+		kmem_cache_free(batadv_tt_roam_cache, node);
 	}
 	spin_unlock_bh(&bat_priv->tt.roam_list_lock);
 }
@@ -3162,7 +3214,8 @@ static bool batadv_tt_check_roam_count(struct batadv_priv *bat_priv, u8 *client)
 	}
 
 	if (!ret) {
-		tt_roam_node = kmalloc(sizeof(*tt_roam_node), GFP_ATOMIC);
+		tt_roam_node = kmem_cache_alloc(batadv_tt_roam_cache,
+						GFP_ATOMIC);
 		if (!tt_roam_node)
 			goto unlock;
 
@@ -3865,3 +3918,85 @@ bool batadv_tt_global_is_isolated(struct batadv_priv *bat_priv,
 
 	return ret;
 }
+
+/**
+ * batadv_tt_cache_init - Initialize tt memory object cache
+ *
+ * Return: 0 on success or negative error number in case of failure.
+ */
+int __init batadv_tt_cache_init(void)
+{
+	size_t tl_size = sizeof(struct batadv_tt_local_entry);
+	size_t tg_size = sizeof(struct batadv_tt_global_entry);
+	size_t tt_orig_size = sizeof(struct batadv_tt_orig_list_entry);
+	size_t tt_change_size = sizeof(struct batadv_tt_change_node);
+	size_t tt_req_size = sizeof(struct batadv_tt_req_node);
+	size_t tt_roam_size = sizeof(struct batadv_tt_roam_node);
+
+	batadv_tl_cache = kmem_cache_create("batadv_tl_cache", tl_size, 0,
+					    SLAB_HWCACHE_ALIGN, NULL);
+	if (!batadv_tl_cache)
+		return -ENOMEM;
+
+	batadv_tg_cache = kmem_cache_create("batadv_tg_cache", tg_size, 0,
+					    SLAB_HWCACHE_ALIGN, NULL);
+	if (!batadv_tg_cache)
+		goto err_tt_tl_destroy;
+
+	batadv_tt_orig_cache = kmem_cache_create("batadv_tt_orig_cache",
+						 tt_orig_size, 0,
+						 SLAB_HWCACHE_ALIGN, NULL);
+	if (!batadv_tt_orig_cache)
+		goto err_tt_tg_destroy;
+
+	batadv_tt_change_cache = kmem_cache_create("batadv_tt_change_cache",
+						   tt_change_size, 0,
+						   SLAB_HWCACHE_ALIGN, NULL);
+	if (!batadv_tt_change_cache)
+		goto err_tt_orig_destroy;
+
+	batadv_tt_req_cache = kmem_cache_create("batadv_tt_req_cache",
+						tt_req_size, 0,
+						SLAB_HWCACHE_ALIGN, NULL);
+	if (!batadv_tt_req_cache)
+		goto err_tt_change_destroy;
+
+	batadv_tt_roam_cache = kmem_cache_create("batadv_tt_roam_cache",
+						 tt_roam_size, 0,
+						 SLAB_HWCACHE_ALIGN, NULL);
+	if (!batadv_tt_roam_cache)
+		goto err_tt_req_destroy;
+
+	return 0;
+
+err_tt_req_destroy:
+	kmem_cache_destroy(batadv_tt_req_cache);
+	batadv_tt_req_cache = NULL;
+err_tt_change_destroy:
+	kmem_cache_destroy(batadv_tt_change_cache);
+	batadv_tt_change_cache = NULL;
+err_tt_orig_destroy:
+	kmem_cache_destroy(batadv_tt_orig_cache);
+	batadv_tt_orig_cache = NULL;
+err_tt_tg_destroy:
+	kmem_cache_destroy(batadv_tg_cache);
+	batadv_tg_cache = NULL;
+err_tt_tl_destroy:
+	kmem_cache_destroy(batadv_tl_cache);
+	batadv_tl_cache = NULL;
+
+	return -ENOMEM;
+}
+
+/**
+ * batadv_tt_cache_destroy - Destroy tt memory object cache
+ */
+void batadv_tt_cache_destroy(void)
+{
+	kmem_cache_destroy(batadv_tl_cache);
+	kmem_cache_destroy(batadv_tg_cache);
+	kmem_cache_destroy(batadv_tt_orig_cache);
+	kmem_cache_destroy(batadv_tt_change_cache);
+	kmem_cache_destroy(batadv_tt_req_cache);
+	kmem_cache_destroy(batadv_tt_roam_cache);
+}
diff --git a/net/batman-adv/translation-table.h b/net/batman-adv/translation-table.h
index 7c7e2c0..02b0f85 100644
--- a/net/batman-adv/translation-table.h
+++ b/net/batman-adv/translation-table.h
@@ -59,4 +59,7 @@ bool batadv_tt_add_temporary_global_entry(struct batadv_priv *bat_priv,
 bool batadv_tt_global_is_isolated(struct batadv_priv *bat_priv,
 				  const u8 *addr, unsigned short vid);
 
+int batadv_tt_cache_init(void);
+void batadv_tt_cache_destroy(void);
+
 #endif /* _NET_BATMAN_ADV_TRANSLATION_TABLE_H_ */
-- 
2.8.1
