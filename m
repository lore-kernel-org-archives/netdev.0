From: Rusty Russell <rusty@rustcorp.com.au>
Subject: [PATCH 2/5] /dev/vring: simple userspace-kernel ringbuffer interface.
Date: Fri, 18 Apr 2008 14:39:48 +1000
Message-ID: <200804181439.49051.rusty@rustcorp.com.au>
References: <200804181433.48488.rusty@rustcorp.com.au> <200804181435.21214.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Max Krasnyansky <maxk@qualcomm.com>,
	virtualization@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:45643 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750999AbYDREkd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Apr 2008 00:40:33 -0400
In-Reply-To: <200804181435.21214.rusty@rustcorp.com.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

virtio introduced a ring structure ABI for guest-host communications
(currently used by lguest and kvm).  Using this same ABI, we can
create a nice fd version.

This is useful for efficiently passing packets to and from the tun,
for example.

Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
---
 drivers/char/Kconfig  |    9 +
 drivers/char/Makefile |    2 
 drivers/char/vring.c  |  400 ++++++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/vring.h |   58 +++++++
 4 files changed, 469 insertions(+)

diff -r b2d9869d338f drivers/char/Kconfig
--- a/drivers/char/Kconfig	Fri Apr 18 10:33:58 2008 +1000
+++ b/drivers/char/Kconfig	Fri Apr 18 13:35:16 2008 +1000
@@ -1049,5 +1049,14 @@ config DEVPORT
 
 source "drivers/s390/char/Kconfig"
 
+config VRING
+       tristate "/dev/vring support (EXPERIMENTAL)"
+       depends on EXPERIMENTAL
+       help
+         vring is a ringbuffer implementation for efficient I/O.  It is
+	 currently used by virtualization hosts (lguest, kvm) for efficient
+	 networking using the tun driver.
+
+	 If unsure, say N, but there's a part of you that wants to say M.
 endmenu
 
diff -r b2d9869d338f drivers/char/Makefile
--- a/drivers/char/Makefile	Fri Apr 18 10:33:58 2008 +1000
+++ b/drivers/char/Makefile	Fri Apr 18 13:35:16 2008 +1000
@@ -112,6 +112,8 @@ obj-$(CONFIG_JS_RTC)		+= js-rtc.o
 obj-$(CONFIG_JS_RTC)		+= js-rtc.o
 js-rtc-y = rtc.o
 
+obj-$(CONFIG_VRING)		+= vring.o
+
 # Files generated that shall be removed upon make clean
 clean-files := consolemap_deftbl.c defkeymap.c
 
diff -r b2d9869d338f drivers/char/vring.c
--- /dev/null	Thu Jan 01 00:00:00 1970 +0000
+++ b/drivers/char/vring.c	Fri Apr 18 13:35:16 2008 +1000
@@ -0,0 +1,400 @@
+/* Ring-buffer device implementation.
+ *
+ *  Copyright 2008 Rusty Russell IBM Corporation
+ *
+ *  This program is free software; you can redistribute it and/or modify
+ *  it under the terms of the GNU General Public License as published by
+ *  the Free Software Foundation; either version 2 of the License, or
+ *  (at your option) any later version.
+ *
+ *  This program is distributed in the hope that it will be useful,
+ *  but WITHOUT ANY WARRANTY; without even the implied warranty of
+ *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ *  GNU General Public License for more details.
+ *
+ *  You should have received a copy of the GNU General Public License
+ *  along with this program; if not, write to the Free Software
+ *  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
+ */
+#include <linux/virtio_ring.h>
+#include <linux/vring.h>
+#include <linux/init.h>
+#include <linux/mutex.h>
+#include <linux/wait.h>
+#include <linux/fs.h>
+#include <linux/poll.h>
+#include <linux/module.h>
+#include <linux/miscdevice.h>
+
+struct vring_info {
+	struct mutex lock;
+
+	struct vring ring;
+	u16 mask;
+	u16 last_used;
+
+	const struct vring_ops *ops;
+	void *ops_data;
+
+	/* Waitqueue for poll() */
+	wait_queue_head_t poll_wait;
+};
+
+static unsigned int vring_poll(struct file *filp,
+			       struct poll_table_struct *poll)
+{
+	struct vring_info *vr = filp->private_data;
+	unsigned int mask;
+	u16 used = 0;
+
+	/* Poll can't error, so let's not go silly here. */
+	get_user(used, &vr->ring.used->idx);
+
+	/* More buffers have been used?  It's 'readable'. */
+	if (used != vr->last_used)
+		mask = POLLIN | POLLRDNORM;
+	else {
+		mask = 0;
+		/* If we need to pull, it's also readable. */
+		mutex_lock(&vr->lock);
+		if (vr->ops && vr->ops->needs_pull) {
+			if (vr->ops->needs_pull(vr->ops_data))
+				mask = POLLIN | POLLRDNORM;
+		}
+		mutex_unlock(&vr->lock);
+	}
+
+	poll_wait(filp, &vr->poll_wait, poll);
+
+	return mask;
+}
+
+/* Read may not be necessary for all use cases, in fact. */
+static ssize_t vring_read(struct file *filp, char __user *buf,
+			  size_t size, loff_t *off)
+{
+	struct vring_info *vr = filp->private_data;
+	int err;
+
+	/* Some uses of vrings require updating in user context.  This
+	 * is best done close to the caller, ie. here. */
+	mutex_lock(&vr->lock);
+	if (vr->ops && vr->ops->pull)
+		err = vr->ops->pull(vr->ops_data);
+	else
+		err = 0;
+	mutex_unlock(&vr->lock);
+
+	/* Update our last_used value to clear the poll. */
+	if (!err)
+		err = get_user(vr->last_used, &vr->ring.used->idx);
+
+	return err;
+}
+
+/* Write kicks the other end to say we have buffers. */
+static ssize_t vring_write(struct file *filp, const char __user *buf,
+			   size_t size, loff_t *off)
+{
+	struct vring_info *vr = filp->private_data;
+	int err;
+
+	mutex_lock(&vr->lock);
+	if (vr->ops && vr->ops->push)
+		err = vr->ops->push(vr->ops_data);
+	else
+		err = 0;
+	mutex_unlock(&vr->lock);
+
+	return err;
+}
+
+/* We assume anyone attached holds a reference, so this won't mess them up */
+static int vring_release(struct inode *inode, struct file *filp)
+{
+	struct vring_info *vr = filp->private_data;
+
+	kfree(vr);
+	return 0;
+}
+
+static int vring_mmap(struct file *filp, struct vm_area_struct *vma)
+{
+	unsigned long size, num_descs;
+	struct vring_info *vr = filp->private_data;
+	int err;
+
+	/* We overload mmap's offset to hold the ring number. */
+	num_descs = vma->vm_pgoff;
+
+	/* Must be a power of two, and limit indices to a u16. */
+	if (!num_descs || (num_descs & (num_descs-1)) || num_descs > 65536)
+		return -EINVAL;
+
+	/* mmap size must be what we expect for such a ring. */
+	size = vma->vm_end - vma->vm_start;
+	if (size != ALIGN(vring_size(num_descs, PAGE_SIZE), PAGE_SIZE))
+		return -EINVAL;
+
+	/* We only let them map this in one place. */
+	mutex_lock(&vr->lock);
+	if (vr->ring.num != 0) {
+		err = -EBUSY;
+		goto unlock;
+	}
+
+	vring_init(&vr->ring, num_descs, (void *)vma->vm_start, PAGE_SIZE);
+
+	vr->mask = num_descs - 1;
+	err = 0;
+
+unlock:
+	mutex_unlock(&vr->lock);
+	return err;
+}
+
+static int vring_open(struct inode *in, struct file *filp)
+{
+	struct vring_info *vr;
+
+	filp->private_data = vr = kzalloc(sizeof(*vr), GFP_KERNEL);
+	if (!vr)
+		return -ENOMEM;
+
+	init_waitqueue_head(&vr->poll_wait);
+	mutex_init(&vr->lock);
+	return 0;
+}
+
+static const struct file_operations vring_fops = {
+	.open		= vring_open,
+	.release	= vring_release,
+	.mmap		= vring_mmap,
+	.read		= vring_read,
+	.write		= vring_write,
+	.poll		= vring_poll,
+};
+
+/**
+ * vring_get_buffer - get a buffer from the vring
+ * @vr: the vring
+ * @in_iov: the iovec array for input buffers
+ * @num_in: the size of the in_iov array, updated by this function.
+ * @in_len: the total length of in_iov after this function.
+ * @out_iov: the iovec array for output buffers
+ * @num_out: the size of the ut_iov array, updated by this function.
+ * @out_len: the total length of out_iov after this function.
+ *
+ * A vring buffer is an array of input and output parts.  This gets the next
+ * available buffer, and returns a non-zero id which is handed back to
+ * vring_used_buffer() once you're finished with the buffer.  A zero return
+ * means no available buffers, negative for error.
+ */
+int vring_get_buffer(struct vring_info *vr,
+		     struct iovec *in_iov,
+		     unsigned int *num_in, unsigned long *in_len,
+		     struct iovec *out_iov,
+		     unsigned int *num_out, unsigned long *out_len)
+{
+	unsigned int i, in = 0, out = 0;
+	unsigned long dummy;
+	u16 avail, last_avail, head;
+	struct vring_desc d;
+
+	if (unlikely(get_user(avail, &vr->ring.avail->idx)))
+		return -EFAULT;
+	if (unlikely(get_user(last_avail, &vring_last_avail(&vr->ring))))
+		return -EFAULT;
+
+	if (last_avail == avail)
+		return 0;
+
+	if (!in_len)
+		in_len = &dummy;
+	if (!out_len)
+		out_len = &dummy;
+
+	*in_len = *out_len = 0;
+
+	if (unlikely(get_user(head, &vr->ring.avail->ring[last_avail
+							  & vr->mask])))
+		return -EFAULT;
+
+	i = head;
+	do {
+		if (unlikely(i >= vr->ring.num)) {
+			pr_debug("vring: bad index: %u\n", i);
+			return -EINVAL;
+		}
+
+		if (copy_from_user(&d, &vr->ring.desc[i], sizeof(d)) != 0)
+			return -EFAULT;
+
+		if (d.flags & VRING_DESC_F_WRITE) {
+			/* Check for length and iovec overflows */
+			if (!num_in) {
+				pr_debug("vring: writable desc %u in ring %p\n",
+					 i, vr->ring.desc);
+				return -EINVAL;
+			}
+			if (in == *num_in || *in_len + d.len < *in_len)
+				return -E2BIG;
+			in_iov[in].iov_len = d.len;
+			*in_len += d.len;
+			in_iov[in].iov_base = (void __user *)(long)d.addr;
+			in++;
+		} else {
+			if (!num_out) {
+				pr_debug("vring: readable desc %u in ring %p\n",
+					 i, vr->ring.desc);
+				return -EINVAL;
+			}
+			if (out == *num_out || *out_len + d.len < *out_len)
+				return -E2BIG;
+			out_iov[out].iov_len = d.len;
+			*out_len += d.len;
+			out_iov[out].iov_base = (void __user *)(long)d.addr;
+			out++;
+		}
+
+		i = d.next;
+	} while (d.flags & VRING_DESC_F_NEXT);
+
+	if (num_in)
+		*num_in = in;
+	if (num_out)
+		*num_out = out;
+
+	last_avail++;
+	put_user(last_avail, &vring_last_avail(&vr->ring));
+
+	/* 0 is a valid head, so add one. */
+	return head + 1;
+}
+EXPORT_SYMBOL_GPL(vring_get_buffer);
+
+/**
+ * vring_used_buffer - return a used buffer to the vring
+ * @vr: the vring
+ * @id: the id returned from vring_get_buffer
+ * @len: the total bytes *written* to the buffer
+ */
+void vring_used_buffer(struct vring_info *vr, int id, u32 len)
+{
+	struct vring_used_elem used;
+	u16 used_idx;
+
+	BUG_ON(id <= 0 || id > vr->ring.num);
+
+	used.id = id - 1;
+	used.len = len;
+	if (get_user(used_idx, &vr->ring.used->idx) != 0)
+		return;
+
+	if (copy_to_user(&vr->ring.used->ring[used_idx & vr->mask], &used,
+			 sizeof(used)))
+		return;
+
+	wmb();
+	used_idx++;
+	put_user(used_idx, &vr->ring.used->idx);
+}
+EXPORT_SYMBOL_GPL(vring_used_buffer);
+
+void vring_wake(struct vring_info *vr)
+{
+	wake_up(&vr->poll_wait);
+}
+EXPORT_SYMBOL_GPL(vring_wake);
+
+/**
+ * vring_get - check out a vring file descriptor
+ * @filp: the file structure to attach to (eg. from fget()).
+ *
+ * Userspace opens /dev/vring and mmaps it, then hands that fd to the
+ * kernel subsystem it wants to communicate with.  That subsystem uses
+ * this routine and vring_set_ops() to attach to it.
+ *
+ * This simply checks that it really is a vring fd (otherwise it
+ * returns NULL), the other routine checks that it's not already
+ * attached.
+ */
+struct vring_info *vring_get(struct file *filp)
+{
+	/* Must be one of ours. */
+	if (filp->f_op != &vring_fops)
+		return NULL;
+
+	return filp->private_data;
+}
+EXPORT_SYMBOL_GPL(vring_get);
+
+/**
+ * vring_set_ops - attach operations to a vring file descriptor.
+ * @vr: the vring_info returned from vring_get.
+ * @ops: the operations to attach.
+ * @ops_data: the argument to the ops callbacks.
+ *
+ * This is called after vring_get(): the reason for the two-part
+ * process is that the ops can be called before vring_set_ops returns
+ * (we don't do locking), so you really need to set things up before
+ * this call.
+ *
+ * This simply checks that the ring is not already attached to something,
+ * then sets the ops.
+ */
+int vring_set_ops(struct vring_info *vr,
+		  const struct vring_ops *ops, void *ops_data)
+{
+	int err;
+
+	mutex_lock(&vr->lock);
+	if (vr->ops) {
+		err = -EBUSY;
+		goto unlock;
+	}
+
+	/* We don't lock, so make sure we get this in the right order. */
+	vr->ops_data = ops_data;
+	wmb();
+	vr->ops = ops;
+
+	err = 0;
+unlock:
+	mutex_unlock(&vr->lock);
+	local_irq_enable();
+	return err;
+}
+EXPORT_SYMBOL_GPL(vring_set_ops);
+
+/**
+ * vring_unset_ops - remove operations to a vring file descriptor.
+ * @vr: the vring_info previously successfully vring_set_ops'd
+ */
+void vring_unset_ops(struct vring_info *vr)
+{
+	BUG_ON(!vr->ops);
+	mutex_lock(&vr->lock);
+	vr->ops = NULL;
+	mutex_unlock(&vr->lock);
+}
+EXPORT_SYMBOL_GPL(vring_unset_ops);
+
+static struct miscdevice vring_dev = {
+	.minor = MISC_DYNAMIC_MINOR,
+	.name = KBUILD_MODNAME,
+	.fops = &vring_fops,
+};
+
+static int __init init(void)
+{
+	return misc_register(&vring_dev);
+}
+
+static void __exit fini(void)
+{
+	misc_deregister(&vring_dev);
+}
+
+module_init(init);
+module_exit(fini);
diff -r b2d9869d338f include/linux/vring.h
--- /dev/null	Thu Jan 01 00:00:00 1970 +0000
+++ b/include/linux/vring.h	Fri Apr 18 13:35:16 2008 +1000
@@ -0,0 +1,58 @@
+/* Ring-buffer file descriptor implementation.
+ *
+ *  Copyright 2008 Rusty Russell IBM Corporation
+ *
+ *  This program is free software; you can redistribute it and/or modify
+ *  it under the terms of the GNU General Public License as published by
+ *  the Free Software Foundation; either version 2 of the License, or
+ *  (at your option) any later version.
+ *
+ *  This program is distributed in the hope that it will be useful,
+ *  but WITHOUT ANY WARRANTY; without even the implied warranty of
+ *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ *  GNU General Public License for more details.
+ *
+ *  You should have received a copy of the GNU General Public License
+ *  along with this program; if not, write to the Free Software
+ *  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
+ */
+#ifndef _LINUX_VRING_H
+#define _LINUX_VRING_H
+
+/**
+ * vring_ops - operations for a vring fd.
+ * @needs_pull: more data is pending, need to call pull.
+ * @pull: callback when read() is called to report used buffers.
+ * @push: callback when write() is called to notify of added buffers.
+ *
+ * Any of these callbacks can be NULL, if you don't need them.
+ */
+struct vring_ops {
+	bool (*needs_pull)(void *ops_data);
+
+	/* Returns 0 or negative errno. */
+	int (*pull)(void *ops_data);
+
+	/* Returns 0 or negative errno. */
+	int (*push)(void *ops_data);
+};
+
+struct file;
+
+struct vring_info *vring_get(struct file *filp);
+int vring_set_ops(struct vring_info *,
+		  const struct vring_ops *ops, void *ops_data);
+void vring_unset_ops(struct vring_info *vr);
+struct iovec;
+
+/* Returns an error, or 0 (no buffers), or an id for vring_used_buffer() */
+int vring_get_buffer(struct vring_info *vr,
+		     struct iovec *in_iov,
+		     unsigned int *num_in, unsigned long *in_len,
+		     struct iovec *out_iov,
+		     unsigned int *num_out, unsigned long *out_len);
+
+void vring_used_buffer(struct vring_info *vr, int id, u32 len);
+
+void vring_wake(struct vring_info *vr);
+#endif /* _LINUX_VRING_H */
