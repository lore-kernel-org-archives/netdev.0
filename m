From: David Miller <davem@davemloft.net>
Subject: Re: Ottawa and slow hash-table resize
Date: Mon, 23 Feb 2015 17:32:52 -0500 (EST)
Message-ID: <20150223.173252.397503088215638994.davem@davemloft.net>
References: <20150223191201.GA4355@cloud>
	<20150223210358.GB806@casper.infradead.org>
	<20150223215248.GA15405@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, josh@joshtriplett.org, alexei.starovoitov@gmail.com,
	herbert@gondor.apana.org.au, kaber@trash.net,
	ying.xue@windriver.com, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: paulmck@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38506 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751959AbbBWWc4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Feb 2015 17:32:56 -0500
In-Reply-To: <20150223215248.GA15405@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Date: Mon, 23 Feb 2015 13:52:49 -0800

> On Mon, Feb 23, 2015 at 09:03:58PM +0000, Thomas Graf wrote:
>> On 02/23/15 at 11:12am, josh@joshtriplett.org wrote:
>> > In theory, resizes should only take the locks for the buckets they're
>> > currently unzipping, and adds should take those same locks.  Neither one
>> > should take a whole-table lock, other than resize excluding concurrent
>> > resizes.  Is that still insufficient?
>> 
>> Correct, this is what happens. The problem is basically that
>> if we insert from atomic context we cannot slow down inserts
>> and the table may not grow quickly enough.
>> 
>> > Yeah, the add/remove statistics used for tracking would need some
>> > special handling to avoid being a table-wide bottleneck.
>> 
>> Daniel is working on a patch to do per-cpu element counting
>> with a batched update cycle.
> 
> One approach is simply to count only when a resize operation is in
> flight.  Another is to keep a per-bucket count, which can be summed
> at the beginning of the next resize operation.

I think we should think exactly about what we should do when someone
loops non-stop adding 1 million entries to the hash table and the
initial table size is very small.

This is a common use case for at least one of the current rhashtable
users (nft_hash).  When you load an nftables rule with a large set
of IP addresses attached, this is what happens.

Yes I understand that nftables could give a hint and start with a
larger hash size from the start when it knows this is going to happen,
but I still believe that we should behave reasonably when starting
from a small table.

I'd say that with the way things work right now, in this situation it
actually hurts to allow asynchronous inserts during a resize.  Because
we end up with extremely long hash table chains, and thus make the
resize work and the lookups both take an excruciatingly long amount of
time to complete.

I just did a quick scan of all code paths that do inserts into an
rhashtable, and it seems like all of them can easily block.  So why
don't we do that?  Make inserts sleep on an rhashtable expansion
waitq.

There could even be a counter of pending inserts, so the expander can
decide to expand further before waking the inserting threads up.
