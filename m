From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH 1/2] net: ethernet: marvell: pxa168_eth: use phydev from struct net_device
Date: Sun, 17 Jul 2016 23:30:45 +0200
Message-ID: <1468791046-19567-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Philippe Reynes <tremyfr@gmail.com>
To: davem@davemloft.net, jszhang@marvell.com,
	sergei.shtylyov@cogentembedded.com, mugunthanvnm@ti.com,
	a@unstable.cc, fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:33468 "EHLO
	mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751189AbcGQVaz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Jul 2016 17:30:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The private structure contain a pointer to phydev, but the structure
net_device already contain such pointer. So we can remove the pointer
phydev in the private structure, and update the driver to use the
one contained in struct net_device.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/marvell/pxa168_eth.c |   36 +++++++++++++----------------
 1 files changed, 16 insertions(+), 20 deletions(-)

diff --git a/drivers/net/ethernet/marvell/pxa168_eth.c b/drivers/net/ethernet/marvell/pxa168_eth.c
index 54d5154..d466326 100644
--- a/drivers/net/ethernet/marvell/pxa168_eth.c
+++ b/drivers/net/ethernet/marvell/pxa168_eth.c
@@ -247,7 +247,6 @@ struct pxa168_eth_private {
 	 */
 	struct timer_list timeout;
 	struct mii_bus *smi_bus;
-	struct phy_device *phy;
 
 	/* clock */
 	struct clk *clk;
@@ -644,7 +643,7 @@ static void eth_port_start(struct net_device *dev)
 	struct pxa168_eth_private *pep = netdev_priv(dev);
 	int tx_curr_desc, rx_curr_desc;
 
-	phy_start(pep->phy);
+	phy_start(dev->phydev);
 
 	/* Assignment of Tx CTRP of given queue */
 	tx_curr_desc = pep->tx_curr_desc_q;
@@ -700,7 +699,7 @@ static void eth_port_reset(struct net_device *dev)
 	val &= ~PCR_EN;
 	wrl(pep, PORT_CONFIG, val);
 
-	phy_stop(pep->phy);
+	phy_stop(dev->phydev);
 }
 
 /*
@@ -943,7 +942,7 @@ static int set_port_config_ext(struct pxa168_eth_private *pep)
 static void pxa168_eth_adjust_link(struct net_device *dev)
 {
 	struct pxa168_eth_private *pep = netdev_priv(dev);
-	struct phy_device *phy = pep->phy;
+	struct phy_device *phy = dev->phydev;
 	u32 cfg, cfg_o = rdl(pep, PORT_CONFIG);
 	u32 cfgext, cfgext_o = rdl(pep, PORT_CONFIG_EXT);
 
@@ -973,16 +972,17 @@ static int pxa168_init_phy(struct net_device *dev)
 {
 	struct pxa168_eth_private *pep = netdev_priv(dev);
 	struct ethtool_cmd cmd;
+	struct phy_device *phy = NULL;
 	int err;
 
-	if (pep->phy)
+	if (dev->phydev)
 		return 0;
 
-	pep->phy = mdiobus_scan(pep->smi_bus, pep->phy_addr);
-	if (IS_ERR(pep->phy))
-		return PTR_ERR(pep->phy);
+	phy = mdiobus_scan(pep->smi_bus, pep->phy_addr);
+	if (IS_ERR(phy))
+		return PTR_ERR(phy);
 
-	err = phy_connect_direct(dev, pep->phy, pxa168_eth_adjust_link,
+	err = phy_connect_direct(dev, phy, pxa168_eth_adjust_link,
 				 pep->phy_intf);
 	if (err)
 		return err;
@@ -1366,30 +1366,26 @@ static int pxa168_smi_write(struct mii_bus *bus, int phy_addr, int regnum,
 static int pxa168_eth_do_ioctl(struct net_device *dev, struct ifreq *ifr,
 			       int cmd)
 {
-	struct pxa168_eth_private *pep = netdev_priv(dev);
-	if (pep->phy != NULL)
-		return phy_mii_ioctl(pep->phy, ifr, cmd);
+	if (dev->phydev != NULL)
+		return phy_mii_ioctl(dev->phydev, ifr, cmd);
 
 	return -EOPNOTSUPP;
 }
 
 static int pxa168_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
-	struct pxa168_eth_private *pep = netdev_priv(dev);
 	int err;
 
-	err = phy_read_status(pep->phy);
+	err = phy_read_status(dev->phydev);
 	if (err == 0)
-		err = phy_ethtool_gset(pep->phy, cmd);
+		err = phy_ethtool_gset(dev->phydev, cmd);
 
 	return err;
 }
 
 static int pxa168_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
-	struct pxa168_eth_private *pep = netdev_priv(dev);
-
-	return phy_ethtool_sset(pep->phy, cmd);
+	return phy_ethtool_sset(dev->phydev, cmd);
 }
 
 static void pxa168_get_drvinfo(struct net_device *dev,
@@ -1569,8 +1565,8 @@ static int pxa168_eth_remove(struct platform_device *pdev)
 				  pep->htpr, pep->htpr_dma);
 		pep->htpr = NULL;
 	}
-	if (pep->phy)
-		phy_disconnect(pep->phy);
+	if (dev->phydev)
+		phy_disconnect(dev->phydev);
 	if (pep->clk) {
 		clk_disable_unprepare(pep->clk);
 	}
-- 
1.7.4.4
