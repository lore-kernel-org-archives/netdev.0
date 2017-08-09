From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/7] rtnetlink: allow to run selected handlers
 without rtnl
Date: Tue, 08 Aug 2017 21:33:29 -0700 (PDT)
Message-ID: <20170808.213329.522107918983433411.davem@davemloft.net>
References: <20170808160236.28562-1-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60540 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751314AbdHIEdb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2017 00:33:31 -0400
In-Reply-To: <20170808160236.28562-1-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Tue,  8 Aug 2017 18:02:29 +0200

> Unfortunately RTNL mutex is a performance issue, e.g. a cpu adding
> an ip address prevents other cpus from seemingly unrelated tasks
> such as dumping tc classifiers.

It is related if somehow the TC entries refer to IP addresses.

Someone could create something like that.

> Initial no-rtnl spots are ip6 fib add/del and netns new/getid.

I could see the netns stuff being ok, but IPv6 route add/del I'm
not so sure of.

Because of things like nexthops etc. there are dependencies on
other configuration things.

That's the whole reason we have this unfortunate global
synchronization point.  If I'm changing some aspect of network
configuration, I know I can atomically test any piece of networking
configuration state.

If I test a network address to make sure I can properly reacy X and
use X as a nexthop in the route I'm adding, it will be there
throughout the entire operation.

There really is a hierachy of these dependencies.  Device state, up
to neighbour table state, up to protocol address state, up to routes,
up to FIB tables, etc. etc. etc.

I'd really like to make this operate more freely, but this is an
extremely delicate area which has been bottled up like this for
two decades so good luck :-)
