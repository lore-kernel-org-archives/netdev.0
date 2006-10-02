From: Jesse Huang <jesse@icplus.com.tw>
Subject: [PATCH 2/5] Fix TX Pause bug (reset_tx, intr_handler)
Date: Mon, 02 Oct 2006 14:24:36 -0400
Message-ID: <1159813476.2576.2.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from msr46.hinet.net ([168.95.4.146]:27591 "EHLO msr46.hinet.net")
	by vger.kernel.org with ESMTP id S932660AbWJBGjW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Oct 2006 02:39:22 -0400
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	akpm@osdl.org, jgarzik@pobox.com, jesse@icplus.com.tw
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jesse Huang <jesse@icplus.com.tw>

Change Logs:
Fix TX Pause bug (reset_tx, intr_handler)

Signed-off-by: Jesse Huang <jesse@icplus.com.tw>
---

 drivers/net/sundance.c |   16 ++++++++++++++--
 1 files changed, 14 insertions(+), 2 deletions(-)

e146d4c423de9c2e9d55fbf9c6b3abbee14ce9ac
diff --git a/drivers/net/sundance.c b/drivers/net/sundance.c
index a5dd1c3..11ca31e 100755
--- a/drivers/net/sundance.c
+++ b/drivers/net/sundance.c
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
-- 
1.3.GIT



