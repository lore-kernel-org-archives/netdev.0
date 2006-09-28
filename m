From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: tc related lockdep warning.
Date: Thu, 28 Sep 2006 15:13:01 +0200
Message-ID: <20060928131301.GB3283@ff.dom.local>
References: <20060925124352.GA1592@ff.dom.local> <1159188473.5301.68.camel@jzny2> <4517D9A6.70307@trash.net> <45195219.7050105@trash.net> <20060926212034.GA3134@redhat.com> <20060927085427.GA1619@ff.dom.local> <451BBD6F.6020007@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dave Jones <davej@redhat.com>, hadi@cyberus.ca,
	netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx10.go2.pl ([193.17.41.74]:55256 "EHLO poczta.o2.pl")
	by vger.kernel.org with ESMTP id S1161111AbWI1NIl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Sep 2006 09:08:41 -0400
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <451BBD6F.6020007@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 28, 2006 at 02:17:51PM +0200, Patrick McHardy wrote:
> [My mail provider is down, so responding "manually"]
> 
> Jarek Poplawski wrote:
> > > [NET_SCHED]: Fix fallout from dev->qdisc RCU change
> >
> > Sorry again but I can't abstain from some doubts:
> >
> > ...
> > > diff --git a/net/core/dev.c b/net/core/dev.c
> > > index 14de297..4d891be 100644
> > > --- a/net/core/dev.c
> > > +++ b/net/core/dev.c
> > > @@ -1480,14 +1480,16 @@ #endif
> > >  	if (q->enqueue) {
> > >  		/* Grab device queue */
> > >  		spin_lock(&dev->queue_lock);
> > > +		q = dev->qdisc;
> >
> > I don't get it. If it is some anti-race step according to
> > rcu rules it should be again:
> > q = rcu_dereference(dev->qdisc);
> 
> At this point RCU protection is not needed anymore since we
> have the lock. We simply want to avoid taking the lock for
> devices that don't have a real qdisc attached (like loopback).
> Thats what the test for q->enqueue is there for. RCU is only
> needed to avoid races between testing q->enqueue and freeing
> of the qdisc.

But in Documentation/RCU/whatisRCU.txt I see this:

        /*
         * Return the value of field "a" of the current gbl_foo
         * structure.  Use rcu_read_lock() and rcu_read_unlock()
         * to ensure that the structure does not get deleted out
         * from under us, and use rcu_dereference() to ensure that
         * we see the initialized version of the structure (important
         * for DEC Alpha and for people reading the code).
         */
        int foo_get_a(void)
        {
                int retval;

                rcu_read_lock();
                retval = rcu_dereference(gbl_foo)->a;
                rcu_read_unlock();
                return retval;
        }

 
> > But I don't know which of the attached lockups would be
> > fixed by this.
> 
> None - the repeated check is needed because deconstruction
> of the qdisc tree now happens immediately instead of in the
> RCU callback, so stale data can't be tolerated.
> 
> > And by the way - a few lines above is:
> > rcu_read_lock_bh();
> > which according to the rules should be
> > rcu_read_lock();
> > (or call_rcu should be changed to call_rcu_bh).
> 
> Read up on how it got there or simply look at the comment directly
> above it:
> 
>         /* Disable soft irqs for various locks below. Also
>          * stops preemption for RCU.
>          */
> 

I've read it. And also this from include/linux/rcupdate.h:

/**
 * rcu_read_lock_bh - mark the beginning of a softirq-only RCU critical section
 *
 * This is equivalent of rcu_read_lock(), but to be used when updates
 * are being done using call_rcu_bh(). Since call_rcu_bh() callbacks
 * consider completion of a softirq handler to be a quiescent state,
 * a process in RCU read-side critical section must be protected by
 * disabling softirqs. Read-side critical sections in interrupt context
 * can use just rcu_read_lock().
 *
 */
#define rcu_read_lock_bh() \


> > > @@ -504,32 +489,23 @@ #endif
> > >
> > >  void qdisc_destroy(struct Qdisc *qdisc)
> > >  {
> > > -	struct list_head cql = LIST_HEAD_INIT(cql);
> > > -	struct Qdisc *cq, *q, *n;
> > > +	struct Qdisc_ops  *ops = qdisc->ops;
> > >
> > >  	if (qdisc->flags & TCQ_F_BUILTIN ||
> > > -		!atomic_dec_and_test(&qdisc->refcnt))
> > > +	    !atomic_dec_and_test(&qdisc->refcnt))
> > >  		return;
> > ...
> > > +	list_del(&qdisc->list);
> > > +#ifdef CONFIG_NET_ESTIMATOR
> > > +	gen_kill_estimator(&qdisc->bstats, &qdisc->rate_est);
> > > +#endif
> > > +	if (ops->reset)
> > > +		ops->reset(qdisc);
> > > +	if (ops->destroy)
> > > +		ops->destroy(qdisc);
> > >
> > > +	module_put(ops->owner);
> > > +	dev_put(qdisc->dev);
> > >  	call_rcu(&qdisc->q_rcu, __qdisc_destroy);
> >
> >
> > This qdisc way of RCU looks very "special" to me.
> > Is this really doing anything here? There is no
> > pointers switching, everything is deleted in place,
> > refcnt checked, no clean read_lock_rcu (without
> > spin_locks) anywhere - in my once more not very
> > humble opinion it is only very advanced method of
> > time wasting.
> 
> You don't seem to understand what is done here at all and
> additionally haven't even read any of the comments explaining
> what this is for. You are wasting time.

I've only written my personal opinion and a word "special"
could suggest it is hard to comprehend for me. I didn't
intend to offend anybody so I'm very sorry.  
 
> As I already explained, RCU is only needed for one thing,
> and for nothing more: to make sure the q->enqueue check
> in net/core/dev.c doesn't reference freed memory.
> Therefore just the final free is done in the RCU callback.
> We could also have used synchronize_net(), but it doesn't
> really matter.

Probably my problem is I didn't see anything like that
in docs. Anyway thank you very much for explanation.

Jarek P.  

