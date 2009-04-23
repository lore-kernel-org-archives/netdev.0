From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: htb parallelism on multi-core platforms
Date: Thu, 23 Apr 2009 20:19:36 +0200
Message-ID: <20090423181936.GA2756@ami.dom.local>
References: <20090423082052.GA4243@ff.dom.local> <1240495002.6554.155.camel@blade.ines.ro>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jesper Dangaard Brouer <hawk@diku.dk>,
	Denys Fedoryschenko <denys@visp.net.lb>, netdev@vger.kernel.org
To: Radu Rendec <radu.rendec@ines.ro>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f158.google.com ([209.85.220.158]:55465 "EHLO
	mail-fx0-f158.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751829AbZDWSTn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Apr 2009 14:19:43 -0400
Received: by fxm2 with SMTP id 2so699297fxm.37
        for <netdev@vger.kernel.org>; Thu, 23 Apr 2009 11:19:41 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1240495002.6554.155.camel@blade.ines.ro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 23, 2009 at 04:56:42PM +0300, Radu Rendec wrote:
> On Thu, 2009-04-23 at 08:20 +0000, Jarek Poplawski wrote:
> > Within a common tree of classes it would a need finer locking to
> > separate some jobs but considering cache problems I doubt there would
> > be much gain from such redesigning for smp. On the other hand, a
> > common tree is necessary if these classes really have to share every
> > byte, which I doubt. Then we could think of config and maybe tiny
> > hardware "redesign" (to more qdiscs/roots). So, e.g. using additional
> > (cheap) NICs and even switch, if possible, looks quite natural way of
> > spanning. Similar thing (multiple htb qdiscs) should be possible in
> > the future with one multiqueue NIC too.
> 
> Since htb has a tree structure by default, I think it's pretty difficult
> to distribute shaping across different htb-enabled queues. Actually we
> had thought of using completely separate machines, but soon we realized
> there are some issues. Consider the following example:
> 
> Customer A and customer B share 2 Mbit of bandwith. Each of them is
> guaranteed to reach 1 Mbit and in addition is able to "borrow" up to 1
> Mbit from the other's bandwith (depending on the other's traffic).
> 
> This is done like this:
> 
> * bucket C -> rate 2 Mbit, ceil 2 Mbit
> * bucket A -> rate 1 Mbit, ceil 2 Mbit, parent C
> * bucket B -> rate 1 Mbit, ceil 2 Mbit, parent C
> 
> IP filters for customer A classify packets to bucket A, and similar for
> customer B to bucket B.
> 
> It's obvious that buckets A, B and C must be in the same htb tree,
> otherwise customers A and B would not be able to borrow from each
> other's bandwidth. One simple rule would be to allocate all buckets
> (with all their child buckets) that have rate = ceil to the same tree /
> queue / whatever. I don't know if this is enough.

Yes, what I meant was rather a config with more individual clients eg.
20 x rate 50kbit ceil 100kbit. But, if you have many such rate = ceil
classes, separating them to another qdisc/NIC looks even better (no
problem with unbalanced load).

> > There is also an interesting thread "Software receive packet steering"
> > nearby, but using this for shaping only looks like "less simple":
> > http://lwn.net/Articles/328339/
> 
> I am aware of the thread and even tried out the author's patch (despite
> the fact that David Miller suggested it was not sane). Under heavy
> (simulated) traffic nothing was changed: only one ksoftirqd using 100%
> CPU, one CPU in 100%, others idle. This only confirms what I've already
> been told: htb is single threaded by design. It also proves that most of
> the packet processing work is actually in htb.

But, I wrote it's not simple. (And it was told about single threadedness
too.) This method is intended for a local traffic (to sockets) AFAIK, so
I thought about using some trick with virtual devs instead, but maybe
I'm totally wrong.

> 
> > BTW, I hope you add filters after classes they point to.
> 
> Do you mean the actual order I use for the "tc filter add" and "tc class
> add" commands? Does it make any difference?

Yes, I mean this order:
tc class add ... classid 1:23 ...
tc filter add ... flowid 1:23

> 
> Anyway, speaking of htb redesign or improvement (to use multiple
> threads / CPUs) I think classification rules can be cloned on a
> per-thread basis (to avoid synchronization issues). This means
> sacrificing memory for the benefit of performance but probably it is
> better to do it this way.
> 
> However, shaping data structures must be shared between all threads as
> long as it's not sure that all packets corresponding to a certain IP
> address are processed in the same thread (they most probably would not,
> if a round-robin alhorithm is used).
> 
> While searching the Internet for what has already been accomplished in
> this area, I ran several time across the per-CPU cache issue. The
> commonly accepted opinion seems to be that CPU parallelism in packet
> processing implies synchronization issues which in turn imply cache
> misses, which ultimately result in performance loss. However, with only
> one core in 100% and other 7 cores idle, I doubt that CPU-cache is
> really worth (it's just a guess and it definitely needs real tests as
> evidence).

There are many things to learn and to do around smp yet, just like
this "Software receive packet steering" thread shows. Anyway, there
are really big htb traffics handled as it is (look at Vyacheslav's
mail in this thread), so I guess you have something to do around your
config/hardware too.

Jarek P.
