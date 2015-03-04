From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 2/3] be2net: re-distribute SRIOV resources allowed by FW
Date: Wed, 4 Mar 2015 00:44:33 -0500
Message-ID: <1425447874-5406-3-git-send-email-sathya.perla@emulex.com>
References: <1425447874-5406-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.emulex.com ([138.239.224.100]:38634 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753917AbbCDFlg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Mar 2015 00:41:36 -0500
In-Reply-To: <1425447874-5406-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasundhara Volam <vasundhara.volam@emulex.com>

When SR-IOV is enabled in the adapter, the FW distributes resources
evenly across the PF and it's VFs. This is currently done only for some
resources.

This patch adds support for a new cmd that queries the FW for the list
of resources for which the distribution is allowed and distributes them
accordingly.

Signed-off-by: Vasundhara Volam <vasundhara.volam@emulex.com>
Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be.h      |   4 ++
 drivers/net/ethernet/emulex/benet/be_cmds.c | 108 ++++++++++++++++++++--------
 drivers/net/ethernet/emulex/benet/be_cmds.h |  18 +++--
 drivers/net/ethernet/emulex/benet/be_main.c |  49 +++++++++++--
 4 files changed, 141 insertions(+), 38 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be.h b/drivers/net/ethernet/emulex/benet/be.h
index 7e13fab..996bbc6 100644
--- a/drivers/net/ethernet/emulex/benet/be.h
+++ b/drivers/net/ethernet/emulex/benet/be.h
@@ -87,6 +87,7 @@
 #define BE3_MAX_EVT_QS		16
 #define BE3_SRIOV_MAX_EVT_QS	8
 
+#define MAX_RSS_IFACES		15
 #define MAX_RX_QS		32
 #define MAX_EVT_QS		32
 #define MAX_TX_QS		32
@@ -411,8 +412,11 @@ struct be_resources {
 	u16 max_tx_qs;
 	u16 max_rss_qs;
 	u16 max_rx_qs;
+	u16 max_cq_count;
 	u16 max_uc_mac;		/* Max UC MACs programmable */
 	u16 max_vlans;		/* Number of vlans supported */
+	u16 max_iface_count;
+	u16 max_mcc_count;
 	u16 max_evt_qs;
 	u32 if_cap_flags;
 	u32 vf_if_cap_flags;	/* VF if capability flags */
diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index 43dea7a..4a97cbf 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -3577,6 +3577,9 @@ static void be_copy_nic_desc(struct be_resources *res,
 	res->max_rss_qs = le16_to_cpu(desc->rssq_count);
 	res->max_rx_qs = le16_to_cpu(desc->rq_count);
 	res->max_evt_qs = le16_to_cpu(desc->eq_count);
+	res->max_cq_count = le16_to_cpu(desc->cq_count);
+	res->max_iface_count = le16_to_cpu(desc->iface_count);
+	res->max_mcc_count = le16_to_cpu(desc->mcc_count);
 	/* Clear flags that driver is not interested in */
 	res->if_cap_flags = le32_to_cpu(desc->cap_flags) &
 				BE_IF_CAP_FLAGS_WANT;
@@ -3641,7 +3644,7 @@ err:
 
 /* Will use MBOX only if MCCQ has not been created */
 int be_cmd_get_profile_config(struct be_adapter *adapter,
-			      struct be_resources *res, u8 domain)
+			      struct be_resources *res, u8 query, u8 domain)
 {
 	struct be_cmd_resp_get_profile_config *resp;
 	struct be_cmd_req_get_profile_config *req;
@@ -3651,7 +3654,7 @@ int be_cmd_get_profile_config(struct be_adapter *adapter,
 	struct be_nic_res_desc *nic;
 	struct be_mcc_wrb wrb = {0};
 	struct be_dma_mem cmd;
-	u32 desc_count;
+	u16 desc_count;
 	int status;
 
 	memset(&cmd, 0, sizeof(struct be_dma_mem));
@@ -3670,12 +3673,19 @@ int be_cmd_get_profile_config(struct be_adapter *adapter,
 		req->hdr.version = 1;
 	req->type = ACTIVE_PROFILE_TYPE;
 
+	/* When QUERY_MODIFIABLE_FIELDS_TYPE bit is set, cmd returns the
+	 * descriptors with all bits set to "1" for the fields which can be
+	 * modified using SET_PROFILE_CONFIG cmd.
+	 */
+	if (query == RESOURCE_MODIFIABLE)
+		req->type |= QUERY_MODIFIABLE_FIELDS_TYPE;
+
 	status = be_cmd_notify_wait(adapter, &wrb);
 	if (status)
 		goto err;
 
 	resp = cmd.va;
-	desc_count = le32_to_cpu(resp->desc_count);
+	desc_count = le16_to_cpu(resp->desc_count);
 
 	pcie = be_get_pcie_desc(adapter->pdev->devfn, resp->func_param,
 				desc_count);
@@ -3800,14 +3810,74 @@ int be_cmd_config_qos(struct be_adapter *adapter, u32 max_rate, u16 link_speed,
 					 1, version, domain);
 }
 
+static void be_fill_vf_res_template(struct be_adapter *adapter,
+				    struct be_resources pool_res,
+				    u16 num_vfs, u16 num_vf_qs,
+				    struct be_nic_res_desc *nic_vft)
+{
+	u32 vf_if_cap_flags = pool_res.vf_if_cap_flags;
+	struct be_resources res_mod = {0};
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
+		nic_vft->flags |= BIT(IF_CAPS_FLAGS_VALID_SHIFT);
+		if (num_vf_qs > 1) {
+			vf_if_cap_flags |= BE_IF_FLAGS_RSS;
+			if (pool_res.if_cap_flags & BE_IF_FLAGS_DEFQ_RSS)
+				vf_if_cap_flags |= BE_IF_FLAGS_DEFQ_RSS;
+		} else {
+			vf_if_cap_flags &= ~(BE_IF_FLAGS_RSS |
+					     BE_IF_FLAGS_DEFQ_RSS);
+		}
+
+		nic_vft->cap_flags = cpu_to_le32(vf_if_cap_flags);
+	} else {
+		num_vf_qs = 1;
+	}
+
+	nic_vft->rq_count = cpu_to_le16(num_vf_qs);
+	nic_vft->txq_count = cpu_to_le16(num_vf_qs);
+	nic_vft->rssq_count = cpu_to_le16(num_vf_qs);
+	nic_vft->cq_count = cpu_to_le16(pool_res.max_cq_count /
+					(num_vfs + 1));
+
+	/* Distribute unicast MACs, VLANs, IFACE count and MCCQ count equally
+	 * among the PF and it's VFs, if the fields are changeable
+	 */
+	if (res_mod.max_uc_mac == FIELD_MODIFIABLE)
+		nic_vft->unicast_mac_count = cpu_to_le16(pool_res.max_uc_mac /
+							 (num_vfs + 1));
+
+	if (res_mod.max_vlans == FIELD_MODIFIABLE)
+		nic_vft->vlan_count = cpu_to_le16(pool_res.max_vlans /
+						  (num_vfs + 1));
+
+	if (res_mod.max_iface_count == FIELD_MODIFIABLE)
+		nic_vft->iface_count = cpu_to_le16(pool_res.max_iface_count /
+						   (num_vfs + 1));
+
+	if (res_mod.max_mcc_count == FIELD_MODIFIABLE)
+		nic_vft->mcc_count = cpu_to_le16(pool_res.max_mcc_count /
+						 (num_vfs + 1));
+}
+
 int be_cmd_set_sriov_config(struct be_adapter *adapter,
-			    struct be_resources res, u16 num_vfs)
+			    struct be_resources pool_res, u16 num_vfs,
+			    u16 num_vf_qs)
 {
 	struct {
 		struct be_pcie_res_desc pcie;
 		struct be_nic_res_desc nic_vft;
 	} __packed desc;
-	u16 vf_q_count;
 
 	if (BEx_chip(adapter) || lancer_chip(adapter))
 		return 0;
@@ -3816,7 +3886,7 @@ int be_cmd_set_sriov_config(struct be_adapter *adapter,
 	be_reset_pcie_desc(&desc.pcie);
 	desc.pcie.hdr.desc_type = PCIE_RESOURCE_DESC_TYPE_V1;
 	desc.pcie.hdr.desc_len = RESOURCE_DESC_SIZE_V1;
-	desc.pcie.flags = (1 << IMM_SHIFT) | (1 << NOSV_SHIFT);
+	desc.pcie.flags = BIT(IMM_SHIFT) | BIT(NOSV_SHIFT);
 	desc.pcie.pf_num = adapter->pdev->devfn;
 	desc.pcie.sriov_state = num_vfs ? 1 : 0;
 	desc.pcie.num_vfs = cpu_to_le16(num_vfs);
@@ -3825,32 +3895,12 @@ int be_cmd_set_sriov_config(struct be_adapter *adapter,
 	be_reset_nic_desc(&desc.nic_vft);
 	desc.nic_vft.hdr.desc_type = NIC_RESOURCE_DESC_TYPE_V1;
 	desc.nic_vft.hdr.desc_len = RESOURCE_DESC_SIZE_V1;
-	desc.nic_vft.flags = (1 << VFT_SHIFT) | (1 << IMM_SHIFT) |
-				(1 << NOSV_SHIFT);
+	desc.nic_vft.flags = BIT(VFT_SHIFT) | BIT(IMM_SHIFT) | BIT(NOSV_SHIFT);
 	desc.nic_vft.pf_num = adapter->pdev->devfn;
 	desc.nic_vft.vf_num = 0;
 
-	if (num_vfs && res.vf_if_cap_flags & BE_IF_FLAGS_RSS) {
-		/* If number of VFs requested is 8 less than max supported,
-		 * assign 8 queue pairs to the PF and divide the remaining
-		 * resources evenly among the VFs
-		 */
-		if (num_vfs < (be_max_vfs(adapter) - 8))
-			vf_q_count = (res.max_rss_qs - 8) / num_vfs;
-		else
-			vf_q_count = res.max_rss_qs / num_vfs;
-
-		desc.nic_vft.rq_count = cpu_to_le16(vf_q_count);
-		desc.nic_vft.txq_count = cpu_to_le16(vf_q_count);
-		desc.nic_vft.rssq_count = cpu_to_le16(vf_q_count - 1);
-		desc.nic_vft.cq_count = cpu_to_le16(3 * vf_q_count);
-	} else {
-		desc.nic_vft.txq_count = cpu_to_le16(1);
-		desc.nic_vft.rq_count = cpu_to_le16(1);
-		desc.nic_vft.rssq_count = cpu_to_le16(0);
-		/* One CQ for each TX, RX and MCCQ */
-		desc.nic_vft.cq_count = cpu_to_le16(3);
-	}
+	be_fill_vf_res_template(adapter, pool_res, num_vfs, num_vf_qs,
+				&desc.nic_vft);
 
 	return be_cmd_set_profile_config(adapter, &desc,
 					 2 * RESOURCE_DESC_SIZE_V1, 2, 1, 0);
diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.h b/drivers/net/ethernet/emulex/benet/be_cmds.h
index 4951482..53e903f 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.h
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.h
@@ -2022,6 +2022,7 @@ struct be_cmd_req_set_ext_fat_caps {
 #define PORT_RESOURCE_DESC_TYPE_V1		0x55
 #define MAX_RESOURCE_DESC			264
 
+#define IF_CAPS_FLAGS_VALID_SHIFT		0	/* IF caps valid */
 #define VFT_SHIFT				3	/* VF template */
 #define IMM_SHIFT				6	/* Immediate */
 #define NOSV_SHIFT				7	/* No save */
@@ -2132,20 +2133,28 @@ struct be_cmd_resp_get_func_config {
 	u8 func_param[MAX_RESOURCE_DESC * RESOURCE_DESC_SIZE_V1];
 };
 
-#define ACTIVE_PROFILE_TYPE			0x2
+enum {
+	RESOURCE_LIMITS,
+	RESOURCE_MODIFIABLE
+};
+
 struct be_cmd_req_get_profile_config {
 	struct be_cmd_req_hdr hdr;
 	u8 rsvd;
+#define ACTIVE_PROFILE_TYPE			0x2
+#define QUERY_MODIFIABLE_FIELDS_TYPE		BIT(3)
 	u8 type;
 	u16 rsvd1;
 };
 
 struct be_cmd_resp_get_profile_config {
 	struct be_cmd_resp_hdr hdr;
-	u32 desc_count;
+	__le16 desc_count;
+	u16 rsvd;
 	u8 func_param[MAX_RESOURCE_DESC * RESOURCE_DESC_SIZE_V1];
 };
 
+#define FIELD_MODIFIABLE			0xFFFF
 struct be_cmd_req_set_profile_config {
 	struct be_cmd_req_hdr hdr;
 	u32 rsvd;
@@ -2345,7 +2354,7 @@ int be_cmd_query_port_name(struct be_adapter *adapter);
 int be_cmd_get_func_config(struct be_adapter *adapter,
 			   struct be_resources *res);
 int be_cmd_get_profile_config(struct be_adapter *adapter,
-			      struct be_resources *res, u8 domain);
+			      struct be_resources *res, u8 query, u8 domain);
 int be_cmd_get_active_profile(struct be_adapter *adapter, u16 *profile);
 int be_cmd_get_if_id(struct be_adapter *adapter, struct be_vf_cfg *vf_cfg,
 		     int vf_num);
@@ -2356,4 +2365,5 @@ int be_cmd_set_logical_link_config(struct be_adapter *adapter,
 int be_cmd_set_vxlan_port(struct be_adapter *adapter, __be16 port);
 int be_cmd_manage_iface(struct be_adapter *adapter, u32 iface, u8 op);
 int be_cmd_set_sriov_config(struct be_adapter *adapter,
-			    struct be_resources res, u16 num_vfs);
+			    struct be_resources res, u16 num_vfs,
+			    u16 num_vf_qs);
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 6121a04..5f1e018 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -3408,8 +3408,39 @@ static void be_disable_vxlan_offloads(struct be_adapter *adapter)
 }
 #endif
 
+static u16 be_calculate_vf_qs(struct be_adapter *adapter, u16 num_vfs)
+{
+	struct be_resources res = adapter->pool_res;
+	u16 num_vf_qs = 1;
+
+	/* Distribute the queue resources equally among the PF and it's VFs
+	 * Do not distribute queue resources in multi-channel configuration.
+	 */
+	if (num_vfs && !be_is_mc(adapter)) {
+		/* If number of VFs requested is 8 less than max supported,
+		 * assign 8 queue pairs to the PF and divide the remaining
+		 * resources evenly among the VFs
+		 */
+		if (num_vfs < (be_max_vfs(adapter) - 8))
+			num_vf_qs = (res.max_rss_qs - 8) / num_vfs;
+		else
+			num_vf_qs = res.max_rss_qs / num_vfs;
+
+		/* Skyhawk-R chip supports only MAX_RSS_IFACES RSS capable
+		 * interfaces per port. Provide RSS on VFs, only if number
+		 * of VFs requested is less than MAX_RSS_IFACES limit.
+		 */
+		if (num_vfs >= MAX_RSS_IFACES)
+			num_vf_qs = 1;
+	}
+	return num_vf_qs;
+}
+
 static int be_clear(struct be_adapter *adapter)
 {
+	struct pci_dev *pdev = adapter->pdev;
+	u16 num_vf_qs;
+
 	be_cancel_worker(adapter);
 
 	if (sriov_enabled(adapter))
@@ -3418,9 +3449,13 @@ static int be_clear(struct be_adapter *adapter)
 	/* Re-configure FW to distribute resources evenly across max-supported
 	 * number of VFs, only when VFs are not already enabled.
 	 */
-	if (be_physfn(adapter) && !pci_vfs_assigned(adapter->pdev))
+	if (be_physfn(adapter) && !pci_vfs_assigned(pdev)) {
+		num_vf_qs = be_calculate_vf_qs(adapter,
+					       pci_sriov_get_totalvfs(pdev));
 		be_cmd_set_sriov_config(adapter, adapter->pool_res,
-					pci_sriov_get_totalvfs(adapter->pdev));
+					pci_sriov_get_totalvfs(pdev),
+					num_vf_qs);
+	}
 
 #ifdef CONFIG_BE2NET_VXLAN
 	be_disable_vxlan_offloads(adapter);
@@ -3469,6 +3504,7 @@ static int be_vfs_if_create(struct be_adapter *adapter)
 	for_all_vfs(adapter, vf_cfg, vf) {
 		if (!BE3_chip(adapter)) {
 			status = be_cmd_get_profile_config(adapter, &res,
+							   RESOURCE_LIMITS,
 							   vf + 1);
 			if (!status)
 				cap_flags = res.if_cap_flags;
@@ -3635,7 +3671,8 @@ static void BEx_get_resources(struct be_adapter *adapter,
 		/* On a SuperNIC profile, the driver needs to use the
 		 * GET_PROFILE_CONFIG cmd to query the per-function TXQ limits
 		 */
-		be_cmd_get_profile_config(adapter, &super_nic_res, 0);
+		be_cmd_get_profile_config(adapter, &super_nic_res,
+					  RESOURCE_LIMITS, 0);
 		/* Some old versions of BE3 FW don't report max_tx_qs value */
 		res->max_tx_qs = super_nic_res.max_tx_qs ? : BE3_MAX_TX_QS;
 	} else {
@@ -3680,7 +3717,7 @@ static int be_get_sriov_config(struct be_adapter *adapter)
 	int max_vfs, old_vfs;
 
 	/* Some old versions of BE3 FW don't report max_vfs value */
-	be_cmd_get_profile_config(adapter, &res, 0);
+	be_cmd_get_profile_config(adapter, &res, RESOURCE_LIMITS, 0);
 
 	if (BE3_chip(adapter) && !res.max_vfs) {
 		max_vfs = pci_sriov_get_totalvfs(adapter->pdev);
@@ -3769,6 +3806,7 @@ static int be_get_resources(struct be_adapter *adapter)
 static void be_sriov_config(struct be_adapter *adapter)
 {
 	struct device *dev = &adapter->pdev->dev;
+	u16 num_vf_qs;
 	int status;
 
 	status = be_get_sriov_config(adapter);
@@ -3787,9 +3825,10 @@ static void be_sriov_config(struct be_adapter *adapter)
 	 * Also, this is done by FW in Lancer chip.
 	 */
 	if (be_max_vfs(adapter) && !pci_num_vf(adapter->pdev)) {
+		num_vf_qs = be_calculate_vf_qs(adapter, adapter->num_vfs);
 		status = be_cmd_set_sriov_config(adapter,
 						 adapter->pool_res,
-						 adapter->num_vfs);
+						 adapter->num_vfs, num_vf_qs);
 		if (status)
 			dev_err(dev, "Failed to optimize SR-IOV resources\n");
 	}
-- 
2.2.0
