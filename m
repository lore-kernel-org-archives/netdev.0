From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] lockdep: annotate rcu_read_{,un}lock()
Date: Fri, 17 Aug 2007 11:53:27 -0700
Message-ID: <20070817185327.GA21190@linux.vnet.ibm.com>
References: <af57f1ac0708141130v729fa636k3150673809ec20a8@mail.gmail.com> <E1ILEJr-0005Fl-00@gondolin.me.apana.org.au> <20070815.144628.104052147.davem@davemloft.net> <1187274307.6114.92.camel@twins> <20070816160145.GA16957@linux.vnet.ibm.com> <1187337405.6114.123.camel@twins> <20070817155357.GD8464@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ingo Molnar <mingo@elte.hu>, herbert@gondor.apana.org.au,
	123.oleg@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, David Miller <davem@davemloft.net>,
	Daniel Walker <dwalker@mvista.com>, josht@linux.vnet.ibm.com,
	minyard@acm.org
To: Peter Zijlstra <peterz@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e6.ny.us.ibm.com ([32.97.182.146]:49897 "EHLO e6.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753272AbXHQSxc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Aug 2007 14:53:32 -0400
Content-Disposition: inline
In-Reply-To: <20070817155357.GD8464@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 17, 2007 at 08:53:57AM -0700, Paul E. McKenney wrote:
> On Fri, Aug 17, 2007 at 09:56:45AM +0200, Peter Zijlstra wrote:
> > On Thu, 2007-08-16 at 09:01 -0700, Paul E. McKenney wrote:
> > > On Thu, Aug 16, 2007 at 04:25:07PM +0200, Peter Zijlstra wrote:
> > > > 
> > > > There seem to be some unbalanced rcu_read_{,un}lock() issues of late,
> > > > how about doing something like this:
> > > 
> > > This will break when rcu_read_lock() and rcu_read_unlock() are invoked
> > > from NMI/SMI handlers -- the raw_local_irq_save() in lock_acquire() will
> > > not mask NMIs or SMIs.
> > > 
> > > One approach would be to check for being in an NMI/SMI handler, and
> > > to avoid calling lock_acquire() and lock_release() in those cases.
> > 
> > It seems:
> > 
> > #define nmi_enter()		do { lockdep_off(); __irq_enter(); } while (0)
> > #define nmi_exit()		do { __irq_exit(); lockdep_on(); } while (0)
> > 
> > Should make it all work out just fine. (for NMIs at least, /me fully
> > ignorant of the workings of SMIs)
> 
> Very good point, at least for NMIs on i386 and x86_64.  Can't say that I
> know much about SMIs myself.  Or about whatever equivalents to NMIs and
> SMIs might exist on other platforms.  :-/  Of course, the other platforms
> could be handled by making the RCU lockdep operate only on i386 and x86_64
> if required.
> 
> Corey, any advice on SMI handlers?  Is there something like nmi_enter()
> and nmi_exit() that allows disabing lockdep?
> 
> > > Another approach would be to use sparse, which has checks for
> > > rcu_read_lock()/rcu_read_unlock() nesting.
> > 
> > Yeah, but one more method can never hurt, no? :-)
> 
> Excellent point!
> 
> I guess the next thing for me is to do a performance check.  Looks like
> CONFIG_DEBUG_LOCK_ALLOC is not on by default, so not violently worried
> about performance, but would be good to know.

4-CPU 1.8GHz Opteron 844 running 2.6.22 CONFIG_PREEMPT_NONE with Peter's
patch running rcu_read_lock()/rcu_read_unlock() in a tight loop:

1 CPU:  91.7ns
2 CPU: 335.2ns
3 CPU: 534.3ns  (But bimodal: two CPUs at 640.7ns, one at 321.6ns)
4 CPU: 784.0ns  (again bimodal: three CPUs at 895.9ns, one at 448.2ns)

Running without Peter's patch measures the loop overhead of about 1.2ns.

So not crippling, but definitely a debug-only option that is not enabled
by default in production.

In summary, seems like an eminently reasonable approach to me, assuming
that the NMI/SMI issues can be resolved across the platforms that have
them.  Good stuff, Peter!!!

						Thanx, Paul
