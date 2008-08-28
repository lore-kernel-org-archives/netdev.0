From: David Miller <davem@davemloft.net>
Subject: Re: cat /proc/net/tcp takes 0.5 seconds on x86_64
Date: Wed, 27 Aug 2008 23:51:58 -0700 (PDT)
Message-ID: <20080827.235158.187658055.davem@davemloft.net>
References: <20080827144800.5f9fc5b4@extreme>
	<20080827.150955.118944272.davem@davemloft.net>
	<48B643C3.9040502@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, andi@firstfloor.org, davej@redhat.com,
	netdev@vger.kernel.org, j.w.r.degoede@hhs.nl
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33551
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752466AbYH1GwD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Aug 2008 02:52:03 -0400
In-Reply-To: <48B643C3.9040502@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Thu, 28 Aug 2008 08:20:51 +0200

> But for route cache, it is probably doable since we added the
> rt_genid thing in commit 29e75252da20f3ab9e132c68c9aed156b87beae6
> ([IPV4] route cache: Introduce rt_genid for smooth cache
> invalidation)
>
> If we add a hash table for each "struct net"
> (net->ipv4.rt_hash_table), we then could do something sensible when
> an admin writes to /proc/sys/net/ipv4/route/hash_size or at
> rt_check_expire() time, if hash table is found to be full...

The synchronization and implementation is not a problem for
the route cache, I implemented this eons ago.

> 3) In rt_check_expire(), adds some metrics to trigger an expand of the
>   hash table in case we found too many entries in it.

This is the problem and why I didn't just commit the patch I had back
then.

We could not define a reasonable way to trigger hash table growth.

GC attempts to keep a resident set of entries in the cache, and these
heuristics are guided by the table size itself.  So if you grow the
table too aggressively this never has a chance to work.

You want to respond dynamically to traffic in a reasonable amount of
time, but you don't want to get tricked by bursts of RCU effects.

We never came up with an algorithm that addresses all of these
issues.
