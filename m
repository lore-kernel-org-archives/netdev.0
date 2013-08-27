From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH next 5/6] be2net: refactor be_setup() to consolidate queue creation routines
Date: Tue, 27 Aug 2013 16:57:34 +0530
Message-ID: <1377602855-13920-6-git-send-email-sathya.perla@emulex.com>
References: <1377602855-13920-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:48951 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753266Ab3H0LXz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Aug 2013 07:23:55 -0400
In-Reply-To: <1377602855-13920-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

1) Move be_cmd_if_create() above queue create routines to allow
   TXQ creation (that requires if_handle) to be clubbed with TX-CQ creation.
2) Consolidate all queue create routines into be_setup_queues()

Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_cmds.c |   23 ++-----
 drivers/net/ethernet/emulex/benet/be_main.c |   95 ++++++++++++++-------------
 2 files changed, 55 insertions(+), 63 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index 70d5db0..52c9085 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -1182,25 +1182,16 @@ int be_cmd_mccq_create(struct be_adapter *adapter,
 
 int be_cmd_txq_create(struct be_adapter *adapter, struct be_tx_obj *txo)
 {
-	struct be_mcc_wrb *wrb;
+	struct be_mcc_wrb wrb = {0};
 	struct be_cmd_req_eth_tx_create *req;
 	struct be_queue_info *txq = &txo->q;
 	struct be_queue_info *cq = &txo->cq;
 	struct be_dma_mem *q_mem = &txq->dma_mem;
 	int status, ver = 0;
 
-	spin_lock_bh(&adapter->mcc_lock);
-
-	wrb = wrb_from_mccq(adapter);
-	if (!wrb) {
-		status = -EBUSY;
-		goto err;
-	}
-
-	req = embedded_payload(wrb);
-
+	req = embedded_payload(&wrb);
 	be_wrb_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_ETH,
-		OPCODE_ETH_TX_CREATE, sizeof(*req), wrb, NULL);
+				OPCODE_ETH_TX_CREATE, sizeof(*req), &wrb, NULL);
 
 	if (lancer_chip(adapter)) {
 		req->hdr.version = 1;
@@ -1218,12 +1209,11 @@ int be_cmd_txq_create(struct be_adapter *adapter, struct be_tx_obj *txo)
 	req->cq_id = cpu_to_le16(cq->id);
 	req->queue_size = be_encoded_q_len(txq->len);
 	be_cmd_page_addrs_prepare(req->pages, ARRAY_SIZE(req->pages), q_mem);
-
 	ver = req->hdr.version;
 
-	status = be_mcc_notify_wait(adapter);
+	status = be_cmd_notify_wait(adapter, &wrb);
 	if (!status) {
-		struct be_cmd_resp_eth_tx_create *resp = embedded_payload(wrb);
+		struct be_cmd_resp_eth_tx_create *resp = embedded_payload(&wrb);
 		txq->id = le16_to_cpu(resp->cid);
 		if (ver == 2)
 			txo->db_offset = le32_to_cpu(resp->db_offset);
@@ -1232,9 +1222,6 @@ int be_cmd_txq_create(struct be_adapter *adapter, struct be_tx_obj *txo)
 		txq->created = true;
 	}
 
-err:
-	spin_unlock_bh(&adapter->mcc_lock);
-
 	return status;
 }
 
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index d34ea98..b08459d 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -2014,7 +2014,7 @@ static void be_tx_queues_destroy(struct be_adapter *adapter)
 	}
 }
 
-static int be_tx_cqs_create(struct be_adapter *adapter)
+static int be_tx_qs_create(struct be_adapter *adapter)
 {
 	struct be_queue_info *cq, *eq;
 	struct be_tx_obj *txo;
@@ -2042,16 +2042,7 @@ static int be_tx_cqs_create(struct be_adapter *adapter)
 		status = be_cmd_cq_create(adapter, cq, eq, false, 3);
 		if (status)
 			return status;
-	}
-	return 0;
-}
 
-static int be_tx_qs_create(struct be_adapter *adapter)
-{
-	struct be_tx_obj *txo;
-	int i, status;
-
-	for_all_tx_queues(adapter, txo, i) {
 		status = be_queue_alloc(adapter, &txo->q, TX_Q_LEN,
 					sizeof(struct be_eth_wrb));
 		if (status)
@@ -2772,6 +2763,14 @@ done:
 	adapter->num_vfs = 0;
 }
 
+static void be_clear_queues(struct be_adapter *adapter)
+{
+	be_mcc_queues_destroy(adapter);
+	be_rx_cqs_destroy(adapter);
+	be_tx_queues_destroy(adapter);
+	be_evt_queues_destroy(adapter);
+}
+
 static int be_clear(struct be_adapter *adapter)
 {
 	int i;
@@ -2792,10 +2791,7 @@ static int be_clear(struct be_adapter *adapter)
 
 	be_cmd_if_destroy(adapter, adapter->if_handle,  0);
 
-	be_mcc_queues_destroy(adapter);
-	be_rx_cqs_destroy(adapter);
-	be_tx_queues_destroy(adapter);
-	be_evt_queues_destroy(adapter);
+	be_clear_queues(adapter);
 
 	kfree(adapter->pmac_id);
 	adapter->pmac_id = NULL;
@@ -3112,11 +3108,36 @@ static int be_mac_setup(struct be_adapter *adapter)
 	return 0;
 }
 
+static int be_setup_queues(struct be_adapter *adapter)
+{
+	int status;
+
+	status = be_evt_queues_create(adapter);
+	if (status)
+		goto err;
+
+	status = be_tx_qs_create(adapter);
+	if (status)
+		goto err;
+
+	status = be_rx_cqs_create(adapter);
+	if (status)
+		goto err;
+
+	status = be_mcc_queues_create(adapter);
+	if (status)
+		goto err;
+
+	return 0;
+err:
+	dev_err(&adapter->pdev->dev, "queue_setup failed\n");
+	return status;
+}
+
 static int be_setup(struct be_adapter *adapter)
 {
 	struct device *dev = &adapter->pdev->dev;
-	u32 en_flags;
-	u32 tx_fc, rx_fc;
+	u32 tx_fc, rx_fc, en_flags;
 	int status;
 
 	be_setup_init(adapter);
@@ -3132,47 +3153,31 @@ static int be_setup(struct be_adapter *adapter)
 	if (status)
 		goto err;
 
-	status = be_evt_queues_create(adapter);
-	if (status)
-		goto err;
-
-	status = be_tx_cqs_create(adapter);
-	if (status)
-		goto err;
-
-	status = be_rx_cqs_create(adapter);
-	if (status)
-		goto err;
-
-	status = be_mcc_queues_create(adapter);
-	if (status)
-		goto err;
-
-	be_cmd_get_fn_privileges(adapter, &adapter->cmd_privileges, 0);
-	/* In UMC mode FW does not return right privileges.
-	 * Override with correct privilege equivalent to PF.
-	 */
-	if (be_is_mc(adapter))
-		adapter->cmd_privileges = MAX_PRIVILEGES;
-
 	en_flags = BE_IF_FLAGS_UNTAGGED | BE_IF_FLAGS_BROADCAST |
-			BE_IF_FLAGS_MULTICAST | BE_IF_FLAGS_PASS_L3L4_ERRORS;
+		   BE_IF_FLAGS_MULTICAST | BE_IF_FLAGS_PASS_L3L4_ERRORS;
 	if (adapter->function_caps & BE_FUNCTION_CAPS_RSS)
 		en_flags |= BE_IF_FLAGS_RSS;
 	en_flags = en_flags & be_if_cap_flags(adapter);
 	status = be_cmd_if_create(adapter, be_if_cap_flags(adapter), en_flags,
 				  &adapter->if_handle, 0);
-	if (status != 0)
+	if (status)
 		goto err;
 
+	status = be_setup_queues(adapter);
+	if (status)
+		goto err;
+
+	be_cmd_get_fn_privileges(adapter, &adapter->cmd_privileges, 0);
+	/* In UMC mode FW does not return right privileges.
+	 * Override with correct privilege equivalent to PF.
+	 */
+	if (be_is_mc(adapter))
+		adapter->cmd_privileges = MAX_PRIVILEGES;
+
 	status = be_mac_setup(adapter);
 	if (status)
 		goto err;
 
-	status = be_tx_qs_create(adapter);
-	if (status)
-		goto err;
-
 	be_cmd_get_fw_ver(adapter, adapter->fw_ver, adapter->fw_on_flash);
 
 	if (adapter->vlans_added)
-- 
1.7.1
