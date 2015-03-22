From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [v2 PATCH 0/10] rhashtable: Multiple rehashing
Date: Sun, 22 Mar 2015 19:03:30 +1100
Message-ID: <20150322080330.GA3416@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>,
	Thomas Graf <tgraf@suug.ch>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Patrick McHardy <kaber@trash.net>,
	Josh Triplett <josh@joshtriplett.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:59484 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751621AbbCVIDy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Mar 2015 04:03:54 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi:                                           

This series introduces multiple rehashing.

Recall that the original implementation in br_multicast used
two list pointers per hash node and therefore is limited to at
most one rehash at a time since you need one list pointer for
the old table and one for the new table.

Thanks to Josh Triplett's suggestion of using a single list pointer
we're no longer limited by that.  So it is perfectly OK to have
an arbitrary number of tables in existence at any one time.

The reader and removal simply has to walk from the oldest table
to the newest table in order not to miss anything.  Insertion
without lookup are just as easy as we simply go to the last table
that we can find and add the entry there.

However, insertion with uniqueness lookup is more complicated
because we need to ensure that two simultaneous insertions of the
same key do not both succeed.  To achieve this, all insertions
including those without lookups are required to obtain the bucket
lock from the oldest hash table that is still alive.  This is
determined by having the rehasher (there is only one rehashing
thread in the system) keep a pointer of where it is up to.  If
a bucket has already been rehashed then it is dead, i.e., there
cannot be any more insertions to it, otherwise it is considered
alive.  This guarantees that the same key cannot be inserted
in two different tables in parallel.

Patch 1 is actually a bug fix for the walker.

Patch 2-6 eliminates unnecessary out-of-line copies of jhash.

Patch 7 disables automatic shrinking so now shrinking is only
possible if requested by the user.

Patch 8 introduces multiple rehashing.  This means that if we
decide to grow then we will grow regardless of whether the previous
one has finished.  However, this is still asynchronous meaning
that if insertions come fast enough we may still end up with a
table that is overutilised.

Patch 9 adds support for GFP_ATOMIC allocations of struct bucket_table.

Finally patch 10 enables immediate rehashing.  This is done either
when the table reaches 100% utilisation, or when the chain length
exceeds 16 (the latter can be disabled on request, e.g., for
nft_hash.

With these patches the system should no longer have any trouble
dealing with fast insertions on a small table.  In the worst
case you end up with a list of tables that's log N in length
while the rehasher catches up.

v2 fixes the blank subject of patch 5 and the prevents vzalloc
for GFP_ATOMIC callers in patch 9.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
