From: Boris Brezillon <boris.brezillon-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Subject: [PATCH 3/3] net: macb: remove #if defined(CONFIG_ARCH_AT91) sections
Date: Thu,  5 Mar 2015 17:27:22 +0100
Message-ID: <1425572842-6084-4-git-send-email-boris.brezillon@free-electrons.com>
References: <1425572842-6084-1-git-send-email-boris.brezillon@free-electrons.com>
Cc: Nicolas Ferre <nicolas.ferre-AIFe0yeh4nAAvxtiuMwx3w@public.gmane.org>,
	Jean-Christophe Plagniol-Villard <plagnioj-sclMFOaUSTBWk0Htik3J/w@public.gmane.org>,
	Alexandre Belloni <alexandre.belloni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
	Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Pawel Moll <pawel.moll-5wv7dgnIgG8@public.gmane.org>,
	Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
	Ian Campbell <ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>,
	Kumar Gala <galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	Boris Brezillon <boris.brezillon-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1425572842-6084-1-git-send-email-boris.brezillon-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

With multi platform support those sections could lead to unexpected
behavior if both ARCH_AT91 and another ARM SoC using the MACB IP are
selected.
Add two new capabilities to encode the default MII mode and the presence
of a CLKEN bit in USRIO register.
Then define the appropriate config for IPs embedded in at91 SoCs.

Signed-off-by: Boris Brezillon <boris.brezillon-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
---
 drivers/net/ethernet/cadence/macb.c | 33 ++++++++++++++++++---------------
 drivers/net/ethernet/cadence/macb.h |  2 ++
 2 files changed, 20 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index ad76b8e..a7dbf04 100644
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
@@ -2388,21 +2392,20 @@ static int macb_probe(struct platform_device *pdev)
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
+	else if (bp->phy_interface == PHY_INTERFACE_MODE_MII &&
+		 !(bp->caps & MACB_CAPS_USRIO_DEFAULT_IS_MII))
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

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
