From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: rib_trie / Fix inflate_threshold_root. Now=15 size=11 bits
Date: Fri, 26 Jun 2009 10:05:38 -0700
Message-ID: <20090626170538.GK6771@linux.vnet.ibm.com>
References: <19012.49700.908412.410984@robur.slu.se> <20090626125449.GA8897@ff.dom.local> <20090626132820.GB8897@ff.dom.local> <19012.53943.734747.493480@robur.slu.se> <20090626151051.GA2714@ami.dom.local> <20090626153010.GC6771@linux.vnet.ibm.com> <20090626155410.GA6526@ami.dom.local> <20090626161500.GB6526@ami.dom.local> <20090626162340.GF6771@linux.vnet.ibm.com> <20090626164557.GB6755@ami.dom.local>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Robert Olsson <robert@robur.slu.se>,
	Robert Olsson <Robert.Olsson@data.slu.se>,
	Eric Dumazet <dada1@cosmosbay.com>,
	=?us-ascii?B?PT9JU08tODg1OS0yP1E/UGF3ZT1CM19TdGFzemV3c2tpPz0=?=
	<pstaszewski@itcare.pl>, Robert Olsson <robert.olsson@its.uu.se>,
	Linux Network Development list <netdev@vger.kernel.org>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e9.ny.us.ibm.com ([32.97.182.139]:43668 "EHLO e9.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754902AbZFZRFl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Jun 2009 13:05:41 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e9.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id n5QGrH40031472
	for <netdev@vger.kernel.org>; Fri, 26 Jun 2009 12:53:17 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n5QH5dIk255138
	for <netdev@vger.kernel.org>; Fri, 26 Jun 2009 13:05:39 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n5QH5cFG021295
	for <netdev@vger.kernel.org>; Fri, 26 Jun 2009 13:05:39 -0400
Content-Disposition: inline
In-Reply-To: <20090626164557.GB6755@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 26, 2009 at 06:45:57PM +0200, Jarek Poplawski wrote:
> On Fri, Jun 26, 2009 at 09:23:40AM -0700, Paul E. McKenney wrote:
> > On Fri, Jun 26, 2009 at 06:15:00PM +0200, Jarek Poplawski wrote:
> > > On Fri, Jun 26, 2009 at 05:54:10PM +0200, Jarek Poplawski wrote:
> > > > On Fri, Jun 26, 2009 at 08:30:10AM -0700, Paul E. McKenney wrote:
> > > > > On Fri, Jun 26, 2009 at 05:10:52PM +0200, Jarek Poplawski wrote:
> > > > > > On Fri, Jun 26, 2009 at 03:52:55PM +0200, Robert Olsson wrote:
> > > > > > > 
> > > > > > > Jarek Poplawski writes:
> > > > > > > 
> > > > > > >  Thanks, 
> > > > > > > 
> > > > > > >  Should be worth testing so we synchronize_rcu instead of doing call_rcu's
> > > > > > >  
> > > > > > 
> > > > > > Alas take 2 (nor 1) doesn't compile, so here it is again.
> > > > > 
> > > > > So the idea is to balance memory and latency, so that large changes
> > > > > (those affecting the root node) get at least one synchronize_rcu(),
> > > > > while smaller changes just use call_rcu(), correct?  This means that
> > > > > the amount of memory awaiting an RCU grace period is limited, but
> > > > > the algorithm avoids per-node synchronize_rcu() overhead.
> > > > > 
> > > > > If I understand the goal correctly, looks good!  (Give or take my
> > > > > limited understanding of fib_trie and is usage, of course.)
> > > > 
> > > > The goal is practically to replace all call_rcu() during
> > > > trie_rebalance() with synchronize_rcu() (except some freeing after
> > > > ENOMEM). I guess currently (<= 2.6.30) call_rcu() can free this
> > > > memory after trie_rebalance() has finished, that's why there were
> > > > problems with enabled preemption. So this patch tries to do/force
> > > > this a bit earlier - at least before the top/largest node is
> > > > rebalanced.
> > > 
> > > On the other hand, we could probably stay with call_rcu() plus only
> > > one synchronize_rcu() before the top node's resize() if you think it's
> > > enough here?
> > 
> > Well, my first task is to understand the problem/goal.  ;-)
> > 
> > My guess from what you said above is that use of call_rcu(), when
> > combined with changes to the trie in rapid succession, is resulting
> > in excessive memory awaiting a grace period.  Is this the case, or am I
> > confused?
> 
> Exactly! (I guess... ;-)

;-)

In that case, simply invoking synchronize_rcu() every once and awhile
should take care of things.  This could be at the end of every large
trie operation, or you could even count the call_rcu() invocations and
do a synchronize_rcu() every 100th, 1,000th, or whatever, based on
the amount of memory available.

							Thanx, Paul
