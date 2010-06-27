From: Joe Perches <joe@perches.com>
Subject: [PATCH 2/4] device.h drivers/base/core.c Convert dev_<level> logging macros to functions
Date: Sun, 27 Jun 2010 04:02:34 -0700
Message-ID: <b3f0a17a992be7b4e7a59a271c265d8695f92f4a.1277636090.git.joe@perches.com>
References: <cover.1277636090.git.joe@perches.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1277636090.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Reduces an x86 defconfig text and data ~55k, .6% smaller.

$ size vmlinux*
   text	   data	    bss	    dec	    hex	filename
7205273	 716016	1366288	9287577	 8db799	vmlinux
7258890	 719768	1366288	9344946	 8e97b2	vmlinux.master

Uses %pV and struct va_format
Format arguments are verified before printk

The dev_info macro is converted to _dev_info because there are
existing uses of variables named dev_info in the kernel tree
like drivers/net/pcmcia/pcnet_cs.c

A dev_info macro is created to call _dev_info

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/base/core.c    |   64 +++++++++++++++++++++++++++
 include/linux/device.h |  112 ++++++++++++++++++++++++++++++++++++-----------
 2 files changed, 150 insertions(+), 26 deletions(-)

diff --git a/drivers/base/core.c b/drivers/base/core.c
index 9630fbd..38bbbd0 100644
--- a/drivers/base/core.c
+++ b/drivers/base/core.c
@@ -1819,3 +1819,67 @@ void device_shutdown(void)
 	spin_unlock(&devices_kset->list_lock);
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
+			struct va_format *vaf)
+{
+	if (!dev)
+		return printk("%s(NULL device *): %pV", level, vaf);
+
+	return printk("%s%s %s: %pV",
+		      level, dev_driver_string(dev), dev_name(dev), vaf);
+}
+
+int dev_printk(const char *level, const struct device *dev,
+	       const char *fmt, ...)
+{
+	struct va_format vaf;
+	va_list args;
+	int r;
+
+	va_start(args, fmt);
+
+	vaf.fmt = fmt;
+	vaf.va = &args;
+
+	r = __dev_printk(level, dev, &vaf);
+	va_end(args);
+
+	return r;
+}
+EXPORT_SYMBOL(dev_printk);
+
+#define define_dev_printk_level(func, kern_level)		\
+int func(const struct device *dev, const char *fmt, ...)	\
+{								\
+	struct va_format vaf;					\
+	va_list args;						\
+	int r;							\
+								\
+	va_start(args, fmt);					\
+								\
+	vaf.fmt = fmt;						\
+	vaf.va = &args;						\
+								\
+	r = __dev_printk(kern_level, dev, &vaf);		\
+	va_end(args);						\
+								\
+	return r;						\
+}								\
+EXPORT_SYMBOL(func);
+
+define_dev_printk_level(dev_emerg, KERN_EMERG);
+define_dev_printk_level(dev_alert, KERN_ALERT);
+define_dev_printk_level(dev_crit, KERN_CRIT);
+define_dev_printk_level(dev_err, KERN_ERR);
+define_dev_printk_level(dev_warn, KERN_WARNING);
+define_dev_printk_level(dev_notice, KERN_NOTICE);
+define_dev_printk_level(_dev_info, KERN_INFO);
+
+#endif
diff --git a/include/linux/device.h b/include/linux/device.h
index 0713e10..6a8276f 100644
--- a/include/linux/device.h
+++ b/include/linux/device.h
@@ -638,43 +638,103 @@ extern void sysdev_shutdown(void);
 
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
+static inline int dev_emerg(const struct device *dev, const char *fmt, ...)
+	__attribute__ ((format (printf, 2, 3)));
+static inline int dev_emerg(const struct device *dev, const char *fmt, ...)
+	{ return 0; }
+static inline int dev_crit(const struct device *dev, const char *fmt, ...)
+	__attribute__ ((format (printf, 2, 3)));
+static inline int dev_crit(const struct device *dev, const char *fmt, ...)
+	{ return 0; }
+static inline int dev_alert(const struct device *dev, const char *fmt, ...)
+	__attribute__ ((format (printf, 2, 3)));
+static inline int dev_alert(const struct device *dev, const char *fmt, ...)
+	{ return 0; }
+static inline int dev_err(const struct device *dev, const char *fmt, ...)
+	__attribute__ ((format (printf, 2, 3)));
+static inline int dev_err(const struct device *dev, const char *fmt, ...)
+	{ return 0; }
+static inline int dev_warn(const struct device *dev, const char *fmt, ...)
+	__attribute__ ((format (printf, 2, 3)));
+static inline int dev_warn(const struct device *dev, const char *fmt, ...)
+	{ return 0; }
+static inline int dev_notice(const struct device *dev, const char *fmt, ...)
+	__attribute__ ((format (printf, 2, 3)));
+static inline int dev_notice(const struct device *dev, const char *fmt, ...)
+	{ return 0; }
+static inline int _dev_info(const struct device *dev, const char *fmt, ...)
+	__attribute__ ((format (printf, 2, 3)));
+static inline int _dev_info(const struct device *dev, const char *fmt, ...)
+	{ return 0; }
+
+#endif
+
+/*
+ * Stupid hackaround for existing uses of non-printk uses dev_info
+ *
+ * Note that the definition of dev_info below is actually _dev_info
+ * and a macro is used to avoid redefining dev_info
+ */
+
+#define dev_info(dev, fmt, arg...) _dev_info(dev, fmt, ##arg)
 
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
1.7.1.337.g6068.dirty
