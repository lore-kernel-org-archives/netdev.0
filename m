From: raghavendra.koushik@neterion.com
Subject: [PATCH 2.6.12.1 11/12] S2io: New link handling scheme for Xframe II
Date: Thu,  7 Jul 2005 15:40:05 -0700 (PDT)
Message-ID: <20050707224005.2DD9589826@linux.site>
Cc: raghavendra.koushik@neterion.com, ravinandan.arakali@neterion.com,
        leonid.grossman@neterion.com, rapuru.sriram@neterion.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com, netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,
The below patch implements a new "Link state change handling"
scheme supported by the Xframe II adapter. It also bumps up the
driver version to 2.0.2.0.

Signed-off-by: Ravinandan Arakali <ravinandan.arakali@neterion.com>
Signed-off-by: Raghavendra Koushik <raghavendra.koushik@neterion.com>
---
diff -uprN vanilla_kernel/drivers/net/s2io-regs.h linux-2.6.12-rc6/drivers/net/s2io-regs.h
--- vanilla_kernel/drivers/net/s2io-regs.h	2005-06-28 06:00:05.000000000 -0700
+++ linux-2.6.12-rc6/drivers/net/s2io-regs.h	2005-06-28 06:00:14.000000000 -0700
@@ -167,7 +167,11 @@ typedef struct _XENA_dev_config {
 	u8 unused4[0x08];
 
 	u64 gpio_int_reg;
+#define GPIO_INT_REG_LINK_DOWN                 BIT(1)
+#define GPIO_INT_REG_LINK_UP                   BIT(2)
 	u64 gpio_int_mask;
+#define GPIO_INT_MASK_LINK_DOWN                BIT(1)
+#define GPIO_INT_MASK_LINK_UP                  BIT(2)
 	u64 gpio_alarms;
 
 	u8 unused5[0x38];
@@ -279,8 +283,10 @@ typedef struct _XENA_dev_config {
 
 	u64 gpio_control;
 #define GPIO_CTRL_GPIO_0		BIT(8)
+	u64 misc_control;
+#define MISC_LINK_STABILITY_PRD(val)   vBIT(val,29,3)
 
-	u8 unused7_1[0x240 - 0x200];
+	u8 unused7_1[0x240 - 0x208];
 
 	u64 wreq_split_mask;
 #define	WREQ_SPLIT_MASK_SET_MASK(val)	vBIT(val, 52, 12)
diff -uprN vanilla_kernel/drivers/net/s2io.c linux-2.6.12-rc6/drivers/net/s2io.c
--- vanilla_kernel/drivers/net/s2io.c	2005-06-28 06:00:05.000000000 -0700
+++ linux-2.6.12-rc6/drivers/net/s2io.c	2005-06-28 06:00:14.000000000 -0700
@@ -66,7 +66,7 @@
 
 /* S2io Driver name & version. */
 static char s2io_driver_name[] = "Neterion";
-static char s2io_driver_version[] = "Version 1.7.7";
+static char s2io_driver_version[] = "Version 2.0.2.0";
 
 static inline int RXD_IS_UP2DT(RxD_t *rxdp)
 {
@@ -1455,8 +1455,28 @@ static int init_nic(struct s2io_nic *nic
 		writeq(val64, &bar0->wreq_split_mask);
 	}
 
+	/* Setting Link stability period to 64 ms */ 
+	if (nic->device_type == XFRAME_II_DEVICE) {
+		val64 = MISC_LINK_STABILITY_PRD(3);
+		writeq(val64, &bar0->misc_control);
+	}
+
 	return SUCCESS;
 }
+#define LINK_UP_DOWN_INTERRUPT		1
+#define MAC_RMAC_ERR_TIMER		2
+
+#if defined(CONFIG_MSI_MODE) || defined(CONFIG_MSIX_MODE)
+#define s2io_link_fault_indication(x) MAC_RMAC_ERR_TIMER
+#else
+int s2io_link_fault_indication(nic_t *nic)
+{
+	if (nic->device_type == XFRAME_II_DEVICE)
+		return LINK_UP_DOWN_INTERRUPT;
+	else
+		return MAC_RMAC_ERR_TIMER;
+}
+#endif
 
 /**
  *  en_dis_able_nic_intrs - Enable or Disable the interrupts
@@ -1484,11 +1504,22 @@ static void en_dis_able_nic_intrs(struct
 			temp64 &= ~((u64) val64);
 			writeq(temp64, &bar0->general_int_mask);
 			/*
-			 * Disabled all PCIX, Flash, MDIO, IIC and GPIO
+			 * If Hercules adapter enable GPIO otherwise
+			 * disabled all PCIX, Flash, MDIO, IIC and GPIO
 			 * interrupts for now.
 			 * TODO
 			 */
-			writeq(DISABLE_ALL_INTRS, &bar0->pic_int_mask);
+			if (s2io_link_fault_indication(nic) ==
+					LINK_UP_DOWN_INTERRUPT ) {
+				temp64 = readq(&bar0->pic_int_mask);
+				temp64 &= ~((u64) PIC_INT_GPIO);
+				writeq(temp64, &bar0->pic_int_mask);
+				temp64 = readq(&bar0->gpio_int_mask);
+				temp64 &= ~((u64) GPIO_INT_MASK_LINK_UP);
+				writeq(temp64, &bar0->gpio_int_mask);
+			} else {
+				writeq(DISABLE_ALL_INTRS, &bar0->pic_int_mask);
+			}
 			/*
 			 * No MSI Support is available presently, so TTI and
 			 * RTI interrupts are also disabled.
@@ -1579,17 +1610,8 @@ static void en_dis_able_nic_intrs(struct
 			writeq(temp64, &bar0->general_int_mask);
 			/*
 			 * All MAC block error interrupts are disabled for now
-			 * except the link status change interrupt.
 			 * TODO
 			 */
-			val64 = MAC_INT_STATUS_RMAC_INT;
-			temp64 = readq(&bar0->mac_int_mask);
-			temp64 &= ~((u64) val64);
-			writeq(temp64, &bar0->mac_int_mask);
-
-			val64 = readq(&bar0->mac_rmac_err_mask);
-			val64 &= ~((u64) RMAC_LINK_STATE_CHANGE_INT);
-			writeq(val64, &bar0->mac_rmac_err_mask);
 		} else if (flag == DISABLE_INTRS) {
 			/*
 			 * Disable MAC Intrs in the general intr mask register
@@ -1878,8 +1900,10 @@ static int start_nic(struct s2io_nic *ni
 	}
 
 	/*  Enable select interrupts */
-	interruptible = TX_TRAFFIC_INTR | RX_TRAFFIC_INTR | TX_MAC_INTR |
-	    RX_MAC_INTR | MC_INTR;
+	interruptible = TX_TRAFFIC_INTR | RX_TRAFFIC_INTR | MC_INTR;
+	interruptible |= TX_PIC_INTR | RX_PIC_INTR;
+	interruptible |= TX_MAC_INTR | RX_MAC_INTR;
+
 	en_dis_able_nic_intrs(nic, interruptible, ENABLE_INTRS);
 
 	/*
@@ -2003,8 +2027,9 @@ static void stop_nic(struct s2io_nic *ni
 	config = &nic->config;
 
 	/*  Disable all interrupts */
-	interruptible = TX_TRAFFIC_INTR | RX_TRAFFIC_INTR | TX_MAC_INTR |
-	    RX_MAC_INTR | MC_INTR;
+	interruptible = TX_TRAFFIC_INTR | RX_TRAFFIC_INTR | MC_INTR;
+	interruptible |= TX_PIC_INTR | RX_PIC_INTR;
+	interruptible |= TX_MAC_INTR | RX_MAC_INTR;
 	en_dis_able_nic_intrs(nic, interruptible, DISABLE_INTRS);
 
 	/*  Disable PRCs */
@@ -2619,10 +2644,12 @@ static void alarm_intr_handler(struct s2
 	register u64 val64 = 0, err_reg = 0;
 
 	/* Handling link status change error Intr */
-	err_reg = readq(&bar0->mac_rmac_err_reg);
-	writeq(err_reg, &bar0->mac_rmac_err_reg);
-	if (err_reg & RMAC_LINK_STATE_CHANGE_INT) {
-		schedule_work(&nic->set_link_task);
+	if (s2io_link_fault_indication(nic) == MAC_RMAC_ERR_TIMER) {
+		err_reg = readq(&bar0->mac_rmac_err_reg);
+		writeq(err_reg, &bar0->mac_rmac_err_reg);
+		if (err_reg & RMAC_LINK_STATE_CHANGE_INT) {
+			schedule_work(&nic->set_link_task);
+		}
 	}
 
 	/* Handling Ecc errors */
@@ -2948,7 +2975,7 @@ int s2io_open(struct net_device *dev)
 	 * Nic is initialized
 	 */
 	netif_carrier_off(dev);
-	sp->last_link_state = 0; /* Unkown link state */
+	sp->last_link_state = LINK_DOWN;
 
 	/* Initialize H/W and enable interrupts */
 	if (s2io_card_up(sp)) {
@@ -3160,6 +3187,53 @@ s2io_alarm_handle(unsigned long data)
 	mod_timer(&sp->alarm_timer, jiffies + HZ / 2);
 }
 
+static void s2io_txpic_intr_handle(nic_t *sp)
+{
+	XENA_dev_config_t *bar0 = (XENA_dev_config_t *) sp->bar0;
+	u64 val64;
+
+	val64 = readq(&bar0->pic_int_status);
+	if (val64 & PIC_INT_GPIO) {
+		val64 = readq(&bar0->gpio_int_reg);
+		if ((val64 & GPIO_INT_REG_LINK_DOWN) &&
+		    (val64 & GPIO_INT_REG_LINK_UP)) {
+			val64 |=  GPIO_INT_REG_LINK_DOWN;
+			val64 |= GPIO_INT_REG_LINK_UP;
+			writeq(val64, &bar0->gpio_int_reg);
+			goto masking;
+		}
+
+		if (((sp->last_link_state == LINK_UP) &&
+			(val64 & GPIO_INT_REG_LINK_DOWN)) ||
+		((sp->last_link_state == LINK_DOWN) &&
+		(val64 & GPIO_INT_REG_LINK_UP))) {
+			val64 = readq(&bar0->gpio_int_mask);
+			val64 |=  GPIO_INT_MASK_LINK_DOWN;
+			val64 |= GPIO_INT_MASK_LINK_UP;
+			writeq(val64, &bar0->gpio_int_mask);
+			s2io_set_link((unsigned long)sp);
+		}
+masking:
+		if (sp->last_link_state == LINK_UP) {
+			/*enable down interrupt */
+			val64 = readq(&bar0->gpio_int_mask);
+			/* unmasks link down intr */
+			val64 &=  ~GPIO_INT_MASK_LINK_DOWN;
+			/* masks link up intr */
+			val64 |= GPIO_INT_MASK_LINK_UP;
+			writeq(val64, &bar0->gpio_int_mask);
+		} else {
+			/*enable UP Interrupt */
+			val64 = readq(&bar0->gpio_int_mask);
+			/* unmasks link up interrupt */
+			val64 &= ~GPIO_INT_MASK_LINK_UP;
+			/* masks link down interrupt */
+			val64 |=  GPIO_INT_MASK_LINK_DOWN;
+			writeq(val64, &bar0->gpio_int_mask);
+		}
+	}
+}
+
 /**
  *  s2io_isr - ISR handler of the device .
  *  @irq: the irq of the device.
@@ -3242,6 +3316,8 @@ static irqreturn_t s2io_isr(int irq, voi
 			tx_intr_handler(&mac_control->fifos[i]);
 	}
 
+	if (reason & GEN_INTR_TXPIC)
+		s2io_txpic_intr_handle(sp);
 	/*
 	 * If the Rx buffer count is below the panic threshold then
 	 * reallocate the buffers from the interrupt handler itself,
@@ -4645,11 +4721,13 @@ static void s2io_set_link(unsigned long 
 	}
 
 	subid = nic->pdev->subsystem_device;
-	/*
-	 * Allow a small delay for the NICs self initiated
-	 * cleanup to complete.
-	 */
-	msleep(100);
+	if (s2io_link_fault_indication(nic) == MAC_RMAC_ERR_TIMER) {
+		/*
+		 * Allow a small delay for the NICs self initiated
+		 * cleanup to complete.
+		 */
+		msleep(100);
+	}
 
 	val64 = readq(&bar0->adapter_status);
 	if (verify_xena_quiescence(nic, val64, nic->device_enabled_once)) {
@@ -4667,13 +4745,16 @@ static void s2io_set_link(unsigned long 
 				val64 |= ADAPTER_LED_ON;
 				writeq(val64, &bar0->adapter_control);
 			}
-			val64 = readq(&bar0->adapter_status);
-			if (!LINK_IS_UP(val64)) {
-				DBG_PRINT(ERR_DBG, "%s:", dev->name);
-				DBG_PRINT(ERR_DBG, " Link down");
-				DBG_PRINT(ERR_DBG, "after ");
-				DBG_PRINT(ERR_DBG, "enabling ");
-				DBG_PRINT(ERR_DBG, "device \n");
+			if (s2io_link_fault_indication(nic) ==
+						MAC_RMAC_ERR_TIMER) {
+				val64 = readq(&bar0->adapter_status);
+				if (!LINK_IS_UP(val64)) {
+					DBG_PRINT(ERR_DBG, "%s:", dev->name);
+					DBG_PRINT(ERR_DBG, " Link down");
+					DBG_PRINT(ERR_DBG, "after ");
+					DBG_PRINT(ERR_DBG, "enabling ");
+					DBG_PRINT(ERR_DBG, "device \n");
+				}
 			}
 			if (nic->device_enabled_once == FALSE) {
 				nic->device_enabled_once = TRUE;
