From: koushik <raghavendra.koushik@s2io.com>
Subject: [PATCH 2.6.9-rc2 2/12] S2io: sw bug fixes
Date: Fri, 5 Nov 2004 05:05:41 -0800
Message-ID: <200411050505.41343.raghavendra.koushik@s2io.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: leonid.grossman@s2io.com, ravinandan.arakali@s2io.com,
        raghavendra.koushik@s2io.com, rapuru.sriram@s2io.com,
        alicia.pena@s2io.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com, romieu@fr.zoreil.com, netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,
Attached is the second patch in this submission. It contains the following
software bug fixes.

1. In free_rx_buffers clearing out RxDs not owned by Xena.

2. In alarm_intr_handler, when a serr error occurs, schedule a task to reset the card rather than stopping Tx queue.

3. In s2io_close freeing IRQ before calling s2io_reset also added a new call to flush queued tasks. This is not done if the
s2io_close itself is called from a queued task like s2io_restart_nic.

4. read_eeprom function has been changed such that data to be returned is sent as an input argument and the return value represents
a pass/fail. The previous implementation as Randy had pointed out was error prone as on failure it returned -1 which can be
interpreted as all ff's, so any data area which contained ff's in the eeprom was likely to be treated as an error.

5. Added a flag "task_flag" to track if the call to s2io_close is coming from the s2io_restart_nic function or from the ifconfig
<I/F> down called by user.

6. Moved register_netdev call from just after setting entry points to the end of the s2io_init_nic function.

7. In s2io.h field added a new member into the s2io_nic structure called "task_flag".


Signed-off-by: Raghavendra Koushik <raghavendra.koushik@s2io.com>
Signed-off-by: Ravinandan Arakali <ravinandan.arakali@s2io.com>
---
diff -urN vanilla-linux/drivers/net/s2io.c linux-2.6.8.1/drivers/net/s2io.c
--- vanilla-linux/drivers/net/s2io.c	2004-10-06 15:18:10.000000000 -0700
+++ linux-2.6.8.1/drivers/net/s2io.c	2004-10-06 16:19:52.821420504 -0700
@@ -1525,6 +1525,11 @@
 				blk++;
 			}
 
+			if (!(rxdp->Control_1 & RXD_OWN_XENA)) {
+				memset(rxdp, 0, sizeof(RxD_t));
+				continue;
+			}
+
 			skb =
 			    (struct sk_buff *) ((unsigned long) rxdp->
 						Host_Control);
@@ -1887,7 +1892,7 @@
 	if (val64 & SERR_SOURCE_ANY) {
 		DBG_PRINT(ERR_DBG, "%s: Device indicates ", dev->name);
 		DBG_PRINT(ERR_DBG, "serious error!!\n");
-		netif_stop_queue(dev);
+		schedule_work(&nic->rst_timer_task);
 	}
 
 	/* Other type of interrupts are not being handled now,  TODO */
@@ -2205,6 +2210,17 @@
 	}
 	tasklet_kill(&sp->task);
 
+	/*  Free the Registered IRQ */
+	free_irq(dev->irq, dev);
+
+	/* Flush all scheduled tasks */
+	if (sp->task_flag == 1) {
+		DBG_PRINT(INFO_DBG, "%s: Calling close from a task\n",
+			  dev->name);
+	} else {
+		flush_scheduled_work();
+	}
+
 	/* Check if the device is Quiescent and then Reset the NIC */
 	do {
 		val64 = readq(&bar0->adapter_status);
@@ -2225,9 +2241,6 @@
 	} while (1);
 	s2io_reset(sp);
 
-	/*  Free the Registered IRQ */
-	free_irq(dev->irq, dev);
-
 	/* Free all Tx Buffers waiting for transmission */
 	free_tx_buffers(sp);
 
@@ -2982,9 +2995,10 @@
  */
 
 #define S2IO_DEV_ID		5
-static u32 read_eeprom(nic_t * sp, int off)
+static int read_eeprom(nic_t * sp, int off, u32 * data)
 {
-	u32 data = -1, exit_cnt = 0;
+	int ret = -1;
+	u32 exit_cnt = 0;
 	u64 val64;
 	XENA_dev_config_t *bar0 = (XENA_dev_config_t *) sp->bar0;
 
@@ -2996,7 +3010,8 @@
 	while (exit_cnt < 5) {
 		val64 = readq(&bar0->i2c_control);
 		if (I2C_CONTROL_CNTL_END(val64)) {
-			data = I2C_CONTROL_GET_DATA(val64);
+			*data = I2C_CONTROL_GET_DATA(val64);
+			ret = 0;
 			break;
 		}
 		set_current_state(TASK_UNINTERRUPTIBLE);
@@ -3004,7 +3019,7 @@
 		exit_cnt++;
 	}
 
-	return data;
+	return ret;
 }
 
 /**
@@ -3073,8 +3088,7 @@
 		eeprom->len = XENA_EEPROM_SPACE - eeprom->offset;
 
 	for (i = 0; i < eeprom->len; i += 4) {
-		data = read_eeprom(sp, eeprom->offset + i);
-		if (data < 0) {
+		if (read_eeprom(sp, (eeprom->offset + i), &data)) {
 			DBG_PRINT(ERR_DBG, "Read of EEPROM failed\n");
 			return -EFAULT;
 		}
@@ -3213,7 +3227,8 @@
 
 static int s2io_eeprom_test(nic_t * sp, uint64_t * data)
 {
-	int fail = 0, ret_data;
+	int fail = 0;
+	u32 ret_data;
 
 	/* Test Write Error at offset 0 */
 	if (!write_eeprom(sp, 0, 0, 3))
@@ -3222,7 +3237,7 @@
 	/* Test Write at offset 4f0 */
 	if (write_eeprom(sp, 0x4F0, 0x01234567, 3))
 		fail = 1;
-	if ((ret_data = read_eeprom(sp, 0x4F0)) < 0)
+	if (read_eeprom(sp, 0x4F0, &ret_data))
 		fail = 1;
 
 	if (ret_data != 0x01234567)
@@ -3238,7 +3253,7 @@
 	/* Test Write Request at offset 0x7fc */
 	if (write_eeprom(sp, 0x7FC, 0x01234567, 3))
 		fail = 1;
-	if ((ret_data = read_eeprom(sp, 0x7FC)) < 0)
+	if (read_eeprom(sp, 0x7FC, &ret_data))
 		fail = 1;
 
 	if (ret_data != 0x01234567)
@@ -3811,7 +3826,9 @@
 	struct net_device *dev = (struct net_device *) data;
 	nic_t *sp = dev->priv;
 
+	sp->task_flag = 1;
 	s2io_close(dev);
+	sp->task_flag = 0;
 	sp->device_close_flag = TRUE;
 	s2io_open(dev);
 	DBG_PRINT(ERR_DBG,
@@ -4275,18 +4292,13 @@
 	INIT_WORK(&sp->set_link_task,
 		  (void (*)(void *)) s2io_set_link, sp);
 
-	if (register_netdev(dev)) {
-		DBG_PRINT(ERR_DBG, "Device registration failed\n");
-		goto register_failed;
-	}
-
 	pci_save_state(sp->pdev, sp->config_space);
 
 	/* Setting swapper control on the NIC, for proper reset operation */
 	if (s2io_set_swapper(sp)) {
 		DBG_PRINT(ERR_DBG, "%s:swapper settings are wrong\n",
 			  dev->name);
-		goto register_failed;
+		goto set_swap_failed;
 	}
 
 	/* Fix for all "FFs" MAC address problems observed on Alpha platforms */
@@ -4363,6 +4375,11 @@
 
 	sp->rx_csum = 1;	/* Rx chksum verify enabled by default */
 
+	if (register_netdev(dev)) {
+		DBG_PRINT(ERR_DBG, "Device registration failed\n");
+		goto register_failed;
+	}
+
 	/* 
 	 * Make Link state as off at this point, when the Link change 
 	 * interrupt comes the state will be automatically changed to 
@@ -4373,9 +4390,8 @@
 
 	return 0;
 
-      set_swap_failed:
-	unregister_netdev(dev);
       register_failed:
+      set_swap_failed:
 	iounmap(sp->bar1);
       bar1_remap_failed:
 	iounmap(sp->bar0);
diff -urN vanilla-linux/drivers/net/s2io.h linux-2.6.8.1/drivers/net/s2io.h
--- vanilla-linux/drivers/net/s2io.h	2004-10-06 15:15:03.000000000 -0700
+++ linux-2.6.8.1/drivers/net/s2io.h	2004-10-06 16:19:52.829419288 -0700
@@ -668,6 +668,8 @@
 	u16 last_link_state;
 #define	LINK_DOWN	1
 #define	LINK_UP		2
+
+	int task_flag;
 } nic_t;
 
 #define RESET_ERROR 1;


-------------------------------------------------------
