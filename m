From: Sathya Perla <sathya.perla@broadcom.com>
Subject: [net-next PATCH 1/3] be2net: use max-TXQs limit too while provisioning VF queue pairs
Date: Mon,  6 Jun 2016 07:22:08 -0400
Message-ID: <1465212130-510-2-git-send-email-sathya.perla@broadcom.com>
References: <1465212130-510-1-git-send-email-sathya.perla@broadcom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [192.19.245.250] ([192.19.245.250]:15324 "EHLO
	CMRELAYP1.ad.emulex.com" rhost-flags-FAIL-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751004AbcFFLkH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jun 2016 07:40:07 -0400
In-Reply-To: <1465212130-510-1-git-send-email-sathya.perla@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Suresh Reddy <suresh.reddy@broadcom.com>

When the PF driver provisions resources for VFs, it currently only looks
at max RSS queues available to calculate the number of VF queue pairs.
This logic breaks when there are less number of TX-queues than RSS-queues.
This patch fixes this problem by using the max-TXQs available in the
PF-pool in the calculations. As a part of this change the
be_calculate_vf_qs() routine is renamed as be_calculate_vf_res() and the
code that calculates limits on other related resources is moved here to
contain all resource calculation code inside one routine.

Signed-off-by: Suresh Reddy <suresh.reddy@broadcom.com>
Signed-off-by: Sathya Perla <sathya.perla@broadcom.com>
---
 drivers/net/ethernet/emulex/benet/be.h      |  1 +
 drivers/net/ethernet/emulex/benet/be_cmds.c | 90 +++++++----------------------
 drivers/net/ethernet/emulex/benet/be_cmds.h |  2 +-
 drivers/net/ethernet/emulex/benet/be_main.c | 82 +++++++++++++++++++++-----
 4 files changed, 90 insertions(+), 85 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be.h b/drivers/net/ethernet/emulex/benet/be.h
index fe3763d..ee0bdb7 100644
--- a/drivers/net/ethernet/emulex/benet/be.h
+++ b/drivers/net/ethernet/emulex/benet/be.h
@@ -444,6 +444,7 @@ struct be_resources {
 	u16 max_evt_qs;
 	u32 if_cap_flags;
 	u32 vf_if_cap_flags;	/* VF if capability flags */
+	u32 flags;
 };
 
 #define be_is_os2bmc_enabled(adapter) (adapter->flags & BE_FLAGS_OS2BMC)
diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index 22402db..bef92c4 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -4465,7 +4465,7 @@ static int be_cmd_set_profile_config(struct be_adapter *adapter, void *desc,
 }
 
 /* Mark all fields invalid */
-static void be_reset_nic_desc(struct be_nic_res_desc *nic)
+void be_reset_nic_desc(struct be_nic_res_desc *nic)
 {
 	memset(nic, 0, sizeof(*nic));
 	nic->unicast_mac_count = 0xFFFF;
@@ -4534,73 +4534,9 @@ int be_cmd_config_qos(struct be_adapter *adapter, u32 max_rate, u16 link_speed,
 					 1, version, domain);
 }
 
-static void be_fill_vf_res_template(struct be_adapter *adapter,
-				    struct be_resources pool_res,
-				    u16 num_vfs, u16 num_vf_qs,
-				    struct be_nic_res_desc *nic_vft)
-{
-	u32 vf_if_cap_flags = pool_res.vf_if_cap_flags;
-	struct be_resources res_mod = {0};
-
-	/* Resource with fields set to all '1's by GET_PROFILE_CONFIG cmd,
-	 * which are modifiable using SET_PROFILE_CONFIG cmd.
-	 */
-	be_cmd_get_profile_config(adapter, &res_mod, RESOURCE_MODIFIABLE, 0);
-
-	/* If RSS IFACE capability flags are modifiable for a VF, set the
-	 * capability flag as valid and set RSS and DEFQ_RSS IFACE flags if
-	 * more than 1 RSSQ is available for a VF.
-	 * Otherwise, provision only 1 queue pair for VF.
-	 */
-	if (res_mod.vf_if_cap_flags & BE_IF_FLAGS_RSS) {
-		nic_vft->flags |= BIT(IF_CAPS_FLAGS_VALID_SHIFT);
-		if (num_vf_qs > 1) {
-			vf_if_cap_flags |= BE_IF_FLAGS_RSS;
-			if (pool_res.if_cap_flags & BE_IF_FLAGS_DEFQ_RSS)
-				vf_if_cap_flags |= BE_IF_FLAGS_DEFQ_RSS;
-		} else {
-			vf_if_cap_flags &= ~(BE_IF_FLAGS_RSS |
-					     BE_IF_FLAGS_DEFQ_RSS);
-		}
-	} else {
-		num_vf_qs = 1;
-	}
-
-	if (res_mod.vf_if_cap_flags & BE_IF_FLAGS_VLAN_PROMISCUOUS) {
-		nic_vft->flags |= BIT(IF_CAPS_FLAGS_VALID_SHIFT);
-		vf_if_cap_flags &= ~BE_IF_FLAGS_VLAN_PROMISCUOUS;
-	}
-
-	nic_vft->cap_flags = cpu_to_le32(vf_if_cap_flags);
-	nic_vft->rq_count = cpu_to_le16(num_vf_qs);
-	nic_vft->txq_count = cpu_to_le16(num_vf_qs);
-	nic_vft->rssq_count = cpu_to_le16(num_vf_qs);
-	nic_vft->cq_count = cpu_to_le16(pool_res.max_cq_count /
-					(num_vfs + 1));
-
-	/* Distribute unicast MACs, VLANs, IFACE count and MCCQ count equally
-	 * among the PF and it's VFs, if the fields are changeable
-	 */
-	if (res_mod.max_uc_mac == FIELD_MODIFIABLE)
-		nic_vft->unicast_mac_count = cpu_to_le16(pool_res.max_uc_mac /
-							 (num_vfs + 1));
-
-	if (res_mod.max_vlans == FIELD_MODIFIABLE)
-		nic_vft->vlan_count = cpu_to_le16(pool_res.max_vlans /
-						  (num_vfs + 1));
-
-	if (res_mod.max_iface_count == FIELD_MODIFIABLE)
-		nic_vft->iface_count = cpu_to_le16(pool_res.max_iface_count /
-						   (num_vfs + 1));
-
-	if (res_mod.max_mcc_count == FIELD_MODIFIABLE)
-		nic_vft->mcc_count = cpu_to_le16(pool_res.max_mcc_count /
-						 (num_vfs + 1));
-}
-
 int be_cmd_set_sriov_config(struct be_adapter *adapter,
 			    struct be_resources pool_res, u16 num_vfs,
-			    u16 num_vf_qs)
+			    struct be_resources *vft_res)
 {
 	struct {
 		struct be_pcie_res_desc pcie;
@@ -4620,12 +4556,26 @@ int be_cmd_set_sriov_config(struct be_adapter *adapter,
 	be_reset_nic_desc(&desc.nic_vft);
 	desc.nic_vft.hdr.desc_type = NIC_RESOURCE_DESC_TYPE_V1;
 	desc.nic_vft.hdr.desc_len = RESOURCE_DESC_SIZE_V1;
-	desc.nic_vft.flags = BIT(VFT_SHIFT) | BIT(IMM_SHIFT) | BIT(NOSV_SHIFT);
+	desc.nic_vft.flags = vft_res->flags | BIT(VFT_SHIFT) |
+			     BIT(IMM_SHIFT) | BIT(NOSV_SHIFT);
 	desc.nic_vft.pf_num = adapter->pdev->devfn;
 	desc.nic_vft.vf_num = 0;
-
-	be_fill_vf_res_template(adapter, pool_res, num_vfs, num_vf_qs,
-				&desc.nic_vft);
+	desc.nic_vft.cap_flags = cpu_to_le32(vft_res->vf_if_cap_flags);
+	desc.nic_vft.rq_count = cpu_to_le16(vft_res->max_rx_qs);
+	desc.nic_vft.txq_count = cpu_to_le16(vft_res->max_tx_qs);
+	desc.nic_vft.rssq_count = cpu_to_le16(vft_res->max_rss_qs);
+	desc.nic_vft.cq_count = cpu_to_le16(vft_res->max_cq_count);
+
+	if (vft_res->max_uc_mac)
+		desc.nic_vft.unicast_mac_count =
+					cpu_to_le16(vft_res->max_uc_mac);
+	if (vft_res->max_vlans)
+		desc.nic_vft.vlan_count = cpu_to_le16(vft_res->max_vlans);
+	if (vft_res->max_iface_count)
+		desc.nic_vft.iface_count =
+				cpu_to_le16(vft_res->max_iface_count);
+	if (vft_res->max_mcc_count)
+		desc.nic_vft.mcc_count = cpu_to_le16(vft_res->max_mcc_count);
 
 	return be_cmd_set_profile_config(adapter, &desc,
 					 2 * RESOURCE_DESC_SIZE_V1, 2, 1, 0);
diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.h b/drivers/net/ethernet/emulex/benet/be_cmds.h
index d8540ae..b63ae37 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.h
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.h
@@ -2461,4 +2461,4 @@ int be_cmd_set_vxlan_port(struct be_adapter *adapter, __be16 port);
 int be_cmd_manage_iface(struct be_adapter *adapter, u32 iface, u8 op);
 int be_cmd_set_sriov_config(struct be_adapter *adapter,
 			    struct be_resources res, u16 num_vfs,
-			    u16 num_vf_qs);
+			    struct be_resources *vft_res);
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index ed98ef1..8601047 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -3810,17 +3810,20 @@ static void be_disable_vxlan_offloads(struct be_adapter *adapter)
 }
 #endif
 
-static u16 be_calculate_vf_qs(struct be_adapter *adapter, u16 num_vfs)
+static void be_calculate_vf_res(struct be_adapter *adapter, u16 num_vfs,
+				struct be_resources *vft_res)
 {
 	struct be_resources res = adapter->pool_res;
+	u32 vf_if_cap_flags = res.vf_if_cap_flags;
+	struct be_resources res_mod = {0};
 	u16 num_vf_qs = 1;
 
 	/* Distribute the queue resources among the PF and it's VFs
 	 * Do not distribute queue resources in multi-channel configuration.
 	 */
 	if (num_vfs && !be_is_mc(adapter)) {
-		 /* Divide the qpairs evenly among the VFs and the PF, capped
-		  * at VF-EQ-count. Any remainder qpairs belong to the PF.
+		 /* Divide the rx queues evenly among the VFs and the PF, capped
+		  * at VF-EQ-count. Any remainder queues belong to the PF.
 		  */
 		num_vf_qs = min(SH_VF_MAX_NIC_EQS,
 				res.max_rss_qs / (num_vfs + 1));
@@ -3832,13 +3835,62 @@ static u16 be_calculate_vf_qs(struct be_adapter *adapter, u16 num_vfs)
 		if (num_vfs >= MAX_RSS_IFACES)
 			num_vf_qs = 1;
 	}
-	return num_vf_qs;
+
+	/* Resource with fields set to all '1's by GET_PROFILE_CONFIG cmd,
+	 * which are modifiable using SET_PROFILE_CONFIG cmd.
+	 */
+	be_cmd_get_profile_config(adapter, &res_mod, RESOURCE_MODIFIABLE, 0);
+
+	/* If RSS IFACE capability flags are modifiable for a VF, set the
+	 * capability flag as valid and set RSS and DEFQ_RSS IFACE flags if
+	 * more than 1 RSSQ is available for a VF.
+	 * Otherwise, provision only 1 queue pair for VF.
+	 */
+	if (res_mod.vf_if_cap_flags & BE_IF_FLAGS_RSS) {
+		vft_res->flags |= BIT(IF_CAPS_FLAGS_VALID_SHIFT);
+		if (num_vf_qs > 1) {
+			vf_if_cap_flags |= BE_IF_FLAGS_RSS;
+			if (res.if_cap_flags & BE_IF_FLAGS_DEFQ_RSS)
+				vf_if_cap_flags |= BE_IF_FLAGS_DEFQ_RSS;
+		} else {
+			vf_if_cap_flags &= ~(BE_IF_FLAGS_RSS |
+					     BE_IF_FLAGS_DEFQ_RSS);
+		}
+	} else {
+		num_vf_qs = 1;
+	}
+
+	if (res_mod.vf_if_cap_flags & BE_IF_FLAGS_VLAN_PROMISCUOUS) {
+		vft_res->flags |= BIT(IF_CAPS_FLAGS_VALID_SHIFT);
+		vf_if_cap_flags &= ~BE_IF_FLAGS_VLAN_PROMISCUOUS;
+	}
+
+	vft_res->vf_if_cap_flags = vf_if_cap_flags;
+	vft_res->max_rx_qs = num_vf_qs;
+	vft_res->max_rss_qs = num_vf_qs;
+	vft_res->max_tx_qs = res.max_tx_qs / (num_vfs + 1);
+	vft_res->max_cq_count = res.max_cq_count / (num_vfs + 1);
+
+	/* Distribute unicast MACs, VLANs, IFACE count and MCCQ count equally
+	 * among the PF and it's VFs, if the fields are changeable
+	 */
+	if (res_mod.max_uc_mac == FIELD_MODIFIABLE)
+		vft_res->max_uc_mac = res.max_uc_mac / (num_vfs + 1);
+
+	if (res_mod.max_vlans == FIELD_MODIFIABLE)
+		vft_res->max_vlans = res.max_vlans / (num_vfs + 1);
+
+	if (res_mod.max_iface_count == FIELD_MODIFIABLE)
+		vft_res->max_iface_count = res.max_iface_count / (num_vfs + 1);
+
+	if (res_mod.max_mcc_count == FIELD_MODIFIABLE)
+		vft_res->max_mcc_count = res.max_mcc_count / (num_vfs + 1);
 }
 
 static int be_clear(struct be_adapter *adapter)
 {
 	struct pci_dev *pdev = adapter->pdev;
-	u16 num_vf_qs;
+	struct  be_resources vft_res = {0};
 
 	be_cancel_worker(adapter);
 
@@ -3850,11 +3902,12 @@ static int be_clear(struct be_adapter *adapter)
 	 */
 	if (skyhawk_chip(adapter) && be_physfn(adapter) &&
 	    !pci_vfs_assigned(pdev)) {
-		num_vf_qs = be_calculate_vf_qs(adapter,
-					       pci_sriov_get_totalvfs(pdev));
+		be_calculate_vf_res(adapter,
+				    pci_sriov_get_totalvfs(pdev),
+				    &vft_res);
 		be_cmd_set_sriov_config(adapter, adapter->pool_res,
 					pci_sriov_get_totalvfs(pdev),
-					num_vf_qs);
+					&vft_res);
 	}
 
 #ifdef CONFIG_BE2NET_VXLAN
@@ -4144,7 +4197,7 @@ static int be_get_sriov_config(struct be_adapter *adapter)
 static void be_alloc_sriov_res(struct be_adapter *adapter)
 {
 	int old_vfs = pci_num_vf(adapter->pdev);
-	u16 num_vf_qs;
+	struct  be_resources vft_res = {0};
 	int status;
 
 	be_get_sriov_config(adapter);
@@ -4158,9 +4211,9 @@ static void be_alloc_sriov_res(struct be_adapter *adapter)
 	 * Also, this is done by FW in Lancer chip.
 	 */
 	if (skyhawk_chip(adapter) && be_max_vfs(adapter) && !old_vfs) {
-		num_vf_qs = be_calculate_vf_qs(adapter, 0);
+		be_calculate_vf_res(adapter, 0, &vft_res);
 		status = be_cmd_set_sriov_config(adapter, adapter->pool_res, 0,
-						 num_vf_qs);
+						 &vft_res);
 		if (status)
 			dev_err(&adapter->pdev->dev,
 				"Failed to optimize SRIOV resources\n");
@@ -5552,7 +5605,7 @@ err:
 static int be_pci_sriov_configure(struct pci_dev *pdev, int num_vfs)
 {
 	struct be_adapter *adapter = pci_get_drvdata(pdev);
-	u16 num_vf_qs;
+	struct be_resources vft_res = {0};
 	int status;
 
 	if (!num_vfs)
@@ -5575,9 +5628,10 @@ static int be_pci_sriov_configure(struct pci_dev *pdev, int num_vfs)
 	 * Also, this is done by FW in Lancer chip.
 	 */
 	if (skyhawk_chip(adapter) && !pci_num_vf(pdev)) {
-		num_vf_qs = be_calculate_vf_qs(adapter, adapter->num_vfs);
+		be_calculate_vf_res(adapter, adapter->num_vfs,
+				    &vft_res);
 		status = be_cmd_set_sriov_config(adapter, adapter->pool_res,
-						 adapter->num_vfs, num_vf_qs);
+						 adapter->num_vfs, &vft_res);
 		if (status)
 			dev_err(&pdev->dev,
 				"Failed to optimize SR-IOV resources\n");
-- 
2.4.1
