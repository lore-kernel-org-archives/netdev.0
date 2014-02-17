From: Andrew Bennieston <andrew.bennieston@citrix.com>
Subject: Re: [Xen-devel] [PATCH V3 net-next 3/5] xen-netfront: Factor	queue-specific
 data into queue struct.
Date: Mon, 17 Feb 2014 11:10:23 +0000
Message-ID: <5301EE1F.8080305@citrix.com>
References: <1392399353-11973-1-git-send-email-andrew.bennieston@citrix.com> <1392399353-11973-4-git-send-email-andrew.bennieston@citrix.com> <52FE5AC6.9000300@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <xen-devel@lists.xenproject.org>, <netdev@vger.kernel.org>,
	<paul.durrant@citrix.com>, <wei.liu2@citrix.com>,
	<ian.campbell@citrix.com>
To: David Vrabel <david.vrabel@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:43848 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751936AbaBQLKs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Feb 2014 06:10:48 -0500
In-Reply-To: <52FE5AC6.9000300@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 14/02/14 18:04, David Vrabel wrote:
> On 14/02/14 17:35, Andrew J. Bennieston wrote:
>> From: "Andrew J. Bennieston" <andrew.bennieston@citrix.com>
>>
>> In preparation for multi-queue support in xen-netfront, move the
>> queue-specific data from struct netfront_info to struct netfront_queue,
>> and update the rest of the code to use this.
>>
>> Also adds loops over queues where appropriate, even though only one is
>> configured at this point, and uses alloc_etherdev_mq() and the
>> corresponding multi-queue netif wake/start/stop functions in preparation
>> for multiple active queues.
>>
>> Finally, implements a trivial queue selection function suitable for
>> ndo_select_queue, which simply returns 0, selecting the first (and
>> only) queue.
> [...]
>> --- a/drivers/net/xen-netfront.c
>> +++ b/drivers/net/xen-netfront.c
> [...]
>> @@ -2048,17 +2196,27 @@ static const struct xenbus_device_id netfront_ids[] = {
> [...]
>> +	for (i = 0; i < info->num_queues; ++i) {
>> +		queue = &info->queues[i];
>> +		del_timer_sync(&queue->rx_refill_timer);
>> +	}
>> +
>> +	if (info->num_queues) {
>> +		kfree(info->queues);
>> +		info->queues = NULL;
>> +	}
>> +
>>   	xennet_sysfs_delif(info->netdev);
>>
>>   	unregister_netdev(info->netdev);
>>
>> -	del_timer_sync(&info->rx_refill_timer);
>> -
>
> This has reordered the del_timer_sync() to before the
> unregister_netdev() call.
>
> Can you be sure that the timer cannot be restarted after deleting it?
>
> David
>
Looking at the code, mod_timer() is called from 
xennet_alloc_rx_buffers(), only. This, in turn, is called from 
xennet_poll, which is the registered NAPI handler function. This should 
not be called after a napi_disable(), which is done in xennet_close(). 
xennet_close() is called to stop the interface, which should be done 
before the module is removed (unless I'm mistaken here). So this should 
be safe.

That said, there is no reason that the queue cleanup has to happen 
before the unregister_netdev() call. I'll move it to after that point, 
just to be safe.

-Andrew
