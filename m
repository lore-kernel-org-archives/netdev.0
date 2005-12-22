From: Manfred Spraul <manfred@colorfullife.com>
Subject: [PATCH] forcedeth: Fix incorrect parameters in pci_unmap_single calls
Date: Thu, 22 Dec 2005 23:05:34 +0100
Message-ID: <43AB232E.7050309@colorfullife.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020905000705080401070509"
Cc: Netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------020905000705080401070509
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Hi,

The natsemi rx codepath calls pci_unmap_single with a different size 
than the initial pci_map_single call.
The attached patch fixes that.

Signed-Off-By: Manfred Spraul <manfred@colorfullife.com>

--------------020905000705080401070509
Content-Type: text/plain;
 name="patch-natsemi-rxunmapsize"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-natsemi-rxunmapsize"

--- 2.6/drivers/net/natsemi.c	2005-12-19 01:36:54.000000000 +0100
+++ x64/drivers/net/natsemi.c	2005-12-22 22:10:56.000000000 +0100
@@ -1920,6 +1920,7 @@
 		int entry = np->dirty_rx % RX_RING_SIZE;
 		if (np->rx_skbuff[entry] == NULL) {
 			unsigned int buflen = np->rx_buf_sz+NATSEMI_PADDING;
+
 			skb = dev_alloc_skb(buflen);
 			np->rx_skbuff[entry] = skb;
 			if (skb == NULL)
@@ -2006,7 +2007,6 @@
 static void drain_rx(struct net_device *dev)
 {
 	struct netdev_private *np = netdev_priv(dev);
-	unsigned int buflen = np->rx_buf_sz;
 	int i;
 
 	/* Free all the skbuffs in the Rx queue. */
@@ -2014,6 +2014,8 @@
 		np->rx_ring[i].cmd_status = 0;
 		np->rx_ring[i].addr = 0xBADF00D0; /* An invalid address. */
 		if (np->rx_skbuff[i]) {
+			unsigned int buflen = np->rx_buf_sz+NATSEMI_PADDING;
+
 			pci_unmap_single(np->pci_dev,
 				np->rx_dma[i], buflen,
 				PCI_DMA_FROMDEVICE);
@@ -2225,7 +2227,6 @@
 	int entry = np->cur_rx % RX_RING_SIZE;
 	int boguscnt = np->dirty_rx + RX_RING_SIZE - np->cur_rx;
 	s32 desc_status = le32_to_cpu(np->rx_head_desc->cmd_status);
-	unsigned int buflen = np->rx_buf_sz;
 	void __iomem * ioaddr = ns_ioaddr(dev);
 
 	/* If the driver owns the next entry it's a new packet. Send it up. */
@@ -2267,6 +2268,8 @@
 			 */
 		} else {
 			struct sk_buff *skb;
+			unsigned int buflen = np->rx_buf_sz+NATSEMI_PADDING;
+
 			/* Omit CRC size. */
 			/* Check if the packet is long enough to accept
 			 * without copying to a minimally-sized skbuff. */

--------------020905000705080401070509--
