From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH v6 08/12] drivers: net: xgene: Use exported functions
Date: Wed, 20 Jul 2016 23:59:26 -0700
Message-ID: <1469084370-16781-9-git-send-email-isubramanian@apm.com>
References: <1469084370-16781-1-git-send-email-isubramanian@apm.com>
Cc: linux-arm-kernel@lists.infradead.org, patches@apm.com,
	linux@armlinux.org.uk, Iyappan Subramanian <isubramanian@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	devicetree@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:33101 "EHLO
	mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751225AbcGUG7N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jul 2016 02:59:13 -0400
Received: by mail-pf0-f182.google.com with SMTP id y134so27373355pfg.0
        for <netdev@vger.kernel.org>; Wed, 20 Jul 2016 23:59:13 -0700 (PDT)
In-Reply-To: <1469084370-16781-1-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch reuses the mdio read/write and phy_register functions
and removed the local definitions.

Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
Tested-by: Fushen Chen <fchen@apm.com>
Tested-by: Toan Le <toanle@apm.com>
---
 drivers/net/ethernet/apm/xgene/xgene_enet_hw.c | 97 +++-----------------------
 1 file changed, 9 insertions(+), 88 deletions(-)

diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
index 27a7a1c..8a2a221 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
@@ -381,59 +381,6 @@ static void xgene_enet_rd_mcx_mac(struct xgene_enet_pdata *pdata,
 			   rd_addr);
 }
 
-static int xgene_mii_phy_write(struct xgene_enet_pdata *pdata, int phy_id,
-			       u32 reg, u16 data)
-{
-	u32 addr = 0, wr_data = 0;
-	u32 done;
-	u8 wait = 10;
-
-	PHY_ADDR_SET(&addr, phy_id);
-	REG_ADDR_SET(&addr, reg);
-	xgene_enet_wr_mcx_mac(pdata, MII_MGMT_ADDRESS_ADDR, addr);
-
-	PHY_CONTROL_SET(&wr_data, data);
-	xgene_enet_wr_mcx_mac(pdata, MII_MGMT_CONTROL_ADDR, wr_data);
-	do {
-		usleep_range(5, 10);
-		xgene_enet_rd_mcx_mac(pdata, MII_MGMT_INDICATORS_ADDR, &done);
-	} while ((done & BUSY_MASK) && wait--);
-
-	if (done & BUSY_MASK) {
-		netdev_err(pdata->ndev, "MII_MGMT write failed\n");
-		return -EBUSY;
-	}
-
-	return 0;
-}
-
-static int xgene_mii_phy_read(struct xgene_enet_pdata *pdata,
-			      u8 phy_id, u32 reg)
-{
-	u32 addr = 0;
-	u32 data, done;
-	u8 wait = 10;
-
-	PHY_ADDR_SET(&addr, phy_id);
-	REG_ADDR_SET(&addr, reg);
-	xgene_enet_wr_mcx_mac(pdata, MII_MGMT_ADDRESS_ADDR, addr);
-	xgene_enet_wr_mcx_mac(pdata, MII_MGMT_COMMAND_ADDR, READ_CYCLE_MASK);
-	do {
-		usleep_range(5, 10);
-		xgene_enet_rd_mcx_mac(pdata, MII_MGMT_INDICATORS_ADDR, &done);
-	} while ((done & BUSY_MASK) && wait--);
-
-	if (done & BUSY_MASK) {
-		netdev_err(pdata->ndev, "MII_MGMT read failed\n");
-		return -EBUSY;
-	}
-
-	xgene_enet_rd_mcx_mac(pdata, MII_MGMT_STATUS_ADDR, &data);
-	xgene_enet_wr_mcx_mac(pdata, MII_MGMT_COMMAND_ADDR, 0);
-
-	return data;
-}
-
 static void xgene_gmac_set_mac_addr(struct xgene_enet_pdata *pdata)
 {
 	u32 addr0, addr1;
@@ -762,28 +709,6 @@ static void xgene_gport_shutdown(struct xgene_enet_pdata *pdata)
 	}
 }
 
-static int xgene_enet_mdio_read(struct mii_bus *bus, int mii_id, int regnum)
-{
-	struct xgene_enet_pdata *pdata = bus->priv;
-	u32 val;
-
-	val = xgene_mii_phy_read(pdata, mii_id, regnum);
-	netdev_dbg(pdata->ndev, "mdio_rd: bus=%d reg=%d val=%x\n",
-		   mii_id, regnum, val);
-
-	return val;
-}
-
-static int xgene_enet_mdio_write(struct mii_bus *bus, int mii_id, int regnum,
-				 u16 val)
-{
-	struct xgene_enet_pdata *pdata = bus->priv;
-
-	netdev_dbg(pdata->ndev, "mdio_wr: bus=%d reg=%d val=%x\n",
-		   mii_id, regnum, val);
-	return xgene_mii_phy_write(pdata, mii_id, regnum, val);
-}
-
 static void xgene_enet_adjust_link(struct net_device *ndev)
 {
 	struct xgene_enet_pdata *pdata = netdev_priv(ndev);
@@ -888,8 +813,8 @@ static int xgene_mdiobus_register(struct xgene_enet_pdata *pdata,
 	struct phy_device *phy;
 	struct device_node *child_np;
 	struct device_node *mdio_np = NULL;
+	u32 phy_addr;
 	int ret;
-	u32 phy_id;
 
 	if (dev->of_node) {
 		for_each_child_of_node(dev->of_node, child_np) {
@@ -916,21 +841,17 @@ static int xgene_mdiobus_register(struct xgene_enet_pdata *pdata,
 	if (ret)
 		return ret;
 
-	ret = device_property_read_u32(dev, "phy-channel", &phy_id);
+	ret = device_property_read_u32(dev, "phy-channel", &phy_addr);
 	if (ret)
-		ret = device_property_read_u32(dev, "phy-addr", &phy_id);
+		ret = device_property_read_u32(dev, "phy-addr", &phy_addr);
 	if (ret)
 		return -EINVAL;
 
-	phy = get_phy_device(mdio, phy_id, false);
-	if (IS_ERR(phy))
+	phy = xgene_enet_phy_register(mdio, phy_addr);
+	if (!phy)
 		return -EIO;
 
-	ret = phy_device_register(phy);
-	if (ret)
-		phy_device_free(phy);
-	else
-		pdata->phy_dev = phy;
+	pdata->phy_dev = phy;
 
 	return ret;
 }
@@ -946,12 +867,12 @@ int xgene_enet_mdio_config(struct xgene_enet_pdata *pdata)
 		return -ENOMEM;
 
 	mdio_bus->name = "APM X-Gene MDIO bus";
-	mdio_bus->read = xgene_enet_mdio_read;
-	mdio_bus->write = xgene_enet_mdio_write;
+	mdio_bus->read = xgene_mdio_rgmii_read;
+	mdio_bus->write = xgene_mdio_rgmii_write;
 	snprintf(mdio_bus->id, MII_BUS_ID_SIZE, "%s-%s", "xgene-mii",
 		 ndev->name);
 
-	mdio_bus->priv = pdata;
+	mdio_bus->priv = (void __force *)pdata->mcx_mac_addr;
 	mdio_bus->parent = &pdata->pdev->dev;
 
 	ret = xgene_mdiobus_register(pdata, mdio_bus);
-- 
1.9.1
