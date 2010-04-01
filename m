From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH nf-next-2.6] xt_hashlimit: RCU conversion
Date: Thu, 01 Apr 2010 14:10:04 +0200
Message-ID: <1270123804.2229.91.camel@edumazet-laptop>
References: <4BA74950.6000305@infopact.nl> <4BA7A5D8.5080101@trash.net>
	 <4BA8DAC5.6050002@infopact.nl> <1269364893.2983.296.camel@edumazet-laptop>
	 <4BAA2DC5.7000409@infopact.nl>  <1269447674.3213.64.camel@edumazet-laptop>
	 <1269509574.3626.9.camel@edumazet-laptop>  <4BAB3C8B.3030104@trash.net>
	 <1269514928.3626.13.camel@edumazet-laptop>
	 <1270038210.2103.23.camel@edumazet-laptop>  <4BB47D81.3060400@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jorrit Kronjee <j.kronjee@infopact.nl>,
	netfilter-devel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:44084 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755249Ab0DAMKK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Apr 2010 08:10:10 -0400
In-Reply-To: <4BB47D81.3060400@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 01 avril 2010 =C3=A0 13:03 +0200, Patrick McHardy a =C3=A9crit=
 :
> Eric Dumazet wrote:
> > xt_hashlimit uses a central lock per hash table and suffers from
> > contention on some workloads. (Multiqueue NIC or if RPS is enabled)
> >=20
> > After RCU conversion, central lock is only used when a writer wants=
 to
> > add or delete an entry.
> >=20
> > For 'readers', updating an existing entry, they use an individual l=
ock
> > per entry.
>=20
> Looks good to me, thanks Eric.
>=20
> > -/* allocate dsthash_ent, initialize dst, put in htable and lock it=
 */
> > -static struct dsthash_ent *
> > -dsthash_alloc_init(struct xt_hashlimit_htable *ht,
> > -		   const struct dsthash_dst *dst)
>=20
> Is there a reason for moving this function downwards in the file?
> That unnecessarily increases the diff and makes the patch harder to
> review. For review purposes I moved it back up, resulting in 42
> lines less diff.
> --

Well, this is because I had to move inside this function various
initializations and these inits use user2credits() which was defined
after dsthash_alloc_init().

But we can avoid this since we hold the entry spinlock, and before hash
insertion.

Only the lookup fields and the spinlock MUST be committed to memory
before the insert. Other fields can be initialized later by caller.

Here is V2 of patch, I added locking as well in dl_seq_real_show()
because we call rateinfo_recalc(). htable main lock doesnt anymore
protects each entry rateinfo.

Thanks

[PATCH nf-next-2.6] xt_hashlimit: RCU conversion

xt_hashlimit uses a central lock per hash table and suffers from
contention on some workloads. (Multiqueue NIC or if RPS is enabled)

After RCU conversion, central lock is only used when a writer wants to
add or delete an entry.

=46or 'readers', updating an existing entry, they use an individual loc=
k
per entry.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---

diff --git a/net/netfilter/xt_hashlimit.c b/net/netfilter/xt_hashlimit.=
c
index 5470bb0..453178d 100644
--- a/net/netfilter/xt_hashlimit.c
+++ b/net/netfilter/xt_hashlimit.c
@@ -81,12 +81,14 @@ struct dsthash_ent {
 	struct dsthash_dst dst;
=20
 	/* modified structure members in the end */
+	spinlock_t lock;
 	unsigned long expires;		/* precalculated expiry time */
 	struct {
 		unsigned long prev;	/* last modification */
 		u_int32_t credit;
 		u_int32_t credit_cap, cost;
 	} rateinfo;
+	struct rcu_head rcu;
 };
=20
 struct xt_hashlimit_htable {
@@ -143,9 +145,11 @@ dsthash_find(const struct xt_hashlimit_htable *ht,
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
@@ -157,9 +161,10 @@ dsthash_alloc_init(struct xt_hashlimit_htable *ht,
 {
 	struct dsthash_ent *ent;
=20
+	spin_lock(&ht->lock);
 	/* initialize hash with random val at the time we allocate
 	 * the first hashtable entry */
-	if (!ht->rnd_initialized) {
+	if (unlikely(!ht->rnd_initialized)) {
 		get_random_bytes(&ht->rnd, sizeof(ht->rnd));
 		ht->rnd_initialized =3D true;
 	}
@@ -168,27 +173,36 @@ dsthash_alloc_init(struct xt_hashlimit_htable *ht=
,
 		/* FIXME: do something. question is what.. */
 		if (net_ratelimit())
 			pr_err("max count of %u reached\n", ht->cfg.max);
-		return NULL;
-	}
-
-	ent =3D kmem_cache_alloc(hashlimit_cachep, GFP_ATOMIC);
+		ent =3D NULL;
+	} else
+		ent =3D kmem_cache_alloc(hashlimit_cachep, GFP_ATOMIC);
 	if (!ent) {
 		if (net_ratelimit())
 			pr_err("cannot allocate dsthash_ent\n");
-		return NULL;
-	}
-	memcpy(&ent->dst, dst, sizeof(ent->dst));
+	} else {
+		memcpy(&ent->dst, dst, sizeof(ent->dst));
+		spin_lock_init(&ent->lock);
=20
-	hlist_add_head(&ent->node, &ht->hash[hash_dst(ht, dst)]);
-	ht->count++;
+		spin_lock(&ent->lock);
+		hlist_add_head_rcu(&ent->node, &ht->hash[hash_dst(ht, dst)]);
+		ht->count++;
+	}
+	spin_unlock(&ht->lock);
 	return ent;
 }
=20
+static void dsthash_free_rcu(struct rcu_head *head)
+{
+	struct dsthash_ent *ent =3D container_of(head, struct dsthash_ent, rc=
u);
+
+	kmem_cache_free(hashlimit_cachep, ent);
+}
+
 static inline void
 dsthash_free(struct xt_hashlimit_htable *ht, struct dsthash_ent *ent)
 {
-	hlist_del(&ent->node);
-	kmem_cache_free(hashlimit_cachep, ent);
+	hlist_del_rcu(&ent->node);
+	call_rcu_bh(&ent->rcu, dsthash_free_rcu);
 	ht->count--;
 }
 static void htable_gc(unsigned long htlong);
@@ -512,15 +526,14 @@ hashlimit_mt(const struct sk_buff *skb, const str=
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
-
 		dh->expires =3D jiffies + msecs_to_jiffies(hinfo->cfg.expire);
 		dh->rateinfo.prev =3D jiffies;
 		dh->rateinfo.credit =3D user2credits(hinfo->cfg.avg *
@@ -537,11 +550,13 @@ hashlimit_mt(const struct sk_buff *skb, const str=
uct xt_match_param *par)
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
@@ -666,12 +681,15 @@ static void dl_seq_stop(struct seq_file *s, void =
*v)
 static int dl_seq_real_show(struct dsthash_ent *ent, u_int8_t family,
 				   struct seq_file *s)
 {
+	int res;
+
+	spin_lock(&ent->lock);
 	/* recalculate to show accurate numbers */
 	rateinfo_recalc(ent, jiffies);
=20
 	switch (family) {
 	case NFPROTO_IPV4:
-		return seq_printf(s, "%ld %pI4:%u->%pI4:%u %u %u %u\n",
+		res =3D seq_printf(s, "%ld %pI4:%u->%pI4:%u %u %u %u\n",
 				 (long)(ent->expires - jiffies)/HZ,
 				 &ent->dst.ip.src,
 				 ntohs(ent->dst.src_port),
@@ -679,9 +697,10 @@ static int dl_seq_real_show(struct dsthash_ent *en=
t, u_int8_t family,
 				 ntohs(ent->dst.dst_port),
 				 ent->rateinfo.credit, ent->rateinfo.credit_cap,
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
@@ -689,11 +708,14 @@ static int dl_seq_real_show(struct dsthash_ent *e=
nt, u_int8_t family,
 				 ntohs(ent->dst.dst_port),
 				 ent->rateinfo.credit, ent->rateinfo.credit_cap,
 				 ent->rateinfo.cost);
+		break;
 #endif
 	default:
 		BUG();
-		return 0;
+		res =3D 0;
 	}
+	spin_unlock(&ent->lock);
+	return res;
 }
=20
 static int dl_seq_show(struct seq_file *s, void *v)
@@ -817,9 +839,11 @@ err1:
=20
 static void __exit hashlimit_mt_exit(void)
 {
-	kmem_cache_destroy(hashlimit_cachep);
 	xt_unregister_matches(hashlimit_mt_reg, ARRAY_SIZE(hashlimit_mt_reg))=
;
 	unregister_pernet_subsys(&hashlimit_net_ops);
+
+	rcu_barrier_bh();
+	kmem_cache_destroy(hashlimit_cachep);
 }
=20
 module_init(hashlimit_mt_init);


