From: Timur Tabi <timur@codeaurora.org>
Subject: [PATCH 1/3] [v2] net: qcom/emac: do not use devm on internal phy pdev
Date: Wed, 28 Sep 2016 11:58:42 -0500
Message-ID: <1475081924-12362-2-git-send-email-timur@codeaurora.org>
References: <1475081924-12362-1-git-send-email-timur@codeaurora.org>
To: netdev@vger.kernel.org, linaro-acpi@lists.linaro.org,
        linux-arm-kernel@lists.infradead.org, shankerd@codeaurora.org,
        vikrams@codeaurora.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:53618 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932961AbcI1Q6t (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Sep 2016 12:58:49 -0400
In-Reply-To: <1475081924-12362-1-git-send-email-timur@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The platform_device returned by of_find_device_by_node() is not
automatically released when the driver unprobes.  Therefore,
managed calls like devm_ioremap_resource() should not be used.
Instead, we manually allocate the resources and then free them
on driver release.

Signed-off-by: Timur Tabi <timur@codeaurora.org>
---
 drivers/net/ethernet/qualcomm/emac/emac-sgmii.c | 42 +++++++++++++++++++------
 drivers/net/ethernet/qualcomm/emac/emac.c       |  4 +++
 2 files changed, 37 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/qualcomm/emac/emac-sgmii.c b/drivers/net/ethernet/qualcomm/emac/emac-sgmii.c
index 6ab0a3c..ad0e420 100644
--- a/drivers/net/ethernet/qualcomm/emac/emac-sgmii.c
+++ b/drivers/net/ethernet/qualcomm/emac/emac-sgmii.c
@@ -681,6 +681,7 @@ int emac_sgmii_config(struct platform_device *pdev, struct emac_adapter *adpt)
 	struct resource *res;
 	const struct of_device_id *match;
 	struct device_node *np;
+	int ret;
 
 	np = of_parse_phandle(pdev->dev.of_node, "internal-phy", 0);
 	if (!np) {
@@ -697,25 +698,48 @@ int emac_sgmii_config(struct platform_device *pdev, struct emac_adapter *adpt)
 	match = of_match_device(emac_sgmii_dt_match, &sgmii_pdev->dev);
 	if (!match) {
 		dev_err(&pdev->dev, "unrecognized internal phy node\n");
-		return -ENODEV;
+		ret = -ENODEV;
+		goto error_put_device;
 	}
 
 	phy->initialize = (emac_sgmii_initialize)match->data;
 
 	/* Base address is the first address */
 	res = platform_get_resource(sgmii_pdev, IORESOURCE_MEM, 0);
-	phy->base = devm_ioremap_resource(&sgmii_pdev->dev, res);
-	if (IS_ERR(phy->base))
-		return PTR_ERR(phy->base);
+	phy->base = ioremap(res->start, resource_size(res));
+	if (IS_ERR(phy->base)) {
+		ret = PTR_ERR(phy->base);
+		goto error_put_device;
+	}
 
 	/* v2 SGMII has a per-lane digital digital, so parse it if it exists */
 	res = platform_get_resource(sgmii_pdev, IORESOURCE_MEM, 1);
 	if (res) {
-		phy->digital = devm_ioremap_resource(&sgmii_pdev->dev, res);
-		if (IS_ERR(phy->base))
-			return PTR_ERR(phy->base);
-
+		phy->digital = ioremap(res->start, resource_size(res));
+		if (IS_ERR(phy->digital)) {
+			ret = PTR_ERR(phy->digital);
+			goto error_unmap_base;
+		}
 	}
 
-	return phy->initialize(adpt);
+	ret = phy->initialize(adpt);
+	if (ret)
+		goto error;
+
+	/* We've remapped the addresses, so we don't need the device any
+	 * more.  of_find_device_by_node() says we should release it.
+	 */
+	put_device(&sgmii_pdev->dev);
+
+	return 0;
+
+error:
+	if (phy->digital)
+		iounmap(phy->digital);
+error_unmap_base:
+	iounmap(phy->base);
+error_put_device:
+	put_device(&sgmii_pdev->dev);
+
+	return ret;
 }
diff --git a/drivers/net/ethernet/qualcomm/emac/emac.c b/drivers/net/ethernet/qualcomm/emac/emac.c
index e47d387..429b4cb 100644
--- a/drivers/net/ethernet/qualcomm/emac/emac.c
+++ b/drivers/net/ethernet/qualcomm/emac/emac.c
@@ -723,6 +723,10 @@ static int emac_remove(struct platform_device *pdev)
 	mdiobus_unregister(adpt->mii_bus);
 	free_netdev(netdev);
 
+	if (adpt->phy.digital)
+		iounmap(adpt->phy.digital);
+	iounmap(adpt->phy.base);
+
 	return 0;
 }
 
-- 
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm
Technologies, Inc.  Qualcomm Technologies, Inc. is a member of the
Code Aurora Forum, a Linux Foundation Collaborative Project.
