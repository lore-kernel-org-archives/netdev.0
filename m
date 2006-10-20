From: akpm@osdl.org
Subject: [patch 6/8] subdance: correct initial and close hardware step.
Date: Fri, 20 Oct 2006 14:42:13 -0700
Message-ID: <200610202142.k9KLgDSI003729@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@osdl.org, jesse@icplus.com.tw
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:26756 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S2992760AbWJTVnI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Oct 2006 17:43:08 -0400
To: jeff@garzik.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jesse Huang <jesse@icplus.com.tw>

Correct initial and close hardware step.  In some embedded system down and up
IP100A will cause DMA crash.  We add some for safe down and up IP100A.

Signed-off-by: Jesse Huang <jesse@icplus.com.tw>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 drivers/net/sundance.c |    8 ++++++++
 1 files changed, 8 insertions(+)

diff -puN drivers/net/sundance.c~sundance-correct-initial-and-close-hardware-step drivers/net/sundance.c
--- a/drivers/net/sundance.c~sundance-correct-initial-and-close-hardware-step
+++ a/drivers/net/sundance.c
@@ -789,6 +789,7 @@ static int netdev_open(struct net_device
 {
 	struct netdev_private *np = netdev_priv(dev);
 	void __iomem *ioaddr = np->base;
+	unsigned long flags;
 	int i;
 
 	/* Do we need to reset the chip??? */
@@ -833,6 +834,10 @@ static int netdev_open(struct net_device
 		iowrite8(0x01, ioaddr + DebugCtrl1);
 	netif_start_queue(dev);
 
+	spin_lock_irqsave(&np->lock, flags);
+	reset_tx(dev);
+	spin_unlock_irqrestore(&np->lock, flags);
+
 	iowrite16 (StatsEnable | RxEnable | TxEnable, ioaddr + MACCtrl1);
 
 	if (netif_msg_ifup(np))
@@ -1652,6 +1657,9 @@ static int netdev_close(struct net_devic
 	/* Disable interrupts by clearing the interrupt mask. */
 	iowrite16(0x0000, ioaddr + IntrEnable);
 
+	/* Disable Rx and Tx DMA for safely release resource */
+	iowrite32(0x500, ioaddr + DMACtrl);
+
 	/* Stop the chip's Tx and Rx processes. */
 	iowrite16(TxDisable | RxDisable | StatsDisable, ioaddr + MACCtrl1);
 
_
