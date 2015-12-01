From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: size overflow in function qdisc_tree_decrease_qlen
 net/sched/sch_api.c
Date: Tue, 01 Dec 2015 08:34:20 -0800
Message-ID: <1448987660.2977.6.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20151201010005.GA23175@Fux-PC>
	 , <1448978807.25582.19.camel@edumazet-glaptop2.roam.corp.google.com>
	 , <1448979011.25582.21.camel@edumazet-glaptop2.roam.corp.google.com>
	 <565DC716.22673.2DBA261B@pageexec.freemail.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Daniele Fucini <dfucini@gmail.com>,
	Cong Wang <cwang@twopensource.com>,
	netdev <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	David Miller <davem@davemloft.net>, spender@grsecurity.net,
	re.emese@gmail.com
To: pageexec@freemail.hu
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:34379 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755540AbbLAQeX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2015 11:34:23 -0500
Received: by padhx2 with SMTP id hx2so9988792pad.1
        for <netdev@vger.kernel.org>; Tue, 01 Dec 2015 08:34:22 -0800 (PST)
In-Reply-To: <565DC716.22673.2DBA261B@pageexec.freemail.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-12-01 at 17:13 +0100, PaX Team wrote:
> On 1 Dec 2015 at 6:10, Eric Dumazet wrote:
> 
> > On Tue, 2015-12-01 at 06:06 -0800, Eric Dumazet wrote:
> > > On Tue, 2015-12-01 at 12:19 +0100, Daniele Fucini wrote:
> > > > Thanks for the reply. Here's the output of `tc qdisc show`:
> > > > https://gist.github.com/1847102c8fe08f63e9e7
> > 
> > > Hmm... I do not think we ever took care of MQ in
> > > qdisc_tree_decrease_qlen()
> > 
> > This looks like a false positive, because MQ recomputes backlog/qlen at
> > the time (stats) dumps are requested.
> > 
> > I would say there is no bug.
> 
> is it correct for sk_buff_head.qlen to underflow in general
> or just in this particular sched code? (we can exclude overflow
> checking for either case but obviously would like to retain as
> much coverage as possible)

We do not particularly care on the qlen value for MQ, although we simply
should avoid doing anything.

Otherwise we might report slightly wrong qlen values while doing "tc -s
qdisc show" if the qdisc_tree_decrease_qlen() happens right after we
computed the folded values in mq_dump()

Please try the patch I sent. I am pretty sure it should be the right
fix.

I will submit it formally once you tell me it is fixing the issue you
reported.


diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index f43c8f33f09e..72f2c1dfdcde 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -759,6 +759,8 @@ void qdisc_tree_decrease_qlen(struct Qdisc *sch, unsigned int n)
 			WARN_ON(parentid != TC_H_ROOT);
 			return;
 		}
+		if (sch->flags & TCQ_F_MQROOT)
+			return;
 		cops = sch->ops->cl_ops;
 		if (cops->qlen_notify) {
 			cl = cops->get(sch, parentid);
