From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH 1/2] net: ethernet: fs-enet: use phydev from struct net_device
Date: Mon, 16 May 2016 16:52:36 +0200
Message-ID: <1463410357-1110-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Philippe Reynes <tremyfr@gmail.com>
To: pantelis.antoniou@gmail.com, vbordug@ru.mvista.com,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:34617 "EHLO
	mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753537AbcEPOwv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 May 2016 10:52:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The private structure contain a pointer to phydev, but the structure
net_device already contain such pointer. So we can remove the pointer
phydev in the private structure, and update the driver to use the
one contained in struct net_device.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 .../net/ethernet/freescale/fs_enet/fs_enet-main.c  |   31 +++++++------------
 drivers/net/ethernet/freescale/fs_enet/fs_enet.h   |    1 -
 drivers/net/ethernet/freescale/fs_enet/mac-fcc.c   |    4 +-
 drivers/net/ethernet/freescale/fs_enet/mac-fec.c   |    6 ++--
 drivers/net/ethernet/freescale/fs_enet/mac-scc.c   |    2 +-
 5 files changed, 18 insertions(+), 26 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c b/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c
index da90b5a..dc3700c 100644
--- a/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c
+++ b/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c
@@ -652,13 +652,13 @@ static void fs_timeout(struct net_device *dev)
 	spin_lock_irqsave(&fep->lock, flags);
 
 	if (dev->flags & IFF_UP) {
-		phy_stop(fep->phydev);
+		phy_stop(dev->phydev);
 		(*fep->ops->stop)(dev);
 		(*fep->ops->restart)(dev);
-		phy_start(fep->phydev);
+		phy_start(dev->phydev);
 	}
 
-	phy_start(fep->phydev);
+	phy_start(dev->phydev);
 	wake = fep->tx_free && !(CBDR_SC(fep->cur_tx) & BD_ENET_TX_READY);
 	spin_unlock_irqrestore(&fep->lock, flags);
 
@@ -672,7 +672,7 @@ static void fs_timeout(struct net_device *dev)
 static void generic_adjust_link(struct  net_device *dev)
 {
 	struct fs_enet_private *fep = netdev_priv(dev);
-	struct phy_device *phydev = fep->phydev;
+	struct phy_device *phydev = dev->phydev;
 	int new_state = 0;
 
 	if (phydev->link) {
@@ -741,8 +741,6 @@ static int fs_init_phy(struct net_device *dev)
 		return -ENODEV;
 	}
 
-	fep->phydev = phydev;
-
 	return 0;
 }
 
@@ -776,7 +774,7 @@ static int fs_enet_open(struct net_device *dev)
 		napi_disable(&fep->napi_tx);
 		return err;
 	}
-	phy_start(fep->phydev);
+	phy_start(dev->phydev);
 
 	netif_start_queue(dev);
 
@@ -792,7 +790,7 @@ static int fs_enet_close(struct net_device *dev)
 	netif_carrier_off(dev);
 	napi_disable(&fep->napi);
 	napi_disable(&fep->napi_tx);
-	phy_stop(fep->phydev);
+	phy_stop(dev->phydev);
 
 	spin_lock_irqsave(&fep->lock, flags);
 	spin_lock(&fep->tx_lock);
@@ -801,8 +799,7 @@ static int fs_enet_close(struct net_device *dev)
 	spin_unlock_irqrestore(&fep->lock, flags);
 
 	/* release any irqs */
-	phy_disconnect(fep->phydev);
-	fep->phydev = NULL;
+	phy_disconnect(dev->phydev);
 	free_irq(fep->interrupt, dev);
 
 	return 0;
@@ -850,10 +847,9 @@ static void fs_get_regs(struct net_device *dev, struct ethtool_regs *regs,
 static int fs_get_ksettings(struct net_device *dev,
 			    struct ethtool_link_ksettings *cmd)
 {
-	struct fs_enet_private *fep = netdev_priv(dev);
-	struct phy_device *phydev = fep->phydev;
+	struct phy_device *phydev = dev->phydev;
 
-	if (!fep->phydev)
+	if (!phydev)
 		return -ENODEV;
 
 	return phy_ethtool_ksettings_get(phydev, cmd);
@@ -862,10 +858,9 @@ static int fs_get_ksettings(struct net_device *dev,
 static int fs_set_ksettings(struct net_device *dev,
 			    const struct ethtool_link_ksettings *cmd)
 {
-	struct fs_enet_private *fep = netdev_priv(dev);
-	struct phy_device *phydev = fep->phydev;
+	struct phy_device *phydev = dev->phydev;
 
-	if (!fep->phydev)
+	if (!phydev)
 		return -ENODEV;
 
 	return phy_ethtool_ksettings_set(phydev, cmd);
@@ -903,12 +898,10 @@ static const struct ethtool_ops fs_ethtool_ops = {
 
 static int fs_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 {
-	struct fs_enet_private *fep = netdev_priv(dev);
-
 	if (!netif_running(dev))
 		return -EINVAL;
 
-	return phy_mii_ioctl(fep->phydev, rq, cmd);
+	return phy_mii_ioctl(dev->phydev, rq, cmd);
 }
 
 extern int fs_mii_connect(struct net_device *dev);
diff --git a/drivers/net/ethernet/freescale/fs_enet/fs_enet.h b/drivers/net/ethernet/freescale/fs_enet/fs_enet.h
index f184d8f..e29f54a 100644
--- a/drivers/net/ethernet/freescale/fs_enet/fs_enet.h
+++ b/drivers/net/ethernet/freescale/fs_enet/fs_enet.h
@@ -149,7 +149,6 @@ struct fs_enet_private {
 	unsigned int last_mii_status;
 	int interrupt;
 
-	struct phy_device *phydev;
 	int oldduplex, oldspeed, oldlink;	/* current settings */
 
 	/* event masks */
diff --git a/drivers/net/ethernet/freescale/fs_enet/mac-fcc.c b/drivers/net/ethernet/freescale/fs_enet/mac-fcc.c
index 1ba359f..d71761a 100644
--- a/drivers/net/ethernet/freescale/fs_enet/mac-fcc.c
+++ b/drivers/net/ethernet/freescale/fs_enet/mac-fcc.c
@@ -370,7 +370,7 @@ static void restart(struct net_device *dev)
 
 	/* adjust to speed (for RMII mode) */
 	if (fpi->use_rmii) {
-		if (fep->phydev->speed == 100)
+		if (dev->phydev->speed == 100)
 			C8(fcccp, fcc_gfemr, 0x20);
 		else
 			S8(fcccp, fcc_gfemr, 0x20);
@@ -396,7 +396,7 @@ static void restart(struct net_device *dev)
 		S32(fccp, fcc_fpsmr, FCC_PSMR_RMII);
 
 	/* adjust to duplex mode */
-	if (fep->phydev->duplex)
+	if (dev->phydev->duplex)
 		S32(fccp, fcc_fpsmr, FCC_PSMR_FDE | FCC_PSMR_LPB);
 	else
 		C32(fccp, fcc_fpsmr, FCC_PSMR_FDE | FCC_PSMR_LPB);
diff --git a/drivers/net/ethernet/freescale/fs_enet/mac-fec.c b/drivers/net/ethernet/freescale/fs_enet/mac-fec.c
index bade2f8..35a318e 100644
--- a/drivers/net/ethernet/freescale/fs_enet/mac-fec.c
+++ b/drivers/net/ethernet/freescale/fs_enet/mac-fec.c
@@ -254,7 +254,7 @@ static void restart(struct net_device *dev)
 	int r;
 	u32 addrhi, addrlo;
 
-	struct mii_bus *mii = fep->phydev->mdio.bus;
+	struct mii_bus *mii = dev->phydev->mdio.bus;
 	struct fec_info* fec_inf = mii->priv;
 
 	r = whack_reset(fep->fec.fecp);
@@ -333,7 +333,7 @@ static void restart(struct net_device *dev)
 	/*
 	 * adjust to duplex mode
 	 */
-	if (fep->phydev->duplex) {
+	if (dev->phydev->duplex) {
 		FC(fecp, r_cntrl, FEC_RCNTRL_DRT);
 		FS(fecp, x_cntrl, FEC_TCNTRL_FDEN);	/* FD enable */
 	} else {
@@ -363,7 +363,7 @@ static void stop(struct net_device *dev)
 	const struct fs_platform_info *fpi = fep->fpi;
 	struct fec __iomem *fecp = fep->fec.fecp;
 
-	struct fec_info *feci = fep->phydev->mdio.bus->priv;
+	struct fec_info *feci = dev->phydev->mdio.bus->priv;
 
 	int i;
 
diff --git a/drivers/net/ethernet/freescale/fs_enet/mac-scc.c b/drivers/net/ethernet/freescale/fs_enet/mac-scc.c
index 7a184e8..e8b9c33 100644
--- a/drivers/net/ethernet/freescale/fs_enet/mac-scc.c
+++ b/drivers/net/ethernet/freescale/fs_enet/mac-scc.c
@@ -352,7 +352,7 @@ static void restart(struct net_device *dev)
 	W16(sccp, scc_psmr, SCC_PSMR_ENCRC | SCC_PSMR_NIB22);
 
 	/* Set full duplex mode if needed */
-	if (fep->phydev->duplex)
+	if (dev->phydev->duplex)
 		S16(sccp, scc_psmr, SCC_PSMR_LPB | SCC_PSMR_FDE);
 
 	/* Restore multicast and promiscuous settings */
-- 
1.7.4.4
