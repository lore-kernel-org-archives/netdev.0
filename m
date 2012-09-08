From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 0/5] dev_<level> and dynamic_debug cleanups
Date: Fri, 07 Sep 2012 18:55:50 -0700
Message-ID: <1347069350.13424.28.camel@joe2Laptop>
References: <cover.1345978012.git.joe@perches.com>
	 <20120906175158.GB9786@redhat.com> <1346957026.13424.5.camel@joe2Laptop>
	 <20120907145235.GA18673@redhat.com> <1347030721.13424.22.camel@joe2Laptop>
	 <20120907153542.GB18673@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	Jim Cromie <jim.cromie@gmail.com>, Kay Sievers <kay@vrfy.org>,
	linux-kernel@vger.kernel.org
To: Jason Baron <jbaron@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120907153542.GB18673@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2012-09-07 at 11:35 -0400, Jason Baron wrote:
> If nobody else thinks this patch is better, let's at least add a comment in
> __dev_printk() and __netdev_printk() to fix dynamic debug, if these are changed.

Or maybe make dynamic_emit_prefix a public function
and move the __dynamic_<foo>_printk functions to
nearby the __<foo>_printk functions so it's easier to
see that changing one requires the other to change.

Something like:

 drivers/base/core.c           |   34 +++++++++++++++++++
 include/linux/dynamic_debug.h |    2 +
 lib/dynamic_debug.c           |   74 +----------------------------------------
 net/core/dev.c                |   40 ++++++++++++++++++++++
 4 files changed, 77 insertions(+), 73 deletions(-)

diff --git a/drivers/base/core.c b/drivers/base/core.c
index 65f82e3..2b4f3e8 100644
--- a/drivers/base/core.c
+++ b/drivers/base/core.c
@@ -1948,6 +1948,40 @@ static int __dev_printk(const char *level, const struct device *dev,
 			       dev_driver_string(dev), dev_name(dev), vaf);
 }
 
+#ifdef CONFIG_DYNAMIC_DEBUG
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
+	if (!dev) {
+		res = printk(KERN_DEBUG "(NULL device *): %pV", &vaf);
+	} else {
+		char buf[PREFIX_SIZE];
+
+		res = dev_printk_emit(7, dev, "%s%s %s: %pV",
+				      dynamic_emit_prefix(descriptor, buf),
+				      dev_driver_string(dev), dev_name(dev),
+				      &vaf);
+	}
+
+	va_end(args);
+
+	return res;
+}
+EXPORT_SYMBOL(__dynamic_dev_dbg);
+#endif
+
 int dev_printk(const char *level, const struct device *dev,
 	       const char *fmt, ...)
 {
diff --git a/include/linux/dynamic_debug.h b/include/linux/dynamic_debug.h
index c18257b..8de7573 100644
--- a/include/linux/dynamic_debug.h
+++ b/include/linux/dynamic_debug.h
@@ -41,6 +41,8 @@ int ddebug_add_module(struct _ddebug *tab, unsigned int n,
 
 #if defined(CONFIG_DYNAMIC_DEBUG)
 extern int ddebug_remove_module(const char *mod_name);
+char *dynamic_emit_prefix(const struct _ddebug *desc, char *buf);
+
 extern __printf(2, 3)
 int __dynamic_pr_debug(struct _ddebug *descriptor, const char *fmt, ...);
 
diff --git a/lib/dynamic_debug.c b/lib/dynamic_debug.c
index e7f7d99..b9f1d22 100644
--- a/lib/dynamic_debug.c
+++ b/lib/dynamic_debug.c
@@ -516,7 +516,7 @@ static int remaining(int wrote)
 	return 0;
 }
 
-static char *dynamic_emit_prefix(const struct _ddebug *desc, char *buf)
+char *dynamic_emit_prefix(const struct _ddebug *desc, char *buf)
 {
 	int pos_after_tid;
 	int pos = 0;
@@ -572,78 +572,6 @@ int __dynamic_pr_debug(struct _ddebug *descriptor, const char *fmt, ...)
 }
 EXPORT_SYMBOL(__dynamic_pr_debug);
 
-int __dynamic_dev_dbg(struct _ddebug *descriptor,
-		      const struct device *dev, const char *fmt, ...)
-{
-	struct va_format vaf;
-	va_list args;
-	int res;
-
-	BUG_ON(!descriptor);
-	BUG_ON(!fmt);
-
-	va_start(args, fmt);
-
-	vaf.fmt = fmt;
-	vaf.va = &args;
-
-	if (!dev) {
-		res = printk(KERN_DEBUG "(NULL device *): %pV", &vaf);
-	} else {
-		char buf[PREFIX_SIZE];
-
-		res = dev_printk_emit(7, dev, "%s%s %s: %pV",
-				      dynamic_emit_prefix(descriptor, buf),
-				      dev_driver_string(dev), dev_name(dev),
-				      &vaf);
-	}
-
-	va_end(args);
-
-	return res;
-}
-EXPORT_SYMBOL(__dynamic_dev_dbg);
-
-#ifdef CONFIG_NET
-
-int __dynamic_netdev_dbg(struct _ddebug *descriptor,
-			 const struct net_device *dev, const char *fmt, ...)
-{
-	struct va_format vaf;
-	va_list args;
-	int res;
-
-	BUG_ON(!descriptor);
-	BUG_ON(!fmt);
-
-	va_start(args, fmt);
-
-	vaf.fmt = fmt;
-	vaf.va = &args;
-
-	if (dev && dev->dev.parent) {
-		char buf[PREFIX_SIZE];
-
-		res = dev_printk_emit(7, dev->dev.parent,
-				      "%s%s %s %s: %pV",
-				      dynamic_emit_prefix(descriptor, buf),
-				      dev_driver_string(dev->dev.parent),
-				      dev_name(dev->dev.parent),
-				      netdev_name(dev), &vaf);
-	} else if (dev) {
-		res = printk(KERN_DEBUG "%s: %pV", netdev_name(dev), &vaf);
-	} else {
-		res = printk(KERN_DEBUG "(NULL net_device): %pV", &vaf);
-	}
-
-	va_end(args);
-
-	return res;
-}
-EXPORT_SYMBOL(__dynamic_netdev_dbg);
-
-#endif
-
 #define DDEBUG_STRING_SIZE 1024
 static __initdata char ddebug_setup_string[DDEBUG_STRING_SIZE];
 
diff --git a/net/core/dev.c b/net/core/dev.c
index 8ad42fd..fc69703 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -6443,6 +6443,46 @@ static int __netdev_printk(const char *level, const struct net_device *dev,
 	return r;
 }
 
+#ifdef CONFIG_DYNAMIC_DEBUG
+
+int __dynamic_netdev_dbg(struct _ddebug *descriptor,
+			 const struct net_device *dev, const char *fmt, ...)
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
+	if (dev && dev->dev.parent) {
+		char buf[PREFIX_SIZE];
+
+		res = dev_printk_emit(7, dev->dev.parent,
+				      "%s%s %s %s: %pV",
+				      dynamic_emit_prefix(descriptor, buf),
+				      dev_driver_string(dev->dev.parent),
+				      dev_name(dev->dev.parent),
+				      netdev_name(dev), &vaf);
+	} else if (dev) {
+		res = printk(KERN_DEBUG "%s: %pV", netdev_name(dev), &vaf);
+	} else {
+		res = printk(KERN_DEBUG "(NULL net_device): %pV", &vaf);
+	}
+
+	va_end(args);
+
+	return res;
+}
+EXPORT_SYMBOL(__dynamic_netdev_dbg);
+
+#endif
+
 int netdev_printk(const char *level, const struct net_device *dev,
 		  const char *format, ...)
 {
