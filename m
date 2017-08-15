From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net_sched/sfq: update hierarchical backlog when drop
 packet
Date: Tue, 15 Aug 2017 07:09:39 -0700
Message-ID: <1502806179.4936.76.camel@edumazet-glaptop3.roam.corp.google.com>
References: <150280422406.717624.15125218636935056461.stgit@buzz>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:37407 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751517AbdHOOJm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2017 10:09:42 -0400
Received: by mail-pg0-f67.google.com with SMTP id 83so1646929pgb.4
        for <netdev@vger.kernel.org>; Tue, 15 Aug 2017 07:09:42 -0700 (PDT)
In-Reply-To: <150280422406.717624.15125218636935056461.stgit@buzz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-08-15 at 16:37 +0300, Konstantin Khlebnikov wrote:
> When sfq_enqueue() drops head packet or packet from another queue it
> have to update backlog at upper qdiscs too.
> 
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
> Fixes: 2ccccf5fb43f ("net_sched: update hierarchical backlog too")
> ---
>  net/sched/sch_sfq.c |    5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
> 
> diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
> index f80ea2cc5f1f..82469ef9655e 100644
> --- a/net/sched/sch_sfq.c
> +++ b/net/sched/sch_sfq.c
> @@ -437,6 +437,7 @@ sfq_enqueue(struct sk_buff *skb, struct Qdisc *sch, struct sk_buff **to_free)
>  		qdisc_drop(head, sch, to_free);
>  
>  		slot_queue_add(slot, skb);
> +		qdisc_tree_reduce_backlog(sch, 0, delta);
>  		return NET_XMIT_CN;
>  	}
>  
> @@ -468,8 +469,10 @@ sfq_enqueue(struct sk_buff *skb, struct Qdisc *sch, struct sk_buff **to_free)
>  	/* Return Congestion Notification only if we dropped a packet
>  	 * from this flow.
>  	 */
> -	if (qlen != slot->qlen)
> +	if (qlen != slot->qlen) {
> +		qdisc_tree_reduce_backlog(sch, 0, dropped - qdisc_pkt_len(skb));
>  		return NET_XMIT_CN;
> +	}
>  
>  	/* As we dropped a packet, better let upper stack know this */
>  	qdisc_tree_reduce_backlog(sch, 1, dropped);
> 

Are you sure you have tested this patch ?
