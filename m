From: Joe Perches <joe@perches.com>
Subject: [PATCH 3/4] netdevice.h net/core/dev.c: Convert netdev_<level> logging macros to functions
Date: Sun, 27 Jun 2010 04:02:35 -0700
Message-ID: <eb41161d2a328018836a4d7612cedac1068b6b7e.1277636090.git.joe@perches.com>
References: <cover.1277636090.git.joe@perches.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1277636090.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Reduces an x86 defconfig text and data ~2k.
text is smaller, data is larger.

$ size vmlinux*
   text	   data	    bss	    dec	    hex	filename
7198862	 720112	1366288	9285262	 8dae8e	vmlinux
7205273	 716016	1366288	9287577	 8db799	vmlinux.device_h

Uses %pV and struct va_format
Format arguments are verified before printk

Signed-off-by: Joe Perches <joe@perches.com>
---
 include/linux/netdevice.h |   36 ++++++++++++-------------
 net/core/dev.c            |   62 +++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 79 insertions(+), 19 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 40291f3..7f3197d 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2227,25 +2227,23 @@ static inline const char *netdev_name(const struct net_device *dev)
 	return dev->name;
 }
 
-#define netdev_printk(level, netdev, format, args...)		\
-	dev_printk(level, (netdev)->dev.parent,			\
-		   "%s: " format,				\
-		   netdev_name(netdev), ##args)
-
-#define netdev_emerg(dev, format, args...)			\
-	netdev_printk(KERN_EMERG, dev, format, ##args)
-#define netdev_alert(dev, format, args...)			\
-	netdev_printk(KERN_ALERT, dev, format, ##args)
-#define netdev_crit(dev, format, args...)			\
-	netdev_printk(KERN_CRIT, dev, format, ##args)
-#define netdev_err(dev, format, args...)			\
-	netdev_printk(KERN_ERR, dev, format, ##args)
-#define netdev_warn(dev, format, args...)			\
-	netdev_printk(KERN_WARNING, dev, format, ##args)
-#define netdev_notice(dev, format, args...)			\
-	netdev_printk(KERN_NOTICE, dev, format, ##args)
-#define netdev_info(dev, format, args...)			\
-	netdev_printk(KERN_INFO, dev, format, ##args)
+extern int netdev_printk(const char *level, const struct net_device *dev,
+			 const char *format, ...)
+	__attribute__ ((format (printf, 3, 4)));
+extern int netdev_emerg(const struct net_device *dev, const char *format, ...)
+	__attribute__ ((format (printf, 2, 3)));
+extern int netdev_alert(const struct net_device *dev, const char *format, ...)
+	__attribute__ ((format (printf, 2, 3)));
+extern int netdev_crit(const struct net_device *dev, const char *format, ...)
+	__attribute__ ((format (printf, 2, 3)));
+extern int netdev_err(const struct net_device *dev, const char *format, ...)
+	__attribute__ ((format (printf, 2, 3)));
+extern int netdev_warn(const struct net_device *dev, const char *format, ...)
+	__attribute__ ((format (printf, 2, 3)));
+extern int netdev_notice(const struct net_device *dev, const char *format, ...)
+	__attribute__ ((format (printf, 2, 3)));
+extern int netdev_info(const struct net_device *dev, const char *format, ...)
+	__attribute__ ((format (printf, 2, 3)));
 
 #if defined(DEBUG)
 #define netdev_dbg(__dev, format, args...)			\
diff --git a/net/core/dev.c b/net/core/dev.c
index 2b3bf53..6f6e1f4 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5790,6 +5790,68 @@ char *netdev_drivername(const struct net_device *dev, char *buffer, int len)
 	return buffer;
 }
 
+static int __netdev_printk(const char *level, const struct net_device *dev,
+			   struct va_format *vaf)
+{
+	int r;
+
+	if (dev && dev->dev.parent)
+		r = dev_printk(level, dev->dev.parent, "%s: %pV",
+			       netdev_name(dev), vaf);
+	else if (dev)
+		r = printk("%s%s: %pV", level, netdev_name(dev), vaf);
+	else
+		r = printk("%s(NULL net_device): %pV", level, vaf);
+
+	return r;
+}
+
+int netdev_printk(const char *level, const struct net_device *dev,
+		  const char *format, ...)
+{
+	struct va_format vaf;
+	va_list args;
+	int r;
+
+	va_start(args, format);
+
+	vaf.fmt = format;
+	vaf.va = &args;
+
+	r = __netdev_printk(level, dev, &vaf);
+	va_end(args);
+
+	return r;
+}
+EXPORT_SYMBOL(netdev_printk);
+
+#define define_netdev_printk_level(func, level)			\
+int func(const struct net_device *dev, const char *fmt, ...)	\
+{								\
+	int r;							\
+	struct va_format vaf;					\
+	va_list args;						\
+								\
+	va_start(args, fmt);					\
+								\
+	vaf.fmt = fmt;						\
+	vaf.va = &args;						\
+								\
+	r = __netdev_printk(level, dev, &vaf);			\
+	va_end(args);						\
+								\
+	return r;						\
+}								\
+EXPORT_SYMBOL(func);
+
+define_netdev_printk_level(netdev_emerg, KERN_EMERG);
+define_netdev_printk_level(netdev_alert, KERN_ALERT);
+define_netdev_printk_level(netdev_crit, KERN_CRIT);
+define_netdev_printk_level(netdev_err, KERN_ERR);
+define_netdev_printk_level(netdev_warn, KERN_WARNING);
+define_netdev_printk_level(netdev_notice, KERN_NOTICE);
+define_netdev_printk_level(netdev_info, KERN_INFO);
+
 static void __net_exit netdev_exit(struct net *net)
 {
 	kfree(net->dev_name_head);
-- 
1.7.1.337.g6068.dirty
