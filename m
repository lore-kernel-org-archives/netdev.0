From: =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5@gmail.com>
Subject: [PATCH] bgmac: separate RX descriptor setup code into a new function
Date: Mon, 28 Oct 2013 14:40:29 +0100
Message-ID: <1382967629-3794-1-git-send-email-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5@gmail.com>
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f172.google.com ([209.85.215.172]:38061 "EHLO
	mail-ea0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756004Ab3J1Nkt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Oct 2013 09:40:49 -0400
Received: by mail-ea0-f172.google.com with SMTP id r16so2245450ead.3
        for <netdev@vger.kernel.org>; Mon, 28 Oct 2013 06:40:48 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This cleans code a bit and will be useful when allocating buffers in
other places (like RX path, to avoid skb_copy_from_linear_data_offset).

Signed-off-by: Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com>
---
 drivers/net/ethernet/broadcom/bgmac.c |   41 ++++++++++++++++++-------=
--------
 1 file changed, 22 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/ethern=
et/broadcom/bgmac.c
index e7d98ea..6b7541f 100644
--- a/drivers/net/ethernet/broadcom/bgmac.c
+++ b/drivers/net/ethernet/broadcom/bgmac.c
@@ -269,6 +269,26 @@ static int bgmac_dma_rx_skb_for_slot(struct bgmac =
*bgmac,
 	return 0;
 }
=20
+static void bgmac_dma_rx_setup_desc(struct bgmac *bgmac,
+				    struct bgmac_dma_ring *ring, int desc_idx)
+{
+	struct bgmac_dma_desc *dma_desc =3D ring->cpu_base + desc_idx;
+	u32 ctl0 =3D 0, ctl1 =3D 0;
+
+	if (desc_idx =3D=3D ring->num_slots - 1)
+		ctl0 |=3D BGMAC_DESC_CTL0_EOT;
+	ctl1 |=3D BGMAC_RX_BUF_SIZE & BGMAC_DESC_CTL1_LEN;
+	/* Is there any BGMAC device that requires extension? */
+	/* ctl1 |=3D (addrext << B43_DMA64_DCTL1_ADDREXT_SHIFT) &
+	 * B43_DMA64_DCTL1_ADDREXT_MASK;
+	 */
+
+	dma_desc->addr_low =3D cpu_to_le32(lower_32_bits(ring->slots[desc_idx=
].dma_addr));
+	dma_desc->addr_high =3D cpu_to_le32(upper_32_bits(ring->slots[desc_id=
x].dma_addr));
+	dma_desc->ctl0 =3D cpu_to_le32(ctl0);
+	dma_desc->ctl1 =3D cpu_to_le32(ctl1);
+}
+
 static int bgmac_dma_rx_read(struct bgmac *bgmac, struct bgmac_dma_rin=
g *ring,
 			     int weight)
 {
@@ -491,8 +511,6 @@ err_dma_free:
 static void bgmac_dma_init(struct bgmac *bgmac)
 {
 	struct bgmac_dma_ring *ring;
-	struct bgmac_dma_desc *dma_desc;
-	u32 ctl0, ctl1;
 	int i;
=20
 	for (i =3D 0; i < BGMAC_MAX_TX_RINGS; i++) {
@@ -525,23 +543,8 @@ static void bgmac_dma_init(struct bgmac *bgmac)
 		if (ring->unaligned)
 			bgmac_dma_rx_enable(bgmac, ring);
=20
-		for (j =3D 0, dma_desc =3D ring->cpu_base; j < ring->num_slots;
-		     j++, dma_desc++) {
-			ctl0 =3D ctl1 =3D 0;
-
-			if (j =3D=3D ring->num_slots - 1)
-				ctl0 |=3D BGMAC_DESC_CTL0_EOT;
-			ctl1 |=3D BGMAC_RX_BUF_SIZE & BGMAC_DESC_CTL1_LEN;
-			/* Is there any BGMAC device that requires extension? */
-			/* ctl1 |=3D (addrext << B43_DMA64_DCTL1_ADDREXT_SHIFT) &
-			 * B43_DMA64_DCTL1_ADDREXT_MASK;
-			 */
-
-			dma_desc->addr_low =3D cpu_to_le32(lower_32_bits(ring->slots[j].dma=
_addr));
-			dma_desc->addr_high =3D cpu_to_le32(upper_32_bits(ring->slots[j].dm=
a_addr));
-			dma_desc->ctl0 =3D cpu_to_le32(ctl0);
-			dma_desc->ctl1 =3D cpu_to_le32(ctl1);
-		}
+		for (j =3D 0; j < ring->num_slots; j++)
+			bgmac_dma_rx_setup_desc(bgmac, ring, j);
=20
 		bgmac_write(bgmac, ring->mmio_base + BGMAC_DMA_RX_INDEX,
 			    ring->index_base +
--=20
1.7.10.4
