From: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
Subject: [PATCH net-next-2.6 4/5] be2net: Use NTWK_RX_FILTER command for promiscous mode
Date: Tue, 10 May 2011 20:43:26 +0530
Message-ID: <bdba6ec6-4db4-4293-81e5-9474c2cef227@exht1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:11263 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755667Ab1EJPO0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2011 11:14:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use OPCODE_COMMON_NTWK_RX_FILTER command for promiscous mode as
OPCODE_ETH_PROMISCUOUS command is getting deprecated.

Signed-off-by: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
---
 drivers/net/benet/be_cmds.c |   46 +++++++++++++++++++++++++++++--------------
 drivers/net/benet/be_cmds.h |   24 ++++++++++++++--------
 drivers/net/benet/be_main.c |    4 +-
 3 files changed, 48 insertions(+), 26 deletions(-)

diff --git a/drivers/net/benet/be_cmds.c b/drivers/net/benet/be_cmds.c
index 20a97a8..06af55c 100644
--- a/drivers/net/benet/be_cmds.c
+++ b/drivers/net/benet/be_cmds.c
@@ -1404,12 +1404,24 @@ err:
 /* Uses MCC for this command as it may be called in BH context
  * Uses synchronous mcc
  */
-int be_cmd_promiscuous_config(struct be_adapter *adapter, u8 port_num, bool en)
+int be_cmd_promiscuous_config(struct be_adapter *adapter, bool en)
 {
 	struct be_mcc_wrb *wrb;
-	struct be_cmd_req_promiscuous_config *req;
+	struct be_cmd_req_rx_filter *req;
+	struct be_dma_mem promiscous_cmd;
+	struct be_sge *sge;
 	int status;
 
+	memset(&promiscous_cmd, 0, sizeof(struct be_dma_mem));
+	promiscous_cmd.size = sizeof(struct be_cmd_req_rx_filter);
+	promiscous_cmd.va = pci_alloc_consistent(adapter->pdev,
+				promiscous_cmd.size, &promiscous_cmd.dma);
+	if (!promiscous_cmd.va) {
+		dev_err(&adapter->pdev->dev,
+				"Memory allocation failure\n");
+		return -ENOMEM;
+	}
+
 	spin_lock_bh(&adapter->mcc_lock);
 
 	wrb = wrb_from_mccq(adapter);
@@ -1417,26 +1429,30 @@ int be_cmd_promiscuous_config(struct be_adapter *adapter, u8 port_num, bool en)
 		status = -EBUSY;
 		goto err;
 	}
-	req = embedded_payload(wrb);
 
-	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0, OPCODE_ETH_PROMISCUOUS);
+	req = promiscous_cmd.va;
+	sge = nonembedded_sgl(wrb);
 
-	be_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_ETH,
-		OPCODE_ETH_PROMISCUOUS, sizeof(*req));
-
-	/* In FW versions X.102.149/X.101.487 and later,
-	 * the port setting associated only with the
-	 * issuing pci function will take effect
-	 */
-	if (port_num)
-		req->port1_promiscuous = en;
-	else
-		req->port0_promiscuous = en;
+	be_wrb_hdr_prepare(wrb, sizeof(*req), false, 1,
+					OPCODE_COMMON_NTWK_RX_FILTER);
+	be_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
+			OPCODE_COMMON_NTWK_RX_FILTER, sizeof(*req));
+
+	req->if_id = cpu_to_le32(adapter->if_handle);
+	req->if_flags_mask = cpu_to_le32(BE_IF_FLAGS_PROMISCUOUS);
+	if (en)
+		req->if_flags = cpu_to_le32(BE_IF_FLAGS_PROMISCUOUS);
+
+	sge->pa_hi = cpu_to_le32(upper_32_bits(promiscous_cmd.dma));
+	sge->pa_lo = cpu_to_le32(promiscous_cmd.dma & 0xFFFFFFFF);
+	sge->len = cpu_to_le32(promiscous_cmd.size);
 
 	status = be_mcc_notify_wait(adapter);
 
 err:
 	spin_unlock_bh(&adapter->mcc_lock);
+	pci_free_consistent(adapter->pdev, promiscous_cmd.size,
+			promiscous_cmd.va, promiscous_cmd.dma);
 	return status;
 }
 
diff --git a/drivers/net/benet/be_cmds.h b/drivers/net/benet/be_cmds.h
index af4bbff..78256b6 100644
--- a/drivers/net/benet/be_cmds.h
+++ b/drivers/net/benet/be_cmds.h
@@ -714,13 +714,6 @@ struct be_cmd_req_vlan_config {
 	u16 normal_vlan[64];
 } __packed;
 
-struct be_cmd_req_promiscuous_config {
-	struct be_cmd_req_hdr hdr;
-	u8 port0_promiscuous;
-	u8 port1_promiscuous;
-	u16 rsvd0;
-} __packed;
-
 /******************** Multicast MAC Config *******************/
 #define BE_MAX_MC		64 /* set mcast promisc if > 64 */
 struct macaddr {
@@ -741,6 +734,20 @@ hw_stats_from_cmd(struct be_cmd_resp_get_stats *cmd)
 	return &cmd->hw_stats;
 }
 
+
+/******************* RX FILTER ******************************/
+struct be_cmd_req_rx_filter {
+	struct be_cmd_req_hdr hdr;
+	u32 global_flags_mask;
+	u32 global_flags;
+	u32 if_flags_mask;
+	u32 if_flags;
+	u32 if_id;
+	u32 multicast_num;
+	struct macaddr mac[BE_MAX_MC];
+};
+
+
 /******************** Link Status Query *******************/
 struct be_cmd_req_link_status {
 	struct be_cmd_req_hdr hdr;
@@ -1122,8 +1129,7 @@ extern int be_cmd_modify_eqd(struct be_adapter *adapter, u32 eq_id, u32 eqd);
 extern int be_cmd_vlan_config(struct be_adapter *adapter, u32 if_id,
 			u16 *vtag_array, u32 num, bool untagged,
 			bool promiscuous);
-extern int be_cmd_promiscuous_config(struct be_adapter *adapter,
-			u8 port_num, bool en);
+extern int be_cmd_promiscuous_config(struct be_adapter *adapter, bool en);
 extern int be_cmd_multicast_set(struct be_adapter *adapter, u32 if_id,
 			struct net_device *netdev, struct be_dma_mem *mem);
 extern int be_cmd_set_flow_control(struct be_adapter *adapter,
diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index b1beb31..69728fb 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -698,7 +698,7 @@ static void be_set_multicast_list(struct net_device *netdev)
 	struct be_adapter *adapter = netdev_priv(netdev);
 
 	if (netdev->flags & IFF_PROMISC) {
-		be_cmd_promiscuous_config(adapter, adapter->port_num, 1);
+		be_cmd_promiscuous_config(adapter, true);
 		adapter->promiscuous = true;
 		goto done;
 	}
@@ -706,7 +706,7 @@ static void be_set_multicast_list(struct net_device *netdev)
 	/* BE was previously in promiscuous mode; disable it */
 	if (adapter->promiscuous) {
 		adapter->promiscuous = false;
-		be_cmd_promiscuous_config(adapter, adapter->port_num, 0);
+		be_cmd_promiscuous_config(adapter, false);
 	}
 
 	/* Enable multicast promisc if num configured exceeds what we support */
-- 
1.6.0.2

