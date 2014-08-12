From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH stable 3.4 1/2] ipv4: move route garbage collector to
 work queue
Date: Tue, 12 Aug 2014 15:42:55 -0700 (PDT)
Message-ID: <20140812.154255.2235928819945086905.davem@davemloft.net>
References: <1407869404.27163.5.camel@localhost>
	<1407875003.6804.0.camel@edumazet-glaptop2.roam.corp.google.com>
	<1407879692.16087.5.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, mleitner@redhat.com, netdev@vger.kernel.org
To: hannes@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39677 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751284AbaHLWm4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Aug 2014 18:42:56 -0400
In-Reply-To: <1407879692.16087.5.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@redhat.com>
Date: Tue, 12 Aug 2014 23:41:32 +0200

> Hi Eric,
> 
> On Di, 2014-08-12 at 13:23 -0700, Eric Dumazet wrote:
>> On Tue, 2014-08-12 at 20:50 +0200, Hannes Frederic Sowa wrote:
>> > On Mo, 2014-08-11 at 19:41 -0300, Marcelo Ricardo Leitner wrote:
>> > > Currently the route garbage collector gets called by dst_alloc() if it
>> > > have more entries than the threshold. But it's an expensive call, that
>> > > don't really need to be done by then.
>> > > 
>> > > Another issue with current way is that it allows running the garbage
>> > > collector with the same start parameters on multiple CPUs at once, which
>> > > is not optimal. A system may even soft lockup if the cache is big enough
>> > > as the garbage collectors will be fighting over the hash lock entries.
>> > > 
>> > > This patch thus moves the garbage collector to run asynchronously on a
>> > > work queue, much similar to how rt_expire_check runs.
>> > > 
>> > > There is one condition left that allows multiple executions, which is
>> > > handled by the next patch.
>> > > 
>> > > Signed-off-by: Marcelo Ricardo Leitner <mleitner@redhat.com>
>> > > Cc: Hannes Frederic Sowa <hannes@redhat.com>
>> > 
>> > Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
>> 
>> 
>> This does not look as stable material.
> 
> We hesitated at first, too, to send those out.
> 
> We had a machine being brought down by production traffic while using
> TPROXY. The routing cache, while still having a relatively good hit
> ratio, was filled with combinations of source and destination addresses.
> Multiple GCs running and trying to grab the same per-chain spin_lock
> caused a complete lockdown of the machine. That's why we submitted those
> patches for review in the end.
> 
>> One can always disable route cache in 3.4 kernels
> 
> Sure, but we didn't like the fact that it is possible to bring down the
> machine in the first place.

I think I can handle this first patch for 3.4/3.2 -stable, it is very
straightforward and deals with what are actually purely asynchronous
invocations of garbage collection anyways.

Although this needs to be reformatted properly:

+	if (dst_entries_get_fast(&ipv4_dst_ops) >= ip_rt_max_size ||
+		dst_entries_get_slow(&ipv4_dst_ops) >= ip_rt_max_size) {

The second line needs to start at the first column after the openning
parenthesis of the if () statement.

The second patch, on the other hand, needs some more thought.  It is
changing behavior, in that cases that would have succeeded in the past
will now potentially fail only because the neighbour cache limits were
hit at an unlucky moment (when an async GC was going already).

If this happens from a software interrupt, we'll fail instantly
because attempts starts at 0.

Just bite the bullet and put a spinlock around the GC operation.

The async GCs are normal on a loaded machine, whereas the neighbour
tables filling up is much less so.  I think having the neighbout
overflow path synchronize with async GCs is therefore not going to be
a real problem in practice.
