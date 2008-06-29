From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 2/13] r8169: remove non-napi code
Date: Sun, 29 Jun 2008 16:40:54 +0200
Message-ID: <20080629144054.GC1540@electric-eye.fr.zoreil.com>
References: <20080629143817.GA1540@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, akpm@linux-foundation.org,
	Edward Hsu <edward_hsu@realtek.com.tw>,
	Mario Limonciello <mario_limonciello@dell.com>,
	Kasper Sandberg <lkml@metanurb.dk>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:52860 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755226AbYF2OlW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Jun 2008 10:41:22 -0400
Content-Disposition: inline
In-Reply-To: <20080629143817.GA1540@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It will almost unavoidably cause some breakage but it
is long overdue.

The driver identification string has been updated, a
lost tabulation and some unused code have been removed.
Otherwise the code paths should stay the same.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Edward Hsu <edward_hsu@realtek.com.tw>
---
 drivers/net/Kconfig |   16 +------
 drivers/net/r8169.c |  139 +++++++++++++++------------------------------------
 2 files changed, 41 insertions(+), 114 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index d85b9d0..8492591 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -2122,27 +2122,13 @@ config R8169
 	  To compile this driver as a module, choose M here: the module
 	  will be called r8169.  This is recommended.
 
-config R8169_NAPI
-	bool "Use Rx Polling (NAPI) (EXPERIMENTAL)"
-	depends on R8169 && EXPERIMENTAL
-	help
-	  NAPI is a new driver API designed to reduce CPU and interrupt load
-	  when the driver is receiving lots of packets from the card. It is
-	  still somewhat experimental and thus not yet enabled by default.
-
-	  If your estimated Rx load is 10kpps or more, or if the card will be
-	  deployed on potentially unfriendly networks (e.g. in a firewall),
-	  then say Y here.
-
-	  If in doubt, say N.
-
 config R8169_VLAN
 	bool "VLAN support"
 	depends on R8169 && VLAN_8021Q
 	---help---
 	  Say Y here for the r8169 driver to support the functions required
 	  by the kernel 802.1Q code.
-	  
+
 	  If in doubt, say Y.
 
 config SB1250_MAC
diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 9086e81..cfe8829 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -28,13 +28,7 @@
 #include <asm/io.h>
 #include <asm/irq.h>
 
-#ifdef CONFIG_R8169_NAPI
-#define NAPI_SUFFIX	"-NAPI"
-#else
-#define NAPI_SUFFIX	""
-#endif
-
-#define RTL8169_VERSION "2.2LK" NAPI_SUFFIX
+#define RTL8169_VERSION "2.3LK-NAPI"
 #define MODULENAME "r8169"
 #define PFX MODULENAME ": "
 
@@ -57,16 +51,6 @@
 #define TX_BUFFS_AVAIL(tp) \
 	(tp->dirty_tx + NUM_TX_DESC - tp->cur_tx - 1)
 
-#ifdef CONFIG_R8169_NAPI
-#define rtl8169_rx_skb			netif_receive_skb
-#define rtl8169_rx_hwaccel_skb		vlan_hwaccel_receive_skb
-#define rtl8169_rx_quota(count, quota)	min(count, quota)
-#else
-#define rtl8169_rx_skb			netif_rx
-#define rtl8169_rx_hwaccel_skb		vlan_hwaccel_rx
-#define rtl8169_rx_quota(count, quota)	count
-#endif
-
 /* Maximum events (Rx packets, etc.) to handle at each interrupt. */
 static const int max_interrupt_work = 20;
 
@@ -394,9 +378,7 @@ struct rtl8169_private {
 	void __iomem *mmio_addr;	/* memory map physical address */
 	struct pci_dev *pci_dev;	/* Index of PCI device */
 	struct net_device *dev;
-#ifdef CONFIG_R8169_NAPI
 	struct napi_struct napi;
-#endif
 	spinlock_t lock;		/* spin lock flag */
 	u32 msg_enable;
 	int chipset;
@@ -458,10 +440,7 @@ static int rtl8169_rx_interrupt(struct net_device *, struct rtl8169_private *,
 static int rtl8169_change_mtu(struct net_device *dev, int new_mtu);
 static void rtl8169_down(struct net_device *dev);
 static void rtl8169_rx_clear(struct rtl8169_private *tp);
-
-#ifdef CONFIG_R8169_NAPI
 static int rtl8169_poll(struct napi_struct *napi, int budget);
-#endif
 
 static const unsigned int rtl8169_rx_config =
 	(RX_FIFO_THRESH << RxCfgFIFOShift) | (RX_DMA_BURST << RxCfgDMAShift);
@@ -843,10 +822,11 @@ static int rtl8169_rx_vlan_skb(struct rtl8169_private *tp, struct RxDesc *desc,
 			       struct sk_buff *skb)
 {
 	u32 opts2 = le32_to_cpu(desc->opts2);
+	struct vlan_group *vlgrp = tp->vlgrp;
 	int ret;
 
-	if (tp->vlgrp && (opts2 & RxVlanTag)) {
-		rtl8169_rx_hwaccel_skb(skb, tp->vlgrp, swab16(opts2 & 0xffff));
+	if (vlgrp && (opts2 & RxVlanTag)) {
+		vlan_hwaccel_receive_skb(skb, vlgrp, swab16(opts2 & 0xffff));
 		ret = 0;
 	} else
 		ret = -1;
@@ -1764,9 +1744,7 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	dev->change_mtu = rtl8169_change_mtu;
 	dev->set_mac_address = rtl_set_mac_address;
 
-#ifdef CONFIG_R8169_NAPI
 	netif_napi_add(dev, &tp->napi, rtl8169_poll, R8169_NAPI_WEIGHT);
-#endif
 
 #ifdef CONFIG_R8169_VLAN
 	dev->features |= NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
@@ -1887,9 +1865,7 @@ static int rtl8169_open(struct net_device *dev)
 	if (retval < 0)
 		goto err_release_ring_2;
 
-#ifdef CONFIG_R8169_NAPI
 	napi_enable(&tp->napi);
-#endif
 
 	rtl_hw_start(dev);
 
@@ -2197,9 +2173,7 @@ static int rtl8169_change_mtu(struct net_device *dev, int new_mtu)
 	if (ret < 0)
 		goto out;
 
-#ifdef CONFIG_R8169_NAPI
 	napi_enable(&tp->napi);
-#endif
 
 	rtl_hw_start(dev);
 
@@ -2391,17 +2365,13 @@ static void rtl8169_wait_for_quiescence(struct net_device *dev)
 	synchronize_irq(dev->irq);
 
 	/* Wait for any pending NAPI task to complete */
-#ifdef CONFIG_R8169_NAPI
 	napi_disable(&tp->napi);
-#endif
 
 	rtl8169_irq_mask_and_ack(ioaddr);
 
-#ifdef CONFIG_R8169_NAPI
 	tp->intr_mask = 0xffff;
 	RTL_W16(IntrMask, tp->intr_event);
 	napi_enable(&tp->napi);
-#endif
 }
 
 static void rtl8169_reinit_task(struct work_struct *work)
@@ -2767,7 +2737,7 @@ static int rtl8169_rx_interrupt(struct net_device *dev,
 
 	cur_rx = tp->cur_rx;
 	rx_left = NUM_RX_DESC + tp->dirty_rx - cur_rx;
-	rx_left = rtl8169_rx_quota(rx_left, budget);
+	rx_left = min(rx_left, budget);
 
 	for (; rx_left > 0; rx_left--, cur_rx++) {
 		unsigned int entry = cur_rx % NUM_RX_DESC;
@@ -2829,7 +2799,7 @@ static int rtl8169_rx_interrupt(struct net_device *dev,
 			skb->protocol = eth_type_trans(skb, dev);
 
 			if (rtl8169_rx_vlan_skb(tp, desc, skb) < 0)
-				rtl8169_rx_skb(skb);
+				netif_receive_skb(skb);
 
 			dev->last_rx = jiffies;
 			dev->stats.rx_bytes += pkt_size;
@@ -2869,87 +2839,61 @@ static irqreturn_t rtl8169_interrupt(int irq, void *dev_instance)
 {
 	struct net_device *dev = dev_instance;
 	struct rtl8169_private *tp = netdev_priv(dev);
-	int boguscnt = max_interrupt_work;
 	void __iomem *ioaddr = tp->mmio_addr;
-	int status;
 	int handled = 0;
+	int status;
 
-	do {
-		status = RTL_R16(IntrStatus);
+	status = RTL_R16(IntrStatus);
 
-		/* hotplug/major error/no more work/shared irq */
-		if ((status == 0xFFFF) || !status)
-			break;
+	/* hotplug/major error/no more work/shared irq */
+	if ((status == 0xffff) || !status)
+		goto out;
 
-		handled = 1;
+	handled = 1;
 
-		if (unlikely(!netif_running(dev))) {
-			rtl8169_asic_down(ioaddr);
-			goto out;
-		}
+	if (unlikely(!netif_running(dev))) {
+		rtl8169_asic_down(ioaddr);
+		goto out;
+	}
 
-		status &= tp->intr_mask;
-		RTL_W16(IntrStatus,
-			(status & RxFIFOOver) ? (status | RxOverflow) : status);
+	status &= tp->intr_mask;
+	RTL_W16(IntrStatus,
+		(status & RxFIFOOver) ? (status | RxOverflow) : status);
 
-		if (!(status & tp->intr_event))
-			break;
+	if (!(status & tp->intr_event))
+		goto out;
 
-                /* Work around for rx fifo overflow */
-                if (unlikely(status & RxFIFOOver) &&
-		    (tp->mac_version == RTL_GIGA_MAC_VER_11)) {
-			netif_stop_queue(dev);
-			rtl8169_tx_timeout(dev);
-			break;
-		}
+	/* Work around for rx fifo overflow */
+	if (unlikely(status & RxFIFOOver) &&
+	    (tp->mac_version == RTL_GIGA_MAC_VER_11)) {
+		netif_stop_queue(dev);
+		rtl8169_tx_timeout(dev);
+		goto out;
+	}
 
-		if (unlikely(status & SYSErr)) {
-			rtl8169_pcierr_interrupt(dev);
-			break;
-		}
+	if (unlikely(status & SYSErr)) {
+		rtl8169_pcierr_interrupt(dev);
+		goto out;
+	}
 
-		if (status & LinkChg)
-			rtl8169_check_link_status(dev, tp, ioaddr);
+	if (status & LinkChg)
+		rtl8169_check_link_status(dev, tp, ioaddr);
 
-#ifdef CONFIG_R8169_NAPI
-		if (status & tp->napi_event) {
-			RTL_W16(IntrMask, tp->intr_event & ~tp->napi_event);
-			tp->intr_mask = ~tp->napi_event;
+	if (status & tp->napi_event) {
+		RTL_W16(IntrMask, tp->intr_event & ~tp->napi_event);
+		tp->intr_mask = ~tp->napi_event;
 
 		if (likely(netif_rx_schedule_prep(dev, &tp->napi)))
 			__netif_rx_schedule(dev, &tp->napi);
-			else if (netif_msg_intr(tp)) {
-				printk(KERN_INFO "%s: interrupt %04x in poll\n",
-				       dev->name, status);
-			}
-		}
-		break;
-#else
-		/* Rx interrupt */
-		if (status & (RxOK | RxOverflow | RxFIFOOver))
-			rtl8169_rx_interrupt(dev, tp, ioaddr, ~(u32)0);
-
-		/* Tx interrupt */
-		if (status & (TxOK | TxErr))
-			rtl8169_tx_interrupt(dev, tp, ioaddr);
-#endif
-
-		boguscnt--;
-	} while (boguscnt > 0);
-
-	if (boguscnt <= 0) {
-		if (netif_msg_intr(tp) && net_ratelimit() ) {
-			printk(KERN_WARNING
-			       "%s: Too much work at interrupt!\n", dev->name);
+		else if (netif_msg_intr(tp)) {
+			printk(KERN_INFO "%s: interrupt %04x in poll\n",
+			       dev->name, status);
 		}
-		/* Clear all interrupt sources. */
-		RTL_W16(IntrStatus, 0xffff);
 	}
 out:
 	return IRQ_RETVAL(handled);
 }
 
-#ifdef CONFIG_R8169_NAPI
 static int rtl8169_poll(struct napi_struct *napi, int budget)
 {
 	struct rtl8169_private *tp = container_of(napi, struct rtl8169_private, napi);
@@ -2975,7 +2919,6 @@ static int rtl8169_poll(struct napi_struct *napi, int budget)
 
 	return work_done;
 }
-#endif
 
 static void rtl8169_down(struct net_device *dev)
 {
@@ -2987,9 +2930,7 @@ static void rtl8169_down(struct net_device *dev)
 
 	netif_stop_queue(dev);
 
-#ifdef CONFIG_R8169_NAPI
 	napi_disable(&tp->napi);
-#endif
 
 core_down:
 	spin_lock_irq(&tp->lock);
-- 
1.5.3.3

