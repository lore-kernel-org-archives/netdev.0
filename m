From: Tino Reichardt <milky-kernel@mcmilk.de>
Subject: [PATCH net-next v3 04/07] via-rhine: Support for byte queue limits
Date: Sun, 20 Oct 2013 21:23:08 +0200
Message-ID: <1382296991-20289-5-git-send-email-milky-kernel@mcmilk.de>
References: <1382296991-20289-1-git-send-email-milky-kernel@mcmilk.de>
To: netdev@vger.kernel.org, Roger Luethi <rl@hellgate.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lotte.svc-box.de ([80.252.109.10]:49850 "EHLO lotte.svc-box.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751496Ab3JTTXX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 20 Oct 2013 15:23:23 -0400
In-Reply-To: <1382296991-20289-1-git-send-email-milky-kernel@mcmilk.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changes to via-rhine driver to use byte queue limits.


Signed-off-by: Tino Reichardt <milky-kernel@mcmilk.de>

---
 drivers/net/ethernet/via/via-rhine.c | 17 +++++++++++++++++
 1 file changed, 17 insertions(+)

diff --git a/drivers/net/ethernet/via/via-rhine.c b/drivers/net/ethernet/via/via-rhine.c
index bdf697b..067b4ab 100644
--- a/drivers/net/ethernet/via/via-rhine.c
+++ b/drivers/net/ethernet/via/via-rhine.c
@@ -53,6 +53,8 @@ static int rx_copybreak = 1518;
 static int rx_copybreak;
 #endif
 
+static bool bql_disable;
+
 /* Work-around for broken BIOSes: they are unable to get the chip back out of
    power state D3 so PXE booting fails. bootparam(7): via-rhine.avoid_D3=1 */
 static bool avoid_D3;
@@ -128,9 +130,11 @@ MODULE_DESCRIPTION("VIA Rhine PCI Fast Ethernet driver");
 MODULE_LICENSE("GPL");
 
 module_param(debug, int, 0);
+module_param(bql_disable, bool, 0);
 module_param(rx_copybreak, int, 0);
 module_param(avoid_D3, bool, 0);
 MODULE_PARM_DESC(debug, "VIA Rhine debug message flags");
+MODULE_PARM_DESC(bql_disable, "Disable Byte Queue Limits functionality (default: false)");
 MODULE_PARM_DESC(rx_copybreak, "VIA Rhine copy breakpoint for copy-only-tiny-frames");
 MODULE_PARM_DESC(avoid_D3, "Avoid power state D3 (work-around for broken BIOSes)");
 
@@ -1220,6 +1224,8 @@ static void alloc_tbufs(struct net_device* dev)
 	}
 	rp->tx_ring[i-1].next_desc = cpu_to_le32(rp->tx_ring_dma);
 
+	if (unlikely(bql_disable))
+		netdev_reset_queue(dev);
 }
 
 static void free_tbufs(struct net_device* dev)
@@ -1719,6 +1725,8 @@ static netdev_tx_t rhine_start_tx(struct sk_buff *skb,
 	/* lock eth irq */
 	wmb();
 	rp->tx_ring[entry].tx_status |= cpu_to_le32(DescOwn);
+	if (unlikely(bql_disable))
+		netdev_sent_queue(dev, skb->len);
 	wmb();
 
 	rp->cur_tx++;
@@ -1783,6 +1791,7 @@ static void rhine_tx(struct net_device *dev)
 {
 	struct rhine_private *rp = netdev_priv(dev);
 	int txstatus = 0, entry = rp->dirty_tx % TX_RING_SIZE;
+	unsigned int pkts_compl = 0, bytes_compl = 0;
 
 	/* find and cleanup dirty tx descriptors */
 	while (rp->dirty_tx != rp->cur_tx) {
@@ -1830,10 +1839,18 @@ static void rhine_tx(struct net_device *dev)
 					 rp->tx_skbuff[entry]->len,
 					 PCI_DMA_TODEVICE);
 		}
+
+		bytes_compl += rp->tx_skbuff[entry]->len;
+		pkts_compl++;
 		dev_kfree_skb(rp->tx_skbuff[entry]);
+
 		rp->tx_skbuff[entry] = NULL;
 		entry = (++rp->dirty_tx) % TX_RING_SIZE;
 	}
+
+	if (unlikely(bql_disable))
+		netdev_completed_queue(dev, pkts_compl, bytes_compl);
+
 	if ((rp->cur_tx - rp->dirty_tx) < TX_QUEUE_LEN - 4)
 		netif_wake_queue(dev);
 }
-- 
1.8.4.1
