From: Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Subject: Re: Kernel WARNING: at net/core/dev.c:1330
	__netif_schedule+0x2c/0x98()
Date: Thu, 24 Jul 2008 12:59:46 +0200
Message-ID: <1216897186.7257.279.camel@twins>
References: <1216890648.7257.258.camel@twins>
	 <20080724.023210.229338550.davem@davemloft.net>
	 <1216894136.7257.266.camel@twins>
	 <200807242038.36693.nickpiggin@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, jarkao2-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org, kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org,
	torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
To: Nick Piggin <nickpiggin-/E1597aS9LT0CCvOHzKKcA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <200807242038.36693.nickpiggin-/E1597aS9LT0CCvOHzKKcA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 2008-07-24 at 20:38 +1000, Nick Piggin wrote:
> On Thursday 24 July 2008 20:08, Peter Zijlstra wrote:
> > On Thu, 2008-07-24 at 02:32 -0700, David Miller wrote:
> > > From: Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
> > > Date: Thu, 24 Jul 2008 11:27:05 +0200
> > >
> > > > Well, not only lockdep, taking a very large number of locks is
> > > > expensive as well.
> > >
> > > Right now it would be on the order of 16 or 32 for
> > > real hardware.
> > >
> > > Much less than the scheduler currently takes on some
> > > of my systems, so currently you are the pot calling the
> > > kettle black. :-)
> >
> > One nit, and then I'll let this issue rest :-)
> >
> > The scheduler has a long lock dependancy chain (nr_cpu_ids rq locks),
> > but it never takes all of them at the same time. Any one code path will
> > at most hold two rq locks.
> 
> Aside from lockdep, is there a particular problem with taking 64k locks
> at once? (in a very slow path, of course) I don't think it causes a
> problem with preempt_count, does it cause issues with -rt kernel?

PI-chains might explode I guess, Thomas?

Besides that, I just have this voice in my head telling me that
minimizing the number of locks held is a good thing.

> Hey, something kind of cool (and OT) I've just thought of that we can
> do with ticket locks is to take tickets for 2 (or 64K) nested locks,
> and then wait for them both (all), so the cost is N*lock + longest spin,
> rather than N*lock + N*avg spin.
> 
> That would mean even at the worst case of a huge amount of contention
> on all 64K locks, it should only take a couple of ms to take all of
> them (assuming max spin time isn't ridiculous).
> 
> Probably not the kind of feature we want to expose widely, but for
> really special things like the scheduler, it might be a neat hack to
> save a few cycles ;) Traditional implementations would just have
> #define spin_lock_async	      spin_lock
> #define spin_lock_async_wait  do {} while (0)
> 
> Sorry it's offtopic, but if I didn't post it, I'd forget to. Might be
> a fun quick hack for someone.

It might just be worth it for double_rq_lock() - if you can sort out the
deadlock potential Miklos just raised ;-)

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
