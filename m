From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: rfi: stmmac: creating an of mdio bus for attached dsa
Date: Sat, 19 Sep 2015 13:58:39 -0700
Message-ID: <55FDCC7F.10601@gmail.com>
References: <55FBBCAC.1080904@electromag.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Phil Reid <preid@electromag.com.au>, netdev@vger.kernel.org,
	Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f175.google.com ([209.85.214.175]:33566 "EHLO
	mail-ob0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751738AbbISU6l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Sep 2015 16:58:41 -0400
Received: by obbbh8 with SMTP id bh8so59573589obb.0
        for <netdev@vger.kernel.org>; Sat, 19 Sep 2015 13:58:40 -0700 (PDT)
In-Reply-To: <55FBBCAC.1080904@electromag.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

+Andrew,

Le 09/18/15 00:26, Phil Reid a =C3=A9crit :
> G'day All,
>=20
> Prior to submitting a patch I'd just like to get an idea on what the
> correct way is to create and register an mdio bus for use by the marv=
ell
> dsa driver.
> On our system the cpu ethernet port is connected directly to a switch
> with a fixed link (1Gbit).
> So the driver needs to create and persist the mdio bus for the dsa
> driver using of_mdiobus_register.
> The trunk stmmac driver currently doesn't create the mdio bus if a fi=
xed
> link is found.
> stmmac_probe_config_dt does hte following check.
>     if (plat->phy_node || plat->phy_bus_name)
>         plat->mdio_bus_data =3D NULL;
> phy_node is set because a fixed-link is found above and setting
> mdio_bus_data to null skips mdio bus creation.
> removing the phy_node check gets things working.

It seems to me like you should have the stmmac driver always register
its MDIO bus driver, whether or not it will end-up being used depends o=
n
the information provided via OF/platform_data.

Even in topologies where a stmmac block is unused, you would expect
power/clock gating to be applied for the Ethernet MAC, but still have
the ability to use the MDIO bus of this stmmac instance if it connects
to a particular device. In your case, I would assume that the stmmac
Ethernet MAC and MDIO will be used, so this make even more sense.

>=20
> I've also modified stmmac_mdio_register to use of_mdiobus_register an=
d
> setup the dt to probe for a phy (that doesn't really exist, the switc=
h
> is on the mdio).
> This cause a fair bit of log spamming but does seem to work as the
> switch is detected.
> eg: eth0: PHY ID 00000000 at 27 IRQ POLL (stmmac-0:1b)
> Currently if no phy is found the mdio bus gets de registered so this
> seems to be required.
>=20
> In summary what is the correct way to make sure the mdio bus stays
> registered when a fixed-link is in use?
> Am I configuring the link to the switch incorrectly?

This seems reasonable to me. One of the problems with DSA right now is
that you need to provide a fixed-link emulated PHY for your Ethernet MA=
C
controller to keep "working" (that is: get link status/parameters etc.)=
,
while the switch sits on the MDIO bus and does not look like (yet) a PH=
Y
device.

The "problem" here is that the STMMAC driver treats fixed link as there
is no MDIO device connected here, so why bother with registering a MDIO
bus driver in the first place, which is a valid design shortcut, but no=
t
in the case of DSA right now.

In the future, I hope we can have DSA switch devices look like almost
regular PHY devices, such that we do not have to use the fixed PHY to
keep having the Ethernet MAC controller be happy with link parameters
to/from the switch, see [1].

[1]: https://lwn.net/Articles/643149/
--=20
=46lorian
