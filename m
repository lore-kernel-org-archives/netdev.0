From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 4/9] net: dsa: Allow configuration of CPU & DSA
 port speeds/duplex
Date: Tue, 25 Aug 2015 18:45:39 -0700
Message-ID: <55DD1A43.4070606@gmail.com>
References: <1440323220-20438-1-git-send-email-andrew@lunn.ch> <1440323220-20438-5-git-send-email-andrew@lunn.ch> <55DA1340.9080604@gmail.com> <20150823212404.GD20710@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f48.google.com ([209.85.218.48]:34594 "EHLO
	mail-oi0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751859AbbHZBpl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2015 21:45:41 -0400
Received: by oiey141 with SMTP id y141so112578671oie.1
        for <netdev@vger.kernel.org>; Tue, 25 Aug 2015 18:45:40 -0700 (PDT)
In-Reply-To: <20150823212404.GD20710@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 08/23/15 14:24, Andrew Lunn a =C3=A9crit :
>>> +		port_dn =3D cd->port_dn[port];
>>> +		if (of_phy_is_fixed_link(port_dn)) {
>>> +			ret =3D of_phy_register_fixed_link(port_dn);
>>> +			if (ret) {
>>> +				netdev_err(master,
>>> +					   "failed to register fixed PHY\n");
>>> +				return ret;
>>> +			}
>>> +			phydev =3D of_phy_find_device(port_dn);
>>> +			genphy_config_init(phydev);
>>> +			genphy_read_status(phydev);
>>> +			if (ds->drv->adjust_link)
>>> +				ds->drv->adjust_link(ds, port, phydev);
>>
>> This kind of hack here because what you really need is just the link
>> parameters, but you cannot obtain such information without first
>> configuring the PHY up to a certain point in genphy_config_init(), a=
nd
>> then have genphy_read_status() copy these values in your phydev stru=
cture.
>>
>> Maybe we should really consider something like this after all:
>>
>> https://lkml.org/lkml/2015/8/5/490
>=20
> Hi Florian
>=20
> This half solves the problem. The nice thing about using the
> fixed_link, is that i can just call the adjust_link function with it.
> The fixed_phy_status cannot be passed directly to adjust_link. Some
> code refactoring or duplication would be needed.

BTW, this is really the reason why I was trying to push for having MDIO
connected switches as PHY devices, because then you get the PHY library
to calculate the advertised/supported intersection for you, and you
could even imagine re-negotiating the CPU port link with the Ethernet M=
AC.

Maybe I should repost these patches some day once I can get that workin=
g
with multiple switches in a tree ;)

> =20
>> Or maybe, we should really introduce this "cpu" network device after=
 all
>> with a dropping xmit function, such that we get ethtool counters to =
work
>> on it, and we can also attach it to a PHY device to configure link
>> parameters?
>=20
> I keep humming and harring about this. I don't really like the idea o=
f
> having an interface which you cannot send/receive packets. Yet it
> solves a number of problems like this, and gives you access to
> statistics and registers in the usual way. If we do it for the CPU
> port, we should also do it for the DSA ports. And we probably want th=
e
> call for up to return -ENOSUP, just to make it clear it cannot be use=
d
> for anything.
>=20
>       Andrew
>=20


--=20
=46lorian
