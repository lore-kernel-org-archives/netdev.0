From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH v2 net-next 2/2] drivers: net: xgene: Check all RGMII phy mode variants
Date: Thu, 18 May 2017 15:13:44 -0700
Message-ID: <1495145624-29463-3-git-send-email-isubramanian@apm.com>
References: <1495145624-29463-1-git-send-email-isubramanian@apm.com>
Cc: f.fainelli@gmail.com, andrew@lunn.ch,
        linux-arm-kernel@lists.infradead.org, patches@apm.com,
        Iyappan Subramanian <isubramanian@apm.com>,
        Quan Nguyen <qnguyen@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f45.google.com ([74.125.83.45]:34142 "EHLO
        mail-pg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932412AbdERWKw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 18 May 2017 18:10:52 -0400
Received: by mail-pg0-f45.google.com with SMTP id u28so28901200pgn.1
        for <netdev@vger.kernel.org>; Thu, 18 May 2017 15:10:52 -0700 (PDT)
In-Reply-To: <1495145624-29463-1-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch addresses the review comment from the previous patch set,
by using phy_interface_mode_is_rgmii() helper function to address
all RGMII phy mode variants.

Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
Signed-off-by: Quan Nguyen <qnguyen@apm.com>
---

Review comment reference:
http://www.spinics.net/lists/netdev/msg434649.html
---
 drivers/net/ethernet/apm/xgene/xgene_enet_ethtool.c |  6 +++---
 drivers/net/ethernet/apm/xgene/xgene_enet_hw.c      | 12 ++++++------
 drivers/net/ethernet/apm/xgene/xgene_enet_main.c    | 15 +++++++++------
 3 files changed, 18 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_ethtool.c b/drivers/net/ethernet/apm/xgene/xgene_enet_ethtool.c
index 0fdec78..559963b 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_ethtool.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_ethtool.c
@@ -127,7 +127,7 @@ static int xgene_get_link_ksettings(struct net_device *ndev,
 	struct phy_device *phydev = ndev->phydev;
 	u32 supported;
 
-	if (pdata->phy_mode == PHY_INTERFACE_MODE_RGMII) {
+	if (phy_interface_mode_is_rgmii(pdata->phy_mode)) {
 		if (phydev == NULL)
 			return -ENODEV;
 
@@ -177,7 +177,7 @@ static int xgene_set_link_ksettings(struct net_device *ndev,
 	struct xgene_enet_pdata *pdata = netdev_priv(ndev);
 	struct phy_device *phydev = ndev->phydev;
 
-	if (pdata->phy_mode == PHY_INTERFACE_MODE_RGMII) {
+	if (phy_interface_mode_is_rgmii(pdata->phy_mode)) {
 		if (!phydev)
 			return -ENODEV;
 
@@ -304,7 +304,7 @@ static int xgene_set_pauseparam(struct net_device *ndev,
 	struct phy_device *phydev = ndev->phydev;
 	u32 oldadv, newadv;
 
-	if (pdata->phy_mode == PHY_INTERFACE_MODE_RGMII ||
+	if (phy_interface_mode_is_rgmii(pdata->phy_mode) ||
 	    pdata->phy_mode == PHY_INTERFACE_MODE_SGMII) {
 		if (!phydev)
 			return -EINVAL;
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
index 6ac27c7..e45b587 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
@@ -272,7 +272,7 @@ void xgene_enet_wr_mac(struct xgene_enet_pdata *pdata, u32 wr_addr, u32 wr_data)
 	u32 done;
 
 	if (pdata->mdio_driver && ndev->phydev &&
-	    pdata->phy_mode == PHY_INTERFACE_MODE_RGMII) {
+	    phy_interface_mode_is_rgmii(pdata->phy_mode)) {
 		struct mii_bus *bus = ndev->phydev->mdio.bus;
 
 		return xgene_mdio_wr_mac(bus->priv, wr_addr, wr_data);
@@ -326,12 +326,13 @@ static void xgene_enet_rd_mcx_csr(struct xgene_enet_pdata *pdata,
 u32 xgene_enet_rd_mac(struct xgene_enet_pdata *pdata, u32 rd_addr)
 {
 	void __iomem *addr, *rd, *cmd, *cmd_done;
+	struct net_device *ndev = pdata->ndev;
 	u32 done, rd_data;
 	u8 wait = 10;
 
-	if (pdata->mdio_driver && pdata->ndev->phydev &&
-	    pdata->phy_mode == PHY_INTERFACE_MODE_RGMII) {
-		struct mii_bus *bus = pdata->ndev->phydev->mdio.bus;
+	if (pdata->mdio_driver && ndev->phydev &&
+	    phy_interface_mode_is_rgmii(pdata->phy_mode)) {
+		struct mii_bus *bus = ndev->phydev->mdio.bus;
 
 		return xgene_mdio_rd_mac(bus->priv, rd_addr);
 	}
@@ -349,8 +350,7 @@ u32 xgene_enet_rd_mac(struct xgene_enet_pdata *pdata, u32 rd_addr)
 		udelay(1);
 
 	if (!done)
-		netdev_err(pdata->ndev, "mac read failed, addr: %04x\n",
-			   rd_addr);
+		netdev_err(ndev, "mac read failed, addr: %04x\n", rd_addr);
 
 	rd_data = ioread32(rd);
 	iowrite32(0, cmd);
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
index 21cd4ef..d3906f6 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
@@ -1634,7 +1634,7 @@ static int xgene_enet_get_irqs(struct xgene_enet_pdata *pdata)
 	struct device *dev = &pdev->dev;
 	int i, ret, max_irqs;
 
-	if (pdata->phy_mode == PHY_INTERFACE_MODE_RGMII)
+	if (phy_interface_mode_is_rgmii(pdata->phy_mode))
 		max_irqs = 1;
 	else if (pdata->phy_mode == PHY_INTERFACE_MODE_SGMII)
 		max_irqs = 2;
@@ -1760,7 +1760,7 @@ static int xgene_enet_get_resources(struct xgene_enet_pdata *pdata)
 		dev_err(dev, "Unable to get phy-connection-type\n");
 		return pdata->phy_mode;
 	}
-	if (pdata->phy_mode != PHY_INTERFACE_MODE_RGMII &&
+	if (!phy_interface_mode_is_rgmii(pdata->phy_mode) &&
 	    pdata->phy_mode != PHY_INTERFACE_MODE_SGMII &&
 	    pdata->phy_mode != PHY_INTERFACE_MODE_XGMII) {
 		dev_err(dev, "Incorrect phy-connection-type specified\n");
@@ -1805,7 +1805,7 @@ static int xgene_enet_get_resources(struct xgene_enet_pdata *pdata)
 	pdata->cle.base = base_addr + BLOCK_ETH_CLE_CSR_OFFSET;
 	pdata->eth_ring_if_addr = base_addr + BLOCK_ETH_RING_IF_OFFSET;
 	pdata->eth_diag_csr_addr = base_addr + BLOCK_ETH_DIAG_CSR_OFFSET;
-	if (pdata->phy_mode == PHY_INTERFACE_MODE_RGMII ||
+	if (phy_interface_mode_is_rgmii(pdata->phy_mode) ||
 	    pdata->phy_mode == PHY_INTERFACE_MODE_SGMII) {
 		pdata->mcx_mac_addr = pdata->base_addr + BLOCK_ETH_MAC_OFFSET;
 		pdata->mcx_stats_addr =
@@ -1904,6 +1904,9 @@ static void xgene_enet_setup_ops(struct xgene_enet_pdata *pdata)
 {
 	switch (pdata->phy_mode) {
 	case PHY_INTERFACE_MODE_RGMII:
+	case PHY_INTERFACE_MODE_RGMII_ID:
+	case PHY_INTERFACE_MODE_RGMII_RXID:
+	case PHY_INTERFACE_MODE_RGMII_TXID:
 		pdata->mac_ops = &xgene_gmac_ops;
 		pdata->port_ops = &xgene_gport_ops;
 		pdata->rm = RM3;
@@ -2100,7 +2103,7 @@ static int xgene_enet_probe(struct platform_device *pdev)
 	if (pdata->phy_mode == PHY_INTERFACE_MODE_XGMII) {
 		INIT_DELAYED_WORK(&pdata->link_work, link_state);
 	} else if (!pdata->mdio_driver) {
-		if (pdata->phy_mode == PHY_INTERFACE_MODE_RGMII)
+		if (phy_interface_mode_is_rgmii(pdata->phy_mode))
 			ret = xgene_enet_mdio_config(pdata);
 		else
 			INIT_DELAYED_WORK(&pdata->link_work, link_state);
@@ -2131,7 +2134,7 @@ static int xgene_enet_probe(struct platform_device *pdev)
 
 	if (pdata->mdio_driver)
 		xgene_enet_phy_disconnect(pdata);
-	else if (pdata->phy_mode == PHY_INTERFACE_MODE_RGMII)
+	else if (phy_interface_mode_is_rgmii(pdata->phy_mode))
 		xgene_enet_mdio_remove(pdata);
 err1:
 	xgene_enet_delete_desc_rings(pdata);
@@ -2155,7 +2158,7 @@ static int xgene_enet_remove(struct platform_device *pdev)
 
 	if (pdata->mdio_driver)
 		xgene_enet_phy_disconnect(pdata);
-	else if (pdata->phy_mode == PHY_INTERFACE_MODE_RGMII)
+	else if (phy_interface_mode_is_rgmii(pdata->phy_mode))
 		xgene_enet_mdio_remove(pdata);
 
 	unregister_netdev(ndev);
-- 
1.9.1
