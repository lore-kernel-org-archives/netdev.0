From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH net-next 10/19] bnx2x: Add 57712 support
Date: Wed, 6 Oct 2010 15:28:26 +0200
Message-ID: <1286371706.30552.43.camel@lb-tlvb-dmitry>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, mchan@broadcom.com
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4218 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757398Ab0JFNkI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Oct 2010 09:40:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


57712 HW supported with same set of features as for 57710/57711

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x.h          |  124 +++-
 drivers/net/bnx2x/bnx2x_cmn.c      |  275 ++++--
 drivers/net/bnx2x/bnx2x_cmn.h      |  137 +++-
 drivers/net/bnx2x/bnx2x_dump.h     |   35 +-
 drivers/net/bnx2x/bnx2x_ethtool.c  |  123 ++-
 drivers/net/bnx2x/bnx2x_hsi.h      |  187 ++++-
 drivers/net/bnx2x/bnx2x_init.h     |    3 +
 drivers/net/bnx2x/bnx2x_init_ops.h |   28 +-
 drivers/net/bnx2x/bnx2x_link.c     |  379 ++++++--
 drivers/net/bnx2x/bnx2x_link.h     |    6 +-
 drivers/net/bnx2x/bnx2x_main.c     | 1777 +++++++++++++++++++++++++++---------
 drivers/net/bnx2x/bnx2x_reg.h      |  879 ++++++++++++++++++-
 drivers/net/bnx2x/bnx2x_stats.c    |  262 +++---
 firmware/Makefile                  |    3 +-
 14 files changed, 3428 insertions(+), 790 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x.h b/drivers/net/bnx2x/bnx2x.h
index 09fb7ff..6f8e266 100644
--- a/drivers/net/bnx2x/bnx2x.h
+++ b/drivers/net/bnx2x/bnx2x.h
@@ -180,10 +180,16 @@ void bnx2x_panic_dump(struct bnx2x *bp);
 #define SHMEM2_WR(bp, field, val)	REG_WR(bp, SHMEM2_ADDR(bp, field), val)
 #define MF_CFG_ADDR(bp, field)		(bp->common.mf_cfg_base + \
 					 offsetof(struct mf_cfg, field))
+#define MF2_CFG_ADDR(bp, field)	(bp->common.mf2_cfg_base + \
+					 offsetof(struct mf2_cfg, field))
 
 #define MF_CFG_RD(bp, field)		REG_RD(bp, MF_CFG_ADDR(bp, field))
 #define MF_CFG_WR(bp, field, val)	REG_WR(bp,\
 					       MF_CFG_ADDR(bp, field), (val))
+#define MF2_CFG_RD(bp, field)		REG_RD(bp, MF2_CFG_ADDR(bp, field))
+#define SHMEM2_HAS(bp, field)		((bp)->common.shmem2_base &&	\
+					 (SHMEM2_RD((bp), size) >	\
+					 offsetof(struct shmem2_region, field)))
 
 #define EMAC_RD(bp, reg)		REG_RD(bp, emac_base + reg)
 #define EMAC_WR(bp, reg, val)		REG_WR(bp, emac_base + reg, val)
@@ -296,6 +302,8 @@ union db_prod {
 union host_hc_status_block {
 	/* pointer to fp status block e1x */
 	struct host_hc_status_block_e1x *e1x_sb;
+	/* pointer to fp status block e2 */
+	struct host_hc_status_block_e2  *e2_sb;
 };
 
 struct bnx2x_fastpath {
@@ -564,12 +572,19 @@ struct bnx2x_common {
 #define CHIP_NUM_57710			0x164e
 #define CHIP_NUM_57711			0x164f
 #define CHIP_NUM_57711E			0x1650
+#define CHIP_NUM_57712			0x1662
+#define CHIP_NUM_57712E			0x1663
 #define CHIP_IS_E1(bp)			(CHIP_NUM(bp) == CHIP_NUM_57710)
 #define CHIP_IS_57711(bp)		(CHIP_NUM(bp) == CHIP_NUM_57711)
 #define CHIP_IS_57711E(bp)		(CHIP_NUM(bp) == CHIP_NUM_57711E)
+#define CHIP_IS_57712(bp)		(CHIP_NUM(bp) == CHIP_NUM_57712)
+#define CHIP_IS_57712E(bp)		(CHIP_NUM(bp) == CHIP_NUM_57712E)
 #define CHIP_IS_E1H(bp)			(CHIP_IS_57711(bp) || \
 					 CHIP_IS_57711E(bp))
-#define IS_E1H_OFFSET			CHIP_IS_E1H(bp)
+#define CHIP_IS_E2(bp)			(CHIP_IS_57712(bp) || \
+					 CHIP_IS_57712E(bp))
+#define CHIP_IS_E1x(bp)			(CHIP_IS_E1((bp)) || CHIP_IS_E1H((bp)))
+#define IS_E1H_OFFSET			(CHIP_IS_E1H(bp) || CHIP_IS_E2(bp))
 
 #define CHIP_REV(bp)			(bp->common.chip_id & 0x0000f000)
 #define CHIP_REV_Ax			0x00000000
@@ -596,6 +611,7 @@ struct bnx2x_common {
 	u32			shmem_base;
 	u32			shmem2_base;
 	u32			mf_cfg_base;
+	u32			mf2_cfg_base;
 
 	u32			hw_config;
 
@@ -603,10 +619,25 @@ struct bnx2x_common {
 
 	u8			int_block;
 #define INT_BLOCK_HC			0
+#define INT_BLOCK_IGU			1
+#define INT_BLOCK_MODE_NORMAL		0
+#define INT_BLOCK_MODE_BW_COMP		2
+#define CHIP_INT_MODE_IS_NBC(bp)		\
+			(CHIP_IS_E2(bp) &&	\
+			!((bp)->common.int_block & INT_BLOCK_MODE_BW_COMP))
+#define CHIP_INT_MODE_IS_BC(bp) (!CHIP_INT_MODE_IS_NBC(bp))
+
 	u8			chip_port_mode;
+#define CHIP_4_PORT_MODE			0x0
+#define CHIP_2_PORT_MODE			0x1
 #define CHIP_PORT_MODE_NONE			0x2
+#define CHIP_MODE(bp)			(bp->common.chip_port_mode)
+#define CHIP_MODE_IS_4_PORT(bp) (CHIP_MODE(bp) == CHIP_4_PORT_MODE)
 };
 
+/* IGU MSIX STATISTICS on 57712: 64 for VFs; 4 for PFs; 4 for Attentions */
+#define BNX2X_IGU_STAS_MSG_VF_CNT 64
+#define BNX2X_IGU_STAS_MSG_PF_CNT 4
 
 /* end of common */
 
@@ -670,7 +701,7 @@ enum {
  */
 
 #define FP_SB_MAX_E1x		16	/* fast-path interrupt contexts E1x */
-#define MAX_CONTEXT		FP_SB_MAX_E1x
+#define FP_SB_MAX_E2		16	/* fast-path interrupt contexts E2 */
 
 /*
  * cid_cnt paramter below refers to the value returned by
@@ -754,7 +785,7 @@ struct bnx2x_slowpath {
 #define MAX_DYNAMIC_ATTN_GRPS		8
 
 struct attn_route {
-	u32	sig[4];
+	u32	sig[5];
 };
 
 struct iro {
@@ -896,13 +927,20 @@ struct bnx2x {
 #define HW_VLAN_RX_FLAG			0x800
 #define MF_FUNC_DIS			0x1000
 
-	int			func;
+	int			pf_num;	/* absolute PF number */
+	int			pfid;	/* per-path PF number */
 	int			base_fw_ndsb;
-
-#define BP_PORT(bp)			(bp->func % PORT_MAX)
-#define BP_FUNC(bp)			(bp->func)
-#define BP_E1HVN(bp)			(bp->func >> 1)
+#define BP_PATH(bp)			(!CHIP_IS_E2(bp) ? \
+						0 : (bp->pf_num & 1))
+#define BP_PORT(bp)			(bp->pfid & 1)
+#define BP_FUNC(bp)			(bp->pfid)
+#define BP_ABS_FUNC(bp)			(bp->pf_num)
+#define BP_E1HVN(bp)			(bp->pfid >> 1)
+#define BP_VN(bp)			(CHIP_MODE_IS_4_PORT(bp) ? \
+						0 : BP_E1HVN(bp))
 #define BP_L_ID(bp)			(BP_E1HVN(bp) << 2)
+#define BP_FW_MB_IDX(bp)		(BP_PORT(bp) +\
+					 BP_VN(bp) * (CHIP_IS_E1x(bp) ? 2  : 1))
 
 #ifdef BCM_CNIC
 #define BCM_CNIC_CID_START		16
@@ -932,7 +970,8 @@ struct bnx2x {
 	struct cmng_struct_per_port cmng;
 	u32			vn_weight_sum;
 
-	u32			mf_config;
+	u32			mf_config[E1HVN_MAX];
+	u32			mf2_config[E2_FUNC_MAX];
 	u16			mf_ov;
 	u8			mf_mode;
 #define IS_MF(bp)			(bp->mf_mode != 0)
@@ -1127,11 +1166,11 @@ struct bnx2x {
 #define RSS_IPV6_CAP		0x0004
 #define RSS_IPV6_TCP_CAP	0x0008
 
-#define BNX2X_MAX_QUEUES(bp)	(IS_MF(bp) ? (MAX_CONTEXT/E1HVN_MAX) \
-					      : MAX_CONTEXT)
 #define BNX2X_NUM_QUEUES(bp)	(bp->num_queues)
 #define is_multi(bp)		(BNX2X_NUM_QUEUES(bp) > 1)
 
+#define BNX2X_MAX_QUEUES(bp)	(bp->igu_sb_cnt - CNIC_CONTEXT_USE)
+#define is_eth_multi(bp)	(BNX2X_NUM_ETH_QUEUES(bp) > 1)
 
 #define RSS_IPV4_CAP_MASK						\
 	TSTORM_ETH_FUNCTION_COMMON_CONFIG_RSS_IPV4_CAPABILITY
@@ -1342,14 +1381,40 @@ static inline u32 reg_poll(struct bnx2x *bp, u32 reg, u32 expected, int ms,
 
 
 /* DMAE command defines */
-#define DMAE_CMD_SRC_PCI		0
-#define DMAE_CMD_SRC_GRC		DMAE_COMMAND_SRC
+#define DMAE_TIMEOUT			-1
+#define DMAE_PCI_ERROR			-2	/* E2 and onward */
+#define DMAE_NOT_RDY			-3
+#define DMAE_PCI_ERR_FLAG		0x80000000
+
+#define DMAE_SRC_PCI			0
+#define DMAE_SRC_GRC			1
+
+#define DMAE_DST_NONE			0
+#define DMAE_DST_PCI			1
+#define DMAE_DST_GRC			2
+
+#define DMAE_COMP_PCI			0
+#define DMAE_COMP_GRC			1
+
+/* E2 and onward - PCI error handling in the completion */
+
+#define DMAE_COMP_REGULAR		0
+#define DMAE_COM_SET_ERR		1
 
-#define DMAE_CMD_DST_PCI		(1 << DMAE_COMMAND_DST_SHIFT)
-#define DMAE_CMD_DST_GRC		(2 << DMAE_COMMAND_DST_SHIFT)
+#define DMAE_CMD_SRC_PCI		(DMAE_SRC_PCI << \
+						DMAE_COMMAND_SRC_SHIFT)
+#define DMAE_CMD_SRC_GRC		(DMAE_SRC_GRC << \
+						DMAE_COMMAND_SRC_SHIFT)
 
-#define DMAE_CMD_C_DST_PCI		0
-#define DMAE_CMD_C_DST_GRC		(1 << DMAE_COMMAND_C_DST_SHIFT)
+#define DMAE_CMD_DST_PCI		(DMAE_DST_PCI << \
+						DMAE_COMMAND_DST_SHIFT)
+#define DMAE_CMD_DST_GRC		(DMAE_DST_GRC << \
+						DMAE_COMMAND_DST_SHIFT)
+
+#define DMAE_CMD_C_DST_PCI		(DMAE_COMP_PCI << \
+						DMAE_COMMAND_C_DST_SHIFT)
+#define DMAE_CMD_C_DST_GRC		(DMAE_COMP_GRC << \
+						DMAE_COMMAND_C_DST_SHIFT)
 
 #define DMAE_CMD_C_ENABLE		DMAE_COMMAND_C_TYPE_ENABLE
 
@@ -1365,10 +1430,20 @@ static inline u32 reg_poll(struct bnx2x *bp, u32 reg, u32 expected, int ms,
 #define DMAE_CMD_DST_RESET		DMAE_COMMAND_DST_RESET
 #define DMAE_CMD_E1HVN_SHIFT		DMAE_COMMAND_E1HVN_SHIFT
 
+#define DMAE_SRC_PF			0
+#define DMAE_SRC_VF			1
+
+#define DMAE_DST_PF			0
+#define DMAE_DST_VF			1
+
+#define DMAE_C_SRC			0
+#define DMAE_C_DST			1
+
 #define DMAE_LEN32_RD_MAX		0x80
 #define DMAE_LEN32_WR_MAX(bp)		(CHIP_IS_E1(bp) ? 0x400 : 0x2000)
 
-#define DMAE_COMP_VAL			0xe0d0d0ae
+#define DMAE_COMP_VAL			0x60d0d0ae /* E2 and on - upper bit
+							indicates eror */
 
 #define MAX_DMAE_C_PER_PORT		8
 #define INIT_DMAE_C(bp)			(BP_PORT(bp) * MAX_DMAE_C_PER_PORT + \
@@ -1534,6 +1609,9 @@ static inline u32 reg_poll(struct bnx2x *bp, u32 reg, u32 expected, int ms,
 #define GET_FLAG(value, mask) \
 	(((value) &= (mask)) >> (mask##_SHIFT))
 
+#define GET_FIELD(value, fname) \
+	(((value) & (fname##_MASK)) >> (fname##_SHIFT))
+
 #define CAM_IS_INVALID(x) \
 	(GET_FLAG(x.flags, \
 	MAC_CONFIGURATION_ENTRY_ACTION_TYPE) == \
@@ -1553,6 +1631,9 @@ static inline u32 reg_poll(struct bnx2x *bp, u32 reg, u32 expected, int ms,
 #define PXP2_REG_PXP2_INT_STS		PXP2_REG_PXP2_INT_STS_0
 #endif
 
+#ifndef ETH_MAX_RX_CLIENTS_E2
+#define ETH_MAX_RX_CLIENTS_E2		ETH_MAX_RX_CLIENTS_E1H
+#endif
 #define BNX2X_VPD_LEN			128
 #define VENDOR_ID_LEN			4
 
@@ -1570,13 +1651,18 @@ static inline u32 reg_poll(struct bnx2x *bp, u32 reg, u32 expected, int ms,
 #define BNX2X_EXTERN extern
 #endif
 
-BNX2X_EXTERN int load_count[3]; /* 0-common, 1-port0, 2-port1 */
+BNX2X_EXTERN int load_count[2][3]; /* per path: 0-common, 1-port0, 2-port1 */
 
 /* MISC_REG_RESET_REG - this is here for the hsi to work don't touch */
 
 extern void bnx2x_set_ethtool_ops(struct net_device *netdev);
 
 void bnx2x_post_dmae(struct bnx2x *bp, struct dmae_command *dmae, int idx);
+u32 bnx2x_dmae_opcode_add_comp(u32 opcode, u8 comp_type);
+u32 bnx2x_dmae_opcode_clr_src_reset(u32 opcode);
+u32 bnx2x_dmae_opcode(struct bnx2x *bp, u8 src_type, u8 dst_type,
+		      bool with_comp, u8 comp_type);
+
 
 #define WAIT_RAMROD_POLL	0x01
 #define WAIT_RAMROD_COMMON	0x02
diff --git a/drivers/net/bnx2x/bnx2x_cmn.c b/drivers/net/bnx2x/bnx2x_cmn.c
index ae05987..cffa778 100644
--- a/drivers/net/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/bnx2x/bnx2x_cmn.c
@@ -18,7 +18,7 @@
 
 #include <linux/etherdevice.h>
 #include <linux/ip.h>
-#include <linux/ipv6.h>
+#include <net/ipv6.h>
 #include <net/ip6_checksum.h>
 #include <linux/firmware.h>
 #include "bnx2x_cmn.h"
@@ -118,16 +118,10 @@ int bnx2x_tx_int(struct bnx2x_fastpath *fp)
 
 		pkt_cons = TX_BD(sw_cons);
 
-		/* prefetch(bp->tx_buf_ring[pkt_cons].skb); */
+		DP(NETIF_MSG_TX_DONE, "queue[%d]: hw_cons %u  sw_cons %u "
+				      " pkt_cons %u\n",
+		   fp->index, hw_cons, sw_cons, pkt_cons);
 
-		DP(NETIF_MSG_TX_DONE, "hw_cons %u  sw_cons %u  pkt_cons %u\n",
-		   hw_cons, sw_cons, pkt_cons);
-
-/*		if (NEXT_TX_IDX(sw_cons) != hw_cons) {
-			rmb();
-			prefetch(fp->tx_buf_ring[NEXT_TX_IDX(sw_cons)].skb);
-		}
-*/
 		bd_cons = bnx2x_free_tx_pkt(bp, fp, pkt_cons);
 		sw_cons++;
 	}
@@ -749,8 +743,9 @@ void bnx2x_link_report(struct bnx2x *bp)
 			u16 vn_max_rate;
 
 			vn_max_rate =
-				((bp->mf_config & FUNC_MF_CFG_MAX_BW_MASK) >>
-				 FUNC_MF_CFG_MAX_BW_SHIFT) * 100;
+				((bp->mf_config[BP_VN(bp)] &
+				  FUNC_MF_CFG_MAX_BW_MASK) >>
+						FUNC_MF_CFG_MAX_BW_SHIFT) * 100;
 			if (vn_max_rate < line_speed)
 				line_speed = vn_max_rate;
 		}
@@ -912,14 +907,15 @@ void bnx2x_init_rx_rings(struct bnx2x *bp)
 		if (j != 0)
 			continue;
 
-		REG_WR(bp, BAR_USTRORM_INTMEM +
-		       USTORM_MEM_WORKAROUND_ADDRESS_OFFSET(func),
-		       U64_LO(fp->rx_comp_mapping));
-		REG_WR(bp, BAR_USTRORM_INTMEM +
-		       USTORM_MEM_WORKAROUND_ADDRESS_OFFSET(func) + 4,
-		       U64_HI(fp->rx_comp_mapping));
+		if (!CHIP_IS_E2(bp)) {
+			REG_WR(bp, BAR_USTRORM_INTMEM +
+			       USTORM_MEM_WORKAROUND_ADDRESS_OFFSET(func),
+			       U64_LO(fp->rx_comp_mapping));
+			REG_WR(bp, BAR_USTRORM_INTMEM +
+			       USTORM_MEM_WORKAROUND_ADDRESS_OFFSET(func) + 4,
+			       U64_HI(fp->rx_comp_mapping));
+		}
 	}
-
 }
 static void bnx2x_free_tx_skbs(struct bnx2x *bp)
 {
@@ -1308,23 +1304,27 @@ int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
 		}
 
 	} else {
+		int path = BP_PATH(bp);
 		int port = BP_PORT(bp);
 
-		DP(NETIF_MSG_IFUP, "NO MCP - load counts      %d, %d, %d\n",
-		   load_count[0], load_count[1], load_count[2]);
-		load_count[0]++;
-		load_count[1 + port]++;
-		DP(NETIF_MSG_IFUP, "NO MCP - new load counts  %d, %d, %d\n",
-		   load_count[0], load_count[1], load_count[2]);
-		if (load_count[0] == 1)
+		DP(NETIF_MSG_IFUP, "NO MCP - load counts[%d]      %d, %d, %d\n",
+		   path, load_count[path][0], load_count[path][1],
+		   load_count[path][2]);
+		load_count[path][0]++;
+		load_count[path][1 + port]++;
+		DP(NETIF_MSG_IFUP, "NO MCP - new load counts[%d]  %d, %d, %d\n",
+		   path, load_count[path][0], load_count[path][1],
+		   load_count[path][2]);
+		if (load_count[path][0] == 1)
 			load_code = FW_MSG_CODE_DRV_LOAD_COMMON;
-		else if (load_count[1 + port] == 1)
+		else if (load_count[path][1 + port] == 1)
 			load_code = FW_MSG_CODE_DRV_LOAD_PORT;
 		else
 			load_code = FW_MSG_CODE_DRV_LOAD_FUNCTION;
 	}
 
 	if ((load_code == FW_MSG_CODE_DRV_LOAD_COMMON) ||
+	    (load_code == FW_MSG_CODE_DRV_LOAD_COMMON_CHIP) ||
 	    (load_code == FW_MSG_CODE_DRV_LOAD_PORT))
 		bp->port.pmf = 1;
 	else
@@ -1349,7 +1349,8 @@ int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
 	/* Setup NIC internals and enable interrupts */
 	bnx2x_nic_init(bp, load_code);
 
-	if ((load_code == FW_MSG_CODE_DRV_LOAD_COMMON) &&
+	if (((load_code == FW_MSG_CODE_DRV_LOAD_COMMON) ||
+	    (load_code == FW_MSG_CODE_DRV_LOAD_COMMON_CHIP)) &&
 	    (bp->common.shmem2_base))
 		SHMEM2_WR(bp, dcc_support,
 			  (SHMEM_DCC_SUPPORT_DISABLE_ENABLE_PF_TLV |
@@ -1389,11 +1390,11 @@ int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
 #endif
 	}
 
-	if (CHIP_IS_E1H(bp))
-		if (bp->mf_config & FUNC_MF_CFG_FUNC_DISABLED) {
-			DP(NETIF_MSG_IFUP, "mf_cfg function disabled\n");
-			bp->flags |= MF_FUNC_DIS;
-		}
+	if (!CHIP_IS_E1(bp) &&
+	    (bp->mf_config[BP_VN(bp)] & FUNC_MF_CFG_FUNC_DISABLED)) {
+		DP(NETIF_MSG_IFUP, "mf_cfg function disabled\n");
+		bp->flags |= MF_FUNC_DIS;
+	}
 
 #ifdef BCM_CNIC
 	/* Enable Timer scan */
@@ -1527,8 +1528,10 @@ int bnx2x_nic_unload(struct bnx2x *bp, int unload_mode)
 	bp->rx_mode = BNX2X_RX_MODE_NONE;
 	bnx2x_set_storm_rx_mode(bp);
 
+	/* Stop Tx */
+	bnx2x_tx_disable(bp);
 	del_timer_sync(&bp->timer);
-	SHMEM_WR(bp, func_mb[BP_FUNC(bp)].drv_pulse_mb,
+	SHMEM_WR(bp, func_mb[BP_FW_MB_IDX(bp)].drv_pulse_mb,
 		 (DRV_PULSE_ALWAYS_ALIVE | bp->fw_drv_pulse_wr_seq));
 	bnx2x_stats_handle(bp, STATS_EVENT_STOP);
 
@@ -1855,6 +1858,120 @@ exit_lbl:
 }
 #endif
 
+static inline void bnx2x_set_pbd_gso_e2(struct sk_buff *skb,
+				     struct eth_tx_parse_bd_e2 *pbd,
+				     u32 xmit_type)
+{
+	pbd->parsing_data |= cpu_to_le16(skb_shinfo(skb)->gso_size) <<
+		ETH_TX_PARSE_BD_E2_LSO_MSS_SHIFT;
+	if ((xmit_type & XMIT_GSO_V6) &&
+	    (ipv6_hdr(skb)->nexthdr == NEXTHDR_IPV6))
+		pbd->parsing_data |= ETH_TX_PARSE_BD_E2_IPV6_WITH_EXT_HDR;
+}
+
+/**
+ * Update PBD in GSO case.
+ *
+ * @param skb
+ * @param tx_start_bd
+ * @param pbd
+ * @param xmit_type
+ */
+static inline void bnx2x_set_pbd_gso(struct sk_buff *skb,
+				     struct eth_tx_parse_bd_e1x *pbd,
+				     u32 xmit_type)
+{
+	pbd->lso_mss = cpu_to_le16(skb_shinfo(skb)->gso_size);
+	pbd->tcp_send_seq = swab32(tcp_hdr(skb)->seq);
+	pbd->tcp_flags = pbd_tcp_flags(skb);
+
+	if (xmit_type & XMIT_GSO_V4) {
+		pbd->ip_id = swab16(ip_hdr(skb)->id);
+		pbd->tcp_pseudo_csum =
+			swab16(~csum_tcpudp_magic(ip_hdr(skb)->saddr,
+						  ip_hdr(skb)->daddr,
+						  0, IPPROTO_TCP, 0));
+
+	} else
+		pbd->tcp_pseudo_csum =
+			swab16(~csum_ipv6_magic(&ipv6_hdr(skb)->saddr,
+						&ipv6_hdr(skb)->daddr,
+						0, IPPROTO_TCP, 0));
+
+	pbd->global_data |= ETH_TX_PARSE_BD_E1X_PSEUDO_CS_WITHOUT_LEN;
+}
+/**
+ *
+ * @param skb
+ * @param tx_start_bd
+ * @param pbd_e2
+ * @param xmit_type
+ *
+ * @return header len
+ */
+static inline  u8 bnx2x_set_pbd_csum_e2(struct bnx2x *bp, struct sk_buff *skb,
+	struct eth_tx_parse_bd_e2 *pbd,
+	u32 xmit_type)
+{
+	pbd->parsing_data |= cpu_to_le16(tcp_hdrlen(skb)/4) <<
+		ETH_TX_PARSE_BD_E2_TCP_HDR_LENGTH_DW_SHIFT;
+
+	pbd->parsing_data |= cpu_to_le16(((unsigned char *)tcp_hdr(skb) -
+					  skb->data) / 2) <<
+		ETH_TX_PARSE_BD_E2_TCP_HDR_START_OFFSET_W_SHIFT;
+
+	return skb_transport_header(skb) + tcp_hdrlen(skb) - skb->data;
+}
+
+/**
+ *
+ * @param skb
+ * @param tx_start_bd
+ * @param pbd
+ * @param xmit_type
+ *
+ * @return Header length
+ */
+static inline u8 bnx2x_set_pbd_csum(struct bnx2x *bp, struct sk_buff *skb,
+	struct eth_tx_parse_bd_e1x *pbd,
+	u32 xmit_type)
+{
+	u8 hlen = (skb_network_header(skb) - skb->data) / 2;
+
+	/* for now NS flag is not used in Linux */
+	pbd->global_data =
+		(hlen | ((skb->protocol == cpu_to_be16(ETH_P_8021Q)) <<
+			 ETH_TX_PARSE_BD_E1X_LLC_SNAP_EN_SHIFT));
+
+	pbd->ip_hlen_w = (skb_transport_header(skb) -
+			skb_network_header(skb)) / 2;
+
+	hlen += pbd->ip_hlen_w + tcp_hdrlen(skb) / 2;
+
+	pbd->total_hlen_w = cpu_to_le16(hlen);
+	hlen = hlen*2;
+
+	if (xmit_type & XMIT_CSUM_TCP) {
+		pbd->tcp_pseudo_csum = swab16(tcp_hdr(skb)->check);
+
+	} else {
+		s8 fix = SKB_CS_OFF(skb); /* signed! */
+
+		DP(NETIF_MSG_TX_QUEUED,
+		   "hlen %d  fix %d  csum before fix %x\n",
+		   le16_to_cpu(pbd->total_hlen_w), fix, SKB_CS(skb));
+
+		/* HW bug: fixup the CSUM */
+		pbd->tcp_pseudo_csum =
+			bnx2x_csum_fix(skb_transport_header(skb),
+				       SKB_CS(skb), fix);
+
+		DP(NETIF_MSG_TX_QUEUED, "csum after fix %x\n",
+		   pbd->tcp_pseudo_csum);
+	}
+
+	return hlen;
+}
 /* called with netif_tx_lock
  * bnx2x_tx_int() runs without netif_tx_lock unless it needs to call
  * netif_wake_queue()
@@ -1868,6 +1985,7 @@ netdev_tx_t bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	struct eth_tx_start_bd *tx_start_bd;
 	struct eth_tx_bd *tx_data_bd, *total_pkt_bd = NULL;
 	struct eth_tx_parse_bd_e1x *pbd_e1x = NULL;
+	struct eth_tx_parse_bd_e2 *pbd_e2 = NULL;
 	u16 pkt_prod, bd_prod;
 	int nbd, fp_index;
 	dma_addr_t mapping;
@@ -1895,9 +2013,9 @@ netdev_tx_t bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		return NETDEV_TX_BUSY;
 	}
 
-	DP(NETIF_MSG_TX_QUEUED, "SKB: summed %x  protocol %x  protocol(%x,%x)"
-	   "  gso type %x  xmit_type %x\n",
-	   skb->ip_summed, skb->protocol, ipv6_hdr(skb)->nexthdr,
+	DP(NETIF_MSG_TX_QUEUED, "queue[%d]: SKB: summed %x  protocol %x  "
+				"protocol(%x,%x) gso type %x  xmit_type %x\n",
+	   fp_index, skb->ip_summed, skb->protocol, ipv6_hdr(skb)->nexthdr,
 	   ip_hdr(skb)->protocol, skb_shinfo(skb)->gso_type, xmit_type);
 
 	eth = (struct ethhdr *)skb->data;
@@ -1988,44 +2106,21 @@ netdev_tx_t bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 			tx_start_bd->bd_flags.as_bitfield |=
 						ETH_TX_BD_FLAGS_IS_UDP;
 	}
-	pbd_e1x = &fp->tx_desc_ring[bd_prod].parse_bd_e1x;
-	memset(pbd_e1x, 0, sizeof(struct eth_tx_parse_bd_e1x));
-	/* Set PBD in checksum offload case */
-	if (xmit_type & XMIT_CSUM) {
-		hlen = (skb_network_header(skb) - skb->data) / 2;
 
-		/* for now NS flag is not used in Linux */
-		pbd_e1x->global_data =
-			(hlen | ((skb->protocol == cpu_to_be16(ETH_P_8021Q)) <<
-			 ETH_TX_PARSE_BD_E1X_LLC_SNAP_EN_SHIFT));
-
-		pbd_e1x->ip_hlen_w = (skb_transport_header(skb) -
-				skb_network_header(skb)) / 2;
-
-		hlen += pbd_e1x->ip_hlen_w + tcp_hdrlen(skb) / 2;
-
-		pbd_e1x->total_hlen_w = cpu_to_le16(hlen);
-		hlen = hlen*2;
-
-		if (xmit_type & XMIT_CSUM_TCP) {
-			pbd_e1x->tcp_pseudo_csum = swab16(tcp_hdr(skb)->check);
-
-		} else {
-			s8 fix = SKB_CS_OFF(skb); /* signed! */
-
-			DP(NETIF_MSG_TX_QUEUED,
-			   "hlen %d  fix %d  csum before fix %x\n",
-			   le16_to_cpu(pbd_e1x->total_hlen_w),
-			   fix, SKB_CS(skb));
-
-			/* HW bug: fixup the CSUM */
-			pbd_e1x->tcp_pseudo_csum =
-				bnx2x_csum_fix(skb_transport_header(skb),
-					       SKB_CS(skb), fix);
+	if (CHIP_IS_E2(bp)) {
+		pbd_e2 = &fp->tx_desc_ring[bd_prod].parse_bd_e2;
+		memset(pbd_e2, 0, sizeof(struct eth_tx_parse_bd_e2));
+		/* Set PBD in checksum offload case */
+		if (xmit_type & XMIT_CSUM)
+			hlen = bnx2x_set_pbd_csum_e2(bp,
+						     skb, pbd_e2, xmit_type);
+	} else {
+		pbd_e1x = &fp->tx_desc_ring[bd_prod].parse_bd_e1x;
+		memset(pbd_e1x, 0, sizeof(struct eth_tx_parse_bd_e1x));
+		/* Set PBD in checksum offload case */
+		if (xmit_type & XMIT_CSUM)
+			hlen = bnx2x_set_pbd_csum(bp, skb, pbd_e1x, xmit_type);
 
-			DP(NETIF_MSG_TX_QUEUED, "csum after fix %x\n",
-			   pbd_e1x->tcp_pseudo_csum);
-		}
 	}
 
 	mapping = dma_map_single(&bp->pdev->dev, skb->data,
@@ -2057,26 +2152,10 @@ netdev_tx_t bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		if (unlikely(skb_headlen(skb) > hlen))
 			bd_prod = bnx2x_tx_split(bp, fp, tx_buf, &tx_start_bd,
 						 hlen, bd_prod, ++nbd);
-
-		pbd_e1x->lso_mss = cpu_to_le16(skb_shinfo(skb)->gso_size);
-		pbd_e1x->tcp_send_seq = swab32(tcp_hdr(skb)->seq);
-		pbd_e1x->tcp_flags = pbd_tcp_flags(skb);
-
-		if (xmit_type & XMIT_GSO_V4) {
-			pbd_e1x->ip_id = swab16(ip_hdr(skb)->id);
-			pbd_e1x->tcp_pseudo_csum =
-				swab16(~csum_tcpudp_magic(ip_hdr(skb)->saddr,
-							  ip_hdr(skb)->daddr,
-							  0, IPPROTO_TCP, 0));
-
-		} else
-			pbd_e1x->tcp_pseudo_csum =
-				swab16(~csum_ipv6_magic(&ipv6_hdr(skb)->saddr,
-							&ipv6_hdr(skb)->daddr,
-							0, IPPROTO_TCP, 0));
-
-		pbd_e1x->global_data |=
-				ETH_TX_PARSE_BD_E1X_PSEUDO_CS_WITHOUT_LEN;
+		if (CHIP_IS_E2(bp))
+			bnx2x_set_pbd_gso_e2(skb, pbd_e2, xmit_type);
+		else
+			bnx2x_set_pbd_gso(skb, pbd_e1x, xmit_type);
 	}
 	tx_data_bd = (struct eth_tx_bd *)tx_start_bd;
 
@@ -2124,7 +2203,13 @@ netdev_tx_t bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		   pbd_e1x->ip_id, pbd_e1x->lso_mss, pbd_e1x->tcp_flags,
 		   pbd_e1x->tcp_pseudo_csum, pbd_e1x->tcp_send_seq,
 		    le16_to_cpu(pbd_e1x->total_hlen_w));
-
+	if (pbd_e2)
+		DP(NETIF_MSG_TX_QUEUED,
+		   "PBD (E2) @%p  dst %x %x %x src %x %x %x parsing_data %x\n",
+		   pbd_e2, pbd_e2->dst_mac_addr_hi, pbd_e2->dst_mac_addr_mid,
+		   pbd_e2->dst_mac_addr_lo, pbd_e2->src_mac_addr_hi,
+		   pbd_e2->src_mac_addr_mid, pbd_e2->src_mac_addr_lo,
+		   pbd_e2->parsing_data);
 	DP(NETIF_MSG_TX_QUEUED, "doorbell: nbd %d  bd %u\n", nbd, bd_prod);
 
 	/*
@@ -2327,6 +2412,8 @@ int bnx2x_resume(struct pci_dev *pdev)
 	bnx2x_set_power_state(bp, PCI_D0);
 	netif_device_attach(dev);
 
+	/* Since the chip was reset, clear the FW sequence number */
+	bp->fw_seq = 0;
 	rc = bnx2x_nic_load(bp, LOAD_OPEN);
 
 	rtnl_unlock();
diff --git a/drivers/net/bnx2x/bnx2x_cmn.h b/drivers/net/bnx2x/bnx2x_cmn.h
index 2fb9045..41d0a17 100644
--- a/drivers/net/bnx2x/bnx2x_cmn.h
+++ b/drivers/net/bnx2x/bnx2x_cmn.h
@@ -366,10 +366,77 @@ static inline void bnx2x_update_rx_prod(struct bnx2x *bp,
 	   fp->index, bd_prod, rx_comp_prod, rx_sge_prod);
 }
 
+static inline void bnx2x_igu_ack_sb_gen(struct bnx2x *bp, u8 igu_sb_id,
+					u8 segment, u16 index, u8 op,
+					u8 update, u32 igu_addr)
+{
+	struct igu_regular cmd_data = {0};
+
+	cmd_data.sb_id_and_flags =
+			((index << IGU_REGULAR_SB_INDEX_SHIFT) |
+			 (segment << IGU_REGULAR_SEGMENT_ACCESS_SHIFT) |
+			 (update << IGU_REGULAR_BUPDATE_SHIFT) |
+			 (op << IGU_REGULAR_ENABLE_INT_SHIFT));
 
+	DP(NETIF_MSG_HW, "write 0x%08x to IGU addr 0x%x\n",
+	   cmd_data.sb_id_and_flags, igu_addr);
+	REG_WR(bp, igu_addr, cmd_data.sb_id_and_flags);
+
+	/* Make sure that ACK is written */
+	mmiowb();
+	barrier();
+}
 
-static inline void bnx2x_ack_sb(struct bnx2x *bp, u8 sb_id,
-				u8 storm, u16 index, u8 op, u8 update)
+static inline void bnx2x_igu_clear_sb_gen(struct bnx2x *bp,
+					  u8 idu_sb_id, bool is_Pf)
+{
+	u32 data, ctl, cnt = 100;
+	u32 igu_addr_data = IGU_REG_COMMAND_REG_32LSB_DATA;
+	u32 igu_addr_ctl = IGU_REG_COMMAND_REG_CTRL;
+	u32 igu_addr_ack = IGU_REG_CSTORM_TYPE_0_SB_CLEANUP + (idu_sb_id/32)*4;
+	u32 sb_bit =  1 << (idu_sb_id%32);
+	u32 func_encode = BP_FUNC(bp) |
+			((is_Pf == true ? 1 : 0) << IGU_FID_ENCODE_IS_PF_SHIFT);
+	u32 addr_encode = IGU_CMD_E2_PROD_UPD_BASE + idu_sb_id;
+
+	/* Not supported in BC mode */
+	if (CHIP_INT_MODE_IS_BC(bp))
+		return;
+
+	data = (IGU_USE_REGISTER_cstorm_type_0_sb_cleanup
+			<< IGU_REGULAR_CLEANUP_TYPE_SHIFT)	|
+		IGU_REGULAR_CLEANUP_SET				|
+		IGU_REGULAR_BCLEANUP;
+
+	ctl = addr_encode << IGU_CTRL_REG_ADDRESS_SHIFT		|
+	      func_encode << IGU_CTRL_REG_FID_SHIFT		|
+	      IGU_CTRL_CMD_TYPE_WR << IGU_CTRL_REG_TYPE_SHIFT;
+
+	DP(NETIF_MSG_HW, "write 0x%08x to IGU(via GRC) addr 0x%x\n",
+			 data, igu_addr_data);
+	REG_WR(bp, igu_addr_data, data);
+	mmiowb();
+	barrier();
+	DP(NETIF_MSG_HW, "write 0x%08x to IGU(via GRC) addr 0x%x\n",
+			  ctl, igu_addr_ctl);
+	REG_WR(bp, igu_addr_ctl, ctl);
+	mmiowb();
+	barrier();
+
+	/* wait for clean up to finish */
+	while (!(REG_RD(bp, igu_addr_ack) & sb_bit) && --cnt)
+		msleep(20);
+
+
+	if (!(REG_RD(bp, igu_addr_ack) & sb_bit)) {
+		DP(NETIF_MSG_HW, "Unable to finish IGU cleanup: "
+			  "idu_sb_id %d offset %d bit %d (cnt %d)\n",
+			  idu_sb_id, idu_sb_id/32, idu_sb_id%32, cnt);
+	}
+}
+
+static inline void bnx2x_hc_ack_sb(struct bnx2x *bp, u8 sb_id,
+				   u8 storm, u16 index, u8 op, u8 update)
 {
 	u32 hc_addr = (HC_REG_COMMAND_REG + BP_PORT(bp)*32 +
 		       COMMAND_REG_INT_ACK);
@@ -390,7 +457,37 @@ static inline void bnx2x_ack_sb(struct bnx2x *bp, u8 sb_id,
 	mmiowb();
 	barrier();
 }
-static inline u16 bnx2x_ack_int(struct bnx2x *bp)
+
+static inline void bnx2x_igu_ack_sb(struct bnx2x *bp, u8 igu_sb_id, u8 segment,
+		      u16 index, u8 op, u8 update)
+{
+	u32 igu_addr = BAR_IGU_INTMEM + (IGU_CMD_INT_ACK_BASE + igu_sb_id)*8;
+
+	bnx2x_igu_ack_sb_gen(bp, igu_sb_id, segment, index, op, update,
+			     igu_addr);
+}
+
+static inline void bnx2x_ack_sb(struct bnx2x *bp, u8 igu_sb_id, u8 storm,
+				u16 index, u8 op, u8 update)
+{
+	if (bp->common.int_block == INT_BLOCK_HC)
+		bnx2x_hc_ack_sb(bp, igu_sb_id, storm, index, op, update);
+	else {
+		u8 segment;
+
+		if (CHIP_INT_MODE_IS_BC(bp))
+			segment = storm;
+		else if (igu_sb_id != bp->igu_dsb_id)
+			segment = IGU_SEG_ACCESS_DEF;
+		else if (storm == ATTENTION_ID)
+			segment = IGU_SEG_ACCESS_ATTN;
+		else
+			segment = IGU_SEG_ACCESS_DEF;
+		bnx2x_igu_ack_sb(bp, igu_sb_id, segment, index, op, update);
+	}
+}
+
+static inline u16 bnx2x_hc_ack_int(struct bnx2x *bp)
 {
 	u32 hc_addr = (HC_REG_COMMAND_REG + BP_PORT(bp)*32 +
 		       COMMAND_REG_SIMD_MASK);
@@ -399,13 +496,34 @@ static inline u16 bnx2x_ack_int(struct bnx2x *bp)
 	DP(BNX2X_MSG_OFF, "read 0x%08x from HC addr 0x%x\n",
 	   result, hc_addr);
 
+	barrier();
+	return result;
+}
+
+static inline u16 bnx2x_igu_ack_int(struct bnx2x *bp)
+{
+	u32 igu_addr = (BAR_IGU_INTMEM + IGU_REG_SISR_MDPC_WMASK_LSB_UPPER*8);
+	u32 result = REG_RD(bp, igu_addr);
+
+	DP(NETIF_MSG_HW, "read 0x%08x from IGU addr 0x%x\n",
+	   result, igu_addr);
+
+	barrier();
 	return result;
 }
 
+static inline u16 bnx2x_ack_int(struct bnx2x *bp)
+{
+	barrier();
+	if (bp->common.int_block == INT_BLOCK_HC)
+		return bnx2x_hc_ack_int(bp);
+	else
+		return bnx2x_igu_ack_int(bp);
+}
+
 /*
  * fast path service functions
  */
-
 static inline int bnx2x_has_tx_work_unload(struct bnx2x_fastpath *fp)
 {
 	/* Tell compiler that consumer and producer can change */
@@ -456,6 +574,17 @@ static inline int bnx2x_has_rx_work(struct bnx2x_fastpath *fp)
 		rx_cons_sb++;
 	return (fp->rx_comp_cons != rx_cons_sb);
 }
+/**
+ * disables tx from stack point of view
+ *
+ * @param bp
+ */
+static inline void bnx2x_tx_disable(struct bnx2x *bp)
+{
+	netif_tx_disable(bp->dev);
+	netif_carrier_off(bp->dev);
+}
+
 static inline void bnx2x_free_rx_sge(struct bnx2x *bp,
 				     struct bnx2x_fastpath *fp, u16 index)
 {
diff --git a/drivers/net/bnx2x/bnx2x_dump.h b/drivers/net/bnx2x/bnx2x_dump.h
index 3bb9a91..dc18c25 100644
--- a/drivers/net/bnx2x/bnx2x_dump.h
+++ b/drivers/net/bnx2x/bnx2x_dump.h
@@ -31,14 +31,24 @@ struct dump_sign {
 
 #define RI_E1				0x1
 #define RI_E1H				0x2
+#define RI_E2			0x4
 #define RI_ONLINE			0x100
-
+#define RI_PATH0_DUMP		0x200
+#define RI_PATH1_DUMP		0x400
 #define RI_E1_OFFLINE			(RI_E1)
 #define RI_E1_ONLINE			(RI_E1 | RI_ONLINE)
 #define RI_E1H_OFFLINE			(RI_E1H)
 #define RI_E1H_ONLINE			(RI_E1H | RI_ONLINE)
-#define RI_ALL_OFFLINE			(RI_E1 | RI_E1H)
-#define RI_ALL_ONLINE			(RI_E1 | RI_E1H | RI_ONLINE)
+#define RI_E2_OFFLINE			(RI_E2)
+#define RI_E2_ONLINE			(RI_E2 | RI_ONLINE)
+#define RI_E1E1H_OFFLINE		(RI_E1 | RI_E1H)
+#define RI_E1E1H_ONLINE			(RI_E1 | RI_E1H | RI_ONLINE)
+#define RI_E1HE2_OFFLINE		(RI_E2 | RI_E1H)
+#define RI_E1HE2_ONLINE			(RI_E2 | RI_E1H | RI_ONLINE)
+#define RI_E1E2_OFFLINE			(RI_E2 | RI_E1)
+#define RI_E1E2_ONLINE			(RI_E2 | RI_E1 | RI_ONLINE)
+#define RI_ALL_OFFLINE			(RI_E1 | RI_E1H | RI_E2)
+#define RI_ALL_ONLINE			(RI_E1 | RI_E1H | RI_E2 | RI_ONLINE)
 
 #define MAX_TIMER_PENDING		200
 #define TIMER_SCAN_DONT_CARE		0xFF
@@ -513,6 +523,12 @@ static const struct wreg_addr wreg_addrs_e1h[WREGS_COUNT_E1H] = {
 	{ 0x1b0c00, 256, 2, read_reg_e1h_0, RI_E1H_OFFLINE }
 };
 
+#define WREGS_COUNT_E2			1
+static const u32 read_reg_e2_0[] = { 0x1b1040, 0x1b1000 };
+
+static const struct wreg_addr wreg_addrs_e2[WREGS_COUNT_E2] = {
+	{ 0x1b0c00, 128, 2, read_reg_e2_0, RI_E2_OFFLINE }
+};
 
 static const struct dump_sign dump_sign_all = { 0x49aa93ee, 0x40835, 0x22 };
 
@@ -531,4 +547,17 @@ static const u32 timer_scan_regs_e1h[TIMER_REGS_COUNT_E1H] =
 	{ 0x1640d0, 0x1640d4 };
 
 
+#define PAGE_MODE_VALUES_E2 2
+
+#define PAGE_READ_REGS_E2 1
+
+#define PAGE_WRITE_REGS_E2 1
+
+static const u32 page_vals_e2[PAGE_MODE_VALUES_E2] = { 0, 128 };
+
+static const u32 page_write_regs_e2[PAGE_WRITE_REGS_E2] = { 328476 };
+
+static const struct reg_addr page_read_regs_e2[PAGE_READ_REGS_E2] = {
+	{ 0x58000, 4608, RI_E2_ONLINE } };
+
 #endif /* BNX2X_DUMP_H */
diff --git a/drivers/net/bnx2x/bnx2x_ethtool.c b/drivers/net/bnx2x/bnx2x_ethtool.c
index fa8f952..8fb0027 100644
--- a/drivers/net/bnx2x/bnx2x_ethtool.c
+++ b/drivers/net/bnx2x/bnx2x_ethtool.c
@@ -41,19 +41,19 @@ static int bnx2x_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 	    (bp->link_vars.link_up)) {
 		cmd->speed = bp->link_vars.line_speed;
 		cmd->duplex = bp->link_vars.duplex;
-		if (IS_MF(bp)) {
-			u16 vn_max_rate;
-
-			vn_max_rate =
-				((bp->mf_config & FUNC_MF_CFG_MAX_BW_MASK) >>
-				FUNC_MF_CFG_MAX_BW_SHIFT) * 100;
-			if (vn_max_rate < cmd->speed)
-				cmd->speed = vn_max_rate;
-		}
 	} else {
+
 		cmd->speed = bp->link_params.req_line_speed[cfg_idx];
 		cmd->duplex = bp->link_params.req_duplex[cfg_idx];
 	}
+	if (IS_MF(bp)) {
+		u16 vn_max_rate = ((bp->mf_config[BP_VN(bp)] &
+			FUNC_MF_CFG_MAX_BW_MASK) >> FUNC_MF_CFG_MAX_BW_SHIFT) *
+			100;
+
+		if (vn_max_rate < cmd->speed)
+			cmd->speed = vn_max_rate;
+	}
 
 	if (bp->port.supported[cfg_idx] & SUPPORTED_TP)
 		cmd->port = PORT_TP;
@@ -298,6 +298,7 @@ static int bnx2x_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 
 #define IS_E1_ONLINE(info)	(((info) & RI_E1_ONLINE) == RI_E1_ONLINE)
 #define IS_E1H_ONLINE(info)	(((info) & RI_E1H_ONLINE) == RI_E1H_ONLINE)
+#define IS_E2_ONLINE(info)	(((info) & RI_E2_ONLINE) == RI_E2_ONLINE)
 
 static int bnx2x_get_regs_len(struct net_device *dev)
 {
@@ -315,7 +316,7 @@ static int bnx2x_get_regs_len(struct net_device *dev)
 				regdump_len += wreg_addrs_e1[i].size *
 					(1 + wreg_addrs_e1[i].read_regs_count);
 
-	} else { /* E1H */
+	} else if (CHIP_IS_E1H(bp)) {
 		for (i = 0; i < REGS_COUNT; i++)
 			if (IS_E1H_ONLINE(reg_addrs[i].info))
 				regdump_len += reg_addrs[i].size;
@@ -324,6 +325,15 @@ static int bnx2x_get_regs_len(struct net_device *dev)
 			if (IS_E1H_ONLINE(wreg_addrs_e1h[i].info))
 				regdump_len += wreg_addrs_e1h[i].size *
 					(1 + wreg_addrs_e1h[i].read_regs_count);
+	} else if (CHIP_IS_E2(bp)) {
+		for (i = 0; i < REGS_COUNT; i++)
+			if (IS_E2_ONLINE(reg_addrs[i].info))
+				regdump_len += reg_addrs[i].size;
+
+		for (i = 0; i < WREGS_COUNT_E2; i++)
+			if (IS_E2_ONLINE(wreg_addrs_e2[i].info))
+				regdump_len += wreg_addrs_e2[i].size *
+					(1 + wreg_addrs_e2[i].read_regs_count);
 	}
 	regdump_len *= 4;
 	regdump_len += sizeof(struct dump_hdr);
@@ -331,6 +341,23 @@ static int bnx2x_get_regs_len(struct net_device *dev)
 	return regdump_len;
 }
 
+static inline void bnx2x_read_pages_regs_e2(struct bnx2x *bp, u32 *p)
+{
+	u32 i, j, k, n;
+
+	for (i = 0; i < PAGE_MODE_VALUES_E2; i++) {
+		for (j = 0; j < PAGE_WRITE_REGS_E2; j++) {
+			REG_WR(bp, page_write_regs_e2[j], page_vals_e2[i]);
+			for (k = 0; k < PAGE_READ_REGS_E2; k++)
+				if (IS_E2_ONLINE(page_read_regs_e2[k].info))
+					for (n = 0; n <
+					      page_read_regs_e2[k].size; n++)
+						*p++ = REG_RD(bp,
+					page_read_regs_e2[k].addr + n*4);
+		}
+	}
+}
+
 static void bnx2x_get_regs(struct net_device *dev,
 			   struct ethtool_regs *regs, void *_p)
 {
@@ -350,7 +377,14 @@ static void bnx2x_get_regs(struct net_device *dev,
 	dump_hdr.tstorm_waitp = REG_RD(bp, TSTORM_WAITP_ADDR);
 	dump_hdr.ustorm_waitp = REG_RD(bp, USTORM_WAITP_ADDR);
 	dump_hdr.cstorm_waitp = REG_RD(bp, CSTORM_WAITP_ADDR);
-	dump_hdr.info = CHIP_IS_E1(bp) ? RI_E1_ONLINE : RI_E1H_ONLINE;
+
+	if (CHIP_IS_E1(bp))
+		dump_hdr.info = RI_E1_ONLINE;
+	else if (CHIP_IS_E1H(bp))
+		dump_hdr.info = RI_E1H_ONLINE;
+	else if (CHIP_IS_E2(bp))
+		dump_hdr.info = RI_E2_ONLINE |
+		(BP_PATH(bp) ? RI_PATH1_DUMP : RI_PATH0_DUMP);
 
 	memcpy(p, &dump_hdr, sizeof(struct dump_hdr));
 	p += dump_hdr.hdr_size + 1;
@@ -362,16 +396,25 @@ static void bnx2x_get_regs(struct net_device *dev,
 					*p++ = REG_RD(bp,
 						      reg_addrs[i].addr + j*4);
 
-	} else { /* E1H */
+	} else if (CHIP_IS_E1H(bp)) {
 		for (i = 0; i < REGS_COUNT; i++)
 			if (IS_E1H_ONLINE(reg_addrs[i].info))
 				for (j = 0; j < reg_addrs[i].size; j++)
 					*p++ = REG_RD(bp,
 						      reg_addrs[i].addr + j*4);
+
+	} else if (CHIP_IS_E2(bp)) {
+		for (i = 0; i < REGS_COUNT; i++)
+			if (IS_E2_ONLINE(reg_addrs[i].info))
+				for (j = 0; j < reg_addrs[i].size; j++)
+					*p++ = REG_RD(bp,
+					      reg_addrs[i].addr + j*4);
+
+		bnx2x_read_pages_regs_e2(bp, p);
 	}
 }
 
-#define PHY_FW_VER_LEN			10
+#define PHY_FW_VER_LEN			20
 
 static void bnx2x_get_drvinfo(struct net_device *dev,
 			      struct ethtool_drvinfo *info)
@@ -474,7 +517,7 @@ static u32 bnx2x_get_link(struct net_device *dev)
 {
 	struct bnx2x *bp = netdev_priv(dev);
 
-	if (bp->flags & MF_FUNC_DIS)
+	if (bp->flags & MF_FUNC_DIS || (bp->state != BNX2X_STATE_OPEN))
 		return 0;
 
 	return bp->link_vars.link_up;
@@ -1235,6 +1278,9 @@ static int bnx2x_test_registers(struct bnx2x *bp)
 
 		for (i = 0; reg_tbl[i].offset0 != 0xffffffff; i++) {
 			u32 offset, mask, save_val, val;
+			if (CHIP_IS_E2(bp) &&
+			    reg_tbl[i].offset0 == HC_REG_AGG_INT_0)
+				continue;
 
 			offset = reg_tbl[i].offset0 + port*reg_tbl[i].offset1;
 			mask = reg_tbl[i].mask;
@@ -1286,20 +1332,33 @@ static int bnx2x_test_memory(struct bnx2x *bp)
 		u32 offset;
 		u32 e1_mask;
 		u32 e1h_mask;
+		u32 e2_mask;
 	} prty_tbl[] = {
-		{ "CCM_PRTY_STS",  CCM_REG_CCM_PRTY_STS,   0x3ffc0, 0 },
-		{ "CFC_PRTY_STS",  CFC_REG_CFC_PRTY_STS,   0x2,     0x2 },
-		{ "DMAE_PRTY_STS", DMAE_REG_DMAE_PRTY_STS, 0,       0 },
-		{ "TCM_PRTY_STS",  TCM_REG_TCM_PRTY_STS,   0x3ffc0, 0 },
-		{ "UCM_PRTY_STS",  UCM_REG_UCM_PRTY_STS,   0x3ffc0, 0 },
-		{ "XCM_PRTY_STS",  XCM_REG_XCM_PRTY_STS,   0x3ffc1, 0 },
-
-		{ NULL, 0xffffffff, 0, 0 }
+		{ "CCM_PRTY_STS",  CCM_REG_CCM_PRTY_STS,   0x3ffc0, 0,   0 },
+		{ "CFC_PRTY_STS",  CFC_REG_CFC_PRTY_STS,   0x2,     0x2, 0 },
+		{ "DMAE_PRTY_STS", DMAE_REG_DMAE_PRTY_STS, 0,       0,   0 },
+		{ "TCM_PRTY_STS",  TCM_REG_TCM_PRTY_STS,   0x3ffc0, 0,   0 },
+		{ "UCM_PRTY_STS",  UCM_REG_UCM_PRTY_STS,   0x3ffc0, 0,   0 },
+		{ "XCM_PRTY_STS",  XCM_REG_XCM_PRTY_STS,   0x3ffc1, 0,   0 },
+
+		{ NULL, 0xffffffff, 0, 0, 0 }
 	};
 
 	if (!netif_running(bp->dev))
 		return rc;
 
+	/* pre-Check the parity status */
+	for (i = 0; prty_tbl[i].offset != 0xffffffff; i++) {
+		val = REG_RD(bp, prty_tbl[i].offset);
+		if ((CHIP_IS_E1(bp) && (val & ~(prty_tbl[i].e1_mask))) ||
+		    (CHIP_IS_E1H(bp) && (val & ~(prty_tbl[i].e1h_mask))) ||
+		    (CHIP_IS_E2(bp) && (val & ~(prty_tbl[i].e2_mask)))) {
+			DP(NETIF_MSG_HW,
+			   "%s is 0x%x\n", prty_tbl[i].name, val);
+			goto test_mem_exit;
+		}
+	}
+
 	/* Go through all the memories */
 	for (i = 0; mem_tbl[i].offset != 0xffffffff; i++)
 		for (j = 0; j < mem_tbl[i].size; j++)
@@ -1309,7 +1368,8 @@ static int bnx2x_test_memory(struct bnx2x *bp)
 	for (i = 0; prty_tbl[i].offset != 0xffffffff; i++) {
 		val = REG_RD(bp, prty_tbl[i].offset);
 		if ((CHIP_IS_E1(bp) && (val & ~(prty_tbl[i].e1_mask))) ||
-		    (CHIP_IS_E1H(bp) && (val & ~(prty_tbl[i].e1h_mask)))) {
+		    (CHIP_IS_E1H(bp) && (val & ~(prty_tbl[i].e1h_mask))) ||
+		    (CHIP_IS_E2(bp) && (val & ~(prty_tbl[i].e2_mask)))) {
 			DP(NETIF_MSG_HW,
 			   "%s is 0x%x\n", prty_tbl[i].name, val);
 			goto test_mem_exit;
@@ -1324,7 +1384,7 @@ test_mem_exit:
 
 static void bnx2x_wait_for_link(struct bnx2x *bp, u8 link_up, u8 is_serdes)
 {
-	int cnt = 1000;
+	int cnt = 1400;
 
 	if (link_up)
 		while (bnx2x_link_test(bp, is_serdes) && cnt--)
@@ -1343,7 +1403,8 @@ static int bnx2x_run_loopback(struct bnx2x *bp, int loopback_mode, u8 link_up)
 	u16 pkt_prod, bd_prod;
 	struct sw_tx_bd *tx_buf;
 	struct eth_tx_start_bd *tx_start_bd;
-	struct eth_tx_parse_bd_e1x *pbd_e1x = NULL;
+	struct eth_tx_parse_bd_e1x  *pbd_e1x = NULL;
+	struct eth_tx_parse_bd_e2  *pbd_e2 = NULL;
 	dma_addr_t mapping;
 	union eth_rx_cqe *cqe;
 	u8 cqe_fp_flags;
@@ -1411,7 +1472,9 @@ static int bnx2x_run_loopback(struct bnx2x *bp, int loopback_mode, u8 link_up)
 	/* turn on parsing and get a BD */
 	bd_prod = TX_BD(NEXT_TX_IDX(bd_prod));
 	pbd_e1x = &fp_tx->tx_desc_ring[bd_prod].parse_bd_e1x;
+	pbd_e2 = &fp_tx->tx_desc_ring[bd_prod].parse_bd_e2;
 
+	memset(pbd_e2, 0, sizeof(struct eth_tx_parse_bd_e2));
 	memset(pbd_e1x, 0, sizeof(struct eth_tx_parse_bd_e1x));
 
 	wmb();
@@ -1431,6 +1494,13 @@ static int bnx2x_run_loopback(struct bnx2x *bp, int loopback_mode, u8 link_up)
 	if (tx_idx != tx_start_idx + num_pkts)
 		goto test_loopback_exit;
 
+	/* Unlike HC IGU won't generate an interrupt for status block
+	 * updates that have been performed while interrupts were
+	 * disabled.
+	 */
+	if (bp->common.int_block == INT_BLOCK_IGU)
+		bnx2x_tx_int(fp_tx);
+
 	rx_idx = le16_to_cpu(*fp_rx->rx_cons_sb);
 	if (rx_idx != rx_start_idx + num_pkts)
 		goto test_loopback_exit;
@@ -1573,8 +1643,7 @@ static int bnx2x_test_intr(struct bnx2x *bp)
 
 	config->hdr.length = 0;
 	if (CHIP_IS_E1(bp))
-		/* use last unicast entries */
-		config->hdr.offset = (BP_PORT(bp) ? 63 : 31);
+		config->hdr.offset = (BP_PORT(bp) ? 32 : 0);
 	else
 		config->hdr.offset = BP_FUNC(bp);
 	config->hdr.client_id = bp->fp->cl_id;
diff --git a/drivers/net/bnx2x/bnx2x_hsi.h b/drivers/net/bnx2x/bnx2x_hsi.h
index 596041c..18c8e23 100644
--- a/drivers/net/bnx2x/bnx2x_hsi.h
+++ b/drivers/net/bnx2x/bnx2x_hsi.h
@@ -663,6 +663,7 @@ struct shm_dev_info {						    /* size */
 #define FUNC_7				7
 #define E1_FUNC_MAX			2
 #define E1H_FUNC_MAX			8
+#define E2_FUNC_MAX	    4	/* per path */
 
 #define VN_0				0
 #define VN_1				1
@@ -821,6 +822,9 @@ struct drv_func_mb {
 #define FW_MSG_CODE_DRV_LOAD_COMMON			0x10100000
 #define FW_MSG_CODE_DRV_LOAD_PORT			0x10110000
 #define FW_MSG_CODE_DRV_LOAD_FUNCTION			0x10120000
+	/* Load common chip is supported from bc 6.0.0	*/
+#define REQ_BC_VER_4_DRV_LOAD_COMMON_CHIP	0x00060000
+#define FW_MSG_CODE_DRV_LOAD_COMMON_CHIP	0x10130000
 #define FW_MSG_CODE_DRV_LOAD_REFUSED			0x10200000
 #define FW_MSG_CODE_DRV_LOAD_DONE			0x11100000
 #define FW_MSG_CODE_DRV_UNLOAD_COMMON			0x20100000
@@ -1026,7 +1030,17 @@ struct shmem_region {			       /*   SharedMem Offset (size) */
 
 }; /* 57710 = 0x6dc | 57711 = 0x7E4 | 57712 = 0x734 */
 
+struct fw_flr_ack {
+	u32	pf_ack;
+	u32	vf_ack[1];
+	u32	iov_dis_ack;
+};
 
+struct fw_flr_mb {
+	u32	aggint;
+	u32	opgen_addr;
+	struct	fw_flr_ack ack;
+};
 
 
 struct shmem2_region {
@@ -1046,7 +1060,20 @@ struct shmem2_region {
 	 * For backwards compatibility, if the mf_cfg_addr does not exist
 	 * (the size filed is smaller than 0xc) the mf_cfg resides at the
 	 * end of struct shmem_region
+     */
+	u32	mf_cfg_addr;
+#define SHMEM_MF_CFG_ADDR_NONE			    0x00000000
+
+	struct fw_flr_mb flr_mb;
+	u32	reserved[3];
+	/*
+	 * The other shmemX_base_addr holds the other path's shmem address
+	 * required for example in case of common phy init, or for path1 to know
+	 * the address of mcp debug trace which is located in offset from shmem
+	 * of path0
 	 */
+	u32 other_shmem_base_addr;
+	u32 other_shmem2_base_addr;
 };
 
 
@@ -1206,10 +1233,126 @@ struct bmac1_stats {
     u32     rx_stat_gripj_hi;
 };
 
+struct bmac2_stats {
+	u32	tx_stat_gtpk_lo; /* gtpok */
+	u32	tx_stat_gtpk_hi; /* gtpok */
+	u32	tx_stat_gtxpf_lo; /* gtpf */
+	u32	tx_stat_gtxpf_hi; /* gtpf */
+	u32	tx_stat_gtpp_lo; /* NEW BMAC2 */
+	u32	tx_stat_gtpp_hi; /* NEW BMAC2 */
+	u32	tx_stat_gtfcs_lo;
+	u32	tx_stat_gtfcs_hi;
+	u32	tx_stat_gtuca_lo; /* NEW BMAC2 */
+	u32	tx_stat_gtuca_hi; /* NEW BMAC2 */
+	u32	tx_stat_gtmca_lo;
+	u32	tx_stat_gtmca_hi;
+	u32	tx_stat_gtbca_lo;
+	u32	tx_stat_gtbca_hi;
+	u32	tx_stat_gtovr_lo;
+	u32	tx_stat_gtovr_hi;
+	u32	tx_stat_gtfrg_lo;
+	u32	tx_stat_gtfrg_hi;
+	u32	tx_stat_gtpkt1_lo; /* gtpkt */
+	u32	tx_stat_gtpkt1_hi; /* gtpkt */
+	u32	tx_stat_gt64_lo;
+	u32	tx_stat_gt64_hi;
+	u32	tx_stat_gt127_lo;
+	u32	tx_stat_gt127_hi;
+	u32	tx_stat_gt255_lo;
+	u32	tx_stat_gt255_hi;
+	u32	tx_stat_gt511_lo;
+	u32	tx_stat_gt511_hi;
+	u32	tx_stat_gt1023_lo;
+	u32	tx_stat_gt1023_hi;
+	u32	tx_stat_gt1518_lo;
+	u32	tx_stat_gt1518_hi;
+	u32	tx_stat_gt2047_lo;
+	u32	tx_stat_gt2047_hi;
+	u32	tx_stat_gt4095_lo;
+	u32	tx_stat_gt4095_hi;
+	u32	tx_stat_gt9216_lo;
+	u32	tx_stat_gt9216_hi;
+	u32	tx_stat_gt16383_lo;
+	u32	tx_stat_gt16383_hi;
+	u32	tx_stat_gtmax_lo;
+	u32	tx_stat_gtmax_hi;
+	u32	tx_stat_gtufl_lo;
+	u32	tx_stat_gtufl_hi;
+	u32	tx_stat_gterr_lo;
+	u32	tx_stat_gterr_hi;
+	u32	tx_stat_gtbyt_lo;
+	u32	tx_stat_gtbyt_hi;
+
+	u32	rx_stat_gr64_lo;
+	u32	rx_stat_gr64_hi;
+	u32	rx_stat_gr127_lo;
+	u32	rx_stat_gr127_hi;
+	u32	rx_stat_gr255_lo;
+	u32	rx_stat_gr255_hi;
+	u32	rx_stat_gr511_lo;
+	u32	rx_stat_gr511_hi;
+	u32	rx_stat_gr1023_lo;
+	u32	rx_stat_gr1023_hi;
+	u32	rx_stat_gr1518_lo;
+	u32	rx_stat_gr1518_hi;
+	u32	rx_stat_gr2047_lo;
+	u32	rx_stat_gr2047_hi;
+	u32	rx_stat_gr4095_lo;
+	u32	rx_stat_gr4095_hi;
+	u32	rx_stat_gr9216_lo;
+	u32	rx_stat_gr9216_hi;
+	u32	rx_stat_gr16383_lo;
+	u32	rx_stat_gr16383_hi;
+	u32	rx_stat_grmax_lo;
+	u32	rx_stat_grmax_hi;
+	u32	rx_stat_grpkt_lo;
+	u32	rx_stat_grpkt_hi;
+	u32	rx_stat_grfcs_lo;
+	u32	rx_stat_grfcs_hi;
+	u32	rx_stat_gruca_lo;
+	u32	rx_stat_gruca_hi;
+	u32	rx_stat_grmca_lo;
+	u32	rx_stat_grmca_hi;
+	u32	rx_stat_grbca_lo;
+	u32	rx_stat_grbca_hi;
+	u32	rx_stat_grxpf_lo; /* grpf */
+	u32	rx_stat_grxpf_hi; /* grpf */
+	u32	rx_stat_grpp_lo;
+	u32	rx_stat_grpp_hi;
+	u32	rx_stat_grxuo_lo; /* gruo */
+	u32	rx_stat_grxuo_hi; /* gruo */
+	u32	rx_stat_grjbr_lo;
+	u32	rx_stat_grjbr_hi;
+	u32	rx_stat_grovr_lo;
+	u32	rx_stat_grovr_hi;
+	u32	rx_stat_grxcf_lo; /* grcf */
+	u32	rx_stat_grxcf_hi; /* grcf */
+	u32	rx_stat_grflr_lo;
+	u32	rx_stat_grflr_hi;
+	u32	rx_stat_grpok_lo;
+	u32	rx_stat_grpok_hi;
+	u32	rx_stat_grmeg_lo;
+	u32	rx_stat_grmeg_hi;
+	u32	rx_stat_grmeb_lo;
+	u32	rx_stat_grmeb_hi;
+	u32	rx_stat_grbyt_lo;
+	u32	rx_stat_grbyt_hi;
+	u32	rx_stat_grund_lo;
+	u32	rx_stat_grund_hi;
+	u32	rx_stat_grfrg_lo;
+	u32	rx_stat_grfrg_hi;
+	u32	rx_stat_grerb_lo; /* grerrbyt */
+	u32	rx_stat_grerb_hi; /* grerrbyt */
+	u32	rx_stat_grfre_lo; /* grfrerr */
+	u32	rx_stat_grfre_hi; /* grfrerr */
+	u32	rx_stat_gripj_lo;
+	u32	rx_stat_gripj_hi;
+};
 
 union mac_stats {
-	struct emac_stats	emac_stats;
-	struct bmac1_stats	bmac1_stats;
+	struct emac_stats	 emac_stats;
+	struct bmac1_stats	 bmac1_stats;
+	struct bmac2_stats	 bmac2_stats;
 };
 
 
@@ -1594,6 +1737,24 @@ union igu_consprod_reg {
 
 
 /*
+ * Control register for the IGU command register
+ */
+struct igu_ctrl_reg {
+	u32 ctrl_data;
+#define IGU_CTRL_REG_ADDRESS (0xFFF<<0)
+#define IGU_CTRL_REG_ADDRESS_SHIFT 0
+#define IGU_CTRL_REG_FID (0x7F<<12)
+#define IGU_CTRL_REG_FID_SHIFT 12
+#define IGU_CTRL_REG_RESERVED (0x1<<19)
+#define IGU_CTRL_REG_RESERVED_SHIFT 19
+#define IGU_CTRL_REG_TYPE (0x1<<20)
+#define IGU_CTRL_REG_TYPE_SHIFT 20
+#define IGU_CTRL_REG_UNUSED (0x7FF<<21)
+#define IGU_CTRL_REG_UNUSED_SHIFT 21
+};
+
+
+/*
  * Parser parsing flags field
  */
 struct parsing_flags {
@@ -1924,6 +2085,27 @@ struct eth_tx_parse_bd_e1x {
 };
 
 /*
+ * Tx parsing BD structure for ETH E2
+ */
+struct eth_tx_parse_bd_e2 {
+	__le16 dst_mac_addr_lo;
+	__le16 dst_mac_addr_mid;
+	__le16 dst_mac_addr_hi;
+	__le16 src_mac_addr_lo;
+	__le16 src_mac_addr_mid;
+	__le16 src_mac_addr_hi;
+	__le32 parsing_data;
+#define ETH_TX_PARSE_BD_E2_TCP_HDR_START_OFFSET_W (0x1FFF<<0)
+#define ETH_TX_PARSE_BD_E2_TCP_HDR_START_OFFSET_W_SHIFT 0
+#define ETH_TX_PARSE_BD_E2_TCP_HDR_LENGTH_DW (0xF<<13)
+#define ETH_TX_PARSE_BD_E2_TCP_HDR_LENGTH_DW_SHIFT 13
+#define ETH_TX_PARSE_BD_E2_LSO_MSS (0x3FFF<<17)
+#define ETH_TX_PARSE_BD_E2_LSO_MSS_SHIFT 17
+#define ETH_TX_PARSE_BD_E2_IPV6_WITH_EXT_HDR (0x1<<31)
+#define ETH_TX_PARSE_BD_E2_IPV6_WITH_EXT_HDR_SHIFT 31
+};
+
+/*
  * The last BD in the BD memory will hold a pointer to the next BD memory
  */
 struct eth_tx_next_bd {
@@ -1939,6 +2121,7 @@ union eth_tx_bd_types {
 	struct eth_tx_start_bd start_bd;
 	struct eth_tx_bd reg_bd;
 	struct eth_tx_parse_bd_e1x parse_bd_e1x;
+	struct eth_tx_parse_bd_e2 parse_bd_e2;
 	struct eth_tx_next_bd next_bd;
 };
 
diff --git a/drivers/net/bnx2x/bnx2x_init.h b/drivers/net/bnx2x/bnx2x_init.h
index 5ae22e0..a9d5487 100644
--- a/drivers/net/bnx2x/bnx2x_init.h
+++ b/drivers/net/bnx2x/bnx2x_init.h
@@ -97,6 +97,9 @@
 #define MISC_AEU_BLOCK		35
 #define PGLUE_B_BLOCK		36
 #define IGU_BLOCK		37
+#define ATC_BLOCK		38
+#define QM_4PORT_BLOCK		39
+#define XSEM_4PORT_BLOCK		40
 
 
 /* Returns the index of start or end of a specific block stage in ops array*/
diff --git a/drivers/net/bnx2x/bnx2x_init_ops.h b/drivers/net/bnx2x/bnx2x_init_ops.h
index aae7fea..e65de78 100644
--- a/drivers/net/bnx2x/bnx2x_init_ops.h
+++ b/drivers/net/bnx2x/bnx2x_init_ops.h
@@ -486,18 +486,30 @@ static void bnx2x_init_pxp_arb(struct bnx2x *bp, int r_order, int w_order)
 	REG_WR(bp, PXP2_REG_RQ_RD_MBS0, r_order);
 	REG_WR(bp, PXP2_REG_RQ_RD_MBS1, r_order);
 
-	if (r_order == MAX_RD_ORD)
+	if ((CHIP_IS_E1(bp) || CHIP_IS_E1H(bp)) && (r_order == MAX_RD_ORD))
 		REG_WR(bp, PXP2_REG_RQ_PDR_LIMIT, 0xe00);
 
-	REG_WR(bp, PXP2_REG_WR_USDMDP_TH, (0x18 << w_order));
+	if (CHIP_IS_E2(bp))
+		REG_WR(bp, PXP2_REG_WR_USDMDP_TH, (0x8 << w_order));
+	else
+		REG_WR(bp, PXP2_REG_WR_USDMDP_TH, (0x18 << w_order));
 
-	if (CHIP_IS_E1H(bp)) {
+	if (CHIP_IS_E1H(bp) || CHIP_IS_E2(bp)) {
 		/*    MPS      w_order     optimal TH      presently TH
 		 *    128         0             0               2
 		 *    256         1             1               3
 		 *    >=512       2             2               3
 		 */
-		val = ((w_order == 0) ? 2 : 3);
+		/* DMAE is special */
+		if (CHIP_IS_E2(bp)) {
+			/* E2 can use optimal TH */
+			val = w_order;
+			REG_WR(bp, PXP2_REG_WR_DMAE_MPS, val);
+		} else {
+			val = ((w_order == 0) ? 2 : 3);
+			REG_WR(bp, PXP2_REG_WR_DMAE_MPS, 2);
+		}
+
 		REG_WR(bp, PXP2_REG_WR_HC_MPS, val);
 		REG_WR(bp, PXP2_REG_WR_USDM_MPS, val);
 		REG_WR(bp, PXP2_REG_WR_CSDM_MPS, val);
@@ -507,9 +519,15 @@ static void bnx2x_init_pxp_arb(struct bnx2x *bp, int r_order, int w_order)
 		REG_WR(bp, PXP2_REG_WR_TM_MPS, val);
 		REG_WR(bp, PXP2_REG_WR_SRC_MPS, val);
 		REG_WR(bp, PXP2_REG_WR_DBG_MPS, val);
-		REG_WR(bp, PXP2_REG_WR_DMAE_MPS, 2); /* DMAE is special */
 		REG_WR(bp, PXP2_REG_WR_CDU_MPS, val);
 	}
+
+	/* Validate number of tags suppoted by device */
+#define PCIE_REG_PCIER_TL_HDR_FC_ST		0x2980
+	val = REG_RD(bp, PCIE_REG_PCIER_TL_HDR_FC_ST);
+	val &= 0xFF;
+	if (val <= 0x20)
+		REG_WR(bp, PXP2_REG_PGL_TAGS_LIMIT, 0x20);
 }
 
 /****************************************************************************
diff --git a/drivers/net/bnx2x/bnx2x_link.c b/drivers/net/bnx2x/bnx2x_link.c
index 51d468d..3e99bf9 100644
--- a/drivers/net/bnx2x/bnx2x_link.c
+++ b/drivers/net/bnx2x/bnx2x_link.c
@@ -377,9 +377,60 @@ static u8 bnx2x_emac_enable(struct link_params *params,
 	return 0;
 }
 
+static void bnx2x_update_bmac2(struct link_params *params,
+			       struct link_vars *vars,
+			       u8 is_lb)
+{
+	/*
+	 * Set rx control: Strip CRC and enable BigMAC to relay
+	 * control packets to the system as well
+	 */
+	u32 wb_data[2];
+	struct bnx2x *bp = params->bp;
+	u32 bmac_addr = params->port ? NIG_REG_INGRESS_BMAC1_MEM :
+		NIG_REG_INGRESS_BMAC0_MEM;
+	u32 val = 0x14;
 
+	if (vars->flow_ctrl & BNX2X_FLOW_CTRL_RX)
+		/* Enable BigMAC to react on received Pause packets */
+		val |= (1<<5);
+	wb_data[0] = val;
+	wb_data[1] = 0;
+	REG_WR_DMAE(bp, bmac_addr + BIGMAC2_REGISTER_RX_CONTROL,
+			wb_data, 2);
+	udelay(30);
 
-static u8 bnx2x_bmac_enable(struct link_params *params, struct link_vars *vars,
+	/* Tx control */
+	val = 0xc0;
+	if (vars->flow_ctrl & BNX2X_FLOW_CTRL_TX)
+		val |= 0x800000;
+	wb_data[0] = val;
+	wb_data[1] = 0;
+	REG_WR_DMAE(bp, bmac_addr + BIGMAC2_REGISTER_TX_CONTROL,
+			wb_data, 2);
+
+	val = 0x8000;
+	wb_data[0] = val;
+	wb_data[1] = 0;
+	REG_WR_DMAE(bp, bmac_addr + BIGMAC2_REGISTER_TX_PAUSE_CONTROL,
+			wb_data, 2);
+
+	/* mac control */
+	val = 0x3; /* Enable RX and TX */
+	if (is_lb) {
+		val |= 0x4; /* Local loopback */
+		DP(NETIF_MSG_LINK, "enable bmac loopback\n");
+	}
+
+	wb_data[0] = val;
+	wb_data[1] = 0;
+	REG_WR_DMAE(bp, bmac_addr + BIGMAC2_REGISTER_BMAC_CONTROL,
+			wb_data, 2);
+}
+
+
+static u8 bnx2x_bmac1_enable(struct link_params *params,
+			     struct link_vars *vars,
 			  u8 is_lb)
 {
 	struct bnx2x *bp = params->bp;
@@ -389,17 +440,7 @@ static u8 bnx2x_bmac_enable(struct link_params *params, struct link_vars *vars,
 	u32 wb_data[2];
 	u32 val;
 
-	DP(NETIF_MSG_LINK, "Enabling BigMAC\n");
-	/* reset and unreset the BigMac */
-	REG_WR(bp, GRCBASE_MISC + MISC_REGISTERS_RESET_REG_2_CLEAR,
-	       (MISC_REGISTERS_RESET_REG_2_RST_BMAC0 << port));
-	msleep(1);
-
-	REG_WR(bp, GRCBASE_MISC + MISC_REGISTERS_RESET_REG_2_SET,
-	       (MISC_REGISTERS_RESET_REG_2_RST_BMAC0 << port));
-
-	/* enable access for bmac registers */
-	REG_WR(bp, NIG_REG_BMAC0_REGS_OUT_EN + port*4, 0x1);
+	DP(NETIF_MSG_LINK, "Enabling BigMAC1\n");
 
 	/* XGXS control */
 	wb_data[0] = 0x3c;
@@ -479,6 +520,103 @@ static u8 bnx2x_bmac_enable(struct link_params *params, struct link_vars *vars,
 			    wb_data, 2);
 	}
 
+
+	return 0;
+}
+
+static u8 bnx2x_bmac2_enable(struct link_params *params,
+			     struct link_vars *vars,
+			     u8 is_lb)
+{
+	struct bnx2x *bp = params->bp;
+	u8 port = params->port;
+	u32 bmac_addr = port ? NIG_REG_INGRESS_BMAC1_MEM :
+			       NIG_REG_INGRESS_BMAC0_MEM;
+	u32 wb_data[2];
+
+	DP(NETIF_MSG_LINK, "Enabling BigMAC2\n");
+
+	wb_data[0] = 0;
+	wb_data[1] = 0;
+	REG_WR_DMAE(bp, bmac_addr + BIGMAC2_REGISTER_BMAC_CONTROL,
+			wb_data, 2);
+	udelay(30);
+
+	/* XGXS control: Reset phy HW, MDIO registers, PHY PLL and BMAC */
+	wb_data[0] = 0x3c;
+	wb_data[1] = 0;
+	REG_WR_DMAE(bp, bmac_addr +
+			BIGMAC2_REGISTER_BMAC_XGXS_CONTROL,
+			wb_data, 2);
+
+	udelay(30);
+
+	/* tx MAC SA */
+	wb_data[0] = ((params->mac_addr[2] << 24) |
+		       (params->mac_addr[3] << 16) |
+		       (params->mac_addr[4] << 8) |
+			params->mac_addr[5]);
+	wb_data[1] = ((params->mac_addr[0] << 8) |
+			params->mac_addr[1]);
+	REG_WR_DMAE(bp, bmac_addr + BIGMAC2_REGISTER_TX_SOURCE_ADDR,
+			wb_data, 2);
+
+	udelay(30);
+
+	/* Configure SAFC */
+	wb_data[0] = 0x1000200;
+	wb_data[1] = 0;
+	REG_WR_DMAE(bp, bmac_addr + BIGMAC2_REGISTER_RX_LLFC_MSG_FLDS,
+			wb_data, 2);
+	udelay(30);
+
+	/* set rx mtu */
+	wb_data[0] = ETH_MAX_JUMBO_PACKET_SIZE + ETH_OVREHEAD;
+	wb_data[1] = 0;
+	REG_WR_DMAE(bp, bmac_addr + BIGMAC2_REGISTER_RX_MAX_SIZE,
+			wb_data, 2);
+	udelay(30);
+
+	/* set tx mtu */
+	wb_data[0] = ETH_MAX_JUMBO_PACKET_SIZE + ETH_OVREHEAD;
+	wb_data[1] = 0;
+	REG_WR_DMAE(bp, bmac_addr + BIGMAC2_REGISTER_TX_MAX_SIZE,
+			wb_data, 2);
+	udelay(30);
+	/* set cnt max size */
+	wb_data[0] = ETH_MAX_JUMBO_PACKET_SIZE + ETH_OVREHEAD - 2;
+	wb_data[1] = 0;
+	REG_WR_DMAE(bp, bmac_addr + BIGMAC2_REGISTER_CNT_MAX_SIZE,
+			wb_data, 2);
+	udelay(30);
+	bnx2x_update_bmac2(params, vars, is_lb);
+
+	return 0;
+}
+
+u8 bnx2x_bmac_enable(struct link_params *params,
+			    struct link_vars *vars,
+			    u8 is_lb)
+{
+	u8 rc, port = params->port;
+	struct bnx2x *bp = params->bp;
+	u32 val;
+	/* reset and unreset the BigMac */
+	REG_WR(bp, GRCBASE_MISC + MISC_REGISTERS_RESET_REG_2_CLEAR,
+		     (MISC_REGISTERS_RESET_REG_2_RST_BMAC0 << port));
+	udelay(10);
+
+	REG_WR(bp, GRCBASE_MISC + MISC_REGISTERS_RESET_REG_2_SET,
+		     (MISC_REGISTERS_RESET_REG_2_RST_BMAC0 << port));
+
+	/* enable access for bmac registers */
+	REG_WR(bp, NIG_REG_BMAC0_REGS_OUT_EN + port*4, 0x1);
+
+	/* Enable BMAC according to BMAC type*/
+	if (CHIP_IS_E2(bp))
+		rc = bnx2x_bmac2_enable(params, vars, is_lb);
+	else
+		rc = bnx2x_bmac1_enable(params, vars, is_lb);
 	REG_WR(bp, NIG_REG_XGXS_SERDES0_MODE_SEL + port*4, 0x1);
 	REG_WR(bp, NIG_REG_XGXS_LANE_SEL_P0 + port*4, 0x0);
 	REG_WR(bp, NIG_REG_EGRESS_EMAC0_PORT + port*4, 0x0);
@@ -493,7 +631,7 @@ static u8 bnx2x_bmac_enable(struct link_params *params, struct link_vars *vars,
 	REG_WR(bp, NIG_REG_BMAC0_OUT_EN + port*4, 0x1);
 
 	vars->mac_type = MAC_TYPE_BMAC;
-	return 0;
+	return rc;
 }
 
 
@@ -519,13 +657,25 @@ static void bnx2x_bmac_rx_disable(struct bnx2x *bp, u8 port)
 			(MISC_REGISTERS_RESET_REG_2_RST_BMAC0 << port) &&
 	    nig_bmac_enable) {
 
-		/* Clear Rx Enable bit in BMAC_CONTROL register */
-		REG_RD_DMAE(bp, bmac_addr + BIGMAC_REGISTER_BMAC_CONTROL,
-			    wb_data, 2);
-		wb_data[0] &= ~BMAC_CONTROL_RX_ENABLE;
-		REG_WR_DMAE(bp, bmac_addr + BIGMAC_REGISTER_BMAC_CONTROL,
-			    wb_data, 2);
-
+		if (CHIP_IS_E2(bp)) {
+			/* Clear Rx Enable bit in BMAC_CONTROL register */
+			REG_RD_DMAE(bp, bmac_addr +
+					BIGMAC2_REGISTER_BMAC_CONTROL,
+					wb_data, 2);
+			wb_data[0] &= ~BMAC_CONTROL_RX_ENABLE;
+			REG_WR_DMAE(bp, bmac_addr +
+					BIGMAC2_REGISTER_BMAC_CONTROL,
+					wb_data, 2);
+		} else {
+			/* Clear Rx Enable bit in BMAC_CONTROL register */
+			REG_RD_DMAE(bp, bmac_addr +
+					BIGMAC_REGISTER_BMAC_CONTROL,
+					wb_data, 2);
+			wb_data[0] &= ~BMAC_CONTROL_RX_ENABLE;
+			REG_WR_DMAE(bp, bmac_addr +
+					BIGMAC_REGISTER_BMAC_CONTROL,
+					wb_data, 2);
+		}
 		msleep(1);
 	}
 }
@@ -821,23 +971,31 @@ u8 bnx2x_phy_write(struct link_params *params, u8 phy_addr,
 	return -EINVAL;
 }
 
-static void bnx2x_set_aer_mmd(struct link_params *params,
-			      struct bnx2x_phy *phy)
+static void bnx2x_set_aer_mmd_xgxs(struct link_params *params,
+				   struct bnx2x_phy *phy)
 {
-	struct bnx2x *bp = params->bp;
 	u32 ser_lane;
-	u16 offset;
-
+	u16 offset, aer_val;
+	struct bnx2x *bp = params->bp;
 	ser_lane = ((params->lane_config &
 		     PORT_HW_CFG_LANE_SWAP_CFG_MASTER_MASK) >>
 		     PORT_HW_CFG_LANE_SWAP_CFG_MASTER_SHIFT);
 
-	offset = (phy->type == PORT_HW_CFG_XGXS_EXT_PHY_TYPE_DIRECT) ?
-		(phy->addr + ser_lane) : 0;
-
+	offset = phy->addr + ser_lane;
+	if (CHIP_IS_E2(bp))
+		aer_val = 0x2800 + offset - 1;
+	else
+		aer_val = 0x3800 + offset;
 	CL45_WR_OVER_CL22(bp, phy,
-			      MDIO_REG_BANK_AER_BLOCK,
-			      MDIO_AER_BLOCK_AER_REG, 0x3800 + offset);
+				MDIO_REG_BANK_AER_BLOCK,
+				MDIO_AER_BLOCK_AER_REG, aer_val);
+}
+static void bnx2x_set_aer_mmd_serdes(struct bnx2x *bp,
+				     struct bnx2x_phy *phy)
+{
+	CL45_WR_OVER_CL22(bp, phy,
+				MDIO_REG_BANK_AER_BLOCK,
+				MDIO_AER_BLOCK_AER_REG, 0x3800);
 }
 
 /******************************************************************/
@@ -2046,12 +2204,12 @@ static u8 bnx2x_init_serdes(struct bnx2x_phy *phy,
 	u8 rc;
 	vars->phy_flags |= PHY_SGMII_FLAG;
 	bnx2x_calc_ieee_aneg_adv(phy, params, &vars->ieee_fc);
-	bnx2x_set_aer_mmd(params, phy);
+	bnx2x_set_aer_mmd_serdes(params->bp, phy);
 	rc = bnx2x_reset_unicore(params, phy, 1);
 	/* reset the SerDes and wait for reset bit return low */
 	if (rc != 0)
 		return rc;
-	bnx2x_set_aer_mmd(params, phy);
+	bnx2x_set_aer_mmd_serdes(params->bp, phy);
 
 	return rc;
 }
@@ -2076,7 +2234,7 @@ static u8 bnx2x_init_xgxs(struct bnx2x_phy *phy,
 		vars->phy_flags &= ~PHY_SGMII_FLAG;
 
 	bnx2x_calc_ieee_aneg_adv(phy, params, &vars->ieee_fc);
-	bnx2x_set_aer_mmd(params, phy);
+	bnx2x_set_aer_mmd_xgxs(params, phy);
 	bnx2x_set_master_ln(params, phy);
 
 	rc = bnx2x_reset_unicore(params, phy, 0);
@@ -2084,7 +2242,7 @@ static u8 bnx2x_init_xgxs(struct bnx2x_phy *phy,
 	if (rc != 0)
 		return rc;
 
-	bnx2x_set_aer_mmd(params, phy);
+	bnx2x_set_aer_mmd_xgxs(params, phy);
 
 	/* setting the masterLn_def again after the reset */
 	bnx2x_set_master_ln(params, phy);
@@ -2358,7 +2516,7 @@ static void bnx2x_set_xgxs_loopback(struct bnx2x_phy *phy,
 			       0x6041);
 		msleep(200);
 		/* set aer mmd back */
-		bnx2x_set_aer_mmd(params, phy);
+		bnx2x_set_aer_mmd_xgxs(params, phy);
 
 		/* and md_devad */
 		REG_WR(bp, NIG_REG_XGXS0_CTRL_MD_DEVAD + port*0x18,
@@ -2721,7 +2879,10 @@ static void bnx2x_common_ext_link_reset(struct bnx2x_phy *phy,
 	struct bnx2x *bp = params->bp;
 	u8 gpio_port;
 	/* HW reset */
-	gpio_port = params->port;
+	if (CHIP_IS_E2(bp))
+		gpio_port = BP_PATH(bp);
+	else
+		gpio_port = params->port;
 	bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_1,
 			    MISC_REGISTERS_GPIO_OUTPUT_LOW,
 			    gpio_port);
@@ -2799,8 +2960,9 @@ static u8 bnx2x_update_link_up(struct link_params *params,
 	}
 
 	/* PBF - link up */
-	rc |= bnx2x_pbf_update(params, vars->flow_ctrl,
-			      vars->line_speed);
+	if (!(CHIP_IS_E2(bp)))
+		rc |= bnx2x_pbf_update(params, vars->flow_ctrl,
+				       vars->line_speed);
 
 	/* disable drain */
 	REG_WR(bp, NIG_REG_EGRESS_DRAIN0_MODE + port*4, 0);
@@ -3443,7 +3605,10 @@ static u8 bnx2x_8073_config_init(struct bnx2x_phy *phy,
 	u8 gpio_port;
 	DP(NETIF_MSG_LINK, "Init 8073\n");
 
-	gpio_port = params->port;
+	if (CHIP_IS_E2(bp))
+		gpio_port = BP_PATH(bp);
+	else
+		gpio_port = params->port;
 	/* Restore normal power mode*/
 	bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_2,
 			    MISC_REGISTERS_GPIO_OUTPUT_HIGH, gpio_port);
@@ -3680,7 +3845,10 @@ static void bnx2x_8073_link_reset(struct bnx2x_phy *phy,
 {
 	struct bnx2x *bp = params->bp;
 	u8 gpio_port;
-	gpio_port = params->port;
+	if (CHIP_IS_E2(bp))
+		gpio_port = BP_PATH(bp);
+	else
+		gpio_port = params->port;
 	DP(NETIF_MSG_LINK, "Setting 8073 port %d into low power mode\n",
 	   gpio_port);
 	bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_2,
@@ -6371,7 +6539,10 @@ static u8 bnx2x_populate_int_phy(struct bnx2x *bp, u32 shmem_base, u8 port,
 	phy->mdio_ctrl = bnx2x_get_emac_base(bp,
 					    SHARED_HW_CFG_MDC_MDIO_ACCESS1_BOTH,
 					    port);
-	phy->def_md_devad = DEFAULT_PHY_DEV_ADDR;
+	if (CHIP_IS_E2(bp))
+		phy->def_md_devad = E2_DEFAULT_PHY_DEV_ADDR;
+	else
+		phy->def_md_devad = DEFAULT_PHY_DEV_ADDR;
 
 	DP(NETIF_MSG_LINK, "Internal phy port=%d, addr=0x%x, mdio_ctl=0x%x\n",
 		   port, phy->addr, phy->mdio_ctrl);
@@ -6742,7 +6913,9 @@ u8 bnx2x_phy_init(struct link_params *params, struct link_vars *vars)
 		}
 
 		bnx2x_emac_enable(params, vars, 0);
-		bnx2x_pbf_update(params, vars->flow_ctrl, vars->line_speed);
+		if (!(CHIP_IS_E2(bp)))
+			bnx2x_pbf_update(params, vars->flow_ctrl,
+					 vars->line_speed);
 		/* disable drain */
 		REG_WR(bp, NIG_REG_EGRESS_DRAIN0_MODE + params->port*4, 0);
 
@@ -6932,18 +7105,34 @@ u8 bnx2x_link_reset(struct link_params *params, struct link_vars *vars,
 /****************************************************************************/
 /*				Common function				    */
 /****************************************************************************/
-static u8 bnx2x_8073_common_init_phy(struct bnx2x *bp, u32 shmem_base, u32 shmem2_base, u8 phy_index)
+static u8 bnx2x_8073_common_init_phy(struct bnx2x *bp,
+				     u32 shmem_base_path[],
+				     u32 shmem2_base_path[], u8 phy_index,
+				     u32 chip_id)
 {
 	struct bnx2x_phy phy[PORT_MAX];
 	struct bnx2x_phy *phy_blk[PORT_MAX];
 	u16 val;
 	s8 port;
+	s8 port_of_path = 0;
 
 	/* PART1 - Reset both phys */
 	for (port = PORT_MAX - 1; port >= PORT_0; port--) {
+		u32 shmem_base, shmem2_base;
+		/* In E2, same phy is using for port0 of the two paths */
+		if (CHIP_IS_E2(bp)) {
+			shmem_base = shmem_base_path[port];
+			shmem2_base = shmem2_base_path[port];
+			port_of_path = 0;
+		} else {
+			shmem_base = shmem_base_path[0];
+			shmem2_base = shmem2_base_path[0];
+			port_of_path = port;
+		}
+
 		/* Extract the ext phy address for the port */
 		if (bnx2x_populate_phy(bp, phy_index, shmem_base, shmem2_base,
-				       port, &phy[port]) !=
+				       port_of_path, &phy[port]) !=
 		    0) {
 			DP(NETIF_MSG_LINK, "populate_phy failed\n");
 			return -EINVAL;
@@ -6981,9 +7170,15 @@ static u8 bnx2x_8073_common_init_phy(struct bnx2x *bp, u32 shmem_base, u32 shmem
 	/* PART2 - Download firmware to both phys */
 	for (port = PORT_MAX - 1; port >= PORT_0; port--) {
 		u16 fw_ver1;
+		if (CHIP_IS_E2(bp))
+			port_of_path = 0;
+		else
+			port_of_path = port;
 
+		DP(NETIF_MSG_LINK, "Loading spirom for phy address 0x%x\n",
+			   phy_blk[port]->addr);
 		bnx2x_8073_8727_external_rom_boot(bp, phy_blk[port],
-						  port);
+						  port_of_path);
 
 		bnx2x_cl45_read(bp, phy_blk[port],
 			      MDIO_PMA_DEVAD,
@@ -7039,9 +7234,10 @@ static u8 bnx2x_8073_common_init_phy(struct bnx2x *bp, u32 shmem_base, u32 shmem
 	}
 	return 0;
 }
-
-static u8 bnx2x_8726_common_init_phy(struct bnx2x *bp, u32 shmem_base,
-				     u32 shmem2_base, u8 phy_index)
+static u8 bnx2x_8726_common_init_phy(struct bnx2x *bp,
+				     u32 shmem_base_path[],
+				     u32 shmem2_base_path[], u8 phy_index,
+				     u32 chip_id)
 {
 	u32 val;
 	s8 port;
@@ -7056,6 +7252,16 @@ static u8 bnx2x_8726_common_init_phy(struct bnx2x *bp, u32 shmem_base,
 	bnx2x_ext_phy_hw_reset(bp, 1);
 	msleep(5);
 	for (port = 0; port < PORT_MAX; port++) {
+		u32 shmem_base, shmem2_base;
+
+		/* In E2, same phy is using for port0 of the two paths */
+		if (CHIP_IS_E2(bp)) {
+			shmem_base = shmem_base_path[port];
+			shmem2_base = shmem2_base_path[port];
+		} else {
+			shmem_base = shmem_base_path[0];
+			shmem2_base = shmem2_base_path[0];
+		}
 		/* Extract the ext phy address for the port */
 		if (bnx2x_populate_phy(bp, phy_index, shmem_base, shmem2_base,
 				       port, &phy) !=
@@ -7077,14 +7283,16 @@ static u8 bnx2x_8726_common_init_phy(struct bnx2x *bp, u32 shmem_base,
 
 	return 0;
 }
-static u8 bnx2x_8727_common_init_phy(struct bnx2x *bp, u32 shmem_base,
-				     u32 shmem2_base, u8 phy_index)
+static u8 bnx2x_8727_common_init_phy(struct bnx2x *bp,
+				     u32 shmem_base_path[],
+				     u32 shmem2_base_path[], u8 phy_index,
+				     u32 chip_id)
 {
 	s8 port;
 	u32 swap_val, swap_override;
 	struct bnx2x_phy phy[PORT_MAX];
 	struct bnx2x_phy *phy_blk[PORT_MAX];
-	DP(NETIF_MSG_LINK, "Executing BCM8727 common init\n");
+	s8 port_of_path;
 	swap_val = REG_RD(bp,  NIG_REG_PORT_SWAP);
 	swap_override = REG_RD(bp,  NIG_REG_STRAP_OVERRIDE);
 
@@ -7099,19 +7307,33 @@ static u8 bnx2x_8727_common_init_phy(struct bnx2x *bp, u32 shmem_base,
 
 	/* PART1 - Reset both phys */
 	for (port = PORT_MAX - 1; port >= PORT_0; port--) {
+		u32 shmem_base, shmem2_base;
+
+		/* In E2, same phy is using for port0 of the two paths */
+		if (CHIP_IS_E2(bp)) {
+			shmem_base = shmem_base_path[port];
+			shmem2_base = shmem2_base_path[port];
+			port_of_path = 0;
+		} else {
+			shmem_base = shmem_base_path[0];
+			shmem2_base = shmem2_base_path[0];
+			port_of_path = port;
+		}
+
 		/* Extract the ext phy address for the port */
 		if (bnx2x_populate_phy(bp, phy_index, shmem_base, shmem2_base,
-				       port, &phy[port]) !=
+				       port_of_path, &phy[port]) !=
 				       0) {
 			DP(NETIF_MSG_LINK, "populate phy failed\n");
 			return -EINVAL;
 		}
 		/* disable attentions */
-		bnx2x_bits_dis(bp, NIG_REG_MASK_INTERRUPT_PORT0 + port*4,
-			     (NIG_MASK_XGXS0_LINK_STATUS |
-			      NIG_MASK_XGXS0_LINK10G |
-			      NIG_MASK_SERDES0_LINK_STATUS |
-			      NIG_MASK_MI_INT));
+		bnx2x_bits_dis(bp, NIG_REG_MASK_INTERRUPT_PORT0 +
+			       port_of_path*4,
+			       (NIG_MASK_XGXS0_LINK_STATUS |
+				NIG_MASK_XGXS0_LINK10G |
+				NIG_MASK_SERDES0_LINK_STATUS |
+				NIG_MASK_MI_INT));
 
 
 		/* Reset the phy */
@@ -7133,9 +7355,14 @@ static u8 bnx2x_8727_common_init_phy(struct bnx2x *bp, u32 shmem_base,
 	/* PART2 - Download firmware to both phys */
 	for (port = PORT_MAX - 1; port >= PORT_0; port--) {
 		u16 fw_ver1;
-
+		 if (CHIP_IS_E2(bp))
+			port_of_path = 0;
+		else
+			port_of_path = port;
+		DP(NETIF_MSG_LINK, "Loading spirom for phy address 0x%x\n",
+			   phy_blk[port]->addr);
 		bnx2x_8073_8727_external_rom_boot(bp, phy_blk[port],
-						  port);
+						  port_of_path);
 		bnx2x_cl45_read(bp, phy_blk[port],
 			      MDIO_PMA_DEVAD,
 			      MDIO_PMA_REG_ROM_VER1, &fw_ver1);
@@ -7151,29 +7378,32 @@ static u8 bnx2x_8727_common_init_phy(struct bnx2x *bp, u32 shmem_base,
 	return 0;
 }
 
-static u8 bnx2x_ext_phy_common_init(struct bnx2x *bp, u32 shmem_base,
-				    u32 shmem2_base, u8 phy_index,
-				    u32 ext_phy_type)
+static u8 bnx2x_ext_phy_common_init(struct bnx2x *bp, u32 shmem_base_path[],
+				    u32 shmem2_base_path[], u8 phy_index,
+				    u32 ext_phy_type, u32 chip_id)
 {
 	u8 rc = 0;
 
 	switch (ext_phy_type) {
 	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8073:
-		rc = bnx2x_8073_common_init_phy(bp, shmem_base,
-						shmem2_base, phy_index);
+		rc = bnx2x_8073_common_init_phy(bp, shmem_base_path,
+						shmem2_base_path,
+						phy_index, chip_id);
 		break;
 
 	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8727:
 	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8727_NOC:
-		rc = bnx2x_8727_common_init_phy(bp, shmem_base,
-						shmem2_base, phy_index);
+		rc = bnx2x_8727_common_init_phy(bp, shmem_base_path,
+						shmem2_base_path,
+						phy_index, chip_id);
 		break;
 
 	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8726:
 		/* GPIO1 affects both ports, so there's need to pull
 		it for single port alone */
-		rc = bnx2x_8726_common_init_phy(bp, shmem_base,
-						shmem2_base, phy_index);
+		rc = bnx2x_8726_common_init_phy(bp, shmem_base_path,
+						shmem2_base_path,
+						phy_index, chip_id);
 		break;
 	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_FAILURE:
 		rc = -EINVAL;
@@ -7188,8 +7418,8 @@ static u8 bnx2x_ext_phy_common_init(struct bnx2x *bp, u32 shmem_base,
 	return rc;
 }
 
-u8 bnx2x_common_init_phy(struct bnx2x *bp, u32 shmem_base,
-			 u32 shmem2_base)
+u8 bnx2x_common_init_phy(struct bnx2x *bp, u32 shmem_base_path[],
+			 u32 shmem2_base_path[], u32 chip_id)
 {
 	u8 rc = 0;
 	u8 phy_index;
@@ -7203,12 +7433,13 @@ u8 bnx2x_common_init_phy(struct bnx2x *bp, u32 shmem_base,
 	for (phy_index = EXT_PHY1; phy_index < MAX_PHYS;
 	      phy_index++) {
 		ext_phy_config = bnx2x_get_ext_phy_config(bp,
-							  shmem_base,
+							  shmem_base_path[0],
 							  phy_index, 0);
 		ext_phy_type = XGXS_EXT_PHY_TYPE(ext_phy_config);
-		rc |= bnx2x_ext_phy_common_init(bp, shmem_base,
-						shmem2_base,
-						phy_index, ext_phy_type);
+		rc |= bnx2x_ext_phy_common_init(bp, shmem_base_path,
+						shmem2_base_path,
+						phy_index, ext_phy_type,
+						chip_id);
 	}
 	return rc;
 }
diff --git a/drivers/net/bnx2x/bnx2x_link.h b/drivers/net/bnx2x/bnx2x_link.h
index e98ea3d..58a4c71 100644
--- a/drivers/net/bnx2x/bnx2x_link.h
+++ b/drivers/net/bnx2x/bnx2x_link.h
@@ -22,7 +22,8 @@
 /***********************************************************/
 /*                         Defines                         */
 /***********************************************************/
-#define DEFAULT_PHY_DEV_ADDR 3
+#define DEFAULT_PHY_DEV_ADDR	3
+#define E2_DEFAULT_PHY_DEV_ADDR	5
 
 
 
@@ -315,7 +316,8 @@ u8 bnx2x_test_link(struct link_params *input, struct link_vars *vars,
 		   u8 is_serdes);
 
 /* One-time initialization for external phy after power up */
-u8 bnx2x_common_init_phy(struct bnx2x *bp, u32 shmem_base, u32 shmem2_base);
+u8 bnx2x_common_init_phy(struct bnx2x *bp, u32 shmem_base_path[],
+			 u32 shmem2_base_path[], u32 chip_id);
 
 /* Reset the external PHY using GPIO */
 void bnx2x_ext_phy_hw_reset(struct bnx2x *bp, u8 port);
diff --git a/drivers/net/bnx2x/bnx2x_main.c b/drivers/net/bnx2x/bnx2x_main.c
index 2c04b97..0ac416a 100644
--- a/drivers/net/bnx2x/bnx2x_main.c
+++ b/drivers/net/bnx2x/bnx2x_main.c
@@ -23,7 +23,6 @@
 #include <linux/errno.h>
 #include <linux/ioport.h>
 #include <linux/slab.h>
-#include <linux/vmalloc.h>
 #include <linux/interrupt.h>
 #include <linux/pci.h>
 #include <linux/init.h>
@@ -68,6 +67,7 @@
 	__stringify(BCM_5710_FW_ENGINEERING_VERSION)
 #define FW_FILE_NAME_E1		"bnx2x/bnx2x-e1-" FW_FILE_VERSION ".fw"
 #define FW_FILE_NAME_E1H	"bnx2x/bnx2x-e1h-" FW_FILE_VERSION ".fw"
+#define FW_FILE_NAME_E2		"bnx2x/bnx2x-e2-" FW_FILE_VERSION ".fw"
 
 /* Time in jiffies before concluding the transmitter is hung */
 #define TX_TIMEOUT		(5*HZ)
@@ -77,11 +77,13 @@ static char version[] __devinitdata =
 	DRV_MODULE_NAME " " DRV_MODULE_VERSION " (" DRV_MODULE_RELDATE ")\n";
 
 MODULE_AUTHOR("Eliezer Tamir");
-MODULE_DESCRIPTION("Broadcom NetXtreme II BCM57710/57711/57711E Driver");
+MODULE_DESCRIPTION("Broadcom NetXtreme II "
+		   "BCM57710/57711/57711E/57712/57712E Driver");
 MODULE_LICENSE("GPL");
 MODULE_VERSION(DRV_MODULE_VERSION);
 MODULE_FIRMWARE(FW_FILE_NAME_E1);
 MODULE_FIRMWARE(FW_FILE_NAME_E1H);
+MODULE_FIRMWARE(FW_FILE_NAME_E2);
 
 static int multi_mode = 1;
 module_param(multi_mode, int, 0);
@@ -124,6 +126,8 @@ enum bnx2x_board_type {
 	BCM57710 = 0,
 	BCM57711 = 1,
 	BCM57711E = 2,
+	BCM57712 = 3,
+	BCM57712E = 4
 };
 
 /* indexed by board_type, above */
@@ -132,14 +136,24 @@ static struct {
 } board_info[] __devinitdata = {
 	{ "Broadcom NetXtreme II BCM57710 XGb" },
 	{ "Broadcom NetXtreme II BCM57711 XGb" },
-	{ "Broadcom NetXtreme II BCM57711E XGb" }
+	{ "Broadcom NetXtreme II BCM57711E XGb" },
+	{ "Broadcom NetXtreme II BCM57712 XGb" },
+	{ "Broadcom NetXtreme II BCM57712E XGb" }
 };
 
+#ifndef PCI_DEVICE_ID_NX2_57712
+#define PCI_DEVICE_ID_NX2_57712		0x1662
+#endif
+#ifndef PCI_DEVICE_ID_NX2_57712E
+#define PCI_DEVICE_ID_NX2_57712E	0x1663
+#endif
 
 static DEFINE_PCI_DEVICE_TABLE(bnx2x_pci_tbl) = {
 	{ PCI_VDEVICE(BROADCOM, PCI_DEVICE_ID_NX2_57710), BCM57710 },
 	{ PCI_VDEVICE(BROADCOM, PCI_DEVICE_ID_NX2_57711), BCM57711 },
 	{ PCI_VDEVICE(BROADCOM, PCI_DEVICE_ID_NX2_57711E), BCM57711E },
+	{ PCI_VDEVICE(BROADCOM, PCI_DEVICE_ID_NX2_57712), BCM57712 },
+	{ PCI_VDEVICE(BROADCOM, PCI_DEVICE_ID_NX2_57712E), BCM57712E },
 	{ 0 }
 };
 
@@ -353,7 +367,8 @@ static inline void storm_memset_hc_timeout(struct bnx2x *bp, u8 port,
 					     u8 ticks)
 {
 
-	int index_offset =
+	int index_offset = CHIP_IS_E2(bp) ?
+		offsetof(struct hc_status_block_data_e2, index_data) :
 		offsetof(struct hc_status_block_data_e1x, index_data);
 	u32 addr = BAR_CSTRORM_INTMEM +
 			CSTORM_STATUS_BLOCK_DATA_OFFSET(fw_sb_id) +
@@ -369,7 +384,8 @@ static inline void storm_memset_hc_disable(struct bnx2x *bp, u8 port,
 					     u8 disable)
 {
 	u32 enable_flag = disable ? 0 : (1 << HC_INDEX_DATA_HC_ENABLED_SHIFT);
-	int index_offset =
+	int index_offset = CHIP_IS_E2(bp) ?
+		offsetof(struct hc_status_block_data_e2, index_data) :
 		offsetof(struct hc_status_block_data_e1x, index_data);
 	u32 addr = BAR_CSTRORM_INTMEM +
 			CSTORM_STATUS_BLOCK_DATA_OFFSET(fw_sb_id) +
@@ -408,6 +424,75 @@ static u32 bnx2x_reg_rd_ind(struct bnx2x *bp, u32 addr)
 	return val;
 }
 
+#define DMAE_DP_SRC_GRC		"grc src_addr [%08x]"
+#define DMAE_DP_SRC_PCI		"pci src_addr [%x:%08x]"
+#define DMAE_DP_DST_GRC		"grc dst_addr [%08x]"
+#define DMAE_DP_DST_PCI		"pci dst_addr [%x:%08x]"
+#define DMAE_DP_DST_NONE	"dst_addr [none]"
+
+void bnx2x_dp_dmae(struct bnx2x *bp, struct dmae_command *dmae, int msglvl)
+{
+	u32 src_type = dmae->opcode & DMAE_COMMAND_SRC;
+
+	switch (dmae->opcode & DMAE_COMMAND_DST) {
+	case DMAE_CMD_DST_PCI:
+		if (src_type == DMAE_CMD_SRC_PCI)
+			DP(msglvl, "DMAE: opcode 0x%08x\n"
+			   "src [%x:%08x], len [%d*4], dst [%x:%08x]\n"
+			   "comp_addr [%x:%08x], comp_val 0x%08x\n",
+			   dmae->opcode, dmae->src_addr_hi, dmae->src_addr_lo,
+			   dmae->len, dmae->dst_addr_hi, dmae->dst_addr_lo,
+			   dmae->comp_addr_hi, dmae->comp_addr_lo,
+			   dmae->comp_val);
+		else
+			DP(msglvl, "DMAE: opcode 0x%08x\n"
+			   "src [%08x], len [%d*4], dst [%x:%08x]\n"
+			   "comp_addr [%x:%08x], comp_val 0x%08x\n",
+			   dmae->opcode, dmae->src_addr_lo >> 2,
+			   dmae->len, dmae->dst_addr_hi, dmae->dst_addr_lo,
+			   dmae->comp_addr_hi, dmae->comp_addr_lo,
+			   dmae->comp_val);
+		break;
+	case DMAE_CMD_DST_GRC:
+		if (src_type == DMAE_CMD_SRC_PCI)
+			DP(msglvl, "DMAE: opcode 0x%08x\n"
+			   "src [%x:%08x], len [%d*4], dst_addr [%08x]\n"
+			   "comp_addr [%x:%08x], comp_val 0x%08x\n",
+			   dmae->opcode, dmae->src_addr_hi, dmae->src_addr_lo,
+			   dmae->len, dmae->dst_addr_lo >> 2,
+			   dmae->comp_addr_hi, dmae->comp_addr_lo,
+			   dmae->comp_val);
+		else
+			DP(msglvl, "DMAE: opcode 0x%08x\n"
+			   "src [%08x], len [%d*4], dst [%08x]\n"
+			   "comp_addr [%x:%08x], comp_val 0x%08x\n",
+			   dmae->opcode, dmae->src_addr_lo >> 2,
+			   dmae->len, dmae->dst_addr_lo >> 2,
+			   dmae->comp_addr_hi, dmae->comp_addr_lo,
+			   dmae->comp_val);
+		break;
+	default:
+		if (src_type == DMAE_CMD_SRC_PCI)
+			DP(msglvl, "DMAE: opcode 0x%08x\n"
+			   DP_LEVEL "src_addr [%x:%08x]  len [%d * 4]  "
+				    "dst_addr [none]\n"
+			   DP_LEVEL "comp_addr [%x:%08x]  comp_val 0x%08x\n",
+			   dmae->opcode, dmae->src_addr_hi, dmae->src_addr_lo,
+			   dmae->len, dmae->comp_addr_hi, dmae->comp_addr_lo,
+			   dmae->comp_val);
+		else
+			DP(msglvl, "DMAE: opcode 0x%08x\n"
+			   DP_LEVEL "src_addr [%08x]  len [%d * 4]  "
+				    "dst_addr [none]\n"
+			   DP_LEVEL "comp_addr [%x:%08x]  comp_val 0x%08x\n",
+			   dmae->opcode, dmae->src_addr_lo >> 2,
+			   dmae->len, dmae->comp_addr_hi, dmae->comp_addr_lo,
+			   dmae->comp_val);
+		break;
+	}
+
+}
+
 const u32 dmae_reg_go_c[] = {
 	DMAE_REG_GO_C0, DMAE_REG_GO_C1, DMAE_REG_GO_C2, DMAE_REG_GO_C3,
 	DMAE_REG_GO_C4, DMAE_REG_GO_C5, DMAE_REG_GO_C6, DMAE_REG_GO_C7,
@@ -431,85 +516,137 @@ void bnx2x_post_dmae(struct bnx2x *bp, struct dmae_command *dmae, int idx)
 	REG_WR(bp, dmae_reg_go_c[idx], 1);
 }
 
-void bnx2x_write_dmae(struct bnx2x *bp, dma_addr_t dma_addr, u32 dst_addr,
-		      u32 len32)
+u32 bnx2x_dmae_opcode_add_comp(u32 opcode, u8 comp_type)
 {
-	struct dmae_command dmae;
-	u32 *wb_comp = bnx2x_sp(bp, wb_comp);
-	int cnt = 200;
+	return opcode | ((comp_type << DMAE_COMMAND_C_DST_SHIFT) |
+			   DMAE_CMD_C_ENABLE);
+}
 
-	if (!bp->dmae_ready) {
-		u32 *data = bnx2x_sp(bp, wb_data[0]);
+u32 bnx2x_dmae_opcode_clr_src_reset(u32 opcode)
+{
+	return opcode & ~DMAE_CMD_SRC_RESET;
+}
 
-		DP(BNX2X_MSG_OFF, "DMAE is not ready (dst_addr %08x  len32 %d)"
-		   "  using indirect\n", dst_addr, len32);
-		bnx2x_init_ind_wr(bp, dst_addr, data, len32);
-		return;
-	}
+u32 bnx2x_dmae_opcode(struct bnx2x *bp, u8 src_type, u8 dst_type,
+			     bool with_comp, u8 comp_type)
+{
+	u32 opcode = 0;
+
+	opcode |= ((src_type << DMAE_COMMAND_SRC_SHIFT) |
+		   (dst_type << DMAE_COMMAND_DST_SHIFT));
 
-	memset(&dmae, 0, sizeof(struct dmae_command));
+	opcode |= (DMAE_CMD_SRC_RESET | DMAE_CMD_DST_RESET);
+
+	opcode |= (BP_PORT(bp) ? DMAE_CMD_PORT_1 : DMAE_CMD_PORT_0);
+	opcode |= ((BP_E1HVN(bp) << DMAE_CMD_E1HVN_SHIFT) |
+		   (BP_E1HVN(bp) << DMAE_COMMAND_DST_VN_SHIFT));
+	opcode |= (DMAE_COM_SET_ERR << DMAE_COMMAND_ERR_POLICY_SHIFT);
 
-	dmae.opcode = (DMAE_CMD_SRC_PCI | DMAE_CMD_DST_GRC |
-		       DMAE_CMD_C_DST_PCI | DMAE_CMD_C_ENABLE |
-		       DMAE_CMD_SRC_RESET | DMAE_CMD_DST_RESET |
 #ifdef __BIG_ENDIAN
-		       DMAE_CMD_ENDIANITY_B_DW_SWAP |
+	opcode |= DMAE_CMD_ENDIANITY_B_DW_SWAP;
 #else
-		       DMAE_CMD_ENDIANITY_DW_SWAP |
+	opcode |= DMAE_CMD_ENDIANITY_DW_SWAP;
 #endif
-		       (BP_PORT(bp) ? DMAE_CMD_PORT_1 : DMAE_CMD_PORT_0) |
-		       (BP_E1HVN(bp) << DMAE_CMD_E1HVN_SHIFT));
-	dmae.src_addr_lo = U64_LO(dma_addr);
-	dmae.src_addr_hi = U64_HI(dma_addr);
-	dmae.dst_addr_lo = dst_addr >> 2;
-	dmae.dst_addr_hi = 0;
-	dmae.len = len32;
-	dmae.comp_addr_lo = U64_LO(bnx2x_sp_mapping(bp, wb_comp));
-	dmae.comp_addr_hi = U64_HI(bnx2x_sp_mapping(bp, wb_comp));
-	dmae.comp_val = DMAE_COMP_VAL;
-
-	DP(BNX2X_MSG_OFF, "DMAE: opcode 0x%08x\n"
-	   DP_LEVEL "src_addr  [%x:%08x]  len [%d *4]  "
-		    "dst_addr [%x:%08x (%08x)]\n"
-	   DP_LEVEL "comp_addr [%x:%08x]  comp_val 0x%08x\n",
-	   dmae.opcode, dmae.src_addr_hi, dmae.src_addr_lo,
-	   dmae.len, dmae.dst_addr_hi, dmae.dst_addr_lo, dst_addr,
-	   dmae.comp_addr_hi, dmae.comp_addr_lo, dmae.comp_val);
-	DP(BNX2X_MSG_OFF, "data [0x%08x 0x%08x 0x%08x 0x%08x]\n",
+	if (with_comp)
+		opcode = bnx2x_dmae_opcode_add_comp(opcode, comp_type);
+	return opcode;
+}
+
+void bnx2x_prep_dmae_with_comp(struct bnx2x *bp, struct dmae_command *dmae,
+			       u8 src_type, u8 dst_type)
+{
+	memset(dmae, 0, sizeof(struct dmae_command));
+
+	/* set the opcode */
+	dmae->opcode = bnx2x_dmae_opcode(bp, src_type, dst_type,
+					 true, DMAE_COMP_PCI);
+
+	/* fill in the completion parameters */
+	dmae->comp_addr_lo = U64_LO(bnx2x_sp_mapping(bp, wb_comp));
+	dmae->comp_addr_hi = U64_HI(bnx2x_sp_mapping(bp, wb_comp));
+	dmae->comp_val = DMAE_COMP_VAL;
+}
+
+/* issue a dmae command over the init-channel and wailt for completion */
+int bnx2x_issue_dmae_with_comp(struct bnx2x *bp, struct dmae_command *dmae)
+{
+	u32 *wb_comp = bnx2x_sp(bp, wb_comp);
+	int cnt = CHIP_REV_IS_SLOW(bp) ? (400000) : 40;
+	int rc = 0;
+
+	DP(BNX2X_MSG_OFF, "data before [0x%08x 0x%08x 0x%08x 0x%08x]\n",
 	   bp->slowpath->wb_data[0], bp->slowpath->wb_data[1],
 	   bp->slowpath->wb_data[2], bp->slowpath->wb_data[3]);
 
+	/* lock the dmae channel */
 	mutex_lock(&bp->dmae_mutex);
 
+	/* reset completion */
 	*wb_comp = 0;
 
-	bnx2x_post_dmae(bp, &dmae, INIT_DMAE_C(bp));
+	/* post the command on the channel used for initializations */
+	bnx2x_post_dmae(bp, dmae, INIT_DMAE_C(bp));
 
+	/* wait for completion */
 	udelay(5);
-
-	while (*wb_comp != DMAE_COMP_VAL) {
+	while ((*wb_comp & ~DMAE_PCI_ERR_FLAG) != DMAE_COMP_VAL) {
 		DP(BNX2X_MSG_OFF, "wb_comp 0x%08x\n", *wb_comp);
 
 		if (!cnt) {
 			BNX2X_ERR("DMAE timeout!\n");
-			break;
+			rc = DMAE_TIMEOUT;
+			goto unlock;
 		}
 		cnt--;
-		/* adjust delay for emulation/FPGA */
-		if (CHIP_REV_IS_SLOW(bp))
-			msleep(100);
-		else
-			udelay(5);
+		udelay(50);
 	}
+	if (*wb_comp & DMAE_PCI_ERR_FLAG) {
+		BNX2X_ERR("DMAE PCI error!\n");
+		rc = DMAE_PCI_ERROR;
+	}
+
+	DP(BNX2X_MSG_OFF, "data after [0x%08x 0x%08x 0x%08x 0x%08x]\n",
+	   bp->slowpath->wb_data[0], bp->slowpath->wb_data[1],
+	   bp->slowpath->wb_data[2], bp->slowpath->wb_data[3]);
 
+unlock:
 	mutex_unlock(&bp->dmae_mutex);
+	return rc;
+}
+
+void bnx2x_write_dmae(struct bnx2x *bp, dma_addr_t dma_addr, u32 dst_addr,
+		      u32 len32)
+{
+	struct dmae_command dmae;
+
+	if (!bp->dmae_ready) {
+		u32 *data = bnx2x_sp(bp, wb_data[0]);
+
+		DP(BNX2X_MSG_OFF, "DMAE is not ready (dst_addr %08x  len32 %d)"
+		   "  using indirect\n", dst_addr, len32);
+		bnx2x_init_ind_wr(bp, dst_addr, data, len32);
+		return;
+	}
+
+	/* set opcode and fixed command fields */
+	bnx2x_prep_dmae_with_comp(bp, &dmae, DMAE_SRC_PCI, DMAE_DST_GRC);
+
+	/* fill in addresses and len */
+	dmae.src_addr_lo = U64_LO(dma_addr);
+	dmae.src_addr_hi = U64_HI(dma_addr);
+	dmae.dst_addr_lo = dst_addr >> 2;
+	dmae.dst_addr_hi = 0;
+	dmae.len = len32;
+
+	bnx2x_dp_dmae(bp, &dmae, BNX2X_MSG_OFF);
+
+	/* issue the command and wait for completion */
+	bnx2x_issue_dmae_with_comp(bp, &dmae);
 }
 
 void bnx2x_read_dmae(struct bnx2x *bp, u32 src_addr, u32 len32)
 {
 	struct dmae_command dmae;
-	u32 *wb_comp = bnx2x_sp(bp, wb_comp);
-	int cnt = 200;
 
 	if (!bp->dmae_ready) {
 		u32 *data = bnx2x_sp(bp, wb_data[0]);
@@ -522,62 +659,20 @@ void bnx2x_read_dmae(struct bnx2x *bp, u32 src_addr, u32 len32)
 		return;
 	}
 
-	memset(&dmae, 0, sizeof(struct dmae_command));
+	/* set opcode and fixed command fields */
+	bnx2x_prep_dmae_with_comp(bp, &dmae, DMAE_SRC_GRC, DMAE_DST_PCI);
 
-	dmae.opcode = (DMAE_CMD_SRC_GRC | DMAE_CMD_DST_PCI |
-		       DMAE_CMD_C_DST_PCI | DMAE_CMD_C_ENABLE |
-		       DMAE_CMD_SRC_RESET | DMAE_CMD_DST_RESET |
-#ifdef __BIG_ENDIAN
-		       DMAE_CMD_ENDIANITY_B_DW_SWAP |
-#else
-		       DMAE_CMD_ENDIANITY_DW_SWAP |
-#endif
-		       (BP_PORT(bp) ? DMAE_CMD_PORT_1 : DMAE_CMD_PORT_0) |
-		       (BP_E1HVN(bp) << DMAE_CMD_E1HVN_SHIFT));
+	/* fill in addresses and len */
 	dmae.src_addr_lo = src_addr >> 2;
 	dmae.src_addr_hi = 0;
 	dmae.dst_addr_lo = U64_LO(bnx2x_sp_mapping(bp, wb_data));
 	dmae.dst_addr_hi = U64_HI(bnx2x_sp_mapping(bp, wb_data));
 	dmae.len = len32;
-	dmae.comp_addr_lo = U64_LO(bnx2x_sp_mapping(bp, wb_comp));
-	dmae.comp_addr_hi = U64_HI(bnx2x_sp_mapping(bp, wb_comp));
-	dmae.comp_val = DMAE_COMP_VAL;
-
-	DP(BNX2X_MSG_OFF, "DMAE: opcode 0x%08x\n"
-	   DP_LEVEL "src_addr  [%x:%08x]  len [%d *4]  "
-		    "dst_addr [%x:%08x (%08x)]\n"
-	   DP_LEVEL "comp_addr [%x:%08x]  comp_val 0x%08x\n",
-	   dmae.opcode, dmae.src_addr_hi, dmae.src_addr_lo,
-	   dmae.len, dmae.dst_addr_hi, dmae.dst_addr_lo, src_addr,
-	   dmae.comp_addr_hi, dmae.comp_addr_lo, dmae.comp_val);
-
-	mutex_lock(&bp->dmae_mutex);
-
-	memset(bnx2x_sp(bp, wb_data[0]), 0, sizeof(u32) * 4);
-	*wb_comp = 0;
-
-	bnx2x_post_dmae(bp, &dmae, INIT_DMAE_C(bp));
-
-	udelay(5);
 
-	while (*wb_comp != DMAE_COMP_VAL) {
+	bnx2x_dp_dmae(bp, &dmae, BNX2X_MSG_OFF);
 
-		if (!cnt) {
-			BNX2X_ERR("DMAE timeout!\n");
-			break;
-		}
-		cnt--;
-		/* adjust delay for emulation/FPGA */
-		if (CHIP_REV_IS_SLOW(bp))
-			msleep(100);
-		else
-			udelay(5);
-	}
-	DP(BNX2X_MSG_OFF, "data [0x%08x 0x%08x 0x%08x 0x%08x]\n",
-	   bp->slowpath->wb_data[0], bp->slowpath->wb_data[1],
-	   bp->slowpath->wb_data[2], bp->slowpath->wb_data[3]);
-
-	mutex_unlock(&bp->dmae_mutex);
+	/* issue the command and wait for completion */
+	bnx2x_issue_dmae_with_comp(bp, &dmae);
 }
 
 void bnx2x_write_dmae_phys_len(struct bnx2x *bp, dma_addr_t phys_addr,
@@ -744,19 +839,24 @@ static void bnx2x_fw_dump(struct bnx2x *bp)
 	u32 mark, offset;
 	__be32 data[9];
 	int word;
-
+	u32 trace_shmem_base;
 	if (BP_NOMCP(bp)) {
 		BNX2X_ERR("NO MCP - can not dump\n");
 		return;
 	}
 
-	addr = bp->common.shmem_base - 0x0800 + 4;
+	if (BP_PATH(bp) == 0)
+		trace_shmem_base = bp->common.shmem_base;
+	else
+		trace_shmem_base = SHMEM2_RD(bp, other_shmem_base_addr);
+	addr = trace_shmem_base - 0x0800 + 4;
 	mark = REG_RD(bp, addr);
-	mark = MCP_REG_MCPR_SCRATCH + ((mark + 0x3) & ~0x3) - 0x08000000;
+	mark = (CHIP_IS_E1x(bp) ? MCP_REG_MCPR_SCRATCH : MCP_A_REG_MCPR_SCRATCH)
+			+ ((mark + 0x3) & ~0x3) - 0x08000000;
 	pr_err("begin fw dump (mark 0x%x)\n", mark);
 
 	pr_err("");
-	for (offset = mark; offset <= bp->common.shmem_base; offset += 0x8*4) {
+	for (offset = mark; offset <= trace_shmem_base; offset += 0x8*4) {
 		for (word = 0; word < 8; word++)
 			data[word] = htonl(REG_RD(bp, offset + 4*word));
 		data[8] = 0x0;
@@ -822,10 +922,15 @@ void bnx2x_panic_dump(struct bnx2x *bp)
 	for_each_queue(bp, i) {
 		struct bnx2x_fastpath *fp = &bp->fp[i];
 		int loop;
+		struct hc_status_block_data_e2 sb_data_e2;
 		struct hc_status_block_data_e1x sb_data_e1x;
 		struct hc_status_block_sm  *hc_sm_p =
+			CHIP_IS_E2(bp) ?
+			sb_data_e2.common.state_machine :
 			sb_data_e1x.common.state_machine;
 		struct hc_index_data *hc_index_p =
+			CHIP_IS_E2(bp) ?
+			sb_data_e2.index_data :
 			sb_data_e1x.index_data;
 		int data_size;
 		u32 *sb_data_p;
@@ -849,7 +954,8 @@ void bnx2x_panic_dump(struct bnx2x *bp)
 			  i, fp->tx_pkt_prod, fp->tx_pkt_cons, fp->tx_bd_prod,
 			  fp->tx_bd_cons, le16_to_cpu(*fp->tx_cons_sb));
 
-		loop = HC_SB_MAX_INDICES_E1X;
+		loop = CHIP_IS_E2(bp) ?
+			HC_SB_MAX_INDICES_E2 : HC_SB_MAX_INDICES_E1X;
 
 		/* host sb data */
 
@@ -865,23 +971,36 @@ void bnx2x_panic_dump(struct bnx2x *bp)
 			       fp->sb_index_values[j],
 			       (j == loop - 1) ? ")" : " ");
 		/* fw sb data */
-		data_size =
+		data_size = CHIP_IS_E2(bp) ?
+			sizeof(struct hc_status_block_data_e2) :
 			sizeof(struct hc_status_block_data_e1x);
 		data_size /= sizeof(u32);
-		sb_data_p = (u32 *)&sb_data_e1x;
+		sb_data_p = CHIP_IS_E2(bp) ?
+			(u32 *)&sb_data_e2 :
+			(u32 *)&sb_data_e1x;
 		/* copy sb data in here */
 		for (j = 0; j < data_size; j++)
 			*(sb_data_p + j) = REG_RD(bp, BAR_CSTRORM_INTMEM +
 				CSTORM_STATUS_BLOCK_DATA_OFFSET(fp->fw_sb_id) +
 				j * sizeof(u32));
 
-		pr_cont("pf_id(0x%x)  vf_id (0x%x)  vf_valid(0x%x) "
-			"vnic_id(0x%x)  same_igu_sb_1b(0x%x)\n",
-			sb_data_e1x.common.p_func.pf_id,
-			sb_data_e1x.common.p_func.vf_id,
-			sb_data_e1x.common.p_func.vf_valid,
-			sb_data_e1x.common.p_func.vnic_id,
-			sb_data_e1x.common.same_igu_sb_1b);
+		if (CHIP_IS_E2(bp)) {
+			pr_cont("pf_id(0x%x)  vf_id (0x%x)  vf_valid(0x%x) "
+				"vnic_id(0x%x)  same_igu_sb_1b(0x%x)\n",
+				sb_data_e2.common.p_func.pf_id,
+				sb_data_e2.common.p_func.vf_id,
+				sb_data_e2.common.p_func.vf_valid,
+				sb_data_e2.common.p_func.vnic_id,
+				sb_data_e2.common.same_igu_sb_1b);
+		} else {
+			pr_cont("pf_id(0x%x)  vf_id (0x%x)  vf_valid(0x%x) "
+				"vnic_id(0x%x)  same_igu_sb_1b(0x%x)\n",
+				sb_data_e1x.common.p_func.pf_id,
+				sb_data_e1x.common.p_func.vf_id,
+				sb_data_e1x.common.p_func.vf_valid,
+				sb_data_e1x.common.p_func.vnic_id,
+				sb_data_e1x.common.same_igu_sb_1b);
+		}
 
 		/* SB_SMs data */
 		for (j = 0; j < HC_SB_MAX_SM; j++) {
@@ -969,7 +1088,7 @@ void bnx2x_panic_dump(struct bnx2x *bp)
 	BNX2X_ERR("end crash dump -----------------\n");
 }
 
-void bnx2x_int_enable(struct bnx2x *bp)
+static void bnx2x_hc_int_enable(struct bnx2x *bp)
 {
 	int port = BP_PORT(bp);
 	u32 addr = port ? HC_REG_CONFIG_1 : HC_REG_CONFIG_0;
@@ -1011,7 +1130,7 @@ void bnx2x_int_enable(struct bnx2x *bp)
 	mmiowb();
 	barrier();
 
-	if (CHIP_IS_E1H(bp)) {
+	if (!CHIP_IS_E1(bp)) {
 		/* init leading/trailing edge */
 		if (IS_MF(bp)) {
 			val = (0xee0f | (1 << (BP_E1HVN(bp) + 4)));
@@ -1029,7 +1148,66 @@ void bnx2x_int_enable(struct bnx2x *bp)
 	mmiowb();
 }
 
-void bnx2x_int_disable(struct bnx2x *bp)
+static void bnx2x_igu_int_enable(struct bnx2x *bp)
+{
+	u32 val;
+	int msix = (bp->flags & USING_MSIX_FLAG) ? 1 : 0;
+	int msi = (bp->flags & USING_MSI_FLAG) ? 1 : 0;
+
+	val = REG_RD(bp, IGU_REG_PF_CONFIGURATION);
+
+	if (msix) {
+		val &= ~(IGU_PF_CONF_INT_LINE_EN |
+			 IGU_PF_CONF_SINGLE_ISR_EN);
+		val |= (IGU_PF_CONF_FUNC_EN |
+			IGU_PF_CONF_MSI_MSIX_EN |
+			IGU_PF_CONF_ATTN_BIT_EN);
+	} else if (msi) {
+		val &= ~IGU_PF_CONF_INT_LINE_EN;
+		val |= (IGU_PF_CONF_FUNC_EN |
+			IGU_PF_CONF_MSI_MSIX_EN |
+			IGU_PF_CONF_ATTN_BIT_EN |
+			IGU_PF_CONF_SINGLE_ISR_EN);
+	} else {
+		val &= ~IGU_PF_CONF_MSI_MSIX_EN;
+		val |= (IGU_PF_CONF_FUNC_EN |
+			IGU_PF_CONF_INT_LINE_EN |
+			IGU_PF_CONF_ATTN_BIT_EN |
+			IGU_PF_CONF_SINGLE_ISR_EN);
+	}
+
+	DP(NETIF_MSG_INTR, "write 0x%x to IGU  mode %s\n",
+	   val, (msix ? "MSI-X" : (msi ? "MSI" : "INTx")));
+
+	REG_WR(bp, IGU_REG_PF_CONFIGURATION, val);
+
+	barrier();
+
+	/* init leading/trailing edge */
+	if (IS_MF(bp)) {
+		val = (0xee0f | (1 << (BP_E1HVN(bp) + 4)));
+		if (bp->port.pmf)
+			/* enable nig and gpio3 attention */
+			val |= 0x1100;
+	} else
+		val = 0xffff;
+
+	REG_WR(bp, IGU_REG_TRAILING_EDGE_LATCH, val);
+	REG_WR(bp, IGU_REG_LEADING_EDGE_LATCH, val);
+
+	/* Make sure that interrupts are indeed enabled from here on */
+	mmiowb();
+}
+
+void bnx2x_int_enable(struct bnx2x *bp)
+{
+	if (bp->common.int_block == INT_BLOCK_HC)
+		bnx2x_hc_int_enable(bp);
+	else
+		bnx2x_igu_int_enable(bp);
+}
+
+static void bnx2x_hc_int_disable(struct bnx2x *bp)
 {
 	int port = BP_PORT(bp);
 	u32 addr = port ? HC_REG_CONFIG_1 : HC_REG_CONFIG_0;
@@ -1051,6 +1229,32 @@ void bnx2x_int_disable(struct bnx2x *bp)
 		BNX2X_ERR("BUG! proper val not read from IGU!\n");
 }
 
+static void bnx2x_igu_int_disable(struct bnx2x *bp)
+{
+	u32 val = REG_RD(bp, IGU_REG_PF_CONFIGURATION);
+
+	val &= ~(IGU_PF_CONF_MSI_MSIX_EN |
+		 IGU_PF_CONF_INT_LINE_EN |
+		 IGU_PF_CONF_ATTN_BIT_EN);
+
+	DP(NETIF_MSG_INTR, "write %x to IGU\n", val);
+
+	/* flush all outstanding writes */
+	mmiowb();
+
+	REG_WR(bp, IGU_REG_PF_CONFIGURATION, val);
+	if (REG_RD(bp, IGU_REG_PF_CONFIGURATION) != val)
+		BNX2X_ERR("BUG! proper val not read from IGU!\n");
+}
+
+void bnx2x_int_disable(struct bnx2x *bp)
+{
+	if (bp->common.int_block == INT_BLOCK_HC)
+		bnx2x_hc_int_disable(bp);
+	else
+		bnx2x_igu_int_disable(bp);
+}
+
 void bnx2x_int_disable_sync(struct bnx2x *bp, int disable_hw)
 {
 	int msix = (bp->flags & USING_MSIX_FLAG) ? 1 : 0;
@@ -1194,7 +1398,7 @@ irqreturn_t bnx2x_interrupt(int irq, void *dev_instance)
 		return IRQ_HANDLED;
 #endif
 
-	for (i = 0; i < BNX2X_NUM_QUEUES(bp); i++) {
+	for_each_queue(bp, i) {
 		struct bnx2x_fastpath *fp = &bp->fp[i];
 
 		mask = 0x2 << (fp->index + CNIC_CONTEXT_USE);
@@ -1579,7 +1783,7 @@ u8 bnx2x_initial_phy_init(struct bnx2x *bp, int load_mode)
 		/* Initialize link parameters structure variables */
 		/* It is recommended to turn off RX FC for jumbo frames
 		   for better performance */
-		if (bp->dev->mtu > 5000)
+		if ((CHIP_IS_E1x(bp)) && (bp->dev->mtu > 5000))
 			bp->link_params.req_fc_auto_adv = BNX2X_FLOW_CTRL_TX;
 		else
 			bp->link_params.req_fc_auto_adv = BNX2X_FLOW_CTRL_BOTH;
@@ -1693,13 +1897,11 @@ static void bnx2x_init_port_minmax(struct bnx2x *bp)
 static void bnx2x_calc_vn_weight_sum(struct bnx2x *bp)
 {
 	int all_zero = 1;
-	int port = BP_PORT(bp);
 	int vn;
 
 	bp->vn_weight_sum = 0;
 	for (vn = VN_0; vn < E1HVN_MAX; vn++) {
-		int func = 2*vn + port;
-		u32 vn_cfg = MF_CFG_RD(bp, func_mf_config[func].config);
+		u32 vn_cfg = bp->mf_config[vn];
 		u32 vn_min_rate = ((vn_cfg & FUNC_MF_CFG_MIN_BW_MASK) >>
 				   FUNC_MF_CFG_MIN_BW_SHIFT) * 100;
 
@@ -1727,11 +1929,12 @@ static void bnx2x_calc_vn_weight_sum(struct bnx2x *bp)
 					CMNG_FLAGS_PER_PORT_FAIRNESS_VN;
 }
 
-static void bnx2x_init_vn_minmax(struct bnx2x *bp, int func)
+static void bnx2x_init_vn_minmax(struct bnx2x *bp, int vn)
 {
 	struct rate_shaping_vars_per_vn m_rs_vn;
 	struct fairness_vars_per_vn m_fair_vn;
-	u32 vn_cfg = MF_CFG_RD(bp, func_mf_config[func].config);
+	u32 vn_cfg = bp->mf_config[vn];
+	int func = 2*vn + BP_PORT(bp);
 	u16 vn_min_rate, vn_max_rate;
 	int i;
 
@@ -1744,7 +1947,7 @@ static void bnx2x_init_vn_minmax(struct bnx2x *bp, int func)
 		vn_min_rate = ((vn_cfg & FUNC_MF_CFG_MIN_BW_MASK) >>
 				FUNC_MF_CFG_MIN_BW_SHIFT) * 100;
 		/* If min rate is zero - set it to 1 */
-		if (!vn_min_rate)
+		if (bp->vn_weight_sum && (vn_min_rate == 0))
 			vn_min_rate = DEF_MIN_RATE;
 		vn_max_rate = ((vn_cfg & FUNC_MF_CFG_MAX_BW_MASK) >>
 				FUNC_MF_CFG_MAX_BW_SHIFT) * 100;
@@ -1807,7 +2010,7 @@ static void bnx2x_read_mf_cfg(struct bnx2x *bp)
 
 	for (vn = VN_0; vn < E1HVN_MAX; vn++) {
 		int /*abs*/func = 2*vn + BP_PORT(bp);
-		bp->mf_config =
+		bp->mf_config[vn] =
 			MF_CFG_RD(bp, func_mf_config[func].config);
 	}
 }
@@ -1878,7 +2081,7 @@ static void bnx2x_link_attn(struct bnx2x *bp)
 	if (bp->link_vars.link_up) {
 
 		/* dropless flow control */
-		if (CHIP_IS_E1H(bp) && bp->dropless_fc) {
+		if (!CHIP_IS_E1(bp) && bp->dropless_fc) {
 			int port = BP_PORT(bp);
 			u32 pause_enabled = 0;
 
@@ -1906,37 +2109,19 @@ static void bnx2x_link_attn(struct bnx2x *bp)
 	if (prev_link_status != bp->link_vars.link_status)
 		bnx2x_link_report(bp);
 
-	if (IS_MF(bp)) {
-		int port = BP_PORT(bp);
-		int func;
-		int vn;
-
-		/* Set the attention towards other drivers on the same port */
-		for (vn = VN_0; vn < E1HVN_MAX; vn++) {
-			if (vn == BP_E1HVN(bp))
-				continue;
-
-			func = ((vn << 1) | port);
-			REG_WR(bp, MISC_REG_AEU_GENERAL_ATTN_0 +
-			       (LINK_SYNC_ATTENTION_BIT_FUNC_0 + func)*4, 1);
-		}
-
-		if (bp->link_vars.link_up) {
-			int i;
-
-			/* Init rate shaping and fairness contexts */
-			bnx2x_init_port_minmax(bp);
+	if (IS_MF(bp))
+		bnx2x_link_sync_notify(bp);
 
-			for (vn = VN_0; vn < E1HVN_MAX; vn++)
-				bnx2x_init_vn_minmax(bp, 2*vn + port);
+	if (bp->link_vars.link_up && bp->link_vars.line_speed) {
+		int cmng_fns = bnx2x_get_cmng_fns_mode(bp);
 
-			/* Store it to internal memory */
-			for (i = 0;
-			     i < sizeof(struct cmng_struct_per_port) / 4; i++)
-				REG_WR(bp, BAR_XSTRORM_INTMEM +
-				  XSTORM_CMNG_PER_PORT_VARS_OFFSET(port) + i*4,
-				       ((u32 *)(&bp->cmng))[i]);
-		}
+		if (cmng_fns != CMNG_FNS_NONE) {
+			bnx2x_cmng_fns_init(bp, false, cmng_fns);
+			storm_memset_cmng(bp, &bp->cmng, BP_PORT(bp));
+		} else
+			/* rate shaping and fairness are disabled */
+			DP(NETIF_MSG_IFUP,
+			   "single function mode without fairness\n");
 	}
 }
 
@@ -1952,7 +2137,9 @@ void bnx2x__link_status_update(struct bnx2x *bp)
 	else
 		bnx2x_stats_handle(bp, STATS_EVENT_STOP);
 
-	bnx2x_calc_vn_weight_sum(bp);
+	/* the link status update could be the result of a DCC event
+	   hence re-read the shmem mf configuration */
+	bnx2x_read_mf_cfg(bp);
 
 	/* indicate link status */
 	bnx2x_link_report(bp);
@@ -1968,8 +2155,13 @@ static void bnx2x_pmf_update(struct bnx2x *bp)
 
 	/* enable nig attention */
 	val = (0xff0f | (1 << (BP_E1HVN(bp) + 4)));
-	REG_WR(bp, HC_REG_TRAILING_EDGE_0 + port*8, val);
-	REG_WR(bp, HC_REG_LEADING_EDGE_0 + port*8, val);
+	if (bp->common.int_block == INT_BLOCK_HC) {
+		REG_WR(bp, HC_REG_TRAILING_EDGE_0 + port*8, val);
+		REG_WR(bp, HC_REG_LEADING_EDGE_0 + port*8, val);
+	} else if (CHIP_IS_E2(bp)) {
+		REG_WR(bp, IGU_REG_TRAILING_EDGE_LATCH, val);
+		REG_WR(bp, IGU_REG_LEADING_EDGE_LATCH, val);
+	}
 
 	bnx2x_stats_handle(bp, STATS_EVENT_PMF);
 }
@@ -1985,22 +2177,23 @@ static void bnx2x_pmf_update(struct bnx2x *bp)
 /* send the MCP a request, block until there is a reply */
 u32 bnx2x_fw_command(struct bnx2x *bp, u32 command, u32 param)
 {
-	int func = BP_FUNC(bp);
+	int mb_idx = BP_FW_MB_IDX(bp);
 	u32 seq = ++bp->fw_seq;
 	u32 rc = 0;
 	u32 cnt = 1;
 	u8 delay = CHIP_REV_IS_SLOW(bp) ? 100 : 10;
 
 	mutex_lock(&bp->fw_mb_mutex);
-	SHMEM_WR(bp, func_mb[func].drv_mb_param, param);
-	SHMEM_WR(bp, func_mb[func].drv_mb_header, (command | seq));
+	SHMEM_WR(bp, func_mb[mb_idx].drv_mb_param, param);
+	SHMEM_WR(bp, func_mb[mb_idx].drv_mb_header, (command | seq));
+
 	DP(BNX2X_MSG_MCP, "wrote command (%x) to FW MB\n", (command | seq));
 
 	do {
 		/* let the FW do it's magic ... */
 		msleep(delay);
 
-		rc = SHMEM_RD(bp, func_mb[func].fw_mb_header);
+		rc = SHMEM_RD(bp, func_mb[mb_idx].fw_mb_header);
 
 		/* Give the FW up to 5 second (500*10ms) */
 	} while ((seq != (rc & FW_MSG_SEQ_NUMBER_MASK)) && (cnt++ < 500));
@@ -2264,10 +2457,28 @@ void bnx2x_pf_init(struct bnx2x *bp)
 	if (!CHIP_IS_E1(bp))
 		storm_memset_ov(bp, bp->mf_ov, BP_FUNC(bp));
 
+	if (CHIP_IS_E2(bp)) {
+		/* reset IGU PF statistics: MSIX + ATTN */
+		/* PF */
+		REG_WR(bp, IGU_REG_STATISTIC_NUM_MESSAGE_SENT +
+			   BNX2X_IGU_STAS_MSG_VF_CNT*4 +
+			   (CHIP_MODE_IS_4_PORT(bp) ?
+				BP_FUNC(bp) : BP_VN(bp))*4, 0);
+		/* ATTN */
+		REG_WR(bp, IGU_REG_STATISTIC_NUM_MESSAGE_SENT +
+			   BNX2X_IGU_STAS_MSG_VF_CNT*4 +
+			   BNX2X_IGU_STAS_MSG_PF_CNT*4 +
+			   (CHIP_MODE_IS_4_PORT(bp) ?
+				BP_FUNC(bp) : BP_VN(bp))*4, 0);
+	}
+
 	/* function setup flags */
 	flags = (FUNC_FLG_STATS | FUNC_FLG_LEADING | FUNC_FLG_SPQ);
 
-	flags |= (bp->flags & TPA_ENABLE_FLAG) ? FUNC_FLG_TPA : 0;
+	if (CHIP_IS_E1x(bp))
+		flags |= (bp->flags & TPA_ENABLE_FLAG) ? FUNC_FLG_TPA : 0;
+	else
+		flags |= FUNC_FLG_TPA;
 
 	/**
 	 * Although RSS is meaningless when there is a single HW queue we
@@ -2361,7 +2572,7 @@ static void bnx2x_dcc_event(struct bnx2x *bp, u32 dcc_event)
 		 * where the bp->flags can change so it is done without any
 		 * locks
 		 */
-		if (bp->mf_config & FUNC_MF_CFG_FUNC_DISABLED) {
+		if (bp->mf_config[BP_VN(bp)] & FUNC_MF_CFG_FUNC_DISABLED) {
 			DP(NETIF_MSG_IFDOWN, "mf_cfg function disabled\n");
 			bp->flags |= MF_FUNC_DIS;
 
@@ -2548,14 +2759,13 @@ static inline u16 bnx2x_update_dsb_idx(struct bnx2x *bp)
 static void bnx2x_attn_int_asserted(struct bnx2x *bp, u32 asserted)
 {
 	int port = BP_PORT(bp);
-	u32 hc_addr = (HC_REG_COMMAND_REG + port*32 +
-		       COMMAND_REG_ATTN_BITS_SET);
 	u32 aeu_addr = port ? MISC_REG_AEU_MASK_ATTN_FUNC_1 :
 			      MISC_REG_AEU_MASK_ATTN_FUNC_0;
 	u32 nig_int_mask_addr = port ? NIG_REG_MASK_INTERRUPT_PORT1 :
 				       NIG_REG_MASK_INTERRUPT_PORT0;
 	u32 aeu_mask;
 	u32 nig_mask = 0;
+	u32 reg_addr;
 
 	if (bp->attn_state & asserted)
 		BNX2X_ERR("IGU ERROR\n");
@@ -2630,9 +2840,15 @@ static void bnx2x_attn_int_asserted(struct bnx2x *bp, u32 asserted)
 
 	} /* if hardwired */
 
-	DP(NETIF_MSG_HW, "about to mask 0x%08x at HC addr 0x%x\n",
-	   asserted, hc_addr);
-	REG_WR(bp, hc_addr, asserted);
+	if (bp->common.int_block == INT_BLOCK_HC)
+		reg_addr = (HC_REG_COMMAND_REG + port*32 +
+			    COMMAND_REG_ATTN_BITS_SET);
+	else
+		reg_addr = (BAR_IGU_INTMEM + IGU_CMD_ATTN_BIT_SET_UPPER*8);
+
+	DP(NETIF_MSG_HW, "about to mask 0x%08x at %s addr 0x%x\n", asserted,
+	   (bp->common.int_block == INT_BLOCK_HC) ? "HC" : "IGU", reg_addr);
+	REG_WR(bp, reg_addr, asserted);
 
 	/* now set back the mask */
 	if (asserted & ATTN_NIG_FOR_FUNC) {
@@ -2753,6 +2969,10 @@ static inline void bnx2x_attn_int_deasserted2(struct bnx2x *bp, u32 attn)
 		/* RQ_USDMDP_FIFO_OVERFLOW */
 		if (val & 0x18000)
 			BNX2X_ERR("FATAL error from PXP\n");
+		if (CHIP_IS_E2(bp)) {
+			val = REG_RD(bp, PXP_REG_PXP_INT_STS_CLR_1);
+			BNX2X_ERR("PXP hw attention-1 0x%x\n", val);
+		}
 	}
 
 	if (attn & HW_INTERRUT_ASSERT_SET_2) {
@@ -2783,9 +3003,10 @@ static inline void bnx2x_attn_int_deasserted3(struct bnx2x *bp, u32 attn)
 			int func = BP_FUNC(bp);
 
 			REG_WR(bp, MISC_REG_AEU_GENERAL_ATTN_12 + func*4, 0);
-			bp->mf_config =
-				MF_CFG_RD(bp, func_mf_config[func].config);
-			val = SHMEM_RD(bp, func_mb[func].drv_status);
+			bp->mf_config[BP_VN(bp)] = MF_CFG_RD(bp,
+					func_mf_config[BP_ABS_FUNC(bp)].config);
+			val = SHMEM_RD(bp,
+				       func_mb[BP_FW_MB_IDX(bp)].drv_status);
 			if (val & DRV_STATUS_DCC_EVENT_MASK)
 				bnx2x_dcc_event(bp,
 					    (val & DRV_STATUS_DCC_EVENT_MASK));
@@ -2815,13 +3036,13 @@ static inline void bnx2x_attn_int_deasserted3(struct bnx2x *bp, u32 attn)
 	if (attn & EVEREST_LATCHED_ATTN_IN_USE_MASK) {
 		BNX2X_ERR("LATCHED attention 0x%08x (masked)\n", attn);
 		if (attn & BNX2X_GRC_TIMEOUT) {
-			val = CHIP_IS_E1H(bp) ?
-				REG_RD(bp, MISC_REG_GRC_TIMEOUT_ATTN) : 0;
+			val = CHIP_IS_E1(bp) ? 0 :
+					REG_RD(bp, MISC_REG_GRC_TIMEOUT_ATTN);
 			BNX2X_ERR("GRC time-out 0x%08x\n", val);
 		}
 		if (attn & BNX2X_GRC_RSV) {
-			val = CHIP_IS_E1H(bp) ?
-				REG_RD(bp, MISC_REG_GRC_RSV_ATTN) : 0;
+			val = CHIP_IS_E1(bp) ? 0 :
+					REG_RD(bp, MISC_REG_GRC_RSV_ATTN);
 			BNX2X_ERR("GRC reserved 0x%08x\n", val);
 		}
 		REG_WR(bp, MISC_REG_AEU_CLR_LATCH_SIGNAL, 0x7ff);
@@ -3126,6 +3347,74 @@ bool bnx2x_chk_parity_attn(struct bnx2x *bp)
 					attn.sig[3]);
 }
 
+
+static inline void bnx2x_attn_int_deasserted4(struct bnx2x *bp, u32 attn)
+{
+	u32 val;
+	if (attn & AEU_INPUTS_ATTN_BITS_PGLUE_HW_INTERRUPT) {
+
+		val = REG_RD(bp, PGLUE_B_REG_PGLUE_B_INT_STS_CLR);
+		BNX2X_ERR("PGLUE hw attention 0x%x\n", val);
+		if (val & PGLUE_B_PGLUE_B_INT_STS_REG_ADDRESS_ERROR)
+			BNX2X_ERR("PGLUE_B_PGLUE_B_INT_STS_REG_"
+				  "ADDRESS_ERROR\n");
+		if (val & PGLUE_B_PGLUE_B_INT_STS_REG_INCORRECT_RCV_BEHAVIOR)
+			BNX2X_ERR("PGLUE_B_PGLUE_B_INT_STS_REG_"
+				  "INCORRECT_RCV_BEHAVIOR\n");
+		if (val & PGLUE_B_PGLUE_B_INT_STS_REG_WAS_ERROR_ATTN)
+			BNX2X_ERR("PGLUE_B_PGLUE_B_INT_STS_REG_"
+				  "WAS_ERROR_ATTN\n");
+		if (val & PGLUE_B_PGLUE_B_INT_STS_REG_VF_LENGTH_VIOLATION_ATTN)
+			BNX2X_ERR("PGLUE_B_PGLUE_B_INT_STS_REG_"
+				  "VF_LENGTH_VIOLATION_ATTN\n");
+		if (val &
+		    PGLUE_B_PGLUE_B_INT_STS_REG_VF_GRC_SPACE_VIOLATION_ATTN)
+			BNX2X_ERR("PGLUE_B_PGLUE_B_INT_STS_REG_"
+				  "VF_GRC_SPACE_VIOLATION_ATTN\n");
+		if (val &
+		    PGLUE_B_PGLUE_B_INT_STS_REG_VF_MSIX_BAR_VIOLATION_ATTN)
+			BNX2X_ERR("PGLUE_B_PGLUE_B_INT_STS_REG_"
+				  "VF_MSIX_BAR_VIOLATION_ATTN\n");
+		if (val & PGLUE_B_PGLUE_B_INT_STS_REG_TCPL_ERROR_ATTN)
+			BNX2X_ERR("PGLUE_B_PGLUE_B_INT_STS_REG_"
+				  "TCPL_ERROR_ATTN\n");
+		if (val & PGLUE_B_PGLUE_B_INT_STS_REG_TCPL_IN_TWO_RCBS_ATTN)
+			BNX2X_ERR("PGLUE_B_PGLUE_B_INT_STS_REG_"
+				  "TCPL_IN_TWO_RCBS_ATTN\n");
+		if (val & PGLUE_B_PGLUE_B_INT_STS_REG_CSSNOOP_FIFO_OVERFLOW)
+			BNX2X_ERR("PGLUE_B_PGLUE_B_INT_STS_REG_"
+				  "CSSNOOP_FIFO_OVERFLOW\n");
+	}
+	if (attn & AEU_INPUTS_ATTN_BITS_ATC_HW_INTERRUPT) {
+		val = REG_RD(bp, ATC_REG_ATC_INT_STS_CLR);
+		BNX2X_ERR("ATC hw attention 0x%x\n", val);
+		if (val & ATC_ATC_INT_STS_REG_ADDRESS_ERROR)
+			BNX2X_ERR("ATC_ATC_INT_STS_REG_ADDRESS_ERROR\n");
+		if (val & ATC_ATC_INT_STS_REG_ATC_TCPL_TO_NOT_PEND)
+			BNX2X_ERR("ATC_ATC_INT_STS_REG"
+				  "_ATC_TCPL_TO_NOT_PEND\n");
+		if (val & ATC_ATC_INT_STS_REG_ATC_GPA_MULTIPLE_HITS)
+			BNX2X_ERR("ATC_ATC_INT_STS_REG_"
+				  "ATC_GPA_MULTIPLE_HITS\n");
+		if (val & ATC_ATC_INT_STS_REG_ATC_RCPL_TO_EMPTY_CNT)
+			BNX2X_ERR("ATC_ATC_INT_STS_REG_"
+				  "ATC_RCPL_TO_EMPTY_CNT\n");
+		if (val & ATC_ATC_INT_STS_REG_ATC_TCPL_ERROR)
+			BNX2X_ERR("ATC_ATC_INT_STS_REG_ATC_TCPL_ERROR\n");
+		if (val & ATC_ATC_INT_STS_REG_ATC_IREQ_LESS_THAN_STU)
+			BNX2X_ERR("ATC_ATC_INT_STS_REG_"
+				  "ATC_IREQ_LESS_THAN_STU\n");
+	}
+
+	if (attn & (AEU_INPUTS_ATTN_BITS_PGLUE_PARITY_ERROR |
+		    AEU_INPUTS_ATTN_BITS_ATC_PARITY_ERROR)) {
+		BNX2X_ERR("FATAL parity attention set4 0x%x\n",
+		(u32)(attn & (AEU_INPUTS_ATTN_BITS_PGLUE_PARITY_ERROR |
+		    AEU_INPUTS_ATTN_BITS_ATC_PARITY_ERROR)));
+	}
+
+}
+
 static void bnx2x_attn_int_deasserted(struct bnx2x *bp, u32 deasserted)
 {
 	struct attn_route attn, *group_mask;
@@ -3156,17 +3445,28 @@ static void bnx2x_attn_int_deasserted(struct bnx2x *bp, u32 deasserted)
 	attn.sig[1] = REG_RD(bp, MISC_REG_AEU_AFTER_INVERT_2_FUNC_0 + port*4);
 	attn.sig[2] = REG_RD(bp, MISC_REG_AEU_AFTER_INVERT_3_FUNC_0 + port*4);
 	attn.sig[3] = REG_RD(bp, MISC_REG_AEU_AFTER_INVERT_4_FUNC_0 + port*4);
-	DP(NETIF_MSG_HW, "attn: %08x %08x %08x %08x\n",
-	   attn.sig[0], attn.sig[1], attn.sig[2], attn.sig[3]);
+	if (CHIP_IS_E2(bp))
+		attn.sig[4] =
+		      REG_RD(bp, MISC_REG_AEU_AFTER_INVERT_5_FUNC_0 + port*4);
+	else
+		attn.sig[4] = 0;
+
+	DP(NETIF_MSG_HW, "attn: %08x %08x %08x %08x %08x\n",
+	   attn.sig[0], attn.sig[1], attn.sig[2], attn.sig[3], attn.sig[4]);
 
 	for (index = 0; index < MAX_DYNAMIC_ATTN_GRPS; index++) {
 		if (deasserted & (1 << index)) {
 			group_mask = &bp->attn_group[index];
 
-			DP(NETIF_MSG_HW, "group[%d]: %08x %08x %08x %08x\n",
-			   index, group_mask->sig[0], group_mask->sig[1],
-			   group_mask->sig[2], group_mask->sig[3]);
+			DP(NETIF_MSG_HW, "group[%d]: %08x %08x "
+					 "%08x %08x %08x\n",
+			   index,
+			   group_mask->sig[0], group_mask->sig[1],
+			   group_mask->sig[2], group_mask->sig[3],
+			   group_mask->sig[4]);
 
+			bnx2x_attn_int_deasserted4(bp,
+					attn.sig[4] & group_mask->sig[4]);
 			bnx2x_attn_int_deasserted3(bp,
 					attn.sig[3] & group_mask->sig[3]);
 			bnx2x_attn_int_deasserted1(bp,
@@ -3180,11 +3480,15 @@ static void bnx2x_attn_int_deasserted(struct bnx2x *bp, u32 deasserted)
 
 	bnx2x_release_alr(bp);
 
-	reg_addr = (HC_REG_COMMAND_REG + port*32 + COMMAND_REG_ATTN_BITS_CLR);
+	if (bp->common.int_block == INT_BLOCK_HC)
+		reg_addr = (HC_REG_COMMAND_REG + port*32 +
+			    COMMAND_REG_ATTN_BITS_CLR);
+	else
+		reg_addr = (BAR_IGU_INTMEM + IGU_CMD_ATTN_BIT_CLR_UPPER*8);
 
 	val = ~deasserted;
-	DP(NETIF_MSG_HW, "about to mask 0x%08x at HC addr 0x%x\n",
-	   val, reg_addr);
+	DP(NETIF_MSG_HW, "about to mask 0x%08x at %s addr 0x%x\n", val,
+	   (bp->common.int_block == INT_BLOCK_HC) ? "HC" : "IGU", reg_addr);
 	REG_WR(bp, reg_addr, val);
 
 	if (~bp->attn_state & deasserted)
@@ -3471,7 +3775,7 @@ static void bnx2x_timer(unsigned long data)
 	}
 
 	if (!BP_NOMCP(bp)) {
-		int func = BP_FUNC(bp);
+		int mb_idx = BP_FW_MB_IDX(bp);
 		u32 drv_pulse;
 		u32 mcp_pulse;
 
@@ -3479,9 +3783,9 @@ static void bnx2x_timer(unsigned long data)
 		bp->fw_drv_pulse_wr_seq &= DRV_PULSE_SEQ_MASK;
 		/* TBD - add SYSTEM_TIME */
 		drv_pulse = bp->fw_drv_pulse_wr_seq;
-		SHMEM_WR(bp, func_mb[func].drv_pulse_mb, drv_pulse);
+		SHMEM_WR(bp, func_mb[mb_idx].drv_pulse_mb, drv_pulse);
 
-		mcp_pulse = (SHMEM_RD(bp, func_mb[func].mcp_pulse_mb) &
+		mcp_pulse = (SHMEM_RD(bp, func_mb[mb_idx].mcp_pulse_mb) &
 			     MCP_PULSE_SEQ_MASK);
 		/* The delta between driver pulse and mcp response
 		 * should be 1 (before mcp response) or 0 (after mcp response)
@@ -3539,17 +3843,26 @@ static inline void bnx2x_zero_fp_sb(struct bnx2x *bp, int fw_sb_id)
 {
 	u32 *sb_data_p;
 	u32 data_size = 0;
+	struct hc_status_block_data_e2 sb_data_e2;
 	struct hc_status_block_data_e1x sb_data_e1x;
 
 	/* disable the function first */
-	memset(&sb_data_e1x, 0,
-	       sizeof(struct hc_status_block_data_e1x));
-	sb_data_e1x.common.p_func.pf_id = HC_FUNCTION_DISABLED;
-	sb_data_e1x.common.p_func.vf_id = HC_FUNCTION_DISABLED;
-	sb_data_e1x.common.p_func.vf_valid = false;
-	sb_data_p = (u32 *)&sb_data_e1x;
-	data_size = sizeof(struct hc_status_block_data_e1x)/sizeof(u32);
-
+	if (CHIP_IS_E2(bp)) {
+		memset(&sb_data_e2, 0, sizeof(struct hc_status_block_data_e2));
+		sb_data_e2.common.p_func.pf_id = HC_FUNCTION_DISABLED;
+		sb_data_e2.common.p_func.vf_id = HC_FUNCTION_DISABLED;
+		sb_data_e2.common.p_func.vf_valid = false;
+		sb_data_p = (u32 *)&sb_data_e2;
+		data_size = sizeof(struct hc_status_block_data_e2)/sizeof(u32);
+	} else {
+		memset(&sb_data_e1x, 0,
+		       sizeof(struct hc_status_block_data_e1x));
+		sb_data_e1x.common.p_func.pf_id = HC_FUNCTION_DISABLED;
+		sb_data_e1x.common.p_func.vf_id = HC_FUNCTION_DISABLED;
+		sb_data_e1x.common.p_func.vf_valid = false;
+		sb_data_p = (u32 *)&sb_data_e1x;
+		data_size = sizeof(struct hc_status_block_data_e1x)/sizeof(u32);
+	}
 	bnx2x_wr_fp_sb_data(bp, fw_sb_id, sb_data_p, data_size);
 
 	bnx2x_fill(bp, BAR_CSTRORM_INTMEM +
@@ -3610,30 +3923,48 @@ void bnx2x_init_sb(struct bnx2x *bp, dma_addr_t mapping, int vfid,
 {
 	int igu_seg_id;
 
+	struct hc_status_block_data_e2 sb_data_e2;
 	struct hc_status_block_data_e1x sb_data_e1x;
 	struct hc_status_block_sm  *hc_sm_p;
 	struct hc_index_data *hc_index_p;
 	int data_size;
 	u32 *sb_data_p;
 
-	igu_seg_id = HC_SEG_ACCESS_NORM;
+	if (CHIP_INT_MODE_IS_BC(bp))
+		igu_seg_id = HC_SEG_ACCESS_NORM;
+	else
+		igu_seg_id = IGU_SEG_ACCESS_NORM;
 
 	bnx2x_zero_fp_sb(bp, fw_sb_id);
 
-	memset(&sb_data_e1x, 0,
-	       sizeof(struct hc_status_block_data_e1x));
-	sb_data_e1x.common.p_func.pf_id = BP_FUNC(bp);
-	sb_data_e1x.common.p_func.vf_id = 0xff;
-	sb_data_e1x.common.p_func.vf_valid = false;
-	sb_data_e1x.common.p_func.vnic_id = BP_E1HVN(bp);
-	sb_data_e1x.common.same_igu_sb_1b = true;
-	sb_data_e1x.common.host_sb_addr.hi = U64_HI(mapping);
-	sb_data_e1x.common.host_sb_addr.lo = U64_LO(mapping);
-	hc_sm_p = sb_data_e1x.common.state_machine;
-	hc_index_p = sb_data_e1x.index_data;
-	sb_data_p = (u32 *)&sb_data_e1x;
-	data_size = sizeof(struct hc_status_block_data_e1x)/sizeof(u32);
-
+	if (CHIP_IS_E2(bp)) {
+		memset(&sb_data_e2, 0, sizeof(struct hc_status_block_data_e2));
+		sb_data_e2.common.p_func.pf_id = BP_FUNC(bp);
+		sb_data_e2.common.p_func.vf_id = vfid;
+		sb_data_e2.common.p_func.vf_valid = vf_valid;
+		sb_data_e2.common.p_func.vnic_id = BP_VN(bp);
+		sb_data_e2.common.same_igu_sb_1b = true;
+		sb_data_e2.common.host_sb_addr.hi = U64_HI(mapping);
+		sb_data_e2.common.host_sb_addr.lo = U64_LO(mapping);
+		hc_sm_p = sb_data_e2.common.state_machine;
+		hc_index_p = sb_data_e2.index_data;
+		sb_data_p = (u32 *)&sb_data_e2;
+		data_size = sizeof(struct hc_status_block_data_e2)/sizeof(u32);
+	} else {
+		memset(&sb_data_e1x, 0,
+		       sizeof(struct hc_status_block_data_e1x));
+		sb_data_e1x.common.p_func.pf_id = BP_FUNC(bp);
+		sb_data_e1x.common.p_func.vf_id = 0xff;
+		sb_data_e1x.common.p_func.vf_valid = false;
+		sb_data_e1x.common.p_func.vnic_id = BP_VN(bp);
+		sb_data_e1x.common.same_igu_sb_1b = true;
+		sb_data_e1x.common.host_sb_addr.hi = U64_HI(mapping);
+		sb_data_e1x.common.host_sb_addr.lo = U64_LO(mapping);
+		hc_sm_p = sb_data_e1x.common.state_machine;
+		hc_index_p = sb_data_e1x.index_data;
+		sb_data_p = (u32 *)&sb_data_e1x;
+		data_size = sizeof(struct hc_status_block_data_e1x)/sizeof(u32);
+	}
 
 	bnx2x_setup_ndsb_state_machine(&hc_sm_p[SM_RX_ID],
 				       igu_sb_id, igu_seg_id);
@@ -3666,6 +3997,7 @@ static void bnx2x_update_coalesce_sb(struct bnx2x *bp, u16 fw_sb_id,
 	bnx2x_update_coalesce_sb_index(bp, fw_sb_id, C_SB_ETH_TX_CQ_INDEX,
 				    false, tx_usec);
 }
+
 static void bnx2x_init_def_sb(struct bnx2x *bp)
 {
 	struct host_sp_status_block *def_sb = bp->def_status_blk;
@@ -3680,8 +4012,13 @@ static void bnx2x_init_def_sb(struct bnx2x *bp)
 	struct hc_sp_status_block_data sp_sb_data;
 	memset(&sp_sb_data, 0, sizeof(struct hc_sp_status_block_data));
 
-	igu_sp_sb_index = DEF_SB_IGU_ID;
-	igu_seg_id = HC_SEG_ACCESS_DEF;
+	if (CHIP_INT_MODE_IS_BC(bp)) {
+		igu_sp_sb_index = DEF_SB_IGU_ID;
+		igu_seg_id = HC_SEG_ACCESS_DEF;
+	} else {
+		igu_sp_sb_index = bp->igu_dsb_id;
+		igu_seg_id = IGU_SEG_ACCESS_DEF;
+	}
 
 	/* ATTN */
 	section = ((u64)mapping) + offsetof(struct host_sp_status_block,
@@ -3698,12 +4035,29 @@ static void bnx2x_init_def_sb(struct bnx2x *bp)
 		for (sindex = 0; sindex < 4; sindex++)
 			bp->attn_group[index].sig[sindex] =
 			   REG_RD(bp, reg_offset + sindex*0x4 + 0x10*index);
+
+		if (CHIP_IS_E2(bp))
+			/*
+			 * enable5 is separate from the rest of the registers,
+			 * and therefore the address skip is 4
+			 * and not 16 between the different groups
+			 */
+			bp->attn_group[index].sig[4] = REG_RD(bp,
+					reg_offset + 0x10 + 0x4*index);
+		else
+			bp->attn_group[index].sig[4] = 0;
 	}
 
-	reg_offset = (port ? HC_REG_ATTN_MSG1_ADDR_L :
-			     HC_REG_ATTN_MSG0_ADDR_L);
-	REG_WR(bp, reg_offset, U64_LO(section));
-	REG_WR(bp, reg_offset + 4, U64_HI(section));
+	if (bp->common.int_block == INT_BLOCK_HC) {
+		reg_offset = (port ? HC_REG_ATTN_MSG1_ADDR_L :
+				     HC_REG_ATTN_MSG0_ADDR_L);
+
+		REG_WR(bp, reg_offset, U64_LO(section));
+		REG_WR(bp, reg_offset + 4, U64_HI(section));
+	} else if (CHIP_IS_E2(bp)) {
+		REG_WR(bp, IGU_REG_ATTN_MSG_ADDR_L, U64_LO(section));
+		REG_WR(bp, IGU_REG_ATTN_MSG_ADDR_H, U64_HI(section));
+	}
 
 	section = ((u64)mapping) + offsetof(struct host_sp_status_block,
 					    sp_sb);
@@ -3715,7 +4069,7 @@ static void bnx2x_init_def_sb(struct bnx2x *bp)
 	sp_sb_data.igu_sb_id		= igu_sp_sb_index;
 	sp_sb_data.igu_seg_id		= igu_seg_id;
 	sp_sb_data.p_func.pf_id		= func;
-	sp_sb_data.p_func.vnic_id	= BP_E1HVN(bp);
+	sp_sb_data.p_func.vnic_id	= BP_VN(bp);
 	sp_sb_data.p_func.vf_id		= 0xff;
 
 	bnx2x_wr_sp_sb_data(bp, &sp_sb_data);
@@ -3870,6 +4224,11 @@ static void bnx2x_init_internal_common(struct bnx2x *bp)
 	for (i = 0; i < (USTORM_AGG_DATA_SIZE >> 2); i++)
 		REG_WR(bp, BAR_USTRORM_INTMEM +
 		       USTORM_AGG_DATA_OFFSET + i * 4, 0);
+	if (CHIP_IS_E2(bp)) {
+		REG_WR8(bp, BAR_CSTRORM_INTMEM + CSTORM_IGU_MODE_OFFSET,
+			CHIP_INT_MODE_IS_BC(bp) ?
+			HC_IGU_BC_MODE : HC_IGU_NBC_MODE);
+	}
 }
 
 static void bnx2x_init_internal_port(struct bnx2x *bp)
@@ -3881,6 +4240,7 @@ static void bnx2x_init_internal(struct bnx2x *bp, u32 load_code)
 {
 	switch (load_code) {
 	case FW_MSG_CODE_DRV_LOAD_COMMON:
+	case FW_MSG_CODE_DRV_LOAD_COMMON_CHIP:
 		bnx2x_init_internal_common(bp);
 		/* no break */
 
@@ -3911,9 +4271,11 @@ static void bnx2x_init_fp_sb(struct bnx2x *bp, int fp_idx)
 	fp->igu_sb_id = bp->igu_base_sb + fp_idx + CNIC_CONTEXT_USE;
 	/* qZone id equals to FW (per path) client id */
 	fp->cl_qzone_id  = fp->cl_id +
-			   BP_PORT(bp)*(ETH_MAX_RX_CLIENTS_E1H);
+			   BP_PORT(bp)*(CHIP_IS_E2(bp) ? ETH_MAX_RX_CLIENTS_E2 :
+				ETH_MAX_RX_CLIENTS_E1H);
 	/* init shortcut */
-	fp->ustorm_rx_prods_offset =
+	fp->ustorm_rx_prods_offset = CHIP_IS_E2(bp) ?
+			    USTORM_RX_PRODS_E2_OFFSET(fp->cl_qzone_id) :
 			    USTORM_RX_PRODS_E1X_OFFSET(BP_PORT(bp), fp->cl_id);
 	/* Setup SB indicies */
 	fp->rx_cons_sb = BNX2X_RX_SB_INDEX;
@@ -4248,9 +4610,19 @@ static int bnx2x_int_mem_test(struct bnx2x *bp)
 static void enable_blocks_attention(struct bnx2x *bp)
 {
 	REG_WR(bp, PXP_REG_PXP_INT_MASK_0, 0);
-	REG_WR(bp, PXP_REG_PXP_INT_MASK_1, 0);
+	if (CHIP_IS_E2(bp))
+		REG_WR(bp, PXP_REG_PXP_INT_MASK_1, 0x40);
+	else
+		REG_WR(bp, PXP_REG_PXP_INT_MASK_1, 0);
 	REG_WR(bp, DORQ_REG_DORQ_INT_MASK, 0);
 	REG_WR(bp, CFC_REG_CFC_INT_MASK, 0);
+	/*
+	 * mask read length error interrupts in brb for parser
+	 * (parsing unit and 'checksum and crc' unit)
+	 * these errors are legal (PU reads fixed length and CAC can cause
+	 * read length error on truncated packets)
+	 */
+	REG_WR(bp, BRB1_REG_BRB1_INT_MASK, 0xFC00);
 	REG_WR(bp, QM_REG_QM_INT_MASK, 0);
 	REG_WR(bp, TM_REG_TM_INT_MASK, 0);
 	REG_WR(bp, XSDM_REG_XSDM_INT_MASK_0, 0);
@@ -4271,6 +4643,13 @@ static void enable_blocks_attention(struct bnx2x *bp)
 /*	REG_WR(bp, CSEM_REG_CSEM_INT_MASK_1, 0); */
 	if (CHIP_REV_IS_FPGA(bp))
 		REG_WR(bp, PXP2_REG_PXP2_INT_MASK_0, 0x580000);
+	else if (CHIP_IS_E2(bp))
+		REG_WR(bp, PXP2_REG_PXP2_INT_MASK_0,
+			   (PXP2_PXP2_INT_MASK_0_REG_PGL_CPL_OF
+				| PXP2_PXP2_INT_MASK_0_REG_PGL_CPL_AFT
+				| PXP2_PXP2_INT_MASK_0_REG_PGL_PCIE_ATTN
+				| PXP2_PXP2_INT_MASK_0_REG_PGL_READ_BLOCKED
+				| PXP2_PXP2_INT_MASK_0_REG_PGL_WRITE_BLOCKED));
 	else
 		REG_WR(bp, PXP2_REG_PXP2_INT_MASK_0, 0x480000);
 	REG_WR(bp, TSDM_REG_TSDM_INT_MASK_0, 0);
@@ -4288,11 +4667,11 @@ static const struct {
 	u32 addr;
 	u32 mask;
 } bnx2x_parity_mask[] = {
-	{PXP_REG_PXP_PRTY_MASK, 0xffffffff},
-	{PXP2_REG_PXP2_PRTY_MASK_0, 0xffffffff},
-	{PXP2_REG_PXP2_PRTY_MASK_1, 0xffffffff},
-	{HC_REG_HC_PRTY_MASK, 0xffffffff},
-	{MISC_REG_MISC_PRTY_MASK, 0xffffffff},
+	{PXP_REG_PXP_PRTY_MASK,		0x3ffffff},
+	{PXP2_REG_PXP2_PRTY_MASK_0,	0xffffffff},
+	{PXP2_REG_PXP2_PRTY_MASK_1,	0x7f},
+	{HC_REG_HC_PRTY_MASK,		0x7},
+	{MISC_REG_MISC_PRTY_MASK,	0x1},
 	{QM_REG_QM_PRTY_MASK, 0x0},
 	{DORQ_REG_DORQ_PRTY_MASK, 0x0},
 	{GRCBASE_UPB + PB_REG_PB_PRTY_MASK, 0x0},
@@ -4407,23 +4786,97 @@ static void bnx2x_setup_fan_failure_detection(struct bnx2x *bp)
 	REG_WR(bp, MISC_REG_SPIO_EVENT_EN, val);
 }
 
+static void bnx2x_pretend_func(struct bnx2x *bp, u8 pretend_func_num)
+{
+	u32 offset = 0;
+
+	if (CHIP_IS_E1(bp))
+		return;
+	if (CHIP_IS_E1H(bp) && (pretend_func_num >= E1H_FUNC_MAX))
+		return;
+
+	switch (BP_ABS_FUNC(bp)) {
+	case 0:
+		offset = PXP2_REG_PGL_PRETEND_FUNC_F0;
+		break;
+	case 1:
+		offset = PXP2_REG_PGL_PRETEND_FUNC_F1;
+		break;
+	case 2:
+		offset = PXP2_REG_PGL_PRETEND_FUNC_F2;
+		break;
+	case 3:
+		offset = PXP2_REG_PGL_PRETEND_FUNC_F3;
+		break;
+	case 4:
+		offset = PXP2_REG_PGL_PRETEND_FUNC_F4;
+		break;
+	case 5:
+		offset = PXP2_REG_PGL_PRETEND_FUNC_F5;
+		break;
+	case 6:
+		offset = PXP2_REG_PGL_PRETEND_FUNC_F6;
+		break;
+	case 7:
+		offset = PXP2_REG_PGL_PRETEND_FUNC_F7;
+		break;
+	default:
+		return;
+	}
+
+	REG_WR(bp, offset, pretend_func_num);
+	REG_RD(bp, offset);
+	DP(NETIF_MSG_HW, "Pretending to func %d\n", pretend_func_num);
+}
+
+static void bnx2x_pf_disable(struct bnx2x *bp)
+{
+	u32 val = REG_RD(bp, IGU_REG_PF_CONFIGURATION);
+	val &= ~IGU_PF_CONF_FUNC_EN;
+
+	REG_WR(bp, IGU_REG_PF_CONFIGURATION, val);
+	REG_WR(bp, PGLUE_B_REG_INTERNAL_PFID_ENABLE_MASTER, 0);
+	REG_WR(bp, CFC_REG_WEAK_ENABLE_PF, 0);
+}
+
 static int bnx2x_init_hw_common(struct bnx2x *bp, u32 load_code)
 {
 	u32 val, i;
 
-	DP(BNX2X_MSG_MCP, "starting common init  func %d\n", BP_FUNC(bp));
+	DP(BNX2X_MSG_MCP, "starting common init  func %d\n", BP_ABS_FUNC(bp));
 
 	bnx2x_reset_common(bp);
 	REG_WR(bp, GRCBASE_MISC + MISC_REGISTERS_RESET_REG_1_SET, 0xffffffff);
 	REG_WR(bp, GRCBASE_MISC + MISC_REGISTERS_RESET_REG_2_SET, 0xfffc);
 
 	bnx2x_init_block(bp, MISC_BLOCK, COMMON_STAGE);
-	if (CHIP_IS_E1H(bp))
+	if (!CHIP_IS_E1(bp))
 		REG_WR(bp, MISC_REG_E1HMF_MODE, IS_MF(bp));
 
-	REG_WR(bp, MISC_REG_LCPLL_CTRL_REG_2, 0x100);
-	msleep(30);
-	REG_WR(bp, MISC_REG_LCPLL_CTRL_REG_2, 0x0);
+	if (CHIP_IS_E2(bp)) {
+		u8 fid;
+
+		/**
+		 * 4-port mode or 2-port mode we need to turn of master-enable
+		 * for everyone, after that, turn it back on for self.
+		 * so, we disregard multi-function or not, and always disable
+		 * for all functions on the given path, this means 0,2,4,6 for
+		 * path 0 and 1,3,5,7 for path 1
+		 */
+		for (fid = BP_PATH(bp); fid  < E2_FUNC_MAX*2; fid += 2) {
+			if (fid == BP_ABS_FUNC(bp)) {
+				REG_WR(bp,
+				    PGLUE_B_REG_INTERNAL_PFID_ENABLE_MASTER,
+				    1);
+				continue;
+			}
+
+			bnx2x_pretend_func(bp, fid);
+			/* clear pf enable */
+			bnx2x_pf_disable(bp);
+			bnx2x_pretend_func(bp, BP_ABS_FUNC(bp));
+		}
+	}
 
 	bnx2x_init_block(bp, PXP_BLOCK, COMMON_STAGE);
 	if (CHIP_IS_E1(bp)) {
@@ -4471,9 +4924,65 @@ static int bnx2x_init_hw_common(struct bnx2x *bp, u32 load_code)
 		return -EBUSY;
 	}
 
+	/* Timers bug workaround E2 only. We need to set the entire ILT to
+	 * have entries with value "0" and valid bit on.
+	 * This needs to be done by the first PF that is loaded in a path
+	 * (i.e. common phase)
+	 */
+	if (CHIP_IS_E2(bp)) {
+		struct ilt_client_info ilt_cli;
+		struct bnx2x_ilt ilt;
+		memset(&ilt_cli, 0, sizeof(struct ilt_client_info));
+		memset(&ilt, 0, sizeof(struct bnx2x_ilt));
+
+		/* initalize dummy TM client */
+		ilt_cli.start = 0;
+		ilt_cli.end = ILT_NUM_PAGE_ENTRIES - 1;
+		ilt_cli.client_num = ILT_CLIENT_TM;
+
+		/* Step 1: set zeroes to all ilt page entries with valid bit on
+		 * Step 2: set the timers first/last ilt entry to point
+		 * to the entire range to prevent ILT range error for 3rd/4th
+		 * vnic	(this code assumes existance of the vnic)
+		 *
+		 * both steps performed by call to bnx2x_ilt_client_init_op()
+		 * with dummy TM client
+		 *
+		 * we must use pretend since PXP2_REG_RQ_##blk##_FIRST_ILT
+		 * and his brother are split registers
+		 */
+		bnx2x_pretend_func(bp, (BP_PATH(bp) + 6));
+		bnx2x_ilt_client_init_op_ilt(bp, &ilt, &ilt_cli, INITOP_CLEAR);
+		bnx2x_pretend_func(bp, BP_ABS_FUNC(bp));
+
+		REG_WR(bp, PXP2_REG_RQ_DRAM_ALIGN, BNX2X_PXP_DRAM_ALIGN);
+		REG_WR(bp, PXP2_REG_RQ_DRAM_ALIGN_RD, BNX2X_PXP_DRAM_ALIGN);
+		REG_WR(bp, PXP2_REG_RQ_DRAM_ALIGN_SEL, 1);
+	}
+
+
 	REG_WR(bp, PXP2_REG_RQ_DISABLE_INPUTS, 0);
 	REG_WR(bp, PXP2_REG_RD_DISABLE_INPUTS, 0);
 
+	if (CHIP_IS_E2(bp)) {
+		int factor = CHIP_REV_IS_EMUL(bp) ? 1000 :
+				(CHIP_REV_IS_FPGA(bp) ? 400 : 0);
+		bnx2x_init_block(bp, PGLUE_B_BLOCK, COMMON_STAGE);
+
+		bnx2x_init_block(bp, ATC_BLOCK, COMMON_STAGE);
+
+		/* let the HW do it's magic ... */
+		do {
+			msleep(200);
+			val = REG_RD(bp, ATC_REG_ATC_INIT_DONE);
+		} while (factor-- && (val != 1));
+
+		if (val != 1) {
+			BNX2X_ERR("ATC_INIT failed\n");
+			return -EBUSY;
+		}
+	}
+
 	bnx2x_init_block(bp, DMAE_BLOCK, COMMON_STAGE);
 
 	/* clean the DMAE memory */
@@ -4492,6 +5001,8 @@ static int bnx2x_init_hw_common(struct bnx2x *bp, u32 load_code)
 
 	bnx2x_init_block(bp, QM_BLOCK, COMMON_STAGE);
 
+	if (CHIP_MODE_IS_4_PORT(bp))
+		bnx2x_init_block(bp, QM_4PORT_BLOCK, COMMON_STAGE);
 	/* QM queues pointers table */
 	bnx2x_qm_init_ptr_table(bp, bp->qm_cid_count, INITOP_SET);
 
@@ -4512,14 +5023,26 @@ static int bnx2x_init_hw_common(struct bnx2x *bp, u32 load_code)
 	}
 
 	bnx2x_init_block(bp, BRB1_BLOCK, COMMON_STAGE);
+	if (CHIP_MODE_IS_4_PORT(bp)) {
+		REG_WR(bp, BRB1_REG_FULL_LB_XOFF_THRESHOLD, 248);
+		REG_WR(bp, BRB1_REG_FULL_LB_XON_THRESHOLD, 328);
+	}
+
 	bnx2x_init_block(bp, PRS_BLOCK, COMMON_STAGE);
 	REG_WR(bp, PRS_REG_A_PRSU_20, 0xf);
 #ifndef BCM_CNIC
 	/* set NIC mode */
 	REG_WR(bp, PRS_REG_NIC_MODE, 1);
 #endif
-	if (CHIP_IS_E1H(bp))
+	if (!CHIP_IS_E1(bp))
 		REG_WR(bp, PRS_REG_E1HOV_MODE, IS_MF(bp));
+	if (CHIP_IS_E2(bp)) {
+		/* Bit-map indicating which L2 hdrs may appear after the
+		   basic Ethernet header */
+		int has_ovlan = IS_MF(bp);
+		REG_WR(bp, PRS_REG_HDRS_AFTER_BASIC, (has_ovlan ? 7 : 6));
+		REG_WR(bp, PRS_REG_MUST_HAVE_HDRS, (has_ovlan ? 1 : 0));
+	}
 
 	bnx2x_init_block(bp, TSDM_BLOCK, COMMON_STAGE);
 	bnx2x_init_block(bp, CSDM_BLOCK, COMMON_STAGE);
@@ -4536,6 +5059,9 @@ static int bnx2x_init_hw_common(struct bnx2x *bp, u32 load_code)
 	bnx2x_init_block(bp, CSEM_BLOCK, COMMON_STAGE);
 	bnx2x_init_block(bp, XSEM_BLOCK, COMMON_STAGE);
 
+	if (CHIP_MODE_IS_4_PORT(bp))
+		bnx2x_init_block(bp, XSEM_4PORT_BLOCK, COMMON_STAGE);
+
 	/* sync semi rtc */
 	REG_WR(bp, GRCBASE_MISC + MISC_REGISTERS_RESET_REG_1_CLEAR,
 	       0x80000000);
@@ -4546,6 +5072,12 @@ static int bnx2x_init_hw_common(struct bnx2x *bp, u32 load_code)
 	bnx2x_init_block(bp, XPB_BLOCK, COMMON_STAGE);
 	bnx2x_init_block(bp, PBF_BLOCK, COMMON_STAGE);
 
+	if (CHIP_IS_E2(bp)) {
+		int has_ovlan = IS_MF(bp);
+		REG_WR(bp, PBF_REG_HDRS_AFTER_BASIC, (has_ovlan ? 7 : 6));
+		REG_WR(bp, PBF_REG_MUST_HAVE_HDRS, (has_ovlan ? 1 : 0));
+	}
+
 	REG_WR(bp, SRC_REG_SOFT_RST, 1);
 	for (i = SRC_REG_KEYRSS0_0; i <= SRC_REG_KEYRSS1_9; i += 4)
 		REG_WR(bp, i, random32());
@@ -4583,6 +5115,11 @@ static int bnx2x_init_hw_common(struct bnx2x *bp, u32 load_code)
 	REG_WR(bp, CFC_REG_DEBUG0, 0x20020000);
 
 	bnx2x_init_block(bp, HC_BLOCK, COMMON_STAGE);
+
+	if (CHIP_IS_E2(bp) && BP_NOMCP(bp))
+		REG_WR(bp, IGU_REG_RESET_MEMORIES, 0x36);
+
+	bnx2x_init_block(bp, IGU_BLOCK, COMMON_STAGE);
 	bnx2x_init_block(bp, MISC_AEU_BLOCK, COMMON_STAGE);
 
 	bnx2x_init_block(bp, PXPCS_BLOCK, COMMON_STAGE);
@@ -4590,16 +5127,35 @@ static int bnx2x_init_hw_common(struct bnx2x *bp, u32 load_code)
 	REG_WR(bp, 0x2814, 0xffffffff);
 	REG_WR(bp, 0x3820, 0xffffffff);
 
+	if (CHIP_IS_E2(bp)) {
+		REG_WR(bp, PCICFG_OFFSET + PXPCS_TL_CONTROL_5,
+			   (PXPCS_TL_CONTROL_5_ERR_UNSPPORT1 |
+				PXPCS_TL_CONTROL_5_ERR_UNSPPORT));
+		REG_WR(bp, PCICFG_OFFSET + PXPCS_TL_FUNC345_STAT,
+			   (PXPCS_TL_FUNC345_STAT_ERR_UNSPPORT4 |
+				PXPCS_TL_FUNC345_STAT_ERR_UNSPPORT3 |
+				PXPCS_TL_FUNC345_STAT_ERR_UNSPPORT2));
+		REG_WR(bp, PCICFG_OFFSET + PXPCS_TL_FUNC678_STAT,
+			   (PXPCS_TL_FUNC678_STAT_ERR_UNSPPORT7 |
+				PXPCS_TL_FUNC678_STAT_ERR_UNSPPORT6 |
+				PXPCS_TL_FUNC678_STAT_ERR_UNSPPORT5));
+	}
+
 	bnx2x_init_block(bp, EMAC0_BLOCK, COMMON_STAGE);
 	bnx2x_init_block(bp, EMAC1_BLOCK, COMMON_STAGE);
 	bnx2x_init_block(bp, DBU_BLOCK, COMMON_STAGE);
 	bnx2x_init_block(bp, DBG_BLOCK, COMMON_STAGE);
 
 	bnx2x_init_block(bp, NIG_BLOCK, COMMON_STAGE);
-	if (CHIP_IS_E1H(bp)) {
+	if (!CHIP_IS_E1(bp)) {
 		REG_WR(bp, NIG_REG_LLH_MF_MODE, IS_MF(bp));
 		REG_WR(bp, NIG_REG_LLH_E1HOV_MODE, IS_MF(bp));
 	}
+	if (CHIP_IS_E2(bp)) {
+		/* Bit-map indicating which L2 hdrs may appear after the
+		   basic Ethernet header */
+		REG_WR(bp, NIG_REG_P0_HDRS_AFTER_BASIC, (IS_MF(bp) ? 7 : 6));
+	}
 
 	if (CHIP_REV_IS_SLOW(bp))
 		msleep(200);
@@ -4622,15 +5178,17 @@ static int bnx2x_init_hw_common(struct bnx2x *bp, u32 load_code)
 	}
 	REG_WR(bp, CFC_REG_DEBUG0, 0);
 
-	/* read NIG statistic
-	   to see if this is our first up since powerup */
-	bnx2x_read_dmae(bp, NIG_REG_STAT2_BRB_OCTET, 2);
-	val = *bnx2x_sp(bp, wb_data[0]);
+	if (CHIP_IS_E1(bp)) {
+		/* read NIG statistic
+		   to see if this is our first up since powerup */
+		bnx2x_read_dmae(bp, NIG_REG_STAT2_BRB_OCTET, 2);
+		val = *bnx2x_sp(bp, wb_data[0]);
 
-	/* do internal memory self test */
-	if ((CHIP_IS_E1(bp)) && (val == 0) && bnx2x_int_mem_test(bp)) {
-		BNX2X_ERR("internal mem self test failed\n");
-		return -EBUSY;
+		/* do internal memory self test */
+		if ((val == 0) && bnx2x_int_mem_test(bp)) {
+			BNX2X_ERR("internal mem self test failed\n");
+			return -EBUSY;
+		}
 	}
 
 	bp->port.need_hw_lock = bnx2x_hw_lock_required(bp,
@@ -4647,10 +5205,23 @@ static int bnx2x_init_hw_common(struct bnx2x *bp, u32 load_code)
 		enable_blocks_parity(bp);
 
 	if (!BP_NOMCP(bp)) {
-		bnx2x_acquire_phy_lock(bp);
-		bnx2x_common_init_phy(bp, bp->common.shmem_base,
-				      bp->common.shmem2_base);
-		bnx2x_release_phy_lock(bp);
+		/* In E2 2-PORT mode, same ext phy is used for the two paths */
+		if ((load_code == FW_MSG_CODE_DRV_LOAD_COMMON_CHIP) ||
+		    CHIP_IS_E1x(bp)) {
+			u32 shmem_base[2], shmem2_base[2];
+			shmem_base[0] =  bp->common.shmem_base;
+			shmem2_base[0] = bp->common.shmem2_base;
+			if (CHIP_IS_E2(bp)) {
+				shmem_base[1] =
+					SHMEM2_RD(bp, other_shmem_base_addr);
+				shmem2_base[1] =
+					SHMEM2_RD(bp, other_shmem2_base_addr);
+			}
+			bnx2x_acquire_phy_lock(bp);
+			bnx2x_common_init_phy(bp, shmem_base, shmem2_base,
+					      bp->common.chip_id);
+			bnx2x_release_phy_lock(bp);
+		}
 	} else
 		BNX2X_ERR("Bootcode is missing - can not initialize link\n");
 
@@ -4671,6 +5242,14 @@ static int bnx2x_init_hw_port(struct bnx2x *bp)
 	bnx2x_init_block(bp, PXP_BLOCK, init_stage);
 	bnx2x_init_block(bp, PXP2_BLOCK, init_stage);
 
+	/* Timers bug workaround: disables the pf_master bit in pglue at
+	 * common phase, we need to enable it here before any dmae access are
+	 * attempted. Therefore we manually added the enable-master to the
+	 * port phase (it also happens in the function phase)
+	 */
+	if (CHIP_IS_E2(bp))
+		REG_WR(bp, PGLUE_B_REG_INTERNAL_PFID_ENABLE_MASTER, 1);
+
 	bnx2x_init_block(bp, TCM_BLOCK, init_stage);
 	bnx2x_init_block(bp, UCM_BLOCK, init_stage);
 	bnx2x_init_block(bp, CCM_BLOCK, init_stage);
@@ -4687,29 +5266,41 @@ static int bnx2x_init_hw_port(struct bnx2x *bp)
 
 	bnx2x_init_block(bp, DQ_BLOCK, init_stage);
 
-	bnx2x_init_block(bp, BRB1_BLOCK, init_stage);
-	if (CHIP_REV_IS_SLOW(bp) && !CHIP_IS_E1H(bp)) {
-		/* no pause for emulation and FPGA */
-		low = 0;
-		high = 513;
-	} else {
-		if (IS_MF(bp))
-			low = ((bp->flags & ONE_PORT_FLAG) ? 160 : 246);
-		else if (bp->dev->mtu > 4096) {
-			if (bp->flags & ONE_PORT_FLAG)
-				low = 160;
-			else {
-				val = bp->dev->mtu;
-				/* (24*1024 + val*4)/256 */
-				low = 96 + (val/64) + ((val % 64) ? 1 : 0);
-			}
-		} else
-			low = ((bp->flags & ONE_PORT_FLAG) ? 80 : 160);
-		high = low + 56;	/* 14*1024/256 */
+	if (CHIP_MODE_IS_4_PORT(bp))
+		bnx2x_init_block(bp, QM_4PORT_BLOCK, init_stage);
+
+	if (CHIP_IS_E1(bp) || CHIP_IS_E1H(bp)) {
+		bnx2x_init_block(bp, BRB1_BLOCK, init_stage);
+		if (CHIP_REV_IS_SLOW(bp) && CHIP_IS_E1(bp)) {
+			/* no pause for emulation and FPGA */
+			low = 0;
+			high = 513;
+		} else {
+			if (IS_MF(bp))
+				low = ((bp->flags & ONE_PORT_FLAG) ? 160 : 246);
+			else if (bp->dev->mtu > 4096) {
+				if (bp->flags & ONE_PORT_FLAG)
+					low = 160;
+				else {
+					val = bp->dev->mtu;
+					/* (24*1024 + val*4)/256 */
+					low = 96 + (val/64) +
+							((val % 64) ? 1 : 0);
+				}
+			} else
+				low = ((bp->flags & ONE_PORT_FLAG) ? 80 : 160);
+			high = low + 56;	/* 14*1024/256 */
+		}
+		REG_WR(bp, BRB1_REG_PAUSE_LOW_THRESHOLD_0 + port*4, low);
+		REG_WR(bp, BRB1_REG_PAUSE_HIGH_THRESHOLD_0 + port*4, high);
 	}
-	REG_WR(bp, BRB1_REG_PAUSE_LOW_THRESHOLD_0 + port*4, low);
-	REG_WR(bp, BRB1_REG_PAUSE_HIGH_THRESHOLD_0 + port*4, high);
 
+	if (CHIP_MODE_IS_4_PORT(bp)) {
+		REG_WR(bp, BRB1_REG_PAUSE_0_XOFF_THRESHOLD_0 + port*8, 248);
+		REG_WR(bp, BRB1_REG_PAUSE_0_XON_THRESHOLD_0 + port*8, 328);
+		REG_WR(bp, (BP_PORT(bp) ? BRB1_REG_MAC_GUARANTIED_1 :
+					  BRB1_REG_MAC_GUARANTIED_0), 40);
+	}
 
 	bnx2x_init_block(bp, PRS_BLOCK, init_stage);
 
@@ -4722,24 +5313,28 @@ static int bnx2x_init_hw_port(struct bnx2x *bp)
 	bnx2x_init_block(bp, USEM_BLOCK, init_stage);
 	bnx2x_init_block(bp, CSEM_BLOCK, init_stage);
 	bnx2x_init_block(bp, XSEM_BLOCK, init_stage);
+	if (CHIP_MODE_IS_4_PORT(bp))
+		bnx2x_init_block(bp, XSEM_4PORT_BLOCK, init_stage);
 
 	bnx2x_init_block(bp, UPB_BLOCK, init_stage);
 	bnx2x_init_block(bp, XPB_BLOCK, init_stage);
 
 	bnx2x_init_block(bp, PBF_BLOCK, init_stage);
 
-	/* configure PBF to work without PAUSE mtu 9000 */
-	REG_WR(bp, PBF_REG_P0_PAUSE_ENABLE + port*4, 0);
+	if (!CHIP_IS_E2(bp)) {
+		/* configure PBF to work without PAUSE mtu 9000 */
+		REG_WR(bp, PBF_REG_P0_PAUSE_ENABLE + port*4, 0);
 
-	/* update threshold */
-	REG_WR(bp, PBF_REG_P0_ARB_THRSH + port*4, (9040/16));
-	/* update init credit */
-	REG_WR(bp, PBF_REG_P0_INIT_CRD + port*4, (9040/16) + 553 - 22);
+		/* update threshold */
+		REG_WR(bp, PBF_REG_P0_ARB_THRSH + port*4, (9040/16));
+		/* update init credit */
+		REG_WR(bp, PBF_REG_P0_INIT_CRD + port*4, (9040/16) + 553 - 22);
 
-	/* probe changes */
-	REG_WR(bp, PBF_REG_INIT_P0 + port*4, 1);
-	msleep(5);
-	REG_WR(bp, PBF_REG_INIT_P0 + port*4, 0);
+		/* probe changes */
+		REG_WR(bp, PBF_REG_INIT_P0 + port*4, 1);
+		udelay(50);
+		REG_WR(bp, PBF_REG_INIT_P0 + port*4, 0);
+	}
 
 #ifdef BCM_CNIC
 	bnx2x_init_block(bp, SRCH_BLOCK, init_stage);
@@ -4753,6 +5348,8 @@ static int bnx2x_init_hw_port(struct bnx2x *bp)
 	}
 	bnx2x_init_block(bp, HC_BLOCK, init_stage);
 
+	bnx2x_init_block(bp, IGU_BLOCK, init_stage);
+
 	bnx2x_init_block(bp, MISC_AEU_BLOCK, init_stage);
 	/* init aeu_mask_attn_func_0/1:
 	 *  - SF mode: bits 3-7 are masked. only bits 0-2 are in use
@@ -4771,11 +5368,25 @@ static int bnx2x_init_hw_port(struct bnx2x *bp)
 
 	REG_WR(bp, NIG_REG_XGXS_SERDES0_MODE_SEL + port*4, 1);
 
-	if (CHIP_IS_E1H(bp)) {
+	if (!CHIP_IS_E1(bp)) {
 		/* 0x2 disable mf_ov, 0x1 enable */
 		REG_WR(bp, NIG_REG_LLH0_BRB1_DRV_MASK_MF + port*4,
 		       (IS_MF(bp) ? 0x1 : 0x2));
 
+		if (CHIP_IS_E2(bp)) {
+			val = 0;
+			switch (bp->mf_mode) {
+			case MULTI_FUNCTION_SD:
+				val = 1;
+				break;
+			case MULTI_FUNCTION_SI:
+				val = 2;
+				break;
+			}
+
+			REG_WR(bp, (BP_PORT(bp) ? NIG_REG_LLH1_CLS_TYPE :
+						  NIG_REG_LLH0_CLS_TYPE), val);
+		}
 		{
 			REG_WR(bp, NIG_REG_LLFC_ENABLE_0 + port*4, 0);
 			REG_WR(bp, NIG_REG_LLFC_OUT_EN_0 + port*4, 0);
@@ -4805,14 +5416,26 @@ static void bnx2x_ilt_wr(struct bnx2x *bp, u32 index, dma_addr_t addr)
 {
 	int reg;
 
-	if (CHIP_IS_E1H(bp))
-		reg = PXP2_REG_RQ_ONCHIP_AT_B0 + index*8;
-	else /* E1 */
+	if (CHIP_IS_E1(bp))
 		reg = PXP2_REG_RQ_ONCHIP_AT + index*8;
+	else
+		reg = PXP2_REG_RQ_ONCHIP_AT_B0 + index*8;
 
 	bnx2x_wb_wr(bp, reg, ONCHIP_ADDR1(addr), ONCHIP_ADDR2(addr));
 }
 
+static inline void bnx2x_igu_clear_sb(struct bnx2x *bp, u8 idu_sb_id)
+{
+	bnx2x_igu_clear_sb_gen(bp, idu_sb_id, true /*PF*/);
+}
+
+static inline void bnx2x_clear_func_ilt(struct bnx2x *bp, u32 func)
+{
+	u32 i, base = FUNC_ILT_BASE(func);
+	for (i = base; i < base + ILT_PER_FUNC; i++)
+		bnx2x_ilt_wr(bp, i, 0);
+}
+
 static int bnx2x_init_hw_func(struct bnx2x *bp)
 {
 	int port = BP_PORT(bp);
@@ -4825,10 +5448,12 @@ static int bnx2x_init_hw_func(struct bnx2x *bp)
 	DP(BNX2X_MSG_MCP, "starting func init  func %d\n", func);
 
 	/* set MSI reconfigure capability */
-	addr = (port ? HC_REG_CONFIG_1 : HC_REG_CONFIG_0);
-	val = REG_RD(bp, addr);
-	val |= HC_CONFIG_0_REG_MSI_ATTN_EN_0;
-	REG_WR(bp, addr, val);
+	if (bp->common.int_block == INT_BLOCK_HC) {
+		addr = (port ? HC_REG_CONFIG_1 : HC_REG_CONFIG_0);
+		val = REG_RD(bp, addr);
+		val |= HC_CONFIG_0_REG_MSI_ATTN_EN_0;
+		REG_WR(bp, addr, val);
+	}
 
 	ilt = BP_ILT(bp);
 	cdu_ilt_start = ilt->clients[ILT_CLIENT_CDU].start;
@@ -4854,10 +5479,38 @@ static int bnx2x_init_hw_func(struct bnx2x *bp)
 	REG_WR(bp, PRS_REG_NIC_MODE, 1);
 #endif  /* BCM_CNIC */
 
+	if (CHIP_IS_E2(bp)) {
+		u32 pf_conf = IGU_PF_CONF_FUNC_EN;
+
+		/* Turn on a single ISR mode in IGU if driver is going to use
+		 * INT#x or MSI
+		 */
+		if (!(bp->flags & USING_MSIX_FLAG))
+			pf_conf |= IGU_PF_CONF_SINGLE_ISR_EN;
+		/*
+		 * Timers workaround bug: function init part.
+		 * Need to wait 20msec after initializing ILT,
+		 * needed to make sure there are no requests in
+		 * one of the PXP internal queues with "old" ILT addresses
+		 */
+		msleep(20);
+		/*
+		 * Master enable - Due to WB DMAE writes performed before this
+		 * register is re-initialized as part of the regular function
+		 * init
+		 */
+		REG_WR(bp, PGLUE_B_REG_INTERNAL_PFID_ENABLE_MASTER, 1);
+		/* Enable the function in IGU */
+		REG_WR(bp, IGU_REG_PF_CONFIGURATION, pf_conf);
+	}
+
 	bp->dmae_ready = 1;
 
 	bnx2x_init_block(bp, PGLUE_B_BLOCK, FUNC0_STAGE + func);
 
+	if (CHIP_IS_E2(bp))
+		REG_WR(bp, PGLUE_B_REG_WAS_ERROR_PF_7_0_CLR, func);
+
 	bnx2x_init_block(bp, MISC_BLOCK, FUNC0_STAGE + func);
 	bnx2x_init_block(bp, TCM_BLOCK, FUNC0_STAGE + func);
 	bnx2x_init_block(bp, UCM_BLOCK, FUNC0_STAGE + func);
@@ -4868,7 +5521,24 @@ static int bnx2x_init_hw_func(struct bnx2x *bp)
 	bnx2x_init_block(bp, CSEM_BLOCK, FUNC0_STAGE + func);
 	bnx2x_init_block(bp, XSEM_BLOCK, FUNC0_STAGE + func);
 
+	if (CHIP_IS_E2(bp)) {
+		REG_WR(bp, BAR_XSTRORM_INTMEM + XSTORM_PATH_ID_OFFSET,
+								BP_PATH(bp));
+		REG_WR(bp, BAR_CSTRORM_INTMEM + CSTORM_PATH_ID_OFFSET,
+								BP_PATH(bp));
+	}
+
+	if (CHIP_MODE_IS_4_PORT(bp))
+		bnx2x_init_block(bp, XSEM_4PORT_BLOCK, FUNC0_STAGE + func);
+
+	if (CHIP_IS_E2(bp))
+		REG_WR(bp, QM_REG_PF_EN, 1);
+
 	bnx2x_init_block(bp, QM_BLOCK, FUNC0_STAGE + func);
+
+	if (CHIP_MODE_IS_4_PORT(bp))
+		bnx2x_init_block(bp, QM_4PORT_BLOCK, FUNC0_STAGE + func);
+
 	bnx2x_init_block(bp, TIMERS_BLOCK, FUNC0_STAGE + func);
 	bnx2x_init_block(bp, DQ_BLOCK, FUNC0_STAGE + func);
 	bnx2x_init_block(bp, BRB1_BLOCK, FUNC0_STAGE + func);
@@ -4880,10 +5550,16 @@ static int bnx2x_init_hw_func(struct bnx2x *bp)
 	bnx2x_init_block(bp, UPB_BLOCK, FUNC0_STAGE + func);
 	bnx2x_init_block(bp, XPB_BLOCK, FUNC0_STAGE + func);
 	bnx2x_init_block(bp, PBF_BLOCK, FUNC0_STAGE + func);
+	if (CHIP_IS_E2(bp))
+		REG_WR(bp, PBF_REG_DISABLE_PF, 0);
+
 	bnx2x_init_block(bp, CDU_BLOCK, FUNC0_STAGE + func);
 
 	bnx2x_init_block(bp, CFC_BLOCK, FUNC0_STAGE + func);
 
+	if (CHIP_IS_E2(bp))
+		REG_WR(bp, CFC_REG_WEAK_ENABLE_PF, 1);
+
 	if (IS_MF(bp)) {
 		REG_WR(bp, NIG_REG_LLH0_FUNC_EN + port*8, 1);
 		REG_WR(bp, NIG_REG_LLH0_FUNC_VLAN_ID + port*8, bp->mf_ov);
@@ -4892,13 +5568,117 @@ static int bnx2x_init_hw_func(struct bnx2x *bp)
 	bnx2x_init_block(bp, MISC_AEU_BLOCK, FUNC0_STAGE + func);
 
 	/* HC init per function */
-	if (CHIP_IS_E1H(bp)) {
+	if (bp->common.int_block == INT_BLOCK_HC) {
+		if (CHIP_IS_E1H(bp)) {
+			REG_WR(bp, MISC_REG_AEU_GENERAL_ATTN_12 + func*4, 0);
+
+			REG_WR(bp, HC_REG_LEADING_EDGE_0 + port*8, 0);
+			REG_WR(bp, HC_REG_TRAILING_EDGE_0 + port*8, 0);
+		}
+		bnx2x_init_block(bp, HC_BLOCK, FUNC0_STAGE + func);
+
+	} else {
+		int num_segs, sb_idx, prod_offset;
+
 		REG_WR(bp, MISC_REG_AEU_GENERAL_ATTN_12 + func*4, 0);
 
-		REG_WR(bp, HC_REG_LEADING_EDGE_0 + port*8, 0);
-		REG_WR(bp, HC_REG_TRAILING_EDGE_0 + port*8, 0);
+		if (CHIP_IS_E2(bp)) {
+			REG_WR(bp, IGU_REG_LEADING_EDGE_LATCH, 0);
+			REG_WR(bp, IGU_REG_TRAILING_EDGE_LATCH, 0);
+		}
+
+		bnx2x_init_block(bp, IGU_BLOCK, FUNC0_STAGE + func);
+
+		if (CHIP_IS_E2(bp)) {
+			int dsb_idx = 0;
+			/**
+			 * Producer memory:
+			 * E2 mode: address 0-135 match to the mapping memory;
+			 * 136 - PF0 default prod; 137 - PF1 default prod;
+			 * 138 - PF2 default prod; 139 - PF3 default prod;
+			 * 140 - PF0 attn prod;    141 - PF1 attn prod;
+			 * 142 - PF2 attn prod;    143 - PF3 attn prod;
+			 * 144-147 reserved.
+			 *
+			 * E1.5 mode - In backward compatible mode;
+			 * for non default SB; each even line in the memory
+			 * holds the U producer and each odd line hold
+			 * the C producer. The first 128 producers are for
+			 * NDSB (PF0 - 0-31; PF1 - 32-63 and so on). The last 20
+			 * producers are for the DSB for each PF.
+			 * Each PF has five segments: (the order inside each
+			 * segment is PF0; PF1; PF2; PF3) - 128-131 U prods;
+			 * 132-135 C prods; 136-139 X prods; 140-143 T prods;
+			 * 144-147 attn prods;
+			 */
+			/* non-default-status-blocks */
+			num_segs = CHIP_INT_MODE_IS_BC(bp) ?
+				IGU_BC_NDSB_NUM_SEGS : IGU_NORM_NDSB_NUM_SEGS;
+			for (sb_idx = 0; sb_idx < bp->igu_sb_cnt; sb_idx++) {
+				prod_offset = (bp->igu_base_sb + sb_idx) *
+					num_segs;
+
+				for (i = 0; i < num_segs; i++) {
+					addr = IGU_REG_PROD_CONS_MEMORY +
+							(prod_offset + i) * 4;
+					REG_WR(bp, addr, 0);
+				}
+				/* send consumer update with value 0 */
+				bnx2x_ack_sb(bp, bp->igu_base_sb + sb_idx,
+					     USTORM_ID, 0, IGU_INT_NOP, 1);
+				bnx2x_igu_clear_sb(bp,
+						   bp->igu_base_sb + sb_idx);
+			}
+
+			/* default-status-blocks */
+			num_segs = CHIP_INT_MODE_IS_BC(bp) ?
+				IGU_BC_DSB_NUM_SEGS : IGU_NORM_DSB_NUM_SEGS;
+
+			if (CHIP_MODE_IS_4_PORT(bp))
+				dsb_idx = BP_FUNC(bp);
+			else
+				dsb_idx = BP_E1HVN(bp);
+
+			prod_offset = (CHIP_INT_MODE_IS_BC(bp) ?
+				       IGU_BC_BASE_DSB_PROD + dsb_idx :
+				       IGU_NORM_BASE_DSB_PROD + dsb_idx);
+
+			for (i = 0; i < (num_segs * E1HVN_MAX);
+			     i += E1HVN_MAX) {
+				addr = IGU_REG_PROD_CONS_MEMORY +
+							(prod_offset + i)*4;
+				REG_WR(bp, addr, 0);
+			}
+			/* send consumer update with 0 */
+			if (CHIP_INT_MODE_IS_BC(bp)) {
+				bnx2x_ack_sb(bp, bp->igu_dsb_id,
+					     USTORM_ID, 0, IGU_INT_NOP, 1);
+				bnx2x_ack_sb(bp, bp->igu_dsb_id,
+					     CSTORM_ID, 0, IGU_INT_NOP, 1);
+				bnx2x_ack_sb(bp, bp->igu_dsb_id,
+					     XSTORM_ID, 0, IGU_INT_NOP, 1);
+				bnx2x_ack_sb(bp, bp->igu_dsb_id,
+					     TSTORM_ID, 0, IGU_INT_NOP, 1);
+				bnx2x_ack_sb(bp, bp->igu_dsb_id,
+					     ATTENTION_ID, 0, IGU_INT_NOP, 1);
+			} else {
+				bnx2x_ack_sb(bp, bp->igu_dsb_id,
+					     USTORM_ID, 0, IGU_INT_NOP, 1);
+				bnx2x_ack_sb(bp, bp->igu_dsb_id,
+					     ATTENTION_ID, 0, IGU_INT_NOP, 1);
+			}
+			bnx2x_igu_clear_sb(bp, bp->igu_dsb_id);
+
+			/* !!! these should become driver const once
+			   rf-tool supports split-68 const */
+			REG_WR(bp, IGU_REG_SB_INT_BEFORE_MASK_LSB, 0);
+			REG_WR(bp, IGU_REG_SB_INT_BEFORE_MASK_MSB, 0);
+			REG_WR(bp, IGU_REG_SB_MASK_LSB, 0);
+			REG_WR(bp, IGU_REG_SB_MASK_MSB, 0);
+			REG_WR(bp, IGU_REG_PBA_STATUS_LSB, 0);
+			REG_WR(bp, IGU_REG_PBA_STATUS_MSB, 0);
+		}
 	}
-	bnx2x_init_block(bp, HC_BLOCK, FUNC0_STAGE + func);
 
 	/* Reset PCIE errors for debug */
 	REG_WR(bp, 0x2114, 0xffffffff);
@@ -4920,7 +5700,7 @@ int bnx2x_init_hw(struct bnx2x *bp, u32 load_code)
 	int rc = 0;
 
 	DP(BNX2X_MSG_MCP, "function %d  load_code %x\n",
-	   BP_FUNC(bp), load_code);
+	   BP_ABS_FUNC(bp), load_code);
 
 	bp->dmae_ready = 0;
 	mutex_init(&bp->dmae_mutex);
@@ -4930,6 +5710,7 @@ int bnx2x_init_hw(struct bnx2x *bp, u32 load_code)
 
 	switch (load_code) {
 	case FW_MSG_CODE_DRV_LOAD_COMMON:
+	case FW_MSG_CODE_DRV_LOAD_COMMON_CHIP:
 		rc = bnx2x_init_hw_common(bp, load_code);
 		if (rc)
 			goto init_hw_err;
@@ -4953,10 +5734,10 @@ int bnx2x_init_hw(struct bnx2x *bp, u32 load_code)
 	}
 
 	if (!BP_NOMCP(bp)) {
-		int func = BP_FUNC(bp);
+		int mb_idx = BP_FW_MB_IDX(bp);
 
 		bp->fw_drv_pulse_wr_seq =
-				(SHMEM_RD(bp, func_mb[func].drv_pulse_mb) &
+				(SHMEM_RD(bp, func_mb[mb_idx].drv_pulse_mb) &
 				 DRV_PULSE_SEQ_MASK);
 		DP(BNX2X_MSG_MCP, "drv_pulse 0x%x\n", bp->fw_drv_pulse_wr_seq);
 	}
@@ -4993,9 +5774,14 @@ void bnx2x_free_mem(struct bnx2x *bp)
 	/* Common */
 	for_each_queue(bp, i) {
 		/* status blocks */
-		BNX2X_PCI_FREE(bnx2x_fp(bp, i, status_blk.e1x_sb),
-			       bnx2x_fp(bp, i, status_blk_mapping),
-			       sizeof(struct host_hc_status_block_e1x));
+		if (CHIP_IS_E2(bp))
+			BNX2X_PCI_FREE(bnx2x_fp(bp, i, status_blk.e2_sb),
+				       bnx2x_fp(bp, i, status_blk_mapping),
+				       sizeof(struct host_hc_status_block_e2));
+		else
+			BNX2X_PCI_FREE(bnx2x_fp(bp, i, status_blk.e1x_sb),
+				       bnx2x_fp(bp, i, status_blk_mapping),
+				       sizeof(struct host_hc_status_block_e1x));
 	}
 	/* Rx */
 	for_each_queue(bp, i) {
@@ -5041,9 +5827,12 @@ void bnx2x_free_mem(struct bnx2x *bp)
 
 	BNX2X_FREE(bp->ilt->lines);
 #ifdef BCM_CNIC
-
-	BNX2X_PCI_FREE(bp->cnic_sb.e1x_sb, bp->cnic_sb_mapping,
-		       sizeof(struct host_hc_status_block_e1x));
+	if (CHIP_IS_E2(bp))
+		BNX2X_PCI_FREE(bp->cnic_sb.e2_sb, bp->cnic_sb_mapping,
+			       sizeof(struct host_hc_status_block_e2));
+	else
+		BNX2X_PCI_FREE(bp->cnic_sb.e1x_sb, bp->cnic_sb_mapping,
+			       sizeof(struct host_hc_status_block_e1x));
 	BNX2X_PCI_FREE(bp->t2, bp->t2_mapping, SRC_T2_SZ);
 #endif
 	BNX2X_PCI_FREE(bp->spq, bp->spq_mapping, BCM_PAGE_SIZE);
@@ -5055,6 +5844,22 @@ void bnx2x_free_mem(struct bnx2x *bp)
 #undef BNX2X_KFREE
 }
 
+static inline void set_sb_shortcuts(struct bnx2x *bp, int index)
+{
+	union host_hc_status_block status_blk = bnx2x_fp(bp, index, status_blk);
+	if (CHIP_IS_E2(bp)) {
+		bnx2x_fp(bp, index, sb_index_values) =
+			(__le16 *)status_blk.e2_sb->sb.index_values;
+		bnx2x_fp(bp, index, sb_running_index) =
+			(__le16 *)status_blk.e2_sb->sb.running_index;
+	} else {
+		bnx2x_fp(bp, index, sb_index_values) =
+			(__le16 *)status_blk.e1x_sb->sb.index_values;
+		bnx2x_fp(bp, index, sb_running_index) =
+			(__le16 *)status_blk.e1x_sb->sb.running_index;
+	}
+}
+
 int bnx2x_alloc_mem(struct bnx2x *bp)
 {
 
@@ -5074,25 +5879,23 @@ int bnx2x_alloc_mem(struct bnx2x *bp)
 	} while (0)
 
 	int i;
-	void *p;
 
 	/* fastpath */
 	/* Common */
 	for_each_queue(bp, i) {
+		union host_hc_status_block *sb = &bnx2x_fp(bp, i, status_blk);
 		bnx2x_fp(bp, i, bp) = bp;
-
 		/* status blocks */
-		BNX2X_PCI_ALLOC(p,
+		if (CHIP_IS_E2(bp))
+			BNX2X_PCI_ALLOC(sb->e2_sb,
+				&bnx2x_fp(bp, i, status_blk_mapping),
+				sizeof(struct host_hc_status_block_e2));
+		else
+			BNX2X_PCI_ALLOC(sb->e1x_sb,
 				&bnx2x_fp(bp, i, status_blk_mapping),
 				sizeof(struct host_hc_status_block_e1x));
 
-		bnx2x_fp(bp, i, status_blk.e1x_sb) =
-				(struct host_hc_status_block_e1x *)p;
-
-		bnx2x_fp(bp, i, sb_index_values) = (__le16 *)
-			(bnx2x_fp(bp, i, status_blk.e1x_sb)->sb.index_values);
-		bnx2x_fp(bp, i, sb_running_index) = (__le16 *)
-			(bnx2x_fp(bp, i, status_blk.e1x_sb)->sb.running_index);
+		set_sb_shortcuts(bp, i);
 	}
 	/* Rx */
 	for_each_queue(bp, i) {
@@ -5129,8 +5932,12 @@ int bnx2x_alloc_mem(struct bnx2x *bp)
 	/* end of fastpath */
 
 #ifdef BCM_CNIC
-	BNX2X_PCI_ALLOC(bp->cnic_sb.e1x_sb, &bp->cnic_sb_mapping,
-			sizeof(struct host_hc_status_block_e1x));
+	if (CHIP_IS_E2(bp))
+		BNX2X_PCI_ALLOC(bp->cnic_sb.e2_sb, &bp->cnic_sb_mapping,
+				sizeof(struct host_hc_status_block_e2));
+	else
+		BNX2X_PCI_ALLOC(bp->cnic_sb.e1x_sb, &bp->cnic_sb_mapping,
+				sizeof(struct host_hc_status_block_e1x));
 
 	/* allocate searcher T2 table */
 	BNX2X_PCI_ALLOC(bp->t2, &bp->t2_mapping, SRC_T2_SZ);
@@ -5210,11 +6017,6 @@ static void bnx2x_set_mac_addr_gen(struct bnx2x *bp, int set, u8 *mac,
 	bp->set_mac_pending = 1;
 	smp_wmb();
 
-	config->hdr.length = 1 + (is_bcast ? 1 : 0);
-	config->hdr.offset = cam_offset;
-	config->hdr.client_id = 0xff;
-	config->hdr.reserved1 = 0;
-
 	config->hdr.length = 1;
 	config->hdr.offset = cam_offset;
 	config->hdr.client_id = 0xff;
@@ -5312,7 +6114,12 @@ int bnx2x_wait_ramrod(struct bnx2x *bp, int state, int idx,
 
 u8 bnx2x_e1h_cam_offset(struct bnx2x *bp, u8 rel_offset)
 {
-	return E1H_FUNC_MAX * rel_offset + BP_FUNC(bp);
+	if (CHIP_IS_E1H(bp))
+		return E1H_FUNC_MAX * rel_offset + BP_FUNC(bp);
+	else if (CHIP_MODE_IS_4_PORT(bp))
+		return BP_FUNC(bp) * 32  + rel_offset;
+	else
+		return BP_VN(bp) * 32  + rel_offset;
 }
 
 void bnx2x_set_eth_mac(struct bnx2x *bp, int set)
@@ -5804,9 +6611,11 @@ static void bnx2x_reset_func(struct bnx2x *bp)
 {
 	int port = BP_PORT(bp);
 	int func = BP_FUNC(bp);
-	int base, i;
+	int i;
 	int pfunc_offset_fp = offsetof(struct hc_sb_data, p_func) +
-			 offsetof(struct hc_status_block_data_e1x, common);
+			(CHIP_IS_E2(bp) ?
+			 offsetof(struct hc_status_block_data_e2, common) :
+			 offsetof(struct hc_status_block_data_e1x, common));
 	int pfunc_offset_sp = offsetof(struct hc_sp_status_block_data, p_func);
 	int pfid_offset = offsetof(struct pci_entity, pf_id);
 
@@ -5839,8 +6648,13 @@ static void bnx2x_reset_func(struct bnx2x *bp)
 		       0);
 
 	/* Configure IGU */
-	REG_WR(bp, HC_REG_LEADING_EDGE_0 + port*8, 0);
-	REG_WR(bp, HC_REG_TRAILING_EDGE_0 + port*8, 0);
+	if (bp->common.int_block == INT_BLOCK_HC) {
+		REG_WR(bp, HC_REG_LEADING_EDGE_0 + port*8, 0);
+		REG_WR(bp, HC_REG_TRAILING_EDGE_0 + port*8, 0);
+	} else {
+		REG_WR(bp, IGU_REG_LEADING_EDGE_LATCH, 0);
+		REG_WR(bp, IGU_REG_TRAILING_EDGE_LATCH, 0);
+	}
 
 #ifdef BCM_CNIC
 	/* Disable Timer scan */
@@ -5856,9 +6670,25 @@ static void bnx2x_reset_func(struct bnx2x *bp)
 	}
 #endif
 	/* Clear ILT */
-	base = FUNC_ILT_BASE(func);
-	for (i = base; i < base + ILT_PER_FUNC; i++)
-		bnx2x_ilt_wr(bp, i, 0);
+	bnx2x_clear_func_ilt(bp, func);
+
+	/* Timers workaround bug for E2: if this is vnic-3,
+	 * we need to set the entire ilt range for this timers.
+	 */
+	if (CHIP_IS_E2(bp) && BP_VN(bp) == 3) {
+		struct ilt_client_info ilt_cli;
+		/* use dummy TM client */
+		memset(&ilt_cli, 0, sizeof(struct ilt_client_info));
+		ilt_cli.start = 0;
+		ilt_cli.end = ILT_NUM_PAGE_ENTRIES - 1;
+		ilt_cli.client_num = ILT_CLIENT_TM;
+
+		bnx2x_ilt_boundry_init_op(bp, &ilt_cli, 0, INITOP_CLEAR);
+	}
+
+	/* this assumes that reset_port() called before reset_func()*/
+	if (CHIP_IS_E2(bp))
+		bnx2x_pf_disable(bp);
 
 	bp->dmae_ready = 0;
 }
@@ -5892,7 +6722,7 @@ static void bnx2x_reset_port(struct bnx2x *bp)
 static void bnx2x_reset_chip(struct bnx2x *bp, u32 reset_code)
 {
 	DP(BNX2X_MSG_MCP, "function %d  reset_code %x\n",
-	   BP_FUNC(bp), reset_code);
+	   BP_ABS_FUNC(bp), reset_code);
 
 	switch (reset_code) {
 	case FW_MSG_CODE_DRV_UNLOAD_COMMON:
@@ -6024,15 +6854,20 @@ unload_error:
 	if (!BP_NOMCP(bp))
 		reset_code = bnx2x_fw_command(bp, reset_code, 0);
 	else {
-		DP(NETIF_MSG_IFDOWN, "NO MCP - load counts      %d, %d, %d\n",
-		   load_count[0], load_count[1], load_count[2]);
-		load_count[0]--;
-		load_count[1 + port]--;
-		DP(NETIF_MSG_IFDOWN, "NO MCP - new load counts  %d, %d, %d\n",
-		   load_count[0], load_count[1], load_count[2]);
-		if (load_count[0] == 0)
+		DP(NETIF_MSG_IFDOWN, "NO MCP - load counts[%d]      "
+				     "%d, %d, %d\n", BP_PATH(bp),
+		   load_count[BP_PATH(bp)][0],
+		   load_count[BP_PATH(bp)][1],
+		   load_count[BP_PATH(bp)][2]);
+		load_count[BP_PATH(bp)][0]--;
+		load_count[BP_PATH(bp)][1 + port]--;
+		DP(NETIF_MSG_IFDOWN, "NO MCP - new load counts[%d]  "
+				     "%d, %d, %d\n", BP_PATH(bp),
+		   load_count[BP_PATH(bp)][0], load_count[BP_PATH(bp)][1],
+		   load_count[BP_PATH(bp)][2]);
+		if (load_count[BP_PATH(bp)][0] == 0)
 			reset_code = FW_MSG_CODE_DRV_UNLOAD_COMMON;
-		else if (load_count[1 + port] == 0)
+		else if (load_count[BP_PATH(bp)][1 + port] == 0)
 			reset_code = FW_MSG_CODE_DRV_UNLOAD_PORT;
 		else
 			reset_code = FW_MSG_CODE_DRV_UNLOAD_FUNCTION;
@@ -6531,39 +7366,23 @@ reset_task_exit:
  * Init service functions
  */
 
-static inline u32 bnx2x_get_pretend_reg(struct bnx2x *bp, int func)
-{
-	switch (func) {
-	case 0: return PXP2_REG_PGL_PRETEND_FUNC_F0;
-	case 1:	return PXP2_REG_PGL_PRETEND_FUNC_F1;
-	case 2:	return PXP2_REG_PGL_PRETEND_FUNC_F2;
-	case 3:	return PXP2_REG_PGL_PRETEND_FUNC_F3;
-	case 4:	return PXP2_REG_PGL_PRETEND_FUNC_F4;
-	case 5:	return PXP2_REG_PGL_PRETEND_FUNC_F5;
-	case 6:	return PXP2_REG_PGL_PRETEND_FUNC_F6;
-	case 7:	return PXP2_REG_PGL_PRETEND_FUNC_F7;
-	default:
-		BNX2X_ERR("Unsupported function index: %d\n", func);
-		return (u32)(-1);
-	}
+u32 bnx2x_get_pretend_reg(struct bnx2x *bp)
+{
+	u32 base = PXP2_REG_PGL_PRETEND_FUNC_F0;
+	u32 stride = PXP2_REG_PGL_PRETEND_FUNC_F1 - base;
+	return base + (BP_ABS_FUNC(bp)) * stride;
 }
 
-static void bnx2x_undi_int_disable_e1h(struct bnx2x *bp, int orig_func)
+static void bnx2x_undi_int_disable_e1h(struct bnx2x *bp)
 {
-	u32 reg = bnx2x_get_pretend_reg(bp, orig_func), new_val;
+	u32 reg = bnx2x_get_pretend_reg(bp);
 
 	/* Flush all outstanding writes */
 	mmiowb();
 
 	/* Pretend to be function 0 */
 	REG_WR(bp, reg, 0);
-	/* Flush the GRC transaction (in the chip) */
-	new_val = REG_RD(bp, reg);
-	if (new_val != 0) {
-		BNX2X_ERR("Hmmm... Pretend register wasn't updated: (0,%d)!\n",
-			  new_val);
-		BUG();
-	}
+	REG_RD(bp, reg);	/* Flush the GRC transaction (in the chip) */
 
 	/* From now we are in the "like-E1" mode */
 	bnx2x_int_disable(bp);
@@ -6571,22 +7390,17 @@ static void bnx2x_undi_int_disable_e1h(struct bnx2x *bp, int orig_func)
 	/* Flush all outstanding writes */
 	mmiowb();
 
-	/* Restore the original funtion settings */
-	REG_WR(bp, reg, orig_func);
-	new_val = REG_RD(bp, reg);
-	if (new_val != orig_func) {
-		BNX2X_ERR("Hmmm... Pretend register wasn't updated: (%d,%d)!\n",
-			  orig_func, new_val);
-		BUG();
-	}
+	/* Restore the original function */
+	REG_WR(bp, reg, BP_ABS_FUNC(bp));
+	REG_RD(bp, reg);
 }
 
-static inline void bnx2x_undi_int_disable(struct bnx2x *bp, int func)
+static inline void bnx2x_undi_int_disable(struct bnx2x *bp)
 {
-	if (CHIP_IS_E1H(bp))
-		bnx2x_undi_int_disable_e1h(bp, func);
-	else
+	if (CHIP_IS_E1(bp))
 		bnx2x_int_disable(bp);
+	else
+		bnx2x_undi_int_disable_e1h(bp);
 }
 
 static void __devinit bnx2x_undi_unload(struct bnx2x *bp)
@@ -6603,8 +7417,8 @@ static void __devinit bnx2x_undi_unload(struct bnx2x *bp)
 		val = REG_RD(bp, DORQ_REG_NORM_CID_OFST);
 		if (val == 0x7) {
 			u32 reset_code = DRV_MSG_CODE_UNLOAD_REQ_WOL_DIS;
-			/* save our func */
-			int func = BP_FUNC(bp);
+			/* save our pf_num */
+			int orig_pf_num = bp->pf_num;
 			u32 swap_en;
 			u32 swap_val;
 
@@ -6614,9 +7428,9 @@ static void __devinit bnx2x_undi_unload(struct bnx2x *bp)
 			BNX2X_DEV_INFO("UNDI is active! reset device\n");
 
 			/* try unload UNDI on port 0 */
-			bp->func = 0;
+			bp->pf_num = 0;
 			bp->fw_seq =
-			       (SHMEM_RD(bp, func_mb[bp->func].drv_mb_header) &
+			      (SHMEM_RD(bp, func_mb[bp->pf_num].drv_mb_header) &
 				DRV_MSG_SEQ_NUMBER_MASK);
 			reset_code = bnx2x_fw_command(bp, reset_code, 0);
 
@@ -6628,9 +7442,9 @@ static void __devinit bnx2x_undi_unload(struct bnx2x *bp)
 						 DRV_MSG_CODE_UNLOAD_DONE, 0);
 
 				/* unload UNDI on port 1 */
-				bp->func = 1;
+				bp->pf_num = 1;
 				bp->fw_seq =
-			       (SHMEM_RD(bp, func_mb[bp->func].drv_mb_header) &
+			      (SHMEM_RD(bp, func_mb[bp->pf_num].drv_mb_header) &
 					DRV_MSG_SEQ_NUMBER_MASK);
 				reset_code = DRV_MSG_CODE_UNLOAD_REQ_WOL_DIS;
 
@@ -6640,7 +7454,7 @@ static void __devinit bnx2x_undi_unload(struct bnx2x *bp)
 			/* now it's safe to release the lock */
 			bnx2x_release_hw_lock(bp, HW_LOCK_RESOURCE_UNDI);
 
-			bnx2x_undi_int_disable(bp, func);
+			bnx2x_undi_int_disable(bp);
 
 			/* close input traffic and wait for it */
 			/* Do not rcv packets to BRB */
@@ -6679,9 +7493,9 @@ static void __devinit bnx2x_undi_unload(struct bnx2x *bp)
 			bnx2x_fw_command(bp, DRV_MSG_CODE_UNLOAD_DONE, 0);
 
 			/* restore our func and fw_seq */
-			bp->func = func;
+			bp->pf_num = orig_pf_num;
 			bp->fw_seq =
-			       (SHMEM_RD(bp, func_mb[bp->func].drv_mb_header) &
+			      (SHMEM_RD(bp, func_mb[bp->pf_num].drv_mb_header) &
 				DRV_MSG_SEQ_NUMBER_MASK);
 
 		} else
@@ -6705,20 +7519,42 @@ static void __devinit bnx2x_get_common_hwinfo(struct bnx2x *bp)
 	val = REG_RD(bp, MISC_REG_BOND_ID);
 	id |= (val & 0xf);
 	bp->common.chip_id = id;
-	bp->link_params.chip_id = bp->common.chip_id;
-	BNX2X_DEV_INFO("chip ID is 0x%x\n", id);
-
-	bp->common.chip_port_mode = CHIP_PORT_MODE_NONE; /* N/A */
 
 	/* Set doorbell size */
 	bp->db_size = (1 << BNX2X_DB_SHIFT);
 
+	if (CHIP_IS_E2(bp)) {
+		val = REG_RD(bp, MISC_REG_PORT4MODE_EN_OVWR);
+		if ((val & 1) == 0)
+			val = REG_RD(bp, MISC_REG_PORT4MODE_EN);
+		else
+			val = (val >> 1) & 1;
+		BNX2X_DEV_INFO("chip is in %s\n", val ? "4_PORT_MODE" :
+						       "2_PORT_MODE");
+		bp->common.chip_port_mode = val ? CHIP_4_PORT_MODE :
+						 CHIP_2_PORT_MODE;
+
+		if (CHIP_MODE_IS_4_PORT(bp))
+			bp->pfid = (bp->pf_num >> 1);	/* 0..3 */
+		else
+			bp->pfid = (bp->pf_num & 0x6);	/* 0, 2, 4, 6 */
+	} else {
+		bp->common.chip_port_mode = CHIP_PORT_MODE_NONE; /* N/A */
+		bp->pfid = bp->pf_num;			/* 0..7 */
+	}
+
 	/*
 	 * set base FW non-default (fast path) status block id, this value is
 	 * used to initialize the fw_sb_id saved on the fp/queue structure to
 	 * determine the id used by the FW.
 	 */
-	bp->base_fw_ndsb = BP_PORT(bp) * FP_SB_MAX_E1x;
+	if (CHIP_IS_E1x(bp))
+		bp->base_fw_ndsb = BP_PORT(bp) * FP_SB_MAX_E1x;
+	else /* E2 */
+		bp->base_fw_ndsb = BP_PORT(bp) * FP_SB_MAX_E2;
+
+	bp->link_params.chip_id = bp->common.chip_id;
+	BNX2X_DEV_INFO("chip ID is 0x%x\n", id);
 
 	val = (REG_RD(bp, 0x2874) & 0x55);
 	if ((bp->common.chip_id & 0x1) ||
@@ -6734,15 +7570,15 @@ static void __devinit bnx2x_get_common_hwinfo(struct bnx2x *bp)
 		       bp->common.flash_size, bp->common.flash_size);
 
 	bp->common.shmem_base = REG_RD(bp, MISC_REG_SHARED_MEM_ADDR);
-	bp->common.shmem2_base = REG_RD(bp, MISC_REG_GENERIC_CR_0);
+	bp->common.shmem2_base = REG_RD(bp, (BP_PATH(bp) ?
+					MISC_REG_GENERIC_CR_1 :
+					MISC_REG_GENERIC_CR_0));
 	bp->link_params.shmem_base = bp->common.shmem_base;
 	bp->link_params.shmem2_base = bp->common.shmem2_base;
 	BNX2X_DEV_INFO("shmem offset 0x%x  shmem2 offset 0x%x\n",
 		       bp->common.shmem_base, bp->common.shmem2_base);
 
-	if (!bp->common.shmem_base ||
-	    (bp->common.shmem_base < 0xA0000) ||
-	    (bp->common.shmem_base >= 0xC0000)) {
+	if (!bp->common.shmem_base) {
 		BNX2X_DEV_INFO("MCP not active\n");
 		bp->flags |= NO_MCP_FLAG;
 		return;
@@ -6751,7 +7587,7 @@ static void __devinit bnx2x_get_common_hwinfo(struct bnx2x *bp)
 	val = SHMEM_RD(bp, validity_map[BP_PORT(bp)]);
 	if ((val & (SHR_MEM_VALIDITY_DEV_INFO | SHR_MEM_VALIDITY_MB))
 		!= (SHR_MEM_VALIDITY_DEV_INFO | SHR_MEM_VALIDITY_MB))
-		BNX2X_ERROR("BAD MCP validity signature\n");
+		BNX2X_ERR("BAD MCP validity signature\n");
 
 	bp->common.hw_config = SHMEM_RD(bp, dev_info.shared_hw_config.config);
 	BNX2X_DEV_INFO("hw_config 0x%08x\n", bp->common.hw_config);
@@ -6775,8 +7611,8 @@ static void __devinit bnx2x_get_common_hwinfo(struct bnx2x *bp)
 	if (val < BNX2X_BC_VER) {
 		/* for now only warn
 		 * later we might need to enforce this */
-		BNX2X_ERROR("This driver needs bc_ver %X but found %X, "
-			    "please upgrade BC\n", BNX2X_BC_VER, val);
+		BNX2X_ERR("This driver needs bc_ver %X but found %X, "
+			  "please upgrade BC\n", BNX2X_BC_VER, val);
 	}
 	bp->link_params.feature_config_flags |=
 				(val >= REQ_BC_VER_4_VRFY_FIRST_PHY_OPT_MDL) ?
@@ -6804,6 +7640,57 @@ static void __devinit bnx2x_get_common_hwinfo(struct bnx2x *bp)
 		 val, val2, val3, val4);
 }
 
+#define IGU_FID(val)	GET_FIELD((val), IGU_REG_MAPPING_MEMORY_FID)
+#define IGU_VEC(val)	GET_FIELD((val), IGU_REG_MAPPING_MEMORY_VECTOR)
+
+static void __devinit bnx2x_get_igu_cam_info(struct bnx2x *bp)
+{
+	int pfid = BP_FUNC(bp);
+	int vn = BP_E1HVN(bp);
+	int igu_sb_id;
+	u32 val;
+	u8 fid;
+
+	bp->igu_base_sb = 0xff;
+	bp->igu_sb_cnt = 0;
+	if (CHIP_INT_MODE_IS_BC(bp)) {
+		bp->igu_sb_cnt = min_t(u8, FP_SB_MAX_E1x,
+				       bp->l2_cid_count);
+
+		bp->igu_base_sb = (CHIP_MODE_IS_4_PORT(bp) ? pfid : vn) *
+			FP_SB_MAX_E1x;
+
+		bp->igu_dsb_id =  E1HVN_MAX * FP_SB_MAX_E1x +
+			(CHIP_MODE_IS_4_PORT(bp) ? pfid : vn);
+
+		return;
+	}
+
+	/* IGU in normal mode - read CAM */
+	for (igu_sb_id = 0; igu_sb_id < IGU_REG_MAPPING_MEMORY_SIZE;
+	     igu_sb_id++) {
+		val = REG_RD(bp, IGU_REG_MAPPING_MEMORY + igu_sb_id * 4);
+		if (!(val & IGU_REG_MAPPING_MEMORY_VALID))
+			continue;
+		fid = IGU_FID(val);
+		if ((fid & IGU_FID_ENCODE_IS_PF)) {
+			if ((fid & IGU_FID_PF_NUM_MASK) != pfid)
+				continue;
+			if (IGU_VEC(val) == 0)
+				/* default status block */
+				bp->igu_dsb_id = igu_sb_id;
+			else {
+				if (bp->igu_base_sb == 0xff)
+					bp->igu_base_sb = igu_sb_id;
+				bp->igu_sb_cnt++;
+			}
+		}
+	}
+	bp->igu_sb_cnt = min_t(u8, bp->igu_sb_cnt, bp->l2_cid_count);
+	if (bp->igu_sb_cnt == 0)
+		BNX2X_ERR("CAM configuration error\n");
+}
+
 static void __devinit bnx2x_link_settings_supported(struct bnx2x *bp,
 						    u32 switch_cfg)
 {
@@ -7178,26 +8065,49 @@ static void __devinit bnx2x_get_port_hwinfo(struct bnx2x *bp)
 
 static int __devinit bnx2x_get_hwinfo(struct bnx2x *bp)
 {
-	int func = BP_FUNC(bp);
+	int func = BP_ABS_FUNC(bp);
+	int vn;
 	u32 val, val2;
 	int rc = 0;
 
 	bnx2x_get_common_hwinfo(bp);
 
-	bp->common.int_block = INT_BLOCK_HC;
+	if (CHIP_IS_E1x(bp)) {
+		bp->common.int_block = INT_BLOCK_HC;
+
+		bp->igu_dsb_id = DEF_SB_IGU_ID;
+		bp->igu_base_sb = 0;
+		bp->igu_sb_cnt = min_t(u8, FP_SB_MAX_E1x, bp->l2_cid_count);
+	} else {
+		bp->common.int_block = INT_BLOCK_IGU;
+		val = REG_RD(bp, IGU_REG_BLOCK_CONFIGURATION);
+		if (val & IGU_BLOCK_CONFIGURATION_REG_BACKWARD_COMP_EN) {
+			DP(NETIF_MSG_PROBE, "IGU Backward Compatible Mode\n");
+			bp->common.int_block |= INT_BLOCK_MODE_BW_COMP;
+		} else
+			DP(NETIF_MSG_PROBE, "IGU Normal Mode\n");
 
-	bp->igu_dsb_id = DEF_SB_IGU_ID;
-	bp->igu_base_sb = 0;
-	bp->igu_sb_cnt = min_t(u8, FP_SB_MAX_E1x, bp->l2_cid_count);
+		bnx2x_get_igu_cam_info(bp);
+
+	}
+	DP(NETIF_MSG_PROBE, "igu_dsb_id %d  igu_base_sb %d  igu_sb_cnt %d\n",
+			     bp->igu_dsb_id, bp->igu_base_sb, bp->igu_sb_cnt);
+
+	/*
+	 * Initialize MF configuration
+	 */
 
 	bp->mf_ov = 0;
 	bp->mf_mode = 0;
-	if (CHIP_IS_E1H(bp) && !BP_NOMCP(bp)) {
-
-		bp->common.mf_cfg_base = bp->common.shmem_base +
+	vn = BP_E1HVN(bp);
+	if (!CHIP_IS_E1(bp) && !BP_NOMCP(bp)) {
+		if (SHMEM2_HAS(bp, mf_cfg_addr))
+			bp->common.mf_cfg_base = SHMEM2_RD(bp, mf_cfg_addr);
+		else
+			bp->common.mf_cfg_base = bp->common.shmem_base +
 				offsetof(struct shmem_region, func_mb) +
 				E1H_FUNC_MAX * sizeof(struct drv_func_mb);
-		bp->mf_config =
+		bp->mf_config[vn] =
 			MF_CFG_RD(bp, func_mf_config[func].config);
 
 		val = (MF_CFG_RD(bp, func_mf_config[FUNC_0].e1hov_tag) &
@@ -7213,16 +8123,16 @@ static int __devinit bnx2x_get_hwinfo(struct bnx2x *bp)
 			       FUNC_MF_CFG_E1HOV_TAG_MASK);
 			if (val != FUNC_MF_CFG_E1HOV_TAG_DEFAULT) {
 				bp->mf_ov = val;
-				BNX2X_DEV_INFO("E1HOV for func %d is %d "
+				BNX2X_DEV_INFO("MF OV for func %d is %d "
 					       "(0x%04x)\n",
 					       func, bp->mf_ov, bp->mf_ov);
 			} else {
-				BNX2X_ERROR("No valid E1HOV for func %d,"
+				BNX2X_ERROR("No valid MF OV for func %d,"
 					    "  aborting\n", func);
 				rc = -EPERM;
 			}
 		} else {
-			if (BP_E1HVN(bp)) {
+			if (BP_VN(bp)) {
 				BNX2X_ERROR("VN %d in single function mode,"
 					    "  aborting\n", BP_E1HVN(bp));
 				rc = -EPERM;
@@ -7230,15 +8140,25 @@ static int __devinit bnx2x_get_hwinfo(struct bnx2x *bp)
 		}
 	}
 
-	/* adjust igu_sb_cnt to MF */
-	if (IS_MF(bp))
+	/* adjust igu_sb_cnt to MF for E1x */
+	if (CHIP_IS_E1x(bp) && IS_MF(bp))
 		bp->igu_sb_cnt /= E1HVN_MAX;
 
+	/*
+	 * adjust E2 sb count: to be removed when FW will support
+	 * more then 16 L2 clients
+	 */
+#define MAX_L2_CLIENTS				16
+	if (CHIP_IS_E2(bp))
+		bp->igu_sb_cnt = min_t(u8, bp->igu_sb_cnt,
+				       MAX_L2_CLIENTS / (IS_MF(bp) ? 4 : 1));
+
 	if (!BP_NOMCP(bp)) {
 		bnx2x_get_port_hwinfo(bp);
 
-		bp->fw_seq = (SHMEM_RD(bp, func_mb[func].drv_mb_header) &
-			      DRV_MSG_SEQ_NUMBER_MASK);
+		bp->fw_seq =
+			(SHMEM_RD(bp, func_mb[BP_FW_MB_IDX(bp)].drv_mb_header) &
+			 DRV_MSG_SEQ_NUMBER_MASK);
 		BNX2X_DEV_INFO("fw_seq 0x%08x\n", bp->fw_seq);
 	}
 
@@ -7338,7 +8258,7 @@ out_not_found:
 
 static int __devinit bnx2x_init_bp(struct bnx2x *bp)
 {
-	int func = BP_FUNC(bp);
+	int func;
 	int timer_interval;
 	int rc;
 
@@ -7362,6 +8282,9 @@ static int __devinit bnx2x_init_bp(struct bnx2x *bp)
 		rc = bnx2x_alloc_mem_bp(bp);
 
 	bnx2x_read_fwinfo(bp);
+
+	func = BP_FUNC(bp);
+
 	/* need to reset chip if undi was active */
 	if (!BP_NOMCP(bp))
 		bnx2x_undi_unload(bp);
@@ -7650,7 +8573,7 @@ static int __devinit bnx2x_init_dev(struct pci_dev *pdev,
 	bp->dev = dev;
 	bp->pdev = pdev;
 	bp->flags = 0;
-	bp->func = PCI_FUNC(pdev->devfn);
+	bp->pf_num = PCI_FUNC(pdev->devfn);
 
 	rc = pci_enable_device(pdev);
 	if (rc) {
@@ -7964,6 +8887,8 @@ int bnx2x_init_firmware(struct bnx2x *bp)
 		fw_file_name = FW_FILE_NAME_E1;
 	else if (CHIP_IS_E1H(bp))
 		fw_file_name = FW_FILE_NAME_E1H;
+	else if (CHIP_IS_E2(bp))
+		fw_file_name = FW_FILE_NAME_E2;
 	else {
 		BNX2X_ERR("Unsupported chip revision\n");
 		return -EINVAL;
@@ -8047,8 +8972,25 @@ static int __devinit bnx2x_init_one(struct pci_dev *pdev,
 	int pcie_width, pcie_speed;
 	int rc, cid_count;
 
-	cid_count = FP_SB_MAX_E1x + CNIC_CONTEXT_USE;
+	switch (ent->driver_data) {
+	case BCM57710:
+	case BCM57711:
+	case BCM57711E:
+		cid_count = FP_SB_MAX_E1x;
+		break;
+
+	case BCM57712:
+	case BCM57712E:
+		cid_count = FP_SB_MAX_E2;
+		break;
 
+	default:
+		pr_err("Unknown board_type (%ld), aborting\n",
+			   ent->driver_data);
+		return ENODEV;
+	}
+
+	cid_count += CNIC_CONTEXT_USE;
 	/* dev zeroed in init_etherdev */
 	dev = alloc_etherdev_mq(sizeof(*bp), cid_count);
 	if (!dev) {
@@ -8086,7 +9028,10 @@ static int __devinit bnx2x_init_one(struct pci_dev *pdev,
 	netdev_info(dev, "%s (%c%d) PCI-E x%d %s found at mem %lx,"
 	       " IRQ %d, ", board_info[ent->driver_data].name,
 	       (CHIP_REV(bp) >> 12) + 'A', (CHIP_METAL(bp) >> 4),
-	       pcie_width, (pcie_speed == 2) ? "5GHz (Gen2)" : "2.5GHz",
+	       pcie_width,
+	       ((!CHIP_IS_E2(bp) && pcie_speed == 2) ||
+		 (CHIP_IS_E2(bp) && pcie_speed == 1)) ?
+						"5GHz (Gen2)" : "2.5GHz",
 	       dev->base_addr, bp->pdev->irq);
 	pr_cont("node addr %pM\n", dev->dev_addr);
 
@@ -8199,8 +9144,9 @@ static void bnx2x_eeh_recover(struct bnx2x *bp)
 		BNX2X_ERR("BAD MCP validity signature\n");
 
 	if (!BP_NOMCP(bp)) {
-		bp->fw_seq = (SHMEM_RD(bp, func_mb[BP_FUNC(bp)].drv_mb_header)
-			      & DRV_MSG_SEQ_NUMBER_MASK);
+		bp->fw_seq =
+		    (SHMEM_RD(bp, func_mb[BP_FW_MB_IDX(bp)].drv_mb_header) &
+		    DRV_MSG_SEQ_NUMBER_MASK);
 		BNX2X_DEV_INFO("fw_seq 0x%08x\n", bp->fw_seq);
 	}
 }
@@ -8283,7 +9229,8 @@ static void bnx2x_io_resume(struct pci_dev *pdev)
 	struct bnx2x *bp = netdev_priv(dev);
 
 	if (bp->recovery_state != BNX2X_RECOVERY_DONE) {
-		printk(KERN_ERR "Handling parity error recovery. Try again later\n");
+		printk(KERN_ERR "Handling parity error recovery. "
+				"Try again later\n");
 		return;
 	}
 
@@ -8560,7 +9507,11 @@ void bnx2x_setup_cnic_irq_info(struct bnx2x *bp)
 		cp->drv_state &= ~CNIC_DRV_STATE_USING_MSIX;
 		cp->irq_arr[0].irq_flags &= ~CNIC_IRQ_FL_MSIX;
 	}
-	cp->irq_arr[0].status_blk = (void *)bp->cnic_sb.e1x_sb;
+	if (CHIP_IS_E2(bp))
+		cp->irq_arr[0].status_blk = (void *)bp->cnic_sb.e2_sb;
+	else
+		cp->irq_arr[0].status_blk = (void *)bp->cnic_sb.e1x_sb;
+
 	cp->irq_arr[0].status_blk_num = CNIC_SB_ID(bp);
 	cp->irq_arr[0].status_blk_num2 = CNIC_IGU_SB_ID(bp);
 	cp->irq_arr[1].status_blk = bp->def_status_blk;
diff --git a/drivers/net/bnx2x/bnx2x_reg.h b/drivers/net/bnx2x/bnx2x_reg.h
index 6be0d09..18a8628 100644
--- a/drivers/net/bnx2x/bnx2x_reg.h
+++ b/drivers/net/bnx2x/bnx2x_reg.h
@@ -1,6 +1,6 @@
 /* bnx2x_reg.h: Broadcom Everest network driver.
  *
- * Copyright (c) 2007-2009 Broadcom Corporation
+ * Copyright (c) 2007-2010 Broadcom Corporation
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
@@ -19,7 +19,20 @@
  *
  */
 
-
+#define ATC_ATC_INT_STS_REG_ADDRESS_ERROR			 (0x1<<0)
+#define ATC_ATC_INT_STS_REG_ATC_GPA_MULTIPLE_HITS		 (0x1<<2)
+#define ATC_ATC_INT_STS_REG_ATC_IREQ_LESS_THAN_STU		 (0x1<<5)
+#define ATC_ATC_INT_STS_REG_ATC_RCPL_TO_EMPTY_CNT		 (0x1<<3)
+#define ATC_ATC_INT_STS_REG_ATC_TCPL_ERROR			 (0x1<<4)
+#define ATC_ATC_INT_STS_REG_ATC_TCPL_TO_NOT_PEND		 (0x1<<1)
+/* [RW 1] Initiate the ATC array - reset all the valid bits */
+#define ATC_REG_ATC_INIT_ARRAY					 0x1100b8
+/* [R 1] ATC initalization done */
+#define ATC_REG_ATC_INIT_DONE					 0x1100bc
+/* [RC 6] Interrupt register #0 read clear */
+#define ATC_REG_ATC_INT_STS_CLR				 0x1101c0
+/* [RW 19] Interrupt mask register #0 read/write */
+#define BRB1_REG_BRB1_INT_MASK					 0x60128
 /* [R 19] Interrupt register #0 read */
 #define BRB1_REG_BRB1_INT_STS					 0x6011c
 /* [RW 4] Parity mask register #0 read/write */
@@ -27,9 +40,31 @@
 /* [R 4] Parity register #0 read */
 #define BRB1_REG_BRB1_PRTY_STS					 0x6012c
 /* [RW 10] At address BRB1_IND_FREE_LIST_PRS_CRDT initialize free head. At
-   address BRB1_IND_FREE_LIST_PRS_CRDT+1 initialize free tail. At address
-   BRB1_IND_FREE_LIST_PRS_CRDT+2 initialize parser initial credit. */
+ * address BRB1_IND_FREE_LIST_PRS_CRDT+1 initialize free tail. At address
+ * BRB1_IND_FREE_LIST_PRS_CRDT+2 initialize parser initial credit. Warning -
+ * following reset the first rbc access to this reg must be write; there can
+ * be no more rbc writes after the first one; there can be any number of rbc
+ * read following the first write; rbc access not following these rules will
+ * result in hang condition. */
 #define BRB1_REG_FREE_LIST_PRS_CRDT				 0x60200
+/* [RW 10] The number of free blocks below which the full signal to class 0
+ * is asserted */
+#define BRB1_REG_FULL_0_XOFF_THRESHOLD_0			 0x601d0
+/* [RW 10] The number of free blocks above which the full signal to class 0
+ * is de-asserted */
+#define BRB1_REG_FULL_0_XON_THRESHOLD_0				 0x601d4
+/* [RW 10] The number of free blocks below which the full signal to class 1
+ * is asserted */
+#define BRB1_REG_FULL_1_XOFF_THRESHOLD_0			 0x601d8
+/* [RW 10] The number of free blocks above which the full signal to class 1
+ * is de-asserted */
+#define BRB1_REG_FULL_1_XON_THRESHOLD_0				 0x601dc
+/* [RW 10] The number of free blocks below which the full signal to the LB
+ * port is asserted */
+#define BRB1_REG_FULL_LB_XOFF_THRESHOLD				 0x601e0
+/* [RW 10] The number of free blocks above which the full signal to the LB
+ * port is de-asserted */
+#define BRB1_REG_FULL_LB_XON_THRESHOLD				 0x601e4
 /* [RW 10] The number of free blocks above which the High_llfc signal to
    interface #n is de-asserted. */
 #define BRB1_REG_HIGH_LLFC_HIGH_THRESHOLD_0			 0x6014c
@@ -44,6 +79,9 @@
 /* [RW 10] The number of free blocks below which the Low_llfc signal to
    interface #n is asserted. */
 #define BRB1_REG_LOW_LLFC_LOW_THRESHOLD_0			 0x6015c
+/* [RW 10] The number of blocks guarantied for the MAC port */
+#define BRB1_REG_MAC_GUARANTIED_0				 0x601e8
+#define BRB1_REG_MAC_GUARANTIED_1				 0x60240
 /* [R 24] The number of full blocks. */
 #define BRB1_REG_NUM_OF_FULL_BLOCKS				 0x60090
 /* [ST 32] The number of cycles that the write_full signal towards MAC #0
@@ -55,7 +93,19 @@
    asserted. */
 #define BRB1_REG_NUM_OF_PAUSE_CYCLES_0				 0x600b8
 #define BRB1_REG_NUM_OF_PAUSE_CYCLES_1				 0x600bc
-/* [RW 10] Write client 0: De-assert pause threshold. */
+/* [RW 10] The number of free blocks below which the pause signal to class 0
+ * is asserted */
+#define BRB1_REG_PAUSE_0_XOFF_THRESHOLD_0			 0x601c0
+/* [RW 10] The number of free blocks above which the pause signal to class 0
+ * is de-asserted */
+#define BRB1_REG_PAUSE_0_XON_THRESHOLD_0			 0x601c4
+/* [RW 10] The number of free blocks below which the pause signal to class 1
+ * is asserted */
+#define BRB1_REG_PAUSE_1_XOFF_THRESHOLD_0			 0x601c8
+/* [RW 10] The number of free blocks above which the pause signal to class 1
+ * is de-asserted */
+#define BRB1_REG_PAUSE_1_XON_THRESHOLD_0			 0x601cc
+/* [RW 10] Write client 0: De-assert pause threshold. Not Functional */
 #define BRB1_REG_PAUSE_HIGH_THRESHOLD_0 			 0x60078
 #define BRB1_REG_PAUSE_HIGH_THRESHOLD_1 			 0x6007c
 /* [RW 10] Write client 0: Assert pause threshold. */
@@ -362,6 +412,7 @@
 #define CFC_REG_NUM_LCIDS_ARRIVING				 0x104004
 /* [R 9] Number of Leaving LCIDs in Link List Block */
 #define CFC_REG_NUM_LCIDS_LEAVING				 0x104018
+#define CFC_REG_WEAK_ENABLE_PF					 0x104124
 /* [RW 8] The event id for aggregated interrupt 0 */
 #define CSDM_REG_AGG_INT_EVENT_0				 0xc2038
 #define CSDM_REG_AGG_INT_EVENT_10				 0xc2060
@@ -590,10 +641,17 @@
 #define CSEM_REG_TS_8_AS					 0x200058
 /* [RW 3] The arbitration scheme of time_slot 9 */
 #define CSEM_REG_TS_9_AS					 0x20005c
+/* [W 7] VF or PF ID for reset error bit. Values 0-63 reset error bit for 64
+ * VF; values 64-67 reset error for 4 PF; values 68-127 are not valid. */
+#define CSEM_REG_VFPF_ERR_NUM					 0x200380
 /* [RW 1] Parity mask register #0 read/write */
 #define DBG_REG_DBG_PRTY_MASK					 0xc0a8
 /* [R 1] Parity register #0 read */
 #define DBG_REG_DBG_PRTY_STS					 0xc09c
+/* [RW 1] When set the DMAE will process the commands as in E1.5. 1.The
+ * function that is used is always SRC-PCI; 2.VF_Valid = 0; 3.VFID=0;
+ * 4.Completion function=0; 5.Error handling=0 */
+#define DMAE_REG_BACKWARD_COMP_EN				 0x10207c
 /* [RW 32] Commands memory. The address to command X; row Y is to calculated
    as 14*X+Y. */
 #define DMAE_REG_CMD_MEM					 0x102400
@@ -758,6 +816,92 @@
 #define HC_REG_USTORM_ADDR_FOR_COALESCE 			 0x108068
 #define HC_REG_VQID_0						 0x108008
 #define HC_REG_VQID_1						 0x10800c
+#define IGU_BLOCK_CONFIGURATION_REG_BACKWARD_COMP_EN		 (0x1<<1)
+#define IGU_REG_ATTENTION_ACK_BITS				 0x130108
+/* [R 4] Debug: attn_fsm */
+#define IGU_REG_ATTN_FSM					 0x130054
+#define IGU_REG_ATTN_MSG_ADDR_H				 0x13011c
+#define IGU_REG_ATTN_MSG_ADDR_L				 0x130120
+/* [R 4] Debug: [3] - attention write done message is pending (0-no pending;
+ * 1-pending). [2:0] = PFID. Pending means attention message was sent; but
+ * write done didnt receive. */
+#define IGU_REG_ATTN_WRITE_DONE_PENDING			 0x130030
+#define IGU_REG_BLOCK_CONFIGURATION				 0x130000
+#define IGU_REG_COMMAND_REG_32LSB_DATA				 0x130124
+#define IGU_REG_COMMAND_REG_CTRL				 0x13012c
+/* [WB_R 32] Cleanup bit status per SB. 1 = cleanup is set. 0 = cleanup bit
+ * is clear. The bits in this registers are set and clear via the producer
+ * command. Data valid only in addresses 0-4. all the rest are zero. */
+#define IGU_REG_CSTORM_TYPE_0_SB_CLEANUP			 0x130200
+/* [R 5] Debug: ctrl_fsm */
+#define IGU_REG_CTRL_FSM					 0x130064
+/* [R 1] data availble for error memory. If this bit is clear do not red
+ * from error_handling_memory. */
+#define IGU_REG_ERROR_HANDLING_DATA_VALID			 0x130130
+/* [R 11] Parity register #0 read */
+#define IGU_REG_IGU_PRTY_STS					 0x13009c
+/* [R 4] Debug: int_handle_fsm */
+#define IGU_REG_INT_HANDLE_FSM					 0x130050
+#define IGU_REG_LEADING_EDGE_LATCH				 0x130134
+/* [RW 14] mapping CAM; relevant for E2 operating mode only. [0] - valid.
+ * [6:1] - vector number; [13:7] - FID (if VF - [13] = 0; [12:7] = VF
+ * number; if PF - [13] = 1; [12:10] = 0; [9:7] = PF number); */
+#define IGU_REG_MAPPING_MEMORY					 0x131000
+#define IGU_REG_MAPPING_MEMORY_SIZE				 136
+#define IGU_REG_PBA_STATUS_LSB					 0x130138
+#define IGU_REG_PBA_STATUS_MSB					 0x13013c
+#define IGU_REG_PCI_PF_MSI_EN					 0x130140
+#define IGU_REG_PCI_PF_MSIX_EN					 0x130144
+#define IGU_REG_PCI_PF_MSIX_FUNC_MASK				 0x130148
+/* [WB_R 32] Each bit represent the pending bits status for that SB. 0 = no
+ * pending; 1 = pending. Pendings means interrupt was asserted; and write
+ * done was not received. Data valid only in addresses 0-4. all the rest are
+ * zero. */
+#define IGU_REG_PENDING_BITS_STATUS				 0x130300
+#define IGU_REG_PF_CONFIGURATION				 0x130154
+/* [RW 20] producers only. E2 mode: address 0-135 match to the mapping
+ * memory; 136 - PF0 default prod; 137 PF1 default prod; 138 - PF2 default
+ * prod; 139 PF3 default prod; 140 - PF0 - ATTN prod; 141 - PF1 - ATTN prod;
+ * 142 - PF2 - ATTN prod; 143 - PF3 - ATTN prod; 144-147 reserved. E1.5 mode
+ * - In backward compatible mode; for non default SB; each even line in the
+ * memory holds the U producer and each odd line hold the C producer. The
+ * first 128 producer are for NDSB (PF0 - 0-31; PF1 - 32-63 and so on). The
+ * last 20 producers are for the DSB for each PF. each PF has five segments
+ * (the order inside each segment is PF0; PF1; PF2; PF3) - 128-131 U prods;
+ * 132-135 C prods; 136-139 X prods; 140-143 T prods; 144-147 ATTN prods; */
+#define IGU_REG_PROD_CONS_MEMORY				 0x132000
+/* [R 3] Debug: pxp_arb_fsm */
+#define IGU_REG_PXP_ARB_FSM					 0x130068
+/* [RW 6] Write one for each bit will reset the appropriate memory. When the
+ * memory reset finished the appropriate bit will be clear. Bit 0 - mapping
+ * memory; Bit 1 - SB memory; Bit 2 - SB interrupt and mask register; Bit 3
+ * - MSIX memory; Bit 4 - PBA memory; Bit 5 - statistics; */
+#define IGU_REG_RESET_MEMORIES					 0x130158
+/* [R 4] Debug: sb_ctrl_fsm */
+#define IGU_REG_SB_CTRL_FSM					 0x13004c
+#define IGU_REG_SB_INT_BEFORE_MASK_LSB				 0x13015c
+#define IGU_REG_SB_INT_BEFORE_MASK_MSB				 0x130160
+#define IGU_REG_SB_MASK_LSB					 0x130164
+#define IGU_REG_SB_MASK_MSB					 0x130168
+/* [RW 16] Number of command that were dropped without causing an interrupt
+ * due to: read access for WO BAR address; or write access for RO BAR
+ * address or any access for reserved address or PCI function error is set
+ * and address is not MSIX; PBA or cleanup */
+#define IGU_REG_SILENT_DROP					 0x13016c
+/* [RW 10] Number of MSI/MSIX/ATTN messages sent for the function: 0-63 -
+ * number of MSIX messages per VF; 64-67 - number of MSI/MSIX messages per
+ * PF; 68-71 number of ATTN messages per PF */
+#define IGU_REG_STATISTIC_NUM_MESSAGE_SENT			 0x130800
+/* [RW 32] Number of cycles the timer mask masking the IGU interrupt when a
+ * timer mask command arrives. Value must be bigger than 100. */
+#define IGU_REG_TIMER_MASKING_VALUE				 0x13003c
+#define IGU_REG_TRAILING_EDGE_LATCH				 0x130104
+#define IGU_REG_VF_CONFIGURATION				 0x130170
+/* [WB_R 32] Each bit represent write done pending bits status for that SB
+ * (MSI/MSIX message was sent and write done was not received yet). 0 =
+ * clear; 1 = set. Data valid only in addresses 0-4. all the rest are zero. */
+#define IGU_REG_WRITE_DONE_PENDING				 0x130480
+#define MCP_A_REG_MCPR_SCRATCH					 0x3a0000
 #define MCP_REG_MCPR_NVM_ACCESS_ENABLE				 0x86424
 #define MCP_REG_MCPR_NVM_ADDR					 0x8640c
 #define MCP_REG_MCPR_NVM_CFG4					 0x8642c
@@ -880,6 +1024,11 @@
    rom_parity; [29] MCP Latched ump_rx_parity; [30] MCP Latched
    ump_tx_parity; [31] MCP Latched scpad_parity; */
 #define MISC_REG_AEU_AFTER_INVERT_4_MCP 			 0xa458
+/* [R 32] Read fifth 32 bit after inversion of function 0. Mapped as
+ * follows: [0] PGLUE config_space; [1] PGLUE misc_flr; [2] PGLUE B RBC
+ * attention [3] PGLUE B RBC parity; [4] ATC attention; [5] ATC parity; [6]
+ * CNIG attention (reserved); [7] CNIG parity (reserved); [31-8] Reserved; */
+#define MISC_REG_AEU_AFTER_INVERT_5_FUNC_0			 0xa700
 /* [W 14] write to this register results with the clear of the latched
    signals; one in d0 clears RBCR latch; one in d1 clears RBCT latch; one in
    d2 clears RBCN latch; one in d3 clears RBCU latch; one in d4 clears RBCP
@@ -1251,6 +1400,7 @@
 #define MISC_REG_E1HMF_MODE					 0xa5f8
 /* [RW 32] Debug only: spare RW register reset by core reset */
 #define MISC_REG_GENERIC_CR_0					 0xa460
+#define MISC_REG_GENERIC_CR_1					 0xa464
 /* [RW 32] Debug only: spare RW register reset by por reset */
 #define MISC_REG_GENERIC_POR_1					 0xa474
 /* [RW 32] GPIO. [31-28] FLOAT port 0; [27-24] FLOAT port 0; When any of
@@ -1373,6 +1523,14 @@
 #define MISC_REG_PLL_STORM_CTRL_2				 0xa298
 #define MISC_REG_PLL_STORM_CTRL_3				 0xa29c
 #define MISC_REG_PLL_STORM_CTRL_4				 0xa2a0
+/* [R 1] Status of 4 port mode enable input pin. */
+#define MISC_REG_PORT4MODE_EN					 0xa750
+/* [RW 2] 4 port mode enable overwrite.[0] - Overwrite control; if it is 0 -
+ * the port4mode_en output is equal to 4 port mode input pin; if it is 1 -
+ * the port4mode_en output is equal to bit[1] of this register; [1] -
+ * Overwrite value. If bit[0] of this register is 1 this is the value that
+ * receives the port4mode_en output . */
+#define MISC_REG_PORT4MODE_EN_OVWR				 0xa720
 /* [RW 32] reset reg#2; rite/read one = the specific block is out of reset;
    write/read zero = the specific block is in reset; addr 0-wr- the write
    value will be written to the register; addr 1-set - one will be written
@@ -1656,8 +1814,91 @@
 /* [R 32] Interrupt register #0 read */
 #define NIG_REG_NIG_INT_STS_0					 0x103b0
 #define NIG_REG_NIG_INT_STS_1					 0x103c0
-/* [R 32] Parity register #0 read */
+/* [R 32] Legacy E1 and E1H location for parity error status register. */
 #define NIG_REG_NIG_PRTY_STS					 0x103d0
+/* [R 32] Parity register #0 read */
+#define NIG_REG_NIG_PRTY_STS_0					 0x183bc
+#define NIG_REG_NIG_PRTY_STS_1					 0x183cc
+/* [RW 6] Bit-map indicating which L2 hdrs may appear after the basic
+ * Ethernet header. */
+#define NIG_REG_P0_HDRS_AFTER_BASIC				 0x18038
+/* [RW 1] HW PFC enable bit. Set this bit to enable the PFC functionality in
+ * the NIG. Other flow control modes such as PAUSE and SAFC/LLFC should be
+ * disabled when this bit is set. */
+#define NIG_REG_P0_HWPFC_ENABLE				 0x18078
+#define NIG_REG_P0_LLH_FUNC_MEM2				 0x18480
+#define NIG_REG_P0_LLH_FUNC_MEM2_ENABLE			 0x18440
+/* [RW 32] Eight 4-bit configurations for specifying which COS (0-15 for
+ * future expansion) each priorty is to be mapped to. Bits 3:0 specify the
+ * COS for priority 0. Bits 31:28 specify the COS for priority 7. The 3-bit
+ * priority field is extracted from the outer-most VLAN in receive packet.
+ * Only COS 0 and COS 1 are supported in E2. */
+#define NIG_REG_P0_PKT_PRIORITY_TO_COS				 0x18054
+/* [RW 16] Bit-map indicating which SAFC/PFC priorities to map to COS 0. A
+ * priority is mapped to COS 0 when the corresponding mask bit is 1. More
+ * than one bit may be set; allowing multiple priorities to be mapped to one
+ * COS. */
+#define NIG_REG_P0_RX_COS0_PRIORITY_MASK			 0x18058
+/* [RW 16] Bit-map indicating which SAFC/PFC priorities to map to COS 1. A
+ * priority is mapped to COS 1 when the corresponding mask bit is 1. More
+ * than one bit may be set; allowing multiple priorities to be mapped to one
+ * COS. */
+#define NIG_REG_P0_RX_COS1_PRIORITY_MASK			 0x1805c
+/* [RW 15] Specify which of the credit registers the client is to be mapped
+ * to. Bits[2:0] are for client 0; bits [14:12] are for client 4. For
+ * clients that are not subject to WFQ credit blocking - their
+ * specifications here are not used. */
+#define NIG_REG_P0_TX_ARB_CLIENT_CREDIT_MAP			 0x180f0
+/* [RW 5] Specify whether the client competes directly in the strict
+ * priority arbiter. The bits are mapped according to client ID (client IDs
+ * are defined in tx_arb_priority_client). Default value is set to enable
+ * strict priorities for clients 0-2 -- management and debug traffic. */
+#define NIG_REG_P0_TX_ARB_CLIENT_IS_STRICT			 0x180e8
+/* [RW 5] Specify whether the client is subject to WFQ credit blocking. The
+ * bits are mapped according to client ID (client IDs are defined in
+ * tx_arb_priority_client). Default value is 0 for not using WFQ credit
+ * blocking. */
+#define NIG_REG_P0_TX_ARB_CLIENT_IS_SUBJECT2WFQ		 0x180ec
+/* [RW 32] Specify the upper bound that credit register 0 is allowed to
+ * reach. */
+#define NIG_REG_P0_TX_ARB_CREDIT_UPPER_BOUND_0			 0x1810c
+#define NIG_REG_P0_TX_ARB_CREDIT_UPPER_BOUND_1			 0x18110
+/* [RW 32] Specify the weight (in bytes) to be added to credit register 0
+ * when it is time to increment. */
+#define NIG_REG_P0_TX_ARB_CREDIT_WEIGHT_0			 0x180f8
+#define NIG_REG_P0_TX_ARB_CREDIT_WEIGHT_1			 0x180fc
+/* [RW 12] Specify the number of strict priority arbitration slots between
+ * two round-robin arbitration slots to avoid starvation. A value of 0 means
+ * no strict priority cycles - the strict priority with anti-starvation
+ * arbiter becomes a round-robin arbiter. */
+#define NIG_REG_P0_TX_ARB_NUM_STRICT_ARB_SLOTS			 0x180f4
+/* [RW 15] Specify the client number to be assigned to each priority of the
+ * strict priority arbiter. Priority 0 is the highest priority. Bits [2:0]
+ * are for priority 0 client; bits [14:12] are for priority 4 client. The
+ * clients are assigned the following IDs: 0-management; 1-debug traffic
+ * from this port; 2-debug traffic from other port; 3-COS0 traffic; 4-COS1
+ * traffic. The reset value[14:0] is set to 0x4688 (15'b100_011_010_001_000)
+ * for management at priority 0; debug traffic at priorities 1 and 2; COS0
+ * traffic at priority 3; and COS1 traffic at priority 4. */
+#define NIG_REG_P0_TX_ARB_PRIORITY_CLIENT			 0x180e4
+#define NIG_REG_P1_LLH_FUNC_MEM2				 0x184c0
+#define NIG_REG_P1_LLH_FUNC_MEM2_ENABLE			 0x18460
+/* [RW 32] Eight 4-bit configurations for specifying which COS (0-15 for
+ * future expansion) each priorty is to be mapped to. Bits 3:0 specify the
+ * COS for priority 0. Bits 31:28 specify the COS for priority 7. The 3-bit
+ * priority field is extracted from the outer-most VLAN in receive packet.
+ * Only COS 0 and COS 1 are supported in E2. */
+#define NIG_REG_P1_PKT_PRIORITY_TO_COS				 0x181a8
+/* [RW 16] Bit-map indicating which SAFC/PFC priorities to map to COS 0. A
+ * priority is mapped to COS 0 when the corresponding mask bit is 1. More
+ * than one bit may be set; allowing multiple priorities to be mapped to one
+ * COS. */
+#define NIG_REG_P1_RX_COS0_PRIORITY_MASK			 0x181ac
+/* [RW 16] Bit-map indicating which SAFC/PFC priorities to map to COS 1. A
+ * priority is mapped to COS 1 when the corresponding mask bit is 1. More
+ * than one bit may be set; allowing multiple priorities to be mapped to one
+ * COS. */
+#define NIG_REG_P1_RX_COS1_PRIORITY_MASK			 0x181b0
 /* [RW 1] Pause enable for port0. This register may get 1 only when
    ~safc_enable.safc_enable = 0 and ppp_enable.ppp_enable =0 for the same
    port */
@@ -1742,6 +1983,10 @@
 /* [RW 1] Disable processing further tasks from port 4 (after ending the
    current task in process). */
 #define PBF_REG_DISABLE_NEW_TASK_PROC_P4			 0x14006c
+#define PBF_REG_DISABLE_PF					 0x1402e8
+/* [RW 6] Bit-map indicating which L2 hdrs may appear after the basic
+ * Ethernet header. */
+#define PBF_REG_HDRS_AFTER_BASIC				 0x15c0a8
 #define PBF_REG_IF_ENABLE_REG					 0x140044
 /* [RW 1] Init bit. When set the initial credits are copied to the credit
    registers (except the port credits). Should be set and then reset after
@@ -1765,6 +2010,8 @@
 #define PBF_REG_MAC_IF1_ENABLE					 0x140034
 /* [RW 1] Enable for the loopback interface. */
 #define PBF_REG_MAC_LB_ENABLE					 0x140040
+/* [RW 6] Bit-map indicating which headers must appear in the packet */
+#define PBF_REG_MUST_HAVE_HDRS					 0x15c0c4
 /* [RW 10] Port 0 threshold used by arbiter in 16 byte lines used when pause
    not suppoterd. */
 #define PBF_REG_P0_ARB_THRSH					 0x1400e4
@@ -1804,6 +2051,259 @@
 #define PB_REG_PB_PRTY_MASK					 0x38
 /* [R 4] Parity register #0 read */
 #define PB_REG_PB_PRTY_STS					 0x2c
+#define PGLUE_B_PGLUE_B_INT_STS_REG_ADDRESS_ERROR		 (0x1<<0)
+#define PGLUE_B_PGLUE_B_INT_STS_REG_CSSNOOP_FIFO_OVERFLOW	 (0x1<<8)
+#define PGLUE_B_PGLUE_B_INT_STS_REG_INCORRECT_RCV_BEHAVIOR	 (0x1<<1)
+#define PGLUE_B_PGLUE_B_INT_STS_REG_TCPL_ERROR_ATTN		 (0x1<<6)
+#define PGLUE_B_PGLUE_B_INT_STS_REG_TCPL_IN_TWO_RCBS_ATTN	 (0x1<<7)
+#define PGLUE_B_PGLUE_B_INT_STS_REG_VF_GRC_SPACE_VIOLATION_ATTN  (0x1<<4)
+#define PGLUE_B_PGLUE_B_INT_STS_REG_VF_LENGTH_VIOLATION_ATTN	 (0x1<<3)
+#define PGLUE_B_PGLUE_B_INT_STS_REG_VF_MSIX_BAR_VIOLATION_ATTN	 (0x1<<5)
+#define PGLUE_B_PGLUE_B_INT_STS_REG_WAS_ERROR_ATTN		 (0x1<<2)
+/* [R 8] Config space A attention dirty bits. Each bit indicates that the
+ * corresponding PF generates config space A attention. Set by PXP. Reset by
+ * MCP writing 1 to icfg_space_a_request_clr. Note: register contains bits
+ * from both paths. */
+#define PGLUE_B_REG_CFG_SPACE_A_REQUEST			 0x9010
+/* [R 8] Config space B attention dirty bits. Each bit indicates that the
+ * corresponding PF generates config space B attention. Set by PXP. Reset by
+ * MCP writing 1 to icfg_space_b_request_clr. Note: register contains bits
+ * from both paths. */
+#define PGLUE_B_REG_CFG_SPACE_B_REQUEST			 0x9014
+/* [RW 1] Type A PF enable inbound interrupt table for CSDM. 0 - disable; 1
+ * - enable. */
+#define PGLUE_B_REG_CSDM_INB_INT_A_PF_ENABLE			 0x9194
+/* [RW 18] Type B VF inbound interrupt table for CSDM: bits[17:9]-mask;
+ * its[8:0]-address. Bits [1:0] must be zero (DW resolution address). */
+#define PGLUE_B_REG_CSDM_INB_INT_B_VF				 0x916c
+/* [RW 1] Type B VF enable inbound interrupt table for CSDM. 0 - disable; 1
+ * - enable. */
+#define PGLUE_B_REG_CSDM_INB_INT_B_VF_ENABLE			 0x919c
+/* [RW 16] Start offset of CSDM zone A (queue zone) in the internal RAM */
+#define PGLUE_B_REG_CSDM_START_OFFSET_A			 0x9100
+/* [RW 16] Start offset of CSDM zone B (legacy zone) in the internal RAM */
+#define PGLUE_B_REG_CSDM_START_OFFSET_B			 0x9108
+/* [RW 5] VF Shift of CSDM zone B (legacy zone) in the internal RAM */
+#define PGLUE_B_REG_CSDM_VF_SHIFT_B				 0x9110
+/* [RW 1] 0 - Zone A size is 136x32B; 1 - Zone A size is 152x32B. */
+#define PGLUE_B_REG_CSDM_ZONE_A_SIZE_PF			 0x91ac
+/* [R 8] FLR request attention dirty bits for PFs 0 to 7. Each bit indicates
+ * that the FLR register of the corresponding PF was set. Set by PXP. Reset
+ * by MCP writing 1 to flr_request_pf_7_0_clr. Note: register contains bits
+ * from both paths. */
+#define PGLUE_B_REG_FLR_REQUEST_PF_7_0				 0x9028
+/* [W 8] FLR request attention dirty bits clear for PFs 0 to 7. MCP writes 1
+ * to a bit in this register in order to clear the corresponding bit in
+ * flr_request_pf_7_0 register. Note: register contains bits from both
+ * paths. */
+#define PGLUE_B_REG_FLR_REQUEST_PF_7_0_CLR			 0x9418
+/* [R 32] FLR request attention dirty bits for VFs 96 to 127. Each bit
+ * indicates that the FLR register of the corresponding VF was set. Set by
+ * PXP. Reset by MCP writing 1 to flr_request_vf_127_96_clr. */
+#define PGLUE_B_REG_FLR_REQUEST_VF_127_96			 0x9024
+/* [R 32] FLR request attention dirty bits for VFs 0 to 31. Each bit
+ * indicates that the FLR register of the corresponding VF was set. Set by
+ * PXP. Reset by MCP writing 1 to flr_request_vf_31_0_clr. */
+#define PGLUE_B_REG_FLR_REQUEST_VF_31_0			 0x9018
+/* [R 32] FLR request attention dirty bits for VFs 32 to 63. Each bit
+ * indicates that the FLR register of the corresponding VF was set. Set by
+ * PXP. Reset by MCP writing 1 to flr_request_vf_63_32_clr. */
+#define PGLUE_B_REG_FLR_REQUEST_VF_63_32			 0x901c
+/* [R 32] FLR request attention dirty bits for VFs 64 to 95. Each bit
+ * indicates that the FLR register of the corresponding VF was set. Set by
+ * PXP. Reset by MCP writing 1 to flr_request_vf_95_64_clr. */
+#define PGLUE_B_REG_FLR_REQUEST_VF_95_64			 0x9020
+/* [R 8] Each bit indicates an incorrect behavior in user RX interface. Bit
+ * 0 - Target memory read arrived with a correctable error. Bit 1 - Target
+ * memory read arrived with an uncorrectable error. Bit 2 - Configuration RW
+ * arrived with a correctable error. Bit 3 - Configuration RW arrived with
+ * an uncorrectable error. Bit 4 - Completion with Configuration Request
+ * Retry Status. Bit 5 - Expansion ROM access received with a write request.
+ * Bit 6 - Completion with pcie_rx_err of 0000; CMPL_STATUS of non-zero; and
+ * pcie_rx_last not asserted. Bit 7 - Completion with pcie_rx_err of 1010;
+ * and pcie_rx_last not asserted. */
+#define PGLUE_B_REG_INCORRECT_RCV_DETAILS			 0x9068
+#define PGLUE_B_REG_INTERNAL_PFID_ENABLE_MASTER		 0x942c
+#define PGLUE_B_REG_INTERNAL_PFID_ENABLE_TARGET_READ		 0x9430
+#define PGLUE_B_REG_INTERNAL_PFID_ENABLE_TARGET_WRITE		 0x9434
+#define PGLUE_B_REG_INTERNAL_VFID_ENABLE			 0x9438
+/* [R 9] Interrupt register #0 read */
+#define PGLUE_B_REG_PGLUE_B_INT_STS				 0x9298
+/* [RC 9] Interrupt register #0 read clear */
+#define PGLUE_B_REG_PGLUE_B_INT_STS_CLR			 0x929c
+/* [R 2] Parity register #0 read */
+#define PGLUE_B_REG_PGLUE_B_PRTY_STS				 0x92a8
+/* [R 13] Details of first request received with error. [2:0] - PFID. [3] -
+ * VF_VALID. [9:4] - VFID. [11:10] - Error Code - 0 - Indicates Completion
+ * Timeout of a User Tx non-posted request. 1 - unsupported request. 2 -
+ * completer abort. 3 - Illegal value for this field. [12] valid - indicates
+ * if there was a completion error since the last time this register was
+ * cleared. */
+#define PGLUE_B_REG_RX_ERR_DETAILS				 0x9080
+/* [R 18] Details of first ATS Translation Completion request received with
+ * error. [2:0] - PFID. [3] - VF_VALID. [9:4] - VFID. [11:10] - Error Code -
+ * 0 - Indicates Completion Timeout of a User Tx non-posted request. 1 -
+ * unsupported request. 2 - completer abort. 3 - Illegal value for this
+ * field. [16:12] - ATC OTB EntryID. [17] valid - indicates if there was a
+ * completion error since the last time this register was cleared. */
+#define PGLUE_B_REG_RX_TCPL_ERR_DETAILS			 0x9084
+/* [W 8] Debug only - Shadow BME bits clear for PFs 0 to 7. MCP writes 1 to
+ * a bit in this register in order to clear the corresponding bit in
+ * shadow_bme_pf_7_0 register. MCP should never use this unless a
+ * work-around is needed. Note: register contains bits from both paths. */
+#define PGLUE_B_REG_SHADOW_BME_PF_7_0_CLR			 0x9458
+/* [R 8] SR IOV disabled attention dirty bits. Each bit indicates that the
+ * VF enable register of the corresponding PF is written to 0 and was
+ * previously 1. Set by PXP. Reset by MCP writing 1 to
+ * sr_iov_disabled_request_clr. Note: register contains bits from both
+ * paths. */
+#define PGLUE_B_REG_SR_IOV_DISABLED_REQUEST			 0x9030
+/* [R 32] Indicates the status of tags 32-63. 0 - tags is used - read
+ * completion did not return yet. 1 - tag is unused. Same functionality as
+ * pxp2_registers_pgl_exp_rom_data2 for tags 0-31. */
+#define PGLUE_B_REG_TAGS_63_32					 0x9244
+/* [RW 1] Type A PF enable inbound interrupt table for TSDM. 0 - disable; 1
+ * - enable. */
+#define PGLUE_B_REG_TSDM_INB_INT_A_PF_ENABLE			 0x9170
+/* [RW 16] Start offset of TSDM zone A (queue zone) in the internal RAM */
+#define PGLUE_B_REG_TSDM_START_OFFSET_A			 0x90c4
+/* [RW 16] Start offset of TSDM zone B (legacy zone) in the internal RAM */
+#define PGLUE_B_REG_TSDM_START_OFFSET_B			 0x90cc
+/* [RW 5] VF Shift of TSDM zone B (legacy zone) in the internal RAM */
+#define PGLUE_B_REG_TSDM_VF_SHIFT_B				 0x90d4
+/* [RW 1] 0 - Zone A size is 136x32B; 1 - Zone A size is 152x32B. */
+#define PGLUE_B_REG_TSDM_ZONE_A_SIZE_PF			 0x91a0
+/* [R 32] Address [31:0] of first read request not submitted due to error */
+#define PGLUE_B_REG_TX_ERR_RD_ADD_31_0				 0x9098
+/* [R 32] Address [63:32] of first read request not submitted due to error */
+#define PGLUE_B_REG_TX_ERR_RD_ADD_63_32			 0x909c
+/* [R 31] Details of first read request not submitted due to error. [4:0]
+ * VQID. [5] TREQ. 1 - Indicates the request is a Translation Request.
+ * [20:8] - Length in bytes. [23:21] - PFID. [24] - VF_VALID. [30:25] -
+ * VFID. */
+#define PGLUE_B_REG_TX_ERR_RD_DETAILS				 0x90a0
+/* [R 26] Details of first read request not submitted due to error. [15:0]
+ * Request ID. [19:16] client ID. [20] - last SR. [24:21] - Error type -
+ * [21] - Indicates was_error was set; [22] - Indicates BME was cleared;
+ * [23] - Indicates FID_enable was cleared; [24] - Indicates VF with parent
+ * PF FLR_request or IOV_disable_request dirty bit is set. [25] valid -
+ * indicates if there was a request not submitted due to error since the
+ * last time this register was cleared. */
+#define PGLUE_B_REG_TX_ERR_RD_DETAILS2				 0x90a4
+/* [R 32] Address [31:0] of first write request not submitted due to error */
+#define PGLUE_B_REG_TX_ERR_WR_ADD_31_0				 0x9088
+/* [R 32] Address [63:32] of first write request not submitted due to error */
+#define PGLUE_B_REG_TX_ERR_WR_ADD_63_32			 0x908c
+/* [R 31] Details of first write request not submitted due to error. [4:0]
+ * VQID. [20:8] - Length in bytes. [23:21] - PFID. [24] - VF_VALID. [30:25]
+ * - VFID. */
+#define PGLUE_B_REG_TX_ERR_WR_DETAILS				 0x9090
+/* [R 26] Details of first write request not submitted due to error. [15:0]
+ * Request ID. [19:16] client ID. [20] - last SR. [24:21] - Error type -
+ * [21] - Indicates was_error was set; [22] - Indicates BME was cleared;
+ * [23] - Indicates FID_enable was cleared; [24] - Indicates VF with parent
+ * PF FLR_request or IOV_disable_request dirty bit is set. [25] valid -
+ * indicates if there was a request not submitted due to error since the
+ * last time this register was cleared. */
+#define PGLUE_B_REG_TX_ERR_WR_DETAILS2				 0x9094
+/* [RW 10] Type A PF/VF inbound interrupt table for USDM: bits[9:5]-mask;
+ * its[4:0]-address relative to start_offset_a. Bits [1:0] can have any
+ * value (Byte resolution address). */
+#define PGLUE_B_REG_USDM_INB_INT_A_0				 0x9128
+#define PGLUE_B_REG_USDM_INB_INT_A_1				 0x912c
+#define PGLUE_B_REG_USDM_INB_INT_A_2				 0x9130
+#define PGLUE_B_REG_USDM_INB_INT_A_3				 0x9134
+#define PGLUE_B_REG_USDM_INB_INT_A_4				 0x9138
+#define PGLUE_B_REG_USDM_INB_INT_A_5				 0x913c
+#define PGLUE_B_REG_USDM_INB_INT_A_6				 0x9140
+/* [RW 1] Type A PF enable inbound interrupt table for USDM. 0 - disable; 1
+ * - enable. */
+#define PGLUE_B_REG_USDM_INB_INT_A_PF_ENABLE			 0x917c
+/* [RW 1] Type A VF enable inbound interrupt table for USDM. 0 - disable; 1
+ * - enable. */
+#define PGLUE_B_REG_USDM_INB_INT_A_VF_ENABLE			 0x9180
+/* [RW 1] Type B VF enable inbound interrupt table for USDM. 0 - disable; 1
+ * - enable. */
+#define PGLUE_B_REG_USDM_INB_INT_B_VF_ENABLE			 0x9184
+/* [RW 16] Start offset of USDM zone A (queue zone) in the internal RAM */
+#define PGLUE_B_REG_USDM_START_OFFSET_A			 0x90d8
+/* [RW 16] Start offset of USDM zone B (legacy zone) in the internal RAM */
+#define PGLUE_B_REG_USDM_START_OFFSET_B			 0x90e0
+/* [RW 5] VF Shift of USDM zone B (legacy zone) in the internal RAM */
+#define PGLUE_B_REG_USDM_VF_SHIFT_B				 0x90e8
+/* [RW 1] 0 - Zone A size is 136x32B; 1 - Zone A size is 152x32B. */
+#define PGLUE_B_REG_USDM_ZONE_A_SIZE_PF			 0x91a4
+/* [R 26] Details of first target VF request accessing VF GRC space that
+ * failed permission check. [14:0] Address. [15] w_nr: 0 - Read; 1 - Write.
+ * [21:16] VFID. [24:22] - PFID. [25] valid - indicates if there was a
+ * request accessing VF GRC space that failed permission check since the
+ * last time this register was cleared. Permission checks are: function
+ * permission; R/W permission; address range permission. */
+#define PGLUE_B_REG_VF_GRC_SPACE_VIOLATION_DETAILS		 0x9234
+/* [R 31] Details of first target VF request with length violation (too many
+ * DWs) accessing BAR0. [12:0] Address in DWs (bits [14:2] of byte address).
+ * [14:13] BAR. [20:15] VFID. [23:21] - PFID. [29:24] - Length in DWs. [30]
+ * valid - indicates if there was a request with length violation since the
+ * last time this register was cleared. Length violations: length of more
+ * than 2DWs; length of 2DWs and address not QW aligned; window is GRC and
+ * length is more than 1 DW. */
+#define PGLUE_B_REG_VF_LENGTH_VIOLATION_DETAILS		 0x9230
+/* [R 8] Was_error indication dirty bits for PFs 0 to 7. Each bit indicates
+ * that there was a completion with uncorrectable error for the
+ * corresponding PF. Set by PXP. Reset by MCP writing 1 to
+ * was_error_pf_7_0_clr. */
+#define PGLUE_B_REG_WAS_ERROR_PF_7_0				 0x907c
+/* [W 8] Was_error indication dirty bits clear for PFs 0 to 7. MCP writes 1
+ * to a bit in this register in order to clear the corresponding bit in
+ * flr_request_pf_7_0 register. */
+#define PGLUE_B_REG_WAS_ERROR_PF_7_0_CLR			 0x9470
+/* [R 32] Was_error indication dirty bits for VFs 96 to 127. Each bit
+ * indicates that there was a completion with uncorrectable error for the
+ * corresponding VF. Set by PXP. Reset by MCP writing 1 to
+ * was_error_vf_127_96_clr. */
+#define PGLUE_B_REG_WAS_ERROR_VF_127_96			 0x9078
+/* [W 32] Was_error indication dirty bits clear for VFs 96 to 127. MCP
+ * writes 1 to a bit in this register in order to clear the corresponding
+ * bit in was_error_vf_127_96 register. */
+#define PGLUE_B_REG_WAS_ERROR_VF_127_96_CLR			 0x9474
+/* [R 32] Was_error indication dirty bits for VFs 0 to 31. Each bit
+ * indicates that there was a completion with uncorrectable error for the
+ * corresponding VF. Set by PXP. Reset by MCP writing 1 to
+ * was_error_vf_31_0_clr. */
+#define PGLUE_B_REG_WAS_ERROR_VF_31_0				 0x906c
+/* [W 32] Was_error indication dirty bits clear for VFs 0 to 31. MCP writes
+ * 1 to a bit in this register in order to clear the corresponding bit in
+ * was_error_vf_31_0 register. */
+#define PGLUE_B_REG_WAS_ERROR_VF_31_0_CLR			 0x9478
+/* [R 32] Was_error indication dirty bits for VFs 32 to 63. Each bit
+ * indicates that there was a completion with uncorrectable error for the
+ * corresponding VF. Set by PXP. Reset by MCP writing 1 to
+ * was_error_vf_63_32_clr. */
+#define PGLUE_B_REG_WAS_ERROR_VF_63_32				 0x9070
+/* [W 32] Was_error indication dirty bits clear for VFs 32 to 63. MCP writes
+ * 1 to a bit in this register in order to clear the corresponding bit in
+ * was_error_vf_63_32 register. */
+#define PGLUE_B_REG_WAS_ERROR_VF_63_32_CLR			 0x947c
+/* [R 32] Was_error indication dirty bits for VFs 64 to 95. Each bit
+ * indicates that there was a completion with uncorrectable error for the
+ * corresponding VF. Set by PXP. Reset by MCP writing 1 to
+ * was_error_vf_95_64_clr. */
+#define PGLUE_B_REG_WAS_ERROR_VF_95_64				 0x9074
+/* [W 32] Was_error indication dirty bits clear for VFs 64 to 95. MCP writes
+ * 1 to a bit in this register in order to clear the corresponding bit in
+ * was_error_vf_95_64 register. */
+#define PGLUE_B_REG_WAS_ERROR_VF_95_64_CLR			 0x9480
+/* [RW 1] Type A PF enable inbound interrupt table for XSDM. 0 - disable; 1
+ * - enable. */
+#define PGLUE_B_REG_XSDM_INB_INT_A_PF_ENABLE			 0x9188
+/* [RW 16] Start offset of XSDM zone A (queue zone) in the internal RAM */
+#define PGLUE_B_REG_XSDM_START_OFFSET_A			 0x90ec
+/* [RW 16] Start offset of XSDM zone B (legacy zone) in the internal RAM */
+#define PGLUE_B_REG_XSDM_START_OFFSET_B			 0x90f4
+/* [RW 5] VF Shift of XSDM zone B (legacy zone) in the internal RAM */
+#define PGLUE_B_REG_XSDM_VF_SHIFT_B				 0x90fc
+/* [RW 1] 0 - Zone A size is 136x32B; 1 - Zone A size is 152x32B. */
+#define PGLUE_B_REG_XSDM_ZONE_A_SIZE_PF			 0x91a8
 #define PRS_REG_A_PRSU_20					 0x40134
 /* [R 8] debug only: CFC load request current credit. Transaction based. */
 #define PRS_REG_CFC_LD_CURRENT_CREDIT				 0x40164
@@ -1866,9 +2366,13 @@
 #define PRS_REG_FLUSH_REGIONS_TYPE_5				 0x40018
 #define PRS_REG_FLUSH_REGIONS_TYPE_6				 0x4001c
 #define PRS_REG_FLUSH_REGIONS_TYPE_7				 0x40020
+/* [RW 6] Bit-map indicating which L2 hdrs may appear after the basic
+ * Ethernet header. */
+#define PRS_REG_HDRS_AFTER_BASIC				 0x40238
 /* [RW 4] The increment value to send in the CFC load request message */
 #define PRS_REG_INC_VALUE					 0x40048
-/* [RW 1] If set indicates not to send messages to CFC on received packets */
+/* [RW 6] Bit-map indicating which headers must appear in the packet */
+#define PRS_REG_MUST_HAVE_HDRS					 0x40254
 #define PRS_REG_NIC_MODE					 0x40138
 /* [RW 8] The 8-bit event ID for cases where there is no match on the
    connection. Used in packet start message to TCM. */
@@ -1919,6 +2423,13 @@
 #define PRS_REG_TCM_CURRENT_CREDIT				 0x40160
 /* [R 8] debug only: TSDM current credit. Transaction based. */
 #define PRS_REG_TSDM_CURRENT_CREDIT				 0x4015c
+#define PXP2_PXP2_INT_MASK_0_REG_PGL_CPL_AFT			 (0x1<<19)
+#define PXP2_PXP2_INT_MASK_0_REG_PGL_CPL_OF			 (0x1<<20)
+#define PXP2_PXP2_INT_MASK_0_REG_PGL_PCIE_ATTN			 (0x1<<22)
+#define PXP2_PXP2_INT_MASK_0_REG_PGL_READ_BLOCKED		 (0x1<<23)
+#define PXP2_PXP2_INT_MASK_0_REG_PGL_WRITE_BLOCKED		 (0x1<<24)
+#define PXP2_PXP2_INT_STS_0_REG_WR_PGLUE_EOP_ERROR		 (0x1<<7)
+#define PXP2_PXP2_INT_STS_CLR_0_REG_WR_PGLUE_EOP_ERROR		 (0x1<<7)
 /* [R 6] Debug only: Number of used entries in the data FIFO */
 #define PXP2_REG_HST_DATA_FIFO_STATUS				 0x12047c
 /* [R 7] Debug only: Number of used entries in the header FIFO */
@@ -2244,8 +2755,17 @@
 /* [RW 1] When '1'; requests will enter input buffers but wont get out
    towards the glue */
 #define PXP2_REG_RQ_DISABLE_INPUTS				 0x120330
-/* [RW 1] 1 - SR will be aligned by 64B; 0 - SR will be aligned by 8B */
+/* [RW 4] Determines alignment of write SRs when a request is split into
+ * several SRs. 0 - 8B aligned. 1 - 64B aligned. 2 - 128B aligned. 3 - 256B
+ * aligned. 4 - 512B aligned. */
 #define PXP2_REG_RQ_DRAM_ALIGN					 0x1205b0
+/* [RW 4] Determines alignment of read SRs when a request is split into
+ * several SRs. 0 - 8B aligned. 1 - 64B aligned. 2 - 128B aligned. 3 - 256B
+ * aligned. 4 - 512B aligned. */
+#define PXP2_REG_RQ_DRAM_ALIGN_RD				 0x12092c
+/* [RW 1] when set the new alignment method (E2) will be applied; when reset
+ * the original alignment method (E1 E1H) will be applied */
+#define PXP2_REG_RQ_DRAM_ALIGN_SEL				 0x120930
 /* [RW 1] If 1 ILT failiue will not result in ELT access; An interrupt will
    be asserted */
 #define PXP2_REG_RQ_ELT_DISABLE 				 0x12066c
@@ -2436,7 +2956,8 @@
 #define PXP_REG_PXP_INT_STS_1					 0x103078
 /* [RC 32] Interrupt register #0 read clear */
 #define PXP_REG_PXP_INT_STS_CLR_0				 0x10306c
-/* [RW 26] Parity mask register #0 read/write */
+#define PXP_REG_PXP_INT_STS_CLR_1				 0x10307c
+/* [RW 27] Parity mask register #0 read/write */
 #define PXP_REG_PXP_PRTY_MASK					 0x103094
 /* [R 26] Parity register #0 read */
 #define PXP_REG_PXP_PRTY_STS					 0x103088
@@ -2566,6 +3087,7 @@
 #define QM_REG_PAUSESTATE7					 0x16e698
 /* [RW 2] The PCI attributes field used in the PCI request. */
 #define QM_REG_PCIREQAT 					 0x168054
+#define QM_REG_PF_EN						 0x16e70c
 /* [R 16] The byte credit of port 0 */
 #define QM_REG_PORT0BYTECRD					 0x168300
 /* [R 16] The byte credit of port 1 */
@@ -3402,6 +3924,14 @@
 /* [R 32] Parity register #0 read */
 #define TSEM_REG_TSEM_PRTY_STS_0				 0x180114
 #define TSEM_REG_TSEM_PRTY_STS_1				 0x180124
+/* [W 7] VF or PF ID for reset error bit. Values 0-63 reset error bit for 64
+ * VF; values 64-67 reset error for 4 PF; values 68-127 are not valid. */
+#define TSEM_REG_VFPF_ERR_NUM					 0x180380
+/* [RW 32] Indirect access to AG context with 32-bits granularity. The bits
+ * [10:8] of the address should be the offset within the accessed LCID
+ * context; the bits [7:0] are the accessed LCID.Example: to write to REG10
+ * LCID100. The RBC address should be 12'ha64. */
+#define UCM_REG_AG_CTX						 0xe2000
 /* [R 5] Used to read the XX protection CAM occupancy counter. */
 #define UCM_REG_CAM_OCCUP					 0xe0170
 /* [RW 1] CDU AG read Interface enable. If 0 - the request input is
@@ -3851,6 +4381,17 @@
 /* [R 32] Parity register #0 read */
 #define USEM_REG_USEM_PRTY_STS_0				 0x300124
 #define USEM_REG_USEM_PRTY_STS_1				 0x300134
+/* [W 7] VF or PF ID for reset error bit. Values 0-63 reset error bit for 64
+ * VF; values 64-67 reset error for 4 PF; values 68-127 are not valid. */
+#define USEM_REG_VFPF_ERR_NUM					 0x300380
+#define VFC_MEMORIES_RST_REG_CAM_RST				 (0x1<<0)
+#define VFC_MEMORIES_RST_REG_RAM_RST				 (0x1<<1)
+#define VFC_REG_MEMORIES_RST					 0x1943c
+/* [RW 32] Indirect access to AG context with 32-bits granularity. The bits
+ * [12:8] of the address should be the offset within the accessed LCID
+ * context; the bits [7:0] are the accessed LCID.Example: to write to REG10
+ * LCID100. The RBC address should be 13'ha64. */
+#define XCM_REG_AG_CTX						 0x28000
 /* [RW 2] The queue index for registration on Aux1 counter flag. */
 #define XCM_REG_AUX1_Q						 0x20134
 /* [RW 2] Per each decision rule the queue index to register to. */
@@ -4333,6 +4874,9 @@
 #define XSEM_REG_TS_8_AS					 0x280058
 /* [RW 3] The arbitration scheme of time_slot 9 */
 #define XSEM_REG_TS_9_AS					 0x28005c
+/* [W 7] VF or PF ID for reset error bit. Values 0-63 reset error bit for 64
+ * VF; values 64-67 reset error for 4 PF; values 68-127 are not valid. */
+#define XSEM_REG_VFPF_ERR_NUM					 0x280380
 /* [RW 32] Interrupt mask register #0 read/write */
 #define XSEM_REG_XSEM_INT_MASK_0				 0x280110
 #define XSEM_REG_XSEM_INT_MASK_1				 0x280120
@@ -4371,6 +4915,23 @@
 #define BIGMAC_REGISTER_TX_SOURCE_ADDR				 (0x08<<3)
 #define BIGMAC_REGISTER_TX_STAT_GTBYT				 (0x20<<3)
 #define BIGMAC_REGISTER_TX_STAT_GTPKT				 (0x0C<<3)
+#define BIGMAC2_REGISTER_BMAC_CONTROL				 (0x00<<3)
+#define BIGMAC2_REGISTER_BMAC_XGXS_CONTROL			 (0x01<<3)
+#define BIGMAC2_REGISTER_CNT_MAX_SIZE				 (0x05<<3)
+#define BIGMAC2_REGISTER_PFC_CONTROL				 (0x06<<3)
+#define BIGMAC2_REGISTER_RX_CONTROL				 (0x3A<<3)
+#define BIGMAC2_REGISTER_RX_LLFC_MSG_FLDS			 (0x62<<3)
+#define BIGMAC2_REGISTER_RX_MAX_SIZE				 (0x3C<<3)
+#define BIGMAC2_REGISTER_RX_STAT_GR64				 (0x40<<3)
+#define BIGMAC2_REGISTER_RX_STAT_GRIPJ				 (0x5f<<3)
+#define BIGMAC2_REGISTER_RX_STAT_GRPP				 (0x51<<3)
+#define BIGMAC2_REGISTER_TX_CONTROL				 (0x1C<<3)
+#define BIGMAC2_REGISTER_TX_MAX_SIZE				 (0x1E<<3)
+#define BIGMAC2_REGISTER_TX_PAUSE_CONTROL			 (0x20<<3)
+#define BIGMAC2_REGISTER_TX_SOURCE_ADDR			 (0x1D<<3)
+#define BIGMAC2_REGISTER_TX_STAT_GTBYT				 (0x39<<3)
+#define BIGMAC2_REGISTER_TX_STAT_GTPOK				 (0x22<<3)
+#define BIGMAC2_REGISTER_TX_STAT_GTPP				 (0x24<<3)
 #define EMAC_LED_1000MB_OVERRIDE				 (1L<<1)
 #define EMAC_LED_100MB_OVERRIDE 				 (1L<<2)
 #define EMAC_LED_10MB_OVERRIDE					 (1L<<3)
@@ -4478,6 +5039,8 @@
 #define HW_LOCK_RESOURCE_SPIO					 2
 #define HW_LOCK_RESOURCE_UNDI					 5
 #define PRS_FLAG_OVERETH_IPV4					 1
+#define AEU_INPUTS_ATTN_BITS_ATC_HW_INTERRUPT		      (0x1<<4)
+#define AEU_INPUTS_ATTN_BITS_ATC_PARITY_ERROR		      (0x1<<5)
 #define AEU_INPUTS_ATTN_BITS_BRB_PARITY_ERROR		      (1<<18)
 #define AEU_INPUTS_ATTN_BITS_CCM_HW_INTERRUPT		      (1<<31)
 #define AEU_INPUTS_ATTN_BITS_CDU_HW_INTERRUPT		      (1<<9)
@@ -4504,6 +5067,8 @@
 #define AEU_INPUTS_ATTN_BITS_PARSER_PARITY_ERROR	      (1<<20)
 #define AEU_INPUTS_ATTN_BITS_PBCLIENT_PARITY_ERROR	      (1<<0)
 #define AEU_INPUTS_ATTN_BITS_PBF_HW_INTERRUPT		      (1<<31)
+#define AEU_INPUTS_ATTN_BITS_PGLUE_HW_INTERRUPT	      (0x1<<2)
+#define AEU_INPUTS_ATTN_BITS_PGLUE_PARITY_ERROR	      (0x1<<3)
 #define AEU_INPUTS_ATTN_BITS_PXP_HW_INTERRUPT		      (1<<3)
 #define AEU_INPUTS_ATTN_BITS_PXP_PARITY_ERROR		      (1<<2)
 #define AEU_INPUTS_ATTN_BITS_PXPPCICLOCKCLIENT_HW_INTERRUPT   (1<<5)
@@ -4796,6 +5361,253 @@
 #define PCI_ID_VAL1					0x434
 #define PCI_ID_VAL2					0x438
 
+#define PXPCS_TL_CONTROL_5		    0x814
+#define PXPCS_TL_CONTROL_5_UNKNOWNTYPE_ERR_ATTN    (1 << 29) /*WC*/
+#define PXPCS_TL_CONTROL_5_BOUNDARY4K_ERR_ATTN	   (1 << 28)   /*WC*/
+#define PXPCS_TL_CONTROL_5_MRRS_ERR_ATTN   (1 << 27)   /*WC*/
+#define PXPCS_TL_CONTROL_5_MPS_ERR_ATTN    (1 << 26)   /*WC*/
+#define PXPCS_TL_CONTROL_5_TTX_BRIDGE_FORWARD_ERR  (1 << 25)   /*WC*/
+#define PXPCS_TL_CONTROL_5_TTX_TXINTF_OVERFLOW	   (1 << 24)   /*WC*/
+#define PXPCS_TL_CONTROL_5_PHY_ERR_ATTN    (1 << 23)   /*RO*/
+#define PXPCS_TL_CONTROL_5_DL_ERR_ATTN	   (1 << 22)   /*RO*/
+#define PXPCS_TL_CONTROL_5_TTX_ERR_NP_TAG_IN_USE   (1 << 21)   /*WC*/
+#define PXPCS_TL_CONTROL_5_TRX_ERR_UNEXP_RTAG  (1 << 20)   /*WC*/
+#define PXPCS_TL_CONTROL_5_PRI_SIG_TARGET_ABORT1   (1 << 19)   /*WC*/
+#define PXPCS_TL_CONTROL_5_ERR_UNSPPORT1   (1 << 18)   /*WC*/
+#define PXPCS_TL_CONTROL_5_ERR_ECRC1   (1 << 17)   /*WC*/
+#define PXPCS_TL_CONTROL_5_ERR_MALF_TLP1   (1 << 16)   /*WC*/
+#define PXPCS_TL_CONTROL_5_ERR_RX_OFLOW1   (1 << 15)   /*WC*/
+#define PXPCS_TL_CONTROL_5_ERR_UNEXP_CPL1  (1 << 14)   /*WC*/
+#define PXPCS_TL_CONTROL_5_ERR_MASTER_ABRT1    (1 << 13)   /*WC*/
+#define PXPCS_TL_CONTROL_5_ERR_CPL_TIMEOUT1    (1 << 12)   /*WC*/
+#define PXPCS_TL_CONTROL_5_ERR_FC_PRTL1    (1 << 11)   /*WC*/
+#define PXPCS_TL_CONTROL_5_ERR_PSND_TLP1   (1 << 10)   /*WC*/
+#define PXPCS_TL_CONTROL_5_PRI_SIG_TARGET_ABORT    (1 << 9)    /*WC*/
+#define PXPCS_TL_CONTROL_5_ERR_UNSPPORT    (1 << 8)    /*WC*/
+#define PXPCS_TL_CONTROL_5_ERR_ECRC    (1 << 7)    /*WC*/
+#define PXPCS_TL_CONTROL_5_ERR_MALF_TLP    (1 << 6)    /*WC*/
+#define PXPCS_TL_CONTROL_5_ERR_RX_OFLOW    (1 << 5)    /*WC*/
+#define PXPCS_TL_CONTROL_5_ERR_UNEXP_CPL   (1 << 4)    /*WC*/
+#define PXPCS_TL_CONTROL_5_ERR_MASTER_ABRT     (1 << 3)    /*WC*/
+#define PXPCS_TL_CONTROL_5_ERR_CPL_TIMEOUT     (1 << 2)    /*WC*/
+#define PXPCS_TL_CONTROL_5_ERR_FC_PRTL	   (1 << 1)    /*WC*/
+#define PXPCS_TL_CONTROL_5_ERR_PSND_TLP    (1 << 0)    /*WC*/
+
+
+#define PXPCS_TL_FUNC345_STAT	   0x854
+#define PXPCS_TL_FUNC345_STAT_PRI_SIG_TARGET_ABORT4    (1 << 29)   /* WC */
+#define PXPCS_TL_FUNC345_STAT_ERR_UNSPPORT4\
+	(1 << 28) /* Unsupported Request Error Status in function4, if \
+	set, generate pcie_err_attn output when this error is seen. WC */
+#define PXPCS_TL_FUNC345_STAT_ERR_ECRC4\
+	(1 << 27) /* ECRC Error TLP Status Status in function 4, if set, \
+	generate pcie_err_attn output when this error is seen.. WC */
+#define PXPCS_TL_FUNC345_STAT_ERR_MALF_TLP4\
+	(1 << 26) /* Malformed TLP Status Status in function 4, if set, \
+	generate pcie_err_attn output when this error is seen.. WC */
+#define PXPCS_TL_FUNC345_STAT_ERR_RX_OFLOW4\
+	(1 << 25) /* Receiver Overflow Status Status in function 4, if \
+	set, generate pcie_err_attn output when this error is seen.. WC \
+	*/
+#define PXPCS_TL_FUNC345_STAT_ERR_UNEXP_CPL4\
+	(1 << 24) /* Unexpected Completion Status Status in function 4, \
+	if set, generate pcie_err_attn output when this error is seen. WC \
+	*/
+#define PXPCS_TL_FUNC345_STAT_ERR_MASTER_ABRT4\
+	(1 << 23) /* Receive UR Statusin function 4. If set, generate \
+	pcie_err_attn output when this error is seen. WC */
+#define PXPCS_TL_FUNC345_STAT_ERR_CPL_TIMEOUT4\
+	(1 << 22) /* Completer Timeout Status Status in function 4, if \
+	set, generate pcie_err_attn output when this error is seen. WC */
+#define PXPCS_TL_FUNC345_STAT_ERR_FC_PRTL4\
+	(1 << 21) /* Flow Control Protocol Error Status Status in \
+	function 4, if set, generate pcie_err_attn output when this error \
+	is seen. WC */
+#define PXPCS_TL_FUNC345_STAT_ERR_PSND_TLP4\
+	(1 << 20) /* Poisoned Error Status Status in function 4, if set, \
+	generate pcie_err_attn output when this error is seen.. WC */
+#define PXPCS_TL_FUNC345_STAT_PRI_SIG_TARGET_ABORT3    (1 << 19)   /* WC */
+#define PXPCS_TL_FUNC345_STAT_ERR_UNSPPORT3\
+	(1 << 18) /* Unsupported Request Error Status in function3, if \
+	set, generate pcie_err_attn output when this error is seen. WC */
+#define PXPCS_TL_FUNC345_STAT_ERR_ECRC3\
+	(1 << 17) /* ECRC Error TLP Status Status in function 3, if set, \
+	generate pcie_err_attn output when this error is seen.. WC */
+#define PXPCS_TL_FUNC345_STAT_ERR_MALF_TLP3\
+	(1 << 16) /* Malformed TLP Status Status in function 3, if set, \
+	generate pcie_err_attn output when this error is seen.. WC */
+#define PXPCS_TL_FUNC345_STAT_ERR_RX_OFLOW3\
+	(1 << 15) /* Receiver Overflow Status Status in function 3, if \
+	set, generate pcie_err_attn output when this error is seen.. WC \
+	*/
+#define PXPCS_TL_FUNC345_STAT_ERR_UNEXP_CPL3\
+	(1 << 14) /* Unexpected Completion Status Status in function 3, \
+	if set, generate pcie_err_attn output when this error is seen. WC \
+	*/
+#define PXPCS_TL_FUNC345_STAT_ERR_MASTER_ABRT3\
+	(1 << 13) /* Receive UR Statusin function 3. If set, generate \
+	pcie_err_attn output when this error is seen. WC */
+#define PXPCS_TL_FUNC345_STAT_ERR_CPL_TIMEOUT3\
+	(1 << 12) /* Completer Timeout Status Status in function 3, if \
+	set, generate pcie_err_attn output when this error is seen. WC */
+#define PXPCS_TL_FUNC345_STAT_ERR_FC_PRTL3\
+	(1 << 11) /* Flow Control Protocol Error Status Status in \
+	function 3, if set, generate pcie_err_attn output when this error \
+	is seen. WC */
+#define PXPCS_TL_FUNC345_STAT_ERR_PSND_TLP3\
+	(1 << 10) /* Poisoned Error Status Status in function 3, if set, \
+	generate pcie_err_attn output when this error is seen.. WC */
+#define PXPCS_TL_FUNC345_STAT_PRI_SIG_TARGET_ABORT2    (1 << 9)    /* WC */
+#define PXPCS_TL_FUNC345_STAT_ERR_UNSPPORT2\
+	(1 << 8) /* Unsupported Request Error Status for Function 2, if \
+	set, generate pcie_err_attn output when this error is seen. WC */
+#define PXPCS_TL_FUNC345_STAT_ERR_ECRC2\
+	(1 << 7) /* ECRC Error TLP Status Status for Function 2, if set, \
+	generate pcie_err_attn output when this error is seen.. WC */
+#define PXPCS_TL_FUNC345_STAT_ERR_MALF_TLP2\
+	(1 << 6) /* Malformed TLP Status Status for Function 2, if set, \
+	generate pcie_err_attn output when this error is seen.. WC */
+#define PXPCS_TL_FUNC345_STAT_ERR_RX_OFLOW2\
+	(1 << 5) /* Receiver Overflow Status Status for Function 2, if \
+	set, generate pcie_err_attn output when this error is seen.. WC \
+	*/
+#define PXPCS_TL_FUNC345_STAT_ERR_UNEXP_CPL2\
+	(1 << 4) /* Unexpected Completion Status Status for Function 2, \
+	if set, generate pcie_err_attn output when this error is seen. WC \
+	*/
+#define PXPCS_TL_FUNC345_STAT_ERR_MASTER_ABRT2\
+	(1 << 3) /* Receive UR Statusfor Function 2. If set, generate \
+	pcie_err_attn output when this error is seen. WC */
+#define PXPCS_TL_FUNC345_STAT_ERR_CPL_TIMEOUT2\
+	(1 << 2) /* Completer Timeout Status Status for Function 2, if \
+	set, generate pcie_err_attn output when this error is seen. WC */
+#define PXPCS_TL_FUNC345_STAT_ERR_FC_PRTL2\
+	(1 << 1) /* Flow Control Protocol Error Status Status for \
+	Function 2, if set, generate pcie_err_attn output when this error \
+	is seen. WC */
+#define PXPCS_TL_FUNC345_STAT_ERR_PSND_TLP2\
+	(1 << 0) /* Poisoned Error Status Status for Function 2, if set, \
+	generate pcie_err_attn output when this error is seen.. WC */
+
+
+#define PXPCS_TL_FUNC678_STAT  0x85C
+#define PXPCS_TL_FUNC678_STAT_PRI_SIG_TARGET_ABORT7    (1 << 29)   /*	 WC */
+#define PXPCS_TL_FUNC678_STAT_ERR_UNSPPORT7\
+	(1 << 28) /* Unsupported Request Error Status in function7, if \
+	set, generate pcie_err_attn output when this error is seen. WC */
+#define PXPCS_TL_FUNC678_STAT_ERR_ECRC7\
+	(1 << 27) /* ECRC Error TLP Status Status in function 7, if set, \
+	generate pcie_err_attn output when this error is seen.. WC */
+#define PXPCS_TL_FUNC678_STAT_ERR_MALF_TLP7\
+	(1 << 26) /* Malformed TLP Status Status in function 7, if set, \
+	generate pcie_err_attn output when this error is seen.. WC */
+#define PXPCS_TL_FUNC678_STAT_ERR_RX_OFLOW7\
+	(1 << 25) /* Receiver Overflow Status Status in function 7, if \
+	set, generate pcie_err_attn output when this error is seen.. WC \
+	*/
+#define PXPCS_TL_FUNC678_STAT_ERR_UNEXP_CPL7\
+	(1 << 24) /* Unexpected Completion Status Status in function 7, \
+	if set, generate pcie_err_attn output when this error is seen. WC \
+	*/
+#define PXPCS_TL_FUNC678_STAT_ERR_MASTER_ABRT7\
+	(1 << 23) /* Receive UR Statusin function 7. If set, generate \
+	pcie_err_attn output when this error is seen. WC */
+#define PXPCS_TL_FUNC678_STAT_ERR_CPL_TIMEOUT7\
+	(1 << 22) /* Completer Timeout Status Status in function 7, if \
+	set, generate pcie_err_attn output when this error is seen. WC */
+#define PXPCS_TL_FUNC678_STAT_ERR_FC_PRTL7\
+	(1 << 21) /* Flow Control Protocol Error Status Status in \
+	function 7, if set, generate pcie_err_attn output when this error \
+	is seen. WC */
+#define PXPCS_TL_FUNC678_STAT_ERR_PSND_TLP7\
+	(1 << 20) /* Poisoned Error Status Status in function 7, if set, \
+	generate pcie_err_attn output when this error is seen.. WC */
+#define PXPCS_TL_FUNC678_STAT_PRI_SIG_TARGET_ABORT6    (1 << 19)    /*	  WC */
+#define PXPCS_TL_FUNC678_STAT_ERR_UNSPPORT6\
+	(1 << 18) /* Unsupported Request Error Status in function6, if \
+	set, generate pcie_err_attn output when this error is seen. WC */
+#define PXPCS_TL_FUNC678_STAT_ERR_ECRC6\
+	(1 << 17) /* ECRC Error TLP Status Status in function 6, if set, \
+	generate pcie_err_attn output when this error is seen.. WC */
+#define PXPCS_TL_FUNC678_STAT_ERR_MALF_TLP6\
+	(1 << 16) /* Malformed TLP Status Status in function 6, if set, \
+	generate pcie_err_attn output when this error is seen.. WC */
+#define PXPCS_TL_FUNC678_STAT_ERR_RX_OFLOW6\
+	(1 << 15) /* Receiver Overflow Status Status in function 6, if \
+	set, generate pcie_err_attn output when this error is seen.. WC \
+	*/
+#define PXPCS_TL_FUNC678_STAT_ERR_UNEXP_CPL6\
+	(1 << 14) /* Unexpected Completion Status Status in function 6, \
+	if set, generate pcie_err_attn output when this error is seen. WC \
+	*/
+#define PXPCS_TL_FUNC678_STAT_ERR_MASTER_ABRT6\
+	(1 << 13) /* Receive UR Statusin function 6. If set, generate \
+	pcie_err_attn output when this error is seen. WC */
+#define PXPCS_TL_FUNC678_STAT_ERR_CPL_TIMEOUT6\
+	(1 << 12) /* Completer Timeout Status Status in function 6, if \
+	set, generate pcie_err_attn output when this error is seen. WC */
+#define PXPCS_TL_FUNC678_STAT_ERR_FC_PRTL6\
+	(1 << 11) /* Flow Control Protocol Error Status Status in \
+	function 6, if set, generate pcie_err_attn output when this error \
+	is seen. WC */
+#define PXPCS_TL_FUNC678_STAT_ERR_PSND_TLP6\
+	(1 << 10) /* Poisoned Error Status Status in function 6, if set, \
+	generate pcie_err_attn output when this error is seen.. WC */
+#define PXPCS_TL_FUNC678_STAT_PRI_SIG_TARGET_ABORT5    (1 << 9) /*    WC */
+#define PXPCS_TL_FUNC678_STAT_ERR_UNSPPORT5\
+	(1 << 8) /* Unsupported Request Error Status for Function 5, if \
+	set, generate pcie_err_attn output when this error is seen. WC */
+#define PXPCS_TL_FUNC678_STAT_ERR_ECRC5\
+	(1 << 7) /* ECRC Error TLP Status Status for Function 5, if set, \
+	generate pcie_err_attn output when this error is seen.. WC */
+#define PXPCS_TL_FUNC678_STAT_ERR_MALF_TLP5\
+	(1 << 6) /* Malformed TLP Status Status for Function 5, if set, \
+	generate pcie_err_attn output when this error is seen.. WC */
+#define PXPCS_TL_FUNC678_STAT_ERR_RX_OFLOW5\
+	(1 << 5) /* Receiver Overflow Status Status for Function 5, if \
+	set, generate pcie_err_attn output when this error is seen.. WC \
+	*/
+#define PXPCS_TL_FUNC678_STAT_ERR_UNEXP_CPL5\
+	(1 << 4) /* Unexpected Completion Status Status for Function 5, \
+	if set, generate pcie_err_attn output when this error is seen. WC \
+	*/
+#define PXPCS_TL_FUNC678_STAT_ERR_MASTER_ABRT5\
+	(1 << 3) /* Receive UR Statusfor Function 5. If set, generate \
+	pcie_err_attn output when this error is seen. WC */
+#define PXPCS_TL_FUNC678_STAT_ERR_CPL_TIMEOUT5\
+	(1 << 2) /* Completer Timeout Status Status for Function 5, if \
+	set, generate pcie_err_attn output when this error is seen. WC */
+#define PXPCS_TL_FUNC678_STAT_ERR_FC_PRTL5\
+	(1 << 1) /* Flow Control Protocol Error Status Status for \
+	Function 5, if set, generate pcie_err_attn output when this error \
+	is seen. WC */
+#define PXPCS_TL_FUNC678_STAT_ERR_PSND_TLP5\
+	(1 << 0) /* Poisoned Error Status Status for Function 5, if set, \
+	generate pcie_err_attn output when this error is seen.. WC */
+
+
+#define BAR_USTRORM_INTMEM				0x400000
+#define BAR_CSTRORM_INTMEM				0x410000
+#define BAR_XSTRORM_INTMEM				0x420000
+#define BAR_TSTRORM_INTMEM				0x430000
+
+/* for accessing the IGU in case of status block ACK */
+#define BAR_IGU_INTMEM					0x440000
+
+#define BAR_DOORBELL_OFFSET				0x800000
+
+#define BAR_ME_REGISTER				0x450000
+#define ME_REG_PF_NUM_SHIFT		0
+#define ME_REG_PF_NUM\
+	(7L<<ME_REG_PF_NUM_SHIFT) /* Relative PF Num */
+#define ME_REG_VF_VALID		(1<<8)
+#define ME_REG_VF_NUM_SHIFT		9
+#define ME_REG_VF_NUM_MASK		(0x3f<<ME_REG_VF_NUM_SHIFT)
+#define ME_REG_VF_ERR			(0x1<<3)
+#define ME_REG_ABS_PF_NUM_SHIFT	16
+#define ME_REG_ABS_PF_NUM\
+	(7L<<ME_REG_ABS_PF_NUM_SHIFT) /* Absolute PF Num */
+
 
 #define MDIO_REG_BANK_CL73_IEEEB0	0x0
 #define MDIO_CL73_IEEEB0_CL73_AN_CONTROL	0x0
@@ -5276,6 +6088,11 @@ Theotherbitsarereservedandshouldbezero*/
 #define IGU_INT_NOP				2
 #define IGU_INT_NOP2			3
 
+#define IGU_USE_REGISTER_ustorm_type_0_sb_cleanup  0
+#define IGU_USE_REGISTER_ustorm_type_1_sb_cleanup  1
+#define IGU_USE_REGISTER_cstorm_type_0_sb_cleanup  2
+#define IGU_USE_REGISTER_cstorm_type_1_sb_cleanup  3
+
 #define COMMAND_REG_INT_ACK	    0x0
 #define COMMAND_REG_PROD_UPD	    0x4
 #define COMMAND_REG_ATTN_BITS_UPD   0x8
@@ -5318,6 +6135,50 @@ Theotherbitsarereservedandshouldbezero*/
 #define IGU_REG_SISR_MDPC_WOMASK_UPPER		0x05a6
 
 #define IGU_REG_RESERVED_UPPER				0x05ff
+/* Fields of IGU PF CONFIGRATION REGISTER */
+#define IGU_PF_CONF_FUNC_EN	  (0x1<<0)  /* function enable	      */
+#define IGU_PF_CONF_MSI_MSIX_EN   (0x1<<1)  /* MSI/MSIX enable	      */
+#define IGU_PF_CONF_INT_LINE_EN   (0x1<<2)  /* INT enable	      */
+#define IGU_PF_CONF_ATTN_BIT_EN   (0x1<<3)  /* attention enable       */
+#define IGU_PF_CONF_SINGLE_ISR_EN (0x1<<4)  /* single ISR mode enable */
+#define IGU_PF_CONF_SIMD_MODE	  (0x1<<5)  /* simd all ones mode     */
+
+/* Fields of IGU VF CONFIGRATION REGISTER */
+#define IGU_VF_CONF_FUNC_EN	   (0x1<<0)  /* function enable        */
+#define IGU_VF_CONF_MSI_MSIX_EN    (0x1<<1)  /* MSI/MSIX enable        */
+#define IGU_VF_CONF_PARENT_MASK    (0x3<<2)  /* Parent PF	       */
+#define IGU_VF_CONF_PARENT_SHIFT   2	     /* Parent PF	       */
+#define IGU_VF_CONF_SINGLE_ISR_EN  (0x1<<4)  /* single ISR mode enable */
+
+
+#define IGU_BC_DSB_NUM_SEGS    5
+#define IGU_BC_NDSB_NUM_SEGS   2
+#define IGU_NORM_DSB_NUM_SEGS  2
+#define IGU_NORM_NDSB_NUM_SEGS 1
+#define IGU_BC_BASE_DSB_PROD   128
+#define IGU_NORM_BASE_DSB_PROD 136
+
+#define IGU_CTRL_CMD_TYPE_WR\
+	1
+#define IGU_CTRL_CMD_TYPE_RD\
+	0
+
+#define IGU_SEG_ACCESS_NORM   0
+#define IGU_SEG_ACCESS_DEF    1
+#define IGU_SEG_ACCESS_ATTN   2
+
+	/* FID (if VF - [6] = 0; [5:0] = VF number; if PF - [6] = 1; \
+	[5:2] = 0; [1:0] = PF number) */
+#define IGU_FID_ENCODE_IS_PF	    (0x1<<6)
+#define IGU_FID_ENCODE_IS_PF_SHIFT  6
+#define IGU_FID_VF_NUM_MASK	    (0x3f)
+#define IGU_FID_PF_NUM_MASK	    (0x7)
+
+#define IGU_REG_MAPPING_MEMORY_VALID		(1<<0)
+#define IGU_REG_MAPPING_MEMORY_VECTOR_MASK	(0x3F<<1)
+#define IGU_REG_MAPPING_MEMORY_VECTOR_SHIFT	1
+#define IGU_REG_MAPPING_MEMORY_FID_MASK	(0x7F<<7)
+#define IGU_REG_MAPPING_MEMORY_FID_SHIFT	7
 
 
 #define CDU_REGION_NUMBER_XCM_AG 2
diff --git a/drivers/net/bnx2x/bnx2x_stats.c b/drivers/net/bnx2x/bnx2x_stats.c
index 32b6b10..ad7aa55 100644
--- a/drivers/net/bnx2x/bnx2x_stats.c
+++ b/drivers/net/bnx2x/bnx2x_stats.c
@@ -185,20 +185,12 @@ static void bnx2x_hw_stats_post(struct bnx2x *bp)
 	/* loader */
 	if (bp->executer_idx) {
 		int loader_idx = PMF_DMAE_C(bp);
+		u32 opcode =  bnx2x_dmae_opcode(bp, DMAE_SRC_PCI, DMAE_DST_GRC,
+						 true, DMAE_COMP_GRC);
+		opcode = bnx2x_dmae_opcode_clr_src_reset(opcode);
 
 		memset(dmae, 0, sizeof(struct dmae_command));
-
-		dmae->opcode = (DMAE_CMD_SRC_PCI | DMAE_CMD_DST_GRC |
-				DMAE_CMD_C_DST_GRC | DMAE_CMD_C_ENABLE |
-				DMAE_CMD_DST_RESET |
-#ifdef __BIG_ENDIAN
-				DMAE_CMD_ENDIANITY_B_DW_SWAP |
-#else
-				DMAE_CMD_ENDIANITY_DW_SWAP |
-#endif
-				(BP_PORT(bp) ? DMAE_CMD_PORT_1 :
-					       DMAE_CMD_PORT_0) |
-				(BP_E1HVN(bp) << DMAE_CMD_E1HVN_SHIFT));
+		dmae->opcode = opcode;
 		dmae->src_addr_lo = U64_LO(bnx2x_sp_mapping(bp, dmae[0]));
 		dmae->src_addr_hi = U64_HI(bnx2x_sp_mapping(bp, dmae[0]));
 		dmae->dst_addr_lo = (DMAE_REG_CMD_MEM +
@@ -257,19 +249,10 @@ static void bnx2x_stats_pmf_update(struct bnx2x *bp)
 
 	bp->executer_idx = 0;
 
-	opcode = (DMAE_CMD_SRC_GRC | DMAE_CMD_DST_PCI |
-		  DMAE_CMD_C_ENABLE |
-		  DMAE_CMD_SRC_RESET | DMAE_CMD_DST_RESET |
-#ifdef __BIG_ENDIAN
-		  DMAE_CMD_ENDIANITY_B_DW_SWAP |
-#else
-		  DMAE_CMD_ENDIANITY_DW_SWAP |
-#endif
-		  (BP_PORT(bp) ? DMAE_CMD_PORT_1 : DMAE_CMD_PORT_0) |
-		  (BP_E1HVN(bp) << DMAE_CMD_E1HVN_SHIFT));
+	opcode = bnx2x_dmae_opcode(bp, DMAE_SRC_GRC, DMAE_DST_PCI, false, 0);
 
 	dmae = bnx2x_sp(bp, dmae[bp->executer_idx++]);
-	dmae->opcode = (opcode | DMAE_CMD_C_DST_GRC);
+	dmae->opcode = bnx2x_dmae_opcode_add_comp(opcode, DMAE_COMP_GRC);
 	dmae->src_addr_lo = bp->port.port_stx >> 2;
 	dmae->src_addr_hi = 0;
 	dmae->dst_addr_lo = U64_LO(bnx2x_sp_mapping(bp, port_stats));
@@ -280,7 +263,7 @@ static void bnx2x_stats_pmf_update(struct bnx2x *bp)
 	dmae->comp_val = 1;
 
 	dmae = bnx2x_sp(bp, dmae[bp->executer_idx++]);
-	dmae->opcode = (opcode | DMAE_CMD_C_DST_PCI);
+	dmae->opcode = bnx2x_dmae_opcode_add_comp(opcode, DMAE_COMP_PCI);
 	dmae->src_addr_lo = (bp->port.port_stx >> 2) + DMAE_LEN32_RD_MAX;
 	dmae->src_addr_hi = 0;
 	dmae->dst_addr_lo = U64_LO(bnx2x_sp_mapping(bp, port_stats) +
@@ -301,7 +284,6 @@ static void bnx2x_port_stats_init(struct bnx2x *bp)
 {
 	struct dmae_command *dmae;
 	int port = BP_PORT(bp);
-	int vn = BP_E1HVN(bp);
 	u32 opcode;
 	int loader_idx = PMF_DMAE_C(bp);
 	u32 mac_addr;
@@ -316,16 +298,8 @@ static void bnx2x_port_stats_init(struct bnx2x *bp)
 	bp->executer_idx = 0;
 
 	/* MCP */
-	opcode = (DMAE_CMD_SRC_PCI | DMAE_CMD_DST_GRC |
-		  DMAE_CMD_C_DST_GRC | DMAE_CMD_C_ENABLE |
-		  DMAE_CMD_SRC_RESET | DMAE_CMD_DST_RESET |
-#ifdef __BIG_ENDIAN
-		  DMAE_CMD_ENDIANITY_B_DW_SWAP |
-#else
-		  DMAE_CMD_ENDIANITY_DW_SWAP |
-#endif
-		  (port ? DMAE_CMD_PORT_1 : DMAE_CMD_PORT_0) |
-		  (vn << DMAE_CMD_E1HVN_SHIFT));
+	opcode = bnx2x_dmae_opcode(bp, DMAE_SRC_PCI, DMAE_DST_GRC,
+				    true, DMAE_COMP_GRC);
 
 	if (bp->port.port_stx) {
 
@@ -356,16 +330,8 @@ static void bnx2x_port_stats_init(struct bnx2x *bp)
 	}
 
 	/* MAC */
-	opcode = (DMAE_CMD_SRC_GRC | DMAE_CMD_DST_PCI |
-		  DMAE_CMD_C_DST_GRC | DMAE_CMD_C_ENABLE |
-		  DMAE_CMD_SRC_RESET | DMAE_CMD_DST_RESET |
-#ifdef __BIG_ENDIAN
-		  DMAE_CMD_ENDIANITY_B_DW_SWAP |
-#else
-		  DMAE_CMD_ENDIANITY_DW_SWAP |
-#endif
-		  (port ? DMAE_CMD_PORT_1 : DMAE_CMD_PORT_0) |
-		  (vn << DMAE_CMD_E1HVN_SHIFT));
+	opcode = bnx2x_dmae_opcode(bp, DMAE_SRC_GRC, DMAE_DST_PCI,
+				   true, DMAE_COMP_GRC);
 
 	if (bp->link_vars.mac_type == MAC_TYPE_BMAC) {
 
@@ -376,13 +342,21 @@ static void bnx2x_port_stats_init(struct bnx2x *bp)
 		   BIGMAC_REGISTER_TX_STAT_GTBYT */
 		dmae = bnx2x_sp(bp, dmae[bp->executer_idx++]);
 		dmae->opcode = opcode;
-		dmae->src_addr_lo = (mac_addr +
+		if (CHIP_IS_E1x(bp)) {
+			dmae->src_addr_lo = (mac_addr +
 				     BIGMAC_REGISTER_TX_STAT_GTPKT) >> 2;
+			dmae->len = (8 + BIGMAC_REGISTER_TX_STAT_GTBYT -
+				     BIGMAC_REGISTER_TX_STAT_GTPKT) >> 2;
+		} else {
+			dmae->src_addr_lo = (mac_addr +
+				     BIGMAC2_REGISTER_TX_STAT_GTPOK) >> 2;
+			dmae->len = (8 + BIGMAC2_REGISTER_TX_STAT_GTBYT -
+				     BIGMAC2_REGISTER_TX_STAT_GTPOK) >> 2;
+		}
+
 		dmae->src_addr_hi = 0;
 		dmae->dst_addr_lo = U64_LO(bnx2x_sp_mapping(bp, mac_stats));
 		dmae->dst_addr_hi = U64_HI(bnx2x_sp_mapping(bp, mac_stats));
-		dmae->len = (8 + BIGMAC_REGISTER_TX_STAT_GTBYT -
-			     BIGMAC_REGISTER_TX_STAT_GTPKT) >> 2;
 		dmae->comp_addr_lo = dmae_reg_go_c[loader_idx] >> 2;
 		dmae->comp_addr_hi = 0;
 		dmae->comp_val = 1;
@@ -391,15 +365,31 @@ static void bnx2x_port_stats_init(struct bnx2x *bp)
 		   BIGMAC_REGISTER_RX_STAT_GRIPJ */
 		dmae = bnx2x_sp(bp, dmae[bp->executer_idx++]);
 		dmae->opcode = opcode;
-		dmae->src_addr_lo = (mac_addr +
-				     BIGMAC_REGISTER_RX_STAT_GR64) >> 2;
 		dmae->src_addr_hi = 0;
-		dmae->dst_addr_lo = U64_LO(bnx2x_sp_mapping(bp, mac_stats) +
+		if (CHIP_IS_E1x(bp)) {
+			dmae->src_addr_lo = (mac_addr +
+					     BIGMAC_REGISTER_RX_STAT_GR64) >> 2;
+			dmae->dst_addr_lo =
+				U64_LO(bnx2x_sp_mapping(bp, mac_stats) +
 				offsetof(struct bmac1_stats, rx_stat_gr64_lo));
-		dmae->dst_addr_hi = U64_HI(bnx2x_sp_mapping(bp, mac_stats) +
+			dmae->dst_addr_hi =
+				U64_HI(bnx2x_sp_mapping(bp, mac_stats) +
 				offsetof(struct bmac1_stats, rx_stat_gr64_lo));
-		dmae->len = (8 + BIGMAC_REGISTER_RX_STAT_GRIPJ -
-			     BIGMAC_REGISTER_RX_STAT_GR64) >> 2;
+			dmae->len = (8 + BIGMAC_REGISTER_RX_STAT_GRIPJ -
+				     BIGMAC_REGISTER_RX_STAT_GR64) >> 2;
+		} else {
+			dmae->src_addr_lo =
+				(mac_addr + BIGMAC2_REGISTER_RX_STAT_GR64) >> 2;
+			dmae->dst_addr_lo =
+				U64_LO(bnx2x_sp_mapping(bp, mac_stats) +
+				offsetof(struct bmac2_stats, rx_stat_gr64_lo));
+			dmae->dst_addr_hi =
+				U64_HI(bnx2x_sp_mapping(bp, mac_stats) +
+				offsetof(struct bmac2_stats, rx_stat_gr64_lo));
+			dmae->len = (8 + BIGMAC2_REGISTER_RX_STAT_GRIPJ -
+				     BIGMAC2_REGISTER_RX_STAT_GR64) >> 2;
+		}
+
 		dmae->comp_addr_lo = dmae_reg_go_c[loader_idx] >> 2;
 		dmae->comp_addr_hi = 0;
 		dmae->comp_val = 1;
@@ -480,16 +470,8 @@ static void bnx2x_port_stats_init(struct bnx2x *bp)
 	dmae->comp_val = 1;
 
 	dmae = bnx2x_sp(bp, dmae[bp->executer_idx++]);
-	dmae->opcode = (DMAE_CMD_SRC_GRC | DMAE_CMD_DST_PCI |
-			DMAE_CMD_C_DST_PCI | DMAE_CMD_C_ENABLE |
-			DMAE_CMD_SRC_RESET | DMAE_CMD_DST_RESET |
-#ifdef __BIG_ENDIAN
-			DMAE_CMD_ENDIANITY_B_DW_SWAP |
-#else
-			DMAE_CMD_ENDIANITY_DW_SWAP |
-#endif
-			(port ? DMAE_CMD_PORT_1 : DMAE_CMD_PORT_0) |
-			(vn << DMAE_CMD_E1HVN_SHIFT));
+	dmae->opcode = bnx2x_dmae_opcode(bp, DMAE_SRC_GRC, DMAE_DST_PCI,
+					 true, DMAE_COMP_PCI);
 	dmae->src_addr_lo = (port ? NIG_REG_STAT1_EGRESS_MAC_PKT1 :
 				    NIG_REG_STAT0_EGRESS_MAC_PKT1) >> 2;
 	dmae->src_addr_hi = 0;
@@ -519,16 +501,8 @@ static void bnx2x_func_stats_init(struct bnx2x *bp)
 	bp->executer_idx = 0;
 	memset(dmae, 0, sizeof(struct dmae_command));
 
-	dmae->opcode = (DMAE_CMD_SRC_PCI | DMAE_CMD_DST_GRC |
-			DMAE_CMD_C_DST_PCI | DMAE_CMD_C_ENABLE |
-			DMAE_CMD_SRC_RESET | DMAE_CMD_DST_RESET |
-#ifdef __BIG_ENDIAN
-			DMAE_CMD_ENDIANITY_B_DW_SWAP |
-#else
-			DMAE_CMD_ENDIANITY_DW_SWAP |
-#endif
-			(BP_PORT(bp) ? DMAE_CMD_PORT_1 : DMAE_CMD_PORT_0) |
-			(BP_E1HVN(bp) << DMAE_CMD_E1HVN_SHIFT));
+	dmae->opcode = bnx2x_dmae_opcode(bp, DMAE_SRC_PCI, DMAE_DST_GRC,
+					 true, DMAE_COMP_PCI);
 	dmae->src_addr_lo = U64_LO(bnx2x_sp_mapping(bp, func_stats));
 	dmae->src_addr_hi = U64_HI(bnx2x_sp_mapping(bp, func_stats));
 	dmae->dst_addr_lo = bp->func_stx >> 2;
@@ -568,7 +542,6 @@ static void bnx2x_stats_restart(struct bnx2x *bp)
 
 static void bnx2x_bmac_stats_update(struct bnx2x *bp)
 {
-	struct bmac1_stats *new = bnx2x_sp(bp, mac_stats.bmac1_stats);
 	struct host_port_stats *pstats = bnx2x_sp(bp, port_stats);
 	struct bnx2x_eth_stats *estats = &bp->eth_stats;
 	struct {
@@ -576,35 +549,74 @@ static void bnx2x_bmac_stats_update(struct bnx2x *bp)
 		u32 hi;
 	} diff;
 
-	UPDATE_STAT64(rx_stat_grerb, rx_stat_ifhcinbadoctets);
-	UPDATE_STAT64(rx_stat_grfcs, rx_stat_dot3statsfcserrors);
-	UPDATE_STAT64(rx_stat_grund, rx_stat_etherstatsundersizepkts);
-	UPDATE_STAT64(rx_stat_grovr, rx_stat_dot3statsframestoolong);
-	UPDATE_STAT64(rx_stat_grfrg, rx_stat_etherstatsfragments);
-	UPDATE_STAT64(rx_stat_grjbr, rx_stat_etherstatsjabbers);
-	UPDATE_STAT64(rx_stat_grxcf, rx_stat_maccontrolframesreceived);
-	UPDATE_STAT64(rx_stat_grxpf, rx_stat_xoffstateentered);
-	UPDATE_STAT64(rx_stat_grxpf, rx_stat_bmac_xpf);
-	UPDATE_STAT64(tx_stat_gtxpf, tx_stat_outxoffsent);
-	UPDATE_STAT64(tx_stat_gtxpf, tx_stat_flowcontroldone);
-	UPDATE_STAT64(tx_stat_gt64, tx_stat_etherstatspkts64octets);
-	UPDATE_STAT64(tx_stat_gt127,
+	if (CHIP_IS_E1x(bp)) {
+		struct bmac1_stats *new = bnx2x_sp(bp, mac_stats.bmac1_stats);
+
+		/* the macros below will use "bmac1_stats" type */
+		UPDATE_STAT64(rx_stat_grerb, rx_stat_ifhcinbadoctets);
+		UPDATE_STAT64(rx_stat_grfcs, rx_stat_dot3statsfcserrors);
+		UPDATE_STAT64(rx_stat_grund, rx_stat_etherstatsundersizepkts);
+		UPDATE_STAT64(rx_stat_grovr, rx_stat_dot3statsframestoolong);
+		UPDATE_STAT64(rx_stat_grfrg, rx_stat_etherstatsfragments);
+		UPDATE_STAT64(rx_stat_grjbr, rx_stat_etherstatsjabbers);
+		UPDATE_STAT64(rx_stat_grxcf, rx_stat_maccontrolframesreceived);
+		UPDATE_STAT64(rx_stat_grxpf, rx_stat_xoffstateentered);
+		UPDATE_STAT64(rx_stat_grxpf, rx_stat_bmac_xpf);
+		UPDATE_STAT64(tx_stat_gtxpf, tx_stat_outxoffsent);
+		UPDATE_STAT64(tx_stat_gtxpf, tx_stat_flowcontroldone);
+		UPDATE_STAT64(tx_stat_gt64, tx_stat_etherstatspkts64octets);
+		UPDATE_STAT64(tx_stat_gt127,
 				tx_stat_etherstatspkts65octetsto127octets);
-	UPDATE_STAT64(tx_stat_gt255,
+		UPDATE_STAT64(tx_stat_gt255,
 				tx_stat_etherstatspkts128octetsto255octets);
-	UPDATE_STAT64(tx_stat_gt511,
+		UPDATE_STAT64(tx_stat_gt511,
 				tx_stat_etherstatspkts256octetsto511octets);
-	UPDATE_STAT64(tx_stat_gt1023,
+		UPDATE_STAT64(tx_stat_gt1023,
 				tx_stat_etherstatspkts512octetsto1023octets);
-	UPDATE_STAT64(tx_stat_gt1518,
+		UPDATE_STAT64(tx_stat_gt1518,
 				tx_stat_etherstatspkts1024octetsto1522octets);
-	UPDATE_STAT64(tx_stat_gt2047, tx_stat_bmac_2047);
-	UPDATE_STAT64(tx_stat_gt4095, tx_stat_bmac_4095);
-	UPDATE_STAT64(tx_stat_gt9216, tx_stat_bmac_9216);
-	UPDATE_STAT64(tx_stat_gt16383, tx_stat_bmac_16383);
-	UPDATE_STAT64(tx_stat_gterr,
+		UPDATE_STAT64(tx_stat_gt2047, tx_stat_bmac_2047);
+		UPDATE_STAT64(tx_stat_gt4095, tx_stat_bmac_4095);
+		UPDATE_STAT64(tx_stat_gt9216, tx_stat_bmac_9216);
+		UPDATE_STAT64(tx_stat_gt16383, tx_stat_bmac_16383);
+		UPDATE_STAT64(tx_stat_gterr,
 				tx_stat_dot3statsinternalmactransmiterrors);
-	UPDATE_STAT64(tx_stat_gtufl, tx_stat_bmac_ufl);
+		UPDATE_STAT64(tx_stat_gtufl, tx_stat_bmac_ufl);
+
+	} else {
+		struct bmac2_stats *new = bnx2x_sp(bp, mac_stats.bmac2_stats);
+
+		/* the macros below will use "bmac2_stats" type */
+		UPDATE_STAT64(rx_stat_grerb, rx_stat_ifhcinbadoctets);
+		UPDATE_STAT64(rx_stat_grfcs, rx_stat_dot3statsfcserrors);
+		UPDATE_STAT64(rx_stat_grund, rx_stat_etherstatsundersizepkts);
+		UPDATE_STAT64(rx_stat_grovr, rx_stat_dot3statsframestoolong);
+		UPDATE_STAT64(rx_stat_grfrg, rx_stat_etherstatsfragments);
+		UPDATE_STAT64(rx_stat_grjbr, rx_stat_etherstatsjabbers);
+		UPDATE_STAT64(rx_stat_grxcf, rx_stat_maccontrolframesreceived);
+		UPDATE_STAT64(rx_stat_grxpf, rx_stat_xoffstateentered);
+		UPDATE_STAT64(rx_stat_grxpf, rx_stat_bmac_xpf);
+		UPDATE_STAT64(tx_stat_gtxpf, tx_stat_outxoffsent);
+		UPDATE_STAT64(tx_stat_gtxpf, tx_stat_flowcontroldone);
+		UPDATE_STAT64(tx_stat_gt64, tx_stat_etherstatspkts64octets);
+		UPDATE_STAT64(tx_stat_gt127,
+				tx_stat_etherstatspkts65octetsto127octets);
+		UPDATE_STAT64(tx_stat_gt255,
+				tx_stat_etherstatspkts128octetsto255octets);
+		UPDATE_STAT64(tx_stat_gt511,
+				tx_stat_etherstatspkts256octetsto511octets);
+		UPDATE_STAT64(tx_stat_gt1023,
+				tx_stat_etherstatspkts512octetsto1023octets);
+		UPDATE_STAT64(tx_stat_gt1518,
+				tx_stat_etherstatspkts1024octetsto1522octets);
+		UPDATE_STAT64(tx_stat_gt2047, tx_stat_bmac_2047);
+		UPDATE_STAT64(tx_stat_gt4095, tx_stat_bmac_4095);
+		UPDATE_STAT64(tx_stat_gt9216, tx_stat_bmac_9216);
+		UPDATE_STAT64(tx_stat_gt16383, tx_stat_bmac_16383);
+		UPDATE_STAT64(tx_stat_gterr,
+				tx_stat_dot3statsinternalmactransmiterrors);
+		UPDATE_STAT64(tx_stat_gtufl, tx_stat_bmac_ufl);
+	}
 
 	estats->pause_frames_received_hi =
 				pstats->mac_stx[1].rx_stat_bmac_xpf_hi;
@@ -1121,24 +1133,17 @@ static void bnx2x_port_stats_stop(struct bnx2x *bp)
 
 	bp->executer_idx = 0;
 
-	opcode = (DMAE_CMD_SRC_PCI | DMAE_CMD_DST_GRC |
-		  DMAE_CMD_C_ENABLE |
-		  DMAE_CMD_SRC_RESET | DMAE_CMD_DST_RESET |
-#ifdef __BIG_ENDIAN
-		  DMAE_CMD_ENDIANITY_B_DW_SWAP |
-#else
-		  DMAE_CMD_ENDIANITY_DW_SWAP |
-#endif
-		  (BP_PORT(bp) ? DMAE_CMD_PORT_1 : DMAE_CMD_PORT_0) |
-		  (BP_E1HVN(bp) << DMAE_CMD_E1HVN_SHIFT));
+	opcode = bnx2x_dmae_opcode(bp, DMAE_SRC_PCI, DMAE_DST_GRC, false, 0);
 
 	if (bp->port.port_stx) {
 
 		dmae = bnx2x_sp(bp, dmae[bp->executer_idx++]);
 		if (bp->func_stx)
-			dmae->opcode = (opcode | DMAE_CMD_C_DST_GRC);
+			dmae->opcode = bnx2x_dmae_opcode_add_comp(
+						opcode, DMAE_COMP_GRC);
 		else
-			dmae->opcode = (opcode | DMAE_CMD_C_DST_PCI);
+			dmae->opcode = bnx2x_dmae_opcode_add_comp(
+						opcode, DMAE_COMP_PCI);
 		dmae->src_addr_lo = U64_LO(bnx2x_sp_mapping(bp, port_stats));
 		dmae->src_addr_hi = U64_HI(bnx2x_sp_mapping(bp, port_stats));
 		dmae->dst_addr_lo = bp->port.port_stx >> 2;
@@ -1162,7 +1167,8 @@ static void bnx2x_port_stats_stop(struct bnx2x *bp)
 	if (bp->func_stx) {
 
 		dmae = bnx2x_sp(bp, dmae[bp->executer_idx++]);
-		dmae->opcode = (opcode | DMAE_CMD_C_DST_PCI);
+		dmae->opcode =
+			bnx2x_dmae_opcode_add_comp(opcode, DMAE_COMP_PCI);
 		dmae->src_addr_lo = U64_LO(bnx2x_sp_mapping(bp, func_stats));
 		dmae->src_addr_hi = U64_HI(bnx2x_sp_mapping(bp, func_stats));
 		dmae->dst_addr_lo = bp->func_stx >> 2;
@@ -1255,16 +1261,8 @@ static void bnx2x_port_stats_base_init(struct bnx2x *bp)
 	bp->executer_idx = 0;
 
 	dmae = bnx2x_sp(bp, dmae[bp->executer_idx++]);
-	dmae->opcode = (DMAE_CMD_SRC_PCI | DMAE_CMD_DST_GRC |
-			DMAE_CMD_C_DST_PCI | DMAE_CMD_C_ENABLE |
-			DMAE_CMD_SRC_RESET | DMAE_CMD_DST_RESET |
-#ifdef __BIG_ENDIAN
-			DMAE_CMD_ENDIANITY_B_DW_SWAP |
-#else
-			DMAE_CMD_ENDIANITY_DW_SWAP |
-#endif
-			(BP_PORT(bp) ? DMAE_CMD_PORT_1 : DMAE_CMD_PORT_0) |
-			(BP_E1HVN(bp) << DMAE_CMD_E1HVN_SHIFT));
+	dmae->opcode = bnx2x_dmae_opcode(bp, DMAE_SRC_PCI, DMAE_DST_GRC,
+					 true, DMAE_COMP_PCI);
 	dmae->src_addr_lo = U64_LO(bnx2x_sp_mapping(bp, port_stats));
 	dmae->src_addr_hi = U64_HI(bnx2x_sp_mapping(bp, port_stats));
 	dmae->dst_addr_lo = bp->port.port_stx >> 2;
@@ -1282,8 +1280,6 @@ static void bnx2x_port_stats_base_init(struct bnx2x *bp)
 static void bnx2x_func_stats_base_init(struct bnx2x *bp)
 {
 	int vn, vn_max = IS_MF(bp) ? E1HVN_MAX : E1VN_MAX;
-	int port = BP_PORT(bp);
-	int func;
 	u32 func_stx;
 
 	/* sanity */
@@ -1296,9 +1292,9 @@ static void bnx2x_func_stats_base_init(struct bnx2x *bp)
 	func_stx = bp->func_stx;
 
 	for (vn = VN_0; vn < vn_max; vn++) {
-		func = 2*vn + port;
+		int mb_idx = !CHIP_IS_E2(bp) ? 2*vn + BP_PORT(bp) : vn;
 
-		bp->func_stx = SHMEM_RD(bp, func_mb[func].fw_mb_param);
+		bp->func_stx = SHMEM_RD(bp, func_mb[mb_idx].fw_mb_param);
 		bnx2x_func_stats_init(bp);
 		bnx2x_hw_stats_post(bp);
 		bnx2x_stats_comp(bp);
@@ -1322,16 +1318,8 @@ static void bnx2x_func_stats_base_update(struct bnx2x *bp)
 	bp->executer_idx = 0;
 	memset(dmae, 0, sizeof(struct dmae_command));
 
-	dmae->opcode = (DMAE_CMD_SRC_GRC | DMAE_CMD_DST_PCI |
-			DMAE_CMD_C_DST_PCI | DMAE_CMD_C_ENABLE |
-			DMAE_CMD_SRC_RESET | DMAE_CMD_DST_RESET |
-#ifdef __BIG_ENDIAN
-			DMAE_CMD_ENDIANITY_B_DW_SWAP |
-#else
-			DMAE_CMD_ENDIANITY_DW_SWAP |
-#endif
-			(BP_PORT(bp) ? DMAE_CMD_PORT_1 : DMAE_CMD_PORT_0) |
-			(BP_E1HVN(bp) << DMAE_CMD_E1HVN_SHIFT));
+	dmae->opcode = bnx2x_dmae_opcode(bp, DMAE_SRC_GRC, DMAE_DST_PCI,
+					 true, DMAE_COMP_PCI);
 	dmae->src_addr_lo = bp->func_stx >> 2;
 	dmae->src_addr_hi = 0;
 	dmae->dst_addr_lo = U64_LO(bnx2x_sp_mapping(bp, func_stats_base));
@@ -1349,7 +1337,7 @@ static void bnx2x_func_stats_base_update(struct bnx2x *bp)
 void bnx2x_stats_init(struct bnx2x *bp)
 {
 	int port = BP_PORT(bp);
-	int func = BP_FUNC(bp);
+	int mb_idx = BP_FW_MB_IDX(bp);
 	int i;
 
 	bp->stats_pending = 0;
@@ -1359,7 +1347,7 @@ void bnx2x_stats_init(struct bnx2x *bp)
 	/* port and func stats for management */
 	if (!BP_NOMCP(bp)) {
 		bp->port.port_stx = SHMEM_RD(bp, port_mb[port].port_stx);
-		bp->func_stx = SHMEM_RD(bp, func_mb[func].fw_mb_param);
+		bp->func_stx = SHMEM_RD(bp, func_mb[mb_idx].fw_mb_param);
 
 	} else {
 		bp->port.port_stx = 0;
diff --git a/firmware/Makefile b/firmware/Makefile
index e0a3439..494a167 100644
--- a/firmware/Makefile
+++ b/firmware/Makefile
@@ -33,7 +33,8 @@ fw-shipped-$(CONFIG_ADAPTEC_STARFIRE) += adaptec/starfire_rx.bin \
 fw-shipped-$(CONFIG_ATARI_DSP56K) += dsp56k/bootstrap.bin
 fw-shipped-$(CONFIG_ATM_AMBASSADOR) += atmsar11.fw
 fw-shipped-$(CONFIG_BNX2X) += bnx2x/bnx2x-e1-6.0.34.0.fw \
-			      bnx2x/bnx2x-e1h-6.0.34.0.fw
+			      bnx2x/bnx2x-e1h-6.0.34.0.fw \
+			      bnx2x/bnx2x-e2-6.0.34.0.fw
 fw-shipped-$(CONFIG_BNX2) += bnx2/bnx2-mips-09-5.0.0.j15.fw \
 			     bnx2/bnx2-rv2p-09-5.0.0.j10.fw \
 			     bnx2/bnx2-rv2p-09ax-5.0.0.j10.fw \
-- 
1.7.1




