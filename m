From: =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5@gmail.com>
Subject: [PATCH][FIX] bgmac: fix indexing of 2nd level loops
Date: Mon, 25 Feb 2013 19:22:26 +0100
Message-ID: <1361816546-10171-1-git-send-email-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Tijs Van Buggenhout <tvb@able.be>,
	=?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5@gmail.com>
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:56200 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754529Ab3BYSWd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Feb 2013 13:22:33 -0500
Received: by mail-ee0-f46.google.com with SMTP id e49so1548711eek.5
        for <netdev@vger.kernel.org>; Mon, 25 Feb 2013 10:22:32 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We were using the same variable for iterating two nested loops.

Reported-by: Tijs Van Buggenhout <tvb@able.be>
Signed-off-by: Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com>
---
Luckily it didn't case any real errors (thanks to the loops limits) but
I think it's ugly enough to make it a "FIX" anyway.
---
 drivers/net/ethernet/broadcom/bgmac.c |   18 +++++++++++-------
 1 file changed, 11 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/ethern=
et/broadcom/bgmac.c
index 67a03d5..3f62bef 100644
--- a/drivers/net/ethernet/broadcom/bgmac.c
+++ b/drivers/net/ethernet/broadcom/bgmac.c
@@ -436,6 +436,8 @@ static int bgmac_dma_alloc(struct bgmac *bgmac)
 	}
=20
 	for (i =3D 0; i < BGMAC_MAX_RX_RINGS; i++) {
+		int j;
+
 		ring =3D &bgmac->rx_ring[i];
 		ring->num_slots =3D BGMAC_RX_RING_SLOTS;
 		ring->mmio_base =3D ring_base[i];
@@ -458,8 +460,8 @@ static int bgmac_dma_alloc(struct bgmac *bgmac)
 			bgmac_warn(bgmac, "DMA address using 0xC0000000 bit(s), it may need=
 translation trick\n");
=20
 		/* Alloc RX slots */
-		for (i =3D 0; i < ring->num_slots; i++) {
-			err =3D bgmac_dma_rx_skb_for_slot(bgmac, &ring->slots[i]);
+		for (j =3D 0; j < ring->num_slots; j++) {
+			err =3D bgmac_dma_rx_skb_for_slot(bgmac, &ring->slots[j]);
 			if (err) {
 				bgmac_err(bgmac, "Can't allocate skb for slot in RX ring\n");
 				goto err_dma_free;
@@ -496,6 +498,8 @@ static void bgmac_dma_init(struct bgmac *bgmac)
 	}
=20
 	for (i =3D 0; i < BGMAC_MAX_RX_RINGS; i++) {
+		int j;
+
 		ring =3D &bgmac->rx_ring[i];
=20
 		/* We don't implement unaligned addressing, so enable first */
@@ -505,11 +509,11 @@ static void bgmac_dma_init(struct bgmac *bgmac)
 		bgmac_write(bgmac, ring->mmio_base + BGMAC_DMA_RX_RINGHI,
 			    upper_32_bits(ring->dma_base));
=20
-		for (i =3D 0, dma_desc =3D ring->cpu_base; i < ring->num_slots;
-		     i++, dma_desc++) {
+		for (j =3D 0, dma_desc =3D ring->cpu_base; j < ring->num_slots;
+		     j++, dma_desc++) {
 			ctl0 =3D ctl1 =3D 0;
=20
-			if (i =3D=3D ring->num_slots - 1)
+			if (j =3D=3D ring->num_slots - 1)
 				ctl0 |=3D BGMAC_DESC_CTL0_EOT;
 			ctl1 |=3D BGMAC_RX_BUF_SIZE & BGMAC_DESC_CTL1_LEN;
 			/* Is there any BGMAC device that requires extension? */
@@ -517,8 +521,8 @@ static void bgmac_dma_init(struct bgmac *bgmac)
 			 * B43_DMA64_DCTL1_ADDREXT_MASK;
 			 */
=20
-			dma_desc->addr_low =3D cpu_to_le32(lower_32_bits(ring->slots[i].dma=
_addr));
-			dma_desc->addr_high =3D cpu_to_le32(upper_32_bits(ring->slots[i].dm=
a_addr));
+			dma_desc->addr_low =3D cpu_to_le32(lower_32_bits(ring->slots[j].dma=
_addr));
+			dma_desc->addr_high =3D cpu_to_le32(upper_32_bits(ring->slots[j].dm=
a_addr));
 			dma_desc->ctl0 =3D cpu_to_le32(ctl0);
 			dma_desc->ctl1 =3D cpu_to_le32(ctl1);
 		}
--=20
1.7.10.4
