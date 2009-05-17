From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH RFC] v5 expedited "big hammer" RCU grace periods
Date: Sun, 17 May 2009 15:08:35 -0700
Message-ID: <20090517220835.GF6973@linux.vnet.ibm.com>
References: <20090517191141.GA25915@linux.vnet.ibm.com> <20090517200223.GA31029@ioremap.net>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, mingo@elte.hu,
	akpm@linux-foundation.org, torvalds@linux-foundation.org,
	davem@davemloft.net, dada1@cosmosbay.com,
	jeff.chua.linux@gmail.com, paulus@samba.org, laijs@cn.fujitsu.com,
	jengelh@medozas.de, r000n@r000n.net, benh@kernel.crashing.org,
	mathieu.desnoyers@polymtl.ca
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090517200223.GA31029@ioremap.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 18, 2009 at 12:02:23AM +0400, Evgeniy Polyakov wrote:
> Hi.

Hello, Evgeniy!

> On Sun, May 17, 2009 at 12:11:41PM -0700, Paul E. McKenney (paulmck@linux.vnet.ibm.com) wrote:
> > Fifth cut of "big hammer" expedited RCU grace periods.  This uses per-CPU
> > kthreads that are scheduled in parallel by a call to smp_call_function()
> > by yet another kthread.  The synchronize_sched(), synchronize_rcu(),
> > and synchronize_bh() primitives wake this kthread up and then wait for
> > it to force the grace period.
> 
> I'm curious, but doesn't the fact that registered 'barrier' callback is
> invoked mean grace period completion? I.e. why to bother with
> rescheduling, waiting for thread to complete and so on, when we only
> care in the fact that 'barrier' callback is invoked, and thus all
> previous ones are completed?
> Or it is done just for the simplicity, since all rescheduling machinery
> already manages the rcu bits correctly, so you do not want to put it
> directly into 'barrier' callback?

It is a short-term expedient course of action.  Longer term, I will drop
rcuclassic in favor of rcutree, and then merge rcupreempt into rcutree.
I will then add machinery to rcutree to handle expedited grace periods
(somewhat) more naturally.  Trying to expedite three very different RCU
implementations seems a bit silly, hence the current off-on-the-side
approach.

But even then I will avoid relying on a "barrier" callback, or, indeed,
any sort of callback, because we don't want expedited grace periods to
have to wait on invocation of earlier RCU callbacks.  There will thus
not be a call_rcu_expedited(), at least not unless someone comes up with
a -really- compelling reason why.

But the exercise of going through several possible implementations was
quite useful, as I learned a number of things that will improve the
eventual rcutree implementation.  Like the fact that expedited grace
periods don't want to be waiting on invocation of prior callbacks.  ;-)

And rcutiny is, as always, as special case.  Here is the implementation
of synchronize_rcu_expedited() in rcutiny:

	void synchronize_rcu_expedited(void)
	{
	}

Or even:

	#define synchronize_rcu_expedited synchronize_rcu

;-)

							Thanx, Paul
