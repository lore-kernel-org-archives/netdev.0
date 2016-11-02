From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v2] ipv4: fib: Replay events when registering
 FIB notifier
Date: Tue, 01 Nov 2016 19:13:42 -0700
Message-ID: <58194BD6.5040406@cumulusnetworks.com>
References: <1477948427-9189-1-git-send-email-idosch@idosch.org> <1477949046.7065.320.camel@edumazet-glaptop3.roam.corp.google.com> <20161031225737.7nfoy4ka3ydzhptq@splinter> <1478009999.7065.334.camel@edumazet-glaptop3.roam.corp.google.com> <5818B146.20209@cumulusnetworks.com> <20161101170345.pq2ewecw35mrurkp@splinter>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
        davem@davemloft.net, jiri@mellanox.com, mlxsw@mellanox.com,
        dsa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
        andy@greyhouse.net, vivien.didelot@savoirfairelinux.com,
        andrew@lunn.ch, f.fainelli@gmail.com, alexander.h.duyck@intel.com,
        kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net, Ido Schimmel <idosch@mellanox.com>
To: Ido Schimmel <idosch@idosch.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:34799 "EHLO
        mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754155AbcKBCNp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Nov 2016 22:13:45 -0400
Received: by mail-pf0-f174.google.com with SMTP id n85so1802096pfi.1
        for <netdev@vger.kernel.org>; Tue, 01 Nov 2016 19:13:45 -0700 (PDT)
In-Reply-To: <20161101170345.pq2ewecw35mrurkp@splinter>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/1/16, 10:03 AM, Ido Schimmel wrote:
> Hi Roopa,
>
> On Tue, Nov 01, 2016 at 08:14:14AM -0700, Roopa Prabhu wrote:
>>
[snip]
>> I have the same concern as Eric here.
>>
>> I understand why you need it, but can the driver request for an initial dump and that
>> dump be made more efficient somehow ie not hold rtnl for the whole dump ?.
>> instead of making the fib notifier registration code doing it.
> We can do what we suggested in the last bi-weekly meeting, which is
> still holding rtnl, but moving the hardware operation to delayed work.
> This is possible because upper layers always assume operation was
> successful and driver is responsible for invoking its abort mechanism in
> case of failure.
>
>> these routing table sizes can be huge and an analogy for this in user-space:
>> We do request a netlink dump of  routing tables at initialization (on driver starts or resets)...
>> but, existing netlink routing table dumps for that scale don't hold rtnl for the whole dump.
>> The dump is split into multiple responses to the user and hence it does not starve other rtnl users.
> In my reply to Eric I mentioned that when we register and unregister
> from this chain the tables aren't really huge, but instead quite small.
> I understand your concerns, but I don't wish to make things more
> complicated than they should be only to address concerns that aren't
> really realistic.

I understand..but, if you are adding some core infrastructure for switchdev ..it cannot be
based on the number of simple use-cases or data you have today.

I won't be surprised if tomorrow other switch drivers have a case where they need to
reset the hw routing table state and reprogram all routes again. Re-registering the notifier to just
get the routing state of the kernel will not scale. For the long term, since the driver does not maintain a cache,
a pull api with efficient use of rtnl will be useful for other such cases as well.


If you don't want to get to the complexity of a new api right away because of the
simple case of management interface routes you have, Can your driver register the notifier early  ?
(I am sure you have probably already thought about this)

>
> I believe current patch is quite simple and also consistent with other
> notification chains in the kernel, such as the netdevice, where rtnl is
> held during replay of events.
> http://lxr.free-electrons.com/source/net/core/dev.c#L1535
as you know, netdev and routing scale are not the same thing.
Looking at the current code for netdevices (replay and rollback on failure),
a pull api (equivalent to the netlink dump api) may end up being less complex...with an
ability to batch in the future.
