From: Avi Kivity <avi@redhat.com>
Subject: Re: [RFC PATCH 00/17] virtual-bus
Date: Sun, 05 Apr 2009 13:00:22 +0300
Message-ID: <49D88136.1090704@redhat.com>
References: <20090331184057.28333.77287.stgit@dev.haskins.net> <87ab71monw.fsf@basil.nowhere.org> <49D35825.3050001@novell.com> <20090401132340.GT11935@one.firstfloor.org> <49D37805.1060301@novell.com> <20090401170103.GU11935@one.firstfloor.org> <49D3B64F.6070703@codemonkey.ws> <49D3D7EE.4080202@novell.com> <49D46089.5040204@redhat.com> <49D497A1.4090900@novell.com> <49D4A4EB.8020105@redhat.com> <49D4AE0C.3000604@novell.com> <49D4B2C0.5060906@redhat.com> <49D4B594.6080703@novell.com> <49D4B8B4.4020003@redhat.com> <49D4BF70.1060301@novell.com> <49D4C191.2070502@redhat.com> <49D4CAA7.3020004@novell.com> <49D4CC61.6010105@redhat.com> <49D4CEB1.9020001@redhat.com> <49D4D075.9010702@codemonkey.ws> <49D4E33F.5000303@codemonkey.ws> <49D5FAFD.1010102@novell.com> <49D5FDF9.7090602@redhat.com> <49D6
 0B91.6010503@novell.com> <49D61100.5010202@redhat.com> <49D6391F.8010408@novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Anthony Liguori <anthony@codemonkey.ws>,
	Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org,
	agraf@suse.de, pmullaney@novell.com, pmorreale@novell.com,
	rusty@rustcorp.com.au, netdev@vger.kernel.org, kvm@vger.kernel.org
To: Gregory Haskins <ghaskins@novell.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <49D6391F.8010408@novell.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Gregory Haskins wrote:
>   
>>> 2) the vbus-proxy and kvm-guest patch go away
>>> 3) the kvm-host patch changes to work with coordination from the
>>> userspace-pci emulation for things like MSI routing
>>> 4) qemu will know to create some MSI shim 1:1 with whatever it
>>> instantiates on the bus (and can communicate changes
>>>   
>>>       
>> Don't userstand.  What's this MSI shim?
>>     
>
> Well, if the device model was an object in vbus down in the kernel, yet
> PCI emulation was up in qemu, presumably we would want something to
> handle things like PCI config-cycles up in userspace.  Like, for
> instance, if the guest re-routes the MSI.  The shim/proxy would handle
> the config-cycle, and then turn around and do an ioctl to the kernel to
> configure the change with the in-kernel device model (or the irq
> infrastructure, as required).
>   

Right, this is how it should work.  All the gunk in userspace.

> But, TBH, I haven't really looked into whats actually required to make
> this work yet.  I am just spitballing to try to find a compromise.
>   

One thing I thought of trying to get this generic is to use file 
descriptors as irq handles.  So:

- userspace exposes a PCI device (same as today)
- guest configures its PCI IRQ (using MSI if it supports it)
- userspace handles this by calling KVM_IRQ_FD which converts the irq to 
a file descriptor
- userspace passes this fd to the kernel, or another userspace process
- end user triggers guest irqs by writing to this fd

We could do the same with hypercalls:

- guest and host userspace negotiate hypercall use through PCI config space
- userspace passes an fd to the kernel
- whenever the guest issues an hypercall, the kernel writes the 
arguments to the fd
- other end (in kernel or userspace) processes the hypercall


> No, you are confusing the front-end and back-end again ;)
>
> The back-end remains, and holds the device models as before.  This is
> the "vbus core".  Today the front-end interacts with the hypervisor to
> render "vbus" specific devices.  The proposal is to eliminate the
> front-end, and have the back end render the objects on the bus as PCI
> devices to the guest.  I am not sure if I can make it work, yet.  It
> needs more thought.
>   

It seems to me this already exists, it's the qemu device model.

The host kernel doesn't need any knowledge of how the devices are 
connected, even if it does implement some of them.

>> .  I don't think you've yet set down what its advantages are.  Being
>> pure and clean doesn't count, unless you rip out PCI from all existing
>> installed hardware and from Windows.
>>     
>
> You are being overly dramatic.  No one has ever said we are talking
> about ripping something out.  In fact, I've explicitly stated that PCI
> can coexist peacefully.    Having more than one bus in a system is
> certainly not without precedent (PCI, scsi, usb, etc).
>
> Rather, PCI is PCI, and will always be.  PCI was designed as a
> software-to-hardware interface.  It works well for its intention.  When
> we do full emulation of guests, we still do PCI so that all that
> software that was designed to work software-to-hardware still continue
> to work, even though technically its now software-to-software.  When we
> do PV, on the other hand, we no longer need to pretend it is
> software-to-hardware.  We can continue to use an interface designed for
> software-to-hardware if we choose, or we can use something else such as
> an interface designed specifically for software-to-software.
>
> As I have stated, PCI was designed with hardware constraints in mind. 
> What if I don't want to be governed by those constraints?  

I'd agree with all this if I actually saw a constraint in PCI.  But I don't.

> What if I
> don't want an interrupt per device (I don't)?   

Don't.  Though I thing you do, even multiple interrupts per device.

> What do I need BARs for
> (I don't)?  

Don't use them.

> Is a PCI PIO address relevant to me (no, hypercalls are more
> direct)?  Etc.  Its crap I dont need.
>   

So use hypercalls.

> All I really need is a way to a) discover and enumerate devices,
> preferably dynamically (hotswap), and b) a way to communicate with those
> devices.  I think you are overstating the the importance that PCI plays
> in (a), and are overstating the complexity associated with doing an
> alternative.  

Given that we have PCI, why would we do an alternative?

It works, it works with Windows, the nasty stuff is in userspace.  Why 
expend effort on an alternative?  Instead make it go faster.

> I think you are understating the level of hackiness
> required to continue to support PCI as we move to new paradigms, like
> in-kernel models.  

The kernel need know nothing about PCI, so I don't see how you work this 
out.

> And I think I have already stated that I can
> establish a higher degree of flexibility, and arguably, performance for
> (b).  

You've stated it, but failed to provide arguments for it.


-- 
error compiling committee.c: too many arguments to function

