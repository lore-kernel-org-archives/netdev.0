From: "Gregory Haskins" <ghaskins@novell.com>
Subject: Re: [PATCH 4/7] vbus-proxy: add a pci-to-vbus bridge
Date: Thu, 06 Aug 2009 09:59:56 -0600
Message-ID: <4A7AC5BC0200005A00051C2A@sinclair.provo.novell.com>
References: <20090803171030.17268.26962.stgit@dev.haskins.net>
 <20090803171751.17268.48169.stgit@dev.haskins.net>
 <200908061642.40614.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: <alacrityvm-devel@lists.sourceforge.net>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
To: "Arnd Bergmann" <arnd@arndb.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756132AbZHFQAA@vger.kernel.org>
In-Reply-To: <200908061642.40614.arnd@arndb.de>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>>> On 8/6/2009 at 10:42 AM, in message <200908061642.40614.arnd@arndb.de>, Arnd
Bergmann <arnd@arndb.de> wrote: 
> On Monday 03 August 2009, Gregory Haskins wrote:
>> This patch adds a pci-based driver to interface between the a host VBUS
>> and the guest's vbus-proxy bus model.
>> 
>> Signed-off-by: Gregory Haskins <ghaskins@novell.com>
> 
> This seems to be duplicating parts of virtio-pci that could be kept
> common by extending the virtio code. Layering on top of virtio
> would also make it possible to use the same features you add
> on top of other transports (e.g. the s390 virtio code) without
> adding yet another backend for each of them.

This doesn't make sense to me, but I suspect we are both looking at what this code does differently.  I am under the impression that you may believe that there is one of these objects per vbus device.  Note that this is just a bridge to vbus, so there is only one of these per system with potentially many vbus devices behind it.

In essence, this driver's job is to populate the "vbus-proxy" LDM bus with objects that it finds across the PCI-OTHER bridge.  This would actually sit below the virtio components in the stack, so it doesnt make sense (to me) to turn around and build this on top of virtio.  But perhaps I am missing something you are seeing.

Can you elaborate?

> 
>> +static int
>> +vbus_pci_hypercall(unsigned long nr, void *data, unsigned long len)
>> +{
>> +	struct vbus_pci_hypercall params = {
>> +		.vector = nr,
>> +		.len    = len,
>> +		.datap  = __pa(data),
>> +	};
>> +	unsigned long flags;
>> +	int ret;
>> +
>> +	spin_lock_irqsave(&vbus_pci.lock, flags);
>> +
>> +	memcpy_toio(&vbus_pci.regs->hypercall.data, &params, sizeof(params));
>> +	ret = ioread32(&vbus_pci.regs->hypercall.result);
>> +
>> +	spin_unlock_irqrestore(&vbus_pci.lock, flags);
>> +
>> +	return ret;
>> +}
> 
> The functionality looks reasonable but please don't call this a hypercall.

Heh, I guess its just semantics.  The reason why its called hypercall is two fold:

1) In previous versions (vbus-v3 and earlier), it actually *was* literally a KVM-hypercall.
2) In this current version, it is purely a PCI device doing PIO, but it still acts exactly like a hypercall on the backend (via the ioeventfd mechanism in KVM).

That said, I am not married to the name, so I can come up with something more appropriate/descriptive.

> A hypercall would be hypervisor specific by definition while this one
> is device specific if I understand it correctly. How about "command queue",
> "mailbox", "message queue", "devcall" or something else that we have in
> existing PCI devices?
> 
>> +
>> +static int
>> +vbus_pci_device_open(struct vbus_device_proxy *vdev, int version, int 
> flags)
>> +{
>> +	struct vbus_pci_device *dev = to_dev(vdev);
>> +	struct vbus_pci_deviceopen params;
>> +	int ret;
>> +
>> +	if (dev->handle)
>> +		return -EINVAL;
>> +
>> +	params.devid   = vdev->id;
>> +	params.version = version;
>> +
>> +	ret = vbus_pci_hypercall(VBUS_PCI_HC_DEVOPEN,
>> +				 &params, sizeof(params));
>> +	if (ret < 0)
>> +		return ret;
>> +
>> +	dev->handle = params.handle;
>> +
>> +	return 0;
>> +}
> 
> This seems to add an artificial abstraction that does not make sense
> if you stick to the PCI abstraction.

I think there may be confusion about what is going on here.  The "device-open" pertains to a vbus device *beyond* the bridge, not the PCI device (the bridge) itself.  Nor is the vbus device a PCI device.

Whats happening here is somewhat analogous to a PCI config-cycle.  Its a way to open a channel to a device beyond the bridge in _response_ to a probe.

We have a way to enumerate devices present beyond the bridge (this yields a "device-id")  but in order to actually talk to the device, you must first call DEVOPEN(id).  When a device-id is enumerated, it generates a probe() event on vbus-proxy.  The responding driver in question would then turn around and issue the handle = dev->open(VERSION) to see if it is compatible with the device, and to establish a context for further communication.

The reason why DEVOPEN returns a unique handle is to help ensure that the driver has established proper context before allowing other calls.

> The two sensible and common models
> for virtual devices that I've seen are:
> 
> * The hypervisor knows what virtual resources exist and provides them
>   to the guest. The guest owns them as soon as they show up in the
>   bus (e.g. PCI) probe. The 'handle' is preexisting.
> 
> * The guest starts without any devices and asks for resources it wants
>   to access. There is no probing of resources but the guest issues
>   a hypercall to get a handle to a newly created virtual device
>   (or -ENODEV).
> 
> What is your reasoning for requiring both a probe and an allocation?

Answered above, I thnk

> 
>> +static int
>> +vbus_pci_device_shm(struct vbus_device_proxy *vdev, int id, int prio,
>> +		    void *ptr, size_t len,
>> +		    struct shm_signal_desc *sdesc, struct shm_signal **signal,
>> +		    int flags)
>> +{
>> +	struct vbus_pci_device *dev = to_dev(vdev);
>> +	struct _signal *_signal = NULL;
>> +	struct vbus_pci_deviceshm params;
>> +	unsigned long iflags;
>> +	int ret;
>> +
>> +	if (!dev->handle)
>> +		return -EINVAL;
>> +
>> +	params.devh   = dev->handle;
>> +	params.id     = id;
>> +	params.flags  = flags;
>> +	params.datap  = (u64)__pa(ptr);
>> +	params.len    = len;
>> +
>> +	if (signal) {
>> +		/*
>> +		 * The signal descriptor must be embedded within the
>> +		 * provided ptr
>> +		 */
>> +		if (!sdesc
>> +		    || (len < sizeof(*sdesc))
>> +		    || ((void *)sdesc < ptr)
>> +		    || ((void *)sdesc > (ptr + len - sizeof(*sdesc))))
>> +			return -EINVAL;
>> +
>> +		_signal = kzalloc(sizeof(*_signal), GFP_KERNEL);
>> +		if (!_signal)
>> +			return -ENOMEM;
>> +
>> +		_signal_init(&_signal->signal, sdesc, &_signal_ops);
>> +
>> +		/*
>> +		 * take another reference for the host.  This is dropped
>> +		 * by a SHMCLOSE event
>> +		 */
>> +		shm_signal_get(&_signal->signal);
>> +
>> +		params.signal.offset = (u64)sdesc - (u64)ptr;
>> +		params.signal.prio   = prio;
>> +		params.signal.cookie = (u64)_signal;
>> +
>> +	} else
>> +		params.signal.offset = -1; /* yes, this is a u32, but its ok */
>> +
>> +	ret = vbus_pci_hypercall(VBUS_PCI_HC_DEVSHM,
>> +				 &params, sizeof(params));
>> +	if (ret < 0) {
>> +		if (_signal) {
>> +			/*
>> +			 * We held two references above, so we need to drop
>> +			 * both of them
>> +			 */
>> +			shm_signal_put(&_signal->signal);
>> +			shm_signal_put(&_signal->signal);
>> +		}
>> +
>> +		return ret;
>> +	}
>> +
>> +	if (signal) {
>> +		_signal->handle = ret;
>> +
>> +		spin_lock_irqsave(&vbus_pci.lock, iflags);
>> +
>> +		list_add_tail(&_signal->list, &dev->shms);
>> +
>> +		spin_unlock_irqrestore(&vbus_pci.lock, iflags);
>> +
>> +		shm_signal_get(&_signal->signal);
>> +		*signal = &_signal->signal;
>> +	}
>> +
>> +	return 0;
>> +}
> 
> This could be implemented by virtio devices as well, right?

The big difference with dev->shm() is that it is not bound to a particular ABI within the shared-memory (as opposed to virtio, which assumes a virtio ABI).  This just creates an empty shared-memory region (with a bidirectional signaling path) which you can overlay a variety of structures (virtio included).  You can of course also use non-ring based structures, such as, say, an array of idempotent state.

The point is that, once this is done, you have a shared-memory region and a way (via the shm-signal) to bidirectionally signal changes to that memory region.  You can then build bigger things with it, like virtqueues.

> 
>> +static int
>> +vbus_pci_device_call(struct vbus_device_proxy *vdev, u32 func, void *data,
>> +		     size_t len, int flags)
>> +{
>> +	struct vbus_pci_device *dev = to_dev(vdev);
>> +	struct vbus_pci_devicecall params = {
>> +		.devh  = dev->handle,
>> +		.func  = func,
>> +		.datap = (u64)__pa(data),
>> +		.len   = len,
>> +		.flags = flags,
>> +	};
>> +
>> +	if (!dev->handle)
>> +		return -EINVAL;
>> +
>> +	return vbus_pci_hypercall(VBUS_PCI_HC_DEVCALL, &params, sizeof(params));
>> +}
> 
> Why the indirection? It seems to me that you could do the simpler

What indirection?

/me looks below and thinks he sees the confusion..

> 
> static int
> vbus_pci_device_call(struct vbus_device_proxy *vdev, u32 func, void *data,
> 		     size_t len, int flags)
> {
> 	struct vbus_pci_device *dev = to_dev(vdev);
> 	struct vbus_pci_hypercall params = {
> 		.vector = func,
> 		.len    = len,
> 		.datap  = __pa(data),
> 	};
> 	spin_lock_irqsave(&dev.lock, flags);
> 	memcpy_toio(&dev.regs->hypercall.data, &params, sizeof(params));
> 	ret = ioread32(&dev.regs->hypercall.result);
> 	spin_unlock_irqrestore(&dev.lock, flags);
> 
> 	return ret;
> }
> 
> This gets rid of your 'handle' and the unwinding through an extra pointer
> indirection. You just need to make sure that the device specific call 
> numbers
> don't conflict with any global ones.

Ah, now I see the confusion...

DEVCALL is sending a synchronous call to a specific device beyond the bridge.  The MMIO going on here against dev.regs->hypercall.data is sending a synchronous call to the bridge itself.  They are distinctly different ;)

> 
>> +
>> +static struct ioq_notifier eventq_notifier;
> 
>> ...
> 
>> +/* Invoked whenever the hypervisor ioq_signal()s our eventq */
>> +static void
>> +eventq_wakeup(struct ioq_notifier *notifier)
>> +{
>> +	struct ioq_iterator iter;
>> +	int ret;
>> +
>> +	/* We want to iterate on the head of the in-use index */
>> +	ret = ioq_iter_init(&vbus_pci.eventq, &iter, ioq_idxtype_inuse, 0);
>> +	BUG_ON(ret < 0);
>> +
>> +	ret = ioq_iter_seek(&iter, ioq_seek_head, 0, 0);
>> +	BUG_ON(ret < 0);
>> +
>> +	/*
>> +	 * The EOM is indicated by finding a packet that is still owned by
>> +	 * the south side.
>> +	 *
>> +	 * FIXME: This in theory could run indefinitely if the host keeps
>> +	 * feeding us events since there is nothing like a NAPI budget.  We
>> +	 * might need to address that
>> +	 */
>> +	while (!iter.desc->sown) {
>> +		struct ioq_ring_desc *desc  = iter.desc;
>> +		struct vbus_pci_event *event;
>> +
>> +		event = (struct vbus_pci_event *)desc->cookie;
>> +
>> +		switch (event->eventid) {
>> +		case VBUS_PCI_EVENT_DEVADD:
>> +			event_devadd(&event->data.add);
>> +			break;
>> +		case VBUS_PCI_EVENT_DEVDROP:
>> +			event_devdrop(&event->data.handle);
>> +			break;
>> +		case VBUS_PCI_EVENT_SHMSIGNAL:
>> +			event_shmsignal(&event->data.handle);
>> +			break;
>> +		case VBUS_PCI_EVENT_SHMCLOSE:
>> +			event_shmclose(&event->data.handle);
>> +			break;
>> +		default:
>> +			printk(KERN_WARNING "VBUS_PCI: Unexpected event %d\n",
>> +			       event->eventid);
>> +			break;
>> +		};
>> +
>> +		memset(event, 0, sizeof(*event));
>> +
>> +		/* Advance the in-use head */
>> +		ret = ioq_iter_pop(&iter, 0);
>> +		BUG_ON(ret < 0);
>> +	}
>> +
>> +	/* And let the south side know that we changed the queue */
>> +	ioq_signal(&vbus_pci.eventq, 0);
>> +}
> 
> Ah, so you have a global event queue and your own device hotplug mechanism.
> But why would you then still use PCI to back it?

PCI is only used as a PCI-to-vbus bridge.  Beyond that, the bridge is populating the vbus devices it sees beyond the bridge into the vbus-proxy LDM bus.

That said, the event queue is sending me events such as "device added" and "shm-signal", which are then reflected up into the general model.

> We already have PCI hotplug to add and remove devices

Yep, and I do actually use that...to get a probe for the bridge itself ;)

>and you have defined per device notifier queues that you can use for waking up the device, right?

Only per bridge.  vbus drivers themselves allocate additional dynamic shm-signal channels that are tunneled through the bridge's eventq(s).

Kind Regards,
-Greg
