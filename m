From: Sathya Perla <sathya.perla@broadcom.com>
Subject: [net-next PATCH 3/3] be2net: Fix provisioning of RSS for VFs in multi-partition configurations
Date: Mon,  6 Jun 2016 07:22:10 -0400
Message-ID: <1465212130-510-4-git-send-email-sathya.perla@broadcom.com>
References: <1465212130-510-1-git-send-email-sathya.perla@broadcom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [192.19.245.250] ([192.19.245.250]:15324 "EHLO
	CMRELAYP1.ad.emulex.com" rhost-flags-FAIL-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751004AbcFFLkJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jun 2016 07:40:09 -0400
In-Reply-To: <1465212130-510-1-git-send-email-sathya.perla@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Somnath Kotur <somnath.kotur@emulex.com>

Currently, we do not distribute queue resources to enable RSS for VFs
in multi-channel/partition configurations.
Fix this by having each PF(SRIOV capable) calculate it's share of the
15 RSS Policy Tables available per port before provisioning resources for
all the VFs.
This  proportional share calculation is done based on division of the
PF's MAX VFs with the Total MAX VFs on that port. It also needs to
learn about the no: of NIC PFs on the port and subtract that from
the 15 RSS Policy Tables on the port.

Signed-off-by: Somnath Kotur <somnath.kotur@emulex.com>
Signed-off-by: Sathya Perla <sathya.perla@broadcom.com>
---
 drivers/net/ethernet/emulex/benet/be.h      | 15 ++++-
 drivers/net/ethernet/emulex/benet/be_cmds.c | 52 +++++++++++++++++-
 drivers/net/ethernet/emulex/benet/be_cmds.h |  8 ++-
 drivers/net/ethernet/emulex/benet/be_main.c | 85 ++++++++++++++++++++---------
 4 files changed, 130 insertions(+), 30 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be.h b/drivers/net/ethernet/emulex/benet/be.h
index ee0bdb7..e1e6c40 100644
--- a/drivers/net/ethernet/emulex/benet/be.h
+++ b/drivers/net/ethernet/emulex/benet/be.h
@@ -97,7 +97,8 @@
 					 * SURF/DPDK
 					 */
 
-#define MAX_RSS_IFACES		15
+#define MAX_PORT_RSS_TABLES	15
+#define MAX_NIC_FUNCS		16
 #define MAX_RX_QS		32
 #define MAX_EVT_QS		32
 #define MAX_TX_QS		32
@@ -445,6 +446,16 @@ struct be_resources {
 	u32 if_cap_flags;
 	u32 vf_if_cap_flags;	/* VF if capability flags */
 	u32 flags;
+	/* Calculated PF Pool's share of RSS Tables. This is not enforced by
+	 * the FW, but is a self-imposed driver limitation.
+	 */
+	u16 max_rss_tables;
+};
+
+/* These are port-wide values */
+struct be_port_resources {
+	u16 max_vfs;
+	u16 nic_pfs;
 };
 
 #define be_is_os2bmc_enabled(adapter) (adapter->flags & BE_FLAGS_OS2BMC)
@@ -635,6 +646,8 @@ struct be_adapter {
 #define be_max_rxqs(adapter)		(adapter->res.max_rx_qs)
 #define be_max_eqs(adapter)		(adapter->res.max_evt_qs)
 #define be_if_cap_flags(adapter)	(adapter->res.if_cap_flags)
+#define be_max_pf_pool_rss_tables(adapter)	\
+				(adapter->pool_res.max_rss_tables)
 
 static inline u16 be_max_qs(struct be_adapter *adapter)
 {
diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index ddc8611..29aeb91 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -4363,9 +4363,35 @@ err:
 	return status;
 }
 
+/* This routine returns a list of all the NIC PF_nums in the adapter */
+u16 be_get_nic_pf_num_list(u8 *buf, u32 desc_count, u16 *nic_pf_nums)
+{
+	struct be_res_desc_hdr *hdr = (struct be_res_desc_hdr *)buf;
+	struct be_pcie_res_desc *pcie = NULL;
+	int i;
+	u16 nic_pf_count = 0;
+
+	for (i = 0; i < desc_count; i++) {
+		if (hdr->desc_type == PCIE_RESOURCE_DESC_TYPE_V0 ||
+		    hdr->desc_type == PCIE_RESOURCE_DESC_TYPE_V1) {
+			pcie = (struct be_pcie_res_desc *)hdr;
+			if (pcie->pf_state && (pcie->pf_type == MISSION_NIC ||
+					       pcie->pf_type == MISSION_RDMA)) {
+				nic_pf_nums[nic_pf_count++] = pcie->pf_num;
+			}
+		}
+
+		hdr->desc_len = hdr->desc_len ? : RESOURCE_DESC_SIZE_V0;
+		hdr = (void *)hdr + hdr->desc_len;
+	}
+	return nic_pf_count;
+}
+
 /* Will use MBOX only if MCCQ has not been created */
 int be_cmd_get_profile_config(struct be_adapter *adapter,
-			      struct be_resources *res, u8 query, u8 domain)
+			      struct be_resources *res,
+			      struct be_port_resources *port_res,
+			      u8 profile_type, u8 query, u8 domain)
 {
 	struct be_cmd_resp_get_profile_config *resp;
 	struct be_cmd_req_get_profile_config *req;
@@ -4392,7 +4418,7 @@ int be_cmd_get_profile_config(struct be_adapter *adapter,
 
 	if (!lancer_chip(adapter))
 		req->hdr.version = 1;
-	req->type = ACTIVE_PROFILE_TYPE;
+	req->type = profile_type;
 	req->hdr.domain = domain;
 
 	/* When QUERY_MODIFIABLE_FIELDS_TYPE bit is set, cmd returns the
@@ -4409,6 +4435,28 @@ int be_cmd_get_profile_config(struct be_adapter *adapter,
 	resp = cmd.va;
 	desc_count = le16_to_cpu(resp->desc_count);
 
+	if (port_res) {
+		u16 nic_pf_cnt = 0, i;
+		u16 nic_pf_num_list[MAX_NIC_FUNCS];
+
+		nic_pf_cnt = be_get_nic_pf_num_list(resp->func_param,
+						    desc_count,
+						    nic_pf_num_list);
+
+		for (i = 0; i < nic_pf_cnt; i++) {
+			nic = be_get_func_nic_desc(resp->func_param, desc_count,
+						   nic_pf_num_list[i]);
+			if (nic->link_param == adapter->port_num) {
+				port_res->nic_pfs++;
+				pcie = be_get_pcie_desc(resp->func_param,
+							desc_count,
+							nic_pf_num_list[i]);
+				port_res->max_vfs += le16_to_cpu(pcie->num_vfs);
+			}
+		}
+		return status;
+	}
+
 	pcie = be_get_pcie_desc(resp->func_param, desc_count,
 				adapter->pf_num);
 	if (pcie)
diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.h b/drivers/net/ethernet/emulex/benet/be_cmds.h
index 855a170..cb96ddd 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.h
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.h
@@ -2130,6 +2130,9 @@ struct be_cmd_req_set_ext_fat_caps {
 #define IMM_SHIFT				6	/* Immediate */
 #define NOSV_SHIFT				7	/* No save */
 
+#define MISSION_NIC				1
+#define MISSION_RDMA				8
+
 struct be_res_desc_hdr {
 	u8 desc_type;
 	u8 desc_len;
@@ -2246,6 +2249,7 @@ struct be_cmd_req_get_profile_config {
 	struct be_cmd_req_hdr hdr;
 	u8 rsvd;
 #define ACTIVE_PROFILE_TYPE			0x2
+#define SAVED_PROFILE_TYPE			0x0
 #define QUERY_MODIFIABLE_FIELDS_TYPE		BIT(3)
 	u8 type;
 	u16 rsvd1;
@@ -2451,7 +2455,9 @@ int be_cmd_query_port_name(struct be_adapter *adapter);
 int be_cmd_get_func_config(struct be_adapter *adapter,
 			   struct be_resources *res);
 int be_cmd_get_profile_config(struct be_adapter *adapter,
-			      struct be_resources *res, u8 query, u8 domain);
+			      struct be_resources *res,
+			      struct be_port_resources *port_res,
+			      u8 profile_type, u8 query, u8 domain);
 int be_cmd_get_active_profile(struct be_adapter *adapter, u16 *profile);
 int be_cmd_get_if_id(struct be_adapter *adapter, struct be_vf_cfg *vf_cfg,
 		     int vf_num);
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 32823a7..2451a47 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -3784,28 +3784,27 @@ static void be_calculate_vf_res(struct be_adapter *adapter, u16 num_vfs,
 	struct be_resources res_mod = {0};
 	u16 num_vf_qs = 1;
 
-	/* Distribute the queue resources among the PF and it's VFs
-	 * Do not distribute queue resources in multi-channel configuration.
-	 */
-	if (num_vfs && !be_is_mc(adapter)) {
-		 /* Divide the rx queues evenly among the VFs and the PF, capped
-		  * at VF-EQ-count. Any remainder queues belong to the PF.
-		  */
+	/* Distribute the queue resources among the PF and it's VFs */
+	if (num_vfs) {
+		/* Divide the rx queues evenly among the VFs and the PF, capped
+		 * at VF-EQ-count. Any remainder queues belong to the PF.
+		 */
 		num_vf_qs = min(SH_VF_MAX_NIC_EQS,
 				res.max_rss_qs / (num_vfs + 1));
 
-		/* Skyhawk-R chip supports only MAX_RSS_IFACES RSS capable
-		 * interfaces per port. Provide RSS on VFs, only if number
-		 * of VFs requested is less than MAX_RSS_IFACES limit.
+		/* Skyhawk-R chip supports only MAX_PORT_RSS_TABLES
+		 * RSS Tables per port. Provide RSS on VFs, only if number of
+		 * VFs requested is less than it's PF Pool's RSS Tables limit.
 		 */
-		if (num_vfs >= MAX_RSS_IFACES)
+		if (num_vfs >= be_max_pf_pool_rss_tables(adapter))
 			num_vf_qs = 1;
 	}
 
 	/* Resource with fields set to all '1's by GET_PROFILE_CONFIG cmd,
 	 * which are modifiable using SET_PROFILE_CONFIG cmd.
 	 */
-	be_cmd_get_profile_config(adapter, &res_mod, RESOURCE_MODIFIABLE, 0);
+	be_cmd_get_profile_config(adapter, &res_mod, NULL, ACTIVE_PROFILE_TYPE,
+				  RESOURCE_MODIFIABLE, 0);
 
 	/* If RSS IFACE capability flags are modifiable for a VF, set the
 	 * capability flag as valid and set RSS and DEFQ_RSS IFACE flags if
@@ -3903,7 +3902,8 @@ static int be_vfs_if_create(struct be_adapter *adapter)
 
 	for_all_vfs(adapter, vf_cfg, vf) {
 		if (!BE3_chip(adapter)) {
-			status = be_cmd_get_profile_config(adapter, &res,
+			status = be_cmd_get_profile_config(adapter, &res, NULL,
+							   ACTIVE_PROFILE_TYPE,
 							   RESOURCE_LIMITS,
 							   vf + 1);
 			if (!status) {
@@ -4088,8 +4088,9 @@ static void BEx_get_resources(struct be_adapter *adapter,
 		/* On a SuperNIC profile, the driver needs to use the
 		 * GET_PROFILE_CONFIG cmd to query the per-function TXQ limits
 		 */
-		be_cmd_get_profile_config(adapter, &super_nic_res,
-					  RESOURCE_LIMITS, 0);
+		be_cmd_get_profile_config(adapter, &super_nic_res, NULL,
+					  ACTIVE_PROFILE_TYPE, RESOURCE_LIMITS,
+					  0);
 		/* Some old versions of BE3 FW don't report max_tx_qs value */
 		res->max_tx_qs = super_nic_res.max_tx_qs ? : BE3_MAX_TX_QS;
 	} else {
@@ -4128,12 +4129,38 @@ static void be_setup_init(struct be_adapter *adapter)
 		adapter->cmd_privileges = MIN_PRIVILEGES;
 }
 
+/* HW supports only MAX_PORT_RSS_TABLES RSS Policy Tables per port.
+ * However, this HW limitation is not exposed to the host via any SLI cmd.
+ * As a result, in the case of SRIOV and in particular multi-partition configs
+ * the driver needs to calcuate a proportional share of RSS Tables per PF-pool
+ * for distribution between the VFs. This self-imposed limit will determine the
+ * no: of VFs for which RSS can be enabled.
+ */
+void be_calculate_pf_pool_rss_tables(struct be_adapter *adapter)
+{
+	struct be_port_resources port_res = {0};
+	u8 rss_tables_on_port;
+	u16 max_vfs = be_max_vfs(adapter);
+
+	be_cmd_get_profile_config(adapter, NULL, &port_res, SAVED_PROFILE_TYPE,
+				  RESOURCE_LIMITS, 0);
+
+	rss_tables_on_port = MAX_PORT_RSS_TABLES - port_res.nic_pfs;
+
+	/* Each PF Pool's RSS Tables limit =
+	 * PF's Max VFs / Total_Max_VFs on Port * RSS Tables on Port
+	 */
+	adapter->pool_res.max_rss_tables =
+		max_vfs * rss_tables_on_port / port_res.max_vfs;
+}
+
 static int be_get_sriov_config(struct be_adapter *adapter)
 {
 	struct be_resources res = {0};
 	int max_vfs, old_vfs;
 
-	be_cmd_get_profile_config(adapter, &res, RESOURCE_LIMITS, 0);
+	be_cmd_get_profile_config(adapter, &res, NULL, ACTIVE_PROFILE_TYPE,
+				  RESOURCE_LIMITS, 0);
 
 	/* Some old versions of BE3 FW don't report max_vfs value */
 	if (BE3_chip(adapter) && !res.max_vfs) {
@@ -4157,6 +4184,12 @@ static int be_get_sriov_config(struct be_adapter *adapter)
 		adapter->num_vfs = old_vfs;
 	}
 
+	if (skyhawk_chip(adapter) && be_max_vfs(adapter) && !old_vfs) {
+		be_calculate_pf_pool_rss_tables(adapter);
+		dev_info(&adapter->pdev->dev,
+			 "RSS can be enabled for all VFs if num_vfs <= %d\n",
+			 be_max_pf_pool_rss_tables(adapter));
+	}
 	return 0;
 }
 
@@ -4272,15 +4305,6 @@ static int be_get_config(struct be_adapter *adapter)
 				 "Using profile 0x%x\n", profile_id);
 	}
 
-	status = be_get_resources(adapter);
-	if (status)
-		return status;
-
-	adapter->pmac_id = kcalloc(be_max_uc(adapter),
-				   sizeof(*adapter->pmac_id), GFP_KERNEL);
-	if (!adapter->pmac_id)
-		return -ENOMEM;
-
 	return 0;
 }
 
@@ -4481,13 +4505,22 @@ static int be_setup(struct be_adapter *adapter)
 			return status;
 	}
 
+	status = be_get_config(adapter);
+	if (status)
+		goto err;
+
 	if (!BE2_chip(adapter) && be_physfn(adapter))
 		be_alloc_sriov_res(adapter);
 
-	status = be_get_config(adapter);
+	status = be_get_resources(adapter);
 	if (status)
 		goto err;
 
+	adapter->pmac_id = kcalloc(be_max_uc(adapter),
+				   sizeof(*adapter->pmac_id), GFP_KERNEL);
+	if (!adapter->pmac_id)
+		return -ENOMEM;
+
 	status = be_msix_enable(adapter);
 	if (status)
 		goto err;
-- 
2.4.1
