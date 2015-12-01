From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: size overflow in function qdisc_tree_decrease_qlen
 net/sched/sch_api.c
Date: Tue, 01 Dec 2015 06:10:11 -0800
Message-ID: <1448979011.25582.21.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20151201010005.GA23175@Fux-PC>
	 <CAHA+R7NdbMgfWpdCoP8peXT3zBX1=B_HWhsykjcT3QO=Gk-9aQ@mail.gmail.com>
	 <20151201111943.GA4036@Fux-PC>
	 <1448978807.25582.19.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <cwang@twopensource.com>,
	netdev <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	David Miller <davem@davemloft.net>, spender@grsecurity.net,
	pageexec@freemail.hu, re.emese@gmail.com
To: Daniele Fucini <dfucini@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:36441 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755253AbbLAOKO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2015 09:10:14 -0500
Received: by pacdm15 with SMTP id dm15so6402667pac.3
        for <netdev@vger.kernel.org>; Tue, 01 Dec 2015 06:10:13 -0800 (PST)
In-Reply-To: <1448978807.25582.19.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-12-01 at 06:06 -0800, Eric Dumazet wrote:
> On Tue, 2015-12-01 at 12:19 +0100, Daniele Fucini wrote:
> > Thanks for the reply. Here's the output of `tc qdisc show`:
> > https://gist.github.com/1847102c8fe08f63e9e7

> Hmm... I do not think we ever took care of MQ in
> qdisc_tree_decrease_qlen()

This looks like a false positive, because MQ recomputes backlog/qlen at
the time (stats) dumps are requested.

I would say there is no bug.

static int mq_dump(struct Qdisc *sch, struct sk_buff *skb)
{
        struct net_device *dev = qdisc_dev(sch);
        struct Qdisc *qdisc;
        unsigned int ntx;

        sch->q.qlen = 0;
        memset(&sch->bstats, 0, sizeof(sch->bstats));
        memset(&sch->qstats, 0, sizeof(sch->qstats));

        for (ntx = 0; ntx < dev->num_tx_queues; ntx++) {
                qdisc = netdev_get_tx_queue(dev, ntx)->qdisc_sleeping;
                spin_lock_bh(qdisc_lock(qdisc));
                sch->q.qlen             += qdisc->q.qlen;
                sch->bstats.bytes       += qdisc->bstats.bytes;
                sch->bstats.packets     += qdisc->bstats.packets;
                sch->qstats.backlog     += qdisc->qstats.backlog;
                sch->qstats.drops       += qdisc->qstats.drops;
                sch->qstats.requeues    += qdisc->qstats.requeues;
                sch->qstats.overlimits  += qdisc->qstats.overlimits;
                spin_unlock_bh(qdisc_lock(qdisc));
        }
        return 0;
}
