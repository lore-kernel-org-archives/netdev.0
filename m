From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH RFC 00/28] DSA: Restructure probing
Date: Fri, 25 Dec 2015 14:00:19 -0800
Message-ID: <567DBC73.9040104@gmail.com>
References: <1450875402-20740-1-git-send-email-andrew@lunn.ch>
 <567B07CB.5080308@gmail.com> <20151223223303.GD25485@lunn.ch>
 <567B2A89.7000803@gmail.com> <20151224125812.GB29139@lunn.ch>
 <567CA01F.6010604@gmail.com> <20151225113123.GA7422@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: narmstrong@baylibre.com, vivien.didelot@savoirfairelinux.com,
	netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f178.google.com ([209.85.214.178]:33946 "EHLO
	mail-ob0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753862AbbLYWAW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Dec 2015 17:00:22 -0500
Received: by mail-ob0-f178.google.com with SMTP id iw8so201986289obc.1
        for <netdev@vger.kernel.org>; Fri, 25 Dec 2015 14:00:21 -0800 (PST)
In-Reply-To: <20151225113123.GA7422@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 25/12/2015 03:31, Andrew Lunn a =C3=A9crit :
>>> One of my aims is to abstract away the MDIO bus from DSA. How you t=
alk
>>> to the switch is a switch device property. SF2 has a different way =
to
>>> talk to the switch, memory mapped IO, etc.
>>
>> I appreciate you trying to see my point of view and mentioning the
>> driver that I care about, but I am not just after SF2 here, just any
>> kind of switch in general: PCIe, SPI, I2C, GPIO, MDIO, MMIO is preci=
sely
>> what I would like to solve instead of narrow MDIO and distributed ca=
se
>> that DSA currently deals with, and MMIO with some help from the of_*
>> routines which do not need any kind of bus probing and struct device
>> creation (most often).
>=20
> And this is achieved with the new structure. How you access the switc=
h
> is part of the switch device binding, be it an MDIO bus/addr, an MMIO
> reg property, or an i2c client, etc. The switch driver registers a se=
t
> of ops which are neutral to the switch access mechanism.

I am not really questioning whether the abstraction is working, this
clearly does, what I am wondering is if the use of the component
framework requires us to have master and slaves be implemented as stric=
t
platform devices, or if we have a choice in how we mix things together,
like master is a platform device, but slaves could be I2C, SPI client o=
r
even platform devices themselves? That was not quite obvious to me by
looking at the patches, sorry.

If it is the former, then this does not really allow us to make this
framework usable to a wider class of devices. Also, one could imagine
that you could make the master network device's "struct device" be the
master device in the component framework terminology, such that you
could eliminate this synthetic "dsa" platform device.

>=20
> In the DSA node, the mdio bus is now only required when using
> backwards compatibility. The reg property is a bit odd, since it is
> used for linking DSA ports together. So currently it is kept, but onl=
y
> one of the two fields is used. We could in a later patchset change
> this, since there are currently no in kernel devices with multiple
> switches, so we don't have to worry about breaking the binding.

Sure, that would work.

>=20
>>> Anyway, who do you think the device tree binding will look? Maybe t=
ake
>>> the .dts file in patches 2 and 20 to build an example?
>>
>> The binding would look pretty much the same as what the current DSA =
and
>> your proposed binding look like, except that instead of encoding the
>> MDIO address *and* the switch index in tree in the same "reg" proper=
ties
>> (which was wrong along, but I did not really knew it back in 2009 or
>> so), the two would be different properties.
>=20
> Agreed, as explained above.
> =20
>> When you parse the Device Tree you can determine what is the positio=
n of
>> the switch in the switch tree by looking at its ports sub-nodes and =
see
>> if they have a "link" property which links them to another device,
>> eventually, in case where there is not a one to one, but one to many
>> connection, an additional property can help you figure out how to
>> flatten things out.
>>
>> So in practical terms, this could wind up looking like this:
>>
>> mdio_bus@deadbeef {
>> 	compatible =3D "acme,mdiobus";
>> 	..
>> 	switch0@0 {
>> 		compatible =3D "marvell,mv88e6131";
>> 		reg =3D <0>;
>> 		dsa,addr =3D <1>;
>=20
> This is not sufficient. It does not tell you which DSA cluster this
> switch belongs to.

Would it work if we added an additional digit which is the cluster id o=
r
do you need a node grouping switches in a cluster with each other like
you proposed in patch 20?

The question being mostly, if we have the cluster id, address/index in
switch tree, and a double linked list using phandles, is that good
enough to figure out a topology or shall we really have nodes and
sub-nodes with that (we would still need a list one linked list of
phandles to figure out which ports are "dsa").

>=20
>>
>> 		switch0port5: port@5 {
>> 				reg =3D <5>;
>> 				label =3D "dsa";
>> 				link =3D <&switch1port9>;
>> 			};
>> 		};
>> 	};
>> };
>=20
> Just for clarification, where are the cpu ports and normal user ports=
?
> Here as well?

I purposely omitted them to make the example simpler to read.

>=20
> Making MDIO controlled switches hang of MDIO can be done, but it does
> require some bigger changes to the mdio code. I will need to look at
> this again, but i think it starts in of_mdiobus_register_phy() which
> needs to look a the compatibility field, and do something different t=
o
> phy_device_register(). mdio_unregister() will also need some work,
> since it only expects phy devices on the mdio bus.

Correct, and this is really where I would start before we go on with th=
e
probing restructuring, because that could impact how the new DSA bindin=
g
will have to be (re)defined. Right now, converting the Marvell drivers
into individual platform devices is kind of a temporary solution becaus=
e
we do not have have a proper MDIO device model which is not a PHY.

There are lots of good patches in this series that should probably be
merged right away since they are all improvements.
--=20
=46lorian
