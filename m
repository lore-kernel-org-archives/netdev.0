From: Josh Triplett <josh@joshtriplett.org>
Subject: Re: [PATCH 4/4] rhashtable: Add parent argument to mutex_is_held
Date: Sat, 15 Nov 2014 11:12:20 -0800
Message-ID: <20141115191219.GA19060@thin>
References: <20141113101025.GA3728@gondor.apana.org.au>
 <E1XorN4-0000zn-0H@gondolin.me.apana.org.au>
 <20141113103723.GO19157@casper.infradead.org>
 <20141113103834.GA4024@gondor.apana.org.au>
 <20141113104124.GA24379@casper.infradead.org>
 <20141113104343.GA4112@gondor.apana.org.au>
 <20141115032512.GA19299@gondor.apana.org.au>
 <20141115111626.GP19157@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@vger.kernel.org,
	eric.dumazet@gmail.com, paulmck@linux.vnet.ibm.com
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay5-d.mail.gandi.net ([217.70.183.197]:57743 "EHLO
	relay5-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754305AbaKOTMb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Nov 2014 14:12:31 -0500
Content-Disposition: inline
In-Reply-To: <20141115111626.GP19157@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Nov 15, 2014 at 11:16:26AM +0000, Thomas Graf wrote:
> On 11/15/14 at 11:25am, Herbert Xu wrote:
> > On Thu, Nov 13, 2014 at 06:43:43PM +0800, Herbert Xu wrote:
> > > On Thu, Nov 13, 2014 at 10:41:24AM +0000, Thomas Graf wrote:
> > > >
> > > > Never mind. You did fix it. I looked at the wrong patch.
> > > 
> > > OK.  Now comes the fun part of shoehorning the xfrm_policy bydst
> > > hash into rhashtable :)
> > 
> > Thomas, it appears that rhashtable as it stands cannot handle
> > changing the random seed because of the way it constructs the
> > new hash table without degrading into a linked list.  Is there
> > something I'm missing?
> > 
> > FWIW my hashtable in net/bridge/br_multicast.c handles rehashing
> > correctly.  Any objections to me converting rhashtable to use my
> > scheme instead?
> 
> Can you elaborate a bit?
> 
> The point of rhashtable is to not require two sets of linked list
> pointers as done by MDB or OVS flow tables to work around the
> increased cache footprint of that approach. The difference of the
> two algos is dicussed in this paper [0].
> 
> The disadvantage of rhashtable is that, AFAIK, the hash function
> cannot change while resizing as it would break the mutual linked
> lists.

You can handle hash function changes with rhashtable without needing a
second set of linked-list pointers, actually.  You'd have to add ~1
unlikely() conditional to the reader common case, and you'd make readers
*during* a hash algorithm change (which I'd hope happens as rarely as a
resize) somewhat less efficient, but you wouldn't use any more memory
than a resize currently does, and you wouldn't use the memory of extra
linked-list pointers in the common case.

Rather than the current approach of switching out the hash table pointer
and having readers only search the new table (which will have
valid-but-crosslinked buckets during a resize), instead keep two hash
table pointers (each with their own hash parameters) and a single
toggleable old/new indicator.  Readers check both hash table pointers,
and if valid, check both tables, first old then new (order important to
make sure they don't miss a node).  Then, the rehashing algorithm can
incrementally move nodes from the old buckets to the new buckets,
*without* disrupting concurrent readers.

Rough rehashing algorithm sketch:

- Set up the new empty table with the new set of hash parameters.
- synchronize_rcu().  Readers will now search both old and new tables.
- Peel nodes off the ends of the old hash table and add them to the new
  hash table (similar to the unzip step in the resize algorithm).
  Because readers search old-then-new, and writers make each node appear
  in the new table before making it disappear from the old, you don't
  need a synchronize_rcu() here, just an smp_wmb() after linking the
  node into the new table and before unlinking the node from the old
  table.  Also, because you remove nodes from the *ends* of old-table
  buckets, you don't have to worry about a reader's linked-list walk
  getting dragged over to the new table and missing nodes from the old
  one.
- Once all nodes have moved to the new table, mark the pointer to the
  old table as NULL, synchronize_rcu(), and free the old table.
- Toggle the old/new flag.

Ordering principles in this algorithm:
- You want readers to see the changes made by the rehasher in order.
- If the reader reads location A then B, and the rehasher writes
  location B then A, the rehasher just needs an smp_wmb() in between.
- If the reader reads location A then B, and the rehasher writes
  location A then B, the rehasher needs a synchronize_rcu() in between.


- Josh Triplett
