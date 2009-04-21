From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] netfilter: use per-cpu recursive lock (v11)
Date: Tue, 21 Apr 2009 14:04:46 -0700
Message-ID: <20090421140446.0c45d9a0@nehalam>
References: <20090418094001.GA2369@ioremap.net>
	<20090418141455.GA7082@linux.vnet.ibm.com>
	<20090420103414.1b4c490f@nehalam>
	<49ECBE0A.7010303@cosmosbay.com>
	<18924.59347.375292.102385@cargo.ozlabs.ibm.com>
	<20090420215827.GK6822@linux.vnet.ibm.com>
	<18924.64032.103954.171918@cargo.ozlabs.ibm.com>
	<20090420160121.268a8226@nehalam>
	<alpine.LFD.2.00.0904210831560.2199@localhost.localdomain>
	<20090421111541.228e977a@nehalam>
	<20090421191007.GA15485@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
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
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:44366 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754434AbZDUVEx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Apr 2009 17:04:53 -0400
In-Reply-To: <20090421191007.GA15485@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 21 Apr 2009 21:10:07 +0200
Ingo Molnar <mingo@elte.hu> wrote:

> 
> * Stephen Hemminger <shemminger@vyatta.com> wrote:
> 
> > +void xt_info_wrlock_bh(void)
> > +{
> > +	unsigned int i;
> > +
> > +	local_bh_disable();
> > +	for_each_possible_cpu(i) {
> > +		write_lock(&per_cpu(xt_info_locks, i));
> > +#if NR_CPUS > (PREEMPT_MASK - 1)
> > +		/*
> > +		 * Since spin_lock disables preempt, the following is
> > +		 * required to avoid overflowing the preempt counter
> > +		 */
> > +		preempt_enable_no_resched();
> > +#endif
> > +	}
> > +}
> 
> hm, this is rather ugly and it will make a lot of instrumentation 
> code explode.

Better general solutions:
    * use raw_spin_lock
    * increase PREEMPT_BITS on 64 bit machine 
      and limit to 128 CPU or less on 32 bit
    * get rid of default preempt_disable in spin_lock

You choose. It is a general problem.

> Why not use the obvious solution: a _single_ wrlock for global 
> access and read_can_lock() plus per cpu locks in the fastpath?
> 
> That way there's no global cacheline bouncing (just the _reading_ of 
> a global cacheline - which will be nicely localized - on NUMA too) - 
> and we will hold at most 1-2 locks at once!
> 
> Something like:
> 
> 	__cacheline_aligned DEFINE_RWLOCK(global_wrlock);
> 
> 	DEFINE_PER_CPU(rwlock_t local_lock);
> 
> 
> 	void local_read_lock(void)
> 	{
> 	again:
> 		read_lock(&per_cpu(local_lock, this_cpu));
> 
> 		if (unlikely(!read_can_lock(&global_wrlock))) {
> 			read_unlock(&per_cpu(local_lock, this_cpu));
> 			/*
> 			 * Just wait for any global write activity:
> 			 */
> 			read_unlock_wait(&global_wrlock);
> 			goto again;
> 		}
> 	}

Quit trying to be so damn f*cking cool. We don't build the software
for locking instrumentation. Locking instrumentation needs to serve
the kernel, not the other way around. 

Your version fails for the case of nested local rules. Which was
the whole reason I switched to read/writer locks.

        CPU 1                            CPU 2
        local_read_lock
        ...                              global_write_lock
            local_read_lock
Stuck...

CPU 2 is waiting for CPU 1 to get out of its nested table processing
CPU 1 is waiting for write lock to get done

