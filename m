From: Ramkrishna Vepa <ram.vepa@neterion.com>
Subject: [PATCH 2.6.24 2/5]S2io: Handle and monitor all of the device
	errors and alarms
Date: 15 Aug 2007 17:12:20 -0700
Message-ID: <1187223139.23940.333.camel@flash>
Reply-To: ram.vepa@neterion.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, support@neterion.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:49006 "EHLO
	barracuda.s2io.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752303AbXHOWUq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Aug 2007 18:20:46 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

- Added support to poll entire set of device errors and alarams.
- Replaced alarm_intr_handler() with s2io_handle_errors().
- Added statistic counters to monitor the alarms.

Signed-off-by: Sivakumar Subramani <sivakumar.subramani@neterion.com>
Signed-off-by: Santosh Rastapur <santosh.rastapur@neterion.com>
Signed-off-by: Ramkrishna Vepa <ram.vepa@neterion.com>
---
diff -Nurp patch1/drivers/net/s2io.c patch2/drivers/net/s2io.c
--- patch1/drivers/net/s2io.c	2007-08-15 08:55:53.000000000 -0700
+++ patch2/drivers/net/s2io.c	2007-08-15 08:57:44.000000000 -0700
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
@@ -3478,135 +3502,6 @@ static void s2io_updt_xpak_counter(struc
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
@@ -4468,8 +4363,9 @@ static void
 s2io_alarm_handle(unsigned long data)
 {
 	struct s2io_nic *sp = (struct s2io_nic *)data;
+	struct net_device *dev = sp->dev;
 
-	alarm_intr_handler(sp);
+	s2io_handle_errors(dev);
 	mod_timer(&sp->alarm_timer, jiffies + HZ / 2);
 }
 
@@ -4588,6 +4484,391 @@ static void s2io_txpic_intr_handle(struc
 }
 
 /**
+ *  s2io_handle_errors - Xframe error indication handler
+ *  @nic: device private variable
+ *  Description: Handle alarms such as loss of link, single or
+ *  double ECC errors, critical and serious errors.
+ *  Return Value:
+ *  NONE
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
+					/*
+					 * Reset XframeI only if critical error
+					 */
+					if (val64 &
+						(MC_ERR_REG_MIRI_ECC_DB_ERR_0 |
+						MC_ERR_REG_MIRI_ECC_DB_ERR_1))
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
+/**
  *  s2io_isr - ISR handler of the device .
  *  @irq: the irq of the device.
  *  @dev_id: a void pointer to the dev structure of the NIC.
@@ -5976,7 +6257,7 @@ static void s2io_get_ethtool_stats(struc
 				   struct ethtool_stats *estats,
 				   u64 * tmp_stats)
 {
-	int i = 0;
+	int i = 0, k;
 	struct s2io_nic *sp = dev->priv;
 	struct stat_block *stat_info = sp->mac_control.stats_info;
 
@@ -6171,7 +6452,8 @@ static void s2io_get_ethtool_stats(struc
 	tmp_stats[i++] = stat_info->sw_stat.serious_err_cnt;
 	tmp_stats[i++] = stat_info->sw_stat.soft_reset_cnt;
 	tmp_stats[i++] = stat_info->sw_stat.fifo_full_cnt;
-	tmp_stats[i++] = stat_info->sw_stat.ring_full_cnt;
+	for (k = 0; k < MAX_RX_RINGS; k++)
+		tmp_stats[i++] = stat_info->sw_stat.ring_full_cnt[k];
 	tmp_stats[i++] = stat_info->xpak_stat.alarm_transceiver_temp_high;
 	tmp_stats[i++] = stat_info->xpak_stat.alarm_transceiver_temp_low;
 	tmp_stats[i++] = stat_info->xpak_stat.alarm_laser_bias_current_high;
@@ -6228,6 +6510,23 @@ static void s2io_get_ethtool_stats(struc
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
diff -Nurp patch1/drivers/net/s2io.h patch2/drivers/net/s2io.h
--- patch1/drivers/net/s2io.h	2007-08-15 08:06:06.000000000 -0700
+++ patch2/drivers/net/s2io.h	2007-08-15 08:06:17.000000000 -0700
@@ -91,7 +91,7 @@ struct swStat {
 	unsigned long long serious_err_cnt;
 	unsigned long long soft_reset_cnt;
 	unsigned long long fifo_full_cnt;
-	unsigned long long ring_full_cnt;
+	unsigned long long ring_full_cnt[8];
 	/* LRO statistics */
 	unsigned long long clubbed_frms_cnt;
 	unsigned long long sending_both;
@@ -126,6 +126,26 @@ struct swStat {
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
+
 };
 
 /* Xpak releated alarm and warnings */
@@ -1017,7 +1037,7 @@ static void free_shared_mem(struct s2io_
 static int init_nic(struct s2io_nic *nic);
 static void rx_intr_handler(struct ring_info *ring_data);
 static void tx_intr_handler(struct fifo_info *fifo_data);
-static void alarm_intr_handler(struct s2io_nic *sp);
+static void s2io_handle_errors(void * dev_id);
 
 static int s2io_starter(void);
 static void s2io_closer(void);



