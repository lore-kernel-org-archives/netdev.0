From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [PATCH v4] net: add Faraday FTMAC100 10/100 Ethernet driver
Date: Fri, 21 Jan 2011 13:26:26 +0100
Message-ID: <AANLkTikpu05V92T+YvuHW+jcTH-Bu2t6=HoQn5OR3ZhX@mail.gmail.com>
References: <1295537418-2057-1-git-send-email-ratbert.chuang@gmail.com>
	<1295596533-1748-1-git-send-email-ratbert.chuang@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	bhutchings@solarflare.com, eric.dumazet@gmail.com, joe@perches.com,
	dilinger@queued.net, Po-Yu Chuang <ratbert@faraday-tech.com>
To: Po-Yu Chuang <ratbert.chuang@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1295596533-1748-1-git-send-email-ratbert.chuang@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2011/1/21 Po-Yu Chuang <ratbert.chuang@gmail.com>:
> From: Po-Yu Chuang <ratbert@faraday-tech.com>
>
> FTMAC100 Ethernet Media Access Controller supports 10/100 Mbps and
> MII. =A0This driver has been working on some ARM/NDS32 SoC's includin=
g
> Faraday A320 and Andes AG101.
>
> Signed-off-by: Po-Yu Chuang <ratbert@faraday-tech.com>
[...]
> +static void ftmac100_txdes_reset(struct ftmac100_txdes *txdes)
> +{
> + =A0 =A0 =A0 /* clear all except end of ring bit */
> + =A0 =A0 =A0 txdes->txdes0 =3D 0;
> + =A0 =A0 =A0 txdes->txdes1 &=3D FTMAC100_TXDES1_EDOTR;
> + =A0 =A0 =A0 txdes->txdes2 =3D 0;
> + =A0 =A0 =A0 txdes->txdes3 =3D 0;
> +}

This also probably needs cpu_to_le32().

[...]
> +static void ftmac100_free_buffers(struct ftmac100 *priv)
> +{
> + =A0 =A0 =A0 int i;
> +
> + =A0 =A0 =A0 for (i =3D 0; i < RX_QUEUE_ENTRIES; i +=3D 2) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct ftmac100_rxdes *rxdes =3D &priv-=
>descs->rxdes[i];
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dma_addr_t d =3D ftmac100_rxdes_get_dma=
_addr(rxdes);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 void *page =3D ftmac100_rxdes_get_va(rx=
des);
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (d)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dma_unmap_single(priv->=
dev, d, PAGE_SIZE,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0DMA_FROM_DEVICE);
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (page !=3D NULL)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 free_page((unsigned lon=
g)page);
> + =A0 =A0 =A0 }
> +
[...]

> +static int ftmac100_alloc_buffers(struct ftmac100 *priv)
> +{
> + =A0 =A0 =A0 int i;
> +
> + =A0 =A0 =A0 priv->descs =3D dma_alloc_coherent(priv->dev,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0sizeof(struct ftmac100_descs),
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0&priv->descs_dma_addr,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0GFP_KERNEL | GFP_DMA);
> + =A0 =A0 =A0 if (priv->descs =3D=3D NULL)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENOMEM;
> +
> + =A0 =A0 =A0 memset(priv->descs, 0, sizeof(struct ftmac100_descs));
> +
> + =A0 =A0 =A0 /* initialize RX ring */
> +
> + =A0 =A0 =A0 ftmac100_rxdes_set_end_of_ring(&priv->descs->rxdes[RX_Q=
UEUE_ENTRIES - 1]);
> +
> + =A0 =A0 =A0 for (i =3D 0; i < RX_QUEUE_ENTRIES; i +=3D 2) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct ftmac100_rxdes *rxdes =3D &priv-=
>descs->rxdes[i];
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 void *page;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dma_addr_t d;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 page =3D (void *)__get_free_page(GFP_KE=
RNEL | GFP_DMA);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (page =3D=3D NULL)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto err;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 d =3D dma_map_single(priv->dev, page, P=
AGE_SIZE, DMA_FROM_DEVICE);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (unlikely(dma_mapping_error(priv->de=
v, d))) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 free_page((unsigned lon=
g)page);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto err;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* The hardware enforces a sub-2K max=
imum packet size, so we
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* put two buffers on every hardware =
page.
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ftmac100_rxdes_set_va(rxdes, page);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ftmac100_rxdes_set_va(rxdes + 1, page +=
 PAGE_SIZE / 2);
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ftmac100_rxdes_set_dma_addr(rxdes, d);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ftmac100_rxdes_set_dma_addr(rxdes + 1, =
d + PAGE_SIZE / 2);
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ftmac100_rxdes_set_buffer_size(rxdes, R=
X_BUF_SIZE);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ftmac100_rxdes_set_buffer_size(rxdes + =
1, RX_BUF_SIZE);
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ftmac100_rxdes_set_dma_own(rxdes);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ftmac100_rxdes_set_dma_own(rxdes + 1);
> + =A0 =A0 =A0 }
[...]

Did you test this? This looks like it will result in double free after
packet RX, as you are giving the same page (referenced once) to two
distinct RX descriptors, that may be assigned different packets.

Since your not implementing any RX offloads, you might just allocate
fresh skb's with alloc_skb() and store skb pointer in rxdes3. Since
hardware doesn't touch it, you can skip cpu_to_le32()/le32_to_cpu()
there (leave a comment, though).

Unless this needs to work for ISA devices, you should drop GFP_DMA
allocation flag.

Best Regards,
Micha=B3 Miros=B3aw
