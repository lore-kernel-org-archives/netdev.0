From: Denis Kirjanov <kirjanov@gmail.com>
Subject: Re: [PATCH] sis900: Fix the tx queue timeout issue
Date: Fri, 2 Aug 2013 16:13:14 +0400
Message-ID: <CAHj3AVnbF4NdsYJr3B=b8DBjRs8ogdkCE9sDnCUrhMYpOqx9EA@mail.gmail.com>
References: <1375281782-2332-1-git-send-email-kda@linux-powerpc.org>
	<1375445019.11783.5.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Denis Kirjanov <kda@linux-powerpc.org>, venza@brownhat.org,
	davem@davemloft.net, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f182.google.com ([209.85.215.182]:42290 "EHLO
	mail-ea0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751395Ab3HBMNP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Aug 2013 08:13:15 -0400
Received: by mail-ea0-f182.google.com with SMTP id o10so293590eaj.13
        for <netdev@vger.kernel.org>; Fri, 02 Aug 2013 05:13:14 -0700 (PDT)
In-Reply-To: <1375445019.11783.5.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/2/13, Ben Hutchings <bhutchings@solarflare.com> wrote:
> On Wed, 2013-07-31 at 18:43 +0400, Denis Kirjanov wrote:
> [...]
>> We are trying to initiate a frame transmission even
>> if we are not ready to do so due auto negotiation progress:
>>
>> timer routine checks the link status and if it's up calls
>> netif_carrier_on() allowing upper layer to start the tx queue
>
> Right.  So why is sis900_start_xmit() still being called?  Is this
> handling the case where the link just went down and the TX scheduler has
> not yet reacted to this?
>
> Would it actually hurt if a packet is queued at this point?  I see no
> reason to think it would.  In that case you could remove the entire
> if-statement.

Yeah, it's completely wrong to handle such issue in tx path and it
must be removed.
I've prepared an another patch... I'll send it shortly.

Thanks.

> Ben.
>
>> Signed-off-by: Denis Kirjanov <kda@linux-powerpc.org>
>> ---
>>  drivers/net/ethernet/sis/sis900.c | 10 +++++++---
>>  1 file changed, 7 insertions(+), 3 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/sis/sis900.c
>> b/drivers/net/ethernet/sis/sis900.c
>> index eb4aea3..9516734 100644
>> --- a/drivers/net/ethernet/sis/sis900.c
>> +++ b/drivers/net/ethernet/sis/sis900.c
>> @@ -1613,9 +1613,13 @@ sis900_start_xmit(struct sk_buff *skb, struct
>> net_device *net_dev)
>>  	unsigned int  count_dirty_tx;
>>
>>  	/* Don't transmit data before the complete of auto-negotiation */
>> -	if(!sis_priv->autong_complete){
>> -		netif_stop_queue(net_dev);
>> -		return NETDEV_TX_BUSY;
>> +	if (unlikely(!sis_priv->autong_complete)) {
>> +		if (netif_msg_tx_err(sis_priv) && net_ratelimit())
>> +			printk(KERN_DEBUG "%s: Auto negotiation in progress\n",
>> +					net_dev->name);
>> +		net_dev->stats.tx_dropped++;
>> +		dev_kfree_skb(skb);
>> +		return NETDEV_TX_OK;
>>  	}
>>
>>  	spin_lock_irqsave(&sis_priv->lock, flags);
>
> --
> Ben Hutchings, Staff Engineer, Solarflare
> Not speaking for my employer; that's the marketing department's job.
> They asked us to note that Solarflare product names are trademarked.
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>


-- 
Regards,
Denis
