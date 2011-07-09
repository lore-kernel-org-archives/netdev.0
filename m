From: David Dillow <dave@thedillows.org>
Subject: Re: [RFC PATCH] net: clean up rx_copybreak handling
Date: Fri, 08 Jul 2011 21:37:49 -0400
Message-ID: <1310175469.26320.9.camel@obelisk.thedillows.org>
References: <f73b8ed0717151cd2c72e5c23d275cc0de28d277.1310167326.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from matrix.voodoobox.net ([75.127.97.206]:49670 "EHLO
	matrix.voodoobox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751600Ab1GIBhy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jul 2011 21:37:54 -0400
In-Reply-To: <f73b8ed0717151cd2c72e5c23d275cc0de28d277.1310167326.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2011-07-09 at 01:27 +0200, Micha=C5=82 Miros=C5=82aw wrote:
> diff --git a/drivers/net/typhoon.c b/drivers/net/typhoon.c

> @@ -1675,25 +1674,14 @@ typhoon_rx(struct typhoon *tp, struct basic_r=
ing *rxRing, volatile __le32 * read
> =20
>                 pkt_len =3D le16_to_cpu(rx->frameLen);
> =20
> -               if(pkt_len < rx_copybreak &&
> -                  (new_skb =3D dev_alloc_skb(pkt_len + 2)) !=3D NULL=
) {
> -                       skb_reserve(new_skb, 2);
> -                       pci_dma_sync_single_for_cpu(tp->pdev, dma_add=
r,
> -                                                   PKT_BUF_SZ,
> -                                                   PCI_DMA_FROMDEVIC=
E);
> -                       skb_copy_to_linear_data(new_skb, skb->data, p=
kt_len);
> -                       pci_dma_sync_single_for_device(tp->pdev, dma_=
addr,
> -                                                      PKT_BUF_SZ,
> -                                                      PCI_DMA_FROMDE=
VICE);
> -                       skb_put(new_skb, pkt_len);
> +               new_skb =3D dev_skb_finish_rx_dma(&rxb->skb,
> +                       pkt_len, rx_copybreak,
> +                       &tp->pdev->dev, dma_addr, PKT_BUF_SZ);

Needs a few more tabs in front of the arguments. It looks like
		new_skb =3D dev_skb_finish_rx_dma(&rxb->skb, pkt_len,
						rx_copybreak, &tp->pdev->dev,
						dma_addr, PKT_BUF_SZ);

would fit the style around it better.

> +               if (!rxb->skb)
>                         typhoon_recycle_rx_skb(tp, idx);

I think you either meant
		if (rxb->skb)
			typhoon_recycle_rx_skb(tp, idx);

or to swap typhoon_{recycle,alloc}_rx_skb(). As it stands, you'll reloa=
d
the NIC with a NULL skb pointer, and it will DMA to the old location
when it eventually uses this descriptor.

> -               } else {
> -                       new_skb =3D skb;
> -                       skb_put(new_skb, pkt_len);
> -                       pci_unmap_single(tp->pdev, dma_addr, PKT_BUF_=
SZ,
> -                                      PCI_DMA_FROMDEVICE);
> +               else
>                         typhoon_alloc_rx_skb(tp, idx);


