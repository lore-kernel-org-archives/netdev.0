From: Sudarsana Reddy Kalluru <sudarsana.kalluru@qlogic.com>
Subject: [PATCH net-next 1/2] qed: Add support for coalescing config read/update.
Date: Tue, 21 Jun 2016 09:36:21 -0400
Message-ID: <1466516182-24442-2-git-send-email-sudarsana.kalluru@qlogic.com>
References: <1466516182-24442-1-git-send-email-sudarsana.kalluru@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Yuval.Mintz@qlogic.com>,
	<sudarsana.kalluru@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:40935 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752066AbcFUPIy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jun 2016 11:08:54 -0400
In-Reply-To: <1466516182-24442-1-git-send-email-sudarsana.kalluru@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for configuring the device tx/rx coalescing
timeout values in the order of micro seconds. It also adds APIs for
upper layer drivers for reading/updating the coalescing values.

Signed-off-by: Sudarsana Reddy Kalluru <sudarsana.kalluru@qlogic.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/net/ethernet/qlogic/qed/qed_dev.c      | 104 +++++++++++++++++++++++++
 drivers/net/ethernet/qlogic/qed/qed_dev_api.h  |  47 +++++++++++
 drivers/net/ethernet/qlogic/qed/qed_hw.c       |  23 ++++++
 drivers/net/ethernet/qlogic/qed/qed_int.c      |  75 ++++++++++++++++--
 drivers/net/ethernet/qlogic/qed/qed_int.h      |   3 +
 drivers/net/ethernet/qlogic/qed/qed_main.c     |  34 ++++++++
 drivers/net/ethernet/qlogic/qed/qed_reg_addr.h |   2 +
 include/linux/qed/qed_if.h                     |  24 ++++++
 8 files changed, 307 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_dev.c b/drivers/net/ethernet/qlogic/qed/qed_dev.c
index e45cff4..b26fe26 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_dev.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_dev.c
@@ -2222,6 +2222,110 @@ int qed_fw_rss_eng(struct qed_hwfn *p_hwfn,
 	return 0;
 }
 
+static int qed_set_coalesce(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt,
+			    u32 hw_addr, void *p_eth_qzone,
+			    size_t eth_qzone_size, u8 timeset)
+{
+	struct coalescing_timeset *p_coal_timeset;
+
+	if (p_hwfn->cdev->int_coalescing_mode != QED_COAL_MODE_ENABLE) {
+		DP_NOTICE(p_hwfn, "Coalescing configuration not enabled\n");
+		return -EINVAL;
+	}
+
+	p_coal_timeset = p_eth_qzone;
+	memset(p_coal_timeset, 0, eth_qzone_size);
+	SET_FIELD(p_coal_timeset->value, COALESCING_TIMESET_TIMESET, timeset);
+	SET_FIELD(p_coal_timeset->value, COALESCING_TIMESET_VALID, 1);
+	qed_memcpy_to(p_hwfn, p_ptt, hw_addr, p_eth_qzone, eth_qzone_size);
+
+	return 0;
+}
+
+int qed_set_rxq_coalesce(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt,
+			 u16 coalesce, u8 qid, u16 sb_id)
+{
+	struct ustorm_eth_queue_zone eth_qzone;
+	u8 timeset, timer_res;
+	u16 fw_qid = 0;
+	u32 address;
+	int rc;
+
+	/* Coalesce = (timeset << timer-resolution), timeset is 7bit wide */
+	if (coalesce <= 0x7F) {
+		timer_res = 0;
+	} else if (coalesce <= 0xFF) {
+		timer_res = 1;
+	} else if (coalesce <= 0x1FF) {
+		timer_res = 2;
+	} else {
+		DP_ERR(p_hwfn, "Invalid coalesce value - %d\n", coalesce);
+		return -EINVAL;
+	}
+	timeset = (u8)(coalesce >> timer_res);
+
+	rc = qed_fw_l2_queue(p_hwfn, (u16)qid, &fw_qid);
+	if (rc)
+		return rc;
+
+	rc = qed_int_set_timer_res(p_hwfn, p_ptt, timer_res, sb_id, false);
+	if (rc)
+		goto out;
+
+	address = BAR0_MAP_REG_USDM_RAM + USTORM_ETH_QUEUE_ZONE_OFFSET(fw_qid);
+
+	rc = qed_set_coalesce(p_hwfn, p_ptt, address, &eth_qzone,
+			      sizeof(struct ustorm_eth_queue_zone), timeset);
+	if (rc)
+		goto out;
+
+	p_hwfn->cdev->rx_coalesce_usecs = coalesce;
+out:
+	return rc;
+}
+
+int qed_set_txq_coalesce(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt,
+			 u16 coalesce, u8 qid, u16 sb_id)
+{
+	struct xstorm_eth_queue_zone eth_qzone;
+	u8 timeset, timer_res;
+	u16 fw_qid = 0;
+	u32 address;
+	int rc;
+
+	/* Coalesce = (timeset << timer-resolution), timeset is 7bit wide */
+	if (coalesce <= 0x7F) {
+		timer_res = 0;
+	} else if (coalesce <= 0xFF) {
+		timer_res = 1;
+	} else if (coalesce <= 0x1FF) {
+		timer_res = 2;
+	} else {
+		DP_ERR(p_hwfn, "Invalid coalesce value - %d\n", coalesce);
+		return -EINVAL;
+	}
+	timeset = (u8)(coalesce >> timer_res);
+
+	rc = qed_fw_l2_queue(p_hwfn, (u16)qid, &fw_qid);
+	if (rc)
+		return rc;
+
+	rc = qed_int_set_timer_res(p_hwfn, p_ptt, timer_res, sb_id, true);
+	if (rc)
+		goto out;
+
+	address = BAR0_MAP_REG_XSDM_RAM + XSTORM_ETH_QUEUE_ZONE_OFFSET(fw_qid);
+
+	rc = qed_set_coalesce(p_hwfn, p_ptt, address, &eth_qzone,
+			      sizeof(struct xstorm_eth_queue_zone), timeset);
+	if (rc)
+		goto out;
+
+	p_hwfn->cdev->tx_coalesce_usecs = coalesce;
+out:
+	return rc;
+}
+
 /* Calculate final WFQ values for all vports and configure them.
  * After this configuration each vport will have
  * approx min rate =  min_pf_rate * (vport_wfq / QED_WFQ_UNIT)
diff --git a/drivers/net/ethernet/qlogic/qed/qed_dev_api.h b/drivers/net/ethernet/qlogic/qed/qed_dev_api.h
index f810ce4..343bb03 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_dev_api.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_dev_api.h
@@ -212,6 +212,20 @@ qed_dmae_host2grc(struct qed_hwfn *p_hwfn,
 		  u32 size_in_dwords,
 		  u32 flags);
 
+ /**
+ * @brief qed_dmae_grc2host - Read data from dmae data offset
+ * to source address using the given ptt
+ *
+ * @param p_ptt
+ * @param grc_addr (dmae_data_offset)
+ * @param dest_addr
+ * @param size_in_dwords
+ * @param flags - one of the flags defined above
+ */
+int qed_dmae_grc2host(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt,
+		      u32 grc_addr, dma_addr_t dest_addr, u32 size_in_dwords,
+		      u32 flags);
+
 /**
  * @brief qed_dmae_host2host - copy data from to source address
  * to a destination adress (for SRIOV) using the given ptt
@@ -308,4 +322,37 @@ int qed_fw_rss_eng(struct qed_hwfn *p_hwfn,
 int qed_final_cleanup(struct qed_hwfn *p_hwfn,
 		      struct qed_ptt *p_ptt, u16 id, bool is_vf);
 
+/**
+ * @brief qed_set_rxq_coalesce - Configure coalesce parameters for an Rx queue
+ * The fact that we can configure coalescing to up to 511, but on varying
+ * accuracy [the bigger the value the less accurate] up to a mistake of 3usec
+ * for the highest values.
+ *
+ * @param p_hwfn
+ * @param p_ptt
+ * @param coalesce - Coalesce value in micro seconds.
+ * @param qid - Queue index.
+ * @param qid - SB Id
+ *
+ * @return int
+ */
+int qed_set_rxq_coalesce(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt,
+			 u16 coalesce, u8 qid, u16 sb_id);
+
+/**
+ * @brief qed_set_txq_coalesce - Configure coalesce parameters for a Tx queue
+ * While the API allows setting coalescing per-qid, all tx queues sharing a
+ * SB should be in same range [i.e., either 0-0x7f, 0x80-0xff or 0x100-0x1ff]
+ * otherwise configuration would break.
+ *
+ * @param p_hwfn
+ * @param p_ptt
+ * @param coalesce - Coalesce value in micro seconds.
+ * @param qid - Queue index.
+ * @param qid - SB Id
+ *
+ * @return int
+ */
+int qed_set_txq_coalesce(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt,
+			 u16 coalesce, u8 qid, u16 sb_id);
 #endif
diff --git a/drivers/net/ethernet/qlogic/qed/qed_hw.c b/drivers/net/ethernet/qlogic/qed/qed_hw.c
index 2693c30..e178853 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_hw.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_hw.c
@@ -769,6 +769,29 @@ int qed_dmae_host2grc(struct qed_hwfn *p_hwfn,
 }
 
 int
+qed_dmae_grc2host(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt, u32 grc_addr,
+		  dma_addr_t dest_addr, u32 size_in_dwords, u32 flags)
+{
+	u32 grc_addr_in_dw = grc_addr / sizeof(u32);
+	struct qed_dmae_params params;
+	int rc;
+
+	memset(&params, 0, sizeof(struct qed_dmae_params));
+	params.flags = flags;
+
+	mutex_lock(&p_hwfn->dmae_info.mutex);
+
+	rc = qed_dmae_execute_command(p_hwfn, p_ptt, grc_addr_in_dw,
+				      dest_addr, QED_DMAE_ADDRESS_GRC,
+				      QED_DMAE_ADDRESS_HOST_VIRT,
+				      size_in_dwords, &params);
+
+	mutex_unlock(&p_hwfn->dmae_info.mutex);
+
+	return rc;
+}
+
+int
 qed_dmae_host2host(struct qed_hwfn *p_hwfn,
 		   struct qed_ptt *p_ptt,
 		   dma_addr_t source_addr,
diff --git a/drivers/net/ethernet/qlogic/qed/qed_int.c b/drivers/net/ethernet/qlogic/qed/qed_int.c
index 09a6ad3..8fa50fa 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_int.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_int.c
@@ -2418,6 +2418,7 @@ void qed_init_cau_sb_entry(struct qed_hwfn *p_hwfn,
 {
 	struct qed_dev *cdev = p_hwfn->cdev;
 	u32 cau_state;
+	u8 timer_res;
 
 	memset(p_sb_entry, 0, sizeof(*p_sb_entry));
 
@@ -2443,6 +2444,23 @@ void qed_init_cau_sb_entry(struct qed_hwfn *p_hwfn,
 			cdev->tx_coalesce_usecs = QED_CAU_DEF_TX_USECS;
 	}
 
+	/* Coalesce = (timeset << timer-res), timeset is 7bit wide */
+	if (cdev->rx_coalesce_usecs <= 0x7F)
+		timer_res = 0;
+	else if (cdev->rx_coalesce_usecs <= 0xFF)
+		timer_res = 1;
+	else
+		timer_res = 2;
+	SET_FIELD(p_sb_entry->params, CAU_SB_ENTRY_TIMER_RES0, timer_res);
+
+	if (cdev->tx_coalesce_usecs <= 0x7F)
+		timer_res = 0;
+	else if (cdev->tx_coalesce_usecs <= 0xFF)
+		timer_res = 1;
+	else
+		timer_res = 2;
+	SET_FIELD(p_sb_entry->params, CAU_SB_ENTRY_TIMER_RES1, timer_res);
+
 	SET_FIELD(p_sb_entry->data, CAU_SB_ENTRY_STATE0, cau_state);
 	SET_FIELD(p_sb_entry->data, CAU_SB_ENTRY_STATE1, cau_state);
 }
@@ -2484,17 +2502,28 @@ void qed_int_cau_conf_sb(struct qed_hwfn *p_hwfn,
 
 	/* Configure pi coalescing if set */
 	if (p_hwfn->cdev->int_coalescing_mode == QED_COAL_MODE_ENABLE) {
-		u8 timeset = p_hwfn->cdev->rx_coalesce_usecs >>
-			     (QED_CAU_DEF_RX_TIMER_RES + 1);
+		u8 timeset, timer_res;
 		u8 num_tc = 1, i;
 
+		/* timeset = (coalesce >> timer-res), timeset is 7bit wide */
+		if (p_hwfn->cdev->rx_coalesce_usecs <= 0x7F)
+			timer_res = 0;
+		else if (p_hwfn->cdev->rx_coalesce_usecs <= 0xFF)
+			timer_res = 1;
+		else
+			timer_res = 2;
+		timeset = (u8)(p_hwfn->cdev->rx_coalesce_usecs >> timer_res);
 		qed_int_cau_conf_pi(p_hwfn, p_ptt, igu_sb_id, RX_PI,
 				    QED_COAL_RX_STATE_MACHINE,
 				    timeset);
 
-		timeset = p_hwfn->cdev->tx_coalesce_usecs >>
-			  (QED_CAU_DEF_TX_TIMER_RES + 1);
-
+		if (p_hwfn->cdev->tx_coalesce_usecs <= 0x7F)
+			timer_res = 0;
+		else if (p_hwfn->cdev->tx_coalesce_usecs <= 0xFF)
+			timer_res = 1;
+		else
+			timer_res = 2;
+		timeset = (u8)(p_hwfn->cdev->tx_coalesce_usecs >> timer_res);
 		for (i = 0; i < num_tc; i++) {
 			qed_int_cau_conf_pi(p_hwfn, p_ptt,
 					    igu_sb_id, TX_PI(i),
@@ -3199,3 +3228,39 @@ void qed_int_disable_post_isr_release(struct qed_dev *cdev)
 	for_each_hwfn(cdev, i)
 		cdev->hwfns[i].b_int_requested = false;
 }
+
+int qed_int_set_timer_res(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt,
+			  u8 timer_res, u16 sb_id, bool tx)
+{
+	struct cau_sb_entry sb_entry;
+	int rc;
+
+	if (!p_hwfn->hw_init_done) {
+		DP_ERR(p_hwfn, "hardware not initialized yet\n");
+		return -EINVAL;
+	}
+
+	rc = qed_dmae_grc2host(p_hwfn, p_ptt, CAU_REG_SB_VAR_MEMORY +
+			       sb_id * sizeof(u64),
+			       (u64)(uintptr_t)&sb_entry, 2, 0);
+	if (rc) {
+		DP_ERR(p_hwfn, "dmae_grc2host failed %d\n", rc);
+		return rc;
+	}
+
+	if (tx)
+		SET_FIELD(sb_entry.params, CAU_SB_ENTRY_TIMER_RES1, timer_res);
+	else
+		SET_FIELD(sb_entry.params, CAU_SB_ENTRY_TIMER_RES0, timer_res);
+
+	rc = qed_dmae_host2grc(p_hwfn, p_ptt,
+			       (u64)(uintptr_t)&sb_entry,
+			       CAU_REG_SB_VAR_MEMORY +
+			       sb_id * sizeof(u64), 2, 0);
+	if (rc) {
+		DP_ERR(p_hwfn, "dmae_host2grc failed %d\n", rc);
+		return rc;
+	}
+
+	return rc;
+}
diff --git a/drivers/net/ethernet/qlogic/qed/qed_int.h b/drivers/net/ethernet/qlogic/qed/qed_int.h
index 20b4686..0948be6 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_int.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_int.h
@@ -389,6 +389,9 @@ void qed_init_cau_sb_entry(struct qed_hwfn *p_hwfn,
 			   u16 vf_number,
 			   u8 vf_valid);
 
+int qed_int_set_timer_res(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt,
+			  u8 timer_res, u16 sb_id, bool tx);
+
 #define QED_MAPPING_MEMORY_SIZE(dev)	(NUM_OF_SBS(dev))
 
 #endif
diff --git a/drivers/net/ethernet/qlogic/qed/qed_main.c b/drivers/net/ethernet/qlogic/qed/qed_main.c
index 6c4606b..e32ee57 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_main.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_main.c
@@ -1303,6 +1303,38 @@ static int qed_drain(struct qed_dev *cdev)
 	return 0;
 }
 
+static void qed_get_coalesce(struct qed_dev *cdev, u16 *rx_coal, u16 *tx_coal)
+{
+	*rx_coal = cdev->rx_coalesce_usecs;
+	*tx_coal = cdev->tx_coalesce_usecs;
+}
+
+static int qed_set_coalesce(struct qed_dev *cdev, u16 rx_coal, u16 tx_coal,
+			    u8 qid, u16 sb_id)
+{
+	struct qed_hwfn *hwfn;
+	struct qed_ptt *ptt;
+	int hwfn_index;
+	int status = 0;
+
+	hwfn_index = qid % cdev->num_hwfns;
+	hwfn = &cdev->hwfns[hwfn_index];
+	ptt = qed_ptt_acquire(hwfn);
+	if (!ptt)
+		return -EAGAIN;
+
+	status = qed_set_rxq_coalesce(hwfn, ptt, rx_coal,
+				      qid / cdev->num_hwfns, sb_id);
+	if (status)
+		goto out;
+	status = qed_set_txq_coalesce(hwfn, ptt, tx_coal,
+				      qid / cdev->num_hwfns, sb_id);
+out:
+	qed_ptt_release(hwfn, ptt);
+
+	return status;
+}
+
 static int qed_set_led(struct qed_dev *cdev, enum qed_led_mode mode)
 {
 	struct qed_hwfn *hwfn = QED_LEADING_HWFN(cdev);
@@ -1349,5 +1381,7 @@ const struct qed_common_ops qed_common_ops_pass = {
 	.update_msglvl = &qed_init_dp,
 	.chain_alloc = &qed_chain_alloc,
 	.chain_free = &qed_chain_free,
+	.get_coalesce = &qed_get_coalesce,
+	.set_coalesce = &qed_set_coalesce,
 	.set_led = &qed_set_led,
 };
diff --git a/drivers/net/ethernet/qlogic/qed/qed_reg_addr.h b/drivers/net/ethernet/qlogic/qed/qed_reg_addr.h
index aa08ddb..f6b86ca 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_reg_addr.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_reg_addr.h
@@ -80,6 +80,8 @@
 	0x1f00000UL
 #define  BAR0_MAP_REG_TSDM_RAM \
 	0x1c80000UL
+#define BAR0_MAP_REG_XSDM_RAM \
+	0x1e00000UL
 #define  NIG_REG_RX_LLH_BRB_GATE_DNTFWD_PERPF \
 	0x5011f4UL
 #define  PRS_REG_SEARCH_TCP \
diff --git a/include/linux/qed/qed_if.h b/include/linux/qed/qed_if.h
index e1d5122..b1e3c57 100644
--- a/include/linux/qed/qed_if.h
+++ b/include/linux/qed/qed_if.h
@@ -489,6 +489,30 @@ struct qed_common_ops {
 				      struct qed_chain *p_chain);
 
 /**
+ * @brief get_coalesce - Get coalesce parameters in usec
+ *
+ * @param cdev
+ * @param rx_coal - Rx coalesce value in usec
+ * @param tx_coal - Tx coalesce value in usec
+ *
+ */
+	void (*get_coalesce)(struct qed_dev *cdev, u16 *rx_coal, u16 *tx_coal);
+
+/**
+ * @brief set_coalesce - Configure Rx coalesce value in usec
+ *
+ * @param cdev
+ * @param rx_coal - Rx coalesce value in usec
+ * @param tx_coal - Tx coalesce value in usec
+ * @param qid - Queue index
+ * @param sb_id - Status Block Id
+ *
+ * @return 0 on success, error otherwise.
+ */
+	int (*set_coalesce)(struct qed_dev *cdev, u16 rx_coal, u16 tx_coal,
+			    u8 qid, u16 sb_id);
+
+/**
  * @brief set_led - Configure LED mode
  *
  * @param cdev
-- 
1.8.3.1
