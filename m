From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 3/5] cpmac: add support for fixed PHY
Date: Tue, 4 Aug 2009 22:52:52 +0200
Message-ID: <200908042252.53068.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-mips@linux-mips.org, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: Ralf Baechle <ralf@linux-mips.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f214.google.com ([209.85.219.214]:50430 "EHLO
	mail-ew0-f214.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932582AbZHDUwz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Aug 2009 16:52:55 -0400
Received: by mail-ew0-f214.google.com with SMTP id 10so654827ewy.37
        for <netdev@vger.kernel.org>; Tue, 04 Aug 2009 13:52:55 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for fixed PHY connected in MII mode
to cpmac. We allow external and dumb_switch module parameters
to override the PHY detection process since they are always connected
with MDIO bus identifier 0. This lets fixed PHYs to be detected
correctly and be connected to the their corresponding MDIO
bus identifier.

Signed-off-by: Florian Fainelli <florian@openwrt.org>
---
diff --git a/drivers/net/cpmac.c b/drivers/net/cpmac.c
index c951dd4..f2fc722 100644
--- a/drivers/net/cpmac.c
+++ b/drivers/net/cpmac.c
@@ -1117,22 +1117,23 @@ static int __devinit cpmac_probe(struct platform_device *pdev)
 
 	pdata = pdev->dev.platform_data;
 
-	for (phy_id = 0; phy_id < PHY_MAX_ADDR; phy_id++) {
-		if (!(pdata->phy_mask & (1 << phy_id)))
-			continue;
-		if (!cpmac_mii->phy_map[phy_id])
-			continue;
-		break;
+	if (external_switch || dumb_switch) {
+		strncpy(mdio_bus_id, "0", BUS_ID_SIZE); /* fixed phys bus */
+		phy_id = pdev->id;
+	} else {
+		for (phy_id = 0; phy_id < PHY_MAX_ADDR; phy_id++) {
+			if (!(pdata->phy_mask & (1 << phy_id)))
+				continue;
+			if (!cpmac_mii->phy_map[phy_id])
+				continue;
+			strncpy(mdio_bus_id, cpmac_mii->id, BUS_ID_SIZE);
+			break;
+		}
 	}
 
 	if (phy_id == PHY_MAX_ADDR) {
-		if (external_switch || dumb_switch) {
-			strncpy(mdio_bus_id, "0", BUS_ID_SIZE); /* fixed phys bus */
-			phy_id = pdev->id;
-		} else {
-			dev_err(&pdev->dev, "no PHY present\n");
-			return -ENODEV;
-		}
+		dev_err(&pdev->dev, "no PHY present\n");
+		return -ENODEV;
 	}
 
 	dev = alloc_etherdev_mq(sizeof(*priv), CPMAC_QUEUES);
@@ -1166,8 +1167,11 @@ static int __devinit cpmac_probe(struct platform_device *pdev)
 	priv->msg_enable = netif_msg_init(debug_level, 0xff);
 	memcpy(dev->dev_addr, pdata->dev_addr, sizeof(dev->dev_addr));
 
-	priv->phy = phy_connect(dev, dev_name(&cpmac_mii->phy_map[phy_id]->dev),
-				&cpmac_adjust_link, 0, PHY_INTERFACE_MODE_MII);
+	snprintf(priv->phy_name, BUS_ID_SIZE, PHY_ID_FMT, mdio_bus_id, phy_id);
+	
+	priv->phy = phy_connect(dev, priv->phy_name, &cpmac_adjust_link, 0,
+						PHY_INTERFACE_MODE_MII);
+
 	if (IS_ERR(priv->phy)) {
 		if (netif_msg_drv(priv))
 			printk(KERN_ERR "%s: Could not attach to PHY\n",
