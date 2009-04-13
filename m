From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] netfilter: use per-cpu spinlock rather than RCU
Date: Mon, 13 Apr 2009 16:26:20 -0700
Message-ID: <20090413162620.01353461.akpm@linux-foundation.org>
References: <20090411174801.GG6822@linux.vnet.ibm.com>
	<18913.53699.544083.320542@cargo.ozlabs.ibm.com>
	<20090412173108.GO6822@linux.vnet.ibm.com>
	<20090412.181330.23529546.davem@davemloft.net>
	<20090413040413.GQ6822@linux.vnet.ibm.com>
	<20090413095309.631cf395@nehalam>
	<20090413152437.c48723f6.akpm@linux-foundation.org>
	<20090413162000.5f8d9a05@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: paulmck@linux.vnet.ibm.com, davem@davemloft.net, paulus@samba.org,
	mingo@elte.hu, torvalds@linux-foundation.org, laijs@cn.fujitsu.com,
	jeff.chua.linux@gmail.com, dada1@cosmosbay.com, jengelh@medozas.de,
	kaber@trash.net, r000n@r000n.net, linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	benh@kernel.crashing.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:57821 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751697AbZDMXfk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Apr 2009 19:35:40 -0400
In-Reply-To: <20090413162000.5f8d9a05@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 13 Apr 2009 16:20:00 -0700
Stephen Hemminger <shemminger@vyatta.com> wrote:

> On Mon, 13 Apr 2009 15:24:37 -0700
> Andrew Morton <akpm@linux-foundation.org> wrote:
> 
> > On Mon, 13 Apr 2009 09:53:09 -0700
> > Stephen Hemminger <shemminger@vyatta.com> wrote:
> > 
> > > This is an alternative version of ip/ip6/arp tables locking using
> > > per-cpu locks.  This avoids the overhead of synchronize_net() during
> > > update but still removes the expensive rwlock in earlier versions.
> > > 
> > > The idea for this came from an earlier version done by Eric Duzamet.
> > > Locking is done per-cpu, the fast path locks on the current cpu
> > > and updates counters.  The slow case involves acquiring the locks on
> > > all cpu's.
> > > 
> > > The mutex that was added for 2.6.30 in xt_table is unnecessary since
> > > there already is a mutex for xt[af].mutex that is held.
> > > 
> > > Tested basic functionality (add/remove/list), but don't have test cases
> > > for stress, ip6tables or arptables.
> > > 
> > >  unsigned int
> > >  ipt_do_table(struct sk_buff *skb,
> > > @@ -339,9 +341,10 @@ ipt_do_table(struct sk_buff *skb,
> > >  
> > >  	IP_NF_ASSERT(table->valid_hooks & (1 << hook));
> > >  
> > > -	rcu_read_lock_bh();
> > > -	private = rcu_dereference(table->private);
> > > -	table_base = rcu_dereference(private->entries[smp_processor_id()]);
> > > +	local_bh_disable();
> > > +	spin_lock(&__get_cpu_var(ip_tables_lock));
> > 
> > spin_lock_bh()?
> 
> No. get_cpu_var implies smp_processor_id which is not safe
> without preempt_disable (ie bh disable).

spin_lock_bh() will dtrt, but spelling it out seems a good idea.

It should have an explanatory comment, IMO.

> > 
> > And it should be hotplug aware, really.  num_possible_cpus() can exceed
> > num_online_cpus().  The extent by which possible>online is
> > controversial, but one can conceive of situations where it is "lots".
> 
> It is doing right thing already with hotplug.

It's slow.

> This code still needs to count packets processed by previously online
> cpu, that is no longer there.

Those counts could be migrated off that CPU when it is offlined.  As
percpucounter does.

> > Is lib/percpu_counter.c no good for this application?  Unfixably no
> > good?  That code automagically handles cpu hotplug.
> 
> percpu_counter can't deal with the layout/load here.

Insufficient detail here for anyone to understand why percpucounter
cannot be adapted to this requirement.

