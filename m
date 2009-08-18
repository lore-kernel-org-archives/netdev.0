From: "Ira W. Snyder" <iws@ovro.caltech.edu>
Subject: Re: [Alacrityvm-devel] [PATCH v3 3/6] vbus: add a "vbus-proxy" bus
	model for vbus_driver objects
Date: Tue, 18 Aug 2009 08:53:29 -0700
Message-ID: <20090818155329.GD31060@ovro.caltech.edu>
References: <20090814154125.26116.70709.stgit@dev.haskins.net> <20090814154308.26116.46980.stgit@dev.haskins.net> <20090815103243.GA26749@elte.hu> <4A870964.9090408@codemonkey.ws> <4A8965E0.8050608@gmail.com> <20090817174142.GA11140@redhat.com> <4A89BAC5.9040400@gmail.com> <20090818084606.GA13878@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Gregory Haskins <gregory.haskins@gmail.com>, kvm@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	alacrityvm-devel@lists.sourceforge.net,
	Avi Kivity <avi@redhat.com>,
	Anthony Liguori <anthony@codemonkey.ws>,
	Ingo Molnar <mingo@elte.hu>,
	Gregory Haskins <ghaskins@novell.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ovro.ovro.caltech.edu ([192.100.16.2]:49307 "EHLO
	ovro.ovro.caltech.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752543AbZHRPxa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Aug 2009 11:53:30 -0400
Content-Disposition: inline
In-Reply-To: <20090818084606.GA13878@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 18, 2009 at 11:46:06AM +0300, Michael S. Tsirkin wrote:
> On Mon, Aug 17, 2009 at 04:17:09PM -0400, Gregory Haskins wrote:
> > Michael S. Tsirkin wrote:
> > > On Mon, Aug 17, 2009 at 10:14:56AM -0400, Gregory Haskins wrote:
> > >> Case in point: Take an upstream kernel and you can modprobe the
> > >> vbus-pcibridge in and virtio devices will work over that transport
> > >> unmodified.
> > >>
> > >> See http://lkml.org/lkml/2009/8/6/244 for details.
> > > 
> > > The modprobe you are talking about would need
> > > to be done in guest kernel, correct?
> > 
> > Yes, and your point is? "unmodified" (pardon the psuedo pun) modifies
> > "virtio", not "guest".
> >  It means you can take an off-the-shelf kernel
> > with off-the-shelf virtio (ala distro-kernel) and modprobe
> > vbus-pcibridge and get alacrityvm acceleration.
> 
> Heh, by that logic ksplice does not modify running kernel either :)
> 
> > It is not a design goal of mine to forbid the loading of a new driver,
> > so I am ok with that requirement.
> > 
> > >> OTOH, Michael's patch is purely targeted at improving virtio-net on kvm,
> > >> and its likewise constrained by various limitations of that decision
> > >> (such as its reliance of the PCI model, and the kvm memory scheme).
> > > 
> > > vhost is actually not related to PCI in any way. It simply leaves all
> > > setup for userspace to do.  And the memory scheme was intentionally
> > > separated from kvm so that it can easily support e.g. lguest.
> > > 
> > 
> > I think you have missed my point. I mean that vhost requires a separate
> > bus-model (ala qemu-pci).
> 
> So? That can be in userspace, and can be anything including vbus.
> 
> > And no, your memory scheme is not separated,
> > at least, not very well.  It still assumes memory-regions and
> > copy_to_user(), which is very kvm-esque.
> 
> I don't think so: works for lguest, kvm, UML and containers
> 
> > Vbus has people using things
> > like userspace containers (no regions),
> 
> vhost by default works without regions
> 
> > and physical hardware (dma
> > controllers, so no regions or copy_to_user) so your scheme quickly falls
> > apart once you get away from KVM.
> 
> Someone took a driver and is building hardware for it ... so what?
> 

I think Greg is referring to something like my virtio-over-PCI patch.
I'm pretty sure that vhost is completely useless for my situation. I'd
like to see vhost work for my use, so I'll try to explain what I'm
doing.

I've got a system where I have about 20 computers connected via PCI. The
PCI master is a normal x86 system, and the PCI agents are PowerPC
systems. The PCI agents act just like any other PCI card, except they
are running Linux, and have their own RAM and peripherals.

I wrote a custom driver which imitated a network interface and a serial
port. I tried to push it towards mainline, and DavidM rejected it, with
the argument, "use virtio, don't add another virtualization layer to the
kernel." I think he has a decent argument, so I wrote virtio-over-PCI.

Now, there are some things about virtio that don't work over PCI.
Mainly, memory is not truly shared. It is extremely slow to access
memory that is "far away", meaning "across the PCI bus." This can be
worked around by using a DMA controller to transfer all data, along with
an intelligent scheme to perform only writes across the bus. If you're
careful, reads are never needed.

So, in my system, copy_(to|from)_user() is completely wrong. There is no
userspace, only a physical system. In fact, because normal x86 computers
do not have DMA controllers, the host system doesn't actually handle any
data transfer!

I used virtio-net in both the guest and host systems in my example
virtio-over-PCI patch, and succeeded in getting them to communicate.
However, the lack of any setup interface means that the devices must be
hardcoded into both drivers, when the decision could be up to userspace.
I think this is a problem that vbus could solve.

For my own selfish reasons (I don't want to maintain an out-of-tree
driver) I'd like to see *something* useful in mainline Linux. I'm happy
to answer questions about my setup, just ask.

Ira
