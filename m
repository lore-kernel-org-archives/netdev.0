From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [6/6]: jenkins hash for neigh
Date: Fri, 24 Sep 2004 14:27:02 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040924142702.62a2b23d.davem@davemloft.net>
References: <20040923225158.23c2d502.davem@davemloft.net>
	<20040924085234.GE3236@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Harald Welte <laforge@gnumonks.org>
In-Reply-To: <20040924085234.GE3236@sunbeam.de.gnumonks.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 24 Sep 2004 10:52:34 +0200
Harald Welte <laforge@gnumonks.org> wrote:

> So this means you put get_random_bytes into the __init function.  I
> explicitly didn't want to do that (and added that _initted variable),
> since at bootup time we might not have sufficient entropy yet.

Good point.

> If we defer get_random_bytes() until the first neighbour is created,
> this gives the system some more time to gather entropy...  
 ...
> Also, wouldn't it make sense to use a new random value if we grow the
> hash table?  I mean it's cheap, and we make it harder for someone trying
> a hash-based attack.  

I've combined all of your thoughts into the patch below.
We set the initial ARP table very small (2 chains), and we
regenerate the random seed every time we grow the hash table.

This should address all of your concerns.

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/09/24 14:06:45-07:00 davem@nuts.davemloft.net 
#   [NET]: Neighbour hashing tweaks.
#   
#   1) Start with a smaller initial hash table size.
#      This stresses the new code better.
#   2) Generate a new hash_rnd every time we grow
#      the hashes.
#   
#   Based upon commentary from Harald Welte.
#   
#   Signed-off-by: David S. Miller <davem@davemloft.net>
# 
# net/core/neighbour.c
#   2004/09/24 14:06:02-07:00 davem@nuts.davemloft.net +2 -1
#   [NET]: Neighbour hashing tweaks.
#   
#   1) Start with a smaller initial hash table size.
#      This stresses the new code better.
#   2) Generate a new hash_rnd every time we grow
#      the hashes.
#   
#   Based upon commentary from Harald Welte.
#   
#   Signed-off-by: David S. Miller <davem@davemloft.net>
# 
diff -Nru a/net/core/neighbour.c b/net/core/neighbour.c
--- a/net/core/neighbour.c	2004-09-24 14:07:07 -07:00
+++ b/net/core/neighbour.c	2004-09-24 14:07:07 -07:00
@@ -331,6 +331,7 @@
 	old_hash = tbl->hash_buckets;
 
 	write_lock_bh(&tbl->lock);
+	get_random_bytes(&tbl->hash_rnd, sizeof(tbl->hash_rnd));
 	for (i = 0; i < old_entries; i++) {
 		struct neighbour *n, *next;
 
@@ -1306,7 +1307,7 @@
 	if (!tbl->kmem_cachep)
 		panic("cannot create neighbour cache");
 
-	tbl->hash_mask = 0x1f;
+	tbl->hash_mask = 1;
 	tbl->hash_buckets = neigh_hash_alloc(tbl->hash_mask + 1);
 
 	phsize = (PNEIGH_HASHMASK + 1) * sizeof(struct pneigh_entry *);
