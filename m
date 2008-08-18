From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] pkt_sched: Destroy gen estimators under rtnl_lock().
Date: Mon, 18 Aug 2008 22:12:36 +0200
Message-ID: <20080818201236.GA3366@ami.dom.local>
References: <20080817.153218.178334822.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	denys@visp.net.lb
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.186]:44358 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751779AbYHRUJz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Aug 2008 16:09:55 -0400
Received: by nf-out-0910.google.com with SMTP id d3so1254991nfc.21
        for <netdev@vger.kernel.org>; Mon, 18 Aug 2008 13:09:54 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080817.153218.178334822.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote, On 08/18/2008 12:32 AM:
...
> What is the real problem besides the correct notify_and_destroy()
> issue you discovered?
> 
> The locking we have now is very simple:

Probably simple for you, but I'm not even sure of this. If it were
true there would be no this and a few other threads concerned with
this.

> 
> 1) Only under RTNL can qdisc roots change.
> 
> 2) Therefore, sch_tree_lock() and tcf_tree_lock() are fully valid
>    and lock the entire qdisc tree state, if and only if used under
>    RTNL lock.
> 
> 3) Before modifying a qdisc, we dev_deactivate(), which synchronizes
>    with asynchronous TX/RX packet handling contexts.
> 
> 4) The qdisc root and all children are protected by the root qdiscs
>    lock, which is taken when asynchonous contexts need to blocked
>    while modifying some root or inner qdisc's state.
> 
> Yes, of course, if you apply a hammer and add a bit lock at the
> top of all of this it will fix whatever bugs remain, but as you
> know I don't think that's the solution.

I don't think it's true. What matters here is the qdisc lock. And
within the qdisc's tree only one such lock can matter because current
code doesn't use qdisc locks on lower levels. So we need to take this
one top lock. But as we have seen in notify_and_destroy() or
qdisc_watchdog() it's easy to do this wrong because you've always
analyze the tree plus activated/deactivated state. My proposal is to
simply have still this one lock but easy accessible at some well
known place (actually, with an exception for builtin qdiscs).

> The only substance I've seen is that you've found a violation of #4 in
> notify_and_destroy(), so great let's test the fix for that.

Actually, after partly fixing this we have currently messed this up
again. We can't destroy a qdisc without RCU or some other delayed
method while we're holding a lock inside this - and this is a case
of root qdiscs... It's quite simple too, but why we've missed this
so easily?

As mentioned there was also this tricky qdisc_watchdog (or other
direct __netif_scheduling), but this is not all. Try to look at
qdisc_create() and gen_new_estimator() call. It passes
qdisc_root_lock(sch) somewhere. This is similar to qdisc_watchdog()
problem, but are you really sure we always save the right spinlock
here? I don't think so.

So, of course, if you think such problems are exceptional, and will
not return after current fixes, then we can continue, no problem
for me, but I'm not sure how about Denys or other testers and users.

Jarek P.
