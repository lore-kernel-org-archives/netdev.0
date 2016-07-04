From: Simon Wunderlich <sw@simonwunderlich.de>
Subject: [PATCH 04/11] batman-adv: move bat_algo functions into a separate file
Date: Mon,  4 Jul 2016 15:02:52 +0200
Message-ID: <1467637379-6089-5-git-send-email-sw@simonwunderlich.de>
References: <1467637379-6089-1-git-send-email-sw@simonwunderlich.de>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Simon Wunderlich <sw@simonwunderlich.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from packetmixer.de ([79.140.42.25]:58216 "EHLO
	mail.mail.packetmixer.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753768AbcGDNDM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jul 2016 09:03:12 -0400
In-Reply-To: <1467637379-6089-1-git-send-email-sw@simonwunderlich.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

The bat_algo functionality in main.c is mostly unrelated to the rest of the
content. It still takes up a large portion of this source file (~15%, 103
lines). Moving it to a separate file makes it better visible as a main
component of the batman-adv implementation and hides it less in the other
helper functions in main.c.

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Simon Wunderlich <sw@simonwunderlich.de>
---
 net/batman-adv/Makefile            |   1 +
 net/batman-adv/bat_algo.c          | 140 +++++++++++++++++++++++++++++++++++++
 net/batman-adv/bat_algo.h          |  12 ++++
 net/batman-adv/bat_v_ogm.c         |   1 +
 net/batman-adv/debugfs.c           |   1 +
 net/batman-adv/main.c              | 105 +---------------------------
 net/batman-adv/main.h              |   4 --
 net/batman-adv/originator.c        |   1 +
 net/batman-adv/routing.c           |   1 +
 net/batman-adv/soft-interface.c    |   1 +
 net/batman-adv/translation-table.c |   1 +
 11 files changed, 160 insertions(+), 108 deletions(-)
 create mode 100644 net/batman-adv/bat_algo.c

diff --git a/net/batman-adv/Makefile b/net/batman-adv/Makefile
index 5c6ece0..5260c17 100644
--- a/net/batman-adv/Makefile
+++ b/net/batman-adv/Makefile
@@ -17,6 +17,7 @@
 #
 
 obj-$(CONFIG_BATMAN_ADV) += batman-adv.o
+batman-adv-y += bat_algo.o
 batman-adv-y += bat_iv_ogm.o
 batman-adv-$(CONFIG_BATMAN_ADV_BATMAN_V) += bat_v.o
 batman-adv-$(CONFIG_BATMAN_ADV_BATMAN_V) += bat_v_elp.o
diff --git a/net/batman-adv/bat_algo.c b/net/batman-adv/bat_algo.c
new file mode 100644
index 0000000..610d4de
--- /dev/null
+++ b/net/batman-adv/bat_algo.c
@@ -0,0 +1,140 @@
+/* Copyright (C) 2007-2016  B.A.T.M.A.N. contributors:
+ *
+ * Marek Lindner, Simon Wunderlich
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
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
+ */
+
+#include "main.h"
+
+#include <linux/errno.h>
+#include <linux/list.h>
+#include <linux/moduleparam.h>
+#include <linux/printk.h>
+#include <linux/seq_file.h>
+#include <linux/stddef.h>
+#include <linux/string.h>
+
+#include "bat_algo.h"
+
+char batadv_routing_algo[20] = "BATMAN_IV";
+static struct hlist_head batadv_algo_list;
+
+/**
+ * batadv_algo_init - Initialize batman-adv algorithm management data structures
+ */
+void batadv_algo_init(void)
+{
+	INIT_HLIST_HEAD(&batadv_algo_list);
+}
+
+static struct batadv_algo_ops *batadv_algo_get(char *name)
+{
+	struct batadv_algo_ops *bat_algo_ops = NULL, *bat_algo_ops_tmp;
+
+	hlist_for_each_entry(bat_algo_ops_tmp, &batadv_algo_list, list) {
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
+int batadv_algo_register(struct batadv_algo_ops *bat_algo_ops)
+{
+	struct batadv_algo_ops *bat_algo_ops_tmp;
+
+	bat_algo_ops_tmp = batadv_algo_get(bat_algo_ops->name);
+	if (bat_algo_ops_tmp) {
+		pr_info("Trying to register already registered routing algorithm: %s\n",
+			bat_algo_ops->name);
+		return -EEXIST;
+	}
+
+	/* all algorithms must implement all ops (for now) */
+	if (!bat_algo_ops->bat_iface_enable ||
+	    !bat_algo_ops->bat_iface_disable ||
+	    !bat_algo_ops->bat_iface_update_mac ||
+	    !bat_algo_ops->bat_primary_iface_set ||
+	    !bat_algo_ops->bat_neigh_cmp ||
+	    !bat_algo_ops->bat_neigh_is_similar_or_better) {
+		pr_info("Routing algo '%s' does not implement required ops\n",
+			bat_algo_ops->name);
+		return -EINVAL;
+	}
+
+	INIT_HLIST_NODE(&bat_algo_ops->list);
+	hlist_add_head(&bat_algo_ops->list, &batadv_algo_list);
+
+	return 0;
+}
+
+int batadv_algo_select(struct batadv_priv *bat_priv, char *name)
+{
+	struct batadv_algo_ops *bat_algo_ops;
+
+	bat_algo_ops = batadv_algo_get(name);
+	if (!bat_algo_ops)
+		return -EINVAL;
+
+	bat_priv->bat_algo_ops = bat_algo_ops;
+
+	return 0;
+}
+
+int batadv_algo_seq_print_text(struct seq_file *seq, void *offset)
+{
+	struct batadv_algo_ops *bat_algo_ops;
+
+	seq_puts(seq, "Available routing algorithms:\n");
+
+	hlist_for_each_entry(bat_algo_ops, &batadv_algo_list, list) {
+		seq_printf(seq, " * %s\n", bat_algo_ops->name);
+	}
+
+	return 0;
+}
+
+static int batadv_param_set_ra(const char *val, const struct kernel_param *kp)
+{
+	struct batadv_algo_ops *bat_algo_ops;
+	char *algo_name = (char *)val;
+	size_t name_len = strlen(algo_name);
+
+	if (name_len > 0 && algo_name[name_len - 1] == '\n')
+		algo_name[name_len - 1] = '\0';
+
+	bat_algo_ops = batadv_algo_get(algo_name);
+	if (!bat_algo_ops) {
+		pr_err("Routing algorithm '%s' is not supported\n", algo_name);
+		return -EINVAL;
+	}
+
+	return param_set_copystring(algo_name, kp);
+}
+
+static const struct kernel_param_ops batadv_param_ops_ra = {
+	.set = batadv_param_set_ra,
+	.get = param_get_string,
+};
+
+static struct kparam_string batadv_param_string_ra = {
+	.maxlen = sizeof(batadv_routing_algo),
+	.string = batadv_routing_algo,
+};
+
+module_param_cb(routing_algo, &batadv_param_ops_ra, &batadv_param_string_ra,
+		0644);
diff --git a/net/batman-adv/bat_algo.h b/net/batman-adv/bat_algo.h
index 3654296..8c7e761 100644
--- a/net/batman-adv/bat_algo.h
+++ b/net/batman-adv/bat_algo.h
@@ -20,8 +20,20 @@
 
 #include "main.h"
 
+#include <linux/types.h>
+
+struct seq_file;
+
 int batadv_iv_init(void);
 
+extern char batadv_routing_algo[];
+extern struct list_head batadv_hardif_list;
+
+void batadv_algo_init(void);
+int batadv_algo_register(struct batadv_algo_ops *bat_algo_ops);
+int batadv_algo_select(struct batadv_priv *bat_priv, char *name);
+int batadv_algo_seq_print_text(struct seq_file *seq, void *offset);
+
 #ifdef CONFIG_BATMAN_ADV_BATMAN_V
 
 int batadv_v_init(void);
diff --git a/net/batman-adv/bat_v_ogm.c b/net/batman-adv/bat_v_ogm.c
index ca5a679..93e3d76 100644
--- a/net/batman-adv/bat_v_ogm.c
+++ b/net/batman-adv/bat_v_ogm.c
@@ -39,6 +39,7 @@
 #include <linux/types.h>
 #include <linux/workqueue.h>
 
+#include "bat_algo.h"
 #include "hard-interface.h"
 #include "hash.h"
 #include "originator.h"
diff --git a/net/batman-adv/debugfs.c b/net/batman-adv/debugfs.c
index f187a8f..227c84b 100644
--- a/net/batman-adv/debugfs.c
+++ b/net/batman-adv/debugfs.c
@@ -44,6 +44,7 @@
 #include <linux/wait.h>
 #include <stdarg.h>
 
+#include "bat_algo.h"
 #include "bridge_loop_avoidance.h"
 #include "distributed-arp-table.h"
 #include "gateway_client.h"
diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index 225d63e..c5a7cab 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -32,7 +32,6 @@
 #include <linux/kref.h>
 #include <linux/list.h>
 #include <linux/module.h>
-#include <linux/moduleparam.h>
 #include <linux/netdevice.h>
 #include <linux/rculist.h>
 #include <linux/rcupdate.h>
@@ -68,8 +67,6 @@
 struct list_head batadv_hardif_list;
 static int (*batadv_rx_handler[256])(struct sk_buff *,
 				     struct batadv_hard_iface *);
-char batadv_routing_algo[20] = "BATMAN_IV";
-static struct hlist_head batadv_algo_list;
 
 unsigned char batadv_broadcast_addr[] = {0xff, 0xff, 0xff, 0xff, 0xff, 0xff};
 
@@ -80,7 +77,7 @@ static void batadv_recv_handler_init(void);
 static int __init batadv_init(void)
 {
 	INIT_LIST_HEAD(&batadv_hardif_list);
-	INIT_HLIST_HEAD(&batadv_algo_list);
+	batadv_algo_init();
 
 	batadv_recv_handler_init();
 
@@ -535,76 +532,6 @@ void batadv_recv_handler_unregister(u8 packet_type)
 	batadv_rx_handler[packet_type] = batadv_recv_unhandled_packet;
 }
 
-static struct batadv_algo_ops *batadv_algo_get(char *name)
-{
-	struct batadv_algo_ops *bat_algo_ops = NULL, *bat_algo_ops_tmp;
-
-	hlist_for_each_entry(bat_algo_ops_tmp, &batadv_algo_list, list) {
-		if (strcmp(bat_algo_ops_tmp->name, name) != 0)
-			continue;
-
-		bat_algo_ops = bat_algo_ops_tmp;
-		break;
-	}
-
-	return bat_algo_ops;
-}
-
-int batadv_algo_register(struct batadv_algo_ops *bat_algo_ops)
-{
-	struct batadv_algo_ops *bat_algo_ops_tmp;
-
-	bat_algo_ops_tmp = batadv_algo_get(bat_algo_ops->name);
-	if (bat_algo_ops_tmp) {
-		pr_info("Trying to register already registered routing algorithm: %s\n",
-			bat_algo_ops->name);
-		return -EEXIST;
-	}
-
-	/* all algorithms must implement all ops (for now) */
-	if (!bat_algo_ops->bat_iface_enable ||
-	    !bat_algo_ops->bat_iface_disable ||
-	    !bat_algo_ops->bat_iface_update_mac ||
-	    !bat_algo_ops->bat_primary_iface_set ||
-	    !bat_algo_ops->bat_neigh_cmp ||
-	    !bat_algo_ops->bat_neigh_is_similar_or_better) {
-		pr_info("Routing algo '%s' does not implement required ops\n",
-			bat_algo_ops->name);
-		return -EINVAL;
-	}
-
-	INIT_HLIST_NODE(&bat_algo_ops->list);
-	hlist_add_head(&bat_algo_ops->list, &batadv_algo_list);
-
-	return 0;
-}
-
-int batadv_algo_select(struct batadv_priv *bat_priv, char *name)
-{
-	struct batadv_algo_ops *bat_algo_ops;
-
-	bat_algo_ops = batadv_algo_get(name);
-	if (!bat_algo_ops)
-		return -EINVAL;
-
-	bat_priv->bat_algo_ops = bat_algo_ops;
-
-	return 0;
-}
-
-int batadv_algo_seq_print_text(struct seq_file *seq, void *offset)
-{
-	struct batadv_algo_ops *bat_algo_ops;
-
-	seq_puts(seq, "Available routing algorithms:\n");
-
-	hlist_for_each_entry(bat_algo_ops, &batadv_algo_list, list) {
-		seq_printf(seq, " * %s\n", bat_algo_ops->name);
-	}
-
-	return 0;
-}
-
 /**
  * batadv_skb_crc32 - calculate CRC32 of the whole packet and skip bytes in
  *  the header
@@ -691,36 +618,6 @@ bool batadv_vlan_ap_isola_get(struct batadv_priv *bat_priv, unsigned short vid)
 	return ap_isolation_enabled;
 }
 
-static int batadv_param_set_ra(const char *val, const struct kernel_param *kp)
-{
-	struct batadv_algo_ops *bat_algo_ops;
-	char *algo_name = (char *)val;
-	size_t name_len = strlen(algo_name);
-
-	if (name_len > 0 && algo_name[name_len - 1] == '\n')
-		algo_name[name_len - 1] = '\0';
-
-	bat_algo_ops = batadv_algo_get(algo_name);
-	if (!bat_algo_ops) {
-		pr_err("Routing algorithm '%s' is not supported\n", algo_name);
-		return -EINVAL;
-	}
-
-	return param_set_copystring(algo_name, kp);
-}
-
-static const struct kernel_param_ops batadv_param_ops_ra = {
-	.set = batadv_param_set_ra,
-	.get = param_get_string,
-};
-
-static struct kparam_string batadv_param_string_ra = {
-	.maxlen = sizeof(batadv_routing_algo),
-	.string = batadv_routing_algo,
-};
-
-module_param_cb(routing_algo, &batadv_param_ops_ra, &batadv_param_string_ra,
-		0644);
 module_init(batadv_init);
 module_exit(batadv_exit);
 
diff --git a/net/batman-adv/main.h b/net/batman-adv/main.h
index 3af6582..3ec6285 100644
--- a/net/batman-adv/main.h
+++ b/net/batman-adv/main.h
@@ -196,7 +196,6 @@ struct sk_buff;
 #define BATADV_PRINT_VID(vid) ((vid & BATADV_VLAN_HAS_TAG) ? \
 			       (int)(vid & VLAN_VID_MASK) : -1)
 
-extern char batadv_routing_algo[];
 extern struct list_head batadv_hardif_list;
 
 extern unsigned char batadv_broadcast_addr[];
@@ -217,9 +216,6 @@ batadv_recv_handler_register(u8 packet_type,
 			     int (*recv_handler)(struct sk_buff *,
 						 struct batadv_hard_iface *));
 void batadv_recv_handler_unregister(u8 packet_type);
-int batadv_algo_register(struct batadv_algo_ops *bat_algo_ops);
-int batadv_algo_select(struct batadv_priv *bat_priv, char *name);
-int batadv_algo_seq_print_text(struct seq_file *seq, void *offset);
 __be32 batadv_skb_crc32(struct sk_buff *skb, u8 *payload_ptr);
 
 /**
diff --git a/net/batman-adv/originator.c b/net/batman-adv/originator.c
index 076d258..592cbda 100644
--- a/net/batman-adv/originator.c
+++ b/net/batman-adv/originator.c
@@ -34,6 +34,7 @@
 #include <linux/spinlock.h>
 #include <linux/workqueue.h>
 
+#include "bat_algo.h"
 #include "distributed-arp-table.h"
 #include "fragmentation.h"
 #include "gateway_client.h"
diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index 8cb459a..b9c7325 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -34,6 +34,7 @@
 #include <linux/spinlock.h>
 #include <linux/stddef.h>
 
+#include "bat_algo.h"
 #include "bitarray.h"
 #include "bridge_loop_avoidance.h"
 #include "distributed-arp-table.h"
diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index b60999d..f75631e 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -48,6 +48,7 @@
 #include <linux/types.h>
 #include <linux/workqueue.h>
 
+#include "bat_algo.h"
 #include "bridge_loop_avoidance.h"
 #include "debugfs.h"
 #include "distributed-arp-table.h"
diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index 6c8d624..5c3cf7f 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -44,6 +44,7 @@
 #include <linux/string.h>
 #include <linux/workqueue.h>
 
+#include "bat_algo.h"
 #include "bridge_loop_avoidance.h"
 #include "hard-interface.h"
 #include "hash.h"
-- 
2.8.1
