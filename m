From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 06/11] batman-adv: Allow to use rntl_link for device creation/deletion
Date: Thu, 28 Mar 2013 08:50:26 +0100
Message-ID: <1364457031-3194-7-git-send-email-ordex@autistici.org>
References: <1364457031-3194-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Marek Lindner <lindner_marek@yahoo.de>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from diserzione.investici.org ([82.221.99.153]:33342 "EHLO
	diserzione.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756647Ab3C1HwL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Mar 2013 03:52:11 -0400
In-Reply-To: <1364457031-3194-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

The sysfs configuration interface of batman-adv to add/remove soft-interfaces
is not deadlock free and doesn't follow the currently common way to create new
virtual interfaces.

An additional interface though rtnl_link is introduced which provides easy device
creation/deletion with tools like "ip":

$ ip link add dev bat0 type batadv
$ ip link del dev bat0

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/main.c           |  2 ++
 net/batman-adv/main.h           |  1 +
 net/batman-adv/soft-interface.c | 29 +++++++++++++++++++++++++++++
 net/batman-adv/soft-interface.h |  1 +
 4 files changed, 33 insertions(+)

diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index 0495a7d..62b1f89 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -71,6 +71,7 @@ static int __init batadv_init(void)
 	batadv_debugfs_init();
 
 	register_netdevice_notifier(&batadv_hard_if_notifier);
+	rtnl_link_register(&batadv_link_ops);
 
 	pr_info("B.A.T.M.A.N. advanced %s (compatibility version %i) loaded\n",
 		BATADV_SOURCE_VERSION, BATADV_COMPAT_VERSION);
@@ -81,6 +82,7 @@ static int __init batadv_init(void)
 static void __exit batadv_exit(void)
 {
 	batadv_debugfs_destroy();
+	rtnl_link_unregister(&batadv_link_ops);
 	unregister_netdevice_notifier(&batadv_hard_if_notifier);
 	batadv_hardif_remove_interfaces();
 
diff --git a/net/batman-adv/main.h b/net/batman-adv/main.h
index 0afd4ee..a9e12e6 100644
--- a/net/batman-adv/main.h
+++ b/net/batman-adv/main.h
@@ -152,6 +152,7 @@ enum batadv_uev_type {
 #include <linux/percpu.h>
 #include <linux/slab.h>
 #include <net/sock.h>		/* struct sock */
+#include <net/rtnetlink.h>
 #include <linux/jiffies.h>
 #include <linux/seq_file.h>
 #include "types.h"
diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index bc77a5be..545c863 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -570,6 +570,8 @@ struct net_device *batadv_softif_create(const char *name)
 	if (!soft_iface)
 		return NULL;
 
+	soft_iface->rtnl_link_ops = &batadv_link_ops;
+
 	ret = register_netdevice(soft_iface);
 	if (ret < 0) {
 		pr_err("Unable to register the batman interface '%s': %i\n",
@@ -592,6 +594,26 @@ void batadv_softif_destroy_sysfs(struct net_device *soft_iface)
 	queue_work(batadv_event_workqueue, &bat_priv->cleanup_work);
 }
 
+/**
+ * batadv_softif_destroy_netlink - deletion of batadv_soft_interface via netlink
+ * @soft_iface: the to-be-removed batman-adv interface
+ * @head: list pointer
+ */
+static void batadv_softif_destroy_netlink(struct net_device *soft_iface,
+					  struct list_head *head)
+{
+	struct batadv_hard_iface *hard_iface;
+
+	list_for_each_entry(hard_iface, &batadv_hardif_list, list) {
+		if (hard_iface->soft_iface == soft_iface)
+			batadv_hardif_disable_interface(hard_iface,
+							BATADV_IF_CLEANUP_KEEP);
+	}
+
+	batadv_sysfs_del_meshif(soft_iface);
+	unregister_netdevice_queue(soft_iface, head);
+}
+
 int batadv_softif_is_valid(const struct net_device *net_dev)
 {
 	if (net_dev->netdev_ops->ndo_start_xmit == batadv_interface_tx)
@@ -600,6 +622,13 @@ int batadv_softif_is_valid(const struct net_device *net_dev)
 	return 0;
 }
 
+struct rtnl_link_ops batadv_link_ops __read_mostly = {
+	.kind		= "batadv",
+	.priv_size	= sizeof(struct batadv_priv),
+	.setup		= batadv_softif_init_early,
+	.dellink	= batadv_softif_destroy_netlink,
+};
+
 /* ethtool */
 static int batadv_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
diff --git a/net/batman-adv/soft-interface.h b/net/batman-adv/soft-interface.h
index 49bc66b..2f2472c 100644
--- a/net/batman-adv/soft-interface.h
+++ b/net/batman-adv/soft-interface.h
@@ -27,5 +27,6 @@ void batadv_interface_rx(struct net_device *soft_iface,
 struct net_device *batadv_softif_create(const char *name);
 void batadv_softif_destroy_sysfs(struct net_device *soft_iface);
 int batadv_softif_is_valid(const struct net_device *net_dev);
+extern struct rtnl_link_ops batadv_link_ops;
 
 #endif /* _NET_BATMAN_ADV_SOFT_INTERFACE_H_ */
-- 
1.8.1.5
