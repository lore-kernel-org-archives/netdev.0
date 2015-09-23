From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v2] netlink: Replace rhash_portid with bound
Date: Wed, 23 Sep 2015 11:54:40 -0400
Message-ID: <20150923155440.GB26647@mtj.duckdns.org>
References: <20150918111650.GA7508@gondor.apana.org.au>
 <20150920.225521.1063980101511317898.davem@davemloft.net>
 <20150921060636.GA30807@gondor.apana.org.au>
 <20150920.231104.525285577747035896.davem@davemloft.net>
 <20150921133415.GA1740@gondor.apana.org.au>
 <20150921182022.GB13263@mtj.duckdns.org>
 <20150922033856.GA7851@gondor.apana.org.au>
 <20150922161056.GB9761@mtj.duckdns.org>
 <20150923061342.GA19106@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, cwang@twopensource.com,
	tom@herbertland.com, kafai@fb.com, kernel-team@fb.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	torvalds@linux-foundation.org, jiri@resnulli.us,
	nicolas.dichtel@6wind.com, tgraf@suug.ch, sfeldma@gmail.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150923061342.GA19106@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello, Herbert.

On Wed, Sep 23, 2015 at 02:13:42PM +0800, Herbert Xu wrote:
> It doesn't matter on x86 but the semantics of smp_load_acquire
> and smp_store_release explicitly includes a full barrier which
> is something that we don't need.

Yeah, I was confused there.  I was thinking smp_rmb() was still doing
rmb() on x86.  smp_rmb/wmb() is the better pick here.

> > I mean, read this thread.  It's one subtle breakage after another, one
> > confusion after another.  The problematic usages of memory barriers
> > are usually of two types.
> 
> smp_load_acquire/store_release isn't some kind of magic dust
> that you can just spread around to fix races.  Whoever is writing
> the code had better understood what the code is doing or they will
> end up creating more bugs.

Hmm... lemme try again.  When using barriers or RCU, it's desirable to
establish certain invariants because it usually is extremely easy to
miss corner cases.  It is helpful to have an abstraction, even if just
conceptual, where people can go "this thing is barrier / RCU protected
to guarantee XYZ".  Going more towards RCU example, this is why we
annotate variables as RCU protected to detect incorrect usages.  There
sure are exceptions but most are of the sort "this is write path and
protected by something else which is annotated differently".  Doing
things this way makes it a lot easier to get right.

Now, going back to barrier example.  If we take a similar approach,
there can be two cases.

1. Read of the boolean is barrier protected.  It's known that the
   condition that the boolean indicates is visible as true once the
   test succeeds.

2. Directly test the boolean inside write locking.  As the whole thing
   is protected by the same lock, we know that the indicated condition
   always matches what's visible.

In a lot of cases, separating out 2 doesn't matter all that much and
we sometimes skip it.  If we do that, either the protection should be
fairly obvious or, if there are multiple of those and the code path
isn't quite trivial, a different helper with extra lockdep annotation
can be used.

No matter what we do, please realize that we keep the invariant that
once the test evaulates to true the visible state matches what's
expected from such result.

What you're proposing introduces a third case in the above scenario
where how the test is performed becomes dependent on not only the
context of the test (which often can be annotated) but also the
following code does with the result of the test.  There are
exceptional cases where this makes sense but it's inherently hairy and
we only do things like that only if it's absoultely necessary and with
a lot of caution.  That isn't the case here.

You said that barriers aren't magic bullets.  Exactly, they aren't
anything special and whatever we do with them should be a reasonable
trade-off.  We've had incorrect and/or incomprehensible barrier usages
but that's not because people weren't going to 11 with scrutinizing
each deref and mixing barriered and non-barriered accesses.  If
anything, doing things like that without good enough rationale and
documentation (both are lacking here) is likely to lead to code base
which is difficult to comprehend and easy to get wrong.

> Having said that, I very much appreciate the work you have done
> in reviewing my patches and pointing out holes in them.  Please
> continue to do so and I will look at any real issues that you
> discover.

It isn't an accident that so many attempts in this thread were
errorneous.  You are taking the wrong approach and it's gonna cause
the same kind of failures in the future and there is no actual benefit
we're getting out of it.

> The same thing can still happen even if you use smp_load_acquire.
> Someone may add a read prior to it or add a second smp_load_acquire
> and then screw up the logic as we have seen in netlink_bind.

So, you're worrying about the following?

	portid = nlk->portid;
	if (nlk_bound(nlk)) {
		// use portid
	}

How is that even comparable?

> As I said whoever is touching these lockless code paths need to
> understand what is going on.  There is no easy way out.

There is a pretty wide gap between "no easy way out" and "lemme make
this as painful as possible so that people including myself get it
wrong most of the time for no good reason".

Thanks.

-- 
tejun
