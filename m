From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] NETDEV_UNREGISTER_BATCH seems unused nowaday ?
Date: Fri, 10 Aug 2012 17:01:19 +0200
Message-ID: <1344610879.31104.2715.camel@edumazet-glaptop>
References: <1344590824.31104.1953.camel@edumazet-glaptop>
	 <20120810.034211.994338127277150687.davem@davemloft.net>
	 <1344596809.31104.2358.camel@edumazet-glaptop>
	 <87vcgq955v.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:47992 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758269Ab2HJPBY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Aug 2012 11:01:24 -0400
Received: by bkwj10 with SMTP id j10so633091bkw.19
        for <netdev@vger.kernel.org>; Fri, 10 Aug 2012 08:01:23 -0700 (PDT)
In-Reply-To: <87vcgq955v.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-08-10 at 07:45 -0700, Eric W. Biederman wrote:

> Can someone help bring me up to speed.  What has changed in the
> dst ref counting that has invalidated our previous solutions?
> 

In fact your patch (850a545bd8a416484 net: Move rcu_barrier from
rollback_registered_many to netdev_run_todo.) reinstated the problem
again. You didnt notice, but other people can see the problem.

> As for the idea of putting an rcu_barrier inside of the rtnl_lock.  I
> really don't like it. You are trading off a 1000ms singled threaded wait
> without locks for extending the hold times of rtnl lock by 12ms or so.
> 

We probably can keep the rcu_barrier() in netdev_run_todo() and kick the
UNREGISTER_FINAL in netdev_run_todo() too.

I'll try that.


> We already have an rcu_barrier on that path in netdev_run_todo,
> so we can reorganize things to use that barrier I would be much
> happer.  Furthermore I talked to Paul McKenney a while ago
> about creating an rcu_barrier expedited and he really did not
> like the idea.
> 
> Reading through the code we really should get dst_rcu_free
> out of the header and make it non-line.  dst_rcu_free can't
> possibly be called from a location where it can be inlined.
> 
> Trying to understand your analysis I have stared at the code for
> a while and I am definitely not seeing any rcu callbacks that
> result in calling rt_free.  So one of us is missing something.

Recent commits add the rt_free() calls.

Of course, if you unregister a dummy device you wont see the problem.

If you unregister a real device, you definitely hit the problem.
