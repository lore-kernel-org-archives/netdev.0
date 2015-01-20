From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [net PATCH 1/1] drivers: net: cpsw: discard dual emac default vlan configuration
Date: Tue, 20 Jan 2015 17:55:40 +0530
Message-ID: <1421756740-32180-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, Mugunthan V N <mugunthanvnm@ti.com>,
	<stable@vger.kernel.org>
To: <netdev@vger.kernel.org>
Return-path: <stable-owner@vger.kernel.org>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In Dual EMAC, the default vlans are used to segregate rx packets between
the ports, so adding the same default vlan to the switch will affect the
normal packet transfers. So returning error on addition of dual emac
default vlans.

Even if emac 0 default port vlan is added to emac 1, it will lead to
break dual EMAC port seperations.

Fixes: d9ba8f9 (driver: net: ethernet: cpsw: dual emac interface implementation)
Cc: <stable@vger.kernel.org> # v3.9+
Reported-by: Felipe Balbi <balbi@ti.com>
Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
---
 drivers/net/ethernet/ti/cpsw.c | 22 ++++++++++++++++++++++
 1 file changed, 22 insertions(+)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index e068d48..7c32815 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -1683,6 +1683,19 @@ static int cpsw_ndo_vlan_rx_add_vid(struct net_device *ndev,
 	if (vid == priv->data.default_vlan)
 		return 0;
 
+	if (priv->data.dual_emac) {
+		/* In dual EMAC, reserved VLAN id should not be used of
+		 * creating vlan interfaces as this can break the dual
+		 * EMAC port seperation
+		 */
+		int i;
+
+		for (i = 0; i < priv->data.slaves; i++) {
+			if (vid == priv->slaves[i].port_vlan)
+				return -EINVAL;
+		}
+	}
+
 	dev_info(priv->dev, "Adding vlanid %d to vlan filter\n", vid);
 	return cpsw_add_vlan_ale_entry(priv, vid);
 }
@@ -1696,6 +1709,15 @@ static int cpsw_ndo_vlan_rx_kill_vid(struct net_device *ndev,
 	if (vid == priv->data.default_vlan)
 		return 0;
 
+	if (priv->data.dual_emac) {
+		int i;
+
+		for (i = 0; i < priv->data.slaves; i++) {
+			if (vid == priv->slaves[i].port_vlan)
+				return -EINVAL;
+		}
+	}
+
 	dev_info(priv->dev, "removing vlanid %d from vlan filter\n", vid);
 	ret = cpsw_ale_del_vlan(priv->ale, vid, 0);
 	if (ret != 0)
-- 
2.2.1.62.g3f15098
