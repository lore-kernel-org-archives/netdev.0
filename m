From: Gavin Shan <gwshan@linux.vnet.ibm.com>
Subject: [PATCH RFC 5/6] net/faraday: Enable NCSI interface
Date: Mon,  9 Nov 2015 11:10:05 +1100
Message-ID: <1447027806-4744-6-git-send-email-gwshan@linux.vnet.ibm.com>
References: <1447027806-4744-1-git-send-email-gwshan@linux.vnet.ibm.com>
Cc: benh@kernel.crashing.org, davem@davemloft.net,
	sergei.shtylyov@cogentembedded.com,
	Gavin Shan <gwshan@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e23smtp01.au.ibm.com ([202.81.31.143]:44860 "EHLO
	e23smtp01.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751468AbbKIALP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Nov 2015 19:11:15 -0500
Received: from localhost
	by e23smtp01.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <gwshan@linux.vnet.ibm.com>;
	Mon, 9 Nov 2015 10:11:12 +1000
Received: from d23relay07.au.ibm.com (d23relay07.au.ibm.com [9.190.26.37])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 62A162BB0051
	for <netdev@vger.kernel.org>; Mon,  9 Nov 2015 11:11:09 +1100 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay07.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id tA90B2Or15335666
	for <netdev@vger.kernel.org>; Mon, 9 Nov 2015 11:11:10 +1100
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id tA90AZc1027061
	for <netdev@vger.kernel.org>; Mon, 9 Nov 2015 11:10:36 +1100
In-Reply-To: <1447027806-4744-1-git-send-email-gwshan@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The NIC has the possibility to connect to NCSI package and channel.
This supports NCSI enabled interface. When the network device is
registered, the accompanying NCSI device is registered. When the
interface is to be brought up, the NCSI device is started to probe
NCSI topology and choose one active channel automatically. On the
other handle, when the interface is to be brought down, the interface
will be shuted down when the NCSI device is teared down.

Signed-off-by: Gavin Shan <gwshan@linux.vnet.ibm.com>
---
 drivers/net/ethernet/faraday/ftgmac100.c | 91 +++++++++++++++++++++++---------
 1 file changed, 67 insertions(+), 24 deletions(-)

diff --git a/drivers/net/ethernet/faraday/ftgmac100.c b/drivers/net/ethernet/faraday/ftgmac100.c
index 778bee8..1b13fd4 100644
--- a/drivers/net/ethernet/faraday/ftgmac100.c
+++ b/drivers/net/ethernet/faraday/ftgmac100.c
@@ -31,6 +31,7 @@
 #include <linux/phy.h>
 #include <linux/platform_device.h>
 #include <net/ip.h>
+#include <net/ncsi.h>
 
 #include "ftgmac100.h"
 
@@ -68,6 +69,7 @@ struct ftgmac100 {
 
 	struct net_device *netdev;
 	struct device *dev;
+	struct ncsi_dev *ndev;
 	struct napi_struct napi;
 
 	struct mii_bus *mii_bus;
@@ -1038,7 +1040,11 @@ static irqreturn_t ftgmac100_interrupt(int irq, void *dev_id)
 	struct net_device *netdev = dev_id;
 	struct ftgmac100 *priv = netdev_priv(netdev);
 
-	if (likely(netif_running(netdev))) {
+	/* When running in NCSI mode, the interface should be
+	 * ready to receive or transmit NCSI packet before it's
+	 * opened.
+	 */
+	if (likely(priv->use_ncsi || netif_running(netdev))) {
 		/* Disable interrupts for polling */
 		iowrite32(0, priv->base + FTGMAC100_OFFSET_IER);
 		napi_schedule(&priv->napi);
@@ -1162,8 +1168,18 @@ static int ftgmac100_open(struct net_device *netdev)
 
 	/* enable all interrupts */
 	iowrite32(INT_MASK_ALL_ENABLED, priv->base + FTGMAC100_OFFSET_IER);
+	/* Start the NCSI device */
+	if (priv->use_ncsi){
+		err = ncsi_start_dev(priv->ndev);
+		if (err)
+			goto err_ncsi;
+	}
 	return 0;
 
+err_ncsi:
+	napi_disable(&priv->napi);
+	netif_stop_queue(netdev);
+	iowrite32(0, priv->base + FTGMAC100_OFFSET_IER);
 err_hw:
 	free_irq(priv->irq, netdev);
 err_irq:
@@ -1172,7 +1188,7 @@ err_alloc:
 	return err;
 }
 
-static int ftgmac100_stop(struct net_device *netdev)
+static int ftgmac100_stop_dev(struct net_device *netdev)
 {
 	struct ftgmac100 *priv = netdev_priv(netdev);
 
@@ -1191,6 +1207,18 @@ static int ftgmac100_stop(struct net_device *netdev)
 	return 0;
 }
 
+static int ftgmac100_stop(struct net_device *netdev)
+{
+	struct ftgmac100 *priv = netdev_priv(netdev);
+
+	/* Stop NCSI device */
+	if (priv->use_ncsi) {
+		ncsi_stop_dev(priv->ndev);
+		return 0;
+	}
+
+	return ftgmac100_stop_dev(netdev);
+}
 static int ftgmac100_hard_start_xmit(struct sk_buff *skb,
 				     struct net_device *netdev)
 {
@@ -1291,6 +1319,21 @@ static const struct net_device_ops ftgmac100_netdev_ops = {
 	.ndo_do_ioctl		= ftgmac100_do_ioctl,
 };
 
+static void ftgmac100_ncsi_handler(struct ncsi_dev *nd)
+{
+	struct net_device *netdev = nd->nd_dev;
+
+	if (nd->nd_state != ncsi_dev_state_functional)
+		return;
+
+	if (nd->nd_link_up) {
+		pr_info("NCSI dev is up\n");
+		netif_start_queue(netdev);
+	} else {
+		pr_info("NCSI dev is down\n");
+		ftgmac100_stop_dev(netdev);
+	}
+}
 /******************************************************************************
  * struct platform_driver functions
  *****************************************************************************/
@@ -1300,7 +1343,7 @@ static int ftgmac100_probe(struct platform_device *pdev)
 	int irq;
 	struct net_device *netdev;
 	struct ftgmac100 *priv;
-	int err;
+	int err = 0;
 
 	if (!pdev)
 		return -ENODEV;
@@ -1320,7 +1363,17 @@ static int ftgmac100_probe(struct platform_device *pdev)
 		goto err_alloc_etherdev;
 	}
 
+	/* Check for NCSI mode */
+	priv = netdev_priv(netdev);
 	SET_NETDEV_DEV(netdev, &pdev->dev);
+	if (pdev->dev.of_node &&
+	    of_get_property(pdev->dev.of_node, "use-nc-si", NULL)) {
+		dev_info(&pdev->dev, "Using NCSI interface\n");
+		priv->phydev = NULL;
+		priv->use_ncsi = true;
+	} else {
+		priv->use_ncsi = false;
+	}
 
 	netdev->ethtool_ops = &ftgmac100_ethtool_ops;
 	netdev->netdev_ops = &ftgmac100_netdev_ops;
@@ -1329,7 +1382,6 @@ static int ftgmac100_probe(struct platform_device *pdev)
 	platform_set_drvdata(pdev, netdev);
 
 	/* setup private data */
-	priv = netdev_priv(netdev);
 	priv->netdev = netdev;
 	priv->dev = &pdev->dev;
 
@@ -1356,24 +1408,14 @@ static int ftgmac100_probe(struct platform_device *pdev)
 
 	priv->irq = irq;
 
-	/* Check for NC-SI mode */
-	if (pdev->dev.of_node &&
-	    of_get_property(pdev->dev.of_node, "use-nc-si", NULL))
-		priv->use_ncsi = true;
-	else
-		priv->use_ncsi = false;
+	/* Read MAC address or setup a new one */
+	ftgmac100_setup_mac(priv);
 
-	/* If we use NC-SI, we need to set that up, which isn't implemented yet
-	 * so we pray things were setup by the bootloader and just mark our link
-	 * as up (otherwise we can't get packets through).
-	 *
-	 * Eventually, we'll have a proper NC-SI stack as a helper we can
-	 * instanciate
-	 */
+	/* Register NCSI device */
 	if (priv->use_ncsi) {
-		/* XXX */
-		priv->phydev = NULL;
-		dev_info(&pdev->dev, "Using NC-SI interface\n");
+		priv->ndev = ncsi_register_dev(netdev, ftgmac100_ncsi_handler);
+		if (!priv->ndev)
+			goto err_ncsi_dev;
 	} else {
 		err = ftgmac100_setup_mdio(priv);
 
@@ -1384,9 +1426,6 @@ static int ftgmac100_probe(struct platform_device *pdev)
 			dev_warn(&pdev->dev, "Error %d setting up MDIO\n", err);
 	}
 
-	/* Read MAC address or setup a new one */
-	ftgmac100_setup_mac(priv);
-
 	/* Register network device */
 	err = register_netdev(netdev);
 	if (err) {
@@ -1399,7 +1438,11 @@ static int ftgmac100_probe(struct platform_device *pdev)
 	return 0;
 
 err_register_netdev:
-	ftgmac100_destroy_mdio(priv);
+	if (!priv->use_ncsi)
+		ftgmac100_destroy_mdio(priv);
+	else
+		ncsi_unregister_dev(priv->ndev);
+err_ncsi_dev:
 	iounmap(priv->base);
 err_ioremap:
 	release_resource(priv->res);
-- 
2.1.0
