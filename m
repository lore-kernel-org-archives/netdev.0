From: Ido Schimmel <idosch@idosch.org>
Subject: Re: [PATCH net-next v2] ipv4: fib: Replay events when registering
 FIB notifier
Date: Tue, 1 Nov 2016 00:57:37 +0200
Message-ID: <20161031225737.7nfoy4ka3ydzhptq@splinter>
References: <1477948427-9189-1-git-send-email-idosch@idosch.org>
 <1477949046.7065.320.camel@edumazet-glaptop3.roam.corp.google.com>
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
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:48076 "EHLO
        out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S947776AbcJaW6N (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Oct 2016 18:58:13 -0400
Content-Disposition: inline
In-Reply-To: <1477949046.7065.320.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 31, 2016 at 02:24:06PM -0700, Eric Dumazet wrote:
> On Mon, 2016-10-31 at 23:13 +0200, idosch@idosch.org wrote:
> > From: Ido Schimmel <idosch@mellanox.com>
> > 
> > When registering a FIB notifier block we should notify the caller of
> > already existing FIB entries and rules, as it would otherwise have an
> > incomplete view of the FIB tables. This is especially important for
> > switchdev drivers that support FIB offloads. Failing to notify them of
> > existing entries may lead to packet loss.
> > 
> > Upon registration, walk the leafs of all the routing tables and for each
> > leaf send notification of existing FIB aliases. Similarly, when
> > unregistering the notifier synthesize a deletion event, thereby
> > relieving potential callers from the need to perform cleanup.
> > 
> > The above is consistent with the netdevice notification chain, where
> > "registration and up events are replayed to the new notifier" upon
> > registration.
> > 
> > Signed-off-by: Ido Schimmel <idosch@mellanox.com>
> > Reviewed-by: Jiri Pirko <jiri@mellanox.com>
> 
> How well will this work for large FIB tables ?
> 
> Holding rtnl while sending thousands of skb will prevent consumers to
> make progress ?

Can you please clarify what do you mean by "while sending thousands of
skb"? This patch doesn't generate notifications to user space, but
instead invokes notification routines inside the kernel. I probably
misunderstood you.

Are you suggesting this be done using RCU instead? Well, there are a
couple of reasons why I took RTNL here:

1) The FIB notification chain is blocking, so listeners are expected to
be able to sleep. This isn't possible if we use RCU. Note that this
chain is mainly useful for drivers that reflect the FIB table into a
capable device and hardware operations usually involve sleeping.

2) The insertion of a single route is done with RTNL held. I didn't want
to differentiate between both cases. This property is really useful for
listeners, as they don't need to worry about locking in writer-side.
Access to data structs is serialized by RTNL.

Thanks for reviewing.
