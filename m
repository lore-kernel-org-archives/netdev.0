From: Amir Vadai <amirv@dev.mellanox.co.il>
Subject: Re: RFS issue: no HW filter for paused stream
Date: Tue, 20 Sep 2011 09:53:09 +0300
Message-ID: <4E783855.4020907@dev.mellanox.co.il>
References: <CAP7N4Kfd9TOPr_V6+R9yVtK80eGWbkAvPE8BStG0+WhvJHaLGg@mail.gmail.com>  <CAP7N4Kes9=VdRV8NHvk03SBg5GbohgdbGqKPABCfYbVyzZ+1ng@mail.gmail.com>  <CA+mtBx9K8MY+WcFZpQp_85rcf316jrPpNgzqSzgMLzy7TC6eXQ@mail.gmail.com> <1316447572.2764.21.camel@bwh-desktop>
Reply-To: amirv@mellanox.co.il
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <therbert@google.com>, oren@mellanox.co.il,
	liranl@mellanox.co.il, netdev@vger.kernel.org,
	amirv@mellanox.co.il, Diego Crupnicoff <Diego@Mellanox.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:42783 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750740Ab1ITGxQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2011 02:53:16 -0400
Received: by wwf22 with SMTP id 22so331898wwf.1
        for <netdev@vger.kernel.org>; Mon, 19 Sep 2011 23:53:14 -0700 (PDT)
In-Reply-To: <1316447572.2764.21.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This will unset the current CPU of the rflow that belongs to the desired 
CPU.
The problem is when the stream resumes and it goes to the wrong RXQ - in 
our HW, it will be according to RSS, as long as there is no specific 
flow steering rule for the stream.
We need to unset the current CPU of the rflow of the actual RXQ that the 
packet arrived at:

diff --git a/net/core/dev.c b/net/core/dev.c
index 4b9981c..a6b3bc8 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2685,6 +2685,12 @@ set_rps_cpu(struct net_device *dev, struct 
sk_buff *skb,
                 rflow = &flow_table->flows[flow_id];
                 rflow->cpu = next_cpu;
                 rflow->filter = rc;
+         /* If this flow (or a flow with the same hash value) becomes
+          * active on the CPU as before, we want to restore the
+          * hardware filter.  Unset the current CPU to ensure that
+          * set_rps_cpu() will be called then.
+          */
+         old_rflow->cpu = RPS_NO_CPU;
                 if (old_rflow->filter == rflow->filter)
                         old_rflow->filter = RPS_NO_FILTER;
         out:

Or even better, not set it in the first place - but I'm not sure I 
undersdtand the implications on RPS:

diff --git a/net/core/dev.c b/net/core/dev.c
index 4b9981c..748acdb 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2654,7 +2654,7 @@ set_rps_cpu(struct net_device *dev, struct sk_buff 
*skb,
  {
         u16 tcpu;

-   tcpu = rflow->cpu = next_cpu;
+ tcpu = next_cpu;
         if (tcpu != RPS_NO_CPU) {
  #ifdef CONFIG_RFS_ACCEL
                 struct netdev_rx_queue *rxqueue;



- Amir

On 09/19/2011 06:52 PM, Ben Hutchings wrote:
> On Mon, 2011-09-19 at 08:13 -0700, Tom Herbert wrote:
>> Ben:  Once a accel RFS flow expires (because flow is idle?), how
>> should it get re-instantiated if thread's CPU doesn't change?
>
> Good question.
>
>> Tom
>>
>> On Sun, Sep 18, 2011 at 11:05 PM, Amir Vadai<amirv@dev.mellanox.co.il>  wrote:
>>> (Resending in plain text)
>>>
>>> Tom Hi,
>>> When a stream is paused, and its rule is expired while it is paused,
>>> no new rule will be configured to the HW when traffic resume.
>>>
>>> Scenario:
>>> 1. Start iperf.
>>> 2. Pause it using Ctrl-Z
>>> 3. Start another iperf (to make sure first stream rule is expired)
>>> 4. Stop the second stream.
>>> 5. Resume first stream. Traffic is not steered to the right rx-queue.
>>>
>>>  From looking at the code:
>>> - When first stream started, RSS steered traffic to rx-queue 'x'.
>>> Because iperf server was running on a different CPU, a new rule was
>>> added and current-cpu was set to desired-cpu.
>>> - After paused, rule was expired and removed from HW by net driver.
>>> But current-cpu wasn't cleared and still is equal to desired-cpu.
>>> - When stream was resumed, traffic was steered again by RSS, and
>>> because current-cpu was equal to desired-cpu,  ndo_rx_flow_steer
>>> wasn't called and no rule was configured to the HW.
>>>
>>> Why isn't current-cpu cleared when expiring a rule?
>
> Because I wrongly assumed that rules could be independently expired by
> the driver and the RPS/RFS core code.
>
> Try this (I haven't tested it myself yet):
>
> From: Ben Hutchings<bhutchings@solarflare.com>
> Date: Mon, 19 Sep 2011 16:44:13 +0100
> Subject: [PATCH net-next] RPS: When a hardware filter is expired, ensure it
>   can be re-added later
>
> Amir Vadai wrote:
>> When a stream is paused, and its rule is expired while it is paused,
>> no new rule will be configured to the HW when traffic resume.
> [...]
>> - When stream was resumed, traffic was steered again by RSS, and
>> because current-cpu was equal to desired-cpu,  ndo_rx_flow_steer
>> wasn't called and no rule was configured to the HW.
>>
>> Why isn't current-cpu cleared when expiring a rule?
>
> When rps_may_expire_flow() matches a filter to a flow that is found to
> be idle, unset the current CPU for that flow.
>
> Reported-by: Amir Vadai<amirv@dev.mellanox.co.il>
> ---
>   net/core/dev.c |   21 ++++++++++++++++-----
>   1 files changed, 16 insertions(+), 5 deletions(-)
>
> diff --git a/net/core/dev.c b/net/core/dev.c
> index b2e262e..3caf65a 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -2817,11 +2817,22 @@ bool rps_may_expire_flow(struct net_device *dev, u16 rxq_index,
>   	if (flow_table&&  flow_id<= flow_table->mask) {
>   		rflow =&flow_table->flows[flow_id];
>   		cpu = ACCESS_ONCE(rflow->cpu);
> -		if (rflow->filter == filter_id&&  cpu != RPS_NO_CPU&&
> -		    ((int)(per_cpu(softnet_data, cpu).input_queue_head -
> -			   rflow->last_qtail)<
> -		     (int)(10 * flow_table->mask)))
> -			expire = false;
> +		if (rflow->filter == filter_id&&  cpu != RPS_NO_CPU) {
> +			if ((int)(per_cpu(softnet_data, cpu).input_queue_head -
> +				  rflow->last_qtail)<
> +			    (int)(10 * flow_table->mask)) {
> +				expire = false;
> +			} else {
> +				/* If this flow (or a flow with the
> +				 * same hash value) becomes active
> +				 * on the CPU as before, we want to
> +				 * restore the hardware filter.  Unset
> +				 * the current CPU to ensure that
> +				 * set_rps_cpu() will be called then.
> +				 */
> +				rflow->cpu = RPS_NO_CPU;
> +			}
> +		}
>   	}
>   	rcu_read_unlock();
>   	return expire;
