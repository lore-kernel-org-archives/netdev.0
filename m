From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: size overflow in function qdisc_tree_decrease_qlen
 net/sched/sch_api.c
Date: Tue, 01 Dec 2015 14:33:05 -0800
Message-ID: <1449009185.32764.5.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20151201010005.GA23175@Fux-PC>
	 <1448978807.25582.19.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1448979011.25582.21.camel@edumazet-glaptop2.roam.corp.google.com>
	 <565DC716.22673.2DBA261B@pageexec.freemail.hu>
	 <1448987660.2977.6.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAHA+R7NiYjhE5dY7HPkWuoTA5WMqF3zPyCFk5i3LYTUrYD7gYA@mail.gmail.com>
	 <1448996964.16994.2.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAHA+R7NRsKrdVAY7_Wyvq1COAGjjkGZdJxZLvDRGS7gaN3iQvQ@mail.gmail.com>
	 <1449000371.16994.14.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: pageexec@freemail.hu, Daniele Fucini <dfucini@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	David Miller <davem@davemloft.net>, spender@grsecurity.net,
	re.emese@gmail.com
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:34691 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756954AbbLAWdH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2015 17:33:07 -0500
Received: by padhx2 with SMTP id hx2so18719945pad.1
        for <netdev@vger.kernel.org>; Tue, 01 Dec 2015 14:33:06 -0800 (PST)
In-Reply-To: <1449000371.16994.14.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-12-01 at 12:06 -0800, Eric Dumazet wrote:
> On Tue, 2015-12-01 at 11:17 -0800, Cong Wang wrote:
> > On Tue, Dec 1, 2015 at 11:09 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > > On Tue, 2015-12-01 at 10:43 -0800, Cong Wang wrote:
> > >
> > >> This smells hacky... Another way to fix this is to hold the qdisc tree
> > >> lock in mq_dump(), since it is not a hot path (comparing with
> > >> enqueue/dequeue)?
> > >
> > > Really ? Which qdisc tree lock will protect you exactly ???
> > >
> > > Whole point of MQ is that each TX queue has its own lock.
> > >
> > > So multiple cpus can call qdisc_tree_decrease_qlen() at the same time,
> > > holding their own lock.
> > >
> > > Clearly modifying mq 'data' is wrong.
> > 
> > Ah, yeah, but mq _seems_ also the only one who modifies sch->q.qlen
> > in ->dump(), which is the root cause of this bug. I am wondering if it should
> > just compute the qlen and return it without modifying sch->q.qlen.
> 
> Sure, but then we still would get PAX underflows warnings ...
> 
> Also need to take care of sch->qstats.drops += count;
> 
> Also that would require a change of ->dump() api, since tc_fill_qdisc()
> does :
> 
> if (q->ops->dump && q->ops->dump(q, skb) < 0)
>     goto nla_put_failure;
> qlen = q->q.qlen;
> 
> Not sure it is worth the pain, changing signature of all ->dump()
> handlers...
> 
> 
> What about adding TCQ_F_NOPARENT and then :
> 
> Note : Seems to be more invasive patch for net tree (need to properly
> set TCQ_F_NOPARENT)


Hmm... it looks like we have a much more serious bug :

qdisc_lookup() calls qdisc_match_from_root(dev->qdisc, handle) without
proper lock being held, so we might actually crash the host,
if qdisc_tree_decrease_qlen() happens at the time qdiscs are changed. 

qdisc_tree_decrease_qlen() needs serious care :(

Damned.
