From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 1/2] net: ethtool: Add support for PHY packet
 generators
Date: Wed, 17 Feb 2016 22:55:33 +0100
Message-ID: <20160217215533.GC25818@lunn.ch>
References: <1455741127-25453-1-git-send-email-andrew@lunn.ch>
 <1455741127-25453-2-git-send-email-andrew@lunn.ch>
 <1455743179.21571.6.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:50685 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030267AbcBQVzi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Feb 2016 16:55:38 -0500
Content-Disposition: inline
In-Reply-To: <1455743179.21571.6.camel@decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 17, 2016 at 09:06:19PM +0000, Ben Hutchings wrote:
> On Wed, 2016-02-17 at 21:32 +0100, Andrew Lunn wrote:
> > Some PHY devices contain a simple packet generator. Features vary, =
but
> > often they can be used to generate packets of different sizes,
> > different contents, with or without errors, and with different inte=
r
> > packet gaps. Add support to the core ethtool code to support this.
> [...]
> > --- a/include/uapi/linux/ethtool.h
> > +++ b/include/uapi/linux/ethtool.h
> > @@ -1167,6 +1167,31 @@ struct ethtool_ts_info {
> > =A0	__u32	rx_reserved[3];
> > =A0};
> > =A0
> > +enum ethtool_phy_pkg_gen_flags {
> > +	ETH_PKT_RANDOM	=3D (1 << 0),
> > +	ETH_PKT_ERROR	=3D (1 << 1),
>=20
> What kind of error? =A0CRC error, FEC error, symbol error?

Hi Ben

I want to try to keep the API generic, since different PHYs are
different capabilities.  The Marvell phy will generate symbol errors
and CRC errors. You cannot control it in a finer way than that.
=20
> > +};
> > +
> > +/**
> > + * struct ethtool_phy_pkt_get - command to request the phy to gene=
rate packets.
> > + * @cmd: command number =3D %ETHTOOL_PHY_PKT_GEN
> > + * @count: number of packets to generate
> > + * @len: length of generated packets
> > + * @ipg: inter packet gap in bytes.
>=20
> What if the PHY doesn't allow varying the IPG? =A0Should there be a w=
ay
> to find out what its supported IPG is, or to request the default valu=
e?

If you pass 0, it will use the default IPG. If you pass a value other
than 0, and it is not supported, it return -EINVAL.

=46or the Marvell PHYs some don't support setting the IPG, it is hard
set to 12. On those phys passing anything other than 0 gives
-EINVAL. When an IPG is allowed, a value of 0 gives the default 12,
since 0 is invalid, and a value > 256 also gives -EINVAL, since that
is the limit imposed by the hardware.
=20
> Similarly, should there be a way to find out the minimum/maximum leng=
th it supports?

I'm trying to keep it simple. Do we really want to add a complex
mechanism to query every available parameter to determine the range of
values it can take? I find it better that the driver accepts the
values of 0 meaning pick a sensible default, and for any value not 0,
return an error if it cannot be supported by the hardware.
I tried to emphasise this in the man page patch.

> > + * @flags: a bitmask of flags from &enum ethtool_phy_pkg_gen_flags
> > + *
> > + * PHY drivers may not support all of these parameters. If the
> > + * requested parameter value cannot be supported an error should b=
e
> > + * returned.
>=20
> Should, or must?

Must would be better.
=20
> How does userland tell when the PHY has finished? =A0Should it be
> possible to cancel this (similar to ETHTOOL_PHYS_ID)?

The call is blocking and returns when all the packets are sent.
=46or the Marvell hardware, you can send up to 255 packets. At 10Mbps,
1518 byte packets and 256 it takes about 0.3 seconds.

I don't really like the idea of making it non-blocking. i.e. set it
generating packets and sometime later stop it. It can lead to some
very non-obvious issues. Why is my Ethernet card spamming the net at
line rate, yet the netdev TX counters are not going up?
=20
> What should happen if the stack tries to send a packet while the PHY =
is
> in this mode? =A0Is it discarded? =A0Should the driver indicate carri=
er-off=20
> so that this is obvious?

Depends on the hardware. Marvell PHYs will discard any packets coming
from the MAC.
=20
> [...]
> > --- a/net/core/ethtool.c
> > +++ b/net/core/ethtool.c
> > @@ -1541,6 +1541,25 @@ static int ethtool_get_phy_stats(struct net_=
device *dev, void __user *useraddr)
> > =A0	return ret;
> > =A0}
> > =A0
> > +static int ethtool_phy_pkt_gen(struct net_device *dev, void __user=
 *useraddr)
> > +{
> > +	struct phy_device *phydev =3D dev->phydev;
> > +	struct ethtool_phy_pkt_gen pkt_gen;
> > +	int err;
> > +
> > +	if (!phydev || !phydev->drv->pkt_gen)
> > +		return -EOPNOTSUPP;
> [...]
>=20
> Why should this be tied to phylib? =A0Nothing else in the ethtool
> interface is.

We need the phy lock to be held. We don't want anything else accessing
phy registers at the same time. For the Marvell hardware, we need to
change the page. If for example genphy_read_status() was used to poll
the status of the PHY, it could read from the wrong page and get very
confused.

	Andrew
