From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH net-next 1/2] net: ethtool: Add support for PHY packet
 generators
Date: Wed, 17 Feb 2016 23:28:17 +0000
Message-ID: <1455751697.21571.34.camel@decadent.org.uk>
References: <1455741127-25453-1-git-send-email-andrew@lunn.ch>
	 <1455741127-25453-2-git-send-email-andrew@lunn.ch>
	 <1455743179.21571.6.camel@decadent.org.uk> <20160217215533.GC25818@lunn.ch>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-doUFaEFUeojUEijBTPbk"
Cc: David Miller <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:51057 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1423447AbcBQX2b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2016 18:28:31 -0500
In-Reply-To: <20160217215533.GC25818@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-doUFaEFUeojUEijBTPbk
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2016-02-17 at 22:55 +0100, Andrew Lunn wrote:
> On Wed, Feb 17, 2016 at 09:06:19PM +0000, Ben Hutchings wrote:
> > On Wed, 2016-02-17 at 21:32 +0100, Andrew Lunn wrote:
> > > Some PHY devices contain a simple packet generator. Features vary, bu=
t
> > > often they can be used to generate packets of different sizes,
> > > different contents, with or without errors, and with different inter
> > > packet gaps. Add support to the core ethtool code to support this.
> > [...]
> > > --- a/include/uapi/linux/ethtool.h
> > > +++ b/include/uapi/linux/ethtool.h
> > > @@ -1167,6 +1167,31 @@ struct ethtool_ts_info {
> > > =C2=A0	__u32	rx_reserved[3];
> > > =C2=A0};
> > > =C2=A0
> > > +enum ethtool_phy_pkg_gen_flags {
> > > +	ETH_PKT_RANDOM	=3D (1 << 0),
> > > +	ETH_PKT_ERROR	=3D (1 << 1),
> >=20
> > What kind of error? =C2=A0CRC error, FEC error, symbol error?
>=20
> Hi Ben
>=20
> I want to try to keep the API generic, since different PHYs are
> different capabilities.=C2=A0=C2=A0The Marvell phy will generate symbol e=
rrors
> and CRC errors. You cannot control it in a finer way than that.

Sure. =C2=A0But this should be commented, something like "all packets have
layer 1 and/or layer 2 errors".

Similarly the random flag should be commented as something like
"randomise packet header and payload".

> > > +};
> > > +
> > > +/**
> > > + * struct ethtool_phy_pkt_get - command to request the phy to genera=
te packets.
> > > + * @cmd: command number =3D %ETHTOOL_PHY_PKT_GEN
> > > + * @count: number of packets to generate
> > > + * @len: length of generated packets
> > > + * @ipg: inter packet gap in bytes.
> >=20
> > What if the PHY doesn't allow varying the IPG? =C2=A0Should there be a =
way
> > to find out what its supported IPG is, or to request the default value?
>=20
> If you pass 0, it will use the default IPG. If you pass a value other
> than 0, and it is not supported, it return -EINVAL.

Include that in the comment.

[...]=C2=A0
> > Similarly, should there be a way to find out the minimum/maximum length=
 it supports?
>=20
> I'm trying to keep it simple. Do we really want to add a complex
> mechanism to query every available parameter to determine the range of
> values it can take?

That is an important part of making this feature generic.

> I find it better that the driver accepts the
> values of 0 meaning pick a sensible default, and for any value not 0,
> return an error if it cannot be supported by the hardware.
> I tried to emphasise this in the man page patch.

The ethtool API is not a private API for the ethtool utility, despite
its name. =C2=A0The API must be documented in ethtool.h.

> > > + * @flags: a bitmask of flags from &enum ethtool_phy_pkg_gen_flags
> > > + *
> > > + * PHY drivers may not support all of these parameters. If the
> > > + * requested parameter value cannot be supported an error should be
> > > + * returned.
> >=20
> > Should, or must?
>=20
> Must would be better.
> =C2=A0
> > How does userland tell when the PHY has finished? =C2=A0Should it be
> > possible to cancel this (similar to ETHTOOL_PHYS_ID)?
>=20
> The call is blocking and returns when all the packets are sent.
> For the Marvell hardware, you can send up to 255 packets. At 10Mbps,
> 1518 byte packets and 256 it takes about 0.3 seconds.

OK, then it needs to drop the RTNL lock and the ethtool core should
probably call into the driver multiple times, similarly to
ETHTOOL_PHYS_ID..

> I don't really like the idea of making it non-blocking. i.e. set it
> generating packets and sometime later stop it. It can lead to some
> very non-obvious issues. Why is my Ethernet card spamming the net at
> line rate, yet the netdev TX counters are not going up?
> =C2=A0
> > What should happen if the stack tries to send a packet while the PHY is
> > in this mode? =C2=A0Is it discarded? =C2=A0Should the driver indicate c=
arrier-off=C2=A0
> > so that this is obvious?
>=20
> Depends on the hardware. Marvell PHYs will discard any packets coming
> from the MAC.

I know that the PHY behaviour varies but the API should be consistent
across drivers and the drivers will have to do a little work to ensure
that.

> > [...]
> > > --- a/net/core/ethtool.c
> > > +++ b/net/core/ethtool.c
> > > @@ -1541,6 +1541,25 @@ static int ethtool_get_phy_stats(struct net_de=
vice *dev, void __user *useraddr)
> > > =C2=A0	return ret;
> > > =C2=A0}
> > > =C2=A0
> > > +static int ethtool_phy_pkt_gen(struct net_device *dev, void __user *=
useraddr)
> > > +{
> > > +	struct phy_device *phydev =3D dev->phydev;
> > > +	struct ethtool_phy_pkt_gen pkt_gen;
> > > +	int err;
> > > +
> > > +	if (!phydev || !phydev->drv->pkt_gen)
> > > +		return -EOPNOTSUPP;
> > [...]
> >=20
> > Why should this be tied to phylib? =C2=A0Nothing else in the ethtool
> > interface is.
>=20
> We need the phy lock to be held. We don't want anything else accessing
> phy registers at the same time. For the Marvell hardware, we need to
> change the page. If for example genphy_read_status() was used to poll
> the status of the PHY, it could read from the wrong page and get very
> confused.

So what are net drivers that don't use phylib supposed to do to support thi=
s?

Ben.

--=20
Ben Hutchings
Lowery's Law:
             If it jams, force it. If it breaks, it needed replacing anyway=
.
--=-doUFaEFUeojUEijBTPbk
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAVsUCEee/yOyVhhEJAQok7xAAk7GJ6TTS9xTDmJRS1RZGwlkhmYkpNTww
ZStbhLKMP1r1BvxXja8zptbJVILr/f9SpKGePv9E/GshaOzCZfZVHUYnoegy4Prb
WJ3c+IYrXGaefd84bJ+BZjMzt7ey2w+XVuve/2BoZmXNI448H4M+Hv99a8hfE+BL
CQitBlWxtJz78XvQNOVaAbxCMWj56SifxLJBGrtai9rn4JpYI/jnVrRhH8eCAj/s
tGF1GqV8WHd2830pVpuoVKpIlv3J1ACdDbCLJnnvhJXgnDNw8SHMZr4pBs5x5t6i
ihOgkOETwnBdUCoQgb1ohiZOTqbkNYyWDw4utWt0NBVQhda59b3rzWlqzH2LzGQq
kcyMGV4nY0ZwAQOo6DyRSx5eug2R+DNTvWAsrUE5jI8HVS/SxS1optzRQueWM6j6
7pe9muqolLNLqjvBh54bnsJEPGA3uS1FfoNUfOsMoGVDdopwCfCJDBbTdURiZ6AZ
p5JEIvVk2ln8j/et4uPF1kAdRbBqNp3N4iVxFiZ09ZNANURz8loV20P+APXR6R+z
u0Q+1KTkz62bqpYdGSU3JQdbMyAutFtb2TFCtE3Bsue6FqW1QlLUOsvBKyVOYOAh
I4xGIJdr62GDH/RubTt6kcRyAKwPb7gy/CuWWZlUhK+j/KiyaZsWbaMjOMBxZLwK
EPWExxQ9rEc=
=sCSz
-----END PGP SIGNATURE-----

--=-doUFaEFUeojUEijBTPbk--
