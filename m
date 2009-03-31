From: Henk Stegeman <henk.stegeman@gmail.com>
Subject: Patch: Fix fec_mpc52xx driver to use net_device_ops
Date: Tue, 31 Mar 2009 12:44:15 +0200
Message-ID: <ae4f76fd0903310344s2d46edf2l505a1d21a4778d54@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.25]:21488 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750923AbZCaKoT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Mar 2009 06:44:19 -0400
Received: by ey-out-2122.google.com with SMTP id 4so733726eyf.37
        for <netdev@vger.kernel.org>; Tue, 31 Mar 2009 03:44:15 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix fec_mpc52xx driver to use net_device_ops and to be careful not to
dereference phy_device if a phy has not yet been connected.

Signed-off-by: Henk Stegeman <henk.stegeman@gmail.com>

diff --git a/drivers/net/fec_mpc52xx.c b/drivers/net/fec_mpc52xx.c
index cd8e98b..ca76b95 100644
--- a/drivers/net/fec_mpc52xx.c
+++ b/drivers/net/fec_mpc52xx.c
@@ -847,24 +847,40 @@ static void mpc52xx_fec_get_drvinfo(struct
net_device *dev,
 static int mpc52xx_fec_get_settings(struct net_device *dev, struct
ethtool_cmd *cmd)
 {
 	struct mpc52xx_fec_priv *priv = netdev_priv(dev);
+
+	if (!priv->phydev)
+			return -ENODEV;
+
 	return phy_ethtool_gset(priv->phydev, cmd);
 }

 static int mpc52xx_fec_set_settings(struct net_device *dev, struct
ethtool_cmd *cmd)
 {
 	struct mpc52xx_fec_priv *priv = netdev_priv(dev);
+
+	if (!priv->phydev)
+			return -ENODEV;
+
 	return phy_ethtool_sset(priv->phydev, cmd);
 }

 static u32 mpc52xx_fec_get_msglevel(struct net_device *dev)
 {
 	struct mpc52xx_fec_priv *priv = netdev_priv(dev);
+
+	if (!priv->phydev)
+		return 0;
+
 	return priv->msg_enable;
 }

 static void mpc52xx_fec_set_msglevel(struct net_device *dev, u32 level)
 {
 	struct mpc52xx_fec_priv *priv = netdev_priv(dev);
+
+	if (!priv->phydev)
+			return;
+
 	priv->msg_enable = level;
 }

@@ -882,12 +898,31 @@ static int mpc52xx_fec_ioctl(struct net_device
*dev, struct ifreq *rq, int cmd)
 {
 	struct mpc52xx_fec_priv *priv = netdev_priv(dev);

+	if (!priv->phydev)
+			return -ENODEV;
+
 	return mpc52xx_fec_phy_mii_ioctl(priv, if_mii(rq), cmd);
 }

 /* ======================================================================== */
 /* OF Driver                                                                */
 /* ======================================================================== */
+static const struct net_device_ops mpc52xx_fec_netdev_ops = {
+       .ndo_open               = mpc52xx_fec_open,
+       .ndo_stop               = mpc52xx_fec_close,
+       .ndo_start_xmit         = mpc52xx_fec_hard_start_xmit,
+       .ndo_tx_timeout         = mpc52xx_fec_tx_timeout,
+       .ndo_get_stats          = mpc52xx_fec_get_stats,
+       .ndo_set_multicast_list = mpc52xx_fec_set_multicast_list,
+       .ndo_validate_addr      = eth_validate_addr,
+       .ndo_set_mac_address    = mpc52xx_fec_set_mac_address,
+       .ndo_do_ioctl           = mpc52xx_fec_ioctl,
+
+#ifdef CONFIG_NET_POLL_CONTROLLER
+       .ndo_poll_controller     = mpc52xx_fec_poll_controller,
+#endif
+};
+

 static int __devinit
 mpc52xx_fec_probe(struct of_device *op, const struct of_device_id *match)
@@ -929,20 +964,10 @@ mpc52xx_fec_probe(struct of_device *op, const
struct of_device_id *match)
 		return -EBUSY;

 	/* Init ether ndev with what we have */
-	ndev->open		= mpc52xx_fec_open;
-	ndev->stop		= mpc52xx_fec_close;
-	ndev->hard_start_xmit	= mpc52xx_fec_hard_start_xmit;
-	ndev->do_ioctl		= mpc52xx_fec_ioctl;
 	ndev->ethtool_ops	= &mpc52xx_fec_ethtool_ops;
-	ndev->get_stats		= mpc52xx_fec_get_stats;
-	ndev->set_mac_address	= mpc52xx_fec_set_mac_address;
-	ndev->set_multicast_list = mpc52xx_fec_set_multicast_list;
-	ndev->tx_timeout	= mpc52xx_fec_tx_timeout;
 	ndev->watchdog_timeo	= FEC_WATCHDOG_TIMEOUT;
 	ndev->base_addr		= mem.start;
-#ifdef CONFIG_NET_POLL_CONTROLLER
-	ndev->poll_controller = mpc52xx_fec_poll_controller;
-#endif
+	ndev->netdev_ops = &mpc52xx_fec_netdev_ops;

 	priv->t_irq = priv->r_irq = ndev->irq = NO_IRQ; /* IRQ are free for now */
