From: Helmut Buchsbaum <helmut.buchsbaum@gmail.com>
Subject: [PATCH 1/1] net: macb: disable HW checksum offload for Xilinx Zynq
Date: Fri, 19 Aug 2016 15:04:58 +0200
Message-ID: <1471611898-3852-2-git-send-email-helmut.buchsbaum@gmail.com>
References: <1471611898-3852-1-git-send-email-helmut.buchsbaum@gmail.com>
Cc: netdev@vger.kernel.org,
        Cyrille Pitchen <cyrille.pitchen@atmel.com>,
        Helmut Buchsbaum <helmut.buchsbaum@gmail.com>
To: Nicolas Ferre <nicolas.ferre@atmel.com>,
        Michal Simek <michal.simek@xilinx.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:33166 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754305AbcHSNFK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 Aug 2016 09:05:10 -0400
Received: by mail-wm0-f68.google.com with SMTP id o80so3386085wme.0
        for <netdev@vger.kernel.org>; Fri, 19 Aug 2016 06:05:09 -0700 (PDT)
In-Reply-To: <1471611898-3852-1-git-send-email-helmut.buchsbaum@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When sending UDP packets with data payload size <= 2, Zynq's GEM
implementation for HW checksum offloading calculates wrong checksums.

Adding a MACB_CAPS_NO_CSUM_OFFLOAD capability and turning off HW checksum
offloading for Zynq solves it.

Signed-off-by: Helmut Buchsbaum <helmut.buchsbaum@gmail.com>
---
 drivers/net/ethernet/cadence/macb.c | 6 ++++--
 drivers/net/ethernet/cadence/macb.h | 1 +
 2 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 89c0cfa..26eba1a 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -2430,7 +2430,8 @@ static int macb_init(struct platform_device *pdev)
 	/* Set features */
 	dev->hw_features = NETIF_F_SG;
 	/* Checksum offload is only available on gem with packet buffer */
-	if (macb_is_gem(bp) && !(bp->caps & MACB_CAPS_FIFO_MODE))
+	if (macb_is_gem(bp) && !(bp->caps & MACB_CAPS_FIFO_MODE) &&
+	    !(bp->caps & MACB_CAPS_NO_CSUM_OFFLOAD))
 		dev->hw_features |= NETIF_F_HW_CSUM | NETIF_F_RXCSUM;
 	if (bp->caps & MACB_CAPS_SG_DISABLED)
 		dev->hw_features &= ~NETIF_F_SG;
@@ -2829,7 +2830,8 @@ static const struct macb_config zynqmp_config = {
 };
 
 static const struct macb_config zynq_config = {
-	.caps = MACB_CAPS_GIGABIT_MODE_AVAILABLE | MACB_CAPS_NO_GIGABIT_HALF,
+	.caps = MACB_CAPS_GIGABIT_MODE_AVAILABLE | MACB_CAPS_NO_GIGABIT_HALF |
+		MACB_CAPS_NO_CSUM_OFFLOAD,
 	.dma_burst_length = 16,
 	.clk_init = macb_clk_init,
 	.init = macb_init,
diff --git a/drivers/net/ethernet/cadence/macb.h b/drivers/net/ethernet/cadence/macb.h
index b6fcf10..79193db 100644
--- a/drivers/net/ethernet/cadence/macb.h
+++ b/drivers/net/ethernet/cadence/macb.h
@@ -404,6 +404,7 @@
 #define MACB_CAPS_NO_GIGABIT_HALF		0x00000008
 #define MACB_CAPS_USRIO_DISABLED		0x00000010
 #define MACB_CAPS_JUMBO				0x00000020
+#define MACB_CAPS_NO_CSUM_OFFLOAD		0x08000000
 #define MACB_CAPS_FIFO_MODE			0x10000000
 #define MACB_CAPS_GIGABIT_MODE_AVAILABLE	0x20000000
 #define MACB_CAPS_SG_DISABLED			0x40000000
-- 
2.1.4
