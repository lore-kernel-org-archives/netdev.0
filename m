From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] sky2: NAPI poll fix
Date: Mon, 17 Jul 2006 09:54:34 -0400
Message-ID: <20060717095434.7c6277f6@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:25730 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1750779AbWGQNyx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Jul 2006 09:54:53 -0400
To: Jeff Garzik <jgarzik@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When sky2 driver gets lots of received packets at once, it can get stuck.
The NAPI poll routine gets called back to keep going, but since no IRQ bits
are set it doesn't make progress.

Increase version, since this is serious enough problem that I want to be
able to tell new from old problems.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>


--- sky2.orig/drivers/net/sky2.c	2006-07-17 06:02:27.000000000 -0700
+++ sky2/drivers/net/sky2.c	2006-07-17 06:06:56.000000000 -0700
@@ -50,7 +50,7 @@
 #include "sky2.h"
 
 #define DRV_NAME		"sky2"
-#define DRV_VERSION		"1.4"
+#define DRV_VERSION		"1.5"
 #define PFX			DRV_NAME " "
 
 /*
@@ -2204,9 +2204,6 @@
 	int work_done = 0;
 	u32 status = sky2_read32(hw, B0_Y2_SP_EISR);
 
-	if (!~status)
-		goto out;
-
 	if (status & Y2_IS_HW_ERR)
 		sky2_hw_intr(hw);
 
@@ -2243,7 +2240,7 @@
 
 	if (sky2_more_work(hw))
 		return 1;
-out:
+
 	netif_rx_complete(dev0);
 
 	sky2_read32(hw, B0_Y2_SP_LISR);
