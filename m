From: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Subject: Re: [PATCH v6 7/9] bgmac: simplify dma init/cleanup
Date: Tue, 14 Apr 2015 09:24:35 +0200
Message-ID: <CACna6rz+fY-MGKJw858-i47rx5_9ZKhW2ik-YEpDGyMSqALK=A@mail.gmail.com>
References: <1428968537-6181-1-git-send-email-nbd@openwrt.org>
	<1428968537-6181-7-git-send-email-nbd@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Network Development <netdev@vger.kernel.org>,
	Hauke Mehrtens <hauke@hauke-m.de>
To: Felix Fietkau <nbd@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f170.google.com ([209.85.213.170]:37817 "EHLO
	mail-ig0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751941AbbDNHYg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Apr 2015 03:24:36 -0400
Received: by igblo3 with SMTP id lo3so7963545igb.0
        for <netdev@vger.kernel.org>; Tue, 14 Apr 2015 00:24:36 -0700 (PDT)
In-Reply-To: <1428968537-6181-7-git-send-email-nbd@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 14 April 2015 at 01:42, Felix Fietkau <nbd@openwrt.org> wrote:
> Instead of allocating buffers at device init time and initializing
> descriptors at device open, do both at the same time (during open).
> Free all buffers when closing the device.
>
> Signed-off-by: Felix Fietkau <nbd@openwrt.org>
> ---
>  drivers/net/ethernet/broadcom/bgmac.c | 70 +++++++++++++++++------------------
>  1 file changed, 35 insertions(+), 35 deletions(-)
>
> diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/ethernet/broadcom/bgmac.c
> index eafdbca..aad80a7 100644
> --- a/drivers/net/ethernet/broadcom/bgmac.c
> +++ b/drivers/net/ethernet/broadcom/bgmac.c
> @@ -557,18 +557,26 @@ static void bgmac_dma_ring_desc_free(struct bgmac *bgmac,
>                           ring->dma_base);
>  }
>
> -static void bgmac_dma_free(struct bgmac *bgmac)
> +static void bgmac_dma_cleanup(struct bgmac *bgmac)
>  {
>         int i;
>
> -       for (i = 0; i < BGMAC_MAX_TX_RINGS; i++) {
> +       for (i = 0; i < BGMAC_MAX_TX_RINGS; i++)
>                 bgmac_dma_tx_ring_free(bgmac, &bgmac->tx_ring[i]);
> -               bgmac_dma_ring_desc_free(bgmac, &bgmac->tx_ring[i]);
> -       }
> -       for (i = 0; i < BGMAC_MAX_RX_RINGS; i++) {
> +
> +       for (i = 0; i < BGMAC_MAX_RX_RINGS; i++)
>                 bgmac_dma_rx_ring_free(bgmac, &bgmac->rx_ring[i]);
> +}
> +
> +static void bgmac_dma_free(struct bgmac *bgmac)
> +{
> +       int i;
> +
> +       for (i = 0; i < BGMAC_MAX_TX_RINGS; i++)
> +               bgmac_dma_ring_desc_free(bgmac, &bgmac->tx_ring[i]);
> +
> +       for (i = 0; i < BGMAC_MAX_RX_RINGS; i++)
>                 bgmac_dma_ring_desc_free(bgmac, &bgmac->rx_ring[i]);
> -       }
>  }
>
>  static int bgmac_dma_alloc(struct bgmac *bgmac)
> @@ -693,8 +690,13 @@ static void bgmac_dma_init(struct bgmac *bgmac)
>                 if (ring->unaligned)
>                         bgmac_dma_rx_enable(bgmac, ring);
>
> -               for (j = 0; j < ring->num_slots; j++)
> +               for (j = 0; j < ring->num_slots; j++) {
> +                       err = bgmac_dma_rx_skb_for_slot(bgmac, &ring->slots[j]);
> +                       if (err)
> +                               return err;

I don't think I like this logic. Instead of allowing caller to just
detect an error and handle it, you require it to do a cleanup. I think
bgmac_dma_init shouldn't leave any mess after failing.

If you e.g. call alloc_netdev and it fails, you don't care about
freeing whatever is allocated before failing.

I think you should call bgmac_dma_cleanup directly in a bgmac_dma_init
in case of error.
