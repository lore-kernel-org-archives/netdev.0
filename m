From: Nathan Hintz <nlhintz@hotmail.com>
Subject: [PATCH v2] bgmac: don't update slot on skb alloc/dma mapping error
Date: Tue, 29 Oct 2013 19:32:01 -0700
Message-ID: <BLU0-SMTP255BD097115C7E52E264D41AC0A0@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: zajec5@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from blu0-omc1-s35.blu0.hotmail.com ([65.55.116.46]:17457 "EHLO
	blu0-omc1-s35.blu0.hotmail.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751292Ab3J3CcF convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Oct 2013 22:32:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Don't update the slot in "bgmac_dma_rx_skb_for_slot" unless both the
skb alloc and dma mapping are successful; and free the newly allocated
skb if a dma mapping error occurs.  This relieves the caller of the nee=
d
to deduce/execute the appropriate cleanup action required when an error
occurs.

Signed-off-by: Nathan Hintz <nlhintz@hotmail.com>
Acked-by: Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com>

---

v2: Revised commit message
---
 drivers/net/ethernet/broadcom/bgmac.c | 20 ++++++++++++++------
 1 file changed, 14 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/ethern=
et/broadcom/bgmac.c
index 7eca5a1..11e5d8d 100644
--- a/drivers/net/ethernet/broadcom/bgmac.c
+++ b/drivers/net/ethernet/broadcom/bgmac.c
@@ -252,25 +252,33 @@ static int bgmac_dma_rx_skb_for_slot(struct bgmac=
 *bgmac,
 				     struct bgmac_slot_info *slot)
 {
 	struct device *dma_dev =3D bgmac->core->dma_dev;
+	struct sk_buff *skb;
+	dma_addr_t dma_addr;
 	struct bgmac_rx_header *rx;
=20
 	/* Alloc skb */
-	slot->skb =3D netdev_alloc_skb(bgmac->net_dev, BGMAC_RX_BUF_SIZE);
-	if (!slot->skb)
+	skb =3D netdev_alloc_skb(bgmac->net_dev, BGMAC_RX_BUF_SIZE);
+	if (!skb)
 		return -ENOMEM;
=20
 	/* Poison - if everything goes fine, hardware will overwrite it */
-	rx =3D (struct bgmac_rx_header *)slot->skb->data;
+	rx =3D (struct bgmac_rx_header *)skb->data;
 	rx->len =3D cpu_to_le16(0xdead);
 	rx->flags =3D cpu_to_le16(0xbeef);
=20
 	/* Map skb for the DMA */
-	slot->dma_addr =3D dma_map_single(dma_dev, slot->skb->data,
-					BGMAC_RX_BUF_SIZE, DMA_FROM_DEVICE);
-	if (dma_mapping_error(dma_dev, slot->dma_addr)) {
+	dma_addr =3D dma_map_single(dma_dev, skb->data,
+				  BGMAC_RX_BUF_SIZE, DMA_FROM_DEVICE);
+	if (dma_mapping_error(dma_dev, dma_addr)) {
 		bgmac_err(bgmac, "DMA mapping error\n");
+		dev_kfree_skb(skb);
 		return -ENOMEM;
 	}
+
+	/* Update the slot */
+	slot->skb =3D skb;
+	slot->dma_addr =3D dma_addr;
+
 	if (slot->dma_addr & 0xC0000000)
 		bgmac_warn(bgmac, "DMA address using 0xC0000000 bit(s), it may need =
translation trick\n");
=20
--=20
1.8.3.1
