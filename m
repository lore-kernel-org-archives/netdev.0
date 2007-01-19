From: Ananda Raju <Ananda.Raju@neterion.com>
Subject: [PATCH 2.6.20 2/5] S2IO: Fixes for reset and link handling.
Date: Fri, 19 Jan 2007 02:34:50 -0500 (EST)
Message-ID: <Pine.GSO.4.10.10701190231190.22012-100000@guinness>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: leonid.grossman@neterion.com, alicia.pena@neterion.com,
	ramkrishna.vepa@neterion.com, sivakumar.subramani@neterion.com,
	sreenivasa.honnur@neterion.com, sriram.rapuru@neterion.com,
	ananda.raju@neterion.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:59256 "EHLO
	barracuda.s2io.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964894AbXASHev (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Jan 2007 02:34:51 -0500
To: netdev@vger.kernel.org, jeff@garzik.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

1. Fix for reset and link handling.
2. Allow for promiscuos mode and multicast state be maintained through
   ifconfig up and down.
3. Support to print adapter serial number.

Signed-off-by: Sivakumar Subramani <sivakumar.subramani@neterion.com>
---
diff -urpN patch1/drivers/net/s2io.c patch2/drivers/net/s2io.c
--- patch1/drivers/net/s2io.c	2007-01-08 11:56:23.000000000 +0530
+++ patch2/drivers/net/s2io.c	2007-01-08 17:51:20.000000000 +0530
@@ -1416,7 +1416,7 @@ static int init_nic(struct s2io_nic *nic
 
 	val64 = TTI_DATA2_MEM_TX_UFC_A(0x10) |
 	    TTI_DATA2_MEM_TX_UFC_B(0x20) |
-	    TTI_DATA2_MEM_TX_UFC_C(0x70) | TTI_DATA2_MEM_TX_UFC_D(0x80);
+	    TTI_DATA2_MEM_TX_UFC_C(0x40) | TTI_DATA2_MEM_TX_UFC_D(0x80);
 	writeq(val64, &bar0->tti_data2_mem);
 
 	val64 = TTI_CMD_MEM_WE | TTI_CMD_MEM_STROBE_NEW_CMD;
@@ -1612,7 +1612,8 @@ static int init_nic(struct s2io_nic *nic
 	 * that does not start on an ADB to reduce disconnects.
 	 */
 	if (nic->device_type == XFRAME_II_DEVICE) {
-		val64 = EXT_REQ_EN | MISC_LINK_STABILITY_PRD(3);
+		val64 = FAULT_BEHAVIOUR | EXT_REQ_EN |
+			MISC_LINK_STABILITY_PRD(3);
 		writeq(val64, &bar0->misc_control);
 		val64 = readq(&bar0->pic_control2);
 		val64 &= ~(BIT(13)|BIT(14)|BIT(15));
@@ -1879,41 +1880,36 @@ static void en_dis_able_nic_intrs(struct
 	}
 }
 
-static int check_prc_pcc_state(u64 val64, int flag, int rev_id, int herc)
+/**
+ *  verify_pcc_quiescent- Checks for PCC quiescent state
+ *  Return: 1 If PCC is quiescence
+ *          0 If PCC is not quiescence
+ */
+static int verify_pcc_quiescent(nic_t *sp, int flag)
 {
-	int ret = 0;
+	int ret = 0, herc;
+	XENA_dev_config_t __iomem *bar0 = sp->bar0;
+	u64 val64 = readq(&bar0->adapter_status);
+	
+	herc = (sp->device_type == XFRAME_II_DEVICE);
 
 	if (flag == FALSE) {
-		if ((!herc && (rev_id >= 4)) || herc) {
-			if (!(val64 & ADAPTER_STATUS_RMAC_PCC_IDLE) &&
-			    ((val64 & ADAPTER_STATUS_RC_PRC_QUIESCENT) ==
-			     ADAPTER_STATUS_RC_PRC_QUIESCENT)) {
+		if ((!herc && (get_xena_rev_id(sp->pdev) >= 4)) || herc) {
+			if (!(val64 & ADAPTER_STATUS_RMAC_PCC_IDLE)) 
 				ret = 1;
-			}
-		}else {
-			if (!(val64 & ADAPTER_STATUS_RMAC_PCC_FOUR_IDLE) &&
-			    ((val64 & ADAPTER_STATUS_RC_PRC_QUIESCENT) ==
-			     ADAPTER_STATUS_RC_PRC_QUIESCENT)) {
+		} else {
+			if (!(val64 & ADAPTER_STATUS_RMAC_PCC_FOUR_IDLE))
 				ret = 1;
-			}
 		}
 	} else {
-		if ((!herc && (rev_id >= 4)) || herc) {
+		if ((!herc && (get_xena_rev_id(sp->pdev) >= 4)) || herc) {
 			if (((val64 & ADAPTER_STATUS_RMAC_PCC_IDLE) ==
-			     ADAPTER_STATUS_RMAC_PCC_IDLE) &&
-			    (!(val64 & ADAPTER_STATUS_RC_PRC_QUIESCENT) ||
-			     ((val64 & ADAPTER_STATUS_RC_PRC_QUIESCENT) ==
-			      ADAPTER_STATUS_RC_PRC_QUIESCENT))) {
+			     ADAPTER_STATUS_RMAC_PCC_IDLE))
 				ret = 1;
-			}
 		} else {
 			if (((val64 & ADAPTER_STATUS_RMAC_PCC_FOUR_IDLE) ==
-			     ADAPTER_STATUS_RMAC_PCC_FOUR_IDLE) &&
-			    (!(val64 & ADAPTER_STATUS_RC_PRC_QUIESCENT) ||
-			     ((val64 & ADAPTER_STATUS_RC_PRC_QUIESCENT) ==
-			      ADAPTER_STATUS_RC_PRC_QUIESCENT))) {
+			     ADAPTER_STATUS_RMAC_PCC_FOUR_IDLE))
 				ret = 1;
-			}
 		}
 	}
 
@@ -1921,9 +1917,6 @@ static int check_prc_pcc_state(u64 val64
 }
 /**
  *  verify_xena_quiescence - Checks whether the H/W is ready
- *  @val64 :  Value read from adapter status register.
- *  @flag : indicates if the adapter enable bit was ever written once
- *  before.
  *  Description: Returns whether the H/W is ready to go or not. Depending
  *  on whether adapter enable bit was written or not the comparison
  *  differs and the calling function passes the input argument flag to
@@ -1932,24 +1925,63 @@ static int check_prc_pcc_state(u64 val64
  *          0 If Xena is not quiescence
  */
 
-static int verify_xena_quiescence(nic_t *sp, u64 val64, int flag)
+static int verify_xena_quiescence(nic_t *sp)
 {
-	int ret = 0, herc;
-	u64 tmp64 = ~((u64) val64);
-	int rev_id = get_xena_rev_id(sp->pdev);
+	int  mode;
+	XENA_dev_config_t __iomem *bar0 = sp->bar0;
+	u64 val64 = readq(&bar0->adapter_status);
+	mode = s2io_verify_pci_mode(sp);
 
-	herc = (sp->device_type == XFRAME_II_DEVICE);
-	if (!
-	    (tmp64 &
-	     (ADAPTER_STATUS_TDMA_READY | ADAPTER_STATUS_RDMA_READY |
-	      ADAPTER_STATUS_PFC_READY | ADAPTER_STATUS_TMAC_BUF_EMPTY |
-	      ADAPTER_STATUS_PIC_QUIESCENT | ADAPTER_STATUS_MC_DRAM_READY |
-	      ADAPTER_STATUS_MC_QUEUES_READY | ADAPTER_STATUS_M_PLL_LOCK |
-	      ADAPTER_STATUS_P_PLL_LOCK))) {
-		ret = check_prc_pcc_state(val64, flag, rev_id, herc);
+	if (!(val64 & ADAPTER_STATUS_TDMA_READY)) {
+		DBG_PRINT(ERR_DBG, "%s", "TDMA is not ready!");
+		return 0;
+	}
+	if (!(val64 & ADAPTER_STATUS_RDMA_READY)) {
+	DBG_PRINT(ERR_DBG, "%s", "RDMA is not ready!");
+		return 0;
+	}
+	if (!(val64 & ADAPTER_STATUS_PFC_READY)) {
+		DBG_PRINT(ERR_DBG, "%s", "PFC is not ready!");
+		return 0;
+	}
+	if (!(val64 & ADAPTER_STATUS_TMAC_BUF_EMPTY)) {
+		DBG_PRINT(ERR_DBG, "%s", "TMAC BUF is not empty!");
+		return 0;
+	}
+	if (!(val64 & ADAPTER_STATUS_PIC_QUIESCENT)) {
+		DBG_PRINT(ERR_DBG, "%s", "PIC is not QUIESCENT!");
+		return 0;
+	}
+	if (!(val64 & ADAPTER_STATUS_MC_DRAM_READY)) {
+		DBG_PRINT(ERR_DBG, "%s", "MC_DRAM is not ready!");
+		return 0;
+	}
+	if (!(val64 & ADAPTER_STATUS_MC_QUEUES_READY)) {
+		DBG_PRINT(ERR_DBG, "%s", "MC_QUEUES is not ready!");
+		return 0;
+	}
+	if (!(val64 & ADAPTER_STATUS_M_PLL_LOCK)) {
+		DBG_PRINT(ERR_DBG, "%s", "M_PLL is not locked!");
+		return 0;
 	}
 
-	return ret;
+	/*
+	 * Andrew: in PCI 33 mode, the P_PLL is not used, and therefore,
+	 * the the P_PLL_LOCK bit in the adapter_status register will
+	 * not be asserted.
+	 */
+	if (!(val64 & ADAPTER_STATUS_P_PLL_LOCK) &&
+		sp->device_type == XFRAME_II_DEVICE && mode !=
+		PCI_MODE_PCI_33) {
+		DBG_PRINT(ERR_DBG, "%s", "P_PLL is not locked!");
+		return 0;
+	}
+	if (!((val64 & ADAPTER_STATUS_RC_PRC_QUIESCENT) ==
+			ADAPTER_STATUS_RC_PRC_QUIESCENT)) {
+		DBG_PRINT(ERR_DBG, "%s", "RC_PRC is not QUIESCENT!");
+		return 0;
+	}
+	return 1;
 }
 
 /**
@@ -2054,7 +2086,7 @@ static int start_nic(struct s2io_nic *ni
 	 * it.
 	 */
 	val64 = readq(&bar0->adapter_status);
-	if (!verify_xena_quiescence(nic, val64, nic->device_enabled_once)) {
+	if (!verify_xena_quiescence(nic)) {
 		DBG_PRINT(ERR_DBG, "%s: device is not ready, ", dev->name);
 		DBG_PRINT(ERR_DBG, "Adapter status reads: 0x%llx\n",
 			  (unsigned long long) val64);
@@ -2579,7 +2611,6 @@ static int s2io_poll(struct net_device *
 	mac_info_t *mac_control;
 	struct config_param *config;
 	XENA_dev_config_t __iomem *bar0 = nic->bar0;
-	u64 val64 = 0xFFFFFFFFFFFFFFFFULL;
 	int i;
 
 	atomic_inc(&nic->isr_cnt);
@@ -2591,8 +2622,8 @@ static int s2io_poll(struct net_device *
 		nic->pkts_to_process = dev->quota;
 	org_pkts_to_process = nic->pkts_to_process;
 
-	writeq(val64, &bar0->rx_traffic_int);
-	val64 = readl(&bar0->rx_traffic_int);
+	writeq(S2IO_MINUS_ONE, &bar0->rx_traffic_int);
+	readl(&bar0->rx_traffic_int);
 
 	for (i = 0; i < config->rx_ring_num; i++) {
 		rx_intr_handler(&mac_control->rings[i]);
@@ -2618,7 +2649,7 @@ static int s2io_poll(struct net_device *
 	}
 	/* Re enable the Rx interrupts. */
 	writeq(0x0, &bar0->rx_traffic_mask);
-	val64 = readl(&bar0->rx_traffic_mask);
+	readl(&bar0->rx_traffic_mask);
 	atomic_dec(&nic->isr_cnt);
 	return 0;
 
@@ -2852,11 +2883,10 @@ static void tx_intr_handler(fifo_info_t 
 			}
 			if ((err >> 48) == 0xA) {
 				DBG_PRINT(TX_DBG, "TxD returned due \
-to loss of link\n");
+						to loss of link\n");
 			}
 			else {
-				DBG_PRINT(ERR_DBG, "***TxD error \
-%llx\n", err);
+				DBG_PRINT(ERR_DBG, "***TxD error %llx\n", err);
 			}
 		}
 
@@ -3295,6 +3325,25 @@ static int wait_for_cmd_complete(void __
 	}
 	return ret;
 }
+/*
+ * check_pci_device_id - Checks if the device id is supported
+ * @id : device id 
+ * Description: Function to check if the pci device id is supported by driver.
+ * Return value: Actual device id if supported else PCI_ANY_ID
+ */
+static u16 check_pci_device_id(u16 id)
+{
+	switch (id) {
+	case PCI_DEVICE_ID_HERC_WIN:
+	case PCI_DEVICE_ID_HERC_UNI:
+		return XFRAME_II_DEVICE;
+	case PCI_DEVICE_ID_S2IO_UNI:
+	case PCI_DEVICE_ID_S2IO_WIN:
+		return XFRAME_I_DEVICE;
+	default:
+		return PCI_ANY_ID;
+	}
+}
 
 /**
  *  s2io_reset - Resets the card.
@@ -3311,38 +3360,53 @@ static void s2io_reset(nic_t * sp)
 	XENA_dev_config_t __iomem *bar0 = sp->bar0;
 	u64 val64;
 	u16 subid, pci_cmd;
+	int i;
+	u16 val16;
+	DBG_PRINT(INIT_DBG,"%s - Resetting XFrame card %s\n",
+			__FUNCTION__, sp->dev->name);
 
 	/* Back up  the PCI-X CMD reg, dont want to lose MMRBC, OST settings */
 	pci_read_config_word(sp->pdev, PCIX_COMMAND_REGISTER, &(pci_cmd));
 
+	if (sp->device_type == XFRAME_II_DEVICE) {
+		int ret;
+		ret = pci_set_power_state(sp->pdev, 3);
+		if (!ret)
+			ret = pci_set_power_state(sp->pdev, 0);
+		else {
+			DBG_PRINT(ERR_DBG,"%s PME based SW_Reset failed!\n",
+					__FUNCTION__);
+			goto old_way;
+		}
+		msleep(20);
+		goto new_way;
+	}
+old_way:
 	val64 = SW_RESET_ALL;
 	writeq(val64, &bar0->sw_reset);
-
-	/*
-	 * At this stage, if the PCI write is indeed completed, the
-	 * card is reset and so is the PCI Config space of the device.
-	 * So a read cannot be issued at this stage on any of the
-	 * registers to ensure the write into "sw_reset" register
-	 * has gone through.
-	 * Question: Is there any system call that will explicitly force
-	 * all the write commands still pending on the bus to be pushed
-	 * through?
-	 * As of now I'am just giving a 250ms delay and hoping that the
-	 * PCI write to sw_reset register is done by this time.
-	 */
-	msleep(250);
+new_way:
 	if (strstr(sp->product_name, "CX4")) {
 		msleep(750);
 	}
+	msleep(250);
+	for (i = 0; i < S2IO_MAX_PCI_CONFIG_SPACE_REINIT; i++) {
 
-	/* Restore the PCI state saved during initialization. */
-	pci_restore_state(sp->pdev);
-	pci_write_config_word(sp->pdev, PCIX_COMMAND_REGISTER,
-				     pci_cmd);
-	s2io_init_pci(sp);
+		/* Restore the PCI state saved during initialization. */
+		pci_restore_state(sp->pdev);
+		pci_read_config_word(sp->pdev, 0x2, &val16);
+		if (check_pci_device_id(val16) != (u16)PCI_ANY_ID)
+			break;
+		msleep(200);
+	}
 
-	msleep(250);
+	if (check_pci_device_id(val16) == (u16)PCI_ANY_ID) {
+		DBG_PRINT(ERR_DBG,"%s SW_Reset failed!\n", __FUNCTION__);
+	}
 
+	pci_write_config_word(sp->pdev, PCIX_COMMAND_REGISTER, pci_cmd);
+
+	s2io_init_pci(sp);
+		
 	/* Set swapper to enable I/O register access */
 	s2io_set_swapper(sp);
 
@@ -4107,39 +4171,33 @@ static void s2io_txpic_intr_handle(nic_t
 		}
 		else if (val64 & GPIO_INT_REG_LINK_UP) {
 			val64 = readq(&bar0->adapter_status);
-			if (verify_xena_quiescence(sp, val64,
-						   sp->device_enabled_once)) {
 				/* Enable Adapter */
-				val64 = readq(&bar0->adapter_control);
-				val64 |= ADAPTER_CNTL_EN;
-				writeq(val64, &bar0->adapter_control);
-				val64 |= ADAPTER_LED_ON;
-				writeq(val64, &bar0->adapter_control);
-				if (!sp->device_enabled_once)
-					sp->device_enabled_once = 1;
+			val64 = readq(&bar0->adapter_control);
+			val64 |= ADAPTER_CNTL_EN;
+			writeq(val64, &bar0->adapter_control);
+			val64 |= ADAPTER_LED_ON;
+			writeq(val64, &bar0->adapter_control);
+			if (!sp->device_enabled_once)
+				sp->device_enabled_once = 1;
 
-				s2io_link(sp, LINK_UP);
-				/*
-				 * unmask link down interrupt and mask link-up
-				 * intr
-				 */
-				val64 = readq(&bar0->gpio_int_mask);
-				val64 &= ~GPIO_INT_MASK_LINK_DOWN;
-				val64 |= GPIO_INT_MASK_LINK_UP;
-				writeq(val64, &bar0->gpio_int_mask);
+			s2io_link(sp, LINK_UP);
+			/*
+			 * unmask link down interrupt and mask link-up
+			 * intr
+			 */
+			val64 = readq(&bar0->gpio_int_mask);
+			val64 &= ~GPIO_INT_MASK_LINK_DOWN;
+			val64 |= GPIO_INT_MASK_LINK_UP;
+			writeq(val64, &bar0->gpio_int_mask);
 
-			}
 		}else if (val64 & GPIO_INT_REG_LINK_DOWN) {
 			val64 = readq(&bar0->adapter_status);
-			if (verify_xena_quiescence(sp, val64,
-						   sp->device_enabled_once)) {
-				s2io_link(sp, LINK_DOWN);
-				/* Link is down so unmaks link up interrupt */
-				val64 = readq(&bar0->gpio_int_mask);
-				val64 &= ~GPIO_INT_MASK_LINK_UP;
-				val64 |= GPIO_INT_MASK_LINK_DOWN;
-				writeq(val64, &bar0->gpio_int_mask);
-			}
+			s2io_link(sp, LINK_DOWN);
+			/* Link is down so unmaks link up interrupt */
+			val64 = readq(&bar0->gpio_int_mask);
+			val64 &= ~GPIO_INT_MASK_LINK_UP;
+			val64 |= GPIO_INT_MASK_LINK_DOWN;
+			writeq(val64, &bar0->gpio_int_mask);
 		}
 	}
 	val64 = readq(&bar0->gpio_int_mask);
@@ -4164,7 +4222,7 @@ static irqreturn_t s2io_isr(int irq, voi
 	nic_t *sp = dev->priv;
 	XENA_dev_config_t __iomem *bar0 = sp->bar0;
 	int i;
-	u64 reason = 0, val64, org_mask;
+	u64 reason = 0;
 	mac_info_t *mac_control;
 	struct config_param *config;
 
@@ -4183,22 +4241,24 @@ static irqreturn_t s2io_isr(int irq, voi
 	reason = readq(&bar0->general_int_status);
 
 	if (!reason) {
-		/* The interrupt was not raised by Xena. */
+		/* The interrupt was not raised by us. */
+		atomic_dec(&sp->isr_cnt);
+		return IRQ_NONE;
+	}
+	else if (unlikely(reason == S2IO_MINUS_ONE) ) {
+		/* Disable device and get out */
 		atomic_dec(&sp->isr_cnt);
 		return IRQ_NONE;
 	}
-
-	val64 = 0xFFFFFFFFFFFFFFFFULL;
-	/* Store current mask before masking all interrupts */
-	org_mask = readq(&bar0->general_int_mask);
-	writeq(val64, &bar0->general_int_mask);
 
 	if (napi) {
 		if (reason & GEN_INTR_RXTRAFFIC) {
-			if (netif_rx_schedule_prep(dev)) {
-				writeq(val64, &bar0->rx_traffic_mask);
+			if ( likely ( netif_rx_schedule_prep(dev)) ) {
 				__netif_rx_schedule(dev);
+				writeq(S2IO_MINUS_ONE, &bar0->rx_traffic_mask);
 			}
+			else
+				writeq(S2IO_MINUS_ONE, &bar0->rx_traffic_int);
 		}
 	} else {
 		/*
@@ -4208,7 +4268,9 @@ static irqreturn_t s2io_isr(int irq, voi
 	 	* will ensure that the actual interrupt causing bit get's
 	 	* cleared and hence a read can be avoided.
 	 	*/
-		writeq(val64, &bar0->rx_traffic_int);
+		if (reason & GEN_INTR_RXTRAFFIC)
+			writeq(S2IO_MINUS_ONE, &bar0->rx_traffic_int);
+
 		for (i = 0; i < config->rx_ring_num; i++) {
 			rx_intr_handler(&mac_control->rings[i]);
 		}
@@ -4219,7 +4281,8 @@ static irqreturn_t s2io_isr(int irq, voi
 	 * will ensure that the actual interrupt causing bit get's
 	 * cleared and hence a read can be avoided.
 	 */
-	writeq(val64, &bar0->tx_traffic_int);
+	if (reason & GEN_INTR_TXTRAFFIC)
+		writeq(S2IO_MINUS_ONE, &bar0->tx_traffic_int);
 
 	for (i = 0; i < config->tx_fifo_num; i++)
 		tx_intr_handler(&mac_control->fifos[i]);
@@ -4915,6 +4978,7 @@ static void s2io_vpd_read(nic_t *nic)
 		strcpy(nic->product_name, "Xframe I 10GbE network adapter");
 		vpd_addr = 0x50;
 	}
+	strcpy(nic->serial_num, "NOT AVAILABLE");
 
 	vpd_data = kmalloc(256, GFP_KERNEL);
 	if (!vpd_data)
@@ -4938,7 +5002,22 @@ static void s2io_vpd_read(nic_t *nic)
 		pci_read_config_dword(nic->pdev,  (vpd_addr + 4),
 				      (u32 *)&vpd_data[i]);
 	}
-	if ((!fail) && (vpd_data[1] < VPD_PRODUCT_NAME_LEN)) {
+
+	if(!fail) {
+		/* read serial number of adapter */
+		for (cnt = 0; cnt < 256; cnt++) {
+		if ((vpd_data[cnt] == 'S') &&
+			(vpd_data[cnt+1] == 'N') &&
+			(vpd_data[cnt+2] < VPD_STRING_LEN)) {
+				memset(nic->serial_num, 0, VPD_STRING_LEN);
+				memcpy(nic->serial_num, &vpd_data[cnt + 3],
+					vpd_data[cnt+2]);
+				break;
+			}
+		}
+        }
+
+	if ((!fail) && (vpd_data[1] < VPD_STRING_LEN)) {
 		memset(nic->product_name, 0, vpd_data[1]);
 		memcpy(nic->product_name, &vpd_data[3], vpd_data[1]);
 	}
@@ -5895,50 +5974,45 @@ static void s2io_set_link(struct work_st
 	}
 
 	val64 = readq(&bar0->adapter_status);
-	if (verify_xena_quiescence(nic, val64, nic->device_enabled_once)) {
-		if (LINK_IS_UP(val64)) {
-			val64 = readq(&bar0->adapter_control);
-			val64 |= ADAPTER_CNTL_EN;
-			writeq(val64, &bar0->adapter_control);
-			if (CARDS_WITH_FAULTY_LINK_INDICATORS(nic->device_type,
-							     subid)) {
-				val64 = readq(&bar0->gpio_control);
-				val64 |= GPIO_CTRL_GPIO_0;
-				writeq(val64, &bar0->gpio_control);
-				val64 = readq(&bar0->gpio_control);
-			} else {
-				val64 |= ADAPTER_LED_ON;
+	if (LINK_IS_UP(val64)) {
+		if (!(readq(&bar0->adapter_control) & ADAPTER_CNTL_EN)) {
+			if (verify_xena_quiescence(nic)) {
+				val64 = readq(&bar0->adapter_control);
+				val64 |= ADAPTER_CNTL_EN;
 				writeq(val64, &bar0->adapter_control);
-			}
-			if (s2io_link_fault_indication(nic) ==
-						MAC_RMAC_ERR_TIMER) {
-				val64 = readq(&bar0->adapter_status);
-				if (!LINK_IS_UP(val64)) {
-					DBG_PRINT(ERR_DBG, "%s:", dev->name);
-					DBG_PRINT(ERR_DBG, " Link down");
-					DBG_PRINT(ERR_DBG, "after ");
-					DBG_PRINT(ERR_DBG, "enabling ");
-					DBG_PRINT(ERR_DBG, "device \n");
+				if (CARDS_WITH_FAULTY_LINK_INDICATORS(
+					nic->device_type, subid)) {
+					val64 = readq(&bar0->gpio_control);
+					val64 |= GPIO_CTRL_GPIO_0;
+					writeq(val64, &bar0->gpio_control);
+					val64 = readq(&bar0->gpio_control);
+				} else {
+					val64 |= ADAPTER_LED_ON;
+					writeq(val64, &bar0->adapter_control);
 				}
-			}
-			if (nic->device_enabled_once == FALSE) {
 				nic->device_enabled_once = TRUE;
+			} else {
+				DBG_PRINT(ERR_DBG, "%s: Error: ", dev->name);
+				DBG_PRINT(ERR_DBG, "device is not Quiescent\n");
+				netif_stop_queue(dev);
 			}
+		}
+		val64 = readq(&bar0->adapter_status);
+		if (!LINK_IS_UP(val64)) {
+			DBG_PRINT(ERR_DBG, "%s:", dev->name);
+			DBG_PRINT(ERR_DBG, " Link down after enabling ");
+			DBG_PRINT(ERR_DBG, "device \n");			
+		} else 
 			s2io_link(nic, LINK_UP);
-		} else {
-			if (CARDS_WITH_FAULTY_LINK_INDICATORS(nic->device_type,
-							      subid)) {
-				val64 = readq(&bar0->gpio_control);
-				val64 &= ~GPIO_CTRL_GPIO_0;
-				writeq(val64, &bar0->gpio_control);
-				val64 = readq(&bar0->gpio_control);
-			}
-			s2io_link(nic, LINK_DOWN);
+	} else {
+		if (CARDS_WITH_FAULTY_LINK_INDICATORS(nic->device_type,
+						      subid)) {
+			val64 = readq(&bar0->gpio_control);
+			val64 &= ~GPIO_CTRL_GPIO_0;
+			writeq(val64, &bar0->gpio_control);
+			val64 = readq(&bar0->gpio_control);
 		}
-	} else {		/* NIC is not Quiescent. */
-		DBG_PRINT(ERR_DBG, "%s: Error: ", dev->name);
-		DBG_PRINT(ERR_DBG, "device is not Quiescent\n");
-		netif_stop_queue(dev);
+		s2io_link(nic, LINK_DOWN);
 	}
 	clear_bit(0, &(nic->link_state));
 }
@@ -5987,7 +6061,7 @@ static int set_rxd_buffer_pointer(nic_t 
 			*skb = dev_alloc_skb(size);
 			if (!(*skb)) {
 				DBG_PRINT(ERR_DBG, "%s: dev_alloc_skb failed\n",
-					  dev->name);
+					dev->name);
 				return -ENOMEM;
 			}
 			((RxD3_t*)rxdp)->Buffer2_ptr = *temp2 =
@@ -6257,7 +6331,8 @@ static void s2io_card_down(nic_t * sp)
 		rxd_owner_bit_reset(sp);
 
 		val64 = readq(&bar0->adapter_status);
-		if (verify_xena_quiescence(sp, val64, sp->device_enabled_once)) {
+		if (verify_xena_quiescence(sp)) {
+			if(verify_pcc_quiescent(sp, sp->device_enabled_once))
 			break;
 		}
 
@@ -6320,6 +6395,13 @@ static int s2io_card_up(nic_t * sp)
 		DBG_PRINT(INFO_DBG, "Buf in ring:%d is %d:\n", i,
 			  atomic_read(&sp->rx_bufs_left[i]));
 	}
+	/* Maintain the state prior to the open */
+	if (sp->promisc_flg)
+		sp->promisc_flg = 0;
+	if (sp->m_cast_flg) {
+		sp->m_cast_flg = 0;
+		sp->all_multi_pos= 0;
+	}
 
 	/* Setting its receive mode */
 	s2io_set_multicast(dev);
@@ -6920,7 +7002,7 @@ s2io_init_nic(struct pci_dev *pdev, cons
 	sp->bar0 = ioremap(pci_resource_start(pdev, 0),
 				     pci_resource_len(pdev, 0));
 	if (!sp->bar0) {
-		DBG_PRINT(ERR_DBG, "%s: S2IO: cannot remap io mem1\n",
+		DBG_PRINT(ERR_DBG, "%s: Neterion: cannot remap io mem1\n",
 			  dev->name);
 		ret = -ENOMEM;
 		goto bar0_remap_failed;
@@ -6929,7 +7011,7 @@ s2io_init_nic(struct pci_dev *pdev, cons
 	sp->bar1 = ioremap(pci_resource_start(pdev, 2),
 				     pci_resource_len(pdev, 2));
 	if (!sp->bar1) {
-		DBG_PRINT(ERR_DBG, "%s: S2IO: cannot remap io mem2\n",
+		DBG_PRINT(ERR_DBG, "%s: Neterion: cannot remap io mem2\n",
 			  dev->name);
 		ret = -ENOMEM;
 		goto bar1_remap_failed;
@@ -7093,13 +7175,14 @@ s2io_init_nic(struct pci_dev *pdev, cons
 	DBG_PRINT(ERR_DBG, "%s: Driver version %s\n", dev->name,
 		  s2io_driver_version);
 	DBG_PRINT(ERR_DBG, "%s: MAC ADDR: "
-			  "%02x:%02x:%02x:%02x:%02x:%02x\n", dev->name,
+			  "%02x:%02x:%02x:%02x:%02x:%02x", dev->name,
 			  sp->def_mac_addr[0].mac_addr[0],
 			  sp->def_mac_addr[0].mac_addr[1],
 			  sp->def_mac_addr[0].mac_addr[2],
 			  sp->def_mac_addr[0].mac_addr[3],
 			  sp->def_mac_addr[0].mac_addr[4],
 			  sp->def_mac_addr[0].mac_addr[5]);
+	DBG_PRINT(ERR_DBG, "SERIAL NUMBER: %s\n", sp->serial_num);
 	if (sp->device_type & XFRAME_II_DEVICE) {
 		mode = s2io_print_pci_mode(sp);
 		if (mode < 0) {
@@ -7212,7 +7295,6 @@ static void __devexit s2io_rem_nic(struc
 	free_shared_mem(sp);
 	iounmap(sp->bar0);
 	iounmap(sp->bar1);
-	pci_disable_device(pdev);
 	if (sp->intr_type != MSI_X)
 		pci_release_regions(pdev);
 	else {
@@ -7223,6 +7305,7 @@ static void __devexit s2io_rem_nic(struc
 	}
 	pci_set_drvdata(pdev, NULL);
 	free_netdev(dev);
+	pci_disable_device(pdev);
 }
 
 /**
diff -urpN patch1/drivers/net/s2io.h patch2/drivers/net/s2io.h
--- patch1/drivers/net/s2io.h	2007-01-09 14:33:06.000000000 +0530
+++ patch2/drivers/net/s2io.h	2007-01-09 14:33:22.000000000 +0530
@@ -30,6 +30,8 @@
 #undef SUCCESS
 #define SUCCESS 0
 #define FAILURE -1
+#define S2IO_MINUS_ONE 0xFFFFFFFFFFFFFFFFULL
+#define S2IO_MAX_PCI_CONFIG_SPACE_REINIT 100
 
 #define CHECKBIT(value, nbit) (value & (1 << nbit))
 
@@ -537,9 +539,9 @@ typedef struct _RxD_block {
 
 #define SIZE_OF_BLOCK	4096
 
-#define RXD_MODE_1	0
-#define RXD_MODE_3A	1
-#define RXD_MODE_3B	2
+#define RXD_MODE_1	0 //One Buffer mode
+#define RXD_MODE_3A	1 //Three Buffer mode
+#define RXD_MODE_3B	2 //Two Buffer mode
 
 /* Structure to hold virtual addresses of Buf0 and Buf1 in
  * 2buf mode. */
@@ -849,8 +851,9 @@ struct s2io_nic {
 	spinlock_t	rx_lock;
 	atomic_t	isr_cnt;
 	u64 *ufo_in_band_v;
-#define VPD_PRODUCT_NAME_LEN 50
-	u8  product_name[VPD_PRODUCT_NAME_LEN];
+#define VPD_STRING_LEN 80
+	u8  product_name[VPD_STRING_LEN];
+	u8  serial_num[VPD_STRING_LEN];
 };
 
 #define RESET_ERROR 1;
@@ -893,10 +896,10 @@ static inline void SPECIAL_REG_WRITE(u64
 		writel((u32) (val), addr);
 		ret = readl(addr);
 		writel((u32) (val >> 32), (addr + 4));
-		ret = readl(addr + 4);
+		ret = readl((addr + 4));
 	} else {
 		writel((u32) (val >> 32), (addr + 4));
-		ret = readl(addr + 4);
+		ret = readl((addr + 4));
 		writel((u32) (val), addr);
 		ret = readl(addr);
 	}
@@ -974,11 +977,13 @@ static void tx_intr_handler(fifo_info_t 
 static void alarm_intr_handler(struct s2io_nic *sp);
 
 static int s2io_starter(void);
+static void s2io_closer(void);
 static void s2io_tx_watchdog(struct net_device *dev);
 static void s2io_tasklet(unsigned long dev_addr);
 static void s2io_set_multicast(struct net_device *dev);
 static int rx_osm_handler(ring_info_t *ring_data, RxD_t * rxdp);
 static void s2io_link(nic_t * sp, int link);
+static void s2io_reset(nic_t * sp);
 #if defined (HAVE_NETDEV_POLL)
 static int s2io_poll(struct net_device *dev, int *budget);
 #endif
@@ -992,13 +997,17 @@ s2io_msix_ring_handle(int irq, void *dev
 static irqreturn_t
 s2io_msix_fifo_handle(int irq, void *dev_id);
 static irqreturn_t s2io_isr(int irq, void *dev_id);
-static int verify_xena_quiescence(nic_t *sp, u64 val64, int flag);
+static int verify_xena_quiescence(nic_t *sp);
 static const struct ethtool_ops netdev_ethtool_ops;
 static void s2io_set_link(struct work_struct *work);
 static int s2io_set_swapper(nic_t * sp);
 static void s2io_card_down(nic_t *nic);
 static int s2io_card_up(nic_t *nic);
 static int get_xena_rev_id(struct pci_dev *pdev);
+static int wait_for_cmd_complete(void *addr, u64 busy_bit);
+static int s2io_add_isr(nic_t * sp);
+static void s2io_rem_isr(nic_t * sp);
+
 static void restore_xmsi_data(nic_t *nic);
 
 static int s2io_club_tcp_session(u8 *buffer, u8 **tcp, u32 *tcp_len, lro_t **lro, RxD_t *rxdp, nic_t *sp);
diff -urpN patch1/drivers/net/s2io-regs.h patch2/drivers/net/s2io-regs.h
--- patch1/drivers/net/s2io-regs.h	2007-01-08 10:37:49.000000000 +0530
+++ patch2/drivers/net/s2io-regs.h	2007-01-08 15:06:50.000000000 +0530
@@ -300,6 +300,7 @@ typedef struct _XENA_dev_config {
 	u64 gpio_control;
 #define GPIO_CTRL_GPIO_0		BIT(8)
 	u64 misc_control;
+#define FAULT_BEHAVIOUR			BIT(0)
 #define EXT_REQ_EN			BIT(1)
 #define MISC_LINK_STABILITY_PRD(val)   vBIT(val,29,3)
 

