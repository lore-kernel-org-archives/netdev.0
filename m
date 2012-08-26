From: Joe Perches <joe@perches.com>
Subject: [PATCH 4/5] dev: Add dev_vprintk_emit and dev_printk_emit
Date: Sun, 26 Aug 2012 04:25:29 -0700
Message-ID: <7cfb202968f0928bba66965146a828a1cff87950.1345978012.git.joe@perches.com>
References: <cover.1345978012.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Jason Baron <jbaron@redhat.com>,
	Jim Cromie <jim.cromie@gmail.com>, Kay Sievers <kay@vrfy.org>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1345978012.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add utility functions to consolidate the use of
create_syslog_header and vprintk_emit.

This allows conversion of logging functions that
call create_syslog_header and then call vprintk_emit
or printk_emit to the dev_ equivalents.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/base/core.c    |   27 +++++++++++++++++++++++++++
 include/linux/device.h |   11 +++++++++++
 2 files changed, 38 insertions(+), 0 deletions(-)

diff --git a/drivers/base/core.c b/drivers/base/core.c
index d46b635..ffccb64 100644
--- a/drivers/base/core.c
+++ b/drivers/base/core.c
@@ -1909,6 +1909,33 @@ int create_syslog_header(const struct device *dev, char *hdr, size_t hdrlen)
 }
 EXPORT_SYMBOL(create_syslog_header);
 
+int dev_vprintk_emit(int level, const struct device *dev,
+		     const char *fmt, va_list args)
+{
+	char hdr[128];
+	size_t hdrlen;
+
+	hdrlen = create_syslog_header(dev, hdr, sizeof(hdr));
+
+	return vprintk_emit(0, level, hdrlen ? hdr : NULL, hdrlen, fmt, args);
+}
+EXPORT_SYMBOL(dev_vprintk_emit);
+
+int dev_printk_emit(int level, const struct device *dev, const char *fmt, ...)
+{
+	va_list args;
+	int r;
+
+	va_start(args, fmt);
+
+	r = dev_vprintk_emit(level, dev, fmt, args);
+
+	va_end(args);
+
+	return r;
+}
+EXPORT_SYMBOL(dev_printk_emit);
+
 static int __dev_printk(const char *level, const struct device *dev,
 			struct va_format *vaf)
 {
diff --git a/include/linux/device.h b/include/linux/device.h
index 4800d73..0063d01 100644
--- a/include/linux/device.h
+++ b/include/linux/device.h
@@ -893,6 +893,10 @@ extern const char *dev_driver_string(const struct device *dev);
 
 extern int create_syslog_header(const struct device *dev,
 				char *hdr, size_t hdrlen);
+extern int dev_vprintk_emit(int level, const struct device *dev,
+			    const char *fmt, va_list args);
+extern __printf(3, 4)
+int dev_printk_emit(int level, const struct device *dev, const char *fmt, ...);
 
 extern __printf(3, 4)
 int dev_printk(const char *level, const struct device *dev,
@@ -914,6 +918,13 @@ int _dev_info(const struct device *dev, const char *fmt, ...);
 
 #else
 
+static int dev_vprintk_emit(int level, const struct device *dev,
+			    const char *fmt, va_list args)
+{ return 0; }
+static inline __printf(3, 4)
+int dev_printk_emit(int level, const struct device *dev, const char *fmt, ...)
+{ return 0; }
+
 static inline int __dev_printk(const char *level, const struct device *dev,
 			       struct va_format *vaf)
 { return 0; }
-- 
1.7.8.111.gad25c.dirty
