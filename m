From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH net-next 2/9] net: Remove e_inval label from
 ip_route_input_slow
Date: Wed, 23 Sep 2015 09:31:06 -0700
Message-ID: <5602D3CA.7010502@gmail.com>
References: <1443021322-48621-1-git-send-email-dsa@cumulusnetworks.com>
 <1443021322-48621-3-git-send-email-dsa@cumulusnetworks.com>
 <5602C901.2050404@gmail.com> <5602CD17.3030008@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: David Ahern <dsa@cumulusnetworks.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:32825 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752728AbbIWQbI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2015 12:31:08 -0400
Received: by pacex6 with SMTP id ex6so44856662pac.0
        for <netdev@vger.kernel.org>; Wed, 23 Sep 2015 09:31:08 -0700 (PDT)
In-Reply-To: <5602CD17.3030008@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/23/2015 09:02 AM, David Ahern wrote:
> On 9/23/15 9:45 AM, Alexander Duyck wrote:
>> On 09/23/2015 08:15 AM, David Ahern wrote:
>>> e_inval has 1 explicit user and 1 fallthrough user --
>>> martian_destination.
>>> Move setting err to EINVAL before the 2 users and use the goto out 
>>> label
>>> instead of e_inval.
>>>
>>> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
>>> ---
>>>   net/ipv4/route.c | 7 +++----
>>>   1 file changed, 3 insertions(+), 4 deletions(-)
>>>
>>> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
>>> index ef36dfed24da..3c5000db5972 100644
>>> --- a/net/ipv4/route.c
>>> +++ b/net/ipv4/route.c
>>> @@ -1775,8 +1775,9 @@ static int ip_route_input_slow(struct sk_buff
>>> *skb, __be32 daddr, __be32 saddr,
>>>   out:    return err;
>>>   brd_input:
>>> +    err = -EINVAL;
>>>       if (skb->protocol != htons(ETH_P_IP))
>>> -        goto e_inval;
>>> +        goto out;
>>>       if (!ipv4_is_zeronet(saddr)) {
>>>           err = fib_validate_source(skb, saddr, 0, tos, 0, dev,
>>> @@ -1842,15 +1843,13 @@ out:    return err;
>>>        *    Do not cache martian addresses: they should be logged
>>> (RFC1812)
>>>        */
>>>   martian_destination:
>>> +    err = -EINVAL;
>>>       RT_CACHE_STAT_INC(in_martian_dst);
>>>   #ifdef CONFIG_IP_ROUTE_VERBOSE
>>>       if (IN_DEV_LOG_MARTIANS(in_dev))
>>>           net_warn_ratelimited("martian destination %pI4 from %pI4,
>>> dev %s\n",
>>>                        &daddr, &saddr, dev->name);
>>>   #endif
>>> -
>>> -e_inval:
>>> -    err = -EINVAL;
>>>       goto out;
>>>   e_nobufs:
>>
>> This is adding unnecessary bloat to the code.  I really think if you
>> want to simplify this just replace "goto e_inval;" with "return 
>> -EINVAL;".
>
> Not sure why you think this is bloating the code. Before this patch:
>
> $ size kbuild/net/ipv4/route.o
> text data bss dec hex filename
> 19778 2321 32 22131 5673 kbuild/net/ipv4/route.o
>
> With this patch:
> $ size kbuild/net/ipv4/route.o
>    text       data        bss        dec        hex    filename
>   19778       2321         32      22131       5673 
> kbuild/net/ipv4/route.o
>
> So no difference at all.
>
> Please consider this is an intermediate step; the code goes away in 
> later ones.

Total code size for a change this small doesn't tell you anything. The 
fact is you are doubling the number of spots where you are having to 
reinitialize err.  It is the general direction of this I don't like 
since it is just making the code uglier before you attempt to fix it.

>
>>
>> Also why is it you end up leaving the out label through all of these
>> patches?  It seems like that would be one of the first places to start
>> in terms of removing the labels.
>
> jump to return is normal usage. Why would I start there and end up 
> with N exit points? There are a lot of functions in the route code 
> where doing that will burn you.
>

Just as you said, that code would be an intermediate step.  Going though 
and adding more points where you are updating err and just exchanging 
one jump label for another doesn't help anything.  You are better off 
pulling apart the spaghetti right from the start and then rearranging 
the code.  If nothing else it helps to make things more readable.

In a couple of patches from here you are going to have to pull out the 
local_input helper.  Rather than adding a new jump label inside of it 
for out you could save yourself a few steps and just return the error 
values.  If you do this correctly what you should end up with is a 
series of functions that all converge on one end point anyway.

Also as far as the multiple returns issue it isn't much of a problem 
since ip_output_input_slow ends up being compiled into 
ip_route_input_noref anyway.  As such the return statements end up just 
being jumps to the bits for the rcu_read_unlock and returning the error 
value.

- Alex
