From: koushik <raghavendra.koushik@s2io.com>
Subject: [PATCH 2.6.9-rc2 3/12] S2io: optimizations
Date: Fri, 5 Nov 2004 05:06:18 -0800
Message-ID: <200411050506.18749.raghavendra.koushik@s2io.com>
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
Following are the optimization-related changes made in this patch.

1. Definitions of LOW and PANIC levels of the Rx buffers have changed.
2. In wait_for_cmd_complete there is no longer a writeq but just a read and wait for strobe bit to reset.
3. In s2io_isr, the isr_lock has been done away with also the NICs interrupt are no longer disabled explicitly on entering the
interrupt handler and re-enabled again before leaving it.
4. Also clearing the semaphore "tasklet_status" when exiting erroneously from s2io_isr after failing fill_rx_buffer call.
5. The set/reset Tx Csum function through ethtool was added to the ethtool_ops structure.
6. Added a Rx side error code in the rx_osm_handler function.
7. No longer stopping and waking Tx queue when link state changes in s2io_link function.
8. removed the isr_lock spinlock from the s2io_nic structure.
9. changed parameters which determine thresholds(LOW and PANIC) to replenish Rx buffers.
   This has been found to result in better performance.

Signed-off-by: Raghavendra Koushik <raghavendra.koushik@s2io.com>
Signed-off-by: Ravinandan Arakali <ravinandan.arakali@s2io.com>
---
diff -urN vanilla-linux/drivers/net/s2io.c linux-2.6.8.1/drivers/net/s2io.c
--- vanilla-linux/drivers/net/s2io.c	2004-10-06 17:24:02.000000000 -0700
+++ linux-2.6.8.1/drivers/net/s2io.c	2004-10-06 17:37:32.751003528 -0700
@@ -80,10 +80,11 @@
 static inline int rx_buffer_level(nic_t * sp, int rxb_size, int ring)
 {
 	int level = 0;
-	if ((sp->pkt_cnt[ring] - rxb_size) > 128) {
+	if ((sp->pkt_cnt[ring] - rxb_size) > 16) {
 		level = LOW;
-		if (rxb_size < sp->pkt_cnt[ring] / 8)
+		if ((sp->pkt_cnt[ring] - rxb_size) < MAX_RXDS_PER_BLOCK) {
 			level = PANIC;
+		}
 	}
 
 	return level;
@@ -1916,12 +1917,8 @@
 	u64 val64;
 
 	while (TRUE) {
-		val64 =
-		    RMAC_ADDR_CMD_MEM_RD | RMAC_ADDR_CMD_MEM_STROBE_NEW_CMD
-		    | RMAC_ADDR_CMD_MEM_OFFSET(0);
-		writeq(val64, &bar0->rmac_addr_cmd_mem);
 		val64 = readq(&bar0->rmac_addr_cmd_mem);
-		if (!val64) {
+		if (!(val64 & RMAC_ADDR_CMD_MEM_STROBE_CMD_EXECUTING)) {
 			ret = SUCCESS;
 			break;
 		}
@@ -2192,14 +2189,11 @@
 	register u64 val64 = 0;
 	u16 cnt = 0;
 
-	spin_lock(&sp->isr_lock);
 	netif_stop_queue(dev);
 
 	/* disable Tx and Rx traffic on the NIC */
 	stop_nic(sp);
 
-	spin_unlock(&sp->isr_lock);
-
 	/* 
 	 * If the device tasklet is running, wait till its done 
 	 * before killing it 
@@ -2398,15 +2392,13 @@
 	struct net_device *dev = (struct net_device *) dev_id;
 	nic_t *sp = dev->priv;
 	XENA_dev_config_t *bar0 = (XENA_dev_config_t *) sp->bar0;
-	u64 reason = 0, general_mask = 0;
+	u64 reason = 0;
 	mac_info_t *mac_control;
 	struct config_param *config;
 
 	mac_control = &sp->mac_control;
 	config = &sp->config;
 
-	spin_lock(&sp->isr_lock);
-
 	/* 
 	 * Identify the cause for interrupt and call the appropriate
 	 * interrupt handler. Causes for the interrupt could be;
@@ -2419,14 +2411,9 @@
 
 	if (!reason) {
 		/* The interrupt was not raised by Xena. */
-		spin_unlock(&sp->isr_lock);
 		return IRQ_NONE;
 	}
 
-	/* Mask the Interrupts on the NIC. */
-	general_mask = readq(&bar0->general_int_mask);
-	writeq(0xFFFFFFFFFFFFFFFFULL, &bar0->general_int_mask);
-
 	/* If Intr is because of Tx Traffic */
 	if (reason & GEN_INTR_TXTRAFFIC) {
 		tx_intr_handler(sp);
@@ -2441,11 +2428,6 @@
 		if (netif_rx_schedule_prep(dev)) {
 			en_dis_able_nic_intrs(sp, RX_TRAFFIC_INTR,
 					      DISABLE_INTRS);
-			/* 
-			 * Here we take a snap shot of the general 
-			 * Intr Register.
-			 */
-			general_mask = readq(&bar0->general_int_mask);
 			__netif_rx_schedule(dev);
 		}
 	}
@@ -2481,9 +2463,9 @@
 						  "%s:Out of memory",
 						  dev->name);
 					DBG_PRINT(ERR_DBG, " in ISR!!\n");
-					writeq(general_mask,
-					       &bar0->general_int_mask);
-					spin_unlock(&sp->isr_lock);
+					clear_bit(0,
+						  (unsigned long *) (&sp->
+								     tasklet_status));
 					return IRQ_HANDLED;
 				}
 				clear_bit(0,
@@ -2501,10 +2483,6 @@
 	tasklet_schedule(&sp->task);
 #endif
 
-	/* Unmask all previously enabled interrupts on the NIC. */
-	writeq(general_mask, &bar0->general_int_mask);
-
-	spin_unlock(&sp->isr_lock);
 	return IRQ_HANDLED;
 }
 
@@ -3626,6 +3604,17 @@
 	return (S2IO_STAT_LEN);
 }
 
+int s2io_ethtool_op_set_tx_csum(struct net_device *dev, u32 data)
+{
+	if (data)
+		dev->features |= NETIF_F_IP_CSUM;
+	else
+		dev->features &= ~NETIF_F_IP_CSUM;
+
+	return 0;
+}
+
+
 static struct ethtool_ops netdev_ethtool_ops = {
 	.get_settings = s2io_ethtool_gset,
 	.set_settings = s2io_ethtool_sset,
@@ -3641,7 +3630,7 @@
 	.get_rx_csum = s2io_ethtool_get_rx_csum,
 	.set_rx_csum = s2io_ethtool_set_rx_csum,
 	.get_tx_csum = ethtool_op_get_tx_csum,
-	.set_tx_csum = ethtool_op_set_tx_csum,
+	.set_tx_csum = s2io_ethtool_op_set_tx_csum,
 	.get_sg = ethtool_op_get_sg,
 	.set_sg = ethtool_op_set_sg,
 #ifdef NETIF_F_TSO
@@ -3902,6 +3891,12 @@
 		skb->ip_summed = CHECKSUM_NONE;
 	}
 
+	if (rxdp->Control_1 & RXD_T_CODE) {
+		unsigned long long err = rxdp->Control_1 & RXD_T_CODE;
+		DBG_PRINT(ERR_DBG, "%s: Rx error Value: 0x%llx\n",
+			  dev->name, err);
+	}
+
 	skb->dev = dev;
 	skb_put(skb, len);
 	skb->protocol = eth_type_trans(skb, dev);
@@ -3922,25 +3917,6 @@
 	return SUCCESS;
 }
 
-int check_for_tx_space(nic_t * sp)
-{
-	u32 put_off, get_off, queue_len;
-	int ret = TRUE, i;
-
-	for (i = 0; i < sp->config.tx_fifo_num; i++) {
-		queue_len = sp->mac_control.tx_curr_put_info[i].fifo_len
-		    + 1;
-		put_off = sp->mac_control.tx_curr_put_info[i].offset;
-		get_off = sp->mac_control.tx_curr_get_info[i].offset;
-		if (((put_off + 1) % queue_len) == get_off) {
-			ret = FALSE;
-			break;
-		}
-	}
-
-	return ret;
-}
-
 /**
  *  s2io_link - stops/starts the Tx queue.
  *  @sp : private member of the device structure, which is a pointer to the
@@ -3962,17 +3938,9 @@
 		if (link == LINK_DOWN) {
 			DBG_PRINT(ERR_DBG, "%s: Link down\n", dev->name);
 			netif_carrier_off(dev);
-			netif_stop_queue(dev);
 		} else {
 			DBG_PRINT(ERR_DBG, "%s: Link Up\n", dev->name);
 			netif_carrier_on(dev);
-			if (check_for_tx_space(sp) == TRUE) {
-				/*
-				 * Dont wake the queue if we know there
-				 * are no free TxDs available.
-				 */
-				netif_wake_queue(dev);
-			}
 		}
 	}
 	sp->last_link_state = link;
@@ -4357,7 +4325,6 @@
 
 	/* Initialize spinlocks */
 	spin_lock_init(&sp->tx_lock);
-	spin_lock_init(&sp->isr_lock);
 
 	/* 
 	 * SXE-002: Configure link and activity LED to init state 
diff -urN vanilla-linux/drivers/net/s2io.h linux-2.6.8.1/drivers/net/s2io.h
--- vanilla-linux/drivers/net/s2io.h	2004-10-06 17:24:05.000000000 -0700
+++ linux-2.6.8.1/drivers/net/s2io.h	2004-10-06 17:37:47.532756360 -0700
@@ -612,7 +612,6 @@
 	atomic_t rx_bufs_left[MAX_RX_RINGS];
 
 	spinlock_t tx_lock;
-	spinlock_t isr_lock;
 
 #define PROMISC     1
 #define ALL_MULTI   2


-------------------------------------------------------
