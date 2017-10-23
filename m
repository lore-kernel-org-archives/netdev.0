From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: problem with rtnetlink 'reference' count
Date: Mon, 23 Oct 2017 20:31:58 +0200
Message-ID: <20171023183158.GI3165@worktop.lehotels.local>
References: <20171023142555.GF3165@worktop.lehotels.local>
 <20171023153200.GA12422@breakpoint.cc>
 <20171023162006.GH3165@worktop.lehotels.local>
 <20171023163744.GB12422@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:48037 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751388AbdJWScF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Oct 2017 14:32:05 -0400
Content-Disposition: inline
In-Reply-To: <20171023163744.GB12422@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 23, 2017 at 06:37:44PM +0200, Florian Westphal wrote:

> Is refcount_t only supposed to be used with dec_and_test patterns?

Yes, for reference counting objects.

> > This rtnetlink_rcv_msg() is called from softirq-context, right? Also,
> > all that stuff happens with rcu_read_lock() held.
> 
> No, its called from process context.

OK, so then why not do something like so?


---
 net/core/rtnetlink.c | 21 ++++++++++-----------
 1 file changed, 10 insertions(+), 11 deletions(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index d4bcdcc68e92..473cabd0a551 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -128,7 +128,6 @@ bool lockdep_rtnl_is_held(void)
 #endif /* #ifdef CONFIG_PROVE_LOCKING */
 
 static struct rtnl_link __rcu *rtnl_msg_handlers[RTNL_FAMILY_MAX + 1];
-static refcount_t rtnl_msg_handlers_ref[RTNL_FAMILY_MAX + 1];
 
 static inline int rtm_msgindex(int msgtype)
 {
@@ -260,10 +259,18 @@ void rtnl_unregister_all(int protocol)
 	RCU_INIT_POINTER(rtnl_msg_handlers[protocol], NULL);
 	rtnl_unlock();
 
+	/*
+	 * XXX explain what this is for...
+	 */
 	synchronize_net();
 
-	while (refcount_read(&rtnl_msg_handlers_ref[protocol]) > 1)
-		schedule();
+	/*
+	 * This serializes against the rcu_read_lock() section in
+	 * rtnetlink_rcv_msg() such that after this, all prior instances have
+	 * completed and future instances must observe the NULL written above.
+	 */
+	synchronize_rcu();
+
 	kfree(handlers);
 }
 EXPORT_SYMBOL_GPL(rtnl_unregister_all);
@@ -4203,8 +4210,6 @@ static int rtnetlink_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh,
 				goto err_unlock;
 		}
 
-		refcount_inc(&rtnl_msg_handlers_ref[family]);
-
 		if (type == RTM_GETLINK - RTM_BASE)
 			min_dump_alloc = rtnl_calcit(skb, nlh);
 
@@ -4218,7 +4223,6 @@ static int rtnetlink_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh,
 			};
 			err = netlink_dump_start(rtnl, skb, nlh, &c);
 		}
-		refcount_dec(&rtnl_msg_handlers_ref[family]);
 		return err;
 	}
 
@@ -4230,12 +4234,10 @@ static int rtnetlink_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh,
 
 	flags = READ_ONCE(handlers[type].flags);
 	if (flags & RTNL_FLAG_DOIT_UNLOCKED) {
-		refcount_inc(&rtnl_msg_handlers_ref[family]);
 		doit = READ_ONCE(handlers[type].doit);
 		rcu_read_unlock();
 		if (doit)
 			err = doit(skb, nlh, extack);
-		refcount_dec(&rtnl_msg_handlers_ref[family]);
 		return err;
 	}
 
@@ -4333,9 +4335,6 @@ void __init rtnetlink_init(void)
 {
 	int i;
 
-	for (i = 0; i < ARRAY_SIZE(rtnl_msg_handlers_ref); i++)
-		refcount_set(&rtnl_msg_handlers_ref[i], 1);
-
 	if (register_pernet_subsys(&rtnetlink_net_ops))
 		panic("rtnetlink_init: cannot initialize rtnetlink\n");
 
