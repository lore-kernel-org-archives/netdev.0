From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 05/16] batman-adv: debugfs, avoid compiling for !DEBUG_FS
Date: Fri, 29 May 2015 11:05:17 +0200
Message-ID: <1432890328-8247-6-git-send-email-antonio@meshcoding.com>
References: <1432890328-8247-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Markus Pargmann <mpa@pengutronix.de>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <antonio@meshcoding.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s1.neomailbox.net ([5.148.176.57]:7646 "EHLO s1.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755712AbbE2JVl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 May 2015 05:21:41 -0400
In-Reply-To: <1432890328-8247-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Markus Pargmann <mpa@pengutronix.de>

Normally the debugfs framework will return error pointer with -ENODEV
for function calls when DEBUG_FS is not set.

batman does not notice this error code and continues trying to create
debugfs files and executes more code. We can avoid this code execution
by disabling compiling debugfs.c when DEBUG_FS is not set.

Signed-off-by: Markus Pargmann <mpa@pengutronix.de>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
---
 net/batman-adv/Makefile  |  2 +-
 net/batman-adv/debugfs.c |  8 --------
 net/batman-adv/debugfs.h | 34 ++++++++++++++++++++++++++++++++++
 3 files changed, 35 insertions(+), 9 deletions(-)

diff --git a/net/batman-adv/Makefile b/net/batman-adv/Makefile
index 79833eb..bd7e343 100644
--- a/net/batman-adv/Makefile
+++ b/net/batman-adv/Makefile
@@ -20,7 +20,7 @@ obj-$(CONFIG_BATMAN_ADV) += batman-adv.o
 batman-adv-y += bat_iv_ogm.o
 batman-adv-y += bitarray.o
 batman-adv-$(CONFIG_BATMAN_ADV_BLA) += bridge_loop_avoidance.o
-batman-adv-y += debugfs.o
+batman-adv-$(CONFIG_DEBUG_FS) += debugfs.o
 batman-adv-$(CONFIG_BATMAN_ADV_DAT) += distributed-arp-table.o
 batman-adv-y += fragmentation.o
 batman-adv-y += gateway_client.o
diff --git a/net/batman-adv/debugfs.c b/net/batman-adv/debugfs.c
index 0c213a8..4611808 100644
--- a/net/batman-adv/debugfs.c
+++ b/net/batman-adv/debugfs.c
@@ -482,11 +482,7 @@ rem_attr:
 	debugfs_remove_recursive(hard_iface->debug_dir);
 	hard_iface->debug_dir = NULL;
 out:
-#ifdef CONFIG_DEBUG_FS
 	return -ENOMEM;
-#else
-	return 0;
-#endif /* CONFIG_DEBUG_FS */
 }
 
 /**
@@ -541,11 +537,7 @@ rem_attr:
 	debugfs_remove_recursive(bat_priv->debug_dir);
 	bat_priv->debug_dir = NULL;
 out:
-#ifdef CONFIG_DEBUG_FS
 	return -ENOMEM;
-#else
-	return 0;
-#endif /* CONFIG_DEBUG_FS */
 }
 
 void batadv_debugfs_del_meshif(struct net_device *dev)
diff --git a/net/batman-adv/debugfs.h b/net/batman-adv/debugfs.h
index f3b49c3..ed25605 100644
--- a/net/batman-adv/debugfs.h
+++ b/net/batman-adv/debugfs.h
@@ -20,6 +20,8 @@
 
 #define BATADV_DEBUGFS_SUBDIR "batman_adv"
 
+#if IS_ENABLED(CONFIG_DEBUG_FS)
+
 void batadv_debugfs_init(void);
 void batadv_debugfs_destroy(void);
 int batadv_debugfs_add_meshif(struct net_device *dev);
@@ -27,4 +29,36 @@ void batadv_debugfs_del_meshif(struct net_device *dev);
 int batadv_debugfs_add_hardif(struct batadv_hard_iface *hard_iface);
 void batadv_debugfs_del_hardif(struct batadv_hard_iface *hard_iface);
 
+#else
+
+static inline void batadv_debugfs_init(void)
+{
+}
+
+static inline void batadv_debugfs_destroy(void)
+{
+}
+
+static inline int batadv_debugfs_add_meshif(struct net_device *dev)
+{
+	return 0;
+}
+
+static inline void batadv_debugfs_del_meshif(struct net_device *dev)
+{
+}
+
+static inline
+int batadv_debugfs_add_hardif(struct batadv_hard_iface *hard_iface)
+{
+	return 0;
+}
+
+static inline
+void batadv_debugfs_del_hardif(struct batadv_hard_iface *hard_iface)
+{
+}
+
+#endif
+
 #endif /* _NET_BATMAN_ADV_DEBUGFS_H_ */
-- 
2.4.2
