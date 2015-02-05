From: subashab@codeaurora.org
Subject: Re: [RFC] Possible data stall with RPS and CPU hotplug
Date: Thu, 5 Feb 2015 23:32:33 -0000
Message-ID: <29656169f6b412195cea472d21c89b4f.squirrel@www.codeaurora.org>
References: <90b4251bdb040907ea73f992e1bb96df.squirrel@www.codeaurora.org>
    <1423012751.907.49.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org, therbert@google.com
To: "Eric Dumazet" <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.11.231]:46602 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751098AbbBEXce (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2015 18:32:34 -0500
In-Reply-To: <1423012751.907.49.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks for the suggestion. It appears to be an oversight on my part that
the device where the crash was reported did not have commit
ac64da0b83d82abe62f78b3d0e21cca31aea24fa ("net: rps: fix cpu unplug").

> On Wed, 2015-02-04 at 00:52 +0000, subashab@codeaurora.org wrote:
>> We have an RPS configuration to process packets on Core3 while hardware
>> interrupts arrive on Core0. We see an occasional stall when Core3 is hot
>> plugged out and comes back up at a later point in time. At the time of
>> this stall, we notice that the maximum backlog queue size of 1000 is
>> reached and subsequent packets are dropped, NAPI is scheduled on Core3,
>> but softIRQ NET_RX is not raised on Core3.
>>
>> This leads me to think that possibly the Core3 went offline just before
>> hitting this conditional cpu_online() check in
>> net_rps_action_and_irq_enable(), so the IPI was not delivered to Core3.
>>
>> 	/* Send pending IPI's to kick RPS processing on remote cpus. */
>> 	while (remsd) {
>> 		struct softnet_data *next = remsd->rps_ipi_next;
>> 		if (cpu_online(remsd->cpu))
>> 			__smp_call_function_single(remsd->cpu,
>> 						   &remsd->csd, 0);
>> 		remsd = next;
>> 	}
>>
>> Later when the Core3 comes back online packets start getting enqueued to
>> Core3 but IPI's are not delivered because NAPI_STATE_SCHED is never
>> cleared on sofnet_data for Core3.
>>
>> enqueue_to_backlog()
>>
>> 	/* Schedule NAPI for backlog device
>> 	 * We can use non atomic operation since we own the queue lock
>> 	 */
>> 	if (!__test_and_set_bit(NAPI_STATE_SCHED, &sd->backlog.state)) {
>> 		if (!rps_ipi_queued(sd))
>> 			____napi_schedule(sd, &sd->backlog);
>> 	}
>> 	goto enqueue;
>> }
>>
>> Is this analysis correct and does the following patch makes sense?
>>
>> Signed-off-by: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
>> ---
>>  net/core/dev.c | 1 +
>>  1 file changed, 1 insertion(+)
>>
>> diff --git a/net/core/dev.c b/net/core/dev.c
>> index 171420e..57663c9 100644
>> --- a/net/core/dev.c
>> +++ b/net/core/dev.c
>> @@ -7101,6 +7101,7 @@ static int dev_cpu_callback(struct notifier_block
>> *nfb,
>>  		input_queue_head_incr(oldsd);
>>  	}
>>
>> +	clear_bit(NAPI_STATE_SCHED, oldsd->backlog.state);
>>  	return NOTIFY_OK;
>>  }
>>
>
> Really, this should not be needed after commit
> ac64da0b83d82abe62f78b3d0e21cca31aea24fa
> ("net: rps: fix cpu unplug")
>
> If NAPI_STATE_SCHED was set on oldsd->backlog.state, then we must have
> found the napi in oldsd->poll_list
>
> So we should have hit line 7125 :
>
> 	if (napi->poll == process_backlog)
> 7125:		napi->state = 0;
> 	else
> 		____napi_schedule(sd, napi);
>
> So if you find this bit set, there is another bug ?
>
>
> But it looks like we do not use proper netif_rx() variant in this path.
>
> We run from process context, so we need (at least) following patch :
>
> diff --git a/net/core/dev.c b/net/core/dev.c
> index
> 1d564d68e31a5f361fc233ae90a3a19e82915664..947a291223f5437bc004f7fcbb3a938ecba6ced0
> 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -7132,11 +7132,11 @@ static int dev_cpu_callback(struct notifier_block
> *nfb,
>
>  	/* Process offline CPU's input_pkt_queue */
>  	while ((skb = __skb_dequeue(&oldsd->process_queue))) {
> -		netif_rx_internal(skb);
> +		netif_rx_ni(skb);
>  		input_queue_head_incr(oldsd);
>  	}
>  	while ((skb = skb_dequeue(&oldsd->input_pkt_queue))) {
> -		netif_rx_internal(skb);
> +		netif_rx_ni(skb);
>  		input_queue_head_incr(oldsd);
>  	}
>
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
