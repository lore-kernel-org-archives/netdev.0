From: Avi Kivity <avi@redhat.com>
Subject: Re: [RFC PATCH 00/17] virtual-bus
Date: Fri, 03 Apr 2009 18:37:00 +0300
Message-ID: <49D62D1C.9030704@redhat.com>
References: <49D469D2020000A100045FA1@lucius.provo.novell.com> <49D473EA020000C700056627@lucius.provo.novell.com> <49D473EA020000C700056627@lucius.provo.novell.com> <49D4CB38.5030205@redhat.com> <49D4DA54.3090401@novell.com> <49D4DE82.5020306@redhat.com> <49D4F97F.6040507@novell.com> <49D5F669.1070502@redhat.com> <49D6240B.4080809@novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Patrick Mullaney <pmullaney@novell.com>, anthony@codemonkey.ws,
	andi@firstfloor.org, herbert@gondor.apana.org.au,
	Peter Morreale <PMorreale@novell.com>, rusty@rustcorp.com.au,
	agraf@suse.de, kvm@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Gregory Haskins <ghaskins@novell.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <49D6240B.4080809@novell.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Gregory Haskins wrote:
>> I'll rephrase.  What are the substantial benefits that this offers
>> over PCI?
>>     
>
> Simplicity and optimization.  You don't need most of the junk that comes
> with PCI.  Its all overhead and artificial constraints.  You really only
> need things like a handful of hypercall verbs and thats it.
>
>   

Simplicity:

The guest already supports PCI.  It has to, since it was written to the 
PC platform, and since today it is fashionable to run kernels that 
support both bare metal and a hypervisor.  So you can't remove PCI from 
the guest.

The host also already supports PCI.  It has to, since it must supports 
guests which do not support vbus.  We can't remove PCI from the host.

You don't gain simplicity by adding things.  Sure, lguest is simple 
because it doesn't support PCI.  But Linux will forever support PCI, and 
Qemu will always support PCI.  You aren't simplifying anything by adding 
vbus.

Optimization:

Most of PCI (in our context) deals with configuration.  So removing it 
doesn't optimize anything, unless you're counting hotplugs-per-second or 
something.


>>> Second of all, I want to use vbus for other things that do not speak PCI
>>> natively (like userspace for instance...and if I am gleaning this
>>> correctly, lguest doesnt either).
>>>   
>>>       
>> And virtio supports lguest and s390.  virtio is not PCI specific.
>>     
> I understand that.  We keep getting wrapped around the axle on this
> one.   At some point in the discussion we were talking about supporting
> the existing guest ABI without changing the guest at all.  So while I
> totally understand the virtio can work over various transports, I am
> referring to what would be needed to have existing ABI guests work with
> an in-kernel version.  This may or may not be an actual requirement.
>   

There is be no problem supporting an in-kernel host virtio endpoint with 
the existing guest/host ABI.  Nothing in the ABI assumes the host 
endpoint is in userspace.  Nothing in the implementation requires us to 
move any of the PCI stuff into the kernel.

In fact, we already have in-kernel sources of PCI interrupts, these are 
assigned PCI devices (obviously, these have to use PCI).

>> However, for the PC platform, PCI has distinct advantages.  What
>> advantages does vbus have for the PC platform?
>>     
> To reiterate: IMO simplicity and optimization.  Its designed
> specifically for PV use, which is software to software.
>   

To avoid reiterating, please be specific about these advantages.

>   
>>> PCI sounds good at first, but I believe its a false economy.  It was
>>> designed, of course, to be a hardware solution, so it carries all this
>>> baggage derived from hardware constraints that simply do not exist in a
>>> pure software world and that have to be emulated.  Things like the fixed
>>> length and centrally managed PCI-IDs, 
>>>       
>> Not a problem in practice.
>>     
>
> Perhaps, but its just one more constraint that isn't actually needed. 
> Its like the cvs vs git debate.  Why have it centrally managed when you
> don't technically need it.  Sure, centrally managed works, but I'd
> rather not deal with it if there was a better option.
>   

We've allocated 3 PCI device IDs so far.  It's not a problem.  There are 
enough real problems out there.

>   
>>> PIO config cycles, BARs,
>>> pci-irq-routing, etc.  
>>>       
>> What are the problems with these?
>>     
>
> 1) PIOs are still less efficient to decode than a hypercall vector.  We
> dont need to pretend we are hardware..the guest already knows whats
> underneath them.  Use the most efficient call method.
>   

Last time we measured, hypercall overhead was the same as pio overhead.  
Both vmx and svm decode pio completely (except for string pio ...)

> 2) BARs?  No one in their right mind should use an MMIO BAR for PV. :)
> The last thing we want to do is cause page faults here.  Don't use them,
> period.  (This is where something like the vbus::shm() interface comes in)
>   

So don't use BARs for your fast path.  virtio places the ring in guest 
memory (like most real NICs).

> 3) pci-irq routing was designed to accommodate etch constraints on a
> piece of silicon that doesn't actually exist in kvm.  Why would I want
> to pretend I have PCI A,B,C,D lines that route to a pin on an IOAPIC? 
> Forget all that stuff and just inject an IRQ directly.  This gets much
> better with MSI, I admit, but you hopefully catch my drift now.
>   

True, PCI interrupts suck.  But this was fixed with MSI.  Why fix it again?

> One of my primary design objectives with vbus was to a) reduce the
> signaling as much as possible, and b) reduce the cost of signaling.  
> That is why I do things like use explicit hypercalls, aggregated
> interrupts, bidir napi to mitigate signaling, the shm_signal::pending
> mitigation, and avoiding going to userspace by running in the kernel. 
> All of these things together help to form what I envision would be a
> maximum performance transport.  Not all of these tricks are
> interdependent (for instance, the bidir + full-duplex threading that I
> do can be done in userspace too, as discussed).  They are just the
> collective design elements that I think we need to make a guest perform
> very close to its peak.  That is what I am after.
>
>   

None of these require vbus.  They can all be done with PCI.

> You are right, its not strictly necessary to work.  Its just presents
> the opportunity to optimize as much as possible and to move away from
> legacy constraints that no longer apply.  And since PVs sole purpose is
> about optimization, I was not really interested in going "half-way".
>   

What constraints?  Please be specific.

>>   We need a positive advantage, we don't do things just because we can
>> (and then lose the real advantages PCI has).
>>     
>
> Agreed, but I assert there are advantages.  You may not think they
> outweigh the cost, and thats your prerogative, but I think they are
> still there nonetheless.
>   

I'm not saying anything about what the advantages are worth and how they 
compare to the cost.  I'm asking what are the advantages.  Please don't 
just assert them into existence.

>>> If we insist that PCI is the only interface we can support and we want
>>> to do something, say, in the kernel for instance, we have to have either
>>> something like the ICH model in the kernel (and really all of the pci
>>> chipset models that qemu supports), or a hacky hybrid userspace/kernel
>>> solution.  I think this is what you are advocating, but im sorry. IMO
>>> that's just gross and unecessary gunk.  
>>>       
>> If we go for a kernel solution, a hybrid solution is the best IMO.  I
>> have no idea what's wrong with it.
>>     
>
> Its just that rendering these objects as PCI is overhead that you don't
> technically need.  You only want this backwards compat because you don't
> want to require a new bus-driver in the guest, which is a perfectly
> reasonable position to take.  But that doesn't mean it isn't a
> compromise.  You are trading more complexity and overhead in the host
> for simplicity in the guest.  I am trying to clean up this path for
> looking forward.
>   

All of this overhead is incurred at configuration time.  All the 
complexity already exists so we gain nothing by adding a competing 
implementation.  And making the guest complex in order to simplify the 
host is a pretty bad tradeoff considering we maintain one host but want 
to support many guests.

It's good to look forward, but in the vbus-dominated universe, what do 
we have that we don't have now?  Besides simplicity.

>> The guest would discover and configure the device using normal PCI
>> methods.  Qemu emulates the requests, and configures the kernel part
>> using normal Linux syscalls.  The nice thing is, kvm and the kernel
>> part don't even know about each other, except for a way for hypercalls
>> to reach the device and a way for interrupts to reach kvm.
>>
>>     
>>> Lets stop beating around the
>>> bush and just define the 4-5 hypercall verbs we need and be done with
>>> it.  :)
>>>
>>> FYI: The guest support for this is not really *that* much code IMO.
>>>  
>>>  drivers/vbus/proxy/Makefile      |    2
>>>  drivers/vbus/proxy/kvm.c         |  726 +++++++++++++++++
>>>   
>>>       
>> Does it support device hotplug and hotunplug?
>>     
> Yes, today (use "ln -s" in configfs to map a device to a bus, and the
> guest will see the device immediately)
>   

Neat.

>   
>>   Can vbus interrupts be load balanced by irqbalance?
>>     
>
> Yes (tho support for the .affinity verb on the guests irq-chip is
> currently missing...but the backend support is there)
>
>
>   
>>   Can guest userspace enumerate devices?
>>     
>
> Yes, it presents as a standard LDM device in things like /sys/bus/vbus_proxy
>
>   
>>   Module autoloading support?
>>     
>
> Yes
>
>   

Cool, looks like you have a nice part covered.

>>   pxe booting?
>>     
> No, but this is something I don't think we need for now.  If it was
> really needed it could be added, I suppose.  But there are other
> alternatives already, so I am not putting this high on the priority
> list.  (For instance you can chose to not use vbus, or you can use
> --kernel, etc).
>
>   
>> Plus a port to Windows,
>>     
>
> Ive already said this is low on my list, but it could always be added if
> someone cares that much
>   

That's unreasonable.  Windows is an important workload.

>   
>> enerprise Linux distros based on 2.6.dead
>>     
>
> Thats easy, though there is nothing that says we need to.  This can be a
> 2.6.31ish thing that they pick up next time.
>   

Of course we need to.  RHEL 4/5 and their equivalents will live for a 
long time as guests.  Customers will expect good performance.


>> As a matter of fact, a new bus was developed recently called PCI
>> express.  It uses new slots, new electricals, it's not even a bus
>> (routers + point-to-point links), new everything except that the
>> software model was 1000000000000% compatible with traditional PCI. 
>> That's how much people are afraid of the Windows ABI.
>>     
>
> Come on, Avi.  Now you are being silly.  So should the USB designers
> have tried to make it look like PCI too?  Should the PCI designers have
> tried to make it look like ISA?  :)  Yes, there are advantages to making
> something backwards compatible.  There are also disadvantages to
> maintaining that backwards compatibility.
>   

Most PCI chipsets include an ISA bridge, at least until recently.

> Let me ask you this:  If you had a clean slate and were designing a
> hypervisor and a guest OS from scratch:  What would you make the bus
> look like?
>   

If there were no installed base to cater for, the avi-bus would blow 
anything out of the water.  It would be so shiny and new to make you cry 
in envy.  It would strongly compete with lguest and steal its two users.

Back on earth, there are a hundred gazillion machines with good old x86, 
booting through 1978 era real mode, jumping over the 640K memory barrier 
(est. 1981), running BIOS code which was probably written in the 14th 
century, and sporting a PCI-compatible peripheral bus.

This is not an academic exercise, we're not trying to develop the most 
aesthetically pleasing stack.  We need to be pragmatic so we can provide 
users with real value, not provide outselves with software design 
entertainment (nominally called wanking on lkml, but kvm@ is a kinder, 
gentler list).

>> virtio-net knows nothing about PCI.  If you have a problem with PCI,
>> write virtio-blah for a new bus.
>>     
> Can virtio-net use a different backend other than virtio-pci?  Cool!  I
> will look into that.  Perhaps that is what I need to make this work
> smoothly.
>   

virtio-net (all virtio devices, actually) supports three platforms 
today.  PCI, lguest, and s390.

>> I think you're integrating too tightly with kvm, which is likely to
>> cause problems when kvm evolves.  The way I'd do it is:
>>
>> - drop all mmu integration; instead, have your devices maintain their
>> own slots layout and use copy_to_user()/copy_from_user() (or
>> get_user_pages_fast()).
>>     
>
>   
>> - never use vmap like structures for more than the length of a request
>>     
>
> So does virtio also do demand loading in the backend?  

Given that it's entirely in userspace, yes.

> Hmm.  I suppose
> we could do this, but it will definitely affect the performance
> somewhat.  I was thinking that the pages needed for the basic shm
> components should be minimal, so this is a good tradeoff to vmap them in
> and only demand load the payload.
>   

This is negotiable :) I won't insist on it, only strongly recommend it.  
copy_to_user() should be pretty fast.


>> I think virtio can be used for much of the same things.  There's
>> nothing in virtio that implies guest/host, or pci, or anything else. 
>> It's similar to your shm/signal and ring abstractions except virtio
>> folds them together.  Is this folding the main problem?
>>     
> Right.  Virtio and ioq overlap, and they do so primarily because I
> needed a ring that was compatible with some of my design ideas, yet I
> didnt want to break the virtio ABI without a blessing first.  If the
> signaling was not folded in virtio, that would be a first great step.  I
> am not sure if there would be other areas to address as well.
>   

It would be good to find out.  virtio has evolved in time, mostly 
keeping backwards compatibility, so if you need a feature, it could be 
added.

>> As far as I can tell, everything around it just duplicates existing
>> infrastructure (which may be old and crusty, but so what) without
>> added value.
>>     
>
> I am not sure what you refer to with "everything around it".  Are you
> talking about the vbus core? 
>   

I'm talking about enumeration, hotplug, interrupt routing, all that PCI 
slowpath stuff.  My feeling is the fast path is mostly virtio except for 
being in kernel, and the slow path is totally redundant.


-- 
I have a truly marvellous patch that fixes the bug which this
signature is too narrow to contain.

