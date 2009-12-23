From: "Ira W. Snyder" <iws@ovro.caltech.edu>
Subject: Re: [Alacrityvm-devel] [GIT PULL] AlacrityVM guest drivers for
 2.6.33
Date: Wed, 23 Dec 2009 15:42:56 -0800
Message-ID: <20091223234256.GC30700@ovro.caltech.edu>
References: <4B1D4F29.8020309@gmail.com>
 <20091218215107.GA14946@elte.hu>
 <4B2F9582.5000002@gmail.com>
 <20091222075742.GB26467@elte.hu>
 <4B3103B4.4070708@gmail.com>
 <f73f7ab80912222215i39ba865dv95764f95fd57bd96@mail.gmail.com>
 <4B3232A1.8050505@codemonkey.ws>
 <20091223195413.GB30700@ovro.caltech.edu>
 <4B32A09D.30400@codemonkey.ws>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kyle Moffett <kyle@moffetthome.net>,
	Gregory Haskins <gregory.haskins@gmail.com>,
	kvm@vger.kernel.org, netdev@vger.kernel.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"alacrityvm-devel@lists.sourceforge.net"
	<alacrityvm-devel@lists.sourceforge.net>,
	Avi Kivity <avi@redhat.com>, Ingo Molnar <mingo@elte.hu>,
	torvalds@linux-foundation.org,
	Andrew Morton <akpm@linux-foundation.org>
To: Anthony Liguori <anthony@codemonkey.ws>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4B32A09D.30400@codemonkey.ws>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 23, 2009 at 04:58:37PM -0600, Anthony Liguori wrote:
> On 12/23/2009 01:54 PM, Ira W. Snyder wrote:
> > On Wed, Dec 23, 2009 at 09:09:21AM -0600, Anthony Liguori wrote:
> 
> > I didn't know you were interested in this as well. See my later reply to
> > Kyle for a lot of code that I've written with this in mind.
> 
> 
> BTW, in the future, please CC me or CC 
> virtualization@lists.linux-foundation.org.  Or certainly kvm@vger.  I 
> never looked at the virtio-over-pci patchset although I've heard it 
> referenced before.
> 

Will do. I wouldn't think kvm@vger would be on-topic. I'm not interested
in KVM (though I do use it constantly, it is great). I'm only interested
in using virtio as a transport between physical systems. Is it a place
where discussing virtio by itself is on-topic?

> >> But both virtio-lguest and virtio-s390 use in-band enumeration and
> >> discovery since they do not have support for PCI on either platform.
> >>
> >
> > I'm interested in the same thing, just over PCI. The only PCI agent
> > systems I've used are not capable of manipulating the PCI configuration
> > space in such a way that virtio-pci is usable on them.
> 
> virtio-pci is the wrong place to start if you want to use a PCI *device* 
> as the virtio bus. virtio-pci is meant to use the PCI bus as the virtio 
> bus.  That's a very important requirement for us because it maintains 
> the relationship of each device looking like a normal PCI device.
> 
> > This means
> > creating your own enumeration mechanism. Which sucks.
> 
> I don't think it sucks.  The idea is that we don't want to unnecessarily 
> reinvent things.
> 
> Of course, the key feature of virtio is that it makes it possible for 
> you to create your own enumeration mechanism if you're so inclined.
> 
> > See my virtio-phys
> > code (http://www.mmarray.org/~iws/virtio-phys/) for an example of how I
> > did it. It was modeled on lguest. Help is appreciated.
> 
> If it were me, I'd take a much different approach.  I would use a very 
> simple device with a single transmit and receive queue.  I'd create a 
> standard header, and the implement a command protocol on top of it. 
> You'll be able to support zero copy I/O (although you'll have a fixed 
> number of outstanding requests).  You would need a single large ring.
> 
> But then again, I have no idea what your requirements are.  You could 
> probably get far treating the thing as a network device and just doing 
> ATAoE or something like that.
> 

I've got a single PCI Host (master) with ~20 PCI slots. Physically, it
is a backplane in a cPCI chassis, but the form factor is irrelevant. It
is regular PCI from a software perspective.

Into this backplane, I plug up to 20 PCI Agents (slaves). They are
powerpc computers, almost identical to the Freescale MPC8349EMDS board.
They're full-featured powerpc computers, with CPU, RAM, etc. They can
run standalone.

I want to use the PCI backplane as a data transport. Specifically, I
want to transport ethernet over the backplane, so I can have the powerpc
boards mount their rootfs via NFS, etc. Everyone knows how to write
network daemons. It is a good and very well known way to transport data
between systems.

On the PCI bus, the powerpc systems expose 3 PCI BAR's. The size is
configureable, as is the memory location at which they point. What I
cannot do is get notified when a read/write hits the BAR. There is a
feature on the board which allows me to generate interrupts in either
direction: agent->master (PCI INTX) and master->agent (via an MMIO
register). The PCI vendor ID and device ID are not configureable.

One thing I cannot assume is that the PCI master system is capable of
performing DMA. In my system, it is a Pentium3 class x86 machine, which
has no DMA engine. However, the PowerPC systems do have DMA engines. In
virtio terms, it was suggested to make the powerpc systems the "virtio
hosts" (running the backends) and make the x86 (PCI master) the "virtio
guest" (running virtio-net, etc.).

I'm not sure what you're suggesting in the paragraph above. I want to
use virtio-net as the transport, I do not want to write my own
virtual-network driver. Can you please clarify?

Hopefully that explains what I'm trying to do. I'd love someone to help
guide me in the right direction here. I want something to fill this need
in mainline. I've been contacted seperately by 10+ people also looking
for a similar solution. I hunch most of them end up doing what I did:
write a quick-and-dirty network driver. I've been working on this for a
year, just to give an idea.

PS - should I create a new thread on the two mailing lists mentioned
above? I don't want to go too far off-topic in an alacrityvm thread. :)

Ira
