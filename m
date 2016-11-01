From: Ido Schimmel <idosch@idosch.org>
Subject: Re: [PATCH net-next v2] ipv4: fib: Replay events when registering
 FIB notifier
Date: Tue, 1 Nov 2016 19:03:45 +0200
Message-ID: <20161101170345.pq2ewecw35mrurkp@splinter>
References: <1477948427-9189-1-git-send-email-idosch@idosch.org>
 <1477949046.7065.320.camel@edumazet-glaptop3.roam.corp.google.com>
 <20161031225737.7nfoy4ka3ydzhptq@splinter>
 <1478009999.7065.334.camel@edumazet-glaptop3.roam.corp.google.com>
 <5818B146.20209@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
        davem@davemloft.net, jiri@mellanox.com, mlxsw@mellanox.com,
        dsa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
        andy@greyhouse.net, vivien.didelot@savoirfairelinux.com,
        andrew@lunn.ch, f.fainelli@gmail.com, alexander.h.duyck@intel.com,
        kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net, Ido Schimmel <idosch@mellanox.com>
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:49087 "EHLO
        out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750940AbcKARDs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Nov 2016 13:03:48 -0400
Content-Disposition: inline
In-Reply-To: <5818B146.20209@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Roopa,

On Tue, Nov 01, 2016 at 08:14:14AM -0700, Roopa Prabhu wrote:
> On 11/1/16, 7:19 AM, Eric Dumazet wrote:
> > On Tue, 2016-11-01 at 00:57 +0200, Ido Schimmel wrote:
> >> On Mon, Oct 31, 2016 at 02:24:06PM -0700, Eric Dumazet wrote:
> >>> How well will this work for large FIB tables ?
> >>>
> >>> Holding rtnl while sending thousands of skb will prevent consumers to
> >>> make progress ?
> >> Can you please clarify what do you mean by "while sending thousands of
> >> skb"? This patch doesn't generate notifications to user space, but
> >> instead invokes notification routines inside the kernel. I probably
> >> misunderstood you.
> >>
> >> Are you suggesting this be done using RCU instead? Well, there are a
> >> couple of reasons why I took RTNL here:
> >>
> > No, I do not believe RCU is wanted here, in control path where we might
> > sleep anyway.
> >
> >> 1) The FIB notification chain is blocking, so listeners are expected to
> >> be able to sleep. This isn't possible if we use RCU. Note that this
> >> chain is mainly useful for drivers that reflect the FIB table into a
> >> capable device and hardware operations usually involve sleeping.
> >>
> >> 2) The insertion of a single route is done with RTNL held. I didn't want
> >> to differentiate between both cases. This property is really useful for
> >> listeners, as they don't need to worry about locking in writer-side.
> >> Access to data structs is serialized by RTNL.
> > My concern was that for large iterations, you might hold RTNL and/or
> > current cpu for hundred of ms or even seconds...
> >
> I have the same concern as Eric here.
> 
> I understand why you need it, but can the driver request for an initial dump and that
> dump be made more efficient somehow ie not hold rtnl for the whole dump ?.
> instead of making the fib notifier registration code doing it.

We can do what we suggested in the last bi-weekly meeting, which is
still holding rtnl, but moving the hardware operation to delayed work.
This is possible because upper layers always assume operation was
successful and driver is responsible for invoking its abort mechanism in
case of failure.

> these routing table sizes can be huge and an analogy for this in user-space:
> We do request a netlink dump of  routing tables at initialization (on driver starts or resets)...
> but, existing netlink routing table dumps for that scale don't hold rtnl for the whole dump.
> The dump is split into multiple responses to the user and hence it does not starve other rtnl users.

In my reply to Eric I mentioned that when we register and unregister
from this chain the tables aren't really huge, but instead quite small.
I understand your concerns, but I don't wish to make things more
complicated than they should be only to address concerns that aren't
really realistic.

I believe current patch is quite simple and also consistent with other
notification chains in the kernel, such as the netdevice, where rtnl is
held during replay of events.
http://lxr.free-electrons.com/source/net/core/dev.c#L1535
