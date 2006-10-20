From: akpm@osdl.org
Subject: [patch 4/8] subdance: fix TX Pause bug (reset_tx, intr_handler)
Date: Fri, 20 Oct 2006 14:42:11 -0700
Message-ID: <200610202142.k9KLgBKA003722@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@osdl.org, jesse@icplus.com.tw
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:28292 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S2992759AbWJTVnJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Oct 2006 17:43:09 -0400
To: jeff@garzik.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jesse Huang <jesse@icplus.com.tw>

Fix TX Pause bug (reset_tx, intr_handler).  When MaxCollisions occurred, need
to re-enable Tx.  But just after re-enable, MaxCollisions maybe occurred again
and with TxStatusOverflow.  This will cause driver can't check new
MaxCollisions to re-enable Tx again, because TxStatusOverflow.  For this
reason, after re-enable Tx, we need to make sure Tx was actually enabled.

Signed-off-by: Jesse Huang <jesse@icplus.com.tw>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 drivers/net/sundance.c |   16 ++++++++++++++--
 1 files changed, 14 insertions(+), 2 deletions(-)

diff -puN drivers/net/sundance.c~sundance-fix-tx-pause-bug-reset_tx-intr_handler drivers/net/sundance.c
--- a/drivers/net/sundance.c~sundance-fix-tx-pause-bug-reset_tx-intr_handler
+++ a/drivers/net/sundance.c
@@ -1079,6 +1079,8 @@ reset_tx (struct net_device *dev)
 
 	/* free all tx skbuff */
 	for (i = 0; i < TX_RING_SIZE; i++) {
+		np->tx_ring[i].next_desc = 0;
+
 		skb = np->tx_skbuff[i];
 		if (skb) {
 			pci_unmap_single(np->pci_dev,
@@ -1094,6 +1096,10 @@ reset_tx (struct net_device *dev)
 	}
 	np->cur_tx = np->dirty_tx = 0;
 	np->cur_task = 0;
+
+	np->last_tx = 0;
+	iowrite8(127, ioaddr + TxDMAPollPeriod);
+
 	iowrite16 (StatsEnable | RxEnable | TxEnable, ioaddr + MACCtrl1);
 	return 0;
 }
@@ -1162,8 +1168,14 @@ static irqreturn_t intr_handler(int irq,
 						sundance_reset(dev, (NetworkReset|FIFOReset|TxReset) << 16);
 						/* No need to reset the Tx pointer here */
 					}
-					/* Restart the Tx. */
-					iowrite16 (TxEnable, ioaddr + MACCtrl1);
+					/* Restart the Tx. Need to make sure tx enabled */
+					i = 10;
+					do {
+						iowrite16(ioread16(ioaddr + MACCtrl1) | TxEnable, ioaddr + MACCtrl1);
+						if (ioread16(ioaddr + MACCtrl1) & TxEnabled)
+							break;
+						mdelay(1);
+					} while (--i);
 				}
 				/* Yup, this is a documentation bug.  It cost me *hours*. */
 				iowrite16 (0, ioaddr + TxStatus);
_
