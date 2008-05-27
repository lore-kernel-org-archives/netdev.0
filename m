From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH net-next 4/12]bnx2x: Add support for BCM57711 HW
Date: Tue, 27 May 2008 10:17:23 -0400
Message-ID: <1211897844.6967.77.camel@ubuntu804desktop.localdomain>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Eliezer Tamir" <eliezert@broadcom.com>
To: netdev <netdev@vger.kernel.org>, jeff@garzik.org,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4932 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756223AbYE0ORx convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 May 2008 10:17:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

bnx2x: Add support for BCM57711 HW

=EF=BB=BFSigned-off-by: Eliezer Tamir <eliezert@broadcom.com>
Signed-off-by: Eilong Greenstein <eilong@broadcom.com>
---
 drivers/net/Kconfig         |    1 +
 drivers/net/bnx2x.h         |  775 ++++++----
 drivers/net/bnx2x_fw_defs.h |  471 ++++--
 drivers/net/bnx2x_hsi.h     |  708 ++++++---
 drivers/net/bnx2x_link.c    |   11 +-
 drivers/net/bnx2x_main.c    | 3645 +++++++++++++++++++++++++++--------=
--------
 drivers/net/bnx2x_reg.h     |   27 +-
 include/linux/pci_ids.h     |    2 +
 8 files changed, 3550 insertions(+), 2090 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 9f6cc8a..edd2e39 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -2574,6 +2574,7 @@ config BNX2X
 	tristate "Broadcom NetXtremeII 10Gb support"
 	depends on PCI
 	select ZLIB_INFLATE
+	select LIBCRC32C
 	help
 	  This driver supports Broadcom NetXtremeII 10 gigabit Ethernet cards=
=2E
 	  To compile this driver as a module, choose M here: the module
diff --git a/drivers/net/bnx2x.h b/drivers/net/bnx2x.h
index fc48219..8d7b2f4 100644
--- a/drivers/net/bnx2x.h
+++ b/drivers/net/bnx2x.h
@@ -15,37 +15,38 @@
=20
 /* error/debug prints */
=20
-#define DRV_MODULE_NAME 	"bnx2x"
-#define PFX DRV_MODULE_NAME     ": "
+#define DRV_MODULE_NAME		"bnx2x"
+#define PFX DRV_MODULE_NAME	": "
=20
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
=20
-#define DP_LEVEL			KERN_NOTICE     /* was: KERN_DEBUG */
+#define DP_LEVEL			KERN_NOTICE	/* was: KERN_DEBUG */
=20
 /* regular debug print */
 #define DP(__mask, __fmt, __args...) do { \
 	if (bp->msglevel & (__mask)) \
-		printk(DP_LEVEL "[%s:%d(%s)]" __fmt, __FUNCTION__, \
-		__LINE__, bp->dev?(bp->dev->name):"?", ##__args); \
+		printk(DP_LEVEL "[%s:%d(%s)]" __fmt, __func__, __LINE__, \
+			bp->dev?(bp->dev->name):"?", ##__args); \
 	} while (0)
=20
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
=20
-/* for logging (never masked) */
-#define BNX2X_LOG(__fmt, __args...) do { \
-	printk(KERN_NOTICE "[%s:%d(%s)]" __fmt, __FUNCTION__, \
-		__LINE__, bp->dev?(bp->dev->name):"?", ##__args); \
+/* for errors (never masked) */
+#define BNX2X_ERR(__fmt, __args...) do { \
+	printk(KERN_ERR "[%s:%d(%s)]" __fmt, __func__, __LINE__, \
+		bp->dev?(bp->dev->name):"?", ##__args); \
 	} while (0)
=20
 /* before we have a dev->name use dev_info() */
@@ -59,7 +60,7 @@
 #define bnx2x_panic() do { \
 		bp->panic =3D 1; \
 		BNX2X_ERR("driver assert\n"); \
-		bnx2x_disable_int(bp); \
+		bnx2x_int_disable(bp); \
 		bnx2x_panic_dump(bp); \
 	} while (0)
 #else
@@ -70,24 +71,29 @@
 #endif
=20
=20
-#define U64_LO(x)       		(((u64)x) & 0xffffffff)
-#define U64_HI(x)       		(((u64)x) >> 32)
-#define HILO_U64(hi, lo)		(((u64)hi << 32) + lo)
+#ifdef NETIF_F_HW_VLAN_TX
+#define BCM_VLAN			1
+#endif
+
=20
+#define U64_LO(x)			(u32)(((u64)(x)) & 0xffffffff)
+#define U64_HI(x)			(u32)(((u64)(x)) >> 32)
+#define HILO_U64(hi, lo)		((((u64)(hi)) << 32) + (lo))
=20
-#define REG_ADDR(bp, offset)    	(bp->regview + offset)
=20
-#define REG_RD(bp, offset)      	readl(REG_ADDR(bp, offset))
-#define REG_RD8(bp, offset)     	readb(REG_ADDR(bp, offset))
-#define REG_RD64(bp, offset)    	readq(REG_ADDR(bp, offset))
+#define REG_ADDR(bp, offset)		(bp->regview + offset)
=20
-#define REG_WR(bp, offset, val) 	writel((u32)val, REG_ADDR(bp, offset)=
)
+#define REG_RD(bp, offset)		readl(REG_ADDR(bp, offset))
+#define REG_RD8(bp, offset)		readb(REG_ADDR(bp, offset))
+#define REG_RD64(bp, offset)		readq(REG_ADDR(bp, offset))
+
+#define REG_WR(bp, offset, val)		writel((u32)val, REG_ADDR(bp, offset)=
)
 #define REG_WR8(bp, offset, val)	writeb((u8)val, REG_ADDR(bp, offset))
-#define REG_WR16(bp, offset, val)       writew((u16)val, REG_ADDR(bp, =
offset))
-#define REG_WR32(bp, offset, val)       REG_WR(bp, offset, val)
+#define REG_WR16(bp, offset, val)	writew((u16)val, REG_ADDR(bp, offset=
))
+#define REG_WR32(bp, offset, val)	REG_WR(bp, offset, val)
=20
-#define REG_RD_IND(bp, offset)  	bnx2x_reg_rd_ind(bp, offset)
-#define REG_WR_IND(bp, offset, val)     bnx2x_reg_wr_ind(bp, offset, v=
al)
+#define REG_RD_IND(bp, offset)		bnx2x_reg_rd_ind(bp, offset)
+#define REG_WR_IND(bp, offset, val)	bnx2x_reg_wr_ind(bp, offset, val)
=20
 #define REG_RD_DMAE(bp, offset, valp, len32) \
 	do { \
@@ -95,28 +101,28 @@
 		memcpy(valp, bnx2x_sp(bp, wb_data[0]), len32 * 4); \
 	} while (0)
=20
-#define REG_WR_DMAE(bp, offset, val, len32) \
+#define REG_WR_DMAE(bp, offset, valp, len32) \
 	do { \
-		memcpy(bnx2x_sp(bp, wb_data[0]), val, len32 * 4); \
+		memcpy(bnx2x_sp(bp, wb_data[0]), valp, len32 * 4); \
 		bnx2x_write_dmae(bp, bnx2x_sp_mapping(bp, wb_data), \
 				 offset, len32); \
 	} while (0)
=20
-#define SHMEM_RD(bp, type) \
-	REG_RD(bp, bp->shmem_base + offsetof(struct shmem_region, type))
-#define SHMEM_WR(bp, type, val) \
-	REG_WR(bp, bp->shmem_base + offsetof(struct shmem_region, type), val)
+#define SHMEM_ADDR(bp, field)		(bp->common.shmem_base + \
+					 offsetof(struct shmem_region, field))
+#define SHMEM_RD(bp, field)		REG_RD(bp, SHMEM_ADDR(bp, field))
+#define SHMEM_WR(bp, field, val)	REG_WR(bp, SHMEM_ADDR(bp, field), val=
)
=20
 #define NIG_WR(reg, val)	REG_WR(bp, reg, val)
-#define EMAC_WR(reg, val)       REG_WR(bp, emac_base + reg, val)
-#define BMAC_WR(reg, val)       REG_WR(bp, GRCBASE_NIG + bmac_addr + r=
eg, val)
+#define EMAC_WR(reg, val)	REG_WR(bp, emac_base + reg, val)
+#define BMAC_WR(reg, val)	REG_WR(bp, GRCBASE_NIG + bmac_addr + reg, va=
l)
=20
=20
-#define for_each_queue(bp, var) for (var =3D 0; var < bp->num_queues; =
var++)
+#define for_each_queue(bp, var)	for (var =3D 0; var < bp->num_queues; =
var++)
=20
 #define for_each_nondefault_queue(bp, var) \
 				for (var =3D 1; var < bp->num_queues; var++)
-#define is_multi(bp)    	(bp->num_queues > 1)
+#define is_multi(bp)		(bp->num_queues > 1)
=20
=20
 struct regp {
@@ -357,105 +363,73 @@ struct bnx2x_eth_stats {
 	u32 number_of_bugs_found_in_stats_spec; /* just kidding */
 };
=20
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
 #define bnx2x_sp_check(bp, var) ((bp->slowpath) ? (&bp->slowpath->var)=
 : NULL)
-#define bnx2x_sp_mapping(bp, var) \
-		(bp->slowpath_mapping + offsetof(struct bnx2x_slowpath, var))
-
-
 struct sw_rx_bd {
-	struct sk_buff  *skb;
+	struct sk_buff	*skb;
 	DECLARE_PCI_UNMAP_ADDR(mapping)
 };
=20
 struct sw_tx_bd {
-	struct sk_buff  *skb;
-	u16     	first_bd;
+	struct sk_buff	*skb;
+	u16		first_bd;
 };
=20
 struct bnx2x_fastpath {
=20
-	struct napi_struct      napi;
+	struct napi_struct	napi;
=20
 	struct host_status_block *status_blk;
-	dma_addr_t      	status_blk_mapping;
+	dma_addr_t		status_blk_mapping;
=20
-	struct eth_tx_db_data   *hw_tx_prods;
-	dma_addr_t      	tx_prods_mapping;
+	struct eth_tx_db_data	*hw_tx_prods;
+	dma_addr_t		tx_prods_mapping;
=20
-	struct sw_tx_bd 	*tx_buf_ring;
+	struct sw_tx_bd		*tx_buf_ring;
=20
 	struct eth_tx_bd	*tx_desc_ring;
-	dma_addr_t      	tx_desc_mapping;
+	dma_addr_t		tx_desc_mapping;
=20
 	struct sw_rx_bd 	*rx_buf_ring;
=20
 	struct eth_rx_bd	*rx_desc_ring;
-	dma_addr_t      	rx_desc_mapping;
+	dma_addr_t		rx_desc_mapping;
=20
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
=20
@@ -463,104 +437,48 @@ struct bnx2x_fastpath {
 };
=20
 #define bnx2x_fp(bp, nr, var)   	(bp->fp[nr].var)
+/* This is needed for determening of last_max */
+#define SUB_S16(a, b)			(s16)((s16)(a) - (s16)(b))
=20
+/* stuff added to make the code fit 80Col */
=20
-/* attn group wiring */
-#define MAX_DYNAMIC_ATTN_GRPS   	8
-
-struct attn_route {
-	u32     sig[4];
-};
-
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
-
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
-
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
-
-	/* slow path ring */
-	struct eth_spe  	*spq;
-	dma_addr_t      	spq_mapping;
-	u16     		spq_prod_idx;
-	struct eth_spe  	*spq_prod_bd;
-	struct eth_spe  	*spq_last_bd;
-	u16     		*dsb_sp_prod;
-	u16     		spq_left; /* serialize spq */
-	spinlock_t      	spq_lock;
+#define CQE_TYPE(cqe_fp_flags)	((cqe_fp_flags) & ETH_FAST_PATH_RX_CQE_=
TYPE)
=20
-	/* Flag for marking that there is either
-	 * STAT_QUERY or CFC DELETE ramrod pending
-	 */
-	u8      		stat_pending;
+#define ETH_RX_ERROR_FALGS	(ETH_FAST_PATH_RX_CQE_PHY_DECODE_ERR_FLG | =
\
+				 ETH_FAST_PATH_RX_CQE_IP_BAD_XSUM_FLG | \
+				 ETH_FAST_PATH_RX_CQE_L4_BAD_XSUM_FLG)
=20
-	/* End of fields used in the performance code paths */
=20
-	int     		panic;
-	int     		msglevel;
+#define U_SB_ETH_RX_CQ_INDEX		HC_INDEX_U_ETH_RX_CQ_CONS
+#define U_SB_ETH_RX_BD_INDEX		HC_INDEX_U_ETH_RX_BD_CONS
+#define C_SB_ETH_TX_CQ_INDEX		HC_INDEX_C_ETH_TX_CQ_CONS
=20
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
=20
-	int     		port;
+#define BNX2X_RX_SB_BD_INDEX \
+	(&fp->status_blk->u_status_block.index_values[U_SB_ETH_RX_BD_INDEX])
=20
-	int     		pm_cap;
-	int     		pcie_cap;
+#define BNX2X_RX_SB_INDEX_NUM \
+		(((U_SB_ETH_RX_CQ_INDEX << \
+		   USTORM_ETH_ST_CONTEXT_CONFIG_CQE_SB_INDEX_NUMBER_SHIFT) & \
+		  USTORM_ETH_ST_CONTEXT_CONFIG_CQE_SB_INDEX_NUMBER) | \
+		 ((U_SB_ETH_RX_BD_INDEX << \
+		   USTORM_ETH_ST_CONTEXT_CONFIG_BD_SB_INDEX_NUMBER_SHIFT) & \
+		  USTORM_ETH_ST_CONTEXT_CONFIG_BD_SB_INDEX_NUMBER))
=20
-	struct work_struct	sp_task;
-	struct work_struct	reset_task;
+#define BNX2X_TX_SB_INDEX \
+	(&fp->status_blk->c_status_block.index_values[C_SB_ETH_TX_CQ_INDEX])
=20
-	struct timer_list       timer;
-	int     		timer_interval;
-	int     		current_interval;
+/* common */
=20
-	u32     		shmem_base;
+struct bnx2x_common {
=20
 	u32			chip_id;
 /* chip num:16-31, rev:12-15, metal:4-11, bond_id:0-3 */
-#define CHIP_ID(bp)			(bp->chip_id & 0xfffffff0)
+#define CHIP_ID(bp)			(bp->common.chip_id & 0xfffffff0)
=20
-#define CHIP_NUM(bp)			(bp->chip_id >> 16)
+#define CHIP_NUM(bp)			(bp->common.chip_id >> 16)
 #define CHIP_NUM_57710			0x164e
 #define CHIP_NUM_57711			0x164f
 #define CHIP_NUM_57711E			0x1650
@@ -571,7 +489,7 @@ struct bnx2x {
 					 CHIP_IS_57711E(bp))
 #define IS_E1H_OFFSET			CHIP_IS_E1H(bp)
=20
-#define CHIP_REV(bp)			(bp->chip_id & 0x0000f000)
+#define CHIP_REV(bp)			(bp->common.chip_id & 0x0000f000)
 #define CHIP_REV_Ax			0x00000000
 /* assume maximum 5 revisions */
 #define CHIP_REV_IS_SLOW(bp)		(CHIP_REV(bp) > 0x00005000)
@@ -585,86 +503,250 @@ struct bnx2x {
 #define CHIP_TIME(bp)			((CHIP_REV_IS_EMUL(bp)) ? 2000 : \
 					((CHIP_REV_IS_FPGA(bp)) ? 200 : 1))
=20
-#define CHIP_METAL(bp)			(bp->chip_id & 0x00000ff0)
-#define CHIP_BOND_ID(bp)		(bp->chip_id & 0x0000000f)
+#define CHIP_METAL(bp)			(bp->common.chip_id & 0x00000ff0)
+#define CHIP_BOND_ID(bp)		(bp->common.chip_id & 0x0000000f)
+
+	int			flash_size;
+#define NVRAM_1MB_SIZE			0x20000	/* 1M bit in bytes */
+#define NVRAM_TIMEOUT_COUNT		30000
+#define NVRAM_PAGE_SIZE			256
=20
-	u16     		fw_seq;
-	u16     		fw_drv_pulse_wr_seq;
-	u32     		fw_mb;
+	u32			shmem_base;
=20
-	u32     		hw_config;
+	u32			hw_config;
 	u32			board;
=20
-	struct link_params	link_params;
+	u32			bc_ver;
=20
-	struct link_vars	link_vars;
+	char			*name;
+};
+
+
+/* end of common */
+
+/* port */
+
+struct bnx2x_port {
+	u32			pmf;
=20
 	u32			link_config;
=20
-	u32     		supported;
+	u32			supported;
+/* link settings - missing defines */
+#define SUPPORTED_2500baseX_Full	(1 << 15)
+
+	u32			advertising;
 /* link settings - missing defines */
-#define SUPPORTED_2500baseT_Full	(1 << 15)
+#define ADVERTISED_2500baseX_Full	(1 << 15)
=20
-	u32     		phy_addr;
+	u32			phy_addr;
=20
 	/* used to synchronize phy accesses */
 	struct mutex		phy_mutex;
=20
-	u32     		phy_id;
+	u32			port_stx;
=20
+	struct nig_stats	old_nig_stats;
+};
=20
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
=20
+#define MAX_DMAE_C			6
=20
-	u32     		bc_ver;
+/* DMA memory not used in fastpath */
+struct bnx2x_slowpath {
+	union cdu_context		context[MAX_CONTEXT];
+	struct eth_stats_query		fw_stats;
+	struct mac_configuration_cmd	mac_config;
+	struct mac_configuration_cmd	mcast_config;
=20
-	int     		flash_size;
-#define NVRAM_1MB_SIZE  		0x20000 /* 1M bit in bytes */
-#define NVRAM_TIMEOUT_COUNT     	30000
-#define NVRAM_PAGE_SIZE 		256
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
+
+	u32			rx_csum;
+	u32			rx_offset;
+	u32			rx_buf_use_size;	/* useable size */
+	u32			rx_buf_size;		/* with alignment */
+#define ETH_OVREHEAD			(ETH_HLEN + 8)	/* 8 for CRC + VLAN */
+#define ETH_MIN_PACKET_SIZE		60
+#define ETH_MAX_PACKET_SIZE		1500
+#define ETH_MAX_JUMBO_PACKET_SIZE	9600
+
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
+#define IS_E1HMF(bp)			(bp->e1hmf !=3D 0)
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
+
+	struct bnx2x_common	common;
+	struct bnx2x_port	port;
+
+	u32			mf_config;
+	u16			e1hovl;
+	u8			e1hmf;
=20
 	u8			wol;
=20
-	int     		rx_ring_size;
+	int			rx_ring_size;
=20
-	u16     		tx_quick_cons_trip_int;
-	u16     		tx_quick_cons_trip;
-	u16     		tx_ticks_int;
-	u16     		tx_ticks;
+	u16			tx_quick_cons_trip_int;
+	u16			tx_quick_cons_trip;
+	u16			tx_ticks_int;
+	u16			tx_ticks;
=20
-	u16     		rx_quick_cons_trip_int;
-	u16     		rx_quick_cons_trip;
-	u16     		rx_ticks_int;
-	u16     		rx_ticks;
+	u16			rx_quick_cons_trip_int;
+	u16			rx_quick_cons_trip;
+	u16			rx_ticks_int;
+	u16			rx_ticks;
=20
-	u32     		stats_ticks;
+	u32			stats_ticks;
+	u32			lin_cnt;
=20
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
=20
-	int     		num_queues;
+	int			num_queues;
=20
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
=20
-	dma_addr_t      	def_status_blk_mapping;
+	dma_addr_t		def_status_blk_mapping;
=20
-	struct bnx2x_slowpath   *slowpath;
-	dma_addr_t      	slowpath_mapping;
+	struct bnx2x_slowpath	*slowpath;
+	dma_addr_t		slowpath_mapping;
=20
 #ifdef BCM_ISCSI
 	void    		*t1;
@@ -677,61 +759,33 @@ struct bnx2x {
 	dma_addr_t      	qm_mapping;
 #endif
=20
-	char    		*name;
+	int			dmae_ready;
+	/* used to synchronize dmae accesses */
+	struct mutex		dmae_mutex;
+	struct dmae_command	init_dmae;
=20
 	/* used to synchronize stats collecting */
-	int     		stats_state;
+	int			stats_state;
 #define STATS_STATE_DISABLE     	0
 #define STATS_STATE_ENABLE      	1
 #define STATS_STATE_STOP		2 /* stop stats on next iteration */
=20
 	/* used by dmae command loader */
 	struct dmae_command     dmae;
-	int     		executer_idx;
-
-       	int			dmae_ready;
-	/* used to synchronize dmae accesses */
-	struct mutex		dmae_mutex;
-	struct dmae_command	init_dmae;
-
-
+	int			executer_idx;
=20
 	u32     		old_brb_discard;
 	struct bmac_stats       old_bmac;
 	struct tstorm_per_client_stats old_tclient;
-	struct z_stream_s       *strm;
-	void    		*gunzip_buf;
-	dma_addr_t      	gunzip_mapping;
-	int     		gunzip_outlen;
-#define FW_BUF_SIZE     		0x8000
-
-};
-
=20
-/* DMAE command defines */
-#define DMAE_CMD_SRC_PCI		0
-#define DMAE_CMD_SRC_GRC		DMAE_COMMAND_SRC
-
-#define DMAE_CMD_DST_PCI		(1 << DMAE_COMMAND_DST_SHIFT)
-#define DMAE_CMD_DST_GRC		(2 << DMAE_COMMAND_DST_SHIFT)
+	struct z_stream_s	*strm;
+	void			*gunzip_buf;
+	dma_addr_t		gunzip_mapping;
+	int			gunzip_outlen;
+#define FW_BUF_SIZE			0x40000
=20
-#define DMAE_CMD_C_DST_PCI      	0
-#define DMAE_CMD_C_DST_GRC      	(1 << DMAE_COMMAND_C_DST_SHIFT)
-
-#define DMAE_CMD_C_ENABLE       	DMAE_COMMAND_C_TYPE_ENABLE
-
-#define DMAE_CMD_ENDIANITY_NO_SWAP      (0 << DMAE_COMMAND_ENDIANITY_S=
HIFT)
-#define DMAE_CMD_ENDIANITY_B_SWAP       (1 << DMAE_COMMAND_ENDIANITY_S=
HIFT)
-#define DMAE_CMD_ENDIANITY_DW_SWAP      (2 << DMAE_COMMAND_ENDIANITY_S=
HIFT)
-#define DMAE_CMD_ENDIANITY_B_DW_SWAP    (3 << DMAE_COMMAND_ENDIANITY_S=
HIFT)
-
-#define DMAE_CMD_PORT_0 		0
-#define DMAE_CMD_PORT_1 		DMAE_COMMAND_PORT
-
-#define DMAE_CMD_SRC_RESET      	DMAE_COMMAND_SRC_RESET
-#define DMAE_CMD_DST_RESET      	DMAE_COMMAND_DST_RESET
+};
=20
-#define DMAE_LEN32_MAX  		0x400
=20
 void bnx2x_read_dmae(struct bnx2x *bp, u32 src_addr, u32 len32);
 void bnx2x_write_dmae(struct bnx2x *bp, dma_addr_t dma_addr, u32 dst_a=
ddr,
@@ -794,26 +848,11 @@ int bnx2x_set_gpio(struct bnx2x *bp, int gpio_num=
, u32 mode);
=20
=20
 /* must be used on a CID before placing it on a HW ring */
-#define HW_CID(bp, x)   		(x | (bp->port << 23))
+#define HW_CID(bp, x)		((BP_PORT(bp) << 23) | (BP_E1HVN(bp) << 17) | x=
)
=20
 #define SP_DESC_CNT     	(BCM_PAGE_SIZE / sizeof(struct eth_spe))
 #define MAX_SP_DESC_CNT 		(SP_DESC_CNT - 1)
=20
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
=20
 #define BNX2X_BTR       		3
 #define MAX_SPQ_PENDING 		8
@@ -830,6 +869,31 @@ int bnx2x_set_gpio(struct bnx2x *bp, int gpio_num,=
 u32 mode);
 		       DPM_TRIGER_TYPE); \
 	} while (0)
=20
+static inline u32 reg_poll(struct bnx2x *bp, u32 reg, u32 expected, in=
t ms,
+			   int wait)
+{
+	u32 val;
+
+	do {
+		val =3D REG_RD(bp, reg);
+		if (val =3D=3D expected)
+			break;
+		ms -=3D wait;
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
@@ -876,22 +940,47 @@ int bnx2x_set_gpio(struct bnx2x *bp, int gpio_num=
, u32 mode);
=20
 #define pbd_tcp_flags(skb)  	(ntohl(tcp_flag_word(tcp_hdr(skb)))>>16 &=
 0xff)
=20
-/* stuff added to make the code fit 80Col */
+/* must be used on a CID before placing it on a HW ring */
=20
-#define TPA_TYPE_START  		ETH_FAST_PATH_RX_CQE_START_FLG
-#define TPA_TYPE_END    		ETH_FAST_PATH_RX_CQE_END_FLG
-#define TPA_TYPE(cqe)   	(cqe->fast_path_cqe.error_type_flags & \
-				 (TPA_TYPE_START | TPA_TYPE_END))
 #define BNX2X_RX_SUM_OK(cqe) \
 			(!(cqe->fast_path_cqe.status_flags & \
 			 (ETH_FAST_PATH_RX_CQE_IP_XSUM_NO_VALIDATION_FLG | \
 			  ETH_FAST_PATH_RX_CQE_L4_XSUM_NO_VALIDATION_FLG)))
=20
-#define BNX2X_RX_SUM_FIX(cqe) \
-			((le16_to_cpu(cqe->fast_path_cqe.pars_flags.flags) & \
-			  PARSING_FLAGS_OVER_ETHERNET_PROTOCOL) =3D=3D \
-			 (1 << PARSING_FLAGS_OVER_ETHERNET_PROTOCOL_SHIFT))
+/* CMNG constants
+   derived from lab experiments, and not from system spec calculations=
 !!! */
+#define DEF_MIN_RATE			1
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
+
+
+/* stuff added to make the code fit 80Col */
=20
+#define BNX2X_PMF_LINK_ASSERT \
+	GENERAL_ATTEN_OFFSET(LINK_SYNC_ATTENTION_BIT_FUNC_0 + BP_FUNC(bp))
=20
 #define BNX2X_MC_ASSERT_BITS \
 	(GENERAL_ATTEN_OFFSET(TSTORM_FATAL_ASSERT_ATTENTION_BIT) | \
@@ -905,12 +994,20 @@ int bnx2x_set_gpio(struct bnx2x *bp, int gpio_num=
, u32 mode);
 #define BNX2X_DOORQ_ASSERT \
 	AEU_INPUTS_ATTN_BITS_DOORBELLQ_HW_INTERRUPT
=20
+#define BNX2X_GRC_TIMEOUT	GENERAL_ATTEN_OFFSET(LATCHED_ATTN_TIMEOUT_GR=
C)
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
-#define HW_PRTY_ASSERT_SET_0    (AEU_INPUTS_ATTN_BITS_BRB_PARITY_ERROR=
 | \
+#define HW_PRTY_ASSERT_SET_0	(AEU_INPUTS_ATTN_BITS_BRB_PARITY_ERROR | =
\
 				 AEU_INPUTS_ATTN_BITS_PARSER_PARITY_ERROR | \
 				 AEU_INPUTS_ATTN_BITS_TSDM_PARITY_ERROR | \
 				 AEU_INPUTS_ATTN_BITS_SEARCHER_PARITY_ERROR |\
@@ -927,7 +1024,7 @@ int bnx2x_set_gpio(struct bnx2x *bp, int gpio_num,=
 u32 mode);
 				 AEU_INPUTS_ATTN_BITS_UPB_HW_INTERRUPT | \
 				 AEU_INPUTS_ATTN_BITS_CSDM_HW_INTERRUPT | \
 				 AEU_INPUTS_ATTN_BITS_CCM_HW_INTERRUPT)
-#define HW_PRTY_ASSERT_SET_1    (AEU_INPUTS_ATTN_BITS_PBCLIENT_PARITY_=
ERROR |\
+#define HW_PRTY_ASSERT_SET_1	(AEU_INPUTS_ATTN_BITS_PBCLIENT_PARITY_ERR=
OR |\
 				 AEU_INPUTS_ATTN_BITS_QM_PARITY_ERROR | \
 				 AEU_INPUTS_ATTN_BITS_XSDM_PARITY_ERROR | \
 				 AEU_INPUTS_ATTN_BITS_XSEMI_PARITY_ERROR | \
@@ -944,7 +1041,7 @@ int bnx2x_set_gpio(struct bnx2x *bp, int gpio_num,=
 u32 mode);
 				 AEU_INPUTS_ATTN_BITS_DMAE_HW_INTERRUPT | \
 			AEU_INPUTS_ATTN_BITS_PXPPCICLOCKCLIENT_HW_INTERRUPT |\
 				 AEU_INPUTS_ATTN_BITS_MISC_HW_INTERRUPT)
-#define HW_PRTY_ASSERT_SET_2    (AEU_INPUTS_ATTN_BITS_CSEMI_PARITY_ERR=
OR | \
+#define HW_PRTY_ASSERT_SET_2	(AEU_INPUTS_ATTN_BITS_CSEMI_PARITY_ERROR =
| \
 				 AEU_INPUTS_ATTN_BITS_PXP_PARITY_ERROR | \
 			AEU_INPUTS_ATTN_BITS_PXPPCICLOCKCLIENT_PARITY_ERROR |\
 				 AEU_INPUTS_ATTN_BITS_CFC_PARITY_ERROR | \
@@ -953,41 +1050,43 @@ int bnx2x_set_gpio(struct bnx2x *bp, int gpio_nu=
m, u32 mode);
 				 AEU_INPUTS_ATTN_BITS_MISC_PARITY_ERROR)
=20
=20
-#define ETH_RX_ERROR_FALGS      (ETH_FAST_PATH_RX_CQE_PHY_DECODE_ERR_F=
LG | \
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
-
-#define MULTI_MASK      0x7f
+		(TSTORM_ETH_FUNCTION_COMMON_CONFIG_RSS_IPV4_CAPABILITY | \
+		 TSTORM_ETH_FUNCTION_COMMON_CONFIG_RSS_IPV4_TCP_CAPABILITY | \
+		 TSTORM_ETH_FUNCTION_COMMON_CONFIG_RSS_IPV6_CAPABILITY | \
+		 TSTORM_ETH_FUNCTION_COMMON_CONFIG_RSS_IPV6_TCP_CAPABILITY | \
+		 TSTORM_ETH_FUNCTION_COMMON_CONFIG_RSS_ENABLE)
=20
+#define MULTI_MASK			0x7f
=20
-#define U_SB_ETH_RX_CQ_INDEX    	HC_INDEX_U_ETH_RX_CQ_CONS
-#define C_SB_ETH_TX_CQ_INDEX    	HC_INDEX_C_ETH_TX_CQ_CONS
-#define C_DEF_SB_SP_INDEX       	HC_INDEX_DEF_C_ETH_SLOW_PATH
=20
-#define BNX2X_RX_SB_INDEX \
-	&fp->status_blk->u_status_block.index_values[U_SB_ETH_RX_CQ_INDEX]
+#define DEF_USB_FUNC_OFF		(2 + 2*HC_USTORM_DEF_SB_NUM_INDICES)
+#define DEF_CSB_FUNC_OFF		(2 + 2*HC_CSTORM_DEF_SB_NUM_INDICES)
+#define DEF_XSB_FUNC_OFF		(2 + 2*HC_XSTORM_DEF_SB_NUM_INDICES)
+#define DEF_TSB_FUNC_OFF		(2 + 2*HC_TSTORM_DEF_SB_NUM_INDICES)
=20
-#define BNX2X_TX_SB_INDEX \
-	&fp->status_blk->c_status_block.index_values[C_SB_ETH_TX_CQ_INDEX]
+#define C_DEF_SB_SP_INDEX		HC_INDEX_DEF_C_ETH_SLOW_PATH
=20
 #define BNX2X_SP_DSB_INDEX \
-&bp->def_status_blk->c_def_status_block.index_values[C_DEF_SB_SP_INDEX=
]
+(&bp->def_status_blk->c_def_status_block.index_values[C_DEF_SB_SP_INDE=
X])
=20
=20
 #define CAM_IS_INVALID(x) \
 (x.target_table_entry.flags =3D=3D TSTORM_CAM_TARGET_TABLE_ENTRY_ACTIO=
N_TYPE)
=20
 #define CAM_INVALIDATE(x) \
-x.target_table_entry.flags =3D TSTORM_CAM_TARGET_TABLE_ENTRY_ACTION_TY=
PE
+	(x.target_table_entry.flags =3D TSTORM_CAM_TARGET_TABLE_ENTRY_ACTION_=
TYPE)
+
=20
+/* Number of u32 elements in MC hash array */
+#define MC_HASH_SIZE			8
+#define MC_HASH_OFFSET(bp, i)		(BAR_TSTRORM_INTMEM + \
+	TSTORM_APPROXIMATE_MATCH_MULTICAST_FILTERING_OFFSET(BP_FUNC(bp)) + i*=
4)
+
+
+#ifndef PXP2_REG_PXP2_INT_STS
+#define PXP2_REG_PXP2_INT_STS		PXP2_REG_PXP2_INT_STS_0
+#endif
=20
 /* MISC_REG_RESET_REG - this is here for the hsi to work don't touch *=
/
=20
diff --git a/drivers/net/bnx2x_fw_defs.h b/drivers/net/bnx2x_fw_defs.h
index 3b96890..aa08a15 100644
--- a/drivers/net/bnx2x_fw_defs.h
+++ b/drivers/net/bnx2x_fw_defs.h
@@ -8,191 +8,378 @@
  */
=20
=20
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
+#define TSTORM_APPROXIMATE_MATCH_MULTICAST_FILTERING_OFFSET(function) =
\
+	(IS_E1H_OFFSET? (0x31c0 + (function * 0x20)) : 0xffffffff)
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
=20
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
=20
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
=20
=20
 /* command values for set mac command */
-#define T_ETH_MAC_COMMAND_SET				0
-#define T_ETH_MAC_COMMAND_INVALIDATE			1
+#define T_ETH_MAC_COMMAND_SET 0
+#define T_ETH_MAC_COMMAND_INVALIDATE 1
+
+#define T_ETH_INDIRECTION_TABLE_SIZE 128
=20
-#define T_ETH_INDIRECTION_TABLE_SIZE			128
+/*The CRC32 seed, that is used for the hash(reduction) multicast addre=
ss */
+#define T_ETH_CRC32_HASH_SEED 0x00000000
=20
 /* Maximal L2 clients supported */
-#define ETH_MAX_RX_CLIENTS				(18)
+#define ETH_MAX_RX_CLIENTS_E1 19
+#define ETH_MAX_RX_CLIENTS_E1H 25
+
+/* Maximal aggregation queues supported */
+#define ETH_MAX_AGGREGATION_QUEUES_E1 (32)
+#define ETH_MAX_AGGREGATION_QUEUES_E1H (64)
+
=20
 /**
 * This file defines HSI constatnts common to all microcode flows
 */
=20
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
=20
-#define PROTOCOL_STATE_BIT_OFFSET		6
+#define PROTOCOL_STATE_BIT_OFFSET 6
=20
-#define ETH_STATE	(ETH_CONNECTION_TYPE << PROTOCOL_STATE_BIT_OFFSET)
+#define ETH_STATE (ETH_CONNECTION_TYPE << PROTOCOL_STATE_BIT_OFFSET)
+#define TOE_STATE (TOE_CONNECTION_TYPE << PROTOCOL_STATE_BIT_OFFSET)
+#define RDMA_STATE (RDMA_CONNECTION_TYPE << PROTOCOL_STATE_BIT_OFFSET)
+#define ISCSI_STATE \
+	(ISCSI_CONNECTION_TYPE << PROTOCOL_STATE_BIT_OFFSET)
+#define FCOE_STATE (FCOE_CONNECTION_TYPE << PROTOCOL_STATE_BIT_OFFSET)
=20
 /* microcode fixed page page size 4K (chains and ring segments) */
-#define MC_PAGE_SIZE						(4096)
+#define MC_PAGE_SIZE (4096)
=20
-/* Host coalescing constants */
=20
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
=20
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
=20
 /* index values - which counterto update */
=20
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
=20
-#define HC_INDEX_C_ETH_TX_CQ_CONS		1
+#define HC_INDEX_DEF_C_RDMA_EQ_CONS 0
+#define HC_INDEX_DEF_C_RDMA_NAL_PROD 1
+#define HC_INDEX_DEF_C_ETH_FW_TX_CQ_CONS 2
+#define HC_INDEX_DEF_C_ETH_SLOW_PATH 3
+#define HC_INDEX_DEF_C_ETH_RDMA_CQ_CONS 4
+#define HC_INDEX_DEF_C_ETH_ISCSI_CQ_CONS 5
=20
-#define HC_INDEX_DEF_X_SPQ_CONS 		0
+#define HC_INDEX_DEF_U_ETH_RDMA_RX_CQ_CONS 0
+#define HC_INDEX_DEF_U_ETH_ISCSI_RX_CQ_CONS 1
+#define HC_INDEX_DEF_U_ETH_RDMA_RX_BD_CONS 2
+#define HC_INDEX_DEF_U_ETH_ISCSI_RX_BD_CONS 3
=20
-#define HC_INDEX_DEF_C_ETH_FW_TX_CQ_CONS	2
-#define HC_INDEX_DEF_C_ETH_SLOW_PATH		3
=20
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
=20
 /* max number of slow path commands per port */
-#define MAX_RAMRODS_PER_PORT		(8)
+#define MAX_RAMRODS_PER_PORT (8)
=20
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
+#define TIMERS_TICK_SIZE_CHIP 1e-3
+#define TIMERS_TICK_SIZE_EMUL \
+ ((TIMERS_TICK_SIZE_CHIP)/((EMULATION_FREQUENCY_FACTOR)))
+#define TIMERS_TICK_SIZE_FPGA \
+ ((TIMERS_TICK_SIZE_CHIP)/((FPGA_FREQUENCY_FACTOR)))
+
+#define TSEMI_CLK1_RESUL_CHIP 1e-3
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
+#define XSEMI_CLK1_RESUL_CHIP 1e-3
+#define XSEMI_CLK1_RESUL_EMUL \
+ ((XSEMI_CLK1_RESUL_CHIP)/(EMULATION_FREQUENCY_FACTOR))
+#define XSEMI_CLK1_RESUL_FPGA \
+ ((XSEMI_CLK1_RESUL_CHIP)/(FPGA_FREQUENCY_FACTOR))
+
+#define XSEMI_CLK2_RESUL_CHIP 1e-6
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
=20
-#define FW_LOG_LIST_SIZE	(50)
+#define FW_LOG_LIST_SIZE (50)
+
+#define NUM_OF_PROTOCOLS 4
+#define MAX_COS_NUMBER 16
+#define MAX_T_STAT_COUNTER_ID 18
+#define MAX_X_STAT_COUNTER_ID 18
=20
-#define NUM_OF_PROTOCOLS		4
-#define MAX_COS_NUMBER			16
-#define MAX_T_STAT_COUNTER_ID	18
+#define UNKNOWN_ADDRESS 0
+#define UNICAST_ADDRESS 1
+#define MULTICAST_ADDRESS 2
+#define BROADCAST_ADDRESS 3
=20
-#define T_FAIR							1
-#define FAIR_MEM						2
-#define RS_PERIODIC_TIMEOUT_IN_SDM_TICS 25
+#define SINGLE_FUNCTION 0
+#define MULTI_FUNCTION 1
=20
-#define UNKNOWN_ADDRESS 	0
-#define UNICAST_ADDRESS 	1
-#define MULTICAST_ADDRESS	2
-#define BROADCAST_ADDRESS	3
+#define IP_V4 0
+#define IP_V6 1
=20
diff --git a/drivers/net/bnx2x_hsi.h b/drivers/net/bnx2x_hsi.h
index 96208ac..b5f486c 100644
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
=20
 #define SHARED_HW_CFG_BOARD_VER_MASK		    0xffff0000
 #define SHARED_HW_CFG_BOARD_VER_SHIFT		    16
@@ -313,6 +319,7 @@ struct shared_feat_cfg {				 /* NVRAM Offset */
=20
 	u32 config;						/* 0x450 */
 #define SHARED_FEATURE_BMC_ECHO_MODE_EN 	    0x00000001
+#define SHARED_FEATURE_MF_MODE_DISABLED 	    0x00000100
=20
 };
=20
@@ -502,20 +509,20 @@ struct port_feat_cfg {			    /* port 0: 0x454  po=
rt 1: 0x4c8 */
 };
=20
=20
-/*********************************************************************=
********
- * Device Information							     *
- *********************************************************************=
********/
-struct dev_info {						     /* size */
+/*********************************************************************=
*******
+ * Device Information							    *
+ *********************************************************************=
*******/
+struct dev_info {						    /* size */
=20
-	u32    bc_rev; /* 8 bits each: major, minor, build */	        /* 4 */
+	u32    bc_rev; /* 8 bits each: major, minor, build */	       /* 4 */
=20
-	struct shared_hw_cfg	 shared_hw_config;		       /* 40 */
+	struct shared_hw_cfg	 shared_hw_config;		      /* 40 */
=20
-	struct port_hw_cfg	 port_hw_config[PORT_MAX];      /* 400*2=3D800 */
+	struct port_hw_cfg	 port_hw_config[PORT_MAX];     /* 400*2=3D800 */
=20
-	struct shared_feat_cfg	 shared_feature_config; 	        /* 4 */
+	struct shared_feat_cfg	 shared_feature_config; 	       /* 4 */
=20
-	struct port_feat_cfg	 port_feature_config[PORT_MAX]; /* 116*2=3D232 *=
/
+	struct port_feat_cfg	 port_feature_config[PORT_MAX];/* 116*2=3D232 */
=20
 };
=20
@@ -632,7 +639,9 @@ struct drv_port_mb {
 #define LINK_STATUS_LINK_PARTNER_15GXFD_CAPABLE 	0x08000000
 #define LINK_STATUS_LINK_PARTNER_16GXFD_CAPABLE 	0x10000000
=20
-	u32 reserved[3];
+	u32 port_stx;
+
+	u32 reserved[2];
=20
 };
=20
@@ -655,6 +664,11 @@ struct drv_func_mb {
 #define DRV_MSG_CODE_GET_MANUF_KEY			0x82000000
 #define DRV_MSG_CODE_LOAD_L2B_PRAM			0x90000000
=20
+#define BIOS_MSG_CODE_LIC_CHALLENGE			0xff010000
+#define BIOS_MSG_CODE_LIC_RESPONSE			0xff020000
+#define BIOS_MSG_CODE_VIRT_MAC_PRIM			0xff030000
+#define BIOS_MSG_CODE_VIRT_MAC_ISCSI			0xff040000
+
 #define DRV_MSG_SEQ_NUMBER_MASK 			0x0000ffff
=20
 	u32 drv_mb_param;
@@ -684,6 +698,11 @@ struct drv_func_mb {
 #define FW_MSG_CODE_L2B_PRAM_X_LOAD_FAILURE		0x90230000
 #define FW_MSG_CODE_L2B_PRAM_U_LOAD_FAILURE		0x90240000
=20
+#define FW_MSG_CODE_LIC_CHALLENGE			0xff010000
+#define FW_MSG_CODE_LIC_RESPONSE			0xff020000
+#define FW_MSG_CODE_VIRT_MAC_PRIM			0xff030000
+#define FW_MSG_CODE_VIRT_MAC_ISCSI			0xff040000
+
 #define FW_MSG_SEQ_NUMBER_MASK				0x0000ffff
=20
 	u32 fw_mb_param;
@@ -709,7 +728,13 @@ struct drv_func_mb {
 	u32 iscsi_boot_signature;
 	u32 iscsi_boot_block_offset;
=20
-	u32 reserved[3];
+	u32 drv_status;
+#define DRV_STATUS_PMF					0x00000001
+
+	u32 virt_mac_upper;
+#define VIRT_MAC_SIGN_MASK				0xffff0000
+#define VIRT_MAC_SIGNATURE				0x564d0000
+	u32 virt_mac_lower;
=20
 };
=20
@@ -726,6 +751,92 @@ struct mgmtfw_state {
=20
=20
 /*********************************************************************=
*******
+ * Multi-Function configuration 					    *
+ *********************************************************************=
*******/
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
+/*********************************************************************=
*******
  * Shared Memory Region 						    *
  *********************************************************************=
*******/
 struct shmem_region {			       /*   SharedMem Offset (size) */
@@ -760,18 +871,20 @@ struct shmem_region {			       /*   SharedMem Off=
set (size) */
 	struct mgmtfw_state	mgmtfw_state;	       /* 0x4ac     (0x1b8) */
=20
 	struct drv_port_mb	port_mb[PORT_MAX];     /* 0x664 (16*2=3D0x20) */
-#if defined(b710)
-	struct drv_func_mb	func_mb[E1_FUNC_MAX];  /* 0x684 (44*2=3D0x58) */
-#else
 	struct drv_func_mb	func_mb[E1H_FUNC_MAX];
+
+#if !defined(b710)
+	struct mf_cfg		mf_cfg;
 #endif
=20
 };						       /* 0x6dc */
=20
=20
+
+
 #define BCM_5710_FW_MAJOR_VERSION			4
-#define BCM_5710_FW_MINOR_VERSION			0
-#define BCM_5710_FW_REVISION_VERSION			14
+#define BCM_5710_FW_MINOR_VERSION			6
+#define BCM_5710_FW_REVISION_VERSION			0
 #define BCM_5710_FW_COMPILE_FLAGS			1
=20
=20
@@ -810,7 +923,7 @@ struct doorbell_hdr {
 };
=20
 /*
- * doorbell message send to the chip
+ * doorbell message sent to the chip
  */
 struct doorbell {
 #if defined(__BIG_ENDIAN)
@@ -866,8 +979,10 @@ struct parsing_flags {
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
@@ -891,6 +1006,12 @@ struct parsing_flags {
 };
=20
=20
+struct regpair {
+	u32 lo;
+	u32 hi;
+};
+
+
 /*
  * dmae command structure
  */
@@ -971,72 +1092,107 @@ struct double_regpair {
=20
=20
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
=20
 /*
@@ -1107,9 +1263,9 @@ struct xstorm_eth_extra_ag_context_section {
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
@@ -1387,7 +1543,13 @@ struct timers_block_context {
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
=20
 /*
@@ -1497,11 +1659,19 @@ struct xstorm_eth_st_context {
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
@@ -1578,7 +1748,7 @@ struct eth_tx_doorbell {
 struct ustorm_def_status_block {
 	u16 index_values[HC_USTORM_DEF_SB_NUM_INDICES];
 	u16 status_block_index;
-	u8 reserved0;
+	u8 func;
 	u8 status_block_id;
 	u32 __flags;
 };
@@ -1589,7 +1759,7 @@ struct ustorm_def_status_block {
 struct cstorm_def_status_block {
 	u16 index_values[HC_CSTORM_DEF_SB_NUM_INDICES];
 	u16 status_block_index;
-	u8 reserved0;
+	u8 func;
 	u8 status_block_id;
 	u32 __flags;
 };
@@ -1600,7 +1770,7 @@ struct cstorm_def_status_block {
 struct xstorm_def_status_block {
 	u16 index_values[HC_XSTORM_DEF_SB_NUM_INDICES];
 	u16 status_block_index;
-	u8 reserved0;
+	u8 func;
 	u8 status_block_id;
 	u32 __flags;
 };
@@ -1611,7 +1781,7 @@ struct xstorm_def_status_block {
 struct tstorm_def_status_block {
 	u16 index_values[HC_TSTORM_DEF_SB_NUM_INDICES];
 	u16 status_block_index;
-	u8 reserved0;
+	u8 func;
 	u8 status_block_id;
 	u32 __flags;
 };
@@ -1634,7 +1804,7 @@ struct host_def_status_block {
 struct ustorm_status_block {
 	u16 index_values[HC_USTORM_SB_NUM_INDICES];
 	u16 status_block_index;
-	u8 reserved0;
+	u8 func;
 	u8 status_block_id;
 	u32 __flags;
 };
@@ -1645,7 +1815,7 @@ struct ustorm_status_block {
 struct cstorm_status_block {
 	u16 index_values[HC_CSTORM_SB_NUM_INDICES];
 	u16 status_block_index;
-	u8 reserved0;
+	u8 func;
 	u8 status_block_id;
 	u32 __flags;
 };
@@ -1683,20 +1853,21 @@ struct eth_dynamic_hc_config {
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
@@ -1711,11 +1882,13 @@ struct eth_fast_path_rx_cqe {
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
=20
=20
@@ -1729,6 +1902,23 @@ struct eth_halt_ramrod_data {
=20
=20
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
@@ -1758,15 +1948,20 @@ struct eth_rx_bd_next_page {
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
=20
 /*
@@ -1775,8 +1970,7 @@ struct common_ramrod_eth_rx_cqe {
 struct eth_rx_cqe_next_page {
 	u32 addr_lo;
 	u32 addr_hi;
-	u32 reserved0;
-	u32 reserved1;
+	u32 reserved[6];
 };
=20
 /*
@@ -1806,11 +2000,6 @@ struct spe_hdr {
 	u16 reserved;
 };
=20
-struct regpair {
-	u32 lo;
-	u32 hi;
-};
-
 /*
  * ethernet slow path element
  */
@@ -1821,6 +2010,7 @@ union eth_specific_data {
 	struct eth_halt_ramrod_data halt_ramrod_data;
 	struct regpair leading_cqe_addr;
 	struct regpair update_data_addr;
+	struct eth_query_ramrod_data query_ramrod_data;
 };
=20
 /*
@@ -1843,10 +2033,13 @@ struct eth_tx_db_data {
=20
=20
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
 #define TSTORM_ETH_FUNCTION_COMMON_CONFIG_RSS_IPV4_TCP_CAPABILITY (0x1=
<<1)
@@ -1859,17 +2052,32 @@ struct tstorm_eth_function_common_config {
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
+#define TSTORM_ETH_FUNCTION_COMMON_CONFIG_RSS_IPV4_TCP_CAPABILITY (0x1=
<<1)
+#define TSTORM_ETH_FUNCTION_COMMON_CONFIG_RSS_IPV4_TCP_CAPABILITY_SHIF=
T 1
+#define TSTORM_ETH_FUNCTION_COMMON_CONFIG_RSS_IPV6_CAPABILITY (0x1<<2)
+#define TSTORM_ETH_FUNCTION_COMMON_CONFIG_RSS_IPV6_CAPABILITY_SHIFT 2
+#define TSTORM_ETH_FUNCTION_COMMON_CONFIG_RSS_IPV6_TCP_CAPABILITY (0x1=
<<3)
+#define TSTORM_ETH_FUNCTION_COMMON_CONFIG_RSS_IPV6_TCP_CAPABILITY_SHIF=
T 3
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
=20
 /*
@@ -1887,7 +2095,7 @@ struct eth_update_ramrod_data {
 struct mac_configuration_hdr {
 	u8 length_6b;
 	u8 offset;
-	u16 reserved0;
+	u16 client_id;
 	u32 reserved1;
 };
=20
@@ -1944,15 +2152,55 @@ struct mac_configuration_cmd {
=20
=20
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
+ * approximate-match multicast filtering for E1H per function in Tstor=
m
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
@@ -1960,42 +2208,42 @@ struct tstorm_eth_client_config {
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
=20
@@ -2011,96 +2259,112 @@ struct tstorm_eth_mac_filter_config {
 	u32 bcast_drop_all;
 	u32 bcast_accept_all;
 	u32 strict_vlan;
-	u32 __secondary_vlan_clients;
+	u32 vlan_filter[2];
+	u32 reserved;
 };
=20
=20
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
=20
-struct fairness_vars {
-	struct fairness_per_protocol protocol_vars[NUM_OF_PROTOCOLS];
-	u32 upper_bound;
-	u32 port_rate;
-	u32 pause_mask;
-	u32 fair_threshold;
-};
=20
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
=20
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
=20
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
 };
=20
=20
-struct cos_to_protocol {
-	u8 mask[MAX_COS_NUMBER];
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
+};
+
+
+/*
+ * Per-port congestion management variables
+ */
+struct cmng_struct_per_port {
+	struct rate_shaping_vars_per_port rs_vars;
+	struct fairness_vars_per_port fair_vars;
+	struct safc_struct_per_port safc_vars;
+	struct cmng_flags_per_port flags;
 };
=20
=20
@@ -2162,6 +2426,16 @@ struct eth_stats_query {
=20
=20
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
@@ -2179,8 +2453,10 @@ struct fw_version {
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
=20
=20
@@ -2188,15 +2464,9 @@ struct fw_version {
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
@@ -2204,8 +2474,34 @@ struct pram_fw_version {
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
+ * a single rate shaping counter. can be used as protocol or vnic coun=
ter
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
=20
=20
diff --git a/drivers/net/bnx2x_link.c b/drivers/net/bnx2x_link.c
index 4da9d28..7afc069 100644
--- a/drivers/net/bnx2x_link.c
+++ b/drivers/net/bnx2x_link.c
@@ -3510,7 +3510,8 @@ u8 bnx2x_set_led(struct bnx2x *bp, u8 port, u8 mo=
de, u32 speed,
 			   LED_BLINK_RATE_VAL);
 		REG_WR(bp, NIG_REG_LED_CONTROL_BLINK_RATE_ENA_P0 +
 			   port*4, 1);
-		if (((speed =3D=3D SPEED_2500) ||
+		if (!CHIP_IS_E1H(bp) &&
+		    ((speed =3D=3D SPEED_2500) ||
 		     (speed =3D=3D SPEED_1000) ||
 		     (speed =3D=3D SPEED_100) ||
 		     (speed =3D=3D SPEED_10))) {
@@ -3691,6 +3692,14 @@ u8 bnx2x_phy_init(struct link_params *params, st=
ruct link_vars *vars)
 		vars->duplex =3D DUPLEX_FULL;
 		vars->flow_ctrl =3D FLOW_CTRL_NONE;
 		vars->link_status =3D (LINK_STATUS_LINK_UP | LINK_10GTFD);
+		/* enable on E1.5 FPGA */
+		if (CHIP_IS_E1H(bp)) {
+			vars->flow_ctrl |=3D
+				(FLOW_CTRL_TX | FLOW_CTRL_RX);
+			vars->link_status |=3D
+					(LINK_STATUS_TX_FLOW_CONTROL_ENABLED |
+					 LINK_STATUS_RX_FLOW_CONTROL_ENABLED);
+		}
=20
 		bnx2x_emac_enable(params, vars, 0);
 		bnx2x_pbf_update(params, vars->flow_ctrl, vars->line_speed);
diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 26ca847..ba46002 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -1,4 +1,4 @@
-/* bnx2x.c: Broadcom Everest network driver.
+/* bnx2x_main.c: Broadcom Everest network driver.
  *
  * Copyright (c) 2007-2008 Broadcom Corporation
  *
@@ -18,7 +18,7 @@
  * to allow getting debug info
  * (you will need to reboot afterwards)
  */
-/*#define BNX2X_STOP_ON_ERROR*/
+/* #define BNX2X_STOP_ON_ERROR */
=20
 #include <linux/module.h>
 #include <linux/moduleparam.h>
@@ -45,16 +45,17 @@
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
=20
 #include "bnx2x_reg.h"
@@ -66,13 +67,13 @@
=20
 #define DRV_MODULE_VERSION      "1.42.4"
 #define DRV_MODULE_RELDATE      "2008/4/9"
-#define BNX2X_BC_VER    	0x040200
+#define BNX2X_BC_VER		0x040200
=20
 /* Time in jiffies before concluding the transmitter is hung. */
-#define TX_TIMEOUT      	(5*HZ)
+#define TX_TIMEOUT		(5*HZ)
=20
 static char version[] __devinitdata =3D
-	"Broadcom NetXtreme II 5771X 10Gigabit Ethernet Driver "
+	"Broadcom NetXtreme II 5771x 10Gigabit Ethernet Driver "
 	DRV_MODULE_NAME " " DRV_MODULE_VERSION " (" DRV_MODULE_RELDATE ")\n";
=20
 MODULE_AUTHOR("Eliezer Tamir <eliezert@broadcom.com>");
@@ -82,20 +83,19 @@ MODULE_VERSION(DRV_MODULE_VERSION);
=20
 static int use_inta;
 static int poll;
-static int onefunc;
-static int nomcp;
 static int debug;
+static int nomcp;
+static int load_count[3]; /* 0 common, 1 port0, 2 port1 */
 static int use_multi;
=20
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
=20
 #ifdef BNX2X_MULTI
 module_param(use_multi, int, 0);
@@ -104,18 +104,26 @@ MODULE_PARM_DESC(use_multi, "use per-CPU queues")=
;
=20
 enum bnx2x_board_type {
 	BCM57710 =3D 0,
+	BCM57711 =3D 1,
+	BCM57711E =3D 2,
 };
=20
 /* indexed by board_t, above */
 static struct {
 	char *name;
 } board_info[] __devinitdata =3D {
-	{ "Broadcom NetXtreme II BCM57710 XGb" }
+	{ "Broadcom NetXtreme II BCM57710 XGb" },
+	{ "Broadcom NetXtreme II BCM57711 XGb" },
+	{ "Broadcom NetXtreme II BCM57711E XGb" }
 };
=20
 static const struct pci_device_id bnx2x_pci_tbl[] =3D {
 	{ PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_NX2_57710,
 		PCI_ANY_ID, PCI_ANY_ID, 0, 0, BCM57710 },
+	{ PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_NX2_57711,
+		PCI_ANY_ID, PCI_ANY_ID, 0, 0, BCM57711 },
+	{ PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_NX2_57711E,
+		PCI_ANY_ID, PCI_ANY_ID, 0, 0, BCM57711E },
 	{ 0 }
 };
=20
@@ -200,7 +208,8 @@ void bnx2x_write_dmae(struct bnx2x *bp, dma_addr_t =
dma_addr, u32 dst_addr,
 #else
 			DMAE_CMD_ENDIANITY_DW_SWAP |
 #endif
-			(bp->port ? DMAE_CMD_PORT_1 : DMAE_CMD_PORT_0));
+			(BP_PORT(bp) ? DMAE_CMD_PORT_1 : DMAE_CMD_PORT_0) |
+			(BP_E1HVN(bp) << DMAE_CMD_E1HVN_SHIFT));
 	dmae->src_addr_lo =3D U64_LO(dma_addr);
 	dmae->src_addr_hi =3D U64_HI(dma_addr);
 	dmae->dst_addr_lo =3D dst_addr >> 2;
@@ -223,7 +232,7 @@ void bnx2x_write_dmae(struct bnx2x *bp, dma_addr_t =
dma_addr, u32 dst_addr,
=20
 	*wb_comp =3D 0;
=20
-	bnx2x_post_dmae(bp, dmae, (bp->port)*MAX_DMAE_C_PER_PORT);
+	bnx2x_post_dmae(bp, dmae, INIT_DMAE_C(bp));
=20
 	udelay(5);
=20
@@ -276,7 +285,8 @@ void bnx2x_read_dmae(struct bnx2x *bp, u32 src_addr=
, u32 len32)
 #else
 			DMAE_CMD_ENDIANITY_DW_SWAP |
 #endif
-			(bp->port ? DMAE_CMD_PORT_1 : DMAE_CMD_PORT_0) );
+			(BP_PORT(bp) ? DMAE_CMD_PORT_1 : DMAE_CMD_PORT_0) |
+			(BP_E1HVN(bp) << DMAE_CMD_E1HVN_SHIFT));
 	dmae->src_addr_lo =3D src_addr >> 2;
 	dmae->src_addr_hi =3D 0;
 	dmae->dst_addr_lo =3D U64_LO(bnx2x_sp_mapping(bp, wb_data));
@@ -296,7 +306,7 @@ void bnx2x_read_dmae(struct bnx2x *bp, u32 src_addr=
, u32 len32)
=20
 	*wb_comp =3D 0;
=20
-	bnx2x_post_dmae(bp, dmae, (bp->port)*MAX_DMAE_C_PER_PORT);
+	bnx2x_post_dmae(bp, dmae, INIT_DMAE_C(bp));
=20
 	udelay(5);
=20
@@ -346,8 +356,8 @@ static int bnx2x_mc_assert(struct bnx2x *bp)
 {
 	int i, j, rc =3D 0;
 	char last_idx;
-	const char storm[] =3D {"XTCU"};
-	const u32 intmem_base[] =3D {
+	static const char storm[] =3D {"XTCU"};
+	static const u32 intmem_base[] =3D {
 		BAR_XSTRORM_INTMEM,
 		BAR_TSTRORM_INTMEM,
 		BAR_CSTRORM_INTMEM,
@@ -356,29 +366,29 @@ static int bnx2x_mc_assert(struct bnx2x *bp)
=20
 	/* Go through all instances of all SEMIs */
 	for (i =3D 0; i < 4; i++) {
-		last_idx =3D REG_RD8(bp, XSTORM_ASSERT_LIST_INDEX_OFFSET +
-				   intmem_base[i]);
+		last_idx =3D REG_RD8(bp, intmem_base[i] +
+				   XSTORM_ASSERT_LIST_INDEX_OFFSET);
 		if (last_idx)
-			BNX2X_LOG("DATA %cSTORM_ASSERT_LIST_INDEX 0x%x\n",
+			BNX2X_ERR("%cSTORM_ASSERT_LIST_INDEX 0x%x\n",
 				  storm[i], last_idx);
=20
 		/* print the asserts */
 		for (j =3D 0; j < STROM_ASSERT_ARRAY_SIZE; j++) {
 			u32 row0, row1, row2, row3;
=20
-			row0 =3D REG_RD(bp, XSTORM_ASSERT_LIST_OFFSET(j) +
-				      intmem_base[i]);
-			row1 =3D REG_RD(bp, XSTORM_ASSERT_LIST_OFFSET(j) + 4 +
-				      intmem_base[i]);
-			row2 =3D REG_RD(bp, XSTORM_ASSERT_LIST_OFFSET(j) + 8 +
-				      intmem_base[i]);
-			row3 =3D REG_RD(bp, XSTORM_ASSERT_LIST_OFFSET(j) + 12 +
-				      intmem_base[i]);
+			row0 =3D REG_RD(bp, intmem_base[i] +
+				      XSTORM_ASSERT_LIST_OFFSET(j));
+			row1 =3D REG_RD(bp, intmem_base[i] +
+				      XSTORM_ASSERT_LIST_OFFSET(j) + 4);
+			row2 =3D REG_RD(bp, intmem_base[i] +
+				      XSTORM_ASSERT_LIST_OFFSET(j) + 8);
+			row3 =3D REG_RD(bp, intmem_base[i] +
+				      XSTORM_ASSERT_LIST_OFFSET(j) + 12);
=20
 			if (row0 !=3D COMMON_ASM_INVALID_ASSERT_OPCODE) {
-				BNX2X_LOG("DATA %cSTORM_ASSERT_INDEX 0x%x =3D"
-					  " 0x%08x 0x%08x 0x%08x 0x%08x\n",
-					  storm[i], j, row3, row2, row1, row0);
+				BNX2X_ERR("%cSTORM_ASSERT_INDEX 0x%x =3D 0x%08x"
+					  " 0x%08x 0x%08x 0x%08x\n",
+					 storm[i], j, row3, row2, row1, row0);
 				rc++;
 			} else {
 				break;
@@ -481,7 +491,7 @@ static void bnx2x_panic_dump(struct bnx2x *bp)
 		  bp->def_c_idx, bp->def_u_idx, bp->def_x_idx, bp->def_t_idx,
 		  bp->def_att_idx, bp->attn_state, bp->spq_prod_idx);
=20
-
+	bnx2x_fw_dump(bp);
 	bnx2x_mc_assert(bp);
 	BNX2X_ERR("end crash dump -----------------\n");
=20
@@ -491,7 +501,7 @@ static void bnx2x_panic_dump(struct bnx2x *bp)
=20
 static void bnx2x_int_enable(struct bnx2x *bp)
 {
-	int port =3D bp->port;
+	int port =3D BP_PORT(bp);
 	u32 addr =3D port ? HC_REG_CONFIG_1 : HC_REG_CONFIG_0;
 	u32 val =3D REG_RD(bp, addr);
 	int msix =3D (bp->flags & USING_MSIX_FLAG) ? 1 : 0;
@@ -506,7 +516,6 @@ static void bnx2x_int_enable(struct bnx2x *bp)
 			HC_CONFIG_0_REG_INT_LINE_EN_0 |
 			HC_CONFIG_0_REG_ATTN_BIT_EN_0);
=20
-		/* Errata A0.158 workaround */
 		DP(NETIF_MSG_INTR, "write %x to HC %d (addr 0x%x)  MSI-X %d\n",
 		   val, port, addr, msix);
=20
@@ -519,11 +528,25 @@ static void bnx2x_int_enable(struct bnx2x *bp)
 	   val, port, addr, msix);
=20
 	REG_WR(bp, addr, val);
+
+	if (CHIP_IS_E1H(bp)) {
+		/* init leading/trailing edge */
+		if (IS_E1HMF(bp)) {
+			val =3D (0xfe0f | (1 << (BP_E1HVN(bp) + 4)));
+			if (bp->port.pmf)
+				/* enable nig attention */
+				val |=3D 0x0100;
+		} else
+			val =3D 0xffff;
+
+		REG_WR(bp, HC_REG_TRAILING_EDGE_0 + port*8, val);
+		REG_WR(bp, HC_REG_LEADING_EDGE_0 + port*8, val);
+	}
 }
=20
 static void bnx2x_int_disable(struct bnx2x *bp)
 {
-	int port =3D bp->port;
+	int port =3D BP_PORT(bp);
 	u32 addr =3D port ? HC_REG_CONFIG_1 : HC_REG_CONFIG_0;
 	u32 val =3D REG_RD(bp, addr);
=20
@@ -542,7 +565,6 @@ static void bnx2x_int_disable(struct bnx2x *bp)
=20
 static void bnx2x_int_disable_sync(struct bnx2x *bp)
 {
-
 	int msix =3D (bp->flags & USING_MSIX_FLAG) ? 1 : 0;
 	int i;
=20
@@ -562,30 +584,29 @@ static void bnx2x_int_disable_sync(struct bnx2x *=
bp)
=20
 	/* make sure sp_task is not running */
 	cancel_work_sync(&bp->sp_task);
-
 }
=20
-/* fast path code */
+/* fast path */
=20
 /*
- * general service functions
+ * General service functions
  */
=20
-static inline void bnx2x_ack_sb(struct bnx2x *bp, u8 id,
+static inline void bnx2x_ack_sb(struct bnx2x *bp, u8 sb_id,
 				u8 storm, u16 index, u8 op, u8 update)
 {
-	u32 igu_addr =3D (IGU_ADDR_INT_ACK + IGU_PORT_BASE * bp->port) * 8;
+	u32 igu_addr =3D (IGU_ADDR_INT_ACK + IGU_FUNC_BASE * BP_FUNC(bp)) * 8=
;
 	struct igu_ack_register igu_ack;
=20
 	igu_ack.status_block_index =3D index;
 	igu_ack.sb_id_and_flags =3D
-			((id << IGU_ACK_REGISTER_STATUS_BLOCK_ID_SHIFT) |
+			((sb_id << IGU_ACK_REGISTER_STATUS_BLOCK_ID_SHIFT) |
 			 (storm << IGU_ACK_REGISTER_STORM_ID_SHIFT) |
 			 (update << IGU_ACK_REGISTER_UPDATE_INDEX_SHIFT) |
 			 (op << IGU_ACK_REGISTER_INTERRUPT_MODE_SHIFT));
=20
-/*      DP(NETIF_MSG_INTR, "write 0x%08x to IGU addr 0x%x\n",
-	   (*(u32 *)&igu_ack), BAR_IGU_INTMEM + igu_addr); */
+	DP(BNX2X_MSG_OFF, "write 0x%08x to IGU addr 0x%x\n",
+	   (*(u32 *)&igu_ack), BAR_IGU_INTMEM + igu_addr);
 	REG_WR(bp, BAR_IGU_INTMEM + igu_addr, (*(u32 *)&igu_ack));
 }
=20
@@ -622,11 +643,11 @@ static inline int bnx2x_has_work(struct bnx2x_fas=
tpath *fp)
=20
 static u16 bnx2x_ack_int(struct bnx2x *bp)
 {
-	u32 igu_addr =3D (IGU_ADDR_SIMD_MASK + IGU_PORT_BASE * bp->port) * 8;
+	u32 igu_addr =3D (IGU_ADDR_SIMD_MASK + IGU_FUNC_BASE * BP_FUNC(bp)) *=
 8;
 	u32 result =3D REG_RD(bp, BAR_IGU_INTMEM + igu_addr);
=20
-/*      DP(NETIF_MSG_INTR, "read 0x%08x from IGU addr 0x%x\n",
-	   result, BAR_IGU_INTMEM + igu_addr); */
+	DP(BNX2X_MSG_OFF, "read 0x%08x from IGU addr 0x%x\n",
+	   result, BAR_IGU_INTMEM + igu_addr);
=20
 #ifdef IGU_DEBUG
 #warning IGU_DEBUG active
@@ -652,7 +673,7 @@ static u16 bnx2x_free_tx_pkt(struct bnx2x *bp, stru=
ct bnx2x_fastpath *fp,
 	struct sw_tx_bd *tx_buf =3D &fp->tx_buf_ring[idx];
 	struct eth_tx_bd *tx_bd;
 	struct sk_buff *skb =3D tx_buf->skb;
-	u16 bd_idx =3D tx_buf->first_bd;
+	u16 bd_idx =3D TX_BD(tx_buf->first_bd), new_cons;
 	int nbd;
=20
 	DP(BNX2X_MSG_OFF, "pkt_idx %d  buff @(%p)->skb %p\n",
@@ -665,9 +686,10 @@ static u16 bnx2x_free_tx_pkt(struct bnx2x *bp, str=
uct bnx2x_fastpath *fp,
 			 BD_UNMAP_LEN(tx_bd), PCI_DMA_TODEVICE);
=20
 	nbd =3D le16_to_cpu(tx_bd->nbd) - 1;
+	new_cons =3D nbd + tx_buf->first_bd;
 #ifdef BNX2X_STOP_ON_ERROR
 	if (nbd > (MAX_SKB_FRAGS + 2)) {
-		BNX2X_ERR("bad nbd!\n");
+		BNX2X_ERR("BAD nbd!\n");
 		bnx2x_panic();
 	}
 #endif
@@ -707,32 +729,30 @@ static u16 bnx2x_free_tx_pkt(struct bnx2x *bp, st=
ruct bnx2x_fastpath *fp,
 	tx_buf->first_bd =3D 0;
 	tx_buf->skb =3D NULL;
=20
-	return bd_idx;
+	return new_cons;
 }
=20
-static inline u32 bnx2x_tx_avail(struct bnx2x_fastpath *fp)
+static inline u16 bnx2x_tx_avail(struct bnx2x_fastpath *fp)
 {
-	u16 used;
-	u32 prod;
-	u32 cons;
+	s16 used;
+	u16 prod;
+	u16 cons;
=20
-	/* Tell compiler that prod and cons can change */
-	barrier();
+	barrier(); /* Tell compiler that prod and cons can change */
 	prod =3D fp->tx_bd_prod;
 	cons =3D fp->tx_bd_cons;
=20
-	used =3D (NUM_TX_BD - NUM_TX_RINGS + prod - cons +
-		(cons / TX_DESC_CNT) - (prod / TX_DESC_CNT));
-
-	if (prod >=3D cons) {
-		/* used =3D prod - cons - prod/size + cons/size */
-		used -=3D NUM_TX_BD - NUM_TX_RINGS;
-	}
+	/* NUM_TX_RINGS =3D number of "next-page" entries
+	   It will be used as a threshold */
+	used =3D SUB_S16(prod, cons) + (s16)NUM_TX_RINGS;
=20
+#ifdef BNX2X_STOP_ON_ERROR
+	BUG_TRAP(used >=3D 0);
 	BUG_TRAP(used <=3D fp->bp->tx_ring_size);
 	BUG_TRAP((fp->bp->tx_ring_size - used) <=3D MAX_TX_AVAIL);
+#endif
=20
-	return (fp->bp->tx_ring_size - used);
+	return ((s16)(fp->bp->tx_ring_size) - used);
 }
=20
 static void bnx2x_tx_int(struct bnx2x_fastpath *fp, int work)
@@ -756,10 +776,10 @@ static void bnx2x_tx_int(struct bnx2x_fastpath *f=
p, int work)
=20
 		/* prefetch(bp->tx_buf_ring[pkt_cons].skb); */
=20
-		DP(NETIF_MSG_TX_DONE, "hw_cons %u  sw_cons %u  pkt_cons %d\n",
+		DP(NETIF_MSG_TX_DONE, "hw_cons %u  sw_cons %u  pkt_cons %u\n",
 		   hw_cons, sw_cons, pkt_cons);
=20
-/*      	if (NEXT_TX_IDX(sw_cons) !=3D hw_cons) {
+/*		if (NEXT_TX_IDX(sw_cons) !=3D hw_cons) {
 			rmb();
 			prefetch(fp->tx_buf_ring[NEXT_TX_IDX(sw_cons)].skb);
 		}
@@ -792,7 +812,6 @@ static void bnx2x_tx_int(struct bnx2x_fastpath *fp,=
 int work)
 			netif_wake_queue(bp->dev);
=20
 		netif_tx_unlock(bp->dev);
-
 	}
 }
=20
@@ -805,11 +824,12 @@ static void bnx2x_sp_event(struct bnx2x_fastpath =
*fp,
=20
 	DP(NETIF_MSG_RX_STATUS,
 	   "fp %d  cid %d  got ramrod #%d  state is %x  type is %d\n",
-	   fp->index, cid, command, bp->state, rr_cqe->ramrod_cqe.type);
+	   FP_IDX(fp), cid, command, bp->state,
+	   rr_cqe->ramrod_cqe.ramrod_type);
=20
 	bp->spq_left++;
=20
-	if (fp->index) {
+	if (FP_IDX(fp)) {
 		switch (command | fp->state) {
 		case (RAMROD_CMD_ID_ETH_CLIENT_SETUP |
 						BNX2X_FP_STATE_OPENING):
@@ -825,10 +845,11 @@ static void bnx2x_sp_event(struct bnx2x_fastpath =
*fp,
 			break;
=20
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
=20
@@ -845,25 +866,25 @@ static void bnx2x_sp_event(struct bnx2x_fastpath =
*fp,
 		break;
=20
 	case (RAMROD_CMD_ID_ETH_CFC_DEL | BNX2X_STATE_CLOSING_WAIT4_HALT):
-		DP(NETIF_MSG_IFDOWN, "got delete ramrod for MULTI[%d]\n",
-		   cid);
+		DP(NETIF_MSG_IFDOWN, "got delete ramrod for MULTI[%d]\n", cid);
 		bnx2x_fp(bp, cid, state) =3D BNX2X_FP_STATE_CLOSED;
 		break;
=20
 	case (RAMROD_CMD_ID_ETH_SET_MAC | BNX2X_STATE_OPEN):
+	case (RAMROD_CMD_ID_ETH_SET_MAC | BNX2X_STATE_DIAG):
 		DP(NETIF_MSG_IFUP, "got set mac ramrod\n");
 		break;
=20
 	case (RAMROD_CMD_ID_ETH_SET_MAC | BNX2X_STATE_CLOSING_WAIT4_HALT):
-		DP(NETIF_MSG_IFUP, "got (un)set mac ramrod\n");
+		DP(NETIF_MSG_IFDOWN, "got (un)set mac ramrod\n");
 		break;
=20
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
=20
 static inline int bnx2x_alloc_rx_skb(struct bnx2x *bp,
@@ -881,7 +902,6 @@ static inline int bnx2x_alloc_rx_skb(struct bnx2x *=
bp,
 	mapping =3D pci_map_single(bp->pdev, skb->data, bp->rx_buf_use_size,
 				 PCI_DMA_FROMDEVICE);
 	if (unlikely(dma_mapping_error(mapping))) {
-
 		dev_kfree_skb(skb);
 		return -ENOMEM;
 	}
@@ -923,7 +943,7 @@ static void bnx2x_reuse_rx_skb(struct bnx2x_fastpat=
h *fp,
 static int bnx2x_rx_int(struct bnx2x_fastpath *fp, int budget)
 {
 	struct bnx2x *bp =3D fp->bp;
-	u16 bd_cons, bd_prod, comp_ring_cons;
+	u16 bd_cons, bd_prod, bd_prod_fw, comp_ring_cons;
 	u16 hw_comp_cons, sw_comp_cons, sw_comp_prod;
 	int rx_pkt =3D 0;
=20
@@ -932,12 +952,15 @@ static int bnx2x_rx_int(struct bnx2x_fastpath *fp=
, int budget)
 		return 0;
 #endif
=20
+	/* CQ "next element" is of the size of the regular element,
+	   that's why it's ok here */
 	hw_comp_cons =3D le16_to_cpu(*fp->rx_cons_sb);
 	if ((hw_comp_cons & MAX_RCQ_DESC_CNT) =3D=3D MAX_RCQ_DESC_CNT)
 		hw_comp_cons++;
=20
 	bd_cons =3D fp->rx_bd_cons;
 	bd_prod =3D fp->rx_bd_prod;
+	bd_prod_fw =3D bd_prod;
 	sw_comp_cons =3D fp->rx_comp_cons;
 	sw_comp_prod =3D fp->rx_comp_prod;
=20
@@ -948,34 +971,30 @@ static int bnx2x_rx_int(struct bnx2x_fastpath *fp=
, int budget)
=20
 	DP(NETIF_MSG_RX_STATUS,
 	   "queue[%d]:  hw_comp_cons %u  sw_comp_cons %u\n",
-	   fp->index, hw_comp_cons, sw_comp_cons);
+	   FP_IDX(fp), hw_comp_cons, sw_comp_cons);
=20
 	while (sw_comp_cons !=3D hw_comp_cons) {
-		unsigned int len, pad;
-		struct sw_rx_bd *rx_buf;
+		struct sw_rx_bd *rx_buf =3D NULL;
 		struct sk_buff *skb;
 		union eth_rx_cqe *cqe;
+		u8 cqe_fp_flags;
+		u16 len, pad;
=20
 		comp_ring_cons =3D RCQ_BD(sw_comp_cons);
 		bd_prod =3D RX_BD(bd_prod);
 		bd_cons =3D RX_BD(bd_cons);
=20
 		cqe =3D &fp->rx_comp_ring[comp_ring_cons];
+		cqe_fp_flags =3D cqe->fast_path_cqe.type_error_flags;
=20
-		DP(NETIF_MSG_RX_STATUS, "hw_comp_cons %u  sw_comp_cons %u"
-		   "  comp_ring (%u)  bd_ring (%u,%u)\n",
-		   hw_comp_cons, sw_comp_cons,
-		   comp_ring_cons, bd_prod, bd_cons);
 		DP(NETIF_MSG_RX_STATUS, "CQE type %x  err %x  status %x"
-		   "  queue %x  vlan %x  len %x\n",
-		   cqe->fast_path_cqe.type,
-		   cqe->fast_path_cqe.error_type_flags,
-		   cqe->fast_path_cqe.status_flags,
+		   "  queue %x  vlan %x  len %x\n", CQE_TYPE(cqe_fp_flags),
+		   cqe_fp_flags, cqe->fast_path_cqe.status_flags,
 		   cqe->fast_path_cqe.rss_hash_result,
 		   cqe->fast_path_cqe.vlan_tag, cqe->fast_path_cqe.pkt_len);
=20
 		/* is this a slowpath msg? */
-		if (unlikely(cqe->fast_path_cqe.type)) {
+		if (unlikely(CQE_TYPE(cqe_fp_flags))) {
 			bnx2x_sp_event(fp, cqe);
 			goto next_cqe;
=20
@@ -983,7 +1002,6 @@ static int bnx2x_rx_int(struct bnx2x_fastpath *fp,=
 int budget)
 		} else {
 			rx_buf =3D &fp->rx_buf_ring[bd_cons];
 			skb =3D rx_buf->skb;
-
 			len =3D le16_to_cpu(cqe->fast_path_cqe.pkt_len);
 			pad =3D cqe->fast_path_cqe.placement_offset;
=20
@@ -995,13 +1013,11 @@ static int bnx2x_rx_int(struct bnx2x_fastpath *f=
p, int budget)
 			prefetch(((char *)(skb)) + 128);
=20
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
@@ -1017,7 +1033,7 @@ static int bnx2x_rx_int(struct bnx2x_fastpath *fp=
, int budget)
 							   len + pad);
 				if (new_skb =3D=3D NULL) {
 					DP(NETIF_MSG_RX_ERR,
-					   "ERROR packet dropped "
+					   "ERROR  packet dropped "
 					   "because of alloc failure\n");
 					/* TBD count this as a drop? */
 					goto reuse_rx;
@@ -1043,7 +1059,7 @@ static int bnx2x_rx_int(struct bnx2x_fastpath *fp=
, int budget)
=20
 			} else {
 				DP(NETIF_MSG_RX_ERR,
-				   "ERROR packet dropped because "
+				   "ERROR  packet dropped because "
 				   "of alloc failure\n");
 reuse_rx:
 				bnx2x_reuse_rx_skb(fp, skb, bd_cons, bd_prod);
@@ -1060,14 +1076,14 @@ reuse_rx:
 		}
=20
 #ifdef BCM_VLAN
-		if ((le16_to_cpu(cqe->fast_path_cqe.pars_flags.flags)
-				& PARSING_FLAGS_NUMBER_OF_NESTED_VLANS)
-		    && (bp->vlgrp !=3D NULL))
+		if ((bp->vlgrp !=3D NULL) &&
+		    (le16_to_cpu(cqe->fast_path_cqe.pars_flags.flags) &
+		     PARSING_FLAGS_VLAN))
 			vlan_hwaccel_receive_skb(skb, bp->vlgrp,
 				le16_to_cpu(cqe->fast_path_cqe.vlan_tag));
 		else
 #endif
-		netif_receive_skb(skb);
+			netif_receive_skb(skb);
=20
 		bp->dev->last_rx =3D jiffies;
=20
@@ -1076,22 +1092,25 @@ next_rx:
=20
 		bd_cons =3D NEXT_RX_IDX(bd_cons);
 		bd_prod =3D NEXT_RX_IDX(bd_prod);
+		bd_prod_fw =3D NEXT_RX_IDX(bd_prod_fw);
+		rx_pkt++;
 next_cqe:
 		sw_comp_prod =3D NEXT_RCQ_IDX(sw_comp_prod);
 		sw_comp_cons =3D NEXT_RCQ_IDX(sw_comp_cons);
-		rx_pkt++;
=20
-		if ((rx_pkt =3D=3D budget))
+		if (rx_pkt =3D=3D budget)
 			break;
 	} /* while */
=20
 	fp->rx_bd_cons =3D bd_cons;
-	fp->rx_bd_prod =3D bd_prod;
+	fp->rx_bd_prod =3D bd_prod_fw;
 	fp->rx_comp_cons =3D sw_comp_cons;
 	fp->rx_comp_prod =3D sw_comp_prod;
=20
 	REG_WR(bp, BAR_TSTRORM_INTMEM +
-	       TSTORM_RCQ_PROD_OFFSET(bp->port, fp->index), sw_comp_prod);
+		TSTORM_RX_PRODS_OFFSET(BP_PORT(bp), FP_CL_ID(fp)),
+		sw_comp_prod);
+
=20
 	mmiowb(); /* keep prod updates ordered */
=20
@@ -1106,10 +1125,11 @@ static irqreturn_t bnx2x_msix_fp_int(int irq, v=
oid *fp_cookie)
 	struct bnx2x_fastpath *fp =3D fp_cookie;
 	struct bnx2x *bp =3D fp->bp;
 	struct net_device *dev =3D bp->dev;
-	int index =3D fp->index;
+	int index =3D FP_IDX(fp);
=20
-	DP(NETIF_MSG_INTR, "got an msix interrupt on [%d]\n", index);
-	bnx2x_ack_sb(bp, index, USTORM_ID, 0, IGU_INT_DISABLE, 0);
+	DP(NETIF_MSG_INTR, "got an MSI-X interrupt on IDX:SB [%d:%d]\n",
+	   index, FP_SB_ID(fp));
+	bnx2x_ack_sb(bp, FP_SB_ID(fp), USTORM_ID, 0, IGU_INT_DISABLE, 0);
=20
 #ifdef BNX2X_STOP_ON_ERROR
 	if (unlikely(bp->panic))
@@ -1122,6 +1142,7 @@ static irqreturn_t bnx2x_msix_fp_int(int irq, voi=
d *fp_cookie)
 	prefetch(&fp->status_blk->u_status_block.status_block_index);
=20
 	netif_rx_schedule(dev, &bnx2x_fp(bp, index, napi));
+
 	return IRQ_HANDLED;
 }
=20
@@ -1130,6 +1151,7 @@ static irqreturn_t bnx2x_interrupt(int irq, void =
*dev_instance)
 	struct net_device *dev =3D dev_instance;
 	struct bnx2x *bp =3D netdev_priv(dev);
 	u16 status =3D bnx2x_ack_int(bp);
+	u16 mask;
=20
 	if (unlikely(status =3D=3D 0)) {
 		DP(NETIF_MSG_INTR, "not our interrupt!\n");
@@ -1149,7 +1171,8 @@ static irqreturn_t bnx2x_interrupt(int irq, void =
*dev_instance)
 		return IRQ_HANDLED;
 	}
=20
-	if (status & 0x2) {
+	mask =3D 0x2 << bp->fp[0].sb_id;
+	if (status & mask) {
 		struct bnx2x_fastpath *fp =3D &bp->fp[0];
=20
 		prefetch(fp->rx_cons_sb);
@@ -1159,13 +1182,11 @@ static irqreturn_t bnx2x_interrupt(int irq, voi=
d *dev_instance)
=20
 		netif_rx_schedule(dev, &bnx2x_fp(bp, 0, napi));
=20
-		status &=3D ~0x2;
-		if (!status)
-			return IRQ_HANDLED;
+		status &=3D ~mask;
 	}
=20
-	if (unlikely(status & 0x1)) {
=20
+	if (unlikely(status & 0x1)) {
 		schedule_work(&bp->sp_task);
=20
 		status &=3D ~0x1;
@@ -1173,8 +1194,9 @@ static irqreturn_t bnx2x_interrupt(int irq, void =
*dev_instance)
 			return IRQ_HANDLED;
 	}
=20
-	DP(NETIF_MSG_INTR, "got an unknown interrupt! (status is %u)\n",
-	   status);
+	if (status)
+		DP(NETIF_MSG_INTR, "got an unknown interrupt! (status is %u)\n",
+		   status);
=20
 	return IRQ_HANDLED;
 }
@@ -1192,7 +1214,7 @@ static int bnx2x_hw_lock(struct bnx2x *bp, u32 re=
source)
 {
 	u32 lock_status;
 	u32 resource_bit =3D (1 << resource);
-	u8 port =3D bp->port;
+	u8 port =3D BP_PORT(bp);
 	int cnt;
=20
 	/* Validating that the resource is within range */
@@ -1230,7 +1252,7 @@ static int bnx2x_hw_unlock(struct bnx2x *bp, u32 =
resource)
 {
 	u32 lock_status;
 	u32 resource_bit =3D (1 << resource);
-	u8 port =3D bp->port;
+	u8 port =3D BP_PORT(bp);
=20
 	/* Validating that the resource is within range */
 	if (resource > HW_LOCK_MAX_RESOURCE_VALUE) {
@@ -1257,7 +1279,7 @@ static void bnx2x_phy_hw_lock(struct bnx2x *bp)
 {
 	u32 ext_phy_type =3D XGXS_EXT_PHY_TYPE(bp->link_params.ext_phy_config=
);
=20
-	mutex_lock(&bp->phy_mutex);
+	mutex_lock(&bp->port.phy_mutex);
=20
 	if ((ext_phy_type =3D=3D PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8072) ||
 	    (ext_phy_type =3D=3D PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8073))
@@ -1272,14 +1294,14 @@ static void bnx2x_phy_hw_unlock(struct bnx2x *b=
p)
 	    (ext_phy_type =3D=3D PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8073))
 		bnx2x_hw_unlock(bp, HW_LOCK_RESOURCE_8072_MDIO);
=20
-	mutex_unlock(&bp->phy_mutex);
+	mutex_unlock(&bp->port.phy_mutex);
 }
=20
 int bnx2x_set_gpio(struct bnx2x *bp, int gpio_num, u32 mode)
 {
 	/* The GPIO should be swapped if swap register is set and active */
 	int gpio_port =3D (REG_RD(bp, NIG_REG_PORT_SWAP) &&
-			 REG_RD(bp, NIG_REG_STRAP_OVERRIDE)) ^ bp->port;
+			 REG_RD(bp, NIG_REG_STRAP_OVERRIDE)) ^ BP_PORT(bp);
 	int gpio_shift =3D gpio_num +
 			(gpio_port ? MISC_REGISTERS_GPIO_PORT_SHIFT : 0);
 	u32 gpio_mask =3D (1 << gpio_shift);
@@ -1378,18 +1400,18 @@ static void bnx2x_calc_fc_adv(struct bnx2x *bp)
 {
 	switch (bp->link_vars.ieee_fc) {
 	case MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_NONE:
-		bp->advertising &=3D ~(ADVERTISED_Asym_Pause |
+		bp->port.advertising &=3D ~(ADVERTISED_Asym_Pause |
 					  ADVERTISED_Pause);
 		break;
 	case MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_BOTH:
-		bp->advertising |=3D (ADVERTISED_Asym_Pause |
+		bp->port.advertising |=3D (ADVERTISED_Asym_Pause |
 					 ADVERTISED_Pause);
 		break;
 	case MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_ASYMMETRIC:
-		bp->advertising |=3D ADVERTISED_Asym_Pause;
+		bp->port.advertising |=3D ADVERTISED_Asym_Pause;
 		break;
 	default:
-		bp->advertising &=3D ~(ADVERTISED_Asym_Pause |
+		bp->port.advertising &=3D ~(ADVERTISED_Asym_Pause |
 					  ADVERTISED_Pause);
 		break;
 	}
@@ -1472,15 +1494,264 @@ static u8 bnx2x_link_test(struct bnx2x *bp)
 	return rc;
 }
=20
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
+	int i, port =3D BP_PORT(bp);
+	u32 wsum =3D 0;
+	int all_zero =3D 1;
+
+	for (i =3D 0; i < E1HVN_MAX; i++) {
+		u32 vn_cfg =3D
+			SHMEM_RD(bp, mf_cfg.func_mf_config[2*i + port].config);
+		u32 vn_min_rate =3D ((vn_cfg & FUNC_MF_CFG_MIN_BW_MASK) >>
+				     FUNC_MF_CFG_MIN_BW_SHIFT) * 100;
+		if (!(vn_cfg & FUNC_MF_CFG_FUNC_HIDE)) {
+			/* If min rate is zero - set it to 1 */
+			if (!vn_min_rate)
+				vn_min_rate =3D DEF_MIN_RATE;
+			else
+				all_zero =3D 0;
+
+			wsum +=3D vn_min_rate;
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
+				   u16 port_rate)
+{
+	u32 fair_periodic_timeout_usec, r_param =3D port_rate / 8;
+	struct cmng_struct_per_port m_cmng_port;
+	int port =3D BP_PORT(bp);
+	int i;
+
+	memset(&m_cmng_port, 0, sizeof(struct cmng_struct_per_port));
+
+	/* Enable minmax only if we are in e1hmf mode */
+	if (IS_E1HMF(bp)) {
+		u32 tFair;
+
+		/* Enable RS and fairness */
+		m_cmng_port.flags.cmng_vn_enable =3D 1;
+		m_cmng_port.flags.fairness_enable =3D en_fness ? 1 : 0;
+		m_cmng_port.flags.rate_shaping_enable =3D 1;
+
+		if (!en_fness)
+			DP(NETIF_MSG_IFUP, "All MIN values are zeroes"
+			   "  fairness will be disabled\n");
+
+		/* RS per-port variables */
+		/* 100 usec in SDM ticks =3D 25 since each tick is 4 usec */
+		m_cmng_port.rs_vars.rs_periodic_timeout =3D
+						RS_PERIODIC_TIMEOUT_USEC / 4;
+
+		/* this is the threshold below which no timer arming will occur
+		   1.25 coefficient is for the threshold to be a little bigger
+		   than the real time, to compensate for timer in-accuracy */
+		m_cmng_port.rs_vars.rs_threshold =3D
+				(5 * RS_PERIODIC_TIMEOUT_USEC * r_param) / 4;
+
+
+		/* resolution of fairness timer */
+		fair_periodic_timeout_usec =3D QM_ARB_BYTES / r_param;
+		/* for 10G it is 1000usec. for 1G it is 10000usec. */
+		tFair =3D T_FAIR_COEF / port_rate;
+
+		/* this is the threshold below which we won't arm
+		   the timer anymore */
+		m_cmng_port.fair_vars.fair_threshold =3D
+					fair_periodic_timeout_usec * r_param;
+
+		/* we multiply by 1e3/8 to get bytes/msec.
+		   We don't want the credits to pass a credit
+		   of the T_FAIR*FAIR_MEM (algorithm resolution) */
+		m_cmng_port.fair_vars.upper_bound =3D
+			(u32)(r_param * tFair * FAIR_MEM);
+		/* since each tick is 4 microSeconds */
+		m_cmng_port.fair_vars.fairness_timeout =3D
+						fair_periodic_timeout_usec / 4;
+
+	} else {
+		/* Disable rate shaping and fairness */
+		m_cmng_port.flags.cmng_vn_enable =3D 0;
+		m_cmng_port.flags.fairness_enable =3D 0;
+		m_cmng_port.flags.rate_shaping_enable =3D 0;
+
+		DP(NETIF_MSG_IFUP,
+		   "Single function mode  minmax will be disabled\n");
+	}
+
+	/* Store it to internal memory */
+	for (i =3D 0; i < sizeof(struct cmng_struct_per_port) / 4; i++)
+		REG_WR(bp, BAR_XSTRORM_INTMEM +
+		       XSTORM_CMNG_PER_PORT_VARS_OFFSET(port) + i * 4,
+		       ((u32 *)(&m_cmng_port))[i]);
+}
+
+static void bnx2x_init_func_minmax(struct bnx2x *bp, int func,
+				   u32 wsum, u16 port_rate)
+{
+	struct rate_shaping_vars_per_vn m_rs_vn;
+	struct fairness_vars_per_vn m_fair_vn;
+	u32 vn_cfg =3D SHMEM_RD(bp, mf_cfg.func_mf_config[func].config);
+	u16 vn_min_rate, vn_max_rate;
+	int i;
+
+	/* If function is hidden - set min and max to zeroes */
+	if (vn_cfg & FUNC_MF_CFG_FUNC_HIDE) {
+		vn_min_rate =3D 0;
+		vn_max_rate =3D 0;
+
+	} else {
+		vn_min_rate =3D ((vn_cfg & FUNC_MF_CFG_MIN_BW_MASK) >>
+				FUNC_MF_CFG_MIN_BW_SHIFT) * 100;
+		/* If FAIRNESS is enabled (not all min rates are zeroes) and
+		   if current min rate is zero - set it to 1.
+		   This is a requirment of the algorithm. */
+		if ((vn_min_rate =3D=3D 0) && wsum)
+			vn_min_rate =3D DEF_MIN_RATE;
+		vn_max_rate =3D ((vn_cfg & FUNC_MF_CFG_MAX_BW_MASK) >>
+				FUNC_MF_CFG_MAX_BW_SHIFT) * 100;
+	}
+
+	DP(NETIF_MSG_IFUP, "func %d: vn_min_rate=3D%d  vn_max_rate=3D%d  "
+	   "wsum=3D%d\n", func, vn_min_rate, vn_max_rate, wsum);
+
+	memset(&m_rs_vn, 0, sizeof(struct rate_shaping_vars_per_vn));
+	memset(&m_fair_vn, 0, sizeof(struct fairness_vars_per_vn));
+
+	/************************************************************/
+	/* RATE SHAPING section (maximum bandwidth for protocol/vn) */
+	/************************************************************/
+	/* global vn counter: maximal Mbps for this vn */
+	m_rs_vn.vn_counter.rate =3D vn_max_rate;
+
+	/* quota - number of bytes transmitted in this period */
+	m_rs_vn.vn_counter.quota =3D
+				(vn_max_rate * RS_PERIODIC_TIMEOUT_USEC) / 8;
+
+#ifdef BNX2X_PER_PROT_QOS
+	/* per protocol counter */
+	for (protocol =3D 0; protocol < NUM_OF_PROTOCOLS; protocol++) {
+		/* maximal Mbps for this protocol */
+		m_rs_vn.protocol_counters[protocol].rate =3D
+						protocol_max_rate[protocol];
+		/* the quota in each timer period -
+		   number of bytes transmitted in this period */
+		m_rs_vn.protocol_counters[protocol].quota =3D
+			(u32)(rs_periodic_timeout_usec *
+			  ((double)m_rs_vn.
+				   protocol_counters[protocol].rate/8));
+	}
+#endif
+	/*******************************************************************/
+	/* FAIRNESS section (minimal guaranteed bandwidth for protocol/vn) */
+	/*******************************************************************/
+	if (wsum) {
+		/* global vn counter:
+		   credit for each period of the fairness algorithm:
+		   number of bytes in T_FAIR
+		   (this vn share of the port rate) */
+		m_fair_vn.vn_credit_delta =3D
+			((u64)T_FAIR_COEF * vn_min_rate) / (8 * wsum);
+	}
+
+#ifdef BNX2X_PER_PROT_QOS
+	do {
+		u32 protocolWeightSum =3D 0;
+		for (protocol =3D 0; protocol < NUM_OF_PROTOCOLS; protocol++)
+			protocolWeightSum +=3D
+				drvInit.protocol_min_rate[protocol];
+		/* per protocol counter -
+		   NOT NEEDED IF NO PER-PROTOCOL CONGESTION MANAGEMENT */
+		if (protocolWeightSum > 0) {
+			for (protocol =3D 0;
+			      protocol < NUM_OF_PROTOCOLS;
+			      protocol++)
+				/* this is the credit for each period of the
+				   fairness algorithm - number of bytes in
+				   T_FAIR (this protocol share of the vn rate)
+				 */
+				m_fair_vn.protocol_credit_delta[protocol] =3D
+					(u32)((vn_min_rate / 8) * t_fair *
+					protocol_min_rate / protocolWeightSum);
+		}
+	} while (0);
+#endif
+
+	/* Store it to internal memory */
+	for (i =3D 0; i < sizeof(struct rate_shaping_vars_per_vn)/4; i++)
+		REG_WR(bp, BAR_XSTRORM_INTMEM +
+		       XSTORM_RATE_SHAPING_PER_VN_VARS_OFFSET(func) + i * 4,
+		       ((u32 *)(&m_rs_vn))[i]);
+
+	for (i =3D 0; i < sizeof(struct fairness_vars_per_vn)/4; i++)
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
=20
 	/* indicate link status */
 	bnx2x_link_report(bp);
+
+	if (IS_E1HMF(bp)) {
+		int func;
+
+		for (vn =3D VN_0; vn < E1HVN_MAX; vn++) {
+			if (vn =3D=3D BP_E1HVN(bp))
+				continue;
+
+			func =3D ((vn << 1) | BP_PORT(bp));
+
+			/* Set the attention towards other drivers
+			   on the same port */
+			REG_WR(bp, MISC_REG_AEU_GENERAL_ATTN_0 +
+			       (LINK_SYNC_ATTENTION_BIT_FUNC_0 + func)*4, 1);
+		}
+	}
+
+	if (CHIP_IS_E1H(bp) && bp->port.pmf &&
+		(bp->link_vars.line_speed > 0)) {
+		int i;
+		u32 wsum;
+		int port =3D BP_PORT(bp);
+
+		/* Init RATE SHAPING and FAIRNESS contexts */
+		wsum =3D bnx2x_calc_vn_wsum(bp);
+		bnx2x_init_port_minmax(bp, (int)wsum,
+					bp->link_vars.line_speed);
+		if (IS_E1HMF(bp))
+			for (i =3D 0; i < E1HVN_MAX; i++)
+				bnx2x_init_func_minmax(bp, 2*i + port,
+					wsum, bp->link_vars.line_speed);
+	}
 }
=20
 static void bnx2x__link_status_update(struct bnx2x *bp)
@@ -1494,6 +1765,20 @@ static void bnx2x__link_status_update(struct bnx=
2x *bp)
 	bnx2x_link_report(bp);
 }
=20
+static void bnx2x_pmf_update(struct bnx2x *bp)
+{
+	int port =3D BP_PORT(bp);
+	u32 val;
+
+	bp->port.pmf =3D 1;
+	DP(NETIF_MSG_LINK, "pmf %d\n", bp->port.pmf);
+
+	/* enable nig attention */
+	val =3D (0xff0f | (1 << (BP_E1HVN(bp) + 4)));
+	REG_WR(bp, HC_REG_TRAILING_EDGE_0 + port*8, val);
+	REG_WR(bp, HC_REG_LEADING_EDGE_0 + port*8, val);
+}
+
 /* end of Link */
=20
 /* slow path */
@@ -1506,10 +1791,10 @@ static void bnx2x__link_status_update(struct bn=
x2x *bp)
 static int bnx2x_sp_post(struct bnx2x *bp, int command, int cid,
 			 u32 data_hi, u32 data_lo, int common)
 {
-	int port =3D bp->port;
+	int func =3D BP_FUNC(bp);
=20
-	DP(NETIF_MSG_TIMER,
-	   "spe (%x:%x)  command %d  hw_cid %x  data (%x:%x)  left %x\n",
+	DP(BNX2X_MSG_SP/*NETIF_MSG_TIMER*/,
+	   "SPQE (%x:%x)  command %d  hw_cid %x  data (%x:%x)  left %x\n",
 	   (u32)U64_HI(bp->spq_mapping), (u32)(U64_LO(bp->spq_mapping) +
 	   (void *)bp->spq_prod_bd - (void *)bp->spq), command,
 	   HW_CID(bp, cid), data_hi, data_lo, bp->spq_left);
@@ -1552,7 +1837,7 @@ static int bnx2x_sp_post(struct bnx2x *bp, int co=
mmand, int cid,
 		bp->spq_prod_idx++;
 	}
=20
-	REG_WR(bp, BAR_XSTRORM_INTMEM + XSTORM_SPQ_PROD_OFFSET(port),
+	REG_WR(bp, BAR_XSTRORM_INTMEM + XSTORM_SPQ_PROD_OFFSET(func),
 	       bp->spq_prod_idx);
=20
 	spin_unlock(&bp->spq_lock);
@@ -1562,8 +1847,8 @@ static int bnx2x_sp_post(struct bnx2x *bp, int co=
mmand, int cid,
 /* acquire split MCP access lock register */
 static int bnx2x_lock_alr(struct bnx2x *bp)
 {
-	int rc =3D 0;
 	u32 i, j, val;
+	int rc =3D 0;
=20
 	might_sleep();
 	i =3D 100;
@@ -1573,13 +1858,10 @@ static int bnx2x_lock_alr(struct bnx2x *bp)
 		val =3D REG_RD(bp, GRCBASE_MCP + 0x9c);
 		if (val & (1L << 31))
 			break;
-
 		msleep(5);
 	}
-
 	if (!(val & (1L << 31))) {
 		BNX2X_ERR("Cannot acquire nvram interface\n");
-
 		rc =3D -EBUSY;
 	}
=20
@@ -1630,8 +1912,9 @@ static inline u16 bnx2x_update_dsb_idx(struct bnx=
2x *bp)
=20
 static void bnx2x_attn_int_asserted(struct bnx2x *bp, u32 asserted)
 {
-	int port =3D bp->port;
-	u32 igu_addr =3D (IGU_ADDR_ATTN_BITS_SET + IGU_PORT_BASE * port) * 8;
+	int port =3D BP_PORT(bp);
+	int func =3D BP_FUNC(bp);
+	u32 igu_addr =3D (IGU_ADDR_ATTN_BITS_SET + IGU_FUNC_BASE * func) * 8;
 	u32 aeu_addr =3D port ? MISC_REG_AEU_MASK_ATTN_FUNC_1 :
 			      MISC_REG_AEU_MASK_ATTN_FUNC_0;
 	u32 nig_int_mask_addr =3D port ? NIG_REG_MASK_INTERRUPT_PORT1 :
@@ -1715,14 +1998,14 @@ static void bnx2x_attn_int_asserted(struct bnx2=
x *bp, u32 asserted)
=20
 static inline void bnx2x_attn_int_deasserted0(struct bnx2x *bp, u32 at=
tn)
 {
-	int port =3D bp->port;
+	int port =3D BP_PORT(bp);
 	int reg_offset;
 	u32 val;
=20
-	if (attn & AEU_INPUTS_ATTN_BITS_SPIO5) {
+	reg_offset =3D (port ? MISC_REG_AEU_ENABLE1_FUNC_1_OUT_0 :
+			     MISC_REG_AEU_ENABLE1_FUNC_0_OUT_0);
=20
-		reg_offset =3D (port ? MISC_REG_AEU_ENABLE1_FUNC_1_OUT_0 :
-				     MISC_REG_AEU_ENABLE1_FUNC_0_OUT_0);
+	if (attn & AEU_INPUTS_ATTN_BITS_SPIO5) {
=20
 		val =3D REG_RD(bp, reg_offset);
 		val &=3D ~AEU_INPUTS_ATTN_BITS_SPIO5;
@@ -1730,7 +2013,7 @@ static inline void bnx2x_attn_int_deasserted0(str=
uct bnx2x *bp, u32 attn)
=20
 		BNX2X_ERR("SPIO5 hw attention\n");
=20
-		switch (bp->board & SHARED_HW_CFG_BOARD_TYPE_MASK) {
+		switch (bp->common.board & SHARED_HW_CFG_BOARD_TYPE_MASK) {
 		case SHARED_HW_CFG_BOARD_TYPE_BCM957710A1022G:
 			/* Fan failure attention */
=20
@@ -1761,6 +2044,17 @@ static inline void bnx2x_attn_int_deasserted0(st=
ruct bnx2x *bp, u32 attn)
 			break;
 		}
 	}
+
+	if (attn & HW_INTERRUT_ASSERT_SET_0) {
+
+		val =3D REG_RD(bp, reg_offset);
+		val &=3D ~(attn & HW_INTERRUT_ASSERT_SET_0);
+		REG_WR(bp, reg_offset, val);
+
+		BNX2X_ERR("FATAL HW block attention set0 0x%x\n",
+			  (attn & HW_INTERRUT_ASSERT_SET_0));
+		bnx2x_panic();
+	}
 }
=20
 static inline void bnx2x_attn_int_deasserted1(struct bnx2x *bp, u32 at=
tn)
@@ -1775,6 +2069,23 @@ static inline void bnx2x_attn_int_deasserted1(st=
ruct bnx2x *bp, u32 attn)
 		if (val & 0x2)
 			BNX2X_ERR("FATAL error from DORQ\n");
 	}
+
+	if (attn & HW_INTERRUT_ASSERT_SET_1) {
+
+		int port =3D BP_PORT(bp);
+		int reg_offset;
+
+		reg_offset =3D (port ? MISC_REG_AEU_ENABLE1_FUNC_1_OUT_1 :
+				     MISC_REG_AEU_ENABLE1_FUNC_0_OUT_1);
+
+		val =3D REG_RD(bp, reg_offset);
+		val &=3D ~(attn & HW_INTERRUT_ASSERT_SET_1);
+		REG_WR(bp, reg_offset, val);
+
+		BNX2X_ERR("FATAL HW block attention set1 0x%x\n",
+			  (attn & HW_INTERRUT_ASSERT_SET_1));
+		bnx2x_panic();
+	}
 }
=20
 static inline void bnx2x_attn_int_deasserted2(struct bnx2x *bp, u32 at=
tn)
@@ -1798,13 +2109,41 @@ static inline void bnx2x_attn_int_deasserted2(s=
truct bnx2x *bp, u32 attn)
 		if (val & 0x18000)
 			BNX2X_ERR("FATAL error from PXP\n");
 	}
+
+	if (attn & HW_INTERRUT_ASSERT_SET_2) {
+
+		int port =3D BP_PORT(bp);
+		int reg_offset;
+
+		reg_offset =3D (port ? MISC_REG_AEU_ENABLE1_FUNC_1_OUT_2 :
+				     MISC_REG_AEU_ENABLE1_FUNC_0_OUT_2);
+
+		val =3D REG_RD(bp, reg_offset);
+		val &=3D ~(attn & HW_INTERRUT_ASSERT_SET_2);
+		REG_WR(bp, reg_offset, val);
+
+		BNX2X_ERR("FATAL HW block attention set2 0x%x\n",
+			  (attn & HW_INTERRUT_ASSERT_SET_2));
+		bnx2x_panic();
+	}
 }
=20
 static inline void bnx2x_attn_int_deasserted3(struct bnx2x *bp, u32 at=
tn)
 {
+	u32 val;
+
 	if (attn & EVEREST_GEN_ATTN_IN_USE_MASK) {
=20
-		if (attn & BNX2X_MC_ASSERT_BITS) {
+		if (attn & BNX2X_PMF_LINK_ASSERT) {
+			int func =3D BP_FUNC(bp);
+
+			REG_WR(bp, MISC_REG_AEU_GENERAL_ATTN_12 + func*4, 0);
+			bnx2x__link_status_update(bp);
+			if (SHMEM_RD(bp, func_mb[func].drv_status) &
+							DRV_STATUS_PMF)
+				bnx2x_pmf_update(bp);
+
+		} else if (attn & BNX2X_MC_ASSERT_BITS) {
=20
 			BNX2X_ERR("MC assert!\n");
 			REG_WR(bp, MISC_REG_AEU_GENERAL_ATTN_10, 0);
@@ -1817,16 +2156,25 @@ static inline void bnx2x_attn_int_deasserted3(s=
truct bnx2x *bp, u32 attn)
=20
 			BNX2X_ERR("MCP assert!\n");
 			REG_WR(bp, MISC_REG_AEU_GENERAL_ATTN_11, 0);
-			bnx2x_mc_assert(bp);
+			bnx2x_fw_dump(bp);
=20
 		} else
 			BNX2X_ERR("Unknown HW assert! (attn 0x%x)\n", attn);
 	}
=20
 	if (attn & EVEREST_LATCHED_ATTN_IN_USE_MASK) {
-
+		BNX2X_ERR("LATCHED attention 0x%08x (masked)\n", attn);
+		if (attn & BNX2X_GRC_TIMEOUT) {
+			val =3D CHIP_IS_E1H(bp) ?
+				REG_RD(bp, MISC_REG_GRC_TIMEOUT_ATTN) : 0;
+			BNX2X_ERR("GRC time-out 0x%08x\n", val);
+		}
+		if (attn & BNX2X_GRC_RSV) {
+			val =3D CHIP_IS_E1H(bp) ?
+				REG_RD(bp, MISC_REG_GRC_RSV_ATTN) : 0;
+			BNX2X_ERR("GRC reserved 0x%08x\n", val);
+		}
 		REG_WR(bp, MISC_REG_AEU_CLR_LATCH_SIGNAL, 0x7ff);
-		BNX2X_ERR("LATCHED attention 0x%x (masked)\n", attn);
 	}
 }
=20
@@ -1834,7 +2182,7 @@ static void bnx2x_attn_int_deasserted(struct bnx2=
x *bp, u32 deasserted)
 {
 	struct attn_route attn;
 	struct attn_route group_mask;
-	int port =3D bp->port;
+	int port =3D BP_PORT(bp);
 	int index;
 	u32 reg_addr;
 	u32 val;
@@ -1847,14 +2195,16 @@ static void bnx2x_attn_int_deasserted(struct bn=
x2x *bp, u32 deasserted)
 	attn.sig[1] =3D REG_RD(bp, MISC_REG_AEU_AFTER_INVERT_2_FUNC_0 + port*=
4);
 	attn.sig[2] =3D REG_RD(bp, MISC_REG_AEU_AFTER_INVERT_3_FUNC_0 + port*=
4);
 	attn.sig[3] =3D REG_RD(bp, MISC_REG_AEU_AFTER_INVERT_4_FUNC_0 + port*=
4);
-	DP(NETIF_MSG_HW, "attn %llx\n", (unsigned long long)attn.sig[0]);
+	DP(NETIF_MSG_HW, "attn: %08x %08x %08x %08x\n",
+	   attn.sig[0], attn.sig[1], attn.sig[2], attn.sig[3]);
=20
 	for (index =3D 0; index < MAX_DYNAMIC_ATTN_GRPS; index++) {
 		if (deasserted & (1 << index)) {
 			group_mask =3D bp->attn_group[index];
=20
-			DP(NETIF_MSG_HW, "group[%d]: %llx\n", index,
-			   (unsigned long long)group_mask.sig[0]);
+			DP(NETIF_MSG_HW, "group[%d]: %08x %08x %08x %08x\n",
+			   index, group_mask.sig[0], group_mask.sig[1],
+			   group_mask.sig[2], group_mask.sig[3]);
=20
 			bnx2x_attn_int_deasserted3(bp,
 					attn.sig[3] & group_mask.sig[3]);
@@ -1866,22 +2216,6 @@ static void bnx2x_attn_int_deasserted(struct bnx=
2x *bp, u32 deasserted)
 					attn.sig[0] & group_mask.sig[0]);
=20
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
@@ -1893,17 +2227,17 @@ static void bnx2x_attn_int_deasserted(struct bn=
x2x *bp, u32 deasserted)
=20
 	bnx2x_unlock_alr(bp);
=20
-	reg_addr =3D (IGU_ADDR_ATTN_BITS_CLR + IGU_PORT_BASE * port) * 8;
+	reg_addr =3D (IGU_ADDR_ATTN_BITS_CLR + IGU_FUNC_BASE * BP_FUNC(bp)) *=
 8;
=20
 	val =3D ~deasserted;
-/*      DP(NETIF_MSG_INTR, "write 0x%08x to IGU addr 0x%x\n",
+/*	DP(NETIF_MSG_INTR, "write 0x%08x to IGU addr 0x%x\n",
 	   val, BAR_IGU_INTMEM + reg_addr); */
 	REG_WR(bp, BAR_IGU_INTMEM + reg_addr, val);
=20
 	if (bp->aeu_mask & (deasserted & 0xff))
-		BNX2X_ERR("IGU BUG\n");
+		BNX2X_ERR("IGU BUG!\n");
 	if (~bp->attn_state & deasserted)
-		BNX2X_ERR("IGU BUG\n");
+		BNX2X_ERR("IGU BUG!\n");
=20
 	reg_addr =3D port ? MISC_REG_AEU_MASK_ATTN_FUNC_1 :
 			  MISC_REG_AEU_MASK_ATTN_FUNC_0;
@@ -1935,7 +2269,7 @@ static void bnx2x_attn_int(struct bnx2x *bp)
 	   attn_bits, attn_ack, asserted, deasserted);
=20
 	if (~(attn_bits ^ attn_ack) & (attn_bits ^ attn_state))
-		BNX2X_ERR("bad attention state\n");
+		BNX2X_ERR("BAD attention state\n");
=20
 	/* handle bits that were raised */
 	if (asserted)
@@ -1950,6 +2284,7 @@ static void bnx2x_sp_task(struct work_struct *wor=
k)
 	struct bnx2x *bp =3D container_of(work, struct bnx2x, sp_task);
 	u16 status;
=20
+
 	/* Return here if interrupt is disabled */
 	if (unlikely(atomic_read(&bp->intr_sem) !=3D 0)) {
 		DP(BNX2X_MSG_SP, "called but intr_sem not 0, returning\n");
@@ -1957,8 +2292,8 @@ static void bnx2x_sp_task(struct work_struct *wor=
k)
 	}
=20
 	status =3D bnx2x_update_dsb_idx(bp);
-	if (status =3D=3D 0)
-		BNX2X_ERR("spurious slowpath interrupt!\n");
+/*	if (status =3D=3D 0)				     */
+/*		BNX2X_ERR("spurious slowpath interrupt!\n"); */
=20
 	DP(NETIF_MSG_INTR, "got a slowpath interrupt (updated %x)\n", status)=
;
=20
@@ -1966,10 +2301,6 @@ static void bnx2x_sp_task(struct work_struct *wo=
rk)
 	if (status & 0x1)
 		bnx2x_attn_int(bp);
=20
-	/* CStorm events: query_stats, port delete ramrod */
-	if (status & 0x2)
-		bp->stat_pending =3D 0;
-
 	bnx2x_ack_sb(bp, DEF_SB_ID, ATTENTION_ID, bp->def_att_idx,
 		     IGU_INT_NOP, 1);
 	bnx2x_ack_sb(bp, DEF_SB_ID, USTORM_ID, le16_to_cpu(bp->def_u_idx),
@@ -2108,13 +2439,13 @@ static inline long bnx2x_hilo(u32 *hiref)
 static void bnx2x_init_mac_stats(struct bnx2x *bp)
 {
 	struct dmae_command *dmae;
-	int port =3D bp->port;
+	int port =3D BP_PORT(bp);
 	int loader_idx =3D port * 8;
 	u32 opcode;
 	u32 mac_addr;
=20
 	bp->executer_idx =3D 0;
-	if (bp->fw_mb) {
+	if (bp->func_stx) {
 		/* MCP */
 		opcode =3D (DMAE_CMD_SRC_PCI | DMAE_CMD_DST_GRC |
 			  DMAE_CMD_SRC_RESET | DMAE_CMD_DST_RESET |
@@ -2134,7 +2465,7 @@ static void bnx2x_init_mac_stats(struct bnx2x *bp=
)
 					   sizeof(u32));
 		dmae->src_addr_hi =3D U64_HI(bnx2x_sp_mapping(bp, eth_stats) +
 					   sizeof(u32));
-		dmae->dst_addr_lo =3D bp->fw_mb >> 2;
+		dmae->dst_addr_lo =3D bp->func_stx >> 2;
 		dmae->dst_addr_hi =3D 0;
 		dmae->len =3D (offsetof(struct bnx2x_eth_stats, mac_stx_end) -
 			     sizeof(u32)) >> 2;
@@ -2279,7 +2610,7 @@ static void bnx2x_init_mac_stats(struct bnx2x *bp=
)
=20
 static void bnx2x_init_stats(struct bnx2x *bp)
 {
-	int port =3D bp->port;
+	int port =3D BP_PORT(bp);
=20
 	bp->stats_state =3D STATS_STATE_DISABLE;
 	bp->executer_idx =3D 0;
@@ -2640,8 +2971,6 @@ static void bnx2x_update_net_stats(struct bnx2x *=
bp)
=20
 static void bnx2x_update_stats(struct bnx2x *bp)
 {
-	int i;
-
 	if (!bnx2x_update_storm_stats(bp)) {
=20
 		if (bp->link_vars.mac_type =3D=3D MAC_TYPE_BMAC) {
@@ -2661,6 +2990,7 @@ static void bnx2x_update_stats(struct bnx2x *bp)
 	if (bp->msglevel & NETIF_MSG_TIMER) {
 		struct bnx2x_eth_stats *estats =3D bnx2x_sp(bp, eth_stats);
 		struct net_device_stats *nstats =3D &bp->dev->stats;
+		int i;
=20
 		printk(KERN_DEBUG "%s:\n", bp->dev->name);
 		printk(KERN_DEBUG "  tx avail (%4x)  tx hc idx (%x)"
@@ -2706,7 +3036,7 @@ static void bnx2x_update_stats(struct bnx2x *bp)
 	/* loader */
 	if (bp->executer_idx) {
 		struct dmae_command *dmae =3D &bp->dmae;
-		int port =3D bp->port;
+		int port =3D BP_PORT(bp);
 		int loader_idx =3D port * 8;
=20
 		memset(dmae, 0, sizeof(struct dmae_command));
@@ -2765,8 +3095,8 @@ static void bnx2x_timer(unsigned long data)
 		rc =3D bnx2x_rx_int(fp, 1000);
 	}
=20
-	if (!nomcp) {
-		int port =3D bp->port;
+	if (!BP_NOMCP(bp)) {
+		int func =3D BP_FUNC(bp);
 		u32 drv_pulse;
 		u32 mcp_pulse;
=20
@@ -2774,9 +3104,9 @@ static void bnx2x_timer(unsigned long data)
 		bp->fw_drv_pulse_wr_seq &=3D DRV_PULSE_SEQ_MASK;
 		/* TBD - add SYSTEM_TIME */
 		drv_pulse =3D bp->fw_drv_pulse_wr_seq;
-		SHMEM_WR(bp, func_mb[port].drv_pulse_mb, drv_pulse);
+		SHMEM_WR(bp, func_mb[func].drv_pulse_mb, drv_pulse);
=20
-		mcp_pulse =3D (SHMEM_RD(bp, func_mb[port].mcp_pulse_mb) &
+		mcp_pulse =3D (SHMEM_RD(bp, func_mb[func].mcp_pulse_mb) &
 			     MCP_PULSE_SEQ_MASK);
 		/* The delta between driver pulse and mcp response
 		 * should be 1 (before mcp response) or 0 (after mcp response)
@@ -2806,58 +3136,89 @@ timer_restart:
  * nic init service functions
  */
=20
-static void bnx2x_init_sb(struct bnx2x *bp, struct host_status_block *=
sb,
-			  dma_addr_t mapping, int id)
+static void bnx2x_zero_sb(struct bnx2x *bp, int sb_id)
 {
-	int port =3D bp->port;
-	u64 section;
+	int port =3D BP_PORT(bp);
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
+	int port =3D BP_PORT(bp);
 	int index;
+	u64 section;
=20
 	/* USTORM */
 	section =3D ((u64)mapping) + offsetof(struct host_status_block,
 					    u_status_block);
-	sb->u_status_block.status_block_id =3D id;
+	sb->u_status_block.status_block_id =3D sb_id;
=20
 	REG_WR(bp, BAR_USTRORM_INTMEM +
-	       USTORM_SB_HOST_SB_ADDR_OFFSET(port, id), U64_LO(section));
+	       USTORM_SB_HOST_SB_ADDR_OFFSET(port, sb_id), U64_LO(section));
 	REG_WR(bp, BAR_USTRORM_INTMEM +
-	       ((USTORM_SB_HOST_SB_ADDR_OFFSET(port, id)) + 4),
+	       ((USTORM_SB_HOST_SB_ADDR_OFFSET(port, sb_id)) + 4),
 	       U64_HI(section));
=20
 	for (index =3D 0; index < HC_USTORM_SB_NUM_INDICES; index++)
 		REG_WR16(bp, BAR_USTRORM_INTMEM +
-			 USTORM_SB_HC_DISABLE_OFFSET(port, id, index), 0x1);
+			 USTORM_SB_HC_DISABLE_OFFSET(port, sb_id, index), 1);
=20
 	/* CSTORM */
 	section =3D ((u64)mapping) + offsetof(struct host_status_block,
 					    c_status_block);
-	sb->c_status_block.status_block_id =3D id;
+	sb->c_status_block.status_block_id =3D sb_id;
=20
 	REG_WR(bp, BAR_CSTRORM_INTMEM +
-	       CSTORM_SB_HOST_SB_ADDR_OFFSET(port, id), U64_LO(section));
+	       CSTORM_SB_HOST_SB_ADDR_OFFSET(port, sb_id), U64_LO(section));
 	REG_WR(bp, BAR_CSTRORM_INTMEM +
-	       ((CSTORM_SB_HOST_SB_ADDR_OFFSET(port, id)) + 4),
+	       ((CSTORM_SB_HOST_SB_ADDR_OFFSET(port, sb_id)) + 4),
 	       U64_HI(section));
=20
 	for (index =3D 0; index < HC_CSTORM_SB_NUM_INDICES; index++)
 		REG_WR16(bp, BAR_CSTRORM_INTMEM +
-			 CSTORM_SB_HC_DISABLE_OFFSET(port, id, index), 0x1);
+			 CSTORM_SB_HC_DISABLE_OFFSET(port, sb_id, index), 1);
+
+	bnx2x_ack_sb(bp, sb_id, CSTORM_ID, 0, IGU_INT_ENABLE, 0);
+}
=20
-	bnx2x_ack_sb(bp, id, CSTORM_ID, 0, IGU_INT_ENABLE, 0);
+static void bnx2x_zero_def_sb(struct bnx2x *bp)
+{
+	int func =3D BP_FUNC(bp);
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
=20
 static void bnx2x_init_def_sb(struct bnx2x *bp,
 			      struct host_def_status_block *def_sb,
-			      dma_addr_t mapping, int id)
+			      dma_addr_t mapping, int sb_id)
 {
-	int port =3D bp->port;
+	int port =3D BP_PORT(bp);
+	int func =3D BP_FUNC(bp);
 	int index, val, reg_offset;
 	u64 section;
=20
 	/* ATTN */
 	section =3D ((u64)mapping) + offsetof(struct host_def_status_block,
 					    atten_status_block);
-	def_sb->atten_status_block.status_block_id =3D id;
+	def_sb->atten_status_block.status_block_id =3D sb_id;
=20
 	bp->def_att_idx =3D 0;
 	bp->attn_state =3D 0;
@@ -2865,7 +3226,7 @@ static void bnx2x_init_def_sb(struct bnx2x *bp,
 	reg_offset =3D (port ? MISC_REG_AEU_ENABLE1_FUNC_1_OUT_0 :
 			     MISC_REG_AEU_ENABLE1_FUNC_0_OUT_0);
=20
-	for (index =3D 0; index < 3; index++) {
+	for (index =3D 0; index < MAX_DYNAMIC_ATTN_GRPS; index++) {
 		bp->attn_group[index].sig[0] =3D REG_RD(bp,
 						     reg_offset + 0x10*index);
 		bp->attn_group[index].sig[1] =3D REG_RD(bp,
@@ -2888,116 +3249,123 @@ static void bnx2x_init_def_sb(struct bnx2x *b=
p,
 	reg_offset =3D (port ? HC_REG_ATTN_NUM_P1 : HC_REG_ATTN_NUM_P0);
=20
 	val =3D REG_RD(bp, reg_offset);
-	val |=3D id;
+	val |=3D sb_id;
 	REG_WR(bp, reg_offset, val);
=20
 	/* USTORM */
 	section =3D ((u64)mapping) + offsetof(struct host_def_status_block,
 					    u_def_status_block);
-	def_sb->u_def_status_block.status_block_id =3D id;
+	def_sb->u_def_status_block.status_block_id =3D sb_id;
=20
 	bp->def_u_idx =3D 0;
=20
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
=20
 	for (index =3D 0; index < HC_USTORM_DEF_SB_NUM_INDICES; index++)
 		REG_WR16(bp, BAR_USTRORM_INTMEM +
-			 USTORM_DEF_SB_HC_DISABLE_OFFSET(port, index), 0x1);
+			 USTORM_DEF_SB_HC_DISABLE_OFFSET(func, index), 1);
=20
 	/* CSTORM */
 	section =3D ((u64)mapping) + offsetof(struct host_def_status_block,
 					    c_def_status_block);
-	def_sb->c_def_status_block.status_block_id =3D id;
+	def_sb->c_def_status_block.status_block_id =3D sb_id;
=20
 	bp->def_c_idx =3D 0;
=20
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
=20
 	for (index =3D 0; index < HC_CSTORM_DEF_SB_NUM_INDICES; index++)
 		REG_WR16(bp, BAR_CSTRORM_INTMEM +
-			 CSTORM_DEF_SB_HC_DISABLE_OFFSET(port, index), 0x1);
+			 CSTORM_DEF_SB_HC_DISABLE_OFFSET(func, index), 1);
=20
 	/* TSTORM */
 	section =3D ((u64)mapping) + offsetof(struct host_def_status_block,
 					    t_def_status_block);
-	def_sb->t_def_status_block.status_block_id =3D id;
+	def_sb->t_def_status_block.status_block_id =3D sb_id;
=20
 	bp->def_t_idx =3D 0;
=20
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
=20
 	for (index =3D 0; index < HC_TSTORM_DEF_SB_NUM_INDICES; index++)
 		REG_WR16(bp, BAR_TSTRORM_INTMEM +
-			 TSTORM_DEF_SB_HC_DISABLE_OFFSET(port, index), 0x1);
+			 TSTORM_DEF_SB_HC_DISABLE_OFFSET(func, index), 1);
=20
 	/* XSTORM */
 	section =3D ((u64)mapping) + offsetof(struct host_def_status_block,
 					    x_def_status_block);
-	def_sb->x_def_status_block.status_block_id =3D id;
+	def_sb->x_def_status_block.status_block_id =3D sb_id;
=20
 	bp->def_x_idx =3D 0;
=20
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
=20
 	for (index =3D 0; index < HC_XSTORM_DEF_SB_NUM_INDICES; index++)
 		REG_WR16(bp, BAR_XSTRORM_INTMEM +
-			 XSTORM_DEF_SB_HC_DISABLE_OFFSET(port, index), 0x1);
-
-	bp->stat_pending =3D 0;
+			 XSTORM_DEF_SB_HC_DISABLE_OFFSET(func, index), 1);
=20
-	bnx2x_ack_sb(bp, id, CSTORM_ID, 0, IGU_INT_ENABLE, 0);
+	bnx2x_ack_sb(bp, sb_id, CSTORM_ID, 0, IGU_INT_ENABLE, 0);
 }
=20
 static void bnx2x_update_coalesce(struct bnx2x *bp)
 {
-	int port =3D bp->port;
+	int port =3D BP_PORT(bp);
 	int i;
=20
 	for_each_queue(bp, i) {
+		int sb_id =3D bp->fp[i].sb_id;
=20
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
=20
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
=20
@@ -3005,7 +3373,6 @@ static void bnx2x_init_rx_rings(struct bnx2x *bp)
 {
 	u16 ring_prod;
 	int i, j;
-	int port =3D bp->port;
=20
 	bp->rx_buf_use_size =3D bp->dev->mtu;
=20
@@ -3024,13 +3391,13 @@ static void bnx2x_init_rx_rings(struct bnx2x *b=
p)
 			rx_bd =3D &fp->rx_desc_ring[RX_DESC_CNT * i - 2];
 			rx_bd->addr_hi =3D
 				cpu_to_le32(U64_HI(fp->rx_desc_mapping +
-					   BCM_PAGE_SIZE*(i % NUM_RX_RINGS)));
+					    BCM_PAGE_SIZE*(i % NUM_RX_RINGS)));
 			rx_bd->addr_lo =3D
 				cpu_to_le32(U64_LO(fp->rx_desc_mapping +
-					   BCM_PAGE_SIZE*(i % NUM_RX_RINGS)));
-
+					    BCM_PAGE_SIZE*(i % NUM_RX_RINGS)));
 		}
=20
+		/* CQ ring */
 		for (i =3D 1; i <=3D NUM_RCQ_RINGS; i++) {
 			struct eth_rx_cqe_next_page *nextpg;
=20
@@ -3038,10 +3405,10 @@ static void bnx2x_init_rx_rings(struct bnx2x *b=
p)
 				&fp->rx_comp_ring[RCQ_DESC_CNT * i - 1];
 			nextpg->addr_hi =3D
 				cpu_to_le32(U64_HI(fp->rx_comp_mapping +
-					  BCM_PAGE_SIZE*(i % NUM_RCQ_RINGS)));
+					   BCM_PAGE_SIZE*(i % NUM_RCQ_RINGS)));
 			nextpg->addr_lo =3D
 				cpu_to_le32(U64_LO(fp->rx_comp_mapping +
-					  BCM_PAGE_SIZE*(i % NUM_RCQ_RINGS)));
+					   BCM_PAGE_SIZE*(i % NUM_RCQ_RINGS)));
 		}
=20
 		/* rx completion queue */
@@ -3063,15 +3430,16 @@ static void bnx2x_init_rx_rings(struct bnx2x *b=
p)
 		/* Warning! this will generate an interrupt (to the TSTORM) */
 		/* must only be done when chip is initialized */
 		REG_WR(bp, BAR_TSTRORM_INTMEM +
-		       TSTORM_RCQ_PROD_OFFSET(port, j), ring_prod);
+		       TSTORM_RX_PRODS_OFFSET(BP_PORT(bp), FP_CL_ID(fp)),
+			ring_prod);
 		if (j !=3D 0)
 			continue;
=20
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
@@ -3089,10 +3457,10 @@ static void bnx2x_init_tx_ring(struct bnx2x *bp=
)
=20
 			tx_bd->addr_hi =3D
 				cpu_to_le32(U64_HI(fp->tx_desc_mapping +
-					   BCM_PAGE_SIZE*(i % NUM_TX_RINGS)));
+					    BCM_PAGE_SIZE*(i % NUM_TX_RINGS)));
 			tx_bd->addr_lo =3D
 				cpu_to_le32(U64_LO(fp->tx_desc_mapping +
-					   BCM_PAGE_SIZE*(i % NUM_TX_RINGS)));
+					    BCM_PAGE_SIZE*(i % NUM_TX_RINGS)));
 		}
=20
 		fp->tx_pkt_prod =3D 0;
@@ -3106,7 +3474,7 @@ static void bnx2x_init_tx_ring(struct bnx2x *bp)
=20
 static void bnx2x_init_sp_ring(struct bnx2x *bp)
 {
-	int port =3D bp->port;
+	int func =3D BP_FUNC(bp);
=20
 	spin_lock_init(&bp->spq_lock);
=20
@@ -3116,12 +3484,13 @@ static void bnx2x_init_sp_ring(struct bnx2x *bp=
)
 	bp->spq_prod_bd =3D bp->spq;
 	bp->spq_last_bd =3D bp->spq_prod_bd + MAX_SP_DESC_CNT;
=20
-	REG_WR(bp, BAR_XSTRORM_INTMEM + XSTORM_SPQ_PAGE_BASE_OFFSET(port),
+	REG_WR(bp, XSEM_REG_FAST_MEMORY + XSTORM_SPQ_PAGE_BASE_OFFSET(func),
 	       U64_LO(bp->spq_mapping));
-	REG_WR(bp, BAR_XSTRORM_INTMEM + XSTORM_SPQ_PAGE_BASE_OFFSET(port) + 4=
,
+	REG_WR(bp,
+	       XSEM_REG_FAST_MEMORY + XSTORM_SPQ_PAGE_BASE_OFFSET(func) + 4,
 	       U64_HI(bp->spq_mapping));
=20
-	REG_WR(bp, XSEM_REG_FAST_MEMORY + XSTORM_SPQ_PROD_OFFSET(port),
+	REG_WR(bp, XSEM_REG_FAST_MEMORY + XSTORM_SPQ_PROD_OFFSET(func),
 	       bp->spq_prod_idx);
 }
=20
@@ -3132,6 +3501,7 @@ static void bnx2x_init_context(struct bnx2x *bp)
 	for_each_queue(bp, i) {
 		struct eth_context *context =3D bnx2x_sp(bp, context[i].eth);
 		struct bnx2x_fastpath *fp =3D &bp->fp[i];
+		int sb_id =3D FP_SB_ID(fp);
=20
 		context->xstorm_st_context.tx_bd_page_base_hi =3D
 						U64_HI(fp->tx_desc_mapping);
@@ -3141,26 +3511,25 @@ static void bnx2x_init_context(struct bnx2x *bp=
)
 						U64_HI(fp->tx_prods_mapping);
 		context->xstorm_st_context.db_data_addr_lo =3D
 						U64_LO(fp->tx_prods_mapping);
-
-		context->ustorm_st_context.rx_bd_page_base_hi =3D
+		context->xstorm_st_context.statistics_data =3D (BP_CL_ID(bp) |
+				XSTORM_ETH_ST_CONTEXT_STATISTICS_ENABLE);
+
+		context->ustorm_st_context.common.sb_index_numbers =3D
+						BNX2X_RX_SB_INDEX_NUM;
+		context->ustorm_st_context.common.clientId =3D FP_CL_ID(fp);
+		context->ustorm_st_context.common.status_block_id =3D sb_id;
+		context->ustorm_st_context.common.flags =3D
+			USTORM_ETH_ST_CONTEXT_CONFIG_ENABLE_MC_ALIGNMENT;
+		context->ustorm_st_context.common.mc_alignment_size =3D 64;
+		context->ustorm_st_context.common.bd_buff_size =3D
+						bp->rx_buf_use_size;
+		context->ustorm_st_context.common.bd_page_base_hi =3D
 						U64_HI(fp->rx_desc_mapping);
-		context->ustorm_st_context.rx_bd_page_base_lo =3D
+		context->ustorm_st_context.common.bd_page_base_lo =3D
 						U64_LO(fp->rx_desc_mapping);
-		context->ustorm_st_context.status_block_id =3D i;
-		context->ustorm_st_context.sb_index_number =3D
-						HC_INDEX_U_ETH_RX_CQ_CONS;
-		context->ustorm_st_context.rcq_base_address_hi =3D
-						U64_HI(fp->rx_comp_mapping);
-		context->ustorm_st_context.rcq_base_address_lo =3D
-						U64_LO(fp->rx_comp_mapping);
-		context->ustorm_st_context.flags =3D
-				USTORM_ETH_ST_CONTEXT_ENABLE_MC_ALIGNMENT;
-		context->ustorm_st_context.mc_alignment_size =3D 64;
-		context->ustorm_st_context.num_rss =3D bp->num_queues;
-
 		context->cstorm_st_context.sb_index_number =3D
 						HC_INDEX_C_ETH_TX_CQ_CONS;
-		context->cstorm_st_context.status_block_id =3D i;
+		context->cstorm_st_context.status_block_id =3D sb_id;
=20
 		context->xstorm_ag_context.cdu_reserved =3D
 			CDU_RSRVD_VALUE_TYPE_A(HW_CID(bp, i),
@@ -3175,14 +3544,16 @@ static void bnx2x_init_context(struct bnx2x *bp=
)
=20
 static void bnx2x_init_ind_table(struct bnx2x *bp)
 {
-	int port =3D bp->port;
+	int port =3D BP_PORT(bp);
 	int i;
=20
 	if (!is_multi(bp))
 		return;
=20
+	DP(NETIF_MSG_IFUP, "Initializing indirection table\n");
 	for (i =3D 0; i < TSTORM_INDIRECTION_TABLE_SIZE; i++)
-		REG_WR8(bp, TSTORM_INDIRECTION_TABLE_OFFSET(port) + i,
+		REG_WR8(bp, BAR_TSTRORM_INTMEM +
+			TSTORM_INDIRECTION_TABLE_OFFSET(port) + i,
 			i % bp->num_queues);
=20
 	REG_WR(bp, PRS_REG_A_PRSU_20, 0xf);
@@ -3190,77 +3561,74 @@ static void bnx2x_init_ind_table(struct bnx2x *=
bp)
=20
 static void bnx2x_set_client_config(struct bnx2x *bp)
 {
-#ifdef BCM_VLAN
-	int mode =3D bp->rx_mode;
-#endif
-	int i, port =3D bp->port;
 	struct tstorm_eth_client_config tstorm_client =3D {0};
+	int port =3D BP_PORT(bp);
+	int i;
=20
-	tstorm_client.mtu =3D bp->dev->mtu;
+	tstorm_client.mtu =3D bp->dev->mtu + ETH_OVREHEAD;
 	tstorm_client.statistics_counter_id =3D 0;
 	tstorm_client.config_flags =3D
 				TSTORM_ETH_CLIENT_CONFIG_STATSITICS_ENABLE;
 #ifdef BCM_VLAN
-	if (mode && bp->vlgrp) {
+	if (bp->rx_mode && bp->vlgrp) {
 		tstorm_client.config_flags |=3D
 				TSTORM_ETH_CLIENT_CONFIG_VLAN_REMOVAL_ENABLE;
 		DP(NETIF_MSG_IFUP, "vlan removal enabled\n");
 	}
 #endif
-	if (mode !=3D BNX2X_RX_MODE_PROMISC)
-		tstorm_client.drop_flags =3D
-				TSTORM_ETH_CLIENT_CONFIG_DROP_MAC_ERR;
=20
 	for_each_queue(bp, i) {
 		REG_WR(bp, BAR_TSTRORM_INTMEM +
-		       TSTORM_CLIENT_CONFIG_OFFSET(port, i),
-		       ((u32 *)&tstorm_client)[0]);
+			TSTORM_CLIENT_CONFIG_OFFSET(port, bp->fp[i].cl_id),
+			((u32 *)&tstorm_client)[0]);
 		REG_WR(bp, BAR_TSTRORM_INTMEM +
-		       TSTORM_CLIENT_CONFIG_OFFSET(port, i) + 4,
-		       ((u32 *)&tstorm_client)[1]);
+			TSTORM_CLIENT_CONFIG_OFFSET(port, bp->fp[i].cl_id) + 4,
+			((u32 *)&tstorm_client)[1]);
 	}
=20
-/*	DP(NETIF_MSG_IFUP, "tstorm_client: 0x%08x 0x%08x\n",
-	   ((u32 *)&tstorm_client)[0], ((u32 *)&tstorm_client)[1]); */
+	DP(BNX2X_MSG_OFF, "tstorm_client: 0x%08x 0x%08x\n",
+		((u32 *)&tstorm_client)[0], ((u32 *)&tstorm_client)[1]);
 }
=20
 static void bnx2x_set_storm_rx_mode(struct bnx2x *bp)
 {
-	int mode =3D bp->rx_mode;
-	int port =3D bp->port;
 	struct tstorm_eth_mac_filter_config tstorm_mac_filter =3D {0};
+	int mode =3D bp->rx_mode;
+	int mask =3D (1 << BP_L_ID(bp));
+	int func =3D BP_FUNC(bp);
 	int i;
=20
 	DP(NETIF_MSG_RX_STATUS, "rx mode is %d\n", mode);
=20
 	switch (mode) {
 	case BNX2X_RX_MODE_NONE: /* no Rx */
-		tstorm_mac_filter.ucast_drop_all =3D 1;
-		tstorm_mac_filter.mcast_drop_all =3D 1;
-		tstorm_mac_filter.bcast_drop_all =3D 1;
+		tstorm_mac_filter.ucast_drop_all =3D mask;
+		tstorm_mac_filter.mcast_drop_all =3D mask;
+		tstorm_mac_filter.bcast_drop_all =3D mask;
 		break;
 	case BNX2X_RX_MODE_NORMAL:
-		tstorm_mac_filter.bcast_accept_all =3D 1;
+		tstorm_mac_filter.bcast_accept_all =3D mask;
 		break;
 	case BNX2X_RX_MODE_ALLMULTI:
-		tstorm_mac_filter.mcast_accept_all =3D 1;
-		tstorm_mac_filter.bcast_accept_all =3D 1;
+		tstorm_mac_filter.mcast_accept_all =3D mask;
+		tstorm_mac_filter.bcast_accept_all =3D mask;
 		break;
 	case BNX2X_RX_MODE_PROMISC:
-		tstorm_mac_filter.ucast_accept_all =3D 1;
-		tstorm_mac_filter.mcast_accept_all =3D 1;
-		tstorm_mac_filter.bcast_accept_all =3D 1;
+		tstorm_mac_filter.ucast_accept_all =3D mask;
+		tstorm_mac_filter.mcast_accept_all =3D mask;
+		tstorm_mac_filter.bcast_accept_all =3D mask;
 		break;
 	default:
-		BNX2X_ERR("bad rx mode (%d)\n", mode);
+		BNX2X_ERR("BAD rx mode (%d)\n", mode);
+		break;
 	}
=20
 	for (i =3D 0; i < sizeof(struct tstorm_eth_mac_filter_config)/4; i++)=
 {
 		REG_WR(bp, BAR_TSTRORM_INTMEM +
-		       TSTORM_MAC_FILTER_CONFIG_OFFSET(port) + i * 4,
+		       TSTORM_MAC_FILTER_CONFIG_OFFSET(func) + i * 4,
 		       ((u32 *)&tstorm_mac_filter)[i]);
=20
-/*      	DP(NETIF_MSG_IFUP, "tstorm_mac_filter[%d]: 0x%08x\n", i,
+/*		DP(NETIF_MSG_IFUP, "tstorm_mac_filter[%d]: 0x%08x\n", i,
 		   ((u32 *)&tstorm_mac_filter)[i]); */
 	}
=20
@@ -3270,26 +3638,30 @@ static void bnx2x_set_storm_rx_mode(struct bnx2=
x *bp)
=20
 static void bnx2x_init_internal(struct bnx2x *bp)
 {
-	int port =3D bp->port;
 	struct tstorm_eth_function_common_config tstorm_config =3D {0};
 	struct stats_indication_flags stats_flags =3D {0};
+	int port =3D BP_PORT(bp);
+	int func =3D BP_FUNC(bp);
+	int i;
=20
 	if (is_multi(bp)) {
 		tstorm_config.config_flags =3D MULTI_FLAGS;
 		tstorm_config.rss_result_mask =3D MULTI_MASK;
 	}
=20
+	tstorm_config.leading_client_id =3D BP_L_ID(bp);
+
 	REG_WR(bp, BAR_TSTRORM_INTMEM +
-	       TSTORM_FUNCTION_COMMON_CONFIG_OFFSET(port),
+	       TSTORM_FUNCTION_COMMON_CONFIG_OFFSET(func),
 	       (*(u32 *)&tstorm_config));
=20
-/*      DP(NETIF_MSG_IFUP, "tstorm_config: 0x%08x\n",
+/*	DP(NETIF_MSG_IFUP, "tstorm_config: 0x%08x\n",
 	   (*(u32 *)&tstorm_config)); */
=20
 	bp->rx_mode =3D BNX2X_RX_MODE_NONE; /* no rx until link is up */
 	bnx2x_set_storm_rx_mode(bp);
=20
-	stats_flags.collect_eth =3D cpu_to_le32(1);
+	stats_flags.collect_eth =3D 1;
=20
 	REG_WR(bp, BAR_XSTRORM_INTMEM + XSTORM_STATS_FLAGS_OFFSET(port),
 	       ((u32 *)&stats_flags)[0]);
@@ -3306,8 +3678,28 @@ static void bnx2x_init_internal(struct bnx2x *bp=
)
 	REG_WR(bp, BAR_CSTRORM_INTMEM + CSTORM_STATS_FLAGS_OFFSET(port) + 4,
 	       ((u32 *)&stats_flags)[1]);
=20
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
+			 XSTORM_E1HOV_OFFSET(func), bp->e1hovl);
+	}
+
+	/* Zero this manualy as it's initialization is
+		   currently missing in the initTool */
+	for (i =3D 0; i < USTORM_AGG_DATA_SIZE >> 2; i++)
+		REG_WR(bp, BAR_USTRORM_INTMEM +
+			USTORM_AGG_DATA_OFFSET + 4*i, 0);
 }
=20
 static void bnx2x_nic_init(struct bnx2x *bp)
@@ -3317,15 +3709,20 @@ static void bnx2x_nic_init(struct bnx2x *bp)
 	for_each_queue(bp, i) {
 		struct bnx2x_fastpath *fp =3D &bp->fp[i];
=20
+		fp->bp =3D bp;
 		fp->state =3D BNX2X_FP_STATE_CLOSED;
-		DP(NETIF_MSG_IFUP, "bnx2x_init_sb(%p,%p,%d);\n",
-		   bp, fp->status_blk, i);
 		fp->index =3D i;
-		bnx2x_init_sb(bp, fp->status_blk, fp->status_blk_mapping, i);
+		fp->cl_id =3D BP_L_ID(bp) + i;
+		fp->sb_id =3D fp->cl_id;
+		DP(NETIF_MSG_IFUP,
+		   "bnx2x_init_sb(%p,%p) index %d  cl_id %d  sb %d\n",
+		   bp, fp->status_blk, i, FP_CL_ID(fp), FP_SB_ID(fp));
+		bnx2x_init_sb(bp, FP_SB_ID(fp), fp->status_blk,
+			      fp->status_blk_mapping);
 	}
=20
 	bnx2x_init_def_sb(bp, bp->def_status_blk,
-			  bp->def_status_blk_mapping, 0x10);
+			  bp->def_status_blk_mapping, DEF_SB_ID);
 	bnx2x_update_coalesce(bp);
 	bnx2x_init_rx_rings(bp);
 	bnx2x_init_tx_ring(bp);
@@ -3335,7 +3732,6 @@ static void bnx2x_nic_init(struct bnx2x *bp)
 	bnx2x_init_stats(bp);
 	bnx2x_init_ind_table(bp);
 	bnx2x_int_enable(bp);
-
 }
=20
 /* end of nic init */
@@ -3373,7 +3769,7 @@ gunzip_nomem2:
=20
 gunzip_nomem1:
 	printk(KERN_ERR PFX "%s: Cannot allocate firmware buffer for"
-	       " uncompression\n", bp->dev->name);
+	       " un-compression\n", bp->dev->name);
 	return -ENOMEM;
 }
=20
@@ -3401,7 +3797,7 @@ static int bnx2x_gunzip(struct bnx2x *bp, u8 *zbu=
f, int len)
=20
 	n =3D 10;
=20
-#define FNAME   			0x8
+#define FNAME				0x8
=20
 	if (zbuf[3] & FNAME)
 		while ((zbuf[n++] !=3D 0) && (n < len));
@@ -3438,41 +3834,25 @@ static int bnx2x_gunzip(struct bnx2x *bp, u8 *z=
buf, int len)
 /* nic load/unload */
=20
 /*
- * general service functions
+ * General service functions
  */
=20
 /* send a NIG loopback debug packet */
 static void bnx2x_lb_pckt(struct bnx2x *bp)
 {
-#ifdef USE_DMAE
 	u32 wb_write[3];
-#endif
=20
 	/* Ethernet source and destination addresses */
-#ifdef USE_DMAE
 	wb_write[0] =3D 0x55555555;
 	wb_write[1] =3D 0x55555555;
-	wb_write[2] =3D 0x20;     	/* SOP */
+	wb_write[2] =3D 0x20;		/* SOP */
 	REG_WR_DMAE(bp, NIG_REG_DEBUG_PACKET_LB, wb_write, 3);
-#else
-	REG_WR_IND(bp, NIG_REG_DEBUG_PACKET_LB, 0x55555555);
-	REG_WR_IND(bp, NIG_REG_DEBUG_PACKET_LB + 4, 0x55555555);
-	/* SOP */
-	REG_WR_IND(bp, NIG_REG_DEBUG_PACKET_LB + 8, 0x20);
-#endif
=20
 	/* NON-IP protocol */
-#ifdef USE_DMAE
 	wb_write[0] =3D 0x09000000;
 	wb_write[1] =3D 0x55555555;
-	wb_write[2] =3D 0x10;     	/* EOP, eop_bvalid =3D 0 */
+	wb_write[2] =3D 0x10;		/* EOP, eop_bvalid =3D 0 */
 	REG_WR_DMAE(bp, NIG_REG_DEBUG_PACKET_LB, wb_write, 3);
-#else
-	REG_WR_IND(bp, NIG_REG_DEBUG_PACKET_LB, 0x09000000);
-	REG_WR_IND(bp, NIG_REG_DEBUG_PACKET_LB + 4, 0x55555555);
-	/* EOP, eop_bvalid =3D 0 */
-	REG_WR_IND(bp, NIG_REG_DEBUG_PACKET_LB + 8, 0x10);
-#endif
 }
=20
 /* some of the internal memories
@@ -3510,13 +3890,9 @@ static int bnx2x_int_mem_test(struct bnx2x *bp)
 	/* Wait until NIG register shows 1 packet of size 0x10 */
 	count =3D 1000 * factor;
 	while (count) {
-#ifdef BNX2X_DMAE_RD
+
 		bnx2x_read_dmae(bp, NIG_REG_STAT2_BRB_OCTET, 2);
 		val =3D *bnx2x_sp(bp, wb_data[0]);
-#else
-		val =3D REG_RD(bp, NIG_REG_STAT2_BRB_OCTET);
-		REG_RD(bp, NIG_REG_STAT2_BRB_OCTET + 4);
-#endif
 		if (val =3D=3D 0x10)
 			break;
=20
@@ -3532,7 +3908,6 @@ static int bnx2x_int_mem_test(struct bnx2x *bp)
 	count =3D 1000 * factor;
 	while (count) {
 		val =3D REG_RD(bp, PRS_REG_NUM_OF_PACKETS);
-
 		if (val =3D=3D 1)
 			break;
=20
@@ -3545,9 +3920,9 @@ static int bnx2x_int_mem_test(struct bnx2x *bp)
 	}
=20
 	/* Reset and init BRB, PRS */
-	REG_WR(bp, GRCBASE_MISC + MISC_REGISTERS_RESET_REG_1_CLEAR, 0x3);
+	REG_WR(bp, GRCBASE_MISC + MISC_REGISTERS_RESET_REG_1_CLEAR, 0x03);
 	msleep(50);
-	REG_WR(bp, GRCBASE_MISC + MISC_REGISTERS_RESET_REG_1_SET, 0x3);
+	REG_WR(bp, GRCBASE_MISC + MISC_REGISTERS_RESET_REG_1_SET, 0x03);
 	msleep(50);
 	bnx2x_init_block(bp, BRB1_COMMON_START, BRB1_COMMON_END);
 	bnx2x_init_block(bp, PRS_COMMON_START, PRS_COMMON_END);
@@ -3571,13 +3946,9 @@ static int bnx2x_int_mem_test(struct bnx2x *bp)
 	   packets of size 11*0x10 =3D 0xb0 */
 	count =3D 1000 * factor;
 	while (count) {
-#ifdef BNX2X_DMAE_RD
+
 		bnx2x_read_dmae(bp, NIG_REG_STAT2_BRB_OCTET, 2);
 		val =3D *bnx2x_sp(bp, wb_data[0]);
-#else
-		val =3D REG_RD(bp, NIG_REG_STAT2_BRB_OCTET);
-		REG_RD(bp, NIG_REG_STAT2_BRB_OCTET + 4);
-#endif
 		if (val =3D=3D 0xb0)
 			break;
=20
@@ -3647,85 +4018,108 @@ static void enable_blocks_attention(struct bnx=
2x *bp)
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
=20
-static int bnx2x_function_init(struct bnx2x *bp, int mode)
-{
-	int func =3D bp->port;
-	int port =3D func ? PORT1 : PORT0;
-	u32 val, i;
-#ifdef USE_DMAE
-	u32 wb_write[2];
+#ifdef BNX2X_EXTRA_DEBUG
+static void enable_blocks_parity(struct bnx2x *bp)
+{
+	REG_WR(bp, PXP_REG_PXP_PRTY_MASK, 0x80000);	/* bit 19 masked */
+	REG_WR(bp, PXP2_REG_PXP2_PRTY_MASK_0, 0xfff40020);/* bit 5,18,20-31 *=
/
+	REG_WR(bp, PXP2_REG_PXP2_PRTY_MASK_1, 0x20);	/* bit 5 */
+	REG_WR(bp, QM_REG_QM_PRTY_MASK, 0x0);
+	REG_WR(bp, DORQ_REG_DORQ_PRTY_MASK, 0x0);
+	REG_WR(bp, GRCBASE_UPB + PB_REG_PB_PRTY_MASK, 0x0);
+	REG_WR(bp, GRCBASE_XPB + PB_REG_PB_PRTY_MASK, 0x0);
+	REG_WR(bp, SRC_REG_SRC_PRTY_MASK, 0x4);		/* bit 2 */
+	REG_WR(bp, CDU_REG_CDU_PRTY_MASK, 0x0);
+	REG_WR(bp, CFC_REG_CFC_PRTY_MASK, 0x0);
+	REG_WR(bp, HC_REG_HC_PRTY_MASK, 0x0);
+	REG_WR(bp, MISC_REG_MISC_PRTY_MASK, 0x0);
+	REG_WR(bp, DBG_REG_DBG_PRTY_MASK, 0x0);
+	REG_WR(bp, DMAE_REG_DMAE_PRTY_MASK, 0x0);
+	REG_WR(bp, BRB1_REG_BRB1_PRTY_MASK, 0x0);
+	REG_WR(bp, PRS_REG_PRS_PRTY_MASK, 0x0);
+	REG_WR(bp, TSDM_REG_TSDM_PRTY_MASK, 0x8);	/* bit 3 */
+	REG_WR(bp, CSDM_REG_CSDM_PRTY_MASK, 0x8);	/* bit 3 */
+	REG_WR(bp, USDM_REG_USDM_PRTY_MASK, 0x28);	/* bit 3,5 */
+	REG_WR(bp, XSDM_REG_XSDM_PRTY_MASK, 0x8);	/* bit 3 */
+	REG_WR(bp, TSEM_REG_TSEM_PRTY_MASK_0, 0x0);
+	REG_WR(bp, TSEM_REG_TSEM_PRTY_MASK_1, 0x0);
+	REG_WR(bp, USEM_REG_USEM_PRTY_MASK_0, 0x0);
+	REG_WR(bp, USEM_REG_USEM_PRTY_MASK_1, 0x0);
+	REG_WR(bp, CSEM_REG_CSEM_PRTY_MASK_0, 0x0);
+	REG_WR(bp, CSEM_REG_CSEM_PRTY_MASK_1, 0x0);
+	REG_WR(bp, XSEM_REG_XSEM_PRTY_MASK_0, 0x0);
+	REG_WR(bp, XSEM_REG_XSEM_PRTY_MASK_1, 0x0);
+}
 #endif
=20
-	DP(BNX2X_MSG_MCP, "function is %d  mode is %x\n", func, mode);
-	if ((func !=3D 0) && (func !=3D 1)) {
-		BNX2X_ERR("BAD function number (%d)\n", func);
-		return -ENODEV;
-	}
+static int bnx2x_init_common(struct bnx2x *bp)
+{
+	u32 val, i;
=20
-	bnx2x_gunzip_init(bp);
+	DP(BNX2X_MSG_MCP, "starting common init  func %d\n", BP_FUNC(bp));
=20
-	if (mode & 0x1) {       /* init common */
-		DP(BNX2X_MSG_MCP, "starting common init  func %d  mode %x\n",
-		   func, mode);
-		REG_WR(bp, GRCBASE_MISC + MISC_REGISTERS_RESET_REG_1_SET,
-		       0xffffffff);
-		REG_WR(bp, GRCBASE_MISC + MISC_REGISTERS_RESET_REG_2_SET,
-		       0xfffc);
-		bnx2x_init_block(bp, MISC_COMMON_START, MISC_COMMON_END);
+	REG_WR(bp, GRCBASE_MISC + MISC_REGISTERS_RESET_REG_1_SET, 0xffffffff)=
;
+	REG_WR(bp, GRCBASE_MISC + MISC_REGISTERS_RESET_REG_2_SET, 0xfffc);
=20
-		REG_WR(bp, MISC_REG_LCPLL_CTRL_REG_2, 0x100);
-		msleep(30);
-		REG_WR(bp, MISC_REG_LCPLL_CTRL_REG_2, 0x0);
+	bnx2x_init_block(bp, MISC_COMMON_START, MISC_COMMON_END);
+	if (CHIP_IS_E1H(bp))
+		REG_WR(bp, MISC_REG_E1HMF_MODE, IS_E1HMF(bp));
=20
-		bnx2x_init_block(bp, PXP_COMMON_START, PXP_COMMON_END);
-		bnx2x_init_block(bp, PXP2_COMMON_START, PXP2_COMMON_END);
+	REG_WR(bp, MISC_REG_LCPLL_CTRL_REG_2, 0x100);
+	msleep(30);
+	REG_WR(bp, MISC_REG_LCPLL_CTRL_REG_2, 0x0);
=20
-		bnx2x_init_pxp(bp);
+	bnx2x_init_block(bp, PXP_COMMON_START, PXP_COMMON_END);
+	if (CHIP_IS_E1(bp)) {
+		/* enable HW interrupt from PXP on USDM overflow
+		   bit 16 on INT_MASK_0 */
+		REG_WR(bp, PXP_REG_PXP_INT_MASK_0, 0);
+	}
=20
-		if (CHIP_REV(bp) =3D=3D CHIP_REV_Ax) {
-			/* enable HW interrupt from PXP on USDM
-			   overflow bit 16 on INT_MASK_0 */
-			REG_WR(bp, PXP_REG_PXP_INT_MASK_0, 0);
-		}
+	bnx2x_init_block(bp, PXP2_COMMON_START, PXP2_COMMON_END);
+	bnx2x_init_pxp(bp);
=20
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
=20
 #ifndef BCM_ISCSI
@@ -3735,90 +4129,103 @@ static int bnx2x_function_init(struct bnx2x *b=
p, int mode)
=20
 		REG_WR(bp, PXP2_REG_RQ_CDU_P_SIZE, 5);
 #ifdef BCM_ISCSI
-		REG_WR(bp, PXP2_REG_RQ_TM_P_SIZE, 5);
-		REG_WR(bp, PXP2_REG_RQ_QM_P_SIZE, 5);
-		REG_WR(bp, PXP2_REG_RQ_SRC_P_SIZE, 5);
+	REG_WR(bp, PXP2_REG_RQ_TM_P_SIZE, 5);
+	REG_WR(bp, PXP2_REG_RQ_QM_P_SIZE, 5);
+	REG_WR(bp, PXP2_REG_RQ_SRC_P_SIZE, 5);
 #endif
=20
-		bnx2x_init_block(bp, DMAE_COMMON_START, DMAE_COMMON_END);
+	if (CHIP_REV_IS_FPGA(bp) && CHIP_IS_E1H(bp))
+		REG_WR(bp, PXP2_REG_PGL_TAGS_LIMIT, 0x1);
=20
-		/* let the HW do it's magic ... */
-		msleep(100);
-		/* finish PXP init
-		   (can be moved up if we want to use the DMAE) */
-		val =3D REG_RD(bp, PXP2_REG_RQ_CFG_DONE);
-		if (val !=3D 1) {
-			BNX2X_ERR("PXP2 CFG failed\n");
-			return -EBUSY;
-		}
+	/* let the HW do it's magic ... */
+	msleep(100);
+	/* finish PXP init */
+	val =3D REG_RD(bp, PXP2_REG_RQ_CFG_DONE);
+	if (val !=3D 1) {
+		BNX2X_ERR("PXP2 CFG failed\n");
+		return -EBUSY;
+	}
+	val =3D REG_RD(bp, PXP2_REG_RD_INIT_DONE);
+	if (val !=3D 1) {
+		BNX2X_ERR("PXP2 RD_INIT failed\n");
+		return -EBUSY;
+	}
=20
-		val =3D REG_RD(bp, PXP2_REG_RD_INIT_DONE);
-		if (val !=3D 1) {
-			BNX2X_ERR("PXP2 RD_INIT failed\n");
-			return -EBUSY;
-		}
+	REG_WR(bp, PXP2_REG_RQ_DISABLE_INPUTS, 0);
+	REG_WR(bp, PXP2_REG_RD_DISABLE_INPUTS, 0);
=20
-		REG_WR(bp, PXP2_REG_RQ_DISABLE_INPUTS, 0);
-		REG_WR(bp, PXP2_REG_RD_DISABLE_INPUTS, 0);
+	bnx2x_init_block(bp, DMAE_COMMON_START, DMAE_COMMON_END);
=20
-		bnx2x_init_fill(bp, TSEM_REG_PRAM, 0, 8);
+	/* clean the DMAE memory */
+	bp->dmae_ready =3D 1;
+	bnx2x_init_fill(bp, TSEM_REG_PRAM, 0, 8);
=20
-		bnx2x_init_block(bp, TCM_COMMON_START, TCM_COMMON_END);
-		bnx2x_init_block(bp, UCM_COMMON_START, UCM_COMMON_END);
-		bnx2x_init_block(bp, CCM_COMMON_START, CCM_COMMON_END);
-		bnx2x_init_block(bp, XCM_COMMON_START, XCM_COMMON_END);
+	bnx2x_init_block(bp, TCM_COMMON_START, TCM_COMMON_END);
+	bnx2x_init_block(bp, UCM_COMMON_START, UCM_COMMON_END);
+	bnx2x_init_block(bp, CCM_COMMON_START, CCM_COMMON_END);
+	bnx2x_init_block(bp, XCM_COMMON_START, XCM_COMMON_END);
=20
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
=20
 #ifdef BCM_ISCSI
-		bnx2x_init_block(bp, TIMERS_COMMON_START, TIMERS_COMMON_END);
+	bnx2x_init_block(bp, TIMERS_COMMON_START, TIMERS_COMMON_END);
 #endif
-		bnx2x_init_block(bp, DQ_COMMON_START, DQ_COMMON_END);
-		REG_WR(bp, DORQ_REG_DPM_CID_OFST, BCM_PAGE_BITS);
-		if (CHIP_REV(bp) =3D=3D CHIP_REV_Ax) {
-			/* enable hw interrupt from doorbell Q */
-			REG_WR(bp, DORQ_REG_DORQ_INT_MASK, 0);
-		}
=20
-		bnx2x_init_block(bp, BRB1_COMMON_START, BRB1_COMMON_END);
+	bnx2x_init_block(bp, DQ_COMMON_START, DQ_COMMON_END);
+	REG_WR(bp, DORQ_REG_DPM_CID_OFST, BCM_PAGE_BITS);
+	if (!CHIP_REV_IS_SLOW(bp)) {
+		/* enable hw interrupt from doorbell Q */
+		REG_WR(bp, DORQ_REG_DORQ_INT_MASK, 0);
+	}
=20
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
=20
-		bnx2x_init_block(bp, PRS_COMMON_START, PRS_COMMON_END);
+	bnx2x_init_block(bp, PRS_COMMON_START, PRS_COMMON_END);
+	if (CHIP_IS_E1H(bp))
+		REG_WR(bp, PRS_REG_E1HOV_MODE, IS_E1HMF(bp));
=20
-		bnx2x_init_block(bp, TSDM_COMMON_START, TSDM_COMMON_END);
-		bnx2x_init_block(bp, CSDM_COMMON_START, CSDM_COMMON_END);
-		bnx2x_init_block(bp, USDM_COMMON_START, USDM_COMMON_END);
-		bnx2x_init_block(bp, XSDM_COMMON_START, XSDM_COMMON_END);
+	bnx2x_init_block(bp, TSDM_COMMON_START, TSDM_COMMON_END);
+	bnx2x_init_block(bp, CSDM_COMMON_START, CSDM_COMMON_END);
+	bnx2x_init_block(bp, USDM_COMMON_START, USDM_COMMON_END);
+	bnx2x_init_block(bp, XSDM_COMMON_START, XSDM_COMMON_END);
=20
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
@@ -3827,157 +4234,144 @@ static int bnx2x_function_init(struct bnx2x *=
bp, int mode)
 				STORM_INTMEM_SIZE_E1);
 		bnx2x_init_fill(bp, USTORM_INTMEM_ADDR, 0,
 				STORM_INTMEM_SIZE_E1);
+	}
=20
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
-		for (i =3D SRC_REG_KEYRSS0_0; i <=3D SRC_REG_KEYRSS1_9; i +=3D 4) {
-			REG_WR(bp, i, 0xc0cac01a);
-			/* TODO: replace with something meaningful */
-		}
-		/* SRCH COMMON comes here */
-		REG_WR(bp, SRC_REG_SOFT_RST, 0);
-
-		if (sizeof(union cdu_context) !=3D 1024) {
-			/* we currently assume that a context is 1024 bytes */
-			printk(KERN_ALERT PFX "please adjust the size of"
-			       " cdu_context(%ld)\n",
-			       (long)sizeof(union cdu_context));
-		}
-		val =3D (4 << 24) + (0 << 12) + 1024;
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
=20
-		if (CHIP_REV_IS_SLOW(bp))
-			msleep(200);
+	/* sync semi rtc */
+	REG_WR(bp, GRCBASE_MISC + MISC_REGISTERS_RESET_REG_1_CLEAR,
+	       0x80000000);
+	REG_WR(bp, GRCBASE_MISC + MISC_REGISTERS_RESET_REG_1_SET,
+	       0x80000000);
=20
-		/* finish CFC init */
-		val =3D REG_RD(bp, CFC_REG_LL_INIT_DONE);
-		if (val !=3D 1) {
-			BNX2X_ERR("CFC LL_INIT failed\n");
-			return -EBUSY;
-		}
+	bnx2x_init_block(bp, UPB_COMMON_START, UPB_COMMON_END);
+	bnx2x_init_block(bp, XPB_COMMON_START, XPB_COMMON_END);
+	bnx2x_init_block(bp, PBF_COMMON_START, PBF_COMMON_END);
=20
-		val =3D REG_RD(bp, CFC_REG_AC_INIT_DONE);
-		if (val !=3D 1) {
-			BNX2X_ERR("CFC AC_INIT failed\n");
-			return -EBUSY;
-		}
+	REG_WR(bp, SRC_REG_SOFT_RST, 1);
+	for (i =3D SRC_REG_KEYRSS0_0; i <=3D SRC_REG_KEYRSS1_9; i +=3D 4) {
+		REG_WR(bp, i, 0xc0cac01a);
+		/* TODO: replace with something meaningful */
+	}
+	if (CHIP_IS_E1H(bp))
+		bnx2x_init_block(bp, SRCH_COMMON_START, SRCH_COMMON_END);
+	REG_WR(bp, SRC_REG_SOFT_RST, 0);
=20
-		val =3D REG_RD(bp, CFC_REG_CAM_INIT_DONE);
-		if (val !=3D 1) {
-			BNX2X_ERR("CFC CAM_INIT failed\n");
-			return -EBUSY;
-		}
+	if (sizeof(union cdu_context) !=3D 1024)
+		/* we currently assume that a context is 1024 bytes */
+		printk(KERN_ALERT PFX "please adjust the size of"
+		       " cdu_context(%ld)\n", (long)sizeof(union cdu_context));
=20
-		REG_WR(bp, CFC_REG_DEBUG0, 0);
+	bnx2x_init_block(bp, CDU_COMMON_START, CDU_COMMON_END);
+	val =3D (4 << 24) + (0 << 12) + 1024;
+	REG_WR(bp, CDU_REG_CDU_GLOBAL_PARAMS, val);
+	if (CHIP_IS_E1(bp)) {
+		/* !!! fix pxp client crdit until excel update */
+		REG_WR(bp, CDU_REG_CDU_DEBUG, 0x264);
+		REG_WR(bp, CDU_REG_CDU_DEBUG, 0);
+	}
=20
-		/* read NIG statistic
-		   to see if this is our first up since powerup */
-#ifdef BNX2X_DMAE_RD
-		bnx2x_read_dmae(bp, NIG_REG_STAT2_BRB_OCTET, 2);
-		val =3D *bnx2x_sp(bp, wb_data[0]);
-#else
-		val =3D REG_RD(bp, NIG_REG_STAT2_BRB_OCTET);
-		REG_RD(bp, NIG_REG_STAT2_BRB_OCTET + 4);
-#endif
-		/* do internal memory self test */
-		if ((val =3D=3D 0) && bnx2x_int_mem_test(bp)) {
-			BNX2X_ERR("internal mem selftest failed\n");
-			return -EBUSY;
-		}
+	bnx2x_init_block(bp, CFC_COMMON_START, CFC_COMMON_END);
+	REG_WR(bp, CFC_REG_INIT_REG, 0x7FF);
=20
-		/* clear PXP2 attentions */
-		REG_RD(bp, PXP2_REG_PXP2_INT_STS_CLR);
+	bnx2x_init_block(bp, HC_COMMON_START, HC_COMMON_END);
+	bnx2x_init_block(bp, MISC_AEU_COMMON_START, MISC_AEU_COMMON_END);
=20
-		enable_blocks_attention(bp);
-		/* enable_blocks_parity(bp); */
+	/* PXPCS COMMON comes here */
+	/* Reset PCIE errors for debug */
+	REG_WR(bp, 0x2814, 0xffffffff);
+	REG_WR(bp, 0x3820, 0xffffffff);
=20
-		switch (bp->board & SHARED_HW_CFG_BOARD_TYPE_MASK) {
-		case SHARED_HW_CFG_BOARD_TYPE_BCM957710A1022G:
-			/* Fan failure is indicated by SPIO 5 */
-			bnx2x_set_spio(bp, MISC_REGISTERS_SPIO_5,
-				       MISC_REGISTERS_SPIO_INPUT_HI_Z);
+	/* EMAC0 COMMON comes here */
+	/* EMAC1 COMMON comes here */
+	/* DBU COMMON comes here */
+	/* DBG COMMON comes here */
=20
-			/* set to active low mode */
-			val =3D REG_RD(bp, MISC_REG_SPIO_INT);
-			val |=3D ((1 << MISC_REGISTERS_SPIO_5) <<
-					MISC_REGISTERS_SPIO_INT_OLD_SET_POS);
-			REG_WR(bp, MISC_REG_SPIO_INT, val);
+	bnx2x_init_block(bp, NIG_COMMON_START, NIG_COMMON_END);
+	if (CHIP_IS_E1H(bp)) {
+		REG_WR(bp, NIG_REG_LLH_MF_MODE, IS_E1HMF(bp));
+		REG_WR(bp, NIG_REG_LLH_E1HOV_MODE, IS_E1HMF(bp));
+	}
=20
-			/* enable interrupt to signal the IGU */
-			val =3D REG_RD(bp, MISC_REG_SPIO_EVENT_EN);
-			val |=3D (1 << MISC_REGISTERS_SPIO_5);
-			REG_WR(bp, MISC_REG_SPIO_EVENT_EN, val);
-			break;
+	if (CHIP_REV_IS_SLOW(bp))
+		msleep(200);
=20
-		default:
-			break;
-		}
+	/* finish CFC init */
+	val =3D reg_poll(bp, CFC_REG_LL_INIT_DONE, 1, 100, 10);
+	if (val !=3D 1) {
+		BNX2X_ERR("CFC LL_INIT failed\n");
+		return -EBUSY;
+	}
+	val =3D reg_poll(bp, CFC_REG_AC_INIT_DONE, 1, 100, 10);
+	if (val !=3D 1) {
+		BNX2X_ERR("CFC AC_INIT failed\n");
+		return -EBUSY;
+	}
+	val =3D reg_poll(bp, CFC_REG_CAM_INIT_DONE, 1, 100, 10);
+	if (val !=3D 1) {
+		BNX2X_ERR("CFC CAM_INIT failed\n");
+		return -EBUSY;
+	}
+	REG_WR(bp, CFC_REG_DEBUG0, 0);
+
+	/* read NIG statistic
+	   to see if this is our first up since powerup */
+	bnx2x_read_dmae(bp, NIG_REG_STAT2_BRB_OCTET, 2);
+	val =3D *bnx2x_sp(bp, wb_data[0]);
=20
-	} /* end of common init */
+	/* do internal memory self test */
+	if ((CHIP_IS_E1(bp)) && (val =3D=3D 0) && bnx2x_int_mem_test(bp)) {
+		BNX2X_ERR("internal mem self test failed\n");
+		return -EBUSY;
+	}
=20
-	/* per port init */
+	switch (bp->common.board & SHARED_HW_CFG_BOARD_TYPE_MASK) {
+	case SHARED_HW_CFG_BOARD_TYPE_BCM957710A1022G:
+		/* Fan failure is indicated by SPIO 5 */
+		bnx2x_set_spio(bp, MISC_REGISTERS_SPIO_5,
+			       MISC_REGISTERS_SPIO_INPUT_HI_Z);
=20
-	/* the phys address is shifted right 12 bits and has an added
-	   1=3Dvalid bit added to the 53rd bit
-	   then since this is a wide register(TM)
-	   we split it into two 32 bit writes
-	 */
-#define RQ_ONCHIP_AT_PORT_SIZE  384
-#define ONCHIP_ADDR1(x)   ((u32)(((u64)x >> 12) & 0xFFFFFFFF))
-#define ONCHIP_ADDR2(x)   ((u32)((1 << 20) | ((u64)x >> 44)))
-#define PXP_ONE_ILT(x)    ((x << 10) | x)
+		/* set to active low mode */
+		val =3D REG_RD(bp, MISC_REG_SPIO_INT);
+		val |=3D ((1 << MISC_REGISTERS_SPIO_5) <<
+					MISC_REGISTERS_SPIO_INT_OLD_SET_POS);
+		REG_WR(bp, MISC_REG_SPIO_INT, val);
=20
-	DP(BNX2X_MSG_MCP, "starting per-function init port is %x\n", func);
+		/* enable interrupt to signal the IGU */
+		val =3D REG_RD(bp, MISC_REG_SPIO_EVENT_EN);
+		val |=3D (1 << MISC_REGISTERS_SPIO_5);
+		REG_WR(bp, MISC_REG_SPIO_EVENT_EN, val);
+		break;
=20
-	REG_WR(bp, NIG_REG_MASK_INTERRUPT_PORT0 + func*4, 0);
+	default:
+		break;
+	}
=20
-	/* Port PXP comes here */
-	/* Port PXP2 comes here */
+	/* clear PXP2 attentions */
+	REG_RD(bp, PXP2_REG_PXP2_INT_STS_CLR_0);
=20
-	/* Offset is
-	 * Port0  0
-	 * Port1  384 */
-	i =3D func * RQ_ONCHIP_AT_PORT_SIZE;
-#ifdef USE_DMAE
-	wb_write[0] =3D ONCHIP_ADDR1(bnx2x_sp_mapping(bp, context));
-	wb_write[1] =3D ONCHIP_ADDR2(bnx2x_sp_mapping(bp, context));
-	REG_WR_DMAE(bp, PXP2_REG_RQ_ONCHIP_AT + i*8, wb_write, 2);
-#else
-	REG_WR_IND(bp, PXP2_REG_RQ_ONCHIP_AT + i*8,
-		   ONCHIP_ADDR1(bnx2x_sp_mapping(bp, context)));
-	REG_WR_IND(bp, PXP2_REG_RQ_ONCHIP_AT + i*8 + 4,
-		   ONCHIP_ADDR2(bnx2x_sp_mapping(bp, context)));
+	enable_blocks_attention(bp);
+#ifdef BNX2X_EXTRA_DEBUG
+	enable_blocks_parity(bp);
 #endif
-	REG_WR(bp, PXP2_REG_PSWRQ_CDU0_L2P + func*4, PXP_ONE_ILT(i));
=20
+	return 0;
+}
+
+static int bnx2x_init_port(struct bnx2x *bp)
+{
+	int port =3D BP_PORT(bp);
+	u32 val;
+
+	DP(BNX2X_MSG_MCP, "starting port init port is %x\n", port);
+
+	REG_WR(bp, NIG_REG_MASK_INTERRUPT_PORT0 + port*4, 0);
+
+	/* Port PXP comes here */
+	/* Port PXP2 comes here */
 #ifdef BCM_ISCSI
 	/* Port0  1
 	 * Port1  385 */
@@ -4003,30 +4397,9 @@ static int bnx2x_function_init(struct bnx2x *bp,=
 int mode)
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
-	wb_write[0] =3D 0;
-	wb_write[1] =3D 0;
-#endif
-	for (i =3D 0; i < 32; i++) {
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
=20
 	/* Port QM comes here */
-
 #ifdef BCM_ISCSI
 	REG_WR(bp, TM_REG_LIN0_SCAN_TIME + func*4, 1024/64*20);
 	REG_WR(bp, TM_REG_LIN0_MAX_ACTIVE_CID + func*4, 31);
@@ -4041,31 +4414,32 @@ static int bnx2x_function_init(struct bnx2x *bp=
, int mode)
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
=20
 	/* configure PBF to work without PAUSE mtu 9000 */
-	REG_WR(bp, PBF_REG_P0_PAUSE_ENABLE + func*4, 0);
+	REG_WR(bp, PBF_REG_P0_PAUSE_ENABLE + port*4, 0);
=20
 	/* update threshold */
-	REG_WR(bp, PBF_REG_P0_ARB_THRSH + func*4, (9040/16));
+	REG_WR(bp, PBF_REG_P0_ARB_THRSH + port*4, (9040/16));
 	/* update init credit */
-	REG_WR(bp, PBF_REG_P0_INIT_CRD + func*4, (9040/16) + 553 - 22);
+	REG_WR(bp, PBF_REG_P0_INIT_CRD + port*4, (9040/16) + 553 - 22);
=20
 	/* probe changes */
-	REG_WR(bp, PBF_REG_INIT_P0 + func*4, 1);
+	REG_WR(bp, PBF_REG_INIT_P0 + port*4, 1);
 	msleep(5);
-	REG_WR(bp, PBF_REG_INIT_P0 + func*4, 0);
+	REG_WR(bp, PBF_REG_INIT_P0 + port*4, 0);
=20
 #ifdef BCM_ISCSI
 	/* tell the searcher where the T2 table is */
@@ -4083,23 +4457,56 @@ static int bnx2x_function_init(struct bnx2x *bp=
, int mode)
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
+	 *	     bits 4-7 are used for "per vn group attention" */
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
+		int i;
+		u32 wsum;
+
+		/* 0x2 disable e1hov, 0x1 enable */
+		REG_WR(bp, NIG_REG_LLH0_BRB1_DRV_MASK_MF + port*4,
+		       (IS_E1HMF(bp) ? 0x1 : 0x2));
+
+		/* Init RATE SHAPING and FAIRNESS contexts.
+		   Initialize as if there is 10G link. */
+		wsum =3D bnx2x_calc_vn_wsum(bp);
+		bnx2x_init_port_minmax(bp, (int)wsum, 10000);
+		if (IS_E1HMF(bp))
+			for (i =3D 0; i < E1HVN_MAX; i++)
+				bnx2x_init_func_minmax(bp, 2*i + port,
+					wsum, 10000);
+	}
+
 	/* Port MCP comes here */
 	/* Port DMAE comes here */
=20
-	switch (bp->board & SHARED_HW_CFG_BOARD_TYPE_MASK) {
+	switch (bp->common.board & SHARED_HW_CFG_BOARD_TYPE_MASK) {
 	case SHARED_HW_CFG_BOARD_TYPE_BCM957710A1022G:
 		/* add SPIO 5 to group 0 */
 		val =3D REG_RD(bp, MISC_REG_AEU_ENABLE1_FUNC_0_OUT_0);
@@ -4113,48 +4520,150 @@ static int bnx2x_function_init(struct bnx2x *b=
p, int mode)
=20
 	bnx2x__link_reset(bp);
=20
+	return 0;
+}
+
+#define ILT_PER_FUNC		(768/2)
+#define FUNC_ILT_BASE(func)	(func * ILT_PER_FUNC)
+/* the phys address is shifted right 12 bits and has an added
+   1=3Dvalid bit added to the 53rd bit
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
+		reg =3D PXP2_REG_RQ_ONCHIP_AT_B0 + index*8;
+	else /* E1 */
+		reg =3D PXP2_REG_RQ_ONCHIP_AT + index*8;
+
+	bnx2x_wb_wr(bp, reg, ONCHIP_ADDR1(addr), ONCHIP_ADDR2(addr));
+}
+
+static int bnx2x_init_func(struct bnx2x *bp)
+{
+	int port =3D BP_PORT(bp);
+	int func =3D BP_FUNC(bp);
+	int i;
+
+	DP(BNX2X_MSG_MCP, "starting func init func is %x\n", func);
+
+	i =3D FUNC_ILT_BASE(func);
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
+		for (i =3D 0; i < 9; i++)
+			bnx2x_init_block(bp,
+					 cm_start[func][i], cm_end[func][i]);
+
+		REG_WR(bp, NIG_REG_LLH0_FUNC_EN + port*8, 1);
+		REG_WR(bp, NIG_REG_LLH0_FUNC_VLAN_ID + port*8, bp->e1hovl);
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
=20
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
+	int i, rc =3D 0;
=20
-	REG_WR(bp, DBG_REG_PCI_REQ_CREDIT, 0x1);
-	REG_WR(bp, TM_REG_PCIARB_CRDCNT_VAL, 0x1);
-	REG_WR(bp, CDU_REG_CDU_DEBUG, 0x264);
-	REG_WR(bp, CDU_REG_CDU_DEBUG, 0x0);
+	DP(BNX2X_MSG_MCP, "function %d  load_code %x\n",
+	   BP_FUNC(bp), load_code);
=20
-	bnx2x_gunzip_end(bp);
+	bp->dmae_ready =3D 0;
+	mutex_init(&bp->dmae_mutex);
+	bnx2x_gunzip_init(bp);
+
+	switch (load_code) {
+	case FW_MSG_CODE_DRV_LOAD_COMMON:
+		rc =3D bnx2x_init_common(bp);
+		if (rc)
+			goto init_hw_err;
+		/* no break */
+
+	case FW_MSG_CODE_DRV_LOAD_PORT:
+		bp->dmae_ready =3D 1;
+		rc =3D bnx2x_init_port(bp);
+		if (rc)
+			goto init_hw_err;
+		/* no break */
+
+	case FW_MSG_CODE_DRV_LOAD_FUNCTION:
+		bp->dmae_ready =3D 1;
+		rc =3D bnx2x_init_func(bp);
+		if (rc)
+			goto init_hw_err;
+		break;
+
+	default:
+		BNX2X_ERR("Unknown load_code (0x%x) from MCP\n", load_code);
+		break;
+	}
=20
-	if (!nomcp) {
-		port =3D bp->port;
+	if (!BP_NOMCP(bp)) {
+		int func =3D BP_FUNC(bp);
=20
 		bp->fw_drv_pulse_wr_seq =3D
-				(SHMEM_RD(bp, func_mb[port].drv_pulse_mb) &
+				(SHMEM_RD(bp, func_mb[func].drv_pulse_mb) &
 				 DRV_PULSE_SEQ_MASK);
-		bp->fw_mb =3D SHMEM_RD(bp, func_mb[port].fw_mb_param);
-		DP(BNX2X_MSG_MCP, "drv_pulse 0x%x  fw_mb 0x%x\n",
-		   bp->fw_drv_pulse_wr_seq, bp->fw_mb);
-	} else {
-		bp->fw_mb =3D 0;
-	}
+		bp->func_stx =3D SHMEM_RD(bp, func_mb[func].fw_mb_param);
+		DP(BNX2X_MSG_MCP, "drv_pulse 0x%x  func_stx 0x%x\n",
+		   bp->fw_drv_pulse_wr_seq, bp->func_stx);
+	} else
+		bp->func_stx =3D 0;
=20
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
=20
 /* send the MCP a request, block until there is a reply */
 static u32 bnx2x_fw_command(struct bnx2x *bp, u32 command)
 {
-	int port =3D bp->port;
+	int func =3D BP_FUNC(bp);
 	u32 seq =3D ++bp->fw_seq;
 	u32 rc =3D 0;
=20
-	SHMEM_WR(bp, func_mb[port].drv_mb_header, (command | seq));
+	SHMEM_WR(bp, func_mb[func].drv_mb_header, (command | seq));
 	DP(BNX2X_MSG_MCP, "wrote command (%x) to FW MB\n", (command | seq));
=20
 	/* let the FW do it's magic ... */
@@ -4163,7 +4672,7 @@ static u32 bnx2x_fw_command(struct bnx2x *bp, u32=
 command)
 	if (CHIP_REV_IS_SLOW(bp))
 		msleep(900);
=20
-	rc =3D SHMEM_RD(bp, func_mb[port].fw_mb_header);
+	rc =3D SHMEM_RD(bp, func_mb[func].fw_mb_header);
 	DP(BNX2X_MSG_MCP, "read (%x) seq is (%x) from FW MB\n", rc, seq);
=20
 	/* is this a reply to our command? */
@@ -4228,15 +4737,13 @@ static void bnx2x_free_mem(struct bnx2x *bp)
 			       NUM_RCQ_BD);
 	}
=20
-	BNX2X_FREE(bp->fp);
-
 	/* end of fastpath */
=20
 	BNX2X_PCI_FREE(bp->def_status_blk, bp->def_status_blk_mapping,
-		       (sizeof(struct host_def_status_block)));
+		       sizeof(struct host_def_status_block));
=20
 	BNX2X_PCI_FREE(bp->slowpath, bp->slowpath_mapping,
-		       (sizeof(struct bnx2x_slowpath)));
+		       sizeof(struct bnx2x_slowpath));
=20
 #ifdef BCM_ISCSI
 	BNX2X_PCI_FREE(bp->t1, bp->t1_mapping, 64*1024);
@@ -4271,8 +4778,7 @@ static int bnx2x_alloc_mem(struct bnx2x *bp)
=20
 	int i;
=20
-	/* fastpath */
-	BNX2X_ALLOC(bp->fp, sizeof(struct bnx2x_fastpath) * bp->num_queues);
+	/* fastpath*/
=20
 	for_each_queue(bp, i) {
 		bnx2x_fp(bp, i, bp) =3D bp;
@@ -4369,8 +4875,6 @@ static void bnx2x_free_tx_skbs(struct bnx2x *bp)
 		u16 sw_prod =3D fp->tx_pkt_prod;
 		u16 sw_cons =3D fp->tx_pkt_cons;
=20
-		BUG_TRAP(fp->tx_buf_ring !=3D NULL);
-
 		while (sw_cons !=3D sw_prod) {
 			bd_cons =3D bnx2x_free_tx_pkt(bp, fp, TX_BD(sw_cons));
 			sw_cons++;
@@ -4385,8 +4889,6 @@ static void bnx2x_free_rx_skbs(struct bnx2x *bp)
 	for_each_queue(bp, j) {
 		struct bnx2x_fastpath *fp =3D &bp->fp[j];
=20
-		BUG_TRAP(fp->rx_buf_ring !=3D NULL);
-
 		for (i =3D 0; i < NUM_RX_BD; i++) {
 			struct sw_rx_bd *rx_buf =3D &fp->rx_buf_ring[i];
 			struct sk_buff *skb =3D rx_buf->skb;
@@ -4413,7 +4915,7 @@ static void bnx2x_free_skbs(struct bnx2x *bp)
=20
 static void bnx2x_free_msix_irqs(struct bnx2x *bp)
 {
-	int i;
+	int i, offset =3D 1;
=20
 	free_irq(bp->msix_table[0].vector, bp->dev);
 	DP(NETIF_MSG_IFDOWN, "released sp irq (%d)\n",
@@ -4421,26 +4923,22 @@ static void bnx2x_free_msix_irqs(struct bnx2x *=
bp)
=20
 	for_each_queue(bp, i) {
 		DP(NETIF_MSG_IFDOWN, "about to release fp #%d->%d irq  "
-		   "state(%x)\n", i, bp->msix_table[i + 1].vector,
+		   "state %x\n", i, bp->msix_table[i + offset].vector,
 		   bnx2x_fp(bp, i, state));
=20
 		if (bnx2x_fp(bp, i, state) !=3D BNX2X_FP_STATE_CLOSED)
 			BNX2X_ERR("IRQ of fp #%d being freed while "
 				  "state !=3D closed\n", i);
=20
-		free_irq(bp->msix_table[i + 1].vector, &bp->fp[i]);
+		free_irq(bp->msix_table[i + offset].vector, &bp->fp[i]);
 	}
-
 }
=20
 static void bnx2x_free_irq(struct bnx2x *bp)
 {
-
 	if (bp->flags & USING_MSIX_FLAG) {
-
 		bnx2x_free_msix_irqs(bp);
 		pci_disable_msix(bp->pdev);
-
 		bp->flags &=3D ~USING_MSIX_FLAG;
=20
 	} else
@@ -4449,87 +4947,87 @@ static void bnx2x_free_irq(struct bnx2x *bp)
=20
 static int bnx2x_enable_msix(struct bnx2x *bp)
 {
-
-	int i;
+	int i, rc, offset;
=20
 	bp->msix_table[0].entry =3D 0;
-	for_each_queue(bp, i)
-		bp->msix_table[i + 1].entry =3D i + 1;
+	offset =3D 1;
+	DP(NETIF_MSG_IFUP, "msix_table[0].entry =3D 0 (slowpath)\n");
=20
-	if (pci_enable_msix(bp->pdev, &bp->msix_table[0],
-				     bp->num_queues + 1)){
-		BNX2X_LOG("failed to enable MSI-X\n");
-		return -1;
+	for_each_queue(bp, i) {
+		int igu_vec =3D offset + i + BP_L_ID(bp);
=20
+		bp->msix_table[i + offset].entry =3D igu_vec;
+		DP(NETIF_MSG_IFUP, "msix_table[%d].entry =3D %d "
+		   "(fastpath #%u)\n", i + offset, igu_vec, i);
 	}
=20
+	rc =3D pci_enable_msix(bp->pdev, &bp->msix_table[0],
+			     bp->num_queues + offset);
+	if (rc) {
+		DP(NETIF_MSG_IFUP, "MSI-X is not attainable\n");
+		return -1;
+	}
 	bp->flags |=3D USING_MSIX_FLAG;
=20
 	return 0;
-
 }
=20
-
 static int bnx2x_req_msix_irqs(struct bnx2x *bp)
 {
-
-	int i, rc;
+	int i, rc, offset =3D 1;
=20
 	rc =3D request_irq(bp->msix_table[0].vector, bnx2x_msix_sp_int, 0,
 			 bp->dev->name, bp->dev);
-
 	if (rc) {
 		BNX2X_ERR("request sp irq failed\n");
 		return -EBUSY;
 	}
=20
 	for_each_queue(bp, i) {
-		rc =3D request_irq(bp->msix_table[i + 1].vector,
+		rc =3D request_irq(bp->msix_table[i + offset].vector,
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
=20
 		bnx2x_fp(bp, i, state) =3D BNX2X_FP_STATE_IRQ;
-
 	}
=20
 	return 0;
-
 }
=20
 static int bnx2x_req_irq(struct bnx2x *bp)
 {
+	int rc;
=20
-	int rc =3D request_irq(bp->pdev->irq, bnx2x_interrupt,
-			     IRQF_SHARED, bp->dev->name, bp->dev);
+	rc =3D request_irq(bp->pdev->irq, bnx2x_interrupt, IRQF_SHARED,
+			 bp->dev->name, bp->dev);
 	if (!rc)
 		bnx2x_fp(bp, 0, state) =3D BNX2X_FP_STATE_IRQ;
=20
 	return rc;
-
 }
=20
 /*
  * Init service functions
  */
=20
-static void bnx2x_set_mac_addr(struct bnx2x *bp)
+static void bnx2x_set_mac_addr_e1(struct bnx2x *bp)
 {
 	struct mac_configuration_cmd *config =3D bnx2x_sp(bp, mac_config);
+	int port =3D BP_PORT(bp);
=20
 	/* CAM allocation
 	 * unicasts 0-31:port0 32-63:port1
 	 * multicast 64-127:port0 128-191:port1
 	 */
 	config->hdr.length_6b =3D 2;
-	config->hdr.offset =3D bp->port ? 31 : 0;
-	config->hdr.reserved0 =3D 0;
+	config->hdr.offset =3D port ? 31 : 0;
+	config->hdr.client_id =3D BP_CL_ID(bp);
 	config->hdr.reserved1 =3D 0;
=20
 	/* primary MAC */
@@ -4539,7 +5037,7 @@ static void bnx2x_set_mac_addr(struct bnx2x *bp)
 					swab16(*(u16 *)&bp->dev->dev_addr[2]);
 	config->config_table[0].cam_entry.lsb_mac_addr =3D
 					swab16(*(u16 *)&bp->dev->dev_addr[4]);
-	config->config_table[0].cam_entry.flags =3D cpu_to_le16(bp->port);
+	config->config_table[0].cam_entry.flags =3D cpu_to_le16(port);
 	config->config_table[0].target_table_entry.flags =3D 0;
 	config->config_table[0].target_table_entry.client_id =3D 0;
 	config->config_table[0].target_table_entry.vlan_id =3D 0;
@@ -4553,7 +5051,7 @@ static void bnx2x_set_mac_addr(struct bnx2x *bp)
 	config->config_table[1].cam_entry.msb_mac_addr =3D 0xffff;
 	config->config_table[1].cam_entry.middle_mac_addr =3D 0xffff;
 	config->config_table[1].cam_entry.lsb_mac_addr =3D 0xffff;
-	config->config_table[1].cam_entry.flags =3D cpu_to_le16(bp->port);
+	config->config_table[1].cam_entry.flags =3D cpu_to_le16(port);
 	config->config_table[1].target_table_entry.flags =3D
 				TSTORM_CAM_TARGET_TABLE_ENTRY_BROADCAST;
 	config->config_table[1].target_table_entry.client_id =3D 0;
@@ -4564,64 +5062,106 @@ static void bnx2x_set_mac_addr(struct bnx2x *b=
p)
 		      U64_LO(bnx2x_sp_mapping(bp, mac_config)), 0);
 }
=20
+static void bnx2x_set_mac_addr_e1h(struct bnx2x *bp)
+{
+	struct mac_configuration_cmd_e1h *config =3D
+		(struct mac_configuration_cmd_e1h *)bnx2x_sp(bp, mac_config);
+
+	if (bp->state !=3D BNX2X_STATE_OPEN) {
+		DP(NETIF_MSG_IFUP, "state is %x, returning\n", bp->state);
+		return;
+	}
+
+	/* CAM allocation for E1H
+	 * unicasts: by func number
+	 * multicast: 20+FUNC*20, 20 each
+	 */
+	config->hdr.length_6b =3D 1;
+	config->hdr.offset =3D BP_FUNC(bp);
+	config->hdr.client_id =3D BP_CL_ID(bp);
+	config->hdr.reserved1 =3D 0;
+
+	/* primary MAC */
+	config->config_table[0].msb_mac_addr =3D
+					swab16(*(u16 *)&bp->dev->dev_addr[0]);
+	config->config_table[0].middle_mac_addr =3D
+					swab16(*(u16 *)&bp->dev->dev_addr[2]);
+	config->config_table[0].lsb_mac_addr =3D
+					swab16(*(u16 *)&bp->dev->dev_addr[4]);
+	config->config_table[0].client_id =3D BP_L_ID(bp);
+	config->config_table[0].vlan_id =3D 0;
+	config->config_table[0].e1hov_id =3D cpu_to_le16(bp->e1hovl);
+	config->config_table[0].flags =3D BP_PORT(bp);
+
+	DP(NETIF_MSG_IFUP, "setting MAC (%04x:%04x:%04x)  E1HOVL %d  CLID %d\=
n",
+	   config->config_table[0].msb_mac_addr,
+	   config->config_table[0].middle_mac_addr,
+	   config->config_table[0].lsb_mac_addr,
+	   bp->e1hovl, BP_L_ID(bp));
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
-	int timeout =3D 500;
+	int cnt =3D 500;
=20
 	DP(NETIF_MSG_IFUP, "%s for state to become %x on IDX [%d]\n",
 	   poll ? "polling" : "waiting", state, idx);
=20
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
=20
 		if (*state_p =3D=3D state)
 			return 0;
=20
-		timeout--;
 		msleep(1);
-
 	}
=20
 	/* timeout! */
 	BNX2X_ERR("timeout %s for state %x on IDX [%d]\n",
 		  poll ? "polling" : "waiting", state, idx);
+#ifdef BNX2X_STOP_ON_ERROR
+	bnx2x_panic();
+#endif
=20
 	return -EBUSY;
 }
=20
 static int bnx2x_setup_leading(struct bnx2x *bp)
 {
+	int rc;
=20
 	/* reset IGU state */
-	bnx2x_ack_sb(bp, DEF_SB_ID, CSTORM_ID, 0, IGU_INT_ENABLE, 0);
+	bnx2x_ack_sb(bp, bp->fp[0].sb_id, CSTORM_ID, 0, IGU_INT_ENABLE, 0);
=20
 	/* SETUP ramrod */
 	bnx2x_sp_post(bp, RAMROD_CMD_ID_ETH_PORT_SETUP, 0, 0, 0, 0);
=20
-	return bnx2x_wait_ramrod(bp, BNX2X_STATE_OPEN, 0, &(bp->state), 0);
+	/* Wait for completion */
+	rc =3D bnx2x_wait_ramrod(bp, BNX2X_STATE_OPEN, 0, &(bp->state), 0);
=20
+	return rc;
 }
=20
 static int bnx2x_setup_multi(struct bnx2x *bp, int index)
 {
-
 	/* reset IGU state */
-	bnx2x_ack_sb(bp, index, CSTORM_ID, 0, IGU_INT_ENABLE, 0);
+	bnx2x_ack_sb(bp, bp->fp[index].sb_id, CSTORM_ID, 0, IGU_INT_ENABLE, 0=
);
=20
 	/* SETUP ramrod */
 	bp->fp[index].state =3D BNX2X_FP_STATE_OPENING;
@@ -4630,82 +5170,108 @@ static int bnx2x_setup_multi(struct bnx2x *bp,=
 int index)
 	/* Wait for completion */
 	return bnx2x_wait_ramrod(bp, BNX2X_FP_STATE_OPEN, index,
 				 &(bp->fp[index].state), 0);
-
 }
=20
=20
 static int bnx2x_poll(struct napi_struct *napi, int budget);
 static void bnx2x_set_rx_mode(struct net_device *dev);
=20
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
=20
 	bp->state =3D BNX2X_STATE_OPENING_WAIT4_LOAD;
=20
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
 		load_code =3D bnx2x_fw_command(bp, DRV_MSG_CODE_LOAD_REQ);
 		if (!load_code) {
 			BNX2X_ERR("MCP response failure, unloading\n");
 			return -EBUSY;
 		}
-		if (load_code =3D=3D FW_MSG_CODE_DRV_LOAD_REFUSED) {
-			BNX2X_ERR("MCP refused load request, unloading\n");
+		if (load_code =3D=3D FW_MSG_CODE_DRV_LOAD_REFUSED)
 			return -EBUSY; /* other port in diagnostic mode */
-		}
+
 	} else {
-		load_code =3D FW_MSG_CODE_DRV_LOAD_COMMON;
+		DP(NETIF_MSG_IFUP, "NO MCP load counts before us %d, %d, %d\n",
+		   load_count[0], load_count[1], load_count[2]);
+		load_count[0]++;
+		load_count[1 + BP_PORT(bp)]++;
+		DP(NETIF_MSG_IFUP, "NO MCP new load counts       %d, %d, %d\n",
+		   load_count[0], load_count[1], load_count[2]);
+		if (load_count[0] =3D=3D 1)
+			load_code =3D FW_MSG_CODE_DRV_LOAD_COMMON;
+		else if (load_count[1 + BP_PORT(bp)] =3D=3D 1)
+			load_code =3D FW_MSG_CODE_DRV_LOAD_PORT;
+		else
+			load_code =3D FW_MSG_CODE_DRV_LOAD_FUNCTION;
 	}
=20
-	/* if we can't use msix we only need one fp,
-	 * so try to enable msix with the requested number of fp's
+	if ((load_code =3D=3D FW_MSG_CODE_DRV_LOAD_COMMON) ||
+	    (load_code =3D=3D FW_MSG_CODE_DRV_LOAD_PORT))
+		bp->port.pmf =3D 1;
+	else
+		bp->port.pmf =3D 0;
+	DP(NETIF_MSG_LINK, "pmf %d\n", bp->port.pmf);
+
+	/* if we can't use MSI-X we only need one fp,
+	 * so try to enable MSI-X with the requested number of fp's
 	 * and fallback to inta with one fp
 	 */
-	if (req_irq) {
-		if (use_inta) {
+	if (use_inta) {
+		bp->num_queues =3D 1;
+
+	} else {
+		if ((use_multi > 1) && (use_multi <=3D BP_MAX_QUEUES(bp)))
+			/* user requested number */
+			bp->num_queues =3D use_multi;
+
+		else if (use_multi)
+			bp->num_queues =3D min_t(u32, num_online_cpus(),
+					       BP_MAX_QUEUES(bp));
+		else
 			bp->num_queues =3D 1;
-		} else {
-			if ((use_multi > 1) && (use_multi <=3D 16))
-				/* user requested number */
-				bp->num_queues =3D use_multi;
-			else if (use_multi =3D=3D 1)
-				bp->num_queues =3D num_online_cpus();
-			else
-				bp->num_queues =3D 1;
-
-			if (bnx2x_enable_msix(bp)) {
-				/* failed to enable msix */
-				bp->num_queues =3D 1;
-				if (use_multi)
-					BNX2X_ERR("Multi requested but failed"
-						  " to enable MSI-X\n");
-			}
+
+		if (bnx2x_enable_msix(bp)) {
+			/* failed to enable MSI-X */
+			bp->num_queues =3D 1;
+			if (use_multi)
+				BNX2X_ERR("Multi requested but failed"
+					  " to enable MSI-X\n");
 		}
 	}
-
-	DP(NETIF_MSG_IFUP, "set number of queues to %d\n", bp->num_queues);
+	DP(NETIF_MSG_IFUP,
+	   "set number of queues to %d\n", bp->num_queues);
=20
 	if (bnx2x_alloc_mem(bp))
 		return -ENOMEM;
=20
-	if (req_irq) {
-		if (bp->flags & USING_MSIX_FLAG) {
-			if (bnx2x_req_msix_irqs(bp)) {
-				pci_disable_msix(bp->pdev);
-				goto load_error;
-			}
+	/* Disable ISR calls until we initialize HW */
+	atomic_set(&bp->intr_sem, 1);
=20
-		} else {
-			if (bnx2x_req_irq(bp)) {
-				BNX2X_ERR("IRQ request failed, aborting\n");
-				goto load_error;
-			}
+	if (bp->flags & USING_MSIX_FLAG) {
+		rc =3D bnx2x_req_msix_irqs(bp);
+		if (rc) {
+			pci_disable_msix(bp->pdev);
+			goto load_error;
+		}
+	} else {
+		bnx2x_ack_int(bp);
+		rc =3D bnx2x_req_irq(bp);
+		if (rc) {
+			BNX2X_ERR("IRQ request failed, aborting\n");
+			goto load_error;
 		}
 	}
=20
@@ -4713,26 +5279,25 @@ static int bnx2x_nic_load(struct bnx2x *bp, int=
 req_irq)
 		netif_napi_add(bp->dev, &bnx2x_fp(bp, i, napi),
 			       bnx2x_poll, 128);
=20
-
 	/* Initialize HW */
-	if (bnx2x_function_init(bp,
-				(load_code =3D=3D FW_MSG_CODE_DRV_LOAD_COMMON))) {
+	rc =3D bnx2x_init_hw(bp, load_code);
+	if (rc) {
 		BNX2X_ERR("HW init failed, aborting\n");
 		goto load_error;
 	}
=20
-
+	/* Enable ISR */
 	atomic_set(&bp->intr_sem, 0);
=20
-
 	/* Setup NIC internals and enable interrupts */
 	bnx2x_nic_init(bp);
=20
 	/* Send LOAD_DONE command to MCP */
-	if (!nomcp) {
+	if (!BP_NOMCP(bp)) {
 		load_code =3D bnx2x_fw_command(bp, DRV_MSG_CODE_LOAD_DONE);
 		if (!load_code) {
 			BNX2X_ERR("MCP response failure, unloading\n");
+			rc =3D -EBUSY;
 			goto load_int_disable;
 		}
 	}
@@ -4744,33 +5309,68 @@ static int bnx2x_nic_load(struct bnx2x *bp, int=
 req_irq)
 	for_each_queue(bp, i)
 		napi_enable(&bnx2x_fp(bp, i, napi));
=20
-	if (bnx2x_setup_leading(bp))
+	rc =3D bnx2x_setup_leading(bp);
+	if (rc) {
+#ifdef BNX2X_STOP_ON_ERROR
+		bp->panic =3D 1;
+#endif
 		goto load_stop_netif;
+	}
=20
-	for_each_nondefault_queue(bp, i)
-		if (bnx2x_setup_multi(bp, i))
-			goto load_stop_netif;
+	if (CHIP_IS_E1H(bp))
+		if (bp->mf_config & FUNC_MF_CFG_FUNC_DISABLED) {
+			BNX2X_ERR("!!!  mf_cfg function disabled\n");
+			bp->state =3D BNX2X_STATE_DISABLED;
+		}
=20
-	bnx2x_set_mac_addr(bp);
+	if (bp->state =3D=3D BNX2X_STATE_OPEN)
+		for_each_nondefault_queue(bp, i) {
+			rc =3D bnx2x_setup_multi(bp, i);
+			if (rc)
+				goto load_stop_netif;
+		}
=20
-	bnx2x_initial_phy_init(bp);
+	if (CHIP_IS_E1(bp))
+		bnx2x_set_mac_addr_e1(bp);
+	else
+		bnx2x_set_mac_addr_e1h(bp);
+
+	if (bp->port.pmf)
+		bnx2x_initial_phy_init(bp);
=20
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
=20
-	/* Otherwise Tx queue should be only reenabled */
-	} else if (netif_running(bp->dev)) {
-		netif_wake_queue(bp->dev);
+	case LOAD_DIAG:
 		bnx2x_set_rx_mode(bp->dev);
+		bp->state =3D BNX2X_STATE_DIAG;
+		break;
+
+	default:
+		break;
 	}
=20
+	if (!bp->port.pmf)
+		bnx2x__link_status_update(bp);
+
 	/* start the timer */
 	mod_timer(&bp->timer, jiffies + bp->current_interval);
=20
+
 	return 0;
=20
 load_stop_netif:
@@ -4780,7 +5380,7 @@ load_stop_netif:
 load_int_disable:
 	bnx2x_int_disable_sync(bp);
=20
-	bnx2x_free_skbs(bp);
+	/* Release IRQs */
 	bnx2x_free_irq(bp);
=20
 load_error:
@@ -4788,95 +5388,50 @@ load_error:
=20
 	/* TBD we really need to reset the chip
 	   if we want to recover from this */
-	return -EBUSY;
-}
-
-
-static void bnx2x_reset_chip(struct bnx2x *bp, u32 reset_code)
-{
-	int port =3D bp->port;
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
-	wb_write[0] =3D 0;
-	wb_write[1] =3D 0;
-#endif
-	base =3D port * RQ_ONCHIP_AT_PORT_SIZE;
-	for (i =3D base; i < base + RQ_ONCHIP_AT_PORT_SIZE; i++) {
-#ifdef USE_DMAE
-		REG_WR_DMAE(bp, PXP2_REG_RQ_ONCHIP_AT + i*8, wb_write, 2);
-#else
-		REG_WR_IND(bp, PXP2_REG_RQ_ONCHIP_AT, 0);
-		REG_WR_IND(bp, PXP2_REG_RQ_ONCHIP_AT + 4, 0);
-#endif
-	}
-
-	if (reset_code =3D=3D FW_MSG_CODE_DRV_UNLOAD_COMMON) {
-		/* reset_common */
-		REG_WR(bp, GRCBASE_MISC + MISC_REGISTERS_RESET_REG_1_CLEAR,
-		       0xd3ffff7f);
-		REG_WR(bp, GRCBASE_MISC + MISC_REGISTERS_RESET_REG_2_CLEAR,
-		       0x1403);
-	}
+	return rc;
 }
=20
 static int bnx2x_stop_multi(struct bnx2x *bp, int index)
 {
-
 	int rc;
=20
 	/* halt the connection */
 	bp->fp[index].state =3D BNX2X_FP_STATE_HALTING;
 	bnx2x_sp_post(bp, RAMROD_CMD_ID_ETH_HALT, index, 0, 0, 0);
=20
-
+	/* Wait for completion */
 	rc =3D bnx2x_wait_ramrod(bp, BNX2X_FP_STATE_HALTED, index,
-				       &(bp->fp[index].state), 1);
+			       &(bp->fp[index].state), 1);
 	if (rc) /* timeout */
 		return rc;
=20
 	/* delete cfc entry */
 	bnx2x_sp_post(bp, RAMROD_CMD_ID_ETH_CFC_DEL, index, 0, 0, 1);
=20
-	return bnx2x_wait_ramrod(bp, BNX2X_FP_STATE_CLOSED, index,
-				 &(bp->fp[index].state), 1);
-
+	/* Wait for completion */
+	rc =3D bnx2x_wait_ramrod(bp, BNX2X_FP_STATE_CLOSED, index,
+			       &(bp->fp[index].state), 1);
+	return rc;
 }
=20
-
 static void bnx2x_stop_leading(struct bnx2x *bp)
 {
 	u16 dsb_sp_prod_idx;
 	/* if the other port is handling traffic,
 	   this can take a lot of time */
-	int timeout =3D 500;
+	int cnt =3D 500;
+	int rc;
=20
 	might_sleep();
=20
 	/* Send HALT ramrod */
 	bp->fp[0].state =3D BNX2X_FP_STATE_HALTING;
-	bnx2x_sp_post(bp, RAMROD_CMD_ID_ETH_HALT, 0, 0, 0, 0);
+	bnx2x_sp_post(bp, RAMROD_CMD_ID_ETH_HALT, 0, 0, BP_CL_ID(bp), 0);
=20
-	if (bnx2x_wait_ramrod(bp, BNX2X_FP_STATE_HALTED, 0,
-			       &(bp->fp[0].state), 1))
+	/* Wait for completion */
+	rc =3D bnx2x_wait_ramrod(bp, BNX2X_FP_STATE_HALTED, 0,
+			       &(bp->fp[0].state), 1);
+	if (rc) /* timeout */
 		return;
=20
 	dsb_sp_prod_idx =3D *bp->dsb_sp_prod;
@@ -4888,29 +5443,101 @@ static void bnx2x_stop_leading(struct bnx2x *b=
p)
 	   we are going to reset the chip anyway
 	   so there is not much to do if this times out
 	 */
-	while ((dsb_sp_prod_idx =3D=3D *bp->dsb_sp_prod) && timeout) {
-		timeout--;
+	while (dsb_sp_prod_idx =3D=3D *bp->dsb_sp_prod) {
 		msleep(1);
-	}
-	if (!timeout) {
-		DP(NETIF_MSG_IFDOWN, "timeout polling for completion "
-		   "dsb_sp_prod 0x%x !=3D dsb_sp_prod_idx 0x%x\n",
-		   *bp->dsb_sp_prod, dsb_sp_prod_idx);
+		if (!cnt) {
+			DP(NETIF_MSG_IFDOWN, "timeout waiting for port del "
+			   "dsb_sp_prod 0x%x !=3D dsb_sp_prod_idx 0x%x\n",
+			   *bp->dsb_sp_prod, dsb_sp_prod_idx);
+#ifdef BNX2X_STOP_ON_ERROR
+			bnx2x_panic();
+#endif
+			break;
+		}
+		cnt--;
 	}
 	bp->state =3D BNX2X_STATE_CLOSING_WAIT4_UNLOAD;
 	bp->fp[0].state =3D BNX2X_FP_STATE_CLOSED;
 }
=20
+static void bnx2x_reset_func(struct bnx2x *bp)
+{
+	int port =3D BP_PORT(bp);
+	int func =3D BP_FUNC(bp);
+	int base, i;
+
+	/* Configure IGU */
+	REG_WR(bp, HC_REG_LEADING_EDGE_0 + port*8, 0);
+	REG_WR(bp, HC_REG_TRAILING_EDGE_0 + port*8, 0);
+
+	REG_WR(bp, HC_REG_CONFIG_0 + port*4, 0x1000);
+
+	/* Clear ILT */
+	base =3D FUNC_ILT_BASE(func);
+	for (i =3D base; i < base + ILT_PER_FUNC; i++)
+		bnx2x_ilt_wr(bp, i, 0);
+
+}
=20
-static int bnx2x_nic_unload(struct bnx2x *bp, int free_irq)
+static void bnx2x_reset_port(struct bnx2x *bp)
+{
+	int port =3D BP_PORT(bp);
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
+
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
 	u32 reset_code =3D 0;
-	int i, timeout;
+	int i, cnt;
=20
 	bp->state =3D BNX2X_STATE_CLOSING_WAIT4_HALT;
=20
-	del_timer_sync(&bp->timer);
-
 	bp->rx_mode =3D BNX2X_RX_MODE_NONE;
 	bnx2x_set_storm_rx_mode(bp);
=20
@@ -4919,21 +5546,29 @@ static int bnx2x_nic_unload(struct bnx2x *bp, i=
nt free_irq)
 		bp->dev->trans_start =3D jiffies;	/* prevent tx timeout */
 	}
=20
+	del_timer_sync(&bp->timer);
+	SHMEM_WR(bp, func_mb[BP_FUNC(bp)].drv_pulse_mb,
+		 (DRV_PULSE_ALWAYS_ALIVE | bp->fw_drv_pulse_wr_seq));
+
 	/* Wait until all fast path tasks complete */
 	for_each_queue(bp, i) {
 		struct bnx2x_fastpath *fp =3D &bp->fp[i];
=20
-		timeout =3D 1000;
-		while (bnx2x_has_work(fp) && (timeout--))
+		cnt =3D 1000;
+		while (bnx2x_has_work(fp)) {
 			msleep(1);
-		if (!timeout)
-			BNX2X_ERR("timeout waiting for queue[%d]\n", i);
+			if (!cnt) {
+				BNX2X_ERR("timeout waiting for queue[%d]\n",
+					  i);
+				break;
+			}
+			cnt--;
+		}
 	}
=20
-	/* Wait until stat ramrod returns and all SP tasks complete */
-	timeout =3D 1000;
-	while ((bp->stat_pending || (bp->spq_left !=3D MAX_SPQ_PENDING)) &&
-	       (timeout--))
+	/* Wait until all slow path tasks complete */
+	cnt =3D 1000;
+	while ((bp->spq_left !=3D MAX_SPQ_PENDING) && cnt--)
 		msleep(1);
=20
 	for_each_queue(bp, i)
@@ -4941,59 +5576,81 @@ static int bnx2x_nic_unload(struct bnx2x *bp, i=
nt free_irq)
 	/* Disable interrupts after Tx and Rx are disabled on stack level */
 	bnx2x_int_disable_sync(bp);
=20
+	/* Release IRQs */
+	bnx2x_free_irq(bp);
+
 	if (bp->flags & NO_WOL_FLAG)
 		reset_code =3D DRV_MSG_CODE_UNLOAD_REQ_WOL_MCP;
=20
 	else if (bp->wol) {
-		u32 emac_base =3D bp->port ? GRCBASE_EMAC0 : GRCBASE_EMAC1;
+		u32 emac_base =3D BP_PORT(bp) ? GRCBASE_EMAC1 : GRCBASE_EMAC0;
 		u8 *mac_addr =3D bp->dev->dev_addr;
-		u32 val =3D (EMAC_MODE_MPKT | EMAC_MODE_MPKT_RCVD |
-			   EMAC_MODE_ACPI_RCVD);
-
-		EMAC_WR(EMAC_REG_EMAC_MODE, val);
+		u32 val;
=20
+		/* The mac address is written to entries 1-4 to
+		   preserve entry 0 which is used by the PMF */
 		val =3D (mac_addr[0] << 8) | mac_addr[1];
-		EMAC_WR(EMAC_REG_EMAC_MAC_MATCH, val);
+		EMAC_WR(EMAC_REG_EMAC_MAC_MATCH + (BP_E1HVN(bp) + 1)*8, val);
=20
 		val =3D (mac_addr[2] << 24) | (mac_addr[3] << 16) |
 		      (mac_addr[4] << 8) | mac_addr[5];
-		EMAC_WR(EMAC_REG_EMAC_MAC_MATCH + 4, val);
+		EMAC_WR(EMAC_REG_EMAC_MAC_MATCH + (BP_E1HVN(bp) + 1)*8 + 4,
+			val);
=20
 		reset_code =3D DRV_MSG_CODE_UNLOAD_REQ_WOL_EN;
=20
 	} else
 		reset_code =3D DRV_MSG_CODE_UNLOAD_REQ_WOL_DIS;
=20
-	/* Close multi and leading connections */
+	/* Close multi and leading connections
+	   Completions for ramrods are collected in a synchronous way */
 	for_each_nondefault_queue(bp, i)
 		if (bnx2x_stop_multi(bp, i))
 			goto unload_error;
=20
 	bnx2x_stop_leading(bp);
+#ifdef BNX2X_STOP_ON_ERROR
+	/* If ramrod completion timed out - break here! */
+	if (bp->panic) {
+		BNX2X_ERR("Stop leading failed!\n");
+		return -EBUSY;
+	}
+#endif
+
 	if ((bp->state !=3D BNX2X_STATE_CLOSING_WAIT4_UNLOAD) ||
 	    (bp->fp[0].state !=3D BNX2X_FP_STATE_CLOSED)) {
-		DP(NETIF_MSG_IFDOWN, "failed to close leading properly!"
-		   "state 0x%x  fp[0].state 0x%x",
+		DP(NETIF_MSG_IFDOWN, "failed to close leading properly!  "
+		   "state 0x%x  fp[0].state 0x%x\n",
 		   bp->state, bp->fp[0].state);
 	}
=20
 unload_error:
-	bnx2x__link_reset(bp);
-
-	if (!nomcp)
+	if (!BP_NOMCP(bp))
 		reset_code =3D bnx2x_fw_command(bp, reset_code);
-	else
-		reset_code =3D FW_MSG_CODE_DRV_UNLOAD_COMMON;
+	else {
+		DP(NETIF_MSG_IFDOWN, "NO MCP load counts      %d, %d, %d\n",
+		   load_count[0], load_count[1], load_count[2]);
+		load_count[0]--;
+		load_count[1 + BP_PORT(bp)]--;
+		DP(NETIF_MSG_IFDOWN, "NO MCP new load counts  %d, %d, %d\n",
+		   load_count[0], load_count[1], load_count[2]);
+		if (load_count[0] =3D=3D 0)
+			reset_code =3D FW_MSG_CODE_DRV_UNLOAD_COMMON;
+		else if (load_count[1 + BP_PORT(bp)] =3D=3D 0)
+			reset_code =3D FW_MSG_CODE_DRV_UNLOAD_PORT;
+		else
+			reset_code =3D FW_MSG_CODE_DRV_UNLOAD_FUNCTION;
+	}
=20
-	/* Release IRQs */
-	if (free_irq)
-		bnx2x_free_irq(bp);
+	if ((reset_code =3D=3D FW_MSG_CODE_DRV_UNLOAD_COMMON) ||
+	    (reset_code =3D=3D FW_MSG_CODE_DRV_UNLOAD_PORT))
+		bnx2x__link_reset(bp);
=20
 	/* Reset the chip */
 	bnx2x_reset_chip(bp, reset_code);
=20
 	/* Report UNLOAD_DONE to MCP */
-	if (!nomcp)
+	if (!BP_NOMCP(bp))
 		bnx2x_fw_command(bp, DRV_MSG_CODE_UNLOAD_DONE);
=20
 	/* Free SKBs and driver internals */
@@ -5007,6 +5664,29 @@ unload_error:
 	return 0;
 }
=20
+static void bnx2x_reset_task(struct work_struct *work)
+{
+	struct bnx2x *bp =3D container_of(work, struct bnx2x, reset_task);
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
=20
 /* ethtool_ops */
@@ -5015,9 +5695,136 @@ unload_error:
  * Init service functions
  */
=20
+static void bnx2x_undi_unload(struct bnx2x *bp)
+{
+	u32 val;
+
+	/* Check if there is any driver already loaded */
+	val =3D REG_RD(bp, MISC_REG_UNPREPARED);
+	if (val =3D=3D 0x1) {
+		/* Check if it is the UNDI driver
+		 * UNDI driver initializes CID offset for normal bell to 0x7
+		 */
+		val =3D REG_RD(bp, DORQ_REG_NORM_CID_OFST);
+		if (val =3D=3D 0x7) {
+			u32 reset_code =3D DRV_MSG_CODE_UNLOAD_REQ_WOL_DIS;
+			/* save our func and fw_seq */
+			int func =3D BP_FUNC(bp);
+			u16 fw_seq =3D bp->fw_seq;
+
+			BNX2X_DEV_INFO("UNDI is active! reset device\n");
+
+			/* try unload UNDI on port 0 */
+			bp->func =3D 0;
+			bp->fw_seq =3D (SHMEM_RD(bp,
+					     func_mb[bp->func].drv_mb_header) &
+				      DRV_MSG_SEQ_NUMBER_MASK);
+
+			reset_code =3D bnx2x_fw_command(bp, reset_code);
+			bnx2x_fw_command(bp, DRV_MSG_CODE_UNLOAD_DONE);
+
+			/* if UNDI is loaded on the other port */
+			if (reset_code !=3D FW_MSG_CODE_DRV_UNLOAD_COMMON) {
+
+				bp->func =3D 1;
+				bp->fw_seq =3D (SHMEM_RD(bp,
+					     func_mb[bp->func].drv_mb_header) &
+					      DRV_MSG_SEQ_NUMBER_MASK);
+
+				bnx2x_fw_command(bp,
+					     DRV_MSG_CODE_UNLOAD_REQ_WOL_DIS);
+				bnx2x_fw_command(bp,
+						 DRV_MSG_CODE_UNLOAD_DONE);
+
+				/* restore our func and fw_seq */
+				bp->func =3D func;
+				bp->fw_seq =3D fw_seq;
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
+static void bnx2x_get_common_hwinfo(struct bnx2x *bp)
+{
+	u32 val, val2, val3, val4, id;
+
+	/* Get the chip revision id and number. */
+	/* chip num:16-31, rev:12-15, metal:4-11, bond_id:0-3 */
+	val =3D REG_RD(bp, MISC_REG_CHIP_NUM);
+	id =3D ((val & 0xffff) << 16);
+	val =3D REG_RD(bp, MISC_REG_CHIP_REV);
+	id |=3D ((val & 0xf) << 12);
+	val =3D REG_RD(bp, MISC_REG_CHIP_METAL);
+	id |=3D ((val & 0xff) << 4);
+	REG_RD(bp, MISC_REG_BOND_ID);
+	id |=3D (val & 0xf);
+	bp->common.chip_id =3D id;
+	bp->link_params.chip_id =3D bp->common.chip_id;
+	BNX2X_DEV_INFO("chip ID is %x\n", id);
+
+	val =3D REG_RD(bp, MCP_REG_MCPR_NVM_CFG4);
+	bp->common.flash_size =3D (NVRAM_1MB_SIZE <<
+				 (val & MCPR_NVM_CFG4_FLASH_SIZE));
+	BNX2X_DEV_INFO("flash_size 0x%x (%d)\n",
+		       bp->common.flash_size, bp->common.flash_size);
+
+	bp->common.shmem_base =3D REG_RD(bp, MISC_REG_SHARED_MEM_ADDR);
+	bp->link_params.shmem_base =3D bp->common.shmem_base;
+	BNX2X_DEV_INFO("shmem offset is %x\n", bp->common.shmem_base);
+
+	if (!bp->common.shmem_base ||
+	    (bp->common.shmem_base < 0xA0000) ||
+	    (bp->common.shmem_base >=3D 0xC0000)) {
+		BNX2X_DEV_INFO("MCP not active\n");
+		bp->flags |=3D NO_MCP_FLAG;
+		return;
+	}
+
+	val =3D SHMEM_RD(bp, validity_map[BP_PORT(bp)]);
+	if ((val & (SHR_MEM_VALIDITY_DEV_INFO | SHR_MEM_VALIDITY_MB))
+		!=3D (SHR_MEM_VALIDITY_DEV_INFO | SHR_MEM_VALIDITY_MB))
+		BNX2X_ERR("BAD MCP validity signature\n");
+
+	bp->common.hw_config =3D SHMEM_RD(bp, dev_info.shared_hw_config.confi=
g);
+	bp->common.board =3D SHMEM_RD(bp, dev_info.shared_hw_config.board);
+
+	BNX2X_DEV_INFO("hw_config (%08x)  board (%08x)\n",
+		       bp->common.hw_config, bp->common.board);
+
+	bp->link_params.hw_led_mode =3D ((bp->common.hw_config &
+					SHARED_HW_CFG_LED_MODE_MASK) >>
+				       SHARED_HW_CFG_LED_MODE_SHIFT);
+
+	val =3D SHMEM_RD(bp, dev_info.bc_rev) >> 8;
+	bp->common.bc_ver =3D val;
+	BNX2X_DEV_INFO("bc_ver %X\n", val);
+	if (val < BNX2X_BC_VER) {
+		/* for now only warn
+		 * later we might need to enforce this */
+		BNX2X_ERR("This driver needs bc_ver %X but found %X,"
+			  " please upgrade BC\n", BNX2X_BC_VER, val);
+	}
+
+	val =3D SHMEM_RD(bp, dev_info.shared_hw_config.part_num);
+	val2 =3D SHMEM_RD(bp, dev_info.shared_hw_config.part_num[4]);
+	val3 =3D SHMEM_RD(bp, dev_info.shared_hw_config.part_num[8]);
+	val4 =3D SHMEM_RD(bp, dev_info.shared_hw_config.part_num[12]);
+
+	printk(KERN_INFO PFX "part number %X-%X-%X-%X\n",
+	       val, val2, val3, val4);
+}
+
 static void bnx2x_link_settings_supported(struct bnx2x *bp, u32 switch=
_cfg)
 {
-	int port =3D bp->port;
+	int port =3D BP_PORT(bp);
 	u32 ext_phy_type;
=20
 	switch (switch_cfg) {
@@ -5031,31 +5838,33 @@ static void bnx2x_link_settings_supported(struc=
t bnx2x *bp, u32 switch_cfg)
 			BNX2X_DEV_INFO("ext_phy_type 0x%x (Direct)\n",
 				       ext_phy_type);
=20
-			bp->supported |=3D (SUPPORTED_10baseT_Half |
-					  SUPPORTED_10baseT_Full |
-					  SUPPORTED_100baseT_Half |
-					  SUPPORTED_100baseT_Full |
-					  SUPPORTED_1000baseT_Full |
-					  SUPPORTED_2500baseX_Full |
-					  SUPPORTED_TP | SUPPORTED_FIBRE |
-					  SUPPORTED_Autoneg |
-					  SUPPORTED_Pause |
-					  SUPPORTED_Asym_Pause);
+			bp->port.supported |=3D (SUPPORTED_10baseT_Half |
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
=20
 		case PORT_HW_CFG_SERDES_EXT_PHY_TYPE_BCM5482:
 			BNX2X_DEV_INFO("ext_phy_type 0x%x (5482)\n",
 				       ext_phy_type);
=20
-			bp->supported |=3D (SUPPORTED_10baseT_Half |
-					  SUPPORTED_10baseT_Full |
-					  SUPPORTED_100baseT_Half |
-					  SUPPORTED_100baseT_Full |
-					  SUPPORTED_1000baseT_Full |
-					  SUPPORTED_TP | SUPPORTED_FIBRE |
-					  SUPPORTED_Autoneg |
-					  SUPPORTED_Pause |
-					  SUPPORTED_Asym_Pause);
+			bp->port.supported |=3D (SUPPORTED_10baseT_Half |
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
=20
 		default:
@@ -5065,9 +5874,9 @@ static void bnx2x_link_settings_supported(struct =
bnx2x *bp, u32 switch_cfg)
 			return;
 		}
=20
-		bp->phy_addr =3D REG_RD(bp, NIG_REG_SERDES0_CTRL_PHY_ADDR +
-				      port*0x10);
-		BNX2X_DEV_INFO("phy_addr 0x%x\n", bp->phy_addr);
+		bp->port.phy_addr =3D REG_RD(bp, NIG_REG_SERDES0_CTRL_PHY_ADDR +
+					   port*0x10);
+		BNX2X_DEV_INFO("phy_addr 0x%x\n", bp->port.phy_addr);
 		break;
=20
 	case SWITCH_CFG_10G:
@@ -5080,75 +5889,75 @@ static void bnx2x_link_settings_supported(struc=
t bnx2x *bp, u32 switch_cfg)
 			BNX2X_DEV_INFO("ext_phy_type 0x%x (Direct)\n",
 				       ext_phy_type);
=20
-			bp->supported |=3D (SUPPORTED_10baseT_Half |
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
+			bp->port.supported |=3D (SUPPORTED_10baseT_Half |
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
=20
 		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8705:
 			BNX2X_DEV_INFO("ext_phy_type 0x%x (8705)\n",
-					ext_phy_type);
+				       ext_phy_type);
=20
-			bp->supported |=3D (SUPPORTED_10000baseT_Full |
-					  SUPPORTED_FIBRE |
-					  SUPPORTED_Pause |
-					  SUPPORTED_Asym_Pause);
+			bp->port.supported |=3D (SUPPORTED_10000baseT_Full |
+					       SUPPORTED_FIBRE |
+					       SUPPORTED_Pause |
+					       SUPPORTED_Asym_Pause);
 			break;
=20
 		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8706:
 			BNX2X_DEV_INFO("ext_phy_type 0x%x (8706)\n",
 				       ext_phy_type);
=20
-			bp->supported |=3D (SUPPORTED_10000baseT_Full |
-					  SUPPORTED_1000baseT_Full |
-					  SUPPORTED_Autoneg |
-					  SUPPORTED_FIBRE |
-					  SUPPORTED_Pause |
-					  SUPPORTED_Asym_Pause);
+			bp->port.supported |=3D (SUPPORTED_10000baseT_Full |
+					       SUPPORTED_1000baseT_Full |
+					       SUPPORTED_FIBRE |
+					       SUPPORTED_Pause |
+					       SUPPORTED_Asym_Pause);
 			break;
=20
 		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8072:
 			BNX2X_DEV_INFO("ext_phy_type 0x%x (8072)\n",
 				       ext_phy_type);
=20
-			bp->supported |=3D (SUPPORTED_10000baseT_Full |
-					  SUPPORTED_1000baseT_Full |
-					  SUPPORTED_FIBRE |
-					  SUPPORTED_Autoneg |
-					  SUPPORTED_Pause |
-					  SUPPORTED_Asym_Pause);
+			bp->port.supported |=3D (SUPPORTED_10000baseT_Full |
+					       SUPPORTED_1000baseT_Full |
+					       SUPPORTED_FIBRE |
+					       SUPPORTED_Autoneg |
+					       SUPPORTED_Pause |
+					       SUPPORTED_Asym_Pause);
 			break;
=20
 		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8073:
 			BNX2X_DEV_INFO("ext_phy_type 0x%x (8073)\n",
 				       ext_phy_type);
=20
-			bp->supported |=3D (SUPPORTED_10000baseT_Full |
-					  SUPPORTED_2500baseX_Full |
-					  SUPPORTED_1000baseT_Full |
-					  SUPPORTED_FIBRE |
-					  SUPPORTED_Autoneg |
-					  SUPPORTED_Pause |
-					  SUPPORTED_Asym_Pause);
+			bp->port.supported |=3D (SUPPORTED_10000baseT_Full |
+					       SUPPORTED_2500baseX_Full |
+					       SUPPORTED_1000baseT_Full |
+					       SUPPORTED_FIBRE |
+					       SUPPORTED_Autoneg |
+					       SUPPORTED_Pause |
+					       SUPPORTED_Asym_Pause);
 			break;
=20
 		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_SFX7101:
 			BNX2X_DEV_INFO("ext_phy_type 0x%x (SFX7101)\n",
 				       ext_phy_type);
=20
-			bp->supported |=3D (SUPPORTED_10000baseT_Full |
-					  SUPPORTED_TP |
-					  SUPPORTED_Autoneg |
-					  SUPPORTED_Pause |
-					  SUPPORTED_Asym_Pause);
+			bp->port.supported |=3D (SUPPORTED_10000baseT_Full |
+					       SUPPORTED_TP |
+					       SUPPORTED_Autoneg |
+					       SUPPORTED_Pause |
+					       SUPPORTED_Asym_Pause);
 			break;
=20
 		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_FAILURE:
@@ -5163,61 +5972,61 @@ static void bnx2x_link_settings_supported(struc=
t bnx2x *bp, u32 switch_cfg)
 			return;
 		}
=20
-		bp->phy_addr =3D REG_RD(bp, NIG_REG_XGXS0_CTRL_PHY_ADDR +
-				      port*0x18);
-		BNX2X_DEV_INFO("phy_addr 0x%x\n", bp->phy_addr);
+		bp->port.phy_addr =3D REG_RD(bp, NIG_REG_XGXS0_CTRL_PHY_ADDR +
+					   port*0x18);
+		BNX2X_DEV_INFO("phy_addr 0x%x\n", bp->port.phy_addr);
=20
 		break;
=20
 	default:
 		BNX2X_ERR("BAD switch_cfg link_config 0x%x\n",
-			  bp->link_config);
+			  bp->port.link_config);
 		return;
 	}
-	bp->link_params.phy_addr =3D bp->phy_addr;
+	bp->link_params.phy_addr =3D bp->port.phy_addr;
=20
 	/* mask what we support according to speed_cap_mask */
 	if (!(bp->link_params.speed_cap_mask &
 				PORT_HW_CFG_SPEED_CAPABILITY_D0_10M_HALF))
-		bp->supported &=3D ~SUPPORTED_10baseT_Half;
+		bp->port.supported &=3D ~SUPPORTED_10baseT_Half;
=20
 	if (!(bp->link_params.speed_cap_mask &
 				PORT_HW_CFG_SPEED_CAPABILITY_D0_10M_FULL))
-		bp->supported &=3D ~SUPPORTED_10baseT_Full;
+		bp->port.supported &=3D ~SUPPORTED_10baseT_Full;
=20
 	if (!(bp->link_params.speed_cap_mask &
 				PORT_HW_CFG_SPEED_CAPABILITY_D0_100M_HALF))
-		bp->supported &=3D ~SUPPORTED_100baseT_Half;
+		bp->port.supported &=3D ~SUPPORTED_100baseT_Half;
=20
 	if (!(bp->link_params.speed_cap_mask &
 				PORT_HW_CFG_SPEED_CAPABILITY_D0_100M_FULL))
-		bp->supported &=3D ~SUPPORTED_100baseT_Full;
+		bp->port.supported &=3D ~SUPPORTED_100baseT_Full;
=20
 	if (!(bp->link_params.speed_cap_mask &
 					PORT_HW_CFG_SPEED_CAPABILITY_D0_1G))
-		bp->supported &=3D ~(SUPPORTED_1000baseT_Half |
-				   SUPPORTED_1000baseT_Full);
+		bp->port.supported &=3D ~(SUPPORTED_1000baseT_Half |
+					SUPPORTED_1000baseT_Full);
=20
 	if (!(bp->link_params.speed_cap_mask &
 					PORT_HW_CFG_SPEED_CAPABILITY_D0_2_5G))
-		bp->supported &=3D ~SUPPORTED_2500baseX_Full;
+		bp->port.supported &=3D ~SUPPORTED_2500baseX_Full;
=20
 	if (!(bp->link_params.speed_cap_mask &
 					PORT_HW_CFG_SPEED_CAPABILITY_D0_10G))
-		bp->supported &=3D ~SUPPORTED_10000baseT_Full;
+		bp->port.supported &=3D ~SUPPORTED_10000baseT_Full;
=20
-	BNX2X_DEV_INFO("supported 0x%x\n", bp->supported);
+	BNX2X_DEV_INFO("supported 0x%x\n", bp->port.supported);
 }
=20
 static void bnx2x_link_settings_requested(struct bnx2x *bp)
 {
 	bp->link_params.req_duplex =3D DUPLEX_FULL;
=20
-	switch (bp->link_config & PORT_FEATURE_LINK_SPEED_MASK) {
+	switch (bp->port.link_config & PORT_FEATURE_LINK_SPEED_MASK) {
 	case PORT_FEATURE_LINK_SPEED_AUTO:
-		if (bp->supported & SUPPORTED_Autoneg) {
+		if (bp->port.supported & SUPPORTED_Autoneg) {
 			bp->link_params.req_line_speed =3D SPEED_AUTO_NEG;
-			bp->advertising =3D bp->supported;
+			bp->port.advertising =3D bp->port.supported;
 		} else {
 			u32 ext_phy_type =3D
 			    XGXS_EXT_PHY_TYPE(bp->link_params.ext_phy_config);
@@ -5228,7 +6037,7 @@ static void bnx2x_link_settings_requested(struct =
bnx2x *bp)
 			     PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8706)) {
 				/* force 10G, no AN */
 				bp->link_params.req_line_speed =3D SPEED_10000;
-				bp->advertising =3D
+				bp->port.advertising =3D
 						(ADVERTISED_10000baseT_Full |
 						 ADVERTISED_FIBRE);
 				break;
@@ -5236,98 +6045,98 @@ static void bnx2x_link_settings_requested(struc=
t bnx2x *bp)
 			BNX2X_ERR("NVRAM config error. "
 				  "Invalid link_config 0x%x"
 				  "  Autoneg not supported\n",
-				  bp->link_config);
+				  bp->port.link_config);
 			return;
 		}
 		break;
=20
 	case PORT_FEATURE_LINK_SPEED_10M_FULL:
-		if (bp->supported & SUPPORTED_10baseT_Full) {
+		if (bp->port.supported & SUPPORTED_10baseT_Full) {
 			bp->link_params.req_line_speed =3D SPEED_10;
-			bp->advertising =3D (ADVERTISED_10baseT_Full |
-					   ADVERTISED_TP);
+			bp->port.advertising =3D (ADVERTISED_10baseT_Full |
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
=20
 	case PORT_FEATURE_LINK_SPEED_10M_HALF:
-		if (bp->supported & SUPPORTED_10baseT_Half) {
+		if (bp->port.supported & SUPPORTED_10baseT_Half) {
 			bp->link_params.req_line_speed =3D SPEED_10;
 			bp->link_params.req_duplex =3D DUPLEX_HALF;
-			bp->advertising =3D (ADVERTISED_10baseT_Half |
-					   ADVERTISED_TP);
+			bp->port.advertising =3D (ADVERTISED_10baseT_Half |
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
=20
 	case PORT_FEATURE_LINK_SPEED_100M_FULL:
-		if (bp->supported & SUPPORTED_100baseT_Full) {
+		if (bp->port.supported & SUPPORTED_100baseT_Full) {
 			bp->link_params.req_line_speed =3D SPEED_100;
-			bp->advertising =3D (ADVERTISED_100baseT_Full |
-					   ADVERTISED_TP);
+			bp->port.advertising =3D (ADVERTISED_100baseT_Full |
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
=20
 	case PORT_FEATURE_LINK_SPEED_100M_HALF:
-		if (bp->supported & SUPPORTED_100baseT_Half) {
+		if (bp->port.supported & SUPPORTED_100baseT_Half) {
 			bp->link_params.req_line_speed =3D SPEED_100;
 			bp->link_params.req_duplex =3D DUPLEX_HALF;
-			bp->advertising =3D (ADVERTISED_100baseT_Half |
-					   ADVERTISED_TP);
+			bp->port.advertising =3D (ADVERTISED_100baseT_Half |
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
=20
 	case PORT_FEATURE_LINK_SPEED_1G:
-		if (bp->supported & SUPPORTED_1000baseT_Full) {
+		if (bp->port.supported & SUPPORTED_1000baseT_Full) {
 			bp->link_params.req_line_speed =3D SPEED_1000;
-			bp->advertising =3D (ADVERTISED_1000baseT_Full |
-					   ADVERTISED_TP);
+			bp->port.advertising =3D (ADVERTISED_1000baseT_Full |
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
=20
 	case PORT_FEATURE_LINK_SPEED_2_5G:
-		if (bp->supported & SUPPORTED_2500baseX_Full) {
+		if (bp->port.supported & SUPPORTED_2500baseX_Full) {
 			bp->link_params.req_line_speed =3D SPEED_2500;
-			bp->advertising =3D (ADVERTISED_2500baseX_Full |
-					   ADVERTISED_TP);
+			bp->port.advertising =3D (ADVERTISED_2500baseX_Full |
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
@@ -5336,15 +6145,15 @@ static void bnx2x_link_settings_requested(struc=
t bnx2x *bp)
 	case PORT_FEATURE_LINK_SPEED_10G_CX4:
 	case PORT_FEATURE_LINK_SPEED_10G_KX4:
 	case PORT_FEATURE_LINK_SPEED_10G_KR:
-		if (bp->supported & SUPPORTED_10000baseT_Full) {
+		if (bp->port.supported & SUPPORTED_10000baseT_Full) {
 			bp->link_params.req_line_speed =3D SPEED_10000;
-			bp->advertising =3D (ADVERTISED_10000baseT_Full |
-					   ADVERTISED_FIBRE);
+			bp->port.advertising =3D (ADVERTISED_10000baseT_Full |
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
@@ -5353,66 +6162,35 @@ static void bnx2x_link_settings_requested(struc=
t bnx2x *bp)
 	default:
 		BNX2X_ERR("NVRAM config error. "
 			  "BAD link speed link_config 0x%x\n",
-			  bp->link_config);
+			  bp->port.link_config);
 		bp->link_params.req_line_speed =3D SPEED_AUTO_NEG;
-		bp->advertising =3D bp->supported;
+		bp->port.advertising =3D bp->port.supported;
 		break;
 	}
 	BNX2X_DEV_INFO("req_line_speed %d  req_duplex %d\n",
 		       bp->link_params.req_line_speed,
 		       bp->link_params.req_duplex);
=20
-	bp->link_params.req_flow_ctrl =3D (bp->link_config &
-			     PORT_FEATURE_FLOW_CONTROL_MASK);
+	bp->link_params.req_flow_ctrl =3D (bp->port.link_config &
+					 PORT_FEATURE_FLOW_CONTROL_MASK);
 	if ((bp->link_params.req_flow_ctrl =3D=3D FLOW_CTRL_AUTO) &&
-	    (!bp->supported & SUPPORTED_Autoneg))
+	    (!bp->port.supported & SUPPORTED_Autoneg))
 		bp->link_params.req_flow_ctrl =3D FLOW_CTRL_NONE;
=20
 	BNX2X_DEV_INFO("req_flow_ctrl 0x%x"
 		       " advertising 0x%x\n",
 		       bp->link_params.req_flow_ctrl,
-		       bp->advertising);
+		       bp->port.advertising);
 }
=20
-static void bnx2x_get_hwinfo(struct bnx2x *bp)
+static void bnx2x_get_port_hwinfo(struct bnx2x *bp)
 {
-	u32 val, val2, val3, val4, id;
-	int port =3D bp->port;
-
-	bp->shmem_base =3D REG_RD(bp, MISC_REG_SHARED_MEM_ADDR);
-	BNX2X_DEV_INFO("shmem offset is %x\n", bp->shmem_base);
-
-	/* Get the chip revision id and number. */
-	/* chip num:16-31, rev:12-15, metal:4-11, bond_id:0-3 */
-	val =3D REG_RD(bp, MISC_REG_CHIP_NUM);
-	id =3D ((val & 0xffff) << 16);
-	val =3D REG_RD(bp, MISC_REG_CHIP_REV);
-	id |=3D ((val & 0xf) << 12);
-	val =3D REG_RD(bp, MISC_REG_CHIP_METAL);
-	id |=3D ((val & 0xff) << 4);
-	REG_RD(bp, MISC_REG_BOND_ID);
-	id |=3D (val & 0xf);
-	bp->chip_id =3D id;
-	BNX2X_DEV_INFO("chip ID is %x\n", id);
+	int port =3D BP_PORT(bp);
+	u32 val, val2;
=20
 	bp->link_params.bp =3D bp;
+	bp->link_params.port =3D port;
=20
-	if (!bp->shmem_base || (bp->shmem_base !=3D 0xAF900)) {
-		BNX2X_DEV_INFO("MCP not active\n");
-		nomcp =3D 1;
-		goto set_mac;
-	}
-
-	val =3D SHMEM_RD(bp, validity_map[port]);
-	if ((val & (SHR_MEM_VALIDITY_DEV_INFO | SHR_MEM_VALIDITY_MB))
-		!=3D (SHR_MEM_VALIDITY_DEV_INFO | SHR_MEM_VALIDITY_MB))
-		BNX2X_ERR("BAD MCP validity signature\n");
-
-	bp->fw_seq =3D (SHMEM_RD(bp, func_mb[port].drv_mb_header) &
-		      DRV_MSG_SEQ_NUMBER_MASK);
-
-	bp->hw_config =3D SHMEM_RD(bp, dev_info.shared_hw_config.config);
-	bp->board =3D SHMEM_RD(bp, dev_info.shared_hw_config.board);
 	bp->link_params.serdes_config =3D
 		SHMEM_RD(bp, dev_info.port_hw_config[port].serdes_config);
 	bp->link_params.lane_config =3D
@@ -5424,7 +6202,7 @@ static void bnx2x_get_hwinfo(struct bnx2x *bp)
 		SHMEM_RD(bp,
 			 dev_info.port_hw_config[port].speed_capability_mask);
=20
-	bp->link_config =3D
+	bp->port.link_config =3D
 		SHMEM_RD(bp, dev_info.port_feature_config[port].link_config);
=20
 	BNX2X_DEV_INFO("serdes_config (%08x)  lane_config (%08x)\n"
@@ -5434,9 +6212,9 @@ static void bnx2x_get_hwinfo(struct bnx2x *bp)
 		       bp->link_params.lane_config,
 		       bp->link_params.ext_phy_config,
 		       bp->link_params.speed_cap_mask,
-		       bp->link_config);
+		       bp->port.link_config);
=20
-	bp->link_params.switch_cfg =3D (bp->link_config &
+	bp->link_params.switch_cfg =3D (bp->port.link_config &
 				      PORT_FEATURE_CONNECTED_SWITCH_MASK);
 	bnx2x_link_settings_supported(bp, bp->link_params.switch_cfg);
=20
@@ -5452,43 +6230,126 @@ static void bnx2x_get_hwinfo(struct bnx2x *bp)
 	bp->dev->dev_addr[5] =3D (u8)(val & 0xff);
 	memcpy(bp->link_params.mac_addr, bp->dev->dev_addr, ETH_ALEN);
 	memcpy(bp->dev->perm_addr, bp->dev->dev_addr, ETH_ALEN);
+}
=20
+static int bnx2x_get_hwinfo(struct bnx2x *bp)
+{
+	int func =3D BP_FUNC(bp);
+	u32 val, val2;
+	int rc =3D 0;
=20
+	bnx2x_get_common_hwinfo(bp);
=20
-	val =3D SHMEM_RD(bp, dev_info.shared_hw_config.part_num);
-	val2 =3D SHMEM_RD(bp, dev_info.shared_hw_config.part_num[4]);
-	val3 =3D SHMEM_RD(bp, dev_info.shared_hw_config.part_num[8]);
-	val4 =3D SHMEM_RD(bp, dev_info.shared_hw_config.part_num[12]);
+	bp->e1hovl =3D 0;
+	bp->e1hmf =3D 0;
+	if (CHIP_IS_E1H(bp)) {
+		bp->mf_config =3D
+			SHMEM_RD(bp, mf_cfg.func_mf_config[func].config);
=20
-	printk(KERN_INFO PFX "part number %X-%X-%X-%X\n",
-	       val, val2, val3, val4);
+		val =3D
+		   (SHMEM_RD(bp, mf_cfg.func_mf_config[func].e1hov_tag) &
+		    FUNC_MF_CFG_E1HOV_TAG_MASK);
+		if (val !=3D FUNC_MF_CFG_E1HOV_TAG_DEFAULT) {
=20
-	/* bc ver */
-	if (!nomcp) {
-		bp->bc_ver =3D val =3D ((SHMEM_RD(bp, dev_info.bc_rev)) >> 8);
-		BNX2X_DEV_INFO("bc_ver %X\n", val);
-		if (val < BNX2X_BC_VER) {
-			/* for now only warn
-			 * later we might need to enforce this */
-			BNX2X_ERR("This driver needs bc_ver %X but found %X,"
-				  " please upgrade BC\n", BNX2X_BC_VER, val);
+			bp->e1hovl =3D val;
+			bp->e1hmf =3D 1;
+			BNX2X_DEV_INFO("MF mode  E1HOVL for func %d is %d "
+				       "(0x%04x)\n",
+				       func, bp->e1hovl, bp->e1hovl);
+		} else {
+			BNX2X_DEV_INFO("Single function mode\n");
+			if (BP_E1HVN(bp)) {
+				BNX2X_ERR("!!!  No valid E1HOVL for func %d,"
+					  "  aborting\n", func);
+				rc =3D -EPERM;
+			}
 		}
-	} else {
-		bp->bc_ver =3D 0;
 	}
=20
-	val =3D REG_RD(bp, MCP_REG_MCPR_NVM_CFG4);
-	bp->flash_size =3D (NVRAM_1MB_SIZE << (val & MCPR_NVM_CFG4_FLASH_SIZE=
));
-	BNX2X_DEV_INFO("flash_size 0x%x (%d)\n",
-		       bp->flash_size, bp->flash_size);
+	if (!BP_NOMCP(bp)) {
+		bnx2x_get_port_hwinfo(bp);
+
+		bp->fw_seq =3D (SHMEM_RD(bp, func_mb[func].drv_mb_header) &
+			      DRV_MSG_SEQ_NUMBER_MASK);
+		BNX2X_DEV_INFO("fw_seq (%08x)\n", bp->fw_seq);
+	}
+
+	if (IS_E1HMF(bp)) {
+		val2 =3D SHMEM_RD(bp, mf_cfg.func_mf_config[func].mac_upper);
+		val =3D SHMEM_RD(bp,  mf_cfg.func_mf_config[func].mac_lower);
+		if ((val2 !=3D FUNC_MF_CFG_UPPERMAC_DEFAULT) &&
+		    (val !=3D FUNC_MF_CFG_LOWERMAC_DEFAULT)) {
+			bp->dev->dev_addr[0] =3D (u8)(val2 >> 8 & 0xff);
+			bp->dev->dev_addr[1] =3D (u8)(val2 & 0xff);
+			bp->dev->dev_addr[2] =3D (u8)(val >> 24 & 0xff);
+			bp->dev->dev_addr[3] =3D (u8)(val >> 16 & 0xff);
+			bp->dev->dev_addr[4] =3D (u8)(val >> 8  & 0xff);
+			bp->dev->dev_addr[5] =3D (u8)(val & 0xff);
+			memcpy(bp->link_params.mac_addr, bp->dev->dev_addr,
+			       ETH_ALEN);
+			memcpy(bp->dev->perm_addr, bp->dev->dev_addr,
+			       ETH_ALEN);
+		}
=20
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
+static int bnx2x_init_bp(struct bnx2x *bp)
+{
+	int func =3D BP_FUNC(bp);
+	int rc;
+
+	if (nomcp)
+		bp->flags |=3D NO_MCP_FLAG;
+
+	mutex_init(&bp->port.phy_mutex);
+
+	INIT_WORK(&bp->sp_task, bnx2x_sp_task);
+	INIT_WORK(&bp->reset_task, bnx2x_reset_task);
+
+	rc =3D bnx2x_get_hwinfo(bp);
+
+	/* need to reset chip if undi was active */
+	if (!BP_NOMCP(bp))
+		bnx2x_undi_unload(bp);
+
+	if (CHIP_REV_IS_FPGA(bp))
+		printk(KERN_ERR PFX "FPGA detected\n");
+
+	if (BP_NOMCP(bp) && (func =3D=3D 0))
+		printk(KERN_ERR PFX
+		       "MCP disabled, must load devices in order!\n");
+
+	bp->tx_ring_size =3D MAX_TX_AVAIL;
+	bp->rx_ring_size =3D MAX_RX_AVAIL;
+
+	bp->rx_csum =3D 1;
+	bp->rx_offset =3D 0;
+
+	bp->tx_ticks =3D 50;
+	bp->rx_ticks =3D 25;
=20
-set_mac: /* only supposed to happen on emulation/FPGA */
-	BNX2X_ERR("warning rendom MAC workaround active\n");
-	random_ether_addr(bp->dev->dev_addr);
-	memcpy(bp->dev->perm_addr, bp->dev->dev_addr, 6);
+	bp->stats_ticks =3D 1000000 & 0xffff00;
+
+	bp->timer_interval =3D (CHIP_REV_IS_SLOW(bp) ? 5*HZ : HZ);
+	bp->current_interval =3D (poll ? poll : bp->timer_interval);
+
+	init_timer(&bp->timer);
+	bp->timer.expires =3D jiffies + bp->current_interval;
+	bp->timer.data =3D (unsigned long) bp;
+	bp->timer.function =3D bnx2x_timer;
=20
+	return rc;
 }
=20
 /*
@@ -5501,8 +6362,8 @@ static int bnx2x_get_settings(struct net_device *=
dev, struct ethtool_cmd *cmd)
 {
 	struct bnx2x *bp =3D netdev_priv(dev);
=20
-	cmd->supported =3D bp->supported;
-	cmd->advertising =3D bp->advertising;
+	cmd->supported =3D bp->port.supported;
+	cmd->advertising =3D bp->port.advertising;
=20
 	if (netif_carrier_ok(dev)) {
 		cmd->speed =3D bp->link_vars.line_speed;
@@ -5511,6 +6372,9 @@ static int bnx2x_get_settings(struct net_device *=
dev, struct ethtool_cmd *cmd)
 		cmd->speed =3D bp->link_params.req_line_speed;
 		cmd->duplex =3D bp->link_params.req_duplex;
 	}
+	if (IS_E1HMF(bp))
+		cmd->speed =3D ((bp->mf_config & FUNC_MF_CFG_MAX_BW_MASK) >>
+			      FUNC_MF_CFG_MAX_BW_SHIFT) * 100;
=20
 	if (bp->link_params.switch_cfg =3D=3D SWITCH_CFG_10G) {
 		u32 ext_phy_type =3D
@@ -5542,7 +6406,7 @@ static int bnx2x_get_settings(struct net_device *=
dev, struct ethtool_cmd *cmd)
 	} else
 		cmd->port =3D PORT_TP;
=20
-	cmd->phy_address =3D bp->phy_addr;
+	cmd->phy_address =3D bp->port.phy_addr;
 	cmd->transceiver =3D XCVR_INTERNAL;
=20
 	if (bp->link_params.req_line_speed =3D=3D SPEED_AUTO_NEG)
@@ -5569,6 +6433,9 @@ static int bnx2x_set_settings(struct net_device *=
dev, struct ethtool_cmd *cmd)
 	struct bnx2x *bp =3D netdev_priv(dev);
 	u32 advertising;
=20
+	if (IS_E1HMF(bp))
+		return 0;
+
 	DP(NETIF_MSG_LINK, "ethtool_cmd: cmd %d\n"
 	   DP_LEVEL "  supported 0x%x  advertising 0x%x  speed %d\n"
 	   DP_LEVEL "  duplex %d  port %d  phy_address %d  transceiver %d\n"
@@ -5578,24 +6445,25 @@ static int bnx2x_set_settings(struct net_device=
 *dev, struct ethtool_cmd *cmd)
 	   cmd->autoneg, cmd->maxtxpkt, cmd->maxrxpkt);
=20
 	if (cmd->autoneg =3D=3D AUTONEG_ENABLE) {
-		if (!(bp->supported & SUPPORTED_Autoneg)) {
-			DP(NETIF_MSG_LINK, "Aotoneg not supported\n");
+		if (!(bp->port.supported & SUPPORTED_Autoneg)) {
+			DP(NETIF_MSG_LINK, "Autoneg not supported\n");
 			return -EINVAL;
 		}
=20
 		/* advertise the requested speed and duplex if supported */
-		cmd->advertising &=3D bp->supported;
+		cmd->advertising &=3D bp->port.supported;
=20
 		bp->link_params.req_line_speed =3D SPEED_AUTO_NEG;
 		bp->link_params.req_duplex =3D DUPLEX_FULL;
-		bp->advertising |=3D (ADVERTISED_Autoneg | cmd->advertising);
+		bp->port.advertising |=3D (ADVERTISED_Autoneg |
+					 cmd->advertising);
=20
 	} else { /* forced speed */
 		/* advertise the requested speed and duplex if supported */
 		switch (cmd->speed) {
 		case SPEED_10:
 			if (cmd->duplex =3D=3D DUPLEX_FULL) {
-				if (!(bp->supported &
+				if (!(bp->port.supported &
 				      SUPPORTED_10baseT_Full)) {
 					DP(NETIF_MSG_LINK,
 					   "10M full not supported\n");
@@ -5605,7 +6473,7 @@ static int bnx2x_set_settings(struct net_device *=
dev, struct ethtool_cmd *cmd)
 				advertising =3D (ADVERTISED_10baseT_Full |
 					       ADVERTISED_TP);
 			} else {
-				if (!(bp->supported &
+				if (!(bp->port.supported &
 				      SUPPORTED_10baseT_Half)) {
 					DP(NETIF_MSG_LINK,
 					   "10M half not supported\n");
@@ -5619,7 +6487,7 @@ static int bnx2x_set_settings(struct net_device *=
dev, struct ethtool_cmd *cmd)
=20
 		case SPEED_100:
 			if (cmd->duplex =3D=3D DUPLEX_FULL) {
-				if (!(bp->supported &
+				if (!(bp->port.supported &
 						SUPPORTED_100baseT_Full)) {
 					DP(NETIF_MSG_LINK,
 					   "100M full not supported\n");
@@ -5629,7 +6497,7 @@ static int bnx2x_set_settings(struct net_device *=
dev, struct ethtool_cmd *cmd)
 				advertising =3D (ADVERTISED_100baseT_Full |
 					       ADVERTISED_TP);
 			} else {
-				if (!(bp->supported &
+				if (!(bp->port.supported &
 						SUPPORTED_100baseT_Half)) {
 					DP(NETIF_MSG_LINK,
 					   "100M half not supported\n");
@@ -5647,7 +6515,7 @@ static int bnx2x_set_settings(struct net_device *=
dev, struct ethtool_cmd *cmd)
 				return -EINVAL;
 			}
=20
-			if (!(bp->supported & SUPPORTED_1000baseT_Full)) {
+			if (!(bp->port.supported & SUPPORTED_1000baseT_Full)) {
 				DP(NETIF_MSG_LINK, "1G full not supported\n");
 				return -EINVAL;
 			}
@@ -5663,7 +6531,7 @@ static int bnx2x_set_settings(struct net_device *=
dev, struct ethtool_cmd *cmd)
 				return -EINVAL;
 			}
=20
-			if (!(bp->supported & SUPPORTED_2500baseX_Full)) {
+			if (!(bp->port.supported & SUPPORTED_2500baseX_Full)) {
 				DP(NETIF_MSG_LINK,
 				   "2.5G full not supported\n");
 				return -EINVAL;
@@ -5679,7 +6547,7 @@ static int bnx2x_set_settings(struct net_device *=
dev, struct ethtool_cmd *cmd)
 				return -EINVAL;
 			}
=20
-			if (!(bp->supported & SUPPORTED_10000baseT_Full)) {
+			if (!(bp->port.supported & SUPPORTED_10000baseT_Full)) {
 				DP(NETIF_MSG_LINK, "10G full not supported\n");
 				return -EINVAL;
 			}
@@ -5695,16 +6563,18 @@ static int bnx2x_set_settings(struct net_device=
 *dev, struct ethtool_cmd *cmd)
=20
 		bp->link_params.req_line_speed =3D cmd->speed;
 		bp->link_params.req_duplex =3D cmd->duplex;
-		bp->advertising =3D advertising;
+		bp->port.advertising =3D advertising;
 	}
=20
 	DP(NETIF_MSG_LINK, "req_line_speed %d\n"
 	   DP_LEVEL "  req_duplex %d  advertising 0x%x\n",
 	   bp->link_params.req_line_speed, bp->link_params.req_duplex,
-	   bp->advertising);
+	   bp->port.advertising);
=20
-	bnx2x_stop_stats(bp);
-	bnx2x_link_set(bp);
+	if (netif_running(dev)) {
+		bnx2x_stop_stats(bp);
+		bnx2x_link_set(bp);
+	}
=20
 	return 0;
 }
@@ -5721,21 +6591,23 @@ static void bnx2x_get_drvinfo(struct net_device=
 *dev,
 	strcpy(info->version, DRV_MODULE_VERSION);
=20
 	phy_fw_ver[0] =3D '\0';
-	bnx2x_phy_hw_lock(bp);
-	bnx2x_get_ext_phy_fw_version(&bp->link_params,
-				     (bp->state !=3D BNX2X_STATE_CLOSED),
-				     phy_fw_ver, PHY_FW_VER_LEN);
-	bnx2x_phy_hw_unlock(bp);
+	if (bp->port.pmf) {
+		bnx2x_phy_hw_lock(bp);
+		bnx2x_get_ext_phy_fw_version(&bp->link_params,
+					     (bp->state !=3D BNX2X_STATE_CLOSED),
+					     phy_fw_ver, PHY_FW_VER_LEN);
+		bnx2x_phy_hw_unlock(bp);
+	}
=20
 	snprintf(info->fw_version, 32, "%d.%d.%d:%d BC:%x%s%s",
 		 BCM_5710_FW_MAJOR_VERSION, BCM_5710_FW_MINOR_VERSION,
 		 BCM_5710_FW_REVISION_VERSION,
-		 BCM_5710_FW_COMPILE_FLAGS, bp->bc_ver,
+		 BCM_5710_FW_COMPILE_FLAGS, bp->common.bc_ver,
 		 ((phy_fw_ver[0] !=3D '\0')? " PHY:":""), phy_fw_ver);
 	strcpy(info->bus_info, pci_name(bp->pdev));
 	info->n_stats =3D BNX2X_NUM_STATS;
 	info->testinfo_len =3D BNX2X_NUM_TESTS;
-	info->eedump_len =3D bp->flash_size;
+	info->eedump_len =3D bp->common.flash_size;
 	info->regdump_len =3D 0;
 }
=20
@@ -5793,13 +6665,13 @@ static int bnx2x_nway_reset(struct net_device *=
dev)
 {
 	struct bnx2x *bp =3D netdev_priv(dev);
=20
-	if (bp->state !=3D BNX2X_STATE_OPEN) {
-		DP(NETIF_MSG_PROBE, "state is %x, returning\n", bp->state);
-		return -EAGAIN;
-	}
+	if (!bp->port.pmf)
+		return 0;
=20
-	bnx2x_stop_stats(bp);
-	bnx2x_link_set(bp);
+	if (netif_running(dev)) {
+		bnx2x_stop_stats(bp);
+		bnx2x_link_set(bp);
+	}
=20
 	return 0;
 }
@@ -5808,12 +6680,12 @@ static int bnx2x_get_eeprom_len(struct net_devi=
ce *dev)
 {
 	struct bnx2x *bp =3D netdev_priv(dev);
=20
-	return bp->flash_size;
+	return bp->common.flash_size;
 }
=20
 static int bnx2x_acquire_nvram_lock(struct bnx2x *bp)
 {
-	int port =3D bp->port;
+	int port =3D BP_PORT(bp);
 	int count, i;
 	u32 val =3D 0;
=20
@@ -5835,7 +6707,7 @@ static int bnx2x_acquire_nvram_lock(struct bnx2x =
*bp)
 	}
=20
 	if (!(val & (MCPR_NVM_SW_ARB_ARB_ARB1 << port))) {
-		DP(NETIF_MSG_NVM, "cannot get access to nvram interface\n");
+		DP(BNX2X_MSG_NVM, "cannot get access to nvram interface\n");
 		return -EBUSY;
 	}
=20
@@ -5844,7 +6716,7 @@ static int bnx2x_acquire_nvram_lock(struct bnx2x =
*bp)
=20
 static int bnx2x_release_nvram_lock(struct bnx2x *bp)
 {
-	int port =3D bp->port;
+	int port =3D BP_PORT(bp);
 	int count, i;
 	u32 val =3D 0;
=20
@@ -5866,7 +6738,7 @@ static int bnx2x_release_nvram_lock(struct bnx2x =
*bp)
 	}
=20
 	if (val & (MCPR_NVM_SW_ARB_ARB_ARB1 << port)) {
-		DP(NETIF_MSG_NVM, "cannot free access to nvram interface\n");
+		DP(BNX2X_MSG_NVM, "cannot free access to nvram interface\n");
 		return -EBUSY;
 	}
=20
@@ -5930,7 +6802,6 @@ static int bnx2x_nvram_read_dword(struct bnx2x *b=
p, u32 offset, u32 *ret_val,
=20
 		if (val & MCPR_NVM_COMMAND_DONE) {
 			val =3D REG_RD(bp, MCP_REG_MCPR_NVM_READ);
-			DP(NETIF_MSG_NVM, "val 0x%08x\n", val);
 			/* we read nvram data in cpu order
 			 * but ethtool sees it as an array of bytes
 			 * converting to big-endian will do the work */
@@ -5952,16 +6823,16 @@ static int bnx2x_nvram_read(struct bnx2x *bp, u=
32 offset, u8 *ret_buf,
 	u32 val;
=20
 	if ((offset & 0x03) || (buf_size & 0x03) || (buf_size =3D=3D 0)) {
-		DP(NETIF_MSG_NVM,
+		DP(BNX2X_MSG_NVM,
 		   "Invalid parameter: offset 0x%x  buf_size 0x%x\n",
 		   offset, buf_size);
 		return -EINVAL;
 	}
=20
-	if (offset + buf_size > bp->flash_size) {
-		DP(NETIF_MSG_NVM, "Invalid parameter: offset (0x%x) +"
+	if (offset + buf_size > bp->common.flash_size) {
+		DP(BNX2X_MSG_NVM, "Invalid parameter: offset (0x%x) +"
 				  " buf_size (0x%x) > flash_size (0x%x)\n",
-		   offset, buf_size, bp->flash_size);
+		   offset, buf_size, bp->common.flash_size);
 		return -EINVAL;
 	}
=20
@@ -6005,7 +6876,7 @@ static int bnx2x_get_eeprom(struct net_device *de=
v,
 	struct bnx2x *bp =3D netdev_priv(dev);
 	int rc;
=20
-	DP(NETIF_MSG_NVM, "ethtool_eeprom: cmd %d\n"
+	DP(BNX2X_MSG_NVM, "ethtool_eeprom: cmd %d\n"
 	   DP_LEVEL "  magic 0x%x  offset 0x%x (%d)  len 0x%x (%d)\n",
 	   eeprom->cmd, eeprom->magic, eeprom->offset, eeprom->offset,
 	   eeprom->len, eeprom->len);
@@ -6067,10 +6938,10 @@ static int bnx2x_nvram_write1(struct bnx2x *bp,=
 u32 offset, u8 *data_buf,
 	u32 align_offset;
 	u32 val;
=20
-	if (offset + buf_size > bp->flash_size) {
-		DP(NETIF_MSG_NVM, "Invalid parameter: offset (0x%x) +"
+	if (offset + buf_size > bp->common.flash_size) {
+		DP(BNX2X_MSG_NVM, "Invalid parameter: offset (0x%x) +"
 				  " buf_size (0x%x) > flash_size (0x%x)\n",
-		   offset, buf_size, bp->flash_size);
+		   offset, buf_size, bp->common.flash_size);
 		return -EINVAL;
 	}
=20
@@ -6094,8 +6965,6 @@ static int bnx2x_nvram_write1(struct bnx2x *bp, u=
32 offset, u8 *data_buf,
 		 * convert it back to cpu order */
 		val =3D be32_to_cpu(val);
=20
-		DP(NETIF_MSG_NVM, "val 0x%08x\n", val);
-
 		rc =3D bnx2x_nvram_write_dword(bp, align_offset, val,
 					     cmd_flags);
 	}
@@ -6115,21 +6984,20 @@ static int bnx2x_nvram_write(struct bnx2x *bp, =
u32 offset, u8 *data_buf,
 	u32 val;
 	u32 written_so_far;
=20
-	if (buf_size =3D=3D 1) {    /* ethtool */
+	if (buf_size =3D=3D 1)	/* ethtool */
 		return bnx2x_nvram_write1(bp, offset, data_buf, buf_size);
-	}
=20
 	if ((offset & 0x03) || (buf_size & 0x03) || (buf_size =3D=3D 0)) {
-		DP(NETIF_MSG_NVM,
+		DP(BNX2X_MSG_NVM,
 		   "Invalid parameter: offset 0x%x  buf_size 0x%x\n",
 		   offset, buf_size);
 		return -EINVAL;
 	}
=20
-	if (offset + buf_size > bp->flash_size) {
-		DP(NETIF_MSG_NVM, "Invalid parameter: offset (0x%x) +"
+	if (offset + buf_size > bp->common.flash_size) {
+		DP(BNX2X_MSG_NVM, "Invalid parameter: offset (0x%x) +"
 				  " buf_size (0x%x) > flash_size (0x%x)\n",
-		   offset, buf_size, bp->flash_size);
+		   offset, buf_size, bp->common.flash_size);
 		return -EINVAL;
 	}
=20
@@ -6152,7 +7020,6 @@ static int bnx2x_nvram_write(struct bnx2x *bp, u3=
2 offset, u8 *data_buf,
 			cmd_flags |=3D MCPR_NVM_COMMAND_FIRST;
=20
 		memcpy(&val, data_buf, 4);
-		DP(NETIF_MSG_NVM, "val 0x%08x\n", val);
=20
 		rc =3D bnx2x_nvram_write_dword(bp, offset, val, cmd_flags);
=20
@@ -6176,7 +7043,7 @@ static int bnx2x_set_eeprom(struct net_device *de=
v,
 	struct bnx2x *bp =3D netdev_priv(dev);
 	int rc;
=20
-	DP(NETIF_MSG_NVM, "ethtool_eeprom: cmd %d\n"
+	DP(BNX2X_MSG_NVM, "ethtool_eeprom: cmd %d\n"
 	   DP_LEVEL "  magic 0x%x  offset 0x%x (%d)  len 0x%x (%d)\n",
 	   eeprom->cmd, eeprom->magic, eeprom->offset, eeprom->offset,
 	   eeprom->len, eeprom->len);
@@ -6184,20 +7051,23 @@ static int bnx2x_set_eeprom(struct net_device *=
dev,
 	/* parameters already validated in ethtool_set_eeprom */
=20
 	/* If the magic number is PHY (0x00504859) upgrade the PHY FW */
-	if (eeprom->magic =3D=3D 0x00504859) {
-
-		bnx2x_phy_hw_lock(bp);
-		rc =3D bnx2x_flash_download(bp, bp->port,
-				     bp->link_params.ext_phy_config,
-				     (bp->state !=3D BNX2X_STATE_CLOSED),
-				     eebuf, eeprom->len);
-		rc |=3D bnx2x_link_reset(&bp->link_params,
-				       &bp->link_vars);
-		rc |=3D bnx2x_phy_init(&bp->link_params,
-				     &bp->link_vars);
-		bnx2x_phy_hw_unlock(bp);
-
-	} else
+	if (eeprom->magic =3D=3D 0x00504859)
+		if (bp->port.pmf) {
+
+			bnx2x_phy_hw_lock(bp);
+			rc =3D bnx2x_flash_download(bp, BP_PORT(bp),
+					     bp->link_params.ext_phy_config,
+					     (bp->state !=3D BNX2X_STATE_CLOSED),
+					     eebuf, eeprom->len);
+				rc |=3D bnx2x_link_reset(&bp->link_params,
+						       &bp->link_vars);
+				rc |=3D bnx2x_phy_init(&bp->link_params,
+						     &bp->link_vars);
+			bnx2x_phy_hw_unlock(bp);
+
+		} else /* Only the PMF can access the PHY */
+			return -EINVAL;
+	else
 		rc =3D bnx2x_nvram_write(bp, eeprom->offset, eebuf, eeprom->len);
=20
 	return rc;
@@ -6235,7 +7105,7 @@ static int bnx2x_set_coalesce(struct net_device *=
dev,
 		bp->stats_ticks =3D 0xffff00;
 	bp->stats_ticks &=3D 0xffff00;
=20
-	if (netif_running(bp->dev))
+	if (netif_running(dev))
 		bnx2x_update_coalesce(bp);
=20
 	return 0;
@@ -6271,9 +7141,9 @@ static int bnx2x_set_ringparam(struct net_device =
*dev,
 	bp->rx_ring_size =3D ering->rx_pending;
 	bp->tx_ring_size =3D ering->tx_pending;
=20
-	if (netif_running(bp->dev)) {
-		bnx2x_nic_unload(bp, 0);
-		bnx2x_nic_load(bp, 0);
+	if (netif_running(dev)) {
+		bnx2x_nic_unload(bp, UNLOAD_NORMAL);
+		bnx2x_nic_load(bp, LOAD_NORMAL);
 	}
=20
 	return 0;
@@ -6301,13 +7171,16 @@ static int bnx2x_set_pauseparam(struct net_devi=
ce *dev,
 {
 	struct bnx2x *bp =3D netdev_priv(dev);
=20
+	if (IS_E1HMF(bp))
+		return 0;
+
 	DP(NETIF_MSG_LINK, "ethtool_pauseparam: cmd %d\n"
 	   DP_LEVEL "  autoneg %d  rx_pause %d  tx_pause %d\n",
 	   epause->cmd, epause->autoneg, epause->rx_pause, epause->tx_pause);
=20
 	if (epause->autoneg) {
-		if (!(bp->supported & SUPPORTED_Autoneg)) {
-			DP(NETIF_MSG_LINK, "Aotoneg not supported\n");
+		if (!(bp->port.supported & SUPPORTED_Autoneg)) {
+			DP(NETIF_MSG_LINK, "Autoneg not supported\n");
 			return -EINVAL;
 		}
=20
@@ -6330,8 +7203,10 @@ static int bnx2x_set_pauseparam(struct net_devic=
e *dev,
 	DP(NETIF_MSG_LINK, "req_flow_ctrl 0x%x\n",
 	   bp->link_params.req_flow_ctrl);
=20
-	bnx2x_stop_stats(bp);
-	bnx2x_link_set(bp);
+	if (netif_running(dev)) {
+		bnx2x_stop_stats(bp);
+		bnx2x_link_set(bp);
+	}
=20
 	return 0;
 }
@@ -6533,18 +7408,25 @@ static void bnx2x_get_ethtool_stats(struct net_=
device *dev,
 static int bnx2x_phys_id(struct net_device *dev, u32 data)
 {
 	struct bnx2x *bp =3D netdev_priv(dev);
+	int port =3D BP_PORT(bp);
 	int i;
=20
+	if (!netif_running(dev))
+		return 0;
+
+	if (!bp->port.pmf)
+		return 0;
+
 	if (data =3D=3D 0)
 		data =3D 2;
=20
 	for (i =3D 0; i < (data * 2); i++) {
 		if ((i % 2) =3D=3D 0)
-			bnx2x_set_led(bp, bp->port, LED_MODE_OPER, SPEED_1000,
+			bnx2x_set_led(bp, port, LED_MODE_OPER, SPEED_1000,
 				      bp->link_params.hw_led_mode,
 				      bp->link_params.chip_id);
 		else
-			bnx2x_set_led(bp, bp->port, LED_MODE_OFF, 0,
+			bnx2x_set_led(bp, port, LED_MODE_OFF, 0,
 				      bp->link_params.hw_led_mode,
 				      bp->link_params.chip_id);
=20
@@ -6554,7 +7436,7 @@ static int bnx2x_phys_id(struct net_device *dev, =
u32 data)
 	}
=20
 	if (bp->link_vars.link_up)
-		bnx2x_set_led(bp, bp->port, LED_MODE_OPER,
+		bnx2x_set_led(bp, port, LED_MODE_OPER,
 			      bp->link_vars.line_speed,
 			      bp->link_params.hw_led_mode,
 			      bp->link_params.chip_id);
@@ -6611,8 +7493,7 @@ static int bnx2x_set_power_state(struct bnx2x *bp=
, pci_power_t state)
=20
 	switch (state) {
 	case PCI_D0:
-		pci_write_config_word(bp->pdev,
-				      bp->pm_cap + PCI_PM_CTRL,
+		pci_write_config_word(bp->pdev, bp->pm_cap + PCI_PM_CTRL,
 				      ((pmcsr & ~PCI_PM_CTRL_STATE_MASK) |
 				       PCI_PM_CTRL_PME_STATUS));
=20
@@ -6646,82 +7527,6 @@ static int bnx2x_set_power_state(struct bnx2x *b=
p, pci_power_t state)
  * net_device service functions
  */
=20
-/* called with netif_tx_lock from set_multicast */
-static void bnx2x_set_rx_mode(struct net_device *dev)
-{
-	struct bnx2x *bp =3D netdev_priv(dev);
-	u32 rx_mode =3D BNX2X_RX_MODE_NORMAL;
-
-	DP(NETIF_MSG_IFUP, "called dev->flags =3D %x\n", dev->flags);
-
-	if (dev->flags & IFF_PROMISC)
-		rx_mode =3D BNX2X_RX_MODE_PROMISC;
-
-	else if ((dev->flags & IFF_ALLMULTI) ||
-		 (dev->mc_count > BNX2X_MAX_MULTICAST))
-		rx_mode =3D BNX2X_RX_MODE_ALLMULTI;
-
-	else { /* some multicasts */
-		int i, old, offset;
-		struct dev_mc_list *mclist;
-		struct mac_configuration_cmd *config =3D
-						bnx2x_sp(bp, mcast_config);
-
-		for (i =3D 0, mclist =3D dev->mc_list;
-		     mclist && (i < dev->mc_count);
-		     i++, mclist =3D mclist->next) {
-
-			config->config_table[i].cam_entry.msb_mac_addr =3D
-					swab16(*(u16 *)&mclist->dmi_addr[0]);
-			config->config_table[i].cam_entry.middle_mac_addr =3D
-					swab16(*(u16 *)&mclist->dmi_addr[2]);
-			config->config_table[i].cam_entry.lsb_mac_addr =3D
-					swab16(*(u16 *)&mclist->dmi_addr[4]);
-			config->config_table[i].cam_entry.flags =3D
-							cpu_to_le16(bp->port);
-			config->config_table[i].target_table_entry.flags =3D 0;
-			config->config_table[i].target_table_entry.
-								client_id =3D 0;
-			config->config_table[i].target_table_entry.
-								vlan_id =3D 0;
-
-			DP(NETIF_MSG_IFUP,
-			   "setting MCAST[%d] (%04x:%04x:%04x)\n",
-			   i, config->config_table[i].cam_entry.msb_mac_addr,
-			   config->config_table[i].cam_entry.middle_mac_addr,
-			   config->config_table[i].cam_entry.lsb_mac_addr);
-		}
-		old =3D config->hdr.length_6b;
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
-			offset =3D BNX2X_MAX_EMUL_MULTI*(1 + bp->port);
-		else
-			offset =3D BNX2X_MAX_MULTICAST*(1 + bp->port);
-
-		config->hdr.length_6b =3D i;
-		config->hdr.offset =3D offset;
-		config->hdr.reserved0 =3D 0;
-		config->hdr.reserved1 =3D 0;
-
-		bnx2x_sp_post(bp, RAMROD_CMD_ID_ETH_SET_MAC, 0,
-			      U64_HI(bnx2x_sp_mapping(bp, mcast_config)),
-			      U64_LO(bnx2x_sp_mapping(bp, mcast_config)), 0);
-	}
-
-	bp->rx_mode =3D rx_mode;
-	bnx2x_set_storm_rx_mode(bp);
-}
-
 static int bnx2x_poll(struct napi_struct *napi, int budget)
 {
 	struct bnx2x_fastpath *fp =3D container_of(napi, struct bnx2x_fastpat=
h,
@@ -6731,7 +7536,7 @@ static int bnx2x_poll(struct napi_struct *napi, i=
nt budget)
=20
 #ifdef BNX2X_STOP_ON_ERROR
 	if (unlikely(bp->panic))
-		goto out_panic;
+		goto poll_panic;
 #endif
=20
 	prefetch(fp->tx_buf_ring[TX_BD(fp->tx_pkt_cons)].skb);
@@ -6743,27 +7548,24 @@ static int bnx2x_poll(struct napi_struct *napi,=
 int budget)
 	if (le16_to_cpu(*fp->tx_cons_sb) !=3D fp->tx_pkt_cons)
 		bnx2x_tx_int(fp, budget);
=20
-
 	if (le16_to_cpu(*fp->rx_cons_sb) !=3D fp->rx_comp_cons)
 		work_done =3D bnx2x_rx_int(fp, budget);
=20
-
 	rmb(); /* bnx2x_has_work() reads the status block */
=20
 	/* must not complete if we consumed full budget */
 	if ((work_done < budget) && !bnx2x_has_work(fp)) {
=20
 #ifdef BNX2X_STOP_ON_ERROR
-out_panic:
+poll_panic:
 #endif
 		netif_rx_complete(bp->dev, napi);
=20
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
=20
@@ -7057,18 +7859,146 @@ static int bnx2x_close(struct net_device *dev)
 	return 0;
 }
=20
-/* Called with rtnl_lock */
+/* called with netif_tx_lock from set_multicast */
+static void bnx2x_set_rx_mode(struct net_device *dev)
+{
+	struct bnx2x *bp =3D netdev_priv(dev);
+	u32 rx_mode =3D BNX2X_RX_MODE_NORMAL;
+	int port =3D BP_PORT(bp);
+
+	if (bp->state !=3D BNX2X_STATE_OPEN) {
+		DP(NETIF_MSG_IFUP, "state is %x, returning\n", bp->state);
+		return;
+	}
+
+	DP(NETIF_MSG_IFUP, "dev->flags =3D %x\n", dev->flags);
+
+	if (dev->flags & IFF_PROMISC)
+		rx_mode =3D BNX2X_RX_MODE_PROMISC;
+
+	else if ((dev->flags & IFF_ALLMULTI) ||
+		 ((dev->mc_count > BNX2X_MAX_MULTICAST) && CHIP_IS_E1(bp)))
+		rx_mode =3D BNX2X_RX_MODE_ALLMULTI;
+
+	else { /* some multicasts */
+		if (CHIP_IS_E1(bp)) {
+			int i, old, offset;
+			struct dev_mc_list *mclist;
+			struct mac_configuration_cmd *config =3D
+						bnx2x_sp(bp, mcast_config);
+
+			for (i =3D 0, mclist =3D dev->mc_list;
+			     mclist && (i < dev->mc_count);
+			     i++, mclist =3D mclist->next) {
+
+				config->config_table[i].
+					cam_entry.msb_mac_addr =3D
+					swab16(*(u16 *)&mclist->dmi_addr[0]);
+				config->config_table[i].
+					cam_entry.middle_mac_addr =3D
+					swab16(*(u16 *)&mclist->dmi_addr[2]);
+				config->config_table[i].
+					cam_entry.lsb_mac_addr =3D
+					swab16(*(u16 *)&mclist->dmi_addr[4]);
+				config->config_table[i].cam_entry.flags =3D
+							cpu_to_le16(port);
+				config->config_table[i].
+					target_table_entry.flags =3D 0;
+				config->config_table[i].
+					target_table_entry.client_id =3D 0;
+				config->config_table[i].
+					target_table_entry.vlan_id =3D 0;
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
+			old =3D config->hdr.length_6b;
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
+				offset =3D BNX2X_MAX_EMUL_MULTI*(1 + port);
+			else
+				offset =3D BNX2X_MAX_MULTICAST*(1 + port);
+
+			config->hdr.length_6b =3D i;
+			config->hdr.offset =3D offset;
+			config->hdr.client_id =3D BP_CL_ID(bp);
+			config->hdr.reserved1 =3D 0;
+
+			bnx2x_sp_post(bp, RAMROD_CMD_ID_ETH_SET_MAC, 0,
+				   U64_HI(bnx2x_sp_mapping(bp, mcast_config)),
+				   U64_LO(bnx2x_sp_mapping(bp, mcast_config)),
+				      0);
+		} else { /* E1H */
+			/* Accept one or more multicast(s). */
+			struct dev_mc_list *mclist;
+			u32 mc_filter[MC_HASH_SIZE];
+			u32 crc, bit, regidx;
+			int i;
+
+			memset(mc_filter, 0, 4 * MC_HASH_SIZE);
+
+			for (i =3D 0, mclist =3D dev->mc_list;
+			     mclist && (i < dev->mc_count);
+			     i++, mclist =3D mclist->next) {
+
+				DP(NETIF_MSG_IFUP, "Adding mcast MAC: "
+				   "%02x:%02x:%02x:%02x:%02x:%02x\n",
+				   mclist->dmi_addr[0], mclist->dmi_addr[1],
+				   mclist->dmi_addr[2], mclist->dmi_addr[3],
+				   mclist->dmi_addr[4], mclist->dmi_addr[5]);
+
+				crc =3D crc32c_le(0, mclist->dmi_addr, ETH_ALEN);
+				bit =3D (crc >> 24) & 0xff;
+				regidx =3D bit >> 5;
+				bit &=3D 0x1f;
+				mc_filter[regidx] |=3D (1 << bit);
+			}
+
+			for (i =3D 0; i < MC_HASH_SIZE; i++) {
+				REG_WR(bp, MC_HASH_OFFSET(bp, i),
+				       mc_filter[i]);
+			}
+		}
+	}
+
+	bp->rx_mode =3D rx_mode;
+	bnx2x_set_storm_rx_mode(bp);
+}
+
+/* called with rtnl_lock */
 static int bnx2x_change_mac_addr(struct net_device *dev, void *p)
 {
 	struct sockaddr *addr =3D p;
 	struct bnx2x *bp =3D netdev_priv(dev);
=20
-	if (!is_valid_ether_addr(addr->sa_data))
+	if (!is_valid_ether_addr((u8 *)(addr->sa_data)))
 		return -EINVAL;
=20
 	memcpy(dev->dev_addr, addr->sa_data, dev->addr_len);
-	if (netif_running(dev))
-		bnx2x_set_mac_addr(bp);
+	if (netif_running(dev)) {
+		if (CHIP_IS_E1(bp))
+			bnx2x_set_mac_addr_e1(bp);
+		else
+			bnx2x_set_mac_addr_e1h(bp);
+	}
=20
 	return 0;
 }
@@ -7082,7 +8012,7 @@ static int bnx2x_ioctl(struct net_device *dev, st=
ruct ifreq *ifr, int cmd)
=20
 	switch (cmd) {
 	case SIOCGMIIPHY:
-		data->phy_id =3D bp->phy_addr;
+		data->phy_id =3D bp->port.phy_addr;
=20
 		/* fallthrough */
=20
@@ -7092,12 +8022,12 @@ static int bnx2x_ioctl(struct net_device *dev, =
struct ifreq *ifr, int cmd)
 		if (!netif_running(dev))
 			return -EAGAIN;
=20
-		mutex_lock(&bp->phy_mutex);
-		err =3D bnx2x_cl45_read(bp, bp->port, 0, bp->phy_addr,
+		mutex_lock(&bp->port.phy_mutex);
+		err =3D bnx2x_cl45_read(bp, BP_PORT(bp), 0, bp->port.phy_addr,
 				      DEFAULT_PHY_DEV_ADDR,
 				      (data->reg_num & 0x1f), &mii_regval);
 		data->val_out =3D mii_regval;
-		mutex_unlock(&bp->phy_mutex);
+		mutex_unlock(&bp->port.phy_mutex);
 		return err;
 	}
=20
@@ -7108,11 +8038,11 @@ static int bnx2x_ioctl(struct net_device *dev, =
struct ifreq *ifr, int cmd)
 		if (!netif_running(dev))
 			return -EAGAIN;
=20
-		mutex_lock(&bp->phy_mutex);
-		err =3D bnx2x_cl45_write(bp, bp->port, 0, bp->phy_addr,
+		mutex_lock(&bp->port.phy_mutex);
+		err =3D bnx2x_cl45_write(bp, BP_PORT(bp), 0, bp->port.phy_addr,
 				       DEFAULT_PHY_DEV_ADDR,
 				       (data->reg_num & 0x1f), data->val_in);
-		mutex_unlock(&bp->phy_mutex);
+		mutex_unlock(&bp->port.phy_mutex);
 		return err;
=20
 	default:
@@ -7123,7 +8053,7 @@ static int bnx2x_ioctl(struct net_device *dev, st=
ruct ifreq *ifr, int cmd)
 	return -EOPNOTSUPP;
 }
=20
-/* Called with rtnl_lock */
+/* called with rtnl_lock */
 static int bnx2x_change_mtu(struct net_device *dev, int new_mtu)
 {
 	struct bnx2x *bp =3D netdev_priv(dev);
@@ -7139,8 +8069,8 @@ static int bnx2x_change_mtu(struct net_device *de=
v, int new_mtu)
 	dev->mtu =3D new_mtu;
=20
 	if (netif_running(dev)) {
-		bnx2x_nic_unload(bp, 0);
-		bnx2x_nic_load(bp, 0);
+		bnx2x_nic_unload(bp, UNLOAD_NORMAL);
+		bnx2x_nic_load(bp, LOAD_NORMAL);
 	}
 	return 0;
 }
@@ -7158,7 +8088,7 @@ static void bnx2x_tx_timeout(struct net_device *d=
ev)
 }
=20
 #ifdef BCM_VLAN
-/* Called with rtnl_lock */
+/* called with rtnl_lock */
 static void bnx2x_vlan_rx_register(struct net_device *dev,
 				   struct vlan_group *vlgrp)
 {
@@ -7168,6 +8098,7 @@ static void bnx2x_vlan_rx_register(struct net_dev=
ice *dev,
 	if (netif_running(dev))
 		bnx2x_set_client_config(bp);
 }
+
 #endif
=20
 #if defined(HAVE_POLL_CONTROLLER) || defined(CONFIG_NET_POLL_CONTROLLE=
R)
@@ -7181,36 +8112,8 @@ static void poll_bnx2x(struct net_device *dev)
 }
 #endif
=20
-static void bnx2x_reset_task(struct work_struct *work)
-{
-	struct bnx2x *bp =3D container_of(work, struct bnx2x, reset_task);
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
-	if (bp->state !=3D BNX2X_STATE_OPEN) {
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
@@ -7218,8 +8121,10 @@ static int __devinit bnx2x_init_board(struct pci=
_dev *pdev,
 	SET_NETDEV_DEV(dev, &pdev->dev);
 	bp =3D netdev_priv(dev);
=20
+	bp->dev =3D dev;
+	bp->pdev =3D pdev;
 	bp->flags =3D 0;
-	bp->port =3D PCI_FUNC(pdev->devfn);
+	bp->func =3D PCI_FUNC(pdev->devfn);
=20
 	rc =3D pci_enable_device(pdev);
 	if (rc) {
@@ -7241,14 +8146,16 @@ static int __devinit bnx2x_init_board(struct pc=
i_dev *pdev,
 		goto err_out_disable;
 	}
=20
-	rc =3D pci_request_regions(pdev, DRV_MODULE_NAME);
-	if (rc) {
-		printk(KERN_ERR PFX "Cannot obtain PCI resources,"
-		       " aborting\n");
-		goto err_out_disable;
-	}
+	if (atomic_read(&pdev->enable_cnt) =3D=3D 1) {
+		rc =3D pci_request_regions(pdev, DRV_MODULE_NAME);
+		if (rc) {
+			printk(KERN_ERR PFX "Cannot obtain PCI resources,"
+			       " aborting\n");
+			goto err_out_disable;
+		}
=20
-	pci_set_master(pdev);
+		pci_set_master(pdev);
+	}
=20
 	bp->pm_cap =3D pci_find_capability(pdev, PCI_CAP_ID_PM);
 	if (bp->pm_cap =3D=3D 0) {
@@ -7282,13 +8189,9 @@ static int __devinit bnx2x_init_board(struct pci=
_dev *pdev,
 		goto err_out_release;
 	}
=20
-	bp->dev =3D dev;
-	bp->pdev =3D pdev;
-
-	INIT_WORK(&bp->reset_task, bnx2x_reset_task);
-	INIT_WORK(&bp->sp_task, bnx2x_sp_task);
-
-	dev->base_addr =3D pci_resource_start(pdev, 0);
+	dev->mem_start =3D pci_resource_start(pdev, 0);
+	dev->base_addr =3D dev->mem_start;
+	dev->mem_end =3D pci_resource_end(pdev, 0);
=20
 	dev->irq =3D pdev->irq;
=20
@@ -7301,7 +8204,8 @@ static int __devinit bnx2x_init_board(struct pci_=
dev *pdev,
 	}
=20
 	bp->doorbells =3D ioremap_nocache(pci_resource_start(pdev , 2),
-					pci_resource_len(pdev, 2));
+					min_t(u64, (u64)BNX2X_DB_SIZE,
+					      (u64)pci_resource_len(pdev, 2)));
 	if (!bp->doorbells) {
 		printk(KERN_ERR PFX "Cannot map doorbell space, aborting\n");
 		rc =3D -ENOMEM;
@@ -7310,47 +8214,35 @@ static int __devinit bnx2x_init_board(struct pc=
i_dev *pdev,
=20
 	bnx2x_set_power_state(bp, PCI_D0);
=20
-	bnx2x_get_hwinfo(bp);
-
-
-	if (nomcp) {
-		printk(KERN_ERR PFX "MCP disabled, will only"
-		       " init first device\n");
-		onefunc =3D 1;
-	}
-
-	if (onefunc && bp->port) {
-		printk(KERN_ERR PFX "Second device disabled, exiting\n");
-		rc =3D -ENODEV;
-		goto err_out_unmap;
-	}
-
-	bp->tx_ring_size =3D MAX_TX_AVAIL;
-	bp->rx_ring_size =3D MAX_RX_AVAIL;
-
-	bp->rx_csum =3D 1;
-
-	bp->rx_offset =3D 0;
-
-	bp->tx_quick_cons_trip_int =3D 0xff;
-	bp->tx_quick_cons_trip =3D 0xff;
-	bp->tx_ticks_int =3D 50;
-	bp->tx_ticks =3D 50;
-
-	bp->rx_quick_cons_trip_int =3D 0xff;
-	bp->rx_quick_cons_trip =3D 0xff;
-	bp->rx_ticks_int =3D 25;
-	bp->rx_ticks =3D 25;
+	dev->hard_start_xmit =3D bnx2x_start_xmit;
+	dev->watchdog_timeo =3D TX_TIMEOUT;
=20
-	bp->stats_ticks =3D 1000000 & 0xffff00;
+	dev->ethtool_ops =3D &bnx2x_ethtool_ops;
+	dev->open =3D bnx2x_open;
+	dev->stop =3D bnx2x_close;
+	dev->set_multicast_list =3D bnx2x_set_rx_mode;
+	dev->set_mac_address =3D bnx2x_change_mac_addr;
+	dev->do_ioctl =3D bnx2x_ioctl;
+	dev->change_mtu =3D bnx2x_change_mtu;
+	dev->tx_timeout =3D bnx2x_tx_timeout;
+#ifdef BCM_VLAN
+	dev->vlan_rx_register =3D bnx2x_vlan_rx_register;
+#endif
+#if defined(HAVE_POLL_CONTROLLER) || defined(CONFIG_NET_POLL_CONTROLLE=
R)
+	dev->poll_controller =3D poll_bnx2x;
+#endif
+	dev->features |=3D NETIF_F_SG;
+	if (bp->flags & USING_DAC_FLAG)
+		dev->features |=3D NETIF_F_HIGHDMA;
+	dev->features |=3D NETIF_F_HW_CSUM;
+#ifdef BCM_VLAN
+	dev->features |=3D (NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX);
+#endif
+	dev->features |=3D (NETIF_F_TSO | NETIF_F_TSO_ECN);
=20
 	bp->timer_interval =3D HZ;
 	bp->current_interval =3D (poll ? poll : HZ);
=20
-	init_timer(&bp->timer);
-	bp->timer.expires =3D jiffies + bp->current_interval;
-	bp->timer.data =3D (unsigned long) bp;
-	bp->timer.function =3D bnx2x_timer;
=20
 	return 0;
=20
@@ -7359,14 +8251,14 @@ err_out_unmap:
 		iounmap(bp->regview);
 		bp->regview =3D NULL;
 	}
-
 	if (bp->doorbells) {
 		iounmap(bp->doorbells);
 		bp->doorbells =3D NULL;
 	}
=20
 err_out_release:
-	pci_release_regions(pdev);
+	if (atomic_read(&pdev->enable_cnt) =3D=3D 1)
+		pci_release_regions(pdev);
=20
 err_out_disable:
 	pci_disable_device(pdev);
@@ -7400,7 +8292,6 @@ static int __devinit bnx2x_init_one(struct pci_de=
v *pdev,
 	struct net_device *dev =3D NULL;
 	struct bnx2x *bp;
 	int rc;
-	int port =3D PCI_FUNC(pdev->devfn);
 	DECLARE_MAC_BUF(mac);
=20
 	if (version_printed++ =3D=3D 0)
@@ -7408,78 +8299,61 @@ static int __devinit bnx2x_init_one(struct pci_=
dev *pdev,
=20
 	/* dev zeroed in init_etherdev */
 	dev =3D alloc_etherdev(sizeof(*bp));
-	if (!dev)
+	if (!dev) {
+		printk(KERN_ERR PFX "Cannot allocate net device\n");
 		return -ENOMEM;
+	}
=20
 	netif_carrier_off(dev);
=20
 	bp =3D netdev_priv(dev);
 	bp->msglevel =3D debug;
=20
-	if (port && onefunc) {
-		printk(KERN_ERR PFX "second function disabled. exiting\n");
-		free_netdev(dev);
-		return 0;
-	}
-
-	rc =3D bnx2x_init_board(pdev, dev);
+	rc =3D bnx2x_init_dev(pdev, dev);
 	if (rc < 0) {
 		free_netdev(dev);
 		return rc;
 	}
=20
-	dev->hard_start_xmit =3D bnx2x_start_xmit;
-	dev->watchdog_timeo =3D TX_TIMEOUT;
-
-	dev->ethtool_ops =3D &bnx2x_ethtool_ops;
-	dev->open =3D bnx2x_open;
-	dev->stop =3D bnx2x_close;
-	dev->set_multicast_list =3D bnx2x_set_rx_mode;
-	dev->set_mac_address =3D bnx2x_change_mac_addr;
-	dev->do_ioctl =3D bnx2x_ioctl;
-	dev->change_mtu =3D bnx2x_change_mtu;
-	dev->tx_timeout =3D bnx2x_tx_timeout;
-#ifdef BCM_VLAN
-	dev->vlan_rx_register =3D bnx2x_vlan_rx_register;
-#endif
-#if defined(HAVE_POLL_CONTROLLER) || defined(CONFIG_NET_POLL_CONTROLLE=
R)
-	dev->poll_controller =3D poll_bnx2x;
-#endif
-	dev->features |=3D NETIF_F_SG;
-	if (bp->flags & USING_DAC_FLAG)
-		dev->features |=3D NETIF_F_HIGHDMA;
-	dev->features |=3D NETIF_F_IP_CSUM;
-#ifdef BCM_VLAN
-	dev->features |=3D NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
-#endif
-	dev->features |=3D NETIF_F_TSO | NETIF_F_TSO_ECN;
-
 	rc =3D register_netdev(dev);
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
=20
 	pci_set_drvdata(pdev, dev);
=20
-	bp->name =3D board_info[ent->driver_data].name;
+	rc =3D bnx2x_init_bp(bp);
+	if (rc) {
+		unregister_netdev(dev);
+		goto init_one_exit;
+	}
+
+	bp->common.name =3D board_info[ent->driver_data].name;
 	printk(KERN_INFO "%s: %s (%c%d) PCI-E x%d %s found at mem %lx,"
-	       " IRQ %d, ", dev->name, bp->name,
-	       ((CHIP_ID(bp) & 0xf000) >> 12) + 'A',
-	       ((CHIP_ID(bp) & 0x0ff0) >> 4),
+	       " IRQ %d, ", dev->name, bp->common.name,
+	       (CHIP_REV(bp) >> 12) + 'A', (CHIP_METAL(bp) >> 4),
 	       bnx2x_get_pcie_width(bp),
 	       (bnx2x_get_pcie_speed(bp) =3D=3D 2) ? "5GHz (Gen2)" : "2.5GHz"=
,
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
+	if (atomic_read(&pdev->enable_cnt) =3D=3D 1)
+		pci_release_regions(pdev);
+
+	pci_disable_device(pdev);
+	pci_set_drvdata(pdev, NULL);
+	return rc;
 }
=20
 static void __devexit bnx2x_remove_one(struct pci_dev *pdev)
@@ -7488,11 +8362,9 @@ static void __devexit bnx2x_remove_one(struct pc=
i_dev *pdev)
 	struct bnx2x *bp;
=20
 	if (!dev) {
-		/* we get here if init_one() fails */
 		printk(KERN_ERR PFX "BAD net device from bnx2x_init_one\n");
 		return;
 	}
-
 	bp =3D netdev_priv(dev);
=20
 	unregister_netdev(dev);
@@ -7504,7 +8376,10 @@ static void __devexit bnx2x_remove_one(struct pc=
i_dev *pdev)
 		iounmap(bp->doorbells);
=20
 	free_netdev(dev);
-	pci_release_regions(pdev);
+
+	if (atomic_read(&pdev->enable_cnt) =3D=3D 1)
+		pci_release_regions(pdev);
+
 	pci_disable_device(pdev);
 	pci_set_drvdata(pdev, NULL);
 }
@@ -7514,15 +8389,17 @@ static int bnx2x_suspend(struct pci_dev *pdev, =
pm_message_t state)
 	struct net_device *dev =3D pci_get_drvdata(pdev);
 	struct bnx2x *bp;
=20
-	if (!dev)
-		return 0;
+	if (!dev) {
+		printk(KERN_ERR PFX "BAD net device from bnx2x_init_one\n");
+		return -ENODEV;
+	}
=20
 	if (!netif_running(dev))
 		return 0;
=20
 	bp =3D netdev_priv(dev);
=20
-	bnx2x_nic_unload(bp, 0);
+	bnx2x_nic_unload(bp, UNLOAD_NORMAL);
=20
 	netif_device_detach(dev);
=20
@@ -7552,7 +8429,7 @@ static int bnx2x_resume(struct pci_dev *pdev)
 	bnx2x_set_power_state(bp, PCI_D0);
 	netif_device_attach(dev);
=20
-	rc =3D bnx2x_nic_load(bp, 0);
+	rc =3D bnx2x_nic_load(bp, LOAD_NORMAL);
 	if (rc)
 		return rc;
=20
diff --git a/drivers/net/bnx2x_reg.h b/drivers/net/bnx2x_reg.h
index 82cf0ec..311158f 100644
--- a/drivers/net/bnx2x_reg.h
+++ b/drivers/net/bnx2x_reg.h
@@ -38,15 +38,11 @@
    was asserted. */
 #define BRB1_REG_NUM_OF_FULL_CYCLES_0				 0x600c8
 #define BRB1_REG_NUM_OF_FULL_CYCLES_1				 0x600cc
-#define BRB1_REG_NUM_OF_FULL_CYCLES_2				 0x600d0
-#define BRB1_REG_NUM_OF_FULL_CYCLES_3				 0x600d4
 #define BRB1_REG_NUM_OF_FULL_CYCLES_4				 0x600d8
 /* [ST 32] The number of cycles that the pause signal towards MAC #0 w=
as
    asserted. */
 #define BRB1_REG_NUM_OF_PAUSE_CYCLES_0				 0x600b8
 #define BRB1_REG_NUM_OF_PAUSE_CYCLES_1				 0x600bc
-#define BRB1_REG_NUM_OF_PAUSE_CYCLES_2				 0x600c0
-#define BRB1_REG_NUM_OF_PAUSE_CYCLES_3				 0x600c4
 /* [RW 10] Write client 0: De-assert pause threshold. */
 #define BRB1_REG_PAUSE_HIGH_THRESHOLD_0 			 0x60078
 #define BRB1_REG_PAUSE_HIGH_THRESHOLD_1 			 0x6007c
@@ -587,10 +583,6 @@
 #define DBG_REG_DBG_PRTY_MASK					 0xc0a8
 /* [R 1] Parity register #0 read */
 #define DBG_REG_DBG_PRTY_STS					 0xc09c
-/* [RW 2] debug only: These bits indicate the credit for PCI request t=
ype 4
-   interface; MUST be configured AFTER pci_ext_buffer_strt_addr_lsb/ms=
b are
-   configured */
-#define DBG_REG_PCI_REQ_CREDIT					 0xc120
 /* [RW 32] Commands memory. The address to command X; row Y is to calc=
ulated
    as 14*X+Y. */
 #define DMAE_REG_CMD_MEM					 0x102400
@@ -1626,7 +1618,7 @@
    is reset to 0x080; giving a default blink period of approximately 8=
Hz. */
 #define NIG_REG_LED_CONTROL_BLINK_RATE_P0			 0x10310
 /* [RW 1] Port0: If set along with the
-   nig_registers_led_control_override_traffic_p0.led_control_override_=
traffic_p0
+ ~nig_registers_led_control_override_traffic_p0.led_control_override_t=
raffic_p0
    bit and ~nig_registers_led_control_traffic_p0.led_control_traffic_p=
0 LED
    bit; the Traffic LED will blink with the blink rate specified in
    ~nig_registers_led_control_blink_rate_p0.led_control_blink_rate_p0 =
and
@@ -1849,7 +1841,6 @@
 #define PRS_REG_CFC_SEARCH_INITIAL_CREDIT			 0x4011c
 /* [RW 24] CID for port 0 if no match */
 #define PRS_REG_CID_PORT_0					 0x400fc
-#define PRS_REG_CID_PORT_1					 0x40100
 /* [RW 32] The CM header for flush message where 'load existed' bit in=
 CFC
    load response is reset and packet type is 0. Used in packet start m=
essage
    to TCM. */
@@ -2060,12 +2051,13 @@
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
@@ -4930,10 +4922,7 @@
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
index cf6dbd7..14599f6 100644
--- a/include/linux/pci_ids.h
+++ b/include/linux/pci_ids.h
@@ -1947,6 +1947,8 @@
 #define PCI_DEVICE_ID_NX2_5708		0x164c
 #define PCI_DEVICE_ID_TIGON3_5702FE	0x164d
 #define PCI_DEVICE_ID_NX2_57710		0x164e
+#define PCI_DEVICE_ID_NX2_57711		0x164f
+#define PCI_DEVICE_ID_NX2_57711E	0x1650
 #define PCI_DEVICE_ID_TIGON3_5705	0x1653
 #define PCI_DEVICE_ID_TIGON3_5705_2	0x1654
 #define PCI_DEVICE_ID_TIGON3_5720	0x1658
--=20
1.5.5




