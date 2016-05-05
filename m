From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next 03/13] net: l3mdev: Allow send on enslaved
 interface
Date: Thu, 5 May 2016 08:50:15 -0600
Message-ID: <572B5DA7.1040504@cumulusnetworks.com>
References: <1462419210-10463-1-git-send-email-dsa@cumulusnetworks.com>
 <1462419210-10463-4-git-send-email-dsa@cumulusnetworks.com>
 <alpine.LFD.2.11.1605051026380.2118@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f170.google.com ([209.85.213.170]:36839 "EHLO
	mail-ig0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757359AbcEEOuY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 May 2016 10:50:24 -0400
Received: by mail-ig0-f170.google.com with SMTP id u10so17712471igr.1
        for <netdev@vger.kernel.org>; Thu, 05 May 2016 07:50:23 -0700 (PDT)
In-Reply-To: <alpine.LFD.2.11.1605051026380.2118@ja.home.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/5/16 1:40 AM, Julian Anastasov wrote:
>> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
>> index 8c8c655bb2c4..a1f2830d8110 100644
>> --- a/net/ipv4/route.c
>> +++ b/net/ipv4/route.c
>> @@ -2146,6 +2146,7 @@ struct rtable *__ip_route_output_key_hash(struct net *net, struct flowi4 *fl4,
>>   	unsigned int flags = 0;
>>   	struct fib_result res;
>>   	struct rtable *rth;
>> +	int master_idx;
>>   	int orig_oif;
>>   	int err = -ENETUNREACH;
>>
>> @@ -2155,6 +2156,9 @@ struct rtable *__ip_route_output_key_hash(struct net *net, struct flowi4 *fl4,
>>
>>   	orig_oif = fl4->flowi4_oif;
>>
>> +	master_idx = l3mdev_master_ifindex_by_index(net, fl4->flowi4_oif);
>> +	if (master_idx)
>> +		fl4->flowi4_oif = master_idx;
>
> 	Changing the flowi4_oif at this point can have
> bad effects. I remember for recent commit for  __mkroute_output
> where the route caching is disabled if traffic is redirected
> to loopback. I think, such change can affect the route
> caching, for example, now we use nexthop on master_idx to
> cache routes for orig_oif. Such problems with the caching
> in the past always caused lookups to return wrong cached result
> for other users. But this is only my fears, I don't know
> the actual result of this change. May be you are trying to
> change flowi4_oif at one place instead of every caller.

Yes. VRFs require the oif to be the master index so that the FIB rules 
direct the lookup to the proper table. Without it we get the wrong result.
