From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next] net: Change netdev_<level> logging functions to
 return void
Date: Mon, 22 Sep 2014 11:10:50 -0700
Message-ID: <1411409450.2952.55.camel@joe-AO725>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

No caller or macro uses the return value so make all
the functions return void.

Signed-off-by: Joe Perches <joe@perches.com>
---
This change is associated to a desire to eventually
change printk to return void.

 include/linux/netdevice.h | 19 +++++++++----------
 net/core/dev.c            | 44 +++++++++++++++++---------------------------
 2 files changed, 26 insertions(+), 37 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 28d4378..3d7ea30 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -3612,22 +3612,22 @@ static inline const char *netdev_reg_state(const struct net_device *dev)
 }
 
 __printf(3, 4)
-int netdev_printk(const char *level, const struct net_device *dev,
-		  const char *format, ...);
+void netdev_printk(const char *level, const struct net_device *dev,
+		   const char *format, ...);
 __printf(2, 3)
-int netdev_emerg(const struct net_device *dev, const char *format, ...);
+void netdev_emerg(const struct net_device *dev, const char *format, ...);
 __printf(2, 3)
-int netdev_alert(const struct net_device *dev, const char *format, ...);
+void netdev_alert(const struct net_device *dev, const char *format, ...);
 __printf(2, 3)
-int netdev_crit(const struct net_device *dev, const char *format, ...);
+void netdev_crit(const struct net_device *dev, const char *format, ...);
 __printf(2, 3)
-int netdev_err(const struct net_device *dev, const char *format, ...);
+void netdev_err(const struct net_device *dev, const char *format, ...);
 __printf(2, 3)
-int netdev_warn(const struct net_device *dev, const char *format, ...);
+void netdev_warn(const struct net_device *dev, const char *format, ...);
 __printf(2, 3)
-int netdev_notice(const struct net_device *dev, const char *format, ...);
+void netdev_notice(const struct net_device *dev, const char *format, ...);
 __printf(2, 3)
-int netdev_info(const struct net_device *dev, const char *format, ...);
+void netdev_info(const struct net_device *dev, const char *format, ...);
 
 #define MODULE_ALIAS_NETDEV(device) \
 	MODULE_ALIAS("netdev-" device)
@@ -3645,7 +3645,6 @@ do {								\
 ({								\
 	if (0)							\
 		netdev_printk(KERN_DEBUG, __dev, format, ##args); \
-	0;							\
 })
 #endif
 
diff --git a/net/core/dev.c b/net/core/dev.c
index ad2522d..fa47b81 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -7074,53 +7074,45 @@ const char *netdev_drivername(const struct net_device *dev)
 	return empty;
 }
 
-static int __netdev_printk(const char *level, const struct net_device *dev,
-			   struct va_format *vaf)
+static void __netdev_printk(const char *level, const struct net_device *dev,
+			    struct va_format *vaf)
 {
-	int r;
-
 	if (dev && dev->dev.parent) {
-		r = dev_printk_emit(level[1] - '0',
-				    dev->dev.parent,
-				    "%s %s %s%s: %pV",
-				    dev_driver_string(dev->dev.parent),
-				    dev_name(dev->dev.parent),
-				    netdev_name(dev), netdev_reg_state(dev),
-				    vaf);
+		dev_printk_emit(level[1] - '0',
+				dev->dev.parent,
+				"%s %s %s%s: %pV",
+				dev_driver_string(dev->dev.parent),
+				dev_name(dev->dev.parent),
+				netdev_name(dev), netdev_reg_state(dev),
+				vaf);
 	} else if (dev) {
-		r = printk("%s%s%s: %pV", level, netdev_name(dev),
-			   netdev_reg_state(dev), vaf);
+		printk("%s%s%s: %pV",
+		       level, netdev_name(dev), netdev_reg_state(dev), vaf);
 	} else {
-		r = printk("%s(NULL net_device): %pV", level, vaf);
+		printk("%s(NULL net_device): %pV", level, vaf);
 	}
-
-	return r;
 }
 
-int netdev_printk(const char *level, const struct net_device *dev,
-		  const char *format, ...)
+void netdev_printk(const char *level, const struct net_device *dev,
+		   const char *format, ...)
 {
 	struct va_format vaf;
 	va_list args;
-	int r;
 
 	va_start(args, format);
 
 	vaf.fmt = format;
 	vaf.va = &args;
 
-	r = __netdev_printk(level, dev, &vaf);
+	__netdev_printk(level, dev, &vaf);
 
 	va_end(args);
-
-	return r;
 }
 EXPORT_SYMBOL(netdev_printk);
 
 #define define_netdev_printk_level(func, level)			\
-int func(const struct net_device *dev, const char *fmt, ...)	\
+void func(const struct net_device *dev, const char *fmt, ...)	\
 {								\
-	int r;							\
 	struct va_format vaf;					\
 	va_list args;						\
 								\
@@ -7129,11 +7121,9 @@ int func(const struct net_device *dev, const char *fmt, ...)	\
 	vaf.fmt = fmt;						\
 	vaf.va = &args;						\
 								\
-	r = __netdev_printk(level, dev, &vaf);			\
+	__netdev_printk(level, dev, &vaf);			\
 								\
 	va_end(args);						\
-								\
-	return r;						\
 }								\
 EXPORT_SYMBOL(func);
 
