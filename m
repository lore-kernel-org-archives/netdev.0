From: Abhishek Shah <abhishek.shah@broadcom.com>
Subject: [PATCH 2/3] net: ethernet: bgmac: Make IDM register space optional
Date: Fri, 14 Jul 2017 00:34:08 +0530
Message-ID: <1499972649-6200-3-git-send-email-abhishek.shah@broadcom.com>
References: <1499972649-6200-1-git-send-email-abhishek.shah@broadcom.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org, devicetree@vger.kernel.org,
        bcm-kernel-feedback-list@broadcom.com,
        Abhishek Shah <abhishek.shah@broadcom.com>
To: =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <rafal@milecki.pl>,
        Florian Fainelli <f.fainelli@gmail.com>,
        "David S . Miller" <davem@davemloft.net>,
        Jon Mason <jon.mason@broadcom.com>,
        Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f42.google.com ([74.125.82.42]:38146 "EHLO
        mail-wm0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752847AbdGMTEp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Jul 2017 15:04:45 -0400
Received: by mail-wm0-f42.google.com with SMTP id f67so1809603wmh.1
        for <netdev@vger.kernel.org>; Thu, 13 Jul 2017 12:04:44 -0700 (PDT)
In-Reply-To: <1499972649-6200-1-git-send-email-abhishek.shah@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IDM operations are usually one time ops and should be done in
firmware itself. Driver is not supposed to touch IDM registers.

However, for some SoCs', driver is performing IDM read/writes.
So this patch masks IDM operations in case firmware is taking
care of IDM operations.

Signed-off-by: Abhishek Shah <abhishek.shah@broadcom.com>
Reviewed-by: Oza Oza <oza.oza@broadcom.com>
Reviewed-by: Ray Jui <ray.jui@broadcom.com>
Reviewed-by: Scott Branden <scott.branden@broadcom.com>
---
 drivers/net/ethernet/broadcom/bgmac-platform.c | 19 ++++---
 drivers/net/ethernet/broadcom/bgmac.c          | 70 +++++++++++++++-----------
 drivers/net/ethernet/broadcom/bgmac.h          |  1 +
 3 files changed, 55 insertions(+), 35 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bgmac-platform.c b/drivers/net/ethernet/broadcom/bgmac-platform.c
index 1ca75de..d937083d 100644
--- a/drivers/net/ethernet/broadcom/bgmac-platform.c
+++ b/drivers/net/ethernet/broadcom/bgmac-platform.c
@@ -55,6 +55,9 @@ static void platform_bgmac_idm_write(struct bgmac *bgmac, u16 offset, u32 value)
 
 static bool platform_bgmac_clk_enabled(struct bgmac *bgmac)
 {
+	if (!bgmac->plat.idm_base)
+		return true;
+
 	if ((bgmac_idm_read(bgmac, BCMA_IOCTL) & BGMAC_CLK_EN) != BGMAC_CLK_EN)
 		return false;
 	if (bgmac_idm_read(bgmac, BCMA_RESET_CTL) & BCMA_RESET_CTL_RESET)
@@ -66,6 +69,9 @@ static void platform_bgmac_clk_enable(struct bgmac *bgmac, u32 flags)
 {
 	u32 val;
 
+	if (!bgmac->plat.idm_base)
+		return;
+
 	/* The Reset Control register only contains a single bit to show if the
 	 * controller is currently in reset.  Do a sanity check here, just in
 	 * case the bootloader happened to leave the device in reset.
@@ -180,6 +186,7 @@ static int bgmac_probe(struct platform_device *pdev)
 	bgmac->feature_flags |= BGMAC_FEAT_CMDCFG_SR_REV4;
 	bgmac->feature_flags |= BGMAC_FEAT_TX_MASK_SETUP;
 	bgmac->feature_flags |= BGMAC_FEAT_RX_MASK_SETUP;
+	bgmac->feature_flags |= BGMAC_FEAT_IDM_MASK;
 
 	bgmac->dev = &pdev->dev;
 	bgmac->dma_dev = &pdev->dev;
@@ -207,15 +214,13 @@ static int bgmac_probe(struct platform_device *pdev)
 		return PTR_ERR(bgmac->plat.base);
 
 	regs = platform_get_resource_byname(pdev, IORESOURCE_MEM, "idm_base");
-	if (!regs) {
-		dev_err(&pdev->dev, "Unable to obtain idm resource\n");
-		return -EINVAL;
+	if (regs) {
+		bgmac->plat.idm_base = devm_ioremap_resource(&pdev->dev, regs);
+		if (IS_ERR(bgmac->plat.idm_base))
+			return PTR_ERR(bgmac->plat.idm_base);
+		bgmac->feature_flags &= ~BGMAC_FEAT_IDM_MASK;
 	}
 
-	bgmac->plat.idm_base = devm_ioremap_resource(&pdev->dev, regs);
-	if (IS_ERR(bgmac->plat.idm_base))
-		return PTR_ERR(bgmac->plat.idm_base);
-
 	regs = platform_get_resource_byname(pdev, IORESOURCE_MEM, "nicpm_base");
 	if (regs) {
 		bgmac->plat.nicpm_base = devm_ioremap_resource(&pdev->dev,
diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/ethernet/broadcom/bgmac.c
index ba4d2e1..48d672b 100644
--- a/drivers/net/ethernet/broadcom/bgmac.c
+++ b/drivers/net/ethernet/broadcom/bgmac.c
@@ -622,9 +622,11 @@ static int bgmac_dma_alloc(struct bgmac *bgmac)
 	BUILD_BUG_ON(BGMAC_MAX_TX_RINGS > ARRAY_SIZE(ring_base));
 	BUILD_BUG_ON(BGMAC_MAX_RX_RINGS > ARRAY_SIZE(ring_base));
 
-	if (!(bgmac_idm_read(bgmac, BCMA_IOST) & BCMA_IOST_DMA64)) {
-		dev_err(bgmac->dev, "Core does not report 64-bit DMA\n");
-		return -ENOTSUPP;
+	if (!(bgmac->feature_flags & BGMAC_FEAT_IDM_MASK)) {
+		if (!(bgmac_idm_read(bgmac, BCMA_IOST) & BCMA_IOST_DMA64)) {
+			dev_err(bgmac->dev, "Core does not report 64-bit DMA\n");
+			return -ENOTSUPP;
+		}
 	}
 
 	for (i = 0; i < BGMAC_MAX_TX_RINGS; i++) {
@@ -855,9 +857,11 @@ static void bgmac_mac_speed(struct bgmac *bgmac)
 static void bgmac_miiconfig(struct bgmac *bgmac)
 {
 	if (bgmac->feature_flags & BGMAC_FEAT_FORCE_SPEED_2500) {
-		bgmac_idm_write(bgmac, BCMA_IOCTL,
-				bgmac_idm_read(bgmac, BCMA_IOCTL) | 0x40 |
-				BGMAC_BCMA_IOCTL_SW_CLKEN);
+		if (!(bgmac->feature_flags & BGMAC_FEAT_IDM_MASK)) {
+			bgmac_idm_write(bgmac, BCMA_IOCTL,
+					bgmac_idm_read(bgmac, BCMA_IOCTL) |
+					0x40 | BGMAC_BCMA_IOCTL_SW_CLKEN);
+		}
 		bgmac->mac_speed = SPEED_2500;
 		bgmac->mac_duplex = DUPLEX_FULL;
 		bgmac_mac_speed(bgmac);
@@ -874,11 +878,36 @@ static void bgmac_miiconfig(struct bgmac *bgmac)
 	}
 }
 
+static void bgmac_chip_reset_idm_config(struct bgmac *bgmac)
+{
+	u32 iost;
+
+	iost = bgmac_idm_read(bgmac, BCMA_IOST);
+	if (bgmac->feature_flags & BGMAC_FEAT_IOST_ATTACHED)
+		iost &= ~BGMAC_BCMA_IOST_ATTACHED;
+
+	/* 3GMAC: for BCM4707 & BCM47094, only do core reset at bgmac_probe() */
+	if (!(bgmac->feature_flags & BGMAC_FEAT_NO_RESET)) {
+		u32 flags = 0;
+
+		if (iost & BGMAC_BCMA_IOST_ATTACHED) {
+			flags = BGMAC_BCMA_IOCTL_SW_CLKEN;
+			if (!bgmac->has_robosw)
+				flags |= BGMAC_BCMA_IOCTL_SW_RESET;
+		}
+		bgmac_clk_enable(bgmac, flags);
+	}
+
+	if (iost & BGMAC_BCMA_IOST_ATTACHED && !bgmac->has_robosw)
+		bgmac_idm_write(bgmac, BCMA_IOCTL,
+				bgmac_idm_read(bgmac, BCMA_IOCTL) &
+				~BGMAC_BCMA_IOCTL_SW_RESET);
+}
+
 /* http://bcm-v4.sipsolutions.net/mac-gbit/gmac/chipreset */
 static void bgmac_chip_reset(struct bgmac *bgmac)
 {
 	u32 cmdcfg_sr;
-	u32 iost;
 	int i;
 
 	if (bgmac_clk_enabled(bgmac)) {
@@ -899,20 +928,8 @@ static void bgmac_chip_reset(struct bgmac *bgmac)
 		/* TODO: Clear software multicast filter list */
 	}
 
-	iost = bgmac_idm_read(bgmac, BCMA_IOST);
-	if (bgmac->feature_flags & BGMAC_FEAT_IOST_ATTACHED)
-		iost &= ~BGMAC_BCMA_IOST_ATTACHED;
-
-	/* 3GMAC: for BCM4707 & BCM47094, only do core reset at bgmac_probe() */
-	if (!(bgmac->feature_flags & BGMAC_FEAT_NO_RESET)) {
-		u32 flags = 0;
-		if (iost & BGMAC_BCMA_IOST_ATTACHED) {
-			flags = BGMAC_BCMA_IOCTL_SW_CLKEN;
-			if (!bgmac->has_robosw)
-				flags |= BGMAC_BCMA_IOCTL_SW_RESET;
-		}
-		bgmac_clk_enable(bgmac, flags);
-	}
+	if (!(bgmac->feature_flags & BGMAC_FEAT_IDM_MASK))
+		bgmac_chip_reset_idm_config(bgmac);
 
 	/* Request Misc PLL for corerev > 2 */
 	if (bgmac->feature_flags & BGMAC_FEAT_MISC_PLL_REQ) {
@@ -970,11 +987,6 @@ static void bgmac_chip_reset(struct bgmac *bgmac)
 				      BGMAC_CHIPCTL_7_IF_TYPE_RGMII);
 	}
 
-	if (iost & BGMAC_BCMA_IOST_ATTACHED && !bgmac->has_robosw)
-		bgmac_idm_write(bgmac, BCMA_IOCTL,
-				bgmac_idm_read(bgmac, BCMA_IOCTL) &
-				~BGMAC_BCMA_IOCTL_SW_RESET);
-
 	/* http://bcm-v4.sipsolutions.net/mac-gbit/gmac/gmac_reset
 	 * Specs don't say about using BGMAC_CMDCFG_SR, but in this routine
 	 * BGMAC_CMDCFG is read _after_ putting chip in a reset. So it has to
@@ -1497,8 +1509,10 @@ int bgmac_enet_probe(struct bgmac *bgmac)
 	bgmac_clk_enable(bgmac, 0);
 
 	/* This seems to be fixing IRQ by assigning OOB #6 to the core */
-	if (bgmac->feature_flags & BGMAC_FEAT_IRQ_ID_OOB_6)
-		bgmac_idm_write(bgmac, BCMA_OOB_SEL_OUT_A30, 0x86);
+	if (!(bgmac->feature_flags & BGMAC_FEAT_IDM_MASK)) {
+		if (bgmac->feature_flags & BGMAC_FEAT_IRQ_ID_OOB_6)
+			bgmac_idm_write(bgmac, BCMA_OOB_SEL_OUT_A30, 0x86);
+	}
 
 	bgmac_chip_reset(bgmac);
 
diff --git a/drivers/net/ethernet/broadcom/bgmac.h b/drivers/net/ethernet/broadcom/bgmac.h
index c181876..443d57b 100644
--- a/drivers/net/ethernet/broadcom/bgmac.h
+++ b/drivers/net/ethernet/broadcom/bgmac.h
@@ -425,6 +425,7 @@
 #define BGMAC_FEAT_CC4_IF_SW_TYPE	BIT(17)
 #define BGMAC_FEAT_CC4_IF_SW_TYPE_RGMII	BIT(18)
 #define BGMAC_FEAT_CC7_IF_TYPE_RGMII	BIT(19)
+#define BGMAC_FEAT_IDM_MASK		BIT(20)
 
 struct bgmac_slot_info {
 	union {
-- 
2.7.4
