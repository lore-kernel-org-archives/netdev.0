From: Kulikov Vasiliy <segooon@gmail.com>
Subject: [PATCH] starfire: Use the instance of net_device_stats from net_device.
Date: Mon,  5 Jul 2010 16:14:34 +0400
Message-ID: <1278332077-18431-1-git-send-email-segooon@gmail.com>
Cc: Ion Badulescu <ionut@badula.org>,
	"David S. Miller" <davem@davemloft.net>,
	Joe Perches <joe@perches.com>, Jiri Pirko <jpirko@redhat.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Kernel Janitors <kernel-janitors@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since net_device has an instance of net_device_stats,
we can remove the instance of this from the adapter structure.

Signed-off-by: Kulikov Vasiliy <segooon@gmail.com>
---
 drivers/net/starfire.c |   47 +++++++++++++++++++++++------------------------
 1 files changed, 23 insertions(+), 24 deletions(-)

diff --git a/drivers/net/starfire.c b/drivers/net/starfire.c
index 74b7ae7..a42b687 100644
--- a/drivers/net/starfire.c
+++ b/drivers/net/starfire.c
@@ -562,7 +562,6 @@ struct netdev_private {
 	unsigned int tx_done;
 	struct napi_struct napi;
 	struct net_device *dev;
-	struct net_device_stats stats;
 	struct pci_dev *pci_dev;
 #ifdef VLAN_SUPPORT
 	struct vlan_group *vlgrp;
@@ -1174,7 +1173,7 @@ static void tx_timeout(struct net_device *dev)
 	/* Trigger an immediate transmit demand. */
 
 	dev->trans_start = jiffies; /* prevent tx timeout */
-	np->stats.tx_errors++;
+	dev->stats.tx_errors++;
 	netif_wake_queue(dev);
 }
 
@@ -1265,7 +1264,7 @@ static netdev_tx_t start_tx(struct sk_buff *skb, struct net_device *dev)
 			}
 			if (skb->ip_summed == CHECKSUM_PARTIAL) {
 				status |= TxCalTCP;
-				np->stats.tx_compressed++;
+				dev->stats.tx_compressed++;
 			}
 			status |= skb_first_frag_len(skb) | (skb_num_frags(skb) << 16);
 
@@ -1374,7 +1373,7 @@ static irqreturn_t intr_handler(int irq, void *dev_instance)
 				printk(KERN_DEBUG "%s: Tx completion #%d entry %d is %#8.8x.\n",
 				       dev->name, np->dirty_tx, np->tx_done, tx_status);
 			if ((tx_status & 0xe0000000) == 0xa0000000) {
-				np->stats.tx_packets++;
+				dev->stats.tx_packets++;
 			} else if ((tx_status & 0xe0000000) == 0x80000000) {
 				u16 entry = (tx_status & 0x7fff) / sizeof(starfire_tx_desc);
 				struct sk_buff *skb = np->tx_info[entry].skb;
@@ -1462,9 +1461,9 @@ static int __netdev_rx(struct net_device *dev, int *quota)
 			/* There was an error. */
 			if (debug > 2)
 				printk(KERN_DEBUG "  netdev_rx() Rx error was %#8.8x.\n", desc_status);
-			np->stats.rx_errors++;
+			dev->stats.rx_errors++;
 			if (desc_status & RxFIFOErr)
-				np->stats.rx_fifo_errors++;
+				dev->stats.rx_fifo_errors++;
 			goto next_rx;
 		}
 
@@ -1515,7 +1514,7 @@ static int __netdev_rx(struct net_device *dev, int *quota)
 #endif
 		if (le16_to_cpu(desc->status2) & 0x0100) {
 			skb->ip_summed = CHECKSUM_UNNECESSARY;
-			np->stats.rx_compressed++;
+			dev->stats.rx_compressed++;
 		}
 		/*
 		 * This feature doesn't seem to be working, at least
@@ -1547,7 +1546,7 @@ static int __netdev_rx(struct net_device *dev, int *quota)
 		} else
 #endif /* VLAN_SUPPORT */
 			netif_receive_skb(skb);
-		np->stats.rx_packets++;
+		dev->stats.rx_packets++;
 
 	next_rx:
 		np->cur_rx++;
@@ -1717,12 +1716,12 @@ static void netdev_error(struct net_device *dev, int intr_status)
 			printk(KERN_WARNING "%s: PCI Tx underflow -- adapter is probably malfunctioning\n", dev->name);
 	}
 	if (intr_status & IntrRxGFPDead) {
-		np->stats.rx_fifo_errors++;
-		np->stats.rx_errors++;
+		dev->stats.rx_fifo_errors++;
+		dev->stats.rx_errors++;
 	}
 	if (intr_status & (IntrNoTxCsum | IntrDMAErr)) {
-		np->stats.tx_fifo_errors++;
-		np->stats.tx_errors++;
+		dev->stats.tx_fifo_errors++;
+		dev->stats.tx_errors++;
 	}
 	if ((intr_status & ~(IntrNormalMask | IntrAbnormalSummary | IntrLinkChange | IntrStatsMax | IntrTxDataLow | IntrRxGFPDead | IntrNoTxCsum | IntrPCIPad)) && debug)
 		printk(KERN_ERR "%s: Something Wicked happened! %#8.8x.\n",
@@ -1736,24 +1735,24 @@ static struct net_device_stats *get_stats(struct net_device *dev)
 	void __iomem *ioaddr = np->base;
 
 	/* This adapter architecture needs no SMP locks. */
-	np->stats.tx_bytes = readl(ioaddr + 0x57010);
-	np->stats.rx_bytes = readl(ioaddr + 0x57044);
-	np->stats.tx_packets = readl(ioaddr + 0x57000);
-	np->stats.tx_aborted_errors =
+	dev->stats.tx_bytes = readl(ioaddr + 0x57010);
+	dev->stats.rx_bytes = readl(ioaddr + 0x57044);
+	dev->stats.tx_packets = readl(ioaddr + 0x57000);
+	dev->stats.tx_aborted_errors =
 		readl(ioaddr + 0x57024) + readl(ioaddr + 0x57028);
-	np->stats.tx_window_errors = readl(ioaddr + 0x57018);
-	np->stats.collisions =
+	dev->stats.tx_window_errors = readl(ioaddr + 0x57018);
+	dev->stats.collisions =
 		readl(ioaddr + 0x57004) + readl(ioaddr + 0x57008);
 
 	/* The chip only need report frame silently dropped. */
-	np->stats.rx_dropped += readw(ioaddr + RxDMAStatus);
+	dev->stats.rx_dropped += readw(ioaddr + RxDMAStatus);
 	writew(0, ioaddr + RxDMAStatus);
-	np->stats.rx_crc_errors = readl(ioaddr + 0x5703C);
-	np->stats.rx_frame_errors = readl(ioaddr + 0x57040);
-	np->stats.rx_length_errors = readl(ioaddr + 0x57058);
-	np->stats.rx_missed_errors = readl(ioaddr + 0x5707C);
+	dev->stats.rx_crc_errors = readl(ioaddr + 0x5703C);
+	dev->stats.rx_frame_errors = readl(ioaddr + 0x57040);
+	dev->stats.rx_length_errors = readl(ioaddr + 0x57058);
+	dev->stats.rx_missed_errors = readl(ioaddr + 0x5707C);
 
-	return &np->stats;
+	return &dev->stats;
 }
 
 
-- 
1.7.0.4
