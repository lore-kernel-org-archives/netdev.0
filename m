From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 4/7] vbus-proxy: add a pci-to-vbus bridge
Date: Fri, 7 Aug 2009 00:57:54 +0200
Message-ID: <200908070057.54795.arnd@arndb.de>
References: <20090803171030.17268.26962.stgit@dev.haskins.net> <200908061903.05083.arnd@arndb.de> <4A7B0D090200005A00051D2E@sinclair.provo.novell.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: alacrityvm-devel@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"Ira W. Snyder" <iws@ovro.caltech.edu>
To: "Gregory Haskins" <ghaskins@novell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.188]:49707 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756262AbZHFW6C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Aug 2009 18:58:02 -0400
In-Reply-To: <4A7B0D090200005A00051D2E@sinclair.provo.novell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 06 August 2009, Gregory Haskins wrote:
> >>> On 8/6/2009 at  1:03 PM, in message <200908061903.05083.arnd@arndb.de>, Arnd Bergmann <arnd@arndb.de> wrote: 
> Here are some of my arguments against it:
> 
> 1) there is an ample PCI model that is easy to work with when you are in QEMU and using its device model (and you get it for free).  Its the path of least resistance.  For something in kernel, it is more awkward to try to coordinate the in-kernel state with the PCI state.  Afaict, you either need to have it live partially in both places, or you need some PCI emulation in the kernel.

True, if the whole hypervisor is in the host kernel, then doing full PCI emulation would be
insane. I was assuming that all of the setup code still lived in host user space.
What is the reason why it cannot? Do you want to use something other than qemu,
do you think this will impact performance, or something else?

> 2) The signal model for the 1:1 design is not very flexible IMO.
>     2a) I want to be able to allocate dynamic signal paths, not pre-allocate msi-x vectors at dev-add.

I believe msi-x implies that the interrupt vectors get added by the device driver
at run time, unlike legacy interrupts or msi. It's been a while since I dealt with
that though.

>     2b) I also want to collapse multiple interrupts together so as to minimize the context switch rate (inject + EIO overhead).  My design effectively has "NAPI" for interrupt handling.  This helps when the system needs it the most: heavy IO.

That sounds like a very useful concept in general, but this seems to be a
detail of the interrupt controller implementation. If the IO-APIC cannot
do what you want here, maybe we just need a paravirtual IRQ controller
driver, like e.g. the PS3 has.

> 3) The 1:1 model is not buying us much in terms of hotplug.  We don't really "use" PCI very much even in virtio.  Its a thin-shim of uniform dev-ids to resurface to the virtio-bus as something else.  With LDM, hotplug is ridiculously easy anyway, so who cares.  I already need an event channel anyway for (2b) anyway, so the devadd/devdrop events are trivial to handle.

I agree for Linux guests, but when you want to run other guest operating systems,
PCI hotplug is probably the most common interface for this. AFAIK, the windows
virtio-net driver does not at all have a concept of a virtio layer but is simply
a network driver for a PCI card. The same could be applied any other device,
possibly with some library code doing all the queue handling in a common way.l

> 4) communicating with something efficiently in-kernel requires more finesse than basic PIO/MMIO.  There are tricks you can do to get around this, but with 1:1 you would have to do this trick repeatedly for each device.  Even with a library solution to help, you still have per-cpu .data overhead and cpu hotplug overhead to get maximum performance.  With my "bridge" model, I do it once, which I believe is ideal.
>
> 5) 1:1 is going to quickly populate the available MMIO/PIO and IDT slots for any kind of medium to large configuration.  The bridge model scales better in this regard.

We don't need to rely on PIO, it's just the common interface that all hypervisors
can easily support. We could have different underlying methods for the communication
if space or performance becomes a bottleneck because of this.

> So based on that, I think the bridge model works better for vbus.  Perhaps you can convince me otherwise ;)

Being able to define all of it in the host kernel seems to be the major
advantage of your approach, the other points you mentioned are less
important IMHO. The question is whether that is indeed a worthy goal,
or if it should just live in user space as with the qemu PCI code.

> >> In essence, this driver's job is to populate the "vbus-proxy" LDM bus with
> >> objects that it finds across the PCI-OTHER bridge.  This would actually sit
> >> below the virtio components in the stack, so it doesnt make sense (to me) to
> >> turn around and build this on top of virtio.  But perhaps I am missing
> >> something you are seeing.
> >> 
> >> Can you elaborate?
> > 
> > Your PCI device does not serve any real purpose as far as I can tell
> 
> That is certainly debatable.  Its purpose is as follows:
> 
> 1) Allows a guest to discover the vbus feature (fwiw: I used to do this with cpuid)

true, I missed that.

> 2) Allows the guest to establish proper context to communicate with the feature (mmio, pio, and msi) (fwiw: i used to use hypercalls)
> 3) Access the virtual-devices that have been configured for the feature
> 
> Correct me if I am wrong:  Isn't this more of less the exact intent of something like an LDM bus (vbus-proxy) and a PCI-BRIDGE?  Other than the possibility that there might be some mergable overlap (still debatable), I don't think its fair to say that this does not serve a purpose.

I guess you are right on that. An interesting variation of that would be make the
child devices of it virtio devices again though: Instead of the PCI emulation code
in the host kernel, you could define a simpler interface to the same effect. So the
root device would be a virtio-pci device, below which you can have virtio-virtio
devices.

> >, you could just as well have a root device as a parent for all the vbus devices
> > if you do your device probing like this.
> 
> Yes, I suppose the "bridge" could have been advertised as a virtio-based root device.  In this way, the virtio probe() would replace my pci probe() for feature discovery, and a virtqueue could replace my msi+ioq for the eventq channel.
>
> I see a few issues with that, however:
> 
> 1) The virtqueue library, while a perfectly nice ring design at the metadata level, does not have an API that is friendly to kernel-to-kernel communication.  It was designed more for frontend use to some remote backend.  The IOQ library on the other hand, was specifically designed to support use as kernel-to-kernel (see north/south designations).  So this made life easier for me.  To do what you propose, the eventq channel would need to terminate in kernel, and I would thus be forced to deal that the potential API problems.

Well, virtqueues are not that bad for kernel-to-kernel communication, as Ira mentioned
referring to his virtio-over-PCI driver. You can have virtqueues on both sides, having
the host kernel create a pair of virtqueues (one in user aka guest space, one in the host
kernel), with the host virtqueue_ops doing copy_{to,from}_user to move data between them.

If you have that, you can actually use the same virtio_net driver in both guest and
host kernel, just communicating over different virtio implementations. Interestingly,
that would mean that you no longer need a separation between guest and host device
drivers (vbus and vbus-proxy in your case) but could use the same device abstraction
with just different transports to back the shm-signal or virtqueue.
 
> 2) I would need to have Avi et. al. allocate a virtio vector to use from their namespace, which I am sure they wont be willing to do until they accept my design.  Today, I have a nice conflict free PCI ID to use as I see fit.

My impression is the opposite: as long as you try to reinvent everything at once,
you face opposition, but if you just improve parts of the existing design one
by one (like eventfd), I think you will find lots of support.

> Im sure both of these hurdles are not insurmountable, but I am left scratching my head as to why its worth the effort.  It seems to me its a "six of one, half-dozen of the other" kind of scenario.  Either I write a qemu PCI device and pci-bridge driver, or I write a qemu virtio-devicve and virtio root driver.
> 
> In short: What does this buy us, or did you mean something else?  

In my last reply, I was thinking of a root device that can not be probed like a PCI device.

> > However, assuming that you do the IMHO right thing to do probing like
> > virtio with a PCI device for each slave, the code will be almost the same
> > as virtio-pci and the two can be the same.
> 
> Can you elaborate?

Well, let me revise based on the discussion:

The main point that remains is that I think a vbus-proxy should be the same as a
virtio device. This could be done by having (as in my earlier mails) a PCI device
per vbus-proxy, with devcall implemented in PIO or config-space and additional
shm/shm-signal, or it could be a single virtio device from virtio-pci or one
of the other existing provides that connects you with a new virtio provider
sitting in the host kernel. This provider has child devices for any endpoint
(virtio-net, venet, ...) that is implemented in the host kernel.

> >and you go and enumerate the devices on the bridge, creating a vbus_device for each
> > one as you go.
> 
> Thats exactly what it does.
> 
> > Then you just need to match the vbus drivers with the
> > devices by some string or vendor/device ID tuple.
> > 
> 
> Yep, thats right too.  Then, when the driver gets a ->probe(), it does an dev->open() to check various state:
> 
> a) can the device be opened?  if it has an max-open policy (most will have a max-open = 1 policy) and something else already has the device open, it will fail (this will not be common).
> b) is the driver ABI revision compatible with the device ABI revision?  This is like checking the pci config-space revision number.
> 
> For an example, see drivers/net/vbus-enet.c, line 764:
> 
> http://git.kernel.org/?p=linux/kernel/git/ghaskins/alacrityvm/linux-2.6.git;a=blob;f=drivers/net/vbus-enet.c;h=7220f43723adc5b0bece1bc37974fae1b034cd9e;hb=b3b2339efbd4e754b1c85f8bc8f85f21a1a1f509#l764
> 
> Its simple a check to see if the driver and device are compatible, and therefore the probe should succeed.  Nothing more.  I think what I have done is similar to how most buses (like PCI) work today (ala revision number checks with a config-cycle).

ok. 
 
> Regarding the id->handle indirection:
> 
> Internally, the DEVOPEN call translates an "id" to a "handle".  The handle is just a token to help ensure that the caller actually opened the device successfully.  Note that the "id" namespace is 0 based.  Therefore, something like an errant DEVCALL(0) would be indistinguishable from a legit request.  Using the handle abstraction gives me a slightly more robust mechanism to ensure the caller actually meant to call the host, and was in the proper context to do so.  For one thing, if the device had never been opened, this would have failed before it ever reached the model.  Its one more check I can do at the infrastructure level, and one less thing each model has to look out for.
> 
> Is the id->handle translation critical?  No, i'm sure we could live without it, but I also don't think it hurts anything.  It allows the overall code to be slightly more robust, and the individual model code to be slightly less complicated.  Therefore, I don't see a problem.

Right, assuming your model with all vbus devices behind a single PCI device, your
handle does not hurt, it's the equivalent of a bus/dev/fn number or an MMIO address.

	Arnd <><
