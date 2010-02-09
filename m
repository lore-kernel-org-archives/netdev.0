From: Joe Perches <joe@perches.com>
Subject: [RFC PATCH net-next 1/7] netdevice.h: Add netdev_printk helpers like dev_printk
Date: Tue,  9 Feb 2010 13:49:47 -0800
Message-ID: <b3f7e598cd70314ba07fd9653862173f77d000c6.1265751024.git.joe@perches.com>
References: <cover.1265751023.git.joe@perches.com>
Cc: netdev@vger.kernel.org, Ben Hutchings <bhutchings@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1904 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753429Ab0BIVtz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Feb 2010 16:49:55 -0500
In-Reply-To: <cover.1265751023.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These netdev_printk routines take a struct net_device * and emit
dev_printk logging messages adding "%s: " ... netdev->dev.parent
to the dev_printk format and arguments.

This can create some uniformity in the output message log.

These helpers should not be used until a successful alloc_netdev.

Signed-off-by: Joe Perches <joe@perches.com>
---
 include/linux/netdevice.h |   71 +++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 71 insertions(+), 0 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index e535700..30ed7e0 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2092,6 +2092,77 @@ static inline u32 dev_ethtool_get_flags(struct net_device *dev)
 		return 0;
 	return dev->ethtool_ops->get_flags(dev);
 }
+
+/* Logging, debugging and troubleshooting/diagnostic helpers. */
+
+/* netdev_printk helpers, similar to dev_printk */
+
+static inline const char *netdev_name(const struct net_device *dev)
+{
+	if (dev->reg_state != NETREG_REGISTERED)
+		return "(unregistered net_device)";
+	return dev->name;
+}
+
+#define netdev_printk(level, netdev, format, args...)		\
+	dev_printk(level, (netdev)->dev.parent,			\
+		   "%s: " format,				\
+		   netdev_name(netdev), ##args)
+
+#define netdev_emerg(dev, format, args...)			\
+	netdev_printk(KERN_EMERG, dev, format, ##args)
+#define netdev_alert(dev, format, args...)			\
+	netdev_printk(KERN_ALERT, dev, format, ##args)
+#define netdev_crit(dev, format, args...)			\
+	netdev_printk(KERN_CRIT, dev, format, ##args)
+#define netdev_err(dev, format, args...)			\
+	netdev_printk(KERN_ERR, dev, format, ##args)
+#define netdev_warn(dev, format, args...)			\
+	netdev_printk(KERN_WARNING, dev, format, ##args)
+#define netdev_notice(dev, format, args...)			\
+	netdev_printk(KERN_NOTICE, dev, format, ##args)
+#define netdev_info(dev, format, args...)			\
+	netdev_printk(KERN_INFO, dev, format, ##args)
+
+#if defined(DEBUG)
+#define netdev_dbg(dev, format, args...)			\
+	netdev_printk(KERN_DEBUG, dev, format, ##args)
+#elif defined(CONFIG_DYNAMIC_DEBUG)
+#define netdev_dbg(dev, format, args...)			\
+do {								\
+	dynamic_dev_dbg((dev)->dev.parent, "%s: " format,	\
+			netdev_name(dev), ##args);		\
+} while (0)
+#else
+#define netdev_dbg(dev, format, args...)			\
+({								\
+	if (0)							\
+		netdev_printk(KERN_DEBUG, dev, format, ##args);	\
+	0;							\
+})
+#endif
+
+#if defined(VERBOSE_DEBUG)
+#define netdev_vdbg	netdev_dbg
+#else
+
+#define netdev_vdbg(dev, format, args...)			\
+({								\
+	if (0)							\
+		netdev_printk(KERN_DEBUG, dev, format, ##args);	\
+	0;							\
+})
+#endif
+
+/*
+ * netdev_WARN() acts like dev_printk(), but with the key difference
+ * of using a WARN/WARN_ON to get the message out, including the
+ * file/line information and a backtrace.
+ */
+#define netdev_WARN(dev, format, args...)			\
+	WARN(1, "netdevice: %s\n" format, netdev_name(dev), ##args);
+
+
 #endif /* __KERNEL__ */
 
 #endif	/* _LINUX_NETDEVICE_H */
-- 
1.7.0.rc1.33.g07cf0f

