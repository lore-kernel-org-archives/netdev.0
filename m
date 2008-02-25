From: "Eliezer Tamir" <eliezert@broadcom.com>
Subject: [PATCH resend 2.6.25 4/12][BNX2X]: correct rx filtering
 (client-config)
Date: Mon, 25 Feb 2008 12:32:54 +0200
Message-ID: <1203935574.8232.208.camel@lb-tlvb-eliezer.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, jeff@garzik.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [216.31.210.20] ([216.31.210.20]:3701 "EHLO mms5.broadcom.com"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1754089AbYBYKlo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Feb 2008 05:41:44 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[BNX2X]: correct rx filtering (client-config)

Signed-off-by: Eliezer Tamir <eliezert@broadcom.com>
---
 drivers/net/bnx2x.c |  165 ++++++++++++++++++++++++++++-----------------------
 drivers/net/bnx2x.h |    5 +-
 2 files changed, 92 insertions(+), 78 deletions(-)

diff --git a/drivers/net/bnx2x.c b/drivers/net/bnx2x.c
index 5cd7850..103d3e0 100644
--- a/drivers/net/bnx2x.c
+++ b/drivers/net/bnx2x.c
@@ -298,8 +298,7 @@ static void bnx2x_read_dmae(struct bnx2x *bp, u32 src_addr, u32 len32)
 
 static int bnx2x_mc_assert(struct bnx2x *bp)
 {
-	int i, j;
-	int rc = 0;
+	int i, j, rc = 0;
 	char last_idx;
 	const char storm[] = {"XTCU"};
 	const u32 intmem_base[] = {
@@ -313,8 +312,9 @@ static int bnx2x_mc_assert(struct bnx2x *bp)
 	for (i = 0; i < 4; i++) {
 		last_idx = REG_RD8(bp, XSTORM_ASSERT_LIST_INDEX_OFFSET +
 				   intmem_base[i]);
-		BNX2X_ERR("DATA %cSTORM_ASSERT_LIST_INDEX 0x%x\n",
-			  storm[i], last_idx);
+		if (last_idx)
+			BNX2X_LOG("DATA %cSTORM_ASSERT_LIST_INDEX 0x%x\n",
+				  storm[i], last_idx);
 
 		/* print the asserts */
 		for (j = 0; j < STROM_ASSERT_ARRAY_SIZE; j++) {
@@ -330,7 +330,7 @@ static int bnx2x_mc_assert(struct bnx2x *bp)
 				      intmem_base[i]);
 
 			if (row0 != COMMON_ASM_INVALID_ASSERT_OPCODE) {
-				BNX2X_ERR("DATA %cSTORM_ASSERT_INDEX 0x%x ="
+				BNX2X_LOG("DATA %cSTORM_ASSERT_INDEX 0x%x ="
 					  " 0x%08x 0x%08x 0x%08x 0x%08x\n",
 					  storm[i], j, row3, row2, row1, row0);
 				rc++;
@@ -349,21 +349,22 @@ static void bnx2x_fw_dump(struct bnx2x *bp)
 	int word;
 
 	mark = REG_RD(bp, MCP_REG_MCPR_SCRATCH + 0xf104);
-	printk(KERN_ERR PFX "begin fw dump (mark 0x%x)\n", mark);
+	mark = ((mark + 0x3) & ~0x3);
+	printk(KERN_ERR PFX "begin fw dump (mark 0x%x)\n" KERN_ERR, mark);
 
 	for (offset = mark - 0x08000000; offset <= 0xF900; offset += 0x8*4) {
 		for (word = 0; word < 8; word++)
 			data[word] = htonl(REG_RD(bp, MCP_REG_MCPR_SCRATCH +
 						  offset + 4*word));
 		data[8] = 0x0;
-		printk(KERN_ERR PFX "%s", (char *)data);
+		printk(KERN_CONT "%s", (char *)data);
 	}
 	for (offset = 0xF108; offset <= mark - 0x08000000; offset += 0x8*4) {
 		for (word = 0; word < 8; word++)
 			data[word] = htonl(REG_RD(bp, MCP_REG_MCPR_SCRATCH +
 						  offset + 4*word));
 		data[8] = 0x0;
-		printk(KERN_ERR PFX "%s", (char *)data);
+		printk(KERN_CONT "%s", (char *)data);
 	}
 	printk("\n" KERN_ERR PFX "end of fw dump\n");
 }
@@ -428,10 +429,10 @@ static void bnx2x_panic_dump(struct bnx2x *bp)
 		}
 	}
 
-	BNX2X_ERR("def_c_idx(%u)  def_u_idx(%u)  def_t_idx(%u)"
-		  "  def_x_idx(%u)  def_att_idx(%u)  attn_state(%u)"
+	BNX2X_ERR("def_c_idx(%u)  def_u_idx(%u)  def_x_idx(%u)"
+		  "  def_t_idx(%u)  def_att_idx(%u)  attn_state(%u)"
 		  "  spq_prod_idx(%u)\n",
-		  bp->def_c_idx, bp->def_u_idx, bp->def_t_idx, bp->def_x_idx,
+		  bp->def_c_idx, bp->def_u_idx, bp->def_x_idx, bp->def_t_idx,
 		  bp->def_att_idx, bp->attn_state, bp->spq_prod_idx);
 
 
@@ -789,20 +790,20 @@ static void bnx2x_sp_event(struct bnx2x_fastpath *fp,
 		fp->state = BNX2X_FP_STATE_HALTED;
 		break;
 
-	case (RAMROD_CMD_ID_ETH_PORT_DEL | BNX2X_STATE_CLOSING_WAIT4_DELETE):
-		DP(NETIF_MSG_IFDOWN, "got delete ramrod\n");
-		bp->state = BNX2X_STATE_CLOSING_WAIT4_UNLOAD;
-		break;
-
 	case (RAMROD_CMD_ID_ETH_CFC_DEL | BNX2X_STATE_CLOSING_WAIT4_HALT):
-		DP(NETIF_MSG_IFDOWN, "got delete ramrod for MULTI[%d]\n", cid);
-		bnx2x_fp(bp, cid, state) = BNX2X_FP_STATE_DELETED;
+		DP(NETIF_MSG_IFDOWN, "got delete ramrod for MULTI[%d]\n",
+		   cid);
+		bnx2x_fp(bp, cid, state) = BNX2X_FP_STATE_CLOSED;
 		break;
 
 	case (RAMROD_CMD_ID_ETH_SET_MAC | BNX2X_STATE_OPEN):
 		DP(NETIF_MSG_IFUP, "got set mac ramrod\n");
 		break;
 
+	case (RAMROD_CMD_ID_ETH_SET_MAC | BNX2X_STATE_CLOSING_WAIT4_HALT):
+		DP(NETIF_MSG_IFUP, "got (un)set mac ramrod\n");
+		break;
+
 	default:
 		BNX2X_ERR("unexpected ramrod (%d)  state is %x\n",
 			  command, bp->state);
@@ -5236,6 +5237,9 @@ static void bnx2x_init_def_sb(struct bnx2x *bp,
 					    atten_status_block);
 	def_sb->atten_status_block.status_block_id = id;
 
+	bp->def_att_idx = 0;
+	bp->attn_state = 0;
+
 	reg_offset = (port ? MISC_REG_AEU_ENABLE1_FUNC_1_OUT_0 :
 			     MISC_REG_AEU_ENABLE1_FUNC_0_OUT_0);
 
@@ -5270,6 +5274,8 @@ static void bnx2x_init_def_sb(struct bnx2x *bp,
 					    u_def_status_block);
 	def_sb->u_def_status_block.status_block_id = id;
 
+	bp->def_u_idx = 0;
+
 	REG_WR(bp, BAR_USTRORM_INTMEM +
 	       USTORM_DEF_SB_HOST_SB_ADDR_OFFSET(port), U64_LO(section));
 	REG_WR(bp, BAR_USTRORM_INTMEM +
@@ -5287,6 +5293,8 @@ static void bnx2x_init_def_sb(struct bnx2x *bp,
 					    c_def_status_block);
 	def_sb->c_def_status_block.status_block_id = id;
 
+	bp->def_c_idx = 0;
+
 	REG_WR(bp, BAR_CSTRORM_INTMEM +
 	       CSTORM_DEF_SB_HOST_SB_ADDR_OFFSET(port), U64_LO(section));
 	REG_WR(bp, BAR_CSTRORM_INTMEM +
@@ -5304,6 +5312,8 @@ static void bnx2x_init_def_sb(struct bnx2x *bp,
 					    t_def_status_block);
 	def_sb->t_def_status_block.status_block_id = id;
 
+	bp->def_t_idx = 0;
+
 	REG_WR(bp, BAR_TSTRORM_INTMEM +
 	       TSTORM_DEF_SB_HOST_SB_ADDR_OFFSET(port), U64_LO(section));
 	REG_WR(bp, BAR_TSTRORM_INTMEM +
@@ -5321,6 +5331,8 @@ static void bnx2x_init_def_sb(struct bnx2x *bp,
 					    x_def_status_block);
 	def_sb->x_def_status_block.status_block_id = id;
 
+	bp->def_x_idx = 0;
+
 	REG_WR(bp, BAR_XSTRORM_INTMEM +
 	       XSTORM_DEF_SB_HOST_SB_ADDR_OFFSET(port), U64_LO(section));
 	REG_WR(bp, BAR_XSTRORM_INTMEM +
@@ -5333,6 +5345,8 @@ static void bnx2x_init_def_sb(struct bnx2x *bp,
 		REG_WR16(bp, BAR_XSTRORM_INTMEM +
 			 XSTORM_DEF_SB_HC_DISABLE_OFFSET(port, index), 0x1);
 
+	bp->stat_pending = 0;
+
 	bnx2x_ack_sb(bp, id, CSTORM_ID, 0, IGU_INT_ENABLE, 0);
 }
 
@@ -5476,7 +5490,6 @@ static void bnx2x_init_sp_ring(struct bnx2x *bp)
 
 	bp->spq_left = MAX_SPQ_PENDING;
 	bp->spq_prod_idx = 0;
-	bp->dsb_sp_prod_idx = 0;
 	bp->dsb_sp_prod = BNX2X_SP_DSB_INDEX;
 	bp->spq_prod_bd = bp->spq;
 	bp->spq_last_bd = bp->spq_prod_bd + MAX_SP_DESC_CNT;
@@ -5553,6 +5566,42 @@ static void bnx2x_init_ind_table(struct bnx2x *bp)
 	REG_WR(bp, PRS_REG_A_PRSU_20, 0xf);
 }
 
+static void bnx2x_set_client_config(struct bnx2x *bp)
+{
+#ifdef BCM_VLAN
+	int mode = bp->rx_mode;
+#endif
+	int i, port = bp->port;
+	struct tstorm_eth_client_config tstorm_client = {0};
+
+	tstorm_client.mtu = bp->dev->mtu;
+	tstorm_client.statistics_counter_id = 0;
+	tstorm_client.config_flags =
+				TSTORM_ETH_CLIENT_CONFIG_STATSITICS_ENABLE;
+#ifdef BCM_VLAN
+	if (mode && bp->vlgrp) {
+		tstorm_client.config_flags |=
+				TSTORM_ETH_CLIENT_CONFIG_VLAN_REMOVAL_ENABLE;
+		DP(NETIF_MSG_IFUP, "vlan removal enabled\n");
+	}
+#endif
+	if (mode != BNX2X_RX_MODE_PROMISC)
+		tstorm_client.drop_flags =
+				TSTORM_ETH_CLIENT_CONFIG_DROP_MAC_ERR;
+
+	for_each_queue(bp, i) {
+		REG_WR(bp, BAR_TSTRORM_INTMEM +
+		       TSTORM_CLIENT_CONFIG_OFFSET(port, i),
+		       ((u32 *)&tstorm_client)[0]);
+		REG_WR(bp, BAR_TSTRORM_INTMEM +
+		       TSTORM_CLIENT_CONFIG_OFFSET(port, i) + 4,
+		       ((u32 *)&tstorm_client)[1]);
+	}
+
+/*	DP(NETIF_MSG_IFUP, "tstorm_client: 0x%08x 0x%08x\n",
+	   ((u32 *)&tstorm_client)[0], ((u32 *)&tstorm_client)[1]); */
+}
+
 static void bnx2x_set_storm_rx_mode(struct bnx2x *bp)
 {
 	int mode = bp->rx_mode;
@@ -5592,41 +5641,9 @@ static void bnx2x_set_storm_rx_mode(struct bnx2x *bp)
 /*      	DP(NETIF_MSG_IFUP, "tstorm_mac_filter[%d]: 0x%08x\n", i,
 		   ((u32 *)&tstorm_mac_filter)[i]); */
 	}
-}
 
-static void bnx2x_set_client_config(struct bnx2x *bp, int client_id)
-{
-#ifdef BCM_VLAN
-	int mode = bp->rx_mode;
-#endif
-	int port = bp->port;
-	struct tstorm_eth_client_config tstorm_client = {0};
-
-	tstorm_client.mtu = bp->dev->mtu;
-	tstorm_client.statistics_counter_id = 0;
-	tstorm_client.config_flags =
-		TSTORM_ETH_CLIENT_CONFIG_STATSITICS_ENABLE;
-#ifdef BCM_VLAN
-	if (mode && bp->vlgrp) {
-		tstorm_client.config_flags |=
-				TSTORM_ETH_CLIENT_CONFIG_VLAN_REMOVAL_ENABLE;
-		DP(NETIF_MSG_IFUP, "vlan removal enabled\n");
-	}
-#endif
-	tstorm_client.drop_flags = (TSTORM_ETH_CLIENT_CONFIG_DROP_IP_CS_ERR |
-				    TSTORM_ETH_CLIENT_CONFIG_DROP_TCP_CS_ERR |
-				    TSTORM_ETH_CLIENT_CONFIG_DROP_UDP_CS_ERR |
-				    TSTORM_ETH_CLIENT_CONFIG_DROP_MAC_ERR);
-
-	REG_WR(bp, BAR_TSTRORM_INTMEM +
-	       TSTORM_CLIENT_CONFIG_OFFSET(port, client_id),
-	       ((u32 *)&tstorm_client)[0]);
-	REG_WR(bp, BAR_TSTRORM_INTMEM +
-	       TSTORM_CLIENT_CONFIG_OFFSET(port, client_id) + 4,
-	       ((u32 *)&tstorm_client)[1]);
-
-/*      DP(NETIF_MSG_IFUP, "tstorm_client: 0x%08x 0x%08x\n",
-	   ((u32 *)&tstorm_client)[0], ((u32 *)&tstorm_client)[1]); */
+	if (mode != BNX2X_RX_MODE_NONE)
+		bnx2x_set_client_config(bp);
 }
 
 static void bnx2x_init_internal(struct bnx2x *bp)
@@ -5634,7 +5651,6 @@ static void bnx2x_init_internal(struct bnx2x *bp)
 	int port = bp->port;
 	struct tstorm_eth_function_common_config tstorm_config = {0};
 	struct stats_indication_flags stats_flags = {0};
-	int i;
 
 	if (is_multi(bp)) {
 		tstorm_config.config_flags = MULTI_FLAGS;
@@ -5651,10 +5667,6 @@ static void bnx2x_init_internal(struct bnx2x *bp)
 	bp->rx_mode = BNX2X_RX_MODE_NONE; /* no rx until link is up */
 	bnx2x_set_storm_rx_mode(bp);
 
-	for_each_queue(bp, i)
-		bnx2x_set_client_config(bp, i);
-
-
 	stats_flags.collect_eth = cpu_to_le32(1);
 
 	REG_WR(bp, BAR_XSTRORM_INTMEM + XSTORM_STATS_FLAGS_OFFSET(port),
@@ -6961,7 +6973,7 @@ static int bnx2x_wait_ramrod(struct bnx2x *bp, int state, int idx,
 
 		mb(); /* state is changed by bnx2x_sp_event()*/
 
-		if (*state_p != state)
+		if (*state_p == state)
 			return 0;
 
 		timeout--;
@@ -6970,9 +6982,10 @@ static int bnx2x_wait_ramrod(struct bnx2x *bp, int state, int idx,
 	}
 
 	/* timeout! */
-	BNX2X_ERR("timeout waiting for ramrod %d on %d\n", state, idx);
-	return -EBUSY;
+	BNX2X_ERR("timeout %s for state %x on IDX [%d]\n",
+		  poll ? "polling" : "waiting", state, idx);
 
+	return -EBUSY;
 }
 
 static int bnx2x_setup_leading(struct bnx2x *bp)
@@ -7239,7 +7252,7 @@ static int bnx2x_stop_multi(struct bnx2x *bp, int index)
 	/* delete cfc entry */
 	bnx2x_sp_post(bp, RAMROD_CMD_ID_ETH_CFC_DEL, index, 0, 0, 1);
 
-	return bnx2x_wait_ramrod(bp, BNX2X_FP_STATE_DELETED, index,
+	return bnx2x_wait_ramrod(bp, BNX2X_FP_STATE_CLOSED, index,
 				 &(bp->fp[index].state), 1);
 
 }
@@ -7247,7 +7260,7 @@ static int bnx2x_stop_multi(struct bnx2x *bp, int index)
 
 static void bnx2x_stop_leading(struct bnx2x *bp)
 {
-
+	u16 dsb_sp_prod_idx;
 	/* if the other port is handling traffic,
 	   this can take a lot of time */
 	int timeout = 500;
@@ -7262,23 +7275,29 @@ static void bnx2x_stop_leading(struct bnx2x *bp)
 			       &(bp->fp[0].state), 1))
 		return;
 
-	bp->dsb_sp_prod_idx = *bp->dsb_sp_prod;
+	dsb_sp_prod_idx = *bp->dsb_sp_prod;
 
 	/* Send CFC_DELETE ramrod */
 	bnx2x_sp_post(bp, RAMROD_CMD_ID_ETH_PORT_DEL, 0, 0, 0, 1);
 
-	/*
-	   Wait for completion.
+	/* Wait for completion to arrive on default status block
 	   we are going to reset the chip anyway
 	   so there is not much to do if this times out
 	 */
-	while (bp->dsb_sp_prod_idx == *bp->dsb_sp_prod && timeout) {
-			timeout--;
-			msleep(1);
+	while ((dsb_sp_prod_idx == *bp->dsb_sp_prod) && timeout) {
+		timeout--;
+		msleep(1);
 	}
-
+	if (!timeout) {
+		DP(NETIF_MSG_IFDOWN, "timeout polling for completion "
+		   "dsb_sp_prod 0x%x != dsb_sp_prod_idx 0x%x\n",
+		   *bp->dsb_sp_prod, dsb_sp_prod_idx);
+	}
+	bp->state = BNX2X_STATE_CLOSING_WAIT4_UNLOAD;
+	bp->fp[0].state = BNX2X_FP_STATE_CLOSED;
 }
 
+
 static int bnx2x_nic_unload(struct bnx2x *bp, int fre_irq)
 {
 	u32 reset_code = 0;
@@ -8968,9 +8987,7 @@ static int bnx2x_set_power_state(struct bnx2x *bp, pci_power_t state)
  * net_device service functions
  */
 
-/* Called with rtnl_lock from vlan functions and also netif_tx_lock
- * from set_multicast.
- */
+/* called with netif_tx_lock from set_multicast */
 static void bnx2x_set_rx_mode(struct net_device *dev)
 {
 	struct bnx2x *bp = netdev_priv(dev);
@@ -9496,7 +9513,7 @@ static void bnx2x_vlan_rx_register(struct net_device *dev,
 
 	bp->vlgrp = vlgrp;
 	if (netif_running(dev))
-		bnx2x_set_rx_mode(dev);
+		bnx2x_set_client_config(bp);
 }
 #endif
 
diff --git a/drivers/net/bnx2x.h b/drivers/net/bnx2x.h
index dc423e5..d0e5ab1 100644
--- a/drivers/net/bnx2x.h
+++ b/drivers/net/bnx2x.h
@@ -1,6 +1,6 @@
 /* bnx2x.h: Broadcom Everest network driver.
  *
- * Copyright (c) 2007 Broadcom Corporation
+ * Copyright (c) 2007-2008 Broadcom Corporation
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
@@ -431,8 +431,6 @@ struct bnx2x_fastpath {
 #define BNX2X_FP_STATE_OPEN     	0xa0000
 #define BNX2X_FP_STATE_HALTING  	0xb0000
 #define BNX2X_FP_STATE_HALTED   	0xc0000
-#define BNX2X_FP_STATE_DELETED  	0xd0000
-#define BNX2X_FP_STATE_CLOSE_IRQ	0xe0000
 
 	int     		index;
 
@@ -513,7 +511,6 @@ struct bnx2x {
 	struct eth_spe  	*spq;
 	dma_addr_t      	spq_mapping;
 	u16     		spq_prod_idx;
-	u16     		dsb_sp_prod_idx;
 	struct eth_spe  	*spq_prod_bd;
 	struct eth_spe  	*spq_last_bd;
 	u16     		*dsb_sp_prod;
-- 
1.5.3.2




