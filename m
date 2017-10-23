From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: problem with rtnetlink 'reference' count
Date: Mon, 23 Oct 2017 18:20:06 +0200
Message-ID: <20171023162006.GH3165@worktop.lehotels.local>
References: <20171023142555.GF3165@worktop.lehotels.local>
 <20171023153200.GA12422@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:40249 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751548AbdJWQUK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Oct 2017 12:20:10 -0400
Content-Disposition: inline
In-Reply-To: <20171023153200.GA12422@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 23, 2017 at 05:32:00PM +0200, Florian Westphal wrote:

> >  1) it not in fact a refcount, so using refcount_t is silly
> 
> Your suggestion is...?

Normal atomic_t

> >  2) there is a distinct lack of memory barriers, so we can easily
> >     observe the decrement while the msg_handler is still in progress.
> 
> I guess you mean it needs:
> 
> +	smp_mb__before_atomic();
> 	refcount_dec(&rtnl_msg_handlers_ref[family]);
> ?

Yes, but also:

	atomic_inc();
	smp_mb__after_atomic();

To avoid the problem of te inc being observed late.

> However, this refcount_dec is misplaced anyway as it would need
> to occur from nlcb->done() (the handler function gets stored in socket for
> use by next recvmsg), so this change is indeed not helpful at all.
> 
> >  3) waiting with a schedule()/yield() loop is complete crap and subject
> >     life-locks, imagine doing that rtnl_unregister_all() from a RT task.

> Alternatively we can of course sleep instead of schedule() but that
> doesn't appear too appealing either (albeit it is a lot less intrusive).

That is much better than a yield loop.

> Any other idea?

This rtnetlink_rcv_msg() is called from softirq-context, right? Also,
all that stuff happens with rcu_read_lock() held.

So why isn't that synchronize_net() call sufficient? You first clear
rtnl_msg_handlers[protocol], and then you do synchronize_net() which
will wait for all concurrent softirq handlers to complete. Which, if
rtnetlink_rcv_msg() is called from softir, guarantees nobody still uses
it.


Also, if that is all softirq, you should maybe use rcu_read_lock_bh(),
alternatively you should use synchronize_rcu(), as is its a bit
inconsistent.
