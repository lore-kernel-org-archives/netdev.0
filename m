From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [6/6]: jenkins hash for neigh
Date: Sat, 25 Sep 2004 20:31:16 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040925203116.4e6f9b06.davem@davemloft.net>
References: <20040923225158.23c2d502.davem@davemloft.net>
	<20040924085234.GE3236@sunbeam.de.gnumonks.org>
	<20040924142702.62a2b23d.davem@davemloft.net>
	<20040925064406.GL3236@sunbeam.de.gnumonks.org>
	<20040925005623.2faf8faf.davem@davemloft.net>
	<20040925090933.GU3236@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Harald Welte <laforge@gnumonks.org>
In-Reply-To: <20040925090933.GU3236@sunbeam.de.gnumonks.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 25 Sep 2004 11:09:33 +0200
Harald Welte <laforge@gnumonks.org> wrote:

> I am sure this is valid for IPv4 and IPv6.  How about other users of the
> neighbour cache, do they share this assumption?  I have to admit that I
> never looked throgh the ATM or 

As Steven Whitehouse mentioned for DecNET and I mentioned for ATM clip,
this is valid.

So consider the following as well.  Any time we send to a neighbour
we will generate a routing cache entry, 'dst', and we will stick it
to skb->dst.  This dst will have neighbour, and the SKB will sit
in the neighbour SKB queue until the neighbour entry is resolved
or it times out.

Therefore I think that test for INCOMPLETE in neigh_force_gc()
is even more rediculious.

Assuming that your test case runs fine with it, what I think we should
do is just forget about my 'diff4' changes to neigh_forced_gc(), and
instead remove that INCOMPLETE test entirely.  Then, neigh_forced_gc()
will simply remove all non-permanent entries with refcount of 1.

Finally, we could think about possibly doing the following:

1) Parameterizing neigh_forced_gc() so that it purges say "N"
   entries each run instead of scanning the entire hash table.
   Perhaps some fraction of tbl->entries

2) Look seriously into making more formal the relationship between
   the routing caches and neighbour cache.

What I mean by #2 is the following.  We know that the worst case
neighbour cache usage for a table is the size of the routing cache.
No routing cache entry, no reference to a corresponding neighbour
entry.  In this sense, all of these gc_thresh* values are superfluous.

What do people think about this?

As a side note, I checked BSD just for the usual shits and grins,
and they make no limits on ARP table growth.  Each routing table
entry may allocate a ARP resolution structure.  It is not exactly
stupid, frankly.

Really, if we got rid of all of this garbage collection crap we could
delete even that annoying message spit out by net/ipv4/route.c when
we run into the problems that made us work on these changes to begin
with.

At the very least, we should have a threshold to run forced GC but
failures to GC purge should not cause neigh_create() failures.
