From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: DSA: Attaching phy twice?
Date: Sun, 08 Feb 2015 14:59:36 -0800
Message-ID: <54D7EA58.40706@gmail.com>
References: <20150208203211.GB23581@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f45.google.com ([209.85.218.45]:61093 "EHLO
	mail-oi0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759026AbbBHW7r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Feb 2015 17:59:47 -0500
Received: by mail-oi0-f45.google.com with SMTP id i138so1509832oig.4
        for <netdev@vger.kernel.org>; Sun, 08 Feb 2015 14:59:47 -0800 (PST)
In-Reply-To: <20150208203211.GB23581@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

Le 08/02/2015 12:32, Andrew Lunn a =E9crit :
> Hi Florian
>=20
> Have you seen messages like this before?

Yes :)

>=20
> [    2.495126] Distributed Switch Architecture driver version 0.1
> [    2.501358] mvneta f1070000.ethernet eth0: [0]: detected a Marvell=
 88E6172 switch
> [    2.556441] libphy: dsa slave smi: probed
> [    2.638292] net lan4: PHY already attached
> [    2.733285] net lan3: PHY already attached
> [    2.820749] net lan2: PHY already attached
> [    2.910749] net lan1: PHY already attached
> [    3.000772] net internet: PHY already attached
>=20
> What appears to be happening is that dsa_slave_phy_setup() is finding
> the phy for the port via device tree and using of_phy_connect(), or i=
t
> uses the fall back of taking a phy from the switch internal mdio bus
> and calling phy_connect_direct(). So if a phy is found,
> phy_attach_direct() gets called to attach the phy to the device.
>=20
> Then in dsa_slave_create(), a second call to phy_attach() is
> made. This is when we get the warning "PHY already attached", and it
> returns EBUSY, which is ignored.
>=20
> Is this code at the end of dsa_slave_create() doing anything useful?
>=20
> 	if (p->phy !=3D NULL) {
> 		if (ds->drv->get_phy_flags)
> 			p->phy->dev_flags |=3D ds->drv->get_phy_flags(ds, port);
>=20
> 		phy_attach(slave_dev, dev_name(&p->phy->dev),
> 			   PHY_INTERFACE_MODE_GMII);
>=20
> 		p->phy->autoneg =3D AUTONEG_ENABLE;
> 		p->phy->speed =3D 0;
> 		p->phy->duplex =3D 0;
> 		p->phy->advertising =3D p->phy->supported | ADVERTISED_Autoneg;
> 	}
>=20
> My quick testing suggests its not useful, so if you agree, i will
> submit a patch removing it. Or am i missing something?

Right, now that we have a call to phy_connect_direct() for the built-in
MDIO bus of the switch, we can remove that code, as it is indeed
redundant (note that it was not before, especially for !OF setups). I
would be happy to ack such a patch and give it a try here as well (with
bcm_sf2).

Thanks!
--
=46lorian
