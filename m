From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH 2/4] net: preserve ifreq parameter when calling generic
 phy_mii_ioctl().
Date: Sat, 17 Jul 2010 20:48:55 +0200
Message-ID: <6e34eaa0e60818833a9ca7b31a16b7e94e692da5.1279391885.git.richard.cochran@omicron.at>
References: <cover.1279391885.git.richard.cochran@omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:65139 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756603Ab0GQSs6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Jul 2010 14:48:58 -0400
Received: by mail-bw0-f46.google.com with SMTP id 1so1698395bwz.19
        for <netdev@vger.kernel.org>; Sat, 17 Jul 2010 11:48:57 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <cover.1279391885.git.richard.cochran@omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The phy_mii_ioctl() function unnecessarily throws away the original ifreq.
We need access to the ifreq in order to support PHYs that can perform
hardware time stamping.

Two maverick drivers filter the ioctl commands passed to phy_mii_ioctl().
This is unnecessary since phylib will check the command in any case.

Signed-off-by: Richard Cochran <richard.cochran@omicron.at>
---
 drivers/net/arm/ixp4xx_eth.c           |    3 ++-
 drivers/net/au1000_eth.c               |    2 +-
 drivers/net/bcm63xx_enet.c             |    2 +-
 drivers/net/cpmac.c                    |    5 +----
 drivers/net/dnet.c                     |    2 +-
 drivers/net/ethoc.c                    |    2 +-
 drivers/net/fec.c                      |    2 +-
 drivers/net/fec_mpc52xx.c              |    2 +-
 drivers/net/fs_enet/fs_enet-main.c     |    3 +--
 drivers/net/gianfar.c                  |    2 +-
 drivers/net/macb.c                     |    2 +-
 drivers/net/mv643xx_eth.c              |    2 +-
 drivers/net/octeon/octeon_mgmt.c       |    2 +-
 drivers/net/phy/phy.c                  |    3 ++-
 drivers/net/sb1250-mac.c               |    2 +-
 drivers/net/sh_eth.c                   |    2 +-
 drivers/net/smsc911x.c                 |    2 +-
 drivers/net/smsc9420.c                 |    2 +-
 drivers/net/stmmac/stmmac_main.c       |   22 ++++++++--------------
 drivers/net/tc35815.c                  |    2 +-
 drivers/net/tg3.c                      |    2 +-
 drivers/net/ucc_geth.c                 |    2 +-
 drivers/staging/octeon/ethernet-mdio.c |    2 +-
 include/linux/phy.h                    |    2 +-
 net/dsa/slave.c                        |    3 +--
 25 files changed, 34 insertions(+), 43 deletions(-)

diff --git a/drivers/net/arm/ixp4xx_eth.c b/drivers/net/arm/ixp4xx_eth.c
index ee2f842..4f1cc71 100644
--- a/drivers/net/arm/ixp4xx_eth.c
+++ b/drivers/net/arm/ixp4xx_eth.c
@@ -782,7 +782,8 @@ static int eth_ioctl(struct net_device *dev, struct ifreq *req, int cmd)
 
 	if (!netif_running(dev))
 		return -EINVAL;
-	return phy_mii_ioctl(port->phydev, if_mii(req), cmd);
+
+	return phy_mii_ioctl(port->phydev, req, cmd);
 }
 
 /* ethtool support */
diff --git a/drivers/net/au1000_eth.c b/drivers/net/au1000_eth.c
index ece6128..386d4fe 100644
--- a/drivers/net/au1000_eth.c
+++ b/drivers/net/au1000_eth.c
@@ -978,7 +978,7 @@ static int au1000_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 	if (!aup->phy_dev)
 		return -EINVAL; /* PHY not controllable */
 
-	return phy_mii_ioctl(aup->phy_dev, if_mii(rq), cmd);
+	return phy_mii_ioctl(aup->phy_dev, rq, cmd);
 }
 
 static const struct net_device_ops au1000_netdev_ops = {
diff --git a/drivers/net/bcm63xx_enet.c b/drivers/net/bcm63xx_enet.c
index faf5add..0d2c5da 100644
--- a/drivers/net/bcm63xx_enet.c
+++ b/drivers/net/bcm63xx_enet.c
@@ -1496,7 +1496,7 @@ static int bcm_enet_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 	if (priv->has_phy) {
 		if (!priv->phydev)
 			return -ENODEV;
-		return phy_mii_ioctl(priv->phydev, if_mii(rq), cmd);
+		return phy_mii_ioctl(priv->phydev, rq, cmd);
 	} else {
 		struct mii_if_info mii;
 
diff --git a/drivers/net/cpmac.c b/drivers/net/cpmac.c
index 1756d28..cdb05bb 100644
--- a/drivers/net/cpmac.c
+++ b/drivers/net/cpmac.c
@@ -846,11 +846,8 @@ static int cpmac_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 		return -EINVAL;
 	if (!priv->phy)
 		return -EINVAL;
-	if ((cmd == SIOCGMIIPHY) || (cmd == SIOCGMIIREG) ||
-	    (cmd == SIOCSMIIREG))
-		return phy_mii_ioctl(priv->phy, if_mii(ifr), cmd);
 
-	return -EOPNOTSUPP;
+	return phy_mii_ioctl(priv->phy, ifr, cmd);
 }
 
 static int cpmac_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
diff --git a/drivers/net/dnet.c b/drivers/net/dnet.c
index 8b0f50b..4ea7141 100644
--- a/drivers/net/dnet.c
+++ b/drivers/net/dnet.c
@@ -797,7 +797,7 @@ static int dnet_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 	if (!phydev)
 		return -ENODEV;
 
-	return phy_mii_ioctl(phydev, if_mii(rq), cmd);
+	return phy_mii_ioctl(phydev, rq, cmd);
 }
 
 static void dnet_get_drvinfo(struct net_device *dev,
diff --git a/drivers/net/ethoc.c b/drivers/net/ethoc.c
index 37ce8ac..d9f3106 100644
--- a/drivers/net/ethoc.c
+++ b/drivers/net/ethoc.c
@@ -732,7 +732,7 @@ static int ethoc_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 		phy = priv->phy;
 	}
 
-	return phy_mii_ioctl(phy, mdio, cmd);
+	return phy_mii_ioctl(phy, ifr, cmd);
 }
 
 static int ethoc_config(struct net_device *dev, struct ifmap *map)
diff --git a/drivers/net/fec.c b/drivers/net/fec.c
index b4afd7a..1670866 100644
--- a/drivers/net/fec.c
+++ b/drivers/net/fec.c
@@ -828,7 +828,7 @@ static int fec_enet_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 	if (!phydev)
 		return -ENODEV;
 
-	return phy_mii_ioctl(phydev, if_mii(rq), cmd);
+	return phy_mii_ioctl(phydev, rq, cmd);
 }
 
 static void fec_enet_free_buffers(struct net_device *dev)
diff --git a/drivers/net/fec_mpc52xx.c b/drivers/net/fec_mpc52xx.c
index 25e6cc6..fdbf148 100644
--- a/drivers/net/fec_mpc52xx.c
+++ b/drivers/net/fec_mpc52xx.c
@@ -826,7 +826,7 @@ static int mpc52xx_fec_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 	if (!priv->phydev)
 		return -ENOTSUPP;
 
-	return phy_mii_ioctl(priv->phydev, if_mii(rq), cmd);
+	return phy_mii_ioctl(priv->phydev, rq, cmd);
 }
 
 static const struct net_device_ops mpc52xx_fec_netdev_ops = {
diff --git a/drivers/net/fs_enet/fs_enet-main.c b/drivers/net/fs_enet/fs_enet-main.c
index 309a0ea..f08cff9 100644
--- a/drivers/net/fs_enet/fs_enet-main.c
+++ b/drivers/net/fs_enet/fs_enet-main.c
@@ -963,12 +963,11 @@ static const struct ethtool_ops fs_ethtool_ops = {
 static int fs_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 {
 	struct fs_enet_private *fep = netdev_priv(dev);
-	struct mii_ioctl_data *mii = (struct mii_ioctl_data *)&rq->ifr_data;
 
 	if (!netif_running(dev))
 		return -EINVAL;
 
-	return phy_mii_ioctl(fep->phydev, mii, cmd);
+	return phy_mii_ioctl(fep->phydev, rq, cmd);
 }
 
 extern int fs_mii_connect(struct net_device *dev);
diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index fccb7a3..1d16d51 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -847,7 +847,7 @@ static int gfar_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 	if (!priv->phydev)
 		return -ENODEV;
 
-	return phy_mii_ioctl(priv->phydev, if_mii(rq), cmd);
+	return phy_mii_ioctl(priv->phydev, rq, cmd);
 }
 
 static unsigned int reverse_bitmap(unsigned int bit_map, unsigned int max_qs)
diff --git a/drivers/net/macb.c b/drivers/net/macb.c
index 40797fb..ff2f158 100644
--- a/drivers/net/macb.c
+++ b/drivers/net/macb.c
@@ -1082,7 +1082,7 @@ static int macb_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 	if (!phydev)
 		return -ENODEV;
 
-	return phy_mii_ioctl(phydev, if_mii(rq), cmd);
+	return phy_mii_ioctl(phydev, rq, cmd);
 }
 
 static const struct net_device_ops macb_netdev_ops = {
diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index 82b720f..0561425 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -2457,7 +2457,7 @@ static int mv643xx_eth_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 	struct mv643xx_eth_private *mp = netdev_priv(dev);
 
 	if (mp->phy != NULL)
-		return phy_mii_ioctl(mp->phy, if_mii(ifr), cmd);
+		return phy_mii_ioctl(mp->phy, ifr, cmd);
 
 	return -EOPNOTSUPP;
 }
diff --git a/drivers/net/octeon/octeon_mgmt.c b/drivers/net/octeon/octeon_mgmt.c
index f4a0f08..b264f0f 100644
--- a/drivers/net/octeon/octeon_mgmt.c
+++ b/drivers/net/octeon/octeon_mgmt.c
@@ -620,7 +620,7 @@ static int octeon_mgmt_ioctl(struct net_device *netdev,
 	if (!p->phydev)
 		return -EINVAL;
 
-	return phy_mii_ioctl(p->phydev, if_mii(rq), cmd);
+	return phy_mii_ioctl(p->phydev, rq, cmd);
 }
 
 static void octeon_mgmt_adjust_link(struct net_device *netdev)
diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index 64be466..bd88d81 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -309,8 +309,9 @@ EXPORT_SYMBOL(phy_ethtool_gset);
  * current state.  Use at own risk.
  */
 int phy_mii_ioctl(struct phy_device *phydev,
-		struct mii_ioctl_data *mii_data, int cmd)
+		struct ifreq *ifr, int cmd)
 {
+	struct mii_ioctl_data *mii_data = if_mii(ifr);
 	u16 val = mii_data->val_in;
 
 	switch (cmd) {
diff --git a/drivers/net/sb1250-mac.c b/drivers/net/sb1250-mac.c
index 1f3acc3..e585c3f 100644
--- a/drivers/net/sb1250-mac.c
+++ b/drivers/net/sb1250-mac.c
@@ -2532,7 +2532,7 @@ static int sbmac_mii_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 	if (!netif_running(dev) || !sc->phy_dev)
 		return -EINVAL;
 
-	return phy_mii_ioctl(sc->phy_dev, if_mii(rq), cmd);
+	return phy_mii_ioctl(sc->phy_dev, rq, cmd);
 }
 
 static int sbmac_close(struct net_device *dev)
diff --git a/drivers/net/sh_eth.c b/drivers/net/sh_eth.c
index 501a55f..8279f8e 100644
--- a/drivers/net/sh_eth.c
+++ b/drivers/net/sh_eth.c
@@ -1233,7 +1233,7 @@ static int sh_eth_do_ioctl(struct net_device *ndev, struct ifreq *rq,
 	if (!phydev)
 		return -ENODEV;
 
-	return phy_mii_ioctl(phydev, if_mii(rq), cmd);
+	return phy_mii_ioctl(phydev, rq, cmd);
 }
 
 #if defined(SH_ETH_HAS_TSU)
diff --git a/drivers/net/smsc911x.c b/drivers/net/smsc911x.c
index cc55974..56dc2ff 100644
--- a/drivers/net/smsc911x.c
+++ b/drivers/net/smsc911x.c
@@ -1538,7 +1538,7 @@ static int smsc911x_do_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 	if (!netif_running(dev) || !pdata->phy_dev)
 		return -EINVAL;
 
-	return phy_mii_ioctl(pdata->phy_dev, if_mii(ifr), cmd);
+	return phy_mii_ioctl(pdata->phy_dev, ifr, cmd);
 }
 
 static int
diff --git a/drivers/net/smsc9420.c b/drivers/net/smsc9420.c
index 6cdee6a..b09ee1c 100644
--- a/drivers/net/smsc9420.c
+++ b/drivers/net/smsc9420.c
@@ -245,7 +245,7 @@ static int smsc9420_do_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 	if (!netif_running(dev) || !pd->phy_dev)
 		return -EINVAL;
 
-	return phy_mii_ioctl(pd->phy_dev, if_mii(ifr), cmd);
+	return phy_mii_ioctl(pd->phy_dev, ifr, cmd);
 }
 
 static int smsc9420_ethtool_get_settings(struct net_device *dev,
diff --git a/drivers/net/stmmac/stmmac_main.c b/drivers/net/stmmac/stmmac_main.c
index a31d580..acf0616 100644
--- a/drivers/net/stmmac/stmmac_main.c
+++ b/drivers/net/stmmac/stmmac_main.c
@@ -1437,24 +1437,18 @@ static void stmmac_poll_controller(struct net_device *dev)
 static int stmmac_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 {
 	struct stmmac_priv *priv = netdev_priv(dev);
-	int ret = -EOPNOTSUPP;
+	int ret;
 
 	if (!netif_running(dev))
 		return -EINVAL;
 
-	switch (cmd) {
-	case SIOCGMIIPHY:
-	case SIOCGMIIREG:
-	case SIOCSMIIREG:
-		if (!priv->phydev)
-			return -EINVAL;
-
-		spin_lock(&priv->lock);
-		ret = phy_mii_ioctl(priv->phydev, if_mii(rq), cmd);
-		spin_unlock(&priv->lock);
-	default:
-		break;
-	}
+	if (!priv->phydev)
+		return -EINVAL;
+
+	spin_lock(&priv->lock);
+	ret = phy_mii_ioctl(priv->phydev, rq, cmd);
+	spin_unlock(&priv->lock);
+
 	return ret;
 }
 
diff --git a/drivers/net/tc35815.c b/drivers/net/tc35815.c
index be08b75..99e423a 100644
--- a/drivers/net/tc35815.c
+++ b/drivers/net/tc35815.c
@@ -2066,7 +2066,7 @@ static int tc35815_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 		return -EINVAL;
 	if (!lp->phy_dev)
 		return -ENODEV;
-	return phy_mii_ioctl(lp->phy_dev, if_mii(rq), cmd);
+	return phy_mii_ioctl(lp->phy_dev, rq, cmd);
 }
 
 static void tc35815_chip_reset(struct net_device *dev)
diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 289cdc5..d4163f2 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -10954,7 +10954,7 @@ static int tg3_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 		if (!(tp->tg3_flags3 & TG3_FLG3_PHY_CONNECTED))
 			return -EAGAIN;
 		phydev = tp->mdio_bus->phy_map[TG3_PHY_MII_ADDR];
-		return phy_mii_ioctl(phydev, data, cmd);
+		return phy_mii_ioctl(phydev, ifr, cmd);
 	}
 
 	switch (cmd) {
diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index dc32a62..e17dd74 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -3714,7 +3714,7 @@ static int ucc_geth_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 	if (!ugeth->phydev)
 		return -ENODEV;
 
-	return phy_mii_ioctl(ugeth->phydev, if_mii(rq), cmd);
+	return phy_mii_ioctl(ugeth->phydev, rq, cmd);
 }
 
 static const struct net_device_ops ucc_geth_netdev_ops = {
diff --git a/drivers/staging/octeon/ethernet-mdio.c b/drivers/staging/octeon/ethernet-mdio.c
index 7e0be8d..10a82ef 100644
--- a/drivers/staging/octeon/ethernet-mdio.c
+++ b/drivers/staging/octeon/ethernet-mdio.c
@@ -113,7 +113,7 @@ int cvm_oct_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 	if (!priv->phydev)
 		return -EINVAL;
 
-	return phy_mii_ioctl(priv->phydev, if_mii(rq), cmd);
+	return phy_mii_ioctl(priv->phydev, rq, cmd);
 }
 
 static void cvm_oct_adjust_link(struct net_device *dev)
diff --git a/include/linux/phy.h b/include/linux/phy.h
index 987e111..d63736a 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -498,7 +498,7 @@ void phy_stop_machine(struct phy_device *phydev);
 int phy_ethtool_sset(struct phy_device *phydev, struct ethtool_cmd *cmd);
 int phy_ethtool_gset(struct phy_device *phydev, struct ethtool_cmd *cmd);
 int phy_mii_ioctl(struct phy_device *phydev,
-		struct mii_ioctl_data *mii_data, int cmd);
+		struct ifreq *ifr, int cmd);
 int phy_start_interrupts(struct phy_device *phydev);
 void phy_print_status(struct phy_device *phydev);
 struct phy_device* phy_device_create(struct mii_bus *bus, int addr, int phy_id);
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 8fdca56..64ca2a6 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -164,10 +164,9 @@ out:
 static int dsa_slave_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct mii_ioctl_data *mii_data = if_mii(ifr);
 
 	if (p->phy != NULL)
-		return phy_mii_ioctl(p->phy, mii_data, cmd);
+		return phy_mii_ioctl(p->phy, ifr, cmd);
 
 	return -EOPNOTSUPP;
 }
-- 
1.7.0.4

