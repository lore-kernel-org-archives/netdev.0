From: Harald Welte <laforge@gnumonks.org>
Subject: Re: [PATCH 2.6] neighbour cache statistics like rt_stat
Date: Mon, 27 Sep 2004 18:23:34 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040927162334.GV3236@sunbeam.de.gnumonks.org>
References: <20040927093613.GH3236@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="I2z5DWo3OKf2mlg0"
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20040927093613.GH3236@sunbeam.de.gnumonks.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--I2z5DWo3OKf2mlg0
Content-Type: multipart/mixed; boundary="1AxFftPZlP9RA4ZR"
Content-Disposition: inline


--1AxFftPZlP9RA4ZR
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Sep 27, 2004 at 11:36:13AM +0200, Harald Welte wrote:
> The patch below (on top of davem's recent 6-patch set and 4-patch-set up
> to diff4) adds rt_stat like statistics to the neighbour cache core.

I've now updated the patch.

Changes:
	- more statistics (lookups, destroy, periodic_gc_runs)
	- add template line to top of file

--=20
- Harald Welte <laforge@gnumonks.org>               http://www.gnumonks.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
Programming is like sex: One mistake and you have to support it your lifeti=
me

--1AxFftPZlP9RA4ZR
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="laforge-neigh_statistics.patch"
Content-Transfer-Encoding: quoted-printable


Add rtstat-like per-cpu statistics to the neighbour cache core.

This will add=20
	/proc/net/arp_cache_stat for ipv4
	/proc/net/ndisc_cache_stat for ipv6
	/proc/net/clip_arp_cache_stat for atm/clip=20
	/proc/net/decnet_neigh_stat for decnet

The format is similar to rt_stat, one line per cpu where each line is:
	Field 0:	Total number of entries in table
	Field 1:	Total number of neighbour allocations in this tbl
	Field 2:	Total number of neighbour destroys in this tbl
	Field 3:	Total number of hash bucket grows
	Field 4:	Total number of failed neighbour resolves
	Field 5:	Total number of cache lookups
	Field 6:	Total number of cache hits
	Field 7:	Total number of received multicast solicitations
	Field 8:	Total number of received unicast solicitations
	Field 9:	Total number of periodic garbage collector runs
	Field 10:	Total number of forced garbage collector runs
	Field 11:	Total number of forced GC runs that missed their goal

Signed-off-by: Harald Welte <laforge@gnumonks.org>


Index: linux-2.6.9-rc2-bk9-neigh1/include/net/neighbour.h
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.9-rc2-bk9-neigh1.orig/include/net/neighbour.h	2004-09-26 12:4=
5:38.000000000 +0200
+++ linux-2.6.9-rc2-bk9-neigh1/include/net/neighbour.h	2004-09-27 13:44:49.=
000000000 +0200
@@ -7,6 +7,11 @@
  *	Authors:
  *	Pedro Roque		<roque@di.fc.ul.pt>
  *	Alexey Kuznetsov	<kuznet@ms2.inr.ac.ru>
+ *
+ * 	Changes:
+ *
+ *	Harald Welte:		<laforge@gnumonks.org>
+ *		- Add neighbour cache statistics like rtstat
  */
=20
 /* The following flags & states are exported to user space,
@@ -90,12 +95,26 @@
=20
 struct neigh_statistics
 {
-	unsigned long allocs;
-	unsigned long res_failed;
-	unsigned long rcv_probes_mcast;
-	unsigned long rcv_probes_ucast;
+	unsigned int allocs;		/* number of allocated neighs */
+	unsigned int destroys;		/* number of destroyed neighs */
+	unsigned int hash_grows;	/* number of hash resizes */
+
+	unsigned int res_failed;	/* nomber of failed resolutions */
+
+	unsigned int lookups;		/* number of lookups */
+	unsigned int hits;		/* number of hits (among lookups) */
+
+	unsigned int rcv_probes_mcast;	/* number of received mcast ipv6 */
+	unsigned int rcv_probes_ucast; /* number of received ucast ipv6 */
+
+	unsigned int periodic_gc_runs;	/* number of periodic GC runs */
+	unsigned int forced_gc_runs;	/* number of forced GC runs */
+	unsigned int forced_gc_goal_miss;/* number of gc goal misses */
 };
=20
+#define NEIGH_CACHE_STAT_INC(tbl, field)				\
+		(per_cpu_ptr((tbl)->stats, smp_processor_id())->field++)
+
 struct neighbour
 {
 	struct neighbour	*next;
@@ -172,12 +191,15 @@
 	unsigned long		last_rand;
 	struct neigh_parms	*parms_list;
 	kmem_cache_t		*kmem_cachep;
-	struct neigh_statistics	stats;
+	struct neigh_statistics	*stats;
 	struct neighbour	**hash_buckets;
 	unsigned int		hash_mask;
 	__u32			hash_rnd;
 	unsigned int		hash_chain_gc;
 	struct pneigh_entry	**phash_buckets;
+#ifdef CONFIG_PROC_FS
+	struct proc_dir_entry	*pde;
+#endif
 };
=20
 /* flags for neigh_update() */
Index: linux-2.6.9-rc2-bk9-neigh1/net/core/neighbour.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.9-rc2-bk9-neigh1.orig/net/core/neighbour.c	2004-09-26 12:37:1=
8.000000000 +0200
+++ linux-2.6.9-rc2-bk9-neigh1/net/core/neighbour.c	2004-09-27 17:24:41.990=
753504 +0200
@@ -12,6 +12,7 @@
  *
  *	Fixes:
  *	Vitaly E. Lavrov	releasing NULL neighbor in neigh_add.
+ *	Harald Welte		Add neighbour cache statistics like rtstat
  */
=20
 #include <linux/config.h>
@@ -21,6 +22,7 @@
 #include <linux/socket.h>
 #include <linux/sched.h>
 #include <linux/netdevice.h>
+#include <linux/proc_fs.h>
 #ifdef CONFIG_SYSCTL
 #include <linux/sysctl.h>
 #endif
@@ -59,6 +61,7 @@
=20
 static int neigh_glbl_allocs;
 static struct neigh_table *neigh_tables;
+static struct file_operations neigh_stat_seq_fops;
=20
 /*
    Neighbour hash table buckets are protected with rwlock tbl->lock.
@@ -115,6 +118,8 @@
 	int shrunk =3D 0, num_incomplete =3D 0, reap_incomplete =3D 0;
 	int i;
=20
+	NEIGH_CACHE_STAT_INC(tbl, forced_gc_runs);
+
 	write_lock_bh(&tbl->lock);
 rescan:
 	for (i =3D 0; i <=3D tbl->hash_mask; i++) {
@@ -161,6 +166,7 @@
 	if (reap_incomplete =3D=3D 0 &&
 	    shrunk < goal &&
 	    (shrunk + num_incomplete) >=3D goal) {
+		NEIGH_CACHE_STAT_INC(tbl, forced_gc_goal_miss);
 		reap_incomplete =3D 1;
 		goto rescan;
 	}
@@ -299,7 +305,8 @@
 	init_timer(&n->timer);
 	n->timer.function =3D neigh_timer_handler;
 	n->timer.data	  =3D (unsigned long)n;
-	tbl->stats.allocs++;
+
+	NEIGH_CACHE_STAT_INC(tbl, allocs);
 	neigh_glbl_allocs++;
 	tbl->entries++;
 	n->tbl		  =3D tbl;
@@ -341,6 +348,8 @@
 	struct neighbour **new_hash, **old_hash;
 	unsigned int i, new_hash_mask, old_entries;
=20
+	NEIGH_CACHE_STAT_INC(tbl, hash_grows);
+
 	BUG_ON(new_entries & (new_entries - 1));
 	new_hash =3D neigh_hash_alloc(new_entries);
 	if (!new_hash)
@@ -375,11 +384,14 @@
 	struct neighbour *n;
 	int key_len =3D tbl->key_len;
 	u32 hash_val =3D tbl->hash(pkey, dev) & tbl->hash_mask;
+=09
+	NEIGH_CACHE_STAT_INC(tbl, lookups);
=20
 	read_lock_bh(&tbl->lock);
 	for (n =3D tbl->hash_buckets[hash_val]; n; n =3D n->next) {
 		if (dev =3D=3D n->dev && !memcmp(n->primary_key, pkey, key_len)) {
 			neigh_hold(n);
+			NEIGH_CACHE_STAT_INC(tbl, hits);
 			break;
 		}
 	}
@@ -393,10 +405,13 @@
 	int key_len =3D tbl->key_len;
 	u32 hash_val =3D tbl->hash(pkey, NULL) & tbl->hash_mask;
=20
+	NEIGH_CACHE_STAT_INC(tbl, lookups);
+
 	read_lock_bh(&tbl->lock);
 	for (n =3D tbl->hash_buckets[hash_val]; n; n =3D n->next) {
 		if (!memcmp(n->primary_key, pkey, key_len)) {
 			neigh_hold(n);
+			NEIGH_CACHE_STAT_INC(tbl, hits);
 			break;
 		}
 	}
@@ -581,6 +596,8 @@
 {
 	struct hh_cache *hh;
=20
+	NEIGH_CACHE_STAT_INC(neigh->tbl, destroys);
+
 	if (!neigh->dead) {
 		printk(KERN_WARNING
 		       "Destroying alive neighbour %p\n", neigh);
@@ -656,6 +673,8 @@
 	struct neighbour *n, **np;
 	unsigned long expire, now =3D jiffies;
=20
+	NEIGH_CACHE_STAT_INC(tbl, periodic_gc_runs);
+
 	write_lock(&tbl->lock);
=20
 	/*
@@ -787,7 +806,7 @@
=20
 		neigh->nud_state =3D NUD_FAILED;
 		notify =3D 1;
-		neigh->tbl->stats.res_failed++;
+		NEIGH_CACHE_STAT_INC(neigh->tbl, res_failed);
 		NEIGH_PRINTK2("neigh %p is failed.\n", neigh);
=20
 		/* It is very thin place. report_unreachable is very complicated
@@ -1336,6 +1355,29 @@
 	if (!tbl->kmem_cachep)
 		panic("cannot create neighbour cache");
=20
+	tbl->stats =3D alloc_percpu(struct neigh_statistics);
+	if (!tbl->stats)
+		panic("cannot create neighbour cache statistics");
+=09
+#ifdef CONFIG_PROC_FS
+#define NC_STAT_SUFFIX "_stat"
+	{
+	char *proc_stat_name;
+	proc_stat_name =3D kmalloc(strlen(tbl->id) +=20
+				 strlen(NC_STAT_SUFFIX) + 1, GFP_KERNEL);
+	if (!proc_stat_name)
+		panic("cannot allocate neighbour cache proc name buffer");
+	strcpy(proc_stat_name, tbl->id);
+	strcat(proc_stat_name, NC_STAT_SUFFIX);
+
+	tbl->pde =3D create_proc_entry(proc_stat_name, 0, proc_net);
+	if (!tbl->pde)=20
+		panic("cannot create neighbour proc dir entry");
+	tbl->pde->proc_fops =3D &neigh_stat_seq_fops;
+	tbl->pde->data =3D tbl;
+	}
+#endif
+
 	tbl->hash_mask =3D 0x1f;
 	tbl->hash_buckets =3D neigh_hash_alloc(tbl->hash_mask + 1);
=20
@@ -1882,6 +1924,107 @@
 }
 EXPORT_SYMBOL(neigh_seq_stop);
=20
+/* statistics via seq_file */
+
+static void *neigh_stat_seq_start(struct seq_file *seq, loff_t *pos)
+{
+	struct proc_dir_entry *pde =3D seq->private;
+	struct neigh_table *tbl =3D pde->data;
+	int cpu;
+
+	if (*pos =3D=3D 0)
+		return SEQ_START_TOKEN;
+=09
+	for (cpu =3D *pos-1; cpu < NR_CPUS; ++cpu) {
+		if (!cpu_possible(cpu))
+			continue;
+		*pos =3D cpu+1;
+		return per_cpu_ptr(tbl->stats, cpu);
+	}
+	return NULL;
+}
+
+static void *neigh_stat_seq_next(struct seq_file *seq, void *v, loff_t *po=
s)
+{
+	struct proc_dir_entry *pde =3D seq->private;
+	struct neigh_table *tbl =3D pde->data;
+	int cpu;
+
+	for (cpu =3D *pos; cpu < NR_CPUS; ++cpu) {
+		if (!cpu_possible(cpu))
+			continue;
+		*pos =3D cpu+1;
+		return per_cpu_ptr(tbl->stats, cpu);
+	}
+	return NULL;
+}
+
+static void neigh_stat_seq_stop(struct seq_file *seq, void *v)
+{
+
+}
+
+static int neigh_stat_seq_show(struct seq_file *seq, void *v)
+{
+	struct proc_dir_entry *pde =3D seq->private;
+	struct neigh_table *tbl =3D pde->data;
+	struct neigh_statistics *st =3D v;
+
+	if (v =3D=3D SEQ_START_TOKEN) {
+		seq_printf(seq, "entries  allocs destroys hash_grows  lookups hits  res_=
failed  rcv_probes_mcast rcv_probes_ucast  periodic_gc_runs forced_gc_runs =
forced_gc_goal_miss\n");
+		return 0;
+	}
+
+	seq_printf(seq, "%08x  %08x %08x %08x  %08x %08x  %08x  %08x %08x  "
+			"%08x %08x %08x\n",
+		   tbl->entries,
+
+		   st->allocs,
+		   st->destroys,
+		   st->hash_grows,
+
+		   st->lookups,
+		   st->hits,
+
+		   st->res_failed,
+
+		   st->rcv_probes_mcast,
+		   st->rcv_probes_ucast,
+
+		   st->periodic_gc_runs,
+		   st->forced_gc_runs,
+		   st->forced_gc_goal_miss
+		   );
+
+	return 0;
+}
+
+static struct seq_operations neigh_stat_seq_ops =3D {
+	.start	=3D neigh_stat_seq_start,
+	.next	=3D neigh_stat_seq_next,
+	.stop	=3D neigh_stat_seq_stop,
+	.show	=3D neigh_stat_seq_show,
+};
+
+static int neigh_stat_seq_open(struct inode *inode, struct file *file)
+{
+	int ret =3D seq_open(file, &neigh_stat_seq_ops);
+
+	if (!ret) {
+		struct seq_file *sf =3D file->private_data;
+		sf->private =3D PDE(inode);
+	}
+	return ret;
+};
+
+static struct file_operations neigh_stat_seq_fops =3D {
+	.owner	 =3D THIS_MODULE,
+	.open 	 =3D neigh_stat_seq_open,
+	.read	 =3D seq_read,
+	.llseek	 =3D seq_lseek,
+	.release =3D seq_release,
+};
+
 #endif /* CONFIG_PROC_FS */
=20
 #ifdef CONFIG_ARPD
Index: linux-2.6.9-rc2-bk9-neigh1/net/ipv6/ndisc.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.9-rc2-bk9-neigh1.orig/net/ipv6/ndisc.c	2004-09-26 12:29:03.00=
0000000 +0200
+++ linux-2.6.9-rc2-bk9-neigh1/net/ipv6/ndisc.c	2004-09-26 23:30:56.0000000=
00 +0200
@@ -802,9 +802,9 @@
 	}
=20
 	if (inc)
-		nd_tbl.stats.rcv_probes_mcast++;
+		NEIGH_CACHE_STAT_INC(&nd_tbl, rcv_probes_mcast);
 	else
-		nd_tbl.stats.rcv_probes_ucast++;
+		NEIGH_CACHE_STAT_INC(&nd_tbl, rcv_probes_ucast);
=20
 	/*=20
 	 *	update / create cache entry

--1AxFftPZlP9RA4ZR--

--I2z5DWo3OKf2mlg0
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)

iD8DBQFBWD6GXaXGVTD0i/8RAn0TAKCBonyyrybY1T1RgxJ1wnbNjaRCUwCgnFlG
uzPyv10PJtowIPdhs0nUEfY=
=w/UB
-----END PGP SIGNATURE-----

--I2z5DWo3OKf2mlg0--
