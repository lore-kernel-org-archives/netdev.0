From: Jamie Iles <jamie@jamieiles.com>
Subject: [PATCHv4 6/9] macb: support higher rate GEM MDIO clock divisors
Date: Tue,  8 Nov 2011 14:13:30 +0000
Message-ID: <1320761613-18641-7-git-send-email-jamie@jamieiles.com>
References: <1320761613-18641-1-git-send-email-jamie@jamieiles.com>
Cc: arnd@arndb.de, Jamie Iles <jamie@jamieiles.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:41484 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932377Ab1KHON4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Nov 2011 09:13:56 -0500
Received: by wwi36 with SMTP id 36so805441wwi.1
        for <netdev@vger.kernel.org>; Tue, 08 Nov 2011 06:13:55 -0800 (PST)
In-Reply-To: <1320761613-18641-1-git-send-email-jamie@jamieiles.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

GEM devices support larger clock divisors and have a different
range of divisors.  Program the MDIO clock divisors based on the
device type.

Signed-off-by: Jamie Iles <jamie@jamieiles.com>
Acked-by: David S. Miller <davem@davemloft.net>
Acked-by: Nicolas Ferre <nicolas.ferre@atmel.com>
---
 drivers/net/ethernet/cadence/macb.c |   55 ++++++++++++++++++++++++++++-------
 drivers/net/ethernet/cadence/macb.h |   11 +++++++
 2 files changed, 55 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index a7c3162..1600466 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -794,6 +794,48 @@ static void macb_reset_hw(struct macb *bp)
 	macb_readl(bp, ISR);
 }
 
+static u32 gem_mdc_clk_div(struct macb *bp)
+{
+	u32 config;
+	unsigned long pclk_hz = clk_get_rate(bp->pclk);
+
+	if (pclk_hz <= 20000000)
+		config = GEM_BF(CLK, GEM_CLK_DIV8);
+	else if (pclk_hz <= 40000000)
+		config = GEM_BF(CLK, GEM_CLK_DIV16);
+	else if (pclk_hz <= 80000000)
+		config = GEM_BF(CLK, GEM_CLK_DIV32);
+	else if (pclk_hz <= 120000000)
+		config = GEM_BF(CLK, GEM_CLK_DIV48);
+	else if (pclk_hz <= 160000000)
+		config = GEM_BF(CLK, GEM_CLK_DIV64);
+	else
+		config = GEM_BF(CLK, GEM_CLK_DIV96);
+
+	return config;
+}
+
+static u32 macb_mdc_clk_div(struct macb *bp)
+{
+	u32 config;
+	unsigned long pclk_hz;
+
+	if (macb_is_gem(bp))
+		return gem_mdc_clk_div(bp);
+
+	pclk_hz = clk_get_rate(bp->pclk);
+	if (pclk_hz <= 20000000)
+		config = MACB_BF(CLK, MACB_CLK_DIV8);
+	else if (pclk_hz <= 40000000)
+		config = MACB_BF(CLK, MACB_CLK_DIV16);
+	else if (pclk_hz <= 80000000)
+		config = MACB_BF(CLK, MACB_CLK_DIV32);
+	else
+		config = MACB_BF(CLK, MACB_CLK_DIV64);
+
+	return config;
+}
+
 static void macb_init_hw(struct macb *bp)
 {
 	u32 config;
@@ -801,7 +843,7 @@ static void macb_init_hw(struct macb *bp)
 	macb_reset_hw(bp);
 	__macb_set_hwaddr(bp);
 
-	config = macb_readl(bp, NCFGR) & MACB_BF(CLK, -1L);
+	config = macb_mdc_clk_div(bp);
 	config |= MACB_BIT(PAE);		/* PAuse Enable */
 	config |= MACB_BIT(DRFCS);		/* Discard Rx FCS */
 	config |= MACB_BIT(BIG);		/* Receive oversized frames */
@@ -1120,7 +1162,6 @@ static int __init macb_probe(struct platform_device *pdev)
 	struct net_device *dev;
 	struct macb *bp;
 	struct phy_device *phydev;
-	unsigned long pclk_hz;
 	u32 config;
 	int err = -ENXIO;
 
@@ -1184,15 +1225,7 @@ static int __init macb_probe(struct platform_device *pdev)
 	dev->base_addr = regs->start;
 
 	/* Set MII management clock divider */
-	pclk_hz = clk_get_rate(bp->pclk);
-	if (pclk_hz <= 20000000)
-		config = MACB_BF(CLK, MACB_CLK_DIV8);
-	else if (pclk_hz <= 40000000)
-		config = MACB_BF(CLK, MACB_CLK_DIV16);
-	else if (pclk_hz <= 80000000)
-		config = MACB_BF(CLK, MACB_CLK_DIV32);
-	else
-		config = MACB_BF(CLK, MACB_CLK_DIV64);
+	config = macb_mdc_clk_div(bp);
 	macb_writel(bp, NCFGR, config);
 
 	macb_get_hwaddr(bp);
diff --git a/drivers/net/ethernet/cadence/macb.h b/drivers/net/ethernet/cadence/macb.h
index d50057c..354ed8f 100644
--- a/drivers/net/ethernet/cadence/macb.h
+++ b/drivers/net/ethernet/cadence/macb.h
@@ -135,6 +135,9 @@
 #define MACB_IRXFCS_OFFSET			19
 #define MACB_IRXFCS_SIZE			1
 
+/* GEM specific NCFGR bitfields. */
+#define GEM_CLK_OFFSET				18
+#define GEM_CLK_SIZE				3
 /* Bitfields in NSR */
 #define MACB_NSR_LINK_OFFSET			0
 #define MACB_NSR_LINK_SIZE			1
@@ -249,6 +252,14 @@
 #define MACB_CLK_DIV32				2
 #define MACB_CLK_DIV64				3
 
+/* GEM specific constants for CLK. */
+#define GEM_CLK_DIV8				0
+#define GEM_CLK_DIV16				1
+#define GEM_CLK_DIV32				2
+#define GEM_CLK_DIV48				3
+#define GEM_CLK_DIV64				4
+#define GEM_CLK_DIV96				5
+
 /* Constants for MAN register */
 #define MACB_MAN_SOF				1
 #define MACB_MAN_WRITE				1
-- 
1.7.4.1
