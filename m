From: subashab@codeaurora.org
Subject: Re: [PATCH net] ipv6: addrconf: Fix recursive spin lock call
Date: Tue, 2 Feb 2016 00:07:46 -0000
Message-ID: <db0e644012c1902f3e0fb3dd0b0a145f.squirrel@www.codeaurora.org>
References: <2cf017eba84341c95d22fda2952a3f6f.squirrel@www.codeaurora.org>
    <1454355454.7627.183.camel@edumazet-glaptop2.roam.corp.google.com>
    <1454355982.7627.185.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "Erik Kline" <ek@google.com>, "Netdev" <netdev@vger.kernel.org>,
	"Hannes Frederic Sowa" <hannes@stressinduktion.org>
To: "Eric Dumazet" <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:38983 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750950AbcBBAHr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Feb 2016 19:07:47 -0500
In-Reply-To: <1454355982.7627.185.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> On Mon, 2016-02-01 at 11:37 -0800, Eric Dumazet wrote:
>
>> I would rather try :
>>
>> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
>> index 38eeddedfc21..d6b7ab07f914 100644
>> --- a/net/ipv6/addrconf.c
>> +++ b/net/ipv6/addrconf.c
>> @@ -3538,6 +3538,7 @@ static void addrconf_dad_begin(struct inet6_ifaddr
>> *ifp)
>>  {
>>  	struct inet6_dev *idev = ifp->idev;
>>  	struct net_device *dev = idev->dev;
>> +	bool notify = false;
>>
>>  	addrconf_join_solict(dev, &ifp->addr);
>>
>> @@ -3583,7 +3584,8 @@ static void addrconf_dad_begin(struct inet6_ifaddr
>> *ifp)
>>  			/* Because optimistic nodes can use this address,
>>  			 * notify listeners. If DAD fails, RTM_DELADDR is sent.
>>  			 */
>> -			ipv6_ifa_notify(RTM_NEWADDR, ifp);
>> +			notify = true;
>> +			in6_ifa_hold(ifp);
>
> Actually the in6_ifa_hold() is not needed.
>
>>  		}
>>  	}
>>
>> @@ -3591,6 +3593,10 @@ static void addrconf_dad_begin(struct
>> inet6_ifaddr *ifp)
>>  out:
>>  	spin_unlock(&ifp->lock);
>>  	read_unlock_bh(&idev->lock);
>> +	if (notify) {
>> +		ipv6_ifa_notify(RTM_NEWADDR, ifp);
>> +		in6_ifa_put(ifp);
>
> And in6_ifa_put() not needed once in6_ifa_hold() is removed.
>
>> +	}
>>  }
>>
>>  static void addrconf_dad_start(struct inet6_ifaddr *ifp)
>>
>>

Thanks Eric. I tested the scenario with your suggestion and I don't see a
RCU stall now. I will send out v2 of this patch.
