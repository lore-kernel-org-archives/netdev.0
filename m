From: Sathya Perla <sathyap@serverengines.com>
Subject: [net-next-2.6 PATCH 5/5] be2net: remove BUG_ON() when be2net runs
 out of mccq wrbs
Date: Mon, 23 Nov 2009 13:32:45 +0530
Message-ID: <20091123080245.GA7836@serverengines.com>
Reply-To: Sathya Perla <sathyap@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:44502 "EHLO
	sperla-laptop.localdomain" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752740AbZKWICt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2009 03:02:49 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver can run out of mccq wrbs when completions don't arrive
due to an unresponsive card. This must not hit a BUG_ON(); instead
log a msg and return an error.

Signed-off-by: Sathya Perla <sathyap@serverengines.com>
---
 drivers/net/benet/be_cmds.c |   89 +++++++++++++++++++++++++++++++++++++++++--
 1 files changed, 85 insertions(+), 4 deletions(-)

diff --git a/drivers/net/benet/be_cmds.c b/drivers/net/benet/be_cmds.c
index 2af87f1..8bd5315 100644
--- a/drivers/net/benet/be_cmds.c
+++ b/drivers/net/benet/be_cmds.c
@@ -349,7 +349,11 @@ static struct be_mcc_wrb *wrb_from_mccq(struct be_adapter *adapter)
 	struct be_queue_info *mccq = &adapter->mcc_obj.q;
 	struct be_mcc_wrb *wrb;
 
-	BUG_ON(atomic_read(&mccq->used) >= mccq->len);
+	if (atomic_read(&mccq->used) >= mccq->len) {
+		dev_err(&adapter->pdev->dev, "Out of MCCQ wrbs\n");
+		return NULL;
+	}
+
 	wrb = queue_head_node(mccq);
 	queue_head_inc(mccq);
 	atomic_inc(&mccq->used);
@@ -499,6 +503,10 @@ int be_cmd_pmac_add(struct be_adapter *adapter, u8 *mac_addr,
 	spin_lock_bh(&adapter->mcc_lock);
 
 	wrb = wrb_from_mccq(adapter);
+	if (!wrb) {
+		status = -EBUSY;
+		goto err;
+	}
 	req = embedded_payload(wrb);
 
 	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0);
@@ -515,6 +523,7 @@ int be_cmd_pmac_add(struct be_adapter *adapter, u8 *mac_addr,
 		*pmac_id = le32_to_cpu(resp->pmac_id);
 	}
 
+err:
 	spin_unlock_bh(&adapter->mcc_lock);
 	return status;
 }
@@ -529,6 +538,10 @@ int be_cmd_pmac_del(struct be_adapter *adapter, u32 if_id, u32 pmac_id)
 	spin_lock_bh(&adapter->mcc_lock);
 
 	wrb = wrb_from_mccq(adapter);
+	if (!wrb) {
+		status = -EBUSY;
+		goto err;
+	}
 	req = embedded_payload(wrb);
 
 	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0);
@@ -541,8 +554,8 @@ int be_cmd_pmac_del(struct be_adapter *adapter, u32 if_id, u32 pmac_id)
 
 	status = be_mcc_notify_wait(adapter);
 
+err:
 	spin_unlock_bh(&adapter->mcc_lock);
-
 	return status;
 }
 
@@ -861,10 +874,15 @@ int be_cmd_get_stats(struct be_adapter *adapter, struct be_dma_mem *nonemb_cmd)
 	struct be_mcc_wrb *wrb;
 	struct be_cmd_req_get_stats *req;
 	struct be_sge *sge;
+	int status = 0;
 
 	spin_lock_bh(&adapter->mcc_lock);
 
 	wrb = wrb_from_mccq(adapter);
+	if (!wrb) {
+		status = -EBUSY;
+		goto err;
+	}
 	req = nonemb_cmd->va;
 	sge = nonembedded_sgl(wrb);
 
@@ -879,8 +897,9 @@ int be_cmd_get_stats(struct be_adapter *adapter, struct be_dma_mem *nonemb_cmd)
 
 	be_mcc_notify(adapter);
 
+err:
 	spin_unlock_bh(&adapter->mcc_lock);
-	return 0;
+	return status;
 }
 
 /* Uses synchronous mcc */
@@ -894,6 +913,10 @@ int be_cmd_link_status_query(struct be_adapter *adapter,
 	spin_lock_bh(&adapter->mcc_lock);
 
 	wrb = wrb_from_mccq(adapter);
+	if (!wrb) {
+		status = -EBUSY;
+		goto err;
+	}
 	req = embedded_payload(wrb);
 
 	*link_up = false;
@@ -913,6 +936,7 @@ int be_cmd_link_status_query(struct be_adapter *adapter,
 		}
 	}
 
+err:
 	spin_unlock_bh(&adapter->mcc_lock);
 	return status;
 }
@@ -951,10 +975,15 @@ int be_cmd_modify_eqd(struct be_adapter *adapter, u32 eq_id, u32 eqd)
 {
 	struct be_mcc_wrb *wrb;
 	struct be_cmd_req_modify_eq_delay *req;
+	int status = 0;
 
 	spin_lock_bh(&adapter->mcc_lock);
 
 	wrb = wrb_from_mccq(adapter);
+	if (!wrb) {
+		status = -EBUSY;
+		goto err;
+	}
 	req = embedded_payload(wrb);
 
 	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0);
@@ -969,8 +998,9 @@ int be_cmd_modify_eqd(struct be_adapter *adapter, u32 eq_id, u32 eqd)
 
 	be_mcc_notify(adapter);
 
+err:
 	spin_unlock_bh(&adapter->mcc_lock);
-	return 0;
+	return status;
 }
 
 /* Uses sycnhronous mcc */
@@ -984,6 +1014,10 @@ int be_cmd_vlan_config(struct be_adapter *adapter, u32 if_id, u16 *vtag_array,
 	spin_lock_bh(&adapter->mcc_lock);
 
 	wrb = wrb_from_mccq(adapter);
+	if (!wrb) {
+		status = -EBUSY;
+		goto err;
+	}
 	req = embedded_payload(wrb);
 
 	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0);
@@ -1002,6 +1036,7 @@ int be_cmd_vlan_config(struct be_adapter *adapter, u32 if_id, u16 *vtag_array,
 
 	status = be_mcc_notify_wait(adapter);
 
+err:
 	spin_unlock_bh(&adapter->mcc_lock);
 	return status;
 }
@@ -1018,6 +1053,10 @@ int be_cmd_promiscuous_config(struct be_adapter *adapter, u8 port_num, bool en)
 	spin_lock_bh(&adapter->mcc_lock);
 
 	wrb = wrb_from_mccq(adapter);
+	if (!wrb) {
+		status = -EBUSY;
+		goto err;
+	}
 	req = embedded_payload(wrb);
 
 	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0);
@@ -1032,6 +1071,7 @@ int be_cmd_promiscuous_config(struct be_adapter *adapter, u8 port_num, bool en)
 
 	status = be_mcc_notify_wait(adapter);
 
+err:
 	spin_unlock_bh(&adapter->mcc_lock);
 	return status;
 }
@@ -1052,6 +1092,10 @@ int be_cmd_multicast_set(struct be_adapter *adapter, u32 if_id,
 	spin_lock_bh(&adapter->mcc_lock);
 
 	wrb = wrb_from_mccq(adapter);
+	if (!wrb) {
+		status = -EBUSY;
+		goto err;
+	}
 	sge = nonembedded_sgl(wrb);
 	memset(req, 0, sizeof(*req));
 
@@ -1078,6 +1122,7 @@ int be_cmd_multicast_set(struct be_adapter *adapter, u32 if_id,
 
 	status = be_mcc_notify_wait(adapter);
 
+err:
 	spin_unlock_bh(&adapter->mcc_lock);
 	return status;
 }
@@ -1092,6 +1137,10 @@ int be_cmd_set_flow_control(struct be_adapter *adapter, u32 tx_fc, u32 rx_fc)
 	spin_lock_bh(&adapter->mcc_lock);
 
 	wrb = wrb_from_mccq(adapter);
+	if (!wrb) {
+		status = -EBUSY;
+		goto err;
+	}
 	req = embedded_payload(wrb);
 
 	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0);
@@ -1104,6 +1153,7 @@ int be_cmd_set_flow_control(struct be_adapter *adapter, u32 tx_fc, u32 rx_fc)
 
 	status = be_mcc_notify_wait(adapter);
 
+err:
 	spin_unlock_bh(&adapter->mcc_lock);
 	return status;
 }
@@ -1118,6 +1168,10 @@ int be_cmd_get_flow_control(struct be_adapter *adapter, u32 *tx_fc, u32 *rx_fc)
 	spin_lock_bh(&adapter->mcc_lock);
 
 	wrb = wrb_from_mccq(adapter);
+	if (!wrb) {
+		status = -EBUSY;
+		goto err;
+	}
 	req = embedded_payload(wrb);
 
 	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0);
@@ -1133,6 +1187,7 @@ int be_cmd_get_flow_control(struct be_adapter *adapter, u32 *tx_fc, u32 *rx_fc)
 		*rx_fc = le16_to_cpu(resp->rx_flow_control);
 	}
 
+err:
 	spin_unlock_bh(&adapter->mcc_lock);
 	return status;
 }
@@ -1199,6 +1254,10 @@ int be_cmd_set_beacon_state(struct be_adapter *adapter, u8 port_num,
 	spin_lock_bh(&adapter->mcc_lock);
 
 	wrb = wrb_from_mccq(adapter);
+	if (!wrb) {
+		status = -EBUSY;
+		goto err;
+	}
 	req = embedded_payload(wrb);
 
 	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0);
@@ -1213,6 +1272,7 @@ int be_cmd_set_beacon_state(struct be_adapter *adapter, u8 port_num,
 
 	status = be_mcc_notify_wait(adapter);
 
+err:
 	spin_unlock_bh(&adapter->mcc_lock);
 	return status;
 }
@@ -1227,6 +1287,10 @@ int be_cmd_get_beacon_state(struct be_adapter *adapter, u8 port_num, u32 *state)
 	spin_lock_bh(&adapter->mcc_lock);
 
 	wrb = wrb_from_mccq(adapter);
+	if (!wrb) {
+		status = -EBUSY;
+		goto err;
+	}
 	req = embedded_payload(wrb);
 
 	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0);
@@ -1243,6 +1307,7 @@ int be_cmd_get_beacon_state(struct be_adapter *adapter, u8 port_num, u32 *state)
 		*state = resp->beacon_state;
 	}
 
+err:
 	spin_unlock_bh(&adapter->mcc_lock);
 	return status;
 }
@@ -1258,6 +1323,10 @@ int be_cmd_read_port_type(struct be_adapter *adapter, u32 port,
 	spin_lock_bh(&adapter->mcc_lock);
 
 	wrb = wrb_from_mccq(adapter);
+	if (!wrb) {
+		status = -EBUSY;
+		goto err;
+	}
 	req = embedded_payload(wrb);
 
 	be_wrb_hdr_prepare(wrb, sizeof(struct be_cmd_resp_port_type), true, 0);
@@ -1273,6 +1342,7 @@ int be_cmd_read_port_type(struct be_adapter *adapter, u32 port,
 			*connector = resp->data.connector;
 	}
 
+err:
 	spin_unlock_bh(&adapter->mcc_lock);
 	return status;
 }
@@ -1288,6 +1358,11 @@ int be_cmd_write_flashrom(struct be_adapter *adapter, struct be_dma_mem *cmd,
 	spin_lock_bh(&adapter->mcc_lock);
 
 	wrb = wrb_from_mccq(adapter);
+	if (!wrb) {
+		status = -EBUSY;
+		goto err;
+	}
+	req = cmd->va;
 	sge = nonembedded_sgl(wrb);
 
 	be_wrb_hdr_prepare(wrb, cmd->size, false, 1);
@@ -1304,6 +1379,7 @@ int be_cmd_write_flashrom(struct be_adapter *adapter, struct be_dma_mem *cmd,
 
 	status = be_mcc_notify_wait(adapter);
 
+err:
 	spin_unlock_bh(&adapter->mcc_lock);
 	return status;
 }
@@ -1317,6 +1393,10 @@ int be_cmd_get_flash_crc(struct be_adapter *adapter, u8 *flashed_crc)
 	spin_lock_bh(&adapter->mcc_lock);
 
 	wrb = wrb_from_mccq(adapter);
+	if (!wrb) {
+		status = -EBUSY;
+		goto err;
+	}
 	req = embedded_payload(wrb);
 
 	be_wrb_hdr_prepare(wrb, sizeof(*req)+4, true, 0);
@@ -1333,6 +1413,7 @@ int be_cmd_get_flash_crc(struct be_adapter *adapter, u8 *flashed_crc)
 	if (!status)
 		memcpy(flashed_crc, req->params.data_buf, 4);
 
+err:
 	spin_unlock_bh(&adapter->mcc_lock);
 	return status;
 }
-- 
1.6.5.2

