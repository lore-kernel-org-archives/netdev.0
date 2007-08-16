From: Ramkrishna Vepa <ram.vepa@neterion.com>
Subject: [PATCH 2.6.24 1/5]S2io: Enable all the error and alarm indications
Date: 15 Aug 2007 17:12:11 -0700
Message-ID: <1187223130.23940.331.camel@flash>
Reply-To: ram.vepa@neterion.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, support@neterion.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:48999 "EHLO
	barracuda.s2io.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755521AbXHOWUi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Aug 2007 18:20:38 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

- Added support to unmask entire set of device errors and alarms.

Signed-off-by: Sivakumar Subramani <sivakumar.subramani@neterion.com>
Signed-off-by: Santosh Rastapur <santosh.rastapur@neterion.com>
Signed-off-by: Ramkrishna Vepa <ram.vepa@neterion.com>
---
diff -Nurp orig/drivers/net/s2io.c patch1/drivers/net/s2io.c
--- orig/drivers/net/s2io.c	2007-08-15 08:04:06.000000000 -0700
+++ patch1/drivers/net/s2io.c	2007-08-15 08:55:53.000000000 -0700
@@ -892,8 +892,9 @@ static void free_shared_mem(struct s2io_
 					k++;
 				}
 				kfree(mac_control->rings[i].ba[j]);
-				nic->mac_control.stats_info->sw_stat.mem_freed 				+= (sizeof(struct buffAdd) * 
-				(rxd_count[nic->rxd_mode] + 1));
+				nic->mac_control.stats_info->sw_stat.mem_freed += 
+					(sizeof(struct buffAdd) * 
+					(rxd_count[nic->rxd_mode] + 1));
 			}
 			kfree(mac_control->rings[i].ba);
 			nic->mac_control.stats_info->sw_stat.mem_freed += 
@@ -1732,6 +1733,365 @@ static int s2io_link_fault_indication(st
 		return MAC_RMAC_ERR_TIMER;
 }
 
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
+				|TDA_SM1_ERR_ALARM|TDA_Fn_ECC_SG_ERR|
+				TDA_PCIX_ERR;
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
+				|LSO7_SM_ERR_ALARM|LSO6_SEND_OFLOW
+				|LSO7_SEND_OFLOW;
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
+				TMAC_ECC_DB_ERR|TMAC_DESC_ECC_SG_ERR
+				|TMAC_DESC_ECC_DB_ERR;
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
+				PRC_PCI_AB_F_WR_Rn|PRC_PCI_DP_RD_Rn
+				|PRC_PCI_DP_WR_Rn|
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
+				RDA_RXD_ECC_DB_SERR|RDA_RXDn_ECC_SG_ERR
+				|RDA_FRM_ECC_SG_ERR|
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
 /**
  *  en_dis_able_nic_intrs - Enable or Disable the interrupts
  *  @nic: device private variable,
@@ -1746,17 +2106,16 @@ static int s2io_link_fault_indication(st
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
+		intr_mask |= TXPIC_INT_M;
 		if (flag == ENABLE_INTRS) {
-			temp64 = readq(&bar0->general_int_mask);
-			temp64 &= ~((u64) val64);
-			writeq(temp64, &bar0->general_int_mask);
 			/*
 			 * If Hercules adapter enable GPIO otherwise
 			 * disable all PCIX, Flash, MDIO, IIC and GPIO
@@ -1771,58 +2130,21 @@ static void en_dis_able_nic_intrs(struct
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
@@ -1834,19 +2156,13 @@ static void en_dis_able_nic_intrs(struct
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
@@ -1855,11 +2171,17 @@ static void en_dis_able_nic_intrs(struct
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
@@ -2063,14 +2385,6 @@ static int start_nic(struct s2io_nic *ni
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
@@ -2223,9 +2537,9 @@ static void stop_nic(struct s2io_nic *ni
 	config = &nic->config;
 
 	/*  Disable all interrupts */
+	en_dis_err_alarms(nic, ENA_ALL_INTRS, DISABLE_INTRS);
 	interruptible = TX_TRAFFIC_INTR | RX_TRAFFIC_INTR;
-	interruptible |= TX_PIC_INTR | RX_PIC_INTR;
-	interruptible |= TX_MAC_INTR | RX_MAC_INTR;
+	interruptible |= TX_PIC_INTR;
 	en_dis_able_nic_intrs(nic, interruptible, DISABLE_INTRS);
 
 	/* Clearing Adapter_En bit of ADAPTER_CONTROL Register */
@@ -6670,12 +6984,12 @@ static int s2io_card_up(struct s2io_nic 
 	tasklet_init(&sp->task, s2io_tasklet, (unsigned long) dev);
 
 	/*  Enable select interrupts */
+	en_dis_err_alarms(sp, ENA_ALL_INTRS, ENABLE_INTRS);
 	if (sp->intr_type != INTA)
 		en_dis_able_nic_intrs(sp, ENA_ALL_INTRS, DISABLE_INTRS);
 	else {
 		interruptible = TX_TRAFFIC_INTR | RX_TRAFFIC_INTR;
-		interruptible |= TX_PIC_INTR | RX_PIC_INTR;
-		interruptible |= TX_MAC_INTR | RX_MAC_INTR;
+		interruptible |= TX_PIC_INTR;
 		en_dis_able_nic_intrs(sp, interruptible, ENABLE_INTRS);
 	}
 
diff -Nurp orig/drivers/net/s2io.h patch1/drivers/net/s2io.h
--- orig/drivers/net/s2io.h	2007-08-15 08:04:06.000000000 -0700
+++ patch1/drivers/net/s2io.h	2007-08-15 08:06:06.000000000 -0700
@@ -892,6 +892,7 @@ struct s2io_nic {
 
 	spinlock_t	rx_lock;
 	atomic_t	isr_cnt;
+	u64		general_int_mask;
 	u64 *ufo_in_band_v;
 #define VPD_STRING_LEN 80
 	u8  product_name[VPD_STRING_LEN];
diff -Nurp orig/drivers/net/s2io-regs.h patch1/drivers/net/s2io-regs.h
--- orig/drivers/net/s2io-regs.h	2007-08-15 08:04:06.000000000 -0700
+++ patch1/drivers/net/s2io-regs.h	2007-08-15 08:06:06.000000000 -0700
@@ -325,33 +325,66 @@ struct XENA_dev_config {
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
+
 	u64 tpa_err_mask;
 	u64 tpa_err_alarm;
 
 	u64 sm_err_reg;
+#define SM_SM_ERR_ALARM			BIT(15)
 	u64 sm_err_mask;
 	u64 sm_err_alarm;
 
@@ -450,22 +483,52 @@ struct XENA_dev_config {
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
 
@@ -582,17 +645,43 @@ struct XENA_dev_config {
 #define MAC_INT_STATUS_RMAC_INT            BIT(1)
 
 	u64 mac_tmac_err_reg;
-#define TMAC_ERR_REG_TMAC_ECC_DB_ERR       BIT(15)
-#define TMAC_ERR_REG_TMAC_TX_BUF_OVRN      BIT(23)
-#define TMAC_ERR_REG_TMAC_TX_CRI_ERR       BIT(31)
+#define TMAC_ECC_SG_ERR				BIT(7)
+#define TMAC_ECC_DB_ERR				BIT(15)
+#define TMAC_TX_BUF_OVRN			BIT(23)
+#define TMAC_TX_CRI_ERR				BIT(31)
+#define TMAC_TX_SM_ERR				BIT(39)
+#define TMAC_DESC_ECC_SG_ERR			BIT(47)
+#define TMAC_DESC_ECC_DB_ERR			BIT(55)
+
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
+						BIT(8)  | BIT(9) | BIT(10)|\
+						BIT(11))
+#define RMAC_DOUBLE_ECC_ERR			(BIT(13) | BIT(14) | BIT(15) |\
+						BIT(16)  | BIT(17) | BIT(18)|\
+						BIT(19))
 	u64 mac_rmac_err_mask;
 	u64 mac_rmac_err_alarm;
 
@@ -750,6 +839,7 @@ struct XENA_dev_config {
 					BIT(17) | BIT(19))
 #define MC_ERR_REG_ECC_ALL_DBL		   (BIT(10) | BIT(11) | BIT(12) |\
 					BIT(13) | BIT(18) | BIT(20))
+#define PLL_LOCK_N			BIT(39)
 	u64 mc_err_mask;
 	u64 mc_err_alarm;
 
@@ -823,11 +913,17 @@ struct XENA_dev_config {
 #define XGXS_INT_MASK_RXGXS                BIT(1)
 
 	u64 xgxs_txgxs_err_reg;
-#define TXGXS_ECC_DB_ERR                   BIT(15)
+#define TXGXS_ECC_SG_ERR		BIT(7)
+#define TXGXS_ECC_DB_ERR		BIT(15)
+#define TXGXS_ESTORE_UFLOW		BIT(31)
+#define TXGXS_TX_SM_ERR			BIT(39)
+
 	u64 xgxs_txgxs_err_mask;
 	u64 xgxs_txgxs_err_alarm;
 
 	u64 xgxs_rxgxs_err_reg;
+#define RXGXS_ESTORE_OFLOW		BIT(7)
+#define RXGXS_RX_SM_ERR			BIT(39)
 	u64 xgxs_rxgxs_err_mask;
 	u64 xgxs_rxgxs_err_alarm;
 



