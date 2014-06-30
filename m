From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: Performance fix for process_backlog
Date: Sun, 29 Jun 2014 23:11:03 -0700
Message-ID: <1404108663.15139.40.camel@edumazet-glaptop2.roam.corp.google.com>
References: <alpine.DEB.2.02.1406291915560.4914@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f50.google.com ([74.125.82.50]:64002 "EHLO
	mail-wg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752510AbaF3GLI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jun 2014 02:11:08 -0400
Received: by mail-wg0-f50.google.com with SMTP id m15so7641552wgh.9
        for <netdev@vger.kernel.org>; Sun, 29 Jun 2014 23:11:07 -0700 (PDT)
In-Reply-To: <alpine.DEB.2.02.1406291915560.4914@tomh.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2014-06-29 at 19:21 -0700, Tom Herbert wrote:
> In process_backlog the input_pkt_queue is only checked once for new
> packets and quota is artificially reduced to reflect precisely the
> number of packets on the input_pkt_queue so that the loop exits
> appropriately.
> 
> This patch changes the behavior to be more straightforward and
> less convoluted. Packets are processed until either the quota
> is met or there are no more packets to process.

This is the same condition than before. You only changed how its done.

> 
> This patch seems to provide a small, but noticeable performance
> improvement.

I would prefer you explain why this gets an improvement, because few
people really understands this.

The reason you might get an improvement here is because one test is
removed, and this test was fooling cpu branch predictor.

perf stat ./super_netperf ... would tell us this better.

> 
> Performance data using super_netperf TCP_RR with 200 flows:
> 
> Before fix:
> 
> 88.06% CPU utilization
> 125/190/309 90/95/99% latencies
> 1.46808e+06 tps
> 
> With fix:
> 
> 87.73% CPU utilization
> 122/183/296 90/95/99% latencies
> 1.4921e+06 tps
> 
> Signed-off-by: Tom Herbert <therbert@google.com>
> ---
>  net/core/dev.c | 23 +++++++++++------------
>  1 file changed, 11 insertions(+), 12 deletions(-)
> 
> diff --git a/net/core/dev.c b/net/core/dev.c
> index a04b12f..136ce3e 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -4227,9 +4227,8 @@ static int process_backlog(struct napi_struct *napi, int quota)
>  #endif
>  	napi->weight = weight_p;
>  	local_irq_disable();
> -	while (work < quota) {
> +	while (1) {
>  		struct sk_buff *skb;
> -		unsigned int qlen;
>  
>  		while ((skb = __skb_dequeue(&sd->process_queue))) {
>  			local_irq_enable();
> @@ -4243,24 +4242,24 @@ static int process_backlog(struct napi_struct *napi, int quota)
>  		}
>  
>  		rps_lock(sd);
> -		qlen = skb_queue_len(&sd->input_pkt_queue);
> -		if (qlen)
> -			skb_queue_splice_tail_init(&sd->input_pkt_queue,
> -						   &sd->process_queue);
> -
> -		if (qlen < quota - work) {
> +		if (skb_queue_empty(&sd->input_pkt_queue)) {
>  			/*
>  			 * Inline a custom version of __napi_complete().
>  			 * only current cpu owns and manipulates this napi,
> -			 * and NAPI_STATE_SCHED is the only possible flag set on backlog.
> -			 * we can use a plain write instead of clear_bit(),
> +			 * and NAPI_STATE_SCHED is the only possible flag set
> +			 * on backlog.
> +			 * We can use a plain write instead of clear_bit(),
>  			 * and we dont need an smp_mb() memory barrier.
>  			 */
>  			list_del(&napi->poll_list);
>  			napi->state = 0;
> +			rps_unlock(sd);
> +
> +			break;
> +		}

Since your first block ends with a break; you do not need an 'else'

>  else

Then you can remove one tab on this,

> +			skb_queue_splice_tail_init(&sd->input_pkt_queue,
> +						   &sd->process_queue);

Alternatively you should have :
 if (A) {
 	...
 } else {
        ...
 }


>  
> -			quota = work + qlen;
> -		}
>  		rps_unlock(sd);
>  	}
>  	local_irq_enable();
