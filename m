From: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Subject: Re: [PATCH] xen-netfront: Delete rx_refill_timer in
 xennet_disconnect_backend()
Date: Mon, 30 Jan 2017 13:23:27 -0500
Message-ID: <40057d9d-c615-1a2b-63a2-ab717c29d659@oracle.com>
References: <1485798346-4425-1-git-send-email-boris.ostrovsky@oracle.com>
 <1485799651.6360.101.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: jgross@suse.com, xen-devel@lists.xenproject.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        vineethp@amazon.com, wei.liu2@citrix.com, paul.durrant@citrix.com,
        stable@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1485799651.6360.101.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/30/2017 01:07 PM, Eric Dumazet wrote:
> On Mon, 2017-01-30 at 12:45 -0500, Boris Ostrovsky wrote:
>> rx_refill_timer should be deleted as soon as we disconnect from the
>> backend since otherwise it is possible for the timer to go off before
>> we get to xennet_destroy_queues(). If this happens we may dereference
>> queue->rx.sring which is set to NULL in xennet_disconnect_backend().
>>
>> Signed-off-by: Boris Ostrovsky <boris.ostrovsky@oracle.com>
>> CC: stable@vger.kernel.org
>> ---
>>  drivers/net/xen-netfront.c | 3 ++-
>>  1 file changed, 2 insertions(+), 1 deletion(-)
>>
>> diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
>> index 8315fe7..722fe9f 100644
>> --- a/drivers/net/xen-netfront.c
>> +++ b/drivers/net/xen-netfront.c
>> @@ -1379,6 +1379,8 @@ static void xennet_disconnect_backend(struct netfront_info *info)
>>  	for (i = 0; i < num_queues && info->queues; ++i) {
>>  		struct netfront_queue *queue = &info->queues[i];
>>  
>> +		del_timer_sync(&queue->rx_refill_timer);
>> +
> If napi_disable() was not called before this del_timer_sync(), another
> RX might come here and rearm rx_refill_timer.

We do netif_carrier_off() first thing in xennet_disconnect_backend() and
the only place where the timer is rearmed is xennet_alloc_rx_buffers(),
which is guarded by netif_carrier_ok() check.

-boris


>
>>  		if (queue->tx_irq && (queue->tx_irq == queue->rx_irq))
>>  			unbind_from_irqhandler(queue->tx_irq, queue);
>>  		if (queue->tx_irq && (queue->tx_irq != queue->rx_irq)) {
>> @@ -1733,7 +1735,6 @@ static void xennet_destroy_queues(struct netfront_info *info)
>>  
>>  		if (netif_running(info->netdev))
>>  			napi_disable(&queue->napi);
>> -		del_timer_sync(&queue->rx_refill_timer);
>>  		netif_napi_del(&queue->napi);
>>  	}
>>  
>
