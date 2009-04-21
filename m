From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH] netfilter: use per-cpu recursive lock (v11)
Date: Tue, 21 Apr 2009 21:10:07 +0200
Message-ID: <20090421191007.GA15485@elte.hu>
References: <20090418094001.GA2369@ioremap.net> <20090418141455.GA7082@linux.vnet.ibm.com> <20090420103414.1b4c490f@nehalam> <49ECBE0A.7010303@cosmosbay.com> <18924.59347.375292.102385@cargo.ozlabs.ibm.com> <20090420215827.GK6822@linux.vnet.ibm.com> <18924.64032.103954.171918@cargo.ozlabs.ibm.com> <20090420160121.268a8226@nehalam> <alpine.LFD.2.00.0904210831560.2199@localhost.localdomain> <20090421111541.228e977a@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Paul Mackerras <paulus@samba.org>, paulmck@linux.vnet.ibm.com,
	Eric Dumazet <dada1@cosmosbay.com>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	David Miller <davem@davemloft.net>, kaber@trash.net,
	jeff.chua.linux@gmail.com, laijs@cn.fujitsu.com,
	jengelh@medozas.de, r000n@r000n.net, linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	benh@kernel.crashing.org, mathieu.desnoyers@polymtl.ca
To: Stephen Hemminger <shemminger@vyatta.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:37948 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757306AbZDUTKr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Apr 2009 15:10:47 -0400
Content-Disposition: inline
In-Reply-To: <20090421111541.228e977a@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Stephen Hemminger <shemminger@vyatta.com> wrote:

> +void xt_info_wrlock_bh(void)
> +{
> +	unsigned int i;
> +
> +	local_bh_disable();
> +	for_each_possible_cpu(i) {
> +		write_lock(&per_cpu(xt_info_locks, i));
> +#if NR_CPUS > (PREEMPT_MASK - 1)
> +		/*
> +		 * Since spin_lock disables preempt, the following is
> +		 * required to avoid overflowing the preempt counter
> +		 */
> +		preempt_enable_no_resched();
> +#endif
> +	}
> +}

hm, this is rather ugly and it will make a lot of instrumentation 
code explode.

Why not use the obvious solution: a _single_ wrlock for global 
access and read_can_lock() plus per cpu locks in the fastpath?

That way there's no global cacheline bouncing (just the _reading_ of 
a global cacheline - which will be nicely localized - on NUMA too) - 
and we will hold at most 1-2 locks at once!

Something like:

	__cacheline_aligned DEFINE_RWLOCK(global_wrlock);

	DEFINE_PER_CPU(rwlock_t local_lock);


	void local_read_lock(void)
	{
	again:
		read_lock(&per_cpu(local_lock, this_cpu));

		if (unlikely(!read_can_lock(&global_wrlock))) {
			read_unlock(&per_cpu(local_lock, this_cpu));
			/*
			 * Just wait for any global write activity:
			 */
			read_unlock_wait(&global_wrlock);
			goto again;
		}
	}

	void global_write_lock(void)
	{
		write_lock(&global_wrlock);

		for_each_possible_cpu(i)
			write_unlock_wait(&per_cpu(local_lock, i));
	}

Note how nesting friendly this construct is: we dont actually _hold_ 
NR_CPUS locks all at once, we simply cycle through all CPUs and make 
sure they have our attention.

No preempt overflow. No lockdep explosion. A very fast and scalable 
read path.

Okay - we need to implement read_unlock_wait() and 
write_unlock_wait() which is similar to spin_unlock_wait(). The 
trivial first-approximation is:

	read_unlock_wait(x)
	{
		read_lock(x);
		read_unlock(x);
	}

	write_unlock_wait(x)
	{
		write_lock(x);
		write_unlock(x);
	}

Hm?

	Ingo
