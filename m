From: Kelly Daly <kelly@au1.ibm.com>
Subject: [PATCH 2/3] Rough VJ Channel Implementation - vj_ne2k.patch
Date: Wed, 26 Apr 2006 11:47:40 +0000
Message-ID: <200604261147.40359.kelly@au.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: rusty@rustcorp.com.au, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausmtp04.au.ibm.com ([202.81.18.152]:17336 "EHLO
	ausmtp04.au.ibm.com") by vger.kernel.org with ESMTP id S932330AbWDZBrV
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Apr 2006 21:47:21 -0400
Received: from sd0208e0.au.ibm.com (d23rh904.au.ibm.com [202.81.18.202])
	by ausmtp04.au.ibm.com (8.13.6/8.13.5) with ESMTP id k3Q1v4nD198094
	for <netdev@vger.kernel.org>; Wed, 26 Apr 2006 11:57:05 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.250.243])
	by sd0208e0.au.ibm.com (8.12.10/NCO/VER6.8) with ESMTP id k3Q1oEfd199336
	for <netdev@vger.kernel.org>; Wed, 26 Apr 2006 11:50:20 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11/8.13.3) with ESMTP id k3Q1krIc013134
	for <netdev@vger.kernel.org>; Wed, 26 Apr 2006 11:46:54 +1000
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Today 11:25:13
   
Signed-off-by: Kelly Daly <kelly@au.ibm.com>

Hacked NE2K driver using VJ Channels on receive.
Takes packet data and dumps it into a VJ buffer instead of skb.
Not implemented on transmit.
Useful for testing under QEMU.

-----


diff -r 47031a1f466c linux-2.6.16/drivers/net/8390.c
--- linux-2.6.16/drivers/net/8390.c     Thu Mar 23 06:32:12 2006
+++ linux-2.6.16/drivers/net/8390.c     Mon Apr 24 19:50:46 2006
@@ -74,6 +74,8 @@
 
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
+
+#include <linux/vjchan.h>
 
 #define NS8390_CORE
 #include "8390.h"
@@ -718,31 +720,30 @@
                }
                 else if ((pkt_stat & 0x0F) == ENRSR_RXOK) 
                {
-                       struct sk_buff *skb;
-                       
-                       skb = dev_alloc_skb(pkt_len+2);
-                       if (skb == NULL) 
-                       {
+
+//NOT make skb - make a buffer!
+                       struct vj_buffer *vjbuffer;
+                       int desc_num;
+
+                       vjbuffer = vj_get_buffer(&desc_num);
+                       if (vjbuffer == NULL) {
+//fail
                                if (ei_debug > 1)
-                                       printk(KERN_DEBUG "%s: Couldn't allocate a sk_buff of size %d.\n",
-                                                  dev->name, pkt_len);
+                                       printk(KERN_DEBUG "%s: Couldn't allocate a vj buffer.\n",
+                                                  dev->name);
                                ei_local->stat.rx_dropped++;
                                break;
                        }
-                       else
-                       {
-                               skb_reserve(skb,2);     /* IP headers on 16 byte boundaries */
-                               skb->dev = dev;
-                               skb_put(skb, pkt_len);  /* Make room */
-                               ei_block_input(dev, pkt_len, skb, current_offset + sizeof(rx_frame));
-                               skb->protocol=eth_type_trans(skb,dev);
-                               netif_rx(skb);
-                               dev->last_rx = jiffies;
-                               ei_local->stat.rx_packets++;
-                               ei_local->stat.rx_bytes += pkt_len;
-                               if (pkt_stat & ENRSR_PHY)
-                                       ei_local->stat.multicast++;
-                       }
+                       vjbuffer->data_len = pkt_len;
+                       vjbuffer->ifindex = dev->ifindex;
+                       ei_block_input(dev, pkt_len, vjbuffer->data, current_offset + sizeof(rx_frame));
+                       vj_netif_rx(vjbuffer, desc_num, eth_vj_type_trans(vjbuffer));
+                       dev->last_rx = jiffies;
+                       ei_local->stat.rx_packets++;
+                       ei_local->stat.rx_bytes += pkt_len;
+                       if (pkt_stat & ENRSR_PHY)
+                               ei_local->stat.multicast++;
+
                } 
                else 
                {
diff -r 47031a1f466c linux-2.6.16/drivers/net/8390.h
--- linux-2.6.16/drivers/net/8390.h     Thu Mar 23 06:32:12 2006
+++ linux-2.6.16/drivers/net/8390.h     Mon Apr 24 19:50:46 2006
@@ -10,7 +10,6 @@
 #include <linux/config.h>
 #include <linux/if_ether.h>
 #include <linux/ioport.h>
-#include <linux/skbuff.h>
 
 #define TX_PAGES 12    /* Two Tx slots */
 
@@ -49,7 +48,7 @@
        void (*reset_8390)(struct net_device *);
        void (*get_8390_hdr)(struct net_device *, struct e8390_pkt_hdr *, int);
        void (*block_output)(struct net_device *, int, const unsigned char *, int);
-       void (*block_input)(struct net_device *, int, struct sk_buff *, int);
+       void (*block_input)(struct net_device *, int, char *, int);
        unsigned long rmem_start;
        unsigned long rmem_end;
        void __iomem *mem;
diff -r 47031a1f466c linux-2.6.16/drivers/net/ne2k-pci.c
--- linux-2.6.16/drivers/net/ne2k-pci.c Thu Mar 23 06:32:12 2006
+++ linux-2.6.16/drivers/net/ne2k-pci.c Mon Apr 24 19:50:46 2006
@@ -172,7 +172,7 @@
 static void ne2k_pci_get_8390_hdr(struct net_device *dev, struct e8390_pkt_hdr *hdr,
                          int ring_page);
 static void ne2k_pci_block_input(struct net_device *dev, int count,
-                         struct sk_buff *skb, int ring_offset);
+                         char *data, int ring_offset);
 static void ne2k_pci_block_output(struct net_device *dev, const int count,
                const unsigned char *buf, const int start_page);
 static struct ethtool_ops ne2k_pci_ethtool_ops;
@@ -503,10 +503,9 @@
    the packet out through the "remote DMA" dataport using outb. */
 
 static void ne2k_pci_block_input(struct net_device *dev, int count,
-                                struct sk_buff *skb, int ring_offset)
+                                char *buf, int ring_offset)
 {
        long nic_base = dev->base_addr;
-       char *buf = skb->data;
 
        /* This *shouldn't* happen. If it does, it's the last thing you'll see */
        if (ei_status.dmaing) {
