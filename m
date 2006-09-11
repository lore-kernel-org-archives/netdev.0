From: Don Fry <brazilnut@us.ibm.com>
Subject: [PATCH 2/3] pcnet32: NAPI implementation
Date: Mon, 11 Sep 2006 10:46:38 -0700
Message-ID: <20060911174638.GA3973@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:33759 "EHLO e5.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S1751320AbWIKRpx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Sep 2006 13:45:53 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e5.ny.us.ibm.com (8.13.8/8.12.11) with ESMTP id k8BHjphS007844
	for <netdev@vger.kernel.org>; Mon, 11 Sep 2006 13:45:51 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay02.pok.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k8BHjpCA294920
	for <netdev@vger.kernel.org>; Mon, 11 Sep 2006 13:45:51 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k8BHjpSW018633
	for <netdev@vger.kernel.org>; Mon, 11 Sep 2006 13:45:51 -0400
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
--- linux-2.6.18-rc6/drivers/net/pcnet32.c.breakup	Mon Sep 11 09:07:13 2006
+++ linux-2.6.18-rc6/drivers/net/pcnet32.c	Fri Sep  8 14:04:47 2006
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
@@ -1224,7 +1245,11 @@ static int pcnet32_rx_entry(struct net_d
 	lp->stats.rx_bytes += skb->len;
 	lp->stats.rx_packets++;
 	skb->protocol = eth_type_trans(skb, dev);
+#ifdef CONFIG_PCNET32_NAPI
+	netif_receive_skb(skb);
+#else
 	netif_rx(skb);
+#endif
 	dev->last_rx = jiffies;
 	return 1;
 }
@@ -1353,6 +1378,52 @@ static int pcnet32_tx(struct net_device 
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
+		lp->a.write_csr(ioaddr, CSR4, 0x0915);
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
@@ -1890,6 +1961,9 @@ pcnet32_probe1(unsigned long ioaddr, int
 	dev->tx_timeout = pcnet32_tx_timeout;
 	dev->watchdog_timeo = (5 * HZ);
 	dev->weight = lp->rx_ring_size / 2;
+#ifdef CONFIG_PCNET32_NAPI
+	dev->poll = pcnet32_poll;
+#endif
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	dev->poll_controller = pcnet32_poll_controller;
@@ -2543,6 +2617,18 @@ pcnet32_interrupt(int irq, void *dev_id,
 				       dev->name, csr0);
 			/* unlike for the lance, there is no restart needed */
 		}
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
 		pcnet32_rx(dev, dev->weight);
 		if (pcnet32_tx(dev)) {
 			/* reset the chip to clear the error condition, then restart */
@@ -2551,11 +2637,14 @@ pcnet32_interrupt(int irq, void *dev_id,
 			pcnet32_restart(dev, CSR0_START);
 			netif_wake_queue(dev);
 		}
+#endif
 		csr0 = lp->a.read_csr(ioaddr, CSR0);
 	}
 
+#ifndef CONFIG_PCNET32_NAPI
 	/*Set interrupt enable. */
 	lp->a.write_csr(ioaddr, CSR0, CSR0_INTEN);
+#endif
 
 	if (netif_msg_intr(lp))
 		printk(KERN_DEBUG "%s: exiting interrupt, csr0=%#4.4x.\n",
-- 
Don Fry
brazilnut@us.ibm.com
