From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH] net: ipv6: Truncate single route when it doesn't fit into
 dump buffer.
Date: Sat, 13 May 2017 11:13:38 -0600
Message-ID: <f72f0622-f5d3-6a85-e8e8-15980c9f1f2d@gmail.com>
References: <20170512111510.2697-1-mq@ucw.cz>
 <20170512.112447.1421545301592945998.davem@davemloft.net>
 <3828cf04-1bf8-92d2-dfc4-184bd615fe10@gmail.com>
 <20170512214107.w3q7ycl6wm7phwox@lopatka.joja.cz>
 <6670aa0f-2f07-5afd-7c47-35b006c9b2e7@gmail.com>
 <20170513105401.iaialveoomahrmyq@lopatka.joja.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, mq@ucw.cz,
        netdev@vger.kernel.org, roopa <roopa@cumulusnetworks.com>
To: Jan Moskyto Matejka <mq@jmq.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:33227 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932303AbdEMRNo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 13 May 2017 13:13:44 -0400
Received: by mail-pf0-f195.google.com with SMTP id f27so243790pfe.0
        for <netdev@vger.kernel.org>; Sat, 13 May 2017 10:13:44 -0700 (PDT)
In-Reply-To: <20170513105401.iaialveoomahrmyq@lopatka.joja.cz>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/13/17 4:54 AM, Jan Moskyto Matejka wrote:
>> I see 2 problems:
>> 1. the kernel is not telling the user the supplied buffer is too small
>> (ie., if a single route does not fit in the skb then it should fail and
>> return an error code to the user),
> 
> Definitely. I want just to note that this condition usually occurs
> somewhere during route dump. To know it before starting output, we would 
> have to walk the FIB once before dump to calculate max route len.

When adding a route to the skb, track whether it contains at least 1
route. If not, it means the next route in the dump is larger than the
given buffer. Detect this condition and error out of the dump -
returning an error to the user (-ENOSPC? or EMSGSIZE?)

> 
>> 2. multipath routes for IPv4 and IPv6 do not have a limit.
>>
>> Should the kernel put a limit on the number of nexthops? I recently put
>> a cap on MPLS route size as 4096 bytes, but I think this should be
>> revisited in terms of a limit on number of nexthops to create a
>> consistent limit even if struct sizes change. And, the limit on the
>> number of nexthops should be consistent across address families (same
>> limit for IPv4, IPv6, and MPLS).
>>
>> From discussions I have had, 32 nexthops for a single route is on the
>> laughably high side, but some people do crazy things. How about a limit
>> of 256 nexthops?
> 
> 256 should be OK even for a crazy developer of BIRD.
> 
> It would be nice to have if the returned error were somehow useful for
> the userspace -- to know what is happening, not only something like
> "impossible to add / append route".

Top of tree kernel has extended error reporting so a message can be
returned that says something to the effect of "route size is larger than
supplied buffer size".
