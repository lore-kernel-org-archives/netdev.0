From: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Subject: [PATCH v3 4/8] net: mvneta: Clean-up mvneta_init()
Date: Thu, 22 May 2014 20:06:59 -0300
Message-ID: <1400800023-1562-5-git-send-email-ezequiel.garcia@free-electrons.com>
References: <1400800023-1562-1-git-send-email-ezequiel.garcia@free-electrons.com>
Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Lior Amsalem <alior@marvell.com>,
	Tawfik Bayouk <tawfik@marvell.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
To: <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from top.free-electrons.com ([176.31.233.9]:49707 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753168AbaEVXIH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 May 2014 19:08:07 -0400
In-Reply-To: <1400800023-1562-1-git-send-email-ezequiel.garcia@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This commit cleans-up mvneta_init(), which initializes the hardware
and allocates the rx/qx queues. The queue allocation is simplified
by using devm_kcalloc instead of kzalloc. The unused phy_addr parameter
is removed. While here, the 'hal' references in the comments are removed.
This commit makes no functionality change.

Signed-off-by: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvneta.c | 36 +++++++++++------------------------
 1 file changed, 11 insertions(+), 25 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index d28327d..66e4631 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -2133,7 +2133,7 @@ static void mvneta_tx_reset(struct mvneta_port *pp)
 {
 	int queue;
 
-	/* free the skb's in the hal tx ring */
+	/* free the skb's in the tx ring */
 	for (queue = 0; queue < txq_number; queue++)
 		mvneta_txq_done_force(pp, &pp->txqs[queue]);
 
@@ -2788,7 +2788,7 @@ const struct ethtool_ops mvneta_eth_tool_ops = {
 };
 
 /* Initialize hw */
-static int mvneta_init(struct mvneta_port *pp, int phy_addr)
+static int mvneta_init(struct device *dev, struct mvneta_port *pp)
 {
 	int queue;
 
@@ -2798,8 +2798,8 @@ static int mvneta_init(struct mvneta_port *pp, int phy_addr)
 	/* Set port default values */
 	mvneta_defaults_set(pp);
 
-	pp->txqs = kzalloc(txq_number * sizeof(struct mvneta_tx_queue),
-			   GFP_KERNEL);
+	pp->txqs = devm_kcalloc(dev, txq_number, sizeof(struct mvneta_tx_queue),
+				GFP_KERNEL);
 	if (!pp->txqs)
 		return -ENOMEM;
 
@@ -2811,12 +2811,10 @@ static int mvneta_init(struct mvneta_port *pp, int phy_addr)
 		txq->done_pkts_coal = MVNETA_TXDONE_COAL_PKTS;
 	}
 
-	pp->rxqs = kzalloc(rxq_number * sizeof(struct mvneta_rx_queue),
-			   GFP_KERNEL);
-	if (!pp->rxqs) {
-		kfree(pp->txqs);
+	pp->rxqs = devm_kcalloc(dev, rxq_number, sizeof(struct mvneta_rx_queue),
+				GFP_KERNEL);
+	if (!pp->rxqs)
 		return -ENOMEM;
-	}
 
 	/* Create Rx descriptor rings */
 	for (queue = 0; queue < rxq_number; queue++) {
@@ -2830,12 +2828,6 @@ static int mvneta_init(struct mvneta_port *pp, int phy_addr)
 	return 0;
 }
 
-static void mvneta_deinit(struct mvneta_port *pp)
-{
-	kfree(pp->txqs);
-	kfree(pp->rxqs);
-}
-
 /* platform glue : initialize decoding windows */
 static void mvneta_conf_mbus_windows(struct mvneta_port *pp,
 				     const struct mbus_dram_target_info *dram)
@@ -2918,7 +2910,6 @@ static int mvneta_probe(struct platform_device *pdev)
 	struct resource *res;
 	struct device_node *dn = pdev->dev.of_node;
 	struct device_node *phy_node;
-	u32 phy_addr;
 	struct mvneta_port *pp;
 	struct net_device *dev;
 	const char *dt_mac_addr;
@@ -3027,16 +3018,14 @@ static int mvneta_probe(struct platform_device *pdev)
 	pp->dev = dev;
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
-	err = mvneta_init(pp, phy_addr);
-	if (err < 0) {
-		dev_err(&pdev->dev, "can't init eth hal\n");
+	err = mvneta_init(&pdev->dev, pp);
+	if (err < 0)
 		goto err_free_stats;
-	}
 
 	err = mvneta_port_power_up(pp, phy_mode);
 	if (err < 0) {
 		dev_err(&pdev->dev, "can't power up port\n");
-		goto err_deinit;
+		goto err_free_stats;
 	}
 
 	dram_target_info = mv_mbus_dram_info();
@@ -3053,7 +3042,7 @@ static int mvneta_probe(struct platform_device *pdev)
 	err = register_netdev(dev);
 	if (err < 0) {
 		dev_err(&pdev->dev, "failed to register\n");
-		goto err_deinit;
+		goto err_free_stats;
 	}
 
 	netdev_info(dev, "Using %s mac address %pM\n", mac_from,
@@ -3063,8 +3052,6 @@ static int mvneta_probe(struct platform_device *pdev)
 
 	return 0;
 
-err_deinit:
-	mvneta_deinit(pp);
 err_free_stats:
 	free_percpu(pp->stats);
 err_clk:
@@ -3083,7 +3070,6 @@ static int mvneta_remove(struct platform_device *pdev)
 	struct mvneta_port *pp = netdev_priv(dev);
 
 	unregister_netdev(dev);
-	mvneta_deinit(pp);
 	clk_disable_unprepare(pp->clk);
 	free_percpu(pp->stats);
 	irq_dispose_mapping(dev->irq);
-- 
1.9.1
