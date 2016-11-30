From: Joakim Tjernlund <Joakim.Tjernlund@infinera.com>
Subject: Re: DSA vs. SWTICHDEV ?
Date: Wed, 30 Nov 2016 18:44:04 +0000
Message-ID: <1480531441.3563.148.camel@infinera.com>
References: <1480495831.3563.135.camel@infinera.com>
         <20161130135257.GC18716@lunn.ch> <1480516241.3563.142.camel@infinera.com>
         <20161130152503.GE21645@lunn.ch> <1480523716.3563.144.camel@infinera.com>
         <20161130165500.GH21645@lunn.ch> <1480527852.3563.146.camel@infinera.com>
         <922521a8-3a33-bbc4-2e07-2b946590c829@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-15"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "f.fainelli@gmail.com" <f.fainelli@gmail.com>,
        "andrew@lunn.ch" <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2nam02on0059.outbound.protection.outlook.com ([104.47.38.59]:59968
        "EHLO NAM02-BL2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1755756AbcK3S7R (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 30 Nov 2016 13:59:17 -0500
In-Reply-To: <922521a8-3a33-bbc4-2e07-2b946590c829@gmail.com>
Content-Language: en-US
Content-ID: <119449F3B21A804B8F00FE385066BBAF@infinera.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-11-30 at 10:10 -0800, Florian Fainelli wrote:
> On 11/30/2016 09:44 AM, Joakim Tjernlund wrote:
> > On Wed, 2016-11-30 at 17:55 +0100, Andrew Lunn wrote:
> > > > This is an embedded system with several boards in a subrack.
> > > > Each board has eth I/F connected to a switch to communicate with ea=
ch other.
> > > > One of the board will also house the actual switch device and manag=
e the switch.
> > > > Then the normal app just communicates over the physical eth I/F lik=
e any other board
> > > > in the system. There is a "manage switch app" which brings the swit=
ch up and partition
> > > > phys VLANs etc. (each phys I/F would be a a separate domain so no l=
oop)
> > >=20
> > > So you are planning on throwing away the "manage switch app", and jus=
t
> > > use standard linux networking commands? That is what switchdev is all
> > > about really, throwing away the vendor SDK for the switch, making a
> > > switch just a bunch on interfaces on the host which you manage as
> > > normal interfaces.
> >=20
> > Something like that. I need to run routing protocols on the switch I/Fs=
 and egress
> > pkgs on selected switch I/Fs bypassing ARP, just like DSA does with its=
 vendor
> > tags.
> >=20
> > >=20
> > > > I guess I could skip the phys I/F and have the switch app create a =
virtual eth0 I/F over PCIe
> > >=20
> > > No need to create this interface. It will exist if you go the
> > > switchdev route.
> > >=20
> > > > > > And switchdev can do all this over PCIe instead? Can you have a
> > > > > > switch tree in switchdev too?
> > > > >=20
> > > > > Mellonex says so, but i don't think they have actually implemente=
d it.
> > > >=20
> > > > Not impl. any of DSAs features? What can you do with a Mellonex swi=
tch then?
> > >=20
> > > They don't have a tree of switches, as far as i know. Just a single
> > > switch. But DSA does support a tree of switches, that is what the D i=
n
> > > DSA means, distributed. And there are a couple of boards which have 2
> > > to 4 switches in a tree.
> >=20
> > We might have a tree as well so now I really wonder: Given we write a
> > proper switchdev driver, can it support switchtrees without touching
> > switchdev infra structure? If not I guess we will attach a physical
> > eth I/F to the switch and use both DSA and switchdev to support both tr=
ees
> > and HW offload.=A0
>=20
> switchdev in itself really is the glue layer between the networking
> stack and how to push specific objects down to the Ethernet switch
> driver, and that Ethernet switch driver. Switchdev does not enforce a
> specific network device driver model object, and just provides standard
> hooks for your network devices to register with switchdev in order to
> push/receive offloads. DSA on the other hand, utilizes switchdev to get
> notifications about offloads from the networking stack, but also exposes
> a clearly and well defined Ethernet switch device driver model, as
> Andrew described, it creates per-port network devices, binds the ports
> to their PHYs (built-in, or external), and also takes care of
> encapsulating/decapsulating the switch specific tagging protocol.

Lets see, switchdev is mainly for offloading L2/L3 into HW and does NOT cre=
ate
virtual I/F(one for each phys sw port) so if my only goal is to offload I d=
on't
need DSA? (How do one create routes if no virtual I/Fs I wonder ..)=20

DSA then does create virt. I/Fs and manages switch trees, to actually tx pk=
g it needs
a phys I/F using vendor specific tags(for PCIe connected switches I can env=
ision using
the PCIe connection instead).

Who is the master when using both DSA and switchdev w.r.t initil conf/bring=
 up of switch?
configuring VLANs?

>=20
> We should probably put that in some crystal clear sentence somewhere in
> Documentation/networking/ but switchdev and DSA are complementary and
> not competitors, they just do not tackle the problems from the same angle=
.

Yes :)

>=20
> >=20
> > >=20
> > > I think this is partially down to market segments. Mellonex market is
> > > top of rack switches. High port count, very high bandwidth. DSA is
> > > more wireless access points, set top boxes, generally up to 7 ports o=
f
> > > 1Gbps and a few custom embedded products which need more ports, so
> > > build a tree of switches.
> >=20
> > We have on an existing board with a BCM ROBO switch with lots of ports(=
>24),
> > managed over SPI. Looking at BCM DSA tag code it looks like it only sup=
ports
> > some 8 ports or so. I still have to find out if this is a limitation in=
 BCM tagging
> > protocol or if just not impl. in DSA yet.
>=20
> Oh cool, can you share the model by chance? I suspect the tagging format

I think it is an BCM5322

> of that switch is going to be different than what net/dsa/tag_brcm.c, so
> feel free to add something NET_DSA_TAG_BRCM8B (for 8 bytes) or something
> like that.

I will have to look at that, don't have an docs handy.

>=20
> Note that DSA currently hardcodes the maximum number of ports to 14
> (DSA_MAX_PORTS), but this should obviously be something dynamically
> determined based on probing the switch device.
>=20
> Can you also evaluate if using drivers/net/dsa/b53/ would work for you?
> My hope would be that they preserved the register compatibility here,
> but since this has a large number of ports, it may have completely
> offset most registers.

I will have a look, I sure want to try out DSA/switchdev on existing boards=
 if I can :)

>=20
> BTW, there is #linuxswitch on Freenode if you want to chat!
