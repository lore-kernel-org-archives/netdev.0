From: Michael Buesch <mb@bu3sch.de>
Subject: [PATCH] b44: Unconditionally enable interrupt routing on reset
Date: Sun, 16 Nov 2008 15:37:30 +0100
Message-ID: <200811161537.30404.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Pantelis Koukousoulas <pktoss@gmail.com>,
	Gary Zambrano <zambrano@broadcom.com>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bu3sch.de ([62.75.166.246]:49861 "EHLO vs166246.vserver.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751997AbYKPP0k (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 16 Nov 2008 10:26:40 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Unconditionally setup the IRQ routing on chip reset.
It's safe to call ssb_pcicore_dev_irqvecs_enable() unconditionally, because
it has internal checks for redundant calls.

This fixes problems where hardware will not come up properly
due to quirks in the enable-bit hardware.

Reported-by: Pantelis Koukousoulas <pktoss@gmail.com>
Signed-off-by: Michael Buesch <mb@bu3sch.de>

---

I'm not sure if we should push this for 2.6.28.
This fixes quirks when booting from PXE. So only a minority of
the b44 users are affected.

Index: wireless-testing/drivers/net/b44.c
===================================================================
--- wireless-testing.orig/drivers/net/b44.c	2008-11-16 14:47:06.000000000 +0100
+++ wireless-testing/drivers/net/b44.c	2008-11-16 15:03:35.000000000 +0100
@@ -1266,8 +1266,14 @@ static void b44_clear_stats(struct b44 *
 static void b44_chip_reset(struct b44 *bp, int reset_kind)
 {
 	struct ssb_device *sdev = bp->sdev;
+	bool was_enabled;
 
-	if (ssb_device_is_enabled(bp->sdev)) {
+	was_enabled = ssb_device_is_enabled(bp->sdev);
+
+	ssb_device_enable(bp->sdev, 0);
+	ssb_pcicore_dev_irqvecs_enable(&sdev->bus->pcicore, sdev);
+
+	if (was_enabled) {
 		bw32(bp, B44_RCV_LAZY, 0);
 		bw32(bp, B44_ENET_CTRL, ENET_CTRL_DISABLE);
 		b44_wait_bit(bp, B44_ENET_CTRL, ENET_CTRL_DISABLE, 200, 1);
@@ -1279,10 +1285,8 @@ static void b44_chip_reset(struct b44 *b
 		}
 		bw32(bp, B44_DMARX_CTRL, 0);
 		bp->rx_prod = bp->rx_cons = 0;
-	} else
-		ssb_pcicore_dev_irqvecs_enable(&sdev->bus->pcicore, sdev);
+	}
 
-	ssb_device_enable(bp->sdev, 0);
 	b44_clear_stats(bp);
 
 	/*

-- 
Greetings Michael.
