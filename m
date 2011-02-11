From: Ajit Khaparde <ajit.khaparde@emulex.com>
Subject: [PATCH net-next 08/15] be2net: pass domain numbers for
 pmac_add/del functions
Date: Fri, 11 Feb 2011 17:36:37 -0600
Message-ID: <20110211233637.GA18406@akhaparde-VBox>
Reply-To: Ajit Khaparde <ajit.khaparde@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:51193 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757767Ab1BKXgl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Feb 2011 18:36:41 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

be_cmd_pmac_add/del functions need to pass domain number to the firmware.

Signed-off-by: Ajit Khaparde <ajit.khaparde@emulex.com>
---
 drivers/net/benet/be_cmds.c |    6 ++++--
 drivers/net/benet/be_cmds.h |    5 +++--
 drivers/net/benet/be_main.c |   14 ++++++++------
 3 files changed, 15 insertions(+), 10 deletions(-)

diff --git a/drivers/net/benet/be_cmds.c b/drivers/net/benet/be_cmds.c
index be2981a..277982b 100644
--- a/drivers/net/benet/be_cmds.c
+++ b/drivers/net/benet/be_cmds.c
@@ -598,7 +598,7 @@ int be_cmd_mac_addr_query(struct be_adapter *adapter, u8 *mac_addr,
 
 /* Uses synchronous MCCQ */
 int be_cmd_pmac_add(struct be_adapter *adapter, u8 *mac_addr,
-		u32 if_id, u32 *pmac_id)
+		u32 if_id, u32 *pmac_id, u32 domain)
 {
 	struct be_mcc_wrb *wrb;
 	struct be_cmd_req_pmac_add *req;
@@ -619,6 +619,7 @@ int be_cmd_pmac_add(struct be_adapter *adapter, u8 *mac_addr,
 	be_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
 		OPCODE_COMMON_NTWK_PMAC_ADD, sizeof(*req));
 
+	req->hdr.domain = domain;
 	req->if_id = cpu_to_le32(if_id);
 	memcpy(req->mac_address, mac_addr, ETH_ALEN);
 
@@ -634,7 +635,7 @@ err:
 }
 
 /* Uses synchronous MCCQ */
-int be_cmd_pmac_del(struct be_adapter *adapter, u32 if_id, u32 pmac_id)
+int be_cmd_pmac_del(struct be_adapter *adapter, u32 if_id, u32 pmac_id, u32 dom)
 {
 	struct be_mcc_wrb *wrb;
 	struct be_cmd_req_pmac_del *req;
@@ -655,6 +656,7 @@ int be_cmd_pmac_del(struct be_adapter *adapter, u32 if_id, u32 pmac_id)
 	be_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
 		OPCODE_COMMON_NTWK_PMAC_DEL, sizeof(*req));
 
+	req->hdr.domain = dom;
 	req->if_id = cpu_to_le32(if_id);
 	req->pmac_id = cpu_to_le32(pmac_id);
 
diff --git a/drivers/net/benet/be_cmds.h b/drivers/net/benet/be_cmds.h
index 02540bd..91c5d2b 100644
--- a/drivers/net/benet/be_cmds.h
+++ b/drivers/net/benet/be_cmds.h
@@ -999,8 +999,9 @@ extern int be_cmd_POST(struct be_adapter *adapter);
 extern int be_cmd_mac_addr_query(struct be_adapter *adapter, u8 *mac_addr,
 			u8 type, bool permanent, u32 if_handle);
 extern int be_cmd_pmac_add(struct be_adapter *adapter, u8 *mac_addr,
-			u32 if_id, u32 *pmac_id);
-extern int be_cmd_pmac_del(struct be_adapter *adapter, u32 if_id, u32 pmac_id);
+			u32 if_id, u32 *pmac_id, u32 domain);
+extern int be_cmd_pmac_del(struct be_adapter *adapter, u32 if_id,
+			u32 pmac_id, u32 domain);
 extern int be_cmd_if_create(struct be_adapter *adapter, u32 cap_flags,
 			u32 en_flags, u8 *mac, bool pmac_invalid,
 			u32 *if_handle, u32 *pmac_id, u32 domain);
diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index fc119d1..f2d2036 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -236,12 +236,13 @@ static int be_mac_addr_set(struct net_device *netdev, void *p)
 	if (!be_physfn(adapter))
 		goto netdev_addr;
 
-	status = be_cmd_pmac_del(adapter, adapter->if_handle, adapter->pmac_id);
+	status = be_cmd_pmac_del(adapter, adapter->if_handle,
+				adapter->pmac_id, 0);
 	if (status)
 		return status;
 
 	status = be_cmd_pmac_add(adapter, (u8 *)addr->sa_data,
-			adapter->if_handle, &adapter->pmac_id);
+				adapter->if_handle, &adapter->pmac_id, 0);
 netdev_addr:
 	if (!status)
 		memcpy(netdev->dev_addr, addr->sa_data, netdev->addr_len);
@@ -741,11 +742,11 @@ static int be_set_vf_mac(struct net_device *netdev, int vf, u8 *mac)
 	if (adapter->vf_cfg[vf].vf_pmac_id != BE_INVALID_PMAC_ID)
 		status = be_cmd_pmac_del(adapter,
 					adapter->vf_cfg[vf].vf_if_handle,
-					adapter->vf_cfg[vf].vf_pmac_id);
+					adapter->vf_cfg[vf].vf_pmac_id, vf + 1);
 
 	status = be_cmd_pmac_add(adapter, mac,
 				adapter->vf_cfg[vf].vf_if_handle,
-				&adapter->vf_cfg[vf].vf_pmac_id);
+				&adapter->vf_cfg[vf].vf_pmac_id, vf + 1);
 
 	if (status)
 		dev_err(&adapter->pdev->dev, "MAC %pM set on VF %d Failed\n",
@@ -2225,7 +2226,8 @@ static inline int be_vf_eth_addr_config(struct be_adapter *adapter)
 	for (vf = 0; vf < num_vfs; vf++) {
 		status = be_cmd_pmac_add(adapter, mac,
 					adapter->vf_cfg[vf].vf_if_handle,
-					&adapter->vf_cfg[vf].vf_pmac_id);
+					&adapter->vf_cfg[vf].vf_pmac_id,
+					vf + 1);
 		if (status)
 			dev_err(&adapter->pdev->dev,
 				"Mac address add failed for VF %d\n", vf);
@@ -2245,7 +2247,7 @@ static inline void be_vf_eth_addr_rem(struct be_adapter *adapter)
 		if (adapter->vf_cfg[vf].vf_pmac_id != BE_INVALID_PMAC_ID)
 			be_cmd_pmac_del(adapter,
 					adapter->vf_cfg[vf].vf_if_handle,
-					adapter->vf_cfg[vf].vf_pmac_id);
+					adapter->vf_cfg[vf].vf_pmac_id, vf + 1);
 	}
 }
 
-- 
1.7.1

