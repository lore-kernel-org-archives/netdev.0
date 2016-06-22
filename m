From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH RFC] sched: split classification and enqueue
Date: Wed, 22 Jun 2016 11:15:52 -0700
Message-ID: <20160622111552.30f64c35@xeon-e3>
References: <1466589835-18521-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:36529 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752542AbcFVSRb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jun 2016 14:17:31 -0400
Received: by mail-pa0-f41.google.com with SMTP id wo6so19051490pac.3
        for <netdev@vger.kernel.org>; Wed, 22 Jun 2016 11:17:30 -0700 (PDT)
In-Reply-To: <1466589835-18521-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 22 Jun 2016 12:03:55 +0200
Florian Westphal <fw@strlen.de> wrote:

> Currently classification and enqueue is done in a single step.
> 
> core acquires the qdisc lock, then calls the ->enqueue() function
> of the qdisc.
> 
> Its the job of the qdisc and its attached classifiers to figure out what
> to do next.
> 
> Typically the enqueue function will call tc_classify() to lookup a
> child class, then call ->enqueue of the child qdisc.
> 
> This can repeat a number of times until a leaf qdisc is reached; this leaf
> will do the real enqueue operation (pfifo for example).
> 
> While this approach gives qdiscs and the classifier/action subsystem
> a lot of control, it has one major drawback:  The root qdisc lock
> is held for a prolonged period of time while we recurse through
> the qdisc hierarchy from root to leaf.
> 
> This (unfinished!) hack splits classification and enqueue into
> two steps.
> 
> Before enqueueing the packet and *before* acquiring the root qdisc lock,
> the new qdisc ->classify() function is invoked.
> 
> This function -- much like enqueue in the current scheme -- looks up
> a child class and/or determines the next qdisc where the packet needs
> to be handled via the classifier action subsystem.
> Then it invokes the new ->classify() hook of the child, which can repeat
> until the leaf qdisc is reached.
> 
> Whenever a classify operation has succeeded, each classify "level"
> stores itself (qdisc) and a cookie (typically just a pointer to the
> class) in the newly added Qdisc_classify_state struct.
> 
> After qdisc_classify returns, this struct contains the path that
> the skb is supposed to take through the qdisc hierarchy in *reverse*
> order, i.e. starting from the leaf up to the root.
> 
> Then, the root qdisc lock is taken and the *leaf* (first entry in
> Qdisc_classify_state) ->enqueue function is invoked.
> 
> If this succeeds, the kernel will invoke the new ->senqeue
> function for all the remaining entries in Qdisc_classify_state.
> 
> This function is responsible to perform needed qdisc internal actions,
> f.e. scheduling a class for transmit.
> 
> This reduces the amount of work done under qdisc root lock.
> Very simple test w. hfsc + u32 filter, gso off, 10G link and 20 netperf
> TCP_STREAM:
> 
>   before: 8.2 GB/s
>   after: 9.4 GB/s (same as w. mq+fq_codel)
> 
> Known issues with this patch:
>  - only converted a few qdiscs
>  - qdisc stats will race since they're changed outside of root lock.
>  - need to protect vs. class removal during classify ops
>  - mirred needs some work for this (but not worse than current situation)
>  - use-after-free in some places, need to ensure that skb remains valid
>    iff enqueue returns != DROP.
>  - senqeue is a horrid name.  It is probably better to split qdiscs
>    into leaf and non-leaf ones, where leaf qdiscs implement ->enqueue() and
>    the others a notify_enqueue() (which doesn't return a value).
> 
> So far I did not see any fundamental issues with this approach.
> 
> If you see any, I'd be happy to learn about them before I spend more
> cycles on this.  The main work to be done is to convert qstats to
> percpu counters and then convert all the qdiscs to this new scheme,
> and of course to extend this to all intree schedulers.
> 
> If you attend NF workshop in Amsterdam feel free to yell at me in person there.
> ---
>  include/net/sch_generic.h | 50 +++++++++++++++++++++++++++++++++
>  net/core/dev.c            | 10 ++++++-
>  net/sched/sch_drr.c       | 38 +++++++++++++++++++++++--
>  net/sched/sch_fq_codel.c  | 71 +++++++++++++++++++++++++++++++++++++++++++++--
>  net/sched/sch_generic.c   | 32 +++++++++++++++++++++
>  net/sched/sch_hfsc.c      | 38 +++++++++++++++++++++++--
>  6 files changed, 232 insertions(+), 7 deletions(-)
> 

The architecture of linux packet scheduler makes this too racy.
Classification can be attached to different nodes on the hierarchy, and the
hierarchy could change underneath.

It is a good idea, but maybe would be better to have a separate classification
step before scheduler (use BPF) and put meta-data in skb. That way it could
be safely lockless and atomic.
