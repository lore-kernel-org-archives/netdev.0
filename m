From: Patrick McHardy <kaber@trash.net>
Subject: Re: tc related lockdep warning.
Date: Thu, 28 Sep 2006 14:17:51 +0200
Message-ID: <451BBD6F.6020007@trash.net>
References: <20060925124352.GA1592@ff.dom.local> <1159188473.5301.68.camel@jzny2> <4517D9A6.70307@trash.net> <45195219.7050105@trash.net> <20060926212034.GA3134@redhat.com> <20060927085427.GA1619@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Dave Jones <davej@redhat.com>, hadi@cyberus.ca,
	netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx01.qsc.de ([213.148.129.14]:17805 "EHLO mx01.qsc.de")
	by vger.kernel.org with ESMTP id S1751802AbWI1MRy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Sep 2006 08:17:54 -0400
To: Jarek Poplawski <jarkao2@o2.pl>
In-Reply-To: <20060927085427.GA1619@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[My mail provider is down, so responding "manually"]

Jarek Poplawski wrote:
> > [NET_SCHED]: Fix fallout from dev->qdisc RCU change
>
> Sorry again but I can't abstain from some doubts:
>
> ...
> > diff --git a/net/core/dev.c b/net/core/dev.c
> > index 14de297..4d891be 100644
> > --- a/net/core/dev.c
> > +++ b/net/core/dev.c
> > @@ -1480,14 +1480,16 @@ #endif
> >  	if (q->enqueue) {
> >  		/* Grab device queue */
> >  		spin_lock(&dev->queue_lock);
> > +		q = dev->qdisc;
>
> I don't get it. If it is some anti-race step according to
> rcu rules it should be again:
> q = rcu_dereference(dev->qdisc);

At this point RCU protection is not needed anymore since we
have the lock. We simply want to avoid taking the lock for
devices that don't have a real qdisc attached (like loopback).
Thats what the test for q->enqueue is there for. RCU is only
needed to avoid races between testing q->enqueue and freeing
of the qdisc.

> But I don't know which of the attached lockups would be
> fixed by this.

None - the repeated check is needed because deconstruction
of the qdisc tree now happens immediately instead of in the
RCU callback, so stale data can't be tolerated.

> And by the way - a few lines above is:
> rcu_read_lock_bh();
> which according to the rules should be
> rcu_read_lock();
> (or call_rcu should be changed to call_rcu_bh).

Read up on how it got there or simply look at the comment directly
above it:

        /* Disable soft irqs for various locks below. Also
         * stops preemption for RCU.
         */

> > @@ -504,32 +489,23 @@ #endif
> >
> >  void qdisc_destroy(struct Qdisc *qdisc)
> >  {
> > -	struct list_head cql = LIST_HEAD_INIT(cql);
> > -	struct Qdisc *cq, *q, *n;
> > +	struct Qdisc_ops  *ops = qdisc->ops;
> >
> >  	if (qdisc->flags & TCQ_F_BUILTIN ||
> > -		!atomic_dec_and_test(&qdisc->refcnt))
> > +	    !atomic_dec_and_test(&qdisc->refcnt))
> >  		return;
> ...
> > +	list_del(&qdisc->list);
> > +#ifdef CONFIG_NET_ESTIMATOR
> > +	gen_kill_estimator(&qdisc->bstats, &qdisc->rate_est);
> > +#endif
> > +	if (ops->reset)
> > +		ops->reset(qdisc);
> > +	if (ops->destroy)
> > +		ops->destroy(qdisc);
> >
> > +	module_put(ops->owner);
> > +	dev_put(qdisc->dev);
> >  	call_rcu(&qdisc->q_rcu, __qdisc_destroy);
>
>
> This qdisc way of RCU looks very "special" to me.
> Is this really doing anything here? There is no
> pointers switching, everything is deleted in place,
> refcnt checked, no clean read_lock_rcu (without
> spin_locks) anywhere - in my once more not very
> humble opinion it is only very advanced method of
> time wasting.

You don't seem to understand what is done here at all and
additionally haven't even read any of the comments explaining
what this is for. You are wasting time.

As I already explained, RCU is only needed for one thing,
and for nothing more: to make sure the q->enqueue check
in net/core/dev.c doesn't reference freed memory.
Therefore just the final free is done in the RCU callback.
We could also have used synchronize_net(), but it doesn't
really matter.

