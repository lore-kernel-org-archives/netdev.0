From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: RFC: memory leak in udp_table_init
Date: Sat, 25 Feb 2012 06:19:42 +0100
Message-ID: <1330147182.2462.25.camel@edumazet-laptop>
References: <4F48318E.8070902@am.sony.com>
	 <CAP=VYLp7+Apubm=PHRLSw50V9zBKmV-xFRvcO4-qAogJVp7jcw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Tim Bird <tim.bird@am.sony.com>,
	David Miller <davem@davemloft.net>, kuznet@ms2.inr.ac.ru,
	linux kernel <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAP=VYLp7+Apubm=PHRLSw50V9zBKmV-xFRvcO4-qAogJVp7jcw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le vendredi 24 f=C3=A9vrier 2012 =C3=A0 20:27 -0500, Paul Gortmaker a =C3=
=A9crit :
> On Fri, Feb 24, 2012 at 7:55 PM, Tim Bird <tim.bird@am.sony.com> wrot=
e:
> > We've uncovered an obscure memory leak in the routine udp_table_ini=
t(),
> > in the file: net/ipv4/udp.c
>=20
> At a glance, I think what you are seeing is the same as this?
>=20
> http://lists.openwall.net/netdev/2011/06/22/12
>=20

Yes, this issue is somewhat recurrent...

> > Any suggestions for a way to correct for a too-small first allocati=
on, without
> > a memory leak?
> >
> > Alternatively - how critical is this UDP_HTABLE_SIZE_MIN for correc=
t operation
> > of the stack?

Absolutely mandatory, if you read net/ipv4/udp.c


Lets add a new parameter to alloc_large_system_hash() to specify minimu=
m
number of slots in hash table.


David, this patch is based on Linus tree, not on net tree.
(Doesnt apply properly on net tree currently)

Thanks

[PATCH] mm: add a low limit to alloc_large_system_hash

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
allocation, and 16 for pid_hash.

Reported-by: Mark Asselstine <mark.asselstine@windriver.com>
Reported-by: Tim Bird <tim.bird@am.sony.com>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Paul Gortmaker <paul.gortmaker@windriver.com>
---
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
=20
 	for (loop =3D 0; loop < (1U << d_hash_shift); loop++)
@@ -3014,6 +3015,7 @@ static void __init dcache_init(void)
 					0,
 					&d_hash_shift,
 					&d_hash_mask,
+					0,
 					0);
=20
 	for (loop =3D 0; loop < (1U << d_hash_shift); loop++)
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
=20
 	for (loop =3D 0; loop < (1U << i_hash_shift); loop++)
@@ -1697,6 +1698,7 @@ void __init inode_init(void)
 					0,
 					&i_hash_shift,
 					&i_hash_mask,
+					0,
 					0);
=20
 	for (loop =3D 0; loop < (1U << i_hash_shift); loop++)
diff --git a/include/linux/bootmem.h b/include/linux/bootmem.h
index 66d3e95..1a0cd27 100644
--- a/include/linux/bootmem.h
+++ b/include/linux/bootmem.h
@@ -154,7 +154,8 @@ extern void *alloc_large_system_hash(const char *ta=
blename,
 				     int flags,
 				     unsigned int *_hash_shift,
 				     unsigned int *_hash_mask,
-				     unsigned long limit);
+				     unsigned long low_limit,
+				     unsigned long high_limit);
=20
 #define HASH_EARLY	0x00000001	/* Allocating during early boot? */
 #define HASH_SMALL	0x00000002	/* sub-page allocation allowed, min
diff --git a/kernel/pid.c b/kernel/pid.c
index 9f08dfa..79884b2 100644
--- a/kernel/pid.c
+++ b/kernel/pid.c
@@ -547,7 +547,8 @@ void __init pidhash_init(void)
=20
 	pid_hash =3D alloc_large_system_hash("PID", sizeof(*pid_hash), 0, 18,
 					   HASH_EARLY | HASH_SMALL,
-					   &pidhash_shift, NULL, 4096);
+					   &pidhash_shift, NULL,
+					   16, 4096);
 	pidhash_size =3D 1U << pidhash_shift;
=20
 	for (i =3D 0; i < pidhash_size; i++)
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index a13ded1..f037398 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5198,9 +5198,10 @@ void *__init alloc_large_system_hash(const char =
*tablename,
 				     int flags,
 				     unsigned int *_hash_shift,
 				     unsigned int *_hash_mask,
-				     unsigned long limit)
+				     unsigned long low_limit,
+				     unsigned long high_limit)
 {
-	unsigned long long max =3D limit;
+	unsigned long long max =3D high_limit;
 	unsigned long log2qty, size;
 	void *table =3D NULL;
=20
@@ -5238,6 +5239,8 @@ void *__init alloc_large_system_hash(const char *=
tablename,
 	}
 	max =3D min(max, 0x80000000ULL);
=20
+	if (numentries < low_limit)
+		numentries =3D low_limit;
 	if (numentries > max)
 		numentries =3D max;
=20
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
 	memset(rt_hash_table, 0, (rt_hash_mask + 1) * sizeof(struct rt_hash_b=
ucket));
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
 	for (i =3D 0; i <=3D tcp_hashinfo.ehash_mask; i++) {
 		INIT_HLIST_NULLS_HEAD(&tcp_hashinfo.ehash[i].chain, i);
@@ -3283,6 +3284,7 @@ void __init tcp_init(void)
 					0,
 					&tcp_hashinfo.bhash_size,
 					NULL,
+					0,
 					64 * 1024);
 	tcp_hashinfo.bhash_size =3D 1U << tcp_hashinfo.bhash_size;
 	for (i =3D 0; i < tcp_hashinfo.bhash_size; i++) {
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 5d075b5..dc68ed2 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -2182,26 +2182,16 @@ void __init udp_table_init(struct udp_table *ta=
ble, const char *name)
 {
 	unsigned int i;
=20
-	if (!CONFIG_BASE_SMALL)
-		table->hash =3D alloc_large_system_hash(name,
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
-		table->hash =3D kmalloc(UDP_HTABLE_SIZE_MIN *
-				      2 * sizeof(struct udp_hslot), GFP_KERNEL);
-		if (!table->hash)
-			panic(name);
-		table->log =3D ilog2(UDP_HTABLE_SIZE_MIN);
-		table->mask =3D UDP_HTABLE_SIZE_MIN - 1;
-	}
+	table->hash =3D alloc_large_system_hash(name,
+					      2 * sizeof(struct udp_hslot),
+					      uhash_entries,
+					      21, /* one slot per 2 MB */
+					      0,
+					      &table->log,
+					      &table->mask,
+					      UDP_HTABLE_SIZE_MIN,
+					      64 * 1024);
+
 	table->hash2 =3D table->hash + (table->mask + 1);
 	for (i =3D 0; i <=3D table->mask; i++) {
 		INIT_HLIST_NULLS_HEAD(&table->hash[i].head, i);
