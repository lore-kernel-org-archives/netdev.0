From: Thomas Graf <tgraf@suug.ch>
Subject: Re: Ottawa and slow hash-table resize
Date: Tue, 24 Feb 2015 17:50:14 +0000
Message-ID: <20150224175014.GA29802@casper.infradead.org>
References: <20150223230619.GD15405@linux.vnet.ibm.com>
 <20150224083714.GB17306@casper.infradead.org>
 <20150224103918.GJ3713@acer.localdomain>
 <20150224.120944.866231994361475327.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kaber@trash.net, paulmck@linux.vnet.ibm.com, josh@joshtriplett.org,
	alexei.starovoitov@gmail.com, herbert@gondor.apana.org.au,
	ying.xue@windriver.com, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:46984 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753144AbbBXRuU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Feb 2015 12:50:20 -0500
Content-Disposition: inline
In-Reply-To: <20150224.120944.866231994361475327.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/24/15 at 12:09pm, David Miller wrote:
> And having a flood of 1 million new TCP connections all at once
> shouldn't knock us over.
> 
> Therefore, we will need to find a way to handle this problem without
> being able to block on insert.

One possible way to handle this is to have users like TCP grow
quicker than 2x. Maybe start with 16x and grow slower and slower
using a log function. (No, we do not want rhashtable congestion
control algos ;-)

> Thinking about this, if inserts occur during a pending resize, if the
> nelems of the table has exceeded even the grow threshold for the new
> table, it makes no sense to allow these async inserts as they are
> going to make the resize take longer and prolong the pain.

Let's say we start with an initial table size of 16K (we can make
this system memory depenend) and we grow by 8x. New inserts go
into the new table immediately so as soon as we have 12K entries
we'll grow right to 128K buckets. As we grow above 75K we'll start
growing to 1024K buckets. New entries already go to the 1024K
buckets at this point given that the first grow cycle should be
fast. The 2nd grow cycle would take an est 6 RCU grace periods.
This would also still give us a max of 8K bucket locks which
should be good enough as well.

Just thinking this out loud. Still working on this.

> On one hand I like the async resize because it means that an insert
> that triggers the resize doesn't incur a huge latency spike since
> it was simply unlucky to be the resize trigger event.  The async
> resize smoothes out the cost of the resize across the system.
> 
> This scheme works really well if, on average, the resize operation
> completes before enough subsequent inserts occur to exceed even
> the resized tables resize threshold.
> 
> So I think what I'm getting at is that we can allow parallel inserts
> but only up until the point where the resized tables thresholds are
> exceeded.
> 
> Looking at how to implement this, I think that there is too much
> configurability to this code.  There is no reason to have indirect
> calls for the grow decision.  This should be a quick test, but it's
> not because we go through ->grow_decision.  It should just be
> rht_grow_above_75 or whatever, and inline this crap!
> 
> Nobody even uses this indirection capability, it's therefore over
> engineered :-)

Another option is to only call the grow_decision once every N inserts
or removals (32? 64?) and handle updates as batches. No objection
to ditching the grow/shrink function for now though. Not sure we
anyone actually needs different growth semantics.
