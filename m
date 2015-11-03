From: Markus Brunner <systemprogrammierung.brunner@gmail.com>
Subject: [PATCH] drivers: net: cpsw: Add support for fixed-link PHY
Date: Tue, 03 Nov 2015 22:09:51 +0100
Message-ID: <2251323.UEGYDRRlj7@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-omap@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:34060 "EHLO
	mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755259AbbKCVLa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2015 16:11:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for a fixed-link devicetree sub-node in case the the 
cpsw MAC is directly connected to a non-mdio PHY/device. 

Signed-off-by: Markus Brunner <systemprogrammierung.brunner@gmail.com>

---
 Documentation/devicetree/bindings/net/cpsw.txt |    5 +++++
 drivers/net/ethernet/ti/cpsw.c                 |   13 +++++++++++++
 2 files changed, 18 insertions(+)

diff -upNr linux-4.3.orig/Documentation/devicetree/bindings/net/cpsw.txt linux-4.3/Documentation/devicetree/bindings/net/cpsw.txt
--- linux-4.3.orig/Documentation/devicetree/bindings/net/cpsw.txt	2015-11-03 17:21:40.000000000 +0100
+++ linux-4.3/Documentation/devicetree/bindings/net/cpsw.txt	2015-11-02 16:53:43.000000000 +0100
@@ -41,6 +41,11 @@ Optional properties:
 - mac-address		: See ethernet.txt file in the same directory
 - phy-handle		: See ethernet.txt file in the same directory
 
+Slave sub-nodes:
+- fixed-link		: See fixed-link.txt file in the same directory
+			  Either the properties phy_id and phy-mode,
+			  or the sub-node fixed-link can be specified
+
 Note: "ti,hwmods" field is used to fetch the base address and irq
 resources from TI, omap hwmod data base during device registration.
 Future plan is to migrate hwmod data base contents into device tree
diff -upNr linux-4.3.orig/drivers/net/ethernet/ti/cpsw.c linux-4.3/drivers/net/ethernet/ti/cpsw.c
--- linux-4.3.orig/drivers/net/ethernet/ti/cpsw.c	2015-11-03 17:18:00.000000000 +0100
+++ linux-4.3/drivers/net/ethernet/ti/cpsw.c	2015-11-03 17:04:08.000000000 +0100
@@ -2037,6 +2037,19 @@ static int cpsw_probe_dt(struct cpsw_pri
 			continue;
 
 		priv->phy_node = of_parse_phandle(slave_node, "phy-handle", 0);
+		if (of_phy_is_fixed_link(slave_node)) {
+			struct phy_device *pd;
+
+			ret = of_phy_register_fixed_link(slave_node);
+			if (ret)
+				return ret;
+			pd = of_phy_find_device(slave_node);
+			if (!pd)
+				return -ENODEV;
+			snprintf(slave_data->phy_id, sizeof(slave_data->phy_id),
+				 PHY_ID_FMT, pd->bus->id, pd->phy_id);
+			goto no_phy_slave;
+		}
 		parp = of_get_property(slave_node, "phy_id", &lenp);
 		if ((parp == NULL) || (lenp != (sizeof(void *) * 2))) {
 			dev_err(&pdev->dev, "Missing slave[%d] phy_id property\n", i);
