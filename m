From: akpm@linux-foundation.org
Subject: [patch 28/28] Introduce strtol_check_range()
Date: Fri, 10 Aug 2007 14:12:10 -0700
Message-ID: <200708102112.l7ALCAd9009463@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	satyam@infradead.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:38500 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754772AbXHJVPr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Aug 2007 17:15:47 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Satyam Sharma <satyam@infradead.org>

Callers (especially "store" functions for sysfs or configfs attributes)
that want to convert an input string to a number may often also want to
check for simple input sanity or allowable range.  strtol10_check_range()
of netconsole does this, so extract it out into lib/vsprintf.c, make it
generic w.r.t.  base, and export it to the rest of the kernel and modules.

[akpm@linux-foundation.org: cleanups]
Signed-off-by: Satyam Sharma <satyam@infradead.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/netconsole.c |   46 +++++++++----------------------------
 include/linux/kernel.h   |    2 +
 lib/vsprintf.c           |   29 +++++++++++++++++++++++
 3 files changed, 43 insertions(+), 34 deletions(-)

diff -puN drivers/net/netconsole.c~introduce-strtol_check_range drivers/net/netconsole.c
--- a/drivers/net/netconsole.c~introduce-strtol_check_range
+++ a/drivers/net/netconsole.c
@@ -242,34 +242,6 @@ static struct netconsole_target *to_targ
 }
 
 /*
- * Wrapper over simple_strtol (base 10) with sanity and range checking.
- * We return (signed) long only because we may want to return errors.
- * Do not use this to convert numbers that are allowed to be negative.
- */
-static long strtol10_check_range(const char *cp, long min, long max)
-{
-	long ret;
-	char *p = (char *) cp;
-
-	WARN_ON(min < 0);
-	WARN_ON(max < min);
-
-	ret = simple_strtol(p, &p, 10);
-
-	if (*p && (*p != '\n')) {
-		printk(KERN_ERR "netconsole: invalid input\n");
-		return -EINVAL;
-	}
-	if ((ret < min) || (ret > max)) {
-		printk(KERN_ERR "netconsole: input %ld must be between "
-				"%ld and %ld\n", ret, min, max);
-		return -EINVAL;
-	}
-
-	return ret;
-}
-
-/*
  * Attribute operations for netconsole_target.
  */
 
@@ -335,9 +307,11 @@ static ssize_t store_enabled(struct netc
 	int err;
 	long enabled;
 
-	enabled = strtol10_check_range(buf, 0, 1);
-	if (enabled < 0)
+	enabled = strtol_check_range(buf, 0, 1, 10);
+	if (enabled < 0) {
+		printk(KERN_ERR "netconsole: invalid input\n");
 		return enabled;
+	}
 
 	if (enabled) {	/* 1 */
 
@@ -398,9 +372,11 @@ static ssize_t store_local_port(struct n
 		return -EINVAL;
 	}
 
-	local_port = strtol10_check_range(buf, 0, U16_MAX);
-	if (local_port < 0)
+	local_port = strtol_check_range(buf, 0, U16_MAX, 10);
+	if (local_port < 0) {
+		printk(KERN_ERR "netconsole: invalid input\n");
 		return local_port;
+	}
 
 	nt->np.local_port = local_port;
 
@@ -420,9 +396,11 @@ static ssize_t store_remote_port(struct 
 		return -EINVAL;
 	}
 
-	remote_port = strtol10_check_range(buf, 0, U16_MAX);
-	if (remote_port < 0)
+	remote_port = strtol_check_range(buf, 0, U16_MAX, 10);
+	if (remote_port < 0) {
+		printk(KERN_ERR "netconsole: invalid input\n");
 		return remote_port;
+	}
 
 	nt->np.remote_port = remote_port;
 
diff -puN include/linux/kernel.h~introduce-strtol_check_range include/linux/kernel.h
--- a/include/linux/kernel.h~introduce-strtol_check_range
+++ a/include/linux/kernel.h
@@ -121,6 +121,8 @@ extern unsigned long simple_strtoul(cons
 extern long simple_strtol(const char *,char **,unsigned int);
 extern unsigned long long simple_strtoull(const char *,char **,unsigned int);
 extern long long simple_strtoll(const char *,char **,unsigned int);
+extern long strtol_check_range(const char *cp, long min, long max,
+				unsigned int base);
 extern int sprintf(char * buf, const char * fmt, ...)
 	__attribute__ ((format (printf, 2, 3)));
 extern int vsprintf(char *buf, const char *, va_list)
diff -puN lib/vsprintf.c~introduce-strtol_check_range lib/vsprintf.c
--- a/lib/vsprintf.c~introduce-strtol_check_range
+++ a/lib/vsprintf.c
@@ -126,6 +126,35 @@ long long simple_strtoll(const char *cp,
 	return simple_strtoull(cp,endp,base);
 }
 
+/**
+ * strtol_check_range - wrapper over simple_strtol with input and range checking
+ * @cp: The start of the string
+ * @min: Minimum value allowed
+ * @max: Maximum value allowed
+ * @base: The number base to use
+ *
+ * We return (signed) long only because we may want to return errors.
+ * Do not use this to convert numbers that are allowed to be negative.
+ */
+long strtol_check_range(const char *cp, long min, long max, unsigned int base)
+{
+	long ret;
+	char *p = (char *) cp;
+
+	WARN_ON(min < 0);
+	WARN_ON(max < min);
+
+	ret = simple_strtol(p, &p, base);
+
+	if (*p && (*p != '\n'))
+		return -EINVAL;
+	if ((ret < min) || (ret > max))
+		return -EINVAL;
+
+	return ret;
+}
+EXPORT_SYMBOL(strtol_check_range);
+
 static int skip_atoi(const char **s)
 {
 	int i=0;
_
