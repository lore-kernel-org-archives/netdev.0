From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: Re: RFC: [PATCH 2/3] netdevice: Fix promiscuity and allmulti overflow
Date: Mon, 16 Jun 2008 17:51:21 +0800
Message-ID: <48563799.4080200@cn.fujitsu.com>
References: <48562F45.3040302@cn.fujitsu.com> <4856349C.70201@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	NETDEV <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:63275 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1756613AbYFPJzI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Jun 2008 05:55:08 -0400
In-Reply-To: <4856349C.70201@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy said the following on 2008-6-16 17:38:
> Wang Chen wrote:
>> diff --git a/net/core/dev.c b/net/core/dev.c
>> index 5829630..a3c692d 100644
>> --- a/net/core/dev.c
>> +++ b/net/core/dev.c
>> @@ -2753,10 +2753,20 @@ static void __dev_set_promiscuity(struct
>> net_device *dev, int inc)
>>  
>>      ASSERT_RTNL();
>>  
>> +    dev->flags |= IFF_PROMISC;
>>      if ((dev->promiscuity += inc) == 0)
>> -        dev->flags &= ~IFF_PROMISC;
>> -    else
>> -        dev->flags |= IFF_PROMISC;
>> +        /*
>> +         * Avoid overflow.
>> +         * If inc causes overflow, ignore it and warn user.
>> +         */
>> +        if (inc < 0)
>> +            dev->flags &= ~IFF_PROMISC;
>> +        else {
>> +            dev->promiscuity -= inc;
>> +            printk(KERN_ERR "%s: promiscuity touches roof, "
>> +                "set promiscuity failed, promiscuity feature "
>> +                "of device will be broken.\n");
>> +        }
> 
> Additional parens around the inner block would make this more
> readable.
> 

Will fix.

> I question the need for this though, userspace can only trigger
> an increase/decrease by one no matter how often it enables
> the ALLMULTI/PROMISC flags, and I doubt any codepath in the
> kernel would lead to an overflow.
> 

How about mif6_add()?
Do we have a limit for mif6?

> If this can really happen it would be better to leave the
> counter untouched and return an error, we already have too
> many device operations that might fail more or less silently.
> 

This can be done.

