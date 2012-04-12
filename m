From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: suspicious RCU usage warnings in 3.3.0
Date: Wed, 11 Apr 2012 17:45:07 -0700
Message-ID: <20120412004507.GF2473@linux.vnet.ibm.com>
References: <alpine.SOC.1.00.1204111807420.26884@math.ut.ee>
 <20120411230837.GC2473@linux.vnet.ibm.com>
 <20120411171004.016ddd95@nehalam.linuxnetplumber.net>
 <20120411.201854.1070083308359208025.davem@davemloft.net>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@vyatta.com, mroos@linux.ee,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20120411.201854.1070083308359208025.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 11, 2012 at 08:18:54PM -0400, David Miller wrote:
> From: Stephen Hemminger <shemminger@vyatta.com>
> Date: Wed, 11 Apr 2012 17:10:04 -0700
> 
> > On Wed, 11 Apr 2012 16:08:37 -0700
> > "Paul E. McKenney" <paulmck@linux.vnet.ibm.com> wrote:
> > 
> >> Hmmm...  What CPU family is this running on?  From the look of the
> >> stack, it is sneaking out of idle into softirq without telling RCU.
> >> This would cause RCU to complain bitterly about being invoked from
> >> the idle loop -- and RCU ignores CPUs in the idle loop.
> >> 
> >> 							Thanx, Paul
> > 
> > Sun4... Ping David.
> 
> So is there anything specific I need to do in the sparc64
> idle loop?

Hmmm...  I must confess that I don't immediately see how control
is passing from cpu_idle() in arch/sparc/kernel/process_64.c to
__handle_softirq().

But it looks like a simple function call in the call trace:

	[36457.471471] Call Trace:
	[36457.503600]  [0000000000489834] lockdep_rcu_suspicious+0xd4/0x100
	[36457.583727]  [00000000006755a8] __netif_receive_skb+0x368/0xa80
	[36457.661536]  [0000000000675e6c] netif_receive_skb+0x4c/0x60
	[36457.734787]  [000000000063fd74] tulip_poll+0x3b4/0x6a0
	[36457.802327]  [00000000006794d8] net_rx_action+0x118/0x1e0
	[36457.873299]  [00000000004560fc] __do_softirq+0x9c/0x140
	[36457.941984]  [000000000042b1c4] do_softirq+0x84/0xc0
	[36458.007229]  [0000000000404a40] __handle_softirq+0x0/0x10
	[36458.078199]  [000000000042b688] cpu_idle+0x48/0x100
	[36458.142314]  [0000000000722db8] rest_init+0x160/0x188
	[36458.208711]  [00000000008c87b0] start_kernel+0x32c/0x33c
	[36458.278530]  [0000000000722c50] tlb_fixup_done+0x88/0x90
	[36458.348346]  [0000000000000000]           (null)

If it really is a simple function call, the trick is to wrap a RCU_NONIDLE()
around the call point, for example, fancifully:

	RCU_NONIDLE(__handle_softirq());

This places an rcu_idle_enter() before the argument and an
rcu_idle_enter() after it.  So it might be sufficient to adjust the
positions of the rcu_idle_enter() and rcu_idle_exit() calls in sparc64's
cpu_idle() function, for example, into the sparc64_yield() function
(if that is what is needed -- I can't see how sparc64_yield() calls
__handle_softirq(), either).

If I am confused about the simple function call, and if control is really
passing via an interrupt or exception, then rcu_irq_enter() should be
called on entry to the interrupt or exception and rcu_irq_exit() should
be called on exit.

Otherwise, RCU will happily ignore any RCU read-side critical sections
that are in what it believes to the the idle loop.

							Thanx, Paul
