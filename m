From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCBN net-next] mlx4_en: fix skb truesize underestimation
Date: Tue, 18 Oct 2011 12:13:02 +0200
Message-ID: <1318932782.2657.36.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Yevgeny Petrilin <yevgenyp@mellanox.co.il>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:55684 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753973Ab1JRKMn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Oct 2011 06:12:43 -0400
Received: by bkbzt19 with SMTP id zt19so602390bkb.19
        for <netdev@vger.kernel.org>; Tue, 18 Oct 2011 03:12:42 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

skb->truesize must account for allocated memory, not the used part of
it. Doing this work is important to avoid unexpected OOM situations.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
Note: To improve performance, this driver should avoid all the
get_page() done for every frag since it dirties page->_count and
conflict with previous skbs consumers (on a different cpu maybe)

Only at alloc_pages() time should we add to page->count the
(number_of_frags on this page) - 1

 drivers/net/ethernet/mellanox/mlx4/en_rx.c |   11 +++++------
 1 file changed, 5 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index 37cc9e5..c9aaf20 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -404,10 +404,11 @@ void mlx4_en_deactivate_rx_ring(struct mlx4_en_priv *priv,
 static int mlx4_en_complete_rx_desc(struct mlx4_en_priv *priv,
 				    struct mlx4_en_rx_desc *rx_desc,
 				    struct skb_frag_struct *skb_frags,
-				    struct skb_frag_struct *skb_frags_rx,
+				    struct sk_buff *skb,
 				    struct mlx4_en_rx_alloc *page_alloc,
 				    int length)
 {
+	struct skb_frag_struct *skb_frags_rx = skb_shinfo(skb)->frags;
 	struct mlx4_en_dev *mdev = priv->mdev;
 	struct mlx4_en_frag_info *frag_info;
 	int nr;
@@ -423,6 +424,7 @@ static int mlx4_en_complete_rx_desc(struct mlx4_en_priv *priv,
 		skb_frags_rx[nr].page = skb_frags[nr].page;
 		skb_frags_rx[nr].size = skb_frags[nr].size;
 		skb_frags_rx[nr].page_offset = skb_frags[nr].page_offset;
+		skb->truesize += frag_info->frag_stride;
 		dma = be64_to_cpu(rx_desc->data[nr].addr);
 
 		/* Allocate a replacement page */
@@ -470,7 +472,6 @@ static struct sk_buff *mlx4_en_rx_skb(struct mlx4_en_priv *priv,
 	skb->dev = priv->dev;
 	skb_reserve(skb, NET_IP_ALIGN);
 	skb->len = length;
-	skb->truesize = length + sizeof(struct sk_buff);
 
 	/* Get pointer to first fragment so we could copy the headers into the
 	 * (linear part of the) skb */
@@ -490,8 +491,7 @@ static struct sk_buff *mlx4_en_rx_skb(struct mlx4_en_priv *priv,
 
 		/* Move relevant fragments to skb */
 		used_frags = mlx4_en_complete_rx_desc(priv, rx_desc, skb_frags,
-						      skb_shinfo(skb)->frags,
-						      page_alloc, length);
+						      skb, page_alloc, length);
 		if (unlikely(!used_frags)) {
 			kfree_skb(skb);
 			return NULL;
@@ -600,7 +600,7 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 
 					nr = mlx4_en_complete_rx_desc(
 						priv, rx_desc,
-						skb_frags, skb_shinfo(gro_skb)->frags,
+						skb_frags, gro_skb,
 						ring->page_alloc, length);
 					if (!nr)
 						goto next;
@@ -608,7 +608,6 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 					skb_shinfo(gro_skb)->nr_frags = nr;
 					gro_skb->len = length;
 					gro_skb->data_len = length;
-					gro_skb->truesize += length;
 					gro_skb->ip_summed = CHECKSUM_UNNECESSARY;
 
 					if (cqe->vlan_my_qpn &
