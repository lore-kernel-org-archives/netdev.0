From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: core: Fix race by  protecting process_queues at
 CPU hotplug
Date: Thu, 15 Jan 2015 11:28:15 -0800
Message-ID: <1421350095.11734.88.camel@edumazet-glaptop2.roam.corp.google.com>
References: <75547b88b7e2d15b35339a6321c3a929.squirrel@www.codeaurora.org>
	 <1421305282.11734.38.camel@edumazet-glaptop2.roam.corp.google.com>
	 <4504851fe2f44615e67cde94286a2fdd.squirrel@www.codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: subashab@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f181.google.com ([209.85.213.181]:38481 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751423AbbAOT2Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2015 14:28:16 -0500
Received: by mail-ig0-f181.google.com with SMTP id r2so14477323igi.2
        for <netdev@vger.kernel.org>; Thu, 15 Jan 2015 11:28:16 -0800 (PST)
In-Reply-To: <4504851fe2f44615e67cde94286a2fdd.squirrel@www.codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-01-15 at 19:03 +0000, subashab@codeaurora.org wrote:
> When a CPU is hotplugged while processing incoming packets,
> dev_cpu_callback() will copy the poll list from the offline
> CPU and raise the softIRQ. In the same context, it will also
> process process_queue of the offline CPU by de-queueing and
> calling netif_rx. Due to this there is a potential for race
> condition between process_backlog() and dev_cpu_callback()
> accessing the same process_queue resource. This patch
> protects this concurrent access by locking.
> 
> Signed-off-by: Prasad Sodagudi <psodagud@codeaurora.org>
> Signed-off-by: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
> ---
>  net/core/dev.c | 22 ++++++++++++++++------
>  1 file changed, 16 insertions(+), 6 deletions(-)
> 
> diff --git a/net/core/dev.c b/net/core/dev.c
> index df0b522..aa8f503 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -3640,6 +3640,7 @@ static void flush_backlog(void *arg)
>  	struct net_device *dev = arg;
>  	struct softnet_data *sd = &__get_cpu_var(softnet_data);
>  	struct sk_buff *skb, *tmp;
> +	unsigned long flags;
> 
>  	rps_lock(sd);
>  	skb_queue_walk_safe(&sd->input_pkt_queue, skb, tmp) {
> @@ -3651,6 +3652,7 @@ static void flush_backlog(void *arg)
>  	}
>  	rps_unlock(sd);
> 
> +	spin_lock_irqsave(&sd->process_queue.lock, flags);
>  	skb_queue_walk_safe(&sd->process_queue, skb, tmp) {
>  		if (skb->dev == dev) {
>  			__skb_unlink(skb, &sd->process_queue);
> @@ -3658,6 +3660,7 @@ static void flush_backlog(void *arg)
>  			input_queue_head_incr(sd);
>  		}
>  	}
> +	spin_unlock_irqrestore(&sd->process_queue.lock, flags);
>  }
> 
>  static int napi_gro_complete(struct sk_buff *skb)
> @@ -4021,7 +4024,7 @@ static int process_backlog(struct napi_struct *napi,
> int quota)
>  {
>  	int work = 0;
>  	struct softnet_data *sd = container_of(napi, struct softnet_data, backlog);
> -
> +	unsigned long flags;
>  #ifdef CONFIG_RPS
>  	/* Check if we have pending ipi, its better to send them now,
>  	 * not waiting net_rx_action() end.
> @@ -4032,18 +4035,19 @@ static int process_backlog(struct napi_struct
> *napi, int quota)
>  	}
>  #endif
>  	napi->weight = weight_p;
> -	local_irq_disable();
> +	spin_lock_irqsave(&sd->process_queue.lock, flags);
>  	while (work < quota) {
>  		struct sk_buff *skb;
>  		unsigned int qlen;
> 
>  		while ((skb = __skb_dequeue(&sd->process_queue))) {
> -			local_irq_enable();
> +			spin_unlock_irqrestore(&sd->process_queue.lock, flags);
>  			__netif_receive_skb(skb);
> -			local_irq_disable();
> +			spin_lock_irqsave(&sd->process_queue.lock, flags);

>  			input_queue_head_incr(sd);
>  			if (++work >= quota) {
> -				local_irq_enable();
> +				spin_unlock_irqrestore(&sd->process_queue.lock,
> +						       flags);
>  				return work;
>  			}


This would be a terrible change in term of performance.

There is something wrong here : process_queue is local to the cpu.

A cpu does not have to use a spin lock to protect this queue.

Can you reproduce the bug on x86 ?
