From: Joe Perches <joe@perches.com>
Subject: [PATCH 5/5] device and dynamic_debug: Use dev_vprintk_emit and dev_printk_emit
Date: Sun, 26 Aug 2012 04:25:30 -0700
Message-ID: <7b5acb50f6cd1e9f3228930bff510c77fd8b823b.1345978012.git.joe@perches.com>
References: <cover.1345978012.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Jim Cromie <jim.cromie@gmail.com>, Kay Sievers <kay@vrfy.org>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Jason Baron <jbaron@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1345978012.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Convert direct calls of vprintk_emit and printk_emit to the
dev_ equivalents.

Make create_syslog_header static.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/base/core.c    |   14 +++++---------
 include/linux/device.h |    2 --
 lib/dynamic_debug.c    |   31 +++++++++++--------------------
 net/core/dev.c         |   16 ++++++----------
 4 files changed, 22 insertions(+), 41 deletions(-)

diff --git a/drivers/base/core.c b/drivers/base/core.c
index ffccb64..65f82e3 100644
--- a/drivers/base/core.c
+++ b/drivers/base/core.c
@@ -1861,7 +1861,8 @@ void device_shutdown(void)
  */
 
 #ifdef CONFIG_PRINTK
-int create_syslog_header(const struct device *dev, char *hdr, size_t hdrlen)
+static int
+create_syslog_header(const struct device *dev, char *hdr, size_t hdrlen)
 {
 	const char *subsys;
 	size_t pos = 0;
@@ -1939,17 +1940,12 @@ EXPORT_SYMBOL(dev_printk_emit);
 static int __dev_printk(const char *level, const struct device *dev,
 			struct va_format *vaf)
 {
-	char hdr[128];
-	size_t hdrlen;
-
 	if (!dev)
 		return printk("%s(NULL device *): %pV", level, vaf);
 
-	hdrlen = create_syslog_header(dev, hdr, sizeof(hdr));
-
-	return printk_emit(0, level[1] - '0', hdrlen ? hdr : NULL, hdrlen,
-			   "%s %s: %pV",
-			   dev_driver_string(dev), dev_name(dev), vaf);
+	return dev_printk_emit(level[1] - '0', dev,
+			       "%s %s: %pV",
+			       dev_driver_string(dev), dev_name(dev), vaf);
 }
 
 int dev_printk(const char *level, const struct device *dev,
diff --git a/include/linux/device.h b/include/linux/device.h
index 0063d01..2da4589 100644
--- a/include/linux/device.h
+++ b/include/linux/device.h
@@ -891,8 +891,6 @@ extern const char *dev_driver_string(const struct device *dev);
 
 #ifdef CONFIG_PRINTK
 
-extern int create_syslog_header(const struct device *dev,
-				char *hdr, size_t hdrlen);
 extern int dev_vprintk_emit(int level, const struct device *dev,
 			    const char *fmt, va_list args);
 extern __printf(3, 4)
diff --git a/lib/dynamic_debug.c b/lib/dynamic_debug.c
index 6b3ebab..e7f7d99 100644
--- a/lib/dynamic_debug.c
+++ b/lib/dynamic_debug.c
@@ -591,15 +591,11 @@ int __dynamic_dev_dbg(struct _ddebug *descriptor,
 		res = printk(KERN_DEBUG "(NULL device *): %pV", &vaf);
 	} else {
 		char buf[PREFIX_SIZE];
-		char dict[128];
-		size_t dictlen;
 
-		dictlen = create_syslog_header(dev, dict, sizeof(dict));
-
-		res = printk_emit(0, 7, dictlen ? dict : NULL, dictlen,
-				  "%s%s %s: %pV",
-				  dynamic_emit_prefix(descriptor, buf),
-				  dev_driver_string(dev), dev_name(dev), &vaf);
+		res = dev_printk_emit(7, dev, "%s%s %s: %pV",
+				      dynamic_emit_prefix(descriptor, buf),
+				      dev_driver_string(dev), dev_name(dev),
+				      &vaf);
 	}
 
 	va_end(args);
@@ -627,18 +623,13 @@ int __dynamic_netdev_dbg(struct _ddebug *descriptor,
 
 	if (dev && dev->dev.parent) {
 		char buf[PREFIX_SIZE];
-		char dict[128];
-		size_t dictlen;
-
-		dictlen = create_syslog_header(dev->dev.parent,
-					       dict, sizeof(dict));
-
-		res = printk_emit(0, 7, dictlen ? dict : NULL, dictlen,
-				  "%s%s %s %s: %pV",
-				  dynamic_emit_prefix(descriptor, buf),
-				  dev_driver_string(dev->dev.parent),
-				  dev_name(dev->dev.parent),
-				  netdev_name(dev), &vaf);
+
+		res = dev_printk_emit(7, dev->dev.parent,
+				      "%s%s %s %s: %pV",
+				      dynamic_emit_prefix(descriptor, buf),
+				      dev_driver_string(dev->dev.parent),
+				      dev_name(dev->dev.parent),
+				      netdev_name(dev), &vaf);
 	} else if (dev) {
 		res = printk(KERN_DEBUG "%s: %pV", netdev_name(dev), &vaf);
 	} else {
diff --git a/net/core/dev.c b/net/core/dev.c
index 1ec186a..8ad42fd 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -6428,16 +6428,12 @@ static int __netdev_printk(const char *level, const struct net_device *dev,
 	int r;
 
 	if (dev && dev->dev.parent) {
-		char dict[128];
-		size_t dictlen = create_syslog_header(dev->dev.parent,
-						      dict, sizeof(dict));
-
-		r = printk_emit(0, level[1] - '0',
-				dictlen ? dict : NULL, dictlen,
-				"%s %s %s: %pV",
-				dev_driver_string(dev->dev.parent),
-				dev_name(dev->dev.parent),
-				netdev_name(dev), vaf);
+		r = dev_printk_emit(level[1] - '0',
+				    dev->dev.parent,
+				    "%s %s %s: %pV",
+				    dev_driver_string(dev->dev.parent),
+				    dev_name(dev->dev.parent),
+				    netdev_name(dev), vaf);
 	} else if (dev) {
 		r = printk("%s%s: %pV", level, netdev_name(dev), vaf);
 	} else {
-- 
1.7.8.111.gad25c.dirty
