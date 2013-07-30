From: David Miller <davem@davemloft.net>
Subject: Re: [patch] net_sched: stack info leak in cbq_dump_wrr()
Date: Tue, 30 Jul 2013 00:18:08 -0700 (PDT)
Message-ID: <20130730.001808.1649128808672716753.davem@davemloft.net>
References: <1375128751.2075.58.camel@joe-AO722>
	<20130730065509.GB29160@mwanda>
	<1375168352.2075.110.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dan.carpenter@oracle.com, jhs@mojatatu.com, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58301 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753572Ab3G3HSJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jul 2013 03:18:09 -0400
In-Reply-To: <1375168352.2075.110.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Tue, 30 Jul 2013 00:12:32 -0700

> On Tue, 2013-07-30 at 09:55 +0300, Dan Carpenter wrote:
>> On Mon, Jul 29, 2013 at 01:12:31PM -0700, Joe Perches wrote:
>> > On Mon, 2013-07-29 at 23:01 +0300, Dan Carpenter wrote:
>> > > On Mon, Jul 29, 2013 at 12:44:32PM -0700, Joe Perches wrote:
>> > > > On Mon, 2013-07-29 at 22:36 +0300, Dan Carpenter wrote:
>> > > > > opt.__reserved isn't cleared so we leak a byte of stack information.
>> > > > []
>> > > > > diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
>> > > > []
>> > > > > @@ -1469,6 +1469,7 @@ static int cbq_dump_wrr(struct sk_buff *skb, struct cbq_class *cl)
>> > > > >  	opt.allot = cl->allot;
>> > > > >  	opt.priority = cl->priority + 1;
>> > > > >  	opt.cpriority = cl->cpriority + 1;
>> > > > > +	opt.__reserved = 0;
>> > > > >  	opt.weight = cl->weight;
>> > > > >  	if (nla_put(skb, TCA_CBQ_WRROPT, sizeof(opt), &opt))
>> > > > >  		goto nla_put_failure;
>> > > > 
>> > > > Alignment isn't guaranteed here so it'd
>> > > > probably be better with a memset.
>> > > > 
>> > > 
>> > > Hm...  Which arches would align it differently?
>> > 
>> > Hey Dan.
>> > 
>> > None so far as I know, but what difference does it make
>> > when it's a general correctness issue?
>> > 
>> 
>> Because I would assume if these aren't aligned the same way we have
>> far more serious problems than just this one case.  It would change
>> the user space API and break network protocols.
> 
> <shrug>
> 
> I didn't say it was necessary to be done here, I said it
> was a correctness issue.  I still believe that's true.
> 
> The nla_put here is by structure, the struct is unpacked,
> and it's local to the arch, not a particular endian type.
> 
> btw: to answer David's question, gcc 4.7 is smart enough
> to elide resetting values when the struct is initialized
> to 0 either with a memset or using {0}.

Ok, I've just commited the following, thanks everyone.

--------------------
>From a0db856a95a29efb1c23db55c02d9f0ff4f0db48 Mon Sep 17 00:00:00 2001
From: "David S. Miller" <davem@davemloft.net>
Date: Tue, 30 Jul 2013 00:16:21 -0700
Subject: [PATCH] net_sched: Fix stack info leak in cbq_dump_wrr().

Make sure the reserved fields, and padding (if any), are
fully initialized.

Based upon a patch by Dan Carpenter and feedback from
Joe Perches.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/sched/sch_cbq.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
index 71a5688..7a42c81 100644
--- a/net/sched/sch_cbq.c
+++ b/net/sched/sch_cbq.c
@@ -1465,6 +1465,7 @@ static int cbq_dump_wrr(struct sk_buff *skb, struct cbq_class *cl)
 	unsigned char *b = skb_tail_pointer(skb);
 	struct tc_cbq_wrropt opt;
 
+	memset(&opt, 0, sizeof(opt));
 	opt.flags = 0;
 	opt.allot = cl->allot;
 	opt.priority = cl->priority + 1;
-- 
1.7.11.7
