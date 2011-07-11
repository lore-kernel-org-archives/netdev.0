From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH v2 11/46] net: sungem: cleanup RX skb allocation
Date: Mon, 11 Jul 2011 02:52:49 +0200 (CEST)
Message-ID: <27159b96d84ff918d7654a0f6a9511630154a2d7.1310339688.git.mirq-linux@rere.qmqm.pl>
References: <cover.1310339688.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:43683 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751794Ab1GKAwx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 10 Jul 2011 20:52:53 -0400
In-Reply-To: <cover.1310339688.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 drivers/net/sungem.c |   34 +++++++++++-----------------------
 drivers/net/sungem.h |    4 +++-
 2 files changed, 14 insertions(+), 24 deletions(-)

diff --git a/drivers/net/sungem.c b/drivers/net/sungem.c
index ade35dd..e82617f 100644
--- a/drivers/net/sungem.c
+++ b/drivers/net/sungem.c
@@ -743,21 +743,6 @@ static __inline__ void gem_post_rxds(struct gem *g=
p, int limit)
 	}
 }
=20
-#define ALIGNED_RX_SKB_ADDR(addr) \
-        ((((unsigned long)(addr) + (64UL - 1UL)) & ~(64UL - 1UL)) - (u=
nsigned long)(addr))
-static __inline__ struct sk_buff *gem_alloc_skb(struct net_device *dev=
, int size,
-						gfp_t gfp_flags)
-{
-	struct sk_buff *skb =3D alloc_skb(size + 64, gfp_flags);
-
-	if (likely(skb)) {
-		unsigned long offset =3D ALIGNED_RX_SKB_ADDR(skb->data);
-		skb_reserve(skb, offset);
-		skb->dev =3D dev;
-	}
-	return skb;
-}
-
 static int gem_rx(struct gem *gp, int work_to_do)
 {
 	struct net_device *dev =3D gp->dev;
@@ -821,7 +806,10 @@ static int gem_rx(struct gem *gp, int work_to_do)
 		if (len > RX_COPY_THRESHOLD) {
 			struct sk_buff *new_skb;
=20
-			new_skb =3D gem_alloc_skb(dev, RX_BUF_ALLOC_SIZE(gp), GFP_ATOMIC);
+			new_skb =3D __netdev_alloc_skb_aligned(dev,
+							     RX_BUF_ALLOC_SIZE(gp),
+							     SUNGEM_RX_ALIGNMENT,
+							     GFP_ATOMIC);
 			if (new_skb =3D=3D NULL) {
 				drops++;
 				goto drop_it;
@@ -830,7 +818,6 @@ static int gem_rx(struct gem *gp, int work_to_do)
 				       RX_BUF_ALLOC_SIZE(gp),
 				       PCI_DMA_FROMDEVICE);
 			gp->rx_skbs[entry] =3D new_skb;
-			skb_put(new_skb, (gp->rx_buf_sz + RX_OFFSET));
 			rxd->buffer =3D cpu_to_le64(pci_map_page(gp->pdev,
 							       virt_to_page(new_skb->data),
 							       offset_in_page(new_skb->data),
@@ -838,17 +825,16 @@ static int gem_rx(struct gem *gp, int work_to_do)
 							       PCI_DMA_FROMDEVICE));
 			skb_reserve(new_skb, RX_OFFSET);
=20
-			/* Trim the original skb for the netif. */
-			skb_trim(skb, len);
+			skb_put(skb, len);
 		} else {
-			struct sk_buff *copy_skb =3D netdev_alloc_skb(dev, len + 2);
+			struct sk_buff *copy_skb =3D
+				netdev_alloc_skb_ip_align(dev, len);
=20
 			if (copy_skb =3D=3D NULL) {
 				drops++;
 				goto drop_it;
 			}
=20
-			skb_reserve(copy_skb, 2);
 			skb_put(copy_skb, len);
 			pci_dma_sync_single_for_cpu(gp->pdev, dma_addr, len, PCI_DMA_FROMDE=
VICE);
 			skb_copy_from_linear_data(skb, copy_skb->data, len);
@@ -1637,7 +1623,10 @@ static void gem_init_rings(struct gem *gp)
 		struct sk_buff *skb;
 		struct gem_rxd *rxd =3D &gb->rxd[i];
=20
-		skb =3D gem_alloc_skb(dev, RX_BUF_ALLOC_SIZE(gp), GFP_KERNEL);
+		skb =3D __netdev_alloc_skb_aligned(dev,
+						 RX_BUF_ALLOC_SIZE(gp),
+						 SUNGEM_RX_ALIGNMENT,
+						 GFP_KERNEL);
 		if (!skb) {
 			rxd->buffer =3D 0;
 			rxd->status_word =3D 0;
@@ -1645,7 +1634,6 @@ static void gem_init_rings(struct gem *gp)
 		}
=20
 		gp->rx_skbs[i] =3D skb;
-		skb_put(skb, (gp->rx_buf_sz + RX_OFFSET));
 		dma_addr =3D pci_map_page(gp->pdev,
 					virt_to_page(skb->data),
 					offset_in_page(skb->data),
diff --git a/drivers/net/sungem.h b/drivers/net/sungem.h
index 835ce1b..0d486ce 100644
--- a/drivers/net/sungem.h
+++ b/drivers/net/sungem.h
@@ -935,7 +935,9 @@ struct gem_rxd {
 	  (GP)->tx_old - (GP)->tx_new - 1)
=20
 #define RX_OFFSET          2
-#define RX_BUF_ALLOC_SIZE(gp)	((gp)->rx_buf_sz + 28 + RX_OFFSET + 64)
+#define SUNGEM_RX_ALIGNMENT 64		/* min: cache line size, see comment a=
bove */
+#define RX_BUF_ALLOC_SIZE(gp)	\
+	ALIGN((gp)->rx_buf_sz + RX_OFFSET, SUNGEM_RX_ALIGNMENT)
=20
 #define RX_COPY_THRESHOLD  256
=20
--=20
1.7.5.4

