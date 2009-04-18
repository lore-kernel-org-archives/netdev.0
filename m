From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] netfilter: use per-cpu spinlock rather than RCU (v3)
Date: Sat, 18 Apr 2009 07:14:55 -0700
Message-ID: <20090418141455.GA7082@linux.vnet.ibm.com>
References: <20090415170111.6e1ca264@nehalam> <alpine.LFD.2.00.0904151705120.4042@localhost.localdomain> <49E72E83.50702@trash.net> <20090416.153354.170676392.davem@davemloft.net> <20090416234955.GL6924@linux.vnet.ibm.com> <20090417012812.GA25534@linux.vnet.ibm.com> <20090418094001.GA2369@ioremap.net>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, kaber@trash.net,
	torvalds@linux-foundation.org, shemminger@vyatta.com,
	dada1@cosmosbay.com, jeff.chua.linux@gmail.com, paulus@samba.org,
	mingo@elte.hu, laijs@cn.fujitsu.com, jengelh@medozas.de,
	r000n@r000n.net, linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	benh@kernel.crashing.org, mathieu.desnoyers@polymtl.ca
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090418094001.GA2369@ioremap.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Apr 18, 2009 at 01:40:01PM +0400, Evgeniy Polyakov wrote:
> Hi.
> 
> On Thu, Apr 16, 2009 at 06:28:12PM -0700, Paul E. McKenney (paulmck@linux.vnet.ibm.com) wrote:
> > +/* Single bit for grace-period index, low-order bits are nesting counter. */
> > +#define RCU_FGP_COUNT		1UL
> > +#define RCU_FGP_PARITY		(1UL << (sizeof(long) << 2))
> > +#define RCU_FGP_NEST_MASK	(RCU_FGP_PARITY - 1)
> > +
> > +extern long rcu_fgp_ctr;
> > +DECLARE_PER_CPU(long, rcu_fgp_active_readers);
> > +
> > +static inline void rcu_read_lock_fgp(void)
> > +{
> > +	long tmp;
> > +	long *uarp;
> > +
> > +	preempt_disable();
> > +	uarp = &__get_cpu_var(rcu_fgp_active_readers);
> > +	tmp = *uarp;
> > +	if (likely(!(tmp & RCU_FGP_NEST_MASK)))
> > +		*uarp = rcu_fgp_ctr;  /* Outermost rcu_read_lock(). */
> > +	else
> > +		*uarp = tmp + RCU_FGP_COUNT;  /* Nested rcu_read_lock(). */
> > +	barrier();
> > +}
> > +
> > +static inline void rcu_read_unlock_fgp(void)
> > +{
> > +	barrier();
> > +	__get_cpu_var(rcu_fgp_active_readers)--;
> 
> Shouldn't it be rcu_fgp_active_readers - RCU_FGP_COUNT?
> Although it is 1 by definition, it is more clear when understanding
> what's going on here.

Excellent point, fixed!

						Thanx, Paul
