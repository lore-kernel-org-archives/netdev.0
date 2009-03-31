From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 2/2] sysctl:  lockdep support for sysctl reference counting.
Date: Tue, 31 Mar 2009 15:44:11 -0700
Message-ID: <m1hc198g90.fsf@fess.ebiederm.org>
References: <49B91A7E.76E4.0078.0@novell.com>
	<tip-6a09dfa870ba0ed21b1124539968a36b42660661@git.kernel.org>
	<1236934491.5188.209.camel@laptop> <49BA33BE.76E4.0078.0@novell.com>
	<1236937423.22914.3698.camel@twins> <20090313103828.GB31094@elte.hu>
	<m1d4cd9n4k.fsf@fess.ebiederm.org> <20090320085205.GB16021@elte.hu>
	<m14oxo8qis.fsf@fess.ebiederm.org> <20090320182404.GA31629@elte.hu>
	<1237575134.4667.5.camel@laptop> <1237577688.4667.68.camel@laptop>
	<m1iqm3xr2n.fsf_-_@fess.ebiederm.org>
	<m1eiwrxr05.fsf_-_@fess.ebiederm.org>
	<m1ab7fxqxw.fsf_-_@fess.ebiederm.org>
	<1238487448.28248.1805.camel@twins> <m1vdppbyjd.fsf@fess.ebiederm.org>
	<1238513726.8530.564.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Ingo Molnar <mingo@elte.hu>, Jan Beulich <jbeulich@novell.com>,
	tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com,
	linux-kernel@vger.kernel.org, Gautham R Shenoy <ego@in.ibm.com>,
	Alexey Dobriyan <adobriyan@gmail.com>, netdev@vger.kernel.org
To: Peter Zijlstra <peterz@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:60350 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751850AbZCaWoY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Mar 2009 18:44:24 -0400
In-Reply-To: <1238513726.8530.564.camel@twins> (Peter Zijlstra's message of "Tue\, 31 Mar 2009 17\:35\:26 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Peter Zijlstra <peterz@infradead.org> writes:

> On Tue, 2009-03-31 at 06:40 -0700, Eric W. Biederman wrote:
>> Peter Zijlstra <peterz@infradead.org> writes:
>> 
>> > On Sat, 2009-03-21 at 00:42 -0700, Eric W. Biederman wrote:
>> >> It is possible for get lock ordering deadlocks between locks
>> >> and waiting for the sysctl used count to drop to zero.  We have
>> >> recently observed one of these in the networking code.
>> >> 
>> >> So teach the sysctl code how to speak lockdep so the kernel
>> >> can warn about these kinds of rare issues proactively.
>> >
>> > It would be very good to extend this changelog with a more detailed
>> > explanation of the deadlock in question.
>> >
>> > Let me see if I got it right:
>> >
>> > We're holding a lock, while waiting for the refcount to drop to 0.
>> > Dropping that refcount is blocked on that lock.
>> >
>> > Something like that?
>> 
>> Exactly.
>> 
>> I must have written an explanation so many times that it got
>> lost when I wrote that commit message.
>> 
>> In particular the problem can be see with /proc/sys/net/ipv4/conf/*/forwarding.
>> 
>> The problem is that the handler for fowarding takes the rtnl_lock
>> with the reference count held.
>> 
>> Then we call unregister_sysctl_table under the rtnl_lock.
>> which waits for the reference count to go to zero.
>
>> >> +
>> >> +#  define lock_sysctl() __raw_spin_lock(&sysctl_lock.raw_lock)
>> >> +#  define unlock_sysctl() __raw_spin_unlock(&sysctl_lock.raw_lock)
>> >
>> > Uhmm, Please explain that -- without a proper explanation this is a NAK.
>> 
>> If the refcount is to be considered a lock.  sysctl_lock must be considered
>> the internals of that lock.  lockdep gets extremely confused otherwise.
>> Since the spinlock is static to this file I'm not especially worried
>> about it.
>
> Usually lock internal locks still get lockdep coverage. Let see if we
> can find a way for this to be true even here. I suspect the below to
> cause the issue:
>
>> >>  /* called under sysctl_lock, will reacquire if has to wait */
>> >> @@ -1478,47 +1531,54 @@ static void start_unregistering(struct ctl_table_header *p)
>> >>  	 * if p->used is 0, nobody will ever touch that entry again;
>> >>  	 * we'll eliminate all paths to it before dropping sysctl_lock
>> >>  	 */
>> >> +	table_acquire(p);
>> >>  	if (unlikely(p->used)) {
>> >>  		struct completion wait;
>> >> +		table_contended(p);
>> >> +
>> >>  		init_completion(&wait);
>> >>  		p->unregistering = &wait;
>> >> -		spin_unlock(&sysctl_lock);
>> >> +		unlock_sysctl();
>> >>  		wait_for_completion(&wait);
>> >> -		spin_lock(&sysctl_lock);
>> >> +		lock_sysctl();
>> >>  	} else {
>> >>  		/* anything non-NULL; we'll never dereference it */
>> >>  		p->unregistering = ERR_PTR(-EINVAL);
>> >>  	}
>> >> +	table_acquired(p);
>> >> +
>> >>  	/*
>> >>  	 * do not remove from the list until nobody holds it; walking the
>> >>  	 * list in do_sysctl() relies on that.
>> >>  	 */
>> >>  	list_del_init(&p->ctl_entry);
>> >> +
>> >> +	table_release(p);
>> >>  }
>
> There you acquire the table while holding the spinlock, generating:
> sysctl_lock -> table_lock, however you then release the sysctl_lock and
> re-acquire it, generating table_lock -> sysctl_lock.
>
> Humm, can't we write that differently?

That is an artifact of sysctl_lock being used to implement
table_lock as best as I can tell.  The case you point
out I could probably play with where I claim the lock
is acquired and make it work.

__sysctl_head_next on the read side is trickier.
We come in with table_lock held for read.
We grab sysctl_lock.
We release table_lock (aka the reference count is decremented)
We grab table_lock on the next table (aka the reference count is incremented)
We release sysctl_lock

If we generate lockdep annotations for that it would seem to transition
through the states:
table_lock
table_lock -> sysctl_lock
sysctl_lock
sysctl_lock -> table_lock
table_lock

Short of saying table_lock is an implementation detail.  Used to
make certain operations atomic I do not see how to model this case.

Let me take a slightly simpler case and ask how that gets modeled.
Looking at rwsem.  Ok all of the annotations are outside of the
spin_lock.  So in some sense we are sloppy, and fib to lockdep
about when the we acquire/release a lock.  In another sense
we are simply respecting the abstraction.

I guess I can take a look and see if I can model things a slightly
more lossy fashion so I don't need to do the __raw_spin_lock thing.


>> >> @@ -1951,7 +2011,13 @@ struct ctl_table_header *__register_sysctl_paths(
>> >>  		return NULL;
>> >>  	}
>> >>  #endif
>> >> -	spin_lock(&sysctl_lock);
>> >> +#ifdef CONFIG_DEBUG_LOCK_ALLOC
>> >> +	{
>> >> +		static struct lock_class_key __key;
>> >> +		lockdep_init_map(&header->dep_map, "sysctl_used", &__key, 0);
>> >> +	}
>> >> +#endif	
>> >
>> > This means every sysctl thingy gets the same class, is that
>> > intended/desired?
>> 
>> There is only one place we initialize it, and as far as I know really
>> only one place we take it.  Which is the definition of a lockdep
>> class as far as I know.
>
> Indeed, just checking.

The only difference I can possibly see is read side versus write side.
Or in my case refcount side versus wait side.

Eric

