From: David Miller <davem@davemloft.net>
Subject: Re: Possible DoS with 6RD border relay
Date: Thu, 05 Jan 2012 14:20:54 -0500 (EST)
Message-ID: <20120105.142054.318495253662798509.davem@davemloft.net>
References: <1325699600.2428.39.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<201201041326.04403.bcook@breakingpoint.com>
	<201201042222.53147.bcook@breakingpoint.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: bcook@breakingpoint.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:33876 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755357Ab2AETVF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jan 2012 14:21:05 -0500
In-Reply-To: <201201042222.53147.bcook@breakingpoint.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Brent Cook <bcook@breakingpoint.com>
Date: Wed, 4 Jan 2012 22:22:52 -0600

> Is this expected behavior? All of the peers in this case are really the same 
> 6RD client - it's really simulating a customer edge router with a few thousand 
> hosts behind it. I suspect that adding a static route entry for the CE's 
> prefix via 'sit' will also make the problem go away.

Any route which refers to more than one exact host as the destination must
be cloned or COW'd.

This is so that we can provide unique metrics for the destination, as
well as a unique neighbour for the nexthop.

In your case, the keys used to lookup the nexthop for all of these
routes must be different, otherwise you wouldn't hit the neighbour
table limits.  Since if they were all the same we'd find an existing
neighbour entry and just bump it's reference count.

Longer term I intend to make the ipv4 and ipv6 routes not take a
reference to the neighbour entries.  The neighbour entries will be
"refcount-less", and only we'll just use the neighbour entry at packet
output time using a low latency fast lookup inside of a tight RCU
protected code sequence.

So all of this "neighbour table overflow" crap will just disappear.
