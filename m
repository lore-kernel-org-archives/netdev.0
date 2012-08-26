From: Joe Perches <joe@perches.com>
Subject: [PATCH 2/5] netdev_printk/dynamic_netdev_dbg: Directly call printk_emit
Date: Sun, 26 Aug 2012 04:25:27 -0700
Message-ID: <f756fa139d9da590c667132093b4d7b7a545ee20.1345978012.git.joe@perches.com>
References: <cover.1345978012.git.joe@perches.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Jim Cromie <jim.cromie@gmail.com>, Kay Sievers <kay@vrfy.org>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	Jason Baron <jbaron@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1345978012.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A lot of stack is used in recursive printks with %pV.

Using multiple levels of %pV (a logging function with %pV
that calls another logging function with %pV) can consume
more stack than necessary.

Avoid excessive stack use by not calling dev_printk from
netdev_printk and dynamic_netdev_dbg.  Duplicate the logic
and form of dev_printk instead.

Make __netdev_printk static.
Remove EXPORT_SYMBOL(__netdev_printk)
Whitespace and brace style neatening.

Signed-off-by: Joe Perches <joe@perches.com>
---
 include/linux/netdevice.h |    3 ---
 lib/dynamic_debug.c       |   26 +++++++++++++++++++++++---
 net/core/dev.c            |   24 +++++++++++++++++-------
 3 files changed, 40 insertions(+), 13 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 59dc05f3..5f49cc0 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2720,9 +2720,6 @@ static inline const char *netdev_name(const struct net_device *dev)
 	return dev->name;
 }
 
-extern int __netdev_printk(const char *level, const struct net_device *dev,
-			struct va_format *vaf);
-
 extern __printf(3, 4)
 int netdev_printk(const char *level, const struct net_device *dev,
 		  const char *format, ...);
diff --git a/lib/dynamic_debug.c b/lib/dynamic_debug.c
index 29ff2e4..2a29f4e 100644
--- a/lib/dynamic_debug.c
+++ b/lib/dynamic_debug.c
@@ -611,20 +611,40 @@ EXPORT_SYMBOL(__dynamic_dev_dbg);
 #ifdef CONFIG_NET
 
 int __dynamic_netdev_dbg(struct _ddebug *descriptor,
-		      const struct net_device *dev, const char *fmt, ...)
+			 const struct net_device *dev, const char *fmt, ...)
 {
 	struct va_format vaf;
 	va_list args;
 	int res;
-	char buf[PREFIX_SIZE];
 
 	BUG_ON(!descriptor);
 	BUG_ON(!fmt);
 
 	va_start(args, fmt);
+
 	vaf.fmt = fmt;
 	vaf.va = &args;
-	res = __netdev_printk(dynamic_emit_prefix(descriptor, buf), dev, &vaf);
+
+	if (dev && dev->dev.parent) {
+		char buf[PREFIX_SIZE];
+		char dict[128];
+		size_t dictlen;
+
+		dictlen = create_syslog_header(dev->dev.parent,
+					       dict, sizeof(dict));
+
+		res = printk_emit(0, 7, dictlen ? dict : NULL, dictlen,
+				  "%s%s %s: %s: %pV",
+				  dynamic_emit_prefix(descriptor, buf),
+				  dev_driver_string(dev->dev.parent),
+				  dev_name(dev->dev.parent),
+				  netdev_name(dev), &vaf);
+	} else if (dev) {
+		res = printk(KERN_DEBUG "%s: %pV", netdev_name(dev), &vaf);
+	} else {
+		res = printk(KERN_DEBUG "(NULL net_device): %pV", &vaf);
+	}
+
 	va_end(args);
 
 	return res;
diff --git a/net/core/dev.c b/net/core/dev.c
index 8398836..a588145 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -6422,22 +6422,30 @@ const char *netdev_drivername(const struct net_device *dev)
 	return empty;
 }
 
-int __netdev_printk(const char *level, const struct net_device *dev,
+static int __netdev_printk(const char *level, const struct net_device *dev,
 			   struct va_format *vaf)
 {
 	int r;
 
-	if (dev && dev->dev.parent)
-		r = dev_printk(level, dev->dev.parent, "%s: %pV",
-			       netdev_name(dev), vaf);
-	else if (dev)
+	if (dev && dev->dev.parent) {
+		char dict[128];
+		size_t dictlen = create_syslog_header(dev->dev.parent,
+						      dict, sizeof(dict));
+
+		r = printk_emit(0, level[1] - '0',
+				dictlen ? dict : NULL, dictlen,
+				"%s %s: %s: %pV",
+				dev_driver_string(dev->dev.parent),
+				dev_name(dev->dev.parent),
+				netdev_name(dev), vaf);
+	} else if (dev) {
 		r = printk("%s%s: %pV", level, netdev_name(dev), vaf);
-	else
+	} else {
 		r = printk("%s(NULL net_device): %pV", level, vaf);
+	}
 
 	return r;
 }
-EXPORT_SYMBOL(__netdev_printk);
 
 int netdev_printk(const char *level, const struct net_device *dev,
 		  const char *format, ...)
@@ -6452,6 +6460,7 @@ int netdev_printk(const char *level, const struct net_device *dev,
 	vaf.va = &args;
 
 	r = __netdev_printk(level, dev, &vaf);
+
 	va_end(args);
 
 	return r;
@@ -6471,6 +6480,7 @@ int func(const struct net_device *dev, const char *fmt, ...)	\
 	vaf.va = &args;						\
 								\
 	r = __netdev_printk(level, dev, &vaf);			\
+								\
 	va_end(args);						\
 								\
 	return r;						\
-- 
1.7.8.111.gad25c.dirty
