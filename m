From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] sis900: Fix the tx queue timeout issue
Date: Thu, 01 Aug 2013 13:15:37 -0700 (PDT)
Message-ID: <20130801.131537.1412986626285577773.davem@davemloft.net>
References: <1375340470-2126-1-git-send-email-kda@linux-powerpc.org>
	<9848F2DB572E5649BA045B288BE08FBE015E5576@039-SN2MPN1-023.039d.mgd.msft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kda@linux-powerpc.org, venza@brownhat.org, netdev@vger.kernel.org
To: B38611@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53426 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757282Ab3HAUPi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Aug 2013 16:15:38 -0400
In-Reply-To: <9848F2DB572E5649BA045B288BE08FBE015E5576@039-SN2MPN1-023.039d.mgd.msft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Duan Fugang-B38611 <B38611@freescale.com>
Date: Thu, 1 Aug 2013 15:50:51 +0000

> On Thursday, August 01, 2013 at 3:01 PM, Denis Kirjanov wrote:
> 
>> @@ -1613,9 +1613,12 @@ sis900_start_xmit(struct sk_buff *skb, struct net_device *net_dev)
>> 	unsigned int  count_dirty_tx;
>> 
>> 	/* Don't transmit data before the complete of auto-negotiation */
>> -	if(!sis_priv->autong_complete){
>> -		netif_stop_queue(net_dev);
>> -		return NETDEV_TX_BUSY;
>> +	if (unlikely(!sis_priv->autong_complete)) {
>> +		if (netif_msg_tx_err(sis_priv) && net_ratelimit())
>> +			netdev_dbg(net_dev, "Auto negotiation in progress\n");
>> +		net_dev->stats.tx_dropped++;
>> +		dev_kfree_skb(skb);
>> +		return NETDEV_TX_OK;
>>  	}
> 
> I always insist on that tx queue timeout is caused by un-correctly phy link handler flow.
> The link up handler flow: Auto-negotiation done-> netif_carrier_on()
>  
> The issue cannot be processed in xmit callback, which must be handled in link adjust process.

I completely agree, if sis_priv->autonet_complete is false this driver _MUST_
keep netif_carrier_off() until it becomes true.

This patch is not the correct fix for this problem, please fix it correctly.
