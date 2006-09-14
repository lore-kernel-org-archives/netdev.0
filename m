From: Jesse Huang <jesse@icplus.com.tw>
Subject: [PATCH 4/4] IP100A: Solve host error problem in low performance
	embedded system when continune down and up. 2006-08-24
Date: Thu, 14 Sep 2006 10:46:17 -0400
Message-ID: <1158245177.2184.6.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from msr17.hinet.net ([168.95.4.117]:7398 "EHLO msr17.hinet.net")
	by vger.kernel.org with ESMTP id S1750711AbWINDAF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Sep 2006 23:00:05 -0400
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	akpm@osdl.org, jgarzik@pobox.com, jesse@icplus.com.tw
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jesse Huang <jesse@icplus.com.tw>

Change Logs:
   - Solve host error problem in low performance embedded 
     system when continune down and up.

Signed-off-by: Jesse Huang <jesse@icplus.com.tw>

---

 drivers/net/sundance.c |   28 ++++++++++++++++++++++++----
 1 files changed, 24 insertions(+), 4 deletions(-)

b7c2fba3fb7179d18c8b1c4af316c8a14d8ec1b8
diff --git a/drivers/net/sundance.c b/drivers/net/sundance.c
index 04ad4d8..a253924 100755
--- a/drivers/net/sundance.c
+++ b/drivers/net/sundance.c
@@ -1076,7 +1076,7 @@ reset_tx (struct net_device *dev)
 	struct sk_buff *skb;
 	int i;
 	int irq = in_interrupt();
-	
+
 	/* Reset tx logic, TxListPtr will be cleaned */
 	iowrite16 (TxDisable, ioaddr + MACCtrl1);
 	iowrite16 (TxReset | DMAReset | FIFOReset | NetworkReset,
@@ -1647,6 +1647,14 @@ static int netdev_close(struct net_devic
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
@@ -1667,9 +1675,20 @@ static int netdev_close(struct net_devic
 	/* Stop the chip's Tx and Rx processes. */
 	iowrite16(TxDisable | RxDisable | StatsDisable, ioaddr + MACCtrl1);
 
-	/* Wait and kill tasklet */
-	tasklet_kill(&np->rx_tasklet);
-	tasklet_kill(&np->tx_tasklet);
+    	for (i = 2000; i > 0; i--) {
+ 		if ((ioread32(ioaddr + DMACtrl) &0xC000) == 0)
+			break;
+		mdelay(1);
+    	}
+
+    	iowrite16(GlobalReset | DMAReset | FIFOReset | NetworkReset, ioaddr +ASICCtrl + 2);
+
+    	for (i = 2000; i > 0; i--)
+    	{
+ 		if ((ioread16(ioaddr + ASICCtrl +2) &ResetBusy) == 0)
+			break;
+		mdelay(1);
+    	}
 
 #ifdef __i386__
 	if (netif_msg_hw(np)) {
@@ -1707,6 +1726,7 @@ #endif /* __i386__ debugging only */
 		}
 	}
 	for (i = 0; i < TX_RING_SIZE; i++) {
+		np->tx_ring[i].next_desc = 0;
 		skb = np->tx_skbuff[i];
 		if (skb) {
 			pci_unmap_single(np->pci_dev,
-- 
1.3.GIT



