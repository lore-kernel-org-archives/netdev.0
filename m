From: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Subject: [PATCH v2 4/9] net: mvneta: Clean-up mvneta_init()
Date: Tue,  6 May 2014 14:20:53 -0300
Message-ID: <1399396858-14551-5-git-send-email-ezequiel.garcia@free-electrons.com>
References: <1399396858-14551-1-git-send-email-ezequiel.garcia@free-electrons.com>
Cc: Gregory Clement <gregory.clement@free-electrons.com>,
	Lior Amsalem <alior@marvell.com>,
	Tawfik Bayouk <tawfik@marvell.com>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
To: <netdev@vger.kernel.org>, "David S. Miller" <davem@davemloft.net>,
	Willy Tarreau <w@1wt.eu>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from top.free-electrons.com ([176.31.233.9]:53537 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753627AbaEFRVs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 May 2014 13:21:48 -0400
In-Reply-To: <1399396858-14551-1-git-send-email-ezequiel.garcia@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This commit cleans-up mvneta_init(), which initializes the hardware
and allocates the rx/qx queues. The queue allocation is simplified
by using devm_kzalloc instead of kzalloc. The unused phy_addr parameter
is removed. While here, the 'hal' references in the comments are removed.
This commit makes no functionality change.

Signed-off-by: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvneta.c | 38 ++++++++++++-----------------------
 1 file changed, 13 insertions(+), 25 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index 743503a..9a444a0 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -1999,7 +1999,7 @@ static void mvneta_tx_reset(struct mvneta_port *pp)
 {
 	int queue;
 
-	/* free the skb's in the hal tx ring */
+	/* free the skb's in the tx ring */
 	for (queue = 0; queue < txq_number; queue++)
 		mvneta_txq_done_force(pp, &pp->txqs[queue]);
 
@@ -2638,7 +2638,7 @@ const struct ethtool_ops mvneta_eth_tool_ops = {
 };
 
 /* Initialize hw */
-static int mvneta_init(struct mvneta_port *pp, int phy_addr)
+static int mvneta_init(struct device *dev, struct mvneta_port *pp)
 {
 	int queue;
 
@@ -2648,8 +2648,9 @@ static int mvneta_init(struct mvneta_port *pp, int phy_addr)
 	/* Set port default values */
 	mvneta_defaults_set(pp);
 
-	pp->txqs = kzalloc(txq_number * sizeof(struct mvneta_tx_queue),
-			   GFP_KERNEL);
+	pp->txqs = devm_kzalloc(dev,
+				txq_number * sizeof(struct mvneta_tx_queue),
+				GFP_KERNEL);
 	if (!pp->txqs)
 		return -ENOMEM;
 
@@ -2661,12 +2662,11 @@ static int mvneta_init(struct mvneta_port *pp, int phy_addr)
 		txq->done_pkts_coal = MVNETA_TXDONE_COAL_PKTS;
 	}
 
-	pp->rxqs = kzalloc(rxq_number * sizeof(struct mvneta_rx_queue),
-			   GFP_KERNEL);
-	if (!pp->rxqs) {
-		kfree(pp->txqs);
+	pp->rxqs = devm_kzalloc(dev,
+				rxq_number * sizeof(struct mvneta_rx_queue),
+				GFP_KERNEL);
+	if (!pp->rxqs)
 		return -ENOMEM;
-	}
 
 	/* Create Rx descriptor rings */
 	for (queue = 0; queue < rxq_number; queue++) {
@@ -2680,12 +2680,6 @@ static int mvneta_init(struct mvneta_port *pp, int phy_addr)
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
@@ -2768,7 +2762,6 @@ static int mvneta_probe(struct platform_device *pdev)
 	struct resource *res;
 	struct device_node *dn = pdev->dev.of_node;
 	struct device_node *phy_node;
-	u32 phy_addr;
 	struct mvneta_port *pp;
 	struct net_device *dev;
 	const char *dt_mac_addr;
@@ -2864,16 +2857,14 @@ static int mvneta_probe(struct platform_device *pdev)
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
@@ -2890,7 +2881,7 @@ static int mvneta_probe(struct platform_device *pdev)
 	err = register_netdev(dev);
 	if (err < 0) {
 		dev_err(&pdev->dev, "failed to register\n");
-		goto err_deinit;
+		goto err_free_stats;
 	}
 
 	netdev_info(dev, "Using %s mac address %pM\n", mac_from,
@@ -2900,8 +2891,6 @@ static int mvneta_probe(struct platform_device *pdev)
 
 	return 0;
 
-err_deinit:
-	mvneta_deinit(pp);
 err_free_stats:
 	free_percpu(pp->stats);
 err_clk:
@@ -2920,7 +2909,6 @@ static int mvneta_remove(struct platform_device *pdev)
 	struct mvneta_port *pp = netdev_priv(dev);
 
 	unregister_netdev(dev);
-	mvneta_deinit(pp);
 	clk_disable_unprepare(pp->clk);
 	free_percpu(pp->stats);
 	irq_dispose_mapping(dev->irq);
-- 
1.9.1
