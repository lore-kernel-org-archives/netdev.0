From: "Gregory Haskins" <ghaskins@novell.com>
Subject: Re: [PATCH 4/7] vbus-proxy: add a pci-to-vbus bridge
Date: Thu, 06 Aug 2009 22:42:00 -0600
Message-ID: <4A7B78580200005A00051D50@sinclair.provo.novell.com>
References: <20090803171030.17268.26962.stgit@dev.haskins.net>
 <200908061903.05083.arnd@arndb.de>
 <4A7B0D090200005A00051D2E@sinclair.provo.novell.com>
 <200908070057.54795.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: <alacrityvm-devel@lists.sourceforge.net>,
	"Ira W. Snyder" <iws@ovro.caltech.edu>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
To: "Arnd Bergmann" <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <200908070057.54795.arnd@arndb.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>> On 8/6/2009 at  6:57 PM, in message <200908070057.54795.arnd@arndb.de>, Arnd
Bergmann <arnd@arndb.de> wrote: 
> On Thursday 06 August 2009, Gregory Haskins wrote:
>> >>> On 8/6/2009 at  1:03 PM, in message <200908061903.05083.arnd@arndb.de>, Arnd 
> Bergmann <arnd@arndb.de> wrote: 
>> Here are some of my arguments against it:
>> 
>> 1) there is an ample PCI model that is easy to work with when you are in 
> QEMU and using its device model (and you get it for free).  Its the path of 
> least resistance.  For something in kernel, it is more awkward to try to 
> coordinate the in-kernel state with the PCI state.  Afaict, you either need to 
> have it live partially in both places, or you need some PCI emulation in the 
> kernel.
> 
> True, if the whole hypervisor is in the host kernel, then doing full PCI 
> emulation would be
> insane.

In this case, the entire bus is more or less self contained and in-kernel.  We technically *do* still have qemu present, however, so you are right there.

> I was assuming that all of the setup code still lived in host user 
> space.

Very little.  Just enough to register the PCI device, handle the MMIO/PIO/MSI configuration, etc.  All the bus management uses the standard vbus management interface (configfs/sysfs)

> What is the reason why it cannot?

Its not that it "can't" per se..  Its just awkward to have it live in two places, and I would need to coordinate in-kernel changes to userspace, etc.  Today I do not need to do this:  i.e. the model in userspace is very simple.

> Do you want to use something other than qemu,

Well, only in the sense that vbus has its own management interface and bus model, and I want them to be used.

> do you think this will impact performance, or something else?

performance is not a concern for this aspect of operation.

> 
>> 2) The signal model for the 1:1 design is not very flexible IMO.
>>     2a) I want to be able to allocate dynamic signal paths, not pre-allocate 
> msi-x vectors at dev-add.
> 
> I believe msi-x implies that the interrupt vectors get added by the device 
> driver
> at run time, unlike legacy interrupts or msi. It's been a while since I 
> dealt with
> that though.

Yeah, its been a while for me too.  I would have to look at the spec again.

My understanding was that its just a slight variation of msi, with some of the constraints revised (no <= 32 vector limit, etc).  Perhaps it is fancier than that and 2a is unfounded.  TBD.

> 
>>     2b) I also want to collapse multiple interrupts together so as to 
> minimize the context switch rate (inject + EIO overhead).  My design 
> effectively has "NAPI" for interrupt handling.  This helps when the system 
> needs it the most: heavy IO.
> 
> That sounds like a very useful concept in general, but this seems to be a
> detail of the interrupt controller implementation. If the IO-APIC cannot
> do what you want here, maybe we just need a paravirtual IRQ controller
> driver, like e.g. the PS3 has.

Yeah, I agree this could be a function of the APIC code.  Do note that I mentioned this in passing to Avi a few months ago but FWIW he indicated at that time that he is not interested in making the APIC PV.

Also, I almost forgot an important one.  Add:

   2c) Interrupt prioritization.  I want to be able to assign priority to interrupts and handle them in priority order.

> 
>> 3) The 1:1 model is not buying us much in terms of hotplug.  We don't really 
> "use" PCI very much even in virtio.  Its a thin-shim of uniform dev-ids to 
> resurface to the virtio-bus as something else.  With LDM, hotplug is 
> ridiculously easy anyway, so who cares.  I already need an event channel 
> anyway for (2b) anyway, so the devadd/devdrop events are trivial to handle.
> 
> I agree for Linux guests, but when you want to run other guest operating 
> systems,
> PCI hotplug is probably the most common interface for this. AFAIK, the 
> windows
> virtio-net driver does not at all have a concept of a virtio layer but is 
> simply
> a network driver for a PCI card. The same could be applied any other device,
> possibly with some library code doing all the queue handling in a common 
> way.l

I was told it also has a layering like Linux, but I haven't actually seen the code myself, so I do not know if this is true.

> 
>> 4) communicating with something efficiently in-kernel requires more finesse 
> than basic PIO/MMIO.  There are tricks you can do to get around this, but 
> with 1:1 you would have to do this trick repeatedly for each device.  Even 
> with a library solution to help, you still have per-cpu .data overhead and cpu 
> hotplug overhead to get maximum performance.  With my "bridge" model, I do it 
> once, which I believe is ideal.
>>
>> 5) 1:1 is going to quickly populate the available MMIO/PIO and IDT slots for 
> any kind of medium to large configuration.  The bridge model scales better in 
> this regard.
> 
> We don't need to rely on PIO, it's just the common interface that all 
> hypervisors
> can easily support. We could have different underlying methods for the 
> communication
> if space or performance becomes a bottleneck because of this.

Heh...I already proposed an alternative, which incidentally was shot down:

http://lkml.org/lkml/2009/5/5/132

(in the end, I think we agreed that a technique of tunneling PIO/MMIO over hypercaills would be better than introducing a new namespace.  But we also decided that the difference between PIO and PIOoHC was too small to care, and we don't care about non-x86)

But in any case, my comment still stands: 1:1 puts load on the PIO emulation (even if you use PIOoHC).  I am not sure this can be easily worked around.

> 
>> So based on that, I think the bridge model works better for vbus.  Perhaps 
> you can convince me otherwise ;)
> 
> Being able to define all of it in the host kernel seems to be the major
> advantage of your approach, the other points you mentioned are less
> important IMHO. The question is whether that is indeed a worthy goal,
> or if it should just live in user space as with the qemu PCI code.

I don't think we can gloss over these so easily.  They are all important to me, particularly 2b and 2c.

> 
>> >> In essence, this driver's job is to populate the "vbus-proxy" LDM bus with
>> >> objects that it finds across the PCI-OTHER bridge.  This would actually sit
>> >> below the virtio components in the stack, so it doesnt make sense (to me) 
> to
>> >> turn around and build this on top of virtio.  But perhaps I am missing
>> >> something you are seeing.
>> >> 
>> >> Can you elaborate?
>> > 
>> > Your PCI device does not serve any real purpose as far as I can tell
>> 
>> That is certainly debatable.  Its purpose is as follows:
>> 
>> 1) Allows a guest to discover the vbus feature (fwiw: I used to do this with 
> cpuid)
> 
> true, I missed that.
> 
>> 2) Allows the guest to establish proper context to communicate with the 
> feature (mmio, pio, and msi) (fwiw: i used to use hypercalls)
>> 3) Access the virtual-devices that have been configured for the feature
>> 
>> Correct me if I am wrong:  Isn't this more of less the exact intent of 
> something like an LDM bus (vbus-proxy) and a PCI-BRIDGE?  Other than the 
> possibility that there might be some mergable overlap (still debatable), I 
> don't think its fair to say that this does not serve a purpose.
> 
> I guess you are right on that. An interesting variation of that would be 
> make the
> child devices of it virtio devices again though: Instead of the PCI 
> emulation code
> in the host kernel, you could define a simpler interface to the same effect. 
> So the
> root device would be a virtio-pci device, below which you can have 
> virtio-virtio
> devices.

Interesting....but note I think that is effectively what I do today (with virtio-vbus) except you wouldn't have the explicit vbus-proxy model underneath.  Also, if 1:1 via PCI is important for windows, that solution would have the same problem that the virtio-vbus model does.


> 
>> >, you could just as well have a root device as a parent for all the vbus 
> devices
>> > if you do your device probing like this.
>> 
>> Yes, I suppose the "bridge" could have been advertised as a virtio-based root 
> device.  In this way, the virtio probe() would replace my pci probe() for 
> feature discovery, and a virtqueue could replace my msi+ioq for the eventq 
> channel.
>>
>> I see a few issues with that, however:
>> 
>> 1) The virtqueue library, while a perfectly nice ring design at the metadata 
> level, does not have an API that is friendly to kernel-to-kernel communication. 
>  It was designed more for frontend use to some remote backend.  The IOQ 
> library on the other hand, was specifically designed to support use as 
> kernel-to-kernel (see north/south designations).  So this made life easier 
> for me.  To do what you propose, the eventq channel would need to terminate 
> in kernel, and I would thus be forced to deal that the potential API 
> problems.
> 
> Well, virtqueues are not that bad for kernel-to-kernel communication, as Ira 
> mentioned
> referring to his virtio-over-PCI driver. You can have virtqueues on both 
> sides, having
> the host kernel create a pair of virtqueues (one in user aka guest space, 
> one in the host
> kernel), with the host virtqueue_ops doing copy_{to,from}_user to move data 
> between them.

Its been a while since I looked, so perhaps I am wrong here.  I will look again.

> 
> If you have that, you can actually use the same virtio_net driver in both 
> guest and
> host kernel, just communicating over different virtio implementations. 
> Interestingly,
> that would mean that you no longer need a separation between guest and host 
> device
> drivers (vbus and vbus-proxy in your case) but could use the same device 
> abstraction
> with just different transports to back the shm-signal or virtqueue.

Actually, I think there are some problems with that model (such as management of the interface).  virtio-net really wants to connect to a virtio-net-backend (such as the one in qemu or vbus).  It wasn't designed to connect back to back like that.  I think you will quickly run into problems similar to what Ira faced with virtio-over-PCI with that model.

>  
>> 2) I would need to have Avi et. al. allocate a virtio vector to use from 
> their namespace, which I am sure they wont be willing to do until they accept 
> my design.  Today, I have a nice conflict free PCI ID to use as I see fit.
> 
> My impression is the opposite: as long as you try to reinvent everything at 
> once,
> you face opposition, but if you just improve parts of the existing design 
> one
> by one (like eventfd), I think you will find lots of support.
> 
>> Im sure both of these hurdles are not insurmountable, but I am left 
> scratching my head as to why its worth the effort.  It seems to me its a "six 
> of one, half-dozen of the other" kind of scenario.  Either I write a qemu PCI 
> device and pci-bridge driver, or I write a qemu virtio-devicve and virtio root 
> driver.
>> 
>> In short: What does this buy us, or did you mean something else?  
> 
> In my last reply, I was thinking of a root device that can not be probed 
> like a PCI device.

IIUC, because you missed the "feature discovery" function of the bridge, you thought this was possible but now see it is problematic?  Or are you saying that this concept is still valid and should be considered?  I think its the former, but wanted to be sure we were on the same page.

> 
>> > However, assuming that you do the IMHO right thing to do probing like
>> > virtio with a PCI device for each slave, the code will be almost the same
>> > as virtio-pci and the two can be the same.
>> 
>> Can you elaborate?
> 
> Well, let me revise based on the discussion:
> 
> The main point that remains is that I think a vbus-proxy should be the same 
> as a
> virtio device. This could be done by having (as in my earlier mails) a PCI 
> device
> per vbus-proxy, with devcall implemented in PIO or config-space and additional
> shm/shm-signal,

So the problem with this model is the points I made earlier (such as 2b, 2c).

I do agree with you that the *lack* of this model may be problematic for Windows, depending on the answer w.r.t. what the windows drivers look like.

> or it could be a single virtio device from virtio-pci or one
> of the other existing provides that connects you with a new virtio provider
> sitting in the host kernel. This provider has child devices for any endpoint
> (virtio-net, venet, ...) that is implemented in the host kernel.

This is an interesting idea, but I think it also has problems.

What we do get with having the explicit vbus-proxy exposed in the stack (aside from being able to support "vbus native" drivers, like venet) is a neat way to map vbus-isms into virtio-isms.  For instance, vbus uses a string-based device id, and virtio uses a PCI-ID.  Using this as an intermediate layer allows the "virtio" vbus-id to know that we issue dev->call(GETID) to obtain the PCI-ID value of this virtio-device, and we should publish this result to virtio-bus.

Without this intermediate layer, the vbus identity scheme would have to be compatible with virtio PCI-ID based scheme, and I think this is suboptimal for the overall design of vbus.

[snip]

>  
>> Regarding the id->handle indirection:
>> 
>> Internally, the DEVOPEN call translates an "id" to a "handle".  The handle 
> is just a token to help ensure that the caller actually opened the device 
> successfully.  Note that the "id" namespace is 0 based.  Therefore, something 
> like an errant DEVCALL(0) would be indistinguishable from a legit request.  
> Using the handle abstraction gives me a slightly more robust mechanism to 
> ensure the caller actually meant to call the host, and was in the proper 
> context to do so.  For one thing, if the device had never been opened, this 
> would have failed before it ever reached the model.  Its one more check I can 
> do at the infrastructure level, and one less thing each model has to look out 
> for.
>> 
>> Is the id->handle translation critical?  No, i'm sure we could live without 
> it, but I also don't think it hurts anything.  It allows the overall code to 
> be slightly more robust, and the individual model code to be slightly less 
> complicated.  Therefore, I don't see a problem.
> 
> Right, assuming your model with all vbus devices behind a single PCI device, 
> your
> handle does not hurt, it's the equivalent of a bus/dev/fn number or an MMIO 
> address.

Agreed

Thanks Arnd,
-Greg

