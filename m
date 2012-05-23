From: Tim Bird <tim.bird@am.sony.com>
Subject: Re: [PATCH v2] mm: add a low limit to alloc_large_system_hash
Date: Wed, 23 May 2012 16:33:35 -0700
Message-ID: <4FBD73CF.2000306@am.sony.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
To: <eric.dumazet@gmail.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	David Miller <davem@davemloft.net>,
	linux kernel <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch seems to have fallen in the cracks:

https://lkml.org/lkml/2012/2/27/20

The last message on the thread was an ACK by David Miller, and
the question "Who wants to take this?"
  -- Tim

[message and patch follow]

UDP stack needs a minimum hash size value for proper operation and also
uses alloc_large_system_hash() for proper NUMA distribution of its hash
tables and automatic sizing depending on available system memory.

On some low memory situations, udp_table_init() must ignore the
alloc_large_system_hash() result and reallocs a bigger memory area.

As we cannot easily free old hash table, we leak it and kmemleak can
issue a warning.

This patch adds a low limit parameter to alloc_large_system_hash() to
solve this problem.

We then specify UDP_HTABLE_SIZE_MIN for UDP/UDPLite hash table
allocation.

Reported-by: Mark Asselstine <mark.asselstine@windriver.com>
Reported-by: Tim Bird <tim.bird@am.sony.com>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Paul Gortmaker <paul.gortmaker@windriver.com>
---
V2: no 16 minimum value for pid hash
 fs/dcache.c             |    2 ++
 fs/inode.c              |    2 ++
 include/linux/bootmem.h |    3 ++-
 kernel/pid.c            |    3 ++-
 mm/page_alloc.c         |    7 +++++--
 net/ipv4/route.c        |    1 +
 net/ipv4/tcp.c          |    2 ++
 net/ipv4/udp.c          |   30 ++++++++++--------------------
 8 files changed, 26 insertions(+), 24 deletions(-)
diff --git a/fs/dcache.c b/fs/dcache.c
index fe19ac1..ef5e72e 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -2984,6 +2984,7 @@ static void __init dcache_init_early(void)
 					HASH_EARLY,
 					&d_hash_shift,
 					&d_hash_mask,
+					0,
 					0);

 	for (loop = 0; loop < (1U << d_hash_shift); loop++)
@@ -3014,6 +3015,7 @@ static void __init dcache_init(void)
 					0,
 					&d_hash_shift,
 					&d_hash_mask,
+					0,
 					0);

 	for (loop = 0; loop < (1U << d_hash_shift); loop++)
diff --git a/fs/inode.c b/fs/inode.c
index d3ebdbe..7acee4c 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -1667,6 +1667,7 @@ void __init inode_init_early(void)
 					HASH_EARLY,
 					&i_hash_shift,
 					&i_hash_mask,
+					0,
 					0);

 	for (loop = 0; loop < (1U << i_hash_shift); loop++)
@@ -1697,6 +1698,7 @@ void __init inode_init(void)
 					0,
 					&i_hash_shift,
 					&i_hash_mask,
+					0,
 					0);

 	for (loop = 0; loop < (1U << i_hash_shift); loop++)
diff --git a/include/linux/bootmem.h b/include/linux/bootmem.h
index 66d3e95..1a0cd27 100644
--- a/include/linux/bootmem.h
+++ b/include/linux/bootmem.h
@@ -154,7 +154,8 @@ extern void *alloc_large_system_hash(const char *tablename,
 				     int flags,
 				     unsigned int *_hash_shift,
 				     unsigned int *_hash_mask,
-				     unsigned long limit);
+				     unsigned long low_limit,
+				     unsigned long high_limit);

 #define HASH_EARLY	0x00000001	/* Allocating during early boot? */
 #define HASH_SMALL	0x00000002	/* sub-page allocation allowed, min
diff --git a/kernel/pid.c b/kernel/pid.c
index 9f08dfa..e86b291 100644
--- a/kernel/pid.c
+++ b/kernel/pid.c
@@ -547,7 +547,8 @@ void __init pidhash_init(void)

 	pid_hash = alloc_large_system_hash("PID", sizeof(*pid_hash), 0, 18,
 					   HASH_EARLY | HASH_SMALL,
-					   &pidhash_shift, NULL, 4096);
+					   &pidhash_shift, NULL,
+					   0, 4096);
 	pidhash_size = 1U << pidhash_shift;

 	for (i = 0; i < pidhash_size; i++)
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index a13ded1..b9afccb 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5198,9 +5198,10 @@ void *__init alloc_large_system_hash(const char *tablename,
 				     int flags,
 				     unsigned int *_hash_shift,
 				     unsigned int *_hash_mask,
-				     unsigned long limit)
+				     unsigned long low_limit,
+				     unsigned long high_limit)
 {
-	unsigned long long max = limit;
+	unsigned long long max = high_limit;
 	unsigned long log2qty, size;
 	void *table = NULL;

@@ -5238,6 +5239,8 @@ void *__init alloc_large_system_hash(const char *tablename,
 	}
 	max = min(max, 0x80000000ULL);

+	if (numentries < low_limit)
+		numentries = low_limit;
 	if (numentries > max)
 		numentries = max;

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index bcacf54..0a41e38 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -3475,6 +3475,7 @@ int __init ip_rt_init(void)
 					0,
 					&rt_hash_log,
 					&rt_hash_mask,
+					0,
 					rhash_entries ? 0 : 512 * 1024);
 	memset(rt_hash_table, 0, (rt_hash_mask + 1) * sizeof(struct rt_hash_bucket));
 	rt_hash_lock_init();
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 22ef5f9..e61a498 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -3267,6 +3267,7 @@ void __init tcp_init(void)
 					0,
 					NULL,
 					&tcp_hashinfo.ehash_mask,
+					0,
 					thash_entries ? 0 : 512 * 1024);
 	for (i = 0; i <= tcp_hashinfo.ehash_mask; i++) {
 		INIT_HLIST_NULLS_HEAD(&tcp_hashinfo.ehash[i].chain, i);
@@ -3283,6 +3284,7 @@ void __init tcp_init(void)
 					0,
 					&tcp_hashinfo.bhash_size,
 					NULL,
+					0,
 					64 * 1024);
 	tcp_hashinfo.bhash_size = 1U << tcp_hashinfo.bhash_size;
 	for (i = 0; i < tcp_hashinfo.bhash_size; i++) {
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 5d075b5..dc68ed2 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -2182,26 +2182,16 @@ void __init udp_table_init(struct udp_table *table, const char *name)
 {
 	unsigned int i;

-	if (!CONFIG_BASE_SMALL)
-		table->hash = alloc_large_system_hash(name,
-			2 * sizeof(struct udp_hslot),
-			uhash_entries,
-			21, /* one slot per 2 MB */
-			0,
-			&table->log,
-			&table->mask,
-			64 * 1024);
-	/*
-	 * Make sure hash table has the minimum size
-	 */
-	if (CONFIG_BASE_SMALL || table->mask < UDP_HTABLE_SIZE_MIN - 1) {
-		table->hash = kmalloc(UDP_HTABLE_SIZE_MIN *
-				      2 * sizeof(struct udp_hslot), GFP_KERNEL);
-		if (!table->hash)
-			panic(name);
-		table->log = ilog2(UDP_HTABLE_SIZE_MIN);
-		table->mask = UDP_HTABLE_SIZE_MIN - 1;
-	}
+	table->hash = alloc_large_system_hash(name,
+					      2 * sizeof(struct udp_hslot),
+					      uhash_entries,
+					      21, /* one slot per 2 MB */
+					      0,
+					      &table->log,
+					      &table->mask,
+					      UDP_HTABLE_SIZE_MIN,
+					      64 * 1024);
+
 	table->hash2 = table->hash + (table->mask + 1);
 	for (i = 0; i <= table->mask; i++) {
 		INIT_HLIST_NULLS_HEAD(&table->hash[i].head, i);
