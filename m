From: Joe Perches <joe@perches.com>
Subject: [RFC PATCH net-next 3/7] include/linux/netdevice.h: Add netif_printk helpers
Date: Tue,  9 Feb 2010 13:49:49 -0800
Message-ID: <1351d126f4427a3d42caa4e16598a3cd36948514.1265751024.git.joe@perches.com>
References: <cover.1265751023.git.joe@perches.com>
Cc: netdev@vger.kernel.org, Ben Hutchings <bhutchings@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1910 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754206Ab0BIVtz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Feb 2010 16:49:55 -0500
In-Reply-To: <cover.1265751023.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add macros to test a private structure for msg_enable bits
and the netif_msg_##bit to test and call netdev_printk if set

Simplifies logic in callers and adds message logging consistency

Signed-off-by: Joe Perches <joe@perches.com>
---
 include/linux/netdevice.h |   53 +++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 53 insertions(+), 0 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 30ed7e0..6d7935f 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2162,6 +2162,59 @@ do {								\
 #define netdev_WARN(dev, format, args...)			\
 	WARN(1, "netdevice: %s\n" format, netdev_name(dev), ##args);
 
+/* netif printk helpers, similar to netdev_printk */
+
+#define netif_printk(priv, type, level, dev, fmt, args...)	\
+do {					  			\
+	if (netif_msg_##type(priv))				\
+		netdev_printk(level, (dev), fmt, ##args);	\
+} while (0)
+
+#define netif_emerg(priv, type, dev, fmt, args...)		\
+	netif_printk(priv, type, KERN_EMERG, dev, fmt, ##args)
+#define netif_alert(priv, type, dev, fmt, args...)		\
+	netif_printk(priv, type, KERN_ALERT, dev, fmt, ##args)
+#define netif_crit(priv, type, dev, fmt, args...)		\
+	netif_printk(priv, type, KERN_CRIT, dev, fmt, ##args)
+#define netif_err(priv, type, dev, fmt, args...)		\
+	netif_printk(priv, type, KERN_ERR, dev, fmt, ##args)
+#define netif_warn(priv, type, dev, fmt, args...)		\
+	netif_printk(priv, type, KERN_WARNING, dev, fmt, ##args)
+#define netif_notice(priv, type, dev, fmt, args...)		\
+	netif_printk(priv, type, KERN_NOTICE, dev, fmt, ##args)
+#define netif_info(priv, type, dev, fmt, args...)		\
+	netif_printk(priv, type, KERN_INFO, (dev), fmt, ##args)
+
+#if defined(DEBUG)
+#define netif_dbg(priv, type, dev, format, args...)		\
+	netif_printk(priv, type, KERN_DEBUG, dev, format, ##args)
+#elif defined(CONFIG_DYNAMIC_DEBUG)
+#define netif_dbg(priv, type, netdev, format, args...)		\
+do {								\
+	if (netif_msg_##type(priv))				\
+		dynamic_dev_dbg((netdev)->dev.parent,		\
+				"%s: " format,			\
+				netdev_name(netdev), ##args);	\
+} while (0)
+#else
+#define netif_dbg(priv, type, dev, format, args...)			\
+({									\
+	if (0)								\
+		netif_printk(priv, type, KERN_DEBUG, dev, format, ##args); \
+	0;								\
+})
+#endif
+
+#if defined(VERBOSE_DEBUG)
+#define netif_vdbg	netdev_dbg
+#else
+#define netif_vdbg(priv, type, dev, format, args...)		\
+({								\
+	if (0)							\
+		netif_printk(KERN_DEBUG, dev, format, ##args);	\
+	0;							\
+})
+#endif
 
 #endif /* __KERNEL__ */
 
-- 
1.7.0.rc1.33.g07cf0f

