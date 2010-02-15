From: David Daney <ddaney@caviumnetworks.com>
Subject: [PATCH 4/4] Staging: Octeon:  Free transmit SKBs in a timely manner.
Date: Mon, 15 Feb 2010 12:13:19 -0800
Message-ID: <1266264799-3510-4-git-send-email-ddaney@caviumnetworks.com>
References: <4B79AAA6.60005@caviumnetworks.com>
Cc: David Daney <ddaney@caviumnetworks.com>
To: ralf@linux-mips.org, linux-mips@linux-mips.org,
	netdev@vger.kernel.org, gregkh@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail3.caviumnetworks.com ([12.108.191.235]:19972 "EHLO
	mail3.caviumnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756216Ab0BOUNd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Feb 2010 15:13:33 -0500
In-Reply-To: <4B79AAA6.60005@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If we wait for the once-per-second cleanup to free transmit SKBs,
sockets with small transmit buffer sizes might spend most of their
time blocked waiting for the cleanup.

Normally we do a cleanup for each transmitted packet.  We add a
watchdog type timer so that we also schedule a timeout for 150uS after
a packet is transmitted.  The watchdog is reset for each transmitted
packet, so for high packet rates, it never expires.  At these high
rates, the cleanups are done for each packet so the extra watchdog
initiated cleanups are not needed.

Signed-off-by: David Daney <ddaney@caviumnetworks.com>
---
 drivers/staging/octeon/Kconfig            |    1 -
 drivers/staging/octeon/ethernet-defines.h |    5 +-
 drivers/staging/octeon/ethernet-tx.c      |  137 +++++++++++++++++++++++------
 drivers/staging/octeon/ethernet-tx.h      |    6 +-
 drivers/staging/octeon/ethernet.c         |   47 +++++-----
 drivers/staging/octeon/octeon-ethernet.h  |    9 +--
 6 files changed, 142 insertions(+), 63 deletions(-)

diff --git a/drivers/staging/octeon/Kconfig b/drivers/staging/octeon/Kconfig
index 579b8f1..638ad6b 100644
--- a/drivers/staging/octeon/Kconfig
+++ b/drivers/staging/octeon/Kconfig
@@ -3,7 +3,6 @@ config OCTEON_ETHERNET
 	depends on CPU_CAVIUM_OCTEON
 	select PHYLIB
 	select MDIO_OCTEON
-	select HIGH_RES_TIMERS
 	help
 	  This driver supports the builtin ethernet ports on Cavium
 	  Networks' products in the Octeon family. This driver supports the
diff --git a/drivers/staging/octeon/ethernet-defines.h b/drivers/staging/octeon/ethernet-defines.h
index 00a8561..6a2cd50 100644
--- a/drivers/staging/octeon/ethernet-defines.h
+++ b/drivers/staging/octeon/ethernet-defines.h
@@ -95,10 +95,11 @@
 /*#define DONT_WRITEBACK(x)         0   */
 
 /* Maximum number of SKBs to try to free per xmit packet. */
-#define MAX_SKB_TO_FREE 10
 #define MAX_OUT_QUEUE_DEPTH 1000
 
-#define FAU_NUM_PACKET_BUFFERS_TO_FREE (CVMX_FAU_REG_END - sizeof(uint32_t))
+#define FAU_TOTAL_TX_TO_CLEAN (CVMX_FAU_REG_END - sizeof(uint32_t))
+#define FAU_NUM_PACKET_BUFFERS_TO_FREE (FAU_TOTAL_TX_TO_CLEAN - sizeof(uint32_t))
+
 #define TOTAL_NUMBER_OF_PORTS       (CVMX_PIP_NUM_INPUT_PORTS+1)
 
 
diff --git a/drivers/staging/octeon/ethernet-tx.c b/drivers/staging/octeon/ethernet-tx.c
index 62258bd..5175247 100644
--- a/drivers/staging/octeon/ethernet-tx.c
+++ b/drivers/staging/octeon/ethernet-tx.c
@@ -48,6 +48,7 @@
 
 #include "cvmx-wqe.h"
 #include "cvmx-fau.h"
+#include "cvmx-pip.h"
 #include "cvmx-pko.h"
 #include "cvmx-helper.h"
 
@@ -66,6 +67,11 @@
 #define GET_SKBUFF_QOS(skb) 0
 #endif
 
+static void cvm_oct_tx_do_cleanup(unsigned long arg);
+static DECLARE_TASKLET(cvm_oct_tx_cleanup_tasklet, cvm_oct_tx_do_cleanup, 0);
+
+/* Maximum number of SKBs to try to free per xmit packet. */
+#define MAX_SKB_TO_FREE (MAX_OUT_QUEUE_DEPTH * 2)
 
 static inline int32_t cvm_oct_adjust_skb_to_free(int32_t skb_to_free, int fau)
 {
@@ -77,10 +83,24 @@ static inline int32_t cvm_oct_adjust_skb_to_free(int32_t skb_to_free, int fau)
 	return skb_to_free;
 }
 
-void cvm_oct_free_tx_skbs(struct octeon_ethernet *priv)
+static void cvm_oct_kick_tx_poll_watchdog(void)
+{
+	union cvmx_ciu_timx ciu_timx;
+	ciu_timx.u64 = 0;
+	ciu_timx.s.one_shot = 1;
+	ciu_timx.s.len = cvm_oct_tx_poll_interval;
+	cvmx_write_csr(CVMX_CIU_TIMX(1), ciu_timx.u64);
+}
+
+void cvm_oct_free_tx_skbs(struct net_device *dev)
 {
 	int32_t skb_to_free;
 	int qos, queues_per_port;
+	int total_freed = 0;
+	int total_remaining = 0;
+	unsigned long flags;
+	struct octeon_ethernet *priv = netdev_priv(dev);
+
 	queues_per_port = cvmx_pko_get_num_queues(priv->port);
 	/* Drain any pending packets in the free list */
 	for (qos = 0; qos < queues_per_port; qos++) {
@@ -89,24 +109,31 @@ void cvm_oct_free_tx_skbs(struct octeon_ethernet *priv)
 		skb_to_free = cvmx_fau_fetch_and_add32(priv->fau+qos*4, MAX_SKB_TO_FREE);
 		skb_to_free = cvm_oct_adjust_skb_to_free(skb_to_free, priv->fau+qos*4);
 
-		while (skb_to_free > 0) {
-			dev_kfree_skb_any(skb_dequeue(&priv->tx_free_list[qos]));
-			skb_to_free--;
+
+		total_freed += skb_to_free;
+		if (skb_to_free > 0) {
+			struct sk_buff *to_free_list = NULL;
+			spin_lock_irqsave(&priv->tx_free_list[qos].lock, flags);
+			while (skb_to_free > 0) {
+				struct sk_buff *t = __skb_dequeue(&priv->tx_free_list[qos]);
+				t->next = to_free_list;
+				to_free_list = t;
+				skb_to_free--;
+			}
+			spin_unlock_irqrestore(&priv->tx_free_list[qos].lock, flags);
+			/* Do the actual freeing outside of the lock. */
+			while (to_free_list) {
+				struct sk_buff *t = to_free_list;
+				to_free_list = to_free_list->next;
+				dev_kfree_skb_any(t);
+			}
 		}
+		total_remaining += skb_queue_len(&priv->tx_free_list[qos]);
 	}
-}
-
-enum hrtimer_restart cvm_oct_restart_tx(struct hrtimer *timer)
-{
-	struct octeon_ethernet *priv = container_of(timer, struct octeon_ethernet, tx_restart_timer);
-	struct net_device *dev = cvm_oct_device[priv->port];
-
-	cvm_oct_free_tx_skbs(priv);
-
-	if (netif_queue_stopped(dev))
+	if (total_freed >= 0 && netif_queue_stopped(dev))
 		netif_wake_queue(dev);
-
-	return HRTIMER_NORESTART;
+	if (total_remaining)
+		cvm_oct_kick_tx_poll_watchdog();
 }
 
 /**
@@ -129,6 +156,7 @@ int cvm_oct_xmit(struct sk_buff *skb, struct net_device *dev)
 	struct sk_buff *to_free_list;
 	int32_t skb_to_free;
 	int32_t buffers_to_free;
+	u32 total_to_clean;
 	unsigned long flags;
 #if REUSE_SKBUFFS_WITHOUT_FREE
 	unsigned char *fpa_head;
@@ -232,7 +260,6 @@ int cvm_oct_xmit(struct sk_buff *skb, struct net_device *dev)
 	pko_command.s.subone0 = 1;
 
 	pko_command.s.dontfree = 1;
-	pko_command.s.reg0 = priv->fau + qos * 4;
 
 	/* Build the PKO buffer pointer */
 	hw_buffer.u64 = 0;
@@ -327,7 +354,6 @@ int cvm_oct_xmit(struct sk_buff *skb, struct net_device *dev)
 	 * We can use this buffer in the FPA.  We don't need the FAU
 	 * update anymore
 	 */
-	pko_command.s.reg0 = 0;
 	pko_command.s.dontfree = 0;
 
 	hw_buffer.s.back = ((unsigned long)skb->data >> 7) - ((unsigned long)fpa_head >> 7);
@@ -384,15 +410,17 @@ dont_put_skbuff_in_hw:
 	 * If we're sending faster than the receive can free them then
 	 * don't do the HW free.
 	 */
-	if ((buffers_to_free < -100) && !pko_command.s.dontfree) {
+	if ((buffers_to_free < -100) && !pko_command.s.dontfree)
 		pko_command.s.dontfree = 1;
-		pko_command.s.reg0 = priv->fau + qos * 4;
-	}
 
-	if (pko_command.s.dontfree)
+	if (pko_command.s.dontfree) {
 		queue_type = QUEUE_CORE;
-	else
+		pko_command.s.reg0 = priv->fau+qos*4;
+	} else {
 		queue_type = QUEUE_HW;
+	}
+	if (USE_ASYNC_IOBDMA)
+		cvmx_fau_async_fetch_and_add32(CVMX_SCR_SCRATCH, FAU_TOTAL_TX_TO_CLEAN, 1);
 
 	spin_lock_irqsave(&priv->tx_free_list[qos].lock, flags);
 
@@ -402,10 +430,7 @@ dont_put_skbuff_in_hw:
 			/* Drop the lock when notifying the core.  */
 			spin_unlock_irqrestore(&priv->tx_free_list[qos].lock, flags);
 			netif_stop_queue(dev);
-			hrtimer_start(&priv->tx_restart_timer,
-				      priv->tx_restart_interval, HRTIMER_MODE_REL);
 			spin_lock_irqsave(&priv->tx_free_list[qos].lock, flags);
-
 		} else {
 			/* If not using normal queueing.  */
 			queue_type = QUEUE_DROP;
@@ -460,11 +485,27 @@ skip_xmit:
 	}
 
 	if (USE_ASYNC_IOBDMA) {
+		CVMX_SYNCIOBDMA;
+		total_to_clean = cvmx_scratch_read64(CVMX_SCR_SCRATCH);
 		/* Restore the scratch area */
 		cvmx_scratch_write64(CVMX_SCR_SCRATCH, old_scratch);
 		cvmx_scratch_write64(CVMX_SCR_SCRATCH + 8, old_scratch2);
+	} else {
+		total_to_clean = cvmx_fau_fetch_and_add32(FAU_TOTAL_TX_TO_CLEAN, 1);
 	}
 
+	if (total_to_clean & 0x3ff) {
+		/*
+		 * Schedule the cleanup tasklet every 1024 packets for
+		 * the pathological case of high traffic on one port
+		 * delaying clean up of packets on a different port
+		 * that is blocked waiting for the cleanup.
+		 */
+		tasklet_schedule(&cvm_oct_tx_cleanup_tasklet);
+	}
+
+	cvm_oct_kick_tx_poll_watchdog();
+
 	return NETDEV_TX_OK;
 }
 
@@ -624,7 +665,7 @@ int cvm_oct_xmit_pow(struct sk_buff *skb, struct net_device *dev)
  *
  * @dev:    Device being shutdown
  */
-void cvm_oct_tx_shutdown(struct net_device *dev)
+void cvm_oct_tx_shutdown_dev(struct net_device *dev)
 {
 	struct octeon_ethernet *priv = netdev_priv(dev);
 	unsigned long flags;
@@ -638,3 +679,45 @@ void cvm_oct_tx_shutdown(struct net_device *dev)
 		spin_unlock_irqrestore(&priv->tx_free_list[qos].lock, flags);
 	}
 }
+
+static void cvm_oct_tx_do_cleanup(unsigned long arg)
+{
+	int port;
+
+	for (port = 0; port < TOTAL_NUMBER_OF_PORTS; port++) {
+		if (cvm_oct_device[port]) {
+			struct net_device *dev = cvm_oct_device[port];
+			cvm_oct_free_tx_skbs(dev);
+		}
+	}
+}
+
+static irqreturn_t cvm_oct_tx_cleanup_watchdog(int cpl, void *dev_id)
+{
+	/* Disable the interrupt.  */
+	cvmx_write_csr(CVMX_CIU_TIMX(1), 0);
+	/* Do the work in the tasklet.  */
+	tasklet_schedule(&cvm_oct_tx_cleanup_tasklet);
+	return IRQ_HANDLED;
+}
+
+void cvm_oct_tx_initialize(void)
+{
+	int i;
+
+	/* Disable the interrupt.  */
+	cvmx_write_csr(CVMX_CIU_TIMX(1), 0);
+	/* Register an IRQ hander for to receive CIU_TIMX(1) interrupts */
+	i = request_irq(OCTEON_IRQ_TIMER1,
+			cvm_oct_tx_cleanup_watchdog, 0,
+			"Ethernet", cvm_oct_device);
+
+	if (i)
+		panic("Could not acquire Ethernet IRQ %d\n", OCTEON_IRQ_TIMER1);
+}
+
+void cvm_oct_tx_shutdown(void)
+{
+	/* Free the interrupt handler */
+	free_irq(OCTEON_IRQ_TIMER1, cvm_oct_device);
+}
diff --git a/drivers/staging/octeon/ethernet-tx.h b/drivers/staging/octeon/ethernet-tx.h
index b628d8c..547680c 100644
--- a/drivers/staging/octeon/ethernet-tx.h
+++ b/drivers/staging/octeon/ethernet-tx.h
@@ -29,6 +29,6 @@ int cvm_oct_xmit(struct sk_buff *skb, struct net_device *dev);
 int cvm_oct_xmit_pow(struct sk_buff *skb, struct net_device *dev);
 int cvm_oct_transmit_qos(struct net_device *dev, void *work_queue_entry,
 			 int do_free, int qos);
-void cvm_oct_tx_shutdown(struct net_device *dev);
-void cvm_oct_free_tx_skbs(struct octeon_ethernet *priv);
-enum hrtimer_restart cvm_oct_restart_tx(struct hrtimer *timer);
+void cvm_oct_tx_initialize(void);
+void cvm_oct_tx_shutdown(void);
+void cvm_oct_tx_shutdown_dev(struct net_device *dev);
diff --git a/drivers/staging/octeon/ethernet.c b/drivers/staging/octeon/ethernet.c
index 1771c10..f2ec8a6 100644
--- a/drivers/staging/octeon/ethernet.c
+++ b/drivers/staging/octeon/ethernet.c
@@ -140,6 +140,8 @@ atomic_t cvm_oct_poll_queue_stopping = ATOMIC_INIT(0);
  */
 struct net_device *cvm_oct_device[TOTAL_NUMBER_OF_PORTS];
 
+u64 cvm_oct_tx_poll_interval;
+
 static void cvm_oct_rx_refill_worker(struct work_struct *work);
 static DECLARE_DELAYED_WORK(cvm_oct_rx_refill_work, cvm_oct_rx_refill_worker);
 
@@ -159,18 +161,19 @@ static void cvm_oct_rx_refill_worker(struct work_struct *work)
 				   &cvm_oct_rx_refill_work, HZ);
 }
 
-static void cvm_oct_tx_clean_worker(struct work_struct *work)
+static void cvm_oct_preiodic_worker(struct work_struct *work)
 {
 	struct octeon_ethernet *priv = container_of(work,
 						    struct octeon_ethernet,
-						    tx_clean_work.work);
+						    port_periodic_work.work);
 
 	if (priv->poll)
 		priv->poll(cvm_oct_device[priv->port]);
-	cvm_oct_free_tx_skbs(priv);
+
 	cvm_oct_device[priv->port]->netdev_ops->ndo_get_stats(cvm_oct_device[priv->port]);
+
 	if (!atomic_read(&cvm_oct_poll_queue_stopping))
-		queue_delayed_work(cvm_oct_poll_queue, &priv->tx_clean_work, HZ);
+		queue_delayed_work(cvm_oct_poll_queue, &priv->port_periodic_work, HZ);
  }
 
 /**
@@ -662,6 +665,9 @@ static int __init cvm_oct_init_module(void)
 	 */
 	cvmx_fau_atomic_write32(FAU_NUM_PACKET_BUFFERS_TO_FREE, 0);
 
+	/* Initialize the FAU used for counting tx SKBs that need to be freed */
+	cvmx_fau_atomic_write32(FAU_TOTAL_TX_TO_CLEAN, 0);
+
 	if ((pow_send_group != -1)) {
 		struct net_device *dev;
 		pr_info("\tConfiguring device for POW only access\n");
@@ -670,18 +676,6 @@ static int __init cvm_oct_init_module(void)
 			/* Initialize the device private structure. */
 			struct octeon_ethernet *priv = netdev_priv(dev);
 
-			hrtimer_init(&priv->tx_restart_timer,
-				     CLOCK_MONOTONIC,
-				     HRTIMER_MODE_REL);
-			priv->tx_restart_timer.function = cvm_oct_restart_tx;
-
-			/*
-			 * Default for 10GE 5000nS enough time to
-			 * transmit about 100 64byte packtes.  1GE
-			 * interfaces will get 50000nS below.
-			 */
-			priv->tx_restart_interval = ktime_set(0, 5000);
-
 			dev->netdev_ops = &cvm_oct_pow_netdev_ops;
 			priv->imode = CVMX_HELPER_INTERFACE_MODE_DISABLED;
 			priv->port = CVMX_PIP_NUM_INPUT_PORTS;
@@ -725,9 +719,8 @@ static int __init cvm_oct_init_module(void)
 			/* Initialize the device private structure. */
 			priv = netdev_priv(dev);
 
-			INIT_DELAYED_WORK(&priv->tx_clean_work,
-					  cvm_oct_tx_clean_worker);
-
+			INIT_DELAYED_WORK(&priv->port_periodic_work,
+					  cvm_oct_preiodic_worker);
 			priv->imode = imode;
 			priv->port = port;
 			priv->queue = cvmx_pko_get_base_queue(priv->port);
@@ -763,7 +756,6 @@ static int __init cvm_oct_init_module(void)
 
 			case CVMX_HELPER_INTERFACE_MODE_SGMII:
 				dev->netdev_ops = &cvm_oct_sgmii_netdev_ops;
-				priv->tx_restart_interval = ktime_set(0, 50000);
 				strcpy(dev->name, "eth%d");
 				break;
 
@@ -775,7 +767,6 @@ static int __init cvm_oct_init_module(void)
 			case CVMX_HELPER_INTERFACE_MODE_RGMII:
 			case CVMX_HELPER_INTERFACE_MODE_GMII:
 				dev->netdev_ops = &cvm_oct_rgmii_netdev_ops;
-				priv->tx_restart_interval = ktime_set(0, 50000);
 				strcpy(dev->name, "eth%d");
 				break;
 			}
@@ -793,13 +784,19 @@ static int __init cvm_oct_init_module(void)
 				    cvmx_pko_get_num_queues(priv->port) *
 				    sizeof(uint32_t);
 				queue_delayed_work(cvm_oct_poll_queue,
-						   &priv->tx_clean_work, HZ);
+						   &priv->port_periodic_work, HZ);
 			}
 		}
 	}
 
+	cvm_oct_tx_initialize();
 	cvm_oct_rx_initialize();
 
+	/*
+	 * 150 uS: about 10 1500-byte packtes at 1GE.
+	 */
+	cvm_oct_tx_poll_interval = 150 * (octeon_get_clock_rate() / 1000000);
+
 	queue_delayed_work(cvm_oct_poll_queue, &cvm_oct_rx_refill_work, HZ);
 
 	return 0;
@@ -826,6 +823,8 @@ static void __exit cvm_oct_cleanup_module(void)
 	cancel_delayed_work_sync(&cvm_oct_rx_refill_work);
 
 	cvm_oct_rx_shutdown();
+	cvm_oct_tx_shutdown();
+
 	cvmx_pko_disable();
 
 	/* Free the ethernet devices */
@@ -833,9 +832,9 @@ static void __exit cvm_oct_cleanup_module(void)
 		if (cvm_oct_device[port]) {
 			struct net_device *dev = cvm_oct_device[port];
 			struct octeon_ethernet *priv = netdev_priv(dev);
-			cancel_delayed_work_sync(&priv->tx_clean_work);
+			cancel_delayed_work_sync(&priv->port_periodic_work);
 
-			cvm_oct_tx_shutdown(dev);
+			cvm_oct_tx_shutdown_dev(dev);
 			unregister_netdev(dev);
 			kfree(dev);
 			cvm_oct_device[port] = NULL;
diff --git a/drivers/staging/octeon/octeon-ethernet.h b/drivers/staging/octeon/octeon-ethernet.h
index 8d09210..db2a3cc 100644
--- a/drivers/staging/octeon/octeon-ethernet.h
+++ b/drivers/staging/octeon/octeon-ethernet.h
@@ -4,7 +4,7 @@
  * Contact: support@caviumnetworks.com
  * This file is part of the OCTEON SDK
  *
- * Copyright (c) 2003-2007 Cavium Networks
+ * Copyright (c) 2003-2010 Cavium Networks
  *
  * This file is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License, Version 2, as
@@ -31,8 +31,6 @@
 #ifndef OCTEON_ETHERNET_H
 #define OCTEON_ETHERNET_H
 
-#include <linux/hrtimer.h>
-
 /**
  * This is the definition of the Ethernet driver's private
  * driver state stored in netdev_priv(dev).
@@ -59,9 +57,7 @@ struct octeon_ethernet {
 	uint64_t link_info;
 	/* Called periodically to check link status */
 	void (*poll) (struct net_device *dev);
-	struct hrtimer		tx_restart_timer;
-	ktime_t			tx_restart_interval;
-	struct delayed_work	tx_clean_work;
+	struct delayed_work	port_periodic_work;
 	struct work_struct	port_work;	/* may be unused. */
 };
 
@@ -101,6 +97,7 @@ extern char pow_send_list[];
 extern struct net_device *cvm_oct_device[];
 extern struct workqueue_struct *cvm_oct_poll_queue;
 extern atomic_t cvm_oct_poll_queue_stopping;
+extern u64 cvm_oct_tx_poll_interval;
 
 extern int max_rx_cpus;
 extern int rx_napi_weight;
-- 
1.6.6

