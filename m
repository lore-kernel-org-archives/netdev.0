From: raghavendra.koushik@neterion.com
Subject: [PATCH 2.6.13-rc4 2/13] S2io: Hardware fixes
Date: Wed,  3 Aug 2005 12:27:09 -0700 (PDT)
Message-ID: <20050803192709.BF46A98336@linux.site>
Cc: raghavendra.koushik@neterion.com, ravinandan.arakali@neterion.com,
        leonid.grossman@neterion.com, rapuru.sriram@neterion.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com, netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,
Below patch addresses few h/w specific issues.
1. Check for additional ownership bit on Rx path before
   starting Rx processing.
2. Enable only 4 PCCs(Per Context Controller) for Xframe I
   revisions less than 4.
3. Program Rx and Tx round robin registers depending on
   no. of rings/FIFOs.
4. Tx continous interrupts is now a loadable parameter.
5. Reset the card if we get double-bit ECC errors.
6. A soft reset of XGXS being done to force a link state change has been 
   eliminated.
7. After a reset, clear "parity error detected" bit, 
   PCI-X ECC status register, and PCI_STATUS bit in 
   tx_pic_int register. 
8. The error in the disabling allmulticast implementation has been 
   rectified.
9. Leave the PCI-X parameters MMRBC, OST etc. at their
   BIOS/system defaults.

Signed-off-by: Ravinandan Arakali <ravinandan.arakali@neterion.com>
Signed-off-by: Raghavendra Koushik <raghavendra.koushik@neterion.com>
---
diff -uprN vanilla_linux/drivers/net/s2io-regs.h linux-2.6.13-rc4/drivers/net/s2io-regs.h
--- vanilla_linux/drivers/net/s2io-regs.h	2005-08-02 02:14:25.000000000 -0700
+++ linux-2.6.13-rc4/drivers/net/s2io-regs.h	2005-08-02 02:14:02.000000000 -0700
@@ -62,6 +62,7 @@ typedef struct _XENA_dev_config {
 #define ADAPTER_STATUS_RMAC_REMOTE_FAULT   BIT(6)
 #define ADAPTER_STATUS_RMAC_LOCAL_FAULT    BIT(7)
 #define ADAPTER_STATUS_RMAC_PCC_IDLE       vBIT(0xFF,8,8)
+#define ADAPTER_STATUS_RMAC_PCC_FOUR_IDLE  vBIT(0x0F,8,8)
 #define ADAPTER_STATUS_RC_PRC_QUIESCENT    vBIT(0xFF,16,8)
 #define ADAPTER_STATUS_MC_DRAM_READY       BIT(24)
 #define ADAPTER_STATUS_MC_QUEUES_READY     BIT(25)
@@ -245,6 +246,7 @@ typedef struct _XENA_dev_config {
 #define STAT_TRSF_PER(n)           TBD
 #define	PER_SEC					   0x208d5
 #define	SET_UPDT_PERIOD(n)		   vBIT((PER_SEC*n),32,32)
+#define	SET_UPDT_CLICKS(val)		   vBIT(val, 32, 32)
 
 	u64 stat_addr;
 
@@ -289,6 +291,7 @@ typedef struct _XENA_dev_config {
 
 	u64 pcc_err_reg;
 #define PCC_FB_ECC_DB_ERR		vBIT(0xFF, 16, 8)
+#define PCC_ENABLE_FOUR			vBIT(0x0F,0,8)
 
 	u64 pcc_err_mask;
 	u64 pcc_err_alarm;
@@ -690,6 +693,10 @@ typedef struct _XENA_dev_config {
 #define MC_ERR_REG_MIRI_CRI_ERR_0          BIT(22)
 #define MC_ERR_REG_MIRI_CRI_ERR_1          BIT(23)
 #define MC_ERR_REG_SM_ERR                  BIT(31)
+#define MC_ERR_REG_ECC_ALL_SNG		   (BIT(6) | \
+					BIT(7) | BIT(17) | BIT(19))
+#define MC_ERR_REG_ECC_ALL_DBL		   (BIT(14) | \
+					BIT(15) | BIT(18) | BIT(20))
 	u64 mc_err_mask;
 	u64 mc_err_alarm;
 
diff -uprN vanilla_linux/drivers/net/s2io.c linux-2.6.13-rc4/drivers/net/s2io.c
--- vanilla_linux/drivers/net/s2io.c	2005-08-02 02:14:17.000000000 -0700
+++ linux-2.6.13-rc4/drivers/net/s2io.c	2005-08-02 02:23:37.000000000 -0700
@@ -68,6 +68,16 @@
 static char s2io_driver_name[] = "Neterion";
 static char s2io_driver_version[] = "Version 1.7.7";
 
+static inline int RXD_IS_UP2DT(RxD_t *rxdp)
+{
+	int ret;
+
+	ret = ((!(rxdp->Control_1 & RXD_OWN_XENA)) &&
+		(GET_RXD_MARKER(rxdp->Control_2) != THE_RXD_MARK));
+
+	return ret;
+}
+
 /*
  * Cards with following subsystem_id have a link state indication
  * problem, 600B, 600C, 600D, 640B, 640C and 640D.
@@ -230,6 +240,7 @@ static unsigned int rx_ring_sz[MAX_RX_RI
 static unsigned int Stats_refresh_time = 4;
 static unsigned int rts_frm_len[MAX_RX_RINGS] =
     {[0 ...(MAX_RX_RINGS - 1)] = 0 };
+static unsigned int use_continuous_tx_intrs = 1;
 static unsigned int rmac_pause_time = 65535;
 static unsigned int mc_pause_threshold_q0q3 = 187;
 static unsigned int mc_pause_threshold_q4q7 = 187;
@@ -638,7 +649,7 @@ static int init_nic(struct s2io_nic *nic
 	mac_control = &nic->mac_control;
 	config = &nic->config;
 
-	/* to set the swapper control on the card */
+	/* to set the swapper controle on the card */
 	if(s2io_set_swapper(nic)) {
 		DBG_PRINT(ERR_DBG,"ERROR: Setting Swapper failed\n");
 		return -1;
@@ -756,6 +767,13 @@ static int init_nic(struct s2io_nic *nic
 	val64 |= BIT(0);	/* To enable the FIFO partition. */
 	writeq(val64, &bar0->tx_fifo_partition_0);
 
+	/*
+	 * Disable 4 PCCs for Xena1, 2 and 3 as per H/W bug
+	 * SXE-008 TRANSMIT DMA ARBITRATION ISSUE.
+	 */
+	if (get_xena_rev_id(nic->pdev) < 4)
+		writeq(PCC_ENABLE_FOUR, &bar0->pcc_enable);
+
 	val64 = readq(&bar0->tx_fifo_partition_0);
 	DBG_PRINT(INIT_DBG, "Fifo partition at: 0x%p is: 0x%llx\n",
 		  &bar0->tx_fifo_partition_0, (unsigned long long) val64);
@@ -823,37 +841,250 @@ static int init_nic(struct s2io_nic *nic
 	}
 	writeq(val64, &bar0->rx_queue_cfg);
 
-	/* Initializing the Tx round robin registers to 0
-	 * filling tx and rx round robin registers as per
-	 * the number of FIFOs and Rings is still TODO
-	 */
-	writeq(0, &bar0->tx_w_round_robin_0);
-	writeq(0, &bar0->tx_w_round_robin_1);
-	writeq(0, &bar0->tx_w_round_robin_2);
-	writeq(0, &bar0->tx_w_round_robin_3);
-	writeq(0, &bar0->tx_w_round_robin_4);
-
-	/*
-	 * TODO
-	 * Disable Rx steering. Hard coding all packets to be steered to
-	 * Queue 0 for now.
+	/*
+	 * Filling Tx round robin registers
+	 * as per the number of FIFOs
 	 */
-	val64 = 0x8080808080808080ULL;
-	writeq(val64, &bar0->rts_qos_steering);
+	switch (config->tx_fifo_num) {
+	case 1:
+		val64 = 0x0000000000000000ULL;
+		writeq(val64, &bar0->tx_w_round_robin_0);
+		writeq(val64, &bar0->tx_w_round_robin_1);
+		writeq(val64, &bar0->tx_w_round_robin_2);
+		writeq(val64, &bar0->tx_w_round_robin_3);
+		writeq(val64, &bar0->tx_w_round_robin_4);
+		break;
+	case 2:
+		val64 = 0x0000010000010000ULL;
+		writeq(val64, &bar0->tx_w_round_robin_0);
+		val64 = 0x0100000100000100ULL;
+		writeq(val64, &bar0->tx_w_round_robin_1);
+		val64 = 0x0001000001000001ULL;
+		writeq(val64, &bar0->tx_w_round_robin_2);
+		val64 = 0x0000010000010000ULL;
+		writeq(val64, &bar0->tx_w_round_robin_3);
+		val64 = 0x0100000000000000ULL;
+		writeq(val64, &bar0->tx_w_round_robin_4);
+		break;
+	case 3:
+		val64 = 0x0001000102000001ULL;
+		writeq(val64, &bar0->tx_w_round_robin_0);
+		val64 = 0x0001020000010001ULL;
+		writeq(val64, &bar0->tx_w_round_robin_1);
+		val64 = 0x0200000100010200ULL;
+		writeq(val64, &bar0->tx_w_round_robin_2);
+		val64 = 0x0001000102000001ULL;
+		writeq(val64, &bar0->tx_w_round_robin_3);
+		val64 = 0x0001020000000000ULL;
+		writeq(val64, &bar0->tx_w_round_robin_4);
+		break;
+	case 4:
+		val64 = 0x0001020300010200ULL;
+		writeq(val64, &bar0->tx_w_round_robin_0);
+		val64 = 0x0100000102030001ULL;
+		writeq(val64, &bar0->tx_w_round_robin_1);
+		val64 = 0x0200010000010203ULL;
+		writeq(val64, &bar0->tx_w_round_robin_2);
+		val64 = 0x0001020001000001ULL;
+		writeq(val64, &bar0->tx_w_round_robin_3);
+		val64 = 0x0203000100000000ULL;
+		writeq(val64, &bar0->tx_w_round_robin_4);
+		break;
+	case 5:
+		val64 = 0x0001000203000102ULL;
+		writeq(val64, &bar0->tx_w_round_robin_0);
+		val64 = 0x0001020001030004ULL;
+		writeq(val64, &bar0->tx_w_round_robin_1);
+		val64 = 0x0001000203000102ULL;
+		writeq(val64, &bar0->tx_w_round_robin_2);
+		val64 = 0x0001020001030004ULL;
+		writeq(val64, &bar0->tx_w_round_robin_3);
+		val64 = 0x0001000000000000ULL;
+		writeq(val64, &bar0->tx_w_round_robin_4);
+		break;
+	case 6:
+		val64 = 0x0001020304000102ULL;
+		writeq(val64, &bar0->tx_w_round_robin_0);
+		val64 = 0x0304050001020001ULL;
+		writeq(val64, &bar0->tx_w_round_robin_1);
+		val64 = 0x0203000100000102ULL;
+		writeq(val64, &bar0->tx_w_round_robin_2);
+		val64 = 0x0304000102030405ULL;
+		writeq(val64, &bar0->tx_w_round_robin_3);
+		val64 = 0x0001000200000000ULL;
+		writeq(val64, &bar0->tx_w_round_robin_4);
+		break;
+	case 7:
+		val64 = 0x0001020001020300ULL;
+		writeq(val64, &bar0->tx_w_round_robin_0);
+		val64 = 0x0102030400010203ULL;
+		writeq(val64, &bar0->tx_w_round_robin_1);
+		val64 = 0x0405060001020001ULL;
+		writeq(val64, &bar0->tx_w_round_robin_2);
+		val64 = 0x0304050000010200ULL;
+		writeq(val64, &bar0->tx_w_round_robin_3);
+		val64 = 0x0102030000000000ULL;
+		writeq(val64, &bar0->tx_w_round_robin_4);
+		break;
+	case 8:
+		val64 = 0x0001020300040105ULL;
+		writeq(val64, &bar0->tx_w_round_robin_0);
+		val64 = 0x0200030106000204ULL;
+		writeq(val64, &bar0->tx_w_round_robin_1);
+		val64 = 0x0103000502010007ULL;
+		writeq(val64, &bar0->tx_w_round_robin_2);
+		val64 = 0x0304010002060500ULL;
+		writeq(val64, &bar0->tx_w_round_robin_3);
+		val64 = 0x0103020400000000ULL;
+		writeq(val64, &bar0->tx_w_round_robin_4);
+		break;
+	}
+
+	/* Filling the Rx round robin registers as per the
+	 * number of Rings and steering based on QoS.
+         */
+	switch (config->rx_ring_num) {
+	case 1:
+		val64 = 0x8080808080808080ULL;
+		writeq(val64, &bar0->rts_qos_steering);
+		break;
+	case 2:
+		val64 = 0x0000010000010000ULL;
+		writeq(val64, &bar0->rx_w_round_robin_0);
+		val64 = 0x0100000100000100ULL;
+		writeq(val64, &bar0->rx_w_round_robin_1);
+		val64 = 0x0001000001000001ULL;
+		writeq(val64, &bar0->rx_w_round_robin_2);
+		val64 = 0x0000010000010000ULL;
+		writeq(val64, &bar0->rx_w_round_robin_3);
+		val64 = 0x0100000000000000ULL;
+		writeq(val64, &bar0->rx_w_round_robin_4);
+
+		val64 = 0x8080808040404040ULL;
+		writeq(val64, &bar0->rts_qos_steering);
+		break;
+	case 3:
+		val64 = 0x0001000102000001ULL;
+		writeq(val64, &bar0->rx_w_round_robin_0);
+		val64 = 0x0001020000010001ULL;
+		writeq(val64, &bar0->rx_w_round_robin_1);
+		val64 = 0x0200000100010200ULL;
+		writeq(val64, &bar0->rx_w_round_robin_2);
+		val64 = 0x0001000102000001ULL;
+		writeq(val64, &bar0->rx_w_round_robin_3);
+		val64 = 0x0001020000000000ULL;
+		writeq(val64, &bar0->rx_w_round_robin_4);
+
+		val64 = 0x8080804040402020ULL;
+		writeq(val64, &bar0->rts_qos_steering);
+		break;
+	case 4:
+		val64 = 0x0001020300010200ULL;
+		writeq(val64, &bar0->rx_w_round_robin_0);
+		val64 = 0x0100000102030001ULL;
+		writeq(val64, &bar0->rx_w_round_robin_1);
+		val64 = 0x0200010000010203ULL;
+		writeq(val64, &bar0->rx_w_round_robin_2);
+		val64 = 0x0001020001000001ULL;	
+		writeq(val64, &bar0->rx_w_round_robin_3);
+		val64 = 0x0203000100000000ULL;
+		writeq(val64, &bar0->rx_w_round_robin_4);
+
+		val64 = 0x8080404020201010ULL;
+		writeq(val64, &bar0->rts_qos_steering);
+		break;
+	case 5:
+		val64 = 0x0001000203000102ULL;
+		writeq(val64, &bar0->rx_w_round_robin_0);
+		val64 = 0x0001020001030004ULL;
+		writeq(val64, &bar0->rx_w_round_robin_1);
+		val64 = 0x0001000203000102ULL;
+		writeq(val64, &bar0->rx_w_round_robin_2);
+		val64 = 0x0001020001030004ULL;
+		writeq(val64, &bar0->rx_w_round_robin_3);
+		val64 = 0x0001000000000000ULL;
+		writeq(val64, &bar0->rx_w_round_robin_4);
+
+		val64 = 0x8080404020201008ULL;
+		writeq(val64, &bar0->rts_qos_steering);
+		break;
+	case 6:
+		val64 = 0x0001020304000102ULL;
+		writeq(val64, &bar0->rx_w_round_robin_0);
+		val64 = 0x0304050001020001ULL;
+		writeq(val64, &bar0->rx_w_round_robin_1);
+		val64 = 0x0203000100000102ULL;
+		writeq(val64, &bar0->rx_w_round_robin_2);
+		val64 = 0x0304000102030405ULL;
+		writeq(val64, &bar0->rx_w_round_robin_3);
+		val64 = 0x0001000200000000ULL;
+		writeq(val64, &bar0->rx_w_round_robin_4);
+
+		val64 = 0x8080404020100804ULL;
+		writeq(val64, &bar0->rts_qos_steering);
+		break;
+	case 7:
+		val64 = 0x0001020001020300ULL;
+		writeq(val64, &bar0->rx_w_round_robin_0);
+		val64 = 0x0102030400010203ULL;
+		writeq(val64, &bar0->rx_w_round_robin_1);
+		val64 = 0x0405060001020001ULL;
+		writeq(val64, &bar0->rx_w_round_robin_2);
+		val64 = 0x0304050000010200ULL;
+		writeq(val64, &bar0->rx_w_round_robin_3);
+		val64 = 0x0102030000000000ULL;
+		writeq(val64, &bar0->rx_w_round_robin_4);
+
+		val64 = 0x8080402010080402ULL;
+		writeq(val64, &bar0->rts_qos_steering);
+		break;
+	case 8:
+		val64 = 0x0001020300040105ULL;
+		writeq(val64, &bar0->rx_w_round_robin_0);
+		val64 = 0x0200030106000204ULL;
+		writeq(val64, &bar0->rx_w_round_robin_1);
+		val64 = 0x0103000502010007ULL;
+		writeq(val64, &bar0->rx_w_round_robin_2);
+		val64 = 0x0304010002060500ULL;
+		writeq(val64, &bar0->rx_w_round_robin_3);
+		val64 = 0x0103020400000000ULL;
+		writeq(val64, &bar0->rx_w_round_robin_4);
+
+		val64 = 0x8040201008040201ULL;
+		writeq(val64, &bar0->rts_qos_steering);
+		break;
+	}
 
 	/* UDP Fix */
 	val64 = 0;
 	for (i = 0; i < 8; i++)
 		writeq(val64, &bar0->rts_frm_len_n[i]);
 
-	/* Set the default rts frame length for ring0 */
-	writeq(MAC_RTS_FRM_LEN_SET(dev->mtu+22),
-		&bar0->rts_frm_len_n[0]);
+	/* Set the default rts frame length for the rings configured */
+	val64 = MAC_RTS_FRM_LEN_SET(dev->mtu+22);
+	for (i = 0 ; i < config->rx_ring_num ; i++)
+		writeq(val64, &bar0->rts_frm_len_n[i]);
+
+	/* Set the frame length for the configured rings
+	 * desired by the user
+	 */
+	for (i = 0; i < config->rx_ring_num; i++) {
+		/* If rts_frm_len[i] == 0 then it is assumed that user not
+		 * specified frame length steering.
+		 * If the user provides the frame length then program
+		 * the rts_frm_len register for those values or else
+		 * leave it as it is.
+		 */
+		if (rts_frm_len[i] != 0) {
+			writeq(MAC_RTS_FRM_LEN_SET(rts_frm_len[i]),
+				&bar0->rts_frm_len_n[i]);
+		}
+	}
 
 	/* Program statistics memory */
 	writeq(mac_control->stats_mem_phy, &bar0->stat_addr);
 	val64 = SET_UPDT_PERIOD(Stats_refresh_time) |
-	    STAT_CFG_STAT_RO | STAT_CFG_STAT_EN;
+		STAT_CFG_STAT_RO | STAT_CFG_STAT_EN;
 	writeq(val64, &bar0->stat_cfg);
 
 	/*
@@ -877,13 +1108,14 @@ static int init_nic(struct s2io_nic *nic
 	val64 = TTI_DATA1_MEM_TX_TIMER_VAL(0x2078) |
 	    TTI_DATA1_MEM_TX_URNG_A(0xA) |
 	    TTI_DATA1_MEM_TX_URNG_B(0x10) |
-	    TTI_DATA1_MEM_TX_URNG_C(0x30) | TTI_DATA1_MEM_TX_TIMER_AC_EN |
-		TTI_DATA1_MEM_TX_TIMER_CI_EN;
+	    TTI_DATA1_MEM_TX_URNG_C(0x30) | TTI_DATA1_MEM_TX_TIMER_AC_EN;
+	if (use_continuous_tx_intrs)
+		val64 |= TTI_DATA1_MEM_TX_TIMER_CI_EN;
 	writeq(val64, &bar0->tti_data1_mem);
 
 	val64 = TTI_DATA2_MEM_TX_UFC_A(0x10) |
 	    TTI_DATA2_MEM_TX_UFC_B(0x20) |
-	    TTI_DATA2_MEM_TX_UFC_C(0x40) | TTI_DATA2_MEM_TX_UFC_D(0x80);
+	    TTI_DATA2_MEM_TX_UFC_C(0x70) | TTI_DATA2_MEM_TX_UFC_D(0x80);
 	writeq(val64, &bar0->tti_data2_mem);
 
 	val64 = TTI_CMD_MEM_WE | TTI_CMD_MEM_STROBE_NEW_CMD;
@@ -927,10 +1159,11 @@ static int init_nic(struct s2io_nic *nic
 	writeq(val64, &bar0->rti_command_mem);
 
 	/*
-	 * Once the operation completes, the Strobe bit of the command
-	 * register will be reset. We poll for this particular condition
-	 * We wait for a maximum of 500ms for the operation to complete,
-	 * if it's not complete by then we return error.
+	 * Once the operation completes, the Strobe bit of the
+	 * command register will be reset. We poll for this
+	 * particular condition. We wait for a maximum of 500ms
+	 * for the operation to complete, if it's not complete
+	 * by then we return error.
 	 */
 	time = 0;
 	while (TRUE) {
@@ -1185,10 +1418,10 @@ static void en_dis_able_nic_intrs(struct
 			temp64 &= ~((u64) val64);
 			writeq(temp64, &bar0->general_int_mask);
 			/*
-			 * All MC block error interrupts are disabled for now.
-			 * TODO
+			 * Enable all MC Intrs.
 			 */
-			writeq(DISABLE_ALL_INTRS, &bar0->mc_int_mask);
+			writeq(0x0, &bar0->mc_int_mask);
+			writeq(0x0, &bar0->mc_err_mask);
 		} else if (flag == DISABLE_INTRS) {
 			/*
 			 * Disable MC Intrs in the general intr mask register
@@ -1247,23 +1480,41 @@ static void en_dis_able_nic_intrs(struct
 	}
 }
 
-static int check_prc_pcc_state(u64 val64, int flag)
+static int check_prc_pcc_state(u64 val64, int flag, int rev_id)
 {
 	int ret = 0;
 
 	if (flag == FALSE) {
-		if (!(val64 & ADAPTER_STATUS_RMAC_PCC_IDLE) &&
-		    ((val64 & ADAPTER_STATUS_RC_PRC_QUIESCENT) ==
-		     ADAPTER_STATUS_RC_PRC_QUIESCENT)) {
-			ret = 1;
+		if (rev_id >= 4) {
+			if (!(val64 & ADAPTER_STATUS_RMAC_PCC_IDLE) &&
+			    ((val64 & ADAPTER_STATUS_RC_PRC_QUIESCENT) ==
+			     ADAPTER_STATUS_RC_PRC_QUIESCENT)) {
+				ret = 1;
+			}
+		} else {
+			if (!(val64 & ADAPTER_STATUS_RMAC_PCC_FOUR_IDLE) &&
+			    ((val64 & ADAPTER_STATUS_RC_PRC_QUIESCENT) ==
+			     ADAPTER_STATUS_RC_PRC_QUIESCENT)) {
+				ret = 1;
+			}
 		}
 	} else {
-		if (((val64 & ADAPTER_STATUS_RMAC_PCC_IDLE) ==
-		     ADAPTER_STATUS_RMAC_PCC_IDLE) &&
-		    (!(val64 & ADAPTER_STATUS_RC_PRC_QUIESCENT) ||
-		     ((val64 & ADAPTER_STATUS_RC_PRC_QUIESCENT) ==
-		      ADAPTER_STATUS_RC_PRC_QUIESCENT))) {
-			ret = 1;
+		if (rev_id >= 4) {
+			if (((val64 & ADAPTER_STATUS_RMAC_PCC_IDLE) ==
+			     ADAPTER_STATUS_RMAC_PCC_IDLE) &&
+			    (!(val64 & ADAPTER_STATUS_RC_PRC_QUIESCENT) ||
+			     ((val64 & ADAPTER_STATUS_RC_PRC_QUIESCENT) ==
+			      ADAPTER_STATUS_RC_PRC_QUIESCENT))) {
+				ret = 1;
+			}
+		} else {
+			if (((val64 & ADAPTER_STATUS_RMAC_PCC_FOUR_IDLE) ==
+			     ADAPTER_STATUS_RMAC_PCC_FOUR_IDLE) &&
+			    (!(val64 & ADAPTER_STATUS_RC_PRC_QUIESCENT) ||
+			     ((val64 & ADAPTER_STATUS_RC_PRC_QUIESCENT) ==
+			      ADAPTER_STATUS_RC_PRC_QUIESCENT))) {
+				ret = 1;
+			}
 		}
 	}
 
@@ -1286,6 +1537,7 @@ static int verify_xena_quiescence(nic_t 
 {
 	int ret = 0;
 	u64 tmp64 = ~((u64) val64);
+	int rev_id = get_xena_rev_id(sp->pdev);
 
 	if (!
 	    (tmp64 &
@@ -1294,7 +1546,7 @@ static int verify_xena_quiescence(nic_t 
 	      ADAPTER_STATUS_PIC_QUIESCENT | ADAPTER_STATUS_MC_DRAM_READY |
 	      ADAPTER_STATUS_MC_QUEUES_READY | ADAPTER_STATUS_M_PLL_LOCK |
 	      ADAPTER_STATUS_P_PLL_LOCK))) {
-		ret = check_prc_pcc_state(val64, flag);
+		ret = check_prc_pcc_state(val64, flag, rev_id);
 	}
 
 	return ret;
@@ -1407,7 +1659,7 @@ static int start_nic(struct s2io_nic *ni
 
 	/*  Enable select interrupts */
 	interruptible = TX_TRAFFIC_INTR | RX_TRAFFIC_INTR | TX_MAC_INTR |
-	    RX_MAC_INTR;
+	    RX_MAC_INTR | MC_INTR;
 	en_dis_able_nic_intrs(nic, interruptible, ENABLE_INTRS);
 
 	/*
@@ -1439,21 +1691,6 @@ static int start_nic(struct s2io_nic *ni
 	 */
 	schedule_work(&nic->set_link_task);
 
-	/*
-	 * Here we are performing soft reset on XGXS to
-	 * force link down. Since link is already up, we will get
-	 * link state change interrupt after this reset
-	 */
-	SPECIAL_REG_WRITE(0x80010515001E0000ULL, &bar0->dtx_control, UF);
-	val64 = readq(&bar0->dtx_control);
-	udelay(50);
-	SPECIAL_REG_WRITE(0x80010515001E00E0ULL, &bar0->dtx_control, UF);
-	val64 = readq(&bar0->dtx_control);
-	udelay(50);
-	SPECIAL_REG_WRITE(0x80070515001F00E4ULL, &bar0->dtx_control, UF);
-	val64 = readq(&bar0->dtx_control);
-	udelay(50);
-
 	return SUCCESS;
 }
 
@@ -1524,7 +1761,7 @@ static void stop_nic(struct s2io_nic *ni
 
 	/*  Disable all interrupts */
 	interruptible = TX_TRAFFIC_INTR | RX_TRAFFIC_INTR | TX_MAC_INTR |
-	    RX_MAC_INTR;
+	    RX_MAC_INTR | MC_INTR;
 	en_dis_able_nic_intrs(nic, interruptible, DISABLE_INTRS);
 
 	/*  Disable PRCs */
@@ -1737,6 +1974,7 @@ int fill_rx_buffers(struct s2io_nic *nic
 		off++;
 		mac_control->rings[ring_no].rx_curr_put_info.offset = off;
 #endif
+		rxdp->Control_2 |= SET_RXD_MARKER;
 
 		atomic_inc(&nic->rx_bufs_left[ring_no]);
 		alloc_tab++;
@@ -1965,11 +2203,8 @@ static void rx_intr_handler(ring_info_t 
 	put_offset = (put_block * (MAX_RXDS_PER_BLOCK + 1)) +
 		put_info.offset;
 #endif
-	while ((!(rxdp->Control_1 & RXD_OWN_XENA)) &&
-#ifdef CONFIG_2BUFF_MODE
-		(!rxdp->Control_2 & BIT(0)) &&
-#endif
-	        (((get_offset + 1) % ring_bufs) != put_offset)) {
+	while (RXD_IS_UP2DT(rxdp) &&
+	       (((get_offset + 1) % ring_bufs) != put_offset)) {
 		skb = (struct sk_buff *) ((unsigned long)rxdp->Host_Control);
 		if (skb == NULL) {
 			DBG_PRINT(ERR_DBG, "%s: The skb is ",
@@ -2153,6 +2388,21 @@ static void alarm_intr_handler(struct s2
 		schedule_work(&nic->set_link_task);
 	}
 
+	/* Handling Ecc errors */
+	val64 = readq(&bar0->mc_err_reg);
+	writeq(val64, &bar0->mc_err_reg);
+	if (val64 & (MC_ERR_REG_ECC_ALL_SNG | MC_ERR_REG_ECC_ALL_DBL)) {
+		if (val64 & MC_ERR_REG_ECC_ALL_DBL) {
+			DBG_PRINT(ERR_DBG, "%s: Device indicates ",
+				  dev->name);
+			DBG_PRINT(ERR_DBG, "double ECC error!!\n");
+			netif_stop_queue(dev);
+			schedule_work(&nic->rst_timer_task);
+		} else {
+			/* Device can recover from Single ECC errors */
+		}
+	}
+
 	/* In case of a serious error, the device will be Reset. */
 	val64 = readq(&bar0->serr_source);
 	if (val64 & SERR_SOURCE_ANY) {
@@ -2226,7 +2476,7 @@ void s2io_reset(nic_t * sp)
 {
 	XENA_dev_config_t __iomem *bar0 = sp->bar0;
 	u64 val64;
-	u16 subid;
+	u16 subid, pci_cmd;
 
 	val64 = SW_RESET_ALL;
 	writeq(val64, &bar0->sw_reset);
@@ -2255,6 +2505,18 @@ void s2io_reset(nic_t * sp)
 	/* Set swapper to enable I/O register access */
 	s2io_set_swapper(sp);
 
+	/* Clear certain PCI/PCI-X fields after reset */
+	pci_read_config_word(sp->pdev, PCI_COMMAND, &pci_cmd);
+	pci_cmd &= 0x7FFF; /* Clear parity err detect bit */
+	pci_write_config_word(sp->pdev, PCI_COMMAND, pci_cmd);
+
+	val64 = readq(&bar0->txpic_int_reg);
+	val64 &= ~BIT(62); /* Clearing PCI_STATUS error reflected here */
+	writeq(val64, &bar0->txpic_int_reg);
+
+	/* Clearing PCIX Ecc status register */
+	pci_write_config_dword(sp->pdev, 0x68, 0);
+
 	/* Reset device statistics maintained by OS */
 	memset(&sp->stats, 0, sizeof (struct net_device_stats));
 
@@ -2797,6 +3059,8 @@ static void s2io_set_multicast(struct ne
 		/*  Disable all Multicast addresses */
 		writeq(RMAC_ADDR_DATA0_MEM_ADDR(dis_addr),
 		       &bar0->rmac_addr_data0_mem);
+		writeq(RMAC_ADDR_DATA1_MEM_MASK(0x0),
+		       &bar0->rmac_addr_data1_mem);
 		val64 = RMAC_ADDR_CMD_MEM_WE |
 		    RMAC_ADDR_CMD_MEM_STROBE_NEW_CMD |
 		    RMAC_ADDR_CMD_MEM_OFFSET(sp->all_multi_pos);
@@ -4369,21 +4633,6 @@ static void s2io_init_pci(nic_t * sp)
 			      (pci_cmd | PCI_COMMAND_PARITY));
 	pci_read_config_word(sp->pdev, PCI_COMMAND, &pci_cmd);
 
-	/* Set MMRB count to 1024 in PCI-X Command register. */
-	pcix_cmd &= 0xFFF3;
-	pci_write_config_word(sp->pdev, PCIX_COMMAND_REGISTER,
-			      (pcix_cmd | (0x1 << 2)));	/* MMRBC 1K */
-	pci_read_config_word(sp->pdev, PCIX_COMMAND_REGISTER,
-			     &(pcix_cmd));
-
-	/*  Setting Maximum outstanding splits based on system type. */
-	pcix_cmd &= 0xFF8F;
-	pcix_cmd |= XENA_MAX_OUTSTANDING_SPLITS(0x1);	/* 2 splits. */
-	pci_write_config_word(sp->pdev, PCIX_COMMAND_REGISTER,
-			      pcix_cmd);
-	pci_read_config_word(sp->pdev, PCIX_COMMAND_REGISTER,
-			     &(pcix_cmd));
-
 	/* Forcibly disabling relaxed ordering capability of the card. */
 	pcix_cmd &= 0xfffd;
 	pci_write_config_word(sp->pdev, PCIX_COMMAND_REGISTER,
@@ -4400,6 +4649,7 @@ module_param_array(tx_fifo_len, uint, NU
 module_param_array(rx_ring_sz, uint, NULL, 0);
 module_param(Stats_refresh_time, int, 0);
 module_param_array(rts_frm_len, uint, NULL, 0);
+module_param(use_continuous_tx_intrs, int, 1);
 module_param(rmac_pause_time, int, 0);
 module_param(mc_pause_threshold_q0q3, int, 0);
 module_param(mc_pause_threshold_q4q7, int, 0);
diff -uprN vanilla_linux/drivers/net/s2io.h linux-2.6.13-rc4/drivers/net/s2io.h
--- vanilla_linux/drivers/net/s2io.h	2005-08-02 02:14:21.000000000 -0700
+++ linux-2.6.13-rc4/drivers/net/s2io.h	2005-08-02 02:13:58.000000000 -0700
@@ -372,6 +372,10 @@ typedef struct _RxD_t {
 #define RXD_GET_L4_CKSUM(val)   ((u16)(val) & 0xFFFF)
 
 	u64 Control_2;
+#define	THE_RXD_MARK		0x3
+#define	SET_RXD_MARKER		vBIT(THE_RXD_MARK, 0, 2)
+#define	GET_RXD_MARKER(ctrl)	((ctrl & SET_RXD_MARKER) >> 62)
+
 #ifndef CONFIG_2BUFF_MODE
 #define MASK_BUFFER0_SIZE       vBIT(0x3FFF,2,14)
 #define SET_BUFFER0_SIZE(val)   vBIT(val,2,14)
