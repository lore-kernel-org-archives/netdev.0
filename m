From: Ido Schimmel <idosch@idosch.org>
Subject: Re: [PATCH net-next v2] ipv4: fib: Replay events when registering
 FIB notifier
Date: Tue, 1 Nov 2016 17:44:16 +0200
Message-ID: <20161101154416.znguyy5srs6vy4xy@splinter>
References: <1477948427-9189-1-git-send-email-idosch@idosch.org>
 <1477949046.7065.320.camel@edumazet-glaptop3.roam.corp.google.com>
 <20161031225737.7nfoy4ka3ydzhptq@splinter>
 <1478009999.7065.334.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, jiri@mellanox.com,
        mlxsw@mellanox.com, roopa@cumulusnetworks.com,
        dsa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
        andy@greyhouse.net, vivien.didelot@savoirfairelinux.com,
        andrew@lunn.ch, f.fainelli@gmail.com, alexander.h.duyck@intel.com,
        kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net, Ido Schimmel <idosch@mellanox.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:49341 "EHLO
        out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750764AbcKAPoU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Nov 2016 11:44:20 -0400
Content-Disposition: inline
In-Reply-To: <1478009999.7065.334.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 01, 2016 at 07:19:59AM -0700, Eric Dumazet wrote:
> On Tue, 2016-11-01 at 00:57 +0200, Ido Schimmel wrote:
> > On Mon, Oct 31, 2016 at 02:24:06PM -0700, Eric Dumazet wrote:
> 
> > > How well will this work for large FIB tables ?
> > > 
> > > Holding rtnl while sending thousands of skb will prevent consumers to
> > > make progress ?
> > 
> > Can you please clarify what do you mean by "while sending thousands of
> > skb"? This patch doesn't generate notifications to user space, but
> > instead invokes notification routines inside the kernel. I probably
> > misunderstood you.
> > 
> > Are you suggesting this be done using RCU instead? Well, there are a
> > couple of reasons why I took RTNL here:
> > 
> 
> No, I do not believe RCU is wanted here, in control path where we might
> sleep anyway.
> 
> > 1) The FIB notification chain is blocking, so listeners are expected to
> > be able to sleep. This isn't possible if we use RCU. Note that this
> > chain is mainly useful for drivers that reflect the FIB table into a
> > capable device and hardware operations usually involve sleeping.
> > 
> > 2) The insertion of a single route is done with RTNL held. I didn't want
> > to differentiate between both cases. This property is really useful for
> > listeners, as they don't need to worry about locking in writer-side.
> > Access to data structs is serialized by RTNL.
> 
> My concern was that for large iterations, you might hold RTNL and/or
> current cpu for hundred of ms or even seconds...

I understand your concern, but I think it's helpful to look at the users
of this API. It was only recently introduced [1] because nobody needed
it beside switch drivers that reflect the FIB table and I believe it'll
stay that way. Currently, only mlxsw and rocker use it.

Now, in these use cases when register_fib_notifier() is called the
switch ports are still not present in the system, so we really only have
a few routes used for management. Similarly, when
unregister_fib_notifier() is called, the switch ports are already gone
and most FIBs were flushed due to NETDEV_UNREGISTER, so again we only
have a handful of FIBs to iterate over.

Does that sound reasonable to you?

1. https://www.spinics.net/lists/netdev/msg397444.html
