From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH] netfilter: use per-cpu recursive lock (v11)
Date: Wed, 22 Apr 2009 10:00:24 +0200
Message-ID: <20090422080024.GB31835@elte.hu>
References: <20090420103414.1b4c490f@nehalam> <49ECBE0A.7010303@cosmosbay.com> <18924.59347.375292.102385@cargo.ozlabs.ibm.com> <20090420215827.GK6822@linux.vnet.ibm.com> <18924.64032.103954.171918@cargo.ozlabs.ibm.com> <20090420160121.268a8226@nehalam> <alpine.LFD.2.00.0904210831560.2199@localhost.localdomain> <20090421111541.228e977a@nehalam> <20090421191007.GA15485@elte.hu> <20090421140446.0c45d9a0@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Paul Mackerras <paulus@samba.org>, paulmck@linux.vnet.ibm.com,
	Eric Dumazet <dada1@cosmosbay.com>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	David Miller <davem@davemloft.net>, kaber@trash.net,
	jeff.chua.linux@gmail.com, laijs@cn.fujitsu.com,
	jengelh@medozas.de, r000n@r000n.net, linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	benh@kernel.crashing.org, mathieu.desnoyers@polymtl.ca
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090421140446.0c45d9a0@nehalam>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Stephen Hemminger <shemminger@vyatta.com> wrote:

> > That way there's no global cacheline bouncing (just the 
> > _reading_ of a global cacheline - which will be nicely localized 
> > - on NUMA too) - and we will hold at most 1-2 locks at once!
> > 
> > Something like:
> > 
> > 	__cacheline_aligned DEFINE_RWLOCK(global_wrlock);
> > 
> > 	DEFINE_PER_CPU(rwlock_t local_lock);
> > 
> > 
> > 	void local_read_lock(void)
> > 	{
> > 	again:
> > 		read_lock(&per_cpu(local_lock, this_cpu));
> > 
> > 		if (unlikely(!read_can_lock(&global_wrlock))) {
> > 			read_unlock(&per_cpu(local_lock, this_cpu));
> > 			/*
> > 			 * Just wait for any global write activity:
> > 			 */
> > 			read_unlock_wait(&global_wrlock);
> > 			goto again;
> > 		}
> > 	}
> 
> Quit trying to be so damn f*cking cool. [...]

You make it quite hard to give reasonable feedback to your code :-/
First you attack me personally here, then - 30 minutes later - in 
the next iteration of your patch, you do:

+       /* wait for each other cpu to see new table */
+       for_each_possible_cpu(i)
+               if (i != smp_processor_id()) {
+                       xt_info_wrlock(i);
+                       xt_info_wrunlock(i);
+               }

... which i have not seen in your previous patch and which looks 
awfully similar to the write_lock_wait() based primitive i 
suggested.

( Just open-coded in an ugly fashion and slower than a real, proper
  wait-unlock would be, because it dirties all those locks 
  needlessly. )

So you must have agreed with me to a certain degree - i just dont 
see that in any of the discussion. (you seem to totally disagree 
with me to the level of ridiculing me.) Which makes it hard to 
discuss this on a rational basis.

> Your version fails for the case of nested local rules. [...]

Yes, as Eric pointed it out, more than an hour before your reply. I 
find the nesting uninteresting (in fact i find it harmful - see my 
reply to Eric). If you were only interested in nesting then a plain 
old-fashioned rwlock would have done the job.

The detail that is interesting here is how to avoid the global 
rwlock cacheline bounce - not the recursion. (the same-CPU recursion 
is avoidable via proper design or workaround-able via a counter in 
so many ways)

Anyway, i'm back into lurker mode.

	Ingo
