From: Harald Welte <laforge@netfilter.org>
Subject: [PATCH 2.6] iptables hashlimit match
Date: Thu, 21 Oct 2004 00:45:06 +0200
Sender: netfilter-devel-bounces@lists.netfilter.org
Message-ID: <20041020224506.GQ19899@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="v6YRErhBvjoBjrPV"
Cc: Linux Netdev List <netdev@oss.sgi.com>,
	Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>,
	Markus Hennig <mhennig@astaro.com>, Gert Hansen <ghansen@astaro.com>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org


--v6YRErhBvjoBjrPV
Content-Type: multipart/mixed; boundary="nHJAUhyIZkPvF01C"
Content-Disposition: inline


--nHJAUhyIZkPvF01C
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Dave!

This is the third (and last, for now) patch, adding the 'hashlimit'
match to iptables.  It was previously known as 'dstlimit', but has now
been generalized one step further.

Please apply, thanks.

Signed-off-by: Harald Welte <laforge@netfilter.org>

--=20
- Harald Welte <laforge@netfilter.org>             http://www.netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--nHJAUhyIZkPvF01C
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: attachment; filename="2.6.9-hashlimit.patch"
Content-Transfer-Encoding: quoted-printable

diff -Nru --exclude-from=3D/sunbeam/home/laforge/scripts/dontdiff linux-2.6=
=2E9-connmark-clusterip/include/linux/netfilter_ipv4/ipt_hashlimit.h linux-=
2.6.9-connmark-clusterip-hashlimit/include/linux/netfilter_ipv4/ipt_hashlim=
it.h
--- linux-2.6.9-connmark-clusterip/include/linux/netfilter_ipv4/ipt_hashlim=
it.h	1970-01-01 01:00:00.000000000 +0100
+++ linux-2.6.9-connmark-clusterip-hashlimit/include/linux/netfilter_ipv4/i=
pt_hashlimit.h	2004-10-21 00:40:01.746818968 +0200
@@ -0,0 +1,40 @@
+#ifndef _IPT_HASHLIMIT_H
+#define _IPT_HASHLIMIT_H
+
+/* timings are in milliseconds. */
+#define IPT_HASHLIMIT_SCALE 10000
+/* 1/10,000 sec period =3D> max of 10,000/sec.  Min rate is then 429490
+   seconds, or one every 59 hours. */
+
+/* details of this structure hidden by the implementation */
+struct ipt_hashlimit_htable;
+
+#define IPT_HASHLIMIT_HASH_DIP	0x0001
+#define IPT_HASHLIMIT_HASH_DPT	0x0002
+#define IPT_HASHLIMIT_HASH_SIP	0x0004
+#define IPT_HASHLIMIT_HASH_SPT	0x0008
+
+struct hashlimit_cfg {
+	u_int32_t mode;	  /* bitmask of IPT_HASHLIMIT_HASH_* */
+	u_int32_t avg;    /* Average secs between packets * scale */
+	u_int32_t burst;  /* Period multiplier for upper limit. */
+
+	/* user specified */
+	u_int32_t size;		/* how many buckets */
+	u_int32_t max;		/* max number of entries */
+	u_int32_t gc_interval;	/* gc interval */
+	u_int32_t expire;	/* when do entries expire? */
+};
+
+struct ipt_hashlimit_info {
+	char name [IFNAMSIZ];		/* name */
+	struct hashlimit_cfg cfg;
+	struct ipt_hashlimit_htable *hinfo;
+
+	/* Used internally by the kernel */
+	union {
+		void *ptr;
+		struct ipt_hashlimit_info *master;
+	} u;
+};
+#endif /*_IPT_HASHLIMIT_H*/
diff -Nru --exclude-from=3D/sunbeam/home/laforge/scripts/dontdiff linux-2.6=
=2E9-connmark-clusterip/net/ipv4/netfilter/Kconfig linux-2.6.9-connmark-clu=
sterip-hashlimit/net/ipv4/netfilter/Kconfig
--- linux-2.6.9-connmark-clusterip/net/ipv4/netfilter/Kconfig	2004-10-21 00=
:30:17.802111752 +0200
+++ linux-2.6.9-connmark-clusterip-hashlimit/net/ipv4/netfilter/Kconfig	200=
4-10-21 00:41:00.931762220 +0200
@@ -361,6 +361,20 @@
 	  Documentation/modules.txt.  The module will be called
 	  ipt_connmark.o.  If unsure, say `N'.
=20
+config IP_NF_MATCH_HASHLIMIT
+	tristate  'hashlimit match support'
+	depends on IP_NF_IPTABLES
+	help
+	  This option adds a new iptables `hashlimit' match. =20
+
+	  As opposed to `limit', this match dynamically crates a hash table
+	  of limit buckets, based on your selection of source/destination
+	  ip addresses and/or ports.
+
+	  It enables you to express policies like `10kpps for any given
+	  destination IP' or `500pps from any given source IP'  with a single
+	  IPtables rule.
+
 # `filter', generic and specific targets
 config IP_NF_FILTER
 	tristate "Packet filtering"
diff -Nru --exclude-from=3D/sunbeam/home/laforge/scripts/dontdiff linux-2.6=
=2E9-connmark-clusterip/net/ipv4/netfilter/Makefile linux-2.6.9-connmark-cl=
usterip-hashlimit/net/ipv4/netfilter/Makefile
--- linux-2.6.9-connmark-clusterip/net/ipv4/netfilter/Makefile	2004-10-21 0=
0:23:57.927312860 +0200
+++ linux-2.6.9-connmark-clusterip-hashlimit/net/ipv4/netfilter/Makefile	20=
04-10-21 00:40:01.760818481 +0200
@@ -46,6 +46,7 @@
 # matches
 obj-$(CONFIG_IP_NF_MATCH_HELPER) +=3D ipt_helper.o
 obj-$(CONFIG_IP_NF_MATCH_LIMIT) +=3D ipt_limit.o
+obj-$(CONFIG_IP_NF_MATCH_HASHLIMIT) +=3D ipt_hashlimit.o
 obj-$(CONFIG_IP_NF_MATCH_SCTP) +=3D ipt_sctp.o
 obj-$(CONFIG_IP_NF_MATCH_MARK) +=3D ipt_mark.o
 obj-$(CONFIG_IP_NF_MATCH_MAC) +=3D ipt_mac.o
diff -Nru --exclude-from=3D/sunbeam/home/laforge/scripts/dontdiff linux-2.6=
=2E9-connmark-clusterip/net/ipv4/netfilter/ipt_hashlimit.c linux-2.6.9-conn=
mark-clusterip-hashlimit/net/ipv4/netfilter/ipt_hashlimit.c
--- linux-2.6.9-connmark-clusterip/net/ipv4/netfilter/ipt_hashlimit.c	1970-=
01-01 01:00:00.000000000 +0100
+++ linux-2.6.9-connmark-clusterip-hashlimit/net/ipv4/netfilter/ipt_hashlim=
it.c	2004-10-21 00:41:45.689206844 +0200
@@ -0,0 +1,716 @@
+/* iptables match extension to limit the number of packets per second
+ * seperately for each hashbucket (sourceip/sourceport/dstip/dstport)
+ *
+ * (C) 2003-2004 by Harald Welte <laforge@netfilter.org>
+ *
+ * $Id: ipt_hashlimit.c 3244 2004-10-20 16:24:29Z laforge@netfilter.org $
+ *
+ * Development of this code was funded by Astaro AG, http://www.astaro.com/
+ *
+ * based on ipt_limit.c by:
+ * J=E9r=F4me de Vivie	<devivie@info.enserb.u-bordeaux.fr>
+ * Herv=E9 Eychenne	<eychenne@info.enserb.u-bordeaux.fr>
+ * Rusty Russell	<rusty@rustcorp.com.au>
+ *
+ * The general idea is to create a hash table for every dstip and have a
+ * seperate limit counter per tuple.  This way you can do something like '=
limit
+ * the number of syn packets for each of my internal addresses.
+ *
+ * Ideally this would just be implemented as a general 'hash' match, which=
 would
+ * allow us to attach any iptables target to it's hash buckets.  But this =
is
+ * not possible in the current iptables architecture.  As always, pkttable=
s for
+ * 2.7.x will help ;)
+ */
+#include <linux/module.h>
+#include <linux/skbuff.h>
+#include <linux/spinlock.h>
+#include <linux/random.h>
+#include <linux/jhash.h>
+#include <linux/slab.h>
+#include <linux/vmalloc.h>
+#include <linux/tcp.h>
+#include <linux/udp.h>
+#include <linux/sctp.h>
+#include <linux/proc_fs.h>
+#include <linux/seq_file.h>
+
+#define ASSERT_READ_LOCK(x)=20
+#define ASSERT_WRITE_LOCK(x)=20
+#include <linux/netfilter_ipv4/lockhelp.h>
+#include <linux/netfilter_ipv4/listhelp.h>
+
+#include <linux/netfilter_ipv4/ip_tables.h>
+#include <linux/netfilter_ipv4/ipt_hashlimit.h>
+
+/* FIXME: this is just for IP_NF_ASSERRT */
+#include <linux/netfilter_ipv4/ip_conntrack.h>
+
+#define MS2JIFFIES(x) ((x*HZ)/1000)
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Harald Welte <laforge@netfilter.org>");
+MODULE_DESCRIPTION("iptables match for limiting per hash-bucket");
+
+/* need to declare this at the top */
+static struct proc_dir_entry *hashlimit_procdir;
+static struct file_operations dl_file_ops;
+
+/* hash table crap */
+
+struct dsthash_dst {
+	u_int32_t src_ip;
+	u_int32_t dst_ip;
+	/* ports have to be consecutive !!! */
+	u_int16_t src_port;
+	u_int16_t dst_port;
+};
+
+struct dsthash_ent {
+	/* static / read-only parts in the beginning */
+	struct list_head list;
+	struct dsthash_dst dst;
+
+	/* modified structure members in the end */
+	unsigned long expires;		/* precalculated expiry time */
+	struct {
+		unsigned long prev;	/* last modification */
+		u_int32_t credit;
+		u_int32_t credit_cap, cost;
+	} rateinfo;
+};
+
+struct ipt_hashlimit_htable {
+	struct list_head list;		/* global list of all htables */
+	atomic_t use;
+
+	struct hashlimit_cfg cfg;	/* config */
+
+	/* used internally */
+	spinlock_t lock;		/* lock for list_head */
+	u_int32_t rnd;			/* random seed for hash */
+	struct timer_list timer;	/* timer for gc */
+	atomic_t count;			/* number entries in table */
+
+	/* seq_file stuff */
+	struct proc_dir_entry *pde;
+
+	struct list_head hash[0];	/* hashtable itself */
+};
+
+DECLARE_RWLOCK(hashlimit_lock);		/* protects htables list */
+static LIST_HEAD(hashlimit_htables);
+static kmem_cache_t *hashlimit_cachep;
+
+static inline int dst_cmp(const struct dsthash_ent *ent, struct dsthash_ds=
t *b)
+{
+	return (ent->dst.dst_ip =3D=3D b->dst_ip=20
+		&& ent->dst.dst_port =3D=3D b->dst_port
+		&& ent->dst.src_port =3D=3D b->src_port
+		&& ent->dst.src_ip =3D=3D b->src_ip);
+}
+
+static inline u_int32_t
+hash_dst(const struct ipt_hashlimit_htable *ht, const struct dsthash_dst *=
dst)
+{
+	return (jhash_3words(dst->dst_ip, (dst->dst_port<<16 & dst->src_port),=20
+			     dst->src_ip, ht->rnd) % ht->cfg.size);
+}
+
+static inline struct dsthash_ent *
+__dsthash_find(const struct ipt_hashlimit_htable *ht, struct dsthash_dst *=
dst)
+{
+	struct dsthash_ent *ent;
+	u_int32_t hash =3D hash_dst(ht, dst);
+	MUST_BE_LOCKED(&ht->lock);
+	ent =3D LIST_FIND(&ht->hash[hash], dst_cmp, struct dsthash_ent *, dst);
+	return ent;
+}
+
+/* allocate dsthash_ent, initialize dst, put in htable and lock it */
+static struct dsthash_ent *
+__dsthash_alloc_init(struct ipt_hashlimit_htable *ht, struct dsthash_dst *=
dst)
+{
+	struct dsthash_ent *ent;
+
+	/* initialize hash with random val at the time we allocate
+	 * the first hashtable entry */
+	if (!ht->rnd)
+		get_random_bytes(&ht->rnd, 4);
+
+	if (ht->cfg.max &&
+	    atomic_read(&ht->count) >=3D ht->cfg.max) {
+		/* FIXME: do something. question is what.. */
+		if (net_ratelimit())
+			printk(KERN_WARNING=20
+				"ipt_hashlimit: max count of %u reached\n",=20
+				ht->cfg.max);
+		return NULL;
+	}
+
+	ent =3D kmem_cache_alloc(hashlimit_cachep, GFP_ATOMIC);
+	if (!ent) {
+		if (net_ratelimit())
+			printk(KERN_ERR=20
+				"ipt_hashlimit: can't allocate dsthash_ent\n");
+		return NULL;
+	}
+
+	atomic_inc(&ht->count);
+
+	ent->dst.dst_ip =3D dst->dst_ip;
+	ent->dst.dst_port =3D dst->dst_port;
+	ent->dst.src_ip =3D dst->src_ip;
+	ent->dst.src_port =3D dst->src_port;
+
+	list_add(&ent->list, &ht->hash[hash_dst(ht, dst)]);
+
+	return ent;
+}
+
+static inline void=20
+__dsthash_free(struct ipt_hashlimit_htable *ht, struct dsthash_ent *ent)
+{
+	MUST_BE_LOCKED(&ht->lock);
+
+	list_del(&ent->list);
+	kmem_cache_free(hashlimit_cachep, ent);
+	atomic_dec(&ht->count);
+}
+static void htable_gc(unsigned long htlong);
+
+static int htable_create(struct ipt_hashlimit_info *minfo)
+{
+	int i;
+	unsigned int size;
+	struct ipt_hashlimit_htable *hinfo;
+
+	if (minfo->cfg.size)
+		size =3D minfo->cfg.size;
+	else {
+		size =3D (((num_physpages << PAGE_SHIFT) / 16384)
+			 / sizeof(struct list_head));
+		if (num_physpages > (1024 * 1024 * 1024 / PAGE_SIZE))
+			size =3D 8192;
+		if (size < 16)
+			size =3D 16;
+	}
+	/* FIXME: don't use vmalloc() here or anywhere else -HW */
+	hinfo =3D vmalloc(sizeof(struct ipt_hashlimit_htable)
+			+ (sizeof(struct list_head) * size));
+	if (!hinfo) {
+		printk(KERN_ERR "ipt_hashlimit: Unable to create hashtable\n");
+		return -1;
+	}
+	minfo->hinfo =3D hinfo;
+
+	/* copy match config into hashtable config */
+	memcpy(&hinfo->cfg, &minfo->cfg, sizeof(hinfo->cfg));
+	hinfo->cfg.size =3D size;
+	if (!hinfo->cfg.max)
+		hinfo->cfg.max =3D 8 * hinfo->cfg.size;
+	else if (hinfo->cfg.max < hinfo->cfg.size)
+		hinfo->cfg.max =3D hinfo->cfg.size;
+
+	for (i =3D 0; i < hinfo->cfg.size; i++)
+		INIT_LIST_HEAD(&hinfo->hash[i]);
+
+	atomic_set(&hinfo->count, 0);
+	atomic_set(&hinfo->use, 1);
+	hinfo->rnd =3D 0;
+	hinfo->lock =3D SPIN_LOCK_UNLOCKED;
+	hinfo->pde =3D create_proc_entry(minfo->name, 0, hashlimit_procdir);
+	if (!hinfo->pde) {
+		vfree(hinfo);
+		return -1;
+	}
+	hinfo->pde->proc_fops =3D &dl_file_ops;
+	hinfo->pde->data =3D hinfo;
+
+	init_timer(&hinfo->timer);
+	hinfo->timer.expires =3D jiffies + MS2JIFFIES(hinfo->cfg.gc_interval);
+	hinfo->timer.data =3D (unsigned long )hinfo;
+	hinfo->timer.function =3D htable_gc;
+	add_timer(&hinfo->timer);
+
+	WRITE_LOCK(&hashlimit_lock);
+	list_add(&hinfo->list, &hashlimit_htables);
+	WRITE_UNLOCK(&hashlimit_lock);
+
+	return 0;
+}
+
+static int select_all(struct ipt_hashlimit_htable *ht, struct dsthash_ent =
*he)
+{
+	return 1;
+}
+
+static int select_gc(struct ipt_hashlimit_htable *ht, struct dsthash_ent *=
he)
+{
+	return (jiffies >=3D he->expires);
+}
+
+static void htable_selective_cleanup(struct ipt_hashlimit_htable *ht,
+		 		int (*select)(struct ipt_hashlimit_htable *ht,=20
+					      struct dsthash_ent *he))
+{
+	int i;
+
+	IP_NF_ASSERT(ht->cfg.size && ht->cfg.max);
+
+	/* lock hash table and iterate over it */
+	LOCK_BH(&ht->lock);
+	for (i =3D 0; i < ht->cfg.size; i++) {
+		struct dsthash_ent *dh, *n;
+		list_for_each_entry_safe(dh, n, &ht->hash[i], list) {
+			if ((*select)(ht, dh))
+				__dsthash_free(ht, dh);
+		}
+	}
+	UNLOCK_BH(&ht->lock);
+}
+
+/* hash table garbage collector, run by timer */
+static void htable_gc(unsigned long htlong)
+{
+	struct ipt_hashlimit_htable *ht =3D (struct ipt_hashlimit_htable *)htlong;
+
+	htable_selective_cleanup(ht, select_gc);
+
+	/* re-add the timer accordingly */
+	ht->timer.expires =3D jiffies + MS2JIFFIES(ht->cfg.gc_interval);
+	add_timer(&ht->timer);
+}
+
+static void htable_destroy(struct ipt_hashlimit_htable *hinfo)
+{
+	/* remove timer, if it is pending */
+	if (timer_pending(&hinfo->timer))
+		del_timer(&hinfo->timer);
+
+	/* remove proc entry */
+	remove_proc_entry(hinfo->pde->name, hashlimit_procdir);
+
+	htable_selective_cleanup(hinfo, select_all);
+	vfree(hinfo);
+}
+
+static struct ipt_hashlimit_htable *htable_find_get(char *name)
+{
+	struct ipt_hashlimit_htable *hinfo;
+
+	READ_LOCK(&hashlimit_lock);
+	list_for_each_entry(hinfo, &hashlimit_htables, list) {
+		if (!strcmp(name, hinfo->pde->name)) {
+			atomic_inc(&hinfo->use);
+			READ_UNLOCK(&hashlimit_lock);
+			return hinfo;
+		}
+	}
+	READ_UNLOCK(&hashlimit_lock);
+
+	return NULL;
+}
+
+static void htable_put(struct ipt_hashlimit_htable *hinfo)
+{
+	if (atomic_dec_and_test(&hinfo->use)) {
+		WRITE_LOCK(&hashlimit_lock);
+		list_del(&hinfo->list);
+		WRITE_UNLOCK(&hashlimit_lock);
+		htable_destroy(hinfo);
+	}
+}
+
+
+/* The algorithm used is the Simple Token Bucket Filter (TBF)
+ * see net/sched/sch_tbf.c in the linux source tree
+ */
+
+/* Rusty: This is my (non-mathematically-inclined) understanding of
+   this algorithm.  The `average rate' in jiffies becomes your initial
+   amount of credit `credit' and the most credit you can ever have
+   `credit_cap'.  The `peak rate' becomes the cost of passing the
+   test, `cost'.
+
+   `prev' tracks the last packet hit: you gain one credit per jiffy.
+   If you get credit balance more than this, the extra credit is
+   discarded.  Every time the match passes, you lose `cost' credits;
+   if you don't have that many, the test fails.
+
+   See Alexey's formal explanation in net/sched/sch_tbf.c.
+
+   To get the maximum range, we multiply by this factor (ie. you get N
+   credits per jiffy).  We want to allow a rate as low as 1 per day
+   (slowest userspace tool allows), which means
+   CREDITS_PER_JIFFY*HZ*60*60*24 < 2^32 ie.
+*/
+#define MAX_CPJ (0xFFFFFFFF / (HZ*60*60*24))
+
+/* Repeated shift and or gives us all 1s, final shift and add 1 gives
+ * us the power of 2 below the theoretical max, so GCC simply does a
+ * shift. */
+#define _POW2_BELOW2(x) ((x)|((x)>>1))
+#define _POW2_BELOW4(x) (_POW2_BELOW2(x)|_POW2_BELOW2((x)>>2))
+#define _POW2_BELOW8(x) (_POW2_BELOW4(x)|_POW2_BELOW4((x)>>4))
+#define _POW2_BELOW16(x) (_POW2_BELOW8(x)|_POW2_BELOW8((x)>>8))
+#define _POW2_BELOW32(x) (_POW2_BELOW16(x)|_POW2_BELOW16((x)>>16))
+#define POW2_BELOW32(x) ((_POW2_BELOW32(x)>>1) + 1)
+
+#define CREDITS_PER_JIFFY POW2_BELOW32(MAX_CPJ)
+
+/* Precision saver. */
+static inline u_int32_t
+user2credits(u_int32_t user)
+{
+	/* If multiplying would overflow... */
+	if (user > 0xFFFFFFFF / (HZ*CREDITS_PER_JIFFY))
+		/* Divide first. */
+		return (user / IPT_HASHLIMIT_SCALE) * HZ * CREDITS_PER_JIFFY;
+
+	return (user * HZ * CREDITS_PER_JIFFY) / IPT_HASHLIMIT_SCALE;
+}
+
+static inline void rateinfo_recalc(struct dsthash_ent *dh, unsigned long n=
ow)
+{
+	dh->rateinfo.credit +=3D (now - xchg(&dh->rateinfo.prev, now))=20
+					* CREDITS_PER_JIFFY;
+	if (dh->rateinfo.credit > dh->rateinfo.credit_cap)
+		dh->rateinfo.credit =3D dh->rateinfo.credit_cap;
+}
+
+static inline int get_ports(const struct sk_buff *skb, int offset,=20
+			    u16 ports[2])
+{
+	union {
+		struct tcphdr th;
+		struct udphdr uh;
+		sctp_sctphdr_t sctph;
+	} hdr_u, *ptr_u;
+
+	/* Must not be a fragment. */
+	if (offset)
+		return 1;
+
+	/* Must be big enough to read ports (both UDP and TCP have
+	   them at the start). */
+	ptr_u =3D skb_header_pointer(skb, skb->nh.iph->ihl*4, 8, &hdr_u);=20
+	if (!ptr_u)
+		return 1;
+
+	switch (skb->nh.iph->protocol) {
+		case IPPROTO_TCP:
+			ports[0] =3D ptr_u->th.source;
+			ports[1] =3D ptr_u->th.dest;
+			break;
+		case IPPROTO_UDP:
+			ports[0] =3D ptr_u->uh.source;
+			ports[1] =3D ptr_u->uh.dest;
+			break;
+		case IPPROTO_SCTP:
+			ports[0] =3D ptr_u->sctph.source;
+			ports[1] =3D ptr_u->sctph.dest;
+			break;
+		default:
+			/* all other protocols don't supprot per-port hash
+			 * buckets */
+			ports[0] =3D ports[1] =3D 0;
+			break;
+	}
+
+	return 0;
+}
+
+
+static int
+hashlimit_match(const struct sk_buff *skb,
+		const struct net_device *in,
+		const struct net_device *out,
+		const void *matchinfo,
+		int offset,
+		int *hotdrop)
+{
+	struct ipt_hashlimit_info *r =3D=20
+		((struct ipt_hashlimit_info *)matchinfo)->u.master;
+	struct ipt_hashlimit_htable *hinfo =3D r->hinfo;
+	unsigned long now =3D jiffies;
+	struct dsthash_ent *dh;
+	struct dsthash_dst dst;
+
+	/* build 'dst' according to hinfo->cfg and current packet */
+	memset(&dst, 0, sizeof(dst));
+	if (hinfo->cfg.mode & IPT_HASHLIMIT_HASH_DIP)
+		dst.dst_ip =3D skb->nh.iph->daddr;
+	if (hinfo->cfg.mode & IPT_HASHLIMIT_HASH_SIP)
+		dst.src_ip =3D skb->nh.iph->saddr;
+	if (hinfo->cfg.mode & IPT_HASHLIMIT_HASH_DPT
+	    ||hinfo->cfg.mode & IPT_HASHLIMIT_HASH_SPT) {
+		u_int16_t ports[2];
+		if (get_ports(skb, offset, ports)) {
+			/* We've been asked to examine this packet, and we
+		 	  can't.  Hence, no choice but to drop. */
+			*hotdrop =3D 1;
+			return 0;
+		}
+		if (hinfo->cfg.mode & IPT_HASHLIMIT_HASH_SPT)
+			dst.src_port =3D ports[0];
+		if (hinfo->cfg.mode & IPT_HASHLIMIT_HASH_DPT)
+			dst.dst_port =3D ports[1];
+	}=20
+
+	LOCK_BH(&hinfo->lock);
+	dh =3D __dsthash_find(hinfo, &dst);
+	if (!dh) {
+		dh =3D __dsthash_alloc_init(hinfo, &dst);
+
+		if (!dh) {
+			/* enomem... don't match =3D=3D DROP */
+			if (net_ratelimit())
+				printk(KERN_ERR "%s: ENOMEM\n", __FUNCTION__);
+			UNLOCK_BH(&hinfo->lock);
+			return 0;
+		}
+
+		dh->expires =3D jiffies + MS2JIFFIES(hinfo->cfg.expire);
+
+		dh->rateinfo.prev =3D jiffies;
+		dh->rateinfo.credit =3D user2credits(hinfo->cfg.avg *=20
+							hinfo->cfg.burst);
+		dh->rateinfo.credit_cap =3D user2credits(hinfo->cfg.avg *=20
+							hinfo->cfg.burst);
+		dh->rateinfo.cost =3D user2credits(hinfo->cfg.avg);
+
+		UNLOCK_BH(&hinfo->lock);
+		return 1;
+	}
+
+	/* update expiration timeout */
+	dh->expires =3D now + MS2JIFFIES(hinfo->cfg.expire);
+
+	rateinfo_recalc(dh, now);
+	if (dh->rateinfo.credit >=3D dh->rateinfo.cost) {
+		/* We're underlimit. */
+		dh->rateinfo.credit -=3D dh->rateinfo.cost;
+		UNLOCK_BH(&hinfo->lock);
+		return 1;
+	}
+
+       	UNLOCK_BH(&hinfo->lock);
+
+	/* default case: we're overlimit, thus don't match */
+	return 0;
+}
+
+static int
+hashlimit_checkentry(const char *tablename,
+		     const struct ipt_ip *ip,
+		     void *matchinfo,
+		     unsigned int matchsize,
+		     unsigned int hook_mask)
+{
+	struct ipt_hashlimit_info *r =3D matchinfo;
+
+	if (matchsize !=3D IPT_ALIGN(sizeof(struct ipt_hashlimit_info)))
+		return 0;
+
+	/* Check for overflow. */
+	if (r->cfg.burst =3D=3D 0
+	    || user2credits(r->cfg.avg * r->cfg.burst) <=20
+	    				user2credits(r->cfg.avg)) {
+		printk(KERN_ERR "ipt_hashlimit: Overflow, try lower: %u/%u\n",
+		       r->cfg.avg, r->cfg.burst);
+		return 0;
+	}
+
+	if (r->cfg.mode =3D=3D 0=20
+	    || r->cfg.mode > (IPT_HASHLIMIT_HASH_DPT
+		          |IPT_HASHLIMIT_HASH_DIP
+			  |IPT_HASHLIMIT_HASH_SIP
+			  |IPT_HASHLIMIT_HASH_SPT))
+		return 0;
+
+	if (!r->cfg.gc_interval)
+		return 0;
+=09
+	if (!r->cfg.expire)
+		return 0;
+
+	r->hinfo =3D htable_find_get(r->name);
+	if (!r->hinfo && (htable_create(r) !=3D 0)) {
+		return 0;
+	}
+
+	/* Ugly hack: For SMP, we only want to use one set */
+	r->u.master =3D r;
+
+	return 1;
+}
+
+static void
+hashlimit_destroy(void *matchinfo, unsigned int matchsize)
+{
+	struct ipt_hashlimit_info *r =3D (struct ipt_hashlimit_info *) matchinfo;
+
+	htable_put(r->hinfo);
+}
+
+static struct ipt_match ipt_hashlimit =3D {=20
+	.name =3D "hashlimit",=20
+	.match =3D hashlimit_match,=20
+	.checkentry =3D hashlimit_checkentry,=20
+	.destroy =3D hashlimit_destroy,
+	.me =3D THIS_MODULE=20
+};
+
+/* PROC stuff */
+
+static void *dl_seq_start(struct seq_file *s, loff_t *pos)
+{
+	struct proc_dir_entry *pde =3D s->private;
+	struct ipt_hashlimit_htable *htable =3D pde->data;
+	unsigned int *bucket;
+
+	LOCK_BH(&htable->lock);
+	if (*pos >=3D htable->cfg.size)
+		return NULL;
+
+	bucket =3D kmalloc(sizeof(unsigned int), GFP_KERNEL);
+	if (!bucket)
+		return ERR_PTR(-ENOMEM);
+
+	*bucket =3D *pos;
+	return bucket;
+}
+
+static void *dl_seq_next(struct seq_file *s, void *v, loff_t *pos)
+{
+	struct proc_dir_entry *pde =3D s->private;
+	struct ipt_hashlimit_htable *htable =3D pde->data;
+	unsigned int *bucket =3D (unsigned int *)v;
+
+	*pos =3D ++(*bucket);
+	if (*pos >=3D htable->cfg.size) {
+		kfree(v);
+		return NULL;
+	}
+	return bucket;
+}
+
+static void dl_seq_stop(struct seq_file *s, void *v)
+{
+	struct proc_dir_entry *pde =3D s->private;
+	struct ipt_hashlimit_htable *htable =3D pde->data;
+	unsigned int *bucket =3D (unsigned int *)v;
+
+	kfree(bucket);
+
+	UNLOCK_BH(&htable->lock);
+}
+
+static inline int dl_seq_real_show(struct dsthash_ent *ent, struct seq_fil=
e *s)
+{
+	/* recalculate to show accurate numbers */
+	rateinfo_recalc(ent, jiffies);
+
+	return seq_printf(s, "%ld %u.%u.%u.%u:%u->%u.%u.%u.%u:%u %u %u %u\n",
+			(ent->expires - jiffies)/HZ,
+			NIPQUAD(ent->dst.src_ip), ntohs(ent->dst.src_port),
+			NIPQUAD(ent->dst.dst_ip), ntohs(ent->dst.dst_port),
+			ent->rateinfo.credit, ent->rateinfo.credit_cap,
+			ent->rateinfo.cost);
+}
+
+static int dl_seq_show(struct seq_file *s, void *v)
+{
+	struct proc_dir_entry *pde =3D s->private;
+	struct ipt_hashlimit_htable *htable =3D pde->data;
+	unsigned int *bucket =3D (unsigned int *)v;
+
+	if (LIST_FIND_W(&htable->hash[*bucket], dl_seq_real_show,
+		      struct dsthash_ent *, s)) {
+		/* buffer was filled and unable to print that tuple */
+		return 1;
+	}
+	return 0;
+}
+
+static struct seq_operations dl_seq_ops =3D {
+	.start =3D dl_seq_start,
+	.next  =3D dl_seq_next,
+	.stop  =3D dl_seq_stop,
+	.show  =3D dl_seq_show
+};
+
+static int dl_proc_open(struct inode *inode, struct file *file)
+{
+	int ret =3D seq_open(file, &dl_seq_ops);
+
+	if (!ret) {
+		struct seq_file *sf =3D file->private_data;
+		sf->private =3D PDE(inode);
+	}
+	return ret;
+}
+
+static struct file_operations dl_file_ops =3D {
+	.owner   =3D THIS_MODULE,
+	.open    =3D dl_proc_open,
+	.read    =3D seq_read,
+	.llseek  =3D seq_lseek,
+	.release =3D seq_release
+};
+
+static int init_or_fini(int fini)
+{
+	int ret =3D 0;
+
+	if (fini)
+		goto cleanup;
+
+	if (ipt_register_match(&ipt_hashlimit)) {
+		ret =3D -EINVAL;
+		goto cleanup_nothing;
+	}
+
+	/* FIXME: do we really want HWCACHE_ALIGN since our objects are
+	 * quite small ? */
+	hashlimit_cachep =3D kmem_cache_create("ipt_hashlimit",
+					    sizeof(struct dsthash_ent), 0,
+					    SLAB_HWCACHE_ALIGN, NULL, NULL);
+	if (!hashlimit_cachep) {
+		printk(KERN_ERR "Unable to create ipt_hashlimit slab cache\n");
+		ret =3D -ENOMEM;
+		goto cleanup_unreg_match;
+	}
+
+	hashlimit_procdir =3D proc_mkdir("ipt_hashlimit", proc_net);
+	if (!hashlimit_procdir) {
+		printk(KERN_ERR "Unable to create proc dir entry\n");
+		ret =3D -ENOMEM;
+		goto cleanup_free_slab;
+	}
+
+	return ret;
+
+cleanup:
+	remove_proc_entry("ipt_hashlimit", proc_net);
+cleanup_free_slab:
+	kmem_cache_destroy(hashlimit_cachep);
+cleanup_unreg_match:
+	ipt_unregister_match(&ipt_hashlimit);
+cleanup_nothing:
+	return ret;
+=09
+}
+
+static int __init init(void)
+{
+	return init_or_fini(0);
+}
+
+static void __exit fini(void)
+{
+	init_or_fini(1);
+}
+
+module_init(init);
+module_exit(fini);

--nHJAUhyIZkPvF01C--

--v6YRErhBvjoBjrPV
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)

iD8DBQFBdupyXaXGVTD0i/8RAigZAJ92jVUs/QqL+pQOB9DnUINnVs0cpwCgkMuY
+ThDszo03iEfrcYkIn++OOs=
=p5c7
-----END PGP SIGNATURE-----

--v6YRErhBvjoBjrPV--
