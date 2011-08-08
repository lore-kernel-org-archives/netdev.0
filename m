From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 2/2] bnx2x: Coalesce pr_cont uses and fix DP typos
Date: Mon,  8 Aug 2011 08:53:05 -0700
Message-ID: <98d09e1b3d7a73bf5f2744f0ca238321573e4579.1312818707.git.joe@perches.com>
References: <cover.1312818707.git.joe@perches.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Eilon Greenstein <eilong@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1312818707.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Uses of pr_cont should be avoided where reasonably possible
because they can be interleaved by other threads and processes.

Coalesce pr_cont uses.

Fix typos, duplicated words and spacing in DP uses caused
by split multi-line formats.  Coalesce some of these
split formats.  Add missing terminating newlines to DP uses.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/bnx2x/bnx2x_cmn.c  |   42 ++++++-----
 drivers/net/bnx2x/bnx2x_cmn.h  |    4 +-
 drivers/net/bnx2x/bnx2x_dcb.c  |    2 +-
 drivers/net/bnx2x/bnx2x_link.c |  155 +++++++++++++++++++++-------------------
 drivers/net/bnx2x/bnx2x_main.c |   33 ++++-----
 drivers/net/bnx2x/bnx2x_sp.c   |   23 +++---
 6 files changed, 135 insertions(+), 124 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_cmn.c b/drivers/net/bnx2x/bnx2x_cmn.c
index 5b0dba6..456baf6 100644
--- a/drivers/net/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/bnx2x/bnx2x_cmn.c
@@ -953,15 +953,16 @@ void __bnx2x_link_report(struct bnx2x *bp)
 		netdev_err(bp->dev, "NIC Link is Down\n");
 		return;
 	} else {
+		const char *duplex;
+		const char *flow;
+
 		netif_carrier_on(bp->dev);
-		netdev_info(bp->dev, "NIC Link is Up, ");
-		pr_cont("%d Mbps ", cur_data.line_speed);
 
 		if (test_and_clear_bit(BNX2X_LINK_REPORT_FD,
 				       &cur_data.link_report_flags))
-			pr_cont("full duplex");
+			duplex = "full";
 		else
-			pr_cont("half duplex");
+			duplex = "half";
 
 		/* Handle the FC at the end so that only these flags would be
 		 * possibly set. This way we may easily check if there is no FC
@@ -970,16 +971,19 @@ void __bnx2x_link_report(struct bnx2x *bp)
 		if (cur_data.link_report_flags) {
 			if (test_bit(BNX2X_LINK_REPORT_RX_FC_ON,
 				     &cur_data.link_report_flags)) {
-				pr_cont(", receive ");
 				if (test_bit(BNX2X_LINK_REPORT_TX_FC_ON,
 				     &cur_data.link_report_flags))
-					pr_cont("& transmit ");
+					flow = "ON - receive & transmit";
+				else
+					flow = "ON - receive";
 			} else {
-				pr_cont(", transmit ");
+				flow = "ON - transmit";
 			}
-			pr_cont("flow control ON");
+		} else {
+			flow = "none";
 		}
-		pr_cont("\n");
+		netdev_info(bp->dev, "NIC Link is Up, %d Mbps %s duplex, Flow control: %s\n",
+			    cur_data.line_speed, duplex, flow);
 	}
 }
 
@@ -2578,7 +2582,7 @@ netdev_tx_t bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 #endif
 
 	/* enable this debug print to view the transmission queue being used
-	DP(BNX2X_MSG_FP, "indices: txq %d, fp %d, txdata %d",
+	DP(BNX2X_MSG_FP, "indices: txq %d, fp %d, txdata %d\n",
 	   txq_index, fp_index, txdata_index); */
 
 	/* locate the fastpath and the txdata */
@@ -2587,7 +2591,7 @@ netdev_tx_t bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	/* enable this debug print to view the tranmission details
 	DP(BNX2X_MSG_FP,"transmitting packet cid %d fp index %d txdata_index %d"
-			" tx_data ptr %p fp pointer %p",
+			" tx_data ptr %p fp pointer %p\n",
 	   txdata->cid, fp_index, txdata_index, txdata, fp); */
 
 	if (unlikely(bnx2x_tx_avail(bp, txdata) <
@@ -2904,14 +2908,14 @@ int bnx2x_setup_tc(struct net_device *dev, u8 num_tc)
 	/* requested to support too many traffic classes */
 	if (num_tc > bp->max_cos) {
 		DP(NETIF_MSG_TX_ERR, "support for too many traffic classes"
-				     " requested: %d. max supported is %d",
+				     " requested: %d. max supported is %d\n",
 				     num_tc, bp->max_cos);
 		return -EINVAL;
 	}
 
 	/* declare amount of supported traffic classes */
 	if (netdev_set_num_tc(dev, num_tc)) {
-		DP(NETIF_MSG_TX_ERR, "failed to declare %d traffic classes",
+		DP(NETIF_MSG_TX_ERR, "failed to declare %d traffic classes\n",
 				     num_tc);
 		return -EINVAL;
 	}
@@ -2919,7 +2923,7 @@ int bnx2x_setup_tc(struct net_device *dev, u8 num_tc)
 	/* configure priority to traffic class mapping */
 	for (prio = 0; prio < BNX2X_MAX_PRIORITY; prio++) {
 		netdev_set_prio_tc_map(dev, prio, bp->prio_to_cos[prio]);
-		DP(BNX2X_MSG_SP, "mapping priority %d to tc %d",
+		DP(BNX2X_MSG_SP, "mapping priority %d to tc %d\n",
 		   prio, bp->prio_to_cos[prio]);
 	}
 
@@ -2928,10 +2932,10 @@ int bnx2x_setup_tc(struct net_device *dev, u8 num_tc)
 	   This can be used for ets or pfc, and save the effort of setting
 	   up a multio class queue disc or negotiating DCBX with a switch
 	netdev_set_prio_tc_map(dev, 0, 0);
-	DP(BNX2X_MSG_SP, "mapping priority %d to tc %d", 0, 0);
+	DP(BNX2X_MSG_SP, "mapping priority %d to tc %d\n", 0, 0);
 	for (prio = 1; prio < 16; prio++) {
 		netdev_set_prio_tc_map(dev, prio, 1);
-		DP(BNX2X_MSG_SP, "mapping priority %d to tc %d", prio, 1);
+		DP(BNX2X_MSG_SP, "mapping priority %d to tc %d\n", prio, 1);
 	} */
 
 	/* configure traffic class to transmission queue mapping */
@@ -2939,7 +2943,7 @@ int bnx2x_setup_tc(struct net_device *dev, u8 num_tc)
 		count = BNX2X_NUM_ETH_QUEUES(bp);
 		offset = cos * MAX_TXQS_PER_COS;
 		netdev_set_tc_queue(dev, cos, count, offset);
-		DP(BNX2X_MSG_SP, "mapping tc %d to offset %d count %d",
+		DP(BNX2X_MSG_SP, "mapping tc %d to offset %d count %d\n",
 		   cos, offset, count);
 	}
 
@@ -3027,7 +3031,7 @@ static void bnx2x_free_fp_mem_at(struct bnx2x *bp, int fp_index)
 			struct bnx2x_fp_txdata *txdata = &fp->txdata[cos];
 
 			DP(BNX2X_MSG_SP,
-			   "freeing tx memory of fp %d cos %d cid %d",
+			   "freeing tx memory of fp %d cos %d cid %d\n",
 			   fp_index, cos, txdata->cid);
 
 			BNX2X_FREE(txdata->tx_buf_ring);
@@ -3109,7 +3113,7 @@ static int bnx2x_alloc_fp_mem_at(struct bnx2x *bp, int index)
 			struct bnx2x_fp_txdata *txdata = &fp->txdata[cos];
 
 			DP(BNX2X_MSG_SP, "allocating tx memory of "
-					 "fp %d cos %d",
+					 "fp %d cos %d\n",
 			   index, cos);
 
 			BNX2X_ALLOC(txdata->tx_buf_ring,
diff --git a/drivers/net/bnx2x/bnx2x_cmn.h b/drivers/net/bnx2x/bnx2x_cmn.h
index 223bfee..501a24b 100644
--- a/drivers/net/bnx2x/bnx2x_cmn.h
+++ b/drivers/net/bnx2x/bnx2x_cmn.h
@@ -1289,7 +1289,7 @@ static inline void bnx2x_init_txdata(struct bnx2x *bp,
 	txdata->txq_index = txq_index;
 	txdata->tx_cons_sb = tx_cons_sb;
 
-	DP(BNX2X_MSG_SP, "created tx data cid %d, txq %d",
+	DP(BNX2X_MSG_SP, "created tx data cid %d, txq %d\n",
 	   txdata->cid, txdata->txq_index);
 }
 
@@ -1333,7 +1333,7 @@ static inline void bnx2x_init_fcoe_fp(struct bnx2x *bp)
 	bnx2x_init_txdata(bp, &bnx2x_fcoe(bp, txdata[0]),
 			  fp->cid, FCOE_TXQ_IDX(bp), BNX2X_FCOE_L2_TX_INDEX);
 
-	DP(BNX2X_MSG_SP, "created fcoe tx data (fp index %d)", fp->index);
+	DP(BNX2X_MSG_SP, "created fcoe tx data (fp index %d)\n", fp->index);
 
 	/* qZone id equals to FW (per path) client id */
 	bnx2x_fcoe(bp, cl_qzone_id) = bnx2x_fp_qzone_id(fp);
diff --git a/drivers/net/bnx2x/bnx2x_dcb.c b/drivers/net/bnx2x/bnx2x_dcb.c
index a4ea35f..38b5ca5 100644
--- a/drivers/net/bnx2x/bnx2x_dcb.c
+++ b/drivers/net/bnx2x/bnx2x_dcb.c
@@ -350,7 +350,7 @@ static void bnx2x_dcbx_map_nw(struct bnx2x *bp)
 		if (cos_params[i].pri_bitmask & nw_prio) {
 			/* extend the bitmask with unmapped */
 			DP(NETIF_MSG_LINK,
-			   "cos %d extended with 0x%08x", i, unmapped);
+			   "cos %d extended with 0x%08x\n", i, unmapped);
 			cos_params[i].pri_bitmask |= unmapped;
 			break;
 		}
diff --git a/drivers/net/bnx2x/bnx2x_link.c b/drivers/net/bnx2x/bnx2x_link.c
index bcd8f00..5874f68 100644
--- a/drivers/net/bnx2x/bnx2x_link.c
+++ b/drivers/net/bnx2x/bnx2x_link.c
@@ -694,8 +694,8 @@ static int bnx2x_ets_e3b0_disabled(const struct link_params *params,
 	struct bnx2x *bp = params->bp;
 
 	if (!CHIP_IS_E3B0(bp)) {
-		DP(NETIF_MSG_LINK, "bnx2x_ets_e3b0_disabled the chip isn't E3B0"
-				   "\n");
+		DP(NETIF_MSG_LINK,
+		   "bnx2x_ets_e3b0_disabled the chip isn't E3B0\n");
 		return -EINVAL;
 	}
 
@@ -854,8 +854,8 @@ static int bnx2x_ets_e3b0_get_total_bw(
 		if (bnx2x_cos_state_bw == ets_params->cos[cos_idx].state) {
 
 			if (0 == ets_params->cos[cos_idx].params.bw_params.bw) {
-				DP(NETIF_MSG_LINK, "bnx2x_ets_E3B0_config BW"
-						   "was set to 0\n");
+				DP(NETIF_MSG_LINK,
+				   "bnx2x_ets_E3B0_config BW was set to 0\n");
 			return -EINVAL;
 		}
 		*total_bw +=
@@ -866,12 +866,12 @@ static int bnx2x_ets_e3b0_get_total_bw(
 	/*Check taotl BW is valid */
 	if ((100 != *total_bw) || (0 == *total_bw)) {
 		if (0 == *total_bw) {
-			DP(NETIF_MSG_LINK, "bnx2x_ets_E3B0_config toatl BW"
-					   "shouldn't be 0\n");
+			DP(NETIF_MSG_LINK,
+			   "bnx2x_ets_E3B0_config toatl BW shouldn't be 0\n");
 			return -EINVAL;
 		}
-		DP(NETIF_MSG_LINK, "bnx2x_ets_E3B0_config toatl BW should be"
-				   "100\n");
+		DP(NETIF_MSG_LINK,
+		   "bnx2x_ets_E3B0_config toatl BW should be 100\n");
 		/**
 		*   We can handle a case whre the BW isn't 100 this can happen
 		*   if the TC are joined.
@@ -908,13 +908,13 @@ static int bnx2x_ets_e3b0_sp_pri_to_cos_set(const struct link_params *params,
 
 	if (DCBX_INVALID_COS != sp_pri_to_cos[pri]) {
 		DP(NETIF_MSG_LINK, "bnx2x_ets_e3b0_sp_pri_to_cos_set invalid "
-				   "parameter There can't be two COS's with"
+				   "parameter There can't be two COS's with "
 				   "the same strict pri\n");
 		return -EINVAL;
 	}
 
 	if (pri > max_num_of_cos) {
-		DP(NETIF_MSG_LINK, "bnx2x_ets_e3b0_sp_pri_to_cos_set invalid"
+		DP(NETIF_MSG_LINK, "bnx2x_ets_e3b0_sp_pri_to_cos_set invalid "
 			       "parameter Illegal strict priority\n");
 	    return -EINVAL;
 	}
@@ -1090,8 +1090,8 @@ int bnx2x_ets_e3b0_config(const struct link_params *params,
 	u8 cos_entry = 0;
 
 	if (!CHIP_IS_E3B0(bp)) {
-		DP(NETIF_MSG_LINK, "bnx2x_ets_e3b0_disabled the chip isn't E3B0"
-				   "\n");
+		DP(NETIF_MSG_LINK,
+		   "bnx2x_ets_e3b0_disabled the chip isn't E3B0\n");
 		return -EINVAL;
 	}
 
@@ -1108,8 +1108,8 @@ int bnx2x_ets_e3b0_config(const struct link_params *params,
 	bnx2x_status = bnx2x_ets_e3b0_get_total_bw(params, ets_params,
 						   &total_bw);
 	if (0 != bnx2x_status) {
-		DP(NETIF_MSG_LINK, "bnx2x_ets_E3B0_config get_total_bw failed "
-				   "\n");
+		DP(NETIF_MSG_LINK,
+		   "bnx2x_ets_E3B0_config get_total_bw failed\n");
 		return -EINVAL;
 	}
 
@@ -1144,13 +1144,13 @@ int bnx2x_ets_e3b0_config(const struct link_params *params,
 				cos_entry);
 
 		} else {
-			DP(NETIF_MSG_LINK, "bnx2x_ets_e3b0_config cos state not"
-					   " valid\n");
+			DP(NETIF_MSG_LINK,
+			   "bnx2x_ets_e3b0_config cos state not valid\n");
 			return -EINVAL;
 		}
 		if (0 != bnx2x_status) {
-			DP(NETIF_MSG_LINK, "bnx2x_ets_e3b0_config set cos bw "
-					   "failed\n");
+			DP(NETIF_MSG_LINK,
+			   "bnx2x_ets_e3b0_config set cos bw failed\n");
 			return bnx2x_status;
 		}
 	}
@@ -1160,8 +1160,8 @@ int bnx2x_ets_e3b0_config(const struct link_params *params,
 							 sp_pri_to_cos);
 
 	if (0 != bnx2x_status) {
-		DP(NETIF_MSG_LINK, "bnx2x_ets_E3B0_config set_pri_cli_reg "
-				   "failed\n");
+		DP(NETIF_MSG_LINK,
+		   "bnx2x_ets_E3B0_config set_pri_cli_reg failed\n");
 		return bnx2x_status;
 	}
 
@@ -1612,8 +1612,8 @@ static void bnx2x_xmac_init(struct bnx2x *bp, u32 max_speed)
 
 	if (is_port4mode && (REG_RD(bp, MISC_REG_RESET_REG_2) &
 	     MISC_REGISTERS_RESET_REG_2_XMAC)) {
-		DP(NETIF_MSG_LINK, "XMAC already out of reset"
-				   " in 4-port mode\n");
+		DP(NETIF_MSG_LINK,
+		   "XMAC already out of reset in 4-port mode\n");
 		return;
 	}
 
@@ -1636,13 +1636,13 @@ static void bnx2x_xmac_init(struct bnx2x *bp, u32 max_speed)
 		/*  Set the number of ports on the system side to 1 */
 		REG_WR(bp, MISC_REG_XMAC_CORE_PORT_MODE, 0);
 		if (max_speed == SPEED_10000) {
-			DP(NETIF_MSG_LINK, "Init XMAC to 10G x 1"
-					   " port per path\n");
+			DP(NETIF_MSG_LINK,
+			   "Init XMAC to 10G x 1 port per path\n");
 			/* Set the number of ports on the Warp Core to 10G */
 			REG_WR(bp, MISC_REG_XMAC_PHY_PORT_MODE, 3);
 		} else {
-			DP(NETIF_MSG_LINK, "Init XMAC to 20G x 2 ports"
-					   " per path\n");
+			DP(NETIF_MSG_LINK,
+			   "Init XMAC to 20G x 2 ports per path\n");
 			/* Set the number of ports on the Warp Core to 20G */
 			REG_WR(bp, MISC_REG_XMAC_PHY_PORT_MODE, 1);
 		}
@@ -3945,8 +3945,8 @@ static void bnx2x_warpcore_set_sgmii_speed(struct bnx2x_phy *phy,
 			val16 |= 0x0040;
 			break;
 		default:
-			DP(NETIF_MSG_LINK, "Speed not supported: 0x%x"
-					   "\n", phy->req_line_speed);
+			DP(NETIF_MSG_LINK,
+			   "Speed not supported: 0x%x\n", phy->req_line_speed);
 			return;
 		}
 
@@ -4078,9 +4078,9 @@ static int bnx2x_get_mod_abs_int_cfg(struct bnx2x *bp,
 		 */
 		if ((cfg_pin < PIN_CFG_GPIO0_P0) ||
 		    (cfg_pin > PIN_CFG_GPIO3_P1)) {
-			DP(NETIF_MSG_LINK, "ERROR: Invalid cfg pin %x for "
-					   "module detect indication\n",
-				       cfg_pin);
+			DP(NETIF_MSG_LINK,
+			   "ERROR: Invalid cfg pin %x for module detect indication\n",
+			   cfg_pin);
 			return -EINVAL;
 		}
 
@@ -4208,8 +4208,9 @@ static void bnx2x_warpcore_config_init(struct bnx2x_phy *phy,
 			break;
 
 		default:
-			DP(NETIF_MSG_LINK, "Unsupported Serdes Net Interface "
-					   "0x%x\n", serdes_net_if);
+			DP(NETIF_MSG_LINK,
+			   "Unsupported Serdes Net Interface 0x%x\n",
+			   serdes_net_if);
 			return;
 		}
 	}
@@ -6098,8 +6099,8 @@ static int bnx2x_link_initialize(struct link_params *params,
 			if (phy_index == EXT_PHY2 &&
 			    (bnx2x_phy_selection(params) ==
 			     PORT_HW_CFG_PHY_SELECTION_FIRST_PHY)) {
-				DP(NETIF_MSG_LINK, "Not initializing"
-						" second phy\n");
+				DP(NETIF_MSG_LINK,
+				   "Not initializing second phy\n");
 				continue;
 			}
 			params->phy[phy_index].config_init(
@@ -6416,8 +6417,8 @@ int bnx2x_link_update(struct link_params *params, struct link_vars *vars)
 		 */
 		if (active_external_phy == EXT_PHY1) {
 			if (params->phy[EXT_PHY2].phy_specific_func) {
-				DP(NETIF_MSG_LINK, "Disabling TX on"
-						   " EXT_PHY2\n");
+				DP(NETIF_MSG_LINK,
+				   "Disabling TX on EXT_PHY2\n");
 				params->phy[EXT_PHY2].phy_specific_func(
 					&params->phy[EXT_PHY2],
 					params, DISABLE_TX);
@@ -7310,8 +7311,8 @@ static int bnx2x_8726_read_sfp_module_eeprom(struct bnx2x_phy *phy,
 	u16 val = 0;
 	u16 i;
 	if (byte_cnt > 16) {
-		DP(NETIF_MSG_LINK, "Reading from eeprom is"
-			    " is limited to 0xf\n");
+		DP(NETIF_MSG_LINK,
+		   "Reading from eeprom is limited to 0xf\n");
 		return -EINVAL;
 	}
 	/* Set the read command byte count */
@@ -7382,8 +7383,8 @@ static int bnx2x_warpcore_read_sfp_module_eeprom(struct bnx2x_phy *phy,
 					" addr %d, cnt %d\n",
 					addr, byte_cnt);*/
 	if (byte_cnt > 16) {
-		DP(NETIF_MSG_LINK, "Reading from eeprom is"
-			    " is limited to 16 bytes\n");
+		DP(NETIF_MSG_LINK,
+		   "Reading from eeprom is limited to 16 bytes\n");
 		return -EINVAL;
 	}
 
@@ -7412,8 +7413,8 @@ static int bnx2x_8727_read_sfp_module_eeprom(struct bnx2x_phy *phy,
 	u16 val, i;
 
 	if (byte_cnt > 16) {
-		DP(NETIF_MSG_LINK, "Reading from eeprom is"
-			    " is limited to 0xf\n");
+		DP(NETIF_MSG_LINK,
+		   "Reading from eeprom is limited to 0xf\n");
 		return -EINVAL;
 	}
 
@@ -7560,13 +7561,14 @@ static int bnx2x_get_edc_mode(struct bnx2x_phy *phy,
 			check_limiting_mode = 1;
 		} else if (copper_module_type &
 			SFP_EEPROM_FC_TX_TECH_BITMASK_COPPER_PASSIVE) {
-				DP(NETIF_MSG_LINK, "Passive Copper"
-					    " cable detected\n");
+				DP(NETIF_MSG_LINK,
+				   "Passive Copper cable detected\n");
 				*edc_mode =
 				      EDC_MODE_PASSIVE_DAC;
 		} else {
-			DP(NETIF_MSG_LINK, "Unknown copper-cable-"
-				     "type 0x%x !!!\n", copper_module_type);
+			DP(NETIF_MSG_LINK,
+			   "Unknown copper-cable-type 0x%x !!!\n",
+			   copper_module_type);
 			return -EINVAL;
 		}
 		break;
@@ -7604,8 +7606,8 @@ static int bnx2x_get_edc_mode(struct bnx2x_phy *phy,
 						 SFP_EEPROM_OPTIONS_ADDR,
 						 SFP_EEPROM_OPTIONS_SIZE,
 						 options) != 0) {
-			DP(NETIF_MSG_LINK, "Failed to read Option"
-				" field from module EEPROM\n");
+			DP(NETIF_MSG_LINK,
+			   "Failed to read Option field from module EEPROM\n");
 			return -EINVAL;
 		}
 		if ((options[0] & SFP_EEPROM_OPTIONS_LINEAR_RX_OUT_MASK))
@@ -7646,15 +7648,15 @@ static int bnx2x_verify_sfp_module(struct bnx2x_phy *phy,
 		   FEATURE_CONFIG_BC_SUPPORTS_OPT_MDL_VRFY) {
 		/* Use first phy request only in case of non-dual media*/
 		if (DUAL_MEDIA(params)) {
-			DP(NETIF_MSG_LINK, "FW does not support OPT MDL "
-			   "verification\n");
+			DP(NETIF_MSG_LINK,
+			   "FW does not support OPT MDL verification\n");
 			return -EINVAL;
 		}
 		cmd = DRV_MSG_CODE_VRFY_FIRST_PHY_OPT_MDL;
 	} else {
 		/* No support in OPT MDL detection */
-		DP(NETIF_MSG_LINK, "FW does not support OPT MDL "
-			  "verification\n");
+		DP(NETIF_MSG_LINK,
+		   "FW does not support OPT MDL verification\n");
 		return -EINVAL;
 	}
 
@@ -7705,8 +7707,9 @@ static int bnx2x_wait_for_sfp_module_initialized(struct bnx2x_phy *phy,
 	for (timeout = 0; timeout < 60; timeout++) {
 		if (bnx2x_read_sfp_module_eeprom(phy, params, 1, 1, &val)
 		    == 0) {
-			DP(NETIF_MSG_LINK, "SFP+ module initialization "
-				     "took %d ms\n", timeout * 5);
+			DP(NETIF_MSG_LINK,
+			   "SFP+ module initialization took %d ms\n",
+			   timeout * 5);
 			return 0;
 		}
 		msleep(5);
@@ -8478,8 +8481,8 @@ static int bnx2x_8726_config_init(struct bnx2x_phy *phy,
 	/* Set TX PreEmphasis if needed */
 	if ((params->feature_config_flags &
 	     FEATURE_CONFIG_OVERRIDE_PREEMPHASIS_ENABLED)) {
-		DP(NETIF_MSG_LINK, "Setting TX_CTRL1 0x%x,"
-			 "TX_CTRL2 0x%x\n",
+		DP(NETIF_MSG_LINK,
+		   "Setting TX_CTRL1 0x%x, TX_CTRL2 0x%x\n",
 			 phy->tx_preemphasis[0],
 			 phy->tx_preemphasis[1]);
 		bnx2x_cl45_write(bp, phy,
@@ -8763,8 +8766,8 @@ static void bnx2x_8727_handle_mod_abs(struct bnx2x_phy *phy,
 	if (mod_abs & (1<<8)) {
 
 		/* Module is absent */
-		DP(NETIF_MSG_LINK, "MOD_ABS indication "
-			    "show module is absent\n");
+		DP(NETIF_MSG_LINK,
+		   "MOD_ABS indication show module is absent\n");
 		phy->media_type = ETH_PHY_NOT_PRESENT;
 		/*
 		 * 1. Set mod_abs to detect next module
@@ -8791,8 +8794,8 @@ static void bnx2x_8727_handle_mod_abs(struct bnx2x_phy *phy,
 
 	} else {
 		/* Module is present */
-		DP(NETIF_MSG_LINK, "MOD_ABS indication "
-			    "show module is present\n");
+		DP(NETIF_MSG_LINK,
+		   "MOD_ABS indication show module is present\n");
 		/*
 		 * First disable transmitter, and if the module is ok, the
 		 * module_detection will enable it
@@ -8883,8 +8886,9 @@ static u8 bnx2x_8727_read_status(struct bnx2x_phy *phy,
 		if ((val1 & (1<<8)) == 0) {
 			if (!CHIP_IS_E1x(bp))
 				oc_port = BP_PATH(bp) + (params->port << 1);
-			DP(NETIF_MSG_LINK, "8727 Power fault has been detected"
-				       " on port %d\n", oc_port);
+			DP(NETIF_MSG_LINK,
+			   "8727 Power fault has been detected on port %d\n",
+			   oc_port);
 			netdev_err(bp->dev, "Error:  Power fault on Port %d has"
 					    " been detected and the power to "
 					    "that SFP+ module has been removed"
@@ -9660,8 +9664,8 @@ static u8 bnx2x_848xx_read_status(struct bnx2x_phy *phy,
 				MDIO_AN_REG_8481_EXPANSION_REG_RD_RW,
 				&legacy_status);
 
-		DP(NETIF_MSG_LINK, "Legacy speed status"
-			     " = 0x%x\n", legacy_status);
+		DP(NETIF_MSG_LINK, "Legacy speed status = 0x%x\n",
+		   legacy_status);
 		link_up = ((legacy_status & (1<<11)) == (1<<11));
 		if (link_up) {
 			legacy_speed = (legacy_status & (3<<9));
@@ -9679,9 +9683,10 @@ static u8 bnx2x_848xx_read_status(struct bnx2x_phy *phy,
 			else
 				vars->duplex = DUPLEX_HALF;
 
-			DP(NETIF_MSG_LINK, "Link is up in %dMbps,"
-				   " is_duplex_full= %d\n", vars->line_speed,
-				   (vars->duplex == DUPLEX_FULL));
+			DP(NETIF_MSG_LINK,
+			   "Link is up in %dMbps, is_duplex_full= %d\n",
+			   vars->line_speed,
+			   (vars->duplex == DUPLEX_FULL));
 			/* Check legacy speed AN resolution */
 			bnx2x_cl45_read(bp, phy,
 					MDIO_AN_DEVAD,
@@ -10251,9 +10256,10 @@ static u8 bnx2x_54618se_read_status(struct bnx2x_phy *phy,
 		} else /* Should not happen */
 			vars->line_speed = 0;
 
-		DP(NETIF_MSG_LINK, "Link is up in %dMbps,"
-			   " is_duplex_full= %d\n", vars->line_speed,
-			   (vars->duplex == DUPLEX_FULL));
+		DP(NETIF_MSG_LINK,
+		   "Link is up in %dMbps, is_duplex_full= %d\n",
+		   vars->line_speed,
+		   (vars->duplex == DUPLEX_FULL));
 
 		/* Check legacy speed AN resolution */
 		bnx2x_cl22_read(bp, phy,
@@ -11295,8 +11301,9 @@ static void bnx2x_phy_def_cfg(struct link_params *params,
 						      dev_info.
 			port_hw_config[params->port].speed_capability_mask));
 	}
-	DP(NETIF_MSG_LINK, "Default config phy idx %x cfg 0x%x speed_cap_mask"
-		       " 0x%x\n", phy_index, link_config, phy->speed_cap_mask);
+	DP(NETIF_MSG_LINK,
+	   "Default config phy idx %x cfg 0x%x speed_cap_mask 0x%x\n",
+	   phy_index, link_config, phy->speed_cap_mask);
 
 	phy->req_duplex = DUPLEX_FULL;
 	switch (link_config  & PORT_FEATURE_LINK_SPEED_MASK) {
@@ -12254,7 +12261,7 @@ void bnx2x_period_func(struct link_params *params, struct link_vars *vars)
 {
 	struct bnx2x *bp = params->bp;
 	if (!params) {
-		DP(NETIF_MSG_LINK, "Ininitliazed params !\n");
+		DP(NETIF_MSG_LINK, "Uninitialized params !\n");
 		return;
 	}
 	/* DP(NETIF_MSG_LINK, "Periodic called vars->phy_flags 0x%x speed 0x%x
diff --git a/drivers/net/bnx2x/bnx2x_main.c b/drivers/net/bnx2x/bnx2x_main.c
index 173b258..e899e87 100644
--- a/drivers/net/bnx2x/bnx2x_main.c
+++ b/drivers/net/bnx2x/bnx2x_main.c
@@ -4388,7 +4388,7 @@ static inline void bnx2x_handle_rx_mode_eqe(struct bnx2x *bp)
 static inline struct bnx2x_queue_sp_obj *bnx2x_cid_to_q_obj(
 	struct bnx2x *bp, u32 cid)
 {
-	DP(BNX2X_MSG_SP, "retrieving fp from cid %d", cid);
+	DP(BNX2X_MSG_SP, "retrieving fp from cid %d\n", cid);
 #ifdef BCM_CNIC
 	if (cid == BNX2X_FCOE_ETH_CID)
 		return &bnx2x_fcoe(bp, q_obj);
@@ -7176,7 +7176,7 @@ static inline void bnx2x_pf_q_prep_init(struct bnx2x *bp,
 	/* set maximum number of COSs supported by this queue */
 	init_params->max_cos = fp->max_cos;
 
-	DP(BNX2X_MSG_SP, "fp: %d setting queue params max cos to: %d",
+	DP(BNX2X_MSG_SP, "fp: %d setting queue params max cos to: %d\n",
 	    fp->index, init_params->max_cos);
 
 	/* set the context pointers queue object */
@@ -7209,7 +7209,7 @@ int bnx2x_setup_tx_only(struct bnx2x *bp, struct bnx2x_fastpath *fp,
 
 	DP(BNX2X_MSG_SP, "preparing to send tx-only ramrod for connection:"
 			 "cos %d, primary cid %d, cid %d, "
-			 "client id %d, sp-client id %d, flags %lx",
+			 "client id %d, sp-client id %d, flags %lx\n",
 	   tx_index, q_params->q_obj->cids[FIRST_TX_COS_INDEX],
 	   q_params->q_obj->cids[tx_index], q_params->q_obj->cl_id,
 	   tx_only_params->gen_params.spcl_id, tx_only_params->flags);
@@ -7241,7 +7241,7 @@ int bnx2x_setup_queue(struct bnx2x *bp, struct bnx2x_fastpath *fp,
 	int rc;
 	u8 tx_index;
 
-	DP(BNX2X_MSG_SP, "setting up queue %d", fp->index);
+	DP(BNX2X_MSG_SP, "setting up queue %d\n", fp->index);
 
 	/* reset IGU state skip FCoE L2 queue */
 	if (!IS_FCOE_FP(fp))
@@ -7265,7 +7265,7 @@ int bnx2x_setup_queue(struct bnx2x *bp, struct bnx2x_fastpath *fp,
 		return rc;
 	}
 
-	DP(BNX2X_MSG_SP, "init complete");
+	DP(BNX2X_MSG_SP, "init complete\n");
 
 
 	/* Now move the Queue to the SETUP state... */
@@ -7319,7 +7319,7 @@ static int bnx2x_stop_queue(struct bnx2x *bp, int index)
 	struct bnx2x_queue_state_params q_params = {0};
 	int rc, tx_index;
 
-	DP(BNX2X_MSG_SP, "stopping queue %d cid %d", index, fp->cid);
+	DP(BNX2X_MSG_SP, "stopping queue %d cid %d\n", index, fp->cid);
 
 	q_params.q_obj = &fp->q_obj;
 	/* We want to wait for completion in this context */
@@ -7334,7 +7334,7 @@ static int bnx2x_stop_queue(struct bnx2x *bp, int index)
 		/* ascertain this is a normal queue*/
 		txdata = &fp->txdata[tx_index];
 
-		DP(BNX2X_MSG_SP, "stopping tx-only queue %d",
+		DP(BNX2X_MSG_SP, "stopping tx-only queue %d\n",
 							txdata->txq_index);
 
 		/* send halt terminate on tx-only connection */
@@ -10704,7 +10704,7 @@ static int __devinit bnx2x_init_one(struct pci_dev *pdev,
 		return rc;
 	}
 
-	DP(NETIF_MSG_DRV, "max_non_def_sbs %d", max_non_def_sbs);
+	DP(NETIF_MSG_DRV, "max_non_def_sbs %d\n", max_non_def_sbs);
 
 	rc = bnx2x_init_bp(bp);
 	if (rc)
@@ -10759,15 +10759,14 @@ static int __devinit bnx2x_init_one(struct pci_dev *pdev,
 
 	bnx2x_get_pcie_width_speed(bp, &pcie_width, &pcie_speed);
 
-	netdev_info(dev, "%s (%c%d) PCI-E x%d %s found at mem %lx,"
-	       " IRQ %d, ", board_info[ent->driver_data].name,
-	       (CHIP_REV(bp) >> 12) + 'A', (CHIP_METAL(bp) >> 4),
-	       pcie_width,
-	       ((!CHIP_IS_E2(bp) && pcie_speed == 2) ||
-		 (CHIP_IS_E2(bp) && pcie_speed == 1)) ?
-						"5GHz (Gen2)" : "2.5GHz",
-	       dev->base_addr, bp->pdev->irq);
-	pr_cont("node addr %pM\n", dev->dev_addr);
+	netdev_info(dev, "%s (%c%d) PCI-E x%d %s found at mem %lx, IRQ %d, node addr %pM\n",
+		    board_info[ent->driver_data].name,
+		    (CHIP_REV(bp) >> 12) + 'A', (CHIP_METAL(bp) >> 4),
+		    pcie_width,
+		    ((!CHIP_IS_E2(bp) && pcie_speed == 2) ||
+		     (CHIP_IS_E2(bp) && pcie_speed == 1)) ?
+		    "5GHz (Gen2)" : "2.5GHz",
+		    dev->base_addr, bp->pdev->irq, dev->dev_addr);
 
 	return 0;
 
diff --git a/drivers/net/bnx2x/bnx2x_sp.c b/drivers/net/bnx2x/bnx2x_sp.c
index b4d9c16..1f88c19 100644
--- a/drivers/net/bnx2x/bnx2x_sp.c
+++ b/drivers/net/bnx2x/bnx2x_sp.c
@@ -3045,8 +3045,8 @@ static int bnx2x_mcast_setup_e1h(struct bnx2x *bp,
 			break;
 
 		case BNX2X_MCAST_CMD_DEL:
-			DP(BNX2X_MSG_SP, "Invalidating multicast "
-					 "MACs configuration\n");
+			DP(BNX2X_MSG_SP,
+			   "Invalidating multicast MACs configuration\n");
 
 			/* clear the registry */
 			memset(o->registry.aprox_match.vec, 0,
@@ -4239,7 +4239,7 @@ static int bnx2x_queue_comp_cmd(struct bnx2x *bp,
 			 o->cids[BNX2X_PRIMARY_CID_INDEX], o->next_state);
 
 	if (o->next_tx_only)  /* print num tx-only if any exist */
-		DP(BNX2X_MSG_SP, "primary cid %d: num tx-only cons %d",
+		DP(BNX2X_MSG_SP, "primary cid %d: num tx-only cons %d\n",
 			   o->cids[BNX2X_PRIMARY_CID_INDEX], o->next_tx_only);
 
 	o->state = o->next_state;
@@ -4301,7 +4301,7 @@ static void bnx2x_q_fill_init_general_data(struct bnx2x *bp,
 		test_bit(BNX2X_Q_FLG_FCOE, flags) ?
 		LLFC_TRAFFIC_TYPE_FCOE : LLFC_TRAFFIC_TYPE_NW;
 
-	DP(BNX2X_MSG_SP, "flags: active %d, cos %d, stats en %d",
+	DP(BNX2X_MSG_SP, "flags: active %d, cos %d, stats en %d\n",
 	   gen_data->activate_flg, gen_data->cos, gen_data->statistics_en_flg);
 }
 
@@ -4454,7 +4454,7 @@ static void bnx2x_q_fill_setup_tx_only(struct bnx2x *bp,
 				  &data->tx,
 				  &cmd_params->params.tx_only.flags);
 
-	DP(BNX2X_MSG_SP, "cid %d, tx bd page lo %x hi %x",cmd_params->q_obj->cids[0],
+	DP(BNX2X_MSG_SP, "cid %d, tx bd page lo %x hi %x\n",cmd_params->q_obj->cids[0],
 	   data->tx.tx_bd_page_base.lo, data->tx.tx_bd_page_base.hi);
 }
 
@@ -4501,9 +4501,9 @@ static inline int bnx2x_q_init(struct bnx2x *bp,
 
 	/* Set CDU context validation values */
 	for (cos = 0; cos < o->max_cos; cos++) {
-		DP(BNX2X_MSG_SP, "setting context validation. cid %d, cos %d",
+		DP(BNX2X_MSG_SP, "setting context validation. cid %d, cos %d\n",
 				 o->cids[cos], cos);
-		DP(BNX2X_MSG_SP, "context pointer %p", init->cxts[cos]);
+		DP(BNX2X_MSG_SP, "context pointer %p\n", init->cxts[cos]);
 		bnx2x_set_ctx_validation(bp, init->cxts[cos], o->cids[cos]);
 	}
 
@@ -4592,7 +4592,7 @@ static inline int bnx2x_q_send_setup_tx_only(struct bnx2x *bp,
 		return -EINVAL;
 	}
 
-	DP(BNX2X_MSG_SP, "parameters received: cos: %d sp-id: %d",
+	DP(BNX2X_MSG_SP, "parameters received: cos: %d sp-id: %d\n",
 			 tx_only_params->gen_params.cos,
 			 tx_only_params->gen_params.spcl_id);
 
@@ -4603,7 +4603,7 @@ static inline int bnx2x_q_send_setup_tx_only(struct bnx2x *bp,
 	bnx2x_q_fill_setup_tx_only(bp, params, rdata);
 
 	DP(BNX2X_MSG_SP, "sending tx-only ramrod: cid %d, client-id %d,"
-			 "sp-client id %d, cos %d",
+			 "sp-client id %d, cos %d\n",
 			 o->cids[cid_index],
 			 rdata->general.client_id,
 			 rdata->general.sp_client_id, rdata->general.cos);
@@ -5160,8 +5160,9 @@ static inline int bnx2x_func_state_change_comp(struct bnx2x *bp,
 		return -EINVAL;
 	}
 
-	DP(BNX2X_MSG_SP, "Completing command %d for func %d, setting state to "
-			 "%d\n", cmd, BP_FUNC(bp), o->next_state);
+	DP(BNX2X_MSG_SP,
+	   "Completing command %d for func %d, setting state to %d\n",
+	   cmd, BP_FUNC(bp), o->next_state);
 
 	o->state = o->next_state;
 	o->next_state = BNX2X_F_STATE_MAX;
-- 
1.7.6.405.gc1be0
