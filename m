From: Amir Vadai <amirv@mellanox.co.il>
Subject: Re: RFS issue: no HW filter for paused stream
Date: Thu, 22 Sep 2011 09:11:48 +0300
Message-ID: <4E7AD1A4.7000308@mellanox.co.il>
References: <CAP7N4Kfd9TOPr_V6+R9yVtK80eGWbkAvPE8BStG0+WhvJHaLGg@mail.gmail.com>  <CAP7N4Kes9=VdRV8NHvk03SBg5GbohgdbGqKPABCfYbVyzZ+1ng@mail.gmail.com>  <CA+mtBx9K8MY+WcFZpQp_85rcf316jrPpNgzqSzgMLzy7TC6eXQ@mail.gmail.com>  <1316447572.2764.21.camel@bwh-desktop>  <4E783855.4020907@dev.mellanox.co.il> <1316617742.2760.18.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <therbert@google.com>, <oren@mellanox.co.il>,
	<liranl@mellanox.co.il>, <netdev@vger.kernel.org>,
	Diego Crupnicoff <Diego@Mellanox.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:52595 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751276Ab1IVGLw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Sep 2011 02:11:52 -0400
In-Reply-To: <1316617742.2760.18.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Looks good.
and now the code is much clearer

- Amir

On 09/21/2011 06:09 PM, Ben Hutchings wrote:
> On Tue, 2011-09-20 at 09:53 +0300, Amir Vadai wrote:
>> This will unset the current CPU of the rflow that belongs to the desired
>> CPU.
>> The problem is when the stream resumes and it goes to the wrong RXQ - in
>> our HW, it will be according to RSS, as long as there is no specific
>> flow steering rule for the stream.
> Sorry, yes.  Told you I didn't test my patch!
>
>> We need to unset the current CPU of the rflow of the actual RXQ that the
>> packet arrived at:
> [...]
>> Or even better, not set it in the first place - but I'm not sure I
>> undersdtand the implications on RPS:
>>
>> diff --git a/net/core/dev.c b/net/core/dev.c
>> index 4b9981c..748acdb 100644
>> --- a/net/core/dev.c
>> +++ b/net/core/dev.c
>> @@ -2654,7 +2654,7 @@ set_rps_cpu(struct net_device *dev, struct sk_buff
>> *skb,
>>    {
>>           u16 tcpu;
>>
>> -   tcpu = rflow->cpu = next_cpu;
>> + tcpu = next_cpu;
>>           if (tcpu != RPS_NO_CPU) {
>>    #ifdef CONFIG_RFS_ACCEL
>>                   struct netdev_rx_queue *rxqueue;
>>
>>
> But that means we never move the flow to a new CPU in the non-
> accelerated case.  So maybe the proper change would be:
>
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -2652,10 +2652,7 @@ static struct rps_dev_flow *
>   set_rps_cpu(struct net_device *dev, struct sk_buff *skb,
>   	    struct rps_dev_flow *rflow, u16 next_cpu)
>   {
> -	u16 tcpu;
> -
> -	tcpu = rflow->cpu = next_cpu;
> -	if (tcpu != RPS_NO_CPU) {
> +	if (next_cpu != RPS_NO_CPU) {
>   #ifdef CONFIG_RFS_ACCEL
>   		struct netdev_rx_queue *rxqueue;
>   		struct rps_dev_flow_table *flow_table;
> @@ -2683,16 +2680,16 @@ set_rps_cpu(struct net_device *dev, struct sk_buff *skb,
>   			goto out;
>   		old_rflow = rflow;
>   		rflow =&flow_table->flows[flow_id];
> -		rflow->cpu = next_cpu;
>   		rflow->filter = rc;
>   		if (old_rflow->filter == rflow->filter)
>   			old_rflow->filter = RPS_NO_FILTER;
>   	out:
>   #endif
>   		rflow->last_qtail =
> -			per_cpu(softnet_data, tcpu).input_queue_head;
> +			per_cpu(softnet_data, next_cpu).input_queue_head;
>   	}
>
> +	rflow->cpu = next_cpu;
>   	return rflow;
>   }
>
> --- END ---
>
