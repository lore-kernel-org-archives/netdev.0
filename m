From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 22/25] bnx2x: Minor code improvements
Date: Wed, 13 Aug 2008 17:16:18 +0300
Message-ID: <1218636978.547.98.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: "David Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2660 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756734AbYHMOQh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Aug 2008 10:16:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Minor code improvements
Small changes to make the code a little bit more efficient and mostly
more readable:
- Using unified macros for EMAC_RD/WR which looks like normal REG_RD/WR
- Removing the NIG_WR since it did nothing and was only confusing
- On bnx2x_panic_dump, print only the used parts of the rings
- define parameters only on the branch they are needed and not at the
  beginning of the function
- using NETIF_MSG_INTR and not private BNX2X_MSG_SP for debug prints

Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x.h      |   23 ++++++--------
 drivers/net/bnx2x_link.c |   57 +++++++++++++++++++------------------
 drivers/net/bnx2x_main.c |   70 +++++++++++++++++++++------------------------
 3 files changed, 72 insertions(+), 78 deletions(-)

diff --git a/drivers/net/bnx2x.h b/drivers/net/bnx2x.h
index 98d6f85..80f5179 100644
--- a/drivers/net/bnx2x.h
+++ b/drivers/net/bnx2x.h
@@ -121,16 +121,7 @@
 #define SHMEM_WR(bp, field, val)	REG_WR(bp, SHMEM_ADDR(bp, field), val)
 
 #define EMAC_RD(bp, reg)		REG_RD(bp, emac_base + reg)
-#define NIG_WR(reg, val)	REG_WR(bp, reg, val)
-#define EMAC_WR(reg, val)	REG_WR(bp, emac_base + reg, val)
-#define BMAC_WR(reg, val)	REG_WR(bp, GRCBASE_NIG + bmac_addr + reg, val)
-
-
-#define for_each_queue(bp, var)	for (var = 0; var < bp->num_queues; var++)
-
-#define for_each_nondefault_queue(bp, var) \
-				for (var = 1; var < bp->num_queues; var++)
-#define is_multi(bp)		(bp->num_queues > 1)
+#define EMAC_WR(bp, reg, val)		REG_WR(bp, emac_base + reg, val)
 
 
 /* fast path */
@@ -815,9 +806,6 @@ struct bnx2x {
 #define BP_FUNC(bp)			(bp->func)
 #define BP_E1HVN(bp)			(bp->func >> 1)
 #define BP_L_ID(bp)			(BP_E1HVN(bp) << 2)
-/* assorted E1HVN */
-#define IS_E1HMF(bp)			(bp->e1hmf != 0)
-#define BP_MAX_QUEUES(bp)		(IS_E1HMF(bp) ? 4 : 16)
 
 	int			pm_cap;
 	int			pcie_cap;
@@ -842,6 +830,7 @@ struct bnx2x {
 	u32			mf_config;
 	u16			e1hov;
 	u8			e1hmf;
+#define IS_E1HMF(bp)			(bp->e1hmf != 0)
 
 	u8			wol;
 
@@ -872,6 +861,7 @@ struct bnx2x {
 #define BNX2X_STATE_ERROR		0xf000
 
 	int			num_queues;
+#define BP_MAX_QUEUES(bp)		(IS_E1HMF(bp) ? 4 : 16)
 
 	u32			rx_mode;
 #define BNX2X_RX_MODE_NONE		0
@@ -922,6 +912,13 @@ struct bnx2x {
 };
 
 
+#define for_each_queue(bp, var)	for (var = 0; var < bp->num_queues; var++)
+
+#define for_each_nondefault_queue(bp, var) \
+				for (var = 1; var < bp->num_queues; var++)
+#define is_multi(bp)		(bp->num_queues > 1)
+
+
 void bnx2x_read_dmae(struct bnx2x *bp, u32 src_addr, u32 len32);
 void bnx2x_write_dmae(struct bnx2x *bp, dma_addr_t dma_addr, u32 dst_addr,
 		      u32 len32);
diff --git a/drivers/net/bnx2x_link.c b/drivers/net/bnx2x_link.c
index 876a968..d7398a3 100755
--- a/drivers/net/bnx2x_link.c
+++ b/drivers/net/bnx2x_link.c
@@ -31,7 +31,7 @@
 
 /********************************************************/
 #define SUPPORT_CL73 0 /* Currently no */
-#define ETH_HLEN 			14
+#define ETH_HLEN			14
 #define ETH_OVREHEAD		(ETH_HLEN + 8)/* 8 for CRC + VLAN*/
 #define ETH_MIN_PACKET_SIZE		60
 #define ETH_MAX_PACKET_SIZE		1500
@@ -40,7 +40,7 @@
 #define BMAC_CONTROL_RX_ENABLE	2
 
 /***********************************************************/
-/*                       Shortcut definitions              */
+/*			Shortcut definitions		   */
 /***********************************************************/
 
 #define NIG_STATUS_XGXS0_LINK10G \
@@ -79,12 +79,12 @@
 
 #define AUTONEG_CL37		SHARED_HW_CFG_AN_ENABLE_CL37
 #define AUTONEG_CL73		SHARED_HW_CFG_AN_ENABLE_CL73
-#define AUTONEG_BAM			SHARED_HW_CFG_AN_ENABLE_BAM
-#define AUTONEG_PARALLEL		\
+#define AUTONEG_BAM 		SHARED_HW_CFG_AN_ENABLE_BAM
+#define AUTONEG_PARALLEL \
 				SHARED_HW_CFG_AN_ENABLE_PARALLEL_DETECTION
-#define AUTONEG_SGMII_FIBER_AUTODET	\
+#define AUTONEG_SGMII_FIBER_AUTODET \
 				SHARED_HW_CFG_AN_EN_SGMII_FIBER_AUTO_DETECT
-#define AUTONEG_REMOTE_PHY		SHARED_HW_CFG_AN_ENABLE_REMOTE_PHY
+#define AUTONEG_REMOTE_PHY	SHARED_HW_CFG_AN_ENABLE_REMOTE_PHY
 
 #define GP_STATUS_PAUSE_RSOLUTION_TXSIDE \
 			MDIO_GP_STATUS_TOP_AN_STATUS1_PAUSE_RSOLUTION_TXSIDE
@@ -201,11 +201,10 @@ static void bnx2x_emac_init(struct link_params *params,
 	/* init emac - use read-modify-write */
 	/* self clear reset */
 	val = REG_RD(bp, emac_base + EMAC_REG_EMAC_MODE);
-	EMAC_WR(EMAC_REG_EMAC_MODE, (val | EMAC_MODE_RESET));
+	EMAC_WR(bp, EMAC_REG_EMAC_MODE, (val | EMAC_MODE_RESET));
 
 	timeout = 200;
-	do
-	{
+	do {
 		val = REG_RD(bp, emac_base + EMAC_REG_EMAC_MODE);
 		DP(NETIF_MSG_LINK, "EMAC reset reg is %u\n", val);
 		if (!timeout) {
@@ -213,18 +212,18 @@ static void bnx2x_emac_init(struct link_params *params,
 			return;
 		}
 		timeout--;
-	}while (val & EMAC_MODE_RESET);
+	} while (val & EMAC_MODE_RESET);
 
 	/* Set mac address */
 	val = ((params->mac_addr[0] << 8) |
 		params->mac_addr[1]);
-	EMAC_WR(EMAC_REG_EMAC_MAC_MATCH, val);
+	EMAC_WR(bp, EMAC_REG_EMAC_MAC_MATCH, val);
 
 	val = ((params->mac_addr[2] << 24) |
 	       (params->mac_addr[3] << 16) |
 	       (params->mac_addr[4] << 8) |
 		params->mac_addr[5]);
-	EMAC_WR(EMAC_REG_EMAC_MAC_MATCH + 4, val);
+	EMAC_WR(bp, EMAC_REG_EMAC_MAC_MATCH + 4, val);
 }
 
 static u8 bnx2x_emac_enable(struct link_params *params,
@@ -285,7 +284,7 @@ static u8 bnx2x_emac_enable(struct link_params *params,
 	if (CHIP_REV_IS_SLOW(bp)) {
 		/* config GMII mode */
 		val = REG_RD(bp, emac_base + EMAC_REG_EMAC_MODE);
-		EMAC_WR(EMAC_REG_EMAC_MODE,
+		EMAC_WR(bp, EMAC_REG_EMAC_MODE,
 			    (val | EMAC_MODE_PORT_GMII));
 	} else { /* ASIC */
 		/* pause enable/disable */
@@ -309,7 +308,7 @@ static u8 bnx2x_emac_enable(struct link_params *params,
 	/* KEEP_VLAN_TAG, promiscuous */
 	val = REG_RD(bp, emac_base + EMAC_REG_EMAC_RX_MODE);
 	val |= EMAC_RX_MODE_KEEP_VLAN_TAG | EMAC_RX_MODE_PROMISCUOUS;
-	EMAC_WR(EMAC_REG_EMAC_RX_MODE, val);
+	EMAC_WR(bp, EMAC_REG_EMAC_RX_MODE, val);
 
 	/* Set Loopback */
 	val = REG_RD(bp, emac_base + EMAC_REG_EMAC_MODE);
@@ -317,10 +316,10 @@ static u8 bnx2x_emac_enable(struct link_params *params,
 		val |= 0x810;
 	else
 		val &= ~0x810;
-	EMAC_WR(EMAC_REG_EMAC_MODE, val);
+	EMAC_WR(bp, EMAC_REG_EMAC_MODE, val);
 
 	/* enable emac for jumbo packets */
-	EMAC_WR(EMAC_REG_EMAC_RX_MTU_SIZE,
+	EMAC_WR(bp, EMAC_REG_EMAC_RX_MTU_SIZE,
 		(EMAC_RX_MTU_SIZE_JUMBO_ENA |
 		 (ETH_MAX_JUMBO_PACKET_SIZE + ETH_OVREHEAD)));
 
@@ -646,7 +645,7 @@ static void bnx2x_bmac_rx_disable(struct bnx2x *bp, u8 port)
 	u32 bmac_addr = port ? NIG_REG_INGRESS_BMAC1_MEM :
 		NIG_REG_INGRESS_BMAC0_MEM;
 	u32 wb_data[2];
-    u32 nig_bmac_enable = REG_RD(bp, NIG_REG_BMAC0_REGS_OUT_EN + port*4);
+	u32 nig_bmac_enable = REG_RD(bp, NIG_REG_BMAC0_REGS_OUT_EN + port*4);
 
 	/* Only if the bmac is out of reset */
 	if (REG_RD(bp, MISC_REG_RESET_REG_2) &
@@ -1036,7 +1035,7 @@ static void bnx2x_set_swap_lanes(struct link_params *params)
 }
 
 static void bnx2x_set_parallel_detection(struct link_params *params,
-				       u8                phy_flags)
+				       u8       	 phy_flags)
 {
 	struct bnx2x *bp = params->bp;
 	u16 control2;
@@ -1489,8 +1488,8 @@ static u8 bnx2x_ext_phy_resove_fc(struct link_params *params,
 {
 	struct bnx2x *bp = params->bp;
 	u8 ext_phy_addr;
-	u16 ld_pause;   /* local */
-	u16 lp_pause;   /* link partner */
+	u16 ld_pause;	/* local */
+	u16 lp_pause;	/* link partner */
 	u16 an_complete; /* AN complete */
 	u16 pause_result;
 	u8 ret = 0;
@@ -1565,8 +1564,8 @@ static void bnx2x_flow_ctrl_resolve(struct link_params *params,
 				  u32 gp_status)
 {
 	struct bnx2x *bp = params->bp;
-	u16 ld_pause;	/* local driver */
-	u16 lp_pause;	/* link partner */
+	u16 ld_pause;   /* local driver */
+	u16 lp_pause;   /* link partner */
 	u16 pause_result;
 
 	vars->flow_ctrl = FLOW_CTRL_NONE;
@@ -1611,6 +1610,7 @@ static u8 bnx2x_link_settings_status(struct link_params *params,
 				      u32 gp_status)
 {
 	struct bnx2x *bp = params->bp;
+
 	u8 rc = 0;
 	vars->link_status = 0;
 
@@ -3303,7 +3303,7 @@ static void bnx2x_link_int_enable(struct link_params *params)
  * link management
  */
 static void bnx2x_link_int_ack(struct link_params *params,
-			     struct link_vars *vars, u16 is_10g)
+			     struct link_vars *vars, u8 is_10g)
 {
 	struct bnx2x *bp = params->bp;
 	u8 port = params->port;
@@ -3781,7 +3781,7 @@ u8 bnx2x_set_led(struct bnx2x *bp, u8 port, u8 mode, u32 speed,
 			   SHARED_HW_CFG_LED_MAC1);
 
 		tmp = EMAC_RD(bp, EMAC_REG_EMAC_LED);
-		EMAC_WR(EMAC_REG_EMAC_LED, (tmp | EMAC_LED_OVERRIDE));
+		EMAC_WR(bp, EMAC_REG_EMAC_LED, (tmp | EMAC_LED_OVERRIDE));
 		break;
 
 	case LED_MODE_OPER:
@@ -3794,7 +3794,7 @@ u8 bnx2x_set_led(struct bnx2x *bp, u8 port, u8 mode, u32 speed,
 		REG_WR(bp, NIG_REG_LED_CONTROL_BLINK_RATE_ENA_P0 +
 			   port*4, 1);
 		tmp = EMAC_RD(bp, EMAC_REG_EMAC_LED);
-		EMAC_WR(EMAC_REG_EMAC_LED,
+		EMAC_WR(bp, EMAC_REG_EMAC_LED,
 			    (tmp & (~EMAC_LED_OVERRIDE)));
 
 		if (!CHIP_IS_E1H(bp) &&
@@ -3917,7 +3917,7 @@ u8 bnx2x_phy_init(struct link_params *params, struct link_vars *vars)
 	struct bnx2x *bp = params->bp;
 
 	u32 val;
-	DP(NETIF_MSG_LINK, "Phy Initialization started\n");
+	DP(NETIF_MSG_LINK, "Phy Initialization started \n");
 	DP(NETIF_MSG_LINK, "req_speed = %d, req_flowctrl=%d\n",
 		  params->req_line_speed, params->req_flow_ctrl);
 	vars->link_status = 0;
@@ -3933,6 +3933,7 @@ u8 bnx2x_phy_init(struct link_params *params, struct link_vars *vars)
 	else
 		vars->phy_flags = PHY_XGXS_FLAG;
 
+
 	/* disable attentions */
 	bnx2x_bits_dis(bp, NIG_REG_MASK_INTERRUPT_PORT0 + params->port*4,
 		       (NIG_MASK_XGXS0_LINK_STATUS |
@@ -4542,7 +4543,7 @@ static u8 bnx2x_sfx7101_flash_download(struct bnx2x *bp, u8 port,
 		size = MAX_APP_SIZE+HEADER_SIZE;
 	}
 	DP(NETIF_MSG_LINK, "File version is %c%c\n", data[0x14e], data[0x14f]);
-	DP(NETIF_MSG_LINK, "                %c%c\n", data[0x150], data[0x151]);
+	DP(NETIF_MSG_LINK, "  	      %c%c\n", data[0x150], data[0x151]);
 	/* Put the DSP in download mode by setting FLASH_CFG[2] to 1
 	   and issuing a reset.*/
 
@@ -4824,7 +4825,7 @@ static u8 bnx2x_sfx7101_flash_download(struct bnx2x *bp, u8 port,
 		      MDIO_PMA_REG_7101_VER2,
 		      &image_revision2);
 
-	if (data[0x14e]	!= (image_revision2&0xFF) ||
+	if (data[0x14e] != (image_revision2&0xFF) ||
 	    data[0x14f] != ((image_revision2&0xFF00)>>8) ||
 	    data[0x150] != (image_revision1&0xFF) ||
 	    data[0x151] != ((image_revision1&0xFF00)>>8)) {
diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 721db29..d3c4c1e 100755
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -555,8 +555,8 @@ static void bnx2x_panic_dump(struct bnx2x *bp)
 				  j, rx_bd[1], rx_bd[0], sw_bd->skb);
 		}
 
-		start = 0;
-		end = RX_SGE_CNT*NUM_RX_SGE_PAGES;
+		start = RX_SGE(fp->rx_sge_prod);
+		end = RX_SGE(fp->last_max_sge);
 		for (j = start; j < end; j++) {
 			u32 *rx_sge = (u32 *)&fp->rx_sge_ring[j];
 			struct sw_rx_page *sw_page = &fp->rx_page_ring[j];
@@ -885,6 +885,7 @@ static void bnx2x_tx_int(struct bnx2x_fastpath *fp, int work)
 	}
 }
 
+
 static void bnx2x_sp_event(struct bnx2x_fastpath *fp,
 			   union eth_rx_cqe *rr_cqe)
 {
@@ -940,6 +941,7 @@ static void bnx2x_sp_event(struct bnx2x_fastpath *fp,
 		bnx2x_fp(bp, cid, state) = BNX2X_FP_STATE_CLOSED;
 		break;
 
+
 	case (RAMROD_CMD_ID_ETH_SET_MAC | BNX2X_STATE_OPEN):
 	case (RAMROD_CMD_ID_ETH_SET_MAC | BNX2X_STATE_DIAG):
 		DP(NETIF_MSG_IFUP, "got set mac ramrod\n");
@@ -1370,7 +1372,6 @@ static int bnx2x_rx_int(struct bnx2x_fastpath *fp, int budget)
 	u16 bd_cons, bd_prod, bd_prod_fw, comp_ring_cons;
 	u16 hw_comp_cons, sw_comp_cons, sw_comp_prod;
 	int rx_pkt = 0;
-	u16 queue;
 
 #ifdef BNX2X_STOP_ON_ERROR
 	if (unlikely(bp->panic))
@@ -1436,7 +1437,7 @@ static int bnx2x_rx_int(struct bnx2x_fastpath *fp, int budget)
 			if ((!fp->disable_tpa) &&
 			    (TPA_TYPE(cqe_fp_flags) !=
 					(TPA_TYPE_START | TPA_TYPE_END))) {
-				queue = cqe->fast_path_cqe.queue_index;
+				u16 queue = cqe->fast_path_cqe.queue_index;
 
 				if (TPA_TYPE(cqe_fp_flags) == TPA_TYPE_START) {
 					DP(NETIF_MSG_RX_STATUS,
@@ -1635,17 +1636,17 @@ static irqreturn_t bnx2x_interrupt(int irq, void *dev_instance)
 	}
 	DP(NETIF_MSG_INTR, "got an interrupt  status %u\n", status);
 
-#ifdef BNX2X_STOP_ON_ERROR
-	if (unlikely(bp->panic))
-		return IRQ_HANDLED;
-#endif
-
 	/* Return here if interrupt is disabled */
 	if (unlikely(atomic_read(&bp->intr_sem) != 0)) {
 		DP(NETIF_MSG_INTR, "called but intr_sem not 0, returning\n");
 		return IRQ_HANDLED;
 	}
 
+#ifdef BNX2X_STOP_ON_ERROR
+	if (unlikely(bp->panic))
+		return IRQ_HANDLED;
+#endif
+
 	mask = 0x2 << bp->fp[0].sb_id;
 	if (status & mask) {
 		struct bnx2x_fastpath *fp = &bp->fp[0];
@@ -2827,7 +2828,7 @@ static void bnx2x_sp_task(struct work_struct *work)
 
 	/* Return here if interrupt is disabled */
 	if (unlikely(atomic_read(&bp->intr_sem) != 0)) {
-		DP(BNX2X_MSG_SP, "called but intr_sem not 0, returning\n");
+		DP(NETIF_MSG_INTR, "called but intr_sem not 0, returning\n");
 		return;
 	}
 
@@ -2835,7 +2836,7 @@ static void bnx2x_sp_task(struct work_struct *work)
 /*	if (status == 0)				     */
 /*		BNX2X_ERR("spurious slowpath interrupt!\n"); */
 
-	DP(BNX2X_MSG_SP, "got a slowpath interrupt (updated %x)\n", status);
+	DP(NETIF_MSG_INTR, "got a slowpath interrupt (updated %x)\n", status);
 
 	/* HW attentions */
 	if (status & 0x1)
@@ -2865,7 +2866,7 @@ static irqreturn_t bnx2x_msix_sp_int(int irq, void *dev_instance)
 
 	/* Return here if interrupt is disabled */
 	if (unlikely(atomic_read(&bp->intr_sem) != 0)) {
-		DP(BNX2X_MSG_SP, "called but intr_sem not 0, returning\n");
+		DP(NETIF_MSG_INTR, "called but intr_sem not 0, returning\n");
 		return IRQ_HANDLED;
 	}
 
@@ -4563,7 +4564,7 @@ static void bnx2x_set_storm_rx_mode(struct bnx2x *bp)
 	int func = BP_FUNC(bp);
 	int i;
 
-	DP(NETIF_MSG_RX_STATUS, "rx mode is %d\n", mode);
+	DP(NETIF_MSG_IFUP, "rx mode %d  mask 0x%x\n", mode, mask);
 
 	switch (mode) {
 	case BNX2X_RX_MODE_NONE: /* no Rx */
@@ -4922,7 +4923,7 @@ static int bnx2x_int_mem_test(struct bnx2x *bp)
 	REG_WR(bp, TSDM_REG_ENABLE_IN1, 0x0);
 	REG_WR(bp, TCM_REG_PRS_IFEN, 0x0);
 	REG_WR(bp, CFC_REG_DEBUG0, 0x1);
-	NIG_WR(NIG_REG_PRS_REQ_IN_EN, 0x0);
+	REG_WR(bp, NIG_REG_PRS_REQ_IN_EN, 0x0);
 
 	/*  Write 0 to parser credits for CFC search request */
 	REG_WR(bp, PRS_REG_CFC_SEARCH_INITIAL_CREDIT, 0x0);
@@ -4977,7 +4978,7 @@ static int bnx2x_int_mem_test(struct bnx2x *bp)
 	REG_WR(bp, TSDM_REG_ENABLE_IN1, 0x0);
 	REG_WR(bp, TCM_REG_PRS_IFEN, 0x0);
 	REG_WR(bp, CFC_REG_DEBUG0, 0x1);
-	NIG_WR(NIG_REG_PRS_REQ_IN_EN, 0x0);
+	REG_WR(bp, NIG_REG_PRS_REQ_IN_EN, 0x0);
 
 	/* Write 0 to parser credits for CFC search request */
 	REG_WR(bp, PRS_REG_CFC_SEARCH_INITIAL_CREDIT, 0x0);
@@ -5044,7 +5045,7 @@ static int bnx2x_int_mem_test(struct bnx2x *bp)
 	REG_WR(bp, TSDM_REG_ENABLE_IN1, 0x7fffffff);
 	REG_WR(bp, TCM_REG_PRS_IFEN, 0x1);
 	REG_WR(bp, CFC_REG_DEBUG0, 0x0);
-	NIG_WR(NIG_REG_PRS_REQ_IN_EN, 0x1);
+	REG_WR(bp, NIG_REG_PRS_REQ_IN_EN, 0x1);
 
 	DP(NETIF_MSG_HW, "done\n");
 
@@ -5133,11 +5134,6 @@ static int bnx2x_init_common(struct bnx2x *bp)
 	REG_WR(bp, PXP2_REG_RD_CDURD_SWAP_MODE, 1);
 #endif
 
-#ifndef BCM_ISCSI
-		/* set NIC mode */
-		REG_WR(bp, PRS_REG_NIC_MODE, 1);
-#endif
-
 	REG_WR(bp, PXP2_REG_RQ_CDU_P_SIZE, 2);
 #ifdef BCM_ISCSI
 	REG_WR(bp, PXP2_REG_RQ_TM_P_SIZE, 5);
@@ -5207,6 +5203,8 @@ static int bnx2x_init_common(struct bnx2x *bp)
 	}
 
 	bnx2x_init_block(bp, PRS_COMMON_START, PRS_COMMON_END);
+	/* set NIC mode */
+	REG_WR(bp, PRS_REG_NIC_MODE, 1);
 	if (CHIP_IS_E1H(bp))
 		REG_WR(bp, PRS_REG_E1HOV_MODE, IS_E1HMF(bp));
 
@@ -6034,8 +6032,8 @@ static int bnx2x_req_msix_irqs(struct bnx2x *bp)
 				 bnx2x_msix_fp_int, 0,
 				 bp->dev->name, &bp->fp[i]);
 		if (rc) {
-			BNX2X_ERR("request fp #%d irq failed  rc %d\n",
-				  i + offset, rc);
+			BNX2X_ERR("request fp #%d irq failed  rc -%d\n",
+				  i + offset, -rc);
 			bnx2x_free_msix_irqs(bp);
 			return -EBUSY;
 		}
@@ -6237,7 +6235,6 @@ static int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
 {
 	u32 load_code;
 	int i, rc;
-
 #ifdef BNX2X_STOP_ON_ERROR
 	if (unlikely(bp->panic))
 		return -EPERM;
@@ -6444,8 +6441,7 @@ load_int_disable:
 	/* Free SKBs, SGEs, TPA pool and driver internals */
 	bnx2x_free_skbs(bp);
 	for_each_queue(bp, i)
-		bnx2x_free_rx_sge_range(bp, bp->fp + i,
-					RX_SGE_CNT*NUM_RX_SGE_PAGES);
+		bnx2x_free_rx_sge_range(bp, bp->fp + i, NUM_RX_SGE);
 load_error:
 	bnx2x_free_mem(bp);
 
@@ -6683,11 +6679,11 @@ static int bnx2x_nic_unload(struct bnx2x *bp, int unload_mode)
 		u8 entry = (BP_E1HVN(bp) + 1)*8;
 
 		val = (mac_addr[0] << 8) | mac_addr[1];
-		EMAC_WR(EMAC_REG_EMAC_MAC_MATCH + entry, val);
+		EMAC_WR(bp, EMAC_REG_EMAC_MAC_MATCH + entry, val);
 
 		val = (mac_addr[2] << 24) | (mac_addr[3] << 16) |
 		      (mac_addr[4] << 8) | mac_addr[5];
-		EMAC_WR(EMAC_REG_EMAC_MAC_MATCH + entry + 4, val);
+		EMAC_WR(bp, EMAC_REG_EMAC_MAC_MATCH + entry + 4, val);
 
 		reset_code = DRV_MSG_CODE_UNLOAD_REQ_WOL_EN;
 
@@ -6773,8 +6769,7 @@ unload_error:
 	/* Free SKBs, SGEs, TPA pool and driver internals */
 	bnx2x_free_skbs(bp);
 	for_each_queue(bp, i)
-		bnx2x_free_rx_sge_range(bp, bp->fp + i,
-					RX_SGE_CNT*NUM_RX_SGE_PAGES);
+		bnx2x_free_rx_sge_range(bp, bp->fp + i, NUM_RX_SGE);
 	bnx2x_free_mem(bp);
 
 	bp->state = BNX2X_STATE_CLOSED;
@@ -7411,9 +7406,8 @@ static int __devinit bnx2x_get_hwinfo(struct bnx2x *bp)
 		bp->mf_config =
 			SHMEM_RD(bp, mf_cfg.func_mf_config[func].config);
 
-		val =
-		   (SHMEM_RD(bp, mf_cfg.func_mf_config[func].e1hov_tag) &
-		    FUNC_MF_CFG_E1HOV_TAG_MASK);
+		val = (SHMEM_RD(bp, mf_cfg.func_mf_config[func].e1hov_tag) &
+		       FUNC_MF_CFG_E1HOV_TAG_MASK);
 		if (val != FUNC_MF_CFG_E1HOV_TAG_DEFAULT) {
 
 			bp->e1hov = val;
@@ -8368,7 +8362,7 @@ static int bnx2x_set_pauseparam(struct net_device *dev,
 
 	if (epause->autoneg) {
 		if (!(bp->port.supported & SUPPORTED_Autoneg)) {
-			DP(NETIF_MSG_LINK, "Autoneg not supported\n");
+			DP(NETIF_MSG_LINK, "autoneg not supported\n");
 			return -EINVAL;
 		}
 
@@ -9536,7 +9530,8 @@ static int bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	tx_bd->bd_flags.as_bitfield = ETH_TX_BD_FLAGS_START_BD;
 	tx_bd->general_data = (UNICAST_ADDRESS <<
 			       ETH_TX_BD_ETH_ADDR_TYPE_SHIFT);
-	tx_bd->general_data |= 1; /* header nbd */
+	/* header nbd */
+	tx_bd->general_data |= (1 << ETH_TX_BD_HDR_NBDS_SHIFT);
 
 	/* remember the first BD of the packet */
 	tx_buf->first_bd = fp->tx_bd_prod;
@@ -9898,6 +9893,7 @@ static int bnx2x_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 {
 	struct mii_ioctl_data *data = if_mii(ifr);
 	struct bnx2x *bp = netdev_priv(dev);
+	int port = BP_PORT(bp);
 	int err;
 
 	switch (cmd) {
@@ -9913,7 +9909,7 @@ static int bnx2x_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 			return -EAGAIN;
 
 		mutex_lock(&bp->port.phy_mutex);
-		err = bnx2x_cl45_read(bp, BP_PORT(bp), 0, bp->port.phy_addr,
+		err = bnx2x_cl45_read(bp, port, 0, bp->port.phy_addr,
 				      DEFAULT_PHY_DEV_ADDR,
 				      (data->reg_num & 0x1f), &mii_regval);
 		data->val_out = mii_regval;
@@ -9929,7 +9925,7 @@ static int bnx2x_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 			return -EAGAIN;
 
 		mutex_lock(&bp->port.phy_mutex);
-		err = bnx2x_cl45_write(bp, BP_PORT(bp), 0, bp->port.phy_addr,
+		err = bnx2x_cl45_write(bp, port, 0, bp->port.phy_addr,
 				       DEFAULT_PHY_DEV_ADDR,
 				       (data->reg_num & 0x1f), data->val_in);
 		mutex_unlock(&bp->port.phy_mutex);
-- 
1.5.3.2




