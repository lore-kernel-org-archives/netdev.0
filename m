From: Kulikov Vasiliy <segooon@gmail.com>
Subject: [PATCH] hamachi: Use the instance of net_device_stats from net_device.
Date: Mon,  5 Jul 2010 16:13:41 +0400
Message-ID: <1278332023-16524-1-git-send-email-segooon@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Joe Perches <joe@perches.com>, Jiri Pirko <jpirko@redhat.com>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Kernel Janitors <kernel-janitors@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since net_device has an instance of net_device_stats,
we can remove the instance of this from the adapter structure.

Signed-off-by: Kulikov Vasiliy <segooon@gmail.com>
---
 drivers/net/hamachi.c |   63 ++++++++++++++++++++++++++++--------------------
 1 files changed, 37 insertions(+), 26 deletions(-)

diff --git a/drivers/net/hamachi.c b/drivers/net/hamachi.c
index 61f2b1c..49aac70 100644
--- a/drivers/net/hamachi.c
+++ b/drivers/net/hamachi.c
@@ -492,7 +492,6 @@ struct hamachi_private {
 	struct sk_buff* tx_skbuff[TX_RING_SIZE];
 	dma_addr_t tx_ring_dma;
 	dma_addr_t rx_ring_dma;
-	struct net_device_stats stats;
 	struct timer_list timer;		/* Media selection timer. */
 	/* Frequently used and paired value: keep adjacent for cache effect. */
 	spinlock_t lock;
@@ -1036,7 +1035,7 @@ static inline int hamachi_tx(struct net_device *dev)
 		if (entry >= TX_RING_SIZE-1)
 			hmp->tx_ring[TX_RING_SIZE-1].status_n_length |=
 				cpu_to_le32(DescEndRing);
-		hmp->stats.tx_packets++;
+		dev->stats.tx_packets++;
 	}
 
 	return 0;
@@ -1167,7 +1166,7 @@ static void hamachi_tx_timeout(struct net_device *dev)
 
 	/* Trigger an immediate transmit demand. */
 	dev->trans_start = jiffies; /* prevent tx timeout */
-	hmp->stats.tx_errors++;
+	dev->stats.tx_errors++;
 
 	/* Restart the chip's Tx/Rx processes . */
 	writew(0x0002, ioaddr + TxCmd); /* STOP Tx */
@@ -1434,7 +1433,7 @@ static irqreturn_t hamachi_interrupt(int irq, void *dev_instance)
 					if (entry >= TX_RING_SIZE-1)
 						hmp->tx_ring[TX_RING_SIZE-1].status_n_length |=
 							cpu_to_le32(DescEndRing);
-					hmp->stats.tx_packets++;
+					dev->stats.tx_packets++;
 				}
 				if (hmp->cur_tx - hmp->dirty_tx < TX_RING_SIZE - 4){
 					/* The ring is no longer full */
@@ -1525,18 +1524,22 @@ static int hamachi_rx(struct net_device *dev)
 				   le32_to_cpu(hmp->rx_ring[(hmp->cur_rx+1) % RX_RING_SIZE].status_n_length) & 0xffff0000,
 				   le32_to_cpu(hmp->rx_ring[(hmp->cur_rx+1) % RX_RING_SIZE].status_n_length) & 0x0000ffff,
 				   le32_to_cpu(hmp->rx_ring[(hmp->cur_rx-1) % RX_RING_SIZE].status_n_length));
-			hmp->stats.rx_length_errors++;
+			dev->stats.rx_length_errors++;
 		} /* else  Omit for prototype errata??? */
 		if (frame_status & 0x00380000) {
 			/* There was an error. */
 			if (hamachi_debug > 2)
 				printk(KERN_DEBUG "  hamachi_rx() Rx error was %8.8x.\n",
 					   frame_status);
-			hmp->stats.rx_errors++;
-			if (frame_status & 0x00600000) hmp->stats.rx_length_errors++;
-			if (frame_status & 0x00080000) hmp->stats.rx_frame_errors++;
-			if (frame_status & 0x00100000) hmp->stats.rx_crc_errors++;
-			if (frame_status < 0) hmp->stats.rx_dropped++;
+			dev->stats.rx_errors++;
+			if (frame_status & 0x00600000)
+				dev->stats.rx_length_errors++;
+			if (frame_status & 0x00080000)
+				dev->stats.rx_frame_errors++;
+			if (frame_status & 0x00100000)
+				dev->stats.rx_crc_errors++;
+			if (frame_status < 0)
+				dev->stats.rx_dropped++;
 		} else {
 			struct sk_buff *skb;
 			/* Omit CRC */
@@ -1654,7 +1657,7 @@ static int hamachi_rx(struct net_device *dev)
 #endif  /* RX_CHECKSUM */
 
 			netif_rx(skb);
-			hmp->stats.rx_packets++;
+			dev->stats.rx_packets++;
 		}
 		entry = (++hmp->cur_rx) % RX_RING_SIZE;
 	}
@@ -1724,9 +1727,9 @@ static void hamachi_error(struct net_device *dev, int intr_status)
 		       dev->name, intr_status);
 	/* Hmmmmm, it's not clear how to recover from PCI faults. */
 	if (intr_status & (IntrTxPCIErr | IntrTxPCIFault))
-		hmp->stats.tx_fifo_errors++;
+		dev->stats.tx_fifo_errors++;
 	if (intr_status & (IntrRxPCIErr | IntrRxPCIFault))
-		hmp->stats.rx_fifo_errors++;
+		dev->stats.rx_fifo_errors++;
 }
 
 static int hamachi_close(struct net_device *dev)
@@ -1828,19 +1831,27 @@ static struct net_device_stats *hamachi_get_stats(struct net_device *dev)
            so I think I'll comment it out here and see if better things
            happen.
         */
-	/* hmp->stats.tx_packets	= readl(ioaddr + 0x000); */
-
-	hmp->stats.rx_bytes = readl(ioaddr + 0x330); /* Total Uni+Brd+Multi */
-	hmp->stats.tx_bytes = readl(ioaddr + 0x3B0); /* Total Uni+Brd+Multi */
-	hmp->stats.multicast		= readl(ioaddr + 0x320); /* Multicast Rx */
-
-	hmp->stats.rx_length_errors	= readl(ioaddr + 0x368); /* Over+Undersized */
-	hmp->stats.rx_over_errors	= readl(ioaddr + 0x35C); /* Jabber */
-	hmp->stats.rx_crc_errors	= readl(ioaddr + 0x360); /* Jabber */
-	hmp->stats.rx_frame_errors	= readl(ioaddr + 0x364); /* Symbol Errs */
-	hmp->stats.rx_missed_errors	= readl(ioaddr + 0x36C); /* Dropped */
-
-	return &hmp->stats;
+	/* dev->stats.tx_packets	= readl(ioaddr + 0x000); */
+
+	/* Total Uni+Brd+Multi */
+	dev->stats.rx_bytes = readl(ioaddr + 0x330);
+	/* Total Uni+Brd+Multi */
+	dev->stats.tx_bytes = readl(ioaddr + 0x3B0);
+	/* Multicast Rx */
+	dev->stats.multicast = readl(ioaddr + 0x320);
+
+	/* Over+Undersized */
+	dev->stats.rx_length_errors = readl(ioaddr + 0x368);
+	/* Jabber */
+	dev->stats.rx_over_errors = readl(ioaddr + 0x35C);
+	/* Jabber */
+	dev->stats.rx_crc_errors = readl(ioaddr + 0x360);
+	/* Symbol Errs */
+	dev->stats.rx_frame_errors = readl(ioaddr + 0x364);
+	/* Dropped */
+	dev->stats.rx_missed_errors = readl(ioaddr + 0x36C);
+
+	return &dev->stats;
 }
 
 static void set_rx_mode(struct net_device *dev)
-- 
1.7.0.4
