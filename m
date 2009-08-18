From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v3 3/6] vbus: add a "vbus-proxy" bus model for
	vbus_driver objects
Date: Tue, 18 Aug 2009 19:25:14 +0300
Message-ID: <20090818162514.GA19846@redhat.com>
References: <20090814154125.26116.70709.stgit@dev.haskins.net> <20090814154308.26116.46980.stgit@dev.haskins.net> <20090815103243.GA26749@elte.hu> <4A870964.9090408@codemonkey.ws> <4A8965E0.8050608@gmail.com> <20090817174142.GA11140@redhat.com> <4A89BAC5.9040400@gmail.com> <20090818084606.GA13878@redhat.com> <4A8AC68C.6040308@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Anthony Liguori <anthony@codemonkey.ws>,
	Ingo Molnar <mingo@elte.hu>, kvm@vger.kernel.org,
	Avi Kivity <avi@redhat.com>,
	alacrityvm-devel@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Gregory Haskins <gregory.haskins@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759262AbZHRQ1G@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4A8AC68C.6040308@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 18, 2009 at 11:19:40AM -0400, Gregory Haskins wrote:
> >>>> OTOH, Michael's patch is purely targeted at improving virtio-net on kvm,
> >>>> and its likewise constrained by various limitations of that decision
> >>>> (such as its reliance of the PCI model, and the kvm memory scheme).
> >>> vhost is actually not related to PCI in any way. It simply leaves all
> >>> setup for userspace to do.  And the memory scheme was intentionally
> >>> separated from kvm so that it can easily support e.g. lguest.
> >>>
> >> I think you have missed my point. I mean that vhost requires a separate
> >> bus-model (ala qemu-pci).
> > 
> > So? That can be in userspace, and can be anything including vbus.
> 
> -ENOPARSE
> 
> Can you elaborate?

Write a device that signals an eventfd on virtio kick, and poll eventfd
for notifications, and you can use vhost-net.  vbus, surely, can do
this?

> > 
> >> And no, your memory scheme is not separated,
> >> at least, not very well.  It still assumes memory-regions and
> >> copy_to_user(), which is very kvm-esque.
> > 
> > I don't think so: works for lguest, kvm, UML and containers
> 
> kvm _esque_ , meaning anything that follows the region+copy_to_user
> model.  Not all things do.

Pretty much all things where it makes sense to share code with
vhost-net.  If there's hardware that wants direct access to descriptor
rings, it just needs a driver.

> >> Vbus has people using things
> >> like userspace containers (no regions),
> > 
> > vhost by default works without regions
> 
> Thats a start, but not good enough if you were trying to achieve the
> same thing as vbus.  As I said before, I've never said you had to
> achieve the same thing, but do note they are distinctly different with
> different goals.  You are solving a directed problem.  I am solving a
> general problem, and trying to solve it once.

Heh. A good demonstration of vbus generality would be a solution that
speeds up virtio in guests.  What venet seems to illustrate instead is
that one has to rework all of host, guest and hypervisor to use vbus.
Maybe it does not need to be that way - it just seems so.

> >> and physical hardware (dma
> >> controllers, so no regions or copy_to_user) so your scheme quickly falls
> >> apart once you get away from KVM.
> > 
> > Someone took a driver and is building hardware for it ... so what?
> 
> What is your point?

OK, can we forget about that physical hardware then?

> >> Don't get me wrong:  That design may have its place.  Perhaps you only
> >> care about fixing KVM, which is a perfectly acceptable strategy.
> >> Its just not a strategy that I think is the best approach.  Essentially you
> >> are promoting the proliferation of competing backends, and I am trying
> >> to unify them (which is ironic that this thread started with concerns I
> >> was fragmenting things ;).
> > 
> > So, you don't see how venet fragments things? It's pretty obvious ...
> 
> I never said it doesn't.  venet started as a test harness, but now it is
> inadvertently fragmenting the virtio-net effort.  I admit it.  It wasn't
> intentional, but just worked out that way.  Until your vhost idea is
> vetted and benchmarked, its not even in the running.
>
> Venet is currently
> the highest performing 802.x acceleration for KVM that I am aware of, so
> it will continue to garner interest from users concerned with performance.
> 
> But likewise, vhost has the potential to fragment the back-end model.
> That was my point.

You don't see the difference? Long term vhost-net can just be enabled by
default whenever it is present, and there is a single guest driver to
support. OTOH, venet means that we have to support 2 guest drivers:
virtio and venet, for a long time.

> > 
> >> The bottom line is, you have a simpler solution that is more finely
> >> targeted at KVM and virtio-networking.  It fixes probably a lot of
> >> problems with the existing implementation, but it still has limitations.
> >>
> >> OTOH, what I am promoting is more complex, but more flexible.  That is
> >> the tradeoff.  You can't have both ;)
> > 
> > We can. connect eventfds to hypercalls, and vhost will work with vbus.
> 
> -ENOPARSE
> 
> vbus doesnt use hypercalls, and I do not see why or how you would
> connect two backend models together like this.  Can you elaborate.

I think some older version did. But whatever. signal eventfd on guest
kick, poll eventfd to notify guest, and you can use vhost-net with vbus.

> > 
> >> So do not for one second think
> >> that what you implemented is equivalent, because they are not.
> >>
> >> In fact, I believe I warned you about this potential problem when you
> >> decided to implement your own version.  I think I said something to the
> >> effect of "you will either have a subset of functionality, or you will
> >> ultimately reinvent what I did".  Right now you are in the subset phase.
> > 
> > No. Unlike vbus, vhost supports unmodified guests and live migration.
> 
> By "subset", I am referring to your interfaces and the scope of its
> applicability.  The things you need to do to make vhost work and a vbus
> device work from a memory and signaling abstration POV are going to be
> extremely similar.
> 
> The difference in how the guest sees them these backends is all
> contained in the vbus-connector.  Therefore, what you *could* have done
> is simply written a connector that  does something like only support
> "virtio" backends, and surfaced them as regular PCI devices to the
> guest.  Then you could have reused all the abstraction features in vbus,
> instead of reinventing them (case in point, your region+copy_to_user
> code).  And likewise, anyone using vbus could use your virtio-net backend.
> 
> Instead, I am still left with no virtio-net backend implemented, and you
> were left designing, writing, and testing facilities that I've already
> completed.  So it was duplicative effort.
> 
> Kind Regards,
> -Greg
> 

As I said, I couldn't reuse your code the way it's written.  But happily
you can reuse vhost - it's just a library, link with it - or even vhost
net as I explained above.

-- 
MST
