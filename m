From: Sathya Perla <sathya.perla@avagotech.com>
Subject: [PATCH 4/5] be2net: set pci_func_num while issuing GET_PROFILE_CONFIG cmd
Date: Mon, 12 Oct 2015 03:47:20 -0400
Message-ID: <1444636041-4727-5-git-send-email-sathya.perla@avagotech.com>
References: <1444636041-4727-1-git-send-email-sathya.perla@avagotech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmrelayp1.emulex.com ([138.239.112.140]:50637 "EHLO
	CMRELAYP1.ad.emulex.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751538AbbJLH50 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2015 03:57:26 -0400
In-Reply-To: <1444636041-4727-1-git-send-email-sathya.perla@avagotech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Somnath Kotur <somnath.kotur@emulex.com>

The FW requires the pf_num field in the cmd hdr to be set for it to return
the specific function's descriptors in the GET_PROFILE_CONFIG cmd. If not
set, the FW returns the descriptors of all the functions on the device.
If the first descriptor is not what is being queried for, the driver will
read wrong data. This patch fixes this issue by using the GET_CNTL_ATTRIB
cmd to query the real pci_func_num of a function and then uses it in the
GET_PROFILE_CONFIG cmd.

Signed-off-by: Somnath Kotur <somnath.kotur@emulex.com>
Signed-off-by: Sathya Perla <sathya.perla@avagotech.com>
---
 drivers/net/ethernet/emulex/benet/be.h      |  1 +
 drivers/net/ethernet/emulex/benet/be_cmds.c | 14 +++++++++++---
 drivers/net/ethernet/emulex/benet/be_cmds.h | 10 ++++++++--
 drivers/net/ethernet/emulex/benet/be_main.c |  9 +++++----
 4 files changed, 25 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be.h b/drivers/net/ethernet/emulex/benet/be.h
index 8215409..d463563 100644
--- a/drivers/net/ethernet/emulex/benet/be.h
+++ b/drivers/net/ethernet/emulex/benet/be.h
@@ -592,6 +592,7 @@ struct be_adapter {
 	int be_get_temp_freq;
 	struct be_hwmon hwmon_info;
 	u8 pf_number;
+	u8 pci_func_num;
 	struct rss_info rss_info;
 	/* Filters for packets that need to be sent to BMC */
 	u32 bmc_filt_mask;
diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index 9dc5ce1..790284d 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -2890,6 +2890,7 @@ int be_cmd_get_cntl_attributes(struct be_adapter *adapter)
 	if (!status) {
 		attribs = attribs_cmd.va + sizeof(struct be_cmd_resp_hdr);
 		adapter->hba_port_num = attribs->hba_attribs.phy_port;
+		adapter->pci_func_num = attribs->pci_func_num;
 		serial_num = attribs->hba_attribs.controller_serial_number;
 		for (i = 0; i < CNTL_SERIAL_NUM_WORDS; i++)
 			adapter->serial_num[i] = le32_to_cpu(serial_num[i]) &
@@ -3712,7 +3713,6 @@ int be_cmd_get_func_config(struct be_adapter *adapter, struct be_resources *res)
 			status = -EINVAL;
 			goto err;
 		}
-
 		adapter->pf_number = desc->pf_num;
 		be_copy_nic_desc(res, desc);
 	}
@@ -3724,7 +3724,10 @@ err:
 	return status;
 }
 
-/* Will use MBOX only if MCCQ has not been created */
+/* Will use MBOX only if MCCQ has not been created
+ * non-zero domain => a PF is querying this on behalf of a VF
+ * zero domain => a PF or a VF is querying this for itself
+ */
 int be_cmd_get_profile_config(struct be_adapter *adapter,
 			      struct be_resources *res, u8 query, u8 domain)
 {
@@ -3751,10 +3754,15 @@ int be_cmd_get_profile_config(struct be_adapter *adapter,
 			       OPCODE_COMMON_GET_PROFILE_CONFIG,
 			       cmd.size, &wrb, &cmd);
 
-	req->hdr.domain = domain;
 	if (!lancer_chip(adapter))
 		req->hdr.version = 1;
 	req->type = ACTIVE_PROFILE_TYPE;
+	/* When a function is querying profile information relating to
+	 * itself hdr.pf_number must be set to it's pci_func_num + 1
+	 */
+	req->hdr.domain = domain;
+	if (domain == 0)
+		req->hdr.pf_num = adapter->pci_func_num + 1;
 
 	/* When QUERY_MODIFIABLE_FIELDS_TYPE bit is set, cmd returns the
 	 * descriptors with all bits set to "1" for the fields which can be
diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.h b/drivers/net/ethernet/emulex/benet/be_cmds.h
index 7d178bd..91155ea 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.h
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.h
@@ -289,7 +289,9 @@ struct be_cmd_req_hdr {
 	u32 timeout;		/* dword 1 */
 	u32 request_length;	/* dword 2 */
 	u8 version;		/* dword 3 */
-	u8 rsvd[3];		/* dword 3 */
+	u8 rsvd1;		/* dword 3 */
+	u8 pf_num;		/* dword 3 */
+	u8 rsvd2;		/* dword 3 */
 };
 
 #define RESP_HDR_INFO_OPCODE_SHIFT	0	/* bits 0 - 7 */
@@ -1652,7 +1654,11 @@ struct mgmt_hba_attribs {
 
 struct mgmt_controller_attrib {
 	struct mgmt_hba_attribs hba_attribs;
-	u32 rsvd0[10];
+	u32 rsvd0[2];
+	u16 rsvd1;
+	u8 pci_func_num;
+	u8 rsvd2;
+	u32 rsvd3[7];
 } __packed;
 
 struct be_cmd_req_cntl_attribs {
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 821e014..eb48a97 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -4206,10 +4206,6 @@ static int be_get_config(struct be_adapter *adapter)
 	int status, level;
 	u16 profile_id;
 
-	status = be_cmd_get_cntl_attributes(adapter);
-	if (status)
-		return status;
-
 	status = be_cmd_query_fw_cfg(adapter);
 	if (status)
 		return status;
@@ -4408,6 +4404,11 @@ static int be_setup(struct be_adapter *adapter)
 	if (!lancer_chip(adapter))
 		be_cmd_req_native_mode(adapter);
 
+	/* Need to invoke this cmd first to get the PCI Function Number */
+	status = be_cmd_get_cntl_attributes(adapter);
+	if (status)
+		return status;
+
 	if (!BE2_chip(adapter) && be_physfn(adapter))
 		be_alloc_sriov_res(adapter);
 
-- 
2.4.1
