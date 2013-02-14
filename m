From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2 1/1] eventfd: implementation of EFD_MASK flag
Date: Thu, 14 Feb 2013 14:54:30 -0800
Message-ID: <20130214145430.04f8750c.akpm@linux-foundation.org>
References: <1360311077-14474-1-git-send-email-sustrik@250bpm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Alexander Viro <viro@zeniv.linux.org.uk>,
	Sha Zhengju <handai.szj@taobao.com>,
	linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Michael Kerrisk <mtk.manpages@gmail.com>,
	Davide Libenzi <davidel@xmailserver.org>,
	Andy Lutomirski <luto@amacapital.net>,
	Eric Wong <normalperson@yhbt.net>
To: Martin Sustrik <sustrik@250bpm.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <1360311077-14474-1-git-send-email-sustrik@250bpm.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri,  8 Feb 2013 09:11:17 +0100
Martin Sustrik <sustrik@250bpm.com> wrote:

> When implementing network protocols in user space, one has to implement
> fake user-space file descriptors to represent the sockets for the protocol.
> 
> While all the BSD socket API functionality for such descriptors may be faked as
> well (myproto_send(), myproto_recv() etc.) this approach doesn't work for
> polling  (select, poll, epoll). And unfortunately, sockets that can't be polled
> on allow only for building the simplest possible applications. Basically, you
> can build a simple client, but once you want to implement a server handling
> many sockets in parallel, you are stuck.
> 
> However, to do polling, real system-level file descriptor is needed,
> not a fake one.
> 
> In theory, eventfd may be used for this purpose, except that it is well suited
> only for signaling POLLIN. With some hacking it can be also used to signal
> POLLOUT and POLLERR, but:
> 
> I.  There's no way to signal POLLPRI, POLLHUP etc.
> II. There's no way to signal arbitraty combination of POLL* flags. Most notably,
>     !POLLIN & !POLLOUT, which is a perfectly valid combination for a network
>     protocol (rx buffer is empty and tx buffer is full), cannot be signaled
>     using current implementation of eventfd.
> 
> This patch implements new EFD_MASK flag which attempts to solve this problem.
> 
> Additionally, when implementing network protocols in user space, there's a
> need to associate user-space state with the each "socket". If eventfd object is
> used as a reference to the socket, it should be possible to associate an opaque
> pointer to user-space data with it.
> 
> The semantics of EFD_MASK are as follows:
> 
> eventfd(2):
> 
> If eventfd is created with EFD_MASK flag set, it is initialised in such a way
> as to signal no events on the file descriptor when it is polled on. 'initval'
> argument is ignored.
> 
> write(2):
> 
> User is allowed to write only buffers containing the following structure:
> 
> struct efd_mask {
>   short events;
>   union {
>     void *ptr;
>     uint32_t u32;
>     uint64_t u64;
>   };
> };
> 
> The value of 'events' should be any combination of event flags as defined by
> poll(2) function (POLLIN, POLLOUT, POLLERR, POLLHUP etc.) Specified events will
> be signaled when polling (select, poll, epoll) on the eventfd is done later on.
> ptr, u32 and u63 are opaque data that are not interpreted by eventfd object.
> 
> read(2):
> 
> User is allowed to read an efd_mask structure from the eventfd marked by
> EFD_MASK. Returned value shall be the last one written to the eventfd.
> 
> select(2), poll(2) and similar:
> 
> When polling on the eventfd marked by EFD_MASK flag, all the events specified
> in last written 'events' field shall be signaled.
> 
> ...

This patch adds userspace interfaces which will require manpage
updates.  Please Cc Michael and work with him on getting those changes
completed.

>
> +/*  On x86-64 keep the same binary layout as on i386. */
> +#ifdef __x86_64__
> +#define EVENTFD_MASK_PACKED __packed
> +#else
> +#define EVENTFD_MASK_PACKED
> +#endif
> +
> +struct eventfd_mask {
> +	__u32 events;
> +	__u64 data;
> +} EVENTFD_MASK_PACKED;

The x86-64 specific thing is ugly.  I can find no explanation of why it
was done, but it should go away.  You could make `events' a u64, or
swap the order of the two fields and make the struct __packed on all
architectures.

Given that the size of the types is fixed, I see no compat issues here.

As this struct is known by userspace, this definition should appear in
a header which is available to usersapce: include/uapi/...

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
> +		struct eventfd_mask mask;

The nice explanation for `count' was retained, but is it appropriate
that `mask' have no explanation?

> +	};
>  	unsigned int flags;
>  };
>  
> ...
>
> @@ -230,13 +261,23 @@ static ssize_t eventfd_read(struct file *file, char __user *buf, size_t count,
>  	ssize_t res;
>  	__u64 cnt;
>  
> -	if (count < sizeof(cnt))
> -		return -EINVAL;
> -	res = eventfd_ctx_read(ctx, file->f_flags & O_NONBLOCK, &cnt);
> -	if (res < 0)
> +	if (ctx->flags & EFD_MASK) {
> +		spin_lock_irq(&ctx->wqh.lock);
> +		if (count < sizeof(ctx->mask))
> +			return -EINVAL;
> +		res = copy_to_user(buf, &ctx->mask, sizeof(ctx->mask)) ?
> +			-EFAULT : sizeof(ctx->mask);
> +		spin_unlock_irq(&ctx->wqh.lock);
>  		return res;

This code is crawling with bugs.

- can return with wqh.lock held -> dead kernel

- performs copy_to_user() under spinlock -> warning spew, kernel
  deadlocks.  It should go via a local temporary, as was done in
  eventfd_write().

This should have filled your screen with warnings when testing.  Either
it wasn't tested or its author forgot to read
Documentation/SubmitChecklist section 12.  Please do so ;)

(otoh maybe might_sleep and lockdep fail to detect copy_*_user under
spinlock when the copy doesn't fault.  If so, that's a big fail)

> -
> -	return put_user(cnt, (__u64 __user *) buf) ? -EFAULT : sizeof(cnt);
> +	} else {
> +		if (count < sizeof(cnt))
> +			return -EINVAL;
> +		res = eventfd_ctx_read(ctx, file->f_flags & O_NONBLOCK, &cnt);
> +		if (res < 0)
> +			return res;
> +		return put_user(cnt, (__u64 __user *) buf) ?
> +			-EFAULT : sizeof(cnt);
> +	}
>  }
>  
>  static ssize_t eventfd_write(struct file *file, const char __user *buf, size_t count,
> @@ -246,6 +287,23 @@ static ssize_t eventfd_write(struct file *file, const char __user *buf, size_t c
>  	ssize_t res;
>  	__u64 ucnt;
>  	DECLARE_WAITQUEUE(wait, current);
> +	struct eventfd_mask mask;
> +
> +	if (ctx->flags & EFD_MASK) {
> +		if (count < sizeof(mask))
> +			return -EINVAL;
> +		if (copy_from_user(&mask, buf, sizeof(mask)))
> +			return -EFAULT;
> +		if (mask.events & ~EFD_MASK_VALID_EVENTS)
> +			return -EINVAL;
> +		spin_lock_irq(&ctx->wqh.lock);
> +		memcpy(&ctx->mask, &mask, sizeof(ctx->mask));
> +		if (waitqueue_active(&ctx->wqh))
> +			wake_up_locked_poll(&ctx->wqh,
> +				(unsigned long)ctx->mask.events);
> +		spin_unlock_irq(&ctx->wqh.lock);
> +		return sizeof(ctx->mask);
> +	}

`mask' can be made local to this `if' block, which is nicer.

>  	if (count < sizeof(ucnt))
>  		return -EINVAL;
> @@ -293,8 +351,13 @@ static int eventfd_show_fdinfo(struct seq_file *m, struct file *f)
>  	int ret;
>  
>  	spin_lock_irq(&ctx->wqh.lock);
> -	ret = seq_printf(m, "eventfd-count: %16llx\n",
> -			 (unsigned long long)ctx->count);
> +	if (ctx->flags & EFD_MASK) {
> +		ret = seq_printf(m, "eventfd-mask: %x\n",
> +				 (unsigned)ctx->mask.events);
> +	} else {
> +		ret = seq_printf(m, "eventfd-count: %16llx\n",
> +				 (unsigned long long)ctx->count);
> +	}
>  	spin_unlock_irq(&ctx->wqh.lock);

This is a non-back-compatible userspace interface change.  A procfs
file which previously displayed

	eventfd-count: nnnn

can now also display

	eventfd-mask: nnnn

So existing userspace could misbehave.

Please fully describe the proposed interface change in the changelog. 
That description should include the full pathname of the procfs file
and example before-and-after output and a discussion of whether and why
the risk to existing userspace is acceptable.
 
> @@ -412,7 +475,12 @@ struct file *eventfd_file_create(unsigned int count, int flags)
>  
>  	kref_init(&ctx->kref);
>  	init_waitqueue_head(&ctx->wqh);
> -	ctx->count = count;
> +	if (flags & EFD_MASK) {
> +		ctx->mask.events = 0;
> +		ctx->mask.data = 0;
> +	} else {
> +		ctx->count = count;
> +	}
>  	ctx->flags = flags;
>  
>  	file = anon_inode_getfile("[eventfd]", &eventfd_fops, ctx,
> diff --git a/include/linux/eventfd.h b/include/linux/eventfd.h
> index 3c3ef19..b806d2b 100644
> --- a/include/linux/eventfd.h
> +++ b/include/linux/eventfd.h
> @@ -20,11 +20,12 @@
>   * shared O_* flags.
>   */
>  #define EFD_SEMAPHORE (1 << 0)
> +#define EFD_MASK (1 << 1)

Does this addition comply with the "CAREFUL:" immediately above it?

It would be best to add code comemntary describing what this constant does.

>  #define EFD_CLOEXEC O_CLOEXEC
>  #define EFD_NONBLOCK O_NONBLOCK
>  
>  #define EFD_SHARED_FCNTL_FLAGS (O_CLOEXEC | O_NONBLOCK)
> -#define EFD_FLAGS_SET (EFD_SHARED_FCNTL_FLAGS | EFD_SEMAPHORE)
> +#define EFD_FLAGS_SET (EFD_SHARED_FCNTL_FLAGS | EFD_SEMAPHORE | EFD_MASK)
>  
>  #ifdef CONFIG_EVENTFD

