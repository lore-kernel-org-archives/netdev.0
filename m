From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [PATCH 1/1] drivers: net:cpsw: fix probe_dt when only slave 1 is pinned out
Date: Fri, 24 Oct 2014 18:51:33 +0530
Message-ID: <1414156893-1884-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from devils.ext.ti.com ([198.47.26.153]:48876 "EHLO
	devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756605AbaJXNVi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Oct 2014 09:21:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

when slave 0 has no phy and slave 1 connected to phy, driver probe will
fail as there is no phy id present for slave 0 device tree, so continuing
even though no phy-id found, also moving mac-id read later to ensure
mac-id is read from device tree even when phy-id entry in not found.

Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
---
 drivers/net/ethernet/ti/cpsw.c | 18 +++++++++---------
 1 file changed, 9 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 952e1e4..d81b84b 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -2006,7 +2006,7 @@ static int cpsw_probe_dt(struct cpsw_platform_data *data,
 		parp = of_get_property(slave_node, "phy_id", &lenp);
 		if ((parp == NULL) || (lenp != (sizeof(void *) * 2))) {
 			dev_err(&pdev->dev, "Missing slave[%d] phy_id property\n", i);
-			return -EINVAL;
+			goto no_phy_slave;
 		}
 		mdio_node = of_find_node_by_phandle(be32_to_cpup(parp));
 		phyid = be32_to_cpup(parp+1);
@@ -2019,6 +2019,14 @@ static int cpsw_probe_dt(struct cpsw_platform_data *data,
 		snprintf(slave_data->phy_id, sizeof(slave_data->phy_id),
 			 PHY_ID_FMT, mdio->name, phyid);
 
+		slave_data->phy_if = of_get_phy_mode(slave_node);
+		if (slave_data->phy_if < 0) {
+			dev_err(&pdev->dev, "Missing or malformed slave[%d] phy-mode property\n",
+				i);
+			return slave_data->phy_if;
+		}
+
+no_phy_slave:
 		mac_addr = of_get_mac_address(slave_node);
 		if (mac_addr) {
 			memcpy(slave_data->mac_addr, mac_addr, ETH_ALEN);
@@ -2030,14 +2038,6 @@ static int cpsw_probe_dt(struct cpsw_platform_data *data,
 					return ret;
 			}
 		}
-
-		slave_data->phy_if = of_get_phy_mode(slave_node);
-		if (slave_data->phy_if < 0) {
-			dev_err(&pdev->dev, "Missing or malformed slave[%d] phy-mode property\n",
-				i);
-			return slave_data->phy_if;
-		}
-
 		if (data->dual_emac) {
 			if (of_property_read_u32(slave_node, "dual_emac_res_vlan",
 						 &prop)) {
-- 
2.1.2.484.g13da0fc
