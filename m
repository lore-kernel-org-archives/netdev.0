From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH]: Dynamically sized routing cache hash table.
Date: Tue, 06 Mar 2007 14:20:55 -0800 (PST)
Message-ID: <20070306.142055.14973231.davem@davemloft.net>
References: <20070305.202632.74752497.davem@davemloft.net>
	<17901.27628.548105.353342@robur.slu.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dada1@cosmosbay.com,
	robert.olsson@its.uu.se, npiggin@suse.de
To: Robert.Olsson@data.slu.se
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54020
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1030384AbXCFWU6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Mar 2007 17:20:58 -0500
In-Reply-To: <17901.27628.548105.353342@robur.slu.se>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Robert Olsson <Robert.Olsson@data.slu.se>
Date: Tue, 6 Mar 2007 14:26:04 +0100

> David Miller writes:
>  
>  > Actually, more accurately, the conflict exists in how this GC
>  > logic is implemented.  The core issue is that hash table size
>  > guides the GC processing, and hash table growth therefore
>  > modifies those GC goals.  So with the patch below we'll just
>  > keep growing the hash table instead of giving GC some time to
>  > try to keep the working set in equilibrium before doing the
>  > hash grow.
>  
>  AFIK the equilibrium is resizing function as well but using fixed 
>  hash table. So can we do without equilibrium resizing if tables 
>  are dynamic?  I think so....
> 
>  With the hash data structure we could monitor the average chain 
>  length or just size and resize hash after that.

I'm not so sure, it may be a mistake to eliminate the equilibrium
logic.  One error I think it does have is the usage of chain length.

Even a nearly perfect hash has small lumps in distribution, and we
should not penalize entries which fall into these lumps.

Let us call T the threshold at which we would grow the routing hash
table.  As we approach T we start to GC.  Let's assume hash table
has shift = 2. and T would (with T=N+(N>>1) algorithm) therefore be
6.

TABLE:	[0]	DST1, DST2
	[1]	DST3, DST4, DST5

DST6 arrives, what should we do?

If we just accept it and don't GC some existing entries, we
will grow the hash table.  This is the wrong thing to do if
our true working set is smaller than 6 entries and thus some
of the existing entries are unlikely to be reused and thus
could be purged to keep us from hitting T.

If they are all active, growing is the right thing to do.

This is the crux of the whole routing cache problem.

I am of the opinion that LRU, for routes not attached to sockets, is
probably the best thing to do here.

Furthermore at high packet rates, the current rt_may_expire() logic
probably is not very effective since it's granularity is limited to
jiffies.  We can quite easily create 100,000 or more entries per
jiffie when HZ=100 during rDOS, for example.  So perhaps some global
LRU algorithm using ktime is more appropriate.

Global LRU is not easy without touching a lot of memory.  But I'm
sure some clever trick can be discovered by someone :)

It is amusing, but it seems that for rDOS workload most optimal
routing hash would be tiny one like my example above.  All packets
essentially miss the routing cache and create new entry.  So
keeping the working set as small as possible is what you want
to do since no matter how large you grow your hit rate will be
zero :-)

