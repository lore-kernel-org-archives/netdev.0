From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH] chelsio: use netdev_alloc_skb
Date: Wed, 20 Mar 2013 11:30:24 -0700
Message-ID: <20130320113024.00377b99@nehalam.linuxnetplumber.net>
References: <1363797199.3333.18.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f41.google.com ([209.85.160.41]:41868 "EHLO
	mail-pb0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755882Ab3CTSaa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Mar 2013 14:30:30 -0400
Received: by mail-pb0-f41.google.com with SMTP id um15so1580961pbc.14
        for <netdev@vger.kernel.org>; Wed, 20 Mar 2013 11:30:30 -0700 (PDT)
In-Reply-To: <1363797199.3333.18.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This extends on Eric's patch. It uses netdev_alloc_skb which fixes a couple of
other issues.
  * driver was never setting skb->dev on the received buffer
  * copybreak allocation wasn't padding buffer
  * copybreak assumed that ip alignment padding was always 2 (it is platform dependent)

Compile tested only, don't have this hardware.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>


--- a/drivers/net/ethernet/chelsio/cxgb/sge.c	2013-03-20 11:13:47.950986878 -0700
+++ b/drivers/net/ethernet/chelsio/cxgb/sge.c	2013-03-20 11:24:26.942722757 -0700
@@ -835,7 +835,7 @@ static void refill_free_list(struct sge
 		struct sk_buff *skb;
 		dma_addr_t mapping;
 
-		skb = dev_alloc_skb(q->rx_buffer_size);
+		skb = netdev_alloc_skb(sge->netdev, q->rx_buffer_size);
 		if (!skb)
 			break;
 
@@ -1039,18 +1039,18 @@ MODULE_PARM_DESC(copybreak, "Receive cop
  *	threshold and the packet is too big to copy, or (b) the packet should
  *	be copied but there is no memory for the copy.
  */
-static inline struct sk_buff *get_packet(struct pci_dev *pdev,
+static inline struct sk_buff *get_packet(struct net_device *netdev,
+					 struct pci_dev *pdev,
 					 struct freelQ *fl, unsigned int len)
 {
 	struct sk_buff *skb;
 	const struct freelQ_ce *ce = &fl->centries[fl->cidx];
 
 	if (len < copybreak) {
-		skb = alloc_skb(len + 2, GFP_ATOMIC);
+		skb = netdev_alloc_skb_ip_align(netdev, len + 2);
 		if (!skb)
 			goto use_orig_buf;
 
-		skb_reserve(skb, 2);	/* align IP header */
 		skb_put(skb, len);
 		pci_dma_sync_single_for_cpu(pdev,
 					    dma_unmap_addr(ce, dma_addr),
@@ -1360,7 +1360,7 @@ static void sge_rx(struct sge *sge, stru
 	struct sge_port_stats *st;
 	struct net_device *dev;
 
-	skb = get_packet(adapter->pdev, fl, len - sge->rx_pkt_pad);
+	skb = get_packet(sge->netdev, adapter->pdev, fl, len - sge->rx_pkt_pad);
 	if (unlikely(!skb)) {
 		sge->stats.rx_drops++;
 		return;
