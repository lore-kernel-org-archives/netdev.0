From: Grant Likely <grant.likely@secretlab.ca>
Subject: [PATCH 03/14] net/fec_mpc52xx: Don't dereference phy_device if it is
	NULL
Date: Tue, 31 Mar 2009 02:26:59 -0600
Message-ID: <20090331082659.1427.83509.stgit@localhost.localdomain>
References: <20090331075537.1427.7819.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: olof@lixom.net, afleming@freescale.com, galak@kernel.crashing.org,
	Anton Vorontsov <avorontsov@ru.mvista.com>,
	Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
To: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.182]:47063 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752848AbZCaI1C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Mar 2009 04:27:02 -0400
Received: by wa-out-1112.google.com with SMTP id j5so1584813wah.21
        for <netdev@vger.kernel.org>; Tue, 31 Mar 2009 01:27:01 -0700 (PDT)
In-Reply-To: <20090331075537.1427.7819.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Grant Likely <grant.likely@secretlab.ca>

The FEC Ethernet device isn't always attached to a phy.  Be careful
not to dereference phy_device if it is NULL.

Reported-by: Henk Stegeman <henk.stegeman@gmail.com>
Signed-off-by: Grant Likely <grant.likely@secretlab.ca>
---

 drivers/net/fec_mpc52xx.c |   22 ++++++++++++----------
 1 files changed, 12 insertions(+), 10 deletions(-)


diff --git a/drivers/net/fec_mpc52xx.c b/drivers/net/fec_mpc52xx.c
index 75d0569..e10eb2c 100644
--- a/drivers/net/fec_mpc52xx.c
+++ b/drivers/net/fec_mpc52xx.c
@@ -271,15 +271,6 @@ static void mpc52xx_fec_phy_stop(struct net_device *dev)
 	phy_write(priv->phydev, MII_BMCR, BMCR_PDOWN);
 }
 
-static int mpc52xx_fec_phy_mii_ioctl(struct mpc52xx_fec_priv *priv,
-		struct mii_ioctl_data *mii_data, int cmd)
-{
-	if (!priv->phydev)
-		return -ENOTSUPP;
-
-	return phy_mii_ioctl(priv->phydev, mii_data, cmd);
-}
-
 static void mpc52xx_fec_phy_hw_init(struct mpc52xx_fec_priv *priv)
 {
 	struct mpc52xx_fec __iomem *fec = priv->fec;
@@ -852,12 +843,20 @@ static void mpc52xx_fec_get_drvinfo(struct net_device *dev,
 static int mpc52xx_fec_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
 	struct mpc52xx_fec_priv *priv = netdev_priv(dev);
+
+	if (!priv->phydev)
+		return -ENODEV;
+
 	return phy_ethtool_gset(priv->phydev, cmd);
 }
 
 static int mpc52xx_fec_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
 	struct mpc52xx_fec_priv *priv = netdev_priv(dev);
+
+	if (!priv->phydev)
+		return -ENODEV;
+
 	return phy_ethtool_sset(priv->phydev, cmd);
 }
 
@@ -887,7 +886,10 @@ static int mpc52xx_fec_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 {
 	struct mpc52xx_fec_priv *priv = netdev_priv(dev);
 
-	return mpc52xx_fec_phy_mii_ioctl(priv, if_mii(rq), cmd);
+	if (!priv->phydev)
+		return -ENOTSUPP;
+
+	return phy_mii_ioctl(priv->phydev, if_mii(rq), cmd);
 }
 
 static const struct net_device_ops mpc52xx_fec_netdev_ops = {

