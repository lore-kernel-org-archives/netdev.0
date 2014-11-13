From: Yoshihiro Kaneko <ykaneko0929@gmail.com>
Subject: [PATCH 2/3] sh_eth: Fix skb alloc size and alignment adjust rule.
Date: Thu, 13 Nov 2014 16:05:00 +0900
Message-ID: <1415862301-28032-3-git-send-email-ykaneko0929@gmail.com>
References: <1415862301-28032-1-git-send-email-ykaneko0929@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Simon Horman <horms@verge.net.au>,
	Magnus Damm <magnus.damm@gmail.com>, linux-sh@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:36007 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753861AbaKMHFf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Nov 2014 02:05:35 -0500
In-Reply-To: <1415862301-28032-1-git-send-email-ykaneko0929@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitsuhiro Kimura <mitsuhiro.kimura.kc@renesas.com>

In the current driver, allocation size of skb does not care the alignment
adjust after allocation.
And also, in the current implementation, buffer alignment method by
sh_eth_set_receive_align function has a bug that this function displace
buffer start address forcedly when the alignment is corrected.
In the result, tail of the skb will exceed allocated area and kernel panic
will be occurred.
This patch fix this issue.

Signed-off-by: Mitsuhiro Kimura <mitsuhiro.kimura.kc@renesas.com>
Signed-off-by: Yoshihiro Kaneko <ykaneko0929@gmail.com>
---
 drivers/net/ethernet/renesas/sh_eth.c | 35 ++++++++++++++---------------------
 drivers/net/ethernet/renesas/sh_eth.h |  2 ++
 2 files changed, 16 insertions(+), 21 deletions(-)

diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index 49e963e..0e4a407 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -917,21 +917,12 @@ static int sh_eth_reset(struct net_device *ndev)
 	return ret;
 }
 
-#if defined(CONFIG_CPU_SH4) || defined(CONFIG_ARCH_SHMOBILE)
 static void sh_eth_set_receive_align(struct sk_buff *skb)
 {
-	int reserve;
-
-	reserve = SH4_SKB_RX_ALIGN - ((u32)skb->data & (SH4_SKB_RX_ALIGN - 1));
+	u32 reserve = (u32)skb->data & (SH_ETH_RX_ALIGN - 1);
 	if (reserve)
-		skb_reserve(skb, reserve);
-}
-#else
-static void sh_eth_set_receive_align(struct sk_buff *skb)
-{
-	skb_reserve(skb, SH2_SH3_SKB_RX_ALIGN);
+		skb_reserve(skb, SH_ETH_RX_ALIGN - reserve);
 }
-#endif
 
 
 /* CPU <-> EDMAC endian convert */
@@ -1119,6 +1110,7 @@ static void sh_eth_ring_format(struct net_device *ndev)
 	struct sh_eth_txdesc *txdesc = NULL;
 	int rx_ringsize = sizeof(*rxdesc) * mdp->num_rx_ring;
 	int tx_ringsize = sizeof(*txdesc) * mdp->num_tx_ring;
+	int skbuff_size = mdp->rx_buf_sz + SH_ETH_RX_ALIGN - 1;
 
 	mdp->cur_rx = 0;
 	mdp->cur_tx = 0;
@@ -1131,21 +1123,21 @@ static void sh_eth_ring_format(struct net_device *ndev)
 	for (i = 0; i < mdp->num_rx_ring; i++) {
 		/* skb */
 		mdp->rx_skbuff[i] = NULL;
-		skb = netdev_alloc_skb(ndev, mdp->rx_buf_sz);
+		skb = netdev_alloc_skb(ndev, skbuff_size);
 		mdp->rx_skbuff[i] = skb;
 		if (skb == NULL)
 			break;
-		dma_map_single(&ndev->dev, skb->data, mdp->rx_buf_sz,
-			       DMA_FROM_DEVICE);
 		sh_eth_set_receive_align(skb);
 
 		/* RX descriptor */
 		rxdesc = &mdp->rx_ring[i];
+		/* The size of the buffer is 16 byte boundary. */
+		rxdesc->buffer_length = ALIGN(mdp->rx_buf_sz, 16);
+		dma_map_single(&ndev->dev, skb->data, rxdesc->buffer_length,
+			       DMA_FROM_DEVICE);
 		rxdesc->addr = virt_to_phys(skb->data);
 		rxdesc->status = cpu_to_edmac(mdp, RD_RACT | RD_RFP);
 
-		/* The size of the buffer is 16 byte boundary. */
-		rxdesc->buffer_length = ALIGN(mdp->rx_buf_sz, 16);
 		/* Rx descriptor address set */
 		if (i == 0) {
 			sh_eth_write(ndev, mdp->rx_desc_dma, RDLAR);
@@ -1397,6 +1389,7 @@ static int sh_eth_rx(struct net_device *ndev, u32 intr_status, int *quota)
 	struct sk_buff *skb;
 	u16 pkt_len = 0;
 	u32 desc_status;
+	int skbuff_size = mdp->rx_buf_sz + SH_ETH_RX_ALIGN - 1;
 
 	rxdesc = &mdp->rx_ring[entry];
 	while (!(rxdesc->status & cpu_to_edmac(mdp, RD_RACT))) {
@@ -1448,8 +1441,8 @@ static int sh_eth_rx(struct net_device *ndev, u32 intr_status, int *quota)
 			if (mdp->cd->rpadir)
 				skb_reserve(skb, NET_IP_ALIGN);
 			dma_sync_single_for_cpu(&ndev->dev, rxdesc->addr,
-						mdp->rx_buf_sz,
-						DMA_FROM_DEVICE);
+					ALIGN(mdp->rx_buf_sz, 16),
+					DMA_FROM_DEVICE);
 			skb_put(skb, pkt_len);
 			skb->protocol = eth_type_trans(skb, ndev);
 			netif_receive_skb(skb);
@@ -1468,13 +1461,13 @@ static int sh_eth_rx(struct net_device *ndev, u32 intr_status, int *quota)
 		rxdesc->buffer_length = ALIGN(mdp->rx_buf_sz, 16);
 
 		if (mdp->rx_skbuff[entry] == NULL) {
-			skb = netdev_alloc_skb(ndev, mdp->rx_buf_sz);
+			skb = netdev_alloc_skb(ndev, skbuff_size);
 			mdp->rx_skbuff[entry] = skb;
 			if (skb == NULL)
 				break;	/* Better luck next round. */
-			dma_map_single(&ndev->dev, skb->data, mdp->rx_buf_sz,
-				       DMA_FROM_DEVICE);
 			sh_eth_set_receive_align(skb);
+			dma_map_single(&ndev->dev, skb->data,
+				       rxdesc->buffer_length, DMA_FROM_DEVICE);
 
 			skb_checksum_none_assert(skb);
 			rxdesc->addr = virt_to_phys(skb->data);
diff --git a/drivers/net/ethernet/renesas/sh_eth.h b/drivers/net/ethernet/renesas/sh_eth.h
index b37c427..d138ebe 100644
--- a/drivers/net/ethernet/renesas/sh_eth.h
+++ b/drivers/net/ethernet/renesas/sh_eth.h
@@ -163,8 +163,10 @@ enum {
 /* Driver's parameters */
 #if defined(CONFIG_CPU_SH4) || defined(CONFIG_ARCH_SHMOBILE)
 #define SH4_SKB_RX_ALIGN	32
+#define SH_ETH_RX_ALIGN		(SH4_SKB_RX_ALIGN)
 #else
 #define SH2_SH3_SKB_RX_ALIGN	2
+#define SH_ETH_RX_ALIGN		(SH2_SH3_SKB_RX_ALIGN)
 #endif
 
 /* Register's bits
-- 
1.9.1
