From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: Re: [PATCH net V2] xen-netback: don't move event pointer in TX credit
 timeout callback
Date: Thu, 15 May 2014 17:34:09 +0100
Message-ID: <5374EC81.1070808@citrix.com>
References: <1400155158-13527-1-git-send-email-wei.liu2@citrix.com> <5374BB64.1080407@jajcus.net> <20140515141322.GI1117@zion.uk.xensource.com> <5374D38A.2070709@citrix.com> <20140515153051.GJ1117@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jacek Konieczny <jajcus@jajcus.net>, <xen-devel@lists.xen.org>,
	<netdev@vger.kernel.org>, Paul Durrant <paul.durrant@citrix.com>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:29591 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751826AbaEOQeN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 May 2014 12:34:13 -0400
In-Reply-To: <20140515153051.GJ1117@zion.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 15/05/14 16:30, Wei Liu wrote:
> On Thu, May 15, 2014 at 03:47:38PM +0100, Zoltan Kiss wrote:
>> On 15/05/14 15:13, Wei Liu wrote:
>>> On Thu, May 15, 2014 at 03:04:36PM +0200, Jacek Konieczny wrote:
>>>> On 05/15/14 13:59, Wei Liu wrote:
>>>>> ... otherwise the frontend will try to send TX event all the time, even
>>>>> if no progress can be made. The pointer should only be advanced by the
>>>>> routine that actually processes the ring (that is, xenvif_poll).
>>>>>
>>>>> Reported-by: Jacek Konieczny <jajcus@jajcus.net>
>>>>> Signed-off-by: Wei Liu <wei.liu2@citrix.com>
>>>>> Acked-by: Ian Campbell <ian.campbell@citrix.com>
>>>>> Cc: Paul Durrant <paul.durrant@citrix.com>
>>>>> ---
>>>>>   drivers/net/xen-netback/netback.c |    2 +-
>>>>>   1 file changed, 1 insertion(+), 1 deletion(-)
>>>>>
>>>>> diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
>>>>> index 7666540..8e2cbeb 100644
>>>>> --- a/drivers/net/xen-netback/netback.c
>>>>> +++ b/drivers/net/xen-netback/netback.c
>>>>> @@ -658,7 +658,7 @@ void xenvif_check_rx_xenvif(struct xenvif *vif)
>>>>>   {
>>>>>   	int more_to_do;
>>>>>
>>>>> -	RING_FINAL_CHECK_FOR_REQUESTS(&vif->tx, more_to_do);
>>>>> +	more_to_do = RING_HAS_UNCONSUMED_REQUESTS(&vif->tx);
>>>>>
>>>>
>>>> Unfortunately, this seems not enough to fix the problem I have reported
>>>> here:
>>>> http://lists.xenproject.org/archives/html/xen-devel/2014-05/msg01183.html
>>>>
>>>> The dom0 network still stalls when using rate limiting on a VIF
>>>> interface after applying this patch to my 3.14.3 kernel (100% CPU#1
>>>> usage in the 'soft interrupts').
>>>>
>>>
>>> This is a patch for 3.14.4. I've tested it myself (and looking at the
>>> right stats!) to confirm it works.
>>>
>>> ---8<---
>>>  From a4afed6c44027afff82d6fa7503faef83b01fffe Mon Sep 17 00:00:00 2001
>>> From: Wei Liu <wei.liu2@citrix.com>
>>> Date: Thu, 15 May 2014 15:02:55 +0100
>>> Subject: [PATCH] xen-netback: call napi_complete if vif is rate limited
>>>
>>> Reported-by: Jacek Konieczny <jajcus@jajcus.net>
>>> Signed-off-by: Wei Liu <wei.liu2@citrix.com>
>>> Cc: Ian Campbell <ian.campbell@citrix.com>
>>> Cc: Paul Durrant <paul.durrant@citrix.com>
>>> Cc: David Vrabel <david.vrabel@citrix.com>
>>> ---
>>>   drivers/net/xen-netback/common.h    |    2 +-
>>>   drivers/net/xen-netback/interface.c |    5 +++--
>>>   drivers/net/xen-netback/netback.c   |   12 ++++++++----
>>>   3 files changed, 12 insertions(+), 7 deletions(-)
>>>
>>> diff --git a/drivers/net/xen-netback/common.h b/drivers/net/xen-netback/common.h
>>> index 4bf5b33..4c018de 100644
>>> --- a/drivers/net/xen-netback/common.h
>>> +++ b/drivers/net/xen-netback/common.h
>>> @@ -219,7 +219,7 @@ void xenvif_check_rx_xenvif(struct xenvif *vif);
>>>   /* Prevent the device from generating any further traffic. */
>>>   void xenvif_carrier_off(struct xenvif *vif);
>>>
>>> -int xenvif_tx_action(struct xenvif *vif, int budget);
>>> +int xenvif_tx_action(struct xenvif *vif, int budget, bool *rate_limited);
>>>
>>>   int xenvif_kthread(void *data);
>>>   void xenvif_kick_thread(struct xenvif *vif);
>>> diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
>>> index 2e92d52..03cfbd6 100644
>>> --- a/drivers/net/xen-netback/interface.c
>>> +++ b/drivers/net/xen-netback/interface.c
>>> @@ -61,6 +61,7 @@ static int xenvif_poll(struct napi_struct *napi, int budget)
>>>   {
>>>   	struct xenvif *vif = container_of(napi, struct xenvif, napi);
>>>   	int work_done;
>>> +	bool rate_limited;
>>>
>>>   	/* This vif is rogue, we pretend we've there is nothing to do
>>>   	 * for this vif to deschedule it from NAPI. But this interface
>>> @@ -71,7 +72,7 @@ static int xenvif_poll(struct napi_struct *napi, int budget)
>>>   		return 0;
>>>   	}
>>>
>>> -	work_done = xenvif_tx_action(vif, budget);
>>> +	work_done = xenvif_tx_action(vif, budget, &rate_limited);
>>>
>>>   	if (work_done < budget) {
>>>   		int more_to_do = 0;
>>> @@ -96,7 +97,7 @@ static int xenvif_poll(struct napi_struct *napi, int budget)
>>>   		local_irq_save(flags);
>>>
>>>   		RING_FINAL_CHECK_FOR_REQUESTS(&vif->tx, more_to_do);
>>> -		if (!more_to_do)
>>> +		if (!more_to_do || rate_limited)
>> How about calling timer_pending(&vif->credit_timeout) instead?
>
> timer_pending(&vif->credit_timeout) covers only one of two senarios of
> "credit exceeded", see tx_credit_exceeded.
The other scenario is when the packet size exceeds the credit. There is 
no packet here actually, we just want to know if this vif ran out of 
credit and waiting for the timer to fire.

>
>> Also, can this __napi_complete and the callback's napi_schedule race with
>> each other? When napi_complete is between removing from the list and
>> clearing the bit, and napi_schedule is just test&set the bit, the latter
>> won't add the instance to the list again
>>
>
> I think it should be fine. How is it different from what we already have
> now? Is this something similar to what David once posted?
>
>    <1395756505-21573-1-git-send-email-david.vrabel@citrix.com>
Unfortunately that discussion stalled, and my question were not 
answered, so I bumped it again. But that's different a bit: it was about 
racing between the NAPI instance (running in softirq context) and the 
interrupt. Here the danger is that the NAPI instance and the softirq can 
race. They both run in softirq context, and even if they were originally 
on the same CPU, I'm sure if the instance move somewhere else, the timer 
doesn't follow it.

Zoli
