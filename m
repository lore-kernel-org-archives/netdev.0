From: Gregory Haskins <ghaskins@novell.com>
Subject: [RFC PATCH v2 18/19] vbus: add a userspace connector
Date: Thu, 09 Apr 2009 12:32:16 -0400
Message-ID: <20090409163215.32740.10903.stgit@dev.haskins.net>
References: <20090409155200.32740.19358.stgit@dev.haskins.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: agraf@suse.de, pmullaney@novell.com, pmorreale@novell.com,
	anthony@codemonkey.ws, rusty@rustcorp.com.au,
	netdev@vger.kernel.org, kvm@vger.kernel.org, avi@redhat.com,
	bhutchings@solarflare.com, andi@firstfloor.org, gregkh@suse.de,
	herber@gondor.apana.org.au, chrisw@sous-sol.org,
	shemminger@vyatta.com
To: linux-kernel@vger.kernel.org
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20090409155200.32740.19358.stgit@dev.haskins.net>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This allows userspace applications to access vbus devices

Signed-off-by: Gregory Haskins <ghaskins@novell.com>
---

 include/linux/vbus.h           |    4 
 include/linux/vbus_client.h    |    2 
 include/linux/vbus_userspace.h |   48 ++++
 kernel/vbus/Kconfig            |   10 +
 kernel/vbus/Makefile           |    2 
 kernel/vbus/userspace-client.c |  485 ++++++++++++++++++++++++++++++++++++++++
 6 files changed, 550 insertions(+), 1 deletions(-)
 create mode 100644 include/linux/vbus_userspace.h
 create mode 100644 kernel/vbus/userspace-client.c

diff --git a/include/linux/vbus.h b/include/linux/vbus.h
index 04db4ff..f967e59 100644
--- a/include/linux/vbus.h
+++ b/include/linux/vbus.h
@@ -23,6 +23,8 @@
 #ifndef _LINUX_VBUS_H
 #define _LINUX_VBUS_H
 
+#ifdef __KERNEL__
+
 #ifdef CONFIG_VBUS
 
 #include <linux/module.h>
@@ -159,4 +161,6 @@ int vbus_notifier_unregister(struct vbus *vbus, struct notifier_block *nb);
 
 #endif /* CONFIG_VBUS */
 
+#endif /* __KERNEL__ */
+
 #endif /* _LINUX_VBUS_H */
diff --git a/include/linux/vbus_client.h b/include/linux/vbus_client.h
index 62dab78..4c82822 100644
--- a/include/linux/vbus_client.h
+++ b/include/linux/vbus_client.h
@@ -35,7 +35,7 @@
 #ifndef _LINUX_VBUS_CLIENT_H
 #define _LINUX_VBUS_CLIENT_H
 
-#include <linux/types.h>
+#include <asm/types.h>
 #include <linux/compiler.h>
 
 struct vbus_deviceopen {
diff --git a/include/linux/vbus_userspace.h b/include/linux/vbus_userspace.h
new file mode 100644
index 0000000..0b78686
--- /dev/null
+++ b/include/linux/vbus_userspace.h
@@ -0,0 +1,48 @@
+/*
+ * Copyright 2009 Novell.  All Rights Reserved.
+ *
+ * Virtual-Bus
+ *
+ * Author:
+ *      Gregory Haskins <ghaskins@novell.com>
+ *
+ * This file is free software; you can redistribute it and/or modify
+ * it under the terms of version 2 of the GNU General Public License
+ * as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA.
+ */
+
+#ifndef _LINUX_VBUS_USERSPACE_H
+#define _LINUX_VBUS_USERSPACE_H
+
+#include <linux/ioctl.h>
+#include <linux/vbus.h>
+#include <linux/vbus_client.h>
+
+#define VBUS_USERSPACE_ABI_MAGIC 0x4fa23b58
+#define VBUS_USERSPACE_ABI_VERSION 1
+
+struct vbus_userspace_busopen {
+	__u32 magic;
+	__u32 version;
+	__u64 capabilities;
+};
+
+#define VBUS_IOCTL_MAGIC 'v'
+
+#define VBUS_BUSOPEN       _IOWR(VBUS_IOCTL_MAGIC, 0x00, struct vbus_userspace_busopen)
+#define VBUS_DEVICEOPEN   _IOWR(VBUS_IOCTL_MAGIC, 0x01, struct vbus_deviceopen)
+#define VBUS_DEVICECLOSE  _IOWR(VBUS_IOCTL_MAGIC, 0x02, __u64)
+#define VBUS_DEVICECALL   _IOWR(VBUS_IOCTL_MAGIC, 0x03, struct vbus_devicecall)
+#define VBUS_DEVICESHM    _IOWR(VBUS_IOCTL_MAGIC, 0x04, struct vbus_deviceshm)
+#define VBUS_SHMSIGNAL    _IOWR(VBUS_IOCTL_MAGIC, 0x05, __u64)
+
+#endif /* _LINUX_VBUS_USERSPACE_H */
diff --git a/kernel/vbus/Kconfig b/kernel/vbus/Kconfig
index 3ce0adc..b894dd1 100644
--- a/kernel/vbus/Kconfig
+++ b/kernel/vbus/Kconfig
@@ -25,6 +25,16 @@ config VBUS_DEVICES
 
 source "drivers/vbus/devices/Kconfig"
 
+config VBUS_USERSPACE
+       tristate "Virtual-Bus userspace client support"
+       depends on VBUS
+       default y
+       help
+         Provides facilities for userspace applications to access virtual-
+	 bus objects.
+
+	 If unsure, say N
+
 config VBUS_DRIVERS
        tristate "VBUS Driver support"
        select IOQ
diff --git a/kernel/vbus/Makefile b/kernel/vbus/Makefile
index 45f6503..61d0371 100644
--- a/kernel/vbus/Makefile
+++ b/kernel/vbus/Makefile
@@ -4,3 +4,5 @@ obj-$(CONFIG_VBUS) += shm-ioq.o
 vbus-proxy-objs += proxy.o
 obj-$(CONFIG_VBUS_DRIVERS) += vbus-proxy.o
 
+vbus-userspace-objs += userspace-client.o
+obj-$(CONFIG_VBUS_USERSPACE) += vbus-userspace.o
diff --git a/kernel/vbus/userspace-client.c b/kernel/vbus/userspace-client.c
new file mode 100644
index 0000000..b2fe447
--- /dev/null
+++ b/kernel/vbus/userspace-client.c
@@ -0,0 +1,485 @@
+#include <linux/ioctl.h>
+#include <linux/fs.h>
+#include <linux/miscdevice.h>
+#include <linux/mm.h>
+#include <linux/vmalloc.h>
+#include <linux/uaccess.h>
+#include <linux/spinlock.h>
+#include <linux/module.h>
+
+#include <linux/vbus.h>
+#include <linux/vbus_userspace.h>
+
+#include "vbus.h"
+
+MODULE_AUTHOR("Gregory Haskins");
+MODULE_LICENSE("GPL");
+
+struct userspace_chardev;
+
+struct userspace_signal {
+	struct userspace_chardev *cd;
+	struct vbus_shm          *shm;
+	struct shm_signal         signal;
+	struct list_head          list;
+	int                       signaled;
+	int                       prio;
+	u64                       cookie;
+};
+
+struct userspace_shm {
+	struct vbus_shm shm;
+};
+
+struct userspace_chardev {
+	spinlock_t lock;
+	int opened;
+	struct vbus_memctx *ctx;
+	struct vbus_client *client;
+	struct list_head signal_list;
+	wait_queue_head_t wq;
+	struct vbus *vbus;
+};
+
+static long
+_busopen(struct userspace_chardev *cd, struct vbus_userspace_busopen *args)
+{
+	if (cd->opened)
+		return -EINVAL;
+
+	if (args->magic != VBUS_USERSPACE_ABI_MAGIC)
+		return -EINVAL;
+
+	if (args->version != VBUS_USERSPACE_ABI_VERSION)
+		return -EINVAL;
+
+	/*
+	 * We have no extended capabilities yet, so we dont care if they set
+	 * any option bits.  Just clear them all.
+	 */
+	args->capabilities = 0;
+
+	cd->opened = 1;
+
+	return 0;
+}
+
+static long
+_deviceopen(struct userspace_chardev *cd, struct vbus_deviceopen *args)
+{
+	struct vbus_client *c = cd->client;
+
+	return c->ops->deviceopen(c, cd->ctx, args->devid, args->version,
+				  &args->handle);
+}
+
+static long
+_deviceclose(struct userspace_chardev *cd, unsigned long devh)
+{
+	struct vbus_client *c = cd->client;
+
+	return c->ops->deviceclose(c, devh);
+}
+
+static long
+_devicecall(struct userspace_chardev *cd, struct vbus_devicecall *args)
+{
+	struct vbus_client *c = cd->client;
+
+	return c->ops->devicecall(c, args->devh, args->func,
+				  (void *)args->datap,
+				  args->len, args->flags);
+}
+
+static void*
+userspace_vmap(__u64 addr, size_t len)
+{
+	struct page **page_list;
+	void *ptr = NULL;
+	unsigned long base;
+	off_t offset;
+	size_t npages;
+	int ret;
+
+	base = (unsigned long)addr & PAGE_MASK;
+	offset = (unsigned long)addr & ~PAGE_MASK;
+	npages = PAGE_ALIGN(len + offset) >> PAGE_SHIFT;
+
+	if (npages > (PAGE_SIZE / sizeof(struct page *)))
+		return NULL;
+
+	page_list = (struct page **) __get_free_page(GFP_KERNEL);
+	if (!page_list)
+		return NULL;
+
+	down_write(&current->mm->mmap_sem);
+
+	ret = get_user_pages(current, current->mm, base, npages,
+			     1, 0, page_list, NULL);
+	if (ret < 0)
+		goto out;
+
+	ptr = vmap(page_list, npages, VM_MAP, PAGE_KERNEL);
+	if (ptr)
+		current->mm->locked_vm += npages;
+
+out:
+	up_write(&current->mm->mmap_sem);
+	free_page((unsigned long)page_list);
+
+	return ptr+offset;
+}
+
+static struct userspace_signal *to_userspace(struct shm_signal *signal)
+{
+       return container_of(signal, struct userspace_signal, signal);
+}
+
+static int
+userspace_signal_inject(struct shm_signal *signal)
+{
+	struct userspace_signal *_signal = to_userspace(signal);
+	struct userspace_chardev *cd = _signal->cd;
+	unsigned long flags;
+
+	spin_lock_irqsave(&cd->lock, flags);
+
+	if (!_signal->signaled) {
+		_signal->signaled = 1;
+		list_add_tail(&_signal->list, &cd->signal_list);
+		wake_up_interruptible(&cd->wq);
+	}
+
+	spin_unlock_irqrestore(&cd->lock, flags);
+
+	return 0;
+}
+
+static void
+userspace_signal_release(struct shm_signal *signal)
+{
+	struct userspace_signal *_signal = to_userspace(signal);
+
+	vbus_shm_put(_signal->shm);
+	kfree(_signal);
+}
+
+static struct shm_signal_ops userspace_signal_ops = {
+	.inject  = userspace_signal_inject,
+	.release = userspace_signal_release,
+};
+
+static long
+userspace_signal_alloc(struct vbus_shm *shm,
+		       u32 offset, u32 prio, u64 cookie,
+		       struct userspace_signal **usignal)
+{
+	struct userspace_signal *_signal;
+	struct shm_signal *signal;
+	struct shm_signal_desc *desc;
+	int ret = -EINVAL;
+
+	_signal = kzalloc(sizeof(*_signal), GFP_KERNEL);
+	if (!_signal)
+		return -ENOMEM;
+
+	desc = (struct shm_signal_desc *)(shm->ptr + offset);
+
+	if (desc->magic != SHM_SIGNAL_MAGIC)
+		goto out;
+
+	if (desc->ver != SHM_SIGNAL_VER)
+		goto out;
+
+	signal = &_signal->signal;
+
+	shm_signal_init(signal);
+
+	signal->locale    = shm_locality_south;
+	signal->ops       = &userspace_signal_ops;
+	signal->desc      = desc;
+
+	_signal->shm      = shm;
+	_signal->prio     = prio;
+	_signal->cookie   = cookie;
+	vbus_shm_get(shm); /* dropped when the signal is released */
+
+	*usignal = _signal;
+
+	return 0;
+
+out:
+	kfree(_signal);
+
+	return ret;
+}
+
+static void
+userspace_shm_release(struct vbus_shm *shm)
+{
+	struct userspace_shm *_shm = container_of(shm, struct userspace_shm,
+						  shm);
+
+	/* FIXME: do we need to adjust current->mm->locked_vm? */
+	vunmap((void *)((unsigned long)shm->ptr & PAGE_MASK));
+	kfree(_shm);
+}
+
+static struct vbus_shm_ops userspace_shm_ops = {
+	.release = userspace_shm_release,
+};
+
+static int
+userspace_shm_map(struct userspace_chardev *cd,
+		  __u64 ptr, __u32 len,
+		  struct userspace_shm **ushm)
+{
+	struct userspace_shm *_shm;
+	struct vbus_shm *shm;
+	void *vmap;
+
+	_shm = kzalloc(sizeof(*_shm), GFP_KERNEL);
+	if (!_shm)
+		return -ENOMEM;
+
+	shm = &_shm->shm;
+
+	vmap = userspace_vmap(ptr, len);
+	if (!vmap) {
+		kfree(_shm);
+		return -EFAULT;
+	}
+
+	vbus_shm_init(shm, &userspace_shm_ops, vmap, len);
+
+	*ushm = _shm;
+
+	return 0;
+}
+
+static long
+_deviceshm(struct userspace_chardev *cd, struct vbus_deviceshm *args)
+{
+	struct vbus_client *c = cd->client;
+	struct userspace_signal *_signal = NULL;
+	struct shm_signal *signal = NULL;
+	struct userspace_shm *_shm;
+	u64 handle;
+	long ret;
+
+	ret = userspace_shm_map(cd, args->datap, args->len, &_shm);
+	if (ret < 0)
+		return ret;
+
+	/*
+	 * Establishing a signal is optional
+	 */
+	if (args->signal.offset != -1) {
+		ret = userspace_signal_alloc(&_shm->shm,
+					     args->signal.offset,
+					     args->signal.prio,
+					     args->signal.cookie,
+					     &_signal);
+		if (ret < 0)
+			goto out;
+
+		_signal->cd = cd;
+		signal = &_signal->signal;
+	}
+
+	ret = c->ops->deviceshm(c, args->devh, args->id,
+				&_shm->shm, signal,
+				args->flags, &handle);
+	if (ret < 0)
+		goto out;
+
+	args->handle = handle;
+
+	return 0;
+
+out:
+	if (signal)
+		shm_signal_put(signal);
+
+	vbus_shm_put(&_shm->shm);
+	return ret;
+}
+
+static long
+_shmsignal(struct userspace_chardev *cd, unsigned long handle)
+{
+	struct vbus_client *c = cd->client;
+
+	return c->ops->shmsignal(c, handle);
+}
+
+static int
+vbus_chardev_open(struct inode *inode, struct file *filp)
+{
+	struct vbus *vbus = task_vbus_get(current);
+	struct vbus_client *client;
+	struct vbus_memctx *ctx;
+	struct userspace_chardev *cd;
+
+	if (!vbus)
+		return -EPERM;
+
+	client = vbus_client_attach(vbus);
+	vbus_put(vbus);
+	if (!client)
+		return -ENOMEM;
+
+	ctx = task_memctx_alloc(current);
+	if (!ctx) {
+		vbus_client_put(client);
+		return -ENOMEM;
+	}
+
+	cd = kzalloc(sizeof(*cd), GFP_KERNEL);
+	if (!cd) {
+		vbus_memctx_put(ctx);
+		vbus_client_put(client);
+		return -ENOMEM;
+	}
+
+	spin_lock_init(&cd->lock);
+	cd->opened = 0;
+	cd->client = client;
+	cd->ctx = ctx;
+
+	INIT_LIST_HEAD(&cd->signal_list);
+	init_waitqueue_head(&cd->wq);
+
+	filp->private_data = cd;
+
+	return 0;
+}
+
+static long
+vbus_chardev_ioctl(struct file *filp, unsigned int ioctl, unsigned long arg)
+{
+	struct userspace_chardev *cd = filp->private_data;
+
+	if (!cd->opened && ioctl != VBUS_BUSOPEN)
+		return -EINVAL;
+
+	switch (ioctl) {
+	case VBUS_BUSOPEN:
+		return _busopen(cd, (struct vbus_userspace_busopen *)arg);
+	case VBUS_DEVICEOPEN:
+		return _deviceopen(cd, (struct vbus_deviceopen *)arg);
+	case VBUS_DEVICECLOSE:
+		return _deviceclose(cd, *(__u64 *)arg);
+	case VBUS_DEVICECALL:
+		return _devicecall(cd, (struct vbus_devicecall *)arg);
+	case VBUS_DEVICESHM:
+		return _deviceshm(cd, (struct vbus_deviceshm *)arg);
+	case VBUS_SHMSIGNAL:
+		return _shmsignal(cd, *(__u64 *)arg);
+	default:
+		return -EINVAL;
+	}
+}
+
+static ssize_t
+vbus_chardev_read(struct file *filp, char __user *buf, size_t len,
+		  loff_t *ppos)
+{
+	DEFINE_WAIT(wait);
+	struct userspace_chardev *cd = filp->private_data;
+	ssize_t bytes = 0;
+	int count, i;
+	__u64 __user *p = (__u64 __user *)buf;
+	unsigned long flags;
+
+	count = len/sizeof(__u64);
+
+	if (!count)
+		return -EINVAL;
+
+	spin_lock_irqsave(&cd->lock, flags);
+
+	for (;;) {
+		prepare_to_wait(&cd->wq, &wait, TASK_INTERRUPTIBLE);
+
+		if (!list_empty(&cd->signal_list))
+			break;
+
+		if (signal_pending(current)) {
+			finish_wait(&cd->wq, &wait);
+			spin_unlock_irqrestore(&cd->lock, flags);
+			return -EINTR;
+		}
+
+		spin_unlock_irqrestore(&cd->lock, flags);
+		schedule();
+		spin_lock_irqsave(&cd->lock, flags);
+	}
+
+	finish_wait(&cd->wq, &wait);
+
+	for (i = 0; i < count; i++) {
+		struct userspace_signal *_signal;
+		__u64 cookie;
+
+		if (list_empty(&cd->signal_list))
+			break;
+
+		_signal = list_first_entry(&cd->signal_list,
+					   struct userspace_signal, list);
+
+		_signal->signaled = 0;
+		list_del(&_signal->list);
+
+		cookie = _signal->cookie;
+
+		put_user(cookie, p++);
+
+		bytes += sizeof(cookie);
+	}
+
+	spin_unlock_irqrestore(&cd->lock, flags);
+
+	return bytes;
+}
+
+static int
+vbus_chardev_release(struct inode *inode, struct file *filp)
+{
+	struct userspace_chardev *cd = filp->private_data;
+
+	vbus_memctx_put(cd->ctx);
+	vbus_client_put(cd->client);
+	kfree(cd);
+
+	return 0;
+}
+
+static const struct file_operations vbus_chardev_ops = {
+	.open           = vbus_chardev_open,
+	.read           = vbus_chardev_read,
+	.unlocked_ioctl = vbus_chardev_ioctl,
+	.compat_ioctl   = vbus_chardev_ioctl,
+	.release        = vbus_chardev_release,
+};
+
+static struct miscdevice vbus_chardev = {
+	MISC_DYNAMIC_MINOR,
+	"vbus",
+	&vbus_chardev_ops,
+};
+
+static int __init
+vbus_userspace_init(void)
+{
+	return misc_register(&vbus_chardev);
+}
+
+static void __exit
+vbus_userspace_cleanup(void)
+{
+	misc_deregister(&vbus_chardev);
+}
+
+module_init(vbus_userspace_init);
+module_exit(vbus_userspace_cleanup);

