From: "Ravinandan Arakali" <ravinandan.arakali@s2io.com>
Subject: [PATCH 2.6.9-rc2 9/12] S2io: new functions for card restart
Date: Thu, 28 Oct 2004 11:34:34 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <001501c4bd1c$dd4dbd90$9810100a@S2IOtech.com>
Reply-To: <ravinandan.arakali@s2io.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <netdev@oss.sgi.com>, <leonid.grossman@s2io.com>,
        <raghavendra.koushik@s2io.com>, <rapuru.sriram@s2io.com>,
        <alicia.pena@s2io.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "'Jeff Garzik'" <jgarzik@pobox.com>,
        "'Francois Romieu'" <romieu@fr.zoreil.com>
In-reply-to: 
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,
The attached patch incorporates Jeff's comments related to creating separate functions for
restarting the NIC(without using close and open entry points) and few other comments. Complete list of changes are as follows:

1. Two new functions s2io_card_down() and s2io_card_up() are defined and are called during reset procedure instead of close and open
routines.
2. tasklet_status field is now made as unsigned long.
3. On getting serious error, queue is stopped before resetting the card.
4. Removed the check for "queue stopped" in xmit routine.

Signed-off-by: Raghavendra Koushik <raghavendra.koushik@s2io.com>
---
diff -urN vanilla-linux/drivers/net/s2io.c linux-2.6.8.1/drivers/net/s2io.c
--- vanilla-linux/drivers/net/s2io.c	2004-10-26 16:36:28.024066008 -0700
+++ linux-2.6.8.1/drivers/net/s2io.c	2004-10-26 16:36:16.682790144 -0700
@@ -82,8 +82,7 @@

 #define LINK_IS_UP(val64) (!(val64 & (ADAPTER_STATUS_RMAC_REMOTE_FAULT | \
 				      ADAPTER_STATUS_RMAC_LOCAL_FAULT)))
-#define TASKLET_IN_USE test_and_set_bit(0, \
-				(unsigned long *)(&sp->tasklet_status))
+#define TASKLET_IN_USE test_and_set_bit(0, (&sp->tasklet_status))
 #define PANIC	1
 #define LOW	2
 static inline int rx_buffer_level(nic_t * sp, int rxb_size, int ring)
@@ -2447,6 +2446,7 @@
 	if (val64 & SERR_SOURCE_ANY) {
 		DBG_PRINT(ERR_DBG, "%s: Device indicates ", dev->name);
 		DBG_PRINT(ERR_DBG, "serious error!!\n");
+		netif_stop_queue(dev);
 		schedule_work(&nic->rst_timer_task);
 	}

@@ -2648,7 +2648,7 @@
  * ********************************************************* */

 /**
- *  s2io-open - open entry point of the driver
+ *  s2io_open - open entry point of the driver
  *  @dev : pointer to the device structure.
  *  Description:
  *  This function is the open entry point of the driver. It mainly calls a
@@ -2662,10 +2662,7 @@
 int s2io_open(struct net_device *dev)
 {
 	nic_t *sp = dev->priv;
-	int i, ret = 0, err = 0;
-	mac_info_t *mac_control;
-	struct config_param *config;
-
+	int err = 0;

 	/*
 	 * Make sure you have link off by default every time
@@ -2674,68 +2671,30 @@
 	netif_carrier_off(dev);
 	sp->last_link_state = LINK_DOWN;

-	/* Initialize the H/W I/O registers */
-	if (init_nic(sp) != 0) {
+	/* Initialize H/W and enable interrupts */
+	if (s2io_card_up(sp)) {
 		DBG_PRINT(ERR_DBG, "%s: H/W initialization failed\n",
 			  dev->name);
 		return -ENODEV;
 	}

 	/* After proper initialization of H/W, register ISR */
-	err =
-	    request_irq((int) sp->irq, s2io_isr, SA_SHIRQ, sp->name, dev);
+	err = request_irq((int) sp->irq, s2io_isr, SA_SHIRQ,
+			  sp->name, dev);
 	if (err) {
 		s2io_reset(sp);
 		DBG_PRINT(ERR_DBG, "%s: ISR registration failed\n",
 			  dev->name);
 		return err;
 	}
+
 	if (s2io_set_mac_addr(dev, dev->dev_addr) == FAILURE) {
 		DBG_PRINT(ERR_DBG, "Set Mac Address Failed\n");
 		s2io_reset(sp);
 		return -ENODEV;
 	}

-
-	/* Setting its receive mode */
-	s2io_set_multicast(dev);
-
-	/*
-	 * Initializing the Rx buffers. For now we are considering only 1
-	 * Rx ring and initializing buffers into 1016 RxDs or 8 Rx blocks
-	 */
-	mac_control = &sp->mac_control;
-	config = &sp->config;
-
-	for (i = 0; i < config->rx_ring_num; i++) {
-		if ((ret = fill_rx_buffers(sp, i))) {
-			DBG_PRINT(ERR_DBG, "%s: Out of memory in Open\n",
-				  dev->name);
-			s2io_reset(sp);
-			free_irq(dev->irq, dev);
-			free_rx_buffers(sp);
-			return -ENOMEM;
-		}
-		DBG_PRINT(INFO_DBG, "Buf in ring:%d is %d:\n", i,
-			  atomic_read(&sp->rx_bufs_left[i]));
-	}
-
-	/* Enable tasklet for the device */
-	tasklet_init(&sp->task, s2io_tasklet, (unsigned long) dev);
-
-	/* Enable Rx Traffic and interrupts on the NIC */
-	if (start_nic(sp)) {
-		DBG_PRINT(ERR_DBG, "%s: Starting NIC failed\n", dev->name);
-		tasklet_kill(&sp->task);
-		s2io_reset(sp);
-		free_irq(dev->irq, dev);
-		free_rx_buffers(sp);
-		return -ENODEV;
-	}
-
-	sp->device_close_flag = FALSE;	/* Device is up and running. */
 	netif_start_queue(dev);
-
 	return 0;
 }

@@ -2755,67 +2714,14 @@
 int s2io_close(struct net_device *dev)
 {
 	nic_t *sp = dev->priv;
-	XENA_dev_config_t *bar0 = (XENA_dev_config_t *) sp->bar0;
-	register u64 val64 = 0;
-	u16 cnt = 0;
-	unsigned long flags;

-	spin_lock_irqsave(&sp->tx_lock, flags);
+	flush_scheduled_work();
 	netif_stop_queue(dev);
+	/* Reset card, kill tasklet and free Tx and Rx buffers. */
+	s2io_card_down(sp);

-	/* disable Tx and Rx traffic on the NIC */
-	stop_nic(sp);
-
-	/*
-	 * If the device tasklet is running, wait till its done
-	 * before killing it
-	 */
-	while (atomic_read(&(sp->tasklet_status))) {
-		set_current_state(TASK_UNINTERRUPTIBLE);
-		schedule_timeout(HZ / 10);
-	}
-	tasklet_kill(&sp->task);
-
-	/*  Free the Registered IRQ */
 	free_irq(dev->irq, dev);
-
-	/* Flush all scheduled tasks */
-	if (sp->task_flag == 1) {
-		DBG_PRINT(INFO_DBG, "%s: Calling close from a task\n",
-			  dev->name);
-	} else {
-		flush_scheduled_work();
-	}
-
-	/* Check if the device is Quiescent and then Reset the NIC */
-	do {
-		val64 = readq(&bar0->adapter_status);
-		if (verify_xena_quiescence(val64, sp->device_enabled_once)) {
-			break;
-		}
-
-		set_current_state(TASK_UNINTERRUPTIBLE);
-		schedule_timeout(HZ / 20);
-		cnt++;
-		if (cnt == 10) {
-			DBG_PRINT(ERR_DBG,
-				  "s2io_close:Device not Quiescent ");
-			DBG_PRINT(ERR_DBG, "adaper status reads 0x%llx\n",
-				  (unsigned long long) val64);
-			break;
-		}
-	} while (1);
-	s2io_reset(sp);
-
-	/* Free all Tx Buffers waiting for transmission */
-	free_tx_buffers(sp);
-
-	/*  Free all Rx buffers allocated by host */
-	free_rx_buffers(sp);
-
 	sp->device_close_flag = TRUE;	/* Device is shut down. */
-	spin_unlock_irqrestore(&sp->tx_lock, flags);
-
 	return 0;
 }

@@ -2851,14 +2757,13 @@
 	config = &sp->config;

 	DBG_PRINT(TX_DBG, "%s: In S2IO Tx routine\n", dev->name);
-
 	spin_lock_irqsave(&sp->tx_lock, flags);
-	if ((netif_queue_stopped(dev)) || (!netif_carrier_ok(dev))) {
-		DBG_PRINT(TX_DBG, "%s:s2io_xmit: Tx Queue stopped\n",
+
+	if (atomic_read(&sp->card_state) == CARD_DOWN) {
+		DBG_PRINT(ERR_DBG, "%s: Card going down for reset\n",
 			  dev->name);
-		dev_kfree_skb(skb);
 		spin_unlock_irqrestore(&sp->tx_lock, flags);
-		return 0;
+		return 1;
 	}

 	queue = 0;
@@ -3037,18 +2942,13 @@
 				DBG_PRINT(ERR_DBG, "%s:Out of memory",
 					  dev->name);
 				DBG_PRINT(ERR_DBG, " in ISR!!\n");
-				clear_bit(0,
-					  (unsigned long *) (&sp->
-							     tasklet_status));
+				clear_bit(0, (&sp->tasklet_status));
 				return IRQ_HANDLED;
 			}
-			clear_bit(0,
-				  (unsigned long *) (&sp->tasklet_status));
-		} else if ((level == LOW)
-			   && (!atomic_read(&sp->tasklet_status))) {
+			clear_bit(0, (&sp->tasklet_status));
+		} else if (level == LOW) {
 			tasklet_schedule(&sp->task);
 		}
-
 	}
 #endif

@@ -4317,7 +4217,7 @@
 				break;
 			}
 		}
-		clear_bit(0, (unsigned long *) (&sp->tasklet_status));
+		clear_bit(0, (&sp->tasklet_status));
 	}
 }

@@ -4335,6 +4235,11 @@
 	register u64 val64;
 	u16 subid;

+	if (test_and_set_bit(0, &(nic->link_state))) {
+		/* The card is being reset, no point doing anything */
+		return;
+	}
+
 	subid = nic->pdev->subsystem_device;
 	/*
 	 * Allow a small delay for the NICs self initiated
@@ -4384,6 +4289,109 @@
 		DBG_PRINT(ERR_DBG, "device is not Quiescent\n");
 		netif_stop_queue(dev);
 	}
+	clear_bit(0, &(nic->link_state));
+}
+
+static void s2io_card_down(nic_t * sp)
+{
+	int cnt = 0;
+	XENA_dev_config_t *bar0 = (XENA_dev_config_t *) sp->bar0;
+	unsigned long flags;
+	register u64 val64 = 0;
+
+	/* If s2io_set_link task is executing, wait till it completes. */
+	while (test_and_set_bit(0, &(sp->link_state))) {
+		set_current_state(TASK_UNINTERRUPTIBLE);
+		schedule_timeout(HZ / 20);
+	}
+	atomic_set(&sp->card_state, CARD_DOWN);
+
+	/* disable Tx and Rx traffic on the NIC */
+	stop_nic(sp);
+
+	/* Kill tasklet. */
+	tasklet_kill(&sp->task);
+
+	/* Check if the device is Quiescent and then Reset the NIC */
+	do {
+		val64 = readq(&bar0->adapter_status);
+		if (verify_xena_quiescence(val64, sp->device_enabled_once)) {
+			break;
+		}
+
+		set_current_state(TASK_UNINTERRUPTIBLE);
+		schedule_timeout(HZ / 20);
+		cnt++;
+		if (cnt == 10) {
+			DBG_PRINT(ERR_DBG,
+				  "s2io_close:Device not Quiescent ");
+			DBG_PRINT(ERR_DBG, "adaper status reads 0x%llx\n",
+				  (unsigned long long) val64);
+			break;
+		}
+	} while (1);
+	spin_lock_irqsave(&sp->tx_lock, flags);
+	s2io_reset(sp);
+
+	/* Free all unused Tx and Rx buffers */
+	free_tx_buffers(sp);
+	free_rx_buffers(sp);
+
+	spin_unlock_irqrestore(&sp->tx_lock, flags);
+	clear_bit(0, &(sp->link_state));
+}
+
+static int s2io_card_up(nic_t * sp)
+{
+	int i, ret;
+	mac_info_t *mac_control;
+	struct config_param *config;
+	struct net_device *dev = (struct net_device *) sp->dev;
+
+	/* Initialize the H/W I/O registers */
+	if (init_nic(sp) != 0) {
+		DBG_PRINT(ERR_DBG, "%s: H/W initialization failed\n",
+			  dev->name);
+		return -ENODEV;
+	}
+
+	/*
+	 * Initializing the Rx buffers. For now we are considering only 1
+	 * Rx ring and initializing buffers into 30 Rx blocks
+	 */
+	mac_control = &sp->mac_control;
+	config = &sp->config;
+
+	for (i = 0; i < config->rx_ring_num; i++) {
+		if ((ret = fill_rx_buffers(sp, i))) {
+			DBG_PRINT(ERR_DBG, "%s: Out of memory in Open\n",
+				  dev->name);
+			s2io_reset(sp);
+			free_rx_buffers(sp);
+			return -ENOMEM;
+		}
+		DBG_PRINT(INFO_DBG, "Buf in ring:%d is %d:\n", i,
+			  atomic_read(&sp->rx_bufs_left[i]));
+	}
+
+	/* Setting its receive mode */
+	s2io_set_multicast(dev);
+
+	/* Enable tasklet for the device */
+	tasklet_init(&sp->task, s2io_tasklet, (unsigned long) dev);
+
+	/* Enable Rx Traffic and interrupts on the NIC */
+	if (start_nic(sp)) {
+		DBG_PRINT(ERR_DBG, "%s: Starting NIC failed\n", dev->name);
+		tasklet_kill(&sp->task);
+		s2io_reset(sp);
+		free_irq(dev->irq, dev);
+		free_rx_buffers(sp);
+		return -ENODEV;
+	}
+
+	atomic_set(&sp->card_state, CARD_UP);
+	return 0;
 }

 /**
@@ -4401,13 +4409,14 @@
 	struct net_device *dev = (struct net_device *) data;
 	nic_t *sp = dev->priv;

-	sp->task_flag = 1;
-	s2io_close(dev);
-	sp->task_flag = 0;
-	sp->device_close_flag = TRUE;
-	s2io_open(dev);
-	DBG_PRINT(ERR_DBG,
-		  "%s: was reset by Tx watchdog timer.\n", dev->name);
+	s2io_card_down(sp);
+	if (s2io_card_up(sp)) {
+		DBG_PRINT(ERR_DBG, "%s: Device bring up failed\n",
+			  dev->name);
+	}
+	netif_wake_queue(dev);
+	DBG_PRINT(ERR_DBG, "%s: was reset by Tx watchdog timer\n",
+		  dev->name);
 }

 /**
@@ -4990,8 +4999,13 @@
 	dev->addr_len = ETH_ALEN;
 	memcpy(dev->dev_addr, sp->def_mac_addr, ETH_ALEN);

-	/*  Initialize the tasklet status flag */
-	atomic_set(&(sp->tasklet_status), 0);
+	/*
+	 * Initialize the tasklet status and link state flags
+	 * and the card statte parameter
+	 */
+	atomic_set(&(sp->card_state), 0);
+	sp->tasklet_status = 0;
+	sp->link_state = 0;


 	/* Initialize spinlocks */
@@ -5298,7 +5312,7 @@
 		printk
 		    ("tx_urange_a, tx_urange_b & tx_urange_c can take value "
 		     "from 0 to 100 and range_a can't exceed range_b "
-			"neither can range_b exceed range_c\n");
+		     "neither can range_b exceed range_c\n");
 		fail = 1;
 	}
 	if (((rx_urange_a > 100) || (rx_urange_b > 100) ||
@@ -5307,7 +5321,7 @@
 		printk
 		    ("rx_urange_a, rx_urange_b & rx_urange_c can take value "
 		     "from 0 to 100 and range_a can't exceed range_b "
-			"neither can range_b exceed range_c\n");
+		     "neither can range_b exceed range_c\n");
 		fail = 1;
 	}
 	if ((tx_ufc_a > 0xffff) || (tx_ufc_b > 0xffff) ||
diff -urN vanilla-linux/drivers/net/s2io.h linux-2.6.8.1/drivers/net/s2io.h
--- vanilla-linux/drivers/net/s2io.h	2004-10-26 16:36:28.244032568 -0700
+++ linux-2.6.8.1/drivers/net/s2io.h	2004-10-26 16:36:16.893758072 -0700
@@ -637,7 +637,7 @@

 	char name[32];
 	struct tasklet_struct task;
-	atomic_t tasklet_status;
+	volatile unsigned long tasklet_status;
 	struct timer_list timer;
 	struct net_device *dev;
 	struct pci_dev *pdev;
@@ -730,6 +730,10 @@
 	buffAdd_t **ba[MAX_RX_RINGS];
 #endif
 	int task_flag;
+#define CARD_DOWN 1
+#define CARD_UP 2
+	atomic_t card_state;
+	volatile unsigned long link_state;
 } nic_t;

 #define RESET_ERROR 1;
@@ -874,5 +878,7 @@
 static struct ethtool_ops netdev_ethtool_ops;
 #endif
 static void s2io_set_link(unsigned long data);
+static void s2io_card_down(nic_t * nic);
+static int s2io_card_up(nic_t * nic);

 #endif				/* _S2IO_H */
