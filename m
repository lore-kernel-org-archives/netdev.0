From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net v2] net: sched: do not requeue a NULL skb
Date: Mon, 11 Apr 2016 06:23:01 -0700
Message-ID: <1460380981.6473.544.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1460355869-13539-1-git-send-email-larper@axis.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com,
	linux-kernel@vger.kernel.org, xiyou.wangcong@gmail.com,
	Lars Persson <larper@axis.com>
To: Lars Persson <lars.persson@axis.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1460355869-13539-1-git-send-email-larper@axis.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2016-04-11 at 08:24 +0200, Lars Persson wrote:
> A failure in validate_xmit_skb_list() triggered an unconditional call
> to dev_requeue_skb with skb=NULL. This slowly grows the queue
> discipline's qlen count until all traffic through the queue stops.
> 
> By introducing a NULL check in dev_requeue_skb it was also necessary
> to make the __netif_schedule call conditional to avoid scheduling an
> empty queue.
> 
> Fixes: 55a93b3ea780 ("qdisc: validate skb without holding lock")
> Signed-off-by: Lars Persson <larper@axis.com>
> ---
>  net/sched/sch_generic.c | 11 +++++++----
>  1 file changed, 7 insertions(+), 4 deletions(-)
> 
> diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
> index f18c350..4e6a79c 100644
> --- a/net/sched/sch_generic.c
> +++ b/net/sched/sch_generic.c
> @@ -47,10 +47,13 @@ EXPORT_SYMBOL(default_qdisc_ops);
>  
>  static inline int dev_requeue_skb(struct sk_buff *skb, struct Qdisc *q)
>  {
> -	q->gso_skb = skb;
> -	q->qstats.requeues++;
> -	q->q.qlen++;	/* it's still part of the queue */
> -	__netif_schedule(q);
> +	if (skb) {
> +		q->gso_skb = skb;
> +		q->qstats.requeues++;
> +		q->q.qlen++;	/* it's still part of the queue */
> +	}
> +	if (qdisc_qlen(q))
> +		__netif_schedule(q);
>  
>  	return 0;
>  }


Please always CC patch author when fixing a bug.

Why adding the if (qdisc_qlen(q)) extra test ?

This seems unrelated to the bug fix, and probably should be part of a
second patch targeting net-next tree.

Also please add a likely() clause

if (likely(skb)) {
        q->gso_skb = skb;
        q->qstats.requeues++;
        q->q.qlen++;    /* it's still part of the queue */
        __netif_schedule(q);
}

Thanks !
