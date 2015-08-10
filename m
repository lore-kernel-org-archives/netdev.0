From: Martin Sustrik <sustrik@250bpm.com>
Subject: Re: [PATCH] eventfd: implementation of EFD_MASK flag
Date: Mon, 10 Aug 2015 08:39:42 +0200
Message-ID: <45138eb2cdd715f14fbd01fb5c8d3655@imap.lucina.net>
References: <1439185906-28180-1-git-send-email-dhobsong@igel.co.jp>
 <1439185906-28180-2-git-send-email-dhobsong@igel.co.jp>
 <55C8436C.1000806@igel.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-api@vger.kernel.org
To: Damian Hobson-Garcia <dhobsong@igel.co.jp>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <55C8436C.1000806@igel.co.jp>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2015-08-10 08:23, Damian Hobson-Garcia wrote:
> Replying to my own post, but I had the following comments/questions.
> Martin, if you have any response to my comments I would be very happy 
> to
> hear them.
> 
> On 2015-08-10 2:51 PM, Damian Hobson-Garcia wrote:
>> From: Martin Sustrik <sustrik@250bpm.com>
>> 
> [snip]
>> 
>> write(2):
>> 
>> User is allowed to write only buffers containing the following 
>> structure:
>> 
>> struct efd_mask {
>>   __u32 events;
>>   __u64 data;
>> };
>> 
>> The value of 'events' should be any combination of event flags as 
>> defined by
>> poll(2) function (POLLIN, POLLOUT, POLLERR, POLLHUP etc.) Specified 
>> events will
>> be signaled when polling (select, poll, epoll) on the eventfd is done 
>> later on.
>> 'data' is opaque data that are not interpreted by eventfd object.
>> 
> I'm not fully clear on the purpose that the 'data' member serves.  Does
> this opaque handle need to be tied together with this event
> synchronization construct?

It's a convenience thing. Imagine you are implementing your own file 
descriptor type in user space. You create an EFD_MASK socket and a 
structure that will hold any state that you need for the socket (tx/rx 
buffers and such).

Now you have two things to pass around. If you want to pass the fd to a 
function, it must have two parameters (fd and pointer to the structure).

To fix it you can put the fd into the structure. That way there's only 
one thing to pass around (the structure).

The problem with that approach is when you have generic code that deals 
with file descriptors. For example, a simple poller which accepts a list 
of (fd, callback) pairs and invokes the callback when one of the fds 
signals POLLIN. You can't send a pointer to a structure to such 
function. All you can send is the fd, but then, when the callback is 
invoked, fd is all you have. You have no idea where your state is.

'data' member allows you to put the pointer to the state to the socket 
itself. Thus, if you have a fd, you can always find out where the 
associated data is by reading the mask structure from the fd.

> 
> [snip]
> 
>> @@ -55,6 +69,9 @@ __u64 eventfd_signal(struct eventfd_ctx *ctx, __u64 
>> n)
>>  {
>> +	/* This function should never be used with eventfd in the mask mode. 
>> */
>> +	BUG_ON(ctx->flags & EFD_MASK);
>> +
> ...
>> @@ -158,6 +180,9 @@ int eventfd_ctx_remove_wait_queue(struct 
>> eventfd_ctx *ctx, wait_queue_t *wait,
>>  {
>> +	/* This function should never be used with eventfd in the mask mode. 
>> */
>> +	BUG_ON(ctx->flags & EFD_MASK);
>> +
> ...
>> @@ -188,6 +213,9 @@ ssize_t eventfd_ctx_read(struct eventfd_ctx *ctx, 
>> int no_wait, __u64 *cnt)
>> +	/* This function should never be used with eventfd in the mask mode. 
>> */
>> +	BUG_ON(ctx->flags & EFD_MASK);
>> +
> 
> If eventfd_ctx_fileget() returns EINVAL when EFD_MASK is set, I don't
> think that there will be a way to call these functions in the mask 
> mode,
> so it should be possible to get rid of the BUG_ON checks.

Sure. Feel free to do so.

> 
> [snip]
>> @@ -230,6 +258,19 @@ static ssize_t eventfd_read(struct file *file, 
>> char __user *buf, size_t count,
>>  	ssize_t res;
>>  	__u64 cnt;
>> 
>> +	if (ctx->flags & EFD_MASK) {
>> +		struct efd_mask mask;
>> +
>> +		if (count < sizeof(mask))
>> +			return -EINVAL;
>> +		spin_lock_irq(&ctx->wqh.lock);
>> +		mask = ctx->mask;
>> +		spin_unlock_irq(&ctx->wqh.lock);
>> +		if (copy_to_user(buf, &mask, sizeof(mask)))
>> +			return -EFAULT;
>> +		return sizeof(mask);
>> +	}
>> +
> 
> For the other eventfd modes, reading the value will update the internal
> state of the eventfd (either clearing or decrementing the counter).
> Should something similar be done here? I'm thinking of a case where a
> process is polling on this fd in a loop. Clearing the efd_mask data  on
> read should provide an easy way for the polling process to know if it 
> is
> seeing new poll events.

No. In this case reading the value has no effect on the state of the fd. 
How it should work is rather:

// fd is in POLLIN state
poll(fd);
// function exits with POLLIN but fd remains in POLLIN state
my_recv(fd, buf, size);
// my_recv function have found out that there's no more data to recv and 
switched off the POLLIN flag
poll(fd); // we block here waiting for more data to arrive from the 
network

> 
>> @@ -292,8 +351,13 @@ static void eventfd_show_fdinfo(struct seq_file 
>> *m, struct file *f)
>>  	struct eventfd_ctx *ctx = f->private_data;
>> 
>>  	spin_lock_irq(&ctx->wqh.lock);
>> -	seq_printf(m, "eventfd-count: %16llx\n",
>> -		   (unsigned long long)ctx->count);
>> +	if (ctx->flags & EFD_MASK) {
>> +		seq_printf(m, "eventfd-mask: %x\n",
>> +				 (unsigned)ctx->mask.events);
>> +	} else {
>> +		seq_printf(m, "eventfd-count: %16llx\n",
>> +				 (unsigned long long)ctx->count);
>> +	}
>>  	spin_unlock_irq(&ctx->wqh.lock);
>>  }
> I think that putting the EFD_MASK functionality into a different fops
> structure might be useful for reducing the number of if statements.

Sure. No objections.

Thanks for re-submitting the patch!
Martin
