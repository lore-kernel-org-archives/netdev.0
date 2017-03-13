From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] net: ipv4: add support for ECMP hash
 policy choice
Date: Sun, 12 Mar 2017 19:23:44 -0700 (PDT)
Message-ID: <20170312.192344.17660738044891310.davem@davemloft.net>
References: <929a2609-51f8-c385-a727-3f819cf28b4f@cumulusnetworks.com>
        <8760jjep2y.fsf@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nikolay@cumulusnetworks.com, netdev@vger.kernel.org,
        edumazet@google.com, roopa@cumulusnetworks.com,
        dsa@cumulusnetworks.com
To: jkbs@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:47562 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933046AbdCMCXv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 12 Mar 2017 22:23:51 -0400
In-Reply-To: <8760jjep2y.fsf@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jakub Sitnicki <jkbs@redhat.com>
Date: Wed, 08 Mar 2017 17:00:05 +0100

> On Wed, Mar 08, 2017 at 12:43 PM GMT, Nikolay Aleksandrov wrote:
>> On 08/03/17 14:05, Jakub Sitnicki wrote:
>>> On Tue, Mar 07, 2017 at 11:01 AM GMT, Nikolay Aleksandrov wrote:
>>>> This patch adds support for ECMP hash policy choice via a new sysctl
>>>> called fib_multipath_hash_policy and also adds support for L4 hashes.
>>>> The current values for fib_multipath_hash_policy are:
>>>>  0 - layer 3 (default)
>>>>  1 - layer 4
>>>> If there's an skb hash already set and it matches the chosen policy then it
>>>> will be used instead of being calculated. The ICMP inner IP addresses use
>>>> is removed.
>>>>
>>>> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
>>>> ---
>>>> v2:
>>>>  - removed the output_key_hash as it's not needed anymore
>>>>  - reverted to my original/internal patch with L3 as default hash
>>> 
>>> What about ICMP PTB (Fragmentation Needed) forwarding that makes PMTUD
>>> work with ECMP in setups like described in RFC7690 [1]?
>>> 
>>>   ptb -> router ecmp -> next hop L4/L7 load balancer -> destination
>>> 
>>>        router --> load balancer 1 --->
>>>             \\--> load balancer 2 ---> load-balanced service
>>>              \--> load balancer N --->
>>> 
>>> Removing special treatment of ICMP errors will break it, won't it?
>>> 
>>
>> Yes, I am aware and this decision was made with that in mind.
>> We'd like to use the HW hash when available and IIRC that doesn't play well with
>> special-casing ICMP errors for anycast as it may not match also. Another thing,
>> again if I remember correctly, was that this behaviour is closer to how hardware
>> handles ECMP.
> 
> OK, I wanted to make sure that is not an oversight that ECMP routing in
> ipv4 stack is to be dumbed down to match the hardware behavior. I
> thought that it was an advantage that we want to have over hardware
> routers. (To be fair, I should mention that we don't have it in ipv6
> stack ATM.)
> 
>>
>> One thing we can do is leave the current L3 behaviour with ICMP error handling
>> and add a new L3 mode that tries to use the skb hash when available and doesn't
>> care about the packet type.
>>
>> What do you think ?
> 
> Sounds good to me. Would be good to hear other opinions also.

This would be so much less of an issue with symmetric hashing.  A quick glance
seems to indicate that Microsoft didn't specify the Toeplitz hash to order the
ports and the addresses so that it would be symmetric, so we can guess what
every piece of hardware out there computing a hash does :-/

We could solve this ICMP problem by using a symmetric hash (flow
dissector already supports this), but then we're back to the problem
that this behaves differently from card computed hashes and hardware
offload of ECMP.

I have to say that losing this ICMP handling makes the current code a
non-starter.  The existing code explicitly was written to handle this
case properly, so just undoing it and making it stop working is not
really something we can do.
