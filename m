From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next v8 02/10] qed: Add basic L2 interface
Date: Mon, 26 Oct 2015 11:02:26 +0200
Message-ID: <1445850154-19322-3-git-send-email-Yuval.Mintz@qlogic.com>
References: <1445850154-19322-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Ariel.Elior@qlogic.com>, Yuval Mintz <Yuval.Mintz@qlogic.com>,
	Manish Chopra <Manish.Chopra@qlogic.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:2042 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750932AbbJZJDS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Oct 2015 05:03:18 -0400
Received: from pps.filterd (m0045602.ppops.net [127.0.0.1])
	by mx0a-0016ce01.pphosted.com (8.15.0.59/8.15.0.59) with SMTP id t9Q8u2Fa004825
	for <netdev@vger.kernel.org>; Mon, 26 Oct 2015 02:03:18 -0700
Received: from avcashub1.qlogic.com (avcashub2.qlogic.com [198.70.193.116])
	by mx0a-0016ce01.pphosted.com with ESMTP id 1xr94wt1wx-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 26 Oct 2015 02:03:17 -0700
In-Reply-To: <1445850154-19322-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds a public API for a network driver to work on top of QED.
The interface itself is very minimal - it's mostly infrastructure, as the
only content it has after this patch is a query for HW-based information
required for the creation of a network interface [I.e., no actual
protocol-specific configurations are supported].

Signed-off-by: Manish Chopra <Manish.Chopra@qlogic.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
Signed-off-by: Ariel Elior <Ariel.Elior@qlogic.com>
---
 drivers/net/ethernet/qlogic/qed/Makefile  |   2 +-
 drivers/net/ethernet/qlogic/qed/qed.h     |  14 ++
 drivers/net/ethernet/qlogic/qed/qed_dev.c |  62 +++++++
 drivers/net/ethernet/qlogic/qed/qed_hsi.h |   1 +
 drivers/net/ethernet/qlogic/qed/qed_l2.c  |  87 ++++++++++
 include/linux/qed/eth_common.h            | 279 ++++++++++++++++++++++++++++++
 include/linux/qed/qed_eth_if.h            |  38 ++++
 7 files changed, 482 insertions(+), 1 deletion(-)
 create mode 100644 drivers/net/ethernet/qlogic/qed/qed_l2.c
 create mode 100644 include/linux/qed/eth_common.h
 create mode 100644 include/linux/qed/qed_eth_if.h

diff --git a/drivers/net/ethernet/qlogic/qed/Makefile b/drivers/net/ethernet/qlogic/qed/Makefile
index 6969b5c..5c2fd57 100644
--- a/drivers/net/ethernet/qlogic/qed/Makefile
+++ b/drivers/net/ethernet/qlogic/qed/Makefile
@@ -1,4 +1,4 @@
 obj-$(CONFIG_QED) := qed.o
 
 qed-y := qed_cxt.o qed_dev.o qed_hw.o qed_init_fw_funcs.o qed_init_ops.o \
-	 qed_int.o qed_main.o qed_mcp.o qed_sp_commands.o qed_spq.o
+	 qed_int.o qed_main.o qed_mcp.o qed_sp_commands.o qed_spq.o qed_l2.o
diff --git a/drivers/net/ethernet/qlogic/qed/qed.h b/drivers/net/ethernet/qlogic/qed/qed.h
index a63ef31..e03371d 100644
--- a/drivers/net/ethernet/qlogic/qed/qed.h
+++ b/drivers/net/ethernet/qlogic/qed/qed.h
@@ -25,6 +25,7 @@
 #include <linux/qed/qed_if.h>
 #include "qed_hsi.h"
 
+extern const struct qed_common_ops qed_common_ops_pass;
 #define DRV_MODULE_VERSION "8.4.0.0"
 
 #define MAX_HWFNS_PER_DEVICE    (4)
@@ -91,13 +92,22 @@ struct qed_qm_iids {
 
 enum QED_RESOURCES {
 	QED_SB,
+	QED_L2_QUEUE,
 	QED_VPORT,
+	QED_RSS_ENG,
 	QED_PQ,
 	QED_RL,
+	QED_MAC,
+	QED_VLAN,
 	QED_ILT,
 	QED_MAX_RESC,
 };
 
+enum QED_FEATURE {
+	QED_PF_L2_QUE,
+	QED_MAX_FEATURES,
+};
+
 struct qed_hw_info {
 	/* PCI personality */
 	enum qed_pci_personality	personality;
@@ -105,6 +115,7 @@ struct qed_hw_info {
 	/* Resource Allocation scheme results */
 	u32				resc_start[QED_MAX_RESC];
 	u32				resc_num[QED_MAX_RESC];
+	u32				feat_num[QED_MAX_FEATURES];
 
 #define RESC_START(_p_hwfn, resc) ((_p_hwfn)->hw_info.resc_start[resc])
 #define RESC_NUM(_p_hwfn, resc) ((_p_hwfn)->hw_info.resc_num[resc])
@@ -266,6 +277,9 @@ struct qed_hwfn {
 
 	struct qed_mcp_info		*mcp_info;
 
+	struct qed_hw_cid_data		*p_tx_cids;
+	struct qed_hw_cid_data		*p_rx_cids;
+
 	struct qed_dmae_info		dmae_info;
 
 	/* QM init */
diff --git a/drivers/net/ethernet/qlogic/qed/qed_dev.c b/drivers/net/ethernet/qlogic/qed/qed_dev.c
index 5b84522..3243cb4 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_dev.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_dev.c
@@ -92,6 +92,15 @@ void qed_resc_free(struct qed_dev *cdev)
 	for_each_hwfn(cdev, i) {
 		struct qed_hwfn *p_hwfn = &cdev->hwfns[i];
 
+		kfree(p_hwfn->p_tx_cids);
+		p_hwfn->p_tx_cids = NULL;
+		kfree(p_hwfn->p_rx_cids);
+		p_hwfn->p_rx_cids = NULL;
+	}
+
+	for_each_hwfn(cdev, i) {
+		struct qed_hwfn *p_hwfn = &cdev->hwfns[i];
+
 		qed_cxt_mngr_free(p_hwfn);
 		qed_qm_info_free(p_hwfn);
 		qed_spq_free(p_hwfn);
@@ -202,6 +211,29 @@ int qed_resc_alloc(struct qed_dev *cdev)
 	if (!cdev->fw_data)
 		return -ENOMEM;
 
+	/* Allocate Memory for the Queue->CID mapping */
+	for_each_hwfn(cdev, i) {
+		struct qed_hwfn *p_hwfn = &cdev->hwfns[i];
+		int tx_size = sizeof(struct qed_hw_cid_data) *
+				     RESC_NUM(p_hwfn, QED_L2_QUEUE);
+		int rx_size = sizeof(struct qed_hw_cid_data) *
+				     RESC_NUM(p_hwfn, QED_L2_QUEUE);
+
+		p_hwfn->p_tx_cids = kzalloc(tx_size, GFP_KERNEL);
+		if (!p_hwfn->p_tx_cids) {
+			DP_NOTICE(p_hwfn,
+				  "Failed to allocate memory for Tx Cids\n");
+			goto alloc_err;
+		}
+
+		p_hwfn->p_rx_cids = kzalloc(rx_size, GFP_KERNEL);
+		if (!p_hwfn->p_rx_cids) {
+			DP_NOTICE(p_hwfn,
+				  "Failed to allocate memory for Rx Cids\n");
+			goto alloc_err;
+		}
+	}
+
 	for_each_hwfn(cdev, i) {
 		struct qed_hwfn *p_hwfn = &cdev->hwfns[i];
 
@@ -881,6 +913,20 @@ static void get_function_id(struct qed_hwfn *p_hwfn)
 				    PXP_CONCRETE_FID_PORT);
 }
 
+static void qed_hw_set_feat(struct qed_hwfn *p_hwfn)
+{
+	u32 *feat_num = p_hwfn->hw_info.feat_num;
+	int num_features = 1;
+
+	feat_num[QED_PF_L2_QUE] = min_t(u32, RESC_NUM(p_hwfn, QED_SB) /
+						num_features,
+					RESC_NUM(p_hwfn, QED_L2_QUEUE));
+	DP_VERBOSE(p_hwfn, NETIF_MSG_PROBE,
+		   "#PF_L2_QUEUES=%d #SBS=%d num_features=%d\n",
+		   feat_num[QED_PF_L2_QUE], RESC_NUM(p_hwfn, QED_SB),
+		   num_features);
+}
+
 static void qed_hw_get_resc(struct qed_hwfn *p_hwfn)
 {
 	u32 *resc_start = p_hwfn->hw_info.resc_start;
@@ -893,29 +939,45 @@ static void qed_hw_get_resc(struct qed_hwfn *p_hwfn)
 	resc_num[QED_SB] = min_t(u32,
 				 (MAX_SB_PER_PATH_BB / num_funcs),
 				 qed_int_get_num_sbs(p_hwfn, NULL));
+	resc_num[QED_L2_QUEUE] = MAX_NUM_L2_QUEUES_BB / num_funcs;
 	resc_num[QED_VPORT] = MAX_NUM_VPORTS_BB / num_funcs;
+	resc_num[QED_RSS_ENG] = ETH_RSS_ENGINE_NUM_BB / num_funcs;
 	resc_num[QED_PQ] = MAX_QM_TX_QUEUES_BB / num_funcs;
 	resc_num[QED_RL] = 8;
+	resc_num[QED_MAC] = ETH_NUM_MAC_FILTERS / num_funcs;
+	resc_num[QED_VLAN] = (ETH_NUM_VLAN_FILTERS - 1 /*For vlan0*/) /
+			     num_funcs;
 	resc_num[QED_ILT] = 950;
 
 	for (i = 0; i < QED_MAX_RESC; i++)
 		resc_start[i] = resc_num[i] * p_hwfn->rel_pf_id;
 
+	qed_hw_set_feat(p_hwfn);
+
 	DP_VERBOSE(p_hwfn, NETIF_MSG_PROBE,
 		   "The numbers for each resource are:\n"
 		   "SB = %d start = %d\n"
+		   "L2_QUEUE = %d start = %d\n"
 		   "VPORT = %d start = %d\n"
 		   "PQ = %d start = %d\n"
 		   "RL = %d start = %d\n"
+		   "MAC = %d start = %d\n"
+		   "VLAN = %d start = %d\n"
 		   "ILT = %d start = %d\n",
 		   p_hwfn->hw_info.resc_num[QED_SB],
 		   p_hwfn->hw_info.resc_start[QED_SB],
+		   p_hwfn->hw_info.resc_num[QED_L2_QUEUE],
+		   p_hwfn->hw_info.resc_start[QED_L2_QUEUE],
 		   p_hwfn->hw_info.resc_num[QED_VPORT],
 		   p_hwfn->hw_info.resc_start[QED_VPORT],
 		   p_hwfn->hw_info.resc_num[QED_PQ],
 		   p_hwfn->hw_info.resc_start[QED_PQ],
 		   p_hwfn->hw_info.resc_num[QED_RL],
 		   p_hwfn->hw_info.resc_start[QED_RL],
+		   p_hwfn->hw_info.resc_num[QED_MAC],
+		   p_hwfn->hw_info.resc_start[QED_MAC],
+		   p_hwfn->hw_info.resc_num[QED_VLAN],
+		   p_hwfn->hw_info.resc_start[QED_VLAN],
 		   p_hwfn->hw_info.resc_num[QED_ILT],
 		   p_hwfn->hw_info.resc_start[QED_ILT]);
 }
diff --git a/drivers/net/ethernet/qlogic/qed/qed_hsi.h b/drivers/net/ethernet/qlogic/qed/qed_hsi.h
index 61c15a5..27f2c00 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_hsi.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_hsi.h
@@ -17,6 +17,7 @@
 #include <linux/list.h>
 #include <linux/slab.h>
 #include <linux/qed/common_hsi.h>
+#include <linux/qed/eth_common.h>
 
 struct qed_hwfn;
 struct qed_ptt;
diff --git a/drivers/net/ethernet/qlogic/qed/qed_l2.c b/drivers/net/ethernet/qlogic/qed/qed_l2.c
new file mode 100644
index 0000000..f2e7602
--- /dev/null
+++ b/drivers/net/ethernet/qlogic/qed/qed_l2.c
@@ -0,0 +1,87 @@
+/* QLogic qed NIC Driver
+ * Copyright (c) 2015 QLogic Corporation
+ *
+ * This software is available under the terms of the GNU General Public License
+ * (GPL) Version 2, available from the file COPYING in the main directory of
+ * this source tree.
+ */
+
+#include <linux/types.h>
+#include <asm/byteorder.h>
+#include <asm/param.h>
+#include <linux/delay.h>
+#include <linux/dma-mapping.h>
+#include <linux/etherdevice.h>
+#include <linux/interrupt.h>
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/pci.h>
+#include <linux/slab.h>
+#include <linux/stddef.h>
+#include <linux/string.h>
+#include <linux/version.h>
+#include <linux/workqueue.h>
+#include <linux/bitops.h>
+#include <linux/bug.h>
+#include "qed.h"
+#include <linux/qed/qed_chain.h>
+#include "qed_cxt.h"
+#include "qed_dev_api.h"
+#include <linux/qed/qed_eth_if.h>
+#include "qed_hsi.h"
+#include "qed_hw.h"
+#include "qed_int.h"
+#include "qed_reg_addr.h"
+#include "qed_sp.h"
+
+static int qed_fill_eth_dev_info(struct qed_dev *cdev,
+				 struct qed_dev_eth_info *info)
+{
+	int i;
+
+	memset(info, 0, sizeof(*info));
+
+	info->num_tc = 1;
+
+	if (cdev->int_params.out.int_mode == QED_INT_MODE_MSIX) {
+		for_each_hwfn(cdev, i)
+			info->num_queues += FEAT_NUM(&cdev->hwfns[i],
+						     QED_PF_L2_QUE);
+		if (cdev->int_params.fp_msix_cnt)
+			info->num_queues = min_t(u8, info->num_queues,
+						 cdev->int_params.fp_msix_cnt);
+	} else {
+		info->num_queues = cdev->num_hwfns;
+	}
+
+	info->num_vlan_filters = RESC_NUM(&cdev->hwfns[0], QED_VLAN);
+	ether_addr_copy(info->port_mac,
+			cdev->hwfns[0].hw_info.hw_mac_addr);
+
+	qed_fill_dev_info(cdev, &info->common);
+
+	return 0;
+}
+
+static const struct qed_eth_ops qed_eth_ops_pass = {
+	.common = &qed_common_ops_pass,
+	.fill_dev_info = &qed_fill_eth_dev_info,
+};
+
+const struct qed_eth_ops *qed_get_eth_ops(u32 version)
+{
+	if (version != QED_ETH_INTERFACE_VERSION) {
+		pr_notice("Cannot supply ethtool operations [%08x != %08x]\n",
+			  version, QED_ETH_INTERFACE_VERSION);
+		return NULL;
+	}
+
+	return &qed_eth_ops_pass;
+}
+EXPORT_SYMBOL(qed_get_eth_ops);
+
+void qed_put_eth_ops(void)
+{
+	/* TODO - reference count for module? */
+}
+EXPORT_SYMBOL(qed_put_eth_ops);
diff --git a/include/linux/qed/eth_common.h b/include/linux/qed/eth_common.h
new file mode 100644
index 0000000..320b337
--- /dev/null
+++ b/include/linux/qed/eth_common.h
@@ -0,0 +1,279 @@
+/* QLogic qed NIC Driver
+ * Copyright (c) 2015 QLogic Corporation
+ *
+ * This software is available under the terms of the GNU General Public License
+ * (GPL) Version 2, available from the file COPYING in the main directory of
+ * this source tree.
+ */
+
+#ifndef __ETH_COMMON__
+#define __ETH_COMMON__
+
+/********************/
+/* ETH FW CONSTANTS */
+/********************/
+#define ETH_CACHE_LINE_SIZE                 64
+
+#define ETH_MAX_RAMROD_PER_CON                          8
+#define ETH_TX_BD_PAGE_SIZE_BYTES                       4096
+#define ETH_RX_BD_PAGE_SIZE_BYTES                       4096
+#define ETH_RX_SGE_PAGE_SIZE_BYTES                      4096
+#define ETH_RX_CQE_PAGE_SIZE_BYTES                      4096
+#define ETH_RX_NUM_NEXT_PAGE_BDS                        2
+#define ETH_RX_NUM_NEXT_PAGE_SGES                       2
+
+#define ETH_TX_MIN_BDS_PER_NON_LSO_PKT                          1
+#define ETH_TX_MAX_BDS_PER_NON_LSO_PACKET                       18
+#define ETH_TX_MAX_LSO_HDR_NBD                                          4
+#define ETH_TX_MIN_BDS_PER_LSO_PKT                                      3
+#define ETH_TX_MIN_BDS_PER_TUNN_IPV6_WITH_EXT_PKT       3
+#define ETH_TX_MIN_BDS_PER_IPV6_WITH_EXT_PKT            2
+#define ETH_TX_MIN_BDS_PER_PKT_W_LOOPBACK_MODE          2
+#define ETH_TX_MAX_NON_LSO_PKT_LEN                  (9700 - (4 + 12 + 8))
+#define ETH_TX_MAX_LSO_HDR_BYTES                    510
+
+#define ETH_NUM_STATISTIC_COUNTERS                      MAX_NUM_VPORTS
+
+#define ETH_REG_CQE_PBL_SIZE                3
+
+/* num of MAC/VLAN filters */
+#define ETH_NUM_MAC_FILTERS                                     512
+#define ETH_NUM_VLAN_FILTERS                            512
+
+/* approx. multicast constants */
+#define ETH_MULTICAST_BIN_FROM_MAC_SEED     0
+#define ETH_MULTICAST_MAC_BINS                          256
+#define ETH_MULTICAST_MAC_BINS_IN_REGS          (ETH_MULTICAST_MAC_BINS / 32)
+
+/*  ethernet vport update constants */
+#define ETH_FILTER_RULES_COUNT                          10
+#define ETH_RSS_IND_TABLE_ENTRIES_NUM           128
+#define ETH_RSS_KEY_SIZE_REGS                       10
+#define ETH_RSS_ENGINE_NUM_K2               207
+#define ETH_RSS_ENGINE_NUM_BB               127
+
+/* TPA constants */
+#define ETH_TPA_MAX_AGGS_NUM              64
+#define ETH_TPA_CQE_START_SGL_SIZE        3
+#define ETH_TPA_CQE_CONT_SGL_SIZE         6
+#define ETH_TPA_CQE_END_SGL_SIZE          4
+
+/* Queue Zone sizes */
+#define TSTORM_QZONE_SIZE    0
+#define MSTORM_QZONE_SIZE    sizeof(struct mstorm_eth_queue_zone)
+#define USTORM_QZONE_SIZE    sizeof(struct ustorm_eth_queue_zone)
+#define XSTORM_QZONE_SIZE    0
+#define YSTORM_QZONE_SIZE    sizeof(struct ystorm_eth_queue_zone)
+#define PSTORM_QZONE_SIZE    0
+
+/* Interrupt coalescing TimeSet */
+struct coalescing_timeset {
+	u8	timeset;
+	u8	valid;
+};
+
+struct eth_tx_1st_bd_flags {
+	u8 bitfields;
+#define ETH_TX_1ST_BD_FLAGS_FORCE_VLAN_MODE_MASK  0x1
+#define ETH_TX_1ST_BD_FLAGS_FORCE_VLAN_MODE_SHIFT 0
+#define ETH_TX_1ST_BD_FLAGS_IP_CSUM_MASK          0x1
+#define ETH_TX_1ST_BD_FLAGS_IP_CSUM_SHIFT         1
+#define ETH_TX_1ST_BD_FLAGS_L4_CSUM_MASK          0x1
+#define ETH_TX_1ST_BD_FLAGS_L4_CSUM_SHIFT         2
+#define ETH_TX_1ST_BD_FLAGS_VLAN_INSERTION_MASK   0x1
+#define ETH_TX_1ST_BD_FLAGS_VLAN_INSERTION_SHIFT  3
+#define ETH_TX_1ST_BD_FLAGS_LSO_MASK              0x1
+#define ETH_TX_1ST_BD_FLAGS_LSO_SHIFT             4
+#define ETH_TX_1ST_BD_FLAGS_START_BD_MASK         0x1
+#define ETH_TX_1ST_BD_FLAGS_START_BD_SHIFT        5
+#define ETH_TX_1ST_BD_FLAGS_TUNN_IP_CSUM_MASK     0x1
+#define ETH_TX_1ST_BD_FLAGS_TUNN_IP_CSUM_SHIFT    6
+#define ETH_TX_1ST_BD_FLAGS_TUNN_L4_CSUM_MASK     0x1
+#define ETH_TX_1ST_BD_FLAGS_TUNN_L4_CSUM_SHIFT    7
+};
+
+/* The parsing information data fo rthe first tx bd of a given packet. */
+struct eth_tx_data_1st_bd {
+	__le16				vlan;
+	u8				nbds;
+	struct eth_tx_1st_bd_flags	bd_flags;
+	__le16				fw_use_only;
+};
+
+/* The parsing information data for the second tx bd of a given packet. */
+struct eth_tx_data_2nd_bd {
+	__le16	tunn_ip_size;
+	__le16	bitfields;
+#define ETH_TX_DATA_2ND_BD_L4_HDR_START_OFFSET_W_MASK     0x1FFF
+#define ETH_TX_DATA_2ND_BD_L4_HDR_START_OFFSET_W_SHIFT    0
+#define ETH_TX_DATA_2ND_BD_RESERVED0_MASK                 0x7
+#define ETH_TX_DATA_2ND_BD_RESERVED0_SHIFT                13
+	__le16	bitfields2;
+#define ETH_TX_DATA_2ND_BD_TUNN_INNER_L2_HDR_SIZE_W_MASK  0xF
+#define ETH_TX_DATA_2ND_BD_TUNN_INNER_L2_HDR_SIZE_W_SHIFT 0
+#define ETH_TX_DATA_2ND_BD_TUNN_INNER_ETH_TYPE_MASK       0x3
+#define ETH_TX_DATA_2ND_BD_TUNN_INNER_ETH_TYPE_SHIFT      4
+#define ETH_TX_DATA_2ND_BD_DEST_PORT_MODE_MASK            0x3
+#define ETH_TX_DATA_2ND_BD_DEST_PORT_MODE_SHIFT           6
+#define ETH_TX_DATA_2ND_BD_TUNN_TYPE_MASK                 0x3
+#define ETH_TX_DATA_2ND_BD_TUNN_TYPE_SHIFT                8
+#define ETH_TX_DATA_2ND_BD_TUNN_INNER_IPV6_MASK           0x1
+#define ETH_TX_DATA_2ND_BD_TUNN_INNER_IPV6_SHIFT          10
+#define ETH_TX_DATA_2ND_BD_IPV6_EXT_MASK                  0x1
+#define ETH_TX_DATA_2ND_BD_IPV6_EXT_SHIFT                 11
+#define ETH_TX_DATA_2ND_BD_TUNN_IPV6_EXT_MASK             0x1
+#define ETH_TX_DATA_2ND_BD_TUNN_IPV6_EXT_SHIFT            12
+#define ETH_TX_DATA_2ND_BD_L4_UDP_MASK                    0x1
+#define ETH_TX_DATA_2ND_BD_L4_UDP_SHIFT                   13
+#define ETH_TX_DATA_2ND_BD_L4_PSEUDO_CSUM_MODE_MASK       0x1
+#define ETH_TX_DATA_2ND_BD_L4_PSEUDO_CSUM_MODE_SHIFT      14
+#define ETH_TX_DATA_2ND_BD_RESERVED1_MASK                 0x1
+#define ETH_TX_DATA_2ND_BD_RESERVED1_SHIFT                15
+};
+
+/* Regular ETH Rx FP CQE. */
+struct eth_fast_path_rx_reg_cqe {
+	u8	type;
+	u8	bitfields;
+#define ETH_FAST_PATH_RX_REG_CQE_RSS_HASH_TYPE_MASK  0x7
+#define ETH_FAST_PATH_RX_REG_CQE_RSS_HASH_TYPE_SHIFT 0
+#define ETH_FAST_PATH_RX_REG_CQE_TC_MASK             0xF
+#define ETH_FAST_PATH_RX_REG_CQE_TC_SHIFT            3
+#define ETH_FAST_PATH_RX_REG_CQE_RESERVED0_MASK      0x1
+#define ETH_FAST_PATH_RX_REG_CQE_RESERVED0_SHIFT     7
+	__le16				pkt_len;
+	struct parsing_and_err_flags	pars_flags;
+	__le16				vlan_tag;
+	__le32				rss_hash;
+	__le16				len_on_bd;
+	u8				placement_offset;
+	u8				reserved;
+	__le16				pbl[ETH_REG_CQE_PBL_SIZE];
+	u8				reserved1[10];
+};
+
+/* The L4 pseudo checksum mode for Ethernet */
+enum eth_l4_pseudo_checksum_mode {
+	ETH_L4_PSEUDO_CSUM_CORRECT_LENGTH,
+	ETH_L4_PSEUDO_CSUM_ZERO_LENGTH,
+	MAX_ETH_L4_PSEUDO_CHECKSUM_MODE
+};
+
+struct eth_rx_bd {
+	struct regpair addr;
+};
+
+/* regular ETH Rx SP CQE */
+struct eth_slow_path_rx_cqe {
+	u8	type;
+	u8	ramrod_cmd_id;
+	u8	error_flag;
+	u8	reserved[27];
+	__le16	echo;
+};
+
+/* union for all ETH Rx CQE types */
+union eth_rx_cqe {
+	struct eth_fast_path_rx_reg_cqe		fast_path_regular;
+	struct eth_slow_path_rx_cqe		slow_path;
+};
+
+/* ETH Rx CQE type */
+enum eth_rx_cqe_type {
+	ETH_RX_CQE_TYPE_UNUSED,
+	ETH_RX_CQE_TYPE_REGULAR,
+	ETH_RX_CQE_TYPE_SLOW_PATH,
+	MAX_ETH_RX_CQE_TYPE
+};
+
+/* ETH Rx producers data */
+struct eth_rx_prod_data {
+	__le16	bd_prod;
+	__le16	sge_prod;
+	__le16	cqe_prod;
+	__le16	reserved;
+};
+
+/* The first tx bd of a given packet */
+struct eth_tx_1st_bd {
+	struct regpair			addr;
+	__le16				nbytes;
+	struct eth_tx_data_1st_bd	data;
+};
+
+/* The second tx bd of a given packet */
+struct eth_tx_2nd_bd {
+	struct regpair			addr;
+	__le16				nbytes;
+	struct eth_tx_data_2nd_bd	data;
+};
+
+/* The parsing information data for the third tx bd of a given packet. */
+struct eth_tx_data_3rd_bd {
+	__le16	lso_mss;
+	u8	bitfields;
+#define ETH_TX_DATA_3RD_BD_TCP_HDR_LEN_DW_MASK  0xF
+#define ETH_TX_DATA_3RD_BD_TCP_HDR_LEN_DW_SHIFT 0
+#define ETH_TX_DATA_3RD_BD_HDR_NBD_MASK         0xF
+#define ETH_TX_DATA_3RD_BD_HDR_NBD_SHIFT        4
+	u8	resereved0[3];
+};
+
+/* The third tx bd of a given packet */
+struct eth_tx_3rd_bd {
+	struct regpair			addr;
+	__le16				nbytes;
+	struct eth_tx_data_3rd_bd	data;
+};
+
+/* The common non-special TX BD ring element */
+struct eth_tx_bd {
+	struct regpair	addr;
+	__le16		nbytes;
+	__le16		reserved0;
+	__le32		reserved1;
+};
+
+union eth_tx_bd_types {
+	struct eth_tx_1st_bd	first_bd;
+	struct eth_tx_2nd_bd	second_bd;
+	struct eth_tx_3rd_bd	third_bd;
+	struct eth_tx_bd	reg_bd;
+};
+
+/* Mstorm Queue Zone */
+struct mstorm_eth_queue_zone {
+	struct eth_rx_prod_data rx_producers;
+	__le32			reserved[2];
+};
+
+/* Ustorm Queue Zone */
+struct ustorm_eth_queue_zone {
+	struct coalescing_timeset	int_coalescing_timeset;
+	__le16				reserved[3];
+};
+
+/* Ystorm Queue Zone */
+struct ystorm_eth_queue_zone {
+	struct coalescing_timeset	int_coalescing_timeset;
+	__le16				reserved[3];
+};
+
+/* ETH doorbell data */
+struct eth_db_data {
+	u8 params;
+#define ETH_DB_DATA_DEST_MASK         0x3
+#define ETH_DB_DATA_DEST_SHIFT        0
+#define ETH_DB_DATA_AGG_CMD_MASK      0x3
+#define ETH_DB_DATA_AGG_CMD_SHIFT     2
+#define ETH_DB_DATA_BYPASS_EN_MASK    0x1
+#define ETH_DB_DATA_BYPASS_EN_SHIFT   4
+#define ETH_DB_DATA_RESERVED_MASK     0x1
+#define ETH_DB_DATA_RESERVED_SHIFT    5
+#define ETH_DB_DATA_AGG_VAL_SEL_MASK  0x3
+#define ETH_DB_DATA_AGG_VAL_SEL_SHIFT 6
+	u8	agg_flags;
+	__le16	bd_prod;
+};
+
+#endif /* __ETH_COMMON__ */
diff --git a/include/linux/qed/qed_eth_if.h b/include/linux/qed/qed_eth_if.h
new file mode 100644
index 0000000..fbd8700
--- /dev/null
+++ b/include/linux/qed/qed_eth_if.h
@@ -0,0 +1,38 @@
+/* QLogic qed NIC Driver
+ * Copyright (c) 2015 QLogic Corporation
+ *
+ * This software is available under the terms of the GNU General Public License
+ * (GPL) Version 2, available from the file COPYING in the main directory of
+ * this source tree.
+ */
+
+#ifndef _QED_ETH_IF_H
+#define _QED_ETH_IF_H
+
+#include <linux/list.h>
+#include <linux/if_link.h>
+#include <linux/qed/eth_common.h>
+#include <linux/qed/qed_if.h>
+
+struct qed_dev_eth_info {
+	struct qed_dev_info common;
+
+	u8	num_queues;
+	u8	num_tc;
+
+	u8	port_mac[ETH_ALEN];
+	u8	num_vlan_filters;
+};
+
+struct qed_eth_ops {
+	const struct qed_common_ops *common;
+
+	int (*fill_dev_info)(struct qed_dev *cdev,
+			     struct qed_dev_eth_info *info);
+
+};
+
+const struct qed_eth_ops *qed_get_eth_ops(u32 version);
+void qed_put_eth_ops(void);
+
+#endif
-- 
1.9.3
