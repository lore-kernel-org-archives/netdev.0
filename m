From: Gregory Haskins <ghaskins@novell.com>
Subject: [RFC PATCH 17/17] kvm: Add guest-side support for VBUS
Date: Tue, 31 Mar 2009 14:44:16 -0400
Message-ID: <20090331184416.28333.92721.stgit@dev.haskins.net>
References: <20090331184057.28333.77287.stgit@dev.haskins.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: agraf@suse.de, pmullaney@novell.com, pmorreale@novell.com,
	anthony@codemonkey.ws, rusty@rustcorp.com.au,
	netdev@vger.kernel.org, kvm@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20090331184057.28333.77287.stgit@dev.haskins.net>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This adds a driver to interface between the host VBUS support, and the
guest-vbus bus model.

Signed-off-by: Gregory Haskins <ghaskins@novell.com>
---

 arch/x86/Kconfig            |    9 +
 drivers/Makefile            |    1 
 drivers/vbus/proxy/Makefile |    2 
 drivers/vbus/proxy/kvm.c    |  726 +++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 738 insertions(+), 0 deletions(-)
 create mode 100644 drivers/vbus/proxy/Makefile
 create mode 100644 drivers/vbus/proxy/kvm.c

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 91fefd5..8661495 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -451,6 +451,15 @@ config KVM_GUEST_DYNIRQ
        depends on KVM_GUEST
        default y
 
+config KVM_GUEST_VBUS
+       tristate "KVM virtual-bus (VBUS) guest-side support"
+       depends on KVM_GUEST
+       select VBUS_DRIVERS
+       default y
+       ---help---
+          This option enables guest-side support for accessing virtual-bus
+	  devices.
+
 source "arch/x86/lguest/Kconfig"
 
 config PARAVIRT
diff --git a/drivers/Makefile b/drivers/Makefile
index 98fab51..4f2cb93 100644
--- a/drivers/Makefile
+++ b/drivers/Makefile
@@ -107,3 +107,4 @@ obj-$(CONFIG_VIRTIO)		+= virtio/
 obj-$(CONFIG_STAGING)		+= staging/
 obj-y				+= platform/
 obj-$(CONFIG_VBUS_DEVICES)	+= vbus/devices/
+obj-$(CONFIG_VBUS_DRIVERS)	+= vbus/proxy/
diff --git a/drivers/vbus/proxy/Makefile b/drivers/vbus/proxy/Makefile
new file mode 100644
index 0000000..c18d58d
--- /dev/null
+++ b/drivers/vbus/proxy/Makefile
@@ -0,0 +1,2 @@
+kvm-guest-vbus-objs += kvm.o
+obj-$(CONFIG_KVM_GUEST_VBUS) += kvm-guest-vbus.o
diff --git a/drivers/vbus/proxy/kvm.c b/drivers/vbus/proxy/kvm.c
new file mode 100644
index 0000000..82e28b4
--- /dev/null
+++ b/drivers/vbus/proxy/kvm.c
@@ -0,0 +1,726 @@
+/*
+ * Copyright (C) 2009 Novell.  All Rights Reserved.
+ *
+ * Author:
+ *	Gregory Haskins <ghaskins@novell.com>
+ *
+ * This file is free software; you can redistribute it and/or modify
+ * it under the terms of version 2 of the GNU General Public License
+ * as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.	 See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA.
+ */
+
+#include <linux/module.h>
+#include <linux/vbus.h>
+#include <linux/kvm_para.h>
+#include <linux/kvm.h>
+#include <linux/mm.h>
+#include <linux/ioq.h>
+#include <linux/interrupt.h>
+#include <linux/kvm_para.h>
+#include <linux/kvm_guest.h>
+#include <linux/vbus_client.h>
+#include <linux/vbus_driver.h>
+
+MODULE_AUTHOR("Gregory Haskins");
+MODULE_LICENSE("GPL");
+MODULE_VERSION("1");
+
+static int kvm_vbus_hypercall(unsigned long nr, void *data, unsigned long len)
+{
+	return kvm_hypercall3(KVM_HC_VBUS, nr, __pa(data), len);
+}
+
+struct kvm_vbus {
+	spinlock_t                lock;
+	struct ioq                eventq;
+	struct kvm_vbus_event    *ring;
+	int                       irq;
+};
+
+static struct kvm_vbus kvm_vbus;
+
+struct kvm_vbus_device {
+	char                     type[VBUS_MAX_DEVTYPE_LEN];
+	u64                      handle;
+	struct list_head         shms;
+	struct vbus_device_proxy vdev;
+};
+
+/*
+ * -------------------
+ * common routines
+ * -------------------
+ */
+
+struct kvm_vbus_device *
+to_dev(struct vbus_device_proxy *vdev)
+{
+	return container_of(vdev, struct kvm_vbus_device, vdev);
+}
+
+static void
+_signal_init(struct shm_signal *signal, struct shm_signal_desc *desc,
+	     struct shm_signal_ops *ops)
+{
+	desc->magic = SHM_SIGNAL_MAGIC;
+	desc->ver   = SHM_SIGNAL_VER;
+
+	shm_signal_init(signal);
+
+	signal->locale = shm_locality_north;
+	signal->ops    = ops;
+	signal->desc   = desc;
+}
+
+/*
+ * -------------------
+ * _signal
+ * -------------------
+ */
+
+struct _signal {
+	struct kvm_vbus   *kvbus;
+	struct shm_signal  signal;
+	u64                handle;
+	struct rb_node     node;
+	struct list_head   list;
+};
+
+static struct _signal *
+to_signal(struct shm_signal *signal)
+{
+       return container_of(signal, struct _signal, signal);
+}
+
+static struct _signal *
+node_to_signal(struct rb_node *node)
+{
+       return container_of(node, struct _signal, node);
+}
+
+static int
+_signal_inject(struct shm_signal *signal)
+{
+	struct _signal *_signal = to_signal(signal);
+
+	kvm_vbus_hypercall(KVM_VBUS_OP_SHMSIGNAL,
+			   &_signal->handle, sizeof(_signal->handle));
+
+	return 0;
+}
+
+static void
+_signal_release(struct shm_signal *signal)
+{
+	struct _signal *_signal = to_signal(signal);
+
+	kfree(_signal);
+}
+
+static struct shm_signal_ops _signal_ops = {
+	.inject  = _signal_inject,
+	.release = _signal_release,
+};
+
+/*
+ * -------------------
+ * vbus_device_proxy routines
+ * -------------------
+ */
+
+static int
+kvm_vbus_device_open(struct vbus_device_proxy *vdev, int version, int flags)
+{
+	struct kvm_vbus_device *dev = to_dev(vdev);
+	struct vbus_deviceopen params;
+	int ret;
+
+	if (dev->handle)
+		return -EINVAL;
+
+	params.devid   = vdev->id;
+	params.version = version;
+
+	ret = kvm_vbus_hypercall(KVM_VBUS_OP_DEVOPEN,
+				 &params, sizeof(params));
+	if (ret < 0)
+		return ret;
+
+	dev->handle = params.handle;
+
+	return 0;
+}
+
+static int
+kvm_vbus_device_close(struct vbus_device_proxy *vdev, int flags)
+{
+	struct kvm_vbus_device *dev = to_dev(vdev);
+	unsigned long iflags;
+	int ret;
+
+	if (!dev->handle)
+		return -EINVAL;
+
+	spin_lock_irqsave(&kvm_vbus.lock, iflags);
+
+	while (!list_empty(&dev->shms)) {
+		struct _signal *_signal;
+
+		_signal = list_first_entry(&dev->shms, struct _signal, list);
+
+		list_del(&_signal->list);
+
+		spin_unlock_irqrestore(&kvm_vbus.lock, iflags);
+		shm_signal_put(&_signal->signal);
+		spin_lock_irqsave(&kvm_vbus.lock, iflags);
+	}
+
+	spin_unlock_irqrestore(&kvm_vbus.lock, iflags);
+
+	/*
+	 * The DEVICECLOSE will implicitly close all of the shm on the
+	 * host-side, so there is no need to do an explicit per-shm
+	 * hypercall
+	 */
+	ret = kvm_vbus_hypercall(KVM_VBUS_OP_DEVCLOSE,
+				 &dev->handle, sizeof(dev->handle));
+
+	if (ret < 0)
+		printk(KERN_ERR "KVM-VBUS: Error closing device %s/%lld: %d\n",
+		       vdev->type, vdev->id, ret);
+
+	dev->handle = 0;
+
+	return 0;
+}
+
+static int
+kvm_vbus_device_shm(struct vbus_device_proxy *vdev, int id, int prio,
+		    void *ptr, size_t len,
+		    struct shm_signal_desc *sdesc, struct shm_signal **signal,
+		    int flags)
+{
+	struct kvm_vbus_device *dev = to_dev(vdev);
+	struct _signal *_signal = NULL;
+	struct vbus_deviceshm params;
+	unsigned long iflags;
+	int ret;
+
+	if (!dev->handle)
+		return -EINVAL;
+
+	params.devh   = dev->handle;
+	params.id     = id;
+	params.flags  = flags;
+	params.datap  = (u64)__pa(ptr);
+	params.len    = len;
+
+	if (signal) {
+		/*
+		 * The signal descriptor must be embedded within the
+		 * provided ptr
+		 */
+		if (!sdesc
+		    || (len < sizeof(*sdesc))
+		    || ((void *)sdesc < ptr)
+		    || ((void *)sdesc > (ptr + len - sizeof(*sdesc))))
+			return -EINVAL;
+
+		_signal = kzalloc(sizeof(*_signal), GFP_KERNEL);
+		if (!_signal)
+			return -ENOMEM;
+
+		_signal_init(&_signal->signal, sdesc, &_signal_ops);
+
+		/*
+		 * take another reference for the host.  This is dropped
+		 * by a SHMCLOSE event
+		 */
+		shm_signal_get(&_signal->signal);
+
+		params.signal.offset = (u64)sdesc - (u64)ptr;
+		params.signal.prio   = prio;
+		params.signal.cookie = (u64)_signal;
+
+	} else
+		params.signal.offset = -1; /* yes, this is a u32, but its ok */
+
+	ret = kvm_vbus_hypercall(KVM_VBUS_OP_DEVSHM,
+				 &params, sizeof(params));
+	if (ret < 0) {
+		if (_signal) {
+			/*
+			 * We held two references above, so we need to drop
+			 * both of them
+			 */
+			shm_signal_put(&_signal->signal);
+			shm_signal_put(&_signal->signal);
+		}
+
+		return ret;
+	}
+
+	if (signal) {
+		_signal->handle = params.handle;
+
+		spin_lock_irqsave(&kvm_vbus.lock, iflags);
+
+		list_add_tail(&_signal->list, &dev->shms);
+
+		spin_unlock_irqrestore(&kvm_vbus.lock, iflags);
+
+		shm_signal_get(&_signal->signal);
+		*signal = &_signal->signal;
+	}
+
+	return 0;
+}
+
+static int
+kvm_vbus_device_call(struct vbus_device_proxy *vdev, u32 func, void *data,
+		     size_t len, int flags)
+{
+	struct kvm_vbus_device *dev = to_dev(vdev);
+	struct vbus_devicecall params = {
+		.devh  = dev->handle,
+		.func  = func,
+		.datap = (u64)__pa(data),
+		.len   = len,
+		.flags = flags,
+	};
+
+	if (!dev->handle)
+		return -EINVAL;
+
+	return kvm_vbus_hypercall(KVM_VBUS_OP_DEVCALL, &params, sizeof(params));
+}
+
+static void
+kvm_vbus_device_release(struct vbus_device_proxy *vdev)
+{
+	struct kvm_vbus_device *_dev = to_dev(vdev);
+
+	kvm_vbus_device_close(vdev, 0);
+
+	kfree(_dev);
+}
+
+struct vbus_device_proxy_ops kvm_vbus_device_ops = {
+	.open    = kvm_vbus_device_open,
+	.close   = kvm_vbus_device_close,
+	.shm     = kvm_vbus_device_shm,
+	.call    = kvm_vbus_device_call,
+	.release = kvm_vbus_device_release,
+};
+
+/*
+ * -------------------
+ * vbus events
+ * -------------------
+ */
+
+static void
+event_devadd(struct kvm_vbus_add_event *event)
+{
+	int ret;
+	struct kvm_vbus_device *new = kzalloc(sizeof(*new), GFP_KERNEL);
+	if (!new) {
+		printk(KERN_ERR "KVM_VBUS: Out of memory on add_event\n");
+		return;
+	}
+
+	INIT_LIST_HEAD(&new->shms);
+
+	memcpy(new->type, event->type, VBUS_MAX_DEVTYPE_LEN);
+	new->vdev.type        = new->type;
+	new->vdev.id          = event->id;
+	new->vdev.ops         = &kvm_vbus_device_ops;
+
+	sprintf(new->vdev.dev.bus_id, "%lld", event->id);
+
+	ret = vbus_device_proxy_register(&new->vdev);
+	if (ret < 0)
+		panic("failed to register device %lld(%s): %d\n",
+		      event->id, event->type, ret);
+}
+
+static void
+event_devdrop(struct kvm_vbus_handle_event *event)
+{
+	struct vbus_device_proxy *dev = vbus_device_proxy_find(event->handle);
+
+	if (!dev) {
+		printk(KERN_WARNING "KVM-VBUS: devdrop failed: %lld\n",
+		       event->handle);
+		return;
+	}
+
+	vbus_device_proxy_unregister(dev);
+}
+
+static void
+event_shmsignal(struct kvm_vbus_handle_event *event)
+{
+	struct _signal *_signal = (struct _signal *)event->handle;
+
+	_shm_signal_wakeup(&_signal->signal);
+}
+
+static void
+event_shmclose(struct kvm_vbus_handle_event *event)
+{
+	struct _signal *_signal = (struct _signal *)event->handle;
+
+	/*
+	 * This reference was taken during the DEVICESHM call
+	 */
+	shm_signal_put(&_signal->signal);
+}
+
+/*
+ * -------------------
+ * eventq routines
+ * -------------------
+ */
+
+static struct ioq_notifier eventq_notifier;
+
+static int __init
+eventq_init(int qlen)
+{
+	struct ioq_iterator iter;
+	int ret;
+	int i;
+
+	kvm_vbus.ring = kzalloc(sizeof(struct kvm_vbus_event) * qlen,
+				GFP_KERNEL);
+	if (!kvm_vbus.ring)
+		return -ENOMEM;
+
+	/*
+	 * We want to iterate on the "valid" index.  By default the iterator
+	 * will not "autoupdate" which means it will not hypercall the host
+	 * with our changes.  This is good, because we are really just
+	 * initializing stuff here anyway.  Note that you can always manually
+	 * signal the host with ioq_signal() if the autoupdate feature is not
+	 * used.
+	 */
+	ret = ioq_iter_init(&kvm_vbus.eventq, &iter, ioq_idxtype_valid, 0);
+	BUG_ON(ret < 0);
+
+	/*
+	 * Seek to the tail of the valid index (which should be our first
+	 * item since the queue is brand-new)
+	 */
+	ret = ioq_iter_seek(&iter, ioq_seek_tail, 0, 0);
+	BUG_ON(ret < 0);
+
+	/*
+	 * Now populate each descriptor with an empty vbus_event and mark it
+	 * valid
+	 */
+	for (i = 0; i < qlen; i++) {
+		struct kvm_vbus_event *event = &kvm_vbus.ring[i];
+		size_t                 len   = sizeof(*event);
+		struct ioq_ring_desc  *desc  = iter.desc;
+
+		BUG_ON(iter.desc->valid);
+
+		desc->cookie = (u64)event;
+		desc->ptr    = (u64)__pa(event);
+		desc->len    = len; /* total length  */
+		desc->valid  = 1;
+
+		/*
+		 * This push operation will simultaneously advance the
+		 * valid-tail index and increment our position in the queue
+		 * by one.
+		 */
+		ret = ioq_iter_push(&iter, 0);
+		BUG_ON(ret < 0);
+	}
+
+	kvm_vbus.eventq.notifier = &eventq_notifier;
+
+	/*
+	 * And finally, ensure that we can receive notification
+	 */
+	ioq_notify_enable(&kvm_vbus.eventq, 0);
+
+	return 0;
+}
+
+/* Invoked whenever the hypervisor ioq_signal()s our eventq */
+static void
+eventq_wakeup(struct ioq_notifier *notifier)
+{
+	struct ioq_iterator iter;
+	int ret;
+
+	/* We want to iterate on the head of the in-use index */
+	ret = ioq_iter_init(&kvm_vbus.eventq, &iter, ioq_idxtype_inuse, 0);
+	BUG_ON(ret < 0);
+
+	ret = ioq_iter_seek(&iter, ioq_seek_head, 0, 0);
+	BUG_ON(ret < 0);
+
+	/*
+	 * The EOM is indicated by finding a packet that is still owned by
+	 * the south side.
+	 *
+	 * FIXME: This in theory could run indefinitely if the host keeps
+	 * feeding us events since there is nothing like a NAPI budget.  We
+	 * might need to address that
+	 */
+	while (!iter.desc->sown) {
+		struct ioq_ring_desc *desc  = iter.desc;
+		struct kvm_vbus_event *event;
+
+		event = (struct kvm_vbus_event *)desc->cookie;
+
+		switch (event->eventid) {
+		case KVM_VBUS_EVENT_DEVADD:
+			event_devadd(&event->data.add);
+			break;
+		case KVM_VBUS_EVENT_DEVDROP:
+			event_devdrop(&event->data.handle);
+			break;
+		case KVM_VBUS_EVENT_SHMSIGNAL:
+			event_shmsignal(&event->data.handle);
+			break;
+		case KVM_VBUS_EVENT_SHMCLOSE:
+			event_shmclose(&event->data.handle);
+			break;
+		default:
+			printk(KERN_WARNING "KVM_VBUS: Unexpected event %d\n",
+			       event->eventid);
+			break;
+		};
+
+		memset(event, 0, sizeof(*event));
+
+		/* Advance the in-use head */
+		ret = ioq_iter_pop(&iter, 0);
+		BUG_ON(ret < 0);
+	}
+
+	/* And let the south side know that we changed the queue */
+	ioq_signal(&kvm_vbus.eventq, 0);
+}
+
+static struct ioq_notifier eventq_notifier = {
+	.signal = &eventq_wakeup,
+};
+
+/* Injected whenever the host issues an ioq_signal() on the eventq */
+irqreturn_t
+eventq_intr(int irq, void *dev)
+{
+	_shm_signal_wakeup(kvm_vbus.eventq.signal);
+
+	return IRQ_HANDLED;
+}
+
+/*
+ * -------------------
+ */
+
+static int
+eventq_signal_inject(struct shm_signal *signal)
+{
+	u64 handle = 0; /* The eventq uses the special-case handle=0 */
+
+	kvm_vbus_hypercall(KVM_VBUS_OP_SHMSIGNAL, &handle, sizeof(handle));
+
+	return 0;
+}
+
+static void
+eventq_signal_release(struct shm_signal *signal)
+{
+	kfree(signal);
+}
+
+static struct shm_signal_ops eventq_signal_ops = {
+	.inject  = eventq_signal_inject,
+	.release = eventq_signal_release,
+};
+
+/*
+ * -------------------
+ */
+
+static void
+eventq_ioq_release(struct ioq *ioq)
+{
+	/* released as part of the kvm_vbus object */
+}
+
+static struct ioq_ops eventq_ioq_ops = {
+	.release = eventq_ioq_release,
+};
+
+/*
+ * -------------------
+ */
+
+static void
+kvm_vbus_release(void)
+{
+	if (kvm_vbus.irq > 0) {
+		free_irq(kvm_vbus.irq, NULL);
+		destroy_kvm_dynirq(kvm_vbus.irq);
+	}
+
+	kfree(kvm_vbus.eventq.head_desc);
+	kfree(kvm_vbus.ring);
+}
+
+static int __init
+kvm_vbus_open(void)
+{
+	struct kvm_vbus_busopen params = {
+		.magic        = KVM_VBUS_MAGIC,
+		.version      = KVM_VBUS_VERSION,
+		.capabilities = 0,
+	};
+
+	return kvm_vbus_hypercall(KVM_VBUS_OP_BUSOPEN, &params, sizeof(params));
+}
+
+#define QLEN 1024
+
+static int __init
+kvm_vbus_register(void)
+{
+	struct kvm_vbus_busreg params = {
+		.count = 1,
+		.eventq = {
+			{
+				.irq   = kvm_vbus.irq,
+				.count = QLEN,
+				.ring  = (u64)__pa(kvm_vbus.eventq.head_desc),
+				.data  = (u64)__pa(kvm_vbus.ring),
+			},
+		},
+	};
+
+	return kvm_vbus_hypercall(KVM_VBUS_OP_BUSREG, &params, sizeof(params));
+}
+
+static int __init
+_ioq_init(size_t ringsize, struct ioq *ioq, struct ioq_ops *ops)
+{
+	struct shm_signal    *signal = NULL;
+	struct ioq_ring_head *head = NULL;
+	size_t                len  = IOQ_HEAD_DESC_SIZE(ringsize);
+
+	head = kzalloc(len, GFP_KERNEL | GFP_DMA);
+	if (!head)
+		return -ENOMEM;
+
+	signal = kzalloc(sizeof(*signal), GFP_KERNEL);
+	if (!signal) {
+		kfree(head);
+		return -ENOMEM;
+	}
+
+	head->magic     = IOQ_RING_MAGIC;
+	head->ver	= IOQ_RING_VER;
+	head->count     = ringsize;
+
+	_signal_init(signal, &head->signal, &eventq_signal_ops);
+
+	ioq_init(ioq, ops, ioq_locality_north, head, signal, ringsize);
+
+	return 0;
+}
+
+int __init
+kvm_vbus_init(void)
+{
+	int ret;
+
+	memset(&kvm_vbus, 0, sizeof(kvm_vbus));
+
+	ret = kvm_para_has_feature(KVM_FEATURE_VBUS);
+	if (!ret)
+		return -ENOENT;
+
+	ret = kvm_vbus_open();
+	if (ret < 0) {
+		printk(KERN_ERR "KVM_VBUS: Could not register with host: %d\n",
+		       ret);
+		goto out_fail;
+	}
+
+	spin_lock_init(&kvm_vbus.lock);
+
+	/*
+	 * Allocate an IOQ to use for host-2-guest event notification
+	 */
+	ret = _ioq_init(QLEN, &kvm_vbus.eventq, &eventq_ioq_ops);
+	if (ret < 0) {
+		printk(KERN_ERR "KVM_VBUS: Cound not init eventq\n");
+		goto out_fail;
+	}
+
+	ret = eventq_init(QLEN);
+	if (ret < 0) {
+		printk(KERN_ERR "KVM_VBUS: Cound not setup ring\n");
+		goto out_fail;
+	}
+
+	/*
+	 * Dynamically assign a free IRQ to this resource
+	 */
+	kvm_vbus.irq = create_kvm_dynirq(0);
+	if (kvm_vbus.irq < 0) {
+		printk(KERN_ERR "KVM_VBUS: Failed to create IRQ\n");
+		goto out_fail;
+	}
+
+	ret = request_irq(kvm_vbus.irq, eventq_intr, 0, "vbus", NULL);
+	if (ret < 0) {
+		printk(KERN_ERR "KVM_VBUS: Failed to register IRQ %d\n: %d",
+		       kvm_vbus.irq, ret);
+		goto out_fail;
+	}
+
+	/*
+	 * Finally register our queue on the host to start receiving events
+	 */
+	ret = kvm_vbus_register();
+	if (ret < 0) {
+		printk(KERN_ERR "KVM_VBUS: Could not register with host: %d\n",
+		       ret);
+		goto out_fail;
+	}
+
+	return 0;
+
+ out_fail:
+	kvm_vbus_release();
+
+	return ret;
+
+}
+
+static void __exit
+kvm_vbus_exit(void)
+{
+	kvm_vbus_release();
+}
+
+module_init(kvm_vbus_init);
+module_exit(kvm_vbus_exit);
+

