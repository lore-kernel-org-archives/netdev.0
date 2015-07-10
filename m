From: Sathya Perla <sathya.perla@avagotech.com>
Subject: [PATCH net-next 6/9] be2net: return error status from be_mcc_notify()
Date: Fri, 10 Jul 2015 05:32:48 -0400
Message-ID: <1436520771-11656-7-git-send-email-sathya.perla@avagotech.com>
References: <1436520771-11656-1-git-send-email-sathya.perla@avagotech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmrelayp1.emulex.com ([138.239.112.140]:56758 "EHLO
	CMRELAYP1.ad.emulex.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753468AbbGJJ0f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jul 2015 05:26:35 -0400
In-Reply-To: <1436520771-11656-1-git-send-email-sathya.perla@avagotech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Suresh Reddy <Suresh.Reddy@emulex.com>

When the adapter is in error state, return error from be_mcc_notify()
so that the caller routines need not sleep waiting for a response.

Signed-off-by: Suresh Reddy <suresh.reddy@avagotech.com>
Signed-off-by: Sathya Perla <sathya.perla@avagotech.com>
---
 drivers/net/ethernet/emulex/benet/be_cmds.c | 39 +++++++++++++++++++++--------
 1 file changed, 28 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index 9eac322..a299f7b 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -88,19 +88,21 @@ static inline void *embedded_payload(struct be_mcc_wrb *wrb)
 	return wrb->payload.embedded_payload;
 }
 
-static void be_mcc_notify(struct be_adapter *adapter)
+static int be_mcc_notify(struct be_adapter *adapter)
 {
 	struct be_queue_info *mccq = &adapter->mcc_obj.q;
 	u32 val = 0;
 
 	if (be_check_error(adapter, BE_ERROR_ANY))
-		return;
+		return -EIO;
 
 	val |= mccq->id & DB_MCCQ_RING_ID_MASK;
 	val |= 1 << DB_MCCQ_NUM_POSTED_SHIFT;
 
 	wmb();
 	iowrite32(val, adapter->db + DB_MCCQ_OFFSET);
+
+	return 0;
 }
 
 /* To check if valid bit is set, check the entire word as we don't know
@@ -541,7 +543,9 @@ static int be_mcc_notify_wait(struct be_adapter *adapter)
 
 	resp = be_decode_resp_hdr(wrb->tag0, wrb->tag1);
 
-	be_mcc_notify(adapter);
+	status = be_mcc_notify(adapter);
+	if (status)
+		goto out;
 
 	status = be_mcc_wait_compl(adapter);
 	if (status == -EIO)
@@ -1547,7 +1551,10 @@ int be_cmd_get_stats(struct be_adapter *adapter, struct be_dma_mem *nonemb_cmd)
 	else
 		hdr->version = 2;
 
-	be_mcc_notify(adapter);
+	status = be_mcc_notify(adapter);
+	if (status)
+		goto err;
+
 	adapter->stats_cmd_sent = true;
 
 err:
@@ -1583,7 +1590,10 @@ int lancer_cmd_get_pport_stats(struct be_adapter *adapter,
 	req->cmd_params.params.pport_num = cpu_to_le16(adapter->hba_port_num);
 	req->cmd_params.params.reset_stats = 0;
 
-	be_mcc_notify(adapter);
+	status = be_mcc_notify(adapter);
+	if (status)
+		goto err;
+
 	adapter->stats_cmd_sent = true;
 
 err:
@@ -1687,8 +1697,7 @@ int be_cmd_get_die_temperature(struct be_adapter *adapter)
 			       OPCODE_COMMON_GET_CNTL_ADDITIONAL_ATTRIBUTES,
 			       sizeof(*req), wrb, NULL);
 
-	be_mcc_notify(adapter);
-
+	status = be_mcc_notify(adapter);
 err:
 	spin_unlock_bh(&adapter->mcc_lock);
 	return status;
@@ -1860,7 +1869,7 @@ static int __be_cmd_modify_eqd(struct be_adapter *adapter,
 				cpu_to_le32(set_eqd[i].delay_multiplier);
 	}
 
-	be_mcc_notify(adapter);
+	status = be_mcc_notify(adapter);
 err:
 	spin_unlock_bh(&adapter->mcc_lock);
 	return status;
@@ -2320,7 +2329,10 @@ int lancer_cmd_write_object(struct be_adapter *adapter, struct be_dma_mem *cmd,
 	req->addr_high = cpu_to_le32(upper_32_bits(cmd->dma +
 				sizeof(struct lancer_cmd_req_write_object)));
 
-	be_mcc_notify(adapter);
+	status = be_mcc_notify(adapter);
+	if (status)
+		goto err_unlock;
+
 	spin_unlock_bh(&adapter->mcc_lock);
 
 	if (!wait_for_completion_timeout(&adapter->et_cmd_compl,
@@ -2491,7 +2503,10 @@ int be_cmd_write_flashrom(struct be_adapter *adapter, struct be_dma_mem *cmd,
 	req->params.op_code = cpu_to_le32(flash_opcode);
 	req->params.data_buf_size = cpu_to_le32(buf_size);
 
-	be_mcc_notify(adapter);
+	status = be_mcc_notify(adapter);
+	if (status)
+		goto err_unlock;
+
 	spin_unlock_bh(&adapter->mcc_lock);
 
 	if (!wait_for_completion_timeout(&adapter->et_cmd_compl,
@@ -2636,7 +2651,9 @@ int be_cmd_loopback_test(struct be_adapter *adapter, u32 port_num,
 	req->num_pkts = cpu_to_le32(num_pkts);
 	req->loopback_type = cpu_to_le32(loopback_type);
 
-	be_mcc_notify(adapter);
+	status = be_mcc_notify(adapter);
+	if (status)
+		goto err;
 
 	spin_unlock_bh(&adapter->mcc_lock);
 
-- 
2.4.1
