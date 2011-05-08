From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] netconsole: switch to kstrto*() functions
Date: Sun, 8 May 2011 09:33:13 +0300
Message-ID: <20110508063313.GA6352@p183>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:43446 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751314Ab1EHGdT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 May 2011 02:33:19 -0400
Received: by eyx24 with SMTP id 24so1296915eyx.19
        for <netdev@vger.kernel.org>; Sat, 07 May 2011 23:33:18 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 drivers/net/netconsole.c |   62 ++++++++++-------------------------------------
 1 file changed, 14 insertions(+), 48 deletions(-)

--- a/drivers/net/netconsole.c
+++ b/drivers/net/netconsole.c
@@ -242,34 +242,6 @@ static struct netconsole_target *to_target(struct config_item *item)
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
 
@@ -327,12 +299,14 @@ static ssize_t store_enabled(struct netconsole_target *nt,
 			     const char *buf,
 			     size_t count)
 {
+	int enabled;
 	int err;
-	long enabled;
 
-	enabled = strtol10_check_range(buf, 0, 1);
-	if (enabled < 0)
-		return enabled;
+	err = kstrtoint(buf, 10, &enabled);
+	if (err < 0)
+		return err;
+	if (enabled < 0 || enabled > 1)
+		return -EINVAL;
 
 	if (enabled) {	/* 1 */
 
@@ -384,8 +358,7 @@ static ssize_t store_local_port(struct netconsole_target *nt,
 				const char *buf,
 				size_t count)
 {
-	long local_port;
-#define __U16_MAX	((__u16) ~0U)
+	int rv;
 
 	if (nt->enabled) {
 		printk(KERN_ERR "netconsole: target (%s) is enabled, "
@@ -394,12 +367,9 @@ static ssize_t store_local_port(struct netconsole_target *nt,
 		return -EINVAL;
 	}
 
-	local_port = strtol10_check_range(buf, 0, __U16_MAX);
-	if (local_port < 0)
-		return local_port;
-
-	nt->np.local_port = local_port;
-
+	rv = kstrtou16(buf, 10, &nt->np.local_port);
+	if (rv < 0)
+		return rv;
 	return strnlen(buf, count);
 }
 
@@ -407,8 +377,7 @@ static ssize_t store_remote_port(struct netconsole_target *nt,
 				 const char *buf,
 				 size_t count)
 {
-	long remote_port;
-#define __U16_MAX	((__u16) ~0U)
+	int rv;
 
 	if (nt->enabled) {
 		printk(KERN_ERR "netconsole: target (%s) is enabled, "
@@ -417,12 +386,9 @@ static ssize_t store_remote_port(struct netconsole_target *nt,
 		return -EINVAL;
 	}
 
-	remote_port = strtol10_check_range(buf, 0, __U16_MAX);
-	if (remote_port < 0)
-		return remote_port;
-
-	nt->np.remote_port = remote_port;
-
+	rv = kstrtou16(buf, 10, &nt->np.remote_port);
+	if (rv < 0)
+		return rv;
 	return strnlen(buf, count);
 }
 
