From: "Ira W. Snyder" <iws@ovro.caltech.edu>
Subject: Re: [GIT PULL] AlacrityVM guest drivers for 2.6.33
Date: Wed, 23 Dec 2009 11:28:08 -0800
Message-ID: <20091223192808.GA30700@ovro.caltech.edu>
References: <4B1D4F29.8020309@gmail.com>
 <20091218215107.GA14946@elte.hu>
 <4B2F9582.5000002@gmail.com>
 <20091222075742.GB26467@elte.hu>
 <4B3103B4.4070708@gmail.com>
 <f73f7ab80912222215i39ba865dv95764f95fd57bd96@mail.gmail.com>
 <4B3254B4.2080602@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kyle Moffett <kyle@moffetthome.net>, Ingo Molnar <mingo@elte.hu>,
	Avi Kivity <avi@redhat.com>, kvm@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	torvalds@linux-foundation.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org,
	"alacrityvm-devel@lists.sourceforge.net"
	<alacrityvm-devel@lists.sourceforge.net>
To: Gregory Haskins <gregory.haskins@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756651AbZLWT2N@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4B3254B4.2080602@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 23, 2009 at 12:34:44PM -0500, Gregory Haskins wrote:
> On 12/23/09 1:15 AM, Kyle Moffett wrote:
> > On Tue, Dec 22, 2009 at 12:36, Gregory Haskins
> > <gregory.haskins@gmail.com> wrote:
> >> On 12/22/09 2:57 AM, Ingo Molnar wrote:
> >>> * Gregory Haskins <gregory.haskins@gmail.com> wrote:
> >>>> Actually, these patches have nothing to do with the KVM folks. [...]
> >>>
> >>> That claim is curious to me - the AlacrityVM host
> >>
> >> It's quite simple, really.  These drivers support accessing vbus, and
> >> vbus is hypervisor agnostic.  In fact, vbus isn't necessarily even
> >> hypervisor related.  It may be used anywhere where a Linux kernel is the
> >> "io backend", which includes hypervisors like AlacrityVM, but also
> >> userspace apps, and interconnected physical systems as well.
> >>
> >> The vbus-core on the backend, and the drivers on the frontend operate
> >> completely independent of the underlying hypervisor.  A glue piece
> >> called a "connector" ties them together, and any "hypervisor" specific
> >> details are encapsulated in the connector module.  In this case, the
> >> connector surfaces to the guest side as a pci-bridge, so even that is
> >> not hypervisor specific per se.  It will work with any pci-bridge that
> >> exposes a compatible ABI, which conceivably could be actual hardware.
> > 
> > This is actually something that is of particular interest to me.  I
> > have a few prototype boards right now with programmable PCI-E
> > host/device links on them; one of my long-term plans is to finagle
> > vbus into providing multiple "virtual" devices across that single
> > PCI-E interface.
> > 
> > Specifically, I want to be able to provide virtual NIC(s), serial
> > ports and serial consoles, virtual block storage, and possibly other
> > kinds of interfaces.  My big problem with existing virtio right now
> > (although I would be happy to be proven wrong) is that it seems to
> > need some sort of out-of-band communication channel for setting up
> > devices, not to mention it seems to need one PCI device per virtual
> > device.
> > 

Greg, thanks for CC'ing me.

Hello Kyle,

I've got a similar situation here. I've got many PCI agents (devices)
plugged into a PCI backplane. I want to use the network to communicate
from the agents to the PCI master (host system).

At the moment, I'm using a custom driver, heavily based on the PCINet
driver posted on the linux-netdev mailing list. David Miller rejected
this approach, and suggested I use virtio instead.

My first approach with virtio was to create a "crossed-wires" driver,
which connected two virtio-net drivers together. While this worked, it
doesn't support feature negotiation properly, and so it was scrapped.
You can find this posted on linux-netdev with the title
"virtio-over-PCI".

I started writing a "virtio-phys" layer which creates the appropriate
distinction between frontend (guest driver) and backend (kvm, qemu,
etc.). This effort has been put on hold for lack of time, and because
there is no example code which shows how to create an interface from
virtio rings to TUN/TAP. The vhost-net driver is supposed to fill this
role, but I haven't seen any test code for that either. The developers
haven't been especially helpful answering questions like: how would I
use vhost-net with a DMA engine.

(You'll quickly find that you must use DMA to transfer data across PCI.
AFAIK, CPU's cannot do burst accesses to the PCI bus. I get a 10+ times
speedup using DMA.)

The virtio-phys work is mostly lacking a backend for virtio-net. It is
still incomplete, but at least devices can be registered, etc. It is
available at:
http://www.mmarray.org/~iws/virtio-phys/

Another thing you'll notice about virtio-net (and vbus' venet) is that
they DO NOT specify endianness. This means that they cannot be used with
a big-endian guest and a little-endian host, or vice versa. This means
they will not work in certain QEMU setups today.

Another problem with virtio is that you'll need to invent your own bus
model. QEMU/KVM has their bus model, lguest uses a different one, and
s390 uses yet another, IIRC. At least vbus provides a standardized bus
model.

All in all, I've written a lot of virtio code, and it has pretty much
all been shot down. It isn't very encouraging.

> > So I would love to be able to port something like vbus to my nify PCI
> > hardware and write some backend drivers... then my PCI-E connected
> > systems would dynamically provide a list of highly-efficient "virtual"
> > devices to each other, with only one 4-lane PCI-E bus.

I've written some IOQ test code, all of which is posted on the
alacrityvm-devel mailing list. If we can figure out how to make IOQ use
the proper ioread32()/iowrite32() accessors for accessing ioremap()ed
PCI BARs, then I can pretty easily write the rest of a "vbus-phys"
connector.

> 
> Hi Kyle,
> 
> We indeed have others that are doing something similar.  I have CC'd Ira
> who may be able to provide you more details.  I would also point you at
> the canonical example for what you would need to write to tie your
> systems together.  Its the "null connector", which you can find here:
> 
> http://git.kernel.org/?p=linux/kernel/git/ghaskins/alacrityvm/linux-2.6.git;a=blob;f=kernel/vbus/connectors/null.c;h=b6d16cb68b7e49e07528278bc9f5b73e1dac0c2f;hb=HEAD
> 
> Do not hesitate to ask any questions, though you may want to take the
> conversation to the alacrityvm-devel list as to not annoy the current CC
> list any further than I already have ;)
> 

IMO, they should at least see the issues here. They can reply back if
they want to be removed.

I hope it helps. Feel free to contact me off-list with any other
questions.

Ira
