From: Arjan van de Ven <arjan@infradead.org>
Subject: [PATCH 2.6.10-rc1] remove NET_HW_FLOWCONTROL
Date: Mon, 25 Oct 2004 21:20:42 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041025202042.GA4930@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

CONFIG_NET_HW_FLOWCONTROL is entirely unused now, and superceded by NAPI in
practice, so remove the dead code

Signed-off-by: Arjan van de Ven <arjan@infradead.org>

diff -purN linux-2.6.9/include/linux/netdevice.h linux/include/linux/netdevice.h
--- linux-2.6.9/include/linux/netdevice.h	2004-10-23 13:07:34.000000000 +0200
+++ linux/include/linux/netdevice.h	2004-10-25 22:08:54.374374481 +0200
@@ -930,8 +930,6 @@ extern void		netdev_state_change(struct 
 /* Load a device via the kmod */
 extern void		dev_load(const char *name);
 extern void		dev_mcast_init(void);
-extern int		netdev_register_fc(struct net_device *dev, void (*stimul)(struct net_device *dev));
-extern void		netdev_unregister_fc(int bit);
 extern int		netdev_max_backlog;
 extern int		weight_p;
 extern unsigned long	netdev_fc_xoff;
diff -purN linux-2.6.9/net/Kconfig linux/net/Kconfig
--- linux-2.6.9/net/Kconfig	2004-10-18 23:53:10.000000000 +0200
+++ linux/net/Kconfig	2004-10-25 22:14:22.940935390 +0200
@@ -564,24 +564,6 @@ config WAN_ROUTER
 
 	  If unsure, say N.
 
-config NET_HW_FLOWCONTROL
-	bool "Forwarding between high speed interfaces"
-	depends on EXPERIMENTAL
-	---help---
-	  This option enables NIC (Network Interface Card) hardware throttling
-	  during periods of extreme congestion. At the moment only a couple
-	  of device drivers support it (really only one -- tulip, a modified
-	  8390 driver can be found at
-	  <ftp://ftp.tux.org/pub/net/ip-routing/fastroute/fastroute-8390.tar.gz>).
-
-	  Really, this option is applicable to any machine attached to a fast
-	  enough network, and even a 10 Mb NIC is able to kill a not very slow
-	  box, such as a 120MHz Pentium.
-
-	  However, do not say Y here if you did not experience any serious
-	  problems.
-
-
 menu "QoS and/or fair queueing"
 
 config NET_SCHED
diff -purN linux-2.6.9/net/core/dev.c linux/net/core/dev.c
--- linux-2.6.9/net/core/dev.c	2004-10-23 13:07:34.000000000 +0200
+++ linux/net/core/dev.c	2004-10-25 22:14:10.183464383 +0200
@@ -1390,66 +1390,6 @@ int mod_cong = 290;
 DEFINE_PER_CPU(struct netif_rx_stats, netdev_rx_stat) = { 0, };
 
 
-#ifdef CONFIG_NET_HW_FLOWCONTROL
-atomic_t netdev_dropping = ATOMIC_INIT(0);
-static unsigned long netdev_fc_mask = 1;
-unsigned long netdev_fc_xoff;
-spinlock_t netdev_fc_lock = SPIN_LOCK_UNLOCKED;
-
-static struct
-{
-	void (*stimul)(struct net_device *);
-	struct net_device *dev;
-} netdev_fc_slots[BITS_PER_LONG];
-
-int netdev_register_fc(struct net_device *dev,
-		       void (*stimul)(struct net_device *dev))
-{
-	int bit = 0;
-	unsigned long flags;
-
-	spin_lock_irqsave(&netdev_fc_lock, flags);
-	if (netdev_fc_mask != ~0UL) {
-		bit = ffz(netdev_fc_mask);
-		netdev_fc_slots[bit].stimul = stimul;
-		netdev_fc_slots[bit].dev = dev;
-		set_bit(bit, &netdev_fc_mask);
-		clear_bit(bit, &netdev_fc_xoff);
-	}
-	spin_unlock_irqrestore(&netdev_fc_lock, flags);
-	return bit;
-}
-
-void netdev_unregister_fc(int bit)
-{
-	unsigned long flags;
-
-	spin_lock_irqsave(&netdev_fc_lock, flags);
-	if (bit > 0) {
-		netdev_fc_slots[bit].stimul = NULL;
-		netdev_fc_slots[bit].dev = NULL;
-		clear_bit(bit, &netdev_fc_mask);
-		clear_bit(bit, &netdev_fc_xoff);
-	}
-	spin_unlock_irqrestore(&netdev_fc_lock, flags);
-}
-
-static void netdev_wakeup(void)
-{
-	unsigned long xoff;
-
-	spin_lock(&netdev_fc_lock);
-	xoff = netdev_fc_xoff;
-	netdev_fc_xoff = 0;
-	while (xoff) {
-		int i = ffz(~xoff);
-		xoff &= ~(1 << i);
-		netdev_fc_slots[i].stimul(netdev_fc_slots[i].dev);
-	}
-	spin_unlock(&netdev_fc_lock);
-}
-#endif
-
 static void get_sample_stats(int cpu)
 {
 #ifdef RAND_LIE
@@ -1559,13 +1499,8 @@ enqueue:
 			return queue->cng_level;
 		}
 
-		if (queue->throttle) {
+		if (queue->throttle)
 			queue->throttle = 0;
-#ifdef CONFIG_NET_HW_FLOWCONTROL
-			if (atomic_dec_and_test(&netdev_dropping))
-				netdev_wakeup();
-#endif
-		}
 
 		netif_rx_schedule(&queue->backlog_dev);
 		goto enqueue;
@@ -1574,9 +1509,6 @@ enqueue:
 	if (!queue->throttle) {
 		queue->throttle = 1;
 		__get_cpu_var(netdev_rx_stat).throttled++;
-#ifdef CONFIG_NET_HW_FLOWCONTROL
-		atomic_inc(&netdev_dropping);
-#endif
 	}
 
 drop:
@@ -1848,16 +1780,6 @@ static int process_backlog(struct net_de
 		if (work >= quota || jiffies - start_time > 1)
 			break;
 
-#ifdef CONFIG_NET_HW_FLOWCONTROL
-		if (queue->throttle &&
-		    queue->input_pkt_queue.qlen < no_cong_thresh ) {
-			queue->throttle = 0;
-			if (atomic_dec_and_test(&netdev_dropping)) {
-				netdev_wakeup();
-				break;
-			}
-		}
-#endif
 	}
 
 	backlog_dev->quota -= work;
@@ -1872,13 +1794,8 @@ job_done:
 	smp_mb__before_clear_bit();
 	netif_poll_enable(backlog_dev);
 
-	if (queue->throttle) {
+	if (queue->throttle)
 		queue->throttle = 0;
-#ifdef CONFIG_NET_HW_FLOWCONTROL
-		if (atomic_dec_and_test(&netdev_dropping))
-			netdev_wakeup();
-#endif
-	}
 	local_irq_enable();
 	return 0;
 }
@@ -3365,12 +3282,6 @@ EXPORT_SYMBOL(br_handle_frame_hook);
 #ifdef CONFIG_KMOD
 EXPORT_SYMBOL(dev_load);
 #endif
-#ifdef CONFIG_NET_HW_FLOWCONTROL
-EXPORT_SYMBOL(netdev_dropping);
-EXPORT_SYMBOL(netdev_fc_xoff);
-EXPORT_SYMBOL(netdev_register_fc);
-EXPORT_SYMBOL(netdev_unregister_fc);
-#endif
 
 #ifdef CONFIG_NET_CLS_ACT
 EXPORT_SYMBOL(ing_filter);
