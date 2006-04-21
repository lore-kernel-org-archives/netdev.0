From: Ananda Raju <Ananda.Raju@neterion.com>
Subject: [patch 3/5] s2io driver updates
Date: Fri, 21 Apr 2006 19:18:03 -0400 (EDT)
Message-ID: <Pine.GSO.4.10.10604211915250.16549-100000@guinness>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: leonid.grossman@neterion.com, ravinandan.arakali@neterion.com,
	ananda.raju@neterion.com, alicia.pena@neterion.com,
	rapuru.sriram@neterion.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:11723 "EHLO
	barracuda.mail.s2io.com") by vger.kernel.org with ESMTP
	id S1750746AbWDUXSH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Apr 2006 19:18:07 -0400
To: jgarzik@pobox.com, netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi, 
	This patch contains some of the bug fixes done for S2io driver.
	Following are the brief description of changes

	1. Continuing with initialization if we get minimum required MSI-X vectors
	2. fix for ethtool online link test fails
	3. make wait_for_cmd_complete generic for all command status registers
	4. Print "Device is on PCI-E bus" for Xframe-E card
	5. CX4 requires additional delay after sw_reset, and requires higher value for igp
	6. Fixed panic due to non-TCP and/or LLC/SNAP traffic in case of lro
	7. remove legacy code for old transponder
	8. SPECIAL_REG_WRITE made to use 32-bit writes irrespective of system type
	9. handle link interrupt as per user guide for Xframe II
	10. Wait till all interrupts hndled

Signed-off-by: Ananda Raju <ananda.raju@neterion.com>
---
diff -upNr dmesg_param_fixes/drivers/net/s2io.c bug_fixes1/drivers/net/s2io.c
--- dmesg_param_fixes/drivers/net/s2io.c	2006-04-13 09:08:22.000000000 -0700
+++ bug_fixes1/drivers/net/s2io.c	2006-04-13 09:03:47.000000000 -0700
@@ -223,9 +223,7 @@ static void s2io_vlan_rx_kill_vid(struct
  * the XAUI.
  */
 
-#define SWITCH_SIGN	0xA5A5A5A5A5A5A5A5ULL
 #define	END_SIGN	0x0
-
 static const u64 herc_act_dtx_cfg[] = {
 	/* Set address */
 	0x8000051536750000ULL, 0x80000515367500E0ULL,
@@ -247,37 +245,19 @@ static const u64 herc_act_dtx_cfg[] = {
 	END_SIGN
 };
 
-static const u64 xena_mdio_cfg[] = {
-	/* Reset PMA PLL */
-	0xC001010000000000ULL, 0xC0010100000000E0ULL,
-	0xC0010100008000E4ULL,
-	/* Remove Reset from PMA PLL */
-	0xC001010000000000ULL, 0xC0010100000000E0ULL,
-	0xC0010100000000E4ULL,
-	END_SIGN
-};
-
 static const u64 xena_dtx_cfg[] = {
+	/* Set address */
 	0x8000051500000000ULL, 0x80000515000000E0ULL,
-	0x80000515D93500E4ULL, 0x8001051500000000ULL,
-	0x80010515000000E0ULL, 0x80010515001E00E4ULL,
-	0x8002051500000000ULL, 0x80020515000000E0ULL,
-	0x80020515F21000E4ULL,
-	/* Set PADLOOPBACKN */
-	0x8002051500000000ULL, 0x80020515000000E0ULL,
-	0x80020515B20000E4ULL, 0x8003051500000000ULL,
-	0x80030515000000E0ULL, 0x80030515B20000E4ULL,
-	0x8004051500000000ULL, 0x80040515000000E0ULL,
-	0x80040515B20000E4ULL, 0x8005051500000000ULL,
-	0x80050515000000E0ULL, 0x80050515B20000E4ULL,
-	SWITCH_SIGN,
-	/* Remove PADLOOPBACKN */
+	/* Write data */
+	0x80000515D9350004ULL, 0x80000515D93500E4ULL,
+	/* Set address */
+	0x8001051500000000ULL, 0x80010515000000E0ULL,
+	/* Write data */
+	0x80010515001E0004ULL, 0x80010515001E00E4ULL,
+	/* Set address */
 	0x8002051500000000ULL, 0x80020515000000E0ULL,
-	0x80020515F20000E4ULL, 0x8003051500000000ULL,
-	0x80030515000000E0ULL, 0x80030515F20000E4ULL,
-	0x8004051500000000ULL, 0x80040515000000E0ULL,
-	0x80040515F20000E4ULL, 0x8005051500000000ULL,
-	0x80050515000000E0ULL, 0x80050515F20000E4ULL,
+	/* Write data */
+	0x80020515F2100004ULL, 0x80020515F21000E4ULL,
 	END_SIGN
 };
 
@@ -552,11 +532,6 @@ static int init_shared_mem(struct s2io_n
 					rx_blocks->block_dma_addr +
 					(rxd_size[nic->rxd_mode] * l);
 			}
-
-			mac_control->rings[i].rx_blocks[j].block_virt_addr =
-				tmp_v_addr;
-			mac_control->rings[i].rx_blocks[j].block_dma_addr =
-				tmp_p_addr;
 		}
 		/* Interlinking all Rx Blocks */
 		for (j = 0; j < blk_cnt; j++) {
@@ -775,7 +750,21 @@ static int s2io_verify_pci_mode(nic_t *n
 	return mode;
 }
 
+#define NEC_VENID   0x1033
+#define NEC_DEVID   0x0125
+static int s2io_on_nec_bridge(struct pci_dev *s2io_pdev)
+{
+	struct pci_dev *tdev = NULL;
+	while ((tdev = pci_find_device(PCI_ANY_ID, PCI_ANY_ID, tdev)) != NULL) {
+		if ((tdev->vendor == NEC_VENID) && (tdev->device == NEC_DEVID)){
+			if (tdev->bus == s2io_pdev->bus->parent)
+				return 1;
+		}
+	}
+	return 0;
+}
 
+int bus_speed[8] = {33, 133, 133, 200, 266, 133, 200, 266};
 /**
  * s2io_print_pci_mode -
  */
@@ -792,6 +781,14 @@ static int s2io_print_pci_mode(nic_t *ni
 	if ( val64 & PCI_MODE_UNKNOWN_MODE)
 		return -1;	/* Unknown PCI mode */
 
+	config->bus_speed = bus_speed[mode];
+
+	if (s2io_on_nec_bridge(nic->pdev)) {
+		DBG_PRINT(ERR_DBG, "%s: Device is on PCI-E bus\n",
+							nic->dev->name);
+		return mode;
+	}
+
 	if (val64 & PCI_MODE_32_BITS) {
 		DBG_PRINT(ERR_DBG, "%s: Device is on 32 bit ", nic->dev->name);
 	} else {
@@ -801,35 +798,27 @@ static int s2io_print_pci_mode(nic_t *ni
 	switch(mode) {
 		case PCI_MODE_PCI_33:
 			DBG_PRINT(ERR_DBG, "33MHz PCI bus\n");
-			config->bus_speed = 33;
 			break;
 		case PCI_MODE_PCI_66:
 			DBG_PRINT(ERR_DBG, "66MHz PCI bus\n");
-			config->bus_speed = 133;
 			break;
 		case PCI_MODE_PCIX_M1_66:
 			DBG_PRINT(ERR_DBG, "66MHz PCIX(M1) bus\n");
-			config->bus_speed = 133; /* Herc doubles the clock rate */
 			break;
 		case PCI_MODE_PCIX_M1_100:
 			DBG_PRINT(ERR_DBG, "100MHz PCIX(M1) bus\n");
-			config->bus_speed = 200;
 			break;
 		case PCI_MODE_PCIX_M1_133:
 			DBG_PRINT(ERR_DBG, "133MHz PCIX(M1) bus\n");
-			config->bus_speed = 266;
 			break;
 		case PCI_MODE_PCIX_M2_66:
 			DBG_PRINT(ERR_DBG, "133MHz PCIX(M2) bus\n");
-			config->bus_speed = 133;
 			break;
 		case PCI_MODE_PCIX_M2_100:
 			DBG_PRINT(ERR_DBG, "200MHz PCIX(M2) bus\n");
-			config->bus_speed = 200;
 			break;
 		case PCI_MODE_PCIX_M2_133:
 			DBG_PRINT(ERR_DBG, "266MHz PCIX(M2) bus\n");
-			config->bus_speed = 266;
 			break;
 		default:
 			return -1;	/* Unsupported bus speed */
@@ -857,7 +846,7 @@ static int init_nic(struct s2io_nic *nic
 	int i, j;
 	mac_info_t *mac_control;
 	struct config_param *config;
-	int mdio_cnt = 0, dtx_cnt = 0;
+	int dtx_cnt = 0;
 	unsigned long long mem_share;
 	int mem_size;
 
@@ -904,20 +893,6 @@ static int init_nic(struct s2io_nic *nic
 	val64 = dev->mtu;
 	writeq(vBIT(val64, 2, 14), &bar0->rmac_max_pyld_len);
 
-	/*
-	 * Configuring the XAUI Interface of Xena.
-	 * ***************************************
-	 * To Configure the Xena's XAUI, one has to write a series
-	 * of 64 bit values into two registers in a particular
-	 * sequence. Hence a macro 'SWITCH_SIGN' has been defined
-	 * which will be defined in the array of configuration values
-	 * (xena_dtx_cfg & xena_mdio_cfg) at appropriate places
-	 * to switch writing from one regsiter to another. We continue
-	 * writing these values until we encounter the 'END_SIGN' macro.
-	 * For example, After making a series of 21 writes into
-	 * dtx_control register the 'SWITCH_SIGN' appears and hence we
-	 * start writing into mdio_control until we encounter END_SIGN.
-	 */
 	if (nic->device_type & XFRAME_II_DEVICE) {
 		while (herc_act_dtx_cfg[dtx_cnt] != END_SIGN) {
 			SPECIAL_REG_WRITE(herc_act_dtx_cfg[dtx_cnt],
@@ -927,35 +902,11 @@ static int init_nic(struct s2io_nic *nic
 			dtx_cnt++;
 		}
 	} else {
-		while (1) {
-		      dtx_cfg:
-			while (xena_dtx_cfg[dtx_cnt] != END_SIGN) {
-				if (xena_dtx_cfg[dtx_cnt] == SWITCH_SIGN) {
-					dtx_cnt++;
-					goto mdio_cfg;
-				}
-				SPECIAL_REG_WRITE(xena_dtx_cfg[dtx_cnt],
-						  &bar0->dtx_control, UF);
-				val64 = readq(&bar0->dtx_control);
-				dtx_cnt++;
-			}
-		      mdio_cfg:
-			while (xena_mdio_cfg[mdio_cnt] != END_SIGN) {
-				if (xena_mdio_cfg[mdio_cnt] == SWITCH_SIGN) {
-					mdio_cnt++;
-					goto dtx_cfg;
-				}
-				SPECIAL_REG_WRITE(xena_mdio_cfg[mdio_cnt],
-						  &bar0->mdio_control, UF);
-				val64 = readq(&bar0->mdio_control);
-				mdio_cnt++;
-			}
-			if ((xena_dtx_cfg[dtx_cnt] == END_SIGN) &&
-			    (xena_mdio_cfg[mdio_cnt] == END_SIGN)) {
-				break;
-			} else {
-				goto dtx_cfg;
-			}
+		while (xena_dtx_cfg[dtx_cnt] != END_SIGN) {
+			SPECIAL_REG_WRITE(xena_dtx_cfg[dtx_cnt],
+					  &bar0->dtx_control, UF);
+			val64 = readq(&bar0->dtx_control);
+			dtx_cnt++;
 		}
 	}
 
@@ -1565,11 +1516,9 @@ static int init_nic(struct s2io_nic *nic
 		val64 &= ~(BIT(13)|BIT(14)|BIT(15));
 		writeq(val64, &bar0->pic_control2);
 	}
-
-	/* Setting Link stability period to 64 ms */ 
-	if (nic->device_type == XFRAME_II_DEVICE) {
-		val64 = MISC_LINK_STABILITY_PRD(3);
-		writeq(val64, &bar0->misc_control);
+	if (strstr(nic->product_name, "CX4")) {
+		val64 = TMAC_AVG_IPG(0x17);
+		writeq(val64, &bar0->tmac_avg_ipg);
 	}
 
 	return SUCCESS;
@@ -2034,6 +1983,13 @@ static int start_nic(struct s2io_nic *ni
 	val64 |= ADAPTER_EOI_TX_ON;
 	writeq(val64, &bar0->adapter_control);
 
+	if (s2io_link_fault_indication(nic) == MAC_RMAC_ERR_TIMER) {
+		/*
+		 * Dont see link state interrupts initally on some switches,
+		 * so directly scheduling the link state task here.
+		 */
+		schedule_work(&nic->set_link_task);
+	}
 	/* SXE-002: Initialize link and activity LED */
 	subid = nic->pdev->subsystem_device;
 	if (((subid & 0xFF) >= 0x07) &&
@@ -2045,12 +2001,6 @@ static int start_nic(struct s2io_nic *ni
 		writeq(val64, (void __iomem *)bar0 + 0x2700);
 	}
 
-	/*
-	 * Don't see link state interrupts on certain switches, so
-	 * directly scheduling a link state task from here.
-	 */
-	schedule_work(&nic->set_link_task);
-
 	return SUCCESS;
 }
 /**
@@ -2569,7 +2519,8 @@ static int s2io_poll(struct net_device *
 		}
 	}
 	/* Re enable the Rx interrupts. */
-	en_dis_able_nic_intrs(nic, RX_TRAFFIC_INTR, ENABLE_INTRS);
+	writeq(0x0, &bar0->rx_traffic_mask);
+	val64 = readl(&bar0->rx_traffic_mask);
 	atomic_dec(&nic->isr_cnt);
 	return 0;
 
@@ -2881,23 +2832,26 @@ static void alarm_intr_handler(struct s2
  *   SUCCESS on success and FAILURE on failure.
  */
 
-static int wait_for_cmd_complete(nic_t * sp)
+static int wait_for_cmd_complete(void *addr, u64 busy_bit)
 {
-	XENA_dev_config_t __iomem *bar0 = sp->bar0;
 	int ret = FAILURE, cnt = 0;
 	u64 val64;
 
 	while (TRUE) {
-		val64 = readq(&bar0->rmac_addr_cmd_mem);
-		if (!(val64 & RMAC_ADDR_CMD_MEM_STROBE_CMD_EXECUTING)) {
+		val64 = readq(addr);
+		if (!(val64 & busy_bit)) {
 			ret = SUCCESS;
 			break;
 		}
-		msleep(50);
+
+		if(in_interrupt())
+			mdelay(50);
+		else
+			msleep(50);
+
 		if (cnt++ > 10)
 			break;
 	}
-
 	return ret;
 }
 
@@ -2936,6 +2890,9 @@ static void s2io_reset(nic_t * sp)
 	 * PCI write to sw_reset register is done by this time.
 	 */
 	msleep(250);
+	if (strstr(sp->product_name, "CX4")) {
+		msleep(750);
+	}
 
 	/* Restore the PCI state saved during initialization. */
 	pci_restore_state(sp->pdev);
@@ -3154,7 +3111,7 @@ static void restore_xmsi_data(nic_t *nic
 	u64 val64;
 	int i;
 
-	for (i=0; i< MAX_REQUESTED_MSI_X; i++) {
+	for (i=0; i< nic->avail_msix_vectors; i++) {
 		writeq(nic->msix_info[i].addr, &bar0->xmsi_address);
 		writeq(nic->msix_info[i].data, &bar0->xmsi_data);
 		val64 = (BIT(7) | BIT(15) | vBIT(i, 26, 6));
@@ -3173,7 +3130,7 @@ static void store_xmsi_data(nic_t *nic)
 	int i;
 
 	/* Store and display */
-	for (i=0; i< MAX_REQUESTED_MSI_X; i++) {
+	for (i=0; i< nic->avail_msix_vectors; i++) {
 		val64 = (BIT(15) | vBIT(i, 26, 6));
 		writeq(val64, &bar0->xmsi_access);
 		if (wait_for_msix_trans(nic, i)) {
@@ -3301,15 +3258,24 @@ static int s2io_enable_msi_x(nic_t *nic)
 		writeq(tx_mat, &bar0->tx_mat0_n[7]);
 	}
 
+	nic->avail_msix_vectors = 0;
 	ret = pci_enable_msix(nic->pdev, nic->entries, MAX_REQUESTED_MSI_X);
+	/* We fail init if error or we get less vectors than min required */
+	if (ret >= (nic->config.tx_fifo_num + nic->config.rx_ring_num + 1)) {
+		nic->avail_msix_vectors = ret;
+		ret = pci_enable_msix(nic->pdev, nic->entries, ret);
+	}
 	if (ret) {
 		DBG_PRINT(ERR_DBG, "%s: Enabling MSIX failed\n", nic->dev->name);
 		kfree(nic->entries);
 		kfree(nic->s2io_entries);
 		nic->entries = NULL;
 		nic->s2io_entries = NULL;
+		nic->avail_msix_vectors = 0;
 		return -ENOMEM;
 	}
+	if (!nic->avail_msix_vectors)
+		nic->avail_msix_vectors = MAX_REQUESTED_MSI_X;
 
 	/*
 	 * To enable MSI-X, MSI also needs to be enabled, due to a bug
@@ -3342,8 +3308,6 @@ static int s2io_open(struct net_device *
 {
 	nic_t *sp = dev->priv;
 	int err = 0;
-	int i;
-	u16 msi_control; /* Temp variable */
 
 	/*
 	 * Make sure you have link off by default every time
@@ -3353,11 +3317,14 @@ static int s2io_open(struct net_device *
 	sp->last_link_state = 0;
 
 	/* Initialize H/W and enable interrupts */
-	if (s2io_card_up(sp)) {
+	err = s2io_card_up(sp);
+	if (err) {
 		DBG_PRINT(ERR_DBG, "%s: H/W initialization failed\n",
 			  dev->name);
-		err = -ENODEV;
-		goto hw_init_failed;
+		if (err == -ENODEV)
+			goto hw_init_failed;
+		else
+			goto hw_enable_failed;
 	}
 
 	/* Store the values of the MSIX table in the nic_t structure */
@@ -3374,6 +3341,8 @@ failed\n", dev->name);
 		}
 	}
 	if (sp->intr_type == MSI_X) {
+		int i;
+
 		for (i=1; (sp->s2io_entries[i].in_use == MSIX_FLG); i++) {
 			if (sp->s2io_entries[i].type == MSIX_FIFO_TYPE) {
 				sprintf(sp->desc1, "%s:MSI-X-%d-TX",
@@ -3426,24 +3395,25 @@ setting_mac_address_failed:
 isr_registration_failed:
 	del_timer_sync(&sp->alarm_timer);
 	if (sp->intr_type == MSI_X) {
-		if (sp->device_type == XFRAME_II_DEVICE) {
-			for (i=1; (sp->s2io_entries[i].in_use == 
+		int i;
+		u16 msi_control; /* Temp variable */
+		for (i=1; (sp->s2io_entries[i].in_use == 
 				MSIX_REGISTERED_SUCCESS); i++) {
-				int vector = sp->entries[i].vector;
-				void *arg = sp->s2io_entries[i].arg;
-
-				free_irq(vector, arg);
-			}
-			pci_disable_msix(sp->pdev);
+			int vector = sp->entries[i].vector;
+			void *arg = sp->s2io_entries[i].arg;
 
-			/* Temp */
-			pci_read_config_word(sp->pdev, 0x42, &msi_control);
-			msi_control &= 0xFFFE; /* Disable MSI */
-			pci_write_config_word(sp->pdev, 0x42, msi_control);
+			free_irq(vector, arg);
 		}
+		pci_disable_msix(sp->pdev);
+
+		/* Temp */
+		pci_read_config_word(sp->pdev, 0x42, &msi_control);
+		msi_control &= 0xFFFE; /* Disable MSI */
+		pci_write_config_word(sp->pdev, 0x42, msi_control);
 	}
 	else if (sp->intr_type == MSI)
 		pci_disable_msi(sp->pdev);
+hw_enable_failed:
 	s2io_reset(sp);
 hw_init_failed:
 	if (sp->intr_type == MSI_X) {
@@ -3471,35 +3441,12 @@ hw_init_failed:
 static int s2io_close(struct net_device *dev)
 {
 	nic_t *sp = dev->priv;
-	int i;
-	u16 msi_control;
 
 	flush_scheduled_work();
 	netif_stop_queue(dev);
 	/* Reset card, kill tasklet and free Tx and Rx buffers. */
-	s2io_card_down(sp);
-
-	if (sp->intr_type == MSI_X) {
-		if (sp->device_type == XFRAME_II_DEVICE) {
-			for (i=1; (sp->s2io_entries[i].in_use == 
-					MSIX_REGISTERED_SUCCESS); i++) {
-				int vector = sp->entries[i].vector;
-				void *arg = sp->s2io_entries[i].arg;
-
-				free_irq(vector, arg);
-			}
-			pci_read_config_word(sp->pdev, 0x42, &msi_control);
-			msi_control &= 0xFFFE; /* Disable MSI */
-			pci_write_config_word(sp->pdev, 0x42, msi_control);
+	s2io_card_down(sp, 1);
 
-			pci_disable_msix(sp->pdev);
-		}
-	}
-	else {
-		free_irq(sp->pdev->irq, dev);
-		if (sp->intr_type == MSI)
-			pci_disable_msi(sp->pdev);
-	}	
 	sp->device_close_flag = TRUE;	/* Device is shut down. */
 	return 0;
 }
@@ -3825,41 +3772,56 @@ static void s2io_txpic_intr_handle(nic_t
 		val64 = readq(&bar0->gpio_int_reg);
 		if ((val64 & GPIO_INT_REG_LINK_DOWN) &&
 		    (val64 & GPIO_INT_REG_LINK_UP)) {
+			/*
+			 * This is unstable state so clear both up/down
+			 * interrupt and adapter to re-evaluate the link state.
+			 */
 			val64 |=  GPIO_INT_REG_LINK_DOWN;
 			val64 |= GPIO_INT_REG_LINK_UP;
 			writeq(val64, &bar0->gpio_int_reg);
-			goto masking;
-		}
-
-		if (((sp->last_link_state == LINK_UP) &&
-			(val64 & GPIO_INT_REG_LINK_DOWN)) ||
-		((sp->last_link_state == LINK_DOWN) &&
-		(val64 & GPIO_INT_REG_LINK_UP))) {
 			val64 = readq(&bar0->gpio_int_mask);
-			val64 |=  GPIO_INT_MASK_LINK_DOWN;
-			val64 |= GPIO_INT_MASK_LINK_UP;
+			val64 &= ~(GPIO_INT_MASK_LINK_UP |
+				   GPIO_INT_MASK_LINK_DOWN);
 			writeq(val64, &bar0->gpio_int_mask);
-			s2io_set_link((unsigned long)sp);
 		}
-masking:
-		if (sp->last_link_state == LINK_UP) {
-			/*enable down interrupt */
-			val64 = readq(&bar0->gpio_int_mask);
-			/* unmasks link down intr */
-			val64 &=  ~GPIO_INT_MASK_LINK_DOWN;
-			/* masks link up intr */
-			val64 |= GPIO_INT_MASK_LINK_UP;
-			writeq(val64, &bar0->gpio_int_mask);
-		} else {
-			/*enable UP Interrupt */
-			val64 = readq(&bar0->gpio_int_mask);
-			/* unmasks link up interrupt */
-			val64 &= ~GPIO_INT_MASK_LINK_UP;
-			/* masks link down interrupt */
-			val64 |=  GPIO_INT_MASK_LINK_DOWN;
-			writeq(val64, &bar0->gpio_int_mask);
+		else if (val64 & GPIO_INT_REG_LINK_UP) {
+			val64 = readq(&bar0->adapter_status);
+			if (verify_xena_quiescence(sp, val64,
+						   sp->device_enabled_once)) {
+				/* Enable Adapter */
+				val64 = readq(&bar0->adapter_control);
+				val64 |= ADAPTER_CNTL_EN;
+				writeq(val64, &bar0->adapter_control);
+				val64 |= ADAPTER_LED_ON;
+				writeq(val64, &bar0->adapter_control);
+				if (!sp->device_enabled_once)
+					sp->device_enabled_once = 1;
+
+				s2io_link(sp, LINK_UP);
+				/*
+				 * unmask link down interrupt and mask link-up
+				 * intr
+				 */
+				val64 = readq(&bar0->gpio_int_mask);
+				val64 &= ~GPIO_INT_MASK_LINK_DOWN;
+				val64 |= GPIO_INT_MASK_LINK_UP;
+				writeq(val64, &bar0->gpio_int_mask);
+
+			}
+		}else if (val64 & GPIO_INT_REG_LINK_DOWN) {
+			val64 = readq(&bar0->adapter_status);
+			if (verify_xena_quiescence(sp, val64,
+						   sp->device_enabled_once)) {
+				s2io_link(sp, LINK_DOWN);
+				/* Link is down so unmaks link up interrupt */
+				val64 = readq(&bar0->gpio_int_mask);
+				val64 &= ~GPIO_INT_MASK_LINK_UP;
+				val64 |= GPIO_INT_MASK_LINK_DOWN;
+				writeq(val64, &bar0->gpio_int_mask);
+			}
 		}
 	}
+	val64 = readq(&bar0->gpio_int_mask);
 }
 
 /**
@@ -4080,7 +4042,8 @@ static void s2io_set_multicast(struct ne
 		    RMAC_ADDR_CMD_MEM_OFFSET(MAC_MC_ALL_MC_ADDR_OFFSET);
 		writeq(val64, &bar0->rmac_addr_cmd_mem);
 		/* Wait till command completes */
-		wait_for_cmd_complete(sp);
+		wait_for_cmd_complete(&bar0->rmac_addr_cmd_mem,
+				      RMAC_ADDR_CMD_MEM_STROBE_CMD_EXECUTING);
 
 		sp->m_cast_flg = 1;
 		sp->all_multi_pos = MAC_MC_ALL_MC_ADDR_OFFSET;
@@ -4095,7 +4058,8 @@ static void s2io_set_multicast(struct ne
 		    RMAC_ADDR_CMD_MEM_OFFSET(sp->all_multi_pos);
 		writeq(val64, &bar0->rmac_addr_cmd_mem);
 		/* Wait till command completes */
-		wait_for_cmd_complete(sp);
+		wait_for_cmd_complete(&bar0->rmac_addr_cmd_mem,
+				      RMAC_ADDR_CMD_MEM_STROBE_CMD_EXECUTING);
 
 		sp->m_cast_flg = 0;
 		sp->all_multi_pos = 0;
@@ -4160,7 +4124,8 @@ static void s2io_set_multicast(struct ne
 			writeq(val64, &bar0->rmac_addr_cmd_mem);
 
 			/* Wait for command completes */
-			if (wait_for_cmd_complete(sp)) {
+			if (wait_for_cmd_complete(&bar0->rmac_addr_cmd_mem,
+				      RMAC_ADDR_CMD_MEM_STROBE_CMD_EXECUTING)) {
 				DBG_PRINT(ERR_DBG, "%s: Adding ",
 					  dev->name);
 				DBG_PRINT(ERR_DBG, "Multicasts failed\n");
@@ -4190,7 +4155,8 @@ static void s2io_set_multicast(struct ne
 			writeq(val64, &bar0->rmac_addr_cmd_mem);
 
 			/* Wait for command completes */
-			if (wait_for_cmd_complete(sp)) {
+			if (wait_for_cmd_complete(&bar0->rmac_addr_cmd_mem,
+				      RMAC_ADDR_CMD_MEM_STROBE_CMD_EXECUTING)) {
 				DBG_PRINT(ERR_DBG, "%s: Adding ",
 					  dev->name);
 				DBG_PRINT(ERR_DBG, "Multicasts failed\n");
@@ -4235,7 +4201,8 @@ static int s2io_set_mac_addr(struct net_
 	    RMAC_ADDR_CMD_MEM_OFFSET(0);
 	writeq(val64, &bar0->rmac_addr_cmd_mem);
 	/* Wait till command completes */
-	if (wait_for_cmd_complete(sp)) {
+	if (wait_for_cmd_complete(&bar0->rmac_addr_cmd_mem,
+		      RMAC_ADDR_CMD_MEM_STROBE_CMD_EXECUTING)) {
 		DBG_PRINT(ERR_DBG, "%s: set_mac_addr failed\n", dev->name);
 		return FAILURE;
 	}
@@ -4632,7 +4599,6 @@ static int write_eeprom(nic_t * sp, int 
 	}
 	return ret;
 }
-
 static void s2io_vpd_read(nic_t *nic)
 {
 	u8 vpd_data[256],data;
@@ -4983,8 +4949,10 @@ static int s2io_link_test(nic_t * sp, ui
 	u64 val64;
 
 	val64 = readq(&bar0->adapter_status);
-	if (val64 & ADAPTER_STATUS_RMAC_LOCAL_FAULT)
+	if(!(LINK_IS_UP(val64)))
 		*data = 1;
+	else
+		*data = 0;
 
 	return 0;
 }
@@ -5403,7 +5371,7 @@ static int s2io_change_mtu(struct net_de
 
 	dev->mtu = new_mtu;
 	if (netif_running(dev)) {
-		s2io_card_down(sp);
+		s2io_card_down(sp, 0);
 		netif_stop_queue(dev);
 		if (s2io_card_up(sp)) {
 			DBG_PRINT(ERR_DBG, "%s: Device bring up failed\n",
@@ -5541,12 +5509,13 @@ static void s2io_set_link(unsigned long 
 	clear_bit(0, &(nic->link_state));
 }
 
-static void s2io_card_down(nic_t * sp)
+static void s2io_card_down(nic_t * sp, int flag)
 {
 	int cnt = 0;
 	XENA_dev_config_t __iomem *bar0 = sp->bar0;
 	unsigned long flags;
 	register u64 val64 = 0;
+	struct net_device *dev = sp->dev;
 
 	del_timer_sync(&sp->alarm_timer);
 	/* If s2io_set_link task is executing, wait till it completes. */
@@ -5557,6 +5526,36 @@ static void s2io_card_down(nic_t * sp)
 
 	/* disable Tx and Rx traffic on the NIC */
 	stop_nic(sp);
+	if (flag) {
+		if (sp->intr_type == MSI_X) {
+			int i;
+			u16 msi_control;
+
+			for (i=1; (sp->s2io_entries[i].in_use ==
+				MSIX_REGISTERED_SUCCESS); i++) {
+				int vector = sp->entries[i].vector;
+				void *arg = sp->s2io_entries[i].arg;
+
+				free_irq(vector, arg);
+			}
+			pci_read_config_word(sp->pdev, 0x42, &msi_control);
+			msi_control &= 0xFFFE; /* Disable MSI */
+			pci_write_config_word(sp->pdev, 0x42, msi_control);
+			pci_disable_msix(sp->pdev);
+		} else {
+			free_irq(sp->pdev->irq, dev);
+			if (sp->intr_type == MSI)
+				pci_disable_msi(sp->pdev);
+		}
+	}
+	/* Waiting till all Interrupt handlers are complete */
+	cnt = 0;
+	do {
+		msleep(10);
+		if (!atomic_read(&sp->isr_cnt))
+			break;
+		cnt++;
+	} while(cnt < 5);
 
 	/* Kill tasklet. */
 	tasklet_kill(&sp->task);
@@ -5580,15 +5579,6 @@ static void s2io_card_down(nic_t * sp)
 	} while (1);
 	s2io_reset(sp);
 
-	/* Waiting till all Interrupt handlers are complete */
-	cnt = 0;
-	do {
-		msleep(10);
-		if (!atomic_read(&sp->isr_cnt))
-			break;
-		cnt++;
-	} while(cnt < 5);
-
 	spin_lock_irqsave(&sp->tx_lock, flags);
 	/* Free all Tx buffers */
 	free_tx_buffers(sp);
@@ -5689,7 +5679,7 @@ static void s2io_restart_nic(unsigned lo
 	struct net_device *dev = (struct net_device *) data;
 	nic_t *sp = dev->priv;
 
-	s2io_card_down(sp);
+	s2io_card_down(sp, 0);
 	if (s2io_card_up(sp)) {
 		DBG_PRINT(ERR_DBG, "%s: Device bring up failed\n",
 			  dev->name);
@@ -5751,6 +5741,7 @@ static int rx_osm_handler(ring_info_t *r
 	lro_t *lro;
 
 	skb->dev = dev;
+
 	if (err) {
 		/*
 		* Drop the packet if bad transfer code. Exception being
@@ -5853,6 +5844,9 @@ static int rx_osm_handler(ring_info_t *r
 						clear_lro_session(lro);
 						goto send_up;
 					case 0: /* sessions exceeded */
+					case -1: /* non-TCP or not
+						  * L2 aggregatable
+						  */
 					case 5: /*
 						 * First pkt in session not
 						 * L3/L4 aggregatable
@@ -6351,8 +6345,8 @@ s2io_init_nic(struct pci_dev *pdev, cons
 	val64 = RMAC_ADDR_CMD_MEM_RD | RMAC_ADDR_CMD_MEM_STROBE_NEW_CMD |
 	    RMAC_ADDR_CMD_MEM_OFFSET(0 + MAC_MAC_ADDR_START_OFFSET);
 	writeq(val64, &bar0->rmac_addr_cmd_mem);
-	wait_for_cmd_complete(sp);
-
+	wait_for_cmd_complete(&bar0->rmac_addr_cmd_mem,
+		      RMAC_ADDR_CMD_MEM_STROBE_CMD_EXECUTING);
 	tmp64 = readq(&bar0->rmac_addr_data0_mem);
 	mac_down = (u32) tmp64;
 	mac_up = (u32) (tmp64 >> 32);
diff -upNr dmesg_param_fixes/drivers/net/s2io.h bug_fixes1/drivers/net/s2io.h
--- dmesg_param_fixes/drivers/net/s2io.h	2006-04-13 09:08:26.000000000 -0700
+++ bug_fixes1/drivers/net/s2io.h	2006-04-19 08:21:12.000000000 -0700
@@ -661,8 +661,8 @@ typedef struct {
 /* Default Tunable parameters of the NIC. */
 #define DEFAULT_FIFO_0_LEN 4096
 #define DEFAULT_FIFO_1_7_LEN 512
-#define SMALL_BLK_CNT   30
-#define LARGE_BLK_CNT   100
+#define SMALL_BLK_CNT	30
+#define LARGE_BLK_CNT	100
 
 /*
  * Structure to keep track of the MSI-X vectors and the corresponding
@@ -733,7 +733,7 @@ struct s2io_nic {
 	int device_close_flag;
 	int device_enabled_once;
 
-	char name[50];
+	char name[60];
 	struct tasklet_struct task;
 	volatile unsigned long tasklet_status;
 
@@ -804,6 +804,8 @@ struct s2io_nic {
 	char desc1[35];
 	char desc2[35];
 
+	int avail_msix_vectors; /* No. of MSI-X vectors granted by system */
+
 	struct msix_info_st msix_info[0x3f];
 
 #define XFRAME_I_DEVICE		1
@@ -851,28 +853,32 @@ static inline void writeq(u64 val, void 
 	writel((u32) (val), addr);
 	writel((u32) (val >> 32), (addr + 4));
 }
+#endif
 
-/* In 32 bit modes, some registers have to be written in a
- * particular order to expect correct hardware operation. The
- * macro SPECIAL_REG_WRITE is used to perform such ordered
- * writes. Defines UF (Upper First) and LF (Lower First) will
- * be used to specify the required write order.
+/* 
+ * Some registers have to be written in a particular order to 
+ * expect correct hardware operation. The macro SPECIAL_REG_WRITE 
+ * is used to perform such ordered writes. Defines UF (Upper First) 
+ * and LF (Lower First) will be used to specify the required write order.
  */
 #define UF	1
 #define LF	2
 static inline void SPECIAL_REG_WRITE(u64 val, void __iomem *addr, int order)
 {
+	u32 ret;
+
 	if (order == LF) {
 		writel((u32) (val), addr);
+		ret = readl(addr);
 		writel((u32) (val >> 32), (addr + 4));
+		ret = readl(addr + 4);
 	} else {
 		writel((u32) (val >> 32), (addr + 4));
+		ret = readl(addr + 4);
 		writel((u32) (val), addr);
+		ret = readl(addr);
 	}
 }
-#else
-#define SPECIAL_REG_WRITE(val, addr, dummy) writeq(val, addr)
-#endif
 
 /*  Interrupt related values of Xena */
 
@@ -968,7 +974,7 @@ static int verify_xena_quiescence(nic_t 
 static struct ethtool_ops netdev_ethtool_ops;
 static void s2io_set_link(unsigned long data);
 static int s2io_set_swapper(nic_t * sp);
-static void s2io_card_down(nic_t *nic);
+static void s2io_card_down(nic_t *nic, int flag);
 static int s2io_card_up(nic_t *nic);
 static int get_xena_rev_id(struct pci_dev *pdev);
 static void restore_xmsi_data(nic_t *nic);

