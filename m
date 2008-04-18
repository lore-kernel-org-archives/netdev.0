From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/5] /dev/vring: simple userspace-kernel ringbuffer
 interface.
Date: Fri, 18 Apr 2008 04:18:46 -0700
Message-ID: <20080418041846.db15150b.akpm@linux-foundation.org>
References: <200804181433.48488.rusty@rustcorp.com.au>
	<200804181435.21214.rusty@rustcorp.com.au>
	<200804181439.49051.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Max Krasnyansky <maxk@qualcomm.com>,
	virtualization@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:43331 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751268AbYDRLSy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Apr 2008 07:18:54 -0400
In-Reply-To: <200804181439.49051.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 18 Apr 2008 14:39:48 +1000 Rusty Russell <rusty@rustcorp.com.au> wrote:

> virtio introduced a ring structure ABI for guest-host communications
> (currently used by lguest and kvm).  Using this same ABI, we can
> create a nice fd version.
> 
> This is useful for efficiently passing packets to and from the tun,
> for example.
> 
> ...
>
> +static int vring_mmap(struct file *filp, struct vm_area_struct *vma)
> +{
> +	unsigned long size, num_descs;
> +	struct vring_info *vr = filp->private_data;
> +	int err;
> +
> +	/* We overload mmap's offset to hold the ring number. */
> +	num_descs = vma->vm_pgoff;
> +
> +	/* Must be a power of two, and limit indices to a u16. */
> +	if (!num_descs || (num_descs & (num_descs-1)) || num_descs > 65536)

We have an is_power_of_2().

> +		return -EINVAL;
> +
> +	/* mmap size must be what we expect for such a ring. */
> +	size = vma->vm_end - vma->vm_start;
> +	if (size != ALIGN(vring_size(num_descs, PAGE_SIZE), PAGE_SIZE))
> +		return -EINVAL;
> +
> +	/* We only let them map this in one place. */
> +	mutex_lock(&vr->lock);
> +	if (vr->ring.num != 0) {
> +		err = -EBUSY;
> +		goto unlock;
> +	}
> +
> +	vring_init(&vr->ring, num_descs, (void *)vma->vm_start, PAGE_SIZE);
> +
> +	vr->mask = num_descs - 1;
> +	err = 0;
> +
> +unlock:
> +	mutex_unlock(&vr->lock);
> +	return err;
> +}
>
> ...
>
> +/**
> + * vring_get - check out a vring file descriptor
> + * @filp: the file structure to attach to (eg. from fget()).
> + *
> + * Userspace opens /dev/vring and mmaps it, then hands that fd to the
> + * kernel subsystem it wants to communicate with.  That subsystem uses
> + * this routine and vring_set_ops() to attach to it.
> + *
> + * This simply checks that it really is a vring fd (otherwise it
> + * returns NULL), the other routine checks that it's not already
> + * attached.
> + */

hm, I don't understand the big picture here yet.

Isn't this kinda-sorta like what a relayfs file does?  The oprofile
buffers?  etc?  Nothing in common at all, no hope?

> +struct vring_info *vring_get(struct file *filp)
> +{
> +	/* Must be one of ours. */
> +	if (filp->f_op != &vring_fops)
> +		return NULL;
> +
> +	return filp->private_data;
> +}
> +EXPORT_SYMBOL_GPL(vring_get);
> +
> +/**
> + * vring_set_ops - attach operations to a vring file descriptor.
> + * @vr: the vring_info returned from vring_get.
> + * @ops: the operations to attach.
> + * @ops_data: the argument to the ops callbacks.
> + *
> + * This is called after vring_get(): the reason for the two-part
> + * process is that the ops can be called before vring_set_ops returns
> + * (we don't do locking), so you really need to set things up before
> + * this call.
> + *
> + * This simply checks that the ring is not already attached to something,
> + * then sets the ops.
> + */
> +int vring_set_ops(struct vring_info *vr,
> +		  const struct vring_ops *ops, void *ops_data)
> +{
> +	int err;
> +
> +	mutex_lock(&vr->lock);
> +	if (vr->ops) {
> +		err = -EBUSY;
> +		goto unlock;
> +	}
> +
> +	/* We don't lock, so make sure we get this in the right order. */
> +	vr->ops_data = ops_data;
> +	wmb();
> +	vr->ops = ops;
> +
> +	err = 0;
> +unlock:
> +	mutex_unlock(&vr->lock);
> +	local_irq_enable();

what's this doing here?

> +	return err;
> +}
> +EXPORT_SYMBOL_GPL(vring_set_ops);
> +
> +/**
> + * vring_unset_ops - remove operations to a vring file descriptor.
> + * @vr: the vring_info previously successfully vring_set_ops'd
> + */
> +void vring_unset_ops(struct vring_info *vr)
> +{
> +	BUG_ON(!vr->ops);
> +	mutex_lock(&vr->lock);
> +	vr->ops = NULL;
> +	mutex_unlock(&vr->lock);
> +}
> +EXPORT_SYMBOL_GPL(vring_unset_ops);

Isn't this just vring_set_ops(vr, NULL, NULL)?

> +static struct miscdevice vring_dev = {
> +	.minor = MISC_DYNAMIC_MINOR,
> +	.name = KBUILD_MODNAME,
> +	.fops = &vring_fops,
> +};
> +
> +static int __init init(void)
> +{
> +	return misc_register(&vring_dev);
> +}
> +
> +static void __exit fini(void)
> +{
> +	misc_deregister(&vring_dev);
> +}
> +
> +module_init(init);
> +module_exit(fini);
> diff -r b2d9869d338f include/linux/vring.h
> --- /dev/null	Thu Jan 01 00:00:00 1970 +0000
> +++ b/include/linux/vring.h	Fri Apr 18 13:35:16 2008 +1000
> @@ -0,0 +1,58 @@
> +/* Ring-buffer file descriptor implementation.
> + *
> + *  Copyright 2008 Rusty Russell IBM Corporation
> + *
> + *  This program is free software; you can redistribute it and/or modify
> + *  it under the terms of the GNU General Public License as published by
> + *  the Free Software Foundation; either version 2 of the License, or
> + *  (at your option) any later version.
> + *
> + *  This program is distributed in the hope that it will be useful,
> + *  but WITHOUT ANY WARRANTY; without even the implied warranty of
> + *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> + *  GNU General Public License for more details.
> + *
> + *  You should have received a copy of the GNU General Public License
> + *  along with this program; if not, write to the Free Software
> + *  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
> + */

ponders #include <copyright.h>

> +#ifndef _LINUX_VRING_H
> +#define _LINUX_VRING_H
> +
> +/**
> + * vring_ops - operations for a vring fd.
> + * @needs_pull: more data is pending, need to call pull.
> + * @pull: callback when read() is called to report used buffers.
> + * @push: callback when write() is called to notify of added buffers.
> + *
> + * Any of these callbacks can be NULL, if you don't need them.
> + */
> +struct vring_ops {
> +	bool (*needs_pull)(void *ops_data);
> +
> +	/* Returns 0 or negative errno. */
> +	int (*pull)(void *ops_data);
> +
> +	/* Returns 0 or negative errno. */
> +	int (*push)(void *ops_data);
> +};
> +
> +struct file;
> +
> +struct vring_info *vring_get(struct file *filp);
> +int vring_set_ops(struct vring_info *,
> +		  const struct vring_ops *ops, void *ops_data);

the first arg to vring_set_ops() lost its name.

> +void vring_unset_ops(struct vring_info *vr);
> +struct iovec;
> +
> +/* Returns an error, or 0 (no buffers), or an id for vring_used_buffer() */
> +int vring_get_buffer(struct vring_info *vr,
> +		     struct iovec *in_iov,
> +		     unsigned int *num_in, unsigned long *in_len,
> +		     struct iovec *out_iov,
> +		     unsigned int *num_out, unsigned long *out_len);
> +
> +void vring_used_buffer(struct vring_info *vr, int id, u32 len);
> +
> +void vring_wake(struct vring_info *vr);
> +#endif /* _LINUX_VRING_H */


