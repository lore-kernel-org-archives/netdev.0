From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: [PATCH] at91_ether: use gpio_is_valid for phy IRQ line
Date: Thu, 24 Nov 2011 22:21:14 +0100
Message-ID: <1322169674-4109-1-git-send-email-nicolas.ferre@atmel.com>
References: <1322128098-17724-1-git-send-email-jamie@jamieiles.com>
Cc: plagnioj@jcrosoft.com, sfr@canb.auug.org.au,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	Nicolas Ferre <nicolas.ferre@atmel.com>
To: jamie@jamieiles.com, netdev@vger.kernel.org
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <1322128098-17724-1-git-send-email-jamie@jamieiles.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use the generic gpiolib gpio_is_valid() function to test
if the phy IRQ line GPIO is actually provided.

For non-connected or non-existing phy IRQ lines, -EINVAL
value is used for phy_irq_pin field of struct at91_eth_data.

Signed-off-by: Nicolas Ferre <nicolas.ferre@atmel.com>
---
 drivers/net/ethernet/cadence/at91_ether.c |   23 +++++++++++++----------
 1 files changed, 13 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/cadence/at91_ether.c b/drivers/net/ethernet/cadence/at91_ether.c
index 56624d3..a1c4143 100644
--- a/drivers/net/ethernet/cadence/at91_ether.c
+++ b/drivers/net/ethernet/cadence/at91_ether.c
@@ -255,8 +255,7 @@ static void enable_phyirq(struct net_device *dev)
 	unsigned int dsintr, irq_number;
 	int status;
 
-	irq_number = lp->board_data.phy_irq_pin;
-	if (!irq_number) {
+	if (!gpio_is_valid(lp->board_data.phy_irq_pin)) {
 		/*
 		 * PHY doesn't have an IRQ pin (RTL8201, DP83847, AC101L),
 		 * or board does not have it connected.
@@ -265,6 +264,7 @@ static void enable_phyirq(struct net_device *dev)
 		return;
 	}
 
+	irq_number = lp->board_data.phy_irq_pin;
 	status = request_irq(irq_number, at91ether_phy_interrupt, 0, dev->name, dev);
 	if (status) {
 		printk(KERN_ERR "at91_ether: PHY IRQ %d request failed - status %d!\n", irq_number, status);
@@ -319,8 +319,7 @@ static void disable_phyirq(struct net_device *dev)
 	unsigned int dsintr;
 	unsigned int irq_number;
 
-	irq_number = lp->board_data.phy_irq_pin;
-	if (!irq_number) {
+	if (!gpio_is_valid(lp->board_data.phy_irq_pin)) {
 		del_timer_sync(&lp->check_timer);
 		return;
 	}
@@ -365,6 +364,7 @@ static void disable_phyirq(struct net_device *dev)
 	disable_mdi();
 	spin_unlock_irq(&lp->lock);
 
+	irq_number = lp->board_data.phy_irq_pin;
 	free_irq(irq_number, dev);			/* Free interrupt handler */
 }
 
@@ -1077,7 +1077,7 @@ static int __init at91ether_setup(unsigned long phy_type, unsigned short phy_add
 	netif_carrier_off(dev);		/* will be enabled in open() */
 
 	/* If board has no PHY IRQ, use a timer to poll the PHY */
-	if (!lp->board_data.phy_irq_pin) {
+	if (!gpio_is_valid(lp->board_data.phy_irq_pin)) {
 		init_timer(&lp->check_timer);
 		lp->check_timer.data = (unsigned long)dev;
 		lp->check_timer.function = at91ether_check_link;
@@ -1169,7 +1169,8 @@ static int __devexit at91ether_remove(struct platform_device *pdev)
 	struct net_device *dev = platform_get_drvdata(pdev);
 	struct at91_private *lp = netdev_priv(dev);
 
-	if (lp->board_data.phy_irq_pin >= 32)
+	if (gpio_is_valid(lp->board_data.phy_irq_pin) &&
+	    lp->board_data.phy_irq_pin >= 32)
 		gpio_free(lp->board_data.phy_irq_pin);
 
 	unregister_netdev(dev);
@@ -1188,11 +1189,12 @@ static int at91ether_suspend(struct platform_device *pdev, pm_message_t mesg)
 {
 	struct net_device *net_dev = platform_get_drvdata(pdev);
 	struct at91_private *lp = netdev_priv(net_dev);
-	int phy_irq = lp->board_data.phy_irq_pin;
 
 	if (netif_running(net_dev)) {
-		if (phy_irq)
+		if (gpio_is_valid(lp->board_data.phy_irq_pin)) {
+			int phy_irq = lp->board_data.phy_irq_pin;
 			disable_irq(phy_irq);
+		}
 
 		netif_stop_queue(net_dev);
 		netif_device_detach(net_dev);
@@ -1206,7 +1208,6 @@ static int at91ether_resume(struct platform_device *pdev)
 {
 	struct net_device *net_dev = platform_get_drvdata(pdev);
 	struct at91_private *lp = netdev_priv(net_dev);
-	int phy_irq = lp->board_data.phy_irq_pin;
 
 	if (netif_running(net_dev)) {
 		clk_enable(lp->ether_clk);
@@ -1214,8 +1215,10 @@ static int at91ether_resume(struct platform_device *pdev)
 		netif_device_attach(net_dev);
 		netif_start_queue(net_dev);
 
-		if (phy_irq)
+		if (gpio_is_valid(lp->board_data.phy_irq_pin)) {
+			int phy_irq = lp->board_data.phy_irq_pin;
 			enable_irq(phy_irq);
+		}
 	}
 	return 0;
 }
-- 
1.7.5.4
