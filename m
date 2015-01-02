From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 00/17] fib_trie: Reduce time spent in
 fib_table_lookup by 35 to 75%
Date: Fri, 02 Jan 2015 15:34:04 -0500 (EST)
Message-ID: <20150102.153404.69412302713934264.davem@davemloft.net>
References: <54A4B1D4.1030506@gmail.com>
	<20150101.210841.1269406605009943743.davem@davemloft.net>
	<54A6C710.6000702@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck@redhat.com, netdev@vger.kernel.org
To: alexander.duyck@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52619 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751631AbbABUeL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jan 2015 15:34:11 -0500
In-Reply-To: <54A6C710.6000702@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Fri, 02 Jan 2015 08:28:00 -0800

> I'm hoping that growing smaller nodes will help offset the fact that we
> have to restrict the larger nodes.  For backtracing these large nodes
> come at a significant price as each bit value beyond what can be fit in
> a cache-line means one additional cache line being read when
> backtracking.  So for example two 3 bit nodes on 64b require 4
> cache-lines when backtracking an all 1s value, but one 6 bit node will
> require reading 5 cache-lines.

If you load a full BGP table into fib_trie you will notice that
basically what it does is degenerate into what is essentially a trie
of huge hash tables.  Largest will be the root node.

So a good test would be loading a sample full BGP table into fib_trie,
then iterate randomly choosing 15 or so routes to remove then re-add
over and over again.  This would simulate route flaps, and you can
check to see how much deeper the trie is with your changes added.

> Also I hope to reduce the memory accesses/dependencies to half of what
> they currently are so hopefully the two will offset each other in the
> case where there were performance gains from having nodes larger than
> 256B that cannot reach the necessary value to inflate after the change. 
> If nothing else I figure I can tune the utilization values based on the
> truesize so that we get the best memory utilization/performance ratio. 
> If necessary I might relax the value from the 50% it is now as we pretty
> much have to be all full nodes in order to inflate based on the truesize
> beyond 256B.

See above.
