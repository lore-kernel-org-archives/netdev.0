From: Geert Uytterhoeven <geert+renesas@glider.be>
Subject: [PATCH v3 2/4] macb: Kill PHY reset code
Date: Fri, 20 Oct 2017 10:14:19 +0200
Message-ID: <1508487261-18524-3-git-send-email-geert+renesas@glider.be>
References: <1508487261-18524-1-git-send-email-geert+renesas@glider.be>
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        Nicolas Ferre <nicolas.ferre@microchip.com>,
        netdev@vger.kernel.org, devicetree@vger.kernel.org,
        linux-renesas-soc@vger.kernel.org, linux-kernel@vger.kernel.org,
        Geert Uytterhoeven <geert+renesas@glider.be>
To: "David S . Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Simon Horman <horms@verge.net.au>,
        Magnus Damm <magnus.damm@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1508487261-18524-1-git-send-email-geert+renesas@glider.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

With the phylib now being aware of the "reset-gpios" PHY node property,
there should be no need to frob the PHY reset in this driver anymore...

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Acked-by: Nicolas Ferre <nicolas.ferre@atmel.com>
Signed-off-by: Geert Uytterhoeven <geert+renesas@glider.be>
---
v3:
  - Resolve rejects due to the file being renamed, refresh the patch,
  - Added code to reset PHY on probe error,
  - Edit patch description,
  - Take over from Sergei,
  - Add Acked-by,

v2:
  - No changes.
---
 drivers/net/ethernet/cadence/macb.h      |  1 -
 drivers/net/ethernet/cadence/macb_main.c | 21 ---------------------
 2 files changed, 22 deletions(-)

diff --git a/drivers/net/ethernet/cadence/macb.h b/drivers/net/ethernet/cadence/macb.h
index c93f3a2dc6c1a318..146cb24ebf4461bf 100644
--- a/drivers/net/ethernet/cadence/macb.h
+++ b/drivers/net/ethernet/cadence/macb.h
@@ -1032,7 +1032,6 @@ struct macb {
 	unsigned int		dma_burst_length;
 
 	phy_interface_t		phy_interface;
-	struct gpio_desc	*reset_gpio;
 
 	/* AT91RM9200 transmit */
 	struct sk_buff *skb;			/* holds skb until xmit interrupt completes */
diff --git a/drivers/net/ethernet/cadence/macb_main.c b/drivers/net/ethernet/cadence/macb_main.c
index 6df2cad61647a6d7..fc11c04be6837ff2 100644
--- a/drivers/net/ethernet/cadence/macb_main.c
+++ b/drivers/net/ethernet/cadence/macb_main.c
@@ -3393,7 +3393,6 @@ static int macb_probe(struct platform_device *pdev)
 					      = macb_config->clk_init;
 	int (*init)(struct platform_device *) = macb_config->init;
 	struct device_node *np = pdev->dev.of_node;
-	struct device_node *phy_node;
 	struct clk *pclk, *hclk = NULL, *tx_clk = NULL, *rx_clk = NULL;
 	unsigned int queue_mask, num_queues;
 	struct macb_platform_data *pdata;
@@ -3499,18 +3498,6 @@ static int macb_probe(struct platform_device *pdev)
 	else
 		macb_get_hwaddr(bp);
 
-	/* Power up the PHY if there is a GPIO reset */
-	phy_node =  of_get_next_available_child(np, NULL);
-	if (phy_node) {
-		int gpio = of_get_named_gpio(phy_node, "reset-gpios", 0);
-
-		if (gpio_is_valid(gpio)) {
-			bp->reset_gpio = gpio_to_desc(gpio);
-			gpiod_direction_output(bp->reset_gpio, 1);
-		}
-	}
-	of_node_put(phy_node);
-
 	err = of_get_phy_mode(np);
 	if (err < 0) {
 		pdata = dev_get_platdata(&pdev->dev);
@@ -3554,10 +3541,6 @@ static int macb_probe(struct platform_device *pdev)
 	mdiobus_unregister(bp->mii_bus);
 	mdiobus_free(bp->mii_bus);
 
-	/* Shutdown the PHY if there is a GPIO reset */
-	if (bp->reset_gpio)
-		gpiod_set_value(bp->reset_gpio, 0);
-
 err_out_free_netdev:
 	free_netdev(dev);
 
@@ -3585,10 +3568,6 @@ static int macb_remove(struct platform_device *pdev)
 		dev->phydev = NULL;
 		mdiobus_free(bp->mii_bus);
 
-		/* Shutdown the PHY if there is a GPIO reset */
-		if (bp->reset_gpio)
-			gpiod_set_value(bp->reset_gpio, 0);
-
 		unregister_netdev(dev);
 		clk_disable_unprepare(bp->tx_clk);
 		clk_disable_unprepare(bp->hclk);
-- 
2.7.4
