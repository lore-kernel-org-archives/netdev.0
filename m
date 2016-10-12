From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] qede: fix CONFIG_INFINIBAND_QEDR=m build error
Date: Wed, 12 Oct 2016 12:31:14 +0200
Message-ID: <20161012103340.978726-1-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>,
        Ariel Elior <Ariel.Elior@qlogic.com>,
        everest-linux-l2@qlogic.com,
        Manish Chopra <manish.chopra@qlogic.com>,
        Alexander Duyck <aduyck@mirantis.com>,
        Ram Amrani <Ram.Amrani@caviumnetworks.com>,
        Sudarsana Reddy Kalluru <Sudarsana.Kalluru@qlogic.com>,
        Tomer Tayar <Tomer.Tayar@qlogic.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Yuval Mintz <Yuval.Mintz@qlogic.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The newly introduced INFINIBAND_QEDR option is 'tristate' but
fails to build when set to 'm':

drivers/net/built-in.o: In function `qed_hw_init':
(.text+0x1c0e17): undefined reference to `qed_rdma_dpm_bar'
drivers/net/built-in.o: In function `qed_eq_completion':
(.text+0x1d185b): undefined reference to `qed_async_roce_event'
drivers/net/built-in.o: In function `qed_ll2_txq_completion':
qed_ll2.c:(.text+0x1e2fdd): undefined reference to `qed_ll2b_complete_tx_gsi_packet'
drivers/net/built-in.o: In function `qed_ll2_rxq_completion':
qed_ll2.c:(.text+0x1e479a): undefined reference to `qed_ll2b_complete_rx_gsi_packet'
drivers/net/built-in.o: In function `qed_ll2_terminate_connection':
(.text+0x1e5645): undefined reference to `qed_ll2b_release_tx_gsi_packet'

There are multiple problems here:

- The option should be 'bool', as this is not a separate module
  but rather a single file that gets added to the normal driver
  module

- The qed_rdma_dpm_bar() helper function should have been 'static
  inline' as it's declared in a header file, the current workaround
  of including qed_roce.h conditionally is not good

- There is no reason to use '#if' all the time to check for the
  symbol, it should use use 'if IS_ENABLED()' to make the code
  more readable and get better compile coverage.

This addresses all three of the above.

Fixes: cee9fbd8e2e9 ("qede: Add qedr framework")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/net/ethernet/qlogic/Kconfig        |  2 +-
 drivers/net/ethernet/qlogic/qed/qed_cxt.c  |  6 +-----
 drivers/net/ethernet/qlogic/qed/qed_dev.c  |  7 +++----
 drivers/net/ethernet/qlogic/qed/qed_main.c | 24 +++++++++++-------------
 drivers/net/ethernet/qlogic/qed/qed_roce.h |  4 ----
 drivers/net/ethernet/qlogic/qed/qed_spq.c  | 13 ++++++-------
 6 files changed, 22 insertions(+), 34 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/Kconfig b/drivers/net/ethernet/qlogic/Kconfig
index 0df1391f9663..90562cf8fa19 100644
--- a/drivers/net/ethernet/qlogic/Kconfig
+++ b/drivers/net/ethernet/qlogic/Kconfig
@@ -108,7 +108,7 @@ config QEDE
 	  This enables the support for ...
 
 config INFINIBAND_QEDR
-	tristate "QLogic qede RoCE sources [debug]"
+	bool "QLogic qede RoCE sources [debug]"
 	depends on QEDE && 64BIT
 	select QED_LL2
 	default n
diff --git a/drivers/net/ethernet/qlogic/qed/qed_cxt.c b/drivers/net/ethernet/qlogic/qed/qed_cxt.c
index 82370a1a59ad..0a3ffcd9f073 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_cxt.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_cxt.c
@@ -48,12 +48,8 @@
 #define TM_ELEM_SIZE    4
 
 /* ILT constants */
-#if IS_ENABLED(CONFIG_INFINIBAND_QEDR)
 /* For RoCE we configure to 64K to cover for RoCE max tasks 256K purpose. */
-#define ILT_DEFAULT_HW_P_SIZE		4
-#else
-#define ILT_DEFAULT_HW_P_SIZE		3
-#endif
+#define ILT_DEFAULT_HW_P_SIZE	IS_ENABLED(CONFIG_INFINIBAND_QEDR) ? 4 : 3
 
 #define ILT_PAGE_IN_BYTES(hw_p_size)	(1U << ((hw_p_size) + 12))
 #define ILT_CFG_REG(cli, reg)	PSWRQ2_REG_ ## cli ## _ ## reg ## _RT_OFFSET
diff --git a/drivers/net/ethernet/qlogic/qed/qed_dev.c b/drivers/net/ethernet/qlogic/qed/qed_dev.c
index 754f6a908858..63a38e3b8f3f 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_dev.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_dev.c
@@ -890,7 +890,7 @@ qed_hw_init_pf_doorbell_bar(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt)
 		n_cpus = 1;
 		rc = qed_hw_init_dpi_size(p_hwfn, p_ptt, pwm_regsize, n_cpus);
 
-		if (cond)
+		if (IS_ENABLED(CONFIG_INFINIBAND_QEDR) && cond)
 			qed_rdma_dpm_bar(p_hwfn, p_ptt);
 	}
 
@@ -1422,19 +1422,18 @@ static void qed_hw_set_feat(struct qed_hwfn *p_hwfn)
 	u32 *feat_num = p_hwfn->hw_info.feat_num;
 	int num_features = 1;
 
-#if IS_ENABLED(CONFIG_INFINIBAND_QEDR)
 	/* Roce CNQ each requires: 1 status block + 1 CNQ. We divide the
 	 * status blocks equally between L2 / RoCE but with consideration as
 	 * to how many l2 queues / cnqs we have
 	 */
-	if (p_hwfn->hw_info.personality == QED_PCI_ETH_ROCE) {
+	if (IS_ENABLED(CONFIG_INFINIBAND_QEDR) &&
+	    p_hwfn->hw_info.personality == QED_PCI_ETH_ROCE) {
 		num_features++;
 
 		feat_num[QED_RDMA_CNQ] =
 			min_t(u32, RESC_NUM(p_hwfn, QED_SB) / num_features,
 			      RESC_NUM(p_hwfn, QED_RDMA_CNQ_RAM));
 	}
-#endif
 	feat_num[QED_PF_L2_QUE] = min_t(u32, RESC_NUM(p_hwfn, QED_SB) /
 						num_features,
 					RESC_NUM(p_hwfn, QED_L2_QUEUE));
diff --git a/drivers/net/ethernet/qlogic/qed/qed_main.c b/drivers/net/ethernet/qlogic/qed/qed_main.c
index 4ee3151e80c2..36023a3583f2 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_main.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_main.c
@@ -33,10 +33,8 @@
 #include "qed_hw.h"
 #include "qed_selftest.h"
 
-#if IS_ENABLED(CONFIG_INFINIBAND_QEDR)
 #define QED_ROCE_QPS			(8192)
 #define QED_ROCE_DPIS			(8)
-#endif
 
 static char version[] =
 	"QLogic FastLinQ 4xxxx Core Module qed " DRV_MODULE_VERSION "\n";
@@ -682,9 +680,7 @@ static int qed_slowpath_setup_int(struct qed_dev *cdev,
 				  enum qed_int_mode int_mode)
 {
 	struct qed_sb_cnt_info sb_cnt_info;
-#if IS_ENABLED(CONFIG_INFINIBAND_QEDR)
 	int num_l2_queues;
-#endif
 	int rc;
 	int i;
 
@@ -715,7 +711,9 @@ static int qed_slowpath_setup_int(struct qed_dev *cdev,
 	cdev->int_params.fp_msix_cnt = cdev->int_params.out.num_vectors -
 				       cdev->num_hwfns;
 
-#if IS_ENABLED(CONFIG_INFINIBAND_QEDR)
+	if (!IS_ENABLED(CONFIG_INFINIBAND_QEDR))
+		return 0;
+
 	num_l2_queues = 0;
 	for_each_hwfn(cdev, i)
 		num_l2_queues += FEAT_NUM(&cdev->hwfns[i], QED_PF_L2_QUE);
@@ -738,7 +736,6 @@ static int qed_slowpath_setup_int(struct qed_dev *cdev,
 	DP_VERBOSE(cdev, QED_MSG_RDMA, "roce_msix_cnt=%d roce_msix_base=%d\n",
 		   cdev->int_params.rdma_msix_cnt,
 		   cdev->int_params.rdma_msix_base);
-#endif
 
 	return 0;
 }
@@ -843,13 +840,14 @@ static void qed_update_pf_params(struct qed_dev *cdev,
 {
 	int i;
 
-#if IS_ENABLED(CONFIG_INFINIBAND_QEDR)
-	params->rdma_pf_params.num_qps = QED_ROCE_QPS;
-	params->rdma_pf_params.min_dpis = QED_ROCE_DPIS;
-	/* divide by 3 the MRs to avoid MF ILT overflow */
-	params->rdma_pf_params.num_mrs = RDMA_MAX_TIDS;
-	params->rdma_pf_params.gl_pi = QED_ROCE_PROTOCOL_INDEX;
-#endif
+	if (IS_ENABLED(CONFIG_INFINIBAND_QEDR)) {
+		params->rdma_pf_params.num_qps = QED_ROCE_QPS;
+		params->rdma_pf_params.min_dpis = QED_ROCE_DPIS;
+		/* divide by 3 the MRs to avoid MF ILT overflow */
+		params->rdma_pf_params.num_mrs = RDMA_MAX_TIDS;
+		params->rdma_pf_params.gl_pi = QED_ROCE_PROTOCOL_INDEX;
+	}
+
 	for (i = 0; i < cdev->num_hwfns; i++) {
 		struct qed_hwfn *p_hwfn = &cdev->hwfns[i];
 
diff --git a/drivers/net/ethernet/qlogic/qed/qed_roce.h b/drivers/net/ethernet/qlogic/qed/qed_roce.h
index 2f091e8a0f40..c59baaca6f3d 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_roce.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_roce.h
@@ -208,9 +208,5 @@ int qed_rdma_modify_qp(void *rdma_cxt, struct qed_rdma_qp *qp,
 int qed_rdma_query_qp(void *rdma_cxt, struct qed_rdma_qp *qp,
 		      struct qed_rdma_query_qp_out_params *out_params);
 
-#if IS_ENABLED(CONFIG_INFINIBAND_QEDR)
 void qed_rdma_dpm_bar(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt);
-#else
-void qed_rdma_dpm_bar(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt) {}
-#endif
 #endif
diff --git a/drivers/net/ethernet/qlogic/qed/qed_spq.c b/drivers/net/ethernet/qlogic/qed/qed_spq.c
index caff41544898..c68d1bca2fc6 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_spq.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_spq.c
@@ -28,9 +28,7 @@
 #include "qed_reg_addr.h"
 #include "qed_sp.h"
 #include "qed_sriov.h"
-#if IS_ENABLED(CONFIG_INFINIBAND_QEDR)
 #include "qed_roce.h"
-#endif
 
 /***************************************************************************
 * Structures & Definitions
@@ -240,15 +238,16 @@ qed_async_event_completion(struct qed_hwfn *p_hwfn,
 			   struct event_ring_entry *p_eqe)
 {
 	switch (p_eqe->protocol_id) {
-#if IS_ENABLED(CONFIG_INFINIBAND_QEDR)
-	case PROTOCOLID_ROCE:
-		qed_async_roce_event(p_hwfn, p_eqe);
-		return 0;
-#endif
 	case PROTOCOLID_COMMON:
 		return qed_sriov_eqe_event(p_hwfn,
 					   p_eqe->opcode,
 					   p_eqe->echo, &p_eqe->data);
+	case PROTOCOLID_ROCE:
+		if (IS_ENABLED(CONFIG_INFINIBAND_QEDR)) {
+			qed_async_roce_event(p_hwfn, p_eqe);
+			return 0;
+		}
+		/* fallthrough */
 	default:
 		DP_NOTICE(p_hwfn,
 			  "Unknown Async completion for protocol: %d\n",
-- 
2.9.0
