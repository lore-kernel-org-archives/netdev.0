From: Andy Shevchenko <andy.shevchenko@gmail.com>
Subject: [PATCH 2/3] drivers: isdn: remove custom strtoul()
Date: Thu, 15 Jul 2010 15:37:19 +0300
Message-ID: <1279197440-6585-2-git-send-email-andy.shevchenko@gmail.com>
References: <1279197440-6585-1-git-send-email-andy.shevchenko@gmail.com>
Cc: Andy Shevchenko <andy.shevchenko@gmail.com>,
	Karsten Keil <isdn@linux-pingi.de>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:32856 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755721Ab0GOMhm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jul 2010 08:37:42 -0400
In-Reply-To: <1279197440-6585-1-git-send-email-andy.shevchenko@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In this case we safe to use strict_strtoul().

Signed-off-by: Andy Shevchenko <andy.shevchenko@gmail.com>
Cc: Karsten Keil <isdn@linux-pingi.de>
Cc: netdev@vger.kernel.org
---
 drivers/isdn/hysdn/hysdn_proclog.c |   36 +++++++-----------------------------
 1 files changed, 7 insertions(+), 29 deletions(-)

diff --git a/drivers/isdn/hysdn/hysdn_proclog.c b/drivers/isdn/hysdn/hysdn_proclog.c
index 7003698..2ee93d0 100644
--- a/drivers/isdn/hysdn/hysdn_proclog.c
+++ b/drivers/isdn/hysdn/hysdn_proclog.c
@@ -16,6 +16,7 @@
 #include <linux/sched.h>
 #include <linux/slab.h>
 #include <linux/mutex.h>
+#include <linux/kernel.h>
 
 #include "hysdn_defs.h"
 
@@ -155,9 +156,8 @@ static ssize_t
 hysdn_log_write(struct file *file, const char __user *buf, size_t count, loff_t * off)
 {
 	unsigned long u = 0;
-	int found = 0;
-	unsigned char *cp, valbuf[128];
-	long base = 10;
+	int rc;
+	unsigned char valbuf[128];
 	hysdn_card *card = file->private_data;
 
 	if (count > (sizeof(valbuf) - 1))
@@ -166,32 +166,10 @@ hysdn_log_write(struct file *file, const char __user *buf, size_t count, loff_t
 		return (-EFAULT);	/* copy failed */
 
 	valbuf[count] = 0;	/* terminating 0 */
-	cp = valbuf;
-	if ((count > 2) && (valbuf[0] == '0') && (valbuf[1] == 'x')) {
-		cp += 2;	/* pointer after hex modifier */
-		base = 16;
-	}
-	/* scan the input for debug flags */
-	while (*cp) {
-		if ((*cp >= '0') && (*cp <= '9')) {
-			found = 1;
-			u *= base;	/* adjust to next digit */
-			u += *cp++ - '0';
-			continue;
-		}
-		if (base != 16)
-			break;	/* end of number */
-
-		if ((*cp >= 'a') && (*cp <= 'f')) {
-			found = 1;
-			u *= base;	/* adjust to next digit */
-			u += *cp++ - 'a' + 10;
-			continue;
-		}
-		break;		/* terminated */
-	}
 
-	if (found) {
+	rc = strict_strtoul(valbuf, 0, &u);
+
+	if (rc == 0) {
 		card->debug_flags = u;	/* remember debug flags */
 		hysdn_addlog(card, "debug set to 0x%lx", card->debug_flags);
 	}
-- 
1.7.1.1

