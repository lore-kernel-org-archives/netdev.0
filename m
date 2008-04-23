From: Sreenivasa Honnur <Sreenivasa.Honnur@neterion.com>
Subject: [PATCH 2.6.26 1/5]S2io: Removed receive buffer replenishment tasklet
Date: Wed, 23 Apr 2008 13:29:42 -0400 (EDT)
Message-ID: <Pine.GSO.4.10.10804231329010.10279-100000@guinness>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: support@neterion.com
To: netdev@vger.kernel.org, jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:39415 "EHLO
	barracuda.s2io.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752298AbYDWR3o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Apr 2008 13:29:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- Removed receive buffer replenishment tasklet s2io_tasklet and instead 
  allocating the receive buffers in either the interrupt handler (no napi) 
  or the napi handler (napi enabled).

Signed-off-by: Surjit Reang <surjit.reang@neterion.com>
Signed-off-by: Sreenivasa Honnur <sreenivasa.honnur@neterion.com>
Signed-off-by: Ramkrishna Vepa <ram.vepa@neterion.com>
---
diff -Nurp 2-0-26-19/drivers/net/s2io.c 2-0-26-21-1/drivers/net/s2io.c
--- 2-0-26-19/drivers/net/s2io.c	2008-04-09 21:06:13.000000000 +0530
+++ 2-0-26-21-1/drivers/net/s2io.c	2008-04-09 21:06:59.000000000 +0530
@@ -117,20 +117,6 @@ static inline int RXD_IS_UP2DT(struct Rx
 
 #define LINK_IS_UP(val64) (!(val64 & (ADAPTER_STATUS_RMAC_REMOTE_FAULT | \
 				      ADAPTER_STATUS_RMAC_LOCAL_FAULT)))
-#define TASKLET_IN_USE test_and_set_bit(0, (&sp->tasklet_status))
-#define PANIC	1
-#define LOW	2
-static inline int rx_buffer_level(struct s2io_nic * sp, int rxb_size, int ring)
-{
-	struct mac_info *mac_control;
-
-	mac_control = &sp->mac_control;
-	if (rxb_size <= rxd_count[sp->rxd_mode])
-		return PANIC;
-	else if ((mac_control->rings[ring].pkt_cnt - rxb_size) > 16)
-		return  LOW;
-	return 0;
-}
 
 static inline int is_s2io_card_up(const struct s2io_nic * sp)
 {
@@ -4105,7 +4091,6 @@ static int s2io_close(struct net_device 
 			do_s2io_delete_unicast_mc(sp, tmp64);
 	}
 
-	/* Reset card, kill tasklet and free Tx and Rx buffers. */
 	s2io_card_down(sp);
 
 	return 0;
@@ -4370,29 +4355,9 @@ s2io_alarm_handle(unsigned long data)
 
 static int s2io_chk_rx_buffers(struct s2io_nic *sp, int rng_n)
 {
-	int rxb_size, level;
-
-	if (!sp->lro) {
-		rxb_size = atomic_read(&sp->rx_bufs_left[rng_n]);
-		level = rx_buffer_level(sp, rxb_size, rng_n);
-
-		if ((level == PANIC) && (!TASKLET_IN_USE)) {
-			int ret;
-			DBG_PRINT(INTR_DBG, "%s: Rx BD hit ", __FUNCTION__);
-			DBG_PRINT(INTR_DBG, "PANIC levels\n");
-			if ((ret = fill_rx_buffers(sp, rng_n)) == -ENOMEM) {
-				DBG_PRINT(INFO_DBG, "Out of memory in %s",
-					  __FUNCTION__);
-				clear_bit(0, (&sp->tasklet_status));
-				return -1;
-			}
-			clear_bit(0, (&sp->tasklet_status));
-		} else if (level == LOW)
-			tasklet_schedule(&sp->task);
-
-	} else if (fill_rx_buffers(sp, rng_n) == -ENOMEM) {
-			DBG_PRINT(INFO_DBG, "%s:Out of memory", sp->dev->name);
-			DBG_PRINT(INFO_DBG, " in Rx Intr!!\n");
+	if (fill_rx_buffers(sp, rng_n) == -ENOMEM) {
+		DBG_PRINT(INFO_DBG, "%s:Out of memory", sp->dev->name);
+		DBG_PRINT(INFO_DBG, " in Rx Intr!!\n");
 	}
 	return 0;
 }
@@ -6770,49 +6735,6 @@ static int s2io_change_mtu(struct net_de
 }
 
 /**
- *  s2io_tasklet - Bottom half of the ISR.
- *  @dev_adr : address of the device structure in dma_addr_t format.
- *  Description:
- *  This is the tasklet or the bottom half of the ISR. This is
- *  an extension of the ISR which is scheduled by the scheduler to be run
- *  when the load on the CPU is low. All low priority tasks of the ISR can
- *  be pushed into the tasklet. For now the tasklet is used only to
- *  replenish the Rx buffers in the Rx buffer descriptors.
- *  Return value:
- *  void.
- */
-
-static void s2io_tasklet(unsigned long dev_addr)
-{
-	struct net_device *dev = (struct net_device *) dev_addr;
-	struct s2io_nic *sp = dev->priv;
-	int i, ret;
-	struct mac_info *mac_control;
-	struct config_param *config;
-
-	mac_control = &sp->mac_control;
-	config = &sp->config;
-
-	if (!TASKLET_IN_USE) {
-		for (i = 0; i < config->rx_ring_num; i++) {
-			ret = fill_rx_buffers(sp, i);
-			if (ret == -ENOMEM) {
-				DBG_PRINT(INFO_DBG, "%s: Out of ",
-					  dev->name);
-				DBG_PRINT(INFO_DBG, "memory in tasklet\n");
-				break;
-			} else if (ret == -EFILL) {
-				DBG_PRINT(INFO_DBG,
-					  "%s: Rx Ring %d is full\n",
-					  dev->name, i);
-				break;
-			}
-		}
-		clear_bit(0, (&sp->tasklet_status));
-	}
-}
-
-/**
  * s2io_set_link - Set the LInk status
  * @data: long pointer to device private structue
  * Description: Sets the link status for the adapter
@@ -7186,9 +7108,6 @@ static void do_s2io_card_down(struct s2i
 
 	s2io_rem_isr(sp);
 
-	/* Kill tasklet. */
-	tasklet_kill(&sp->task);
-
 	/* Check if the device is Quiescent and then Reset the NIC */
 	while(do_io) {
 		/* As per the HW requirement we need to replenish the
@@ -7314,9 +7233,6 @@ static int s2io_card_up(struct s2io_nic 
 
 	S2IO_TIMER_CONF(sp->alarm_timer, s2io_alarm_handle, sp, (HZ/2));
 
-	/* Enable tasklet for the device */
-	tasklet_init(&sp->task, s2io_tasklet, (unsigned long) dev);
-
 	/*  Enable select interrupts */
 	en_dis_err_alarms(sp, ENA_ALL_INTRS, ENABLE_INTRS);
 	if (sp->config.intr_type != INTA)
@@ -8119,10 +8035,9 @@ s2io_init_nic(struct pci_dev *pdev, cons
 	s2io_reset(sp);
 
 	/*
-	 * Initialize the tasklet status and link state flags
+	 * Initialize link state flags
 	 * and the card state parameter
 	 */
-	sp->tasklet_status = 0;
 	sp->state = 0;
 
 	/* Initialize spinlocks */
diff -Nurp 2-0-26-19/drivers/net/s2io.h 2-0-26-21-1/drivers/net/s2io.h
--- 2-0-26-19/drivers/net/s2io.h	2008-04-09 21:06:13.000000000 +0530
+++ 2-0-26-21-1/drivers/net/s2io.h	2008-04-09 21:07:06.000000000 +0530
@@ -868,8 +868,6 @@ struct s2io_nic {
 	int device_enabled_once;
 
 	char name[60];
-	struct tasklet_struct task;
-	volatile unsigned long tasklet_status;
 
 	/* Timer that handles I/O errors/exceptions */
 	struct timer_list alarm_timer;
@@ -1094,7 +1092,6 @@ static void s2io_handle_errors(void * de
 static int s2io_starter(void);
 static void s2io_closer(void);
 static void s2io_tx_watchdog(struct net_device *dev);
-static void s2io_tasklet(unsigned long dev_addr);
 static void s2io_set_multicast(struct net_device *dev);
 static int rx_osm_handler(struct ring_info *ring_data, struct RxD_t * rxdp);
 static void s2io_link(struct s2io_nic * sp, int link);

