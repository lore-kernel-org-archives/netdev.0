From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] net: Add ops->ndo_xmit_flush()
Date: Sat, 23 Aug 2014 17:19:03 -0700 (PDT)
Message-ID: <20140823.171903.2039009790153576522.davem@davemloft.net>
References: <20140823.132823.531609193955178433.davem@davemloft.net>
	<53F9251A.80005@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, therbert@google.com, jhs@mojatatu.com,
	hannes@stressinduktion.org, edumazet@google.com,
	jeffrey.t.kirsher@intel.com, rusty@rustcorp.com.au
To: alexander.duyck@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37558 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751957AbaHXATH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Aug 2014 20:19:07 -0400
In-Reply-To: <53F9251A.80005@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Sat, 23 Aug 2014 16:34:50 -0700

> On 08/23/2014 01:28 PM, David Miller wrote:
>> @@ -3358,6 +3372,27 @@ int __init dev_proc_init(void);
>>  #define dev_proc_init() 0
>>  #endif
>>  
>> +static inline netdev_tx_t __netdev_start_xmit(const struct net_device_ops *ops,
>> +					      struct sk_buff *skb, struct net_device *dev)
>> +{
>> +	netdev_tx_t ret;
>> +	u16 q;
>> +
>> +	q = skb->queue_mapping;
>> +	ret = ops->ndo_start_xmit(skb, dev);
>> +	if (ops->ndo_xmit_flush)
>> +		ops->ndo_xmit_flush(dev, q);
>> +
>> +	return ret;
>> +}
>> +
> 
> What about the case of ndo_start_xmit returning something like
> NETDEV_TX_BUSY?  I am pretty sure you shouldn't be flushing unless
> something has been enqueued.  You might want to add a new return that
> specified that a frame has been enqueued but not flushed and then start
> down the ndo_xmit_flush path.  Maybe something like NETDEV_TX_DEFERRED.
> 
> You might even want to have a return from ndo_xmit_flush just to cover
> any oddball cases like a lockless Tx where we might not be able to flush
> because the queue is already being flushed by another entity.

Indeed, the code as-is isn't correct and should guard the flush
with a check of the 'ret' value.

I don't think LLTX drivers would be able to utilize the flush
facility, which is even more incentive to not use LLTX.
