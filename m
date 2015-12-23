From: "David Rivshin (Allworx)" <drivshin.allworx@gmail.com>
Subject: [PATCH 3/3] drivers: net: cpsw: use of_phy_connect() in fixed-link case
Date: Tue, 22 Dec 2015 19:36:34 -0500
Message-ID: <1450830994-5450-4-git-send-email-drivshin.allworx@gmail.com>
References: <1450830994-5450-1-git-send-email-drivshin.allworx@gmail.com>
Cc: linux-arm-kernel@lists.infradead.org, linux-omap@vger.kernel.org,
	devicetree@vger.kernel.org, David Miller <davem@davemloft.net>,
	Heiko Schocher <hs@denx.de>,
	Mugunthan V N <mugunthanvnm@ti.com>,
	Markus Brunner <systemprogrammierung.brunner@gmail.com>,
	Pascal Speck <kernel@iktek.de>,
	Daniel Trautmann <dtrautmann@ibhsoftec-sps.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f51.google.com ([209.85.192.51]:36065 "EHLO
	mail-qg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933526AbbLWAig (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Dec 2015 19:38:36 -0500
In-Reply-To: <1450830994-5450-1-git-send-email-drivshin.allworx@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Rivshin <drivshin@allworx.com>

If a fixed-link DT subnode is used, the phy_device was looked up so
that a PHY ID string could be constructed and passed to phy_connect().
This is not necessary, as the device_node can be passed directly to
of_phy_connect() instead. This reuses the same codepath as if the
phy-handle DT property was used.

Signed-off-by: David Rivshin <drivshin@allworx.com>
---
 drivers/net/ethernet/ti/cpsw.c | 10 +---------
 1 file changed, 1 insertion(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index f9029e7..94b818c 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -2038,29 +2038,21 @@ static int cpsw_probe_dt(struct cpsw_platform_data *data,
 							"phy-handle", 0);
 		parp = of_get_property(slave_node, "phy_id", &lenp);
 		if (slave_data->phy_node) {
 			dev_dbg(&pdev->dev,
 				"slave[%d] using phy-handle=\"%s\"\n",
 				i, slave_data->phy_node->full_name);
 		} else if (of_phy_is_fixed_link(slave_node)) {
-			struct device_node *phy_node;
-			struct phy_device *phy_dev;
-
 			/* In the case of a fixed PHY, the DT node associated
 			 * to the PHY is the Ethernet MAC DT node.
 			 */
 			ret = of_phy_register_fixed_link(slave_node);
 			if (ret)
 				return ret;
-			phy_node = of_node_get(slave_node);
-			phy_dev = of_phy_find_device(phy_node);
-			if (!phy_dev)
-				return -ENODEV;
-			snprintf(slave_data->phy_id, sizeof(slave_data->phy_id),
-				 PHY_ID_FMT, phy_dev->bus->id, phy_dev->addr);
+			slave_data->phy_node = of_node_get(slave_node);
 		} else if (parp) {
 			u32 phyid;
 			struct device_node *mdio_node;
 			struct platform_device *mdio;
 
 			if (lenp != (sizeof(__be32) * 2)) {
 				dev_err(&pdev->dev, "Invalid slave[%d] phy_id property\n", i);
-- 
2.5.0
