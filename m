From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: Re: [tbench regression fixes]: digging out smelly deadmen.
Date: Sat, 11 Oct 2008 16:39:07 +0200
Message-ID: <1223735947.8485.33.camel@twins>
References: <20081009231759.GA8664@tservice.net.ru>
	 <1223633623.4138.86.camel@marge.simson.net>
	 <20081011131352.GA16908@tservice.net.ru>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Mike Galbraith <efault@gmx.de>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Ingo Molnar <mingo@elte.hu>,
	David Miller <davem@davemloft.net>
To: Evgeniy Polyakov <s0mbre@tservice.net.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from viefep18-int.chello.at ([213.46.255.22]:38104 "EHLO
	viefep12-int.chello.at" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753304AbYJKOjD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Oct 2008 10:39:03 -0400
In-Reply-To: <20081011131352.GA16908@tservice.net.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2008-10-11 at 17:13 +0400, Evgeniy Polyakov wrote:
> Hi Mike.
> 
> On Fri, Oct 10, 2008 at 12:13:43PM +0200, Mike Galbraith (efault@gmx.de) wrote:
> > a7be37a adds some math overhead, calls to calc_delta_mine() per
> > wakeup/context switch for all weight tasks, whereas previously these
> > calls were only made for tasks which were not nice 0.  It also shifts
> > performance a bit in favor of loads which dislike wakeup preemption,
> 
> I believe anyone dislikes this :)
> 
> > this effect lessens as task count increases.  Per testing, overhead is
> > not the primary factor in throughput loss.  I believe clock accuracy to
> > be a more important factor than overhead by a very large margin.
> 
> In my tests it was not just overhead, it was a disaster.
> And stopping just before this commit gained 20 MB/s out of 30 MB/s lose
> for 26-27 window. No matter what accuracy it brings, this is just wrong
> to assume that such performance drop in some workloads is justified.
> What this accuracy is needed for?

a7be37a 's purpose is for group scheduling where it provides means to
calculate things in a unform metric.

If you take the following scenario:

    R
   /|\
  A 1 B
 /|\  |
2 3 4 5

Where letters denote supertasks/groups and digits are tasks.

We used to look at a single level only, so if you want to compute a
task's ideal runtime, you'd take:

  runtime_i = period w_i / \Sum_i w_i

So, in the above example, assuming all entries have an equal weight,
we'd want to run A for p/3. But then we'd also want to run 2 for p/3.
IOW. all of A's tasks would run in p time.

Which in contrairy to the expectation that all tasks in the scenario
would run in p.

So what the patch does is change the calculation to:

  period \Prod_l w_l,i / \Sum_i w_l,i

Which would, for 2 end up being: p 1/3 1/3 = p/9.

Now the thing that causes the extra math in the !group case is that for
the single level case, we can avoid doing that division by the sum,
because that is equal for all tasks (we then compensate for it at some
other place).

However, for the nested case, we cannot do that.

That said, we can probably still avoid the division for the top level
stuff, because the sum of the top level weights is still invariant
between all tasks.

I'll have a stab at doing so... I initially didn't do this because my
first try gave some real ugly code, but we'll see - these numbers are a
very convincing reason to try again.

