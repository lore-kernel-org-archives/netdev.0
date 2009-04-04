From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [netfilter bug] BUG: using smp_processor_id() in preemptible
	[00000000] code: ssh/9115, caller is ipt_do_table+0xc8/0x559
Date: Sat, 4 Apr 2009 10:23:02 -0700
Message-ID: <20090404172302.GA9600@linux.vnet.ibm.com>
References: <20090402200128.GA21805@elte.hu> <49D51D86.9030906@cosmosbay.com> <20090402203220.GA30375@elte.hu> <20090402211606.GC4076@elte.hu>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <dada1@cosmosbay.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, netfilter@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Rusty Russell <rusty@rustcorp.com.au>, coreteam@netfilter.org
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e6.ny.us.ibm.com ([32.97.182.146]:44258 "EHLO e6.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751539AbZDDRXI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 4 Apr 2009 13:23:08 -0400
Content-Disposition: inline
In-Reply-To: <20090402211606.GC4076@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 02, 2009 at 11:16:06PM +0200, Ingo Molnar wrote:
> * Ingo Molnar <mingo@elte.hu> wrote:
> > * Eric Dumazet <dada1@cosmosbay.com> wrote:
> > > David put into its tree fix for that a few hours ago
> > > 
> > > commit fa9a86ddc8ecd2830a5e773facc250f110300ae7
> > > 
> > > (netfilter: iptables: lock free counters) forgot to disable BH
> > > in arpt_do_table(), ipt_do_table() and  ip6t_do_table()
> > > 
> > > Use rcu_read_lock_bh() instead of rcu_read_lock() cures the problem.
> > 
> > ok, got your fix (attached below), thanks Eric for the pointer.
> > 
> > But i think my fix might be slightly better, because it does not 
> > manipulate the preempt counter and leaves preemption enabled.
> > 
> > There's no BH context worries since this code did not seem to have 
> > BH protection before either. (it used a plain read_lock(), not 
> > read_lock_bh(), AFAICS)
> > 
> > I dont see any preemption worries either. I must be missing 
> > something :)
> 
> as per the other mail - what i missed was that the old code _did_ 
> use read_lock_bh(), which did not get carried over into the 
> rcu_read_lock().
> 
> So this fix affects basically all things netfilter, not just 
> rcu-preempt - a plain rcu_read_lock() doesnt protect against BH 
> context interaction.

Strangely enough, the original motivation for rcu_read_lock_bh() does not
apply to -rt kernels.  The problem was that denial-of-service workloads
could apply such a heavy interrupt load to a given CPU that it never
got back to process-level execution, thus never passing through any
quiescent states.

So rcu-bh has softirq-level quiescent states, solving that problem,
but by disabling softirq (and thus preemption) across the read-side
critical sections.

But -rt has every point in the code not covered by rcu_read_lock()
as a quiescent state, so should not be vulnerable to that particular
denial-of-service attack.  But rcu-bh has the additional semantic of
excluding BH execution while under rcu_read_lock_bh(), which appears
to be used in this case, and probably others as well.

Interesting corner we have painted ourselves into here...

							Thanx, Paul
