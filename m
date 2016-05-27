From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH v1 2/6] drivers: net: xgene: Backward compatibility with older firmware
Date: Fri, 27 May 2016 00:22:44 -0700
Message-ID: <1464333768-26150-3-git-send-email-isubramanian@apm.com>
References: <1464333768-26150-1-git-send-email-isubramanian@apm.com>
Cc: linux-arm-kernel@lists.infradead.org, patches@apm.com,
	Iyappan Subramanian <isubramanian@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	devicetree@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:36456 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754687AbcE0HXJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 May 2016 03:23:09 -0400
Received: by mail-pa0-f45.google.com with SMTP id eu11so28467388pad.3
        for <netdev@vger.kernel.org>; Fri, 27 May 2016 00:23:08 -0700 (PDT)
In-Reply-To: <1464333768-26150-1-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch looks for CONFIG_MDIO_XGENE and based on phy-handle DT/ACPI
fields, sets the mdio_driver flag.  The rest of the driver uses the
this flag for any MDIO management, in the case of backward compatibility.
Also, some code clean up done around mdio configuration/remove.

Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
Tested-by: Fushen Chen <fchen@apm.com>
Tested-by: Toan Le <toanle@apm.com>
---
 drivers/net/ethernet/apm/xgene/xgene_enet_hw.c    |  59 +++-----
 drivers/net/ethernet/apm/xgene/xgene_enet_main.c  | 166 +++++++++++++++-------
 drivers/net/ethernet/apm/xgene/xgene_enet_main.h  |   2 +
 drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.c |  13 +-
 4 files changed, 149 insertions(+), 91 deletions(-)

diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
index 6bc8360..38d6ee4 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
@@ -476,9 +476,13 @@ static void xgene_gmac_reset(struct xgene_enet_pdata *pdata)
 static void xgene_enet_configure_clock(struct xgene_enet_pdata *pdata)
 {
 	struct device *dev = &pdata->pdev->dev;
+	struct clk *parent;
 
 	if (dev->of_node) {
-		struct clk *parent = clk_get_parent(pdata->clk);
+		if (IS_ERR(pdata->clk))
+			return;
+
+		parent = clk_get_parent(pdata->clk);
 
 		switch (pdata->phy_speed) {
 		case SPEED_10:
@@ -572,6 +576,9 @@ static void xgene_gmac_init(struct xgene_enet_pdata *pdata)
 {
 	u32 value;
 
+	if (!pdata->mdio_driver)
+		xgene_gmac_reset(pdata);
+
 	xgene_gmac_set_speed(pdata);
 	xgene_gmac_set_mac_addr(pdata);
 
@@ -677,6 +684,14 @@ static int xgene_enet_reset(struct xgene_enet_pdata *pdata)
 	if (!xgene_ring_mgr_init(pdata))
 		return -ENODEV;
 
+	if (!pdata->mdio_driver) {
+		if (!IS_ERR(pdata->clk)) {
+			clk_prepare_enable(pdata->clk);
+			clk_disable_unprepare(pdata->clk);
+			clk_prepare_enable(pdata->clk);
+			xgene_enet_ecc_init(pdata);
+		}
+	}
 	xgene_enet_config_ring_if_assoc(pdata);
 
 	return 0;
@@ -799,27 +814,9 @@ static int xgene_mdiobus_register(struct xgene_enet_pdata *pdata,
 				  struct mii_bus *mdio)
 {
 	struct device *dev = &pdata->pdev->dev;
-	struct device_node *mdio_np = NULL;
-	struct device_node *child_np;
-	u32 phyid;
 
 	if (dev->of_node) {
-		for_each_child_of_node(dev->of_node, child_np) {
-			if (of_device_is_compatible(child_np,
-						    "apm,xgene-mdio")) {
-				mdio_np = child_np;
-				break;
-			}
-		}
-
-		if (!mdio_np) {
-			mdiobus_free(mdio);
-			return 0;
-		}
-
-		pdata->mdio_driver = false;
-
-		return of_mdiobus_register(mdio, mdio_np);
+		return of_mdiobus_register(mdio, pdata->mdio_np);
 	} else {
 #ifdef CONFIG_ACPI
 		struct phy_device *phy;
@@ -838,13 +835,7 @@ static int xgene_mdiobus_register(struct xgene_enet_pdata *pdata,
 		if (ret)
 			return ret;
 
-		ret = device_property_read_u32(dev, "phy-channel", &phyid);
-		if (ret)
-			ret = device_property_read_u32(dev, "phy-addr", &phyid);
-		if (ret)
-			return -EINVAL;
-
-		phy = get_phy_device(mdio, phy_id, false);
+		phy = get_phy_device(mdio, pdata->phy_id, false);
 		if (IS_ERR(phy))
 			return -EIO;
 
@@ -857,6 +848,8 @@ static int xgene_mdiobus_register(struct xgene_enet_pdata *pdata,
 		return ret;
 #endif
 	}
+
+	return 0;
 }
 
 int xgene_enet_mdio_config(struct xgene_enet_pdata *pdata)
@@ -884,10 +877,6 @@ int xgene_enet_mdio_config(struct xgene_enet_pdata *pdata)
 		if (mdio_bus->state == MDIOBUS_REGISTERED)
 			mdiobus_unregister(pdata->mdio_bus);
 		mdiobus_free(mdio_bus);
-		if (pdata->mdio_driver) {
-			ret = xgene_enet_phy_connect(ndev);
-			return 0;
-		}
 		return ret;
 	}
 	pdata->mdio_bus = mdio_bus;
@@ -910,11 +899,9 @@ void xgene_enet_mdio_remove(struct xgene_enet_pdata *pdata)
 	if (pdata->phy_dev)
 		phy_disconnect(pdata->phy_dev);
 
-	if (!pdata->mdio_driver) {
-		mdiobus_unregister(pdata->mdio_bus);
-		mdiobus_free(pdata->mdio_bus);
-		pdata->mdio_bus = NULL;
-	}
+	mdiobus_unregister(pdata->mdio_bus);
+	mdiobus_free(pdata->mdio_bus);
+	pdata->mdio_bus = NULL;
 }
 
 const struct xgene_mac_ops xgene_gmac_ops = {
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
index c698044..c31ea56 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
@@ -1182,31 +1182,27 @@ static const struct net_device_ops xgene_ndev_ops = {
 
 #ifdef CONFIG_ACPI
 static void xgene_get_port_id_acpi(struct device *dev,
-				  struct xgene_enet_pdata *pdata)
+				   struct xgene_enet_pdata *pdata)
 {
 	acpi_status status;
 	u64 temp;
 
 	status = acpi_evaluate_integer(ACPI_HANDLE(dev), "_SUN", NULL, &temp);
-	if (ACPI_FAILURE(status)) {
+	if (ACPI_FAILURE(status))
 		pdata->port_id = 0;
-	} else {
+	else
 		pdata->port_id = temp;
-	}
-
-	return;
 }
 #endif
 
-static void xgene_get_port_id_dt(struct device *dev, struct xgene_enet_pdata *pdata)
+static void xgene_get_port_id_dt(struct device *dev,
+				 struct xgene_enet_pdata *pdata)
 {
 	u32 id = 0;
 
 	of_property_read_u32(dev->of_node, "port-id", &id);
 
 	pdata->port_id = id & BIT(0);
-
-	return;
 }
 
 static int xgene_get_tx_delay(struct xgene_enet_pdata *pdata)
@@ -1284,6 +1280,86 @@ static int xgene_enet_get_irqs(struct xgene_enet_pdata *pdata)
 	return 0;
 }
 
+static int xgene_enet_check_phy_handle(struct xgene_enet_pdata *pdata)
+{
+	struct device *dev = &pdata->pdev->dev;
+	int ret, phy_id, phy_mode = pdata->phy_mode;
+	struct device_node *mdio_np = NULL;
+	const char *ph;
+#ifdef CONFIG_ACPI
+	struct acpi_reference_args args;
+	struct fwnode_handle *fw_node;
+#endif
+
+	if (!IS_ENABLED(CONFIG_MDIO_XGENE))
+		return 0;
+
+	if (dev->of_node) {
+		ret = device_property_read_string(dev, "phy-handle", &ph);
+
+		if (phy_mode == PHY_INTERFACE_MODE_RGMII) {
+			if (ret) {
+				dev_err(dev, "Unable to get phy-handle\n");
+				return ret;
+			}
+
+			mdio_np = of_find_compatible_node(dev->of_node, NULL,
+							  "apm,xgene-mdio");
+			if (!mdio_np)
+				pdata->mdio_driver = true;
+			else
+				pdata->mdio_np = mdio_np;
+		} else {
+			if (!ret)
+				pdata->mdio_driver = true;
+		}
+	} else {
+#ifdef CONFIG_ACPI
+		fw_node = acpi_fwnode_handle(ACPI_COMPANION(dev));
+		ret = acpi_node_get_property_reference(fw_node, "mboxes", 0,
+						       &args);
+		if (!ACPI_FAILURE(ret)) {
+			pdata->mdio_driver = true;
+			pdata->phy_dev =  args.adev->driver_data;
+		} else {
+			ret = device_property_read_u32(dev, "phy-channel",
+						       &phy_id);
+			if (ret) {
+				ret = device_property_read_u32(dev, "phy-addr",
+							       &phy_id);
+			}
+
+			if (!ret)
+				pdata->phy_id = phy_id;
+		}
+#endif
+	}
+
+	return 0;
+}
+
+static int xgene_enet_get_clk(struct xgene_enet_pdata *pdata)
+{
+	struct device *dev = &pdata->pdev->dev;
+
+	if (!dev->of_node)
+		return 0;
+
+	pdata->clk = devm_clk_get(dev, NULL);
+	if (IS_ERR(pdata->clk)) {
+		if (pdata->phy_mode == PHY_INTERFACE_MODE_RGMII) {
+			dev_err(dev, "Unable to get clock\n");
+			return -ENODEV;
+		} else {
+			/* Firmware may have set up the clock already. */
+			dev_info(dev, "clocks have been setup already\n");
+			pdata->clk = NULL;
+		}
+	}
+
+	return 0;
+}
+
 static int xgene_enet_get_resources(struct xgene_enet_pdata *pdata)
 {
 	struct platform_device *pdev;
@@ -1292,7 +1368,6 @@ static int xgene_enet_get_resources(struct xgene_enet_pdata *pdata)
 	struct resource *res;
 	void __iomem *base_addr;
 	u32 offset;
-	const char *ph;
 	int ret = 0;
 
 	pdev = pdata->pdev;
@@ -1370,15 +1445,13 @@ static int xgene_enet_get_resources(struct xgene_enet_pdata *pdata)
 	if (ret)
 		return ret;
 
-	ret = device_property_read_string(dev, "phy-handle", &ph);
-	if (!ret)
-		pdata->mdio_driver = true;
+	ret = xgene_enet_check_phy_handle(pdata);
+	if (ret)
+		return ret;
 
-	pdata->clk = devm_clk_get(&pdev->dev, NULL);
-	if (IS_ERR(pdata->clk)) {
-		/* Firmware may have set up the clock already. */
-		dev_info(dev, "clocks have been setup already\n");
-	}
+	ret = xgene_enet_get_clk(pdata);
+	if (ret)
+		return ret;
 
 	if ((pdata->phy_mode != PHY_INTERFACE_MODE_XGMII) &&
 	    (pdata->enet_id == XGENE_ENET1))
@@ -1434,8 +1507,6 @@ static int xgene_enet_init_hw(struct xgene_enet_pdata *pdata)
 		}
 	}
 
-	dst_ring_num = xgene_enet_dst_ring_num(pdata->rx_ring[0]);
-	buf_pool = pdata->rx_ring[0]->buf_pool;
 	if (pdata->phy_mode == PHY_INTERFACE_MODE_XGMII) {
 		/* Initialize and Enable  PreClassifier Tree */
 		enet_cle->max_nodes = 512;
@@ -1451,9 +1522,12 @@ static int xgene_enet_init_hw(struct xgene_enet_pdata *pdata)
 			return ret;
 		}
 	} else {
+		dst_ring_num = xgene_enet_dst_ring_num(pdata->rx_ring[0]);
+		buf_pool = pdata->rx_ring[0]->buf_pool;
 		pdata->port_ops->cle_bypass(pdata, dst_ring_num, buf_pool->id);
 	}
 
+	pdata->phy_speed = SPEED_UNKNOWN;
 	pdata->mac_ops->init(pdata);
 
 	return ret;
@@ -1563,22 +1637,6 @@ static void xgene_enet_napi_add(struct xgene_enet_pdata *pdata)
 	}
 }
 
-static void xgene_enet_napi_del(struct xgene_enet_pdata *pdata)
-{
-	struct napi_struct *napi;
-	int i;
-
-	for (i = 0; i < pdata->rxq_cnt; i++) {
-		napi = &pdata->rx_ring[i]->napi;
-		netif_napi_del(napi);
-	}
-
-	for (i = 0; i < pdata->cq_cnt; i++) {
-		napi = &pdata->tx_ring[i]->cp_ring->napi;
-		netif_napi_del(napi);
-	}
-}
-
 static int xgene_enet_probe(struct platform_device *pdev)
 {
 	struct net_device *ndev;
@@ -1609,10 +1667,10 @@ static int xgene_enet_probe(struct platform_device *pdev)
 	of_id = of_match_device(xgene_enet_of_match, &pdev->dev);
 	if (of_id) {
 		pdata->enet_id = (enum xgene_enet_id)of_id->data;
-	}
-	else {
+	} else {
 #ifdef CONFIG_ACPI
 		const struct acpi_device_id *acpi_id;
+		enum xgene_enet_id enet_id;
 
 		acpi_id = acpi_match_device(xgene_enet_acpi_match, &pdev->dev);
 		if (acpi_id) {
@@ -1621,6 +1679,7 @@ static int xgene_enet_probe(struct platform_device *pdev)
 		}
 #endif
 	}
+
 	if (!pdata->enet_id) {
 		free_netdev(ndev);
 		return -ENODEV;
@@ -1655,23 +1714,25 @@ static int xgene_enet_probe(struct platform_device *pdev)
 		goto err_netdev;
 
 	link_state = pdata->mac_ops->link_state;
-	if (pdata->phy_mode == PHY_INTERFACE_MODE_RGMII) {
-		ret = xgene_enet_mdio_config(pdata);
-		if (ret)
-			goto err_netdev;
-	} else if (pdata->phy_mode == PHY_INTERFACE_MODE_SGMII) {
+	ret = 0;
+	if (pdata->phy_mode == PHY_INTERFACE_MODE_XGMII) {
+		INIT_DELAYED_WORK(&pdata->link_work, link_state);
+	} else {
 		if (pdata->mdio_driver)
 			ret = xgene_enet_phy_connect(ndev);
+		else if (pdata->phy_mode == PHY_INTERFACE_MODE_RGMII)
+			ret = xgene_enet_mdio_config(pdata);
 		else
 			INIT_DELAYED_WORK(&pdata->link_work, link_state);
-	} else {
-		INIT_DELAYED_WORK(&pdata->link_work, link_state);
 	}
+	if (ret)
+		goto err;
 
 	xgene_enet_napi_add(pdata);
 	return 0;
 err_netdev:
-	unregister_netdev(ndev);
+	if (ndev->reg_state == NETREG_REGISTERED)
+		unregister_netdev(ndev);
 err:
 	free_netdev(ndev);
 	return ret;
@@ -1690,11 +1751,16 @@ static int xgene_enet_remove(struct platform_device *pdev)
 	mac_ops->rx_disable(pdata);
 	mac_ops->tx_disable(pdata);
 
-	xgene_enet_napi_del(pdata);
-	if (pdata->phy_mode == PHY_INTERFACE_MODE_RGMII)
-		xgene_enet_mdio_remove(pdata);
-	else if (pdata->phy_mode == PHY_INTERFACE_MODE_SGMII)
+	rtnl_lock();
+	if (netif_running(ndev))
+		dev_close(ndev);
+	rtnl_unlock();
+
+	if (pdata->mdio_driver)
 		xgene_enet_phy_disconnect(pdata);
+	else if (pdata->phy_mode == PHY_INTERFACE_MODE_RGMII)
+		xgene_enet_mdio_remove(pdata);
+
 	unregister_netdev(ndev);
 	xgene_enet_delete_desc_rings(pdata);
 	pdata->port_ops->shutdown(pdata);
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.h b/drivers/net/ethernet/apm/xgene/xgene_enet_main.h
index 0fe1a96..c2804c2 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_main.h
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.h
@@ -212,6 +212,8 @@ struct xgene_enet_pdata {
 	u32 mss;
 	u8 tx_delay;
 	u8 rx_delay;
+	struct device_node *mdio_np;
+	int phy_id;
 	bool mdio_driver;
 };
 
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.c b/drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.c
index 6d53de4..c078cd6 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.c
@@ -257,9 +257,7 @@ static void xgene_sgmac_set_speed(struct xgene_enet_pdata *p)
 	u32 mc2, value;
 
 	if (p->phy_speed != SPEED_UNKNOWN) {
-		value = xgene_mii_phy_read(p, INT_PHY_ADDR,
-					   SGMII_BASE_PAGE_ABILITY_ADDR >> 2);
-		if (!(value & LINK_UP)) {
+		if (!xgene_enet_link_status(p)) {
 			xgene_mii_phy_write(p, INT_PHY_ADDR,
 					    SGMII_TBI_CONTROL_ADDR >> 2,
 					    0x8000);
@@ -325,7 +323,8 @@ static void xgene_sgmac_init(struct xgene_enet_pdata *p)
 	u32 enet_spare_cfg_reg, rsif_config_reg;
 	u32 cfg_bypass_reg, rx_dv_gate_reg;
 
-	xgene_sgmac_reset(p);
+	if (!(p->enet_id == XGENE_ENET2 && p->mdio_driver))
+		xgene_sgmac_reset(p);
 
 	/* Enable auto-negotiation */
 	xgene_mii_phy_write(p, INT_PHY_ADDR, SGMII_TBI_CONTROL_ADDR >> 2,
@@ -416,6 +415,8 @@ static void xgene_sgmac_tx_disable(struct xgene_enet_pdata *p)
 
 static int xgene_enet_reset(struct xgene_enet_pdata *p)
 {
+	int ret;
+
 	if (!xgene_ring_mgr_init(p))
 		return -ENODEV;
 
@@ -428,7 +429,9 @@ static int xgene_enet_reset(struct xgene_enet_pdata *p)
 		clk_prepare_enable(p->clk);
 	}
 
-	xgene_enet_ecc_init(p);
+	ret = xgene_enet_ecc_init(p);
+	if (ret)
+		return ret;
 	xgene_enet_config_ring_if_assoc(p);
 
 	return 0;
-- 
1.9.1
