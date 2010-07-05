From: Kulikov Vasiliy <segooon@gmail.com>
Subject: [PATCH] ns83820: Use the instance of net_device_stats from net_device.
Date: Mon,  5 Jul 2010 16:14:28 +0400
Message-ID: <1278332071-17865-1-git-send-email-segooon@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Tejun Heo <tj@kernel.org>, Jiri Pirko <jpirko@redhat.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Kernel Janitors <kernel-janitors@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since net_device has an instance of net_device_stats,
we can remove the instance of this from the adapter structure.

Signed-off-by: Kulikov Vasiliy <segooon@gmail.com>
---
 drivers/net/ns83820.c |   44 ++++++++++++++++++++++----------------------
 1 files changed, 22 insertions(+), 22 deletions(-)

diff --git a/drivers/net/ns83820.c b/drivers/net/ns83820.c
index e88e97c..5a3488f 100644
--- a/drivers/net/ns83820.c
+++ b/drivers/net/ns83820.c
@@ -424,7 +424,6 @@ struct rx_info {
 
 
 struct ns83820 {
-	struct net_device_stats	stats;
 	u8			__iomem *base;
 
 	struct pci_dev		*pci_dev;
@@ -918,9 +917,9 @@ static void rx_irq(struct net_device *ndev)
 			if (unlikely(!skb))
 				goto netdev_mangle_me_harder_failed;
 			if (cmdsts & CMDSTS_DEST_MULTI)
-				dev->stats.multicast ++;
-			dev->stats.rx_packets ++;
-			dev->stats.rx_bytes += len;
+				ndev->stats.multicast++;
+			ndev->stats.rx_packets++;
+			ndev->stats.rx_bytes += len;
 			if ((extsts & 0x002a0000) && !(extsts & 0x00540000)) {
 				skb->ip_summed = CHECKSUM_UNNECESSARY;
 			} else {
@@ -940,7 +939,7 @@ static void rx_irq(struct net_device *ndev)
 #endif
 			if (NET_RX_DROP == rx_rc) {
 netdev_mangle_me_harder_failed:
-				dev->stats.rx_dropped ++;
+				ndev->stats.rx_dropped++;
 			}
 		} else {
 			kfree_skb(skb);
@@ -1008,11 +1007,11 @@ static void do_tx_done(struct net_device *ndev)
 		dma_addr_t addr;
 
 		if (cmdsts & CMDSTS_ERR)
-			dev->stats.tx_errors ++;
+			ndev->stats.tx_errors++;
 		if (cmdsts & CMDSTS_OK)
-			dev->stats.tx_packets ++;
+			ndev->stats.tx_packets++;
 		if (cmdsts & CMDSTS_OK)
-			dev->stats.tx_bytes += cmdsts & 0xffff;
+			ndev->stats.tx_bytes += cmdsts & 0xffff;
 
 		dprintk("tx_done_idx=%d free_idx=%d cmdsts=%08x\n",
 			tx_done_idx, dev->tx_free_idx, cmdsts);
@@ -1212,20 +1211,21 @@ again:
 
 static void ns83820_update_stats(struct ns83820 *dev)
 {
+	struct net_device *ndev = dev->ndev;
 	u8 __iomem *base = dev->base;
 
 	/* the DP83820 will freeze counters, so we need to read all of them */
-	dev->stats.rx_errors		+= readl(base + 0x60) & 0xffff;
-	dev->stats.rx_crc_errors	+= readl(base + 0x64) & 0xffff;
-	dev->stats.rx_missed_errors	+= readl(base + 0x68) & 0xffff;
-	dev->stats.rx_frame_errors	+= readl(base + 0x6c) & 0xffff;
-	/*dev->stats.rx_symbol_errors +=*/ readl(base + 0x70);
-	dev->stats.rx_length_errors	+= readl(base + 0x74) & 0xffff;
-	dev->stats.rx_length_errors	+= readl(base + 0x78) & 0xffff;
-	/*dev->stats.rx_badopcode_errors += */ readl(base + 0x7c);
-	/*dev->stats.rx_pause_count += */  readl(base + 0x80);
-	/*dev->stats.tx_pause_count += */  readl(base + 0x84);
-	dev->stats.tx_carrier_errors	+= readl(base + 0x88) & 0xff;
+	ndev->stats.rx_errors		+= readl(base + 0x60) & 0xffff;
+	ndev->stats.rx_crc_errors	+= readl(base + 0x64) & 0xffff;
+	ndev->stats.rx_missed_errors	+= readl(base + 0x68) & 0xffff;
+	ndev->stats.rx_frame_errors	+= readl(base + 0x6c) & 0xffff;
+	/*ndev->stats.rx_symbol_errors +=*/ readl(base + 0x70);
+	ndev->stats.rx_length_errors	+= readl(base + 0x74) & 0xffff;
+	ndev->stats.rx_length_errors	+= readl(base + 0x78) & 0xffff;
+	/*ndev->stats.rx_badopcode_errors += */ readl(base + 0x7c);
+	/*ndev->stats.rx_pause_count += */  readl(base + 0x80);
+	/*ndev->stats.tx_pause_count += */  readl(base + 0x84);
+	ndev->stats.tx_carrier_errors	+= readl(base + 0x88) & 0xff;
 }
 
 static struct net_device_stats *ns83820_get_stats(struct net_device *ndev)
@@ -1237,7 +1237,7 @@ static struct net_device_stats *ns83820_get_stats(struct net_device *ndev)
 	ns83820_update_stats(dev);
 	spin_unlock_irq(&dev->misc_lock);
 
-	return &dev->stats;
+	return &ndev->stats;
 }
 
 /* Let ethtool retrieve info */
@@ -1464,12 +1464,12 @@ static void ns83820_do_isr(struct net_device *ndev, u32 isr)
 
 	if (unlikely(ISR_RXSOVR & isr)) {
 		//printk("overrun: rxsovr\n");
-		dev->stats.rx_fifo_errors ++;
+		ndev->stats.rx_fifo_errors++;
 	}
 
 	if (unlikely(ISR_RXORN & isr)) {
 		//printk("overrun: rxorn\n");
-		dev->stats.rx_fifo_errors ++;
+		ndev->stats.rx_fifo_errors++;
 	}
 
 	if ((ISR_RXRCMP & isr) && dev->rx_info.up)
-- 
1.7.0.4
