From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCHv3] netem: Segment GSO packets on enqueue
Date: Fri, 29 Apr 2016 11:09:26 -0700
Message-ID: <1461953366.5535.152.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1461692618-21333-1-git-send-email-nhorman@tuxdriver.com>
	 <1461951348-3920-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jamal Hadi Salim <jhs@mojatatu.com>,
	"David S. Miller" <davem@davemloft.net>,
	netem@lists.linux-foundation.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f51.google.com ([209.85.213.51]:33995 "EHLO
	mail-vk0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752436AbcD2SJf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Apr 2016 14:09:35 -0400
Received: by mail-vk0-f51.google.com with SMTP id m188so1556001vka.1
        for <netdev@vger.kernel.org>; Fri, 29 Apr 2016 11:09:30 -0700 (PDT)
In-Reply-To: <1461951348-3920-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-04-29 at 13:35 -0400, Neil Horman wrote:
> This was recently reported to me, and reproduced on the latest net kernel, when
> attempting to run netperf from a host that had a netem qdisc attached to the
> egress interface:
> 


>  /*
>   * Insert one skb into qdisc.
>   * Note: parent depends on return value to account for queue length.
> @@ -407,7 +426,11 @@ static int netem_enqueue(struct sk_buff *skb, struct Qdisc *sch)
>  	/* We don't fill cb now as skb_unshare() may invalidate it */
>  	struct netem_skb_cb *cb;
>  	struct sk_buff *skb2;
> +	struct sk_buff *segs = NULL;
> +	unsigned int len = 0, prev_len = qdisc_pkt_len(skb);
> +	int nb = 0;
>  	int count = 1;
> +	int rc = NET_XMIT_SUCCESS;
>  
>  	/* Random duplication */
>  	if (q->duplicate && q->duplicate >= get_crandom(&q->dup_cor))
> @@ -453,10 +476,22 @@ static int netem_enqueue(struct sk_buff *skb, struct Qdisc *sch)
>  	 * do it now in software before we mangle it.
>  	 */
>  	if (q->corrupt && q->corrupt >= get_crandom(&q->corrupt_cor)) {
> +		if (skb_is_gso(skb)) {
> +			segs = netem_segment(skb, sch);
> +			if (!segs)
> +				return NET_XMIT_DROP;
> +		} else
> +			segs = skb;
> +
> +		skb = segs;
> +		segs = segs->next;
> +
>  		if (!(skb = skb_unshare(skb, GFP_ATOMIC)) ||
>  		    (skb->ip_summed == CHECKSUM_PARTIAL &&
> -		     skb_checksum_help(skb)))
> -			return qdisc_drop(skb, sch);
> +		     skb_checksum_help(skb))) {
> +			rc = qdisc_drop(skb, sch);
> +			goto finish_segs;
> +		}
>  
>  		skb->data[prandom_u32() % skb_headlen(skb)] ^=
>  			1<<(prandom_u32() % 8);
> @@ -516,7 +551,26 @@ static int netem_enqueue(struct sk_buff *skb, struct Qdisc *sch)
>  		sch->qstats.requeues++;
>  	}
>  
> -	return NET_XMIT_SUCCESS;
> +finish_segs:
> +	if (segs) {
> +		while (segs) {
> +			skb2 = segs->next;
> +			segs->next = NULL;
> +			qdisc_skb_cb(segs)->pkt_len = segs->len;
> +			len += segs->len;

Wrong operation if packet is dropped by qdisc_enqueue() ?

I would use
 u32 last_len = segs->len;

> +			rc = qdisc_enqueue(segs, sch);
> +			if (rc != NET_XMIT_SUCCESS) {
> +				if (net_xmit_drop_count(rc))
> +					qdisc_qstats_drop(sch);
> +			} else

   } else {
        nb++;
        len += last_len;
   }

> +				nb++;
> +			segs = skb2;
> +		}
> +		sch->q.qlen += nb;
> +		if (nb > 1)
> +			qdisc_tree_reduce_backlog(sch, 1 - nb, prev_len - len);
> +	}
> +	return rc;

Seems you should return NET_XMIT_SUCCESS instead of status of last
segment ?

>  }

Thanks.
