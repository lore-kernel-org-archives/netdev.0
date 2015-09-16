From: Martin Sustrik <sustrik@250bpm.com>
Subject: Re: [PATCH v2 1/1] eventfd: implementation of EFD_MASK flag
Date: Wed, 16 Sep 2015 08:51:45 +0200
Message-ID: <70093385dc00b108e16862c8b8b1c13c@imap.lucina.net>
References: <1442384836-13045-1-git-send-email-dhobsong@igel.co.jp>
 <1442384836-13045-2-git-send-email-dhobsong@igel.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: viro@zeniv.linux.org.uk, linux-kernel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, linux-api@vger.kernel.org,
	netdev@vger.kernel.org, David.Laight@aculab.com
To: Damian Hobson-Garcia <dhobsong@igel.co.jp>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1442384836-13045-2-git-send-email-dhobsong@igel.co.jp>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2015-09-16 08:27, Damian Hobson-Garcia wrote:
> From: Martin Sustrik <sustrik@250bpm.com>
> 
> When implementing network protocols in user space, one has to implement
> fake file descriptors to represent the sockets for the protocol.
> 
> Polling on such fake file descriptors is a problem (poll/select/epoll
> accept only true file descriptors) and forces protocol implementers to 
> use
> various workarounds resulting in complex, non-standard and convoluted 
> APIs.
> 
> More generally, ability to create full-blown file descriptors for
> userspace-to-userspace signalling is missing. While eventfd(2) goes 
> half
> the way towards this goal it has follwoing shorcomings:
> 
> I.  There's no way to signal POLLPRI, POLLHUP etc.
> II. There's no way to signal arbitrary combination of POLL* flags. Most
>     notably, simultaneous !POLLIN and !POLLOUT, which is a perfectly 
> valid
>     combination for a network protocol (rx buffer is empty and tx 
> buffer is
>     full), cannot be signaled using eventfd.
> 
> This patch implements new EFD_MASK flag which solves the above 
> problems.
> 
> Additionally, to provide a way to associate user-space state with 
> eventfd
> object, it allows to attach user-space data to the file descriptor.

The above paragraph is a leftover from the past. The functionality no 
longer exist.

> 
> The semantics of EFD_MASK are as follows:
> 
> eventfd(2):
> 
> If eventfd is created with EFD_MASK flag set, it is initialised in such 
> a
> way as to signal no events on the file descriptor when it is polled on.
> The 'initval' argument is ignored.
> 
> write(2):
> 
> User is allowed to write only buffers containing the following 
> structure:
> 
> struct efd_mask {
>   uint32_t events;
> };

Is it worth having a struct here? Why not just uint32_t?

Martin

> 
> The value of 'events' should be any combination of event flags as 
> defined
> by poll(2) function (POLLIN, POLLOUT, POLLERR, POLLHUP etc.) Specified
> events will be signaled when polling (select, poll, epoll) on the 
> eventfd
> is done later on.
> 
> read(2):
> 
> read is not supported and will fail with EINVAL.
> 
> select(2), poll(2) and similar:
> 
> When polling on the eventfd marked by EFD_MASK flag, all the events
> specified in last written 'events' field shall be signaled.
> 
> Signed-off-by: Martin Sustrik <sustrik@250bpm.com>
> 
> [dhobsong@igel.co.jp: Rebased, and resubmitted for Linux 4.3]
> Signed-off-by: Damian Hobson-Garcia <dhobsong@igel.co.jp>
> ---
>  fs/eventfd.c                 | 102 
> ++++++++++++++++++++++++++++++++++++++-----
>  include/linux/eventfd.h      |  16 +------
>  include/uapi/linux/eventfd.h |  39 +++++++++++++++++
>  3 files changed, 132 insertions(+), 25 deletions(-)
>  create mode 100644 include/uapi/linux/eventfd.h
> 
> diff --git a/fs/eventfd.c b/fs/eventfd.c
> index 8d0c0df..1a6a066 100644
> --- a/fs/eventfd.c
> +++ b/fs/eventfd.c
> @@ -2,6 +2,7 @@
>   *  fs/eventfd.c
>   *
>   *  Copyright (C) 2007  Davide Libenzi <davidel@xmailserver.org>
> + *  Copyright (C) 2013  Martin Sustrik <sustrik@250bpm.com>
>   *
>   */
> 
> @@ -22,18 +23,31 @@
>  #include <linux/proc_fs.h>
>  #include <linux/seq_file.h>
> 
> +#define EFD_SHARED_FCNTL_FLAGS (O_CLOEXEC | O_NONBLOCK)
> +#define EFD_FLAGS_SET (EFD_SHARED_FCNTL_FLAGS | EFD_SEMAPHORE | 
> EFD_MASK)
> +#define EFD_MASK_VALID_EVENTS (POLLIN | POLLPRI | POLLOUT | POLLERR | 
> POLLHUP)
> +
>  struct eventfd_ctx {
>  	struct kref kref;
>  	wait_queue_head_t wqh;
> -	/*
> -	 * Every time that a write(2) is performed on an eventfd, the
> -	 * value of the __u64 being written is added to "count" and a
> -	 * wakeup is performed on "wqh". A read(2) will return the "count"
> -	 * value to userspace, and will reset "count" to zero. The kernel
> -	 * side eventfd_signal() also, adds to the "count" counter and
> -	 * issue a wakeup.
> -	 */
> -	__u64 count;
> +	union {
> +		/*
> +		 * Every time that a write(2) is performed on an eventfd, the
> +		 * value of the __u64 being written is added to "count" and a
> +		 * wakeup is performed on "wqh". A read(2) will return the
> +		 * "count" value to userspace, and will reset "count" to zero.
> +		 * The kernel side eventfd_signal() also, adds to the "count"
> +		 * counter and issue a wakeup.
> +		 */
> +		__u64 count;
> +
> +		/*
> +		 * When using eventfd in EFD_MASK mode this stracture stores the
> +		 * current events to be signaled on the eventfd (events member)
> +		 * along with opaque user-defined data (data member).
> +		 */
> +		struct efd_mask mask;
> +	};
>  	unsigned int flags;
>  };
> 
> @@ -134,6 +148,14 @@ static unsigned int eventfd_poll(struct file
> *file, poll_table *wait)
>  	return events;
>  }
> 
> +static unsigned int eventfd_mask_poll(struct file *file, poll_table 
> *wait)
> +{
> +	struct eventfd_ctx *ctx = file->private_data;
> +
> +	poll_wait(file, &ctx->wqh, wait);
> +	return ctx->mask.events;
> +}
> +
>  static void eventfd_ctx_do_read(struct eventfd_ctx *ctx, __u64 *cnt)
>  {
>  	*cnt = (ctx->flags & EFD_SEMAPHORE) ? 1 : ctx->count;
> @@ -239,6 +261,14 @@ static ssize_t eventfd_read(struct file *file,
> char __user *buf, size_t count,
>  	return put_user(cnt, (__u64 __user *) buf) ? -EFAULT : sizeof(cnt);
>  }
> 
> +static ssize_t eventfd_mask_read(struct file *file, char __user *buf,
> +			    size_t count,
> +			    loff_t *ppos)
> +{
> +	return -EINVAL;
> +}
> +
> +
>  static ssize_t eventfd_write(struct file *file, const char __user
> *buf, size_t count,
>  			     loff_t *ppos)
>  {
> @@ -286,6 +316,28 @@ static ssize_t eventfd_write(struct file *file,
> const char __user *buf, size_t c
>  	return res;
>  }
> 
> +static ssize_t eventfd_mask_write(struct file *file, const char __user 
> *buf,
> +			     size_t count,
> +			     loff_t *ppos)
> +{
> +	struct eventfd_ctx *ctx = file->private_data;
> +	struct efd_mask mask;
> +
> +	if (count < sizeof(mask))
> +		return -EINVAL;
> +	if (copy_from_user(&mask, buf, sizeof(mask)))
> +		return -EFAULT;
> +	if (mask.events & ~EFD_MASK_VALID_EVENTS)
> +		return -EINVAL;
> +	spin_lock_irq(&ctx->wqh.lock);
> +	memcpy(&ctx->mask, &mask, sizeof(ctx->mask));
> +	if (waitqueue_active(&ctx->wqh))
> +		wake_up_locked_poll(&ctx->wqh,
> +			(unsigned long)ctx->mask.events);
> +	spin_unlock_irq(&ctx->wqh.lock);
> +	return sizeof(ctx->mask);
> +}
> +
>  #ifdef CONFIG_PROC_FS
>  static void eventfd_show_fdinfo(struct seq_file *m, struct file *f)
>  {
> @@ -296,6 +348,16 @@ static void eventfd_show_fdinfo(struct seq_file
> *m, struct file *f)
>  		   (unsigned long long)ctx->count);
>  	spin_unlock_irq(&ctx->wqh.lock);
>  }
> +
> +static void eventfd_mask_show_fdinfo(struct seq_file *m, struct file 
> *f)
> +{
> +	struct eventfd_ctx *ctx = f->private_data;
> +
> +	spin_lock_irq(&ctx->wqh.lock);
> +	seq_printf(m, "eventfd-mask: %x\n",
> +		(unsigned)ctx->mask.events);
> +	spin_unlock_irq(&ctx->wqh.lock);
> +}
>  #endif
> 
>  static const struct file_operations eventfd_fops = {
> @@ -309,6 +371,17 @@ static const struct file_operations eventfd_fops = 
> {
>  	.llseek		= noop_llseek,
>  };
> 
> +static const struct file_operations eventfd_mask_fops = {
> +#ifdef CONFIG_PROC_FS
> +	.show_fdinfo	= eventfd_mask_show_fdinfo,
> +#endif
> +	.release	= eventfd_release,
> +	.poll		= eventfd_mask_poll,
> +	.read		= eventfd_mask_read,
> +	.write		= eventfd_mask_write,
> +	.llseek		= noop_llseek,
> +};
> +
>  /**
>   * eventfd_fget - Acquire a reference of an eventfd file descriptor.
>   * @fd: [in] Eventfd file descriptor.
> @@ -392,6 +465,7 @@ struct file *eventfd_file_create(unsigned int
> count, int flags)
>  {
>  	struct file *file;
>  	struct eventfd_ctx *ctx;
> +	const struct file_operations *fops;
> 
>  	/* Check the EFD_* constants for consistency.  */
>  	BUILD_BUG_ON(EFD_CLOEXEC != O_CLOEXEC);
> @@ -406,10 +480,16 @@ struct file *eventfd_file_create(unsigned int
> count, int flags)
> 
>  	kref_init(&ctx->kref);
>  	init_waitqueue_head(&ctx->wqh);
> -	ctx->count = count;
> +	if (flags & EFD_MASK) {
> +		memset(&ctx->mask, 0, sizeof(ctx->mask));
> +		fops = &eventfd_mask_fops;
> +	} else {
> +		ctx->count = count;
> +		fops = &eventfd_fops;
> +	}
>  	ctx->flags = flags;
> 
> -	file = anon_inode_getfile("[eventfd]", &eventfd_fops, ctx,
> +	file = anon_inode_getfile("[eventfd]", fops, ctx,
>  				  O_RDWR | (flags & EFD_SHARED_FCNTL_FLAGS));
>  	if (IS_ERR(file))
>  		eventfd_free_ctx(ctx);
> diff --git a/include/linux/eventfd.h b/include/linux/eventfd.h
> index ff0b981..87de343 100644
> --- a/include/linux/eventfd.h
> +++ b/include/linux/eventfd.h
> @@ -8,23 +8,11 @@
>  #ifndef _LINUX_EVENTFD_H
>  #define _LINUX_EVENTFD_H
> 
> +#include <uapi/linux/eventfd.h>
> +
>  #include <linux/fcntl.h>
>  #include <linux/wait.h>
> 
> -/*
> - * CAREFUL: Check include/uapi/asm-generic/fcntl.h when defining
> - * new flags, since they might collide with O_* ones. We want
> - * to re-use O_* flags that couldn't possibly have a meaning
> - * from eventfd, in order to leave a free define-space for
> - * shared O_* flags.
> - */
> -#define EFD_SEMAPHORE (1 << 0)
> -#define EFD_CLOEXEC O_CLOEXEC
> -#define EFD_NONBLOCK O_NONBLOCK
> -
> -#define EFD_SHARED_FCNTL_FLAGS (O_CLOEXEC | O_NONBLOCK)
> -#define EFD_FLAGS_SET (EFD_SHARED_FCNTL_FLAGS | EFD_SEMAPHORE)
> -
>  struct file;
> 
>  #ifdef CONFIG_EVENTFD
> diff --git a/include/uapi/linux/eventfd.h 
> b/include/uapi/linux/eventfd.h
> new file mode 100644
> index 0000000..98ec034
> --- /dev/null
> +++ b/include/uapi/linux/eventfd.h
> @@ -0,0 +1,39 @@
> +/*
> + *  Copyright (C) 2013 Martin Sustrik <sustrik@250bpm.com>
> + *
> + *  This program is free software; you can redistribute it and/or 
> modify
> + *  it under the terms of the GNU General Public License as published 
> by
> + *  the Free Software Foundation; either version 2 of the License, or
> + *  (at your option) any later version.
> + */
> +
> +#ifndef _UAPI_LINUX_EVENTFD_H
> +#define _UAPI_LINUX_EVENTFD_H
> +
> +/* For O_CLOEXEC */
> +#include <linux/fcntl.h>
> +#include <linux/types.h>
> +
> +/*
> + * CAREFUL: Check include/asm-generic/fcntl.h when defining
> + * new flags, since they might collide with O_* ones. We want
> + * to re-use O_* flags that couldn't possibly have a meaning
> + * from eventfd, in order to leave a free define-space for
> + * shared O_* flags.
> + */
> +
> +/* Provide semaphore-like semantics for reads from the eventfd. */
> +#define EFD_SEMAPHORE (1 << 0)
> +/* Provide event mask semantics for the eventfd. */
> +#define EFD_MASK (1 << 1)
> +/*  Set the close-on-exec (FD_CLOEXEC) flag on the eventfd. */
> +#define EFD_CLOEXEC O_CLOEXEC
> +/*  Create the eventfd in non-blocking mode. */
> +#define EFD_NONBLOCK O_NONBLOCK
> +
> +/* Structure to read/write to eventfd in EFD_MASK mode. */
> +struct efd_mask {
> +	__u32 events;
> +};
> +
> +#endif /* _UAPI_LINUX_EVENTFD_H */
