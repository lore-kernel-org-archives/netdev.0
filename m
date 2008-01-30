From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 3/7][BNX2]: Remove REG_WR_IND/REG_RD_IND macros.
Date: Tue, 29 Jan 2008 16:19:33 -0800
Message-ID: <1201652373.19087.12.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3508 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750964AbYA2Xjb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Jan 2008 18:39:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[BNX2]: Remove REG_WR_IND/REG_RD_IND macros.

The REG_WR_IND/REG_RD_IND macros are unnecessary and obfuscate the
code.  Many callers to these macros read and write shared memory from
the bp->shmem_base, so we add 2 similar functions that automatically
add the shared memory base.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 8d0022d..8e9fe48 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -266,6 +266,18 @@ bnx2_reg_wr_ind(struct bnx2 *bp, u32 offset, u32 val)
 }
 
 static void
+bnx2_shmem_wr(struct bnx2 *bp, u32 offset, u32 val)
+{
+	bnx2_reg_wr_ind(bp, bp->shmem_base + offset, val);
+}
+
+static u32
+bnx2_shmem_rd(struct bnx2 *bp, u32 offset)
+{
+	return (bnx2_reg_rd_ind(bp, bp->shmem_base + offset));
+}
+
+static void
 bnx2_ctx_wr(struct bnx2 *bp, u32 cid_addr, u32 offset, u32 val)
 {
 	offset += cid_addr;
@@ -685,7 +697,7 @@ bnx2_report_fw_link(struct bnx2 *bp)
 	else
 		fw_link_status = BNX2_LINK_STATUS_LINK_DOWN;
 
-	REG_WR_IND(bp, bp->shmem_base + BNX2_LINK_STATUS, fw_link_status);
+	bnx2_shmem_wr(bp, BNX2_LINK_STATUS, fw_link_status);
 }
 
 static char *
@@ -1385,7 +1397,7 @@ bnx2_setup_remote_phy(struct bnx2 *bp, u8 port)
 		speed_arg |= BNX2_NETLINK_SET_LINK_PHY_APP_REMOTE |
 			     BNX2_NETLINK_SET_LINK_ETH_AT_WIRESPEED;
 
-	REG_WR_IND(bp, bp->shmem_base + BNX2_DRV_MB_ARG0, speed_arg);
+	bnx2_shmem_wr(bp, BNX2_DRV_MB_ARG0, speed_arg);
 
 	spin_unlock_bh(&bp->phy_lock);
 	bnx2_fw_sync(bp, BNX2_DRV_MSG_CODE_CMD_SET_LINK, 0);
@@ -1530,9 +1542,9 @@ bnx2_set_default_remote_link(struct bnx2 *bp)
 	u32 link;
 
 	if (bp->phy_port == PORT_TP)
-		link = REG_RD_IND(bp, bp->shmem_base + BNX2_RPHY_COPPER_LINK);
+		link = bnx2_shmem_rd(bp, BNX2_RPHY_COPPER_LINK);
 	else
-		link = REG_RD_IND(bp, bp->shmem_base + BNX2_RPHY_SERDES_LINK);
+		link = bnx2_shmem_rd(bp, BNX2_RPHY_SERDES_LINK);
 
 	if (link & BNX2_NETLINK_SET_LINK_ENABLE_AUTONEG) {
 		bp->req_line_speed = 0;
@@ -1584,7 +1596,7 @@ bnx2_set_default_link(struct bnx2 *bp)
 
 		bp->advertising = ETHTOOL_ALL_FIBRE_SPEED | ADVERTISED_Autoneg;
 
-		reg = REG_RD_IND(bp, bp->shmem_base + BNX2_PORT_HW_CFG_CONFIG);
+		reg = bnx2_shmem_rd(bp, BNX2_PORT_HW_CFG_CONFIG);
 		reg &= BNX2_PORT_HW_CFG_CFG_DFLT_LINK_MASK;
 		if (reg == BNX2_PORT_HW_CFG_CFG_DFLT_LINK_1G) {
 			bp->autoneg = 0;
@@ -1616,7 +1628,7 @@ bnx2_remote_phy_event(struct bnx2 *bp)
 	u8 link_up = bp->link_up;
 	u8 old_port;
 
-	msg = REG_RD_IND(bp, bp->shmem_base + BNX2_LINK_STATUS);
+	msg = bnx2_shmem_rd(bp, BNX2_LINK_STATUS);
 
 	if (msg & BNX2_LINK_STATUS_HEART_BEAT_EXPIRED)
 		bnx2_send_heart_beat(bp);
@@ -1693,7 +1705,7 @@ bnx2_set_remote_link(struct bnx2 *bp)
 {
 	u32 evt_code;
 
-	evt_code = REG_RD_IND(bp, bp->shmem_base + BNX2_FW_EVT_CODE_MB);
+	evt_code = bnx2_shmem_rd(bp, BNX2_FW_EVT_CODE_MB);
 	switch (evt_code) {
 		case BNX2_FW_EVT_CODE_LINK_EVENT:
 			bnx2_remote_phy_event(bp);
@@ -1905,14 +1917,13 @@ bnx2_init_5708s_phy(struct bnx2 *bp)
 		bnx2_write_phy(bp, BCM5708S_BLK_ADDR, BCM5708S_BLK_ADDR_DIG);
 	}
 
-	val = REG_RD_IND(bp, bp->shmem_base + BNX2_PORT_HW_CFG_CONFIG) &
+	val = bnx2_shmem_rd(bp, BNX2_PORT_HW_CFG_CONFIG) &
 	      BNX2_PORT_HW_CFG_CFG_TXCTL3_MASK;
 
 	if (val) {
 		u32 is_backplane;
 
-		is_backplane = REG_RD_IND(bp, bp->shmem_base +
-					  BNX2_SHARED_HW_CFG_CONFIG);
+		is_backplane = bnx2_shmem_rd(bp, BNX2_SHARED_HW_CFG_CONFIG);
 		if (is_backplane & BNX2_SHARED_HW_CFG_PHY_BACKPLANE) {
 			bnx2_write_phy(bp, BCM5708S_BLK_ADDR,
 				       BCM5708S_BLK_ADDR_TX_MISC);
@@ -2111,13 +2122,13 @@ bnx2_fw_sync(struct bnx2 *bp, u32 msg_data, int silent)
 	bp->fw_wr_seq++;
 	msg_data |= bp->fw_wr_seq;
 
-	REG_WR_IND(bp, bp->shmem_base + BNX2_DRV_MB, msg_data);
+	bnx2_shmem_wr(bp, BNX2_DRV_MB, msg_data);
 
 	/* wait for an acknowledgement. */
 	for (i = 0; i < (FW_ACK_TIME_OUT_MS / 10); i++) {
 		msleep(10);
 
-		val = REG_RD_IND(bp, bp->shmem_base + BNX2_FW_MB);
+		val = bnx2_shmem_rd(bp, BNX2_FW_MB);
 
 		if ((val & BNX2_FW_MSG_ACK) == (msg_data & BNX2_DRV_MSG_SEQ))
 			break;
@@ -2134,7 +2145,7 @@ bnx2_fw_sync(struct bnx2 *bp, u32 msg_data, int silent)
 		msg_data &= ~BNX2_DRV_MSG_CODE;
 		msg_data |= BNX2_DRV_MSG_CODE_FW_TIMEOUT;
 
-		REG_WR_IND(bp, bp->shmem_base + BNX2_DRV_MB, msg_data);
+		bnx2_shmem_wr(bp, BNX2_DRV_MB, msg_data);
 
 		return -EBUSY;
 	}
@@ -2251,11 +2262,12 @@ bnx2_alloc_bad_rbuf(struct bnx2 *bp)
 	good_mbuf_cnt = 0;
 
 	/* Allocate a bunch of mbufs and save the good ones in an array. */
-	val = REG_RD_IND(bp, BNX2_RBUF_STATUS1);
+	val = bnx2_reg_rd_ind(bp, BNX2_RBUF_STATUS1);
 	while (val & BNX2_RBUF_STATUS1_FREE_COUNT) {
-		REG_WR_IND(bp, BNX2_RBUF_COMMAND, BNX2_RBUF_COMMAND_ALLOC_REQ);
+		bnx2_reg_wr_ind(bp, BNX2_RBUF_COMMAND,
+				BNX2_RBUF_COMMAND_ALLOC_REQ);
 
-		val = REG_RD_IND(bp, BNX2_RBUF_FW_BUF_ALLOC);
+		val = bnx2_reg_rd_ind(bp, BNX2_RBUF_FW_BUF_ALLOC);
 
 		val &= BNX2_RBUF_FW_BUF_ALLOC_VALUE;
 
@@ -2265,7 +2277,7 @@ bnx2_alloc_bad_rbuf(struct bnx2 *bp)
 			good_mbuf_cnt++;
 		}
 
-		val = REG_RD_IND(bp, BNX2_RBUF_STATUS1);
+		val = bnx2_reg_rd_ind(bp, BNX2_RBUF_STATUS1);
 	}
 
 	/* Free the good ones back to the mbuf pool thus discarding
@@ -2276,7 +2288,7 @@ bnx2_alloc_bad_rbuf(struct bnx2 *bp)
 		val = good_mbuf[good_mbuf_cnt];
 		val = (val << 9) | val | 1;
 
-		REG_WR_IND(bp, BNX2_RBUF_FW_BUF_FREE, val);
+		bnx2_reg_wr_ind(bp, BNX2_RBUF_FW_BUF_FREE, val);
 	}
 	kfree(good_mbuf);
 	return 0;
@@ -3151,10 +3163,10 @@ load_cpu_fw(struct bnx2 *bp, struct cpu_reg *cpu_reg, struct fw_info *fw)
 	int rc;
 
 	/* Halt the CPU. */
-	val = REG_RD_IND(bp, cpu_reg->mode);
+	val = bnx2_reg_rd_ind(bp, cpu_reg->mode);
 	val |= cpu_reg->mode_value_halt;
-	REG_WR_IND(bp, cpu_reg->mode, val);
-	REG_WR_IND(bp, cpu_reg->state, cpu_reg->state_value_clear);
+	bnx2_reg_wr_ind(bp, cpu_reg->mode, val);
+	bnx2_reg_wr_ind(bp, cpu_reg->state, cpu_reg->state_value_clear);
 
 	/* Load the Text area. */
 	offset = cpu_reg->spad_base + (fw->text_addr - cpu_reg->mips_view_base);
@@ -3167,7 +3179,7 @@ load_cpu_fw(struct bnx2 *bp, struct cpu_reg *cpu_reg, struct fw_info *fw)
 			return rc;
 
 		for (j = 0; j < (fw->text_len / 4); j++, offset += 4) {
-			REG_WR_IND(bp, offset, le32_to_cpu(fw->text[j]));
+			bnx2_reg_wr_ind(bp, offset, le32_to_cpu(fw->text[j]));
 	        }
 	}
 
@@ -3177,7 +3189,7 @@ load_cpu_fw(struct bnx2 *bp, struct cpu_reg *cpu_reg, struct fw_info *fw)
 		int j;
 
 		for (j = 0; j < (fw->data_len / 4); j++, offset += 4) {
-			REG_WR_IND(bp, offset, fw->data[j]);
+			bnx2_reg_wr_ind(bp, offset, fw->data[j]);
 		}
 	}
 
@@ -3187,7 +3199,7 @@ load_cpu_fw(struct bnx2 *bp, struct cpu_reg *cpu_reg, struct fw_info *fw)
 		int j;
 
 		for (j = 0; j < (fw->sbss_len / 4); j++, offset += 4) {
-			REG_WR_IND(bp, offset, 0);
+			bnx2_reg_wr_ind(bp, offset, 0);
 		}
 	}
 
@@ -3197,7 +3209,7 @@ load_cpu_fw(struct bnx2 *bp, struct cpu_reg *cpu_reg, struct fw_info *fw)
 		int j;
 
 		for (j = 0; j < (fw->bss_len/4); j++, offset += 4) {
-			REG_WR_IND(bp, offset, 0);
+			bnx2_reg_wr_ind(bp, offset, 0);
 		}
 	}
 
@@ -3208,19 +3220,19 @@ load_cpu_fw(struct bnx2 *bp, struct cpu_reg *cpu_reg, struct fw_info *fw)
 		int j;
 
 		for (j = 0; j < (fw->rodata_len / 4); j++, offset += 4) {
-			REG_WR_IND(bp, offset, fw->rodata[j]);
+			bnx2_reg_wr_ind(bp, offset, fw->rodata[j]);
 		}
 	}
 
 	/* Clear the pre-fetch instruction. */
-	REG_WR_IND(bp, cpu_reg->inst, 0);
-	REG_WR_IND(bp, cpu_reg->pc, fw->start_addr);
+	bnx2_reg_wr_ind(bp, cpu_reg->inst, 0);
+	bnx2_reg_wr_ind(bp, cpu_reg->pc, fw->start_addr);
 
 	/* Start the CPU. */
-	val = REG_RD_IND(bp, cpu_reg->mode);
+	val = bnx2_reg_rd_ind(bp, cpu_reg->mode);
 	val &= ~cpu_reg->mode_value_halt;
-	REG_WR_IND(bp, cpu_reg->state, cpu_reg->state_value_clear);
-	REG_WR_IND(bp, cpu_reg->mode, val);
+	bnx2_reg_wr_ind(bp, cpu_reg->state, cpu_reg->state_value_clear);
+	bnx2_reg_wr_ind(bp, cpu_reg->mode, val);
 
 	return 0;
 }
@@ -3833,7 +3845,7 @@ bnx2_init_nvram(struct bnx2 *bp)
 	}
 
 get_flash_size:
-	val = REG_RD_IND(bp, bp->shmem_base + BNX2_SHARED_HW_CFG_CONFIG2);
+	val = bnx2_shmem_rd(bp, BNX2_SHARED_HW_CFG_CONFIG2);
 	val &= BNX2_SHARED_HW_CFG2_NVM_SIZE_MASK;
 	if (val)
 		bp->flash_size = val;
@@ -4142,14 +4154,14 @@ bnx2_init_remote_phy(struct bnx2 *bp)
 	if (!(bp->phy_flags & BNX2_PHY_FLAG_SERDES))
 		return;
 
-	val = REG_RD_IND(bp, bp->shmem_base + BNX2_FW_CAP_MB);
+	val = bnx2_shmem_rd(bp, BNX2_FW_CAP_MB);
 	if ((val & BNX2_FW_CAP_SIGNATURE_MASK) != BNX2_FW_CAP_SIGNATURE)
 		return;
 
 	if (val & BNX2_FW_CAP_REMOTE_PHY_CAPABLE) {
 		bp->phy_flags |= BNX2_PHY_FLAG_REMOTE_PHY_CAP;
 
-		val = REG_RD_IND(bp, bp->shmem_base + BNX2_LINK_STATUS);
+		val = bnx2_shmem_rd(bp, BNX2_LINK_STATUS);
 		if (val & BNX2_LINK_STATUS_SERDES_LINK)
 			bp->phy_port = PORT_FIBRE;
 		else
@@ -4167,8 +4179,7 @@ bnx2_init_remote_phy(struct bnx2 *bp)
 			}
 			sig = BNX2_DRV_ACK_CAP_SIGNATURE |
 			      BNX2_FW_CAP_REMOTE_PHY_CAPABLE;
-			REG_WR_IND(bp, bp->shmem_base + BNX2_DRV_ACK_CAP_MB,
-				   sig);
+			bnx2_shmem_wr(bp, BNX2_DRV_ACK_CAP_MB, sig);
 		}
 	}
 }
@@ -4204,8 +4215,8 @@ bnx2_reset_chip(struct bnx2 *bp, u32 reset_code)
 
 	/* Deposit a driver reset signature so the firmware knows that
 	 * this is a soft reset. */
-	REG_WR_IND(bp, bp->shmem_base + BNX2_DRV_RESET_SIGNATURE,
-		   BNX2_DRV_RESET_SIGNATURE_MAGIC);
+	bnx2_shmem_wr(bp, BNX2_DRV_RESET_SIGNATURE,
+		      BNX2_DRV_RESET_SIGNATURE_MAGIC);
 
 	/* Do a dummy read to force the chip to complete all current transaction
 	 * before we issue a reset. */
@@ -5006,9 +5017,9 @@ bnx2_do_mem_test(struct bnx2 *bp, u32 start, u32 size)
 
 		for (offset = 0; offset < size; offset += 4) {
 
-			REG_WR_IND(bp, start + offset, test_pattern[i]);
+			bnx2_reg_wr_ind(bp, start + offset, test_pattern[i]);
 
-			if (REG_RD_IND(bp, start + offset) !=
+			if (bnx2_reg_rd_ind(bp, start + offset) !=
 				test_pattern[i]) {
 				return -ENODEV;
 			}
@@ -5443,7 +5454,8 @@ bnx2_timer(unsigned long data)
 
 	bnx2_send_heart_beat(bp);
 
-	bp->stats_blk->stat_FwRxDrop = REG_RD_IND(bp, BNX2_FW_RX_DROP_COUNT);
+	bp->stats_blk->stat_FwRxDrop =
+		bnx2_reg_rd_ind(bp, BNX2_FW_RX_DROP_COUNT);
 
 	/* workaround occasional corrupted counters */
 	if (CHIP_NUM(bp) == CHIP_NUM_5708 && bp->stats_ticks)
@@ -7158,20 +7170,20 @@ bnx2_init_board(struct pci_dev *pdev, struct net_device *dev)
 
 	bnx2_init_nvram(bp);
 
-	reg = REG_RD_IND(bp, BNX2_SHM_HDR_SIGNATURE);
+	reg = bnx2_reg_rd_ind(bp, BNX2_SHM_HDR_SIGNATURE);
 
 	if ((reg & BNX2_SHM_HDR_SIGNATURE_SIG_MASK) ==
 	    BNX2_SHM_HDR_SIGNATURE_SIG) {
 		u32 off = PCI_FUNC(pdev->devfn) << 2;
 
-		bp->shmem_base = REG_RD_IND(bp, BNX2_SHM_HDR_ADDR_0 + off);
+		bp->shmem_base = bnx2_reg_rd_ind(bp, BNX2_SHM_HDR_ADDR_0 + off);
 	} else
 		bp->shmem_base = HOST_VIEW_SHMEM_BASE;
 
 	/* Get the permanent MAC address.  First we need to make sure the
 	 * firmware is actually running.
 	 */
-	reg = REG_RD_IND(bp, bp->shmem_base + BNX2_DEV_INFO_SIGNATURE);
+	reg = bnx2_shmem_rd(bp, BNX2_DEV_INFO_SIGNATURE);
 
 	if ((reg & BNX2_DEV_INFO_SIGNATURE_MAGIC_MASK) !=
 	    BNX2_DEV_INFO_SIGNATURE_MAGIC) {
@@ -7180,7 +7192,7 @@ bnx2_init_board(struct pci_dev *pdev, struct net_device *dev)
 		goto err_out_unmap;
 	}
 
-	reg = REG_RD_IND(bp, bp->shmem_base + BNX2_DEV_INFO_BC_REV);
+	reg = bnx2_shmem_rd(bp, BNX2_DEV_INFO_BC_REV);
 	for (i = 0, j = 0; i < 3; i++) {
 		u8 num, k, skip0;
 
@@ -7194,7 +7206,7 @@ bnx2_init_board(struct pci_dev *pdev, struct net_device *dev)
 		if (i != 2)
 			bp->fw_version[j++] = '.';
 	}
-	reg = REG_RD_IND(bp, bp->shmem_base + BNX2_PORT_FEATURE);
+	reg = bnx2_shmem_rd(bp, BNX2_PORT_FEATURE);
 	if (reg & BNX2_PORT_FEATURE_WOL_ENABLED)
 		bp->wol = 1;
 
@@ -7202,34 +7214,33 @@ bnx2_init_board(struct pci_dev *pdev, struct net_device *dev)
 		bp->flags |= BNX2_FLAG_ASF_ENABLE;
 
 		for (i = 0; i < 30; i++) {
-			reg = REG_RD_IND(bp, bp->shmem_base +
-					     BNX2_BC_STATE_CONDITION);
+			reg = bnx2_shmem_rd(bp, BNX2_BC_STATE_CONDITION);
 			if (reg & BNX2_CONDITION_MFW_RUN_MASK)
 				break;
 			msleep(10);
 		}
 	}
-	reg = REG_RD_IND(bp, bp->shmem_base + BNX2_BC_STATE_CONDITION);
+	reg = bnx2_shmem_rd(bp, BNX2_BC_STATE_CONDITION);
 	reg &= BNX2_CONDITION_MFW_RUN_MASK;
 	if (reg != BNX2_CONDITION_MFW_RUN_UNKNOWN &&
 	    reg != BNX2_CONDITION_MFW_RUN_NONE) {
 		int i;
-		u32 addr = REG_RD_IND(bp, bp->shmem_base + BNX2_MFW_VER_PTR);
+		u32 addr = bnx2_shmem_rd(bp, BNX2_MFW_VER_PTR);
 
 		bp->fw_version[j++] = ' ';
 		for (i = 0; i < 3; i++) {
-			reg = REG_RD_IND(bp, addr + i * 4);
+			reg = bnx2_reg_rd_ind(bp, addr + i * 4);
 			reg = swab32(reg);
 			memcpy(&bp->fw_version[j], &reg, 4);
 			j += 4;
 		}
 	}
 
-	reg = REG_RD_IND(bp, bp->shmem_base + BNX2_PORT_HW_CFG_MAC_UPPER);
+	reg = bnx2_shmem_rd(bp, BNX2_PORT_HW_CFG_MAC_UPPER);
 	bp->mac_addr[0] = (u8) (reg >> 8);
 	bp->mac_addr[1] = (u8) reg;
 
-	reg = REG_RD_IND(bp, bp->shmem_base + BNX2_PORT_HW_CFG_MAC_LOWER);
+	reg = bnx2_shmem_rd(bp, BNX2_PORT_HW_CFG_MAC_LOWER);
 	bp->mac_addr[2] = (u8) (reg >> 24);
 	bp->mac_addr[3] = (u8) (reg >> 16);
 	bp->mac_addr[4] = (u8) (reg >> 8);
@@ -7268,8 +7279,7 @@ bnx2_init_board(struct pci_dev *pdev, struct net_device *dev)
 	bp->phy_port = PORT_TP;
 	if (bp->phy_flags & BNX2_PHY_FLAG_SERDES) {
 		bp->phy_port = PORT_FIBRE;
-		reg = REG_RD_IND(bp, bp->shmem_base +
-				     BNX2_SHARED_HW_CFG_CONFIG);
+		reg = bnx2_shmem_rd(bp, BNX2_SHARED_HW_CFG_CONFIG);
 		if (!(reg & BNX2_SHARED_HW_CFG_GIG_LINK_ON_VAUX)) {
 			bp->flags |= BNX2_FLAG_NO_WOL;
 			bp->wol = 0;
diff --git a/drivers/net/bnx2.h b/drivers/net/bnx2.h
index 7a1eff4..fb3c019 100644
--- a/drivers/net/bnx2.h
+++ b/drivers/net/bnx2.h
@@ -6805,9 +6805,6 @@ struct bnx2 {
 	int			irq_nvecs;
 };
 
-static u32 bnx2_reg_rd_ind(struct bnx2 *bp, u32 offset);
-static void bnx2_reg_wr_ind(struct bnx2 *bp, u32 offset, u32 val);
-
 #define REG_RD(bp, offset)					\
 	readl(bp->regview + offset)
 
@@ -6817,12 +6814,6 @@ static void bnx2_reg_wr_ind(struct bnx2 *bp, u32 offset, u32 val);
 #define REG_WR16(bp, offset, val)				\
 	writew(val, bp->regview + offset)
 
-#define REG_RD_IND(bp, offset)					\
-	bnx2_reg_rd_ind(bp, offset)
-
-#define REG_WR_IND(bp, offset, val)				\
-	bnx2_reg_wr_ind(bp, offset, val)
-
 /* Indirect context access.  Unlike the MBQ_WR, these macros will not
  * trigger a chip event. */
 static void bnx2_ctx_wr(struct bnx2 *bp, u32 cid_addr, u32 offset, u32 val);


