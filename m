From: Ayaz Abdulla <aabdulla@nvidia.com>
Subject: [PATCH 2/2] forcedeth: add recoverable error support
Date: Mon, 30 Oct 2006 17:32:01 -0500
Message-ID: <45467D61.1030502@nvidia.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040802050101090904020000"
Return-path: <netdev-owner@vger.kernel.org>
Received: from hqemgate01.nvidia.com ([216.228.112.170]:34572 "EHLO
	HQEMGATE01.nvidia.com") by vger.kernel.org with ESMTP
	id S1030569AbWJ3Sl7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Oct 2006 13:41:59 -0500
To: Jeff Garzik <jgarzik@pobox.com>,
	Manfred Spraul <manfred@colorfullife.com>,
	Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------040802050101090904020000
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

This patch adds support to recover from a previously fatal MAC error. In 
the past the MAC would be hung on an internal fatal error. On new 
chipsets, the MAC has the ability to enter a non-fatal state and allow 
the driver to re-init it.

Signed-Off-By: Ayaz Abdulla <aabdulla@nvidia.com>


--------------040802050101090904020000
Content-Type: text/plain;
 name="patch-forcedeth-059-recoverable-error"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-forcedeth-059-recoverable-error"

--- orig-2.6/drivers/net/forcedeth.c	2006-10-30 16:07:05.000000000 -0500
+++ new-2.6/drivers/net/forcedeth.c	2006-10-30 16:23:43.000000000 -0500
@@ -111,6 +111,7 @@
  *	0.56: 22 Mar 2006: Additional ethtool config and moduleparam support.
  *	0.57: 14 May 2006: Mac address set in probe/remove and order corrections.
  *	0.58: 30 Oct 2006: Added support for sideband management unit.
+ *	0.59: 30 Oct 2006: Added support for recoverable error.
  *
  * Known bugs:
  * We suspect that on some hardware no TX done interrupts are generated.
@@ -127,7 +128,7 @@
 #else
 #define DRIVERNAPI
 #endif
-#define FORCEDETH_VERSION		"0.58"
+#define FORCEDETH_VERSION		"0.59"
 #define DRV_NAME			"forcedeth"
 
 #include <linux/module.h>
@@ -180,7 +181,7 @@
 enum {
 	NvRegIrqStatus = 0x000,
 #define NVREG_IRQSTAT_MIIEVENT	0x040
-#define NVREG_IRQSTAT_MASK		0x1ff
+#define NVREG_IRQSTAT_MASK		0x81ff
 	NvRegIrqMask = 0x004,
 #define NVREG_IRQ_RX_ERROR		0x0001
 #define NVREG_IRQ_RX			0x0002
@@ -191,15 +192,16 @@
 #define NVREG_IRQ_LINK			0x0040
 #define NVREG_IRQ_RX_FORCED		0x0080
 #define NVREG_IRQ_TX_FORCED		0x0100
+#define NVREG_IRQ_RECOVER_ERROR		0x8000
 #define NVREG_IRQMASK_THROUGHPUT	0x00df
 #define NVREG_IRQMASK_CPU		0x0040
 #define NVREG_IRQ_TX_ALL		(NVREG_IRQ_TX_ERR|NVREG_IRQ_TX_OK|NVREG_IRQ_TX_FORCED)
 #define NVREG_IRQ_RX_ALL		(NVREG_IRQ_RX_ERROR|NVREG_IRQ_RX|NVREG_IRQ_RX_NOBUF|NVREG_IRQ_RX_FORCED)
-#define NVREG_IRQ_OTHER			(NVREG_IRQ_TIMER|NVREG_IRQ_LINK)
+#define NVREG_IRQ_OTHER			(NVREG_IRQ_TIMER|NVREG_IRQ_LINK|NVREG_IRQ_RECOVER_ERROR)
 
 #define NVREG_IRQ_UNKNOWN	(~(NVREG_IRQ_RX_ERROR|NVREG_IRQ_RX|NVREG_IRQ_RX_NOBUF|NVREG_IRQ_TX_ERR| \
 					NVREG_IRQ_TX_OK|NVREG_IRQ_TIMER|NVREG_IRQ_LINK|NVREG_IRQ_RX_FORCED| \
-					NVREG_IRQ_TX_FORCED))
+					NVREG_IRQ_TX_FORCED|NVREG_IRQ_RECOVER_ERROR))
 
 	NvRegUnknownSetupReg6 = 0x008,
 #define NVREG_UNKSETUP6_VAL		3
@@ -718,6 +720,7 @@
 	unsigned int phy_model;
 	u16 gigabit;
 	int intr_test;
+	int recover_error;
 
 	/* General data: RO fields */
 	dma_addr_t ring_addr;
@@ -2455,6 +2458,23 @@
 			printk(KERN_DEBUG "%s: received irq with unknown events 0x%x. Please report\n",
 						dev->name, events);
 		}
+		if (unlikely(events & NVREG_IRQ_RECOVER_ERROR)) {
+			spin_lock(&np->lock);
+			/* disable interrupts on the nic */
+			if (!(np->msi_flags & NV_MSI_X_ENABLED))
+				writel(0, base + NvRegIrqMask);
+			else
+				writel(np->irqmask, base + NvRegIrqMask);
+			pci_push(base);
+
+			if (!np->in_shutdown) {
+				np->nic_poll_irq = np->irqmask;
+				np->recover_error = 1;
+				mod_timer(&np->nic_poll, jiffies + POLL_WAIT);
+			}
+			spin_unlock(&np->lock);
+			break;
+		}
 #ifdef CONFIG_FORCEDETH_NAPI
 		if (events & NVREG_IRQ_RX_ALL) {
 			netif_rx_schedule(dev);
@@ -2685,6 +2705,20 @@
 			spin_unlock_irqrestore(&np->lock, flags);
 			np->link_timeout = jiffies + LINK_TIMEOUT;
 		}
+		if (events & NVREG_IRQ_RECOVER_ERROR) {
+			spin_lock_irq(&np->lock);
+			/* disable interrupts on the nic */
+			writel(NVREG_IRQ_OTHER, base + NvRegIrqMask);
+			pci_push(base);
+
+			if (!np->in_shutdown) {
+				np->nic_poll_irq |= NVREG_IRQ_OTHER;
+				np->recover_error = 1;
+				mod_timer(&np->nic_poll, jiffies + POLL_WAIT);
+			}
+			spin_unlock_irq(&np->lock);
+			break;
+		}
 		if (events & (NVREG_IRQ_UNKNOWN)) {
 			printk(KERN_DEBUG "%s: received irq with unknown events 0x%x. Please report\n",
 						dev->name, events);
@@ -2914,6 +2948,42 @@
 	}
 	np->nic_poll_irq = 0;
 
+	if (np->recover_error) {
+		np->recover_error = 0;
+		printk(KERN_INFO "forcedeth: MAC in recoverable error state\n");
+		if (netif_running(dev)) {
+			netif_tx_lock_bh(dev);
+			spin_lock(&np->lock);
+			/* stop engines */
+			nv_stop_rx(dev);
+			nv_stop_tx(dev);
+			nv_txrx_reset(dev);
+			/* drain rx queue */
+			nv_drain_rx(dev);
+			nv_drain_tx(dev);
+			/* reinit driver view of the rx queue */
+			set_bufsize(dev);
+			if (nv_init_ring(dev)) {
+				if (!np->in_shutdown)
+					mod_timer(&np->oom_kick, jiffies + OOM_REFILL);
+			}
+			/* reinit nic view of the rx queue */
+			writel(np->rx_buf_sz, base + NvRegOffloadConfig);
+			setup_hw_rings(dev, NV_SETUP_RX_RING | NV_SETUP_TX_RING);
+			writel( ((np->rx_ring_size-1) << NVREG_RINGSZ_RXSHIFT) + ((np->tx_ring_size-1) << NVREG_RINGSZ_TXSHIFT),
+				base + NvRegRingSizes);
+			pci_push(base);
+			writel(NVREG_TXRXCTL_KICK|np->txrxctl_bits, get_hwbase(dev) + NvRegTxRxControl);
+			pci_push(base);
+
+			/* restart rx engine */
+			nv_start_rx(dev);
+			nv_start_tx(dev);
+			spin_unlock(&np->lock);
+			netif_tx_unlock_bh(dev);
+		}
+	}
+
 	/* FIXME: Do we need synchronize_irq(dev->irq) here? */
 
 	writel(mask, base + NvRegIrqMask);

--------------040802050101090904020000--
