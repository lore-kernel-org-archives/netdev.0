From: Jamie Iles <jamie@jamieiles.com>
Subject: [PATCH 6/8] macb: support higher rate GEM MDIO clock divisors
Date: Thu, 10 Mar 2011 10:10:41 +0000
Message-ID: <1299751843-9743-7-git-send-email-jamie@jamieiles.com>
References: <1299751843-9743-1-git-send-email-jamie@jamieiles.com>
Cc: nicolas.ferre@atmel.com, Jamie Iles <jamie@jamieiles.com>
To: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:42407 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751705Ab1CJKLC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Mar 2011 05:11:02 -0500
Received: by mail-ww0-f44.google.com with SMTP id 36so1752924wwa.1
        for <netdev@vger.kernel.org>; Thu, 10 Mar 2011 02:11:01 -0800 (PST)
In-Reply-To: <1299751843-9743-1-git-send-email-jamie@jamieiles.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

GEM devices support larger clock divisors and have a different
range of divisors.  Program the MDIO clock divisors based on the
device type.

Signed-off-by: Jamie Iles <jamie@jamieiles.com>
---
 drivers/net/macb.c |   49 ++++++++++++++++++++++++++++++++++++++++---------
 drivers/net/macb.h |   11 +++++++++++
 2 files changed, 51 insertions(+), 9 deletions(-)

diff --git a/drivers/net/macb.c b/drivers/net/macb.c
index 2541e3b..dbc6e7ea 100644
--- a/drivers/net/macb.c
+++ b/drivers/net/macb.c
@@ -801,7 +801,8 @@ static void macb_init_hw(struct macb *bp)
 	macb_reset_hw(bp);
 	__macb_set_hwaddr(bp);
 
-	config = macb_readl(bp, NCFGR) & MACB_BF(CLK, -1L);
+	config = bp->is_gem ? macb_readl(bp, NCFGR) & GEM_BF(CLK, -1L) :
+		macb_readl(bp, NCFGR) & MACB_BF(CLK, -1L);
 	config |= MACB_BIT(PAE);		/* PAuse Enable */
 	config |= MACB_BIT(DRFCS);		/* Discard Rx FCS */
 	config |= MACB_BIT(BIG);		/* Receive oversized frames */
@@ -1118,6 +1119,42 @@ static const struct net_device_ops macb_netdev_ops = {
 #define PCLK_NAME	"pclk"
 #endif
 
+static u32 macb_mdc_clk_div(unsigned long pclk_hz)
+{
+	u32 config;
+
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
+static u32 gem_mdc_clk_div(unsigned long pclk_hz)
+{
+	u32 config;
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
 static int __macb_probe(struct platform_device *pdev, int is_gem)
 {
 	struct resource *regs;
@@ -1202,14 +1239,8 @@ static int __macb_probe(struct platform_device *pdev, int is_gem)
 
 	/* Set MII management clock divider */
 	pclk_hz = clk_get_rate(bp->pclk);
-	if (pclk_hz <= 20000000)
-		config = MACB_BF(CLK, MACB_CLK_DIV8);
-	else if (pclk_hz <= 40000000)
-		config = MACB_BF(CLK, MACB_CLK_DIV16);
-	else if (pclk_hz <= 80000000)
-		config = MACB_BF(CLK, MACB_CLK_DIV32);
-	else
-		config = MACB_BF(CLK, MACB_CLK_DIV64);
+	config = bp->is_gem ? gem_mdc_clk_div(pclk_hz) :
+		macb_mdc_clk_div(pclk_hz);
 	macb_writel(bp, NCFGR, config);
 
 	macb_get_hwaddr(bp);
diff --git a/drivers/net/macb.h b/drivers/net/macb.h
index 6248af6..4cd1e41 100644
--- a/drivers/net/macb.h
+++ b/drivers/net/macb.h
@@ -130,6 +130,9 @@
 #define MACB_IRXFCS_OFFSET			19
 #define MACB_IRXFCS_SIZE			1
 
+/* GEM specific NCFGR bitfields. */
+#define GEM_CLK_OFFSET				18
+#define GEM_CLK_SIZE				3
 /* Bitfields in NSR */
 #define MACB_NSR_LINK_OFFSET			0
 #define MACB_NSR_LINK_SIZE			1
@@ -238,6 +241,14 @@
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

