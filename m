From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH net-next 09/15]bnx2x: Add support for BCM57711 HW
Date: Mon, 23 Jun 2008 19:02:18 +0300
Message-ID: <1214236938.3690.52.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Michael Chan" <mchan@broadcom.com>
To: "David Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2457 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754855AbYFWQCd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Jun 2008 12:02:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Supporting the 57711 and 57711E - refers to in the code as E1H. The
57710 is referred to as E1.

To support the new members in the family, the bnx2x structure was
divided to 3 parts: common, port and function. These changes caused some
rearrangement in the bnx2x.h file.

A set of accessories macros were added to make access to the bnx2x
structure more readable

Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/Kconfig         |    1 +
 drivers/net/bnx2x.h         |  739 +++++----
 drivers/net/bnx2x_fw_defs.h |  483 ++++--
 drivers/net/bnx2x_hsi.h     |  708 ++++++---
 drivers/net/bnx2x_init.h    |   20 +-
 drivers/net/bnx2x_link.c    |   11 +-
 drivers/net/bnx2x_main.c    | 3875 +++++++++++++++++++++++++++----------------
 drivers/net/bnx2x_reg.h     |   66 +-
 include/linux/pci_ids.h     |    2 +
 9 files changed, 3752 insertions(+), 2153 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 0e0f669..287d087 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -2600,6 +2600,7 @@ config BNX2X
 	tristate "Broadcom NetXtremeII 10Gb support"
 	depends on PCI
 	select ZLIB_INFLATE
+	select LIBCRC32C
 	help
 	  This driver supports Broadcom NetXtremeII 10 gigabit Ethernet cards.
 	  To compile this driver as a module, choose M here: the module
diff --git a/drivers/net/bnx2x.h b/drivers/net/bnx2x.h
index 0979ca0..e08b943 100644
--- a/drivers/net/bnx2x.h
+++ b/drivers/net/bnx2x.h
@@ -14,39 +14,46 @@
 #ifndef BNX2X_H
 #define BNX2X_H
 
+/* compilation time flags */
+
+/* define this to make the driver freeze on error to allow getting debug info
+ * (you will need to reboot afterwards) */
+/* #define BNX2X_STOP_ON_ERROR */
+
 /* error/debug prints */
 
-#define DRV_MODULE_NAME 	"bnx2x"
-#define PFX DRV_MODULE_NAME     ": "
+#define DRV_MODULE_NAME		"bnx2x"
+#define PFX DRV_MODULE_NAME	": "
 
 /* for messages that are currently off */
-#define BNX2X_MSG_OFF   		0
-#define BNX2X_MSG_MCP   		0x10000 /* was: NETIF_MSG_HW */
-#define BNX2X_MSG_STATS 		0x20000 /* was: NETIF_MSG_TIMER */
-#define NETIF_MSG_NVM   		0x40000 /* was: NETIF_MSG_HW */
-#define NETIF_MSG_DMAE  		0x80000 /* was: NETIF_MSG_HW */
+#define BNX2X_MSG_OFF			0
+#define BNX2X_MSG_MCP			0x010000 /* was: NETIF_MSG_HW */
+#define BNX2X_MSG_STATS			0x020000 /* was: NETIF_MSG_TIMER */
+#define BNX2X_MSG_NVM			0x040000 /* was: NETIF_MSG_HW */
+#define BNX2X_MSG_DMAE			0x080000 /* was: NETIF_MSG_HW */
 #define BNX2X_MSG_SP			0x100000 /* was: NETIF_MSG_INTR */
 #define BNX2X_MSG_FP			0x200000 /* was: NETIF_MSG_INTR */
 
-#define DP_LEVEL			KERN_NOTICE     /* was: KERN_DEBUG */
+#define DP_LEVEL			KERN_NOTICE	/* was: KERN_DEBUG */
 
 /* regular debug print */
 #define DP(__mask, __fmt, __args...) do { \
 	if (bp->msglevel & (__mask)) \
-		printk(DP_LEVEL "[%s:%d(%s)]" __fmt, __FUNCTION__, \
-		__LINE__, bp->dev?(bp->dev->name):"?", ##__args); \
+		printk(DP_LEVEL "[%s:%d(%s)]" __fmt, __func__, __LINE__, \
+			bp->dev?(bp->dev->name):"?", ##__args); \
 	} while (0)
 
-/* for errors (never masked) */
-#define BNX2X_ERR(__fmt, __args...) do { \
-	printk(KERN_ERR "[%s:%d(%s)]" __fmt, __FUNCTION__, \
-		__LINE__, bp->dev?(bp->dev->name):"?", ##__args); \
+/* errors debug print */
+#define BNX2X_DBG_ERR(__fmt, __args...) do { \
+	if (bp->msglevel & NETIF_MSG_PROBE) \
+		printk(KERN_ERR "[%s:%d(%s)]" __fmt, __func__, __LINE__, \
+			bp->dev?(bp->dev->name):"?", ##__args); \
 	} while (0)
 
-/* for logging (never masked) */
-#define BNX2X_LOG(__fmt, __args...) do { \
-	printk(KERN_NOTICE "[%s:%d(%s)]" __fmt, __FUNCTION__, \
-		__LINE__, bp->dev?(bp->dev->name):"?", ##__args); \
+/* for errors (never masked) */
+#define BNX2X_ERR(__fmt, __args...) do { \
+	printk(KERN_ERR "[%s:%d(%s)]" __fmt, __func__, __LINE__, \
+		bp->dev?(bp->dev->name):"?", ##__args); \
 	} while (0)
 
 /* before we have a dev->name use dev_info() */
@@ -60,7 +67,7 @@
 #define bnx2x_panic() do { \
 		bp->panic = 1; \
 		BNX2X_ERR("driver assert\n"); \
-		bnx2x_disable_int(bp); \
+		bnx2x_int_disable(bp); \
 		bnx2x_panic_dump(bp); \
 	} while (0)
 #else
@@ -71,24 +78,29 @@
 #endif
 
 
-#define U64_LO(x)       		(((u64)x) & 0xffffffff)
-#define U64_HI(x)       		(((u64)x) >> 32)
-#define HILO_U64(hi, lo)		(((u64)hi << 32) + lo)
+#ifdef NETIF_F_HW_VLAN_TX
+#define BCM_VLAN			1
+#endif
+
 
+#define U64_LO(x)			(u32)(((u64)(x)) & 0xffffffff)
+#define U64_HI(x)			(u32)(((u64)(x)) >> 32)
+#define HILO_U64(hi, lo)		((((u64)(hi)) << 32) + (lo))
 
-#define REG_ADDR(bp, offset)    	(bp->regview + offset)
 
-#define REG_RD(bp, offset)      	readl(REG_ADDR(bp, offset))
-#define REG_RD8(bp, offset)     	readb(REG_ADDR(bp, offset))
-#define REG_RD64(bp, offset)    	readq(REG_ADDR(bp, offset))
+#define REG_ADDR(bp, offset)		(bp->regview + offset)
 
-#define REG_WR(bp, offset, val) 	writel((u32)val, REG_ADDR(bp, offset))
+#define REG_RD(bp, offset)		readl(REG_ADDR(bp, offset))
+#define REG_RD8(bp, offset)		readb(REG_ADDR(bp, offset))
+#define REG_RD64(bp, offset)		readq(REG_ADDR(bp, offset))
+
+#define REG_WR(bp, offset, val)		writel((u32)val, REG_ADDR(bp, offset))
 #define REG_WR8(bp, offset, val)	writeb((u8)val, REG_ADDR(bp, offset))
-#define REG_WR16(bp, offset, val)       writew((u16)val, REG_ADDR(bp, offset))
-#define REG_WR32(bp, offset, val)       REG_WR(bp, offset, val)
+#define REG_WR16(bp, offset, val)	writew((u16)val, REG_ADDR(bp, offset))
+#define REG_WR32(bp, offset, val)	REG_WR(bp, offset, val)
 
-#define REG_RD_IND(bp, offset)  	bnx2x_reg_rd_ind(bp, offset)
-#define REG_WR_IND(bp, offset, val)     bnx2x_reg_wr_ind(bp, offset, val)
+#define REG_RD_IND(bp, offset)		bnx2x_reg_rd_ind(bp, offset)
+#define REG_WR_IND(bp, offset, val)	bnx2x_reg_wr_ind(bp, offset, val)
 
 #define REG_RD_DMAE(bp, offset, valp, len32) \
 	do { \
@@ -96,28 +108,28 @@
 		memcpy(valp, bnx2x_sp(bp, wb_data[0]), len32 * 4); \
 	} while (0)
 
-#define REG_WR_DMAE(bp, offset, val, len32) \
+#define REG_WR_DMAE(bp, offset, valp, len32) \
 	do { \
-		memcpy(bnx2x_sp(bp, wb_data[0]), val, len32 * 4); \
+		memcpy(bnx2x_sp(bp, wb_data[0]), valp, len32 * 4); \
 		bnx2x_write_dmae(bp, bnx2x_sp_mapping(bp, wb_data), \
 				 offset, len32); \
 	} while (0)
 
-#define SHMEM_RD(bp, type) \
-	REG_RD(bp, bp->shmem_base + offsetof(struct shmem_region, type))
-#define SHMEM_WR(bp, type, val) \
-	REG_WR(bp, bp->shmem_base + offsetof(struct shmem_region, type), val)
+#define SHMEM_ADDR(bp, field)		(bp->common.shmem_base + \
+					 offsetof(struct shmem_region, field))
+#define SHMEM_RD(bp, field)		REG_RD(bp, SHMEM_ADDR(bp, field))
+#define SHMEM_WR(bp, field, val)	REG_WR(bp, SHMEM_ADDR(bp, field), val)
 
 #define NIG_WR(reg, val)	REG_WR(bp, reg, val)
-#define EMAC_WR(reg, val)       REG_WR(bp, emac_base + reg, val)
-#define BMAC_WR(reg, val)       REG_WR(bp, GRCBASE_NIG + bmac_addr + reg, val)
+#define EMAC_WR(reg, val)	REG_WR(bp, emac_base + reg, val)
+#define BMAC_WR(reg, val)	REG_WR(bp, GRCBASE_NIG + bmac_addr + reg, val)
 
 
-#define for_each_queue(bp, var) for (var = 0; var < bp->num_queues; var++)
+#define for_each_queue(bp, var)	for (var = 0; var < bp->num_queues; var++)
 
 #define for_each_nondefault_queue(bp, var) \
 				for (var = 1; var < bp->num_queues; var++)
-#define is_multi(bp)    	(bp->num_queues > 1)
+#define is_multi(bp)		(bp->num_queues > 1)
 
 
 struct regp {
@@ -358,210 +370,122 @@ struct bnx2x_eth_stats {
 	u32 number_of_bugs_found_in_stats_spec; /* just kidding */
 };
 
-#define MAC_STX_NA      		0xffffffff
-
-#ifdef BNX2X_MULTI
-#define MAX_CONTEXT     		16
-#else
-#define MAX_CONTEXT     		1
-#endif
-
-union cdu_context {
-	struct eth_context eth;
-	char pad[1024];
-};
-
-#define MAX_DMAE_C      		5
-
-/* DMA memory not used in fastpath */
-struct bnx2x_slowpath {
-	union cdu_context       	context[MAX_CONTEXT];
-	struct eth_stats_query  	fw_stats;
-	struct mac_configuration_cmd    mac_config;
-	struct mac_configuration_cmd    mcast_config;
-
-	/* used by dmae command executer */
-	struct dmae_command     	dmae[MAX_DMAE_C];
-
-	union mac_stats 		mac_stats;
-	struct nig_stats		nig;
-	struct bnx2x_eth_stats  	eth_stats;
-
-	u32     			wb_comp;
-#define BNX2X_WB_COMP_VAL       	0xe0d0d0ae
-	u32     			wb_data[4];
-};
-
-#define bnx2x_sp(bp, var)       	(&bp->slowpath->var)
 #define bnx2x_sp_check(bp, var) ((bp->slowpath) ? (&bp->slowpath->var) : NULL)
-#define bnx2x_sp_mapping(bp, var) \
-		(bp->slowpath_mapping + offsetof(struct bnx2x_slowpath, var))
-
-
 struct sw_rx_bd {
-	struct sk_buff  *skb;
+	struct sk_buff	*skb;
 	DECLARE_PCI_UNMAP_ADDR(mapping)
 };
 
 struct sw_tx_bd {
-	struct sk_buff  *skb;
-	u16     	first_bd;
+	struct sk_buff	*skb;
+	u16		first_bd;
 };
 
 struct bnx2x_fastpath {
 
-	struct napi_struct      napi;
+	struct napi_struct	napi;
 
 	struct host_status_block *status_blk;
-	dma_addr_t      	status_blk_mapping;
+	dma_addr_t		status_blk_mapping;
 
-	struct eth_tx_db_data   *hw_tx_prods;
-	dma_addr_t      	tx_prods_mapping;
+	struct eth_tx_db_data	*hw_tx_prods;
+	dma_addr_t		tx_prods_mapping;
 
-	struct sw_tx_bd 	*tx_buf_ring;
+	struct sw_tx_bd		*tx_buf_ring;
 
 	struct eth_tx_bd	*tx_desc_ring;
-	dma_addr_t      	tx_desc_mapping;
+	dma_addr_t		tx_desc_mapping;
 
 	struct sw_rx_bd 	*rx_buf_ring;
 
 	struct eth_rx_bd	*rx_desc_ring;
-	dma_addr_t      	rx_desc_mapping;
+	dma_addr_t		rx_desc_mapping;
 
 	union eth_rx_cqe	*rx_comp_ring;
-	dma_addr_t      	rx_comp_mapping;
-
-	int     		state;
-#define BNX2X_FP_STATE_CLOSED   	0
-#define BNX2X_FP_STATE_IRQ      	0x80000
-#define BNX2X_FP_STATE_OPENING  	0x90000
-#define BNX2X_FP_STATE_OPEN     	0xa0000
-#define BNX2X_FP_STATE_HALTING  	0xb0000
-#define BNX2X_FP_STATE_HALTED   	0xc0000
-
-	int     		index;
-
-	u16     		tx_pkt_prod;
-	u16     		tx_pkt_cons;
-	u16     		tx_bd_prod;
-	u16     		tx_bd_cons;
-	u16     		*tx_cons_sb;
-
-	u16     		fp_c_idx;
-	u16     		fp_u_idx;
-
-	u16     		rx_bd_prod;
-	u16     		rx_bd_cons;
-	u16     		rx_comp_prod;
-	u16     		rx_comp_cons;
-	u16     		*rx_cons_sb;
-
-	unsigned long   	tx_pkt,
+	dma_addr_t		rx_comp_mapping;
+
+	int			state;
+#define BNX2X_FP_STATE_CLOSED		0
+#define BNX2X_FP_STATE_IRQ		0x80000
+#define BNX2X_FP_STATE_OPENING		0x90000
+#define BNX2X_FP_STATE_OPEN		0xa0000
+#define BNX2X_FP_STATE_HALTING		0xb0000
+#define BNX2X_FP_STATE_HALTED		0xc0000
+
+	u8			index;	/* number in fp array */
+	u8			cl_id;	/* eth client id */
+	u8			sb_id;	/* status block number in HW */
+#define FP_IDX(fp)			(fp->index)
+#define FP_CL_ID(fp)			(fp->cl_id)
+#define BP_CL_ID(bp)			(bp->fp[0].cl_id)
+#define FP_SB_ID(fp)			(fp->sb_id)
+#define CNIC_SB_ID			0
+
+	u16			tx_pkt_prod;
+	u16			tx_pkt_cons;
+	u16			tx_bd_prod;
+	u16			tx_bd_cons;
+	u16			*tx_cons_sb;
+
+	u16			fp_c_idx;
+	u16			fp_u_idx;
+
+	u16			rx_bd_prod;
+	u16			rx_bd_cons;
+	u16			rx_comp_prod;
+	u16			rx_comp_cons;
+	u16			*rx_cons_sb;
+
+	unsigned long		tx_pkt,
 				rx_pkt,
 				rx_calls;
 
-	struct bnx2x    	*bp; /* parent */
-};
-
-#define bnx2x_fp(bp, nr, var)   	(bp->fp[nr].var)
-
-
-/* attn group wiring */
-#define MAX_DYNAMIC_ATTN_GRPS   	8
-
-struct attn_route {
-	u32     sig[4];
+	struct bnx2x		*bp; /* parent */
 };
 
-struct bnx2x {
-	/* Fields used in the tx and intr/napi performance paths
-	 * are grouped together in the beginning of the structure
-	 */
-	struct bnx2x_fastpath   *fp;
-	void __iomem    	*regview;
-	void __iomem    	*doorbells;
-
-	struct net_device       *dev;
-	struct pci_dev  	*pdev;
-
-	atomic_t		intr_sem;
-	struct msix_entry       msix_table[MAX_CONTEXT+1];
-
-	int     		tx_ring_size;
+#define bnx2x_fp(bp, nr, var)		(bp->fp[nr].var)
+/* This is needed for determening of last_max */
+#define SUB_S16(a, b)			(s16)((s16)(a) - (s16)(b))
 
-#ifdef BCM_VLAN
-	struct vlan_group       *vlgrp;
-#endif
-
-	u32     		rx_csum;
-	u32     		rx_offset;
-	u32     		rx_buf_use_size;	/* useable size */
-	u32     		rx_buf_size;    	/* with alignment */
-#define ETH_OVREHEAD    		(ETH_HLEN + 8)  /* 8 for CRC + VLAN */
-#define ETH_MIN_PACKET_SIZE     	60
-#define ETH_MAX_PACKET_SIZE     	1500
-#define ETH_MAX_JUMBO_PACKET_SIZE       9600
+/* stuff added to make the code fit 80Col */
 
-	struct host_def_status_block *def_status_blk;
-#define DEF_SB_ID       	16
-	u16     		def_c_idx;
-	u16     		def_u_idx;
-	u16     		def_t_idx;
-	u16     		def_x_idx;
-	u16     		def_att_idx;
-	u32     		attn_state;
-	struct attn_route       attn_group[MAX_DYNAMIC_ATTN_GRPS];
-	u32     		aeu_mask;
-	u32     		nig_mask;
+#define CQE_TYPE(cqe_fp_flags)	((cqe_fp_flags) & ETH_FAST_PATH_RX_CQE_TYPE)
 
-	/* slow path ring */
-	struct eth_spe  	*spq;
-	dma_addr_t      	spq_mapping;
-	u16     		spq_prod_idx;
-	struct eth_spe  	*spq_prod_bd;
-	struct eth_spe  	*spq_last_bd;
-	u16     		*dsb_sp_prod;
-	u16     		spq_left; /* serialize spq */
-	spinlock_t      	spq_lock;
-
-	/* Flag for marking that there is either
-	 * STAT_QUERY or CFC DELETE ramrod pending
-	 */
-	u8      		stat_pending;
+#define ETH_RX_ERROR_FALGS	(ETH_FAST_PATH_RX_CQE_PHY_DECODE_ERR_FLG | \
+				 ETH_FAST_PATH_RX_CQE_IP_BAD_XSUM_FLG | \
+				 ETH_FAST_PATH_RX_CQE_L4_BAD_XSUM_FLG)
 
-	/* End of fields used in the performance code paths */
 
-	int     		panic;
-	int     		msglevel;
+#define U_SB_ETH_RX_CQ_INDEX		HC_INDEX_U_ETH_RX_CQ_CONS
+#define U_SB_ETH_RX_BD_INDEX		HC_INDEX_U_ETH_RX_BD_CONS
+#define C_SB_ETH_TX_CQ_INDEX		HC_INDEX_C_ETH_TX_CQ_CONS
 
-	u32     		flags;
-#define PCIX_FLAG       		1
-#define PCI_32BIT_FLAG  		2
-#define ONE_TDMA_FLAG   		4       /* no longer used */
-#define NO_WOL_FLAG     		8
-#define USING_DAC_FLAG  		0x10
-#define USING_MSIX_FLAG 		0x20
-#define ASF_ENABLE_FLAG 		0x40
+#define BNX2X_RX_SB_INDEX \
+	(&fp->status_blk->u_status_block.index_values[U_SB_ETH_RX_CQ_INDEX])
 
-	int     		port;
+#define BNX2X_RX_SB_BD_INDEX \
+	(&fp->status_blk->u_status_block.index_values[U_SB_ETH_RX_BD_INDEX])
 
-	int     		pm_cap;
-	int     		pcie_cap;
+#define BNX2X_RX_SB_INDEX_NUM \
+		(((U_SB_ETH_RX_CQ_INDEX << \
+		   USTORM_ETH_ST_CONTEXT_CONFIG_CQE_SB_INDEX_NUMBER_SHIFT) & \
+		  USTORM_ETH_ST_CONTEXT_CONFIG_CQE_SB_INDEX_NUMBER) | \
+		 ((U_SB_ETH_RX_BD_INDEX << \
+		   USTORM_ETH_ST_CONTEXT_CONFIG_BD_SB_INDEX_NUMBER_SHIFT) & \
+		  USTORM_ETH_ST_CONTEXT_CONFIG_BD_SB_INDEX_NUMBER))
 
-	struct work_struct	sp_task;
-	struct work_struct	reset_task;
+#define BNX2X_TX_SB_INDEX \
+	(&fp->status_blk->c_status_block.index_values[C_SB_ETH_TX_CQ_INDEX])
 
-	struct timer_list       timer;
-	int     		timer_interval;
-	int     		current_interval;
+/* common */
 
-	u32     		shmem_base;
+struct bnx2x_common {
 
 	u32			chip_id;
 /* chip num:16-31, rev:12-15, metal:4-11, bond_id:0-3 */
-#define CHIP_ID(bp)			(bp->chip_id & 0xfffffff0)
+#define CHIP_ID(bp)			(bp->common.chip_id & 0xfffffff0)
 
-#define CHIP_NUM(bp)			(bp->chip_id >> 16)
+#define CHIP_NUM(bp)			(bp->common.chip_id >> 16)
 #define CHIP_NUM_57710			0x164e
 #define CHIP_NUM_57711			0x164f
 #define CHIP_NUM_57711E			0x1650
@@ -572,7 +496,7 @@ struct bnx2x {
 					 CHIP_IS_57711E(bp))
 #define IS_E1H_OFFSET			CHIP_IS_E1H(bp)
 
-#define CHIP_REV(bp)			(bp->chip_id & 0x0000f000)
+#define CHIP_REV(bp)			(bp->common.chip_id & 0x0000f000)
 #define CHIP_REV_Ax			0x00000000
 /* assume maximum 5 revisions */
 #define CHIP_REV_IS_SLOW(bp)		(CHIP_REV(bp) > 0x00005000)
@@ -586,86 +510,250 @@ struct bnx2x {
 #define CHIP_TIME(bp)			((CHIP_REV_IS_EMUL(bp)) ? 2000 : \
 					((CHIP_REV_IS_FPGA(bp)) ? 200 : 1))
 
-#define CHIP_METAL(bp)			(bp->chip_id & 0x00000ff0)
-#define CHIP_BOND_ID(bp)		(bp->chip_id & 0x0000000f)
+#define CHIP_METAL(bp)			(bp->common.chip_id & 0x00000ff0)
+#define CHIP_BOND_ID(bp)		(bp->common.chip_id & 0x0000000f)
 
-	u16     		fw_seq;
-	u16     		fw_drv_pulse_wr_seq;
-	u32     		fw_mb;
+	int			flash_size;
+#define NVRAM_1MB_SIZE			0x20000	/* 1M bit in bytes */
+#define NVRAM_TIMEOUT_COUNT		30000
+#define NVRAM_PAGE_SIZE			256
 
-	u32     		hw_config;
+	u32			shmem_base;
+
+	u32			hw_config;
 	u32			board;
 
-	struct link_params	link_params;
+	u32			bc_ver;
+
+	char			*name;
+};
 
-	struct link_vars	link_vars;
+
+/* end of common */
+
+/* port */
+
+struct bnx2x_port {
+	u32			pmf;
 
 	u32			link_config;
 
-	u32     		supported;
+	u32			supported;
+/* link settings - missing defines */
+#define SUPPORTED_2500baseX_Full	(1 << 15)
+
+	u32			advertising;
 /* link settings - missing defines */
-#define SUPPORTED_2500baseT_Full	(1 << 15)
+#define ADVERTISED_2500baseX_Full	(1 << 15)
 
-	u32     		phy_addr;
+	u32			phy_addr;
 
 	/* used to synchronize phy accesses */
 	struct mutex		phy_mutex;
 
-	u32     		phy_id;
+	u32			port_stx;
 
+	struct nig_stats	old_nig_stats;
+};
 
-	u32     		advertising;
-/* link settings - missing defines */
-#define ADVERTISED_2500baseT_Full       (1 << 15)
+/* end of port */
+
+#define MAC_STX_NA      		0xffffffff
+
+#ifdef BNX2X_MULTI
+#define MAX_CONTEXT			16
+#else
+#define MAX_CONTEXT			1
+#endif
+
+union cdu_context {
+	struct eth_context eth;
+	char pad[1024];
+};
+
+#define MAX_DMAE_C			6
+
+/* DMA memory not used in fastpath */
+struct bnx2x_slowpath {
+	union cdu_context		context[MAX_CONTEXT];
+	struct eth_stats_query		fw_stats;
+	struct mac_configuration_cmd	mac_config;
+	struct mac_configuration_cmd	mcast_config;
+
+	/* used by dmae command executer */
+	struct dmae_command		dmae[MAX_DMAE_C];
+
+	union mac_stats 		mac_stats;
+	struct nig_stats		nig;
+	struct bnx2x_eth_stats  	eth_stats;
+
+	u32				wb_comp;
+#define BNX2X_WB_COMP_VAL       	0xe0d0d0ae
+	u32				wb_data[4];
+};
+
+#define bnx2x_sp(bp, var)		(&bp->slowpath->var)
+#define bnx2x_sp_mapping(bp, var) \
+		(bp->slowpath_mapping + offsetof(struct bnx2x_slowpath, var))
+
+
+/* attn group wiring */
+#define MAX_DYNAMIC_ATTN_GRPS		8
+
+struct attn_route {
+	u32	sig[4];
+};
+
+struct bnx2x {
+	/* Fields used in the tx and intr/napi performance paths
+	 * are grouped together in the beginning of the structure
+	 */
+	struct bnx2x_fastpath	fp[MAX_CONTEXT];
+	void __iomem		*regview;
+	void __iomem		*doorbells;
+#define BNX2X_DB_SIZE		(16*2048)
+
+	struct net_device	*dev;
+	struct pci_dev		*pdev;
+
+	atomic_t		intr_sem;
+	struct msix_entry       msix_table[MAX_CONTEXT+1];
+
+	int			tx_ring_size;
+
+#ifdef BCM_VLAN
+	struct vlan_group	*vlgrp;
+#endif
 
+	u32			rx_csum;
+	u32			rx_offset;
+	u32			rx_buf_use_size;	/* useable size */
+	u32			rx_buf_size;		/* with alignment */
+#define ETH_OVREHEAD			(ETH_HLEN + 8)	/* 8 for CRC + VLAN */
+#define ETH_MIN_PACKET_SIZE		60
+#define ETH_MAX_PACKET_SIZE		1500
+#define ETH_MAX_JUMBO_PACKET_SIZE	9600
 
-	u32     		bc_ver;
+	struct host_def_status_block *def_status_blk;
+#define DEF_SB_ID			16
+	u16			def_c_idx;
+	u16			def_u_idx;
+	u16			def_x_idx;
+	u16			def_t_idx;
+	u16			def_att_idx;
+	u32			attn_state;
+	struct attn_route	attn_group[MAX_DYNAMIC_ATTN_GRPS];
+	u32			aeu_mask;
+	u32			nig_mask;
+
+	/* slow path ring */
+	struct eth_spe		*spq;
+	dma_addr_t		spq_mapping;
+	u16			spq_prod_idx;
+	struct eth_spe		*spq_prod_bd;
+	struct eth_spe		*spq_last_bd;
+	u16			*dsb_sp_prod;
+	u16			spq_left; /* serialize spq */
+	/* used to synchronize spq accesses */
+	spinlock_t		spq_lock;
+
+	/* Flag for marking that there is either
+	 * STAT_QUERY or CFC DELETE ramrod pending
+	 */
+	u8      		stat_pending;
+
+	/* End of fileds used in the performance code paths */
+
+	int			panic;
+	int			msglevel;
+
+	u32			flags;
+#define PCIX_FLAG			1
+#define PCI_32BIT_FLAG			2
+#define ONE_TDMA_FLAG			4	/* no longer used */
+#define NO_WOL_FLAG			8
+#define USING_DAC_FLAG			0x10
+#define USING_MSIX_FLAG			0x20
+#define ASF_ENABLE_FLAG			0x40
+#define NO_MCP_FLAG			0x100
+#define BP_NOMCP(bp)			(bp->flags & NO_MCP_FLAG)
+
+	int			func;
+#define BP_PORT(bp)			(bp->func % PORT_MAX)
+#define BP_FUNC(bp)			(bp->func)
+#define BP_E1HVN(bp)			(bp->func >> 1)
+#define BP_L_ID(bp)			(BP_E1HVN(bp) << 2)
+/* assorted E1HVN */
+#define IS_E1HMF(bp)			(bp->e1hmf != 0)
+#define BP_MAX_QUEUES(bp)		(IS_E1HMF(bp) ? 4 : 16)
+
+	int			pm_cap;
+	int			pcie_cap;
+
+	struct work_struct	sp_task;
+	struct work_struct	reset_task;
+
+	struct timer_list	timer;
+	int			timer_interval;
+	int			current_interval;
+
+	u16			fw_seq;
+	u16			fw_drv_pulse_wr_seq;
+	u32			func_stx;
+
+	struct link_params	link_params;
+	struct link_vars	link_vars;
 
-	int     		flash_size;
-#define NVRAM_1MB_SIZE  		0x20000 /* 1M bit in bytes */
-#define NVRAM_TIMEOUT_COUNT     	30000
-#define NVRAM_PAGE_SIZE 		256
+	struct bnx2x_common	common;
+	struct bnx2x_port	port;
+
+	u32			mf_config;
+	u16			e1hov;
+	u8			e1hmf;
 
 	u8			wol;
 
-	int     		rx_ring_size;
+	int			rx_ring_size;
 
-	u16     		tx_quick_cons_trip_int;
-	u16     		tx_quick_cons_trip;
-	u16     		tx_ticks_int;
-	u16     		tx_ticks;
+	u16			tx_quick_cons_trip_int;
+	u16			tx_quick_cons_trip;
+	u16			tx_ticks_int;
+	u16			tx_ticks;
 
-	u16     		rx_quick_cons_trip_int;
-	u16     		rx_quick_cons_trip;
-	u16     		rx_ticks_int;
-	u16     		rx_ticks;
+	u16			rx_quick_cons_trip_int;
+	u16			rx_quick_cons_trip;
+	u16			rx_ticks_int;
+	u16			rx_ticks;
 
-	u32     		stats_ticks;
+	u32			stats_ticks;
+	u32			lin_cnt;
 
-	int     		state;
-#define BNX2X_STATE_CLOSED      	0x0
-#define BNX2X_STATE_OPENING_WAIT4_LOAD  0x1000
-#define BNX2X_STATE_OPENING_WAIT4_PORT  0x2000
+	int			state;
+#define BNX2X_STATE_CLOSED		0x0
+#define BNX2X_STATE_OPENING_WAIT4_LOAD	0x1000
+#define BNX2X_STATE_OPENING_WAIT4_PORT	0x2000
 #define BNX2X_STATE_OPEN		0x3000
-#define BNX2X_STATE_CLOSING_WAIT4_HALT  0x4000
+#define BNX2X_STATE_CLOSING_WAIT4_HALT	0x4000
 #define BNX2X_STATE_CLOSING_WAIT4_DELETE 0x5000
 #define BNX2X_STATE_CLOSING_WAIT4_UNLOAD 0x6000
-#define BNX2X_STATE_ERROR       	0xF000
+#define BNX2X_STATE_DISABLED		0xd000
+#define BNX2X_STATE_DIAG		0xe000
+#define BNX2X_STATE_ERROR		0xf000
 
-	int     		num_queues;
+	int			num_queues;
 
-	u32     		rx_mode;
-#define BNX2X_RX_MODE_NONE      	0
-#define BNX2X_RX_MODE_NORMAL    	1
-#define BNX2X_RX_MODE_ALLMULTI  	2
-#define BNX2X_RX_MODE_PROMISC   	3
-#define BNX2X_MAX_MULTICAST     	64
-#define BNX2X_MAX_EMUL_MULTI    	16
+	u32			rx_mode;
+#define BNX2X_RX_MODE_NONE		0
+#define BNX2X_RX_MODE_NORMAL		1
+#define BNX2X_RX_MODE_ALLMULTI		2
+#define BNX2X_RX_MODE_PROMISC		3
+#define BNX2X_MAX_MULTICAST		64
+#define BNX2X_MAX_EMUL_MULTI		16
 
-	dma_addr_t      	def_status_blk_mapping;
+	dma_addr_t		def_status_blk_mapping;
 
-	struct bnx2x_slowpath   *slowpath;
-	dma_addr_t      	slowpath_mapping;
+	struct bnx2x_slowpath	*slowpath;
+	dma_addr_t		slowpath_mapping;
 
 #ifdef BCM_ISCSI
 	void    		*t1;
@@ -742,8 +830,10 @@ int bnx2x_set_gpio(struct bnx2x *bp, int gpio_num, u32 mode);
 
 /* MC hsi */
 #define RX_COPY_THRESH  		92
-#define BCM_PAGE_BITS   		12
-#define BCM_PAGE_SIZE   		(1 << BCM_PAGE_BITS)
+#define BCM_PAGE_SHIFT			12
+#define BCM_PAGE_SIZE			(1 << BCM_PAGE_SHIFT)
+#define BCM_PAGE_MASK			(~(BCM_PAGE_SIZE - 1))
+#define BCM_PAGE_ALIGN(addr)	(((addr) + BCM_PAGE_SIZE - 1) & BCM_PAGE_MASK)
 
 #define NUM_TX_RINGS    		16
 #define TX_DESC_CNT     	(BCM_PAGE_SIZE / sizeof(struct eth_tx_bd))
@@ -795,26 +885,11 @@ int bnx2x_set_gpio(struct bnx2x *bp, int gpio_num, u32 mode);
 
 
 /* must be used on a CID before placing it on a HW ring */
-#define HW_CID(bp, x)   		(x | (bp->port << 23))
+#define HW_CID(bp, x)		((BP_PORT(bp) << 23) | (BP_E1HVN(bp) << 17) | x)
 
 #define SP_DESC_CNT     	(BCM_PAGE_SIZE / sizeof(struct eth_spe))
 #define MAX_SP_DESC_CNT 		(SP_DESC_CNT - 1)
 
-#define ATTN_NIG_FOR_FUNC       	(1L << 8)
-#define ATTN_SW_TIMER_4_FUNC    	(1L << 9)
-#define GPIO_2_FUNC     		(1L << 10)
-#define GPIO_3_FUNC     		(1L << 11)
-#define GPIO_4_FUNC     		(1L << 12)
-#define ATTN_GENERAL_ATTN_1     	(1L << 13)
-#define ATTN_GENERAL_ATTN_2     	(1L << 14)
-#define ATTN_GENERAL_ATTN_3     	(1L << 15)
-#define ATTN_GENERAL_ATTN_4     	(1L << 13)
-#define ATTN_GENERAL_ATTN_5     	(1L << 14)
-#define ATTN_GENERAL_ATTN_6     	(1L << 15)
-
-#define ATTN_HARD_WIRED_MASK    	0xff00
-#define ATTENTION_ID    		4
-
 
 #define BNX2X_BTR       		3
 #define MAX_SPQ_PENDING 		8
@@ -831,6 +906,31 @@ int bnx2x_set_gpio(struct bnx2x *bp, int gpio_num, u32 mode);
 		       DPM_TRIGER_TYPE); \
 	} while (0)
 
+static inline u32 reg_poll(struct bnx2x *bp, u32 reg, u32 expected, int ms,
+			   int wait)
+{
+	u32 val;
+
+	do {
+		val = REG_RD(bp, reg);
+		if (val == expected)
+			break;
+		ms -= wait;
+		msleep(wait);
+
+	} while (ms > 0);
+
+	return val;
+}
+
+
+/* load/unload mode */
+#define LOAD_NORMAL			0
+#define LOAD_OPEN			1
+#define LOAD_DIAG			2
+#define UNLOAD_NORMAL			0
+#define UNLOAD_CLOSE			1
+
 /* DMAE command defines */
 #define DMAE_CMD_SRC_PCI		0
 #define DMAE_CMD_SRC_GRC		DMAE_COMMAND_SRC
@@ -877,23 +977,48 @@ int bnx2x_set_gpio(struct bnx2x *bp, int gpio_num, u32 mode);
 
 #define pbd_tcp_flags(skb)  	(ntohl(tcp_flag_word(tcp_hdr(skb)))>>16 & 0xff)
 
-/* stuff added to make the code fit 80Col */
+/* must be used on a CID before placing it on a HW ring */
 
-#define TPA_TYPE_START  		ETH_FAST_PATH_RX_CQE_START_FLG
-#define TPA_TYPE_END    		ETH_FAST_PATH_RX_CQE_END_FLG
-#define TPA_TYPE(cqe)   	(cqe->fast_path_cqe.error_type_flags & \
-				 (TPA_TYPE_START | TPA_TYPE_END))
 #define BNX2X_RX_SUM_OK(cqe) \
 			(!(cqe->fast_path_cqe.status_flags & \
 			 (ETH_FAST_PATH_RX_CQE_IP_XSUM_NO_VALIDATION_FLG | \
 			  ETH_FAST_PATH_RX_CQE_L4_XSUM_NO_VALIDATION_FLG)))
 
-#define BNX2X_RX_SUM_FIX(cqe) \
-			((le16_to_cpu(cqe->fast_path_cqe.pars_flags.flags) & \
-			  PARSING_FLAGS_OVER_ETHERNET_PROTOCOL) == \
-			 (1 << PARSING_FLAGS_OVER_ETHERNET_PROTOCOL_SHIFT))
+/* CMNG constants
+   derived from lab experiments, and not from system spec calculations !!! */
+#define DEF_MIN_RATE			100
+/* resolution of the rate shaping timer - 100 usec */
+#define RS_PERIODIC_TIMEOUT_USEC	100
+/* resolution of fairness algorithm in usecs -
+   coefficient for clauclating the actuall t fair */
+#define T_FAIR_COEF			10000000
+/* number of bytes in single QM arbitration cycle -
+   coeffiecnt for calculating the fairness timer */
+#define QM_ARB_BYTES			40000
+#define FAIR_MEM			2
+
+
+#define ATTN_NIG_FOR_FUNC		(1L << 8)
+#define ATTN_SW_TIMER_4_FUNC		(1L << 9)
+#define GPIO_2_FUNC			(1L << 10)
+#define GPIO_3_FUNC			(1L << 11)
+#define GPIO_4_FUNC			(1L << 12)
+#define ATTN_GENERAL_ATTN_1		(1L << 13)
+#define ATTN_GENERAL_ATTN_2		(1L << 14)
+#define ATTN_GENERAL_ATTN_3		(1L << 15)
+#define ATTN_GENERAL_ATTN_4		(1L << 13)
+#define ATTN_GENERAL_ATTN_5		(1L << 14)
+#define ATTN_GENERAL_ATTN_6		(1L << 15)
+
+#define ATTN_HARD_WIRED_MASK		0xff00
+#define ATTENTION_ID			4
 
 
+/* stuff added to make the code fit 80Col */
+
+#define BNX2X_PMF_LINK_ASSERT \
+	GENERAL_ATTEN_OFFSET(LINK_SYNC_ATTENTION_BIT_FUNC_0 + BP_FUNC(bp))
+
 #define BNX2X_MC_ASSERT_BITS \
 	(GENERAL_ATTEN_OFFSET(TSTORM_FATAL_ASSERT_ATTENTION_BIT) | \
 	 GENERAL_ATTEN_OFFSET(USTORM_FATAL_ASSERT_ATTENTION_BIT) | \
@@ -906,12 +1031,20 @@ int bnx2x_set_gpio(struct bnx2x *bp, int gpio_num, u32 mode);
 #define BNX2X_DOORQ_ASSERT \
 	AEU_INPUTS_ATTN_BITS_DOORBELLQ_HW_INTERRUPT
 
+#define BNX2X_GRC_TIMEOUT	GENERAL_ATTEN_OFFSET(LATCHED_ATTN_TIMEOUT_GRC)
+#define BNX2X_GRC_RSV		(GENERAL_ATTEN_OFFSET(LATCHED_ATTN_RBCR) | \
+				 GENERAL_ATTEN_OFFSET(LATCHED_ATTN_RBCT) | \
+				 GENERAL_ATTEN_OFFSET(LATCHED_ATTN_RBCN) | \
+				 GENERAL_ATTEN_OFFSET(LATCHED_ATTN_RBCU) | \
+				 GENERAL_ATTEN_OFFSET(LATCHED_ATTN_RBCP) | \
+				 GENERAL_ATTEN_OFFSET(LATCHED_ATTN_RSVD_GRC))
+
 #define HW_INTERRUT_ASSERT_SET_0 \
 				(AEU_INPUTS_ATTN_BITS_TSDM_HW_INTERRUPT | \
 				 AEU_INPUTS_ATTN_BITS_TCM_HW_INTERRUPT | \
 				 AEU_INPUTS_ATTN_BITS_TSEMI_HW_INTERRUPT | \
 				 AEU_INPUTS_ATTN_BITS_PBF_HW_INTERRUPT)
-#define HW_PRTY_ASSERT_SET_0    (AEU_INPUTS_ATTN_BITS_BRB_PARITY_ERROR | \
+#define HW_PRTY_ASSERT_SET_0	(AEU_INPUTS_ATTN_BITS_BRB_PARITY_ERROR | \
 				 AEU_INPUTS_ATTN_BITS_PARSER_PARITY_ERROR | \
 				 AEU_INPUTS_ATTN_BITS_TSDM_PARITY_ERROR | \
 				 AEU_INPUTS_ATTN_BITS_SEARCHER_PARITY_ERROR |\
@@ -928,7 +1061,7 @@ int bnx2x_set_gpio(struct bnx2x *bp, int gpio_num, u32 mode);
 				 AEU_INPUTS_ATTN_BITS_UPB_HW_INTERRUPT | \
 				 AEU_INPUTS_ATTN_BITS_CSDM_HW_INTERRUPT | \
 				 AEU_INPUTS_ATTN_BITS_CCM_HW_INTERRUPT)
-#define HW_PRTY_ASSERT_SET_1    (AEU_INPUTS_ATTN_BITS_PBCLIENT_PARITY_ERROR |\
+#define HW_PRTY_ASSERT_SET_1	(AEU_INPUTS_ATTN_BITS_PBCLIENT_PARITY_ERROR |\
 				 AEU_INPUTS_ATTN_BITS_QM_PARITY_ERROR | \
 				 AEU_INPUTS_ATTN_BITS_XSDM_PARITY_ERROR | \
 				 AEU_INPUTS_ATTN_BITS_XSEMI_PARITY_ERROR | \
@@ -945,7 +1078,7 @@ int bnx2x_set_gpio(struct bnx2x *bp, int gpio_num, u32 mode);
 				 AEU_INPUTS_ATTN_BITS_DMAE_HW_INTERRUPT | \
 			AEU_INPUTS_ATTN_BITS_PXPPCICLOCKCLIENT_HW_INTERRUPT |\
 				 AEU_INPUTS_ATTN_BITS_MISC_HW_INTERRUPT)
-#define HW_PRTY_ASSERT_SET_2    (AEU_INPUTS_ATTN_BITS_CSEMI_PARITY_ERROR | \
+#define HW_PRTY_ASSERT_SET_2	(AEU_INPUTS_ATTN_BITS_CSEMI_PARITY_ERROR | \
 				 AEU_INPUTS_ATTN_BITS_PXP_PARITY_ERROR | \
 			AEU_INPUTS_ATTN_BITS_PXPPCICLOCKCLIENT_PARITY_ERROR |\
 				 AEU_INPUTS_ATTN_BITS_CFC_PARITY_ERROR | \
@@ -954,42 +1087,44 @@ int bnx2x_set_gpio(struct bnx2x *bp, int gpio_num, u32 mode);
 				 AEU_INPUTS_ATTN_BITS_MISC_PARITY_ERROR)
 
 
-#define ETH_RX_ERROR_FALGS      (ETH_FAST_PATH_RX_CQE_PHY_DECODE_ERR_FLG | \
-				 ETH_FAST_PATH_RX_CQE_IP_BAD_XSUM_FLG | \
-				 ETH_FAST_PATH_RX_CQE_L4_BAD_XSUM_FLG)
-
-
 #define MULTI_FLAGS \
-	(TSTORM_ETH_FUNCTION_COMMON_CONFIG_RSS_IPV4_CAPABILITY     | \
-	 TSTORM_ETH_FUNCTION_COMMON_CONFIG_RSS_IPV4_TCP_CAPABILITY | \
-	 TSTORM_ETH_FUNCTION_COMMON_CONFIG_RSS_IPV6_CAPABILITY     | \
-	 TSTORM_ETH_FUNCTION_COMMON_CONFIG_RSS_IPV6_TCP_CAPABILITY | \
-	 TSTORM_ETH_FUNCTION_COMMON_CONFIG_RSS_ENABLE)
+		(TSTORM_ETH_FUNCTION_COMMON_CONFIG_RSS_IPV4_CAPABILITY | \
+		 TSTORM_ETH_FUNCTION_COMMON_CONFIG_RSS_IPV4_TCP_CAPABILITY | \
+		 TSTORM_ETH_FUNCTION_COMMON_CONFIG_RSS_IPV6_CAPABILITY | \
+		 TSTORM_ETH_FUNCTION_COMMON_CONFIG_RSS_IPV6_TCP_CAPABILITY | \
+		 TSTORM_ETH_FUNCTION_COMMON_CONFIG_RSS_ENABLE)
 
-#define MULTI_MASK      0x7f
+#define MULTI_MASK			0x7f
 
 
-#define U_SB_ETH_RX_CQ_INDEX    	HC_INDEX_U_ETH_RX_CQ_CONS
-#define C_SB_ETH_TX_CQ_INDEX    	HC_INDEX_C_ETH_TX_CQ_CONS
-#define C_DEF_SB_SP_INDEX       	HC_INDEX_DEF_C_ETH_SLOW_PATH
-
-#define BNX2X_RX_SB_INDEX \
-	&fp->status_blk->u_status_block.index_values[U_SB_ETH_RX_CQ_INDEX]
+#define DEF_USB_FUNC_OFF		(2 + 2*HC_USTORM_DEF_SB_NUM_INDICES)
+#define DEF_CSB_FUNC_OFF		(2 + 2*HC_CSTORM_DEF_SB_NUM_INDICES)
+#define DEF_XSB_FUNC_OFF		(2 + 2*HC_XSTORM_DEF_SB_NUM_INDICES)
+#define DEF_TSB_FUNC_OFF		(2 + 2*HC_TSTORM_DEF_SB_NUM_INDICES)
 
-#define BNX2X_TX_SB_INDEX \
-	&fp->status_blk->c_status_block.index_values[C_SB_ETH_TX_CQ_INDEX]
+#define C_DEF_SB_SP_INDEX		HC_INDEX_DEF_C_ETH_SLOW_PATH
 
 #define BNX2X_SP_DSB_INDEX \
-&bp->def_status_blk->c_def_status_block.index_values[C_DEF_SB_SP_INDEX]
+(&bp->def_status_blk->c_def_status_block.index_values[C_DEF_SB_SP_INDEX])
 
 
 #define CAM_IS_INVALID(x) \
 (x.target_table_entry.flags == TSTORM_CAM_TARGET_TABLE_ENTRY_ACTION_TYPE)
 
 #define CAM_INVALIDATE(x) \
-x.target_table_entry.flags = TSTORM_CAM_TARGET_TABLE_ENTRY_ACTION_TYPE
+	(x.target_table_entry.flags = TSTORM_CAM_TARGET_TABLE_ENTRY_ACTION_TYPE)
+
+
+/* Number of u32 elements in MC hash array */
+#define MC_HASH_SIZE			8
+#define MC_HASH_OFFSET(bp, i)		(BAR_TSTRORM_INTMEM + \
+	TSTORM_APPROXIMATE_MATCH_MULTICAST_FILTERING_OFFSET(BP_FUNC(bp)) + i*4)
 
 
+#ifndef PXP2_REG_PXP2_INT_STS
+#define PXP2_REG_PXP2_INT_STS		PXP2_REG_PXP2_INT_STS_0
+#endif
+
 /* MISC_REG_RESET_REG - this is here for the hsi to work don't touch */
 
 #endif /* bnx2x.h */
diff --git a/drivers/net/bnx2x_fw_defs.h b/drivers/net/bnx2x_fw_defs.h
index 3b96890..e3da7f6 100644
--- a/drivers/net/bnx2x_fw_defs.h
+++ b/drivers/net/bnx2x_fw_defs.h
@@ -8,191 +8,390 @@
  */
 
 
-#define CSTORM_DEF_SB_HC_DISABLE_OFFSET(port, index)\
-	(0x1922 + (port * 0x40) + (index * 0x4))
-#define CSTORM_DEF_SB_HOST_SB_ADDR_OFFSET(port)\
-	(0x1900 + (port * 0x40))
-#define CSTORM_HC_BTR_OFFSET(port)\
-	(0x1984 + (port * 0xc0))
-#define CSTORM_SB_HC_DISABLE_OFFSET(port, cpu_id, index)\
-	(0x141a + (port * 0x280) + (cpu_id * 0x28) + (index * 0x4))
-#define CSTORM_SB_HC_TIMEOUT_OFFSET(port, cpu_id, index)\
-	(0x1418 + (port * 0x280) + (cpu_id * 0x28) + (index * 0x4))
-#define CSTORM_SB_HOST_SB_ADDR_OFFSET(port, cpu_id)\
-	(0x1400 + (port * 0x280) + (cpu_id * 0x28))
-#define CSTORM_STATS_FLAGS_OFFSET(port) 		(0x5108 + (port * 0x8))
-#define TSTORM_CLIENT_CONFIG_OFFSET(port, client_id)\
-	(0x1510 + (port * 0x240) + (client_id * 0x20))
-#define TSTORM_DEF_SB_HC_DISABLE_OFFSET(port, index)\
-	(0x138a + (port * 0x28) + (index * 0x4))
-#define TSTORM_DEF_SB_HOST_SB_ADDR_OFFSET(port)\
-	(0x1370 + (port * 0x28))
-#define TSTORM_ETH_STATS_QUERY_ADDR_OFFSET(port)\
-	(0x4b70 + (port * 0x8))
-#define TSTORM_FUNCTION_COMMON_CONFIG_OFFSET(function)\
-	(0x1418 + (function * 0x30))
-#define TSTORM_HC_BTR_OFFSET(port)\
-	(0x13c4 + (port * 0x18))
-#define TSTORM_INDIRECTION_TABLE_OFFSET(port)\
-	(0x22c8 + (port * 0x80))
-#define TSTORM_INDIRECTION_TABLE_SIZE			0x80
-#define TSTORM_MAC_FILTER_CONFIG_OFFSET(port)\
-	(0x1420 + (port * 0x30))
-#define TSTORM_RCQ_PROD_OFFSET(port, client_id)\
-	(0x1508 + (port * 0x240) + (client_id * 0x20))
-#define TSTORM_STATS_FLAGS_OFFSET(port) 		(0x4b90 + (port * 0x8))
-#define USTORM_DEF_SB_HC_DISABLE_OFFSET(port, index)\
-	(0x191a + (port * 0x28) + (index * 0x4))
-#define USTORM_DEF_SB_HOST_SB_ADDR_OFFSET(port)\
-	(0x1900 + (port * 0x28))
-#define USTORM_HC_BTR_OFFSET(port)\
-	(0x1954 + (port * 0xb8))
-#define USTORM_MEM_WORKAROUND_ADDRESS_OFFSET(port)\
-	(0x5408 + (port * 0x8))
-#define USTORM_SB_HC_DISABLE_OFFSET(port, cpu_id, index)\
-	(0x141a + (port * 0x280) + (cpu_id * 0x28) + (index * 0x4))
-#define USTORM_SB_HC_TIMEOUT_OFFSET(port, cpu_id, index)\
-	(0x1418 + (port * 0x280) + (cpu_id * 0x28) + (index * 0x4))
-#define USTORM_SB_HOST_SB_ADDR_OFFSET(port, cpu_id)\
-	(0x1400 + (port * 0x280) + (cpu_id * 0x28))
-#define XSTORM_ASSERT_LIST_INDEX_OFFSET 		0x1000
-#define XSTORM_ASSERT_LIST_OFFSET(idx)			(0x1020 + (idx * 0x10))
-#define XSTORM_DEF_SB_HC_DISABLE_OFFSET(port, index)\
-	(0x141a + (port * 0x28) + (index * 0x4))
-#define XSTORM_DEF_SB_HOST_SB_ADDR_OFFSET(port)\
-	(0x1400 + (port * 0x28))
-#define XSTORM_ETH_STATS_QUERY_ADDR_OFFSET(port)\
-	(0x5408 + (port * 0x8))
-#define XSTORM_HC_BTR_OFFSET(port)\
-	(0x1454 + (port * 0x18))
-#define XSTORM_SPQ_PAGE_BASE_OFFSET(port)\
-	(0x5328 + (port * 0x18))
-#define XSTORM_SPQ_PROD_OFFSET(port)\
-	(0x5330 + (port * 0x18))
-#define XSTORM_STATS_FLAGS_OFFSET(port) 		(0x53f8 + (port * 0x8))
+#define CSTORM_ASSERT_LIST_INDEX_OFFSET \
+	(IS_E1H_OFFSET? 0x7000 : 0x1000)
+#define CSTORM_ASSERT_LIST_OFFSET(idx) \
+	(IS_E1H_OFFSET? (0x7020 + (idx * 0x10)) : (0x1020 + (idx * 0x10)))
+#define CSTORM_DEF_SB_HC_DISABLE_OFFSET(function, index) \
+	(IS_E1H_OFFSET? (0x8522 + ((function>>1) * 0x40) + ((function&1) \
+	* 0x100) + (index * 0x4)) : (0x1922 + (function * 0x40) + (index \
+	* 0x4)))
+#define CSTORM_DEF_SB_HOST_SB_ADDR_OFFSET(function) \
+	(IS_E1H_OFFSET? (0x8500 + ((function>>1) * 0x40) + ((function&1) \
+	* 0x100)) : (0x1900 + (function * 0x40)))
+#define CSTORM_DEF_SB_HOST_STATUS_BLOCK_OFFSET(function) \
+	(IS_E1H_OFFSET? (0x8508 + ((function>>1) * 0x40) + ((function&1) \
+	* 0x100)) : (0x1908 + (function * 0x40)))
+#define CSTORM_FUNCTION_MODE_OFFSET \
+	(IS_E1H_OFFSET? 0x11e8 : 0xffffffff)
+#define CSTORM_HC_BTR_OFFSET(port) \
+	(IS_E1H_OFFSET? (0x8704 + (port * 0xf0)) : (0x1984 + (port * 0xc0)))
+#define CSTORM_SB_HC_DISABLE_OFFSET(port, cpu_id, index) \
+	(IS_E1H_OFFSET? (0x801a + (port * 0x280) + (cpu_id * 0x28) + \
+	(index * 0x4)) : (0x141a + (port * 0x280) + (cpu_id * 0x28) + \
+	(index * 0x4)))
+#define CSTORM_SB_HC_TIMEOUT_OFFSET(port, cpu_id, index) \
+	(IS_E1H_OFFSET? (0x8018 + (port * 0x280) + (cpu_id * 0x28) + \
+	(index * 0x4)) : (0x1418 + (port * 0x280) + (cpu_id * 0x28) + \
+	(index * 0x4)))
+#define CSTORM_SB_HOST_SB_ADDR_OFFSET(port, cpu_id) \
+	(IS_E1H_OFFSET? (0x8000 + (port * 0x280) + (cpu_id * 0x28)) : \
+	(0x1400 + (port * 0x280) + (cpu_id * 0x28)))
+#define CSTORM_SB_HOST_STATUS_BLOCK_OFFSET(port, cpu_id) \
+	(IS_E1H_OFFSET? (0x8008 + (port * 0x280) + (cpu_id * 0x28)) : \
+	(0x1408 + (port * 0x280) + (cpu_id * 0x28)))
+#define CSTORM_STATS_FLAGS_OFFSET(function) \
+	(IS_E1H_OFFSET? (0x1108 + (function * 0x8)) : (0x5108 + \
+	(function * 0x8)))
+#define TSTORM_APPROXIMATE_MATCH_MULTICAST_FILTERING_OFFSET(function) \
+	(IS_E1H_OFFSET? (0x31c0 + (function * 0x20)) : 0xffffffff)
+#define TSTORM_ASSERT_LIST_INDEX_OFFSET \
+	(IS_E1H_OFFSET? 0xa000 : 0x1000)
+#define TSTORM_ASSERT_LIST_OFFSET(idx) \
+	(IS_E1H_OFFSET? (0xa020 + (idx * 0x10)) : (0x1020 + (idx * 0x10)))
+#define TSTORM_CLIENT_CONFIG_OFFSET(port, client_id) \
+	(IS_E1H_OFFSET? (0x3358 + (port * 0x3e8) + (client_id * 0x28)) : \
+	(0x9c8 + (port * 0x2f8) + (client_id * 0x28)))
+#define TSTORM_DEF_SB_HC_DISABLE_OFFSET(function, index) \
+	(IS_E1H_OFFSET? (0xb01a + ((function>>1) * 0x28) + ((function&1) \
+	* 0xa0) + (index * 0x4)) : (0x141a + (function * 0x28) + (index * \
+	0x4)))
+#define TSTORM_DEF_SB_HOST_SB_ADDR_OFFSET(function) \
+	(IS_E1H_OFFSET? (0xb000 + ((function>>1) * 0x28) + ((function&1) \
+	* 0xa0)) : (0x1400 + (function * 0x28)))
+#define TSTORM_DEF_SB_HOST_STATUS_BLOCK_OFFSET(function) \
+	(IS_E1H_OFFSET? (0xb008 + ((function>>1) * 0x28) + ((function&1) \
+	* 0xa0)) : (0x1408 + (function * 0x28)))
+#define TSTORM_ETH_STATS_QUERY_ADDR_OFFSET(function) \
+	(IS_E1H_OFFSET? (0x2b80 + (function * 0x8)) : (0x4b68 + \
+	(function * 0x8)))
+#define TSTORM_FUNCTION_COMMON_CONFIG_OFFSET(function) \
+	(IS_E1H_OFFSET? (0x3000 + (function * 0x38)) : (0x1500 + \
+	(function * 0x38)))
+#define TSTORM_FUNCTION_MODE_OFFSET \
+	(IS_E1H_OFFSET? 0x1ad0 : 0xffffffff)
+#define TSTORM_HC_BTR_OFFSET(port) \
+	(IS_E1H_OFFSET? (0xb144 + (port * 0x30)) : (0x1454 + (port * 0x18)))
+#define TSTORM_INDIRECTION_TABLE_OFFSET(function) \
+	(IS_E1H_OFFSET? (0x12c8 + (function * 0x80)) : (0x22c8 + \
+	(function * 0x80)))
+#define TSTORM_INDIRECTION_TABLE_SIZE 0x80
+#define TSTORM_MAC_FILTER_CONFIG_OFFSET(function) \
+	(IS_E1H_OFFSET? (0x3008 + (function * 0x38)) : (0x1508 + \
+	(function * 0x38)))
+#define TSTORM_RX_PRODS_OFFSET(port, client_id) \
+	(IS_E1H_OFFSET? (0x3350 + (port * 0x3e8) + (client_id * 0x28)) : \
+	(0x9c0 + (port * 0x2f8) + (client_id * 0x28)))
+#define TSTORM_STATS_FLAGS_OFFSET(function) \
+	(IS_E1H_OFFSET? (0x2c00 + (function * 0x8)) : (0x4b88 + \
+	(function * 0x8)))
+#define TSTORM_TPA_EXIST_OFFSET (IS_E1H_OFFSET? 0x3b30 : 0x1c20)
+#define USTORM_AGG_DATA_OFFSET (IS_E1H_OFFSET? 0xa040 : 0x2c10)
+#define USTORM_AGG_DATA_SIZE (IS_E1H_OFFSET? 0x2440 : 0x1200)
+#define USTORM_ASSERT_LIST_INDEX_OFFSET \
+	(IS_E1H_OFFSET? 0x8000 : 0x1000)
+#define USTORM_ASSERT_LIST_OFFSET(idx) \
+	(IS_E1H_OFFSET? (0x8020 + (idx * 0x10)) : (0x1020 + (idx * 0x10)))
+#define USTORM_CQE_PAGE_BASE_OFFSET(port, clientId) \
+	(IS_E1H_OFFSET? (0x3298 + (port * 0x258) + (clientId * 0x18)) : \
+	(0x5450 + (port * 0x1c8) + (clientId * 0x18)))
+#define USTORM_DEF_SB_HC_DISABLE_OFFSET(function, index) \
+	(IS_E1H_OFFSET? (0x951a + ((function>>1) * 0x28) + ((function&1) \
+	* 0xa0) + (index * 0x4)) : (0x191a + (function * 0x28) + (index * \
+	0x4)))
+#define USTORM_DEF_SB_HOST_SB_ADDR_OFFSET(function) \
+	(IS_E1H_OFFSET? (0x9500 + ((function>>1) * 0x28) + ((function&1) \
+	* 0xa0)) : (0x1900 + (function * 0x28)))
+#define USTORM_DEF_SB_HOST_STATUS_BLOCK_OFFSET(function) \
+	(IS_E1H_OFFSET? (0x9508 + ((function>>1) * 0x28) + ((function&1) \
+	* 0xa0)) : (0x1908 + (function * 0x28)))
+#define USTORM_FUNCTION_MODE_OFFSET \
+	(IS_E1H_OFFSET? 0x2448 : 0xffffffff)
+#define USTORM_HC_BTR_OFFSET(port) \
+	(IS_E1H_OFFSET? (0x9644 + (port * 0xd0)) : (0x1954 + (port * 0xb8)))
+#define USTORM_MAX_AGG_SIZE_OFFSET(port, clientId) \
+	(IS_E1H_OFFSET? (0x3290 + (port * 0x258) + (clientId * 0x18)) : \
+	(0x5448 + (port * 0x1c8) + (clientId * 0x18)))
+#define USTORM_MEM_WORKAROUND_ADDRESS_OFFSET(function) \
+	(IS_E1H_OFFSET? (0x2408 + (function * 0x8)) : (0x5408 + \
+	(function * 0x8)))
+#define USTORM_SB_HC_DISABLE_OFFSET(port, cpu_id, index) \
+	(IS_E1H_OFFSET? (0x901a + (port * 0x280) + (cpu_id * 0x28) + \
+	(index * 0x4)) : (0x141a + (port * 0x280) + (cpu_id * 0x28) + \
+	(index * 0x4)))
+#define USTORM_SB_HC_TIMEOUT_OFFSET(port, cpu_id, index) \
+	(IS_E1H_OFFSET? (0x9018 + (port * 0x280) + (cpu_id * 0x28) + \
+	(index * 0x4)) : (0x1418 + (port * 0x280) + (cpu_id * 0x28) + \
+	(index * 0x4)))
+#define USTORM_SB_HOST_SB_ADDR_OFFSET(port, cpu_id) \
+	(IS_E1H_OFFSET? (0x9000 + (port * 0x280) + (cpu_id * 0x28)) : \
+	(0x1400 + (port * 0x280) + (cpu_id * 0x28)))
+#define USTORM_SB_HOST_STATUS_BLOCK_OFFSET(port, cpu_id) \
+	(IS_E1H_OFFSET? (0x9008 + (port * 0x280) + (cpu_id * 0x28)) : \
+	(0x1408 + (port * 0x280) + (cpu_id * 0x28)))
+#define XSTORM_ASSERT_LIST_INDEX_OFFSET \
+	(IS_E1H_OFFSET? 0x9000 : 0x1000)
+#define XSTORM_ASSERT_LIST_OFFSET(idx) \
+	(IS_E1H_OFFSET? (0x9020 + (idx * 0x10)) : (0x1020 + (idx * 0x10)))
+#define XSTORM_CMNG_PER_PORT_VARS_OFFSET(port) \
+	(IS_E1H_OFFSET? (0x24a8 + (port * 0x40)) : (0x3ba0 + (port * 0x40)))
+#define XSTORM_DEF_SB_HC_DISABLE_OFFSET(function, index) \
+	(IS_E1H_OFFSET? (0xa01a + ((function>>1) * 0x28) + ((function&1) \
+	* 0xa0) + (index * 0x4)) : (0x141a + (function * 0x28) + (index * \
+	0x4)))
+#define XSTORM_DEF_SB_HOST_SB_ADDR_OFFSET(function) \
+	(IS_E1H_OFFSET? (0xa000 + ((function>>1) * 0x28) + ((function&1) \
+	* 0xa0)) : (0x1400 + (function * 0x28)))
+#define XSTORM_DEF_SB_HOST_STATUS_BLOCK_OFFSET(function) \
+	(IS_E1H_OFFSET? (0xa008 + ((function>>1) * 0x28) + ((function&1) \
+	* 0xa0)) : (0x1408 + (function * 0x28)))
+#define XSTORM_E1HOV_OFFSET(function) \
+	(IS_E1H_OFFSET? (0x2ab8 + (function * 0x2)) : 0xffffffff)
+#define XSTORM_ETH_STATS_QUERY_ADDR_OFFSET(function) \
+	(IS_E1H_OFFSET? (0x2418 + (function * 0x8)) : (0x3b70 + \
+	(function * 0x8)))
+#define XSTORM_FAIRNESS_PER_VN_VARS_OFFSET(function) \
+	(IS_E1H_OFFSET? (0x2568 + (function * 0x70)) : (0x3c60 + \
+	(function * 0x70)))
+#define XSTORM_FUNCTION_MODE_OFFSET \
+	(IS_E1H_OFFSET? 0x2ac8 : 0xffffffff)
+#define XSTORM_HC_BTR_OFFSET(port) \
+	(IS_E1H_OFFSET? (0xa144 + (port * 0x30)) : (0x1454 + (port * 0x18)))
+#define XSTORM_RATE_SHAPING_PER_VN_VARS_OFFSET(function) \
+	(IS_E1H_OFFSET? (0x2528 + (function * 0x70)) : (0x3c20 + \
+	(function * 0x70)))
+#define XSTORM_SPQ_PAGE_BASE_OFFSET(function) \
+	(IS_E1H_OFFSET? (0x2000 + (function * 0x10)) : (0x3328 + \
+	(function * 0x10)))
+#define XSTORM_SPQ_PROD_OFFSET(function) \
+	(IS_E1H_OFFSET? (0x2008 + (function * 0x10)) : (0x3330 + \
+	(function * 0x10)))
+#define XSTORM_STATS_FLAGS_OFFSET(function) \
+	(IS_E1H_OFFSET? (0x23d8 + (function * 0x8)) : (0x3b60 + \
+	(function * 0x8)))
 #define COMMON_ASM_INVALID_ASSERT_OPCODE 0x0
 
 /**
 * This file defines HSI constatnts for the ETH flow
 */
-
-/* hash types */
-#define DEFAULT_HASH_TYPE			0
-#define IPV4_HASH_TYPE				1
-#define TCP_IPV4_HASH_TYPE			2
-#define IPV6_HASH_TYPE				3
-#define TCP_IPV6_HASH_TYPE			4
+#ifdef _EVEREST_MICROCODE
+#include "microcode_constants.h"
+#include "eth_rx_bd.h"
+#include "eth_tx_bd.h"
+#include "eth_rx_cqe.h"
+#include "eth_rx_sge.h"
+#include "eth_rx_cqe_next_page.h"
+#endif
+
+/* RSS hash types */
+#define DEFAULT_HASH_TYPE 0
+#define IPV4_HASH_TYPE 1
+#define TCP_IPV4_HASH_TYPE 2
+#define IPV6_HASH_TYPE 3
+#define TCP_IPV6_HASH_TYPE 4
+
+/* Ethernet Ring parmaters */
+#define X_ETH_LOCAL_RING_SIZE 13
+#define FIRST_BD_IN_PKT 0
+#define PARSE_BD_INDEX 1
+#define NUM_OF_ETH_BDS_IN_PAGE \
+	((PAGE_SIZE) / (STRUCT_SIZE(eth_tx_bd)/8))
+
+
+/* Rx ring params */
+#define U_ETH_LOCAL_BD_RING_SIZE (16)
+#define U_ETH_LOCAL_SGE_RING_SIZE (12)
+#define U_ETH_SGL_SIZE (8)
+
+
+#define U_ETH_BDS_PER_PAGE_MASK \
+	((PAGE_SIZE/(STRUCT_SIZE(eth_rx_bd)/8))-1)
+#define U_ETH_CQE_PER_PAGE_MASK \
+	((PAGE_SIZE/(STRUCT_SIZE(eth_rx_cqe)/8))-1)
+#define U_ETH_SGES_PER_PAGE_MASK \
+	((PAGE_SIZE/(STRUCT_SIZE(eth_rx_sge)/8))-1)
+
+#define U_ETH_SGES_PER_PAGE_INVERSE_MASK \
+	(0xFFFF - ((PAGE_SIZE/((STRUCT_SIZE(eth_rx_sge))/8))-1))
+
+
+#define TU_ETH_CQES_PER_PAGE \
+	(PAGE_SIZE/(STRUCT_SIZE(eth_rx_cqe_next_page)/8))
+#define U_ETH_BDS_PER_PAGE (PAGE_SIZE/(STRUCT_SIZE(eth_rx_bd)/8))
+#define U_ETH_SGES_PER_PAGE (PAGE_SIZE/(STRUCT_SIZE(eth_rx_sge)/8))
+
+#define U_ETH_UNDEFINED_Q 0xFF
 
 /* values of command IDs in the ramrod message */
-#define RAMROD_CMD_ID_ETH_PORT_SETUP			(80)
-#define RAMROD_CMD_ID_ETH_CLIENT_SETUP			(85)
-#define RAMROD_CMD_ID_ETH_STAT_QUERY			(90)
-#define RAMROD_CMD_ID_ETH_UPDATE			(100)
-#define RAMROD_CMD_ID_ETH_HALT				(105)
-#define RAMROD_CMD_ID_ETH_SET_MAC			(110)
-#define RAMROD_CMD_ID_ETH_CFC_DEL			(115)
-#define RAMROD_CMD_ID_ETH_PORT_DEL			(120)
-#define RAMROD_CMD_ID_ETH_FORWARD_SETUP 		(125)
+#define RAMROD_CMD_ID_ETH_PORT_SETUP (80)
+#define RAMROD_CMD_ID_ETH_CLIENT_SETUP (85)
+#define RAMROD_CMD_ID_ETH_STAT_QUERY (90)
+#define RAMROD_CMD_ID_ETH_UPDATE (100)
+#define RAMROD_CMD_ID_ETH_HALT (105)
+#define RAMROD_CMD_ID_ETH_SET_MAC (110)
+#define RAMROD_CMD_ID_ETH_CFC_DEL (115)
+#define RAMROD_CMD_ID_ETH_PORT_DEL (120)
+#define RAMROD_CMD_ID_ETH_FORWARD_SETUP (125)
 
 
 /* command values for set mac command */
-#define T_ETH_MAC_COMMAND_SET				0
-#define T_ETH_MAC_COMMAND_INVALIDATE			1
+#define T_ETH_MAC_COMMAND_SET 0
+#define T_ETH_MAC_COMMAND_INVALIDATE 1
+
+#define T_ETH_INDIRECTION_TABLE_SIZE 128
 
-#define T_ETH_INDIRECTION_TABLE_SIZE			128
+/*The CRC32 seed, that is used for the hash(reduction) multicast address */
+#define T_ETH_CRC32_HASH_SEED 0x00000000
 
 /* Maximal L2 clients supported */
-#define ETH_MAX_RX_CLIENTS				(18)
+#define ETH_MAX_RX_CLIENTS_E1 19
+#define ETH_MAX_RX_CLIENTS_E1H 25
+
+/* Maximal aggregation queues supported */
+#define ETH_MAX_AGGREGATION_QUEUES_E1 (32)
+#define ETH_MAX_AGGREGATION_QUEUES_E1H (64)
+
 
 /**
 * This file defines HSI constatnts common to all microcode flows
 */
 
 /* Connection types */
-#define ETH_CONNECTION_TYPE			0
+#define ETH_CONNECTION_TYPE 0
+#define TOE_CONNECTION_TYPE 1
+#define RDMA_CONNECTION_TYPE 2
+#define ISCSI_CONNECTION_TYPE 3
+#define FCOE_CONNECTION_TYPE 4
+#define RESERVED_CONNECTION_TYPE_0 5
+#define RESERVED_CONNECTION_TYPE_1 6
+#define RESERVED_CONNECTION_TYPE_2 7
+
 
-#define PROTOCOL_STATE_BIT_OFFSET		6
+#define PROTOCOL_STATE_BIT_OFFSET 6
 
-#define ETH_STATE	(ETH_CONNECTION_TYPE << PROTOCOL_STATE_BIT_OFFSET)
+#define ETH_STATE (ETH_CONNECTION_TYPE << PROTOCOL_STATE_BIT_OFFSET)
+#define TOE_STATE (TOE_CONNECTION_TYPE << PROTOCOL_STATE_BIT_OFFSET)
+#define RDMA_STATE (RDMA_CONNECTION_TYPE << PROTOCOL_STATE_BIT_OFFSET)
+#define ISCSI_STATE \
+	(ISCSI_CONNECTION_TYPE << PROTOCOL_STATE_BIT_OFFSET)
+#define FCOE_STATE (FCOE_CONNECTION_TYPE << PROTOCOL_STATE_BIT_OFFSET)
 
 /* microcode fixed page page size 4K (chains and ring segments) */
-#define MC_PAGE_SIZE						(4096)
+#define MC_PAGE_SIZE (4096)
 
-/* Host coalescing constants */
 
-/* IGU constants */
-#define IGU_PORT_BASE				0x0400
-
-#define IGU_ADDR_MSIX				0x0000
-#define IGU_ADDR_INT_ACK			0x0200
-#define IGU_ADDR_PROD_UPD			0x0201
-#define IGU_ADDR_ATTN_BITS_UPD			0x0202
-#define IGU_ADDR_ATTN_BITS_SET			0x0203
-#define IGU_ADDR_ATTN_BITS_CLR			0x0204
-#define IGU_ADDR_COALESCE_NOW			0x0205
-#define IGU_ADDR_SIMD_MASK			0x0206
-#define IGU_ADDR_SIMD_NOMASK			0x0207
-#define IGU_ADDR_MSI_CTL			0x0210
-#define IGU_ADDR_MSI_ADDR_LO			0x0211
-#define IGU_ADDR_MSI_ADDR_HI			0x0212
-#define IGU_ADDR_MSI_DATA			0x0213
-
-#define IGU_INT_ENABLE				0
-#define IGU_INT_DISABLE 			1
-#define IGU_INT_NOP				2
-#define IGU_INT_NOP2				3
+/* Host coalescing constants */
 
 /* index numbers */
-#define HC_USTORM_DEF_SB_NUM_INDICES		4
-#define HC_CSTORM_DEF_SB_NUM_INDICES		8
-#define HC_XSTORM_DEF_SB_NUM_INDICES		4
-#define HC_TSTORM_DEF_SB_NUM_INDICES		4
-#define HC_USTORM_SB_NUM_INDICES		4
-#define HC_CSTORM_SB_NUM_INDICES		4
+#define HC_USTORM_DEF_SB_NUM_INDICES 4
+#define HC_CSTORM_DEF_SB_NUM_INDICES 8
+#define HC_XSTORM_DEF_SB_NUM_INDICES 4
+#define HC_TSTORM_DEF_SB_NUM_INDICES 4
+#define HC_USTORM_SB_NUM_INDICES 4
+#define HC_CSTORM_SB_NUM_INDICES 4
 
 /* index values - which counterto update */
 
-#define HC_INDEX_U_ETH_RX_CQ_CONS		1
+#define HC_INDEX_U_TOE_RX_CQ_CONS 0
+#define HC_INDEX_U_ETH_RX_CQ_CONS 1
+#define HC_INDEX_U_ETH_RX_BD_CONS 2
+#define HC_INDEX_U_FCOE_EQ_CONS 3
+
+#define HC_INDEX_C_TOE_TX_CQ_CONS 0
+#define HC_INDEX_C_ETH_TX_CQ_CONS 1
+#define HC_INDEX_C_ISCSI_EQ_CONS 2
+
+#define HC_INDEX_DEF_X_SPQ_CONS 0
 
-#define HC_INDEX_C_ETH_TX_CQ_CONS		1
+#define HC_INDEX_DEF_C_RDMA_EQ_CONS 0
+#define HC_INDEX_DEF_C_RDMA_NAL_PROD 1
+#define HC_INDEX_DEF_C_ETH_FW_TX_CQ_CONS 2
+#define HC_INDEX_DEF_C_ETH_SLOW_PATH 3
+#define HC_INDEX_DEF_C_ETH_RDMA_CQ_CONS 4
+#define HC_INDEX_DEF_C_ETH_ISCSI_CQ_CONS 5
 
-#define HC_INDEX_DEF_X_SPQ_CONS 		0
+#define HC_INDEX_DEF_U_ETH_RDMA_RX_CQ_CONS 0
+#define HC_INDEX_DEF_U_ETH_ISCSI_RX_CQ_CONS 1
+#define HC_INDEX_DEF_U_ETH_RDMA_RX_BD_CONS 2
+#define HC_INDEX_DEF_U_ETH_ISCSI_RX_BD_CONS 3
 
-#define HC_INDEX_DEF_C_ETH_FW_TX_CQ_CONS	2
-#define HC_INDEX_DEF_C_ETH_SLOW_PATH		3
 
 /* used by the driver to get the SB offset */
-#define USTORM_ID			0
-#define CSTORM_ID			1
-#define XSTORM_ID			2
-#define TSTORM_ID			3
-#define ATTENTION_ID			4
+#define USTORM_ID 0
+#define CSTORM_ID 1
+#define XSTORM_ID 2
+#define TSTORM_ID 3
+#define ATTENTION_ID 4
 
 /* max number of slow path commands per port */
-#define MAX_RAMRODS_PER_PORT		(8)
+#define MAX_RAMRODS_PER_PORT (8)
 
 /* values for RX ETH CQE type field */
-#define RX_ETH_CQE_TYPE_ETH_FASTPATH	(0)
-#define RX_ETH_CQE_TYPE_ETH_RAMROD		(1)
-
-/* MAC address list size */
-#define T_MAC_ADDRESS_LIST_SIZE 	(96)
-
+#define RX_ETH_CQE_TYPE_ETH_FASTPATH (0)
+#define RX_ETH_CQE_TYPE_ETH_RAMROD (1)
+
+
+/**** DEFINES FOR TIMERS/CLOCKS RESOLUTIONS ****/
+#define EMULATION_FREQUENCY_FACTOR (1600)
+#define FPGA_FREQUENCY_FACTOR (100)
+
+#define TIMERS_TICK_SIZE_CHIP (1e-3)
+#define TIMERS_TICK_SIZE_EMUL \
+ ((TIMERS_TICK_SIZE_CHIP)/((EMULATION_FREQUENCY_FACTOR)))
+#define TIMERS_TICK_SIZE_FPGA \
+ ((TIMERS_TICK_SIZE_CHIP)/((FPGA_FREQUENCY_FACTOR)))
+
+#define TSEMI_CLK1_RESUL_CHIP (1e-3)
+#define TSEMI_CLK1_RESUL_EMUL \
+ ((TSEMI_CLK1_RESUL_CHIP)/(EMULATION_FREQUENCY_FACTOR))
+#define TSEMI_CLK1_RESUL_FPGA \
+ ((TSEMI_CLK1_RESUL_CHIP)/(FPGA_FREQUENCY_FACTOR))
+
+#define USEMI_CLK1_RESUL_CHIP \
+ (TIMERS_TICK_SIZE_CHIP)
+#define USEMI_CLK1_RESUL_EMUL \
+ (TIMERS_TICK_SIZE_EMUL)
+#define USEMI_CLK1_RESUL_FPGA \
+ (TIMERS_TICK_SIZE_FPGA)
+
+#define XSEMI_CLK1_RESUL_CHIP (1e-3)
+#define XSEMI_CLK1_RESUL_EMUL \
+ ((XSEMI_CLK1_RESUL_CHIP)/(EMULATION_FREQUENCY_FACTOR))
+#define XSEMI_CLK1_RESUL_FPGA \
+ ((XSEMI_CLK1_RESUL_CHIP)/(FPGA_FREQUENCY_FACTOR))
+
+#define XSEMI_CLK2_RESUL_CHIP (1e-6)
+#define XSEMI_CLK2_RESUL_EMUL \
+ ((XSEMI_CLK2_RESUL_CHIP)/(EMULATION_FREQUENCY_FACTOR))
+#define XSEMI_CLK2_RESUL_FPGA \
+ ((XSEMI_CLK2_RESUL_CHIP)/(FPGA_FREQUENCY_FACTOR))
+
+#define SDM_TIMER_TICK_RESUL_CHIP (4*(1e-6))
+#define SDM_TIMER_TICK_RESUL_EMUL \
+ ((SDM_TIMER_TICK_RESUL_CHIP)/(EMULATION_FREQUENCY_FACTOR))
+#define SDM_TIMER_TICK_RESUL_FPGA \
+ ((SDM_TIMER_TICK_RESUL_CHIP)/(FPGA_FREQUENCY_FACTOR))
+
+
+/**** END DEFINES FOR TIMERS/CLOCKS RESOLUTIONS ****/
 #define XSTORM_IP_ID_ROLL_HALF 0x8000
 #define XSTORM_IP_ID_ROLL_ALL 0
 
-#define FW_LOG_LIST_SIZE	(50)
+#define FW_LOG_LIST_SIZE (50)
+
+#define NUM_OF_PROTOCOLS 4
+#define MAX_COS_NUMBER 16
+#define MAX_T_STAT_COUNTER_ID 18
+#define MAX_X_STAT_COUNTER_ID 18
 
-#define NUM_OF_PROTOCOLS		4
-#define MAX_COS_NUMBER			16
-#define MAX_T_STAT_COUNTER_ID	18
+#define UNKNOWN_ADDRESS 0
+#define UNICAST_ADDRESS 1
+#define MULTICAST_ADDRESS 2
+#define BROADCAST_ADDRESS 3
 
-#define T_FAIR							1
-#define FAIR_MEM						2
-#define RS_PERIODIC_TIMEOUT_IN_SDM_TICS 25
+#define SINGLE_FUNCTION 0
+#define MULTI_FUNCTION 1
 
-#define UNKNOWN_ADDRESS 	0
-#define UNICAST_ADDRESS 	1
-#define MULTICAST_ADDRESS	2
-#define BROADCAST_ADDRESS	3
+#define IP_V4 0
+#define IP_V6 1
 
diff --git a/drivers/net/bnx2x_hsi.h b/drivers/net/bnx2x_hsi.h
index 96208ac..e515d68 100644
--- a/drivers/net/bnx2x_hsi.h
+++ b/drivers/net/bnx2x_hsi.h
@@ -132,6 +132,12 @@ struct shared_hw_cfg {					 /* NVRAM Offset */
 #define SHARED_HW_CFG_BOARD_TYPE_BCM957710T1003G    0x00000008
 #define SHARED_HW_CFG_BOARD_TYPE_BCM957710A1022G    0x00000009
 #define SHARED_HW_CFG_BOARD_TYPE_BCM957710A1021G    0x0000000a
+#define SHARED_HW_CFG_BOARD_TYPE_BCM957710A1023G    0x0000000b
+#define SHARED_HW_CFG_BOARD_TYPE_BCM957710A1033G    0x0000000c
+#define SHARED_HW_CFG_BOARD_TYPE_BCM957711T1101     0x0000000d
+#define SHARED_HW_CFG_BOARD_TYPE_BCM957711ET1201    0x0000000e
+#define SHARED_HW_CFG_BOARD_TYPE_BCM957711A1133G    0x0000000f
+#define SHARED_HW_CFG_BOARD_TYPE_BCM957711EA1233G   0x00000010
 
 #define SHARED_HW_CFG_BOARD_VER_MASK		    0xffff0000
 #define SHARED_HW_CFG_BOARD_VER_SHIFT		    16
@@ -313,6 +319,7 @@ struct shared_feat_cfg {				 /* NVRAM Offset */
 
 	u32 config;						/* 0x450 */
 #define SHARED_FEATURE_BMC_ECHO_MODE_EN 	    0x00000001
+#define SHARED_FEATURE_MF_MODE_DISABLED 	    0x00000100
 
 };
 
@@ -502,20 +509,20 @@ struct port_feat_cfg {			    /* port 0: 0x454  port 1: 0x4c8 */
 };
 
 
-/*****************************************************************************
- * Device Information							     *
- *****************************************************************************/
-struct dev_info {						     /* size */
+/****************************************************************************
+ * Device Information							    *
+ ****************************************************************************/
+struct dev_info {						    /* size */
 
-	u32    bc_rev; /* 8 bits each: major, minor, build */	        /* 4 */
+	u32    bc_rev; /* 8 bits each: major, minor, build */	       /* 4 */
 
-	struct shared_hw_cfg	 shared_hw_config;		       /* 40 */
+	struct shared_hw_cfg	 shared_hw_config;		      /* 40 */
 
-	struct port_hw_cfg	 port_hw_config[PORT_MAX];      /* 400*2=800 */
+	struct port_hw_cfg	 port_hw_config[PORT_MAX];     /* 400*2=800 */
 
-	struct shared_feat_cfg	 shared_feature_config; 	        /* 4 */
+	struct shared_feat_cfg	 shared_feature_config; 	       /* 4 */
 
-	struct port_feat_cfg	 port_feature_config[PORT_MAX]; /* 116*2=232 */
+	struct port_feat_cfg	 port_feature_config[PORT_MAX];/* 116*2=232 */
 
 };
 
@@ -632,7 +639,9 @@ struct drv_port_mb {
 #define LINK_STATUS_LINK_PARTNER_15GXFD_CAPABLE 	0x08000000
 #define LINK_STATUS_LINK_PARTNER_16GXFD_CAPABLE 	0x10000000
 
-	u32 reserved[3];
+	u32 port_stx;
+
+	u32 reserved[2];
 
 };
 
@@ -655,6 +664,11 @@ struct drv_func_mb {
 #define DRV_MSG_CODE_GET_MANUF_KEY			0x82000000
 #define DRV_MSG_CODE_LOAD_L2B_PRAM			0x90000000
 
+#define BIOS_MSG_CODE_LIC_CHALLENGE			0xff010000
+#define BIOS_MSG_CODE_LIC_RESPONSE			0xff020000
+#define BIOS_MSG_CODE_VIRT_MAC_PRIM			0xff030000
+#define BIOS_MSG_CODE_VIRT_MAC_ISCSI			0xff040000
+
 #define DRV_MSG_SEQ_NUMBER_MASK 			0x0000ffff
 
 	u32 drv_mb_param;
@@ -684,6 +698,11 @@ struct drv_func_mb {
 #define FW_MSG_CODE_L2B_PRAM_X_LOAD_FAILURE		0x90230000
 #define FW_MSG_CODE_L2B_PRAM_U_LOAD_FAILURE		0x90240000
 
+#define FW_MSG_CODE_LIC_CHALLENGE			0xff010000
+#define FW_MSG_CODE_LIC_RESPONSE			0xff020000
+#define FW_MSG_CODE_VIRT_MAC_PRIM			0xff030000
+#define FW_MSG_CODE_VIRT_MAC_ISCSI			0xff040000
+
 #define FW_MSG_SEQ_NUMBER_MASK				0x0000ffff
 
 	u32 fw_mb_param;
@@ -709,7 +728,13 @@ struct drv_func_mb {
 	u32 iscsi_boot_signature;
 	u32 iscsi_boot_block_offset;
 
-	u32 reserved[3];
+	u32 drv_status;
+#define DRV_STATUS_PMF					0x00000001
+
+	u32 virt_mac_upper;
+#define VIRT_MAC_SIGN_MASK				0xffff0000
+#define VIRT_MAC_SIGNATURE				0x564d0000
+	u32 virt_mac_lower;
 
 };
 
@@ -726,6 +751,92 @@ struct mgmtfw_state {
 
 
 /****************************************************************************
+ * Multi-Function configuration 					    *
+ ****************************************************************************/
+struct shared_mf_cfg {
+
+	u32 clp_mb;
+#define SHARED_MF_CLP_SET_DEFAULT		    0x00000000
+	/* set by CLP */
+#define SHARED_MF_CLP_EXIT			    0x00000001
+	/* set by MCP */
+#define SHARED_MF_CLP_EXIT_DONE 		    0x00010000
+
+};
+
+struct port_mf_cfg {
+
+	u32 dynamic_cfg;	/* device control channel */
+#define PORT_MF_CFG_OUTER_VLAN_TAG_MASK 	    0x0000ffff
+#define PORT_MF_CFG_OUTER_VLAN_TAG_SHIFT	    0
+#define PORT_MF_CFG_DYNAMIC_CFG_ENABLED 	    0x00010000
+#define PORT_MF_CFG_DYNAMIC_CFG_DEFAULT 	    0x00000000
+
+	u32 reserved[3];
+
+};
+
+struct func_mf_cfg {
+
+	u32 config;
+	/* E/R/I/D */
+	/* function 0 of each port cannot be hidden */
+#define FUNC_MF_CFG_FUNC_HIDE			    0x00000001
+
+#define FUNC_MF_CFG_PROTOCOL_MASK		    0x00000007
+#define FUNC_MF_CFG_PROTOCOL_ETHERNET		    0x00000002
+#define FUNC_MF_CFG_PROTOCOL_ETHERNET_WITH_RDMA     0x00000004
+#define FUNC_MF_CFG_PROTOCOL_ISCSI		    0x00000006
+#define FUNC_MF_CFG_PROTOCOL_DEFAULT\
+	FUNC_MF_CFG_PROTOCOL_ETHERNET_WITH_RDMA
+
+#define FUNC_MF_CFG_FUNC_DISABLED		    0x00000008
+
+	/* PRI */
+	/* 0 - low priority, 3 - high priority */
+#define FUNC_MF_CFG_TRANSMIT_PRIORITY_MASK	    0x00000300
+#define FUNC_MF_CFG_TRANSMIT_PRIORITY_SHIFT	    8
+#define FUNC_MF_CFG_TRANSMIT_PRIORITY_DEFAULT	    0x00000000
+
+	/* MINBW, MAXBW */
+	/* value range - 0..100, increments in 100Mbps */
+#define FUNC_MF_CFG_MIN_BW_MASK 		    0x00ff0000
+#define FUNC_MF_CFG_MIN_BW_SHIFT		    16
+#define FUNC_MF_CFG_MIN_BW_DEFAULT		    0x00000000
+#define FUNC_MF_CFG_MAX_BW_MASK 		    0xff000000
+#define FUNC_MF_CFG_MAX_BW_SHIFT		    24
+#define FUNC_MF_CFG_MAX_BW_DEFAULT		    0x64000000
+
+	u32 mac_upper;		/* MAC */
+#define FUNC_MF_CFG_UPPERMAC_MASK		    0x0000ffff
+#define FUNC_MF_CFG_UPPERMAC_SHIFT		    0
+#define FUNC_MF_CFG_UPPERMAC_DEFAULT		    FUNC_MF_CFG_UPPERMAC_MASK
+	u32 mac_lower;
+#define FUNC_MF_CFG_LOWERMAC_DEFAULT		    0xffffffff
+
+	u32 e1hov_tag;	/* VNI */
+#define FUNC_MF_CFG_E1HOV_TAG_MASK		    0x0000ffff
+#define FUNC_MF_CFG_E1HOV_TAG_SHIFT		    0
+#define FUNC_MF_CFG_E1HOV_TAG_DEFAULT		    FUNC_MF_CFG_E1HOV_TAG_MASK
+
+	u32 reserved[2];
+
+};
+
+struct mf_cfg {
+
+	struct shared_mf_cfg	shared_mf_config;
+	struct port_mf_cfg	port_mf_config[PORT_MAX];
+#if defined(b710)
+	struct func_mf_cfg	func_mf_config[E1_FUNC_MAX];
+#else
+	struct func_mf_cfg	func_mf_config[E1H_FUNC_MAX];
+#endif
+
+};
+
+
+/****************************************************************************
  * Shared Memory Region 						    *
  ****************************************************************************/
 struct shmem_region {			       /*   SharedMem Offset (size) */
@@ -760,18 +871,18 @@ struct shmem_region {			       /*   SharedMem Offset (size) */
 	struct mgmtfw_state	mgmtfw_state;	       /* 0x4ac     (0x1b8) */
 
 	struct drv_port_mb	port_mb[PORT_MAX];     /* 0x664 (16*2=0x20) */
-#if defined(b710)
-	struct drv_func_mb	func_mb[E1_FUNC_MAX];  /* 0x684 (44*2=0x58) */
-#else
 	struct drv_func_mb	func_mb[E1H_FUNC_MAX];
-#endif
+
+	struct mf_cfg		mf_cfg;
 
 };						       /* 0x6dc */
 
 
+
+
 #define BCM_5710_FW_MAJOR_VERSION			4
-#define BCM_5710_FW_MINOR_VERSION			0
-#define BCM_5710_FW_REVISION_VERSION			14
+#define BCM_5710_FW_MINOR_VERSION			5
+#define BCM_5710_FW_REVISION_VERSION			1
 #define BCM_5710_FW_COMPILE_FLAGS			1
 
 
@@ -810,7 +921,7 @@ struct doorbell_hdr {
 };
 
 /*
- * doorbell message send to the chip
+ * doorbell message sent to the chip
  */
 struct doorbell {
 #if defined(__BIG_ENDIAN)
@@ -866,8 +977,10 @@ struct parsing_flags {
 	u16 flags;
 #define PARSING_FLAGS_ETHERNET_ADDRESS_TYPE (0x1<<0)
 #define PARSING_FLAGS_ETHERNET_ADDRESS_TYPE_SHIFT 0
-#define PARSING_FLAGS_NUMBER_OF_NESTED_VLANS (0x3<<1)
-#define PARSING_FLAGS_NUMBER_OF_NESTED_VLANS_SHIFT 1
+#define PARSING_FLAGS_VLAN (0x1<<1)
+#define PARSING_FLAGS_VLAN_SHIFT 1
+#define PARSING_FLAGS_EXTRA_VLAN (0x1<<2)
+#define PARSING_FLAGS_EXTRA_VLAN_SHIFT 2
 #define PARSING_FLAGS_OVER_ETHERNET_PROTOCOL (0x3<<3)
 #define PARSING_FLAGS_OVER_ETHERNET_PROTOCOL_SHIFT 3
 #define PARSING_FLAGS_IP_OPTIONS (0x1<<5)
@@ -891,6 +1004,12 @@ struct parsing_flags {
 };
 
 
+struct regpair {
+	u32 lo;
+	u32 hi;
+};
+
+
 /*
  * dmae command structure
  */
@@ -971,72 +1090,107 @@ struct double_regpair {
 
 
 /*
- * The eth Rx Buffer Descriptor
+ * The eth storm context of Ustorm (configuration part)
  */
-struct eth_rx_bd {
-	u32 addr_lo;
-	u32 addr_hi;
-};
-
-/*
- * The eth storm context of Ustorm
- */
-struct ustorm_eth_st_context {
+struct ustorm_eth_st_context_config {
 #if defined(__BIG_ENDIAN)
-	u8 sb_index_number;
+	u8 flags;
+#define USTORM_ETH_ST_CONTEXT_CONFIG_ENABLE_MC_ALIGNMENT (0x1<<0)
+#define USTORM_ETH_ST_CONTEXT_CONFIG_ENABLE_MC_ALIGNMENT_SHIFT 0
+#define USTORM_ETH_ST_CONTEXT_CONFIG_ENABLE_DYNAMIC_HC (0x1<<1)
+#define USTORM_ETH_ST_CONTEXT_CONFIG_ENABLE_DYNAMIC_HC_SHIFT 1
+#define USTORM_ETH_ST_CONTEXT_CONFIG_ENABLE_TPA (0x1<<2)
+#define USTORM_ETH_ST_CONTEXT_CONFIG_ENABLE_TPA_SHIFT 2
+#define USTORM_ETH_ST_CONTEXT_CONFIG_ENABLE_SGE_RING (0x1<<3)
+#define USTORM_ETH_ST_CONTEXT_CONFIG_ENABLE_SGE_RING_SHIFT 3
+#define __USTORM_ETH_ST_CONTEXT_CONFIG_RESERVED0 (0xF<<4)
+#define __USTORM_ETH_ST_CONTEXT_CONFIG_RESERVED0_SHIFT 4
 	u8 status_block_id;
-	u8 __local_rx_bd_cons;
-	u8 __local_rx_bd_prod;
+	u8 clientId;
+	u8 sb_index_numbers;
+#define USTORM_ETH_ST_CONTEXT_CONFIG_CQE_SB_INDEX_NUMBER (0xF<<0)
+#define USTORM_ETH_ST_CONTEXT_CONFIG_CQE_SB_INDEX_NUMBER_SHIFT 0
+#define USTORM_ETH_ST_CONTEXT_CONFIG_BD_SB_INDEX_NUMBER (0xF<<4)
+#define USTORM_ETH_ST_CONTEXT_CONFIG_BD_SB_INDEX_NUMBER_SHIFT 4
 #elif defined(__LITTLE_ENDIAN)
-	u8 __local_rx_bd_prod;
-	u8 __local_rx_bd_cons;
+	u8 sb_index_numbers;
+#define USTORM_ETH_ST_CONTEXT_CONFIG_CQE_SB_INDEX_NUMBER (0xF<<0)
+#define USTORM_ETH_ST_CONTEXT_CONFIG_CQE_SB_INDEX_NUMBER_SHIFT 0
+#define USTORM_ETH_ST_CONTEXT_CONFIG_BD_SB_INDEX_NUMBER (0xF<<4)
+#define USTORM_ETH_ST_CONTEXT_CONFIG_BD_SB_INDEX_NUMBER_SHIFT 4
+	u8 clientId;
 	u8 status_block_id;
-	u8 sb_index_number;
+	u8 flags;
+#define USTORM_ETH_ST_CONTEXT_CONFIG_ENABLE_MC_ALIGNMENT (0x1<<0)
+#define USTORM_ETH_ST_CONTEXT_CONFIG_ENABLE_MC_ALIGNMENT_SHIFT 0
+#define USTORM_ETH_ST_CONTEXT_CONFIG_ENABLE_DYNAMIC_HC (0x1<<1)
+#define USTORM_ETH_ST_CONTEXT_CONFIG_ENABLE_DYNAMIC_HC_SHIFT 1
+#define USTORM_ETH_ST_CONTEXT_CONFIG_ENABLE_TPA (0x1<<2)
+#define USTORM_ETH_ST_CONTEXT_CONFIG_ENABLE_TPA_SHIFT 2
+#define USTORM_ETH_ST_CONTEXT_CONFIG_ENABLE_SGE_RING (0x1<<3)
+#define USTORM_ETH_ST_CONTEXT_CONFIG_ENABLE_SGE_RING_SHIFT 3
+#define __USTORM_ETH_ST_CONTEXT_CONFIG_RESERVED0 (0xF<<4)
+#define __USTORM_ETH_ST_CONTEXT_CONFIG_RESERVED0_SHIFT 4
 #endif
 #if defined(__BIG_ENDIAN)
-	u16 rcq_cons;
-	u16 rx_bd_cons;
+	u16 bd_buff_size;
+	u16 mc_alignment_size;
 #elif defined(__LITTLE_ENDIAN)
-	u16 rx_bd_cons;
-	u16 rcq_cons;
+	u16 mc_alignment_size;
+	u16 bd_buff_size;
 #endif
-	u32 rx_bd_page_base_lo;
-	u32 rx_bd_page_base_hi;
-	u32 rcq_base_address_lo;
-	u32 rcq_base_address_hi;
 #if defined(__BIG_ENDIAN)
-	u16 __num_of_returned_cqes;
-	u8 num_rss;
-	u8 flags;
-#define USTORM_ETH_ST_CONTEXT_ENABLE_MC_ALIGNMENT (0x1<<0)
-#define USTORM_ETH_ST_CONTEXT_ENABLE_MC_ALIGNMENT_SHIFT 0
-#define USTORM_ETH_ST_CONTEXT_ENABLE_DYNAMIC_HC (0x1<<1)
-#define USTORM_ETH_ST_CONTEXT_ENABLE_DYNAMIC_HC_SHIFT 1
-#define USTORM_ETH_ST_CONTEXT_ENABLE_TPA (0x1<<2)
-#define USTORM_ETH_ST_CONTEXT_ENABLE_TPA_SHIFT 2
-#define __USTORM_ETH_ST_CONTEXT_RESERVED0 (0x1F<<3)
-#define __USTORM_ETH_ST_CONTEXT_RESERVED0_SHIFT 3
+	u8 __local_sge_prod;
+	u8 __local_bd_prod;
+	u16 sge_buff_size;
 #elif defined(__LITTLE_ENDIAN)
-	u8 flags;
-#define USTORM_ETH_ST_CONTEXT_ENABLE_MC_ALIGNMENT (0x1<<0)
-#define USTORM_ETH_ST_CONTEXT_ENABLE_MC_ALIGNMENT_SHIFT 0
-#define USTORM_ETH_ST_CONTEXT_ENABLE_DYNAMIC_HC (0x1<<1)
-#define USTORM_ETH_ST_CONTEXT_ENABLE_DYNAMIC_HC_SHIFT 1
-#define USTORM_ETH_ST_CONTEXT_ENABLE_TPA (0x1<<2)
-#define USTORM_ETH_ST_CONTEXT_ENABLE_TPA_SHIFT 2
-#define __USTORM_ETH_ST_CONTEXT_RESERVED0 (0x1F<<3)
-#define __USTORM_ETH_ST_CONTEXT_RESERVED0_SHIFT 3
-	u8 num_rss;
-	u16 __num_of_returned_cqes;
+	u16 sge_buff_size;
+	u8 __local_bd_prod;
+	u8 __local_sge_prod;
 #endif
 #if defined(__BIG_ENDIAN)
-	u16 mc_alignment_size;
-	u16 agg_threshold;
+	u16 __bd_cons;
+	u16 __sge_cons;
 #elif defined(__LITTLE_ENDIAN)
-	u16 agg_threshold;
-	u16 mc_alignment_size;
+	u16 __sge_cons;
+	u16 __bd_cons;
 #endif
+	u32 bd_page_base_lo;
+	u32 bd_page_base_hi;
+	u32 sge_page_base_lo;
+	u32 sge_page_base_hi;
+};
+
+/*
+ * The eth Rx Buffer Descriptor
+ */
+struct eth_rx_bd {
+	u32 addr_lo;
+	u32 addr_hi;
+};
+
+/*
+ * The eth Rx SGE Descriptor
+ */
+struct eth_rx_sge {
+	u32 addr_lo;
+	u32 addr_hi;
+};
+
+/*
+ * Local BDs and SGEs rings (in ETH)
+ */
+struct eth_local_rx_rings {
 	struct eth_rx_bd __local_bd_ring[16];
+	struct eth_rx_sge __local_sge_ring[12];
+};
+
+/*
+ * The eth storm context of Ustorm
+ */
+struct ustorm_eth_st_context {
+	struct ustorm_eth_st_context_config common;
+	struct eth_local_rx_rings __rings;
 };
 
 /*
@@ -1107,9 +1261,9 @@ struct xstorm_eth_extra_ag_context_section {
 #if defined(__BIG_ENDIAN)
 	u16 __reserved3;
 	u8 __reserved2;
-	u8 __agg_misc7;
+	u8 __da_only_cnt;
 #elif defined(__LITTLE_ENDIAN)
-	u8 __agg_misc7;
+	u8 __da_only_cnt;
 	u8 __reserved2;
 	u16 __reserved3;
 #endif
@@ -1387,7 +1541,13 @@ struct timers_block_context {
 	u32 __reserved_0;
 	u32 __reserved_1;
 	u32 __reserved_2;
-	u32 __reserved_flags;
+	u32 flags;
+#define __TIMERS_BLOCK_CONTEXT_NUM_OF_ACTIVE_TIMERS (0x3<<0)
+#define __TIMERS_BLOCK_CONTEXT_NUM_OF_ACTIVE_TIMERS_SHIFT 0
+#define TIMERS_BLOCK_CONTEXT_CONN_VALID_FLG (0x1<<2)
+#define TIMERS_BLOCK_CONTEXT_CONN_VALID_FLG_SHIFT 2
+#define __TIMERS_BLOCK_CONTEXT_RESERVED0 (0x1FFFFFFF<<3)
+#define __TIMERS_BLOCK_CONTEXT_RESERVED0_SHIFT 3
 };
 
 /*
@@ -1497,11 +1657,19 @@ struct xstorm_eth_st_context {
 	u32 tx_bd_page_base_hi;
 #if defined(__BIG_ENDIAN)
 	u16 tx_bd_cons;
-	u8 __reserved0;
+	u8 statistics_data;
+#define XSTORM_ETH_ST_CONTEXT_STATISTICS_COUNTER_ID (0x7F<<0)
+#define XSTORM_ETH_ST_CONTEXT_STATISTICS_COUNTER_ID_SHIFT 0
+#define XSTORM_ETH_ST_CONTEXT_STATISTICS_ENABLE (0x1<<7)
+#define XSTORM_ETH_ST_CONTEXT_STATISTICS_ENABLE_SHIFT 7
 	u8 __local_tx_bd_prod;
 #elif defined(__LITTLE_ENDIAN)
 	u8 __local_tx_bd_prod;
-	u8 __reserved0;
+	u8 statistics_data;
+#define XSTORM_ETH_ST_CONTEXT_STATISTICS_COUNTER_ID (0x7F<<0)
+#define XSTORM_ETH_ST_CONTEXT_STATISTICS_COUNTER_ID_SHIFT 0
+#define XSTORM_ETH_ST_CONTEXT_STATISTICS_ENABLE (0x1<<7)
+#define XSTORM_ETH_ST_CONTEXT_STATISTICS_ENABLE_SHIFT 7
 	u16 tx_bd_cons;
 #endif
 	u32 db_data_addr_lo;
@@ -1578,7 +1746,7 @@ struct eth_tx_doorbell {
 struct ustorm_def_status_block {
 	u16 index_values[HC_USTORM_DEF_SB_NUM_INDICES];
 	u16 status_block_index;
-	u8 reserved0;
+	u8 func;
 	u8 status_block_id;
 	u32 __flags;
 };
@@ -1589,7 +1757,7 @@ struct ustorm_def_status_block {
 struct cstorm_def_status_block {
 	u16 index_values[HC_CSTORM_DEF_SB_NUM_INDICES];
 	u16 status_block_index;
-	u8 reserved0;
+	u8 func;
 	u8 status_block_id;
 	u32 __flags;
 };
@@ -1600,7 +1768,7 @@ struct cstorm_def_status_block {
 struct xstorm_def_status_block {
 	u16 index_values[HC_XSTORM_DEF_SB_NUM_INDICES];
 	u16 status_block_index;
-	u8 reserved0;
+	u8 func;
 	u8 status_block_id;
 	u32 __flags;
 };
@@ -1611,7 +1779,7 @@ struct xstorm_def_status_block {
 struct tstorm_def_status_block {
 	u16 index_values[HC_TSTORM_DEF_SB_NUM_INDICES];
 	u16 status_block_index;
-	u8 reserved0;
+	u8 func;
 	u8 status_block_id;
 	u32 __flags;
 };
@@ -1634,7 +1802,7 @@ struct host_def_status_block {
 struct ustorm_status_block {
 	u16 index_values[HC_USTORM_SB_NUM_INDICES];
 	u16 status_block_index;
-	u8 reserved0;
+	u8 func;
 	u8 status_block_id;
 	u32 __flags;
 };
@@ -1645,7 +1813,7 @@ struct ustorm_status_block {
 struct cstorm_status_block {
 	u16 index_values[HC_CSTORM_SB_NUM_INDICES];
 	u16 status_block_index;
-	u8 reserved0;
+	u8 func;
 	u8 status_block_id;
 	u32 __flags;
 };
@@ -1683,20 +1851,21 @@ struct eth_dynamic_hc_config {
  * regular eth FP CQE parameters struct
  */
 struct eth_fast_path_rx_cqe {
-	u8 type;
-	u8 error_type_flags;
-#define ETH_FAST_PATH_RX_CQE_PHY_DECODE_ERR_FLG (0x1<<0)
-#define ETH_FAST_PATH_RX_CQE_PHY_DECODE_ERR_FLG_SHIFT 0
-#define ETH_FAST_PATH_RX_CQE_IP_BAD_XSUM_FLG (0x1<<1)
-#define ETH_FAST_PATH_RX_CQE_IP_BAD_XSUM_FLG_SHIFT 1
-#define ETH_FAST_PATH_RX_CQE_L4_BAD_XSUM_FLG (0x1<<2)
-#define ETH_FAST_PATH_RX_CQE_L4_BAD_XSUM_FLG_SHIFT 2
-#define ETH_FAST_PATH_RX_CQE_START_FLG (0x1<<3)
-#define ETH_FAST_PATH_RX_CQE_START_FLG_SHIFT 3
-#define ETH_FAST_PATH_RX_CQE_END_FLG (0x1<<4)
-#define ETH_FAST_PATH_RX_CQE_END_FLG_SHIFT 4
-#define ETH_FAST_PATH_RX_CQE_RESERVED0 (0x7<<5)
-#define ETH_FAST_PATH_RX_CQE_RESERVED0_SHIFT 5
+	u8 type_error_flags;
+#define ETH_FAST_PATH_RX_CQE_TYPE (0x1<<0)
+#define ETH_FAST_PATH_RX_CQE_TYPE_SHIFT 0
+#define ETH_FAST_PATH_RX_CQE_PHY_DECODE_ERR_FLG (0x1<<1)
+#define ETH_FAST_PATH_RX_CQE_PHY_DECODE_ERR_FLG_SHIFT 1
+#define ETH_FAST_PATH_RX_CQE_IP_BAD_XSUM_FLG (0x1<<2)
+#define ETH_FAST_PATH_RX_CQE_IP_BAD_XSUM_FLG_SHIFT 2
+#define ETH_FAST_PATH_RX_CQE_L4_BAD_XSUM_FLG (0x1<<3)
+#define ETH_FAST_PATH_RX_CQE_L4_BAD_XSUM_FLG_SHIFT 3
+#define ETH_FAST_PATH_RX_CQE_START_FLG (0x1<<4)
+#define ETH_FAST_PATH_RX_CQE_START_FLG_SHIFT 4
+#define ETH_FAST_PATH_RX_CQE_END_FLG (0x1<<5)
+#define ETH_FAST_PATH_RX_CQE_END_FLG_SHIFT 5
+#define ETH_FAST_PATH_RX_CQE_RESERVED0 (0x3<<6)
+#define ETH_FAST_PATH_RX_CQE_RESERVED0_SHIFT 6
 	u8 status_flags;
 #define ETH_FAST_PATH_RX_CQE_RSS_HASH_TYPE (0x7<<0)
 #define ETH_FAST_PATH_RX_CQE_RSS_HASH_TYPE_SHIFT 0
@@ -1711,11 +1880,13 @@ struct eth_fast_path_rx_cqe {
 #define ETH_FAST_PATH_RX_CQE_L4_XSUM_NO_VALIDATION_FLG (0x1<<7)
 #define ETH_FAST_PATH_RX_CQE_L4_XSUM_NO_VALIDATION_FLG_SHIFT 7
 	u8 placement_offset;
+	u8 queue_index;
 	u32 rss_hash_result;
 	u16 vlan_tag;
 	u16 pkt_len;
-	u16 queue_index;
+	u16 len_on_bd;
 	struct parsing_flags pars_flags;
+	u16 sgl[8];
 };
 
 
@@ -1729,6 +1900,23 @@ struct eth_halt_ramrod_data {
 
 
 /*
+ * The data for statistics query ramrod
+ */
+struct eth_query_ramrod_data {
+#if defined(__BIG_ENDIAN)
+	u8 reserved0;
+	u8 collect_port_1b;
+	u16 drv_counter;
+#elif defined(__LITTLE_ENDIAN)
+	u16 drv_counter;
+	u8 collect_port_1b;
+	u8 reserved0;
+#endif
+	u32 ctr_id_vector;
+};
+
+
+/*
  * Place holder for ramrods protocol specific data
  */
 struct ramrod_data {
@@ -1758,15 +1946,20 @@ struct eth_rx_bd_next_page {
  * Eth Rx Cqe structure- general structure for ramrods
  */
 struct common_ramrod_eth_rx_cqe {
-	u8 type;
+	u8 ramrod_type;
+#define COMMON_RAMROD_ETH_RX_CQE_TYPE (0x1<<0)
+#define COMMON_RAMROD_ETH_RX_CQE_TYPE_SHIFT 0
+#define COMMON_RAMROD_ETH_RX_CQE_RESERVED0 (0x7F<<1)
+#define COMMON_RAMROD_ETH_RX_CQE_RESERVED0_SHIFT 1
 	u8 conn_type_3b;
-	u16 reserved;
+	u16 reserved1;
 	u32 conn_and_cmd_data;
 #define COMMON_RAMROD_ETH_RX_CQE_CID (0xFFFFFF<<0)
 #define COMMON_RAMROD_ETH_RX_CQE_CID_SHIFT 0
 #define COMMON_RAMROD_ETH_RX_CQE_CMD_ID (0xFF<<24)
 #define COMMON_RAMROD_ETH_RX_CQE_CMD_ID_SHIFT 24
 	struct ramrod_data protocol_data;
+	u32 reserved2[4];
 };
 
 /*
@@ -1775,8 +1968,7 @@ struct common_ramrod_eth_rx_cqe {
 struct eth_rx_cqe_next_page {
 	u32 addr_lo;
 	u32 addr_hi;
-	u32 reserved0;
-	u32 reserved1;
+	u32 reserved[6];
 };
 
 /*
@@ -1806,11 +1998,6 @@ struct spe_hdr {
 	u16 reserved;
 };
 
-struct regpair {
-	u32 lo;
-	u32 hi;
-};
-
 /*
  * ethernet slow path element
  */
@@ -1821,6 +2008,7 @@ union eth_specific_data {
 	struct eth_halt_ramrod_data halt_ramrod_data;
 	struct regpair leading_cqe_addr;
 	struct regpair update_data_addr;
+	struct eth_query_ramrod_data query_ramrod_data;
 };
 
 /*
@@ -1843,10 +2031,13 @@ struct eth_tx_db_data {
 
 
 /*
- * Common configuration parameters per port in Tstorm
+ * Common configuration parameters per function in Tstorm
  */
 struct tstorm_eth_function_common_config {
-	u32 config_flags;
+#if defined(__BIG_ENDIAN)
+	u8 leading_client_id;
+	u8 rss_result_mask;
+	u16 config_flags;
 #define TSTORM_ETH_FUNCTION_COMMON_CONFIG_RSS_IPV4_CAPABILITY (0x1<<0)
 #define TSTORM_ETH_FUNCTION_COMMON_CONFIG_RSS_IPV4_CAPABILITY_SHIFT 0
 #define TSTORM_ETH_FUNCTION_COMMON_CONFIG_RSS_IPV4_TCP_CAPABILITY (0x1<<1)
@@ -1859,17 +2050,32 @@ struct tstorm_eth_function_common_config {
 #define TSTORM_ETH_FUNCTION_COMMON_CONFIG_RSS_ENABLE_SHIFT 4
 #define TSTORM_ETH_FUNCTION_COMMON_CONFIG_DEFAULT_ENABLE (0x1<<5)
 #define TSTORM_ETH_FUNCTION_COMMON_CONFIG_DEFAULT_ENABLE_SHIFT 5
-#define __TSTORM_ETH_FUNCTION_COMMON_CONFIG_RESERVED0 (0x3FFFFFF<<6)
-#define __TSTORM_ETH_FUNCTION_COMMON_CONFIG_RESERVED0_SHIFT 6
-#if defined(__BIG_ENDIAN)
-	u16 __secondary_vlan_id;
-	u8 leading_client_id;
-	u8 rss_result_mask;
+#define TSTORM_ETH_FUNCTION_COMMON_CONFIG_VLAN_IN_CAM (0x1<<6)
+#define TSTORM_ETH_FUNCTION_COMMON_CONFIG_VLAN_IN_CAM_SHIFT 6
+#define __TSTORM_ETH_FUNCTION_COMMON_CONFIG_RESERVED0 (0x1FF<<7)
+#define __TSTORM_ETH_FUNCTION_COMMON_CONFIG_RESERVED0_SHIFT 7
 #elif defined(__LITTLE_ENDIAN)
+	u16 config_flags;
+#define TSTORM_ETH_FUNCTION_COMMON_CONFIG_RSS_IPV4_CAPABILITY (0x1<<0)
+#define TSTORM_ETH_FUNCTION_COMMON_CONFIG_RSS_IPV4_CAPABILITY_SHIFT 0
+#define TSTORM_ETH_FUNCTION_COMMON_CONFIG_RSS_IPV4_TCP_CAPABILITY (0x1<<1)
+#define TSTORM_ETH_FUNCTION_COMMON_CONFIG_RSS_IPV4_TCP_CAPABILITY_SHIFT 1
+#define TSTORM_ETH_FUNCTION_COMMON_CONFIG_RSS_IPV6_CAPABILITY (0x1<<2)
+#define TSTORM_ETH_FUNCTION_COMMON_CONFIG_RSS_IPV6_CAPABILITY_SHIFT 2
+#define TSTORM_ETH_FUNCTION_COMMON_CONFIG_RSS_IPV6_TCP_CAPABILITY (0x1<<3)
+#define TSTORM_ETH_FUNCTION_COMMON_CONFIG_RSS_IPV6_TCP_CAPABILITY_SHIFT 3
+#define TSTORM_ETH_FUNCTION_COMMON_CONFIG_RSS_ENABLE (0x1<<4)
+#define TSTORM_ETH_FUNCTION_COMMON_CONFIG_RSS_ENABLE_SHIFT 4
+#define TSTORM_ETH_FUNCTION_COMMON_CONFIG_DEFAULT_ENABLE (0x1<<5)
+#define TSTORM_ETH_FUNCTION_COMMON_CONFIG_DEFAULT_ENABLE_SHIFT 5
+#define TSTORM_ETH_FUNCTION_COMMON_CONFIG_VLAN_IN_CAM (0x1<<6)
+#define TSTORM_ETH_FUNCTION_COMMON_CONFIG_VLAN_IN_CAM_SHIFT 6
+#define __TSTORM_ETH_FUNCTION_COMMON_CONFIG_RESERVED0 (0x1FF<<7)
+#define __TSTORM_ETH_FUNCTION_COMMON_CONFIG_RESERVED0_SHIFT 7
 	u8 rss_result_mask;
 	u8 leading_client_id;
-	u16 __secondary_vlan_id;
 #endif
+	u16 vlan_id[2];
 };
 
 /*
@@ -1887,7 +2093,7 @@ struct eth_update_ramrod_data {
 struct mac_configuration_hdr {
 	u8 length_6b;
 	u8 offset;
-	u16 reserved0;
+	u16 client_id;
 	u32 reserved1;
 };
 
@@ -1944,15 +2150,55 @@ struct mac_configuration_cmd {
 
 
 /*
+ * MAC address in list for ramrod
+ */
+struct mac_configuration_entry_e1h {
+	u16 lsb_mac_addr;
+	u16 middle_mac_addr;
+	u16 msb_mac_addr;
+	u16 vlan_id;
+	u16 e1hov_id;
+	u8 client_id;
+	u8 flags;
+#define MAC_CONFIGURATION_ENTRY_E1H_PORT (0x1<<0)
+#define MAC_CONFIGURATION_ENTRY_E1H_PORT_SHIFT 0
+#define MAC_CONFIGURATION_ENTRY_E1H_ACTION_TYPE (0x1<<1)
+#define MAC_CONFIGURATION_ENTRY_E1H_ACTION_TYPE_SHIFT 1
+#define MAC_CONFIGURATION_ENTRY_E1H_RDMA_MAC (0x1<<2)
+#define MAC_CONFIGURATION_ENTRY_E1H_RDMA_MAC_SHIFT 2
+#define MAC_CONFIGURATION_ENTRY_E1H_RESERVED0 (0x1F<<3)
+#define MAC_CONFIGURATION_ENTRY_E1H_RESERVED0_SHIFT 3
+};
+
+/*
+ * MAC filtering configuration command
+ */
+struct mac_configuration_cmd_e1h {
+	struct mac_configuration_hdr hdr;
+	struct mac_configuration_entry_e1h config_table[32];
+};
+
+
+/*
+ * approximate-match multicast filtering for E1H per function in Tstorm
+ */
+struct tstorm_eth_approximate_match_multicast_filtering {
+	u32 mcast_add_hash_bit_array[8];
+};
+
+
+/*
  * Configuration parameters per client in Tstorm
  */
 struct tstorm_eth_client_config {
 #if defined(__BIG_ENDIAN)
-	u16 statistics_counter_id;
+	u8 max_sges_for_packet;
+	u8 statistics_counter_id;
 	u16 mtu;
 #elif defined(__LITTLE_ENDIAN)
 	u16 mtu;
-	u16 statistics_counter_id;
+	u8 statistics_counter_id;
+	u8 max_sges_for_packet;
 #endif
 #if defined(__BIG_ENDIAN)
 	u16 drop_flags;
@@ -1960,42 +2206,42 @@ struct tstorm_eth_client_config {
 #define TSTORM_ETH_CLIENT_CONFIG_DROP_IP_CS_ERR_SHIFT 0
 #define TSTORM_ETH_CLIENT_CONFIG_DROP_TCP_CS_ERR (0x1<<1)
 #define TSTORM_ETH_CLIENT_CONFIG_DROP_TCP_CS_ERR_SHIFT 1
-#define TSTORM_ETH_CLIENT_CONFIG_DROP_MAC_ERR (0x1<<2)
-#define TSTORM_ETH_CLIENT_CONFIG_DROP_MAC_ERR_SHIFT 2
-#define TSTORM_ETH_CLIENT_CONFIG_DROP_TTL0 (0x1<<3)
-#define TSTORM_ETH_CLIENT_CONFIG_DROP_TTL0_SHIFT 3
-#define TSTORM_ETH_CLIENT_CONFIG_DROP_UDP_CS_ERR (0x1<<4)
-#define TSTORM_ETH_CLIENT_CONFIG_DROP_UDP_CS_ERR_SHIFT 4
-#define __TSTORM_ETH_CLIENT_CONFIG_RESERVED1 (0x7FF<<5)
-#define __TSTORM_ETH_CLIENT_CONFIG_RESERVED1_SHIFT 5
+#define TSTORM_ETH_CLIENT_CONFIG_DROP_TTL0 (0x1<<2)
+#define TSTORM_ETH_CLIENT_CONFIG_DROP_TTL0_SHIFT 2
+#define TSTORM_ETH_CLIENT_CONFIG_DROP_UDP_CS_ERR (0x1<<3)
+#define TSTORM_ETH_CLIENT_CONFIG_DROP_UDP_CS_ERR_SHIFT 3
+#define __TSTORM_ETH_CLIENT_CONFIG_RESERVED1 (0xFFF<<4)
+#define __TSTORM_ETH_CLIENT_CONFIG_RESERVED1_SHIFT 4
 	u16 config_flags;
 #define TSTORM_ETH_CLIENT_CONFIG_VLAN_REMOVAL_ENABLE (0x1<<0)
 #define TSTORM_ETH_CLIENT_CONFIG_VLAN_REMOVAL_ENABLE_SHIFT 0
 #define TSTORM_ETH_CLIENT_CONFIG_STATSITICS_ENABLE (0x1<<1)
 #define TSTORM_ETH_CLIENT_CONFIG_STATSITICS_ENABLE_SHIFT 1
-#define __TSTORM_ETH_CLIENT_CONFIG_RESERVED0 (0x3FFF<<2)
-#define __TSTORM_ETH_CLIENT_CONFIG_RESERVED0_SHIFT 2
+#define TSTORM_ETH_CLIENT_CONFIG_ENABLE_SGE_RING (0x1<<2)
+#define TSTORM_ETH_CLIENT_CONFIG_ENABLE_SGE_RING_SHIFT 2
+#define __TSTORM_ETH_CLIENT_CONFIG_RESERVED0 (0x1FFF<<3)
+#define __TSTORM_ETH_CLIENT_CONFIG_RESERVED0_SHIFT 3
 #elif defined(__LITTLE_ENDIAN)
 	u16 config_flags;
 #define TSTORM_ETH_CLIENT_CONFIG_VLAN_REMOVAL_ENABLE (0x1<<0)
 #define TSTORM_ETH_CLIENT_CONFIG_VLAN_REMOVAL_ENABLE_SHIFT 0
 #define TSTORM_ETH_CLIENT_CONFIG_STATSITICS_ENABLE (0x1<<1)
 #define TSTORM_ETH_CLIENT_CONFIG_STATSITICS_ENABLE_SHIFT 1
-#define __TSTORM_ETH_CLIENT_CONFIG_RESERVED0 (0x3FFF<<2)
-#define __TSTORM_ETH_CLIENT_CONFIG_RESERVED0_SHIFT 2
+#define TSTORM_ETH_CLIENT_CONFIG_ENABLE_SGE_RING (0x1<<2)
+#define TSTORM_ETH_CLIENT_CONFIG_ENABLE_SGE_RING_SHIFT 2
+#define __TSTORM_ETH_CLIENT_CONFIG_RESERVED0 (0x1FFF<<3)
+#define __TSTORM_ETH_CLIENT_CONFIG_RESERVED0_SHIFT 3
 	u16 drop_flags;
 #define TSTORM_ETH_CLIENT_CONFIG_DROP_IP_CS_ERR (0x1<<0)
 #define TSTORM_ETH_CLIENT_CONFIG_DROP_IP_CS_ERR_SHIFT 0
 #define TSTORM_ETH_CLIENT_CONFIG_DROP_TCP_CS_ERR (0x1<<1)
 #define TSTORM_ETH_CLIENT_CONFIG_DROP_TCP_CS_ERR_SHIFT 1
-#define TSTORM_ETH_CLIENT_CONFIG_DROP_MAC_ERR (0x1<<2)
-#define TSTORM_ETH_CLIENT_CONFIG_DROP_MAC_ERR_SHIFT 2
-#define TSTORM_ETH_CLIENT_CONFIG_DROP_TTL0 (0x1<<3)
-#define TSTORM_ETH_CLIENT_CONFIG_DROP_TTL0_SHIFT 3
-#define TSTORM_ETH_CLIENT_CONFIG_DROP_UDP_CS_ERR (0x1<<4)
-#define TSTORM_ETH_CLIENT_CONFIG_DROP_UDP_CS_ERR_SHIFT 4
-#define __TSTORM_ETH_CLIENT_CONFIG_RESERVED1 (0x7FF<<5)
-#define __TSTORM_ETH_CLIENT_CONFIG_RESERVED1_SHIFT 5
+#define TSTORM_ETH_CLIENT_CONFIG_DROP_TTL0 (0x1<<2)
+#define TSTORM_ETH_CLIENT_CONFIG_DROP_TTL0_SHIFT 2
+#define TSTORM_ETH_CLIENT_CONFIG_DROP_UDP_CS_ERR (0x1<<3)
+#define TSTORM_ETH_CLIENT_CONFIG_DROP_UDP_CS_ERR_SHIFT 3
+#define __TSTORM_ETH_CLIENT_CONFIG_RESERVED1 (0xFFF<<4)
+#define __TSTORM_ETH_CLIENT_CONFIG_RESERVED1_SHIFT 4
 #endif
 };
 
@@ -2011,96 +2257,112 @@ struct tstorm_eth_mac_filter_config {
 	u32 bcast_drop_all;
 	u32 bcast_accept_all;
 	u32 strict_vlan;
-	u32 __secondary_vlan_clients;
+	u32 vlan_filter[2];
+	u32 reserved;
 };
 
 
-struct rate_shaping_per_protocol {
+/*
+ * Three RX producers for ETH
+ */
+struct tstorm_eth_rx_producers {
 #if defined(__BIG_ENDIAN)
-	u16 reserved0;
-	u16 protocol_rate;
+	u16 bd_prod;
+	u16 cqe_prod;
 #elif defined(__LITTLE_ENDIAN)
-	u16 protocol_rate;
-	u16 reserved0;
+	u16 cqe_prod;
+	u16 bd_prod;
 #endif
-	u32 protocol_quota;
-	s32 current_credit;
-	u32 reserved;
-};
-
-struct rate_shaping_vars {
-	struct rate_shaping_per_protocol protocol_vars[NUM_OF_PROTOCOLS];
-	u32 pause_mask;
-	u32 periodic_stop;
-	u32 rs_periodic_timeout;
-	u32 rs_threshold;
-	u32 last_periodic_time;
-	u32 reserved;
-};
-
-struct fairness_per_protocol {
-	u32 credit_delta;
-	s32 fair_credit;
 #if defined(__BIG_ENDIAN)
-	u16 reserved0;
-	u8 state;
-	u8 weight;
+	u16 reserved;
+	u16 sge_prod;
 #elif defined(__LITTLE_ENDIAN)
-	u8 weight;
-	u8 state;
-	u16 reserved0;
+	u16 sge_prod;
+	u16 reserved;
 #endif
-	u32 reserved1;
 };
 
-struct fairness_vars {
-	struct fairness_per_protocol protocol_vars[NUM_OF_PROTOCOLS];
-	u32 upper_bound;
-	u32 port_rate;
-	u32 pause_mask;
-	u32 fair_threshold;
-};
 
-struct safc_struct {
-	u32 cur_pause_mask;
-	u32 expire_time;
+/*
+ * common flag to indicate existance of TPA.
+ */
+struct tstorm_eth_tpa_exist {
 #if defined(__BIG_ENDIAN)
-	u16 reserved0;
-	u8 cur_cos_types;
-	u8 safc_timeout_usec;
+	u16 reserved1;
+	u8 reserved0;
+	u8 tpa_exist;
 #elif defined(__LITTLE_ENDIAN)
-	u8 safc_timeout_usec;
-	u8 cur_cos_types;
-	u16 reserved0;
+	u8 tpa_exist;
+	u8 reserved0;
+	u16 reserved1;
 #endif
-	u32 reserved1;
+	u32 reserved2;
 };
 
-struct demo_struct {
+
+/*
+ * per-port SAFC demo variables
+ */
+struct cmng_flags_per_port {
 	u8 con_number[NUM_OF_PROTOCOLS];
 #if defined(__BIG_ENDIAN)
-	u8 reserved1;
 	u8 fairness_enable;
 	u8 rate_shaping_enable;
-	u8 cmng_enable;
+	u8 cmng_protocol_enable;
+	u8 cmng_vn_enable;
 #elif defined(__LITTLE_ENDIAN)
-	u8 cmng_enable;
+	u8 cmng_vn_enable;
+	u8 cmng_protocol_enable;
 	u8 rate_shaping_enable;
 	u8 fairness_enable;
-	u8 reserved1;
 #endif
 };
 
-struct cmng_struct {
-	struct rate_shaping_vars rs_vars;
-	struct fairness_vars fair_vars;
-	struct safc_struct safc_vars;
-	struct demo_struct demo_vars;
+
+/*
+ * per-port rate shaping variables
+ */
+struct rate_shaping_vars_per_port {
+	u32 rs_periodic_timeout;
+	u32 rs_threshold;
+};
+
+
+/*
+ * per-port fairness variables
+ */
+struct fairness_vars_per_port {
+	u32 upper_bound;
+	u32 fair_threshold;
+	u32 fairness_timeout;
+};
+
+
+/*
+ * per-port SAFC variables
+ */
+struct safc_struct_per_port {
+#if defined(__BIG_ENDIAN)
+	u16 __reserved0;
+	u8 cur_cos_types;
+	u8 safc_timeout_usec;
+#elif defined(__LITTLE_ENDIAN)
+	u8 safc_timeout_usec;
+	u8 cur_cos_types;
+	u16 __reserved0;
+#endif
+	u8 cos_to_protocol[MAX_COS_NUMBER];
 };
 
 
-struct cos_to_protocol {
-	u8 mask[MAX_COS_NUMBER];
+/*
+ * Per-port congestion management variables
+ */
+struct cmng_struct_per_port {
+	struct rate_shaping_vars_per_port rs_vars;
+	struct fairness_vars_per_port fair_vars;
+	struct safc_struct_per_port safc_vars;
+	struct cmng_flags_per_port flags;
 };
 
 
@@ -2162,6 +2424,16 @@ struct eth_stats_query {
 
 
 /*
+ * per-vnic fairness variables
+ */
+struct fairness_vars_per_vn {
+	u32 protocol_credit_delta[NUM_OF_PROTOCOLS];
+	u32 vn_credit_delta;
+	u32 __reserved0;
+};
+
+
+/*
  * FW version stored in the Xstorm RAM
  */
 struct fw_version {
@@ -2179,8 +2451,10 @@ struct fw_version {
 #define FW_VERSION_OPTIMIZED_SHIFT 0
 #define FW_VERSION_BIG_ENDIEN (0x1<<1)
 #define FW_VERSION_BIG_ENDIEN_SHIFT 1
-#define __FW_VERSION_RESERVED (0x3FFFFFFF<<2)
-#define __FW_VERSION_RESERVED_SHIFT 2
+#define FW_VERSION_CHIP_VERSION (0x3<<2)
+#define FW_VERSION_CHIP_VERSION_SHIFT 2
+#define __FW_VERSION_RESERVED (0xFFFFFFF<<4)
+#define __FW_VERSION_RESERVED_SHIFT 4
 };
 
 
@@ -2188,15 +2462,9 @@ struct fw_version {
  * FW version stored in first line of pram
  */
 struct pram_fw_version {
-#if defined(__BIG_ENDIAN)
-	u16 patch;
-	u8 primary;
-	u8 client;
-#elif defined(__LITTLE_ENDIAN)
 	u8 client;
 	u8 primary;
 	u16 patch;
-#endif
 	u8 flags;
 #define PRAM_FW_VERSION_OPTIMIZED (0x1<<0)
 #define PRAM_FW_VERSION_OPTIMIZED_SHIFT 0
@@ -2204,8 +2472,34 @@ struct pram_fw_version {
 #define PRAM_FW_VERSION_STORM_ID_SHIFT 1
 #define PRAM_FW_VERSION_BIG_ENDIEN (0x1<<3)
 #define PRAM_FW_VERSION_BIG_ENDIEN_SHIFT 3
-#define __PRAM_FW_VERSION_RESERVED0 (0xF<<4)
-#define __PRAM_FW_VERSION_RESERVED0_SHIFT 4
+#define PRAM_FW_VERSION_CHIP_VERSION (0x3<<4)
+#define PRAM_FW_VERSION_CHIP_VERSION_SHIFT 4
+#define __PRAM_FW_VERSION_RESERVED0 (0x3<<6)
+#define __PRAM_FW_VERSION_RESERVED0_SHIFT 6
+};
+
+
+/*
+ * a single rate shaping counter. can be used as protocol or vnic counter
+ */
+struct rate_shaping_counter {
+	u32 quota;
+#if defined(__BIG_ENDIAN)
+	u16 __reserved0;
+	u16 rate;
+#elif defined(__LITTLE_ENDIAN)
+	u16 rate;
+	u16 __reserved0;
+#endif
+};
+
+
+/*
+ * per-vnic rate shaping variables
+ */
+struct rate_shaping_vars_per_vn {
+	struct rate_shaping_counter protocol_counters[NUM_OF_PROTOCOLS];
+	struct rate_shaping_counter vn_counter;
 };
 
 
diff --git a/drivers/net/bnx2x_init.h b/drivers/net/bnx2x_init.h
index 5a4e82b..4c77507 100644
--- a/drivers/net/bnx2x_init.h
+++ b/drivers/net/bnx2x_init.h
@@ -226,28 +226,28 @@ static const u32 *bnx2x_sel_blob(u32 addr, const u32 *data, int is_e1)
 			       tsem_int_table_data_e1h;
 	else
 		IF_IS_INT_TABLE_ADDR(CSEM_REG_INT_TABLE, addr)
-		data = is_e1 ? csem_int_table_data_e1 :
-			       csem_int_table_data_e1h;
+			data = is_e1 ? csem_int_table_data_e1 :
+				       csem_int_table_data_e1h;
 	else
 		IF_IS_INT_TABLE_ADDR(USEM_REG_INT_TABLE, addr)
-		data = is_e1 ? usem_int_table_data_e1 :
-			       usem_int_table_data_e1h;
+			data = is_e1 ? usem_int_table_data_e1 :
+				       usem_int_table_data_e1h;
 	else
 		IF_IS_INT_TABLE_ADDR(XSEM_REG_INT_TABLE, addr)
-		data = is_e1 ? xsem_int_table_data_e1 :
-			       xsem_int_table_data_e1h;
+			data = is_e1 ? xsem_int_table_data_e1 :
+				       xsem_int_table_data_e1h;
 	else
 		IF_IS_PRAM_ADDR(TSEM_REG_PRAM, addr)
-		data = is_e1 ? tsem_pram_data_e1 : tsem_pram_data_e1h;
+			data = is_e1 ? tsem_pram_data_e1 : tsem_pram_data_e1h;
 	else
 		IF_IS_PRAM_ADDR(CSEM_REG_PRAM, addr)
-		data = is_e1 ? csem_pram_data_e1 : csem_pram_data_e1h;
+			data = is_e1 ? csem_pram_data_e1 : csem_pram_data_e1h;
 	else
 		IF_IS_PRAM_ADDR(USEM_REG_PRAM, addr)
-		data = is_e1 ? usem_pram_data_e1 : usem_pram_data_e1h;
+			data = is_e1 ? usem_pram_data_e1 : usem_pram_data_e1h;
 	else
 		IF_IS_PRAM_ADDR(XSEM_REG_PRAM, addr)
-		data = is_e1 ? xsem_pram_data_e1 : xsem_pram_data_e1h;
+			data = is_e1 ? xsem_pram_data_e1 : xsem_pram_data_e1h;
 
 	return data;
 }
diff --git a/drivers/net/bnx2x_link.c b/drivers/net/bnx2x_link.c
index 22586eb..ff2743d 100644
--- a/drivers/net/bnx2x_link.c
+++ b/drivers/net/bnx2x_link.c
@@ -3572,7 +3572,8 @@ u8 bnx2x_set_led(struct bnx2x *bp, u8 port, u8 mode, u32 speed,
 			   LED_BLINK_RATE_VAL);
 		REG_WR(bp, NIG_REG_LED_CONTROL_BLINK_RATE_ENA_P0 +
 			   port*4, 1);
-		if (((speed == SPEED_2500) ||
+		if (!CHIP_IS_E1H(bp) &&
+		    ((speed == SPEED_2500) ||
 		     (speed == SPEED_1000) ||
 		     (speed == SPEED_100) ||
 		     (speed == SPEED_10))) {
@@ -3753,6 +3754,14 @@ u8 bnx2x_phy_init(struct link_params *params, struct link_vars *vars)
 		vars->duplex = DUPLEX_FULL;
 		vars->flow_ctrl = FLOW_CTRL_NONE;
 		vars->link_status = (LINK_STATUS_LINK_UP | LINK_10GTFD);
+		/* enable on E1.5 FPGA */
+		if (CHIP_IS_E1H(bp)) {
+			vars->flow_ctrl |=
+				(FLOW_CTRL_TX | FLOW_CTRL_RX);
+			vars->link_status |=
+					(LINK_STATUS_TX_FLOW_CONTROL_ENABLED |
+					 LINK_STATUS_RX_FLOW_CONTROL_ENABLED);
+		}
 
 		bnx2x_emac_enable(params, vars, 0);
 		bnx2x_pbf_update(params, vars->flow_ctrl, vars->line_speed);
diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index efa9426..90b54e4 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -1,4 +1,4 @@
-/* bnx2x.c: Broadcom Everest network driver.
+/* bnx2x_main.c: Broadcom Everest network driver.
  *
  * Copyright (c) 2007-2008 Broadcom Corporation
  *
@@ -15,12 +15,6 @@
  *
  */
 
-/* define this to make the driver freeze on error
- * to allow getting debug info
- * (you will need to reboot afterwards)
- */
-/*#define BNX2X_STOP_ON_ERROR*/
-
 #include <linux/module.h>
 #include <linux/moduleparam.h>
 #include <linux/kernel.h>
@@ -46,16 +40,17 @@
 #include <linux/mii.h>
 #ifdef NETIF_F_HW_VLAN_TX
 	#include <linux/if_vlan.h>
-	#define BCM_VLAN 1
 #endif
 #include <net/ip.h>
 #include <net/tcp.h>
 #include <net/checksum.h>
+#include <linux/version.h>
+#include <net/ip6_checksum.h>
 #include <linux/workqueue.h>
 #include <linux/crc32.h>
+#include <linux/crc32c.h>
 #include <linux/prefetch.h>
 #include <linux/zlib.h>
-#include <linux/version.h>
 #include <linux/io.h>
 
 #include "bnx2x_reg.h"
@@ -67,13 +62,13 @@
 
 #define DRV_MODULE_VERSION      "1.42.4"
 #define DRV_MODULE_RELDATE      "2008/4/9"
-#define BNX2X_BC_VER    	0x040200
+#define BNX2X_BC_VER		0x040200
 
-/* Time in jiffies before concluding the transmitter is hung. */
-#define TX_TIMEOUT      	(5*HZ)
+/* Time in jiffies before concluding the transmitter is hung */
+#define TX_TIMEOUT		(5*HZ)
 
 static char version[] __devinitdata =
-	"Broadcom NetXtreme II 5771X 10Gigabit Ethernet Driver "
+	"Broadcom NetXtreme II 5771x 10Gigabit Ethernet Driver "
 	DRV_MODULE_NAME " " DRV_MODULE_VERSION " (" DRV_MODULE_RELDATE ")\n";
 
 MODULE_AUTHOR("Eliezer Tamir");
@@ -83,20 +78,19 @@ MODULE_VERSION(DRV_MODULE_VERSION);
 
 static int use_inta;
 static int poll;
-static int onefunc;
-static int nomcp;
 static int debug;
+static int nomcp;
+static int load_count[3]; /* 0-common, 1-port0, 2-port1 */
 static int use_multi;
 
 module_param(use_inta, int, 0);
 module_param(poll, int, 0);
-module_param(onefunc, int, 0);
 module_param(debug, int, 0);
+module_param(nomcp, int, 0);
 MODULE_PARM_DESC(use_inta, "use INT#A instead of MSI-X");
 MODULE_PARM_DESC(poll, "use polling (for debug)");
-MODULE_PARM_DESC(onefunc, "enable only first function");
-MODULE_PARM_DESC(nomcp, "ignore management CPU (Implies onefunc)");
 MODULE_PARM_DESC(debug, "default debug msglevel");
+MODULE_PARM_DESC(nomcp, "ignore management CPU");
 
 #ifdef BNX2X_MULTI
 module_param(use_multi, int, 0);
@@ -105,18 +99,27 @@ MODULE_PARM_DESC(use_multi, "use per-CPU queues");
 
 enum bnx2x_board_type {
 	BCM57710 = 0,
+	BCM57711 = 1,
+	BCM57711E = 2,
 };
 
-/* indexed by board_t, above */
+/* indexed by board_type, above */
 static struct {
 	char *name;
 } board_info[] __devinitdata = {
-	{ "Broadcom NetXtreme II BCM57710 XGb" }
+	{ "Broadcom NetXtreme II BCM57710 XGb" },
+	{ "Broadcom NetXtreme II BCM57711 XGb" },
+	{ "Broadcom NetXtreme II BCM57711E XGb" }
 };
 
+
 static const struct pci_device_id bnx2x_pci_tbl[] = {
 	{ PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_NX2_57710,
 		PCI_ANY_ID, PCI_ANY_ID, 0, 0, BCM57710 },
+	{ PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_NX2_57711,
+		PCI_ANY_ID, PCI_ANY_ID, 0, 0, BCM57711 },
+	{ PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_NX2_57711E,
+		PCI_ANY_ID, PCI_ANY_ID, 0, 0, BCM57711E },
 	{ 0 }
 };
 
@@ -201,7 +204,8 @@ void bnx2x_write_dmae(struct bnx2x *bp, dma_addr_t dma_addr, u32 dst_addr,
 #else
 			DMAE_CMD_ENDIANITY_DW_SWAP |
 #endif
-			(bp->port ? DMAE_CMD_PORT_1 : DMAE_CMD_PORT_0));
+			(BP_PORT(bp) ? DMAE_CMD_PORT_1 : DMAE_CMD_PORT_0) |
+			(BP_E1HVN(bp) << DMAE_CMD_E1HVN_SHIFT));
 	dmae->src_addr_lo = U64_LO(dma_addr);
 	dmae->src_addr_hi = U64_HI(dma_addr);
 	dmae->dst_addr_lo = dst_addr >> 2;
@@ -224,7 +228,7 @@ void bnx2x_write_dmae(struct bnx2x *bp, dma_addr_t dma_addr, u32 dst_addr,
 
 	*wb_comp = 0;
 
-	bnx2x_post_dmae(bp, dmae, (bp->port)*MAX_DMAE_C_PER_PORT);
+	bnx2x_post_dmae(bp, dmae, INIT_DMAE_C(bp));
 
 	udelay(5);
 
@@ -277,7 +281,8 @@ void bnx2x_read_dmae(struct bnx2x *bp, u32 src_addr, u32 len32)
 #else
 			DMAE_CMD_ENDIANITY_DW_SWAP |
 #endif
-			(bp->port ? DMAE_CMD_PORT_1 : DMAE_CMD_PORT_0));
+			(BP_PORT(bp) ? DMAE_CMD_PORT_1 : DMAE_CMD_PORT_0) |
+			(BP_E1HVN(bp) << DMAE_CMD_E1HVN_SHIFT));
 	dmae->src_addr_lo = src_addr >> 2;
 	dmae->src_addr_hi = 0;
 	dmae->dst_addr_lo = U64_LO(bnx2x_sp_mapping(bp, wb_data));
@@ -297,7 +302,7 @@ void bnx2x_read_dmae(struct bnx2x *bp, u32 src_addr, u32 len32)
 
 	*wb_comp = 0;
 
-	bnx2x_post_dmae(bp, dmae, (bp->port)*MAX_DMAE_C_PER_PORT);
+	bnx2x_post_dmae(bp, dmae, INIT_DMAE_C(bp));
 
 	udelay(5);
 
@@ -345,47 +350,122 @@ static u64 bnx2x_wb_rd(struct bnx2x *bp, int reg)
 
 static int bnx2x_mc_assert(struct bnx2x *bp)
 {
-	int i, j, rc = 0;
 	char last_idx;
-	const char storm[] = {"XTCU"};
-	const u32 intmem_base[] = {
-		BAR_XSTRORM_INTMEM,
-		BAR_TSTRORM_INTMEM,
-		BAR_CSTRORM_INTMEM,
-		BAR_USTRORM_INTMEM
-	};
-
-	/* Go through all instances of all SEMIs */
-	for (i = 0; i < 4; i++) {
-		last_idx = REG_RD8(bp, XSTORM_ASSERT_LIST_INDEX_OFFSET +
-				   intmem_base[i]);
-		if (last_idx)
-			BNX2X_LOG("DATA %cSTORM_ASSERT_LIST_INDEX 0x%x\n",
-				  storm[i], last_idx);
-
-		/* print the asserts */
-		for (j = 0; j < STROM_ASSERT_ARRAY_SIZE; j++) {
-			u32 row0, row1, row2, row3;
-
-			row0 = REG_RD(bp, XSTORM_ASSERT_LIST_OFFSET(j) +
-				      intmem_base[i]);
-			row1 = REG_RD(bp, XSTORM_ASSERT_LIST_OFFSET(j) + 4 +
-				      intmem_base[i]);
-			row2 = REG_RD(bp, XSTORM_ASSERT_LIST_OFFSET(j) + 8 +
-				      intmem_base[i]);
-			row3 = REG_RD(bp, XSTORM_ASSERT_LIST_OFFSET(j) + 12 +
-				      intmem_base[i]);
-
-			if (row0 != COMMON_ASM_INVALID_ASSERT_OPCODE) {
-				BNX2X_LOG("DATA %cSTORM_ASSERT_INDEX 0x%x ="
-					  " 0x%08x 0x%08x 0x%08x 0x%08x\n",
-					  storm[i], j, row3, row2, row1, row0);
-				rc++;
-			} else {
-				break;
-			}
+	int i, rc = 0;
+	u32 row0, row1, row2, row3;
+
+	/* XSTORM */
+	last_idx = REG_RD8(bp, BAR_XSTRORM_INTMEM +
+			   XSTORM_ASSERT_LIST_INDEX_OFFSET);
+	if (last_idx)
+		BNX2X_ERR("XSTORM_ASSERT_LIST_INDEX 0x%x\n", last_idx);
+
+	/* print the asserts */
+	for (i = 0; i < STROM_ASSERT_ARRAY_SIZE; i++) {
+
+		row0 = REG_RD(bp, BAR_XSTRORM_INTMEM +
+			      XSTORM_ASSERT_LIST_OFFSET(i));
+		row1 = REG_RD(bp, BAR_XSTRORM_INTMEM +
+			      XSTORM_ASSERT_LIST_OFFSET(i) + 4);
+		row2 = REG_RD(bp, BAR_XSTRORM_INTMEM +
+			      XSTORM_ASSERT_LIST_OFFSET(i) + 8);
+		row3 = REG_RD(bp, BAR_XSTRORM_INTMEM +
+			      XSTORM_ASSERT_LIST_OFFSET(i) + 12);
+
+		if (row0 != COMMON_ASM_INVALID_ASSERT_OPCODE) {
+			BNX2X_ERR("XSTORM_ASSERT_INDEX 0x%x = 0x%08x"
+				  " 0x%08x 0x%08x 0x%08x\n",
+				  i, row3, row2, row1, row0);
+			rc++;
+		} else {
+			break;
+		}
+	}
+
+	/* TSTORM */
+	last_idx = REG_RD8(bp, BAR_TSTRORM_INTMEM +
+			   TSTORM_ASSERT_LIST_INDEX_OFFSET);
+	if (last_idx)
+		BNX2X_ERR("TSTORM_ASSERT_LIST_INDEX 0x%x\n", last_idx);
+
+	/* print the asserts */
+	for (i = 0; i < STROM_ASSERT_ARRAY_SIZE; i++) {
+
+		row0 = REG_RD(bp, BAR_TSTRORM_INTMEM +
+			      TSTORM_ASSERT_LIST_OFFSET(i));
+		row1 = REG_RD(bp, BAR_TSTRORM_INTMEM +
+			      TSTORM_ASSERT_LIST_OFFSET(i) + 4);
+		row2 = REG_RD(bp, BAR_TSTRORM_INTMEM +
+			      TSTORM_ASSERT_LIST_OFFSET(i) + 8);
+		row3 = REG_RD(bp, BAR_TSTRORM_INTMEM +
+			      TSTORM_ASSERT_LIST_OFFSET(i) + 12);
+
+		if (row0 != COMMON_ASM_INVALID_ASSERT_OPCODE) {
+			BNX2X_ERR("TSTORM_ASSERT_INDEX 0x%x = 0x%08x"
+				  " 0x%08x 0x%08x 0x%08x\n",
+				  i, row3, row2, row1, row0);
+			rc++;
+		} else {
+			break;
+		}
+	}
+
+	/* CSTORM */
+	last_idx = REG_RD8(bp, BAR_CSTRORM_INTMEM +
+			   CSTORM_ASSERT_LIST_INDEX_OFFSET);
+	if (last_idx)
+		BNX2X_ERR("CSTORM_ASSERT_LIST_INDEX 0x%x\n", last_idx);
+
+	/* print the asserts */
+	for (i = 0; i < STROM_ASSERT_ARRAY_SIZE; i++) {
+
+		row0 = REG_RD(bp, BAR_CSTRORM_INTMEM +
+			      CSTORM_ASSERT_LIST_OFFSET(i));
+		row1 = REG_RD(bp, BAR_CSTRORM_INTMEM +
+			      CSTORM_ASSERT_LIST_OFFSET(i) + 4);
+		row2 = REG_RD(bp, BAR_CSTRORM_INTMEM +
+			      CSTORM_ASSERT_LIST_OFFSET(i) + 8);
+		row3 = REG_RD(bp, BAR_CSTRORM_INTMEM +
+			      CSTORM_ASSERT_LIST_OFFSET(i) + 12);
+
+		if (row0 != COMMON_ASM_INVALID_ASSERT_OPCODE) {
+			BNX2X_ERR("CSTORM_ASSERT_INDEX 0x%x = 0x%08x"
+				  " 0x%08x 0x%08x 0x%08x\n",
+				  i, row3, row2, row1, row0);
+			rc++;
+		} else {
+			break;
 		}
 	}
+
+	/* USTORM */
+	last_idx = REG_RD8(bp, BAR_USTRORM_INTMEM +
+			   USTORM_ASSERT_LIST_INDEX_OFFSET);
+	if (last_idx)
+		BNX2X_ERR("USTORM_ASSERT_LIST_INDEX 0x%x\n", last_idx);
+
+	/* print the asserts */
+	for (i = 0; i < STROM_ASSERT_ARRAY_SIZE; i++) {
+
+		row0 = REG_RD(bp, BAR_USTRORM_INTMEM +
+			      USTORM_ASSERT_LIST_OFFSET(i));
+		row1 = REG_RD(bp, BAR_USTRORM_INTMEM +
+			      USTORM_ASSERT_LIST_OFFSET(i) + 4);
+		row2 = REG_RD(bp, BAR_USTRORM_INTMEM +
+			      USTORM_ASSERT_LIST_OFFSET(i) + 8);
+		row3 = REG_RD(bp, BAR_USTRORM_INTMEM +
+			      USTORM_ASSERT_LIST_OFFSET(i) + 12);
+
+		if (row0 != COMMON_ASM_INVALID_ASSERT_OPCODE) {
+			BNX2X_ERR("USTORM_ASSERT_INDEX 0x%x = 0x%08x"
+				  " 0x%08x 0x%08x 0x%08x\n",
+				  i, row3, row2, row1, row0);
+			rc++;
+		} else {
+			break;
+		}
+	}
+
 	return rc;
 }
 
@@ -428,14 +508,16 @@ static void bnx2x_panic_dump(struct bnx2x *bp)
 		struct eth_tx_db_data *hw_prods = fp->hw_tx_prods;
 
 		BNX2X_ERR("queue[%d]: tx_pkt_prod(%x)  tx_pkt_cons(%x)"
-			  "  tx_bd_prod(%x)  tx_bd_cons(%x)  *tx_cons_sb(%x)"
-			  "  *rx_cons_sb(%x)  rx_comp_prod(%x)"
-			  "  rx_comp_cons(%x)  fp_c_idx(%x)  fp_u_idx(%x)"
-			  "  bd data(%x,%x)\n",
+			  "  tx_bd_prod(%x)  tx_bd_cons(%x)  *tx_cons_sb(%x)\n",
 			  i, fp->tx_pkt_prod, fp->tx_pkt_cons, fp->tx_bd_prod,
-			  fp->tx_bd_cons, *fp->tx_cons_sb, *fp->rx_cons_sb,
-			  fp->rx_comp_prod, fp->rx_comp_cons, fp->fp_c_idx,
-			  fp->fp_u_idx, hw_prods->packets_prod,
+			  fp->tx_bd_cons, le16_to_cpu(*fp->tx_cons_sb));
+		BNX2X_ERR("          rx_comp_prod(%x)  rx_comp_cons(%x)"
+			  "  *rx_cons_sb(%x)\n",
+			  fp->rx_comp_prod, fp->rx_comp_cons,
+			  le16_to_cpu(*fp->rx_cons_sb));
+		BNX2X_ERR("          fp_c_idx(%x)  fp_u_idx(%x)"
+			  "  bd data(%x,%x)\n",
+			  fp->fp_c_idx, fp->fp_u_idx, hw_prods->packets_prod,
 			  hw_prods->bds_prod);
 
 		start = TX_BD(le16_to_cpu(*fp->tx_cons_sb) - 10);
@@ -463,7 +545,7 @@ static void bnx2x_panic_dump(struct bnx2x *bp)
 			struct sw_rx_bd *sw_bd = &fp->rx_buf_ring[j];
 
 			BNX2X_ERR("rx_bd[%x]=[%x:%x]  sw_bd=[%p]\n",
-				  j, rx_bd[0], rx_bd[1], sw_bd->skb);
+				  j, rx_bd[1], rx_bd[0], sw_bd->skb);
 		}
 
 		start = RCQ_BD(fp->rx_comp_cons - 10);
@@ -482,7 +564,7 @@ static void bnx2x_panic_dump(struct bnx2x *bp)
 		  bp->def_c_idx, bp->def_u_idx, bp->def_x_idx, bp->def_t_idx,
 		  bp->def_att_idx, bp->attn_state, bp->spq_prod_idx);
 
-
+	bnx2x_fw_dump(bp);
 	bnx2x_mc_assert(bp);
 	BNX2X_ERR("end crash dump -----------------\n");
 
@@ -492,7 +574,7 @@ static void bnx2x_panic_dump(struct bnx2x *bp)
 
 static void bnx2x_int_enable(struct bnx2x *bp)
 {
-	int port = bp->port;
+	int port = BP_PORT(bp);
 	u32 addr = port ? HC_REG_CONFIG_1 : HC_REG_CONFIG_0;
 	u32 val = REG_RD(bp, addr);
 	int msix = (bp->flags & USING_MSIX_FLAG) ? 1 : 0;
@@ -507,7 +589,6 @@ static void bnx2x_int_enable(struct bnx2x *bp)
 			HC_CONFIG_0_REG_INT_LINE_EN_0 |
 			HC_CONFIG_0_REG_ATTN_BIT_EN_0);
 
-		/* Errata A0.158 workaround */
 		DP(NETIF_MSG_INTR, "write %x to HC %d (addr 0x%x)  MSI-X %d\n",
 		   val, port, addr, msix);
 
@@ -520,11 +601,25 @@ static void bnx2x_int_enable(struct bnx2x *bp)
 	   val, port, addr, msix);
 
 	REG_WR(bp, addr, val);
+
+	if (CHIP_IS_E1H(bp)) {
+		/* init leading/trailing edge */
+		if (IS_E1HMF(bp)) {
+			val = (0xfe0f | (1 << (BP_E1HVN(bp) + 4)));
+			if (bp->port.pmf)
+				/* enable nig attention */
+				val |= 0x0100;
+		} else
+			val = 0xffff;
+
+		REG_WR(bp, HC_REG_TRAILING_EDGE_0 + port*8, val);
+		REG_WR(bp, HC_REG_LEADING_EDGE_0 + port*8, val);
+	}
 }
 
 static void bnx2x_int_disable(struct bnx2x *bp)
 {
-	int port = bp->port;
+	int port = BP_PORT(bp);
 	u32 addr = port ? HC_REG_CONFIG_1 : HC_REG_CONFIG_0;
 	u32 val = REG_RD(bp, addr);
 
@@ -543,10 +638,10 @@ static void bnx2x_int_disable(struct bnx2x *bp)
 
 static void bnx2x_int_disable_sync(struct bnx2x *bp)
 {
-
 	int msix = (bp->flags & USING_MSIX_FLAG) ? 1 : 0;
 	int i;
 
+	/* disable interrupt handling */
 	atomic_inc(&bp->intr_sem);
 	/* prevent the HW from sending interrupts */
 	bnx2x_int_disable(bp);
@@ -563,30 +658,29 @@ static void bnx2x_int_disable_sync(struct bnx2x *bp)
 
 	/* make sure sp_task is not running */
 	cancel_work_sync(&bp->sp_task);
-
 }
 
-/* fast path code */
+/* fast path */
 
 /*
- * general service functions
+ * General service functions
  */
 
-static inline void bnx2x_ack_sb(struct bnx2x *bp, u8 id,
+static inline void bnx2x_ack_sb(struct bnx2x *bp, u8 sb_id,
 				u8 storm, u16 index, u8 op, u8 update)
 {
-	u32 igu_addr = (IGU_ADDR_INT_ACK + IGU_PORT_BASE * bp->port) * 8;
+	u32 igu_addr = (IGU_ADDR_INT_ACK + IGU_FUNC_BASE * BP_FUNC(bp)) * 8;
 	struct igu_ack_register igu_ack;
 
 	igu_ack.status_block_index = index;
 	igu_ack.sb_id_and_flags =
-			((id << IGU_ACK_REGISTER_STATUS_BLOCK_ID_SHIFT) |
+			((sb_id << IGU_ACK_REGISTER_STATUS_BLOCK_ID_SHIFT) |
 			 (storm << IGU_ACK_REGISTER_STORM_ID_SHIFT) |
 			 (update << IGU_ACK_REGISTER_UPDATE_INDEX_SHIFT) |
 			 (op << IGU_ACK_REGISTER_INTERRUPT_MODE_SHIFT));
 
-/*      DP(NETIF_MSG_INTR, "write 0x%08x to IGU addr 0x%x\n",
-	   (*(u32 *)&igu_ack), BAR_IGU_INTMEM + igu_addr); */
+	DP(BNX2X_MSG_OFF, "write 0x%08x to IGU addr 0x%x\n",
+	   (*(u32 *)&igu_ack), BAR_IGU_INTMEM + igu_addr);
 	REG_WR(bp, BAR_IGU_INTMEM + igu_addr, (*(u32 *)&igu_ack));
 }
 
@@ -614,8 +708,9 @@ static inline int bnx2x_has_work(struct bnx2x_fastpath *fp)
 	if ((rx_cons_sb & MAX_RCQ_DESC_CNT) == MAX_RCQ_DESC_CNT)
 		rx_cons_sb++;
 
-	if ((rx_cons_sb != fp->rx_comp_cons) ||
-	    (le16_to_cpu(*fp->tx_cons_sb) != fp->tx_pkt_cons))
+	if ((fp->rx_comp_cons != rx_cons_sb) ||
+	    (fp->tx_pkt_prod != le16_to_cpu(*fp->tx_cons_sb)) ||
+	    (fp->tx_pkt_prod != fp->tx_pkt_cons))
 		return 1;
 
 	return 0;
@@ -623,11 +718,11 @@ static inline int bnx2x_has_work(struct bnx2x_fastpath *fp)
 
 static u16 bnx2x_ack_int(struct bnx2x *bp)
 {
-	u32 igu_addr = (IGU_ADDR_SIMD_MASK + IGU_PORT_BASE * bp->port) * 8;
+	u32 igu_addr = (IGU_ADDR_SIMD_MASK + IGU_FUNC_BASE * BP_FUNC(bp)) * 8;
 	u32 result = REG_RD(bp, BAR_IGU_INTMEM + igu_addr);
 
-/*      DP(NETIF_MSG_INTR, "read 0x%08x from IGU addr 0x%x\n",
-	   result, BAR_IGU_INTMEM + igu_addr); */
+	DP(BNX2X_MSG_OFF, "read 0x%08x from IGU addr 0x%x\n",
+	   result, BAR_IGU_INTMEM + igu_addr);
 
 #ifdef IGU_DEBUG
 #warning IGU_DEBUG active
@@ -653,7 +748,7 @@ static u16 bnx2x_free_tx_pkt(struct bnx2x *bp, struct bnx2x_fastpath *fp,
 	struct sw_tx_bd *tx_buf = &fp->tx_buf_ring[idx];
 	struct eth_tx_bd *tx_bd;
 	struct sk_buff *skb = tx_buf->skb;
-	u16 bd_idx = tx_buf->first_bd;
+	u16 bd_idx = TX_BD(tx_buf->first_bd), new_cons;
 	int nbd;
 
 	DP(BNX2X_MSG_OFF, "pkt_idx %d  buff @(%p)->skb %p\n",
@@ -666,9 +761,10 @@ static u16 bnx2x_free_tx_pkt(struct bnx2x *bp, struct bnx2x_fastpath *fp,
 			 BD_UNMAP_LEN(tx_bd), PCI_DMA_TODEVICE);
 
 	nbd = le16_to_cpu(tx_bd->nbd) - 1;
+	new_cons = nbd + tx_buf->first_bd;
 #ifdef BNX2X_STOP_ON_ERROR
 	if (nbd > (MAX_SKB_FRAGS + 2)) {
-		BNX2X_ERR("bad nbd!\n");
+		BNX2X_ERR("BAD nbd!\n");
 		bnx2x_panic();
 	}
 #endif
@@ -708,32 +804,30 @@ static u16 bnx2x_free_tx_pkt(struct bnx2x *bp, struct bnx2x_fastpath *fp,
 	tx_buf->first_bd = 0;
 	tx_buf->skb = NULL;
 
-	return bd_idx;
+	return new_cons;
 }
 
-static inline u32 bnx2x_tx_avail(struct bnx2x_fastpath *fp)
+static inline u16 bnx2x_tx_avail(struct bnx2x_fastpath *fp)
 {
-	u16 used;
-	u32 prod;
-	u32 cons;
+	s16 used;
+	u16 prod;
+	u16 cons;
 
-	/* Tell compiler that prod and cons can change */
-	barrier();
+	barrier(); /* Tell compiler that prod and cons can change */
 	prod = fp->tx_bd_prod;
 	cons = fp->tx_bd_cons;
 
-	used = (NUM_TX_BD - NUM_TX_RINGS + prod - cons +
-		(cons / TX_DESC_CNT) - (prod / TX_DESC_CNT));
-
-	if (prod >= cons) {
-		/* used = prod - cons - prod/size + cons/size */
-		used -= NUM_TX_BD - NUM_TX_RINGS;
-	}
+	/* NUM_TX_RINGS = number of "next-page" entries
+	   It will be used as a threshold */
+	used = SUB_S16(prod, cons) + (s16)NUM_TX_RINGS;
 
+#ifdef BNX2X_STOP_ON_ERROR
+	BUG_TRAP(used >= 0);
 	BUG_TRAP(used <= fp->bp->tx_ring_size);
 	BUG_TRAP((fp->bp->tx_ring_size - used) <= MAX_TX_AVAIL);
+#endif
 
-	return (fp->bp->tx_ring_size - used);
+	return (s16)(fp->bp->tx_ring_size) - used;
 }
 
 static void bnx2x_tx_int(struct bnx2x_fastpath *fp, int work)
@@ -757,10 +851,10 @@ static void bnx2x_tx_int(struct bnx2x_fastpath *fp, int work)
 
 		/* prefetch(bp->tx_buf_ring[pkt_cons].skb); */
 
-		DP(NETIF_MSG_TX_DONE, "hw_cons %u  sw_cons %u  pkt_cons %d\n",
+		DP(NETIF_MSG_TX_DONE, "hw_cons %u  sw_cons %u  pkt_cons %u\n",
 		   hw_cons, sw_cons, pkt_cons);
 
-/*      	if (NEXT_TX_IDX(sw_cons) != hw_cons) {
+/*		if (NEXT_TX_IDX(sw_cons) != hw_cons) {
 			rmb();
 			prefetch(fp->tx_buf_ring[NEXT_TX_IDX(sw_cons)].skb);
 		}
@@ -793,7 +887,6 @@ static void bnx2x_tx_int(struct bnx2x_fastpath *fp, int work)
 			netif_wake_queue(bp->dev);
 
 		netif_tx_unlock(bp->dev);
-
 	}
 }
 
@@ -804,13 +897,14 @@ static void bnx2x_sp_event(struct bnx2x_fastpath *fp,
 	int cid = SW_CID(rr_cqe->ramrod_cqe.conn_and_cmd_data);
 	int command = CQE_CMD(rr_cqe->ramrod_cqe.conn_and_cmd_data);
 
-	DP(NETIF_MSG_RX_STATUS,
+	DP(BNX2X_MSG_SP,
 	   "fp %d  cid %d  got ramrod #%d  state is %x  type is %d\n",
-	   fp->index, cid, command, bp->state, rr_cqe->ramrod_cqe.type);
+	   FP_IDX(fp), cid, command, bp->state,
+	   rr_cqe->ramrod_cqe.ramrod_type);
 
 	bp->spq_left++;
 
-	if (fp->index) {
+	if (FP_IDX(fp)) {
 		switch (command | fp->state) {
 		case (RAMROD_CMD_ID_ETH_CLIENT_SETUP |
 						BNX2X_FP_STATE_OPENING):
@@ -826,10 +920,11 @@ static void bnx2x_sp_event(struct bnx2x_fastpath *fp,
 			break;
 
 		default:
-			BNX2X_ERR("unexpected MC reply(%d)  state is %x\n",
-				  command, fp->state);
+			BNX2X_ERR("unexpected MC reply (%d)  "
+				  "fp->state is %x\n", command, fp->state);
+			break;
 		}
-		mb(); /* force bnx2x_wait_ramrod to see the change */
+		mb(); /* force bnx2x_wait_ramrod() to see the change */
 		return;
 	}
 
@@ -846,25 +941,25 @@ static void bnx2x_sp_event(struct bnx2x_fastpath *fp,
 		break;
 
 	case (RAMROD_CMD_ID_ETH_CFC_DEL | BNX2X_STATE_CLOSING_WAIT4_HALT):
-		DP(NETIF_MSG_IFDOWN, "got delete ramrod for MULTI[%d]\n",
-		   cid);
+		DP(NETIF_MSG_IFDOWN, "got delete ramrod for MULTI[%d]\n", cid);
 		bnx2x_fp(bp, cid, state) = BNX2X_FP_STATE_CLOSED;
 		break;
 
 	case (RAMROD_CMD_ID_ETH_SET_MAC | BNX2X_STATE_OPEN):
+	case (RAMROD_CMD_ID_ETH_SET_MAC | BNX2X_STATE_DIAG):
 		DP(NETIF_MSG_IFUP, "got set mac ramrod\n");
 		break;
 
 	case (RAMROD_CMD_ID_ETH_SET_MAC | BNX2X_STATE_CLOSING_WAIT4_HALT):
-		DP(NETIF_MSG_IFUP, "got (un)set mac ramrod\n");
+		DP(NETIF_MSG_IFDOWN, "got (un)set mac ramrod\n");
 		break;
 
 	default:
-		BNX2X_ERR("unexpected ramrod (%d)  state is %x\n",
+		BNX2X_ERR("unexpected MC reply (%d)  bp->state is %x\n",
 			  command, bp->state);
+		break;
 	}
-
-	mb(); /* force bnx2x_wait_ramrod to see the change */
+	mb(); /* force bnx2x_wait_ramrod() to see the change */
 }
 
 static inline int bnx2x_alloc_rx_skb(struct bnx2x *bp,
@@ -882,7 +977,6 @@ static inline int bnx2x_alloc_rx_skb(struct bnx2x *bp,
 	mapping = pci_map_single(bp->pdev, skb->data, bp->rx_buf_use_size,
 				 PCI_DMA_FROMDEVICE);
 	if (unlikely(dma_mapping_error(mapping))) {
-
 		dev_kfree_skb(skb);
 		return -ENOMEM;
 	}
@@ -924,7 +1018,7 @@ static void bnx2x_reuse_rx_skb(struct bnx2x_fastpath *fp,
 static int bnx2x_rx_int(struct bnx2x_fastpath *fp, int budget)
 {
 	struct bnx2x *bp = fp->bp;
-	u16 bd_cons, bd_prod, comp_ring_cons;
+	u16 bd_cons, bd_prod, bd_prod_fw, comp_ring_cons;
 	u16 hw_comp_cons, sw_comp_cons, sw_comp_prod;
 	int rx_pkt = 0;
 
@@ -933,12 +1027,15 @@ static int bnx2x_rx_int(struct bnx2x_fastpath *fp, int budget)
 		return 0;
 #endif
 
+	/* CQ "next element" is of the size of the regular element,
+	   that's why it's ok here */
 	hw_comp_cons = le16_to_cpu(*fp->rx_cons_sb);
 	if ((hw_comp_cons & MAX_RCQ_DESC_CNT) == MAX_RCQ_DESC_CNT)
 		hw_comp_cons++;
 
 	bd_cons = fp->rx_bd_cons;
 	bd_prod = fp->rx_bd_prod;
+	bd_prod_fw = bd_prod;
 	sw_comp_cons = fp->rx_comp_cons;
 	sw_comp_prod = fp->rx_comp_prod;
 
@@ -949,34 +1046,31 @@ static int bnx2x_rx_int(struct bnx2x_fastpath *fp, int budget)
 
 	DP(NETIF_MSG_RX_STATUS,
 	   "queue[%d]:  hw_comp_cons %u  sw_comp_cons %u\n",
-	   fp->index, hw_comp_cons, sw_comp_cons);
+	   FP_IDX(fp), hw_comp_cons, sw_comp_cons);
 
 	while (sw_comp_cons != hw_comp_cons) {
-		unsigned int len, pad;
-		struct sw_rx_bd *rx_buf;
+		struct sw_rx_bd *rx_buf = NULL;
 		struct sk_buff *skb;
 		union eth_rx_cqe *cqe;
+		u8 cqe_fp_flags;
+		u16 len, pad;
 
 		comp_ring_cons = RCQ_BD(sw_comp_cons);
 		bd_prod = RX_BD(bd_prod);
 		bd_cons = RX_BD(bd_cons);
 
 		cqe = &fp->rx_comp_ring[comp_ring_cons];
+		cqe_fp_flags = cqe->fast_path_cqe.type_error_flags;
 
-		DP(NETIF_MSG_RX_STATUS, "hw_comp_cons %u  sw_comp_cons %u"
-		   "  comp_ring (%u)  bd_ring (%u,%u)\n",
-		   hw_comp_cons, sw_comp_cons,
-		   comp_ring_cons, bd_prod, bd_cons);
 		DP(NETIF_MSG_RX_STATUS, "CQE type %x  err %x  status %x"
-		   "  queue %x  vlan %x  len %x\n",
-		   cqe->fast_path_cqe.type,
-		   cqe->fast_path_cqe.error_type_flags,
-		   cqe->fast_path_cqe.status_flags,
+		   "  queue %x  vlan %x  len %u\n", CQE_TYPE(cqe_fp_flags),
+		   cqe_fp_flags, cqe->fast_path_cqe.status_flags,
 		   cqe->fast_path_cqe.rss_hash_result,
-		   cqe->fast_path_cqe.vlan_tag, cqe->fast_path_cqe.pkt_len);
+		   le16_to_cpu(cqe->fast_path_cqe.vlan_tag),
+		   le16_to_cpu(cqe->fast_path_cqe.pkt_len));
 
 		/* is this a slowpath msg? */
-		if (unlikely(cqe->fast_path_cqe.type)) {
+		if (unlikely(CQE_TYPE(cqe_fp_flags))) {
 			bnx2x_sp_event(fp, cqe);
 			goto next_cqe;
 
@@ -984,7 +1078,6 @@ static int bnx2x_rx_int(struct bnx2x_fastpath *fp, int budget)
 		} else {
 			rx_buf = &fp->rx_buf_ring[bd_cons];
 			skb = rx_buf->skb;
-
 			len = le16_to_cpu(cqe->fast_path_cqe.pkt_len);
 			pad = cqe->fast_path_cqe.placement_offset;
 
@@ -996,13 +1089,11 @@ static int bnx2x_rx_int(struct bnx2x_fastpath *fp, int budget)
 			prefetch(((char *)(skb)) + 128);
 
 			/* is this an error packet? */
-			if (unlikely(cqe->fast_path_cqe.error_type_flags &
-							ETH_RX_ERROR_FALGS)) {
+			if (unlikely(cqe_fp_flags & ETH_RX_ERROR_FALGS)) {
 			/* do we sometimes forward error packets anyway? */
 				DP(NETIF_MSG_RX_ERR,
-				   "ERROR flags(%u) Rx packet(%u)\n",
-				   cqe->fast_path_cqe.error_type_flags,
-				   sw_comp_cons);
+				   "ERROR  flags %x  rx packet %u\n",
+				   cqe_fp_flags, sw_comp_cons);
 				/* TBD make sure MC counts this as a drop */
 				goto reuse_rx;
 			}
@@ -1018,7 +1109,7 @@ static int bnx2x_rx_int(struct bnx2x_fastpath *fp, int budget)
 							   len + pad);
 				if (new_skb == NULL) {
 					DP(NETIF_MSG_RX_ERR,
-					   "ERROR packet dropped "
+					   "ERROR  packet dropped "
 					   "because of alloc failure\n");
 					/* TBD count this as a drop? */
 					goto reuse_rx;
@@ -1044,7 +1135,7 @@ static int bnx2x_rx_int(struct bnx2x_fastpath *fp, int budget)
 
 			} else {
 				DP(NETIF_MSG_RX_ERR,
-				   "ERROR packet dropped because "
+				   "ERROR  packet dropped because "
 				   "of alloc failure\n");
 reuse_rx:
 				bnx2x_reuse_rx_skb(fp, skb, bd_cons, bd_prod);
@@ -1061,14 +1152,14 @@ reuse_rx:
 		}
 
 #ifdef BCM_VLAN
-		if ((le16_to_cpu(cqe->fast_path_cqe.pars_flags.flags)
-				& PARSING_FLAGS_NUMBER_OF_NESTED_VLANS)
-		    && (bp->vlgrp != NULL))
+		if ((bp->vlgrp != NULL) &&
+		    (le16_to_cpu(cqe->fast_path_cqe.pars_flags.flags) &
+		     PARSING_FLAGS_VLAN))
 			vlan_hwaccel_receive_skb(skb, bp->vlgrp,
 				le16_to_cpu(cqe->fast_path_cqe.vlan_tag));
 		else
 #endif
-		netif_receive_skb(skb);
+			netif_receive_skb(skb);
 
 		bp->dev->last_rx = jiffies;
 
@@ -1077,22 +1168,25 @@ next_rx:
 
 		bd_cons = NEXT_RX_IDX(bd_cons);
 		bd_prod = NEXT_RX_IDX(bd_prod);
+		bd_prod_fw = NEXT_RX_IDX(bd_prod_fw);
+		rx_pkt++;
 next_cqe:
 		sw_comp_prod = NEXT_RCQ_IDX(sw_comp_prod);
 		sw_comp_cons = NEXT_RCQ_IDX(sw_comp_cons);
-		rx_pkt++;
 
-		if ((rx_pkt == budget))
+		if (rx_pkt == budget)
 			break;
 	} /* while */
 
 	fp->rx_bd_cons = bd_cons;
-	fp->rx_bd_prod = bd_prod;
+	fp->rx_bd_prod = bd_prod_fw;
 	fp->rx_comp_cons = sw_comp_cons;
 	fp->rx_comp_prod = sw_comp_prod;
 
 	REG_WR(bp, BAR_TSTRORM_INTMEM +
-	       TSTORM_RCQ_PROD_OFFSET(bp->port, fp->index), sw_comp_prod);
+		TSTORM_RX_PRODS_OFFSET(BP_PORT(bp), FP_CL_ID(fp)),
+		sw_comp_prod);
+
 
 	mmiowb(); /* keep prod updates ordered */
 
@@ -1107,10 +1201,11 @@ static irqreturn_t bnx2x_msix_fp_int(int irq, void *fp_cookie)
 	struct bnx2x_fastpath *fp = fp_cookie;
 	struct bnx2x *bp = fp->bp;
 	struct net_device *dev = bp->dev;
-	int index = fp->index;
+	int index = FP_IDX(fp);
 
-	DP(NETIF_MSG_INTR, "got an msix interrupt on [%d]\n", index);
-	bnx2x_ack_sb(bp, index, USTORM_ID, 0, IGU_INT_DISABLE, 0);
+	DP(BNX2X_MSG_FP, "got an MSI-X interrupt on IDX:SB [%d:%d]\n",
+	   index, FP_SB_ID(fp));
+	bnx2x_ack_sb(bp, FP_SB_ID(fp), USTORM_ID, 0, IGU_INT_DISABLE, 0);
 
 #ifdef BNX2X_STOP_ON_ERROR
 	if (unlikely(bp->panic))
@@ -1123,6 +1218,7 @@ static irqreturn_t bnx2x_msix_fp_int(int irq, void *fp_cookie)
 	prefetch(&fp->status_blk->u_status_block.status_block_index);
 
 	netif_rx_schedule(dev, &bnx2x_fp(bp, index, napi));
+
 	return IRQ_HANDLED;
 }
 
@@ -1131,26 +1227,28 @@ static irqreturn_t bnx2x_interrupt(int irq, void *dev_instance)
 	struct net_device *dev = dev_instance;
 	struct bnx2x *bp = netdev_priv(dev);
 	u16 status = bnx2x_ack_int(bp);
+	u16 mask;
 
+	/* Return here if interrupt is shared and it's not for us */
 	if (unlikely(status == 0)) {
 		DP(NETIF_MSG_INTR, "not our interrupt!\n");
 		return IRQ_NONE;
 	}
-
-	DP(NETIF_MSG_INTR, "got an interrupt status is %u\n", status);
+	DP(NETIF_MSG_INTR, "got an interrupt  status %u\n", status);
 
 #ifdef BNX2X_STOP_ON_ERROR
 	if (unlikely(bp->panic))
 		return IRQ_HANDLED;
 #endif
 
-	/* Return here if interrupt is shared and is disabled */
+	/* Return here if interrupt is disabled */
 	if (unlikely(atomic_read(&bp->intr_sem) != 0)) {
 		DP(NETIF_MSG_INTR, "called but intr_sem not 0, returning\n");
 		return IRQ_HANDLED;
 	}
 
-	if (status & 0x2) {
+	mask = 0x2 << bp->fp[0].sb_id;
+	if (status & mask) {
 		struct bnx2x_fastpath *fp = &bp->fp[0];
 
 		prefetch(fp->rx_cons_sb);
@@ -1160,13 +1258,11 @@ static irqreturn_t bnx2x_interrupt(int irq, void *dev_instance)
 
 		netif_rx_schedule(dev, &bnx2x_fp(bp, 0, napi));
 
-		status &= ~0x2;
-		if (!status)
-			return IRQ_HANDLED;
+		status &= ~mask;
 	}
 
-	if (unlikely(status & 0x1)) {
 
+	if (unlikely(status & 0x1)) {
 		schedule_work(&bp->sp_task);
 
 		status &= ~0x1;
@@ -1174,8 +1270,9 @@ static irqreturn_t bnx2x_interrupt(int irq, void *dev_instance)
 			return IRQ_HANDLED;
 	}
 
-	DP(NETIF_MSG_INTR, "got an unknown interrupt! (status is %u)\n",
-	   status);
+	if (status)
+		DP(NETIF_MSG_INTR, "got an unknown interrupt! (status %u)\n",
+		   status);
 
 	return IRQ_HANDLED;
 }
@@ -1193,7 +1290,7 @@ static int bnx2x_hw_lock(struct bnx2x *bp, u32 resource)
 {
 	u32 lock_status;
 	u32 resource_bit = (1 << resource);
-	u8 port = bp->port;
+	u8 port = BP_PORT(bp);
 	int cnt;
 
 	/* Validating that the resource is within range */
@@ -1231,7 +1328,7 @@ static int bnx2x_hw_unlock(struct bnx2x *bp, u32 resource)
 {
 	u32 lock_status;
 	u32 resource_bit = (1 << resource);
-	u8 port = bp->port;
+	u8 port = BP_PORT(bp);
 
 	/* Validating that the resource is within range */
 	if (resource > HW_LOCK_MAX_RESOURCE_VALUE) {
@@ -1258,7 +1355,7 @@ static void bnx2x_phy_hw_lock(struct bnx2x *bp)
 {
 	u32 ext_phy_type = XGXS_EXT_PHY_TYPE(bp->link_params.ext_phy_config);
 
-	mutex_lock(&bp->phy_mutex);
+	mutex_lock(&bp->port.phy_mutex);
 
 	if ((ext_phy_type == PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8072) ||
 	    (ext_phy_type == PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8073))
@@ -1273,14 +1370,14 @@ static void bnx2x_phy_hw_unlock(struct bnx2x *bp)
 	    (ext_phy_type == PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8073))
 		bnx2x_hw_unlock(bp, HW_LOCK_RESOURCE_8072_MDIO);
 
-	mutex_unlock(&bp->phy_mutex);
+	mutex_unlock(&bp->port.phy_mutex);
 }
 
 int bnx2x_set_gpio(struct bnx2x *bp, int gpio_num, u32 mode)
 {
 	/* The GPIO should be swapped if swap register is set and active */
 	int gpio_port = (REG_RD(bp, NIG_REG_PORT_SWAP) &&
-			 REG_RD(bp, NIG_REG_STRAP_OVERRIDE)) ^ bp->port;
+			 REG_RD(bp, NIG_REG_STRAP_OVERRIDE)) ^ BP_PORT(bp);
 	int gpio_shift = gpio_num +
 			(gpio_port ? MISC_REGISTERS_GPIO_PORT_SHIFT : 0);
 	u32 gpio_mask = (1 << gpio_shift);
@@ -1379,18 +1476,18 @@ static void bnx2x_calc_fc_adv(struct bnx2x *bp)
 {
 	switch (bp->link_vars.ieee_fc) {
 	case MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_NONE:
-		bp->advertising &= ~(ADVERTISED_Asym_Pause |
+		bp->port.advertising &= ~(ADVERTISED_Asym_Pause |
 					  ADVERTISED_Pause);
 		break;
 	case MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_BOTH:
-		bp->advertising |= (ADVERTISED_Asym_Pause |
+		bp->port.advertising |= (ADVERTISED_Asym_Pause |
 					 ADVERTISED_Pause);
 		break;
 	case MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_ASYMMETRIC:
-		bp->advertising |= ADVERTISED_Asym_Pause;
+		bp->port.advertising |= ADVERTISED_Asym_Pause;
 		break;
 	default:
-		bp->advertising &= ~(ADVERTISED_Asym_Pause |
+		bp->port.advertising &= ~(ADVERTISED_Asym_Pause |
 					  ADVERTISED_Pause);
 		break;
 	}
@@ -1443,6 +1540,7 @@ static u8 bnx2x_initial_phy_init(struct bnx2x *bp)
 		bnx2x_link_report(bp);
 
 	bnx2x_calc_fc_adv(bp);
+
 	return rc;
 }
 
@@ -1473,15 +1571,261 @@ static u8 bnx2x_link_test(struct bnx2x *bp)
 	return rc;
 }
 
+/* Calculates the sum of vn_min_rates.
+   It's needed for further normalizing of the min_rates.
+
+   Returns:
+     sum of vn_min_rates
+       or
+     0 - if all the min_rates are 0.
+     In the later case fainess algorithm should be deactivated.
+     If not all min_rates are zero then those that are zeroes will
+     be set to 1.
+ */
+static u32 bnx2x_calc_vn_wsum(struct bnx2x *bp)
+{
+	int i, port = BP_PORT(bp);
+	u32 wsum = 0;
+	int all_zero = 1;
+
+	for (i = 0; i < E1HVN_MAX; i++) {
+		u32 vn_cfg =
+			SHMEM_RD(bp, mf_cfg.func_mf_config[2*i + port].config);
+		u32 vn_min_rate = ((vn_cfg & FUNC_MF_CFG_MIN_BW_MASK) >>
+				     FUNC_MF_CFG_MIN_BW_SHIFT) * 100;
+		if (!(vn_cfg & FUNC_MF_CFG_FUNC_HIDE)) {
+			/* If min rate is zero - set it to 1 */
+			if (!vn_min_rate)
+				vn_min_rate = DEF_MIN_RATE;
+			else
+				all_zero = 0;
+
+			wsum += vn_min_rate;
+		}
+	}
+
+	/* ... only if all min rates are zeros - disable FAIRNESS */
+	if (all_zero)
+		return 0;
+
+	return wsum;
+}
+
+static void bnx2x_init_port_minmax(struct bnx2x *bp,
+				   int en_fness,
+				   u16 port_rate,
+				   struct cmng_struct_per_port *m_cmng_port)
+{
+	u32 r_param = port_rate / 8;
+	int port = BP_PORT(bp);
+	int i;
+
+	memset(m_cmng_port, 0, sizeof(struct cmng_struct_per_port));
+
+	/* Enable minmax only if we are in e1hmf mode */
+	if (IS_E1HMF(bp)) {
+		u32 fair_periodic_timeout_usec;
+		u32 t_fair;
+
+		/* Enable rate shaping and fairness */
+		m_cmng_port->flags.cmng_vn_enable = 1;
+		m_cmng_port->flags.fairness_enable = en_fness ? 1 : 0;
+		m_cmng_port->flags.rate_shaping_enable = 1;
+
+		if (!en_fness)
+			DP(NETIF_MSG_IFUP, "All MIN values are zeroes"
+			   "  fairness will be disabled\n");
+
+		/* 100 usec in SDM ticks = 25 since each tick is 4 usec */
+		m_cmng_port->rs_vars.rs_periodic_timeout =
+						RS_PERIODIC_TIMEOUT_USEC / 4;
+
+		/* this is the threshold below which no timer arming will occur
+		   1.25 coefficient is for the threshold to be a little bigger
+		   than the real time, to compensate for timer in-accuracy */
+		m_cmng_port->rs_vars.rs_threshold =
+				(RS_PERIODIC_TIMEOUT_USEC * r_param * 5) / 4;
+
+		/* resolution of fairness timer */
+		fair_periodic_timeout_usec = QM_ARB_BYTES / r_param;
+		/* for 10G it is 1000usec. for 1G it is 10000usec. */
+		t_fair = T_FAIR_COEF / port_rate;
+
+		/* this is the threshold below which we won't arm
+		   the timer anymore */
+		m_cmng_port->fair_vars.fair_threshold = QM_ARB_BYTES;
+
+		/* we multiply by 1e3/8 to get bytes/msec.
+		   We don't want the credits to pass a credit
+		   of the T_FAIR*FAIR_MEM (algorithm resolution) */
+		m_cmng_port->fair_vars.upper_bound =
+						r_param * t_fair * FAIR_MEM;
+		/* since each tick is 4 usec */
+		m_cmng_port->fair_vars.fairness_timeout =
+						fair_periodic_timeout_usec / 4;
+
+	} else {
+		/* Disable rate shaping and fairness */
+		m_cmng_port->flags.cmng_vn_enable = 0;
+		m_cmng_port->flags.fairness_enable = 0;
+		m_cmng_port->flags.rate_shaping_enable = 0;
+
+		DP(NETIF_MSG_IFUP,
+		   "Single function mode  minmax will be disabled\n");
+	}
+
+	/* Store it to internal memory */
+	for (i = 0; i < sizeof(struct cmng_struct_per_port) / 4; i++)
+		REG_WR(bp, BAR_XSTRORM_INTMEM +
+		       XSTORM_CMNG_PER_PORT_VARS_OFFSET(port) + i * 4,
+		       ((u32 *)(m_cmng_port))[i]);
+}
+
+static void bnx2x_init_vn_minmax(struct bnx2x *bp, int func,
+				   u32 wsum, u16 port_rate,
+				 struct cmng_struct_per_port *m_cmng_port)
+{
+	struct rate_shaping_vars_per_vn m_rs_vn;
+	struct fairness_vars_per_vn m_fair_vn;
+	u32 vn_cfg = SHMEM_RD(bp, mf_cfg.func_mf_config[func].config);
+	u16 vn_min_rate, vn_max_rate;
+	int i;
+
+	/* If function is hidden - set min and max to zeroes */
+	if (vn_cfg & FUNC_MF_CFG_FUNC_HIDE) {
+		vn_min_rate = 0;
+		vn_max_rate = 0;
+
+	} else {
+		vn_min_rate = ((vn_cfg & FUNC_MF_CFG_MIN_BW_MASK) >>
+				FUNC_MF_CFG_MIN_BW_SHIFT) * 100;
+		/* If FAIRNESS is enabled (not all min rates are zeroes) and
+		   if current min rate is zero - set it to 1.
+		   This is a requirment of the algorithm. */
+		if ((vn_min_rate == 0) && wsum)
+			vn_min_rate = DEF_MIN_RATE;
+		vn_max_rate = ((vn_cfg & FUNC_MF_CFG_MAX_BW_MASK) >>
+				FUNC_MF_CFG_MAX_BW_SHIFT) * 100;
+	}
+
+	DP(NETIF_MSG_IFUP, "func %d: vn_min_rate=%d  vn_max_rate=%d  "
+	   "wsum=%d\n", func, vn_min_rate, vn_max_rate, wsum);
+
+	memset(&m_rs_vn, 0, sizeof(struct rate_shaping_vars_per_vn));
+	memset(&m_fair_vn, 0, sizeof(struct fairness_vars_per_vn));
+
+	/* global vn counter - maximal Mbps for this vn */
+	m_rs_vn.vn_counter.rate = vn_max_rate;
+
+	/* quota - number of bytes transmitted in this period */
+	m_rs_vn.vn_counter.quota =
+				(vn_max_rate * RS_PERIODIC_TIMEOUT_USEC) / 8;
+
+#ifdef BNX2X_PER_PROT_QOS
+	/* per protocol counter */
+	for (protocol = 0; protocol < NUM_OF_PROTOCOLS; protocol++) {
+		/* maximal Mbps for this protocol */
+		m_rs_vn.protocol_counters[protocol].rate =
+						protocol_max_rate[protocol];
+		/* the quota in each timer period -
+		   number of bytes transmitted in this period */
+		m_rs_vn.protocol_counters[protocol].quota =
+			(u32)(rs_periodic_timeout_usec *
+			  ((double)m_rs_vn.
+				   protocol_counters[protocol].rate/8));
+	}
+#endif
+
+	if (wsum) {
+		/* credit for each period of the fairness algorithm:
+		   number of bytes in T_FAIR (the vn share the port rate).
+		   wsum should not be larger than 10000, thus
+		   T_FAIR_COEF / (8 * wsum) will always be grater than zero */
+		m_fair_vn.vn_credit_delta =
+			max((u64)(vn_min_rate * (T_FAIR_COEF / (8 * wsum))),
+			    (u64)(m_cmng_port->fair_vars.fair_threshold * 2));
+		DP(NETIF_MSG_IFUP, "m_fair_vn.vn_credit_delta=%d\n",
+		   m_fair_vn.vn_credit_delta);
+	}
+
+#ifdef BNX2X_PER_PROT_QOS
+	do {
+		u32 protocolWeightSum = 0;
+
+		for (protocol = 0; protocol < NUM_OF_PROTOCOLS; protocol++)
+			protocolWeightSum +=
+					drvInit.protocol_min_rate[protocol];
+		/* per protocol counter -
+		   NOT NEEDED IF NO PER-PROTOCOL CONGESTION MANAGEMENT */
+		if (protocolWeightSum > 0) {
+			for (protocol = 0;
+			     protocol < NUM_OF_PROTOCOLS; protocol++)
+				/* credit for each period of the
+				   fairness algorithm - number of bytes in
+				   T_FAIR (the protocol share the vn rate) */
+				m_fair_vn.protocol_credit_delta[protocol] =
+					(u32)((vn_min_rate / 8) * t_fair *
+					protocol_min_rate / protocolWeightSum);
+		}
+	} while (0);
+#endif
+
+	/* Store it to internal memory */
+	for (i = 0; i < sizeof(struct rate_shaping_vars_per_vn)/4; i++)
+		REG_WR(bp, BAR_XSTRORM_INTMEM +
+		       XSTORM_RATE_SHAPING_PER_VN_VARS_OFFSET(func) + i * 4,
+		       ((u32 *)(&m_rs_vn))[i]);
+
+	for (i = 0; i < sizeof(struct fairness_vars_per_vn)/4; i++)
+		REG_WR(bp, BAR_XSTRORM_INTMEM +
+		       XSTORM_FAIRNESS_PER_VN_VARS_OFFSET(func) + i * 4,
+		       ((u32 *)(&m_fair_vn))[i]);
+}
+
 /* This function is called upon link interrupt */
 static void bnx2x_link_attn(struct bnx2x *bp)
 {
+	int vn;
+
 	bnx2x_phy_hw_lock(bp);
 	bnx2x_link_update(&bp->link_params, &bp->link_vars);
 	bnx2x_phy_hw_unlock(bp);
 
 	/* indicate link status */
 	bnx2x_link_report(bp);
+
+	if (IS_E1HMF(bp)) {
+		int func;
+
+		for (vn = VN_0; vn < E1HVN_MAX; vn++) {
+			if (vn == BP_E1HVN(bp))
+				continue;
+
+			func = ((vn << 1) | BP_PORT(bp));
+
+			/* Set the attention towards other drivers
+			   on the same port */
+			REG_WR(bp, MISC_REG_AEU_GENERAL_ATTN_0 +
+			       (LINK_SYNC_ATTENTION_BIT_FUNC_0 + func)*4, 1);
+		}
+	}
+
+	if (CHIP_IS_E1H(bp) && (bp->link_vars.line_speed > 0)) {
+		struct cmng_struct_per_port m_cmng_port;
+		u32 wsum;
+		int port = BP_PORT(bp);
+
+		/* Init RATE SHAPING and FAIRNESS contexts */
+		wsum = bnx2x_calc_vn_wsum(bp);
+		bnx2x_init_port_minmax(bp, (int)wsum,
+					bp->link_vars.line_speed,
+					&m_cmng_port);
+		if (IS_E1HMF(bp))
+			for (vn = VN_0; vn < E1HVN_MAX; vn++)
+				bnx2x_init_vn_minmax(bp, 2*vn + port,
+					wsum, bp->link_vars.line_speed,
+						     &m_cmng_port);
+	}
 }
 
 static void bnx2x__link_status_update(struct bnx2x *bp)
@@ -1495,6 +1839,20 @@ static void bnx2x__link_status_update(struct bnx2x *bp)
 	bnx2x_link_report(bp);
 }
 
+static void bnx2x_pmf_update(struct bnx2x *bp)
+{
+	int port = BP_PORT(bp);
+	u32 val;
+
+	bp->port.pmf = 1;
+	DP(NETIF_MSG_LINK, "pmf %d\n", bp->port.pmf);
+
+	/* enable nig attention */
+	val = (0xff0f | (1 << (BP_E1HVN(bp) + 4)));
+	REG_WR(bp, HC_REG_TRAILING_EDGE_0 + port*8, val);
+	REG_WR(bp, HC_REG_LEADING_EDGE_0 + port*8, val);
+}
+
 /* end of Link */
 
 /* slow path */
@@ -1507,10 +1865,10 @@ static void bnx2x__link_status_update(struct bnx2x *bp)
 static int bnx2x_sp_post(struct bnx2x *bp, int command, int cid,
 			 u32 data_hi, u32 data_lo, int common)
 {
-	int port = bp->port;
+	int func = BP_FUNC(bp);
 
-	DP(NETIF_MSG_TIMER,
-	   "spe (%x:%x)  command %d  hw_cid %x  data (%x:%x)  left %x\n",
+	DP(BNX2X_MSG_SP/*NETIF_MSG_TIMER*/,
+	   "SPQE (%x:%x)  command %d  hw_cid %x  data (%x:%x)  left %x\n",
 	   (u32)U64_HI(bp->spq_mapping), (u32)(U64_LO(bp->spq_mapping) +
 	   (void *)bp->spq_prod_bd - (void *)bp->spq), command,
 	   HW_CID(bp, cid), data_hi, data_lo, bp->spq_left);
@@ -1520,11 +1878,11 @@ static int bnx2x_sp_post(struct bnx2x *bp, int command, int cid,
 		return -EIO;
 #endif
 
-	spin_lock(&bp->spq_lock);
+	spin_lock_bh(&bp->spq_lock);
 
 	if (!bp->spq_left) {
 		BNX2X_ERR("BUG! SPQ ring full!\n");
-		spin_unlock(&bp->spq_lock);
+		spin_unlock_bh(&bp->spq_lock);
 		bnx2x_panic();
 		return -EBUSY;
 	}
@@ -1553,18 +1911,18 @@ static int bnx2x_sp_post(struct bnx2x *bp, int command, int cid,
 		bp->spq_prod_idx++;
 	}
 
-	REG_WR(bp, BAR_XSTRORM_INTMEM + XSTORM_SPQ_PROD_OFFSET(port),
+	REG_WR(bp, BAR_XSTRORM_INTMEM + XSTORM_SPQ_PROD_OFFSET(func),
 	       bp->spq_prod_idx);
 
-	spin_unlock(&bp->spq_lock);
+	spin_unlock_bh(&bp->spq_lock);
 	return 0;
 }
 
 /* acquire split MCP access lock register */
 static int bnx2x_lock_alr(struct bnx2x *bp)
 {
-	int rc = 0;
 	u32 i, j, val;
+	int rc = 0;
 
 	might_sleep();
 	i = 100;
@@ -1577,10 +1935,8 @@ static int bnx2x_lock_alr(struct bnx2x *bp)
 
 		msleep(5);
 	}
-
 	if (!(val & (1L << 31))) {
 		BNX2X_ERR("Cannot acquire nvram interface\n");
-
 		rc = -EBUSY;
 	}
 
@@ -1631,8 +1987,9 @@ static inline u16 bnx2x_update_dsb_idx(struct bnx2x *bp)
 
 static void bnx2x_attn_int_asserted(struct bnx2x *bp, u32 asserted)
 {
-	int port = bp->port;
-	u32 igu_addr = (IGU_ADDR_ATTN_BITS_SET + IGU_PORT_BASE * port) * 8;
+	int port = BP_PORT(bp);
+	int func = BP_FUNC(bp);
+	u32 igu_addr = (IGU_ADDR_ATTN_BITS_SET + IGU_FUNC_BASE * func) * 8;
 	u32 aeu_addr = port ? MISC_REG_AEU_MASK_ATTN_FUNC_1 :
 			      MISC_REG_AEU_MASK_ATTN_FUNC_0;
 	u32 nig_int_mask_addr = port ? NIG_REG_MASK_INTERRUPT_PORT1 :
@@ -1716,14 +2073,14 @@ static void bnx2x_attn_int_asserted(struct bnx2x *bp, u32 asserted)
 
 static inline void bnx2x_attn_int_deasserted0(struct bnx2x *bp, u32 attn)
 {
-	int port = bp->port;
+	int port = BP_PORT(bp);
 	int reg_offset;
 	u32 val;
 
-	if (attn & AEU_INPUTS_ATTN_BITS_SPIO5) {
+	reg_offset = (port ? MISC_REG_AEU_ENABLE1_FUNC_1_OUT_0 :
+			     MISC_REG_AEU_ENABLE1_FUNC_0_OUT_0);
 
-		reg_offset = (port ? MISC_REG_AEU_ENABLE1_FUNC_1_OUT_0 :
-				     MISC_REG_AEU_ENABLE1_FUNC_0_OUT_0);
+	if (attn & AEU_INPUTS_ATTN_BITS_SPIO5) {
 
 		val = REG_RD(bp, reg_offset);
 		val &= ~AEU_INPUTS_ATTN_BITS_SPIO5;
@@ -1731,7 +2088,7 @@ static inline void bnx2x_attn_int_deasserted0(struct bnx2x *bp, u32 attn)
 
 		BNX2X_ERR("SPIO5 hw attention\n");
 
-		switch (bp->board & SHARED_HW_CFG_BOARD_TYPE_MASK) {
+		switch (bp->common.board & SHARED_HW_CFG_BOARD_TYPE_MASK) {
 		case SHARED_HW_CFG_BOARD_TYPE_BCM957710A1022G:
 			/* Fan failure attention */
 
@@ -1762,6 +2119,17 @@ static inline void bnx2x_attn_int_deasserted0(struct bnx2x *bp, u32 attn)
 			break;
 		}
 	}
+
+	if (attn & HW_INTERRUT_ASSERT_SET_0) {
+
+		val = REG_RD(bp, reg_offset);
+		val &= ~(attn & HW_INTERRUT_ASSERT_SET_0);
+		REG_WR(bp, reg_offset, val);
+
+		BNX2X_ERR("FATAL HW block attention set0 0x%x\n",
+			  (attn & HW_INTERRUT_ASSERT_SET_0));
+		bnx2x_panic();
+	}
 }
 
 static inline void bnx2x_attn_int_deasserted1(struct bnx2x *bp, u32 attn)
@@ -1776,6 +2144,23 @@ static inline void bnx2x_attn_int_deasserted1(struct bnx2x *bp, u32 attn)
 		if (val & 0x2)
 			BNX2X_ERR("FATAL error from DORQ\n");
 	}
+
+	if (attn & HW_INTERRUT_ASSERT_SET_1) {
+
+		int port = BP_PORT(bp);
+		int reg_offset;
+
+		reg_offset = (port ? MISC_REG_AEU_ENABLE1_FUNC_1_OUT_1 :
+				     MISC_REG_AEU_ENABLE1_FUNC_0_OUT_1);
+
+		val = REG_RD(bp, reg_offset);
+		val &= ~(attn & HW_INTERRUT_ASSERT_SET_1);
+		REG_WR(bp, reg_offset, val);
+
+		BNX2X_ERR("FATAL HW block attention set1 0x%x\n",
+			  (attn & HW_INTERRUT_ASSERT_SET_1));
+		bnx2x_panic();
+	}
 }
 
 static inline void bnx2x_attn_int_deasserted2(struct bnx2x *bp, u32 attn)
@@ -1799,13 +2184,41 @@ static inline void bnx2x_attn_int_deasserted2(struct bnx2x *bp, u32 attn)
 		if (val & 0x18000)
 			BNX2X_ERR("FATAL error from PXP\n");
 	}
+
+	if (attn & HW_INTERRUT_ASSERT_SET_2) {
+
+		int port = BP_PORT(bp);
+		int reg_offset;
+
+		reg_offset = (port ? MISC_REG_AEU_ENABLE1_FUNC_1_OUT_2 :
+				     MISC_REG_AEU_ENABLE1_FUNC_0_OUT_2);
+
+		val = REG_RD(bp, reg_offset);
+		val &= ~(attn & HW_INTERRUT_ASSERT_SET_2);
+		REG_WR(bp, reg_offset, val);
+
+		BNX2X_ERR("FATAL HW block attention set2 0x%x\n",
+			  (attn & HW_INTERRUT_ASSERT_SET_2));
+		bnx2x_panic();
+	}
 }
 
 static inline void bnx2x_attn_int_deasserted3(struct bnx2x *bp, u32 attn)
 {
+	u32 val;
+
 	if (attn & EVEREST_GEN_ATTN_IN_USE_MASK) {
 
-		if (attn & BNX2X_MC_ASSERT_BITS) {
+		if (attn & BNX2X_PMF_LINK_ASSERT) {
+			int func = BP_FUNC(bp);
+
+			REG_WR(bp, MISC_REG_AEU_GENERAL_ATTN_12 + func*4, 0);
+			bnx2x__link_status_update(bp);
+			if (SHMEM_RD(bp, func_mb[func].drv_status) &
+							DRV_STATUS_PMF)
+				bnx2x_pmf_update(bp);
+
+		} else if (attn & BNX2X_MC_ASSERT_BITS) {
 
 			BNX2X_ERR("MC assert!\n");
 			REG_WR(bp, MISC_REG_AEU_GENERAL_ATTN_10, 0);
@@ -1818,16 +2231,25 @@ static inline void bnx2x_attn_int_deasserted3(struct bnx2x *bp, u32 attn)
 
 			BNX2X_ERR("MCP assert!\n");
 			REG_WR(bp, MISC_REG_AEU_GENERAL_ATTN_11, 0);
-			bnx2x_mc_assert(bp);
+			bnx2x_fw_dump(bp);
 
 		} else
 			BNX2X_ERR("Unknown HW assert! (attn 0x%x)\n", attn);
 	}
 
 	if (attn & EVEREST_LATCHED_ATTN_IN_USE_MASK) {
-
+		BNX2X_ERR("LATCHED attention 0x%08x (masked)\n", attn);
+		if (attn & BNX2X_GRC_TIMEOUT) {
+			val = CHIP_IS_E1H(bp) ?
+				REG_RD(bp, MISC_REG_GRC_TIMEOUT_ATTN) : 0;
+			BNX2X_ERR("GRC time-out 0x%08x\n", val);
+		}
+		if (attn & BNX2X_GRC_RSV) {
+			val = CHIP_IS_E1H(bp) ?
+				REG_RD(bp, MISC_REG_GRC_RSV_ATTN) : 0;
+			BNX2X_ERR("GRC reserved 0x%08x\n", val);
+		}
 		REG_WR(bp, MISC_REG_AEU_CLR_LATCH_SIGNAL, 0x7ff);
-		BNX2X_ERR("LATCHED attention 0x%x (masked)\n", attn);
 	}
 }
 
@@ -1835,7 +2257,7 @@ static void bnx2x_attn_int_deasserted(struct bnx2x *bp, u32 deasserted)
 {
 	struct attn_route attn;
 	struct attn_route group_mask;
-	int port = bp->port;
+	int port = BP_PORT(bp);
 	int index;
 	u32 reg_addr;
 	u32 val;
@@ -1848,14 +2270,16 @@ static void bnx2x_attn_int_deasserted(struct bnx2x *bp, u32 deasserted)
 	attn.sig[1] = REG_RD(bp, MISC_REG_AEU_AFTER_INVERT_2_FUNC_0 + port*4);
 	attn.sig[2] = REG_RD(bp, MISC_REG_AEU_AFTER_INVERT_3_FUNC_0 + port*4);
 	attn.sig[3] = REG_RD(bp, MISC_REG_AEU_AFTER_INVERT_4_FUNC_0 + port*4);
-	DP(NETIF_MSG_HW, "attn %llx\n", (unsigned long long)attn.sig[0]);
+	DP(NETIF_MSG_HW, "attn: %08x %08x %08x %08x\n",
+	   attn.sig[0], attn.sig[1], attn.sig[2], attn.sig[3]);
 
 	for (index = 0; index < MAX_DYNAMIC_ATTN_GRPS; index++) {
 		if (deasserted & (1 << index)) {
 			group_mask = bp->attn_group[index];
 
-			DP(NETIF_MSG_HW, "group[%d]: %llx\n", index,
-			   (unsigned long long)group_mask.sig[0]);
+			DP(NETIF_MSG_HW, "group[%d]: %08x %08x %08x %08x\n",
+			   index, group_mask.sig[0], group_mask.sig[1],
+			   group_mask.sig[2], group_mask.sig[3]);
 
 			bnx2x_attn_int_deasserted3(bp,
 					attn.sig[3] & group_mask.sig[3]);
@@ -1867,22 +2291,6 @@ static void bnx2x_attn_int_deasserted(struct bnx2x *bp, u32 deasserted)
 					attn.sig[0] & group_mask.sig[0]);
 
 			if ((attn.sig[0] & group_mask.sig[0] &
-						HW_INTERRUT_ASSERT_SET_0) ||
-			    (attn.sig[1] & group_mask.sig[1] &
-						HW_INTERRUT_ASSERT_SET_1) ||
-			    (attn.sig[2] & group_mask.sig[2] &
-						HW_INTERRUT_ASSERT_SET_2))
-				BNX2X_ERR("FATAL HW block attention"
-					  "  set0 0x%x  set1 0x%x"
-					  "  set2 0x%x\n",
-					  (attn.sig[0] & group_mask.sig[0] &
-					   HW_INTERRUT_ASSERT_SET_0),
-					  (attn.sig[1] & group_mask.sig[1] &
-					   HW_INTERRUT_ASSERT_SET_1),
-					  (attn.sig[2] & group_mask.sig[2] &
-					   HW_INTERRUT_ASSERT_SET_2));
-
-			if ((attn.sig[0] & group_mask.sig[0] &
 						HW_PRTY_ASSERT_SET_0) ||
 			    (attn.sig[1] & group_mask.sig[1] &
 						HW_PRTY_ASSERT_SET_1) ||
@@ -1894,17 +2302,17 @@ static void bnx2x_attn_int_deasserted(struct bnx2x *bp, u32 deasserted)
 
 	bnx2x_unlock_alr(bp);
 
-	reg_addr = (IGU_ADDR_ATTN_BITS_CLR + IGU_PORT_BASE * port) * 8;
+	reg_addr = (IGU_ADDR_ATTN_BITS_CLR + IGU_FUNC_BASE * BP_FUNC(bp)) * 8;
 
 	val = ~deasserted;
-/*      DP(NETIF_MSG_INTR, "write 0x%08x to IGU addr 0x%x\n",
+/*	DP(NETIF_MSG_INTR, "write 0x%08x to IGU addr 0x%x\n",
 	   val, BAR_IGU_INTMEM + reg_addr); */
 	REG_WR(bp, BAR_IGU_INTMEM + reg_addr, val);
 
 	if (bp->aeu_mask & (deasserted & 0xff))
-		BNX2X_ERR("IGU BUG\n");
+		BNX2X_ERR("IGU BUG!\n");
 	if (~bp->attn_state & deasserted)
-		BNX2X_ERR("IGU BUG\n");
+		BNX2X_ERR("IGU BUG!\n");
 
 	reg_addr = port ? MISC_REG_AEU_MASK_ATTN_FUNC_1 :
 			  MISC_REG_AEU_MASK_ATTN_FUNC_0;
@@ -1936,7 +2344,7 @@ static void bnx2x_attn_int(struct bnx2x *bp)
 	   attn_bits, attn_ack, asserted, deasserted);
 
 	if (~(attn_bits ^ attn_ack) & (attn_bits ^ attn_state))
-		BNX2X_ERR("bad attention state\n");
+		BNX2X_ERR("BAD attention state\n");
 
 	/* handle bits that were raised */
 	if (asserted)
@@ -1951,6 +2359,7 @@ static void bnx2x_sp_task(struct work_struct *work)
 	struct bnx2x *bp = container_of(work, struct bnx2x, sp_task);
 	u16 status;
 
+
 	/* Return here if interrupt is disabled */
 	if (unlikely(atomic_read(&bp->intr_sem) != 0)) {
 		DP(BNX2X_MSG_SP, "called but intr_sem not 0, returning\n");
@@ -1958,19 +2367,15 @@ static void bnx2x_sp_task(struct work_struct *work)
 	}
 
 	status = bnx2x_update_dsb_idx(bp);
-	if (status == 0)
-		BNX2X_ERR("spurious slowpath interrupt!\n");
+/*	if (status == 0)				     */
+/*		BNX2X_ERR("spurious slowpath interrupt!\n"); */
 
-	DP(NETIF_MSG_INTR, "got a slowpath interrupt (updated %x)\n", status);
+	DP(BNX2X_MSG_SP, "got a slowpath interrupt (updated %x)\n", status);
 
 	/* HW attentions */
 	if (status & 0x1)
 		bnx2x_attn_int(bp);
 
-	/* CStorm events: query_stats, port delete ramrod */
-	if (status & 0x2)
-		bp->stat_pending = 0;
-
 	bnx2x_ack_sb(bp, DEF_SB_ID, ATTENTION_ID, bp->def_att_idx,
 		     IGU_INT_NOP, 1);
 	bnx2x_ack_sb(bp, DEF_SB_ID, USTORM_ID, le16_to_cpu(bp->def_u_idx),
@@ -2109,13 +2514,13 @@ static inline long bnx2x_hilo(u32 *hiref)
 static void bnx2x_init_mac_stats(struct bnx2x *bp)
 {
 	struct dmae_command *dmae;
-	int port = bp->port;
+	int port = BP_PORT(bp);
 	int loader_idx = port * 8;
 	u32 opcode;
 	u32 mac_addr;
 
 	bp->executer_idx = 0;
-	if (bp->fw_mb) {
+	if (bp->func_stx) {
 		/* MCP */
 		opcode = (DMAE_CMD_SRC_PCI | DMAE_CMD_DST_GRC |
 			  DMAE_CMD_SRC_RESET | DMAE_CMD_DST_RESET |
@@ -2135,7 +2540,7 @@ static void bnx2x_init_mac_stats(struct bnx2x *bp)
 					   sizeof(u32));
 		dmae->src_addr_hi = U64_HI(bnx2x_sp_mapping(bp, eth_stats) +
 					   sizeof(u32));
-		dmae->dst_addr_lo = bp->fw_mb >> 2;
+		dmae->dst_addr_lo = bp->func_stx >> 2;
 		dmae->dst_addr_hi = 0;
 		dmae->len = (offsetof(struct bnx2x_eth_stats, mac_stx_end) -
 			     sizeof(u32)) >> 2;
@@ -2280,7 +2685,7 @@ static void bnx2x_init_mac_stats(struct bnx2x *bp)
 
 static void bnx2x_init_stats(struct bnx2x *bp)
 {
-	int port = bp->port;
+	int port = BP_PORT(bp);
 
 	bp->stats_state = STATS_STATE_DISABLE;
 	bp->executer_idx = 0;
@@ -2641,8 +3046,6 @@ static void bnx2x_update_net_stats(struct bnx2x *bp)
 
 static void bnx2x_update_stats(struct bnx2x *bp)
 {
-	int i;
-
 	if (!bnx2x_update_storm_stats(bp)) {
 
 		if (bp->link_vars.mac_type == MAC_TYPE_BMAC) {
@@ -2662,6 +3065,7 @@ static void bnx2x_update_stats(struct bnx2x *bp)
 	if (bp->msglevel & NETIF_MSG_TIMER) {
 		struct bnx2x_eth_stats *estats = bnx2x_sp(bp, eth_stats);
 		struct net_device_stats *nstats = &bp->dev->stats;
+		int i;
 
 		printk(KERN_DEBUG "%s:\n", bp->dev->name);
 		printk(KERN_DEBUG "  tx avail (%4x)  tx hc idx (%x)"
@@ -2707,7 +3111,7 @@ static void bnx2x_update_stats(struct bnx2x *bp)
 	/* loader */
 	if (bp->executer_idx) {
 		struct dmae_command *dmae = &bp->dmae;
-		int port = bp->port;
+		int port = BP_PORT(bp);
 		int loader_idx = port * 8;
 
 		memset(dmae, 0, sizeof(struct dmae_command));
@@ -2766,8 +3170,8 @@ static void bnx2x_timer(unsigned long data)
 		rc = bnx2x_rx_int(fp, 1000);
 	}
 
-	if (!nomcp) {
-		int port = bp->port;
+	if (!BP_NOMCP(bp)) {
+		int func = BP_FUNC(bp);
 		u32 drv_pulse;
 		u32 mcp_pulse;
 
@@ -2775,9 +3179,9 @@ static void bnx2x_timer(unsigned long data)
 		bp->fw_drv_pulse_wr_seq &= DRV_PULSE_SEQ_MASK;
 		/* TBD - add SYSTEM_TIME */
 		drv_pulse = bp->fw_drv_pulse_wr_seq;
-		SHMEM_WR(bp, func_mb[port].drv_pulse_mb, drv_pulse);
+		SHMEM_WR(bp, func_mb[func].drv_pulse_mb, drv_pulse);
 
-		mcp_pulse = (SHMEM_RD(bp, func_mb[port].mcp_pulse_mb) &
+		mcp_pulse = (SHMEM_RD(bp, func_mb[func].mcp_pulse_mb) &
 			     MCP_PULSE_SEQ_MASK);
 		/* The delta between driver pulse and mcp response
 		 * should be 1 (before mcp response) or 0 (after mcp response)
@@ -2807,58 +3211,89 @@ timer_restart:
  * nic init service functions
  */
 
-static void bnx2x_init_sb(struct bnx2x *bp, struct host_status_block *sb,
-			  dma_addr_t mapping, int id)
+static void bnx2x_zero_sb(struct bnx2x *bp, int sb_id)
 {
-	int port = bp->port;
-	u64 section;
+	int port = BP_PORT(bp);
+
+	bnx2x_init_fill(bp, BAR_USTRORM_INTMEM +
+			USTORM_SB_HOST_STATUS_BLOCK_OFFSET(port, sb_id), 0,
+			sizeof(struct ustorm_def_status_block)/4);
+	bnx2x_init_fill(bp, BAR_CSTRORM_INTMEM +
+			CSTORM_SB_HOST_STATUS_BLOCK_OFFSET(port, sb_id), 0,
+			sizeof(struct cstorm_def_status_block)/4);
+}
+
+static void bnx2x_init_sb(struct bnx2x *bp, int sb_id,
+			  struct host_status_block *sb,	dma_addr_t mapping)
+{
+	int port = BP_PORT(bp);
 	int index;
+	u64 section;
 
 	/* USTORM */
 	section = ((u64)mapping) + offsetof(struct host_status_block,
 					    u_status_block);
-	sb->u_status_block.status_block_id = id;
+	sb->u_status_block.status_block_id = sb_id;
 
 	REG_WR(bp, BAR_USTRORM_INTMEM +
-	       USTORM_SB_HOST_SB_ADDR_OFFSET(port, id), U64_LO(section));
+	       USTORM_SB_HOST_SB_ADDR_OFFSET(port, sb_id), U64_LO(section));
 	REG_WR(bp, BAR_USTRORM_INTMEM +
-	       ((USTORM_SB_HOST_SB_ADDR_OFFSET(port, id)) + 4),
+	       ((USTORM_SB_HOST_SB_ADDR_OFFSET(port, sb_id)) + 4),
 	       U64_HI(section));
 
 	for (index = 0; index < HC_USTORM_SB_NUM_INDICES; index++)
 		REG_WR16(bp, BAR_USTRORM_INTMEM +
-			 USTORM_SB_HC_DISABLE_OFFSET(port, id, index), 0x1);
+			 USTORM_SB_HC_DISABLE_OFFSET(port, sb_id, index), 1);
 
 	/* CSTORM */
 	section = ((u64)mapping) + offsetof(struct host_status_block,
 					    c_status_block);
-	sb->c_status_block.status_block_id = id;
+	sb->c_status_block.status_block_id = sb_id;
 
 	REG_WR(bp, BAR_CSTRORM_INTMEM +
-	       CSTORM_SB_HOST_SB_ADDR_OFFSET(port, id), U64_LO(section));
+	       CSTORM_SB_HOST_SB_ADDR_OFFSET(port, sb_id), U64_LO(section));
 	REG_WR(bp, BAR_CSTRORM_INTMEM +
-	       ((CSTORM_SB_HOST_SB_ADDR_OFFSET(port, id)) + 4),
+	       ((CSTORM_SB_HOST_SB_ADDR_OFFSET(port, sb_id)) + 4),
 	       U64_HI(section));
 
 	for (index = 0; index < HC_CSTORM_SB_NUM_INDICES; index++)
 		REG_WR16(bp, BAR_CSTRORM_INTMEM +
-			 CSTORM_SB_HC_DISABLE_OFFSET(port, id, index), 0x1);
+			 CSTORM_SB_HC_DISABLE_OFFSET(port, sb_id, index), 1);
 
-	bnx2x_ack_sb(bp, id, CSTORM_ID, 0, IGU_INT_ENABLE, 0);
+	bnx2x_ack_sb(bp, sb_id, CSTORM_ID, 0, IGU_INT_ENABLE, 0);
+}
+
+static void bnx2x_zero_def_sb(struct bnx2x *bp)
+{
+	int func = BP_FUNC(bp);
+
+	bnx2x_init_fill(bp, BAR_USTRORM_INTMEM +
+			USTORM_DEF_SB_HOST_STATUS_BLOCK_OFFSET(func), 0,
+			sizeof(struct ustorm_def_status_block)/4);
+	bnx2x_init_fill(bp, BAR_CSTRORM_INTMEM +
+			CSTORM_DEF_SB_HOST_STATUS_BLOCK_OFFSET(func), 0,
+			sizeof(struct cstorm_def_status_block)/4);
+	bnx2x_init_fill(bp, BAR_XSTRORM_INTMEM +
+			XSTORM_DEF_SB_HOST_STATUS_BLOCK_OFFSET(func), 0,
+			sizeof(struct xstorm_def_status_block)/4);
+	bnx2x_init_fill(bp, BAR_TSTRORM_INTMEM +
+			TSTORM_DEF_SB_HOST_STATUS_BLOCK_OFFSET(func), 0,
+			sizeof(struct tstorm_def_status_block)/4);
 }
 
 static void bnx2x_init_def_sb(struct bnx2x *bp,
 			      struct host_def_status_block *def_sb,
-			      dma_addr_t mapping, int id)
+			      dma_addr_t mapping, int sb_id)
 {
-	int port = bp->port;
+	int port = BP_PORT(bp);
+	int func = BP_FUNC(bp);
 	int index, val, reg_offset;
 	u64 section;
 
 	/* ATTN */
 	section = ((u64)mapping) + offsetof(struct host_def_status_block,
 					    atten_status_block);
-	def_sb->atten_status_block.status_block_id = id;
+	def_sb->atten_status_block.status_block_id = sb_id;
 
 	bp->def_att_idx = 0;
 	bp->attn_state = 0;
@@ -2866,7 +3301,7 @@ static void bnx2x_init_def_sb(struct bnx2x *bp,
 	reg_offset = (port ? MISC_REG_AEU_ENABLE1_FUNC_1_OUT_0 :
 			     MISC_REG_AEU_ENABLE1_FUNC_0_OUT_0);
 
-	for (index = 0; index < 3; index++) {
+	for (index = 0; index < MAX_DYNAMIC_ATTN_GRPS; index++) {
 		bp->attn_group[index].sig[0] = REG_RD(bp,
 						     reg_offset + 0x10*index);
 		bp->attn_group[index].sig[1] = REG_RD(bp,
@@ -2889,116 +3324,123 @@ static void bnx2x_init_def_sb(struct bnx2x *bp,
 	reg_offset = (port ? HC_REG_ATTN_NUM_P1 : HC_REG_ATTN_NUM_P0);
 
 	val = REG_RD(bp, reg_offset);
-	val |= id;
+	val |= sb_id;
 	REG_WR(bp, reg_offset, val);
 
 	/* USTORM */
 	section = ((u64)mapping) + offsetof(struct host_def_status_block,
 					    u_def_status_block);
-	def_sb->u_def_status_block.status_block_id = id;
+	def_sb->u_def_status_block.status_block_id = sb_id;
 
 	bp->def_u_idx = 0;
 
 	REG_WR(bp, BAR_USTRORM_INTMEM +
-	       USTORM_DEF_SB_HOST_SB_ADDR_OFFSET(port), U64_LO(section));
+	       USTORM_DEF_SB_HOST_SB_ADDR_OFFSET(func), U64_LO(section));
 	REG_WR(bp, BAR_USTRORM_INTMEM +
-	       ((USTORM_DEF_SB_HOST_SB_ADDR_OFFSET(port)) + 4),
+	       ((USTORM_DEF_SB_HOST_SB_ADDR_OFFSET(func)) + 4),
 	       U64_HI(section));
-	REG_WR(bp, BAR_USTRORM_INTMEM + USTORM_HC_BTR_OFFSET(port),
+	REG_WR8(bp, BAR_USTRORM_INTMEM +  DEF_USB_FUNC_OFF +
+		USTORM_DEF_SB_HOST_STATUS_BLOCK_OFFSET(func), func);
+	REG_WR(bp, BAR_USTRORM_INTMEM + USTORM_HC_BTR_OFFSET(func),
 	       BNX2X_BTR);
 
 	for (index = 0; index < HC_USTORM_DEF_SB_NUM_INDICES; index++)
 		REG_WR16(bp, BAR_USTRORM_INTMEM +
-			 USTORM_DEF_SB_HC_DISABLE_OFFSET(port, index), 0x1);
+			 USTORM_DEF_SB_HC_DISABLE_OFFSET(func, index), 1);
 
 	/* CSTORM */
 	section = ((u64)mapping) + offsetof(struct host_def_status_block,
 					    c_def_status_block);
-	def_sb->c_def_status_block.status_block_id = id;
+	def_sb->c_def_status_block.status_block_id = sb_id;
 
 	bp->def_c_idx = 0;
 
 	REG_WR(bp, BAR_CSTRORM_INTMEM +
-	       CSTORM_DEF_SB_HOST_SB_ADDR_OFFSET(port), U64_LO(section));
+	       CSTORM_DEF_SB_HOST_SB_ADDR_OFFSET(func), U64_LO(section));
 	REG_WR(bp, BAR_CSTRORM_INTMEM +
-	       ((CSTORM_DEF_SB_HOST_SB_ADDR_OFFSET(port)) + 4),
+	       ((CSTORM_DEF_SB_HOST_SB_ADDR_OFFSET(func)) + 4),
 	       U64_HI(section));
-	REG_WR(bp, BAR_CSTRORM_INTMEM + CSTORM_HC_BTR_OFFSET(port),
+	REG_WR8(bp, BAR_CSTRORM_INTMEM +  DEF_CSB_FUNC_OFF +
+		CSTORM_DEF_SB_HOST_STATUS_BLOCK_OFFSET(func), func);
+	REG_WR(bp, BAR_CSTRORM_INTMEM + CSTORM_HC_BTR_OFFSET(func),
 	       BNX2X_BTR);
 
 	for (index = 0; index < HC_CSTORM_DEF_SB_NUM_INDICES; index++)
 		REG_WR16(bp, BAR_CSTRORM_INTMEM +
-			 CSTORM_DEF_SB_HC_DISABLE_OFFSET(port, index), 0x1);
+			 CSTORM_DEF_SB_HC_DISABLE_OFFSET(func, index), 1);
 
 	/* TSTORM */
 	section = ((u64)mapping) + offsetof(struct host_def_status_block,
 					    t_def_status_block);
-	def_sb->t_def_status_block.status_block_id = id;
+	def_sb->t_def_status_block.status_block_id = sb_id;
 
 	bp->def_t_idx = 0;
 
 	REG_WR(bp, BAR_TSTRORM_INTMEM +
-	       TSTORM_DEF_SB_HOST_SB_ADDR_OFFSET(port), U64_LO(section));
+	       TSTORM_DEF_SB_HOST_SB_ADDR_OFFSET(func), U64_LO(section));
 	REG_WR(bp, BAR_TSTRORM_INTMEM +
-	       ((TSTORM_DEF_SB_HOST_SB_ADDR_OFFSET(port)) + 4),
+	       ((TSTORM_DEF_SB_HOST_SB_ADDR_OFFSET(func)) + 4),
 	       U64_HI(section));
-	REG_WR(bp, BAR_TSTRORM_INTMEM + TSTORM_HC_BTR_OFFSET(port),
+	REG_WR8(bp, BAR_TSTRORM_INTMEM +  DEF_TSB_FUNC_OFF +
+		TSTORM_DEF_SB_HOST_STATUS_BLOCK_OFFSET(func), func);
+	REG_WR(bp, BAR_TSTRORM_INTMEM + TSTORM_HC_BTR_OFFSET(func),
 	       BNX2X_BTR);
 
 	for (index = 0; index < HC_TSTORM_DEF_SB_NUM_INDICES; index++)
 		REG_WR16(bp, BAR_TSTRORM_INTMEM +
-			 TSTORM_DEF_SB_HC_DISABLE_OFFSET(port, index), 0x1);
+			 TSTORM_DEF_SB_HC_DISABLE_OFFSET(func, index), 1);
 
 	/* XSTORM */
 	section = ((u64)mapping) + offsetof(struct host_def_status_block,
 					    x_def_status_block);
-	def_sb->x_def_status_block.status_block_id = id;
+	def_sb->x_def_status_block.status_block_id = sb_id;
 
 	bp->def_x_idx = 0;
 
 	REG_WR(bp, BAR_XSTRORM_INTMEM +
-	       XSTORM_DEF_SB_HOST_SB_ADDR_OFFSET(port), U64_LO(section));
+	       XSTORM_DEF_SB_HOST_SB_ADDR_OFFSET(func), U64_LO(section));
 	REG_WR(bp, BAR_XSTRORM_INTMEM +
-	       ((XSTORM_DEF_SB_HOST_SB_ADDR_OFFSET(port)) + 4),
+	       ((XSTORM_DEF_SB_HOST_SB_ADDR_OFFSET(func)) + 4),
 	       U64_HI(section));
-	REG_WR(bp, BAR_XSTRORM_INTMEM + XSTORM_HC_BTR_OFFSET(port),
+	REG_WR8(bp, BAR_XSTRORM_INTMEM +  DEF_XSB_FUNC_OFF +
+		XSTORM_DEF_SB_HOST_STATUS_BLOCK_OFFSET(func), func);
+	REG_WR(bp, BAR_XSTRORM_INTMEM + XSTORM_HC_BTR_OFFSET(func),
 	       BNX2X_BTR);
 
 	for (index = 0; index < HC_XSTORM_DEF_SB_NUM_INDICES; index++)
 		REG_WR16(bp, BAR_XSTRORM_INTMEM +
-			 XSTORM_DEF_SB_HC_DISABLE_OFFSET(port, index), 0x1);
+			 XSTORM_DEF_SB_HC_DISABLE_OFFSET(func, index), 1);
 
-	bp->stat_pending = 0;
-
-	bnx2x_ack_sb(bp, id, CSTORM_ID, 0, IGU_INT_ENABLE, 0);
+	bnx2x_ack_sb(bp, sb_id, CSTORM_ID, 0, IGU_INT_ENABLE, 0);
 }
 
 static void bnx2x_update_coalesce(struct bnx2x *bp)
 {
-	int port = bp->port;
+	int port = BP_PORT(bp);
 	int i;
 
 	for_each_queue(bp, i) {
+		int sb_id = bp->fp[i].sb_id;
 
 		/* HC_INDEX_U_ETH_RX_CQ_CONS */
 		REG_WR8(bp, BAR_USTRORM_INTMEM +
-			USTORM_SB_HC_TIMEOUT_OFFSET(port, i,
+			USTORM_SB_HC_TIMEOUT_OFFSET(port, sb_id,
 						   HC_INDEX_U_ETH_RX_CQ_CONS),
-			bp->rx_ticks_int/12);
+			bp->rx_ticks/12);
 		REG_WR16(bp, BAR_USTRORM_INTMEM +
-			 USTORM_SB_HC_DISABLE_OFFSET(port, i,
+			 USTORM_SB_HC_DISABLE_OFFSET(port, sb_id,
 						   HC_INDEX_U_ETH_RX_CQ_CONS),
-			 bp->rx_ticks_int ? 0 : 1);
+			 bp->rx_ticks ? 0 : 1);
 
 		/* HC_INDEX_C_ETH_TX_CQ_CONS */
 		REG_WR8(bp, BAR_CSTRORM_INTMEM +
-			CSTORM_SB_HC_TIMEOUT_OFFSET(port, i,
+			CSTORM_SB_HC_TIMEOUT_OFFSET(port, sb_id,
 						   HC_INDEX_C_ETH_TX_CQ_CONS),
-			bp->tx_ticks_int/12);
+			bp->tx_ticks/12);
 		REG_WR16(bp, BAR_CSTRORM_INTMEM +
-			 CSTORM_SB_HC_DISABLE_OFFSET(port, i,
+			 CSTORM_SB_HC_DISABLE_OFFSET(port, sb_id,
 						   HC_INDEX_C_ETH_TX_CQ_CONS),
-			 bp->tx_ticks_int ? 0 : 1);
+			 bp->tx_ticks ? 0 : 1);
 	}
 }
 
@@ -3006,7 +3448,6 @@ static void bnx2x_init_rx_rings(struct bnx2x *bp)
 {
 	u16 ring_prod;
 	int i, j;
-	int port = bp->port;
 
 	bp->rx_buf_use_size = bp->dev->mtu;
 
@@ -3025,13 +3466,13 @@ static void bnx2x_init_rx_rings(struct bnx2x *bp)
 			rx_bd = &fp->rx_desc_ring[RX_DESC_CNT * i - 2];
 			rx_bd->addr_hi =
 				cpu_to_le32(U64_HI(fp->rx_desc_mapping +
-					   BCM_PAGE_SIZE*(i % NUM_RX_RINGS)));
+					    BCM_PAGE_SIZE*(i % NUM_RX_RINGS)));
 			rx_bd->addr_lo =
 				cpu_to_le32(U64_LO(fp->rx_desc_mapping +
-					   BCM_PAGE_SIZE*(i % NUM_RX_RINGS)));
-
+					    BCM_PAGE_SIZE*(i % NUM_RX_RINGS)));
 		}
 
+		/* CQ ring */
 		for (i = 1; i <= NUM_RCQ_RINGS; i++) {
 			struct eth_rx_cqe_next_page *nextpg;
 
@@ -3039,10 +3480,10 @@ static void bnx2x_init_rx_rings(struct bnx2x *bp)
 				&fp->rx_comp_ring[RCQ_DESC_CNT * i - 1];
 			nextpg->addr_hi =
 				cpu_to_le32(U64_HI(fp->rx_comp_mapping +
-					  BCM_PAGE_SIZE*(i % NUM_RCQ_RINGS)));
+					   BCM_PAGE_SIZE*(i % NUM_RCQ_RINGS)));
 			nextpg->addr_lo =
 				cpu_to_le32(U64_LO(fp->rx_comp_mapping +
-					  BCM_PAGE_SIZE*(i % NUM_RCQ_RINGS)));
+					   BCM_PAGE_SIZE*(i % NUM_RCQ_RINGS)));
 		}
 
 		/* rx completion queue */
@@ -3064,15 +3505,16 @@ static void bnx2x_init_rx_rings(struct bnx2x *bp)
 		/* Warning! this will generate an interrupt (to the TSTORM) */
 		/* must only be done when chip is initialized */
 		REG_WR(bp, BAR_TSTRORM_INTMEM +
-		       TSTORM_RCQ_PROD_OFFSET(port, j), ring_prod);
+		       TSTORM_RX_PRODS_OFFSET(BP_PORT(bp), FP_CL_ID(fp)),
+			ring_prod);
 		if (j != 0)
 			continue;
 
 		REG_WR(bp, BAR_USTRORM_INTMEM +
-		       USTORM_MEM_WORKAROUND_ADDRESS_OFFSET(port),
+		       USTORM_MEM_WORKAROUND_ADDRESS_OFFSET(BP_PORT(bp)),
 		       U64_LO(fp->rx_comp_mapping));
 		REG_WR(bp, BAR_USTRORM_INTMEM +
-		       USTORM_MEM_WORKAROUND_ADDRESS_OFFSET(port) + 4,
+		       USTORM_MEM_WORKAROUND_ADDRESS_OFFSET(BP_PORT(bp)) + 4,
 		       U64_HI(fp->rx_comp_mapping));
 	}
 }
@@ -3090,10 +3532,10 @@ static void bnx2x_init_tx_ring(struct bnx2x *bp)
 
 			tx_bd->addr_hi =
 				cpu_to_le32(U64_HI(fp->tx_desc_mapping +
-					   BCM_PAGE_SIZE*(i % NUM_TX_RINGS)));
+					    BCM_PAGE_SIZE*(i % NUM_TX_RINGS)));
 			tx_bd->addr_lo =
 				cpu_to_le32(U64_LO(fp->tx_desc_mapping +
-					   BCM_PAGE_SIZE*(i % NUM_TX_RINGS)));
+					    BCM_PAGE_SIZE*(i % NUM_TX_RINGS)));
 		}
 
 		fp->tx_pkt_prod = 0;
@@ -3107,7 +3549,7 @@ static void bnx2x_init_tx_ring(struct bnx2x *bp)
 
 static void bnx2x_init_sp_ring(struct bnx2x *bp)
 {
-	int port = bp->port;
+	int func = BP_FUNC(bp);
 
 	spin_lock_init(&bp->spq_lock);
 
@@ -3117,12 +3559,13 @@ static void bnx2x_init_sp_ring(struct bnx2x *bp)
 	bp->spq_prod_bd = bp->spq;
 	bp->spq_last_bd = bp->spq_prod_bd + MAX_SP_DESC_CNT;
 
-	REG_WR(bp, BAR_XSTRORM_INTMEM + XSTORM_SPQ_PAGE_BASE_OFFSET(port),
+	REG_WR(bp, XSEM_REG_FAST_MEMORY + XSTORM_SPQ_PAGE_BASE_OFFSET(func),
 	       U64_LO(bp->spq_mapping));
-	REG_WR(bp, BAR_XSTRORM_INTMEM + XSTORM_SPQ_PAGE_BASE_OFFSET(port) + 4,
+	REG_WR(bp,
+	       XSEM_REG_FAST_MEMORY + XSTORM_SPQ_PAGE_BASE_OFFSET(func) + 4,
 	       U64_HI(bp->spq_mapping));
 
-	REG_WR(bp, XSEM_REG_FAST_MEMORY + XSTORM_SPQ_PROD_OFFSET(port),
+	REG_WR(bp, XSEM_REG_FAST_MEMORY + XSTORM_SPQ_PROD_OFFSET(func),
 	       bp->spq_prod_idx);
 }
 
@@ -3133,6 +3576,7 @@ static void bnx2x_init_context(struct bnx2x *bp)
 	for_each_queue(bp, i) {
 		struct eth_context *context = bnx2x_sp(bp, context[i].eth);
 		struct bnx2x_fastpath *fp = &bp->fp[i];
+		u8 sb_id = FP_SB_ID(fp);
 
 		context->xstorm_st_context.tx_bd_page_base_hi =
 						U64_HI(fp->tx_desc_mapping);
@@ -3142,26 +3586,25 @@ static void bnx2x_init_context(struct bnx2x *bp)
 						U64_HI(fp->tx_prods_mapping);
 		context->xstorm_st_context.db_data_addr_lo =
 						U64_LO(fp->tx_prods_mapping);
-
-		context->ustorm_st_context.rx_bd_page_base_hi =
+		context->xstorm_st_context.statistics_data = (BP_CL_ID(bp) |
+				XSTORM_ETH_ST_CONTEXT_STATISTICS_ENABLE);
+
+		context->ustorm_st_context.common.sb_index_numbers =
+						BNX2X_RX_SB_INDEX_NUM;
+		context->ustorm_st_context.common.clientId = FP_CL_ID(fp);
+		context->ustorm_st_context.common.status_block_id = sb_id;
+		context->ustorm_st_context.common.flags =
+			USTORM_ETH_ST_CONTEXT_CONFIG_ENABLE_MC_ALIGNMENT;
+		context->ustorm_st_context.common.mc_alignment_size = 64;
+		context->ustorm_st_context.common.bd_buff_size =
+						bp->rx_buf_use_size;
+		context->ustorm_st_context.common.bd_page_base_hi =
 						U64_HI(fp->rx_desc_mapping);
-		context->ustorm_st_context.rx_bd_page_base_lo =
+		context->ustorm_st_context.common.bd_page_base_lo =
 						U64_LO(fp->rx_desc_mapping);
-		context->ustorm_st_context.status_block_id = i;
-		context->ustorm_st_context.sb_index_number =
-						HC_INDEX_U_ETH_RX_CQ_CONS;
-		context->ustorm_st_context.rcq_base_address_hi =
-						U64_HI(fp->rx_comp_mapping);
-		context->ustorm_st_context.rcq_base_address_lo =
-						U64_LO(fp->rx_comp_mapping);
-		context->ustorm_st_context.flags =
-				USTORM_ETH_ST_CONTEXT_ENABLE_MC_ALIGNMENT;
-		context->ustorm_st_context.mc_alignment_size = 64;
-		context->ustorm_st_context.num_rss = bp->num_queues;
-
 		context->cstorm_st_context.sb_index_number =
 						HC_INDEX_C_ETH_TX_CQ_CONS;
-		context->cstorm_st_context.status_block_id = i;
+		context->cstorm_st_context.status_block_id = sb_id;
 
 		context->xstorm_ag_context.cdu_reserved =
 			CDU_RSRVD_VALUE_TYPE_A(HW_CID(bp, i),
@@ -3176,14 +3619,16 @@ static void bnx2x_init_context(struct bnx2x *bp)
 
 static void bnx2x_init_ind_table(struct bnx2x *bp)
 {
-	int port = bp->port;
+	int port = BP_PORT(bp);
 	int i;
 
 	if (!is_multi(bp))
 		return;
 
+	DP(NETIF_MSG_IFUP, "Initializing indirection table\n");
 	for (i = 0; i < TSTORM_INDIRECTION_TABLE_SIZE; i++)
-		REG_WR8(bp, TSTORM_INDIRECTION_TABLE_OFFSET(port) + i,
+		REG_WR8(bp, BAR_TSTRORM_INTMEM +
+			TSTORM_INDIRECTION_TABLE_OFFSET(port) + i,
 			i % bp->num_queues);
 
 	REG_WR(bp, PRS_REG_A_PRSU_20, 0xf);
@@ -3191,77 +3636,74 @@ static void bnx2x_init_ind_table(struct bnx2x *bp)
 
 static void bnx2x_set_client_config(struct bnx2x *bp)
 {
-#ifdef BCM_VLAN
-	int mode = bp->rx_mode;
-#endif
-	int i, port = bp->port;
 	struct tstorm_eth_client_config tstorm_client = {0};
+	int port = BP_PORT(bp);
+	int i;
 
-	tstorm_client.mtu = bp->dev->mtu;
+	tstorm_client.mtu = bp->dev->mtu + ETH_OVREHEAD;
 	tstorm_client.statistics_counter_id = 0;
 	tstorm_client.config_flags =
 				TSTORM_ETH_CLIENT_CONFIG_STATSITICS_ENABLE;
 #ifdef BCM_VLAN
-	if (mode && bp->vlgrp) {
+	if (bp->rx_mode && bp->vlgrp) {
 		tstorm_client.config_flags |=
 				TSTORM_ETH_CLIENT_CONFIG_VLAN_REMOVAL_ENABLE;
 		DP(NETIF_MSG_IFUP, "vlan removal enabled\n");
 	}
 #endif
-	if (mode != BNX2X_RX_MODE_PROMISC)
-		tstorm_client.drop_flags =
-				TSTORM_ETH_CLIENT_CONFIG_DROP_MAC_ERR;
 
 	for_each_queue(bp, i) {
 		REG_WR(bp, BAR_TSTRORM_INTMEM +
-		       TSTORM_CLIENT_CONFIG_OFFSET(port, i),
+		       TSTORM_CLIENT_CONFIG_OFFSET(port, bp->fp[i].cl_id),
 		       ((u32 *)&tstorm_client)[0]);
 		REG_WR(bp, BAR_TSTRORM_INTMEM +
-		       TSTORM_CLIENT_CONFIG_OFFSET(port, i) + 4,
+		       TSTORM_CLIENT_CONFIG_OFFSET(port, bp->fp[i].cl_id) + 4,
 		       ((u32 *)&tstorm_client)[1]);
 	}
 
-/*	DP(NETIF_MSG_IFUP, "tstorm_client: 0x%08x 0x%08x\n",
-	   ((u32 *)&tstorm_client)[0], ((u32 *)&tstorm_client)[1]); */
+	DP(BNX2X_MSG_OFF, "tstorm_client: 0x%08x 0x%08x\n",
+	   ((u32 *)&tstorm_client)[0], ((u32 *)&tstorm_client)[1]);
 }
 
 static void bnx2x_set_storm_rx_mode(struct bnx2x *bp)
 {
-	int mode = bp->rx_mode;
-	int port = bp->port;
 	struct tstorm_eth_mac_filter_config tstorm_mac_filter = {0};
+	int mode = bp->rx_mode;
+	int mask = (1 << BP_L_ID(bp));
+	int func = BP_FUNC(bp);
 	int i;
 
 	DP(NETIF_MSG_RX_STATUS, "rx mode is %d\n", mode);
 
 	switch (mode) {
 	case BNX2X_RX_MODE_NONE: /* no Rx */
-		tstorm_mac_filter.ucast_drop_all = 1;
-		tstorm_mac_filter.mcast_drop_all = 1;
-		tstorm_mac_filter.bcast_drop_all = 1;
+		tstorm_mac_filter.ucast_drop_all = mask;
+		tstorm_mac_filter.mcast_drop_all = mask;
+		tstorm_mac_filter.bcast_drop_all = mask;
 		break;
 	case BNX2X_RX_MODE_NORMAL:
-		tstorm_mac_filter.bcast_accept_all = 1;
+		tstorm_mac_filter.bcast_accept_all = mask;
 		break;
 	case BNX2X_RX_MODE_ALLMULTI:
-		tstorm_mac_filter.mcast_accept_all = 1;
-		tstorm_mac_filter.bcast_accept_all = 1;
+		tstorm_mac_filter.mcast_accept_all = mask;
+		tstorm_mac_filter.bcast_accept_all = mask;
 		break;
 	case BNX2X_RX_MODE_PROMISC:
-		tstorm_mac_filter.ucast_accept_all = 1;
-		tstorm_mac_filter.mcast_accept_all = 1;
-		tstorm_mac_filter.bcast_accept_all = 1;
+		tstorm_mac_filter.ucast_accept_all = mask;
+		tstorm_mac_filter.mcast_accept_all = mask;
+		tstorm_mac_filter.bcast_accept_all = mask;
 		break;
 	default:
-		BNX2X_ERR("bad rx mode (%d)\n", mode);
+		BNX2X_ERR("BAD rx mode (%d)\n", mode);
+		break;
 	}
 
 	for (i = 0; i < sizeof(struct tstorm_eth_mac_filter_config)/4; i++) {
 		REG_WR(bp, BAR_TSTRORM_INTMEM +
-		       TSTORM_MAC_FILTER_CONFIG_OFFSET(port) + i * 4,
+		       TSTORM_MAC_FILTER_CONFIG_OFFSET(func) + i * 4,
 		       ((u32 *)&tstorm_mac_filter)[i]);
 
-/*      	DP(NETIF_MSG_IFUP, "tstorm_mac_filter[%d]: 0x%08x\n", i,
+/*		DP(NETIF_MSG_IFUP, "tstorm_mac_filter[%d]: 0x%08x\n", i,
 		   ((u32 *)&tstorm_mac_filter)[i]); */
 	}
 
@@ -3271,26 +3713,30 @@ static void bnx2x_set_storm_rx_mode(struct bnx2x *bp)
 
 static void bnx2x_init_internal(struct bnx2x *bp)
 {
-	int port = bp->port;
 	struct tstorm_eth_function_common_config tstorm_config = {0};
 	struct stats_indication_flags stats_flags = {0};
+	int port = BP_PORT(bp);
+	int func = BP_FUNC(bp);
+	int i;
 
 	if (is_multi(bp)) {
 		tstorm_config.config_flags = MULTI_FLAGS;
 		tstorm_config.rss_result_mask = MULTI_MASK;
 	}
 
+	tstorm_config.leading_client_id = BP_L_ID(bp);
+
 	REG_WR(bp, BAR_TSTRORM_INTMEM +
-	       TSTORM_FUNCTION_COMMON_CONFIG_OFFSET(port),
+	       TSTORM_FUNCTION_COMMON_CONFIG_OFFSET(func),
 	       (*(u32 *)&tstorm_config));
 
-/*      DP(NETIF_MSG_IFUP, "tstorm_config: 0x%08x\n",
+/*	DP(NETIF_MSG_IFUP, "tstorm_config: 0x%08x\n",
 	   (*(u32 *)&tstorm_config)); */
 
 	bp->rx_mode = BNX2X_RX_MODE_NONE; /* no rx until link is up */
 	bnx2x_set_storm_rx_mode(bp);
 
-	stats_flags.collect_eth = cpu_to_le32(1);
+	stats_flags.collect_eth = 1;
 
 	REG_WR(bp, BAR_XSTRORM_INTMEM + XSTORM_STATS_FLAGS_OFFSET(port),
 	       ((u32 *)&stats_flags)[0]);
@@ -3307,8 +3753,28 @@ static void bnx2x_init_internal(struct bnx2x *bp)
 	REG_WR(bp, BAR_CSTRORM_INTMEM + CSTORM_STATS_FLAGS_OFFSET(port) + 4,
 	       ((u32 *)&stats_flags)[1]);
 
-/*      DP(NETIF_MSG_IFUP, "stats_flags: 0x%08x 0x%08x\n",
+/*	DP(NETIF_MSG_IFUP, "stats_flags: 0x%08x 0x%08x\n",
 	   ((u32 *)&stats_flags)[0], ((u32 *)&stats_flags)[1]); */
+
+	if (CHIP_IS_E1H(bp)) {
+		REG_WR8(bp, BAR_XSTRORM_INTMEM + XSTORM_FUNCTION_MODE_OFFSET,
+			IS_E1HMF(bp));
+		REG_WR8(bp, BAR_TSTRORM_INTMEM + TSTORM_FUNCTION_MODE_OFFSET,
+			IS_E1HMF(bp));
+		REG_WR8(bp, BAR_CSTRORM_INTMEM + CSTORM_FUNCTION_MODE_OFFSET,
+			IS_E1HMF(bp));
+		REG_WR8(bp, BAR_USTRORM_INTMEM + USTORM_FUNCTION_MODE_OFFSET,
+			IS_E1HMF(bp));
+
+		REG_WR16(bp, BAR_XSTRORM_INTMEM +
+			 XSTORM_E1HOV_OFFSET(func), bp->e1hov);
+	}
+
+	/* Zero this manualy as its initialization is
+	   currently missing in the initTool */
+	for (i = 0; i < USTORM_AGG_DATA_SIZE >> 2; i++)
+		REG_WR(bp, BAR_USTRORM_INTMEM +
+		       USTORM_AGG_DATA_OFFSET + 4*i, 0);
 }
 
 static void bnx2x_nic_init(struct bnx2x *bp)
@@ -3318,15 +3784,20 @@ static void bnx2x_nic_init(struct bnx2x *bp)
 	for_each_queue(bp, i) {
 		struct bnx2x_fastpath *fp = &bp->fp[i];
 
+		fp->bp = bp;
 		fp->state = BNX2X_FP_STATE_CLOSED;
-		DP(NETIF_MSG_IFUP, "bnx2x_init_sb(%p,%p,%d);\n",
-		   bp, fp->status_blk, i);
 		fp->index = i;
-		bnx2x_init_sb(bp, fp->status_blk, fp->status_blk_mapping, i);
+		fp->cl_id = BP_L_ID(bp) + i;
+		fp->sb_id = fp->cl_id;
+		DP(NETIF_MSG_IFUP,
+		   "bnx2x_init_sb(%p,%p) index %d  cl_id %d  sb %d\n",
+		   bp, fp->status_blk, i, FP_CL_ID(fp), FP_SB_ID(fp));
+		bnx2x_init_sb(bp, FP_SB_ID(fp), fp->status_blk,
+			      fp->status_blk_mapping);
 	}
 
 	bnx2x_init_def_sb(bp, bp->def_status_blk,
-			  bp->def_status_blk_mapping, 0x10);
+			  bp->def_status_blk_mapping, DEF_SB_ID);
 	bnx2x_update_coalesce(bp);
 	bnx2x_init_rx_rings(bp);
 	bnx2x_init_tx_ring(bp);
@@ -3336,7 +3807,6 @@ static void bnx2x_nic_init(struct bnx2x *bp)
 	bnx2x_init_stats(bp);
 	bnx2x_init_ind_table(bp);
 	bnx2x_int_enable(bp);
-
 }
 
 /* end of nic init */
@@ -3374,7 +3844,7 @@ gunzip_nomem2:
 
 gunzip_nomem1:
 	printk(KERN_ERR PFX "%s: Cannot allocate firmware buffer for"
-	       " uncompression\n", bp->dev->name);
+	       " un-compression\n", bp->dev->name);
 	return -ENOMEM;
 }
 
@@ -3402,7 +3872,7 @@ static int bnx2x_gunzip(struct bnx2x *bp, u8 *zbuf, int len)
 
 	n = 10;
 
-#define FNAME   			0x8
+#define FNAME				0x8
 
 	if (zbuf[3] & FNAME)
 		while ((zbuf[n++] != 0) && (n < len));
@@ -3439,41 +3909,25 @@ static int bnx2x_gunzip(struct bnx2x *bp, u8 *zbuf, int len)
 /* nic load/unload */
 
 /*
- * general service functions
+ * General service functions
  */
 
 /* send a NIG loopback debug packet */
 static void bnx2x_lb_pckt(struct bnx2x *bp)
 {
-#ifdef USE_DMAE
 	u32 wb_write[3];
-#endif
 
 	/* Ethernet source and destination addresses */
-#ifdef USE_DMAE
 	wb_write[0] = 0x55555555;
 	wb_write[1] = 0x55555555;
-	wb_write[2] = 0x20;     	/* SOP */
+	wb_write[2] = 0x20;		/* SOP */
 	REG_WR_DMAE(bp, NIG_REG_DEBUG_PACKET_LB, wb_write, 3);
-#else
-	REG_WR_IND(bp, NIG_REG_DEBUG_PACKET_LB, 0x55555555);
-	REG_WR_IND(bp, NIG_REG_DEBUG_PACKET_LB + 4, 0x55555555);
-	/* SOP */
-	REG_WR_IND(bp, NIG_REG_DEBUG_PACKET_LB + 8, 0x20);
-#endif
 
 	/* NON-IP protocol */
-#ifdef USE_DMAE
 	wb_write[0] = 0x09000000;
 	wb_write[1] = 0x55555555;
-	wb_write[2] = 0x10;     	/* EOP, eop_bvalid = 0 */
+	wb_write[2] = 0x10;		/* EOP, eop_bvalid = 0 */
 	REG_WR_DMAE(bp, NIG_REG_DEBUG_PACKET_LB, wb_write, 3);
-#else
-	REG_WR_IND(bp, NIG_REG_DEBUG_PACKET_LB, 0x09000000);
-	REG_WR_IND(bp, NIG_REG_DEBUG_PACKET_LB + 4, 0x55555555);
-	/* EOP, eop_bvalid = 0 */
-	REG_WR_IND(bp, NIG_REG_DEBUG_PACKET_LB + 8, 0x10);
-#endif
 }
 
 /* some of the internal memories
@@ -3511,13 +3965,9 @@ static int bnx2x_int_mem_test(struct bnx2x *bp)
 	/* Wait until NIG register shows 1 packet of size 0x10 */
 	count = 1000 * factor;
 	while (count) {
-#ifdef BNX2X_DMAE_RD
+
 		bnx2x_read_dmae(bp, NIG_REG_STAT2_BRB_OCTET, 2);
 		val = *bnx2x_sp(bp, wb_data[0]);
-#else
-		val = REG_RD(bp, NIG_REG_STAT2_BRB_OCTET);
-		REG_RD(bp, NIG_REG_STAT2_BRB_OCTET + 4);
-#endif
 		if (val == 0x10)
 			break;
 
@@ -3533,7 +3983,6 @@ static int bnx2x_int_mem_test(struct bnx2x *bp)
 	count = 1000 * factor;
 	while (count) {
 		val = REG_RD(bp, PRS_REG_NUM_OF_PACKETS);
-
 		if (val == 1)
 			break;
 
@@ -3546,9 +3995,9 @@ static int bnx2x_int_mem_test(struct bnx2x *bp)
 	}
 
 	/* Reset and init BRB, PRS */
-	REG_WR(bp, GRCBASE_MISC + MISC_REGISTERS_RESET_REG_1_CLEAR, 0x3);
+	REG_WR(bp, GRCBASE_MISC + MISC_REGISTERS_RESET_REG_1_CLEAR, 0x03);
 	msleep(50);
-	REG_WR(bp, GRCBASE_MISC + MISC_REGISTERS_RESET_REG_1_SET, 0x3);
+	REG_WR(bp, GRCBASE_MISC + MISC_REGISTERS_RESET_REG_1_SET, 0x03);
 	msleep(50);
 	bnx2x_init_block(bp, BRB1_COMMON_START, BRB1_COMMON_END);
 	bnx2x_init_block(bp, PRS_COMMON_START, PRS_COMMON_END);
@@ -3572,13 +4021,9 @@ static int bnx2x_int_mem_test(struct bnx2x *bp)
 	   packets of size 11*0x10 = 0xb0 */
 	count = 1000 * factor;
 	while (count) {
-#ifdef BNX2X_DMAE_RD
+
 		bnx2x_read_dmae(bp, NIG_REG_STAT2_BRB_OCTET, 2);
 		val = *bnx2x_sp(bp, wb_data[0]);
-#else
-		val = REG_RD(bp, NIG_REG_STAT2_BRB_OCTET);
-		REG_RD(bp, NIG_REG_STAT2_BRB_OCTET + 4);
-#endif
 		if (val == 0xb0)
 			break;
 
@@ -3648,85 +4093,75 @@ static void enable_blocks_attention(struct bnx2x *bp)
 	REG_WR(bp, XSDM_REG_XSDM_INT_MASK_0, 0);
 	REG_WR(bp, XSDM_REG_XSDM_INT_MASK_1, 0);
 	REG_WR(bp, XCM_REG_XCM_INT_MASK, 0);
-/*      REG_WR(bp, XSEM_REG_XSEM_INT_MASK_0, 0); */
-/*      REG_WR(bp, XSEM_REG_XSEM_INT_MASK_1, 0); */
+/*	REG_WR(bp, XSEM_REG_XSEM_INT_MASK_0, 0); */
+/*	REG_WR(bp, XSEM_REG_XSEM_INT_MASK_1, 0); */
 	REG_WR(bp, USDM_REG_USDM_INT_MASK_0, 0);
 	REG_WR(bp, USDM_REG_USDM_INT_MASK_1, 0);
 	REG_WR(bp, UCM_REG_UCM_INT_MASK, 0);
-/*      REG_WR(bp, USEM_REG_USEM_INT_MASK_0, 0); */
-/*      REG_WR(bp, USEM_REG_USEM_INT_MASK_1, 0); */
+/*	REG_WR(bp, USEM_REG_USEM_INT_MASK_0, 0); */
+/*	REG_WR(bp, USEM_REG_USEM_INT_MASK_1, 0); */
 	REG_WR(bp, GRCBASE_UPB + PB_REG_PB_INT_MASK, 0);
 	REG_WR(bp, CSDM_REG_CSDM_INT_MASK_0, 0);
 	REG_WR(bp, CSDM_REG_CSDM_INT_MASK_1, 0);
 	REG_WR(bp, CCM_REG_CCM_INT_MASK, 0);
-/*      REG_WR(bp, CSEM_REG_CSEM_INT_MASK_0, 0); */
-/*      REG_WR(bp, CSEM_REG_CSEM_INT_MASK_1, 0); */
-	REG_WR(bp, PXP2_REG_PXP2_INT_MASK, 0x480000);
+/*	REG_WR(bp, CSEM_REG_CSEM_INT_MASK_0, 0); */
+/*	REG_WR(bp, CSEM_REG_CSEM_INT_MASK_1, 0); */
+	if (CHIP_REV_IS_FPGA(bp))
+		REG_WR(bp, PXP2_REG_PXP2_INT_MASK_0, 0x580000);
+	else
+		REG_WR(bp, PXP2_REG_PXP2_INT_MASK_0, 0x480000);
 	REG_WR(bp, TSDM_REG_TSDM_INT_MASK_0, 0);
 	REG_WR(bp, TSDM_REG_TSDM_INT_MASK_1, 0);
 	REG_WR(bp, TCM_REG_TCM_INT_MASK, 0);
-/*      REG_WR(bp, TSEM_REG_TSEM_INT_MASK_0, 0); */
-/*      REG_WR(bp, TSEM_REG_TSEM_INT_MASK_1, 0); */
+/*	REG_WR(bp, TSEM_REG_TSEM_INT_MASK_0, 0); */
+/*	REG_WR(bp, TSEM_REG_TSEM_INT_MASK_1, 0); */
 	REG_WR(bp, CDU_REG_CDU_INT_MASK, 0);
 	REG_WR(bp, DMAE_REG_DMAE_INT_MASK, 0);
-/*      REG_WR(bp, MISC_REG_MISC_INT_MASK, 0); */
-	REG_WR(bp, PBF_REG_PBF_INT_MASK, 0X18); 	/* bit 3,4 masked */
+/*	REG_WR(bp, MISC_REG_MISC_INT_MASK, 0); */
+	REG_WR(bp, PBF_REG_PBF_INT_MASK, 0X18);		/* bit 3,4 masked */
 }
 
-static int bnx2x_function_init(struct bnx2x *bp, int mode)
+
+static int bnx2x_init_common(struct bnx2x *bp)
 {
-	int func = bp->port;
-	int port = func ? PORT1 : PORT0;
 	u32 val, i;
-#ifdef USE_DMAE
-	u32 wb_write[2];
-#endif
-
-	DP(BNX2X_MSG_MCP, "function is %d  mode is %x\n", func, mode);
-	if ((func != 0) && (func != 1)) {
-		BNX2X_ERR("BAD function number (%d)\n", func);
-		return -ENODEV;
-	}
 
-	bnx2x_gunzip_init(bp);
+	DP(BNX2X_MSG_MCP, "starting common init  func %d\n", BP_FUNC(bp));
 
-	if (mode & 0x1) {       /* init common */
-		DP(BNX2X_MSG_MCP, "starting common init  func %d  mode %x\n",
-		   func, mode);
-		REG_WR(bp, GRCBASE_MISC + MISC_REGISTERS_RESET_REG_1_SET,
-		       0xffffffff);
-		REG_WR(bp, GRCBASE_MISC + MISC_REGISTERS_RESET_REG_2_SET,
-		       0xfffc);
-		bnx2x_init_block(bp, MISC_COMMON_START, MISC_COMMON_END);
+	REG_WR(bp, GRCBASE_MISC + MISC_REGISTERS_RESET_REG_1_SET, 0xffffffff);
+	REG_WR(bp, GRCBASE_MISC + MISC_REGISTERS_RESET_REG_2_SET, 0xfffc);
 
-		REG_WR(bp, MISC_REG_LCPLL_CTRL_REG_2, 0x100);
-		msleep(30);
-		REG_WR(bp, MISC_REG_LCPLL_CTRL_REG_2, 0x0);
+	bnx2x_init_block(bp, MISC_COMMON_START, MISC_COMMON_END);
+	if (CHIP_IS_E1H(bp))
+		REG_WR(bp, MISC_REG_E1HMF_MODE, IS_E1HMF(bp));
 
-		bnx2x_init_block(bp, PXP_COMMON_START, PXP_COMMON_END);
-		bnx2x_init_block(bp, PXP2_COMMON_START, PXP2_COMMON_END);
+	REG_WR(bp, MISC_REG_LCPLL_CTRL_REG_2, 0x100);
+	msleep(30);
+	REG_WR(bp, MISC_REG_LCPLL_CTRL_REG_2, 0x0);
 
-		bnx2x_init_pxp(bp);
+	bnx2x_init_block(bp, PXP_COMMON_START, PXP_COMMON_END);
+	if (CHIP_IS_E1(bp)) {
+		/* enable HW interrupt from PXP on USDM overflow
+		   bit 16 on INT_MASK_0 */
+		REG_WR(bp, PXP_REG_PXP_INT_MASK_0, 0);
+	}
 
-		if (CHIP_REV(bp) == CHIP_REV_Ax) {
-			/* enable HW interrupt from PXP on USDM
-			   overflow bit 16 on INT_MASK_0 */
-			REG_WR(bp, PXP_REG_PXP_INT_MASK_0, 0);
-		}
+	bnx2x_init_block(bp, PXP2_COMMON_START, PXP2_COMMON_END);
+	bnx2x_init_pxp(bp);
 
 #ifdef __BIG_ENDIAN
-		REG_WR(bp, PXP2_REG_RQ_QM_ENDIAN_M, 1);
-		REG_WR(bp, PXP2_REG_RQ_TM_ENDIAN_M, 1);
-		REG_WR(bp, PXP2_REG_RQ_SRC_ENDIAN_M, 1);
-		REG_WR(bp, PXP2_REG_RQ_CDU_ENDIAN_M, 1);
-		REG_WR(bp, PXP2_REG_RQ_DBG_ENDIAN_M, 1);
-		REG_WR(bp, PXP2_REG_RQ_HC_ENDIAN_M, 1);
-
-/*      	REG_WR(bp, PXP2_REG_RD_PBF_SWAP_MODE, 1); */
-		REG_WR(bp, PXP2_REG_RD_QM_SWAP_MODE, 1);
-		REG_WR(bp, PXP2_REG_RD_TM_SWAP_MODE, 1);
-		REG_WR(bp, PXP2_REG_RD_SRC_SWAP_MODE, 1);
-		REG_WR(bp, PXP2_REG_RD_CDURD_SWAP_MODE, 1);
+	REG_WR(bp, PXP2_REG_RQ_QM_ENDIAN_M, 1);
+	REG_WR(bp, PXP2_REG_RQ_TM_ENDIAN_M, 1);
+	REG_WR(bp, PXP2_REG_RQ_SRC_ENDIAN_M, 1);
+	REG_WR(bp, PXP2_REG_RQ_CDU_ENDIAN_M, 1);
+	REG_WR(bp, PXP2_REG_RQ_DBG_ENDIAN_M, 1);
+	REG_WR(bp, PXP2_REG_RQ_HC_ENDIAN_M, 1);
+
+/*	REG_WR(bp, PXP2_REG_RD_PBF_SWAP_MODE, 1); */
+	REG_WR(bp, PXP2_REG_RD_QM_SWAP_MODE, 1);
+	REG_WR(bp, PXP2_REG_RD_TM_SWAP_MODE, 1);
+	REG_WR(bp, PXP2_REG_RD_SRC_SWAP_MODE, 1);
+	REG_WR(bp, PXP2_REG_RD_CDURD_SWAP_MODE, 1);
 #endif
 
 #ifndef BCM_ISCSI
@@ -3734,92 +4169,105 @@ static int bnx2x_function_init(struct bnx2x *bp, int mode)
 		REG_WR(bp, PRS_REG_NIC_MODE, 1);
 #endif
 
-		REG_WR(bp, PXP2_REG_RQ_CDU_P_SIZE, 5);
+	REG_WR(bp, PXP2_REG_RQ_CDU_P_SIZE, 2);
 #ifdef BCM_ISCSI
-		REG_WR(bp, PXP2_REG_RQ_TM_P_SIZE, 5);
-		REG_WR(bp, PXP2_REG_RQ_QM_P_SIZE, 5);
-		REG_WR(bp, PXP2_REG_RQ_SRC_P_SIZE, 5);
+	REG_WR(bp, PXP2_REG_RQ_TM_P_SIZE, 5);
+	REG_WR(bp, PXP2_REG_RQ_QM_P_SIZE, 5);
+	REG_WR(bp, PXP2_REG_RQ_SRC_P_SIZE, 5);
 #endif
 
-		bnx2x_init_block(bp, DMAE_COMMON_START, DMAE_COMMON_END);
+	if (CHIP_REV_IS_FPGA(bp) && CHIP_IS_E1H(bp))
+		REG_WR(bp, PXP2_REG_PGL_TAGS_LIMIT, 0x1);
 
-		/* let the HW do it's magic ... */
-		msleep(100);
-		/* finish PXP init
-		   (can be moved up if we want to use the DMAE) */
-		val = REG_RD(bp, PXP2_REG_RQ_CFG_DONE);
-		if (val != 1) {
-			BNX2X_ERR("PXP2 CFG failed\n");
-			return -EBUSY;
-		}
+	/* let the HW do it's magic ... */
+	msleep(100);
+	/* finish PXP init */
+	val = REG_RD(bp, PXP2_REG_RQ_CFG_DONE);
+	if (val != 1) {
+		BNX2X_ERR("PXP2 CFG failed\n");
+		return -EBUSY;
+	}
+	val = REG_RD(bp, PXP2_REG_RD_INIT_DONE);
+	if (val != 1) {
+		BNX2X_ERR("PXP2 RD_INIT failed\n");
+		return -EBUSY;
+	}
 
-		val = REG_RD(bp, PXP2_REG_RD_INIT_DONE);
-		if (val != 1) {
-			BNX2X_ERR("PXP2 RD_INIT failed\n");
-			return -EBUSY;
-		}
+	REG_WR(bp, PXP2_REG_RQ_DISABLE_INPUTS, 0);
+	REG_WR(bp, PXP2_REG_RD_DISABLE_INPUTS, 0);
 
-		REG_WR(bp, PXP2_REG_RQ_DISABLE_INPUTS, 0);
-		REG_WR(bp, PXP2_REG_RD_DISABLE_INPUTS, 0);
+	bnx2x_init_block(bp, DMAE_COMMON_START, DMAE_COMMON_END);
 
-		bnx2x_init_fill(bp, TSEM_REG_PRAM, 0, 8);
+	/* clean the DMAE memory */
+	bp->dmae_ready = 1;
+	bnx2x_init_fill(bp, TSEM_REG_PRAM, 0, 8);
 
-		bnx2x_init_block(bp, TCM_COMMON_START, TCM_COMMON_END);
-		bnx2x_init_block(bp, UCM_COMMON_START, UCM_COMMON_END);
-		bnx2x_init_block(bp, CCM_COMMON_START, CCM_COMMON_END);
-		bnx2x_init_block(bp, XCM_COMMON_START, XCM_COMMON_END);
+	bnx2x_init_block(bp, TCM_COMMON_START, TCM_COMMON_END);
+	bnx2x_init_block(bp, UCM_COMMON_START, UCM_COMMON_END);
+	bnx2x_init_block(bp, CCM_COMMON_START, CCM_COMMON_END);
+	bnx2x_init_block(bp, XCM_COMMON_START, XCM_COMMON_END);
 
-#ifdef BNX2X_DMAE_RD
-		bnx2x_read_dmae(bp, XSEM_REG_PASSIVE_BUFFER, 3);
-		bnx2x_read_dmae(bp, CSEM_REG_PASSIVE_BUFFER, 3);
-		bnx2x_read_dmae(bp, TSEM_REG_PASSIVE_BUFFER, 3);
-		bnx2x_read_dmae(bp, USEM_REG_PASSIVE_BUFFER, 3);
-#else
-		REG_RD(bp, XSEM_REG_PASSIVE_BUFFER);
-		REG_RD(bp, XSEM_REG_PASSIVE_BUFFER + 4);
-		REG_RD(bp, XSEM_REG_PASSIVE_BUFFER + 8);
-		REG_RD(bp, CSEM_REG_PASSIVE_BUFFER);
-		REG_RD(bp, CSEM_REG_PASSIVE_BUFFER + 4);
-		REG_RD(bp, CSEM_REG_PASSIVE_BUFFER + 8);
-		REG_RD(bp, TSEM_REG_PASSIVE_BUFFER);
-		REG_RD(bp, TSEM_REG_PASSIVE_BUFFER + 4);
-		REG_RD(bp, TSEM_REG_PASSIVE_BUFFER + 8);
-		REG_RD(bp, USEM_REG_PASSIVE_BUFFER);
-		REG_RD(bp, USEM_REG_PASSIVE_BUFFER + 4);
-		REG_RD(bp, USEM_REG_PASSIVE_BUFFER + 8);
-#endif
-		bnx2x_init_block(bp, QM_COMMON_START, QM_COMMON_END);
-		/* soft reset pulse */
-		REG_WR(bp, QM_REG_SOFT_RESET, 1);
-		REG_WR(bp, QM_REG_SOFT_RESET, 0);
+	bnx2x_read_dmae(bp, XSEM_REG_PASSIVE_BUFFER, 3);
+	bnx2x_read_dmae(bp, CSEM_REG_PASSIVE_BUFFER, 3);
+	bnx2x_read_dmae(bp, TSEM_REG_PASSIVE_BUFFER, 3);
+	bnx2x_read_dmae(bp, USEM_REG_PASSIVE_BUFFER, 3);
+
+	bnx2x_init_block(bp, QM_COMMON_START, QM_COMMON_END);
+	/* soft reset pulse */
+	REG_WR(bp, QM_REG_SOFT_RESET, 1);
+	REG_WR(bp, QM_REG_SOFT_RESET, 0);
 
 #ifdef BCM_ISCSI
-		bnx2x_init_block(bp, TIMERS_COMMON_START, TIMERS_COMMON_END);
+	bnx2x_init_block(bp, TIMERS_COMMON_START, TIMERS_COMMON_END);
 #endif
-		bnx2x_init_block(bp, DQ_COMMON_START, DQ_COMMON_END);
-		REG_WR(bp, DORQ_REG_DPM_CID_OFST, BCM_PAGE_BITS);
-		if (CHIP_REV(bp) == CHIP_REV_Ax) {
-			/* enable hw interrupt from doorbell Q */
-			REG_WR(bp, DORQ_REG_DORQ_INT_MASK, 0);
-		}
 
-		bnx2x_init_block(bp, BRB1_COMMON_START, BRB1_COMMON_END);
+	bnx2x_init_block(bp, DQ_COMMON_START, DQ_COMMON_END);
+	REG_WR(bp, DORQ_REG_DPM_CID_OFST, BCM_PAGE_SHIFT);
+	if (!CHIP_REV_IS_SLOW(bp)) {
+		/* enable hw interrupt from doorbell Q */
+		REG_WR(bp, DORQ_REG_DORQ_INT_MASK, 0);
+	}
 
-		if (CHIP_REV_IS_SLOW(bp)) {
-			/* fix for emulation and FPGA for no pause */
-			REG_WR(bp, BRB1_REG_PAUSE_HIGH_THRESHOLD_0, 513);
-			REG_WR(bp, BRB1_REG_PAUSE_HIGH_THRESHOLD_1, 513);
-			REG_WR(bp, BRB1_REG_PAUSE_LOW_THRESHOLD_0, 0);
-			REG_WR(bp, BRB1_REG_PAUSE_LOW_THRESHOLD_1, 0);
-		}
+	bnx2x_init_block(bp, BRB1_COMMON_START, BRB1_COMMON_END);
+	if (CHIP_REV_IS_SLOW(bp)) {
+		/* fix for emulation and FPGA for no pause */
+		REG_WR(bp, BRB1_REG_PAUSE_HIGH_THRESHOLD_0, 513);
+		REG_WR(bp, BRB1_REG_PAUSE_HIGH_THRESHOLD_1, 513);
+		REG_WR(bp, BRB1_REG_PAUSE_LOW_THRESHOLD_0, 0);
+		REG_WR(bp, BRB1_REG_PAUSE_LOW_THRESHOLD_1, 0);
+	}
 
-		bnx2x_init_block(bp, PRS_COMMON_START, PRS_COMMON_END);
+	bnx2x_init_block(bp, PRS_COMMON_START, PRS_COMMON_END);
+	if (CHIP_IS_E1H(bp))
+		REG_WR(bp, PRS_REG_E1HOV_MODE, IS_E1HMF(bp));
 
-		bnx2x_init_block(bp, TSDM_COMMON_START, TSDM_COMMON_END);
-		bnx2x_init_block(bp, CSDM_COMMON_START, CSDM_COMMON_END);
-		bnx2x_init_block(bp, USDM_COMMON_START, USDM_COMMON_END);
-		bnx2x_init_block(bp, XSDM_COMMON_START, XSDM_COMMON_END);
+	bnx2x_init_block(bp, TSDM_COMMON_START, TSDM_COMMON_END);
+	bnx2x_init_block(bp, CSDM_COMMON_START, CSDM_COMMON_END);
+	bnx2x_init_block(bp, USDM_COMMON_START, USDM_COMMON_END);
+	bnx2x_init_block(bp, XSDM_COMMON_START, XSDM_COMMON_END);
 
+	if (CHIP_IS_E1H(bp)) {
+		bnx2x_init_fill(bp, TSTORM_INTMEM_ADDR, 0,
+				STORM_INTMEM_SIZE_E1H/2);
+		bnx2x_init_fill(bp,
+				TSTORM_INTMEM_ADDR + STORM_INTMEM_SIZE_E1H/2,
+				0, STORM_INTMEM_SIZE_E1H/2);
+		bnx2x_init_fill(bp, CSTORM_INTMEM_ADDR, 0,
+				STORM_INTMEM_SIZE_E1H/2);
+		bnx2x_init_fill(bp,
+				CSTORM_INTMEM_ADDR + STORM_INTMEM_SIZE_E1H/2,
+				0, STORM_INTMEM_SIZE_E1H/2);
+		bnx2x_init_fill(bp, XSTORM_INTMEM_ADDR, 0,
+				STORM_INTMEM_SIZE_E1H/2);
+		bnx2x_init_fill(bp,
+				XSTORM_INTMEM_ADDR + STORM_INTMEM_SIZE_E1H/2,
+				0, STORM_INTMEM_SIZE_E1H/2);
+		bnx2x_init_fill(bp, USTORM_INTMEM_ADDR, 0,
+				STORM_INTMEM_SIZE_E1H/2);
+		bnx2x_init_fill(bp,
+				USTORM_INTMEM_ADDR + STORM_INTMEM_SIZE_E1H/2,
+				0, STORM_INTMEM_SIZE_E1H/2);
+	} else { /* E1 */
 		bnx2x_init_fill(bp, TSTORM_INTMEM_ADDR, 0,
 				STORM_INTMEM_SIZE_E1);
 		bnx2x_init_fill(bp, CSTORM_INTMEM_ADDR, 0,
@@ -3828,157 +4276,141 @@ static int bnx2x_function_init(struct bnx2x *bp, int mode)
 				STORM_INTMEM_SIZE_E1);
 		bnx2x_init_fill(bp, USTORM_INTMEM_ADDR, 0,
 				STORM_INTMEM_SIZE_E1);
+	}
 
-		bnx2x_init_block(bp, TSEM_COMMON_START, TSEM_COMMON_END);
-		bnx2x_init_block(bp, USEM_COMMON_START, USEM_COMMON_END);
-		bnx2x_init_block(bp, CSEM_COMMON_START, CSEM_COMMON_END);
-		bnx2x_init_block(bp, XSEM_COMMON_START, XSEM_COMMON_END);
-
-		/* sync semi rtc */
-		REG_WR(bp, GRCBASE_MISC + MISC_REGISTERS_RESET_REG_1_CLEAR,
-		       0x80000000);
-		REG_WR(bp, GRCBASE_MISC + MISC_REGISTERS_RESET_REG_1_SET,
-		       0x80000000);
-
-		bnx2x_init_block(bp, UPB_COMMON_START, UPB_COMMON_END);
-		bnx2x_init_block(bp, XPB_COMMON_START, XPB_COMMON_END);
-		bnx2x_init_block(bp, PBF_COMMON_START, PBF_COMMON_END);
-
-		REG_WR(bp, SRC_REG_SOFT_RST, 1);
-		for (i = SRC_REG_KEYRSS0_0; i <= SRC_REG_KEYRSS1_9; i += 4) {
-			REG_WR(bp, i, 0xc0cac01a);
-			/* TODO: replace with something meaningful */
-		}
-		/* SRCH COMMON comes here */
-		REG_WR(bp, SRC_REG_SOFT_RST, 0);
-
-		if (sizeof(union cdu_context) != 1024) {
-			/* we currently assume that a context is 1024 bytes */
-			printk(KERN_ALERT PFX "please adjust the size of"
-			       " cdu_context(%ld)\n",
-			       (long)sizeof(union cdu_context));
-		}
-		val = (4 << 24) + (0 << 12) + 1024;
-		REG_WR(bp, CDU_REG_CDU_GLOBAL_PARAMS, val);
-		bnx2x_init_block(bp, CDU_COMMON_START, CDU_COMMON_END);
-
-		bnx2x_init_block(bp, CFC_COMMON_START, CFC_COMMON_END);
-		REG_WR(bp, CFC_REG_INIT_REG, 0x7FF);
-
-		bnx2x_init_block(bp, HC_COMMON_START, HC_COMMON_END);
-		bnx2x_init_block(bp, MISC_AEU_COMMON_START,
-				 MISC_AEU_COMMON_END);
-		/* RXPCS COMMON comes here */
-		/* EMAC0 COMMON comes here */
-		/* EMAC1 COMMON comes here */
-		/* DBU COMMON comes here */
-		/* DBG COMMON comes here */
-		bnx2x_init_block(bp, NIG_COMMON_START, NIG_COMMON_END);
+	bnx2x_init_block(bp, TSEM_COMMON_START, TSEM_COMMON_END);
+	bnx2x_init_block(bp, USEM_COMMON_START, USEM_COMMON_END);
+	bnx2x_init_block(bp, CSEM_COMMON_START, CSEM_COMMON_END);
+	bnx2x_init_block(bp, XSEM_COMMON_START, XSEM_COMMON_END);
 
-		if (CHIP_REV_IS_SLOW(bp))
-			msleep(200);
+	/* sync semi rtc */
+	REG_WR(bp, GRCBASE_MISC + MISC_REGISTERS_RESET_REG_1_CLEAR,
+	       0x80000000);
+	REG_WR(bp, GRCBASE_MISC + MISC_REGISTERS_RESET_REG_1_SET,
+	       0x80000000);
 
-		/* finish CFC init */
-		val = REG_RD(bp, CFC_REG_LL_INIT_DONE);
-		if (val != 1) {
-			BNX2X_ERR("CFC LL_INIT failed\n");
-			return -EBUSY;
-		}
+	bnx2x_init_block(bp, UPB_COMMON_START, UPB_COMMON_END);
+	bnx2x_init_block(bp, XPB_COMMON_START, XPB_COMMON_END);
+	bnx2x_init_block(bp, PBF_COMMON_START, PBF_COMMON_END);
 
-		val = REG_RD(bp, CFC_REG_AC_INIT_DONE);
-		if (val != 1) {
-			BNX2X_ERR("CFC AC_INIT failed\n");
-			return -EBUSY;
-		}
+	REG_WR(bp, SRC_REG_SOFT_RST, 1);
+	for (i = SRC_REG_KEYRSS0_0; i <= SRC_REG_KEYRSS1_9; i += 4) {
+		REG_WR(bp, i, 0xc0cac01a);
+		/* TODO: replace with something meaningful */
+	}
+	if (CHIP_IS_E1H(bp))
+		bnx2x_init_block(bp, SRCH_COMMON_START, SRCH_COMMON_END);
+	REG_WR(bp, SRC_REG_SOFT_RST, 0);
 
-		val = REG_RD(bp, CFC_REG_CAM_INIT_DONE);
-		if (val != 1) {
-			BNX2X_ERR("CFC CAM_INIT failed\n");
-			return -EBUSY;
-		}
+	if (sizeof(union cdu_context) != 1024)
+		/* we currently assume that a context is 1024 bytes */
+		printk(KERN_ALERT PFX "please adjust the size of"
+		       " cdu_context(%ld)\n", (long)sizeof(union cdu_context));
 
-		REG_WR(bp, CFC_REG_DEBUG0, 0);
+	bnx2x_init_block(bp, CDU_COMMON_START, CDU_COMMON_END);
+	val = (4 << 24) + (0 << 12) + 1024;
+	REG_WR(bp, CDU_REG_CDU_GLOBAL_PARAMS, val);
+	if (CHIP_IS_E1(bp)) {
+		/* !!! fix pxp client crdit until excel update */
+		REG_WR(bp, CDU_REG_CDU_DEBUG, 0x264);
+		REG_WR(bp, CDU_REG_CDU_DEBUG, 0);
+	}
 
-		/* read NIG statistic
-		   to see if this is our first up since powerup */
-#ifdef BNX2X_DMAE_RD
-		bnx2x_read_dmae(bp, NIG_REG_STAT2_BRB_OCTET, 2);
-		val = *bnx2x_sp(bp, wb_data[0]);
-#else
-		val = REG_RD(bp, NIG_REG_STAT2_BRB_OCTET);
-		REG_RD(bp, NIG_REG_STAT2_BRB_OCTET + 4);
-#endif
-		/* do internal memory self test */
-		if ((val == 0) && bnx2x_int_mem_test(bp)) {
-			BNX2X_ERR("internal mem selftest failed\n");
-			return -EBUSY;
-		}
+	bnx2x_init_block(bp, CFC_COMMON_START, CFC_COMMON_END);
+	REG_WR(bp, CFC_REG_INIT_REG, 0x7FF);
 
-		/* clear PXP2 attentions */
-		REG_RD(bp, PXP2_REG_PXP2_INT_STS_CLR);
+	bnx2x_init_block(bp, HC_COMMON_START, HC_COMMON_END);
+	bnx2x_init_block(bp, MISC_AEU_COMMON_START, MISC_AEU_COMMON_END);
 
-		enable_blocks_attention(bp);
-		/* enable_blocks_parity(bp); */
+	/* PXPCS COMMON comes here */
+	/* Reset PCIE errors for debug */
+	REG_WR(bp, 0x2814, 0xffffffff);
+	REG_WR(bp, 0x3820, 0xffffffff);
 
-		switch (bp->board & SHARED_HW_CFG_BOARD_TYPE_MASK) {
-		case SHARED_HW_CFG_BOARD_TYPE_BCM957710A1022G:
-			/* Fan failure is indicated by SPIO 5 */
-			bnx2x_set_spio(bp, MISC_REGISTERS_SPIO_5,
-				       MISC_REGISTERS_SPIO_INPUT_HI_Z);
+	/* EMAC0 COMMON comes here */
+	/* EMAC1 COMMON comes here */
+	/* DBU COMMON comes here */
+	/* DBG COMMON comes here */
 
-			/* set to active low mode */
-			val = REG_RD(bp, MISC_REG_SPIO_INT);
-			val |= ((1 << MISC_REGISTERS_SPIO_5) <<
+	bnx2x_init_block(bp, NIG_COMMON_START, NIG_COMMON_END);
+	if (CHIP_IS_E1H(bp)) {
+		REG_WR(bp, NIG_REG_LLH_MF_MODE, IS_E1HMF(bp));
+		REG_WR(bp, NIG_REG_LLH_E1HOV_MODE, IS_E1HMF(bp));
+	}
+
+	if (CHIP_REV_IS_SLOW(bp))
+		msleep(200);
+
+	/* finish CFC init */
+	val = reg_poll(bp, CFC_REG_LL_INIT_DONE, 1, 100, 10);
+	if (val != 1) {
+		BNX2X_ERR("CFC LL_INIT failed\n");
+		return -EBUSY;
+	}
+	val = reg_poll(bp, CFC_REG_AC_INIT_DONE, 1, 100, 10);
+	if (val != 1) {
+		BNX2X_ERR("CFC AC_INIT failed\n");
+		return -EBUSY;
+	}
+	val = reg_poll(bp, CFC_REG_CAM_INIT_DONE, 1, 100, 10);
+	if (val != 1) {
+		BNX2X_ERR("CFC CAM_INIT failed\n");
+		return -EBUSY;
+	}
+	REG_WR(bp, CFC_REG_DEBUG0, 0);
+
+	/* read NIG statistic
+	   to see if this is our first up since powerup */
+	bnx2x_read_dmae(bp, NIG_REG_STAT2_BRB_OCTET, 2);
+	val = *bnx2x_sp(bp, wb_data[0]);
+
+	/* do internal memory self test */
+	if ((CHIP_IS_E1(bp)) && (val == 0) && bnx2x_int_mem_test(bp)) {
+		BNX2X_ERR("internal mem self test failed\n");
+		return -EBUSY;
+	}
+
+	switch (bp->common.board & SHARED_HW_CFG_BOARD_TYPE_MASK) {
+	case SHARED_HW_CFG_BOARD_TYPE_BCM957710A1022G:
+		/* Fan failure is indicated by SPIO 5 */
+		bnx2x_set_spio(bp, MISC_REGISTERS_SPIO_5,
+			       MISC_REGISTERS_SPIO_INPUT_HI_Z);
+
+		/* set to active low mode */
+		val = REG_RD(bp, MISC_REG_SPIO_INT);
+		val |= ((1 << MISC_REGISTERS_SPIO_5) <<
 					MISC_REGISTERS_SPIO_INT_OLD_SET_POS);
-			REG_WR(bp, MISC_REG_SPIO_INT, val);
+		REG_WR(bp, MISC_REG_SPIO_INT, val);
 
-			/* enable interrupt to signal the IGU */
-			val = REG_RD(bp, MISC_REG_SPIO_EVENT_EN);
-			val |= (1 << MISC_REGISTERS_SPIO_5);
-			REG_WR(bp, MISC_REG_SPIO_EVENT_EN, val);
-			break;
+		/* enable interrupt to signal the IGU */
+		val = REG_RD(bp, MISC_REG_SPIO_EVENT_EN);
+		val |= (1 << MISC_REGISTERS_SPIO_5);
+		REG_WR(bp, MISC_REG_SPIO_EVENT_EN, val);
+		break;
 
-		default:
-			break;
-		}
+	default:
+		break;
+	}
 
-	} /* end of common init */
+	/* clear PXP2 attentions */
+	REG_RD(bp, PXP2_REG_PXP2_INT_STS_CLR_0);
 
-	/* per port init */
+	enable_blocks_attention(bp);
 
-	/* the phys address is shifted right 12 bits and has an added
-	   1=valid bit added to the 53rd bit
-	   then since this is a wide register(TM)
-	   we split it into two 32 bit writes
-	 */
-#define RQ_ONCHIP_AT_PORT_SIZE  384
-#define ONCHIP_ADDR1(x)   ((u32)(((u64)x >> 12) & 0xFFFFFFFF))
-#define ONCHIP_ADDR2(x)   ((u32)((1 << 20) | ((u64)x >> 44)))
-#define PXP_ONE_ILT(x)    ((x << 10) | x)
+	return 0;
+}
 
-	DP(BNX2X_MSG_MCP, "starting per-function init port is %x\n", func);
+static int bnx2x_init_port(struct bnx2x *bp)
+{
+	int port = BP_PORT(bp);
+	u32 val;
 
-	REG_WR(bp, NIG_REG_MASK_INTERRUPT_PORT0 + func*4, 0);
+	DP(BNX2X_MSG_MCP, "starting port init  port %x\n", port);
+
+	REG_WR(bp, NIG_REG_MASK_INTERRUPT_PORT0 + port*4, 0);
 
 	/* Port PXP comes here */
 	/* Port PXP2 comes here */
-
-	/* Offset is
-	 * Port0  0
-	 * Port1  384 */
-	i = func * RQ_ONCHIP_AT_PORT_SIZE;
-#ifdef USE_DMAE
-	wb_write[0] = ONCHIP_ADDR1(bnx2x_sp_mapping(bp, context));
-	wb_write[1] = ONCHIP_ADDR2(bnx2x_sp_mapping(bp, context));
-	REG_WR_DMAE(bp, PXP2_REG_RQ_ONCHIP_AT + i*8, wb_write, 2);
-#else
-	REG_WR_IND(bp, PXP2_REG_RQ_ONCHIP_AT + i*8,
-		   ONCHIP_ADDR1(bnx2x_sp_mapping(bp, context)));
-	REG_WR_IND(bp, PXP2_REG_RQ_ONCHIP_AT + i*8 + 4,
-		   ONCHIP_ADDR2(bnx2x_sp_mapping(bp, context)));
-#endif
-	REG_WR(bp, PXP2_REG_PSWRQ_CDU0_L2P + func*4, PXP_ONE_ILT(i));
-
 #ifdef BCM_ISCSI
 	/* Port0  1
 	 * Port1  385 */
@@ -4004,30 +4436,9 @@ static int bnx2x_function_init(struct bnx2x *bp, int mode)
 	REG_WR_DMAE(bp, PXP2_REG_RQ_ONCHIP_AT + i*8, wb_write, 2);
 	REG_WR(bp, PXP2_REG_PSWRQ_SRC0_L2P + func*4, PXP_ONE_ILT(i));
 #endif
-
-	/* Port TCM comes here */
-	/* Port UCM comes here */
-	/* Port CCM comes here */
-	bnx2x_init_block(bp, func ? XCM_PORT1_START : XCM_PORT0_START,
-			     func ? XCM_PORT1_END : XCM_PORT0_END);
-
-#ifdef USE_DMAE
-	wb_write[0] = 0;
-	wb_write[1] = 0;
-#endif
-	for (i = 0; i < 32; i++) {
-		REG_WR(bp, QM_REG_BASEADDR + (func*32 + i)*4, 1024 * 4 * i);
-#ifdef USE_DMAE
-		REG_WR_DMAE(bp, QM_REG_PTRTBL + (func*32 + i)*8, wb_write, 2);
-#else
-		REG_WR_IND(bp, QM_REG_PTRTBL + (func*32 + i)*8, 0);
-		REG_WR_IND(bp, QM_REG_PTRTBL + (func*32 + i)*8 + 4, 0);
-#endif
-	}
-	REG_WR(bp, QM_REG_CONNNUM_0 + func*4, 1024/16 - 1);
+	/* Port CMs come here */
 
 	/* Port QM comes here */
-
 #ifdef BCM_ISCSI
 	REG_WR(bp, TM_REG_LIN0_SCAN_TIME + func*4, 1024/64*20);
 	REG_WR(bp, TM_REG_LIN0_MAX_ACTIVE_CID + func*4, 31);
@@ -4042,31 +4453,32 @@ static int bnx2x_function_init(struct bnx2x *bp, int mode)
 	/* Port CSDM comes here */
 	/* Port USDM comes here */
 	/* Port XSDM comes here */
-	bnx2x_init_block(bp, func ? TSEM_PORT1_START : TSEM_PORT0_START,
-			     func ? TSEM_PORT1_END : TSEM_PORT0_END);
-	bnx2x_init_block(bp, func ? USEM_PORT1_START : USEM_PORT0_START,
-			     func ? USEM_PORT1_END : USEM_PORT0_END);
-	bnx2x_init_block(bp, func ? CSEM_PORT1_START : CSEM_PORT0_START,
-			     func ? CSEM_PORT1_END : CSEM_PORT0_END);
-	bnx2x_init_block(bp, func ? XSEM_PORT1_START : XSEM_PORT0_START,
-			     func ? XSEM_PORT1_END : XSEM_PORT0_END);
+	bnx2x_init_block(bp, port ? TSEM_PORT1_START : TSEM_PORT0_START,
+			     port ? TSEM_PORT1_END : TSEM_PORT0_END);
+	bnx2x_init_block(bp, port ? USEM_PORT1_START : USEM_PORT0_START,
+			     port ? USEM_PORT1_END : USEM_PORT0_END);
+	bnx2x_init_block(bp, port ? CSEM_PORT1_START : CSEM_PORT0_START,
+			     port ? CSEM_PORT1_END : CSEM_PORT0_END);
+	bnx2x_init_block(bp, port ? XSEM_PORT1_START : XSEM_PORT0_START,
+			     port ? XSEM_PORT1_END : XSEM_PORT0_END);
 	/* Port UPB comes here */
-	/* Port XSDM comes here */
-	bnx2x_init_block(bp, func ? PBF_PORT1_START : PBF_PORT0_START,
-			     func ? PBF_PORT1_END : PBF_PORT0_END);
+	/* Port XPB comes here */
+
+	bnx2x_init_block(bp, port ? PBF_PORT1_START : PBF_PORT0_START,
+			     port ? PBF_PORT1_END : PBF_PORT0_END);
 
 	/* configure PBF to work without PAUSE mtu 9000 */
-	REG_WR(bp, PBF_REG_P0_PAUSE_ENABLE + func*4, 0);
+	REG_WR(bp, PBF_REG_P0_PAUSE_ENABLE + port*4, 0);
 
 	/* update threshold */
-	REG_WR(bp, PBF_REG_P0_ARB_THRSH + func*4, (9040/16));
+	REG_WR(bp, PBF_REG_P0_ARB_THRSH + port*4, (9040/16));
 	/* update init credit */
-	REG_WR(bp, PBF_REG_P0_INIT_CRD + func*4, (9040/16) + 553 - 22);
+	REG_WR(bp, PBF_REG_P0_INIT_CRD + port*4, (9040/16) + 553 - 22);
 
 	/* probe changes */
-	REG_WR(bp, PBF_REG_INIT_P0 + func*4, 1);
+	REG_WR(bp, PBF_REG_INIT_P0 + port*4, 1);
 	msleep(5);
-	REG_WR(bp, PBF_REG_INIT_P0 + func*4, 0);
+	REG_WR(bp, PBF_REG_INIT_P0 + port*4, 0);
 
 #ifdef BCM_ISCSI
 	/* tell the searcher where the T2 table is */
@@ -4084,23 +4496,57 @@ static int bnx2x_function_init(struct bnx2x *bp, int mode)
 #endif
 	/* Port CDU comes here */
 	/* Port CFC comes here */
-	bnx2x_init_block(bp, func ? HC_PORT1_START : HC_PORT0_START,
-			     func ? HC_PORT1_END : HC_PORT0_END);
-	bnx2x_init_block(bp, func ? MISC_AEU_PORT1_START :
+
+	if (CHIP_IS_E1(bp)) {
+		REG_WR(bp, HC_REG_LEADING_EDGE_0 + port*8, 0);
+		REG_WR(bp, HC_REG_TRAILING_EDGE_0 + port*8, 0);
+	}
+	bnx2x_init_block(bp, port ? HC_PORT1_START : HC_PORT0_START,
+			     port ? HC_PORT1_END : HC_PORT0_END);
+
+	bnx2x_init_block(bp, port ? MISC_AEU_PORT1_START :
 				    MISC_AEU_PORT0_START,
-			     func ? MISC_AEU_PORT1_END : MISC_AEU_PORT0_END);
+			     port ? MISC_AEU_PORT1_END : MISC_AEU_PORT0_END);
+	/* init aeu_mask_attn_func_0/1:
+	 *  - SF mode: bits 3-7 are masked. only bits 0-2 are in use
+	 *  - MF mode: bit 3 is masked. bits 0-2 are in use as in SF
+	 *             bits 4-7 are used for "per vn group attention" */
+	REG_WR(bp, MISC_REG_AEU_MASK_ATTN_FUNC_0 + port*4,
+	       (IS_E1HMF(bp) ? 0xF7 : 0x7));
+
 	/* Port PXPCS comes here */
 	/* Port EMAC0 comes here */
 	/* Port EMAC1 comes here */
 	/* Port DBU comes here */
 	/* Port DBG comes here */
-	bnx2x_init_block(bp, func ? NIG_PORT1_START : NIG_PORT0_START,
-			     func ? NIG_PORT1_END : NIG_PORT0_END);
-	REG_WR(bp, NIG_REG_XGXS_SERDES0_MODE_SEL + func*4, 1);
+	bnx2x_init_block(bp, port ? NIG_PORT1_START : NIG_PORT0_START,
+			     port ? NIG_PORT1_END : NIG_PORT0_END);
+
+	REG_WR(bp, NIG_REG_XGXS_SERDES0_MODE_SEL + port*4, 1);
+
+	if (CHIP_IS_E1H(bp)) {
+		u32 wsum;
+		struct cmng_struct_per_port m_cmng_port;
+		int vn;
+
+		/* 0x2 disable e1hov, 0x1 enable */
+		REG_WR(bp, NIG_REG_LLH0_BRB1_DRV_MASK_MF + port*4,
+		       (IS_E1HMF(bp) ? 0x1 : 0x2));
+
+		/* Init RATE SHAPING and FAIRNESS contexts.
+		   Initialize as if there is 10G link. */
+		wsum = bnx2x_calc_vn_wsum(bp);
+		bnx2x_init_port_minmax(bp, (int)wsum, 10000, &m_cmng_port);
+		if (IS_E1HMF(bp))
+			for (vn = VN_0; vn < E1HVN_MAX; vn++)
+				bnx2x_init_vn_minmax(bp, 2*vn + port,
+					wsum, 10000, &m_cmng_port);
+	}
+
 	/* Port MCP comes here */
 	/* Port DMAE comes here */
 
-	switch (bp->board & SHARED_HW_CFG_BOARD_TYPE_MASK) {
+	switch (bp->common.board & SHARED_HW_CFG_BOARD_TYPE_MASK) {
 	case SHARED_HW_CFG_BOARD_TYPE_BCM957710A1022G:
 		/* add SPIO 5 to group 0 */
 		val = REG_RD(bp, MISC_REG_AEU_ENABLE1_FUNC_0_OUT_0);
@@ -4114,48 +4560,150 @@ static int bnx2x_function_init(struct bnx2x *bp, int mode)
 
 	bnx2x__link_reset(bp);
 
+	return 0;
+}
+
+#define ILT_PER_FUNC		(768/2)
+#define FUNC_ILT_BASE(func)	(func * ILT_PER_FUNC)
+/* the phys address is shifted right 12 bits and has an added
+   1=valid bit added to the 53rd bit
+   then since this is a wide register(TM)
+   we split it into two 32 bit writes
+ */
+#define ONCHIP_ADDR1(x)		((u32)(((u64)x >> 12) & 0xFFFFFFFF))
+#define ONCHIP_ADDR2(x)		((u32)((1 << 20) | ((u64)x >> 44)))
+#define PXP_ONE_ILT(x)		(((x) << 10) | x)
+#define PXP_ILT_RANGE(f, l)	(((l) << 10) | f)
+
+#define CNIC_ILT_LINES		0
+
+static void bnx2x_ilt_wr(struct bnx2x *bp, u32 index, dma_addr_t addr)
+{
+	int reg;
+
+	if (CHIP_IS_E1H(bp))
+		reg = PXP2_REG_RQ_ONCHIP_AT_B0 + index*8;
+	else /* E1 */
+		reg = PXP2_REG_RQ_ONCHIP_AT + index*8;
+
+	bnx2x_wb_wr(bp, reg, ONCHIP_ADDR1(addr), ONCHIP_ADDR2(addr));
+}
+
+static int bnx2x_init_func(struct bnx2x *bp)
+{
+	int port = BP_PORT(bp);
+	int func = BP_FUNC(bp);
+	int i;
+
+	DP(BNX2X_MSG_MCP, "starting func init  func %x\n", func);
+
+	i = FUNC_ILT_BASE(func);
+
+	bnx2x_ilt_wr(bp, i, bnx2x_sp_mapping(bp, context));
+	if (CHIP_IS_E1H(bp)) {
+		REG_WR(bp, PXP2_REG_RQ_CDU_FIRST_ILT, i);
+		REG_WR(bp, PXP2_REG_RQ_CDU_LAST_ILT, i + CNIC_ILT_LINES);
+	} else /* E1 */
+		REG_WR(bp, PXP2_REG_PSWRQ_CDU0_L2P + func*4,
+		       PXP_ILT_RANGE(i, i + CNIC_ILT_LINES));
+
+
+	if (CHIP_IS_E1H(bp)) {
+		for (i = 0; i < 9; i++)
+			bnx2x_init_block(bp,
+					 cm_start[func][i], cm_end[func][i]);
+
+		REG_WR(bp, NIG_REG_LLH0_FUNC_EN + port*8, 1);
+		REG_WR(bp, NIG_REG_LLH0_FUNC_VLAN_ID + port*8, bp->e1hov);
+	}
+
+	/* HC init per function */
+	if (CHIP_IS_E1H(bp)) {
+		REG_WR(bp, MISC_REG_AEU_GENERAL_ATTN_12 + func*4, 0);
+
+		REG_WR(bp, HC_REG_LEADING_EDGE_0 + port*8, 0);
+		REG_WR(bp, HC_REG_TRAILING_EDGE_0 + port*8, 0);
+	}
+	bnx2x_init_block(bp, hc_limits[func][0], hc_limits[func][1]);
+
+	if (CHIP_IS_E1H(bp))
+		REG_WR(bp, HC_REG_FUNC_NUM_P0 + port*4, func);
+
 	/* Reset PCIE errors for debug */
 	REG_WR(bp, 0x2114, 0xffffffff);
 	REG_WR(bp, 0x2120, 0xffffffff);
-	REG_WR(bp, 0x2814, 0xffffffff);
 
-	/* !!! move to init_values.h */
-	REG_WR(bp, XSDM_REG_INIT_CREDIT_PXP_CTRL, 0x1);
-	REG_WR(bp, USDM_REG_INIT_CREDIT_PXP_CTRL, 0x1);
-	REG_WR(bp, CSDM_REG_INIT_CREDIT_PXP_CTRL, 0x1);
-	REG_WR(bp, TSDM_REG_INIT_CREDIT_PXP_CTRL, 0x1);
+	return 0;
+}
+
+static int bnx2x_init_hw(struct bnx2x *bp, u32 load_code)
+{
+	int i, rc = 0;
 
-	REG_WR(bp, DBG_REG_PCI_REQ_CREDIT, 0x1);
-	REG_WR(bp, TM_REG_PCIARB_CRDCNT_VAL, 0x1);
-	REG_WR(bp, CDU_REG_CDU_DEBUG, 0x264);
-	REG_WR(bp, CDU_REG_CDU_DEBUG, 0x0);
+	DP(BNX2X_MSG_MCP, "function %d  load_code %x\n",
+	   BP_FUNC(bp), load_code);
 
-	bnx2x_gunzip_end(bp);
+	bp->dmae_ready = 0;
+	mutex_init(&bp->dmae_mutex);
+	bnx2x_gunzip_init(bp);
 
-	if (!nomcp) {
-		port = bp->port;
+	switch (load_code) {
+	case FW_MSG_CODE_DRV_LOAD_COMMON:
+		rc = bnx2x_init_common(bp);
+		if (rc)
+			goto init_hw_err;
+		/* no break */
+
+	case FW_MSG_CODE_DRV_LOAD_PORT:
+		bp->dmae_ready = 1;
+		rc = bnx2x_init_port(bp);
+		if (rc)
+			goto init_hw_err;
+		/* no break */
+
+	case FW_MSG_CODE_DRV_LOAD_FUNCTION:
+		bp->dmae_ready = 1;
+		rc = bnx2x_init_func(bp);
+		if (rc)
+			goto init_hw_err;
+		break;
+
+	default:
+		BNX2X_ERR("Unknown load_code (0x%x) from MCP\n", load_code);
+		break;
+	}
+
+	if (!BP_NOMCP(bp)) {
+		int func = BP_FUNC(bp);
 
 		bp->fw_drv_pulse_wr_seq =
-				(SHMEM_RD(bp, func_mb[port].drv_pulse_mb) &
+				(SHMEM_RD(bp, func_mb[func].drv_pulse_mb) &
 				 DRV_PULSE_SEQ_MASK);
-		bp->fw_mb = SHMEM_RD(bp, func_mb[port].fw_mb_param);
-		DP(BNX2X_MSG_MCP, "drv_pulse 0x%x  fw_mb 0x%x\n",
-		   bp->fw_drv_pulse_wr_seq, bp->fw_mb);
-	} else {
-		bp->fw_mb = 0;
-	}
+		bp->func_stx = SHMEM_RD(bp, func_mb[func].fw_mb_param);
+		DP(BNX2X_MSG_MCP, "drv_pulse 0x%x  func_stx 0x%x\n",
+		   bp->fw_drv_pulse_wr_seq, bp->func_stx);
+	} else
+		bp->func_stx = 0;
 
-	return 0;
+	/* this needs to be done before gunzip end */
+	bnx2x_zero_def_sb(bp);
+	for_each_queue(bp, i)
+		bnx2x_zero_sb(bp, BP_L_ID(bp) + i);
+
+init_hw_err:
+	bnx2x_gunzip_end(bp);
+
+	return rc;
 }
 
 /* send the MCP a request, block until there is a reply */
 static u32 bnx2x_fw_command(struct bnx2x *bp, u32 command)
 {
-	int port = bp->port;
+	int func = BP_FUNC(bp);
 	u32 seq = ++bp->fw_seq;
 	u32 rc = 0;
 
-	SHMEM_WR(bp, func_mb[port].drv_mb_header, (command | seq));
+	SHMEM_WR(bp, func_mb[func].drv_mb_header, (command | seq));
 	DP(BNX2X_MSG_MCP, "wrote command (%x) to FW MB\n", (command | seq));
 
 	/* let the FW do it's magic ... */
@@ -4164,7 +4712,7 @@ static u32 bnx2x_fw_command(struct bnx2x *bp, u32 command)
 	if (CHIP_REV_IS_SLOW(bp))
 		msleep(900);
 
-	rc = SHMEM_RD(bp, func_mb[port].fw_mb_header);
+	rc = SHMEM_RD(bp, func_mb[func].fw_mb_header);
 	DP(BNX2X_MSG_MCP, "read (%x) seq is (%x) from FW MB\n", rc, seq);
 
 	/* is this a reply to our command? */
@@ -4229,15 +4777,13 @@ static void bnx2x_free_mem(struct bnx2x *bp)
 			       NUM_RCQ_BD);
 	}
 
-	BNX2X_FREE(bp->fp);
-
 	/* end of fastpath */
 
 	BNX2X_PCI_FREE(bp->def_status_blk, bp->def_status_blk_mapping,
-		       (sizeof(struct host_def_status_block)));
+		       sizeof(struct host_def_status_block));
 
 	BNX2X_PCI_FREE(bp->slowpath, bp->slowpath_mapping,
-		       (sizeof(struct bnx2x_slowpath)));
+		       sizeof(struct bnx2x_slowpath));
 
 #ifdef BCM_ISCSI
 	BNX2X_PCI_FREE(bp->t1, bp->t1_mapping, 64*1024);
@@ -4273,8 +4819,6 @@ static int bnx2x_alloc_mem(struct bnx2x *bp)
 	int i;
 
 	/* fastpath */
-	BNX2X_ALLOC(bp->fp, sizeof(struct bnx2x_fastpath) * bp->num_queues);
-
 	for_each_queue(bp, i) {
 		bnx2x_fp(bp, i, bp) = bp;
 
@@ -4370,8 +4914,6 @@ static void bnx2x_free_tx_skbs(struct bnx2x *bp)
 		u16 sw_prod = fp->tx_pkt_prod;
 		u16 sw_cons = fp->tx_pkt_cons;
 
-		BUG_TRAP(fp->tx_buf_ring != NULL);
-
 		while (sw_cons != sw_prod) {
 			bd_cons = bnx2x_free_tx_pkt(bp, fp, TX_BD(sw_cons));
 			sw_cons++;
@@ -4386,8 +4928,6 @@ static void bnx2x_free_rx_skbs(struct bnx2x *bp)
 	for_each_queue(bp, j) {
 		struct bnx2x_fastpath *fp = &bp->fp[j];
 
-		BUG_TRAP(fp->rx_buf_ring != NULL);
-
 		for (i = 0; i < NUM_RX_BD; i++) {
 			struct sw_rx_bd *rx_buf = &fp->rx_buf_ring[i];
 			struct sk_buff *skb = rx_buf->skb;
@@ -4414,7 +4954,7 @@ static void bnx2x_free_skbs(struct bnx2x *bp)
 
 static void bnx2x_free_msix_irqs(struct bnx2x *bp)
 {
-	int i;
+	int i, offset = 1;
 
 	free_irq(bp->msix_table[0].vector, bp->dev);
 	DP(NETIF_MSG_IFDOWN, "released sp irq (%d)\n",
@@ -4422,26 +4962,22 @@ static void bnx2x_free_msix_irqs(struct bnx2x *bp)
 
 	for_each_queue(bp, i) {
 		DP(NETIF_MSG_IFDOWN, "about to release fp #%d->%d irq  "
-		   "state(%x)\n", i, bp->msix_table[i + 1].vector,
+		   "state %x\n", i, bp->msix_table[i + offset].vector,
 		   bnx2x_fp(bp, i, state));
 
 		if (bnx2x_fp(bp, i, state) != BNX2X_FP_STATE_CLOSED)
 			BNX2X_ERR("IRQ of fp #%d being freed while "
 				  "state != closed\n", i);
 
-		free_irq(bp->msix_table[i + 1].vector, &bp->fp[i]);
+		free_irq(bp->msix_table[i + offset].vector, &bp->fp[i]);
 	}
-
 }
 
 static void bnx2x_free_irq(struct bnx2x *bp)
 {
-
 	if (bp->flags & USING_MSIX_FLAG) {
-
 		bnx2x_free_msix_irqs(bp);
 		pci_disable_msix(bp->pdev);
-
 		bp->flags &= ~USING_MSIX_FLAG;
 
 	} else
@@ -4450,87 +4986,87 @@ static void bnx2x_free_irq(struct bnx2x *bp)
 
 static int bnx2x_enable_msix(struct bnx2x *bp)
 {
-
-	int i;
+	int i, rc, offset;
 
 	bp->msix_table[0].entry = 0;
-	for_each_queue(bp, i)
-		bp->msix_table[i + 1].entry = i + 1;
+	offset = 1;
+	DP(NETIF_MSG_IFUP, "msix_table[0].entry = 0 (slowpath)\n");
 
-	if (pci_enable_msix(bp->pdev, &bp->msix_table[0],
-				     bp->num_queues + 1)){
-		BNX2X_LOG("failed to enable MSI-X\n");
-		return -1;
+	for_each_queue(bp, i) {
+		int igu_vec = offset + i + BP_L_ID(bp);
 
+		bp->msix_table[i + offset].entry = igu_vec;
+		DP(NETIF_MSG_IFUP, "msix_table[%d].entry = %d "
+		   "(fastpath #%u)\n", i + offset, igu_vec, i);
 	}
 
+	rc = pci_enable_msix(bp->pdev, &bp->msix_table[0],
+			     bp->num_queues + offset);
+	if (rc) {
+		DP(NETIF_MSG_IFUP, "MSI-X is not attainable\n");
+		return -1;
+	}
 	bp->flags |= USING_MSIX_FLAG;
 
 	return 0;
-
 }
 
-
 static int bnx2x_req_msix_irqs(struct bnx2x *bp)
 {
-
-	int i, rc;
+	int i, rc, offset = 1;
 
 	rc = request_irq(bp->msix_table[0].vector, bnx2x_msix_sp_int, 0,
 			 bp->dev->name, bp->dev);
-
 	if (rc) {
 		BNX2X_ERR("request sp irq failed\n");
 		return -EBUSY;
 	}
 
 	for_each_queue(bp, i) {
-		rc = request_irq(bp->msix_table[i + 1].vector,
+		rc = request_irq(bp->msix_table[i + offset].vector,
 				 bnx2x_msix_fp_int, 0,
 				 bp->dev->name, &bp->fp[i]);
-
 		if (rc) {
-			BNX2X_ERR("request fp #%d irq failed  "
-				  "rc %d\n", i, rc);
+			BNX2X_ERR("request fp #%d irq failed  rc %d\n",
+				  i + offset, rc);
 			bnx2x_free_msix_irqs(bp);
 			return -EBUSY;
 		}
 
 		bnx2x_fp(bp, i, state) = BNX2X_FP_STATE_IRQ;
-
 	}
 
 	return 0;
-
 }
 
 static int bnx2x_req_irq(struct bnx2x *bp)
 {
+	int rc;
 
-	int rc = request_irq(bp->pdev->irq, bnx2x_interrupt,
-			     IRQF_SHARED, bp->dev->name, bp->dev);
+	rc = request_irq(bp->pdev->irq, bnx2x_interrupt, IRQF_SHARED,
+			 bp->dev->name, bp->dev);
 	if (!rc)
 		bnx2x_fp(bp, 0, state) = BNX2X_FP_STATE_IRQ;
 
 	return rc;
-
 }
 
 /*
  * Init service functions
  */
 
-static void bnx2x_set_mac_addr(struct bnx2x *bp)
+static void bnx2x_set_mac_addr_e1(struct bnx2x *bp)
 {
 	struct mac_configuration_cmd *config = bnx2x_sp(bp, mac_config);
+	int port = BP_PORT(bp);
 
 	/* CAM allocation
 	 * unicasts 0-31:port0 32-63:port1
 	 * multicast 64-127:port0 128-191:port1
 	 */
 	config->hdr.length_6b = 2;
-	config->hdr.offset = bp->port ? 31 : 0;
-	config->hdr.reserved0 = 0;
+	config->hdr.offset = port ? 31 : 0;
+	config->hdr.client_id = BP_CL_ID(bp);
 	config->hdr.reserved1 = 0;
 
 	/* primary MAC */
@@ -4540,7 +5076,7 @@ static void bnx2x_set_mac_addr(struct bnx2x *bp)
 					swab16(*(u16 *)&bp->dev->dev_addr[2]);
 	config->config_table[0].cam_entry.lsb_mac_addr =
 					swab16(*(u16 *)&bp->dev->dev_addr[4]);
-	config->config_table[0].cam_entry.flags = cpu_to_le16(bp->port);
+	config->config_table[0].cam_entry.flags = cpu_to_le16(port);
 	config->config_table[0].target_table_entry.flags = 0;
 	config->config_table[0].target_table_entry.client_id = 0;
 	config->config_table[0].target_table_entry.vlan_id = 0;
@@ -4554,7 +5090,7 @@ static void bnx2x_set_mac_addr(struct bnx2x *bp)
 	config->config_table[1].cam_entry.msb_mac_addr = 0xffff;
 	config->config_table[1].cam_entry.middle_mac_addr = 0xffff;
 	config->config_table[1].cam_entry.lsb_mac_addr = 0xffff;
-	config->config_table[1].cam_entry.flags = cpu_to_le16(bp->port);
+	config->config_table[1].cam_entry.flags = cpu_to_le16(port);
 	config->config_table[1].target_table_entry.flags =
 				TSTORM_CAM_TARGET_TABLE_ENTRY_BROADCAST;
 	config->config_table[1].target_table_entry.client_id = 0;
@@ -4565,64 +5101,105 @@ static void bnx2x_set_mac_addr(struct bnx2x *bp)
 		      U64_LO(bnx2x_sp_mapping(bp, mac_config)), 0);
 }
 
+static void bnx2x_set_mac_addr_e1h(struct bnx2x *bp)
+{
+	struct mac_configuration_cmd_e1h *config =
+		(struct mac_configuration_cmd_e1h *)bnx2x_sp(bp, mac_config);
+
+	if (bp->state != BNX2X_STATE_OPEN) {
+		DP(NETIF_MSG_IFUP, "state is %x, returning\n", bp->state);
+		return;
+	}
+
+	/* CAM allocation for E1H
+	 * unicasts: by func number
+	 * multicast: 20+FUNC*20, 20 each
+	 */
+	config->hdr.length_6b = 1;
+	config->hdr.offset = BP_FUNC(bp);
+	config->hdr.client_id = BP_CL_ID(bp);
+	config->hdr.reserved1 = 0;
+
+	/* primary MAC */
+	config->config_table[0].msb_mac_addr =
+					swab16(*(u16 *)&bp->dev->dev_addr[0]);
+	config->config_table[0].middle_mac_addr =
+					swab16(*(u16 *)&bp->dev->dev_addr[2]);
+	config->config_table[0].lsb_mac_addr =
+					swab16(*(u16 *)&bp->dev->dev_addr[4]);
+	config->config_table[0].client_id = BP_L_ID(bp);
+	config->config_table[0].vlan_id = 0;
+	config->config_table[0].e1hov_id = cpu_to_le16(bp->e1hov);
+	config->config_table[0].flags = BP_PORT(bp);
+
+	DP(NETIF_MSG_IFUP, "setting MAC (%04x:%04x:%04x)  E1HOV %d  CLID %d\n",
+	   config->config_table[0].msb_mac_addr,
+	   config->config_table[0].middle_mac_addr,
+	   config->config_table[0].lsb_mac_addr, bp->e1hov, BP_L_ID(bp));
+
+	bnx2x_sp_post(bp, RAMROD_CMD_ID_ETH_SET_MAC, 0,
+		      U64_HI(bnx2x_sp_mapping(bp, mac_config)),
+		      U64_LO(bnx2x_sp_mapping(bp, mac_config)), 0);
+}
+
 static int bnx2x_wait_ramrod(struct bnx2x *bp, int state, int idx,
 			     int *state_p, int poll)
 {
 	/* can take a while if any port is running */
-	int timeout = 500;
+	int cnt = 500;
 
 	DP(NETIF_MSG_IFUP, "%s for state to become %x on IDX [%d]\n",
 	   poll ? "polling" : "waiting", state, idx);
 
 	might_sleep();
-
-	while (timeout) {
-
+	while (cnt--) {
 		if (poll) {
 			bnx2x_rx_int(bp->fp, 10);
-			/* If index is different from 0
-			 * The reply for some commands will
+			/* if index is different from 0
+			 * the reply for some commands will
 			 * be on the none default queue
 			 */
 			if (idx)
 				bnx2x_rx_int(&bp->fp[idx], 10);
 		}
-
-		mb(); /* state is changed by bnx2x_sp_event()*/
+		mb(); /* state is changed by bnx2x_sp_event() */
 
 		if (*state_p == state)
 			return 0;
 
-		timeout--;
 		msleep(1);
-
 	}
 
 	/* timeout! */
 	BNX2X_ERR("timeout %s for state %x on IDX [%d]\n",
 		  poll ? "polling" : "waiting", state, idx);
+#ifdef BNX2X_STOP_ON_ERROR
+	bnx2x_panic();
+#endif
 
 	return -EBUSY;
 }
 
 static int bnx2x_setup_leading(struct bnx2x *bp)
 {
+	int rc;
 
 	/* reset IGU state */
-	bnx2x_ack_sb(bp, DEF_SB_ID, CSTORM_ID, 0, IGU_INT_ENABLE, 0);
+	bnx2x_ack_sb(bp, bp->fp[0].sb_id, CSTORM_ID, 0, IGU_INT_ENABLE, 0);
 
 	/* SETUP ramrod */
 	bnx2x_sp_post(bp, RAMROD_CMD_ID_ETH_PORT_SETUP, 0, 0, 0, 0);
 
-	return bnx2x_wait_ramrod(bp, BNX2X_STATE_OPEN, 0, &(bp->state), 0);
+	/* Wait for completion */
+	rc = bnx2x_wait_ramrod(bp, BNX2X_STATE_OPEN, 0, &(bp->state), 0);
 
+	return rc;
 }
 
 static int bnx2x_setup_multi(struct bnx2x *bp, int index)
 {
-
 	/* reset IGU state */
-	bnx2x_ack_sb(bp, index, CSTORM_ID, 0, IGU_INT_ENABLE, 0);
+	bnx2x_ack_sb(bp, bp->fp[index].sb_id, CSTORM_ID, 0, IGU_INT_ENABLE, 0);
 
 	/* SETUP ramrod */
 	bp->fp[index].state = BNX2X_FP_STATE_OPENING;
@@ -4631,82 +5208,107 @@ static int bnx2x_setup_multi(struct bnx2x *bp, int index)
 	/* Wait for completion */
 	return bnx2x_wait_ramrod(bp, BNX2X_FP_STATE_OPEN, index,
 				 &(bp->fp[index].state), 0);
-
 }
 
-
 static int bnx2x_poll(struct napi_struct *napi, int budget);
 static void bnx2x_set_rx_mode(struct net_device *dev);
 
-static int bnx2x_nic_load(struct bnx2x *bp, int req_irq)
+/* must be called with rtnl_lock */
+static int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
 {
 	u32 load_code;
-	int i;
+	int i, rc;
+
+#ifdef BNX2X_STOP_ON_ERROR
+	if (unlikely(bp->panic))
+		return -EPERM;
+#endif
 
 	bp->state = BNX2X_STATE_OPENING_WAIT4_LOAD;
 
-	/* Send LOAD_REQUEST command to MCP.
-	   Returns the type of LOAD command: if it is the
-	   first port to be initialized common blocks should be
-	   initialized, otherwise - not.
+	/* Send LOAD_REQUEST command to MCP
+	   Returns the type of LOAD command:
+	   if it is the first port to be initialized
+	   common blocks should be initialized, otherwise - not
 	*/
-	if (!nomcp) {
+	if (!BP_NOMCP(bp)) {
 		load_code = bnx2x_fw_command(bp, DRV_MSG_CODE_LOAD_REQ);
 		if (!load_code) {
 			BNX2X_ERR("MCP response failure, unloading\n");
 			return -EBUSY;
 		}
-		if (load_code == FW_MSG_CODE_DRV_LOAD_REFUSED) {
-			BNX2X_ERR("MCP refused load request, unloading\n");
+		if (load_code == FW_MSG_CODE_DRV_LOAD_REFUSED)
 			return -EBUSY; /* other port in diagnostic mode */
-		}
+
 	} else {
-		load_code = FW_MSG_CODE_DRV_LOAD_COMMON;
+		DP(NETIF_MSG_IFUP, "NO MCP load counts before us %d, %d, %d\n",
+		   load_count[0], load_count[1], load_count[2]);
+		load_count[0]++;
+		load_count[1 + BP_PORT(bp)]++;
+		DP(NETIF_MSG_IFUP, "NO MCP new load counts       %d, %d, %d\n",
+		   load_count[0], load_count[1], load_count[2]);
+		if (load_count[0] == 1)
+			load_code = FW_MSG_CODE_DRV_LOAD_COMMON;
+		else if (load_count[1 + BP_PORT(bp)] == 1)
+			load_code = FW_MSG_CODE_DRV_LOAD_PORT;
+		else
+			load_code = FW_MSG_CODE_DRV_LOAD_FUNCTION;
 	}
 
-	/* if we can't use msix we only need one fp,
-	 * so try to enable msix with the requested number of fp's
+	if ((load_code == FW_MSG_CODE_DRV_LOAD_COMMON) ||
+	    (load_code == FW_MSG_CODE_DRV_LOAD_PORT))
+		bp->port.pmf = 1;
+	else
+		bp->port.pmf = 0;
+	DP(NETIF_MSG_LINK, "pmf %d\n", bp->port.pmf);
+
+	/* if we can't use MSI-X we only need one fp,
+	 * so try to enable MSI-X with the requested number of fp's
 	 * and fallback to inta with one fp
 	 */
-	if (req_irq) {
-		if (use_inta) {
+	if (use_inta) {
+		bp->num_queues = 1;
+
+	} else {
+		if ((use_multi > 1) && (use_multi <= BP_MAX_QUEUES(bp)))
+			/* user requested number */
+			bp->num_queues = use_multi;
+
+		else if (use_multi)
+			bp->num_queues = min_t(u32, num_online_cpus(),
+					       BP_MAX_QUEUES(bp));
+		else
 			bp->num_queues = 1;
-		} else {
-			if ((use_multi > 1) && (use_multi <= 16))
-				/* user requested number */
-				bp->num_queues = use_multi;
-			else if (use_multi == 1)
-				bp->num_queues = num_online_cpus();
-			else
-				bp->num_queues = 1;
-
-			if (bnx2x_enable_msix(bp)) {
-				/* failed to enable msix */
-				bp->num_queues = 1;
-				if (use_multi)
-					BNX2X_ERR("Multi requested but failed"
-						  " to enable MSI-X\n");
-			}
+
+		if (bnx2x_enable_msix(bp)) {
+			/* failed to enable MSI-X */
+			bp->num_queues = 1;
+			if (use_multi)
+				BNX2X_ERR("Multi requested but failed"
+					  " to enable MSI-X\n");
 		}
 	}
-
-	DP(NETIF_MSG_IFUP, "set number of queues to %d\n", bp->num_queues);
+	DP(NETIF_MSG_IFUP,
+	   "set number of queues to %d\n", bp->num_queues);
 
 	if (bnx2x_alloc_mem(bp))
 		return -ENOMEM;
 
-	if (req_irq) {
-		if (bp->flags & USING_MSIX_FLAG) {
-			if (bnx2x_req_msix_irqs(bp)) {
-				pci_disable_msix(bp->pdev);
-				goto load_error;
-			}
+	/* Disable interrupt handling until HW is initialized */
+	atomic_set(&bp->intr_sem, 1);
 
-		} else {
-			if (bnx2x_req_irq(bp)) {
-				BNX2X_ERR("IRQ request failed, aborting\n");
-				goto load_error;
-			}
+	if (bp->flags & USING_MSIX_FLAG) {
+		rc = bnx2x_req_msix_irqs(bp);
+		if (rc) {
+			pci_disable_msix(bp->pdev);
+			goto load_error;
+		}
+	} else {
+		bnx2x_ack_int(bp);
+		rc = bnx2x_req_irq(bp);
+		if (rc) {
+			BNX2X_ERR("IRQ request failed, aborting\n");
+			goto load_error;
 		}
 	}
 
@@ -4714,26 +5316,25 @@ static int bnx2x_nic_load(struct bnx2x *bp, int req_irq)
 		netif_napi_add(bp->dev, &bnx2x_fp(bp, i, napi),
 			       bnx2x_poll, 128);
 
-
 	/* Initialize HW */
-	if (bnx2x_function_init(bp,
-				(load_code == FW_MSG_CODE_DRV_LOAD_COMMON))) {
+	rc = bnx2x_init_hw(bp, load_code);
+	if (rc) {
 		BNX2X_ERR("HW init failed, aborting\n");
 		goto load_error;
 	}
 
-
+	/* Enable interrupt handling */
 	atomic_set(&bp->intr_sem, 0);
 
-
 	/* Setup NIC internals and enable interrupts */
 	bnx2x_nic_init(bp);
 
 	/* Send LOAD_DONE command to MCP */
-	if (!nomcp) {
+	if (!BP_NOMCP(bp)) {
 		load_code = bnx2x_fw_command(bp, DRV_MSG_CODE_LOAD_DONE);
 		if (!load_code) {
 			BNX2X_ERR("MCP response failure, unloading\n");
+			rc = -EBUSY;
 			goto load_int_disable;
 		}
 	}
@@ -4745,33 +5346,68 @@ static int bnx2x_nic_load(struct bnx2x *bp, int req_irq)
 	for_each_queue(bp, i)
 		napi_enable(&bnx2x_fp(bp, i, napi));
 
-	if (bnx2x_setup_leading(bp))
+	rc = bnx2x_setup_leading(bp);
+	if (rc) {
+#ifdef BNX2X_STOP_ON_ERROR
+		bp->panic = 1;
+#endif
 		goto load_stop_netif;
+	}
 
-	for_each_nondefault_queue(bp, i)
-		if (bnx2x_setup_multi(bp, i))
-			goto load_stop_netif;
+	if (CHIP_IS_E1H(bp))
+		if (bp->mf_config & FUNC_MF_CFG_FUNC_DISABLED) {
+			BNX2X_ERR("!!!  mf_cfg function disabled\n");
+			bp->state = BNX2X_STATE_DISABLED;
+		}
 
-	bnx2x_set_mac_addr(bp);
+	if (bp->state == BNX2X_STATE_OPEN)
+		for_each_nondefault_queue(bp, i) {
+			rc = bnx2x_setup_multi(bp, i);
+			if (rc)
+				goto load_stop_netif;
+		}
+
+	if (CHIP_IS_E1(bp))
+		bnx2x_set_mac_addr_e1(bp);
+	else
+		bnx2x_set_mac_addr_e1h(bp);
 
-	bnx2x_initial_phy_init(bp);
+	if (bp->port.pmf)
+		bnx2x_initial_phy_init(bp);
 
 	/* Start fast path */
-	if (req_irq) { /* IRQ is only requested from bnx2x_open */
+	switch (load_mode) {
+	case LOAD_NORMAL:
+		/* Tx queue should be only reenabled */
+		netif_wake_queue(bp->dev);
+		bnx2x_set_rx_mode(bp->dev);
+		break;
+
+	case LOAD_OPEN:
+		/* IRQ is only requested from bnx2x_open */
 		netif_start_queue(bp->dev);
+		bnx2x_set_rx_mode(bp->dev);
 		if (bp->flags & USING_MSIX_FLAG)
 			printk(KERN_INFO PFX "%s: using MSI-X\n",
 			       bp->dev->name);
+		break;
 
-	/* Otherwise Tx queue should be only reenabled */
-	} else if (netif_running(bp->dev)) {
-		netif_wake_queue(bp->dev);
+	case LOAD_DIAG:
 		bnx2x_set_rx_mode(bp->dev);
+		bp->state = BNX2X_STATE_DIAG;
+		break;
+
+	default:
+		break;
 	}
 
+	if (!bp->port.pmf)
+		bnx2x__link_status_update(bp);
+
 	/* start the timer */
 	mod_timer(&bp->timer, jiffies + bp->current_interval);
 
+
 	return 0;
 
 load_stop_netif:
@@ -4781,7 +5417,7 @@ load_stop_netif:
 load_int_disable:
 	bnx2x_int_disable_sync(bp);
 
-	bnx2x_free_skbs(bp);
+	/* Release IRQs */
 	bnx2x_free_irq(bp);
 
 load_error:
@@ -4789,95 +5425,50 @@ load_error:
 
 	/* TBD we really need to reset the chip
 	   if we want to recover from this */
-	return -EBUSY;
-}
-
-
-static void bnx2x_reset_chip(struct bnx2x *bp, u32 reset_code)
-{
-	int port = bp->port;
-#ifdef USE_DMAE
-	u32 wb_write[2];
-#endif
-	int base, i;
-
-	DP(NETIF_MSG_IFDOWN, "reset called with code %x\n", reset_code);
-
-	/* Do not rcv packets to BRB */
-	REG_WR(bp, NIG_REG_LLH0_BRB1_DRV_MASK + port*4, 0x0);
-	/* Do not direct rcv packets that are not for MCP to the BRB */
-	REG_WR(bp, (port ? NIG_REG_LLH1_BRB1_NOT_MCP :
-			   NIG_REG_LLH0_BRB1_NOT_MCP), 0x0);
-
-	/* Configure IGU and AEU */
-	REG_WR(bp, HC_REG_CONFIG_0 + port*4, 0x1000);
-	REG_WR(bp, MISC_REG_AEU_MASK_ATTN_FUNC_0 + port*4, 0);
-
-	/* TODO: Close Doorbell port? */
-
-	/* Clear ILT */
-#ifdef USE_DMAE
-	wb_write[0] = 0;
-	wb_write[1] = 0;
-#endif
-	base = port * RQ_ONCHIP_AT_PORT_SIZE;
-	for (i = base; i < base + RQ_ONCHIP_AT_PORT_SIZE; i++) {
-#ifdef USE_DMAE
-		REG_WR_DMAE(bp, PXP2_REG_RQ_ONCHIP_AT + i*8, wb_write, 2);
-#else
-		REG_WR_IND(bp, PXP2_REG_RQ_ONCHIP_AT, 0);
-		REG_WR_IND(bp, PXP2_REG_RQ_ONCHIP_AT + 4, 0);
-#endif
-	}
-
-	if (reset_code == FW_MSG_CODE_DRV_UNLOAD_COMMON) {
-		/* reset_common */
-		REG_WR(bp, GRCBASE_MISC + MISC_REGISTERS_RESET_REG_1_CLEAR,
-		       0xd3ffff7f);
-		REG_WR(bp, GRCBASE_MISC + MISC_REGISTERS_RESET_REG_2_CLEAR,
-		       0x1403);
-	}
+	return rc;
 }
 
 static int bnx2x_stop_multi(struct bnx2x *bp, int index)
 {
-
 	int rc;
 
 	/* halt the connection */
 	bp->fp[index].state = BNX2X_FP_STATE_HALTING;
 	bnx2x_sp_post(bp, RAMROD_CMD_ID_ETH_HALT, index, 0, 0, 0);
 
-
+	/* Wait for completion */
 	rc = bnx2x_wait_ramrod(bp, BNX2X_FP_STATE_HALTED, index,
-				       &(bp->fp[index].state), 1);
+			       &(bp->fp[index].state), 1);
 	if (rc) /* timeout */
 		return rc;
 
 	/* delete cfc entry */
 	bnx2x_sp_post(bp, RAMROD_CMD_ID_ETH_CFC_DEL, index, 0, 0, 1);
 
-	return bnx2x_wait_ramrod(bp, BNX2X_FP_STATE_CLOSED, index,
-				 &(bp->fp[index].state), 1);
-
+	/* Wait for completion */
+	rc = bnx2x_wait_ramrod(bp, BNX2X_FP_STATE_CLOSED, index,
+			       &(bp->fp[index].state), 1);
+	return rc;
 }
 
-
 static void bnx2x_stop_leading(struct bnx2x *bp)
 {
 	u16 dsb_sp_prod_idx;
 	/* if the other port is handling traffic,
 	   this can take a lot of time */
-	int timeout = 500;
+	int cnt = 500;
+	int rc;
 
 	might_sleep();
 
 	/* Send HALT ramrod */
 	bp->fp[0].state = BNX2X_FP_STATE_HALTING;
-	bnx2x_sp_post(bp, RAMROD_CMD_ID_ETH_HALT, 0, 0, 0, 0);
+	bnx2x_sp_post(bp, RAMROD_CMD_ID_ETH_HALT, 0, 0, BP_CL_ID(bp), 0);
 
-	if (bnx2x_wait_ramrod(bp, BNX2X_FP_STATE_HALTED, 0,
-			       &(bp->fp[0].state), 1))
+	/* Wait for completion */
+	rc = bnx2x_wait_ramrod(bp, BNX2X_FP_STATE_HALTED, 0,
+			       &(bp->fp[0].state), 1);
+	if (rc) /* timeout */
 		return;
 
 	dsb_sp_prod_idx = *bp->dsb_sp_prod;
@@ -4889,29 +5480,110 @@ static void bnx2x_stop_leading(struct bnx2x *bp)
 	   we are going to reset the chip anyway
 	   so there is not much to do if this times out
 	 */
-	while ((dsb_sp_prod_idx == *bp->dsb_sp_prod) && timeout) {
-		timeout--;
+	while (dsb_sp_prod_idx == *bp->dsb_sp_prod) {
 		msleep(1);
-	}
-	if (!timeout) {
-		DP(NETIF_MSG_IFDOWN, "timeout polling for completion "
-		   "dsb_sp_prod 0x%x != dsb_sp_prod_idx 0x%x\n",
-		   *bp->dsb_sp_prod, dsb_sp_prod_idx);
+		if (!cnt) {
+			DP(NETIF_MSG_IFDOWN, "timeout waiting for port del "
+			   "dsb_sp_prod 0x%x != dsb_sp_prod_idx 0x%x\n",
+			   *bp->dsb_sp_prod, dsb_sp_prod_idx);
+#ifdef BNX2X_STOP_ON_ERROR
+			bnx2x_panic();
+#endif
+			break;
+		}
+		cnt--;
 	}
 	bp->state = BNX2X_STATE_CLOSING_WAIT4_UNLOAD;
 	bp->fp[0].state = BNX2X_FP_STATE_CLOSED;
 }
 
+static void bnx2x_reset_func(struct bnx2x *bp)
+{
+	int port = BP_PORT(bp);
+	int func = BP_FUNC(bp);
+	int base, i;
+
+	/* Configure IGU */
+	REG_WR(bp, HC_REG_LEADING_EDGE_0 + port*8, 0);
+	REG_WR(bp, HC_REG_TRAILING_EDGE_0 + port*8, 0);
+
+	REG_WR(bp, HC_REG_CONFIG_0 + port*4, 0x1000);
+
+	/* Clear ILT */
+	base = FUNC_ILT_BASE(func);
+	for (i = base; i < base + ILT_PER_FUNC; i++)
+		bnx2x_ilt_wr(bp, i, 0);
+}
+
+static void bnx2x_reset_port(struct bnx2x *bp)
+{
+	int port = BP_PORT(bp);
+	u32 val;
+
+	REG_WR(bp, NIG_REG_MASK_INTERRUPT_PORT0 + port*4, 0);
+
+	/* Do not rcv packets to BRB */
+	REG_WR(bp, NIG_REG_LLH0_BRB1_DRV_MASK + port*4, 0x0);
+	/* Do not direct rcv packets that are not for MCP to the BRB */
+	REG_WR(bp, (port ? NIG_REG_LLH1_BRB1_NOT_MCP :
+			   NIG_REG_LLH0_BRB1_NOT_MCP), 0x0);
+
+	/* Configure AEU */
+	REG_WR(bp, MISC_REG_AEU_MASK_ATTN_FUNC_0 + port*4, 0);
+
+	msleep(100);
+	/* Check for BRB port occupancy */
+	val = REG_RD(bp, BRB1_REG_PORT_NUM_OCC_BLOCKS_0 + port*4);
+	if (val)
+		DP(NETIF_MSG_IFDOWN,
+		   "BRB1 is not empty  %d blooks are occupied\n", val);
+
+	/* TODO: Close Doorbell port? */
+}
+
+static void bnx2x_reset_common(struct bnx2x *bp)
+{
+	/* reset_common */
+	REG_WR(bp, GRCBASE_MISC + MISC_REGISTERS_RESET_REG_1_CLEAR,
+	       0xd3ffff7f);
+	REG_WR(bp, GRCBASE_MISC + MISC_REGISTERS_RESET_REG_2_CLEAR, 0x1403);
+}
 
-static int bnx2x_nic_unload(struct bnx2x *bp, int free_irq)
+static void bnx2x_reset_chip(struct bnx2x *bp, u32 reset_code)
+{
+	DP(BNX2X_MSG_MCP, "function %d  reset_code %x\n",
+	   BP_FUNC(bp), reset_code);
+
+	switch (reset_code) {
+	case FW_MSG_CODE_DRV_UNLOAD_COMMON:
+		bnx2x_reset_port(bp);
+		bnx2x_reset_func(bp);
+		bnx2x_reset_common(bp);
+		break;
+
+	case FW_MSG_CODE_DRV_UNLOAD_PORT:
+		bnx2x_reset_port(bp);
+		bnx2x_reset_func(bp);
+		break;
+
+	case FW_MSG_CODE_DRV_UNLOAD_FUNCTION:
+		bnx2x_reset_func(bp);
+		break;
+
+	default:
+		BNX2X_ERR("Unknown reset_code (0x%x) from MCP\n", reset_code);
+		break;
+	}
+}
+
+/* msut be called with rtnl_lock */
+static int bnx2x_nic_unload(struct bnx2x *bp, int unload_mode)
 {
 	u32 reset_code = 0;
-	int i, timeout;
+	int i, cnt;
 
 	bp->state = BNX2X_STATE_CLOSING_WAIT4_HALT;
 
-	del_timer_sync(&bp->timer);
-
 	bp->rx_mode = BNX2X_RX_MODE_NONE;
 	bnx2x_set_storm_rx_mode(bp);
 
@@ -4920,21 +5592,44 @@ static int bnx2x_nic_unload(struct bnx2x *bp, int free_irq)
 		bp->dev->trans_start = jiffies;	/* prevent tx timeout */
 	}
 
+	del_timer_sync(&bp->timer);
+	SHMEM_WR(bp, func_mb[BP_FUNC(bp)].drv_pulse_mb,
+		 (DRV_PULSE_ALWAYS_ALIVE | bp->fw_drv_pulse_wr_seq));
+
 	/* Wait until all fast path tasks complete */
 	for_each_queue(bp, i) {
 		struct bnx2x_fastpath *fp = &bp->fp[i];
 
-		timeout = 1000;
-		while (bnx2x_has_work(fp) && (timeout--))
+#ifdef BNX2X_STOP_ON_ERROR
+#ifdef __powerpc64__
+		DP(NETIF_MSG_RX_STATUS, "fp->tpa_queue_used = 0x%lx\n",
+#else
+		DP(NETIF_MSG_IFDOWN, "fp->tpa_queue_used = 0x%llx\n",
+#endif
+		   fp->tpa_queue_used);
+#endif
+		cnt = 1000;
+		smp_rmb();
+		while (bnx2x_has_work(fp)) {
 			msleep(1);
-		if (!timeout)
-			BNX2X_ERR("timeout waiting for queue[%d]\n", i);
+			if (!cnt) {
+				BNX2X_ERR("timeout waiting for queue[%d]\n",
+					  i);
+#ifdef BNX2X_STOP_ON_ERROR
+				bnx2x_panic();
+				return -EBUSY;
+#else
+				break;
+#endif
+			}
+			cnt--;
+			smp_rmb();
+		}
 	}
 
-	/* Wait until stat ramrod returns and all SP tasks complete */
-	timeout = 1000;
-	while ((bp->stat_pending || (bp->spq_left != MAX_SPQ_PENDING)) &&
-	       (timeout--))
+	/* Wait until all slow path tasks complete */
+	cnt = 1000;
+	while ((bp->spq_left != MAX_SPQ_PENDING) && cnt--)
 		msleep(1);
 
 	for_each_queue(bp, i)
@@ -4942,59 +5637,84 @@ static int bnx2x_nic_unload(struct bnx2x *bp, int free_irq)
 	/* Disable interrupts after Tx and Rx are disabled on stack level */
 	bnx2x_int_disable_sync(bp);
 
+	/* Release IRQs */
+	bnx2x_free_irq(bp);
+
 	if (bp->flags & NO_WOL_FLAG)
 		reset_code = DRV_MSG_CODE_UNLOAD_REQ_WOL_MCP;
 
 	else if (bp->wol) {
-		u32 emac_base = bp->port ? GRCBASE_EMAC0 : GRCBASE_EMAC1;
+		u32 emac_base = BP_PORT(bp) ? GRCBASE_EMAC1 : GRCBASE_EMAC0;
 		u8 *mac_addr = bp->dev->dev_addr;
-		u32 val = (EMAC_MODE_MPKT | EMAC_MODE_MPKT_RCVD |
-			   EMAC_MODE_ACPI_RCVD);
-
-		EMAC_WR(EMAC_REG_EMAC_MODE, val);
+		u32 val;
 
+		/* The mac address is written to entries 1-4 to
+		   preserve entry 0 which is used by the PMF */
 		val = (mac_addr[0] << 8) | mac_addr[1];
-		EMAC_WR(EMAC_REG_EMAC_MAC_MATCH, val);
+		EMAC_WR(EMAC_REG_EMAC_MAC_MATCH + (BP_E1HVN(bp) + 1)*8, val);
 
 		val = (mac_addr[2] << 24) | (mac_addr[3] << 16) |
 		      (mac_addr[4] << 8) | mac_addr[5];
-		EMAC_WR(EMAC_REG_EMAC_MAC_MATCH + 4, val);
+		EMAC_WR(EMAC_REG_EMAC_MAC_MATCH + (BP_E1HVN(bp) + 1)*8 + 4,
+			val);
 
 		reset_code = DRV_MSG_CODE_UNLOAD_REQ_WOL_EN;
 
 	} else
 		reset_code = DRV_MSG_CODE_UNLOAD_REQ_WOL_DIS;
 
-	/* Close multi and leading connections */
+	/* Close multi and leading connections
+	   Completions for ramrods are collected in a synchronous way */
 	for_each_nondefault_queue(bp, i)
 		if (bnx2x_stop_multi(bp, i))
 			goto unload_error;
 
+	if (CHIP_IS_E1H(bp))
+		REG_WR(bp, NIG_REG_LLH0_FUNC_EN + BP_PORT(bp)*8, 0);
+
 	bnx2x_stop_leading(bp);
+#ifdef BNX2X_STOP_ON_ERROR
+	/* If ramrod completion timed out - break here! */
+	if (bp->panic) {
+		BNX2X_ERR("Stop leading failed!\n");
+		return -EBUSY;
+	}
+#endif
+
 	if ((bp->state != BNX2X_STATE_CLOSING_WAIT4_UNLOAD) ||
 	    (bp->fp[0].state != BNX2X_FP_STATE_CLOSED)) {
-		DP(NETIF_MSG_IFDOWN, "failed to close leading properly!"
-		   "state 0x%x  fp[0].state 0x%x",
+		DP(NETIF_MSG_IFDOWN, "failed to close leading properly!  "
+		   "state 0x%x  fp[0].state 0x%x\n",
 		   bp->state, bp->fp[0].state);
 	}
 
 unload_error:
-	bnx2x__link_reset(bp);
-
-	if (!nomcp)
+	if (!BP_NOMCP(bp))
 		reset_code = bnx2x_fw_command(bp, reset_code);
-	else
-		reset_code = FW_MSG_CODE_DRV_UNLOAD_COMMON;
+	else {
+		DP(NETIF_MSG_IFDOWN, "NO MCP load counts      %d, %d, %d\n",
+		   load_count[0], load_count[1], load_count[2]);
+		load_count[0]--;
+		load_count[1 + BP_PORT(bp)]--;
+		DP(NETIF_MSG_IFDOWN, "NO MCP new load counts  %d, %d, %d\n",
+		   load_count[0], load_count[1], load_count[2]);
+		if (load_count[0] == 0)
+			reset_code = FW_MSG_CODE_DRV_UNLOAD_COMMON;
+		else if (load_count[1 + BP_PORT(bp)] == 0)
+			reset_code = FW_MSG_CODE_DRV_UNLOAD_PORT;
+		else
+			reset_code = FW_MSG_CODE_DRV_UNLOAD_FUNCTION;
+	}
 
-	/* Release IRQs */
-	if (free_irq)
-		bnx2x_free_irq(bp);
+	if ((reset_code == FW_MSG_CODE_DRV_UNLOAD_COMMON) ||
+	    (reset_code == FW_MSG_CODE_DRV_UNLOAD_PORT))
+		bnx2x__link_reset(bp);
 
 	/* Reset the chip */
 	bnx2x_reset_chip(bp, reset_code);
 
 	/* Report UNLOAD_DONE to MCP */
-	if (!nomcp)
+	if (!BP_NOMCP(bp))
 		bnx2x_fw_command(bp, DRV_MSG_CODE_UNLOAD_DONE);
 
 	/* Free SKBs and driver internals */
@@ -5008,6 +5728,29 @@ unload_error:
 	return 0;
 }
 
+static void bnx2x_reset_task(struct work_struct *work)
+{
+	struct bnx2x *bp = container_of(work, struct bnx2x, reset_task);
+
+#ifdef BNX2X_STOP_ON_ERROR
+	BNX2X_ERR("reset task called but STOP_ON_ERROR defined"
+		  " so reset not done to allow debug dump,\n"
+	 KERN_ERR " you will need to reboot when done\n");
+	return;
+#endif
+
+	rtnl_lock();
+
+	if (!netif_running(bp->dev))
+		goto reset_task_exit;
+
+	bnx2x_nic_unload(bp, UNLOAD_NORMAL);
+	bnx2x_nic_load(bp, LOAD_NORMAL);
+
+reset_task_exit:
+	rtnl_unlock();
+}
+
 /* end of nic load/unload */
 
 /* ethtool_ops */
@@ -5016,9 +5759,139 @@ unload_error:
  * Init service functions
  */
 
-static void bnx2x_link_settings_supported(struct bnx2x *bp, u32 switch_cfg)
+static void __devinit bnx2x_undi_unload(struct bnx2x *bp)
+{
+	u32 val;
+
+	/* Check if there is any driver already loaded */
+	val = REG_RD(bp, MISC_REG_UNPREPARED);
+	if (val == 0x1) {
+		/* Check if it is the UNDI driver
+		 * UNDI driver initializes CID offset for normal bell to 0x7
+		 */
+		val = REG_RD(bp, DORQ_REG_NORM_CID_OFST);
+		if (val == 0x7) {
+			u32 reset_code = DRV_MSG_CODE_UNLOAD_REQ_WOL_DIS;
+			/* save our func and fw_seq */
+			int func = BP_FUNC(bp);
+			u16 fw_seq = bp->fw_seq;
+
+			BNX2X_DEV_INFO("UNDI is active! reset device\n");
+
+			/* try unload UNDI on port 0 */
+			bp->func = 0;
+			bp->fw_seq = (SHMEM_RD(bp,
+					     func_mb[bp->func].drv_mb_header) &
+				      DRV_MSG_SEQ_NUMBER_MASK);
+
+			reset_code = bnx2x_fw_command(bp, reset_code);
+			bnx2x_fw_command(bp, DRV_MSG_CODE_UNLOAD_DONE);
+
+			/* if UNDI is loaded on the other port */
+			if (reset_code != FW_MSG_CODE_DRV_UNLOAD_COMMON) {
+
+				bp->func = 1;
+				bp->fw_seq = (SHMEM_RD(bp,
+					     func_mb[bp->func].drv_mb_header) &
+					      DRV_MSG_SEQ_NUMBER_MASK);
+
+				bnx2x_fw_command(bp,
+					     DRV_MSG_CODE_UNLOAD_REQ_WOL_DIS);
+				bnx2x_fw_command(bp,
+						 DRV_MSG_CODE_UNLOAD_DONE);
+
+				/* restore our func and fw_seq */
+				bp->func = func;
+				bp->fw_seq = fw_seq;
+			}
+
+			/* reset device */
+			REG_WR(bp,
+			       GRCBASE_MISC + MISC_REGISTERS_RESET_REG_1_CLEAR,
+			       0xd3ffff7f);
+			REG_WR(bp,
+			       GRCBASE_MISC + MISC_REGISTERS_RESET_REG_2_CLEAR,
+			       0x1403);
+		}
+	}
+}
+
+static void __devinit bnx2x_get_common_hwinfo(struct bnx2x *bp)
+{
+	u32 val, val2, val3, val4, id;
+
+	/* Get the chip revision id and number. */
+	/* chip num:16-31, rev:12-15, metal:4-11, bond_id:0-3 */
+	val = REG_RD(bp, MISC_REG_CHIP_NUM);
+	id = ((val & 0xffff) << 16);
+	val = REG_RD(bp, MISC_REG_CHIP_REV);
+	id |= ((val & 0xf) << 12);
+	val = REG_RD(bp, MISC_REG_CHIP_METAL);
+	id |= ((val & 0xff) << 4);
+	REG_RD(bp, MISC_REG_BOND_ID);
+	id |= (val & 0xf);
+	bp->common.chip_id = id;
+	bp->link_params.chip_id = bp->common.chip_id;
+	BNX2X_DEV_INFO("chip ID is 0x%x\n", id);
+
+	val = REG_RD(bp, MCP_REG_MCPR_NVM_CFG4);
+	bp->common.flash_size = (NVRAM_1MB_SIZE <<
+				 (val & MCPR_NVM_CFG4_FLASH_SIZE));
+	BNX2X_DEV_INFO("flash_size 0x%x (%d)\n",
+		       bp->common.flash_size, bp->common.flash_size);
+
+	bp->common.shmem_base = REG_RD(bp, MISC_REG_SHARED_MEM_ADDR);
+	bp->link_params.shmem_base = bp->common.shmem_base;
+	BNX2X_DEV_INFO("shmem offset is 0x%x\n", bp->common.shmem_base);
+
+	if (!bp->common.shmem_base ||
+	    (bp->common.shmem_base < 0xA0000) ||
+	    (bp->common.shmem_base >= 0xC0000)) {
+		BNX2X_DEV_INFO("MCP not active\n");
+		bp->flags |= NO_MCP_FLAG;
+		return;
+	}
+
+	val = SHMEM_RD(bp, validity_map[BP_PORT(bp)]);
+	if ((val & (SHR_MEM_VALIDITY_DEV_INFO | SHR_MEM_VALIDITY_MB))
+		!= (SHR_MEM_VALIDITY_DEV_INFO | SHR_MEM_VALIDITY_MB))
+		BNX2X_ERR("BAD MCP validity signature\n");
+
+	bp->common.hw_config = SHMEM_RD(bp, dev_info.shared_hw_config.config);
+	bp->common.board = SHMEM_RD(bp, dev_info.shared_hw_config.board);
+
+	BNX2X_DEV_INFO("hw_config 0x%08x  board 0x%08x\n",
+		       bp->common.hw_config, bp->common.board);
+
+	bp->link_params.hw_led_mode = ((bp->common.hw_config &
+					SHARED_HW_CFG_LED_MODE_MASK) >>
+				       SHARED_HW_CFG_LED_MODE_SHIFT);
+
+	val = SHMEM_RD(bp, dev_info.bc_rev) >> 8;
+	bp->common.bc_ver = val;
+	BNX2X_DEV_INFO("bc_ver %X\n", val);
+	if (val < BNX2X_BC_VER) {
+		/* for now only warn
+		 * later we might need to enforce this */
+		BNX2X_ERR("This driver needs bc_ver %X but found %X,"
+			  " please upgrade BC\n", BNX2X_BC_VER, val);
+	}
+	BNX2X_DEV_INFO("%sWoL Capable\n",
+		       (bp->flags & NO_WOL_FLAG)? "Not " : "");
+
+	val = SHMEM_RD(bp, dev_info.shared_hw_config.part_num);
+	val2 = SHMEM_RD(bp, dev_info.shared_hw_config.part_num[4]);
+	val3 = SHMEM_RD(bp, dev_info.shared_hw_config.part_num[8]);
+	val4 = SHMEM_RD(bp, dev_info.shared_hw_config.part_num[12]);
+
+	printk(KERN_INFO PFX "part number %X-%X-%X-%X\n",
+	       val, val2, val3, val4);
+}
+
+static void __devinit bnx2x_link_settings_supported(struct bnx2x *bp,
+						    u32 switch_cfg)
 {
-	int port = bp->port;
+	int port = BP_PORT(bp);
 	u32 ext_phy_type;
 
 	switch (switch_cfg) {
@@ -5032,31 +5905,33 @@ static void bnx2x_link_settings_supported(struct bnx2x *bp, u32 switch_cfg)
 			BNX2X_DEV_INFO("ext_phy_type 0x%x (Direct)\n",
 				       ext_phy_type);
 
-			bp->supported |= (SUPPORTED_10baseT_Half |
-					  SUPPORTED_10baseT_Full |
-					  SUPPORTED_100baseT_Half |
-					  SUPPORTED_100baseT_Full |
-					  SUPPORTED_1000baseT_Full |
-					  SUPPORTED_2500baseX_Full |
-					  SUPPORTED_TP | SUPPORTED_FIBRE |
-					  SUPPORTED_Autoneg |
-					  SUPPORTED_Pause |
-					  SUPPORTED_Asym_Pause);
+			bp->port.supported |= (SUPPORTED_10baseT_Half |
+					       SUPPORTED_10baseT_Full |
+					       SUPPORTED_100baseT_Half |
+					       SUPPORTED_100baseT_Full |
+					       SUPPORTED_1000baseT_Full |
+					       SUPPORTED_2500baseX_Full |
+					       SUPPORTED_TP |
+					       SUPPORTED_FIBRE |
+					       SUPPORTED_Autoneg |
+					       SUPPORTED_Pause |
+					       SUPPORTED_Asym_Pause);
 			break;
 
 		case PORT_HW_CFG_SERDES_EXT_PHY_TYPE_BCM5482:
 			BNX2X_DEV_INFO("ext_phy_type 0x%x (5482)\n",
 				       ext_phy_type);
 
-			bp->supported |= (SUPPORTED_10baseT_Half |
-					  SUPPORTED_10baseT_Full |
-					  SUPPORTED_100baseT_Half |
-					  SUPPORTED_100baseT_Full |
-					  SUPPORTED_1000baseT_Full |
-					  SUPPORTED_TP | SUPPORTED_FIBRE |
-					  SUPPORTED_Autoneg |
-					  SUPPORTED_Pause |
-					  SUPPORTED_Asym_Pause);
+			bp->port.supported |= (SUPPORTED_10baseT_Half |
+					       SUPPORTED_10baseT_Full |
+					       SUPPORTED_100baseT_Half |
+					       SUPPORTED_100baseT_Full |
+					       SUPPORTED_1000baseT_Full |
+					       SUPPORTED_TP |
+					       SUPPORTED_FIBRE |
+					       SUPPORTED_Autoneg |
+					       SUPPORTED_Pause |
+					       SUPPORTED_Asym_Pause);
 			break;
 
 		default:
@@ -5066,9 +5941,9 @@ static void bnx2x_link_settings_supported(struct bnx2x *bp, u32 switch_cfg)
 			return;
 		}
 
-		bp->phy_addr = REG_RD(bp, NIG_REG_SERDES0_CTRL_PHY_ADDR +
-				      port*0x10);
-		BNX2X_DEV_INFO("phy_addr 0x%x\n", bp->phy_addr);
+		bp->port.phy_addr = REG_RD(bp, NIG_REG_SERDES0_CTRL_PHY_ADDR +
+					   port*0x10);
+		BNX2X_DEV_INFO("phy_addr 0x%x\n", bp->port.phy_addr);
 		break;
 
 	case SWITCH_CFG_10G:
@@ -5081,75 +5956,75 @@ static void bnx2x_link_settings_supported(struct bnx2x *bp, u32 switch_cfg)
 			BNX2X_DEV_INFO("ext_phy_type 0x%x (Direct)\n",
 				       ext_phy_type);
 
-			bp->supported |= (SUPPORTED_10baseT_Half |
-					  SUPPORTED_10baseT_Full |
-					  SUPPORTED_100baseT_Half |
-					  SUPPORTED_100baseT_Full |
-					  SUPPORTED_1000baseT_Full |
-					  SUPPORTED_2500baseX_Full |
-					  SUPPORTED_10000baseT_Full |
-					  SUPPORTED_TP | SUPPORTED_FIBRE |
-					  SUPPORTED_Autoneg |
-					  SUPPORTED_Pause |
-					  SUPPORTED_Asym_Pause);
+			bp->port.supported |= (SUPPORTED_10baseT_Half |
+					       SUPPORTED_10baseT_Full |
+					       SUPPORTED_100baseT_Half |
+					       SUPPORTED_100baseT_Full |
+					       SUPPORTED_1000baseT_Full |
+					       SUPPORTED_2500baseX_Full |
+					       SUPPORTED_10000baseT_Full |
+					       SUPPORTED_TP |
+					       SUPPORTED_FIBRE |
+					       SUPPORTED_Autoneg |
+					       SUPPORTED_Pause |
+					       SUPPORTED_Asym_Pause);
 			break;
 
 		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8705:
 			BNX2X_DEV_INFO("ext_phy_type 0x%x (8705)\n",
-					ext_phy_type);
+				       ext_phy_type);
 
-			bp->supported |= (SUPPORTED_10000baseT_Full |
-					  SUPPORTED_FIBRE |
-					  SUPPORTED_Pause |
-					  SUPPORTED_Asym_Pause);
+			bp->port.supported |= (SUPPORTED_10000baseT_Full |
+					       SUPPORTED_FIBRE |
+					       SUPPORTED_Pause |
+					       SUPPORTED_Asym_Pause);
 			break;
 
 		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8706:
 			BNX2X_DEV_INFO("ext_phy_type 0x%x (8706)\n",
 				       ext_phy_type);
 
-			bp->supported |= (SUPPORTED_10000baseT_Full |
-					  SUPPORTED_1000baseT_Full |
-					  SUPPORTED_Autoneg |
-					  SUPPORTED_FIBRE |
-					  SUPPORTED_Pause |
-					  SUPPORTED_Asym_Pause);
+			bp->port.supported |= (SUPPORTED_10000baseT_Full |
+					       SUPPORTED_1000baseT_Full |
+					       SUPPORTED_FIBRE |
+					       SUPPORTED_Pause |
+					       SUPPORTED_Asym_Pause);
 			break;
 
 		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8072:
 			BNX2X_DEV_INFO("ext_phy_type 0x%x (8072)\n",
 				       ext_phy_type);
 
-			bp->supported |= (SUPPORTED_10000baseT_Full |
-					  SUPPORTED_1000baseT_Full |
-					  SUPPORTED_FIBRE |
-					  SUPPORTED_Autoneg |
-					  SUPPORTED_Pause |
-					  SUPPORTED_Asym_Pause);
+			bp->port.supported |= (SUPPORTED_10000baseT_Full |
+					       SUPPORTED_1000baseT_Full |
+					       SUPPORTED_FIBRE |
+					       SUPPORTED_Autoneg |
+					       SUPPORTED_Pause |
+					       SUPPORTED_Asym_Pause);
 			break;
 
 		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8073:
 			BNX2X_DEV_INFO("ext_phy_type 0x%x (8073)\n",
 				       ext_phy_type);
 
-			bp->supported |= (SUPPORTED_10000baseT_Full |
-					  SUPPORTED_2500baseX_Full |
-					  SUPPORTED_1000baseT_Full |
-					  SUPPORTED_FIBRE |
-					  SUPPORTED_Autoneg |
-					  SUPPORTED_Pause |
-					  SUPPORTED_Asym_Pause);
+			bp->port.supported |= (SUPPORTED_10000baseT_Full |
+					       SUPPORTED_2500baseX_Full |
+					       SUPPORTED_1000baseT_Full |
+					       SUPPORTED_FIBRE |
+					       SUPPORTED_Autoneg |
+					       SUPPORTED_Pause |
+					       SUPPORTED_Asym_Pause);
 			break;
 
 		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_SFX7101:
 			BNX2X_DEV_INFO("ext_phy_type 0x%x (SFX7101)\n",
 				       ext_phy_type);
 
-			bp->supported |= (SUPPORTED_10000baseT_Full |
-					  SUPPORTED_TP |
-					  SUPPORTED_Autoneg |
-					  SUPPORTED_Pause |
-					  SUPPORTED_Asym_Pause);
+			bp->port.supported |= (SUPPORTED_10000baseT_Full |
+					       SUPPORTED_TP |
+					       SUPPORTED_Autoneg |
+					       SUPPORTED_Pause |
+					       SUPPORTED_Asym_Pause);
 			break;
 
 		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_FAILURE:
@@ -5164,61 +6039,61 @@ static void bnx2x_link_settings_supported(struct bnx2x *bp, u32 switch_cfg)
 			return;
 		}
 
-		bp->phy_addr = REG_RD(bp, NIG_REG_XGXS0_CTRL_PHY_ADDR +
-				      port*0x18);
-		BNX2X_DEV_INFO("phy_addr 0x%x\n", bp->phy_addr);
+		bp->port.phy_addr = REG_RD(bp, NIG_REG_XGXS0_CTRL_PHY_ADDR +
+					   port*0x18);
+		BNX2X_DEV_INFO("phy_addr 0x%x\n", bp->port.phy_addr);
 
 		break;
 
 	default:
 		BNX2X_ERR("BAD switch_cfg link_config 0x%x\n",
-			  bp->link_config);
+			  bp->port.link_config);
 		return;
 	}
-	bp->link_params.phy_addr = bp->phy_addr;
+	bp->link_params.phy_addr = bp->port.phy_addr;
 
 	/* mask what we support according to speed_cap_mask */
 	if (!(bp->link_params.speed_cap_mask &
 				PORT_HW_CFG_SPEED_CAPABILITY_D0_10M_HALF))
-		bp->supported &= ~SUPPORTED_10baseT_Half;
+		bp->port.supported &= ~SUPPORTED_10baseT_Half;
 
 	if (!(bp->link_params.speed_cap_mask &
 				PORT_HW_CFG_SPEED_CAPABILITY_D0_10M_FULL))
-		bp->supported &= ~SUPPORTED_10baseT_Full;
+		bp->port.supported &= ~SUPPORTED_10baseT_Full;
 
 	if (!(bp->link_params.speed_cap_mask &
 				PORT_HW_CFG_SPEED_CAPABILITY_D0_100M_HALF))
-		bp->supported &= ~SUPPORTED_100baseT_Half;
+		bp->port.supported &= ~SUPPORTED_100baseT_Half;
 
 	if (!(bp->link_params.speed_cap_mask &
 				PORT_HW_CFG_SPEED_CAPABILITY_D0_100M_FULL))
-		bp->supported &= ~SUPPORTED_100baseT_Full;
+		bp->port.supported &= ~SUPPORTED_100baseT_Full;
 
 	if (!(bp->link_params.speed_cap_mask &
 					PORT_HW_CFG_SPEED_CAPABILITY_D0_1G))
-		bp->supported &= ~(SUPPORTED_1000baseT_Half |
-				   SUPPORTED_1000baseT_Full);
+		bp->port.supported &= ~(SUPPORTED_1000baseT_Half |
+					SUPPORTED_1000baseT_Full);
 
 	if (!(bp->link_params.speed_cap_mask &
 					PORT_HW_CFG_SPEED_CAPABILITY_D0_2_5G))
-		bp->supported &= ~SUPPORTED_2500baseX_Full;
+		bp->port.supported &= ~SUPPORTED_2500baseX_Full;
 
 	if (!(bp->link_params.speed_cap_mask &
 					PORT_HW_CFG_SPEED_CAPABILITY_D0_10G))
-		bp->supported &= ~SUPPORTED_10000baseT_Full;
+		bp->port.supported &= ~SUPPORTED_10000baseT_Full;
 
-	BNX2X_DEV_INFO("supported 0x%x\n", bp->supported);
+	BNX2X_DEV_INFO("supported 0x%x\n", bp->port.supported);
 }
 
-static void bnx2x_link_settings_requested(struct bnx2x *bp)
+static void __devinit bnx2x_link_settings_requested(struct bnx2x *bp)
 {
 	bp->link_params.req_duplex = DUPLEX_FULL;
 
-	switch (bp->link_config & PORT_FEATURE_LINK_SPEED_MASK) {
+	switch (bp->port.link_config & PORT_FEATURE_LINK_SPEED_MASK) {
 	case PORT_FEATURE_LINK_SPEED_AUTO:
-		if (bp->supported & SUPPORTED_Autoneg) {
+		if (bp->port.supported & SUPPORTED_Autoneg) {
 			bp->link_params.req_line_speed = SPEED_AUTO_NEG;
-			bp->advertising = bp->supported;
+			bp->port.advertising = bp->port.supported;
 		} else {
 			u32 ext_phy_type =
 			    XGXS_EXT_PHY_TYPE(bp->link_params.ext_phy_config);
@@ -5229,7 +6104,7 @@ static void bnx2x_link_settings_requested(struct bnx2x *bp)
 			     PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8706)) {
 				/* force 10G, no AN */
 				bp->link_params.req_line_speed = SPEED_10000;
-				bp->advertising =
+				bp->port.advertising =
 						(ADVERTISED_10000baseT_Full |
 						 ADVERTISED_FIBRE);
 				break;
@@ -5237,98 +6112,98 @@ static void bnx2x_link_settings_requested(struct bnx2x *bp)
 			BNX2X_ERR("NVRAM config error. "
 				  "Invalid link_config 0x%x"
 				  "  Autoneg not supported\n",
-				  bp->link_config);
+				  bp->port.link_config);
 			return;
 		}
 		break;
 
 	case PORT_FEATURE_LINK_SPEED_10M_FULL:
-		if (bp->supported & SUPPORTED_10baseT_Full) {
+		if (bp->port.supported & SUPPORTED_10baseT_Full) {
 			bp->link_params.req_line_speed = SPEED_10;
-			bp->advertising = (ADVERTISED_10baseT_Full |
-					   ADVERTISED_TP);
+			bp->port.advertising = (ADVERTISED_10baseT_Full |
+						ADVERTISED_TP);
 		} else {
 			BNX2X_ERR("NVRAM config error. "
 				  "Invalid link_config 0x%x"
 				  "  speed_cap_mask 0x%x\n",
-				  bp->link_config,
+				  bp->port.link_config,
 				  bp->link_params.speed_cap_mask);
 			return;
 		}
 		break;
 
 	case PORT_FEATURE_LINK_SPEED_10M_HALF:
-		if (bp->supported & SUPPORTED_10baseT_Half) {
+		if (bp->port.supported & SUPPORTED_10baseT_Half) {
 			bp->link_params.req_line_speed = SPEED_10;
 			bp->link_params.req_duplex = DUPLEX_HALF;
-			bp->advertising = (ADVERTISED_10baseT_Half |
-					   ADVERTISED_TP);
+			bp->port.advertising = (ADVERTISED_10baseT_Half |
+						ADVERTISED_TP);
 		} else {
 			BNX2X_ERR("NVRAM config error. "
 				  "Invalid link_config 0x%x"
 				  "  speed_cap_mask 0x%x\n",
-				  bp->link_config,
+				  bp->port.link_config,
 				  bp->link_params.speed_cap_mask);
 			return;
 		}
 		break;
 
 	case PORT_FEATURE_LINK_SPEED_100M_FULL:
-		if (bp->supported & SUPPORTED_100baseT_Full) {
+		if (bp->port.supported & SUPPORTED_100baseT_Full) {
 			bp->link_params.req_line_speed = SPEED_100;
-			bp->advertising = (ADVERTISED_100baseT_Full |
-					   ADVERTISED_TP);
+			bp->port.advertising = (ADVERTISED_100baseT_Full |
+						ADVERTISED_TP);
 		} else {
 			BNX2X_ERR("NVRAM config error. "
 				  "Invalid link_config 0x%x"
 				  "  speed_cap_mask 0x%x\n",
-				  bp->link_config,
+				  bp->port.link_config,
 				  bp->link_params.speed_cap_mask);
 			return;
 		}
 		break;
 
 	case PORT_FEATURE_LINK_SPEED_100M_HALF:
-		if (bp->supported & SUPPORTED_100baseT_Half) {
+		if (bp->port.supported & SUPPORTED_100baseT_Half) {
 			bp->link_params.req_line_speed = SPEED_100;
 			bp->link_params.req_duplex = DUPLEX_HALF;
-			bp->advertising = (ADVERTISED_100baseT_Half |
-					   ADVERTISED_TP);
+			bp->port.advertising = (ADVERTISED_100baseT_Half |
+						ADVERTISED_TP);
 		} else {
 			BNX2X_ERR("NVRAM config error. "
 				  "Invalid link_config 0x%x"
 				  "  speed_cap_mask 0x%x\n",
-				  bp->link_config,
+				  bp->port.link_config,
 				  bp->link_params.speed_cap_mask);
 			return;
 		}
 		break;
 
 	case PORT_FEATURE_LINK_SPEED_1G:
-		if (bp->supported & SUPPORTED_1000baseT_Full) {
+		if (bp->port.supported & SUPPORTED_1000baseT_Full) {
 			bp->link_params.req_line_speed = SPEED_1000;
-			bp->advertising = (ADVERTISED_1000baseT_Full |
-					   ADVERTISED_TP);
+			bp->port.advertising = (ADVERTISED_1000baseT_Full |
+						ADVERTISED_TP);
 		} else {
 			BNX2X_ERR("NVRAM config error. "
 				  "Invalid link_config 0x%x"
 				  "  speed_cap_mask 0x%x\n",
-				  bp->link_config,
+				  bp->port.link_config,
 				  bp->link_params.speed_cap_mask);
 			return;
 		}
 		break;
 
 	case PORT_FEATURE_LINK_SPEED_2_5G:
-		if (bp->supported & SUPPORTED_2500baseX_Full) {
+		if (bp->port.supported & SUPPORTED_2500baseX_Full) {
 			bp->link_params.req_line_speed = SPEED_2500;
-			bp->advertising = (ADVERTISED_2500baseX_Full |
-					   ADVERTISED_TP);
+			bp->port.advertising = (ADVERTISED_2500baseX_Full |
+						ADVERTISED_TP);
 		} else {
 			BNX2X_ERR("NVRAM config error. "
 				  "Invalid link_config 0x%x"
 				  "  speed_cap_mask 0x%x\n",
-				  bp->link_config,
+				  bp->port.link_config,
 				  bp->link_params.speed_cap_mask);
 			return;
 		}
@@ -5337,15 +6212,15 @@ static void bnx2x_link_settings_requested(struct bnx2x *bp)
 	case PORT_FEATURE_LINK_SPEED_10G_CX4:
 	case PORT_FEATURE_LINK_SPEED_10G_KX4:
 	case PORT_FEATURE_LINK_SPEED_10G_KR:
-		if (bp->supported & SUPPORTED_10000baseT_Full) {
+		if (bp->port.supported & SUPPORTED_10000baseT_Full) {
 			bp->link_params.req_line_speed = SPEED_10000;
-			bp->advertising = (ADVERTISED_10000baseT_Full |
-					   ADVERTISED_FIBRE);
+			bp->port.advertising = (ADVERTISED_10000baseT_Full |
+						ADVERTISED_FIBRE);
 		} else {
 			BNX2X_ERR("NVRAM config error. "
 				  "Invalid link_config 0x%x"
 				  "  speed_cap_mask 0x%x\n",
-				  bp->link_config,
+				  bp->port.link_config,
 				  bp->link_params.speed_cap_mask);
 			return;
 		}
@@ -5354,64 +6229,33 @@ static void bnx2x_link_settings_requested(struct bnx2x *bp)
 	default:
 		BNX2X_ERR("NVRAM config error. "
 			  "BAD link speed link_config 0x%x\n",
-			  bp->link_config);
+			  bp->port.link_config);
 		bp->link_params.req_line_speed = SPEED_AUTO_NEG;
-		bp->advertising = bp->supported;
+		bp->port.advertising = bp->port.supported;
 		break;
 	}
 
-	bp->link_params.req_flow_ctrl = (bp->link_config &
-			     PORT_FEATURE_FLOW_CONTROL_MASK);
+	bp->link_params.req_flow_ctrl = (bp->port.link_config &
+					 PORT_FEATURE_FLOW_CONTROL_MASK);
 	if ((bp->link_params.req_flow_ctrl == FLOW_CTRL_AUTO) &&
-	    (!bp->supported & SUPPORTED_Autoneg))
+	    (!bp->port.supported & SUPPORTED_Autoneg))
 		bp->link_params.req_flow_ctrl = FLOW_CTRL_NONE;
 
 	BNX2X_DEV_INFO("req_line_speed %d  req_duplex %d  req_flow_ctrl 0x%x"
 		       "  advertising 0x%x\n",
 		       bp->link_params.req_line_speed,
 		       bp->link_params.req_duplex,
-		       bp->link_params.req_flow_ctrl, bp->advertising);
+		       bp->link_params.req_flow_ctrl, bp->port.advertising);
 }
 
-static void bnx2x_get_hwinfo(struct bnx2x *bp)
+static void __devinit bnx2x_get_port_hwinfo(struct bnx2x *bp)
 {
-	u32 val, val2, val3, val4, id;
-	int port = bp->port;
-
-	bp->shmem_base = REG_RD(bp, MISC_REG_SHARED_MEM_ADDR);
-	BNX2X_DEV_INFO("shmem offset is %x\n", bp->shmem_base);
-
-	/* Get the chip revision id and number. */
-	/* chip num:16-31, rev:12-15, metal:4-11, bond_id:0-3 */
-	val = REG_RD(bp, MISC_REG_CHIP_NUM);
-	id = ((val & 0xffff) << 16);
-	val = REG_RD(bp, MISC_REG_CHIP_REV);
-	id |= ((val & 0xf) << 12);
-	val = REG_RD(bp, MISC_REG_CHIP_METAL);
-	id |= ((val & 0xff) << 4);
-	REG_RD(bp, MISC_REG_BOND_ID);
-	id |= (val & 0xf);
-	bp->chip_id = id;
-	BNX2X_DEV_INFO("chip ID is %x\n", id);
+	int port = BP_PORT(bp);
+	u32 val, val2;
 
 	bp->link_params.bp = bp;
+	bp->link_params.port = port;
 
-	if (!bp->shmem_base || (bp->shmem_base != 0xAF900)) {
-		BNX2X_DEV_INFO("MCP not active\n");
-		nomcp = 1;
-		goto set_mac;
-	}
-
-	val = SHMEM_RD(bp, validity_map[port]);
-	if ((val & (SHR_MEM_VALIDITY_DEV_INFO | SHR_MEM_VALIDITY_MB))
-		!= (SHR_MEM_VALIDITY_DEV_INFO | SHR_MEM_VALIDITY_MB))
-		BNX2X_ERR("BAD MCP validity signature\n");
-
-	bp->fw_seq = (SHMEM_RD(bp, func_mb[port].drv_mb_header) &
-		      DRV_MSG_SEQ_NUMBER_MASK);
-
-	bp->hw_config = SHMEM_RD(bp, dev_info.shared_hw_config.config);
-	bp->board = SHMEM_RD(bp, dev_info.shared_hw_config.board);
 	bp->link_params.serdes_config =
 		SHMEM_RD(bp, dev_info.port_hw_config[port].serdes_config);
 	bp->link_params.lane_config =
@@ -5423,19 +6267,18 @@ static void bnx2x_get_hwinfo(struct bnx2x *bp)
 		SHMEM_RD(bp,
 			 dev_info.port_hw_config[port].speed_capability_mask);
 
-	bp->link_config =
+	bp->port.link_config =
 		SHMEM_RD(bp, dev_info.port_feature_config[port].link_config);
 
-	BNX2X_DEV_INFO("serdes_config (%08x)  lane_config (%08x)\n"
-	     KERN_INFO "  ext_phy_config (%08x)  speed_cap_mask (%08x)"
-		       "  link_config (%08x)\n",
+	BNX2X_DEV_INFO("serdes_config 0x%08x  lane_config 0x%08x\n"
+	     KERN_INFO "  ext_phy_config 0x%08x  speed_cap_mask 0x%08x"
+		       "  link_config 0x%08x\n",
 		       bp->link_params.serdes_config,
 		       bp->link_params.lane_config,
 		       bp->link_params.ext_phy_config,
-		       bp->link_params.speed_cap_mask,
-		       bp->link_config);
+		       bp->link_params.speed_cap_mask, bp->port.link_config);
 
-	bp->link_params.switch_cfg = (bp->link_config &
+	bp->link_params.switch_cfg = (bp->port.link_config &
 				      PORT_FEATURE_CONNECTED_SWITCH_MASK);
 	bnx2x_link_settings_supported(bp, bp->link_params.switch_cfg);
 
@@ -5451,43 +6294,126 @@ static void bnx2x_get_hwinfo(struct bnx2x *bp)
 	bp->dev->dev_addr[5] = (u8)(val & 0xff);
 	memcpy(bp->link_params.mac_addr, bp->dev->dev_addr, ETH_ALEN);
 	memcpy(bp->dev->perm_addr, bp->dev->dev_addr, ETH_ALEN);
+}
 
+static int __devinit bnx2x_get_hwinfo(struct bnx2x *bp)
+{
+	int func = BP_FUNC(bp);
+	u32 val, val2;
+	int rc = 0;
 
+	bnx2x_get_common_hwinfo(bp);
 
-	val = SHMEM_RD(bp, dev_info.shared_hw_config.part_num);
-	val2 = SHMEM_RD(bp, dev_info.shared_hw_config.part_num[4]);
-	val3 = SHMEM_RD(bp, dev_info.shared_hw_config.part_num[8]);
-	val4 = SHMEM_RD(bp, dev_info.shared_hw_config.part_num[12]);
+	bp->e1hov = 0;
+	bp->e1hmf = 0;
+	if (CHIP_IS_E1H(bp)) {
+		bp->mf_config =
+			SHMEM_RD(bp, mf_cfg.func_mf_config[func].config);
 
-	printk(KERN_INFO PFX "part number %X-%X-%X-%X\n",
-	       val, val2, val3, val4);
+		val =
+		   (SHMEM_RD(bp, mf_cfg.func_mf_config[func].e1hov_tag) &
+		    FUNC_MF_CFG_E1HOV_TAG_MASK);
+		if (val != FUNC_MF_CFG_E1HOV_TAG_DEFAULT) {
 
-	/* bc ver */
-	if (!nomcp) {
-		bp->bc_ver = val = ((SHMEM_RD(bp, dev_info.bc_rev)) >> 8);
-		BNX2X_DEV_INFO("bc_ver %X\n", val);
-		if (val < BNX2X_BC_VER) {
-			/* for now only warn
-			 * later we might need to enforce this */
-			BNX2X_ERR("This driver needs bc_ver %X but found %X,"
-				  " please upgrade BC\n", BNX2X_BC_VER, val);
+			bp->e1hov = val;
+			bp->e1hmf = 1;
+			BNX2X_DEV_INFO("MF mode  E1HOV for func %d is %d "
+				       "(0x%04x)\n",
+				       func, bp->e1hov, bp->e1hov);
+		} else {
+			BNX2X_DEV_INFO("Single function mode\n");
+			if (BP_E1HVN(bp)) {
+				BNX2X_ERR("!!!  No valid E1HOV for func %d,"
+					  "  aborting\n", func);
+				rc = -EPERM;
+			}
 		}
-	} else {
-		bp->bc_ver = 0;
 	}
 
-	val = REG_RD(bp, MCP_REG_MCPR_NVM_CFG4);
-	bp->flash_size = (NVRAM_1MB_SIZE << (val & MCPR_NVM_CFG4_FLASH_SIZE));
-	BNX2X_DEV_INFO("flash_size 0x%x (%d)\n",
-		       bp->flash_size, bp->flash_size);
+	if (!BP_NOMCP(bp)) {
+		bnx2x_get_port_hwinfo(bp);
+
+		bp->fw_seq = (SHMEM_RD(bp, func_mb[func].drv_mb_header) &
+			      DRV_MSG_SEQ_NUMBER_MASK);
+		BNX2X_DEV_INFO("fw_seq 0x%08x\n", bp->fw_seq);
+	}
+
+	if (IS_E1HMF(bp)) {
+		val2 = SHMEM_RD(bp, mf_cfg.func_mf_config[func].mac_upper);
+		val = SHMEM_RD(bp,  mf_cfg.func_mf_config[func].mac_lower);
+		if ((val2 != FUNC_MF_CFG_UPPERMAC_DEFAULT) &&
+		    (val != FUNC_MF_CFG_LOWERMAC_DEFAULT)) {
+			bp->dev->dev_addr[0] = (u8)(val2 >> 8 & 0xff);
+			bp->dev->dev_addr[1] = (u8)(val2 & 0xff);
+			bp->dev->dev_addr[2] = (u8)(val >> 24 & 0xff);
+			bp->dev->dev_addr[3] = (u8)(val >> 16 & 0xff);
+			bp->dev->dev_addr[4] = (u8)(val >> 8  & 0xff);
+			bp->dev->dev_addr[5] = (u8)(val & 0xff);
+			memcpy(bp->link_params.mac_addr, bp->dev->dev_addr,
+			       ETH_ALEN);
+			memcpy(bp->dev->perm_addr, bp->dev->dev_addr,
+			       ETH_ALEN);
+		}
 
-	return;
+		return rc;
+	}
+
+	if (BP_NOMCP(bp)) {
+		/* only supposed to happen on emulation/FPGA */
+		BNX2X_ERR("warning rendom MAC workaround active\n");
+		random_ether_addr(bp->dev->dev_addr);
+		memcpy(bp->dev->perm_addr, bp->dev->dev_addr, ETH_ALEN);
+	}
+
+	return rc;
+}
+
+static int __devinit bnx2x_init_bp(struct bnx2x *bp)
+{
+	int func = BP_FUNC(bp);
+	int rc;
+
+	if (nomcp)
+		bp->flags |= NO_MCP_FLAG;
+
+	mutex_init(&bp->port.phy_mutex);
+
+	INIT_WORK(&bp->sp_task, bnx2x_sp_task);
+	INIT_WORK(&bp->reset_task, bnx2x_reset_task);
+
+	rc = bnx2x_get_hwinfo(bp);
+
+	/* need to reset chip if undi was active */
+	if (!BP_NOMCP(bp))
+		bnx2x_undi_unload(bp);
+
+	if (CHIP_REV_IS_FPGA(bp))
+		printk(KERN_ERR PFX "FPGA detected\n");
 
-set_mac: /* only supposed to happen on emulation/FPGA */
-	BNX2X_ERR("warning rendom MAC workaround active\n");
-	random_ether_addr(bp->dev->dev_addr);
-	memcpy(bp->dev->perm_addr, bp->dev->dev_addr, 6);
+	if (BP_NOMCP(bp) && (func == 0))
+		printk(KERN_ERR PFX
+		       "MCP disabled, must load devices in order!\n");
 
+	bp->tx_ring_size = MAX_TX_AVAIL;
+	bp->rx_ring_size = MAX_RX_AVAIL;
+
+	bp->rx_csum = 1;
+	bp->rx_offset = 0;
+
+	bp->tx_ticks = 50;
+	bp->rx_ticks = 25;
+
+	bp->stats_ticks = 1000000 & 0xffff00;
+
+	bp->timer_interval = (CHIP_REV_IS_SLOW(bp) ? 5*HZ : HZ);
+	bp->current_interval = (poll ? poll : bp->timer_interval);
+
+	init_timer(&bp->timer);
+	bp->timer.expires = jiffies + bp->current_interval;
+	bp->timer.data = (unsigned long) bp;
+	bp->timer.function = bnx2x_timer;
+
+	return rc;
 }
 
 /*
@@ -5500,8 +6426,8 @@ static int bnx2x_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
 	struct bnx2x *bp = netdev_priv(dev);
 
-	cmd->supported = bp->supported;
-	cmd->advertising = bp->advertising;
+	cmd->supported = bp->port.supported;
+	cmd->advertising = bp->port.advertising;
 
 	if (netif_carrier_ok(dev)) {
 		cmd->speed = bp->link_vars.line_speed;
@@ -5510,6 +6436,14 @@ static int bnx2x_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 		cmd->speed = bp->link_params.req_line_speed;
 		cmd->duplex = bp->link_params.req_duplex;
 	}
+	if (IS_E1HMF(bp)) {
+		u16 vn_max_rate;
+
+		vn_max_rate = ((bp->mf_config & FUNC_MF_CFG_MAX_BW_MASK) >>
+				FUNC_MF_CFG_MAX_BW_SHIFT) * 100;
+		if (vn_max_rate < cmd->speed)
+			cmd->speed = vn_max_rate;
+	}
 
 	if (bp->link_params.switch_cfg == SWITCH_CFG_10G) {
 		u32 ext_phy_type =
@@ -5541,7 +6475,7 @@ static int bnx2x_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 	} else
 		cmd->port = PORT_TP;
 
-	cmd->phy_address = bp->phy_addr;
+	cmd->phy_address = bp->port.phy_addr;
 	cmd->transceiver = XCVR_INTERNAL;
 
 	if (bp->link_params.req_line_speed == SPEED_AUTO_NEG)
@@ -5568,6 +6502,9 @@ static int bnx2x_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 	struct bnx2x *bp = netdev_priv(dev);
 	u32 advertising;
 
+	if (IS_E1HMF(bp))
+		return 0;
+
 	DP(NETIF_MSG_LINK, "ethtool_cmd: cmd %d\n"
 	   DP_LEVEL "  supported 0x%x  advertising 0x%x  speed %d\n"
 	   DP_LEVEL "  duplex %d  port %d  phy_address %d  transceiver %d\n"
@@ -5577,24 +6514,25 @@ static int bnx2x_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 	   cmd->autoneg, cmd->maxtxpkt, cmd->maxrxpkt);
 
 	if (cmd->autoneg == AUTONEG_ENABLE) {
-		if (!(bp->supported & SUPPORTED_Autoneg)) {
-			DP(NETIF_MSG_LINK, "Aotoneg not supported\n");
+		if (!(bp->port.supported & SUPPORTED_Autoneg)) {
+			DP(NETIF_MSG_LINK, "Autoneg not supported\n");
 			return -EINVAL;
 		}
 
 		/* advertise the requested speed and duplex if supported */
-		cmd->advertising &= bp->supported;
+		cmd->advertising &= bp->port.supported;
 
 		bp->link_params.req_line_speed = SPEED_AUTO_NEG;
 		bp->link_params.req_duplex = DUPLEX_FULL;
-		bp->advertising |= (ADVERTISED_Autoneg | cmd->advertising);
+		bp->port.advertising |= (ADVERTISED_Autoneg |
+					 cmd->advertising);
 
 	} else { /* forced speed */
 		/* advertise the requested speed and duplex if supported */
 		switch (cmd->speed) {
 		case SPEED_10:
 			if (cmd->duplex == DUPLEX_FULL) {
-				if (!(bp->supported &
+				if (!(bp->port.supported &
 				      SUPPORTED_10baseT_Full)) {
 					DP(NETIF_MSG_LINK,
 					   "10M full not supported\n");
@@ -5604,7 +6542,7 @@ static int bnx2x_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 				advertising = (ADVERTISED_10baseT_Full |
 					       ADVERTISED_TP);
 			} else {
-				if (!(bp->supported &
+				if (!(bp->port.supported &
 				      SUPPORTED_10baseT_Half)) {
 					DP(NETIF_MSG_LINK,
 					   "10M half not supported\n");
@@ -5618,7 +6556,7 @@ static int bnx2x_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 
 		case SPEED_100:
 			if (cmd->duplex == DUPLEX_FULL) {
-				if (!(bp->supported &
+				if (!(bp->port.supported &
 						SUPPORTED_100baseT_Full)) {
 					DP(NETIF_MSG_LINK,
 					   "100M full not supported\n");
@@ -5628,7 +6566,7 @@ static int bnx2x_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 				advertising = (ADVERTISED_100baseT_Full |
 					       ADVERTISED_TP);
 			} else {
-				if (!(bp->supported &
+				if (!(bp->port.supported &
 						SUPPORTED_100baseT_Half)) {
 					DP(NETIF_MSG_LINK,
 					   "100M half not supported\n");
@@ -5646,7 +6584,7 @@ static int bnx2x_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 				return -EINVAL;
 			}
 
-			if (!(bp->supported & SUPPORTED_1000baseT_Full)) {
+			if (!(bp->port.supported & SUPPORTED_1000baseT_Full)) {
 				DP(NETIF_MSG_LINK, "1G full not supported\n");
 				return -EINVAL;
 			}
@@ -5662,7 +6600,7 @@ static int bnx2x_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 				return -EINVAL;
 			}
 
-			if (!(bp->supported & SUPPORTED_2500baseX_Full)) {
+			if (!(bp->port.supported & SUPPORTED_2500baseX_Full)) {
 				DP(NETIF_MSG_LINK,
 				   "2.5G full not supported\n");
 				return -EINVAL;
@@ -5678,7 +6616,7 @@ static int bnx2x_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 				return -EINVAL;
 			}
 
-			if (!(bp->supported & SUPPORTED_10000baseT_Full)) {
+			if (!(bp->port.supported & SUPPORTED_10000baseT_Full)) {
 				DP(NETIF_MSG_LINK, "10G full not supported\n");
 				return -EINVAL;
 			}
@@ -5694,16 +6632,18 @@ static int bnx2x_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 
 		bp->link_params.req_line_speed = cmd->speed;
 		bp->link_params.req_duplex = cmd->duplex;
-		bp->advertising = advertising;
+		bp->port.advertising = advertising;
 	}
 
 	DP(NETIF_MSG_LINK, "req_line_speed %d\n"
 	   DP_LEVEL "  req_duplex %d  advertising 0x%x\n",
 	   bp->link_params.req_line_speed, bp->link_params.req_duplex,
-	   bp->advertising);
+	   bp->port.advertising);
 
-	bnx2x_stop_stats(bp);
-	bnx2x_link_set(bp);
+	if (netif_running(dev)) {
+		bnx2x_stop_stats(bp);
+		bnx2x_link_set(bp);
+	}
 
 	return 0;
 }
@@ -5720,21 +6660,23 @@ static void bnx2x_get_drvinfo(struct net_device *dev,
 	strcpy(info->version, DRV_MODULE_VERSION);
 
 	phy_fw_ver[0] = '\0';
-	bnx2x_phy_hw_lock(bp);
-	bnx2x_get_ext_phy_fw_version(&bp->link_params,
-				     (bp->state != BNX2X_STATE_CLOSED),
-				     phy_fw_ver, PHY_FW_VER_LEN);
-	bnx2x_phy_hw_unlock(bp);
+	if (bp->port.pmf) {
+		bnx2x_phy_hw_lock(bp);
+		bnx2x_get_ext_phy_fw_version(&bp->link_params,
+					     (bp->state != BNX2X_STATE_CLOSED),
+					     phy_fw_ver, PHY_FW_VER_LEN);
+		bnx2x_phy_hw_unlock(bp);
+	}
 
 	snprintf(info->fw_version, 32, "%d.%d.%d:%d BC:%x%s%s",
 		 BCM_5710_FW_MAJOR_VERSION, BCM_5710_FW_MINOR_VERSION,
 		 BCM_5710_FW_REVISION_VERSION,
-		 BCM_5710_FW_COMPILE_FLAGS, bp->bc_ver,
+		 BCM_5710_FW_COMPILE_FLAGS, bp->common.bc_ver,
 		 ((phy_fw_ver[0] != '\0')? " PHY:":""), phy_fw_ver);
 	strcpy(info->bus_info, pci_name(bp->pdev));
 	info->n_stats = BNX2X_NUM_STATS;
 	info->testinfo_len = BNX2X_NUM_TESTS;
-	info->eedump_len = bp->flash_size;
+	info->eedump_len = bp->common.flash_size;
 	info->regdump_len = 0;
 }
 
@@ -5767,9 +6709,9 @@ static int bnx2x_set_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 			return -EINVAL;
 
 		bp->wol = 1;
-	} else {
+	} else
 		bp->wol = 0;
-	}
+
 	return 0;
 }
 
@@ -5792,13 +6734,13 @@ static int bnx2x_nway_reset(struct net_device *dev)
 {
 	struct bnx2x *bp = netdev_priv(dev);
 
-	if (bp->state != BNX2X_STATE_OPEN) {
-		DP(NETIF_MSG_PROBE, "state is %x, returning\n", bp->state);
-		return -EAGAIN;
-	}
+	if (!bp->port.pmf)
+		return 0;
 
-	bnx2x_stop_stats(bp);
-	bnx2x_link_set(bp);
+	if (netif_running(dev)) {
+		bnx2x_stop_stats(bp);
+		bnx2x_link_set(bp);
+	}
 
 	return 0;
 }
@@ -5807,12 +6749,12 @@ static int bnx2x_get_eeprom_len(struct net_device *dev)
 {
 	struct bnx2x *bp = netdev_priv(dev);
 
-	return bp->flash_size;
+	return bp->common.flash_size;
 }
 
 static int bnx2x_acquire_nvram_lock(struct bnx2x *bp)
 {
-	int port = bp->port;
+	int port = BP_PORT(bp);
 	int count, i;
 	u32 val = 0;
 
@@ -5834,7 +6776,7 @@ static int bnx2x_acquire_nvram_lock(struct bnx2x *bp)
 	}
 
 	if (!(val & (MCPR_NVM_SW_ARB_ARB_ARB1 << port))) {
-		DP(NETIF_MSG_NVM, "cannot get access to nvram interface\n");
+		DP(BNX2X_MSG_NVM, "cannot get access to nvram interface\n");
 		return -EBUSY;
 	}
 
@@ -5843,7 +6785,7 @@ static int bnx2x_acquire_nvram_lock(struct bnx2x *bp)
 
 static int bnx2x_release_nvram_lock(struct bnx2x *bp)
 {
-	int port = bp->port;
+	int port = BP_PORT(bp);
 	int count, i;
 	u32 val = 0;
 
@@ -5865,7 +6807,7 @@ static int bnx2x_release_nvram_lock(struct bnx2x *bp)
 	}
 
 	if (val & (MCPR_NVM_SW_ARB_ARB_ARB1 << port)) {
-		DP(NETIF_MSG_NVM, "cannot free access to nvram interface\n");
+		DP(BNX2X_MSG_NVM, "cannot free access to nvram interface\n");
 		return -EBUSY;
 	}
 
@@ -5929,7 +6871,6 @@ static int bnx2x_nvram_read_dword(struct bnx2x *bp, u32 offset, u32 *ret_val,
 
 		if (val & MCPR_NVM_COMMAND_DONE) {
 			val = REG_RD(bp, MCP_REG_MCPR_NVM_READ);
-			DP(NETIF_MSG_NVM, "val 0x%08x\n", val);
 			/* we read nvram data in cpu order
 			 * but ethtool sees it as an array of bytes
 			 * converting to big-endian will do the work */
@@ -5951,16 +6892,16 @@ static int bnx2x_nvram_read(struct bnx2x *bp, u32 offset, u8 *ret_buf,
 	u32 val;
 
 	if ((offset & 0x03) || (buf_size & 0x03) || (buf_size == 0)) {
-		DP(NETIF_MSG_NVM,
+		DP(BNX2X_MSG_NVM,
 		   "Invalid parameter: offset 0x%x  buf_size 0x%x\n",
 		   offset, buf_size);
 		return -EINVAL;
 	}
 
-	if (offset + buf_size > bp->flash_size) {
-		DP(NETIF_MSG_NVM, "Invalid parameter: offset (0x%x) +"
+	if (offset + buf_size > bp->common.flash_size) {
+		DP(BNX2X_MSG_NVM, "Invalid parameter: offset (0x%x) +"
 				  " buf_size (0x%x) > flash_size (0x%x)\n",
-		   offset, buf_size, bp->flash_size);
+		   offset, buf_size, bp->common.flash_size);
 		return -EINVAL;
 	}
 
@@ -6004,7 +6945,7 @@ static int bnx2x_get_eeprom(struct net_device *dev,
 	struct bnx2x *bp = netdev_priv(dev);
 	int rc;
 
-	DP(NETIF_MSG_NVM, "ethtool_eeprom: cmd %d\n"
+	DP(BNX2X_MSG_NVM, "ethtool_eeprom: cmd %d\n"
 	   DP_LEVEL "  magic 0x%x  offset 0x%x (%d)  len 0x%x (%d)\n",
 	   eeprom->cmd, eeprom->magic, eeprom->offset, eeprom->offset,
 	   eeprom->len, eeprom->len);
@@ -6066,10 +7007,10 @@ static int bnx2x_nvram_write1(struct bnx2x *bp, u32 offset, u8 *data_buf,
 	u32 align_offset;
 	u32 val;
 
-	if (offset + buf_size > bp->flash_size) {
-		DP(NETIF_MSG_NVM, "Invalid parameter: offset (0x%x) +"
+	if (offset + buf_size > bp->common.flash_size) {
+		DP(BNX2X_MSG_NVM, "Invalid parameter: offset (0x%x) +"
 				  " buf_size (0x%x) > flash_size (0x%x)\n",
-		   offset, buf_size, bp->flash_size);
+		   offset, buf_size, bp->common.flash_size);
 		return -EINVAL;
 	}
 
@@ -6093,8 +7034,6 @@ static int bnx2x_nvram_write1(struct bnx2x *bp, u32 offset, u8 *data_buf,
 		 * convert it back to cpu order */
 		val = be32_to_cpu(val);
 
-		DP(NETIF_MSG_NVM, "val 0x%08x\n", val);
-
 		rc = bnx2x_nvram_write_dword(bp, align_offset, val,
 					     cmd_flags);
 	}
@@ -6114,21 +7053,20 @@ static int bnx2x_nvram_write(struct bnx2x *bp, u32 offset, u8 *data_buf,
 	u32 val;
 	u32 written_so_far;
 
-	if (buf_size == 1) {    /* ethtool */
+	if (buf_size == 1)	/* ethtool */
 		return bnx2x_nvram_write1(bp, offset, data_buf, buf_size);
-	}
 
 	if ((offset & 0x03) || (buf_size & 0x03) || (buf_size == 0)) {
-		DP(NETIF_MSG_NVM,
+		DP(BNX2X_MSG_NVM,
 		   "Invalid parameter: offset 0x%x  buf_size 0x%x\n",
 		   offset, buf_size);
 		return -EINVAL;
 	}
 
-	if (offset + buf_size > bp->flash_size) {
-		DP(NETIF_MSG_NVM, "Invalid parameter: offset (0x%x) +"
+	if (offset + buf_size > bp->common.flash_size) {
+		DP(BNX2X_MSG_NVM, "Invalid parameter: offset (0x%x) +"
 				  " buf_size (0x%x) > flash_size (0x%x)\n",
-		   offset, buf_size, bp->flash_size);
+		   offset, buf_size, bp->common.flash_size);
 		return -EINVAL;
 	}
 
@@ -6151,7 +7089,6 @@ static int bnx2x_nvram_write(struct bnx2x *bp, u32 offset, u8 *data_buf,
 			cmd_flags |= MCPR_NVM_COMMAND_FIRST;
 
 		memcpy(&val, data_buf, 4);
-		DP(NETIF_MSG_NVM, "val 0x%08x\n", val);
 
 		rc = bnx2x_nvram_write_dword(bp, offset, val, cmd_flags);
 
@@ -6175,7 +7112,7 @@ static int bnx2x_set_eeprom(struct net_device *dev,
 	struct bnx2x *bp = netdev_priv(dev);
 	int rc;
 
-	DP(NETIF_MSG_NVM, "ethtool_eeprom: cmd %d\n"
+	DP(BNX2X_MSG_NVM, "ethtool_eeprom: cmd %d\n"
 	   DP_LEVEL "  magic 0x%x  offset 0x%x (%d)  len 0x%x (%d)\n",
 	   eeprom->cmd, eeprom->magic, eeprom->offset, eeprom->offset,
 	   eeprom->len, eeprom->len);
@@ -6183,20 +7120,23 @@ static int bnx2x_set_eeprom(struct net_device *dev,
 	/* parameters already validated in ethtool_set_eeprom */
 
 	/* If the magic number is PHY (0x00504859) upgrade the PHY FW */
-	if (eeprom->magic == 0x00504859) {
-
-		bnx2x_phy_hw_lock(bp);
-		rc = bnx2x_flash_download(bp, bp->port,
-				     bp->link_params.ext_phy_config,
-				     (bp->state != BNX2X_STATE_CLOSED),
-				     eebuf, eeprom->len);
-		rc |= bnx2x_link_reset(&bp->link_params,
-				       &bp->link_vars);
-		rc |= bnx2x_phy_init(&bp->link_params,
-				     &bp->link_vars);
-		bnx2x_phy_hw_unlock(bp);
-
-	} else
+	if (eeprom->magic == 0x00504859)
+		if (bp->port.pmf) {
+
+			bnx2x_phy_hw_lock(bp);
+			rc = bnx2x_flash_download(bp, BP_PORT(bp),
+					     bp->link_params.ext_phy_config,
+					     (bp->state != BNX2X_STATE_CLOSED),
+					     eebuf, eeprom->len);
+				rc |= bnx2x_link_reset(&bp->link_params,
+						       &bp->link_vars);
+				rc |= bnx2x_phy_init(&bp->link_params,
+						     &bp->link_vars);
+			bnx2x_phy_hw_unlock(bp);
+
+		} else /* Only the PMF can access the PHY */
+			return -EINVAL;
+	else
 		rc = bnx2x_nvram_write(bp, eeprom->offset, eebuf, eeprom->len);
 
 	return rc;
@@ -6234,7 +7174,7 @@ static int bnx2x_set_coalesce(struct net_device *dev,
 		bp->stats_ticks = 0xffff00;
 	bp->stats_ticks &= 0xffff00;
 
-	if (netif_running(bp->dev))
+	if (netif_running(dev))
 		bnx2x_update_coalesce(bp);
 
 	return 0;
@@ -6261,6 +7201,7 @@ static int bnx2x_set_ringparam(struct net_device *dev,
 			       struct ethtool_ringparam *ering)
 {
 	struct bnx2x *bp = netdev_priv(dev);
+	int rc = 0;
 
 	if ((ering->rx_pending > MAX_RX_AVAIL) ||
 	    (ering->tx_pending > MAX_TX_AVAIL) ||
@@ -6270,12 +7211,12 @@ static int bnx2x_set_ringparam(struct net_device *dev,
 	bp->rx_ring_size = ering->rx_pending;
 	bp->tx_ring_size = ering->tx_pending;
 
-	if (netif_running(bp->dev)) {
-		bnx2x_nic_unload(bp, 0);
-		bnx2x_nic_load(bp, 0);
+	if (netif_running(dev)) {
+		bnx2x_nic_unload(bp, UNLOAD_NORMAL);
+		rc = bnx2x_nic_load(bp, LOAD_NORMAL);
 	}
 
-	return 0;
+	return rc;
 }
 
 static void bnx2x_get_pauseparam(struct net_device *dev,
@@ -6301,6 +7242,9 @@ static int bnx2x_set_pauseparam(struct net_device *dev,
 {
 	struct bnx2x *bp = netdev_priv(dev);
 
+	if (IS_E1HMF(bp))
+		return 0;
+
 	DP(NETIF_MSG_LINK, "ethtool_pauseparam: cmd %d\n"
 	   DP_LEVEL "  autoneg %d  rx_pause %d  tx_pause %d\n",
 	   epause->cmd, epause->autoneg, epause->rx_pause, epause->tx_pause);
@@ -6317,7 +7261,7 @@ static int bnx2x_set_pauseparam(struct net_device *dev,
 		bp->link_params.req_flow_ctrl = FLOW_CTRL_NONE;
 
 	if (epause->autoneg) {
-		if (!(bp->supported & SUPPORTED_Autoneg)) {
+		if (!(bp->port.supported & SUPPORTED_Autoneg)) {
 			DP(NETIF_MSG_LINK, "Autoneg not supported\n");
 			return -EINVAL;
 		}
@@ -6328,8 +7272,11 @@ static int bnx2x_set_pauseparam(struct net_device *dev,
 
 	DP(NETIF_MSG_LINK,
 	   "req_flow_ctrl 0x%x\n", bp->link_params.req_flow_ctrl);
-	bnx2x_stop_stats(bp);
-	bnx2x_link_set(bp);
+
+	if (netif_running(dev)) {
+		bnx2x_stop_stats(bp);
+		bnx2x_link_set(bp);
+	}
 
 	return 0;
 }
@@ -6531,18 +7478,25 @@ static void bnx2x_get_ethtool_stats(struct net_device *dev,
 static int bnx2x_phys_id(struct net_device *dev, u32 data)
 {
 	struct bnx2x *bp = netdev_priv(dev);
+	int port = BP_PORT(bp);
 	int i;
 
+	if (!netif_running(dev))
+		return 0;
+
+	if (!bp->port.pmf)
+		return 0;
+
 	if (data == 0)
 		data = 2;
 
 	for (i = 0; i < (data * 2); i++) {
 		if ((i % 2) == 0)
-			bnx2x_set_led(bp, bp->port, LED_MODE_OPER, SPEED_1000,
+			bnx2x_set_led(bp, port, LED_MODE_OPER, SPEED_1000,
 				      bp->link_params.hw_led_mode,
 				      bp->link_params.chip_id);
 		else
-			bnx2x_set_led(bp, bp->port, LED_MODE_OFF, 0,
+			bnx2x_set_led(bp, port, LED_MODE_OFF, 0,
 				      bp->link_params.hw_led_mode,
 				      bp->link_params.chip_id);
 
@@ -6552,7 +7506,7 @@ static int bnx2x_phys_id(struct net_device *dev, u32 data)
 	}
 
 	if (bp->link_vars.link_up)
-		bnx2x_set_led(bp, bp->port, LED_MODE_OPER,
+		bnx2x_set_led(bp, port, LED_MODE_OPER,
 			      bp->link_vars.line_speed,
 			      bp->link_params.hw_led_mode,
 			      bp->link_params.chip_id);
@@ -6609,8 +7563,7 @@ static int bnx2x_set_power_state(struct bnx2x *bp, pci_power_t state)
 
 	switch (state) {
 	case PCI_D0:
-		pci_write_config_word(bp->pdev,
-				      bp->pm_cap + PCI_PM_CTRL,
+		pci_write_config_word(bp->pdev, bp->pm_cap + PCI_PM_CTRL,
 				      ((pmcsr & ~PCI_PM_CTRL_STATE_MASK) |
 				       PCI_PM_CTRL_PME_STATUS));
 
@@ -6644,82 +7597,6 @@ static int bnx2x_set_power_state(struct bnx2x *bp, pci_power_t state)
  * net_device service functions
  */
 
-/* called with netif_tx_lock from set_multicast */
-static void bnx2x_set_rx_mode(struct net_device *dev)
-{
-	struct bnx2x *bp = netdev_priv(dev);
-	u32 rx_mode = BNX2X_RX_MODE_NORMAL;
-
-	DP(NETIF_MSG_IFUP, "called dev->flags = %x\n", dev->flags);
-
-	if (dev->flags & IFF_PROMISC)
-		rx_mode = BNX2X_RX_MODE_PROMISC;
-
-	else if ((dev->flags & IFF_ALLMULTI) ||
-		 (dev->mc_count > BNX2X_MAX_MULTICAST))
-		rx_mode = BNX2X_RX_MODE_ALLMULTI;
-
-	else { /* some multicasts */
-		int i, old, offset;
-		struct dev_mc_list *mclist;
-		struct mac_configuration_cmd *config =
-						bnx2x_sp(bp, mcast_config);
-
-		for (i = 0, mclist = dev->mc_list;
-		     mclist && (i < dev->mc_count);
-		     i++, mclist = mclist->next) {
-
-			config->config_table[i].cam_entry.msb_mac_addr =
-					swab16(*(u16 *)&mclist->dmi_addr[0]);
-			config->config_table[i].cam_entry.middle_mac_addr =
-					swab16(*(u16 *)&mclist->dmi_addr[2]);
-			config->config_table[i].cam_entry.lsb_mac_addr =
-					swab16(*(u16 *)&mclist->dmi_addr[4]);
-			config->config_table[i].cam_entry.flags =
-							cpu_to_le16(bp->port);
-			config->config_table[i].target_table_entry.flags = 0;
-			config->config_table[i].target_table_entry.
-								client_id = 0;
-			config->config_table[i].target_table_entry.
-								vlan_id = 0;
-
-			DP(NETIF_MSG_IFUP,
-			   "setting MCAST[%d] (%04x:%04x:%04x)\n",
-			   i, config->config_table[i].cam_entry.msb_mac_addr,
-			   config->config_table[i].cam_entry.middle_mac_addr,
-			   config->config_table[i].cam_entry.lsb_mac_addr);
-		}
-		old = config->hdr.length_6b;
-		if (old > i) {
-			for (; i < old; i++) {
-				if (CAM_IS_INVALID(config->config_table[i])) {
-					i--; /* already invalidated */
-					break;
-				}
-				/* invalidate */
-				CAM_INVALIDATE(config->config_table[i]);
-			}
-		}
-
-		if (CHIP_REV_IS_SLOW(bp))
-			offset = BNX2X_MAX_EMUL_MULTI*(1 + bp->port);
-		else
-			offset = BNX2X_MAX_MULTICAST*(1 + bp->port);
-
-		config->hdr.length_6b = i;
-		config->hdr.offset = offset;
-		config->hdr.reserved0 = 0;
-		config->hdr.reserved1 = 0;
-
-		bnx2x_sp_post(bp, RAMROD_CMD_ID_ETH_SET_MAC, 0,
-			      U64_HI(bnx2x_sp_mapping(bp, mcast_config)),
-			      U64_LO(bnx2x_sp_mapping(bp, mcast_config)), 0);
-	}
-
-	bp->rx_mode = rx_mode;
-	bnx2x_set_storm_rx_mode(bp);
-}
-
 static int bnx2x_poll(struct napi_struct *napi, int budget)
 {
 	struct bnx2x_fastpath *fp = container_of(napi, struct bnx2x_fastpath,
@@ -6729,7 +7606,7 @@ static int bnx2x_poll(struct napi_struct *napi, int budget)
 
 #ifdef BNX2X_STOP_ON_ERROR
 	if (unlikely(bp->panic))
-		goto out_panic;
+		goto poll_panic;
 #endif
 
 	prefetch(fp->tx_buf_ring[TX_BD(fp->tx_pkt_cons)].skb);
@@ -6738,30 +7615,28 @@ static int bnx2x_poll(struct napi_struct *napi, int budget)
 
 	bnx2x_update_fpsb_idx(fp);
 
-	if (le16_to_cpu(*fp->tx_cons_sb) != fp->tx_pkt_cons)
+	if ((fp->tx_pkt_prod != le16_to_cpu(*fp->tx_cons_sb)) ||
+	    (fp->tx_pkt_prod != fp->tx_pkt_cons))
 		bnx2x_tx_int(fp, budget);
 
-
 	if (le16_to_cpu(*fp->rx_cons_sb) != fp->rx_comp_cons)
 		work_done = bnx2x_rx_int(fp, budget);
 
-
 	rmb(); /* bnx2x_has_work() reads the status block */
 
 	/* must not complete if we consumed full budget */
 	if ((work_done < budget) && !bnx2x_has_work(fp)) {
 
 #ifdef BNX2X_STOP_ON_ERROR
-out_panic:
+poll_panic:
 #endif
 		netif_rx_complete(bp->dev, napi);
 
-		bnx2x_ack_sb(bp, fp->index, USTORM_ID,
+		bnx2x_ack_sb(bp, FP_SB_ID(fp), USTORM_ID,
 			     le16_to_cpu(fp->fp_u_idx), IGU_INT_NOP, 1);
-		bnx2x_ack_sb(bp, fp->index, CSTORM_ID,
+		bnx2x_ack_sb(bp, FP_SB_ID(fp), CSTORM_ID,
 			     le16_to_cpu(fp->fp_c_idx), IGU_INT_ENABLE, 1);
 	}
-
 	return work_done;
 }
 
@@ -7055,18 +7930,145 @@ static int bnx2x_close(struct net_device *dev)
 	return 0;
 }
 
-/* Called with rtnl_lock */
+/* called with netif_tx_lock from set_multicast */
+static void bnx2x_set_rx_mode(struct net_device *dev)
+{
+	struct bnx2x *bp = netdev_priv(dev);
+	u32 rx_mode = BNX2X_RX_MODE_NORMAL;
+	int port = BP_PORT(bp);
+
+	if (bp->state != BNX2X_STATE_OPEN) {
+		DP(NETIF_MSG_IFUP, "state is %x, returning\n", bp->state);
+		return;
+	}
+
+	DP(NETIF_MSG_IFUP, "dev->flags = %x\n", dev->flags);
+
+	if (dev->flags & IFF_PROMISC)
+		rx_mode = BNX2X_RX_MODE_PROMISC;
+
+	else if ((dev->flags & IFF_ALLMULTI) ||
+		 ((dev->mc_count > BNX2X_MAX_MULTICAST) && CHIP_IS_E1(bp)))
+		rx_mode = BNX2X_RX_MODE_ALLMULTI;
+
+	else { /* some multicasts */
+		if (CHIP_IS_E1(bp)) {
+			int i, old, offset;
+			struct dev_mc_list *mclist;
+			struct mac_configuration_cmd *config =
+						bnx2x_sp(bp, mcast_config);
+
+			for (i = 0, mclist = dev->mc_list;
+			     mclist && (i < dev->mc_count);
+			     i++, mclist = mclist->next) {
+
+				config->config_table[i].
+					cam_entry.msb_mac_addr =
+					swab16(*(u16 *)&mclist->dmi_addr[0]);
+				config->config_table[i].
+					cam_entry.middle_mac_addr =
+					swab16(*(u16 *)&mclist->dmi_addr[2]);
+				config->config_table[i].
+					cam_entry.lsb_mac_addr =
+					swab16(*(u16 *)&mclist->dmi_addr[4]);
+				config->config_table[i].cam_entry.flags =
+							cpu_to_le16(port);
+				config->config_table[i].
+					target_table_entry.flags = 0;
+				config->config_table[i].
+					target_table_entry.client_id = 0;
+				config->config_table[i].
+					target_table_entry.vlan_id = 0;
+
+				DP(NETIF_MSG_IFUP,
+				   "setting MCAST[%d] (%04x:%04x:%04x)\n", i,
+				   config->config_table[i].
+						cam_entry.msb_mac_addr,
+				   config->config_table[i].
+						cam_entry.middle_mac_addr,
+				   config->config_table[i].
+						cam_entry.lsb_mac_addr);
+			}
+			old = config->hdr.length_6b;
+			if (old > i) {
+				for (; i < old; i++) {
+					if (CAM_IS_INVALID(config->
+							   config_table[i])) {
+						i--; /* already invalidated */
+						break;
+					}
+					/* invalidate */
+					CAM_INVALIDATE(config->
+						       config_table[i]);
+				}
+			}
+
+			if (CHIP_REV_IS_SLOW(bp))
+				offset = BNX2X_MAX_EMUL_MULTI*(1 + port);
+			else
+				offset = BNX2X_MAX_MULTICAST*(1 + port);
+
+			config->hdr.length_6b = i;
+			config->hdr.offset = offset;
+			config->hdr.client_id = BP_CL_ID(bp);
+			config->hdr.reserved1 = 0;
+
+			bnx2x_sp_post(bp, RAMROD_CMD_ID_ETH_SET_MAC, 0,
+				   U64_HI(bnx2x_sp_mapping(bp, mcast_config)),
+				   U64_LO(bnx2x_sp_mapping(bp, mcast_config)),
+				      0);
+		} else { /* E1H */
+			/* Accept one or more multicasts */
+			struct dev_mc_list *mclist;
+			u32 mc_filter[MC_HASH_SIZE];
+			u32 crc, bit, regidx;
+			int i;
+
+			memset(mc_filter, 0, 4 * MC_HASH_SIZE);
+
+			for (i = 0, mclist = dev->mc_list;
+			     mclist && (i < dev->mc_count);
+			     i++, mclist = mclist->next) {
+
+				DP(NETIF_MSG_IFUP, "Adding mcast MAC: "
+				   "%02x:%02x:%02x:%02x:%02x:%02x\n",
+				   mclist->dmi_addr[0], mclist->dmi_addr[1],
+				   mclist->dmi_addr[2], mclist->dmi_addr[3],
+				   mclist->dmi_addr[4], mclist->dmi_addr[5]);
+
+				crc = crc32c_le(0, mclist->dmi_addr, ETH_ALEN);
+				bit = (crc >> 24) & 0xff;
+				regidx = bit >> 5;
+				bit &= 0x1f;
+				mc_filter[regidx] |= (1 << bit);
+			}
+
+			for (i = 0; i < MC_HASH_SIZE; i++)
+				REG_WR(bp, MC_HASH_OFFSET(bp, i),
+				       mc_filter[i]);
+		}
+	}
+
+	bp->rx_mode = rx_mode;
+	bnx2x_set_storm_rx_mode(bp);
+}
+
+/* called with rtnl_lock */
 static int bnx2x_change_mac_addr(struct net_device *dev, void *p)
 {
 	struct sockaddr *addr = p;
 	struct bnx2x *bp = netdev_priv(dev);
 
-	if (!is_valid_ether_addr(addr->sa_data))
+	if (!is_valid_ether_addr((u8 *)(addr->sa_data)))
 		return -EINVAL;
 
 	memcpy(dev->dev_addr, addr->sa_data, dev->addr_len);
-	if (netif_running(dev))
-		bnx2x_set_mac_addr(bp);
+	if (netif_running(dev)) {
+		if (CHIP_IS_E1(bp))
+			bnx2x_set_mac_addr_e1(bp);
+		else
+			bnx2x_set_mac_addr_e1h(bp);
+	}
 
 	return 0;
 }
@@ -7080,7 +8082,7 @@ static int bnx2x_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 
 	switch (cmd) {
 	case SIOCGMIIPHY:
-		data->phy_id = bp->phy_addr;
+		data->phy_id = bp->port.phy_addr;
 
 		/* fallthrough */
 
@@ -7090,12 +8092,12 @@ static int bnx2x_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 		if (!netif_running(dev))
 			return -EAGAIN;
 
-		mutex_lock(&bp->phy_mutex);
-		err = bnx2x_cl45_read(bp, bp->port, 0, bp->phy_addr,
+		mutex_lock(&bp->port.phy_mutex);
+		err = bnx2x_cl45_read(bp, BP_PORT(bp), 0, bp->port.phy_addr,
 				      DEFAULT_PHY_DEV_ADDR,
 				      (data->reg_num & 0x1f), &mii_regval);
 		data->val_out = mii_regval;
-		mutex_unlock(&bp->phy_mutex);
+		mutex_unlock(&bp->port.phy_mutex);
 		return err;
 	}
 
@@ -7106,11 +8108,11 @@ static int bnx2x_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 		if (!netif_running(dev))
 			return -EAGAIN;
 
-		mutex_lock(&bp->phy_mutex);
-		err = bnx2x_cl45_write(bp, bp->port, 0, bp->phy_addr,
+		mutex_lock(&bp->port.phy_mutex);
+		err = bnx2x_cl45_write(bp, BP_PORT(bp), 0, bp->port.phy_addr,
 				       DEFAULT_PHY_DEV_ADDR,
 				       (data->reg_num & 0x1f), data->val_in);
-		mutex_unlock(&bp->phy_mutex);
+		mutex_unlock(&bp->port.phy_mutex);
 		return err;
 
 	default:
@@ -7121,10 +8123,11 @@ static int bnx2x_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 	return -EOPNOTSUPP;
 }
 
-/* Called with rtnl_lock */
+/* called with rtnl_lock */
 static int bnx2x_change_mtu(struct net_device *dev, int new_mtu)
 {
 	struct bnx2x *bp = netdev_priv(dev);
+	int rc = 0;
 
 	if ((new_mtu > ETH_MAX_JUMBO_PACKET_SIZE) ||
 	    ((new_mtu + ETH_HLEN) < ETH_MIN_PACKET_SIZE))
@@ -7137,10 +8140,11 @@ static int bnx2x_change_mtu(struct net_device *dev, int new_mtu)
 	dev->mtu = new_mtu;
 
 	if (netif_running(dev)) {
-		bnx2x_nic_unload(bp, 0);
-		bnx2x_nic_load(bp, 0);
+		bnx2x_nic_unload(bp, UNLOAD_NORMAL);
+		rc = bnx2x_nic_load(bp, LOAD_NORMAL);
 	}
-	return 0;
+
+	return rc;
 }
 
 static void bnx2x_tx_timeout(struct net_device *dev)
@@ -7156,7 +8160,7 @@ static void bnx2x_tx_timeout(struct net_device *dev)
 }
 
 #ifdef BCM_VLAN
-/* Called with rtnl_lock */
+/* called with rtnl_lock */
 static void bnx2x_vlan_rx_register(struct net_device *dev,
 				   struct vlan_group *vlgrp)
 {
@@ -7166,6 +8170,7 @@ static void bnx2x_vlan_rx_register(struct net_device *dev,
 	if (netif_running(dev))
 		bnx2x_set_client_config(bp);
 }
+
 #endif
 
 #if defined(HAVE_POLL_CONTROLLER) || defined(CONFIG_NET_POLL_CONTROLLER)
@@ -7179,36 +8184,8 @@ static void poll_bnx2x(struct net_device *dev)
 }
 #endif
 
-static void bnx2x_reset_task(struct work_struct *work)
-{
-	struct bnx2x *bp = container_of(work, struct bnx2x, reset_task);
-
-#ifdef BNX2X_STOP_ON_ERROR
-	BNX2X_ERR("reset task called but STOP_ON_ERROR defined"
-		  " so reset not done to allow debug dump,\n"
-	 KERN_ERR " you will need to reboot when done\n");
-	return;
-#endif
-
-	if (!netif_running(bp->dev))
-		return;
-
-	rtnl_lock();
-
-	if (bp->state != BNX2X_STATE_OPEN) {
-		DP(NETIF_MSG_TX_ERR, "state is %x, returning\n", bp->state);
-		goto reset_task_exit;
-	}
-
-	bnx2x_nic_unload(bp, 0);
-	bnx2x_nic_load(bp, 0);
-
-reset_task_exit:
-	rtnl_unlock();
-}
-
-static int __devinit bnx2x_init_board(struct pci_dev *pdev,
-				      struct net_device *dev)
+static int __devinit bnx2x_init_dev(struct pci_dev *pdev,
+				    struct net_device *dev)
 {
 	struct bnx2x *bp;
 	int rc;
@@ -7216,8 +8193,10 @@ static int __devinit bnx2x_init_board(struct pci_dev *pdev,
 	SET_NETDEV_DEV(dev, &pdev->dev);
 	bp = netdev_priv(dev);
 
+	bp->dev = dev;
+	bp->pdev = pdev;
 	bp->flags = 0;
-	bp->port = PCI_FUNC(pdev->devfn);
+	bp->func = PCI_FUNC(pdev->devfn);
 
 	rc = pci_enable_device(pdev);
 	if (rc) {
@@ -7239,14 +8218,17 @@ static int __devinit bnx2x_init_board(struct pci_dev *pdev,
 		goto err_out_disable;
 	}
 
-	rc = pci_request_regions(pdev, DRV_MODULE_NAME);
-	if (rc) {
-		printk(KERN_ERR PFX "Cannot obtain PCI resources,"
-		       " aborting\n");
-		goto err_out_disable;
-	}
+	if (atomic_read(&pdev->enable_cnt) == 1) {
+		rc = pci_request_regions(pdev, DRV_MODULE_NAME);
+		if (rc) {
+			printk(KERN_ERR PFX "Cannot obtain PCI resources,"
+			       " aborting\n");
+			goto err_out_disable;
+		}
 
-	pci_set_master(pdev);
+		pci_set_master(pdev);
+		pci_save_state(pdev);
+	}
 
 	bp->pm_cap = pci_find_capability(pdev, PCI_CAP_ID_PM);
 	if (bp->pm_cap == 0) {
@@ -7280,13 +8262,9 @@ static int __devinit bnx2x_init_board(struct pci_dev *pdev,
 		goto err_out_release;
 	}
 
-	bp->dev = dev;
-	bp->pdev = pdev;
-
-	INIT_WORK(&bp->reset_task, bnx2x_reset_task);
-	INIT_WORK(&bp->sp_task, bnx2x_sp_task);
-
-	dev->base_addr = pci_resource_start(pdev, 0);
+	dev->mem_start = pci_resource_start(pdev, 0);
+	dev->base_addr = dev->mem_start;
+	dev->mem_end = pci_resource_end(pdev, 0);
 
 	dev->irq = pdev->irq;
 
@@ -7298,8 +8276,9 @@ static int __devinit bnx2x_init_board(struct pci_dev *pdev,
 		goto err_out_release;
 	}
 
-	bp->doorbells = ioremap_nocache(pci_resource_start(pdev , 2),
-					pci_resource_len(pdev, 2));
+	bp->doorbells = ioremap_nocache(pci_resource_start(pdev, 2),
+					min_t(u64, BNX2X_DB_SIZE,
+					      pci_resource_len(pdev, 2)));
 	if (!bp->doorbells) {
 		printk(KERN_ERR PFX "Cannot map doorbell space, aborting\n");
 		rc = -ENOMEM;
@@ -7308,47 +8287,43 @@ static int __devinit bnx2x_init_board(struct pci_dev *pdev,
 
 	bnx2x_set_power_state(bp, PCI_D0);
 
-	bnx2x_get_hwinfo(bp);
-
-
-	if (nomcp) {
-		printk(KERN_ERR PFX "MCP disabled, will only"
-		       " init first device\n");
-		onefunc = 1;
-	}
-
-	if (onefunc && bp->port) {
-		printk(KERN_ERR PFX "Second device disabled, exiting\n");
-		rc = -ENODEV;
-		goto err_out_unmap;
-	}
-
-	bp->tx_ring_size = MAX_TX_AVAIL;
-	bp->rx_ring_size = MAX_RX_AVAIL;
-
-	bp->rx_csum = 1;
-
-	bp->rx_offset = 0;
-
-	bp->tx_quick_cons_trip_int = 0xff;
-	bp->tx_quick_cons_trip = 0xff;
-	bp->tx_ticks_int = 50;
-	bp->tx_ticks = 50;
+	/* clean indirect addresses */
+	pci_write_config_dword(bp->pdev, PCICFG_GRC_ADDRESS,
+			       PCICFG_VENDOR_ID_OFFSET);
+	REG_WR(bp, PXP2_REG_PGL_ADDR_88_F0 + BP_PORT(bp)*16, 0);
+	REG_WR(bp, PXP2_REG_PGL_ADDR_8C_F0 + BP_PORT(bp)*16, 0);
+	REG_WR(bp, PXP2_REG_PGL_ADDR_90_F0 + BP_PORT(bp)*16, 0);
+	REG_WR(bp, PXP2_REG_PGL_ADDR_94_F0 + BP_PORT(bp)*16, 0);
 
-	bp->rx_quick_cons_trip_int = 0xff;
-	bp->rx_quick_cons_trip = 0xff;
-	bp->rx_ticks_int = 25;
-	bp->rx_ticks = 25;
+	dev->hard_start_xmit = bnx2x_start_xmit;
+	dev->watchdog_timeo = TX_TIMEOUT;
 
-	bp->stats_ticks = 1000000 & 0xffff00;
+	dev->ethtool_ops = &bnx2x_ethtool_ops;
+	dev->open = bnx2x_open;
+	dev->stop = bnx2x_close;
+	dev->set_multicast_list = bnx2x_set_rx_mode;
+	dev->set_mac_address = bnx2x_change_mac_addr;
+	dev->do_ioctl = bnx2x_ioctl;
+	dev->change_mtu = bnx2x_change_mtu;
+	dev->tx_timeout = bnx2x_tx_timeout;
+#ifdef BCM_VLAN
+	dev->vlan_rx_register = bnx2x_vlan_rx_register;
+#endif
+#if defined(HAVE_POLL_CONTROLLER) || defined(CONFIG_NET_POLL_CONTROLLER)
+	dev->poll_controller = poll_bnx2x;
+#endif
+	dev->features |= NETIF_F_SG;
+	dev->features |= NETIF_F_HW_CSUM;
+	if (bp->flags & USING_DAC_FLAG)
+		dev->features |= NETIF_F_HIGHDMA;
+#ifdef BCM_VLAN
+	dev->features |= (NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX);
+#endif
+	dev->features |= (NETIF_F_TSO | NETIF_F_TSO_ECN);
 
 	bp->timer_interval = HZ;
 	bp->current_interval = (poll ? poll : HZ);
 
-	init_timer(&bp->timer);
-	bp->timer.expires = jiffies + bp->current_interval;
-	bp->timer.data = (unsigned long) bp;
-	bp->timer.function = bnx2x_timer;
 
 	return 0;
 
@@ -7357,14 +8332,14 @@ err_out_unmap:
 		iounmap(bp->regview);
 		bp->regview = NULL;
 	}
-
 	if (bp->doorbells) {
 		iounmap(bp->doorbells);
 		bp->doorbells = NULL;
 	}
 
 err_out_release:
-	pci_release_regions(pdev);
+	if (atomic_read(&pdev->enable_cnt) == 1)
+		pci_release_regions(pdev);
 
 err_out_disable:
 	pci_disable_device(pdev);
@@ -7398,7 +8373,6 @@ static int __devinit bnx2x_init_one(struct pci_dev *pdev,
 	struct net_device *dev = NULL;
 	struct bnx2x *bp;
 	int rc;
-	int port = PCI_FUNC(pdev->devfn);
 	DECLARE_MAC_BUF(mac);
 
 	if (version_printed++ == 0)
@@ -7406,78 +8380,62 @@ static int __devinit bnx2x_init_one(struct pci_dev *pdev,
 
 	/* dev zeroed in init_etherdev */
 	dev = alloc_etherdev(sizeof(*bp));
-	if (!dev)
+	if (!dev) {
+		printk(KERN_ERR PFX "Cannot allocate net device\n");
 		return -ENOMEM;
+	}
 
 	netif_carrier_off(dev);
 
 	bp = netdev_priv(dev);
 	bp->msglevel = debug;
 
-	if (port && onefunc) {
-		printk(KERN_ERR PFX "second function disabled. exiting\n");
-		free_netdev(dev);
-		return 0;
-	}
-
-	rc = bnx2x_init_board(pdev, dev);
+	rc = bnx2x_init_dev(pdev, dev);
 	if (rc < 0) {
 		free_netdev(dev);
 		return rc;
 	}
 
-	dev->hard_start_xmit = bnx2x_start_xmit;
-	dev->watchdog_timeo = TX_TIMEOUT;
-
-	dev->ethtool_ops = &bnx2x_ethtool_ops;
-	dev->open = bnx2x_open;
-	dev->stop = bnx2x_close;
-	dev->set_multicast_list = bnx2x_set_rx_mode;
-	dev->set_mac_address = bnx2x_change_mac_addr;
-	dev->do_ioctl = bnx2x_ioctl;
-	dev->change_mtu = bnx2x_change_mtu;
-	dev->tx_timeout = bnx2x_tx_timeout;
-#ifdef BCM_VLAN
-	dev->vlan_rx_register = bnx2x_vlan_rx_register;
-#endif
-#if defined(HAVE_POLL_CONTROLLER) || defined(CONFIG_NET_POLL_CONTROLLER)
-	dev->poll_controller = poll_bnx2x;
-#endif
-	dev->features |= NETIF_F_SG;
-	if (bp->flags & USING_DAC_FLAG)
-		dev->features |= NETIF_F_HIGHDMA;
-	dev->features |= NETIF_F_IP_CSUM;
-#ifdef BCM_VLAN
-	dev->features |= NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
-#endif
-	dev->features |= NETIF_F_TSO | NETIF_F_TSO_ECN;
-
 	rc = register_netdev(dev);
 	if (rc) {
 		dev_err(&pdev->dev, "Cannot register net device\n");
-		if (bp->regview)
-			iounmap(bp->regview);
-		if (bp->doorbells)
-			iounmap(bp->doorbells);
-		pci_release_regions(pdev);
-		pci_disable_device(pdev);
-		pci_set_drvdata(pdev, NULL);
-		free_netdev(dev);
-		return rc;
+		goto init_one_exit;
 	}
 
 	pci_set_drvdata(pdev, dev);
 
-	bp->name = board_info[ent->driver_data].name;
+	rc = bnx2x_init_bp(bp);
+	if (rc) {
+		unregister_netdev(dev);
+		goto init_one_exit;
+	}
+
+	bp->common.name = board_info[ent->driver_data].name;
 	printk(KERN_INFO "%s: %s (%c%d) PCI-E x%d %s found at mem %lx,"
-	       " IRQ %d, ", dev->name, bp->name,
-	       ((CHIP_ID(bp) & 0xf000) >> 12) + 'A',
-	       ((CHIP_ID(bp) & 0x0ff0) >> 4),
+	       " IRQ %d, ", dev->name, bp->common.name,
+	       (CHIP_REV(bp) >> 12) + 'A', (CHIP_METAL(bp) >> 4),
 	       bnx2x_get_pcie_width(bp),
 	       (bnx2x_get_pcie_speed(bp) == 2) ? "5GHz (Gen2)" : "2.5GHz",
 	       dev->base_addr, bp->pdev->irq);
 	printk(KERN_CONT "node addr %s\n", print_mac(mac, dev->dev_addr));
 	return 0;
+
+init_one_exit:
+	if (bp->regview)
+		iounmap(bp->regview);
+
+	if (bp->doorbells)
+		iounmap(bp->doorbells);
+
+	free_netdev(dev);
+
+	if (atomic_read(&pdev->enable_cnt) == 1)
+		pci_release_regions(pdev);
+
+	pci_disable_device(pdev);
+	pci_set_drvdata(pdev, NULL);
+
+	return rc;
 }
 
 static void __devexit bnx2x_remove_one(struct pci_dev *pdev)
@@ -7486,11 +8444,9 @@ static void __devexit bnx2x_remove_one(struct pci_dev *pdev)
 	struct bnx2x *bp;
 
 	if (!dev) {
-		/* we get here if init_one() fails */
 		printk(KERN_ERR PFX "BAD net device from bnx2x_init_one\n");
 		return;
 	}
-
 	bp = netdev_priv(dev);
 
 	unregister_netdev(dev);
@@ -7502,7 +8458,10 @@ static void __devexit bnx2x_remove_one(struct pci_dev *pdev)
 		iounmap(bp->doorbells);
 
 	free_netdev(dev);
-	pci_release_regions(pdev);
+
+	if (atomic_read(&pdev->enable_cnt) == 1)
+		pci_release_regions(pdev);
+
 	pci_disable_device(pdev);
 	pci_set_drvdata(pdev, NULL);
 }
@@ -7512,21 +8471,29 @@ static int bnx2x_suspend(struct pci_dev *pdev, pm_message_t state)
 	struct net_device *dev = pci_get_drvdata(pdev);
 	struct bnx2x *bp;
 
-	if (!dev)
-		return 0;
+	if (!dev) {
+		printk(KERN_ERR PFX "BAD net device from bnx2x_init_one\n");
+		return -ENODEV;
+	}
+	bp = netdev_priv(dev);
 
-	if (!netif_running(dev))
-		return 0;
+	rtnl_lock();
 
-	bp = netdev_priv(dev);
+	pci_save_state(pdev);
 
-	bnx2x_nic_unload(bp, 0);
+	if (!netif_running(dev)) {
+		rtnl_unlock();
+		return 0;
+	}
 
 	netif_device_detach(dev);
 
-	pci_save_state(pdev);
+	bnx2x_nic_unload(bp, UNLOAD_NORMAL);
+
 	bnx2x_set_power_state(bp, pci_choose_state(pdev, state));
 
+	rtnl_unlock();
+
 	return 0;
 }
 
@@ -7540,21 +8507,25 @@ static int bnx2x_resume(struct pci_dev *pdev)
 		printk(KERN_ERR PFX "BAD net device from bnx2x_init_one\n");
 		return -ENODEV;
 	}
-
-	if (!netif_running(dev))
-		return 0;
-
 	bp = netdev_priv(dev);
 
+	rtnl_lock();
+
 	pci_restore_state(pdev);
+
+	if (!netif_running(dev)) {
+		rtnl_unlock();
+		return 0;
+	}
+
 	bnx2x_set_power_state(bp, PCI_D0);
 	netif_device_attach(dev);
 
-	rc = bnx2x_nic_load(bp, 0);
-	if (rc)
-		return rc;
+	rc = bnx2x_nic_load(bp, LOAD_NORMAL);
 
-	return 0;
+	rtnl_unlock();
+
+	return rc;
 }
 
 static struct pci_driver bnx2x_pci_driver = {
diff --git a/drivers/net/bnx2x_reg.h b/drivers/net/bnx2x_reg.h
index 8707c0d..15c9a99 100644
--- a/drivers/net/bnx2x_reg.h
+++ b/drivers/net/bnx2x_reg.h
@@ -38,21 +38,19 @@
    was asserted. */
 #define BRB1_REG_NUM_OF_FULL_CYCLES_0				 0x600c8
 #define BRB1_REG_NUM_OF_FULL_CYCLES_1				 0x600cc
-#define BRB1_REG_NUM_OF_FULL_CYCLES_2				 0x600d0
-#define BRB1_REG_NUM_OF_FULL_CYCLES_3				 0x600d4
 #define BRB1_REG_NUM_OF_FULL_CYCLES_4				 0x600d8
 /* [ST 32] The number of cycles that the pause signal towards MAC #0 was
    asserted. */
 #define BRB1_REG_NUM_OF_PAUSE_CYCLES_0				 0x600b8
 #define BRB1_REG_NUM_OF_PAUSE_CYCLES_1				 0x600bc
-#define BRB1_REG_NUM_OF_PAUSE_CYCLES_2				 0x600c0
-#define BRB1_REG_NUM_OF_PAUSE_CYCLES_3				 0x600c4
 /* [RW 10] Write client 0: De-assert pause threshold. */
 #define BRB1_REG_PAUSE_HIGH_THRESHOLD_0 			 0x60078
 #define BRB1_REG_PAUSE_HIGH_THRESHOLD_1 			 0x6007c
 /* [RW 10] Write client 0: Assert pause threshold. */
 #define BRB1_REG_PAUSE_LOW_THRESHOLD_0				 0x60068
 #define BRB1_REG_PAUSE_LOW_THRESHOLD_1				 0x6006c
+/* [R 24] The number of full blocks occpied by port. */
+#define BRB1_REG_PORT_NUM_OCC_BLOCKS_0				 0x60094
 /* [RW 1] Reset the design by software. */
 #define BRB1_REG_SOFT_RESET					 0x600dc
 /* [R 5] Used to read the value of the XX protection CAM occupancy counter. */
@@ -513,7 +511,6 @@
 /* [RW 15] Interrupt table Read and write access to it is not possible in
    the middle of the work */
 #define CSEM_REG_INT_TABLE					 0x200400
-#define CSEM_REG_INT_TABLE_SIZE 				 256
 /* [ST 24] Statistics register. The number of messages that entered through
    FIC0 */
 #define CSEM_REG_MSG_NUM_FIC0					 0x200000
@@ -587,13 +584,10 @@
 #define DBG_REG_DBG_PRTY_MASK					 0xc0a8
 /* [R 1] Parity register #0 read */
 #define DBG_REG_DBG_PRTY_STS					 0xc09c
-/* [RW 2] debug only: These bits indicate the credit for PCI request type 4
-   interface; MUST be configured AFTER pci_ext_buffer_strt_addr_lsb/msb are
-   configured */
-#define DBG_REG_PCI_REQ_CREDIT					 0xc120
 /* [RW 32] Commands memory. The address to command X; row Y is to calculated
    as 14*X+Y. */
 #define DMAE_REG_CMD_MEM					 0x102400
+#define DMAE_REG_CMD_MEM_SIZE					 224
 /* [RW 1] If 0 - the CRC-16c initial value is all zeroes; if 1 - the CRC-16c
    initial value is all ones. */
 #define DMAE_REG_CRC16C_INIT					 0x10201c
@@ -1626,7 +1620,7 @@
    is reset to 0x080; giving a default blink period of approximately 8Hz. */
 #define NIG_REG_LED_CONTROL_BLINK_RATE_P0			 0x10310
 /* [RW 1] Port0: If set along with the
-   nig_registers_led_control_override_traffic_p0.led_control_override_traffic_p0
+ ~nig_registers_led_control_override_traffic_p0.led_control_override_traffic_p0
    bit and ~nig_registers_led_control_traffic_p0.led_control_traffic_p0 LED
    bit; the Traffic LED will blink with the blink rate specified in
    ~nig_registers_led_control_blink_rate_p0.led_control_blink_rate_p0 and
@@ -1733,9 +1727,21 @@
 /* [R 32] Rx statistics : In user packets discarded due to BRB backpressure
    for port0 */
 #define NIG_REG_STAT0_BRB_DISCARD				 0x105f0
+/* [WB_R 36] Tx statistics : Number of packets from emac0 or bmac0 that
+   between 1024 and 1522 bytes for port0 */
+#define NIG_REG_STAT0_EGRESS_MAC_PKT0				 0x10750
+/* [WB_R 36] Tx statistics : Number of packets from emac0 or bmac0 that
+   between 1523 bytes and above for port0 */
+#define NIG_REG_STAT0_EGRESS_MAC_PKT1				 0x10760
 /* [R 32] Rx statistics : In user packets discarded due to BRB backpressure
    for port1 */
 #define NIG_REG_STAT1_BRB_DISCARD				 0x10628
+/* [WB_R 36] Tx statistics : Number of packets from emac1 or bmac1 that
+   between 1024 and 1522 bytes for port1 */
+#define NIG_REG_STAT1_EGRESS_MAC_PKT0				 0x107a0
+/* [WB_R 36] Tx statistics : Number of packets from emac1 or bmac1 that
+   between 1523 bytes and above for port1 */
+#define NIG_REG_STAT1_EGRESS_MAC_PKT1				 0x107b0
 /* [WB_R 64] Rx statistics : User octets received for LP */
 #define NIG_REG_STAT2_BRB_OCTET 				 0x107e0
 #define NIG_REG_STATUS_INTERRUPT_PORT0				 0x10328
@@ -1849,7 +1855,6 @@
 #define PRS_REG_CFC_SEARCH_INITIAL_CREDIT			 0x4011c
 /* [RW 24] CID for port 0 if no match */
 #define PRS_REG_CID_PORT_0					 0x400fc
-#define PRS_REG_CID_PORT_1					 0x40100
 /* [RW 32] The CM header for flush message where 'load existed' bit in CFC
    load response is reset and packet type is 0. Used in packet start message
    to TCM. */
@@ -1957,6 +1962,10 @@
 #define PXP2_REG_HST_DATA_FIFO_STATUS				 0x12047c
 /* [R 7] Debug only: Number of used entries in the header FIFO */
 #define PXP2_REG_HST_HEADER_FIFO_STATUS 			 0x120478
+#define PXP2_REG_PGL_ADDR_88_F0 				 0x120534
+#define PXP2_REG_PGL_ADDR_8C_F0 				 0x120538
+#define PXP2_REG_PGL_ADDR_90_F0 				 0x12053c
+#define PXP2_REG_PGL_ADDR_94_F0 				 0x120540
 #define PXP2_REG_PGL_CONTROL0					 0x120490
 #define PXP2_REG_PGL_CONTROL1					 0x120514
 /* [RW 32] third dword data of expansion rom request. this register is
@@ -2060,12 +2069,13 @@
 #define PXP2_REG_PSWRQ_SRC0_L2P 				 0x120054
 #define PXP2_REG_PSWRQ_TM0_L2P					 0x12001c
 #define PXP2_REG_PSWRQ_TSDM0_L2P				 0x1200e0
-/* [RW 25] Interrupt mask register #0 read/write */
-#define PXP2_REG_PXP2_INT_MASK					 0x120578
-/* [R 25] Interrupt register #0 read */
-#define PXP2_REG_PXP2_INT_STS					 0x12056c
-/* [RC 25] Interrupt register #0 read clear */
-#define PXP2_REG_PXP2_INT_STS_CLR				 0x120570
+/* [RW 32] Interrupt mask register #0 read/write */
+#define PXP2_REG_PXP2_INT_MASK_0				 0x120578
+/* [R 32] Interrupt register #0 read */
+#define PXP2_REG_PXP2_INT_STS_0 				 0x12056c
+#define PXP2_REG_PXP2_INT_STS_1 				 0x120608
+/* [RC 32] Interrupt register #0 read clear */
+#define PXP2_REG_PXP2_INT_STS_CLR_0				 0x120570
 /* [RW 32] Parity mask register #0 read/write */
 #define PXP2_REG_PXP2_PRTY_MASK_0				 0x120588
 #define PXP2_REG_PXP2_PRTY_MASK_1				 0x120598
@@ -2811,22 +2821,6 @@
 #define QM_REG_QVOQIDX_97					 0x16e490
 #define QM_REG_QVOQIDX_98					 0x16e494
 #define QM_REG_QVOQIDX_99					 0x16e498
-/* [R 24] Remaining pause timeout for queues 15-0 */
-#define QM_REG_REMAINPAUSETM0					 0x168418
-/* [R 24] Remaining pause timeout for queues 31-16 */
-#define QM_REG_REMAINPAUSETM1					 0x16841c
-/* [R 24] Remaining pause timeout for queues 47-32 */
-#define QM_REG_REMAINPAUSETM2					 0x16e69c
-/* [R 24] Remaining pause timeout for queues 63-48 */
-#define QM_REG_REMAINPAUSETM3					 0x16e6a0
-/* [R 24] Remaining pause timeout for queues 79-64 */
-#define QM_REG_REMAINPAUSETM4					 0x16e6a4
-/* [R 24] Remaining pause timeout for queues 95-80 */
-#define QM_REG_REMAINPAUSETM5					 0x16e6a8
-/* [R 24] Remaining pause timeout for queues 111-96 */
-#define QM_REG_REMAINPAUSETM6					 0x16e6ac
-/* [R 24] Remaining pause timeout for queues 127-112 */
-#define QM_REG_REMAINPAUSETM7					 0x16e6b0
 /* [RW 1] Initialization bit command */
 #define QM_REG_SOFT_RESET					 0x168428
 /* [RW 8] The credit cost per every task in the QM. A value per each VOQ */
@@ -3826,7 +3820,6 @@
 /* [RW 15] Interrupt table Read and write access to it is not possible in
    the middle of the work */
 #define TSEM_REG_INT_TABLE					 0x180400
-#define TSEM_REG_INT_TABLE_SIZE 				 256
 /* [ST 24] Statistics register. The number of messages that entered through
    FIC0 */
 #define TSEM_REG_MSG_NUM_FIC0					 0x180000
@@ -4283,7 +4276,6 @@
 /* [RW 15] Interrupt table Read and write access to it is not possible in
    the middle of the work */
 #define USEM_REG_INT_TABLE					 0x300400
-#define USEM_REG_INT_TABLE_SIZE 				 256
 /* [ST 24] Statistics register. The number of messages that entered through
    FIC0 */
 #define USEM_REG_MSG_NUM_FIC0					 0x300000
@@ -4802,7 +4794,6 @@
 /* [RW 15] Interrupt table Read and write access to it is not possible in
    the middle of the work */
 #define XSEM_REG_INT_TABLE					 0x280400
-#define XSEM_REG_INT_TABLE_SIZE 				 256
 /* [ST 24] Statistics register. The number of messages that entered through
    FIC0 */
 #define XSEM_REG_MSG_NUM_FIC0					 0x280000
@@ -4930,10 +4921,7 @@
 #define EMAC_MDIO_MODE_CLOCK_CNT				 (0x3fL<<16)
 #define EMAC_MDIO_MODE_CLOCK_CNT_BITSHIFT			 16
 #define EMAC_MODE_25G_MODE					 (1L<<5)
-#define EMAC_MODE_ACPI_RCVD					 (1L<<20)
 #define EMAC_MODE_HALF_DUPLEX					 (1L<<1)
-#define EMAC_MODE_MPKT						 (1L<<18)
-#define EMAC_MODE_MPKT_RCVD					 (1L<<19)
 #define EMAC_MODE_PORT_GMII					 (2L<<2)
 #define EMAC_MODE_PORT_MII					 (1L<<2)
 #define EMAC_MODE_PORT_MII_10M					 (3L<<2)
diff --git a/include/linux/pci_ids.h b/include/linux/pci_ids.h
index caa0005..e74b14a 100644
--- a/include/linux/pci_ids.h
+++ b/include/linux/pci_ids.h
@@ -1949,6 +1949,8 @@
 #define PCI_DEVICE_ID_NX2_5708		0x164c
 #define PCI_DEVICE_ID_TIGON3_5702FE	0x164d
 #define PCI_DEVICE_ID_NX2_57710		0x164e
+#define PCI_DEVICE_ID_NX2_57711		0x164f
+#define PCI_DEVICE_ID_NX2_57711E	0x1650
 #define PCI_DEVICE_ID_TIGON3_5705	0x1653
 #define PCI_DEVICE_ID_TIGON3_5705_2	0x1654
 #define PCI_DEVICE_ID_TIGON3_5720	0x1658
-- 
1.5.3.2




