From: "Leonid Grossman" <Leonid.Grossman@neterion.com>
Subject: RE: [PATCH] NET: Multiqueue network device support.
Date: Sat, 9 Jun 2007 17:23:34 -0400
Message-ID: <78C9135A3D2ECE4B8162EBDCE82CAD7701B7D6BC@nekter>
References: <1181168020.4064.46.camel@localhost> <D5C1322C3E673F459512FB59E0DDC32902FC61BF@orsmsx414.amr.corp.intel.com> <78C9135A3D2ECE4B8162EBDCE82CAD7701B7D69C@nekter> <1181417000.4043.34.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"Patrick McHardy" <kaber@trash.net>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>, <jeff@garzik.org>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>,
	"Ramkrishna Vepa" <Ramkrishna.Vepa@neterion.com>,
	"Alex Aizman" <aaizman@neterion.com>
To: <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.neterion.com ([72.1.205.142]:30559 "EHLO owa.neterion.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750932AbXFIVZx convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Jun 2007 17:25:53 -0400
Content-class: urn:content-classes:message
In-Reply-To: <1181417000.4043.34.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: J Hadi Salim [mailto:j.hadi123@gmail.com] On Behalf Of jamal
> Sent: Saturday, June 09, 2007 12:23 PM
> To: Leonid Grossman
> Cc: Waskiewicz Jr, Peter P; Patrick McHardy; davem@davemloft.net;
> netdev@vger.kernel.org; jeff@garzik.org; Kok, Auke-jan H; Ramkrishna
> Vepa; Alex Aizman
> Subject: RE: [PATCH] NET: Multiqueue network device support.
> 
> On Sat, 2007-09-06 at 10:58 -0400, Leonid Grossman wrote:
> 
> > IMHO, in addition to current Intel and Neterion NICs, some/most
> upcoming
> > NICs are likely to be multiqueue, since virtualization emerges as a
> > major driver for hw designs (there are other things of course that
> drive
> > hw, but these are complimentary to multiqueue).
> >
> > PCI-SIG IOV extensions for pci spec are almost done, and a typical
> NIC
> > (at least, typical 10GbE NIC that supports some subset of IOV) in
the
> > near future is likely to have at least 8  independent channels with
> its
> > own tx/rx queue, MAC address, msi-x vector(s), reset that doesn't
> affect
> > other channels, etc.
> 
> Leonid - any relation between that and data center ethernet? i.e
> http://www.ieee802.org/3/ar/public/0503/wadekar_1_0503.pdf
> It seems to desire to do virtualization as well.

Not really. This is a very old presentation; you probably saw some newer
PR on Convergence Enhanced Ethernet, Congestion Free Ethernet etc. 
These efforts are in very early stages and arguably orthogonal to
virtualization, but in general having per channel QoS (flow control is
just a part of it) is a good thing. 

> Is there any open spec for PCI-SIG IOV?

I don't think so, the actual specs and event presentations at
www.pcisig.org are members-only, although there are many PRs about early
IOV support that may shed some light on the features.  

But my point was that while virtualization capabilities of upcoming NICs
may be not even relevant to Linux, the multi-channel hw designs (a side
effect of virtualization push, if you will) will be there and a
non-virtualized stack can take advantage of them.

Actually, our current 10GbE NICs have most of such multichannel
framework already shipping (in pre-IOV fashion), so the programming
manual on the website can probably give you a pretty good idea about how
multi-channel 10GbE NICs may look like. 

> 
> > Basically, each channel could be used as an independent NIC that
just
> > happens to share pci bus and 10GbE PHY with other channels (but has
> > per-channel QoS and throughput guarantees).
> 
> Sounds very similar to data centre ethernet - except data centre
> ethernet seems to map "channels" to rings; whereas the scheme you
> describe maps a channel essentially to a virtual nic which seems to
> read
> in the common case as a single tx, single rx ring. Is that right? If
> yes, we should be able to do the virtual nics today without any
changes
> really since each one appears as a separate NIC. It will be a matter
of
> probably boot time partitioning and parametrization to create virtual
> nics (ex of priorities of each virtual NIC etc).

Right, this is one deployment scenario for a multi-channel NIC, and it
will require very few changes in the stack (couple extra IOCTLS would be
nice).
There are two reasons why you still may want to have a generic
multi-channel support/awareness in the stack: 
1. Some users may want to have single ip interface with multiple
channels.
2. While multi-channel NICs will likely to be many, only "best-in-class"
will make the hw "channels" completely independent and able to operate
as a separate nic. Other implementations may have some limitations, and
will work as multi-channel API compliant devices but not nesseserily as
independent mac devices.
I agree though that supporting multi-channel APIs is a bigger effort.

> 
> > In a non-virtualized system, such NICs could be used in a mode when
> each
> > channel runs on one core; this may eliminate some locking...  This
> mode
> > will require btw deterministic session steering, current hashing
> > approach in the patch is not sufficient; this is something we can
> > contribute once Peter's code is in.
> 
> I can actually see how the PCI-SIG approach using virtual NIC approach
> could run on multiple CPUs (since each is no different from a NIC that
> we have today). And our current Linux steering would also work just
> fine.
> 
> In the case of non-virtual NICs, i am afraid i dont think it is as
easy
> as simple session steering - if you want to be generic that is; you
may
> wanna consider a more complex connection tracking i.e a grouping of
> sessions as the basis for steering to a tx ring (and therefore tying
to
> a specific CPU).
> If you are an ISP or a data center with customers partitioned based on
> simple subnets, then i can see a simple classification based on
subnets
> being tied to a hw ring/CPU. And in such cases simple flow control on
a
> per ring basis makes sense.
> Have you guys experimented on the the non-virtual case? And are you
> doing the virtual case as a pair of tx/rx being a single virtual nic?

To a degree. We have quite a bit of testing done in non-virtual OS (not
in Linux though), using channels with tx/rx rings, msi-x etc as
independent NICs. Flow control was not a focus since the fabric
typically was not congested in these tests, but in theory per-channel
flow control should work reasonably well. Of course, flow control is
only part of resource sharing problem. 

> 
> > In general, a consensus on kernel support for multiqueue NICs will
be
> > beneficial since multiqueue HW is here and other stacks already
> taking
> > advantage of it.
> 
> My main contention with the Peters approach has been to do with the
> propagating of flow control back to the qdisc queues. However, if this
> PCI SIG standard is also desiring such an approach then it will shed a
> different light.

This is not what I'm saying :-). The IEEE link you sent shows that
per-link flow control is a separate effort, and it will likely to take
time to become a standard. 
Also, (besides the shared link) the channels will share pci bus.

One solution could be to provide a generic API for QoS level to a
channel 
(and also to a generic NIC!). 
Internally, device driver can translate QoS requirements into flow
control, pci bus bandwidth, and whatever else is shared on the physical
NIC between the channels.
As always, as some of that code becomes common between the drivers it
can migrate up.

Best, Leonid

> 
> cheers,
> jamal

