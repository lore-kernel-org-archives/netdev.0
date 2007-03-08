From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: [RFC PATCH]: Dynamically sized routing cache hash table.
Date: Thu, 8 Mar 2007 14:35:40 +0100
Message-ID: <17904.4396.166208.95270@robur.slu.se>
References: <20070305.202632.74752497.davem@davemloft.net>
	<17901.27628.548105.353342@robur.slu.se>
	<20070306.142055.14973231.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert.Olsson@data.slu.se, netdev@vger.kernel.org,
	dada1@cosmosbay.com, robert.olsson@its.uu.se, npiggin@suse.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.slu.se ([130.238.96.70]:35498 "EHLO mx1.slu.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751771AbXCHNhQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Mar 2007 08:37:16 -0500
In-Reply-To: <20070306.142055.14973231.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


David Miller writes:

 > Even a nearly perfect hash has small lumps in distribution, and we
 > should not penalize entries which fall into these lumps.
 > 
 > Let us call T the threshold at which we would grow the routing hash
 > table.  As we approach T we start to GC.  Let's assume hash table
 > has shift = 2. and T would (with T=N+(N>>1) algorithm) therefore be
 > 6.
 > 
 > TABLE:	[0]	DST1, DST2
 > 	[1]	DST3, DST4, DST5
 > 
 > DST6 arrives, what should we do?
 > 
 > If we just accept it and don't GC some existing entries, we
 > will grow the hash table.  This is the wrong thing to do if
 > our true working set is smaller than 6 entries and thus some
 > of the existing entries are unlikely to be reused and thus
 > could be purged to keep us from hitting T.
 > 
 > If they are all active, growing is the right thing to do.
 > 
 > This is the crux of the whole routing cache problem.
 
 Yes it very complex... I would be better to have GC processes
 datastructure more independent at least for us mortals.
 With the unicahe I was trying to achive something like this:

 Datastructure pretty independent and optimal wrt inserts and 
 deletes (GC) Well not 100% perfect as  we don't want to resize
 root node - which is close to hash resize. Stefan Nilsson did some 
 work in his "dynamic tries", halve_threshold and  inflate_threshold 
 is controlling the resize alone. AFAIK the two different thresholds 
 was used to prevent oscillation and prevent dampening. Maybe some
 ideas can be considered.

 About GC, if we forget what can be done with active GC for now..
 IMO the "most important" GC for constant load is the on-demanand 
 or passive where we triggered by a fixed threshhold. ( A fixed
 equilibrium point )

 > I am of the opinion that LRU, for routes not attached to sockets, is
 > probably the best thing to do here.
 
 Yes among other things rt_score checks for this.

 > Furthermore at high packet rates, the current rt_may_expire() logic
 > probably is not very effective since it's granularity is limited to
 > jiffies.  We can quite easily create 100,000 or more entries per
 > jiffie when HZ=100 during rDOS, for example.  So perhaps some global
 > LRU algorithm using ktime is more appropriate.

 Timer-based GC. In my world this is just to get rid of entries when 
 traffic has stopped/dropped. 

 > Global LRU is not easy without touching a lot of memory.  But I'm
 > sure some clever trick can be discovered by someone :)

 Yes as have to scan a entries. To be balanced with the work we have  
 to if we remove something that need to "restored".

 > It is amusing, but it seems that for rDOS workload most optimal
 > routing hash would be tiny one like my example above.  All packets
 > essentially miss the routing cache and create new entry.  So
 > keeping the working set as small as possible is what you want
 > to do since no matter how large you grow your hit rate will be
 > zero :-)

 Yes Alexey and I tried long time ago to limit the lengths of the
 hash-chains. We saw improved result but we didn't find any usable 
 measure for rDoS. 

 Cheers
					--ro
