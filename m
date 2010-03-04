From: Joe Perches <joe@perches.com>
Subject: [PATCH 2/2] device.h drivers/base/core.c Convert dev_<level> macros to functions
Date: Wed,  3 Mar 2010 22:27:23 -0800
Message-ID: <f2b24d484347c083fa87856a75c1d96102af9005.1267682641.git.joe__19845.0226955631$1267684108$gmane$org@perches.com>
References: <cover.1267682641.git.joe@perches.com>
Cc: linux-kernel@vger.kernel.org, Greg Kroah-Hartman <gregkh@suse.de>,
	netdev@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Nick Andrew <nick@nick-andrew.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1367 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752745Ab0CDG1Z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Mar 2010 01:27:25 -0500
In-Reply-To: <cover.1267682641.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Save ~60k in a defconfig

Use %pV and struct va_format
Format arguments are verified before printk

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/base/core.c    |  124 ++++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/device.h |  102 +++++++++++++++++++++++++++++----------
 2 files changed, 200 insertions(+), 26 deletions(-)

diff --git a/drivers/base/core.c b/drivers/base/core.c
index 2820257..6551640 100644
--- a/drivers/base/core.c
+++ b/drivers/base/core.c
@@ -1745,3 +1745,127 @@ void device_shutdown(void)
 	}
 	async_synchronize_full();
 }
+
+/*
+ * Device logging functions
+ */
+
+#ifdef CONFIG_PRINTK
+
+static int __dev_printk(const char *level, const struct device *dev,
+			const char *fmt, va_list args)
+{
+	struct va_format vaf;
+
+	vaf.fmt = fmt;
+	vaf.va = &args;
+	return printk("%s%s %s: %pV",
+		      level, dev_driver_string(dev), dev_name(dev), &vaf);
+}
+
+int dev_printk(const char *level, const struct device *dev,
+	       const char *fmt, ...)
+{
+	int r;
+	va_list args;
+
+	va_start(args, fmt);
+	r = __dev_printk(level, dev, fmt, args);
+	va_end(args);
+
+	return r;
+}
+EXPORT_SYMBOL(dev_printk);
+
+int dev_emerg(const struct device *dev, const char *fmt, ...)
+{
+	int r;
+	va_list args;
+
+	va_start(args, fmt);
+	r = __dev_printk(KERN_EMERG, dev, fmt, args);
+	va_end(args);
+
+	return r;
+}
+EXPORT_SYMBOL(dev_emerg);
+
+int dev_alert(const struct device *dev, const char *fmt, ...)
+{
+	int r;
+	va_list args;
+
+	va_start(args, fmt);
+	r = __dev_printk(KERN_ALERT, dev, fmt, args);
+	va_end(args);
+
+	return r;
+}
+EXPORT_SYMBOL(dev_alert);
+
+int dev_crit(const struct device *dev, const char *fmt, ...)
+{
+	int r;
+	va_list args;
+
+	va_start(args, fmt);
+	r = __dev_printk(KERN_CRIT, dev, fmt, args);
+	va_end(args);
+
+	return r;
+}
+EXPORT_SYMBOL(dev_crit);
+
+int dev_err(const struct device *dev, const char *fmt, ...)
+{
+	int r;
+	va_list args;
+
+	va_start(args, fmt);
+	r = __dev_printk(KERN_ERR, dev, fmt, args);
+	va_end(args);
+
+	return r;
+}
+EXPORT_SYMBOL(dev_err);
+
+int dev_warn(const struct device *dev, const char *fmt, ...)
+{
+	int r;
+	va_list args;
+
+	va_start(args, fmt);
+	r = __dev_printk(KERN_WARNING, dev, fmt, args);
+	va_end(args);
+
+	return r;
+}
+EXPORT_SYMBOL(dev_warn);
+
+int dev_notice(const struct device *dev, const char *fmt, ...)
+{
+	int r;
+	va_list args;
+
+	va_start(args, fmt);
+	r = __dev_printk(KERN_NOTICE, dev, fmt, args);
+	va_end(args);
+
+	return r;
+}
+EXPORT_SYMBOL(dev_notice);
+
+int dev_info(const struct device *dev, const char *fmt, ...)
+{
+	int r;
+	va_list args;
+
+	va_start(args, fmt);
+	r = __dev_printk(KERN_INFO, dev, fmt, args);
+	va_end(args);
+
+	return r;
+}
+EXPORT_SYMBOL(dev_info);
+
+#endif
diff --git a/include/linux/device.h b/include/linux/device.h
index b30527d..b4fb694 100644
--- a/include/linux/device.h
+++ b/include/linux/device.h
@@ -590,43 +590,93 @@ extern void sysdev_shutdown(void);
 
 /* debugging and troubleshooting/diagnostic helpers. */
 extern const char *dev_driver_string(const struct device *dev);
-#define dev_printk(level, dev, format, arg...)	\
-	printk(level "%s %s: " format , dev_driver_string(dev) , \
-	       dev_name(dev) , ## arg)
-
-#define dev_emerg(dev, format, arg...)		\
-	dev_printk(KERN_EMERG , dev , format , ## arg)
-#define dev_alert(dev, format, arg...)		\
-	dev_printk(KERN_ALERT , dev , format , ## arg)
-#define dev_crit(dev, format, arg...)		\
-	dev_printk(KERN_CRIT , dev , format , ## arg)
-#define dev_err(dev, format, arg...)		\
-	dev_printk(KERN_ERR , dev , format , ## arg)
-#define dev_warn(dev, format, arg...)		\
-	dev_printk(KERN_WARNING , dev , format , ## arg)
-#define dev_notice(dev, format, arg...)		\
-	dev_printk(KERN_NOTICE , dev , format , ## arg)
-#define dev_info(dev, format, arg...)		\
-	dev_printk(KERN_INFO , dev , format , ## arg)
+
+#ifdef CONFIG_PRINTK
+
+extern int dev_printk(const char *level, const struct device *dev,
+		      const char *fmt, ...)
+	__attribute__ ((format (printf, 3, 4)));
+extern int dev_emerg(const struct device *dev, const char *fmt, ...)
+	__attribute__ ((format (printf, 2, 3)));
+extern int dev_alert(const struct device *dev, const char *fmt, ...)
+	__attribute__ ((format (printf, 2, 3)));
+extern int dev_crit(const struct device *dev, const char *fmt, ...)
+	__attribute__ ((format (printf, 2, 3)));
+extern int dev_err(const struct device *dev, const char *fmt, ...)
+	__attribute__ ((format (printf, 2, 3)));
+extern int dev_warn(const struct device *dev, const char *fmt, ...)
+	__attribute__ ((format (printf, 2, 3)));
+extern int dev_notice(const struct device *dev, const char *fmt, ...)
+	__attribute__ ((format (printf, 2, 3)));
+extern int dev_info(const struct device *dev, const char *fmt, ...)
+	__attribute__ ((format (printf, 2, 3)));
+
+#else
+
+static inline int dev_printk(const char *level, const struct device *dev,
+		      const char *fmt, ...)
+	__attribute__ ((format (printf, 3, 4)));
+static inline int dev_printk(const char *level, const struct device *dev,
+		      const char *fmt, ...)
+	 { return 0; }
+
+static inline int dev_emerg(const struct device *dev, const char *s, ...)
+	__attribute__ ((format (printf, 2, 3)));
+static inline int dev_emerg(const struct device *dev, const char *s, ...)
+	{ return 0; }
+static inline int dev_crit(const struct device *dev, const char *s, ...)
+	__attribute__ ((format (printf, 2, 3)));
+static inline int dev_crit(const struct device *dev, const char *s, ...)
+	{ return 0; }
+static inline int dev_alert(const struct device *dev, const char *s, ...)
+	__attribute__ ((format (printf, 2, 3)));
+static inline int dev_alert(const struct device *dev, const char *s, ...)
+	{ return 0; }
+static inline int dev_err(const struct device *dev, const char *s, ...)
+	__attribute__ ((format (printf, 2, 3)));
+static inline int dev_err(const struct device *dev, const char *s, ...)
+	{ return 0; }
+static inline int dev_warn(const struct device *dev, const char *s, ...)
+	__attribute__ ((format (printf, 2, 3)));
+static inline int dev_warn(const struct device *dev, const char *s, ...)
+	{ return 0; }
+static inline int dev_notice(const struct device *dev, const char *s, ...)
+	__attribute__ ((format (printf, 2, 3)));
+static inline int dev_notice(const struct device *dev, const char *s, ...)
+	{ return 0; }
+static inline int dev_info(const struct device *dev, const char *s, ...)
+	__attribute__ ((format (printf, 2, 3)));
+static inline int dev_info(const struct device *dev, const char *s, ...)
+	{ return 0; }
+
+#endif
 
 #if defined(DEBUG)
 #define dev_dbg(dev, format, arg...)		\
-	dev_printk(KERN_DEBUG , dev , format , ## arg)
+	dev_printk(KERN_DEBUG, dev, format, ##arg)
 #elif defined(CONFIG_DYNAMIC_DEBUG)
-#define dev_dbg(dev, format, ...) do { \
+#define dev_dbg(dev, format, ...)		     \
+do {						     \
 	dynamic_dev_dbg(dev, format, ##__VA_ARGS__); \
-	} while (0)
+} while (0)
 #else
-#define dev_dbg(dev, format, arg...)		\
-	({ if (0) dev_printk(KERN_DEBUG, dev, format, ##arg); 0; })
+#define dev_dbg(dev, format, arg...)				\
+({								\
+	if (0)							\
+		dev_printk(KERN_DEBUG, dev, format, ##arg);	\
+	0;							\
+})
 #endif
 
 #ifdef VERBOSE_DEBUG
 #define dev_vdbg	dev_dbg
 #else
-
-#define dev_vdbg(dev, format, arg...)		\
-	({ if (0) dev_printk(KERN_DEBUG, dev, format, ##arg); 0; })
+#define dev_vdbg(dev, format, arg...)				\
+({								\
+	if (0)							\
+		dev_printk(KERN_DEBUG, dev, format, ##arg);	\
+	0;							\
+})
 #endif
 
 /*
-- 
1.7.0.14.g7e948

