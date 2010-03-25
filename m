From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: debugging kernel during packet drops
Date: Thu, 25 Mar 2010 10:32:54 +0100
Message-ID: <1269509574.3626.9.camel@edumazet-laptop>
References: <4BA74950.6000305@infopact.nl> <4BA7A5D8.5080101@trash.net>
	 <4BA8DAC5.6050002@infopact.nl> <1269364893.2983.296.camel@edumazet-laptop>
	 <4BAA2DC5.7000409@infopact.nl>  <1269447674.3213.64.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netfilter-devel@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>
To: Jorrit Kronjee <j.kronjee@infopact.nl>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1269447674.3213.64.camel@edumazet-laptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mercredi 24 mars 2010 =C3=A0 17:22 +0100, Eric Dumazet a =C3=A9crit =
:
> Le mercredi 24 mars 2010 =C3=A0 16:20 +0100, Jorrit Kronjee a =C3=A9c=
rit :

> >=20
> > I hope this helps! Is there anything special I need to do to use RP=
S?
> >=20
>=20
> Sure this helps a lot !
>=20
> You might try RPS by doing :
>=20
> echo f >/sys/class/net/eth3/queues/rx-0/rps_cpus
>=20
> (But you'll also need a new xt_hashlimit module to make it more
> scalable, I can work on this this week if necessary)
>=20

Here is patch I cooked for xt_hashlimit (on top of net-next-2.6) to mak=
e
it use RCU and scale better in your case (allowing several concurrent
cpus once RPS is activated), but also on more general cases.

[PATCH] xt_hashlimit: RCU conversion

xt_hashlimit uses a central lock per hash table and suffers from
contention on some workloads.

After RCU conversion, central lock is only used when a writer wants to
add or delete an entry. For 'readers', updating an existing entry, they
use an individual lock per entry.


Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/netfilter/xt_hashlimit.c |  290 +++++++++++++++++----------------
 1 file changed, 151 insertions(+), 139 deletions(-)

diff --git a/net/netfilter/xt_hashlimit.c b/net/netfilter/xt_hashlimit.=
c
index 9e9c489..a4f1b69 100644
--- a/net/netfilter/xt_hashlimit.c
+++ b/net/netfilter/xt_hashlimit.c
@@ -41,6 +41,54 @@ MODULE_DESCRIPTION("Xtables: per hash-bucket rate-li=
mit match");
 MODULE_ALIAS("ipt_hashlimit");
 MODULE_ALIAS("ip6t_hashlimit");
=20
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
+		return (user / XT_HASHLIMIT_SCALE) * HZ * CREDITS_PER_JIFFY;
+
+	return (user * HZ * CREDITS_PER_JIFFY) / XT_HASHLIMIT_SCALE;
+}
+
 struct hashlimit_net {
 	struct hlist_head	htables;
 	struct proc_dir_entry	*ipt_hashlimit;
@@ -80,12 +128,14 @@ struct dsthash_ent {
 	struct dsthash_dst dst;
=20
 	/* modified structure members in the end */
+	spinlock_t lock;
 	unsigned long expires;		/* precalculated expiry time */
 	struct {
 		unsigned long prev;	/* last modification */
 		u_int32_t credit;
-		u_int32_t credit_cap, cost;
+		u_int32_t cost;
 	} rateinfo;
+	struct rcu_head rcu;
 };
=20
 struct xt_hashlimit_htable {
@@ -95,10 +145,12 @@ struct xt_hashlimit_htable {
 	bool rnd_initialized;
=20
 	struct hashlimit_cfg1 cfg;	/* config */
+	u_int32_t credit_cap;
=20
 	/* used internally */
-	spinlock_t lock;		/* lock for list_head */
 	u_int32_t rnd;			/* random seed for hash */
+
+	spinlock_t hlock;		/* lock for writes to hash[]/count/rnd */
 	unsigned int count;		/* number entries in table */
 	struct timer_list timer;	/* timer for gc */
=20
@@ -142,55 +194,27 @@ dsthash_find(const struct xt_hashlimit_htable *ht=
,
 	u_int32_t hash =3D hash_dst(ht, dst);
=20
 	if (!hlist_empty(&ht->hash[hash])) {
-		hlist_for_each_entry(ent, pos, &ht->hash[hash], node)
-			if (dst_cmp(ent, dst))
+		hlist_for_each_entry_rcu(ent, pos, &ht->hash[hash], node)
+			if (dst_cmp(ent, dst)) {
+				spin_lock(&ent->lock);
 				return ent;
+			}
 	}
 	return NULL;
 }
=20
-/* allocate dsthash_ent, initialize dst, put in htable and lock it */
-static struct dsthash_ent *
-dsthash_alloc_init(struct xt_hashlimit_htable *ht,
-		   const struct dsthash_dst *dst)
-{
-	struct dsthash_ent *ent;
-
-	/* initialize hash with random val at the time we allocate
-	 * the first hashtable entry */
-	if (!ht->rnd_initialized) {
-		get_random_bytes(&ht->rnd, sizeof(ht->rnd));
-		ht->rnd_initialized =3D true;
-	}
-
-	if (ht->cfg.max && ht->count >=3D ht->cfg.max) {
-		/* FIXME: do something. question is what.. */
-		if (net_ratelimit())
-			printk(KERN_WARNING
-				"xt_hashlimit: max count of %u reached\n",
-				ht->cfg.max);
-		return NULL;
-	}
=20
-	ent =3D kmem_cache_alloc(hashlimit_cachep, GFP_ATOMIC);
-	if (!ent) {
-		if (net_ratelimit())
-			printk(KERN_ERR
-				"xt_hashlimit: can't allocate dsthash_ent\n");
-		return NULL;
-	}
-	memcpy(&ent->dst, dst, sizeof(ent->dst));
+static void dsthash_free_rcu(struct rcu_head *head)
+{
+	struct dsthash_ent *ent =3D container_of(head, struct dsthash_ent, rc=
u);
=20
-	hlist_add_head(&ent->node, &ht->hash[hash_dst(ht, dst)]);
-	ht->count++;
-	return ent;
+	kmem_cache_free(hashlimit_cachep, ent);
 }
=20
-static inline void
-dsthash_free(struct xt_hashlimit_htable *ht, struct dsthash_ent *ent)
+static void dsthash_free(struct xt_hashlimit_htable *ht, struct dsthas=
h_ent *ent)
 {
-	hlist_del(&ent->node);
-	kmem_cache_free(hashlimit_cachep, ent);
+	hlist_del_rcu(&ent->node);
+	call_rcu_bh(&ent->rcu, dsthash_free_rcu);
 	ht->count--;
 }
 static void htable_gc(unsigned long htlong);
@@ -243,11 +267,12 @@ static int htable_create_v0(struct net *net, stru=
ct xt_hashlimit_info *minfo, u_
 	for (i =3D 0; i < hinfo->cfg.size; i++)
 		INIT_HLIST_HEAD(&hinfo->hash[i]);
=20
+	hinfo->credit_cap =3D user2credits(hinfo->cfg.avg * hinfo->cfg.burst)=
;
 	hinfo->use =3D 1;
 	hinfo->count =3D 0;
 	hinfo->family =3D family;
 	hinfo->rnd_initialized =3D false;
-	spin_lock_init(&hinfo->lock);
+	spin_lock_init(&hinfo->hlock);
 	hinfo->pde =3D proc_create_data(minfo->name, 0,
 		(family =3D=3D NFPROTO_IPV4) ?
 		hashlimit_net->ipt_hashlimit : hashlimit_net->ip6t_hashlimit,
@@ -305,11 +330,12 @@ static int htable_create(struct net *net, struct =
xt_hashlimit_mtinfo1 *minfo,
 	for (i =3D 0; i < hinfo->cfg.size; i++)
 		INIT_HLIST_HEAD(&hinfo->hash[i]);
=20
+	hinfo->credit_cap =3D user2credits(hinfo->cfg.avg * hinfo->cfg.burst)=
;
 	hinfo->use =3D 1;
 	hinfo->count =3D 0;
 	hinfo->family =3D family;
 	hinfo->rnd_initialized =3D false;
-	spin_lock_init(&hinfo->lock);
+	spin_lock_init(&hinfo->hlock);
=20
 	hinfo->pde =3D proc_create_data(minfo->name, 0,
 		(family =3D=3D NFPROTO_IPV4) ?
@@ -349,7 +375,7 @@ static void htable_selective_cleanup(struct xt_hash=
limit_htable *ht,
 	unsigned int i;
=20
 	/* lock hash table and iterate over it */
-	spin_lock_bh(&ht->lock);
+	spin_lock_bh(&ht->hlock);
 	for (i =3D 0; i < ht->cfg.size; i++) {
 		struct dsthash_ent *dh;
 		struct hlist_node *pos, *n;
@@ -358,7 +384,7 @@ static void htable_selective_cleanup(struct xt_hash=
limit_htable *ht,
 				dsthash_free(ht, dh);
 		}
 	}
-	spin_unlock_bh(&ht->lock);
+	spin_unlock_bh(&ht->hlock);
 }
=20
 /* hash table garbage collector, run by timer */
@@ -417,59 +443,12 @@ static void htable_put(struct xt_hashlimit_htable=
 *hinfo)
 	mutex_unlock(&hashlimit_mutex);
 }
=20
-/* The algorithm used is the Simple Token Bucket Filter (TBF)
- * see net/sched/sch_tbf.c in the linux source tree
- */
-
-/* Rusty: This is my (non-mathematically-inclined) understanding of
-   this algorithm.  The `average rate' in jiffies becomes your initial
-   amount of credit `credit' and the most credit you can ever have
-   `credit_cap'.  The `peak rate' becomes the cost of passing the
-   test, `cost'.
-
-   `prev' tracks the last packet hit: you gain one credit per jiffy.
-   If you get credit balance more than this, the extra credit is
-   discarded.  Every time the match passes, you lose `cost' credits;
-   if you don't have that many, the test fails.
-
-   See Alexey's formal explanation in net/sched/sch_tbf.c.
-
-   To get the maximum range, we multiply by this factor (ie. you get N
-   credits per jiffy).  We want to allow a rate as low as 1 per day
-   (slowest userspace tool allows), which means
-   CREDITS_PER_JIFFY*HZ*60*60*24 < 2^32 ie.
-*/
-#define MAX_CPJ (0xFFFFFFFF / (HZ*60*60*24))
-
-/* Repeated shift and or gives us all 1s, final shift and add 1 gives
- * us the power of 2 below the theoretical max, so GCC simply does a
- * shift. */
-#define _POW2_BELOW2(x) ((x)|((x)>>1))
-#define _POW2_BELOW4(x) (_POW2_BELOW2(x)|_POW2_BELOW2((x)>>2))
-#define _POW2_BELOW8(x) (_POW2_BELOW4(x)|_POW2_BELOW4((x)>>4))
-#define _POW2_BELOW16(x) (_POW2_BELOW8(x)|_POW2_BELOW8((x)>>8))
-#define _POW2_BELOW32(x) (_POW2_BELOW16(x)|_POW2_BELOW16((x)>>16))
-#define POW2_BELOW32(x) ((_POW2_BELOW32(x)>>1) + 1)
-
-#define CREDITS_PER_JIFFY POW2_BELOW32(MAX_CPJ)
-
-/* Precision saver. */
-static inline u_int32_t
-user2credits(u_int32_t user)
-{
-	/* If multiplying would overflow... */
-	if (user > 0xFFFFFFFF / (HZ*CREDITS_PER_JIFFY))
-		/* Divide first. */
-		return (user / XT_HASHLIMIT_SCALE) * HZ * CREDITS_PER_JIFFY;
-
-	return (user * HZ * CREDITS_PER_JIFFY) / XT_HASHLIMIT_SCALE;
-}
-
-static inline void rateinfo_recalc(struct dsthash_ent *dh, unsigned lo=
ng now)
+static inline void rateinfo_recalc(struct dsthash_ent *dh, unsigned lo=
ng now,
+				   struct xt_hashlimit_htable *hinfo)
 {
 	dh->rateinfo.credit +=3D (now - dh->rateinfo.prev) * CREDITS_PER_JIFF=
Y;
-	if (dh->rateinfo.credit > dh->rateinfo.credit_cap)
-		dh->rateinfo.credit =3D dh->rateinfo.credit_cap;
+	if (dh->rateinfo.credit > hinfo->credit_cap)
+		dh->rateinfo.credit =3D hinfo->credit_cap;
 	dh->rateinfo.prev =3D now;
 }
=20
@@ -563,9 +542,7 @@ hashlimit_init_dst(const struct xt_hashlimit_htable=
 *hinfo,
 					   &_ports);
 		break;
 	default:
-		_ports[0] =3D _ports[1] =3D 0;
-		ports =3D _ports;
-		break;
+		return 0;
 	}
 	if (!ports)
 		return -1;
@@ -576,6 +553,48 @@ hashlimit_init_dst(const struct xt_hashlimit_htabl=
e *hinfo,
 	return 0;
 }
=20
+/* allocate dsthash_ent, initialize dst, put in htable and lock it */
+static struct dsthash_ent *
+dsthash_alloc_init(struct xt_hashlimit_htable *ht,
+		   const struct dsthash_dst *dst)
+{
+	struct dsthash_ent *ent =3D NULL;
+
+	spin_lock(&ht->hlock);
+	/* initialize hash with random val at the time we allocate
+	 * the first hashtable entry */
+	if (unlikely(!ht->rnd_initialized)) {
+		get_random_bytes(&ht->rnd, sizeof(ht->rnd));
+		ht->rnd_initialized =3D true;
+	}
+
+	if (ht->cfg.max && ht->count >=3D ht->cfg.max) {
+		/* FIXME: do something. question is what.. */
+		if (net_ratelimit())
+			printk(KERN_WARNING
+				"xt_hashlimit: max count of %u reached\n",
+				ht->cfg.max);
+	} else=20
+		ent =3D kmem_cache_alloc(hashlimit_cachep, GFP_ATOMIC);
+	if (!ent) {
+		if (net_ratelimit())
+			pr_err("xt_hashlimit: can't allocate dsthash_ent\n");
+	} else {
+		memcpy(&ent->dst, dst, sizeof(ent->dst));
+		spin_lock_init(&ent->lock);
+		ent->expires =3D jiffies + msecs_to_jiffies(ht->cfg.expire);
+		ent->rateinfo.prev =3D jiffies;
+		ent->rateinfo.credit =3D ht->credit_cap;
+		ent->rateinfo.cost =3D user2credits(ht->cfg.avg);
+		spin_lock(&ent->lock);
+
+		hlist_add_head_rcu(&ent->node, &ht->hash[hash_dst(ht, dst)]);
+		ht->count++;
+	}
+	spin_unlock(&ht->hlock);
+	return ent;
+}
+
 static bool
 hashlimit_mt_v0(const struct sk_buff *skb, const struct xt_match_param=
 *par)
 {
@@ -588,38 +607,30 @@ hashlimit_mt_v0(const struct sk_buff *skb, const =
struct xt_match_param *par)
 	if (hashlimit_init_dst(hinfo, &dst, skb, par->thoff) < 0)
 		goto hotdrop;
=20
-	spin_lock_bh(&hinfo->lock);
+	rcu_read_lock_bh();
 	dh =3D dsthash_find(hinfo, &dst);
 	if (!dh) {
 		dh =3D dsthash_alloc_init(hinfo, &dst);
 		if (!dh) {
-			spin_unlock_bh(&hinfo->lock);
+			rcu_read_unlock_bh();
 			goto hotdrop;
 		}
-
-		dh->expires =3D jiffies + msecs_to_jiffies(hinfo->cfg.expire);
-		dh->rateinfo.prev =3D jiffies;
-		dh->rateinfo.credit =3D user2credits(hinfo->cfg.avg *
-						   hinfo->cfg.burst);
-		dh->rateinfo.credit_cap =3D user2credits(hinfo->cfg.avg *
-						       hinfo->cfg.burst);
-		dh->rateinfo.cost =3D user2credits(hinfo->cfg.avg);
 	} else {
 		/* update expiration timeout */
 		dh->expires =3D now + msecs_to_jiffies(hinfo->cfg.expire);
-		rateinfo_recalc(dh, now);
+		rateinfo_recalc(dh, now, hinfo);
 	}
=20
 	if (dh->rateinfo.credit >=3D dh->rateinfo.cost) {
 		/* We're underlimit. */
 		dh->rateinfo.credit -=3D dh->rateinfo.cost;
-		spin_unlock_bh(&hinfo->lock);
+		spin_unlock(&dh->lock);
+		rcu_read_unlock_bh();
 		return true;
 	}
=20
-	spin_unlock_bh(&hinfo->lock);
-
-	/* default case: we're overlimit, thus don't match */
+	spin_unlock(&dh->lock);
+	rcu_read_unlock_bh();
 	return false;
=20
 hotdrop:
@@ -639,36 +650,31 @@ hashlimit_mt(const struct sk_buff *skb, const str=
uct xt_match_param *par)
 	if (hashlimit_init_dst(hinfo, &dst, skb, par->thoff) < 0)
 		goto hotdrop;
=20
-	spin_lock_bh(&hinfo->lock);
+	rcu_read_lock_bh();
 	dh =3D dsthash_find(hinfo, &dst);
 	if (dh =3D=3D NULL) {
 		dh =3D dsthash_alloc_init(hinfo, &dst);
 		if (dh =3D=3D NULL) {
-			spin_unlock_bh(&hinfo->lock);
+			rcu_read_unlock_bh();
 			goto hotdrop;
 		}
=20
-		dh->expires =3D jiffies + msecs_to_jiffies(hinfo->cfg.expire);
-		dh->rateinfo.prev =3D jiffies;
-		dh->rateinfo.credit =3D user2credits(hinfo->cfg.avg *
-		                      hinfo->cfg.burst);
-		dh->rateinfo.credit_cap =3D user2credits(hinfo->cfg.avg *
-		                          hinfo->cfg.burst);
-		dh->rateinfo.cost =3D user2credits(hinfo->cfg.avg);
 	} else {
 		/* update expiration timeout */
 		dh->expires =3D now + msecs_to_jiffies(hinfo->cfg.expire);
-		rateinfo_recalc(dh, now);
+		rateinfo_recalc(dh, now, hinfo);
 	}
=20
 	if (dh->rateinfo.credit >=3D dh->rateinfo.cost) {
 		/* below the limit */
 		dh->rateinfo.credit -=3D dh->rateinfo.cost;
-		spin_unlock_bh(&hinfo->lock);
+		spin_unlock(&dh->lock);
+		rcu_read_unlock_bh();
 		return !(info->cfg.mode & XT_HASHLIMIT_INVERT);
 	}
=20
-	spin_unlock_bh(&hinfo->lock);
+	spin_unlock(&dh->lock);
+	rcu_read_unlock_bh();
 	/* default match is underlimit - so over the limit, we need to invert=
 */
 	return info->cfg.mode & XT_HASHLIMIT_INVERT;
=20
@@ -843,12 +849,12 @@ static struct xt_match hashlimit_mt_reg[] __read_=
mostly =3D {
=20
 /* PROC stuff */
 static void *dl_seq_start(struct seq_file *s, loff_t *pos)
-	__acquires(htable->lock)
+	__acquires(htable->hlock)
 {
 	struct xt_hashlimit_htable *htable =3D s->private;
 	unsigned int *bucket;
=20
-	spin_lock_bh(&htable->lock);
+	spin_lock_bh(&htable->hlock);
 	if (*pos >=3D htable->cfg.size)
 		return NULL;
=20
@@ -874,46 +880,52 @@ static void *dl_seq_next(struct seq_file *s, void=
 *v, loff_t *pos)
 }
=20
 static void dl_seq_stop(struct seq_file *s, void *v)
-	__releases(htable->lock)
+	__releases(htable->hlock)
 {
 	struct xt_hashlimit_htable *htable =3D s->private;
 	unsigned int *bucket =3D (unsigned int *)v;
=20
 	kfree(bucket);
-	spin_unlock_bh(&htable->lock);
+	spin_unlock_bh(&htable->hlock);
 }
=20
 static int dl_seq_real_show(struct dsthash_ent *ent, u_int8_t family,
-				   struct seq_file *s)
+				   struct seq_file *s, struct xt_hashlimit_htable *htable)
 {
+	int res =3D 0;
+
+	spin_lock(&ent->lock);
 	/* recalculate to show accurate numbers */
-	rateinfo_recalc(ent, jiffies);
+	rateinfo_recalc(ent, jiffies, htable);
=20
 	switch (family) {
 	case NFPROTO_IPV4:
-		return seq_printf(s, "%ld %pI4:%u->%pI4:%u %u %u %u\n",
+		res =3D seq_printf(s, "%ld %pI4:%u->%pI4:%u %u %u %u\n",
 				 (long)(ent->expires - jiffies)/HZ,
 				 &ent->dst.ip.src,
 				 ntohs(ent->dst.src_port),
 				 &ent->dst.ip.dst,
 				 ntohs(ent->dst.dst_port),
-				 ent->rateinfo.credit, ent->rateinfo.credit_cap,
+				 ent->rateinfo.credit, htable->credit_cap,
 				 ent->rateinfo.cost);
+		break;
 #if defined(CONFIG_IP6_NF_IPTABLES) || defined(CONFIG_IP6_NF_IPTABLES_=
MODULE)
 	case NFPROTO_IPV6:
-		return seq_printf(s, "%ld %pI6:%u->%pI6:%u %u %u %u\n",
+		res =3D seq_printf(s, "%ld %pI6:%u->%pI6:%u %u %u %u\n",
 				 (long)(ent->expires - jiffies)/HZ,
 				 &ent->dst.ip6.src,
 				 ntohs(ent->dst.src_port),
 				 &ent->dst.ip6.dst,
 				 ntohs(ent->dst.dst_port),
-				 ent->rateinfo.credit, ent->rateinfo.credit_cap,
+				 ent->rateinfo.credit, htable->credit_cap,
 				 ent->rateinfo.cost);
+		break;
 #endif
 	default:
 		BUG();
-		return 0;
 	}
+	spin_unlock(&ent->lock);
+	return res;
 }
=20
 static int dl_seq_show(struct seq_file *s, void *v)
@@ -925,7 +937,7 @@ static int dl_seq_show(struct seq_file *s, void *v)
=20
 	if (!hlist_empty(&htable->hash[*bucket])) {
 		hlist_for_each_entry(ent, pos, &htable->hash[*bucket], node)
-			if (dl_seq_real_show(ent, htable->family, s))
+			if (dl_seq_real_show(ent, htable->family, s, htable))
 				return -1;
 	}
 	return 0;
@@ -1037,9 +1049,9 @@ err1:
=20
 static void __exit hashlimit_mt_exit(void)
 {
-	kmem_cache_destroy(hashlimit_cachep);
 	xt_unregister_matches(hashlimit_mt_reg, ARRAY_SIZE(hashlimit_mt_reg))=
;
 	unregister_pernet_subsys(&hashlimit_net_ops);
+	kmem_cache_destroy(hashlimit_cachep);
 }
=20
 module_init(hashlimit_mt_init);


--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
