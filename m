From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net_sched: increase drop count when packets
 are dropped
Date: Tue, 13 May 2014 06:49:19 -0700
Message-ID: <1399988959.7973.46.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1399974163-8788-1-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vtlam@google.com, nanditad@google.com,
	davem@davemloft.net
To: Yang Yingliang <yangyingliang@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:60587 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933421AbaEMNtX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 May 2014 09:49:23 -0400
Received: by mail-pa0-f46.google.com with SMTP id kq14so307141pab.33
        for <netdev@vger.kernel.org>; Tue, 13 May 2014 06:49:22 -0700 (PDT)
In-Reply-To: <1399974163-8788-1-git-send-email-yangyingliang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-05-13 at 17:42 +0800, Yang Yingliang wrote:
> When packets are dropped because of overlimit, the drop count
> should be increased. Replace kfree_skb() with qdisc_drop() for
> increasing drop count.
> 
> Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>
> ---
>  net/sched/sch_fq.c       | 2 +-
>  net/sched/sch_fq_codel.c | 3 ++-
>  net/sched/sch_hhf.c      | 3 ++-
>  3 files changed, 5 insertions(+), 3 deletions(-)
> 
> diff --git a/net/sched/sch_fq.c b/net/sched/sch_fq.c
> index 23c682b42f99..958ef7d4b825 100644
> --- a/net/sched/sch_fq.c
> +++ b/net/sched/sch_fq.c
> @@ -714,7 +714,7 @@ static int fq_change(struct Qdisc *sch, struct nlattr *opt)
>  
>  		if (!skb)
>  			break;
> -		kfree_skb(skb);
> +		qdisc_drop(skb, sch);
>  		drop_count++;
>  	}
>  	qdisc_tree_decrease_qlen(sch, drop_count);
> diff --git a/net/sched/sch_fq_codel.c b/net/sched/sch_fq_codel.c
> index 0bf432c782c1..bcfe4594470f 100644
> --- a/net/sched/sch_fq_codel.c
> +++ b/net/sched/sch_fq_codel.c
> @@ -344,7 +344,8 @@ static int fq_codel_change(struct Qdisc *sch, struct nlattr *opt)
>  	while (sch->q.qlen > sch->limit) {
>  		struct sk_buff *skb = fq_codel_dequeue(sch);
>  
> -		kfree_skb(skb);
> +		qdisc_drop(skb, sch);
> +		q->drop_overlimit++;
>  		q->cstats.drop_count++;
>  	}

Could you please refrain from adding random stuff in packet schedulers ?

overlimit has a special meaning for HTB like qdisc, having a shapers.

fq_codel or hhf do not shape, there is no reason to increment
'overlimit' when they _drop_ a packet.

Example of current behavior for HTB :

class htb 1:1 root rate 40Gbit ceil 40Gbit burst 625Kb cburst 625Kb 
 Sent 8222081942286 bytes 2240972916 pkt (dropped 0, overlimits 43819454 requeues 0) 
 rate 0bit 0pps backlog 0b 0p requeues 0 
 lended: 1207852666 borrowed: 0 giants: 0
 tokens: 1999 ctokens: 1999
