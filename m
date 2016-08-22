From: Zefir Kurtisi <zefir.kurtisi@neratec.com>
Subject: [PATCH v2] gianfar: fix size of scatter-gathered frames
Date: Mon, 22 Aug 2016 15:58:12 +0200
Message-ID: <1471874292-15425-1-git-send-email-zefir.kurtisi@neratec.com>
References: <1471598156-16875-1-git-send-email-zefir.kurtisi@neratec.com>
Cc: zefir.kurtisi@neratec.com, claudiu.manoil@freescale.com,
        andrew@lunn.ch
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.neratec.com ([46.140.151.2]:40432 "EHLO mail.neratec.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753151AbcHVN6O (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 22 Aug 2016 09:58:14 -0400
In-Reply-To: <1471598156-16875-1-git-send-email-zefir.kurtisi@neratec.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The current scatter-gather logic in gianfar is flawed, since
it does not consider the eTSEC's RxBD 'Data Length' field is
context depening: for the last fragment it contains the full
frame size, while fragments contain the fragment size, which
equals the value written to register MRBLR.

This causes data corruption as soon as the hardware starts
to fragment receiving frames. As a result, the size of
fragmented frames is increased by
(nr_frags - 1) * MRBLR

We first noticed this issue working with DSA, where an ICMP
request sized 1472 bytes causes the scatter-gather logic to
kick in. The full Ethernet frame (1518) gets increased by
DSA (4), GMAC_FCB_LEN (8), and FSL_GIANFAR_DEV_HAS_TIMER
(priv->padding=8) to a total of 1538 octets, which is
fragmented by the hardware and reconstructed by the driver
to a 3074 octet frame.

This patch fixes the problem by adjusting the size of
the last fragment.

It was tested by setting MRBLR to different multiples of
64, proving correct scatter-gather operation on frames
with up to 9000 octets in size.

Signed-off-by: Zefir Kurtisi <zefir.kurtisi@neratec.com>
---
 drivers/net/ethernet/freescale/gianfar.c | 20 ++++++++++++++------
 1 file changed, 14 insertions(+), 6 deletions(-)

Changes to v1:
* removed check for total length exceeding sum of fragments
  (as suggested by Claudiu Manoil)
* updated commit log for clarification

diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index d20935d..4b4f5bc 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -2922,17 +2922,25 @@ static bool gfar_add_rx_frag(struct gfar_rx_buff *rxb, u32 lstatus,
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
+		/* in case the last fragment consisted only of the FCS */
+		if (size > 0)
+			skb_add_rx_frag(skb, skb_shinfo(skb)->nr_frags, page,
+					rxb->page_offset + RXBUF_ALIGNMENT,
+					size, GFAR_RXB_TRUESIZE);
+	}
 
 	/* try reuse page */
 	if (unlikely(page_count(page) != 1))
-- 
2.7.4
