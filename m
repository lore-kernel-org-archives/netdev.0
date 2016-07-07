From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH v5 06/11] drivers: net: xgene: Add backward compatibility
Date: Thu,  7 Jul 2016 16:02:54 -0700
Message-ID: <1467932579-14320-7-git-send-email-isubramanian@apm.com>
References: <1467932579-14320-1-git-send-email-isubramanian@apm.com>
Cc: linux-arm-kernel@lists.infradead.org, patches@apm.com,
	matthias.bgg@gmail.com, andrew@lunn.ch, linux@armlinux.org.uk,
	Iyappan Subramanian <isubramanian@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	devicetree@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:36345 "EHLO
	mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753406AbcGGXDB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jul 2016 19:03:01 -0400
Received: by mail-pf0-f169.google.com with SMTP id t190so9971543pfb.3
        for <netdev@vger.kernel.org>; Thu, 07 Jul 2016 16:03:01 -0700 (PDT)
In-Reply-To: <1467932579-14320-1-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds xgene_enet_check_phy_hanlde() function that checks whether
MDIO driver is probed successfully and sets pdata->mdio_driver to true.
If MDIO driver is not probed, ethernet driver falls back to backward
compatibility mode.

Since enum xgene_enet_cmd is used by MDIO driver, removing this from
ethernet driver.

Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
Tested-by: Fushen Chen <fchen@apm.com>
Tested-by: Toan Le <toanle@apm.com>
Tested-by: Matthias Brugger <mbrugger@suse.com>
---
 drivers/net/ethernet/apm/xgene/xgene_enet_hw.c    | 46 +++++++++++++++++++-
 drivers/net/ethernet/apm/xgene/xgene_enet_hw.h    |  7 +---
 drivers/net/ethernet/apm/xgene/xgene_enet_main.c  | 51 +++++++++++++++++++----
 drivers/net/ethernet/apm/xgene/xgene_enet_main.h  | 30 +------------
 drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.c |  9 +++-
 5 files changed, 99 insertions(+), 44 deletions(-)

diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
index 91a67a0..8410ff8 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
@@ -572,7 +572,9 @@ static void xgene_gmac_init(struct xgene_enet_pdata *pdata)
 {
 	u32 value;
 
-	xgene_gmac_reset(pdata);
+	if (!pdata->mdio_driver)
+		xgene_gmac_reset(pdata);
+
 	xgene_gmac_set_speed(pdata);
 	xgene_gmac_set_mac_addr(pdata);
 
@@ -680,6 +682,11 @@ static int xgene_enet_reset(struct xgene_enet_pdata *pdata)
 	if (!xgene_ring_mgr_init(pdata))
 		return -ENODEV;
 
+	if (pdata->mdio_driver) {
+		xgene_enet_config_ring_if_assoc(pdata);
+		return 0;
+	}
+
 	if (dev->of_node) {
 		clk_prepare_enable(pdata->clk);
 		udelay(5);
@@ -799,7 +806,26 @@ static void xgene_enet_adjust_link(struct net_device *ndev)
 	}
 }
 
-static int xgene_enet_phy_connect(struct net_device *ndev)
+#ifdef CONFIG_ACPI
+static struct acpi_device *acpi_phy_find_device(struct device *dev)
+{
+	struct acpi_reference_args args;
+	struct fwnode_handle *fw_node;
+	int status;
+
+	fw_node = acpi_fwnode_handle(ACPI_COMPANION(dev));
+	status = acpi_node_get_property_reference(fw_node, "phy-handle", 0,
+						  &args);
+	if (ACPI_FAILURE(status)) {
+		dev_dbg(dev, "No matching phy in ACPI table\n");
+		return NULL;
+	}
+
+	return args.adev;
+}
+#endif
+
+int xgene_enet_phy_connect(struct net_device *ndev)
 {
 	struct xgene_enet_pdata *pdata = netdev_priv(ndev);
 	struct device_node *phy_np;
@@ -822,6 +848,15 @@ static int xgene_enet_phy_connect(struct net_device *ndev)
 
 		pdata->phy_dev = phy_dev;
 	} else {
+#ifdef CONFIG_ACPI
+		if (pdata->mdio_driver) {
+			struct acpi_device *adev;
+
+			adev = acpi_phy_find_device(dev);
+			if (adev)
+				pdata->phy_dev =  adev->driver_data;
+		}
+
 		phy_dev = pdata->phy_dev;
 
 		if (!phy_dev ||
@@ -830,6 +865,7 @@ static int xgene_enet_phy_connect(struct net_device *ndev)
 			netdev_err(ndev, "Could not connect to PHY\n");
 			return  -ENODEV;
 		}
+#endif
 	}
 
 	pdata->phy_speed = SPEED_UNKNOWN;
@@ -930,6 +966,12 @@ int xgene_enet_mdio_config(struct xgene_enet_pdata *pdata)
 	return ret;
 }
 
+void xgene_enet_phy_disconnect(struct xgene_enet_pdata *pdata)
+{
+	if (pdata->phy_dev)
+		phy_disconnect(pdata->phy_dev);
+}
+
 void xgene_enet_mdio_remove(struct xgene_enet_pdata *pdata)
 {
 	if (pdata->phy_dev)
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.h b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.h
index eec55c1..179a44d 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.h
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.h
@@ -301,11 +301,6 @@ enum xgene_enet_ring_bufnum {
 	RING_BUFNUM_INVALID
 };
 
-enum xgene_enet_cmd {
-	XGENE_ENET_WR_CMD = BIT(31),
-	XGENE_ENET_RD_CMD = BIT(30)
-};
-
 enum xgene_enet_err_code {
 	HBF_READ_DATA = 3,
 	HBF_LL_READ = 4,
@@ -351,6 +346,8 @@ void xgene_enet_parse_error(struct xgene_enet_desc_ring *ring,
 int xgene_enet_mdio_config(struct xgene_enet_pdata *pdata);
 void xgene_enet_mdio_remove(struct xgene_enet_pdata *pdata);
 bool xgene_ring_mgr_init(struct xgene_enet_pdata *p);
+int xgene_enet_phy_connect(struct net_device *ndev);
+void xgene_enet_phy_disconnect(struct xgene_enet_pdata *pdata);
 
 extern const struct xgene_mac_ops xgene_gmac_ops;
 extern const struct xgene_port_ops xgene_gport_ops;
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
index 87e5929..a8693de 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
@@ -1295,6 +1295,29 @@ static int xgene_enet_get_irqs(struct xgene_enet_pdata *pdata)
 	return 0;
 }
 
+static int xgene_enet_check_phy_handle(struct xgene_enet_pdata *pdata)
+{
+	struct device *dev = &pdata->pdev->dev;
+	int ret;
+
+	if (pdata->phy_mode == PHY_INTERFACE_MODE_XGMII)
+		return 0;
+
+	if (!IS_ENABLED(CONFIG_MDIO_XGENE))
+		return 0;
+
+	if (xgene_mdio_probe_successful()) {
+		ret = device_property_present(dev, "phy-handle");
+		if (!ret) {
+			dev_err(dev, "Unable to find phy-handle\n");
+			return -1;
+		}
+		pdata->mdio_driver = true;
+	}
+
+	return 0;
+}
+
 static int xgene_enet_get_resources(struct xgene_enet_pdata *pdata)
 {
 	struct platform_device *pdev;
@@ -1380,6 +1403,10 @@ static int xgene_enet_get_resources(struct xgene_enet_pdata *pdata)
 	if (ret)
 		return ret;
 
+	ret = xgene_enet_check_phy_handle(pdata);
+	if (ret)
+		return ret;
+
 	pdata->clk = devm_clk_get(&pdev->dev, NULL);
 	if (IS_ERR(pdata->clk)) {
 		/* Firmware may have set up the clock already. */
@@ -1574,7 +1601,7 @@ static int xgene_enet_probe(struct platform_device *pdev)
 	struct net_device *ndev;
 	struct xgene_enet_pdata *pdata;
 	struct device *dev = &pdev->dev;
-	const struct xgene_mac_ops *mac_ops;
+	void (*link_state)(struct work_struct *);
 	const struct of_device_id *of_id;
 	int ret;
 
@@ -1636,14 +1663,19 @@ static int xgene_enet_probe(struct platform_device *pdev)
 	if (ret)
 		goto err_netdev;
 
-	mac_ops = pdata->mac_ops;
-	if (pdata->phy_mode == PHY_INTERFACE_MODE_RGMII) {
-		ret = xgene_enet_mdio_config(pdata);
-		if (ret)
-			goto err_netdev;
+	link_state = pdata->mac_ops->link_state;
+	if (pdata->phy_mode == PHY_INTERFACE_MODE_XGMII) {
+		INIT_DELAYED_WORK(&pdata->link_work, link_state);
 	} else {
-		INIT_DELAYED_WORK(&pdata->link_work, mac_ops->link_state);
+		if (pdata->mdio_driver)
+			ret = xgene_enet_phy_connect(ndev);
+		else if (pdata->phy_mode == PHY_INTERFACE_MODE_RGMII)
+			ret = xgene_enet_mdio_config(pdata);
+		else
+			INIT_DELAYED_WORK(&pdata->link_work, link_state);
 	}
+	if (ret)
+		goto err;
 
 	xgene_enet_napi_add(pdata);
 	ret = register_netdev(ndev);
@@ -1679,8 +1711,11 @@ static int xgene_enet_remove(struct platform_device *pdev)
 	mac_ops->rx_disable(pdata);
 	mac_ops->tx_disable(pdata);
 
-	if (pdata->phy_mode == PHY_INTERFACE_MODE_RGMII)
+	if (pdata->mdio_driver)
+		xgene_enet_phy_disconnect(pdata);
+	else if (pdata->phy_mode == PHY_INTERFACE_MODE_RGMII)
 		xgene_enet_mdio_remove(pdata);
+
 	unregister_netdev(ndev);
 	pdata->port_ops->shutdown(pdata);
 	xgene_enet_delete_desc_rings(pdata);
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.h b/drivers/net/ethernet/apm/xgene/xgene_enet_main.h
index 681a473..217546e 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_main.h
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.h
@@ -38,6 +38,7 @@
 #include "xgene_enet_hw.h"
 #include "xgene_enet_cle.h"
 #include "xgene_enet_ring2.h"
+#include "../../../phy/mdio-xgene.h"
 
 #define XGENE_DRV_VERSION	"v1.0"
 #define XGENE_ENET_MAX_MTU	1536
@@ -214,6 +215,7 @@ struct xgene_enet_pdata {
 	u32 mss;
 	u8 tx_delay;
 	u8 rx_delay;
+	bool mdio_driver;
 };
 
 struct xgene_indirect_ctl {
@@ -223,34 +225,6 @@ struct xgene_indirect_ctl {
 	void __iomem *cmd_done;
 };
 
-/* Set the specified value into a bit-field defined by its starting position
- * and length within a single u64.
- */
-static inline u64 xgene_enet_set_field_value(int pos, int len, u64 val)
-{
-	return (val & ((1ULL << len) - 1)) << pos;
-}
-
-#define SET_VAL(field, val) \
-		xgene_enet_set_field_value(field ## _POS, field ## _LEN, val)
-
-#define SET_BIT(field) \
-		xgene_enet_set_field_value(field ## _POS, 1, 1)
-
-/* Get the value from a bit-field defined by its starting position
- * and length within the specified u64.
- */
-static inline u64 xgene_enet_get_field_value(int pos, int len, u64 src)
-{
-	return (src >> pos) & ((1ULL << len) - 1);
-}
-
-#define GET_VAL(field, src) \
-		xgene_enet_get_field_value(field ## _POS, field ## _LEN, src)
-
-#define GET_BIT(field, src) \
-		xgene_enet_get_field_value(field ## _POS, 1, src)
-
 static inline struct device *ndev_to_dev(struct net_device *ndev)
 {
 	return ndev->dev.parent;
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.c b/drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.c
index 224e216..6fdbb22 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.c
@@ -364,7 +364,9 @@ static void xgene_sgmac_init(struct xgene_enet_pdata *p)
 	u32 cfg_bypass_reg, rx_dv_gate_reg;
 	u32 data, offset;
 
-	xgene_sgmac_reset(p);
+	if (!(p->enet_id == XGENE_ENET2 && p->mdio_driver))
+		xgene_sgmac_reset(p);
+
 	xgene_sgmii_enable_autoneg(p);
 	xgene_sgmac_set_speed(p);
 	xgene_sgmac_set_mac_addr(p);
@@ -443,6 +445,11 @@ static int xgene_enet_reset(struct xgene_enet_pdata *p)
 	if (!xgene_ring_mgr_init(p))
 		return -ENODEV;
 
+	if (p->mdio_driver && p->enet_id == XGENE_ENET2) {
+		xgene_enet_config_ring_if_assoc(p);
+		return 0;
+	}
+
 	if (p->enet_id == XGENE_ENET2)
 		xgene_enet_wr_clkrst_csr(p, XGENET_CONFIG_REG_ADDR, SGMII_EN);
 
-- 
1.9.1
