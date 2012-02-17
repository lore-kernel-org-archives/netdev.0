From: Marek Lindner <lindner_marek@yahoo.de>
Subject: [PATCH 07/10] batman-adv: add infrastructure to change routing algorithm at runtime
Date: Fri, 17 Feb 2012 15:18:27 +0800
Message-ID: <1329463110-856-8-git-send-email-lindner_marek@yahoo.de>
References: <1329463110-856-1-git-send-email-lindner_marek@yahoo.de>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Marek Lindner <lindner_marek@yahoo.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm19.bullet.mail.ukl.yahoo.com ([217.146.183.193]:23136 "HELO
	nm19.bullet.mail.ukl.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751682Ab2BQHTd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Feb 2012 02:19:33 -0500
In-Reply-To: <1329463110-856-1-git-send-email-lindner_marek@yahoo.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
---
 net/batman-adv/bat_algo.h       |   27 ++++++++++++++
 net/batman-adv/bat_debugfs.c    |   22 ++++++++++++
 net/batman-adv/bat_iv_ogm.c     |   10 +++++
 net/batman-adv/main.c           |   72 +++++++++++++++++++++++++++++++++++++++
 net/batman-adv/main.h           |    4 ++
 net/batman-adv/soft-interface.c |    4 ++
 net/batman-adv/types.h          |    6 +++
 7 files changed, 145 insertions(+), 0 deletions(-)
 create mode 100644 net/batman-adv/bat_algo.h

diff --git a/net/batman-adv/bat_algo.h b/net/batman-adv/bat_algo.h
new file mode 100644
index 0000000..755379f
--- /dev/null
+++ b/net/batman-adv/bat_algo.h
@@ -0,0 +1,27 @@
+/*
+ * Copyright (C) 2011 B.A.T.M.A.N. contributors:
+ *
+ * Marek Lindner
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
+ * 02110-1301, USA
+ *
+ */
+
+#ifndef _NET_BATMAN_ADV_BAT_ALGO_H_
+#define _NET_BATMAN_ADV_BAT_ALGO_H_
+
+int bat_iv_init(void);
+
+#endif /* _NET_BATMAN_ADV_BAT_ALGO_H_ */
diff --git a/net/batman-adv/bat_debugfs.c b/net/batman-adv/bat_debugfs.c
index d0af9bf..a7a393e 100644
--- a/net/batman-adv/bat_debugfs.c
+++ b/net/batman-adv/bat_debugfs.c
@@ -221,6 +221,11 @@ static void debug_log_cleanup(struct bat_priv *bat_priv)
 }
 #endif
 
+static int bat_algorithms_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, bat_algo_seq_print_text, NULL);
+}
+
 static int originators_open(struct inode *inode, struct file *file)
 {
 	struct net_device *net_dev = (struct net_device *)inode->i_private;
@@ -274,6 +279,7 @@ struct bat_debuginfo bat_debuginfo_##_name = {	\
 		}				\
 };
 
+static BAT_DEBUGINFO(routing_algos, S_IRUGO, bat_algorithms_open);
 static BAT_DEBUGINFO(originators, S_IRUGO, originators_open);
 static BAT_DEBUGINFO(gateways, S_IRUGO, gateways_open);
 static BAT_DEBUGINFO(softif_neigh, S_IRUGO, softif_neigh_open);
@@ -293,9 +299,25 @@ static struct bat_debuginfo *mesh_debuginfos[] = {
 
 void debugfs_init(void)
 {
+	struct bat_debuginfo *bat_debug;
+	struct dentry *file;
+
 	bat_debugfs = debugfs_create_dir(DEBUGFS_BAT_SUBDIR, NULL);
 	if (bat_debugfs == ERR_PTR(-ENODEV))
 		bat_debugfs = NULL;
+
+	if (!bat_debugfs)
+		goto out;
+
+	bat_debug = &bat_debuginfo_routing_algos;
+	file = debugfs_create_file(bat_debug->attr.name,
+				   S_IFREG | bat_debug->attr.mode,
+				   bat_debugfs, NULL, &bat_debug->fops);
+	if (!file)
+		pr_err("Can't add debugfs file: %s\n", bat_debug->attr.name);
+
+out:
+	return;
 }
 
 void debugfs_destroy(void)
diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index 3402fa5..1847efa 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -29,6 +29,7 @@
 #include "gateway_client.h"
 #include "hard-interface.h"
 #include "send.h"
+#include "bat_algo.h"
 
 void bat_ogm_init(struct hard_iface *hard_iface)
 {
@@ -1172,3 +1173,12 @@ void bat_ogm_receive(struct hard_iface *if_incoming, struct sk_buff *skb)
 	} while (bat_ogm_aggr_packet(buff_pos, packet_len,
 				     batman_ogm_packet->tt_num_changes));
 }
+
+static struct bat_algo_ops batman_iv __read_mostly = {
+	.name = "BATMAN IV",
+};
+
+int __init bat_iv_init(void)
+{
+	return bat_algo_register(&batman_iv);
+}
diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index 71b56cf..7c87a34 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -32,11 +32,14 @@
 #include "gateway_client.h"
 #include "vis.h"
 #include "hash.h"
+#include "bat_algo.h"
 
 
 /* List manipulations on hardif_list have to be rtnl_lock()'ed,
  * list traversals just rcu-locked */
 struct list_head hardif_list;
+char bat_routing_algo[20] = "BATMAN IV";
+static struct hlist_head bat_algo_list;
 
 unsigned char broadcast_addr[] = {0xff, 0xff, 0xff, 0xff, 0xff, 0xff};
 
@@ -45,6 +48,9 @@ struct workqueue_struct *bat_event_workqueue;
 static int __init batman_init(void)
 {
 	INIT_LIST_HEAD(&hardif_list);
+	INIT_HLIST_HEAD(&bat_algo_list);
+
+	bat_iv_init();
 
 	/* the name should not be longer than 10 chars - see
 	 * http://lwn.net/Articles/23634/ */
@@ -172,6 +178,72 @@ int is_my_mac(const uint8_t *addr)
 	return 0;
 }
 
+static struct bat_algo_ops *bat_algo_get(char *name)
+{
+	struct bat_algo_ops *bat_algo_ops = NULL, *bat_algo_ops_tmp;
+	struct hlist_node *node;
+
+	hlist_for_each_entry(bat_algo_ops_tmp, node, &bat_algo_list, list) {
+		if (strcmp(bat_algo_ops_tmp->name, name) != 0)
+			continue;
+
+		bat_algo_ops = bat_algo_ops_tmp;
+		break;
+	}
+
+	return bat_algo_ops;
+}
+
+int bat_algo_register(struct bat_algo_ops *bat_algo_ops)
+{
+	struct bat_algo_ops *bat_algo_ops_tmp;
+	int ret = -1;
+
+	bat_algo_ops_tmp = bat_algo_get(bat_algo_ops->name);
+	if (bat_algo_ops_tmp) {
+		pr_info("Trying to register already registered routing "
+			"algorithm: %s\n", bat_algo_ops->name);
+		goto out;
+	}
+
+	INIT_HLIST_NODE(&bat_algo_ops->list);
+	hlist_add_head(&bat_algo_ops->list, &bat_algo_list);
+	ret = 0;
+
+out:
+	return ret;
+}
+
+int bat_algo_select(struct bat_priv *bat_priv, char *name)
+{
+	struct bat_algo_ops *bat_algo_ops;
+	int ret = -1;
+
+	bat_algo_ops = bat_algo_get(name);
+	if (!bat_algo_ops)
+		goto out;
+
+	bat_priv->bat_algo_ops = bat_algo_ops;
+	ret = 0;
+
+out:
+	return ret;
+}
+
+int bat_algo_seq_print_text(struct seq_file *seq, void *offset)
+{
+	struct bat_algo_ops *bat_algo_ops;
+	struct hlist_node *node;
+
+	seq_printf(seq, "Available routing algorithms:\n");
+
+	hlist_for_each_entry(bat_algo_ops, node, &bat_algo_list, list) {
+		seq_printf(seq, "%s\n", bat_algo_ops->name);
+	}
+
+	return 0;
+}
+
 module_init(batman_init);
 module_exit(batman_exit);
 
diff --git a/net/batman-adv/main.h b/net/batman-adv/main.h
index f9c659b..586afaf 100644
--- a/net/batman-adv/main.h
+++ b/net/batman-adv/main.h
@@ -147,6 +147,7 @@ enum dbg_level {
 #include <linux/seq_file.h>
 #include "types.h"
 
+extern char bat_routing_algo[];
 extern struct list_head hardif_list;
 
 extern unsigned char broadcast_addr[];
@@ -157,6 +158,9 @@ void mesh_free(struct net_device *soft_iface);
 void inc_module_count(void);
 void dec_module_count(void);
 int is_my_mac(const uint8_t *addr);
+int bat_algo_register(struct bat_algo_ops *bat_algo_ops);
+int bat_algo_select(struct bat_priv *bat_priv, char *name);
+int bat_algo_seq_print_text(struct seq_file *seq, void *offset);
 
 #ifdef CONFIG_BATMAN_ADV_DEBUG
 int debug_log(struct bat_priv *bat_priv, const char *fmt, ...) __printf(2, 3);
diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index bd8c7cf..b5aecd5 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -855,6 +855,10 @@ struct net_device *softif_create(const char *name)
 	bat_priv->primary_if = NULL;
 	bat_priv->num_ifaces = 0;
 
+	ret = bat_algo_select(bat_priv, bat_routing_algo);
+	if (ret < 0)
+		goto unreg_soft_iface;
+
 	ret = sysfs_add_meshif(soft_iface);
 	if (ret < 0)
 		goto unreg_soft_iface;
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index 35085f41..d21ff2c 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -206,6 +206,7 @@ struct bat_priv {
 	atomic_t gw_reselect;
 	struct hard_iface __rcu *primary_if;  /* rcu protected pointer */
 	struct vis_info *my_vis_info;
+	struct bat_algo_ops *bat_algo_ops;
 };
 
 struct socket_client {
@@ -344,4 +345,9 @@ struct softif_neigh {
 	struct rcu_head rcu;
 };
 
+struct bat_algo_ops {
+	struct hlist_node list;
+	char *name;
+};
+
 #endif /* _NET_BATMAN_ADV_TYPES_H_ */
-- 
1.7.9
