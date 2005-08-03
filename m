From: raghavendra.koushik@neterion.com
Subject: [PATCH 2.6.13-rc4 9/13] S2io: Support for Xframe II NIC
Date: Wed,  3 Aug 2005 12:36:55 -0700 (PDT)
Message-ID: <20050803193655.CB51298355@linux.site>
Cc: raghavendra.koushik@neterion.com, ravinandan.arakali@neterion.com,
        leonid.grossman@neterion.com, rapuru.sriram@neterion.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com, netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,
This patch provides basic support for the Xframe II adapter.
Includes the following changes:
1. New values to program XAUI interface.
2. Print the PCI/PCI-X mode(bus frequency, width).
3. Remove EOI from reset during intialization.
4. Enable all 8 PCCs if Xframe II adapter.
5. Programs the RLDRAM size depending on the device.
(Note: RLDRAM size on XFARME-I is 64Mb whereas on XFRAME-II it's 32 Mb).
6. Enable extended(64-bit) statistics counters.
7. Program timer interrupt duration based on PCI/PCI-X clock speed.
8. Not required to save/restore PCI config space before/after reset.

Signed-off-by: Ravinandan Arakali <ravinandan.arakali@neterion.com>
Signed-off-by: Raghavendra Koushik <raghavendra.koushik@neterion.com>
---
diff -uprN vanilla_linux/drivers/net/s2io-regs.h linux-2.6.13-rc4/drivers/net/s2io-regs.h
--- vanilla_linux/drivers/net/s2io-regs.h	2005-08-02 06:37:37.000000000 -0700
+++ linux-2.6.13-rc4/drivers/net/s2io-regs.h	2005-08-02 06:45:08.000000000 -0700
@@ -91,7 +91,21 @@ typedef struct _XENA_dev_config {
 					SERR_SOURCE_MC		| \
 					SERR_SOURCE_XGXS)
 
-	u8 unused_0[0x800 - 0x120];
+	u64 pci_mode;
+#define	GET_PCI_MODE(val)		((val & vBIT(0xF, 0, 4)) >> 60)
+#define	PCI_MODE_PCI_33			0
+#define	PCI_MODE_PCI_66			0x1
+#define	PCI_MODE_PCIX_M1_66		0x2
+#define	PCI_MODE_PCIX_M1_100		0x3
+#define	PCI_MODE_PCIX_M1_133		0x4
+#define	PCI_MODE_PCIX_M2_66		0x5
+#define	PCI_MODE_PCIX_M2_100		0x6
+#define	PCI_MODE_PCIX_M2_133		0x7
+#define	PCI_MODE_UNSUPPORTED		BIT(0)
+#define	PCI_MODE_32_BITS		BIT(8)
+#define	PCI_MODE_UNKNOWN_MODE		BIT(9)
+
+	u8 unused_0[0x800 - 0x128];
 
 /* PCI-X Controller registers */
 	u64 pic_int_status;
@@ -223,19 +237,16 @@ typedef struct _XENA_dev_config {
 	u64 xmsi_data;
 
 	u64 rx_mat;
+#define RX_MAT_SET(ring, msi)			vBIT(msi, (8 * ring), 8)
 
 	u8 unused6[0x8];
 
-	u64 tx_mat0_7;
-	u64 tx_mat8_15;
-	u64 tx_mat16_23;
-	u64 tx_mat24_31;
-	u64 tx_mat32_39;
-	u64 tx_mat40_47;
-	u64 tx_mat48_55;
-	u64 tx_mat56_63;
+	u64 tx_mat0_n[0x8];
+#define TX_MAT_SET(fifo, msi)			vBIT(msi, (8 * fifo), 8)
 
-	u8 unused_1[0x10];
+	u8 unused_1[0x8];
+	u64 stat_byte_cnt;
+#define STAT_BC(n)                              vBIT(n,4,12)
 
 	/* Automated statistics collection */
 	u64 stat_cfg;
@@ -269,7 +280,12 @@ typedef struct _XENA_dev_config {
 	u64 gpio_control;
 #define GPIO_CTRL_GPIO_0		BIT(8)
 
-	u8 unused7[0x600];
+	u8 unused7_1[0x240 - 0x200];
+
+	u64 wreq_split_mask;
+#define	WREQ_SPLIT_MASK_SET_MASK(val)	vBIT(val, 52, 12)
+
+	u8 unused7_2[0x800 - 0x248];
 
 /* TxDMA registers */
 	u64 txdma_int_status;
@@ -470,6 +486,7 @@ typedef struct _XENA_dev_config {
 #define PRC_CTRL_NO_SNOOP                      (BIT(22)|BIT(23))
 #define PRC_CTRL_NO_SNOOP_DESC                 BIT(22)
 #define PRC_CTRL_NO_SNOOP_BUFF                 BIT(23)
+#define PRC_CTRL_BIMODAL_INTERRUPT             BIT(37)
 #define PRC_CTRL_RXD_BACKOFF_INTERVAL(val)     vBIT(val,40,24)
 
 	u64 prc_alarm_action;
@@ -742,7 +759,19 @@ typedef struct _XENA_dev_config {
 	u64 mc_rldram_test_d1;
 	u8 unused24[0x300 - 0x288];
 	u64 mc_rldram_test_d2;
-	u8 unused25[0x700 - 0x308];
+
+	u8 unused24_1[0x360 - 0x308];
+	u64 mc_rldram_ctrl;
+#define	MC_RLDRAM_ENABLE_ODT		BIT(7)
+
+	u8 unused24_2[0x640 - 0x368];
+	u64 mc_rldram_ref_per_herc;
+#define	MC_RLDRAM_SET_REF_PERIOD(val)	vBIT(val, 0, 16)
+
+	u8 unused24_3[0x660 - 0x648];
+	u64 mc_rldram_mrs_herc;
+
+	u8 unused25[0x700 - 0x668];
 	u64 mc_debug_ctrl;
 
 	u8 unused26[0x3000 - 0x2f08];
diff -uprN vanilla_linux/drivers/net/s2io.c linux-2.6.13-rc4/drivers/net/s2io.c
--- vanilla_linux/drivers/net/s2io.c	2005-08-02 06:37:37.000000000 -0700
+++ linux-2.6.13-rc4/drivers/net/s2io.c	2005-08-02 06:45:08.000000000 -0700
@@ -84,9 +84,10 @@ static inline int RXD_IS_UP2DT(RxD_t *rx
  * problem, 600B, 600C, 600D, 640B, 640C and 640D.
  * macro below identifies these cards given the subsystem_id.
  */
-#define CARDS_WITH_FAULTY_LINK_INDICATORS(subid) \
-		(((subid >= 0x600B) && (subid <= 0x600D)) || \
-		 ((subid >= 0x640B) && (subid <= 0x640D))) ? 1 : 0
+#define CARDS_WITH_FAULTY_LINK_INDICATORS(dev_type, subid) \
+	(dev_type == XFRAME_I_DEVICE) ?			\
+		((((subid >= 0x600B) && (subid <= 0x600D)) || \
+		 ((subid >= 0x640B) && (subid <= 0x640D))) ? 1 : 0) : 0
 
 #define LINK_IS_UP(val64) (!(val64 & (ADAPTER_STATUS_RMAC_REMOTE_FAULT | \
 				      ADAPTER_STATUS_RMAC_LOCAL_FAULT)))
@@ -207,7 +208,24 @@ static void s2io_vlan_rx_kill_vid(struct
 #define SWITCH_SIGN	0xA5A5A5A5A5A5A5A5ULL
 #define	END_SIGN	0x0
 
-static u64 default_mdio_cfg[] = {
+static u64 herc_act_dtx_cfg[] = {
+	/* Set address */
+	0x80000515BA750000ULL, 0x80000515BA7500E0ULL,
+	/* Write data */
+	0x80000515BA750004ULL, 0x80000515BA7500E4ULL,
+	/* Set address */
+	0x80010515003F0000ULL, 0x80010515003F00E0ULL,
+	/* Write data */
+	0x80010515003F0004ULL, 0x80010515003F00E4ULL,
+	/* Set address */
+	0x80020515F2100000ULL, 0x80020515F21000E0ULL,
+	/* Write data */
+	0x80020515F2100004ULL, 0x80020515F21000E4ULL,
+	/* Done */
+	END_SIGN
+};
+
+static u64 xena_mdio_cfg[] = {
 	/* Reset PMA PLL */
 	0xC001010000000000ULL, 0xC0010100000000E0ULL,
 	0xC0010100008000E4ULL,
@@ -217,7 +235,7 @@ static u64 default_mdio_cfg[] = {
 	END_SIGN
 };
 
-static u64 default_dtx_cfg[] = {
+static u64 xena_dtx_cfg[] = {
 	0x8000051500000000ULL, 0x80000515000000E0ULL,
 	0x80000515D93500E4ULL, 0x8001051500000000ULL,
 	0x80010515000000E0ULL, 0x80010515001E00E4ULL,
@@ -656,6 +674,87 @@ static void free_shared_mem(struct s2io_
 }
 
 /**
+ * s2io_verify_pci_mode -
+ */
+
+static int s2io_verify_pci_mode(nic_t *nic)
+{
+	XENA_dev_config_t *bar0 = (XENA_dev_config_t *) nic->bar0;
+	register u64 val64 = 0;
+	int     mode;
+
+	val64 = readq(&bar0->pci_mode);
+	mode = (u8)GET_PCI_MODE(val64);
+
+	if ( val64 & PCI_MODE_UNKNOWN_MODE)
+		return -1;      /* Unknown PCI mode */
+	return mode;
+}
+
+
+/**
+ * s2io_print_pci_mode -
+ */
+static int s2io_print_pci_mode(nic_t *nic)
+{
+	XENA_dev_config_t *bar0 = (XENA_dev_config_t *) nic->bar0;
+	register u64 val64 = 0;
+	int	mode;
+	struct config_param *config = &nic->config;
+
+	val64 = readq(&bar0->pci_mode);
+	mode = (u8)GET_PCI_MODE(val64);
+
+	if ( val64 & PCI_MODE_UNKNOWN_MODE)
+		return -1;	/* Unknown PCI mode */
+
+	if (val64 & PCI_MODE_32_BITS) {
+		DBG_PRINT(ERR_DBG, "%s: Device is on 32 bit ", nic->dev->name);
+	} else {
+		DBG_PRINT(ERR_DBG, "%s: Device is on 64 bit ", nic->dev->name);
+	}
+
+	switch(mode) {
+		case PCI_MODE_PCI_33:
+			DBG_PRINT(ERR_DBG, "33MHz PCI bus\n");
+			config->bus_speed = 33;
+			break;
+		case PCI_MODE_PCI_66:
+			DBG_PRINT(ERR_DBG, "66MHz PCI bus\n");
+			config->bus_speed = 133;
+			break;
+		case PCI_MODE_PCIX_M1_66:
+			DBG_PRINT(ERR_DBG, "66MHz PCIX(M1) bus\n");
+			config->bus_speed = 133; /* Herc doubles the clock rate */
+			break;
+		case PCI_MODE_PCIX_M1_100:
+			DBG_PRINT(ERR_DBG, "100MHz PCIX(M1) bus\n");
+			config->bus_speed = 200;
+			break;
+		case PCI_MODE_PCIX_M1_133:
+			DBG_PRINT(ERR_DBG, "133MHz PCIX(M1) bus\n");
+			config->bus_speed = 266;
+			break;
+		case PCI_MODE_PCIX_M2_66:
+			DBG_PRINT(ERR_DBG, "133MHz PCIX(M2) bus\n");
+			config->bus_speed = 133;
+			break;
+		case PCI_MODE_PCIX_M2_100:
+			DBG_PRINT(ERR_DBG, "200MHz PCIX(M2) bus\n");
+			config->bus_speed = 200;
+			break;
+		case PCI_MODE_PCIX_M2_133:
+			DBG_PRINT(ERR_DBG, "266MHz PCIX(M2) bus\n");
+			config->bus_speed = 266;
+			break;
+		default:
+			return -1;	/* Unsupported bus speed */
+	}
+
+	return mode;
+}
+
+/**
  *  init_nic - Initialization of hardware
  *  @nic: device peivate variable
  *  Description: The function sequentially configures every block
@@ -687,6 +786,16 @@ static int init_nic(struct s2io_nic *nic
 		return -1;
 	}
 
+	/*
+	 * Herc requires EOI to be removed from reset before XGXS, so..
+	 */
+	if (nic->device_type & XFRAME_II_DEVICE) {
+		val64 = 0xA500000000ULL;
+		writeq(val64, &bar0->sw_reset);
+		msleep(500);
+		val64 = readq(&bar0->sw_reset);
+	}
+
 	/* Remove XGXS from reset state */
 	val64 = 0;
 	writeq(val64, &bar0->sw_reset);
@@ -718,41 +827,51 @@ static int init_nic(struct s2io_nic *nic
 	 * of 64 bit values into two registers in a particular
 	 * sequence. Hence a macro 'SWITCH_SIGN' has been defined
 	 * which will be defined in the array of configuration values
-	 * (default_dtx_cfg & default_mdio_cfg) at appropriate places
+	 * (xena_dtx_cfg & xena_mdio_cfg) at appropriate places
 	 * to switch writing from one regsiter to another. We continue
 	 * writing these values until we encounter the 'END_SIGN' macro.
 	 * For example, After making a series of 21 writes into
 	 * dtx_control register the 'SWITCH_SIGN' appears and hence we
 	 * start writing into mdio_control until we encounter END_SIGN.
 	 */
-	while (1) {
-	      dtx_cfg:
-		while (default_dtx_cfg[dtx_cnt] != END_SIGN) {
-			if (default_dtx_cfg[dtx_cnt] == SWITCH_SIGN) {
-				dtx_cnt++;
-				goto mdio_cfg;
-			}
-			SPECIAL_REG_WRITE(default_dtx_cfg[dtx_cnt],
+	if (nic->device_type & XFRAME_II_DEVICE) {
+		while (herc_act_dtx_cfg[dtx_cnt] != END_SIGN) {
+			SPECIAL_REG_WRITE(xena_dtx_cfg[dtx_cnt],
 					  &bar0->dtx_control, UF);
-			val64 = readq(&bar0->dtx_control);
+			if (dtx_cnt & 0x1)
+				msleep(1); /* Necessary!! */
 			dtx_cnt++;
 		}
-	      mdio_cfg:
-		while (default_mdio_cfg[mdio_cnt] != END_SIGN) {
-			if (default_mdio_cfg[mdio_cnt] == SWITCH_SIGN) {
+	} else {
+		while (1) {
+		      dtx_cfg:
+			while (xena_dtx_cfg[dtx_cnt] != END_SIGN) {
+				if (xena_dtx_cfg[dtx_cnt] == SWITCH_SIGN) {
+					dtx_cnt++;
+					goto mdio_cfg;
+				}
+				SPECIAL_REG_WRITE(xena_dtx_cfg[dtx_cnt],
+						  &bar0->dtx_control, UF);
+				val64 = readq(&bar0->dtx_control);
+				dtx_cnt++;
+			}
+		      mdio_cfg:
+			while (xena_mdio_cfg[mdio_cnt] != END_SIGN) {
+				if (xena_mdio_cfg[mdio_cnt] == SWITCH_SIGN) {
+					mdio_cnt++;
+					goto dtx_cfg;
+				}
+				SPECIAL_REG_WRITE(xena_mdio_cfg[mdio_cnt],
+						  &bar0->mdio_control, UF);
+				val64 = readq(&bar0->mdio_control);
 				mdio_cnt++;
+			}
+			if ((xena_dtx_cfg[dtx_cnt] == END_SIGN) &&
+			    (xena_mdio_cfg[mdio_cnt] == END_SIGN)) {
+				break;
+			} else {
 				goto dtx_cfg;
 			}
-			SPECIAL_REG_WRITE(default_mdio_cfg[mdio_cnt],
-					  &bar0->mdio_control, UF);
-			val64 = readq(&bar0->mdio_control);
-			mdio_cnt++;
-		}
-		if ((default_dtx_cfg[dtx_cnt] == END_SIGN) &&
-		    (default_mdio_cfg[mdio_cnt] == END_SIGN)) {
-			break;
-		} else {
-			goto dtx_cfg;
 		}
 	}
 
@@ -803,7 +922,8 @@ static int init_nic(struct s2io_nic *nic
 	 * Disable 4 PCCs for Xena1, 2 and 3 as per H/W bug
 	 * SXE-008 TRANSMIT DMA ARBITRATION ISSUE.
 	 */
-	if (get_xena_rev_id(nic->pdev) < 4)
+	if ((nic->device_type == XFRAME_I_DEVICE) &&
+		(get_xena_rev_id(nic->pdev) < 4))
 		writeq(PCC_ENABLE_FOUR, &bar0->pcc_enable);
 
 	val64 = readq(&bar0->tx_fifo_partition_0);
@@ -833,7 +953,11 @@ static int init_nic(struct s2io_nic *nic
 	 * configured Rings.
 	 */
 	val64 = 0;
-	mem_size = 64;
+	if (nic->device_type & XFRAME_II_DEVICE)
+		mem_size = 32;
+	else
+		mem_size = 64;
+
 	for (i = 0; i < config->rx_ring_num; i++) {
 		switch (i) {
 		case 0:
@@ -1116,6 +1240,11 @@ static int init_nic(struct s2io_nic *nic
 	/* Program statistics memory */
 	writeq(mac_control->stats_mem_phy, &bar0->stat_addr);
 
+	if (nic->device_type == XFRAME_II_DEVICE) {
+		val64 = STAT_BC(0x320);
+		writeq(val64, &bar0->stat_byte_cnt);
+	}
+
 	/*
 	 * Initializing the sampling rate for the device to calculate the
 	 * bandwidth utilization.
@@ -1134,12 +1263,18 @@ static int init_nic(struct s2io_nic *nic
 	 * 250 interrupts per sec. Continuous interrupts are enabled
 	 * by default.
 	 */
-	val64 = TTI_DATA1_MEM_TX_TIMER_VAL(0x2078) |
-	    TTI_DATA1_MEM_TX_URNG_A(0xA) |
+	if (nic->device_type == XFRAME_II_DEVICE) {
+		int count = (nic->config.bus_speed * 125)/2;
+		val64 = TTI_DATA1_MEM_TX_TIMER_VAL(count);
+	} else {
+
+		val64 = TTI_DATA1_MEM_TX_TIMER_VAL(0x2078);
+	}
+	val64 |= TTI_DATA1_MEM_TX_URNG_A(0xA) |
 	    TTI_DATA1_MEM_TX_URNG_B(0x10) |
 	    TTI_DATA1_MEM_TX_URNG_C(0x30) | TTI_DATA1_MEM_TX_TIMER_AC_EN;
-	if (use_continuous_tx_intrs)
-		val64 |= TTI_DATA1_MEM_TX_TIMER_CI_EN;
+		if (use_continuous_tx_intrs)
+			val64 |= TTI_DATA1_MEM_TX_TIMER_CI_EN;
 	writeq(val64, &bar0->tti_data1_mem);
 
 	val64 = TTI_DATA2_MEM_TX_UFC_A(0x10) |
@@ -1171,9 +1306,19 @@ static int init_nic(struct s2io_nic *nic
 		time++;
 	}
 
+
 	/* RTI Initialization */
-	val64 = RTI_DATA1_MEM_RX_TIMER_VAL(0xFFF) |
-	    RTI_DATA1_MEM_RX_URNG_A(0xA) |
+	if (nic->device_type == XFRAME_II_DEVICE) {
+		/*
+		 * Programmed to generate Apprx 500 Intrs per
+		 * second
+		 */
+		int count = (nic->config.bus_speed * 125)/4;
+		val64 = RTI_DATA1_MEM_RX_TIMER_VAL(count);
+	} else {
+		val64 = RTI_DATA1_MEM_RX_TIMER_VAL(0xFFF);
+	}
+	val64 |= RTI_DATA1_MEM_RX_URNG_A(0xA) |
 	    RTI_DATA1_MEM_RX_URNG_B(0x10) |
 	    RTI_DATA1_MEM_RX_URNG_C(0x30) | RTI_DATA1_MEM_RX_TIMER_AC_EN;
 
@@ -1267,6 +1412,15 @@ static int init_nic(struct s2io_nic *nic
 	val64 |= PIC_CNTL_SHARED_SPLITS(shared_splits);
 	writeq(val64, &bar0->pic_control);
 
+	/*
+	 * Programming the Herc to split every write transaction
+	 * that does not start on an ADB to reduce disconnects.
+	 */
+	if (nic->device_type == XFRAME_II_DEVICE) {
+		val64 = WREQ_SPLIT_MASK_SET_MASK(255);
+		writeq(val64, &bar0->wreq_split_mask);
+	}
+
 	return SUCCESS;
 }
 
@@ -1509,18 +1663,18 @@ static void en_dis_able_nic_intrs(struct
 	}
 }
 
-static int check_prc_pcc_state(u64 val64, int flag, int rev_id)
+static int check_prc_pcc_state(u64 val64, int flag, int rev_id, int herc)
 {
 	int ret = 0;
 
 	if (flag == FALSE) {
-		if (rev_id >= 4) {
+		if ((!herc && (rev_id >= 4)) || herc) {
 			if (!(val64 & ADAPTER_STATUS_RMAC_PCC_IDLE) &&
 			    ((val64 & ADAPTER_STATUS_RC_PRC_QUIESCENT) ==
 			     ADAPTER_STATUS_RC_PRC_QUIESCENT)) {
 				ret = 1;
 			}
-		} else {
+		}else {
 			if (!(val64 & ADAPTER_STATUS_RMAC_PCC_FOUR_IDLE) &&
 			    ((val64 & ADAPTER_STATUS_RC_PRC_QUIESCENT) ==
 			     ADAPTER_STATUS_RC_PRC_QUIESCENT)) {
@@ -1528,7 +1682,7 @@ static int check_prc_pcc_state(u64 val64
 			}
 		}
 	} else {
-		if (rev_id >= 4) {
+		if ((!herc && (rev_id >= 4)) || herc) {
 			if (((val64 & ADAPTER_STATUS_RMAC_PCC_IDLE) ==
 			     ADAPTER_STATUS_RMAC_PCC_IDLE) &&
 			    (!(val64 & ADAPTER_STATUS_RC_PRC_QUIESCENT) ||
@@ -1564,10 +1718,11 @@ static int check_prc_pcc_state(u64 val64
 
 static int verify_xena_quiescence(nic_t *sp, u64 val64, int flag)
 {
-	int ret = 0;
+	int ret = 0, herc;
 	u64 tmp64 = ~((u64) val64);
 	int rev_id = get_xena_rev_id(sp->pdev);
 
+	herc = (sp->device_type == XFRAME_II_DEVICE);
 	if (!
 	    (tmp64 &
 	     (ADAPTER_STATUS_TDMA_READY | ADAPTER_STATUS_RDMA_READY |
@@ -1575,7 +1730,7 @@ static int verify_xena_quiescence(nic_t 
 	      ADAPTER_STATUS_PIC_QUIESCENT | ADAPTER_STATUS_MC_DRAM_READY |
 	      ADAPTER_STATUS_MC_QUEUES_READY | ADAPTER_STATUS_M_PLL_LOCK |
 	      ADAPTER_STATUS_P_PLL_LOCK))) {
-		ret = check_prc_pcc_state(val64, flag, rev_id);
+		ret = check_prc_pcc_state(val64, flag, rev_id, herc);
 	}
 
 	return ret;
@@ -1706,7 +1861,8 @@ static int start_nic(struct s2io_nic *ni
 
 	/* SXE-002: Initialize link and activity LED */
 	subid = nic->pdev->subsystem_device;
-	if ((subid & 0xFF) >= 0x07) {
+	if (((subid & 0xFF) >= 0x07) &&
+	    (nic->device_type == XFRAME_I_DEVICE)) {
 		val64 = readq(&bar0->gpio_control);
 		val64 |= 0x0000800000000000ULL;
 		writeq(val64, &bar0->gpio_control);
@@ -2541,9 +2697,12 @@ void s2io_reset(nic_t * sp)
 	 */
 	msleep(250);
 
+	if (!(sp->device_type & XFRAME_II_DEVICE)) {
 	/* Restore the PCI state saved during initializarion. */
-	pci_restore_state(sp->pdev);
-
+		pci_restore_state(sp->pdev);
+	} else {
+		pci_set_master(sp->pdev);
+	}
 	s2io_init_pci(sp);
 
 	msleep(250);
@@ -2568,7 +2727,8 @@ void s2io_reset(nic_t * sp)
 
 	/* SXE-002: Configure link and activity LED to turn it off */
 	subid = sp->pdev->subsystem_device;
-	if ((subid & 0xFF) >= 0x07) {
+	if (((subid & 0xFF) >= 0x07) &&
+	    (sp->device_type == XFRAME_I_DEVICE)) {
 		val64 = readq(&bar0->gpio_control);
 		val64 |= 0x0000800000000000ULL;
 		writeq(val64, &bar0->gpio_control);
@@ -2576,6 +2736,15 @@ void s2io_reset(nic_t * sp)
 		writeq(val64, (void __iomem *) ((u8 *) bar0 + 0x2700));
 	}
 
+	/*
+	 * Clear spurious ECC interrupts that would have occured on
+	 * XFRAME II cards after reset.
+	 */
+	if (sp->device_type == XFRAME_II_DEVICE) {
+		val64 = readq(&bar0->pcc_err_reg);
+		writeq(val64, &bar0->pcc_err_reg);
+	}
+
 	sp->device_enabled_once = FALSE;
 }
 
@@ -3463,7 +3632,8 @@ static void s2io_phy_id(unsigned long da
 	u16 subid;
 
 	subid = sp->pdev->subsystem_device;
-	if ((subid & 0xFF) >= 0x07) {
+	if ((sp->device_type == XFRAME_II_DEVICE) ||
+		   ((subid & 0xFF) >= 0x07)) {
 		val64 = readq(&bar0->gpio_control);
 		val64 ^= GPIO_CTRL_GPIO_0;
 		writeq(val64, &bar0->gpio_control);
@@ -3500,7 +3670,8 @@ static int s2io_ethtool_idnic(struct net
 
 	subid = sp->pdev->subsystem_device;
 	last_gpio_ctrl_val = readq(&bar0->gpio_control);
-	if ((subid & 0xFF) < 0x07) {
+	if ((sp->device_type == XFRAME_I_DEVICE) &&
+		((subid & 0xFF) < 0x07)) {
 		val64 = readq(&bar0->adapter_control);
 		if (!(val64 & ADAPTER_CNTL_EN)) {
 			printk(KERN_ERR
@@ -3520,7 +3691,7 @@ static int s2io_ethtool_idnic(struct net
 		msleep_interruptible(MAX_FLICKER_TIME);
 	del_timer_sync(&sp->id_timer);
 
-	if (CARDS_WITH_FAULTY_LINK_INDICATORS(subid)) {
+	if (CARDS_WITH_FAULTY_LINK_INDICATORS(sp->device_type, subid)) {
 		writeq(last_gpio_ctrl_val, &bar0->gpio_control);
 		last_gpio_ctrl_val = readq(&bar0->gpio_control);
 	}
@@ -4134,44 +4305,91 @@ static void s2io_get_ethtool_stats(struc
 	StatInfo_t *stat_info = sp->mac_control.stats_info;
 
 	s2io_updt_stats(sp);
-	tmp_stats[i++] = le32_to_cpu(stat_info->tmac_frms);
-	tmp_stats[i++] = le32_to_cpu(stat_info->tmac_data_octets);
+	tmp_stats[i++] =
+		(u64)le32_to_cpu(stat_info->tmac_frms_oflow) << 32  |
+		le32_to_cpu(stat_info->tmac_frms);
+	tmp_stats[i++] =
+		(u64)le32_to_cpu(stat_info->tmac_data_octets_oflow) << 32 |
+		le32_to_cpu(stat_info->tmac_data_octets);
 	tmp_stats[i++] = le64_to_cpu(stat_info->tmac_drop_frms);
-	tmp_stats[i++] = le32_to_cpu(stat_info->tmac_mcst_frms);
-	tmp_stats[i++] = le32_to_cpu(stat_info->tmac_bcst_frms);
+	tmp_stats[i++] =
+		(u64)le32_to_cpu(stat_info->tmac_mcst_frms_oflow) << 32 |
+		le32_to_cpu(stat_info->tmac_mcst_frms);
+	tmp_stats[i++] =
+		(u64)le32_to_cpu(stat_info->tmac_bcst_frms_oflow) << 32 |
+		le32_to_cpu(stat_info->tmac_bcst_frms);
 	tmp_stats[i++] = le64_to_cpu(stat_info->tmac_pause_ctrl_frms);
-	tmp_stats[i++] = le32_to_cpu(stat_info->tmac_any_err_frms);
+	tmp_stats[i++] =
+		(u64)le32_to_cpu(stat_info->tmac_any_err_frms_oflow) << 32 |
+		le32_to_cpu(stat_info->tmac_any_err_frms);
 	tmp_stats[i++] = le64_to_cpu(stat_info->tmac_vld_ip_octets);
-	tmp_stats[i++] = le32_to_cpu(stat_info->tmac_vld_ip);
-	tmp_stats[i++] = le32_to_cpu(stat_info->tmac_drop_ip);
-	tmp_stats[i++] = le32_to_cpu(stat_info->tmac_icmp);
-	tmp_stats[i++] = le32_to_cpu(stat_info->tmac_rst_tcp);
+	tmp_stats[i++] =
+		(u64)le32_to_cpu(stat_info->tmac_vld_ip_oflow) << 32 |
+		le32_to_cpu(stat_info->tmac_vld_ip);
+	tmp_stats[i++] =
+		(u64)le32_to_cpu(stat_info->tmac_drop_ip_oflow) << 32 |
+		le32_to_cpu(stat_info->tmac_drop_ip);
+	tmp_stats[i++] =
+		(u64)le32_to_cpu(stat_info->tmac_icmp_oflow) << 32 |
+		le32_to_cpu(stat_info->tmac_icmp);
+	tmp_stats[i++] =
+		(u64)le32_to_cpu(stat_info->tmac_rst_tcp_oflow) << 32 |
+		le32_to_cpu(stat_info->tmac_rst_tcp);
 	tmp_stats[i++] = le64_to_cpu(stat_info->tmac_tcp);
-	tmp_stats[i++] = le32_to_cpu(stat_info->tmac_udp);
-	tmp_stats[i++] = le32_to_cpu(stat_info->rmac_vld_frms);
-	tmp_stats[i++] = le32_to_cpu(stat_info->rmac_data_octets);
+	tmp_stats[i++] = (u64)le32_to_cpu(stat_info->tmac_udp_oflow) << 32 |
+		le32_to_cpu(stat_info->tmac_udp);
+	tmp_stats[i++] =
+		(u64)le32_to_cpu(stat_info->rmac_vld_frms_oflow) << 32 |
+		le32_to_cpu(stat_info->rmac_vld_frms);
+	tmp_stats[i++] =
+		(u64)le32_to_cpu(stat_info->rmac_data_octets_oflow) << 32 |
+		le32_to_cpu(stat_info->rmac_data_octets);
 	tmp_stats[i++] = le64_to_cpu(stat_info->rmac_fcs_err_frms);
 	tmp_stats[i++] = le64_to_cpu(stat_info->rmac_drop_frms);
-	tmp_stats[i++] = le32_to_cpu(stat_info->rmac_vld_mcst_frms);
-	tmp_stats[i++] = le32_to_cpu(stat_info->rmac_vld_bcst_frms);
+	tmp_stats[i++] =
+		(u64)le32_to_cpu(stat_info->rmac_vld_mcst_frms_oflow) << 32 |
+		le32_to_cpu(stat_info->rmac_vld_mcst_frms);
+	tmp_stats[i++] =
+		(u64)le32_to_cpu(stat_info->rmac_vld_bcst_frms_oflow) << 32 |
+		le32_to_cpu(stat_info->rmac_vld_bcst_frms);
 	tmp_stats[i++] = le32_to_cpu(stat_info->rmac_in_rng_len_err_frms);
 	tmp_stats[i++] = le64_to_cpu(stat_info->rmac_long_frms);
 	tmp_stats[i++] = le64_to_cpu(stat_info->rmac_pause_ctrl_frms);
-	tmp_stats[i++] = le32_to_cpu(stat_info->rmac_discarded_frms);
-	tmp_stats[i++] = le32_to_cpu(stat_info->rmac_usized_frms);
-	tmp_stats[i++] = le32_to_cpu(stat_info->rmac_osized_frms);
-	tmp_stats[i++] = le32_to_cpu(stat_info->rmac_frag_frms);
-	tmp_stats[i++] = le32_to_cpu(stat_info->rmac_jabber_frms);
-	tmp_stats[i++] = le32_to_cpu(stat_info->rmac_ip);
+	tmp_stats[i++] =
+		(u64)le32_to_cpu(stat_info->rmac_discarded_frms_oflow) << 32 |
+		le32_to_cpu(stat_info->rmac_discarded_frms);
+	tmp_stats[i++] =
+		(u64)le32_to_cpu(stat_info->rmac_usized_frms_oflow) << 32 |
+		le32_to_cpu(stat_info->rmac_usized_frms);
+	tmp_stats[i++] =
+		(u64)le32_to_cpu(stat_info->rmac_osized_frms_oflow) << 32 |
+		le32_to_cpu(stat_info->rmac_osized_frms);
+	tmp_stats[i++] =
+		(u64)le32_to_cpu(stat_info->rmac_frag_frms_oflow) << 32 |
+		le32_to_cpu(stat_info->rmac_frag_frms);
+	tmp_stats[i++] =
+		(u64)le32_to_cpu(stat_info->rmac_jabber_frms_oflow) << 32 |
+		le32_to_cpu(stat_info->rmac_jabber_frms);
+	tmp_stats[i++] = (u64)le32_to_cpu(stat_info->rmac_ip_oflow) << 32 |
+		le32_to_cpu(stat_info->rmac_ip);
 	tmp_stats[i++] = le64_to_cpu(stat_info->rmac_ip_octets);
 	tmp_stats[i++] = le32_to_cpu(stat_info->rmac_hdr_err_ip);
-	tmp_stats[i++] = le32_to_cpu(stat_info->rmac_drop_ip);
-	tmp_stats[i++] = le32_to_cpu(stat_info->rmac_icmp);
+	tmp_stats[i++] = (u64)le32_to_cpu(stat_info->rmac_drop_ip_oflow) << 32 |
+		le32_to_cpu(stat_info->rmac_drop_ip);
+	tmp_stats[i++] = (u64)le32_to_cpu(stat_info->rmac_icmp_oflow) << 32 |
+		le32_to_cpu(stat_info->rmac_icmp);
 	tmp_stats[i++] = le64_to_cpu(stat_info->rmac_tcp);
-	tmp_stats[i++] = le32_to_cpu(stat_info->rmac_udp);
-	tmp_stats[i++] = le32_to_cpu(stat_info->rmac_err_drp_udp);
-	tmp_stats[i++] = le32_to_cpu(stat_info->rmac_pause_cnt);
-	tmp_stats[i++] = le32_to_cpu(stat_info->rmac_accepted_ip);
+	tmp_stats[i++] = (u64)le32_to_cpu(stat_info->rmac_udp_oflow) << 32 |
+		le32_to_cpu(stat_info->rmac_udp);
+	tmp_stats[i++] =
+		(u64)le32_to_cpu(stat_info->rmac_err_drp_udp_oflow) << 32 |
+		le32_to_cpu(stat_info->rmac_err_drp_udp);
+	tmp_stats[i++] =
+		(u64)le32_to_cpu(stat_info->rmac_pause_cnt_oflow) << 32 |
+		le32_to_cpu(stat_info->rmac_pause_cnt);
+	tmp_stats[i++] =
+		(u64)le32_to_cpu(stat_info->rmac_accepted_ip_oflow) << 32 |
+		le32_to_cpu(stat_info->rmac_accepted_ip);
 	tmp_stats[i++] = le32_to_cpu(stat_info->rmac_err_tcp);
 	tmp_stats[i++] = 0;
 	tmp_stats[i++] = stat_info->sw_stat.single_ecc_errs;
@@ -4401,7 +4619,8 @@ static void s2io_set_link(unsigned long 
 			val64 = readq(&bar0->adapter_control);
 			val64 |= ADAPTER_CNTL_EN;
 			writeq(val64, &bar0->adapter_control);
-			if (CARDS_WITH_FAULTY_LINK_INDICATORS(subid)) {
+			if (CARDS_WITH_FAULTY_LINK_INDICATORS(nic->device_type,
+							     subid)) {
 				val64 = readq(&bar0->gpio_control);
 				val64 |= GPIO_CTRL_GPIO_0;
 				writeq(val64, &bar0->gpio_control);
@@ -4423,7 +4642,8 @@ static void s2io_set_link(unsigned long 
 			}
 			s2io_link(nic, LINK_UP);
 		} else {
-			if (CARDS_WITH_FAULTY_LINK_INDICATORS(subid)) {
+			if (CARDS_WITH_FAULTY_LINK_INDICATORS(nic->device_type,
+							      subid)) {
 				val64 = readq(&bar0->gpio_control);
 				val64 &= ~GPIO_CTRL_GPIO_0;
 				writeq(val64, &bar0->gpio_control);
@@ -4708,7 +4928,6 @@ static int rx_osm_handler(ring_info_t *r
 		netif_rx(skb);
 	}
 #endif
-
 	dev->last_rx = jiffies;
 	atomic_dec(&sp->rx_bufs_left[ring_no]);
 	return SUCCESS;
@@ -4842,6 +5061,7 @@ s2io_init_nic(struct pci_dev *pdev, cons
 	u16 subid;
 	mac_info_t *mac_control;
 	struct config_param *config;
+	int mode;
 
 #ifdef CONFIG_S2IO_NAPI
 	DBG_PRINT(ERR_DBG, "NAPI support has been enabled\n");
@@ -4898,6 +5118,12 @@ s2io_init_nic(struct pci_dev *pdev, cons
 	sp->high_dma_flag = dma_flag;
 	sp->device_enabled_once = FALSE;
 
+	if ((pdev->device == PCI_DEVICE_ID_HERC_WIN) ||
+		(pdev->device == PCI_DEVICE_ID_HERC_UNI))
+		sp->device_type = XFRAME_II_DEVICE;
+	else
+		sp->device_type = XFRAME_I_DEVICE;
+
 	/* Initialize some PCI/PCI-X fields of the NIC. */
 	s2io_init_pci(sp);
 
@@ -5033,7 +5259,9 @@ s2io_init_nic(struct pci_dev *pdev, cons
 	INIT_WORK(&sp->set_link_task,
 		  (void (*)(void *)) s2io_set_link, sp);
 
-	pci_save_state(sp->pdev);
+	if (!(sp->device_type & XFRAME_II_DEVICE)) {
+		pci_save_state(sp->pdev);
+	}
 
 	/* Setting swapper control on the NIC, for proper reset operation */
 	if (s2io_set_swapper(sp)) {
@@ -5043,12 +5271,26 @@ s2io_init_nic(struct pci_dev *pdev, cons
 		goto set_swap_failed;
 	}
 
-	/*
-	 * Fix for all "FFs" MAC address problems observed on
-	 * Alpha platforms
-	 */
-	fix_mac_address(sp);
-	s2io_reset(sp);
+	/* Verify if the Herc works on the slot its placed into */
+	if (sp->device_type & XFRAME_II_DEVICE) {
+		mode = s2io_verify_pci_mode(sp);
+		if (mode < 0) {
+			DBG_PRINT(ERR_DBG, "%s: ", __FUNCTION__);
+			DBG_PRINT(ERR_DBG, " Unsupported PCI bus mode\n");
+			ret = -EBADSLT;
+			goto set_swap_failed;
+		}
+	}
+
+	/* Not needed for Herc */
+	if (sp->device_type & XFRAME_I_DEVICE) {
+		/*
+		 * Fix for all "FFs" MAC address problems observed on
+		 * Alpha platforms
+		 */
+		fix_mac_address(sp);
+		s2io_reset(sp);
+	}
 
 	/*
 	 * MAC address initialization.
@@ -5073,22 +5315,13 @@ s2io_init_nic(struct pci_dev *pdev, cons
 	sp->def_mac_addr[0].mac_addr[5] = (u8) (mac_down >> 16);
 	sp->def_mac_addr[0].mac_addr[4] = (u8) (mac_down >> 24);
 
-	DBG_PRINT(INIT_DBG,
-		  "DEFAULT MAC ADDR:0x%02x-%02x-%02x-%02x-%02x-%02x\n",
-		  sp->def_mac_addr[0].mac_addr[0],
-		  sp->def_mac_addr[0].mac_addr[1],
-		  sp->def_mac_addr[0].mac_addr[2],
-		  sp->def_mac_addr[0].mac_addr[3],
-		  sp->def_mac_addr[0].mac_addr[4],
-		  sp->def_mac_addr[0].mac_addr[5]);
-
 	/*  Set the factory defined MAC address initially   */
 	dev->addr_len = ETH_ALEN;
 	memcpy(dev->dev_addr, sp->def_mac_addr, ETH_ALEN);
 
 	/*
 	 * Initialize the tasklet status and link state flags
-	 * and the card statte parameter
+	 * and the card state parameter
 	 */
 	atomic_set(&(sp->card_state), 0);
 	sp->tasklet_status = 0;
@@ -5123,9 +5356,46 @@ s2io_init_nic(struct pci_dev *pdev, cons
 		goto register_failed;
 	}
 
+	if (sp->device_type & XFRAME_II_DEVICE) {
+		DBG_PRINT(ERR_DBG, "%s: Neterion Xframe II 10GbE adapter ",
+			  dev->name);
+		DBG_PRINT(ERR_DBG, "(rev %d), Driver %s\n",
+				get_xena_rev_id(sp->pdev),
+				s2io_driver_version);
+		DBG_PRINT(ERR_DBG, "MAC ADDR: %02x:%02x:%02x:%02x:%02x:%02x\n",
+			  sp->def_mac_addr[0].mac_addr[0],
+			  sp->def_mac_addr[0].mac_addr[1],
+			  sp->def_mac_addr[0].mac_addr[2],
+			  sp->def_mac_addr[0].mac_addr[3],
+			  sp->def_mac_addr[0].mac_addr[4],
+			  sp->def_mac_addr[0].mac_addr[5]);
+		int mode = s2io_print_pci_mode(sp);
+		if (mode < 0) {
+			DBG_PRINT(ERR_DBG, " Unsupported PCI bus mode ");
+			ret = -EBADSLT;
+			goto set_swap_failed;
+		}
+	} else {
+		DBG_PRINT(ERR_DBG, "%s: Neterion Xframe I 10GbE adapter ",
+			  dev->name);
+		DBG_PRINT(ERR_DBG, "(rev %d), Driver %s\n",
+					get_xena_rev_id(sp->pdev),
+					s2io_driver_version);
+		DBG_PRINT(ERR_DBG, "MAC ADDR: %02x:%02x:%02x:%02x:%02x:%02x\n",
+			  sp->def_mac_addr[0].mac_addr[0],
+			  sp->def_mac_addr[0].mac_addr[1],
+			  sp->def_mac_addr[0].mac_addr[2],
+			  sp->def_mac_addr[0].mac_addr[3],
+			  sp->def_mac_addr[0].mac_addr[4],
+			  sp->def_mac_addr[0].mac_addr[5]);
+	}
+
 	/* Initialize device name */
 	strcpy(sp->name, dev->name);
-	strcat(sp->name, ": Neterion Xframe I 10GbE adapter");
+	if (sp->device_type & XFRAME_II_DEVICE)
+		strcat(sp->name, ": Neterion Xframe II 10GbE adapter");
+	else
+		strcat(sp->name, ": Neterion Xframe I 10GbE adapter");
 
 	/*
 	 * Make Link state as off at this point, when the Link change
diff -uprN vanilla_linux/drivers/net/s2io.h linux-2.6.13-rc4/drivers/net/s2io.h
--- vanilla_linux/drivers/net/s2io.h	2005-08-02 06:37:37.000000000 -0700
+++ linux-2.6.13-rc4/drivers/net/s2io.h	2005-08-02 06:45:08.000000000 -0700
@@ -201,6 +201,67 @@ typedef struct stat_block {
 	u32 rxf_wr_cnt;
 	u32 txf_rd_cnt;
 
+/* Tx MAC statistics overflow counters. */
+	u32 tmac_data_octets_oflow;
+	u32 tmac_frms_oflow;
+	u32 tmac_bcst_frms_oflow;
+	u32 tmac_mcst_frms_oflow;
+	u32 tmac_ucst_frms_oflow;
+	u32 tmac_ttl_octets_oflow;
+	u32 tmac_any_err_frms_oflow;
+	u32 tmac_nucst_frms_oflow;
+	u64 tmac_vlan_frms;
+	u32 tmac_drop_ip_oflow;
+	u32 tmac_vld_ip_oflow;
+	u32 tmac_rst_tcp_oflow;
+	u32 tmac_icmp_oflow;
+	u32 tpa_unknown_protocol;
+	u32 tmac_udp_oflow;
+	u32 reserved_10;
+	u32 tpa_parse_failure;
+
+/* Rx MAC Statistics overflow counters. */
+	u32 rmac_data_octets_oflow;
+	u32 rmac_vld_frms_oflow;
+	u32 rmac_vld_bcst_frms_oflow;
+	u32 rmac_vld_mcst_frms_oflow;
+	u32 rmac_accepted_ucst_frms_oflow;
+	u32 rmac_ttl_octets_oflow;
+	u32 rmac_discarded_frms_oflow;
+	u32 rmac_accepted_nucst_frms_oflow;
+	u32 rmac_usized_frms_oflow;
+	u32 rmac_drop_events_oflow;
+	u32 rmac_frag_frms_oflow;
+	u32 rmac_osized_frms_oflow;
+	u32 rmac_ip_oflow;
+	u32 rmac_jabber_frms_oflow;
+	u32 rmac_icmp_oflow;
+	u32 rmac_drop_ip_oflow;
+	u32 rmac_err_drp_udp_oflow;
+	u32 rmac_udp_oflow;
+	u32 reserved_11;
+	u32 rmac_pause_cnt_oflow;
+	u64 rmac_ttl_1519_4095_frms;
+	u64 rmac_ttl_4096_8191_frms;
+	u64 rmac_ttl_8192_max_frms;
+	u64 rmac_ttl_gt_max_frms;
+	u64 rmac_osized_alt_frms;
+	u64 rmac_jabber_alt_frms;
+	u64 rmac_gt_max_alt_frms;
+	u64 rmac_vlan_frms;
+	u32 rmac_len_discard;
+	u32 rmac_fcs_discard;
+	u32 rmac_pf_discard;
+	u32 rmac_da_discard;
+	u32 rmac_red_discard;
+	u32 rmac_rts_discard;
+	u32 reserved_12;
+	u32 rmac_ingm_full_discard;
+	u32 reserved_13;
+	u32 rmac_accepted_ip_oflow;
+	u32 reserved_14;
+	u32 link_fault_cnt;
+
 /* Software statistics maintained by driver */
 	swStat_t sw_stat;
 } StatInfo_t;
@@ -690,6 +751,9 @@ struct s2io_nic {
 	atomic_t card_state;
 	volatile unsigned long link_state;
 	struct vlan_group *vlgrp;
+#define XFRAME_I_DEVICE		1
+#define XFRAME_II_DEVICE	2
+	u8 device_type;
 
 	spinlock_t	rx_lock;
 	atomic_t	isr_cnt;
