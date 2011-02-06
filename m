From: "Vlad Zolotarov" <vladz@broadcom.com>
Subject: [PATCH net-next] bnx2x: Proper netdev->ndo_set_rx_mode()
 implementation.
Date: Sun, 6 Feb 2011 18:50:40 +0200
Message-ID: <201102061850.40458.vladz@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: "Dave Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2074 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753016Ab1BFQu7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 6 Feb 2011 11:50:59 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Completed the bnx2x_set_rx_mode() to a proper netdev->ndo_set_rx_mode 
implementation: 
 - Added a missing configuration of a unicast MAC addresses list.
 - Changed bp->dma_lock from being a mutex to a spinlock as long as it's taken
under netdev->addr_list_lock now.

Signed-off-by: Vladislav Zolotarov <vladz@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x.h      |   13 +-
 drivers/net/bnx2x/bnx2x_cmn.c  |   17 +-
 drivers/net/bnx2x/bnx2x_main.c |  444 +++++++++++++++++++++++++++++++---------
 3 files changed, 369 insertions(+), 105 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x.h b/drivers/net/bnx2x/bnx2x.h
index 8e41837..9821bd9 100644
--- a/drivers/net/bnx2x/bnx2x.h
+++ b/drivers/net/bnx2x/bnx2x.h
@@ -129,6 +129,7 @@ void bnx2x_panic_dump(struct bnx2x *bp);
 #endif
 
 #define bnx2x_mc_addr(ha)      ((ha)->addr)
+#define bnx2x_uc_addr(ha)      ((ha)->addr)
 
 #define U64_LO(x)			(u32)(((u64)(x)) & 0xffffffff)
 #define U64_HI(x)			(u32)(((u64)(x)) >> 32)
@@ -810,6 +811,7 @@ struct bnx2x_slowpath {
 	struct eth_stats_query		fw_stats;
 	struct mac_configuration_cmd	mac_config;
 	struct mac_configuration_cmd	mcast_config;
+	struct mac_configuration_cmd	uc_mac_config;
 	struct client_init_ramrod_data	client_init_data;
 
 	/* used by dmae command executer */
@@ -939,7 +941,7 @@ struct bnx2x {
 	struct eth_spe		*spq_prod_bd;
 	struct eth_spe		*spq_last_bd;
 	__le16			*dsb_sp_prod;
-	atomic_t		spq_left; /* serialize spq */
+	atomic_t		cq_spq_left; /* ETH_XXX ramrods credit */
 	/* used to synchronize spq accesses */
 	spinlock_t		spq_lock;
 
@@ -949,6 +951,7 @@ struct bnx2x {
 	u16			eq_prod;
 	u16			eq_cons;
 	__le16			*eq_cons_sb;
+	atomic_t		eq_spq_left; /* COMMON_XXX ramrods credit */
 
 	/* Flags for marking that there is a STAT_QUERY or
 	   SET_MAC ramrod pending */
@@ -1131,7 +1134,7 @@ struct bnx2x {
 
 	int			dmae_ready;
 	/* used to synchronize dmae accesses */
-	struct mutex		dmae_mutex;
+	spinlock_t		dmae_lock;
 
 	/* used to protect the FW mail box */
 	struct mutex		fw_mb_mutex;
@@ -1447,6 +1450,12 @@ u32 bnx2x_fw_command(struct bnx2x *bp, u32 command, u32 param);
 void bnx2x_calc_fc_adv(struct bnx2x *bp);
 int bnx2x_sp_post(struct bnx2x *bp, int command, int cid,
 		  u32 data_hi, u32 data_lo, int common);
+
+/* Clears multicast and unicast list configuration in the chip. */
+void bnx2x_invalidate_e1_mc_list(struct bnx2x *bp);
+void bnx2x_invalidate_e1h_mc_list(struct bnx2x *bp);
+void bnx2x_invalidate_uc_list(struct bnx2x *bp);
+
 void bnx2x_update_coalesce(struct bnx2x *bp);
 int bnx2x_get_link_cfg_idx(struct bnx2x *bp);
 
diff --git a/drivers/net/bnx2x/bnx2x_cmn.c b/drivers/net/bnx2x/bnx2x_cmn.c
index 710ce5d..ae98f7d 100644
--- a/drivers/net/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/bnx2x/bnx2x_cmn.c
@@ -1427,28 +1427,35 @@ int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
 
 	bnx2x_set_eth_mac(bp, 1);
 
+	/* Clear MC configuration */
+	if (CHIP_IS_E1(bp))
+		bnx2x_invalidate_e1_mc_list(bp);
+	else
+		bnx2x_invalidate_e1h_mc_list(bp);
+
+	/* Clear UC lists configuration */
+	bnx2x_invalidate_uc_list(bp);
+
 	if (bp->port.pmf)
 		bnx2x_initial_phy_init(bp, load_mode);
 
+	/* Initialize Rx filtering */
+	bnx2x_set_rx_mode(bp->dev);
+
 	/* Start fast path */
 	switch (load_mode) {
 	case LOAD_NORMAL:
 		/* Tx queue should be only reenabled */
 		netif_tx_wake_all_queues(bp->dev);
 		/* Initialize the receive filter. */
-		bnx2x_set_rx_mode(bp->dev);
 		break;
 
 	case LOAD_OPEN:
 		netif_tx_start_all_queues(bp->dev);
 		smp_mb__after_clear_bit();
-		/* Initialize the receive filter. */
-		bnx2x_set_rx_mode(bp->dev);
 		break;
 
 	case LOAD_DIAG:
-		/* Initialize the receive filter. */
-		bnx2x_set_rx_mode(bp->dev);
 		bp->state = BNX2X_STATE_DIAG;
 		break;
 
diff --git a/drivers/net/bnx2x/bnx2x_main.c b/drivers/net/bnx2x/bnx2x_main.c
index 8cdcf5b..ea10b26 100644
--- a/drivers/net/bnx2x/bnx2x_main.c
+++ b/drivers/net/bnx2x/bnx2x_main.c
@@ -586,7 +586,7 @@ static int bnx2x_issue_dmae_with_comp(struct bnx2x *bp,
 	   bp->slowpath->wb_data[2], bp->slowpath->wb_data[3]);
 
 	/* lock the dmae channel */
-	mutex_lock(&bp->dmae_mutex);
+	spin_lock_bh(&bp->dmae_lock);
 
 	/* reset completion */
 	*wb_comp = 0;
@@ -617,7 +617,7 @@ static int bnx2x_issue_dmae_with_comp(struct bnx2x *bp,
 	   bp->slowpath->wb_data[2], bp->slowpath->wb_data[3]);
 
 unlock:
-	mutex_unlock(&bp->dmae_mutex);
+	spin_unlock_bh(&bp->dmae_lock);
 	return rc;
 }
 
@@ -1397,7 +1397,7 @@ void bnx2x_sp_event(struct bnx2x_fastpath *fp,
 	}
 
 	smp_mb__before_atomic_inc();
-	atomic_inc(&bp->spq_left);
+	atomic_inc(&bp->cq_spq_left);
 	/* push the change in fp->state and towards the memory */
 	smp_wmb();
 
@@ -2731,11 +2731,18 @@ int bnx2x_sp_post(struct bnx2x *bp, int command, int cid,
 
 	spin_lock_bh(&bp->spq_lock);
 
-	if (!atomic_read(&bp->spq_left)) {
-		BNX2X_ERR("BUG! SPQ ring full!\n");
-		spin_unlock_bh(&bp->spq_lock);
-		bnx2x_panic();
-		return -EBUSY;
+	if (common) {
+		if (!atomic_read(&bp->eq_spq_left)) {
+			BNX2X_ERR("BUG! EQ ring full!\n");
+			spin_unlock_bh(&bp->spq_lock);
+			bnx2x_panic();
+			return -EBUSY;
+		}
+	} else if (!atomic_read(&bp->cq_spq_left)) {
+			BNX2X_ERR("BUG! SPQ ring full!\n");
+			spin_unlock_bh(&bp->spq_lock);
+			bnx2x_panic();
+			return -EBUSY;
 	}
 
 	spe = bnx2x_sp_get_next(bp);
@@ -2766,20 +2773,26 @@ int bnx2x_sp_post(struct bnx2x *bp, int command, int cid,
 	spe->data.update_data_addr.lo = cpu_to_le32(data_lo);
 
 	/* stats ramrod has it's own slot on the spq */
-	if (command != RAMROD_CMD_ID_COMMON_STAT_QUERY)
+	if (command != RAMROD_CMD_ID_COMMON_STAT_QUERY) {
 		/* It's ok if the actual decrement is issued towards the memory
 		 * somewhere between the spin_lock and spin_unlock. Thus no
 		 * more explict memory barrier is needed.
 		 */
-		atomic_dec(&bp->spq_left);
+		if (common)
+			atomic_dec(&bp->eq_spq_left);
+		else
+			atomic_dec(&bp->cq_spq_left);
+	}
+
 
 	DP(BNX2X_MSG_SP/*NETIF_MSG_TIMER*/,
 	   "SPQE[%x] (%x:%x)  command %d  hw_cid %x  data (%x:%x) "
-	   "type(0x%x) left %x\n",
+	   "type(0x%x) left (ETH, COMMON) (%x,%x)\n",
 	   bp->spq_prod_idx, (u32)U64_HI(bp->spq_mapping),
 	   (u32)(U64_LO(bp->spq_mapping) +
 	   (void *)bp->spq_prod_bd - (void *)bp->spq), command,
-	   HW_CID(bp, cid), data_hi, data_lo, type, atomic_read(&bp->spq_left));
+	   HW_CID(bp, cid), data_hi, data_lo, type,
+	   atomic_read(&bp->cq_spq_left), atomic_read(&bp->eq_spq_left));
 
 	bnx2x_sp_prod_update(bp);
 	spin_unlock_bh(&bp->spq_lock);
@@ -3691,8 +3704,8 @@ static void bnx2x_eq_int(struct bnx2x *bp)
 	sw_cons = bp->eq_cons;
 	sw_prod = bp->eq_prod;
 
-	DP(BNX2X_MSG_SP, "EQ:  hw_cons %u  sw_cons %u bp->spq_left %u\n",
-			hw_cons, sw_cons, atomic_read(&bp->spq_left));
+	DP(BNX2X_MSG_SP, "EQ:  hw_cons %u  sw_cons %u bp->cq_spq_left %u\n",
+			hw_cons, sw_cons, atomic_read(&bp->eq_spq_left));
 
 	for (; sw_cons != hw_cons;
 	      sw_prod = NEXT_EQ_IDX(sw_prod), sw_cons = NEXT_EQ_IDX(sw_cons)) {
@@ -3757,13 +3770,15 @@ static void bnx2x_eq_int(struct bnx2x *bp)
 		case (EVENT_RING_OPCODE_SET_MAC | BNX2X_STATE_OPEN):
 		case (EVENT_RING_OPCODE_SET_MAC | BNX2X_STATE_DIAG):
 			DP(NETIF_MSG_IFUP, "got set mac ramrod\n");
-			bp->set_mac_pending = 0;
+			if (elem->message.data.set_mac_event.echo)
+				bp->set_mac_pending = 0;
 			break;
 
 		case (EVENT_RING_OPCODE_SET_MAC |
 		      BNX2X_STATE_CLOSING_WAIT4_HALT):
 			DP(NETIF_MSG_IFDOWN, "got (un)set mac ramrod\n");
-			bp->set_mac_pending = 0;
+			if (elem->message.data.set_mac_event.echo)
+				bp->set_mac_pending = 0;
 			break;
 		default:
 			/* unknown event log error and continue */
@@ -3775,7 +3790,7 @@ next_spqe:
 	} /* for */
 
 	smp_mb__before_atomic_inc();
-	atomic_add(spqe_cnt, &bp->spq_left);
+	atomic_add(spqe_cnt, &bp->eq_spq_left);
 
 	bp->eq_cons = sw_cons;
 	bp->eq_prod = sw_prod;
@@ -4208,7 +4223,7 @@ void bnx2x_update_coalesce(struct bnx2x *bp)
 static void bnx2x_init_sp_ring(struct bnx2x *bp)
 {
 	spin_lock_init(&bp->spq_lock);
-	atomic_set(&bp->spq_left, MAX_SPQ_PENDING);
+	atomic_set(&bp->cq_spq_left, MAX_SPQ_PENDING);
 
 	bp->spq_prod_idx = 0;
 	bp->dsb_sp_prod = BNX2X_SP_DSB_INDEX;
@@ -4233,6 +4248,9 @@ static void bnx2x_init_eq_ring(struct bnx2x *bp)
 	bp->eq_cons = 0;
 	bp->eq_prod = NUM_EQ_DESC;
 	bp->eq_cons_sb = BNX2X_EQ_INDEX;
+	/* we want a warning message before it gets rought... */
+	atomic_set(&bp->eq_spq_left,
+		min_t(int, MAX_SP_DESC_CNT - MAX_SPQ_PENDING, NUM_EQ_DESC) - 1);
 }
 
 static void bnx2x_init_ind_table(struct bnx2x *bp)
@@ -5838,7 +5856,7 @@ int bnx2x_init_hw(struct bnx2x *bp, u32 load_code)
 	   BP_ABS_FUNC(bp), load_code);
 
 	bp->dmae_ready = 0;
-	mutex_init(&bp->dmae_mutex);
+	spin_lock_init(&bp->dmae_lock);
 	rc = bnx2x_gunzip_init(bp);
 	if (rc)
 		return rc;
@@ -6173,12 +6191,14 @@ static void bnx2x_set_mac_addr_gen(struct bnx2x *bp, int set, const u8 *mac,
 	int ramrod_flags = WAIT_RAMROD_COMMON;
 
 	bp->set_mac_pending = 1;
-	smp_wmb();
 
 	config->hdr.length = 1;
 	config->hdr.offset = cam_offset;
 	config->hdr.client_id = 0xff;
-	config->hdr.reserved1 = 0;
+	/* Mark the single MAC configuration ramrod as opposed to a
+	 * UC/MC list configuration).
+	 */
+	config->hdr.echo = 1;
 
 	/* primary MAC */
 	config->config_table[0].msb_mac_addr =
@@ -6210,6 +6230,8 @@ static void bnx2x_set_mac_addr_gen(struct bnx2x *bp, int set, const u8 *mac,
 	   config->config_table[0].middle_mac_addr,
 	   config->config_table[0].lsb_mac_addr, BP_FUNC(bp), cl_bit_vec);
 
+	mb();
+
 	bnx2x_sp_post(bp, RAMROD_CMD_ID_COMMON_SET_MAC, 0,
 		      U64_HI(bnx2x_sp_mapping(bp, mac_config)),
 		      U64_LO(bnx2x_sp_mapping(bp, mac_config)), 1);
@@ -6274,20 +6296,15 @@ static u8 bnx2x_e1h_cam_offset(struct bnx2x *bp, u8 rel_offset)
 	if (CHIP_IS_E1H(bp))
 		return E1H_FUNC_MAX * rel_offset + BP_FUNC(bp);
 	else if (CHIP_MODE_IS_4_PORT(bp))
-		return BP_FUNC(bp) * 32  + rel_offset;
+		return E2_FUNC_MAX * rel_offset + BP_FUNC(bp);
 	else
-		return BP_VN(bp) * 32  + rel_offset;
+		return E2_FUNC_MAX * rel_offset + BP_VN(bp);
 }
 
 /**
  *  LLH CAM line allocations: currently only iSCSI and ETH macs are
  *  relevant. In addition, current implementation is tuned for a
  *  single ETH MAC.
- *
- *  When multiple unicast ETH MACs PF configuration in switch
- *  independent mode is required (NetQ, multiple netdev MACs,
- *  etc.), consider better utilisation of 16 per function MAC
- *  entries in the LLH memory.
  */
 enum {
 	LLH_CAM_ISCSI_ETH_LINE = 0,
@@ -6362,14 +6379,37 @@ void bnx2x_set_eth_mac(struct bnx2x *bp, int set)
 		bnx2x_set_mac_addr_gen(bp, set, bcast, 0, cam_offset + 1, 1);
 	}
 }
-static void bnx2x_set_e1_mc_list(struct bnx2x *bp, u8 offset)
+
+static inline u8 bnx2x_e1_cam_mc_offset(struct bnx2x *bp)
+{
+	return CHIP_REV_IS_SLOW(bp) ?
+		(BNX2X_MAX_EMUL_MULTI * (1 + BP_PORT(bp))) :
+		(BNX2X_MAX_MULTICAST * (1 + BP_PORT(bp)));
+}
+
+/* set mc list, do not wait as wait implies sleep and
+ * set_rx_mode can be invoked from non-sleepable context.
+ *
+ * Instead we use the same ramrod data buffer each time we need
+ * to configure a list of addresses, and use the fact that the
+ * list of MACs is changed in an incremental way and that the
+ * function is called under the netif_addr_lock. A temporary
+ * inconsistent CAM configuration (possible in case of a very fast
+ * sequence of add/del/add on the host side) will shortly be
+ * restored by the handler of the last ramrod.
+ */
+static int bnx2x_set_e1_mc_list(struct bnx2x *bp)
 {
 	int i = 0, old;
 	struct net_device *dev = bp->dev;
+	u8 offset = bnx2x_e1_cam_mc_offset(bp);
 	struct netdev_hw_addr *ha;
 	struct mac_configuration_cmd *config_cmd = bnx2x_sp(bp, mcast_config);
 	dma_addr_t config_cmd_map = bnx2x_sp_mapping(bp, mcast_config);
 
+	if (netdev_mc_count(dev) > BNX2X_MAX_MULTICAST)
+		return -EINVAL;
+
 	netdev_for_each_mc_addr(ha, dev) {
 		/* copy mac */
 		config_cmd->config_table[i].msb_mac_addr =
@@ -6410,32 +6450,47 @@ static void bnx2x_set_e1_mc_list(struct bnx2x *bp, u8 offset)
 		}
 	}
 
+	wmb();
+
 	config_cmd->hdr.length = i;
 	config_cmd->hdr.offset = offset;
 	config_cmd->hdr.client_id = 0xff;
-	config_cmd->hdr.reserved1 = 0;
+	/* Mark that this ramrod doesn't use bp->set_mac_pending for
+	 * synchronization.
+	 */
+	config_cmd->hdr.echo = 0;
 
-	bp->set_mac_pending = 1;
-	smp_wmb();
+	mb();
 
-	bnx2x_sp_post(bp, RAMROD_CMD_ID_COMMON_SET_MAC, 0,
+	return bnx2x_sp_post(bp, RAMROD_CMD_ID_COMMON_SET_MAC, 0,
 		   U64_HI(config_cmd_map), U64_LO(config_cmd_map), 1);
 }
-static void bnx2x_invlidate_e1_mc_list(struct bnx2x *bp)
+
+void bnx2x_invalidate_e1_mc_list(struct bnx2x *bp)
 {
 	int i;
 	struct mac_configuration_cmd *config_cmd = bnx2x_sp(bp, mcast_config);
 	dma_addr_t config_cmd_map = bnx2x_sp_mapping(bp, mcast_config);
 	int ramrod_flags = WAIT_RAMROD_COMMON;
+	u8 offset = bnx2x_e1_cam_mc_offset(bp);
 
-	bp->set_mac_pending = 1;
-	smp_wmb();
-
-	for (i = 0; i < config_cmd->hdr.length; i++)
+	for (i = 0; i < BNX2X_MAX_MULTICAST; i++)
 		SET_FLAG(config_cmd->config_table[i].flags,
 			MAC_CONFIGURATION_ENTRY_ACTION_TYPE,
 			T_ETH_MAC_COMMAND_INVALIDATE);
 
+	wmb();
+
+	config_cmd->hdr.length = BNX2X_MAX_MULTICAST;
+	config_cmd->hdr.offset = offset;
+	config_cmd->hdr.client_id = 0xff;
+	/* We'll wait for a completion this time... */
+	config_cmd->hdr.echo = 1;
+
+	bp->set_mac_pending = 1;
+
+	mb();
+
 	bnx2x_sp_post(bp, RAMROD_CMD_ID_COMMON_SET_MAC, 0,
 		      U64_HI(config_cmd_map), U64_LO(config_cmd_map), 1);
 
@@ -6445,6 +6500,44 @@ static void bnx2x_invlidate_e1_mc_list(struct bnx2x *bp)
 
 }
 
+/* Accept one or more multicasts */
+static int bnx2x_set_e1h_mc_list(struct bnx2x *bp)
+{
+	struct net_device *dev = bp->dev;
+	struct netdev_hw_addr *ha;
+	u32 mc_filter[MC_HASH_SIZE];
+	u32 crc, bit, regidx;
+	int i;
+
+	memset(mc_filter, 0, 4 * MC_HASH_SIZE);
+
+	netdev_for_each_mc_addr(ha, dev) {
+		DP(NETIF_MSG_IFUP, "Adding mcast MAC: %pM\n",
+		   bnx2x_mc_addr(ha));
+
+		crc = crc32c_le(0, bnx2x_mc_addr(ha),
+				ETH_ALEN);
+		bit = (crc >> 24) & 0xff;
+		regidx = bit >> 5;
+		bit &= 0x1f;
+		mc_filter[regidx] |= (1 << bit);
+	}
+
+	for (i = 0; i < MC_HASH_SIZE; i++)
+		REG_WR(bp, MC_HASH_OFFSET(bp, i),
+		       mc_filter[i]);
+
+	return 0;
+}
+
+void bnx2x_invalidate_e1h_mc_list(struct bnx2x *bp)
+{
+	int i;
+
+	for (i = 0; i < MC_HASH_SIZE; i++)
+		REG_WR(bp, MC_HASH_OFFSET(bp, i), 0);
+}
+
 #ifdef BCM_CNIC
 /**
  * Set iSCSI MAC(s) at the next enties in the CAM after the ETH
@@ -7110,20 +7203,15 @@ void bnx2x_chip_cleanup(struct bnx2x *bp, int unload_mode)
 	/* Give HW time to discard old tx messages */
 	msleep(1);
 
-	if (CHIP_IS_E1(bp)) {
-		/* invalidate mc list,
-		 * wait and poll (interrupts are off)
-		 */
-		bnx2x_invlidate_e1_mc_list(bp);
-		bnx2x_set_eth_mac(bp, 0);
-
-	} else {
-		REG_WR(bp, NIG_REG_LLH0_FUNC_EN + port*8, 0);
+	bnx2x_set_eth_mac(bp, 0);
 
-		bnx2x_set_eth_mac(bp, 0);
+	bnx2x_invalidate_uc_list(bp);
 
-		for (i = 0; i < MC_HASH_SIZE; i++)
-			REG_WR(bp, MC_HASH_OFFSET(bp, i), 0);
+	if (CHIP_IS_E1(bp))
+		bnx2x_invalidate_e1_mc_list(bp);
+	else {
+		bnx2x_invalidate_e1h_mc_list(bp);
+		REG_WR(bp, NIG_REG_LLH0_FUNC_EN + port*8, 0);
 	}
 
 #ifdef BCM_CNIC
@@ -8813,12 +8901,197 @@ static int bnx2x_close(struct net_device *dev)
 	return 0;
 }
 
+#define E1_MAX_UC_LIST	29
+#define E1H_MAX_UC_LIST	30
+#define E2_MAX_UC_LIST	14
+static inline u8 bnx2x_max_uc_list(struct bnx2x *bp)
+{
+	if (CHIP_IS_E1(bp))
+		return E1_MAX_UC_LIST;
+	else if (CHIP_IS_E1H(bp))
+		return E1H_MAX_UC_LIST;
+	else
+		return E2_MAX_UC_LIST;
+}
+
+
+static inline u8 bnx2x_uc_list_cam_offset(struct bnx2x *bp)
+{
+	if (CHIP_IS_E1(bp))
+		/* CAM Entries for Port0:
+		 *      0 - prim ETH MAC
+		 *      1 - BCAST MAC
+		 *      2 - iSCSI L2 ring ETH MAC
+		 *      3-31 - UC MACs
+		 *
+		 * Port1 entries are allocated the same way starting from
+		 * entry 32.
+		 */
+		return 3 + 32 * BP_PORT(bp);
+	else if (CHIP_IS_E1H(bp)) {
+		/* CAM Entries:
+		 *      0-7  - prim ETH MAC for each function
+		 *      8-15 - iSCSI L2 ring ETH MAC for each function
+		 *      16 till 255 UC MAC lists for each function
+		 *
+		 * Remark: There is no FCoE support for E1H, thus FCoE related
+		 *         MACs are not considered.
+		 */
+		return E1H_FUNC_MAX * (CAM_ISCSI_ETH_LINE + 1) +
+			bnx2x_max_uc_list(bp) * BP_FUNC(bp);
+	} else {
+		/* CAM Entries (there is a separate CAM per engine):
+		 *      0-4  - prim ETH MAC for each function
+		 *      4-7 - iSCSI L2 ring ETH MAC for each function
+		 *      8-11 - FIP ucast L2 MAC for each function
+		 *      12-15 - ALL_ENODE_MACS mcast MAC for each function
+		 *      16 till 71 UC MAC lists for each function
+		 */
+		u8 func_idx =
+			(CHIP_MODE_IS_4_PORT(bp) ? BP_FUNC(bp) : BP_VN(bp));
+
+		return E2_FUNC_MAX * (CAM_MAX_PF_LINE + 1) +
+			bnx2x_max_uc_list(bp) * func_idx;
+	}
+}
+
+/* set uc list, do not wait as wait implies sleep and
+ * set_rx_mode can be invoked from non-sleepable context.
+ *
+ * Instead we use the same ramrod data buffer each time we need
+ * to configure a list of addresses, and use the fact that the
+ * list of MACs is changed in an incremental way and that the
+ * function is called under the netif_addr_lock. A temporary
+ * inconsistent CAM configuration (possible in case of very fast
+ * sequence of add/del/add on the host side) will shortly be
+ * restored by the handler of the last ramrod.
+ */
+static int bnx2x_set_uc_list(struct bnx2x *bp)
+{
+	int i = 0, old;
+	struct net_device *dev = bp->dev;
+	u8 offset = bnx2x_uc_list_cam_offset(bp);
+	struct netdev_hw_addr *ha;
+	struct mac_configuration_cmd *config_cmd = bnx2x_sp(bp, uc_mac_config);
+	dma_addr_t config_cmd_map = bnx2x_sp_mapping(bp, uc_mac_config);
+
+	if (netdev_uc_count(dev) > bnx2x_max_uc_list(bp))
+		return -EINVAL;
+
+	netdev_for_each_uc_addr(ha, dev) {
+		/* copy mac */
+		config_cmd->config_table[i].msb_mac_addr =
+			swab16(*(u16 *)&bnx2x_uc_addr(ha)[0]);
+		config_cmd->config_table[i].middle_mac_addr =
+			swab16(*(u16 *)&bnx2x_uc_addr(ha)[2]);
+		config_cmd->config_table[i].lsb_mac_addr =
+			swab16(*(u16 *)&bnx2x_uc_addr(ha)[4]);
+
+		config_cmd->config_table[i].vlan_id = 0;
+		config_cmd->config_table[i].pf_id = BP_FUNC(bp);
+		config_cmd->config_table[i].clients_bit_vector =
+			cpu_to_le32(1 << BP_L_ID(bp));
+
+		SET_FLAG(config_cmd->config_table[i].flags,
+			MAC_CONFIGURATION_ENTRY_ACTION_TYPE,
+			T_ETH_MAC_COMMAND_SET);
+
+		DP(NETIF_MSG_IFUP,
+		   "setting UCAST[%d] (%04x:%04x:%04x)\n", i,
+		   config_cmd->config_table[i].msb_mac_addr,
+		   config_cmd->config_table[i].middle_mac_addr,
+		   config_cmd->config_table[i].lsb_mac_addr);
+
+		i++;
+
+		/* Set uc MAC in NIG */
+		bnx2x_set_mac_in_nig(bp, 1, bnx2x_uc_addr(ha),
+				     LLH_CAM_ETH_LINE + i);
+	}
+	old = config_cmd->hdr.length;
+	if (old > i) {
+		for (; i < old; i++) {
+			if (CAM_IS_INVALID(config_cmd->
+					   config_table[i])) {
+				/* already invalidated */
+				break;
+			}
+			/* invalidate */
+			SET_FLAG(config_cmd->config_table[i].flags,
+				MAC_CONFIGURATION_ENTRY_ACTION_TYPE,
+				T_ETH_MAC_COMMAND_INVALIDATE);
+		}
+	}
+
+	wmb();
+
+	config_cmd->hdr.length = i;
+	config_cmd->hdr.offset = offset;
+	config_cmd->hdr.client_id = 0xff;
+	/* Mark that this ramrod doesn't use bp->set_mac_pending for
+	 * synchronization.
+	 */
+	config_cmd->hdr.echo = 0;
+
+	mb();
+
+	return bnx2x_sp_post(bp, RAMROD_CMD_ID_COMMON_SET_MAC, 0,
+		   U64_HI(config_cmd_map), U64_LO(config_cmd_map), 1);
+
+}
+
+void bnx2x_invalidate_uc_list(struct bnx2x *bp)
+{
+	int i;
+	struct mac_configuration_cmd *config_cmd = bnx2x_sp(bp, uc_mac_config);
+	dma_addr_t config_cmd_map = bnx2x_sp_mapping(bp, uc_mac_config);
+	int ramrod_flags = WAIT_RAMROD_COMMON;
+	u8 offset = bnx2x_uc_list_cam_offset(bp);
+	u8 max_list_size = bnx2x_max_uc_list(bp);
+
+	for (i = 0; i < max_list_size; i++) {
+		SET_FLAG(config_cmd->config_table[i].flags,
+			MAC_CONFIGURATION_ENTRY_ACTION_TYPE,
+			T_ETH_MAC_COMMAND_INVALIDATE);
+		bnx2x_set_mac_in_nig(bp, 0, NULL, LLH_CAM_ETH_LINE + 1 + i);
+	}
+
+	wmb();
+
+	config_cmd->hdr.length = max_list_size;
+	config_cmd->hdr.offset = offset;
+	config_cmd->hdr.client_id = 0xff;
+	/* We'll wait for a completion this time... */
+	config_cmd->hdr.echo = 1;
+
+	bp->set_mac_pending = 1;
+
+	mb();
+
+	bnx2x_sp_post(bp, RAMROD_CMD_ID_COMMON_SET_MAC, 0,
+		      U64_HI(config_cmd_map), U64_LO(config_cmd_map), 1);
+
+	/* Wait for a completion */
+	bnx2x_wait_ramrod(bp, 0, 0, &bp->set_mac_pending,
+				ramrod_flags);
+
+}
+
+static inline int bnx2x_set_mc_list(struct bnx2x *bp)
+{
+	/* some multicasts */
+	if (CHIP_IS_E1(bp)) {
+		return bnx2x_set_e1_mc_list(bp);
+	} else { /* E1H and newer */
+		return bnx2x_set_e1h_mc_list(bp);
+	}
+}
+
 /* called with netif_tx_lock from dev_mcast.c */
 void bnx2x_set_rx_mode(struct net_device *dev)
 {
 	struct bnx2x *bp = netdev_priv(dev);
 	u32 rx_mode = BNX2X_RX_MODE_NORMAL;
-	int port = BP_PORT(bp);
 
 	if (bp->state != BNX2X_STATE_OPEN) {
 		DP(NETIF_MSG_IFUP, "state is %x, returning\n", bp->state);
@@ -8829,47 +9102,16 @@ void bnx2x_set_rx_mode(struct net_device *dev)
 
 	if (dev->flags & IFF_PROMISC)
 		rx_mode = BNX2X_RX_MODE_PROMISC;
-	else if ((dev->flags & IFF_ALLMULTI) ||
-		 ((netdev_mc_count(dev) > BNX2X_MAX_MULTICAST) &&
-		  CHIP_IS_E1(bp)))
+	else if (dev->flags & IFF_ALLMULTI)
 		rx_mode = BNX2X_RX_MODE_ALLMULTI;
-	else { /* some multicasts */
-		if (CHIP_IS_E1(bp)) {
-			/*
-			 * set mc list, do not wait as wait implies sleep
-			 * and set_rx_mode can be invoked from non-sleepable
-			 * context
-			 */
-			u8 offset = (CHIP_REV_IS_SLOW(bp) ?
-				     BNX2X_MAX_EMUL_MULTI*(1 + port) :
-				     BNX2X_MAX_MULTICAST*(1 + port));
-
-			bnx2x_set_e1_mc_list(bp, offset);
-		} else { /* E1H */
-			/* Accept one or more multicasts */
-			struct netdev_hw_addr *ha;
-			u32 mc_filter[MC_HASH_SIZE];
-			u32 crc, bit, regidx;
-			int i;
-
-			memset(mc_filter, 0, 4 * MC_HASH_SIZE);
-
-			netdev_for_each_mc_addr(ha, dev) {
-				DP(NETIF_MSG_IFUP, "Adding mcast MAC: %pM\n",
-				   bnx2x_mc_addr(ha));
-
-				crc = crc32c_le(0, bnx2x_mc_addr(ha),
-						ETH_ALEN);
-				bit = (crc >> 24) & 0xff;
-				regidx = bit >> 5;
-				bit &= 0x1f;
-				mc_filter[regidx] |= (1 << bit);
-			}
+	else {
+		/* some multicasts */
+		if (bnx2x_set_mc_list(bp))
+			rx_mode = BNX2X_RX_MODE_ALLMULTI;
 
-			for (i = 0; i < MC_HASH_SIZE; i++)
-				REG_WR(bp, MC_HASH_OFFSET(bp, i),
-				       mc_filter[i]);
-		}
+		/* some unicasts */
+		if (bnx2x_set_uc_list(bp))
+			rx_mode = BNX2X_RX_MODE_PROMISC;
 	}
 
 	bp->rx_mode = rx_mode;
@@ -8950,7 +9192,7 @@ static const struct net_device_ops bnx2x_netdev_ops = {
 	.ndo_stop		= bnx2x_close,
 	.ndo_start_xmit		= bnx2x_start_xmit,
 	.ndo_select_queue	= bnx2x_select_queue,
-	.ndo_set_multicast_list	= bnx2x_set_rx_mode,
+	.ndo_set_rx_mode	= bnx2x_set_rx_mode,
 	.ndo_set_mac_address	= bnx2x_change_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_do_ioctl		= bnx2x_ioctl,
@@ -9776,15 +10018,21 @@ static void bnx2x_cnic_sp_post(struct bnx2x *bp, int count)
 					HW_CID(bp, BNX2X_ISCSI_ETH_CID));
 		}
 
-		/* There may be not more than 8 L2 and COMMON SPEs and not more
-		 * than 8 L5 SPEs in the air.
+		/* There may be not more than 8 L2 and not more than 8 L5 SPEs
+		 * We also check that the number of outstanding
+		 * COMMON ramrods is not more than the EQ and SPQ can
+		 * accommodate.
 		 */
-		if ((type == NONE_CONNECTION_TYPE) ||
-		    (type == ETH_CONNECTION_TYPE)) {
-			if (!atomic_read(&bp->spq_left))
+		if (type == ETH_CONNECTION_TYPE) {
+			if (!atomic_read(&bp->cq_spq_left))
+				break;
+			else
+				atomic_dec(&bp->cq_spq_left);
+		} else if (type == NONE_CONNECTION_TYPE) {
+			if (!atomic_read(&bp->eq_spq_left))
 				break;
 			else
-				atomic_dec(&bp->spq_left);
+				atomic_dec(&bp->eq_spq_left);
 		} else if ((type == ISCSI_CONNECTION_TYPE) ||
 			   (type == FCOE_CONNECTION_TYPE)) {
 			if (bp->cnic_spq_pending >=
@@ -9976,7 +10224,7 @@ static int bnx2x_drv_ctl(struct net_device *dev, struct drv_ctl_info *ctl)
 		int count = ctl->data.credit.credit_count;
 
 		smp_mb__before_atomic_inc();
-		atomic_add(count, &bp->spq_left);
+		atomic_add(count, &bp->cq_spq_left);
 		smp_mb__after_atomic_inc();
 		break;
 	}
-- 
1.7.0.4


