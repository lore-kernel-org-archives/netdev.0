From: David Miller <davem@davemloft.net>
Subject: Re: Ottawa and slow hash-table resize
Date: Tue, 24 Feb 2015 12:09:44 -0500 (EST)
Message-ID: <20150224.120944.866231994361475327.davem@davemloft.net>
References: <20150223230619.GD15405@linux.vnet.ibm.com>
	<20150224083714.GB17306@casper.infradead.org>
	<20150224103918.GJ3713@acer.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, paulmck@linux.vnet.ibm.com, josh@joshtriplett.org,
	alexei.starovoitov@gmail.com, herbert@gondor.apana.org.au,
	ying.xue@windriver.com, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: kaber@trash.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20150224103918.GJ3713@acer.localdomain>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Tue, 24 Feb 2015 10:39:18 +0000

> On 24.02, Thomas Graf wrote:
>> On 02/23/15 at 03:06pm, Paul E. McKenney wrote:
>> > On Mon, Feb 23, 2015 at 05:32:52PM -0500, David Miller wrote:
>> > > I just did a quick scan of all code paths that do inserts into an
>> > > rhashtable, and it seems like all of them can easily block.  So why
>> > > don't we do that?  Make inserts sleep on an rhashtable expansion
>> > > waitq.
>> > > 
>> > > There could even be a counter of pending inserts, so the expander can
>> > > decide to expand further before waking the inserting threads up.
>> > 
>> > Should be reasonably simple, and certainly seems worth a try!
>> 
>> Agreed. Definitely desirable for nft_hash. I like the pending counter
>> idea. I'm experimenting with various ideas on blocking inserts for
>> Netlink. Blocking too long might open DoS vectors as one app could
>> easily delay the creation of sockets for other applications.
> 
> Regarding nft_hash, blocking in the netlink path certainly seems fine,
> but we will soon also have inserts from the packet processing path,
> where we obviously can't block.

Indeed, I remembered last night that for TCP sockets blocking will not
work at all.

And having a flood of 1 million new TCP connections all at once
shouldn't knock us over.

Therefore, we will need to find a way to handle this problem without
being able to block on insert.

Thinking about this, if inserts occur during a pending resize, if the
nelems of the table has exceeded even the grow threshold for the new
table, it makes no sense to allow these async inserts as they are
going to make the resize take longer and prolong the pain.

On one hand I like the async resize because it means that an insert
that triggers the resize doesn't incur a huge latency spike since
it was simply unlucky to be the resize trigger event.  The async
resize smoothes out the cost of the resize across the system.

This scheme works really well if, on average, the resize operation
completes before enough subsequent inserts occur to exceed even
the resized tables resize threshold.

So I think what I'm getting at is that we can allow parallel inserts
but only up until the point where the resized tables thresholds are
exceeded.

Looking at how to implement this, I think that there is too much
configurability to this code.  There is no reason to have indirect
calls for the grow decision.  This should be a quick test, but it's
not because we go through ->grow_decision.  It should just be
rht_grow_above_75 or whatever, and inline this crap!

Nobody even uses this indirection capability, it's therefore over
engineered :-)

