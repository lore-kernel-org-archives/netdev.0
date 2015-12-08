From: Tim Harvey <tharvey@gateworks.com>
Subject: Re: [PATCH] I.MX6: Fix Ethernet PHY mode on Ventana boards
Date: Tue, 8 Dec 2015 06:30:56 -0800
Message-ID: <CAJ+vNU0RsXB7j4F5+M8d0Z06=eS1pkMRnyYOfimNPkXe-TfKbQ@mail.gmail.com>
References: <m3egeyct8o.fsf@t19.piap.pl>
	<CAJ+vNU0bNzuDJ971VS4r0gt4+zJj4GkXWE_qzoC0bs7s4OdU1Q@mail.gmail.com>
	<m3zixlav0p.fsf@t19.piap.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>, Shawn Guo <shawnguo@kernel.org>,
	Fabio Estevam <Fabio.Estevam@freescale.com>
To: =?UTF-8?Q?Krzysztof_Ha=C5=82asa?= <khalasa@piap.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f173.google.com ([209.85.223.173]:33109 "EHLO
	mail-io0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756665AbbLHOa5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2015 09:30:57 -0500
Received: by iouu10 with SMTP id u10so26389269iou.0
        for <netdev@vger.kernel.org>; Tue, 08 Dec 2015 06:30:56 -0800 (PST)
In-Reply-To: <m3zixlav0p.fsf@t19.piap.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 8, 2015 at 6:13 AM, Krzysztof Ha=C5=82asa <khalasa@piap.pl>=
 wrote:
> Tim Harvey <tharvey@gateworks.com> writes:
>
>> It sounds like your saying this controls whether the phy is in charg=
e
>> of delay vs the MAC. I have never needed to set this and haven't fou=
nd
>> where its actually used (in at least 4.3). Is this caused by somethi=
ng
>> new in the kernel I haven't seen yet or is it possible you have boar=
d
>> that has an Ethernet issue?
>
> I think you aren't using the Marvell PHY driver :-)
> The existing DTS files work fine with the "default" PHY driver.
> It's only the Marvell driver (drivers/net/phy/marvell.c, aka
> CONFIG_MARVELL_PHY) which have the issue.
>

Kryzsztof,

True - I have not used CONFIG_MARVELL_PHY and didn't know of its exista=
nce.

> The problem is caused by the following code in m88e1121_config_aneg()=
:
>
>         if (phy_interface_is_rgmii(phydev)) {
>
>                 mscr =3D phy_read(phydev, MII_88E1121_PHY_MSCR_REG) &
>                         MII_88E1121_PHY_MSCR_DELAY_MASK;
>
>                 if (phydev->interface =3D=3D PHY_INTERFACE_MODE_RGMII=
_ID)
>                         mscr |=3D (MII_88E1121_PHY_MSCR_RX_DELAY |
>                                  MII_88E1121_PHY_MSCR_TX_DELAY);
>                 else if (phydev->interface =3D=3D PHY_INTERFACE_MODE_=
RGMII_RXID)
>                         mscr |=3D MII_88E1121_PHY_MSCR_RX_DELAY;
>                 else if (phydev->interface =3D=3D PHY_INTERFACE_MODE_=
RGMII_TXID)
>                         mscr |=3D MII_88E1121_PHY_MSCR_TX_DELAY;
>
>                 err =3D phy_write(phydev, MII_88E1121_PHY_MSCR_REG, m=
scr);
>                 if (err < 0)
>                         return err;
>         }
>
> mscr initially holds the correct value (one with RX_DELAY and TX_DELA=
Y
> bits set). Since the _*ID are not specified, these bits are reset and
> (now incorrect) value is written back to the register.
> OTOH the generic PHY driver knows nothing about the MSCR and thus
> doesn't "corrupt" it.
>
> The whole -ID thing is about signal trace lengths (on PCB), where the
> non-ID setup requires special, longer traces for certain signals to
> compensate for propagation times etc. The -ID version does it interna=
lly
> (when enabled) and the PCB layout can be a bit simpler.

right - I understand what the delay lines are, it just struck me as
strange that I've never needed this.

>
> To be honest I only checked it on a single GW5400 rev. C, but I'd exp=
ect
> it to be exactly the same across all GW5[234]*. Can test on GW5[23] i=
f
> there is any doubt (in few days I guess).
>

no doubt now. I re-created your config and see the problem as well.

The marvell phy driver (drivers/net/phy/marvell.c) has a very lacking
Kconfig stating its a PHY driver for the 88E1011S when in fact it has
id's for 12 ID's including the 88E1510 we use on the GW51xx, GW52xx,
GW53xx, GW54xx.

This may be a stupid question but what does the Marvell phy driver
offer that the generic phy driver does not?

Thanks for finding this and submitting a patch!

Acked-by: Tim Harvey <tharvey@gateworks.com>

Tim
