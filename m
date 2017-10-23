From: Florian Westphal <fw@strlen.de>
Subject: Re: problem with rtnetlink 'reference' count
Date: Mon, 23 Oct 2017 18:37:44 +0200
Message-ID: <20171023163744.GB12422@breakpoint.cc>
References: <20171023142555.GF3165@worktop.lehotels.local>
 <20171023153200.GA12422@breakpoint.cc>
 <20171023162006.GH3165@worktop.lehotels.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>,
        David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Peter Zijlstra <peterz@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:44292 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751665AbdJWQiD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Oct 2017 12:38:03 -0400
Content-Disposition: inline
In-Reply-To: <20171023162006.GH3165@worktop.lehotels.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Peter Zijlstra <peterz@infradead.org> wrote:
> On Mon, Oct 23, 2017 at 05:32:00PM +0200, Florian Westphal wrote:
> 
> > >  1) it not in fact a refcount, so using refcount_t is silly
> > 
> > Your suggestion is...?
> 
> Normal atomic_t

Why?  refcount_t gives debug options to catch leaks/underflows,
atomic_t does not.

Is refcount_t only supposed to be used with dec_and_test patterns?

> To avoid the problem of te inc being observed late.
> 
> > However, this refcount_dec is misplaced anyway as it would need
> > to occur from nlcb->done() (the handler function gets stored in socket for
> > use by next recvmsg), so this change is indeed not helpful at all.
> > 
> > >  3) waiting with a schedule()/yield() loop is complete crap and subject
> > >     life-locks, imagine doing that rtnl_unregister_all() from a RT task.
> 
> > Alternatively we can of course sleep instead of schedule() but that
> > doesn't appear too appealing either (albeit it is a lot less intrusive).
> 
> That is much better than a yield loop.
> 
> > Any other idea?
> 
> This rtnetlink_rcv_msg() is called from softirq-context, right? Also,
> all that stuff happens with rcu_read_lock() held.

No, its called from process context.

I need to run now but plan to test and submit something like this:

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -263,7 +263,7 @@ void rtnl_unregister_all(int protocol)
 	synchronize_net();
 
 	while (refcount_read(&rtnl_msg_handlers_ref[protocol]) > 1)
-		schedule();
+		msleep(1);
 	kfree(handlers);
 }
 EXPORT_SYMBOL_GPL(rtnl_unregister_all);
@@ -4149,6 +4149,16 @@ static int rtnl_stats_dump(struct sk_buff *skb, struct netlink_callback *cb)
 	return skb->len;
 }
 
+
+static int rtnl_dumper_done(struct netlink_callback *cb)
+{
+	unsigned int family = (unsigned long)cb->data;
+
+	refcount_dec(&rtnl_msg_handlers_ref[family]);
+	smp_mb__after_atomic();
+	return 0;
+}
+
 /* Process one rtnetlink message. */
 
 static int rtnetlink_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh,
@@ -4207,6 +4217,7 @@ static int rtnetlink_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh,
 		}
 
 		refcount_inc(&rtnl_msg_handlers_ref[family]);
+		smp_mb__after_atomic();
 
 		if (type == RTM_GETLINK - RTM_BASE)
 			min_dump_alloc = rtnl_calcit(skb, nlh);
@@ -4217,11 +4228,12 @@ static int rtnetlink_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh,
 		{
 			struct netlink_dump_control c = {
 				.dump		= dumpit,
+				.done		= rtnl_dumper_done,
 				.min_dump_alloc	= min_dump_alloc,
+				.data		= (void *)(unsigned long)family,
 			};
 			err = netlink_dump_start(rtnl, skb, nlh, &c);
 		}
-		refcount_dec(&rtnl_msg_handlers_ref[family]);
 		return err;
 	}
 
