From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: Re: [Xen-devel] [PATCH net v2 1/3] xen-netback: move NAPI add/remove
 calls
Date: Mon, 11 Aug 2014 13:49:15 +0100
Message-ID: <53E8BBCB.50308@citrix.com>
References: <1407515833-2550-1-git-send-email-wei.liu2@citrix.com> <1407515833-2550-2-git-send-email-wei.liu2@citrix.com> <53E8B874.8070906@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ian Campbell <ian.campbell@citrix.com>
To: David Vrabel <david.vrabel@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>, <netdev@vger.kernel.org>,
	<xen-devel@lists.xen.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:9922 "EHLO SMTP02.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751485AbaHKMtX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Aug 2014 08:49:23 -0400
In-Reply-To: <53E8B874.8070906@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/08/14 13:35, David Vrabel wrote:
> On 08/08/14 17:37, Wei Liu wrote:
>> Originally napi_add was in init_queue and napi_del was in deinit_queue,
>> while kthreads were handled in _connect and _disconnect. Move napi_add
>> and napi_remove to _connect and _disconnect so that they reside togother
>> with kthread operations.
>>
>> Signed-off-by: Wei Liu <wei.liu2@citrix.com>
>> Cc: Ian Campbell <ian.campbell@citrix.com>
>> Cc: Zoltan Kiss <zoltan.kiss@citrix.com>
>> ---
>>   drivers/net/xen-netback/interface.c |   12 ++++++++----
>>   1 file changed, 8 insertions(+), 4 deletions(-)
>>
>> diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
>> index 48a55cd..fdb4fca 100644
>> --- a/drivers/net/xen-netback/interface.c
>> +++ b/drivers/net/xen-netback/interface.c
>> @@ -528,9 +528,6 @@ int xenvif_init_queue(struct xenvif_queue *queue)
>>
>>   	init_timer(&queue->rx_stalled);
>>
>> -	netif_napi_add(queue->vif->dev, &queue->napi, xenvif_poll,
>> -			XENVIF_NAPI_WEIGHT);
>> -
>>   	return 0;
>>   }
>>
>> @@ -618,6 +615,9 @@ int xenvif_connect(struct xenvif_queue *queue, unsigned long tx_ring_ref,
>>   	wake_up_process(queue->task);
>>   	wake_up_process(queue->dealloc_task);
>>
>> +	netif_napi_add(queue->vif->dev, &queue->napi, xenvif_poll,
>> +			XENVIF_NAPI_WEIGHT);
>> +
>>   	return 0;
>>
>>   err_rx_unbind:
>> @@ -675,6 +675,11 @@ void xenvif_disconnect(struct xenvif *vif)
>>
>>   	for (queue_index = 0; queue_index < num_queues; ++queue_index) {
>>   		queue = &vif->queues[queue_index];
>> +		netif_napi_del(&queue->napi);
>> +	}
>
> Why have you added an additional loop over all the queues?  The ordering
> looks wrong as well.  I think you want
>
>    1. unbind from irqhandler
>    2. napi del
>    3. stop task
>    4. stop dealloc task
>    5. unmap frontend rings.
And that's how they are ordered. The idea for having the netif_napi_del 
as a separate loop came from me: it could be more efficient to start 
tearing down all the NAPI instances first, so by the time we stop the 
dealloc thread, it is likely it already done most of the work.
But now I realized that netif_napi_del just delete the instance from a 
list, the real thing happens in xenvif_carrier_off: xenvif_down calls 
napi_disable on all queues, and it waits until all the work is done. So 
it doesn't makes sense to have the netif_napi_del in a separate loop any 
more.
>
> David
>
