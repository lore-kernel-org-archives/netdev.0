From: Suman Tripathi <stripathi@apm.com>
Subject: [PATCH net-next v0 1/4] drivers: net: xgene: Fix the ACPI support for RGMII/SGMII0/XFI interface of APM X-Gene SoC ethernet controller.
Date: Tue, 23 Jun 2015 14:47:14 +0530
Message-ID: <1435051037-21753-2-git-send-email-stripathi@apm.com>
References: <1435051037-21753-1-git-send-email-stripathi@apm.com>
Cc: linux-arm-kernel@lists.infradead.org, kchudgar@apm.com,
	patches@apm.com, isubramanian@apm.com,
	Suman Tripathi <stripathi@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from denmail01-v4020.amcc.com ([192.195.68.30]:45517 "EHLO
	denmail01.amcc.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753972AbbFWJSY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jun 2015 05:18:24 -0400
In-Reply-To: <1435051037-21753-1-git-send-email-stripathi@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch implements couple of fixes to support ACPI for RGMII/SGMII0/XFI
interface of APM X-Gene SoC ethernet controller driver. This patch uses
the _SUN acpi object to fetch the port-id information whereas the FDT uses
port-id binding for port-id information.

Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
Signed-off-by: Suman Tripathi <stripathi@apm.com>
---
 drivers/net/ethernet/apm/xgene/xgene_enet_hw.c   |  2 +-
 drivers/net/ethernet/apm/xgene/xgene_enet_main.c | 66 +++++++++++++++---------
 2 files changed, 44 insertions(+), 24 deletions(-)

diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
index 25873d1..8ff736d 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
@@ -751,7 +751,7 @@ static int xgene_mdiobus_register(struct xgene_enet_pdata *pdata,
 	if (ret)
 		return -EINVAL;

-	phy = get_phy_device(mdio, phy_id, true);
+	phy = get_phy_device(mdio, phy_id, false);
 	if (!phy || IS_ERR(phy))
 		return -EIO;

diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
index 1bb3175..c8f97a7 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
@@ -29,6 +29,7 @@
 #define RES_RING_CMD	2

 static const struct of_device_id xgene_enet_of_match[];
+static const struct acpi_device_id xgene_enet_acpi_match[];

 static void xgene_enet_init_bufpool(struct xgene_enet_desc_ring *buf_pool)
 {
@@ -870,24 +871,33 @@ static const struct net_device_ops xgene_ndev_ops = {
 	.ndo_set_mac_address = xgene_enet_set_mac_address,
 };

-static int xgene_get_port_id(struct device *dev, struct xgene_enet_pdata *pdata)
+static int xgene_get_port_id_acpi(struct device *dev,
+				  struct xgene_enet_pdata *pdata)
+{
+	acpi_status status;
+	u64 temp;
+
+	status = acpi_evaluate_integer(ACPI_HANDLE(dev), "_SUN", NULL, &temp);
+	if (ACPI_FAILURE(status)) {
+		pdata->port_id = 0;
+	} else {
+		pdata->port_id = temp;
+	}
+
+	return 0;
+}
+
+static int xgene_get_port_id_dt(struct device *dev, struct xgene_enet_pdata *pdata)
 {
 	u32 id = 0;
 	int ret;

-	ret = device_property_read_u32(dev, "port-id", &id);
-
-	switch (ret) {
-	case -EINVAL:
+	ret = of_property_read_u32(dev->of_node, "port-id", &id);
+	if (ret) {
 		pdata->port_id = 0;
 		ret = 0;
-		break;
-	case 0:
+	} else {
 		pdata->port_id = id & BIT(0);
-		break;
-	default:
-		dev_err(dev, "Incorrect port-id specified: errno: %d\n", ret);
-		break;
 	}

 	return ret;
@@ -976,8 +986,13 @@ static int xgene_enet_get_resources(struct xgene_enet_pdata *pdata)
 		dev_err(dev, "Unable to retrieve ENET Ring command region\n");
 		return -ENOMEM;
 	}
-
-	ret = xgene_get_port_id(dev, pdata);
+
+	if (dev->of_node)
+		ret = xgene_get_port_id_dt(dev, pdata);
+#ifdef CONFIG_ACPI
+	else
+		ret = xgene_get_port_id_acpi(dev, pdata);
+#endif
 	if (ret)
 		return ret;

@@ -1173,9 +1188,7 @@ static int xgene_enet_probe(struct platform_device *pdev)
 	struct xgene_enet_pdata *pdata;
 	struct device *dev = &pdev->dev;
 	struct xgene_mac_ops *mac_ops;
-#ifdef CONFIG_OF
 	const struct of_device_id *of_id;
-#endif
 	int ret;

 	ndev = alloc_etherdev(sizeof(struct xgene_enet_pdata));
@@ -1194,16 +1207,23 @@ static int xgene_enet_probe(struct platform_device *pdev)
 			  NETIF_F_GSO |
 			  NETIF_F_GRO;

-#ifdef CONFIG_OF
 	of_id = of_match_device(xgene_enet_of_match, &pdev->dev);
 	if (of_id) {
 		pdata->enet_id = (enum xgene_enet_id)of_id->data;
-		if (!pdata->enet_id) {
-			free_netdev(ndev);
-			return -ENODEV;
-		}
+	}
+#ifdef CONFIG_ACPI
+	else {
+		const struct acpi_device_id *acpi_id;
+
+		acpi_id = acpi_match_device(xgene_enet_acpi_match, &pdev->dev);
+		if (acpi_id)
+			pdata->enet_id = (enum xgene_enet_id) acpi_id->driver_data;
 	}
 #endif
+	if (!pdata->enet_id) {
+		free_netdev(ndev);
+		return -ENODEV;
+	}

 	ret = xgene_enet_get_resources(pdata);
 	if (ret)
@@ -1266,9 +1286,9 @@ static int xgene_enet_remove(struct platform_device *pdev)

 #ifdef CONFIG_ACPI
 static const struct acpi_device_id xgene_enet_acpi_match[] = {
-	{ "APMC0D05", },
-	{ "APMC0D30", },
-	{ "APMC0D31", },
+	{ "APMC0D05", XGENE_ENET1},
+	{ "APMC0D30", XGENE_ENET1},
+	{ "APMC0D31", XGENE_ENET1},
 	{ }
 };
 MODULE_DEVICE_TABLE(acpi, xgene_enet_acpi_match);
--
1.8.2.1
