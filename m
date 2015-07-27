From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] phylib: add driver for aquantia phy
Date: Mon, 27 Jul 2015 14:49:38 -0700
Message-ID: <55B6A772.90903@gmail.com>
References: <1437709605-42980-1-git-send-email-shh.xie@gmail.com> <55B1C17B.1000704@gmail.com> <BLUPR03MB14753A6DDD02A9F944F2723EE28E0@BLUPR03MB1475.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Shaohui Xie <Shaohui.Xie@freescale.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:35033 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752739AbbG0Vvl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2015 17:51:41 -0400
Received: by pabkd10 with SMTP id kd10so57747423pab.2
        for <netdev@vger.kernel.org>; Mon, 27 Jul 2015 14:51:41 -0700 (PDT)
In-Reply-To: <BLUPR03MB14753A6DDD02A9F944F2723EE28E0@BLUPR03MB1475.namprd03.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 27/07/15 01:30, Shaohui Xie wrote:
>> -----Original Message-----
>> From: Florian Fainelli [mailto:f.fainelli@gmail.com]
>> Sent: Friday, July 24, 2015 12:39 PM
>> To: shh.xie@gmail.com; netdev@vger.kernel.org; davem@davemloft.net
>> Cc: Xie Shaohui-B21989
>> Subject: Re: [PATCH] phylib: add driver for aquantia phy
>>
>> Le 07/23/15 20:46, shh.xie@gmail.com a =C3=A9crit :
>>> From: Shaohui Xie <Shaohui.Xie@freescale.com>
>>>
>>> This patch added driver to support Aquantia PHYs AQ1202, AQ2104,
>>> AQR105, AQR405, which accessed through clause 45.
>>
>> Could you prefix your patches with "net: phy: " in the future to be
>> consistent with what is typically used?
> [S.H] OK.
>=20
>>
>> See comments below
>>
>>>
>>> Signed-off-by: Shaohui Xie <Shaohui.Xie@freescale.com>
>>> ---
>>
>> [snip]
>>
>>> +static int aquantia_read_status(struct phy_device *phydev) {
>>> +	int reg;
>>> +
>>> +	phydev->speed =3D SPEED_10000;
>>> +	phydev->duplex =3D DUPLEX_FULL;
>>> +
>>> +	reg =3D phy_read_mmd(phydev, MDIO_MMD_AN, MDIO_STAT1);
>>> +	reg =3D phy_read_mmd(phydev, MDIO_MMD_AN, MDIO_STAT1);
>>> +	if (reg & MDIO_STAT1_LSTATUS)
>>> +		phydev->link =3D 1;
>>> +	else
>>> +		phydev->link =3D 0;
>>> +
>>> +	reg =3D phy_read_mmd(phydev, MDIO_MMD_AN, 0xc800);
>>> +	mdelay(10);
>>> +	reg =3D phy_read_mmd(phydev, MDIO_MMD_AN, 0xc800);
>>> +	if (reg =3D=3D 0x9)
>>> +		phydev->speed =3D SPEED_2500;
>>> +	else if (reg =3D=3D 0x5)
>>> +		phydev->speed =3D SPEED_1000;
>>> +	else if (reg =3D=3D 0x3)
>>> +		phydev->speed =3D SPEED_100;
>>
>> Could we use a switch/case here?=20
> [S.H] OK.
>=20
> How about 10Mbits/sec and duplex are we
>> guaranteed to be full-duplex at e.g: 100 or 10Mbits/sec?
> [S.H] The PHY does not support 10M bits/sec.=20
> When link to 100M. the phy is full-duplex.

Ok, that means you need to restrict the supported flags accordingly not
to advertise these modes as being supported in the first place, see bel=
ow:

>=20
>>
>>> +
>>> +	return 0;
>>> +}
>>> +
>>> +static struct phy_driver aquantia_driver[] =3D { {
>>> +	.phy_id		=3D PHY_ID_AQ1202,
>>> +	.phy_id_mask	=3D 0xfffffff0,
>>> +	.name		=3D "Aquantia AQ1202",
>>> +	.features	=3D PHY_GBIT_FEATURES,
>>
>> If these are 10GbE PHYs, should not we start defining a new features
>> bitmask here to reflect that accordingly? That way MAC
> [S.H] there are several defines for 10G PHYs, should be used by a giv=
en 10G PHY.=20
>=20
> for this Aquantia PHY, SUPPORTED_10000baseT_Full is a valid define, s=
hould I set it as below:
> .features	=3D PHY_GBIT_FEATURES | SUPPORTED_10000baseT_Full,

PHY_GBIT_FEATURES means 10/100/1000 half and full-duplex are supported,
which are not supported as you indicated above, I would go with adding
only the supported modes here, this is really important since this is
the contract between the PHY driver and the Ethernet MAC using it
through the PHY library.

Thanks!
--=20
=46lorian
