From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/4] ipv4: Fix pmtu propagating
Date: Tue, 08 Nov 2011 14:19:50 -0500 (EST)
Message-ID: <20111108.141950.1576262997640523669.davem@davemloft.net>
References: <20111017121805.GR1830@secunet.com>
	<4E9E9366.1050702@cn.fujitsu.com>
	<20111019.153208.1743995025598236810.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steffen.klassert@secunet.com, netdev@vger.kernel.org
To: gaofeng@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:43593 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933181Ab1KHTUC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Nov 2011 14:20:02 -0500
In-Reply-To: <20111019.153208.1743995025598236810.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Steffen I look at this specific patch again.

The peer should be found and loaded up, and the PMTU propagated, when
the route cache entry is created.  Specifically rt_init_metrics() will
find any existing peer, and do the whole check_peer_pmtu() sequence
that ipv4_dst_check() does.

If we have some issue with UDP or RAW caching a route past the first
use after the route lookup, yes we have to introduce a dst_check()
call somewhere.

But unilaterally doing this on every CORK setup seems at least very
excessive.  Because CORK setup happens even for single sends.  One
such example is ip_make_skb().

ip_make_skb() is used by, f.e., udp_sendmsg() when corkreq is false.
And in this case 'rt' is used immediately after being looked up
in udp_sendmsg().

And, as far as I can tell, routines like udp_sendmsg() in fact already
handle the "cached route across multiple sendmsg() calls" case too.

Specifically, udp_sendmsg() does this:

	if (connected)
		rt = (struct rtable *)sk_dst_check(sk, 0);

otherwise it makes a completely fresh route lookup.

RAW sendmsg unconditionally makes a fresh route lookup on every
sendmsg call.  So it should be OK too.

So I really fail to see the problematic case.  Therefore, if it exists
you'll have to give me an exact sequence of events that leads to the
problem.

I suspect that your real problem has nothing to do with UDP or RAW,
but rather the issue is that entries already in the routing cache
with a NULL peer need to be refreshed with peer information created
in another context.
