From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [RFC PATCH]: Dynamically sized routing cache hash table.
Date: Tue, 06 Mar 2007 08:14:46 +0100
Message-ID: <45ED14E6.7090109@cosmosbay.com>
References: <20070305.202632.74752497.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, robert.olsson@its.uu.se, npiggin@suse.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:47813 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932706AbXCFHPE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Mar 2007 02:15:04 -0500
In-Reply-To: <20070305.202632.74752497.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller a =E9crit :
> This is essentially a "port" of Nick Piggin's dcache hash table
> patches to the routing cache.  It solves the locking issues
> during table grow/shrink that I couldn't handle properly last
> time I tried to code up a patch like this.
>=20
> But one of the core issues of this kind of change still remains.
> There is a conflict between the desire of routing cache garbage
> collection to reach a state of equilibrium and the hash table
> grow code's desire to match the table size to the current state
> of affairs.
>=20
> Actually, more accurately, the conflict exists in how this GC
> logic is implemented.  The core issue is that hash table size
> guides the GC processing, and hash table growth therefore
> modifies those GC goals.  So with the patch below we'll just
> keep growing the hash table instead of giving GC some time to
> try to keep the working set in equilibrium before doing the
> hash grow.
>=20
> One idea is to put the hash grow check in the garbage collector,
> and put the hash shrink check in rt_del().
>=20
> In fact, it would be a good time to perhaps hack up some entirely
> new passive GC logic for the routing cache.
>=20
> BTW, another thing that plays into this is that Robert's TRASH work
> could make this patch not necessary :-)

Well, maybe... but after looking robert's trash, I discovered its model=
 is=20
essentially a big (2^18 slots) root node (our hash table), and very few=
=20
order:1,2,3 nodes.

Almost all leaves... work in progress anyway.

Please find my comments in your patch
>=20
> Finally, I know that (due to some of Nick's helpful comments the
> other day) that I'm missing some rcu_assign_pointer()'s in here.
> Fixes in this area are most welcome.
>=20
> This patch passes basic testing on UP sparc64, but please handle
> with care :)
>=20
> Signed-off-by: David S. Miller <davem@davemloft.net>
>=20
> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> index 0b3d7bf..57e004a 100644
> --- a/net/ipv4/route.c
> +++ b/net/ipv4/route.c
> @@ -92,6 +92,9 @@
>  #include <linux/jhash.h>
>  #include <linux/rcupdate.h>
>  #include <linux/times.h>
> +#include <linux/workqueue.h>
> +#include <linux/vmalloc.h>
> +#include <linux/mutex.h>
>  #include <net/protocol.h>
>  #include <net/ip.h>
>  #include <net/route.h>
> @@ -242,28 +245,195 @@ static spinlock_t	*rt_hash_locks;
>  # define rt_hash_lock_init()
>  #endif
> =20
> -static struct rt_hash_bucket 	*rt_hash_table;
> -static unsigned			rt_hash_mask;
> -static int			rt_hash_log;
> -static unsigned int		rt_hash_rnd;
> +#define MIN_RTHASH_SHIFT 4

I wonder... are you sure this has no relation with the size of rt_hash_=
locks /=20
RT_HASH_LOCK_SZ ?
One entry must have the same lock in the two tables when resizing is in=
 flight.
#define MIN_RTHASH_SHIFT LOG2(RT_HASH_LOCK_SZ)

> +#if BITS_PER_LONG =3D=3D 32
> +#define MAX_RTHASH_SHIFT 24
> +#else
> +#define MAX_RTHASH_SHIFT 30
> +#endif
> +
> +struct rt_hash {
> +	struct rt_hash_bucket	*table;
> +	unsigned int		mask;
> +	unsigned int		log;
> +};
> +
> +struct rt_hash *rt_hash __read_mostly;
> +struct rt_hash *old_rt_hash __read_mostly;
> +static unsigned int rt_hash_rnd __read_mostly;
> +static DEFINE_SEQLOCK(resize_transfer_lock);
> +static DEFINE_MUTEX(resize_mutex);

I think a better model would be a structure, with a part containing 're=
ad=20
mostly' data, and part of 'higly modified' data with appropriate align_=
to_cache

=46or example, resize_transfer_lock should be in the first part, like r=
t_hash=20
and old_rt_hash, dont you think ?

All static data of this file should be placed on this single structure =
so that=20
we can easily avoid false sharing and have optimal placement.

> =20
>  static DEFINE_PER_CPU(struct rt_cache_stat, rt_cache_stat);
>  #define RT_CACHE_STAT_INC(field) \
>  	(__raw_get_cpu_var(rt_cache_stat).field++)
> =20
> -static int rt_intern_hash(unsigned hash, struct rtable *rth,
> -				struct rtable **res);
> +static void rt_hash_resize(unsigned int new_shift);
> +static void check_nr_rthash(void)
> +{
> +	unsigned int sz =3D rt_hash->mask + 1;
> +	unsigned int nr =3D atomic_read(&ipv4_dst_ops.entries);
> +
> +	if (unlikely(nr > (sz + (sz >> 1))))
> +		rt_hash_resize(rt_hash->log + 1);
> +	else if (unlikely(nr < (sz >> 1)))
> +		rt_hash_resize(rt_hash->log - 1);
> +}
> =20
> -static unsigned int rt_hash_code(u32 daddr, u32 saddr)
> +static struct rt_hash_bucket *rthash_alloc(unsigned int sz)
> +{
> +	struct rt_hash_bucket *n;
> +
> +	if (sz <=3D PAGE_SIZE)
> +		n =3D kmalloc(sz, GFP_KERNEL);
> +	else if (hashdist)
> +		n =3D __vmalloc(sz, GFP_KERNEL, PAGE_KERNEL);
> +	else
> +		n =3D (struct rt_hash_bucket *)
> +			__get_free_pages(GFP_KERNEL, get_order(sz));

I dont feel well with this.
Maybe we could try a __get_free_pages(), and in case of failure, fallba=
ck to=20
vmalloc(). Then keep a flag to be able to free memory correctly. Anyway=
, if=20
(get_order(sz)>=3DMAX_ORDER) we know __get_free_pages() will fail.



> +
> +	if (n)
> +		memset(n, 0, sz);
> +
> +	return n;
> +}
> +
> +static void rthash_free(struct rt_hash_bucket *r, unsigned int sz)
> +{
> +	if (sz <=3D PAGE_SIZE)
> +		kfree(r);
> +	else if (hashdist)
> +		vfree(r);
> +	else
> +		free_pages((unsigned long)r, get_order(sz));
> +}
> +
> +static unsigned int rt_hash_code(struct rt_hash *hashtable,
> +				 u32 daddr, u32 saddr)

Could you add const qualifiers to 'struct rt_hash *' in prototypes wher=
e=20
appropriate ?

>  {
>  	return (jhash_2words(daddr, saddr, rt_hash_rnd)
> -		& rt_hash_mask);
> +		& hashtable->mask);
>  }
> =20
> -#define rt_hash(daddr, saddr, idx) \
> -	rt_hash_code((__force u32)(__be32)(daddr),\
> +#define rt_hashfn(htab, daddr, saddr, idx) \
> +	rt_hash_code(htab, (__force u32)(__be32)(daddr),\
>  		     (__force u32)(__be32)(saddr) ^ ((idx) << 5))
> =20
> +static unsigned int resize_new_shift;
> +
> +static void rt_hash_resize_work(struct work_struct *work)
> +{
> +	struct rt_hash *new_hash, *old_hash;
> +	unsigned int new_size, old_size, transferred;
> +	int i;
> +
> +	if (!mutex_trylock(&resize_mutex))
> +		goto out;
> +
> +	new_hash =3D kmalloc(sizeof(struct rt_hash), GFP_KERNEL);
> +	if (!new_hash)
> +		goto out_unlock;
> +
> +	new_hash->log =3D resize_new_shift;
> +	new_size =3D 1 << new_hash->log;
> +	new_hash->mask =3D new_size - 1;
> +	new_hash->table =3D rthash_alloc(new_size*sizeof(struct hlist_head)=
);

Maybe that for small tables (less than PAGE_SIZE/2), we could embed the=
m in=20
'struct rt_hash'

> +	if (!new_hash->table)
> +		goto out_kfree;
> +
> +	old_rt_hash =3D rt_hash;
> +	/*
> +	 * ensure that if the reader sees the new dentry_hash,
> +	 * then they will also see the old_dentry_hash assignment,
> +	 * above.
> +	 */
> +	smp_wmb();
> +	rt_hash =3D new_hash;
> +	synchronize_rcu();
> +
> +	old_size =3D 1 << old_rt_hash->log;
> +	transferred =3D 0;
> +	for (i =3D 0; i < old_size; i++) {
> +		struct rtable **head =3D &old_rt_hash->table[i].chain;
> +
> +		if (!*head)
> +			continue;
> +
> +		spin_lock_bh(rt_hash_lock_addr(i));
> +		write_seqlock(&resize_transfer_lock);
> +		while (*head) {
> +			struct rtable *rth =3D *head;
> +			int iface =3D rth->fl.iif;
> +			unsigned int hash;
> +
> +			if (!iface)
> +				iface =3D rth->fl.oif;
> +
> +			*head =3D rth->u.dst.rt_next;
> +
> +			hash =3D rt_hashfn(rt_hash,
> +					 rth->fl.fl4_dst,
> +					 rth->fl.fl4_src,
> +					 iface);
> +			rth->u.dst.rt_next =3D rt_hash->table[hash].chain;
> +			rt_hash->table[hash].chain =3D rth;
> +
> +			transferred++;
> +		}
> +		write_sequnlock(&resize_transfer_lock);
> +		spin_unlock_bh(rt_hash_lock_addr(i));
> +	}
> +
> +	printk("resize route hash from %u to %u, moved %u entries\n",
> +	       old_size, new_size, transferred);
> +
> +	old_hash =3D old_rt_hash;
> +	old_rt_hash =3D NULL;
> +	mutex_unlock(&resize_mutex);
> +	synchronize_rcu();
> +	rthash_free(old_hash->table, old_size * sizeof(struct rt_hash_bucke=
t));
> +	kfree(old_hash);
> +
> +	resize_new_shift =3D 0;
> +	return;
> +
> +out_kfree:
> +	kfree(new_hash);
> +out_unlock:
> +	mutex_unlock(&resize_mutex);
> +out:
> +	resize_new_shift =3D 0;
> +	return;
> +}
> +
> +static DEFINE_SPINLOCK(resize_lock);

Could we group all static vars at the begining of this file, so that we=
=20
clearly see where we should place them, to avoid false sharing.

> +
> +static void rt_hash_resize(unsigned int new_shift)
> +{
> +	static DECLARE_WORK(resize_work, rt_hash_resize_work);
> +
> +	if (new_shift < MIN_RTHASH_SHIFT ||
> +	    new_shift > MAX_RTHASH_SHIFT)
> +		return;
> +
> +	if (resize_new_shift)
> +		return;
> +	spin_lock(&resize_lock);
> +	if (resize_new_shift) {
> +		spin_unlock(&resize_lock);
> +		return;
> +	}
> +	resize_new_shift =3D new_shift;
> +	spin_unlock(&resize_lock);
> +
> +	printk("rt_hash_resize: new_shift=3D%u\n", new_shift);
> +
> +	schedule_work(&resize_work);
> +}
> +
> +static int rt_intern_hash(struct rt_hash *h, unsigned int hash,
> +			  struct rtable *rth, struct rtable **res);
> +
>  #ifdef CONFIG_PROC_FS
>  struct rt_cache_iter_state {
>  	int bucket;
> @@ -274,9 +444,9 @@ static struct rtable *rt_cache_get_first(struct s=
eq_file *seq)
>  	struct rtable *r =3D NULL;
>  	struct rt_cache_iter_state *st =3D seq->private;
> =20
> -	for (st->bucket =3D rt_hash_mask; st->bucket >=3D 0; --st->bucket) =
{
> +	for (st->bucket =3D rt_hash->mask; st->bucket >=3D 0; --st->bucket)=
 {
>  		rcu_read_lock_bh();
> -		r =3D rt_hash_table[st->bucket].chain;
> +		r =3D rt_hash->table[st->bucket].chain;
>  		if (r)
>  			break;
>  		rcu_read_unlock_bh();
> @@ -294,7 +464,7 @@ static struct rtable *rt_cache_get_next(struct se=
q_file *seq, struct rtable *r)
>  		if (--st->bucket < 0)
>  			break;
>  		rcu_read_lock_bh();
> -		r =3D rt_hash_table[st->bucket].chain;
> +		r =3D rt_hash->table[st->bucket].chain;
>  	}
>  	return r;
>  }
> @@ -629,16 +799,16 @@ static void rt_check_expire(unsigned long dummy=
)
>  	unsigned long now =3D jiffies;
>  	u64 mult;
> =20
> -	mult =3D ((u64)ip_rt_gc_interval) << rt_hash_log;
> +	mult =3D ((u64)ip_rt_gc_interval) << rt_hash->log;
>  	if (ip_rt_gc_timeout > 1)
>  		do_div(mult, ip_rt_gc_timeout);
>  	goal =3D (unsigned int)mult;
> -	if (goal > rt_hash_mask) goal =3D rt_hash_mask + 1;
> +	if (goal > rt_hash->mask) goal =3D rt_hash->mask + 1;
>  	for (; goal > 0; goal--) {
>  		unsigned long tmo =3D ip_rt_gc_timeout;
> =20
> -		i =3D (i + 1) & rt_hash_mask;
> -		rthp =3D &rt_hash_table[i].chain;
> +		i =3D (i + 1) & rt_hash->mask;
> +		rthp =3D &rt_hash->table[i].chain;
> =20
>  		if (*rthp =3D=3D 0)
>  			continue;
> @@ -662,7 +832,7 @@ static void rt_check_expire(unsigned long dummy)
>  			/* remove all related balanced entries if necessary */
>  			if (rth->u.dst.flags & DST_BALANCED) {
>  				rthp =3D rt_remove_balanced_route(
> -					&rt_hash_table[i].chain,
> +					&rt_hash->table[i].chain,
>  					rth, NULL);
>  				if (!rthp)
>  					break;
> @@ -697,11 +867,11 @@ static void rt_run_flush(unsigned long dummy)
> =20
>  	get_random_bytes(&rt_hash_rnd, 4);
> =20
> -	for (i =3D rt_hash_mask; i >=3D 0; i--) {
> +	for (i =3D rt_hash->mask; i >=3D 0; i--) {
>  		spin_lock_bh(rt_hash_lock_addr(i));
> -		rth =3D rt_hash_table[i].chain;
> +		rth =3D rt_hash->table[i].chain;
>  		if (rth)
> -			rt_hash_table[i].chain =3D NULL;
> +			rt_hash->table[i].chain =3D NULL;
>  		spin_unlock_bh(rt_hash_lock_addr(i));
> =20
>  		for (; rth; rth =3D next) {
> @@ -709,6 +879,7 @@ static void rt_run_flush(unsigned long dummy)
>  			rt_free(rth);
>  		}
>  	}
> +	check_nr_rthash();
>  }
> =20
>  static DEFINE_SPINLOCK(rt_flush_lock);
> @@ -802,20 +973,20 @@ static int rt_garbage_collect(void)
> =20
>  	/* Calculate number of entries, which we want to expire now. */
>  	goal =3D atomic_read(&ipv4_dst_ops.entries) -
> -		(ip_rt_gc_elasticity << rt_hash_log);
> +		(ip_rt_gc_elasticity << rt_hash->log);
>  	if (goal <=3D 0) {
>  		if (equilibrium < ipv4_dst_ops.gc_thresh)
>  			equilibrium =3D ipv4_dst_ops.gc_thresh;
>  		goal =3D atomic_read(&ipv4_dst_ops.entries) - equilibrium;
>  		if (goal > 0) {
> -			equilibrium +=3D min_t(unsigned int, goal / 2, rt_hash_mask + 1);
> +			equilibrium +=3D min_t(unsigned int, goal / 2, rt_hash->mask + 1)=
;
>  			goal =3D atomic_read(&ipv4_dst_ops.entries) - equilibrium;
>  		}
>  	} else {
>  		/* We are in dangerous area. Try to reduce cache really
>  		 * aggressively.
>  		 */
> -		goal =3D max_t(unsigned int, goal / 2, rt_hash_mask + 1);
> +		goal =3D max_t(unsigned int, goal / 2, rt_hash->mask + 1);
>  		equilibrium =3D atomic_read(&ipv4_dst_ops.entries) - goal;
>  	}
> =20
> @@ -830,11 +1001,11 @@ static int rt_garbage_collect(void)
>  	do {
>  		int i, k;
> =20
> -		for (i =3D rt_hash_mask, k =3D rover; i >=3D 0; i--) {
> +		for (i =3D rt_hash->mask, k =3D rover; i >=3D 0; i--) {
>  			unsigned long tmo =3D expire;
> =20
> -			k =3D (k + 1) & rt_hash_mask;
> -			rthp =3D &rt_hash_table[k].chain;
> +			k =3D (k + 1) & rt_hash->mask;
> +			rthp =3D &rt_hash->table[k].chain;
>  			spin_lock_bh(rt_hash_lock_addr(k));
>  			while ((rth =3D *rthp) !=3D NULL) {
>  				if (!rt_may_expire(rth, tmo, expire)) {
> @@ -850,7 +1021,7 @@ static int rt_garbage_collect(void)
>  					int r;
> =20
>  					rthp =3D rt_remove_balanced_route(
> -						&rt_hash_table[k].chain,
> +						&rt_hash->table[k].chain,
>  						rth,
>  						&r);
>  					goal -=3D r;
> @@ -919,7 +1090,8 @@ work_done:
>  out:	return 0;
>  }
> =20
> -static int rt_intern_hash(unsigned hash, struct rtable *rt, struct r=
table **rp)
> +static int rt_intern_hash(struct rt_hash *h, unsigned hash,
> +			  struct rtable *rt, struct rtable **rp)
>  {
>  	struct rtable	*rth, **rthp;
>  	unsigned long	now;
> @@ -935,7 +1107,7 @@ restart:
>  	candp =3D NULL;
>  	now =3D jiffies;
> =20
> -	rthp =3D &rt_hash_table[hash].chain;
> +	rthp =3D &h->table[hash].chain;
> =20
>  	spin_lock_bh(rt_hash_lock_addr(hash));
>  	while ((rth =3D *rthp) !=3D NULL) {
> @@ -953,12 +1125,12 @@ restart:
>  			 * the insertion at the start of the hash chain.
>  			 */
>  			rcu_assign_pointer(rth->u.dst.rt_next,
> -					   rt_hash_table[hash].chain);
> +					   h->table[hash].chain);
>  			/*
>  			 * Since lookup is lockfree, the update writes
>  			 * must be ordered for consistency on SMP.
>  			 */
> -			rcu_assign_pointer(rt_hash_table[hash].chain, rth);
> +			rcu_assign_pointer(h->table[hash].chain, rth);
> =20
>  			rth->u.dst.__use++;
>  			dst_hold(&rth->u.dst);
> @@ -1033,7 +1205,7 @@ restart:
>  		}
>  	}
> =20
> -	rt->u.dst.rt_next =3D rt_hash_table[hash].chain;
> +	rt->u.dst.rt_next =3D h->table[hash].chain;
>  #if RT_CACHE_DEBUG >=3D 2
>  	if (rt->u.dst.rt_next) {
>  		struct rtable *trt;
> @@ -1044,9 +1216,10 @@ restart:
>  		printk("\n");
>  	}
>  #endif
> -	rt_hash_table[hash].chain =3D rt;
> +	h->table[hash].chain =3D rt;
>  	spin_unlock_bh(rt_hash_lock_addr(hash));
>  	*rp =3D rt;
> +	check_nr_rthash();
>  	return 0;
>  }
> =20
> @@ -1109,13 +1282,13 @@ void __ip_select_ident(struct iphdr *iph, str=
uct dst_entry *dst, int more)
>  	ip_select_fb_ident(iph);
>  }
> =20
> -static void rt_del(unsigned hash, struct rtable *rt)
> +static void rt_del(struct rt_hash *h, unsigned hash, struct rtable *=
rt)
>  {
>  	struct rtable **rthp;
> =20
>  	spin_lock_bh(rt_hash_lock_addr(hash));
>  	ip_rt_put(rt);
> -	for (rthp =3D &rt_hash_table[hash].chain; *rthp;
> +	for (rthp =3D &h->table[hash].chain; *rthp;
>  	     rthp =3D &(*rthp)->u.dst.rt_next)
>  		if (*rthp =3D=3D rt) {
>  			*rthp =3D rt->u.dst.rt_next;
> @@ -1123,6 +1296,7 @@ static void rt_del(unsigned hash, struct rtable=
 *rt)
>  			break;
>  		}
>  	spin_unlock_bh(rt_hash_lock_addr(hash));
> +	check_nr_rthash();
>  }
> =20
>  void ip_rt_redirect(__be32 old_gw, __be32 daddr, __be32 new_gw,
> @@ -1154,9 +1328,10 @@ void ip_rt_redirect(__be32 old_gw, __be32 dadd=
r, __be32 new_gw,
> =20
>  	for (i =3D 0; i < 2; i++) {
>  		for (k =3D 0; k < 2; k++) {
> -			unsigned hash =3D rt_hash(daddr, skeys[i], ikeys[k]);
> +			struct rt_hash *h =3D rt_hash;
> +			unsigned hash =3D rt_hashfn(h, daddr, skeys[i], ikeys[k]);
> =20
> -			rthp=3D&rt_hash_table[hash].chain;
> +			rthp=3D&h->table[hash].chain;
> =20
>  			rcu_read_lock();
>  			while ((rth =3D rcu_dereference(*rthp)) !=3D NULL) {
> @@ -1230,8 +1405,8 @@ void ip_rt_redirect(__be32 old_gw, __be32 daddr=
, __be32 new_gw,
>  				call_netevent_notifiers(NETEVENT_REDIRECT,
>  							&netevent);
> =20
> -				rt_del(hash, rth);
> -				if (!rt_intern_hash(hash, rt, &rt))
> +				rt_del(h, hash, rth);
> +				if (!rt_intern_hash(h, hash, rt, &rt))
>  					ip_rt_put(rt);
>  				goto do_next;
>  			}
> @@ -1266,14 +1441,15 @@ static struct dst_entry *ipv4_negative_advice=
(struct dst_entry *dst)
>  			ret =3D NULL;
>  		} else if ((rt->rt_flags & RTCF_REDIRECTED) ||
>  			   rt->u.dst.expires) {
> -			unsigned hash =3D rt_hash(rt->fl.fl4_dst, rt->fl.fl4_src,
> -						rt->fl.oif);
> +			struct rt_hash *h =3D rt_hash;
> +			unsigned hash =3D rt_hashfn(h, rt->fl.fl4_dst,
> +						  rt->fl.fl4_src, rt->fl.oif);
>  #if RT_CACHE_DEBUG >=3D 1
>  			printk(KERN_DEBUG "ip_rt_advice: redirect to "
>  					  "%u.%u.%u.%u/%02x dropped\n",
>  				NIPQUAD(rt->rt_dst), rt->fl.fl4_tos);
>  #endif
> -			rt_del(hash, rt);
> +			rt_del(h, hash, rt);
>  			ret =3D NULL;
>  		}
>  	}
> @@ -1411,10 +1587,11 @@ unsigned short ip_rt_frag_needed(struct iphdr=
 *iph, unsigned short new_mtu)
>  		return 0;
> =20
>  	for (i =3D 0; i < 2; i++) {
> -		unsigned hash =3D rt_hash(daddr, skeys[i], 0);
> +		struct rt_hash *h =3D rt_hash;
> +		unsigned hash =3D rt_hashfn(h, daddr, skeys[i], 0);
> =20
>  		rcu_read_lock();
> -		for (rth =3D rcu_dereference(rt_hash_table[hash].chain); rth;
> +		for (rth =3D rcu_dereference(h->table[hash].chain); rth;
>  		     rth =3D rcu_dereference(rth->u.dst.rt_next)) {
>  			if (rth->fl.fl4_dst =3D=3D daddr &&
>  			    rth->fl.fl4_src =3D=3D skeys[i] &&
> @@ -1669,8 +1846,8 @@ static int ip_route_input_mc(struct sk_buff *sk=
b, __be32 daddr, __be32 saddr,
>  	RT_CACHE_STAT_INC(in_slow_mc);
> =20
>  	in_dev_put(in_dev);
> -	hash =3D rt_hash(daddr, saddr, dev->ifindex);
> -	return rt_intern_hash(hash, rth, (struct rtable**) &skb->dst);
> +	hash =3D rt_hashfn(rt_hash, daddr, saddr, dev->ifindex);
> +	return rt_intern_hash(rt_hash, hash, rth, (struct rtable**) &skb->d=
st);
> =20
>  e_nobufs:
>  	in_dev_put(in_dev);
> @@ -1833,8 +2010,8 @@ static inline int ip_mkroute_input_def(struct s=
k_buff *skb,
>  		return err;
> =20
>  	/* put it into the cache */
> -	hash =3D rt_hash(daddr, saddr, fl->iif);
> -	return rt_intern_hash(hash, rth, (struct rtable**)&skb->dst);
> +	hash =3D rt_hashfn(rt_hash, daddr, saddr, fl->iif);
> +	return rt_intern_hash(rt_hash, hash, rth, (struct rtable**)&skb->ds=
t);
>  }
> =20
>  static inline int ip_mkroute_input(struct sk_buff *skb,
> @@ -1874,8 +2051,8 @@ static inline int ip_mkroute_input(struct sk_bu=
ff *skb,
>  			return err;
> =20
>  		/* put it into the cache */
> -		hash =3D rt_hash(daddr, saddr, fl->iif);
> -		err =3D rt_intern_hash(hash, rth, &rtres);
> +		hash =3D rt_hashfn(rt_hash, daddr, saddr, fl->iif);
> +		err =3D rt_intern_hash(rt_hash, hash, rth, &rtres);
>  		if (err)
>  			return err;
> =20
> @@ -2047,8 +2224,8 @@ local_input:
>  		rth->rt_flags 	&=3D ~RTCF_LOCAL;
>  	}
>  	rth->rt_type	=3D res.type;
> -	hash =3D rt_hash(daddr, saddr, fl.iif);
> -	err =3D rt_intern_hash(hash, rth, (struct rtable**)&skb->dst);
> +	hash =3D rt_hashfn(rt_hash, daddr, saddr, fl.iif);
> +	err =3D rt_intern_hash(rt_hash, hash, rth, (struct rtable**)&skb->d=
st);
>  	goto done;
> =20
>  no_route:
> @@ -2086,18 +2263,13 @@ martian_source:
>  	goto e_inval;
>  }
> =20
> -int ip_route_input(struct sk_buff *skb, __be32 daddr, __be32 saddr,
> -		   u8 tos, struct net_device *dev)
> +static int __input_find(struct rt_hash *h, struct sk_buff *skb,
> +			__be32 daddr, __be32 saddr, u8 tos, int iif)
>  {
> -	struct rtable * rth;
> -	unsigned	hash;
> -	int iif =3D dev->ifindex;
> -
> -	tos &=3D IPTOS_RT_MASK;
> -	hash =3D rt_hash(daddr, saddr, iif);
> +	unsigned int hash =3D rt_hashfn(h, daddr, saddr, iif);
> +	struct rtable *rth;
> =20
> -	rcu_read_lock();
> -	for (rth =3D rcu_dereference(rt_hash_table[hash].chain); rth;
> +	for (rth =3D rcu_dereference(h->table[hash].chain); rth;
>  	     rth =3D rcu_dereference(rth->u.dst.rt_next)) {
>  		if (rth->fl.fl4_dst =3D=3D daddr &&
>  		    rth->fl.fl4_src =3D=3D saddr &&
> @@ -2109,14 +2281,50 @@ int ip_route_input(struct sk_buff *skb, __be3=
2 daddr, __be32 saddr,
>  			dst_hold(&rth->u.dst);
>  			rth->u.dst.__use++;
>  			RT_CACHE_STAT_INC(in_hit);
> -			rcu_read_unlock();
>  			skb->dst =3D (struct dst_entry*)rth;
>  			return 0;
>  		}
>  		RT_CACHE_STAT_INC(in_hlist_search);
>  	}
> +
> +	return 1;
> +}
> +
> +int ip_route_input(struct sk_buff *skb, __be32 daddr, __be32 saddr,
> +		   u8 tos, struct net_device *dev)
> +{
> +	struct rt_hash *htab, *old_htab;
> +	int iif =3D dev->ifindex;
> +	int ret;
> +
> +	tos &=3D IPTOS_RT_MASK;
> +
> +	rcu_read_lock();
> +	htab =3D rt_hash;
> +	smp_rmb();
> +	old_htab =3D old_rt_hash;
> +	if (unlikely(old_htab)) {
> +		unsigned long seq;
> +		do {
> +			seq =3D read_seqbegin(&resize_transfer_lock);
> +			ret =3D __input_find(old_htab, skb, daddr,
> +					   saddr, tos, iif);
> +			if (!ret)
> +				goto out_rcu;
> +			ret =3D __input_find(htab, skb, daddr,
> +					   saddr, tos, iif);
> +			if (!ret)
> +				goto out_rcu;
> +		} while (read_seqretry(&resize_transfer_lock, seq));
> +	} else {
> +		ret =3D __input_find(htab, skb, daddr, saddr, tos, iif);
> +	}
> +out_rcu:
>  	rcu_read_unlock();
> =20
> +	if (!ret)
> +		return ret;
> +
>  	/* Multicast recognition logic is moved from route cache to here.
>  	   The problem was that too many Ethernet cards have broken/missing
>  	   hardware multicast filters :-( As result the host on multicastin=
g
> @@ -2288,8 +2496,9 @@ static inline int ip_mkroute_output_def(struct =
rtable **rp,
>  	int err =3D __mkroute_output(&rth, res, fl, oldflp, dev_out, flags)=
;
>  	unsigned hash;
>  	if (err =3D=3D 0) {
> -		hash =3D rt_hash(oldflp->fl4_dst, oldflp->fl4_src, oldflp->oif);
> -		err =3D rt_intern_hash(hash, rth, rp);
> +		hash =3D rt_hashfn(rt_hash,
> +				 oldflp->fl4_dst, oldflp->fl4_src, oldflp->oif);
> +		err =3D rt_intern_hash(rt_hash, hash, rth, rp);
>  	}
> =20
>  	return err;
> @@ -2330,9 +2539,9 @@ static inline int ip_mkroute_output(struct rtab=
le** rp,
>  			if (err !=3D 0)
>  				goto cleanup;
> =20
> -			hash =3D rt_hash(oldflp->fl4_dst, oldflp->fl4_src,
> -					oldflp->oif);
> -			err =3D rt_intern_hash(hash, rth, rp);
> +			hash =3D rt_hashfn(rt_hash, oldflp->fl4_dst,
> +					 oldflp->fl4_src,	oldflp->oif);
> +			err =3D rt_intern_hash(rt_hash, hash, rth, rp);
> =20
>  			/* forward hop information to multipath impl. */
>  			multipath_set_nhinfo(rth,
> @@ -2553,15 +2762,13 @@ make_route:
>  out:	return err;
>  }
> =20
> -int __ip_route_output_key(struct rtable **rp, const struct flowi *fl=
p)
> +static int __output_find(struct rt_hash *h, struct rtable **rp,
> +			 const struct flowi *flp)
>  {
> -	unsigned hash;
> +	unsigned int hash =3D rt_hashfn(h, flp->fl4_dst, flp->fl4_src, flp-=
>oif);
>  	struct rtable *rth;
> =20
> -	hash =3D rt_hash(flp->fl4_dst, flp->fl4_src, flp->oif);
> -
> -	rcu_read_lock_bh();
> -	for (rth =3D rcu_dereference(rt_hash_table[hash].chain); rth;
> +	for (rth =3D rcu_dereference(h->table[hash].chain); rth;
>  		rth =3D rcu_dereference(rth->u.dst.rt_next)) {
>  		if (rth->fl.fl4_dst =3D=3D flp->fl4_dst &&
>  		    rth->fl.fl4_src =3D=3D flp->fl4_src &&
> @@ -2577,7 +2784,6 @@ int __ip_route_output_key(struct rtable **rp, c=
onst struct flowi *flp)
>  			if (multipath_select_route(flp, rth, rp)) {
>  				dst_hold(&(*rp)->u.dst);
>  				RT_CACHE_STAT_INC(out_hit);
> -				rcu_read_unlock_bh();
>  				return 0;
>  			}
> =20
> @@ -2585,14 +2791,44 @@ int __ip_route_output_key(struct rtable **rp,=
 const struct flowi *flp)
>  			dst_hold(&rth->u.dst);
>  			rth->u.dst.__use++;
>  			RT_CACHE_STAT_INC(out_hit);
> -			rcu_read_unlock_bh();
>  			*rp =3D rth;
>  			return 0;
>  		}
>  		RT_CACHE_STAT_INC(out_hlist_search);
>  	}
> +
> +	return 1;
> +}
> +
> +int __ip_route_output_key(struct rtable **rp, const struct flowi *fl=
p)
> +{
> +	struct rt_hash *htab, *old_htab;
> +	int ret;
> +
> +	rcu_read_lock_bh();
> +	htab =3D rt_hash;
> +	smp_rmb();
> +	old_htab =3D old_rt_hash;
> +	if (unlikely(old_htab)) {
> +		unsigned long seq;
> +		do {
> +			seq =3D read_seqbegin(&resize_transfer_lock);
> +			ret =3D __output_find(old_htab, rp, flp);
> +			if (!ret)
> +				goto out_rcu;
> +			ret =3D __output_find(htab, rp, flp);
> +			if (!ret)
> +				goto out_rcu;
> +		} while (read_seqretry(&resize_transfer_lock, seq));
> +	} else {
> +		ret =3D __output_find(htab, rp, flp);
> +	}
> +out_rcu:
>  	rcu_read_unlock_bh();
> =20
> +	if (!ret)
> +		return 0;
> +
>  	return ip_route_output_slow(rp, flp);
>  }
> =20
> @@ -2810,20 +3046,21 @@ errout_free:
>  	goto errout;
>  }
> =20
> -int ip_rt_dump(struct sk_buff *skb,  struct netlink_callback *cb)
> +int ip_rt_dump(struct sk_buff *skb, struct netlink_callback *cb)
>  {
> +	struct rt_hash *htab =3D rt_hash;
>  	struct rtable *rt;
>  	int h, s_h;
>  	int idx, s_idx;
> =20
>  	s_h =3D cb->args[0];
>  	s_idx =3D idx =3D cb->args[1];
> -	for (h =3D 0; h <=3D rt_hash_mask; h++) {
> +	for (h =3D 0; h <=3D htab->mask; h++) {
>  		if (h < s_h) continue;
>  		if (h > s_h)
>  			s_idx =3D 0;
>  		rcu_read_lock_bh();
> -		for (rt =3D rcu_dereference(rt_hash_table[h].chain), idx =3D 0; rt=
;
> +		for (rt =3D rcu_dereference(htab->table[h].chain), idx =3D 0; rt;
>  		     rt =3D rcu_dereference(rt->u.dst.rt_next), idx++) {
>  			if (idx < s_idx)
>  				continue;
> @@ -3116,6 +3353,7 @@ __setup("rhash_entries=3D", set_rhash_entries);
> =20
>  int __init ip_rt_init(void)
>  {
> +	unsigned int hash_size;
>  	int rc =3D 0;
> =20
>  	rt_hash_rnd =3D (int) ((num_physpages ^ (num_physpages>>8)) ^
> @@ -3138,21 +3376,21 @@ int __init ip_rt_init(void)
>  		kmem_cache_create("ip_dst_cache", sizeof(struct rtable), 0,
>  				  SLAB_HWCACHE_ALIGN|SLAB_PANIC, NULL, NULL);
> =20
> -	rt_hash_table =3D (struct rt_hash_bucket *)
> -		alloc_large_system_hash("IP route cache",
> -					sizeof(struct rt_hash_bucket),
> -					rhash_entries,
> -					(num_physpages >=3D 128 * 1024) ?
> -					15 : 17,
> -					0,
> -					&rt_hash_log,
> -					&rt_hash_mask,
> -					0);
> -	memset(rt_hash_table, 0, (rt_hash_mask + 1) * sizeof(struct rt_hash=
_bucket));
> +	rt_hash =3D kmalloc(sizeof(struct rt_hash), GFP_ATOMIC);
> +	if (!rt_hash)
> +		panic("Failed to allocate rt_hash\n");
> +	rt_hash->log =3D MIN_RTHASH_SHIFT;
> +	hash_size =3D 1 << rt_hash->log;
> +	rt_hash->mask =3D hash_size - 1;
> +	rt_hash->table =3D rthash_alloc(hash_size *
> +				      sizeof(struct rt_hash_bucket));
> +	if (!rt_hash->table)
> +		panic("Failed to allocate rt_hash->table\n");
> +
>  	rt_hash_lock_init();
> =20
> -	ipv4_dst_ops.gc_thresh =3D (rt_hash_mask + 1);
> -	ip_rt_max_size =3D (rt_hash_mask + 1) * 16;
> +	ipv4_dst_ops.gc_thresh =3D (rt_hash->mask + 1);
> +	ip_rt_max_size =3D (rt_hash->mask + 1) * 16;
> =20
>  	devinet_init();
>  	ip_fib_init();
>=20
>=20

