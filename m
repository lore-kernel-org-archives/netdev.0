From: Damian Hobson-Garcia <dhobsong-AlSX/UN32fvPDbFq/vQRIQ@public.gmane.org>
Subject: Re: [PATCH] eventfd: implementation of EFD_MASK flag
Date: Mon, 10 Aug 2015 15:23:40 +0900
Message-ID: <55C8436C.1000806@igel.co.jp>
References: <1439185906-28180-1-git-send-email-dhobsong@igel.co.jp>
 <1439185906-28180-2-git-send-email-dhobsong@igel.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: sustrik-8XN41Hm7QBXQT0dZR+AlfA@public.gmane.org, viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1439185906-28180-2-git-send-email-dhobsong-AlSX/UN32fvPDbFq/vQRIQ@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Replying to my own post, but I had the following comments/questions.
Martin, if you have any response to my comments I would be very happy to
hear them.

On 2015-08-10 2:51 PM, Damian Hobson-Garcia wrote:
> From: Martin Sustrik <sustrik-8XN41Hm7QBXQT0dZR+AlfA@public.gmane.org>
> 
[snip]
> 
> write(2):
> 
> User is allowed to write only buffers containing the following structure:
> 
> struct efd_mask {
>   __u32 events;
>   __u64 data;
> };
> 
> The value of 'events' should be any combination of event flags as defined by
> poll(2) function (POLLIN, POLLOUT, POLLERR, POLLHUP etc.) Specified events will
> be signaled when polling (select, poll, epoll) on the eventfd is done later on.
> 'data' is opaque data that are not interpreted by eventfd object.
> 
I'm not fully clear on the purpose that the 'data' member serves.  Does
this opaque handle need to be tied together with this event
synchronization construct?

[snip]

> @@ -55,6 +69,9 @@ __u64 eventfd_signal(struct eventfd_ctx *ctx, __u64 n)
>  {
> +	/* This function should never be used with eventfd in the mask mode. */
> +	BUG_ON(ctx->flags & EFD_MASK);
> +
...
> @@ -158,6 +180,9 @@ int eventfd_ctx_remove_wait_queue(struct eventfd_ctx *ctx, wait_queue_t *wait,
>  {
> +	/* This function should never be used with eventfd in the mask mode. */
> +	BUG_ON(ctx->flags & EFD_MASK);
> +
...
> @@ -188,6 +213,9 @@ ssize_t eventfd_ctx_read(struct eventfd_ctx *ctx, int no_wait, __u64 *cnt)
> +	/* This function should never be used with eventfd in the mask mode. */
> +	BUG_ON(ctx->flags & EFD_MASK);
> +

If eventfd_ctx_fileget() returns EINVAL when EFD_MASK is set, I don't
think that there will be a way to call these functions in the mask mode,
so it should be possible to get rid of the BUG_ON checks.

[snip]
> @@ -230,6 +258,19 @@ static ssize_t eventfd_read(struct file *file, char __user *buf, size_t count,
>  	ssize_t res;
>  	__u64 cnt;
>  
> +	if (ctx->flags & EFD_MASK) {
> +		struct efd_mask mask;
> +
> +		if (count < sizeof(mask))
> +			return -EINVAL;
> +		spin_lock_irq(&ctx->wqh.lock);
> +		mask = ctx->mask;
> +		spin_unlock_irq(&ctx->wqh.lock);
> +		if (copy_to_user(buf, &mask, sizeof(mask)))
> +			return -EFAULT;
> +		return sizeof(mask);
> +	}
> +

For the other eventfd modes, reading the value will update the internal
state of the eventfd (either clearing or decrementing the counter).
Should something similar be done here? I'm thinking of a case where a
process is polling on this fd in a loop. Clearing the efd_mask data  on
read should provide an easy way for the polling process to know if it is
seeing new poll events.

> @@ -292,8 +351,13 @@ static void eventfd_show_fdinfo(struct seq_file *m, struct file *f)
>  	struct eventfd_ctx *ctx = f->private_data;
>  
>  	spin_lock_irq(&ctx->wqh.lock);
> -	seq_printf(m, "eventfd-count: %16llx\n",
> -		   (unsigned long long)ctx->count);
> +	if (ctx->flags & EFD_MASK) {
> +		seq_printf(m, "eventfd-mask: %x\n",
> +				 (unsigned)ctx->mask.events);
> +	} else {
> +		seq_printf(m, "eventfd-count: %16llx\n",
> +				 (unsigned long long)ctx->count);
> +	}
>  	spin_unlock_irq(&ctx->wqh.lock);
>  }
I think that putting the EFD_MASK functionality into a different fops
structure might be useful for reducing the number of if statements.

Thank you,
Damian
