From: Timur Tabi <timur@codeaurora.org>
Subject: [PATCH 3/3] [v2] net: qcom/emac: initial ACPI support
Date: Wed, 28 Sep 2016 11:58:44 -0500
Message-ID: <1475081924-12362-4-git-send-email-timur@codeaurora.org>
References: <1475081924-12362-1-git-send-email-timur@codeaurora.org>
To: netdev@vger.kernel.org, linaro-acpi@lists.linaro.org,
        linux-arm-kernel@lists.infradead.org, shankerd@codeaurora.org,
        vikrams@codeaurora.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:53691 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932797AbcI1Q6v (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Sep 2016 12:58:51 -0400
In-Reply-To: <1475081924-12362-1-git-send-email-timur@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for reading addresses, interrupts, and _DSD properties
from ACPI tables, just like with device tree.  The HID for the
EMAC device itself is QCOM8070.  The internal PHY is represented
by a child node with a HID of QCOM8071.

The EMAC also has some complex clock initialization requirements
that are not represented by this patch.  This will be addressed
in a future patch.

Signed-off-by: Timur Tabi <timur@codeaurora.org>
---
 drivers/net/ethernet/qualcomm/emac/emac-phy.c   | 37 ++++++++++---
 drivers/net/ethernet/qualcomm/emac/emac-sgmii.c | 72 ++++++++++++++++++-------
 drivers/net/ethernet/qualcomm/emac/emac.c       | 12 +++++
 3 files changed, 95 insertions(+), 26 deletions(-)

diff --git a/drivers/net/ethernet/qualcomm/emac/emac-phy.c b/drivers/net/ethernet/qualcomm/emac/emac-phy.c
index c412ba9..da4e90d 100644
--- a/drivers/net/ethernet/qualcomm/emac/emac-phy.c
+++ b/drivers/net/ethernet/qualcomm/emac/emac-phy.c
@@ -19,6 +19,7 @@
 #include <linux/of_mdio.h>
 #include <linux/phy.h>
 #include <linux/iopoll.h>
+#include <linux/acpi.h>
 #include "emac.h"
 #include "emac-mac.h"
 #include "emac-phy.h"
@@ -167,7 +168,6 @@ static int emac_mdio_write(struct mii_bus *bus, int addr, int regnum, u16 val)
 int emac_phy_config(struct platform_device *pdev, struct emac_adapter *adpt)
 {
 	struct device_node *np = pdev->dev.of_node;
-	struct device_node *phy_np;
 	struct mii_bus *mii_bus;
 	int ret;
 
@@ -183,14 +183,37 @@ int emac_phy_config(struct platform_device *pdev, struct emac_adapter *adpt)
 	mii_bus->parent = &pdev->dev;
 	mii_bus->priv = adpt;
 
-	ret = of_mdiobus_register(mii_bus, np);
-	if (ret) {
-		dev_err(&pdev->dev, "could not register mdio bus\n");
-		return ret;
+	if (has_acpi_companion(&pdev->dev)) {
+		u32 phy_addr;
+
+		ret = mdiobus_register(mii_bus);
+		if (ret) {
+			dev_err(&pdev->dev, "could not register mdio bus\n");
+			return ret;
+		}
+		ret = device_property_read_u32(&pdev->dev, "phy-channel",
+					       &phy_addr);
+		if (ret)
+			/* If we can't read a valid phy address, then assume
+			 * that there is only one phy on this mdio bus.
+			 */
+			adpt->phydev = phy_find_first(mii_bus);
+		else
+			adpt->phydev = mdiobus_get_phy(mii_bus, phy_addr);
+
+	} else {
+		struct device_node *phy_np;
+
+		ret = of_mdiobus_register(mii_bus, np);
+		if (ret) {
+			dev_err(&pdev->dev, "could not register mdio bus\n");
+			return ret;
+		}
+
+		phy_np = of_parse_phandle(np, "phy-handle", 0);
+		adpt->phydev = of_phy_find_device(phy_np);
 	}
 
-	phy_np = of_parse_phandle(np, "phy-handle", 0);
-	adpt->phydev = of_phy_find_device(phy_np);
 	if (!adpt->phydev) {
 		dev_err(&pdev->dev, "could not find external phy\n");
 		mdiobus_unregister(mii_bus);
diff --git a/drivers/net/ethernet/qualcomm/emac/emac-sgmii.c b/drivers/net/ethernet/qualcomm/emac/emac-sgmii.c
index ad0e420..3d2c05a 100644
--- a/drivers/net/ethernet/qualcomm/emac/emac-sgmii.c
+++ b/drivers/net/ethernet/qualcomm/emac/emac-sgmii.c
@@ -14,6 +14,7 @@
  */
 
 #include <linux/iopoll.h>
+#include <linux/acpi.h>
 #include <linux/of_device.h>
 #include "emac.h"
 #include "emac-mac.h"
@@ -662,6 +663,24 @@ void emac_sgmii_reset(struct emac_adapter *adpt)
 	clk_set_rate(adpt->clk[EMAC_CLK_HIGH_SPEED], 125000000);
 }
 
+static int emac_sgmii_acpi_match(struct device *dev, void *data)
+{
+	static const struct acpi_device_id match_table[] = {
+		{
+			.id = "QCOM8071",
+			.driver_data = (kernel_ulong_t)emac_sgmii_init_v2,
+		},
+		{}
+	};
+	const struct acpi_device_id *id = acpi_match_device(match_table, dev);
+	emac_sgmii_initialize *initialize = data;
+
+	if (id)
+		*initialize = (emac_sgmii_initialize)id->driver_data;
+
+	return !!id;
+}
+
 static const struct of_device_id emac_sgmii_dt_match[] = {
 	{
 		.compatible = "qcom,fsm9900-emac-sgmii",
@@ -679,30 +698,45 @@ int emac_sgmii_config(struct platform_device *pdev, struct emac_adapter *adpt)
 	struct platform_device *sgmii_pdev = NULL;
 	struct emac_phy *phy = &adpt->phy;
 	struct resource *res;
-	const struct of_device_id *match;
-	struct device_node *np;
 	int ret;
 
-	np = of_parse_phandle(pdev->dev.of_node, "internal-phy", 0);
-	if (!np) {
-		dev_err(&pdev->dev, "missing internal-phy property\n");
-		return -ENODEV;
-	}
+	if (has_acpi_companion(&pdev->dev)) {
+		struct device *dev;
 
-	sgmii_pdev = of_find_device_by_node(np);
-	if (!sgmii_pdev) {
-		dev_err(&pdev->dev, "invalid internal-phy property\n");
-		return -ENODEV;
-	}
+		dev = device_find_child(&pdev->dev, &phy->initialize,
+					emac_sgmii_acpi_match);
 
-	match = of_match_device(emac_sgmii_dt_match, &sgmii_pdev->dev);
-	if (!match) {
-		dev_err(&pdev->dev, "unrecognized internal phy node\n");
-		ret = -ENODEV;
-		goto error_put_device;
-	}
+		if (!dev) {
+			dev_err(&pdev->dev, "cannot find internal phy node\n");
+			return -ENODEV;
+		}
 
-	phy->initialize = (emac_sgmii_initialize)match->data;
+		sgmii_pdev = to_platform_device(dev);
+	} else {
+		const struct of_device_id *match;
+		struct device_node *np;
+
+		np = of_parse_phandle(pdev->dev.of_node, "internal-phy", 0);
+		if (!np) {
+			dev_err(&pdev->dev, "missing internal-phy property\n");
+			return -ENODEV;
+		}
+
+		sgmii_pdev = of_find_device_by_node(np);
+		if (!sgmii_pdev) {
+			dev_err(&pdev->dev, "invalid internal-phy property\n");
+			return -ENODEV;
+		}
+
+		match = of_match_device(emac_sgmii_dt_match, &sgmii_pdev->dev);
+		if (!match) {
+			dev_err(&pdev->dev, "unrecognized internal phy node\n");
+			ret = -ENODEV;
+			goto error_put_device;
+		}
+
+		phy->initialize = (emac_sgmii_initialize)match->data;
+	}
 
 	/* Base address is the first address */
 	res = platform_get_resource(sgmii_pdev, IORESOURCE_MEM, 0);
diff --git a/drivers/net/ethernet/qualcomm/emac/emac.c b/drivers/net/ethernet/qualcomm/emac/emac.c
index 551df1c..9bf3b2b 100644
--- a/drivers/net/ethernet/qualcomm/emac/emac.c
+++ b/drivers/net/ethernet/qualcomm/emac/emac.c
@@ -22,6 +22,7 @@
 #include <linux/of_device.h>
 #include <linux/phy.h>
 #include <linux/platform_device.h>
+#include <linux/acpi.h>
 #include "emac.h"
 #include "emac-mac.h"
 #include "emac-phy.h"
@@ -575,6 +576,16 @@ static const struct of_device_id emac_dt_match[] = {
 	{}
 };
 
+#if IS_ENABLED(CONFIG_ACPI)
+static const struct acpi_device_id emac_acpi_match[] = {
+	{
+		.id = "QCOM8070",
+	},
+	{}
+};
+MODULE_DEVICE_TABLE(acpi, emac_acpi_match);
+#endif
+
 static int emac_probe(struct platform_device *pdev)
 {
 	struct net_device *netdev;
@@ -734,6 +745,7 @@ static struct platform_driver emac_platform_driver = {
 	.driver = {
 		.name		= "qcom-emac",
 		.of_match_table = emac_dt_match,
+		.acpi_match_table = ACPI_PTR(emac_acpi_match),
 	},
 };
 
-- 
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm
Technologies, Inc.  Qualcomm Technologies, Inc. is a member of the
Code Aurora Forum, a Linux Foundation Collaborative Project.
