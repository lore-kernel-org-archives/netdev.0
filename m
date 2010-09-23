From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: [PATCH 1/2 -next] r8169: allocate with GFP_KERNEL flag when able to sleep
Date: Thu, 23 Sep 2010 14:01:30 +0200
Message-ID: <1285243291-4520-1-git-send-email-sgruszka@redhat.com>
Cc: Stanislaw Gruszka <sgruszka@redhat.com>
To: Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52540 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752561Ab0IWMAc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Sep 2010 08:00:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We have fedora bug report where driver fail to initialize after
suspend/resume because of memory allocation errors:
https://bugzilla.redhat.com/show_bug.cgi?id=629158

To fix use GFP_KERNEL allocation where possible. 

Signed-off-by: Stanislaw Gruszka <sgruszka@redhat.com>
---
 drivers/net/r8169.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 5490033..4f94073 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -4006,7 +4006,7 @@ static inline void rtl8169_map_to_asic(struct RxDesc *desc, dma_addr_t mapping,
 static struct sk_buff *rtl8169_alloc_rx_skb(struct pci_dev *pdev,
 					    struct net_device *dev,
 					    struct RxDesc *desc, int rx_buf_sz,
-					    unsigned int align)
+					    unsigned int align, gfp_t gfp)
 {
 	struct sk_buff *skb;
 	dma_addr_t mapping;
@@ -4014,7 +4014,7 @@ static struct sk_buff *rtl8169_alloc_rx_skb(struct pci_dev *pdev,
 
 	pad = align ? align : NET_IP_ALIGN;
 
-	skb = netdev_alloc_skb(dev, rx_buf_sz + pad);
+	skb = __netdev_alloc_skb(dev, rx_buf_sz + pad, gfp);
 	if (!skb)
 		goto err_out;
 
@@ -4045,7 +4045,7 @@ static void rtl8169_rx_clear(struct rtl8169_private *tp)
 }
 
 static u32 rtl8169_rx_fill(struct rtl8169_private *tp, struct net_device *dev,
-			   u32 start, u32 end)
+			   u32 start, u32 end, gfp_t gfp)
 {
 	u32 cur;
 
@@ -4060,7 +4060,7 @@ static u32 rtl8169_rx_fill(struct rtl8169_private *tp, struct net_device *dev,
 
 		skb = rtl8169_alloc_rx_skb(tp->pci_dev, dev,
 					   tp->RxDescArray + i,
-					   tp->rx_buf_sz, tp->align);
+					   tp->rx_buf_sz, tp->align, gfp);
 		if (!skb)
 			break;
 
@@ -4088,7 +4088,7 @@ static int rtl8169_init_ring(struct net_device *dev)
 	memset(tp->tx_skb, 0x0, NUM_TX_DESC * sizeof(struct ring_info));
 	memset(tp->Rx_skbuff, 0x0, NUM_RX_DESC * sizeof(struct sk_buff *));
 
-	if (rtl8169_rx_fill(tp, dev, 0, NUM_RX_DESC) != NUM_RX_DESC)
+	if (rtl8169_rx_fill(tp, dev, 0, NUM_RX_DESC, GFP_KERNEL) != NUM_RX_DESC)
 		goto err_out;
 
 	rtl8169_mark_as_last_descriptor(tp->RxDescArray + NUM_RX_DESC - 1);
@@ -4587,7 +4587,7 @@ static int rtl8169_rx_interrupt(struct net_device *dev,
 	count = cur_rx - tp->cur_rx;
 	tp->cur_rx = cur_rx;
 
-	delta = rtl8169_rx_fill(tp, dev, tp->dirty_rx, tp->cur_rx);
+	delta = rtl8169_rx_fill(tp, dev, tp->dirty_rx, tp->cur_rx, GFP_ATOMIC);
 	if (!delta && count)
 		netif_info(tp, intr, dev, "no Rx buffer allocated\n");
 	tp->dirty_rx += delta;
-- 
1.7.0.1

