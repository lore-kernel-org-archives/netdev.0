From: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Subject: Re: [RFC][PATCH] bgmac: driver for GBit MAC core on BCMA bus
Date: Thu, 13 Dec 2012 20:24:08 +0100
Message-ID: <CACna6rwJZpjdyWjkdoLrcyo3+Pq8CCk4x1N5GS+n8P5prBVm2A@mail.gmail.com>
References: <1355420611-25764-1-git-send-email-zajec5@gmail.com>
	<1355424373.13796.25.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f180.google.com ([209.85.212.180]:46338 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755901Ab2LMTYK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Dec 2012 14:24:10 -0500
Received: by mail-wi0-f180.google.com with SMTP id hj13so1966719wib.1
        for <netdev@vger.kernel.org>; Thu, 13 Dec 2012 11:24:08 -0800 (PST)
In-Reply-To: <1355424373.13796.25.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2012/12/13 Joe Perches <joe@perches.com>:
> On Thu, 2012-12-13 at 18:43 +0100, Rafa=C5=82 Mi=C5=82ecki wrote:
>> BCMA is a Broadcom specific bus with devices AKA cores. All recent B=
CMA
>> based SoCs have gigabit ethernet provided by the GBit MAC core. This
>> patch adds driver for such a cores registering itself as a netdev. I=
t
>> has been tested on a BCM4706 and BCM4718 chipsets.
> []
>> It's just a RFC, so be aware of two ugly parts in this version:
>
> Just some trivial notes.  Feel free to ignore.

Thanks :) I can always try to discuss some points, but I appreciate
every review!


>> diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/eth=
ernet/broadcom/bgmac.c
>
> []
>
>> +#define pr_fmt(fmt)          KBUILD_MODNAME ": " fmt
>> +
>> +#define bgmac_err(bgmac, fmt, ...) \
>> +     pr_err("u%d: " fmt, (bgmac)->core->core_unit, ##__VA_ARGS__)
>> +#define bgmac_warn(bgmac, fmt, ...) \
>> +     pr_warn("u%d: " fmt, (bgmac)->core->core_unit, ##__VA_ARGS__)
>> +#define bgmac_info(bgmac, fmt, ...) \
>> +     pr_info("u%d: " fmt, (bgmac)->core->core_unit, ##__VA_ARGS__)
>> +#define bgmac_debug(bgmac, fmt, ...) \
>> +     pr_debug("u%d: " fmt, (bgmac)->core->core_unit, ##__VA_ARGS__)
>
> Most subsystems use prefix_dbg now instead of prefix_debug.

Thanks, I didn't know about that. Seeing "pr_debug" suggested I also
should use *_debug.


> Why not change these from pr_<level> to dev_<level>?

One more thing I didn't know/think about (dev_*).


> Maybe these should be in the bgmac.h file.

OK.


>> +static bool bgmac_wait_value(struct bcma_device *core, u16 reg, u32=
 mask,
>> +                          u32 value, int timeout)
>> +{
> []
>> +     pr_err("Timeout waiting for reg 0x%X\n", reg);
>
> Maybe add new bmca_dev_(err|warn|info|dbg) macros too?

It's the only place where we are working on a specific coreunit, but I
didn't bother to print that. Was too lazy to add special code for this
single case, ups ;)


>> +/* http://bcm-v4.sipsolutions.net/mac-gbit/gmac/chipphyinit */
>> +static void bgmac_phy_init(struct bgmac *bgmac)
>> +{
>> +     struct bcma_chipinfo *ci =3D &bgmac->core->bus->chipinfo;
>> +     struct bcma_drv_cc *cc =3D &bgmac->core->bus->drv_cc;
>> +     u8 i;
>> +
>> +     if (ci->id =3D=3D BCMA_CHIP_ID_BCM5356) {
>> +             for (i =3D 0; i < 5; i++) {
>> +                     bgmac_phy_write(bgmac, i, 0x1f, 0x008b);
>> +                     bgmac_phy_write(bgmac, i, 0x15, 0x0100);
>> +                     bgmac_phy_write(bgmac, i, 0x1f, 0x000f);
>> +                     bgmac_phy_write(bgmac, i, 0x12, 0x2aaa);
>> +                     bgmac_phy_write(bgmac, i, 0x1f, 0x000b);
>> +             }
>> +     }
>> +     if ((ci->id =3D=3D BCMA_CHIP_ID_BCM5357 && ci->pkg !=3D 10) ||
>> +         (ci->id =3D=3D BCMA_CHIP_ID_BCM4749 && ci->pkg !=3D 10) ||
>> +         (ci->id =3D=3D BCMA_CHIP_ID_BCM53572 && ci->pkg !=3D 9)) {
>> +             bcma_chipco_chipctl_maskset(cc, 2, ~0xc0000000, 0);
>> +             bcma_chipco_chipctl_maskset(cc, 4, ~0x80000000, 0);
>> +             for (i =3D 0; i < 5; i++) {
>> +                     bgmac_phy_write(bgmac, i, 0x1f, 0x000f);
>> +                     bgmac_phy_write(bgmac, i, 0x16, 0x5284);
>> +                     bgmac_phy_write(bgmac, i, 0x1f, 0x000b);
>> +                     bgmac_phy_write(bgmac, i, 0x17, 0x0010);
>> +                     bgmac_phy_write(bgmac, i, 0x1f, 0x000f);
>> +                     bgmac_phy_write(bgmac, i, 0x16, 0x5296);
>> +                     bgmac_phy_write(bgmac, i, 0x17, 0x1073);
>> +                     bgmac_phy_write(bgmac, i, 0x17, 0x9073);
>> +                     bgmac_phy_write(bgmac, i, 0x16, 0x52b6);
>> +                     bgmac_phy_write(bgmac, i, 0x17, 0x9273);
>> +                     bgmac_phy_write(bgmac, i, 0x1f, 0x000b);
>
> That's a lot of magic numbers.

I agree, unfortunately there's nothing I can do :( I don't know names
for that registers not to mention the values (bits). We don't have
datasheets for that devices and I don't think we will ever have.


>> +static void bgmac_chip_stats_update(struct bgmac *bgmac)
>> +{
>> +     int i;
>> +
>> +     if (bgmac->core->id.id !=3D BCMA_CORE_4706_MAC_GBIT) {
>
> Save an indent level by returning a call to
> a new bgmac_4706_chip_stats_update instead?
>
>         if (bgmac->core->id.id =3D=3D BCMA_CORE_4706_MAC_GBIT)
>                 return bgmac_407_chip_stats_update(bgmac);
>
>> +             for (i =3D 0; i < BGMAC_NUM_MIB_TX_REGS; i++)
>> +                     bgmac->mib_tx_regs[i] =3D
>> +                             bgmac_read(bgmac,
>> +                                        BGMAC_TX_GOOD_OCTETS + (i *=
 4));
>> +             for (i =3D 0; i < BGMAC_NUM_MIB_RX_REGS; i++)
>> +                     bgmac->mib_rx_regs[i] =3D
>> +                             bgmac_read(bgmac,
>> +                                        BGMAC_RX_GOOD_OCTETS + (i *=
 4));
>> +     }
>
> unindent
>
>> +
>> +     /* TODO: what else? how to handle BCM4706? */
>
> and delete?

I got an info from Hauke that we can still do/read sth on BCM4706.
It's just not documented yet, that's why I left "TODO". I can note the
specs are lacking to make it clearer.


>> +}
>> +
>> +static void bgmac_clear_mib(struct bgmac *bgmac)
>> +{
>> +     int i;
>> +
>> +     if (bgmac->core->id.id =3D=3D BCMA_CORE_4706_MAC_GBIT)
>> +             return;
>
> Something like what this function does.


>> +     /* Stats */
>> +     bool stats_grabbed;
>> +     u32 mib_tx_regs[BGMAC_NUM_MIB_TX_REGS];
>> +     u32 mib_rx_regs[BGMAC_NUM_MIB_RX_REGS];
>> +};
>
> Maybe some minor reordering of the u8/bools to reduce padding.

Really? Compiler won't do that for me? I hope that compiler optimizes
structs (until using __packed) :(

--=20
Rafa=C5=82
