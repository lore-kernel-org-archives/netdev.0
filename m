From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH RFC v4 net-next 1/5] virtio_net: enable tx interrupt
Date: Fri, 19 Dec 2014 10:10:04 +0008
Message-ID: <1418983324.20738.1@smtp.corp.redhat.com>
References: <1417429028-11971-1-git-send-email-jasowang@redhat.com>
	<1417429028-11971-2-git-send-email-jasowang@redhat.com>
	<5493D488.7020000@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: pagupta@redhat.com, mst@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, davem@davemloft.net
To: Qin Chuanyu <qinchuanyu@huawei.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <5493D488.7020000@huawei.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org



On Fri, Dec 19, 2014 at 3:32 PM, Qin Chuanyu <qinchuanyu@huawei.com> 
wrote:
> On 2014/12/1 18:17, Jason Wang wrote:
>> On newer hosts that support delayed tx interrupts,
>> we probably don't have much to gain from orphaning
>> packets early.
>> 
>> Note: this might degrade performance for
>> hosts without event idx support.
>> Should be addressed by the next patch.
>> 
>> Cc: Rusty Russell <rusty@rustcorp.com.au>
>> Cc: Michael S. Tsirkin <mst@redhat.com>
>> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
>> Signed-off-by: Jason Wang <jasowang@redhat.com>
>> ---
>>   drivers/net/virtio_net.c | 132 
>> +++++++++++++++++++++++++++++++----------------
>>   1 file changed, 88 insertions(+), 44 deletions(-)
>> 
>> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
>> index ec2a8b4..f68114e 100644
>> --- a/drivers/net/virtio_net.c
>> +++ b/drivers/net/virtio_net.c
>>   static int xmit_skb(struct send_queue *sq, struct sk_buff *skb)
>>   {
>>   	struct skb_vnet_hdr *hdr;
>> @@ -912,7 +951,9 @@ static int xmit_skb(struct send_queue *sq, 
>> struct sk_buff *skb)
>>   		sg_set_buf(sq->sg, hdr, hdr_len);
>>   		num_sg = skb_to_sgvec(skb, sq->sg + 1, 0, skb->len) + 1;
>>   	}
>> -	return virtqueue_add_outbuf(sq->vq, sq->sg, num_sg, skb, 
>> GFP_ATOMIC);
>> +
>> +	return virtqueue_add_outbuf(sq->vq, sq->sg, num_sg, skb,
>> +				    GFP_ATOMIC);
>>   }
>> 
>>   static netdev_tx_t start_xmit(struct sk_buff *skb, struct 
>> net_device *dev)
>> @@ -924,8 +965,7 @@ static netdev_tx_t start_xmit(struct sk_buff 
>> *skb, struct net_device *dev)
>>   	struct netdev_queue *txq = netdev_get_tx_queue(dev, qnum);
>>   	bool kick = !skb->xmit_more;
>> 
>> -	/* Free up any pending old buffers before queueing new ones. */
>> -	free_old_xmit_skbs(sq);
> 
> I think there is no need to remove free_old_xmit_skbs here.
> you could add free_old_xmit_skbs in tx_irq's napi func.
> also could do this in start_xmit if you handle the race well.

Note, free_old_xmit_skbs() has already called in tx napi.
It was a must after tx interrupt was enabled.
> 
> 
> I have done the same thing in ixgbe driver(free skb in ndo_start_xmit 
> and both in tx_irq's poll func), and it seems work well:)

Any performance numbers on this change?
I suspect it reduce the effects of interrupt coalescing.
> 
> I think there would be no so much interrupts in this way, also tx 
> interrupt coalesce is not needed.

Tests (multiple sessions of TCP_RR) does not support this.
Calling free_old_xmit_skbs() in fact damage the performance. 

Any justification that you think it may reduce the interrupts?

Thanks
> 
> 
>> +	virtqueue_disable_cb(sq->vq);
>> 
>>   	/* Try to transmit */
>>   	err = xmit_skb(sq, skb);
>> @@ -941,27 +981,19 @@ static netdev_tx_t start_xmit(struct sk_buff 
>> *skb, struct net_device *dev)
>>   		return NETDEV_TX_OK;
>>   	}
>> 
>> -	/* Don't wait up for transmitted skbs to be freed. */
>> -	skb_orphan(skb);
>> -	nf_reset(skb);
>> -
>>   	/* Apparently nice girls don't return TX_BUSY; stop the queue
>>   	 * before it gets out of hand.  Naturally, this wastes entries. */
>> -	if (sq->vq->num_free < 2+MAX_SKB_FRAGS) {
>> +	if (sq->vq->num_free < 2+MAX_SKB_FRAGS)
>>   		netif_stop_subqueue(dev, qnum);
>> -		if (unlikely(!virtqueue_enable_cb_delayed(sq->vq))) {
>> -			/* More just got used, free them then recheck. */
>> -			free_old_xmit_skbs(sq);
>> -			if (sq->vq->num_free >= 2+MAX_SKB_FRAGS) {
>> -				netif_start_subqueue(dev, qnum);
>> -				virtqueue_disable_cb(sq->vq);
>> -			}
>> -		}
>> -	}
>> 
>>   	if (kick || netif_xmit_stopped(txq))
>>   		virtqueue_kick(sq->vq);
>> 
>> +	if (unlikely(!virtqueue_enable_cb_delayed(sq->vq))) {
>> +		virtqueue_disable_cb(sq->vq);
>> +		napi_schedule(&sq->napi);
>> +	}
>> +
>>   	return NETDEV_TX_OK;
>>   }
>> 
>> @@ -1138,8 +1170,10 @@ static int virtnet_close(struct net_device 
>> *dev)
>>   	/* Make sure refill_work doesn't re-enable napi! */
>>   	cancel_delayed_work_sync(&vi->refill);
>> 
>> -	for (i = 0; i < vi->max_queue_pairs; i++)
>> +	for (i = 0; i < vi->max_queue_pairs; i++) {
>>   		napi_disable(&vi->rq[i].napi);
>> +		napi_disable(&vi->sq[i].napi);
>> +	}
>> 
>>   	return 0;
>>   }
>> @@ -1452,8 +1486,10 @@ static void virtnet_free_queues(struct 
>> virtnet_info *vi)
>>   {
>>   	int i;
>> 
>> -	for (i = 0; i < vi->max_queue_pairs; i++)
>> +	for (i = 0; i < vi->max_queue_pairs; i++) {
>>   		netif_napi_del(&vi->rq[i].napi);
>> +		netif_napi_del(&vi->sq[i].napi);
>> +	}
>> 
>>   	kfree(vi->rq);
>>   	kfree(vi->sq);
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
