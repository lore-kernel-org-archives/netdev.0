From: Andy Fleming <afleming@freescale.com>
Subject: [PATCH v2.6.29 01/14] gianfar: Use gfar_halt to stop DMA in gfar_probe
Date: Tue, 16 Dec 2008 17:20:54 -0600
Message-ID: <1229469667-25002-2-git-send-email-afleming@freescale.com>
References: <1229469667-25002-1-git-send-email-afleming@freescale.com>
Cc: galak@kernel.crashing.org, netdev@vger.kernel.org,
	Andy Fleming <afleming@freescale.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:39643 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752880AbYLPXVT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Dec 2008 18:21:19 -0500
Received: from az33smr01.freescale.net (az33smr01.freescale.net [10.64.34.199])
	by az33egw02.freescale.net (8.14.3/az33egw02) with ESMTP id mBGNL8nm013509
	for <netdev@vger.kernel.org>; Tue, 16 Dec 2008 16:21:08 -0700 (MST)
Received: from ld0175-tx32.am.freescale.net (ld0175-tx32.am.freescale.net [10.82.19.125])
	by az33smr01.freescale.net (8.13.1/8.13.0) with ESMTP id mBGNL8YK020979
	for <netdev@vger.kernel.org>; Tue, 16 Dec 2008 17:21:08 -0600 (CST)
In-Reply-To: <1229469667-25002-1-git-send-email-afleming@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

gfar_halt does everything we want to do there, including disabling
TX/RX.  It also doesn't unnecessarily enable DMA if it's already
stopped.

Signed-off-by: Andy Fleming <afleming@freescale.com>
---
 drivers/net/gianfar.c |   14 +-------------
 1 files changed, 1 insertions(+), 13 deletions(-)

diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 451f6b8..6ceff8d 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -225,19 +225,7 @@ static int gfar_probe(struct platform_device *pdev)
 
 	/* Stop the DMA engine now, in case it was running before */
 	/* (The firmware could have used it, and left it running). */
-	/* To do this, we write Graceful Receive Stop and Graceful */
-	/* Transmit Stop, and then wait until the corresponding bits */
-	/* in IEVENT indicate the stops have completed. */
-	tempval = gfar_read(&priv->regs->dmactrl);
-	tempval &= ~(DMACTRL_GRS | DMACTRL_GTS);
-	gfar_write(&priv->regs->dmactrl, tempval);
-
-	tempval = gfar_read(&priv->regs->dmactrl);
-	tempval |= (DMACTRL_GRS | DMACTRL_GTS);
-	gfar_write(&priv->regs->dmactrl, tempval);
-
-	while (!(gfar_read(&priv->regs->ievent) & (IEVENT_GRSC | IEVENT_GTSC)))
-		cpu_relax();
+	gfar_halt(dev);
 
 	/* Reset MAC layer */
 	gfar_write(&priv->regs->maccfg1, MACCFG1_SOFT_RESET);
-- 
1.5.4.GIT

