From: Avi Kivity <avi@redhat.com>
Subject: Re: [RFC PATCH 00/17] virtual-bus
Date: Thu, 02 Apr 2009 18:49:22 +0300
Message-ID: <49D4DE82.5020306@redhat.com>
References: <49D469D2020000A100045FA1@lucius.provo.novell.com> <49D473EA020000C700056627@lucius.provo.novell.com> <49D473EA020000C700056627@lucius.provo.novell.com> <49D4CB38.5030205@redhat.com> <49D4DA54.3090401@novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Patrick Mullaney <pmullaney@novell.com>, anthony@codemonkey.ws,
	andi@firstfloor.org, herbert@gondor.apana.org.au,
	Peter Morreale <PMorreale@novell.com>, rusty@rustcorp.com.au,
	agraf@suse.de, kvm@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Gregory Haskins <ghaskins@novell.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753701AbZDBPuV@vger.kernel.org>
In-Reply-To: <49D4DA54.3090401@novell.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Gregory Haskins wrote:
>> vbus (if I understand it right) is a whole package of things:
>>
>> - a way to enumerate, discover, and manage devices
>>     
>
> Yes
>   
>> That part duplicates PCI
>>     
>
> Yes, but the important thing to point out is it doesn't *replace* PCI. 
> It simply an alternative.
>   

Does it offer substantial benefits over PCI?  If not, it's just extra code.

Note that virtio is not tied to PCI, so "vbus is generic" doesn't count.

>> and it would be pretty hard to convince me we need to move to
>> something new
>>     
>
> But thats just it.  You don't *need* to move.  The two can coexist side
> by side peacefully.  "vbus" just ends up being another device that may
> or may not be present, and that may or may not have devices on it.  In
> fact, during all this testing I was booting my guest with "eth0" as
> virtio-net, and "eth1" as venet.  The both worked totally fine and
> harmoniously.  The guest simply discovers if vbus is supported via a
> cpuid feature bit and dynamically adds it if present.
>   

I meant, move the development effort, testing, installed base, Windows 
drivers.

>   
>> .  virtio-pci (a) works,
>>     
> And it will continue to work
>   

So why add something new?

>   
>> (b) works on Windows.
>>     
>
> virtio will continue to work on windows, as well.  And if one of my
> customers wants vbus support on windows and is willing to pay us to
> develop it, we can support *it* there as well.
>   

I don't want to develop and support both virtio and vbus.  And I 
certainly don't want to depend on your customers.

>> - a different way of doing interrupts
>>     
> Yeah, but this is ok.  And I am not against doing that mod we talked
> about earlier where I replace dynirq with a pci shim to represent the
> vbus.  Question about that: does userspace support emulation of MSI
> interrupts?  

Yes, this is new.  See the interrupt routing stuff I mentioned.  It's 
probably only in kvm.git, not even in 2.6.30.

> I would probably prefer it if I could keep the vbus IRQ (or
> IRQs when I support MQ) from being shared.  It seems registering the
> vbus as an MSI device would be more conducive to avoiding this.
>   

I still think you want one MSI per device rather than one MSI per vbus, 
to avoid scaling problems on large guest.  After Herbert's let loose on 
the code, one MSI per queue.


>> - a different ring layout, and splitting notifications from the ring
>>     
> Again, virtio will continue to work.  And if we cannot find a way to
> collapse virtio and ioq together in a way that everyone agrees on, there
> is no harm in having two.  I have no problem saying I will maintain
> IOQ.  There is plenty of precedent for multiple ways to do the same thing.
>   

IMO we should just steal whatever makes ioq better, and credit you in 
some file no one reads.  We get backwards compatibility, Windows 
support, continuity, etc.

>> I don't see the huge win here
>>
>> - placing the host part in the host kernel
>>
>> Nothing vbus-specific here.
>>     
>
> Well, it depends on what you want.  Do you want a implementation that is
> virtio-net, kvm, and pci specific while being hardcoded in?

No.  virtio is already not kvm or pci specific.  Definitely all the pci 
emulation parts will remain in user space.

>   What
> happens when someone wants to access it but doesnt support pci?  What if
> something like lguest wants to use it too?  What if you want
> virtio-block next?  This is one extreme.
>   

It works out well on the guest side, so it can work on the host side.  
We have virtio bindings for pci, s390, and of course lguest.  virtio 
itself is agnostic to all of these.  The main difference from vbus is 
that it's guest-only, but could easily be extended to the host side if 
we break down and do things in the kernel.


-- 
error compiling committee.c: too many arguments to function
