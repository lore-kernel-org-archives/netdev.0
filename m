From: Andy Shevchenko <andy.shevchenko@gmail.com>
Subject: Re: [PATCH v5] net: ethernet: add driver for Aurora VLSI NB8800
 Ethernet controller
Date: Wed, 11 Nov 2015 00:09:23 +0200
Message-ID: <CAHp75Vch3vJEqYsCRUoctEmF0EoFx+0y7ZO+LjmdpQKAoikiOA@mail.gmail.com>
References: <1447172063-27234-1-git-send-email-mans@mansr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>, slash.tmp@free.fr
To: Mans Rullgard <mans@mansr.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1447172063-27234-1-git-send-email-mans@mansr.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 10, 2015 at 6:14 PM, Mans Rullgard <mans@mansr.com> wrote:
> This adds a driver for the Aurora VLSI NB8800 Ethernet controller.
> It is an almost complete rewrite of a driver originally found in
> a Sigma Designs 2.6.22 tree.

=46ew nitpicks below.

>
> Signed-off-by: Mans Rullgard <mans@mansr.com>
> ---
> Changes:
> - Refactored mdio access functions
> - Refactored register access helpers
> - Improved error handling in rx buffer allocation
> - Optimised some fifo parameters
> - Overhauled tx dma. Multiple packets are now chained in a single dma
>   operation if xmit_more is set, improving performance.
> - Improved rx irq handling. It's not possible to disable interrupts
>   entirely for napi poll, but they can be slowed down a little.
> - Use readx_poll_timeout in various places
> - Improved error detection
> - Improved statistics
> - Report hardware statistics counters through ethtool
> - Improved tangox-specific setup
> - Support for flow control using pause frames
> - Explanatory comments added
> - Various minor stylistic changes
> ---
>  drivers/net/ethernet/Kconfig         |    1 +
>  drivers/net/ethernet/Makefile        |    1 +
>  drivers/net/ethernet/aurora/Kconfig  |   20 +
>  drivers/net/ethernet/aurora/Makefile |    1 +
>  drivers/net/ethernet/aurora/nb8800.c | 1530 ++++++++++++++++++++++++=
++++++++++
>  drivers/net/ethernet/aurora/nb8800.h |  314 +++++++
>  6 files changed, 1867 insertions(+)
>  create mode 100644 drivers/net/ethernet/aurora/Kconfig
>  create mode 100644 drivers/net/ethernet/aurora/Makefile
>  create mode 100644 drivers/net/ethernet/aurora/nb8800.c
>  create mode 100644 drivers/net/ethernet/aurora/nb8800.h
>
> diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kcon=
fig
> index 05aa759..8310163 100644
> --- a/drivers/net/ethernet/Kconfig
> +++ b/drivers/net/ethernet/Kconfig
> @@ -29,6 +29,7 @@ source "drivers/net/ethernet/apm/Kconfig"
>  source "drivers/net/ethernet/apple/Kconfig"
>  source "drivers/net/ethernet/arc/Kconfig"
>  source "drivers/net/ethernet/atheros/Kconfig"
> +source "drivers/net/ethernet/aurora/Kconfig"
>  source "drivers/net/ethernet/cadence/Kconfig"
>  source "drivers/net/ethernet/adi/Kconfig"
>  source "drivers/net/ethernet/broadcom/Kconfig"
> diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Mak=
efile
> index ddfc808..b435fb0 100644
> --- a/drivers/net/ethernet/Makefile
> +++ b/drivers/net/ethernet/Makefile
> @@ -15,6 +15,7 @@ obj-$(CONFIG_NET_XGENE) +=3D apm/
>  obj-$(CONFIG_NET_VENDOR_APPLE) +=3D apple/
>  obj-$(CONFIG_NET_VENDOR_ARC) +=3D arc/
>  obj-$(CONFIG_NET_VENDOR_ATHEROS) +=3D atheros/
> +obj-$(CONFIG_NET_VENDOR_AURORA) +=3D aurora/
>  obj-$(CONFIG_NET_CADENCE) +=3D cadence/
>  obj-$(CONFIG_NET_BFIN) +=3D adi/
>  obj-$(CONFIG_NET_VENDOR_BROADCOM) +=3D broadcom/
> diff --git a/drivers/net/ethernet/aurora/Kconfig b/drivers/net/ethern=
et/aurora/Kconfig
> new file mode 100644
> index 0000000..a3c7106
> --- /dev/null
> +++ b/drivers/net/ethernet/aurora/Kconfig
> @@ -0,0 +1,20 @@
> +config NET_VENDOR_AURORA
> +       bool "Aurora VLSI devices"
> +       help
> +         If you have a network (Ethernet) device belonging to this c=
lass,
> +         say Y.
> +
> +         Note that the answer to this question doesn't directly affe=
ct the
> +         kernel: saying N will just cause the configurator to skip a=
ll
> +         questions about Aurora devices. If you say Y, you will be a=
sked
> +         for your specific device in the following questions.
> +
> +if NET_VENDOR_AURORA
> +
> +config AURORA_NB8800
> +       tristate "Aurora AU-NB8800 support"
> +       select PHYLIB
> +       help
> +        Support for the AU-NB8800 gigabit Ethernet controller.
> +
> +endif
> diff --git a/drivers/net/ethernet/aurora/Makefile b/drivers/net/ether=
net/aurora/Makefile
> new file mode 100644
> index 0000000..6cb528a
> --- /dev/null
> +++ b/drivers/net/ethernet/aurora/Makefile
> @@ -0,0 +1 @@
> +obj-$(CONFIG_AURORA_NB8800) +=3D nb8800.o
> diff --git a/drivers/net/ethernet/aurora/nb8800.c b/drivers/net/ether=
net/aurora/nb8800.c
> new file mode 100644
> index 0000000..11cd389
> --- /dev/null
> +++ b/drivers/net/ethernet/aurora/nb8800.c
> @@ -0,0 +1,1530 @@
> +/*
> + * Copyright (C) 2015 Mans Rullgard <mans@mansr.com>
> + *
> + * Mostly rewritten, based on driver from Sigma Designs.  Original
> + * copyright notice below.
> + *
> + *
> + * Driver for tangox SMP864x/SMP865x/SMP867x/SMP868x builtin Etherne=
t Mac.
> + *
> + * Copyright (C) 2005 Maxime Bizon <mbizon@freebox.fr>
> + *
> + * This program is free software; you can redistribute it and/or mod=
ify
> + * it under the terms of the GNU General Public License as published=
 by
> + * the Free Software Foundation; either version 2 of the License, or
> + * (at your option) any later version.
> + *
> + * This program is distributed in the hope that it will be useful,
> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> + * GNU General Public License for more details.
> + */
> +
> +#include <linux/module.h>
> +#include <linux/etherdevice.h>
> +#include <linux/delay.h>
> +#include <linux/ethtool.h>
> +#include <linux/interrupt.h>
> +#include <linux/platform_device.h>
> +#include <linux/of_device.h>
> +#include <linux/of_mdio.h>
> +#include <linux/of_net.h>
> +#include <linux/dma-mapping.h>
> +#include <linux/phy.h>
> +#include <linux/cache.h>
> +#include <linux/jiffies.h>
> +#include <linux/io.h>
> +#include <linux/iopoll.h>
> +#include <asm/barrier.h>
> +
> +#include "nb8800.h"
> +
> +static int nb8800_dma_stop(struct net_device *dev);
> +
> +static inline u8 nb8800_readb(struct nb8800_priv *priv, int reg)
> +{
> +       return readb(priv->base + reg);
> +}
> +
> +static inline u32 nb8800_readl(struct nb8800_priv *priv, int reg)
> +{
> +       return readl(priv->base + reg);
> +}
> +
> +static inline void nb8800_writeb(struct nb8800_priv *priv, int reg, =
u8 val)
> +{
> +       writeb(val, priv->base + reg);
> +}
> +
> +static inline void nb8800_writew(struct nb8800_priv *priv, int reg, =
u16 val)
> +{
> +       writew(val, priv->base + reg);
> +}
> +
> +static inline void nb8800_writel(struct nb8800_priv *priv, int reg, =
u32 val)
> +{
> +       writel(val, priv->base + reg);
> +}
> +
> +static inline void nb8800_maskb(struct nb8800_priv *priv, int reg,
> +                               u32 mask, u32 val)
> +{
> +       u32 old =3D nb8800_readb(priv, reg);
> +       u32 new =3D (old & ~mask) | val;

Shoudn't be "=E2=80=A6 | (val & mask);" ?

+ empty line?

> +       if (new !=3D old)
> +               nb8800_writeb(priv, reg, new);
> +}
> +
> +static inline void nb8800_maskl(struct nb8800_priv *priv, int reg,
> +                               u32 mask, u32 val)
> +{
> +       u32 old =3D nb8800_readl(priv, reg);
> +       u32 new =3D (old & ~mask) | val;

Ditto.

> +       if (new !=3D old)
> +               nb8800_writel(priv, reg, new);
> +}
> +
> +static inline void nb8800_modb(struct nb8800_priv *priv, int reg, u8=
 bits,
> +                              bool set)
> +{
> +       nb8800_maskb(priv, reg, bits, set ? bits : 0);
> +}
> +
> +static inline void nb8800_setb(struct nb8800_priv *priv, int reg, u8=
 bits)
> +{
> +       nb8800_maskb(priv, reg, bits, bits);
> +}
> +
> +static inline void nb8800_clearb(struct nb8800_priv *priv, int reg, =
u8 bits)
> +{
> +       nb8800_maskb(priv, reg, bits, 0);
> +}
> +
> +static inline void nb8800_modl(struct nb8800_priv *priv, int reg, u3=
2 bits,
> +                              bool set)
> +{
> +       nb8800_maskl(priv, reg, bits, set ? bits : 0);
> +}
> +
> +static inline void nb8800_setl(struct nb8800_priv *priv, int reg, u3=
2 bits)
> +{
> +       nb8800_maskl(priv, reg, bits, bits);
> +}
> +
> +static inline void nb8800_clearl(struct nb8800_priv *priv, int reg, =
u32 bits)
> +{
> +       nb8800_maskl(priv, reg, bits, 0);
> +}
> +
> +static int nb8800_mdio_wait(struct mii_bus *bus)
> +{
> +       struct nb8800_priv *priv =3D bus->priv;
> +       u32 val;
> +
> +       return readl_poll_timeout_atomic(priv->base + NB8800_MDIO_CMD=
,
> +                                        val, !(val & MDIO_CMD_GO), 1=
, 1000);
> +}
> +
> +static int nb8800_mdio_cmd(struct mii_bus *bus, u32 cmd)
> +{
> +       struct nb8800_priv *priv =3D bus->priv;
> +       int err;
> +
> +       err =3D nb8800_mdio_wait(bus);
> +       if (err)
> +               return err;
> +
> +       nb8800_writel(priv, NB8800_MDIO_CMD, cmd);
> +       udelay(10);
> +       nb8800_writel(priv, NB8800_MDIO_CMD, cmd | MDIO_CMD_GO);
> +
> +       return nb8800_mdio_wait(bus);
> +}
> +
> +static int nb8800_mdio_read(struct mii_bus *bus, int phy_id, int reg=
)
> +{
> +       struct nb8800_priv *priv =3D bus->priv;
> +       u32 val;
> +       int err;
> +
> +       err =3D nb8800_mdio_cmd(bus, MIIAR_ADDR(phy_id) | MIIAR_REG(r=
eg));
> +       if (err)
> +               return err;
> +
> +       val =3D nb8800_readl(priv, NB8800_MDIO_STS);
> +       if (val & MDIO_STS_ERR)
> +               return 0xffff;
> +
> +       return val & 0xffff;
> +}
> +
> +static int nb8800_mdio_write(struct mii_bus *bus, int phy_id, int re=
g, u16 val)
> +{
> +       u32 cmd =3D MIIAR_DATA(val) | MIIAR_ADDR(phy_id) | MIIAR_REG(=
reg) |
> +               MDIO_CMD_WR;
> +
> +       return nb8800_mdio_cmd(bus, cmd);
> +}
> +
> +static void nb8800_mac_tx(struct net_device *dev, bool enable)
> +{
> +       struct nb8800_priv *priv =3D netdev_priv(dev);
> +
> +       while (nb8800_readl(priv, NB8800_TXC_CR) & TCR_EN)
> +               cpu_relax();
> +
> +       nb8800_modb(priv, NB8800_TX_CTL1, TX_EN, enable);
> +}
> +
> +static void nb8800_mac_rx(struct net_device *dev, bool enable)
> +{
> +       nb8800_modb(netdev_priv(dev), NB8800_RX_CTL, RX_EN, enable);
> +}
> +
> +static void nb8800_mac_af(struct net_device *dev, bool enable)
> +{
> +       nb8800_modb(netdev_priv(dev), NB8800_RX_CTL, RX_AF_EN, enable=
);
> +}
> +
> +static void nb8800_start_rx(struct net_device *dev)
> +{
> +       nb8800_setl(netdev_priv(dev), NB8800_RXC_CR, RCR_EN);
> +}
> +
> +static int nb8800_alloc_rx(struct net_device *dev, int i, bool napi)
> +{
> +       struct nb8800_priv *priv =3D netdev_priv(dev);
> +       struct nb8800_rx_desc *rxd =3D &priv->rx_descs[i];
> +       struct nb8800_rx_buf *rxb =3D &priv->rx_bufs[i];
> +       int size =3D L1_CACHE_ALIGN(RX_BUF_SIZE);
> +       dma_addr_t dma_addr;
> +       struct page *page;
> +       unsigned long offset;
> +       void *data;
> +
> +       data =3D napi ? napi_alloc_frag(size) : netdev_alloc_frag(siz=
e);
> +       if (!data)
> +               return -ENOMEM;
> +
> +       page =3D virt_to_head_page(data);
> +       offset =3D data - page_address(page);
> +
> +       dma_addr =3D dma_map_page(&dev->dev, page, offset, RX_BUF_SIZ=
E,
> +                               DMA_FROM_DEVICE);
> +
> +       if (dma_mapping_error(&dev->dev, dma_addr)) {
> +               skb_free_frag(data);
> +               return -ENOMEM;
> +       }
> +
> +       rxb->page =3D page;
> +       rxb->offset =3D offset;
> +       rxd->desc.s_addr =3D dma_addr;
> +
> +       return 0;
> +}
> +
> +static void nb8800_receive(struct net_device *dev, int i, int len)

unsigned int i ?
len as well?

> +{
> +       struct nb8800_priv *priv =3D netdev_priv(dev);
> +       struct nb8800_rx_desc *rxd =3D &priv->rx_descs[i];
> +       struct page *page =3D priv->rx_bufs[i].page;
> +       int offset =3D priv->rx_bufs[i].offset;
> +       void *data =3D page_address(page) + offset;
> +       dma_addr_t dma =3D rxd->desc.s_addr;

dma -> addr ?

> +       struct sk_buff *skb;
> +       int size;
> +       int err;
> +
> +       size =3D len <=3D RX_COPYBREAK ? len : RX_COPYHDR;
> +
> +       skb =3D napi_alloc_skb(&priv->napi, size);
> +       if (!skb) {
> +               netdev_err(dev, "rx skb allocation failed\n");
> +               dev->stats.rx_dropped++;
> +               return;
> +       }
> +
> +       if (len <=3D RX_COPYBREAK) {
> +               dma_sync_single_for_cpu(&dev->dev, dma, len, DMA_FROM=
_DEVICE);
> +               memcpy(skb_put(skb, len), data, len);
> +               dma_sync_single_for_device(&dev->dev, dma, len,
> +                                          DMA_FROM_DEVICE);
> +       } else {
> +               err =3D nb8800_alloc_rx(dev, i, true);
> +               if (err) {
> +                       netdev_err(dev, "rx buffer allocation failed\=
n");
> +                       dev->stats.rx_dropped++;
> +                       return;
> +               }
> +
> +               dma_unmap_page(&dev->dev, dma, RX_BUF_SIZE, DMA_FROM_=
DEVICE);
> +               memcpy(skb_put(skb, RX_COPYHDR), data, RX_COPYHDR);
> +               skb_add_rx_frag(skb, skb_shinfo(skb)->nr_frags, page,
> +                               offset + RX_COPYHDR, len - RX_COPYHDR=
,
> +                               RX_BUF_SIZE);
> +       }
> +
> +       skb->protocol =3D eth_type_trans(skb, dev);
> +       netif_receive_skb(skb);
> +}
> +
> +static void nb8800_rx_error(struct net_device *dev, u32 report)
> +{
> +       if (report & RX_LENGTH_ERR)
> +               dev->stats.rx_length_errors++;
> +
> +       if (report & RX_FCS_ERR)
> +               dev->stats.rx_crc_errors++;
> +
> +       if (report & RX_FIFO_OVERRUN)
> +               dev->stats.rx_fifo_errors++;
> +
> +       if (report & RX_ALIGNMENT_ERROR)
> +               dev->stats.rx_frame_errors++;
> +
> +       dev->stats.rx_errors++;
> +}
> +
> +static int nb8800_poll(struct napi_struct *napi, int budget)
> +{
> +       struct net_device *dev =3D napi->dev;
> +       struct nb8800_priv *priv =3D netdev_priv(dev);
> +       struct nb8800_rx_desc *rxd;
> +       int work =3D 0;
> +       int last =3D priv->rx_eoc;
> +       int next;
> +
> +again:
> +       while (work < budget) {
> +               struct nb8800_rx_buf *rxb;
> +               int len;
> +
> +               next =3D (last + 1) % RX_DESC_COUNT;
> +
> +               rxb =3D &priv->rx_bufs[next];
> +               rxd =3D &priv->rx_descs[next];
> +
> +               if (!rxd->report)
> +                       break;
> +
> +               len =3D RX_BYTES_TRANSFERRED(rxd->report);
> +
> +               if (IS_RX_ERROR(rxd->report))
> +                       nb8800_rx_error(dev, rxd->report);
> +               else
> +                       nb8800_receive(dev, next, len);
> +
> +               dev->stats.rx_packets++;
> +               dev->stats.rx_bytes +=3D len;
> +
> +               if (rxd->report & RX_MULTICAST_PKT)
> +                       dev->stats.multicast++;
> +
> +               rxd->report =3D 0;
> +               last =3D next;
> +               work++;
> +       }
> +
> +       if (work) {
> +               priv->rx_descs[last].desc.config |=3D DESC_EOC;
> +               wmb();  /* ensure new EOC is written before clearing =
old */
> +               priv->rx_descs[priv->rx_eoc].desc.config &=3D ~DESC_E=
OC;
> +               priv->rx_eoc =3D last;
> +               nb8800_start_rx(dev);
> +       }
> +
> +       if (work < budget) {
> +               nb8800_writel(priv, NB8800_RX_ITR, priv->rx_itr_irq);
> +
> +               /* If a packet arrived after we last checked but
> +                * before writing RX_ITR, the interrupt will be
> +                * delayed, so we retrieve it now. */

Block comments usually
/*
 * text
 */

Can be longer lines?

> +               if (priv->rx_descs[next].report)
> +                       goto again;
> +
> +               napi_complete_done(napi, work);
> +       }
> +
> +       return work;
> +}
> +
> +static void nb8800_tx_dma_start(struct net_device *dev)
> +{
> +       struct nb8800_priv *priv =3D netdev_priv(dev);
> +       struct nb8800_tx_buf *txb;
> +       u32 txc_cr;
> +
> +       txb =3D &priv->tx_bufs[priv->tx_queue];
> +       if (!txb->ready)
> +               return;
> +
> +       txc_cr =3D nb8800_readl(priv, NB8800_TXC_CR);
> +       if (txc_cr & TCR_EN)
> +               return;
> +
> +       nb8800_writel(priv, NB8800_TX_DESC_ADDR, txb->dma_desc);
> +       wmb();          /* ensure desc addr is written before startin=
g DMA */

Hm=E2=80=A6 Have I missed corresponding rmb() ? If it's about MMIO, per=
haps mmiowb() ?

> +       nb8800_writel(priv, NB8800_TXC_CR, txc_cr | TCR_EN);
> +
> +       priv->tx_queue =3D (priv->tx_queue + txb->chain_len) % TX_DES=
C_COUNT;
> +}
> +
> +static void nb8800_tx_dma_start_irq(struct net_device *dev)
> +{
> +       struct nb8800_priv *priv =3D netdev_priv(dev);
> +
> +       spin_lock(&priv->tx_lock);
> +       nb8800_tx_dma_start(dev);
> +       spin_unlock(&priv->tx_lock);
> +}
> +
> +static int nb8800_xmit(struct sk_buff *skb, struct net_device *dev)
> +{
> +       struct nb8800_priv *priv =3D netdev_priv(dev);
> +       struct nb8800_tx_desc *txd;
> +       struct nb8800_tx_buf *txb;
> +       struct nb8800_dma_desc *dma;

dma -> desc ?

> +       dma_addr_t dma_addr;
> +       unsigned int dma_len;
> +       unsigned long flags;
> +       int align;
> +       int next;
> +
> +       if (atomic_read(&priv->tx_free) <=3D NB8800_DESC_LOW) {
> +               netif_stop_queue(dev);
> +               return NETDEV_TX_BUSY;
> +       }
> +
> +       align =3D (8 - (uintptr_t)skb->data) & 7;
> +
> +       dma_len =3D skb->len - align;
> +       dma_addr =3D dma_map_single(&dev->dev, skb->data + align,
> +                                 dma_len, DMA_TO_DEVICE);
> +
> +       if (dma_mapping_error(&dev->dev, dma_addr)) {
> +               netdev_err(dev, "tx dma mapping error\n");
> +               kfree_skb(skb);
> +               dev->stats.tx_dropped++;
> +               return NETDEV_TX_OK;
> +       }
> +
> +       if (atomic_dec_return(&priv->tx_free) <=3D NB8800_DESC_LOW)
> +               netif_stop_queue(dev);
> +
> +       next =3D priv->tx_next;
> +       txb =3D &priv->tx_bufs[next];
> +       txd =3D &priv->tx_descs[next];
> +       dma =3D &txd->desc[0];
> +
> +       next =3D (next + 1) % TX_DESC_COUNT;
> +
> +       if (align) {
> +               memcpy(txd->buf, skb->data, align);
> +
> +               dma->s_addr =3D
> +                       txb->dma_desc + offsetof(struct nb8800_tx_des=
c, buf);
> +               dma->n_addr =3D txb->dma_desc + sizeof(txd->desc[0]);
> +               dma->config =3D DESC_BTS(2) | DESC_DS | align;
> +
> +               dma++;
> +       }
> +
> +       dma->s_addr =3D dma_addr;
> +       dma->n_addr =3D priv->tx_bufs[next].dma_desc;
> +       dma->config =3D DESC_BTS(2) | DESC_DS | DESC_EOF | dma_len;
> +
> +       if (!skb->xmit_more)
> +               dma->config |=3D DESC_EOC;
> +
> +       txb->skb =3D skb;
> +       txb->dma_addr =3D dma_addr;
> +       txb->dma_len =3D dma_len;
> +
> +       if (!priv->tx_chain) {
> +               txb->chain_len =3D 1;
> +               priv->tx_chain =3D txb;
> +       } else {
> +               priv->tx_chain->chain_len++;
> +       }
> +
> +       netdev_sent_queue(dev, skb->len);
> +
> +       smp_mb__before_spinlock();
> +       spin_lock_irqsave(&priv->tx_lock, flags);
> +
> +       if (!skb->xmit_more) {
> +               priv->tx_chain->ready =3D true;
> +               priv->tx_chain =3D NULL;
> +               nb8800_tx_dma_start(dev);
> +       }
> +
> +       spin_unlock_irqrestore(&priv->tx_lock, flags);
> +
> +       priv->tx_next =3D next;
> +
> +       return NETDEV_TX_OK;
> +}
> +
> +static void nb8800_tx_error(struct net_device *dev, u32 report)
> +{
> +       if (report & TX_LATE_COLLISION)
> +               dev->stats.collisions++;
> +
> +       if (report & TX_PACKET_DROPPED)
> +               dev->stats.tx_dropped++;
> +
> +       if (report & TX_FIFO_UNDERRUN)
> +               dev->stats.tx_fifo_errors++;
> +
> +       dev->stats.tx_errors++;
> +}
> +
> +static void nb8800_tx_done(struct net_device *dev)
> +{
> +       struct nb8800_priv *priv =3D netdev_priv(dev);
> +       int limit =3D priv->tx_next;
> +       int done =3D priv->tx_done;
> +       unsigned int packets =3D 0;
> +       unsigned int len =3D 0;
> +
> +       while (done !=3D limit) {
> +               struct nb8800_tx_desc *txd =3D &priv->tx_descs[done];
> +               struct nb8800_tx_buf *txb =3D &priv->tx_bufs[done];
> +               struct sk_buff *skb;
> +
> +               if (!txd->report)
> +                       break;
> +
> +               skb =3D txb->skb;
> +               len +=3D skb->len;
> +
> +               dma_unmap_single(&dev->dev, txb->dma_addr, txb->dma_l=
en,
> +                                DMA_TO_DEVICE);
> +
> +               if (IS_TX_ERROR(txd->report)) {
> +                       nb8800_tx_error(dev, txd->report);
> +                       dev_kfree_skb_irq(skb);
> +               } else {
> +                       dev_consume_skb_irq(skb);
> +               }
> +
> +               dev->stats.tx_packets++;
> +               dev->stats.tx_bytes +=3D TX_BYTES_TRANSFERRED(txd->re=
port);
> +               dev->stats.collisions +=3D TX_EARLY_COLLISIONS(txd->r=
eport);
> +
> +               txb->skb =3D NULL;
> +               txb->ready =3D false;
> +               txd->report =3D 0;
> +
> +               done =3D (done + 1) % TX_DESC_COUNT;
> +               packets++;
> +       }
> +
> +       if (packets) {
> +               smp_mb__before_atomic();
> +               atomic_add(packets, &priv->tx_free);
> +               netdev_completed_queue(dev, packets, len);
> +               netif_wake_queue(dev);
> +               priv->tx_done =3D done;
> +       }
> +}
> +
> +static irqreturn_t nb8800_irq(int irq, void *dev_id)
> +{
> +       struct net_device *dev =3D dev_id;
> +       struct nb8800_priv *priv =3D netdev_priv(dev);
> +       u32 val;
> +
> +       /* tx interrupt */
> +       val =3D nb8800_readl(priv, NB8800_TXC_SR);
> +       if (val) {
> +               nb8800_writel(priv, NB8800_TXC_SR, val);
> +
> +               if (val & TSR_DI)
> +                       nb8800_tx_dma_start_irq(dev);
> +
> +               if (val & TSR_TI)
> +                       nb8800_tx_done(dev);
> +
> +               if (unlikely(val & TSR_DE))
> +                       netdev_err(dev, "TX DMA error\n");
> +
> +               /* should never happen with automatic status retrieva=
l */
> +               if (unlikely(val & TSR_TO))
> +                       netdev_err(dev, "TX Status FIFO overflow\n");
> +       }
> +
> +       /* rx interrupt */
> +       val =3D nb8800_readl(priv, NB8800_RXC_SR);
> +       if (val) {
> +               nb8800_writel(priv, NB8800_RXC_SR, val);
> +
> +               if (likely(val & (RSR_RI | RSR_DI))) {
> +                       nb8800_writel(priv, NB8800_RX_ITR, priv->rx_i=
tr_poll);
> +                       napi_schedule_irqoff(&priv->napi);
> +               }
> +
> +               if (unlikely(val & RSR_DE))
> +                       netdev_err(dev, "RX DMA error\n");
> +
> +               /* should never happen with automatic status retrieva=
l */
> +               if (unlikely(val & RSR_RO))
> +                       netdev_err(dev, "RX Status FIFO overflow\n");
> +       }
> +
> +       return IRQ_HANDLED;
> +}
> +
> +static void nb8800_mac_config(struct net_device *dev)
> +{
> +       struct nb8800_priv *priv =3D netdev_priv(dev);
> +       bool gigabit =3D priv->speed =3D=3D SPEED_1000;
> +       u32 mac_mode_mask =3D RGMII_MODE | HALF_DUPLEX | GMAC_MODE;
> +       u32 mac_mode =3D 0;
> +       u32 slot_time;
> +       u32 phy_clk;
> +       u32 ict;
> +
> +       if (!priv->duplex)
> +               mac_mode |=3D HALF_DUPLEX;
> +
> +       if (gigabit) {
> +               if (priv->phy_mode =3D=3D PHY_INTERFACE_MODE_RGMII)
> +                       mac_mode |=3D RGMII_MODE;
> +
> +               mac_mode |=3D GMAC_MODE;
> +               phy_clk =3D 125000000;
> +
> +               /* Should be 512 but register is only 8 bits */
> +               slot_time =3D 255;
> +       } else {
> +               phy_clk =3D 25000000;
> +               slot_time =3D 128;
> +       }
> +
> +       ict =3D DIV_ROUND_UP(phy_clk, clk_get_rate(priv->clk));
> +
> +       nb8800_writeb(priv, NB8800_IC_THRESHOLD, ict);
> +       nb8800_writeb(priv, NB8800_SLOT_TIME, slot_time);
> +       nb8800_maskb(priv, NB8800_MAC_MODE, mac_mode_mask, mac_mode);
> +}
> +
> +static void nb8800_pause_config(struct net_device *dev)
> +{
> +       struct nb8800_priv *priv =3D netdev_priv(dev);
> +       struct phy_device *phydev =3D priv->phydev;
> +       u32 rxcr;
> +
> +       if (priv->pause_aneg) {
> +               if (!phydev || !phydev->link)
> +                       return;
> +
> +               priv->pause_rx =3D phydev->pause;
> +               priv->pause_tx =3D phydev->pause ^ phydev->asym_pause=
;
> +       }
> +
> +       nb8800_modb(priv, NB8800_RX_CTL, RX_PAUSE_EN, priv->pause_rx)=
;
> +
> +       rxcr =3D nb8800_readl(priv, NB8800_RXC_CR);
> +       if (!!(rxcr & RCR_FL) =3D=3D priv->pause_tx)
> +               return;
> +
> +       if (netif_running(dev)) {
> +               napi_disable(&priv->napi);
> +               netif_tx_lock_bh(dev);
> +               nb8800_dma_stop(dev);
> +               nb8800_modl(priv, NB8800_RXC_CR, RCR_FL, priv->pause_=
tx);
> +               nb8800_start_rx(dev);
> +               netif_tx_unlock_bh(dev);
> +               napi_enable(&priv->napi);
> +       } else {
> +               nb8800_modl(priv, NB8800_RXC_CR, RCR_FL, priv->pause_=
tx);
> +       }
> +}
> +
> +static void nb8800_link_reconfigure(struct net_device *dev)
> +{
> +       struct nb8800_priv *priv =3D netdev_priv(dev);
> +       struct phy_device *phydev =3D priv->phydev;
> +       int change =3D 0;
> +
> +       if (phydev->link) {
> +               if (phydev->speed !=3D priv->speed) {
> +                       priv->speed =3D phydev->speed;
> +                       change =3D 1;
> +               }
> +
> +               if (phydev->duplex !=3D priv->duplex) {
> +                       priv->duplex =3D phydev->duplex;
> +                       change =3D 1;
> +               }
> +
> +               if (change)
> +                       nb8800_mac_config(dev);
> +
> +               nb8800_pause_config(dev);
> +       }
> +
> +       if (phydev->link !=3D priv->link) {
> +               priv->link =3D phydev->link;
> +               change =3D 1;
> +       }
> +
> +       if (change)
> +               phy_print_status(priv->phydev);
> +}
> +
> +static void nb8800_update_mac_addr(struct net_device *dev)
> +{
> +       struct nb8800_priv *priv =3D netdev_priv(dev);
> +       int i;
> +
> +       for (i =3D 0; i < ETH_ALEN; i++)
> +               nb8800_writeb(priv, NB8800_SRC_ADDR(i), dev->dev_addr=
[i]);
> +
> +       for (i =3D 0; i < ETH_ALEN; i++)
> +               nb8800_writeb(priv, NB8800_UC_ADDR(i), dev->dev_addr[=
i]);
> +}
> +
> +static int nb8800_set_mac_address(struct net_device *dev, void *addr=
)
> +{
> +       struct sockaddr *sock =3D addr;
> +
> +       if (netif_running(dev))
> +               return -EBUSY;
> +
> +       ether_addr_copy(dev->dev_addr, sock->sa_data);
> +       nb8800_update_mac_addr(dev);
> +
> +       return 0;
> +}
> +
> +static void nb8800_mc_init(struct net_device *dev, int val)
> +{
> +       struct nb8800_priv *priv =3D netdev_priv(dev);
> +
> +       nb8800_writeb(priv, NB8800_MC_INIT, val);
> +       readb_poll_timeout_atomic(priv->base + NB8800_MC_INIT, val, !=
val,
> +                                 1, 1000);
> +}
> +
> +static void nb8800_set_rx_mode(struct net_device *dev)
> +{
> +       struct nb8800_priv *priv =3D netdev_priv(dev);
> +       struct netdev_hw_addr *ha;
> +       int i;
> +
> +       if (dev->flags & (IFF_PROMISC | IFF_ALLMULTI)) {
> +               nb8800_mac_af(dev, false);
> +               return;
> +       }
> +
> +       nb8800_mac_af(dev, true);
> +       nb8800_mc_init(dev, 0);
> +
> +       netdev_for_each_mc_addr(ha, dev) {
> +               for (i =3D 0; i < ETH_ALEN; i++)
> +                       nb8800_writeb(priv, NB8800_MC_ADDR(i), ha->ad=
dr[i]);
> +
> +               nb8800_mc_init(dev, 0xff);
> +       }
> +}
> +
> +#define RX_DESC_SIZE (RX_DESC_COUNT * sizeof(struct nb8800_rx_desc))
> +#define TX_DESC_SIZE (TX_DESC_COUNT * sizeof(struct nb8800_tx_desc))
> +
> +static void nb8800_dma_free(struct net_device *dev)
> +{
> +       struct nb8800_priv *priv =3D netdev_priv(dev);
> +       int i;

looks like unsigned int i;

> +
> +       if (priv->rx_bufs) {
> +               for (i =3D 0; i < RX_DESC_COUNT; i++)
> +                       if (priv->rx_bufs[i].page)
> +                               put_page(priv->rx_bufs[i].page);
> +
> +               kfree(priv->rx_bufs);
> +               priv->rx_bufs =3D NULL;
> +       }
> +
> +       if (priv->tx_bufs) {
> +               for (i =3D 0; i < TX_DESC_COUNT; i++)
> +                       kfree_skb(priv->tx_bufs[i].skb);
> +
> +               kfree(priv->tx_bufs);
> +               priv->tx_bufs =3D NULL;
> +       }
> +
> +       if (priv->rx_descs) {
> +               dma_free_coherent(dev->dev.parent, RX_DESC_SIZE, priv=
->rx_descs,
> +                                 priv->rx_desc_dma);
> +               priv->rx_descs =3D NULL;
> +       }
> +
> +       if (priv->tx_descs) {
> +               dma_free_coherent(dev->dev.parent, TX_DESC_SIZE, priv=
->tx_descs,
> +                                 priv->tx_desc_dma);
> +               priv->tx_descs =3D NULL;
> +       }
> +}
> +
> +static void nb8800_dma_reset(struct net_device *dev)
> +{
> +       struct nb8800_priv *priv =3D netdev_priv(dev);
> +       struct nb8800_rx_desc *rxd;
> +       struct nb8800_tx_desc *txd;
> +       int i;

Ditto.

> +
> +       for (i =3D 0; i < RX_DESC_COUNT; i++) {
> +               dma_addr_t rx_dma =3D priv->rx_desc_dma + i * sizeof(=
*rxd);
> +
> +               rxd =3D &priv->rx_descs[i];
> +               rxd->desc.n_addr =3D rx_dma + sizeof(*rxd);
> +               rxd->desc.r_addr =3D
> +                       rx_dma + offsetof(struct nb8800_rx_desc, repo=
rt);
> +               rxd->desc.config =3D priv->rx_dma_config;
> +               rxd->report =3D 0;
> +       }
> +
> +       rxd->desc.n_addr =3D priv->rx_desc_dma;
> +       rxd->desc.config |=3D DESC_EOC;
> +
> +       priv->rx_eoc =3D RX_DESC_COUNT - 1;
> +
> +       for (i =3D 0; i < TX_DESC_COUNT; i++) {
> +               struct nb8800_tx_buf *txb =3D &priv->tx_bufs[i];
> +               dma_addr_t r_dma =3D txb->dma_desc +
> +                       offsetof(struct nb8800_tx_desc, report);
> +
> +               txd =3D &priv->tx_descs[i];
> +               txd->desc[0].r_addr =3D r_dma;
> +               txd->desc[1].r_addr =3D r_dma;
> +               txd->report =3D 0;
> +       }
> +
> +       priv->tx_next =3D 0;
> +       priv->tx_queue =3D 0;
> +       priv->tx_done =3D 0;
> +       atomic_set(&priv->tx_free, TX_DESC_COUNT);
> +
> +       nb8800_writel(priv, NB8800_RX_DESC_ADDR, priv->rx_desc_dma);
> +
> +       wmb();          /* ensure all setup is written before startin=
g */
> +}
> +
> +static int nb8800_dma_init(struct net_device *dev)
> +{
> +       struct nb8800_priv *priv =3D netdev_priv(dev);
> +       int n_rx =3D RX_DESC_COUNT;
> +       int n_tx =3D TX_DESC_COUNT;
> +       int err;
> +       int i;

Ditto.

> +
> +       priv->rx_descs =3D dma_alloc_coherent(dev->dev.parent, RX_DES=
C_SIZE,
> +                                           &priv->rx_desc_dma, GFP_K=
ERNEL);
> +       if (!priv->rx_descs)
> +               goto err_out;
> +
> +       priv->rx_bufs =3D kcalloc(n_rx, sizeof(*priv->rx_bufs), GFP_K=
ERNEL);
> +       if (!priv->rx_bufs)
> +               goto err_out;
> +
> +       for (i =3D 0; i < n_rx; i++) {
> +               err =3D nb8800_alloc_rx(dev, i, false);
> +               if (err)
> +                       goto err_out;
> +       }
> +
> +       priv->tx_descs =3D dma_alloc_coherent(dev->dev.parent, TX_DES=
C_SIZE,
> +                                           &priv->tx_desc_dma, GFP_K=
ERNEL);
> +       if (!priv->tx_descs)
> +               goto err_out;
> +
> +       priv->tx_bufs =3D kcalloc(n_tx, sizeof(*priv->tx_bufs), GFP_K=
ERNEL);
> +       if (!priv->tx_bufs)
> +               goto err_out;
> +
> +       for (i =3D 0; i < n_tx; i++)
> +               priv->tx_bufs[i].dma_desc =3D
> +                       priv->tx_desc_dma + i * sizeof(struct nb8800_=
tx_desc);
> +
> +       nb8800_dma_reset(dev);
> +
> +       return 0;
> +
> +err_out:
> +       nb8800_dma_free(dev);
> +
> +       return -ENOMEM;
> +}
> +
> +static int nb8800_dma_stop(struct net_device *dev)
> +{
> +       struct nb8800_priv *priv =3D netdev_priv(dev);
> +       struct nb8800_tx_buf *txb =3D &priv->tx_bufs[0];
> +       struct nb8800_tx_desc *txd =3D &priv->tx_descs[0];
> +       int retry =3D 5;
> +       u32 txcr;
> +       u32 rxcr;
> +       int err;
> +       int i;

Ditto.

> +
> +       /* wait for tx to finish */
> +       err =3D readl_poll_timeout_atomic(priv->base + NB8800_TXC_CR,=
 txcr,
> +                                       !(txcr & TCR_EN) &&
> +                                       priv->tx_done =3D=3D priv->tx=
_next,
> +                                       1000, 1000000);
> +       if (err)
> +               return err;
> +
> +       /* The rx DMA only stops if it reaches the end of chain.
> +        * To make this happen, we set the EOC flag on all rx
> +        * descriptors, put the device in loopback mode, and send
> +        * a few dummy frames.  The interrupt handler will ignore
> +        * these since NAPI is disabled and no real frames are in
> +        * the tx queue. */

Block comment
/*
 * text
 */

> +
> +       for (i =3D 0; i < RX_DESC_COUNT; i++)
> +               priv->rx_descs[i].desc.config |=3D DESC_EOC;
> +
> +       txd->desc[0].s_addr =3D
> +               txb->dma_desc + offsetof(struct nb8800_tx_desc, buf);
> +       txd->desc[0].config =3D DESC_BTS(2) | DESC_DS | DESC_EOF | DE=
SC_EOC | 8;
> +       memset(txd->buf, 0, sizeof(txd->buf));
> +
> +       nb8800_mac_af(dev, false);
> +       nb8800_setb(priv, NB8800_MAC_MODE, LOOPBACK_EN);
> +
> +       do {
> +               nb8800_writel(priv, NB8800_TX_DESC_ADDR, txb->dma_des=
c);
> +               wmb();
> +               nb8800_writel(priv, NB8800_TXC_CR, txcr | TCR_EN);
> +
> +               err =3D readl_poll_timeout_atomic(priv->base + NB8800=
_RXC_CR,
> +                                               rxcr, !(rxcr & RCR_EN=
),
> +                                               1000, 100000);
> +       } while (err && --retry);
> +
> +       nb8800_mac_af(dev, true);
> +       nb8800_clearb(priv, NB8800_MAC_MODE, LOOPBACK_EN);
> +       nb8800_dma_reset(dev);
> +
> +       return retry ? 0 : -ETIMEDOUT;
> +}
> +
> +static void nb8800_pause_adv(struct net_device *dev)
> +{
> +       struct nb8800_priv *priv =3D netdev_priv(dev);
> +       u32 adv =3D 0;
> +
> +       if (!priv->phydev)
> +               return;
> +
> +       if (priv->pause_rx)
> +               adv |=3D ADVERTISED_Pause | ADVERTISED_Asym_Pause;
> +       if (priv->pause_tx)
> +               adv ^=3D ADVERTISED_Asym_Pause;
> +
> +       priv->phydev->supported |=3D adv;
> +       priv->phydev->advertising |=3D adv;
> +
> +}
> +
> +static int nb8800_open(struct net_device *dev)
> +{
> +       struct nb8800_priv *priv =3D netdev_priv(dev);
> +       int err;
> +
> +       /* clear any pending interrupts */
> +       nb8800_writel(priv, NB8800_RXC_SR, 0xf);
> +       nb8800_writel(priv, NB8800_TXC_SR, 0xf);
> +
> +       err =3D nb8800_dma_init(dev);
> +       if (err)
> +               return err;
> +
> +       err =3D request_irq(dev->irq, nb8800_irq, 0, dev_name(&dev->d=
ev), dev);
> +       if (err)
> +               goto err_free_dma;
> +
> +       nb8800_mac_rx(dev, true);
> +       nb8800_mac_tx(dev, true);
> +
> +       priv->phydev =3D of_phy_connect(dev, priv->phy_node,
> +                                     nb8800_link_reconfigure, 0,
> +                                     priv->phy_mode);
> +       if (!priv->phydev)
> +               goto err_free_irq;
> +
> +       nb8800_pause_adv(dev);
> +
> +       netdev_reset_queue(dev);
> +       napi_enable(&priv->napi);
> +       netif_start_queue(dev);
> +
> +       nb8800_start_rx(dev);
> +       phy_start(priv->phydev);
> +
> +       return 0;
> +
> +err_free_irq:
> +       free_irq(dev->irq, dev);
> +err_free_dma:
> +       nb8800_dma_free(dev);
> +
> +       return err;
> +}
> +
> +static int nb8800_stop(struct net_device *dev)
> +{
> +       struct nb8800_priv *priv =3D netdev_priv(dev);
> +
> +       phy_stop(priv->phydev);
> +
> +       netif_stop_queue(dev);
> +       napi_disable(&priv->napi);
> +
> +       nb8800_dma_stop(dev);
> +       nb8800_mac_rx(dev, false);
> +       nb8800_mac_tx(dev, false);
> +
> +       phy_disconnect(priv->phydev);
> +       priv->phydev =3D NULL;
> +
> +       free_irq(dev->irq, dev);
> +
> +       nb8800_dma_free(dev);
> +
> +       return 0;
> +}
> +
> +static int nb8800_ioctl(struct net_device *dev, struct ifreq *rq, in=
t cmd)
> +{
> +       struct nb8800_priv *priv =3D netdev_priv(dev);
> +
> +       return phy_mii_ioctl(priv->phydev, rq, cmd);
> +}
> +
> +static const struct net_device_ops nb8800_netdev_ops =3D {
> +       .ndo_open               =3D nb8800_open,
> +       .ndo_stop               =3D nb8800_stop,
> +       .ndo_start_xmit         =3D nb8800_xmit,
> +       .ndo_set_mac_address    =3D nb8800_set_mac_address,
> +       .ndo_set_rx_mode        =3D nb8800_set_rx_mode,
> +       .ndo_do_ioctl           =3D nb8800_ioctl,
> +       .ndo_change_mtu         =3D eth_change_mtu,
> +       .ndo_validate_addr      =3D eth_validate_addr,
> +};
> +
> +static int nb8800_get_settings(struct net_device *dev, struct ethtoo=
l_cmd *cmd)
> +{
> +       struct nb8800_priv *priv =3D netdev_priv(dev);
> +
> +       if (!priv->phydev)
> +               return -ENODEV;
> +
> +       return phy_ethtool_gset(priv->phydev, cmd);
> +}
> +
> +static int nb8800_set_settings(struct net_device *dev, struct ethtoo=
l_cmd *cmd)
> +{
> +       struct nb8800_priv *priv =3D netdev_priv(dev);
> +
> +       if (!priv->phydev)
> +               return -ENODEV;
> +
> +       return phy_ethtool_sset(priv->phydev, cmd);
> +}
> +
> +static int nb8800_nway_reset(struct net_device *dev)
> +{
> +       struct nb8800_priv *priv =3D netdev_priv(dev);
> +
> +       if (!priv->phydev)
> +               return -ENODEV;
> +
> +       return genphy_restart_aneg(priv->phydev);
> +}
> +
> +static void nb8800_get_pauseparam(struct net_device *dev,
> +                                 struct ethtool_pauseparam *pp)
> +{
> +       struct nb8800_priv *priv =3D netdev_priv(dev);
> +
> +       pp->autoneg =3D priv->pause_aneg;
> +       pp->rx_pause =3D priv->pause_rx;
> +       pp->tx_pause =3D priv->pause_tx;
> +}
> +
> +static int nb8800_set_pauseparam(struct net_device *dev,
> +                                struct ethtool_pauseparam *pp)
> +{
> +       struct nb8800_priv *priv =3D netdev_priv(dev);
> +
> +       priv->pause_aneg =3D pp->autoneg;
> +       priv->pause_rx =3D pp->rx_pause;
> +       priv->pause_tx =3D pp->tx_pause;
> +
> +       nb8800_pause_adv(dev);
> +
> +       if (!priv->pause_aneg)
> +               nb8800_pause_config(dev);
> +       else if (priv->phydev)
> +               phy_start_aneg(priv->phydev);
> +
> +       return 0;
> +}
> +
> +static const char nb8800_stats_names[][ETH_GSTRING_LEN] =3D {
> +       "rx_bytes_ok",
> +       "rx_frames_ok",
> +       "rx_undersize_frames",
> +       "rx_fragment_frames",
> +       "rx_64_byte_frames",
> +       "rx_127_byte_frames",
> +       "rx_255_byte_frames",
> +       "rx_511_byte_frames",
> +       "rx_1023_byte_frames",
> +       "rx_max_size_frames",
> +       "rx_oversize_frames",
> +       "rx_bad_fcs_frames",
> +       "rx_broadcast_frames",
> +       "rx_multicast_frames",
> +       "rx_control_frames",
> +       "rx_pause_frames",
> +       "rx_unsup_control_frames",
> +       "rx_align_error_frames",
> +       "rx_overrun_frames",
> +       "rx_jabber_frames",
> +       "rx_bytes",
> +       "rx_frames",
> +
> +       "tx_bytes_ok",
> +       "tx_frames_ok",
> +       "tx_64_byte_frames",
> +       "tx_127_byte_frames",
> +       "tx_255_byte_frames",
> +       "tx_511_byte_frames",
> +       "tx_1023_byte_frames",
> +       "tx_max_size_frames",
> +       "tx_oversize_frames",
> +       "tx_broadcast_frames",
> +       "tx_multicast_frames",
> +       "tx_control_frames",
> +       "tx_pause_frames",
> +       "tx_underrun_frames",
> +       "tx_single_collision_frames",
> +       "tx_multi_collision_frames",
> +       "tx_deferred_collision_frames",
> +       "tx_late_collision_frames",
> +       "tx_excessive_collision_frames",
> +       "tx_bytes",
> +       "tx_frames",
> +       "tx_collisions",
> +};
> +
> +#define NB8800_NUM_STATS ARRAY_SIZE(nb8800_stats_names)
> +
> +static int nb8800_get_sset_count(struct net_device *dev, int sset)
> +{
> +       if (sset =3D=3D ETH_SS_STATS)
> +               return NB8800_NUM_STATS;
> +
> +       return -EOPNOTSUPP;
> +}
> +
> +static void nb8800_get_strings(struct net_device *dev, u32 sset, u8 =
*buf)
> +{
> +       if (sset =3D=3D ETH_SS_STATS)
> +               memcpy(buf, &nb8800_stats_names, sizeof(nb8800_stats_=
names));
> +}
> +
> +static u32 nb8800_read_stat(struct net_device *dev, int index)
> +{
> +       struct nb8800_priv *priv =3D netdev_priv(dev);
> +
> +       nb8800_writeb(priv, NB8800_STAT_INDEX, index);
> +
> +       return nb8800_readl(priv, NB8800_STAT_DATA);
> +}
> +
> +static void nb8800_get_ethtool_stats(struct net_device *dev,
> +                                    struct ethtool_stats *estats, u6=
4 *st)
> +{
> +       u32 rx, tx;
> +       int i;

unsigned int i;

> +
> +       for (i =3D 0; i < NB8800_NUM_STATS / 2; i++) {
> +               rx =3D nb8800_read_stat(dev, i);
> +               tx =3D nb8800_read_stat(dev, i | 0x80);
> +               st[i] =3D rx;
> +               st[i + NB8800_NUM_STATS / 2] =3D tx;
> +       }
> +}
> +
> +static const struct ethtool_ops nb8800_ethtool_ops =3D {
> +       .get_settings           =3D nb8800_get_settings,
> +       .set_settings           =3D nb8800_set_settings,
> +       .nway_reset             =3D nb8800_nway_reset,
> +       .get_link               =3D ethtool_op_get_link,
> +       .get_pauseparam         =3D nb8800_get_pauseparam,
> +       .set_pauseparam         =3D nb8800_set_pauseparam,
> +       .get_sset_count         =3D nb8800_get_sset_count,
> +       .get_strings            =3D nb8800_get_strings,
> +       .get_ethtool_stats      =3D nb8800_get_ethtool_stats,
> +};
> +
> +static int nb8800_hw_init(struct net_device *dev)
> +{
> +       struct nb8800_priv *priv =3D netdev_priv(dev);
> +       u32 val;
> +
> +       val =3D TX_RETRY_EN | TX_PAD_EN | TX_APPEND_FCS;
> +       nb8800_writeb(priv, NB8800_TX_CTL1, val);
> +
> +       /* Collision retry count */
> +       nb8800_writeb(priv, NB8800_TX_CTL2, 5);
> +
> +       val =3D RX_PAD_STRIP | RX_AF_EN;
> +       nb8800_writeb(priv, NB8800_RX_CTL, val);
> +
> +       /* Chosen by fair dice roll */
> +       nb8800_writeb(priv, NB8800_RANDOM_SEED, 4);
> +
> +       /* TX cycles per deferral period */
> +       nb8800_writeb(priv, NB8800_TX_SDP, 12);
> +
> +       /* The following three threshold values have been
> +        * experimentally determined for good results. */
> +
> +       /* RX/TX FIFO threshold for partial empty (64-bit entries) */
> +       nb8800_writeb(priv, NB8800_PE_THRESHOLD, 0);
> +
> +       /* RX/TX FIFO threshold for partial full (64-bit entries) */
> +       nb8800_writeb(priv, NB8800_PF_THRESHOLD, 255);
> +
> +       /* Buffer size for transmit (64-bit entries) */
> +       nb8800_writeb(priv, NB8800_TX_BUFSIZE, 64);
> +
> +       /* Configure tx DMA */
> +
> +       val =3D nb8800_readl(priv, NB8800_TXC_CR);
> +       val &=3D TCR_LE;          /* keep endian setting */
> +       val |=3D TCR_DM;          /* DMA descriptor mode */
> +       val |=3D TCR_RS;          /* automatically store tx status  *=
/
> +       val |=3D TCR_DIE;         /* interrupt on DMA chain completio=
n */
> +       val |=3D TCR_TFI(7);      /* interrupt after 7 frames transmi=
tted */
> +       val |=3D TCR_BTS(2);      /* 32-byte bus transaction size */
> +       nb8800_writel(priv, NB8800_TXC_CR, val);
> +
> +       /* TX complete interrupt after 10 ms or 7 frames (see above) =
*/
> +       val =3D clk_get_rate(priv->clk) / 100;
> +       nb8800_writel(priv, NB8800_TX_ITR, val);
> +
> +       /* Configure rx DMA */
> +
> +       val =3D nb8800_readl(priv, NB8800_RXC_CR);
> +       val &=3D RCR_LE;          /* keep endian setting */
> +       val |=3D RCR_DM;          /* DMA descriptor mode */
> +       val |=3D RCR_RS;          /* automatically store rx status */
> +       val |=3D RCR_DIE;         /* interrupt at end of DMA chain */
> +       val |=3D RCR_RFI(7);      /* interrupt after 7 frames receive=
d */
> +       val |=3D RCR_BTS(2);      /* 32-byte bus transaction size */
> +       nb8800_writel(priv, NB8800_RXC_CR, val);
> +
> +       /* The rx interrupt can fire before the DMA has completed
> +        * unless a small delay is added.  50 us is hopefully enough.=
 */
> +       priv->rx_itr_irq =3D clk_get_rate(priv->clk) / 20000;
> +
> +       /* In NAPI poll mode we want to disable interrupts, but the
> +        * hardware does not permit this.  Delay 10 ms instead. */
> +       priv->rx_itr_poll =3D clk_get_rate(priv->clk) / 100;
> +
> +       nb8800_writel(priv, NB8800_RX_ITR, priv->rx_itr_irq);
> +
> +       priv->rx_dma_config =3D RX_BUF_SIZE | DESC_BTS(2) | DESC_DS |=
 DESC_EOF;
> +
> +       /* Flow control settings */
> +
> +       /* Pause time of 0.1 ms */
> +       val =3D 100000 / 512;
> +       nb8800_writeb(priv, NB8800_PQ1, val >> 8);
> +       nb8800_writeb(priv, NB8800_PQ2, val & 0xff);
> +
> +       /* Auto-negotiate by default */
> +       priv->pause_aneg =3D true;
> +       priv->pause_rx =3D true;
> +       priv->pause_tx =3D true;
> +
> +       nb8800_mc_init(dev, 0);
> +
> +       return 0;
> +}
> +
> +static int nb8800_tangox_init(struct net_device *dev)
> +{
> +       struct nb8800_priv *priv =3D netdev_priv(dev);
> +       u32 pad_mode =3D PAD_MODE_MII;
> +
> +       switch (priv->phy_mode) {
> +       case PHY_INTERFACE_MODE_MII:
> +       case PHY_INTERFACE_MODE_GMII:
> +               pad_mode =3D PAD_MODE_MII;
> +               break;
> +
> +       case PHY_INTERFACE_MODE_RGMII:
> +               pad_mode =3D PAD_MODE_RGMII;
> +               break;
> +
> +       case PHY_INTERFACE_MODE_RGMII_TXID:
> +               pad_mode =3D PAD_MODE_RGMII | PAD_MODE_GTX_CLK_DELAY;
> +               break;
> +
> +       default:
> +               dev_err(dev->dev.parent, "unsupported phy mode %s\n",
> +                       phy_modes(priv->phy_mode));
> +               return -EINVAL;
> +       }
> +
> +       nb8800_writeb(priv, NB8800_TANGOX_PAD_MODE, pad_mode);
> +
> +       return 0;
> +}
> +
> +static int nb8800_tangox_reset(struct net_device *dev)
> +{
> +       struct nb8800_priv *priv =3D netdev_priv(dev);
> +       int clk_div;
> +
> +       nb8800_writeb(priv, NB8800_TANGOX_RESET, 0);
> +       usleep_range(1000, 10000);
> +       nb8800_writeb(priv, NB8800_TANGOX_RESET, 1);
> +
> +       wmb();          /* ensure reset is cleared before proceeding =
*/
> +
> +       clk_div =3D DIV_ROUND_UP(clk_get_rate(priv->clk), 2 * MAX_MDC=
_CLOCK);
> +       nb8800_writew(priv, NB8800_TANGOX_MDIO_CLKDIV, clk_div);
> +
> +       return 0;
> +}
> +
> +static const struct nb8800_ops nb8800_tangox_ops =3D {
> +       .init   =3D nb8800_tangox_init,
> +       .reset  =3D nb8800_tangox_reset,
> +};
> +
> +static int nb8800_tango4_init(struct net_device *dev)
> +{
> +       struct nb8800_priv *priv =3D netdev_priv(dev);
> +       int err;
> +
> +       err =3D nb8800_tangox_init(dev);
> +       if (err)
> +               return err;
> +
> +       /* On tango4 interrupt on DMA completion per frame works and =
gives
> +        * better performance despite generating more rx interrupts. =
*/
> +
> +       /* Disable unnecessary interrupt on rx completion */
> +       nb8800_clearl(priv, NB8800_RXC_CR, RCR_RFI(7));
> +
> +       /* Request interrupt on descriptor DMA completion */
> +       priv->rx_dma_config |=3D DESC_ID;
> +
> +       return 0;
> +}
> +
> +static const struct nb8800_ops nb8800_tango4_ops =3D {
> +       .init   =3D nb8800_tango4_init,
> +       .reset  =3D nb8800_tangox_reset,
> +};
> +
> +static const struct of_device_id nb8800_dt_ids[] =3D {
> +       {
> +               .compatible =3D "aurora,nb8800",
> +       },
> +       {
> +               .compatible =3D "sigma,smp8642-ethernet",
> +               .data =3D &nb8800_tangox_ops,
> +       },
> +       {
> +               .compatible =3D "sigma,smp8734-ethernet",
> +               .data =3D &nb8800_tango4_ops,
> +       },
> +       { }
> +};
> +
> +static int nb8800_probe(struct platform_device *pdev)
> +{
> +       const struct of_device_id *match;
> +       const struct nb8800_ops *ops =3D NULL;
> +       struct nb8800_priv *priv;
> +       struct resource *res;
> +       struct net_device *dev;
> +       struct mii_bus *bus;
> +       const unsigned char *mac;
> +       void __iomem *base;
> +       int irq;
> +       int ret;
> +
> +       match =3D of_match_device(nb8800_dt_ids, &pdev->dev);
> +       if (match)
> +               ops =3D match->data;
> +
> +       irq =3D platform_get_irq(pdev, 0);
> +       if (irq <=3D 0) {
> +               dev_err(&pdev->dev, "No IRQ\n");
> +               return -EINVAL;
> +       }
> +
> +       res =3D platform_get_resource(pdev, IORESOURCE_MEM, 0);
> +       base =3D devm_ioremap_resource(&pdev->dev, res);
> +       if (IS_ERR(base))
> +               return PTR_ERR(base);
> +
> +       dev_dbg(&pdev->dev, "AU-NB8800 Ethernet at %pa\n", &res->star=
t);
> +
> +       dev =3D alloc_etherdev(sizeof(*priv));
> +       if (!dev)
> +               return -ENOMEM;
> +
> +       platform_set_drvdata(pdev, dev);
> +       SET_NETDEV_DEV(dev, &pdev->dev);
> +
> +       priv =3D netdev_priv(dev);
> +       priv->base =3D base;
> +
> +       priv->phy_mode =3D of_get_phy_mode(pdev->dev.of_node);
> +       if (priv->phy_mode < 0)
> +               priv->phy_mode =3D PHY_INTERFACE_MODE_RGMII;
> +
> +       priv->clk =3D devm_clk_get(&pdev->dev, NULL);
> +       if (IS_ERR(priv->clk)) {
> +               dev_err(&pdev->dev, "failed to get clock\n");
> +               ret =3D PTR_ERR(priv->clk);
> +               goto err_free_dev;
> +       }
> +
> +       ret =3D clk_prepare_enable(priv->clk);
> +       if (ret)
> +               goto err_free_dev;
> +
> +       spin_lock_init(&priv->tx_lock);
> +
> +       if (ops && ops->reset) {
> +               ret =3D ops->reset(dev);
> +               if (ret)
> +                       goto err_free_dev;
> +       }
> +
> +       bus =3D devm_mdiobus_alloc(&pdev->dev);
> +       if (!bus) {
> +               ret =3D -ENOMEM;
> +               goto err_disable_clk;
> +       }
> +
> +       bus->name =3D "nb8800-mii";
> +       bus->read =3D nb8800_mdio_read;
> +       bus->write =3D nb8800_mdio_write;
> +       bus->parent =3D &pdev->dev;
> +       snprintf(bus->id, MII_BUS_ID_SIZE, "%lx.nb8800-mii",
> +                (unsigned long)res->start);
> +       bus->priv =3D priv;
> +
> +       ret =3D of_mdiobus_register(bus, pdev->dev.of_node);
> +       if (ret) {
> +               dev_err(&pdev->dev, "failed to register MII bus\n");
> +               goto err_disable_clk;
> +       }
> +
> +       priv->phy_node =3D of_parse_phandle(pdev->dev.of_node, "phy-h=
andle", 0);
> +       if (!priv->phy_node) {
> +               dev_err(&pdev->dev, "no PHY specified\n");
> +               ret =3D -ENODEV;
> +               goto err_free_bus;
> +       }
> +
> +       priv->mii_bus =3D bus;
> +
> +       ret =3D nb8800_hw_init(dev);
> +       if (ret)
> +               goto err_free_bus;
> +
> +       if (ops && ops->init) {
> +               ret =3D ops->init(dev);
> +               if (ret)
> +                       goto err_free_bus;
> +       }
> +
> +       dev->netdev_ops =3D &nb8800_netdev_ops;
> +       dev->ethtool_ops =3D &nb8800_ethtool_ops;
> +       dev->flags |=3D IFF_MULTICAST;
> +       dev->irq =3D irq;
> +
> +       mac =3D of_get_mac_address(pdev->dev.of_node);
> +       if (mac)
> +               ether_addr_copy(dev->dev_addr, mac);
> +
> +       if (!is_valid_ether_addr(dev->dev_addr))
> +               eth_hw_addr_random(dev);
> +
> +       nb8800_update_mac_addr(dev);
> +
> +       netif_carrier_off(dev);
> +
> +       ret =3D register_netdev(dev);
> +       if (ret) {
> +               netdev_err(dev, "failed to register netdev\n");
> +               goto err_free_dma;
> +       }
> +
> +       netif_napi_add(dev, &priv->napi, nb8800_poll, NAPI_POLL_WEIGH=
T);
> +
> +       netdev_info(dev, "MAC address %pM\n", dev->dev_addr);
> +
> +       return 0;
> +
> +err_free_dma:
> +       nb8800_dma_free(dev);
> +err_free_bus:
> +       mdiobus_unregister(bus);
> +err_disable_clk:
> +       clk_disable_unprepare(priv->clk);
> +err_free_dev:
> +       free_netdev(dev);
> +
> +       return ret;
> +}
> +
> +static int nb8800_remove(struct platform_device *pdev)
> +{
> +       struct net_device *ndev =3D platform_get_drvdata(pdev);
> +       struct nb8800_priv *priv =3D netdev_priv(ndev);
> +
> +       unregister_netdev(ndev);
> +
> +       mdiobus_unregister(priv->mii_bus);
> +
> +       clk_disable_unprepare(priv->clk);
> +
> +       nb8800_dma_free(ndev);
> +       free_netdev(ndev);
> +
> +       return 0;
> +}
> +
> +static struct platform_driver nb8800_driver =3D {
> +       .driver =3D {
> +               .name           =3D "nb8800",
> +               .of_match_table =3D nb8800_dt_ids,
> +       },
> +       .probe  =3D nb8800_probe,
> +       .remove =3D nb8800_remove,
> +};
> +
> +module_platform_driver(nb8800_driver);
> +
> +MODULE_DESCRIPTION("Aurora AU-NB8800 Ethernet driver");
> +MODULE_AUTHOR("Mans Rullgard <mans@mansr.com>");
> +MODULE_LICENSE("GPL");
> diff --git a/drivers/net/ethernet/aurora/nb8800.h b/drivers/net/ether=
net/aurora/nb8800.h
> new file mode 100644
> index 0000000..e108d01
> --- /dev/null
> +++ b/drivers/net/ethernet/aurora/nb8800.h
> @@ -0,0 +1,314 @@
> +#ifndef _NB8800_H_
> +#define _NB8800_H_
> +
> +#include <linux/types.h>
> +#include <linux/skbuff.h>
> +#include <linux/phy.h>
> +#include <linux/clk.h>
> +#include <linux/bitops.h>
> +
> +#define RX_DESC_COUNT                  256
> +#define TX_DESC_COUNT                  256
> +
> +#define NB8800_DESC_LOW                        4
> +
> +#define RX_BUF_SIZE                    1552
> +
> +#define RX_COPYBREAK                   256
> +#define RX_COPYHDR                     128
> +
> +#define MAX_MDC_CLOCK                  2500000
> +
> +/* Stargate Solutions SSN8800 core registers */
> +#define NB8800_TX_CTL1                 0x000
> +#define TX_TPD                         BIT(5)
> +#define TX_APPEND_FCS                  BIT(4)
> +#define TX_PAD_EN                      BIT(3)
> +#define TX_RETRY_EN                    BIT(2)
> +#define TX_EN                          BIT(0)
> +
> +#define NB8800_TX_CTL2                 0x001
> +
> +#define NB8800_RX_CTL                  0x004
> +#define RX_BC_DISABLE                  BIT(7)
> +#define RX_RUNT                                BIT(6)
> +#define RX_AF_EN                       BIT(5)
> +#define RX_PAUSE_EN                    BIT(3)
> +#define RX_SEND_CRC                    BIT(2)
> +#define RX_PAD_STRIP                   BIT(1)
> +#define RX_EN                          BIT(0)
> +
> +#define NB8800_RANDOM_SEED             0x008
> +#define NB8800_TX_SDP                  0x14
> +#define NB8800_TX_TPDP1                        0x18
> +#define NB8800_TX_TPDP2                        0x19
> +#define NB8800_SLOT_TIME               0x1c
> +
> +#define NB8800_MDIO_CMD                        0x020

> +#define MIIAR_ADDR(x)                  ((x) << 21)
> +#define MIIAR_REG(x)                   ((x) << 16)
> +#define MIIAR_DATA(x)                  ((x) <<  0)
> +#define MDIO_CMD_GO                    BIT(31)
> +#define MDIO_CMD_WR                    BIT(26)

Perhaps sort them by bits used?

> +
> +#define NB8800_MDIO_STS                        0x024
> +#define MDIO_STS_ERR                   BIT(31)
> +
> +#define NB8800_MC_ADDR(i)              (0x028 + (i))
> +#define NB8800_MC_INIT                 0x02e
> +#define NB8800_UC_ADDR(i)              (0x03c + (i))
> +
> +#define NB8800_MAC_MODE                        0x044
> +#define RGMII_MODE                     BIT(7)
> +#define HALF_DUPLEX                    BIT(4)
> +#define BURST_EN                       BIT(3)
> +#define LOOPBACK_EN                    BIT(2)
> +#define GMAC_MODE                      BIT(0)
> +
> +#define NB8800_IC_THRESHOLD            0x050
> +#define NB8800_PE_THRESHOLD            0x051
> +#define NB8800_PF_THRESHOLD            0x052
> +#define NB8800_TX_BUFSIZE              0x054
> +#define NB8800_FIFO_CTL                        0x056
> +#define NB8800_PQ1                     0x060
> +#define NB8800_PQ2                     0x061
> +#define NB8800_SRC_ADDR(i)             (0x06a + (i))
> +#define NB8800_STAT_DATA               0x078
> +#define NB8800_STAT_INDEX              0x07c
> +#define NB8800_STAT_CLEAR              0x07d
> +
> +#define NB8800_SLEEP_MODE              0x07e
> +#define SLEEP_MODE                     BIT(0)
> +
> +#define NB8800_WAKEUP                  0x07f
> +#define WAKEUP                         BIT(0)
> +
> +/* Aurora NB8800 host interface registers */
> +#define NB8800_TXC_CR                  0x100
> +#define TCR_LK                         BIT(12)
> +#define TCR_DS                         BIT(11)
> +#define TCR_BTS(x)                     (((x) & 0x7) << 8)
> +#define TCR_DIE                                BIT(7)
> +#define TCR_TFI(x)                     (((x) & 0x7) << 4)
> +#define TCR_LE                         BIT(3)
> +#define TCR_RS                         BIT(2)
> +#define TCR_DM                         BIT(1)
> +#define TCR_EN                         BIT(0)
> +
> +#define NB8800_TXC_SR                  0x104
> +#define TSR_DE                         BIT(3)
> +#define TSR_DI                         BIT(2)
> +#define TSR_TO                         BIT(1)
> +#define TSR_TI                         BIT(0)
> +
> +#define NB8800_TX_SAR                  0x108
> +#define NB8800_TX_DESC_ADDR            0x10c
> +
> +#define NB8800_TX_REPORT_ADDR          0x110
> +#define TX_BYTES_TRANSFERRED(x)                (((x) >> 16) & 0xffff=
)
> +#define TX_FIRST_DEFERRAL              BIT(7)
> +#define TX_EARLY_COLLISIONS(x)         (((x) >> 3) & 0xf)
> +#define TX_LATE_COLLISION              BIT(2)
> +#define TX_PACKET_DROPPED              BIT(1)
> +#define TX_FIFO_UNDERRUN               BIT(0)
> +#define IS_TX_ERROR(r)                 ((r) & 0x07)
> +
> +#define NB8800_TX_FIFO_SR              0x114
> +#define NB8800_TX_ITR                  0x118
> +
> +#define NB8800_RXC_CR                  0x200
> +#define RCR_FL                         BIT(13)
> +#define RCR_LK                         BIT(12)
> +#define RCR_DS                         BIT(11)
> +#define RCR_BTS(x)                     (((x) & 7) << 8)
> +#define RCR_DIE                                BIT(7)
> +#define RCR_RFI(x)                     (((x) & 7) << 4)
> +#define RCR_LE                         BIT(3)
> +#define RCR_RS                         BIT(2)
> +#define RCR_DM                         BIT(1)
> +#define RCR_EN                         BIT(0)
> +
> +#define NB8800_RXC_SR                  0x204
> +#define RSR_DE                         BIT(3)
> +#define RSR_DI                         BIT(2)
> +#define RSR_RO                         BIT(1)
> +#define RSR_RI                         BIT(0)
> +
> +#define NB8800_RX_SAR                  0x208
> +#define NB8800_RX_DESC_ADDR            0x20c
> +
> +#define NB8800_RX_REPORT_ADDR          0x210
> +#define RX_BYTES_TRANSFERRED(x)                (((x) >> 16) & 0xFFFF=
)
> +#define RX_MULTICAST_PKT               BIT(9)
> +#define RX_BROADCAST_PKT               BIT(8)
> +#define RX_LENGTH_ERR                  BIT(7)
> +#define RX_FCS_ERR                     BIT(6)
> +#define RX_RUNT_PKT                    BIT(5)
> +#define RX_FIFO_OVERRUN                        BIT(4)
> +#define RX_LATE_COLLISION              BIT(3)
> +#define RX_ALIGNMENT_ERROR             BIT(2)
> +#define RX_ERROR_MASK                  0xfc
> +#define IS_RX_ERROR(r)                 ((r) & RX_ERROR_MASK)
> +
> +#define NB8800_RX_FIFO_SR              0x214
> +#define NB8800_RX_ITR                  0x218
> +
> +/* Sigma Designs SMP86xx additional registers */
> +#define NB8800_TANGOX_PAD_MODE         0x400
> +#define PAD_MODE_MASK                  0x7
> +#define PAD_MODE_MII                   0x0
> +#define PAD_MODE_RGMII                 0x1
> +#define PAD_MODE_GTX_CLK_INV           BIT(3)
> +#define PAD_MODE_GTX_CLK_DELAY         BIT(4)
> +
> +#define NB8800_TANGOX_MDIO_CLKDIV      0x420
> +#define NB8800_TANGOX_RESET            0x424
> +
> +/* Hardware DMA descriptor */
> +struct nb8800_dma_desc {
> +       u32                             s_addr; /* start address */
> +       u32                             n_addr; /* next descriptor ad=
dress */
> +       u32                             r_addr; /* report address */
> +       u32                             config;
> +} __aligned(8);
> +
> +#define DESC_ID                                BIT(23)
> +#define DESC_EOC                       BIT(22)
> +#define DESC_EOF                       BIT(21)
> +#define DESC_LK                                BIT(20)
> +#define DESC_DS                                BIT(19)
> +#define DESC_BTS(x)                    (((x) & 0x7) << 16)
> +
> +/* DMA descriptor and associated data for rx.
> + * Allocated from coherent memory.
> + */
> +struct nb8800_rx_desc {
> +       /* DMA descriptor */
> +       struct nb8800_dma_desc          desc;
> +
> +       /* Status report filled in by hardware */
> +       u32                             report;
> +};
> +
> +/* Address of buffer on rx ring */
> +struct nb8800_rx_buf {
> +       struct page                     *page;
> +       unsigned long                   offset;
> +};
> +
> +/* DMA descriptors and associated data for tx.
> + * Allocated from coherent memory.
> + */

Convert to kernel doc?

> +struct nb8800_tx_desc {
> +       /* DMA descriptor.  The second descriptor is used if packet
> +        * data is unaligned. *


> +       struct nb8800_dma_desc          desc[2];
> +
> +       /* Status report filled in by hardware */
> +       u32                             report;
> +
> +       /* Bounce buffer for initial unaligned part of packet */

> +       u8                              buf[8] __aligned(8);
> +};
> +
> +/* Packet in tx queue */
> +struct nb8800_tx_buf {


> +       /* Currently queued skb */
> +       struct sk_buff                  *skb;
> +
> +       /* DMA address of the first descriptor */
> +       dma_addr_t                      dma_desc;
> +
> +       /* DMA address of packet data */
> +       dma_addr_t                      dma_addr;
> +
> +       /* Length of DMA mapping, less than skb->len if alignment
> +        * buffer is used. */
> +       unsigned int                    dma_len;
> +
> +       /* Number of packets in chain starting here */
> +       unsigned int                    chain_len;
> +
> +       /* Packet chain ready to be submitted to hardware */
> +       bool                            ready;
> +};
> +
> +struct nb8800_priv {

> +       struct napi_struct              napi;
> +
> +       void __iomem                    *base;
> +
> +       /* RX DMA descriptors */
> +       struct nb8800_rx_desc           *rx_descs;
> +
> +       /* RX buffers referenced by DMA descriptors */
> +       struct nb8800_rx_buf            *rx_bufs;
> +
> +       /* Current end of chain */
> +       u32                             rx_eoc;
> +
> +       /* Value for rx interrupt time register in NAPI interrupt mod=
e */
> +       u32                             rx_itr_irq;
> +
> +       /* Value for rx interrupt time register in NAPI poll mode */
> +       u32                             rx_itr_poll;
> +
> +       /* Value for config field of rx DMA descriptors */
> +       u32                             rx_dma_config;
> +
> +       /* TX DMA descriptors */
> +       struct nb8800_tx_desc           *tx_descs;
> +
> +       /* TX packet queue */
> +       struct nb8800_tx_buf            *tx_bufs;
> +
> +       /* Number of free tx queue entries */
> +       atomic_t                        tx_free;
> +
> +       /* First free tx queue entry */
> +       u32                             tx_next;
> +
> +       /* Next buffer to transmit */
> +       u32                             tx_queue;
> +
> +       /* Start of current packet chain */
> +       struct nb8800_tx_buf            *tx_chain;
> +
> +       /* Next buffer to reclaim */
> +       u32                             tx_done;
> +
> +       /* Lock for DMA activation */
> +       spinlock_t                      tx_lock;
> +
> +       struct mii_bus                  *mii_bus;
> +       struct device_node              *phy_node;
> +       struct phy_device               *phydev;
> +
> +       /* PHY connection type from DT */
> +       int                             phy_mode;
> +
> +       /* Current link status */
> +       int                             speed;
> +       int                             duplex;
> +       int                             link;
> +
> +       /* Pause settings */
> +       bool                            pause_aneg;
> +       bool                            pause_rx;
> +       bool                            pause_tx;
> +
> +       /* DMA base address of rx descriptors, see rx_descs above */
> +       dma_addr_t                      rx_desc_dma;
> +
> +       /* DMA base address of tx descriptors, see tx_descs above */
> +       dma_addr_t                      tx_desc_dma;
> +
> +       struct clk                      *clk;
> +};
> +
> +struct nb8800_ops {
> +       int                             (*init)(struct net_device *de=
v);
> +       int                             (*reset)(struct net_device *d=
ev);
> +};
> +
> +#endif /* _NB8800_H_ */
> --
> 2.6.3
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kerne=
l" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/



--=20
With Best Regards,
Andy Shevchenko
