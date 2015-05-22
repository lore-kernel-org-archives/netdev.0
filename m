From: Nathan Sullivan <nathan.sullivan@ni.com>
Subject: [PATCH v2 2/3] net: macb: Disable half duplex gigabit on Zynq
Date: Fri, 22 May 2015 09:22:10 -0500
Message-ID: <1432304531-23682-2-git-send-email-nathan.sullivan@ni.com>
References: <1432304531-23682-1-git-send-email-nathan.sullivan@ni.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Nathan Sullivan <nathan.sullivan@ni.com>
To: nicolas.ferre@atmel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1432304531-23682-1-git-send-email-nathan.sullivan@ni.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

According to the Zynq TRM, gigabit half duplex is not supported.  Add a
new cap and compatible string so Zynq can avoid advertising that mode.

Signed-off-by: Nathan Sullivan <nathan.sullivan@ni.com>
---
 drivers/net/ethernet/cadence/macb.c |   12 ++++++++++++
 drivers/net/ethernet/cadence/macb.h |    1 +
 2 files changed, 13 insertions(+)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 61aa570..e7c0ef6 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -350,6 +350,9 @@ static int macb_mii_probe(struct net_device *dev)
 	else
 		phydev->supported &= PHY_BASIC_FEATURES;
 
+	if (bp->caps & MACB_CAPS_NO_GIGABIT_HALF)
+		phydev->supported &= ~SUPPORTED_1000baseT_Half;
+
 	phydev->advertising = phydev->supported;
 
 	bp->link = 0;
@@ -2693,6 +2696,14 @@ static const struct macb_config emac_config = {
 	.init = at91ether_init,
 };
 
+static const struct macb_config zynq_config = {
+	.caps = MACB_CAPS_SG_DISABLED | MACB_CAPS_GIGABIT_MODE_AVAILABLE |
+		MACB_CAPS_NO_GIGABIT_HALF,
+	.dma_burst_length = 16,
+	.clk_init = macb_clk_init,
+	.init = macb_init,
+};
+
 static const struct of_device_id macb_dt_ids[] = {
 	{ .compatible = "cdns,at32ap7000-macb" },
 	{ .compatible = "cdns,at91sam9260-macb", .data = &at91sam9260_config },
@@ -2703,6 +2714,7 @@ static const struct of_device_id macb_dt_ids[] = {
 	{ .compatible = "atmel,sama5d4-gem", .data = &sama5d4_config },
 	{ .compatible = "cdns,at91rm9200-emac", .data = &emac_config },
 	{ .compatible = "cdns,emac", .data = &emac_config },
+	{ .compatible = "cdns,zynq-gem", .data = &zynq_config },
 	{ /* sentinel */ }
 };
 MODULE_DEVICE_TABLE(of, macb_dt_ids);
diff --git a/drivers/net/ethernet/cadence/macb.h b/drivers/net/ethernet/cadence/macb.h
index eb7d76f..24b1d9b 100644
--- a/drivers/net/ethernet/cadence/macb.h
+++ b/drivers/net/ethernet/cadence/macb.h
@@ -393,6 +393,7 @@
 #define MACB_CAPS_ISR_CLEAR_ON_WRITE		0x00000001
 #define MACB_CAPS_USRIO_HAS_CLKEN		0x00000002
 #define MACB_CAPS_USRIO_DEFAULT_IS_MII		0x00000004
+#define MACB_CAPS_NO_GIGABIT_HALF		0x00000008
 #define MACB_CAPS_FIFO_MODE			0x10000000
 #define MACB_CAPS_GIGABIT_MODE_AVAILABLE	0x20000000
 #define MACB_CAPS_SG_DISABLED			0x40000000
-- 
1.7.10.4
