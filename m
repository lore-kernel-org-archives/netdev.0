From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 2/2] sysctl:  lockdep support for sysctl reference
 counting.
Date: Tue, 31 Mar 2009 17:35:26 +0200
Message-ID: <1238513726.8530.564.camel@twins>
References: <49B91A7E.76E4.0078.0@novell.com>
	 <tip-6a09dfa870ba0ed21b1124539968a36b42660661@git.kernel.org>
	 <1236934491.5188.209.camel@laptop> <49BA33BE.76E4.0078.0@novell.com>
	 <1236937423.22914.3698.camel@twins> <20090313103828.GB31094@elte.hu>
	 <m1d4cd9n4k.fsf@fess.ebiederm.org> <20090320085205.GB16021@elte.hu>
	 <m14oxo8qis.fsf@fess.ebiederm.org> <20090320182404.GA31629@elte.hu>
	 <1237575134.4667.5.camel@laptop> <1237577688.4667.68.camel@laptop>
	 <m1iqm3xr2n.fsf_-_@fess.ebiederm.org> <m1eiwrxr05.fsf_-_@fess.ebiederm.org>
	 <m1ab7fxqxw.fsf_-_@fess.ebiederm.org> <1238487448.28248.1805.camel@twins>
	 <m1vdppbyjd.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Ingo Molnar <mingo@elte.hu>, Jan Beulich <jbeulich@novell.com>,
	tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com,
	linux-kernel@vger.kernel.org, Gautham R Shenoy <ego@in.ibm.com>,
	Alexey Dobriyan <adobriyan@gmail.com>, netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:46638 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759159AbZCaPfP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Mar 2009 11:35:15 -0400
In-Reply-To: <m1vdppbyjd.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2009-03-31 at 06:40 -0700, Eric W. Biederman wrote:
> Peter Zijlstra <peterz@infradead.org> writes:
> 
> > On Sat, 2009-03-21 at 00:42 -0700, Eric W. Biederman wrote:
> >> It is possible for get lock ordering deadlocks between locks
> >> and waiting for the sysctl used count to drop to zero.  We have
> >> recently observed one of these in the networking code.
> >> 
> >> So teach the sysctl code how to speak lockdep so the kernel
> >> can warn about these kinds of rare issues proactively.
> >
> > It would be very good to extend this changelog with a more detailed
> > explanation of the deadlock in question.
> >
> > Let me see if I got it right:
> >
> > We're holding a lock, while waiting for the refcount to drop to 0.
> > Dropping that refcount is blocked on that lock.
> >
> > Something like that?
> 
> Exactly.
> 
> I must have written an explanation so many times that it got
> lost when I wrote that commit message.
> 
> In particular the problem can be see with /proc/sys/net/ipv4/conf/*/forwarding.
> 
> The problem is that the handler for fowarding takes the rtnl_lock
> with the reference count held.
> 
> Then we call unregister_sysctl_table under the rtnl_lock.
> which waits for the reference count to go to zero.

> >> +
> >> +#  define lock_sysctl() __raw_spin_lock(&sysctl_lock.raw_lock)
> >> +#  define unlock_sysctl() __raw_spin_unlock(&sysctl_lock.raw_lock)
> >
> > Uhmm, Please explain that -- without a proper explanation this is a NAK.
> 
> If the refcount is to be considered a lock.  sysctl_lock must be considered
> the internals of that lock.  lockdep gets extremely confused otherwise.
> Since the spinlock is static to this file I'm not especially worried
> about it.

Usually lock internal locks still get lockdep coverage. Let see if we
can find a way for this to be true even here. I suspect the below to
cause the issue:

> >>  /* called under sysctl_lock, will reacquire if has to wait */
> >> @@ -1478,47 +1531,54 @@ static void start_unregistering(struct ctl_table_header *p)
> >>  	 * if p->used is 0, nobody will ever touch that entry again;
> >>  	 * we'll eliminate all paths to it before dropping sysctl_lock
> >>  	 */
> >> +	table_acquire(p);
> >>  	if (unlikely(p->used)) {
> >>  		struct completion wait;
> >> +		table_contended(p);
> >> +
> >>  		init_completion(&wait);
> >>  		p->unregistering = &wait;
> >> -		spin_unlock(&sysctl_lock);
> >> +		unlock_sysctl();
> >>  		wait_for_completion(&wait);
> >> -		spin_lock(&sysctl_lock);
> >> +		lock_sysctl();
> >>  	} else {
> >>  		/* anything non-NULL; we'll never dereference it */
> >>  		p->unregistering = ERR_PTR(-EINVAL);
> >>  	}
> >> +	table_acquired(p);
> >> +
> >>  	/*
> >>  	 * do not remove from the list until nobody holds it; walking the
> >>  	 * list in do_sysctl() relies on that.
> >>  	 */
> >>  	list_del_init(&p->ctl_entry);
> >> +
> >> +	table_release(p);
> >>  }

There you acquire the table while holding the spinlock, generating:
sysctl_lock -> table_lock, however you then release the sysctl_lock and
re-acquire it, generating table_lock -> sysctl_lock.

Humm, can't we write that differently?


> >> @@ -1951,7 +2011,13 @@ struct ctl_table_header *__register_sysctl_paths(
> >>  		return NULL;
> >>  	}
> >>  #endif
> >> -	spin_lock(&sysctl_lock);
> >> +#ifdef CONFIG_DEBUG_LOCK_ALLOC
> >> +	{
> >> +		static struct lock_class_key __key;
> >> +		lockdep_init_map(&header->dep_map, "sysctl_used", &__key, 0);
> >> +	}
> >> +#endif	
> >
> > This means every sysctl thingy gets the same class, is that
> > intended/desired?
> 
> There is only one place we initialize it, and as far as I know really
> only one place we take it.  Which is the definition of a lockdep
> class as far as I know.

Indeed, just checking.
