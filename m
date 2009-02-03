From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 3/3] iptables: lock free counters (alternate version)
Date: Tue, 3 Feb 2009 12:44:42 -0800
Message-ID: <20090203124442.44598d63@extreme>
References: <20090130215700.965611970@vyatta.com>
	<20090130215729.416851870@vyatta.com>
	<498594B6.6000905@cosmosbay.com>
	<20090202153357.3ac6edfa@extreme>
	<49889440.60702@cosmosbay.com>
	<20090203193214.GH6607@linux.vnet.ibm.com>
	<4988A6F4.6000902@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: paulmck@linux.vnet.ibm.com, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:42775 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751244AbZBCUon (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Feb 2009 15:44:43 -0500
In-Reply-To: <4988A6F4.6000902@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> >>> +	e = t->entries[curcpu];
> >>>  	i = 0;
> >>> -	IPT_ENTRY_ITERATE(t->entries[curcpu],
> >>> +	IPT_ENTRY_ITERATE(e,
> >>>  			  t->size,
> >>>  			  set_entry_to_counter,
> >> Hum, current cpu might be interrupted by NIC, since you only disabled preemption.
> >> set_entry_to_counter() might get garbage.
> >> I suppose I already mentioned it :)


Need to change preempt_disable to local_bh_disable.

> >>>  			  counters,
> >>>  			  &i);
> >>>  
> >>>  	for_each_possible_cpu(cpu) {
> >>> +		void *p;
> >>> +
> >>>  		if (cpu == curcpu)
> >>>  			continue;
> >>> +
> >>> +		/* Swizzle the values and wait */
> >>> +		e->counters = ((struct xt_counters) { 0, 0 });
> >> I dont see what you want to do here...
> >>
> >> e->counters is the counter associated with rule #0
> >>
> >>> +		p = t->entries[cpu];
> >>> +		rcu_assign_pointer(t->entries[cpu], e);
> >>> +		synchronize_net();
> >>
> >> Oh well, not this synchronize_net() :)
> >>
> >> This wont provide atomic sampling of counters for whole CPUS, and introduce large delays
> >> on big machines (NR_CPUS >= 64)

For large number of CPU's it  would be possible to allocate
a full set of ncpu-1 new counters, then swap them in and then do one synchronize net.
Or instead of synchronize_net, maybe a "wait for CPU #n" to go through
grace period.

> > Why would this not provide the moral equivalent of atomic sampling?
> > The code above switches to another counter set, and waits for a grace
> > period.  Shouldn't this mean that all CPUs that were incrementing the
> > old set of counters have finished doing so, so that the aggregate count
> > covers all CPUs that started their increments before the pointer switch?
> > Same as acquiring a write lock, which would wait for all CPUs that
> > started their increments before starting the write-lock acquisition.
> > CPUs that started their increments after starting the write acquisition
> > would not be accounted for in the total, same as the RCU approach.
> > 
> > Steve's approach does delay reading out the counters, but it avoids
> > delaying any CPU trying to increment the counters.
> 
> I see your point, but this is not what Stephen implemented.
> 
> So.. CPU will increments which counters, if not delayed ?

The concept is that only the sum of all the counters matters, not
which CPU has the count.

> How counters will be synced again after our 'iptables -L' finished ?
> 
> "iptable -L" is not supposed to miss some counters updates (only some packets
>  might be droped at NIC level because we spend time in the collection).
> If packets matches some rules, we really want up2date counters.
> 
> Maybe we need for this collection an extra "cpu", to collect 
> all increments that were done when CPUs where directed to a 
> "secondary table/counters"
> 
> > 
> > So what am I missing here?
> > 
> 
> Well, I saw one synchronize_net() inside the for_each_possible_cpu(cpu) loop.
> Say we have NR_CPUS=4096, how long will it takes to perform "iptables -L" ?
> 
> 
> 
> General/intuitive idea would be :
> 
> switch pointers to a newly allocated table (and zeroed counters)
> wait one RCU grace period
> collect/sum all counters of "old" table + (all cpus) into user provided table
> restore previous table
> wait one RCU grace period
> disable_bh()
> collect/sum all counters of "new and temporary" table (all cpus) and
> reinject them into local cpu table (this cpu should not be interrupted)
> enable_bh()
> 
> This way, "iptables -L" is not too expensive and doesnt block packet processing at all.

Pretty much what I said.
