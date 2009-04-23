From: Radu Rendec <radu.rendec@ines.ro>
Subject: Re: htb parallelism on multi-core platforms
Date: Thu, 23 Apr 2009 16:56:42 +0300
Message-ID: <1240495002.6554.155.camel@blade.ines.ro>
References: <20090423082052.GA4243@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <hawk@diku.dk>,
	Denys Fedoryschenko <denys@visp.net.lb>, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from NAT-172-Unkn.Local.iNES.RO ([80.86.100.172]:36315 "EHLO
	blade.ines.ro" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751565AbZDWN4u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Apr 2009 09:56:50 -0400
In-Reply-To: <20090423082052.GA4243@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2009-04-23 at 08:20 +0000, Jarek Poplawski wrote:
> Within a common tree of classes it would a need finer locking to
> separate some jobs but considering cache problems I doubt there would
> be much gain from such redesigning for smp. On the other hand, a
> common tree is necessary if these classes really have to share every
> byte, which I doubt. Then we could think of config and maybe tiny
> hardware "redesign" (to more qdiscs/roots). So, e.g. using additional
> (cheap) NICs and even switch, if possible, looks quite natural way of
> spanning. Similar thing (multiple htb qdiscs) should be possible in
> the future with one multiqueue NIC too.

Since htb has a tree structure by default, I think it's pretty difficult
to distribute shaping across different htb-enabled queues. Actually we
had thought of using completely separate machines, but soon we realized
there are some issues. Consider the following example:

Customer A and customer B share 2 Mbit of bandwith. Each of them is
guaranteed to reach 1 Mbit and in addition is able to "borrow" up to 1
Mbit from the other's bandwith (depending on the other's traffic).

This is done like this:

* bucket C -> rate 2 Mbit, ceil 2 Mbit
* bucket A -> rate 1 Mbit, ceil 2 Mbit, parent C
* bucket B -> rate 1 Mbit, ceil 2 Mbit, parent C

IP filters for customer A classify packets to bucket A, and similar for
customer B to bucket B.

It's obvious that buckets A, B and C must be in the same htb tree,
otherwise customers A and B would not be able to borrow from each
other's bandwidth. One simple rule would be to allocate all buckets
(with all their child buckets) that have rate = ceil to the same tree /
queue / whatever. I don't know if this is enough.

> There is also an interesting thread "Software receive packet steering"
> nearby, but using this for shaping only looks like "less simple":
> http://lwn.net/Articles/328339/

I am aware of the thread and even tried out the author's patch (despite
the fact that David Miller suggested it was not sane). Under heavy
(simulated) traffic nothing was changed: only one ksoftirqd using 100%
CPU, one CPU in 100%, others idle. This only confirms what I've already
been told: htb is single threaded by design. It also proves that most of
the packet processing work is actually in htb.

> BTW, I hope you add filters after classes they point to.

Do you mean the actual order I use for the "tc filter add" and "tc class
add" commands? Does it make any difference?

Anyway, speaking of htb redesign or improvement (to use multiple
threads / CPUs) I think classification rules can be cloned on a
per-thread basis (to avoid synchronization issues). This means
sacrificing memory for the benefit of performance but probably it is
better to do it this way.

However, shaping data structures must be shared between all threads as
long as it's not sure that all packets corresponding to a certain IP
address are processed in the same thread (they most probably would not,
if a round-robin alhorithm is used).

While searching the Internet for what has already been accomplished in
this area, I ran several time across the per-CPU cache issue. The
commonly accepted opinion seems to be that CPU parallelism in packet
processing implies synchronization issues which in turn imply cache
misses, which ultimately result in performance loss. However, with only
one core in 100% and other 7 cores idle, I doubt that CPU-cache is
really worth (it's just a guess and it definitely needs real tests as
evidence).

Thanks,

Radu Rendec


