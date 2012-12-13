From: Joe Perches <joe@perches.com>
Subject: Re: [RFC][PATCH] bgmac: driver for GBit MAC core on BCMA bus
Date: Thu, 13 Dec 2012 10:46:13 -0800
Message-ID: <1355424373.13796.25.camel@joe-AO722>
References: <1355420611-25764-1-git-send-email-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: =?UTF-8?Q?Rafa=C5=82_Mi=C5=82ecki?= <zajec5@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:54941 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754006Ab2LMSqP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Dec 2012 13:46:15 -0500
In-Reply-To: <1355420611-25764-1-git-send-email-zajec5@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-12-13 at 18:43 +0100, Rafa=C5=82 Mi=C5=82ecki wrote:
> BCMA is a Broadcom specific bus with devices AKA cores. All recent BC=
MA
> based SoCs have gigabit ethernet provided by the GBit MAC core. This
> patch adds driver for such a cores registering itself as a netdev. It
> has been tested on a BCM4706 and BCM4718 chipsets.
[]
> It's just a RFC, so be aware of two ugly parts in this version:

Just some trivial notes.  Feel free to ignore.

> diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/ethe=
rnet/broadcom/bgmac.c

[]

> +#define pr_fmt(fmt)		KBUILD_MODNAME ": " fmt
> +
> +#define bgmac_err(bgmac, fmt, ...) \
> +	pr_err("u%d: " fmt, (bgmac)->core->core_unit, ##__VA_ARGS__)
> +#define bgmac_warn(bgmac, fmt, ...) \
> +	pr_warn("u%d: " fmt, (bgmac)->core->core_unit, ##__VA_ARGS__)
> +#define bgmac_info(bgmac, fmt, ...) \
> +	pr_info("u%d: " fmt, (bgmac)->core->core_unit, ##__VA_ARGS__)
> +#define bgmac_debug(bgmac, fmt, ...) \
> +	pr_debug("u%d: " fmt, (bgmac)->core->core_unit, ##__VA_ARGS__)

Most subsystems use prefix_dbg now instead of prefix_debug.
Why not change these from pr_<level> to dev_<level>?
Maybe these should be in the bgmac.h file.

> +static bool bgmac_wait_value(struct bcma_device *core, u16 reg, u32 =
mask,
> +			     u32 value, int timeout)
> +{
[]
> +	pr_err("Timeout waiting for reg 0x%X\n", reg);

Maybe add new bmca_dev_(err|warn|info|dbg) macros too?

> +/* http://bcm-v4.sipsolutions.net/mac-gbit/gmac/chipphyinit */
> +static void bgmac_phy_init(struct bgmac *bgmac)
> +{
> +	struct bcma_chipinfo *ci =3D &bgmac->core->bus->chipinfo;
> +	struct bcma_drv_cc *cc =3D &bgmac->core->bus->drv_cc;
> +	u8 i;
> +
> +	if (ci->id =3D=3D BCMA_CHIP_ID_BCM5356) {
> +		for (i =3D 0; i < 5; i++) {
> +			bgmac_phy_write(bgmac, i, 0x1f, 0x008b);
> +			bgmac_phy_write(bgmac, i, 0x15, 0x0100);
> +			bgmac_phy_write(bgmac, i, 0x1f, 0x000f);
> +			bgmac_phy_write(bgmac, i, 0x12, 0x2aaa);
> +			bgmac_phy_write(bgmac, i, 0x1f, 0x000b);
> +		}
> +	}
> +	if ((ci->id =3D=3D BCMA_CHIP_ID_BCM5357 && ci->pkg !=3D 10) ||
> +	    (ci->id =3D=3D BCMA_CHIP_ID_BCM4749 && ci->pkg !=3D 10) ||
> +	    (ci->id =3D=3D BCMA_CHIP_ID_BCM53572 && ci->pkg !=3D 9)) {
> +		bcma_chipco_chipctl_maskset(cc, 2, ~0xc0000000, 0);
> +		bcma_chipco_chipctl_maskset(cc, 4, ~0x80000000, 0);
> +		for (i =3D 0; i < 5; i++) {
> +			bgmac_phy_write(bgmac, i, 0x1f, 0x000f);
> +			bgmac_phy_write(bgmac, i, 0x16, 0x5284);
> +			bgmac_phy_write(bgmac, i, 0x1f, 0x000b);
> +			bgmac_phy_write(bgmac, i, 0x17, 0x0010);
> +			bgmac_phy_write(bgmac, i, 0x1f, 0x000f);
> +			bgmac_phy_write(bgmac, i, 0x16, 0x5296);
> +			bgmac_phy_write(bgmac, i, 0x17, 0x1073);
> +			bgmac_phy_write(bgmac, i, 0x17, 0x9073);
> +			bgmac_phy_write(bgmac, i, 0x16, 0x52b6);
> +			bgmac_phy_write(bgmac, i, 0x17, 0x9273);
> +			bgmac_phy_write(bgmac, i, 0x1f, 0x000b);

That's a lot of magic numbers.

> +static void bgmac_chip_stats_update(struct bgmac *bgmac)
> +{
> +	int i;
> +
> +	if (bgmac->core->id.id !=3D BCMA_CORE_4706_MAC_GBIT) {

Save an indent level by returning a call to
a new bgmac_4706_chip_stats_update instead?

	if (bgmac->core->id.id =3D=3D BCMA_CORE_4706_MAC_GBIT)
		return bgmac_407_chip_stats_update(bgmac);

> +		for (i =3D 0; i < BGMAC_NUM_MIB_TX_REGS; i++)
> +			bgmac->mib_tx_regs[i] =3D
> +				bgmac_read(bgmac,
> +					   BGMAC_TX_GOOD_OCTETS + (i * 4));
> +		for (i =3D 0; i < BGMAC_NUM_MIB_RX_REGS; i++)
> +			bgmac->mib_rx_regs[i] =3D
> +				bgmac_read(bgmac,
> +					   BGMAC_RX_GOOD_OCTETS + (i * 4));
> +	}

unindent

> +
> +	/* TODO: what else? how to handle BCM4706? */

and delete?

> +}
> +
> +static void bgmac_clear_mib(struct bgmac *bgmac)
> +{
> +	int i;
> +
> +	if (bgmac->core->id.id =3D=3D BCMA_CORE_4706_MAC_GBIT)
> +		return;

Something like what this function does.

[]

> diff --git a/drivers/net/ethernet/broadcom/bgmac.h b/drivers/net/ethe=
rnet/broadcom/bgmac.h

[]

> +struct bgmac {
> +	struct bcma_device *core;
> +	struct bcma_device *cmn; /* Reference to CMN core for BCM4706 */
> +	struct net_device *net_dev;
> +	struct napi_struct napi;
> +
> +	u8 phyaddr;
> +	bool has_robosw;
> +
> +	u32 int_mask;
> +	u32 int_status;
> +
> +	bool loopback;
> +
> +	bool autoneg;
> +	bool full_duplex;
> +	int speed;
> +
> +	/* DMA */
> +	struct bgmac_dma_ring tx_ring[BGMAC_MAX_TX_RINGS];
> +	struct bgmac_dma_ring rx_ring[BGMAC_MAX_RX_RINGS];
> +
> +	/* Stats */
> +	bool stats_grabbed;
> +	u32 mib_tx_regs[BGMAC_NUM_MIB_TX_REGS];
> +	u32 mib_rx_regs[BGMAC_NUM_MIB_RX_REGS];
> +};

Maybe some minor reordering of the u8/bools to reduce padding.
