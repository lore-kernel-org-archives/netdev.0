From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [PATCH 3/3] net: allocate tx queues in register_netdevice
Date: Mon, 18 Oct 2010 18:19:57 -0700
Message-ID: <4CBCF23D.50006@intel.com>
References: <alpine.DEB.1.00.1010181057580.16304@pokey.mtv.corp.google.com>	<1287438080.2252.792.camel@achroite.uk.solarflarecom.com>	<4CBCE26E.4020405@intel.com> <AANLkTinX+2aW_yDa0o=oiaxt6BJGNWjiifGCS7auz0O9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:15305 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754759Ab0JSBUA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Oct 2010 21:20:00 -0400
In-Reply-To: <AANLkTinX+2aW_yDa0o=oiaxt6BJGNWjiifGCS7auz0O9@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/18/2010 5:17 PM, Tom Herbert wrote:
> On Mon, Oct 18, 2010 at 5:12 PM, John Fastabend
> <john.r.fastabend@intel.com> wrote:
>> On 10/18/2010 2:41 PM, Ben Hutchings wrote:
>>> On Mon, 2010-10-18 at 11:02 -0700, Tom Herbert wrote:
>>>> This patch introduces netif_alloc_netdev_queues which is called from
>>>> register_device instead of alloc_netdev_mq.  This makes TX queue
>>>> allocation symmetric with RX allocation similarly allows drivers to
>>>> change dev->num_tx_queues after allocating netdev and before
>>>> registering it.
>>>
>>> Changing num_tx_queues is probably *not* desirable, same as for
>>> num_rx_queues.
>>>
> 
> Okay, so both netif_set_real_num_rx_queues and
> netif_set_real_num_tx_queues should return -EINVAL if queue count >
> num_[tr]x_queues?
> 

Yes and also if txq|rxq < 1 but it looks like this case is covered.

>>
>> Right, this will break ixgbe and other drivers that may call netif_set_real_num_{rx|tx}_queues() to increase the number of
>> queues. Returning an error code seems like a good idea though.
>>
>> John.
>>
>>> [...]
>>>> --- a/net/core/dev.c
>>>> +++ b/net/core/dev.c
>>>> @@ -1553,18 +1553,24 @@ static void dev_queue_xmit_nit(struct sk_buff *skb, struct net_device *dev)
>>>>   * Routine to help set real_num_tx_queues. To avoid skbs mapped to queues
>>>>   * greater then real_num_tx_queues stale skbs on the qdisc must be flushed.
>>>>   */
>>>> -void netif_set_real_num_tx_queues(struct net_device *dev, unsigned int txq)
>>>> +int netif_set_real_num_tx_queues(struct net_device *dev, unsigned int txq)
>>>>  {
>>>> -    unsigned int real_num = dev->real_num_tx_queues;
>>>> +    if (txq < 1)
>>>> +            return -EINVAL;
>>>>
>>>> -    if (unlikely(txq > dev->num_tx_queues))
>>>> -            ;
>>>> -    else if (txq > real_num)
>>>> -            dev->real_num_tx_queues = txq;
>>>> -    else if (txq < real_num) {
>>>> -            dev->real_num_tx_queues = txq;
>>>> -            qdisc_reset_all_tx_gt(dev, txq);
>>>> -    }
>>>> +    if (dev->reg_state == NETREG_REGISTERED) {
>>>> +            ASSERT_RTNL();
>>>> +
>>>> +            if (txq > dev->num_tx_queues)
>>>> +                    return -EINVAL;
>>>> +
>>>> +            if (txq < dev->real_num_tx_queues)
>>>> +                    qdisc_reset_all_tx_gt(dev, txq);
>>>> +    } else
>>>> +            dev->num_tx_queues = txq;
>>> [...]
>>>
>>> The kernel-doc comment should be updated to reflect the locking
>>> requirement and the possibility of failure when called after
>>> registration.
>>>
>>> Ben.
>>>
>>
>>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

