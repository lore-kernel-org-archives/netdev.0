From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [net PATCH v2 1/1] drivers: net: cpsw: discard dual emac default vlan configuration
Date: Thu, 22 Jan 2015 15:19:22 +0530
Message-ID: <1421920162-13398-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, Mugunthan V N <mugunthanvnm@ti.com>,
	<stable@vger.kernel.org>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from comal.ext.ti.com ([198.47.26.152]:47808 "EHLO comal.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752496AbbAVJtX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jan 2015 04:49:23 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In Dual EMAC, the default VLANs are used to segregate Rx packets between
the ports, so adding the same default VLAN to the switch will affect the
normal packet transfers. So returning error on addition of dual EMAC
default VLANs.

Even if EMAC 0 default port VLAN is added to EMAC 1, it will lead to
break dual EMAC port separations.

Fixes: d9ba8f9e6298 (driver: net: ethernet: cpsw: dual emac interface implementation)
Cc: <stable@vger.kernel.org> # v3.9+
Reported-by: Felipe Balbi <balbi@ti.com>
Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
---

Changes from initial version:
* Fixed typo errors in comments and no code changes.

---
 drivers/net/ethernet/ti/cpsw.c | 22 ++++++++++++++++++++++
 1 file changed, 22 insertions(+)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index e068d48..a39131f 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -1683,6 +1683,19 @@ static int cpsw_ndo_vlan_rx_add_vid(struct net_device *ndev,
 	if (vid == priv->data.default_vlan)
 		return 0;
 
+	if (priv->data.dual_emac) {
+		/* In dual EMAC, reserved VLAN id should not be used for
+		 * creating VLAN interfaces as this can break the dual
+		 * EMAC port separation
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
