From: "David S. Miller" <davem@davemloft.net>
Subject: [6/6]: jenkins hash for neigh
Date: Thu, 23 Sep 2004 22:51:58 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040923225158.23c2d502.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: laforge@gnumonks.org
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


This makes all the neigh implementations use jenkins.

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/09/23 18:03:13-07:00 davem@nuts.davemloft.net 
#   [NET]: Convert neigh hashing over to jenkins.
#   
#   Based upon work by Harald Welte <laforge@netfilter.org>
#   
#   Signed-off-by: David S. Miller <davem@davemloft.net>
# 
# net/ipv6/ndisc.c
#   2004/09/23 18:02:32-07:00 davem@nuts.davemloft.net +7 -7
#   [NET]: Convert neigh hashing over to jenkins.
# 
# net/ipv4/arp.c
#   2004/09/23 18:02:32-07:00 davem@nuts.davemloft.net +3 -9
#   [NET]: Convert neigh hashing over to jenkins.
# 
# net/decnet/dn_neigh.c
#   2004/09/23 18:02:32-07:00 davem@nuts.davemloft.net +2 -7
#   [NET]: Convert neigh hashing over to jenkins.
# 
# net/core/neighbour.c
#   2004/09/23 18:02:32-07:00 davem@nuts.davemloft.net +3 -0
#   [NET]: Convert neigh hashing over to jenkins.
# 
# net/atm/clip.c
#   2004/09/23 18:02:32-07:00 davem@nuts.davemloft.net +2 -9
#   [NET]: Convert neigh hashing over to jenkins.
# 
# include/net/neighbour.h
#   2004/09/23 18:02:32-07:00 davem@nuts.davemloft.net +1 -0
#   [NET]: Convert neigh hashing over to jenkins.
# 
diff -Nru a/include/net/neighbour.h b/include/net/neighbour.h
--- a/include/net/neighbour.h	2004-09-23 22:27:14 -07:00
+++ b/include/net/neighbour.h	2004-09-23 22:27:14 -07:00
@@ -175,6 +175,7 @@
 	struct neigh_statistics	stats;
 	struct neighbour	**hash_buckets;
 	unsigned int		hash_mask;
+	__u32			hash_rnd;
 	struct pneigh_entry	**phash_buckets;
 };
 
diff -Nru a/net/atm/clip.c b/net/atm/clip.c
--- a/net/atm/clip.c	2004-09-23 22:27:14 -07:00
+++ b/net/atm/clip.c	2004-09-23 22:27:14 -07:00
@@ -27,6 +27,7 @@
 #include <linux/proc_fs.h>
 #include <linux/seq_file.h>
 #include <linux/rcupdate.h>
+#include <linux/jhash.h>
 #include <net/route.h> /* for struct rtable and routing */
 #include <net/icmp.h> /* icmp_send */
 #include <asm/param.h> /* for HZ */
@@ -328,15 +329,7 @@
 
 static u32 clip_hash(const void *pkey, const struct net_device *dev)
 {
-	u32 hash_val;
-
-	hash_val = *(u32*)pkey;
-	hash_val ^= (hash_val>>16);
-	hash_val ^= hash_val>>8;
-	hash_val ^= hash_val>>3;
-	hash_val = (hash_val^dev->ifindex);
-
-	return hash_val;
+	return jhash_2words(*(u32 *)pkey, dev->ifindex, clip_tbl.hash_rnd);
 }
 
 static struct neigh_table clip_tbl = {
diff -Nru a/net/core/neighbour.c b/net/core/neighbour.c
--- a/net/core/neighbour.c	2004-09-23 22:27:14 -07:00
+++ b/net/core/neighbour.c	2004-09-23 22:27:14 -07:00
@@ -29,6 +29,7 @@
 #include <net/dst.h>
 #include <net/sock.h>
 #include <linux/rtnetlink.h>
+#include <linux/random.h>
 
 #define NEIGH_DEBUG 1
 
@@ -1316,6 +1317,8 @@
 		panic("cannot allocate neighbour cache hashes");
 
 	memset(tbl->phash_buckets, 0, phsize);
+
+	get_random_bytes(&tbl->hash_rnd, sizeof(tbl->hash_rnd));
 
 	tbl->lock	       = RW_LOCK_UNLOCKED;
 	init_timer(&tbl->gc_timer);
diff -Nru a/net/decnet/dn_neigh.c b/net/decnet/dn_neigh.c
--- a/net/decnet/dn_neigh.c	2004-09-23 22:27:14 -07:00
+++ b/net/decnet/dn_neigh.c	2004-09-23 22:27:14 -07:00
@@ -36,6 +36,7 @@
 #include <linux/spinlock.h>
 #include <linux/seq_file.h>
 #include <linux/rcupdate.h>
+#include <linux/jhash.h>
 #include <asm/atomic.h>
 #include <net/neighbour.h>
 #include <net/dst.h>
@@ -122,13 +123,7 @@
 
 static u32 dn_neigh_hash(const void *pkey, const struct net_device *dev)
 {
-	u32 hash_val;
-
-	hash_val = *(dn_address *)pkey;
-	hash_val ^= (hash_val >> 10);
-	hash_val ^= (hash_val >> 3);
-
-	return hash_val;
+	return jhash_2words(*(dn_address *)pkey, 0, dn_neigh_table.hash_rnd);
 }
 
 static int dn_neigh_construct(struct neighbour *neigh)
diff -Nru a/net/ipv4/arp.c b/net/ipv4/arp.c
--- a/net/ipv4/arp.c	2004-09-23 22:27:14 -07:00
+++ b/net/ipv4/arp.c	2004-09-23 22:27:14 -07:00
@@ -71,6 +71,7 @@
  *					arp_xmit so intermediate drivers like
  *					bonding can change the skb before
  *					sending (e.g. insert 8021q tag).
+ *		Harald Welte	:	convert to make use of jenkins hash
  */
 
 #include <linux/module.h>
@@ -97,6 +98,7 @@
 #include <linux/init.h>
 #include <linux/net.h>
 #include <linux/rcupdate.h>
+#include <linux/jhash.h>
 #ifdef CONFIG_SYSCTL
 #include <linux/sysctl.h>
 #endif
@@ -223,15 +225,7 @@
 
 static u32 arp_hash(const void *pkey, const struct net_device *dev)
 {
-	u32 hash_val;
-
-	hash_val = *(u32*)pkey;
-	hash_val ^= (hash_val>>16);
-	hash_val ^= hash_val>>8;
-	hash_val ^= hash_val>>3;
-	hash_val = (hash_val^dev->ifindex);
-
-	return hash_val;
+	return jhash_2words(*(u32 *)pkey, dev->ifindex, arp_tbl.hash_rnd);
 }
 
 static int arp_constructor(struct neighbour *neigh)
diff -Nru a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
--- a/net/ipv6/ndisc.c	2004-09-23 22:27:14 -07:00
+++ b/net/ipv6/ndisc.c	2004-09-23 22:27:14 -07:00
@@ -66,6 +66,7 @@
 #include <linux/if_arp.h>
 #include <linux/ipv6.h>
 #include <linux/icmpv6.h>
+#include <linux/jhash.h>
 
 #include <net/sock.h>
 #include <net/snmp.h>
@@ -270,15 +271,14 @@
 
 static u32 ndisc_hash(const void *pkey, const struct net_device *dev)
 {
-	u32 hash_val;
+	const u32 *p32 = pkey;
+	u32 addr_hash, i;
 
-	hash_val = *(u32*)(pkey + sizeof(struct in6_addr) - 4);
-	hash_val ^= (hash_val>>16);
-	hash_val ^= hash_val>>8;
-	hash_val ^= hash_val>>3;
-	hash_val = (hash_val^dev->ifindex);
+	addr_hash = 0;
+	for (i = 0; i < (sizeof(struct in6_addr) / sizeof(u32)); i++)
+		addr_hash ^= *p32++;
 
-	return hash_val;
+	return jhash_2words(addr_hash, dev->ifindex, nd_tbl.hash_rnd);
 }
 
 static int ndisc_constructor(struct neighbour *neigh)
