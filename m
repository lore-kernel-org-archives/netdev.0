From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH v2 13/46] net: sunbmac: cleanup RX skb allocation
Date: Mon, 11 Jul 2011 02:52:49 +0200 (CEST)
Message-ID: <c33610b18030ca66e1ca59b9fcca539a559d5ae0.1310339688.git.mirq-linux@rere.qmqm.pl>
References: <cover.1310339688.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:43684 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753611Ab1GKAwx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 10 Jul 2011 20:52:53 -0400
In-Reply-To: <cover.1310339688.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 drivers/net/sunbmac.c |   22 +++++++++++-----------
 drivers/net/sunbmac.h |   18 +-----------------
 2 files changed, 12 insertions(+), 28 deletions(-)

diff --git a/drivers/net/sunbmac.c b/drivers/net/sunbmac.c
index 297a424..e28d3ea 100644
--- a/drivers/net/sunbmac.c
+++ b/drivers/net/sunbmac.c
@@ -228,15 +228,15 @@ static void bigmac_init_rings(struct bigmac *bp, =
int from_irq)
 	for (i =3D 0; i < RX_RING_SIZE; i++) {
 		struct sk_buff *skb;
=20
-		skb =3D big_mac_alloc_skb(RX_BUF_ALLOC_SIZE, gfp_flags);
+		skb =3D __netdev_alloc_skb_aligned(dev,
+						 RX_BUF_ALLOC_SIZE,
+						 SUNBMAC_RX_ALIGNMENT,
+						 gfp_flags);
 		if (!skb)
 			continue;
=20
 		bp->rx_skbs[i] =3D skb;
-		skb->dev =3D dev;
=20
-		/* Because we reserve afterwards. */
-		skb_put(skb, ETH_FRAME_LEN);
 		skb_reserve(skb, 34);
=20
 		bb->be_rxd[i].rx_addr =3D
@@ -828,7 +828,10 @@ static void bigmac_rx(struct bigmac *bp)
 			struct sk_buff *new_skb;
=20
 			/* Now refill the entry, if we can. */
-			new_skb =3D big_mac_alloc_skb(RX_BUF_ALLOC_SIZE, GFP_ATOMIC);
+			new_skb =3D __netdev_alloc_skb_aligned(dev,
+							     RX_BUF_ALLOC_SIZE,
+							     SUNBMAC_RX_ALIGNMENT,
+							     GFP_ATOMIC);
 			if (new_skb =3D=3D NULL) {
 				drops++;
 				goto drop_it;
@@ -838,8 +841,6 @@ static void bigmac_rx(struct bigmac *bp)
 					 RX_BUF_ALLOC_SIZE - 34,
 					 DMA_FROM_DEVICE);
 			bp->rx_skbs[elem] =3D new_skb;
-			new_skb->dev =3D bp->dev;
-			skb_put(new_skb, ETH_FRAME_LEN);
 			skb_reserve(new_skb, 34);
 			this->rx_addr =3D
 				dma_map_single(&bp->bigmac_op->dev,
@@ -849,16 +850,15 @@ static void bigmac_rx(struct bigmac *bp)
 			this->rx_flags =3D
 				(RXD_OWN | ((RX_BUF_ALLOC_SIZE - 34) & RXD_LENGTH));
=20
-			/* Trim the original skb for the netif. */
-			skb_trim(skb, len);
+			skb_put(skb, len);
 		} else {
-			struct sk_buff *copy_skb =3D dev_alloc_skb(len + 2);
+			struct sk_buff *copy_skb =3D
+				netdev_alloc_skb_ip_align(dev, len);
=20
 			if (copy_skb =3D=3D NULL) {
 				drops++;
 				goto drop_it;
 			}
-			skb_reserve(copy_skb, 2);
 			skb_put(copy_skb, len);
 			dma_sync_single_for_cpu(&bp->bigmac_op->dev,
 						this->rx_addr, len,
diff --git a/drivers/net/sunbmac.h b/drivers/net/sunbmac.h
index 4943e97..63dab2f 100644
--- a/drivers/net/sunbmac.h
+++ b/drivers/net/sunbmac.h
@@ -334,22 +334,6 @@ struct bigmac {
 	struct net_device	*dev;
 };
=20
-/* We use this to acquire receive skb's that we can DMA directly into.=
 */
-#define ALIGNED_RX_SKB_ADDR(addr) \
-        ((((unsigned long)(addr) + (64 - 1)) & ~(64 - 1)) - (unsigned =
long)(addr))
-
-static inline struct sk_buff *big_mac_alloc_skb(unsigned int length, g=
fp_t gfp_flags)
-{
-	struct sk_buff *skb;
-
-	skb =3D alloc_skb(length + 64, gfp_flags);
-	if(skb) {
-		int offset =3D ALIGNED_RX_SKB_ADDR(skb->data);
-
-		if(offset)
-			skb_reserve(skb, offset);
-	}
-	return skb;
-}
+#define SUNBMAC_RX_ALIGNMENT 64
=20
 #endif /* !(_SUNBMAC_H) */
--=20
1.7.5.4

