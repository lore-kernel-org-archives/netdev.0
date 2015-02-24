From: josh@joshtriplett.org
Subject: Re: Ottawa and slow hash-table resize
Date: Tue, 24 Feb 2015 10:33:46 -0800
Message-ID: <20150224183346.GA10713@cloud>
References: <20150223230619.GD15405@linux.vnet.ibm.com>
 <20150224083714.GB17306@casper.infradead.org>
 <20150224103918.GJ3713@acer.localdomain>
 <20150224.120944.866231994361475327.davem@davemloft.net>
 <20150224175014.GA29802@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, kaber@trash.net,
	paulmck@linux.vnet.ibm.com, alexei.starovoitov@gmail.com,
	herbert@gondor.apana.org.au, ying.xue@windriver.com,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay3-d.mail.gandi.net ([217.70.183.195]:51284 "EHLO
	relay3-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753144AbbBXSdx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Feb 2015 13:33:53 -0500
Content-Disposition: inline
In-Reply-To: <20150224175014.GA29802@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 24, 2015 at 05:50:14PM +0000, Thomas Graf wrote:
> On 02/24/15 at 12:09pm, David Miller wrote:
> > And having a flood of 1 million new TCP connections all at once
> > shouldn't knock us over.
> > 
> > Therefore, we will need to find a way to handle this problem without
> > being able to block on insert.
> 
> One possible way to handle this is to have users like TCP grow
> quicker than 2x. Maybe start with 16x and grow slower and slower
> using a log function. (No, we do not want rhashtable congestion
> control algos ;-)
> 
> > Thinking about this, if inserts occur during a pending resize, if the
> > nelems of the table has exceeded even the grow threshold for the new
> > table, it makes no sense to allow these async inserts as they are
> > going to make the resize take longer and prolong the pain.
> 
> Let's say we start with an initial table size of 16K (we can make
> this system memory depenend) and we grow by 8x. New inserts go
> into the new table immediately so as soon as we have 12K entries
> we'll grow right to 128K buckets. As we grow above 75K we'll start
> growing to 1024K buckets. New entries already go to the 1024K
> buckets at this point given that the first grow cycle should be
> fast. The 2nd grow cycle would take an est 6 RCU grace periods.
> This would also still give us a max of 8K bucket locks which
> should be good enough as well.
> 
> Just thinking this out loud. Still working on this.

I agree.  Client systems should start with the smallest possible table
size and memory usage (just enough for dozens or hundreds of
connections), and possibly never grow past that.  Any system processing
a non-trivial number of connections, however, wants to very quickly grow
to a substantial number of buckets.  The unzipping algorithm works just
fine for any integer growth factor; it just gets a bit more complicated.

One nice thing is that the resize algorithm very quickly allocates the
new buckets and sets up the head pointers such that the new table can be
used for inserts almost immediately, *without* a synchronize_rcu.  Only
the bucket unzipping process takes a non-trivial amount of time
(including one or more synchronize_rcu calls).  And the newly inserted
entries will go directly to the appropriate buckets, so they'll take
advantage of the larger table size.

> > On one hand I like the async resize because it means that an insert
> > that triggers the resize doesn't incur a huge latency spike since
> > it was simply unlucky to be the resize trigger event.  The async
> > resize smoothes out the cost of the resize across the system.
> > 
> > This scheme works really well if, on average, the resize operation
> > completes before enough subsequent inserts occur to exceed even
> > the resized tables resize threshold.
> > 
> > So I think what I'm getting at is that we can allow parallel inserts
> > but only up until the point where the resized tables thresholds are
> > exceeded.
> > 
> > Looking at how to implement this, I think that there is too much
> > configurability to this code.  There is no reason to have indirect
> > calls for the grow decision.  This should be a quick test, but it's
> > not because we go through ->grow_decision.  It should just be
> > rht_grow_above_75 or whatever, and inline this crap!
> > 
> > Nobody even uses this indirection capability, it's therefore over
> > engineered :-)
> 
> Another option is to only call the grow_decision once every N inserts
> or removals (32? 64?) and handle updates as batches.

If we have a means of tracking the number of inserts, we already have
the ability to make the decision, which is just a single comparison.  No
need to batch, since the decision of whether to check would *also*
require a comparison.

I do think this should just use the same growth function everywhere
until a user comes along that needs something different.

- Josh Triplett
