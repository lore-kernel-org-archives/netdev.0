From: Rusty Russell <rusty@rustcorp.com.au>
Subject: [PATCH RFC 1/5] vringfd syscall
Date: Sat, 5 Apr 2008 22:02:08 +1000
Message-ID: <200804052202.09157.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	Max Krasnyansky <maxk@qualcomm.com>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:48937 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751642AbYDEMCd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Apr 2008 08:02:33 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For virtualization, we've developed virtio_ring for efficient communication.
This would also work well for userspace-kernel communication, particularly
for things like the tun device.  By using the same ABI, we can join guests
to the host kernel trivially.

These patches are fairly alpha; I've seen some network stalls I have to
track down and there are some fixmes.

Comments welcome!
Rusty.

diff -r 99132ad16999 Documentation/test_vring.c
--- /dev/null	Thu Jan 01 00:00:00 1970 +0000
+++ b/Documentation/test_vring.c	Sat Apr 05 21:31:40 2008 +1100
@@ -0,0 +1,47 @@
+#include <unistd.h>
+#include <linux/virtio_ring.h>
+#include <stdio.h>
+#include <stdint.h>
+#include <err.h>
+#include <poll.h>
+
+#ifndef __NR_vringfd
+#define __NR_vringfd		327
+#endif
+
+int main()
+{
+	int fd, r;
+	struct vring vr;
+	uint16_t used = 0;
+	struct pollfd pfd;
+	void *buf = calloc(vring_size(256, getpagesize()), 0);
+
+	vring_init(&vr, 256, buf, getpagesize());
+
+	fd = syscall(__NR_vringfd, buf, 256, &used);
+	if (fd < 0)
+		err(1, "vringfd gave %i", fd);
+
+	pfd.fd = fd;
+	pfd.events = POLLIN;
+	r = poll(&pfd, 1, 0);
+	
+	if (r != 0)
+		err(1, "poll gave %i", r);
+
+	vr.used->idx++;
+	r = poll(&pfd, 1, 0);
+	
+	if (r != 1)
+		err(1, "poll after buf used gave %i", r);
+
+	used++;
+	r = poll(&pfd, 1, 0);
+	
+	if (r != 0)
+		err(1, "poll after used incremented gave %i", r);
+
+	close(fd);
+	return 0;
+}
diff -r 99132ad16999 arch/x86/kernel/syscall_table_32.S
--- a/arch/x86/kernel/syscall_table_32.S	Sat Apr 05 21:20:32 2008 +1100
+++ b/arch/x86/kernel/syscall_table_32.S	Sat Apr 05 21:31:40 2008 +1100
@@ -326,3 +326,4 @@ ENTRY(sys_call_table)
 	.long sys_fallocate
 	.long sys_timerfd_settime	/* 325 */
 	.long sys_timerfd_gettime
+	.long sys_vringfd
diff -r 99132ad16999 fs/Kconfig
--- a/fs/Kconfig	Sat Apr 05 21:20:32 2008 +1100
+++ b/fs/Kconfig	Sat Apr 05 21:31:40 2008 +1100
@@ -2135,4 +2135,14 @@ source "fs/nls/Kconfig"
 source "fs/nls/Kconfig"
 source "fs/dlm/Kconfig"
 
+config VRINGFD
+       bool "vring fd support (EXPERIMENTAL)"
+       depends on EXPERIMENTAL
+       help
+         vring is a ringbuffer implementation for efficient I/O.  It is
+	 currently used by virtualization hosts (lguest, kvm) for efficient
+	 networking using the tun driver.
+
+	 If unsure, say N.
+
 endmenu
diff -r 99132ad16999 fs/Makefile
--- a/fs/Makefile	Sat Apr 05 21:20:32 2008 +1100
+++ b/fs/Makefile	Sat Apr 05 21:31:40 2008 +1100
@@ -119,3 +119,4 @@ obj-$(CONFIG_DEBUG_FS)		+= debugfs/
 obj-$(CONFIG_DEBUG_FS)		+= debugfs/
 obj-$(CONFIG_OCFS2_FS)		+= ocfs2/
 obj-$(CONFIG_GFS2_FS)           += gfs2/
+obj-$(CONFIG_VRINGFD)		+= vring.o
diff -r 99132ad16999 fs/vring.c
--- /dev/null	Thu Jan 01 00:00:00 1970 +0000
+++ b/fs/vring.c	Sat Apr 05 21:31:40 2008 +1100
@@ -0,0 +1,376 @@
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
+#include <linux/virtio_ring.h>
+#include <linux/vring.h>
+#include <linux/init.h>
+#include <linux/mutex.h>
+#include <linux/wait.h>
+#include <linux/fs.h>
+#include <linux/poll.h>
+#include <linux/highmem.h>
+#include <linux/file.h>
+#include <linux/mount.h>
+#include <linux/magic.h>
+#include <linux/module.h>
+
+static struct vfsmount *vring_mnt;
+static DEFINE_MUTEX(vring_lock);
+
+struct vring_info
+{
+	struct vring ring;
+	u16 mask;
+	u16 __user *last_used;
+	u16 last_avail;
+
+	const struct vring_ops *ops;
+	void *ops_data;
+
+	/* Waitqueue for poll() */
+	wait_queue_head_t poll_wait;
+
+	/* The mapped used ring. */
+	struct vring_used *used;
+	struct page *used_page;
+};
+
+static unsigned int vring_poll(struct file *filp,
+			       struct poll_table_struct *poll)
+{
+	struct vring_info *vr = filp->private_data;
+	int err;
+	unsigned int mask;
+	u16 used, last_used;
+
+	/* Some uses of vrings require updating in user context.  This
+	 * is best done close to the caller, ie. here. */
+	if (vr->ops && vr->ops->pull) {
+		err = vr->ops->pull(vr->ops_data);
+		if (unlikely(err < 0))
+			return err;
+
+		if (err > 0) {
+			/* Buffers have been used, no need to check indices */
+			mask = POLLIN | POLLRDNORM;
+			goto poll_wait;
+		}
+	}
+
+	err = get_user(used, &vr->ring.used->idx);
+	if (unlikely(err))
+		return err;
+
+	err = get_user(last_used, vr->last_used);
+	if (unlikely(err))
+		return err;
+
+	/* More buffers have been used?  It's 'readable'. */
+	if (used != last_used)
+		mask = POLLIN | POLLRDNORM;
+	else
+		mask = 0;
+
+poll_wait:
+	poll_wait(filp, &vr->poll_wait, poll);
+
+	return mask;
+}
+
+static ssize_t vring_write(struct file *filp, const char __user *buf,
+			   size_t size, loff_t *off)
+{
+	struct vring_info *vr = filp->private_data;
+
+	if (vr->ops && vr->ops->push)
+		return vr->ops->push(vr->ops_data);
+
+	return -EINVAL;
+}
+
+static int vring_release(struct inode *inode, struct file *filp)
+{
+	struct vring_info *vr = filp->private_data;
+
+	/* Callback for other end. */
+	if (vr->ops && vr->ops->destroy)
+		vr->ops->destroy(vr->ops_data);
+
+	if (vr->used) {
+		kunmap(vr->used_page);
+		put_page(vr->used_page);
+	}
+
+	kfree(vr);
+	return 0;
+}
+
+static const struct file_operations vring_fops = {
+	.release	= vring_release,
+	.write		= vring_write,
+	.poll		= vring_poll,
+};
+
+asmlinkage long sys_vringfd(void __user *addr,
+			    unsigned num_descs,
+			    u16 __user *last_used)
+{
+	int fd, err;
+	struct file *filp;
+	struct vring_info *vr;
+
+	/* Must be a power of two, and representable by u16 */
+	if (!num_descs || (num_descs & (num_descs-1)) || num_descs > 65536) {
+		err = -EINVAL;
+		goto out;
+	}
+
+	fd = get_unused_fd();
+	if (fd < 0) {
+		err = fd;
+		goto out;
+	}
+
+	filp = alloc_file(vring_mnt, dget(vring_mnt->mnt_root), FMODE_WRITE,
+			  &vring_fops);
+	if (!filp) {
+		err = -ENFILE;
+		goto put_fd;
+	}
+
+	filp->private_data = vr = kmalloc(sizeof(*vr), GFP_KERNEL);
+	if (!vr) {
+		err = -ENOMEM;
+		goto put_filp;
+	}
+
+	/* Set up pointers into ring. */
+	vring_init(&vr->ring, num_descs, addr, PAGE_SIZE);
+	init_waitqueue_head(&vr->poll_wait);
+	vr->last_used = last_used;
+	vr->mask = num_descs - 1;
+	vr->ops = NULL;
+	vr->used = NULL;
+
+	err = get_user(vr->last_avail, &vr->ring.avail->idx);
+	if (err)
+		goto free_vr;
+	
+	fd_install(fd, filp);
+	return fd;
+
+free_vr:
+	kfree(vr);
+put_filp:
+	put_filp(filp);
+put_fd:
+	put_unused_fd(fd);
+out:
+	return err;
+}
+
+/* Returns an error, or 0 (no buffers), or an id for vring_used_buffer() */
+int vring_get_buffer(struct vring_info *vr,
+		     struct iovec *in_iov,
+		     unsigned int *num_in, unsigned long *in_len,
+		     struct iovec *out_iov,
+		     unsigned int *num_out, unsigned long *out_len)
+{
+	unsigned int i, in = 0, out = 0;
+	unsigned long dummy;
+	u16 head;
+	struct vring_desc d;
+
+	if (unlikely(get_user(head, &vr->ring.avail->idx) != 0))
+		return -EFAULT;
+
+	if (vr->last_avail == head)
+		return 0;
+
+	if (!in_len)
+		in_len = &dummy;
+	if (!out_len)
+		out_len = &dummy;
+
+	*in_len = *out_len = 0;
+	
+	if (unlikely(get_user(head, &vr->ring.avail->ring[head]) != 0))
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
+			if (!num_in)
+				return -EINVAL;
+			if (in == *num_in || *in_len + d.len < *in_len)
+				return -E2BIG;
+			in_iov[in].iov_len = d.len;
+			*in_len += d.len;
+			in_iov[in].iov_base = (void __user*)(long)d.addr;
+			in++;
+		} else {
+			if (!num_out)
+				return -EINVAL;
+			if (out == *num_out || *out_len + d.len < *out_len)
+				return -E2BIG;
+			out_iov[out].iov_len = d.len;
+			*out_len += d.len;
+			out_iov[out].iov_base = (void __user*)(long)d.addr;
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
+	/* 0 is a valid head, so add one. */
+	vr->last_avail++;
+	return head + 1;
+}
+EXPORT_SYMBOL_GPL(vring_get_buffer);
+
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
+	copy_to_user(&vr->ring.used->ring[used_idx & vr->mask], &used,
+		     sizeof(used));
+	wmb();
+	used_idx++;
+	put_user(used_idx, &vr->ring.used->idx);
+}
+EXPORT_SYMBOL_GPL(vring_used_buffer);
+
+void vring_used_buffer_atomic(struct vring_info *vr, int id, u32 len)
+{
+	struct vring_used_elem *used;
+
+	BUG_ON(id <= 0 || id > vr->ring.num);
+	BUG_ON(!vr->used);
+
+	used = &vr->used->ring[vr->used->idx & vr->mask];
+	used->id = id - 1;
+	used->len = len;
+	/* Make sure buffer is written before we update index. */
+	wmb();
+	vr->used->idx++;
+}
+EXPORT_SYMBOL_GPL(vring_used_buffer_atomic);
+
+void vring_wake(struct vring_info *vr)
+{
+	wake_up(&vr->poll_wait);
+}
+EXPORT_SYMBOL_GPL(vring_wake);
+
+struct vring_info *vring_attach(int fd, const struct vring_ops *ops,
+				void *data, bool atomic_use)
+{
+	struct file *filp;
+	struct vring_info *vr;
+
+	/* Must be a valid fd, and must be one of ours. */
+	filp = fget(fd);
+	if (!filp) {
+		vr = ERR_PTR(-EBADF);
+		goto out;
+	}
+
+	if (filp->f_op != &vring_fops) {
+		vr = ERR_PTR(-EBADF);
+		goto fput;
+	}
+
+	/* Mutex simply protects against parallel vring_attach. */
+	mutex_lock(&vring_lock);
+	vr = filp->private_data;
+	if (vr->ops) {
+		vr = ERR_PTR(-EBUSY);
+		goto unlock;
+	}
+
+	/* If they want to use atomically, we have to map the page. */
+	if (atomic_use) {
+		if (get_user_pages(current, current->mm,
+				   (unsigned long)vr->ring.used, 1, 1, 1,
+				   &vr->used_page, NULL) != 1) {
+			vr = ERR_PTR(-EFAULT);
+			goto unlock;
+		}
+		vr->used = kmap(vr->used_page);
+		if (!vr->used) {
+			put_page(vr->used_page);
+			vr = ERR_PTR(-ENOMEM);
+			goto unlock;
+		}
+	}
+
+	vr->ops = ops;
+	vr->ops_data = data;
+
+unlock:
+	mutex_unlock(&vring_lock);
+fput:
+	fput(filp);
+out:
+	return vr;
+}
+EXPORT_SYMBOL_GPL(vring_attach);
+
+static int vringfs_get_sb(struct file_system_type *fs_type,
+			  int flags, const char *dev_name, void *data,
+			  struct vfsmount *mnt)
+{
+	return get_sb_pseudo(fs_type, "vring", NULL, VRINGFS_SUPER_MAGIC, mnt);
+}
+
+static struct file_system_type vring_fs_type = {
+	.name		= "vringfs",
+	.get_sb		= vringfs_get_sb,
+	.kill_sb	= kill_anon_super,
+};
+
+static int init(void)
+{
+	register_filesystem(&vring_fs_type);
+	vring_mnt = kern_mount(&vring_fs_type);
+	return 0;
+}
+
+module_init(init);
diff -r 99132ad16999 include/asm-x86/unistd_32.h
--- a/include/asm-x86/unistd_32.h	Sat Apr 05 21:20:32 2008 +1100
+++ b/include/asm-x86/unistd_32.h	Sat Apr 05 21:31:40 2008 +1100
@@ -332,6 +332,7 @@
 #define __NR_fallocate		324
 #define __NR_timerfd_settime	325
 #define __NR_timerfd_gettime	326
+#define __NR_vringfd		327
 
 #ifdef __KERNEL__
 
diff -r 99132ad16999 include/linux/magic.h
--- a/include/linux/magic.h	Sat Apr 05 21:20:32 2008 +1100
+++ b/include/linux/magic.h	Sat Apr 05 21:31:40 2008 +1100
@@ -41,5 +41,6 @@
 
 #define FUTEXFS_SUPER_MAGIC	0xBAD1DEA
 #define INOTIFYFS_SUPER_MAGIC	0x2BAD1DEA
+#define VRINGFS_SUPER_MAGIC	0xB1BBAD
 
 #endif /* __LINUX_MAGIC_H__ */
diff -r 99132ad16999 include/linux/syscalls.h
--- a/include/linux/syscalls.h	Sat Apr 05 21:20:32 2008 +1100
+++ b/include/linux/syscalls.h	Sat Apr 05 21:31:40 2008 +1100
@@ -614,6 +614,7 @@ asmlinkage long sys_timerfd_gettime(int 
 asmlinkage long sys_timerfd_gettime(int ufd, struct itimerspec __user *otmr);
 asmlinkage long sys_eventfd(unsigned int count);
 asmlinkage long sys_fallocate(int fd, int mode, loff_t offset, loff_t len);
+asmlinkage long sys_vringfd(void __user *, unsigned num, u16 __user *);
 
 int kernel_execve(const char *filename, char *const argv[], char *const envp[]);
 
diff -r 99132ad16999 include/linux/vring.h
--- /dev/null	Thu Jan 01 00:00:00 1970 +0000
+++ b/include/linux/vring.h	Sat Apr 05 21:31:40 2008 +1100
@@ -0,0 +1,54 @@
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
+/* All members are optional */
+struct vring_ops
+{
+	/* Cleanup */
+	void (*destroy)(void *);
+
+	/* Returns number of used buffers, or negative errno. */
+	int (*pull)(void *);
+
+	/* Returns 0 or negative errno. */
+	int (*push)(void *);
+};
+
+/* If they want to call vring_used_buffer_atomic(), set atomic_use.
+ * This currently means that the userspace used buffer must fit in a page. */
+struct vring_info *vring_attach(int fd, const struct vring_ops *ops,
+				void *data, bool atomic_use);
+
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
+void vring_used_buffer_atomic(struct vring_info *vr, int id, u32 len);
+
+void vring_wake(struct vring_info *vr);
+#endif /* _LINUX_VRING_H */
diff -r 99132ad16999 kernel/sys_ni.c
--- a/kernel/sys_ni.c	Sat Apr 05 21:20:32 2008 +1100
+++ b/kernel/sys_ni.c	Sat Apr 05 21:31:40 2008 +1100
@@ -161,3 +161,4 @@ cond_syscall(compat_sys_timerfd_settime)
 cond_syscall(compat_sys_timerfd_settime);
 cond_syscall(compat_sys_timerfd_gettime);
 cond_syscall(sys_eventfd);
+cond_syscall(sys_vringfd);
