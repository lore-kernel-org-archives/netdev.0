From: Jamie Iles <jamie@jamieiles.com>
Subject: [PATCHv2 6/9] macb: support higher rate GEM MDIO clock divisors
Date: Tue, 15 Mar 2011 10:14:53 +0000
Message-ID: <1300184096-13937-7-git-send-email-jamie@jamieiles.com>
References: <1300184096-13937-1-git-send-email-jamie@jamieiles.com>
Cc: nicolas.ferre@atmel.com, plagnioj@jcrosoft.com,
	Jamie Iles <jamie@jamieiles.com>
To: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:35177 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756859Ab1COKP3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Mar 2011 06:15:29 -0400
Received: by mail-bw0-f46.google.com with SMTP id 15so389948bwz.19
        for <netdev@vger.kernel.org>; Tue, 15 Mar 2011 03:15:28 -0700 (PDT)
In-Reply-To: <1300184096-13937-1-git-send-email-jamie@jamieiles.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

GEM devices support larger clock divisors and have a different
range of divisors.  Program the MDIO clock divisors based on the
device type.

Signed-off-by: Jamie Iles <jamie@jamieiles.com>
---
 drivers/net/macb.c |   55 +++++++++++++++++++++++++++++++++++++++++----------
 drivers/net/macb.h |   11 ++++++++++
 2 files changed, 55 insertions(+), 11 deletions(-)

diff --git a/drivers/net/macb.c b/drivers/net/macb.c
index 9cd1d7e..f3da878 100644
--- a/drivers/net/macb.c
+++ b/drivers/net/macb.c
@@ -780,6 +780,48 @@ static void macb_reset_hw(struct macb *bp)
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
+	if (bp->is_gem)
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
@@ -787,7 +829,7 @@ static void macb_init_hw(struct macb *bp)
 	macb_reset_hw(bp);
 	__macb_set_hwaddr(bp);
 
-	config = macb_readl(bp, NCFGR) & MACB_BF(CLK, -1L);
+	config = macb_mdc_clk_div(bp);
 	config |= MACB_BIT(PAE);		/* PAuse Enable */
 	config |= MACB_BIT(DRFCS);		/* Discard Rx FCS */
 	config |= MACB_BIT(BIG);		/* Receive oversized frames */
@@ -1105,7 +1147,6 @@ static int __init macb_probe(struct platform_device *pdev)
 	struct net_device *dev;
 	struct macb *bp;
 	struct phy_device *phydev;
-	unsigned long pclk_hz;
 	u32 config;
 	int err = -ENXIO;
 
@@ -1174,15 +1215,7 @@ static int __init macb_probe(struct platform_device *pdev)
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
diff --git a/drivers/net/macb.h b/drivers/net/macb.h
index 3a07352..65abd8a 100644
--- a/drivers/net/macb.h
+++ b/drivers/net/macb.h
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
1.7.4

