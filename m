From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH] 2.6.3-rc1-mm1 - drivers/net/r8169.c - Rx overflow
Date: Wed, 11 Feb 2004 00:21:42 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040211002142.A32631@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Neuffer <neuffer@neuffer.info>, Jeff Garzik <jgarzik@pobox.com>,
        akpm@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Please test/apply/cc: netdev on answers.

Rx wrap bug:
- rtl8169_rx_interrupt() can wrap and process an Rx descriptor that it has
  invalidated a few iterations before. The patch limits the number of
  allowed descriptors between two invocations of the Rx refill function;
- rtl8169_rx_interrupt() now looks similar to rtl8169_tx_interrupt as it
  helps when something goes wrong.


 drivers/net/r8169.c |   25 ++++++++++++++++---------
 1 files changed, 16 insertions(+), 9 deletions(-)

diff -puN drivers/net/r8169.c~r8169-rx-wrap-bug drivers/net/r8169.c
--- linux-2.6.3-rc1-mm1/drivers/net/r8169.c~r8169-rx-wrap-bug	2004-02-11 00:06:11.000000000 +0100
+++ linux-2.6.3-rc1-mm1-fr/drivers/net/r8169.c	2004-02-11 00:06:11.000000000 +0100
@@ -1402,17 +1402,22 @@ static void
 rtl8169_rx_interrupt(struct net_device *dev, struct rtl8169_private *tp,
 		     void *ioaddr)
 {
-	int cur_rx, delta;
+	unsigned long cur_rx, rx_left;
+	int delta;
 
 	assert(dev != NULL);
 	assert(tp != NULL);
 	assert(ioaddr != NULL);
 
-	cur_rx = tp->cur_rx % NUM_RX_DESC;
+	cur_rx = tp->cur_rx;
+	rx_left = NUM_RX_DESC + tp->dirty_rx - cur_rx;
 
-	while (!(le32_to_cpu(tp->RxDescArray[cur_rx].status) & OWNbit)) {
-		u32 status = le32_to_cpu(tp->RxDescArray[cur_rx].status);
+	while (rx_left > 0) {
+		int entry = cur_rx % NUM_RX_DESC;
+		u32 status = le32_to_cpu(tp->RxDescArray[entry].status);
 
+		if (status & OWNbit)
+			break;
 		if (status & RxRES) {
 			printk(KERN_INFO "%s: Rx ERROR!!!\n", dev->name);
 			tp->stats.rx_errors++;
@@ -1421,8 +1426,8 @@ rtl8169_rx_interrupt(struct net_device *
 			if (status & RxCRC)
 				tp->stats.rx_crc_errors++;
 		} else {
-			struct RxDesc *desc = tp->RxDescArray + cur_rx;
-			struct sk_buff *skb = tp->Rx_skbuff[cur_rx];
+			struct RxDesc *desc = tp->RxDescArray + entry;
+			struct sk_buff *skb = tp->Rx_skbuff[entry];
 			int pkt_size = (status & 0x00001FFF) - 4;
 
 			pci_dma_sync_single(tp->pci_dev,
@@ -1434,7 +1439,7 @@ rtl8169_rx_interrupt(struct net_device *
 						 le32_to_cpu(desc->buf_addr),
 						 RX_BUF_SIZE,
 						 PCI_DMA_FROMDEVICE);
-				tp->Rx_skbuff[cur_rx] = NULL;
+				tp->Rx_skbuff[entry] = NULL;
 			}
 
 			skb_put(skb, pkt_size);
@@ -1446,10 +1451,12 @@ rtl8169_rx_interrupt(struct net_device *
 			tp->stats.rx_packets++;
 		}
 		
-		tp->cur_rx++; 
-		cur_rx = tp->cur_rx % NUM_RX_DESC;
+		cur_rx++; 
+		rx_left--;
 	}
 
+	tp->cur_rx = cur_rx;
+
 	delta = rtl8169_rx_fill(tp, dev, tp->dirty_rx, tp->cur_rx);
 	if (delta > 0)
 		tp->dirty_rx += delta;

_
