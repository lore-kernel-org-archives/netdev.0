From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH net-next] drivers: net: xgene: Check all RGMII phy mode variants
Date: Wed, 17 May 2017 13:05:50 -0700
Message-ID: <1495051550-28961-1-git-send-email-isubramanian@apm.com>
Cc: f.fainelli@gmail.com, linux-arm-kernel@lists.infradead.org,
        patches@apm.com, Iyappan Subramanian <isubramanian@apm.com>,
        Quan Nguyen <qnguyen@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:33367 "EHLO
        mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753280AbdEQUCz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 17 May 2017 16:02:55 -0400
Received: by mail-pf0-f174.google.com with SMTP id e193so12471792pfh.0
        for <netdev@vger.kernel.org>; Wed, 17 May 2017 13:02:55 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch addresses the review comment from the previous patch set,
by adding a helper function to address all RGMII phy mode variants.

Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
Signed-off-by: Quan Nguyen <qnguyen@apm.com>
---

Review comment reference:
http://www.spinics.net/lists/netdev/msg434649.html
---
 .../net/ethernet/apm/xgene/xgene_enet_ethtool.c    |  6 ++---
 drivers/net/ethernet/apm/xgene/xgene_enet_hw.c     | 26 +++++++++++++++++-----
 drivers/net/ethernet/apm/xgene/xgene_enet_hw.h     |  1 +
 drivers/net/ethernet/apm/xgene/xgene_enet_main.c   | 15 ++++++++-----
 4 files changed, 33 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_ethtool.c b/drivers/net/ethernet/apm/xgene/xgene_enet_ethtool.c
index 0fdec78..a0c9ddc 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_ethtool.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_ethtool.c
@@ -127,7 +127,7 @@ static int xgene_get_link_ksettings(struct net_device *ndev,
 	struct phy_device *phydev = ndev->phydev;
 	u32 supported;
 
-	if (pdata->phy_mode == PHY_INTERFACE_MODE_RGMII) {
+	if (is_xgene_enet_phy_mode_rgmii(ndev)) {
 		if (phydev == NULL)
 			return -ENODEV;
 
@@ -177,7 +177,7 @@ static int xgene_set_link_ksettings(struct net_device *ndev,
 	struct xgene_enet_pdata *pdata = netdev_priv(ndev);
 	struct phy_device *phydev = ndev->phydev;
 
-	if (pdata->phy_mode == PHY_INTERFACE_MODE_RGMII) {
+	if (is_xgene_enet_phy_mode_rgmii(ndev)) {
 		if (!phydev)
 			return -ENODEV;
 
@@ -304,7 +304,7 @@ static int xgene_set_pauseparam(struct net_device *ndev,
 	struct phy_device *phydev = ndev->phydev;
 	u32 oldadv, newadv;
 
-	if (pdata->phy_mode == PHY_INTERFACE_MODE_RGMII ||
+	if (is_xgene_enet_phy_mode_rgmii(ndev) ||
 	    pdata->phy_mode == PHY_INTERFACE_MODE_SGMII) {
 		if (!phydev)
 			return -EINVAL;
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
index 6ac27c7..00f313d 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
@@ -264,6 +264,20 @@ static void xgene_enet_wr_mcx_csr(struct xgene_enet_pdata *pdata,
 	iowrite32(val, addr);
 }
 
+bool is_xgene_enet_phy_mode_rgmii(struct net_device *ndev)
+{
+	struct xgene_enet_pdata *pdata = netdev_priv(ndev);
+	int phy_mode = pdata->phy_mode;
+	bool ret;
+
+	ret = phy_mode == PHY_INTERFACE_MODE_RGMII ||
+	      phy_mode == PHY_INTERFACE_MODE_RGMII_ID ||
+	      phy_mode == PHY_INTERFACE_MODE_RGMII_RXID ||
+	      phy_mode == PHY_INTERFACE_MODE_RGMII_TXID;
+
+	return ret;
+}
+
 void xgene_enet_wr_mac(struct xgene_enet_pdata *pdata, u32 wr_addr, u32 wr_data)
 {
 	void __iomem *addr, *wr, *cmd, *cmd_done;
@@ -272,7 +286,7 @@ void xgene_enet_wr_mac(struct xgene_enet_pdata *pdata, u32 wr_addr, u32 wr_data)
 	u32 done;
 
 	if (pdata->mdio_driver && ndev->phydev &&
-	    pdata->phy_mode == PHY_INTERFACE_MODE_RGMII) {
+	    is_xgene_enet_phy_mode_rgmii(ndev)) {
 		struct mii_bus *bus = ndev->phydev->mdio.bus;
 
 		return xgene_mdio_wr_mac(bus->priv, wr_addr, wr_data);
@@ -326,12 +340,13 @@ static void xgene_enet_rd_mcx_csr(struct xgene_enet_pdata *pdata,
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
+	    is_xgene_enet_phy_mode_rgmii(ndev)) {
+		struct mii_bus *bus = ndev->phydev->mdio.bus;
 
 		return xgene_mdio_rd_mac(bus->priv, rd_addr);
 	}
@@ -349,8 +364,7 @@ u32 xgene_enet_rd_mac(struct xgene_enet_pdata *pdata, u32 rd_addr)
 		udelay(1);
 
 	if (!done)
-		netdev_err(pdata->ndev, "mac read failed, addr: %04x\n",
-			   rd_addr);
+		netdev_err(ndev, "mac read failed, addr: %04x\n", rd_addr);
 
 	rd_data = ioread32(rd);
 	iowrite32(0, cmd);
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.h b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.h
index 5d3e18d..5c54f65 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.h
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.h
@@ -431,6 +431,7 @@ static inline u16 xgene_enet_get_numslots(u16 id, u32 size)
 		      size / WORK_DESC_SIZE;
 }
 
+bool is_xgene_enet_phy_mode_rgmii(struct net_device *ndev);
 void xgene_enet_parse_error(struct xgene_enet_desc_ring *ring,
 			    enum xgene_enet_err_code status);
 int xgene_enet_mdio_config(struct xgene_enet_pdata *pdata);
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
index 21cd4ef..6e0028f 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
@@ -1634,7 +1634,7 @@ static int xgene_enet_get_irqs(struct xgene_enet_pdata *pdata)
 	struct device *dev = &pdev->dev;
 	int i, ret, max_irqs;
 
-	if (pdata->phy_mode == PHY_INTERFACE_MODE_RGMII)
+	if (is_xgene_enet_phy_mode_rgmii(pdata->ndev))
 		max_irqs = 1;
 	else if (pdata->phy_mode == PHY_INTERFACE_MODE_SGMII)
 		max_irqs = 2;
@@ -1760,7 +1760,7 @@ static int xgene_enet_get_resources(struct xgene_enet_pdata *pdata)
 		dev_err(dev, "Unable to get phy-connection-type\n");
 		return pdata->phy_mode;
 	}
-	if (pdata->phy_mode != PHY_INTERFACE_MODE_RGMII &&
+	if (!is_xgene_enet_phy_mode_rgmii(ndev) &&
 	    pdata->phy_mode != PHY_INTERFACE_MODE_SGMII &&
 	    pdata->phy_mode != PHY_INTERFACE_MODE_XGMII) {
 		dev_err(dev, "Incorrect phy-connection-type specified\n");
@@ -1805,7 +1805,7 @@ static int xgene_enet_get_resources(struct xgene_enet_pdata *pdata)
 	pdata->cle.base = base_addr + BLOCK_ETH_CLE_CSR_OFFSET;
 	pdata->eth_ring_if_addr = base_addr + BLOCK_ETH_RING_IF_OFFSET;
 	pdata->eth_diag_csr_addr = base_addr + BLOCK_ETH_DIAG_CSR_OFFSET;
-	if (pdata->phy_mode == PHY_INTERFACE_MODE_RGMII ||
+	if (is_xgene_enet_phy_mode_rgmii(ndev) ||
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
+		if (is_xgene_enet_phy_mode_rgmii(ndev))
 			ret = xgene_enet_mdio_config(pdata);
 		else
 			INIT_DELAYED_WORK(&pdata->link_work, link_state);
@@ -2131,7 +2134,7 @@ static int xgene_enet_probe(struct platform_device *pdev)
 
 	if (pdata->mdio_driver)
 		xgene_enet_phy_disconnect(pdata);
-	else if (pdata->phy_mode == PHY_INTERFACE_MODE_RGMII)
+	else if (is_xgene_enet_phy_mode_rgmii(ndev))
 		xgene_enet_mdio_remove(pdata);
 err1:
 	xgene_enet_delete_desc_rings(pdata);
@@ -2155,7 +2158,7 @@ static int xgene_enet_remove(struct platform_device *pdev)
 
 	if (pdata->mdio_driver)
 		xgene_enet_phy_disconnect(pdata);
-	else if (pdata->phy_mode == PHY_INTERFACE_MODE_RGMII)
+	else if (is_xgene_enet_phy_mode_rgmii(ndev))
 		xgene_enet_mdio_remove(pdata);
 
 	unregister_netdev(ndev);
-- 
1.9.1
