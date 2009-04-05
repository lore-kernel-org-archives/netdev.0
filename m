From: Avi Kivity <avi@redhat.com>
Subject: Re: [RFC PATCH 00/17] virtual-bus
Date: Sun, 05 Apr 2009 13:50:43 +0300
Message-ID: <49D88D03.5090808@redhat.com>
References: <49D469D2020000A100045FA1@lucius.provo.novell.com> <49D473EA020000C700056627@lucius.provo.novell.com> <49D473EA020000C700056627@lucius.provo.novell.com> <49D4CB38.5030205@redhat.com> <49D4DA54.3090401@novell.com> <49D4DE82.5020306@redhat.com> <49D4F97F.6040507@novell.com> <49D5F669.1070502@redhat.com> <49D6240B.4080809@novell.com> <49D62D1C.9030704@redhat.com> <49D6531B.9020708@novell.com>
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
Received: from mx2.redhat.com ([66.187.237.31]:56104 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757008AbZDEKvD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 5 Apr 2009 06:51:03 -0400
In-Reply-To: <49D6531B.9020708@novell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Gregory Haskins wrote:
>> You don't gain simplicity by adding things.
>>     
>
> But you are failing to account for the fact that we still have to add
> something for PCI if we go with something like the in-kernel model.  Its
> nice for the userspace side because a) it was already in qemu, and b) we
> need it for proper guest support.  But we don't presumably have it for
> this new thing, so something has to be created (unless this support is
> somehow already there and I don't know it?)
>   

No, a virtio server in the kernel would know nothing about PCI.  
Userspace would handle the PCI interface and configure the kernel.  That 
way we can reuse the kernel part for lguest and s390.

>> Optimization:
>>
>> Most of PCI (in our context) deals with configuration.  So removing it
>> doesn't optimize anything, unless you're counting hotplugs-per-second
>> or something.
>>     
>
> Most, but not all ;)  (Sorry, you left the window open on that one).
>
> What about IRQ routing?  

That's already in the kernel.

> What if I want to coalesce interrupts to
> minimize injection overhead?  How do I do that in PCI?
>   

It has nothing to do with PCI.  It has to do with the device/guest 
protocol.  And virtio already does that (badly, in the case of network tx).

> How do I route those interrupts in an arbitrarily nested fashion, say,
> to a guest userspace?
>   

That's a guest problem.  kvm delivers an interrupt; if the guest knows 
how to service it in userspace, great.

> What about scale?  What if Herbet decides to implement a 2048 ring MQ
> device ;)  Theres no great way to do that in x86 with PCI, yet I can do
> it in vbus.  (And yes, I know, this is ridiculous..just wanting to get
> you thinking)
>   

I don't see why you can't do 2048 (or even 2049) rings with PCI.  You'd 
point some config space address at a 'ring descriptor table' and that's it.

>> There is be no problem supporting an in-kernel host virtio endpoint
>> with the existing guest/host ABI.  Nothing in the ABI assumes the host
>> endpoint is in userspace.  Nothing in the implementation requires us
>> to move any of the PCI stuff into the kernel.
>>     
> Well, thats not really true.  If the device is a PCI device, there is
> *some* stuff that has to go into the kernel.  Not an ICH model or
> anything, but at least an ability to interact with userspace for
> config-space changes, etc.
>   

Config space changes go to userspace anyway.  You'd need an interface to 
let userspace configure the kernel, but that's true for every device in 
the kernel.  And you don't want to let the guest configure the kernel 
directly, you want userspace to be able to keep control of things.

  

>> To avoid reiterating, please be specific about these advantages.
>>     
> We are both reading the same thread, right?
>   

Using different languages?

  

>> Last time we measured, hypercall overhead was the same as pio
>> overhead.  Both vmx and svm decode pio completely (except for string
>> pio ...)
>>     
> Not on my woodcrests last time I looked, but I'll check again.
>   

On woodcrests too.  See vmx.c:handle_io().

>> True, PCI interrupts suck.  But this was fixed with MSI.  Why fix it
>> again?
>>     
>
> As I stated, I don't like the constraints in place even by MSI (though
> that is definately a step in the right direction).
>   

Which constraints?

>  With vbus I can have a device that has an arbitrary number of shm
> regions (limited by memory, of course), 

So you can with PCI.

> each with an arbitrarily routed
> signal path that is limited by a u64, even on x86.  

There are still only 224 vectors per vcpu.

> Each region can be
> signaled bidirectionally and masked with a simple local memory write. 
> They can be declared on the fly, allowing for the easy expression of
> things like nested devices or or other dynamic resources.  The can be
> routed across various topologies, such as IRQs or posix signals, even
> across multiple hops in a single path.
>
> How do I do that in PCI?
>   

Not what this nesting means.  If I understand the rest, I think you can 
do it.

> What does masking an interrupt look like?  

It's a protocol between the device and the guest.  PCI doesn't specify 
it.  So you can use a bit in shared memory if you like.

> Again, for the nested case?
>   

What's that?

> Interrupt acknowledgment cycles?
>   

Standard for the platform.  Again it's outside the scope of PCI.

>>> One of my primary design objectives with vbus was to a) reduce the
>>> signaling as much as possible, and b) reduce the cost of signaling. 
>>> That is why I do things like use explicit hypercalls, aggregated
>>> interrupts, bidir napi to mitigate signaling, the shm_signal::pending
>>> mitigation, and avoiding going to userspace by running in the kernel.
>>> All of these things together help to form what I envision would be a
>>> maximum performance transport.  Not all of these tricks are
>>> interdependent (for instance, the bidir + full-duplex threading that I
>>> do can be done in userspace too, as discussed).  They are just the
>>> collective design elements that I think we need to make a guest perform
>>> very close to its peak.  That is what I am after.
>>>
>>>   
>>>       
>> None of these require vbus.  They can all be done with PCI.
>>     
> Well, first of all:  Not really.  

Really?  I think every network card+driver do this bidir napi thing.  
napi was invented for real network cards, IIUC.

> Second of all, even if you *could* do
> this all with PCI, its not really PCI anymore.  So the question I have
> is: whats the value in still using it?  For the discovery?  Its not very
> hard to do discovery.  I wrote that whole part in a few hours and it
> worked the first time I ran it.
>   

Yes, for the discovery.  And so it could work on all guests, not just 
Linux 2.6.31+.

> What about that interrupt model I keep talking about?  How do you work
> around that?  How do I nest these to support bypass?
>   

I'm lost, sorry.

>> What constraints?  Please be specific.
>>     
>
> Avi, I have been.  Is this an exercise to see how much you can get me to
> type? ;)
>   

I know I'd lose this, so no.  I'm really puzzled what you think we'd 
gain by departing from PCI (other than having a nice clean code base, 
which I don't think helps because we get to maintain both PCI and the 
new code base).

>> I'm not saying anything about what the advantages are worth and how
>> they compare to the cost.  I'm asking what are the advantages.  Please
>> don't just assert them into existence.
>>     
>
> Thats an unfair statement, Avi.  Now I would say you are playing word-games.
>   

I genuinely don't see them.  I'm not being deliberately stupid.

>> All of this overhead is incurred at configuration time.  All the
>> complexity already exists
>>     
>
> So you already have the ability to represent PCI devices that are in the
> kernel?  Is this the device-assignment infrastructure?  Cool!  Wouldn't
> this still need to be adapted to work with software devices?  If not,
> then I take back the statements that they both add more host code and
> agree that vbus is simply the one adding more.
>   

Of course it would need to be adapted, but nothing in the core.  For 
example, virtio-net.c would need to communicate with its kernel 
counterpart to tell it what it's configuration is, and to start and stop 
it (so we could do live migration).

We wouldn't need to make any changes to hw/pci.c, for example.

It's similar to how the in-kernel lapic and ioapic are integrated with qemu.

>> so we gain nothing by adding a competing implementation.  And making
>> the guest complex in order to simplify the host is a pretty bad
>> tradeoff considering we maintain one host but want to support many
>> guests.
>>
>> It's good to look forward, but in the vbus-dominated universe, what do
>> we have that we don't have now?  Besides simplicity.
>>     
>
> A unified framework for declaring virtual resources directly in the
> kernel, yet still retaining the natural isolation that we get in
> userspace.

That's not an advantage.  "directly in the kernel" doesn't buy the user 
anything.

>   The ability to support guests that don't have PCI.

Already have that.  See lguest and s390.

>   The
> ability to support things that are not guests.

So would a PCI implementation, as long as PCI is only in userspace.

>   The ability to support
> things that are not supported by PCI, like less hardware-centric signal
> path routing.  

What's that?

> The ability to signal across more than just IRQs.  

You can't, either with or without vbus.  You have to honour guest cli.  
You might do a Xen-like alternative implementation of interrupts, but 
that's bound to be slow since you have to access guest stack directly 
and switch stacks instead of letting the hardware do it for you.  And of 
course forget about Windows.

> The
> ability for nesting (e.g. guest-userspace talking to host-kernel, etc). 
>   

That's a guest problem.  If the guest kernel gives guest userspace 
access, guest userspace can have a go too, PCI or not.

In fact, even today guest userspace controls a PCI device - the X server 
runs in userspace and talks to the cirrus PCI device.

> I recognize that this has no bearing on whether you, or anyone else
> cares about these features.  But it certainly has features beyond what
> he have with PCI, and I hope that is clear now.
>   

With the exception of "less hardware-centric signal path routing", which 
I did not understand, I don't think you demonstrated any advantage.

    

>>> Ive already said this is low on my list, but it could always be added if
>>> someone cares that much
>>>   
>>>       
>> That's unreasonable.  Windows is an important workload.
>>     
>
> Well, this is all GPL, right.  I mean, was KVM 100% complete when it was
> proposed?  Accepted?  I am hoping to get some help building the parts of
> this infrastructure from anyone interested in the community.  If Windows
> support is truly important and someone cares, it will get built soon enough.
>
> I pushed it out now because I have enough working to be useful in of
> itself and to get a review.  But its certainly not done.
>   

You are proposing a major break from what we have now.  While you've 
demonstrated very nice performance numbers, it cannot be undertaken lightly.

This is how I see our options:

- continue to develop virtio, taking the performance improvements from venet

IMO this is the best course.  We do what we have to do to get better 
performance, perhaps by implementing a server in the kernel.  The 
Windows drivers continue to work.  Linux 2.6.older+ continue to work.  
Older hosts continue to work (with the userspace virtio 
implementation).  Performance improves.

- drop virtio, switch to vbus

That's probably the worst course.  Windows drivers stop working until 
further notice.  Older hosts stop working.  Older guests stop working.  
The only combination that works is 2.6.31+ on 2.6.31+.

- move virtio to maintenance mode, start developing vbus

Older guests use virtio, older hosts use virtio, if we have a new guest 
on new host we use vbus.  Start porting the Windows drivers to vbus.  
Start porting block drivers and host to vbus.  Same for balloon.

While workable, it increases the maintenance burden significantly as 
well as user confusion.  I don't think we'd be justified in moving in 
this direction unless there was a compelling reason, which I don't see 
right now.
>   
>   
>> Of course we need to.  RHEL 4/5 and their equivalents will live for a
>> long time as guests.  Customers will expect good performance.
>>     
>
> Okay, easy enough from my perspective.  However, I didn't realize it was
> very common to backport new features to enterprise distros like this.  I
> have a sneaking suspicion we wouldn't really need to worry about this as
> the project managers for those products would probably never allow it. 
> But in the event that it was necessary, I think it wouldn't be horrendous.
>   

As it happens, RHEL 5.3 has backported virtio drivers.

    

>>> So does virtio also do demand loading in the backend?  
>>>       
>> Given that it's entirely in userspace, yes.
>>     
>
> Ah, right.  How does that work our of curiosity?  Do you have to do a
> syscall for every page you want to read?
>   

No, you just read or write it through pointers.  Syscalls that access 
userspace work too (like read() or write()).


>>> Hmm.  I suppose
>>> we could do this, but it will definitely affect the performance
>>> somewhat.  I was thinking that the pages needed for the basic shm
>>> components should be minimal, so this is a good tradeoff to vmap them in
>>> and only demand load the payload.
>>>   
>>>       
>> This is negotiable :) I won't insist on it, only strongly recommend
>> it.  copy_to_user() should be pretty fast.
>>     
>
> It probably is, but generally we cant use it since we are not in the
> same context when we need to do the copy (copy_to/from_user assume
> "current" is proper).  

Right.

> Thats ok, there are ways to do what you request
> without explicitly using c_t_u().
>   

How?

If we can't, vmap() is fine.

-- 
error compiling committee.c: too many arguments to function

