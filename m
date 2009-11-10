From: Patrick McHardy <kaber@trash.net>
Subject: Re: RFC: net: allow to propagate errors through ->ndo_hard_start_xmit()
Date: Tue, 10 Nov 2009 18:31:27 +0100
Message-ID: <4AF9A36F.7070807@trash.net>
References: <4AF87070.6020007@trash.net> <20091110170838.GA4195@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:41025 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756447AbZKJRb1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Nov 2009 12:31:27 -0500
In-Reply-To: <20091110170838.GA4195@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:
> On Mon, Nov 09, 2009 at 08:41:36PM +0100, Patrick McHardy wrote:
>> I've updated my patch to propagate error values (errno and NET_XMIT
>> codes) through ndo_hard_start_xmit() and incorporated the suggestions
>> made last time, namely:
>>
>> - move slightly complicated return value check to inline function and
>>   add a few comments
>>
>> - fix error handling while in the middle of transmitting GSO skbs
>>
>> I've also audited the tree once again for invalid return values and
>> found a single remaining instance in a Wimax driver, I'll take care
>> of that later.
>>
>> Two questions remain:
>>
>> - I'm not sure the error handling in dev_hard_start_xmit() for GSO
>>   skbs is optimal. When the driver returns an error, it is assumed
>>   the current segment has been freed. The patch then frees the
>>   entire GSO skb, including all remaining segments. Alternatively
>>   it could try to transmit the remaining segments later.
> 
> Anyway, it seems this freeing should be described in the changelog,
> if not moved to a separate patch, since it fixes another problem,
> unless I forgot something.

What other problem are you refering to? I'm not aware of any
problems in the existing function.

>> diff --git a/net/core/dev.c b/net/core/dev.c
>> index bf629ac..1f5752d 100644
>> --- a/net/core/dev.c
>> +++ b/net/core/dev.c
>> @@ -1756,7 +1756,7 @@ int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
>>  			struct netdev_queue *txq)
>>  {
>>  	const struct net_device_ops *ops = dev->netdev_ops;
>> -	int rc;
>> +	int rc = NETDEV_TX_OK;
> 
> Isn't it enough to add this in one place only: before this
> "goto out_kfree_skb"?

Its only exists once in the version I sent out earlier.

>>  	if (likely(!skb->next)) {
>>  		if (!list_empty(&ptype_all))
>> @@ -1804,6 +1804,8 @@ gso:
>>  		nskb->next = NULL;
>>  		rc = ops->ndo_start_xmit(nskb, dev);
>>  		if (unlikely(rc != NETDEV_TX_OK)) {
>> +			if (rc & ~NETDEV_TX_MASK)
>> +				goto out_kfree_gso_skb;
> 
> If e.g. (rc == NETDEV_TX_OK | NET_XMIT_CN), why exactly is this freeing
> necessary now?
> 
> Is e.g. (rc == NETDEV_TX_BUSY | NET_XMIT_CN) legal? If so, there would
> be use after kfree, I guess. Otherwise, it should be documented above
> (and maybe checked somewhere as well).

NET_XMIT_CN is a valid return value, yes. But its not freeing the
transmitted segment but the remaining ones. Its not strictly
necessary, but its the easiest way to treat all errors similar.
Otherwise you get complicated cases, f.i. when the driver returns
NET_XMIT_CN for the first segment and NETDEV_TX_OK for the
remaining ones.

>>  			nskb->next = skb->next;
>>  			skb->next = nskb;
>>  			return rc;
>> @@ -1813,11 +1815,14 @@ gso:
>>  			return NETDEV_TX_BUSY;
>>  	} while (skb->next);
>>  
>> -	skb->destructor = DEV_GSO_CB(skb)->destructor;
>> +	rc = NETDEV_TX_OK;
> 
> When is (rc != NETDEV_TX_OK) possible in this place?

Its gone in the current version.

>> +out_kfree_gso_skb:
>> +	if (likely(skb->next == NULL))
>> +		skb->destructor = DEV_GSO_CB(skb)->destructor;
>>  out_kfree_skb:
>>  	kfree_skb(skb);
>> -	return NETDEV_TX_OK;
>> +	return rc;
>>  }
>> diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
>> index 4ae6aa5..b13821a 100644
>> --- a/net/sched/sch_generic.c
>> +++ b/net/sched/sch_generic.c
>> @@ -120,8 +120,15 @@ int sch_direct_xmit(struct sk_buff *skb, struct Qdisc *q,
>>  
>>  	HARD_TX_LOCK(dev, txq, smp_processor_id());
>>  	if (!netif_tx_queue_stopped(txq) &&
>> -	    !netif_tx_queue_frozen(txq))
>> +	    !netif_tx_queue_frozen(txq)) {
>>  		ret = dev_hard_start_xmit(skb, dev, txq);
>> +
>> +		/* an error implies that the skb was consumed */
>> +		if (ret < 0)
>> +			ret = NETDEV_TX_OK;
> 
>   +		else (?)

Another branch vs. an unconditional and operation. I chose the later.

>> +		/* all NET_XMIT codes map to NETDEV_TX_OK */
>> +		ret &= ~NET_XMIT_MASK;
>> +	}
>>  	HARD_TX_UNLOCK(dev, txq);
>>  
>>  	spin_lock(root_lock);
