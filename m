From: Sathya Perla <sathya.perla@avagotech.com>
Subject: [PATCH net-next v3 08/10] be2net: fix port-res desc query of GET_PROFILE_CONFIG FW cmd
Date: Wed, 30 Dec 2015 01:29:03 -0500
Message-ID: <1451456945-31606-9-git-send-email-sathya.perla@avagotech.com>
References: <1451456945-31606-1-git-send-email-sathya.perla@avagotech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmrelayp1.emulex.com ([138.239.112.140]:50633 "EHLO
	CMRELAYP1.ad.emulex.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754351AbbL3G3V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Dec 2015 01:29:21 -0500
In-Reply-To: <1451456945-31606-1-git-send-email-sathya.perla@avagotech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Suresh Reddy <suresh.reddy@avagotech.com>

Commit 72ef3a88fa8e ("be2net: set pci_func_num while issuing
GET_PROFILE_CONFIG cmd") passed a specific pf_num while issuing a
GET_PROFILE_CONFIG cmd as FW returns descriptors for all functions when
pf_num is zero. But, when pf_num is set to a non-zero value, FW does not
return the Port resource descriptor.
This patch fixes this by setting pf_num to 0 while issuing the query cmd
and adds code to pick the correct NIC resource descriptor from the list of
descriptors returned by FW.

Fixes: 72ef3a88fa8e ("be2net: set pci_func_num while issuing
		     GET_PROFILE_CONFIG cmd")
Signed-off-by: Suresh Reddy <suresh.reddy@avagotech.com>

Signed-off-by: Sathya Perla <sathya.perla@avagotech.com>
---
 drivers/net/ethernet/emulex/benet/be.h      |  4 +-
 drivers/net/ethernet/emulex/benet/be_cmds.c | 85 ++++++++++++++++-------------
 drivers/net/ethernet/emulex/benet/be_cmds.h | 11 +---
 drivers/net/ethernet/emulex/benet/be_main.c | 16 ++++--
 4 files changed, 63 insertions(+), 53 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be.h b/drivers/net/ethernet/emulex/benet/be.h
index 0af32f1..66988f4 100644
--- a/drivers/net/ethernet/emulex/benet/be.h
+++ b/drivers/net/ethernet/emulex/benet/be.h
@@ -570,6 +570,8 @@ struct be_adapter {
 	struct be_resources pool_res;	/* resources available for the port */
 	struct be_resources res;	/* resources available for the func */
 	u16 num_vfs;			/* Number of VFs provisioned by PF */
+	u8 pf_num;			/* Numbering used by FW, starts at 0 */
+	u8 vf_num;			/* Numbering used by FW, starts at 1 */
 	u8 virtfn;
 	struct be_vf_cfg *vf_cfg;
 	bool be3_native;
@@ -587,8 +589,6 @@ struct be_adapter {
 	u32 msg_enable;
 	int be_get_temp_freq;
 	struct be_hwmon hwmon_info;
-	u8 pf_number;
-	u8 pci_func_num;
 	struct rss_info rss_info;
 	/* Filters for packets that need to be sent to BMC */
 	u32 bmc_filt_mask;
diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index 7c0e7ff..b92ee06 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -3466,7 +3466,6 @@ int be_cmd_get_cntl_attributes(struct be_adapter *adapter)
 	if (!status) {
 		attribs = attribs_cmd.va + sizeof(struct be_cmd_resp_hdr);
 		adapter->hba_port_num = attribs->hba_attribs.phy_port;
-		adapter->pci_func_num = attribs->pci_func_num;
 		serial_num = attribs->hba_attribs.controller_serial_number;
 		for (i = 0; i < CNTL_SERIAL_NUM_WORDS; i++)
 			adapter->serial_num[i] = le32_to_cpu(serial_num[i]) &
@@ -4149,14 +4148,16 @@ int be_cmd_query_port_name(struct be_adapter *adapter)
 	return status;
 }
 
-/* Descriptor type */
-enum {
-	FUNC_DESC = 1,
-	VFT_DESC = 2
-};
-
+/* When more than 1 NIC descriptor is present in the descriptor list,
+ * the caller must specify the pf_num to obtain the NIC descriptor
+ * corresponding to its pci function.
+ * get_vft must be true when the caller wants the VF-template desc of the
+ * PF-pool.
+ * The pf_num should be set to PF_NUM_IGNORE when the caller knows
+ * that only it's NIC descriptor is present in the descriptor list.
+ */
 static struct be_nic_res_desc *be_get_nic_desc(u8 *buf, u32 desc_count,
-					       int desc_type)
+					       bool get_vft, u8 pf_num)
 {
 	struct be_res_desc_hdr *hdr = (struct be_res_desc_hdr *)buf;
 	struct be_nic_res_desc *nic;
@@ -4166,40 +4167,42 @@ static struct be_nic_res_desc *be_get_nic_desc(u8 *buf, u32 desc_count,
 		if (hdr->desc_type == NIC_RESOURCE_DESC_TYPE_V0 ||
 		    hdr->desc_type == NIC_RESOURCE_DESC_TYPE_V1) {
 			nic = (struct be_nic_res_desc *)hdr;
-			if (desc_type == FUNC_DESC ||
-			    (desc_type == VFT_DESC &&
-			     nic->flags & (1 << VFT_SHIFT)))
+
+			if ((pf_num == PF_NUM_IGNORE ||
+			     nic->pf_num == pf_num) &&
+			    (!get_vft || nic->flags & BIT(VFT_SHIFT)))
 				return nic;
 		}
-
 		hdr->desc_len = hdr->desc_len ? : RESOURCE_DESC_SIZE_V0;
 		hdr = (void *)hdr + hdr->desc_len;
 	}
 	return NULL;
 }
 
-static struct be_nic_res_desc *be_get_vft_desc(u8 *buf, u32 desc_count)
+static struct be_nic_res_desc *be_get_vft_desc(u8 *buf, u32 desc_count,
+					       u8 pf_num)
 {
-	return be_get_nic_desc(buf, desc_count, VFT_DESC);
+	return be_get_nic_desc(buf, desc_count, true, pf_num);
 }
 
-static struct be_nic_res_desc *be_get_func_nic_desc(u8 *buf, u32 desc_count)
+static struct be_nic_res_desc *be_get_func_nic_desc(u8 *buf, u32 desc_count,
+						    u8 pf_num)
 {
-	return be_get_nic_desc(buf, desc_count, FUNC_DESC);
+	return be_get_nic_desc(buf, desc_count, false, pf_num);
 }
 
-static struct be_pcie_res_desc *be_get_pcie_desc(u8 devfn, u8 *buf,
-						 u32 desc_count)
+static struct be_pcie_res_desc *be_get_pcie_desc(u8 *buf, u32 desc_count,
+						 u8 pf_num)
 {
 	struct be_res_desc_hdr *hdr = (struct be_res_desc_hdr *)buf;
 	struct be_pcie_res_desc *pcie;
 	int i;
 
 	for (i = 0; i < desc_count; i++) {
-		if ((hdr->desc_type == PCIE_RESOURCE_DESC_TYPE_V0 ||
-		     hdr->desc_type == PCIE_RESOURCE_DESC_TYPE_V1)) {
-			pcie = (struct be_pcie_res_desc	*)hdr;
-			if (pcie->pf_num == devfn)
+		if (hdr->desc_type == PCIE_RESOURCE_DESC_TYPE_V0 ||
+		    hdr->desc_type == PCIE_RESOURCE_DESC_TYPE_V1) {
+			pcie = (struct be_pcie_res_desc *)hdr;
+			if (pcie->pf_num == pf_num)
 				return pcie;
 		}
 
@@ -4284,13 +4287,23 @@ int be_cmd_get_func_config(struct be_adapter *adapter, struct be_resources *res)
 		u32 desc_count = le32_to_cpu(resp->desc_count);
 		struct be_nic_res_desc *desc;
 
-		desc = be_get_func_nic_desc(resp->func_param, desc_count);
+		/* GET_FUNC_CONFIG returns resource descriptors of the
+		 * current function only. So, pf_num should be set to
+		 * PF_NUM_IGNORE.
+		 */
+		desc = be_get_func_nic_desc(resp->func_param, desc_count,
+					    PF_NUM_IGNORE);
 		if (!desc) {
 			status = -EINVAL;
 			goto err;
 		}
-		adapter->pf_number = desc->pf_num;
-		be_copy_nic_desc(res, desc);
+
+		/* Store pf_num & vf_num for later use in GET_PROFILE_CONFIG */
+		adapter->pf_num = desc->pf_num;
+		adapter->vf_num = desc->vf_num;
+
+		if (res)
+			be_copy_nic_desc(res, desc);
 	}
 err:
 	mutex_unlock(&adapter->mbox_lock);
@@ -4300,10 +4313,7 @@ err:
 	return status;
 }
 
-/* Will use MBOX only if MCCQ has not been created
- * non-zero domain => a PF is querying this on behalf of a VF
- * zero domain => a PF or a VF is querying this for itself
- */
+/* Will use MBOX only if MCCQ has not been created */
 int be_cmd_get_profile_config(struct be_adapter *adapter,
 			      struct be_resources *res, u8 query, u8 domain)
 {
@@ -4333,12 +4343,7 @@ int be_cmd_get_profile_config(struct be_adapter *adapter,
 	if (!lancer_chip(adapter))
 		req->hdr.version = 1;
 	req->type = ACTIVE_PROFILE_TYPE;
-	/* When a function is querying profile information relating to
-	 * itself hdr.pf_number must be set to it's pci_func_num + 1
-	 */
 	req->hdr.domain = domain;
-	if (domain == 0)
-		req->hdr.pf_num = adapter->pci_func_num + 1;
 
 	/* When QUERY_MODIFIABLE_FIELDS_TYPE bit is set, cmd returns the
 	 * descriptors with all bits set to "1" for the fields which can be
@@ -4354,8 +4359,8 @@ int be_cmd_get_profile_config(struct be_adapter *adapter,
 	resp = cmd.va;
 	desc_count = le16_to_cpu(resp->desc_count);
 
-	pcie = be_get_pcie_desc(adapter->pdev->devfn, resp->func_param,
-				desc_count);
+	pcie = be_get_pcie_desc(resp->func_param, desc_count,
+				adapter->pf_num);
 	if (pcie)
 		res->max_vfs = le16_to_cpu(pcie->num_vfs);
 
@@ -4363,11 +4368,13 @@ int be_cmd_get_profile_config(struct be_adapter *adapter,
 	if (port)
 		adapter->mc_type = port->mc_type;
 
-	nic = be_get_func_nic_desc(resp->func_param, desc_count);
+	nic = be_get_func_nic_desc(resp->func_param, desc_count,
+				   adapter->pf_num);
 	if (nic)
 		be_copy_nic_desc(res, nic);
 
-	vf_res = be_get_vft_desc(resp->func_param, desc_count);
+	vf_res = be_get_vft_desc(resp->func_param, desc_count,
+				 adapter->pf_num);
 	if (vf_res)
 		res->vf_if_cap_flags = vf_res->cap_flags;
 err:
@@ -4457,7 +4464,7 @@ int be_cmd_config_qos(struct be_adapter *adapter, u32 max_rate, u16 link_speed,
 		return be_cmd_set_qos(adapter, max_rate / 10, domain);
 
 	be_reset_nic_desc(&nic_desc);
-	nic_desc.pf_num = adapter->pf_number;
+	nic_desc.pf_num = adapter->pf_num;
 	nic_desc.vf_num = domain;
 	nic_desc.bw_min = 0;
 	if (lancer_chip(adapter)) {
diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.h b/drivers/net/ethernet/emulex/benet/be_cmds.h
index 16415ca..5098170 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.h
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.h
@@ -291,9 +291,7 @@ struct be_cmd_req_hdr {
 	u32 timeout;		/* dword 1 */
 	u32 request_length;	/* dword 2 */
 	u8 version;		/* dword 3 */
-	u8 rsvd1;		/* dword 3 */
-	u8 pf_num;		/* dword 3 */
-	u8 rsvd2;		/* dword 3 */
+	u8 rsvd[3];		/* dword 3 */
 };
 
 #define RESP_HDR_INFO_OPCODE_SHIFT	0	/* bits 0 - 7 */
@@ -1676,11 +1674,7 @@ struct mgmt_hba_attribs {
 
 struct mgmt_controller_attrib {
 	struct mgmt_hba_attribs hba_attribs;
-	u32 rsvd0[2];
-	u16 rsvd1;
-	u8 pci_func_num;
-	u8 rsvd2;
-	u32 rsvd3[7];
+	u32 rsvd0[10];
 } __packed;
 
 struct be_cmd_req_cntl_attribs {
@@ -2105,6 +2099,7 @@ struct be_port_res_desc {
 #define NV_TYPE_VXLAN				3
 #define SOCVID_SHIFT				2	/* Strip outer vlan */
 #define RCVID_SHIFT				4	/* Report vlan */
+#define PF_NUM_IGNORE				255
 	u8 nv_flags;
 	u8 rsvd2;
 	__le16 nv_port;					/* vxlan/gre port */
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index c9f9d4b..7039870 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -4204,6 +4204,10 @@ static int be_get_config(struct be_adapter *adapter)
 	int status, level;
 	u16 profile_id;
 
+	status = be_cmd_get_cntl_attributes(adapter);
+	if (status)
+		return status;
+
 	status = be_cmd_query_fw_cfg(adapter);
 	if (status)
 		return status;
@@ -4402,10 +4406,14 @@ static int be_setup(struct be_adapter *adapter)
 	if (!lancer_chip(adapter))
 		be_cmd_req_native_mode(adapter);
 
-	/* Need to invoke this cmd first to get the PCI Function Number */
-	status = be_cmd_get_cntl_attributes(adapter);
-	if (status)
-		return status;
+	/* invoke this cmd first to get pf_num and vf_num which are needed
+	 * for issuing profile related cmds
+	 */
+	if (!BEx_chip(adapter)) {
+		status = be_cmd_get_func_config(adapter, NULL);
+		if (status)
+			return status;
+	}
 
 	if (!BE2_chip(adapter) && be_physfn(adapter))
 		be_alloc_sriov_res(adapter);
-- 
2.4.1
