From: subashab@codeaurora.org
Subject: Re: [PATCH net] net: rps: fix cpu unplug
Date: Thu, 15 Jan 2015 22:29:26 -0000
Message-ID: <9d793ea2f58c16ec1ceca0124eed4d67.squirrel@www.codeaurora.org>
References: <75547b88b7e2d15b35339a6321c3a929.squirrel@www.codeaurora.org>
    <1421305282.11734.38.camel@edumazet-glaptop2.roam.corp.google.com>
    <4504851fe2f44615e67cde94286a2fdd.squirrel@www.codeaurora.org>
    <1421350095.11734.88.camel@edumazet-glaptop2.roam.corp.google.com>
    <1421358383.11734.97.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "Prasad Sodagudi" <psodagud@codeaurora.org>,
	netdev@vger.kernel.org, "Tom Herbert" <therbert@google.com>
To: "Eric Dumazet" <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.11.231]:47164 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752057AbbAOW31 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2015 17:29:27 -0500
In-Reply-To: <1421358383.11734.97.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks for the patch. I shall try it out and provide feedback soon.
But we think the race condition issue is different. The crash was observed
in the process_queue.

On the event of a CPU hotplug, the NAPI poll_list is copied over from the
offline CPU to the CPU on which dev_cpu_callback() was called. These
operations happens in  dev_cpu_callback() in the context of the notifier
chain from hotplug framework.  Also in the same hotplug notifier context
(dev_cpu_callback) the input_pkt_queue and  process_queue of the offline
CPU are dequeued and sent up the network stack and this is where I think
the race/problem is.

Context1: The online CPU starts processing the poll_list from
net_rx_action since a
softIRQ was raised in dev_cpu_callback(). process_backlog() draining the
process queue

Context2: hotplug notifier dev_cpu_callback() draining the queues and
calling netif_rx().

from dev_cpu_callback()
	/* Process offline CPU's input_pkt_queue */
	while ((skb = __skb_dequeue(&oldsd->process_queue))) {
		netif_rx(skb);
		input_queue_head_incr(oldsd);
	}
	while ((skb = __skb_dequeue(&oldsd->input_pkt_queue))) {
		netif_rx(skb);
		input_queue_head_incr(oldsd);
	}

Is this de-queuing(the above code snippet from dev_cpu_callback())
actually necessary since the poll_list should already have the backlog
napi struct of the old CPU? In this case when process_backlog()
actually runs it should drain these two queues of older CPU.
Let me know your thoughts.

Thanks
KS

The Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum,
 a Linux Foundation Collaborative Project

> From: Eric Dumazet <edumazet@google.com>
>
> softnet_data.input_pkt_queue is protected by a spinlock that
> we must hold when transferring packets from victim queue to an active
> one. This is because other cpus could still be trying to enqueue packets
> into victim queue.
>
> Based on initial patch from Prasad Sodagudi & Subash Abhinov
> Kasiviswanathan.
>
> This version is better because we do not slow down packet processing,
> only make migration safer.
>
> Reported-by: Prasad Sodagudi <psodagud@codeaurora.org>
> Reported-by: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Tom Herbert <therbert@google.com>
> ---
>
> Could you test this fix instead of yours ? Thanks !
>
>  net/core/dev.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/net/core/dev.c b/net/core/dev.c
> index
> 1e325adc43678084418ef9e1abb1fca8059ff599..76f72762b325cfa927a793af180189c51e9eaffd
> 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -7089,7 +7089,7 @@ static int dev_cpu_callback(struct notifier_block
> *nfb,
>  		netif_rx_internal(skb);
>  		input_queue_head_incr(oldsd);
>  	}
> -	while ((skb = __skb_dequeue(&oldsd->input_pkt_queue))) {
> +	while ((skb = skb_dequeue(&oldsd->input_pkt_queue))) {
>  		netif_rx_internal(skb);
>  		input_queue_head_incr(oldsd);
>  	}
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
