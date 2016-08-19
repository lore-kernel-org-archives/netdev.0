From: Claudiu Manoil <claudiu.manoil@nxp.com>
Subject: RE: [PATCH] gianfar: fix size of fragmented frames
Date: Fri, 19 Aug 2016 16:46:46 +0000
Message-ID: <AM5PR0401MB25613B657270085A3EE4324F96160@AM5PR0401MB2561.eurprd04.prod.outlook.com>
References: <1471598156-16875-1-git-send-email-zefir.kurtisi@neratec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "claudiu.manoil@freescale.com" <claudiu.manoil@freescale.com>
To: Zefir Kurtisi <zefir.kurtisi@neratec.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db5eur01on0073.outbound.protection.outlook.com ([104.47.2.73]:16256
        "EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1754959AbcHSQqu (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 19 Aug 2016 12:46:50 -0400
In-Reply-To: <1471598156-16875-1-git-send-email-zefir.kurtisi@neratec.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: Zefir Kurtisi [mailto:zefir.kurtisi@neratec.com]
>Sent: Friday, August 19, 2016 12:16 PM
>To: netdev@vger.kernel.org
>Cc: claudiu.manoil@freescale.com
>Subject: [PATCH] gianfar: fix size of fragmented frames
>
>The eTSEC RxBD 'Data Length' field is context depening:
>for the last fragment it contains the full frame size,
>while fragments contain the fragment size, which equals
>the value written to register MRBLR.
>

According to RM the last fragment has the whole packet length indeed,
and this should apply to fragmented frames too:

" Data length, written by the eTSEC.
Data length is the number of octets written by the eTSEC into this BD's dat=
a buffer if L is cleared
(the value is equal to MRBLR), or, if L is set, the length of the frame inc=
luding CRC, FCB (if
RCTRL[PRSDEP > 00), preamble (if MACCFG2[PreAmRxEn]=3D1), time stamp (if RC=
TRL[TS] =3D 1)
and any padding (RCTRL[PAL]). "

>This differentiation is missing in the gianfar driver,
>which causes data corruption as soon as the hardware
>starts to fragment receiving frames. As a result, the
>size of fragmented frames is increased by
>(nr_frags - 1) * MRBLR
>
>We first noticed this issue working with DSA, where a
>1540 octet frame is fragmented by the hardware and
>reconstructed by the driver as 3076 octet frame.
>
>This patch fixes the problem by adjusting the size of
>the last fragment.
>
>Signed-off-by: Zefir Kurtisi <zefir.kurtisi@neratec.com>
>---
> drivers/net/ethernet/freescale/gianfar.c | 19 +++++++++++++------
> 1 file changed, 13 insertions(+), 6 deletions(-)
>
>diff --git a/drivers/net/ethernet/freescale/gianfar.c
>b/drivers/net/ethernet/freescale/gianfar.c
>index d20935d..4187280 100644
>--- a/drivers/net/ethernet/freescale/gianfar.c
>+++ b/drivers/net/ethernet/freescale/gianfar.c
>@@ -2922,17 +2922,24 @@ static bool gfar_add_rx_frag(struct gfar_rx_buff *=
rxb,
>u32 lstatus,
> {
> 	unsigned int size =3D lstatus & BD_LENGTH_MASK;
> 	struct page *page =3D rxb->page;
>+	bool last =3D !!(lstatus & BD_LFLAG(RXBD_LAST));
>
> 	/* Remove the FCS from the packet length */
>-	if (likely(lstatus & BD_LFLAG(RXBD_LAST)))
>+	if (last)
> 		size -=3D ETH_FCS_LEN;
>
>-	if (likely(first))
>+	if (likely(first)) {
> 		skb_put(skb, size);
>-	else
>-		skb_add_rx_frag(skb, skb_shinfo(skb)->nr_frags, page,
>-				rxb->page_offset + RXBUF_ALIGNMENT,
>-				size, GFAR_RXB_TRUESIZE);
>+	} else {
>+		/* the last fragments' length contains the full frame length */
>+		if (last)
>+			size -=3D skb->len;

While I agree with your finding, I don't think this works for packets havin=
g more
than 2 buffers (head + 1 fragment).
How's this supposed to work for a skb with 2 fragments, for instance?
I think this needs more thoughtful consideration.

>+
>+		if (size > 0 && size <=3D GFAR_RXB_SIZE)

Why do you need this check?
The h/w ensures that the buffers won't exceed GFAR_RXB_SIZE
(which is MRBL), size 0 is also not possible.

>+			skb_add_rx_frag(skb, skb_shinfo(skb)->nr_frags, page,
>+					rxb->page_offset + RXBUF_ALIGNMENT,
>+					size, GFAR_RXB_TRUESIZE);
>+	}
>
> 	/* try reuse page */
> 	if (unlikely(page_count(page) !=3D 1))
>--
>2.7.4
