From: Shaohua Li <shli@kernel.org>
Subject: Re: [RFC net-next] net ipv6: convert fib6_table rwlock to a percpu
 lock
Date: Mon, 31 Jul 2017 12:34:07 -0700
Message-ID: <20170731193407.d4cmfq7v3ooewkrc@kernel.org>
References: <1a5ad2f0585aa66496b27e123d1c38b75552df4c.1501520674.git.shli@fb.com>
 <1501525853.1876.22.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, Kernel-team@fb.com,
        Shaohua Li <shli@fb.com>, Wei Wang <weiwan@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:59232 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750967AbdGaTeJ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 31 Jul 2017 15:34:09 -0400
Content-Disposition: inline
In-Reply-To: <1501525853.1876.22.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 31, 2017 at 11:30:53AM -0700, Eric Dumazet wrote:
> On Mon, 2017-07-31 at 10:18 -0700, Shaohua Li wrote:
> > From: Shaohua Li <shli@fb.com>
> > 
> > In a syn flooding test, the fib6_table rwlock is a significant
> > bottleneck. While converting the rwlock to rcu sounds straighforward,
> > but is very challenging if it's possible. A percpu spinlock is quite
> > trival for this problem since updating the routing table is a rare
> > event. In my test, the server receives around 1.5 Mpps in syn flooding
> > test without the patch in a dual sockets and 56-CPU system. With the
> > patch, the server receives around 3.8Mpps, and perf report doesn't show
> > the locking issue.
> > 
> 
> > +static inline void fib6_table_write_lock_bh(struct fib6_table *table)
> > +{
> > +	int i;
> > +
> > +	spin_lock_bh(per_cpu_ptr(table->percpu_tb6_lock, 0));
> > +	for_each_possible_cpu(i) {
> > +		if (i == 0)
> > +			continue;
> > +		spin_lock_nest_lock(per_cpu_ptr(table->percpu_tb6_lock, i),
> > +			per_cpu_ptr(table->percpu_tb6_lock, 0));
> > +	}
> > +}
> 
> Your code assumes that cpu 0 is valid. 

This is unlikely not true especially for possible cpu map :)
> I would rather not hard code this knowledge.

Will fix it in next post

> Also this is not clear why you need the nested thing.

This is to avoid lockdep warnning. The locks have the same lockdep key, if we
don't use the nest lock annotation, lockdep assumes they are the same lock and
complain.

Thanks,
Shaohua
