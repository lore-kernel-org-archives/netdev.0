From: Manish Chopra <manish.chopra@cavium.com>
Subject: [PATCH v2 net-next 5/7] qed: Add support for vf coalesce configuration.
Date: Wed, 26 Jul 2017 06:07:13 -0700
Message-ID: <20170726130715.12976-6-manish.chopra@cavium.com>
References: <20170726130715.12976-1-manish.chopra@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Yuval.Mintz@cavium.com>,
        <rahul.verma@cavium.com>, <sudarsana.kalluru@cavium.com>,
        Rahul Verma <Rahul.Verma@cavium.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam02on0064.outbound.protection.outlook.com ([104.47.36.64]:6224
        "EHLO NAM02-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751022AbdGZNHe (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 26 Jul 2017 09:07:34 -0400
In-Reply-To: <20170726130715.12976-1-manish.chopra@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rahul Verma <Rahul.Verma@cavium.com>

This patch add the ethtool support to set RX/Tx coalesce
value to the VF associated Rx/Tx queues.

Signed-off-by: Rahul Verma <Rahul.Verma@cavium.com>
Signed-off-by: Yuval Mintz <yuval.mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qed/qed_dev.c       |   73 +++++++++++++-------
 drivers/net/ethernet/qlogic/qed/qed_dev_api.h   |   41 ++++--------
 drivers/net/ethernet/qlogic/qed/qed_l2.h        |    7 ++
 drivers/net/ethernet/qlogic/qed/qed_main.c      |   24 +------
 drivers/net/ethernet/qlogic/qed/qed_sriov.c     |   83 +++++++++++++++++++++++
 drivers/net/ethernet/qlogic/qed/qed_vf.c        |   44 ++++++++++++
 drivers/net/ethernet/qlogic/qed/qed_vf.h        |   24 ++++++-
 drivers/net/ethernet/qlogic/qede/qede_ethtool.c |   38 ++++++++---
 include/linux/qed/qed_if.h                      |    4 +-
 9 files changed, 251 insertions(+), 87 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_dev.c b/drivers/net/ethernet/qlogic/qed/qed_dev.c
index f545607..58a689f 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_dev.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_dev.c
@@ -3694,7 +3694,7 @@ static int qed_set_coalesce(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt,
 	}
 
 	p_coal_timeset = p_eth_qzone;
-	memset(p_coal_timeset, 0, eth_qzone_size);
+	memset(p_eth_qzone, 0, eth_qzone_size);
 	SET_FIELD(p_coal_timeset->value, COALESCING_TIMESET_TIMESET, timeset);
 	SET_FIELD(p_coal_timeset->value, COALESCING_TIMESET_VALID, 1);
 	qed_memcpy_to(p_hwfn, p_ptt, hw_addr, p_eth_qzone, eth_qzone_size);
@@ -3702,12 +3702,46 @@ static int qed_set_coalesce(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt,
 	return 0;
 }
 
-int qed_set_rxq_coalesce(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt,
-			 u16 coalesce, u16 qid, u16 sb_id)
+int qed_set_queue_coalesce(u16 rx_coal, u16 tx_coal, void *p_handle)
+{
+	struct qed_queue_cid *p_cid = p_handle;
+	struct qed_hwfn *p_hwfn;
+	struct qed_ptt *p_ptt;
+	int rc = 0;
+
+	p_hwfn = p_cid->p_owner;
+
+	if (IS_VF(p_hwfn->cdev))
+		return qed_vf_pf_set_coalesce(p_hwfn, rx_coal, tx_coal, p_cid);
+
+	p_ptt = qed_ptt_acquire(p_hwfn);
+	if (!p_ptt)
+		return -EAGAIN;
+
+	if (rx_coal) {
+		rc = qed_set_rxq_coalesce(p_hwfn, p_ptt, rx_coal, p_cid);
+		if (rc)
+			goto out;
+		p_hwfn->cdev->rx_coalesce_usecs = rx_coal;
+	}
+
+	if (tx_coal) {
+		rc = qed_set_txq_coalesce(p_hwfn, p_ptt, tx_coal, p_cid);
+		if (rc)
+			goto out;
+		p_hwfn->cdev->tx_coalesce_usecs = tx_coal;
+	}
+out:
+	qed_ptt_release(p_hwfn, p_ptt);
+	return rc;
+}
+
+int qed_set_rxq_coalesce(struct qed_hwfn *p_hwfn,
+			 struct qed_ptt *p_ptt,
+			 u16 coalesce, struct qed_queue_cid *p_cid)
 {
 	struct ustorm_eth_queue_zone eth_qzone;
 	u8 timeset, timer_res;
-	u16 fw_qid = 0;
 	u32 address;
 	int rc;
 
@@ -3724,32 +3758,29 @@ int qed_set_rxq_coalesce(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt,
 	}
 	timeset = (u8)(coalesce >> timer_res);
 
-	rc = qed_fw_l2_queue(p_hwfn, qid, &fw_qid);
-	if (rc)
-		return rc;
-
-	rc = qed_int_set_timer_res(p_hwfn, p_ptt, timer_res, sb_id, false);
+	rc = qed_int_set_timer_res(p_hwfn, p_ptt, timer_res,
+				   p_cid->sb_igu_id, false);
 	if (rc)
 		goto out;
 
-	address = BAR0_MAP_REG_USDM_RAM + USTORM_ETH_QUEUE_ZONE_OFFSET(fw_qid);
+	address = BAR0_MAP_REG_USDM_RAM +
+		  USTORM_ETH_QUEUE_ZONE_OFFSET(p_cid->abs.queue_id);
 
 	rc = qed_set_coalesce(p_hwfn, p_ptt, address, &eth_qzone,
 			      sizeof(struct ustorm_eth_queue_zone), timeset);
 	if (rc)
 		goto out;
 
-	p_hwfn->cdev->rx_coalesce_usecs = coalesce;
 out:
 	return rc;
 }
 
-int qed_set_txq_coalesce(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt,
-			 u16 coalesce, u16 qid, u16 sb_id)
+int qed_set_txq_coalesce(struct qed_hwfn *p_hwfn,
+			 struct qed_ptt *p_ptt,
+			 u16 coalesce, struct qed_queue_cid *p_cid)
 {
 	struct xstorm_eth_queue_zone eth_qzone;
 	u8 timeset, timer_res;
-	u16 fw_qid = 0;
 	u32 address;
 	int rc;
 
@@ -3766,22 +3797,16 @@ int qed_set_txq_coalesce(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt,
 	}
 	timeset = (u8)(coalesce >> timer_res);
 
-	rc = qed_fw_l2_queue(p_hwfn, qid, &fw_qid);
-	if (rc)
-		return rc;
-
-	rc = qed_int_set_timer_res(p_hwfn, p_ptt, timer_res, sb_id, true);
+	rc = qed_int_set_timer_res(p_hwfn, p_ptt, timer_res,
+				   p_cid->sb_igu_id, true);
 	if (rc)
 		goto out;
 
-	address = BAR0_MAP_REG_XSDM_RAM + XSTORM_ETH_QUEUE_ZONE_OFFSET(fw_qid);
+	address = BAR0_MAP_REG_XSDM_RAM +
+		  XSTORM_ETH_QUEUE_ZONE_OFFSET(p_cid->abs.queue_id);
 
 	rc = qed_set_coalesce(p_hwfn, p_ptt, address, &eth_qzone,
 			      sizeof(struct xstorm_eth_queue_zone), timeset);
-	if (rc)
-		goto out;
-
-	p_hwfn->cdev->tx_coalesce_usecs = coalesce;
 out:
 	return rc;
 }
diff --git a/drivers/net/ethernet/qlogic/qed/qed_dev_api.h b/drivers/net/ethernet/qlogic/qed/qed_dev_api.h
index 1f1df1b..e6b3c83 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_dev_api.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_dev_api.h
@@ -443,38 +443,23 @@ int qed_final_cleanup(struct qed_hwfn *p_hwfn,
 		      struct qed_ptt *p_ptt, u16 id, bool is_vf);
 
 /**
- * @brief qed_set_rxq_coalesce - Configure coalesce parameters for an Rx queue
- * The fact that we can configure coalescing to up to 511, but on varying
- * accuracy [the bigger the value the less accurate] up to a mistake of 3usec
- * for the highest values.
- *
- * @param p_hwfn
- * @param p_ptt
- * @param coalesce - Coalesce value in micro seconds.
- * @param qid - Queue index.
- * @param qid - SB Id
- *
- * @return int
- */
-int qed_set_rxq_coalesce(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt,
-			 u16 coalesce, u16 qid, u16 sb_id);
-
-/**
- * @brief qed_set_txq_coalesce - Configure coalesce parameters for a Tx queue
- * While the API allows setting coalescing per-qid, all tx queues sharing a
- * SB should be in same range [i.e., either 0-0x7f, 0x80-0xff or 0x100-0x1ff]
+ * @brief qed_set_queue_coalesce - Configure coalesce parameters for Rx or
+ * Tx queue. We can configure coalescing to up to 511, but on
+ * varying accuracy [the bigger the value the less accurate] up to a mistake
+ * of 3usec for the highest values.
+ * While the API allows setting coalescing per-qid, all queues sharing a SB
+ * should be in same range [i.e., either 0-0x7f, 0x80-0xff or 0x100-0x1ff]
  * otherwise configuration would break.
  *
- * @param p_hwfn
- * @param p_ptt
- * @param coalesce - Coalesce value in micro seconds.
- * @param qid - Queue index.
- * @param qid - SB Id
+ * @param rx_coal - Rx Coalesce value in micro seconds.
+ * @param tx_coal - TX Coalesce value in micro seconds.
+ * @param p_handle
  *
  * @return int
- */
-int qed_set_txq_coalesce(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt,
-			 u16 coalesce, u16 qid, u16 sb_id);
+ **/
+int
+qed_set_queue_coalesce(u16 rx_coal, u16 tx_coal, void *p_handle);
+
 
 const char *qed_hw_get_resc_name(enum qed_resources res_id);
 #endif
diff --git a/drivers/net/ethernet/qlogic/qed/qed_l2.h b/drivers/net/ethernet/qlogic/qed/qed_l2.h
index f8f09aa..60ea72c 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_l2.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_l2.h
@@ -400,4 +400,11 @@ struct qed_queue_cid *
 
 u8 qed_mcast_bin_from_mac(u8 *mac);
 
+int qed_set_rxq_coalesce(struct qed_hwfn *p_hwfn,
+			 struct qed_ptt *p_ptt,
+			 u16 coalesce, struct qed_queue_cid *p_cid);
+
+int qed_set_txq_coalesce(struct qed_hwfn *p_hwfn,
+			 struct qed_ptt *p_ptt,
+			 u16 coalesce, struct qed_queue_cid *p_cid);
 #endif /* _QED_L2_H */
diff --git a/drivers/net/ethernet/qlogic/qed/qed_main.c b/drivers/net/ethernet/qlogic/qed/qed_main.c
index 0a06683..448810a 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_main.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_main.c
@@ -1575,29 +1575,9 @@ static void qed_get_coalesce(struct qed_dev *cdev, u16 *rx_coal, u16 *tx_coal)
 }
 
 static int qed_set_coalesce(struct qed_dev *cdev, u16 rx_coal, u16 tx_coal,
-			    u16 qid, u16 sb_id)
+			    void *handle)
 {
-	struct qed_hwfn *hwfn;
-	struct qed_ptt *ptt;
-	int hwfn_index;
-	int status = 0;
-
-	hwfn_index = qid % cdev->num_hwfns;
-	hwfn = &cdev->hwfns[hwfn_index];
-	ptt = qed_ptt_acquire(hwfn);
-	if (!ptt)
-		return -EAGAIN;
-
-	status = qed_set_rxq_coalesce(hwfn, ptt, rx_coal,
-				      qid / cdev->num_hwfns, sb_id);
-	if (status)
-		goto out;
-	status = qed_set_txq_coalesce(hwfn, ptt, tx_coal,
-				      qid / cdev->num_hwfns, sb_id);
-out:
-	qed_ptt_release(hwfn, ptt);
-
-	return status;
+		return qed_set_queue_coalesce(rx_coal, tx_coal, handle);
 }
 
 static int qed_set_led(struct qed_dev *cdev, enum qed_led_mode mode)
diff --git a/drivers/net/ethernet/qlogic/qed/qed_sriov.c b/drivers/net/ethernet/qlogic/qed/qed_sriov.c
index 2cfd3bd..5feef78 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_sriov.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_sriov.c
@@ -3400,6 +3400,86 @@ static void qed_iov_vf_mbx_release(struct qed_hwfn *p_hwfn,
 			     length, status);
 }
 
+static void qed_iov_vf_pf_set_coalesce(struct qed_hwfn *p_hwfn,
+				       struct qed_ptt *p_ptt,
+				       struct qed_vf_info *vf)
+{
+	struct qed_iov_vf_mbx *mbx = &vf->vf_mbx;
+	struct vfpf_update_coalesce *req;
+	u8 status = PFVF_STATUS_FAILURE;
+	struct qed_queue_cid *p_cid;
+	u16 rx_coal, tx_coal;
+	int rc = 0, i;
+	u16 qid;
+
+	req = &mbx->req_virt->update_coalesce;
+
+	rx_coal = req->rx_coal;
+	tx_coal = req->tx_coal;
+	qid = req->qid;
+
+	if (!qed_iov_validate_rxq(p_hwfn, vf, qid,
+				  QED_IOV_VALIDATE_Q_ENABLE) && rx_coal) {
+		DP_VERBOSE(p_hwfn, QED_MSG_IOV,
+			   "VF[%d]: Invalid Rx queue_id = %d\n",
+			   vf->abs_vf_id, qid);
+		goto out;
+	}
+
+	if (!qed_iov_validate_txq(p_hwfn, vf, qid,
+				  QED_IOV_VALIDATE_Q_ENABLE) && tx_coal) {
+		DP_VERBOSE(p_hwfn, QED_MSG_IOV,
+			   "VF[%d]: Invalid Tx queue_id = %d\n",
+			   vf->abs_vf_id, qid);
+		goto out;
+	}
+
+	DP_VERBOSE(p_hwfn,
+		   QED_MSG_IOV,
+		   "VF[%d]: Setting coalesce for VF rx_coal = %d, tx_coal = %d at queue = %d\n",
+		   vf->abs_vf_id, rx_coal, tx_coal, qid);
+
+	if (rx_coal) {
+		p_cid = qed_iov_get_vf_rx_queue_cid(&vf->vf_queues[qid]);
+
+		rc = qed_set_rxq_coalesce(p_hwfn, p_ptt, rx_coal, p_cid);
+		if (rc) {
+			DP_VERBOSE(p_hwfn,
+				   QED_MSG_IOV,
+				   "VF[%d]: Unable to set rx queue = %d coalesce\n",
+				   vf->abs_vf_id, vf->vf_queues[qid].fw_rx_qid);
+			goto out;
+		}
+	}
+
+	if (tx_coal) {
+		struct qed_vf_queue *p_queue = &vf->vf_queues[qid];
+
+		for (i = 0; i < MAX_QUEUES_PER_QZONE; i++) {
+			if (!p_queue->cids[i].p_cid)
+				continue;
+
+			if (!p_queue->cids[i].b_is_tx)
+				continue;
+
+			rc = qed_set_txq_coalesce(p_hwfn, p_ptt, tx_coal,
+						  p_queue->cids[i].p_cid);
+
+			if (rc) {
+				DP_VERBOSE(p_hwfn,
+					   QED_MSG_IOV,
+					   "VF[%d]: Unable to set tx queue coalesce\n",
+					   vf->abs_vf_id);
+				goto out;
+			}
+		}
+	}
+
+	status = PFVF_STATUS_SUCCESS;
+out:
+	qed_iov_prepare_resp(p_hwfn, p_ptt, vf, CHANNEL_TLV_COALESCE_UPDATE,
+			     sizeof(struct pfvf_def_resp_tlv), status);
+}
 static int
 qed_iov_vf_flr_poll_dorq(struct qed_hwfn *p_hwfn,
 			 struct qed_vf_info *p_vf, struct qed_ptt *p_ptt)
@@ -3725,6 +3805,9 @@ static void qed_iov_process_mbx_req(struct qed_hwfn *p_hwfn,
 		case CHANNEL_TLV_UPDATE_TUNN_PARAM:
 			qed_iov_vf_mbx_update_tunn_param(p_hwfn, p_ptt, p_vf);
 			break;
+		case CHANNEL_TLV_COALESCE_UPDATE:
+			qed_iov_vf_pf_set_coalesce(p_hwfn, p_ptt, p_vf);
+			break;
 		}
 	} else if (qed_iov_tlv_supported(mbx->first_tlv.tl.type)) {
 		DP_VERBOSE(p_hwfn, QED_MSG_IOV,
diff --git a/drivers/net/ethernet/qlogic/qed/qed_vf.c b/drivers/net/ethernet/qlogic/qed/qed_vf.c
index 1926d1e..0a7bbc0 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_vf.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_vf.c
@@ -1343,6 +1343,50 @@ int qed_vf_pf_int_cleanup(struct qed_hwfn *p_hwfn)
 	return rc;
 }
 
+int
+qed_vf_pf_set_coalesce(struct qed_hwfn *p_hwfn,
+		       u16 rx_coal, u16 tx_coal, struct qed_queue_cid *p_cid)
+{
+	struct qed_vf_iov *p_iov = p_hwfn->vf_iov_info;
+	struct vfpf_update_coalesce *req;
+	struct pfvf_def_resp_tlv *resp;
+	int rc;
+
+	/* clear mailbox and prep header tlv */
+	req = qed_vf_pf_prep(p_hwfn, CHANNEL_TLV_COALESCE_UPDATE, sizeof(*req));
+
+	req->rx_coal = rx_coal;
+	req->tx_coal = tx_coal;
+	req->qid = p_cid->rel.queue_id;
+
+	DP_VERBOSE(p_hwfn,
+		   QED_MSG_IOV,
+		   "Setting coalesce rx_coal = %d, tx_coal = %d at queue = %d\n",
+		   rx_coal, tx_coal, req->qid);
+
+	/* add list termination tlv */
+	qed_add_tlv(p_hwfn, &p_iov->offset, CHANNEL_TLV_LIST_END,
+		    sizeof(struct channel_list_end_tlv));
+
+	resp = &p_iov->pf2vf_reply->default_resp;
+	rc = qed_send_msg2pf(p_hwfn, &resp->hdr.status, sizeof(*resp));
+	if (rc)
+		goto exit;
+
+	if (resp->hdr.status != PFVF_STATUS_SUCCESS)
+		goto exit;
+
+	if (rx_coal)
+		p_hwfn->cdev->rx_coalesce_usecs = rx_coal;
+
+	if (tx_coal)
+		p_hwfn->cdev->tx_coalesce_usecs = tx_coal;
+
+exit:
+	qed_vf_pf_req_end(p_hwfn, rc);
+	return rc;
+}
+
 u16 qed_vf_get_igu_sb_id(struct qed_hwfn *p_hwfn, u16 sb_id)
 {
 	struct qed_vf_iov *p_iov = p_hwfn->vf_iov_info;
diff --git a/drivers/net/ethernet/qlogic/qed/qed_vf.h b/drivers/net/ethernet/qlogic/qed/qed_vf.h
index 34d9b88..2d9fdd6 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_vf.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_vf.h
@@ -497,6 +497,13 @@ struct tlv_buffer_size {
 	u8 tlv_buffer[TLV_BUFFER_SIZE];
 };
 
+struct vfpf_update_coalesce {
+	struct vfpf_first_tlv first_tlv;
+	u16 rx_coal;
+	u16 tx_coal;
+	u16 qid;
+	u8 padding[2];
+};
 union vfpf_tlvs {
 	struct vfpf_first_tlv first_tlv;
 	struct vfpf_acquire_tlv acquire;
@@ -509,6 +516,7 @@ struct tlv_buffer_size {
 	struct vfpf_vport_update_tlv vport_update;
 	struct vfpf_ucast_filter_tlv ucast_filter;
 	struct vfpf_update_tunn_param_tlv tunn_param_update;
+	struct vfpf_update_coalesce update_coalesce;
 	struct channel_list_end_tlv list_end;
 	struct tlv_buffer_size tlv_buf_size;
 };
@@ -624,7 +632,7 @@ enum {
 	CHANNEL_TLV_VPORT_UPDATE_ACCEPT_ANY_VLAN,
 	CHANNEL_TLV_VPORT_UPDATE_SGE_TPA,
 	CHANNEL_TLV_UPDATE_TUNN_PARAM,
-	CHANNEL_TLV_RESERVED,
+	CHANNEL_TLV_COALESCE_UPDATE,
 	CHANNEL_TLV_QID,
 	CHANNEL_TLV_MAX,
 
@@ -677,6 +685,20 @@ struct qed_vf_iov {
 	bool b_doorbell_bar;
 };
 
+/**
+ * @brief VF - Set Rx/Tx coalesce per VF's relative queue.
+ *             Coalesce value '0' will omit the configuration.
+ *
+ * @param p_hwfn
+ * @param rx_coal - coalesce value in micro second for rx queue
+ * @param tx_coal - coalesce value in micro second for tx queue
+ * @param p_cid   - queue cid
+ *
+ **/
+int qed_vf_pf_set_coalesce(struct qed_hwfn *p_hwfn,
+			   u16 rx_coal,
+			   u16 tx_coal, struct qed_queue_cid *p_cid);
+
 #ifdef CONFIG_QED_SRIOV
 /**
  * @brief Read the VF bulletin and act on it if needed
diff --git a/drivers/net/ethernet/qlogic/qede/qede_ethtool.c b/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
index 55fa2ef..76e0b13 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
@@ -718,8 +718,9 @@ static int qede_set_coalesce(struct net_device *dev,
 			     struct ethtool_coalesce *coal)
 {
 	struct qede_dev *edev = netdev_priv(dev);
+	struct qede_fastpath *fp;
 	int i, rc = 0;
-	u16 rxc, txc, sb_id;
+	u16 rxc, txc;
 
 	if (!netif_running(dev)) {
 		DP_INFO(edev, "Interface is down\n");
@@ -730,21 +731,36 @@ static int qede_set_coalesce(struct net_device *dev,
 	    coal->tx_coalesce_usecs > QED_COALESCE_MAX) {
 		DP_INFO(edev,
 			"Can't support requested %s coalesce value [max supported value %d]\n",
-			coal->rx_coalesce_usecs > QED_COALESCE_MAX ? "rx"
-								   : "tx",
-			QED_COALESCE_MAX);
+			coal->rx_coalesce_usecs > QED_COALESCE_MAX ? "rx" :
+			"tx", QED_COALESCE_MAX);
 		return -EINVAL;
 	}
 
 	rxc = (u16)coal->rx_coalesce_usecs;
 	txc = (u16)coal->tx_coalesce_usecs;
 	for_each_queue(i) {
-		sb_id = edev->fp_array[i].sb_info->igu_sb_id;
-		rc = edev->ops->common->set_coalesce(edev->cdev, rxc, txc,
-						     (u16)i, sb_id);
-		if (rc) {
-			DP_INFO(edev, "Set coalesce error, rc = %d\n", rc);
-			return rc;
+		fp = &edev->fp_array[i];
+
+		if (edev->fp_array[i].type & QEDE_FASTPATH_RX) {
+			rc = edev->ops->common->set_coalesce(edev->cdev,
+							     rxc, 0,
+							     fp->rxq->handle);
+			if (rc) {
+				DP_INFO(edev,
+					"Set RX coalesce error, rc = %d\n", rc);
+				return rc;
+			}
+		}
+
+		if (edev->fp_array[i].type & QEDE_FASTPATH_TX) {
+			rc = edev->ops->common->set_coalesce(edev->cdev,
+							     0, txc,
+							     fp->txq->handle);
+			if (rc) {
+				DP_INFO(edev,
+					"Set TX coalesce error, rc = %d\n", rc);
+				return rc;
+			}
 		}
 	}
 
@@ -1758,6 +1774,8 @@ static int qede_set_eee(struct net_device *dev, struct ethtool_eee *edata)
 	.get_msglevel = qede_get_msglevel,
 	.set_msglevel = qede_set_msglevel,
 	.get_link = qede_get_link,
+	.get_coalesce = qede_get_coalesce,
+	.set_coalesce = qede_set_coalesce,
 	.get_ringparam = qede_get_ringparam,
 	.set_ringparam = qede_set_ringparam,
 	.get_strings = qede_get_strings,
diff --git a/include/linux/qed/qed_if.h b/include/linux/qed/qed_if.h
index 9f32762..4d59ca1 100644
--- a/include/linux/qed/qed_if.h
+++ b/include/linux/qed/qed_if.h
@@ -694,8 +694,8 @@ struct qed_common_ops {
  *
  * @return 0 on success, error otherwise.
  */
-	int (*set_coalesce)(struct qed_dev *cdev, u16 rx_coal, u16 tx_coal,
-			    u16 qid, u16 sb_id);
+	int (*set_coalesce)(struct qed_dev *cdev,
+			    u16 rx_coal, u16 tx_coal, void *handle);
 
 /**
  * @brief set_led - Configure LED mode
-- 
1.7.1
