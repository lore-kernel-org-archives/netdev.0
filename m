From: Jamie Iles <jamie@jamieiles.com>
Subject: [PATCH 8/8] macb: support data bus widths > 32 bits
Date: Thu, 10 Mar 2011 10:10:43 +0000
Message-ID: <1299751843-9743-9-git-send-email-jamie@jamieiles.com>
References: <1299751843-9743-1-git-send-email-jamie@jamieiles.com>
Cc: nicolas.ferre@atmel.com, Jamie Iles <jamie@jamieiles.com>
To: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:44704 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752307Ab1CJKLK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Mar 2011 05:11:10 -0500
Received: by mail-wy0-f174.google.com with SMTP id 21so1289486wya.19
        for <netdev@vger.kernel.org>; Thu, 10 Mar 2011 02:11:09 -0800 (PST)
In-Reply-To: <1299751843-9743-1-git-send-email-jamie@jamieiles.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some GEM implementations may support data bus widths up to 128 bits.
Allow the platform data to specify the data bus width and let the driver
program it up.

Signed-off-by: Jamie Iles <jamie@jamieiles.com>
---
 drivers/net/macb.c                 |    5 +++++
 drivers/net/macb.h                 |    3 +++
 include/linux/platform_data/macb.h |    6 ++++++
 3 files changed, 14 insertions(+), 0 deletions(-)

diff --git a/drivers/net/macb.c b/drivers/net/macb.c
index 2965405..6ecbd69 100644
--- a/drivers/net/macb.c
+++ b/drivers/net/macb.c
@@ -797,6 +797,7 @@ static void macb_reset_hw(struct macb *bp)
 static void macb_init_hw(struct macb *bp)
 {
 	u32 config;
+	struct eth_platform_data *pdata = dev_get_platdata(&bp->pdev->dev);
 
 	macb_reset_hw(bp);
 	__macb_set_hwaddr(bp);
@@ -810,6 +811,8 @@ static void macb_init_hw(struct macb *bp)
 		config |= MACB_BIT(CAF);	/* Copy All Frames */
 	if (!(bp->dev->flags & IFF_BROADCAST))
 		config |= MACB_BIT(NBC);	/* No BroadCast */
+	if (bp->is_gem)
+		config |= GEM_BF(DBW, pdata->dbw);	/* Data bus width. */
 	macb_writel(bp, NCFGR, config);
 
 	/* Initialize TX and RX buffers */
@@ -1292,6 +1295,8 @@ static int __macb_probe(struct platform_device *pdev, int is_gem)
 	pclk_hz = clk_get_rate(bp->pclk);
 	config = bp->is_gem ? gem_mdc_clk_div(pclk_hz) :
 		macb_mdc_clk_div(pclk_hz);
+	if (bp->is_gem)
+		config |= GEM_BF(DBW, pdata->dbw);	/* Data bus width. */
 	macb_writel(bp, NCFGR, config);
 
 	macb_get_hwaddr(bp);
diff --git a/drivers/net/macb.h b/drivers/net/macb.h
index bc2e2c0..cd63c1b 100644
--- a/drivers/net/macb.h
+++ b/drivers/net/macb.h
@@ -134,6 +134,9 @@
 /* GEM specific NCFGR bitfields. */
 #define GEM_CLK_OFFSET				18
 #define GEM_CLK_SIZE				3
+#define GEM_DBW_OFFSET				21
+#define GEM_DBW_SIZE				2
+
 /* Bitfields in NSR */
 #define MACB_NSR_LINK_OFFSET			0
 #define MACB_NSR_LINK_SIZE			1
diff --git a/include/linux/platform_data/macb.h b/include/linux/platform_data/macb.h
index ae18579..d11bfab 100644
--- a/include/linux/platform_data/macb.h
+++ b/include/linux/platform_data/macb.h
@@ -1,11 +1,17 @@
 #ifndef __MACB_PDATA_H__
 #define __MACB_PDATA_H__
 
+/* Constants for data bus width. */
+#define MACB_DBW32				0
+#define MACB_DBW64				1
+#define MACB_DBW128				2
+
 struct eth_platform_data {
 	u32		phy_mask;
 	u8		phy_irq_pin;	/* PHY IRQ */
 	u8		is_rmii;	/* using RMII interface? */
 	int		have_hclk;	/* have hclk as well as pclk */
+	u8		dbw;		/* Data bus width. */
 };
 
 #endif /* __MACB_PDATA_H__ */
-- 
1.7.4

