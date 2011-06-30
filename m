From: Joe Perches <joe@perches.com>
Subject: [PATCH 1/4] dynamic_debug: Add __dynamic_dev_dbg
Date: Thu, 30 Jun 2011 11:14:34 -0700
Message-ID: <d516cb818b3b64b55179ae640fdc68ccd270fed0.1309457340.git.joe@perches.com>
References: <20110630163218.GA2457@redhat.com>
Cc: Aloisio Almeida <aloisio.almeida@openbossa.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Jason Baron <jbaron@redhat.com>,
	Greg Kroah-Hartman <gregkh@suse.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110630163218.GA2457@redhat.com>
In-Reply-To: <cover.1309457340.git.joe@perches.com>
References: <cover.1309457340.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Unlike dynamic_pr_debug, dynamic uses of dev_dbg can not
currently add task_pid/KBUILD_MODNAME/__func__/__LINE__
to selected debug output.

Add a new function similar to dynamic_pr_debug to
optionally emit these prefixes.

cc: Aloisio Almeida <aloisio.almeida@openbossa.org>

Noticed-by: Aloisio Almeida <aloisio.almeida@openbossa.org>
Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/base/core.c           |    5 +++--
 include/linux/device.h        |    5 +++++
 include/linux/dynamic_debug.h |   10 ++++++++--
 lib/dynamic_debug.c           |   38 ++++++++++++++++++++++++++++++++++++++
 4 files changed, 54 insertions(+), 4 deletions(-)

diff --git a/drivers/base/core.c b/drivers/base/core.c
index bc8729d..82c8654 100644
--- a/drivers/base/core.c
+++ b/drivers/base/core.c
@@ -1764,8 +1764,8 @@ void device_shutdown(void)
 
 #ifdef CONFIG_PRINTK
 
-static int __dev_printk(const char *level, const struct device *dev,
-			struct va_format *vaf)
+int __dev_printk(const char *level, const struct device *dev,
+		 struct va_format *vaf)
 {
 	if (!dev)
 		return printk("%s(NULL device *): %pV", level, vaf);
@@ -1773,6 +1773,7 @@ static int __dev_printk(const char *level, const struct device *dev,
 	return printk("%s%s %s: %pV",
 		      level, dev_driver_string(dev), dev_name(dev), vaf);
 }
+EXPORT_SYMBOL(__dev_printk);
 
 int dev_printk(const char *level, const struct device *dev,
 	       const char *fmt, ...)
diff --git a/include/linux/device.h b/include/linux/device.h
index e4f62d8..53711f2 100644
--- a/include/linux/device.h
+++ b/include/linux/device.h
@@ -785,6 +785,8 @@ extern const char *dev_driver_string(const struct device *dev);
 
 #ifdef CONFIG_PRINTK
 
+extern int __dev_printk(const char *level, const struct device *dev,
+			struct va_format *vaf);
 extern int dev_printk(const char *level, const struct device *dev,
 		      const char *fmt, ...)
 	__attribute__ ((format (printf, 3, 4)));
@@ -805,6 +807,9 @@ extern int _dev_info(const struct device *dev, const char *fmt, ...)
 
 #else
 
+static inline int __dev_printk(const char *level, const struct device *dev,
+			       struct va_format *vaf)
+	 { return 0; }
 static inline int dev_printk(const char *level, const struct device *dev,
 		      const char *fmt, ...)
 	__attribute__ ((format (printf, 3, 4)));
diff --git a/include/linux/dynamic_debug.h b/include/linux/dynamic_debug.h
index e747ecd..bdf1531 100644
--- a/include/linux/dynamic_debug.h
+++ b/include/linux/dynamic_debug.h
@@ -47,6 +47,13 @@ extern int ddebug_remove_module(const char *mod_name);
 extern int __dynamic_pr_debug(struct _ddebug *descriptor, const char *fmt, ...)
 	__attribute__ ((format (printf, 2, 3)));
 
+struct device;
+
+extern int __dynamic_dev_dbg(struct _ddebug *descriptor,
+			     const struct device *dev,
+			     const char *fmt, ...)
+	__attribute__ ((format (printf, 3, 4)));
+
 #define dynamic_pr_debug(fmt, ...) do {					\
 	static struct _ddebug descriptor				\
 	__used								\
@@ -57,7 +64,6 @@ extern int __dynamic_pr_debug(struct _ddebug *descriptor, const char *fmt, ...)
 		__dynamic_pr_debug(&descriptor, pr_fmt(fmt), ##__VA_ARGS__); \
 	} while (0)
 
-
 #define dynamic_dev_dbg(dev, fmt, ...) do {				\
 	static struct _ddebug descriptor				\
 	__used								\
@@ -65,7 +71,7 @@ extern int __dynamic_pr_debug(struct _ddebug *descriptor, const char *fmt, ...)
 	{ KBUILD_MODNAME, __func__, __FILE__, fmt, __LINE__,		\
 		_DPRINTK_FLAGS_DEFAULT };				\
 	if (unlikely(descriptor.enabled))				\
-		dev_printk(KERN_DEBUG, dev, fmt, ##__VA_ARGS__);	\
+		__dynamic_dev_dbg(&descriptor, dev, fmt, ##__VA_ARGS__);	\
 	} while (0)
 
 #else
diff --git a/lib/dynamic_debug.c b/lib/dynamic_debug.c
index 75ca78f..5c5f8f9 100644
--- a/lib/dynamic_debug.c
+++ b/lib/dynamic_debug.c
@@ -30,6 +30,7 @@
 #include <linux/jump_label.h>
 #include <linux/hardirq.h>
 #include <linux/sched.h>
+#include <linux/device.h>
 
 extern struct _ddebug __start___verbose[];
 extern struct _ddebug __stop___verbose[];
@@ -456,6 +457,43 @@ int __dynamic_pr_debug(struct _ddebug *descriptor, const char *fmt, ...)
 }
 EXPORT_SYMBOL(__dynamic_pr_debug);
 
+int __dynamic_dev_dbg(struct _ddebug *descriptor,
+		      const struct device *dev, const char *fmt, ...)
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
+	res = printk(KERN_DEBUG);
+	if (descriptor->flags & _DPRINTK_FLAGS_INCL_TID) {
+		if (in_interrupt())
+			res += printk(KERN_CONT "<intr> ");
+		else
+			res += printk(KERN_CONT "[%d] ", task_pid_vnr(current));
+	}
+	if (descriptor->flags & _DPRINTK_FLAGS_INCL_MODNAME)
+		res += printk(KERN_CONT "%s:", descriptor->modname);
+	if (descriptor->flags & _DPRINTK_FLAGS_INCL_FUNCNAME)
+		res += printk(KERN_CONT "%s:", descriptor->function);
+	if (descriptor->flags & _DPRINTK_FLAGS_INCL_LINENO)
+		res += printk(KERN_CONT "%d ", descriptor->lineno);
+
+	res += __dev_printk("", dev, &vaf);
+
+	va_end(args);
+
+	return res;
+}
+EXPORT_SYMBOL(__dynamic_dev_dbg);
+
 static __initdata char ddebug_setup_string[1024];
 static __init int ddebug_setup_query(char *str)
 {
-- 
1.7.6.rc1
