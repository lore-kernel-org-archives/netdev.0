From: Kevin Lo <kevlo@kevlo.org>
Subject: [PATCH] 8139cp: use netdev_alloc_skb
Date: Wed, 27 Aug 2008 11:35:15 +0800
Message-ID: <1219808115.7135.15.camel@nsl>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-zSnR6decMbNuf/vAjKFb"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from kevlo.org ([220.128.136.52]:33259 "EHLO ns.kevlo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752614AbYH0Dle (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Aug 2008 23:41:34 -0400
Received: from [127.0.0.1] (ns.kevlo.org [220.128.136.52])
	by ns.kevlo.org (8.14.3/8.14.3) with ESMTP id m7R3ZgLh005605
	for <netdev@vger.kernel.org>; Wed, 27 Aug 2008 11:35:46 +0800 (CST)
	(envelope-from kevlo@kevlo.org)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-zSnR6decMbNuf/vAjKFb
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Hi,

This patch uses netdev_alloc_skb. This sets skb->dev and allows 
arch specific allocation. Also cleanup the alignment code.

Tested on x86_64.

Signed-off-by:	Kevin Lo <kevlo@kevlo.org>

--=-zSnR6decMbNuf/vAjKFb
Content-Disposition: attachment; filename=patch-8139cp
Content-Type: text/x-patch; name=patch-8139cp; charset=UTF-8
Content-Transfer-Encoding: 7bit

--- linux-2.6.27-rc4/drivers/net/8139cp.c.orig	2008-08-27 09:28:18.000000000 +0800
+++ linux-2.6.27-rc4/drivers/net/8139cp.c	2008-08-27 09:37:39.000000000 +0800
@@ -127,7 +127,6 @@ MODULE_PARM_DESC (multicast_filter_limit
 	  (CP)->tx_tail - (CP)->tx_head - 1)
 
 #define PKT_BUF_SZ		1536	/* Size of each temporary Rx buffer.*/
-#define RX_OFFSET		2
 #define CP_INTERNAL_PHY		32
 
 /* The following settings are log_2(bytes)-4:  0 == 16 bytes .. 6==1024, 7==end of packet. */
@@ -552,14 +551,14 @@ rx_status_loop:
 			printk(KERN_DEBUG "%s: rx slot %d status 0x%x len %d\n",
 			       dev->name, rx_tail, status, len);
 
-		buflen = cp->rx_buf_sz + RX_OFFSET;
-		new_skb = dev_alloc_skb (buflen);
+		buflen = cp->rx_buf_sz + NET_IP_ALIGN;
+		new_skb = netdev_alloc_skb(dev, buflen);
 		if (!new_skb) {
 			dev->stats.rx_dropped++;
 			goto rx_next;
 		}
 
-		skb_reserve(new_skb, RX_OFFSET);
+		skb_reserve(new_skb, NET_IP_ALIGN);
 
 		dma_unmap_single(&cp->pdev->dev, mapping,
 				 buflen, PCI_DMA_FROMDEVICE);
@@ -1051,19 +1050,20 @@ static void cp_init_hw (struct cp_privat
 	cpw8_f(Cfg9346, Cfg9346_Lock);
 }
 
-static int cp_refill_rx (struct cp_private *cp)
+static int cp_refill_rx(struct cp_private *cp)
 {
+	struct net_device *dev = cp->dev;
 	unsigned i;
 
 	for (i = 0; i < CP_RX_RING_SIZE; i++) {
 		struct sk_buff *skb;
 		dma_addr_t mapping;
 
-		skb = dev_alloc_skb(cp->rx_buf_sz + RX_OFFSET);
+		skb = netdev_alloc_skb(dev, cp->rx_buf_sz + NET_IP_ALIGN);
 		if (!skb)
 			goto err_out;
 
-		skb_reserve(skb, RX_OFFSET);
+		skb_reserve(skb, NET_IP_ALIGN);
 
 		mapping = dma_map_single(&cp->pdev->dev, skb->data,
 					 cp->rx_buf_sz, PCI_DMA_FROMDEVICE);

--=-zSnR6decMbNuf/vAjKFb--

