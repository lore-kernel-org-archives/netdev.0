From: Boris Brezillon <boris.brezillon@free-electrons.com>
Subject: [PATCH v2 3/3] net: macb: remove #if defined(CONFIG_ARCH_AT91) sections
Date: Fri,  6 Mar 2015 11:24:02 +0100
Message-ID: <1425637442-8724-4-git-send-email-boris.brezillon@free-electrons.com>
References: <1425637442-8724-1-git-send-email-boris.brezillon@free-electrons.com>
Cc: Nicolas Ferre <nicolas.ferre@atmel.com>,
	Jean-Christophe Plagniol-Villard <plagnioj@jcrosoft.com>,
	Alexandre Belloni <alexandre.belloni@free-electrons.com>,
	Rob Herring <robh+dt@kernel.org>,
	Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Kumar Gala <galak@codeaurora.org>, devicetree@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	Boris Brezillon <boris.brezillon@free-electrons.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from down.free-electrons.com ([37.187.137.238]:36269 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932705AbbCFKYJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Mar 2015 05:24:09 -0500
In-Reply-To: <1425637442-8724-1-git-send-email-boris.brezillon@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With multi platform support those sections could lead to unexpected
behavior if both ARCH_AT91 and another ARM SoC using the MACB IP are
selected.
Add two new capabilities to encode the default MII mode and the presence
of a CLKEN bit in USRIO register.
Then define the appropriate config for IPs embedded in at91 SoCs.

Signed-off-by: Boris Brezillon <boris.brezillon@free-electrons.com>
Reviewed-by: Alexandre Belloni <alexandre.belloni@free-electrons.com>
---
 drivers/net/ethernet/cadence/macb.c | 32 +++++++++++++++++---------------
 drivers/net/ethernet/cadence/macb.h |  2 ++
 2 files changed, 19 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index ad76b8e..86e915f 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -2113,6 +2113,10 @@ static const struct net_device_ops macb_netdev_ops = {
 };
 
 #if defined(CONFIG_OF)
+static struct macb_config at91sam9260_config = {
+	.caps = MACB_CAPS_USRIO_HAS_CLKEN | MACB_CAPS_USRIO_DEFAULT_IS_MII,
+};
+
 static struct macb_config pc302gem_config = {
 	.caps = MACB_CAPS_SG_DISABLED | MACB_CAPS_GIGABIT_MODE_AVAILABLE,
 	.dma_burst_length = 16,
@@ -2130,7 +2134,7 @@ static struct macb_config sama5d4_config = {
 
 static const struct of_device_id macb_dt_ids[] = {
 	{ .compatible = "cdns,at32ap7000-macb" },
-	{ .compatible = "cdns,at91sam9260-macb" },
+	{ .compatible = "cdns,at91sam9260-macb", .data = &at91sam9260_config },
 	{ .compatible = "cdns,macb" },
 	{ .compatible = "cdns,pc302-gem", .data = &pc302gem_config },
 	{ .compatible = "cdns,gem", .data = &pc302gem_config },
@@ -2388,21 +2392,19 @@ static int macb_probe(struct platform_device *pdev)
 		bp->phy_interface = err;
 	}
 
+	config = 0;
 	if (bp->phy_interface == PHY_INTERFACE_MODE_RGMII)
-		macb_or_gem_writel(bp, USRIO, GEM_BIT(RGMII));
-	else if (bp->phy_interface == PHY_INTERFACE_MODE_RMII)
-#if defined(CONFIG_ARCH_AT91)
-		macb_or_gem_writel(bp, USRIO, (MACB_BIT(RMII) |
-					       MACB_BIT(CLKEN)));
-#else
-		macb_or_gem_writel(bp, USRIO, 0);
-#endif
-	else
-#if defined(CONFIG_ARCH_AT91)
-		macb_or_gem_writel(bp, USRIO, MACB_BIT(CLKEN));
-#else
-		macb_or_gem_writel(bp, USRIO, MACB_BIT(MII));
-#endif
+		config = GEM_BIT(RGMII);
+	else if (bp->phy_interface == PHY_INTERFACE_MODE_RMII &&
+		 (bp->caps & MACB_CAPS_USRIO_DEFAULT_IS_MII))
+		config = MACB_BIT(RMII);
+	else if (!(bp->caps & MACB_CAPS_USRIO_DEFAULT_IS_MII))
+		config = MACB_BIT(MII);
+
+	if (bp->caps & MACB_CAPS_USRIO_HAS_CLKEN)
+		config |= MACB_BIT(CLKEN);
+
+	macb_or_gem_writel(bp, USRIO, config);
 
 	err = register_netdev(dev);
 	if (err) {
diff --git a/drivers/net/ethernet/cadence/macb.h b/drivers/net/ethernet/cadence/macb.h
index 31dc080..efe0247 100644
--- a/drivers/net/ethernet/cadence/macb.h
+++ b/drivers/net/ethernet/cadence/macb.h
@@ -389,6 +389,8 @@
 
 /* Capability mask bits */
 #define MACB_CAPS_ISR_CLEAR_ON_WRITE		0x00000001
+#define MACB_CAPS_USRIO_HAS_CLKEN		0x00000002
+#define MACB_CAPS_USRIO_DEFAULT_IS_MII		0x00000004
 #define MACB_CAPS_FIFO_MODE			0x10000000
 #define MACB_CAPS_GIGABIT_MODE_AVAILABLE	0x20000000
 #define MACB_CAPS_SG_DISABLED			0x40000000
-- 
1.9.1
