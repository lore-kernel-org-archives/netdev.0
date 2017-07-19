From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net-next 2/5] virtio-net: pack headroom into ctx for
 mergeable buffer
Date: Wed, 19 Jul 2017 10:29:18 +0800
Message-ID: <382b22b5-0735-b2d3-e838-adbc4bedfb3c@redhat.com>
References: <1500295441-19339-1-git-send-email-jasowang@redhat.com>
 <1500295441-19339-3-git-send-email-jasowang@redhat.com>
 <20170718215432-mutt-send-email-mst@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: virtualization@lists.linux-foundation.org,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170718215432-mutt-send-email-mst@kernel.org>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 2017年07月19日 02:59, Michael S. Tsirkin wrote:
> On Mon, Jul 17, 2017 at 08:43:58PM +0800, Jason Wang wrote:
>> Pack headroom into ctx, then during XDP set, we could know the size of
>> headroom and copy if needed. This is required for avoiding reset on
>> XDP.
> Not really when XDP is set - it's when buffers are used.

Of course :)

>
> virtio-net: pack headroom into ctx for mergeable buffers
>
> Pack headroom into ctx - this way when we get a buffer we can figure out
> the actual headroom that was allocated for the buffer. Will be helpful
> to optimize switching between XDP and non-XDP modes which have different
> headroom requirements.

Thanks, let me use this as the commit log.

>
>> Signed-off-by: Jason Wang <jasowang@redhat.com>
>> ---
>>   drivers/net/virtio_net.c | 29 ++++++++++++++++++++++++-----
>>   1 file changed, 24 insertions(+), 5 deletions(-)
>>
>> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
>> index 1f8c15c..8fae9a8 100644
>> --- a/drivers/net/virtio_net.c
>> +++ b/drivers/net/virtio_net.c
>> @@ -270,6 +270,23 @@ static void skb_xmit_done(struct virtqueue *vq)
>>   		netif_wake_subqueue(vi->dev, vq2txq(vq));
>>   }
>>   
>> +#define MRG_CTX_HEADER_SHIFT 22
>> +static void *mergeable_len_to_ctx(unsigned int truesize,
>> +				  unsigned int headroom)
>> +{
>> +	return (void *)(unsigned long)((headroom << MRG_CTX_HEADER_SHIFT) | truesize);
>> +}
>> +
>> +static unsigned int mergeable_ctx_to_headroom(void *mrg_ctx)
>> +{
>> +	return (unsigned long)mrg_ctx >> MRG_CTX_HEADER_SHIFT;
>> +}
>> +
>> +static unsigned int mergeable_ctx_to_truesize(void *mrg_ctx)
>> +{
>> +	return (unsigned long)mrg_ctx & ((1 << MRG_CTX_HEADER_SHIFT) - 1);
>> +}
>> +
>>   /* Called from bottom half context */
>>   static struct sk_buff *page_to_skb(struct virtnet_info *vi,
>>   				   struct receive_queue *rq,
>> @@ -639,13 +656,14 @@ static struct sk_buff *receive_mergeable(struct net_device *dev,
>>   	}
>>   	rcu_read_unlock();
>>   
>> -	if (unlikely(len > (unsigned long)ctx)) {
>> +	truesize = mergeable_ctx_to_truesize(ctx);
>> +	if (unlikely(len > truesize)) {
>>   		pr_debug("%s: rx error: len %u exceeds truesize %lu\n",
>>   			 dev->name, len, (unsigned long)ctx);
>>   		dev->stats.rx_length_errors++;
>>   		goto err_skb;
>>   	}
>> -	truesize = (unsigned long)ctx;
>> +
>>   	head_skb = page_to_skb(vi, rq, page, offset, len, truesize);
>>   	curr_skb = head_skb;
>>   
>> @@ -665,13 +683,14 @@ static struct sk_buff *receive_mergeable(struct net_device *dev,
>>   		}
>>   
>>   		page = virt_to_head_page(buf);
>> -		if (unlikely(len > (unsigned long)ctx)) {
>> +
>> +		truesize = mergeable_ctx_to_truesize(ctx);
>> +		if (unlikely(len > truesize)) {
>>   			pr_debug("%s: rx error: len %u exceeds truesize %lu\n",
>>   				 dev->name, len, (unsigned long)ctx);
>>   			dev->stats.rx_length_errors++;
>>   			goto err_skb;
>>   		}
>> -		truesize = (unsigned long)ctx;
>>   
>>   		num_skb_frags = skb_shinfo(curr_skb)->nr_frags;
>>   		if (unlikely(num_skb_frags == MAX_SKB_FRAGS)) {
>> @@ -889,7 +908,7 @@ static int add_recvbuf_mergeable(struct virtnet_info *vi,
>>   
>>   	buf = (char *)page_address(alloc_frag->page) + alloc_frag->offset;
>>   	buf += headroom; /* advance address leaving hole at front of pkt */
>> -	ctx = (void *)(unsigned long)len;
>> +	ctx = mergeable_len_to_ctx(len, headroom);
>>   	get_page(alloc_frag->page);
>>   	alloc_frag->offset += len + headroom;
>>   	hole = alloc_frag->size - alloc_frag->offset;
>> -- 
>> 2.7.4
