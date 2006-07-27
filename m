From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2/2] forcdeth: NAPI support
Date: Thu, 27 Jul 2006 09:19:47 -0700
Message-ID: <20060727162051.259567836@localhost>
References: <20060727161945.204688818@localhost>
Cc: Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:38283 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1750844AbWG0Q01 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Jul 2006 12:26:27 -0400
To: Ayaz Abdulla <aabdulla@nvidia.com>,
	Manfred Spraul <manfred@colorfullife.com>,
	Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline; filename=napi-forcedeth.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Revised (and tested) version of NAPI support for nForce Ethernet
driver.  No change in performance for normal workloads. But will help
under DoS attack or slower processors.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>


 drivers/net/Kconfig     |   16 ++++++
 drivers/net/forcedeth.c |  125 +++++++++++++++++++++++++++++++++++++++++-------
 2 files changed, 123 insertions(+), 18 deletions(-)

--- linux-2.6.orig/drivers/net/Kconfig	2006-07-27 09:08:54.000000000 -0700
+++ linux-2.6/drivers/net/Kconfig	2006-07-27 09:15:10.000000000 -0700
@@ -1411,6 +1411,22 @@
 	  <file:Documentation/networking/net-modules.txt>.  The module will be
 	  called forcedeth.
 
+config FORCEDETH_NAPI
+	bool "Use Rx and Tx Polling (NAPI) (EXPERIMENTAL)"
+	depends on FORCEDETH && EXPERIMENTAL
+	help
+	  NAPI is a new driver API designed to reduce CPU and interrupt load
+	  when the driver is receiving lots of packets from the card. It is
+	  still somewhat experimental and thus not yet enabled by default.
+
+	  If your estimated Rx load is 10kpps or more, or if the card will be
+	  deployed on potentially unfriendly networks (e.g. in a firewall),
+	  then say Y here.
+
+	  See <file:Documentation/networking/NAPI_HOWTO.txt> for more
+	  information.
+
+	  If in doubt, say N.
 
 config CS89x0
 	tristate "CS89x0 support"
--- linux-2.6.orig/drivers/net/forcedeth.c	2006-07-27 09:14:40.000000000 -0700
+++ linux-2.6/drivers/net/forcedeth.c	2006-07-27 09:15:10.000000000 -0700
@@ -120,7 +120,11 @@
  * DEV_NEED_TIMERIRQ will not harm you on sane hardware, only generating a few
  * superfluous timer interrupts from the nic.
  */
-#define FORCEDETH_VERSION		"0.56"
+#ifdef CONFIG_FORCEDETH_NAPI
+#define FORCEDETH_VERSION		"0.57-NAPI"
+#else
+#define FORCEDETH_VERSION		"0.57"
+#endif
 #define DRV_NAME			"forcedeth"
 
 #include <linux/module.h>
@@ -957,7 +961,7 @@
 	writel(mask, base + NvRegIrqMask);
 }
 
-static void nv_disable_hw_interrupts(struct net_device *dev, u32 mask)
+static inline void nv_disable_hw_interrupts(struct net_device *dev, u32 mask)
 {
 	struct fe_priv *np = get_nvpriv(dev);
 	u8 __iomem *base = get_hwbase(dev);
@@ -1277,6 +1281,16 @@
 	return 0;
 }
 
+/* If rx bufs are exhausted called after 50ms to attempt to refresh */
+#ifdef CONFIG_FORCEDETH_NAPI
+static void nv_do_rx_refill(unsigned long data)
+{
+	struct net_device *dev = (struct net_device *) data;
+
+	/* Just reschedule NAPI rx processing */
+	netif_rx_schedule(dev);
+}
+#else
 static void nv_do_rx_refill(unsigned long data)
 {
 	struct net_device *dev = (struct net_device *) data;
@@ -1305,6 +1319,7 @@
 		enable_irq(np->msi_x_entry[NV_MSI_X_VECTOR_RX].vector);
 	}
 }
+#endif
 
 static void nv_init_rx(struct net_device *dev)
 {
@@ -1740,13 +1755,14 @@
 	}
 }
 
-static void nv_rx_process(struct net_device *dev)
+static int nv_rx_process(struct net_device *dev, int limit)
 {
 	struct fe_priv *np = netdev_priv(dev);
 	u32 flags;
 	u32 vlanflags = 0;
+	int count;
 
-	for (;;) {
+ 	for (count = 0; count < limit; ++count) {
 		struct sk_buff *skb;
 		int len;
 		int i;
@@ -1880,17 +1896,27 @@
 		skb->protocol = eth_type_trans(skb, dev);
 		dprintk(KERN_DEBUG "%s: nv_rx_process: packet %d with %d bytes, proto %d accepted.\n",
 					dev->name, np->cur_rx, len, skb->protocol);
-		if (np->vlangrp && (vlanflags & NV_RX3_VLAN_TAG_PRESENT)) {
-			vlan_hwaccel_rx(skb, np->vlangrp, vlanflags & NV_RX3_VLAN_TAG_MASK);
-		} else {
+#ifdef CONFIG_FORCEDETH_NAPI
+		if (np->vlangrp && (vlanflags & NV_RX3_VLAN_TAG_PRESENT))
+			vlan_hwaccel_receive_skb(skb, np->vlangrp,
+						 vlanflags & NV_RX3_VLAN_TAG_MASK);
+		else
+			netif_receive_skb(skb);
+#else
+		if (np->vlangrp && (vlanflags & NV_RX3_VLAN_TAG_PRESENT))
+			vlan_hwaccel_rx(skb, np->vlangrp,
+					vlanflags & NV_RX3_VLAN_TAG_MASK);
+		else
 			netif_rx(skb);
-		}
+#endif
 		dev->last_rx = jiffies;
 		np->stats.rx_packets++;
 		np->stats.rx_bytes += len;
 next_pkt:
 		np->cur_rx++;
 	}
+
+	return count;
 }
 
 static void set_bufsize(struct net_device *dev)
@@ -2376,14 +2402,6 @@
 		nv_tx_done(dev);
 		spin_unlock(&np->lock);
 
-		nv_rx_process(dev);
-		if (nv_alloc_rx(dev)) {
-			spin_lock(&np->lock);
-			if (!np->in_shutdown)
-				mod_timer(&np->oom_kick, jiffies + OOM_REFILL);
-			spin_unlock(&np->lock);
-		}
-
 		if (events & NVREG_IRQ_LINK) {
 			spin_lock(&np->lock);
 			nv_link_irq(dev);
@@ -2403,6 +2421,20 @@
 			printk(KERN_DEBUG "%s: received irq with unknown events 0x%x. Please report\n",
 						dev->name, events);
 		}
+#ifdef CONFIG_FORCEDETH_NAPI
+		if (netif_rx_schedule_prep(dev)) {
+			__netif_rx_schedule(dev);
+			nv_disable_hw_interrupts(dev, NVREG_IRQ_RX_ALL);
+		}
+#else
+		nv_rx_process(dev, dev->weight);
+		if (nv_alloc_rx(dev)) {
+			spin_lock(&np->lock);
+			if (!np->in_shutdown)
+				mod_timer(&np->oom_kick, jiffies + OOM_REFILL);
+			spin_unlock(&np->lock);
+		}
+#endif
 		if (i > max_interrupt_work) {
 			spin_lock(&np->lock);
 			/* disable interrupts on the nic */
@@ -2474,6 +2506,54 @@
 	return IRQ_RETVAL(i);
 }
 
+#ifdef CONFIG_FORCEDETH_NAPI
+static int nv_napi_poll(struct net_device *dev, int *budget)
+{
+	int pkts, limit = min(*budget, dev->quota);
+	struct fe_priv *np = netdev_priv(dev);
+
+	pkts = nv_rx_process(dev, limit);
+
+	if (nv_alloc_rx(dev)) {
+		spin_lock_irq(&np->lock);
+		if (!np->in_shutdown)
+			mod_timer(&np->oom_kick, jiffies + OOM_REFILL);
+		spin_unlock_irq(&np->lock);
+	}
+
+	if (pkts < limit) {
+		/* all done, no more packets present */
+		netif_rx_complete(dev);
+		nv_enable_hw_interrupts(dev, np->irqmask);
+		return 0;
+	} else {
+		/* used up our quantum, so reschedule */
+		dev->quota -= pkts;
+		*budget -= pkts;
+		return 1;
+	}
+}
+#endif
+
+#ifdef CONFIG_FORCEDETH_NAPI
+static irqreturn_t nv_nic_irq_rx(int foo, void *data, struct pt_regs *regs)
+{
+	struct net_device *dev = (struct net_device *) data;
+	u8 __iomem *base = get_hwbase(dev);
+	u32 events;
+
+	events = readl(base + NvRegMSIXIrqStatus) & NVREG_IRQ_RX_ALL;
+	writel(NVREG_IRQ_RX_ALL, base + NvRegMSIXIrqStatus);
+
+	if (events) {
+		netif_rx_schedule(dev);
+		/* disable receive interrupts on the nic */
+		writel(NVREG_IRQ_RX_ALL, base + NvRegIrqMask);
+		pci_push(base);
+	}
+	return IRQ_HANDLED;
+}
+#else
 static irqreturn_t nv_nic_irq_rx(int foo, void *data, struct pt_regs *regs)
 {
 	struct net_device *dev = (struct net_device *) data;
@@ -2492,7 +2572,7 @@
 		if (!(events & np->irqmask))
 			break;
 
-		nv_rx_process(dev);
+		nv_rx_process(dev, dev->weight);
 		if (nv_alloc_rx(dev)) {
 			spin_lock_irq(&np->lock);
 			if (!np->in_shutdown)
@@ -2514,12 +2594,12 @@
 			spin_unlock_irq(&np->lock);
 			break;
 		}
-
 	}
 	dprintk(KERN_DEBUG "%s: nv_nic_irq_rx completed\n", dev->name);
 
 	return IRQ_RETVAL(i);
 }
+#endif
 
 static irqreturn_t nv_nic_irq_other(int foo, void *data, struct pt_regs *regs)
 {
@@ -3753,6 +3833,7 @@
 	if (test->flags & ETH_TEST_FL_OFFLINE) {
 		if (netif_running(dev)) {
 			netif_stop_queue(dev);
+			netif_poll_disable(dev);
 			netif_tx_lock_bh(dev);
 			spin_lock_irq(&np->lock);
 			nv_disable_hw_interrupts(dev, np->irqmask);
@@ -3811,6 +3892,7 @@
 			nv_start_rx(dev);
 			nv_start_tx(dev);
 			netif_start_queue(dev);
+			netif_poll_enable(dev);
 			nv_enable_hw_interrupts(dev, np->irqmask);
 		}
 	}
@@ -4020,6 +4102,8 @@
 	nv_start_rx(dev);
 	nv_start_tx(dev);
 	netif_start_queue(dev);
+	netif_poll_enable(dev);
+
 	if (ret) {
 		netif_carrier_on(dev);
 	} else {
@@ -4049,6 +4133,7 @@
 	spin_lock_irq(&np->lock);
 	np->in_shutdown = 1;
 	spin_unlock_irq(&np->lock);
+	netif_poll_disable(dev);
 	synchronize_irq(dev->irq);
 
 	del_timer_sync(&np->oom_kick);
@@ -4270,6 +4355,10 @@
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	dev->poll_controller = nv_poll_controller;
 #endif
+	dev->weight = 64;
+#ifdef CONFIG_FORCEDETH_NAPI
+	dev->poll = nv_napi_poll;
+#endif
 	SET_ETHTOOL_OPS(dev, &ops);
 	dev->tx_timeout = nv_tx_timeout;
 	dev->watchdog_timeo = NV_WATCHDOG_TIMEO;

--

