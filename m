From: =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5@gmail.com>
Subject: [RFC TRY#2][PATCH] bgmac: pass received packet to the netif instead of copying it
Date: Mon, 28 Oct 2013 18:42:22 +0100
Message-ID: <1382982142-16876-1-git-send-email-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: openwrt-devel@lists.openwrt.org,
	=?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5@gmail.com>
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f42.google.com ([74.125.83.42]:53413 "EHLO
	mail-ee0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757225Ab3J1Rm2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Oct 2013 13:42:28 -0400
Received: by mail-ee0-f42.google.com with SMTP id b45so4740145eek.1
        for <netdev@vger.kernel.org>; Mon, 28 Oct 2013 10:42:27 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Copying whole packets with skb_copy_from_linear_data_offset is a pretty
bad idea. CPU was spending time in __copy_user_common and network
performance was lower. With the new solution iperf-measured speed
increased from 116Mb/s to 134Mb/s.

Another way to improve performance could be switching to build_skb. It
is cache-specific, so will require testing of various devices.

Signed-off-by: Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com>
---
 drivers/net/ethernet/broadcom/bgmac.c |   71 ++++++++++++++++++++-----=
--------
 1 file changed, 44 insertions(+), 27 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/ethern=
et/broadcom/bgmac.c
index 6b7541f..fde9a11 100644
--- a/drivers/net/ethernet/broadcom/bgmac.c
+++ b/drivers/net/ethernet/broadcom/bgmac.c
@@ -307,7 +307,6 @@ static int bgmac_dma_rx_read(struct bgmac *bgmac, s=
truct bgmac_dma_ring *ring,
 		struct device *dma_dev =3D bgmac->core->dma_dev;
 		struct bgmac_slot_info *slot =3D &ring->slots[ring->start];
 		struct sk_buff *skb =3D slot->skb;
-		struct sk_buff *new_skb;
 		struct bgmac_rx_header *rx;
 		u16 len, flags;
=20
@@ -320,38 +319,56 @@ static int bgmac_dma_rx_read(struct bgmac *bgmac,=
 struct bgmac_dma_ring *ring,
 		len =3D le16_to_cpu(rx->len);
 		flags =3D le16_to_cpu(rx->flags);
=20
-		/* Check for poison and drop or pass the packet */
-		if (len =3D=3D 0xdead && flags =3D=3D 0xbeef) {
-			bgmac_err(bgmac, "Found poisoned packet at slot %d, DMA issue!\n",
-				  ring->start);
-		} else {
+		do {
+			struct sk_buff *old_skb =3D slot->skb;
+			dma_addr_t old_dma_addr =3D slot->dma_addr;
+			int err;
+
+			/* Check for poison and drop or pass the packet */
+			if (len =3D=3D 0xdead && flags =3D=3D 0xbeef) {
+				bgmac_err(bgmac, "Found poisoned packet at slot %d, DMA issue!\n",
+					  ring->start);
+				dma_sync_single_for_device(dma_dev,
+							   slot->dma_addr,
+							   BGMAC_RX_BUF_SIZE,
+							   DMA_FROM_DEVICE);
+				break;
+			}
+
 			/* Omit CRC. */
 			len -=3D ETH_FCS_LEN;
=20
-			new_skb =3D netdev_alloc_skb_ip_align(bgmac->net_dev, len);
-			if (new_skb) {
-				skb_put(new_skb, len);
-				skb_copy_from_linear_data_offset(skb, BGMAC_RX_FRAME_OFFSET,
-								 new_skb->data,
-								 len);
-				skb_checksum_none_assert(skb);
-				new_skb->protocol =3D
-					eth_type_trans(new_skb, bgmac->net_dev);
-				netif_receive_skb(new_skb);
-				handled++;
-			} else {
-				bgmac->net_dev->stats.rx_dropped++;
-				bgmac_err(bgmac, "Allocation of skb for copying packet failed!\n")=
;
+			/* Prepare new skb as replacement */
+			err =3D bgmac_dma_rx_skb_for_slot(bgmac, slot);
+			if (err) {
+				slot->skb =3D old_skb;
+				slot->dma_addr =3D old_dma_addr;
+
+				/* Poison the old skb */
+				rx->len =3D cpu_to_le16(0xdead);
+				rx->flags =3D cpu_to_le16(0xbeef);
+
+				dma_sync_single_for_device(dma_dev,
+							   slot->dma_addr,
+							   BGMAC_RX_BUF_SIZE,
+							   DMA_FROM_DEVICE);
+				break;
 			}
+			bgmac_dma_rx_setup_desc(bgmac, ring, ring->start);
=20
-			/* Poison the old skb */
-			rx->len =3D cpu_to_le16(0xdead);
-			rx->flags =3D cpu_to_le16(0xbeef);
-		}
+			/* Unmap old skb, we'll pass it to the netfif */
+			dma_unmap_single(dma_dev, old_dma_addr,
+						BGMAC_RX_BUF_SIZE,
+						DMA_FROM_DEVICE);
+
+			skb_put(skb, BGMAC_RX_FRAME_OFFSET + len);
+			skb_pull(skb, BGMAC_RX_FRAME_OFFSET);
=20
-		/* Make it back accessible to the hardware */
-		dma_sync_single_for_device(dma_dev, slot->dma_addr,
-					   BGMAC_RX_BUF_SIZE, DMA_FROM_DEVICE);
+			skb_checksum_none_assert(skb);
+			skb->protocol =3D eth_type_trans(skb, bgmac->net_dev);
+			netif_receive_skb(skb);
+			handled++;
+		} while (0);
=20
 		if (++ring->start >=3D BGMAC_RX_RING_SLOTS)
 			ring->start =3D 0;
--=20
1.7.10.4
