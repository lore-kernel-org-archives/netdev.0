From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCH] sis900: Allocate rx replacement buffer before rx operation
Date: Fri, 20 Apr 2007 09:54:58 -0400
Message-ID: <20070420135458.GB16191@hmsreliant.homelinux.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, venza@brownhat.org, nhorman@tuxdriver.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:2447 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754052AbXDTNzl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Apr 2007 09:55:41 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hey there-
	The sis900 driver appears to have a bug in which the receive routine
passes the skbuff holding the received frame to the network stack before
refilling the buffer in the rx ring.  If a new skbuff cannot be allocated, the
driver simply leaves a hole in the rx ring, which causes the driver to stop
receiving frames and become non-recoverable without an rmmod/insmod according to
reporters.  This patch reverses that order, attempting to allocate a replacement
buffer first, and receiving the new frame only if one can be allocated.  If no
skbuff can be allocated, the current skbuf in the rx ring is recycled, dropping
the current frame, but keeping the NIC operational.

Thanks & Regards
Neil

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>


 sis900.c |   44 ++++++++++++++++++++------------------------
 1 file changed, 20 insertions(+), 24 deletions(-)


commit b11e33ae6b479f2e7f83b9dc148f0f24d47530bd
Author: Neil Horman <nhorman@redhat.com>
Date:   Mon Feb 12 09:47:45 2007 -0500

    fixing buffer refill problem on sis900

diff --git a/drivers/net/sis900.c b/drivers/net/sis900.c
index fb2b530..a6a0f09 100644
--- a/drivers/net/sis900.c
+++ b/drivers/net/sis900.c
@@ -1755,6 +1755,24 @@ static int sis900_rx(struct net_device *net_dev)
 		} else {
 			struct sk_buff * skb;
 
+			pci_unmap_single(sis_priv->pci_dev,
+				sis_priv->rx_ring[entry].bufptr, RX_BUF_SIZE,
+				PCI_DMA_FROMDEVICE);
+
+			/* refill the Rx buffer, what if there is not enought
+			 * memory for new socket buffer ?? */
+			if ((skb = dev_alloc_skb(RX_BUF_SIZE)) == NULL) {
+				/*
+				 * Not enough memory to refill the buffer
+				 * so we need to recycle the old one so
+				 * as to avoid creating a memory hole
+				 * in the rx ring
+				 */
+				skb = sis_priv->rx_skbuff[entry];
+				sis_priv->stats.rx_dropped++;
+				goto refill_rx_ring;
+			}	
+
 			/* This situation should never happen, but due to
 			   some unknow bugs, it is possible that
 			   we are working on NULL sk_buff :-( */
@@ -1768,9 +1786,6 @@ static int sis900_rx(struct net_device *net_dev)
 				break;
 			}
 
-			pci_unmap_single(sis_priv->pci_dev,
-				sis_priv->rx_ring[entry].bufptr, RX_BUF_SIZE,
-				PCI_DMA_FROMDEVICE);
 			/* give the socket buffer to upper layers */
 			skb = sis_priv->rx_skbuff[entry];
 			skb_put(skb, rx_size);
@@ -1783,33 +1798,14 @@ static int sis900_rx(struct net_device *net_dev)
 			net_dev->last_rx = jiffies;
 			sis_priv->stats.rx_bytes += rx_size;
 			sis_priv->stats.rx_packets++;
-
-			/* refill the Rx buffer, what if there is not enought
-			 * memory for new socket buffer ?? */
-			if ((skb = dev_alloc_skb(RX_BUF_SIZE)) == NULL) {
-				/* not enough memory for skbuff, this makes a
-				 * "hole" on the buffer ring, it is not clear
-				 * how the hardware will react to this kind
-				 * of degenerated buffer */
-				if (netif_msg_rx_status(sis_priv))
-					printk(KERN_INFO "%s: Memory squeeze,"
-						"deferring packet.\n",
-						net_dev->name);
-				sis_priv->rx_skbuff[entry] = NULL;
-				/* reset buffer descriptor state */
-				sis_priv->rx_ring[entry].cmdsts = 0;
-				sis_priv->rx_ring[entry].bufptr = 0;
-				sis_priv->stats.rx_dropped++;
-				sis_priv->cur_rx++;
-				break;
-			}
+			sis_priv->dirty_rx++;
+refill_rx_ring:
 			skb->dev = net_dev;
 			sis_priv->rx_skbuff[entry] = skb;
 			sis_priv->rx_ring[entry].cmdsts = RX_BUF_SIZE;
                 	sis_priv->rx_ring[entry].bufptr =
 				pci_map_single(sis_priv->pci_dev, skb->data,
 					RX_BUF_SIZE, PCI_DMA_FROMDEVICE);
-			sis_priv->dirty_rx++;
 		}
 		sis_priv->cur_rx++;
 		entry = sis_priv->cur_rx % NUM_RX_DESC;
