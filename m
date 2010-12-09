From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [net-next 1/8] bnx2x: add FCoE ring
Date: Thu, 9 Dec 2010 14:07:25 +0200
Message-ID: <1291896445.8745.5.camel@lb-tlvb-dmitry>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "Eilon Greenstein" <eilong@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1999 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755075Ab0LIMVW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Dec 2010 07:21:22 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Includes new driver structures and FW/HW configuration for FCoE ring

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x.h         |  118 +++++++++++++--
 drivers/net/bnx2x/bnx2x_cmn.c     |   81 ++++++++--
 drivers/net/bnx2x/bnx2x_cmn.h     |   53 ++++++-
 drivers/net/bnx2x/bnx2x_ethtool.c |  290 ++++++++++++++++++----------------
 drivers/net/bnx2x/bnx2x_main.c    |  315 +++++++++++++++++++++++++++++--------
 drivers/net/bnx2x/bnx2x_stats.c   |   13 +-
 drivers/net/bnx2x/bnx2x_stats.h   |    2 -
 7 files changed, 631 insertions(+), 241 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x.h b/drivers/net/bnx2x/bnx2x.h
index cfc25cf..34d84de 100644
--- a/drivers/net/bnx2x/bnx2x.h
+++ b/drivers/net/bnx2x/bnx2x.h
@@ -13,6 +13,8 @@
 
 #ifndef BNX2X_H
 #define BNX2X_H
+#include <linux/netdevice.h>
+#include <linux/types.h>
 
 /* compilation time flags */
 
@@ -199,10 +201,25 @@ void bnx2x_panic_dump(struct bnx2x *bp);
 /* EQ completions */
 #define HC_SP_INDEX_EQ_CONS			7
 
+/* FCoE L2 connection completions */
+#define HC_SP_INDEX_ETH_FCOE_TX_CQ_CONS		6
+#define HC_SP_INDEX_ETH_FCOE_RX_CQ_CONS		4
 /* iSCSI L2 */
 #define HC_SP_INDEX_ETH_ISCSI_CQ_CONS		5
 #define HC_SP_INDEX_ETH_ISCSI_RX_CQ_CONS	1
 
+/* Special clients parameters */
+
+/* SB indices */
+/* FCoE L2 */
+#define BNX2X_FCOE_L2_RX_INDEX \
+	(&bp->def_status_blk->sp_sb.\
+	index_values[HC_SP_INDEX_ETH_FCOE_RX_CQ_CONS])
+
+#define BNX2X_FCOE_L2_TX_INDEX \
+	(&bp->def_status_blk->sp_sb.\
+	index_values[HC_SP_INDEX_ETH_FCOE_TX_CQ_CONS])
+
 /**
  *  CIDs and CLIDs:
  *  CLIDs below is a CLID for func 0, then the CLID for other
@@ -215,12 +232,19 @@ void bnx2x_panic_dump(struct bnx2x *bp);
 #define BNX2X_ISCSI_ETH_CL_ID		17
 #define BNX2X_ISCSI_ETH_CID		17
 
+/* FCoE L2 */
+#define BNX2X_FCOE_ETH_CL_ID		18
+#define BNX2X_FCOE_ETH_CID		18
+
 /** Additional rings budgeting */
 #ifdef BCM_CNIC
 #define CNIC_CONTEXT_USE		1
+#define FCOE_CONTEXT_USE		1
 #else
 #define CNIC_CONTEXT_USE		0
+#define FCOE_CONTEXT_USE		0
 #endif /* BCM_CNIC */
+#define NONE_ETH_CONTEXT_USE	(FCOE_CONTEXT_USE)
 
 #define AEU_IN_ATTN_BITS_PXPPCICLOCKCLIENT_PARITY_ERROR \
 	AEU_INPUTS_ATTN_BITS_PXPPCICLOCKCLIENT_PARITY_ERROR
@@ -401,6 +425,17 @@ struct bnx2x_fastpath {
 };
 
 #define bnx2x_fp(bp, nr, var)		(bp->fp[nr].var)
+#ifdef BCM_CNIC
+/* FCoE L2 `fastpath' is right after the eth entries */
+#define FCOE_IDX			BNX2X_NUM_ETH_QUEUES(bp)
+#define bnx2x_fcoe_fp(bp)		(&bp->fp[FCOE_IDX])
+#define bnx2x_fcoe(bp, var)		(bnx2x_fcoe_fp(bp)->var)
+#define IS_FCOE_FP(fp)			(fp->index == FCOE_IDX)
+#define IS_FCOE_IDX(idx)		((idx) == FCOE_IDX)
+#else
+#define IS_FCOE_FP(fp)		false
+#define IS_FCOE_IDX(idx)	false
+#endif
 
 
 /* MC hsi */
@@ -669,7 +704,9 @@ struct bnx2x_port {
 enum {
 	CAM_ETH_LINE = 0,
 	CAM_ISCSI_ETH_LINE,
-	CAM_MAX_PF_LINE = CAM_ISCSI_ETH_LINE
+	CAM_FIP_ETH_LINE,
+	CAM_FIP_MCAST_LINE,
+	CAM_MAX_PF_LINE = CAM_FIP_MCAST_LINE
 };
 /* number of MACs per function in NIG memory - used for SI mode */
 #define NIG_LLH_FUNC_MEM_SIZE		16
@@ -714,6 +751,14 @@ enum {
  */
 #define L2_FP_COUNT(cid_cnt)	((cid_cnt) - CNIC_CONTEXT_USE)
 
+/*
+ * The number of FP-SB allocated by the driver == max number of regular L2
+ * queues + 1 for the CNIC which also consumes an FP-SB
+ */
+#define FP_SB_COUNT(cid_cnt)	((cid_cnt) - FCOE_CONTEXT_USE)
+#define NUM_IGU_SB_REQUIRED(cid_cnt) \
+				(FP_SB_COUNT(cid_cnt) - NONE_ETH_CONTEXT_USE)
+
 union cdu_context {
 	struct eth_context eth;
 	char pad[1024];
@@ -726,7 +771,8 @@ union cdu_context {
 
 #ifdef BCM_CNIC
 #define CNIC_ISCSI_CID_MAX	256
-#define CNIC_CID_MAX		(CNIC_ISCSI_CID_MAX)
+#define CNIC_FCOE_CID_MAX	2048
+#define CNIC_CID_MAX		(CNIC_ISCSI_CID_MAX + CNIC_FCOE_CID_MAX)
 #define CNIC_ILT_LINES		DIV_ROUND_UP(CNIC_CID_MAX, ILT_PAGE_CIDS)
 #endif
 
@@ -922,6 +968,10 @@ struct bnx2x {
 #define DISABLE_MSI_FLAG		0x200
 #define BP_NOMCP(bp)			(bp->flags & NO_MCP_FLAG)
 #define MF_FUNC_DIS			0x1000
+#define FCOE_MACS_SET			0x2000
+#define NO_FCOE_FLAG			0x4000
+
+#define NO_FCOE(bp)		((bp)->flags & NO_FCOE_FLAG)
 
 	int			pf_num;	/* absolute PF number */
 	int			pfid;	/* per-path PF number */
@@ -1069,7 +1119,8 @@ struct bnx2x {
 	u16			cnic_kwq_pending;
 	u16			cnic_spq_pending;
 	struct mutex		cnic_mutex;
-	u8			iscsi_mac[6];
+	u8			iscsi_mac[ETH_ALEN];
+	u8			fip_mac[ETH_ALEN];
 #endif
 
 	int			dmae_ready;
@@ -1159,10 +1210,17 @@ struct bnx2x {
 #define RSS_IPV6_TCP_CAP	0x0008
 
 #define BNX2X_NUM_QUEUES(bp)	(bp->num_queues)
+#define BNX2X_NUM_ETH_QUEUES(bp) (BNX2X_NUM_QUEUES(bp) - NONE_ETH_CONTEXT_USE)
+
+/* ethtool statistics are displayed for all regular ethernet queues and the
+ * fcoe L2 queue if not disabled
+ */
+#define BNX2X_NUM_STAT_QUEUES(bp) (NO_FCOE(bp) ? BNX2X_NUM_ETH_QUEUES(bp) : \
+			   (BNX2X_NUM_ETH_QUEUES(bp) + FCOE_CONTEXT_USE))
+
 #define is_multi(bp)		(BNX2X_NUM_QUEUES(bp) > 1)
 
 #define BNX2X_MAX_QUEUES(bp)	(bp->igu_sb_cnt - CNIC_CONTEXT_USE)
-#define is_eth_multi(bp)	(BNX2X_NUM_ETH_QUEUES(bp) > 1)
 
 #define RSS_IPV4_CAP_MASK						\
 	TSTORM_ETH_FUNCTION_COMMON_CONFIG_RSS_IPV4_CAPABILITY
@@ -1255,6 +1313,7 @@ struct bnx2x_client_ramrod_params {
 	u16 cl_id;
 	u32 cid;
 	u8 poll;
+#define CLIENT_IS_FCOE			0x01
 #define CLIENT_IS_LEADING_RSS		0x02
 	u8 flags;
 };
@@ -1287,11 +1346,54 @@ struct bnx2x_func_init_params {
 	u16		spq_prod;	/* valid iff FUNC_FLG_SPQ */
 };
 
+#define for_each_eth_queue(bp, var) \
+			for (var = 0; var < BNX2X_NUM_ETH_QUEUES(bp); var++)
+
+#define for_each_nondefault_eth_queue(bp, var) \
+			for (var = 1; var < BNX2X_NUM_ETH_QUEUES(bp); var++)
+
+#define for_each_napi_queue(bp, var) \
+	for (var = 0; \
+		var < BNX2X_NUM_ETH_QUEUES(bp) + FCOE_CONTEXT_USE; var++) \
+		if (skip_queue(bp, var))	\
+			continue;		\
+		else
+
 #define for_each_queue(bp, var) \
-			for (var = 0; var < BNX2X_NUM_QUEUES(bp); var++)
+	for (var = 0; var < BNX2X_NUM_QUEUES(bp); var++) \
+		if (skip_queue(bp, var))	\
+			continue;		\
+		else
+
+#define for_each_rx_queue(bp, var) \
+	for (var = 0; var < BNX2X_NUM_QUEUES(bp); var++) \
+		if (skip_rx_queue(bp, var))	\
+			continue;		\
+		else
+
+#define for_each_tx_queue(bp, var) \
+	for (var = 0; var < BNX2X_NUM_QUEUES(bp); var++) \
+		if (skip_tx_queue(bp, var))	\
+			continue;		\
+		else
+
 #define for_each_nondefault_queue(bp, var) \
-			for (var = 1; var < BNX2X_NUM_QUEUES(bp); var++)
+	for (var = 1; var < BNX2X_NUM_QUEUES(bp); var++) \
+		if (skip_queue(bp, var))	\
+			continue;		\
+		else
 
+/* skip rx queue
+ * if FCOE l2 support is diabled and this is the fcoe L2 queue
+ */
+#define skip_rx_queue(bp, idx)	(NO_FCOE(bp) && IS_FCOE_IDX(idx))
+
+/* skip tx queue
+ * if FCOE l2 support is diabled and this is the fcoe L2 queue
+ */
+#define skip_tx_queue(bp, idx)	(NO_FCOE(bp) && IS_FCOE_IDX(idx))
+
+#define skip_queue(bp, idx)	(NO_FCOE(bp) && IS_FCOE_IDX(idx))
 
 #define WAIT_RAMROD_POLL	0x01
 #define WAIT_RAMROD_COMMON	0x02
@@ -1615,10 +1717,6 @@ static inline u32 reg_poll(struct bnx2x *bp, u32 reg, u32 expected, int ms,
 	MAC_CONFIGURATION_ENTRY_ACTION_TYPE) == \
 	(T_ETH_MAC_COMMAND_INVALIDATE))
 
-#define CAM_INVALIDATE(x) \
-	(x.target_table_entry.flags = TSTORM_CAM_TARGET_TABLE_ENTRY_ACTION_TYPE)
-
-
 /* Number of u32 elements in MC hash array */
 #define MC_HASH_SIZE			8
 #define MC_HASH_OFFSET(bp, i)		(BAR_TSTRORM_INTMEM + \
diff --git a/drivers/net/bnx2x/bnx2x_cmn.c b/drivers/net/bnx2x/bnx2x_cmn.c
index a4555ed..a553fba 100644
--- a/drivers/net/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/bnx2x/bnx2x_cmn.c
@@ -827,7 +827,7 @@ void bnx2x_init_rx_rings(struct bnx2x *bp)
 	DP(NETIF_MSG_IFUP,
 	   "mtu %d  rx_buf_size %d\n", bp->dev->mtu, bp->rx_buf_size);
 
-	for_each_queue(bp, j) {
+	for_each_rx_queue(bp, j) {
 		struct bnx2x_fastpath *fp = &bp->fp[j];
 
 		if (!fp->disable_tpa) {
@@ -880,7 +880,7 @@ void bnx2x_init_rx_rings(struct bnx2x *bp)
 		}
 	}
 
-	for_each_queue(bp, j) {
+	for_each_rx_queue(bp, j) {
 		struct bnx2x_fastpath *fp = &bp->fp[j];
 
 		fp->rx_bd_cons = 0;
@@ -911,7 +911,7 @@ static void bnx2x_free_tx_skbs(struct bnx2x *bp)
 {
 	int i;
 
-	for_each_queue(bp, i) {
+	for_each_tx_queue(bp, i) {
 		struct bnx2x_fastpath *fp = &bp->fp[i];
 
 		u16 bd_cons = fp->tx_bd_cons;
@@ -929,7 +929,7 @@ static void bnx2x_free_rx_skbs(struct bnx2x *bp)
 {
 	int i, j;
 
-	for_each_queue(bp, j) {
+	for_each_rx_queue(bp, j) {
 		struct bnx2x_fastpath *fp = &bp->fp[j];
 
 		for (i = 0; i < NUM_RX_BD; i++) {
@@ -970,7 +970,7 @@ static void bnx2x_free_msix_irqs(struct bnx2x *bp)
 #ifdef BCM_CNIC
 	offset++;
 #endif
-	for_each_queue(bp, i) {
+	for_each_eth_queue(bp, i) {
 		DP(NETIF_MSG_IFDOWN, "about to release fp #%d->%d irq  "
 		   "state %x\n", i, bp->msix_table[i + offset].vector,
 		   bnx2x_fp(bp, i, state));
@@ -1004,14 +1004,14 @@ int bnx2x_enable_msix(struct bnx2x *bp)
 	   bp->msix_table[msix_vec].entry, bp->msix_table[msix_vec].entry);
 	msix_vec++;
 #endif
-	for_each_queue(bp, i) {
+	for_each_eth_queue(bp, i) {
 		bp->msix_table[msix_vec].entry = msix_vec;
 		DP(NETIF_MSG_IFUP, "msix_table[%d].entry = %d "
 		   "(fastpath #%u)\n", msix_vec, msix_vec, i);
 		msix_vec++;
 	}
 
-	req_cnt = BNX2X_NUM_QUEUES(bp) + CNIC_CONTEXT_USE + 1;
+	req_cnt = BNX2X_NUM_ETH_QUEUES(bp) + CNIC_CONTEXT_USE + 1;
 
 	rc = pci_enable_msix(bp->pdev, &bp->msix_table[0], req_cnt);
 
@@ -1067,7 +1067,7 @@ static int bnx2x_req_msix_irqs(struct bnx2x *bp)
 #ifdef BCM_CNIC
 	offset++;
 #endif
-	for_each_queue(bp, i) {
+	for_each_eth_queue(bp, i) {
 		struct bnx2x_fastpath *fp = &bp->fp[i];
 		snprintf(fp->name, sizeof(fp->name), "%s-fp-%d",
 			 bp->dev->name, i);
@@ -1084,7 +1084,7 @@ static int bnx2x_req_msix_irqs(struct bnx2x *bp)
 		fp->state = BNX2X_FP_STATE_IRQ;
 	}
 
-	i = BNX2X_NUM_QUEUES(bp);
+	i = BNX2X_NUM_ETH_QUEUES(bp);
 	offset = 1 + CNIC_CONTEXT_USE;
 	netdev_info(bp->dev, "using MSI-X  IRQs: sp %d  fp[%d] %d"
 	       " ... fp[%d] %d\n",
@@ -1131,7 +1131,7 @@ static void bnx2x_napi_enable(struct bnx2x *bp)
 {
 	int i;
 
-	for_each_queue(bp, i)
+	for_each_napi_queue(bp, i)
 		napi_enable(&bnx2x_fp(bp, i, napi));
 }
 
@@ -1139,7 +1139,7 @@ static void bnx2x_napi_disable(struct bnx2x *bp)
 {
 	int i;
 
-	for_each_queue(bp, i)
+	for_each_napi_queue(bp, i)
 		napi_disable(&bnx2x_fp(bp, i, napi));
 }
 
@@ -1181,7 +1181,22 @@ void bnx2x_set_num_queues(struct bnx2x *bp)
 		bp->num_queues = 1;
 		break;
 	}
+
+	/* Add special queues */
+	bp->num_queues += NONE_ETH_CONTEXT_USE;
+}
+
+#ifdef BCM_CNIC
+static inline void bnx2x_set_fcoe_eth_macs(struct bnx2x *bp)
+{
+	if (!NO_FCOE(bp)) {
+		if (!IS_MF_SD(bp))
+			bnx2x_set_fip_eth_mac_addr(bp, 1);
+		bnx2x_set_all_enode_macs(bp, 1);
+		bp->flags |= FCOE_MACS_SET;
+	}
 }
+#endif
 
 static void bnx2x_release_firmware(struct bnx2x *bp)
 {
@@ -1191,6 +1206,20 @@ static void bnx2x_release_firmware(struct bnx2x *bp)
 	release_firmware(bp->firmware);
 }
 
+static inline int bnx2x_set_real_num_queues(struct bnx2x *bp)
+{
+	int rc, num = bp->num_queues;
+
+#ifdef BCM_CNIC
+	if (NO_FCOE(bp))
+		num -= FCOE_CONTEXT_USE;
+
+#endif
+	netif_set_real_num_tx_queues(bp->dev, num);
+	rc = netif_set_real_num_rx_queues(bp->dev, num);
+	return rc;
+}
+
 /* must be called with rtnl_lock */
 int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
 {
@@ -1217,10 +1246,9 @@ int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
 	if (bnx2x_alloc_mem(bp))
 		return -ENOMEM;
 
-	netif_set_real_num_tx_queues(bp->dev, bp->num_queues);
-	rc = netif_set_real_num_rx_queues(bp->dev, bp->num_queues);
+	rc = bnx2x_set_real_num_queues(bp);
 	if (rc) {
-		BNX2X_ERR("Unable to update real_num_rx_queues\n");
+		BNX2X_ERR("Unable to set real_num_queues\n");
 		goto load_error0;
 	}
 
@@ -1228,6 +1256,10 @@ int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
 		bnx2x_fp(bp, i, disable_tpa) =
 					((bp->flags & TPA_ENABLE_FLAG) == 0);
 
+#ifdef BCM_CNIC
+	/* We don't want TPA on FCoE L2 ring */
+	bnx2x_fcoe(bp, disable_tpa) = 1;
+#endif
 	bnx2x_napi_enable(bp);
 
 	/* Send LOAD_REQUEST command to MCP
@@ -1358,6 +1390,10 @@ int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
 	/* Now when Clients are configured we are ready to work */
 	bp->state = BNX2X_STATE_OPEN;
 
+#ifdef BCM_CNIC
+	bnx2x_set_fcoe_eth_macs(bp);
+#endif
+
 	bnx2x_set_eth_mac(bp, 1);
 
 	if (bp->port.pmf)
@@ -1416,7 +1452,7 @@ load_error3:
 
 	/* Free SKBs, SGEs, TPA pool and driver internals */
 	bnx2x_free_skbs(bp);
-	for_each_queue(bp, i)
+	for_each_rx_queue(bp, i)
 		bnx2x_free_rx_sge_range(bp, bp->fp + i, NUM_RX_SGE);
 
 	/* Release IRQs */
@@ -1487,7 +1523,7 @@ int bnx2x_nic_unload(struct bnx2x *bp, int unload_mode)
 
 	/* Free SKBs, SGEs, TPA pool and driver internals */
 	bnx2x_free_skbs(bp);
-	for_each_queue(bp, i)
+	for_each_rx_queue(bp, i)
 		bnx2x_free_rx_sge_range(bp, bp->fp + i, NUM_RX_SGE);
 
 	bnx2x_free_mem(bp);
@@ -1591,6 +1627,17 @@ int bnx2x_poll(struct napi_struct *napi, int budget)
 
 		/* Fall out from the NAPI loop if needed */
 		if (!(bnx2x_has_rx_work(fp) || bnx2x_has_tx_work(fp))) {
+#ifdef BCM_CNIC
+			/* No need to update SB for FCoE L2 ring as long as
+			 * it's connected to the default SB and the SB
+			 * has been updated when NAPI was scheduled.
+			 */
+			if (IS_FCOE_FP(fp)) {
+				napi_complete(napi);
+				break;
+			}
+#endif
+
 			bnx2x_update_fpsb_idx(fp);
 			/* bnx2x_has_rx_work() reads the status block,
 			 * thus we need to ensure that status block indices
@@ -2245,7 +2292,7 @@ int __devinit bnx2x_alloc_mem_bp(struct bnx2x *bp)
 	bp->fp = fp;
 
 	/* msix table */
-	tbl = kzalloc((bp->l2_cid_count + 1) * sizeof(*tbl),
+	tbl = kzalloc((FP_SB_COUNT(bp->l2_cid_count) + 1) * sizeof(*tbl),
 				  GFP_KERNEL);
 	if (!tbl)
 		goto alloc_err;
diff --git a/drivers/net/bnx2x/bnx2x_cmn.h b/drivers/net/bnx2x/bnx2x_cmn.h
index cb8f2a0..4bb0113 100644
--- a/drivers/net/bnx2x/bnx2x_cmn.h
+++ b/drivers/net/bnx2x/bnx2x_cmn.h
@@ -242,6 +242,30 @@ int bnx2x_release_hw_lock(struct bnx2x *bp, u32 resource);
  */
 void bnx2x_set_eth_mac(struct bnx2x *bp, int set);
 
+#ifdef BCM_CNIC
+/**
+ * Set/Clear FIP MAC(s) at the next enties in the CAM after the ETH
+ * MAC(s). This function will wait until the ramdord completion
+ * returns.
+ *
+ * @param bp driver handle
+ * @param set set or clear the CAM entry
+ *
+ * @return 0 if cussess, -ENODEV if ramrod doesn't return.
+ */
+int bnx2x_set_fip_eth_mac_addr(struct bnx2x *bp, int set);
+
+/**
+ * Set/Clear ALL_ENODE mcast MAC.
+ *
+ * @param bp
+ * @param set
+ *
+ * @return int
+ */
+int bnx2x_set_all_enode_macs(struct bnx2x *bp, int set);
+#endif
+
 /**
  * Set MAC filtering configurations.
  *
@@ -695,7 +719,7 @@ static inline void bnx2x_add_all_napi(struct bnx2x *bp)
 	int i;
 
 	/* Add NAPI objects */
-	for_each_queue(bp, i)
+	for_each_napi_queue(bp, i)
 		netif_napi_add(bp->dev, &bnx2x_fp(bp, i, napi),
 			       bnx2x_poll, BNX2X_NAPI_WEIGHT);
 }
@@ -704,7 +728,7 @@ static inline void bnx2x_del_all_napi(struct bnx2x *bp)
 {
 	int i;
 
-	for_each_queue(bp, i)
+	for_each_napi_queue(bp, i)
 		netif_napi_del(&bnx2x_fp(bp, i, napi));
 }
 
@@ -870,7 +894,7 @@ static inline void bnx2x_init_tx_rings(struct bnx2x *bp)
 {
 	int i, j;
 
-	for_each_queue(bp, j) {
+	for_each_tx_queue(bp, j) {
 		struct bnx2x_fastpath *fp = &bp->fp[j];
 
 		for (i = 1; i <= NUM_TX_RINGS; i++) {
@@ -949,7 +973,30 @@ static inline void bnx2x_set_next_page_rx_cq(struct bnx2x_fastpath *fp)
 	}
 }
 
+#ifdef BCM_CNIC
+static inline void bnx2x_init_fcoe_fp(struct bnx2x *bp)
+{
+	bnx2x_fcoe(bp, cl_id) = BNX2X_FCOE_ETH_CL_ID +
+		BP_E1HVN(bp) * NONE_ETH_CONTEXT_USE;
+	bnx2x_fcoe(bp, cid) = BNX2X_FCOE_ETH_CID;
+	bnx2x_fcoe(bp, fw_sb_id) = DEF_SB_ID;
+	bnx2x_fcoe(bp, igu_sb_id) = bp->igu_dsb_id;
+	bnx2x_fcoe(bp, bp) = bp;
+	bnx2x_fcoe(bp, state) = BNX2X_FP_STATE_CLOSED;
+	bnx2x_fcoe(bp, index) = FCOE_IDX;
+	bnx2x_fcoe(bp, rx_cons_sb) = BNX2X_FCOE_L2_RX_INDEX;
+	bnx2x_fcoe(bp, tx_cons_sb) = BNX2X_FCOE_L2_TX_INDEX;
+	/* qZone id equals to FW (per path) client id */
+	bnx2x_fcoe(bp, cl_qzone_id) = bnx2x_fcoe(bp, cl_id) +
+		BP_PORT(bp)*(CHIP_IS_E2(bp) ? ETH_MAX_RX_CLIENTS_E2 :
+				ETH_MAX_RX_CLIENTS_E1H);
+	/* init shortcut */
+	bnx2x_fcoe(bp, ustorm_rx_prods_offset) = CHIP_IS_E2(bp) ?
+	    USTORM_RX_PRODS_E2_OFFSET(bnx2x_fcoe(bp, cl_qzone_id)) :
+	    USTORM_RX_PRODS_E1X_OFFSET(BP_PORT(bp), bnx2x_fcoe_fp(bp)->cl_id);
 
+}
+#endif
 
 static inline void __storm_memset_struct(struct bnx2x *bp,
 					 u32 addr, size_t size, u32 *data)
diff --git a/drivers/net/bnx2x/bnx2x_ethtool.c b/drivers/net/bnx2x/bnx2x_ethtool.c
index bd94827..99c672d 100644
--- a/drivers/net/bnx2x/bnx2x_ethtool.c
+++ b/drivers/net/bnx2x/bnx2x_ethtool.c
@@ -25,6 +25,143 @@
 #include "bnx2x_cmn.h"
 #include "bnx2x_dump.h"
 
+/* Note: in the format strings below %s is replaced by the queue-name which is
+ * either its index or 'fcoe' for the fcoe queue. Make sure the format string
+ * length does not exceed ETH_GSTRING_LEN - MAX_QUEUE_NAME_LEN + 2
+ */
+#define MAX_QUEUE_NAME_LEN	4
+static const struct {
+	long offset;
+	int size;
+	char string[ETH_GSTRING_LEN];
+} bnx2x_q_stats_arr[] = {
+/* 1 */	{ Q_STATS_OFFSET32(total_bytes_received_hi), 8, "[%s]: rx_bytes" },
+	{ Q_STATS_OFFSET32(error_bytes_received_hi),
+						8, "[%s]: rx_error_bytes" },
+	{ Q_STATS_OFFSET32(total_unicast_packets_received_hi),
+						8, "[%s]: rx_ucast_packets" },
+	{ Q_STATS_OFFSET32(total_multicast_packets_received_hi),
+						8, "[%s]: rx_mcast_packets" },
+	{ Q_STATS_OFFSET32(total_broadcast_packets_received_hi),
+						8, "[%s]: rx_bcast_packets" },
+	{ Q_STATS_OFFSET32(no_buff_discard_hi),	8, "[%s]: rx_discards" },
+	{ Q_STATS_OFFSET32(rx_err_discard_pkt),
+					 4, "[%s]: rx_phy_ip_err_discards"},
+	{ Q_STATS_OFFSET32(rx_skb_alloc_failed),
+					 4, "[%s]: rx_skb_alloc_discard" },
+	{ Q_STATS_OFFSET32(hw_csum_err), 4, "[%s]: rx_csum_offload_errors" },
+
+/* 10 */{ Q_STATS_OFFSET32(total_bytes_transmitted_hi),	8, "[%s]: tx_bytes" },
+	{ Q_STATS_OFFSET32(total_unicast_packets_transmitted_hi),
+						8, "[%s]: tx_ucast_packets" },
+	{ Q_STATS_OFFSET32(total_multicast_packets_transmitted_hi),
+						8, "[%s]: tx_mcast_packets" },
+	{ Q_STATS_OFFSET32(total_broadcast_packets_transmitted_hi),
+						8, "[%s]: tx_bcast_packets" }
+};
+
+#define BNX2X_NUM_Q_STATS ARRAY_SIZE(bnx2x_q_stats_arr)
+
+static const struct {
+	long offset;
+	int size;
+	u32 flags;
+#define STATS_FLAGS_PORT		1
+#define STATS_FLAGS_FUNC		2
+#define STATS_FLAGS_BOTH		(STATS_FLAGS_FUNC | STATS_FLAGS_PORT)
+	char string[ETH_GSTRING_LEN];
+} bnx2x_stats_arr[] = {
+/* 1 */	{ STATS_OFFSET32(total_bytes_received_hi),
+				8, STATS_FLAGS_BOTH, "rx_bytes" },
+	{ STATS_OFFSET32(error_bytes_received_hi),
+				8, STATS_FLAGS_BOTH, "rx_error_bytes" },
+	{ STATS_OFFSET32(total_unicast_packets_received_hi),
+				8, STATS_FLAGS_BOTH, "rx_ucast_packets" },
+	{ STATS_OFFSET32(total_multicast_packets_received_hi),
+				8, STATS_FLAGS_BOTH, "rx_mcast_packets" },
+	{ STATS_OFFSET32(total_broadcast_packets_received_hi),
+				8, STATS_FLAGS_BOTH, "rx_bcast_packets" },
+	{ STATS_OFFSET32(rx_stat_dot3statsfcserrors_hi),
+				8, STATS_FLAGS_PORT, "rx_crc_errors" },
+	{ STATS_OFFSET32(rx_stat_dot3statsalignmenterrors_hi),
+				8, STATS_FLAGS_PORT, "rx_align_errors" },
+	{ STATS_OFFSET32(rx_stat_etherstatsundersizepkts_hi),
+				8, STATS_FLAGS_PORT, "rx_undersize_packets" },
+	{ STATS_OFFSET32(etherstatsoverrsizepkts_hi),
+				8, STATS_FLAGS_PORT, "rx_oversize_packets" },
+/* 10 */{ STATS_OFFSET32(rx_stat_etherstatsfragments_hi),
+				8, STATS_FLAGS_PORT, "rx_fragments" },
+	{ STATS_OFFSET32(rx_stat_etherstatsjabbers_hi),
+				8, STATS_FLAGS_PORT, "rx_jabbers" },
+	{ STATS_OFFSET32(no_buff_discard_hi),
+				8, STATS_FLAGS_BOTH, "rx_discards" },
+	{ STATS_OFFSET32(mac_filter_discard),
+				4, STATS_FLAGS_PORT, "rx_filtered_packets" },
+	{ STATS_OFFSET32(xxoverflow_discard),
+				4, STATS_FLAGS_PORT, "rx_fw_discards" },
+	{ STATS_OFFSET32(brb_drop_hi),
+				8, STATS_FLAGS_PORT, "rx_brb_discard" },
+	{ STATS_OFFSET32(brb_truncate_hi),
+				8, STATS_FLAGS_PORT, "rx_brb_truncate" },
+	{ STATS_OFFSET32(pause_frames_received_hi),
+				8, STATS_FLAGS_PORT, "rx_pause_frames" },
+	{ STATS_OFFSET32(rx_stat_maccontrolframesreceived_hi),
+				8, STATS_FLAGS_PORT, "rx_mac_ctrl_frames" },
+	{ STATS_OFFSET32(nig_timer_max),
+			4, STATS_FLAGS_PORT, "rx_constant_pause_events" },
+/* 20 */{ STATS_OFFSET32(rx_err_discard_pkt),
+				4, STATS_FLAGS_BOTH, "rx_phy_ip_err_discards"},
+	{ STATS_OFFSET32(rx_skb_alloc_failed),
+				4, STATS_FLAGS_BOTH, "rx_skb_alloc_discard" },
+	{ STATS_OFFSET32(hw_csum_err),
+				4, STATS_FLAGS_BOTH, "rx_csum_offload_errors" },
+
+	{ STATS_OFFSET32(total_bytes_transmitted_hi),
+				8, STATS_FLAGS_BOTH, "tx_bytes" },
+	{ STATS_OFFSET32(tx_stat_ifhcoutbadoctets_hi),
+				8, STATS_FLAGS_PORT, "tx_error_bytes" },
+	{ STATS_OFFSET32(total_unicast_packets_transmitted_hi),
+				8, STATS_FLAGS_BOTH, "tx_ucast_packets" },
+	{ STATS_OFFSET32(total_multicast_packets_transmitted_hi),
+				8, STATS_FLAGS_BOTH, "tx_mcast_packets" },
+	{ STATS_OFFSET32(total_broadcast_packets_transmitted_hi),
+				8, STATS_FLAGS_BOTH, "tx_bcast_packets" },
+	{ STATS_OFFSET32(tx_stat_dot3statsinternalmactransmiterrors_hi),
+				8, STATS_FLAGS_PORT, "tx_mac_errors" },
+	{ STATS_OFFSET32(rx_stat_dot3statscarriersenseerrors_hi),
+				8, STATS_FLAGS_PORT, "tx_carrier_errors" },
+/* 30 */{ STATS_OFFSET32(tx_stat_dot3statssinglecollisionframes_hi),
+				8, STATS_FLAGS_PORT, "tx_single_collisions" },
+	{ STATS_OFFSET32(tx_stat_dot3statsmultiplecollisionframes_hi),
+				8, STATS_FLAGS_PORT, "tx_multi_collisions" },
+	{ STATS_OFFSET32(tx_stat_dot3statsdeferredtransmissions_hi),
+				8, STATS_FLAGS_PORT, "tx_deferred" },
+	{ STATS_OFFSET32(tx_stat_dot3statsexcessivecollisions_hi),
+				8, STATS_FLAGS_PORT, "tx_excess_collisions" },
+	{ STATS_OFFSET32(tx_stat_dot3statslatecollisions_hi),
+				8, STATS_FLAGS_PORT, "tx_late_collisions" },
+	{ STATS_OFFSET32(tx_stat_etherstatscollisions_hi),
+				8, STATS_FLAGS_PORT, "tx_total_collisions" },
+	{ STATS_OFFSET32(tx_stat_etherstatspkts64octets_hi),
+				8, STATS_FLAGS_PORT, "tx_64_byte_packets" },
+	{ STATS_OFFSET32(tx_stat_etherstatspkts65octetsto127octets_hi),
+			8, STATS_FLAGS_PORT, "tx_65_to_127_byte_packets" },
+	{ STATS_OFFSET32(tx_stat_etherstatspkts128octetsto255octets_hi),
+			8, STATS_FLAGS_PORT, "tx_128_to_255_byte_packets" },
+	{ STATS_OFFSET32(tx_stat_etherstatspkts256octetsto511octets_hi),
+			8, STATS_FLAGS_PORT, "tx_256_to_511_byte_packets" },
+/* 40 */{ STATS_OFFSET32(tx_stat_etherstatspkts512octetsto1023octets_hi),
+			8, STATS_FLAGS_PORT, "tx_512_to_1023_byte_packets" },
+	{ STATS_OFFSET32(etherstatspkts1024octetsto1522octets_hi),
+			8, STATS_FLAGS_PORT, "tx_1024_to_1522_byte_packets" },
+	{ STATS_OFFSET32(etherstatspktsover1522octets_hi),
+			8, STATS_FLAGS_PORT, "tx_1523_to_9022_byte_packets" },
+	{ STATS_OFFSET32(pause_frames_sent_hi),
+				8, STATS_FLAGS_PORT, "tx_pause_frames" }
+};
+
+#define BNX2X_NUM_STATS		ARRAY_SIZE(bnx2x_stats_arr)
+
 static int bnx2x_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
 	struct bnx2x *bp = netdev_priv(dev);
@@ -1318,7 +1455,7 @@ static int bnx2x_test_registers(struct bnx2x *bp)
 
 			save_val = REG_RD(bp, offset);
 
-			REG_WR(bp, offset, (wr_val & mask));
+			REG_WR(bp, offset, wr_val & mask);
 
 			val = REG_RD(bp, offset);
 
@@ -1689,7 +1826,7 @@ static int bnx2x_test_intr(struct bnx2x *bp)
 	config->hdr.client_id = bp->fp->cl_id;
 	config->hdr.reserved1 = 0;
 
-	bp->set_mac_pending++;
+	bp->set_mac_pending = 1;
 	smp_wmb();
 	rc = bnx2x_sp_post(bp, RAMROD_CMD_ID_COMMON_SET_MAC, 0,
 			   U64_HI(bnx2x_sp_mapping(bp, mac_config)),
@@ -1787,134 +1924,6 @@ static void bnx2x_self_test(struct net_device *dev,
 #endif
 }
 
-static const struct {
-	long offset;
-	int size;
-	u8 string[ETH_GSTRING_LEN];
-} bnx2x_q_stats_arr[BNX2X_NUM_Q_STATS] = {
-/* 1 */	{ Q_STATS_OFFSET32(total_bytes_received_hi), 8, "[%d]: rx_bytes" },
-	{ Q_STATS_OFFSET32(error_bytes_received_hi),
-						8, "[%d]: rx_error_bytes" },
-	{ Q_STATS_OFFSET32(total_unicast_packets_received_hi),
-						8, "[%d]: rx_ucast_packets" },
-	{ Q_STATS_OFFSET32(total_multicast_packets_received_hi),
-						8, "[%d]: rx_mcast_packets" },
-	{ Q_STATS_OFFSET32(total_broadcast_packets_received_hi),
-						8, "[%d]: rx_bcast_packets" },
-	{ Q_STATS_OFFSET32(no_buff_discard_hi),	8, "[%d]: rx_discards" },
-	{ Q_STATS_OFFSET32(rx_err_discard_pkt),
-					 4, "[%d]: rx_phy_ip_err_discards"},
-	{ Q_STATS_OFFSET32(rx_skb_alloc_failed),
-					 4, "[%d]: rx_skb_alloc_discard" },
-	{ Q_STATS_OFFSET32(hw_csum_err), 4, "[%d]: rx_csum_offload_errors" },
-
-/* 10 */{ Q_STATS_OFFSET32(total_bytes_transmitted_hi),	8, "[%d]: tx_bytes" },
-	{ Q_STATS_OFFSET32(total_unicast_packets_transmitted_hi),
-						8, "[%d]: tx_ucast_packets" },
-	{ Q_STATS_OFFSET32(total_multicast_packets_transmitted_hi),
-						8, "[%d]: tx_mcast_packets" },
-	{ Q_STATS_OFFSET32(total_broadcast_packets_transmitted_hi),
-						8, "[%d]: tx_bcast_packets" }
-};
-
-static const struct {
-	long offset;
-	int size;
-	u32 flags;
-#define STATS_FLAGS_PORT		1
-#define STATS_FLAGS_FUNC		2
-#define STATS_FLAGS_BOTH		(STATS_FLAGS_FUNC | STATS_FLAGS_PORT)
-	u8 string[ETH_GSTRING_LEN];
-} bnx2x_stats_arr[BNX2X_NUM_STATS] = {
-/* 1 */	{ STATS_OFFSET32(total_bytes_received_hi),
-				8, STATS_FLAGS_BOTH, "rx_bytes" },
-	{ STATS_OFFSET32(error_bytes_received_hi),
-				8, STATS_FLAGS_BOTH, "rx_error_bytes" },
-	{ STATS_OFFSET32(total_unicast_packets_received_hi),
-				8, STATS_FLAGS_BOTH, "rx_ucast_packets" },
-	{ STATS_OFFSET32(total_multicast_packets_received_hi),
-				8, STATS_FLAGS_BOTH, "rx_mcast_packets" },
-	{ STATS_OFFSET32(total_broadcast_packets_received_hi),
-				8, STATS_FLAGS_BOTH, "rx_bcast_packets" },
-	{ STATS_OFFSET32(rx_stat_dot3statsfcserrors_hi),
-				8, STATS_FLAGS_PORT, "rx_crc_errors" },
-	{ STATS_OFFSET32(rx_stat_dot3statsalignmenterrors_hi),
-				8, STATS_FLAGS_PORT, "rx_align_errors" },
-	{ STATS_OFFSET32(rx_stat_etherstatsundersizepkts_hi),
-				8, STATS_FLAGS_PORT, "rx_undersize_packets" },
-	{ STATS_OFFSET32(etherstatsoverrsizepkts_hi),
-				8, STATS_FLAGS_PORT, "rx_oversize_packets" },
-/* 10 */{ STATS_OFFSET32(rx_stat_etherstatsfragments_hi),
-				8, STATS_FLAGS_PORT, "rx_fragments" },
-	{ STATS_OFFSET32(rx_stat_etherstatsjabbers_hi),
-				8, STATS_FLAGS_PORT, "rx_jabbers" },
-	{ STATS_OFFSET32(no_buff_discard_hi),
-				8, STATS_FLAGS_BOTH, "rx_discards" },
-	{ STATS_OFFSET32(mac_filter_discard),
-				4, STATS_FLAGS_PORT, "rx_filtered_packets" },
-	{ STATS_OFFSET32(xxoverflow_discard),
-				4, STATS_FLAGS_PORT, "rx_fw_discards" },
-	{ STATS_OFFSET32(brb_drop_hi),
-				8, STATS_FLAGS_PORT, "rx_brb_discard" },
-	{ STATS_OFFSET32(brb_truncate_hi),
-				8, STATS_FLAGS_PORT, "rx_brb_truncate" },
-	{ STATS_OFFSET32(pause_frames_received_hi),
-				8, STATS_FLAGS_PORT, "rx_pause_frames" },
-	{ STATS_OFFSET32(rx_stat_maccontrolframesreceived_hi),
-				8, STATS_FLAGS_PORT, "rx_mac_ctrl_frames" },
-	{ STATS_OFFSET32(nig_timer_max),
-			4, STATS_FLAGS_PORT, "rx_constant_pause_events" },
-/* 20 */{ STATS_OFFSET32(rx_err_discard_pkt),
-				4, STATS_FLAGS_BOTH, "rx_phy_ip_err_discards"},
-	{ STATS_OFFSET32(rx_skb_alloc_failed),
-				4, STATS_FLAGS_BOTH, "rx_skb_alloc_discard" },
-	{ STATS_OFFSET32(hw_csum_err),
-				4, STATS_FLAGS_BOTH, "rx_csum_offload_errors" },
-
-	{ STATS_OFFSET32(total_bytes_transmitted_hi),
-				8, STATS_FLAGS_BOTH, "tx_bytes" },
-	{ STATS_OFFSET32(tx_stat_ifhcoutbadoctets_hi),
-				8, STATS_FLAGS_PORT, "tx_error_bytes" },
-	{ STATS_OFFSET32(total_unicast_packets_transmitted_hi),
-				8, STATS_FLAGS_BOTH, "tx_ucast_packets" },
-	{ STATS_OFFSET32(total_multicast_packets_transmitted_hi),
-				8, STATS_FLAGS_BOTH, "tx_mcast_packets" },
-	{ STATS_OFFSET32(total_broadcast_packets_transmitted_hi),
-				8, STATS_FLAGS_BOTH, "tx_bcast_packets" },
-	{ STATS_OFFSET32(tx_stat_dot3statsinternalmactransmiterrors_hi),
-				8, STATS_FLAGS_PORT, "tx_mac_errors" },
-	{ STATS_OFFSET32(rx_stat_dot3statscarriersenseerrors_hi),
-				8, STATS_FLAGS_PORT, "tx_carrier_errors" },
-/* 30 */{ STATS_OFFSET32(tx_stat_dot3statssinglecollisionframes_hi),
-				8, STATS_FLAGS_PORT, "tx_single_collisions" },
-	{ STATS_OFFSET32(tx_stat_dot3statsmultiplecollisionframes_hi),
-				8, STATS_FLAGS_PORT, "tx_multi_collisions" },
-	{ STATS_OFFSET32(tx_stat_dot3statsdeferredtransmissions_hi),
-				8, STATS_FLAGS_PORT, "tx_deferred" },
-	{ STATS_OFFSET32(tx_stat_dot3statsexcessivecollisions_hi),
-				8, STATS_FLAGS_PORT, "tx_excess_collisions" },
-	{ STATS_OFFSET32(tx_stat_dot3statslatecollisions_hi),
-				8, STATS_FLAGS_PORT, "tx_late_collisions" },
-	{ STATS_OFFSET32(tx_stat_etherstatscollisions_hi),
-				8, STATS_FLAGS_PORT, "tx_total_collisions" },
-	{ STATS_OFFSET32(tx_stat_etherstatspkts64octets_hi),
-				8, STATS_FLAGS_PORT, "tx_64_byte_packets" },
-	{ STATS_OFFSET32(tx_stat_etherstatspkts65octetsto127octets_hi),
-			8, STATS_FLAGS_PORT, "tx_65_to_127_byte_packets" },
-	{ STATS_OFFSET32(tx_stat_etherstatspkts128octetsto255octets_hi),
-			8, STATS_FLAGS_PORT, "tx_128_to_255_byte_packets" },
-	{ STATS_OFFSET32(tx_stat_etherstatspkts256octetsto511octets_hi),
-			8, STATS_FLAGS_PORT, "tx_256_to_511_byte_packets" },
-/* 40 */{ STATS_OFFSET32(tx_stat_etherstatspkts512octetsto1023octets_hi),
-			8, STATS_FLAGS_PORT, "tx_512_to_1023_byte_packets" },
-	{ STATS_OFFSET32(etherstatspkts1024octetsto1522octets_hi),
-			8, STATS_FLAGS_PORT, "tx_1024_to_1522_byte_packets" },
-	{ STATS_OFFSET32(etherstatspktsover1522octets_hi),
-			8, STATS_FLAGS_PORT, "tx_1523_to_9022_byte_packets" },
-	{ STATS_OFFSET32(pause_frames_sent_hi),
-				8, STATS_FLAGS_PORT, "tx_pause_frames" }
-};
-
 #define IS_PORT_STAT(i) \
 	((bnx2x_stats_arr[i].flags & STATS_FLAGS_BOTH) == STATS_FLAGS_PORT)
 #define IS_FUNC_STAT(i)		(bnx2x_stats_arr[i].flags & STATS_FLAGS_FUNC)
@@ -1929,7 +1938,8 @@ static int bnx2x_get_sset_count(struct net_device *dev, int stringset)
 	switch (stringset) {
 	case ETH_SS_STATS:
 		if (is_multi(bp)) {
-			num_stats = BNX2X_NUM_Q_STATS * bp->num_queues;
+			num_stats = BNX2X_NUM_STAT_QUEUES(bp) *
+				BNX2X_NUM_Q_STATS;
 			if (!IS_MF_MODE_STAT(bp))
 				num_stats += BNX2X_NUM_STATS;
 		} else {
@@ -1955,15 +1965,25 @@ static void bnx2x_get_strings(struct net_device *dev, u32 stringset, u8 *buf)
 {
 	struct bnx2x *bp = netdev_priv(dev);
 	int i, j, k;
+	char queue_name[MAX_QUEUE_NAME_LEN+1];
 
 	switch (stringset) {
 	case ETH_SS_STATS:
 		if (is_multi(bp)) {
 			k = 0;
-			for_each_queue(bp, i) {
+			for_each_napi_queue(bp, i) {
+				memset(queue_name, 0, sizeof(queue_name));
+
+				if (IS_FCOE_IDX(i))
+					sprintf(queue_name, "fcoe");
+				else
+					sprintf(queue_name, "%d", i);
+
 				for (j = 0; j < BNX2X_NUM_Q_STATS; j++)
-					sprintf(buf + (k + j)*ETH_GSTRING_LEN,
-						bnx2x_q_stats_arr[j].string, i);
+					snprintf(buf + (k + j)*ETH_GSTRING_LEN,
+						ETH_GSTRING_LEN,
+						bnx2x_q_stats_arr[j].string,
+						queue_name);
 				k += BNX2X_NUM_Q_STATS;
 			}
 			if (IS_MF_MODE_STAT(bp))
@@ -1997,7 +2017,7 @@ static void bnx2x_get_ethtool_stats(struct net_device *dev,
 
 	if (is_multi(bp)) {
 		k = 0;
-		for_each_queue(bp, i) {
+		for_each_napi_queue(bp, i) {
 			hw_stats = (u32 *)&bp->fp[i].eth_q_stats;
 			for (j = 0; j < BNX2X_NUM_Q_STATS; j++) {
 				if (bnx2x_q_stats_arr[j].size == 0) {
diff --git a/drivers/net/bnx2x/bnx2x_main.c b/drivers/net/bnx2x/bnx2x_main.c
index 1552fc3..6c70ee5 100644
--- a/drivers/net/bnx2x/bnx2x_main.c
+++ b/drivers/net/bnx2x/bnx2x_main.c
@@ -121,6 +121,10 @@ MODULE_PARM_DESC(debug, " Default debug msglevel");
 
 static struct workqueue_struct *bnx2x_wq;
 
+#ifdef BCM_CNIC
+static u8 ALL_ENODE_MACS[] = {0x01, 0x10, 0x18, 0x01, 0x00, 0x01};
+#endif
+
 enum bnx2x_board_type {
 	BCM57710 = 0,
 	BCM57711 = 1,
@@ -921,7 +925,7 @@ void bnx2x_panic_dump(struct bnx2x *bp)
 	       sp_sb_data.p_func.vf_valid);
 
 
-	for_each_queue(bp, i) {
+	for_each_eth_queue(bp, i) {
 		struct bnx2x_fastpath *fp = &bp->fp[i];
 		int loop;
 		struct hc_status_block_data_e2 sb_data_e2;
@@ -961,6 +965,10 @@ void bnx2x_panic_dump(struct bnx2x *bp)
 
 		/* host sb data */
 
+#ifdef BCM_CNIC
+		if (IS_FCOE_FP(fp))
+			continue;
+#endif
 		BNX2X_ERR("     run indexes (");
 		for (j = 0; j < HC_SB_MAX_SM; j++)
 			pr_cont("0x%x%s",
@@ -1029,7 +1037,7 @@ void bnx2x_panic_dump(struct bnx2x *bp)
 #ifdef BNX2X_STOP_ON_ERROR
 	/* Rings */
 	/* Rx */
-	for_each_queue(bp, i) {
+	for_each_rx_queue(bp, i) {
 		struct bnx2x_fastpath *fp = &bp->fp[i];
 
 		start = RX_BD(le16_to_cpu(*fp->rx_cons_sb) - 10);
@@ -1063,7 +1071,7 @@ void bnx2x_panic_dump(struct bnx2x *bp)
 	}
 
 	/* Tx */
-	for_each_queue(bp, i) {
+	for_each_tx_queue(bp, i) {
 		struct bnx2x_fastpath *fp = &bp->fp[i];
 
 		start = TX_BD(le16_to_cpu(*fp->tx_cons_sb) - 10);
@@ -1298,7 +1306,7 @@ void bnx2x_int_disable_sync(struct bnx2x *bp, int disable_hw)
 #ifdef BCM_CNIC
 		offset++;
 #endif
-		for_each_queue(bp, i)
+		for_each_eth_queue(bp, i)
 			synchronize_irq(bp->msix_table[i + offset].vector);
 	} else
 		synchronize_irq(bp->pdev->irq);
@@ -1420,7 +1428,7 @@ irqreturn_t bnx2x_interrupt(int irq, void *dev_instance)
 		return IRQ_HANDLED;
 #endif
 
-	for_each_queue(bp, i) {
+	for_each_eth_queue(bp, i) {
 		struct bnx2x_fastpath *fp = &bp->fp[i];
 
 		mask = 0x2 << (fp->index + CNIC_CONTEXT_USE);
@@ -2253,6 +2261,15 @@ u32 bnx2x_fw_command(struct bnx2x *bp, u32 command, u32 param)
 	return rc;
 }
 
+static u8 stat_counter_valid(struct bnx2x *bp, struct bnx2x_fastpath *fp)
+{
+#ifdef BCM_CNIC
+	if (IS_FCOE_FP(fp) && IS_MF(bp))
+		return false;
+#endif
+	return true;
+}
+
 /* must be called under rtnl_lock */
 static void bnx2x_rxq_set_mac_filters(struct bnx2x *bp, u16 cl_id, u32 filters)
 {
@@ -2411,7 +2428,8 @@ static inline u16 bnx2x_get_cl_flags(struct bnx2x *bp,
 	if (!fp->disable_tpa)
 		flags |= QUEUE_FLG_TPA;
 
-	flags |= QUEUE_FLG_STATS;
+	flags = stat_counter_valid(bp, fp) ?
+			(flags | QUEUE_FLG_STATS) : (flags & ~QUEUE_FLG_STATS);
 
 	return flags;
 }
@@ -2471,7 +2489,10 @@ static void bnx2x_pf_rx_cl_prep(struct bnx2x *bp,
 	rxq_init->cache_line_log = BNX2X_RX_ALIGN_SHIFT;
 	rxq_init->fw_sb_id = fp->fw_sb_id;
 
-	rxq_init->sb_cq_index = U_SB_ETH_RX_CQ_INDEX;
+	if (IS_FCOE_FP(fp))
+		rxq_init->sb_cq_index = HC_SP_INDEX_ETH_FCOE_RX_CQ_CONS;
+	else
+		rxq_init->sb_cq_index = U_SB_ETH_RX_CQ_INDEX;
 
 	rxq_init->cid = HW_CID(bp, fp->cid);
 
@@ -2491,6 +2512,12 @@ static void bnx2x_pf_tx_cl_prep(struct bnx2x *bp,
 	txq_init->sb_cq_index = C_SB_ETH_TX_CQ_INDEX;
 	txq_init->traffic_type = LLFC_TRAFFIC_TYPE_NW;
 	txq_init->fw_sb_id = fp->fw_sb_id;
+
+	if (IS_FCOE_FP(fp)) {
+		txq_init->sb_cq_index = HC_SP_INDEX_ETH_FCOE_TX_CQ_CONS;
+		txq_init->traffic_type = LLFC_TRAFFIC_TYPE_FCOE;
+	}
+
 	txq_init->hc_rate = bp->tx_ticks ? (1000000 / bp->tx_ticks) : 0;
 }
 
@@ -3689,8 +3716,11 @@ static void bnx2x_eq_int(struct bnx2x *bp)
 #ifdef BCM_CNIC
 			if (!bnx2x_cnic_handle_cfc_del(bp, cid, elem))
 				goto next_spqe;
+			if (cid == BNX2X_FCOE_ETH_CID)
+				bnx2x_fcoe(bp, state) = BNX2X_FP_STATE_CLOSED;
+			else
 #endif
-			bnx2x_fp(bp, cid, state) =
+				bnx2x_fp(bp, cid, state) =
 						BNX2X_FP_STATE_CLOSED;
 
 			goto next_spqe;
@@ -3766,7 +3796,13 @@ static void bnx2x_sp_task(struct work_struct *work)
 
 	/* SP events: STAT_QUERY and others */
 	if (status & BNX2X_DEF_SB_IDX) {
+#ifdef BCM_CNIC
+		struct bnx2x_fastpath *fp = bnx2x_fcoe_fp(bp);
 
+		if ((!NO_FCOE(bp)) &&
+			(bnx2x_has_rx_work(fp) || bnx2x_has_tx_work(fp)))
+			napi_schedule(&bnx2x_fcoe(bp, napi));
+#endif
 		/* Handle EQ completions */
 		bnx2x_eq_int(bp);
 
@@ -4149,7 +4185,7 @@ void bnx2x_update_coalesce(struct bnx2x *bp)
 {
 	int i;
 
-	for_each_queue(bp, i)
+	for_each_eth_queue(bp, i)
 		bnx2x_update_coalesce_sb(bp, bp->fp[i].fw_sb_id,
 					 bp->rx_ticks, bp->tx_ticks);
 }
@@ -4197,13 +4233,16 @@ static void bnx2x_init_ind_table(struct bnx2x *bp)
 	for (i = 0; i < TSTORM_INDIRECTION_TABLE_SIZE; i++)
 		REG_WR8(bp, BAR_TSTRORM_INTMEM +
 			TSTORM_INDIRECTION_TABLE_OFFSET(func) + i,
-			bp->fp->cl_id + (i % bp->num_queues));
+			bp->fp->cl_id + (i % (bp->num_queues -
+				NONE_ETH_CONTEXT_USE)));
 }
 
 void bnx2x_set_storm_rx_mode(struct bnx2x *bp)
 {
 	int mode = bp->rx_mode;
+	int port = BP_PORT(bp);
 	u16 cl_id;
+	u32 def_q_filters = 0;
 
 	/* All but management unicast packets should pass to the host as well */
 	u32 llh_mask =
@@ -4214,30 +4253,42 @@ void bnx2x_set_storm_rx_mode(struct bnx2x *bp)
 
 	switch (mode) {
 	case BNX2X_RX_MODE_NONE: /* no Rx */
-		cl_id = BP_L_ID(bp);
-		bnx2x_rxq_set_mac_filters(bp, cl_id, BNX2X_ACCEPT_NONE);
+		def_q_filters = BNX2X_ACCEPT_NONE;
+#ifdef BCM_CNIC
+		if (!NO_FCOE(bp)) {
+			cl_id = bnx2x_fcoe(bp, cl_id);
+			bnx2x_rxq_set_mac_filters(bp, cl_id, BNX2X_ACCEPT_NONE);
+		}
+#endif
 		break;
 
 	case BNX2X_RX_MODE_NORMAL:
-		cl_id = BP_L_ID(bp);
-		bnx2x_rxq_set_mac_filters(bp, cl_id,
-			BNX2X_ACCEPT_UNICAST |
-			BNX2X_ACCEPT_BROADCAST |
-			BNX2X_ACCEPT_MULTICAST);
+		def_q_filters |= BNX2X_ACCEPT_UNICAST | BNX2X_ACCEPT_BROADCAST |
+				BNX2X_ACCEPT_MULTICAST;
+#ifdef BCM_CNIC
+		cl_id = bnx2x_fcoe(bp, cl_id);
+		bnx2x_rxq_set_mac_filters(bp, cl_id, BNX2X_ACCEPT_UNICAST |
+					  BNX2X_ACCEPT_MULTICAST);
+#endif
 		break;
 
 	case BNX2X_RX_MODE_ALLMULTI:
-		cl_id = BP_L_ID(bp);
-		bnx2x_rxq_set_mac_filters(bp, cl_id,
-			BNX2X_ACCEPT_UNICAST |
-			BNX2X_ACCEPT_BROADCAST |
-			BNX2X_ACCEPT_ALL_MULTICAST);
+		def_q_filters |= BNX2X_ACCEPT_UNICAST | BNX2X_ACCEPT_BROADCAST |
+				BNX2X_ACCEPT_ALL_MULTICAST;
+#ifdef BCM_CNIC
+		cl_id = bnx2x_fcoe(bp, cl_id);
+		bnx2x_rxq_set_mac_filters(bp, cl_id, BNX2X_ACCEPT_UNICAST |
+					  BNX2X_ACCEPT_MULTICAST);
+#endif
 		break;
 
 	case BNX2X_RX_MODE_PROMISC:
-		cl_id = BP_L_ID(bp);
-		bnx2x_rxq_set_mac_filters(bp, cl_id, BNX2X_PROMISCUOUS_MODE);
-
+		def_q_filters |= BNX2X_PROMISCUOUS_MODE;
+#ifdef BCM_CNIC
+		cl_id = bnx2x_fcoe(bp, cl_id);
+		bnx2x_rxq_set_mac_filters(bp, cl_id, BNX2X_ACCEPT_UNICAST |
+					  BNX2X_ACCEPT_MULTICAST);
+#endif
 		/* pass management unicast packets as well */
 		llh_mask |= NIG_LLH0_BRB1_DRV_MASK_REG_LLH0_BRB1_DRV_MASK_UNCST;
 		break;
@@ -4247,20 +4298,24 @@ void bnx2x_set_storm_rx_mode(struct bnx2x *bp)
 		break;
 	}
 
+	cl_id = BP_L_ID(bp);
+	bnx2x_rxq_set_mac_filters(bp, cl_id, def_q_filters);
+
 	REG_WR(bp,
-	       BP_PORT(bp) ? NIG_REG_LLH1_BRB1_DRV_MASK :
-			     NIG_REG_LLH0_BRB1_DRV_MASK,
-	       llh_mask);
+	       (port ? NIG_REG_LLH1_BRB1_DRV_MASK :
+		       NIG_REG_LLH0_BRB1_DRV_MASK), llh_mask);
 
 	DP(NETIF_MSG_IFUP, "rx mode %d\n"
 		"drop_ucast 0x%x\ndrop_mcast 0x%x\ndrop_bcast 0x%x\n"
-		"accp_ucast 0x%x\naccp_mcast 0x%x\naccp_bcast 0x%x\n", mode,
+		"accp_ucast 0x%x\naccp_mcast 0x%x\naccp_bcast 0x%x\n"
+		"unmatched_ucast 0x%x\n", mode,
 		bp->mac_filters.ucast_drop_all,
 		bp->mac_filters.mcast_drop_all,
 		bp->mac_filters.bcast_drop_all,
 		bp->mac_filters.ucast_accept_all,
 		bp->mac_filters.mcast_accept_all,
-		bp->mac_filters.bcast_accept_all
+		bp->mac_filters.bcast_accept_all,
+		bp->mac_filters.unmatched_unicast
 	);
 
 	storm_memset_mac_filters(bp, &bp->mac_filters, BP_FUNC(bp));
@@ -4369,9 +4424,11 @@ void bnx2x_nic_init(struct bnx2x *bp, u32 load_code)
 {
 	int i;
 
-	for_each_queue(bp, i)
+	for_each_eth_queue(bp, i)
 		bnx2x_init_fp_sb(bp, i);
 #ifdef BCM_CNIC
+	if (!NO_FCOE(bp))
+		bnx2x_init_fcoe_fp(bp);
 
 	bnx2x_init_sb(bp, bp->cnic_sb_mapping,
 		      BNX2X_VF_ID_INVALID, false,
@@ -5877,6 +5934,15 @@ void bnx2x_free_mem(struct bnx2x *bp)
 	/* fastpath */
 	/* Common */
 	for_each_queue(bp, i) {
+#ifdef BCM_CNIC
+		/* FCoE client uses default status block */
+		if (IS_FCOE_IDX(i)) {
+			union host_hc_status_block *sb =
+				&bnx2x_fp(bp, i, status_blk);
+			memset(sb, 0, sizeof(union host_hc_status_block));
+			bnx2x_fp(bp, i, status_blk_mapping) = 0;
+		} else {
+#endif
 		/* status blocks */
 		if (CHIP_IS_E2(bp))
 			BNX2X_PCI_FREE(bnx2x_fp(bp, i, status_blk.e2_sb),
@@ -5886,9 +5952,12 @@ void bnx2x_free_mem(struct bnx2x *bp)
 			BNX2X_PCI_FREE(bnx2x_fp(bp, i, status_blk.e1x_sb),
 				       bnx2x_fp(bp, i, status_blk_mapping),
 				       sizeof(struct host_hc_status_block_e1x));
+#ifdef BCM_CNIC
+		}
+#endif
 	}
 	/* Rx */
-	for_each_queue(bp, i) {
+	for_each_rx_queue(bp, i) {
 
 		/* fastpath rx rings: rx_buf rx_desc rx_comp */
 		BNX2X_FREE(bnx2x_fp(bp, i, rx_buf_ring));
@@ -5908,7 +5977,7 @@ void bnx2x_free_mem(struct bnx2x *bp)
 			       BCM_PAGE_SIZE * NUM_RX_SGE_PAGES);
 	}
 	/* Tx */
-	for_each_queue(bp, i) {
+	for_each_tx_queue(bp, i) {
 
 		/* fastpath tx rings: tx_buf tx_desc */
 		BNX2X_FREE(bnx2x_fp(bp, i, tx_buf_ring));
@@ -5992,15 +6061,20 @@ int bnx2x_alloc_mem(struct bnx2x *bp)
 		union host_hc_status_block *sb = &bnx2x_fp(bp, i, status_blk);
 		bnx2x_fp(bp, i, bp) = bp;
 		/* status blocks */
-		if (CHIP_IS_E2(bp))
-			BNX2X_PCI_ALLOC(sb->e2_sb,
-				&bnx2x_fp(bp, i, status_blk_mapping),
-				sizeof(struct host_hc_status_block_e2));
-		else
-			BNX2X_PCI_ALLOC(sb->e1x_sb,
-				&bnx2x_fp(bp, i, status_blk_mapping),
-				sizeof(struct host_hc_status_block_e1x));
-
+#ifdef BCM_CNIC
+		if (!IS_FCOE_IDX(i)) {
+#endif
+			if (CHIP_IS_E2(bp))
+				BNX2X_PCI_ALLOC(sb->e2_sb,
+				    &bnx2x_fp(bp, i, status_blk_mapping),
+				    sizeof(struct host_hc_status_block_e2));
+			else
+				BNX2X_PCI_ALLOC(sb->e1x_sb,
+				    &bnx2x_fp(bp, i, status_blk_mapping),
+				    sizeof(struct host_hc_status_block_e1x));
+#ifdef BCM_CNIC
+		}
+#endif
 		set_sb_shortcuts(bp, i);
 	}
 	/* Rx */
@@ -6410,7 +6484,8 @@ static int bnx2x_set_iscsi_eth_mac_addr(struct bnx2x *bp, int set)
 {
 	u8 cam_offset = (CHIP_IS_E1(bp) ? ((BP_PORT(bp) ? 32 : 0) + 2) :
 			 bnx2x_e1h_cam_offset(bp, CAM_ISCSI_ETH_LINE));
-	u32 iscsi_l2_cl_id = BNX2X_ISCSI_ETH_CL_ID;
+	u32 iscsi_l2_cl_id = BNX2X_ISCSI_ETH_CL_ID +
+		BP_E1HVN(bp) * NONE_ETH_CONTEXT_USE;
 	u32 cl_bit_vec = (1 << iscsi_l2_cl_id);
 
 	/* Send a SET_MAC ramrod */
@@ -6418,6 +6493,50 @@ static int bnx2x_set_iscsi_eth_mac_addr(struct bnx2x *bp, int set)
 			       cam_offset, 0);
 
 	bnx2x_set_mac_in_nig(bp, set, bp->iscsi_mac, LLH_CAM_ISCSI_ETH_LINE);
+
+	return 0;
+}
+
+/**
+ * Set FCoE L2 MAC(s) at the next enties in the CAM after the
+ * ETH MAC(s). This function will wait until the ramdord
+ * completion returns.
+ *
+ * @param bp driver handle
+ * @param set set or clear the CAM entry
+ *
+ * @return 0 if cussess, -ENODEV if ramrod doesn't return.
+ */
+int bnx2x_set_fip_eth_mac_addr(struct bnx2x *bp, int set)
+{
+	u32 cl_bit_vec = (1 << bnx2x_fcoe(bp, cl_id));
+	/**
+	 * CAM allocation for E1H
+	 * eth unicasts: by func number
+	 * iscsi: by func number
+	 * fip unicast: by func number
+	 * fip multicast: by func number
+	 */
+	bnx2x_set_mac_addr_gen(bp, set, bp->fip_mac,
+		cl_bit_vec, bnx2x_e1h_cam_offset(bp, CAM_FIP_ETH_LINE), 0);
+
+	return 0;
+}
+
+int bnx2x_set_all_enode_macs(struct bnx2x *bp, int set)
+{
+	u32 cl_bit_vec = (1 << bnx2x_fcoe(bp, cl_id));
+
+	/**
+	 * CAM allocation for E1H
+	 * eth unicasts: by func number
+	 * iscsi: by func number
+	 * fip unicast: by func number
+	 * fip multicast: by func number
+	 */
+	bnx2x_set_mac_addr_gen(bp, set, ALL_ENODE_MACS,	cl_bit_vec,
+		bnx2x_e1h_cam_offset(bp, CAM_FIP_MCAST_LINE), 0);
+
 	return 0;
 }
 #endif
@@ -6435,6 +6554,8 @@ static void bnx2x_fill_cl_init_data(struct bnx2x *bp,
 	data->general.statistics_counter_id = params->rxq_params.stat_id;
 	data->general.statistics_en_flg =
 		(params->rxq_params.flags & QUEUE_FLG_STATS) ? 1 : 0;
+	data->general.is_fcoe_flg =
+		(params->ramrod_params.flags & CLIENT_IS_FCOE) ? 1 : 0;
 	data->general.activate_flg = activate;
 	data->general.sp_client_id = params->rxq_params.spcl_id;
 
@@ -6503,7 +6624,9 @@ static void bnx2x_fill_cl_init_data(struct bnx2x *bp,
 	data->fc.safc_group_num = params->txq_params.cos;
 	data->fc.safc_group_en_flg =
 		(params->txq_params.flags & QUEUE_FLG_COS) ? 1 : 0;
-	data->fc.traffic_type = LLFC_TRAFFIC_TYPE_NW;
+	data->fc.traffic_type =
+		(params->ramrod_params.flags & CLIENT_IS_FCOE) ?
+		LLFC_TRAFFIC_TYPE_FCOE : LLFC_TRAFFIC_TYPE_NW;
 }
 
 static inline void bnx2x_set_ctx_validation(struct eth_context *cxt, u32 cid)
@@ -6602,7 +6725,7 @@ static int __devinit bnx2x_set_int_mode(struct bnx2x *bp)
 		bnx2x_enable_msi(bp);
 		/* falling through... */
 	case INT_MODE_INTx:
-		bp->num_queues = 1;
+		bp->num_queues = 1 + NONE_ETH_CONTEXT_USE;
 		DP(NETIF_MSG_IFUP, "set number of queues to 1\n");
 		break;
 	default:
@@ -6625,8 +6748,8 @@ static int __devinit bnx2x_set_int_mode(struct bnx2x *bp)
 					  "enable MSI-X (%d), "
 					  "set number of queues to %d\n",
 				   bp->num_queues,
-				   1);
-			bp->num_queues = 1;
+				   1 + NONE_ETH_CONTEXT_USE);
+			bp->num_queues = 1 + NONE_ETH_CONTEXT_USE;
 
 			if (!(bp->flags & DISABLE_MSI_FLAG))
 				bnx2x_enable_msi(bp);
@@ -6747,7 +6870,9 @@ int bnx2x_setup_client(struct bnx2x *bp, struct bnx2x_fastpath *fp,
 	struct bnx2x_client_init_params params = { {0} };
 	int rc;
 
-	bnx2x_ack_sb(bp, fp->igu_sb_id, USTORM_ID, 0,
+	/* reset IGU state skip FCoE L2 queue */
+	if (!IS_FCOE_FP(fp))
+		bnx2x_ack_sb(bp, fp->igu_sb_id, USTORM_ID, 0,
 			     IGU_INT_ENABLE, 0);
 
 	params.ramrod_params.pstate = &fp->state;
@@ -6755,6 +6880,12 @@ int bnx2x_setup_client(struct bnx2x *bp, struct bnx2x_fastpath *fp,
 	params.ramrod_params.index = fp->index;
 	params.ramrod_params.cid = fp->cid;
 
+#ifdef BCM_CNIC
+	if (IS_FCOE_FP(fp))
+		params.ramrod_params.flags |= CLIENT_IS_FCOE;
+
+#endif
+
 	if (is_leading)
 		params.ramrod_params.flags |= CLIENT_IS_LEADING_RSS;
 
@@ -6839,7 +6970,7 @@ static void bnx2x_reset_func(struct bnx2x *bp)
 	REG_WR8(bp, BAR_USTRORM_INTMEM + USTORM_FUNC_EN_OFFSET(func), 0);
 
 	/* FP SBs */
-	for_each_queue(bp, i) {
+	for_each_eth_queue(bp, i) {
 		struct bnx2x_fastpath *fp = &bp->fp[i];
 		REG_WR8(bp,
 			BAR_CSTRORM_INTMEM +
@@ -6959,6 +7090,20 @@ static void bnx2x_reset_chip(struct bnx2x *bp, u32 reset_code)
 	}
 }
 
+#ifdef BCM_CNIC
+static inline void bnx2x_del_fcoe_eth_macs(struct bnx2x *bp)
+{
+	if (bp->flags & FCOE_MACS_SET) {
+		if (!IS_MF_SD(bp))
+			bnx2x_set_fip_eth_mac_addr(bp, 0);
+
+		bnx2x_set_all_enode_macs(bp, 0);
+
+		bp->flags &= ~FCOE_MACS_SET;
+	}
+}
+#endif
+
 void bnx2x_chip_cleanup(struct bnx2x *bp, int unload_mode)
 {
 	int port = BP_PORT(bp);
@@ -6966,7 +7111,7 @@ void bnx2x_chip_cleanup(struct bnx2x *bp, int unload_mode)
 	int i, cnt, rc;
 
 	/* Wait until tx fastpath tasks complete */
-	for_each_queue(bp, i) {
+	for_each_tx_queue(bp, i) {
 		struct bnx2x_fastpath *fp = &bp->fp[i];
 
 		cnt = 1000;
@@ -7006,13 +7151,7 @@ void bnx2x_chip_cleanup(struct bnx2x *bp, int unload_mode)
 	}
 
 #ifdef BCM_CNIC
-	/* Clear iSCSI L2 MAC */
-	mutex_lock(&bp->cnic_mutex);
-	if (bp->cnic_flags & BNX2X_CNIC_FLAG_MAC_SET) {
-		bnx2x_set_iscsi_eth_mac_addr(bp, 0);
-		bp->cnic_flags &= ~BNX2X_CNIC_FLAG_MAC_SET;
-	}
-	mutex_unlock(&bp->cnic_mutex);
+	bnx2x_del_fcoe_eth_macs(bp);
 #endif
 
 	if (unload_mode == UNLOAD_NORMAL)
@@ -7865,7 +8004,7 @@ static void __devinit bnx2x_get_igu_cam_info(struct bnx2x *bp)
 	bp->igu_sb_cnt = 0;
 	if (CHIP_INT_MODE_IS_BC(bp)) {
 		bp->igu_sb_cnt = min_t(u8, FP_SB_MAX_E1x,
-				       bp->l2_cid_count);
+				       NUM_IGU_SB_REQUIRED(bp->l2_cid_count));
 
 		bp->igu_base_sb = (CHIP_MODE_IS_4_PORT(bp) ? pfid : vn) *
 			FP_SB_MAX_E1x;
@@ -7896,7 +8035,8 @@ static void __devinit bnx2x_get_igu_cam_info(struct bnx2x *bp)
 			}
 		}
 	}
-	bp->igu_sb_cnt = min_t(u8, bp->igu_sb_cnt, bp->l2_cid_count);
+	bp->igu_sb_cnt = min_t(u8, bp->igu_sb_cnt,
+				   NUM_IGU_SB_REQUIRED(bp->l2_cid_count));
 	if (bp->igu_sb_cnt == 0)
 		BNX2X_ERR("CAM configuration error\n");
 }
@@ -8312,6 +8452,17 @@ static void __devinit bnx2x_get_mac_hwinfo(struct bnx2x *bp)
 	memcpy(bp->link_params.mac_addr, bp->dev->dev_addr, ETH_ALEN);
 	memcpy(bp->dev->perm_addr, bp->dev->dev_addr, ETH_ALEN);
 
+#ifdef BCM_CNIC
+	/* Inform the upper layers about FCoE MAC */
+	if (!CHIP_IS_E1x(bp)) {
+		if (IS_MF_SD(bp))
+			memcpy(bp->fip_mac, bp->dev->dev_addr,
+			       sizeof(bp->fip_mac));
+		else
+			memcpy(bp->fip_mac, bp->iscsi_mac,
+			       sizeof(bp->fip_mac));
+	}
+#endif
 }
 
 static int __devinit bnx2x_get_hwinfo(struct bnx2x *bp)
@@ -8328,7 +8479,8 @@ static int __devinit bnx2x_get_hwinfo(struct bnx2x *bp)
 
 		bp->igu_dsb_id = DEF_SB_IGU_ID;
 		bp->igu_base_sb = 0;
-		bp->igu_sb_cnt = min_t(u8, FP_SB_MAX_E1x, bp->l2_cid_count);
+		bp->igu_sb_cnt = min_t(u8, FP_SB_MAX_E1x,
+				       NUM_IGU_SB_REQUIRED(bp->l2_cid_count));
 	} else {
 		bp->common.int_block = INT_BLOCK_IGU;
 		val = REG_RD(bp, IGU_REG_BLOCK_CONFIGURATION);
@@ -9263,7 +9415,7 @@ static int __devinit bnx2x_init_one(struct pci_dev *pdev,
 		return -ENODEV;
 	}
 
-	cid_count += CNIC_CONTEXT_USE;
+	cid_count += NONE_ETH_CONTEXT_USE + CNIC_CONTEXT_USE;
 
 	/* dev zeroed in init_etherdev */
 	dev = alloc_etherdev_mq(sizeof(*bp), cid_count);
@@ -9292,6 +9444,13 @@ static int __devinit bnx2x_init_one(struct pci_dev *pdev,
 	/* calc qm_cid_count */
 	bp->qm_cid_count = bnx2x_set_qm_cid_count(bp, cid_count);
 
+#ifdef BCM_CNIC
+	/* disable FCOE L2 queue for E1x*/
+	if (CHIP_IS_E1x(bp))
+		bp->flags |= NO_FCOE_FLAG;
+
+#endif
+
 	/* Configure interupt mode: try to enable MSI-X/MSI if
 	 * needed, set bp->num_queues appropriately.
 	 */
@@ -9306,6 +9465,15 @@ static int __devinit bnx2x_init_one(struct pci_dev *pdev,
 		goto init_one_exit;
 	}
 
+#ifdef BCM_CNIC
+	if (!NO_FCOE(bp)) {
+		/* Add storage MAC address */
+		rtnl_lock();
+		dev_addr_add(bp->dev, bp->fip_mac, NETDEV_HW_ADDR_T_SAN);
+		rtnl_unlock();
+	}
+#endif
+
 	bnx2x_get_pcie_width_speed(bp, &pcie_width, &pcie_speed);
 
 	netdev_info(dev, "%s (%c%d) PCI-E x%d %s found at mem %lx,"
@@ -9349,6 +9517,15 @@ static void __devexit bnx2x_remove_one(struct pci_dev *pdev)
 	}
 	bp = netdev_priv(dev);
 
+#ifdef BCM_CNIC
+	/* Delete storage MAC address */
+	if (!NO_FCOE(bp)) {
+		rtnl_lock();
+		dev_addr_del(bp->dev, bp->fip_mac, NETDEV_HW_ADDR_T_SAN);
+		rtnl_unlock();
+	}
+#endif
+
 	unregister_netdev(dev);
 
 	/* Delete all NAPI objects */
@@ -9398,7 +9575,7 @@ static int bnx2x_eeh_nic_unload(struct bnx2x *bp)
 	/* Free SKBs, SGEs, TPA pool and driver internals */
 	bnx2x_free_skbs(bp);
 
-	for_each_queue(bp, i)
+	for_each_rx_queue(bp, i)
 		bnx2x_free_rx_sge_range(bp, bp->fp + i, NUM_RX_SGE);
 
 	bnx2x_free_mem(bp);
@@ -9625,7 +9802,8 @@ static void bnx2x_cnic_sp_post(struct bnx2x *bp, int count)
 				break;
 			else
 				atomic_dec(&bp->spq_left);
-		} else if (type == ISCSI_CONNECTION_TYPE) {
+		} else if ((type == ISCSI_CONNECTION_TYPE) ||
+			   (type == FCOE_CONNECTION_TYPE)) {
 			if (bp->cnic_spq_pending >=
 			    bp->cnic_eth_dev.max_kwqe_pending)
 				break;
@@ -9772,6 +9950,9 @@ static int bnx2x_drv_ctl(struct net_device *dev, struct drv_ctl_info *ctl)
 	case DRV_CTL_START_L2_CMD: {
 		u32 cli = ctl->data.ring.client_id;
 
+		/* Clear FCoE FIP and ALL ENODE MACs addresses first */
+		bnx2x_del_fcoe_eth_macs(bp);
+
 		/* Set iSCSI MAC address */
 		bnx2x_set_iscsi_eth_mac_addr(bp, 1);
 
@@ -9893,10 +10074,6 @@ static int bnx2x_unregister_cnic(struct net_device *dev)
 	struct cnic_eth_dev *cp = &bp->cnic_eth_dev;
 
 	mutex_lock(&bp->cnic_mutex);
-	if (bp->cnic_flags & BNX2X_CNIC_FLAG_MAC_SET) {
-		bp->cnic_flags &= ~BNX2X_CNIC_FLAG_MAC_SET;
-		bnx2x_set_iscsi_eth_mac_addr(bp, 0);
-	}
 	cp->drv_state = 0;
 	rcu_assign_pointer(bp->cnic_ops, NULL);
 	mutex_unlock(&bp->cnic_mutex);
@@ -9927,7 +10104,9 @@ struct cnic_eth_dev *bnx2x_cnic_probe(struct net_device *dev)
 	cp->drv_ctl = bnx2x_drv_ctl;
 	cp->drv_register_cnic = bnx2x_register_cnic;
 	cp->drv_unregister_cnic = bnx2x_unregister_cnic;
-	cp->iscsi_l2_client_id = BNX2X_ISCSI_ETH_CL_ID;
+	cp->fcoe_init_cid = BNX2X_FCOE_ETH_CID;
+	cp->iscsi_l2_client_id = BNX2X_ISCSI_ETH_CL_ID +
+		BP_E1HVN(bp) * NONE_ETH_CONTEXT_USE;
 	cp->iscsi_l2_cid = BNX2X_ISCSI_ETH_CID;
 
 	DP(BNX2X_MSG_SP, "page_size %d, tbl_offset %d, tbl_lines %d, "
diff --git a/drivers/net/bnx2x/bnx2x_stats.c b/drivers/net/bnx2x/bnx2x_stats.c
index 4733c83..6e4d9b1 100644
--- a/drivers/net/bnx2x/bnx2x_stats.c
+++ b/drivers/net/bnx2x/bnx2x_stats.c
@@ -160,7 +160,7 @@ static void bnx2x_storm_stats_post(struct bnx2x *bp)
 
 		ramrod_data.drv_counter = bp->stats_counter++;
 		ramrod_data.collect_port = bp->port.pmf ? 1 : 0;
-		for_each_queue(bp, i)
+		for_each_eth_queue(bp, i)
 			ramrod_data.ctr_id_vector |= (1 << bp->fp[i].cl_id);
 
 		rc = bnx2x_sp_post(bp, RAMROD_CMD_ID_COMMON_STAT_QUERY, 0,
@@ -766,7 +766,7 @@ static int bnx2x_storm_stats_update(struct bnx2x *bp)
 	estats->no_buff_discard_hi = 0;
 	estats->no_buff_discard_lo = 0;
 
-	for_each_queue(bp, i) {
+	for_each_eth_queue(bp, i) {
 		struct bnx2x_fastpath *fp = &bp->fp[i];
 		int cl_id = fp->cl_id;
 		struct tstorm_per_client_stats *tclient =
@@ -996,7 +996,7 @@ static void bnx2x_net_stats_update(struct bnx2x *bp)
 	nstats->tx_bytes = bnx2x_hilo(&estats->total_bytes_transmitted_hi);
 
 	tmp = estats->mac_discard;
-	for_each_queue(bp, i)
+	for_each_rx_queue(bp, i)
 		tmp += le32_to_cpu(bp->fp[i].old_tclient.checksum_discard);
 	nstats->rx_dropped = tmp;
 
@@ -1087,7 +1087,7 @@ static void bnx2x_stats_update(struct bnx2x *bp)
 		       bp->dev->name,
 		       estats->brb_drop_lo, estats->brb_truncate_lo);
 
-		for_each_queue(bp, i) {
+		for_each_eth_queue(bp, i) {
 			struct bnx2x_fastpath *fp = &bp->fp[i];
 			struct bnx2x_eth_q_stats *qstats = &fp->eth_q_stats;
 
@@ -1101,7 +1101,7 @@ static void bnx2x_stats_update(struct bnx2x *bp)
 			       fp->rx_calls, fp->rx_pkt);
 		}
 
-		for_each_queue(bp, i) {
+		for_each_eth_queue(bp, i) {
 			struct bnx2x_fastpath *fp = &bp->fp[i];
 			struct bnx2x_eth_q_stats *qstats = &fp->eth_q_stats;
 			struct netdev_queue *txq =
@@ -1381,7 +1381,8 @@ void bnx2x_stats_init(struct bnx2x *bp)
 		memset(&fp->eth_q_stats, 0, sizeof(struct bnx2x_eth_q_stats));
 	}
 
-	for_each_queue(bp, i) {
+	/* FW stats are currently collected for ETH clients only */
+	for_each_eth_queue(bp, i) {
 		/* Set initial stats counter in the stats ramrod data to -1 */
 		int cl_id = bp->fp[i].cl_id;
 
diff --git a/drivers/net/bnx2x/bnx2x_stats.h b/drivers/net/bnx2x/bnx2x_stats.h
index afd15ef..596798c 100644
--- a/drivers/net/bnx2x/bnx2x_stats.h
+++ b/drivers/net/bnx2x/bnx2x_stats.h
@@ -53,7 +53,6 @@ struct bnx2x_eth_q_stats {
 	u32 hw_csum_err;
 };
 
-#define BNX2X_NUM_Q_STATS		13
 #define Q_STATS_OFFSET32(stat_name) \
 			(offsetof(struct bnx2x_eth_q_stats, stat_name) / 4)
 
@@ -225,7 +224,6 @@ struct bnx2x_eth_stats {
 	u32 nig_timer_max;
 };
 
-#define BNX2X_NUM_STATS			43
 #define STATS_OFFSET32(stat_name) \
 			(offsetof(struct bnx2x_eth_stats, stat_name) / 4)
 
-- 
1.7.1




