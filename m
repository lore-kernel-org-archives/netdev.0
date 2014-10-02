From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH V6 2/2] qdisc: dequeue bulking also pickup
 GSO/TSO packets
Date: Thu, 02 Oct 2014 07:35:28 -0700
Message-ID: <1412260528.16704.96.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20141001203345.3321.99675.stgit@dragon>
	 <20141001203604.3321.91746.stgit@dragon>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Florian Westphal <fw@strlen.de>,
	Daniel Borkmann <dborkman@redhat.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Dave Taht <dave.taht@gmail.com>, toke@toke.dk
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:59844 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751448AbaJBOfa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Oct 2014 10:35:30 -0400
Received: by mail-pa0-f53.google.com with SMTP id kq14so2542693pab.26
        for <netdev@vger.kernel.org>; Thu, 02 Oct 2014 07:35:30 -0700 (PDT)
In-Reply-To: <20141001203604.3321.91746.stgit@dragon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-10-01 at 22:36 +0200, Jesper Dangaard Brouer wrote:
> The TSO and GSO segmented packets already benefit from bulking
> on their own.
> 

> 
> Signed-off-by: Florian Westphal <fw@strlen.de>
> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> ---
> 
>  net/sched/sch_generic.c |   12 +++---------
>  1 files changed, 3 insertions(+), 9 deletions(-)
> 
> diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
> index c2e87e6..797ebef 100644
> --- a/net/sched/sch_generic.c
> +++ b/net/sched/sch_generic.c
> @@ -63,10 +63,6 @@ static struct sk_buff *try_bulk_dequeue_skb(struct Qdisc *q,
>  	struct sk_buff *skb, *tail_skb = head_skb;
>  
>  	while (bytelimit > 0) {
> -		/* For now, don't bulk dequeue GSO (or GSO segmented) pkts */
> -		if (tail_skb->next || skb_is_gso(tail_skb))
> -			break;
> -
>  		skb = q->dequeue(q);
>  		if (!skb)
>  			break;
> @@ -76,11 +72,9 @@ static struct sk_buff *try_bulk_dequeue_skb(struct Qdisc *q,
>  		if (!skb)
>  			break;
>  
> -		/* "skb" can be a skb list after validate call above
> -		 * (GSO segmented), but it is okay to append it to
> -		 * current tail_skb->next, because next round will exit
> -		 * in-case "tail_skb->next" is a skb list.
> -		 */
> +		while (tail_skb->next) /* GSO list goto tail */
> +			tail_skb = tail_skb->next;
> +
>  		tail_skb->next = skb;
>  		tail_skb = skb;

Thanks a lot guys. I am testing this patch set today.
