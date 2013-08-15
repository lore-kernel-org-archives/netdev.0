From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH 1/3 v4] ipv6: do not disable temp_address when reaching
 max_address
Date: Thu, 15 Aug 2013 08:43:06 +0800
Message-ID: <520C241A.2030708@huawei.com>
References: <520B48AE.8050103@huawei.com> <20130814101511.GC16264@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Jon Maloy <jon.maloy@ericsson.com>,
	Eric Dumazet <edumazet@google.com>,
	Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:21792 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758417Ab3HOAn5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Aug 2013 20:43:57 -0400
In-Reply-To: <20130814101511.GC16264@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013/8/14 18:15, Hannes Frederic Sowa wrote:
> On Wed, Aug 14, 2013 at 05:06:54PM +0800, Ding Tianhong wrote:
>> A LAN user can remotely disable temporary address which may lead
>> to privacy violatins and information disclosure.
>>
>> The reason is that the linux kernel uses the 'ipv6.max_addresses'
>> option to specify how many ipv6 addresses and interface may have.
>> The 'ipv6.regen_max_retry' (default value 3) option specifies
>> how many times the kernel will try to create a new address.
>>
>> But the kernel is not distinguish between the event of reaching
>> max_addresses for an interface and failing to generate a new address.
>> the kernel disable the temporary address after regenerate a new
>> address 'regen_max_retry' times.
>>
>> According RFC4941 3.3.7:
>>
>> ---------------------------------------
>>
>> If DAD indicates the address is already in use,
>> the node must generate a new randomized interface
>> identifier as described in section 3.2 above, and
>> repeat the previous steps as appropriate up to
>> TEMP_IDGEN_RETRIES times.
>>
>> If after TEMP_IDGEN_RETRIES consecutive attempts no
>> non-unique address was generated, the node must log
>> a system error and must not attempt to generate
>> temporary address for that interface.
>>
>> ------------------------------------------
>>
>> RFC4941 3.3.7 specifies that disabling the temp_address must happen
>> upon the address is already in use, not reach the max_address,
>> So we have to check the return err and distinguish the correct retry path.
>>
>> This fixes CVE-2013-0343
> 
> I don't think this patch fixes CVE-2013-0343.
> 
>>
>> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
>> Tested-by: Wang Weidong <wangweidong1@huawei.com>
>> Cc: David S. Miller <davem@davemloft.net>
>> Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
>> Cc: Eric Dumazet <edumazet@google.com>
>> ---
>>  net/ipv6/addrconf.c | 26 ++++++++++++++++++++++----
>>  1 file changed, 22 insertions(+), 4 deletions(-)
>>
>> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
>> index da4241c..7b55464 100644
>> --- a/net/ipv6/addrconf.c
>> +++ b/net/ipv6/addrconf.c
>> @@ -1134,10 +1134,28 @@ retry:
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
> 
> -EEXIST is not the same as "ipv6 address is is already used on the
> subnet". I really don't see the point here. IMHO this breaks the intended
> regeneration logic.
> 
> I fear a fix of CVE-2013-0343 will be a bit more complicated. ;) I give it a
> thought.
> 
> Greetings,
> 
>   Hannes
> 
> 
ok, thanks for your feedback, I'll waiting you for more information to fix the problem.:)

> .
> 
