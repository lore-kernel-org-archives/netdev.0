From: Anthony Liguori <anthony@codemonkey.ws>
Subject: Re: [PATCH RFC 1/5] vringfd syscall
Date: Sat, 05 Apr 2008 12:13:41 -0500
Message-ID: <47F7B345.1080200@codemonkey.ws>
References: <200804052202.09157.rusty__7324.67876882783$1207397085$gmane$org@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Max Krasnyansky <maxk@qualcomm.com>,
	virtualization@lists.linux-foundation.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rn-out-0910.google.com ([64.233.170.189]:50927 "EHLO
	rn-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752483AbYDERNr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Apr 2008 13:13:47 -0400
Received: by rn-out-0910.google.com with SMTP id e24so616641rng.1
        for <netdev@vger.kernel.org>; Sat, 05 Apr 2008 10:13:46 -0700 (PDT)
In-Reply-To: <200804052202.09157.rusty__7324.67876882783$1207397085$gmane$org@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rusty Russell wrote:
> For virtualization, we've developed virtio_ring for efficient communication.
> This would also work well for userspace-kernel communication, particularly
> for things like the tun device.  By using the same ABI, we can join guests
> to the host kernel trivially.
> 
> These patches are fairly alpha; I've seen some network stalls I have to
> track down and there are some fixmes.
> 
> Comments welcome!
> Rusty.
> 
> diff -r 99132ad16999 Documentation/test_vring.c
> --- /dev/null	Thu Jan 01 00:00:00 1970 +0000
> +++ b/Documentation/test_vring.c	Sat Apr 05 21:31:40 2008 +1100
> @@ -0,0 +1,47 @@
> +#include <unistd.h>
> +#include <linux/virtio_ring.h>
> +#include <stdio.h>
> +#include <stdint.h>
> +#include <err.h>
> +#include <poll.h>
> +
> +#ifndef __NR_vringfd
> +#define __NR_vringfd		327
> +#endif
> +
> +int main()
> +{
> +	int fd, r;
> +	struct vring vr;
> +	uint16_t used = 0;
> +	struct pollfd pfd;
> +	void *buf = calloc(vring_size(256, getpagesize()), 0);

Shouldn't this be calloc(1, vring_size(256, getpagesize()));?

> +	vring_init(&vr, 256, buf, getpagesize());
> +
> +	fd = syscall(__NR_vringfd, buf, 256, &used);
> +	if (fd < 0)
> +		err(1, "vringfd gave %i", fd);
> +
> +	pfd.fd = fd;
> +	pfd.events = POLLIN;
> +	r = poll(&pfd, 1, 0);
> +	
> +	if (r != 0)
> +		err(1, "poll gave %i", r);
> +
> +	vr.used->idx++;
> +	r = poll(&pfd, 1, 0);
> +	
> +	if (r != 1)
> +		err(1, "poll after buf used gave %i", r);
> +
> +	used++;
> +	r = poll(&pfd, 1, 0);
> +	
> +	if (r != 0)
> +		err(1, "poll after used incremented gave %i", r);

I have a tough time seeing what you're demonstrating here.  Perhaps some 
comments?

> +	close(fd);
> +	return 0;
> +}
> diff -r 99132ad16999 arch/x86/kernel/syscall_table_32.S
> --- a/arch/x86/kernel/syscall_table_32.S	Sat Apr 05 21:20:32 2008 +1100
> +++ b/arch/x86/kernel/syscall_table_32.S	Sat Apr 05 21:31:40 2008 +1100
> @@ -326,3 +326,4 @@ ENTRY(sys_call_table)
>  	.long sys_fallocate
>  	.long sys_timerfd_settime	/* 325 */
>  	.long sys_timerfd_gettime
> +	.long sys_vringfd
> diff -r 99132ad16999 fs/Kconfig
> --- a/fs/Kconfig	Sat Apr 05 21:20:32 2008 +1100
> +++ b/fs/Kconfig	Sat Apr 05 21:31:40 2008 +1100
> @@ -2135,4 +2135,14 @@ source "fs/nls/Kconfig"
>  source "fs/nls/Kconfig"
>  source "fs/dlm/Kconfig"
>  
> +config VRINGFD
> +       bool "vring fd support (EXPERIMENTAL)"
> +       depends on EXPERIMENTAL
> +       help
> +         vring is a ringbuffer implementation for efficient I/O.  It is
> +	 currently used by virtualization hosts (lguest, kvm) for efficient
> +	 networking using the tun driver.
> +
> +	 If unsure, say N.
> +

Should select VIRTIO && VIRTIO_RING

<snip>

> +/* Returns an error, or 0 (no buffers), or an id for vring_used_buffer() */
> +int vring_get_buffer(struct vring_info *vr,
> +		     struct iovec *in_iov,
> +		     unsigned int *num_in, unsigned long *in_len,
> +		     struct iovec *out_iov,
> +		     unsigned int *num_out, unsigned long *out_len)
> +{

It seems unlikely that a caller could place both in_iov/out_iov on the 
stack since to do it safely, you would have to use vring.num which is 
determined by userspace.  Since you have to kmalloc() the buffers 
anyway, why not just allocate a single data structure within this 
function and return it.

> +void vring_used_buffer_atomic(struct vring_info *vr, int id, u32 len)
> +{
> +	struct vring_used_elem *used;
> +
> +	BUG_ON(id <= 0 || id > vr->ring.num);
> +	BUG_ON(!vr->used);
> +
> +	used = &vr->used->ring[vr->used->idx & vr->mask];
> +	used->id = id - 1;
> +	used->len = len;
> +	/* Make sure buffer is written before we update index. */
> +	wmb();
> +	vr->used->idx++;
> +}
> +EXPORT_SYMBOL_GPL(vring_used_buffer_atomic);

When is this actually safe to use?

> +
> +void vring_wake(struct vring_info *vr)
> +{
> +	wake_up(&vr->poll_wait);
> +}
> +EXPORT_SYMBOL_GPL(vring_wake);
> +
> +struct vring_info *vring_attach(int fd, const struct vring_ops *ops,
> +				void *data, bool atomic_use)
> +{
> +	struct file *filp;
> +	struct vring_info *vr;
> +
> +	/* Must be a valid fd, and must be one of ours. */
> +	filp = fget(fd);
> +	if (!filp) {
> +		vr = ERR_PTR(-EBADF);
> +		goto out;
> +	}
> +
> +	if (filp->f_op != &vring_fops) {
> +		vr = ERR_PTR(-EBADF);
> +		goto fput;
> +	}
> +
> +	/* Mutex simply protects against parallel vring_attach. */
> +	mutex_lock(&vring_lock);
> +	vr = filp->private_data;
> +	if (vr->ops) {
> +		vr = ERR_PTR(-EBUSY);
> +		goto unlock;
> +	}
> +
> +	/* If they want to use atomically, we have to map the page. */
> +	if (atomic_use) {
> +		if (get_user_pages(current, current->mm,
> +				   (unsigned long)vr->ring.used, 1, 1, 1,
> +				   &vr->used_page, NULL) != 1) {
> +			vr = ERR_PTR(-EFAULT);
> +			goto unlock;
> +		}

Oh, this is when it's safe to use.  You don't seem to be acquiring 
current->mm->mmap_sem here.  Also, this assumes the used ring fits 
within a single page which isn't true with a ring > 512 elements.

A consequence of this is that devices that interact with a ring queue 
atomically now have an additional capability: pinning an arbitrary 
amount of physical memory.

I think this means that it's no longer safe to give a tap fd to an 
unprivileged process regardless of how you're routing the traffic.

Regards,

Anthony Liguori
