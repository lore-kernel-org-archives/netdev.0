From: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Subject: Re: [PATCH v4 1/9] bgmac: simplify tx ring index handling
Date: Mon, 13 Apr 2015 16:21:48 +0200
Message-ID: <CACna6rxeBNuSq8OJTBH1Yr75o79q9CDqc2JTW4=kEk+HQt5JRg@mail.gmail.com>
References: <1428933162-26763-1-git-send-email-nbd@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Network Development <netdev@vger.kernel.org>,
	Hauke Mehrtens <hauke@hauke-m.de>
To: Felix Fietkau <nbd@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f174.google.com ([209.85.213.174]:33457 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754322AbbDMOVs convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Apr 2015 10:21:48 -0400
Received: by igbpi8 with SMTP id pi8so27935928igb.0
        for <netdev@vger.kernel.org>; Mon, 13 Apr 2015 07:21:48 -0700 (PDT)
In-Reply-To: <1428933162-26763-1-git-send-email-nbd@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 13 April 2015 at 15:52, Felix Fietkau <nbd@openwrt.org> wrote:
> Keep incrementing ring->start and ring->end instead of pointing it to
> the actual ring slot entry. This simplifies the calculation of the
> number of free slots.

You're much more experienced in network stuff, so it's likely me not
understanding some stuff & needing help.


> @@ -158,13 +157,7 @@ static netdev_tx_t bgmac_dma_tx_add(struct bgmac=
 *bgmac,
>                 skb_checksum_help(skb);
>
>         nr_frags =3D skb_shinfo(skb)->nr_frags;
> -
> -       if (ring->start <=3D ring->end)
> -               free_slots =3D ring->start - ring->end + BGMAC_TX_RIN=
G_SLOTS;
> -       else
> -               free_slots =3D ring->start - ring->end;
> -
> -       if (free_slots <=3D nr_frags + 1) {
> +       if (ring->end - ring->start + nr_frags + 1 >=3D BGMAC_TX_RING=
_SLOTS) {
>                 bgmac_err(bgmac, "TX ring is full, queue should be st=
opped!\n");
>                 netif_stop_queue(net_dev);
>                 return NETDEV_TX_BUSY;

How is this going to work with ring->end lower than ring->start? Let's
say you have 2 empty slots at the end of ring and 2 empty slots at the
beginning. In total 4 free slots. Doing ring->end - ring->start will
give you some big negative number (depending on the ring size), won't
it?


> @@ -284,10 +276,8 @@ static void bgmac_dma_tx_free(struct bgmac *bgma=
c, struct bgmac_dma_ring *ring)
>                         slot->skb =3D NULL;
>                 }
>
> -next:
>                 slot->dma_addr =3D 0;
> -               if (++ring->start >=3D BGMAC_TX_RING_SLOTS)
> -                       ring->start =3D 0;
> +               ring->start++;
>                 freed =3D true;
>         }
>

Do I understand correctly you're using u32 overflow here? Is this
OK/allowed in kernel to knowingly use overflows?


> diff --git a/drivers/net/ethernet/broadcom/bgmac.h b/drivers/net/ethe=
rnet/broadcom/bgmac.h
> index 3ad965f..5a198d5 100644
> --- a/drivers/net/ethernet/broadcom/bgmac.h
> +++ b/drivers/net/ethernet/broadcom/bgmac.h
> @@ -414,10 +414,10 @@ enum bgmac_dma_ring_type {
>   * empty.
>   */
>  struct bgmac_dma_ring {
> -       u16 num_slots;
> -       u16 start;
> -       u16 end;
> +       u32 start;
> +       u32 end;
>
> +       u16 num_slots;
>         u16 mmio_base;
>         struct bgmac_dma_desc *cpu_base;
>         dma_addr_t dma_base;

Any reason for u32 instead of u16?

--=20
Rafa=C5=82
