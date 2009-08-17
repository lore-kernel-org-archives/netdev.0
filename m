From: Avi Kivity <avi@redhat.com>
Subject: Re: [PATCH v3 3/6] vbus: add a "vbus-proxy" bus model for vbus_driver
 objects
Date: Mon, 17 Aug 2009 17:58:06 +0300
Message-ID: <4A896FFE.5050207@redhat.com>
References: <20090814154125.26116.70709.stgit@dev.haskins.net> <20090814154308.26116.46980.stgit@dev.haskins.net> <20090815103243.GA26749@elte.hu> <4A870964.9090408@codemonkey.ws> <4A8965E0.8050608@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Anthony Liguori <anthony@codemonkey.ws>,
	Ingo Molnar <mingo@elte.hu>,
	Gregory Haskins <ghaskins@novell.com>, kvm@vger.kernel.org,
	alacrityvm-devel@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"Michael S. Tsirkin" <mst@redhat.com>
To: Gregory Haskins <gregory.haskins@gmail.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <4A8965E0.8050608@gmail.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/17/2009 05:14 PM, Gregory Haskins wrote:
> Note: No one has ever proposed to change the virtio-ABI.  In fact, this
> thread in question doesn't even touch virtio, and even the patches that
> I have previously posted to add virtio-capability do it in a backwards
> compatible way
>    

Your patches include venet, which is a direct competitor to virtio-net, 
so it splits the development effort.

> Case in point: Take an upstream kernel and you can modprobe the
> vbus-pcibridge in and virtio devices will work over that transport
> unmodified.
>    

Older kernels don't support it, and Windows doesn't support it.

>>   vbus
>> does things in different ways (paravirtual bus vs. pci for discovery)
>> but I think we're happy with how virtio does things today.
>>
>>      
> Thats fine.  KVM can stick with virtio-pci if it wants.  AlacrityVM will
> support virtio-pci and vbus (with possible convergence with
> virtio-vbus).  If at some point KVM thinks vbus is interesting, I will
> gladly work with getting it integrated into upstream KVM as well.  Until
> then, they can happily coexist without issue between the two projects.
>    

If vbus is to go upstream, it must go via the same path other drivers 
go.  Virtio wasn't merged via the kvm tree and virtio-host won't be either.

I don't have any technical objections to vbus/venet (I had in the past 
re interrupts but I believe you've addressed them), and it appears to 
perform very well.  However I still think we should address virtio's 
shortcomings (as Michael is doing) rather than create a competitor.  We 
have enough external competition, we don't need in-tree competitors.

>> I think the reason vbus gets better performance for networking today is
>> that vbus' backends are in the kernel while virtio's backends are
>> currently in userspace.
>>      
> Well, with all due respect, you also said initially when I announced
> vbus that in-kernel doesn't matter, and tried to make virtio-net run as
> fast as venet from userspace ;)  Given that we never saw those userspace
> patches from you that in fact equaled my performance, I assume you were
> wrong about that statement.

I too thought that if we'd improved the userspace interfaces we'd get 
fast networking without pushing virtio details into the kernels, 
benefiting not just kvm but the Linux community at large.  This might 
still be correct but in fact no one turned up with the patches.  Maybe 
they're impossible to write, hard to write, or uninteresting to write 
for those who are capable of writing them.  As it is, we've given up and 
Michael wrote vhost.

> Perhaps you were wrong about other things too?
>    

I'm pretty sure Anthony doesn't posses a Diploma of Perpetual Omniscience.

>> Since Michael has a functioning in-kernel
>> backend for virtio-net now, I suspect we're weeks (maybe days) away from
>> performance results.  My expectation is that vhost + virtio-net will be
>> as good as venet + vbus.
>>      
> This is not entirely impossible, at least for certain simple benchmarks
> like singleton throughput and latency.

What about more complex benchmarks?  Do you thing vbus+venet has an 
advantage there?

> But if you think that this
> somehow invalidates vbus as a concept, you have missed the point entirely.
>
> vbus is about creating a flexible (e.g. cross hypervisor, and even
> physical system or userspace application) in-kernel IO containers with
> linux.  The "guest" interface represents what I believe to be the ideal
> interface for ease of use, yet maximum performance for
> software-to-software interaction.

Maybe.  But layering venet or vblock on top of it makes it specific to 
hypervisors.  The venet/vblock ABIs are not very interesting for 
user-to-user (and anyway, they could use virtio just as well).

> venet was originally crafted just to validate the approach and test the
> vbus interface.  It ended up being so much faster that virtio-net, that
> people in the vbus community started coding against its ABI.

It ended up being much faster than qemu's host implementation, not the 
virtio ABI.  When asked you've indicated that you don't see any 
deficiencies in the virtio protocol.

> OTOH, Michael's patch is purely targeted at improving virtio-net on kvm,
> and its likewise constrained by various limitations of that decision
> (such as its reliance of the PCI model, and the kvm memory scheme).  The
> tradeoff is that his approach will work in all existing virtio-net kvm
> guests, and is probably significantly less code since he can re-use the
> qemu PCI bus model.
>    

virtio does not depend on PCI and virtio-host does not either.

> Conversely, I am not afraid of requiring a new driver to optimize the
> general PV interface.  In the long term, this will reduce the amount of
> reimplementing the same code over and over, reduce system overhead, and
> it adds new features not previously available (for instance, coalescing
> and prioritizing interrupts).
>    

If it were proven to me a new driver is needed I'd switch too.  So far 
no proof has materialized.

>> If that's the case, then I don't see any
>> reason to adopt vbus unless Greg things there are other compelling
>> features over virtio.
>>      
> Aside from the fact that this is another confusion of the vbus/virtio
> relationship...yes, of course there are compelling features (IMHO) or I
> wouldn't be expending effort ;)  They are at least compelling enough to
> put in AlacrityVM.  If upstream KVM doesn't want them, that's KVMs
> decision and I am fine with that.  Simply never apply my qemu patches to
> qemu-kvm.git, and KVM will be blissfully unaware if vbus is present.  I
> do hope that I can convince the KVM community otherwise, however. :)
>    

If the vbus patches make it into the kernel I see no reason not to 
support them in qemu.  qemu supports dozens if not hundreds of devices, 
one more wouldn't matter.

But there's a lot of work before that can happen; for example you must 
support save/restore/migrate for vbus to be mergable.

-- 
error compiling committee.c: too many arguments to function

