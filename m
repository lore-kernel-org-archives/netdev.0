From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH 01/12] ftgmac100: Add a tx timeout handler
Date: Fri,  7 Apr 2017 13:30:54 +1000
Message-ID: <20170407033105.29558-2-benh@kernel.crashing.org>
References: <20170407033105.29558-1-benh@kernel.crashing.org>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:39156 "EHLO gate.crashing.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753288AbdDGDbc (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 6 Apr 2017 23:31:32 -0400
In-Reply-To: <20170407033105.29558-1-benh@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We have a reset task to reset our chip, use it.

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---
 drivers/net/ethernet/faraday/ftgmac100.c | 13 +++++++++++++
 1 file changed, 13 insertions(+)

diff --git a/drivers/net/ethernet/faraday/ftgmac100.c b/drivers/net/ethernet/faraday/ftgmac100.c
index 9f18e5e..f4b719214 100644
--- a/drivers/net/ethernet/faraday/ftgmac100.c
+++ b/drivers/net/ethernet/faraday/ftgmac100.c
@@ -1248,6 +1248,17 @@ static int ftgmac100_do_ioctl(struct net_device *netdev, struct ifreq *ifr, int
 	return phy_mii_ioctl(netdev->phydev, ifr, cmd);
 }
 
+static void ftgmac100_tx_timeout(struct net_device *netdev)
+{
+	struct ftgmac100 *priv = netdev_priv(netdev);
+
+	/* Disable all interrupts */
+	iowrite32(0, priv->base + FTGMAC100_OFFSET_IER);
+
+	/* Do the reset outside of interrupt context */
+	schedule_work(&priv->reset_task);
+}
+
 static const struct net_device_ops ftgmac100_netdev_ops = {
 	.ndo_open		= ftgmac100_open,
 	.ndo_stop		= ftgmac100_stop,
@@ -1255,6 +1266,7 @@ static const struct net_device_ops ftgmac100_netdev_ops = {
 	.ndo_set_mac_address	= ftgmac100_set_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_do_ioctl		= ftgmac100_do_ioctl,
+	.ndo_tx_timeout		= ftgmac100_tx_timeout,
 };
 
 static int ftgmac100_setup_mdio(struct net_device *netdev)
@@ -1359,6 +1371,7 @@ static int ftgmac100_probe(struct platform_device *pdev)
 
 	netdev->ethtool_ops = &ftgmac100_ethtool_ops;
 	netdev->netdev_ops = &ftgmac100_netdev_ops;
+	netdev->watchdog_timeo = 5 * HZ;
 
 	platform_set_drvdata(pdev, netdev);
 
-- 
2.9.3
