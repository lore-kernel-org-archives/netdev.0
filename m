From: Harald Welte <laforge@gnumonks.org>
Subject: [PATCH + RFC] neighbour/ARP cache scalability
Date: Tue, 21 Sep 2004 00:51:40 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040920225140.GH1307@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="hEi834+foqWOL7fK"
Return-path: <netdev-bounce@oss.sgi.com>
To: Linux Netdev List <netdev@oss.sgi.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--hEi834+foqWOL7fK
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi!

I've recently had some problems with the neighbour cache on systems
which have large layer-2 networks (such as 10/12 ethernet interfaces,
most of them attached to networks with a /16 netmaks).  Yes, I know,
networks of that size is a bad design anyway.  But at the same time
there are people using such strange setups ...

The current garbage collection mechanism's ultimate goal is to prevent
ARP floods.  It therefore never expires INCOMPLETE entries from the
neighbour cache.  I've seen systems in a state which is what I believe
beign completely starved of neighbour cache entries, while gc is unable
to evict anything =3D> increasing gc_thesh2/gc_thresh3 to large values.

As a result, on systems with large networks (think of even less than 16
bit netmasks!) the neighbour table can grow quite significantly,
especially if some jerk runs pktgen with random destinations, and we
start expiring 'real' neighbours in favour of incomplete ones. =20

This large number of ncache entries is distributed over only 32 buckets,
which is quite unsatisfactory.  Especially if we consider that the
distribution within the hash has been reported to be quite sub-optimal[1]

Tim Gardner has already sent two patches for 2.4.x on this some time
ago [1], [2] adressing this issue - but none of them was integrated.

I've now ported [2] to 2.6.9-rc2-bk6, and dropped [1]. Furthermore, I've
added:
	- neigh_hash_bits boot parameter (if not specified, auto-sizing
	  hash based on system ram)
	- jenkins hash for ARP hash function, like Dave indicated [3]
	- make number of buckets readable via /proc/

The patch is not yet intende for mainline inclusion, since I want to
have feedback on

1) should I try to use jhash for ipv6, too?

2) Dave has indicated that there should be an upper limit for hash
   buckets.  What is considered a reasonable upper bound, even for very
   large systems?

3) What do you think about removing gc_interval in favour of the dynamic
   interval calculation, combined with the 'one bucket per gc run'
   approach that Tim selected?

4) Shouldn't we set gc_thresh3 automatically based on the netmassk of
   the interfaces we have IFF_RUNNING? =20

5) What is the proposed solution for IPv6, when you have /48 or /64 bit
   prefixes and systems become even more vulnerable to neighbour cache
   attacks? =20

6) Since everybody agrees the current scheme of bucket-sizing based on
   memory only is a bad idea, do we want to unify this bucket sizing
   code, so people have one single knob (boot option) which they can use
   to give the system some metrics on how large it should scale all the
   network hash tables?

[1] http://oss.sgi.com/projects/netdev/archive/2004-03/msg00265.html
[2] http://oss.sgi.com/projects/netdev/archive/2004-03/msg00250.html
[3] http://oss.sgi.com/projects/netdev/archive/2004-03/msg00279.html


diff -Nru --exclude-from=3D/sunbeam/home/laforge/scripts/dontdiff linux-2.6=
=2E9-rc2-bk6/net/atm/clip.c linux-2.6.9-rc2-bk6-ncache/net/atm/clip.c
--- linux-2.6.9-rc2-bk6/net/atm/clip.c	2004-09-21 00:23:16.000000000 +0200
+++ linux-2.6.9-rc2-bk6-ncache/net/atm/clip.c	2004-09-20 20:25:48.000000000=
 +0200
@@ -130,7 +130,7 @@
=20
 	/*DPRINTK("idle_timer_check\n");*/
 	write_lock(&clip_tbl.lock);
-	for (i =3D 0; i <=3D NEIGH_HASHMASK; i++) {
+	for (i =3D 0; i < clip_tbl.num_hash_buckets; i++) {
 		struct neighbour **np;
=20
 		for (np =3D &clip_tbl.hash_buckets[i]; *np;) {
@@ -341,6 +341,7 @@
 	return 0;
 }
=20
+static struct neigh_table clip_tbl;
 static u32 clip_hash(const void *pkey, const struct net_device *dev)
 {
 	u32 hash_val;
@@ -349,7 +350,7 @@
 	hash_val ^=3D (hash_val>>16);
 	hash_val ^=3D hash_val>>8;
 	hash_val ^=3D hash_val>>3;
-	hash_val =3D (hash_val^dev->ifindex)&NEIGH_HASHMASK;
+	hash_val =3D (hash_val^dev->ifindex)&(clip_tbl.num_hash_buckets-1);
=20
 	return hash_val;
 }
@@ -894,7 +895,7 @@
 {
 	void *v =3D NULL;
=20
-	for (; state->bucket <=3D NEIGH_HASHMASK; state->bucket++) {
+	for (; state->bucket < clip_tbl.num_hash_buckets; state->bucket++) {
 		for (; state->n; state->n =3D state->n->next) {
 			v =3D arp_vcc_walk(state, NEIGH2ENTRY(state->n), &l);
 			if (v)
diff -Nru --exclude-from=3D/sunbeam/home/laforge/scripts/dontdiff linux-2.6=
=2E9-rc2-bk6/net/core/neighbour.c linux-2.6.9-rc2-bk6-ncache/net/core/neigh=
bour.c
--- linux-2.6.9-rc2-bk6/net/core/neighbour.c	2004-09-21 00:23:16.000000000 =
+0200
+++ linux-2.6.9-rc2-bk6-ncache/net/core/neighbour.c	2004-09-20 22:13:56.000=
000000 +0200
@@ -12,6 +12,10 @@
  *
  *	Fixes:
  *	Vitaly E. Lavrov	releasing NULL neighbor in neigh_add.
+ *
+ *	Changes:
+ *	2004-09-17: Make cache size dynamically sized + configurable=20
+ *	  (Tim Gardner <timg@tpi.com> & Harald Welte <laforge@netfilter.org>)
  */
=20
 #include <linux/config.h>
@@ -47,6 +51,9 @@
 #define NEIGH_PRINTK2 NEIGH_PRINTK
 #endif
=20
+static unsigned int neigh_hash_bits;
+module_param(neigh_hash_bits, int, 0400);
+
 static void neigh_timer_handler(unsigned long arg);
 #ifdef CONFIG_ARPD
 static void neigh_app_notify(struct neighbour *n);
@@ -113,7 +120,7 @@
 	int shrunk =3D 0;
 	int i;
=20
-	for (i =3D 0; i <=3D NEIGH_HASHMASK; i++) {
+	for (i =3D 0; i < tbl->num_hash_buckets; i++) {
 		struct neighbour *n, **np;
=20
 		np =3D &tbl->hash_buckets[i];
@@ -177,7 +184,7 @@
=20
 	write_lock_bh(&tbl->lock);
=20
-	for (i=3D0; i <=3D NEIGH_HASHMASK; i++) {
+	for (i=3D0; i < tbl->num_hash_buckets; i++) {
 		struct neighbour *n, **np;
=20
 		np =3D &tbl->hash_buckets[i];
@@ -204,7 +211,7 @@
=20
 	write_lock_bh(&tbl->lock);
=20
-	for (i =3D 0; i <=3D NEIGH_HASHMASK; i++) {
+	for (i =3D 0; i < tbl->num_hash_buckets; i++) {
 		struct neighbour *n, **np =3D &tbl->hash_buckets[i];
=20
 		while ((n =3D *np) !=3D NULL) {
@@ -545,9 +552,8 @@
 static void neigh_periodic_timer(unsigned long arg)
 {
 	struct neigh_table *tbl =3D (struct neigh_table *)arg;
+	struct neighbour *n, **np;
 	unsigned long now =3D jiffies;
-	int i;
-
=20
 	write_lock(&tbl->lock);
=20
@@ -563,41 +569,44 @@
 				neigh_rand_reach_time(p->base_reachable_time);
 	}
=20
-	for (i =3D 0; i <=3D NEIGH_HASHMASK; i++) {
-		struct neighbour *n, **np;
+	tbl->curr_hash_bucket &=3D (tbl->num_hash_buckets-1);
+	np =3D &tbl->hash_buckets[tbl->curr_hash_bucket++];
=20
-		np =3D &tbl->hash_buckets[i];
-		while ((n =3D *np) !=3D NULL) {
-			unsigned state;
+	while ((n =3D *np) !=3D NULL) {
+		unsigned state;
=20
-			write_lock(&n->lock);
+		write_lock(&n->lock);
=20
-			state =3D n->nud_state;
-			if (state & (NUD_PERMANENT | NUD_IN_TIMER)) {
-				write_unlock(&n->lock);
-				goto next_elt;
-			}
+		state =3D n->nud_state;
+		if (state & (NUD_PERMANENT | NUD_IN_TIMER)) {
+			write_unlock(&n->lock);
+			goto next_elt;
+		}
=20
-			if (time_before(n->used, n->confirmed))
-				n->used =3D n->confirmed;
+		if (time_before(n->used, n->confirmed))
+			n->used =3D n->confirmed;
=20
-			if (atomic_read(&n->refcnt) =3D=3D 1 &&
-			    (state =3D=3D NUD_FAILED ||
-			     time_after(now, n->used + n->parms->gc_staletime))) {
-				*np =3D n->next;
-				n->dead =3D 1;
-				write_unlock(&n->lock);
-				neigh_release(n);
-				continue;
-			}
+		if (atomic_read(&n->refcnt) =3D=3D 1 &&
+		    (state =3D=3D NUD_FAILED ||
+		     time_after(now, n->used + n->parms->gc_staletime))) {
+			*np =3D n->next;
+			n->dead =3D 1;
 			write_unlock(&n->lock);
+			neigh_release(n);
+			continue;
+		}
+		write_unlock(&n->lock);
=20
 next_elt:
-			np =3D &n->next;
-		}
+		np =3D &n->next;
 	}
-
-	mod_timer(&tbl->gc_timer, now + tbl->gc_interval);
+ 	/* Cycle through all hash buckets every base_reachable_time/2 ticks.
+ 	 * ARP entry timeouts range from 1/2 base_reachable_time to 3/2
+ 	 * base_reachable_time. */
+=20
+ 	mod_timer(&tbl->gc_timer, now +=20
+		 ((tbl->parms.base_reachable_time>>1)/(tbl->num_hash_buckets)));
+=20
 	write_unlock(&tbl->lock);
 }
=20
@@ -1205,6 +1214,37 @@
 void neigh_table_init(struct neigh_table *tbl)
 {
 	unsigned long now =3D jiffies;
+	unsigned int goal =3D neigh_hash_bits;
+
+	/* Allocate a power of 2 hash buckets for each power of 2 MB of RAM. */
+	if (!goal) {
+		unsigned int ram_mb =3D (num_physpages*PAGE_SIZE) / (1024*1024);
+		goal =3D 31;
+		while ((1<<goal) > ram_mb)
+		{
+			goal--;
+		}
+	}
+
+	tbl->hash_buckets =3D NULL;
+	while (goal && (!tbl->hash_buckets)) {
+		tbl->num_hash_buckets =3D (1<<goal);
+		tbl->hash_buckets =3D kmalloc(sizeof(struct neighbour *)
+					    *tbl->num_hash_buckets, GFP_ATOMIC);
+		goal--;
+	}
+
+	if (tbl->hash_buckets =3D=3D NULL)
+		panic("%s: Could not allocate memory for hash buckets "
+		      "of table %s.\n", tbl->id, __FUNCTION__);
+	memset(tbl->hash_buckets, 0,
+	       sizeof(struct neighbour *)*tbl->num_hash_buckets);
+
+	if (neigh_hash_bits &&=20
+	    (tbl->num_hash_buckets !=3D ((1<<neigh_hash_bits)+1)))
+		printk(KERN_WARNING "%s: Couldn't allocate %u hash buckets, "
+		       "did %u instead.\n", __FUNCTION__,
+			(1<<neigh_hash_bits)+1, tbl->num_hash_buckets);
=20
 	atomic_set(&tbl->parms.refcnt, 1);
 	INIT_RCU_HEAD(&tbl->parms.rcu_head);
@@ -1224,8 +1264,7 @@
 	init_timer(&tbl->gc_timer);
 	tbl->gc_timer.data     =3D (unsigned long)tbl;
 	tbl->gc_timer.function =3D neigh_periodic_timer;
-	tbl->gc_timer.expires  =3D now + tbl->gc_interval +
-				 tbl->parms.reachable_time;
+	tbl->gc_timer.expires  =3D now + 1;
 	add_timer(&tbl->gc_timer);
=20
 	init_timer(&tbl->proxy_timer);
@@ -1439,7 +1478,7 @@
 	int rc, h, s_h =3D cb->args[1];
 	int idx, s_idx =3D idx =3D cb->args[2];
=20
-	for (h =3D 0; h <=3D NEIGH_HASHMASK; h++) {
+	for (h =3D 0; h < tbl->num_hash_buckets; h++) {
 		if (h < s_h)
 			continue;
 		if (h > s_h)
@@ -1628,14 +1667,6 @@
 			.proc_handler	=3D &proc_dointvec_userhz_jiffies,
 		},
 		{
-			.ctl_name	=3D NET_NEIGH_GC_INTERVAL,
-			.procname	=3D "gc_interval",
-			.maxlen		=3D sizeof(int),
-			.mode		=3D 0644,
-			.proc_handler	=3D &proc_dointvec_jiffies,
-			.strategy	=3D &sysctl_jiffies,
-		},
-		{
 			.ctl_name	=3D NET_NEIGH_GC_THRESH1,
 			.procname	=3D "gc_thresh1",
 			.maxlen		=3D sizeof(int),
@@ -1656,6 +1687,13 @@
 			.mode		=3D 0644,
 			.proc_handler	=3D &proc_dointvec,
 		},
+		{
+			.ctl_name	=3D NET_NEIGH_NUM_HASH_BUCKETS,
+			.procname	=3D "hash_buckets",
+			.maxlen		=3D sizeof(int),
+			.mode		=3D 0400,
+			.proc_handler	=3D &proc_dointvec,
+		},
 	},
 	.neigh_dev =3D {
 		{
@@ -1719,10 +1757,13 @@
 		t->neigh_dev[0].ctl_name =3D dev->ifindex;
 		memset(&t->neigh_vars[12], 0, sizeof(ctl_table));
 	} else {
+		/* If you listen carefully, you can actually hear this
+		 * code suck */
 		t->neigh_vars[12].data =3D (int *)(p + 1);
 		t->neigh_vars[13].data =3D (int *)(p + 1) + 1;
 		t->neigh_vars[14].data =3D (int *)(p + 1) + 2;
 		t->neigh_vars[15].data =3D (int *)(p + 1) + 3;
+		t->neigh_vars[16].data =3D (int *)(p + 1) + 4;
 	}
=20
 	dev_name =3D net_sysctl_strdup(dev_name_source);
diff -Nru --exclude-from=3D/sunbeam/home/laforge/scripts/dontdiff linux-2.6=
=2E9-rc2-bk6/net/decnet/dn_neigh.c linux-2.6.9-rc2-bk6-ncache/net/decnet/dn=
_neigh.c
--- linux-2.6.9-rc2-bk6/net/decnet/dn_neigh.c	2004-09-13 07:32:55.000000000=
 +0200
+++ linux-2.6.9-rc2-bk6-ncache/net/decnet/dn_neigh.c	2004-09-20 20:25:48.00=
0000000 +0200
@@ -128,7 +128,7 @@
 	hash_val ^=3D (hash_val >> 10);
 	hash_val ^=3D (hash_val >> 3);
=20
-	return hash_val & NEIGH_HASHMASK;
+	return hash_val & (dn_neigh_table.num_hash_buckets-1);
 }
=20
 static int dn_neigh_construct(struct neighbour *neigh)
@@ -526,7 +526,7 @@
=20
 	read_lock_bh(&tbl->lock);
=20
-	for(i =3D 0; i < NEIGH_HASHMASK; i++) {
+	for(i =3D 0; i < tbl->num_hash_buckets; i++) {
 		for(neigh =3D tbl->hash_buckets[i]; neigh !=3D NULL; neigh =3D neigh->ne=
xt) {
 			if (neigh->dev !=3D dev)
 				continue;
@@ -567,7 +567,7 @@
 	struct neighbour *n =3D NULL;
=20
 	for(state->bucket =3D 0;
-	    state->bucket <=3D NEIGH_HASHMASK;
+	    state->bucket < dn_neigh_table.num_hash_buckets;
 	    ++state->bucket) {
 		n =3D dn_neigh_table.hash_buckets[state->bucket];
 		if (n)
@@ -586,7 +586,7 @@
 try_again:
 	if (n)
 		goto out;
-	if (++state->bucket > NEIGH_HASHMASK)
+	if (++state->bucket >=3D dn_neigh_table.num_hash_buckets)
 		goto out;
 	n =3D dn_neigh_table.hash_buckets[state->bucket];
 	goto try_again;
diff -Nru --exclude-from=3D/sunbeam/home/laforge/scripts/dontdiff linux-2.6=
=2E9-rc2-bk6/net/ipv4/arp.c linux-2.6.9-rc2-bk6-ncache/net/ipv4/arp.c
--- linux-2.6.9-rc2-bk6/net/ipv4/arp.c	2004-09-21 00:23:16.000000000 +0200
+++ linux-2.6.9-rc2-bk6-ncache/net/ipv4/arp.c	2004-09-20 20:31:21.000000000=
 +0200
@@ -71,6 +71,7 @@
  *					arp_xmit so intermediate drivers like
  *					bonding can change the skb before
  *					sending (e.g. insert 8021q tag).
+ *		Harald Welte    :	convert to make use of jenkins hash
  */
=20
 #include <linux/module.h>
@@ -97,6 +98,7 @@
 #include <linux/init.h>
 #include <linux/net.h>
 #include <linux/rcupdate.h>
+#include <linux/jhash.h>
 #ifdef CONFIG_SYSCTL
 #include <linux/sysctl.h>
 #endif
@@ -124,6 +126,9 @@
=20
 #include <linux/netfilter_arp.h>
=20
+static u32 arp_hash_rnd;
+static int arp_hash_rnd_initted;
+
 /*
  *	Interface to generic neighbour cache.
  */
@@ -194,7 +199,6 @@
 		.proxy_qlen =3D		64,
 		.locktime =3D		1 * HZ,
 	},
-	.gc_interval =3D	30 * HZ,
 	.gc_thresh1 =3D	128,
 	.gc_thresh2 =3D	512,
 	.gc_thresh3 =3D	1024,
@@ -223,15 +227,13 @@
=20
 static u32 arp_hash(const void *pkey, const struct net_device *dev)
 {
-	u32 hash_val;
-
-	hash_val =3D *(u32*)pkey;
-	hash_val ^=3D (hash_val>>16);
-	hash_val ^=3D hash_val>>8;
-	hash_val ^=3D hash_val>>3;
-	hash_val =3D (hash_val^dev->ifindex)&NEIGH_HASHMASK;
+	if (unlikely(!arp_hash_rnd_initted)) {
+		get_random_bytes(&arp_hash_rnd, 4);
+		arp_hash_rnd_initted =3D 1;
+	}
=20
-	return hash_val;
+	return (jhash_2words(*(u32 *)pkey, dev->ifindex,
+			     arp_hash_rnd) & arp_tbl.num_hash_buckets-1);
 }
=20
 static int arp_constructor(struct neighbour *neigh)
@@ -1281,7 +1283,7 @@
 	state->is_pneigh =3D 0;
=20
 	for (state->bucket =3D 0;
-	     state->bucket <=3D NEIGH_HASHMASK;
+	     state->bucket < arp_tbl.num_hash_buckets;
 	     ++state->bucket) {
 		n =3D arp_tbl.hash_buckets[state->bucket];
 		while (n && !(n->nud_state & ~NUD_NOARP))
@@ -1307,7 +1309,7 @@
=20
 	if (n)
 		goto out;
-	if (++state->bucket > NEIGH_HASHMASK)
+	if (++state->bucket >=3D arp_tbl.num_hash_buckets)
 		goto out;
 	n =3D arp_tbl.hash_buckets[state->bucket];
 	goto try_again;
diff -Nru --exclude-from=3D/sunbeam/home/laforge/scripts/dontdiff linux-2.6=
=2E9-rc2-bk6/net/ipv6/ndisc.c linux-2.6.9-rc2-bk6-ncache/net/ipv6/ndisc.c
--- linux-2.6.9-rc2-bk6/net/ipv6/ndisc.c	2004-09-21 00:23:16.000000000 +0200
+++ linux-2.6.9-rc2-bk6-ncache/net/ipv6/ndisc.c	2004-09-20 20:25:48.0000000=
00 +0200
@@ -147,7 +147,6 @@
 		.proxy_delay =3D		(8 * HZ) / 10,
 		.proxy_qlen =3D		64,
 	},
-	.gc_interval =3D	  30 * HZ,
 	.gc_thresh1 =3D	 128,
 	.gc_thresh2 =3D	 512,
 	.gc_thresh3 =3D	1024,
@@ -276,7 +275,7 @@
 	hash_val ^=3D (hash_val>>16);
 	hash_val ^=3D hash_val>>8;
 	hash_val ^=3D hash_val>>3;
-	hash_val =3D (hash_val^dev->ifindex)&NEIGH_HASHMASK;
+	hash_val =3D (hash_val^dev->ifindex)&(nd_tbl.num_hash_buckets-1);
=20
 	return hash_val;
 }
diff -Nru --exclude-from=3D/sunbeam/home/laforge/scripts/dontdiff linux-2.6=
=2E9-rc2-bk6/include/net/neighbour.h linux-2.6.9-rc2-bk6-ncache/include/net=
/neighbour.h
--- linux-2.6.9-rc2-bk6/include/net/neighbour.h	2004-09-21 00:23:16.0000000=
00 +0200
+++ linux-2.6.9-rc2-bk6-ncache/include/net/neighbour.h	2004-09-20 22:12:50.=
000000000 +0200
@@ -139,7 +139,6 @@
 	u8			key[0];
 };
=20
-#define NEIGH_HASHMASK		0x1F
 #define PNEIGH_HASHMASK		0xF
=20
 /*
@@ -160,11 +159,12 @@
 	void			(*proxy_redo)(struct sk_buff *skb);
 	char			*id;
 	struct neigh_parms	parms;
-	/* HACK. gc_* shoul follow parms without a gap! */
-	int			gc_interval;
+	/* UGLY HACK. gc_* and num_hash_buckets must follow parms without a
+	 * gap! */
 	int			gc_thresh1;
 	int			gc_thresh2;
 	int			gc_thresh3;
+	int			num_hash_buckets;
 	unsigned long		last_flush;
 	struct timer_list 	gc_timer;
 	struct timer_list 	proxy_timer;
@@ -175,7 +175,8 @@
 	struct neigh_parms	*parms_list;
 	kmem_cache_t		*kmem_cachep;
 	struct neigh_statistics	stats;
-	struct neighbour	*hash_buckets[NEIGH_HASHMASK+1];
+	struct neighbour	**hash_buckets;
+	int			curr_hash_bucket; /* For GC */
 	struct pneigh_entry	*phash_buckets[PNEIGH_HASHMASK+1];
 };
=20
diff -Nru --exclude-from=3D/sunbeam/home/laforge/scripts/dontdiff linux-2.6=
=2E9-rc2-bk6/include/linux/sysctl.h linux-2.6.9-rc2-bk6-ncache/include/linu=
x/sysctl.h
--- linux-2.6.9-rc2-bk6/include/linux/sysctl.h	2004-09-13 07:32:48.00000000=
0 +0200
+++ linux-2.6.9-rc2-bk6-ncache/include/linux/sysctl.h	2004-09-20 22:14:47.0=
00000000 +0200
@@ -494,7 +494,8 @@
 	NET_NEIGH_GC_INTERVAL=3D13,
 	NET_NEIGH_GC_THRESH1=3D14,
 	NET_NEIGH_GC_THRESH2=3D15,
-	NET_NEIGH_GC_THRESH3=3D16
+	NET_NEIGH_GC_THRESH3=3D16,
+	NET_NEIGH_NUM_HASH_BUCKETS=3D17
 };
=20
 /* /proc/sys/net/ipx */


--=20
- Harald Welte <laforge@gnumonks.org>               http://www.gnumonks.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
Programming is like sex: One mistake and you have to support it your lifeti=
me

--hEi834+foqWOL7fK
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)

iD8DBQFBT178XaXGVTD0i/8RAt5LAKC0ORGeV/O5bRU/nmlkqiloqsSWwgCgrukz
pJ65zugvm9UyKhBO6phUXMI=
=BfqU
-----END PGP SIGNATURE-----

--hEi834+foqWOL7fK--
