From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH v2 12/46] net: sunhme: cleanup RX skb allocation
Date: Mon, 11 Jul 2011 02:52:49 +0200 (CEST)
Message-ID: <a9886452097f937592e11f73f032173546848216.1310339688.git.mirq-linux@rere.qmqm.pl>
References: <cover.1310339688.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:43682 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753312Ab1GKAwx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 10 Jul 2011 20:52:53 -0400
In-Reply-To: <cover.1310339688.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 drivers/net/sunhme.c |   18 ++++++++----------
 drivers/net/sunhme.h |   14 +-------------
 2 files changed, 9 insertions(+), 23 deletions(-)

diff --git a/drivers/net/sunhme.c b/drivers/net/sunhme.c
index 856e05b..c73fdad 100644
--- a/drivers/net/sunhme.c
+++ b/drivers/net/sunhme.c
@@ -1265,7 +1265,8 @@ static void happy_meal_init_rings(struct happy_me=
al *hp)
 	for (i =3D 0; i < RX_RING_SIZE; i++) {
 		struct sk_buff *skb;
=20
-		skb =3D happy_meal_alloc_skb(RX_BUF_ALLOC_SIZE, GFP_ATOMIC);
+		skb =3D __netdev_alloc_skb_aligned(dev, RX_BUF_ALLOC_SIZE,
+			SUNHME_RX_ALIGNMENT, GFP_ATOMIC);
 		if (!skb) {
 			hme_write_rxd(hp, &hb->happy_meal_rxd[i], 0, 0);
 			continue;
@@ -1273,8 +1274,6 @@ static void happy_meal_init_rings(struct happy_me=
al *hp)
 		hp->rx_skbs[i] =3D skb;
 		skb->dev =3D dev;
=20
-		/* Because we reserve afterwards. */
-		skb_put(skb, (ETH_FRAME_LEN + RX_OFFSET + 4));
 		hme_write_rxd(hp, &hb->happy_meal_rxd[i],
 			      (RXFLAG_OWN | ((RX_BUF_ALLOC_SIZE - RX_OFFSET) << 16)),
 			      dma_map_single(hp->dma_dev, skb->data, RX_BUF_ALLOC_SIZE,
@@ -2025,32 +2024,31 @@ static void happy_meal_rx(struct happy_meal *hp=
, struct net_device *dev)
 			struct sk_buff *new_skb;
=20
 			/* Now refill the entry, if we can. */
-			new_skb =3D happy_meal_alloc_skb(RX_BUF_ALLOC_SIZE, GFP_ATOMIC);
+			new_skb =3D __netdev_alloc_skb_aligned(dev,
+							     RX_BUF_ALLOC_SIZE,
+							     SUNHME_RX_ALIGNMENT,
+							     GFP_ATOMIC);
 			if (new_skb =3D=3D NULL) {
 				drops++;
 				goto drop_it;
 			}
 			dma_unmap_single(hp->dma_dev, dma_addr, RX_BUF_ALLOC_SIZE, DMA_FROM=
_DEVICE);
 			hp->rx_skbs[elem] =3D new_skb;
-			new_skb->dev =3D dev;
-			skb_put(new_skb, (ETH_FRAME_LEN + RX_OFFSET + 4));
 			hme_write_rxd(hp, this,
 				      (RXFLAG_OWN|((RX_BUF_ALLOC_SIZE-RX_OFFSET)<<16)),
 				      dma_map_single(hp->dma_dev, new_skb->data, RX_BUF_ALLOC_SIZE=
,
 						     DMA_FROM_DEVICE));
 			skb_reserve(new_skb, RX_OFFSET);
=20
-			/* Trim the original skb for the netif. */
-			skb_trim(skb, len);
+			skb_put(skb, len);
 		} else {
-			struct sk_buff *copy_skb =3D dev_alloc_skb(len + 2);
+			struct sk_buff *copy_skb =3D netdev_alloc_skb_ip_align(dev, len);
=20
 			if (copy_skb =3D=3D NULL) {
 				drops++;
 				goto drop_it;
 			}
=20
-			skb_reserve(copy_skb, 2);
 			skb_put(copy_skb, len);
 			dma_sync_single_for_cpu(hp->dma_dev, dma_addr, len, DMA_FROM_DEVICE=
);
 			skb_copy_from_linear_data(skb, copy_skb->data, len);
diff --git a/drivers/net/sunhme.h b/drivers/net/sunhme.h
index 64f2783..f584eb0 100644
--- a/drivers/net/sunhme.h
+++ b/drivers/net/sunhme.h
@@ -495,18 +495,6 @@ struct quattro {
 	int			  nranges;
 };
=20
-/* We use this to acquire receive skb's that we can DMA directly into.=
 */
-#define ALIGNED_RX_SKB_ADDR(addr) \
-        ((((unsigned long)(addr) + (64UL - 1UL)) & ~(64UL - 1UL)) - (u=
nsigned long)(addr))
-#define happy_meal_alloc_skb(__length, __gfp_flags) \
-({	struct sk_buff *__skb; \
-	__skb =3D alloc_skb((__length) + 64, (__gfp_flags)); \
-	if(__skb) { \
-		int __offset =3D (int) ALIGNED_RX_SKB_ADDR(__skb->data); \
-		if(__offset) \
-			skb_reserve(__skb, __offset); \
-	} \
-	__skb; \
-})
+#define SUNHME_RX_ALIGNMENT 64
=20
 #endif /* !(_SUNHME_H) */
--=20
1.7.5.4

