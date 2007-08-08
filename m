From: Ramkrishna Vepa <ram.vepa@neterion.com>
Subject: [PATCH 2.6.24]S2io: Enhance device error/alarm handling
Date: 07 Aug 2007 20:15:19 -0700
Message-ID: <1186542917.1997.17.camel@flash>
Reply-To: ram.vepa@neterion.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, support@neterion.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:57046 "EHLO
	barracuda.s2io.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934856AbXHHBW3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Aug 2007 21:22:29 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

- Added support to poll for entire set of device errors and alarms.
- Optimized interrupt routine fast path.
- Removed the unused variable, intr_type, in device private structure.

Signed-off-by: Santosh Rastapur <santosh.rastapur@neterion.com>
Signed-off-by: Ramkrishna Vepa <ram.vepa@neterion.com>
---
diff -Nurp 2.0.26.1/drivers/net/s2io.c 2.0.26.2/drivers/net/s2io.c
--- 2.0.26.1/drivers/net/s2io.c	2007-08-06 15:24:43.000000000 -0700
+++ 2.0.26.2/drivers/net/s2io.c	2007-08-06 15:22:29.000000000 -0700
@@ -84,7 +84,7 @@
 #include "s2io.h"
 #include "s2io-regs.h"
 
-#define DRV_VERSION "2.0.26.1"
+#define DRV_VERSION "2.0.26.2"
 
 /* S2io Driver name & version. */
 static char s2io_driver_name[] = "Neterion";
@@ -263,7 +263,14 @@ static char ethtool_driver_stats_keys[][
 	{"serious_err_cnt"},
 	{"soft_reset_cnt"},
 	{"fifo_full_cnt"},
-	{"ring_full_cnt"},
+	{"ring_0_full_cnt"},
+	{"ring_1_full_cnt"},
+	{"ring_2_full_cnt"},
+	{"ring_3_full_cnt"},
+	{"ring_4_full_cnt"},
+	{"ring_5_full_cnt"},
+	{"ring_6_full_cnt"},
+	{"ring_7_full_cnt"},
 	("alarm_transceiver_temp_high"),
 	("alarm_transceiver_temp_low"),
 	("alarm_laser_bias_current_high"),
@@ -303,7 +310,24 @@ static char ethtool_driver_stats_keys[][
 	("rx_tcode_fcs_err_cnt"),
 	("rx_tcode_buf_size_err_cnt"),
 	("rx_tcode_rxd_corrupt_cnt"),
-	("rx_tcode_unkn_err_cnt")
+	("rx_tcode_unkn_err_cnt"),
+	{"tda_err_cnt"},
+	{"pfc_err_cnt"},
+	{"pcc_err_cnt"},
+	{"tti_err_cnt"},
+	{"tpa_err_cnt"},
+	{"sm_err_cnt"},
+	{"lso_err_cnt"},
+	{"mac_tmac_err_cnt"},
+	{"mac_rmac_err_cnt"},
+	{"xgxs_txgxs_err_cnt"},
+	{"xgxs_rxgxs_err_cnt"},
+	{"rc_err_cnt"},
+	{"prc_pcix_err_cnt"},
+	{"rpa_err_cnt"},
+	{"rda_err_cnt"},
+	{"rti_err_cnt"},
+	{"mc_err_cnt"}
 };
 
 #define S2IO_XENA_STAT_LEN sizeof(ethtool_xena_stats_keys)/ ETH_GSTRING_LEN
@@ -802,7 +826,7 @@ static void free_shared_mem(struct s2io_
 
 	if (!nic)
 		return;
-
+	
 	dev = nic->dev;
 
 	mac_control = &nic->mac_control;
@@ -892,7 +916,7 @@ static void free_shared_mem(struct s2io_
 					k++;
 				}
 				kfree(mac_control->rings[i].ba[j]);
-				nic->mac_control.stats_info->sw_stat.mem_freed 				+= (sizeof(struct buffAdd) * 
+				nic->mac_control.stats_info->sw_stat.mem_freed 	+= (sizeof(struct buffAdd) *
 				(rxd_count[nic->rxd_mode] + 1));
 			}
 			kfree(mac_control->rings[i].ba);
@@ -1456,7 +1480,7 @@ static int init_nic(struct s2io_nic *nic
 				&bar0->rts_frm_len_n[i]);
 		}
 	}
-	
+
 	/* Disable differentiated services steering logic */
 	for (i = 0; i < 64; i++) {
 		if (rts_ds_steer(nic, i, 0) == FAILURE) {
@@ -1586,7 +1610,7 @@ static int init_nic(struct s2io_nic *nic
 
 		val64 = RTI_DATA2_MEM_RX_UFC_A(0x1) |
 		    RTI_DATA2_MEM_RX_UFC_B(0x2) ;
-		if (nic->intr_type == MSI_X)
+		if (nic->config.intr_type == MSI_X)
 		    val64 |= (RTI_DATA2_MEM_RX_UFC_C(0x20) | \
 				RTI_DATA2_MEM_RX_UFC_D(0x40));
 		else
@@ -1724,7 +1748,7 @@ static int init_nic(struct s2io_nic *nic
 
 static int s2io_link_fault_indication(struct s2io_nic *nic)
 {
-	if (nic->intr_type != INTA)
+	if (nic->config.intr_type != INTA)
 		return MAC_RMAC_ERR_TIMER;
 	if (nic->device_type == XFRAME_II_DEVICE)
 		return LINK_UP_DOWN_INTERRUPT;
@@ -1732,6 +1756,362 @@ static int s2io_link_fault_indication(st
 		return MAC_RMAC_ERR_TIMER;
 }
 
+
+void en_dis_err_alarms(struct s2io_nic *nic, u16 mask, int flag)
+{
+	struct XENA_dev_config __iomem *bar0 = nic->bar0;
+	register u64 val64 = 0, temp64 = 0, gen_int_mask = 0;
+
+	if (mask & TX_DMA_INTR) {
+		gen_int_mask |= TXDMA_INT_M;
+
+		if (flag == ENABLE_INTRS) {
+
+			val64 = TXDMA_TDA_INT|TXDMA_PFC_INT|TXDMA_PCC_INT
+				|TXDMA_TTI_INT|TXDMA_LSO_INT|TXDMA_TPA_INT
+				|TXDMA_SM_INT;
+			temp64 = readq(&bar0->txdma_int_mask);
+			temp64 &= ~((u64) val64);
+			writeq(temp64, &bar0->txdma_int_mask);
+
+			val64 = PFC_ECC_DB_ERR|PFC_SM_ERR_ALARM|PFC_MISC_0_ERR
+				|PFC_MISC_1_ERR|PFC_PCIX_ERR|PFC_ECC_SG_ERR;
+			temp64 = readq(&bar0->pfc_err_mask);
+			temp64 &= ~((u64) val64);
+			writeq(temp64, &bar0->pfc_err_mask);
+
+			val64 = TDA_Fn_ECC_DB_ERR|TDA_SM0_ERR_ALARM
+				|TDA_SM1_ERR_ALARM|TDA_Fn_ECC_SG_ERR|TDA_PCIX_ERR;
+			temp64 = readq(&bar0->tda_err_mask);
+			temp64 &= ~((u64) val64);
+			writeq(temp64, &bar0->tda_err_mask);
+
+			val64 = PCC_FB_ECC_DB_ERR|PCC_TXB_ECC_DB_ERR
+				|PCC_SM_ERR_ALARM|PCC_WR_ERR_ALARM|PCC_N_SERR
+				|PCC_6_COF_OV_ERR|PCC_7_COF_OV_ERR
+				|PCC_6_LSO_OV_ERR|PCC_7_LSO_OV_ERR
+				|PCC_FB_ECC_SG_ERR|PCC_TXB_ECC_SG_ERR;
+			temp64 = readq(&bar0->pcc_err_mask);
+			temp64 &= ~((u64) val64);
+			writeq(temp64, &bar0->pcc_err_mask);
+
+			val64 = TTI_SM_ERR_ALARM|TTI_ECC_SG_ERR|TTI_ECC_DB_ERR;
+			temp64 = readq(&bar0->tti_err_mask);
+			temp64 &= ~((u64) val64);
+			writeq(temp64, &bar0->tti_err_mask);
+
+
+			val64 = LSO6_ABORT|LSO7_ABORT|LSO6_SM_ERR_ALARM
+				|LSO7_SM_ERR_ALARM|LSO6_SEND_OFLOW|LSO7_SEND_OFLOW;
+			temp64 = readq(&bar0->lso_err_mask);
+			temp64 &= ~((u64) val64);
+			writeq(temp64, &bar0->lso_err_mask);
+
+			val64 = TPA_SM_ERR_ALARM|TPA_TX_FRM_DROP;
+			temp64 = readq(&bar0->tpa_err_mask);
+			temp64 &= ~((u64) val64);
+			writeq(temp64, &bar0->tpa_err_mask);
+
+			val64 = SM_SM_ERR_ALARM;
+			temp64 = readq(&bar0->sm_err_mask);
+			temp64 &= ~((u64) val64);
+			writeq(temp64, &bar0->sm_err_mask);
+		}
+		else {
+			val64 = TXDMA_TDA_INT|TXDMA_PFC_INT|TXDMA_PCC_INT
+				|TXDMA_TTI_INT|TXDMA_LSO_INT|TXDMA_TPA_INT
+				|TXDMA_SM_INT;
+			temp64 = readq(&bar0->txdma_int_mask);
+			temp64 |= ((u64) val64);
+			writeq(temp64, &bar0->txdma_int_mask);
+
+			val64 = PFC_ECC_DB_ERR|PFC_SM_ERR_ALARM|PFC_MISC_0_ERR
+				|PFC_MISC_1_ERR|PFC_PCIX_ERR|PFC_ECC_SG_ERR;
+			temp64 = readq(&bar0->pfc_err_mask);
+			temp64 |= ((u64) val64);
+			writeq(temp64, &bar0->pfc_err_mask);
+
+			val64 = TDA_Fn_ECC_DB_ERR|TDA_SM0_ERR_ALARM
+				|TDA_Fn_ECC_SG_ERR|TDA_SM1_ERR_ALARM
+				|TDA_PCIX_ERR;
+			temp64 = readq(&bar0->tda_err_mask);
+			temp64 |= ((u64) val64);
+			writeq(temp64, &bar0->tda_err_mask);
+
+			val64 = PCC_FB_ECC_DB_ERR|PCC_TXB_ECC_DB_ERR
+				|PCC_SM_ERR_ALARM |PCC_WR_ERR_ALARM|PCC_N_SERR
+				|PCC_FB_ECC_SG_ERR|PCC_TXB_ECC_SG_ERR
+				|PCC_6_COF_OV_ERR|PCC_7_COF_OV_ERR
+				|PCC_6_LSO_OV_ERR|PCC_7_LSO_OV_ERR;
+			temp64 = readq(&bar0->pcc_err_mask);
+			temp64 |= ((u64) val64);
+			writeq(temp64, &bar0->pcc_err_mask);
+
+			val64 = TTI_SM_ERR_ALARM|TTI_ECC_SG_ERR|TTI_ECC_DB_ERR;
+			temp64 = readq(&bar0->tti_err_mask);
+			temp64 |= ((u64) val64);
+			writeq(temp64, &bar0->tti_err_mask);
+
+			val64 = LSO6_ABORT|LSO7_ABORT|LSO6_SM_ERR_ALARM
+				|LSO7_SM_ERR_ALARM|LSO6_SEND_OFLOW
+				|LSO7_SEND_OFLOW;
+			temp64 = readq(&bar0->lso_err_mask);
+			temp64 |= ((u64) val64);
+			writeq(temp64, &bar0->lso_err_mask);
+
+			val64 = TPA_SM_ERR_ALARM|TPA_TX_FRM_DROP;
+			temp64 = readq(&bar0->tpa_err_mask);
+			temp64 |= ((u64) val64);
+			writeq(temp64, &bar0->tpa_err_mask);
+
+			val64 = SM_SM_ERR_ALARM;
+			temp64 = readq(&bar0->sm_err_mask);
+			temp64 |= ((u64) val64);
+			writeq(temp64, &bar0->sm_err_mask);
+		}
+	}
+
+	if (mask & TX_MAC_INTR) {
+		gen_int_mask |= TXMAC_INT_M;
+
+		if (flag == ENABLE_INTRS) {
+			val64 = MAC_INT_STATUS_TMAC_INT;
+			temp64 = readq(&bar0->mac_int_mask);
+			temp64 &= ~((u64) val64);
+			writeq(temp64, &bar0->mac_int_mask);
+
+			val64 = TMAC_TX_BUF_OVRN|TMAC_TX_SM_ERR|TMAC_ECC_SG_ERR|
+				TMAC_ECC_DB_ERR|TMAC_DESC_ECC_SG_ERR|TMAC_DESC_ECC_DB_ERR;
+			temp64 = readq(&bar0->mac_tmac_err_mask);
+			temp64 &= ~((u64) val64);
+			writeq(temp64, &bar0->mac_tmac_err_mask);
+		}
+		else {
+			val64 = MAC_INT_STATUS_TMAC_INT;
+			temp64 = readq(&bar0->mac_int_mask);
+			temp64 |= ((u64) val64);
+			writeq(temp64, &bar0->mac_int_mask);
+
+			val64 = TMAC_ECC_SG_ERR|TMAC_ECC_DB_ERR
+				|TMAC_TX_BUF_OVRN|TMAC_TX_SM_ERR
+				|TMAC_DESC_ECC_SG_ERR|TMAC_DESC_ECC_DB_ERR;
+			temp64 = readq(&bar0->mac_tmac_err_mask);
+			temp64 |= ((u64) val64);
+			writeq(temp64, &bar0->mac_tmac_err_mask);
+		}
+	}
+
+	if (mask & TX_XGXS_INTR) {
+		gen_int_mask |= TXXGXS_INT_M;
+
+		if (flag == ENABLE_INTRS) {
+			val64 = XGXS_INT_STATUS_TXGXS;
+			temp64 = readq(&bar0->xgxs_int_mask);
+			temp64 &= ~((u64) val64);
+			writeq(temp64, &bar0->xgxs_int_mask);
+
+			val64 = TXGXS_ESTORE_UFLOW|TXGXS_TX_SM_ERR|
+				TXGXS_ECC_SG_ERR|TXGXS_ECC_DB_ERR;
+			temp64 = readq(&bar0->xgxs_txgxs_err_mask);
+			temp64 &= ~((u64) val64);
+			writeq(temp64, &bar0->xgxs_txgxs_err_mask);
+		}
+		else {
+			val64 = XGXS_INT_STATUS_TXGXS;
+			temp64 = readq(&bar0->mac_int_mask);
+			temp64 |= ((u64) val64);
+			writeq(temp64, &bar0->mac_int_mask);
+
+			val64 = TXGXS_ECC_SG_ERR|TXGXS_ECC_DB_ERR
+				|TXGXS_ESTORE_UFLOW|TXGXS_TX_SM_ERR;
+			temp64 = readq(&bar0->xgxs_txgxs_err_mask);
+			temp64 |= ((u64) val64);
+			writeq(temp64, &bar0->xgxs_txgxs_err_mask);
+		}
+	}
+
+	if (mask & RX_DMA_INTR) {
+		gen_int_mask |= RXDMA_INT_M;
+
+		if (flag == ENABLE_INTRS) {
+			val64 = RXDMA_INT_RC_INT_M|RXDMA_INT_RPA_INT_M
+				|RXDMA_INT_RDA_INT_M|RXDMA_INT_RTI_INT_M;
+			temp64 = readq(&bar0->rxdma_int_mask);
+			temp64 &= ~((u64) val64);
+			writeq(temp64, &bar0->rxdma_int_mask);
+
+			val64 = RC_PRCn_ECC_DB_ERR|RC_FTC_ECC_DB_ERR|
+				RC_PRCn_SM_ERR_ALARM|RC_FTC_SM_ERR_ALARM|
+				RC_PRCn_ECC_SG_ERR|RC_FTC_ECC_SG_ERR|
+				RC_RDA_FAIL_WR_Rn;
+			temp64 = readq(&bar0->rc_err_mask);
+			temp64 &= ~((u64) val64);
+			writeq(temp64, &bar0->rc_err_mask);
+
+			val64 = PRC_PCI_AB_RD_Rn|PRC_PCI_AB_WR_Rn|
+				PRC_PCI_AB_F_WR_Rn|PRC_PCI_DP_RD_Rn|PRC_PCI_DP_WR_Rn|
+				PRC_PCI_DP_F_WR_Rn;
+			temp64 = readq(&bar0->prc_pcix_err_mask);
+			temp64 &= ~((u64) val64);
+			writeq(temp64, &bar0->prc_pcix_err_mask);
+
+			val64 = RPA_SM_ERR_ALARM|RPA_CREDIT_ERR|
+				RPA_ECC_SG_ERR|RPA_ECC_DB_ERR;
+			temp64 = readq(&bar0->rpa_err_mask);
+			temp64 &= ~((u64) val64);
+			writeq(temp64, &bar0->rpa_err_mask);
+
+			val64 = RDA_RXDn_ECC_DB_ERR|RDA_FRM_ECC_DB_N_AERR|
+				RDA_SM1_ERR_ALARM|RDA_SM0_ERR_ALARM|
+				RDA_RXD_ECC_DB_SERR|RDA_RXDn_ECC_SG_ERR|RDA_FRM_ECC_SG_ERR|
+				RDA_MISC_ERR|RDA_PCIX_ERR;
+			temp64 = readq(&bar0->rda_err_mask);
+			temp64 &= ~((u64) val64);
+			writeq(temp64, &bar0->rda_err_mask);
+
+			val64 = RTI_SM_ERR_ALARM|RTI_ECC_SG_ERR|RTI_ECC_DB_ERR;
+			temp64 = readq(&bar0->rti_err_mask);
+			temp64 &= ~((u64) val64);
+			writeq(temp64, &bar0->rti_err_mask);
+		}
+		else {
+			val64 = RXDMA_INT_RC_INT_M|RXDMA_INT_RPA_INT_M
+				|RXDMA_INT_RDA_INT_M|RXDMA_INT_RTI_INT_M;
+			temp64 = readq(&bar0->rxdma_int_mask);
+			temp64 |= ((u64) val64);
+			writeq(temp64, &bar0->rxdma_int_mask);
+
+			val64 = RC_PRCn_ECC_SG_ERR|RC_PRCn_ECC_DB_ERR
+				|RC_FTC_ECC_SG_ERR|RC_FTC_ECC_DB_ERR
+				|RC_PRCn_SM_ERR_ALARM|RC_FTC_SM_ERR_ALARM
+				|RC_RDA_FAIL_WR_Rn;
+			temp64 = readq(&bar0->rc_err_mask);
+			temp64 |= ((u64) val64);
+			writeq(temp64, &bar0->rc_err_mask);
+
+			val64 = PRC_PCI_AB_RD_Rn|PRC_PCI_DP_RD_Rn
+				|PRC_PCI_AB_WR_Rn|PRC_PCI_DP_WR_Rn
+				|PRC_PCI_AB_F_WR_Rn|PRC_PCI_DP_F_WR_Rn;
+			temp64 = readq(&bar0->prc_pcix_err_mask);
+			temp64 |= ((u64) val64);
+			writeq(temp64, &bar0->prc_pcix_err_mask);
+
+			val64 = RPA_ECC_SG_ERR|RPA_ECC_DB_ERR
+				|RPA_FLUSH_REQUEST|RPA_SM_ERR_ALARM
+				|RPA_CREDIT_ERR;
+			temp64 = readq(&bar0->rpa_err_mask);
+			temp64 |= ((u64) val64);
+			writeq(temp64, &bar0->rpa_err_mask);
+
+			val64 = RDA_RXDn_ECC_SG_ERR|RDA_RXDn_ECC_DB_ERR
+				|RDA_FRM_ECC_SG_ERR|RDA_FRM_ECC_DB_N_AERR
+				|RDA_SM1_ERR_ALARM|RDA_SM0_ERR_ALARM
+				|RDA_MISC_ERR|RDA_PCIX_ERR|RDA_RXD_ECC_DB_SERR;
+			temp64 = readq(&bar0->rda_err_mask);
+			temp64 |= ((u64) val64);
+			writeq(temp64, &bar0->rda_err_mask);
+
+			val64 = RTI_ECC_SG_ERR|RTI_ECC_DB_ERR|RTI_SM_ERR_ALARM;
+			temp64 = readq(&bar0->rti_err_mask);
+			temp64 |= ((u64) val64);
+			writeq(temp64, &bar0->rti_err_mask);
+		}
+	}
+
+	if (mask & RX_MAC_INTR) {
+		gen_int_mask |= RXMAC_INT_M;
+
+		if (flag == ENABLE_INTRS) {
+			val64 = MAC_INT_STATUS_RMAC_INT;
+			temp64 = readq(&bar0->mac_int_mask);
+			temp64 &= ~((u64) val64);
+			writeq(temp64, &bar0->mac_int_mask);
+
+			val64 = RMAC_RX_BUFF_OVRN|RMAC_RX_SM_ERR|
+				RMAC_UNUSED_INT|RMAC_SINGLE_ECC_ERR|
+				RMAC_DOUBLE_ECC_ERR|RMAC_LINK_STATE_CHANGE_INT;
+			temp64 = readq(&bar0->mac_rmac_err_mask);
+			temp64 &= ~((u64) val64);
+			writeq(temp64, &bar0->mac_rmac_err_mask);
+		}
+		else {
+			val64 = MAC_INT_STATUS_RMAC_INT;
+			temp64 = readq(&bar0->mac_int_mask);
+			temp64 |= ((u64) val64);
+			writeq(temp64, &bar0->mac_int_mask);
+
+			val64 = RMAC_RX_BUFF_OVRN|RMAC_FRM_RCVD_INT
+				|RMAC_UNUSED_INT|RMAC_SINGLE_ECC_ERR
+				|RMAC_DOUBLE_ECC_ERR|RMAC_LINK_STATE_CHANGE_INT
+				|RMAC_RX_SM_ERR;
+			temp64 = readq(&bar0->mac_rmac_err_mask);
+			temp64 |= ((u64) val64);
+			writeq(temp64, &bar0->mac_rmac_err_mask);
+		}
+	}
+
+	if (mask & RX_XGXS_INTR)
+	{
+		gen_int_mask |= RXXGXS_INT_M;
+
+		if (flag == ENABLE_INTRS) {
+			val64 = XGXS_INT_STATUS_RXGXS;
+			temp64 = readq(&bar0->xgxs_int_mask);
+			temp64 &= ~((u64) val64);
+			writeq(temp64, &bar0->xgxs_int_mask);
+
+			val64 = RXGXS_ESTORE_OFLOW|RXGXS_RX_SM_ERR;
+			temp64 = readq(&bar0->xgxs_rxgxs_err_mask);
+			temp64 &= ~((u64) val64);
+			writeq(temp64, &bar0->xgxs_rxgxs_err_mask);
+		}
+		else {
+			val64 = XGXS_INT_STATUS_RXGXS;
+			temp64 = readq(&bar0->xgxs_int_mask);
+			temp64 |= ((u64) val64);
+			writeq(temp64, &bar0->xgxs_int_mask);
+
+			val64 = RXGXS_ESTORE_OFLOW|RXGXS_RX_SM_ERR;
+			temp64 = readq(&bar0->xgxs_rxgxs_err_mask);
+			temp64 |= ((u64) val64);
+			writeq(temp64, &bar0->xgxs_rxgxs_err_mask);
+		}
+	}
+
+	if (mask & MC_INTR) {
+		gen_int_mask |= MC_INT_M;
+
+		if (flag == ENABLE_INTRS) {
+			val64 = MC_INT_MASK_MC_INT;
+			temp64 = readq(&bar0->mc_int_mask);
+			temp64 &= ~((u64) val64);
+			writeq(temp64, &bar0->mc_int_mask);
+
+			val64 = MC_ERR_REG_SM_ERR|MC_ERR_REG_ECC_ALL_SNG|
+				MC_ERR_REG_ECC_ALL_DBL;
+			temp64 = readq(&bar0->mc_err_mask);
+			temp64 &= ~((u64) val64);
+			writeq(temp64, &bar0->mc_err_mask);
+		}
+		else {
+			val64 = MC_INT_MASK_MC_INT;
+			temp64 = readq(&bar0->mc_int_mask);
+			temp64 |= ((u64) val64);
+			writeq(temp64, &bar0->mc_int_mask);
+
+			val64 = MC_ERR_REG_ECC_ALL_SNG|MC_ERR_REG_ECC_ALL_DBL
+				|MC_ERR_REG_SM_ERR|PLL_LOCK_N;
+			temp64 = readq(&bar0->mc_err_mask);
+			temp64 |= ((u64) val64);
+			writeq(temp64, &bar0->mc_err_mask);
+		}
+	}
+	nic->general_int_mask = gen_int_mask;
+
+	/* Remove this line when alarm interrupts are enabled */
+	nic->general_int_mask = 0;
+}
+
 /**
  *  en_dis_able_nic_intrs - Enable or Disable the interrupts
  *  @nic: device private variable,
@@ -1742,21 +2122,19 @@ static int s2io_link_fault_indication(st
  *  enable/disable any Intr block.
  *  Return Value: NONE.
  */
-
 static void en_dis_able_nic_intrs(struct s2io_nic *nic, u16 mask, int flag)
 {
 	struct XENA_dev_config __iomem *bar0 = nic->bar0;
-	register u64 val64 = 0, temp64 = 0;
+	register u64 temp64 = 0, intr_mask = 0;
+
+	intr_mask = nic->general_int_mask;
 
 	/*  Top level interrupt classification */
 	/*  PIC Interrupts */
-	if ((mask & (TX_PIC_INTR | RX_PIC_INTR))) {
+	if (mask & TX_PIC_INTR) {
 		/*  Enable PIC Intrs in the general intr mask register */
-		val64 = TXPIC_INT_M;
+		intr_mask |= TXPIC_INT_M ;
 		if (flag == ENABLE_INTRS) {
-			temp64 = readq(&bar0->general_int_mask);
-			temp64 &= ~((u64) val64);
-			writeq(temp64, &bar0->general_int_mask);
 			/*
 			 * If Hercules adapter enable GPIO otherwise
 			 * disable all PCIX, Flash, MDIO, IIC and GPIO
@@ -1771,58 +2149,21 @@ static void en_dis_able_nic_intrs(struct
 				temp64 = readq(&bar0->gpio_int_mask);
 				temp64 &= ~((u64) GPIO_INT_MASK_LINK_UP);
 				writeq(temp64, &bar0->gpio_int_mask);
-			} else {
+			} else
 				writeq(DISABLE_ALL_INTRS, &bar0->pic_int_mask);
-			}
-			/*
-			 * No MSI Support is available presently, so TTI and
-			 * RTI interrupts are also disabled.
-			 */
 		} else if (flag == DISABLE_INTRS) {
 			/*
 			 * Disable PIC Intrs in the general
 			 * intr mask register
 			 */
 			writeq(DISABLE_ALL_INTRS, &bar0->pic_int_mask);
-			temp64 = readq(&bar0->general_int_mask);
-			val64 |= temp64;
-			writeq(val64, &bar0->general_int_mask);
-		}
-	}
-
-	/*  MAC Interrupts */
-	/*  Enabling/Disabling MAC interrupts */
-	if (mask & (TX_MAC_INTR | RX_MAC_INTR)) {
-		val64 = TXMAC_INT_M | RXMAC_INT_M;
-		if (flag == ENABLE_INTRS) {
-			temp64 = readq(&bar0->general_int_mask);
-			temp64 &= ~((u64) val64);
-			writeq(temp64, &bar0->general_int_mask);
-			/*
-			 * All MAC block error interrupts are disabled for now
-			 * TODO
-			 */
-		} else if (flag == DISABLE_INTRS) {
-			/*
-			 * Disable MAC Intrs in the general intr mask register
-			 */
-			writeq(DISABLE_ALL_INTRS, &bar0->mac_int_mask);
-			writeq(DISABLE_ALL_INTRS,
-			       &bar0->mac_rmac_err_mask);
-
-			temp64 = readq(&bar0->general_int_mask);
-			val64 |= temp64;
-			writeq(val64, &bar0->general_int_mask);
 		}
 	}
 
 	/*  Tx traffic interrupts */
 	if (mask & TX_TRAFFIC_INTR) {
-		val64 = TXTRAFFIC_INT_M;
+		intr_mask |= TXTRAFFIC_INT_M;
 		if (flag == ENABLE_INTRS) {
-			temp64 = readq(&bar0->general_int_mask);
-			temp64 &= ~((u64) val64);
-			writeq(temp64, &bar0->general_int_mask);
 			/*
 			 * Enable all the Tx side interrupts
 			 * writing 0 Enables all 64 TX interrupt levels
@@ -1834,19 +2175,13 @@ static void en_dis_able_nic_intrs(struct
 			 * register.
 			 */
 			writeq(DISABLE_ALL_INTRS, &bar0->tx_traffic_mask);
-			temp64 = readq(&bar0->general_int_mask);
-			val64 |= temp64;
-			writeq(val64, &bar0->general_int_mask);
 		}
 	}
 
 	/*  Rx traffic interrupts */
 	if (mask & RX_TRAFFIC_INTR) {
-		val64 = RXTRAFFIC_INT_M;
+		intr_mask |= RXTRAFFIC_INT_M;
 		if (flag == ENABLE_INTRS) {
-			temp64 = readq(&bar0->general_int_mask);
-			temp64 &= ~((u64) val64);
-			writeq(temp64, &bar0->general_int_mask);
 			/* writing 0 Enables all 8 RX interrupt levels */
 			writeq(0x0, &bar0->rx_traffic_mask);
 		} else if (flag == DISABLE_INTRS) {
@@ -1855,11 +2190,17 @@ static void en_dis_able_nic_intrs(struct
 			 * register.
 			 */
 			writeq(DISABLE_ALL_INTRS, &bar0->rx_traffic_mask);
-			temp64 = readq(&bar0->general_int_mask);
-			val64 |= temp64;
-			writeq(val64, &bar0->general_int_mask);
 		}
 	}
+
+	temp64 = readq(&bar0->general_int_mask);
+	if (flag == ENABLE_INTRS)
+		temp64 &= ~((u64) intr_mask);
+	else
+		temp64 = DISABLE_ALL_INTRS;
+	writeq(temp64, &bar0->general_int_mask);
+
+	nic->general_int_mask = readq(&bar0->general_int_mask);
 }
 
 /**
@@ -1872,7 +2213,7 @@ static int verify_pcc_quiescent(struct s
 	int ret = 0, herc;
 	struct XENA_dev_config __iomem *bar0 = sp->bar0;
 	u64 val64 = readq(&bar0->adapter_status);
-	
+
 	herc = (sp->device_type == XFRAME_II_DEVICE);
 
 	if (flag == FALSE) {
@@ -2063,14 +2404,6 @@ static int start_nic(struct s2io_nic *ni
 	writeq(val64, &bar0->adapter_control);
 
 	/*
-	 * Clearing any possible Link state change interrupts that
-	 * could have popped up just before Enabling the card.
-	 */
-	val64 = readq(&bar0->mac_rmac_err_reg);
-	if (val64)
-		writeq(val64, &bar0->mac_rmac_err_reg);
-
-	/*
 	 * Verify if the device is ready to be enabled, if so enable
 	 * it.
 	 */
@@ -2223,9 +2556,9 @@ static void stop_nic(struct s2io_nic *ni
 	config = &nic->config;
 
 	/*  Disable all interrupts */
+	en_dis_err_alarms(nic, ENA_ALL_INTRS, DISABLE_INTRS);
 	interruptible = TX_TRAFFIC_INTR | RX_TRAFFIC_INTR;
-	interruptible |= TX_PIC_INTR | RX_PIC_INTR;
-	interruptible |= TX_MAC_INTR | RX_MAC_INTR;
+	interruptible |= TX_PIC_INTR;
 	en_dis_able_nic_intrs(nic, interruptible, DISABLE_INTRS);
 
 	/* Clearing Adapter_En bit of ADAPTER_CONTROL Register */
@@ -2589,6 +2922,12 @@ static int s2io_poll(struct net_device *
 	int i;
 
 	atomic_inc(&nic->isr_cnt);
+
+	if (unlikely(atomic_read(&nic->card_state) == CARD_DOWN)) {
+		atomic_dec(&nic->isr_cnt);
+		return IRQ_NONE;
+	}
+
 	mac_control = &nic->mac_control;
 	config = &nic->config;
 
@@ -2724,13 +3063,6 @@ static void rx_intr_handler(struct ring_
 	struct RxD3* rxdp3;
 
 	spin_lock(&nic->rx_lock);
-	if (atomic_read(&nic->card_state) == CARD_DOWN) {
-		DBG_PRINT(INTR_DBG, "%s: %s going down for reset\n",
-			  __FUNCTION__, dev->name);
-		spin_unlock(&nic->rx_lock);
-		return;
-	}
-
 	get_info = ring_data->rx_curr_get_info;
 	get_block = get_info.block_index;
 	memcpy(&put_info, &ring_data->rx_curr_put_info, sizeof(put_info));
@@ -3164,135 +3496,6 @@ static void s2io_updt_xpak_counter(struc
 }
 
 /**
- *  alarm_intr_handler - Alarm Interrrupt handler
- *  @nic: device private variable
- *  Description: If the interrupt was neither because of Rx packet or Tx
- *  complete, this function is called. If the interrupt was to indicate
- *  a loss of link, the OSM link status handler is invoked for any other
- *  alarm interrupt the block that raised the interrupt is displayed
- *  and a H/W reset is issued.
- *  Return Value:
- *  NONE
-*/
-
-static void alarm_intr_handler(struct s2io_nic *nic)
-{
-	struct net_device *dev = (struct net_device *) nic->dev;
-	struct XENA_dev_config __iomem *bar0 = nic->bar0;
-	register u64 val64 = 0, err_reg = 0;
-	u64 cnt;
-	int i;
-	if (atomic_read(&nic->card_state) == CARD_DOWN)
-		return;
-	if (pci_channel_offline(nic->pdev))
-		return;
-	nic->mac_control.stats_info->sw_stat.ring_full_cnt = 0;
-	/* Handling the XPAK counters update */
-	if(nic->mac_control.stats_info->xpak_stat.xpak_timer_count < 72000) {
-		/* waiting for an hour */
-		nic->mac_control.stats_info->xpak_stat.xpak_timer_count++;
-	} else {
-		s2io_updt_xpak_counter(dev);
-		/* reset the count to zero */
-		nic->mac_control.stats_info->xpak_stat.xpak_timer_count = 0;
-	}
-
-	/* Handling link status change error Intr */
-	if (s2io_link_fault_indication(nic) == MAC_RMAC_ERR_TIMER) {
-		err_reg = readq(&bar0->mac_rmac_err_reg);
-		writeq(err_reg, &bar0->mac_rmac_err_reg);
-		if (err_reg & RMAC_LINK_STATE_CHANGE_INT) {
-			schedule_work(&nic->set_link_task);
-		}
-	}
-
-	/* Handling Ecc errors */
-	val64 = readq(&bar0->mc_err_reg);
-	writeq(val64, &bar0->mc_err_reg);
-	if (val64 & (MC_ERR_REG_ECC_ALL_SNG | MC_ERR_REG_ECC_ALL_DBL)) {
-		if (val64 & MC_ERR_REG_ECC_ALL_DBL) {
-			nic->mac_control.stats_info->sw_stat.
-				double_ecc_errs++;
-			DBG_PRINT(INIT_DBG, "%s: Device indicates ",
-				  dev->name);
-			DBG_PRINT(INIT_DBG, "double ECC error!!\n");
-			if (nic->device_type != XFRAME_II_DEVICE) {
-				/* Reset XframeI only if critical error */
-				if (val64 & (MC_ERR_REG_MIRI_ECC_DB_ERR_0 |
-					     MC_ERR_REG_MIRI_ECC_DB_ERR_1)) {
-					netif_stop_queue(dev);
-					schedule_work(&nic->rst_timer_task);
-					nic->mac_control.stats_info->sw_stat.
-							soft_reset_cnt++;
-				}
-			}
-		} else {
-			nic->mac_control.stats_info->sw_stat.
-				single_ecc_errs++;
-		}
-	}
-
-	/* In case of a serious error, the device will be Reset. */
-	val64 = readq(&bar0->serr_source);
-	if (val64 & SERR_SOURCE_ANY) {
-		nic->mac_control.stats_info->sw_stat.serious_err_cnt++;
-		DBG_PRINT(ERR_DBG, "%s: Device indicates ", dev->name);
-		DBG_PRINT(ERR_DBG, "serious error %llx!!\n",
-			  (unsigned long long)val64);
-		netif_stop_queue(dev);
-		schedule_work(&nic->rst_timer_task);
-		nic->mac_control.stats_info->sw_stat.soft_reset_cnt++;
-	}
-
-	/*
-	 * Also as mentioned in the latest Errata sheets if the PCC_FB_ECC
-	 * Error occurs, the adapter will be recycled by disabling the
-	 * adapter enable bit and enabling it again after the device
-	 * becomes Quiescent.
-	 */
-	val64 = readq(&bar0->pcc_err_reg);
-	writeq(val64, &bar0->pcc_err_reg);
-	if (val64 & PCC_FB_ECC_DB_ERR) {
-		u64 ac = readq(&bar0->adapter_control);
-		ac &= ~(ADAPTER_CNTL_EN);
-		writeq(ac, &bar0->adapter_control);
-		ac = readq(&bar0->adapter_control);
-		schedule_work(&nic->set_link_task);
-	}
-	/* Check for data parity error */
-	val64 = readq(&bar0->pic_int_status);
-	if (val64 & PIC_INT_GPIO) {
-		val64 = readq(&bar0->gpio_int_reg);
-		if (val64 & GPIO_INT_REG_DP_ERR_INT) {
-			nic->mac_control.stats_info->sw_stat.parity_err_cnt++;
-			schedule_work(&nic->rst_timer_task);
-			nic->mac_control.stats_info->sw_stat.soft_reset_cnt++;
-		}
-	}
-
-	/* Check for ring full counter */
-	if (nic->device_type & XFRAME_II_DEVICE) {
-		val64 = readq(&bar0->ring_bump_counter1);
-		for (i=0; i<4; i++) {
-			cnt = ( val64 & vBIT(0xFFFF,(i*16),16));
-			cnt >>= 64 - ((i+1)*16);
-			nic->mac_control.stats_info->sw_stat.ring_full_cnt
-				+= cnt;
-		}
-
-		val64 = readq(&bar0->ring_bump_counter2);
-		for (i=0; i<4; i++) {
-			cnt = ( val64 & vBIT(0xFFFF,(i*16),16));
-			cnt >>= 64 - ((i+1)*16);
-			nic->mac_control.stats_info->sw_stat.ring_full_cnt
-				+= cnt;
-		}
-	}
-
-	/* Other type of interrupts are not being handled now,  TODO */
-}
-
-/**
  *  wait_for_cmd_complete - waits for a command to complete.
  *  @sp : private member of the device structure, which is a pointer to the
  *  s2io_nic structure.
@@ -3426,7 +3629,7 @@ static void s2io_reset(struct s2io_nic *
 
 	/* Reset device statistics maintained by OS */
 	memset(&sp->stats, 0, sizeof (struct net_device_stats));
-	
+
 	up_cnt = sp->mac_control.stats_info->sw_stat.link_up_cnt;
 	down_cnt = sp->mac_control.stats_info->sw_stat.link_down_cnt;
 	up_time = sp->mac_control.stats_info->sw_stat.link_up_time;
@@ -3565,7 +3768,7 @@ static int s2io_set_swapper(struct s2io_
 		 SWAPPER_CTRL_RXF_W_FE |
 		 SWAPPER_CTRL_XMSI_FE |
 		 SWAPPER_CTRL_STATS_FE | SWAPPER_CTRL_STATS_SE);
-	if (sp->intr_type == INTA)
+	if (sp->config.intr_type == INTA)
 		val64 |= SWAPPER_CTRL_XMSI_SE;
 	writeq(val64, &bar0->swapper_ctrl);
 #else
@@ -3588,7 +3791,7 @@ static int s2io_set_swapper(struct s2io_
 		 SWAPPER_CTRL_RXF_W_FE |
 		 SWAPPER_CTRL_XMSI_FE |
 		 SWAPPER_CTRL_STATS_FE | SWAPPER_CTRL_STATS_SE);
-	if (sp->intr_type == INTA)
+	if (sp->config.intr_type == INTA)
 		val64 |= SWAPPER_CTRL_XMSI_SE;
 	writeq(val64, &bar0->swapper_ctrl);
 #endif
@@ -3862,7 +4065,7 @@ static int s2io_open(struct net_device *
 	netif_carrier_off(dev);
 	sp->last_link_state = 0;
 
-	if (sp->intr_type == MSI_X) {
+	if (sp->config.intr_type == MSI_X) {
 		int ret = s2io_enable_msi_x(sp);
 
 		if (!ret) {
@@ -3894,12 +4097,12 @@ static int s2io_open(struct net_device *
 			DBG_PRINT(ERR_DBG,
 			  "%s: MSI-X requested but failed to enable\n",
 			  dev->name);
-			sp->intr_type = INTA;
+			sp->config.intr_type = INTA;
 		}
 	}
 
 	/* NAPI doesn't work well with MSI(X) */
-	 if (sp->intr_type != INTA) {
+	 if (sp->config.intr_type != INTA) {
 		if(sp->config.napi)
 			sp->config.napi = 0;
 	}
@@ -3923,7 +4126,7 @@ static int s2io_open(struct net_device *
 	return 0;
 
 hw_init_failed:
-	if (sp->intr_type == MSI_X) {
+	if (sp->config.intr_type == MSI_X) {
 		if (sp->entries) {
 			kfree(sp->entries);
 			sp->mac_control.stats_info->sw_stat.mem_freed 
@@ -3999,7 +4202,7 @@ static int s2io_xmit(struct sk_buff *skb
 		DBG_PRINT(TX_DBG, "%s:Buffer has no data..\n", dev->name);
 		dev_kfree_skb_any(skb);
 		return 0;
-}
+	}
 
 	spin_lock_irqsave(&sp->tx_lock, flags);
 	if (atomic_read(&sp->card_state) == CARD_DOWN) {
@@ -4154,9 +4357,11 @@ static void
 s2io_alarm_handle(unsigned long data)
 {
 	struct s2io_nic *sp = (struct s2io_nic *)data;
+	struct net_device *dev = sp->dev;
 
-	alarm_intr_handler(sp);
-	mod_timer(&sp->alarm_timer, jiffies + HZ / 2);
+	s2io_handle_errors(dev);
+
+	mod_timer(&sp->alarm_timer, jiffies + HZ/2);
 }
 
 static int s2io_chk_rx_buffers(struct s2io_nic *sp, int rng_n)
@@ -4195,6 +4400,11 @@ static irqreturn_t s2io_msix_ring_handle
 
 	atomic_inc(&sp->isr_cnt);
 
+	if (unlikely(atomic_read(&sp->card_state) == CARD_DOWN)){
+		atomic_dec(&sp->isr_cnt);
+		return IRQ_HANDLED;
+	}
+
 	rx_intr_handler(ring);
 	s2io_chk_rx_buffers(sp, ring->ring_no);
 
@@ -4208,6 +4418,12 @@ static irqreturn_t s2io_msix_fifo_handle
 	struct s2io_nic *sp = fifo->nic;
 
 	atomic_inc(&sp->isr_cnt);
+
+	if (unlikely(atomic_read(&sp->card_state) == CARD_DOWN)){
+		atomic_dec(&sp->isr_cnt);
+		return IRQ_HANDLED;
+	}
+
 	tx_intr_handler(fifo);
 	atomic_dec(&sp->isr_cnt);
 	return IRQ_HANDLED;
@@ -4273,6 +4489,383 @@ static void s2io_txpic_intr_handle(struc
 	val64 = readq(&bar0->gpio_int_mask);
 }
 
+/*
+ * Checking for reset and SERR bits in the error registers
+ */
+static void s2io_handle_errors(void * dev_id)
+{
+	struct net_device *dev = (struct net_device *) dev_id;
+	struct s2io_nic *sp = dev->priv;
+	struct XENA_dev_config __iomem *bar0 = sp->bar0;
+	u64 temp64 = 0,val64=0;
+	int i = 0;
+
+	struct swStat *sw_stat = &sp->mac_control.stats_info->sw_stat;
+	struct xpakStat *stats = &sp->mac_control.stats_info->xpak_stat;
+
+	if (unlikely(atomic_read(&sp->card_state) == CARD_DOWN))
+		return;
+
+	if (pci_channel_offline(sp->pdev))
+		return;
+
+	memset(&sw_stat->ring_full_cnt, 0,
+		sizeof(sw_stat->ring_full_cnt));
+
+	/* Handling the XPAK counters update */
+	if(stats->xpak_timer_count < 72000) {
+		/* waiting for an hour */
+		stats->xpak_timer_count++;
+	} else {
+		s2io_updt_xpak_counter(dev);
+		/* reset the count to zero */
+		stats->xpak_timer_count = 0;
+	}
+
+	/* Handling link status change error Intr */
+	if (s2io_link_fault_indication(sp) == MAC_RMAC_ERR_TIMER) {
+		val64 = readq(&bar0->mac_rmac_err_reg);
+		writeq(val64, &bar0->mac_rmac_err_reg);
+		if (val64 & RMAC_LINK_STATE_CHANGE_INT)
+			schedule_work(&sp->set_link_task);
+	}
+
+	/* In case of a serious error, the device will be Reset. */
+	val64 = readq(&bar0->serr_source);
+	if (val64 & SERR_SOURCE_ANY) {
+		sw_stat->serious_err_cnt++;
+		goto reset;
+	}
+
+	/* Check for data parity error */
+	val64 = readq(&bar0->gpio_int_reg);
+	if (val64 & GPIO_INT_REG_DP_ERR_INT) {
+		sw_stat->parity_err_cnt++;
+		goto reset;
+	}
+
+	/* Check for ring full counter */
+	if (sp->device_type == XFRAME_II_DEVICE) {
+		val64 = readq(&bar0->ring_bump_counter1);
+		for (i=0; i<4; i++) {
+			temp64 = ( val64 & vBIT(0xFFFF,(i*16),16));
+			temp64 >>= 64 - ((i+1)*16);
+			sw_stat->ring_full_cnt[i] += temp64;
+		}
+
+		val64 = readq(&bar0->ring_bump_counter2);
+		for (i=0; i<4; i++) {
+			temp64 = ( val64 & vBIT(0xFFFF,(i*16),16));
+			temp64 >>= 64 - ((i+1)*16);
+			 sw_stat->ring_full_cnt[i+4] += temp64;
+		}
+	}
+
+	val64 = readq(&bar0->txdma_int_status);
+	/*check for pfc_err*/
+	if (val64 & TXDMA_PFC_INT) {
+		val64 = readq(&bar0->pfc_err_reg);
+		temp64 = PFC_ECC_DB_ERR | PFC_SM_ERR_ALARM
+			| PFC_MISC_0_ERR | PFC_MISC_1_ERR
+			| PFC_PCIX_ERR;
+		if ( val64 & temp64 ) {
+			writeq(val64, &bar0->pfc_err_reg);
+			sw_stat->pfc_err_cnt++;
+			goto reset;
+		}
+
+		temp64 = PFC_ECC_SG_ERR;
+		if (val64 & temp64) {
+			sw_stat->pfc_err_cnt++;
+			writeq(val64, &bar0->pfc_err_reg);
+		}
+	}
+
+	/*check for tda_err*/
+	if (val64 & TXDMA_TDA_INT) {
+		val64 = readq(&bar0->tda_err_reg);
+		temp64 = TDA_Fn_ECC_DB_ERR | TDA_SM0_ERR_ALARM
+			| TDA_SM1_ERR_ALARM;
+		if ( val64 & temp64 ) {
+			writeq(val64, &bar0->tda_err_reg);
+			sw_stat->tda_err_cnt++;
+			goto reset;
+		}
+
+		temp64 = TDA_Fn_ECC_SG_ERR | TDA_PCIX_ERR;
+		if (val64 & temp64) {
+			sw_stat->tda_err_cnt++;
+			writeq(val64, &bar0->tda_err_reg);
+		}
+	}
+	/*check for pcc_err*/
+	if (val64 & TXDMA_PCC_INT) {
+		val64 = readq(&bar0->pcc_err_reg);
+		temp64 = PCC_TXB_ECC_DB_ERR
+			| PCC_SM_ERR_ALARM | PCC_WR_ERR_ALARM
+			| PCC_N_SERR | PCC_6_COF_OV_ERR
+			| PCC_7_COF_OV_ERR | PCC_6_LSO_OV_ERR
+			| PCC_7_LSO_OV_ERR | PCC_FB_ECC_DB_ERR
+			| PCC_TXB_ECC_DB_ERR;
+		if ( val64 & temp64 ) {
+			writeq(val64, &bar0->pcc_err_reg);
+			sw_stat->pcc_err_cnt++;
+			goto reset;
+		}
+
+		if (val64 & (PCC_FB_ECC_SG_ERR | PCC_TXB_ECC_SG_ERR)) {
+			sw_stat->pcc_err_cnt++;
+			writeq(val64, &bar0->pcc_err_reg);
+		}
+	}
+
+	/*check for tti_err*/
+	if (val64 & TXDMA_TTI_INT) {
+		val64 = readq(&bar0->tti_err_reg);
+		temp64 = TTI_SM_ERR_ALARM;
+		if ( val64 & temp64 ) {
+			writeq(val64, &bar0->tti_err_reg);
+			sw_stat->tti_err_cnt++;
+			goto reset;
+		}
+
+		temp64 = TTI_ECC_SG_ERR | TTI_ECC_DB_ERR;
+		if (val64 & temp64) {
+			sw_stat->tti_err_cnt++;
+			writeq(val64, &bar0->tti_err_reg);
+		}
+	}
+
+	/*check for lso_err*/
+	if (val64 & TXDMA_LSO_INT) {
+		val64 = readq(&bar0->lso_err_reg);
+		temp64 = LSO6_ABORT | LSO7_ABORT
+			| LSO6_SM_ERR_ALARM | LSO7_SM_ERR_ALARM;
+		if ( val64 & temp64 ) {
+			writeq(val64, &bar0->lso_err_reg);
+			sw_stat->lso_err_cnt++;
+			goto reset;
+		}
+
+		temp64 = LSO6_SEND_OFLOW | LSO7_SEND_OFLOW;
+		if (val64 & temp64) {
+			sw_stat->lso_err_cnt++;
+			writeq(val64, &bar0->lso_err_reg);
+		}
+	}
+
+	/*check for tpa_err*/
+	if (val64 & TXDMA_TPA_INT) {
+		val64 = readq(&bar0->tpa_err_reg);
+		temp64 = TPA_SM_ERR_ALARM;
+		if ( val64 & temp64 ) {
+			writeq(val64, &bar0->tpa_err_reg);
+			sw_stat->tpa_err_cnt++;
+			goto reset;
+		}
+
+		temp64 = TPA_TX_FRM_DROP;
+		if (val64 & temp64) {
+			sw_stat->tpa_err_cnt++;
+			writeq(val64, &bar0->tpa_err_reg);
+		}
+	}
+
+	/*check for sm_err*/
+	if (val64 & TXDMA_SM_INT) {
+		val64 = readq(&bar0->sm_err_reg);
+		temp64 = SM_SM_ERR_ALARM;
+		if ( val64 & temp64 ) {
+			writeq(val64, &bar0->sm_err_reg);
+			sw_stat->sm_err_cnt++;
+			goto reset;
+		}
+	}
+
+	val64 = readq(&bar0->mac_int_status);
+	if (val64 & MAC_INT_STATUS_TMAC_INT) {
+		val64 = readq(&bar0->mac_tmac_err_reg);
+		temp64 = TMAC_TX_BUF_OVRN | TMAC_TX_SM_ERR;
+		if ( val64 & temp64) {
+			writeq(val64, &bar0->mac_tmac_err_reg);
+			sw_stat->mac_tmac_err_cnt++;
+			goto reset;
+		}
+
+		temp64 = TMAC_ECC_SG_ERR | TMAC_ECC_DB_ERR
+			| TMAC_DESC_ECC_SG_ERR | TMAC_DESC_ECC_DB_ERR;
+		if (val64 & temp64) {
+			sw_stat->mac_tmac_err_cnt++;
+			writeq(val64, &bar0->mac_tmac_err_reg);
+		}
+	}
+
+	val64 = readq(&bar0->xgxs_int_status);
+	if (val64 & XGXS_INT_STATUS_TXGXS) {
+		val64 = readq(&bar0->xgxs_txgxs_err_reg);
+		temp64 = TXGXS_ESTORE_UFLOW | TXGXS_TX_SM_ERR;
+		if ( val64 & temp64) {
+			writeq(val64, &bar0->xgxs_txgxs_err_reg);
+			sw_stat->xgxs_txgxs_err_cnt++;
+			goto reset;
+		}
+
+		temp64 = TXGXS_ECC_SG_ERR | TXGXS_ECC_DB_ERR;
+		if (val64 & temp64) {
+			sw_stat->xgxs_txgxs_err_cnt++;
+			writeq(val64, &bar0->xgxs_txgxs_err_reg);
+		}
+	}
+
+	val64 = readq(&bar0->rxdma_int_status);
+	if (val64 & RXDMA_INT_RC_INT_M) {
+		val64 = readq(&bar0->rc_err_reg);
+		temp64 = RC_PRCn_ECC_DB_ERR | RC_FTC_ECC_DB_ERR
+			| RC_PRCn_SM_ERR_ALARM |RC_FTC_SM_ERR_ALARM;
+		if ( val64 & temp64 ) {
+			writeq(val64, &bar0->rc_err_reg);
+			sw_stat->rc_err_cnt++;
+			goto reset;
+		}
+
+		temp64 = RC_PRCn_ECC_SG_ERR | RC_FTC_ECC_SG_ERR
+			| RC_RDA_FAIL_WR_Rn;
+		if (val64 & temp64) {
+			sw_stat->rc_err_cnt++;
+			writeq(val64, &bar0->rc_err_reg);
+		}
+
+		val64 = readq(&bar0->prc_pcix_err_reg);
+		temp64 = PRC_PCI_AB_RD_Rn | PRC_PCI_AB_WR_Rn
+			| PRC_PCI_AB_F_WR_Rn;
+		if ( val64 & temp64 ) {
+			writeq(val64, &bar0->prc_pcix_err_reg);
+			sw_stat->prc_pcix_err_cnt++;
+			goto reset;
+		}
+
+		temp64 = PRC_PCI_DP_RD_Rn | PRC_PCI_DP_WR_Rn
+			| PRC_PCI_DP_F_WR_Rn;
+		if (val64 & temp64) {
+			sw_stat->prc_pcix_err_cnt++;
+			writeq(val64, &bar0->prc_pcix_err_reg);
+		}
+	}
+
+	if (val64 & RXDMA_INT_RPA_INT_M) {
+		val64 = readq(&bar0->rpa_err_reg);
+		temp64 = RPA_SM_ERR_ALARM | RPA_CREDIT_ERR;
+		if ( val64 & temp64 ) {
+			writeq(val64, &bar0->rpa_err_reg);
+			sw_stat->rpa_err_cnt++;
+			goto reset;
+		}
+
+		temp64 = RPA_ECC_SG_ERR | RPA_ECC_DB_ERR;
+		if (val64 & temp64) {
+			sw_stat->rpa_err_cnt++;
+			writeq(val64, &bar0->rpa_err_reg);
+		}
+	}
+
+	if (val64 & RXDMA_INT_RDA_INT_M) {
+		val64 = readq(&bar0->rda_err_reg);
+		temp64 = RDA_RXDn_ECC_DB_ERR | RDA_FRM_ECC_DB_N_AERR
+			| RDA_SM1_ERR_ALARM | RDA_SM0_ERR_ALARM
+			| RDA_RXD_ECC_DB_SERR;
+		if ( val64 & temp64 ) {
+			writeq(val64, &bar0->rda_err_reg);
+			sw_stat->rda_err_cnt++;
+			goto reset;
+		}
+
+		temp64 = RDA_RXDn_ECC_SG_ERR | RDA_FRM_ECC_SG_ERR
+			| RDA_MISC_ERR | RDA_PCIX_ERR;
+		if (val64 & temp64) {
+			sw_stat->rda_err_cnt++;
+			writeq(val64, &bar0->rda_err_reg);
+		}
+	}
+
+	if (val64 & RXDMA_INT_RTI_INT_M) {
+		val64 = readq(&bar0->rti_err_reg);
+		temp64 = RTI_SM_ERR_ALARM;
+		if ( val64 & temp64 ) {
+			writeq(val64, &bar0->rti_err_reg);
+			sw_stat->rti_err_cnt++;
+			goto reset;
+		}
+
+		temp64 = RTI_ECC_SG_ERR | RTI_ECC_DB_ERR;
+		if (val64 & temp64) {
+			sw_stat->rti_err_cnt++;
+			writeq(val64, &bar0->rti_err_reg);
+		}
+	}
+
+	val64 = readq(&bar0->mac_int_status);
+	if (val64 & MAC_INT_STATUS_RMAC_INT) {
+		val64 = readq(&bar0->mac_rmac_err_reg);
+		temp64 = RMAC_RX_BUFF_OVRN | RMAC_RX_SM_ERR;
+		if ( val64 & temp64 ) {
+			writeq(val64, &bar0->mac_rmac_err_reg);
+			sw_stat->mac_rmac_err_cnt++;
+			goto reset;
+		}
+
+		temp64 = RMAC_UNUSED_INT|RMAC_SINGLE_ECC_ERR|
+			RMAC_DOUBLE_ECC_ERR;
+		if (val64 & temp64) {
+			sw_stat->mac_rmac_err_cnt++;
+			writeq(val64, &bar0->mac_rmac_err_reg);
+		}
+	}
+
+	val64 = readq(&bar0->xgxs_int_status);
+	if (val64 & XGXS_INT_STATUS_RXGXS) {
+		val64 = readq(&bar0->xgxs_rxgxs_err_reg);
+		temp64 = RXGXS_ESTORE_OFLOW | RXGXS_RX_SM_ERR;
+		if ( val64 & temp64 ) {
+			writeq(val64, &bar0->xgxs_rxgxs_err_reg);
+			sw_stat->xgxs_rxgxs_err_cnt++;
+			goto reset;
+		}
+	}
+
+	val64 = readq(&bar0->mc_int_status);
+	if(val64 & MC_INT_STATUS_MC_INT) {
+		val64 = readq(&bar0->mc_err_reg);
+		temp64 = MC_ERR_REG_SM_ERR;
+		if ( val64 & temp64 ) {
+			writeq(val64, &bar0->mc_err_reg);
+			sw_stat->mc_err_cnt++;
+			goto reset;
+		}
+
+		/* Handling Ecc errors */
+		if (val64 & (MC_ERR_REG_ECC_ALL_SNG | MC_ERR_REG_ECC_ALL_DBL)) {
+			writeq(val64, &bar0->mc_err_reg);
+			if (val64 & MC_ERR_REG_ECC_ALL_DBL) {
+				sw_stat->double_ecc_errs++;
+				if (sp->device_type != XFRAME_II_DEVICE) {
+					/* Reset XframeI only if critical error */
+					if (val64 & (MC_ERR_REG_MIRI_ECC_DB_ERR_0 |
+							MC_ERR_REG_MIRI_ECC_DB_ERR_1))
+								goto reset;
+					}
+			} else
+				sw_stat->single_ecc_errs++;
+		}
+	}
+	return;
+
+reset:
+	netif_stop_queue(dev);
+	schedule_work(&sp->rst_timer_task);
+	sw_stat->soft_reset_cnt++;
+	return;
+}
+
 /**
  *  s2io_isr - ISR handler of the device .
  *  @irq: the irq of the device.
@@ -4301,6 +4894,12 @@ static irqreturn_t s2io_isr(int irq, voi
 		return IRQ_NONE;
 
 	atomic_inc(&sp->isr_cnt);
+
+	if (unlikely(atomic_read(&sp->card_state) == CARD_DOWN)) {
+		atomic_dec(&sp->isr_cnt);
+		return IRQ_NONE;
+	}
+
 	mac_control = &sp->mac_control;
 	config = &sp->config;
 
@@ -4310,71 +4909,74 @@ static irqreturn_t s2io_isr(int irq, voi
 	 * 1. Rx of packet.
 	 * 2. Tx complete.
 	 * 3. Link down.
-	 * 4. Error in any functional blocks of the NIC.
 	 */
 	reason = readq(&bar0->general_int_status);
 
-	if (!reason) {
-		/* The interrupt was not raised by us. */
-		atomic_dec(&sp->isr_cnt);
-		return IRQ_NONE;
-	}
-	else if (unlikely(reason == S2IO_MINUS_ONE) ) {
-		/* Disable device and get out */
+	if ( unlikely(reason == S2IO_MINUS_ONE) ) {
+		/* Nothing much can be done. Get out */
 		atomic_dec(&sp->isr_cnt);
-		return IRQ_NONE;
+		return IRQ_HANDLED;
 	}
 
-	if (napi) {
-		if (reason & GEN_INTR_RXTRAFFIC) {
-			if ( likely ( netif_rx_schedule_prep(dev)) ) {
-				__netif_rx_schedule(dev);
-				writeq(S2IO_MINUS_ONE, &bar0->rx_traffic_mask);
+	if (reason & (GEN_INTR_RXTRAFFIC |
+		GEN_INTR_TXTRAFFIC | GEN_INTR_TXPIC))
+	{
+		writeq(S2IO_MINUS_ONE, &bar0->general_int_mask);
+
+		if (config->napi) {
+			if (reason & GEN_INTR_RXTRAFFIC) {
+				if ( likely (netif_rx_schedule_prep(dev)) ) {
+					__netif_rx_schedule(dev);
+					writeq(S2IO_MINUS_ONE, &bar0->rx_traffic_mask);
+				} else
+					writeq(S2IO_MINUS_ONE, &bar0->rx_traffic_int);
 			}
-			else
+		} else {
+			/*
+			 * rx_traffic_int reg is an R1 register, writing all 1's
+			 * will ensure that the actual interrupt causing bit get's
+			 * cleared and hence a read can be avoided.
+			 */
+			if (reason & GEN_INTR_RXTRAFFIC)
 				writeq(S2IO_MINUS_ONE, &bar0->rx_traffic_int);
+
+			for (i = 0; i < config->rx_ring_num; i++)
+				rx_intr_handler(&mac_control->rings[i]);
 		}
-	} else {
+
 		/*
-		 * Rx handler is called by default, without checking for the
-		 * cause of interrupt.
-		 * rx_traffic_int reg is an R1 register, writing all 1's
+		 * tx_traffic_int reg is an R1 register, writing all 1's
 		 * will ensure that the actual interrupt causing bit get's
 		 * cleared and hence a read can be avoided.
 		 */
-		if (reason & GEN_INTR_RXTRAFFIC)
-			writeq(S2IO_MINUS_ONE, &bar0->rx_traffic_int);
+		if (reason & GEN_INTR_TXTRAFFIC)
+			writeq(S2IO_MINUS_ONE, &bar0->tx_traffic_int);
 
-		for (i = 0; i < config->rx_ring_num; i++) {
-			rx_intr_handler(&mac_control->rings[i]);
-		}
-	}
+		for (i = 0; i < config->tx_fifo_num; i++)
+			tx_intr_handler(&mac_control->fifos[i]);
 
-	/*
-	 * tx_traffic_int reg is an R1 register, writing all 1's
-	 * will ensure that the actual interrupt causing bit get's
-	 * cleared and hence a read can be avoided.
-	 */
-	if (reason & GEN_INTR_TXTRAFFIC)
-		writeq(S2IO_MINUS_ONE, &bar0->tx_traffic_int);
+		if (reason & GEN_INTR_TXPIC)
+			s2io_txpic_intr_handle(sp);
 
-	for (i = 0; i < config->tx_fifo_num; i++)
-		tx_intr_handler(&mac_control->fifos[i]);
+		/*
+		 * Reallocate the buffers from the interrupt handler itself.
+		 */
+		if (!config->napi) {
+			for (i = 0; i < config->rx_ring_num; i++)
+				s2io_chk_rx_buffers(sp, i);
+		}
+		writeq(sp->general_int_mask, &bar0->general_int_mask);
+		readl(&bar0->general_int_status);
 
-	if (reason & GEN_INTR_TXPIC)
-		s2io_txpic_intr_handle(sp);
-	/*
-	 * If the Rx buffer count is below the panic threshold then
-	 * reallocate the buffers from the interrupt handler itself,
-	 * else schedule a tasklet to reallocate the buffers.
-	 */
-	if (!napi) {
-		for (i = 0; i < config->rx_ring_num; i++)
-			s2io_chk_rx_buffers(sp, i);
-	}
+		atomic_dec(&sp->isr_cnt);
+		return IRQ_HANDLED;
 
-	writeq(0, &bar0->general_int_mask);
-	readl(&bar0->general_int_status);
+	}
+	else if (!reason) {
+		/* The interrupt was not raised by us */
+		atomic_dec(&sp->isr_cnt);
+		return IRQ_NONE;
+	}
 
 	atomic_dec(&sp->isr_cnt);
 	return IRQ_HANDLED;
@@ -4403,7 +5005,7 @@ static void s2io_updt_stats(struct s2io_
 			if (cnt == 5)
 				break; /* Updt failed */
 		} while(1);
-	} 
+	}
 }
 
 /**
@@ -4900,7 +5502,7 @@ static void s2io_ethtool_gringparam(stru
 	ering->tx_max_pending = MAX_TX_DESC;
 	for (i = 0 ; i < sp->config.tx_fifo_num ; i++) 
 		tx_desc_count += sp->config.tx_cfg[i].fifo_len;
-	
+
 	DBG_PRINT(INFO_DBG,"\nmax txds : %d\n",sp->config.max_txds);
 	ering->tx_pending = tx_desc_count;
 	rx_desc_count = 0;
@@ -5662,7 +6264,7 @@ static void s2io_get_ethtool_stats(struc
 				   struct ethtool_stats *estats,
 				   u64 * tmp_stats)
 {
-	int i = 0;
+	int i = 0, k = 0;
 	struct s2io_nic *sp = dev->priv;
 	struct stat_block *stat_info = sp->mac_control.stats_info;
 
@@ -5857,7 +6459,8 @@ static void s2io_get_ethtool_stats(struc
 	tmp_stats[i++] = stat_info->sw_stat.serious_err_cnt;
 	tmp_stats[i++] = stat_info->sw_stat.soft_reset_cnt;
 	tmp_stats[i++] = stat_info->sw_stat.fifo_full_cnt;
-	tmp_stats[i++] = stat_info->sw_stat.ring_full_cnt;
+	for (k = 0; k < MAX_RX_RINGS; k++)
+		tmp_stats[i++] = stat_info->sw_stat.ring_full_cnt[k];
 	tmp_stats[i++] = stat_info->xpak_stat.alarm_transceiver_temp_high;
 	tmp_stats[i++] = stat_info->xpak_stat.alarm_transceiver_temp_low;
 	tmp_stats[i++] = stat_info->xpak_stat.alarm_laser_bias_current_high;
@@ -5914,6 +6517,23 @@ static void s2io_get_ethtool_stats(struc
 	tmp_stats[i++] = stat_info->sw_stat.rx_buf_size_err_cnt;
 	tmp_stats[i++] = stat_info->sw_stat.rx_rxd_corrupt_cnt;
 	tmp_stats[i++] = stat_info->sw_stat.rx_unkn_err_cnt;
+	tmp_stats[i++] = stat_info->sw_stat.tda_err_cnt;
+	tmp_stats[i++] = stat_info->sw_stat.pfc_err_cnt;
+	tmp_stats[i++] = stat_info->sw_stat.pcc_err_cnt;
+	tmp_stats[i++] = stat_info->sw_stat.tti_err_cnt;
+	tmp_stats[i++] = stat_info->sw_stat.tpa_err_cnt;
+	tmp_stats[i++] = stat_info->sw_stat.sm_err_cnt;
+	tmp_stats[i++] = stat_info->sw_stat.lso_err_cnt;
+	tmp_stats[i++] = stat_info->sw_stat.mac_tmac_err_cnt;
+	tmp_stats[i++] = stat_info->sw_stat.mac_rmac_err_cnt;
+	tmp_stats[i++] = stat_info->sw_stat.xgxs_txgxs_err_cnt;
+	tmp_stats[i++] = stat_info->sw_stat.xgxs_rxgxs_err_cnt;
+	tmp_stats[i++] = stat_info->sw_stat.rc_err_cnt;
+	tmp_stats[i++] = stat_info->sw_stat.prc_pcix_err_cnt;
+	tmp_stats[i++] = stat_info->sw_stat.rpa_err_cnt;
+	tmp_stats[i++] = stat_info->sw_stat.rda_err_cnt;
+	tmp_stats[i++] = stat_info->sw_stat.rti_err_cnt;
+	tmp_stats[i++] = stat_info->sw_stat.mc_err_cnt;
 }
 
 static int s2io_ethtool_get_regs_len(struct net_device *dev)
@@ -6404,18 +7024,18 @@ static int s2io_add_isr(struct s2io_nic 
 	struct net_device *dev = sp->dev;
 	int err = 0;
 
-	if (sp->intr_type == MSI_X)
+	if (sp->config.intr_type == MSI_X)
 		ret = s2io_enable_msi_x(sp);
 	if (ret) {
 		DBG_PRINT(ERR_DBG, "%s: Defaulting to INTA\n", dev->name);
-		sp->intr_type = INTA;
+		sp->config.intr_type = INTA;
 	}
 
 	/* Store the values of the MSIX table in the struct s2io_nic structure */
 	store_xmsi_data(sp);
 
 	/* After proper initialization of H/W, register ISR */
-	if (sp->intr_type == MSI_X) {
+	if (sp->config.intr_type == MSI_X) {
 		int i, msix_tx_cnt=0,msix_rx_cnt=0;
 
 		for (i=1; (sp->s2io_entries[i].in_use == MSIX_FLG); i++) {
@@ -6467,7 +7087,7 @@ static int s2io_add_isr(struct s2io_nic 
 		printk("MSI-X-TX %d entries enabled\n",msix_tx_cnt);
 		printk("MSI-X-RX %d entries enabled\n",msix_rx_cnt);
 	}
-	if (sp->intr_type == INTA) {
+	if (sp->config.intr_type == INTA) {
 		err = request_irq((int) sp->pdev->irq, s2io_isr, IRQF_SHARED,
 				sp->name, dev);
 		if (err) {
@@ -6484,7 +7104,15 @@ static void s2io_rem_isr(struct s2io_nic
 	struct net_device *dev = sp->dev;
 	struct swStat *stats = &sp->mac_control.stats_info->sw_stat;
 
-	if (sp->intr_type == MSI_X) {
+	/* Waiting till all Interrupt handlers are complete */
+	do {
+		if (!atomic_read(&sp->isr_cnt))
+			break;
+		msleep(10);
+		cnt++;
+	} while(cnt < 5);
+
+	if (sp->config.intr_type == MSI_X) {
 		int i;
 		u16 msi_control;
 
@@ -6513,14 +7141,6 @@ static void s2io_rem_isr(struct s2io_nic
 	} else {
 		free_irq(sp->pdev->irq, dev);
 	}
-	/* Waiting till all Interrupt handlers are complete */
-	cnt = 0;
-	do {
-		msleep(10);
-		if (!atomic_read(&sp->isr_cnt))
-			break;
-		cnt++;
-	} while(cnt < 5);
 }
 
 static void do_s2io_card_down(struct s2io_nic * sp, int do_io)
@@ -6657,7 +7277,7 @@ static int s2io_card_up(struct s2io_nic 
 
 	/* Add interrupt service routine */
 	if (s2io_add_isr(sp) != 0) {
-		if (sp->intr_type == MSI_X)
+		if (sp->config.intr_type == MSI_X)
 			s2io_rem_isr(sp);
 		s2io_reset(sp);
 		free_rx_buffers(sp);
@@ -6670,16 +7290,16 @@ static int s2io_card_up(struct s2io_nic 
 	tasklet_init(&sp->task, s2io_tasklet, (unsigned long) dev);
 
 	/*  Enable select interrupts */
-	if (sp->intr_type != INTA)
+	en_dis_err_alarms(sp, ENA_ALL_INTRS, ENABLE_INTRS);
+
+	if (sp->config.intr_type != INTA)
 		en_dis_able_nic_intrs(sp, ENA_ALL_INTRS, DISABLE_INTRS);
 	else {
 		interruptible = TX_TRAFFIC_INTR | RX_TRAFFIC_INTR;
-		interruptible |= TX_PIC_INTR | RX_PIC_INTR;
-		interruptible |= TX_MAC_INTR | RX_MAC_INTR;
+		interruptible |= TX_PIC_INTR;
 		en_dis_able_nic_intrs(sp, interruptible, ENABLE_INTRS);
 	}
 
-
 	atomic_set(&sp->card_state, CARD_UP);
 	return 0;
 }
@@ -7051,19 +7671,12 @@ static int s2io_verify_parm(struct pci_d
 	if (*dev_intr_type != INTA)
 		napi = 0;
 
-#ifndef CONFIG_PCI_MSI
-	if (*dev_intr_type != INTA) {
-		DBG_PRINT(ERR_DBG, "s2io: This kernel does not support"
-			  "MSI/MSI-X. Defaulting to INTA\n");
-		*dev_intr_type = INTA;
-	}
-#else
 	if ((*dev_intr_type != INTA) && (*dev_intr_type != MSI_X)) {
 		DBG_PRINT(ERR_DBG, "s2io: Wrong intr_type requested. "
 			  "Defaulting to INTA\n");
 		*dev_intr_type = INTA;
 	}
-#endif
+
 	if ((*dev_intr_type == MSI_X) &&
 			((pdev->device != PCI_DEVICE_ID_HERC_WIN) &&
 			(pdev->device != PCI_DEVICE_ID_HERC_UNI))) {
@@ -7198,7 +7811,7 @@ s2io_init_nic(struct pci_dev *pdev, cons
 	if (rx_ring_mode == 2)
 		sp->rxd_mode = RXD_MODE_3B;
 
-	sp->intr_type = dev_intr_type;
+	sp->config.intr_type = dev_intr_type;
 
 	if ((pdev->device == PCI_DEVICE_ID_HERC_WIN) ||
 		(pdev->device == PCI_DEVICE_ID_HERC_UNI))
@@ -7221,6 +7834,8 @@ s2io_init_nic(struct pci_dev *pdev, cons
 	mac_control = &sp->mac_control;
 	config = &sp->config;
 
+	config->napi = napi;
+
 	/* Tx side parameters. */
 	config->tx_fifo_num = tx_fifo_num;
 	for (i = 0; i < MAX_TX_FIFOS; i++) {
@@ -7478,7 +8093,7 @@ s2io_init_nic(struct pci_dev *pdev, cons
 
 	if (napi)
 		DBG_PRINT(ERR_DBG, "%s: NAPI enabled\n", dev->name);
-	switch(sp->intr_type) {
+	switch(sp->config.intr_type) {
 		case INTA:
 		    DBG_PRINT(ERR_DBG, "%s: Interrupt type INTA\n", dev->name);
 		    break;
diff -Nurp 2.0.26.1/drivers/net/s2io.h 2.0.26.2/drivers/net/s2io.h
--- 2.0.26.1/drivers/net/s2io.h	2007-08-03 15:09:15.000000000 -0700
+++ 2.0.26.2/drivers/net/s2io.h	2007-08-03 17:45:06.000000000 -0700
@@ -91,7 +91,7 @@ struct swStat {
 	unsigned long long serious_err_cnt;
 	unsigned long long soft_reset_cnt;
 	unsigned long long fifo_full_cnt;
-	unsigned long long ring_full_cnt;
+	unsigned long long ring_full_cnt[8];
 	/* LRO statistics */
 	unsigned long long clubbed_frms_cnt;
 	unsigned long long sending_both;
@@ -126,6 +126,25 @@ struct swStat {
 	unsigned long long rx_buf_size_err_cnt;
 	unsigned long long rx_rxd_corrupt_cnt;
 	unsigned long long rx_unkn_err_cnt;
+
+	/* Error/alarm statistics*/
+	unsigned long long tda_err_cnt;
+	unsigned long long pfc_err_cnt;
+	unsigned long long pcc_err_cnt;
+	unsigned long long tti_err_cnt;
+	unsigned long long lso_err_cnt;
+	unsigned long long tpa_err_cnt;
+	unsigned long long sm_err_cnt;
+	unsigned long long mac_tmac_err_cnt;
+	unsigned long long mac_rmac_err_cnt;
+	unsigned long long xgxs_txgxs_err_cnt;
+	unsigned long long xgxs_rxgxs_err_cnt;
+	unsigned long long rc_err_cnt;
+	unsigned long long prc_pcix_err_cnt;
+	unsigned long long rpa_err_cnt;
+	unsigned long long rda_err_cnt;
+	unsigned long long rti_err_cnt;
+	unsigned long long mc_err_cnt;
 };
 
 /* Xpak releated alarm and warnings */
@@ -886,12 +905,9 @@ struct s2io_nic {
 	u8		lro;
 	u16		lro_max_aggr_per_sess;
 
-#define INTA	0
-#define MSI_X	2
-	u8 intr_type;
-
 	spinlock_t	rx_lock;
 	atomic_t	isr_cnt;
+	u64		general_int_mask;
 	u64 *ufo_in_band_v;
 #define VPD_STRING_LEN 80
 	u8  product_name[VPD_STRING_LEN];
@@ -1016,7 +1032,7 @@ static void free_shared_mem(struct s2io_
 static int init_nic(struct s2io_nic *nic);
 static void rx_intr_handler(struct ring_info *ring_data);
 static void tx_intr_handler(struct fifo_info *fifo_data);
-static void alarm_intr_handler(struct s2io_nic *sp);
+static void s2io_handle_errors(void * dev_id);
 
 static int s2io_starter(void);
 static void s2io_closer(void);
diff -Nurp 2.0.26.1/drivers/net/s2io-regs.h 2.0.26.2/drivers/net/s2io-regs.h
--- 2.0.26.1/drivers/net/s2io-regs.h	2007-08-03 15:09:16.000000000 -0700
+++ 2.0.26.2/drivers/net/s2io-regs.h	2007-08-03 15:10:41.000000000 -0700
@@ -325,33 +325,65 @@ struct XENA_dev_config {
 #define TXDMA_TPA_INT                  BIT(5)
 #define TXDMA_SM_INT                   BIT(6)
 	u64 pfc_err_reg;
+#define PFC_ECC_SG_ERR			BIT(7)
+#define PFC_ECC_DB_ERR			BIT(15)
+#define PFC_SM_ERR_ALARM		BIT(23)
+#define PFC_MISC_0_ERR			BIT(31)
+#define PFC_MISC_1_ERR			BIT(32)
+#define PFC_PCIX_ERR			BIT(39)
 	u64 pfc_err_mask;
 	u64 pfc_err_alarm;
 
 	u64 tda_err_reg;
+#define TDA_Fn_ECC_SG_ERR		vBIT(0xff,0,8)
+#define TDA_Fn_ECC_DB_ERR		vBIT(0xff,8,8)
+#define TDA_SM0_ERR_ALARM		BIT(22)
+#define TDA_SM1_ERR_ALARM		BIT(23)
+#define TDA_PCIX_ERR			BIT(39)
 	u64 tda_err_mask;
 	u64 tda_err_alarm;
 
 	u64 pcc_err_reg;
-#define PCC_FB_ECC_DB_ERR		vBIT(0xFF, 16, 8)
+#define PCC_FB_ECC_SG_ERR		vBIT(0xFF,0,8)
+#define PCC_TXB_ECC_SG_ERR		vBIT(0xFF,8,8)
+#define PCC_FB_ECC_DB_ERR		vBIT(0xFF,16, 8)
+#define PCC_TXB_ECC_DB_ERR		vBIT(0xff,24,8)
+#define PCC_SM_ERR_ALARM		vBIT(0xff,32,8)
+#define PCC_WR_ERR_ALARM		vBIT(0xff,40,8)
+#define PCC_N_SERR			vBIT(0xff,48,8)
+#define PCC_6_COF_OV_ERR		BIT(56)
+#define PCC_7_COF_OV_ERR		BIT(57)
+#define PCC_6_LSO_OV_ERR		BIT(58)
+#define PCC_7_LSO_OV_ERR		BIT(59)
 #define PCC_ENABLE_FOUR			vBIT(0x0F,0,8)
-
 	u64 pcc_err_mask;
 	u64 pcc_err_alarm;
 
 	u64 tti_err_reg;
+#define TTI_ECC_SG_ERR			BIT(7)
+#define TTI_ECC_DB_ERR			BIT(15)
+#define TTI_SM_ERR_ALARM		BIT(23)
 	u64 tti_err_mask;
 	u64 tti_err_alarm;
 
 	u64 lso_err_reg;
+#define LSO6_SEND_OFLOW			BIT(12)
+#define LSO7_SEND_OFLOW			BIT(13)
+#define LSO6_ABORT			BIT(14)
+#define LSO7_ABORT			BIT(15)
+#define LSO6_SM_ERR_ALARM		BIT(22)
+#define LSO7_SM_ERR_ALARM		BIT(23)
 	u64 lso_err_mask;
 	u64 lso_err_alarm;
 
 	u64 tpa_err_reg;
+#define TPA_TX_FRM_DROP			BIT(7)
+#define TPA_SM_ERR_ALARM		BIT(23)
 	u64 tpa_err_mask;
 	u64 tpa_err_alarm;
 
 	u64 sm_err_reg;
+#define SM_SM_ERR_ALARM			BIT(15)
 	u64 sm_err_mask;
 	u64 sm_err_alarm;
 
@@ -450,22 +482,52 @@ struct XENA_dev_config {
 #define RXDMA_INT_RTI_INT_M            BIT(3)
 
 	u64 rda_err_reg;
+#define RDA_RXDn_ECC_SG_ERR		vBIT(0xFF,0,8)
+#define RDA_RXDn_ECC_DB_ERR		vBIT(0xFF,8,8)
+#define RDA_FRM_ECC_SG_ERR		BIT(23)
+#define RDA_FRM_ECC_DB_N_AERR		BIT(31)
+#define RDA_SM1_ERR_ALARM		BIT(38)
+#define RDA_SM0_ERR_ALARM		BIT(39)
+#define RDA_MISC_ERR			BIT(47)
+#define RDA_PCIX_ERR			BIT(55)
+#define RDA_RXD_ECC_DB_SERR		BIT(63)
 	u64 rda_err_mask;
 	u64 rda_err_alarm;
 
 	u64 rc_err_reg;
+#define RC_PRCn_ECC_SG_ERR		vBIT(0xFF,0,8)
+#define RC_PRCn_ECC_DB_ERR		vBIT(0xFF,8,8)
+#define RC_FTC_ECC_SG_ERR		BIT(23)
+#define RC_FTC_ECC_DB_ERR		BIT(31)
+#define RC_PRCn_SM_ERR_ALARM		vBIT(0xFF,32,8)
+#define RC_FTC_SM_ERR_ALARM		BIT(47)
+#define RC_RDA_FAIL_WR_Rn		vBIT(0xFF,48,8)
 	u64 rc_err_mask;
 	u64 rc_err_alarm;
 
 	u64 prc_pcix_err_reg;
+#define PRC_PCI_AB_RD_Rn		vBIT(0xFF,0,8)
+#define PRC_PCI_DP_RD_Rn		vBIT(0xFF,8,8)
+#define PRC_PCI_AB_WR_Rn		vBIT(0xFF,16,8)
+#define PRC_PCI_DP_WR_Rn		vBIT(0xFF,24,8)
+#define PRC_PCI_AB_F_WR_Rn		vBIT(0xFF,32,8)
+#define PRC_PCI_DP_F_WR_Rn		vBIT(0xFF,40,8)
 	u64 prc_pcix_err_mask;
 	u64 prc_pcix_err_alarm;
 
 	u64 rpa_err_reg;
+#define RPA_ECC_SG_ERR			BIT(7)
+#define RPA_ECC_DB_ERR			BIT(15)
+#define RPA_FLUSH_REQUEST		BIT(22)
+#define RPA_SM_ERR_ALARM		BIT(23)
+#define RPA_CREDIT_ERR			BIT(31)
 	u64 rpa_err_mask;
 	u64 rpa_err_alarm;
 
 	u64 rti_err_reg;
+#define RTI_ECC_SG_ERR			BIT(7)
+#define RTI_ECC_DB_ERR			BIT(15)
+#define RTI_SM_ERR_ALARM		BIT(23)
 	u64 rti_err_mask;
 	u64 rti_err_alarm;
 
@@ -582,17 +644,42 @@ struct XENA_dev_config {
 #define MAC_INT_STATUS_RMAC_INT            BIT(1)
 
 	u64 mac_tmac_err_reg;
-#define TMAC_ERR_REG_TMAC_ECC_DB_ERR       BIT(15)
-#define TMAC_ERR_REG_TMAC_TX_BUF_OVRN      BIT(23)
-#define TMAC_ERR_REG_TMAC_TX_CRI_ERR       BIT(31)
+#define TMAC_ECC_SG_ERR				BIT(7)
+#define TMAC_ECC_DB_ERR				BIT(15)
+#define TMAC_TX_BUF_OVRN			BIT(23)
+#define TMAC_TX_CRI_ERR				BIT(31)
+#define TMAC_TX_SM_ERR			 	BIT(39)
+#define TMAC_DESC_ECC_SG_ERR			BIT(47)
+#define TMAC_DESC_ECC_DB_ERR			BIT(55)
 	u64 mac_tmac_err_mask;
 	u64 mac_tmac_err_alarm;
 
 	u64 mac_rmac_err_reg;
-#define RMAC_ERR_REG_RX_BUFF_OVRN          BIT(0)
-#define RMAC_ERR_REG_RTS_ECC_DB_ERR        BIT(14)
-#define RMAC_ERR_REG_ECC_DB_ERR            BIT(15)
-#define RMAC_LINK_STATE_CHANGE_INT         BIT(31)
+#define RMAC_RX_BUFF_OVRN			BIT(0)
+#define RMAC_FRM_RCVD_INT			BIT(1)
+#define RMAC_UNUSED_INT				BIT(2)
+#define RMAC_RTS_PNUM_ECC_SG_ERR		BIT(5)
+#define RMAC_RTS_DS_ECC_SG_ERR			BIT(6)
+#define RMAC_RD_BUF_ECC_SG_ERR			BIT(7)
+#define RMAC_RTH_MAP_ECC_SG_ERR			BIT(8)
+#define RMAC_RTH_SPDM_ECC_SG_ERR		BIT(9)
+#define RMAC_RTS_VID_ECC_SG_ERR			BIT(10)
+#define RMAC_DA_SHADOW_ECC_SG_ERR		BIT(11)
+#define RMAC_RTS_PNUM_ECC_DB_ERR		BIT(13)
+#define RMAC_RTS_DS_ECC_DB_ERR			BIT(14)
+#define RMAC_RD_BUF_ECC_DB_ERR			BIT(15)
+#define RMAC_RTH_MAP_ECC_DB_ERR			BIT(16)
+#define RMAC_RTH_SPDM_ECC_DB_ERR		BIT(17)
+#define RMAC_RTS_VID_ECC_DB_ERR			BIT(18)
+#define RMAC_DA_SHADOW_ECC_DB_ERR		BIT(19)
+#define RMAC_LINK_STATE_CHANGE_INT		BIT(31)
+#define RMAC_RX_SM_ERR				BIT(39)
+#define RMAC_SINGLE_ECC_ERR			(BIT(5) | BIT(6) | BIT(7) |\
+						BIT(8)	| BIT(9) | BIT(10)|\
+						BIT(11))
+#define RMAC_DOUBLE_ECC_ERR			(BIT(13) | BIT(14) | BIT(15) |\
+						BIT(16)  | BIT(17) | BIT(18)|\
+						BIT(19))
 	u64 mac_rmac_err_mask;
 	u64 mac_rmac_err_alarm;
 
@@ -750,6 +837,8 @@ struct XENA_dev_config {
 					BIT(17) | BIT(19))
 #define MC_ERR_REG_ECC_ALL_DBL		   (BIT(10) | BIT(11) | BIT(12) |\
 					BIT(13) | BIT(18) | BIT(20))
+#define PLL_LOCK_N			BIT(39)
+
 	u64 mc_err_mask;
 	u64 mc_err_alarm;
 
@@ -823,11 +912,16 @@ struct XENA_dev_config {
 #define XGXS_INT_MASK_RXGXS                BIT(1)
 
 	u64 xgxs_txgxs_err_reg;
-#define TXGXS_ECC_DB_ERR                   BIT(15)
+#define TXGXS_ECC_SG_ERR		BIT(7)
+#define TXGXS_ECC_DB_ERR		BIT(15)
+#define TXGXS_ESTORE_UFLOW		BIT(31)
+#define TXGXS_TX_SM_ERR			BIT(39)
 	u64 xgxs_txgxs_err_mask;
 	u64 xgxs_txgxs_err_alarm;
 
 	u64 xgxs_rxgxs_err_reg;
+#define RXGXS_ESTORE_OFLOW		BIT(7)
+#define RXGXS_RX_SM_ERR			BIT(39)
 	u64 xgxs_rxgxs_err_mask;
 	u64 xgxs_rxgxs_err_alarm;
 



