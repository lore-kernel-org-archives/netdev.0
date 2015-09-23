From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next 2/9] net: Remove e_inval label from
 ip_route_input_slow
Date: Wed, 23 Sep 2015 10:02:31 -0600
Message-ID: <5602CD17.3030008@cumulusnetworks.com>
References: <1443021322-48621-1-git-send-email-dsa@cumulusnetworks.com>
 <1443021322-48621-3-git-send-email-dsa@cumulusnetworks.com>
 <5602C901.2050404@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Alexander Duyck <alexander.duyck@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:34758 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755726AbbIWQCf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2015 12:02:35 -0400
Received: by padhy16 with SMTP id hy16so44288245pad.1
        for <netdev@vger.kernel.org>; Wed, 23 Sep 2015 09:02:34 -0700 (PDT)
In-Reply-To: <5602C901.2050404@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/23/15 9:45 AM, Alexander Duyck wrote:
> On 09/23/2015 08:15 AM, David Ahern wrote:
>> e_inval has 1 explicit user and 1 fallthrough user --
>> martian_destination.
>> Move setting err to EINVAL before the 2 users and use the goto out label
>> instead of e_inval.
>>
>> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
>> ---
>>   net/ipv4/route.c | 7 +++----
>>   1 file changed, 3 insertions(+), 4 deletions(-)
>>
>> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
>> index ef36dfed24da..3c5000db5972 100644
>> --- a/net/ipv4/route.c
>> +++ b/net/ipv4/route.c
>> @@ -1775,8 +1775,9 @@ static int ip_route_input_slow(struct sk_buff
>> *skb, __be32 daddr, __be32 saddr,
>>   out:    return err;
>>   brd_input:
>> +    err = -EINVAL;
>>       if (skb->protocol != htons(ETH_P_IP))
>> -        goto e_inval;
>> +        goto out;
>>       if (!ipv4_is_zeronet(saddr)) {
>>           err = fib_validate_source(skb, saddr, 0, tos, 0, dev,
>> @@ -1842,15 +1843,13 @@ out:    return err;
>>        *    Do not cache martian addresses: they should be logged
>> (RFC1812)
>>        */
>>   martian_destination:
>> +    err = -EINVAL;
>>       RT_CACHE_STAT_INC(in_martian_dst);
>>   #ifdef CONFIG_IP_ROUTE_VERBOSE
>>       if (IN_DEV_LOG_MARTIANS(in_dev))
>>           net_warn_ratelimited("martian destination %pI4 from %pI4,
>> dev %s\n",
>>                        &daddr, &saddr, dev->name);
>>   #endif
>> -
>> -e_inval:
>> -    err = -EINVAL;
>>       goto out;
>>   e_nobufs:
>
> This is adding unnecessary bloat to the code.  I really think if you
> want to simplify this just replace "goto e_inval;" with "return -EINVAL;".

Not sure why you think this is bloating the code. Before this patch:

$ size kbuild/net/ipv4/route.o
text data bss dec hex filename
19778 2321 32 22131 5673 kbuild/net/ipv4/route.o

With this patch:
$ size kbuild/net/ipv4/route.o
    text	   data	    bss	    dec	    hex	filename
   19778	   2321	     32	  22131	   5673	kbuild/net/ipv4/route.o

So no difference at all.

Please consider this is an intermediate step; the code goes away in 
later ones.

>
> Also why is it you end up leaving the out label through all of these
> patches?  It seems like that would be one of the first places to start
> in terms of removing the labels.

jump to return is normal usage. Why would I start there and end up with 
N exit points? There are a lot of functions in the route code where 
doing that will burn you.
