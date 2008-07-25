From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] 3c59x: use netdev_alloc_skb
Date: Fri, 25 Jul 2008 12:07:22 -0700
Message-ID: <20080725120722.1f2668a1@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>, klassert@mathematik.tu-chemnitz.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:51239 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755855AbYGYTHZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Jul 2008 15:07:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix possible bug where end of receive buffer could be overwritten.
The allocation needs to allow for the reserved space. This would only happen
if device received packet greater than Ethernet standard MTU.

Change this driver to use netdev_alloc_skb rather than setting skb->dev
directly. For the initial allocation it doesn't need to be GFP_ATOMIC.

Compile tested only.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/3c59x.c	2008-07-25 11:53:43.000000000 -0700
+++ b/drivers/net/3c59x.c	2008-07-25 12:06:00.000000000 -0700
@@ -1692,12 +1692,14 @@ vortex_open(struct net_device *dev)
 			vp->rx_ring[i].next = cpu_to_le32(vp->rx_ring_dma + sizeof(struct boom_rx_desc) * (i+1));
 			vp->rx_ring[i].status = 0;	/* Clear complete bit. */
 			vp->rx_ring[i].length = cpu_to_le32(PKT_BUF_SZ | LAST_FRAG);
-			skb = dev_alloc_skb(PKT_BUF_SZ);
+
+			skb = __netdev_alloc_skb(dev, PKT_BUF_SZ + NET_IP_ALIGN,
+						 GFP_KERNEL);
 			vp->rx_skbuff[i] = skb;
 			if (skb == NULL)
 				break;			/* Bad news!  */
-			skb->dev = dev;			/* Mark as being used by this device. */
-			skb_reserve(skb, 2);	/* Align IP on 16 byte boundaries */
+
+			skb_reserve(skb, NET_IP_ALIGN);	/* Align IP on 16 byte boundaries */
 			vp->rx_ring[i].addr = cpu_to_le32(pci_map_single(VORTEX_PCI(vp), skb->data, PKT_BUF_SZ, PCI_DMA_FROMDEVICE));
 		}
 		if (i != RX_RING_SIZE) {
@@ -2538,7 +2540,7 @@ boomerang_rx(struct net_device *dev)
 		struct sk_buff *skb;
 		entry = vp->dirty_rx % RX_RING_SIZE;
 		if (vp->rx_skbuff[entry] == NULL) {
-			skb = dev_alloc_skb(PKT_BUF_SZ);
+			skb = netdev_alloc_skb(dev, PKT_BUF_SZ + NET_IP_ALIGN);
 			if (skb == NULL) {
 				static unsigned long last_jif;
 				if (time_after(jiffies, last_jif + 10 * HZ)) {
@@ -2549,8 +2551,8 @@ boomerang_rx(struct net_device *dev)
 					mod_timer(&vp->rx_oom_timer, RUN_AT(HZ * 1));
 				break;			/* Bad news!  */
 			}
-			skb->dev = dev;			/* Mark as being used by this device. */
-			skb_reserve(skb, 2);	/* Align IP on 16 byte boundaries */
+
+			skb_reserve(skb, NET_IP_ALIGN);
 			vp->rx_ring[entry].addr = cpu_to_le32(pci_map_single(VORTEX_PCI(vp), skb->data, PKT_BUF_SZ, PCI_DMA_FROMDEVICE));
 			vp->rx_skbuff[entry] = skb;
 		}
