From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH 1/3] be2net: Prevent VFs from enabling VLAN promiscuous mode
Date: Fri, 20 Mar 2015 06:28:23 -0400
Message-ID: <1426847305-23008-2-git-send-email-sathya.perla@emulex.com>
References: <1426847305-23008-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.emulex.com ([138.239.224.99]:49488 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751820AbbCTKZW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2015 06:25:22 -0400
In-Reply-To: <1426847305-23008-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasundhara Volam <vasundhara.volam@emulex.com>

Currently, a PF does not restrict its VF interface from enabling vlan
promiscuous mode. This breaks vlan isolation when a vlan
(transparent tagging) is configured on a VF.

This patch fixes this problem by disabling the vlan promisc capability
for VFs.

Reported-by: Yoann Juet <veilletechno-irts@univ-nantes.fr>
Signed-off-by: Vasundhara Volam <vasundhara.volam@emulex.com>
Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be.h      |  1 +
 drivers/net/ethernet/emulex/benet/be_cmds.c |  3 +-
 drivers/net/ethernet/emulex/benet/be_cmds.h |  2 +-
 drivers/net/ethernet/emulex/benet/be_main.c | 98 ++++++++++++++++++++++-------
 4 files changed, 80 insertions(+), 24 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be.h b/drivers/net/ethernet/emulex/benet/be.h
index 27de37a..92eb0c8 100644
--- a/drivers/net/ethernet/emulex/benet/be.h
+++ b/drivers/net/ethernet/emulex/benet/be.h
@@ -354,6 +354,7 @@ struct be_vf_cfg {
 	u16 vlan_tag;
 	u32 tx_rate;
 	u32 plink_tracking;
+	u32 privileges;
 };
 
 enum vf_state {
diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index 36916cf..3e894f4 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -1918,7 +1918,7 @@ int be_cmd_modify_eqd(struct be_adapter *adapter, struct be_set_eqd *set_eqd,
 
 /* Uses sycnhronous mcc */
 int be_cmd_vlan_config(struct be_adapter *adapter, u32 if_id, u16 *vtag_array,
-		       u32 num)
+		       u32 num, u32 domain)
 {
 	struct be_mcc_wrb *wrb;
 	struct be_cmd_req_vlan_config *req;
@@ -1936,6 +1936,7 @@ int be_cmd_vlan_config(struct be_adapter *adapter, u32 if_id, u16 *vtag_array,
 	be_wrb_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
 			       OPCODE_COMMON_NTWK_VLAN_CONFIG, sizeof(*req),
 			       wrb, NULL);
+	req->hdr.domain = domain;
 
 	req->interface_id = if_id;
 	req->untagged = BE_IF_FLAGS_UNTAGGED & be_if_cap_flags(adapter) ? 1 : 0;
diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.h b/drivers/net/ethernet/emulex/benet/be_cmds.h
index db761e8e..a7634a3 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.h
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.h
@@ -2256,7 +2256,7 @@ int lancer_cmd_get_pport_stats(struct be_adapter *adapter,
 int be_cmd_get_fw_ver(struct be_adapter *adapter);
 int be_cmd_modify_eqd(struct be_adapter *adapter, struct be_set_eqd *, int num);
 int be_cmd_vlan_config(struct be_adapter *adapter, u32 if_id, u16 *vtag_array,
-		       u32 num);
+		       u32 num, u32 domain);
 int be_cmd_rx_filter(struct be_adapter *adapter, u32 flags, u32 status);
 int be_cmd_set_flow_control(struct be_adapter *adapter, u32 tx_fc, u32 rx_fc);
 int be_cmd_get_flow_control(struct be_adapter *adapter, u32 *tx_fc, u32 *rx_fc);
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 0a81685..eb2bed9 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -1171,7 +1171,7 @@ static int be_vid_config(struct be_adapter *adapter)
 	for_each_set_bit(i, adapter->vids, VLAN_N_VID)
 		vids[num++] = cpu_to_le16(i);
 
-	status = be_cmd_vlan_config(adapter, adapter->if_handle, vids, num);
+	status = be_cmd_vlan_config(adapter, adapter->if_handle, vids, num, 0);
 	if (status) {
 		dev_err(dev, "Setting HW VLAN filtering failed\n");
 		/* Set to VLAN promisc mode as setting VLAN filter failed */
@@ -1380,11 +1380,67 @@ static int be_get_vf_config(struct net_device *netdev, int vf,
 	return 0;
 }
 
+static int be_set_vf_tvt(struct be_adapter *adapter, int vf, u16 vlan)
+{
+	struct be_vf_cfg *vf_cfg = &adapter->vf_cfg[vf];
+	u16 vids[BE_NUM_VLANS_SUPPORTED];
+	int vf_if_id = vf_cfg->if_handle;
+	int status;
+
+	/* Enable Transparent VLAN Tagging */
+	status = be_cmd_set_hsw_config(adapter, vlan, vf + 1, vf_if_id, 0);
+	if (status)
+		return status;
+
+	/* Clear pre-programmed VLAN filters on VF if any, if TVT is enabled */
+	vids[0] = 0;
+	status = be_cmd_vlan_config(adapter, vf_if_id, vids, 1, vf + 1);
+	if (!status)
+		dev_info(&adapter->pdev->dev,
+			 "Cleared guest VLANs on VF%d", vf);
+
+	/* After TVT is enabled, disallow VFs to program VLAN filters */
+	if (vf_cfg->privileges & BE_PRIV_FILTMGMT) {
+		status = be_cmd_set_fn_privileges(adapter, vf_cfg->privileges &
+						  ~BE_PRIV_FILTMGMT, vf + 1);
+		if (!status)
+			vf_cfg->privileges &= ~BE_PRIV_FILTMGMT;
+	}
+	return 0;
+}
+
+static int be_clear_vf_tvt(struct be_adapter *adapter, int vf)
+{
+	struct be_vf_cfg *vf_cfg = &adapter->vf_cfg[vf];
+	struct device *dev = &adapter->pdev->dev;
+	int status;
+
+	/* Reset Transparent VLAN Tagging. */
+	status = be_cmd_set_hsw_config(adapter, BE_RESET_VLAN_TAG_ID, vf + 1,
+				       vf_cfg->if_handle, 0);
+	if (status)
+		return status;
+
+	/* Allow VFs to program VLAN filtering */
+	if (!(vf_cfg->privileges & BE_PRIV_FILTMGMT)) {
+		status = be_cmd_set_fn_privileges(adapter, vf_cfg->privileges |
+						  BE_PRIV_FILTMGMT, vf + 1);
+		if (!status) {
+			vf_cfg->privileges |= BE_PRIV_FILTMGMT;
+			dev_info(dev, "VF%d: FILTMGMT priv enabled", vf);
+		}
+	}
+
+	dev_info(dev,
+		 "Disable/re-enable i/f in VM to clear Transparent VLAN tag");
+	return 0;
+}
+
 static int be_set_vf_vlan(struct net_device *netdev, int vf, u16 vlan, u8 qos)
 {
 	struct be_adapter *adapter = netdev_priv(netdev);
 	struct be_vf_cfg *vf_cfg = &adapter->vf_cfg[vf];
-	int status = 0;
+	int status;
 
 	if (!sriov_enabled(adapter))
 		return -EPERM;
@@ -1394,24 +1450,19 @@ static int be_set_vf_vlan(struct net_device *netdev, int vf, u16 vlan, u8 qos)
 
 	if (vlan || qos) {
 		vlan |= qos << VLAN_PRIO_SHIFT;
-		if (vf_cfg->vlan_tag != vlan)
-			status = be_cmd_set_hsw_config(adapter, vlan, vf + 1,
-						       vf_cfg->if_handle, 0);
+		status = be_set_vf_tvt(adapter, vf, vlan);
 	} else {
-		/* Reset Transparent Vlan Tagging. */
-		status = be_cmd_set_hsw_config(adapter, BE_RESET_VLAN_TAG_ID,
-					       vf + 1, vf_cfg->if_handle, 0);
+		status = be_clear_vf_tvt(adapter, vf);
 	}
 
 	if (status) {
 		dev_err(&adapter->pdev->dev,
-			"VLAN %d config on VF %d failed : %#x\n", vlan,
-			vf, status);
+			"VLAN %d config on VF %d failed : %#x\n", vlan, vf,
+			status);
 		return be_cmd_status(status);
 	}
 
 	vf_cfg->vlan_tag = vlan;
-
 	return 0;
 }
 
@@ -3339,7 +3390,6 @@ static int be_if_create(struct be_adapter *adapter, u32 *if_handle,
 			u32 cap_flags, u32 vf)
 {
 	u32 en_flags;
-	int status;
 
 	en_flags = BE_IF_FLAGS_UNTAGGED | BE_IF_FLAGS_BROADCAST |
 		   BE_IF_FLAGS_MULTICAST | BE_IF_FLAGS_PASS_L3L4_ERRORS |
@@ -3347,10 +3397,7 @@ static int be_if_create(struct be_adapter *adapter, u32 *if_handle,
 
 	en_flags &= cap_flags;
 
-	status = be_cmd_if_create(adapter, cap_flags, en_flags,
-				  if_handle, vf);
-
-	return status;
+	return be_cmd_if_create(adapter, cap_flags, en_flags, if_handle, vf);
 }
 
 static int be_vfs_if_create(struct be_adapter *adapter)
@@ -3368,8 +3415,13 @@ static int be_vfs_if_create(struct be_adapter *adapter)
 		if (!BE3_chip(adapter)) {
 			status = be_cmd_get_profile_config(adapter, &res,
 							   vf + 1);
-			if (!status)
+			if (!status) {
 				cap_flags = res.if_cap_flags;
+				/* Prevent VFs from enabling VLAN promiscuous
+				 * mode
+				 */
+				cap_flags &= ~BE_IF_FLAGS_VLAN_PROMISCUOUS;
+			}
 		}
 
 		status = be_if_create(adapter, &vf_cfg->if_handle,
@@ -3403,7 +3455,6 @@ static int be_vf_setup(struct be_adapter *adapter)
 	struct device *dev = &adapter->pdev->dev;
 	struct be_vf_cfg *vf_cfg;
 	int status, old_vfs, vf;
-	u32 privileges;
 
 	old_vfs = pci_num_vf(adapter->pdev);
 
@@ -3433,15 +3484,18 @@ static int be_vf_setup(struct be_adapter *adapter)
 
 	for_all_vfs(adapter, vf_cfg, vf) {
 		/* Allow VFs to programs MAC/VLAN filters */
-		status = be_cmd_get_fn_privileges(adapter, &privileges, vf + 1);
-		if (!status && !(privileges & BE_PRIV_FILTMGMT)) {
+		status = be_cmd_get_fn_privileges(adapter, &vf_cfg->privileges,
+						  vf + 1);
+		if (!status && !(vf_cfg->privileges & BE_PRIV_FILTMGMT)) {
 			status = be_cmd_set_fn_privileges(adapter,
-							  privileges |
+							  vf_cfg->privileges |
 							  BE_PRIV_FILTMGMT,
 							  vf + 1);
-			if (!status)
+			if (!status) {
+				vf_cfg->privileges |= BE_PRIV_FILTMGMT;
 				dev_info(dev, "VF%d has FILTMGMT privilege\n",
 					 vf);
+			}
 		}
 
 		/* Allow full available bandwidth */
-- 
2.2.0
