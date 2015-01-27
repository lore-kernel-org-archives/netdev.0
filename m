From: Ben Hutchings <ben.hutchings@codethink.co.uk>
Subject: [PATCH kernel 4/4] sh_eth: Fix DMA-API usage for RX buffers
Date: Tue, 27 Jan 2015 00:50:24 +0000
Message-ID: <1422319824.3524.24.camel@xylophone.i.decadent.org.uk>
References: <1422319232.3524.14.camel@xylophone.i.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@lists.codethink.co.uk,
	Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>,
	Mitsuhiro Kimura <mitsuhiro.kimura.kc@renesas.com>,
	Hisashi Nakamura <hisashi.nakamura.ak@renesas.com>,
	Yoshihiro Kaneko <ykaneko0929@gmail.com>
To: "David S.Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ducie-dc1.codethink.co.uk ([185.25.241.215]:50239 "EHLO
	ducie-dc1.codethink.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756659AbbA0AuY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jan 2015 19:50:24 -0500
In-Reply-To: <1422319232.3524.14.camel@xylophone.i.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- Use the return value of dma_map_single(), rather than calling
  virt_to_page() separately
- Check for mapping failue
- Call dma_unmap_single() rather than dma_sync_single_for_cpu()

Signed-off-by: Ben Hutchings <ben.hutchings@codethink.co.uk>
---
 drivers/net/ethernet/renesas/sh_eth.c |   34 ++++++++++++++++++++++-----------
 1 file changed, 23 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index 48610ed..4da8bd2 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -1123,6 +1123,7 @@ static void sh_eth_ring_format(struct net_device *ndev)
 	int rx_ringsize = sizeof(*rxdesc) * mdp->num_rx_ring;
 	int tx_ringsize = sizeof(*txdesc) * mdp->num_tx_ring;
 	int skbuff_size = mdp->rx_buf_sz + SH_ETH_RX_ALIGN - 1;
+	dma_addr_t dma_addr;
 
 	mdp->cur_rx = 0;
 	mdp->cur_tx = 0;
@@ -1136,7 +1137,6 @@ static void sh_eth_ring_format(struct net_device *ndev)
 		/* skb */
 		mdp->rx_skbuff[i] = NULL;
 		skb = netdev_alloc_skb(ndev, skbuff_size);
-		mdp->rx_skbuff[i] = skb;
 		if (skb == NULL)
 			break;
 		sh_eth_set_receive_align(skb);
@@ -1145,9 +1145,15 @@ static void sh_eth_ring_format(struct net_device *ndev)
 		rxdesc = &mdp->rx_ring[i];
 		/* The size of the buffer is a multiple of 16 bytes. */
 		rxdesc->buffer_length = ALIGN(mdp->rx_buf_sz, 16);
-		dma_map_single(&ndev->dev, skb->data, rxdesc->buffer_length,
-			       DMA_FROM_DEVICE);
-		rxdesc->addr = virt_to_phys(skb->data);
+		dma_addr = dma_map_single(&ndev->dev, skb->data,
+					  rxdesc->buffer_length,
+					  DMA_FROM_DEVICE);
+		if (dma_mapping_error(&ndev->dev, dma_addr)) {
+			kfree_skb(skb);
+			break;
+		}
+		mdp->rx_skbuff[i] = skb;
+		rxdesc->addr = dma_addr;
 		rxdesc->status = cpu_to_edmac(mdp, RD_RACT | RD_RFP);
 
 		/* Rx descriptor address set */
@@ -1432,6 +1438,7 @@ static int sh_eth_rx(struct net_device *ndev, u32 intr_status, int *quota)
 	u16 pkt_len = 0;
 	u32 desc_status;
 	int skbuff_size = mdp->rx_buf_sz + SH_ETH_RX_ALIGN - 1;
+	dma_addr_t dma_addr;
 
 	boguscnt = min(boguscnt, *quota);
 	limit = boguscnt;
@@ -1479,9 +1486,9 @@ static int sh_eth_rx(struct net_device *ndev, u32 intr_status, int *quota)
 			mdp->rx_skbuff[entry] = NULL;
 			if (mdp->cd->rpadir)
 				skb_reserve(skb, NET_IP_ALIGN);
-			dma_sync_single_for_cpu(&ndev->dev, rxdesc->addr,
-						ALIGN(mdp->rx_buf_sz, 16),
-						DMA_FROM_DEVICE);
+			dma_unmap_single(&ndev->dev, rxdesc->addr,
+					 ALIGN(mdp->rx_buf_sz, 16),
+					 DMA_FROM_DEVICE);
 			skb_put(skb, pkt_len);
 			skb->protocol = eth_type_trans(skb, ndev);
 			netif_receive_skb(skb);
@@ -1501,15 +1508,20 @@ static int sh_eth_rx(struct net_device *ndev, u32 intr_status, int *quota)
 
 		if (mdp->rx_skbuff[entry] == NULL) {
 			skb = netdev_alloc_skb(ndev, skbuff_size);
-			mdp->rx_skbuff[entry] = skb;
 			if (skb == NULL)
 				break;	/* Better luck next round. */
 			sh_eth_set_receive_align(skb);
-			dma_map_single(&ndev->dev, skb->data,
-				       rxdesc->buffer_length, DMA_FROM_DEVICE);
+			dma_addr = dma_map_single(&ndev->dev, skb->data,
+						  rxdesc->buffer_length,
+						  DMA_FROM_DEVICE);
+			if (dma_mapping_error(&ndev->dev, dma_addr)) {
+				kfree_skb(skb);
+				break;
+			}
+			mdp->rx_skbuff[entry] = skb;
 
 			skb_checksum_none_assert(skb);
-			rxdesc->addr = virt_to_phys(skb->data);
+			rxdesc->addr = dma_addr;
 		}
 		if (entry >= mdp->num_rx_ring - 1)
 			rxdesc->status |=
-- 
1.7.10.4
