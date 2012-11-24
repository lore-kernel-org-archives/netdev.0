From: Sven Eckelmann <sven@narfation.org>
Subject: [PATCH 6/7] batman-adv: Allow to use rntl_link for device creation/deletion
Date: Sat, 24 Nov 2012 01:02:11 +0100
Message-ID: <1353715332-4284-6-git-send-email-sven@narfation.org>
References: <1353715332-4284-1-git-send-email-sven@narfation.org>
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Sven Eckelmann <sven@narfation.org>
To: b.a.t.m.a.n@lists.open-mesh.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from narfation.org ([79.140.41.39]:40443 "EHLO v3-1039.vlinux.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932354Ab2KXACX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Nov 2012 19:02:23 -0500
In-Reply-To: <1353715332-4284-1-git-send-email-sven@narfation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The sysfs configuration interface of batman-adv to add/remove soft-interfaces
is not deadlock free and doesn't follow the currently common way to create new
virtual interfaces.

An additional interface though rtnl_link is introduced which provides easy device
creation/deletion with tools like "ip":

$ ip link add dev bat0 type batadv
$ ip link del dev bat0

Signed-off-by: Sven Eckelmann <sven@narfation.org>
---
 net/batman-adv/main.c           |    2 ++
 net/batman-adv/main.h           |    1 +
 net/batman-adv/soft-interface.c |    9 +++++++++
 net/batman-adv/soft-interface.h |    1 +
 4 files changed, 13 insertions(+)

diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index f65a222..9b180a1 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -70,6 +70,7 @@ static int __init batadv_init(void)
 	batadv_debugfs_init();
 
 	register_netdevice_notifier(&batadv_hard_if_notifier);
+	rtnl_link_register(&batadv_link_ops);
 
 	pr_info("B.A.T.M.A.N. advanced %s (compatibility version %i) loaded\n",
 		BATADV_SOURCE_VERSION, BATADV_COMPAT_VERSION);
@@ -80,6 +81,7 @@ static int __init batadv_init(void)
 static void __exit batadv_exit(void)
 {
 	batadv_debugfs_destroy();
+	rtnl_link_unregister(&batadv_link_ops);
 	unregister_netdevice_notifier(&batadv_hard_if_notifier);
 	batadv_hardif_remove_interfaces();
 
diff --git a/net/batman-adv/main.h b/net/batman-adv/main.h
index 2f85577..605b125 100644
--- a/net/batman-adv/main.h
+++ b/net/batman-adv/main.h
@@ -148,6 +148,7 @@ enum batadv_uev_type {
 #include <linux/percpu.h>
 #include <linux/slab.h>
 #include <net/sock.h>		/* struct sock */
+#include <net/rtnetlink.h>
 #include <linux/jiffies.h>
 #include <linux/seq_file.h>
 #include "types.h"
diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index 68832f5..fcb510e 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -533,6 +533,8 @@ struct net_device *batadv_softif_create(const char *name)
 	if (!soft_iface)
 		return NULL;
 
+	soft_iface->rtnl_link_ops = &batadv_link_ops;
+
 	ret = register_netdevice(soft_iface);
 	if (ret < 0) {
 		pr_err("Unable to register the batman interface '%s': %i\n",
@@ -567,6 +569,13 @@ int batadv_softif_is_valid(const struct net_device *net_dev)
 	return 0;
 }
 
+struct rtnl_link_ops batadv_link_ops __read_mostly = {
+	.kind		= "batadv",
+	.priv_size	= sizeof(struct batadv_priv),
+	.setup		= batadv_interface_setup,
+	.dellink	= batadv_softif_destroy,
+};
+
 /* ethtool */
 static int batadv_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
diff --git a/net/batman-adv/soft-interface.h b/net/batman-adv/soft-interface.h
index fe9b0f7..5eecc6e 100644
--- a/net/batman-adv/soft-interface.h
+++ b/net/batman-adv/soft-interface.h
@@ -28,5 +28,6 @@ struct net_device *batadv_softif_create(const char *name);
 void batadv_softif_destroy(struct net_device *soft_iface,
 			   struct list_head *head);
 int batadv_softif_is_valid(const struct net_device *net_dev);
+extern struct rtnl_link_ops batadv_link_ops;
 
 #endif /* _NET_BATMAN_ADV_SOFT_INTERFACE_H_ */
-- 
1.7.10.4
