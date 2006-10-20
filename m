From: akpm@osdl.org
Subject: [patch 7/8] subdance: solve host error problem in low performance embedded system when continune down and up
Date: Fri, 20 Oct 2006 14:42:13 -0700
Message-ID: <200610202142.k9KLgDHx003732@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@osdl.org, jesse@icplus.com.tw
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:24964 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S2992754AbWJTVnC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Oct 2006 17:43:02 -0400
To: jeff@garzik.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jesse Huang <jesse@icplus.com.tw>

Solve host error problem in low performance embedded system when continune
down and up.  It will cause IP100A DMA TargetAbort.  So we need more safe
process to up and down IP100A with wait hardware completely stop and software
cur_tx/ dirty_tx/cur_task/last_tx be clear.

Signed-off-by: Jesse Huang <jesse@icplus.com.tw>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 drivers/net/sundance.c |   26 +++++++++++++++++++++++---
 1 files changed, 23 insertions(+), 3 deletions(-)

diff -puN drivers/net/sundance.c~sundance-solve-host-error-problem-in-low-performance-embedded drivers/net/sundance.c
--- a/drivers/net/sundance.c~sundance-solve-host-error-problem-in-low-performance-embedded
+++ a/drivers/net/sundance.c
@@ -1643,6 +1643,14 @@ static int netdev_close(struct net_devic
 	struct sk_buff *skb;
 	int i;
 
+	/* Wait and kill tasklet */
+	tasklet_kill(&np->rx_tasklet);
+	tasklet_kill(&np->tx_tasklet);
+	np->cur_tx = 0;
+	np->dirty_tx = 0;
+	np->cur_task = 0;
+	np->last_tx = 0;
+
 	netif_stop_queue(dev);
 
 	if (netif_msg_ifdown(np)) {
@@ -1663,9 +1671,20 @@ static int netdev_close(struct net_devic
 	/* Stop the chip's Tx and Rx processes. */
 	iowrite16(TxDisable | RxDisable | StatsDisable, ioaddr + MACCtrl1);
 
-	/* Wait and kill tasklet */
-	tasklet_kill(&np->rx_tasklet);
-	tasklet_kill(&np->tx_tasklet);
+    	for (i = 2000; i > 0; i--) {
+ 		if ((ioread32(ioaddr + DMACtrl) & 0xc000) == 0)
+			break;
+		mdelay(1);
+    	}
+
+    	iowrite16(GlobalReset | DMAReset | FIFOReset | NetworkReset,
+			ioaddr +ASICCtrl + 2);
+
+    	for (i = 2000; i > 0; i--) {
+ 		if ((ioread16(ioaddr + ASICCtrl +2) & ResetBusy) == 0)
+			break;
+		mdelay(1);
+    	}
 
 #ifdef __i386__
 	if (netif_msg_hw(np)) {
@@ -1703,6 +1722,7 @@ static int netdev_close(struct net_devic
 		}
 	}
 	for (i = 0; i < TX_RING_SIZE; i++) {
+		np->tx_ring[i].next_desc = 0;
 		skb = np->tx_skbuff[i];
 		if (skb) {
 			pci_unmap_single(np->pci_dev,
_
