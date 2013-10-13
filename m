From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 tip/core/rcu 07/13] ipv6/ip6_tunnel: Apply
 rcu_access_pointer() to avoid sparse false positive
Date: Sun, 13 Oct 2013 04:14:39 -0700
Message-ID: <20131013111439.GE5790@linux.vnet.ibm.com>
References: <20131009225617.GH11709@jtriplet-mobl1>
 <20131010002833.GJ5790@linux.vnet.ibm.com>
 <20131010020422.GB24368@order.stressinduktion.org>
 <20131010190532.GQ5790@linux.vnet.ibm.com>
 <20131012022508.GA20321@order.stressinduktion.org>
 <20131012075336.GA5790@linux.vnet.ibm.com>
 <20131012164345.GB20321@order.stressinduktion.org>
 <20131012173734.GC20321@order.stressinduktion.org>
 <1882655271.38519.1381606938076.JavaMail.zimbra@efficios.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Josh Triplett <josh@joshtriplett.org>,
	linux-kernel@vger.kernel.org, mingo@kernel.org,
	laijs@cn.fujitsu.com, dipankar@in.ibm.com,
	akpm@linux-foundation.org, niv@us.ibm.com, tglx@linutronix.de,
	peterz@infradead.org, rostedt@goodmis.org, dhowells@redhat.com,
	edumazet@google.com, darren@dvhart.com, fweisbec@gmail.com,
	sbw@mit.edu, "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1882655271.38519.1381606938076.JavaMail.zimbra@efficios.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Oct 12, 2013 at 07:42:18PM +0000, Mathieu Desnoyers wrote:
> ----- Original Message -----
> > On Sat, Oct 12, 2013 at 06:43:45PM +0200, Hannes Frederic Sowa wrote:
> > > Regarding the volatile access, I hope that the C11 memory model
> > > and enhancements to the compiler will some day provide a better
> > > way to express the semantics of what is tried to express here
> > > (__atomic_store_n/__atomic_load_n with the accompanied memory model,
> > > which could be even weaker to what a volatile access would enfore
> > > now and could guarantee atomic stores/loads).
> > 
> > I just played around a bit more. Perhaps we could try to warn of silly
> > usages of ACCESS_ONCE():
> > 
> > --- a/include/linux/compiler.h
> > +++ b/include/linux/compiler.h
> > @@ -349,7 +349,11 @@ void ftrace_likely_update(struct ftrace_branch_data *f,
> > int val, int expect);
> >   * use is to mediate communication between process-level code and irq/NMI
> >   * handlers, all running on the same CPU.
> >   */
> > -#define ACCESS_ONCE(x) (*(volatile typeof(x) *)&(x))
> > +#define ACCESS_ONCE(x) (*({						\
> > +		compiletime_assert(sizeof(typeof(x)) <= sizeof(typeof(&x)), \
> > +				   "ACCESS_ONCE likely not atomic");	\
> 
> AFAIU, ACCESS_ONCE() is not meant to ensure atomicity of load/store,
> but rather merely ensures that the compiler will not merge nor refetch
> accesses. I don't think the assert check you propose is appropriate with
> respect to the ACCESS_ONCE() semantic.

I am with Mathieu on this one, at least unless there is some set of actual
bugs already in the kernel that these length checks would find.

/me wonders about structs of size 3, 5, 6, and 7...

							Thanx, Paul

> Thanks,
> 
> Mathieu
> 
> > +		(volatile typeof(x) *)&(x);				\
> > +}))
> >  
> >  /* Ignore/forbid kprobes attach on very low level functions marked by this
> >  attribute: */
> >  #ifdef CONFIG_KPROBES
> > 
> > 
> 
> -- 
> Mathieu Desnoyers
> EfficiOS Inc.
> http://www.efficios.com
> 
