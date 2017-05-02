From: Sudarsana Reddy Kalluru <sudarsana.kalluru@cavium.com>
Subject: [PATCH net 2/2] qed*: Fix issues in the ptp filter config implementation.
Date: Tue, 2 May 2017 01:11:03 -0700
Message-ID: <20170502081103.4252-3-sudarsana.kalluru@cavium.com>
References: <20170502081103.4252-1-sudarsana.kalluru@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <richardcochran@gmail.com>, <netdev@vger.kernel.org>,
        <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-dm3nam03on0041.outbound.protection.outlook.com ([104.47.41.41]:15649
        "EHLO NAM03-DM3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750751AbdEBILe (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 2 May 2017 04:11:34 -0400
In-Reply-To: <20170502081103.4252-1-sudarsana.kalluru@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PTP hardware filter configuration performed by the driver for a given
user requested config is not correct for some of the PTP modes.
Following changes are needed for PTP config-filter implementation.
 1. NIG_REG_TX_PTP_EN register - Bits 0/1/2 respectively enables
    TimeSync/"V1 frame format support"/"V2 frame format support" on
    the TX side. Set the associated bits based on the user request.
 2. ptp4l application fails to operate in Peer Delay mode. Following
    changes are needed to fix this,
    a. Driver should enable (set to 0) DA #1-related bits for IPv4,
       IPv6 and MAC destination addresses in these registers:
         NIG_REG_TX_LLH_PTP_RULE_MASK
         NIG_REG_LLH_PTP_RULE_MASK
    b. NIG_REG_LLH_PTP_PARAM_MASK/NIG_REG_TX_LLH_PTP_PARAM_MASK should
       be set to 0x0 in all modes.

Signed-off-by: Sudarsana Reddy Kalluru <Sudarsana.Kalluru@cavium.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qed/qed_ptp.c   | 84 ++++++++++++++++++-----------
 drivers/net/ethernet/qlogic/qede/qede_ptp.c | 34 +++++++++---
 include/linux/qed/qed_eth_if.h              | 23 +++++---
 3 files changed, 98 insertions(+), 43 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_ptp.c b/drivers/net/ethernet/qlogic/qed/qed_ptp.c
index d27aa85..f4e5c04 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_ptp.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_ptp.c
@@ -112,39 +112,73 @@ static int qed_ptp_hw_read_cc(struct qed_dev *cdev, u64 *phc_cycles)
 }
 
 /* Filter PTP protocol packets that need to be timestamped */
-static int qed_ptp_hw_cfg_rx_filters(struct qed_dev *cdev,
-				     enum qed_ptp_filter_type type)
+static int qed_ptp_hw_cfg_filters(struct qed_dev *cdev,
+				  enum qed_ptp_filter_type rx_type,
+				  enum qed_ptp_hwtstamp_tx_type tx_type)
 {
 	struct qed_hwfn *p_hwfn = QED_LEADING_HWFN(cdev);
 	struct qed_ptt *p_ptt = p_hwfn->p_ptp_ptt;
-	u32 rule_mask, parm_mask;
+	u32 rule_mask, enable_cfg = 0x0;
 
-	switch (type) {
-	case QED_PTP_FILTER_L2_IPV4_IPV6:
-		parm_mask = 0x6AA;
-		rule_mask = 0x3EEE;
+	switch (rx_type) {
+	case QED_PTP_FILTER_NONE:
+		enable_cfg = 0x0;
+		rule_mask = 0x3FFF;
 		break;
-	case QED_PTP_FILTER_L2:
-		parm_mask = 0x6BF;
-		rule_mask = 0x3EFF;
+	case QED_PTP_FILTER_ALL:
+		enable_cfg = 0x7;
+		rule_mask = 0x3CAA;
 		break;
-	case QED_PTP_FILTER_IPV4_IPV6:
-		parm_mask = 0x7EA;
-		rule_mask = 0x3FFE;
+	case QED_PTP_FILTER_V1_L4_EVENT:
+		enable_cfg = 0x3;
+		rule_mask = 0x3FFA;
 		break;
-	case QED_PTP_FILTER_IPV4:
-		parm_mask = 0x7EE;
+	case QED_PTP_FILTER_V1_L4_GEN:
+		enable_cfg = 0x3;
 		rule_mask = 0x3FFE;
 		break;
+	case QED_PTP_FILTER_V2_L4_EVENT:
+		enable_cfg = 0x5;
+		rule_mask = 0x3FAA;
+		break;
+	case QED_PTP_FILTER_V2_L4_GEN:
+		enable_cfg = 0x5;
+		rule_mask = 0x3FEE;
+		break;
+	case QED_PTP_FILTER_V2_L2_EVENT:
+		enable_cfg = 0x5;
+		rule_mask = 0x3CFF;
+		break;
+	case QED_PTP_FILTER_V2_L2_GEN:
+		enable_cfg = 0x5;
+		rule_mask = 0x3EFF;
+		break;
+	case QED_PTP_FILTER_V2_EVENT:
+		enable_cfg = 0x5;
+		rule_mask = 0x3CAA;
+		break;
+	case QED_PTP_FILTER_V2_GEN:
+		enable_cfg = 0x5;
+		rule_mask = 0x3EEE;
+		break;
 	default:
-		DP_INFO(p_hwfn, "Invalid PTP filter type %d\n", type);
+		DP_INFO(p_hwfn, "Invalid PTP filter type %d\n", rx_type);
 		return -EINVAL;
 	}
 
-	qed_wr(p_hwfn, p_ptt, NIG_REG_LLH_PTP_PARAM_MASK, parm_mask);
+	qed_wr(p_hwfn, p_ptt, NIG_REG_LLH_PTP_PARAM_MASK, 0);
 	qed_wr(p_hwfn, p_ptt, NIG_REG_LLH_PTP_RULE_MASK, rule_mask);
+	qed_wr(p_hwfn, p_ptt, NIG_REG_RX_PTP_EN, enable_cfg);
 
-	qed_wr(p_hwfn, p_ptt, NIG_REG_LLH_PTP_TO_HOST, 0x1);
+	if (tx_type == QED_PTP_HWTSTAMP_TX_OFF) {
+		qed_wr(p_hwfn, p_ptt, NIG_REG_TX_PTP_EN, 0x0);
+		qed_wr(p_hwfn, p_ptt, NIG_REG_TX_LLH_PTP_PARAM_MASK, 0x7FF);
+		qed_wr(p_hwfn, p_ptt, NIG_REG_TX_LLH_PTP_RULE_MASK, 0x3FFF);
+	} else {
+		qed_wr(p_hwfn, p_ptt, NIG_REG_TX_PTP_EN, enable_cfg);
+		qed_wr(p_hwfn, p_ptt, NIG_REG_TX_LLH_PTP_PARAM_MASK, 0);
+		qed_wr(p_hwfn, p_ptt, NIG_REG_TX_LLH_PTP_RULE_MASK, rule_mask);
+	}
 
 	/* Reset possibly old timestamps */
 	qed_wr(p_hwfn, p_ptt, NIG_REG_LLH_PTP_HOST_BUF_SEQID,
@@ -281,17 +315,6 @@ static int qed_ptp_hw_enable(struct qed_dev *cdev)
 	return 0;
 }
 
-static int qed_ptp_hw_hwtstamp_tx_on(struct qed_dev *cdev)
-{
-	struct qed_hwfn *p_hwfn = QED_LEADING_HWFN(cdev);
-	struct qed_ptt *p_ptt = p_hwfn->p_ptp_ptt;
-
-	qed_wr(p_hwfn, p_ptt, NIG_REG_TX_LLH_PTP_PARAM_MASK, 0x6AA);
-	qed_wr(p_hwfn, p_ptt, NIG_REG_TX_LLH_PTP_RULE_MASK, 0x3EEE);
-
-	return 0;
-}
-
 static int qed_ptp_hw_disable(struct qed_dev *cdev)
 {
 	struct qed_hwfn *p_hwfn = QED_LEADING_HWFN(cdev);
@@ -312,8 +335,7 @@ static int qed_ptp_hw_disable(struct qed_dev *cdev)
 }
 
 const struct qed_eth_ptp_ops qed_ptp_ops_pass = {
-	.hwtstamp_tx_on = qed_ptp_hw_hwtstamp_tx_on,
-	.cfg_rx_filters = qed_ptp_hw_cfg_rx_filters,
+	.cfg_filters = qed_ptp_hw_cfg_filters,
 	.read_rx_ts = qed_ptp_hw_read_rx_ts,
 	.read_tx_ts = qed_ptp_hw_read_tx_ts,
 	.read_cc = qed_ptp_hw_read_cc,
diff --git a/drivers/net/ethernet/qlogic/qede/qede_ptp.c b/drivers/net/ethernet/qlogic/qede/qede_ptp.c
index f5f743f..26aaf63 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_ptp.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_ptp.c
@@ -224,6 +224,8 @@ static void qede_ptp_init_cc(struct qede_dev *edev)
 
 static int qede_ptp_cfg_filters(struct qede_dev *edev)
 {
+	enum qed_ptp_hwtstamp_tx_type tx_type = QED_PTP_HWTSTAMP_TX_ON;
+	enum qed_ptp_filter_type rx_filter = QED_PTP_FILTER_NONE;
 	struct qede_ptp *ptp = edev->ptp;
 
 	if (!ptp)
@@ -237,7 +239,12 @@ static int qede_ptp_cfg_filters(struct qede_dev *edev)
 	switch (ptp->tx_type) {
 	case HWTSTAMP_TX_ON:
 		edev->flags |= QEDE_TX_TIMESTAMPING_EN;
-		ptp->ops->hwtstamp_tx_on(edev->cdev);
+		tx_type = QED_PTP_HWTSTAMP_TX_ON;
+		break;
+
+	case HWTSTAMP_TX_OFF:
+		edev->flags &= ~QEDE_TX_TIMESTAMPING_EN;
+		tx_type = QED_PTP_HWTSTAMP_TX_OFF;
 		break;
 
 	case HWTSTAMP_TX_ONESTEP_SYNC:
@@ -248,42 +255,57 @@ static int qede_ptp_cfg_filters(struct qede_dev *edev)
 	spin_lock_bh(&ptp->lock);
 	switch (ptp->rx_filter) {
 	case HWTSTAMP_FILTER_NONE:
+		rx_filter = QED_PTP_FILTER_NONE;
 		break;
 	case HWTSTAMP_FILTER_ALL:
 	case HWTSTAMP_FILTER_SOME:
 		ptp->rx_filter = HWTSTAMP_FILTER_NONE;
+		rx_filter = QED_PTP_FILTER_ALL;
 		break;
 	case HWTSTAMP_FILTER_PTP_V1_L4_EVENT:
+		ptp->rx_filter = HWTSTAMP_FILTER_PTP_V1_L4_EVENT;
+		rx_filter = QED_PTP_FILTER_V1_L4_EVENT;
+		break;
 	case HWTSTAMP_FILTER_PTP_V1_L4_SYNC:
 	case HWTSTAMP_FILTER_PTP_V1_L4_DELAY_REQ:
 		ptp->rx_filter = HWTSTAMP_FILTER_PTP_V1_L4_EVENT;
 		/* Initialize PTP detection for UDP/IPv4 events */
-		ptp->ops->cfg_rx_filters(edev->cdev, QED_PTP_FILTER_IPV4);
+		rx_filter = QED_PTP_FILTER_V1_L4_GEN;
 		break;
 	case HWTSTAMP_FILTER_PTP_V2_L4_EVENT:
+		ptp->rx_filter = HWTSTAMP_FILTER_PTP_V2_L4_EVENT;
+		rx_filter = QED_PTP_FILTER_V2_L4_EVENT;
+		break;
 	case HWTSTAMP_FILTER_PTP_V2_L4_SYNC:
 	case HWTSTAMP_FILTER_PTP_V2_L4_DELAY_REQ:
 		ptp->rx_filter = HWTSTAMP_FILTER_PTP_V2_L4_EVENT;
 		/* Initialize PTP detection for UDP/IPv4 or UDP/IPv6 events */
-		ptp->ops->cfg_rx_filters(edev->cdev, QED_PTP_FILTER_IPV4_IPV6);
+		rx_filter = QED_PTP_FILTER_V2_L4_GEN;
 		break;
 	case HWTSTAMP_FILTER_PTP_V2_L2_EVENT:
+		ptp->rx_filter = HWTSTAMP_FILTER_PTP_V2_L2_EVENT;
+		rx_filter = QED_PTP_FILTER_V2_L2_EVENT;
+		break;
 	case HWTSTAMP_FILTER_PTP_V2_L2_SYNC:
 	case HWTSTAMP_FILTER_PTP_V2_L2_DELAY_REQ:
 		ptp->rx_filter = HWTSTAMP_FILTER_PTP_V2_L2_EVENT;
 		/* Initialize PTP detection L2 events */
-		ptp->ops->cfg_rx_filters(edev->cdev, QED_PTP_FILTER_L2);
+		rx_filter = QED_PTP_FILTER_V2_L2_GEN;
 		break;
 	case HWTSTAMP_FILTER_PTP_V2_EVENT:
+		ptp->rx_filter = HWTSTAMP_FILTER_PTP_V2_EVENT;
+		rx_filter = QED_PTP_FILTER_V2_EVENT;
+		break;
 	case HWTSTAMP_FILTER_PTP_V2_SYNC:
 	case HWTSTAMP_FILTER_PTP_V2_DELAY_REQ:
 		ptp->rx_filter = HWTSTAMP_FILTER_PTP_V2_EVENT;
 		/* Initialize PTP detection L2, UDP/IPv4 or UDP/IPv6 events */
-		ptp->ops->cfg_rx_filters(edev->cdev,
-					 QED_PTP_FILTER_L2_IPV4_IPV6);
+		rx_filter = QED_PTP_FILTER_V2_GEN;
 		break;
 	}
 
+	ptp->ops->cfg_filters(edev->cdev, rx_filter, tx_type);
+
 	spin_unlock_bh(&ptp->lock);
 
 	return 0;
diff --git a/include/linux/qed/qed_eth_if.h b/include/linux/qed/qed_eth_if.h
index 4cd1f0c..65f6271 100644
--- a/include/linux/qed/qed_eth_if.h
+++ b/include/linux/qed/qed_eth_if.h
@@ -163,10 +163,21 @@ struct qed_eth_cb_ops {
 #define QED_MAX_PHC_DRIFT_PPB   291666666
 
 enum qed_ptp_filter_type {
-	QED_PTP_FILTER_L2,
-	QED_PTP_FILTER_IPV4,
-	QED_PTP_FILTER_IPV4_IPV6,
-	QED_PTP_FILTER_L2_IPV4_IPV6
+	QED_PTP_FILTER_NONE,
+	QED_PTP_FILTER_ALL,
+	QED_PTP_FILTER_V1_L4_EVENT,
+	QED_PTP_FILTER_V1_L4_GEN,
+	QED_PTP_FILTER_V2_L4_EVENT,
+	QED_PTP_FILTER_V2_L4_GEN,
+	QED_PTP_FILTER_V2_L2_EVENT,
+	QED_PTP_FILTER_V2_L2_GEN,
+	QED_PTP_FILTER_V2_EVENT,
+	QED_PTP_FILTER_V2_GEN
+};
+
+enum qed_ptp_hwtstamp_tx_type {
+	QED_PTP_HWTSTAMP_TX_OFF,
+	QED_PTP_HWTSTAMP_TX_ON,
 };
 
 #ifdef CONFIG_DCB
@@ -229,8 +240,8 @@ struct qed_eth_dcbnl_ops {
 #endif
 
 struct qed_eth_ptp_ops {
-	int (*hwtstamp_tx_on)(struct qed_dev *);
-	int (*cfg_rx_filters)(struct qed_dev *, enum qed_ptp_filter_type);
+	int (*cfg_filters)(struct qed_dev *, enum qed_ptp_filter_type,
+			   enum qed_ptp_hwtstamp_tx_type);
 	int (*read_rx_ts)(struct qed_dev *, u64 *);
 	int (*read_tx_ts)(struct qed_dev *, u64 *);
 	int (*read_cc)(struct qed_dev *, u64 *);
-- 
1.8.3.1
