From: Ayaz Abdulla <aabdulla@nvidia.com>
Subject: [PATCH 4/5] forcedeth: recover error support
Date: Fri, 06 Feb 2009 14:27:27 -0500
Message-ID: <498C8F1F.2060005@nvidia.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070108050803080308020909"
To: Jeff Garzik <jgarzik@pobox.com>,
	Manfred Spraul <manfred@colorfullife.com>,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@osdl.org>, nedev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hqemgate03.nvidia.com ([216.228.112.145]:19161 "EHLO
	hqemgate03.nvidia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753323AbZBFW2p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Feb 2009 17:28:45 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------070108050803080308020909
Content-Type: text/plain; charset=iso-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

This patch adds another type of recoverable error to the driver. It also
modifies the sequence for recovery to include a mac reset and clearing
of interrupts.

Signed-off-by: Ayaz Abdulla <aabdulla@nvidia.com>



--------------070108050803080308020909
Content-Type: text/plain;
 name="patch-forcedeth-recover-error"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-forcedeth-recover-error"

--- old/drivers/net/forcedeth.c	2009-02-06 14:16:30.000000000 -0500
+++ new/drivers/net/forcedeth.c	2009-02-06 14:16:47.000000000 -0500
@@ -102,7 +102,7 @@
 enum {
 	NvRegIrqStatus = 0x000,
 #define NVREG_IRQSTAT_MIIEVENT	0x040
-#define NVREG_IRQSTAT_MASK		0x81ff
+#define NVREG_IRQSTAT_MASK		0x83ff
 	NvRegIrqMask = 0x004,
 #define NVREG_IRQ_RX_ERROR		0x0001
 #define NVREG_IRQ_RX			0x0002
@@ -113,7 +113,7 @@
 #define NVREG_IRQ_LINK			0x0040
 #define NVREG_IRQ_RX_FORCED		0x0080
 #define NVREG_IRQ_TX_FORCED		0x0100
-#define NVREG_IRQ_RECOVER_ERROR		0x8000
+#define NVREG_IRQ_RECOVER_ERROR		0x8200
 #define NVREG_IRQMASK_THROUGHPUT	0x00df
 #define NVREG_IRQMASK_CPU		0x0060
 #define NVREG_IRQ_TX_ALL		(NVREG_IRQ_TX_ERR|NVREG_IRQ_TX_OK|NVREG_IRQ_TX_FORCED)
@@ -4073,13 +4073,15 @@
 
 	if (np->recover_error) {
 		np->recover_error = 0;
-		printk(KERN_INFO "forcedeth: MAC in recoverable error state\n");
+		printk(KERN_INFO "%s: MAC in recoverable error state\n", dev->name);
 		if (netif_running(dev)) {
 			netif_tx_lock_bh(dev);
 			netif_addr_lock(dev);
 			spin_lock(&np->lock);
 			/* stop engines */
 			nv_stop_rxtx(dev);
+			if (np->driver_data & DEV_HAS_POWER_CNTRL)
+				nv_mac_reset(dev);
 			nv_txrx_reset(dev);
 			/* drain rx queue */
 			nv_drain_rxtx(dev);
@@ -4097,6 +4099,11 @@
 			pci_push(base);
 			writel(NVREG_TXRXCTL_KICK|np->txrxctl_bits, get_hwbase(dev) + NvRegTxRxControl);
 			pci_push(base);
+			/* clear interrupts */
+			if (!(np->msi_flags & NV_MSI_X_ENABLED))
+				writel(NVREG_IRQSTAT_MASK, base + NvRegIrqStatus);
+			else
+				writel(NVREG_IRQSTAT_MASK, base + NvRegMSIXIrqStatus);
 
 			/* restart rx engine */
 			nv_start_rxtx(dev);

--------------070108050803080308020909--
