From: Raivis Bucis <raivis@mt.lv>
Subject: [PATCH 2.4] Bugfix in neigh_create
Date: Fri, 7 Jan 2005 14:52:28 +0200
Message-ID: <200501071452.29006.raivis@mt.lv>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello,

I believe that there is a bug in neigh_create in linux-2.4.28 introduced by 
neighbor cache backport from v2.6.9.

New neigh entry hash_val was calculated before possible hash growth. So it got 
inserted in wrong place, making ARP entry (that was inserted immediately after 
hash growth) 
unresolvable until entry timeout.

It looked like this. The host did not answer to pings from some random host, 
but it could ping it after that with no problems. And vice versa.

Raivis Bucis

diff -uNr linux-2.4.28.org/net/core/neighbour.c 
linux-2.4.28/net/core/neighbour.c
--- linux-2.4.28.org/net/core/neighbour.c 2004-11-17 13:54:22.000000000 +0200
+++ linux-2.4.28/net/core/neighbour.c 2005-01-07 14:11:57.000000000 +0200
@@ -427,11 +427,12 @@
 
  n->confirmed = jiffies - (n->parms->base_reachable_time<<1);
 
- hash_val = tbl->hash(pkey, dev) & tbl->hash_mask;
-
  write_lock_bh(&tbl->lock);
  if (atomic_read(&tbl->entries) > (tbl->hash_mask + 1))
   neigh_hash_grow(tbl, (tbl->hash_mask + 1) << 1);
+
+ hash_val = tbl->hash(pkey, dev) & tbl->hash_mask;
+
  for (n1 = tbl->hash_buckets[hash_val]; n1; n1 = n1->next) {
   if (dev == n1->dev &&
       memcmp(n1->primary_key, pkey, key_len) == 0) {
