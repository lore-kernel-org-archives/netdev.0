From: saeed bishara <saeed.bishara@gmail.com>
Subject: Re: [PATCH] net: add calxeda xgmac ethernet driver
Date: Thu, 27 Oct 2011 11:28:20 +0200
Message-ID: <CAMAG_eeTvcy+45QD0ReXwcypvg-QB5OcwqN_ndQvDp+xeknYSg@mail.gmail.com>
References: <1319684206-473-1-git-send-email-robherring2@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, devicetree-discuss@lists.ozlabs.org,
	Rob Herring <rob.herring@calxeda.com>
To: Rob Herring <robherring2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:56457 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753705Ab1J0J2k convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Oct 2011 05:28:40 -0400
Received: by iaby12 with SMTP id y12so2686041iab.19
        for <netdev@vger.kernel.org>; Thu, 27 Oct 2011 02:28:40 -0700 (PDT)
In-Reply-To: <1319684206-473-1-git-send-email-robherring2@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Rob,
please note that ethernet drivers moved to drivers/net/ethernet.

here are more notes:
> +#define XGMAC_ADDR_HIGH(reg) =C2=A0 (0x00000040+(reg * 8))
please add brackets around reg
> +#define XGMAC_ADDR_LOW(reg) =C2=A0 =C2=A0(0x00000044+(reg * 8))
ditto
> +#define XGMAC_HASH(n) =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0(0x00000300 =
+ (n) * 4) /* HASH table regs */
> +
> +struct xgmac_dma_desc {
> + =C2=A0 =C2=A0 =C2=A0 u32 flags;
please use __le32 for descriptors
> + =C2=A0 =C2=A0 =C2=A0 u32 buf_size;
> + =C2=A0 =C2=A0 =C2=A0 u32 buf1_addr; =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0/* Buffer 1 Address Pointer */
> + =C2=A0 =C2=A0 =C2=A0 u32 buf2_addr; =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0/* Buffer 2 Address Pointer */
> + =C2=A0 =C2=A0 =C2=A0 u32 ext_status;
> + =C2=A0 =C2=A0 =C2=A0 u32 res[3];
> +};

> +/* XGMAC Descriptor Access Helpers */
> +static inline void desc_set_buf_len(struct xgmac_dma_desc *p, u32 bu=
f_sz)
> +{
> + =C2=A0 =C2=A0 =C2=A0 if (buf_sz > MAX_DESC_BUF_SZ)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 p->buf_size =3D MA=
X_DESC_BUF_SZ |
you should use cpu_to_leX when accessing descriptors
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 (buf_sz - MAX_DESC_BUF_SZ) << DESC_BUFFER2_SZ_OFFSET;



> +static inline dma_addr_t desc_get_buf_addr(struct xgmac_dma_desc *p)
> +{
> + =C2=A0 =C2=A0 =C2=A0 return p->buf1_addr;
1. use le32_to_cpu()
2. your assuming that dma_addr_t is the same as u32 (or __le32), this
might be true in your system, but drivers should be written in generic
way
> +}
> +
> +static void xgmac_dma_flush_tx_fifo(void __iomem *ioaddr)
> +{
> + =C2=A0 =C2=A0 =C2=A0 u32 reg =3D readl(ioaddr + XGMAC_OMR);
> + =C2=A0 =C2=A0 =C2=A0 writel(reg | XGMAC_OMR_FTF, ioaddr + XGMAC_OMR=
);
> +
> + =C2=A0 =C2=A0 =C2=A0 do {} while (readl(ioaddr + XGMAC_OMR) & XGMAC=
_OMR_FTF);
1. change this to: while (read...);
2. that can lead to infinite loop. please consider using time/counter
based limit.
> +}
> +
> +



> +static void xgmac_set_mac_addr(void __iomem *ioaddr, unsigned char *=
addr,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 int num)
> +{
> + =C2=A0 =C2=A0 =C2=A0 u32 reg =3D 0;
> +
> + =C2=A0 =C2=A0 =C2=A0 memcpy(&reg, &addr[4], 2);
> + =C2=A0 =C2=A0 =C2=A0 reg |=3D num ? XGMAC_ADDR_AE : 0;
> + =C2=A0 =C2=A0 =C2=A0 writel(reg, ioaddr + XGMAC_ADDR_HIGH(num));
I think this code won't work in big endian mode
> +
> + =C2=A0 =C2=A0 =C2=A0 memcpy(&reg, addr, sizeof(reg));
> + =C2=A0 =C2=A0 =C2=A0 writel(reg, ioaddr + XGMAC_ADDR_LOW(num));
> +}
> +
> +static void xgmac_get_mac_addr(void __iomem *ioaddr, unsigned char *=
addr,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 int num)

> +
> +/**
> + * init_xgmac_dma_desc_rings - init the RX/TX descriptor rings
> + * @dev: net device structure
> + * Description: =C2=A0this function initializes the DMA RX/TX descri=
ptors
> + * and allocates the socket buffers.
> + */
> +static void xgmac_dma_desc_rings_init(struct net_device *dev)
> +{
> + =C2=A0 =C2=A0 =C2=A0 struct xgmac_priv *priv =3D netdev_priv(dev);
> + =C2=A0 =C2=A0 =C2=A0 unsigned int bfsize;
> +
> + =C2=A0 =C2=A0 =C2=A0 /* Set the Buffer size according to the MTU;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* indeed, in case of jumbo we need to bu=
mp-up the buffer sizes.
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
> + =C2=A0 =C2=A0 =C2=A0 bfsize =3D ALIGN(dev->mtu + ETH_HLEN + ETH_FCS=
_LEN + NET_IP_ALIGN + 64,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A064);
> +
> + =C2=A0 =C2=A0 =C2=A0 dev_dbg(priv->device, "mtu [%d] bfsize [%d]\n"=
, dev->mtu, bfsize);
> +
> + =C2=A0 =C2=A0 =C2=A0 priv->rx_skbuff =3D kzalloc(sizeof(struct sk_b=
uff *) * DMA_RX_RING_SZ,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 GFP_KERNEL);
> + =C2=A0 =C2=A0 =C2=A0 priv->dma_rx =3D dma_alloc_coherent(priv->devi=
ce,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
DMA_RX_RING_SZ *
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
sizeof(struct xgmac_dma_desc),
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
&priv->dma_rx_phy,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
GFP_KERNEL);
> + =C2=A0 =C2=A0 =C2=A0 priv->tx_skbuff =3D kzalloc(sizeof(struct sk_b=
uff *) * DMA_TX_RING_SZ,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 GFP_KERNEL);
> + =C2=A0 =C2=A0 =C2=A0 priv->dma_tx =3D dma_alloc_coherent(priv->devi=
ce,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
DMA_TX_RING_SZ *
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
sizeof(struct xgmac_dma_desc),
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
&priv->dma_tx_phy,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
GFP_KERNEL);
> + =C2=A0 =C2=A0 =C2=A0 if ((priv->dma_rx =3D=3D NULL) || (priv->dma_t=
x =3D=3D NULL)) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 dev_err(priv->devi=
ce, "ERROR allocating the DMA Tx/Rx desc\n");
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return;
the rx descs are not freed when tx desc allocation fails.
no check done for tx_skbuff/rx_skbuff allocation, consider using deem_k=
zalloc
> + =C2=A0 =C2=A0 =C2=A0 }
