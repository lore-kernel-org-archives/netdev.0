From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH] netfilter: use per-cpu spinlock rather than RCU
Date: Mon, 13 Apr 2009 16:37:26 -0700 (PDT)
Message-ID: <alpine.LFD.2.00.0904131631400.26713@localhost.localdomain>
References: <20090411174801.GG6822@linux.vnet.ibm.com> <18913.53699.544083.320542@cargo.ozlabs.ibm.com> <20090412173108.GO6822@linux.vnet.ibm.com> <20090412.181330.23529546.davem@davemloft.net> <20090413040413.GQ6822@linux.vnet.ibm.com> <20090413095309.631cf395@nehalam>
 <20090413152437.c48723f6.akpm@linux-foundation.org> <20090413162000.5f8d9a05@nehalam> <20090413162620.01353461.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	paulmck@linux.vnet.ibm.com, davem@davemloft.net, paulus@samba.org,
	mingo@elte.hu, laijs@cn.fujitsu.com, jeff.chua.linux@gmail.com,
	dada1@cosmosbay.com, jengelh@medozas.de, kaber@trash.net,
	r000n@r000n.net, linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	benh@kernel.crashing.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090413162620.01353461.akpm@linux-foundation.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Mon, 13 Apr 2009, Andrew Morton wrote:
> > > >  
> > > > -	rcu_read_lock_bh();
> > > > -	private = rcu_dereference(table->private);
> > > > -	table_base = rcu_dereference(private->entries[smp_processor_id()]);
> > > > +	local_bh_disable();
> > > > +	spin_lock(&__get_cpu_var(ip_tables_lock));
> > > 
> > > spin_lock_bh()?
> > 
> > No. get_cpu_var implies smp_processor_id which is not safe
> > without preempt_disable (ie bh disable).
> 
> spin_lock_bh() will dtrt, but spelling it out seems a good idea.

No, spin_lock_bh() will _not_ do the right thing. 

On UP it will actually work for two reasons: it will work because (a) it's 
UP, so there are no issues with smp_processor_id() to beging with, but 
also because even if there _were_ issues, it would still work because it 
would all expand as a macro, and the preempt_disable() will actually 
happen before the argument is evaluated.

But on SMP, spin_lock_bh() expands to just _spin_lock_bh(), and is a real 
function - and the argument will be evaluated before the call (obviously), 
and thus before the preempt_disable().

So

	local_bh_disable();
	spin_lock(&__get_cpu_var(ip_tables_lock));

is correct, and 

	spin_lock_bh(&__get_cpu_var(ip_tables_lock));

is _not_ correct. The latter will do "&__get_cpu_var(ip_tables_lock)"
with no protection from the process being switched to another CPU.

			Linus
