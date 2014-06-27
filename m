From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 2/4] be2net: read VF's capabilities from GET_PROFILE_CONFIG cmd
Date: Fri, 27 Jun 2014 17:13:19 +0530
Message-ID: <1403869401-6545-3-git-send-email-sathya.perla@emulex.com>
References: <1403869401-6545-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:36259 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753469AbaF0Lkx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jun 2014 07:40:53 -0400
In-Reply-To: <1403869401-6545-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasundhara Volam <vasundhara.volam@emulex.com>

The PF driver must query the FW for VF's interface capabilities
to know if the VF is RSS capable or not.
This patch is in preparation for enabling RSS on VFs on Skyhawk-R.

Signed-off-by: Vasundhara Volam <vasundhara.volam@emulex.com>
Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be.h      |    1 +
 drivers/net/ethernet/emulex/benet/be_cmds.c |   37 +++++++++++++++++++++++---
 drivers/net/ethernet/emulex/benet/be_cmds.h |    1 +
 drivers/net/ethernet/emulex/benet/be_main.c |    1 +
 4 files changed, 35 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be.h b/drivers/net/ethernet/emulex/benet/be.h
index 2e7c555..155ec2c 100644
--- a/drivers/net/ethernet/emulex/benet/be.h
+++ b/drivers/net/ethernet/emulex/benet/be.h
@@ -411,6 +411,7 @@ struct be_resources {
 	u16 max_vlans;		/* Number of vlans supported */
 	u16 max_evt_qs;
 	u32 if_cap_flags;
+	u32 vf_if_cap_flags;	/* VF if capability flags */
 };
 
 struct rss_info {
diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index 0e2f6e1..68d2006 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -3313,15 +3313,28 @@ err:
 	return status;
 }
 
-static struct be_nic_res_desc *be_get_nic_desc(u8 *buf, u32 desc_count)
+/* Descriptor type */
+enum {
+	FUNC_DESC = 1,
+	VFT_DESC = 2
+};
+
+static struct be_nic_res_desc *be_get_nic_desc(u8 *buf, u32 desc_count,
+					       int desc_type)
 {
 	struct be_res_desc_hdr *hdr = (struct be_res_desc_hdr *)buf;
+	struct be_nic_res_desc *nic;
 	int i;
 
 	for (i = 0; i < desc_count; i++) {
 		if (hdr->desc_type == NIC_RESOURCE_DESC_TYPE_V0 ||
-		    hdr->desc_type == NIC_RESOURCE_DESC_TYPE_V1)
-			return (struct be_nic_res_desc *)hdr;
+		    hdr->desc_type == NIC_RESOURCE_DESC_TYPE_V1) {
+			nic = (struct be_nic_res_desc *)hdr;
+			if (desc_type == FUNC_DESC ||
+			    (desc_type == VFT_DESC &&
+			     nic->flags & (1 << VFT_SHIFT)))
+				return nic;
+		}
 
 		hdr->desc_len = hdr->desc_len ? : RESOURCE_DESC_SIZE_V0;
 		hdr = (void *)hdr + hdr->desc_len;
@@ -3329,6 +3342,16 @@ static struct be_nic_res_desc *be_get_nic_desc(u8 *buf, u32 desc_count)
 	return NULL;
 }
 
+static struct be_nic_res_desc *be_get_vft_desc(u8 *buf, u32 desc_count)
+{
+	return be_get_nic_desc(buf, desc_count, VFT_DESC);
+}
+
+static struct be_nic_res_desc *be_get_func_nic_desc(u8 *buf, u32 desc_count)
+{
+	return be_get_nic_desc(buf, desc_count, FUNC_DESC);
+}
+
 static struct be_pcie_res_desc *be_get_pcie_desc(u8 devfn, u8 *buf,
 						 u32 desc_count)
 {
@@ -3424,7 +3447,7 @@ int be_cmd_get_func_config(struct be_adapter *adapter, struct be_resources *res)
 		u32 desc_count = le32_to_cpu(resp->desc_count);
 		struct be_nic_res_desc *desc;
 
-		desc = be_get_nic_desc(resp->func_param, desc_count);
+		desc = be_get_func_nic_desc(resp->func_param, desc_count);
 		if (!desc) {
 			status = -EINVAL;
 			goto err;
@@ -3446,6 +3469,7 @@ int be_cmd_get_profile_config(struct be_adapter *adapter,
 {
 	struct be_cmd_resp_get_profile_config *resp;
 	struct be_cmd_req_get_profile_config *req;
+	struct be_nic_res_desc *vf_res;
 	struct be_pcie_res_desc *pcie;
 	struct be_port_res_desc *port;
 	struct be_nic_res_desc *nic;
@@ -3486,10 +3510,13 @@ int be_cmd_get_profile_config(struct be_adapter *adapter,
 	if (port)
 		adapter->mc_type = port->mc_type;
 
-	nic = be_get_nic_desc(resp->func_param, desc_count);
+	nic = be_get_func_nic_desc(resp->func_param, desc_count);
 	if (nic)
 		be_copy_nic_desc(res, nic);
 
+	vf_res = be_get_vft_desc(resp->func_param, desc_count);
+	if (vf_res)
+		res->vf_if_cap_flags = vf_res->cap_flags;
 err:
 	if (cmd.va)
 		pci_free_consistent(adapter->pdev, cmd.size, cmd.va, cmd.dma);
diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.h b/drivers/net/ethernet/emulex/benet/be_cmds.h
index 3e0a6b2..7e589d6 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.h
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.h
@@ -1835,6 +1835,7 @@ struct be_cmd_req_set_ext_fat_caps {
 #define PORT_RESOURCE_DESC_TYPE_V1		0x55
 #define MAX_RESOURCE_DESC			264
 
+#define VFT_SHIFT				3	/* VF template */
 #define IMM_SHIFT				6	/* Immediate */
 #define NOSV_SHIFT				7	/* No save */
 
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 6822b3d..474291e 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -3379,6 +3379,7 @@ static int be_get_resources(struct be_adapter *adapter)
 			if (status)
 				return status;
 			adapter->res.max_vfs = res.max_vfs;
+			adapter->res.vf_if_cap_flags = res.vf_if_cap_flags;
 		}
 
 		dev_info(dev, "Max: txqs %d, rxqs %d, rss %d, eqs %d, vfs %d\n",
-- 
1.7.1
