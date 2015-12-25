From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH RFC 00/28] DSA: Restructure probing
Date: Thu, 24 Dec 2015 17:47:11 -0800
Message-ID: <567CA01F.6010604@gmail.com>
References: <1450875402-20740-1-git-send-email-andrew@lunn.ch>
 <567B07CB.5080308@gmail.com> <20151223223303.GD25485@lunn.ch>
 <567B2A89.7000803@gmail.com> <20151224125812.GB29139@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: narmstrong@baylibre.com, vivien.didelot@savoirfairelinux.com,
	netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f178.google.com ([209.85.214.178]:34953 "EHLO
	mail-ob0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753243AbbLYBrO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Dec 2015 20:47:14 -0500
Received: by mail-ob0-f178.google.com with SMTP id 18so193564432obc.2
        for <netdev@vger.kernel.org>; Thu, 24 Dec 2015 17:47:13 -0800 (PST)
In-Reply-To: <20151224125812.GB29139@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 24/12/2015 04:58, Andrew Lunn a =C3=A9crit :
>> I do not think you need the platform device because ultimately what =
the
>> DSA platform device does is bind some data to the master network dev=
ice
>> the DSA switch tree is hanging off. Sure you need some piece of code
>> that is resident in kernel or module space to be able to parse and
>> allocate that data structure and bind multiple switch drivers togeth=
er,
>> but that could be a consequence of probing switch driver using their=
 bus
>> probe function.
>>
>> The way I would imagine this in a cluster configuration is that you
>> probe switches in the order in which they should appear in the final
>> switch tree (if this order cannot be guaranteed, then defer until it
>> is), and as you parse Device Tree for these switches you allocate th=
eir
>> resources and update the dsa_switch_tree structure "live".
>=20
> How do you get this ordering? You cannot control the probe order in
> Linux.

=46air enough, then the ordering is not that important after all, the
cases could be something like these:

- all switch drivers built into the kernel, whichever gets probed first
creates the dsa_switch_tree and attaches its to the master network devi=
ce
- subsequent switch drivers probed locate that master network device,
use the dsa_switch_tree and insert themselves at the correct index

If you need a working switch tree to boot your system from the network,
then all of this probing will eventually converge thanks to deferred
probing. If you build everything as a module, then the expectation as a=
n
end-user could be that the switch tree becomes only fully functional
when *all* modules, and consequently switch devices are loaded/created.
Whether the switch tree is functional in between is something that
mostly depends on the default switch configuration left by
bootloader/reset defaults, so your mileage may vary.

>=20
>> If we are using Device Tree this is relatively easy since we can loo=
kup
>> the entire Device Tree to know the switch tree topology whenever we
>> probe a switch device driver. If we are using platform data, then, w=
e
>> should have a way to associate a given MDIO bus address with
>> supplementary information, very much like what this patch does:
>=20
> One of my aims is to abstract away the MDIO bus from DSA. How you tal=
k
> to the switch is a switch device property. SF2 has a different way to
> talk to the switch, memory mapped IO, etc.

I appreciate you trying to see my point of view and mentioning the
driver that I care about, but I am not just after SF2 here, just any
kind of switch in general: PCIe, SPI, I2C, GPIO, MDIO, MMIO is precisel=
y
what I would like to solve instead of narrow MDIO and distributed case
that DSA currently deals with, and MMIO with some help from the of_*
routines which do not need any kind of bus probing and struct device
creation (most often).

>=20
> Anyway, who do you think the device tree binding will look? Maybe tak=
e
> the .dts file in patches 2 and 20 to build an example?

The binding would look pretty much the same as what the current DSA and
your proposed binding look like, except that instead of encoding the
MDIO address *and* the switch index in tree in the same "reg" propertie=
s
(which was wrong along, but I did not really knew it back in 2009 or
so), the two would be different properties.

When you parse the Device Tree you can determine what is the position o=
f
the switch in the switch tree by looking at its ports sub-nodes and see
if they have a "link" property which links them to another device,
eventually, in case where there is not a one to one, but one to many
connection, an additional property can help you figure out how to
flatten things out.

So in practical terms, this could wind up looking like this:

mdio_bus@deadbeef {
	compatible =3D "acme,mdiobus";
	..
	switch0@0 {
		compatible =3D "marvell,mv88e6131";
		reg =3D <0>;
		dsa,addr =3D <1>;

		switch0port5: port@5 {
				reg =3D <5>;
				label =3D "dsa";
				link =3D <&switch1port9>;
			};
		};
	};
};

soc-bus@cafebabe {
	compatible =3D "simple-bus";

	switch1@cafedead {
		compatible =3D "marvell,armada-xp-switch";
		reg =3D <0xcafedead 0x1000>;
		dsa,addr =3D <0>;

	=09
		switch1port9: port9 {
			reg =3D <9>;
			label =3D "dsa";
			link =3D <&switch0port5>;
		};
	};
};

That way you could even intertwine foreign bus switches, and that would
not make a slight difference in how they are managed by DSA.

Your changes in patch 20 make your switches appear out of any busing
hierarchy whereas they are actually child devices of their respective
mdio-mux bus nodes and should appear as such imho.
--=20
=46lorian
