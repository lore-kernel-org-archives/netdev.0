From: Neil Armstrong <narmstrong@baylibre.com>
Subject: [PATCH v2 net-next 2/3] net: ethernet: cadence-macb: Add fallback to read DT provided caps
Date: Tue,  8 Dec 2015 14:52:05 +0100
Message-ID: <1449582726-6148-3-git-send-email-narmstrong@baylibre.com>
References: <1449485914-12883-1-git-send-email-narmstrong@baylibre.com>
 <1449582726-6148-1-git-send-email-narmstrong@baylibre.com>
Cc: Neil Armstrong <narmstrong@baylibre.com>
To: nicolas.ferre@atmel.com, davem@davemloft.net,
	harini.katakam@xilinx.com, boris.brezillon@free-electrons.com,
	alexandre.belloni@free-electrons.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, devicetree@vger.kernel.org, joshc@ni.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1449582726-6148-1-git-send-email-narmstrong@baylibre.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add 1:1 mapping of software defines caps parsing from DT in case the
generic macb compatible form is used.
These properties will provide support for futures implementations
only defined from DT without need to update the driver code to support
new variants.

Signed-off-by: Neil Armstrong <narmstrong@baylibre.com>
---
 drivers/net/ethernet/cadence/macb.c | 45 +++++++++++++++++++++++++++++++++++++
 1 file changed, 45 insertions(+)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 9325140..28a9a8b 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -2795,6 +2795,48 @@ static const struct macb_config zynq_config = {
 	.init = macb_init,
 };
 
+static const struct macb_config *macb_parse_dt_caps(struct device *dev)
+{
+	struct device_node *np = dev->of_node;
+	struct macb_config *macb_config;
+	u32 val;
+
+	macb_config = devm_kzalloc(dev, sizeof(*macb_config), GFP_KERNEL);
+	if (!macb_config)
+		return NULL;
+
+	if (of_property_read_bool(np, "cdns,usrio-has-clken"))
+		macb_config->caps |= MACB_CAPS_USRIO_HAS_CLKEN;
+
+	if (of_property_read_bool(np, "cdns,usrio-default-mii"))
+		macb_config->caps |= MACB_CAPS_USRIO_DEFAULT_IS_MII;
+
+	if (of_property_read_bool(np, "cdns,no-gigabit-half"))
+		macb_config->caps |= MACB_CAPS_NO_GIGABIT_HALF;
+
+	if (of_property_read_bool(np, "cdns,usrio-disabled"))
+		macb_config->caps |= MACB_CAPS_USRIO_DISABLED;
+
+	if (of_property_read_bool(np, "cdns,gem-sg-disabled"))
+		macb_config->caps |= MACB_CAPS_SG_DISABLED;
+
+	if (of_property_read_bool(np, "cdns,gem-has-gigabit"))
+		macb_config->caps |= MACB_CAPS_GIGABIT_MODE_AVAILABLE;
+
+	if (of_property_read_bool(np, "cdns,usrio-disabled"))
+		macb_config->caps |= MACB_CAPS_USRIO_DISABLED;
+
+	if (!of_property_read_u32(np, "cdns,dma-burst-length", &val))
+		macb_config->dma_burst_length = val;
+
+	if (!of_property_read_u32(np, "cdns,jumbo-max-length", &val)) {
+		macb_config->jumbo_max_len = val;
+		macb_config->caps |= MACB_CAPS_JUMBO;
+	}
+
+	return macb_config;
+}
+
 static const struct of_device_id macb_dt_ids[] = {
 	{ .compatible = "cdns,at32ap7000-macb" },
 	{ .compatible = "cdns,at91sam9260-macb", .data = &at91sam9260_config },
@@ -2847,6 +2889,9 @@ static int macb_probe(struct platform_device *pdev)
 			clk_init = macb_config->clk_init;
 			init = macb_config->init;
 		}
+
+		if (!macb_config)
+			macb_config = macb_parse_dt_caps(&pdev->dev);
 	}
 
 	err = clk_init(pdev, &pclk, &hclk, &tx_clk);
-- 
1.9.1
