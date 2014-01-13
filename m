From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 07/14] batman-adv: add debugfs structure for information per interface
Date: Mon, 13 Jan 2014 23:31:31 +0100
Message-ID: <1389652298-472-8-git-send-email-antonio@meshcoding.com>
References: <1389652298-472-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Simon Wunderlich <simon@open-mesh.com>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <antonio@meshcoding.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:6783 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751499AbaAMWdq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jan 2014 17:33:46 -0500
In-Reply-To: <1389652298-472-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Wunderlich <simon@open-mesh.com>

To show information per interface, add a debugfs hardif structure
similar to the system in sysfs. Hard interface folders will be created
in "$debugfs/batman-adv/". Files are not yet added.

Signed-off-by: Simon Wunderlich <simon@open-mesh.com>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
---
 net/batman-adv/debugfs.c        | 73 +++++++++++++++++++++++++++++++++++++++++
 net/batman-adv/debugfs.h        |  2 ++
 net/batman-adv/hard-interface.c |  9 +++++
 net/batman-adv/types.h          |  2 ++
 4 files changed, 86 insertions(+)

diff --git a/net/batman-adv/debugfs.c b/net/batman-adv/debugfs.c
index 0adbcee..2ea3695 100644
--- a/net/batman-adv/debugfs.c
+++ b/net/batman-adv/debugfs.c
@@ -369,6 +369,25 @@ static struct batadv_debuginfo *batadv_mesh_debuginfos[] = {
 	NULL,
 };
 
+#define BATADV_HARDIF_DEBUGINFO(_name, _mode, _open)		\
+struct batadv_debuginfo batadv_hardif_debuginfo_##_name = {	\
+	.attr = {						\
+		.name = __stringify(_name),			\
+		.mode = _mode,					\
+	},							\
+	.fops = {						\
+		.owner = THIS_MODULE,				\
+		.open = _open,					\
+		.read	= seq_read,				\
+		.llseek = seq_lseek,				\
+		.release = single_release,			\
+	},							\
+};
+
+static struct batadv_debuginfo *batadv_hardif_debuginfos[] = {
+	NULL,
+};
+
 void batadv_debugfs_init(void)
 {
 	struct batadv_debuginfo **bat_debug;
@@ -396,6 +415,7 @@ void batadv_debugfs_init(void)
 	return;
 err:
 	debugfs_remove_recursive(batadv_debugfs);
+	batadv_debugfs = NULL;
 }
 
 void batadv_debugfs_destroy(void)
@@ -404,6 +424,59 @@ void batadv_debugfs_destroy(void)
 	batadv_debugfs = NULL;
 }
 
+/**
+ * batadv_debugfs_add_hardif - creates the base directory for a hard interface
+ *  in debugfs.
+ * @hard_iface: hard interface which should be added.
+ */
+int batadv_debugfs_add_hardif(struct batadv_hard_iface *hard_iface)
+{
+	struct batadv_debuginfo **bat_debug;
+	struct dentry *file;
+
+	if (!batadv_debugfs)
+		goto out;
+
+	hard_iface->debug_dir = debugfs_create_dir(hard_iface->net_dev->name,
+						   batadv_debugfs);
+	if (!hard_iface->debug_dir)
+		goto out;
+
+	for (bat_debug = batadv_hardif_debuginfos; *bat_debug; ++bat_debug) {
+		file = debugfs_create_file(((*bat_debug)->attr).name,
+					   S_IFREG | ((*bat_debug)->attr).mode,
+					   hard_iface->debug_dir,
+					   hard_iface->net_dev,
+					   &(*bat_debug)->fops);
+		if (!file)
+			goto rem_attr;
+	}
+
+	return 0;
+rem_attr:
+	debugfs_remove_recursive(hard_iface->debug_dir);
+	hard_iface->debug_dir = NULL;
+out:
+#ifdef CONFIG_DEBUG_FS
+	return -ENOMEM;
+#else
+	return 0;
+#endif /* CONFIG_DEBUG_FS */
+}
+
+/**
+ * batadv_debugfs_del_hardif - delete the base directory for a hard interface
+ *  in debugfs.
+ * @hard_iface: hard interface which is deleted.
+ */
+void batadv_debugfs_del_hardif(struct batadv_hard_iface *hard_iface)
+{
+	if (batadv_debugfs) {
+		debugfs_remove_recursive(hard_iface->debug_dir);
+		hard_iface->debug_dir = NULL;
+	}
+}
+
 int batadv_debugfs_add_meshif(struct net_device *dev)
 {
 	struct batadv_priv *bat_priv = netdev_priv(dev);
diff --git a/net/batman-adv/debugfs.h b/net/batman-adv/debugfs.h
index 0861b62..981794f 100644
--- a/net/batman-adv/debugfs.h
+++ b/net/batman-adv/debugfs.h
@@ -24,5 +24,7 @@ void batadv_debugfs_init(void);
 void batadv_debugfs_destroy(void);
 int batadv_debugfs_add_meshif(struct net_device *dev);
 void batadv_debugfs_del_meshif(struct net_device *dev);
+int batadv_debugfs_add_hardif(struct batadv_hard_iface *hard_iface);
+void batadv_debugfs_del_hardif(struct batadv_hard_iface *hard_iface);
 
 #endif /* _NET_BATMAN_ADV_DEBUGFS_H_ */
diff --git a/net/batman-adv/hard-interface.c b/net/batman-adv/hard-interface.c
index bebd46ce..3f0e41a 100644
--- a/net/batman-adv/hard-interface.c
+++ b/net/batman-adv/hard-interface.c
@@ -23,6 +23,7 @@
 #include "translation-table.h"
 #include "routing.h"
 #include "sysfs.h"
+#include "debugfs.h"
 #include "originator.h"
 #include "hash.h"
 #include "bridge_loop_avoidance.h"
@@ -539,6 +540,7 @@ static void batadv_hardif_remove_interface_finish(struct work_struct *work)
 	hard_iface = container_of(work, struct batadv_hard_iface,
 				  cleanup_work);
 
+	batadv_debugfs_del_hardif(hard_iface);
 	batadv_sysfs_del_hardif(&hard_iface->hardif_obj);
 	batadv_hardif_free_ref(hard_iface);
 }
@@ -569,6 +571,11 @@ batadv_hardif_add_interface(struct net_device *net_dev)
 	hard_iface->net_dev = net_dev;
 	hard_iface->soft_iface = NULL;
 	hard_iface->if_status = BATADV_IF_NOT_IN_USE;
+
+	ret = batadv_debugfs_add_hardif(hard_iface);
+	if (ret)
+		goto free_sysfs;
+
 	INIT_LIST_HEAD(&hard_iface->list);
 	INIT_WORK(&hard_iface->cleanup_work,
 		  batadv_hardif_remove_interface_finish);
@@ -585,6 +592,8 @@ batadv_hardif_add_interface(struct net_device *net_dev)
 
 	return hard_iface;
 
+free_sysfs:
+	batadv_sysfs_del_hardif(&hard_iface->hardif_obj);
 free_if:
 	kfree(hard_iface);
 release_dev:
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index 1409279..529b374 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -84,6 +84,7 @@ struct batadv_hard_iface_bat_iv {
  * @rcu: struct used for freeing in an RCU-safe manner
  * @bat_iv: BATMAN IV specific per hard interface data
  * @cleanup_work: work queue callback item for hard interface deinit
+ * @debug_dir: dentry for nc subdir in batman-adv directory in debugfs
  */
 struct batadv_hard_iface {
 	struct list_head list;
@@ -98,6 +99,7 @@ struct batadv_hard_iface {
 	struct rcu_head rcu;
 	struct batadv_hard_iface_bat_iv bat_iv;
 	struct work_struct cleanup_work;
+	struct dentry *debug_dir;
 };
 
 /**
-- 
1.8.5.2
