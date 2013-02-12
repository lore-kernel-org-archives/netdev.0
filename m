From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [patch net-next v5 10/11] tbf: take into account gso skbs
Date: Tue, 12 Feb 2013 08:39:42 -0800
Message-ID: <1360687182.6884.5.camel@edumazet-glaptop>
References: <1360663929-1023-1-git-send-email-jiri@resnulli.us>
	 <1360663929-1023-11-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, edumazet@google.com,
	jhs@mojatatu.com, kuznet@ms2.inr.ac.ru, j.vimal@gmail.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f44.google.com ([209.85.210.44]:65121 "EHLO
	mail-da0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933389Ab3BLQjr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Feb 2013 11:39:47 -0500
Received: by mail-da0-f44.google.com with SMTP id z20so99871dae.31
        for <netdev@vger.kernel.org>; Tue, 12 Feb 2013 08:39:46 -0800 (PST)
In-Reply-To: <1360663929-1023-11-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-02-12 at 11:12 +0100, Jiri Pirko wrote:
> Ignore max_size check for gso skbs. This check made bigger packets
> incorrectly dropped. Remove this limitation for gso skbs.
> 
> Also for peaks, ignore mtu for gso skbs.
> 
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> ---
>  net/sched/sch_tbf.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
> index c8388f3..8973e93 100644
> --- a/net/sched/sch_tbf.c
> +++ b/net/sched/sch_tbf.c
> @@ -121,7 +121,7 @@ static int tbf_enqueue(struct sk_buff *skb, struct Qdisc *sch)
>  	struct tbf_sched_data *q = qdisc_priv(sch);
>  	int ret;
>  
> -	if (qdisc_pkt_len(skb) > q->max_size)
> +	if (qdisc_pkt_len(skb) > q->max_size && !skb_is_gso(skb))
>  		return qdisc_reshape_fail(skb, sch);
>  
>  	ret = qdisc_enqueue(skb, q->qdisc);
> @@ -165,7 +165,7 @@ static struct sk_buff *tbf_dequeue(struct Qdisc *sch)
>  
>  		if (q->peak_present) {
>  			ptoks = toks + q->ptokens;
> -			if (ptoks > q->mtu)
> +			if (ptoks > q->mtu && !skb_is_gso(skb))
>  				ptoks = q->mtu;
>  			ptoks -= (s64) psched_l2t_ns(&q->peak, len);
>  		}


I guess this part is wrong.

If we dont cap ptoks to q->mtu we allow bigger bursts.

Ideally we could re-segment the skb if psched_l2t_ns(&q->peak, len) is
bigger than q->mtu
