From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [take12 3/3] kevent: Timer notifications.
Date: Mon, 21 Aug 2006 12:12:39 +0100
Message-ID: <20060821111239.GA30945@infradead.org>
References: <11561555893621@2ka.mipt.ru> <1156155589287@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: lkml <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Ulrich Drepper <drepper@redhat.com>,
	Andrew Morton <akpm@osdl.org>, netdev <netdev@vger.kernel.org>,
	Zach Brown <zach.brown@oracle.com>, tglx@linutronix.de
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932068AbWHULMm@vger.kernel.org>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Content-Disposition: inline
In-Reply-To: <1156155589287@2ka.mipt.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 21, 2006 at 02:19:49PM +0400, Evgeniy Polyakov wrote:
> 
> 
> Timer notifications.
> 
> Timer notifications can be used for fine grained per-process time 
> management, since interval timers are very inconvenient to use, 
> and they are limited.

Shouldn't this at leat use a hrtimer?

> new file mode 100644
> index 0000000..5217cd1
> --- /dev/null
> +++ b/kernel/kevent/kevent_timer.c
> @@ -0,0 +1,107 @@
> +/*
> + * 	kevent_timer.c

You still include those sill filename ontop of file comments..

> +static struct lock_class_key kevent_timer_key;
> +
> +static int kevent_timer_enqueue(struct kevent *k)
> +{
> +	int err;
> +	struct kevent_timer *t;
> +
> +	t = kmalloc(sizeof(struct kevent_timer), GFP_KERNEL);
> +	if (!t)
> +		return -ENOMEM;
> +
> +	setup_timer(&t->ktimer, &kevent_timer_func, (unsigned long)k);
> +
> +	err = kevent_storage_init(&t->ktimer, &t->ktimer_storage);
> +	if (err)
> +		goto err_out_free;
> +	lockdep_set_class(&t->ktimer_storage.lock, &kevent_timer_key);

When looking at the kevent_storage_init callers most need to do
those lockdep_set_class class.  Shouldn't kevent_storage_init just
get a "struct lock_class_key *" argument?

> +static int kevent_timer_callback(struct kevent *k)
> +{
> +	k->event.ret_data[0] = (__u32)jiffies;

This is returned to userspace, isn't it?  raw jiffies should never be
user-visible.  Please convert this to an unit that actually makes sense
for userspace (probably nanoseconds)

> +static int __init kevent_init_timer(void)
> +{
> +	struct kevent_callbacks tc = {
> +		.callback = &kevent_timer_callback, 
> +		.enqueue = &kevent_timer_enqueue, 
> +		.dequeue = &kevent_timer_dequeue};

I think this should be static, and the normal style to write it would be:

static struct kevent_callbacks tc = {
	.callback	= kevent_timer_callback,
	.enqueue	= kevent_timer_enqueue,
	.dequeue	= kevent_timer_dequeue,
};

also please consider makring all the kevent_callbacks structs const
to avoid false cacheline sharing and accidental modification, similar
to what we did to various other operation vectors.
