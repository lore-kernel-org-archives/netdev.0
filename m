From: =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5@gmail.com>
Subject: [PATCH] bgmac: implement unaligned addressing for DMA rings that support it
Date: Sun, 15 Sep 2013 23:13:18 +0200
Message-ID: <1379279598-25274-1-git-send-email-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Hauke Mehrtens <hauke@hauke-m.de>,
	=?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5@gmail.com>
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f180.google.com ([209.85.215.180]:50632 "EHLO
	mail-ea0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753590Ab3IOVN0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Sep 2013 17:13:26 -0400
Received: by mail-ea0-f180.google.com with SMTP id h10so1619639eaj.39
        for <netdev@vger.kernel.org>; Sun, 15 Sep 2013 14:13:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is important patch for new devices that support unaligned
addressing. That devices suffer from the backward-compatibility bug in
DMA engine. In theory we should be able to use old mechanism, but in
practice DMA address seems to be randomly copied into status register
when hardware reaches end of a ring. This breaks reading slot number
from status register and we can't use DMA anymore.

Signed-off-by: Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com>
---
 drivers/net/ethernet/broadcom/bgmac.c |   38 ++++++++++++++++++++++++-=
--------
 drivers/net/ethernet/broadcom/bgmac.h |    2 ++
 2 files changed, 30 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/ethern=
et/broadcom/bgmac.c
index 59f3e0c..249468f 100644
--- a/drivers/net/ethernet/broadcom/bgmac.c
+++ b/drivers/net/ethernet/broadcom/bgmac.c
@@ -157,6 +157,7 @@ static netdev_tx_t bgmac_dma_tx_add(struct bgmac *b=
gmac,
 	if (++ring->end >=3D BGMAC_TX_RING_SLOTS)
 		ring->end =3D 0;
 	bgmac_write(bgmac, ring->mmio_base + BGMAC_DMA_TX_INDEX,
+		    ring->index_base +
 		    ring->end * sizeof(struct bgmac_dma_desc));
=20
 	/* Always keep one slot free to allow detecting bugged calls. */
@@ -181,6 +182,8 @@ static void bgmac_dma_tx_free(struct bgmac *bgmac, =
struct bgmac_dma_ring *ring)
 	/* The last slot that hardware didn't consume yet */
 	empty_slot =3D bgmac_read(bgmac, ring->mmio_base + BGMAC_DMA_TX_STATU=
S);
 	empty_slot &=3D BGMAC_DMA_TX_STATDPTR;
+	empty_slot -=3D ring->index_base;
+	empty_slot &=3D BGMAC_DMA_TX_STATDPTR;
 	empty_slot /=3D sizeof(struct bgmac_dma_desc);
=20
 	while (ring->start !=3D empty_slot) {
@@ -274,6 +277,8 @@ static int bgmac_dma_rx_read(struct bgmac *bgmac, s=
truct bgmac_dma_ring *ring,
=20
 	end_slot =3D bgmac_read(bgmac, ring->mmio_base + BGMAC_DMA_RX_STATUS)=
;
 	end_slot &=3D BGMAC_DMA_RX_STATDPTR;
+	end_slot -=3D ring->index_base;
+	end_slot &=3D BGMAC_DMA_RX_STATDPTR;
 	end_slot /=3D sizeof(struct bgmac_dma_desc);
=20
 	ring->end =3D end_slot;
@@ -418,9 +423,6 @@ static int bgmac_dma_alloc(struct bgmac *bgmac)
 		ring =3D &bgmac->tx_ring[i];
 		ring->num_slots =3D BGMAC_TX_RING_SLOTS;
 		ring->mmio_base =3D ring_base[i];
-		if (bgmac_dma_unaligned(bgmac, ring, BGMAC_DMA_RING_TX))
-			bgmac_warn(bgmac, "TX on ring 0x%X supports unaligned addressing bu=
t this feature is not implemented\n",
-				   ring->mmio_base);
=20
 		/* Alloc ring of descriptors */
 		size =3D ring->num_slots * sizeof(struct bgmac_dma_desc);
@@ -435,6 +437,13 @@ static int bgmac_dma_alloc(struct bgmac *bgmac)
 		if (ring->dma_base & 0xC0000000)
 			bgmac_warn(bgmac, "DMA address using 0xC0000000 bit(s), it may need=
 translation trick\n");
=20
+		ring->unaligned =3D bgmac_dma_unaligned(bgmac, ring,
+						      BGMAC_DMA_RING_TX);
+		if (ring->unaligned)
+			ring->index_base =3D lower_32_bits(ring->dma_base);
+		else
+			ring->index_base =3D 0;
+
 		/* No need to alloc TX slots yet */
 	}
=20
@@ -444,9 +453,6 @@ static int bgmac_dma_alloc(struct bgmac *bgmac)
 		ring =3D &bgmac->rx_ring[i];
 		ring->num_slots =3D BGMAC_RX_RING_SLOTS;
 		ring->mmio_base =3D ring_base[i];
-		if (bgmac_dma_unaligned(bgmac, ring, BGMAC_DMA_RING_RX))
-			bgmac_warn(bgmac, "RX on ring 0x%X supports unaligned addressing bu=
t this feature is not implemented\n",
-				   ring->mmio_base);
=20
 		/* Alloc ring of descriptors */
 		size =3D ring->num_slots * sizeof(struct bgmac_dma_desc);
@@ -462,6 +468,13 @@ static int bgmac_dma_alloc(struct bgmac *bgmac)
 		if (ring->dma_base & 0xC0000000)
 			bgmac_warn(bgmac, "DMA address using 0xC0000000 bit(s), it may need=
 translation trick\n");
=20
+		ring->unaligned =3D bgmac_dma_unaligned(bgmac, ring,
+						      BGMAC_DMA_RING_RX);
+		if (ring->unaligned)
+			ring->index_base =3D lower_32_bits(ring->dma_base);
+		else
+			ring->index_base =3D 0;
+
 		/* Alloc RX slots */
 		for (j =3D 0; j < ring->num_slots; j++) {
 			err =3D bgmac_dma_rx_skb_for_slot(bgmac, &ring->slots[j]);
@@ -489,12 +502,14 @@ static void bgmac_dma_init(struct bgmac *bgmac)
 	for (i =3D 0; i < BGMAC_MAX_TX_RINGS; i++) {
 		ring =3D &bgmac->tx_ring[i];
=20
-		/* We don't implement unaligned addressing, so enable first */
-		bgmac_dma_tx_enable(bgmac, ring);
+		if (!ring->unaligned)
+			bgmac_dma_tx_enable(bgmac, ring);
 		bgmac_write(bgmac, ring->mmio_base + BGMAC_DMA_TX_RINGLO,
 			    lower_32_bits(ring->dma_base));
 		bgmac_write(bgmac, ring->mmio_base + BGMAC_DMA_TX_RINGHI,
 			    upper_32_bits(ring->dma_base));
+		if (ring->unaligned)
+			bgmac_dma_tx_enable(bgmac, ring);
=20
 		ring->start =3D 0;
 		ring->end =3D 0;	/* Points the slot that should *not* be read */
@@ -505,12 +520,14 @@ static void bgmac_dma_init(struct bgmac *bgmac)
=20
 		ring =3D &bgmac->rx_ring[i];
=20
-		/* We don't implement unaligned addressing, so enable first */
-		bgmac_dma_rx_enable(bgmac, ring);
+		if (!ring->unaligned)
+			bgmac_dma_rx_enable(bgmac, ring);
 		bgmac_write(bgmac, ring->mmio_base + BGMAC_DMA_RX_RINGLO,
 			    lower_32_bits(ring->dma_base));
 		bgmac_write(bgmac, ring->mmio_base + BGMAC_DMA_RX_RINGHI,
 			    upper_32_bits(ring->dma_base));
+		if (ring->unaligned)
+			bgmac_dma_rx_enable(bgmac, ring);
=20
 		for (j =3D 0, dma_desc =3D ring->cpu_base; j < ring->num_slots;
 		     j++, dma_desc++) {
@@ -531,6 +548,7 @@ static void bgmac_dma_init(struct bgmac *bgmac)
 		}
=20
 		bgmac_write(bgmac, ring->mmio_base + BGMAC_DMA_RX_INDEX,
+			    ring->index_base +
 			    ring->num_slots * sizeof(struct bgmac_dma_desc));
=20
 		ring->start =3D 0;
diff --git a/drivers/net/ethernet/broadcom/bgmac.h b/drivers/net/ethern=
et/broadcom/bgmac.h
index 12a35cf..66c8afb 100644
--- a/drivers/net/ethernet/broadcom/bgmac.h
+++ b/drivers/net/ethernet/broadcom/bgmac.h
@@ -384,6 +384,8 @@ struct bgmac_dma_ring {
 	u16 mmio_base;
 	struct bgmac_dma_desc *cpu_base;
 	dma_addr_t dma_base;
+	u32 index_base; /* Used for unaligned rings only, otherwise 0 */
+	bool unaligned;
=20
 	struct bgmac_slot_info slots[BGMAC_RX_RING_SLOTS];
 };
--=20
1.7.10.4
