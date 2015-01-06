From: Felipe Balbi <balbi@ti.com>
Subject: [PATCH] net: ethernet: cpsw: ignore VLAN ID 1
Date: Tue, 6 Jan 2015 11:43:32 -0600
Message-ID: <1420566212-30081-1-git-send-email-balbi@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
	Linux OMAP Mailing List <linux-omap@vger.kernel.org>,
	Felipe Balbi <balbi@ti.com>, <stable@vger.kernel.org>,
	Mugunthan V N <mugunthanvnm@ti.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from devils.ext.ti.com ([198.47.26.153]:34510 "EHLO
	devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755801AbbAFRoK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2015 12:44:10 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

CPSW completely hangs if we add, and later remove,
VLAN ID #1. What happens is that after removing
VLAN ID #1, no packets will be received by CPSW
rendering network unusable.

In order to "fix" the issue, we're returning -EINVAL
if anybody tries to add VLAN ID #1. While at that,
also filter out any ID > 4095 because we only have
12 bits for VLAN IDs.

Fixes: 3b72c2f (drivers: net:ethernet: cpsw: add support for VLAN)
Cc: <stable@vger.kernel.org> # v3.9+
Cc: Mugunthan V N <mugunthanvnm@ti.com>
Tested-by: Schuyler Patton <spatton@ti.com>
Signed-off-by: Felipe Balbi <balbi@ti.com>
---
 drivers/net/ethernet/ti/cpsw.c | 14 ++++++++++++++
 1 file changed, 14 insertions(+)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index e61ee8351272..028bb7f3de65 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -1669,6 +1669,13 @@ static int cpsw_ndo_vlan_rx_add_vid(struct net_device *ndev,
 	if (vid == priv->data.default_vlan)
 		return 0;
 
+	/* NOTICE: CPSW does not support VID 1. We should
+	 * also filter out VID > 4095 as we only have 12
+	 * bits for VID entries
+	 */
+	if (vid == 1 || vid >= VLAN_N_VID)
+		return -EINVAL;
+
 	dev_info(priv->dev, "Adding vlanid %d to vlan filter\n", vid);
 	return cpsw_add_vlan_ale_entry(priv, vid);
 }
@@ -1682,6 +1689,13 @@ static int cpsw_ndo_vlan_rx_kill_vid(struct net_device *ndev,
 	if (vid == priv->data.default_vlan)
 		return 0;
 
+	/* NOTICE: CPSW does not support VID 1. We should
+	 * also filter out VID > 4095 as we only have 12
+	 * bits for VID entries
+	 */
+	if (vid == 1 || vid >= VLAN_N_VID)
+		return -EINVAL;
+
 	dev_info(priv->dev, "removing vlanid %d from vlan filter\n", vid);
 	ret = cpsw_ale_del_vlan(priv->ale, vid, 0);
 	if (ret != 0)
-- 
2.2.0
