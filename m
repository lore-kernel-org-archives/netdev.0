From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: tc related lockdep warning.
Date: Thu, 28 Sep 2006 10:17:09 +0200
Message-ID: <20060928081709.GA1820@ff.dom.local>
References: <20060925124352.GA1592@ff.dom.local> <1159188473.5301.68.camel@jzny2> <4517D9A6.70307@trash.net> <45195219.7050105@trash.net> <20060926212034.GA3134@redhat.com> <451A6968.2090607@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dave Jones <davej@redhat.com>, hadi@cyberus.ca,
	netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.go2.pl ([193.17.41.41]:28340 "EHLO poczta.o2.pl")
	by vger.kernel.org with ESMTP id S1751026AbWI1IMt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Sep 2006 04:12:49 -0400
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <451A6968.2090607@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 27, 2006 at 02:07:04PM +0200, Patrick McHardy wrote:
> Dave Jones wrote:
> > With this patch, I get no lockdep warnings, but the machine locks up completely.
> > I hooked up a serial console, and found this..
> > 
> > 
> > u32 classifier
> >     Performance counters on
> >     input device check on 
> >     Actions configured 
> > BUG: warning at net/sched/sch_htb.c:395/htb_safe_rb_erase()
> > 
> > Call Trace:
> >  [<ffffffff8026f79b>] show_trace+0xae/0x336
> >  [<ffffffff8026fa38>] dump_stack+0x15/0x17
> >  [<ffffffff8860a171>] :sch_htb:htb_safe_rb_erase+0x3b/0x55
> 
> I found the reason for this, it was an unrelated bug. I've attached
> the latest version of the locking fixes and the fix for the HTB bug.

Congratulations! (But I think David Jones could have saved some brain
cycles applying fixes to the same version where the bug originated). 

...
> [NET_SCHED]: Fix fallout from dev->qdisc RCU change

Sorry again but I can't abstain from some doubts: 

...
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 14de297..4d891be 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -1480,14 +1480,16 @@ #endif
>  	if (q->enqueue) {
>  		/* Grab device queue */
>  		spin_lock(&dev->queue_lock);
> +		q = dev->qdisc;

I don't get it. If it is some anti-race step according to
rcu rules it should be again:
q = rcu_dereference(dev->qdisc);

But I don't know which of the attached lockups would be
fixed by this. 
And by the way - a few lines above is:
rcu_read_lock_bh();
which according to the rules should be
rcu_read_lock();
(or call_rcu should be changed to call_rcu_bh).

> +		if (q->enqueue) {
> +			rc = q->enqueue(skb, q);
> +			qdisc_run(dev);
> +			spin_unlock(&dev->queue_lock);
>  
> -		rc = q->enqueue(skb, q);
> -
> -		qdisc_run(dev);
> -
> +			rc = rc == NET_XMIT_BYPASS ? NET_XMIT_SUCCESS : rc;
> +			goto out;
> +		}
>  		spin_unlock(&dev->queue_lock);
> -		rc = rc == NET_XMIT_BYPASS ? NET_XMIT_SUCCESS : rc;
> -		goto out;
>  	}

By the way: rcu_read_unlock could be done here instead
at the very end. 

> @@ -504,32 +489,23 @@ #endif
>  
>  void qdisc_destroy(struct Qdisc *qdisc)
>  {
> -	struct list_head cql = LIST_HEAD_INIT(cql);
> -	struct Qdisc *cq, *q, *n;
> +	struct Qdisc_ops  *ops = qdisc->ops;
>  
>  	if (qdisc->flags & TCQ_F_BUILTIN ||
> -		!atomic_dec_and_test(&qdisc->refcnt))
> +	    !atomic_dec_and_test(&qdisc->refcnt))
>  		return;
...
> +	list_del(&qdisc->list);
> +#ifdef CONFIG_NET_ESTIMATOR
> +	gen_kill_estimator(&qdisc->bstats, &qdisc->rate_est);
> +#endif
> +	if (ops->reset)
> +		ops->reset(qdisc);
> +	if (ops->destroy)
> +		ops->destroy(qdisc);
>  
> +	module_put(ops->owner);
> +	dev_put(qdisc->dev);
>  	call_rcu(&qdisc->q_rcu, __qdisc_destroy);

This qdisc way of RCU looks very "special" to me.
Is this really doing anything here? There is no
pointers switching, everything is deleted in place, 
refcnt checked, no clean read_lock_rcu (without
spin_locks) anywhere - in my once more not very
humble opinion it is only very advanced method of
time wasting. 

Jarek P.
