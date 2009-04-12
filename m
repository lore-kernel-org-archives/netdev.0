From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: iptables very slow after commit
	784544739a25c30637397ace5489eeb6e15d7d49
Date: Sat, 11 Apr 2009 17:34:45 -0700
Message-ID: <20090412003445.GK6822@linux.vnet.ibm.com>
References: <Pine.LNX.4.64.0904101656190.2093@boston.corp.fedex.com> <20090410095246.4fdccb56@s6510> <20090410.182507.140306636.davem@davemloft.net> <alpine.LFD.2.00.0904101828490.4583@localhost.localdomain> <20090411041533.GB6822@linux.vnet.ibm.com> <alpine.LFD.2.00.0904111150380.4583@localhost.localdomain>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, Ingo Molnar <mingo@elte.hu>,
	Lai Jiangshan <laijs@cn.fujitsu.com>, shemminger@vyatta.com,
	jeff.chua.linux@gmail.com, dada1@cosmosbay.com, jengelh@medozas.de,
	kaber@trash.net, r000n@r000n.net,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.0904111150380.4583@localhost.localdomain>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Apr 11, 2009 at 11:57:16AM -0700, Linus Torvalds wrote:
> 
> 
> On Fri, 10 Apr 2009, Paul E. McKenney wrote:
> > 
> > 1.	Assuming that the synchronize_net() is intended to guarantee
> > 	that the new rules will be in effect before returning to
> > 	user space:
> 
> Btw, I think that's a bad assumption.

It does indeed appear to be!

> The thing is, nobody can really care if the new rules are in effect or 
> not, because the thing you race with is not the "return to user space" 
> part, but the incoming packets.
> 
> And those incoming packets might have been incoming before the rules were 
> set up too.
> 
> So I seriously doubt you need to synchronize with any returning to user 
> space. What you want to synchronize with is then later actions that do 
> things like turning on the interface that the rules are attached to etc!
> 
> So I would suggest:
> 
>  - remove the synchronize_net() entirely. Replace it with just freeing the 
>    old rules using RCU.
> 
>  - new packets will always end up seeing the new rules. That includes the 
>    case of somebody doing "ifconfig eth0 up" that enables a new source of 
>    packets, so there are no real security issues.
> 
>  - if you enabled your network interfaces before you updated your packet 
>    filtering rules, you already had a window where packets would come in 
>    with the old rules, so doing a "synchronize_net()" in no way protects 
>    against any race conditions anyway.
> 
> Am I missing something?

The issue at this point seems to be the need to get accurate snapshots
of various counters -- there are a number of Linux networking users who
need to account for every byte flowing through their systems.  However,
it is also necessary to update these counters very efficiently, given
that they are updated on a per-packet basis.  The current approach is
as follows:

1.	Install a new set of counters.

2.	Wait for a grace period to elapse.

3.	At this point, we know that all subsequent counting will happen
	on the new set of counters.

4.	Add the value of the old set of counters to the new set of
	counters.

5.	Copy the old set of counters up to user space.

So we get a good snapshot in #5, while #4 ensures that we don't lose
any counts when taking future snapshots.  Unfortunately, #2 hits us
with grace-period latencies on the critical path.

We are going through the following possibilities:

o	Stick with the current approach, and ask people to move to
	new batch-oriented interfaces.  However, a 30x decrease in
	performance is pretty grim, even for an old-style interface.

o	Use various atomic tricks to get an immediate snapshot of the
	old counters after step 1.  Make step 3 use call_rcu() instead
	of synchronize_rcu(), and then step 4 happens off the
	critical path.

	This approach moves the RCU grace period off of the critical
	path, but the atomic tricks are extremely ugly on 32-bit SMP
	machines.  32-bit UP machines and 64-bit machines are not
	too bad, though the 32-bit UP case does add preemption-disable
	overhead on the counter-update fastpath.

o	Provide some sort of expedited synchronize_rcu().  This might
	be able to decrease the hit from 30x down to maybe 5x.
	But I might need to do this for the fast-boot folks anyway,
	though I am first trying to get away with just speeding
	up synchronized_rcu().  Though I was not thinking in terms
	of 6x, let alone 30x.

	Please note that this would not be a drop-in replacement for
	synchronize_rcu().  One would use synchronize_rcu_expedited()
	(or whatever) only when the system really could not get any
	useful work done while the grace period was in progress.
	The general approach would be to keep the whole machine busy
	trying to get the grace period done as soon as possible.

							Thanx, Paul
