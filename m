From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH] net: ipv6: Truncate single route when it doesn't fit into
 dump buffer.
Date: Sat, 13 May 2017 00:52:47 -0600
Message-ID: <6670aa0f-2f07-5afd-7c47-35b006c9b2e7@gmail.com>
References: <20170512111510.2697-1-mq@ucw.cz>
 <20170512.112447.1421545301592945998.davem@davemloft.net>
 <3828cf04-1bf8-92d2-dfc4-184bd615fe10@gmail.com>
 <20170512214107.w3q7ycl6wm7phwox@lopatka.joja.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, mq@ucw.cz,
        netdev@vger.kernel.org, roopa <roopa@cumulusnetworks.com>
To: Jan Moskyto Matejka <mq@jmq.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:33449 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750935AbdEMGxF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 13 May 2017 02:53:05 -0400
Received: by mail-pg0-f68.google.com with SMTP id s62so10151884pgc.0
        for <netdev@vger.kernel.org>; Fri, 12 May 2017 23:53:05 -0700 (PDT)
In-Reply-To: <20170512214107.w3q7ycl6wm7phwox@lopatka.joja.cz>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/12/17 3:41 PM, Jan Moskyto Matejka wrote:
> On Fri, May 12, 2017 at 10:26:08AM -0700, David Ahern wrote:
>> On 5/12/17 8:24 AM, David Miller wrote:
>>> From: Jan Moskyto Matejka <mq@ucw.cz>
>>> Date: Fri, 12 May 2017 13:15:10 +0200
>>>
>>>> -int rt6_dump_route(struct rt6_info *rt, void *p_arg);
>>>> +int rt6_dump_route(struct rt6_info *rt, void *p_arg, int truncate);
>>>
>>> Please use "bool" and "true"/"false" for boolean values.
>>>
>>> What does ipv4 do in this situation?
>>>
>>> I'm hesitant to be OK with adding a new nlmsg flag just for this case
>>> if we solve this problem differently and using existing mechanisms
>>> elsewhere.
>>>
>>
>> I'll take a look at this later today or this weekend; we can't just
>> truncate the route returned to userspace.
> 
> Agreed. My favourite would be skb realloc somewhere inside the dump loop
> ... but I don't know whether it's feasible.
> 
> MQ
> 

Here is what is happening: user initiates a route dump and specifies a
buffer size for receiving the message which becomes max_recvmsg_len.
This buffer size dictates the skb length allocated by netlink_dump.

The dump is interrupted when a route does not fit in the skb and
returns. Subsequent call picks up with the next route to be dumped - the
one that overflowed. All good and normal so far.

If the next route is larger than max_recvmsg_len, then the route can not
be put in the buffer, nothing is returned to the user which causes the
dump to abort showing the abbreviated output. This problem occurs with
IPv4 and IPv6. You can see this with modest size routes by just dropping
the buffer size to something really small (e.g., with iproute2, change
buf size in rtnl_dump_filter_l to say 2048).

I see 2 problems:
1. the kernel is not telling the user the supplied buffer is too small
(ie., if a single route does not fit in the skb then it should fail and
return an error code to the user),

2. multipath routes for IPv4 and IPv6 do not have a limit.

Should the kernel put a limit on the number of nexthops? I recently put
a cap on MPLS route size as 4096 bytes, but I think this should be
revisited in terms of a limit on number of nexthops to create a
consistent limit even if struct sizes change. And, the limit on the
number of nexthops should be consistent across address families (same
limit for IPv4, IPv6, and MPLS).

>From discussions I have had, 32 nexthops for a single route is on the
laughably high side, but some people do crazy things. How about a limit
of 256 nexthops?
