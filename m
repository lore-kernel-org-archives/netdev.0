From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH RFT v2 2/2] macb: kill PHY reset code
Date: Fri, 29 Apr 2016 01:15:24 +0300
Message-ID: <2024144.Eda96jDyaz@wasted.cogentembedded.com>
References: <19240252.825Vlx6L0H@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org, nicolas.ferre@atmel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <19240252.825Vlx6L0H@wasted.cogentembedded.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

With  the 'phylib' now  being aware of  the "reset-gpios" PHY node property,
there should be no need to frob the PHY reset in this  driver anymore...

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
 drivers/net/ethernet/cadence/macb.c |   17 -----------------
 drivers/net/ethernet/cadence/macb.h |    1 -
 2 files changed, 18 deletions(-)

Index: net-next/drivers/net/ethernet/cadence/macb.c
===================================================================
--- net-next.orig/drivers/net/ethernet/cadence/macb.c
+++ net-next/drivers/net/ethernet/cadence/macb.c
@@ -2884,7 +2884,6 @@ static int macb_probe(struct platform_de
 					      = macb_clk_init;
 	int (*init)(struct platform_device *) = macb_init;
 	struct device_node *np = pdev->dev.of_node;
-	struct device_node *phy_node;
 	const struct macb_config *macb_config = NULL;
 	struct clk *pclk, *hclk = NULL, *tx_clk = NULL;
 	unsigned int queue_mask, num_queues;
@@ -2977,18 +2976,6 @@ static int macb_probe(struct platform_de
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
@@ -3054,10 +3041,6 @@ static int macb_remove(struct platform_d
 		mdiobus_unregister(bp->mii_bus);
 		mdiobus_free(bp->mii_bus);
 
-		/* Shutdown the PHY if there is a GPIO reset */
-		if (bp->reset_gpio)
-			gpiod_set_value(bp->reset_gpio, 0);
-
 		unregister_netdev(dev);
 		clk_disable_unprepare(bp->tx_clk);
 		clk_disable_unprepare(bp->hclk);
Index: net-next/drivers/net/ethernet/cadence/macb.h
===================================================================
--- net-next.orig/drivers/net/ethernet/cadence/macb.h
+++ net-next/drivers/net/ethernet/cadence/macb.h
@@ -832,7 +832,6 @@ struct macb {
 	unsigned int		dma_burst_length;
 
 	phy_interface_t		phy_interface;
-	struct gpio_desc	*reset_gpio;
 
 	/* AT91RM9200 transmit */
 	struct sk_buff *skb;			/* holds skb until xmit interrupt completes */
