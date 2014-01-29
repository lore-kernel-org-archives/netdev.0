From: Stefan Roese <sr@denx.de>
Subject: [PATCH] net: eth: cpsw: Correctly attach to GPIO bitbang MDIO driver
Date: Wed, 29 Jan 2014 11:32:37 +0100
Message-ID: <1390991557-22522-1-git-send-email-sr@denx.de>
Cc: Lukas Stockmann <lukas.stockmann@siemens.com>,
	Mugunthan V N <mugunthanvnm@ti.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo4-p05-ob.smtp.rzone.de ([81.169.146.183]:55238 "EHLO
	mo4-p05-ob.smtp.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750882AbaA2Kih (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jan 2014 05:38:37 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the GPIO bitbang MDIO driver is used instead of the Davinci MDIO driver
we need to configure the phy_id string differently. Otherwise this string
looks like this "gpio.6" instead of "gpio-0" and the PHY is not found when
phy_connect() is called.

Signed-off-by: Stefan Roese <sr@denx.de>
Cc: Lukas Stockmann <lukas.stockmann@siemens.com>
Cc: Mugunthan V N <mugunthanvnm@ti.com>
---
 drivers/net/ethernet/ti/cpsw.c | 14 ++++++++++++--
 1 file changed, 12 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index a3ca3dd..43e6591 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -1858,8 +1858,18 @@ static int cpsw_probe_dt(struct cpsw_platform_data *data,
 		mdio_node = of_find_node_by_phandle(be32_to_cpup(parp));
 		phyid = be32_to_cpup(parp+1);
 		mdio = of_find_device_by_node(mdio_node);
-		snprintf(slave_data->phy_id, sizeof(slave_data->phy_id),
-			 PHY_ID_FMT, mdio->name, phyid);
+
+		if (strncmp(mdio->name, "gpio", 4) == 0) {
+			/* GPIO bitbang MDIO driver attached */
+			struct mii_bus *bus = dev_get_drvdata(&mdio->dev);
+
+			snprintf(slave_data->phy_id, sizeof(slave_data->phy_id),
+				 PHY_ID_FMT, bus->id, phyid);
+		} else {
+			/* davinci MDIO driver attached */
+			snprintf(slave_data->phy_id, sizeof(slave_data->phy_id),
+				 PHY_ID_FMT, mdio->name, phyid);
+		}
 
 		mac_addr = of_get_mac_address(slave_node);
 		if (mac_addr)
-- 
1.8.5.3
