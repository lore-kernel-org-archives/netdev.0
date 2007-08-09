From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [RFC NET_SCHED 00/02]: Flexible SFQ flow classification
Date: Wed, 8 Aug 2007 21:12:07 -0700
Message-ID: <20070809041207.GA21106@linux.vnet.ibm.com>
References: <20070530094020.24073.84277.sendpatchset@localhost.localdomain> <1180536987.4109.19.camel@localhost>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:55914 "EHLO e4.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750792AbXHIEMJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Aug 2007 00:12:09 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e4.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l794C9dv020768
	for <netdev@vger.kernel.org>; Thu, 9 Aug 2007 00:12:09 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.4) with ESMTP id l794C90h555088
	for <netdev@vger.kernel.org>; Thu, 9 Aug 2007 00:12:09 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l794C8CS001988
	for <netdev@vger.kernel.org>; Thu, 9 Aug 2007 00:12:09 -0400
Content-Disposition: inline
In-Reply-To: <1180536987.4109.19.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 30, 2007 at 10:56:27AM -0400, jamal wrote:
> 
> On Wed, 2007-30-05 at 11:40 +0200, Patrick McHardy wrote:
> > One good thing about ESFQ is the more flexible flow classification, but
> > I don't like the concept of having a set of selectable hash functions
> > very much.
> > 
> 
> In the spirit of SFQ it is probably ok to do that; 
> i.e iirc,  the idea for justification behind sfq was to provide a
> "computationaly feasible/reasonable" way to provide fair queueing with a
> gazillion queues. 
> Classification was considered damn expensive in those days (when MC68K
> was sort of state of the art); it still is but maybe a much much lesser
> issue now for what "gazillion" was in those days. So a simple hash on a
> few fields with pertubation (the part that makes allows the "stochastic"
> part in the name) was deemed the way to go and in order to provide
> fairness (while avoiding packet reordering).
> So if you want to keep that spirit it is ok to do what ESFQ does;
> I think the assumptions will still be valid if you have a gazillion
> queues in todays terms. A number like say 128K may make sense.
> (Hey Paul M is still around, just too focused on the wrong things like
> RCU;-> so we can ask his opinion)

Not only that, he is -really- slow about getting to some of his email
sometimes.  :-/  In my defense, if you CC me, I will spot it more quickly.

Yeah, the 1980s were indeed over a -long- time ago, and architectures
certainly have changed.  I wrote my first parallel kernel code about
a year after the SFQ paper was published, and not too many years after
that began my longstanding RCU habit.  And not only did I inhale at
the time, I am still inhaling deeply.  ;-)

In any case, if you can feasibly do an exact classification, then doing so
would most likely be better than using SFQ.  And with today's hardware,
exact classifications are much reasonable than they were back on my old
handful-of-MHz 68K-based Sun workstation.  If an exact classification is
unworkable, but you absolutely have to maintain perfect ordering, then
one approach is to let the SFQ drain before perturbing the hash function.

One way to do this is to have a pair of hash tables, and switch back and
forth between them on each perturbation.  Perturbation then goes as follows:

1.	Select a new hash perturbation value, and associate it with the
	currently-unused hash table (call it B).

2.	Swing pointers so that subsequent incoming packets go to B.

3.	Continue outputting from A until it is drained.  If the
	perturbation is lockless, you might need to ensure that a
	grace period passes during this drain operation.  (Yep, still
	inhaling!!!)

4.	Start outputting packets from B.

But there might be better approaches.

> > These patches change SFQ to allow attaching external classifiers and add
> > a new "flow" classifier that allows to classify flows based on an arbitary
> > combination of pre-defined keys. Its probably not the fastest classifier
> > when used with multiple keys, but frankly, I don't think speed is very
> > important in most situations where the current SFQ implementation is used.
> 
> The only one thing i noticed that changes the behavior is the use of
> skb->prio as a selector. I think if you removed that it should be fine.
> Another alternative is to create a brand new FQ qdisc and leave the
> classification to the classifiers.
> 
> > It currently does not support perturbation, I didn't want to move this into
> > the classifier, so I need to think about a way to handle it within SFQ.
> 
> It is kind of hard to put it back into the current approach because the
> basic assumptions of ensuring no re-ordering and a "fast" classifier are
> gone.
> 
> I am almost tempted to say go back and write a qdisc called FQ.

And this might well be a better approach.  ;-)

							Thanx, Paul

> cheers,
> jamal
> 
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
