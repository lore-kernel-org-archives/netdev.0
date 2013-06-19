From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH net-next 2/2] macvtap: Perform GSO on forwarding path.
Date: Wed, 19 Jun 2013 12:27:47 -0400
Message-ID: <51C1DC03.10704@redhat.com>
References: <1371653272-11703-1-git-send-email-vyasevic@redhat.com> <1371653272-11703-3-git-send-email-vyasevic@redhat.com> <20130619153047.GB12619@redhat.com>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, jasowang@redhat.com
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:14607 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756860Ab3FSQ1t (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Jun 2013 12:27:49 -0400
In-Reply-To: <20130619153047.GB12619@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/19/2013 11:30 AM, Michael S. Tsirkin wrote:
> On Wed, Jun 19, 2013 at 10:47:52AM -0400, Vlad Yasevich wrote:
>> When macvtap forwards skb to its tap, it needs to check
>> if GSO needs to be performed.  This is necessary
>> when the HW device performed GRO, but the guest reading
>> from the tap does not support it (ex: Windows 7).
>>
>> Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
>> ---
>>   drivers/net/macvtap.c | 26 +++++++++++++++++++++++++-
>>   1 file changed, 25 insertions(+), 1 deletion(-)
>>
>> diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
>> index 09f0b1f..698f613 100644
>> --- a/drivers/net/macvtap.c
>> +++ b/drivers/net/macvtap.c
>> @@ -291,13 +291,37 @@ static void macvtap_del_queues(struct net_device *dev)
>>   static int macvtap_forward(struct net_device *dev, struct sk_buff *skb)
>>   {
>>   	struct macvtap_queue *q = macvtap_get_queue(dev, skb);
>> +	netdev_features_t features;
>>   	if (!q)
>>   		goto drop;
>>
>>   	if (skb_queue_len(&q->sk.sk_receive_queue) >= dev->tx_queue_len)
>>   		goto drop;
>>
>> -	skb_queue_tail(&q->sk.sk_receive_queue, skb);
>> +	features = netif_skb_features(skb);
>
> Confused. skb->dev here points to the source macvlan
> so features are wrong - we need destination features, no?

yes and no....  Thanks for pointing this out as this is actually the 
wrong patch.

So, to answer your question, in the case of receive, the device is 
already the destination device.
In the case of broadcast forward, the skb->dev is actually null and the
'correct' patch does:

	skb->dev = dev;


>
>> +	if (netif_needs_gso(skb, features)) {
>> +		struct sk_buff *segs = skb_gso_segment(skb, features);
>
> I'd prefer a different name for this variable.
> skb_seg?
>

OK.

-vlad

>> +
>> +		if (IS_ERR(segs))
>> +			goto drop;
>> +
>> +		if (!segs) {
>> +			skb_queue_tail(&q->sk.sk_receive_queue, skb);
>> +			goto wake_up;
>> +		}
>> +
>> +		kfree_skb(skb);
>> +		while (segs) {
>> +			struct sk_buff *nskb = segs->next;
>> +
>> +			segs->next = NULL;
>> +			skb_queue_tail(&q->sk.sk_receive_queue, segs);
>> +			segs = nskb;
>> +		}
>
>
>> +	} else
>> +		skb_queue_tail(&q->sk.sk_receive_queue, skb);
>> +
>> +wake_up:
>>   	wake_up_interruptible_poll(sk_sleep(&q->sk), POLLIN | POLLRDNORM | POLLRDBAND);
>>   	return NET_RX_SUCCESS;
>>
>> --
>> 1.8.1.4
