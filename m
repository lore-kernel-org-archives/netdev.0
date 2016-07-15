From: Gavin Shan <gwshan@linux.vnet.ibm.com>
Subject: [PATCH net-next v2 08/10] net/faraday: Support NCSI mode
Date: Fri, 15 Jul 2016 20:44:18 +1000
Message-ID: <1468579460-13768-9-git-send-email-gwshan@linux.vnet.ibm.com>
References: <1468579460-13768-1-git-send-email-gwshan@linux.vnet.ibm.com>
Cc: davem@davemloft.net, benh@kernel.crashing.org, joel@jms.id.au,
	gerlitz.or@gmail.com, weixue@trustnetic.com, yuvali@mellanox.com,
	alexei.starovoitov@gmail.com, f.fainelli@gmail.com,
	Gavin Shan <gwshan@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:10275 "EHLO
	mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932653AbcGOKvP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jul 2016 06:51:15 -0400
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u6FAnI0E023416
	for <netdev@vger.kernel.org>; Fri, 15 Jul 2016 06:51:15 -0400
Received: from e23smtp01.au.ibm.com (e23smtp01.au.ibm.com [202.81.31.143])
	by mx0a-001b2d01.pphosted.com with ESMTP id 246kcjt7ud-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 15 Jul 2016 06:51:15 -0400
Received: from localhost
	by e23smtp01.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <gwshan@linux.vnet.ibm.com>;
	Fri, 15 Jul 2016 20:51:12 +1000
Received: from d23relay10.au.ibm.com (d23relay10.au.ibm.com [9.190.26.77])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id DF9E23578052
	for <netdev@vger.kernel.org>; Fri, 15 Jul 2016 20:51:08 +1000 (EST)
Received: from d23av06.au.ibm.com (d23av06.au.ibm.com [9.190.235.151])
	by d23relay10.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u6FAp8GN22675526
	for <netdev@vger.kernel.org>; Fri, 15 Jul 2016 20:51:08 +1000
Received: from d23av06.au.ibm.com (localhost [127.0.0.1])
	by d23av06.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u6FAp7Ju031921
	for <netdev@vger.kernel.org>; Fri, 15 Jul 2016 20:51:08 +1000
In-Reply-To: <1468579460-13768-1-git-send-email-gwshan@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This makes ftgmac100 driver support NCSI mode. The NCSI is enabled
on the interface if property "use-nc-si" or "use-ncsi" is found from
the device node in device tree.

   * No PHY device is used when NCSI mode is enabled.
   * The NCSI device (struct ncsi_dev) is created when probing the
     device while it's enabled/started when the interface is brought
     up.
   * Hardware IP checksum dosn't work when NCSI mode is enabled. It
     is disabled on enabled NCSI.

Signed-off-by: Gavin Shan <gwshan@linux.vnet.ibm.com>
Acked-by: Joel Stanley <joel@jms.id.au>
---
 drivers/net/ethernet/faraday/ftgmac100.c | 85 ++++++++++++++++++++++++++++----
 1 file changed, 75 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/faraday/ftgmac100.c b/drivers/net/ethernet/faraday/ftgmac100.c
index 2c3f656..1cd4975 100644
--- a/drivers/net/ethernet/faraday/ftgmac100.c
+++ b/drivers/net/ethernet/faraday/ftgmac100.c
@@ -31,6 +31,7 @@
 #include <linux/phy.h>
 #include <linux/platform_device.h>
 #include <net/ip.h>
+#include <net/ncsi.h>
 
 #include "ftgmac100.h"
 
@@ -68,10 +69,13 @@ struct ftgmac100 {
 
 	struct net_device *netdev;
 	struct device *dev;
+	struct ncsi_dev *ndev;
 	struct napi_struct napi;
 
 	struct mii_bus *mii_bus;
 	int old_speed;
+	bool use_ncsi;
+	bool enabled;
 };
 
 static int ftgmac100_alloc_rx_page(struct ftgmac100 *priv,
@@ -1010,7 +1014,10 @@ static irqreturn_t ftgmac100_interrupt(int irq, void *dev_id)
 	struct net_device *netdev = dev_id;
 	struct ftgmac100 *priv = netdev_priv(netdev);
 
-	if (likely(netif_running(netdev))) {
+	/* When running in NCSI mode, the interface should be ready for
+	 * receiving or transmitting NCSI packets before it's opened.
+	 */
+	if (likely(priv->use_ncsi || netif_running(netdev))) {
 		/* Disable interrupts for polling */
 		iowrite32(0, priv->base + FTGMAC100_OFFSET_IER);
 		napi_schedule(&priv->napi);
@@ -1123,17 +1130,33 @@ static int ftgmac100_open(struct net_device *netdev)
 		goto err_hw;
 
 	ftgmac100_init_hw(priv);
-	ftgmac100_start_hw(priv, 10);
-
-	phy_start(netdev->phydev);
+	ftgmac100_start_hw(priv, priv->use_ncsi ? 100 : 10);
+	if (netdev->phydev)
+		phy_start(netdev->phydev);
+	else if (priv->use_ncsi)
+		netif_carrier_on(netdev);
 
 	napi_enable(&priv->napi);
 	netif_start_queue(netdev);
 
 	/* enable all interrupts */
 	iowrite32(INT_MASK_ALL_ENABLED, priv->base + FTGMAC100_OFFSET_IER);
+
+	/* Start the NCSI device */
+	if (priv->use_ncsi) {
+		err = ncsi_start_dev(priv->ndev);
+		if (err)
+			goto err_ncsi;
+	}
+
+	priv->enabled = true;
+
 	return 0;
 
+err_ncsi:
+	napi_disable(&priv->napi);
+	netif_stop_queue(netdev);
+	iowrite32(0, priv->base + FTGMAC100_OFFSET_IER);
 err_hw:
 	free_irq(priv->irq, netdev);
 err_irq:
@@ -1146,12 +1169,17 @@ static int ftgmac100_stop(struct net_device *netdev)
 {
 	struct ftgmac100 *priv = netdev_priv(netdev);
 
+	if (!priv->enabled)
+		return 0;
+
 	/* disable all interrupts */
+	priv->enabled = false;
 	iowrite32(0, priv->base + FTGMAC100_OFFSET_IER);
 
 	netif_stop_queue(netdev);
 	napi_disable(&priv->napi);
-	phy_stop(netdev->phydev);
+	if (netdev->phydev)
+		phy_stop(netdev->phydev);
 
 	ftgmac100_stop_hw(priv);
 	free_irq(priv->irq, netdev);
@@ -1192,6 +1220,9 @@ static int ftgmac100_hard_start_xmit(struct sk_buff *skb,
 /* optional */
 static int ftgmac100_do_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd)
 {
+	if (!netdev->phydev)
+		return -ENXIO;
+
 	return phy_mii_ioctl(netdev->phydev, ifr, cmd);
 }
 
@@ -1258,6 +1289,15 @@ static void ftgmac100_destroy_mdio(struct net_device *netdev)
 	mdiobus_free(priv->mii_bus);
 }
 
+static void ftgmac100_ncsi_handler(struct ncsi_dev *nd)
+{
+	if (unlikely(nd->state != ncsi_dev_state_functional))
+		return;
+
+	netdev_info(nd->dev, "NCSI interface %s\n",
+		    nd->link_up ? "up" : "down");
+}
+
 /******************************************************************************
  * struct platform_driver functions
  *****************************************************************************/
@@ -1267,7 +1307,7 @@ static int ftgmac100_probe(struct platform_device *pdev)
 	int irq;
 	struct net_device *netdev;
 	struct ftgmac100 *priv;
-	int err;
+	int err = 0;
 
 	if (!pdev)
 		return -ENODEV;
@@ -1291,7 +1331,6 @@ static int ftgmac100_probe(struct platform_device *pdev)
 
 	netdev->ethtool_ops = &ftgmac100_ethtool_ops;
 	netdev->netdev_ops = &ftgmac100_netdev_ops;
-	netdev->features = NETIF_F_IP_CSUM | NETIF_F_GRO;
 
 	platform_set_drvdata(pdev, netdev);
 
@@ -1326,9 +1365,34 @@ static int ftgmac100_probe(struct platform_device *pdev)
 	/* MAC address from chip or random one */
 	ftgmac100_setup_mac(priv);
 
-	err = ftgmac100_setup_mdio(netdev);
-	if (err)
-		goto err_setup_mdio;
+	if (pdev->dev.of_node &&
+	    of_get_property(pdev->dev.of_node, "use-ncsi", NULL)) {
+		if (!IS_ENABLED(CONFIG_NET_NCSI)) {
+			dev_err(&pdev->dev, "NCSI stack not enabled\n");
+			goto err_ncsi_dev;
+		}
+
+		dev_info(&pdev->dev, "Using NCSI interface\n");
+		priv->use_ncsi = true;
+		priv->ndev = ncsi_register_dev(netdev, ftgmac100_ncsi_handler);
+		if (!priv->ndev)
+			goto err_ncsi_dev;
+	} else {
+		priv->use_ncsi = false;
+		err = ftgmac100_setup_mdio(netdev);
+		if (err)
+			goto err_setup_mdio;
+	}
+
+	/* We have to disable on-chip IP checksum functionality
+	 * when NCSI is enabled on the interface. It doesn't work
+	 * in that case.
+	 */
+	netdev->features = NETIF_F_IP_CSUM | NETIF_F_GRO;
+	if (priv->use_ncsi &&
+	    of_get_property(pdev->dev.of_node, "no-hw-checksum", NULL))
+		netdev->features &= ~NETIF_F_IP_CSUM;
+
 
 	/* register network device */
 	err = register_netdev(netdev);
@@ -1341,6 +1405,7 @@ static int ftgmac100_probe(struct platform_device *pdev)
 
 	return 0;
 
+err_ncsi_dev:
 err_register_netdev:
 	ftgmac100_destroy_mdio(netdev);
 err_setup_mdio:
-- 
2.1.0
