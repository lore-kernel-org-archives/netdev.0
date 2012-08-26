From: Joe Perches <joe@perches.com>
Subject: [PATCH 1/5] dev_dbg/dynamic_debug: Update to use printk_emit, optimize stack
Date: Sun, 26 Aug 2012 04:25:26 -0700
Message-ID: <80eef5427bd92a3667d5bdbe5232c9c299b9b068.1345978012.git.joe@perches.com>
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

commit c4e00daaa9
("driver-core: extend dev_printk() to pass structured data")
changed __dev_printk and broke dynamic-debug's ability to control the
dynamic prefix of dev_dbg(dev,..).

commit af7f2158fd
("drivers-core: make structured logging play nice with dynamic-debug")
made a minimal correction.

The current dynamic debug code uses up to 3 recursion levels via %pV.
This can consume quite a bit of stack.  Directly call printk_emit to
reduce the recursion depth.

These changes include:

dev_dbg:
o Create and use function create_syslog_header to format the syslog
  header for printk_emit uses.
o Call create_syslog_header and neaten __dev_printk
o Make __dev_printk static not global
o Remove include header declaration of __dev_printk
o Remove now unused EXPORT_SYMBOL() of __dev_printk
o Whitespace neatening

dynamic_dev_dbg:
o Remove KERN_DEBUG from dynamic_emit_prefix
o Call create_syslog_header and printk_emit
o Whitespace neatening

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/base/core.c    |   64 +++++++++++++++++++++++++----------------------
 include/linux/device.h |    8 +++---
 lib/dynamic_debug.c    |   39 +++++++++++++++++++++-------
 3 files changed, 67 insertions(+), 44 deletions(-)

diff --git a/drivers/base/core.c b/drivers/base/core.c
index 5e6e00b..d46b635 100644
--- a/drivers/base/core.c
+++ b/drivers/base/core.c
@@ -1861,26 +1861,19 @@ void device_shutdown(void)
  */
 
 #ifdef CONFIG_PRINTK
-int __dev_printk(const char *level, const struct device *dev,
-		 struct va_format *vaf)
+int create_syslog_header(const struct device *dev, char *hdr, size_t hdrlen)
 {
-	char dict[128];
-	const char *level_extra = "";
-	size_t dictlen = 0;
 	const char *subsys;
-
-	if (!dev)
-		return printk("%s(NULL device *): %pV", level, vaf);
+	size_t pos = 0;
 
 	if (dev->class)
 		subsys = dev->class->name;
 	else if (dev->bus)
 		subsys = dev->bus->name;
 	else
-		goto skip;
+		return 0;
 
-	dictlen += snprintf(dict + dictlen, sizeof(dict) - dictlen,
-			    "SUBSYSTEM=%s", subsys);
+	pos += snprintf(hdr + pos, hdrlen - pos, "SUBSYSTEM=%s", subsys);
 
 	/*
 	 * Add device identifier DEVICE=:
@@ -1896,32 +1889,41 @@ int __dev_printk(const char *level, const struct device *dev,
 			c = 'b';
 		else
 			c = 'c';
-		dictlen++;
-		dictlen += snprintf(dict + dictlen, sizeof(dict) - dictlen,
-				   "DEVICE=%c%u:%u",
-				   c, MAJOR(dev->devt), MINOR(dev->devt));
+		pos++;
+		pos += snprintf(hdr + pos, hdrlen - pos,
+				"DEVICE=%c%u:%u",
+				c, MAJOR(dev->devt), MINOR(dev->devt));
 	} else if (strcmp(subsys, "net") == 0) {
 		struct net_device *net = to_net_dev(dev);
 
-		dictlen++;
-		dictlen += snprintf(dict + dictlen, sizeof(dict) - dictlen,
-				    "DEVICE=n%u", net->ifindex);
+		pos++;
+		pos += snprintf(hdr + pos, hdrlen - pos,
+				"DEVICE=n%u", net->ifindex);
 	} else {
-		dictlen++;
-		dictlen += snprintf(dict + dictlen, sizeof(dict) - dictlen,
-				    "DEVICE=+%s:%s", subsys, dev_name(dev));
+		pos++;
+		pos += snprintf(hdr + pos, hdrlen - pos,
+				"DEVICE=+%s:%s", subsys, dev_name(dev));
 	}
-skip:
-	if (level[2])
-		level_extra = &level[2]; /* skip past KERN_SOH "L" */
 
-	return printk_emit(0, level[1] - '0',
-			   dictlen ? dict : NULL, dictlen,
-			   "%s %s: %s%pV",
-			   dev_driver_string(dev), dev_name(dev),
-			   level_extra, vaf);
+	return pos;
+}
+EXPORT_SYMBOL(create_syslog_header);
+
+static int __dev_printk(const char *level, const struct device *dev,
+			struct va_format *vaf)
+{
+	char hdr[128];
+	size_t hdrlen;
+
+	if (!dev)
+		return printk("%s(NULL device *): %pV", level, vaf);
+
+	hdrlen = create_syslog_header(dev, hdr, sizeof(hdr));
+
+	return printk_emit(0, level[1] - '0', hdrlen ? hdr : NULL, hdrlen,
+			   "%s %s: %pV",
+			   dev_driver_string(dev), dev_name(dev), vaf);
 }
-EXPORT_SYMBOL(__dev_printk);
 
 int dev_printk(const char *level, const struct device *dev,
 	       const char *fmt, ...)
@@ -1936,6 +1938,7 @@ int dev_printk(const char *level, const struct device *dev,
 	vaf.va = &args;
 
 	r = __dev_printk(level, dev, &vaf);
+
 	va_end(args);
 
 	return r;
@@ -1955,6 +1958,7 @@ int func(const struct device *dev, const char *fmt, ...)	\
 	vaf.va = &args;						\
 								\
 	r = __dev_printk(kern_level, dev, &vaf);		\
+								\
 	va_end(args);						\
 								\
 	return r;						\
diff --git a/include/linux/device.h b/include/linux/device.h
index 52a5f15..4800d73 100644
--- a/include/linux/device.h
+++ b/include/linux/device.h
@@ -891,12 +891,12 @@ extern const char *dev_driver_string(const struct device *dev);
 
 #ifdef CONFIG_PRINTK
 
-extern int __dev_printk(const char *level, const struct device *dev,
-			struct va_format *vaf);
+extern int create_syslog_header(const struct device *dev,
+				char *hdr, size_t hdrlen);
+
 extern __printf(3, 4)
 int dev_printk(const char *level, const struct device *dev,
-	       const char *fmt, ...)
-	;
+	       const char *fmt, ...);
 extern __printf(2, 3)
 int dev_emerg(const struct device *dev, const char *fmt, ...);
 extern __printf(2, 3)
diff --git a/lib/dynamic_debug.c b/lib/dynamic_debug.c
index 7ca29a0..29ff2e4 100644
--- a/lib/dynamic_debug.c
+++ b/lib/dynamic_debug.c
@@ -521,25 +521,25 @@ static char *dynamic_emit_prefix(const struct _ddebug *desc, char *buf)
 	int pos_after_tid;
 	int pos = 0;
 
-	pos += snprintf(buf + pos, remaining(pos), "%s", KERN_DEBUG);
+	*buf = '\0';
+
 	if (desc->flags & _DPRINTK_FLAGS_INCL_TID) {
 		if (in_interrupt())
-			pos += snprintf(buf + pos, remaining(pos), "%s ",
-						"<intr>");
+			pos += snprintf(buf + pos, remaining(pos), "<intr> ");
 		else
 			pos += snprintf(buf + pos, remaining(pos), "[%d] ",
-						task_pid_vnr(current));
+					task_pid_vnr(current));
 	}
 	pos_after_tid = pos;
 	if (desc->flags & _DPRINTK_FLAGS_INCL_MODNAME)
 		pos += snprintf(buf + pos, remaining(pos), "%s:",
-					desc->modname);
+				desc->modname);
 	if (desc->flags & _DPRINTK_FLAGS_INCL_FUNCNAME)
 		pos += snprintf(buf + pos, remaining(pos), "%s:",
-					desc->function);
+				desc->function);
 	if (desc->flags & _DPRINTK_FLAGS_INCL_LINENO)
 		pos += snprintf(buf + pos, remaining(pos), "%d:",
-					desc->lineno);
+				desc->lineno);
 	if (pos - pos_after_tid)
 		pos += snprintf(buf + pos, remaining(pos), " ");
 	if (pos >= PREFIX_SIZE)
@@ -559,9 +559,13 @@ int __dynamic_pr_debug(struct _ddebug *descriptor, const char *fmt, ...)
 	BUG_ON(!fmt);
 
 	va_start(args, fmt);
+
 	vaf.fmt = fmt;
 	vaf.va = &args;
-	res = printk("%s%pV", dynamic_emit_prefix(descriptor, buf), &vaf);
+
+	res = printk(KERN_DEBUG "%s%pV",
+		     dynamic_emit_prefix(descriptor, buf), &vaf);
+
 	va_end(args);
 
 	return res;
@@ -574,15 +578,30 @@ int __dynamic_dev_dbg(struct _ddebug *descriptor,
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
-	res = __dev_printk(dynamic_emit_prefix(descriptor, buf), dev, &vaf);
+
+	if (!dev) {
+		res = printk(KERN_DEBUG "(NULL device *): %pV", &vaf);
+	} else {
+		char buf[PREFIX_SIZE];
+		char dict[128];
+		size_t dictlen;
+
+		dictlen = create_syslog_header(dev, dict, sizeof(dict));
+
+		res = printk_emit(0, 7, dictlen ? dict : NULL, dictlen,
+				  "%s%s %s: %pV",
+				  dynamic_emit_prefix(descriptor, buf),
+				  dev_driver_string(dev), dev_name(dev), &vaf);
+	}
+
 	va_end(args);
 
 	return res;
-- 
1.7.8.111.gad25c.dirty
