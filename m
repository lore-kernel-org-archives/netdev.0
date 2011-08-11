From: Jason Baron <jbaron@redhat.com>
Subject: [PATCH 07/11] dynamic_debug: make netdev_dbg() call __netdev_printk()
Date: Thu, 11 Aug 2011 14:36:48 -0400
Message-ID: <5514795fe63ccfd4b3a80283ed04a526abe3c59d.1313085588.git.jbaron@redhat.com>
References: <cover.1313085588.git.jbaron@redhat.com>
Cc: joe@perches.com, jim.cromie@gmail.com, bvanassche@acm.org,
	linux-kernel@vger.kernel.org, davem@davemloft.net,
	aloisio.almeida@openbossa.org, netdev@vger.kernel.org
To: gregkh@suse.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1313085588.git.jbaron@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jason Baron <jbaron@redhat.com>

Previously, if dynamic debug was enabled netdev_dbg() was using
dynamic_dev_dbg() to print out the underlying msg. Fix this by making
sure netdev_dbg() uses __netdev_printk().

Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Jason Baron <jbaron@redhat.com>
---
 include/linux/dynamic_debug.h |   17 +++++++++++++++++
 include/linux/netdevice.h     |    6 ++++--
 lib/dynamic_debug.c           |   25 +++++++++++++++++++++++++
 net/core/dev.c                |    3 ++-
 4 files changed, 48 insertions(+), 3 deletions(-)

diff --git a/include/linux/dynamic_debug.h b/include/linux/dynamic_debug.h
index 843cb9e..feaac1e 100644
--- a/include/linux/dynamic_debug.h
+++ b/include/linux/dynamic_debug.h
@@ -47,6 +47,13 @@ extern int __dynamic_dev_dbg(struct _ddebug *descriptor,
 			     const char *fmt, ...)
 	__attribute__ ((format (printf, 3, 4)));
 
+struct net_device;
+
+extern int __dynamic_netdev_dbg(struct _ddebug *descriptor,
+			     const struct net_device *dev,
+			     const char *fmt, ...)
+	__attribute__ ((format (printf, 3, 4)));
+
 #define dynamic_pr_debug(fmt, ...) do {					\
 	static struct _ddebug descriptor				\
 	__used								\
@@ -67,6 +74,16 @@ extern int __dynamic_dev_dbg(struct _ddebug *descriptor,
 		__dynamic_dev_dbg(&descriptor, dev, fmt, ##__VA_ARGS__);	\
 	} while (0)
 
+#define dynamic_netdev_dbg(dev, fmt, ...) do {				\
+	static struct _ddebug descriptor				\
+	__used								\
+	__attribute__((section("__verbose"), aligned(8))) =		\
+	{ KBUILD_MODNAME, __func__, __FILE__, fmt, __LINE__,		\
+		_DPRINTK_FLAGS_DEFAULT };				\
+	if (unlikely(descriptor.enabled))				\
+		__dynamic_netdev_dbg(&descriptor, dev, fmt, ##__VA_ARGS__);\
+	} while (0)
+
 #else
 
 static inline int ddebug_remove_module(const char *mod)
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index ddee79b..9333a03 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2617,6 +2617,9 @@ static inline const char *netdev_name(const struct net_device *dev)
 	return dev->name;
 }
 
+extern int __netdev_printk(const char *level, const struct net_device *dev,
+			struct va_format *vaf);
+
 extern int netdev_printk(const char *level, const struct net_device *dev,
 			 const char *format, ...)
 	__attribute__ ((format (printf, 3, 4)));
@@ -2644,8 +2647,7 @@ extern int netdev_info(const struct net_device *dev, const char *format, ...)
 #elif defined(CONFIG_DYNAMIC_DEBUG)
 #define netdev_dbg(__dev, format, args...)			\
 do {								\
-	dynamic_dev_dbg((__dev)->dev.parent, "%s: " format,	\
-			netdev_name(__dev), ##args);		\
+	dynamic_netdev_dbg(__dev, format, ##args);		\
 } while (0)
 #else
 #define netdev_dbg(__dev, format, args...)			\
diff --git a/lib/dynamic_debug.c b/lib/dynamic_debug.c
index 4fc03dd..ee3b9ba 100644
--- a/lib/dynamic_debug.c
+++ b/lib/dynamic_debug.c
@@ -33,6 +33,7 @@
 #include <linux/hardirq.h>
 #include <linux/sched.h>
 #include <linux/device.h>
+#include <linux/netdevice.h>
 
 extern struct _ddebug __start___verbose[];
 extern struct _ddebug __stop___verbose[];
@@ -503,6 +504,30 @@ int __dynamic_dev_dbg(struct _ddebug *descriptor,
 }
 EXPORT_SYMBOL(__dynamic_dev_dbg);
 
+int __dynamic_netdev_dbg(struct _ddebug *descriptor,
+		      const struct net_device *dev, const char *fmt, ...)
+{
+	struct va_format vaf;
+	va_list args;
+	int res;
+
+	BUG_ON(!descriptor);
+	BUG_ON(!fmt);
+
+	va_start(args, fmt);
+
+	vaf.fmt = fmt;
+	vaf.va = &args;
+
+	res = dynamic_emit_prefix(descriptor);
+	res += __netdev_printk(KERN_CONT, dev, &vaf);
+
+	va_end(args);
+
+	return res;
+}
+EXPORT_SYMBOL(__dynamic_netdev_dbg);
+
 static __initdata char ddebug_setup_string[1024];
 static __init int ddebug_setup_query(char *str)
 {
diff --git a/net/core/dev.c b/net/core/dev.c
index 17d67b5..c47a7bc 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -6290,7 +6290,7 @@ const char *netdev_drivername(const struct net_device *dev)
 	return empty;
 }
 
-static int __netdev_printk(const char *level, const struct net_device *dev,
+int __netdev_printk(const char *level, const struct net_device *dev,
 			   struct va_format *vaf)
 {
 	int r;
@@ -6305,6 +6305,7 @@ static int __netdev_printk(const char *level, const struct net_device *dev,
 
 	return r;
 }
+EXPORT_SYMBOL(__netdev_printk);
 
 int netdev_printk(const char *level, const struct net_device *dev,
 		  const char *format, ...)
-- 
1.7.5.4
