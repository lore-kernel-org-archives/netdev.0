From: Jamie Iles <jamie@jamieiles.com>
Subject: [PATCHv4 8/9] macb: support DMA bus widths > 32 bits
Date: Tue,  8 Nov 2011 14:13:32 +0000
Message-ID: <1320761613-18641-9-git-send-email-jamie@jamieiles.com>
References: <1320761613-18641-1-git-send-email-jamie@jamieiles.com>
Cc: arnd@arndb.de, Jamie Iles <jamie@jamieiles.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:37644 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932544Ab1KHOOC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Nov 2011 09:14:02 -0500
Received: by eye27 with SMTP id 27so372674eye.19
        for <netdev@vger.kernel.org>; Tue, 08 Nov 2011 06:14:00 -0800 (PST)
In-Reply-To: <1320761613-18641-1-git-send-email-jamie@jamieiles.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some GEM implementations may support DMA bus widths up to 128 bits.  We
can get the maximum supported DMA bus width from the design
configuration register so use that to program the device up.

Signed-off-by: Jamie Iles <jamie@jamieiles.com>
Acked-by: David S. Miller <davem@davemloft.net>
Acked-by: Nicolas Ferre <nicolas.ferre@atmel.com>
---
 drivers/net/ethernet/cadence/macb.c |   23 +++++++++++++++++++++++
 drivers/net/ethernet/cadence/macb.h |   19 +++++++++++++++++++
 2 files changed, 42 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index ecfe98a..3194af2 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -836,6 +836,27 @@ static u32 macb_mdc_clk_div(struct macb *bp)
 	return config;
 }
 
+/*
+ * Get the DMA bus width field of the network configuration register that we
+ * should program.  We find the width from decoding the design configuration
+ * register to find the maximum supported data bus width.
+ */
+static u32 macb_dbw(struct macb *bp)
+{
+	if (!macb_is_gem(bp))
+		return 0;
+
+	switch (GEM_BFEXT(DBWDEF, gem_readl(bp, DCFG1))) {
+	case 4:
+		return GEM_BF(DBW, GEM_DBW128);
+	case 2:
+		return GEM_BF(DBW, GEM_DBW64);
+	case 1:
+	default:
+		return GEM_BF(DBW, GEM_DBW32);
+	}
+}
+
 static void macb_init_hw(struct macb *bp)
 {
 	u32 config;
@@ -851,6 +872,7 @@ static void macb_init_hw(struct macb *bp)
 		config |= MACB_BIT(CAF);	/* Copy All Frames */
 	if (!(bp->dev->flags & IFF_BROADCAST))
 		config |= MACB_BIT(NBC);	/* No BroadCast */
+	config |= macb_dbw(bp);
 	macb_writel(bp, NCFGR, config);
 
 	/* Initialize TX and RX buffers */
@@ -1277,6 +1299,7 @@ static int __init macb_probe(struct platform_device *pdev)
 
 	/* Set MII management clock divider */
 	config = macb_mdc_clk_div(bp);
+	config |= macb_dbw(bp);
 	macb_writel(bp, NCFGR, config);
 
 	macb_get_hwaddr(bp);
diff --git a/drivers/net/ethernet/cadence/macb.h b/drivers/net/ethernet/cadence/macb.h
index 1367b92..71424aa 100644
--- a/drivers/net/ethernet/cadence/macb.h
+++ b/drivers/net/ethernet/cadence/macb.h
@@ -69,6 +69,13 @@
 #define GEM_SA1B				0x0088
 #define GEM_SA1T				0x008C
 #define GEM_OTX					0x0100
+#define GEM_DCFG1				0x0280
+#define GEM_DCFG2				0x0284
+#define GEM_DCFG3				0x0288
+#define GEM_DCFG4				0x028c
+#define GEM_DCFG5				0x0290
+#define GEM_DCFG6				0x0294
+#define GEM_DCFG7				0x0298
 
 /* Bitfields in NCR */
 #define MACB_LB_OFFSET				0
@@ -139,6 +146,14 @@
 /* GEM specific NCFGR bitfields. */
 #define GEM_CLK_OFFSET				18
 #define GEM_CLK_SIZE				3
+#define GEM_DBW_OFFSET				21
+#define GEM_DBW_SIZE				2
+
+/* Constants for data bus width. */
+#define GEM_DBW32				0
+#define GEM_DBW64				1
+#define GEM_DBW128				2
+
 /* Bitfields in NSR */
 #define MACB_NSR_LINK_OFFSET			0
 #define MACB_NSR_LINK_SIZE			1
@@ -247,6 +262,10 @@
 #define MACB_REV_OFFSET				0
 #define MACB_REV_SIZE				16
 
+/* Bitfields in DCFG1. */
+#define GEM_DBWDEF_OFFSET			25
+#define GEM_DBWDEF_SIZE				3
+
 /* Constants for CLK */
 #define MACB_CLK_DIV8				0
 #define MACB_CLK_DIV16				1
-- 
1.7.4.1
