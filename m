From: Don Fry <brazilnut@us.ibm.com>
Subject: [PATCH 5/5] pcnet32:  NAPI implementation
Date: Wed, 13 Sep 2006 10:16:53 -0700
Message-ID: <20060913171653.GA12766@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:42180 "EHLO
	e31.co.us.ibm.com") by vger.kernel.org with ESMTP id S1750811AbWIMRQH
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Sep 2006 13:16:07 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e31.co.us.ibm.com (8.13.8/8.12.11) with ESMTP id k8DHG65Y013169
	for <netdev@vger.kernel.org>; Wed, 13 Sep 2006 13:16:06 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k8DHG6lp117792
	for <netdev@vger.kernel.org>; Wed, 13 Sep 2006 11:16:06 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k8DHG5Vj029852
	for <netdev@vger.kernel.org>; Wed, 13 Sep 2006 11:16:06 -0600
To: tsbogend@alpha.franken.de, jgarzik@pobox.com,
	netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Implement NAPI changes to pcnet32 driver.  Compile default is off.
Listed as experimental.

Len and Don both worked on a NAPI implementation and have both tested
these changes. 

An e1000 blasting short packets to the pcnet32 will lockup Don's system
until the receive storm stops.  Without NAPI Len's system watchdog would
expire causing the system to reboot.  With NAPI the system will stay
operational.

Tested ia32 and ppc64.  Tested '970A, '971, '972, '973, '975, '976, and
'978.

The Kconfig changes came from Len.  Don is to blame for all the others.

Signed-off-by: Len Sorensen <lsorense@csclub.uwaterloo.ca>
Signed-off-by: Don Fry <brazilnut@us.ibm.com>

--- linux-2.6.17-git13/drivers/net/orig.Kconfig	Wed Jun 28 10:38:45 2006
+++ linux-2.6.17-git13/drivers/net/Kconfig	Wed Jun 28 15:36:25 2006
@@ -1300,6 +1300,23 @@ config PCNET32
 	  <file:Documentation/networking/net-modules.txt>. The module
 	  will be called pcnet32.
 
+config PCNET32_NAPI
+	bool "Use RX polling (NAPI) (EXPERIMENTAL)"
+	depends on PCNET32 && EXPERIMENTAL
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
+
 config AMD8111_ETH
 	tristate "AMD 8111 (new PCI lance) support"
 	depends on NET_PCI && PCI
--- linux-2.6.18-rc6/drivers/net/pcnet32.c.split	Tue Sep 12 14:21:49 2006
+++ linux-2.6.18-rc6/drivers/net/pcnet32.c	Tue Sep 12 16:45:01 2006
@@ -21,9 +21,15 @@
  *
  *************************************************************************/
 
+#include <linux/config.h>
+
 #define DRV_NAME	"pcnet32"
-#define DRV_VERSION	"1.32"
-#define DRV_RELDATE	"18.Mar.2006"
+#ifdef CONFIG_PCNET32_NAPI
+#define DRV_VERSION	"1.33-NAPI"
+#else
+#define DRV_VERSION	"1.33"
+#endif
+#define DRV_RELDATE	"27.Jun.2006"
 #define PFX		DRV_NAME ": "
 
 static const char *const version =
@@ -882,7 +888,11 @@ static int pcnet32_loopback_test(struct 
 	rc = 1;			/* default to fail */
 
 	if (netif_running(dev))
+#ifdef CONFIG_PCNET32_NAPI
+		pcnet32_netif_stop(dev);
+#else
 		pcnet32_close(dev);
+#endif
 
 	spin_lock_irqsave(&lp->lock, flags);
 	lp->a.write_csr(ioaddr, CSR0, CSR0_STOP);	/* stop the chip */
@@ -1014,6 +1024,16 @@ static int pcnet32_loopback_test(struct 
 	x = a->read_bcr(ioaddr, 32);	/* reset internal loopback */
 	a->write_bcr(ioaddr, 32, (x & ~0x0002));
 
+#ifdef CONFIG_PCNET32_NAPI
+	if (netif_running(dev)) {
+		pcnet32_netif_start(dev);
+		pcnet32_restart(dev, CSR0_NORMAL);
+	} else {
+		pcnet32_purge_rx_ring(dev);
+		lp->a.write_bcr(ioaddr, 20, 4);	/* return to 16bit mode */
+	}
+	spin_unlock_irqrestore(&lp->lock, flags);
+#else
 	if (netif_running(dev)) {
 		spin_unlock_irqrestore(&lp->lock, flags);
 		pcnet32_open(dev);
@@ -1022,6 +1042,7 @@ static int pcnet32_loopback_test(struct 
 		lp->a.write_bcr(ioaddr, 20, 4);	/* return to 16bit mode */
 		spin_unlock_irqrestore(&lp->lock, flags);
 	}
+#endif
 
 	return (rc);
 }				/* end pcnet32_loopback_test  */
@@ -1227,23 +1248,25 @@ static void pcnet32_rx_entry(struct net_
 	}
 	lp->stats.rx_bytes += skb->len;
 	skb->protocol = eth_type_trans(skb, dev);
+#ifdef CONFIG_PCNET32_NAPI
+	netif_receive_skb(skb);
+#else
 	netif_rx(skb);
+#endif
 	dev->last_rx = jiffies;
 	lp->stats.rx_packets++;
 	return;
 }
 
-
-static void pcnet32_rx(struct net_device *dev)
+static int pcnet32_rx(struct net_device *dev, int quota)
 {
 	struct pcnet32_private *lp = dev->priv;
 	int entry = lp->cur_rx & lp->rx_mod_mask;
 	struct pcnet32_rx_head *rxp = &lp->rx_ring[entry];
 	int npackets = 0;
-	int boguscnt = lp->rx_ring_size / 2;
 
 	/* If we own the next entry, it's a new packet. Send it up. */
-	while (boguscnt > npackets && (short)le16_to_cpu(rxp->status) >= 0) {
+	while (quota > npackets && (short)le16_to_cpu(rxp->status) >= 0) {
 		pcnet32_rx_entry(dev, lp, rxp, entry);
 		npackets += 1;
 		/*
@@ -1257,10 +1280,10 @@ static void pcnet32_rx(struct net_device
 		rxp = &lp->rx_ring[entry];
 	}
 
-	return;
+	return npackets;
 }
 
-static int pcnet32_tx(struct net_device *dev, u16 csr0)
+static int pcnet32_tx(struct net_device *dev)
 {
 	struct pcnet32_private *lp = dev->priv;
 	unsigned int dirty_tx = lp->dirty_tx;
@@ -1298,8 +1321,8 @@ static int pcnet32_tx(struct net_device 
 				/* Remove this verbosity later! */
 				if (netif_msg_tx_err(lp))
 					printk(KERN_ERR
-					       "%s: Tx FIFO error! CSR0=%4.4x\n",
-					       dev->name, csr0);
+					       "%s: Tx FIFO error!\n",
+					       dev->name);
 				must_restart = 1;
 			}
 #else
@@ -1310,8 +1333,8 @@ static int pcnet32_tx(struct net_device 
 					/* Remove this verbosity later! */
 					if (netif_msg_tx_err(lp))
 						printk(KERN_ERR
-						       "%s: Tx FIFO error! CSR0=%4.4x\n",
-						       dev->name, csr0);
+						       "%s: Tx FIFO error!\n",
+						       dev->name);
 					must_restart = 1;
 				}
 			}
@@ -1358,6 +1381,52 @@ static int pcnet32_tx(struct net_device 
 	return must_restart;
 }
 
+#ifdef CONFIG_PCNET32_NAPI
+static int pcnet32_poll(struct net_device *dev, int *budget)
+{
+	struct pcnet32_private *lp = dev->priv;
+	int quota = min(dev->quota, *budget);
+	unsigned long ioaddr = dev->base_addr;
+	unsigned long flags;
+	u16 val;
+
+	quota = pcnet32_rx(dev, quota);
+
+	spin_lock_irqsave(&lp->lock, flags);
+	if (pcnet32_tx(dev)) {
+		/* reset the chip to clear the error condition, then restart */
+		lp->a.reset(ioaddr);
+		lp->a.write_csr(ioaddr, CSR4, 0x0915);	/* auto tx pad */
+		pcnet32_restart(dev, CSR0_START);
+		netif_wake_queue(dev);
+	}
+	spin_unlock_irqrestore(&lp->lock, flags);
+
+	*budget -= quota;
+	dev->quota -= quota;
+
+	if (dev->quota == 0) {
+		return 1;
+	}
+
+	netif_rx_complete(dev);
+
+	spin_lock_irqsave(&lp->lock, flags);
+
+	/* clear interrupt masks */
+	val = lp->a.read_csr(ioaddr, CSR3);
+	val &= 0x00ff;
+	lp->a.write_csr(ioaddr, CSR3, val);
+
+	/* Set interrupt enable. */
+	lp->a.write_csr(ioaddr, CSR0, CSR0_INTEN);
+	mmiowb();
+	spin_unlock_irqrestore(&lp->lock, flags);
+
+	return 0;
+}
+#endif
+
 #define PCNET32_REGS_PER_PHY	32
 #define PCNET32_MAX_PHYS	32
 static int pcnet32_get_regs_len(struct net_device *dev)
@@ -1894,6 +1963,10 @@ pcnet32_probe1(unsigned long ioaddr, int
 	dev->ethtool_ops = &pcnet32_ethtool_ops;
 	dev->tx_timeout = pcnet32_tx_timeout;
 	dev->watchdog_timeo = (5 * HZ);
+	dev->weight = lp->rx_ring_size / 2;
+#ifdef CONFIG_PCNET32_NAPI
+	dev->poll = pcnet32_poll;
+#endif
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	dev->poll_controller = pcnet32_poll_controller;
@@ -2497,7 +2570,6 @@ pcnet32_interrupt(int irq, void *dev_id,
 	unsigned long ioaddr;
 	u16 csr0;
 	int boguscnt = max_interrupt_work;
-	int must_restart;
 
 	if (!dev) {
 		if (pcnet32_debug & NETIF_MSG_INTR)
@@ -2519,20 +2591,11 @@ pcnet32_interrupt(int irq, void *dev_id,
 		/* Acknowledge all of the current interrupt sources ASAP. */
 		lp->a.write_csr(ioaddr, CSR0, csr0 & ~0x004f);
 
-		must_restart = 0;
-
 		if (netif_msg_intr(lp))
 			printk(KERN_DEBUG
 			       "%s: interrupt  csr0=%#2.2x new csr=%#2.2x.\n",
 			       dev->name, csr0, lp->a.read_csr(ioaddr, CSR0));
 
-		if (csr0 & 0x0400)	/* Rx interrupt */
-			pcnet32_rx(dev);
-
-		if (csr0 & 0x0200) {	/* Tx-done interrupt */
-			must_restart = pcnet32_tx(dev, csr0);
-		}
-
 		/* Log misc errors. */
 		if (csr0 & 0x4000)
 			lp->stats.tx_errors++;	/* Tx babble. */
@@ -2546,10 +2609,8 @@ pcnet32_interrupt(int irq, void *dev_id,
 			 * sometimes problems and will fill up the receive
 			 * ring with error descriptors.  In this situation we
 			 * don't get a rx interrupt, but a missed frame
-			 * interrupt sooner or later.  So we try to clean up
-			 * our receive ring here.
+			 * interrupt sooner or later.
 			 */
-			pcnet32_rx(dev);
 			lp->stats.rx_errors++;	/* Missed a Rx frame. */
 		}
 		if (csr0 & 0x0800) {
@@ -2559,19 +2620,34 @@ pcnet32_interrupt(int irq, void *dev_id,
 				       dev->name, csr0);
 			/* unlike for the lance, there is no restart needed */
 		}
-
-		if (must_restart) {
+#ifdef CONFIG_PCNET32_NAPI
+		if (netif_rx_schedule_prep(dev)) {
+			u16 val;
+			/* set interrupt masks */
+			val = lp->a.read_csr(ioaddr, CSR3);
+			val |= 0x5f00;
+			lp->a.write_csr(ioaddr, CSR3, val);
+			mmiowb();
+			__netif_rx_schedule(dev);
+			break;
+		}
+#else
+		pcnet32_rx(dev, dev->weight);
+		if (pcnet32_tx(dev)) {
 			/* reset the chip to clear the error condition, then restart */
 			lp->a.reset(ioaddr);
-			lp->a.write_csr(ioaddr, CSR4, 0x0915);	/* auto tx pad */
+			lp->a.write_csr(ioaddr, CSR4, 0x0915); /* auto tx pad */
 			pcnet32_restart(dev, CSR0_START);
 			netif_wake_queue(dev);
 		}
+#endif
 		csr0 = lp->a.read_csr(ioaddr, CSR0);
 	}
 
+#ifndef CONFIG_PCNET32_NAPI
 	/* Set interrupt enable. */
 	lp->a.write_csr(ioaddr, CSR0, CSR0_INTEN);
+#endif
 
 	if (netif_msg_intr(lp))
 		printk(KERN_DEBUG "%s: exiting interrupt, csr0=%#4.4x.\n",
-- 
Don Fry
brazilnut@us.ibm.com
