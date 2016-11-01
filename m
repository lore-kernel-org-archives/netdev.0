From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v2] ipv4: fib: Replay events when registering
 FIB notifier
Date: Tue, 01 Nov 2016 08:14:14 -0700
Message-ID: <5818B146.20209@cumulusnetworks.com>
References: <1477948427-9189-1-git-send-email-idosch@idosch.org>  <1477949046.7065.320.camel@edumazet-glaptop3.roam.corp.google.com>  <20161031225737.7nfoy4ka3ydzhptq@splinter> <1478009999.7065.334.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Ido Schimmel <idosch@idosch.org>, netdev@vger.kernel.org,
        davem@davemloft.net, jiri@mellanox.com, mlxsw@mellanox.com,
        dsa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
        andy@greyhouse.net, vivien.didelot@savoirfairelinux.com,
        andrew@lunn.ch, f.fainelli@gmail.com, alexander.h.duyck@intel.com,
        kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net, Ido Schimmel <idosch@mellanox.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:34218 "EHLO
        mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751015AbcKAPV7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Nov 2016 11:21:59 -0400
Received: by mail-pf0-f170.google.com with SMTP id n85so96649113pfi.1
        for <netdev@vger.kernel.org>; Tue, 01 Nov 2016 08:21:59 -0700 (PDT)
In-Reply-To: <1478009999.7065.334.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/1/16, 7:19 AM, Eric Dumazet wrote:
> On Tue, 2016-11-01 at 00:57 +0200, Ido Schimmel wrote:
>> On Mon, Oct 31, 2016 at 02:24:06PM -0700, Eric Dumazet wrote:
>>> How well will this work for large FIB tables ?
>>>
>>> Holding rtnl while sending thousands of skb will prevent consumers to
>>> make progress ?
>> Can you please clarify what do you mean by "while sending thousands of
>> skb"? This patch doesn't generate notifications to user space, but
>> instead invokes notification routines inside the kernel. I probably
>> misunderstood you.
>>
>> Are you suggesting this be done using RCU instead? Well, there are a
>> couple of reasons why I took RTNL here:
>>
> No, I do not believe RCU is wanted here, in control path where we might
> sleep anyway.
>
>> 1) The FIB notification chain is blocking, so listeners are expected to
>> be able to sleep. This isn't possible if we use RCU. Note that this
>> chain is mainly useful for drivers that reflect the FIB table into a
>> capable device and hardware operations usually involve sleeping.
>>
>> 2) The insertion of a single route is done with RTNL held. I didn't want
>> to differentiate between both cases. This property is really useful for
>> listeners, as they don't need to worry about locking in writer-side.
>> Access to data structs is serialized by RTNL.
> My concern was that for large iterations, you might hold RTNL and/or
> current cpu for hundred of ms or even seconds...
>
I have the same concern as Eric here.

I understand why you need it, but can the driver request for an initial dump and that
dump be made more efficient somehow ie not hold rtnl for the whole dump ?.
instead of making the fib notifier registration code doing it.

these routing table sizes can be huge and an analogy for this in user-space:
We do request a netlink dump of  routing tables at initialization (on driver starts or resets)...
but, existing netlink routing table dumps for that scale don't hold rtnl for the whole dump.
The dump is split into multiple responses to the user and hence it does not starve other rtnl users.

In-fact I don't think netlink routing table dumps from user-space hold rtnl_lock for the whole dump.
IIRC this was done to allow route add/dels to be allowed in parallel for performance reasons.
(I will need to double check to confirm this).
