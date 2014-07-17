From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 06/14] be2net: fix return status of some ndo methods
Date: Thu, 17 Jul 2014 16:20:24 +0530
Message-ID: <1405594232-30818-7-git-send-email-sathya.perla@emulex.com>
References: <1405594232-30818-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:22735 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756778AbaGQKsf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jul 2014 06:48:35 -0400
In-Reply-To: <1405594232-30818-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kalesh AP <kalesh.purayil@emulex.com>

The netlink layer expects a -ve status value to be returned when a driver
ndo method encounters an error. The driver was directly passing the
error status returned by FW (a positive value) to the stack.
This patch fixes this by returning -EIO status when a FW-cmd reports an error.

Signed-off-by: Kalesh AP <kalesh.purayil@emulex.com>
Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c |   43 +++++++++++++++++----------
 1 files changed, 27 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index bd0cadc..46cdcba 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -1281,13 +1281,15 @@ static int be_set_vf_mac(struct net_device *netdev, int vf, u8 *mac)
 					vf + 1);
 	}
 
-	if (status)
-		dev_err(&adapter->pdev->dev, "MAC %pM set on VF %d Failed\n",
-			mac, vf);
-	else
-		memcpy(vf_cfg->mac_addr, mac, ETH_ALEN);
+	if (status) {
+		dev_err(&adapter->pdev->dev, "MAC %pM set on VF %d Failed: %#x",
+			mac, vf, status);
+		return be_cmd_status(status);
+	}
 
-	return status;
+	ether_addr_copy(vf_cfg->mac_addr, mac);
+
+	return 0;
 }
 
 static int be_get_vf_config(struct net_device *netdev, int vf,
@@ -1336,12 +1338,16 @@ static int be_set_vf_vlan(struct net_device *netdev, int vf, u16 vlan, u8 qos)
 					       vf + 1, vf_cfg->if_handle, 0);
 	}
 
-	if (!status)
-		vf_cfg->vlan_tag = vlan;
-	else
-		dev_info(&adapter->pdev->dev,
-			 "VLAN %d config on VF %d failed\n", vlan, vf);
-	return status;
+	if (status) {
+		dev_err(&adapter->pdev->dev,
+			"VLAN %d config on VF %d failed : %#x\n", vlan,
+			vf, status);
+		return be_cmd_status(status);
+	}
+
+	vf_cfg->vlan_tag = vlan;
+
+	return 0;
 }
 
 static int be_set_vf_tx_rate(struct net_device *netdev, int vf,
@@ -1403,7 +1409,7 @@ config_qos:
 err:
 	dev_err(dev, "TX-rate setting of %dMbps on VF%d failed\n",
 		max_tx_rate, vf);
-	return status;
+	return be_cmd_status(status);
 }
 static int be_set_vf_link_state(struct net_device *netdev, int vf,
 				int link_state)
@@ -1418,10 +1424,15 @@ static int be_set_vf_link_state(struct net_device *netdev, int vf,
 		return -EINVAL;
 
 	status = be_cmd_set_logical_link_config(adapter, link_state, vf+1);
-	if (!status)
-		adapter->vf_cfg[vf].plink_tracking = link_state;
+	if (status) {
+		dev_err(&adapter->pdev->dev,
+			"Link state change on VF %d failed: %#x\n", vf, status);
+		return be_cmd_status(status);
+	}
 
-	return status;
+	adapter->vf_cfg[vf].plink_tracking = link_state;
+
+	return 0;
 }
 
 static void be_aic_update(struct be_aic_obj *aic, u64 rx_pkts, u64 tx_pkts,
-- 
1.7.1
