From: Chris Friesen <chris.friesen@windriver.com>
Subject: Re: [RFC PATCH] possible bug in handling of ipv4 route caching
Date: Fri, 8 Apr 2016 09:00:51 -0600
Message-ID: <5707C7A3.2040904@windriver.com>
References: <5706B250.1060303@windriver.com> <alpine.LFD.2.11.1604072305400.2154@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:50934 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932725AbcDHPBW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Apr 2016 11:01:22 -0400
In-Reply-To: <alpine.LFD.2.11.1604072305400.2154@ja.home.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/07/2016 03:20 PM, Julian Anastasov wrote:
> On Thu, 7 Apr 2016, Chris Friesen wrote:
>
>> Hi,
>>
>> We think we may have found a bug in the handling of ipv4 route caching,
>> and are curious what you think.
>>
>> For local routes that require a particular output interface we do not
>> want to cache the result.  Caching the result causes incorrect behaviour
>> when there are multiple source addresses on the interface.  The end
>> result being that if the intended recipient is waiting on that interface
>> for the packet he won't receive it because it will be delivered on the
>> loopback interface and the IP_PKTINFO ipi_ifindex will be set to the
>> loopback interface as well.

>> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
>> index 02c6229..e965d4b 100644
>> --- a/net/ipv4/route.c
>> +++ b/net/ipv4/route.c
>> @@ -2045,6 +2045,17 @@ static struct rtable *__mkroute_output(const struct fib_result *res,
>>   		 */
>>   		if (fi && res->prefixlen < 4)
>>   			fi = NULL;
>> +	} else if ((type == RTN_LOCAL) && (orig_oif != 0)) {
>
> 	So, we can be more specific. Can this work?:
>
> 	} else if ((type == RTN_LOCAL) && (orig_oif != 0) &&
> 		   (orig_oif != dev_out->ifindex)) {
>
> 	I.e. we should allow to cache orig_oif=LOOPBACK_IFINDEX
> but eth1 should not be cached.

Yes, we think that will work.  New patch to follow.

Chris
