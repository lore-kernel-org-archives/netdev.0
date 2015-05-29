From: Josh Hunt <johunt@akamai.com>
Subject: Re: [PATCH v2] ipv6: Fix protocol resubmission
Date: Fri, 29 May 2015 16:43:31 -0500
Message-ID: <5568DD83.8020600@akamai.com>
References: <1432929886-14259-1-git-send-email-johunt@akamai.com> <5568CBCC.1080503@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tom@herbertland.com
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from prod-mail-xrelay02.akamai.com ([72.246.2.14]:41956 "EHLO
	prod-mail-xrelay02.akamai.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756266AbbE2Vnd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2015 17:43:33 -0400
In-Reply-To: <5568CBCC.1080503@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/29/2015 03:27 PM, Sergei Shtylyov wrote:
> Hello.
>
> On 05/29/2015 11:04 PM, Josh Hunt wrote:
>
>> I came across this problem while trying to use UDP encapsulation with
>> IPv6. The
>> change below fixes that, but it was not immediately apparent if there
>> are any
>> other protocols relying on this broken behavior. FWIW the behavior
>> below now
>> matches IPv4.
>
>> Josh
>
>     Need "Signed-off-by:" line insted of this.
>
>> v2: Actually sets nexthdr so we can use it ;)
>
>     Normally goes after ---, not before.
>
>> ---
>
>> UDP encapsulation is broken on IPv6 because it expects when it returns
>> a negative
>> value that the packet will be resubmitted to the stack with the
>> handler corresponding
>> to the return value. The check currently looks for return values > 0
>> and then resubmits.
>
>> This patch fixes that check and also moves the resubmit label to take
>> advantage of
>> the return code identifying the next protocol we want to process.
>
>> Signed-off-by: Josh Hunt <johunt@akamai.com>
>> ---
>>   net/ipv6/ip6_input.c |    7 ++++---
>>   1 file changed, 4 insertions(+), 3 deletions(-)
>
>> diff --git a/net/ipv6/ip6_input.c b/net/ipv6/ip6_input.c
>> index f2e464e..e16c289 100644
>> --- a/net/ipv6/ip6_input.c
>> +++ b/net/ipv6/ip6_input.c
> [...]
>> @@ -246,9 +246,10 @@ resubmit:
>>               goto discard;
>>
>>           ret = ipprot->handler(skb);
>> -        if (ret > 0)
>> +        if (ret < 0) {
>> +            nexthdr = -ret;
>>               goto resubmit;
>> -        else if (ret == 0)
>> +        } else if (ret == 0)
>>               IP6_INC_STATS_BH(net, idev, IPSTATS_MIB_INDELIVERS);
>
>     The CodingStyle dictates that all branches must have {} if at least
> one has them.

Thanks Sergei, I appreciate the review. I will make these changes in a 
v3 after I get feedback this is the correct fix for the problem.

Josh
