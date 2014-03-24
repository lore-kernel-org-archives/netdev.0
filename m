From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: Re: [Xen-devel] [PATCH net] xen-netback: disable rogue vif in kthread
 context
Date: Mon, 24 Mar 2014 13:17:47 +0000
Message-ID: <5330307B.8050304@citrix.com>
References: <1395663214-14133-1-git-send-email-wei.liu2@citrix.com> <533029C7.1080006@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <xen-devel@lists.xen.org>,
	<paul.durrant@citrix.com>, <edwin@etorok.net>,
	Ian Campbell <ian.campbell@citrix.com>
To: David Vrabel <david.vrabel@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:16286 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752938AbaCXNRu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Mar 2014 09:17:50 -0400
In-Reply-To: <533029C7.1080006@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 24/03/14 12:49, David Vrabel wrote:
> On 24/03/14 12:13, Wei Liu wrote:
>> --- a/drivers/net/xen-netback/interface.c
>> +++ b/drivers/net/xen-netback/interface.c
>> @@ -62,6 +62,13 @@ static int xenvif_poll(struct napi_struct *napi, int budget)
>>   	struct xenvif *vif = container_of(napi, struct xenvif, napi);
>>   	int work_done;
>>
>> +	/* This vif is rogue, we pretend we've used up all budget to
>> +	 * deschedule it from NAPI. But this interface will be turned
>> +	 * off in thread context later.
>> +	 */
>> +	if (unlikely(vif->disabled))
>> +		return budget;
>
> Shouldn't you call __napi_complete() and return 0?  Returning budget
> will make NAPI poll repeatedly (since you're pretending to do work).
The comment in net_rx_action:

		/* Drivers must not modify the NAPI state if they
		 * consume the entire weight.  In such cases this code
		 * still "owns" the NAPI instance and therefore can
		 * move the instance around on the list at-will.
		 */



>
>> diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
>> index 438d0c0..94e7261 100644
>> --- a/drivers/net/xen-netback/netback.c
>> +++ b/drivers/net/xen-netback/netback.c
>> @@ -655,7 +655,7 @@ static void xenvif_tx_err(struct xenvif *vif,
>>   static void xenvif_fatal_tx_err(struct xenvif *vif)
>>   {
>>   	netdev_err(vif->dev, "fatal error; disabling device\n");
>> -	xenvif_carrier_off(vif);
>> +	vif->disabled = true;
>
> Do you need to wake the thread here?
>
>> @@ -1549,6 +1549,16 @@ int xenvif_kthread(void *data)
>>   		wait_event_interruptible(vif->wq,
>>   					 rx_work_todo(vif) ||
>>   					 kthread_should_stop());
>
>                                           || vif->disabled ?
>
>> +
>> +		/* This frontend is found to be rogue, disable it in
>> +		 * kthread context. Currently this is only set when
>> +		 * netback finds out frontend sends malformed packet,
>> +		 * but we cannot disable the interface in softirq
>> +		 * context so we defer it here.
>> +		 */
>> +		if (unlikely(vif->disabled) && netif_carrier_ok(vif->dev))
>> +			xenvif_carrier_off(vif);
>> +
>>   		if (kthread_should_stop())
>>   			break;
>>
>
> As an aside, since I happened to be looking at xenvif_poll(), disabling
> local irqs to avoid problems with concurrent events looks unsafe as the
> event may occur on another VCPU.
>
>     __napi_complete(napi);
>     RING_FINAL_CHECK_FOR_REQUESTS(&vif->tx, more_to_do);
>     if (more_to_do)
>         napi_schedule(napi);
>
> Would work I think.
>
> David
>
