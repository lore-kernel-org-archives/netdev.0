From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net_sched: increase drop count when packets
 are dropped
Date: Fri, 16 May 2014 06:22:05 -0700
Message-ID: <1400246525.7973.168.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1399974163-8788-1-git-send-email-yangyingliang@huawei.com>
	 <1399988959.7973.46.camel@edumazet-glaptop2.roam.corp.google.com>
	 <5375D54C.4040108@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: vtlam@google.com, nanditad@google.com, davem@davemloft.net,
	netdev <netdev@vger.kernel.org>
To: Yang Yingliang <yangyingliang@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f51.google.com ([209.85.160.51]:61016 "EHLO
	mail-pb0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752052AbaEPNWI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 May 2014 09:22:08 -0400
Received: by mail-pb0-f51.google.com with SMTP id ma3so2581118pbc.24
        for <netdev@vger.kernel.org>; Fri, 16 May 2014 06:22:08 -0700 (PDT)
In-Reply-To: <5375D54C.4040108@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-05-16 at 17:07 +0800, Yang Yingliang wrote:
> On 2014/5/13 21:49, Eric Dumazet wrote:
> > On Tue, 2014-05-13 at 17:42 +0800, Yang Yingliang wrote:
> >> When packets are dropped because of overlimit, the drop count
> >> should be increased. Replace kfree_skb() with qdisc_drop() for
> >> increasing drop count.
> >>
> >> Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>
> >> ---
> >>  net/sched/sch_fq.c       | 2 +-
> >>  net/sched/sch_fq_codel.c | 3 ++-
> >>  net/sched/sch_hhf.c      | 3 ++-
> >>  3 files changed, 5 insertions(+), 3 deletions(-)
> >>
> >> diff --git a/net/sched/sch_fq.c b/net/sched/sch_fq.c
> >> index 23c682b42f99..958ef7d4b825 100644
> >> --- a/net/sched/sch_fq.c
> >> +++ b/net/sched/sch_fq.c
> >> @@ -714,7 +714,7 @@ static int fq_change(struct Qdisc *sch, struct nlattr *opt)
> >>  
> >>  		if (!skb)
> >>  			break;
> >> -		kfree_skb(skb);
> >> +		qdisc_drop(skb, sch);
> >>  		drop_count++;
> >>  	}
> >>  	qdisc_tree_decrease_qlen(sch, drop_count);
> >> diff --git a/net/sched/sch_fq_codel.c b/net/sched/sch_fq_codel.c
> >> index 0bf432c782c1..bcfe4594470f 100644
> >> --- a/net/sched/sch_fq_codel.c
> >> +++ b/net/sched/sch_fq_codel.c
> >> @@ -344,7 +344,8 @@ static int fq_codel_change(struct Qdisc *sch, struct nlattr *opt)
> >>  	while (sch->q.qlen > sch->limit) {
> >>  		struct sk_buff *skb = fq_codel_dequeue(sch);
> >>  
> >> -		kfree_skb(skb);
> >> +		qdisc_drop(skb, sch);
> >> +		q->drop_overlimit++;
> >>  		q->cstats.drop_count++;
> >>  	}
> > 
> > Could you please refrain from adding random stuff in packet schedulers ?
> OK :)
> 
> > 
> > overlimit has a special meaning for HTB like qdisc, having a shapers.
> I don't really catch up with you here. What's special meaning ?
> 
> > 
> > fq_codel or hhf do not shape, there is no reason to increment
> > 'overlimit' when they _drop_ a packet.
> 
> Do you mean 'drop_overlimit' or 'overlimit' ?
> 
> fq_codel has both 'overlimits' and 'drop_overlimit' :
> 
> qdisc fq_codel 1: dev eth4 root refcnt 2 limit 10240p flows 1024 quantum 1514 target 5.0ms interval 100.0ms ecn 
>  Sent 834 bytes 5 pkt (dropped 0, overlimits 0 requeues 0) 
>  backlog 0b 0p requeues 0 
>   maxpacket 256 drop_overlimit 0 new_flow_count 0 ecn_mark 0
>   new_flows_len 0 old_flows_len 0
> 
> Could you please explain more explicitly ?


Okay fair enough.

Read again the changelog you gave.

Where is this change mentioned or explained properly ?

You give a changelog, then you insert a 'random' change in the patch,
not mentioned in the changelog. How I am supposed to be cool ?

Instead of cooking a clean patch, you have this tendency of putting
'random' things and expect me/us to carefully check you didn't add a
bug. But you know what, its exhausting,

The quality of your patches dropped considerably in the last
submissions.

I ask you to test your patches and prove you don't break things, because
I do not trust you anymore.

I am going to ask you to give detailed Tested: sections for your next
patches.
