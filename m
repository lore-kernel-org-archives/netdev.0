From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 4/7] vbus-proxy: add a pci-to-vbus bridge
Date: Thu, 6 Aug 2009 19:03:04 +0200
Message-ID: <200908061903.05083.arnd@arndb.de>
References: <20090803171030.17268.26962.stgit@dev.haskins.net> <200908061642.40614.arnd@arndb.de> <4A7AC5BC0200005A00051C2A@sinclair.provo.novell.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: alacrityvm-devel@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: "Gregory Haskins" <ghaskins@novell.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756276AbZHFRD2@vger.kernel.org>
In-Reply-To: <4A7AC5BC0200005A00051C2A@sinclair.provo.novell.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 06 August 2009, you wrote:
> >>> On 8/6/2009 at 10:42 AM, in message <200908061642.40614.arnd@arndb.de>, Arnd
> Bergmann <arnd@arndb.de> wrote: 
> > On Monday 03 August 2009, Gregory Haskins wrote:
> >> This patch adds a pci-based driver to interface between the a host VBUS
> >> and the guest's vbus-proxy bus model.
> >> 
> >> Signed-off-by: Gregory Haskins <ghaskins@novell.com>
> > 
> > This seems to be duplicating parts of virtio-pci that could be kept
> > common by extending the virtio code. Layering on top of virtio
> > would also make it possible to use the same features you add
> > on top of other transports (e.g. the s390 virtio code) without
> > adding yet another backend for each of them.
> 
> This doesn't make sense to me, but I suspect we are both looking at what this
> code does differently.  I am under the impression that you may believe that
> there is one of these objects per vbus device.  Note that this is just a bridge
> to vbus, so there is only one of these per system with potentially many vbus
> devices behind it.

Right, this did not become clear from the posting. For virtio, we discussed
a model like this in the beginning and then rejected it in favour of a
"one PCI device per virtio device" model, which I now think is a better
approach than your pci-to-vbus bridge.
 
> In essence, this driver's job is to populate the "vbus-proxy" LDM bus with
> objects that it finds across the PCI-OTHER bridge.  This would actually sit
> below the virtio components in the stack, so it doesnt make sense (to me) to
> turn around and build this on top of virtio.  But perhaps I am missing
> something you are seeing.
> 
> Can you elaborate?

Your PCI device does not serve any real purpose as far as I can tell, you
could just as well have a root device as a parent for all the vbus devices
if you do your device probing like this.

However, assuming that you do the IMHO right thing to do probing like
virtio with a PCI device for each slave, the code will be almost the same
as virtio-pci and the two can be the same.

> > This seems to add an artificial abstraction that does not make sense
> > if you stick to the PCI abstraction.
> 
> I think there may be confusion about what is going on here.  The "device-open"
> pertains to a vbus device *beyond* the bridge, not the PCI device (the bridge)
> itself.  Nor is the vbus device a PCI device.
> 
> Whats happening here is somewhat analogous to a PCI config-cycle.  Its
> a way to open a channel to a device beyond the bridge in _response_ to
> a probe.
> 
> We have a way to enumerate devices present beyond the bridge (this yields
> a "device-id")  but in order to actually talk to the device, you must first
> call DEVOPEN(id).  When a device-id is enumerated, it generates a probe()
> event on vbus-proxy.  The responding driver in question would then turn
> around and issue the handle = dev->open(VERSION) to see if it is compatible
> with the device, and to establish a context for further communication.
> 
> The reason why DEVOPEN returns a unique handle is to help ensure that the
> driver has established proper context before allowing other calls.

So assuming this kind of bus is the right idea (which I think it's not),
why can't the host assume they are open to start with and you go and
enumerate the devices on the bridge, creating a vbus_device for each
one as you go. Then you just need to match the vbus drivers with the
devices by some string or vendor/device ID tuple.

> > 
> > This could be implemented by virtio devices as well, right?
> 
> The big difference with dev->shm() is that it is not bound to
> a particular ABI within the shared-memory (as opposed to
> virtio, which assumes a virtio ABI).  This just creates a
> n empty shared-memory region (with a bidirectional signaling
> path) which you can overlay a variety of structures (virtio
> included).  You can of course also use non-ring based
> structures, such as, say, an array of idempotent state.
>
> The point is that, once this is done, you have a shared-memory
> region and a way (via the shm-signal) to bidirectionally signal
> changes to that memory region.  You can then build bigger
> things with it, like virtqueues.

Let me try to rephrase my point: I believe you can implement
the shm/ioq data transport on top of the virtio bus level, by
adding shm and signal functions to struct virtio_config_ops
alongside find_vqs() so that a virtio_device can have either
any combination of virtqueues, shm and ioq.

> > static int
> > vbus_pci_device_call(struct vbus_device_proxy *vdev, u32 func, void *data,
> > 		     size_t len, int flags)
> > {
> > 	struct vbus_pci_device *dev = to_dev(vdev);
> > 	struct vbus_pci_hypercall params = {
> > 		.vector = func,
> > 		.len    = len,
> > 		.datap  = __pa(data),
> > 	};
> > 	spin_lock_irqsave(&dev.lock, flags);
> > 	memcpy_toio(&dev.regs->hypercall.data, &params, sizeof(params));
> > 	ret = ioread32(&dev.regs->hypercall.result);
> > 	spin_unlock_irqrestore(&dev.lock, flags);
> > 
> > 	return ret;
> > }
> > 
> > This gets rid of your 'handle' and the unwinding through an extra pointer
> > indirection. You just need to make sure that the device specific call 
> > numbers
> > don't conflict with any global ones.
> 
> Ah, now I see the confusion...
> 
> DEVCALL is sending a synchronous call to a specific device beyond the bridge.  The MMIO going on here against dev.regs->hypercall.data is sending a synchronous call to the bridge itself.  They are distinctly different ;)

well, my point earlier was that they probably should not be different  ;-)

	Arnd <><
