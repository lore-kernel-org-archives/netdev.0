From: "David S. Miller" <davem@davemloft.net>
Subject: [2/6]: Move hash masking to call sites
Date: Thu, 23 Sep 2004 22:49:21 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040923224921.3461f7a8.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: laforge@gnumonks.org
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Another step towards moving all hashing details
into net/core/neighbour.c

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/09/23 15:20:38-07:00 davem@nuts.davemloft.net 
#   [NET]: Apply NEIGH_HASHMASK at tbl->hash() caller.
#   
#   Now there is no reason for any neigh implementation
#   to know the value of {P,}NEIGH_HASHMASK
#   
#   Signed-off-by: David S. Miller <davem@davemloft.net>
# 
# net/ipv6/ndisc.c
#   2004/09/23 15:20:09-07:00 davem@nuts.davemloft.net +1 -1
#   [NET]: Apply NEIGH_HASHMASK at tbl->hash() caller.
#   
#   Now there is no reason for any neigh implementation
#   to know the value of {P,}NEIGH_HASHMASK
#   
#   Signed-off-by: David S. Miller <davem@davemloft.net>
# 
# net/ipv4/arp.c
#   2004/09/23 15:20:09-07:00 davem@nuts.davemloft.net +1 -1
#   [NET]: Apply NEIGH_HASHMASK at tbl->hash() caller.
#   
#   Now there is no reason for any neigh implementation
#   to know the value of {P,}NEIGH_HASHMASK
#   
#   Signed-off-by: David S. Miller <davem@davemloft.net>
# 
# net/decnet/dn_neigh.c
#   2004/09/23 15:20:09-07:00 davem@nuts.davemloft.net +1 -1
#   [NET]: Apply NEIGH_HASHMASK at tbl->hash() caller.
#   
#   Now there is no reason for any neigh implementation
#   to know the value of {P,}NEIGH_HASHMASK
#   
#   Signed-off-by: David S. Miller <davem@davemloft.net>
# 
# net/core/neighbour.c
#   2004/09/23 15:20:09-07:00 davem@nuts.davemloft.net +2 -2
#   [NET]: Apply NEIGH_HASHMASK at tbl->hash() caller.
#   
#   Now there is no reason for any neigh implementation
#   to know the value of {P,}NEIGH_HASHMASK
#   
#   Signed-off-by: David S. Miller <davem@davemloft.net>
# 
# net/atm/clip.c
#   2004/09/23 15:20:09-07:00 davem@nuts.davemloft.net +1 -1
#   [NET]: Apply NEIGH_HASHMASK at tbl->hash() caller.
#   
#   Now there is no reason for any neigh implementation
#   to know the value of {P,}NEIGH_HASHMASK
#   
#   Signed-off-by: David S. Miller <davem@davemloft.net>
# 
diff -Nru a/net/atm/clip.c b/net/atm/clip.c
--- a/net/atm/clip.c	2004-09-23 22:26:08 -07:00
+++ b/net/atm/clip.c	2004-09-23 22:26:08 -07:00
@@ -334,7 +334,7 @@
 	hash_val ^= (hash_val>>16);
 	hash_val ^= hash_val>>8;
 	hash_val ^= hash_val>>3;
-	hash_val = (hash_val^dev->ifindex)&NEIGH_HASHMASK;
+	hash_val = (hash_val^dev->ifindex);
 
 	return hash_val;
 }
diff -Nru a/net/core/neighbour.c b/net/core/neighbour.c
--- a/net/core/neighbour.c	2004-09-23 22:26:08 -07:00
+++ b/net/core/neighbour.c	2004-09-23 22:26:08 -07:00
@@ -291,7 +291,7 @@
 {
 	struct neighbour *n;
 	int key_len = tbl->key_len;
-	u32 hash_val = tbl->hash(pkey, dev);
+	u32 hash_val = tbl->hash(pkey, dev) & NEIGH_HASHMASK;
 
 	read_lock_bh(&tbl->lock);
 	for (n = tbl->hash_buckets[hash_val]; n; n = n->next) {
@@ -336,7 +336,7 @@
 
 	n->confirmed = jiffies - (n->parms->base_reachable_time << 1);
 
-	hash_val = tbl->hash(pkey, dev);
+	hash_val = tbl->hash(pkey, dev) & NEIGH_HASHMASK;
 
 	write_lock_bh(&tbl->lock);
 	if (n->parms->dead) {
diff -Nru a/net/decnet/dn_neigh.c b/net/decnet/dn_neigh.c
--- a/net/decnet/dn_neigh.c	2004-09-23 22:26:08 -07:00
+++ b/net/decnet/dn_neigh.c	2004-09-23 22:26:08 -07:00
@@ -128,7 +128,7 @@
 	hash_val ^= (hash_val >> 10);
 	hash_val ^= (hash_val >> 3);
 
-	return hash_val & NEIGH_HASHMASK;
+	return hash_val;
 }
 
 static int dn_neigh_construct(struct neighbour *neigh)
diff -Nru a/net/ipv4/arp.c b/net/ipv4/arp.c
--- a/net/ipv4/arp.c	2004-09-23 22:26:08 -07:00
+++ b/net/ipv4/arp.c	2004-09-23 22:26:08 -07:00
@@ -229,7 +229,7 @@
 	hash_val ^= (hash_val>>16);
 	hash_val ^= hash_val>>8;
 	hash_val ^= hash_val>>3;
-	hash_val = (hash_val^dev->ifindex)&NEIGH_HASHMASK;
+	hash_val = (hash_val^dev->ifindex);
 
 	return hash_val;
 }
diff -Nru a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
--- a/net/ipv6/ndisc.c	2004-09-23 22:26:08 -07:00
+++ b/net/ipv6/ndisc.c	2004-09-23 22:26:08 -07:00
@@ -276,7 +276,7 @@
 	hash_val ^= (hash_val>>16);
 	hash_val ^= hash_val>>8;
 	hash_val ^= hash_val>>3;
-	hash_val = (hash_val^dev->ifindex)&NEIGH_HASHMASK;
+	hash_val = (hash_val^dev->ifindex);
 
 	return hash_val;
 }
