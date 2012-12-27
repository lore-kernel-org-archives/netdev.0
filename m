From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] bgmac: driver for GBit MAC core on BCMA bus
Date: Thu, 27 Dec 2012 23:03:44 +0100
Message-ID: <20121227220344.GA20409@electric-eye.fr.zoreil.com>
References: <1356363222-16672-1-git-send-email-zajec5@gmail.com> <20121226231721.GA8243@electric-eye.fr.zoreil.com> <CACna6rydhYcBZnRpz2PD5S=UfjQJ5xqkY=_+Y9BeOt-ENQqc3w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: =?utf-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:59617 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751417Ab2L0Wak (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Dec 2012 17:30:40 -0500
Content-Disposition: inline
In-Reply-To: <CACna6rydhYcBZnRpz2PD5S=UfjQJ5xqkY=_+Y9BeOt-ENQqc3w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com> :
[...]
> I'm not 100% sure if I understand... Do you mean I should declare var=
iables
> inside "while" loop when possible ?

Yes. Please consider the deepest inner block.

While at it:

> diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/ethe=
rnet/broadcom/bgmac.c
[...]
> +static int bgmac_dma_rx_read(struct bgmac *bgmac, struct bgmac_dma_r=
ing *ring,
[...]
> +		/* Check for poison and drop or pass the packet */
> +		if (len =3D=3D 0xdead && flags =3D=3D 0xbeef) {
> +			bgmac_err(bgmac, "Found poisoned packet at slot %d, DMA issue!\n"=
, ring->start);
> +		} else {
> +			new_skb =3D netdev_alloc_skb(bgmac->net_dev, len);
> +			if (new_skb) {
> +				skb_put(new_skb, len);
> +				skb_copy_from_linear_data_offset(skb, BGMAC_RX_FRAME_OFFSET,
> +								 new_skb->data, len);
> +				new_skb->protocol =3D
> +					eth_type_trans(new_skb, bgmac->net_dev);
> +				netif_receive_skb(new_skb);
> +				handled++;
> +			} else {
> +				bgmac_err(bgmac, "Allocation of skb for copying packet failed!\n=
");
> +			}

You should increase bgmac->net_dev->stats.rx_dropped

[...]
> +static int bgmac_dma_alloc(struct bgmac *bgmac)
> +{
> +	struct device *dma_dev =3D bgmac->core->dma_dev;
> +	struct bgmac_dma_ring *ring;
> +	u16 ring_base[] =3D { BGMAC_DMA_BASE0, BGMAC_DMA_BASE1, BGMAC_DMA_B=
ASE2,
> +			    BGMAC_DMA_BASE3, };

ring_base could be 'static const'.

> +	int size; /* ring size: different for Tx and Rx */
> +	int err;
> +	int i;
> +
> +	BUILD_BUG_ON(BGMAC_MAX_TX_RINGS > ARRAY_SIZE(ring_base));
> +	BUILD_BUG_ON(BGMAC_MAX_RX_RINGS > ARRAY_SIZE(ring_base));
> +
> +	if (!(bcma_aread32(bgmac->core, BCMA_IOST) & BCMA_IOST_DMA64)) {
> +		bgmac_err(bgmac, "Core does not report 64-bit DMA\n");
> +		return -ENOTSUPP;
> +	}
> +
> +	for (i =3D 0; i < BGMAC_MAX_TX_RINGS; i++) {
> +		ring =3D &bgmac->tx_ring[i];
> +		ring->tx =3D true;
> +		ring->num_slots =3D BGMAC_TX_RING_SLOTS;
> +		ring->mmio_base =3D ring_base[i];
> +		if (bgmac_dma_unaligned(bgmac, ring))
> +			bgmac_warn(bgmac, "TX on ring 0x%X supports unaligned addressing =
but this feature is not implemented\n", ring->mmio_base);

ring->tx is used once in bgmac_dma_unaligned.

Add bgmac_dma_unaligned an extra parameter for the BGMAC_DMA_[RT]X_RING=
LO
offset and ring->[rt]x can go away.

> +
> +		/* Alloc ring of descriptors */
> +		size =3D ring->num_slots * sizeof(struct bgmac_dma_desc);
> +		ring->cpu_base =3D dma_zalloc_coherent(dma_dev, size,
> +						     &(ring->dma_base),

Plese remove the useless parenthesis.

[...]
> +static void bgmac_chip_stats_update(struct bgmac *bgmac)
> +{
> +	int i;
> +
> +	if (bgmac->core->id.id !=3D BCMA_CORE_4706_MAC_GBIT) {
> +		for (i =3D 0; i < BGMAC_NUM_MIB_TX_REGS; i++)
> +			bgmac->mib_tx_regs[i] =3D
> +				bgmac_read(bgmac,
> +					   BGMAC_TX_GOOD_OCTETS + (i * 4));
> +		for (i =3D 0; i < BGMAC_NUM_MIB_RX_REGS; i++)
> +			bgmac->mib_rx_regs[i] =3D
> +				bgmac_read(bgmac,
> +					   BGMAC_RX_GOOD_OCTETS + (i * 4));
> +	}

Neither of mib_[rt]x_regs is ever read.

[...]
> +static void bgmac_chip_reset(struct bgmac *bgmac)
> +{
[...]
> +	if (ci->id =3D=3D BCMA_CHIP_ID_BCM5357 || ci->id =3D=3D BCMA_CHIP_I=
D_BCM4749 ||
> +	    ci->id =3D=3D BCMA_CHIP_ID_BCM53572) {
> +		struct bcma_drv_cc *cc =3D &bgmac->core->bus->drv_cc;
> +		u8 et_swtype =3D 0;
> +		u8 sw_type =3D BGMAC_CHIPCTL_1_SW_TYPE_EPHY |
> +			     BGMAC_CHIPCTL_1_IF_TYPE_RMII;
> +		char buf[2];
> +		if (nvram_getenv("et_swtype", buf, 1) > 0) {

Please keep an empty line between variables declaration and body.

[...]
> +static irqreturn_t bgmac_interrupt(int irq, void *dev_id)
> +{
> +	struct bgmac *bgmac =3D netdev_priv(dev_id);
> +
> +	u32 int_status =3D bgmac_read(bgmac, BGMAC_INT_STATUS);
> +	int_status &=3D bgmac->int_mask;

=2E..


[...]
> +/**************************************************
> + * net_device_ops
> + **************************************************/
> +
> +static int bgmac_open(struct net_device *net_dev)
> +{
> +	struct bgmac *bgmac =3D netdev_priv(net_dev);
> +
> +	/* Reset */
> +	bgmac_chip_reset(bgmac);

Please remove the useless comment(s).

> +	/* Specs say about reclaiming rings here, but we do that in DMA ini=
t */
> +	bgmac_chip_init(bgmac, true);
> +
> +	/* Enable IRQs */
> +	if (request_irq(bgmac->core->irq, bgmac_interrupt, IRQF_SHARED,
> +			KBUILD_MODNAME, net_dev) < 0)
> +		bgmac_err(bgmac, "IRQ request error!\n");
> +	napi_enable(&bgmac->napi);
> +
> +	return 0;

bgmac_open should not succeed when request_irq fails. Please propagate =
its
error status code.

[...]
> +static int bgmac_get_settings(struct net_device *net_dev,
> +			      struct ethtool_cmd *cmd)
> +{
> +	struct bgmac *bgmac =3D netdev_priv(net_dev);
> +
> +	cmd->supported =3D SUPPORTED_10baseT_Half |
> +			 SUPPORTED_10baseT_Full |
> +			 SUPPORTED_100baseT_Half |
> +			 SUPPORTED_100baseT_Full |
> +			 SUPPORTED_1000baseT_Half |
> +			 SUPPORTED_1000baseT_Full |
> +			 SUPPORTED_Autoneg;
> +
> +	if (bgmac->autoneg) {
> +		WARN_ON(cmd->advertising);
> +		if (bgmac->full_duplex) {
> +			if (bgmac->speed & BGMAC_SPEED_10)
> +				cmd->advertising |=3D ADVERTISED_10baseT_Full;
> +			if (bgmac->speed & BGMAC_SPEED_100)
> +				cmd->advertising |=3D ADVERTISED_100baseT_Full;
> +			if (bgmac->speed & BGMAC_SPEED_1000)
> +				cmd->advertising |=3D ADVERTISED_1000baseT_Full;
> +		} else {
> +			if (bgmac->speed & BGMAC_SPEED_10)
> +				cmd->advertising |=3D ADVERTISED_10baseT_Half;
> +			if (bgmac->speed & BGMAC_SPEED_100)
> +				cmd->advertising |=3D ADVERTISED_100baseT_Half;
> +			if (bgmac->speed & BGMAC_SPEED_1000)
> +				cmd->advertising |=3D ADVERTISED_1000baseT_Half;
> +		}
> +	} else {
> +		switch (bgmac->speed) {
> +		case BGMAC_SPEED_10:
> +			ethtool_cmd_speed_set(cmd, SPEED_10);
> +			break;
> +		case BGMAC_SPEED_100:
> +			ethtool_cmd_speed_set(cmd, SPEED_100);
> +			break;
> +		case BGMAC_SPEED_1000:
> +			ethtool_cmd_speed_set(cmd, SPEED_1000);
> +			break;
> +		}
> +	}

It should not take long for users to complain that the driver does not
report the current link speed. A struct mii_if_info will ease your life=
=2E

Btw the driver does not manage the link (netif_carrier_{on/off}).

[...]
> diff --git a/drivers/net/ethernet/broadcom/bgmac.h b/drivers/net/ethe=
rnet/broadcom/bgmac.h
[...]
> +struct bgmac_dma_ring {
> +	bool tx;
> +	u16 num_slots;
> +	u16 start;
> +	u16 end;
> +
> +	u16 mmio_base;
> +	void *cpu_base;

	struct bgmac_dma_desc *cpu_base; ?


--=20
Ueimor
