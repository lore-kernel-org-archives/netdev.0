From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] ipv6: alternative version of S/390 shared NIC support
Date: 19 Jan 2005 08:49:28 -0500
Message-ID: <1106142567.1049.970.camel@jzny.localdomain>
References: <20050116115431.GA13617@lst.de>
	 <200501180037.58453.christian@borntraeger.net>
	 <1106009385.1046.49.camel@jzny.localdomain>
	 <200501181653.59041.christian@borntraeger.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: Christoph Hellwig <hch@lst.de>, "David S. Miller" <davem@davemloft.net>,
        pavlic@de.ibm.com, waldi@debian.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Christian =?ISO-8859-1?Q?Borntr=E4ger?= <christian@borntraeger.net>
In-Reply-To: <200501181653.59041.christian@borntraeger.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


On Tue, 2005-01-18 at 10:53, Christian Borntr=E4ger wrote:
> Frank, please correct me, if I am wrong....
>=20
> jamal wrote:
> > On Mon, 2005-01-17 at 18:37, Christian Borntr=E4ger wrote:
> > > I am trying a small simplification here:
> > > Each physical network adapter offers hundreds of device addresses. =
You
> > > need 3 of them to have one logical network adapter(read,write,data).
> >
> > the "card" concept is what you call network adapter, correct?
> > I take it that read and write are control channels and data is where =
the
> > skb comes through?
>=20
> don't ask me about naming....

thats fine,=20
I think it doesnt matter what they are used for; important part is
you need all 3 addresses to have a "card"; so got it.

>=20
> > >  S/390 has
> > > hardware supported virtualization. Therefore can then use the
> > > hypervisor (LPAR or z/VM) to give specific LPARs or VM guests exact=
ly 3
> > > device addresses out of these hundreds.
> >
> > Can you provision multiple of these cards per VM? if yes, is there so=
me
> > ID that will break it down to OSInstance:cardid?

You did not answer this question.=20
Let me draw a diagram to show what i think the hierachy is:

  Physical Card: MAC address X
     |
     |
     +--- OSInstance A
     |        |
     |        +-- "CARD" with IP A
     |        +-- "CARD" with IP B
     |        +-- "CARD" with IP C
     |        +-- "CARD" with IP D
     .        =20
     .
     .
     |
     +--- OSInstance N
              |
              +-- "CARD" with IP Z


Is the above reflective of what happens?
In other words, packet comes from the wire (with MAC address X); somehow
the hypervisor(?) or firmware figures based on IP address A (assuming no
other instance has that IP) it has to send packet to OSInstanceA.
OSInstanceA then selects further the CARD based on something probably in
a descriptor?

Let me get to the point:
I think it would make sense for the "CARD" to be just another netdevice
(call it "card" netdevice for this discussion).
The representation of the physical card in the OSInstance is also a
netdevice(call it physical netdevice for this discussion) as it is now
(excpet it has no IP address ever).=20
The "card netdevices" are stacked on top of the physical netdevice. This
would be like an upside down bridge stacking relationship of
netdevices....
It actually is no different from a few tunnel netdevices that sit on top
of say eth0 or multiple PPP devices on top of ethx in a PPPOE
relationship.
The demuxing for incoming packets is done at physical card netdevice
to select the "card" netdevice whose receive method is then called.
Reverse direction for transmit (we could go into details later, just
wanna make sure this is sensible to begin with).
Does this sound reasonable? If yes, then if you do this you wont need to
hack anything like IPV6 etc in your driver - they become merely
netdevices. It should also allow for all standard features like ifconfig
up/down etc of the "card" and setting IP addresses, VLANS etc to work as
is. And you wont need to put any speacilized code in the driver.
If its off tangent, then i just wasted 1/2 a cup of coffee energy typing
away ;->

> Right, without registering the IP address, you can not receive any pack=
et.

If this is firmware issue, it would be wise to fix it. You should be
able to register multiple MAC addresses hidden in the firmware (not at
the Linux level) and have your "cards" netdevice use them. i.e the
"card" netdevices would own those.

> As the logical network interface has no own MAC address you actually sp=
eak=20
> IP to the card. That also means, that without some additional effort, t=
ools=20
> like tcpdump fail and you need some patches in the dhcp tools.

Refer to above. If you actually have your virtual/"card" netdevice on
top of the physical netdevice have a MAC address, then all tools should
work as is with zero changes IMO.

> =20
> You can define options for routers to get more than your own packages, =
but=20
> IIRC you can only define a primary and secondary router per port.=20
>=20

Ok, this is new information - what does a "router" mean in relation to a
port?

cheers,
jamal
