From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] bgmac: driver for GBit MAC core on BCMA bus
Date: Thu, 27 Dec 2012 00:17:21 +0100
Message-ID: <20121226231721.GA8243@electric-eye.fr.zoreil.com>
References: <1356363222-16672-1-git-send-email-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: =?utf-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:58426 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751434Ab2LZXoN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Dec 2012 18:44:13 -0500
Content-Disposition: inline
In-Reply-To: <1356363222-16672-1-git-send-email-zajec5@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com> :
[...]
> diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/ethe=
rnet/broadcom/bgmac.c
[...]
> +static void bgmac_dma_tx_reset(struct bgmac *bgmac, struct bgmac_dma=
_ring *ring)
> +{
> +	u32 val;
> +	int i;
> +
> +	if (!ring->mmio_base)
> +		return;

static int bgmac_probe(struct bcma_device *core)
[...]
	bgmac_chip_reset(bgmac);

	err =3D bgmac_dma_alloc(bgmac);

mmio_base is only set in bgmac_dma_alloc.

-> remove the useless bgmac_chip_reset() in bgmac_probe() and the drive=
r
won't need to test for !ring->mmio_base.

> +
> +	/* Susend DMA TX ring first.

	/* Suspend DMA TX ring first.

[...]
> +static netdev_tx_t bgmac_dma_tx_add(struct bgmac *bgmac,
> +				    struct bgmac_dma_ring *ring,
> +				    struct sk_buff *skb)
> +{
> +	struct device *dma_dev =3D bgmac->core->dma_dev;
> +	struct bgmac_dma_desc *dma_desc;
> +	struct bgmac_slot_info *slot;
> +	u32 ctl0, ctl1;
> +	int free_slots;
> +
> +	if (skb->len > BGMAC_DESC_CTL1_LEN) {
> +		bgmac_err(bgmac, "Too long skb (%d)\n", skb->len);
> +		return NETDEV_TX_BUSY;
> +	}

The driver will loop if you don't stop queuing. It won't help.

> +
> +	if (ring->start <=3D ring->end)
> +		free_slots =3D ring->start - ring->end + BGMAC_TX_RING_SLOTS;
> +	else
> +		free_slots =3D ring->start - ring->end;
> +	if (free_slots <=3D 1) {
> +		bgmac_err(bgmac, "No free slots on ring 0x%X!\n", ring->mmio_base)=
;
> +		netif_stop_queue(bgmac->net_dev);
> +		return NETDEV_TX_BUSY;
> +	}

The driver should stop queueing after its processing if it detects that
it can't handle more requests.

> +
> +	slot =3D &ring->slots[ring->end];
> +	slot->skb =3D skb;
> +	slot->dma_addr =3D dma_map_single(dma_dev, skb->data, skb->len, DMA=
_TO_DEVICE);
> +	if (dma_mapping_error(dma_dev, slot->dma_addr)) {
> +		bgmac_err(bgmac, "Mapping error of skb on ring 0x%X\n", ring->mmio=
_base);
> +		return NETDEV_TX_BUSY;
> +	}

Why don't you drop the packet and return TX_OK ?

> +
> +	ctl0 =3D BGMAC_DESC_CTL0_IOC | BGMAC_DESC_CTL0_SOF | BGMAC_DESC_CTL=
0_EOF;
> +	if (ring->end =3D=3D ring->num_slots - 1)
> +		ctl0 |=3D BGMAC_DESC_CTL0_EOT;
> +	ctl1 =3D skb->len & BGMAC_DESC_CTL1_LEN;
> +
> +	dma_desc =3D ring->cpu_base;
> +	dma_desc +=3D ring->end;

	struct bgmac_dma_desc *dma_desc =3D ring->cpu_base + ring->end;

> +	dma_desc->addr_low =3D cpu_to_le32(lower_32_bits(slot->dma_addr));
> +	dma_desc->addr_high =3D cpu_to_le32(upper_32_bits(slot->dma_addr));
> +	dma_desc->ctl0 =3D cpu_to_le32(ctl0);
> +	dma_desc->ctl1 =3D cpu_to_le32(ctl1);
> +
> +	wmb();

Are we sure that the hardware will never read a descriptor where ctl0 i=
s
set and ctl1 is not (start_xmit, dma starts, competing start_xmit, oops=
) ?

> +
> +	/* Increase ring->end to point empty slot. We tell hardware the fir=
st
> +	 * slot it shold *not* read.

	 * slot it should *not* read.

[...]
> +static void bgmac_dma_tx_free(struct bgmac *bgmac, struct bgmac_dma_=
ring *ring)
> +{
> +	struct device *dma_dev =3D bgmac->core->dma_dev;
> +	struct bgmac_dma_desc *dma_desc;

The scope of 'slot' and 'dma_desc' can be reduced.

> +	struct bgmac_slot_info *slot;
> +	int empty_slot;
> +
> +	/* The last slot that hardware didn't consume yet */
> +	empty_slot =3D bgmac_read(bgmac, ring->mmio_base + BGMAC_DMA_TX_STA=
TUS);
> +	empty_slot &=3D BGMAC_DMA_TX_STATDPTR;
> +	empty_slot /=3D sizeof(struct bgmac_dma_desc);
> +
> +	while (ring->start !=3D empty_slot) {
> +		/* Set pointers */
> +		dma_desc =3D ring->cpu_base;
> +		dma_desc +=3D ring->start;
> +		slot =3D &ring->slots[ring->start];
> +
> +		if (slot->skb) {
> +			/* Unmap no longer used buffer */
> +			dma_unmap_single(dma_dev, slot->dma_addr,
> +					 slot->skb->len, DMA_TO_DEVICE);
> +			slot->dma_addr =3D 0;
> +
> +			/* Free memory! :) */
> +			dev_kfree_skb_any(slot->skb);

This is irq enabled NAPI poll context so you can dev_kfree_skb.

> +			slot->skb =3D NULL;
> +		} else {
> +			bgmac_err(bgmac, "Hardware reported transmission for empty TX rin=
g slot %d! End of ring: %d", ring->start, ring->end);
> +		}
> +
> +		if (++ring->start >=3D BGMAC_TX_RING_SLOTS)
> +			ring->start =3D 0;
> +	}
> +}
> +
> +static void bgmac_dma_rx_reset(struct bgmac *bgmac, struct bgmac_dma=
_ring *ring)
> +{
> +	if (!ring->mmio_base)
> +		return;

See remark about bgmac_dma_tx_reset.

[...]
> +static int bgmac_dma_rx_read(struct bgmac *bgmac, struct bgmac_dma_r=
ing *ring,
> +			     int weight)
> +{
> +	struct device *dma_dev =3D bgmac->core->dma_dev;
> +	struct bgmac_dma_desc *dma_desc;
> +	struct bgmac_slot_info *slot;
> +	struct sk_buff *skb, *new_skb;
> +	struct bgmac_rx_header *rx;
> +	u32 end_slot;
> +	u16 len, flags;
> +	int handled =3D 0;

The scope of several variables can be reduced as well.

--=20
Ueimor
