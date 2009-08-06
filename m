From: "Gregory Haskins" <ghaskins@novell.com>
Subject: Re: [PATCH 4/7] vbus-proxy: add a pci-to-vbus bridge
Date: Thu, 06 Aug 2009 15:04:09 -0600
Message-ID: <4A7B0D090200005A00051D2E@sinclair.provo.novell.com>
References: <20090803171030.17268.26962.stgit@dev.haskins.net>
 <200908061642.40614.arnd@arndb.de>
 <4A7AC5BC0200005A00051C2A@sinclair.provo.novell.com>
 <200908061903.05083.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: <alacrityvm-devel@lists.sourceforge.net>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
To: "Arnd Bergmann" <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <200908061903.05083.arnd@arndb.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>> On 8/6/2009 at  1:03 PM, in message <200908061903.05083.arnd@arndb.de>, Arnd
Bergmann <arnd@arndb.de> wrote: 
> On Thursday 06 August 2009, you wrote:
>> >>> On 8/6/2009 at 10:42 AM, in message <200908061642.40614.arnd@arndb.de>, Arnd
>> Bergmann <arnd@arndb.de> wrote: 
>> > On Monday 03 August 2009, Gregory Haskins wrote:
>> >> This patch adds a pci-based driver to interface between the a host VBUS
>> >> and the guest's vbus-proxy bus model.
>> >> 
>> >> Signed-off-by: Gregory Haskins <ghaskins@novell.com>
>> > 
>> > This seems to be duplicating parts of virtio-pci that could be kept
>> > common by extending the virtio code. Layering on top of virtio
>> > would also make it possible to use the same features you add
>> > on top of other transports (e.g. the s390 virtio code) without
>> > adding yet another backend for each of them.
>> 
>> This doesn't make sense to me, but I suspect we are both looking at what 
> this
>> code does differently.  I am under the impression that you may believe that
>> there is one of these objects per vbus device.  Note that this is just a 
> bridge
>> to vbus, so there is only one of these per system with potentially many vbus
>> devices behind it.
> 
> Right, this did not become clear from the posting. For virtio, we discussed
> a model like this in the beginning and then rejected it in favour of a
> "one PCI device per virtio device" model, which I now think is a better
> approach than your pci-to-vbus bridge.

I agree that the 1:1 model may have made sense for QEMU based virtio.  I think you will find it has diminished value here, however.

Here are some of my arguments against it:

1) there is an ample PCI model that is easy to work with when you are in QEMU and using its device model (and you get it for free).  Its the path of least resistance.  For something in kernel, it is more awkward to try to coordinate the in-kernel state with the PCI state.  Afaict, you either need to have it live partially in both places, or you need some PCI emulation in the kernel.

2) The signal model for the 1:1 design is not very flexible IMO.
    2a) I want to be able to allocate dynamic signal paths, not pre-allocate msi-x vectors at dev-add.
    2b) I also want to collapse multiple interrupts together so as to minimize the context switch rate (inject + EIO overhead).  My design effectively has "NAPI" for interrupt handling.  This helps when the system needs it the most: heavy IO.

3) The 1:1 model is not buying us much in terms of hotplug.  We don't really "use" PCI very much even in virtio.  Its a thin-shim of uniform dev-ids to resurface to the virtio-bus as something else.  With LDM, hotplug is ridiculously easy anyway, so who cares.  I already need an event channel anyway for (2b) anyway, so the devadd/devdrop events are trivial to handle.

4) communicating with something efficiently in-kernel requires more finesse than basic PIO/MMIO.  There are tricks you can do to get around this, but with 1:1 you would have to do this trick repeatedly for each device.  Even with a library solution to help, you still have per-cpu .data overhead and cpu hotplug overhead to get maximum performance.  With my "bridge" model, I do it once, which I believe is ideal.

5) 1:1 is going to quickly populate the available MMIO/PIO and IDT slots for any kind of medium to large configuration.  The bridge model scales better in this regard.

So based on that, I think the bridge model works better for vbus.  Perhaps you can convince me otherwise ;)

>  
>> In essence, this driver's job is to populate the "vbus-proxy" LDM bus with
>> objects that it finds across the PCI-OTHER bridge.  This would actually sit
>> below the virtio components in the stack, so it doesnt make sense (to me) to
>> turn around and build this on top of virtio.  But perhaps I am missing
>> something you are seeing.
>> 
>> Can you elaborate?
> 
> Your PCI device does not serve any real purpose as far as I can tell

That is certainly debatable.  Its purpose is as follows:

1) Allows a guest to discover the vbus feature (fwiw: I used to do this with cpuid)
2) Allows the guest to establish proper context to communicate with the feature (mmio, pio, and msi) (fwiw: i used to use hypercalls)
3) Access the virtual-devices that have been configured for the feature

Correct me if I am wrong:  Isn't this more of less the exact intent of something like an LDM bus (vbus-proxy) and a PCI-BRIDGE?  Other than the possibility that there might be some mergable overlap (still debatable), I don't think its fair to say that this does not serve a purpose.

>, you could just as well have a root device as a parent for all the vbus devices
> if you do your device probing like this.

Yes, I suppose the "bridge" could have been advertised as a virtio-based root device.  In this way, the virtio probe() would replace my pci probe() for feature discovery, and a virtqueue could replace my msi+ioq for the eventq channel.

I see a few issues with that, however:

1) The virtqueue library, while a perfectly nice ring design at the metadata level, does not have an API that is friendly to kernel-to-kernel communication.  It was designed more for frontend use to some remote backend.  The IOQ library on the other hand, was specifically designed to support use as kernel-to-kernel (see north/south designations).  So this made life easier for me.  To do what you propose, the eventq channel would need to terminate in kernel, and I would thus be forced to deal that the potential API problems.

2) I would need to have Avi et. al. allocate a virtio vector to use from their namespace, which I am sure they wont be willing to do until they accept my design.  Today, I have a nice conflict free PCI ID to use as I see fit.

Im sure both of these hurdles are not insurmountable, but I am left scratching my head as to why its worth the effort.  It seems to me its a "six of one, half-dozen of the other" kind of scenario.  Either I write a qemu PCI device and pci-bridge driver, or I write a qemu virtio-devicve and virtio root driver.

In short: What does this buy us, or did you mean something else?  

> 
> However, assuming that you do the IMHO right thing to do probing like
> virtio with a PCI device for each slave, the code will be almost the same
> as virtio-pci and the two can be the same.

Can you elaborate?

> 
>> > This seems to add an artificial abstraction that does not make sense
>> > if you stick to the PCI abstraction.
>> 
>> I think there may be confusion about what is going on here.  The 
> "device-open"
>> pertains to a vbus device *beyond* the bridge, not the PCI device (the 
> bridge)
>> itself.  Nor is the vbus device a PCI device.
>> 
>> Whats happening here is somewhat analogous to a PCI config-cycle.  Its
>> a way to open a channel to a device beyond the bridge in _response_ to
>> a probe.
>> 
>> We have a way to enumerate devices present beyond the bridge (this yields
>> a "device-id")  but in order to actually talk to the device, you must first
>> call DEVOPEN(id).  When a device-id is enumerated, it generates a probe()
>> event on vbus-proxy.  The responding driver in question would then turn
>> around and issue the handle = dev->open(VERSION) to see if it is compatible
>> with the device, and to establish a context for further communication.
>> 
>> The reason why DEVOPEN returns a unique handle is to help ensure that the
>> driver has established proper context before allowing other calls.
> 
> So assuming this kind of bus is the right idea (which I think it's not),
> why can't the host assume they are open to start with

Read on..

>and you go and enumerate the devices on the bridge, creating a vbus_device for each
> one as you go.

Thats exactly what it does.

> Then you just need to match the vbus drivers with the
> devices by some string or vendor/device ID tuple.
> 

Yep, thats right too.  Then, when the driver gets a ->probe(), it does an dev->open() to check various state:

a) can the device be opened?  if it has an max-open policy (most will have a max-open = 1 policy) and something else already has the device open, it will fail (this will not be common).
b) is the driver ABI revision compatible with the device ABI revision?  This is like checking the pci config-space revision number.

For an example, see drivers/net/vbus-enet.c, line 764:

http://git.kernel.org/?p=linux/kernel/git/ghaskins/alacrityvm/linux-2.6.git;a=blob;f=drivers/net/vbus-enet.c;h=7220f43723adc5b0bece1bc37974fae1b034cd9e;hb=b3b2339efbd4e754b1c85f8bc8f85f21a1a1f509#l764

Its simple a check to see if the driver and device are compatible, and therefore the probe should succeed.  Nothing more.  I think what I have done is similar to how most buses (like PCI) work today (ala revision number checks with a config-cycle).

Regarding the id->handle indirection:

Internally, the DEVOPEN call translates an "id" to a "handle".  The handle is just a token to help ensure that the caller actually opened the device successfully.  Note that the "id" namespace is 0 based.  Therefore, something like an errant DEVCALL(0) would be indistinguishable from a legit request.  Using the handle abstraction gives me a slightly more robust mechanism to ensure the caller actually meant to call the host, and was in the proper context to do so.  For one thing, if the device had never been opened, this would have failed before it ever reached the model.  Its one more check I can do at the infrastructure level, and one less thing each model has to look out for.

Is the id->handle translation critical?  No, i'm sure we could live without it, but I also don't think it hurts anything.  It allows the overall code to be slightly more robust, and the individual model code to be slightly less complicated.  Therefore, I don't see a problem.

>> > 
>> > This could be implemented by virtio devices as well, right?
>> 
>> The big difference with dev->shm() is that it is not bound to
>> a particular ABI within the shared-memory (as opposed to
>> virtio, which assumes a virtio ABI).  This just creates a
>> n empty shared-memory region (with a bidirectional signaling
>> path) which you can overlay a variety of structures (virtio
>> included).  You can of course also use non-ring based
>> structures, such as, say, an array of idempotent state.
>>
>> The point is that, once this is done, you have a shared-memory
>> region and a way (via the shm-signal) to bidirectionally signal
>> changes to that memory region.  You can then build bigger
>> things with it, like virtqueues.
> 
> Let me try to rephrase my point: I believe you can implement
> the shm/ioq data transport on top of the virtio bus level, by
> adding shm and signal functions to struct virtio_config_ops
> alongside find_vqs() so that a virtio_device can have either
> any combination of virtqueues, shm and ioq.

Yes, I believe this might be doable, but I don't know virtio well enough to say for sure.

> 
>> > static int
>> > vbus_pci_device_call(struct vbus_device_proxy *vdev, u32 func, void *data,
>> > 		     size_t len, int flags)
>> > {
>> > 	struct vbus_pci_device *dev = to_dev(vdev);
>> > 	struct vbus_pci_hypercall params = {
>> > 		.vector = func,
>> > 		.len    = len,
>> > 		.datap  = __pa(data),
>> > 	};
>> > 	spin_lock_irqsave(&dev.lock, flags);
>> > 	memcpy_toio(&dev.regs->hypercall.data, &params, sizeof(params));
>> > 	ret = ioread32(&dev.regs->hypercall.result);
>> > 	spin_unlock_irqrestore(&dev.lock, flags);
>> > 
>> > 	return ret;
>> > }
>> > 
>> > This gets rid of your 'handle' and the unwinding through an extra pointer
>> > indirection. You just need to make sure that the device specific call 
>> > numbers
>> > don't conflict with any global ones.
>> 
>> Ah, now I see the confusion...
>> 
>> DEVCALL is sending a synchronous call to a specific device beyond the 
> bridge.  The MMIO going on here against dev.regs->hypercall.data is sending a 
> synchronous call to the bridge itself.  They are distinctly different ;)
> 
> well, my point earlier was that they probably should not be different  ;-)

Ok :)

I still do not see how they could be merged in a way that is both a) worth the effort, and b) doesn't compromise my design.  But I will keep an open mind if you want to continue the conversation.

Thanks for all the feedback.  I do appreciate it.

Kind Regards,
-Greg

