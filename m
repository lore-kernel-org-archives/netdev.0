From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 8/8] b44: add dummy PHY device if we do not find any
Date: Sun, 15 Dec 2013 19:42:24 -0800
Message-ID: <3257000.PkooeomauC@lenovo>
References: <1387132925-18651-1-git-send-email-hauke@hauke-m.de> <1931903.b5YbP2FvL1@lenovo> <52AE3BD6.9070502@hauke-m.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, zambrano@broadcom.com, netdev@vger.kernel.org
To: Hauke Mehrtens <hauke@hauke-m.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f43.google.com ([209.85.219.43]:48542 "EHLO
	mail-oa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751998Ab3LPDm1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Dec 2013 22:42:27 -0500
Received: by mail-oa0-f43.google.com with SMTP id i7so4463813oag.16
        for <netdev@vger.kernel.org>; Sun, 15 Dec 2013 19:42:27 -0800 (PST)
In-Reply-To: <52AE3BD6.9070502@hauke-m.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 16 d=E9cembre 2013, 00:31:34 Hauke Mehrtens a =E9crit :
> On 12/15/2013 10:26 PM, Florian Fainelli wrote:
> > Hi Hauke,
> >=20
> > Le dimanche 15 d=E9cembre 2013, 19:42:05 Hauke Mehrtens a =E9crit :
> >> The ADM6996L switches used on some routers do not return a valid v=
alue
> >> when reading the PHY id register and Linux thinks there is not PHY=
 at
> >> all, but that is wrong. This created a dummy PHY and uses that ins=
tead.
> >=20
> > As far as I read it from the ADM6996L datasheet; the management int=
erface
> > on these switches is via a serial EEPROM which was usually wired up=
 to
> > the BCM47xx SoC to some GPIOs (kmod-switch driver in OpenWrt). If
> > MII_PHYSID1 and MII_PHYSID2 present bad values, I would assume that
> > MII_BMSR would also return bad values too and that if you are given=
 a
> > valid link speed/duplex this might just be because all bits are set=
?
>=20
> Yes these registers are returning 0xffff.

Ok, yes that's pretty typical of the absence of a physical connection b=
etween=20
the MAC and PHY/switch.

>=20
> > In any case this is a case where you should register a fixed PHY de=
vice
> > instead of creating such a dummy device which will still make the m=
diobus
> > driver/PHY state machine issue real reads/writes on the MDIO bus to=
 a
> > non-existent PHY.
> Yes I will try that.

Thanks! Note that a fixed PHY must be registered before the fixed MDIO =
bus is=20
probe, you can take a look at how AR7 does it for instance=20
(arch/mips/ar7/platform.c and drivers/net/ethernet/ti/cpmac.c). We migh=
t want=20
to be able to change that in the future and re-scan the fixed MDIO bus =
though.

>=20
> >> Signed-off-by: Hauke Mehrtens <hauke@hauke-m.de>
> >> ---
> >>=20
> >>  drivers/net/ethernet/broadcom/b44.c |   23 +++++++++++++++++++---=
-
> >>  drivers/net/ethernet/broadcom/b44.h |    3 +++
> >>  2 files changed, 22 insertions(+), 4 deletions(-)
> >>=20
> >> diff --git a/drivers/net/ethernet/broadcom/b44.c
> >> b/drivers/net/ethernet/broadcom/b44.c index b65a463..07e58c2 10064=
4
> >> --- a/drivers/net/ethernet/broadcom/b44.c
> >> +++ b/drivers/net/ethernet/broadcom/b44.c
> >> @@ -2233,6 +2233,8 @@ static int b44_register_phy_one(struct b44 *=
bp)
> >>=20
> >>  	struct ssb_device *sdev =3D bp->sdev;
> >>  	struct phy_device *phydev;
> >>  	int err;
> >>=20
> >> +	struct phy_c45_device_ids c45_ids =3D {0};
> >> +	struct ssb_sprom *sprom =3D &sdev->bus->sprom;
> >>=20
> >>  	mii_bus =3D mdiobus_alloc();
> >>  	if (!mii_bus) {
> >>=20
> >> @@ -2266,10 +2268,23 @@ static int b44_register_phy_one(struct b44=
 *bp)
> >>=20
> >>  	}
> >>  =09
> >>  	phydev =3D bp->mii_bus->phy_map[bp->phy_addr];
> >>=20
> >> -	if (!phydev) {
> >> -		dev_err(sdev->dev, "could not find PHY at %i\n", bp->phy_addr);
> >> -		err =3D -ENODEV;
> >> -		goto err_out_mdiobus_unregister;
> >> +	if (!phydev &&
> >> +	    (sprom->boardflags_lo & (B44_BOARDFLAG_ROBO | B44_BOARDFLAG_=
ADM)))
> >> {
> >> +		dev_info(sdev->dev, "could not find PHY at %i, create dummy one=
\n",
> >> +			 bp->phy_addr);
> >=20
> > Your commit subject says ADM6996L but here you are also treating Br=
oadcom
> > switches that way, this might deserve a comment to explain that som=
e
> > BCM53xx switches might be SPI/GPIO connected.
>=20
> This is also needed for some Broadcom switches. The Broadcom BCM5325F
> switch has two MII interfaces and the BCM4704 has two MACs which are
> both connected to one of the MII interfaces of the switch. On such
> devices we do get a PHY ID for the first MII interface used for the L=
AN
> ports, but when trying to read the PHY ID of the second MII interface
> used for the WAN port it just returns 0xffff on all addresses. When
> registering this dummy phy we are able to talk to the interface.

Most likely you get 0xffff because the switch is only connected to the =
first=20
Ethernet MAC MDIO bus.

In that specific case it might be better to make the second Ethernet MA=
C probe=20
for PHYs on the first Ethernet MAC mdio bus or simply register a fixed =
PHY=20
device for the WAN port since you only want one Ethernet MAC to be in c=
ontrol=20
of the switch at a time.

>=20
> This WAN port seams to be hard wired to the second MII interface in t=
he
> switch.

This is quite likely, most Broadcom switches support one or two IMP (CP=
U port)=20
configurations.
--=20
=46lorian
