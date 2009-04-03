From: Avi Kivity <avi@redhat.com>
Subject: Re: [RFC PATCH 00/17] virtual-bus
Date: Fri, 03 Apr 2009 14:43:37 +0300
Message-ID: <49D5F669.1070502@redhat.com>
References: <49D469D2020000A100045FA1@lucius.provo.novell.com> <49D473EA020000C700056627@lucius.provo.novell.com> <49D473EA020000C700056627@lucius.provo.novell.com> <49D4CB38.5030205@redhat.com> <49D4DA54.3090401@novell.com> <49D4DE82.5020306@redhat.com> <49D4F97F.6040507@novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Patrick Mullaney <pmullaney@novell.com>, anthony@codemonkey.ws,
	andi@firstfloor.org, herbert@gondor.apana.org.au,
	Peter Morreale <PMorreale@novell.com>, rusty@rustcorp.com.au,
	agraf@suse.de, kvm@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Gregory Haskins <ghaskins@novell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:60922 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752141AbZDCLnR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Apr 2009 07:43:17 -0400
In-Reply-To: <49D4F97F.6040507@novell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Gregory Haskins wrote:
>>> Yes, but the important thing to point out is it doesn't *replace*
>>> PCI. It simply an alternative.
>>>   
>>>       
>> Does it offer substantial benefits over PCI?  If not, it's just extra
>> code.
>>     
>
> First of all, do you think I would spend time designing it if I didn't
> think so? :)
>   

I'll rephrase.  What are the substantial benefits that this offers over PCI?

> Second of all, I want to use vbus for other things that do not speak PCI
> natively (like userspace for instance...and if I am gleaning this
> correctly, lguest doesnt either).
>   

And virtio supports lguest and s390.  virtio is not PCI specific.

However, for the PC platform, PCI has distinct advantages.  What 
advantages does vbus have for the PC platform?

> PCI sounds good at first, but I believe its a false economy.  It was
> designed, of course, to be a hardware solution, so it carries all this
> baggage derived from hardware constraints that simply do not exist in a
> pure software world and that have to be emulated.  Things like the fixed
> length and centrally managed PCI-IDs, 

Not a problem in practice.

> PIO config cycles, BARs,
> pci-irq-routing, etc.  

What are the problems with these?

> While emulation of PCI is invaluable for
> executing unmodified guest, its not strictly necessary from a
> paravirtual software perspective...PV software is inherently already
> aware of its context and can therefore use the best mechanism
> appropriate from a broader selection of choices.
>   

It's also not necessary to invent a new bus.  We need a positive 
advantage, we don't do things just because we can (and then lose the 
real advantages PCI has).

> If we insist that PCI is the only interface we can support and we want
> to do something, say, in the kernel for instance, we have to have either
> something like the ICH model in the kernel (and really all of the pci
> chipset models that qemu supports), or a hacky hybrid userspace/kernel
> solution.  I think this is what you are advocating, but im sorry. IMO
> that's just gross and unecessary gunk.  

If we go for a kernel solution, a hybrid solution is the best IMO.  I 
have no idea what's wrong with it.

The guest would discover and configure the device using normal PCI 
methods.  Qemu emulates the requests, and configures the kernel part 
using normal Linux syscalls.  The nice thing is, kvm and the kernel part 
don't even know about each other, except for a way for hypercalls to 
reach the device and a way for interrupts to reach kvm.

> Lets stop beating around the
> bush and just define the 4-5 hypercall verbs we need and be done with
> it.  :)
>
> FYI: The guest support for this is not really *that* much code IMO.
>  
>  drivers/vbus/proxy/Makefile      |    2
>  drivers/vbus/proxy/kvm.c         |  726 +++++++++++++++++
>   

Does it support device hotplug and hotunplug?  Can vbus interrupts be 
load balanced by irqbalance?  Can guest userspace enumerate devices?  
Module autoloading support?  pxe booting?

Plus a port to Windows, enerprise Linux distros based on 2.6.dead, and 
possibly less mainstream OSes.

> and plus, I'll gladly maintain it :)
>
> I mean, its not like new buses do not get defined from time to time. 
> Should the computing industry stop coming up with new bus types because
> they are afraid that the windows ABI only speaks PCI?  No, they just
> develop a new driver for whatever the bus is and be done with it.  This
> is really no different.
>   

As a matter of fact, a new bus was developed recently called PCI 
express.  It uses new slots, new electricals, it's not even a bus 
(routers + point-to-point links), new everything except that the 
software model was 1000000000000% compatible with traditional PCI.  
That's how much people are afraid of the Windows ABI.

>> Note that virtio is not tied to PCI, so "vbus is generic" doesn't count.
>>     
> Well, preserving the existing virtio-net on x86 ABI is tied to PCI,
> which is what I was referring to.  Sorry for the confusion.
>   

virtio-net knows nothing about PCI.  If you have a problem with PCI, 
write virtio-blah for a new bus.  Though I still don't understand why.

  

>> I meant, move the development effort, testing, installed base, Windows
>> drivers.
>>     
>
> Again, I will maintain this feature, and its completely off to the
> side.  Turn it off in the config, or do not enable it in qemu and its
> like it never existed.  Worst case is it gets reverted if you don't like
> it.  Aside from the last few kvm specific patches, the rest is no
> different than the greater linux environment.  E.g. if I update the
> venet driver upstream, its conceptually no different than someone else
> updating e1000, right?
>   

I have no objections to you maintaining vbus, though I'd much prefer if 
we can pool our efforts and cooperate on having one good set of drivers.

I think you're integrating too tightly with kvm, which is likely to 
cause problems when kvm evolves.  The way I'd do it is:

- drop all mmu integration; instead, have your devices maintain their 
own slots layout and use copy_to_user()/copy_from_user() (or 
get_user_pages_fast()).
- never use vmap like structures for more than the length of a request
- for hypercalls, add kvm_register_hypercall_handler()
- for interrupts, see the interrupt routing thingie and have an 
in-kernel version of the KVM_IRQ_LINE ioctl.

This way, the parts that go into kvm know nothing about vbus, you're not 
pinning any memory, and the integration bits can be used for other 
purposes.

  

>> So why add something new?
>>     
>
> I was hoping this was becoming clear by now, but apparently I am doing a
> poor job of articulating things. :(  I think we got bogged down in the
> 802.x performance discussion and lost sight of what we are trying to
> accomplish with the core infrastructure.
>
> So this core vbus infrastructure is for generic, in-kernel IO models. 
> As a first pass, we have implemented a kvm-connector, which lets kvm
> guest kernels have access to the bus.  We also have a userspace
> connector (which I haven't pushed yet due to remaining issues being
> ironed out) which allows userspace applications to interact with the
> devices as well.  As a prototype, we built "venet" to show how it all works.
>
> In the future, we want to use this infrastructure to build IO models for
> various things like high performance fabrics and guest bypass
> technologies, etc.  For instance, guest userspace connections to RDMA
> devices in the kernel, etc.
>   

I think virtio can be used for much of the same things.  There's nothing 
in virtio that implies guest/host, or pci, or anything else.  It's 
similar to your shm/signal and ring abstractions except virtio folds 
them together.  Is this folding the main problem?

As far as I can tell, everything around it just duplicates existing 
infrastructure (which may be old and crusty, but so what) without added 
value.

>>
>> I don't want to develop and support both virtio and vbus.  And I
>> certainly don't want to depend on your customers.
>>     
>
> So don't.  Ill maintain the drivers and the infrastructure.  All we are
> talking here is the possible acceptance of my kvm-connector patches
> *after* the broader LKML community accepts the core infrastructure,
> assuming that happens.
>   

As I mentioned above, I'd much rather we cooperate rather than fragment 
the development effort (and user base).

Regarding kvm-connector, see my more generic suggestion above.  That 
would work for virtio-in-kernel as well.

-- 
I have a truly marvellous patch that fixes the bug which this
signature is too narrow to contain.

