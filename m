From: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Subject: Re: [PATCH v6 4/9] bgmac: simplify/optimize rx DMA error handling
Date: Tue, 14 Apr 2015 07:55:18 +0200
Message-ID: <CACna6ry7yD4jb2ph1EOvOrmdWiqOU8+yFQKvH0OCS=haH4dUqA@mail.gmail.com>
References: <1428968537-6181-1-git-send-email-nbd@openwrt.org>
	<1428968537-6181-4-git-send-email-nbd@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Network Development <netdev@vger.kernel.org>,
	Hauke Mehrtens <hauke@hauke-m.de>
To: Felix Fietkau <nbd@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f46.google.com ([209.85.215.46]:33428 "EHLO
	mail-la0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750894AbbDNFzU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Apr 2015 01:55:20 -0400
Received: by layy10 with SMTP id y10so73856835lay.0
        for <netdev@vger.kernel.org>; Mon, 13 Apr 2015 22:55:18 -0700 (PDT)
In-Reply-To: <1428968537-6181-4-git-send-email-nbd@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 14 April 2015 at 01:42, Felix Fietkau <nbd@openwrt.org> wrote:
> @@ -382,6 +382,19 @@ static void bgmac_dma_rx_setup_desc(struct bgmac=
 *bgmac,
>         dma_desc->ctl1 =3D cpu_to_le32(ctl1);
>  }
>
> +static void bgmac_dma_rx_poison_buf(struct device *dma_dev,
> +                                   struct bgmac_slot_info *slot)
> +{
> +       struct bgmac_rx_header *rx =3D slot->buf + BGMAC_RX_BUF_OFFSE=
T;
> +
> +       dma_sync_single_for_cpu(dma_dev, slot->dma_addr, BGMAC_RX_BUF=
_SIZE,
> +                               DMA_FROM_DEVICE);
> +       rx->len =3D cpu_to_le16(0xdead);
> +       rx->flags =3D cpu_to_le16(0xdead);
> +       dma_sync_single_for_device(dma_dev, slot->dma_addr, BGMAC_RX_=
BUF_SIZE,
> +                                  DMA_FROM_DEVICE);
> +}

flags should be 0xbeef


> @@ -404,51 +417,32 @@ static int bgmac_dma_rx_read(struct bgmac *bgma=
c, struct bgmac_dma_ring *ring,
>                 void *buf =3D slot->buf;
>                 u16 len, flags;
>
> -               /* Unmap buffer to make it accessible to the CPU */
> -               dma_sync_single_for_cpu(dma_dev, slot->dma_addr,
> -                                       BGMAC_RX_BUF_SIZE, DMA_FROM_D=
EVICE);
> +               do {
> +                       /* Prepare new skb as replacement */
> +                       if (bgmac_dma_rx_skb_for_slot(bgmac, slot)) {
> +                               bgmac_dma_rx_poison_buf(dma_dev, slot=
);
> +                               break;
> +                       }

So you just replaced slot->dma_addr with a mapping of new skb data.


>
> -               /* Get info from the header */
> -               len =3D le16_to_cpu(rx->len);
> -               flags =3D le16_to_cpu(rx->flags);
> +                       /* Unmap buffer to make it accessible to the =
CPU */
> +                       dma_unmap_single(dma_dev, slot->dma_addr,
> +                                        BGMAC_RX_BUF_SIZE, DMA_FROM_=
DEVICE);

Now you unmap the new sbk data instead of the old one you want to acces=
s.
That's why the old code included old_dma_addr.


> @@ -528,14 +524,14 @@ static void bgmac_dma_rx_ring_free(struct bgmac=
 *bgmac,
>
>         for (i =3D 0; i < ring->num_slots; i++) {
>                 slot =3D &ring->slots[i];
> -               if (!slot->buf)
> +               if (!slot->dma_addr)
>                         continue;

I think it breaks error path of bgmac_dma_alloc. It may happen that
during DMA alloc we alloc skb and then we fail to map it. In such case
buf should be freed. Please trace how bgmac_dma_free is used in
bgmac_dma_alloc.


>
> -               if (slot->dma_addr)
> -                       dma_unmap_single(dma_dev, slot->dma_addr,
> -                                        BGMAC_RX_BUF_SIZE,
> -                                        DMA_FROM_DEVICE);
> +               dma_unmap_single(dma_dev, slot->dma_addr,
> +                                BGMAC_RX_BUF_SIZE,
> +                                DMA_FROM_DEVICE);
>                 put_page(virt_to_head_page(slot->buf));
> +               slot->dma_addr =3D 0;
>         }
>  }

--=20
Rafa=C5=82
