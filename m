From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/1] ARC VMAC ethernet driver.
Date: Thu, 17 Feb 2011 11:13:19 +0100
Message-ID: <1297937599.2670.44.camel@edumazet-laptop>
References: <AANLkTi=5XOmzzO=Bov4Rse_rhw_0uPnjPNN1DN9CLSXX@mail.gmail.com>
	 <1297935091-15504-1-git-send-email-afenkart@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Andreas Fenkart <afenkart@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:49124 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754526Ab1BQKNZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Feb 2011 05:13:25 -0500
Received: by fxm20 with SMTP id 20so2413806fxm.19
        for <netdev@vger.kernel.org>; Thu, 17 Feb 2011 02:13:23 -0800 (PST)
In-Reply-To: <1297935091-15504-1-git-send-email-afenkart@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 17 f=C3=A9vrier 2011 =C3=A0 10:31 +0100, Andreas Fenkart a =C3=
=A9crit :
> Signed-off-by: Andreas Fenkart <afenkart@gmail.com>
> ---
>  drivers/net/Kconfig   |   10 +
>  drivers/net/Makefile  |    1 +
>  drivers/net/arcvmac.c | 1494 +++++++++++++++++++++++++++++++++++++++=
++++++++++
>  drivers/net/arcvmac.h |  265 +++++++++
>  4 files changed, 1770 insertions(+), 0 deletions(-)
>=20



> +/* merge buffer chaining  */
> +struct sk_buff *vmac_merge_rx_buffers_unlocked(struct net_device *de=
v,
> +		struct vmac_buffer_desc *after,
> +		int pkt_len) /* data */
> +{
> +	struct vmac_priv *ap =3D netdev_priv(dev);
> +	struct sk_buff *merge_skb, *cur_skb;
> +	struct dma_fifo *rx_ring;
> +	struct vmac_buffer_desc *desc;
> +
> +	/* locking: same as vmac_rx_receive */
> +
> +	rx_ring =3D &ap->rx_ring;
> +	desc =3D &ap->rxbd[rx_ring->tail];
> +
> +	WARN_ON(desc =3D=3D after);
> +
> +	/* strip FCS */
> +	pkt_len -=3D 4;
> +
> +	merge_skb =3D netdev_alloc_skb_ip_align(dev, pkt_len + NET_IP_ALIGN=
);


You can remove the "+ NET_IP_ALIGN", its already done in
netdev_alloc_skb_ip_align()

Also, it seems strange you want to build one big SKB (no frag), while
this NIC is able to feed multiple frags.

(Change to get a SKB to hold a 9000 bytes frame is very very low if you=
r
memory gets fragmented)

> +	if (!merge_skb) {
> +		dev_err(&ap->pdev->dev, "failed to allocate merged rx_skb, rx skb'=
s left %d\n",
> +				fifo_used(rx_ring));
> +
> +		return NULL;
> +	}
> +
> +	while (desc !=3D after && pkt_len) {
> +		struct vmac_buffer_desc *desc;
> +		int buf_len, valid;
> +
> +		/* desc needs wrapping */
> +		desc =3D &ap->rxbd[rx_ring->tail];
> +		cur_skb =3D ap->rx_skbuff[rx_ring->tail];
> +		WARN_ON(!cur_skb);
> +
> +		dma_unmap_single(&ap->pdev->dev, desc->data, ap->rx_skb_size,
> +				DMA_FROM_DEVICE);
> +
> +		/* do not copy FCS */
> +		buf_len =3D le32_to_cpu(desc->info) & BD_LEN;
> +		valid =3D min(pkt_len, buf_len);
> +		pkt_len -=3D valid;
> +
> +		memcpy(skb_put(merge_skb, valid), cur_skb->data, valid);
> +
> +		fifo_inc_tail(rx_ring);
> +	}
> +
> +	/* merging_pressure++ */
> +
> +	if (unlikely(pkt_len !=3D 0))
> +		dev_err(&ap->pdev->dev, "buffer chaining bytes missing %d\n",
> +				pkt_len);
> +
> +	WARN_ON(desc !=3D after);
> +
> +	return merge_skb;
> +}
> +

> +
> +int vmac_start_xmit(struct sk_buff *skb, struct net_device *dev)
> +{
> +	struct vmac_priv *ap =3D netdev_priv(dev);
> +	struct vmac_buffer_desc *desc;
> +	unsigned long flags;
> +	unsigned int tmp;
> +
> +	/* running under xmit lock */
> +	/* locking: modifies tx_ring head, tx_reclaim only tail */
> +
> +	/* no scatter/gatter see features below */
> +	WARN_ON(skb_shinfo(skb)->nr_frags !=3D 0);
> +	WARN_ON(skb->len > MAX_TX_BUFFER_LEN);
> +
> +	if (unlikely(fifo_full(&ap->tx_ring))) {
> +		netif_stop_queue(dev);
> +		vmac_toggle_txint(dev, 1);
> +		dev_err(&ap->pdev->dev, "xmit called with no tx desc available\n")=
;
> +		return NETDEV_TX_BUSY;
> +	}
> +
> +	if (unlikely(skb->len < ETH_ZLEN)) {
> +		struct sk_buff *short_skb;
> +		short_skb =3D netdev_alloc_skb_ip_align(dev, ETH_ZLEN);

I guess you dont really need the _ip_align() version here

> +		if (!short_skb)
> +			return NETDEV_TX_LOCKED;
> +
> +		memset(short_skb->data, 0, ETH_ZLEN);
> +		memcpy(skb_put(short_skb, ETH_ZLEN), skb->data, skb->len);
> +		dev_kfree_skb(skb);
> +		skb =3D short_skb;
> +	}
> +
> +	/* fill descriptor */
> +	ap->tx_skbuff[ap->tx_ring.head] =3D skb;
> +	desc =3D &ap->txbd[ap->tx_ring.head];
> +	WARN_ON(desc->info & cpu_to_le32(BD_DMA_OWN));
> +
> +	desc->data =3D dma_map_single(&ap->pdev->dev, skb->data, skb->len,
> +			DMA_TO_DEVICE);
> +
> +	/* dma might already be polling */
> +	wmb();
> +	desc->info =3D cpu_to_le32(BD_DMA_OWN | BD_FRST | BD_LAST | skb->le=
n);
> +	wmb();

Not sure you need this wmb();

> +
> +	/* lock device data */
> +	spin_lock_irqsave(&ap->lock, flags);
> +
> +	/* kick tx dma */
> +	tmp =3D vmac_readl(ap, STAT);
> +	vmac_writel(ap, tmp | TXPL_MASK, STAT);
> +
> +	dev->stats.tx_packets++;
> +	dev->stats.tx_bytes +=3D skb->len;
> +	dev->trans_start =3D jiffies;

trans_start doesnt need to be set anymore in drivers.

> +	fifo_inc_head(&ap->tx_ring);
> +
> +	/* vmac_tx_reclaim outside of vmac_tx_timeout */
> +	if (fifo_used(&ap->tx_ring) > 8)
> +		vmac_tx_reclaim_unlocked(dev, 0);
> +
> +	/* unlock device data */
> +	spin_unlock_irqrestore(&ap->lock, flags);
> +
> +	/* stop queue if no more desc available */
> +	if (fifo_full(&ap->tx_ring)) {
> +		netif_stop_queue(dev);
> +		vmac_toggle_txint(dev, 1);
> +	}
> +
> +	return NETDEV_TX_OK;
> +}
> +


> +static void create_multicast_filter(struct net_device *dev,
> +	unsigned long *bitmask)
> +{
> +	unsigned long crc;
> +	char *addrs;
> +
> +	/* locking: done by net_device */
> +
> +	WARN_ON(netdev_mc_count(dev) =3D=3D 0);
> +	WARN_ON(dev->flags & IFF_ALLMULTI);
> +
> +	bitmask[0] =3D bitmask[1] =3D 0;
> +
> +	{
> +		struct netdev_hw_addr *ha;
> +		netdev_for_each_mc_addr(ha, dev) {
> +			addrs =3D ha->addr;
> +
> +			/* skip non-multicast addresses */
> +			if (!(*addrs & 1))
> +				continue;
> +
> +			crc =3D ether_crc_le(ETH_ALEN, addrs);
> +			set_bit(crc >> 26, bitmask);

I am wondering if it works on 64bit arches ;)

> +		}
> +	}
> +}
> +

> +static struct ethtool_ops vmac_ethtool_ops =3D {

please add const qualifier

static const struct ethtool_ops vmac_ethtool_ops =3D {


> +	.get_settings		=3D vmacether_get_settings,
> +	.set_settings		=3D vmacether_set_settings,
> +	.get_drvinfo		=3D vmacether_get_drvinfo,
> +	.get_link		=3D ethtool_op_get_link,
> +};
> +

> +static int __devinit vmac_probe(struct platform_device *pdev)
> +{
> +	struct net_device *dev;
> +	struct vmac_priv *ap;
> +	struct resource *mem;
> +	int err;
> +
> +	/* locking: no concurrency */
> +
> +	if (dma_get_mask(&pdev->dev) > DMA_BIT_MASK(32) ||
> +			pdev->dev.coherent_dma_mask > DMA_BIT_MASK(32)) {
> +		dev_err(&pdev->dev, "arcvmac supports only 32-bit DMA addresses\n"=
);
> +		return -ENODEV;
> +	}
> +
> +	dev =3D alloc_etherdev(sizeof(*ap));
> +	if (!dev) {
> +		dev_err(&pdev->dev, "etherdev alloc failed, aborting.\n");
> +		return -ENOMEM;
> +	}
> +
> +	ap =3D netdev_priv(dev);
> +
> +	err =3D -ENODEV;
> +	mem =3D platform_get_resource(pdev, IORESOURCE_MEM, 0);
> +	if (!mem) {
> +		dev_err(&pdev->dev, "no mmio resource defined\n");
> +		goto err_out;
> +	}
> +	ap->mem =3D mem;
> +
> +	err =3D platform_get_irq(pdev, 0);
> +	if (err < 0) {
> +		dev_err(&pdev->dev, "no irq found\n");
> +		goto err_out;
> +	}
> +	dev->irq =3D err;
> +
> +	spin_lock_init(&ap->lock);
> +
> +	SET_NETDEV_DEV(dev, &pdev->dev);
> +	ap->dev =3D dev;
> +	ap->pdev =3D pdev;
> +
> +	/* init rx timeout (used for oom) */
> +	init_timer(&ap->refill_timer);
> +	ap->refill_timer.function =3D vmac_refill_rx_timer;
> +	ap->refill_timer.data =3D (unsigned long)dev;
> +	spin_lock_init(&ap->refill_lock);
> +
> +	netif_napi_add(dev, &ap->napi, vmac_poll, 2);

2 ?

You have 16 skb in RX ring, please use 16 (or 64)

> +	dev->netdev_ops =3D &vmac_netdev_ops;
> +	dev->ethtool_ops =3D &vmac_ethtool_ops;
> +
> +	dev->flags |=3D IFF_MULTICAST;
> +
> +	dev->base_addr =3D (unsigned long)ap->regs; /* TODO */
> +
> +	/* prevent buffer chaining, favor speed over space */
> +	ap->rx_skb_size =3D ETH_FRAME_LEN + VMAC_BUFFER_PAD;
> +
> +	/* private struct functional */
> +
> +	/* temporarily map registers to fetch mac addr */
> +	err =3D get_register_map(ap);
> +	if (err)
> +		goto err_out;
> +
> +	/* mac address intialize, set vmac_open  */
> +	read_mac_reg(dev, dev->dev_addr); /* TODO */
> +
> +	if (!is_valid_ether_addr(dev->dev_addr))
> +		random_ether_addr(dev->dev_addr);
> +
> +	err =3D register_netdev(dev);
> +	if (err) {
> +		dev_err(&pdev->dev, "Cannot register net device, aborting.\n");
> +		goto err_out;
> +	}
> +
> +	/* release the memory region, till open is called */
> +	put_register_map(ap);
> +
> +	dev_info(&pdev->dev, "ARC VMAC at 0x%pP irq %d %pM\n", &mem->start,
> +	    dev->irq, dev->dev_addr);
> +	platform_set_drvdata(pdev, ap);
> +
> +	return 0;
> +
> +err_out:
> +	free_netdev(dev);
> +	return err;
> +}
> +

> diff --git a/drivers/net/arcvmac.h b/drivers/net/arcvmac.h
> new file mode 100644
> index 0000000..ee570a5
> --- /dev/null
> +++ b/drivers/net/arcvmac.h
> @@ -0,0 +1,265 @@
> +/*
> + * ARC VMAC Driver
> + *
> + * Copyright (C) 2003-2006 Codito Technologies, for linux-2.4 port
> + * Copyright (C) 2006-2007 Celunite Inc, for linux-2.6 port
> + * Copyright (C) 2007-2008 Sagem Communications, Fehmi HAFSI
> + * Copyright (C) 2009-2011 Sagem Communications, Andreas Fenkart
> + * All Rights Reserved.
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
> + *
> + * You should have received a copy of the GNU General Public License
> + * along with this program; if not, write to the Free Software
> + * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1=
307  USA
> + *
> + */
> +
> +#ifndef _ARCVMAC_H
> +#define _ARCVMAC_H
> +
> +#define DRV_NAME		"arcvmac"
> +#define DRV_VERSION		"1.0"
> +
> +/* Buffer descriptors */
> +#define TX_BDT_LEN		16    /* Number of receive BD's */

16 is a bit small. Is it a hardware limitation or user choice ?

> +#define RX_BDT_LEN		256   /* Number of transmit BD's */

If hardware permits it, I suggest using 128 RX and 128 TX descs

> +
> +/* BD poll rate, in 1024 cycles. @100Mhz: x * 1024 cy * 10ns =3D 1ms=
 */
> +#define POLLRATE_TIME		200
> +
> +/* next power of two, bigger than ETH_FRAME_LEN + VLAN  */
> +#define MAX_RX_BUFFER_LEN	0x800	/* 2^11 =3D 2048 =3D 0x800 */
> +#define MAX_TX_BUFFER_LEN	0x800	/* 2^11 =3D 2048 =3D 0x800 */
> +
> +/* 14 bytes of ethernet header, 4 bytes VLAN, FCS,
> + * plus extra pad to prevent buffer chaining of
> + * maximum sized ethernet packets (1514 bytes) */
> +#define	VMAC_BUFFER_PAD		(ETH_HLEN + 4 + ETH_FCS_LEN + 4)
> +
> +/* VMAC register definitions, offsets in bytes */
> +#define VMAC_ID			0x00
> +
> +/* stat/enable use same bit mask */
> +#define VMAC_STAT		0x04
> +#define VMAC_ENABLE		0x08
> +#  define TXINT_MASK		0x00000001 /* Transmit interrupt */
> +#  define RXINT_MASK		0x00000002 /* Receive interrupt */
> +#  define ERR_MASK		0x00000004 /* Error interrupt */
> +#  define TXCH_MASK		0x00000008 /* Transmit chaining error */
> +#  define MSER_MASK		0x00000010 /* Missed packet counter error */
> +#  define RXCR_MASK		0x00000100 /* RXCRCERR counter rolled over	 */
> +#  define RXFR_MASK		0x00000200 /* RXFRAMEERR counter rolled over */
> +#  define RXFL_MASK		0x00000400 /* RXOFLOWERR counter rolled over */
> +#  define MDIO_MASK		0x00001000 /* MDIO complete */
> +#  define TXPL_MASK		0x80000000 /* TXPOLL */
> +
> +#define VMAC_CONTROL		0x0c
> +#  define EN_MASK		0x00000001 /* VMAC enable */
> +#  define TXRN_MASK		0x00000008 /* TX enable */
> +#  define RXRN_MASK		0x00000010 /* RX enable */
> +#  define DSBC_MASK		0x00000100 /* Disable receive broadcast */
> +#  define ENFL_MASK		0x00000400 /* Enable Full Duplex */
> +#  define PROM_MASK		0x00000800 /* Promiscuous mode */
> +
> +#define VMAC_POLLRATE		0x10
> +
> +#define VMAC_RXERR		0x14
> +#  define RXERR_CRC		0x000000ff
> +#  define RXERR_FRM		0x0000ff00
> +#  define RXERR_OFLO		0x00ff0000 /* fifo overflow */
> +
> +#define VMAC_MISS		0x18
> +#define VMAC_TXRINGPTR		0x1c
> +#define VMAC_RXRINGPTR		0x20
> +#define VMAC_ADDRL		0x24
> +#define VMAC_ADDRH		0x28
> +#define VMAC_LAFL		0x2c
> +#define VMAC_LAFH		0x30
> +#define VMAC_MAC_TXRING_HEAD	0x38
> +#define VMAC_MAC_RXRING_HEAD	0x3C
> +
> +#define VMAC_MDIO_DATA		0x34
> +#  define MDIO_SFD		0xC0000000
> +#  define MDIO_OP		0x30000000
> +#  define MDIO_ID_MASK		0x0F800000
> +#  define MDIO_REG_MASK		0x007C0000
> +#  define MDIO_TA		0x00030000
> +#  define MDIO_DATA_MASK	0x0000FFFF
> +/* common combinations */
> +#  define MDIO_BASE		0x40020000
> +#  define MDIO_OP_READ		0x20000000
> +#  define MDIO_OP_WRITE		0x10000000
> +
> +/* Buffer descriptor INFO bit masks */
> +#define BD_DMA_OWN		0x80000000 /* buffer ownership, 0 CPU, 1 DMA */
> +#define BD_BUFF			0x40000000 /* buffer invalid, rx */
> +#define BD_UFLO			0x20000000 /* underflow, tx */
> +#define BD_LTCL			0x10000000 /* late collision, tx  */
> +#define BD_RETRY_CT		0x0f000000 /* tx */
> +#define BD_DROP			0x00800000 /* drop, more than 16 retries, tx */
> +#define BD_DEFER		0x00400000 /* traffic on the wire, tx */
> +#define BD_CARLOSS		0x00200000 /* carrier loss while transmission, t=
x, rx? */
> +/* 20:19 reserved */
> +#define BD_ADCR			0x00040000 /* add crc, ignored if not disaddcrc */
> +#define BD_LAST			0x00020000 /* Last buffer in chain */
> +#define BD_FRST			0x00010000 /* First buffer in chain */
> +/* 15:11 reserved */
> +#define BD_LEN			0x000007FF
> +
> +/* common combinations */
> +#define BD_TX_ERR		(BD_UFLO | BD_LTCL | BD_RETRY_CT | BD_DROP | \
> +		BD_DEFER | BD_CARLOSS)
> +
> +
> +/* arcvmac private data structures */
> +struct vmac_buffer_desc {
> +	__le32 info;
> +	__le32 data;
> +};
> +
> +struct dma_fifo {
> +	int head; /* head */
> +	int tail; /* tail */
> +	int size;
> +};
> +
> +struct	vmac_priv {
> +	struct net_device *dev;
> +	struct platform_device *pdev;
> +
> +	struct completion mdio_complete;
> +	spinlock_t lock; /* protects structure plus hw regs of device */
> +
> +	/* base address of register set */
> +	char *regs;
> +	struct resource *mem;
> +
> +	/* DMA ring buffers */
> +	struct vmac_buffer_desc *rxbd;
> +	dma_addr_t rxbd_dma;
> +
> +	struct vmac_buffer_desc *txbd;
> +	dma_addr_t txbd_dma;
> +
> +	/* socket buffers */
> +	struct sk_buff *rx_skbuff[RX_BDT_LEN];
> +	struct sk_buff *tx_skbuff[TX_BDT_LEN];
> +	int rx_skb_size;
> +
> +	/* skb / dma desc managing */
> +	struct dma_fifo rx_ring; /* valid rx buffers */
> +	struct dma_fifo tx_ring;
> +
> +	/* descriptor last polled/processed by the VMAC */
> +	unsigned long dma_rx_head;
> +
> +	/* timer to retry rx skb allocation, if failed during receive */
> +	struct timer_list refill_timer;
> +	spinlock_t refill_lock;
> +
> +	struct napi_struct napi;
> +
> +	/* rx buffer chaining */
> +	int rx_merge_error;
> +	int tx_timeout_error;
> +
> +	/* PHY stuff */
> +	struct mii_bus *mii_bus;
> +	struct phy_device *phy_dev;
> +
> +	int link;
> +	int speed;
> +	int duplex;
> +
> +	/* debug */
> +	int shutdown;
> +};
> +
> +/* DMA ring management */
> +
> +/* for a fifo with size n,
> + * - [0..n] fill levels are n + 1 states
> + * - there are only n different deltas (head - tail) values
> + * =3D> not all fill levels can be represented with head, tail
> + *    pointers only
> + * we give up the n fill level, aka fifo full */
> +
> +/* sacrifice one elt as a sentinel */
> +static inline int fifo_used(struct dma_fifo *f);
> +static inline int fifo_inc_ct(int ct, int size);
> +static inline void fifo_dump(struct dma_fifo *fifo);
> +
> +static inline int fifo_empty(struct dma_fifo *f)
> +{
> +	return (f->head =3D=3D f->tail);

return f->head =3D=3D f->tail;

> +}
> +
> +static inline int fifo_free(struct dma_fifo *f)
> +{
> +	int free;
> +
> +	free =3D f->tail - f->head;
> +	if (free <=3D 0)
> +		free +=3D f->size;
> +
> +	return free;
> +}
> +
> +static inline int fifo_used(struct dma_fifo *f)
> +{
> +	int used;
> +
> +	used =3D f->head - f->tail;
> +	if (used < 0)
> +		used +=3D f->size;
> +
> +	return used;
> +}
> +
> +static inline int fifo_full(struct dma_fifo *f)
> +{
> +	return (fifo_used(f) + 1) =3D=3D f->size;
> +}
> +
> +/* manipulate */
> +static inline void fifo_init(struct dma_fifo *fifo, int size)
> +{
> +	fifo->size =3D size;
> +	fifo->head =3D fifo->tail =3D 0; /* empty */
> +}
> +
> +static inline void fifo_inc_head(struct dma_fifo *fifo)
> +{
> +	BUG_ON(fifo_full(fifo));
> +	fifo->head =3D fifo_inc_ct(fifo->head, fifo->size);
> +}
> +
> +static inline void fifo_inc_tail(struct dma_fifo *fifo)
> +{
> +	BUG_ON(fifo_empty(fifo));
> +	fifo->tail =3D fifo_inc_ct(fifo->tail, fifo->size);
> +}
> +
> +/* internal funcs */
> +static inline void fifo_dump(struct dma_fifo *fifo)
> +{
> +	printk(KERN_INFO "fifo: head %d, tail %d, size %d\n", fifo->head,
> +			fifo->tail,
> +			fifo->size);

	pr_info() is preferred in new code
> +}
> +
> +static inline int fifo_inc_ct(int ct, int size)
> +{
> +	return (++ct =3D=3D size) ? 0 : ct;
> +}
> +
> +#endif	  /* _ARCVMAC_H */


