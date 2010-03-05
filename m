From: Joe Perches <joe@perches.com>
Subject: [PATCH 2/3] device.h drivers/base/core.c Convert dev_<level> macros to functions
Date: Thu,  4 Mar 2010 22:56:53 -0800
Message-ID: <e18f5d8b8a0857a07918107f464a653234a47564.1267771398.git.joe@perches.com>
References: <cover.1267771398.git.joe@perches.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1267771398.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Save ~60k in a defconfig

Use %pV and struct va_format
Format arguments are verified before printk

There are existing "struct dev_info" declarations as well as local variables
named dev_info so the dev_info macro to function conversion is instead
called _dev_info and a macro is used to call _dev_info

Perhaps over time the struct and local uses of dev_info should be renamed.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/base/core.c    |   56 +++++++++++++++++++++++++
 include/linux/device.h |  105 ++++++++++++++++++++++++++++++++++++------------
 2 files changed, 135 insertions(+), 26 deletions(-)

diff --git a/drivers/base/core.c b/drivers/base/core.c
index 2820257..19de3ab 100644
--- a/drivers/base/core.c
+++ b/drivers/base/core.c
@@ -1745,3 +1745,59 @@ void device_shutdown(void)
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
+#define declare_dev_level(function, level)			\
+int function(const struct device *dev, const char *fmt, ...)	\
+{								\
+	int r;							\
+        va_list args;						\
+								\
+        va_start(args, fmt);					\
+	r = __dev_printk(level, dev, fmt, args);		\
+        va_end(args);						\
+								\
+        return r;						\
+}								\
+EXPORT_SYMBOL(function)
+
+declare_dev_level(dev_emerg,	KERN_EMERG);
+declare_dev_level(dev_alert,	KERN_ALERT);
+declare_dev_level(dev_crit,	KERN_CRIT);
+declare_dev_level(dev_err,	KERN_ERR);
+declare_dev_level(dev_warn,	KERN_WARNING);
+declare_dev_level(dev_notice,	KERN_NOTICE);
+declare_dev_level(_dev_info,	KERN_INFO);
+/* Not dev_info because it conflicts with with existing "struct dev_info" */
+
+#endif
diff --git a/include/linux/device.h b/include/linux/device.h
index b30527d..5948c07 100644
--- a/include/linux/device.h
+++ b/include/linux/device.h
@@ -590,43 +590,96 @@ extern void sysdev_shutdown(void);
 
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
+extern int _dev_info(const struct device *dev, const char *fmt, ...)
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
+static inline int _dev_info(const struct device *dev, const char *s, ...)
+	__attribute__ ((format (printf, 2, 3)));
+static inline int _dev_info(const struct device *dev, const char *s, ...)
+	{ return 0; }
+
+#endif
+
+#define dev_info(dev, fmt, arg...) _dev_info(dev, fmt, ##arg)
+/* workaround for existing struct dev_info and variable dev_info uses */
 
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
