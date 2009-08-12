From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [net-next 02/36] bnx2x: Using the new FW
Date: Wed, 12 Aug 2009 21:20:38 +0300
Message-ID: <1250101238.27379.153.camel@lb-tlvb-eilong>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Vladislav Zolotarov" <vladz@broadcom.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4825 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752715AbZHLSWq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Aug 2009 14:22:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The new FW improves the packets per second rate. It required a lot of change in
the FW which implies many changes in the driver to support it. It is now also
possible for the driver to use a separate MSI-X vector for Rx and Tx - this also
add some to the complicity of this change.

All things said - after this patch, practically all performance matrixes show
improvement.
Though Vladislav Zolotarov is not signed on this patch, he did most of the job
and deserves credit for that.

Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x.h         |   45 ++-
 drivers/net/bnx2x_fw_defs.h |  379 +++++++++++++-----
 drivers/net/bnx2x_hsi.h     |  361 +++++++++++++-----
 drivers/net/bnx2x_main.c    |  888 +++++++++++++++++++++++--------------------
 drivers/net/bnx2x_reg.h     |   60 ++--
 firmware/Makefile           |    2 +-
 6 files changed, 1075 insertions(+), 660 deletions(-)

diff --git a/drivers/net/bnx2x.h b/drivers/net/bnx2x.h
index 8bd80fc..16ccba8 100644
--- a/drivers/net/bnx2x.h
+++ b/drivers/net/bnx2x.h
@@ -142,6 +142,9 @@ struct sw_rx_bd {
 struct sw_tx_bd {
 	struct sk_buff	*skb;
 	u16		first_bd;
+	u8		flags;
+/* Set on the first BD descriptor when there is a split BD */
+#define BNX2X_TSO_SPLIT_BD		(1<<0)
 };
 
 struct sw_rx_page {
@@ -149,6 +152,11 @@ struct sw_rx_page {
 	DECLARE_PCI_UNMAP_ADDR(mapping)
 };
 
+union db_prod {
+	struct doorbell_set_prod data;
+	u32		raw;
+};
+
 
 /* MC hsi */
 #define BCM_PAGE_SHIFT			12
@@ -234,15 +242,14 @@ struct bnx2x_fastpath {
 
 	struct napi_struct	napi;
 
+	u8			is_rx_queue;
+
 	struct host_status_block *status_blk;
 	dma_addr_t		status_blk_mapping;
 
-	struct eth_tx_db_data	*hw_tx_prods;
-	dma_addr_t		tx_prods_mapping;
-
 	struct sw_tx_bd		*tx_buf_ring;
 
-	struct eth_tx_bd	*tx_desc_ring;
+	union eth_tx_bd_types	*tx_desc_ring;
 	dma_addr_t		tx_desc_mapping;
 
 	struct sw_rx_bd		*rx_buf_ring;	/* BDs mappings ring */
@@ -272,6 +279,8 @@ struct bnx2x_fastpath {
 	u8			cl_id;	/* eth client id */
 	u8			sb_id;	/* status block number in HW */
 
+	union db_prod		tx_db;
+
 	u16			tx_pkt_prod;
 	u16			tx_pkt_cons;
 	u16			tx_bd_prod;
@@ -309,21 +318,24 @@ struct bnx2x_fastpath {
 	struct xstorm_per_client_stats old_xclient;
 	struct bnx2x_eth_q_stats eth_q_stats;
 
-	char			name[IFNAMSIZ];
+	/* The size is calculated using the following:
+	     sizeof name field from netdev structure +
+	     4 ('-Xx-' string) +
+	     4 (for the digits and to make it DWORD aligned) */
+#define FP_NAME_SIZE		(sizeof(((struct net_device *)0)->name) + 8)
+	char			name[FP_NAME_SIZE];
 	struct bnx2x		*bp; /* parent */
 };
 
 #define bnx2x_fp(bp, nr, var)		(bp->fp[nr].var)
 
-#define BNX2X_HAS_WORK(fp)	(bnx2x_has_rx_work(fp) || bnx2x_has_tx_work(fp))
-
 
 /* MC hsi */
 #define MAX_FETCH_BD			13	/* HW max BDs per packet */
 #define RX_COPY_THRESH			92
 
 #define NUM_TX_RINGS			16
-#define TX_DESC_CNT		(BCM_PAGE_SIZE / sizeof(struct eth_tx_bd))
+#define TX_DESC_CNT		(BCM_PAGE_SIZE / sizeof(union eth_tx_bd_types))
 #define MAX_TX_DESC_CNT			(TX_DESC_CNT - 1)
 #define NUM_TX_BD			(TX_DESC_CNT * NUM_TX_RINGS)
 #define MAX_TX_BD			(NUM_TX_BD - 1)
@@ -395,7 +407,7 @@ struct bnx2x_fastpath {
 #define DPM_TRIGER_TYPE			0x40
 #define DOORBELL(bp, cid, val) \
 	do { \
-		writel((u32)val, (bp)->doorbells + (BCM_PAGE_SIZE * cid) + \
+		writel((u32)(val), bp->doorbells + (BCM_PAGE_SIZE * (cid)) + \
 		       DPM_TRIGER_TYPE); \
 	} while (0)
 
@@ -902,8 +914,6 @@ struct bnx2x {
 	u16			rx_quick_cons_trip;
 	u16			rx_ticks_int;
 	u16			rx_ticks;
-/* Maximal coalescing timeout in us */
-#define BNX2X_MAX_COALESCE_TOUT		(0xf0*12)
 
 	u32			lin_cnt;
 
@@ -985,19 +995,20 @@ struct bnx2x {
 };
 
 
-#define BNX2X_MAX_QUEUES(bp)	(IS_E1HMF(bp) ? (MAX_CONTEXT / E1HVN_MAX) : \
-						 MAX_CONTEXT)
-#define BNX2X_NUM_QUEUES(bp)	max(bp->num_rx_queues, bp->num_tx_queues)
-#define is_multi(bp)		(BNX2X_NUM_QUEUES(bp) > 1)
+#define BNX2X_MAX_QUEUES(bp)	(IS_E1HMF(bp) ? (MAX_CONTEXT/(2 * E1HVN_MAX)) \
+					      : (MAX_CONTEXT/2))
+#define BNX2X_NUM_QUEUES(bp)	(bp->num_rx_queues + bp->num_tx_queues)
+#define is_multi(bp)		(BNX2X_NUM_QUEUES(bp) > 2)
 
 #define for_each_rx_queue(bp, var) \
 			for (var = 0; var < bp->num_rx_queues; var++)
 #define for_each_tx_queue(bp, var) \
-			for (var = 0; var < bp->num_tx_queues; var++)
+			for (var = bp->num_rx_queues; \
+			     var < BNX2X_NUM_QUEUES(bp); var++)
 #define for_each_queue(bp, var) \
 			for (var = 0; var < BNX2X_NUM_QUEUES(bp); var++)
 #define for_each_nondefault_queue(bp, var) \
-			for (var = 1; var < BNX2X_NUM_QUEUES(bp); var++)
+			for (var = 1; var < bp->num_rx_queues; var++)
 
 
 void bnx2x_read_dmae(struct bnx2x *bp, u32 src_addr, u32 len32);
diff --git a/drivers/net/bnx2x_fw_defs.h b/drivers/net/bnx2x_fw_defs.h
index e2df238..931dcac 100644
--- a/drivers/net/bnx2x_fw_defs.h
+++ b/drivers/net/bnx2x_fw_defs.h
@@ -12,48 +12,117 @@
 	(IS_E1H_OFFSET ? 0x7000 : 0x1000)
 #define CSTORM_ASSERT_LIST_OFFSET(idx) \
 	(IS_E1H_OFFSET ? (0x7020 + (idx * 0x10)) : (0x1020 + (idx * 0x10)))
-#define CSTORM_DEF_SB_HC_DISABLE_OFFSET(function, index) \
-	(IS_E1H_OFFSET ? (0x8522 + ((function>>1) * 0x40) + \
-	((function&1) * 0x100) + (index * 0x4)) : (0x1922 + (function * \
+#define CSTORM_DEF_SB_HC_DISABLE_C_OFFSET(function, index) \
+	(IS_E1H_OFFSET ? (0x8622 + ((function>>1) * 0x40) + \
+	((function&1) * 0x100) + (index * 0x4)) : (0x3562 + (function * \
 	0x40) + (index * 0x4)))
-#define CSTORM_DEF_SB_HOST_SB_ADDR_OFFSET(function) \
-	(IS_E1H_OFFSET ? (0x8500 + ((function>>1) * 0x40) + \
-	((function&1) * 0x100)) : (0x1900 + (function * 0x40)))
-#define CSTORM_DEF_SB_HOST_STATUS_BLOCK_OFFSET(function) \
-	(IS_E1H_OFFSET ? (0x8508 + ((function>>1) * 0x40) + \
-	((function&1) * 0x100)) : (0x1908 + (function * 0x40)))
+#define CSTORM_DEF_SB_HC_DISABLE_U_OFFSET(function, index) \
+	(IS_E1H_OFFSET ? (0x8822 + ((function>>1) * 0x80) + \
+	((function&1) * 0x200) + (index * 0x4)) : (0x35e2 + (function * \
+	0x80) + (index * 0x4)))
+#define CSTORM_DEF_SB_HOST_SB_ADDR_C_OFFSET(function) \
+	(IS_E1H_OFFSET ? (0x8600 + ((function>>1) * 0x40) + \
+	((function&1) * 0x100)) : (0x3540 + (function * 0x40)))
+#define CSTORM_DEF_SB_HOST_SB_ADDR_U_OFFSET(function) \
+	(IS_E1H_OFFSET ? (0x8800 + ((function>>1) * 0x80) + \
+	((function&1) * 0x200)) : (0x35c0 + (function * 0x80)))
+#define CSTORM_DEF_SB_HOST_STATUS_BLOCK_C_OFFSET(function) \
+	(IS_E1H_OFFSET ? (0x8608 + ((function>>1) * 0x40) + \
+	((function&1) * 0x100)) : (0x3548 + (function * 0x40)))
+#define CSTORM_DEF_SB_HOST_STATUS_BLOCK_U_OFFSET(function) \
+	(IS_E1H_OFFSET ? (0x8808 + ((function>>1) * 0x80) + \
+	((function&1) * 0x200)) : (0x35c8 + (function * 0x80)))
 #define CSTORM_FUNCTION_MODE_OFFSET \
 	(IS_E1H_OFFSET ? 0x11e8 : 0xffffffff)
-#define CSTORM_HC_BTR_OFFSET(port) \
-	(IS_E1H_OFFSET ? (0x8704 + (port * 0xf0)) : (0x1984 + (port * 0xc0)))
-#define CSTORM_SB_HC_DISABLE_OFFSET(port, cpu_id, index) \
-	(IS_E1H_OFFSET ? (0x801a + (port * 0x280) + (cpu_id * 0x28) + \
-	(index * 0x4)) : (0x141a + (port * 0x280) + (cpu_id * 0x28) + \
+#define CSTORM_HC_BTR_C_OFFSET(port) \
+	(IS_E1H_OFFSET ? (0x8c04 + (port * 0xf0)) : (0x36c4 + (port * 0xc0)))
+#define CSTORM_HC_BTR_U_OFFSET(port) \
+	(IS_E1H_OFFSET ? (0x8de4 + (port * 0xf0)) : (0x3844 + (port * 0xc0)))
+#define CSTORM_ISCSI_CQ_SIZE_OFFSET(function) \
+	(IS_E1H_OFFSET ? (0x6680 + (function * 0x8)) : (0x25a0 + \
+	(function * 0x8)))
+#define CSTORM_ISCSI_CQ_SQN_SIZE_OFFSET(function) \
+	(IS_E1H_OFFSET ? (0x66c0 + (function * 0x8)) : (0x25b0 + \
+	(function * 0x8)))
+#define CSTORM_ISCSI_EQ_CONS_OFFSET(function, eqIdx) \
+	(IS_E1H_OFFSET ? (0x6040 + (function * 0xc0) + (eqIdx * 0x18)) : \
+	(0x2410 + (function * 0xc0) + (eqIdx * 0x18)))
+#define CSTORM_ISCSI_EQ_NEXT_EQE_ADDR_OFFSET(function, eqIdx) \
+	(IS_E1H_OFFSET ? (0x6044 + (function * 0xc0) + (eqIdx * 0x18)) : \
+	(0x2414 + (function * 0xc0) + (eqIdx * 0x18)))
+#define CSTORM_ISCSI_EQ_NEXT_PAGE_ADDR_OFFSET(function, eqIdx) \
+	(IS_E1H_OFFSET ? (0x604c + (function * 0xc0) + (eqIdx * 0x18)) : \
+	(0x241c + (function * 0xc0) + (eqIdx * 0x18)))
+#define CSTORM_ISCSI_EQ_NEXT_PAGE_ADDR_VALID_OFFSET(function, eqIdx) \
+	(IS_E1H_OFFSET ? (0x6057 + (function * 0xc0) + (eqIdx * 0x18)) : \
+	(0x2427 + (function * 0xc0) + (eqIdx * 0x18)))
+#define CSTORM_ISCSI_EQ_PROD_OFFSET(function, eqIdx) \
+	(IS_E1H_OFFSET ? (0x6042 + (function * 0xc0) + (eqIdx * 0x18)) : \
+	(0x2412 + (function * 0xc0) + (eqIdx * 0x18)))
+#define CSTORM_ISCSI_EQ_SB_INDEX_OFFSET(function, eqIdx) \
+	(IS_E1H_OFFSET ? (0x6056 + (function * 0xc0) + (eqIdx * 0x18)) : \
+	(0x2426 + (function * 0xc0) + (eqIdx * 0x18)))
+#define CSTORM_ISCSI_EQ_SB_NUM_OFFSET(function, eqIdx) \
+	(IS_E1H_OFFSET ? (0x6054 + (function * 0xc0) + (eqIdx * 0x18)) : \
+	(0x2424 + (function * 0xc0) + (eqIdx * 0x18)))
+#define CSTORM_ISCSI_HQ_SIZE_OFFSET(function) \
+	(IS_E1H_OFFSET ? (0x6640 + (function * 0x8)) : (0x2590 + \
+	(function * 0x8)))
+#define CSTORM_ISCSI_NUM_OF_TASKS_OFFSET(function) \
+	(IS_E1H_OFFSET ? (0x6004 + (function * 0x8)) : (0x2404 + \
+	(function * 0x8)))
+#define CSTORM_ISCSI_PAGE_SIZE_LOG_OFFSET(function) \
+	(IS_E1H_OFFSET ? (0x6002 + (function * 0x8)) : (0x2402 + \
+	(function * 0x8)))
+#define CSTORM_ISCSI_PAGE_SIZE_OFFSET(function) \
+	(IS_E1H_OFFSET ? (0x6000 + (function * 0x8)) : (0x2400 + \
+	(function * 0x8)))
+#define CSTORM_SB_HC_DISABLE_C_OFFSET(port, cpu_id, index) \
+	(IS_E1H_OFFSET ? (0x811a + (port * 0x280) + (cpu_id * 0x28) + \
+	(index * 0x4)) : (0x305a + (port * 0x280) + (cpu_id * 0x28) + \
+	(index * 0x4)))
+#define CSTORM_SB_HC_DISABLE_U_OFFSET(port, cpu_id, index) \
+	(IS_E1H_OFFSET ? (0xb01a + (port * 0x800) + (cpu_id * 0x80) + \
+	(index * 0x4)) : (0x401a + (port * 0x800) + (cpu_id * 0x80) + \
 	(index * 0x4)))
-#define CSTORM_SB_HC_TIMEOUT_OFFSET(port, cpu_id, index) \
-	(IS_E1H_OFFSET ? (0x8018 + (port * 0x280) + (cpu_id * 0x28) + \
-	(index * 0x4)) : (0x1418 + (port * 0x280) + (cpu_id * 0x28) + \
+#define CSTORM_SB_HC_TIMEOUT_C_OFFSET(port, cpu_id, index) \
+	(IS_E1H_OFFSET ? (0x8118 + (port * 0x280) + (cpu_id * 0x28) + \
+	(index * 0x4)) : (0x3058 + (port * 0x280) + (cpu_id * 0x28) + \
 	(index * 0x4)))
-#define CSTORM_SB_HOST_SB_ADDR_OFFSET(port, cpu_id) \
-	(IS_E1H_OFFSET ? (0x8000 + (port * 0x280) + (cpu_id * 0x28)) : \
-	(0x1400 + (port * 0x280) + (cpu_id * 0x28)))
-#define CSTORM_SB_HOST_STATUS_BLOCK_OFFSET(port, cpu_id) \
-	(IS_E1H_OFFSET ? (0x8008 + (port * 0x280) + (cpu_id * 0x28)) : \
-	(0x1408 + (port * 0x280) + (cpu_id * 0x28)))
+#define CSTORM_SB_HC_TIMEOUT_U_OFFSET(port, cpu_id, index) \
+	(IS_E1H_OFFSET ? (0xb018 + (port * 0x800) + (cpu_id * 0x80) + \
+	(index * 0x4)) : (0x4018 + (port * 0x800) + (cpu_id * 0x80) + \
+	(index * 0x4)))
+#define CSTORM_SB_HOST_SB_ADDR_C_OFFSET(port, cpu_id) \
+	(IS_E1H_OFFSET ? (0x8100 + (port * 0x280) + (cpu_id * 0x28)) : \
+	(0x3040 + (port * 0x280) + (cpu_id * 0x28)))
+#define CSTORM_SB_HOST_SB_ADDR_U_OFFSET(port, cpu_id) \
+	(IS_E1H_OFFSET ? (0xb000 + (port * 0x800) + (cpu_id * 0x80)) : \
+	(0x4000 + (port * 0x800) + (cpu_id * 0x80)))
+#define CSTORM_SB_HOST_STATUS_BLOCK_C_OFFSET(port, cpu_id) \
+	(IS_E1H_OFFSET ? (0x8108 + (port * 0x280) + (cpu_id * 0x28)) : \
+	(0x3048 + (port * 0x280) + (cpu_id * 0x28)))
+#define CSTORM_SB_HOST_STATUS_BLOCK_U_OFFSET(port, cpu_id) \
+	(IS_E1H_OFFSET ? (0xb008 + (port * 0x800) + (cpu_id * 0x80)) : \
+	(0x4008 + (port * 0x800) + (cpu_id * 0x80)))
+#define CSTORM_SB_STATUS_BLOCK_C_SIZE 0x10
+#define CSTORM_SB_STATUS_BLOCK_U_SIZE 0x60
 #define CSTORM_STATS_FLAGS_OFFSET(function) \
 	(IS_E1H_OFFSET ? (0x1108 + (function * 0x8)) : (0x5108 + \
 	(function * 0x8)))
 #define TSTORM_APPROXIMATE_MATCH_MULTICAST_FILTERING_OFFSET(function) \
-	(IS_E1H_OFFSET ? (0x31c0 + (function * 0x20)) : 0xffffffff)
+	(IS_E1H_OFFSET ? (0x3200 + (function * 0x20)) : 0xffffffff)
 #define TSTORM_ASSERT_LIST_INDEX_OFFSET \
 	(IS_E1H_OFFSET ? 0xa000 : 0x1000)
 #define TSTORM_ASSERT_LIST_OFFSET(idx) \
 	(IS_E1H_OFFSET ? (0xa020 + (idx * 0x10)) : (0x1020 + (idx * 0x10)))
 #define TSTORM_CLIENT_CONFIG_OFFSET(port, client_id) \
-	(IS_E1H_OFFSET ? (0x3350 + (port * 0x190) + (client_id * 0x10)) \
-	: (0x9c0 + (port * 0x130) + (client_id * 0x10)))
+	(IS_E1H_OFFSET ? (0x33a0 + (port * 0x1a0) + (client_id * 0x10)) \
+	: (0x9c0 + (port * 0x120) + (client_id * 0x10)))
 #define TSTORM_COMMON_SAFC_WORKAROUND_ENABLE_OFFSET \
-	(IS_E1H_OFFSET ? 0x1ad8 : 0xffffffff)
+	(IS_E1H_OFFSET ? 0x1ed8 : 0xffffffff)
+#define TSTORM_COMMON_SAFC_WORKAROUND_TIMEOUT_10USEC_OFFSET \
+	(IS_E1H_OFFSET ? 0x1eda : 0xffffffff)
 #define TSTORM_DEF_SB_HC_DISABLE_OFFSET(function, index) \
 	(IS_E1H_OFFSET ? (0xb01a + ((function>>1) * 0x28) + \
 	((function&1) * 0xa0) + (index * 0x4)) : (0x141a + (function * \
@@ -65,95 +134,133 @@
 	(IS_E1H_OFFSET ? (0xb008 + ((function>>1) * 0x28) + \
 	((function&1) * 0xa0)) : (0x1408 + (function * 0x28)))
 #define TSTORM_ETH_STATS_QUERY_ADDR_OFFSET(function) \
-	(IS_E1H_OFFSET ? (0x2b80 + (function * 0x8)) : (0x4b68 + \
+	(IS_E1H_OFFSET ? (0x2940 + (function * 0x8)) : (0x4928 + \
 	(function * 0x8)))
 #define TSTORM_FUNCTION_COMMON_CONFIG_OFFSET(function) \
-	(IS_E1H_OFFSET ? (0x3000 + (function * 0x38)) : (0x1500 + \
-	(function * 0x38)))
+	(IS_E1H_OFFSET ? (0x3000 + (function * 0x40)) : (0x1500 + \
+	(function * 0x40)))
 #define TSTORM_FUNCTION_MODE_OFFSET \
-	(IS_E1H_OFFSET ? 0x1ad0 : 0xffffffff)
+	(IS_E1H_OFFSET ? 0x1ed0 : 0xffffffff)
 #define TSTORM_HC_BTR_OFFSET(port) \
 	(IS_E1H_OFFSET ? (0xb144 + (port * 0x30)) : (0x1454 + (port * 0x18)))
 #define TSTORM_INDIRECTION_TABLE_OFFSET(function) \
 	(IS_E1H_OFFSET ? (0x12c8 + (function * 0x80)) : (0x22c8 + \
 	(function * 0x80)))
 #define TSTORM_INDIRECTION_TABLE_SIZE 0x80
+#define TSTORM_ISCSI_CONN_BUF_PBL_OFFSET(function, pblEntry) \
+	(IS_E1H_OFFSET ? (0x60c0 + (function * 0x40) + (pblEntry * 0x8)) \
+	: (0x4c30 + (function * 0x40) + (pblEntry * 0x8)))
+#define TSTORM_ISCSI_ERROR_BITMAP_OFFSET(function) \
+	(IS_E1H_OFFSET ? (0x6340 + (function * 0x8)) : (0x4cd0 + \
+	(function * 0x8)))
+#define TSTORM_ISCSI_NUM_OF_TASKS_OFFSET(function) \
+	(IS_E1H_OFFSET ? (0x6004 + (function * 0x8)) : (0x4c04 + \
+	(function * 0x8)))
+#define TSTORM_ISCSI_PAGE_SIZE_LOG_OFFSET(function) \
+	(IS_E1H_OFFSET ? (0x6002 + (function * 0x8)) : (0x4c02 + \
+	(function * 0x8)))
+#define TSTORM_ISCSI_PAGE_SIZE_OFFSET(function) \
+	(IS_E1H_OFFSET ? (0x6000 + (function * 0x8)) : (0x4c00 + \
+	(function * 0x8)))
+#define TSTORM_ISCSI_RQ_SIZE_OFFSET(function) \
+	(IS_E1H_OFFSET ? (0x6080 + (function * 0x8)) : (0x4c20 + \
+	(function * 0x8)))
+#define TSTORM_ISCSI_TCP_VARS_FLAGS_OFFSET(function) \
+	(IS_E1H_OFFSET ? (0x6040 + (function * 0x8)) : (0x4c10 + \
+	(function * 0x8)))
+#define TSTORM_ISCSI_TCP_VARS_LSB_LOCAL_MAC_ADDR_OFFSET(function) \
+	(IS_E1H_OFFSET ? (0x6042 + (function * 0x8)) : (0x4c12 + \
+	(function * 0x8)))
+#define TSTORM_ISCSI_TCP_VARS_MSB_LOCAL_MAC_ADDR_OFFSET(function) \
+	(IS_E1H_OFFSET ? (0x6044 + (function * 0x8)) : (0x4c14 + \
+	(function * 0x8)))
 #define TSTORM_MAC_FILTER_CONFIG_OFFSET(function) \
-	(IS_E1H_OFFSET ? (0x3008 + (function * 0x38)) : (0x1508 + \
-	(function * 0x38)))
+	(IS_E1H_OFFSET ? (0x3008 + (function * 0x40)) : (0x1508 + \
+	(function * 0x40)))
 #define TSTORM_PER_COUNTER_ID_STATS_OFFSET(port, stats_counter_id) \
-	(IS_E1H_OFFSET ? (0x2010 + (port * 0x5b0) + (stats_counter_id * \
-	0x50)) : (0x4080 + (port * 0x5b0) + (stats_counter_id * 0x50)))
+	(IS_E1H_OFFSET ? (0x2010 + (port * 0x490) + (stats_counter_id * \
+	0x40)) : (0x4010 + (port * 0x490) + (stats_counter_id * 0x40)))
 #define TSTORM_STATS_FLAGS_OFFSET(function) \
-	(IS_E1H_OFFSET ? (0x2c00 + (function * 0x8)) : (0x4b88 + \
+	(IS_E1H_OFFSET ? (0x29c0 + (function * 0x8)) : (0x4948 + \
 	(function * 0x8)))
-#define TSTORM_TPA_EXIST_OFFSET (IS_E1H_OFFSET ? 0x3680 : 0x1c20)
-#define USTORM_AGG_DATA_OFFSET (IS_E1H_OFFSET ? 0xa040 : 0x2c10)
-#define USTORM_AGG_DATA_SIZE (IS_E1H_OFFSET ? 0x2440 : 0x1200)
+#define TSTORM_TCP_MAX_CWND_OFFSET(function) \
+	(IS_E1H_OFFSET ? (0x4004 + (function * 0x8)) : (0x1fb4 + \
+	(function * 0x8)))
+#define USTORM_AGG_DATA_OFFSET (IS_E1H_OFFSET ? 0xa000 : 0x3000)
+#define USTORM_AGG_DATA_SIZE (IS_E1H_OFFSET ? 0x2000 : 0x1000)
 #define USTORM_ASSERT_LIST_INDEX_OFFSET \
-	(IS_E1H_OFFSET ? 0x8960 : 0x1000)
+	(IS_E1H_OFFSET ? 0x8000 : 0x1000)
 #define USTORM_ASSERT_LIST_OFFSET(idx) \
-	(IS_E1H_OFFSET ? (0x8980 + (idx * 0x10)) : (0x1020 + (idx * 0x10)))
+	(IS_E1H_OFFSET ? (0x8020 + (idx * 0x10)) : (0x1020 + (idx * 0x10)))
 #define USTORM_CQE_PAGE_BASE_OFFSET(port, clientId) \
-	(IS_E1H_OFFSET ? (0x8018 + (port * 0x4b0) + (clientId * 0x30)) : \
-	(0x5330 + (port * 0x260) + (clientId * 0x20)))
-#define USTORM_DEF_SB_HC_DISABLE_OFFSET(function, index) \
-	(IS_E1H_OFFSET ? (0x9522 + ((function>>1) * 0x40) + \
-	((function&1) * 0x100) + (index * 0x4)) : (0x1922 + (function * \
-	0x40) + (index * 0x4)))
-#define USTORM_DEF_SB_HOST_SB_ADDR_OFFSET(function) \
-	(IS_E1H_OFFSET ? (0x9500 + ((function>>1) * 0x40) + \
-	((function&1) * 0x100)) : (0x1900 + (function * 0x40)))
-#define USTORM_DEF_SB_HOST_STATUS_BLOCK_OFFSET(function) \
-	(IS_E1H_OFFSET ? (0x9508 + ((function>>1) * 0x40) + \
-	((function&1) * 0x100)) : (0x1908 + (function * 0x40)))
+	(IS_E1H_OFFSET ? (0x1010 + (port * 0x680) + (clientId * 0x40)) : \
+	(0x4010 + (port * 0x360) + (clientId * 0x30)))
+#define USTORM_CQE_PAGE_NEXT_OFFSET(port, clientId) \
+	(IS_E1H_OFFSET ? (0x1028 + (port * 0x680) + (clientId * 0x40)) : \
+	(0x4028 + (port * 0x360) + (clientId * 0x30)))
+#define USTORM_ETH_PAUSE_ENABLED_OFFSET(port) \
+	(IS_E1H_OFFSET ? (0x2ad4 + (port * 0x8)) : 0xffffffff)
 #define USTORM_ETH_RING_PAUSE_DATA_OFFSET(port, clientId) \
-	(IS_E1H_OFFSET ? (0x8020 + (port * 0x4b0) + (clientId * 0x30)) : \
+	(IS_E1H_OFFSET ? (0x1030 + (port * 0x680) + (clientId * 0x40)) : \
 	0xffffffff)
 #define USTORM_ETH_STATS_QUERY_ADDR_OFFSET(function) \
-	(IS_E1H_OFFSET ? (0x2a50 + (function * 0x8)) : (0x1d98 + \
+	(IS_E1H_OFFSET ? (0x2a50 + (function * 0x8)) : (0x1dd0 + \
 	(function * 0x8)))
 #define USTORM_FUNCTION_MODE_OFFSET \
 	(IS_E1H_OFFSET ? 0x2448 : 0xffffffff)
-#define USTORM_HC_BTR_OFFSET(port) \
-	(IS_E1H_OFFSET ? (0x9704 + (port * 0xf0)) : (0x1984 + (port * 0xc0)))
+#define USTORM_ISCSI_CQ_SIZE_OFFSET(function) \
+	(IS_E1H_OFFSET ? (0x7044 + (function * 0x8)) : (0x2414 + \
+	(function * 0x8)))
+#define USTORM_ISCSI_CQ_SQN_SIZE_OFFSET(function) \
+	(IS_E1H_OFFSET ? (0x7046 + (function * 0x8)) : (0x2416 + \
+	(function * 0x8)))
+#define USTORM_ISCSI_ERROR_BITMAP_OFFSET(function) \
+	(IS_E1H_OFFSET ? (0x7688 + (function * 0x8)) : (0x29c8 + \
+	(function * 0x8)))
+#define USTORM_ISCSI_GLOBAL_BUF_PHYS_ADDR_OFFSET(function) \
+	(IS_E1H_OFFSET ? (0x7648 + (function * 0x8)) : (0x29b8 + \
+	(function * 0x8)))
+#define USTORM_ISCSI_NUM_OF_TASKS_OFFSET(function) \
+	(IS_E1H_OFFSET ? (0x7004 + (function * 0x8)) : (0x2404 + \
+	(function * 0x8)))
+#define USTORM_ISCSI_PAGE_SIZE_LOG_OFFSET(function) \
+	(IS_E1H_OFFSET ? (0x7002 + (function * 0x8)) : (0x2402 + \
+	(function * 0x8)))
+#define USTORM_ISCSI_PAGE_SIZE_OFFSET(function) \
+	(IS_E1H_OFFSET ? (0x7000 + (function * 0x8)) : (0x2400 + \
+	(function * 0x8)))
+#define USTORM_ISCSI_R2TQ_SIZE_OFFSET(function) \
+	(IS_E1H_OFFSET ? (0x7040 + (function * 0x8)) : (0x2410 + \
+	(function * 0x8)))
+#define USTORM_ISCSI_RQ_BUFFER_SIZE_OFFSET(function) \
+	(IS_E1H_OFFSET ? (0x7080 + (function * 0x8)) : (0x2420 + \
+	(function * 0x8)))
+#define USTORM_ISCSI_RQ_SIZE_OFFSET(function) \
+	(IS_E1H_OFFSET ? (0x7084 + (function * 0x8)) : (0x2424 + \
+	(function * 0x8)))
 #define USTORM_MAX_AGG_SIZE_OFFSET(port, clientId) \
-	(IS_E1H_OFFSET ? (0x8010 + (port * 0x4b0) + (clientId * 0x30)) : \
-	(0x5328 + (port * 0x260) + (clientId * 0x20)))
+	(IS_E1H_OFFSET ? (0x1018 + (port * 0x680) + (clientId * 0x40)) : \
+	(0x4018 + (port * 0x360) + (clientId * 0x30)))
 #define USTORM_MEM_WORKAROUND_ADDRESS_OFFSET(function) \
-	(IS_E1H_OFFSET ? (0x2408 + (function * 0x8)) : (0x5308 + \
+	(IS_E1H_OFFSET ? (0x2408 + (function * 0x8)) : (0x1da8 + \
 	(function * 0x8)))
-#define USTORM_PAUSE_ENABLED_OFFSET(port) \
-	(IS_E1H_OFFSET ? (0x2ad4 + (port * 0x8)) : 0xffffffff)
 #define USTORM_PER_COUNTER_ID_STATS_OFFSET(port, stats_counter_id) \
 	(IS_E1H_OFFSET ? (0x2450 + (port * 0x2d0) + (stats_counter_id * \
-	0x28)) : (0x4740 + (port * 0x2d0) + (stats_counter_id * 0x28)))
+	0x28)) : (0x1500 + (port * 0x2d0) + (stats_counter_id * 0x28)))
 #define USTORM_RX_PRODS_OFFSET(port, client_id) \
-	(IS_E1H_OFFSET ? (0x8000 + (port * 0x4b0) + (client_id * 0x30)) \
-	: (0x5318 + (port * 0x260) + (client_id * 0x20)))
-#define USTORM_SB_HC_DISABLE_OFFSET(port, cpu_id, index) \
-	(IS_E1H_OFFSET ? (0x901a + (port * 0x280) + (cpu_id * 0x28) + \
-	(index * 0x4)) : (0x141a + (port * 0x280) + (cpu_id * 0x28) + \
-	(index * 0x4)))
-#define USTORM_SB_HC_TIMEOUT_OFFSET(port, cpu_id, index) \
-	(IS_E1H_OFFSET ? (0x9018 + (port * 0x280) + (cpu_id * 0x28) + \
-	(index * 0x4)) : (0x1418 + (port * 0x280) + (cpu_id * 0x28) + \
-	(index * 0x4)))
-#define USTORM_SB_HOST_SB_ADDR_OFFSET(port, cpu_id) \
-	(IS_E1H_OFFSET ? (0x9000 + (port * 0x280) + (cpu_id * 0x28)) : \
-	(0x1400 + (port * 0x280) + (cpu_id * 0x28)))
-#define USTORM_SB_HOST_STATUS_BLOCK_OFFSET(port, cpu_id) \
-	(IS_E1H_OFFSET ? (0x9008 + (port * 0x280) + (cpu_id * 0x28)) : \
-	(0x1408 + (port * 0x280) + (cpu_id * 0x28)))
+	(IS_E1H_OFFSET ? (0x1000 + (port * 0x680) + (client_id * 0x40)) \
+	: (0x4000 + (port * 0x360) + (client_id * 0x30)))
 #define USTORM_STATS_FLAGS_OFFSET(function) \
-	(IS_E1H_OFFSET ? (0x29f0 + (function * 0x8)) : (0x1d80 + \
+	(IS_E1H_OFFSET ? (0x29f0 + (function * 0x8)) : (0x1db8 + \
 	(function * 0x8)))
+#define USTORM_TPA_BTR_OFFSET (IS_E1H_OFFSET ? 0x3da5 : 0x5095)
+#define USTORM_TPA_BTR_SIZE 0x1
 #define XSTORM_ASSERT_LIST_INDEX_OFFSET \
 	(IS_E1H_OFFSET ? 0x9000 : 0x1000)
 #define XSTORM_ASSERT_LIST_OFFSET(idx) \
 	(IS_E1H_OFFSET ? (0x9020 + (idx * 0x10)) : (0x1020 + (idx * 0x10)))
 #define XSTORM_CMNG_PER_PORT_VARS_OFFSET(port) \
-	(IS_E1H_OFFSET ? (0x24a8 + (port * 0x50)) : (0x3ba0 + (port * 0x50)))
+	(IS_E1H_OFFSET ? (0x24a8 + (port * 0x50)) : (0x3a80 + (port * 0x50)))
 #define XSTORM_DEF_SB_HC_DISABLE_OFFSET(function, index) \
 	(IS_E1H_OFFSET ? (0xa01a + ((function>>1) * 0x28) + \
 	((function&1) * 0xa0) + (index * 0x4)) : (0x141a + (function * \
@@ -165,22 +272,73 @@
 	(IS_E1H_OFFSET ? (0xa008 + ((function>>1) * 0x28) + \
 	((function&1) * 0xa0)) : (0x1408 + (function * 0x28)))
 #define XSTORM_E1HOV_OFFSET(function) \
-	(IS_E1H_OFFSET ? (0x2c10 + (function * 0x2)) : 0xffffffff)
+	(IS_E1H_OFFSET ? (0x2c10 + (function * 0x8)) : 0xffffffff)
 #define XSTORM_ETH_STATS_QUERY_ADDR_OFFSET(function) \
-	(IS_E1H_OFFSET ? (0x2418 + (function * 0x8)) : (0x3b70 + \
+	(IS_E1H_OFFSET ? (0x2418 + (function * 0x8)) : (0x3a50 + \
 	(function * 0x8)))
 #define XSTORM_FAIRNESS_PER_VN_VARS_OFFSET(function) \
-	(IS_E1H_OFFSET ? (0x2588 + (function * 0x90)) : (0x3c80 + \
+	(IS_E1H_OFFSET ? (0x2588 + (function * 0x90)) : (0x3b60 + \
 	(function * 0x90)))
 #define XSTORM_FUNCTION_MODE_OFFSET \
-	(IS_E1H_OFFSET ? 0x2c20 : 0xffffffff)
+	(IS_E1H_OFFSET ? 0x2c50 : 0xffffffff)
 #define XSTORM_HC_BTR_OFFSET(port) \
 	(IS_E1H_OFFSET ? (0xa144 + (port * 0x30)) : (0x1454 + (port * 0x18)))
+#define XSTORM_ISCSI_HQ_SIZE_OFFSET(function) \
+	(IS_E1H_OFFSET ? (0x80c0 + (function * 0x8)) : (0x1c30 + \
+	(function * 0x8)))
+#define XSTORM_ISCSI_LOCAL_MAC_ADDR0_OFFSET(function) \
+	(IS_E1H_OFFSET ? (0x8080 + (function * 0x8)) : (0x1c20 + \
+	(function * 0x8)))
+#define XSTORM_ISCSI_LOCAL_MAC_ADDR1_OFFSET(function) \
+	(IS_E1H_OFFSET ? (0x8081 + (function * 0x8)) : (0x1c21 + \
+	(function * 0x8)))
+#define XSTORM_ISCSI_LOCAL_MAC_ADDR2_OFFSET(function) \
+	(IS_E1H_OFFSET ? (0x8082 + (function * 0x8)) : (0x1c22 + \
+	(function * 0x8)))
+#define XSTORM_ISCSI_LOCAL_MAC_ADDR3_OFFSET(function) \
+	(IS_E1H_OFFSET ? (0x8083 + (function * 0x8)) : (0x1c23 + \
+	(function * 0x8)))
+#define XSTORM_ISCSI_LOCAL_MAC_ADDR4_OFFSET(function) \
+	(IS_E1H_OFFSET ? (0x8084 + (function * 0x8)) : (0x1c24 + \
+	(function * 0x8)))
+#define XSTORM_ISCSI_LOCAL_MAC_ADDR5_OFFSET(function) \
+	(IS_E1H_OFFSET ? (0x8085 + (function * 0x8)) : (0x1c25 + \
+	(function * 0x8)))
+#define XSTORM_ISCSI_LOCAL_VLAN_OFFSET(function) \
+	(IS_E1H_OFFSET ? (0x8086 + (function * 0x8)) : (0x1c26 + \
+	(function * 0x8)))
+#define XSTORM_ISCSI_NUM_OF_TASKS_OFFSET(function) \
+	(IS_E1H_OFFSET ? (0x8004 + (function * 0x8)) : (0x1c04 + \
+	(function * 0x8)))
+#define XSTORM_ISCSI_PAGE_SIZE_LOG_OFFSET(function) \
+	(IS_E1H_OFFSET ? (0x8002 + (function * 0x8)) : (0x1c02 + \
+	(function * 0x8)))
+#define XSTORM_ISCSI_PAGE_SIZE_OFFSET(function) \
+	(IS_E1H_OFFSET ? (0x8000 + (function * 0x8)) : (0x1c00 + \
+	(function * 0x8)))
+#define XSTORM_ISCSI_R2TQ_SIZE_OFFSET(function) \
+	(IS_E1H_OFFSET ? (0x80c4 + (function * 0x8)) : (0x1c34 + \
+	(function * 0x8)))
+#define XSTORM_ISCSI_SQ_SIZE_OFFSET(function) \
+	(IS_E1H_OFFSET ? (0x80c2 + (function * 0x8)) : (0x1c32 + \
+	(function * 0x8)))
+#define XSTORM_ISCSI_TCP_VARS_ADV_WND_SCL_OFFSET(function) \
+	(IS_E1H_OFFSET ? (0x8043 + (function * 0x8)) : (0x1c13 + \
+	(function * 0x8)))
+#define XSTORM_ISCSI_TCP_VARS_FLAGS_OFFSET(function) \
+	(IS_E1H_OFFSET ? (0x8042 + (function * 0x8)) : (0x1c12 + \
+	(function * 0x8)))
+#define XSTORM_ISCSI_TCP_VARS_TOS_OFFSET(function) \
+	(IS_E1H_OFFSET ? (0x8041 + (function * 0x8)) : (0x1c11 + \
+	(function * 0x8)))
+#define XSTORM_ISCSI_TCP_VARS_TTL_OFFSET(function) \
+	(IS_E1H_OFFSET ? (0x8040 + (function * 0x8)) : (0x1c10 + \
+	(function * 0x8)))
 #define XSTORM_PER_COUNTER_ID_STATS_OFFSET(port, stats_counter_id) \
-	(IS_E1H_OFFSET ? (0xc000 + (port * 0x3f0) + (stats_counter_id * \
-	0x38)) : (0x3378 + (port * 0x3f0) + (stats_counter_id * 0x38)))
+	(IS_E1H_OFFSET ? (0xc000 + (port * 0x360) + (stats_counter_id * \
+	0x30)) : (0x3378 + (port * 0x360) + (stats_counter_id * 0x30)))
 #define XSTORM_RATE_SHAPING_PER_VN_VARS_OFFSET(function) \
-	(IS_E1H_OFFSET ? (0x2548 + (function * 0x90)) : (0x3c40 + \
+	(IS_E1H_OFFSET ? (0x2548 + (function * 0x90)) : (0x3b20 + \
 	(function * 0x90)))
 #define XSTORM_SPQ_PAGE_BASE_OFFSET(function) \
 	(IS_E1H_OFFSET ? (0x2000 + (function * 0x10)) : (0x3328 + \
@@ -189,8 +347,15 @@
 	(IS_E1H_OFFSET ? (0x2008 + (function * 0x10)) : (0x3330 + \
 	(function * 0x10)))
 #define XSTORM_STATS_FLAGS_OFFSET(function) \
-	(IS_E1H_OFFSET ? (0x23d8 + (function * 0x8)) : (0x3b60 + \
+	(IS_E1H_OFFSET ? (0x23d8 + (function * 0x8)) : (0x3a40 + \
 	(function * 0x8)))
+#define XSTORM_TCP_GLOBAL_DEL_ACK_COUNTER_ENABLED_OFFSET(port) \
+	(IS_E1H_OFFSET ? (0x4000 + (port * 0x8)) : (0x1960 + (port * 0x8)))
+#define XSTORM_TCP_GLOBAL_DEL_ACK_COUNTER_MAX_COUNT_OFFSET(port) \
+	(IS_E1H_OFFSET ? (0x4001 + (port * 0x8)) : (0x1961 + (port * 0x8)))
+#define XSTORM_TCP_TX_SWS_TIMER_VAL_OFFSET(function) \
+	(IS_E1H_OFFSET ? (0x4060 + ((function>>1) * 0x8) + ((function&1) \
+	* 0x4)) : (0x1978 + (function * 0x4)))
 #define COMMON_ASM_INVALID_ASSERT_OPCODE 0x0
 
 /**
@@ -211,6 +376,9 @@
 #define TCP_IPV4_HASH_TYPE 2
 #define IPV6_HASH_TYPE 3
 #define TCP_IPV6_HASH_TYPE 4
+#define VLAN_PRI_HASH_TYPE 5
+#define E1HOV_PRI_HASH_TYPE 6
+#define DSCP_HASH_TYPE 7
 
 
 /* Ethernet Ring parameters */
@@ -218,30 +386,26 @@
 #define FIRST_BD_IN_PKT 0
 #define PARSE_BD_INDEX 1
 #define NUM_OF_ETH_BDS_IN_PAGE ((PAGE_SIZE)/(STRUCT_SIZE(eth_tx_bd)/8))
-
+#define U_ETH_NUM_OF_SGES_TO_FETCH 8
+#define U_ETH_MAX_SGES_FOR_PACKET 3
 
 /* Rx ring params */
-#define U_ETH_LOCAL_BD_RING_SIZE 16
-#define U_ETH_LOCAL_SGE_RING_SIZE 12
+#define U_ETH_LOCAL_BD_RING_SIZE 8
+#define U_ETH_LOCAL_SGE_RING_SIZE 10
 #define U_ETH_SGL_SIZE 8
 
 
-#define U_ETH_BDS_PER_PAGE_MASK \
-	((PAGE_SIZE/(STRUCT_SIZE(eth_rx_bd)/8))-1)
-#define U_ETH_CQE_PER_PAGE_MASK \
-	((PAGE_SIZE/(STRUCT_SIZE(eth_rx_cqe)/8))-1)
-#define U_ETH_SGES_PER_PAGE_MASK \
-	((PAGE_SIZE/(STRUCT_SIZE(eth_rx_sge)/8))-1)
-
 #define U_ETH_SGES_PER_PAGE_INVERSE_MASK \
 	(0xFFFF - ((PAGE_SIZE/((STRUCT_SIZE(eth_rx_sge))/8))-1))
 
-
-#define TU_ETH_CQES_PER_PAGE \
-	(PAGE_SIZE/(STRUCT_SIZE(eth_rx_cqe_next_page)/8))
+#define TU_ETH_CQES_PER_PAGE (PAGE_SIZE/(STRUCT_SIZE(eth_rx_cqe)/8))
 #define U_ETH_BDS_PER_PAGE (PAGE_SIZE/(STRUCT_SIZE(eth_rx_bd)/8))
 #define U_ETH_SGES_PER_PAGE (PAGE_SIZE/(STRUCT_SIZE(eth_rx_sge)/8))
 
+#define U_ETH_BDS_PER_PAGE_MASK (U_ETH_BDS_PER_PAGE-1)
+#define U_ETH_CQE_PER_PAGE_MASK (TU_ETH_CQES_PER_PAGE-1)
+#define U_ETH_SGES_PER_PAGE_MASK (U_ETH_SGES_PER_PAGE-1)
+
 #define U_ETH_UNDEFINED_Q 0xFF
 
 /* values of command IDs in the ramrod message */
@@ -266,8 +430,8 @@
 #define T_ETH_CRC32_HASH_SEED 0x00000000
 
 /* Maximal L2 clients supported */
-#define ETH_MAX_RX_CLIENTS_E1 19
-#define ETH_MAX_RX_CLIENTS_E1H 25
+#define ETH_MAX_RX_CLIENTS_E1 18
+#define ETH_MAX_RX_CLIENTS_E1H 26
 
 /* Maximal aggregation queues supported */
 #define ETH_MAX_AGGREGATION_QUEUES_E1 32
@@ -276,6 +440,9 @@
 /* ETH RSS modes */
 #define ETH_RSS_MODE_DISABLED 0
 #define ETH_RSS_MODE_REGULAR 1
+#define ETH_RSS_MODE_VLAN_PRI 2
+#define ETH_RSS_MODE_E1HOV_PRI 3
+#define ETH_RSS_MODE_IP_DSCP 4
 
 
 /**
@@ -332,12 +499,14 @@
 #define HC_INDEX_DEF_C_ETH_SLOW_PATH 3
 #define HC_INDEX_DEF_C_ETH_RDMA_CQ_CONS 4
 #define HC_INDEX_DEF_C_ETH_ISCSI_CQ_CONS 5
+#define HC_INDEX_DEF_C_ETH_FCOE_CQ_CONS 6
 
 #define HC_INDEX_DEF_U_ETH_RDMA_RX_CQ_CONS 0
 #define HC_INDEX_DEF_U_ETH_ISCSI_RX_CQ_CONS 1
 #define HC_INDEX_DEF_U_ETH_RDMA_RX_BD_CONS 2
 #define HC_INDEX_DEF_U_ETH_ISCSI_RX_BD_CONS 3
-
+#define HC_INDEX_DEF_U_ETH_FCOE_RX_CQ_CONS 4
+#define HC_INDEX_DEF_U_ETH_FCOE_RX_BD_CONS 5
 
 /* used by the driver to get the SB offset */
 #define USTORM_ID 0
diff --git a/drivers/net/bnx2x_hsi.h b/drivers/net/bnx2x_hsi.h
index 7de83c4..da62cc5 100644
--- a/drivers/net/bnx2x_hsi.h
+++ b/drivers/net/bnx2x_hsi.h
@@ -1218,9 +1218,9 @@ struct host_func_stats {
 };
 
 
-#define BCM_5710_FW_MAJOR_VERSION			4
-#define BCM_5710_FW_MINOR_VERSION			8
-#define BCM_5710_FW_REVISION_VERSION			53
+#define BCM_5710_FW_MAJOR_VERSION			5
+#define BCM_5710_FW_MINOR_VERSION			0
+#define BCM_5710_FW_REVISION_VERSION			21
 #define BCM_5710_FW_ENGINEERING_VERSION 		0
 #define BCM_5710_FW_COMPILE_FLAGS			1
 
@@ -1270,6 +1270,22 @@ struct doorbell {
 
 
 /*
+ * doorbell message sent to the chip
+ */
+struct doorbell_set_prod {
+#if defined(__BIG_ENDIAN)
+	u16 prod;
+	u8 zero_fill1;
+	struct doorbell_hdr header;
+#elif defined(__LITTLE_ENDIAN)
+	struct doorbell_hdr header;
+	u8 zero_fill1;
+	u16 prod;
+#endif
+};
+
+
+/*
  * IGU driver acknowledgement register
  */
 struct igu_ack_register {
@@ -1304,6 +1320,62 @@ struct igu_ack_register {
 
 
 /*
+ * IGU driver acknowledgement register
+ */
+struct igu_backward_compatible {
+	u32 sb_id_and_flags;
+#define IGU_BACKWARD_COMPATIBLE_SB_INDEX (0xFFFF<<0)
+#define IGU_BACKWARD_COMPATIBLE_SB_INDEX_SHIFT 0
+#define IGU_BACKWARD_COMPATIBLE_SB_SELECT (0x1F<<16)
+#define IGU_BACKWARD_COMPATIBLE_SB_SELECT_SHIFT 16
+#define IGU_BACKWARD_COMPATIBLE_SEGMENT_ACCESS (0x7<<21)
+#define IGU_BACKWARD_COMPATIBLE_SEGMENT_ACCESS_SHIFT 21
+#define IGU_BACKWARD_COMPATIBLE_BUPDATE (0x1<<24)
+#define IGU_BACKWARD_COMPATIBLE_BUPDATE_SHIFT 24
+#define IGU_BACKWARD_COMPATIBLE_ENABLE_INT (0x3<<25)
+#define IGU_BACKWARD_COMPATIBLE_ENABLE_INT_SHIFT 25
+#define IGU_BACKWARD_COMPATIBLE_RESERVED_0 (0x1F<<27)
+#define IGU_BACKWARD_COMPATIBLE_RESERVED_0_SHIFT 27
+	u32 reserved_2;
+};
+
+
+/*
+ * IGU driver acknowledgement register
+ */
+struct igu_regular {
+	u32 sb_id_and_flags;
+#define IGU_REGULAR_SB_INDEX (0xFFFFF<<0)
+#define IGU_REGULAR_SB_INDEX_SHIFT 0
+#define IGU_REGULAR_RESERVED0 (0x1<<20)
+#define IGU_REGULAR_RESERVED0_SHIFT 20
+#define IGU_REGULAR_SEGMENT_ACCESS (0x7<<21)
+#define IGU_REGULAR_SEGMENT_ACCESS_SHIFT 21
+#define IGU_REGULAR_BUPDATE (0x1<<24)
+#define IGU_REGULAR_BUPDATE_SHIFT 24
+#define IGU_REGULAR_ENABLE_INT (0x3<<25)
+#define IGU_REGULAR_ENABLE_INT_SHIFT 25
+#define IGU_REGULAR_RESERVED_1 (0x1<<27)
+#define IGU_REGULAR_RESERVED_1_SHIFT 27
+#define IGU_REGULAR_CLEANUP_TYPE (0x3<<28)
+#define IGU_REGULAR_CLEANUP_TYPE_SHIFT 28
+#define IGU_REGULAR_CLEANUP_SET (0x1<<30)
+#define IGU_REGULAR_CLEANUP_SET_SHIFT 30
+#define IGU_REGULAR_BCLEANUP (0x1<<31)
+#define IGU_REGULAR_BCLEANUP_SHIFT 31
+	u32 reserved_2;
+};
+
+/*
+ * IGU driver acknowledgement register
+ */
+union igu_consprod_reg {
+	struct igu_regular regular;
+	struct igu_backward_compatible backward_compatible;
+};
+
+
+/*
  * Parser parsing flags field
  */
 struct parsing_flags {
@@ -1434,12 +1506,10 @@ struct ustorm_eth_st_context_config {
 #define USTORM_ETH_ST_CONTEXT_CONFIG_ENABLE_DYNAMIC_HC_SHIFT 1
 #define USTORM_ETH_ST_CONTEXT_CONFIG_ENABLE_TPA (0x1<<2)
 #define USTORM_ETH_ST_CONTEXT_CONFIG_ENABLE_TPA_SHIFT 2
-#define USTORM_ETH_ST_CONTEXT_CONFIG_ENABLE_SGE_RING (0x1<<3)
-#define USTORM_ETH_ST_CONTEXT_CONFIG_ENABLE_SGE_RING_SHIFT 3
-#define USTORM_ETH_ST_CONTEXT_CONFIG_ENABLE_STATISTICS (0x1<<4)
-#define USTORM_ETH_ST_CONTEXT_CONFIG_ENABLE_STATISTICS_SHIFT 4
-#define __USTORM_ETH_ST_CONTEXT_CONFIG_RESERVED0 (0x7<<5)
-#define __USTORM_ETH_ST_CONTEXT_CONFIG_RESERVED0_SHIFT 5
+#define USTORM_ETH_ST_CONTEXT_CONFIG_ENABLE_STATISTICS (0x1<<3)
+#define USTORM_ETH_ST_CONTEXT_CONFIG_ENABLE_STATISTICS_SHIFT 3
+#define __USTORM_ETH_ST_CONTEXT_CONFIG_RESERVED0 (0xF<<4)
+#define __USTORM_ETH_ST_CONTEXT_CONFIG_RESERVED0_SHIFT 4
 	u8 status_block_id;
 	u8 clientId;
 	u8 sb_index_numbers;
@@ -1462,12 +1532,10 @@ struct ustorm_eth_st_context_config {
 #define USTORM_ETH_ST_CONTEXT_CONFIG_ENABLE_DYNAMIC_HC_SHIFT 1
 #define USTORM_ETH_ST_CONTEXT_CONFIG_ENABLE_TPA (0x1<<2)
 #define USTORM_ETH_ST_CONTEXT_CONFIG_ENABLE_TPA_SHIFT 2
-#define USTORM_ETH_ST_CONTEXT_CONFIG_ENABLE_SGE_RING (0x1<<3)
-#define USTORM_ETH_ST_CONTEXT_CONFIG_ENABLE_SGE_RING_SHIFT 3
-#define USTORM_ETH_ST_CONTEXT_CONFIG_ENABLE_STATISTICS (0x1<<4)
-#define USTORM_ETH_ST_CONTEXT_CONFIG_ENABLE_STATISTICS_SHIFT 4
-#define __USTORM_ETH_ST_CONTEXT_CONFIG_RESERVED0 (0x7<<5)
-#define __USTORM_ETH_ST_CONTEXT_CONFIG_RESERVED0_SHIFT 5
+#define USTORM_ETH_ST_CONTEXT_CONFIG_ENABLE_STATISTICS (0x1<<3)
+#define USTORM_ETH_ST_CONTEXT_CONFIG_ENABLE_STATISTICS_SHIFT 3
+#define __USTORM_ETH_ST_CONTEXT_CONFIG_RESERVED0 (0xF<<4)
+#define __USTORM_ETH_ST_CONTEXT_CONFIG_RESERVED0_SHIFT 4
 #endif
 #if defined(__BIG_ENDIAN)
 	u16 bd_buff_size;
@@ -1487,11 +1555,36 @@ struct ustorm_eth_st_context_config {
 	u8 __local_bd_prod;
 	u8 __local_sge_prod;
 #endif
-	u32 reserved;
+#if defined(__BIG_ENDIAN)
+	u16 __sdm_bd_expected_counter;
+	u8 cstorm_agg_int;
+	u8 __expected_bds_on_ram;
+#elif defined(__LITTLE_ENDIAN)
+	u8 __expected_bds_on_ram;
+	u8 cstorm_agg_int;
+	u16 __sdm_bd_expected_counter;
+#endif
+#if defined(__BIG_ENDIAN)
+	u16 __ring_data_ram_addr;
+	u16 __hc_cstorm_ram_addr;
+#elif defined(__LITTLE_ENDIAN)
+	u16 __hc_cstorm_ram_addr;
+	u16 __ring_data_ram_addr;
+#endif
+#if defined(__BIG_ENDIAN)
+	u8 reserved1;
+	u8 max_sges_for_packet;
+	u16 __bd_ring_ram_addr;
+#elif defined(__LITTLE_ENDIAN)
+	u16 __bd_ring_ram_addr;
+	u8 max_sges_for_packet;
+	u8 reserved1;
+#endif
 	u32 bd_page_base_lo;
 	u32 bd_page_base_hi;
 	u32 sge_page_base_lo;
 	u32 sge_page_base_hi;
+	struct regpair reserved2;
 };
 
 /*
@@ -1514,8 +1607,8 @@ struct eth_rx_sge {
  * Local BDs and SGEs rings (in ETH)
  */
 struct eth_local_rx_rings {
-	struct eth_rx_bd __local_bd_ring[16];
-	struct eth_rx_sge __local_sge_ring[12];
+	struct eth_rx_bd __local_bd_ring[8];
+	struct eth_rx_sge __local_sge_ring[10];
 };
 
 /*
@@ -1607,13 +1700,13 @@ struct xstorm_eth_extra_ag_context_section {
  */
 struct xstorm_eth_ag_context {
 #if defined(__BIG_ENDIAN)
-	u16 __bd_prod;
+	u16 agg_val1;
 	u8 __agg_vars1;
 	u8 __state;
 #elif defined(__LITTLE_ENDIAN)
 	u8 __state;
 	u8 __agg_vars1;
-	u16 __bd_prod;
+	u16 agg_val1;
 #endif
 #if defined(__BIG_ENDIAN)
 	u8 cdu_reserved;
@@ -1626,7 +1719,7 @@ struct xstorm_eth_ag_context {
 	u8 __agg_vars4;
 	u8 cdu_reserved;
 #endif
-	u32 __more_packets_to_send;
+	u32 __bd_prod;
 #if defined(__BIG_ENDIAN)
 	u16 __agg_vars5;
 	u16 __agg_val4_th;
@@ -1892,8 +1985,8 @@ struct eth_tx_bd_flags {
 #define ETH_TX_BD_FLAGS_VLAN_TAG_SHIFT 0
 #define ETH_TX_BD_FLAGS_IP_CSUM (0x1<<1)
 #define ETH_TX_BD_FLAGS_IP_CSUM_SHIFT 1
-#define ETH_TX_BD_FLAGS_TCP_CSUM (0x1<<2)
-#define ETH_TX_BD_FLAGS_TCP_CSUM_SHIFT 2
+#define ETH_TX_BD_FLAGS_L4_CSUM (0x1<<2)
+#define ETH_TX_BD_FLAGS_L4_CSUM_SHIFT 2
 #define ETH_TX_BD_FLAGS_END_BD (0x1<<3)
 #define ETH_TX_BD_FLAGS_END_BD_SHIFT 3
 #define ETH_TX_BD_FLAGS_START_BD (0x1<<4)
@@ -1909,7 +2002,7 @@ struct eth_tx_bd_flags {
 /*
  * The eth Tx Buffer Descriptor
  */
-struct eth_tx_bd {
+struct eth_tx_start_bd {
 	__le32 addr_lo;
 	__le32 addr_hi;
 	__le16 nbd;
@@ -1917,10 +2010,21 @@ struct eth_tx_bd {
 	__le16 vlan;
 	struct eth_tx_bd_flags bd_flags;
 	u8 general_data;
-#define ETH_TX_BD_HDR_NBDS (0x3F<<0)
-#define ETH_TX_BD_HDR_NBDS_SHIFT 0
-#define ETH_TX_BD_ETH_ADDR_TYPE (0x3<<6)
-#define ETH_TX_BD_ETH_ADDR_TYPE_SHIFT 6
+#define ETH_TX_START_BD_HDR_NBDS (0x3F<<0)
+#define ETH_TX_START_BD_HDR_NBDS_SHIFT 0
+#define ETH_TX_START_BD_ETH_ADDR_TYPE (0x3<<6)
+#define ETH_TX_START_BD_ETH_ADDR_TYPE_SHIFT 6
+};
+
+/*
+ * Tx regular BD structure
+ */
+struct eth_tx_bd {
+	u32 addr_lo;
+	u32 addr_hi;
+	u16 total_pkt_bytes;
+	u16 nbytes;
+	u8 reserved[4];
 };
 
 /*
@@ -1930,8 +2034,8 @@ struct eth_tx_parse_bd {
 	u8 global_data;
 #define ETH_TX_PARSE_BD_IP_HDR_START_OFFSET (0xF<<0)
 #define ETH_TX_PARSE_BD_IP_HDR_START_OFFSET_SHIFT 0
-#define ETH_TX_PARSE_BD_CS_ANY_FLG (0x1<<4)
-#define ETH_TX_PARSE_BD_CS_ANY_FLG_SHIFT 4
+#define ETH_TX_PARSE_BD_UDP_CS_FLG (0x1<<4)
+#define ETH_TX_PARSE_BD_UDP_CS_FLG_SHIFT 4
 #define ETH_TX_PARSE_BD_PSEUDO_CS_WITHOUT_LEN (0x1<<5)
 #define ETH_TX_PARSE_BD_PSEUDO_CS_WITHOUT_LEN_SHIFT 5
 #define ETH_TX_PARSE_BD_LLC_SNAP_EN (0x1<<6)
@@ -1956,10 +2060,10 @@ struct eth_tx_parse_bd {
 #define ETH_TX_PARSE_BD_CWR_FLG (0x1<<7)
 #define ETH_TX_PARSE_BD_CWR_FLG_SHIFT 7
 	u8 ip_hlen;
-	s8 cs_offset;
+	s8 reserved;
 	__le16 total_hlen;
-	__le16 lso_mss;
 	__le16 tcp_pseudo_csum;
+	__le16 lso_mss;
 	__le16 ip_id;
 	__le32 tcp_send_seq;
 };
@@ -1968,15 +2072,16 @@ struct eth_tx_parse_bd {
  * The last BD in the BD memory will hold a pointer to the next BD memory
  */
 struct eth_tx_next_bd {
-	u32 addr_lo;
-	u32 addr_hi;
+	__le32 addr_lo;
+	__le32 addr_hi;
 	u8 reserved[8];
 };
 
 /*
- * union for 3 Bd types
+ * union for 4 Bd types
  */
 union eth_tx_bd_types {
+	struct eth_tx_start_bd start_bd;
 	struct eth_tx_bd reg_bd;
 	struct eth_tx_parse_bd parse_bd;
 	struct eth_tx_next_bd next_bd;
@@ -2005,11 +2110,35 @@ struct xstorm_eth_st_context {
 #define XSTORM_ETH_ST_CONTEXT_STATISTICS_ENABLE_SHIFT 7
 	u16 tx_bd_cons;
 #endif
-	u32 db_data_addr_lo;
-	u32 db_data_addr_hi;
-	u32 __pkt_cons;
-	u32 __gso_next;
-	u32 is_eth_conn_1b;
+	u32 __reserved1;
+	u32 __reserved2;
+#if defined(__BIG_ENDIAN)
+	u8 __ram_cache_index;
+	u8 __double_buffer_client;
+	u16 __pkt_cons;
+#elif defined(__LITTLE_ENDIAN)
+	u16 __pkt_cons;
+	u8 __double_buffer_client;
+	u8 __ram_cache_index;
+#endif
+#if defined(__BIG_ENDIAN)
+	u16 __statistics_address;
+	u16 __gso_next;
+#elif defined(__LITTLE_ENDIAN)
+	u16 __gso_next;
+	u16 __statistics_address;
+#endif
+#if defined(__BIG_ENDIAN)
+	u8 __local_tx_bd_cons;
+	u8 safc_group_num;
+	u8 safc_group_en;
+	u8 __is_eth_conn;
+#elif defined(__LITTLE_ENDIAN)
+	u8 __is_eth_conn;
+	u8 safc_group_en;
+	u8 safc_group_num;
+	u8 __local_tx_bd_cons;
+#endif
 	union eth_tx_bd_types __bds[13];
 };
 
@@ -2074,9 +2203,9 @@ struct eth_tx_doorbell {
 
 
 /*
- * ustorm status block
+ * cstorm default status block, generated by ustorm
  */
-struct ustorm_def_status_block {
+struct cstorm_def_status_block_u {
 	__le16 index_values[HC_USTORM_DEF_SB_NUM_INDICES];
 	__le16 status_block_index;
 	u8 func;
@@ -2085,9 +2214,9 @@ struct ustorm_def_status_block {
 };
 
 /*
- * cstorm status block
+ * cstorm default status block, generated by cstorm
  */
-struct cstorm_def_status_block {
+struct cstorm_def_status_block_c {
 	__le16 index_values[HC_CSTORM_DEF_SB_NUM_INDICES];
 	__le16 status_block_index;
 	u8 func;
@@ -2122,17 +2251,17 @@ struct tstorm_def_status_block {
  */
 struct host_def_status_block {
 	struct atten_def_status_block atten_status_block;
-	struct ustorm_def_status_block u_def_status_block;
-	struct cstorm_def_status_block c_def_status_block;
+	struct cstorm_def_status_block_u u_def_status_block;
+	struct cstorm_def_status_block_c c_def_status_block;
 	struct xstorm_def_status_block x_def_status_block;
 	struct tstorm_def_status_block t_def_status_block;
 };
 
 
 /*
- * ustorm status block
+ * cstorm status block, generated by ustorm
  */
-struct ustorm_status_block {
+struct cstorm_status_block_u {
 	__le16 index_values[HC_USTORM_SB_NUM_INDICES];
 	__le16 status_block_index;
 	u8 func;
@@ -2141,9 +2270,9 @@ struct ustorm_status_block {
 };
 
 /*
- * cstorm status block
+ * cstorm status block, generated by cstorm
  */
-struct cstorm_status_block {
+struct cstorm_status_block_c {
 	__le16 index_values[HC_CSTORM_SB_NUM_INDICES];
 	__le16 status_block_index;
 	u8 func;
@@ -2155,8 +2284,8 @@ struct cstorm_status_block {
  * host status block
  */
 struct host_status_block {
-	struct ustorm_status_block u_status_block;
-	struct cstorm_status_block c_status_block;
+	struct cstorm_status_block_u u_status_block;
+	struct cstorm_status_block_c c_status_block;
 };
 
 
@@ -2172,15 +2301,6 @@ struct eth_client_setup_ramrod_data {
 
 
 /*
- * L2 dynamic host coalescing init parameters
- */
-struct eth_dynamic_hc_config {
-	u32 threshold[3];
-	u8 hc_timeout[4];
-};
-
-
-/*
  * regular eth FP CQE parameters struct
  */
 struct eth_fast_path_rx_cqe {
@@ -2344,12 +2464,10 @@ struct eth_spe {
 
 
 /*
- * doorbell data in host memory
+ * array of 13 bds as appears in the eth xstorm context
  */
-struct eth_tx_db_data {
-	__le32 packets_prod;
-	__le16 bds_prod;
-	__le16 reserved;
+struct eth_tx_bds_array {
+	union eth_tx_bd_types bds[13];
 };
 
 
@@ -2377,8 +2495,10 @@ struct tstorm_eth_function_common_config {
 #define TSTORM_ETH_FUNCTION_COMMON_CONFIG_VLAN_IN_CAM_SHIFT 8
 #define TSTORM_ETH_FUNCTION_COMMON_CONFIG_E1HOV_IN_CAM (0x1<<9)
 #define TSTORM_ETH_FUNCTION_COMMON_CONFIG_E1HOV_IN_CAM_SHIFT 9
-#define __TSTORM_ETH_FUNCTION_COMMON_CONFIG_RESERVED0 (0x3F<<10)
-#define __TSTORM_ETH_FUNCTION_COMMON_CONFIG_RESERVED0_SHIFT 10
+#define TSTORM_ETH_FUNCTION_COMMON_CONFIG_ENABLE_TPA (0x1<<10)
+#define TSTORM_ETH_FUNCTION_COMMON_CONFIG_ENABLE_TPA_SHIFT 10
+#define __TSTORM_ETH_FUNCTION_COMMON_CONFIG_RESERVED0 (0x1F<<11)
+#define __TSTORM_ETH_FUNCTION_COMMON_CONFIG_RESERVED0_SHIFT 11
 #elif defined(__LITTLE_ENDIAN)
 	u16 config_flags;
 #define TSTORM_ETH_FUNCTION_COMMON_CONFIG_RSS_IPV4_CAPABILITY (0x1<<0)
@@ -2397,8 +2517,10 @@ struct tstorm_eth_function_common_config {
 #define TSTORM_ETH_FUNCTION_COMMON_CONFIG_VLAN_IN_CAM_SHIFT 8
 #define TSTORM_ETH_FUNCTION_COMMON_CONFIG_E1HOV_IN_CAM (0x1<<9)
 #define TSTORM_ETH_FUNCTION_COMMON_CONFIG_E1HOV_IN_CAM_SHIFT 9
-#define __TSTORM_ETH_FUNCTION_COMMON_CONFIG_RESERVED0 (0x3F<<10)
-#define __TSTORM_ETH_FUNCTION_COMMON_CONFIG_RESERVED0_SHIFT 10
+#define TSTORM_ETH_FUNCTION_COMMON_CONFIG_ENABLE_TPA (0x1<<10)
+#define TSTORM_ETH_FUNCTION_COMMON_CONFIG_ENABLE_TPA_SHIFT 10
+#define __TSTORM_ETH_FUNCTION_COMMON_CONFIG_RESERVED0 (0x1F<<11)
+#define __TSTORM_ETH_FUNCTION_COMMON_CONFIG_RESERVED0_SHIFT 11
 	u8 rss_result_mask;
 	u8 leading_client_id;
 #endif
@@ -2406,11 +2528,38 @@ struct tstorm_eth_function_common_config {
 };
 
 /*
+ * RSS idirection table update configuration
+ */
+struct rss_update_config {
+#if defined(__BIG_ENDIAN)
+	u16 toe_rss_bitmap;
+	u16 flags;
+#define RSS_UPDATE_CONFIG_ETH_UPDATE_ENABLE (0x1<<0)
+#define RSS_UPDATE_CONFIG_ETH_UPDATE_ENABLE_SHIFT 0
+#define RSS_UPDATE_CONFIG_TOE_UPDATE_ENABLE (0x1<<1)
+#define RSS_UPDATE_CONFIG_TOE_UPDATE_ENABLE_SHIFT 1
+#define __RSS_UPDATE_CONFIG_RESERVED0 (0x3FFF<<2)
+#define __RSS_UPDATE_CONFIG_RESERVED0_SHIFT 2
+#elif defined(__LITTLE_ENDIAN)
+	u16 flags;
+#define RSS_UPDATE_CONFIG_ETH_UPDATE_ENABLE (0x1<<0)
+#define RSS_UPDATE_CONFIG_ETH_UPDATE_ENABLE_SHIFT 0
+#define RSS_UPDATE_CONFIG_TOE_UPDATE_ENABLE (0x1<<1)
+#define RSS_UPDATE_CONFIG_TOE_UPDATE_ENABLE_SHIFT 1
+#define __RSS_UPDATE_CONFIG_RESERVED0 (0x3FFF<<2)
+#define __RSS_UPDATE_CONFIG_RESERVED0_SHIFT 2
+	u16 toe_rss_bitmap;
+#endif
+	u32 reserved1;
+};
+
+/*
  * parameters for eth update ramrod
  */
 struct eth_update_ramrod_data {
 	struct tstorm_eth_function_common_config func_config;
 	u8 indirectionTable[128];
+	struct rss_update_config rss_config;
 };
 
 
@@ -2455,8 +2604,9 @@ struct tstorm_cam_target_table_entry {
 #define TSTORM_CAM_TARGET_TABLE_ENTRY_RDMA_MAC_SHIFT 3
 #define TSTORM_CAM_TARGET_TABLE_ENTRY_RESERVED0 (0xF<<4)
 #define TSTORM_CAM_TARGET_TABLE_ENTRY_RESERVED0_SHIFT 4
-	u8 client_id;
+	u8 reserved1;
 	u16 vlan_id;
+	u32 clients_bit_vector;
 };
 
 /*
@@ -2485,7 +2635,7 @@ struct mac_configuration_entry_e1h {
 	__le16 msb_mac_addr;
 	__le16 vlan_id;
 	__le16 e1hov_id;
-	u8 client_id;
+	u8 reserved0;
 	u8 flags;
 #define MAC_CONFIGURATION_ENTRY_E1H_PORT (0x1<<0)
 #define MAC_CONFIGURATION_ENTRY_E1H_PORT_SHIFT 0
@@ -2493,8 +2643,9 @@ struct mac_configuration_entry_e1h {
 #define MAC_CONFIGURATION_ENTRY_E1H_ACTION_TYPE_SHIFT 1
 #define MAC_CONFIGURATION_ENTRY_E1H_RDMA_MAC (0x1<<2)
 #define MAC_CONFIGURATION_ENTRY_E1H_RDMA_MAC_SHIFT 2
-#define MAC_CONFIGURATION_ENTRY_E1H_RESERVED0 (0x1F<<3)
-#define MAC_CONFIGURATION_ENTRY_E1H_RESERVED0_SHIFT 3
+#define MAC_CONFIGURATION_ENTRY_E1H_RESERVED1 (0x1F<<3)
+#define MAC_CONFIGURATION_ENTRY_E1H_RESERVED1_SHIFT 3
+	u32 clients_bit_vector;
 };
 
 /*
@@ -2519,13 +2670,13 @@ struct tstorm_eth_approximate_match_multicast_filtering {
  */
 struct tstorm_eth_client_config {
 #if defined(__BIG_ENDIAN)
-	u8 max_sges_for_packet;
+	u8 reserved0;
 	u8 statistics_counter_id;
 	u16 mtu;
 #elif defined(__LITTLE_ENDIAN)
 	u16 mtu;
 	u8 statistics_counter_id;
-	u8 max_sges_for_packet;
+	u8 reserved0;
 #endif
 #if defined(__BIG_ENDIAN)
 	u16 drop_flags;
@@ -2537,8 +2688,8 @@ struct tstorm_eth_client_config {
 #define TSTORM_ETH_CLIENT_CONFIG_DROP_TTL0_SHIFT 2
 #define TSTORM_ETH_CLIENT_CONFIG_DROP_UDP_CS_ERR (0x1<<3)
 #define TSTORM_ETH_CLIENT_CONFIG_DROP_UDP_CS_ERR_SHIFT 3
-#define __TSTORM_ETH_CLIENT_CONFIG_RESERVED1 (0xFFF<<4)
-#define __TSTORM_ETH_CLIENT_CONFIG_RESERVED1_SHIFT 4
+#define __TSTORM_ETH_CLIENT_CONFIG_RESERVED2 (0xFFF<<4)
+#define __TSTORM_ETH_CLIENT_CONFIG_RESERVED2_SHIFT 4
 	u16 config_flags;
 #define TSTORM_ETH_CLIENT_CONFIG_VLAN_REM_ENABLE (0x1<<0)
 #define TSTORM_ETH_CLIENT_CONFIG_VLAN_REM_ENABLE_SHIFT 0
@@ -2546,10 +2697,8 @@ struct tstorm_eth_client_config {
 #define TSTORM_ETH_CLIENT_CONFIG_E1HOV_REM_ENABLE_SHIFT 1
 #define TSTORM_ETH_CLIENT_CONFIG_STATSITICS_ENABLE (0x1<<2)
 #define TSTORM_ETH_CLIENT_CONFIG_STATSITICS_ENABLE_SHIFT 2
-#define TSTORM_ETH_CLIENT_CONFIG_ENABLE_SGE_RING (0x1<<3)
-#define TSTORM_ETH_CLIENT_CONFIG_ENABLE_SGE_RING_SHIFT 3
-#define __TSTORM_ETH_CLIENT_CONFIG_RESERVED0 (0xFFF<<4)
-#define __TSTORM_ETH_CLIENT_CONFIG_RESERVED0_SHIFT 4
+#define __TSTORM_ETH_CLIENT_CONFIG_RESERVED1 (0x1FFF<<3)
+#define __TSTORM_ETH_CLIENT_CONFIG_RESERVED1_SHIFT 3
 #elif defined(__LITTLE_ENDIAN)
 	u16 config_flags;
 #define TSTORM_ETH_CLIENT_CONFIG_VLAN_REM_ENABLE (0x1<<0)
@@ -2558,10 +2707,8 @@ struct tstorm_eth_client_config {
 #define TSTORM_ETH_CLIENT_CONFIG_E1HOV_REM_ENABLE_SHIFT 1
 #define TSTORM_ETH_CLIENT_CONFIG_STATSITICS_ENABLE (0x1<<2)
 #define TSTORM_ETH_CLIENT_CONFIG_STATSITICS_ENABLE_SHIFT 2
-#define TSTORM_ETH_CLIENT_CONFIG_ENABLE_SGE_RING (0x1<<3)
-#define TSTORM_ETH_CLIENT_CONFIG_ENABLE_SGE_RING_SHIFT 3
-#define __TSTORM_ETH_CLIENT_CONFIG_RESERVED0 (0xFFF<<4)
-#define __TSTORM_ETH_CLIENT_CONFIG_RESERVED0_SHIFT 4
+#define __TSTORM_ETH_CLIENT_CONFIG_RESERVED1 (0x1FFF<<3)
+#define __TSTORM_ETH_CLIENT_CONFIG_RESERVED1_SHIFT 3
 	u16 drop_flags;
 #define TSTORM_ETH_CLIENT_CONFIG_DROP_IP_CS_ERR (0x1<<0)
 #define TSTORM_ETH_CLIENT_CONFIG_DROP_IP_CS_ERR_SHIFT 0
@@ -2571,8 +2718,8 @@ struct tstorm_eth_client_config {
 #define TSTORM_ETH_CLIENT_CONFIG_DROP_TTL0_SHIFT 2
 #define TSTORM_ETH_CLIENT_CONFIG_DROP_UDP_CS_ERR (0x1<<3)
 #define TSTORM_ETH_CLIENT_CONFIG_DROP_UDP_CS_ERR_SHIFT 3
-#define __TSTORM_ETH_CLIENT_CONFIG_RESERVED1 (0xFFF<<4)
-#define __TSTORM_ETH_CLIENT_CONFIG_RESERVED1_SHIFT 4
+#define __TSTORM_ETH_CLIENT_CONFIG_RESERVED2 (0xFFF<<4)
+#define __TSTORM_ETH_CLIENT_CONFIG_RESERVED2_SHIFT 4
 #endif
 };
 
@@ -2695,7 +2842,6 @@ struct rate_shaping_vars_per_port {
 	u32 rs_threshold;
 };
 
-
 /*
  * per-port fairness variables
  */
@@ -2705,7 +2851,6 @@ struct fairness_vars_per_port {
 	u32 fairness_timeout;
 };
 
-
 /*
  * per-port SAFC variables
  */
@@ -2722,7 +2867,6 @@ struct safc_struct_per_port {
 	u16 cos_to_pause_mask[NUM_OF_SAFC_BITS];
 };
 
-
 /*
  * Per-port congestion management variables
  */
@@ -2735,11 +2879,23 @@ struct cmng_struct_per_port {
 
 
 /*
+ * Dynamic host coalescing init parameters
+ */
+struct dynamic_hc_config {
+	u32 threshold[3];
+	u8 shift_per_protocol[HC_USTORM_SB_NUM_INDICES];
+	u8 hc_timeout0[HC_USTORM_SB_NUM_INDICES];
+	u8 hc_timeout1[HC_USTORM_SB_NUM_INDICES];
+	u8 hc_timeout2[HC_USTORM_SB_NUM_INDICES];
+	u8 hc_timeout3[HC_USTORM_SB_NUM_INDICES];
+};
+
+
+/*
  * Protocol-common statistics collected by the Xstorm (per client)
  */
 struct xstorm_per_client_stats {
-	struct regpair total_sent_bytes;
-	__le32 total_sent_pkts;
+	__le32 reserved0;
 	__le32 unicast_pkts_sent;
 	struct regpair unicast_bytes_sent;
 	struct regpair multicast_bytes_sent;
@@ -2747,11 +2903,10 @@ struct xstorm_per_client_stats {
 	__le32 broadcast_pkts_sent;
 	struct regpair broadcast_bytes_sent;
 	__le16 stats_counter;
-	__le16 reserved0;
-	__le32 reserved1;
+	__le16 reserved1;
+	__le32 reserved2;
 };
 
-
 /*
  * Common statistics collected by the Xstorm (per port)
  */
@@ -2759,7 +2914,6 @@ struct xstorm_common_stats {
  struct xstorm_per_client_stats client_statistics[MAX_X_STAT_COUNTER_ID];
 };
 
-
 /*
  * Protocol-common statistics collected by the Tstorm (per port)
  */
@@ -2770,19 +2924,16 @@ struct tstorm_per_port_stats {
 	__le32 mac_discard;
 };
 
-
 /*
  * Protocol-common statistics collected by the Tstorm (per client)
  */
 struct tstorm_per_client_stats {
-	struct regpair total_rcv_bytes;
 	struct regpair rcv_unicast_bytes;
 	struct regpair rcv_broadcast_bytes;
 	struct regpair rcv_multicast_bytes;
 	struct regpair rcv_error_bytes;
 	__le32 checksum_discard;
 	__le32 packets_too_big_discard;
-	__le32 total_rcv_pkts;
 	__le32 rcv_unicast_pkts;
 	__le32 rcv_broadcast_pkts;
 	__le32 rcv_multicast_pkts;
@@ -2790,7 +2941,6 @@ struct tstorm_per_client_stats {
 	__le32 ttl0_discard;
 	__le16 stats_counter;
 	__le16 reserved0;
-	__le32 reserved1;
 };
 
 /*
@@ -2893,6 +3043,15 @@ struct pram_fw_version {
 
 
 /*
+ * The send queue element
+ */
+struct protocol_common_spe {
+	struct spe_hdr hdr;
+	struct regpair phy_address;
+};
+
+
+/*
  * a single rate shaping counter. can be used as protocol or vnic counter
  */
 struct rate_shaping_counter {
diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index c92d1a4..76b7fac 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -10,7 +10,7 @@
  * Written by: Eliezer Tamir
  * Based on code from Michael Chan's bnx2 driver
  * UDP CSUM errata workaround by Arik Gendelman
- * Slowpath rework by Vladislav Zolotarov
+ * Slowpath and fastpath rework by Vladislav Zolotarov
  * Statistics and Link management by Yitchak Gertner
  *
  */
@@ -80,7 +80,18 @@ MODULE_VERSION(DRV_MODULE_VERSION);
 
 static int multi_mode = 1;
 module_param(multi_mode, int, 0);
-MODULE_PARM_DESC(multi_mode, " Use per-CPU queues");
+MODULE_PARM_DESC(multi_mode, " Multi queue mode "
+			     "(0 Disable; 1 Enable (default))");
+
+static int num_rx_queues;
+module_param(num_rx_queues, int, 0);
+MODULE_PARM_DESC(num_rx_queues, " Number of Rx queues for multi_mode=1"
+				" (default is half number of CPUs)");
+
+static int num_tx_queues;
+module_param(num_tx_queues, int, 0);
+MODULE_PARM_DESC(num_tx_queues, " Number of Tx queues for multi_mode=1"
+				" (default is half number of CPUs)");
 
 static int disable_tpa;
 module_param(disable_tpa, int, 0);
@@ -541,16 +552,15 @@ static void bnx2x_panic_dump(struct bnx2x *bp)
 	/* Tx */
 	for_each_tx_queue(bp, i) {
 		struct bnx2x_fastpath *fp = &bp->fp[i];
-		struct eth_tx_db_data *hw_prods = fp->hw_tx_prods;
 
 		BNX2X_ERR("fp%d: tx_pkt_prod(%x)  tx_pkt_cons(%x)"
 			  "  tx_bd_prod(%x)  tx_bd_cons(%x)  *tx_cons_sb(%x)\n",
 			  i, fp->tx_pkt_prod, fp->tx_pkt_cons, fp->tx_bd_prod,
 			  fp->tx_bd_cons, le16_to_cpu(*fp->tx_cons_sb));
 		BNX2X_ERR("      fp_c_idx(%x)  *sb_c_idx(%x)"
-			  "  bd data(%x,%x)\n", le16_to_cpu(fp->fp_c_idx),
+			  "  tx_db_prod(%x)\n", le16_to_cpu(fp->fp_c_idx),
 			  fp->status_blk->c_status_block.status_block_index,
-			  hw_prods->packets_prod, hw_prods->bds_prod);
+			  fp->tx_db.data.prod);
 	}
 
 	/* Rings */
@@ -789,16 +799,6 @@ static u16 bnx2x_ack_int(struct bnx2x *bp)
  * fast path service functions
  */
 
-static inline int bnx2x_has_tx_work(struct bnx2x_fastpath *fp)
-{
-	u16 tx_cons_sb;
-
-	/* Tell compiler that status block fields can change */
-	barrier();
-	tx_cons_sb = le16_to_cpu(*fp->tx_cons_sb);
-	return (fp->tx_pkt_cons != tx_cons_sb);
-}
-
 static inline int bnx2x_has_tx_work_unload(struct bnx2x_fastpath *fp)
 {
 	/* Tell compiler that consumer and producer can change */
@@ -813,7 +813,8 @@ static u16 bnx2x_free_tx_pkt(struct bnx2x *bp, struct bnx2x_fastpath *fp,
 			     u16 idx)
 {
 	struct sw_tx_bd *tx_buf = &fp->tx_buf_ring[idx];
-	struct eth_tx_bd *tx_bd;
+	struct eth_tx_start_bd *tx_start_bd;
+	struct eth_tx_bd *tx_data_bd;
 	struct sk_buff *skb = tx_buf->skb;
 	u16 bd_idx = TX_BD(tx_buf->first_bd), new_cons;
 	int nbd;
@@ -823,51 +824,46 @@ static u16 bnx2x_free_tx_pkt(struct bnx2x *bp, struct bnx2x_fastpath *fp,
 
 	/* unmap first bd */
 	DP(BNX2X_MSG_OFF, "free bd_idx %d\n", bd_idx);
-	tx_bd = &fp->tx_desc_ring[bd_idx];
-	pci_unmap_single(bp->pdev, BD_UNMAP_ADDR(tx_bd),
-			 BD_UNMAP_LEN(tx_bd), PCI_DMA_TODEVICE);
+	tx_start_bd = &fp->tx_desc_ring[bd_idx].start_bd;
+	pci_unmap_single(bp->pdev, BD_UNMAP_ADDR(tx_start_bd),
+			 BD_UNMAP_LEN(tx_start_bd), PCI_DMA_TODEVICE);
 
-	nbd = le16_to_cpu(tx_bd->nbd) - 1;
-	new_cons = nbd + tx_buf->first_bd;
+	nbd = le16_to_cpu(tx_start_bd->nbd) - 1;
 #ifdef BNX2X_STOP_ON_ERROR
-	if (nbd > (MAX_SKB_FRAGS + 2)) {
+	if ((nbd - 1) > (MAX_SKB_FRAGS + 2)) {
 		BNX2X_ERR("BAD nbd!\n");
 		bnx2x_panic();
 	}
 #endif
+	new_cons = nbd + tx_buf->first_bd;
 
-	/* Skip a parse bd and the TSO split header bd
-	   since they have no mapping */
-	if (nbd)
-		bd_idx = TX_BD(NEXT_TX_IDX(bd_idx));
+	/* Get the next bd */
+	bd_idx = TX_BD(NEXT_TX_IDX(bd_idx));
 
-	if (tx_bd->bd_flags.as_bitfield & (ETH_TX_BD_FLAGS_IP_CSUM |
-					   ETH_TX_BD_FLAGS_TCP_CSUM |
-					   ETH_TX_BD_FLAGS_SW_LSO)) {
-		if (--nbd)
-			bd_idx = TX_BD(NEXT_TX_IDX(bd_idx));
-		tx_bd = &fp->tx_desc_ring[bd_idx];
-		/* is this a TSO split header bd? */
-		if (tx_bd->bd_flags.as_bitfield & ETH_TX_BD_FLAGS_SW_LSO) {
-			if (--nbd)
-				bd_idx = TX_BD(NEXT_TX_IDX(bd_idx));
-		}
+	/* Skip a parse bd... */
+	--nbd;
+	bd_idx = TX_BD(NEXT_TX_IDX(bd_idx));
+
+	/* ...and the TSO split header bd since they have no mapping */
+	if (tx_buf->flags & BNX2X_TSO_SPLIT_BD) {
+		--nbd;
+		bd_idx = TX_BD(NEXT_TX_IDX(bd_idx));
 	}
 
 	/* now free frags */
 	while (nbd > 0) {
 
 		DP(BNX2X_MSG_OFF, "free frag bd_idx %d\n", bd_idx);
-		tx_bd = &fp->tx_desc_ring[bd_idx];
-		pci_unmap_page(bp->pdev, BD_UNMAP_ADDR(tx_bd),
-			       BD_UNMAP_LEN(tx_bd), PCI_DMA_TODEVICE);
+		tx_data_bd = &fp->tx_desc_ring[bd_idx].reg_bd;
+		pci_unmap_page(bp->pdev, BD_UNMAP_ADDR(tx_data_bd),
+			       BD_UNMAP_LEN(tx_data_bd), PCI_DMA_TODEVICE);
 		if (--nbd)
 			bd_idx = TX_BD(NEXT_TX_IDX(bd_idx));
 	}
 
 	/* release skb */
 	WARN_ON(!skb);
-	dev_kfree_skb(skb);
+	dev_kfree_skb_any(skb);
 	tx_buf->first_bd = 0;
 	tx_buf->skb = NULL;
 
@@ -909,7 +905,7 @@ static void bnx2x_tx_int(struct bnx2x_fastpath *fp)
 		return;
 #endif
 
-	txq = netdev_get_tx_queue(bp->dev, fp->index);
+	txq = netdev_get_tx_queue(bp->dev, fp->index - bp->num_rx_queues);
 	hw_cons = le16_to_cpu(*fp->tx_cons_sb);
 	sw_cons = fp->tx_pkt_cons;
 
@@ -939,8 +935,6 @@ static void bnx2x_tx_int(struct bnx2x_fastpath *fp)
 	/* TBD need a thresh? */
 	if (unlikely(netif_tx_queue_stopped(txq))) {
 
-		__netif_tx_lock(txq, smp_processor_id());
-
 		/* Need to make the tx_bd_cons update visible to start_xmit()
 		 * before checking for netif_tx_queue_stopped().  Without the
 		 * memory barrier, there is a small possibility that
@@ -953,8 +947,6 @@ static void bnx2x_tx_int(struct bnx2x_fastpath *fp)
 		    (bp->state == BNX2X_STATE_OPEN) &&
 		    (bnx2x_tx_avail(fp) >= MAX_SKB_FRAGS + 3))
 			netif_tx_wake_queue(txq);
-
-		__netif_tx_unlock(txq);
 	}
 }
 
@@ -1022,6 +1014,7 @@ static void bnx2x_sp_event(struct bnx2x_fastpath *fp,
 		break;
 
 	case (RAMROD_CMD_ID_ETH_SET_MAC | BNX2X_STATE_CLOSING_WAIT4_HALT):
+	case (RAMROD_CMD_ID_ETH_SET_MAC | BNX2X_STATE_DISABLED):
 		DP(NETIF_MSG_IFDOWN, "got (un)set mac ramrod\n");
 		break;
 
@@ -1687,7 +1680,6 @@ static irqreturn_t bnx2x_msix_fp_int(int irq, void *fp_cookie)
 {
 	struct bnx2x_fastpath *fp = fp_cookie;
 	struct bnx2x *bp = fp->bp;
-	int index = fp->index;
 
 	/* Return here if interrupt is disabled */
 	if (unlikely(atomic_read(&bp->intr_sem) != 0)) {
@@ -1696,20 +1688,34 @@ static irqreturn_t bnx2x_msix_fp_int(int irq, void *fp_cookie)
 	}
 
 	DP(BNX2X_MSG_FP, "got an MSI-X interrupt on IDX:SB [%d:%d]\n",
-	   index, fp->sb_id);
+	   fp->index, fp->sb_id);
 	bnx2x_ack_sb(bp, fp->sb_id, USTORM_ID, 0, IGU_INT_DISABLE, 0);
 
 #ifdef BNX2X_STOP_ON_ERROR
 	if (unlikely(bp->panic))
 		return IRQ_HANDLED;
 #endif
+	/* Handle Rx or Tx according to MSI-X vector */
+	if (fp->is_rx_queue) {
+		prefetch(fp->rx_cons_sb);
+		prefetch(&fp->status_blk->u_status_block.status_block_index);
 
-	prefetch(fp->rx_cons_sb);
-	prefetch(fp->tx_cons_sb);
-	prefetch(&fp->status_blk->c_status_block.status_block_index);
-	prefetch(&fp->status_blk->u_status_block.status_block_index);
+		napi_schedule(&bnx2x_fp(bp, fp->index, napi));
 
-	napi_schedule(&bnx2x_fp(bp, index, napi));
+	} else {
+		prefetch(fp->tx_cons_sb);
+		prefetch(&fp->status_blk->c_status_block.status_block_index);
+
+		bnx2x_update_fpsb_idx(fp);
+		rmb();
+		bnx2x_tx_int(fp);
+
+		/* Re-enable interrupts */
+		bnx2x_ack_sb(bp, fp->sb_id, USTORM_ID,
+			     le16_to_cpu(fp->fp_u_idx), IGU_INT_NOP, 1);
+		bnx2x_ack_sb(bp, fp->sb_id, CSTORM_ID,
+			     le16_to_cpu(fp->fp_c_idx), IGU_INT_ENABLE, 1);
+	}
 
 	return IRQ_HANDLED;
 }
@@ -1719,6 +1725,7 @@ static irqreturn_t bnx2x_interrupt(int irq, void *dev_instance)
 	struct bnx2x *bp = netdev_priv(dev_instance);
 	u16 status = bnx2x_ack_int(bp);
 	u16 mask;
+	int i;
 
 	/* Return here if interrupt is shared and it's not for us */
 	if (unlikely(status == 0)) {
@@ -1738,18 +1745,38 @@ static irqreturn_t bnx2x_interrupt(int irq, void *dev_instance)
 		return IRQ_HANDLED;
 #endif
 
-	mask = 0x2 << bp->fp[0].sb_id;
-	if (status & mask) {
-		struct bnx2x_fastpath *fp = &bp->fp[0];
+	for (i = 0; i < BNX2X_NUM_QUEUES(bp); i++) {
+		struct bnx2x_fastpath *fp = &bp->fp[i];
 
-		prefetch(fp->rx_cons_sb);
-		prefetch(fp->tx_cons_sb);
-		prefetch(&fp->status_blk->c_status_block.status_block_index);
-		prefetch(&fp->status_blk->u_status_block.status_block_index);
+		mask = 0x2 << fp->sb_id;
+		if (status & mask) {
+			/* Handle Rx or Tx according to SB id */
+			if (fp->is_rx_queue) {
+				prefetch(fp->rx_cons_sb);
+				prefetch(&fp->status_blk->u_status_block.
+							status_block_index);
 
-		napi_schedule(&bnx2x_fp(bp, 0, napi));
+				napi_schedule(&bnx2x_fp(bp, fp->index, napi));
 
-		status &= ~mask;
+			} else {
+				prefetch(fp->tx_cons_sb);
+				prefetch(&fp->status_blk->c_status_block.
+							status_block_index);
+
+				bnx2x_update_fpsb_idx(fp);
+				rmb();
+				bnx2x_tx_int(fp);
+
+				/* Re-enable interrupts */
+				bnx2x_ack_sb(bp, fp->sb_id, USTORM_ID,
+					     le16_to_cpu(fp->fp_u_idx),
+					     IGU_INT_NOP, 1);
+				bnx2x_ack_sb(bp, fp->sb_id, CSTORM_ID,
+					     le16_to_cpu(fp->fp_c_idx),
+					     IGU_INT_ENABLE, 1);
+			}
+			status &= ~mask;
+		}
 	}
 
 
@@ -2297,7 +2324,7 @@ static void bnx2x_link_attn(struct bnx2x *bp)
 				pause_enabled = 1;
 
 			REG_WR(bp, BAR_USTRORM_INTMEM +
-			       USTORM_PAUSE_ENABLED_OFFSET(port),
+			       USTORM_ETH_PAUSE_ENABLED_OFFSET(port),
 			       pause_enabled);
 		}
 
@@ -3755,7 +3782,7 @@ static int bnx2x_storm_stats_update(struct bnx2x *bp)
 	estats->no_buff_discard_hi = 0;
 	estats->no_buff_discard_lo = 0;
 
-	for_each_queue(bp, i) {
+	for_each_rx_queue(bp, i) {
 		struct bnx2x_fastpath *fp = &bp->fp[i];
 		int cl_id = fp->cl_id;
 		struct tstorm_per_client_stats *tclient =
@@ -3794,11 +3821,24 @@ static int bnx2x_storm_stats_update(struct bnx2x *bp)
 		}
 
 		qstats->total_bytes_received_hi =
-		qstats->valid_bytes_received_hi =
-				le32_to_cpu(tclient->total_rcv_bytes.hi);
+			le32_to_cpu(tclient->rcv_broadcast_bytes.hi);
 		qstats->total_bytes_received_lo =
+			le32_to_cpu(tclient->rcv_broadcast_bytes.lo);
+
+		ADD_64(qstats->total_bytes_received_hi,
+		       le32_to_cpu(tclient->rcv_multicast_bytes.hi),
+		       qstats->total_bytes_received_lo,
+		       le32_to_cpu(tclient->rcv_multicast_bytes.lo));
+
+		ADD_64(qstats->total_bytes_received_hi,
+		       le32_to_cpu(tclient->rcv_unicast_bytes.hi),
+		       qstats->total_bytes_received_lo,
+		       le32_to_cpu(tclient->rcv_unicast_bytes.lo));
+
+		qstats->valid_bytes_received_hi =
+					qstats->total_bytes_received_hi;
 		qstats->valid_bytes_received_lo =
-				le32_to_cpu(tclient->total_rcv_bytes.lo);
+					qstats->total_bytes_received_lo;
 
 		qstats->error_bytes_received_hi =
 				le32_to_cpu(tclient->rcv_error_bytes.hi);
@@ -3831,9 +3871,19 @@ static int bnx2x_storm_stats_update(struct bnx2x *bp)
 		UPDATE_EXTEND_USTAT(bcast_no_buff_pkts, no_buff_discard);
 
 		qstats->total_bytes_transmitted_hi =
-				le32_to_cpu(xclient->total_sent_bytes.hi);
+				le32_to_cpu(xclient->unicast_bytes_sent.hi);
 		qstats->total_bytes_transmitted_lo =
-				le32_to_cpu(xclient->total_sent_bytes.lo);
+				le32_to_cpu(xclient->unicast_bytes_sent.lo);
+
+		ADD_64(qstats->total_bytes_transmitted_hi,
+		       le32_to_cpu(xclient->multicast_bytes_sent.hi),
+		       qstats->total_bytes_transmitted_lo,
+		       le32_to_cpu(xclient->multicast_bytes_sent.lo));
+
+		ADD_64(qstats->total_bytes_transmitted_hi,
+		       le32_to_cpu(xclient->broadcast_bytes_sent.hi),
+		       qstats->total_bytes_transmitted_lo,
+		       le32_to_cpu(xclient->broadcast_bytes_sent.lo));
 
 		UPDATE_EXTEND_XSTAT(unicast_pkts_sent,
 					total_unicast_packets_transmitted);
@@ -3949,7 +3999,7 @@ static void bnx2x_net_stats_update(struct bnx2x *bp)
 	nstats->tx_bytes = bnx2x_hilo(&estats->total_bytes_transmitted_hi);
 
 	nstats->rx_dropped = estats->mac_discard;
-	for_each_queue(bp, i)
+	for_each_rx_queue(bp, i)
 		nstats->rx_dropped +=
 			le32_to_cpu(bp->fp[i].old_tclient.checksum_discard);
 
@@ -4003,7 +4053,7 @@ static void bnx2x_drv_stats_update(struct bnx2x *bp)
 	estats->rx_err_discard_pkt = 0;
 	estats->rx_skb_alloc_failed = 0;
 	estats->hw_csum_err = 0;
-	for_each_queue(bp, i) {
+	for_each_rx_queue(bp, i) {
 		struct bnx2x_eth_q_stats *qstats = &bp->fp[i].eth_q_stats;
 
 		estats->driver_xoff += qstats->driver_xoff;
@@ -4033,6 +4083,8 @@ static void bnx2x_stats_update(struct bnx2x *bp)
 	bnx2x_drv_stats_update(bp);
 
 	if (bp->msglevel & NETIF_MSG_TIMER) {
+		struct bnx2x_fastpath *fp0_rx = bp->fp;
+		struct bnx2x_fastpath *fp0_tx = &(bp->fp[bp->num_rx_queues]);
 		struct tstorm_per_client_stats *old_tclient =
 							&bp->fp->old_tclient;
 		struct bnx2x_eth_q_stats *qstats = &bp->fp->eth_q_stats;
@@ -4043,13 +4095,13 @@ static void bnx2x_stats_update(struct bnx2x *bp)
 		printk(KERN_DEBUG "%s:\n", bp->dev->name);
 		printk(KERN_DEBUG "  tx avail (%4x)  tx hc idx (%x)"
 				  "  tx pkt (%lx)\n",
-		       bnx2x_tx_avail(bp->fp),
-		       le16_to_cpu(*bp->fp->tx_cons_sb), nstats->tx_packets);
+		       bnx2x_tx_avail(fp0_tx),
+		       le16_to_cpu(*fp0_tx->tx_cons_sb), nstats->tx_packets);
 		printk(KERN_DEBUG "  rx usage (%4x)  rx hc idx (%x)"
 				  "  rx pkt (%lx)\n",
-		       (u16)(le16_to_cpu(*bp->fp->rx_cons_sb) -
-			     bp->fp->rx_comp_cons),
-		       le16_to_cpu(*bp->fp->rx_cons_sb), nstats->rx_packets);
+		       (u16)(le16_to_cpu(*fp0_rx->rx_cons_sb) -
+			     fp0_rx->rx_comp_cons),
+		       le16_to_cpu(*fp0_rx->rx_cons_sb), nstats->rx_packets);
 		printk(KERN_DEBUG "  %s (Xoff events %u)  brb drops %u  "
 				  "brb truncate %u\n",
 		       (netif_queue_stopped(bp->dev) ? "Xoff" : "Xon"),
@@ -4262,12 +4314,13 @@ static void bnx2x_zero_sb(struct bnx2x *bp, int sb_id)
 {
 	int port = BP_PORT(bp);
 
-	bnx2x_init_fill(bp, USTORM_INTMEM_ADDR +
-			USTORM_SB_HOST_STATUS_BLOCK_OFFSET(port, sb_id), 0,
-			sizeof(struct ustorm_status_block)/4);
-	bnx2x_init_fill(bp, CSTORM_INTMEM_ADDR +
-			CSTORM_SB_HOST_STATUS_BLOCK_OFFSET(port, sb_id), 0,
-			sizeof(struct cstorm_status_block)/4);
+	/* "CSTORM" */
+	bnx2x_init_fill(bp, CSEM_REG_FAST_MEMORY +
+			CSTORM_SB_HOST_STATUS_BLOCK_U_OFFSET(port, sb_id), 0,
+			CSTORM_SB_STATUS_BLOCK_U_SIZE / 4);
+	bnx2x_init_fill(bp, CSEM_REG_FAST_MEMORY +
+			CSTORM_SB_HOST_STATUS_BLOCK_C_OFFSET(port, sb_id), 0,
+			CSTORM_SB_STATUS_BLOCK_C_SIZE / 4);
 }
 
 static void bnx2x_init_sb(struct bnx2x *bp, struct host_status_block *sb,
@@ -4283,17 +4336,17 @@ static void bnx2x_init_sb(struct bnx2x *bp, struct host_status_block *sb,
 					    u_status_block);
 	sb->u_status_block.status_block_id = sb_id;
 
-	REG_WR(bp, BAR_USTRORM_INTMEM +
-	       USTORM_SB_HOST_SB_ADDR_OFFSET(port, sb_id), U64_LO(section));
-	REG_WR(bp, BAR_USTRORM_INTMEM +
-	       ((USTORM_SB_HOST_SB_ADDR_OFFSET(port, sb_id)) + 4),
+	REG_WR(bp, BAR_CSTRORM_INTMEM +
+	       CSTORM_SB_HOST_SB_ADDR_U_OFFSET(port, sb_id), U64_LO(section));
+	REG_WR(bp, BAR_CSTRORM_INTMEM +
+	       ((CSTORM_SB_HOST_SB_ADDR_U_OFFSET(port, sb_id)) + 4),
 	       U64_HI(section));
-	REG_WR8(bp, BAR_USTRORM_INTMEM + FP_USB_FUNC_OFF +
-		USTORM_SB_HOST_STATUS_BLOCK_OFFSET(port, sb_id), func);
+	REG_WR8(bp, BAR_CSTRORM_INTMEM + FP_USB_FUNC_OFF +
+		CSTORM_SB_HOST_STATUS_BLOCK_U_OFFSET(port, sb_id), func);
 
 	for (index = 0; index < HC_USTORM_SB_NUM_INDICES; index++)
-		REG_WR16(bp, BAR_USTRORM_INTMEM +
-			 USTORM_SB_HC_DISABLE_OFFSET(port, sb_id, index), 1);
+		REG_WR16(bp, BAR_CSTRORM_INTMEM +
+			 CSTORM_SB_HC_DISABLE_U_OFFSET(port, sb_id, index), 1);
 
 	/* CSTORM */
 	section = ((u64)mapping) + offsetof(struct host_status_block,
@@ -4301,16 +4354,16 @@ static void bnx2x_init_sb(struct bnx2x *bp, struct host_status_block *sb,
 	sb->c_status_block.status_block_id = sb_id;
 
 	REG_WR(bp, BAR_CSTRORM_INTMEM +
-	       CSTORM_SB_HOST_SB_ADDR_OFFSET(port, sb_id), U64_LO(section));
+	       CSTORM_SB_HOST_SB_ADDR_C_OFFSET(port, sb_id), U64_LO(section));
 	REG_WR(bp, BAR_CSTRORM_INTMEM +
-	       ((CSTORM_SB_HOST_SB_ADDR_OFFSET(port, sb_id)) + 4),
+	       ((CSTORM_SB_HOST_SB_ADDR_C_OFFSET(port, sb_id)) + 4),
 	       U64_HI(section));
 	REG_WR8(bp, BAR_CSTRORM_INTMEM + FP_CSB_FUNC_OFF +
-		CSTORM_SB_HOST_STATUS_BLOCK_OFFSET(port, sb_id), func);
+		CSTORM_SB_HOST_STATUS_BLOCK_C_OFFSET(port, sb_id), func);
 
 	for (index = 0; index < HC_CSTORM_SB_NUM_INDICES; index++)
 		REG_WR16(bp, BAR_CSTRORM_INTMEM +
-			 CSTORM_SB_HC_DISABLE_OFFSET(port, sb_id, index), 1);
+			 CSTORM_SB_HC_DISABLE_C_OFFSET(port, sb_id, index), 1);
 
 	bnx2x_ack_sb(bp, sb_id, CSTORM_ID, 0, IGU_INT_ENABLE, 0);
 }
@@ -4319,16 +4372,16 @@ static void bnx2x_zero_def_sb(struct bnx2x *bp)
 {
 	int func = BP_FUNC(bp);
 
-	bnx2x_init_fill(bp, TSTORM_INTMEM_ADDR +
+	bnx2x_init_fill(bp, TSEM_REG_FAST_MEMORY +
 			TSTORM_DEF_SB_HOST_STATUS_BLOCK_OFFSET(func), 0,
 			sizeof(struct tstorm_def_status_block)/4);
-	bnx2x_init_fill(bp, USTORM_INTMEM_ADDR +
-			USTORM_DEF_SB_HOST_STATUS_BLOCK_OFFSET(func), 0,
-			sizeof(struct ustorm_def_status_block)/4);
-	bnx2x_init_fill(bp, CSTORM_INTMEM_ADDR +
-			CSTORM_DEF_SB_HOST_STATUS_BLOCK_OFFSET(func), 0,
-			sizeof(struct cstorm_def_status_block)/4);
-	bnx2x_init_fill(bp, XSTORM_INTMEM_ADDR +
+	bnx2x_init_fill(bp, CSEM_REG_FAST_MEMORY +
+			CSTORM_DEF_SB_HOST_STATUS_BLOCK_U_OFFSET(func), 0,
+			sizeof(struct cstorm_def_status_block_u)/4);
+	bnx2x_init_fill(bp, CSEM_REG_FAST_MEMORY +
+			CSTORM_DEF_SB_HOST_STATUS_BLOCK_C_OFFSET(func), 0,
+			sizeof(struct cstorm_def_status_block_c)/4);
+	bnx2x_init_fill(bp, XSEM_REG_FAST_MEMORY +
 			XSTORM_DEF_SB_HOST_STATUS_BLOCK_OFFSET(func), 0,
 			sizeof(struct xstorm_def_status_block)/4);
 }
@@ -4380,17 +4433,17 @@ static void bnx2x_init_def_sb(struct bnx2x *bp,
 					    u_def_status_block);
 	def_sb->u_def_status_block.status_block_id = sb_id;
 
-	REG_WR(bp, BAR_USTRORM_INTMEM +
-	       USTORM_DEF_SB_HOST_SB_ADDR_OFFSET(func), U64_LO(section));
-	REG_WR(bp, BAR_USTRORM_INTMEM +
-	       ((USTORM_DEF_SB_HOST_SB_ADDR_OFFSET(func)) + 4),
+	REG_WR(bp, BAR_CSTRORM_INTMEM +
+	       CSTORM_DEF_SB_HOST_SB_ADDR_U_OFFSET(func), U64_LO(section));
+	REG_WR(bp, BAR_CSTRORM_INTMEM +
+	       ((CSTORM_DEF_SB_HOST_SB_ADDR_U_OFFSET(func)) + 4),
 	       U64_HI(section));
-	REG_WR8(bp, BAR_USTRORM_INTMEM + DEF_USB_FUNC_OFF +
-		USTORM_DEF_SB_HOST_STATUS_BLOCK_OFFSET(func), func);
+	REG_WR8(bp, BAR_CSTRORM_INTMEM + DEF_USB_FUNC_OFF +
+		CSTORM_DEF_SB_HOST_STATUS_BLOCK_U_OFFSET(func), func);
 
 	for (index = 0; index < HC_USTORM_DEF_SB_NUM_INDICES; index++)
-		REG_WR16(bp, BAR_USTRORM_INTMEM +
-			 USTORM_DEF_SB_HC_DISABLE_OFFSET(func, index), 1);
+		REG_WR16(bp, BAR_CSTRORM_INTMEM +
+			 CSTORM_DEF_SB_HC_DISABLE_U_OFFSET(func, index), 1);
 
 	/* CSTORM */
 	section = ((u64)mapping) + offsetof(struct host_def_status_block,
@@ -4398,16 +4451,16 @@ static void bnx2x_init_def_sb(struct bnx2x *bp,
 	def_sb->c_def_status_block.status_block_id = sb_id;
 
 	REG_WR(bp, BAR_CSTRORM_INTMEM +
-	       CSTORM_DEF_SB_HOST_SB_ADDR_OFFSET(func), U64_LO(section));
+	       CSTORM_DEF_SB_HOST_SB_ADDR_C_OFFSET(func), U64_LO(section));
 	REG_WR(bp, BAR_CSTRORM_INTMEM +
-	       ((CSTORM_DEF_SB_HOST_SB_ADDR_OFFSET(func)) + 4),
+	       ((CSTORM_DEF_SB_HOST_SB_ADDR_C_OFFSET(func)) + 4),
 	       U64_HI(section));
 	REG_WR8(bp, BAR_CSTRORM_INTMEM + DEF_CSB_FUNC_OFF +
-		CSTORM_DEF_SB_HOST_STATUS_BLOCK_OFFSET(func), func);
+		CSTORM_DEF_SB_HOST_STATUS_BLOCK_C_OFFSET(func), func);
 
 	for (index = 0; index < HC_CSTORM_DEF_SB_NUM_INDICES; index++)
 		REG_WR16(bp, BAR_CSTRORM_INTMEM +
-			 CSTORM_DEF_SB_HC_DISABLE_OFFSET(func, index), 1);
+			 CSTORM_DEF_SB_HC_DISABLE_C_OFFSET(func, index), 1);
 
 	/* TSTORM */
 	section = ((u64)mapping) + offsetof(struct host_def_status_block,
@@ -4458,23 +4511,23 @@ static void bnx2x_update_coalesce(struct bnx2x *bp)
 		int sb_id = bp->fp[i].sb_id;
 
 		/* HC_INDEX_U_ETH_RX_CQ_CONS */
-		REG_WR8(bp, BAR_USTRORM_INTMEM +
-			USTORM_SB_HC_TIMEOUT_OFFSET(port, sb_id,
-						    U_SB_ETH_RX_CQ_INDEX),
+		REG_WR8(bp, BAR_CSTRORM_INTMEM +
+			CSTORM_SB_HC_TIMEOUT_U_OFFSET(port, sb_id,
+						      U_SB_ETH_RX_CQ_INDEX),
 			bp->rx_ticks/12);
-		REG_WR16(bp, BAR_USTRORM_INTMEM +
-			 USTORM_SB_HC_DISABLE_OFFSET(port, sb_id,
-						     U_SB_ETH_RX_CQ_INDEX),
+		REG_WR16(bp, BAR_CSTRORM_INTMEM +
+			 CSTORM_SB_HC_DISABLE_U_OFFSET(port, sb_id,
+						       U_SB_ETH_RX_CQ_INDEX),
 			 (bp->rx_ticks/12) ? 0 : 1);
 
 		/* HC_INDEX_C_ETH_TX_CQ_CONS */
 		REG_WR8(bp, BAR_CSTRORM_INTMEM +
-			CSTORM_SB_HC_TIMEOUT_OFFSET(port, sb_id,
-						    C_SB_ETH_TX_CQ_INDEX),
+			CSTORM_SB_HC_TIMEOUT_C_OFFSET(port, sb_id,
+						      C_SB_ETH_TX_CQ_INDEX),
 			bp->tx_ticks/12);
 		REG_WR16(bp, BAR_CSTRORM_INTMEM +
-			 CSTORM_SB_HC_DISABLE_OFFSET(port, sb_id,
-						     C_SB_ETH_TX_CQ_INDEX),
+			 CSTORM_SB_HC_DISABLE_C_OFFSET(port, sb_id,
+						       C_SB_ETH_TX_CQ_INDEX),
 			 (bp->tx_ticks/12) ? 0 : 1);
 	}
 }
@@ -4547,6 +4600,9 @@ static void bnx2x_init_rx_rings(struct bnx2x *bp)
 		fp->rx_cons_sb = BNX2X_RX_SB_INDEX;
 		fp->rx_bd_cons_sb = BNX2X_RX_SB_BD_INDEX;
 
+		/* Mark queue as Rx */
+		fp->is_rx_queue = 1;
+
 		/* "next page" elements initialization */
 		/* SGE ring */
 		for (i = 1; i <= NUM_RX_SGE_PAGES; i++) {
@@ -4656,17 +4712,21 @@ static void bnx2x_init_tx_ring(struct bnx2x *bp)
 		struct bnx2x_fastpath *fp = &bp->fp[j];
 
 		for (i = 1; i <= NUM_TX_RINGS; i++) {
-			struct eth_tx_bd *tx_bd =
-				&fp->tx_desc_ring[TX_DESC_CNT * i - 1];
+			struct eth_tx_next_bd *tx_next_bd =
+				&fp->tx_desc_ring[TX_DESC_CNT * i - 1].next_bd;
 
-			tx_bd->addr_hi =
+			tx_next_bd->addr_hi =
 				cpu_to_le32(U64_HI(fp->tx_desc_mapping +
 					    BCM_PAGE_SIZE*(i % NUM_TX_RINGS)));
-			tx_bd->addr_lo =
+			tx_next_bd->addr_lo =
 				cpu_to_le32(U64_LO(fp->tx_desc_mapping +
 					    BCM_PAGE_SIZE*(i % NUM_TX_RINGS)));
 		}
 
+		fp->tx_db.data.header.header = DOORBELL_HDR_DB_TYPE;
+		fp->tx_db.data.zero_fill1 = 0;
+		fp->tx_db.data.prod = 0;
+
 		fp->tx_pkt_prod = 0;
 		fp->tx_pkt_cons = 0;
 		fp->tx_bd_prod = 0;
@@ -4702,16 +4762,15 @@ static void bnx2x_init_context(struct bnx2x *bp)
 {
 	int i;
 
-	for_each_queue(bp, i) {
+	for_each_rx_queue(bp, i) {
 		struct eth_context *context = bnx2x_sp(bp, context[i].eth);
 		struct bnx2x_fastpath *fp = &bp->fp[i];
 		u8 cl_id = fp->cl_id;
-		u8 sb_id = fp->sb_id;
 
 		context->ustorm_st_context.common.sb_index_numbers =
 						BNX2X_RX_SB_INDEX_NUM;
 		context->ustorm_st_context.common.clientId = cl_id;
-		context->ustorm_st_context.common.status_block_id = sb_id;
+		context->ustorm_st_context.common.status_block_id = fp->sb_id;
 		context->ustorm_st_context.common.flags =
 			(USTORM_ETH_ST_CONTEXT_CONFIG_ENABLE_MC_ALIGNMENT |
 			 USTORM_ETH_ST_CONTEXT_CONFIG_ENABLE_STATISTICS);
@@ -4727,8 +4786,7 @@ static void bnx2x_init_context(struct bnx2x *bp)
 						U64_LO(fp->rx_desc_mapping);
 		if (!fp->disable_tpa) {
 			context->ustorm_st_context.common.flags |=
-				(USTORM_ETH_ST_CONTEXT_CONFIG_ENABLE_TPA |
-				 USTORM_ETH_ST_CONTEXT_CONFIG_ENABLE_SGE_RING);
+				USTORM_ETH_ST_CONTEXT_CONFIG_ENABLE_TPA;
 			context->ustorm_st_context.common.sge_buff_size =
 				(u16)min((u32)SGE_PAGE_SIZE*PAGES_PER_SGE,
 					 (u32)0xffff);
@@ -4736,6 +4794,13 @@ static void bnx2x_init_context(struct bnx2x *bp)
 						U64_HI(fp->rx_sge_mapping);
 			context->ustorm_st_context.common.sge_page_base_lo =
 						U64_LO(fp->rx_sge_mapping);
+
+			context->ustorm_st_context.common.max_sges_for_packet =
+				SGE_PAGE_ALIGN(bp->dev->mtu) >> SGE_PAGE_SHIFT;
+			context->ustorm_st_context.common.max_sges_for_packet =
+				((context->ustorm_st_context.common.
+				  max_sges_for_packet + PAGES_PER_SGE - 1) &
+				 (~(PAGES_PER_SGE - 1))) >> PAGES_PER_SGE_SHIFT;
 		}
 
 		context->ustorm_ag_context.cdu_usage =
@@ -4743,24 +4808,27 @@ static void bnx2x_init_context(struct bnx2x *bp)
 					       CDU_REGION_NUMBER_UCM_AG,
 					       ETH_CONNECTION_TYPE);
 
+		context->xstorm_ag_context.cdu_reserved =
+			CDU_RSRVD_VALUE_TYPE_A(HW_CID(bp, i),
+					       CDU_REGION_NUMBER_XCM_AG,
+					       ETH_CONNECTION_TYPE);
+	}
+
+	for_each_tx_queue(bp, i) {
+		struct bnx2x_fastpath *fp = &bp->fp[i];
+		struct eth_context *context =
+			bnx2x_sp(bp, context[i - bp->num_rx_queues].eth);
+
+		context->cstorm_st_context.sb_index_number =
+						C_SB_ETH_TX_CQ_INDEX;
+		context->cstorm_st_context.status_block_id = fp->sb_id;
+
 		context->xstorm_st_context.tx_bd_page_base_hi =
 						U64_HI(fp->tx_desc_mapping);
 		context->xstorm_st_context.tx_bd_page_base_lo =
 						U64_LO(fp->tx_desc_mapping);
-		context->xstorm_st_context.db_data_addr_hi =
-						U64_HI(fp->tx_prods_mapping);
-		context->xstorm_st_context.db_data_addr_lo =
-						U64_LO(fp->tx_prods_mapping);
-		context->xstorm_st_context.statistics_data = (cl_id |
+		context->xstorm_st_context.statistics_data = (fp->cl_id |
 				XSTORM_ETH_ST_CONTEXT_STATISTICS_ENABLE);
-		context->cstorm_st_context.sb_index_number =
-						C_SB_ETH_TX_CQ_INDEX;
-		context->cstorm_st_context.status_block_id = sb_id;
-
-		context->xstorm_ag_context.cdu_reserved =
-			CDU_RSRVD_VALUE_TYPE_A(HW_CID(bp, i),
-					       CDU_REGION_NUMBER_XCM_AG,
-					       ETH_CONNECTION_TYPE);
 	}
 }
 
@@ -4798,18 +4866,6 @@ static void bnx2x_set_client_config(struct bnx2x *bp)
 	}
 #endif
 
-	if (bp->flags & TPA_ENABLE_FLAG) {
-		tstorm_client.max_sges_for_packet =
-			SGE_PAGE_ALIGN(tstorm_client.mtu) >> SGE_PAGE_SHIFT;
-		tstorm_client.max_sges_for_packet =
-			((tstorm_client.max_sges_for_packet +
-			  PAGES_PER_SGE - 1) & (~(PAGES_PER_SGE - 1))) >>
-			PAGES_PER_SGE_SHIFT;
-
-		tstorm_client.config_flags |=
-				TSTORM_ETH_CLIENT_CONFIG_ENABLE_SGE_RING;
-	}
-
 	for_each_queue(bp, i) {
 		tstorm_client.statistics_counter_id = bp->fp[i].cl_id;
 
@@ -4892,17 +4948,6 @@ static void bnx2x_init_internal_common(struct bnx2x *bp)
 {
 	int i;
 
-	if (bp->flags & TPA_ENABLE_FLAG) {
-		struct tstorm_eth_tpa_exist tpa = {0};
-
-		tpa.tpa_exist = 1;
-
-		REG_WR(bp, BAR_TSTRORM_INTMEM + TSTORM_TPA_EXIST_OFFSET,
-		       ((u32 *)&tpa)[0]);
-		REG_WR(bp, BAR_TSTRORM_INTMEM + TSTORM_TPA_EXIST_OFFSET + 4,
-		       ((u32 *)&tpa)[1]);
-	}
-
 	/* Zero this manually as its initialization is
 	   currently missing in the initTool */
 	for (i = 0; i < (USTORM_AGG_DATA_SIZE >> 2); i++)
@@ -4914,8 +4959,10 @@ static void bnx2x_init_internal_port(struct bnx2x *bp)
 {
 	int port = BP_PORT(bp);
 
-	REG_WR(bp, BAR_USTRORM_INTMEM + USTORM_HC_BTR_OFFSET(port), BNX2X_BTR);
-	REG_WR(bp, BAR_CSTRORM_INTMEM + CSTORM_HC_BTR_OFFSET(port), BNX2X_BTR);
+	REG_WR(bp,
+	       BAR_CSTRORM_INTMEM + CSTORM_HC_BTR_U_OFFSET(port), BNX2X_BTR);
+	REG_WR(bp,
+	       BAR_CSTRORM_INTMEM + CSTORM_HC_BTR_C_OFFSET(port), BNX2X_BTR);
 	REG_WR(bp, BAR_TSTRORM_INTMEM + TSTORM_HC_BTR_OFFSET(port), BNX2X_BTR);
 	REG_WR(bp, BAR_XSTRORM_INTMEM + XSTORM_HC_BTR_OFFSET(port), BNX2X_BTR);
 }
@@ -4975,6 +5022,12 @@ static void bnx2x_init_internal_func(struct bnx2x *bp)
 		tstorm_config.config_flags = MULTI_FLAGS(bp);
 		tstorm_config.rss_result_mask = MULTI_MASK;
 	}
+
+	/* Enable TPA if needed */
+	if (bp->flags & TPA_ENABLE_FLAG)
+		tstorm_config.config_flags |=
+			TSTORM_ETH_FUNCTION_COMMON_CONFIG_ENABLE_TPA;
+
 	if (IS_E1HMF(bp))
 		tstorm_config.config_flags |=
 				TSTORM_ETH_FUNCTION_COMMON_CONFIG_E1HOV_IN_CAM;
@@ -5086,6 +5139,14 @@ static void bnx2x_init_internal_func(struct bnx2x *bp)
 		       USTORM_CQE_PAGE_BASE_OFFSET(port, fp->cl_id) + 4,
 		       U64_HI(fp->rx_comp_mapping));
 
+		/* Next page */
+		REG_WR(bp, BAR_USTRORM_INTMEM +
+		       USTORM_CQE_PAGE_NEXT_OFFSET(port, fp->cl_id),
+		       U64_LO(fp->rx_comp_mapping + BCM_PAGE_SIZE));
+		REG_WR(bp, BAR_USTRORM_INTMEM +
+		       USTORM_CQE_PAGE_NEXT_OFFSET(port, fp->cl_id) + 4,
+		       U64_HI(fp->rx_comp_mapping + BCM_PAGE_SIZE));
+
 		REG_WR16(bp, BAR_USTRORM_INTMEM +
 			 USTORM_MAX_AGG_SIZE_OFFSET(port, fp->cl_id),
 			 max_agg_size);
@@ -5196,6 +5257,9 @@ static void bnx2x_nic_init(struct bnx2x *bp, u32 load_code)
 		fp->index = i;
 		fp->cl_id = BP_L_ID(bp) + i;
 		fp->sb_id = fp->cl_id;
+		/* Suitable Rx and Tx SBs are served by the same client */
+		if (i >= bp->num_rx_queues)
+			fp->cl_id -= bp->num_rx_queues;
 		DP(NETIF_MSG_IFUP,
 		   "queue[%d]:  bnx2x_init_sb(%p,%p)  cl_id %d  sb %d\n",
 		   i, bp, fp->status_blk, fp->cl_id, fp->sb_id);
@@ -5728,10 +5792,10 @@ static int bnx2x_init_common(struct bnx2x *bp)
 	bnx2x_init_block(bp, USDM_BLOCK, COMMON_STAGE);
 	bnx2x_init_block(bp, XSDM_BLOCK, COMMON_STAGE);
 
-	bnx2x_init_fill(bp, TSTORM_INTMEM_ADDR, 0, STORM_INTMEM_SIZE(bp));
-	bnx2x_init_fill(bp, USTORM_INTMEM_ADDR, 0, STORM_INTMEM_SIZE(bp));
-	bnx2x_init_fill(bp, CSTORM_INTMEM_ADDR, 0, STORM_INTMEM_SIZE(bp));
-	bnx2x_init_fill(bp, XSTORM_INTMEM_ADDR, 0, STORM_INTMEM_SIZE(bp));
+	bnx2x_init_fill(bp, TSEM_REG_FAST_MEMORY, 0, STORM_INTMEM_SIZE(bp));
+	bnx2x_init_fill(bp, USEM_REG_FAST_MEMORY, 0, STORM_INTMEM_SIZE(bp));
+	bnx2x_init_fill(bp, CSEM_REG_FAST_MEMORY, 0, STORM_INTMEM_SIZE(bp));
+	bnx2x_init_fill(bp, XSEM_REG_FAST_MEMORY, 0, STORM_INTMEM_SIZE(bp));
 
 	bnx2x_init_block(bp, TSEM_BLOCK, COMMON_STAGE);
 	bnx2x_init_block(bp, USEM_BLOCK, COMMON_STAGE);
@@ -5764,11 +5828,6 @@ static int bnx2x_init_common(struct bnx2x *bp)
 	bnx2x_init_block(bp, CDU_BLOCK, COMMON_STAGE);
 	val = (4 << 24) + (0 << 12) + 1024;
 	REG_WR(bp, CDU_REG_CDU_GLOBAL_PARAMS, val);
-	if (CHIP_IS_E1(bp)) {
-		/* !!! fix pxp client crdit until excel update */
-		REG_WR(bp, CDU_REG_CDU_DEBUG, 0x264);
-		REG_WR(bp, CDU_REG_CDU_DEBUG, 0);
-	}
 
 	bnx2x_init_block(bp, CFC_BLOCK, COMMON_STAGE);
 	REG_WR(bp, CFC_REG_INIT_REG, 0x7FF);
@@ -5781,19 +5840,14 @@ static int bnx2x_init_common(struct bnx2x *bp)
 	bnx2x_init_block(bp, HC_BLOCK, COMMON_STAGE);
 	bnx2x_init_block(bp, MISC_AEU_BLOCK, COMMON_STAGE);
 
-	/* PXPCS COMMON comes here */
 	bnx2x_init_block(bp, PXPCS_BLOCK, COMMON_STAGE);
 	/* Reset PCIE errors for debug */
 	REG_WR(bp, 0x2814, 0xffffffff);
 	REG_WR(bp, 0x3820, 0xffffffff);
 
-	/* EMAC0 COMMON comes here */
 	bnx2x_init_block(bp, EMAC0_BLOCK, COMMON_STAGE);
-	/* EMAC1 COMMON comes here */
 	bnx2x_init_block(bp, EMAC1_BLOCK, COMMON_STAGE);
-	/* DBU COMMON comes here */
 	bnx2x_init_block(bp, DBU_BLOCK, COMMON_STAGE);
-	/* DBG COMMON comes here */
 	bnx2x_init_block(bp, DBG_BLOCK, COMMON_STAGE);
 
 	bnx2x_init_block(bp, NIG_BLOCK, COMMON_STAGE);
@@ -5874,10 +5928,12 @@ static int bnx2x_init_port(struct bnx2x *bp)
 
 	REG_WR(bp, NIG_REG_MASK_INTERRUPT_PORT0 + port*4, 0);
 
-	/* Port PXP comes here */
 	bnx2x_init_block(bp, PXP_BLOCK, init_stage);
-	/* Port PXP2 comes here */
 	bnx2x_init_block(bp, PXP2_BLOCK, init_stage);
+
+	bnx2x_init_block(bp, TCM_BLOCK, init_stage);
+	bnx2x_init_block(bp, UCM_BLOCK, init_stage);
+	bnx2x_init_block(bp, CCM_BLOCK, init_stage);
 #ifdef BCM_ISCSI
 	/* Port0  1
 	 * Port1  385 */
@@ -5903,17 +5959,14 @@ static int bnx2x_init_port(struct bnx2x *bp)
 	REG_WR_DMAE(bp, PXP2_REG_RQ_ONCHIP_AT + i*8, wb_write, 2);
 	REG_WR(bp, PXP2_REG_PSWRQ_SRC0_L2P + func*4, PXP_ONE_ILT(i));
 #endif
-	/* Port CMs come here */
 	bnx2x_init_block(bp, XCM_BLOCK, init_stage);
 
-	/* Port QM comes here */
 #ifdef BCM_ISCSI
 	REG_WR(bp, TM_REG_LIN0_SCAN_TIME + func*4, 1024/64*20);
 	REG_WR(bp, TM_REG_LIN0_MAX_ACTIVE_CID + func*4, 31);
 
 	bnx2x_init_block(bp, TIMERS_BLOCK, init_stage);
 #endif
-	/* Port DQ comes here */
 	bnx2x_init_block(bp, DQ_BLOCK, init_stage);
 
 	bnx2x_init_block(bp, BRB1_BLOCK, init_stage);
@@ -5940,15 +5993,11 @@ static int bnx2x_init_port(struct bnx2x *bp)
 	REG_WR(bp, BRB1_REG_PAUSE_HIGH_THRESHOLD_0 + port*4, high);
 
 
-	/* Port PRS comes here */
 	bnx2x_init_block(bp, PRS_BLOCK, init_stage);
-	/* Port TSDM comes here */
+
 	bnx2x_init_block(bp, TSDM_BLOCK, init_stage);
-	/* Port CSDM comes here */
 	bnx2x_init_block(bp, CSDM_BLOCK, init_stage);
-	/* Port USDM comes here */
 	bnx2x_init_block(bp, USDM_BLOCK, init_stage);
-	/* Port XSDM comes here */
 	bnx2x_init_block(bp, XSDM_BLOCK, init_stage);
 
 	bnx2x_init_block(bp, TSEM_BLOCK, init_stage);
@@ -5956,9 +6005,7 @@ static int bnx2x_init_port(struct bnx2x *bp)
 	bnx2x_init_block(bp, CSEM_BLOCK, init_stage);
 	bnx2x_init_block(bp, XSEM_BLOCK, init_stage);
 
-	/* Port UPB comes here */
 	bnx2x_init_block(bp, UPB_BLOCK, init_stage);
-	/* Port XPB comes here */
 	bnx2x_init_block(bp, XPB_BLOCK, init_stage);
 
 	bnx2x_init_block(bp, PBF_BLOCK, init_stage);
@@ -5988,11 +6035,8 @@ static int bnx2x_init_port(struct bnx2x *bp)
 	REG_WR_DMAE(bp, SRC_REG_LASTFREE0 + func*4, wb_write, 2);
 
 	REG_WR(bp, SRC_REG_NUMBER_HASH_BITS0 + func*4, 10);
-	/* Port SRCH comes here */
 #endif
-	/* Port CDU comes here */
 	bnx2x_init_block(bp, CDU_BLOCK, init_stage);
-	/* Port CFC comes here */
 	bnx2x_init_block(bp, CFC_BLOCK, init_stage);
 
 	if (CHIP_IS_E1(bp)) {
@@ -6009,15 +6053,10 @@ static int bnx2x_init_port(struct bnx2x *bp)
 	REG_WR(bp, MISC_REG_AEU_MASK_ATTN_FUNC_0 + port*4,
 	       (IS_E1HMF(bp) ? 0xF7 : 0x7));
 
-	/* Port PXPCS comes here */
 	bnx2x_init_block(bp, PXPCS_BLOCK, init_stage);
-	/* Port EMAC0 comes here */
 	bnx2x_init_block(bp, EMAC0_BLOCK, init_stage);
-	/* Port EMAC1 comes here */
 	bnx2x_init_block(bp, EMAC1_BLOCK, init_stage);
-	/* Port DBU comes here */
 	bnx2x_init_block(bp, DBU_BLOCK, init_stage);
-	/* Port DBG comes here */
 	bnx2x_init_block(bp, DBG_BLOCK, init_stage);
 
 	bnx2x_init_block(bp, NIG_BLOCK, init_stage);
@@ -6039,9 +6078,7 @@ static int bnx2x_init_port(struct bnx2x *bp)
 		}
 	}
 
-	/* Port MCP comes here */
 	bnx2x_init_block(bp, MCP_BLOCK, init_stage);
-	/* Port DMAE comes here */
 	bnx2x_init_block(bp, DMAE_BLOCK, init_stage);
 
 	switch (XGXS_EXT_PHY_TYPE(bp->link_params.ext_phy_config)) {
@@ -6301,8 +6338,7 @@ static void bnx2x_free_mem(struct bnx2x *bp)
 		/* status blocks */
 		BNX2X_PCI_FREE(bnx2x_fp(bp, i, status_blk),
 			       bnx2x_fp(bp, i, status_blk_mapping),
-			       sizeof(struct host_status_block) +
-			       sizeof(struct eth_tx_db_data));
+			       sizeof(struct host_status_block));
 	}
 	/* Rx */
 	for_each_rx_queue(bp, i) {
@@ -6331,7 +6367,7 @@ static void bnx2x_free_mem(struct bnx2x *bp)
 		BNX2X_FREE(bnx2x_fp(bp, i, tx_buf_ring));
 		BNX2X_PCI_FREE(bnx2x_fp(bp, i, tx_desc_ring),
 			       bnx2x_fp(bp, i, tx_desc_mapping),
-			       sizeof(struct eth_tx_bd) * NUM_TX_BD);
+			       sizeof(union eth_tx_bd_types) * NUM_TX_BD);
 	}
 	/* end of fastpath */
 
@@ -6382,8 +6418,7 @@ static int bnx2x_alloc_mem(struct bnx2x *bp)
 		/* status blocks */
 		BNX2X_PCI_ALLOC(bnx2x_fp(bp, i, status_blk),
 				&bnx2x_fp(bp, i, status_blk_mapping),
-				sizeof(struct host_status_block) +
-				sizeof(struct eth_tx_db_data));
+				sizeof(struct host_status_block));
 	}
 	/* Rx */
 	for_each_rx_queue(bp, i) {
@@ -6410,19 +6445,12 @@ static int bnx2x_alloc_mem(struct bnx2x *bp)
 	/* Tx */
 	for_each_tx_queue(bp, i) {
 
-		bnx2x_fp(bp, i, hw_tx_prods) =
-				(void *)(bnx2x_fp(bp, i, status_blk) + 1);
-
-		bnx2x_fp(bp, i, tx_prods_mapping) =
-				bnx2x_fp(bp, i, status_blk_mapping) +
-				sizeof(struct host_status_block);
-
 		/* fastpath tx rings: tx_buf tx_desc */
 		BNX2X_ALLOC(bnx2x_fp(bp, i, tx_buf_ring),
 				sizeof(struct sw_tx_bd) * NUM_TX_BD);
 		BNX2X_PCI_ALLOC(bnx2x_fp(bp, i, tx_desc_ring),
 				&bnx2x_fp(bp, i, tx_desc_mapping),
-				sizeof(struct eth_tx_bd) * NUM_TX_BD);
+				sizeof(union eth_tx_bd_types) * NUM_TX_BD);
 	}
 	/* end of fastpath */
 
@@ -6599,7 +6627,12 @@ static int bnx2x_req_msix_irqs(struct bnx2x *bp)
 	for_each_queue(bp, i) {
 		struct bnx2x_fastpath *fp = &bp->fp[i];
 
-		sprintf(fp->name, "%s.fp%d", bp->dev->name, i);
+		if (i < bp->num_rx_queues)
+			sprintf(fp->name, "%s-rx-%d", bp->dev->name, i);
+		else
+			sprintf(fp->name, "%s-tx-%d",
+				bp->dev->name, i - bp->num_rx_queues);
+
 		rc = request_irq(bp->msix_table[i + offset].vector,
 				 bnx2x_msix_fp_int, 0, fp->name, fp);
 		if (rc) {
@@ -6612,16 +6645,11 @@ static int bnx2x_req_msix_irqs(struct bnx2x *bp)
 	}
 
 	i = BNX2X_NUM_QUEUES(bp);
-	if (is_multi(bp))
-		printk(KERN_INFO PFX
-		       "%s: using MSI-X  IRQs: sp %d  fp %d - %d\n",
-		       bp->dev->name, bp->msix_table[0].vector,
-		       bp->msix_table[offset].vector,
-		       bp->msix_table[offset + i - 1].vector);
-	else
-		printk(KERN_INFO PFX "%s: using MSI-X  IRQs: sp %d  fp %d\n",
-		       bp->dev->name, bp->msix_table[0].vector,
-		       bp->msix_table[offset + i - 1].vector);
+	printk(KERN_INFO PFX "%s: using MSI-X  IRQs: sp %d  fp[%d] %d"
+	       " ... fp[%d] %d\n",
+	       bp->dev->name, bp->msix_table[0].vector,
+	       0, bp->msix_table[offset].vector,
+	       i - 1, bp->msix_table[offset + i - 1].vector);
 
 	return 0;
 }
@@ -6729,7 +6757,8 @@ static void bnx2x_set_mac_addr_e1(struct bnx2x *bp, int set)
 		config->config_table[0].target_table_entry.flags = 0;
 	else
 		CAM_INVALIDATE(config->config_table[0]);
-	config->config_table[0].target_table_entry.client_id = 0;
+	config->config_table[0].target_table_entry.clients_bit_vector =
+						cpu_to_le32(1 << BP_L_ID(bp));
 	config->config_table[0].target_table_entry.vlan_id = 0;
 
 	DP(NETIF_MSG_IFUP, "%s MAC (%04x:%04x:%04x)\n",
@@ -6748,7 +6777,8 @@ static void bnx2x_set_mac_addr_e1(struct bnx2x *bp, int set)
 				TSTORM_CAM_TARGET_TABLE_ENTRY_BROADCAST;
 	else
 		CAM_INVALIDATE(config->config_table[1]);
-	config->config_table[1].target_table_entry.client_id = 0;
+	config->config_table[1].target_table_entry.clients_bit_vector =
+						cpu_to_le32(1 << BP_L_ID(bp));
 	config->config_table[1].target_table_entry.vlan_id = 0;
 
 	bnx2x_sp_post(bp, RAMROD_CMD_ID_ETH_SET_MAC, 0,
@@ -6761,11 +6791,6 @@ static void bnx2x_set_mac_addr_e1h(struct bnx2x *bp, int set)
 	struct mac_configuration_cmd_e1h *config =
 		(struct mac_configuration_cmd_e1h *)bnx2x_sp(bp, mac_config);
 
-	if (set && (bp->state != BNX2X_STATE_OPEN)) {
-		DP(NETIF_MSG_IFUP, "state is %x, returning\n", bp->state);
-		return;
-	}
-
 	/* CAM allocation for E1H
 	 * unicasts: by func number
 	 * multicast: 20+FUNC*20, 20 each
@@ -6782,7 +6807,8 @@ static void bnx2x_set_mac_addr_e1h(struct bnx2x *bp, int set)
 					swab16(*(u16 *)&bp->dev->dev_addr[2]);
 	config->config_table[0].lsb_mac_addr =
 					swab16(*(u16 *)&bp->dev->dev_addr[4]);
-	config->config_table[0].client_id = BP_L_ID(bp);
+	config->config_table[0].clients_bit_vector =
+					cpu_to_le32(1 << BP_L_ID(bp));
 	config->config_table[0].vlan_id = 0;
 	config->config_table[0].e1hov_id = cpu_to_le16(bp->e1hov);
 	if (set)
@@ -6879,49 +6905,94 @@ static int bnx2x_setup_multi(struct bnx2x *bp, int index)
 
 static int bnx2x_poll(struct napi_struct *napi, int budget);
 
-static void bnx2x_set_int_mode(struct bnx2x *bp)
+static void bnx2x_set_int_mode_msix(struct bnx2x *bp, int *num_rx_queues_out,
+				    int *num_tx_queues_out)
+{
+	int _num_rx_queues = 0, _num_tx_queues = 0;
+
+	switch (bp->multi_mode) {
+	case ETH_RSS_MODE_DISABLED:
+		_num_rx_queues = 1;
+		_num_tx_queues = 1;
+		break;
+
+	case ETH_RSS_MODE_REGULAR:
+		if (num_rx_queues)
+			_num_rx_queues = min_t(u32, num_rx_queues,
+					       BNX2X_MAX_QUEUES(bp));
+		else
+			_num_rx_queues = min_t(u32, num_online_cpus(),
+					       BNX2X_MAX_QUEUES(bp));
+
+		if (num_tx_queues)
+			_num_tx_queues = min_t(u32, num_tx_queues,
+					       BNX2X_MAX_QUEUES(bp));
+		else
+			_num_tx_queues = min_t(u32, num_online_cpus(),
+					       BNX2X_MAX_QUEUES(bp));
+
+		/* There must be not more Tx queues than Rx queues */
+		if (_num_tx_queues > _num_rx_queues) {
+			BNX2X_ERR("number of tx queues (%d) > "
+				  "number of rx queues (%d)"
+				  "  defaulting to %d\n",
+				  _num_tx_queues, _num_rx_queues,
+				  _num_rx_queues);
+			_num_tx_queues = _num_rx_queues;
+		}
+		break;
+
+
+	default:
+		_num_rx_queues = 1;
+		_num_tx_queues = 1;
+		break;
+	}
+
+	*num_rx_queues_out = _num_rx_queues;
+	*num_tx_queues_out = _num_tx_queues;
+}
+
+static int bnx2x_set_int_mode(struct bnx2x *bp)
 {
-	int num_queues;
+	int rc = 0;
 
 	switch (int_mode) {
 	case INT_MODE_INTx:
 	case INT_MODE_MSI:
-		num_queues = 1;
-		bp->num_rx_queues = num_queues;
-		bp->num_tx_queues = num_queues;
-		DP(NETIF_MSG_IFUP,
-		   "set number of queues to %d\n", num_queues);
+		bp->num_rx_queues = 1;
+		bp->num_tx_queues = 1;
+		DP(NETIF_MSG_IFUP, "set number of queues to 1\n");
 		break;
 
 	case INT_MODE_MSIX:
 	default:
-		if (bp->multi_mode == ETH_RSS_MODE_REGULAR)
-			num_queues = min_t(u32, num_online_cpus(),
-					   BNX2X_MAX_QUEUES(bp));
-		else
-			num_queues = 1;
-		bp->num_rx_queues = num_queues;
-		bp->num_tx_queues = num_queues;
-		DP(NETIF_MSG_IFUP, "set number of rx queues to %d"
-		   "  number of tx queues to %d\n",
+		/* Set interrupt mode according to bp->multi_mode value */
+		bnx2x_set_int_mode_msix(bp, &bp->num_rx_queues,
+					&bp->num_tx_queues);
+
+		DP(NETIF_MSG_IFUP, "set number of queues to: rx %d tx %d\n",
 		   bp->num_rx_queues, bp->num_tx_queues);
+
 		/* if we can't use MSI-X we only need one fp,
 		 * so try to enable MSI-X with the requested number of fp's
 		 * and fallback to MSI or legacy INTx with one fp
 		 */
-		if (bnx2x_enable_msix(bp)) {
+		rc = bnx2x_enable_msix(bp);
+		if (rc) {
 			/* failed to enable MSI-X */
-			num_queues = 1;
-			bp->num_rx_queues = num_queues;
-			bp->num_tx_queues = num_queues;
 			if (bp->multi_mode)
 				BNX2X_ERR("Multi requested but failed to "
-					  "enable MSI-X  set number of "
-					  "queues to %d\n", num_queues);
+					  "enable MSI-X (rx %d tx %d), "
+					  "set number of queues to 1\n",
+					  bp->num_rx_queues, bp->num_tx_queues);
+			bp->num_rx_queues = 1;
+			bp->num_tx_queues = 1;
 		}
 		break;
 	}
 	bp->dev->real_num_tx_queues = bp->num_tx_queues;
+	return rc;
 }
 
 static void bnx2x_set_rx_mode(struct net_device *dev);
@@ -6930,16 +7001,16 @@ static void bnx2x_set_rx_mode(struct net_device *dev);
 static int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
 {
 	u32 load_code;
-	int i, rc = 0;
+	int i, rc;
+
 #ifdef BNX2X_STOP_ON_ERROR
-	DP(NETIF_MSG_IFUP, "enter  load_mode %d\n", load_mode);
 	if (unlikely(bp->panic))
 		return -EPERM;
 #endif
 
 	bp->state = BNX2X_STATE_OPENING_WAIT4_LOAD;
 
-	bnx2x_set_int_mode(bp);
+	rc = bnx2x_set_int_mode(bp);
 
 	if (bnx2x_alloc_mem(bp))
 		return -ENOMEM;
@@ -6952,17 +7023,6 @@ static int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
 		netif_napi_add(bp->dev, &bnx2x_fp(bp, i, napi),
 			       bnx2x_poll, 128);
 
-#ifdef BNX2X_STOP_ON_ERROR
-	for_each_rx_queue(bp, i) {
-		struct bnx2x_fastpath *fp = &bp->fp[i];
-
-		fp->poll_no_work = 0;
-		fp->poll_calls = 0;
-		fp->poll_max_calls = 0;
-		fp->poll_complete = 0;
-		fp->poll_exit = 0;
-	}
-#endif
 	bnx2x_napi_enable(bp);
 
 	if (bp->flags & USING_MSIX_FLAG) {
@@ -6972,6 +7032,8 @@ static int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
 			goto load_error1;
 		}
 	} else {
+		/* Fall to INTx if failed to enable MSI-X due to lack of
+		   memory (in bnx2x_set_int_mode()) */
 		if ((rc != -ENOMEM) && (int_mode != INT_MODE_INTx))
 			bnx2x_enable_msi(bp);
 		bnx2x_ack_int(bp);
@@ -7064,17 +7126,18 @@ static int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
 			bp->state = BNX2X_STATE_DISABLED;
 		}
 
-	if (bp->state == BNX2X_STATE_OPEN)
+	if (bp->state == BNX2X_STATE_OPEN) {
 		for_each_nondefault_queue(bp, i) {
 			rc = bnx2x_setup_multi(bp, i);
 			if (rc)
 				goto load_error3;
 		}
 
-	if (CHIP_IS_E1(bp))
-		bnx2x_set_mac_addr_e1(bp, 1);
-	else
-		bnx2x_set_mac_addr_e1h(bp, 1);
+		if (CHIP_IS_E1(bp))
+			bnx2x_set_mac_addr_e1(bp, 1);
+		else
+			bnx2x_set_mac_addr_e1h(bp, 1);
+	}
 
 	if (bp->port.pmf)
 		bnx2x_initial_phy_init(bp, load_mode);
@@ -7082,14 +7145,18 @@ static int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
 	/* Start fast path */
 	switch (load_mode) {
 	case LOAD_NORMAL:
-		/* Tx queue should be only reenabled */
-		netif_tx_wake_all_queues(bp->dev);
+		if (bp->state == BNX2X_STATE_OPEN) {
+			/* Tx queue should be only reenabled */
+			netif_tx_wake_all_queues(bp->dev);
+		}
 		/* Initialize the receive filter. */
 		bnx2x_set_rx_mode(bp->dev);
 		break;
 
 	case LOAD_OPEN:
 		netif_tx_start_all_queues(bp->dev);
+		if (bp->state != BNX2X_STATE_OPEN)
+			netif_tx_disable(bp->dev);
 		/* Initialize the receive filter. */
 		bnx2x_set_rx_mode(bp->dev);
 		break;
@@ -9183,18 +9250,19 @@ static int bnx2x_get_coalesce(struct net_device *dev,
 	return 0;
 }
 
+#define BNX2X_MAX_COALES_TOUT  (0xf0*12) /* Maximal coalescing timeout in us */
 static int bnx2x_set_coalesce(struct net_device *dev,
 			      struct ethtool_coalesce *coal)
 {
 	struct bnx2x *bp = netdev_priv(dev);
 
 	bp->rx_ticks = (u16) coal->rx_coalesce_usecs;
-	if (bp->rx_ticks > BNX2X_MAX_COALESCE_TOUT)
-		bp->rx_ticks = BNX2X_MAX_COALESCE_TOUT;
+	if (bp->rx_ticks > BNX2X_MAX_COALES_TOUT)
+		bp->rx_ticks = BNX2X_MAX_COALES_TOUT;
 
 	bp->tx_ticks = (u16) coal->tx_coalesce_usecs;
-	if (bp->tx_ticks > BNX2X_MAX_COALESCE_TOUT)
-		bp->tx_ticks = BNX2X_MAX_COALESCE_TOUT;
+	if (bp->tx_ticks > BNX2X_MAX_COALES_TOUT)
+		bp->tx_ticks = BNX2X_MAX_COALES_TOUT;
 
 	if (netif_running(dev))
 		bnx2x_update_coalesce(bp);
@@ -9553,12 +9621,14 @@ static int bnx2x_run_loopback(struct bnx2x *bp, int loopback_mode, u8 link_up)
 	unsigned int pkt_size, num_pkts, i;
 	struct sk_buff *skb;
 	unsigned char *packet;
-	struct bnx2x_fastpath *fp = &bp->fp[0];
+	struct bnx2x_fastpath *fp_rx = &bp->fp[0];
+	struct bnx2x_fastpath *fp_tx = &bp->fp[bp->num_rx_queues];
 	u16 tx_start_idx, tx_idx;
 	u16 rx_start_idx, rx_idx;
-	u16 pkt_prod;
+	u16 pkt_prod, bd_prod;
 	struct sw_tx_bd *tx_buf;
-	struct eth_tx_bd *tx_bd;
+	struct eth_tx_start_bd *tx_start_bd;
+	struct eth_tx_parse_bd *pbd = NULL;
 	dma_addr_t mapping;
 	union eth_rx_cqe *cqe;
 	u8 cqe_fp_flags;
@@ -9590,57 +9660,64 @@ static int bnx2x_run_loopback(struct bnx2x *bp, int loopback_mode, u8 link_up)
 	}
 	packet = skb_put(skb, pkt_size);
 	memcpy(packet, bp->dev->dev_addr, ETH_ALEN);
-	memset(packet + ETH_ALEN, 0, (ETH_HLEN - ETH_ALEN));
+	memset(packet + ETH_ALEN, 0, ETH_ALEN);
+	memset(packet + 2*ETH_ALEN, 0x77, (ETH_HLEN - 2*ETH_ALEN));
 	for (i = ETH_HLEN; i < pkt_size; i++)
 		packet[i] = (unsigned char) (i & 0xff);
 
 	/* send the loopback packet */
 	num_pkts = 0;
-	tx_start_idx = le16_to_cpu(*fp->tx_cons_sb);
-	rx_start_idx = le16_to_cpu(*fp->rx_cons_sb);
+	tx_start_idx = le16_to_cpu(*fp_tx->tx_cons_sb);
+	rx_start_idx = le16_to_cpu(*fp_rx->rx_cons_sb);
 
-	pkt_prod = fp->tx_pkt_prod++;
-	tx_buf = &fp->tx_buf_ring[TX_BD(pkt_prod)];
-	tx_buf->first_bd = fp->tx_bd_prod;
+	pkt_prod = fp_tx->tx_pkt_prod++;
+	tx_buf = &fp_tx->tx_buf_ring[TX_BD(pkt_prod)];
+	tx_buf->first_bd = fp_tx->tx_bd_prod;
 	tx_buf->skb = skb;
+	tx_buf->flags = 0;
 
-	tx_bd = &fp->tx_desc_ring[TX_BD(fp->tx_bd_prod)];
+	bd_prod = TX_BD(fp_tx->tx_bd_prod);
+	tx_start_bd = &fp_tx->tx_desc_ring[bd_prod].start_bd;
 	mapping = pci_map_single(bp->pdev, skb->data,
 				 skb_headlen(skb), PCI_DMA_TODEVICE);
-	tx_bd->addr_hi = cpu_to_le32(U64_HI(mapping));
-	tx_bd->addr_lo = cpu_to_le32(U64_LO(mapping));
-	tx_bd->nbd = cpu_to_le16(1);
-	tx_bd->nbytes = cpu_to_le16(skb_headlen(skb));
-	tx_bd->vlan = cpu_to_le16(pkt_prod);
-	tx_bd->bd_flags.as_bitfield = (ETH_TX_BD_FLAGS_START_BD |
-				       ETH_TX_BD_FLAGS_END_BD);
-	tx_bd->general_data = ((UNICAST_ADDRESS <<
-				ETH_TX_BD_ETH_ADDR_TYPE_SHIFT) | 1);
+	tx_start_bd->addr_hi = cpu_to_le32(U64_HI(mapping));
+	tx_start_bd->addr_lo = cpu_to_le32(U64_LO(mapping));
+	tx_start_bd->nbd = cpu_to_le16(2); /* start + pbd */
+	tx_start_bd->nbytes = cpu_to_le16(skb_headlen(skb));
+	tx_start_bd->vlan = cpu_to_le16(pkt_prod);
+	tx_start_bd->bd_flags.as_bitfield = ETH_TX_BD_FLAGS_START_BD;
+	tx_start_bd->general_data = ((UNICAST_ADDRESS <<
+				ETH_TX_START_BD_ETH_ADDR_TYPE_SHIFT) | 1);
+
+	/* turn on parsing and get a BD */
+	bd_prod = TX_BD(NEXT_TX_IDX(bd_prod));
+	pbd = &fp_tx->tx_desc_ring[bd_prod].parse_bd;
+
+	memset(pbd, 0, sizeof(struct eth_tx_parse_bd));
 
 	wmb();
 
-	le16_add_cpu(&fp->hw_tx_prods->bds_prod, 1);
-	mb(); /* FW restriction: must not reorder writing nbd and packets */
-	le32_add_cpu(&fp->hw_tx_prods->packets_prod, 1);
-	DOORBELL(bp, fp->index, 0);
+	fp_tx->tx_db.data.prod += 2;
+	barrier();
+	DOORBELL(bp, fp_tx->index - bp->num_rx_queues, fp_tx->tx_db.raw);
 
 	mmiowb();
 
 	num_pkts++;
-	fp->tx_bd_prod++;
+	fp_tx->tx_bd_prod += 2; /* start + pbd */
 	bp->dev->trans_start = jiffies;
 
 	udelay(100);
 
-	tx_idx = le16_to_cpu(*fp->tx_cons_sb);
+	tx_idx = le16_to_cpu(*fp_tx->tx_cons_sb);
 	if (tx_idx != tx_start_idx + num_pkts)
 		goto test_loopback_exit;
 
-	rx_idx = le16_to_cpu(*fp->rx_cons_sb);
+	rx_idx = le16_to_cpu(*fp_rx->rx_cons_sb);
 	if (rx_idx != rx_start_idx + num_pkts)
 		goto test_loopback_exit;
 
-	cqe = &fp->rx_comp_ring[RCQ_BD(fp->rx_comp_cons)];
+	cqe = &fp_rx->rx_comp_ring[RCQ_BD(fp_rx->rx_comp_cons)];
 	cqe_fp_flags = cqe->fast_path_cqe.type_error_flags;
 	if (CQE_TYPE(cqe_fp_flags) || (cqe_fp_flags & ETH_RX_ERROR_FALGS))
 		goto test_loopback_rx_exit;
@@ -9649,7 +9726,7 @@ static int bnx2x_run_loopback(struct bnx2x *bp, int loopback_mode, u8 link_up)
 	if (len != pkt_size)
 		goto test_loopback_rx_exit;
 
-	rx_buf = &fp->rx_buf_ring[RX_BD(fp->rx_bd_cons)];
+	rx_buf = &fp_rx->rx_buf_ring[RX_BD(fp_rx->rx_bd_cons)];
 	skb = rx_buf->skb;
 	skb_reserve(skb, cqe->fast_path_cqe.placement_offset);
 	for (i = ETH_HLEN; i < pkt_size; i++)
@@ -9660,14 +9737,14 @@ static int bnx2x_run_loopback(struct bnx2x *bp, int loopback_mode, u8 link_up)
 
 test_loopback_rx_exit:
 
-	fp->rx_bd_cons = NEXT_RX_IDX(fp->rx_bd_cons);
-	fp->rx_bd_prod = NEXT_RX_IDX(fp->rx_bd_prod);
-	fp->rx_comp_cons = NEXT_RCQ_IDX(fp->rx_comp_cons);
-	fp->rx_comp_prod = NEXT_RCQ_IDX(fp->rx_comp_prod);
+	fp_rx->rx_bd_cons = NEXT_RX_IDX(fp_rx->rx_bd_cons);
+	fp_rx->rx_bd_prod = NEXT_RX_IDX(fp_rx->rx_bd_prod);
+	fp_rx->rx_comp_cons = NEXT_RCQ_IDX(fp_rx->rx_comp_cons);
+	fp_rx->rx_comp_prod = NEXT_RCQ_IDX(fp_rx->rx_comp_prod);
 
 	/* Update producers */
-	bnx2x_update_rx_prod(bp, fp, fp->rx_bd_prod, fp->rx_comp_prod,
-			     fp->rx_sge_prod);
+	bnx2x_update_rx_prod(bp, fp_rx, fp_rx->rx_bd_prod, fp_rx->rx_comp_prod,
+			     fp_rx->rx_sge_prod);
 
 test_loopback_exit:
 	bp->link_params.loopback_mode = LOOPBACK_NONE;
@@ -10000,7 +10077,7 @@ static void bnx2x_get_strings(struct net_device *dev, u32 stringset, u8 *buf)
 	case ETH_SS_STATS:
 		if (is_multi(bp)) {
 			k = 0;
-			for_each_queue(bp, i) {
+			for_each_rx_queue(bp, i) {
 				for (j = 0; j < BNX2X_NUM_Q_STATS; j++)
 					sprintf(buf + (k + j)*ETH_GSTRING_LEN,
 						bnx2x_q_stats_arr[j].string, i);
@@ -10034,7 +10111,7 @@ static int bnx2x_get_stats_count(struct net_device *dev)
 	int i, num_stats;
 
 	if (is_multi(bp)) {
-		num_stats = BNX2X_NUM_Q_STATS * BNX2X_NUM_QUEUES(bp);
+		num_stats = BNX2X_NUM_Q_STATS * bp->num_rx_queues;
 		if (!IS_E1HMF_MODE_STAT(bp))
 			num_stats += BNX2X_NUM_STATS;
 	} else {
@@ -10059,7 +10136,7 @@ static void bnx2x_get_ethtool_stats(struct net_device *dev,
 
 	if (is_multi(bp)) {
 		k = 0;
-		for_each_queue(bp, i) {
+		for_each_rx_queue(bp, i) {
 			hw_stats = (u32 *)&bp->fp[i].eth_q_stats;
 			for (j = 0; j < BNX2X_NUM_Q_STATS; j++) {
 				if (bnx2x_q_stats_arr[j].size == 0) {
@@ -10272,15 +10349,11 @@ static int bnx2x_poll(struct napi_struct *napi, int budget)
 		goto poll_panic;
 #endif
 
-	prefetch(fp->tx_buf_ring[TX_BD(fp->tx_pkt_cons)].skb);
 	prefetch(fp->rx_buf_ring[RX_BD(fp->rx_bd_cons)].skb);
 	prefetch((char *)(fp->rx_buf_ring[RX_BD(fp->rx_bd_cons)].skb) + 256);
 
 	bnx2x_update_fpsb_idx(fp);
 
-	if (bnx2x_has_tx_work(fp))
-		bnx2x_tx_int(fp);
-
 	if (bnx2x_has_rx_work(fp)) {
 		work_done = bnx2x_rx_int(fp, budget);
 
@@ -10289,11 +10362,11 @@ static int bnx2x_poll(struct napi_struct *napi, int budget)
 			goto poll_again;
 	}
 
-	/* BNX2X_HAS_WORK() reads the status block, thus we need to
+	/* bnx2x_has_rx_work() reads the status block, thus we need to
 	 * ensure that status block indices have been actually read
-	 * (bnx2x_update_fpsb_idx) prior to this check (BNX2X_HAS_WORK)
+	 * (bnx2x_update_fpsb_idx) prior to this check (bnx2x_has_rx_work)
 	 * so that we won't write the "newer" value of the status block to IGU
-	 * (if there was a DMA right after BNX2X_HAS_WORK and
+	 * (if there was a DMA right after bnx2x_has_rx_work and
 	 * if there is no rmb, the memory reading (bnx2x_update_fpsb_idx)
 	 * may be postponed to right before bnx2x_ack_sb). In this case
 	 * there will never be another interrupt until there is another update
@@ -10301,7 +10374,7 @@ static int bnx2x_poll(struct napi_struct *napi, int budget)
 	 */
 	rmb();
 
-	if (!BNX2X_HAS_WORK(fp)) {
+	if (!bnx2x_has_rx_work(fp)) {
 #ifdef BNX2X_STOP_ON_ERROR
 poll_panic:
 #endif
@@ -10326,10 +10399,11 @@ poll_again:
  */
 static noinline u16 bnx2x_tx_split(struct bnx2x *bp,
 				   struct bnx2x_fastpath *fp,
-				   struct eth_tx_bd **tx_bd, u16 hlen,
+				   struct sw_tx_bd *tx_buf,
+				   struct eth_tx_start_bd **tx_bd, u16 hlen,
 				   u16 bd_prod, int nbd)
 {
-	struct eth_tx_bd *h_tx_bd = *tx_bd;
+	struct eth_tx_start_bd *h_tx_bd = *tx_bd;
 	struct eth_tx_bd *d_tx_bd;
 	dma_addr_t mapping;
 	int old_len = le16_to_cpu(h_tx_bd->nbytes);
@@ -10345,7 +10419,7 @@ static noinline u16 bnx2x_tx_split(struct bnx2x *bp,
 	/* now get a new data BD
 	 * (after the pbd) and fill it */
 	bd_prod = TX_BD(NEXT_TX_IDX(bd_prod));
-	d_tx_bd = &fp->tx_desc_ring[bd_prod];
+	d_tx_bd = &fp->tx_desc_ring[bd_prod].reg_bd;
 
 	mapping = HILO_U64(le32_to_cpu(h_tx_bd->addr_hi),
 			   le32_to_cpu(h_tx_bd->addr_lo)) + hlen;
@@ -10353,17 +10427,16 @@ static noinline u16 bnx2x_tx_split(struct bnx2x *bp,
 	d_tx_bd->addr_hi = cpu_to_le32(U64_HI(mapping));
 	d_tx_bd->addr_lo = cpu_to_le32(U64_LO(mapping));
 	d_tx_bd->nbytes = cpu_to_le16(old_len - hlen);
-	d_tx_bd->vlan = 0;
-	/* this marks the BD as one that has no individual mapping
-	 * the FW ignores this flag in a BD not marked start
-	 */
-	d_tx_bd->bd_flags.as_bitfield = ETH_TX_BD_FLAGS_SW_LSO;
+
+	/* this marks the BD as one that has no individual mapping */
+	tx_buf->flags |= BNX2X_TSO_SPLIT_BD;
+
 	DP(NETIF_MSG_TX_QUEUED,
 	   "TSO split data size is %d (%x:%x)\n",
 	   d_tx_bd->nbytes, d_tx_bd->addr_hi, d_tx_bd->addr_lo);
 
-	/* update tx_bd for marking the last BD flag */
-	*tx_bd = d_tx_bd;
+	/* update tx_bd */
+	*tx_bd = (struct eth_tx_start_bd *)d_tx_bd;
 
 	return bd_prod;
 }
@@ -10498,18 +10571,19 @@ exit_lbl:
 static int bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct bnx2x *bp = netdev_priv(dev);
-	struct bnx2x_fastpath *fp;
+	struct bnx2x_fastpath *fp, *fp_stat;
 	struct netdev_queue *txq;
 	struct sw_tx_bd *tx_buf;
-	struct eth_tx_bd *tx_bd;
+	struct eth_tx_start_bd *tx_start_bd;
+	struct eth_tx_bd *tx_data_bd, *total_pkt_bd = NULL;
 	struct eth_tx_parse_bd *pbd = NULL;
 	u16 pkt_prod, bd_prod;
 	int nbd, fp_index;
 	dma_addr_t mapping;
 	u32 xmit_type = bnx2x_xmit_type(bp, skb);
-	int vlan_off = (bp->e1hov ? 4 : 0);
 	int i;
 	u8 hlen = 0;
+	__le16 pkt_size = 0;
 
 #ifdef BNX2X_STOP_ON_ERROR
 	if (unlikely(bp->panic))
@@ -10519,10 +10593,11 @@ static int bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	fp_index = skb_get_queue_mapping(skb);
 	txq = netdev_get_tx_queue(dev, fp_index);
 
-	fp = &bp->fp[fp_index];
+	fp = &bp->fp[fp_index + bp->num_rx_queues];
+	fp_stat = &bp->fp[fp_index];
 
 	if (unlikely(bnx2x_tx_avail(fp) < (skb_shinfo(skb)->nr_frags + 3))) {
-		fp->eth_q_stats.driver_xoff++,
+		fp_stat->eth_q_stats.driver_xoff++;
 		netif_tx_stop_queue(txq);
 		BNX2X_ERR("BUG! Tx ring full when queue awake!\n");
 		return NETDEV_TX_BUSY;
@@ -10551,7 +10626,7 @@ static int bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	/*
 	Please read carefully. First we use one BD which we mark as start,
-	then for TSO or xsum we have a parsing info BD,
+	then we have a parsing info BD (used for TSO or xsum),
 	and only then we have the rest of the TSO BDs.
 	(don't forget to mark the last one as last,
 	and to unmap only AFTER you write to the BD ...)
@@ -10563,42 +10638,40 @@ static int bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	/* get a tx_buf and first BD */
 	tx_buf = &fp->tx_buf_ring[TX_BD(pkt_prod)];
-	tx_bd = &fp->tx_desc_ring[bd_prod];
+	tx_start_bd = &fp->tx_desc_ring[bd_prod].start_bd;
 
-	tx_bd->bd_flags.as_bitfield = ETH_TX_BD_FLAGS_START_BD;
-	tx_bd->general_data = (UNICAST_ADDRESS <<
-			       ETH_TX_BD_ETH_ADDR_TYPE_SHIFT);
+	tx_start_bd->bd_flags.as_bitfield = ETH_TX_BD_FLAGS_START_BD;
+	tx_start_bd->general_data = (UNICAST_ADDRESS <<
+				     ETH_TX_START_BD_ETH_ADDR_TYPE_SHIFT);
 	/* header nbd */
-	tx_bd->general_data |= (1 << ETH_TX_BD_HDR_NBDS_SHIFT);
+	tx_start_bd->general_data |= (1 << ETH_TX_START_BD_HDR_NBDS_SHIFT);
 
 	/* remember the first BD of the packet */
 	tx_buf->first_bd = fp->tx_bd_prod;
 	tx_buf->skb = skb;
+	tx_buf->flags = 0;
 
 	DP(NETIF_MSG_TX_QUEUED,
 	   "sending pkt %u @%p  next_idx %u  bd %u @%p\n",
-	   pkt_prod, tx_buf, fp->tx_pkt_prod, bd_prod, tx_bd);
+	   pkt_prod, tx_buf, fp->tx_pkt_prod, bd_prod, tx_start_bd);
 
 #ifdef BCM_VLAN
 	if ((bp->vlgrp != NULL) && vlan_tx_tag_present(skb) &&
 	    (bp->flags & HW_VLAN_TX_FLAG)) {
-		tx_bd->vlan = cpu_to_le16(vlan_tx_tag_get(skb));
-		tx_bd->bd_flags.as_bitfield |= ETH_TX_BD_FLAGS_VLAN_TAG;
-		vlan_off += 4;
+		tx_start_bd->vlan = cpu_to_le16(vlan_tx_tag_get(skb));
+		tx_start_bd->bd_flags.as_bitfield |= ETH_TX_BD_FLAGS_VLAN_TAG;
 	} else
 #endif
-		tx_bd->vlan = cpu_to_le16(pkt_prod);
+		tx_start_bd->vlan = cpu_to_le16(pkt_prod);
 
-	if (xmit_type) {
-		/* turn on parsing and get a BD */
-		bd_prod = TX_BD(NEXT_TX_IDX(bd_prod));
-		pbd = (void *)&fp->tx_desc_ring[bd_prod];
+	/* turn on parsing and get a BD */
+	bd_prod = TX_BD(NEXT_TX_IDX(bd_prod));
+	pbd = &fp->tx_desc_ring[bd_prod].parse_bd;
 
-		memset(pbd, 0, sizeof(struct eth_tx_parse_bd));
-	}
+	memset(pbd, 0, sizeof(struct eth_tx_parse_bd));
 
 	if (xmit_type & XMIT_CSUM) {
-		hlen = (skb_network_header(skb) - skb->data + vlan_off) / 2;
+		hlen = (skb_network_header(skb) - skb->data) / 2;
 
 		/* for now NS flag is not used in Linux */
 		pbd->global_data =
@@ -10611,15 +10684,16 @@ static int bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		hlen += pbd->ip_hlen + tcp_hdrlen(skb) / 2;
 
 		pbd->total_hlen = cpu_to_le16(hlen);
-		hlen = hlen*2 - vlan_off;
+		hlen = hlen*2;
 
-		tx_bd->bd_flags.as_bitfield |= ETH_TX_BD_FLAGS_TCP_CSUM;
+		tx_start_bd->bd_flags.as_bitfield |= ETH_TX_BD_FLAGS_L4_CSUM;
 
 		if (xmit_type & XMIT_CSUM_V4)
-			tx_bd->bd_flags.as_bitfield |=
+			tx_start_bd->bd_flags.as_bitfield |=
 						ETH_TX_BD_FLAGS_IP_CSUM;
 		else
-			tx_bd->bd_flags.as_bitfield |= ETH_TX_BD_FLAGS_IPV6;
+			tx_start_bd->bd_flags.as_bitfield |=
+						ETH_TX_BD_FLAGS_IPV6;
 
 		if (xmit_type & XMIT_CSUM_TCP) {
 			pbd->tcp_pseudo_csum = swab16(tcp_hdr(skb)->check);
@@ -10627,13 +10701,11 @@ static int bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		} else {
 			s8 fix = SKB_CS_OFF(skb); /* signed! */
 
-			pbd->global_data |= ETH_TX_PARSE_BD_CS_ANY_FLG;
-			pbd->cs_offset = fix / 2;
+			pbd->global_data |= ETH_TX_PARSE_BD_UDP_CS_FLG;
 
 			DP(NETIF_MSG_TX_QUEUED,
-			   "hlen %d  offset %d  fix %d  csum before fix %x\n",
-			   le16_to_cpu(pbd->total_hlen), pbd->cs_offset, fix,
-			   SKB_CS(skb));
+			   "hlen %d  fix %d  csum before fix %x\n",
+			   le16_to_cpu(pbd->total_hlen), fix, SKB_CS(skb));
 
 			/* HW bug: fixup the CSUM */
 			pbd->tcp_pseudo_csum =
@@ -10648,17 +10720,18 @@ static int bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	mapping = pci_map_single(bp->pdev, skb->data,
 				 skb_headlen(skb), PCI_DMA_TODEVICE);
 
-	tx_bd->addr_hi = cpu_to_le32(U64_HI(mapping));
-	tx_bd->addr_lo = cpu_to_le32(U64_LO(mapping));
-	nbd = skb_shinfo(skb)->nr_frags + ((pbd == NULL) ? 1 : 2);
-	tx_bd->nbd = cpu_to_le16(nbd);
-	tx_bd->nbytes = cpu_to_le16(skb_headlen(skb));
+	tx_start_bd->addr_hi = cpu_to_le32(U64_HI(mapping));
+	tx_start_bd->addr_lo = cpu_to_le32(U64_LO(mapping));
+	nbd = skb_shinfo(skb)->nr_frags + 2; /* start_bd + pbd + frags */
+	tx_start_bd->nbd = cpu_to_le16(nbd);
+	tx_start_bd->nbytes = cpu_to_le16(skb_headlen(skb));
+	pkt_size = tx_start_bd->nbytes;
 
 	DP(NETIF_MSG_TX_QUEUED, "first bd @%p  addr (%x:%x)  nbd %d"
 	   "  nbytes %d  flags %x  vlan %x\n",
-	   tx_bd, tx_bd->addr_hi, tx_bd->addr_lo, le16_to_cpu(tx_bd->nbd),
-	   le16_to_cpu(tx_bd->nbytes), tx_bd->bd_flags.as_bitfield,
-	   le16_to_cpu(tx_bd->vlan));
+	   tx_start_bd, tx_start_bd->addr_hi, tx_start_bd->addr_lo,
+	   le16_to_cpu(tx_start_bd->nbd), le16_to_cpu(tx_start_bd->nbytes),
+	   tx_start_bd->bd_flags.as_bitfield, le16_to_cpu(tx_start_bd->vlan));
 
 	if (xmit_type & XMIT_GSO) {
 
@@ -10667,11 +10740,11 @@ static int bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		   skb->len, hlen, skb_headlen(skb),
 		   skb_shinfo(skb)->gso_size);
 
-		tx_bd->bd_flags.as_bitfield |= ETH_TX_BD_FLAGS_SW_LSO;
+		tx_start_bd->bd_flags.as_bitfield |= ETH_TX_BD_FLAGS_SW_LSO;
 
 		if (unlikely(skb_headlen(skb) > hlen))
-			bd_prod = bnx2x_tx_split(bp, fp, &tx_bd, hlen,
-						 bd_prod, ++nbd);
+			bd_prod = bnx2x_tx_split(bp, fp, tx_buf, &tx_start_bd,
+						 hlen, bd_prod, ++nbd);
 
 		pbd->lso_mss = cpu_to_le16(skb_shinfo(skb)->gso_size);
 		pbd->tcp_send_seq = swab32(tcp_hdr(skb)->seq);
@@ -10692,33 +10765,31 @@ static int bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 		pbd->global_data |= ETH_TX_PARSE_BD_PSEUDO_CS_WITHOUT_LEN;
 	}
+	tx_data_bd = (struct eth_tx_bd *)tx_start_bd;
 
 	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
 		skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
 
 		bd_prod = TX_BD(NEXT_TX_IDX(bd_prod));
-		tx_bd = &fp->tx_desc_ring[bd_prod];
+		tx_data_bd = &fp->tx_desc_ring[bd_prod].reg_bd;
+		if (total_pkt_bd == NULL)
+			total_pkt_bd = &fp->tx_desc_ring[bd_prod].reg_bd;
 
 		mapping = pci_map_page(bp->pdev, frag->page, frag->page_offset,
 				       frag->size, PCI_DMA_TODEVICE);
 
-		tx_bd->addr_hi = cpu_to_le32(U64_HI(mapping));
-		tx_bd->addr_lo = cpu_to_le32(U64_LO(mapping));
-		tx_bd->nbytes = cpu_to_le16(frag->size);
-		tx_bd->vlan = cpu_to_le16(pkt_prod);
-		tx_bd->bd_flags.as_bitfield = 0;
+		tx_data_bd->addr_hi = cpu_to_le32(U64_HI(mapping));
+		tx_data_bd->addr_lo = cpu_to_le32(U64_LO(mapping));
+		tx_data_bd->nbytes = cpu_to_le16(frag->size);
+		le16_add_cpu(&pkt_size, frag->size);
 
 		DP(NETIF_MSG_TX_QUEUED,
-		   "frag %d  bd @%p  addr (%x:%x)  nbytes %d  flags %x\n",
-		   i, tx_bd, tx_bd->addr_hi, tx_bd->addr_lo,
-		   le16_to_cpu(tx_bd->nbytes), tx_bd->bd_flags.as_bitfield);
+		   "frag %d  bd @%p  addr (%x:%x)  nbytes %d\n",
+		   i, tx_data_bd, tx_data_bd->addr_hi, tx_data_bd->addr_lo,
+		   le16_to_cpu(tx_data_bd->nbytes));
 	}
 
-	/* now at last mark the BD as the last BD */
-	tx_bd->bd_flags.as_bitfield |= ETH_TX_BD_FLAGS_END_BD;
-
-	DP(NETIF_MSG_TX_QUEUED, "last bd @%p  flags %x\n",
-	   tx_bd, tx_bd->bd_flags.as_bitfield);
+	DP(NETIF_MSG_TX_QUEUED, "last bd @%p\n", tx_data_bd);
 
 	bd_prod = TX_BD(NEXT_TX_IDX(bd_prod));
 
@@ -10728,6 +10799,9 @@ static int bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (TX_BD_POFF(bd_prod) < nbd)
 		nbd++;
 
+	if (total_pkt_bd != NULL)
+		total_pkt_bd->total_pkt_bytes = pkt_size;
+
 	if (pbd)
 		DP(NETIF_MSG_TX_QUEUED,
 		   "PBD @%p  ip_data %x  ip_hlen %u  ip_id %u  lso_mss %u"
@@ -10747,25 +10821,24 @@ static int bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	 */
 	wmb();
 
-	le16_add_cpu(&fp->hw_tx_prods->bds_prod, nbd);
-	mb(); /* FW restriction: must not reorder writing nbd and packets */
-	le32_add_cpu(&fp->hw_tx_prods->packets_prod, 1);
-	DOORBELL(bp, fp->index, 0);
+	fp->tx_db.data.prod += nbd;
+	barrier();
+	DOORBELL(bp, fp->index - bp->num_rx_queues, fp->tx_db.raw);
 
 	mmiowb();
 
 	fp->tx_bd_prod += nbd;
 
 	if (unlikely(bnx2x_tx_avail(fp) < MAX_SKB_FRAGS + 3)) {
+		netif_tx_stop_queue(txq);
 		/* We want bnx2x_tx_int to "see" the updated tx_bd_prod
 		   if we put Tx into XOFF state. */
 		smp_mb();
-		netif_tx_stop_queue(txq);
-		fp->eth_q_stats.driver_xoff++;
+		fp_stat->eth_q_stats.driver_xoff++;
 		if (bnx2x_tx_avail(fp) >= MAX_SKB_FRAGS + 3)
 			netif_tx_wake_queue(txq);
 	}
-	fp->tx_pkt++;
+	fp_stat->tx_pkt++;
 
 	return NETDEV_TX_OK;
 }
@@ -10841,8 +10914,9 @@ static void bnx2x_set_rx_mode(struct net_device *dev)
 							cpu_to_le16(port);
 				config->config_table[i].
 					target_table_entry.flags = 0;
-				config->config_table[i].
-					target_table_entry.client_id = 0;
+				config->config_table[i].target_table_entry.
+					clients_bit_vector =
+						cpu_to_le32(1 << BP_L_ID(bp));
 				config->config_table[i].
 					target_table_entry.vlan_id = 0;
 
diff --git a/drivers/net/bnx2x_reg.h b/drivers/net/bnx2x_reg.h
index 8e9e7a2..25639e2 100644
--- a/drivers/net/bnx2x_reg.h
+++ b/drivers/net/bnx2x_reg.h
@@ -370,7 +370,6 @@
 #define CFC_REG_NUM_LCIDS_LEAVING				 0x104018
 /* [RW 8] The event id for aggregated interrupt 0 */
 #define CSDM_REG_AGG_INT_EVENT_0				 0xc2038
-#define CSDM_REG_AGG_INT_EVENT_1				 0xc203c
 #define CSDM_REG_AGG_INT_EVENT_10				 0xc2060
 #define CSDM_REG_AGG_INT_EVENT_11				 0xc2064
 #define CSDM_REG_AGG_INT_EVENT_12				 0xc2068
@@ -378,37 +377,27 @@
 #define CSDM_REG_AGG_INT_EVENT_14				 0xc2070
 #define CSDM_REG_AGG_INT_EVENT_15				 0xc2074
 #define CSDM_REG_AGG_INT_EVENT_16				 0xc2078
-#define CSDM_REG_AGG_INT_EVENT_17				 0xc207c
-#define CSDM_REG_AGG_INT_EVENT_18				 0xc2080
-#define CSDM_REG_AGG_INT_EVENT_19				 0xc2084
 #define CSDM_REG_AGG_INT_EVENT_2				 0xc2040
-#define CSDM_REG_AGG_INT_EVENT_20				 0xc2088
-#define CSDM_REG_AGG_INT_EVENT_21				 0xc208c
-#define CSDM_REG_AGG_INT_EVENT_22				 0xc2090
-#define CSDM_REG_AGG_INT_EVENT_23				 0xc2094
-#define CSDM_REG_AGG_INT_EVENT_24				 0xc2098
-#define CSDM_REG_AGG_INT_EVENT_25				 0xc209c
-#define CSDM_REG_AGG_INT_EVENT_26				 0xc20a0
-#define CSDM_REG_AGG_INT_EVENT_27				 0xc20a4
-#define CSDM_REG_AGG_INT_EVENT_28				 0xc20a8
-#define CSDM_REG_AGG_INT_EVENT_29				 0xc20ac
 #define CSDM_REG_AGG_INT_EVENT_3				 0xc2044
-#define CSDM_REG_AGG_INT_EVENT_30				 0xc20b0
-#define CSDM_REG_AGG_INT_EVENT_31				 0xc20b4
 #define CSDM_REG_AGG_INT_EVENT_4				 0xc2048
-/* [RW 1] The T bit for aggregated interrupt 0 */
-#define CSDM_REG_AGG_INT_T_0					 0xc20b8
-#define CSDM_REG_AGG_INT_T_1					 0xc20bc
-#define CSDM_REG_AGG_INT_T_10					 0xc20e0
-#define CSDM_REG_AGG_INT_T_11					 0xc20e4
-#define CSDM_REG_AGG_INT_T_12					 0xc20e8
-#define CSDM_REG_AGG_INT_T_13					 0xc20ec
-#define CSDM_REG_AGG_INT_T_14					 0xc20f0
-#define CSDM_REG_AGG_INT_T_15					 0xc20f4
-#define CSDM_REG_AGG_INT_T_16					 0xc20f8
-#define CSDM_REG_AGG_INT_T_17					 0xc20fc
-#define CSDM_REG_AGG_INT_T_18					 0xc2100
-#define CSDM_REG_AGG_INT_T_19					 0xc2104
+#define CSDM_REG_AGG_INT_EVENT_5				 0xc204c
+#define CSDM_REG_AGG_INT_EVENT_6				 0xc2050
+#define CSDM_REG_AGG_INT_EVENT_7				 0xc2054
+#define CSDM_REG_AGG_INT_EVENT_8				 0xc2058
+#define CSDM_REG_AGG_INT_EVENT_9				 0xc205c
+/* [RW 1] For each aggregated interrupt index whether the mode is normal (0)
+   or auto-mask-mode (1) */
+#define CSDM_REG_AGG_INT_MODE_10				 0xc21e0
+#define CSDM_REG_AGG_INT_MODE_11				 0xc21e4
+#define CSDM_REG_AGG_INT_MODE_12				 0xc21e8
+#define CSDM_REG_AGG_INT_MODE_13				 0xc21ec
+#define CSDM_REG_AGG_INT_MODE_14				 0xc21f0
+#define CSDM_REG_AGG_INT_MODE_15				 0xc21f4
+#define CSDM_REG_AGG_INT_MODE_16				 0xc21f8
+#define CSDM_REG_AGG_INT_MODE_6 				 0xc21d0
+#define CSDM_REG_AGG_INT_MODE_7 				 0xc21d4
+#define CSDM_REG_AGG_INT_MODE_8 				 0xc21d8
+#define CSDM_REG_AGG_INT_MODE_9 				 0xc21dc
 /* [RW 13] The start address in the internal RAM for the cfc_rsp lcid */
 #define CSDM_REG_CFC_RSP_START_ADDR				 0xc2008
 /* [RW 16] The maximum value of the competion counter #0 */
@@ -1421,6 +1410,8 @@
 /* [RW 1] e1hmf for WOL. If clr WOL signal o the PXP will be send on bit 0
    only. */
 #define MISC_REG_E1HMF_MODE					 0xa5f8
+/* [RW 32] Debug only: spare RW register reset by core reset */
+#define MISC_REG_GENERIC_CR_0					 0xa460
 /* [RW 32] GPIO. [31-28] FLOAT port 0; [27-24] FLOAT port 0; When any of
    these bits is written as a '1'; the corresponding SPIO bit will turn off
    it's drivers and become an input. This is the reset state of all GPIO
@@ -1729,6 +1720,7 @@
 /* [RW 3] for port0 enable for llfc ppp and pause. b0 - brb1 enable; b1-
    tsdm enable; b2- usdm enable */
 #define NIG_REG_LLFC_EGRESS_SRC_ENABLE_0			 0x16070
+#define NIG_REG_LLFC_EGRESS_SRC_ENABLE_1			 0x16074
 /* [RW 1] SAFC enable for port0. This register may get 1 only when
    ~ppp_enable.ppp_enable = 0 and pause_enable.pause_enable =0 for the same
    port */
@@ -2079,6 +2071,7 @@
 #define PXP2_REG_PGL_ADDR_94_F0 				 0x120540
 #define PXP2_REG_PGL_CONTROL0					 0x120490
 #define PXP2_REG_PGL_CONTROL1					 0x120514
+#define PXP2_REG_PGL_DEBUG					 0x120520
 /* [RW 32] third dword data of expansion rom request. this register is
    special. reading from it provides a vector outstanding read requests. if
    a bit is zero it means that a read request on the corresponding tag did
@@ -2239,6 +2232,9 @@
    allocated for vq22 */
 #define PXP2_REG_RD_MAX_BLKS_VQ22				 0x1203d0
 /* [RW 8] The maximum number of blocks in Tetris Buffer that can be
+   allocated for vq25 */
+#define PXP2_REG_RD_MAX_BLKS_VQ25				 0x1203dc
+/* [RW 8] The maximum number of blocks in Tetris Buffer that can be
    allocated for vq6 */
 #define PXP2_REG_RD_MAX_BLKS_VQ6				 0x120390
 /* [RW 8] The maximum number of blocks in Tetris Buffer that can be
@@ -3835,6 +3831,7 @@
 #define TM_REG_LIN0_PHY_ADDR					 0x164270
 /* [RW 1] Linear0 physical address valid. */
 #define TM_REG_LIN0_PHY_ADDR_VALID				 0x164248
+#define TM_REG_LIN0_SCAN_ON					 0x1640d0
 /* [RW 24] Linear0 array scan timeout. */
 #define TM_REG_LIN0_SCAN_TIME					 0x16403c
 /* [RW 32] Linear1 logic address. */
@@ -4363,6 +4360,7 @@
 #define USDM_REG_AGG_INT_EVENT_31				 0xc40b4
 #define USDM_REG_AGG_INT_EVENT_4				 0xc4048
 #define USDM_REG_AGG_INT_EVENT_5				 0xc404c
+#define USDM_REG_AGG_INT_EVENT_6				 0xc4050
 /* [RW 1] For each aggregated interrupt index whether the mode is normal (0)
    or auto-mask-mode (1) */
 #define USDM_REG_AGG_INT_MODE_0 				 0xc41b8
@@ -4379,6 +4377,10 @@
 #define USDM_REG_AGG_INT_MODE_19				 0xc4204
 #define USDM_REG_AGG_INT_MODE_4 				 0xc41c8
 #define USDM_REG_AGG_INT_MODE_5 				 0xc41cc
+#define USDM_REG_AGG_INT_MODE_6 				 0xc41d0
+/* [RW 1] The T bit for aggregated interrupt 5 */
+#define USDM_REG_AGG_INT_T_5					 0xc40cc
+#define USDM_REG_AGG_INT_T_6					 0xc40d0
 /* [RW 13] The start address in the internal RAM for the cfc_rsp lcid */
 #define USDM_REG_CFC_RSP_START_ADDR				 0xc4008
 /* [RW 16] The maximum value of the competion counter #0 */
diff --git a/firmware/Makefile b/firmware/Makefile
index 44313b2..317212c 100644
--- a/firmware/Makefile
+++ b/firmware/Makefile
@@ -32,7 +32,7 @@ fw-shipped-$(CONFIG_ADAPTEC_STARFIRE) += adaptec/starfire_rx.bin \
 					 adaptec/starfire_tx.bin
 fw-shipped-$(CONFIG_ATARI_DSP56K) += dsp56k/bootstrap.bin
 fw-shipped-$(CONFIG_ATM_AMBASSADOR) += atmsar11.fw
-fw-shipped-$(CONFIG_BNX2X) += bnx2x-e1-4.8.53.0.fw bnx2x-e1h-4.8.53.0.fw
+fw-shipped-$(CONFIG_BNX2X) += bnx2x-e1-5.0.21.0.fw bnx2x-e1h-5.0.21.0.fw
 fw-shipped-$(CONFIG_BNX2) += bnx2/bnx2-mips-09-4.6.17.fw \
 			     bnx2/bnx2-rv2p-09-4.6.15.fw \
 			     bnx2/bnx2-mips-06-4.6.16.fw \
-- 
1.5.4.3




