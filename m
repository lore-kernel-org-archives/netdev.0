From: Somnath Kotur <somnath.kotur@emulex.com>
Subject: [PATCH net v2 1/4] be2net: Fix to reset transparent vlan tagging
Date: Mon, 3 Mar 2014 14:24:20 +0530
Message-ID: <c22b21a1-bb35-4308-98f3-302c9ccc36bc@CMEXHTCAS2.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, Somnath Kotur <somnath.kotur@emulex.com>,
	Kalesh AP <kalesh.purayil@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:47397 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753889AbaCCI4I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Mar 2014 03:56:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For disabling transparent tagging issue SET_HSW_CONFIG with pvid_valid=1
and pvid=0xFFFF and not with the default pvid as this case would fail in Lancer.
Hence removing the get_hsw_config call from be_vf_setup() as it's
only use of getting default pvid is no longer needed.

Also do proper housekeeping only if the FW command succeeds.

Signed-off-by: Kalesh AP <kalesh.purayil@emulex.com>
Signed-off-by: Somnath Kotur <somnath.kotur@emulex.com>
---
V2: Corect value that works across all cards is 0xFFFF and not 0xFFF
as was in V1 version of the patch.

 drivers/net/ethernet/emulex/benet/be.h      |    4 ++-
 drivers/net/ethernet/emulex/benet/be_main.c |   28 ++++++++------------------
 2 files changed, 12 insertions(+), 20 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be.h b/drivers/net/ethernet/emulex/benet/be.h
index 8d09615..05529e2 100644
--- a/drivers/net/ethernet/emulex/benet/be.h
+++ b/drivers/net/ethernet/emulex/benet/be.h
@@ -350,11 +350,13 @@ struct be_drv_stats {
 	u32 roce_drops_crc;
 };
 
+/* A vlan-id of 0xFFFF must be used to clear transparent vlan-tagging */
+#define BE_RESET_VLAN_TAG_ID	0xFFFF
+
 struct be_vf_cfg {
 	unsigned char mac_addr[ETH_ALEN];
 	int if_handle;
 	int pmac_id;
-	u16 def_vid;
 	u16 vlan_tag;
 	u32 tx_rate;
 };
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 04ac9c6..45662af 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -1287,24 +1287,20 @@ static int be_set_vf_vlan(struct net_device *netdev,
 
 	if (vlan || qos) {
 		vlan |= qos << VLAN_PRIO_SHIFT;
-		if (vf_cfg->vlan_tag != vlan) {
-			/* If this is new value, program it. Else skip. */
-			vf_cfg->vlan_tag = vlan;
+		if (vf_cfg->vlan_tag != vlan)
 			status = be_cmd_set_hsw_config(adapter, vlan, vf + 1,
 						       vf_cfg->if_handle, 0);
-		}
 	} else {
 		/* Reset Transparent Vlan Tagging. */
-		vf_cfg->vlan_tag = 0;
-		vlan = vf_cfg->def_vid;
-		status = be_cmd_set_hsw_config(adapter, vlan, vf + 1,
-					       vf_cfg->if_handle, 0);
+		status = be_cmd_set_hsw_config(adapter, BE_RESET_VLAN_TAG_ID,
+					       vf + 1, vf_cfg->if_handle, 0);
 	}
 
-
-	if (status)
+	if (!status)
+		vf_cfg->vlan_tag = vlan;
+	else
 		dev_info(&adapter->pdev->dev,
-				"VLAN %d config on VF %d failed\n", vlan, vf);
+			 "VLAN %d config on VF %d failed\n", vlan, vf);
 	return status;
 }
 
@@ -3013,11 +3009,11 @@ static int be_vf_setup_init(struct be_adapter *adapter)
 
 static int be_vf_setup(struct be_adapter *adapter)
 {
+	struct device *dev = &adapter->pdev->dev;
 	struct be_vf_cfg *vf_cfg;
-	u16 def_vlan, lnk_speed;
 	int status, old_vfs, vf;
-	struct device *dev = &adapter->pdev->dev;
 	u32 privileges;
+	u16 lnk_speed;
 
 	old_vfs = pci_num_vf(adapter->pdev);
 	if (old_vfs) {
@@ -3084,12 +3080,6 @@ static int be_vf_setup(struct be_adapter *adapter)
 		if (!status)
 			vf_cfg->tx_rate = lnk_speed;
 
-		status = be_cmd_get_hsw_config(adapter, &def_vlan,
-					       vf + 1, vf_cfg->if_handle, NULL);
-		if (status)
-			goto err;
-		vf_cfg->def_vid = def_vlan;
-
 		if (!old_vfs)
 			be_cmd_enable_vf(adapter, vf + 1);
 	}
-- 
1.5.6.1
