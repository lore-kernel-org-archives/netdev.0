From: Ananda Raju <Ananda.Raju@neterion.com>
Subject: [patch 4/5] s2io driver updates
Date: Fri, 21 Apr 2006 19:20:22 -0400 (EDT)
Message-ID: <Pine.GSO.4.10.10604211918060.16549-100000@guinness>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: leonid.grossman@neterion.com, ravinandan.arakali@neterion.com,
	rapuru.sriram@neterion.com, alicia.pena@neterion.com,
	ananda.raju@neterion.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:16587 "EHLO
	barracuda.mail.s2io.com") by vger.kernel.org with ESMTP
	id S1750753AbWDUXUb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Apr 2006 19:20:31 -0400
To: jgarzik@pobox.com, netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi, 
	This patch contains additional statistics counters added to s2io driver
	these statistics are very much usefull in debugging the driver. 

Signed-off-by: Ananda Raju <ananda.raju@neterion.com>
---
diff -upNr bug_fixes1/drivers/net/s2io-regs.h stat_enhancement/drivers/net/s2io-regs.h
--- bug_fixes1/drivers/net/s2io-regs.h	2006-04-13 06:51:23.000000000 -0700
+++ stat_enhancement/drivers/net/s2io-regs.h	2006-04-13 08:16:52.000000000 -0700
@@ -167,6 +167,7 @@ typedef struct _XENA_dev_config {
 	u8 unused4[0x08];
 
 	u64 gpio_int_reg;
+#define GPIO_INT_REG_DP_ERR_INT                BIT(0)
 #define GPIO_INT_REG_LINK_DOWN                 BIT(1)
 #define GPIO_INT_REG_LINK_UP                   BIT(2)
 	u64 gpio_int_mask;
@@ -267,6 +268,21 @@ typedef struct _XENA_dev_config {
 
 	/* General Configuration */
 	u64 mdio_control;
+#define MDIO_MMD_INDX_ADDR(val)		vBIT(val, 0, 16)
+#define MDIO_MMD_DEV_ADDR(val)		vBIT(val, 19, 5)
+#define MDIO_MMD_PMA_DEV_ADDR		0x1
+#define MDIO_MMD_PMD_DEV_ADDR		0x1
+#define MDIO_MMD_WIS_DEV_ADDR		0x2
+#define MDIO_MMD_PCS_DEV_ADDR		0x3
+#define MDIO_MMD_PHYXS_DEV_ADDR		0x4
+#define MDIO_MMS_PRT_ADDR(val)		vBIT(val, 27, 5)
+#define MDIO_CTRL_START_TRANS(val)	vBIT(val, 56, 4)
+#define MDIO_OP(val)			vBIT(val, 60, 2)
+#define MDIO_OP_ADDR_TRANS		0x0
+#define MDIO_OP_WRITE_TRANS		0x1
+#define MDIO_OP_READ_POST_INC_TRANS	0x2
+#define MDIO_OP_READ_TRANS		0x3
+#define MDIO_MDIO_DATA(val)		vBIT(val, 32, 16)
 
 	u64 dtx_control;
 
@@ -546,7 +562,12 @@ typedef struct _XENA_dev_config {
 #define RX_PA_CFG_IGNORE_LLC_CTRL          BIT(3)
 #define RX_PA_CFG_IGNORE_L2_ERR            BIT(6)
 
-	u8 unused12[0x700 - 0x1D8];
+	u64 unused_11_1;
+
+	u64 ring_bump_counter1;
+	u64 ring_bump_counter2;
+
+	u8 unused12[0x700 - 0x1F0];
 
 	u64 rxdma_debug_ctrl;
 
diff -upNr bug_fixes1/drivers/net/s2io.c stat_enhancement/drivers/net/s2io.c
--- bug_fixes1/drivers/net/s2io.c	2006-04-13 09:03:47.000000000 -0700
+++ stat_enhancement/drivers/net/s2io.c	2006-04-13 09:04:10.000000000 -0700
@@ -139,7 +139,11 @@ static char ethtool_stats_keys[][ETH_GST
 	{"tmac_mcst_frms"},
 	{"tmac_bcst_frms"},
 	{"tmac_pause_ctrl_frms"},
+	{"tmac_ttl_octets"},
+	{"tmac_ucst_frms"},
+	{"tmac_nucst_frms"},
 	{"tmac_any_err_frms"},
+	{"tmac_ttl_less_fb_octets"},
 	{"tmac_vld_ip_octets"},
 	{"tmac_vld_ip"},
 	{"tmac_drop_ip"},
@@ -154,13 +158,27 @@ static char ethtool_stats_keys[][ETH_GST
 	{"rmac_vld_mcst_frms"},
 	{"rmac_vld_bcst_frms"},
 	{"rmac_in_rng_len_err_frms"},
+	{"rmac_out_rng_len_err_frms"},
 	{"rmac_long_frms"},
 	{"rmac_pause_ctrl_frms"},
+	{"rmac_unsup_ctrl_frms"},
+	{"rmac_ttl_octets"},
+	{"rmac_accepted_ucst_frms"},
+	{"rmac_accepted_nucst_frms"},
 	{"rmac_discarded_frms"},
+	{"rmac_drop_events"},
+	{"rmac_ttl_less_fb_octets"},
+	{"rmac_ttl_frms"},
 	{"rmac_usized_frms"},
 	{"rmac_osized_frms"},
 	{"rmac_frag_frms"},
 	{"rmac_jabber_frms"},
+	{"rmac_ttl_64_frms"},
+	{"rmac_ttl_65_127_frms"},
+	{"rmac_ttl_128_255_frms"},
+	{"rmac_ttl_256_511_frms"},
+	{"rmac_ttl_512_1023_frms"},
+	{"rmac_ttl_1024_1518_frms"},
 	{"rmac_ip"},
 	{"rmac_ip_octets"},
 	{"rmac_hdr_err_ip"},
@@ -169,12 +187,82 @@ static char ethtool_stats_keys[][ETH_GST
 	{"rmac_tcp"},
 	{"rmac_udp"},
 	{"rmac_err_drp_udp"},
+	{"rmac_xgmii_err_sym"},
+	{"rmac_frms_q0"},
+	{"rmac_frms_q1"},
+	{"rmac_frms_q2"},
+	{"rmac_frms_q3"},
+	{"rmac_frms_q4"},
+	{"rmac_frms_q5"},
+	{"rmac_frms_q6"},
+	{"rmac_frms_q7"},
+	{"rmac_full_q0"},
+	{"rmac_full_q1"},
+	{"rmac_full_q2"},
+	{"rmac_full_q3"},
+	{"rmac_full_q4"},
+	{"rmac_full_q5"},
+	{"rmac_full_q6"},
+	{"rmac_full_q7"},
 	{"rmac_pause_cnt"},
+	{"rmac_xgmii_data_err_cnt"},
+	{"rmac_xgmii_ctrl_err_cnt"},
 	{"rmac_accepted_ip"},
 	{"rmac_err_tcp"},
+	{"rd_req_cnt"},
+	{"new_rd_req_cnt"},
+	{"new_rd_req_rtry_cnt"},
+	{"rd_rtry_cnt"},
+	{"wr_rtry_rd_ack_cnt"},
+	{"wr_req_cnt"},
+	{"new_wr_req_cnt"},
+	{"new_wr_req_rtry_cnt"},
+	{"wr_rtry_cnt"},
+	{"wr_disc_cnt"},
+	{"rd_rtry_wr_ack_cnt"},
+	{"txp_wr_cnt"},
+	{"txd_rd_cnt"},
+	{"txd_wr_cnt"},
+	{"rxd_rd_cnt"},
+	{"rxd_wr_cnt"},
+	{"txf_rd_cnt"},
+	{"rxf_wr_cnt"},
+	{"rmac_ttl_1519_4095_frms"},
+	{"rmac_ttl_4096_8191_frms"},
+	{"rmac_ttl_8192_max_frms"},
+	{"rmac_ttl_gt_max_frms"},
+	{"rmac_osized_alt_frms"},
+	{"rmac_jabber_alt_frms"},
+	{"rmac_gt_max_alt_frms"},
+	{"rmac_vlan_frms"},
+	{"rmac_len_discard"},
+	{"rmac_fcs_discard"},
+	{"rmac_pf_discard"},
+	{"rmac_da_discard"},
+	{"rmac_red_discard"},
+	{"rmac_rts_discard"},
+	{"rmac_ingm_full_discard"},
+	{"link_fault_cnt"},
 	{"\n DRIVER STATISTICS"},
 	{"single_bit_ecc_errs"},
 	{"double_bit_ecc_errs"},
+	{"parity_err_cnt"},
+	{"serious_err_cnt"},
+	{"soft_reset_cnt"},
+	{"fifo_full_cnt"},
+	{"ring_full_cnt"},
+	("alarm_transceiver_temp_high"),
+	("alarm_transceiver_temp_low"),
+	("alarm_laser_bias_current_high"),
+	("alarm_laser_bias_current_low"),
+	("alarm_laser_output_power_high"),
+	("alarm_laser_output_power_low"),
+	("warn_transceiver_temp_high"),
+	("warn_transceiver_temp_low"),
+	("warn_laser_bias_current_high"),
+	("warn_laser_bias_current_low"),
+	("warn_laser_output_power_high"),
+	("warn_laser_output_power_low"),
 	("lro_aggregated_pkts"),
 	("lro_flush_both_count"),
 	("lro_out_of_sequence_pkts"),
@@ -2197,7 +2285,7 @@ static int fill_rx_buffers(struct s2io_n
 	alloc_cnt = mac_control->rings[ring_no].pkt_cnt -
 	    atomic_read(&nic->rx_bufs_left[ring_no]);
 
-	block_no1 = mac_control->rings[ring_no].rx_curr_get_info.block_index;
+        block_no1 = mac_control->rings[ring_no].rx_curr_get_info.block_index;
 	off1 = mac_control->rings[ring_no].rx_curr_get_info.offset;
 	while (alloc_tab < alloc_cnt) {
 		block_no = mac_control->rings[ring_no].rx_curr_put_info.
@@ -2704,6 +2792,10 @@ static void tx_intr_handler(fifo_info_t 
 		if (txdlp->Control_1 & TXD_T_CODE) {
 			unsigned long long err;
 			err = txdlp->Control_1 & TXD_T_CODE;
+			if (err & 0x1) {
+				nic->mac_control.stats_info->sw_stat.
+						parity_err_cnt++;
+			}
 			if ((err >> 48) == 0xA) {
 				DBG_PRINT(TX_DBG, "TxD returned due \
 to loss of link\n");
@@ -2742,6 +2834,256 @@ to loss of link\n");
 }
 
 /**
+ *  s2io_mdio_write - Function to write in to MDIO registers
+ *  @mmd_type : MMD type value (PMA/PMD/WIS/PCS/PHYXS)
+ *  @addr     : address value
+ *  @value    : data value
+ *  @dev      : pointer to net_device structure
+ *  Description:
+ *  This function is used to write values to the MDIO registers
+ *  NONE
+ */
+static void s2io_mdio_write(u32 mmd_type, u64 addr, u16 value, struct net_device *dev)
+{
+	u64 val64 = 0x0;
+	nic_t *sp = dev->priv;
+	XENA_dev_config_t *bar0 = (XENA_dev_config_t *)sp->bar0;
+
+	//address transaction
+	val64 = val64 | MDIO_MMD_INDX_ADDR(addr)
+			| MDIO_MMD_DEV_ADDR(mmd_type)
+			| MDIO_MMS_PRT_ADDR(0x0);
+	writeq(val64, &bar0->mdio_control);
+	val64 = val64 | MDIO_CTRL_START_TRANS(0xE);
+	writeq(val64, &bar0->mdio_control);
+	udelay(100);
+
+	//Data transaction
+	val64 = 0x0;
+	val64 = val64 | MDIO_MMD_INDX_ADDR(addr)
+			| MDIO_MMD_DEV_ADDR(mmd_type)
+			| MDIO_MMS_PRT_ADDR(0x0)
+			| MDIO_MDIO_DATA(value)
+			| MDIO_OP(MDIO_OP_WRITE_TRANS);
+	writeq(val64, &bar0->mdio_control);
+	val64 = val64 | MDIO_CTRL_START_TRANS(0xE);
+	writeq(val64, &bar0->mdio_control);
+	udelay(100);
+
+	val64 = 0x0;
+	val64 = val64 | MDIO_MMD_INDX_ADDR(addr)
+	| MDIO_MMD_DEV_ADDR(mmd_type)
+	| MDIO_MMS_PRT_ADDR(0x0)
+	| MDIO_OP(MDIO_OP_READ_TRANS);
+	writeq(val64, &bar0->mdio_control);
+	val64 = val64 | MDIO_CTRL_START_TRANS(0xE);
+	writeq(val64, &bar0->mdio_control);
+	udelay(100);
+
+}
+
+/**
+ *  s2io_mdio_read - Function to write in to MDIO registers
+ *  @mmd_type : MMD type value (PMA/PMD/WIS/PCS/PHYXS)
+ *  @addr     : address value
+ *  @dev      : pointer to net_device structure
+ *  Description:
+ *  This function is used to read values to the MDIO registers
+ *  NONE
+ */
+static u64 s2io_mdio_read(u32 mmd_type, u64 addr, struct net_device *dev)
+{
+	u64 val64 = 0x0;
+	u64 rval64 = 0x0;
+	nic_t *sp = dev->priv;
+	XENA_dev_config_t *bar0 = (XENA_dev_config_t *)sp->bar0;
+
+	/* address transaction */
+	val64 = val64 | MDIO_MMD_INDX_ADDR(addr)
+			| MDIO_MMD_DEV_ADDR(mmd_type)
+			| MDIO_MMS_PRT_ADDR(0x0);
+	writeq(val64, &bar0->mdio_control);
+	val64 = val64 | MDIO_CTRL_START_TRANS(0xE);
+	writeq(val64, &bar0->mdio_control);
+	udelay(100);
+
+	/* Data transaction */
+	val64 = 0x0;
+	val64 = val64 | MDIO_MMD_INDX_ADDR(addr)
+			| MDIO_MMD_DEV_ADDR(mmd_type)
+			| MDIO_MMS_PRT_ADDR(0x0)
+			| MDIO_OP(MDIO_OP_READ_TRANS);
+	writeq(val64, &bar0->mdio_control);
+	val64 = val64 | MDIO_CTRL_START_TRANS(0xE);
+	writeq(val64, &bar0->mdio_control);
+	udelay(100);
+
+	/* Read the value from regs */
+	rval64 = readq(&bar0->mdio_control);
+	rval64 = rval64 & 0xFFFF0000;
+	rval64 = rval64 >> 16;
+	return rval64;
+}
+/**
+ *  s2io_chk_xpak_counter - Function to check the status of the xpak counters
+ *  @counter      : couter value to be updated
+ *  @flag         : flag to indicate the status
+ *  @type         : counter type
+ *  Description:
+ *  This function is to check the status of the xpak counters value
+ *  NONE
+ */
+
+static void s2io_chk_xpak_counter(u64 *counter, u64 * regs_stat, u32 index, u16 flag, u16 type)
+{
+	u64 mask = 0x3;
+	u64 val64;
+	int i;
+	for(i = 0; i <index; i++)
+		mask = mask << 0x2;
+
+	if(flag > 0)
+	{
+		*counter = *counter + 1;
+		val64 = *regs_stat & mask;
+		val64 = val64 >> (index * 0x2);
+		val64 = val64 + 1;
+		if(val64 == 3)
+		{
+			switch(type)
+			{
+			case 1:
+				DBG_PRINT(ERR_DBG, "Take Xframe NIC out of "
+					  "service. Excessive temperatures may "
+					  "result in premature transceiver "
+					  "failure \n");
+			break;
+			case 2:
+				DBG_PRINT(ERR_DBG, "Take Xframe NIC out of "
+					  "service Excessive bias currents may "
+					  "indicate imminent laser diode "
+					  "failure \n");
+			break;
+			case 3:
+				DBG_PRINT(ERR_DBG, "Take Xframe NIC out of "
+					  "service Excessive laser output "
+					  "power may saturate far-end "
+					  "receiver\n");
+			break;
+			default:
+				DBG_PRINT(ERR_DBG, "Incorrect XPAK Alarm "
+					  "type \n");
+			}
+			val64 = 0x0;
+		}
+		val64 = val64 << (index * 0x2);
+		*regs_stat = (*regs_stat & (~mask)) | (val64);
+
+	} else {
+		*regs_stat = *regs_stat & (~mask);
+	}
+}
+
+/**
+ *  s2io_updt_xpak_counter - Function to update the xpak counters
+ *  @dev         : pointer to net_device struct
+ *  Description:
+ *  This function is to upate the status of the xpak counters value
+ *  NONE
+ */
+static void s2io_updt_xpak_counter(struct net_device *dev)
+{
+	u16 flag  = 0x0;
+	u16 type  = 0x0;
+	u16 val16 = 0x0;
+	u64 val64 = 0x0;
+	u64 addr  = 0x0;
+
+	nic_t *sp = dev->priv;
+	StatInfo_t *stat_info = sp->mac_control.stats_info;
+
+	/* Check the communication with the MDIO slave */
+	addr = 0x0000;
+	val64 = 0x0;
+	val64 = s2io_mdio_read(MDIO_MMD_PMA_DEV_ADDR, addr, dev);
+	if((val64 == 0xFFFF) || (val64 == 0x0000))
+	{
+		DBG_PRINT(ERR_DBG, "ERR: MDIO slave access failed - "
+			  "Returned %llx\n", (unsigned long long)val64);
+		return;
+	}
+
+	/* Check for the expecte value of 2040 at PMA address 0x0000 */
+	if(val64 != 0x2040)
+	{
+		DBG_PRINT(ERR_DBG, "Incorrect value at PMA address 0x0000 - ");
+		DBG_PRINT(ERR_DBG, "Returned: %llx- Expected: 0x2040\n",
+			  (unsigned long long)val64);
+		return;
+	}
+
+	/* Loading the DOM register to MDIO register */
+	addr = 0xA100;
+	s2io_mdio_write(MDIO_MMD_PMA_DEV_ADDR, addr, val16, dev);
+	val64 = s2io_mdio_read(MDIO_MMD_PMA_DEV_ADDR, addr, dev);
+
+	/* Reading the Alarm flags */
+	addr = 0xA070;
+	val64 = 0x0;
+	val64 = s2io_mdio_read(MDIO_MMD_PMA_DEV_ADDR, addr, dev);
+
+	flag = CHECKBIT(val64, 0x7);
+	type = 1;
+	s2io_chk_xpak_counter(&stat_info->xpak_stat.alarm_transceiver_temp_high,
+				&stat_info->xpak_stat.xpak_regs_stat,
+				0x0, flag, type);
+
+	if(CHECKBIT(val64, 0x6))
+		stat_info->xpak_stat.alarm_transceiver_temp_low++;
+
+	flag = CHECKBIT(val64, 0x3);
+	type = 2;
+	s2io_chk_xpak_counter(&stat_info->xpak_stat.alarm_laser_bias_current_high,
+				&stat_info->xpak_stat.xpak_regs_stat,
+				0x2, flag, type);
+
+	if(CHECKBIT(val64, 0x2))
+		stat_info->xpak_stat.alarm_laser_bias_current_low++;
+
+	flag = CHECKBIT(val64, 0x1);
+	type = 3;
+	s2io_chk_xpak_counter(&stat_info->xpak_stat.alarm_laser_output_power_high,
+				&stat_info->xpak_stat.xpak_regs_stat,
+				0x4, flag, type);
+
+	if(CHECKBIT(val64, 0x0))
+		stat_info->xpak_stat.alarm_laser_output_power_low++;
+
+	/* Reading the Warning flags */
+	addr = 0xA074;
+	val64 = 0x0;
+	val64 = s2io_mdio_read(MDIO_MMD_PMA_DEV_ADDR, addr, dev);
+
+	if(CHECKBIT(val64, 0x7))
+		stat_info->xpak_stat.warn_transceiver_temp_high++;
+
+	if(CHECKBIT(val64, 0x6))
+		stat_info->xpak_stat.warn_transceiver_temp_low++;
+
+	if(CHECKBIT(val64, 0x3))
+		stat_info->xpak_stat.warn_laser_bias_current_high++;
+
+	if(CHECKBIT(val64, 0x2))
+		stat_info->xpak_stat.warn_laser_bias_current_low++;
+
+	if(CHECKBIT(val64, 0x1))
+		stat_info->xpak_stat.warn_laser_output_power_high++;
+
+	if(CHECKBIT(val64, 0x0))
+		stat_info->xpak_stat.warn_laser_output_power_low++;
+}
+
+/**
  *  alarm_intr_handler - Alarm Interrrupt handler
  *  @nic: device private variable
  *  Description: If the interrupt was neither because of Rx packet or Tx
@@ -2758,6 +3100,18 @@ static void alarm_intr_handler(struct s2
 	struct net_device *dev = (struct net_device *) nic->dev;
 	XENA_dev_config_t __iomem *bar0 = nic->bar0;
 	register u64 val64 = 0, err_reg = 0;
+	u64 cnt;
+	int i;
+	nic->mac_control.stats_info->sw_stat.ring_full_cnt = 0;
+	/* Handling the XPAK counters update */
+	if(nic->mac_control.stats_info->xpak_stat.xpak_timer_count < 72000) {
+		/* waiting for an hour */
+		nic->mac_control.stats_info->xpak_stat.xpak_timer_count++;
+	} else {
+		s2io_updt_xpak_counter(dev);
+		/* reset the count to zero */
+		nic->mac_control.stats_info->xpak_stat.xpak_timer_count = 0;
+	}
 
 	/* Handling link status change error Intr */
 	if (s2io_link_fault_indication(nic) == MAC_RMAC_ERR_TIMER) {
@@ -2784,6 +3138,8 @@ static void alarm_intr_handler(struct s2
 					     MC_ERR_REG_MIRI_ECC_DB_ERR_1)) {
 					netif_stop_queue(dev);
 					schedule_work(&nic->rst_timer_task);
+					nic->mac_control.stats_info->sw_stat.
+							soft_reset_cnt++;
 				}
 			}
 		} else {
@@ -2795,11 +3151,13 @@ static void alarm_intr_handler(struct s2
 	/* In case of a serious error, the device will be Reset. */
 	val64 = readq(&bar0->serr_source);
 	if (val64 & SERR_SOURCE_ANY) {
+		nic->mac_control.stats_info->sw_stat.serious_err_cnt++;
 		DBG_PRINT(ERR_DBG, "%s: Device indicates ", dev->name);
 		DBG_PRINT(ERR_DBG, "serious error %llx!!\n", 
 			  (unsigned long long)val64);
 		netif_stop_queue(dev);
 		schedule_work(&nic->rst_timer_task);
+		nic->mac_control.stats_info->sw_stat.soft_reset_cnt++;
 	}
 
 	/*
@@ -2817,6 +3175,35 @@ static void alarm_intr_handler(struct s2
 		ac = readq(&bar0->adapter_control);
 		schedule_work(&nic->set_link_task);
 	}
+	/* Check for data parity error */
+	val64 = readq(&bar0->pic_int_status);
+	if (val64 & PIC_INT_GPIO) {
+		val64 = readq(&bar0->gpio_int_reg);
+		if (val64 & GPIO_INT_REG_DP_ERR_INT) {
+			nic->mac_control.stats_info->sw_stat.parity_err_cnt++;
+			schedule_work(&nic->rst_timer_task);
+			nic->mac_control.stats_info->sw_stat.soft_reset_cnt++;
+		}
+	}
+
+	/* Check for ring full counter */
+	if (nic->device_type & XFRAME_II_DEVICE) {
+		val64 = readq(&bar0->ring_bump_counter1);
+		for (i=0; i<4; i++) {
+			cnt = ( val64 & vBIT(0xFFFF,(i*16),16));
+			cnt >>= 64 - ((i+1)*16);
+			nic->mac_control.stats_info->sw_stat.ring_full_cnt
+				+= cnt;
+		}
+
+		val64 = readq(&bar0->ring_bump_counter2);
+		for (i=0; i<4; i++) {
+			cnt = ( val64 & vBIT(0xFFFF,(i*16),16));
+			cnt >>= 64 - ((i+1)*16);
+			nic->mac_control.stats_info->sw_stat.ring_full_cnt
+				+= cnt;
+		}
+	}
 
 	/* Other type of interrupts are not being handled now,  TODO */
 }
@@ -3397,6 +3784,7 @@ isr_registration_failed:
 	if (sp->intr_type == MSI_X) {
 		int i;
 		u16 msi_control; /* Temp variable */
+
 		for (i=1; (sp->s2io_entries[i].in_use == 
 				MSIX_REGISTERED_SUCCESS); i++) {
 			int vector = sp->entries[i].vector;
@@ -3626,6 +4014,7 @@ static int s2io_xmit(struct sk_buff *skb
 
 	/* Avoid "put" pointer going beyond "get" pointer */
 	if (((put_off+1) == queue_len ? 0 : (put_off+1)) == get_off) {
+		sp->mac_control.stats_info->sw_stat.fifo_full_cnt++;
 		DBG_PRINT(TX_DBG,
 			  "No free TxDs for xmit, Put: 0x%x Get:0x%x\n",
 			  put_off, get_off);
@@ -3761,7 +4150,6 @@ s2io_msix_fifo_handle(int irq, void *dev
 	atomic_dec(&sp->isr_cnt);
 	return IRQ_HANDLED;
 }
-
 static void s2io_txpic_intr_handle(nic_t *sp)
 {
 	XENA_dev_config_t __iomem *bar0 = sp->bar0;
@@ -5132,7 +5520,6 @@ static void s2io_get_ethtool_stats(struc
 	int i = 0;
 	nic_t *sp = dev->priv;
 	StatInfo_t *stat_info = sp->mac_control.stats_info;
-	u64 tmp;
 
 	s2io_updt_stats(sp);
 	tmp_stats[i++] =
@@ -5149,9 +5536,19 @@ static void s2io_get_ethtool_stats(struc
 		(u64)le32_to_cpu(stat_info->tmac_bcst_frms_oflow) << 32 |
 		le32_to_cpu(stat_info->tmac_bcst_frms);
 	tmp_stats[i++] = le64_to_cpu(stat_info->tmac_pause_ctrl_frms);
+        tmp_stats[i++] =
+                (u64)le32_to_cpu(stat_info->tmac_ttl_octets_oflow) << 32 |
+                le32_to_cpu(stat_info->tmac_ttl_octets);
+	tmp_stats[i++] =
+                (u64)le32_to_cpu(stat_info->tmac_ucst_frms_oflow) << 32 |
+                le32_to_cpu(stat_info->tmac_ucst_frms);
+	tmp_stats[i++] =
+                (u64)le32_to_cpu(stat_info->tmac_nucst_frms_oflow) << 32 |
+                le32_to_cpu(stat_info->tmac_nucst_frms);
 	tmp_stats[i++] =
 		(u64)le32_to_cpu(stat_info->tmac_any_err_frms_oflow) << 32 |
 		le32_to_cpu(stat_info->tmac_any_err_frms);
+        tmp_stats[i++] = le64_to_cpu(stat_info->tmac_ttl_less_fb_octets);
 	tmp_stats[i++] = le64_to_cpu(stat_info->tmac_vld_ip_octets);
 	tmp_stats[i++] =
 		(u64)le32_to_cpu(stat_info->tmac_vld_ip_oflow) << 32 |
@@ -5183,11 +5580,27 @@ static void s2io_get_ethtool_stats(struc
 		(u64)le32_to_cpu(stat_info->rmac_vld_bcst_frms_oflow) << 32 |
 		le32_to_cpu(stat_info->rmac_vld_bcst_frms);
 	tmp_stats[i++] = le32_to_cpu(stat_info->rmac_in_rng_len_err_frms);
+	tmp_stats[i++] = le32_to_cpu(stat_info->rmac_out_rng_len_err_frms);
 	tmp_stats[i++] = le64_to_cpu(stat_info->rmac_long_frms);
 	tmp_stats[i++] = le64_to_cpu(stat_info->rmac_pause_ctrl_frms);
+	tmp_stats[i++] = le64_to_cpu(stat_info->rmac_unsup_ctrl_frms);
+        tmp_stats[i++] =
+                (u64)le32_to_cpu(stat_info->rmac_ttl_octets_oflow) << 32 |
+		le32_to_cpu(stat_info->rmac_ttl_octets);
+        tmp_stats[i++] =
+                (u64)le32_to_cpu(stat_info->rmac_accepted_ucst_frms_oflow)
+		<< 32 | le32_to_cpu(stat_info->rmac_accepted_ucst_frms);
+	tmp_stats[i++] =
+                (u64)le32_to_cpu(stat_info->rmac_accepted_nucst_frms_oflow)
+                 << 32 | le32_to_cpu(stat_info->rmac_accepted_nucst_frms);
 	tmp_stats[i++] =
 		(u64)le32_to_cpu(stat_info->rmac_discarded_frms_oflow) << 32 |
 		le32_to_cpu(stat_info->rmac_discarded_frms);
+        tmp_stats[i++] =
+                (u64)le32_to_cpu(stat_info->rmac_drop_events_oflow)
+                 << 32 | le32_to_cpu(stat_info->rmac_drop_events);
+        tmp_stats[i++] = le64_to_cpu(stat_info->rmac_ttl_less_fb_octets);
+        tmp_stats[i++] = le64_to_cpu(stat_info->rmac_ttl_frms);
 	tmp_stats[i++] =
 		(u64)le32_to_cpu(stat_info->rmac_usized_frms_oflow) << 32 |
 		le32_to_cpu(stat_info->rmac_usized_frms);
@@ -5200,40 +5613,129 @@ static void s2io_get_ethtool_stats(struc
 	tmp_stats[i++] =
 		(u64)le32_to_cpu(stat_info->rmac_jabber_frms_oflow) << 32 |
 		le32_to_cpu(stat_info->rmac_jabber_frms);
-	tmp_stats[i++] = (u64)le32_to_cpu(stat_info->rmac_ip_oflow) << 32 |
+	tmp_stats[i++] = le64_to_cpu(stat_info->rmac_ttl_64_frms);
+        tmp_stats[i++] = le64_to_cpu(stat_info->rmac_ttl_65_127_frms);
+        tmp_stats[i++] = le64_to_cpu(stat_info->rmac_ttl_128_255_frms);
+        tmp_stats[i++] = le64_to_cpu(stat_info->rmac_ttl_256_511_frms);
+        tmp_stats[i++] = le64_to_cpu(stat_info->rmac_ttl_512_1023_frms);
+        tmp_stats[i++] = le64_to_cpu(stat_info->rmac_ttl_1024_1518_frms);
+	tmp_stats[i++] =
+		(u64)le32_to_cpu(stat_info->rmac_ip_oflow) << 32 |
 		le32_to_cpu(stat_info->rmac_ip);
 	tmp_stats[i++] = le64_to_cpu(stat_info->rmac_ip_octets);
 	tmp_stats[i++] = le32_to_cpu(stat_info->rmac_hdr_err_ip);
-	tmp_stats[i++] = (u64)le32_to_cpu(stat_info->rmac_drop_ip_oflow) << 32 |
+	tmp_stats[i++] =
+		(u64)le32_to_cpu(stat_info->rmac_drop_ip_oflow) << 32 |
 		le32_to_cpu(stat_info->rmac_drop_ip);
-	tmp_stats[i++] = (u64)le32_to_cpu(stat_info->rmac_icmp_oflow) << 32 |
+	tmp_stats[i++] =
+		(u64)le32_to_cpu(stat_info->rmac_icmp_oflow) << 32 |
 		le32_to_cpu(stat_info->rmac_icmp);
 	tmp_stats[i++] = le64_to_cpu(stat_info->rmac_tcp);
-	tmp_stats[i++] = (u64)le32_to_cpu(stat_info->rmac_udp_oflow) << 32 |
+	tmp_stats[i++] =
+		(u64)le32_to_cpu(stat_info->rmac_udp_oflow) << 32 |
 		le32_to_cpu(stat_info->rmac_udp);
 	tmp_stats[i++] =
 		(u64)le32_to_cpu(stat_info->rmac_err_drp_udp_oflow) << 32 |
 		le32_to_cpu(stat_info->rmac_err_drp_udp);
+	tmp_stats[i++] = le64_to_cpu(stat_info->rmac_xgmii_err_sym);
+        tmp_stats[i++] = le64_to_cpu(stat_info->rmac_frms_q0);
+        tmp_stats[i++] = le64_to_cpu(stat_info->rmac_frms_q1);
+        tmp_stats[i++] = le64_to_cpu(stat_info->rmac_frms_q2);
+        tmp_stats[i++] = le64_to_cpu(stat_info->rmac_frms_q3);
+        tmp_stats[i++] = le64_to_cpu(stat_info->rmac_frms_q4);
+        tmp_stats[i++] = le64_to_cpu(stat_info->rmac_frms_q5);
+        tmp_stats[i++] = le64_to_cpu(stat_info->rmac_frms_q6);
+        tmp_stats[i++] = le64_to_cpu(stat_info->rmac_frms_q7);
+        tmp_stats[i++] = le16_to_cpu(stat_info->rmac_full_q0);
+        tmp_stats[i++] = le16_to_cpu(stat_info->rmac_full_q1);
+        tmp_stats[i++] = le16_to_cpu(stat_info->rmac_full_q2);
+        tmp_stats[i++] = le16_to_cpu(stat_info->rmac_full_q3);
+        tmp_stats[i++] = le16_to_cpu(stat_info->rmac_full_q4);
+        tmp_stats[i++] = le16_to_cpu(stat_info->rmac_full_q5);
+        tmp_stats[i++] = le16_to_cpu(stat_info->rmac_full_q6);
+        tmp_stats[i++] = le16_to_cpu(stat_info->rmac_full_q7);
 	tmp_stats[i++] =
 		(u64)le32_to_cpu(stat_info->rmac_pause_cnt_oflow) << 32 |
 		le32_to_cpu(stat_info->rmac_pause_cnt);
+	tmp_stats[i++] = le64_to_cpu(stat_info->rmac_xgmii_data_err_cnt);
+        tmp_stats[i++] = le64_to_cpu(stat_info->rmac_xgmii_ctrl_err_cnt);
 	tmp_stats[i++] =
 		(u64)le32_to_cpu(stat_info->rmac_accepted_ip_oflow) << 32 |
 		le32_to_cpu(stat_info->rmac_accepted_ip);
 	tmp_stats[i++] = le32_to_cpu(stat_info->rmac_err_tcp);
+	tmp_stats[i++] = le32_to_cpu(stat_info->rd_req_cnt);
+	tmp_stats[i++] = le32_to_cpu(stat_info->new_rd_req_cnt);
+	tmp_stats[i++] = le32_to_cpu(stat_info->new_rd_req_rtry_cnt);
+	tmp_stats[i++] = le32_to_cpu(stat_info->rd_rtry_cnt);
+	tmp_stats[i++] = le32_to_cpu(stat_info->wr_rtry_rd_ack_cnt);
+	tmp_stats[i++] = le32_to_cpu(stat_info->wr_req_cnt);
+	tmp_stats[i++] = le32_to_cpu(stat_info->new_wr_req_cnt);
+	tmp_stats[i++] = le32_to_cpu(stat_info->new_wr_req_rtry_cnt);
+	tmp_stats[i++] = le32_to_cpu(stat_info->wr_rtry_cnt);
+	tmp_stats[i++] = le32_to_cpu(stat_info->wr_disc_cnt);
+	tmp_stats[i++] = le32_to_cpu(stat_info->rd_rtry_wr_ack_cnt);
+	tmp_stats[i++] = le32_to_cpu(stat_info->txp_wr_cnt);
+	tmp_stats[i++] = le32_to_cpu(stat_info->txd_rd_cnt);
+	tmp_stats[i++] = le32_to_cpu(stat_info->txd_wr_cnt);
+	tmp_stats[i++] = le32_to_cpu(stat_info->rxd_rd_cnt);
+	tmp_stats[i++] = le32_to_cpu(stat_info->rxd_wr_cnt);
+	tmp_stats[i++] = le32_to_cpu(stat_info->txf_rd_cnt);
+	tmp_stats[i++] = le32_to_cpu(stat_info->rxf_wr_cnt);
+	tmp_stats[i++] = le64_to_cpu(stat_info->rmac_ttl_1519_4095_frms);
+        tmp_stats[i++] = le64_to_cpu(stat_info->rmac_ttl_4096_8191_frms);
+        tmp_stats[i++] = le64_to_cpu(stat_info->rmac_ttl_8192_max_frms);
+        tmp_stats[i++] = le64_to_cpu(stat_info->rmac_ttl_gt_max_frms);
+        tmp_stats[i++] = le64_to_cpu(stat_info->rmac_osized_alt_frms);
+        tmp_stats[i++] = le64_to_cpu(stat_info->rmac_jabber_alt_frms);
+        tmp_stats[i++] = le64_to_cpu(stat_info->rmac_gt_max_alt_frms);
+        tmp_stats[i++] = le64_to_cpu(stat_info->rmac_vlan_frms);
+        tmp_stats[i++] = le32_to_cpu(stat_info->rmac_len_discard);
+        tmp_stats[i++] = le32_to_cpu(stat_info->rmac_fcs_discard);
+        tmp_stats[i++] = le32_to_cpu(stat_info->rmac_pf_discard);
+        tmp_stats[i++] = le32_to_cpu(stat_info->rmac_da_discard);
+        tmp_stats[i++] = le32_to_cpu(stat_info->rmac_red_discard);
+        tmp_stats[i++] = le32_to_cpu(stat_info->rmac_rts_discard);
+        tmp_stats[i++] = le32_to_cpu(stat_info->rmac_ingm_full_discard);
+        tmp_stats[i++] = le32_to_cpu(stat_info->link_fault_cnt);
 	tmp_stats[i++] = 0;
 	tmp_stats[i++] = stat_info->sw_stat.single_ecc_errs;
 	tmp_stats[i++] = stat_info->sw_stat.double_ecc_errs;
+	tmp_stats[i++] = stat_info->sw_stat.parity_err_cnt;
+	tmp_stats[i++] = stat_info->sw_stat.serious_err_cnt;
+	tmp_stats[i++] = stat_info->sw_stat.soft_reset_cnt;
+	tmp_stats[i++] = stat_info->sw_stat.fifo_full_cnt;
+	tmp_stats[i++] = stat_info->sw_stat.ring_full_cnt;
+	tmp_stats[i++] = stat_info->xpak_stat.alarm_transceiver_temp_high;
+	tmp_stats[i++] = stat_info->xpak_stat.alarm_transceiver_temp_low;
+	tmp_stats[i++] = stat_info->xpak_stat.alarm_laser_bias_current_high;
+	tmp_stats[i++] = stat_info->xpak_stat.alarm_laser_bias_current_low;
+	tmp_stats[i++] = stat_info->xpak_stat.alarm_laser_output_power_high;
+	tmp_stats[i++] = stat_info->xpak_stat.alarm_laser_output_power_low;
+	tmp_stats[i++] = stat_info->xpak_stat.warn_transceiver_temp_high;
+	tmp_stats[i++] = stat_info->xpak_stat.warn_transceiver_temp_low;
+	tmp_stats[i++] = stat_info->xpak_stat.warn_laser_bias_current_high;
+	tmp_stats[i++] = stat_info->xpak_stat.warn_laser_bias_current_low;
+	tmp_stats[i++] = stat_info->xpak_stat.warn_laser_output_power_high;
+	tmp_stats[i++] = stat_info->xpak_stat.warn_laser_output_power_low;
 	tmp_stats[i++] = stat_info->sw_stat.clubbed_frms_cnt;
 	tmp_stats[i++] = stat_info->sw_stat.sending_both;
 	tmp_stats[i++] = stat_info->sw_stat.outof_sequence_pkts;
 	tmp_stats[i++] = stat_info->sw_stat.flush_max_pkts;
-	tmp = 0;
 	if (stat_info->sw_stat.num_aggregations) {
-		tmp = stat_info->sw_stat.sum_avg_pkts_aggregated;
-		do_div(tmp, stat_info->sw_stat.num_aggregations);
+		u64 tmp = stat_info->sw_stat.sum_avg_pkts_aggregated;
+		int count = 0;
+		/* 
+		 * Since 64-bit divide does not work on all platforms,
+		 * do repeated subtraction.
+		 */
+		while (tmp >= stat_info->sw_stat.num_aggregations) {
+			tmp -= stat_info->sw_stat.num_aggregations;
+			count++;
+		}
+		tmp_stats[i++] = count;
 	}
-	tmp_stats[i++] = tmp;
+	else
+		tmp_stats[i++] = 0;
 }
 
 static int s2io_ethtool_get_regs_len(struct net_device *dev)
@@ -5709,6 +6211,7 @@ static void s2io_tx_watchdog(struct net_
 
 	if (netif_carrier_ok(dev)) {
 		schedule_work(&sp->rst_timer_task);
+		sp->mac_control.stats_info->sw_stat.soft_reset_cnt++;
 	}
 }
 
@@ -5743,6 +6246,11 @@ static int rx_osm_handler(ring_info_t *r
 	skb->dev = dev;
 
 	if (err) {
+		/* Check for parity error */
+		if (err & 0x1) {
+			sp->mac_control.stats_info->sw_stat.parity_err_cnt++;
+		}
+
 		/*
 		* Drop the packet if bad transfer code. Exception being
 		* 0x5, which could be due to unsupported IPv6 extension header.
diff -upNr bug_fixes1/drivers/net/s2io.h stat_enhancement/drivers/net/s2io.h
--- bug_fixes1/drivers/net/s2io.h	2006-04-19 08:21:12.000000000 -0700
+++ stat_enhancement/drivers/net/s2io.h	2006-04-19 08:21:29.000000000 -0700
@@ -31,6 +31,8 @@
 #define SUCCESS 0
 #define FAILURE -1
 
+#define CHECKBIT(value, nbit) (value & (1 << nbit))
+
 /* Maximum time to flicker LED when asked to identify NIC using ethtool */
 #define MAX_FLICKER_TIME	60000 /* 60 Secs */
 
@@ -78,6 +80,11 @@ static int debug_level = ERR_DBG;
 typedef struct {
 	unsigned long long single_ecc_errs;
 	unsigned long long double_ecc_errs;
+	unsigned long long parity_err_cnt;
+	unsigned long long serious_err_cnt;
+	unsigned long long soft_reset_cnt;
+	unsigned long long fifo_full_cnt;
+	unsigned long long ring_full_cnt;
 	/* LRO statistics */
 	unsigned long long clubbed_frms_cnt;
 	unsigned long long sending_both;
@@ -87,6 +94,25 @@ typedef struct {
 	unsigned long long num_aggregations;
 } swStat_t;
 
+/* Xpak releated alarm and warnings */
+typedef struct {
+	u64 alarm_transceiver_temp_high;
+	u64 alarm_transceiver_temp_low;
+	u64 alarm_laser_bias_current_high;
+	u64 alarm_laser_bias_current_low;
+	u64 alarm_laser_output_power_high;
+	u64 alarm_laser_output_power_low;
+	u64 warn_transceiver_temp_high;
+	u64 warn_transceiver_temp_low;
+	u64 warn_laser_bias_current_high;
+	u64 warn_laser_bias_current_low;
+	u64 warn_laser_output_power_high;
+	u64 warn_laser_output_power_low;
+	u64 xpak_regs_stat;
+	u32 xpak_timer_count;
+} xpakStat_t;
+
+
 /* The statistics block of Xena */
 typedef struct stat_block {
 /* Tx MAC statistics counters. */
@@ -263,7 +289,9 @@ typedef struct stat_block {
 	u32 rmac_accepted_ip_oflow;
 	u32 reserved_14;
 	u32 link_fault_cnt;
+	u8  buffer[20];
 	swStat_t sw_stat;
+	xpakStat_t xpak_stat;
 } StatInfo_t;
 
 /*

