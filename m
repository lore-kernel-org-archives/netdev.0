From: Andrew Morton <akpm@osdl.org>
Subject: Re: [take8 2/2] kevent: poll/select() notifications. Timer
 notifications.
Date: Sat, 12 Aug 2006 01:38:35 -0700
Message-ID: <20060812013835.b4b6b815.akpm@osdl.org>
References: <11552856103972@2ka.mipt.ru>
	<11552856102674@2ka.mipt.ru>
	<20060811084531.ac727a7b.akpm@osdl.org>
	<20060812081835.GA30248@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: lkml <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Ulrich Drepper <drepper@redhat.com>,
	netdev <netdev@vger.kernel.org>,
	Zach Brown <zach.brown@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:49289 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932351AbWHLIjO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Aug 2006 04:39:14 -0400
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <20060812081835.GA30248@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 12 Aug 2006 12:18:35 +0400
Evgeniy Polyakov <johnpol@2ka.mipt.ru> wrote:

> On Fri, Aug 11, 2006 at 08:45:31AM -0700, Andrew Morton (akpm@osdl.org) wrote:
> > > +static struct lock_class_key kevent_poll_key;
> > > +
> > > +void kevent_poll_reinit(struct file *file)
> > > +{
> > > +	lockdep_set_class(&file->st.lock, &kevent_poll_key);
> > > +}
> > 
> > Why is this necessary?
> 
> Locks for all storages are initialized in the same function, so lockdep thinks 
> they are the same, so when later one lock is being held in proces
> context and other in BH or IRQ lockdep screams, so I reinitialize locks
> after spin_lock_init().

So why not simply run spin_lock_init() in the kevent_storage_init() caller?

Does kevent_poll_reinit() have any callers?

> > > +	st = (struct kevent_storage *)(t+1);
> > 
> > It would be cleaner to create
> > 
> > 	struct <something> {
> > 		struct timer_list timer;
> > 		struct kevent_storage storage;
> > 	};

You missed this?

> 
> > > +	
> > > +	kevent_storage_dequeue(st, k);
> > > +	
> > > +	kfree(t);
> > > +
> > > +	return 0;
> > > +}
> > > +
> > > +static int kevent_timer_callback(struct kevent *k)
> > > +{
> > > +	struct kevent_storage *st = k->st;
> > > +	struct timer_list *t = st->origin;
> > > +
> > > +	if (!t)
> > > +		return -ENODEV;
> > > +	
> > > +	k->event.ret_data[0] = (__u32)jiffies;
> > 
> > What does this do?
> > 
> > Does it expose jiffies to userspace?
> > 
> > It truncates jiffies on 64-bit machines.
> 
> It is a hint when timer was stopped.

What does that mean?  What is it for?

Does it expose jiffies to userspace?

It truncates jiffies on 64-bit machines.

Please respond to all review comments and questions.

> > > +late_initcall(kevent_init_timer);
> > 
> > module_init() would be more typical.  If there was a reason for using
> > late_initcall(), that reason should be commented.
> 
> No, there are no reasons to use late_initcall() in any kevent
> initialization function, I do not use module_init() since kevent can not
> be modular. It can be replaced with pure __init function.
> Should it?

We use module_init() for non-modular modules all the time.  Try doing
grep module_init */*.c

