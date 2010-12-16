From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH net-next-2.6] net_sched: sch_sfq: add backlog info in
	sfq_dump_class_stats()
Date: Thu, 16 Dec 2010 08:16:21 +0000
Message-ID: <20101216081621.GA7338@ff.dom.local>
References: <1292437116.3427.386.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f43.google.com ([209.85.161.43]:36760 "EHLO
	mail-fx0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751355Ab0LPIQ1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Dec 2010 03:16:27 -0500
Received: by fxm18 with SMTP id 18so2993902fxm.2
        for <netdev@vger.kernel.org>; Thu, 16 Dec 2010 00:16:26 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1292437116.3427.386.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2010-12-15 19:18, Eric Dumazet wrote:
> We currently return for each active SFQ slot the number of packets in
> queue. We can also give number of bytes accounted for these packets.
> 
> tc -s class show dev ifb0
> 
> Before patch :
> 
> class sfq 11:3d9 parent 11: 
>  (dropped 0, overlimits 0 requeues 0) 
>  backlog 0b 3p requeues 0 
>  allot 1266 
> 
> After patch :
> 
> class sfq 11:3e4 parent 11: 
>  (dropped 0, overlimits 0 requeues 0) 
>  backlog 4380b 3p requeues 0 
>  allot 1212 
> 
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---
>  net/sched/sch_sfq.c |    7 ++++++-
>  1 file changed, 6 insertions(+), 1 deletion(-)
> 
> diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
> index 3cf478d..cb331de 100644
> --- a/net/sched/sch_sfq.c
> +++ b/net/sched/sch_sfq.c
> @@ -548,8 +548,13 @@ static int sfq_dump_class_stats(struct Qdisc *sch, unsigned long cl,
>  {
>  	struct sfq_sched_data *q = qdisc_priv(sch);
>  	sfq_index idx = q->ht[cl-1];
> -	struct gnet_stats_queue qs = { .qlen = q->qs[idx].qlen };
> +	struct sk_buff_head *list = &q->qs[idx];
> +	struct gnet_stats_queue qs = { .qlen = list->qlen };
>  	struct tc_sfq_xstats xstats = { .allot = q->allot[idx] };
> +	struct sk_buff *skb;
> +
> +	skb_queue_walk(list, skb)
> +		qs.backlog += qdisc_pkt_len(skb);

I don't think you can walk this list without the qdisc lock.

Jarek P.
