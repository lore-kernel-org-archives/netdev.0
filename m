From: Zefir Kurtisi <zefir.kurtisi@neratec.com>
Subject: [PATCH] gianfar: fix size of fragmented frames
Date: Fri, 19 Aug 2016 11:15:56 +0200
Message-ID: <1471598156-16875-1-git-send-email-zefir.kurtisi@neratec.com>
Cc: claudiu.manoil@freescale.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.neratec.com ([46.140.151.2]:47188 "EHLO mail.neratec.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750879AbcHSJZD (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 19 Aug 2016 05:25:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The eTSEC RxBD 'Data Length' field is context depening:
for the last fragment it contains the full frame size,
while fragments contain the fragment size, which equals
the value written to register MRBLR.

This differentiation is missing in the gianfar driver,
which causes data corruption as soon as the hardware
starts to fragment receiving frames. As a result, the
size of fragmented frames is increased by
(nr_frags - 1) * MRBLR

We first noticed this issue working with DSA, where a
1540 octet frame is fragmented by the hardware and
reconstructed by the driver as 3076 octet frame.

This patch fixes the problem by adjusting the size of
the last fragment.

Signed-off-by: Zefir Kurtisi <zefir.kurtisi@neratec.com>
---
 drivers/net/ethernet/freescale/gianfar.c | 19 +++++++++++++------
 1 file changed, 13 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index d20935d..4187280 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -2922,17 +2922,24 @@ static bool gfar_add_rx_frag(struct gfar_rx_buff *rxb, u32 lstatus,
 {
 	unsigned int size = lstatus & BD_LENGTH_MASK;
 	struct page *page = rxb->page;
+	bool last = !!(lstatus & BD_LFLAG(RXBD_LAST));
 
 	/* Remove the FCS from the packet length */
-	if (likely(lstatus & BD_LFLAG(RXBD_LAST)))
+	if (last)
 		size -= ETH_FCS_LEN;
 
-	if (likely(first))
+	if (likely(first)) {
 		skb_put(skb, size);
-	else
-		skb_add_rx_frag(skb, skb_shinfo(skb)->nr_frags, page,
-				rxb->page_offset + RXBUF_ALIGNMENT,
-				size, GFAR_RXB_TRUESIZE);
+	} else {
+		/* the last fragments' length contains the full frame length */
+		if (last)
+			size -= skb->len;
+
+		if (size > 0 && size <= GFAR_RXB_SIZE)
+			skb_add_rx_frag(skb, skb_shinfo(skb)->nr_frags, page,
+					rxb->page_offset + RXBUF_ALIGNMENT,
+					size, GFAR_RXB_TRUESIZE);
+	}
 
 	/* try reuse page */
 	if (unlikely(page_count(page) != 1))
-- 
2.7.4
