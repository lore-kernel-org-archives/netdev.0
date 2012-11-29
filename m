From: Akinobu Mita <akinobu.mita@gmail.com>
Subject: [PATCH] mISDN: improve bitops usage
Date: Thu, 29 Nov 2012 20:27:45 +0900
Message-ID: <1354188465-29012-1-git-send-email-akinobu.mita@gmail.com>
Cc: Akinobu Mita <akinobu.mita@gmail.com>,
	Karsten Keil <isdn@linux-pingi.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:38129 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752760Ab2K2L2K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Nov 2012 06:28:10 -0500
Received: by mail-pa0-f46.google.com with SMTP id bh2so7553682pad.19
        for <netdev@vger.kernel.org>; Thu, 29 Nov 2012 03:28:10 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This improves bitops usages in several points:

- Convert u64 to a proper bitmap declaration.  This enables to remove
  superfluous typecasting from 'u64' to 'unsigned long *'.

- Convert superfluous atomic bitops to non atomic bitops.  The bitmap
  is allocated on the stack and it is not accessed by any other threads,
  so using atomic bitops is not necessary.

- Use find_next_zero_bit and find_next_zero_bit instead of calling
  test_bit() for each bit.

Signed-off-by: Akinobu Mita <akinobu.mita@gmail.com>
Cc: Karsten Keil <isdn@linux-pingi.de>
Cc: netdev@vger.kernel.org
---
 drivers/isdn/mISDN/tei.c | 20 ++++++++++----------
 1 file changed, 10 insertions(+), 10 deletions(-)

diff --git a/drivers/isdn/mISDN/tei.c b/drivers/isdn/mISDN/tei.c
index be88728..592f597 100644
--- a/drivers/isdn/mISDN/tei.c
+++ b/drivers/isdn/mISDN/tei.c
@@ -250,7 +250,7 @@ tei_debug(struct FsmInst *fi, char *fmt, ...)
 static int
 get_free_id(struct manager *mgr)
 {
-	u64		ids = 0;
+	DECLARE_BITMAP(ids, 64) = { [0 ... BITS_TO_LONGS(64) - 1] = 0 };
 	int		i;
 	struct layer2	*l2;
 
@@ -261,11 +261,11 @@ get_free_id(struct manager *mgr)
 			       __func__);
 			return -EBUSY;
 		}
-		test_and_set_bit(l2->ch.nr, (u_long *)&ids);
+		__set_bit(l2->ch.nr, ids);
 	}
-	for (i = 1; i < 64; i++)
-		if (!test_bit(i, (u_long *)&ids))
-			return i;
+	i = find_next_zero_bit(ids, 64, 1);
+	if (i < 64)
+		return i;
 	printk(KERN_WARNING "%s: more as 63 layer2 for one device\n",
 	       __func__);
 	return -EBUSY;
@@ -274,7 +274,7 @@ get_free_id(struct manager *mgr)
 static int
 get_free_tei(struct manager *mgr)
 {
-	u64		ids = 0;
+	DECLARE_BITMAP(ids, 64) = { [0 ... BITS_TO_LONGS(64) - 1] = 0 };
 	int		i;
 	struct layer2	*l2;
 
@@ -288,11 +288,11 @@ get_free_tei(struct manager *mgr)
 			continue;
 		i -= 64;
 
-		test_and_set_bit(i, (u_long *)&ids);
+		__set_bit(i, ids);
 	}
-	for (i = 0; i < 64; i++)
-		if (!test_bit(i, (u_long *)&ids))
-			return i + 64;
+	i = find_first_zero_bit(ids, 64);
+	if (i < 64)
+		return i + 64;
 	printk(KERN_WARNING "%s: more as 63 dynamic tei for one device\n",
 	       __func__);
 	return -1;
-- 
1.7.11.7
