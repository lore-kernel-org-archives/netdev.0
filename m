From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH 1/3 v2] ipv6: do not disable temp_address when reaching
 max_address
Date: Wed, 14 Aug 2013 09:34:22 +0800
Message-ID: <520ADE9E.8070700@huawei.com>
References: <5209E6DA.9060805@huawei.com> <20130813110521.GE27385@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:38379 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758688Ab3HNBfb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Aug 2013 21:35:31 -0400
In-Reply-To: <20130813110521.GE27385@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013/8/13 19:05, Hannes Frederic Sowa wrote:
> On Tue, Aug 13, 2013 at 03:57:14PM +0800, Ding Tianhong wrote:
>> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
>> index da4241c..72911fd 100644
>> --- a/net/ipv6/addrconf.c
>> +++ b/net/ipv6/addrconf.c
>> @@ -1134,10 +1134,27 @@ retry:
>>  	if (IS_ERR_OR_NULL(ift)) {
>>  		in6_ifa_put(ifp);
>>  		in6_dev_put(idev);
>> -		pr_info("%s: retry temporary address regeneration\n", __func__);
>> -		tmpaddr = &addr;
>> -		write_lock(&idev->lock);
>> -		goto retry;
>> +
>> +		/* According RFC4941 3.3.7:
>> +		 * If DAD indicates the address is already in use,
>> +		 * the node must generate a new randomized interface
>> +		 * identifier as described in section 3.2 above, and
>> +		 * repeat the previous steps as appropriate up to
>> +		 * TEMP_IDGEN_RETRIES times.
>> +		 * If after TEMP_IDGEN_RETRIES consecutive attempts no
>> +		 * non-unique address was generated, the node must log
>> +		 * a system error and must not attempt to generate
>> +		 * temporary address for that interface.
>> +		 * So we have to check the return err and distinguish
>> +		 * the correct retry path.
>> +		 */
>> +		if (PTR_ERR(ift) == -EEXIST) {
>> +			pr_info("%s: retry temporary address regeneration\n", __func__);
>> +			tmpaddr = &addr;
>> +			write_lock(&idev->lock);
>> +			goto retry;
>> +		} else
>> +			goto out;
> 
> Correct me if I am wrong, but the RFC referes by mentioning "in use" to
> allocated on the subnet and not in use by this host. I don't see how this
> fixes the CVE then. dad is triggered by ipv6_add_addr.
> 
> Greetings,
> 
>   Hannes
> 
Reference:
  -> http://seclists.org/oss-sec/2012/q4/292
  -> http://seclists.org/oss-sec/2013/q1/92

I think the point is after the ./flood_route26 attack, 
the proc/sys/net/ipv6/conf/iface/use_tempaddr will change from 2 to -1,
whether is correct? :)

regards
Ding Tianhong


> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> .
> 
