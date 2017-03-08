From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net-next v2] net: ipv4: add support for ECMP hash policy
 choice
Date: Wed, 8 Mar 2017 14:43:37 +0200
Message-ID: <929a2609-51f8-c385-a727-3f819cf28b4f@cumulusnetworks.com>
References: <878togdldb.fsf@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, davem@davemloft.net,
        roopa@cumulusnetworks.com, dsa@cumulusnetworks.com
To: Jakub Sitnicki <jkbs@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:35094 "EHLO
        mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752095AbdCHMvz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Mar 2017 07:51:55 -0500
Received: by mail-wm0-f50.google.com with SMTP id v186so113954958wmd.0
        for <netdev@vger.kernel.org>; Wed, 08 Mar 2017 04:51:54 -0800 (PST)
In-Reply-To: <878togdldb.fsf@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/03/17 14:05, Jakub Sitnicki wrote:
> Hi Nikolay,
> 
> On Tue, Mar 07, 2017 at 11:01 AM GMT, Nikolay Aleksandrov wrote:
>> This patch adds support for ECMP hash policy choice via a new sysctl
>> called fib_multipath_hash_policy and also adds support for L4 hashes.
>> The current values for fib_multipath_hash_policy are:
>>  0 - layer 3 (default)
>>  1 - layer 4
>> If there's an skb hash already set and it matches the chosen policy then it
>> will be used instead of being calculated. The ICMP inner IP addresses use
>> is removed.
>>
>> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
>> ---
>> v2:
>>  - removed the output_key_hash as it's not needed anymore
>>  - reverted to my original/internal patch with L3 as default hash
> 
> What about ICMP PTB (Fragmentation Needed) forwarding that makes PMTUD
> work with ECMP in setups like described in RFC7690 [1]?
> 
>   ptb -> router ecmp -> next hop L4/L7 load balancer -> destination
> 
>        router --> load balancer 1 --->
>             \\--> load balancer 2 ---> load-balanced service
>              \--> load balancer N --->
> 
> Removing special treatment of ICMP errors will break it, won't it?
> 

Yes, I am aware and this decision was made with that in mind.
We'd like to use the HW hash when available and IIRC that doesn't play well with
special-casing ICMP errors for anycast as it may not match also. Another thing,
again if I remember correctly, was that this behaviour is closer to how hardware
handles ECMP.

One thing we can do is leave the current L3 behaviour with ICMP error handling
and add a new L3 mode that tries to use the skb hash when available and doesn't
care about the packet type.

What do you think ?

> FWIW, I gave a run to your patch (default settings, L3 hash) with a test
> script [2] that simulates such a setup and it confirmed my worries - PTB
> errors don't travel back to the source host any more.

Thanks for testing.

> 
> -Jakub
> 
> [1] https://tools.ietf.org/html/rfc7690#section-2
> [2] https://github.com/jsitnicki/tools/commit/ccb85e68421df4ffd8b7abf00f6f5fe1c6a5af76
> 
