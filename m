From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH RFC 2/3] dsa: Add support for multiple cpu ports.
Date: Mon, 1 Jun 2015 02:51:05 +0200
Message-ID: <20150601005105.GA8647@lunn.ch>
References: <1432926814-22648-1-git-send-email-andrew@lunn.ch>
 <1432926814-22648-3-git-send-email-andrew@lunn.ch>
 <871thyfer0.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>, mathieu@codeaurora.org
To: =?iso-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:48712 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758740AbbFAA43 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 31 May 2015 20:56:29 -0400
Content-Disposition: inline
In-Reply-To: <871thyfer0.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, May 30, 2015 at 02:09:55PM +0200, Bj=F8rn Mork wrote:
> Andrew Lunn <andrew@lunn.ch> writes:
>=20
> > Some boards have two CPU interfaces connected to the switch, e.g. W=
iFi
> > access points, with 1 port labeled WAN, 4 ports labeled lan1-lan4, =
and
> > two port connected to the SoC.
> >
> > This patch extends DSA to allows both CPU ports to be used. The "cp=
u"
> > node in the DSA tree can now have a phandle to the host interface i=
t
> > connects to. Each user port can have a phandle to a cpu port which
> > should be used for traffic between the port and the CPU. Thus simpl=
e
> > load sharing over the two CPU ports can be achieved.
> >
> > Signed-off-by: Andrew Lunn <andrew@lunn.ch>
> > ---
> >  Documentation/devicetree/bindings/net/dsa/dsa.txt |  66 ++++++++++=
++-
> >  drivers/net/dsa/mv88e6xxx.c                       |   8 +-
> >  include/net/dsa.h                                 |  28 +++++-
> >  net/dsa/dsa.c                                     | 109 ++++++++++=
++++++++----
> >  net/dsa/dsa_priv.h                                |   6 ++
> >  net/dsa/slave.c                                   |  10 +-
> >  net/dsa/tag_brcm.c                                |   2 +-
> >  net/dsa/tag_dsa.c                                 |   2 +-
> >  net/dsa/tag_edsa.c                                |   2 +-
> >  net/dsa/tag_trailer.c                             |   2 +-
> >  10 files changed, 206 insertions(+), 29 deletions(-)
> >
> > diff --git a/Documentation/devicetree/bindings/net/dsa/dsa.txt b/Do=
cumentation/devicetree/bindings/net/dsa/dsa.txt
> > index f0b4cd72411d..34f7f18026e5 100644
> > --- a/Documentation/devicetree/bindings/net/dsa/dsa.txt
> > +++ b/Documentation/devicetree/bindings/net/dsa/dsa.txt
> > @@ -58,13 +58,24 @@ Optionnal property:
> >  			  Documentation/devicetree/bindings/net/ethernet.txt
> >  			  for details.
> > =20
> > +- ethernet		: Optional for "cpu" ports. A phandle to an ethernet
> > +                          device which will be used by this CPU po=
rt for
> > +			  passing packets to/from the host. If not present,
> > +			  the port will use the "dsa,ethernet" property
> > +			  defined above.
> > +
> > +- cpu			: Option for non "cpu"/"dsa" ports. A phandle to a
> > +			  "cpu" port, which will be used for passing packets
> > +			  from this port to the host. If not present, the first
> > +			  "cpu" port will be used.
> > +
>=20
> I'm in deep water here, but this scheme sounds a little too static to=
 me
> if I understand your proposal correctly.  Why would you want to creat=
e a
> static mapping of CPU ports to external ports for any given device?  =
To
> me, that's part of the switch VLAN configuration.
=20
Bj=F8rn

Sorry for not replying earlier, i was out for the weekend. But it did
give me time to think about this.

But lets take a step back first, and look at the background. You talk
about vlan's and swconfig. Mainline does things quite differently than
OpenWRT. It was decided a while ago that all "hardware accelerators"
like L2 switches, L3 routers, should use the normal Linux way of
configuration. Ports should look like normal ports.

Looking at my dir665:

2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP g=
roup default qlen 1000
    link/ether c8:be:19:61:de:54 brd ff:ff:ff:ff:ff:ff
    inet6 fe80::cabe:19ff:fe61:de54/64 scope link=20
       valid_lft forever preferred_lft forever
3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP g=
roup default qlen 1000
    link/ether c8:be:19:61:de:55 brd ff:ff:ff:ff:ff:ff
    inet6 fe80::cabe:19ff:fe61:de55/64 scope link=20
       valid_lft forever preferred_lft forever
5: lan4@eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue =
state UP group default=20
    link/ether c8:be:19:61:de:54 brd ff:ff:ff:ff:ff:ff
    inet 10.0.0.9/24 brd 10.0.0.255 scope global lan4
       valid_lft forever preferred_lft forever
    inet6 fe80::cabe:19ff:fe61:de54/64 scope link=20
       valid_lft forever preferred_lft forever
6: lan3@eth0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueu=
e master br0 state LOWERLAYERDOWN group default=20
    link/ether c8:be:19:61:de:55 brd ff:ff:ff:ff:ff:ff
7: lan2@eth0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueu=
e master br0 state LOWERLAYERDOWN group default=20
    link/ether c8:be:19:61:de:54 brd ff:ff:ff:ff:ff:ff
8: lan1@eth0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN grou=
p default=20
    link/ether c8:be:19:61:de:55 brd ff:ff:ff:ff:ff:ff
9: wan@eth0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue=
 state LOWERLAYERDOWN group default=20
    link/ether c8:be:19:61:de:54 brd ff:ff:ff:ff:ff:ff
    inet 192.168.10.3/24 brd 192.168.10.255 scope global wan
       valid_lft forever preferred_lft forever
10: br0@NONE: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueu=
e state LOWERLAYERDOWN group default=20
    link/ether c8:be:19:61:de:54 brd ff:ff:ff:ff:ff:ff
    inet 192.168.13.3/24 brd 192.168.13.255 scope global br0
       valid_lft forever preferred_lft forever

root@dir665:~# brctl show
bridge name     bridge id               STP enabled     interfaces
br0             8000.c8be1961de54       no              lan2
                                                        lan3

I have a dhcp client running on lan4. I have a fixed address on wan,
using /etc/network/interfaces, lan2 and lan3 are bridged together, and
an IP address added to the bridge, etc.

So the ports look like normal ports, and you configure then using the
normal mechanisms.

DSA does not use vlans. It uses an additional protocol header which
the switch supports, to allow the CPU to direct packets out a specific
port. Similarly, packets coming to the CPU from a port and marked with
the port they ingressed. This means the ports are completely separated
by default. When you add interfaces to a bridge, calls are made by the
bridge code into DSA to setup the switch to hardware bridge the
interface. And if the switch driver does not support it, software
bridging is used instead. Unless you know what is going on under the
hood, you have no idea that eth0 and eth1 are used to carry packets to
the switch, and that the switch is bridging the interfaces. So it is
linux concepts, with some hardware acceleration.

Now back to you question. What is clearly hardware and needs to go
into device tree is the mapping between switch ports and cpu
ports. eth0 <--> port 6, eth1 <--> port 5.

But i've reconsidered putting into device tree the load balancing of
which slave ports, lan[1-4], wan, are attached to which master port,
eth[01]. It should not be in DT. We want a sensible default, which i
would say is what i had in DT, allocate them every other, but
implement this in software. And allow the user to move slaves between
masters, using a user space command. Something like:

ip link set dev lan4 master eth0

So if you wish, you can then have eth1 dedicated to WAN, and eth0 for
lan[1-4]. Or any other combination.

I would say implementing this command to move a slave between masters
can come later, so long as we have a default which works for most
people. Using every other is clearly between than only using one
interface.

	Andrew
