From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [PATCH] netfilter: use per-cpu recursive lock (v11)
Date: Tue, 21 Apr 2009 12:16:49 +0400
Message-ID: <20090421081649.GA16782@ioremap.net>
References: <49ECBE0A.7010303@cosmosbay.com> <18924.59347.375292.102385@cargo.ozlabs.ibm.com> <20090420215827.GK6822@linux.vnet.ibm.com> <18924.64032.103954.171918@cargo.ozlabs.ibm.com> <20090420160121.268a8226@nehalam> <49ED406F.2040401@cn.fujitsu.com> <49ED4407.8010200@cosmosbay.com> <49ED5813.1000803@cn.fujitsu.com> <20090420224540.30d7b0ed@nehalam> <49ED6D2E.5060808@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Eric Dumazet <dada1@cosmosbay.com>,
	Paul Mackerras <paulus@samba.org>, paulmck@linux.vnet.ibm.com,
	David Miller <davem@davemloft.net>, kaber@trash.net,
	torvalds@linux-foundation.org, jeff.chua.linux@gmail.com,
	mingo@elte.hu, jengelh@medozas.de, r000n@r000n.net,
	linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, benh@kernel.crashing.org,
	mathieu.desnoyers@polymtl.ca
To: Lai Jiangshan <laijs@cn.fujitsu.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <49ED6D2E.5060808@cn.fujitsu.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi.

On Tue, Apr 21, 2009 at 02:52:30PM +0800, Lai Jiangshan (laijs@cn.fujitsu.com) wrote:
> > +void xt_info_rdlock_bh(void)
> > > +{
> > > +	struct xt_info_lock *lock;
> > > +
> > > +	preempt_disable();
> > > +	lock = &__get_cpu_var(xt_info_locks);
> > > +	if (likely(++lock->depth == 0))
> 
> So what happen when xt_info_rdlock_bh() called recursively here?
> 
> > > +		spin_lock_bh(&lock->lock);
> > > +	preempt_enable_no_resched();
> > > +}
> > > +EXPORT_SYMBOL_GPL(xt_info_rdlock_bh);
> > > +
> 
> ----------
> Is this OK? (Now I suppose we can enter the read-side critical region
> in irq context)
> 
> void xt_info_rdlock_bh(void)
> {
> 	unsigned long flags;
> 	struct xt_info_lock *lock;
> 
> 	local_irq_save(flags);
> 	lock = &__get_cpu_var(xt_info_locks);
> 	if (likely(++lock->depth == 0))
> 		spin_lock_bh(&lock->lock);
> 	local_irq_restore(flags);
> }

Netfilter as long as other generic network pathes are never accessed
from interrupt context, but your analysis looks right for the softirq
case.

Stephen, should preempt_disable() be replaced with local_bh_disable() to
prevent softirq to race on the same cpu for the lock's depth field? Or
can it be made atomic?

-- 
	Evgeniy Polyakov
