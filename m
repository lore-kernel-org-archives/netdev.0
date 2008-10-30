From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH 2/2] udp: RCU handling for Unicast packets.
Date: Thu, 30 Oct 2008 11:25:13 -0700
Message-ID: <20081030182513.GA6469@linux.vnet.ibm.com>
References: <49088288.6050805@acm.org> <49088AD1.7040805@cosmosbay.com> <20081029163739.GB6732@linux.vnet.ibm.com> <49089BE5.3090705@acm.org> <4908A134.4040705@cosmosbay.com> <4908AB3F.1060003@acm.org> <20081029185200.GE6732@linux.vnet.ibm.com> <4908C0CD.5050406@cosmosbay.com> <1225364660.7803.61.camel@twins> <49099ACC.3070600@cosmosbay.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Corey Minyard <minyard@acm.org>,
	David Miller <davem@davemloft.net>, shemminger@vyatta.com,
	benny+usenet@amorsen.dk, netdev@vger.kernel.org,
	Christoph Lameter <cl@linux-foundation.org>,
	johnpol@2ka.mipt.ru, Christian Bell <christian@myri.com>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:52156 "EHLO e1.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752503AbYJaCoV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Oct 2008 22:44:21 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e1.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m9V2iIxO020618
	for <netdev@vger.kernel.org>; Thu, 30 Oct 2008 22:44:18 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m9V2iIjV122558
	for <netdev@vger.kernel.org>; Thu, 30 Oct 2008 22:44:18 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m9V2iGrN022920
	for <netdev@vger.kernel.org>; Thu, 30 Oct 2008 22:44:18 -0400
Content-Disposition: inline
In-Reply-To: <49099ACC.3070600@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 30, 2008 at 12:30:20PM +0100, Eric Dumazet wrote:
> Peter Zijlstra a =E9crit :
>> On Wed, 2008-10-29 at 21:00 +0100, Eric Dumazet wrote:
>>> Hum... Another way of handling all those cases and avoid memory bar=
riers
>>> would be to have different "NULL" pointers.
>>>
>>> Each hash chain should have a unique "NULL" pointer (in the case of=
 UDP,=20
>>> it
>>> can be the 128 values : [ (void*)0 .. (void *)127 ]
>> Why not use the bucket pointer as terminating condition?
>> Because all you really need is a pointer that is specific per bucket=
,
>> and not a valid element, right?
>
> Yes, but it forces compiler to keep around the bucket pointer.
>
> Big chance this value will be stored on stack.
>
> Next patch will use the least significant bit to distinguish a valid
> pointer from a "NULL pointer"

As you might guess, I do like that idea.  ;-)

On my plane trip, so am reviewing what I believe to be your current
combined patchset consisting of six patches transmitted in this thread:

Message-ID: <49081D67.3050502@cosmosbay.com>
Message-ID: <49082718.2030201@cosmosbay.com>
Message-ID: <490874F2.2060306@cosmosbay.com>
Message-ID: <4908DEDE.5030706@cosmosbay.com>
Message-ID: <49094B0F.2090208@cosmosbay.com>
Message-ID: <490838C6.4060304@cosmosbay.com>

This probably won't be your latest and greatest by the time you receive
this, but it appears to be the latest and greatest that I have.  ;-)

A few comments, search for blank lines.

							Thanx, Paul

> diff --git a/include/linux/list.h b/include/linux/list.h
> index 969f6e9..a3d5dd1 100644
> --- a/include/linux/list.h
> +++ b/include/linux/list.h
> @@ -654,6 +654,22 @@ static inline void hlist_move_list(struct hlist_=
head *old,
>  	     pos && ({ prefetch(pos->next); 1;}) &&			 \
>  		({ tpos =3D hlist_entry(pos, typeof(*tpos), member); 1;}); \
>  	     pos =3D pos->next)
> +/**
> + * hlist_for_each_entry_nulls	- iterate over list of given type
> + * @tpos:	the type * to use as a loop cursor.
> + * @pos:	the &struct hlist_node to use as a loop cursor.
> + * @head:	the head for your list.
> + * @member:	the name of the hlist_node within the struct.
> + * @nullval: the iteration should stop if a pointer is < nullval
> + *
> + * Special version of hlist_for_each_entry where the end pointer
> + * can be NULL but also any value < nullval.
> + */
> +#define hlist_for_each_entry_nulls(tpos, pos, head, member, nullval)=
	 \
> +	for (pos =3D (head)->first;					 \
> +	     ((unsigned long)pos >=3D nullval) && ({ prefetch(pos->next); 1=
;}) && \
> +		({ tpos =3D hlist_entry(pos, typeof(*tpos), member); 1;}); \
> +	     pos =3D pos->next)

It might be good to take a predicate macro/function instead of nullval,
in order to allow this primitive to be used for a number of different
pseudo-NULL-pointer schemes, and ditto for the similar macros you defin=
e
below.  Might be too early to know exactly how such a primitive should
look, though.

So just a random thought at this point.

In any case, this macro cannot be used in read-side critical sections.

Used by sk_for_each_nulls(), which is called by udp_lib_lport_inuse()
and udp_get_first().

udp_lib_lport_inuse() is called by udp_lib_get_port(), which holds the
hslot->lock, so should be OK.

In udp_get_first(), this same lock is held, so again should be OK.

>  /**
>   * hlist_for_each_entry_continue - iterate over a hlist continuing a=
fter current point
> @@ -679,6 +695,22 @@ static inline void hlist_move_list(struct hlist_=
head *old,
>  	     pos =3D pos->next)
> =20
>  /**
> + * hlist_for_each_entry_from_nulls - iterate over a hlist continuing=
 from current point
> + * @tpos:	the type * to use as a loop cursor.
> + * @pos:	the &struct hlist_node to use as a loop cursor.
> + * @member:	the name of the hlist_node within the struct.
> + * @nullval: the iteration should stop if a pointer is < nullval
> + *
> + * Special version of hlist_for_each_entry_from where the end pointe=
r
> + * can be NULL but also any value < nullval.
> + */
> +#define hlist_for_each_entry_from_nulls(tpos, pos, member, nullval)	=
\
> +	for (; ((unsigned long)pos >=3D nullval) && \
> +		({ prefetch(pos->next); 1;})   && \
> +		({ tpos =3D hlist_entry(pos, typeof(*tpos), member); 1;}); \
> +	     pos =3D pos->next)

This also must be called with the update-side lock held.  It is
wrappered by sk_for_each_from_nulls(), which in turn is called from
udp_v4_mcast_next() and udp_v6_mcast_next().  According to messages
earlier in this thread, that is the case.

udp_v4_mcast_next() is called from __udp4_lib_mcast_deliver(), which do=
es
hold hslot->lock, so OK.  Ditto for the calls from udp_v6_mcast_next().

Interestingly enough, these two functions use sk_head(), which calls
__sk_head(), which do not do rcu_dereference().  Which is another reaso=
n
that this cannot be called from an RCU read-side critical section.

> +/**
>   * hlist_for_each_entry_safe - iterate over list of given type safe =
against removal of list entry
>   * @tpos:	the type * to use as a loop cursor.
>   * @pos:	the &struct hlist_node to use as a loop cursor.
> diff --git a/include/linux/rculist.h b/include/linux/rculist.h
> index e649bd3..6f78e2b 100644
> --- a/include/linux/rculist.h
> +++ b/include/linux/rculist.h
> @@ -383,5 +383,23 @@ static inline void hlist_add_after_rcu(struct hl=
ist_node *prev,
>  		({ tpos =3D hlist_entry(pos, typeof(*tpos), member); 1; }); \
>  		pos =3D rcu_dereference(pos->next))
> =20
> +/**
> + * hlist_for_each_entry_rcu_nulls - iterate over rcu list of given t=
ype
> + * @tpos:	the type * to use as a loop cursor.
> + * @pos:	the &struct hlist_node to use as a loop cursor.
> + * @head:	the head for your list.
> + * @member:	the name of the hlist_node within the struct.
> + * @nullval:       the iteration should stop if a pointer is < nullv=
al
> + *
> + * Special version of hlist_for_each_entry_rcu where the end pointer
> + * can be NULL but also any value < nullval.
> + */
> +#define hlist_for_each_entry_rcu_nulls(tpos, pos, head, member, null=
val) \
> +	for (pos =3D rcu_dereference((head)->first);			 \
> +		((unsigned long)pos >=3D nullval) && 			\
> +		({ prefetch(pos->next); 1; }) &&			\
> +		({ tpos =3D hlist_entry(pos, typeof(*tpos), member); 1; }); \
> +		pos =3D rcu_dereference(pos->next))

Looks good.  It should be possible to get rid of the "pos" argument in
the upcoming version, as all of the offsets should be even, so the
bottom bit would come through unchanged.  In fact, it should be possibl=
e
in this variant as well:

	((unsigned long)pos - offsetof(typeof(*tpos)) >=3D nullval)

Or am I missing something?

>  #endif	/* __KERNEL__ */
>  #endif
> diff --git a/include/net/sock.h b/include/net/sock.h
> index ada50c0..6e8545b 100644
> --- a/include/net/sock.h
> +++ b/include/net/sock.h
> @@ -361,6 +361,27 @@ static __inline__ int sk_del_node_init(struct so=
ck *sk)
>  	return rc;
>  }
> =20
> +static __inline__ int __sk_del_node_init_rcu(struct sock *sk)
> +{
> +	if (sk_hashed(sk)) {
> +		hlist_del_init_rcu(&sk->sk_node);

Won't your pseudo-NULL pointers mess up __hlist_del(), which is called
from hlist_del_init_rcu(), and which expects real NULL pointers?

Seems like you need _nulls variants of these list primitives as well.

> +		return 1;
> +	}
> +	return 0;
> +}
> +
> +static __inline__ int sk_del_node_init_rcu(struct sock *sk)
> +{
> +	int rc =3D __sk_del_node_init_rcu(sk);
> +
> +	if (rc) {
> +		/* paranoid for a while -acme */
> +		WARN_ON(atomic_read(&sk->sk_refcnt) =3D=3D 1);
> +		__sock_put(sk);
> +	}
> +	return rc;
> +}
> +
>  static __inline__ void __sk_add_node(struct sock *sk, struct hlist_h=
ead *list)
>  {
>  	hlist_add_head(&sk->sk_node, list);
> @@ -372,6 +393,17 @@ static __inline__ void sk_add_node(struct sock *=
sk, struct hlist_head *list)
>  	__sk_add_node(sk, list);
>  }
> =20
> +static __inline__ void __sk_add_node_rcu(struct sock *sk, struct hli=
st_head *list)
> +{
> +	hlist_add_head_rcu(&sk->sk_node, list);

Same here -- hlist_add_head_rcu() expects real NULL pointers.

Or are these different lists?  I believe that these are the same lists,
given that the ->sk_node field is used in both cases.

So I believe that you need parallel _nulls primitives for this one also=
=2E

> +}
> +
> +static __inline__ void sk_add_node_rcu(struct sock *sk, struct hlist=
_head *list)
> +{
> +	sock_hold(sk);
> +	__sk_add_node_rcu(sk, list);
> +}
> +
>  static __inline__ void __sk_del_bind_node(struct sock *sk)
>  {
>  	__hlist_del(&sk->sk_bind_node);
> @@ -385,9 +417,16 @@ static __inline__ void sk_add_bind_node(struct s=
ock *sk,
> =20
>  #define sk_for_each(__sk, node, list) \
>  	hlist_for_each_entry(__sk, node, list, sk_node)
> +#define sk_for_each_nulls(__sk, node, list, nullval) \
> +	hlist_for_each_entry_nulls(__sk, node, list, sk_node, nullval)
> +#define sk_for_each_rcu_nulls(__sk, node, list, nullval) \
> +	hlist_for_each_entry_rcu_nulls(__sk, node, list, sk_node, nullval)
>  #define sk_for_each_from(__sk, node) \
>  	if (__sk && ({ node =3D &(__sk)->sk_node; 1; })) \
>  		hlist_for_each_entry_from(__sk, node, sk_node)
> +#define sk_for_each_from_nulls(__sk, node, nullval) \
> +	if (__sk && ({ node =3D &(__sk)->sk_node; 1; })) \
> +		hlist_for_each_entry_from_nulls(__sk, node, sk_node, nullval)
>  #define sk_for_each_continue(__sk, node) \
>  	if (__sk && ({ node =3D &(__sk)->sk_node; 1; })) \
>  		hlist_for_each_entry_continue(__sk, node, sk_node)
> @@ -587,8 +626,9 @@ struct proto {
>  	int			*sysctl_rmem;
>  	int			max_header;
> =20
> -	struct kmem_cache		*slab;
> +	struct kmem_cache	*slab;
>  	unsigned int		obj_size;
> +	int			slab_flags;
> =20
>  	atomic_t		*orphan_count;
> =20
> @@ -597,7 +637,7 @@ struct proto {
> =20
>  	union {
>  		struct inet_hashinfo	*hashinfo;
> -		struct hlist_head	*udp_hash;
> +		struct udp_table	*udp_table;
>  		struct raw_hashinfo	*raw_hash;
>  	} h;
> =20
> diff --git a/include/net/udp.h b/include/net/udp.h
> index 1e20509..df2bfe5 100644
> --- a/include/net/udp.h
> +++ b/include/net/udp.h
> @@ -50,8 +50,15 @@ struct udp_skb_cb {
>  };
>  #define UDP_SKB_CB(__skb)	((struct udp_skb_cb *)((__skb)->cb))
> =20
> -extern struct hlist_head udp_hash[UDP_HTABLE_SIZE];
> -extern rwlock_t udp_hash_lock;
> +struct udp_hslot {
> +	struct hlist_head	head;
> +	spinlock_t		lock;
> +} __attribute__((aligned(2 * sizeof(long))));
> +struct udp_table {
> +	struct udp_hslot	hash[UDP_HTABLE_SIZE];
> +};
> +extern struct udp_table udp_table;
> +extern void udp_table_init(struct udp_table *);
> =20
> =20
>  /* Note: this must match 'valbool' in sock_setsockopt */
> @@ -110,15 +117,7 @@ static inline void udp_lib_hash(struct sock *sk)
>  	BUG();
>  }
> =20
> -static inline void udp_lib_unhash(struct sock *sk)
> -{
> -	write_lock_bh(&udp_hash_lock);
> -	if (sk_del_node_init(sk)) {
> -		inet_sk(sk)->num =3D 0;
> -		sock_prot_inuse_add(sock_net(sk), sk->sk_prot, -1);
> -	}
> -	write_unlock_bh(&udp_hash_lock);
> -}
> +extern void udp_lib_unhash(struct sock *sk);
> =20
>  static inline void udp_lib_close(struct sock *sk, long timeout)
>  {
> @@ -187,7 +186,7 @@ extern struct sock *udp4_lib_lookup(struct net *n=
et, __be32 saddr, __be16 sport,
>  struct udp_seq_afinfo {
>  	char			*name;
>  	sa_family_t		family;
> -	struct hlist_head	*hashtable;
> +	struct udp_table	*udp_table;
>  	struct file_operations	seq_fops;
>  	struct seq_operations	seq_ops;
>  };
> @@ -196,7 +195,7 @@ struct udp_iter_state {
>  	struct seq_net_private  p;
>  	sa_family_t		family;
>  	int			bucket;
> -	struct hlist_head	*hashtable;
> +	struct udp_table	*udp_table;
>  };
> =20
>  #ifdef CONFIG_PROC_FS
> diff --git a/include/net/udplite.h b/include/net/udplite.h
> index b76b2e3..afdffe6 100644
> --- a/include/net/udplite.h
> +++ b/include/net/udplite.h
> @@ -11,7 +11,7 @@
>  #define UDPLITE_RECV_CSCOV   11 /* receiver partial coverage (thresh=
old ) */
> =20
>  extern struct proto 		udplite_prot;
> -extern struct hlist_head 	udplite_hash[UDP_HTABLE_SIZE];
> +extern struct udp_table		udplite_table;
> =20
>  /*
>   *	Checksum computation is all in software, hence simpler getfrag.
> diff --git a/net/core/sock.c b/net/core/sock.c
> index 5e2a313..ded1eb5 100644
> --- a/net/core/sock.c
> +++ b/net/core/sock.c
> @@ -2042,7 +2042,8 @@ int proto_register(struct proto *prot, int allo=
c_slab)
> =20
>  	if (alloc_slab) {
>  		prot->slab =3D kmem_cache_create(prot->name, prot->obj_size, 0,
> -					       SLAB_HWCACHE_ALIGN, NULL);
> +					SLAB_HWCACHE_ALIGN | prot->slab_flags,
> +					NULL);
> =20
>  		if (prot->slab =3D=3D NULL) {
>  			printk(KERN_CRIT "%s: Can't create sock SLAB cache!\n",
> diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
> index 2095abc..915d92d 100644
> --- a/net/ipv4/udp.c
> +++ b/net/ipv4/udp.c
> @@ -104,12 +104,8 @@
>  #include <net/xfrm.h>
>  #include "udp_impl.h"
> =20
> -/*
> - *	Snmp MIB for the UDP layer
> - */
> -
> -struct hlist_head udp_hash[UDP_HTABLE_SIZE];
> -DEFINE_RWLOCK(udp_hash_lock);
> +struct udp_table udp_table;
> +EXPORT_SYMBOL(udp_table);
> =20
>  int sysctl_udp_mem[3] __read_mostly;
>  int sysctl_udp_rmem_min __read_mostly;
> @@ -123,7 +119,7 @@ atomic_t udp_memory_allocated;
>  EXPORT_SYMBOL(udp_memory_allocated);
> =20
>  static int udp_lib_lport_inuse(struct net *net, __u16 num,
> -			       const struct hlist_head udptable[],
> +			       const struct udp_hslot *hslot,
>  			       struct sock *sk,
>  			       int (*saddr_comp)(const struct sock *sk1,
>  						 const struct sock *sk2))
> @@ -131,7 +127,7 @@ static int udp_lib_lport_inuse(struct net *net, _=
_u16 num,
>  	struct sock *sk2;
>  	struct hlist_node *node;
> =20
> -	sk_for_each(sk2, node, &udptable[udp_hashfn(net, num)])
> +	sk_for_each_nulls(sk2, node, &hslot->head, UDP_HTABLE_SIZE)
>  		if (net_eq(sock_net(sk2), net)			&&
>  		    sk2 !=3D sk					&&
>  		    sk2->sk_hash =3D=3D num				&&
> @@ -154,12 +150,11 @@ int udp_lib_get_port(struct sock *sk, unsigned =
short snum,
>  		       int (*saddr_comp)(const struct sock *sk1,
>  					 const struct sock *sk2 )    )
>  {
> -	struct hlist_head *udptable =3D sk->sk_prot->h.udp_hash;
> +	struct udp_hslot *hslot;
> +	struct udp_table *udptable =3D sk->sk_prot->h.udp_table;
>  	int    error =3D 1;
>  	struct net *net =3D sock_net(sk);
> =20
> -	write_lock_bh(&udp_hash_lock);
> -
>  	if (!snum) {
>  		int low, high, remaining;
>  		unsigned rand;
> @@ -171,26 +166,39 @@ int udp_lib_get_port(struct sock *sk, unsigned =
short snum,

inet_get_local_port_range() used to be under the write_lock_bh(),
and no longer is.  So, how do we now protect against concurrent port
range changes?

>  		rand =3D net_random();
>  		snum =3D first =3D rand % remaining + low;
>  		rand |=3D 1;
> -		while (udp_lib_lport_inuse(net, snum, udptable, sk,
> -					   saddr_comp)) {
> +		for (;;) {
> +			hslot =3D &udptable->hash[udp_hashfn(net, snum)];
> +			spin_lock_bh(&hslot->lock);
> +			if (!udp_lib_lport_inuse(net, snum, hslot, sk, saddr_comp))
> +				break;
> +			spin_unlock_bh(&hslot->lock);
>  			do {
>  				snum =3D snum + rand;
>  			} while (snum < low || snum > high);

The above -really- confuses me, but not part of this patch.  If we are
out of range, keep going?  Well, I guess that since it is a short, we
cannot go very far...

>  			if (snum =3D=3D first)
>  				goto fail;

And I don't understand how we are guaranteed to have scanned all the
possible ports upon failure, but happy to leave that to you guys.

>  		}
> -	} else if (udp_lib_lport_inuse(net, snum, udptable, sk, saddr_comp)=
)
> -		goto fail;
> -
> +	} else {
> +		hslot =3D &udptable->hash[udp_hashfn(net, snum)];
> +		spin_lock_bh(&hslot->lock);
> +		if (udp_lib_lport_inuse(net, snum, hslot, sk, saddr_comp))
> +			goto fail_unlock;
> +	}
>  	inet_sk(sk)->num =3D snum;
>  	sk->sk_hash =3D snum;
>  	if (sk_unhashed(sk)) {
> -		sk_add_node(sk, &udptable[udp_hashfn(net, snum)]);
> +		/*
> +		 * We need that previous write to sk->sk_hash committed
> +		 * before write to sk->next done in following add_node() variant
> +		 */
> +		smp_wmb();
> +		sk_add_node_rcu(sk, &hslot->head);
>  		sock_prot_inuse_add(sock_net(sk), sk->sk_prot, 1);
>  	}
>  	error =3D 0;
> +fail_unlock:
> +	spin_unlock_bh(&hslot->lock);
>  fail:
> -	write_unlock_bh(&udp_hash_lock);
>  	return error;
>  }
> =20
> @@ -208,63 +216,96 @@ int udp_v4_get_port(struct sock *sk, unsigned s=
hort snum)
>  	return udp_lib_get_port(sk, snum, ipv4_rcv_saddr_equal);
>  }
> =20
> +static inline int compute_score(struct sock *sk, struct net *net, __=
be32 saddr,
> +			 unsigned short hnum,
> +			 __be16 sport, __be32 daddr, __be16 dport, int dif)
> +{
> +	int score =3D -1;
> +
> +	if (net_eq(sock_net(sk), net) && sk->sk_hash =3D=3D hnum &&
> +			!ipv6_only_sock(sk)) {
> +		struct inet_sock *inet =3D inet_sk(sk);
> +
> +		score =3D (sk->sk_family =3D=3D PF_INET ? 1 : 0);
> +		if (inet->rcv_saddr) {
> +			if (inet->rcv_saddr !=3D daddr)
> +				return -1;
> +			score +=3D 2;
> +		}
> +		if (inet->daddr) {
> +			if (inet->daddr !=3D saddr)
> +				return -1;
> +			score +=3D 2;
> +		}
> +		if (inet->dport) {
> +			if (inet->dport !=3D sport)
> +				return -1;
> +			score +=3D 2;
> +		}
> +		if (sk->sk_bound_dev_if) {
> +			if (sk->sk_bound_dev_if !=3D dif)
> +				return -1;
> +			score +=3D 2;
> +		}
> +	}
> +	return score;
> +}
> +
>  /* UDP is nearly always wildcards out the wazoo, it makes no sense t=
o try
>   * harder than this. -DaveM
>   */
>  static struct sock *__udp4_lib_lookup(struct net *net, __be32 saddr,
>  		__be16 sport, __be32 daddr, __be16 dport,
> -		int dif, struct hlist_head udptable[])
> +		int dif, struct udp_table *udptable)
>  {
> -	struct sock *sk, *result =3D NULL;
> +	struct sock *sk, *result;
>  	struct hlist_node *node;
>  	unsigned short hnum =3D ntohs(dport);
> -	int badness =3D -1;
> -
> -	read_lock(&udp_hash_lock);
> -	sk_for_each(sk, node, &udptable[udp_hashfn(net, hnum)]) {
> -		struct inet_sock *inet =3D inet_sk(sk);
> -
> -		if (net_eq(sock_net(sk), net) && sk->sk_hash =3D=3D hnum &&
> -				!ipv6_only_sock(sk)) {
> -			int score =3D (sk->sk_family =3D=3D PF_INET ? 1 : 0);
> -			if (inet->rcv_saddr) {
> -				if (inet->rcv_saddr !=3D daddr)
> -					continue;
> -				score+=3D2;
> -			}
> -			if (inet->daddr) {
> -				if (inet->daddr !=3D saddr)
> -					continue;
> -				score+=3D2;
> -			}
> -			if (inet->dport) {
> -				if (inet->dport !=3D sport)
> -					continue;
> -				score+=3D2;
> -			}
> -			if (sk->sk_bound_dev_if) {
> -				if (sk->sk_bound_dev_if !=3D dif)
> -					continue;
> -				score+=3D2;
> -			}
> -			if (score =3D=3D 9) {
> -				result =3D sk;
> -				break;
> -			} else if (score > badness) {
> -				result =3D sk;
> -				badness =3D score;
> -			}
> +	unsigned int hash =3D udp_hashfn(net, hnum);
> +	struct udp_hslot *hslot =3D &udptable->hash[hash];
> +	int score, badness;
> +
> +	rcu_read_lock();
> +begin:
> +	result =3D NULL;
> +	badness =3D -1;
> +	sk_for_each_rcu_nulls(sk, node, &hslot->head, UDP_HTABLE_SIZE) {
> +		/*
> +		 * lockless reader, and SLAB_DESTROY_BY_RCU items:
> +		 * We must check this item was not moved to another chain
> +		 */
> +		if (udp_hashfn(net, sk->sk_hash) !=3D hash)
> +			goto begin;
> +		score =3D compute_score(sk, net, saddr, hnum, sport,
> +				      daddr, dport, dif);
> +		if (score > badness) {
> +			result =3D sk;
> +			badness =3D score;
> + 		}
> +	}
> +	/*
> +	 * if the 'NULL' pointer we got at the end of this lookup is
> +	 * not the expected one, we must restart lookup.
> +	 */
> +	if ((unsigned long)node !=3D hash)
> +		goto begin;
> +
> +	if (result) {
> +		if (unlikely(!atomic_inc_not_zero(&result->sk_refcnt)))
> +			result =3D NULL;
> +		else if (unlikely(compute_score(result, net, saddr, hnum, sport,
> +				  daddr, dport, dif) < badness)) {
> +			sock_put(result);
> +			goto begin;
>  		}
>  	}
> -	if (result)
> -		sock_hold(result);
> -	read_unlock(&udp_hash_lock);
> +	rcu_read_unlock();
>  	return result;
>  }
> =20
>  static inline struct sock *__udp4_lib_lookup_skb(struct sk_buff *skb=
,
>  						 __be16 sport, __be16 dport,
> -						 struct hlist_head udptable[])
> +						 struct udp_table *udptable)
>  {
>  	struct sock *sk;
>  	const struct iphdr *iph =3D ip_hdr(skb);
> @@ -280,7 +321,7 @@ static inline struct sock *__udp4_lib_lookup_skb(=
struct sk_buff *skb,
>  struct sock *udp4_lib_lookup(struct net *net, __be32 saddr, __be16 s=
port,
>  			     __be32 daddr, __be16 dport, int dif)
>  {
> -	return __udp4_lib_lookup(net, saddr, sport, daddr, dport, dif, udp_=
hash);
> +	return __udp4_lib_lookup(net, saddr, sport, daddr, dport, dif, &udp=
_table);
>  }
>  EXPORT_SYMBOL_GPL(udp4_lib_lookup);
> =20
> @@ -293,7 +334,7 @@ static inline struct sock *udp_v4_mcast_next(stru=
ct sock *sk,
>  	struct sock *s =3D sk;
>  	unsigned short hnum =3D ntohs(loc_port);
> =20
> -	sk_for_each_from(s, node) {
> +	sk_for_each_from_nulls(s, node, UDP_HTABLE_SIZE) {
>  		struct inet_sock *inet =3D inet_sk(s);
> =20
>  		if (s->sk_hash !=3D hnum					||
> @@ -323,7 +364,7 @@ found:
>   * to find the appropriate port.
>   */
> =20
> -void __udp4_lib_err(struct sk_buff *skb, u32 info, struct hlist_head=
 udptable[])
> +void __udp4_lib_err(struct sk_buff *skb, u32 info, struct udp_table =
*udptable)
>  {
>  	struct inet_sock *inet;
>  	struct iphdr *iph =3D (struct iphdr*)skb->data;
> @@ -392,7 +433,7 @@ out:
> =20
>  void udp_err(struct sk_buff *skb, u32 info)
>  {
> -	__udp4_lib_err(skb, info, udp_hash);
> +	__udp4_lib_err(skb, info, &udp_table);
>  }
> =20
>  /*
> @@ -933,6 +974,21 @@ int udp_disconnect(struct sock *sk, int flags)
>  	return 0;
>  }
> =20
> +void udp_lib_unhash(struct sock *sk)
> +{
> +	struct udp_table *udptable =3D sk->sk_prot->h.udp_table;
> +	unsigned int hash =3D udp_hashfn(sock_net(sk), sk->sk_hash);
> +	struct udp_hslot *hslot =3D &udptable->hash[hash];
> +
> +	spin_lock(&hslot->lock);
> +	if (sk_del_node_init_rcu(sk)) {
> +		inet_sk(sk)->num =3D 0;
> +		sock_prot_inuse_add(sock_net(sk), sk->sk_prot, -1);
> +	}
> +	spin_unlock(&hslot->lock);
> +}
> +EXPORT_SYMBOL(udp_lib_unhash);
> +
>  static int __udp_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
>  {
>  	int is_udplite =3D IS_UDPLITE(sk);
> @@ -1071,13 +1127,14 @@ drop:
>  static int __udp4_lib_mcast_deliver(struct net *net, struct sk_buff =
*skb,
>  				    struct udphdr  *uh,
>  				    __be32 saddr, __be32 daddr,
> -				    struct hlist_head udptable[])
> +				    struct udp_table *udptable)
>  {
>  	struct sock *sk;
> +	struct udp_hslot *hslot =3D &udptable->hash[udp_hashfn(net, ntohs(u=
h->dest))];
>  	int dif;
> =20
> -	read_lock(&udp_hash_lock);
> -	sk =3D sk_head(&udptable[udp_hashfn(net, ntohs(uh->dest))]);
> +	spin_lock(&hslot->lock);
> +	sk =3D sk_head(&hslot->head);
>  	dif =3D skb->dev->ifindex;
>  	sk =3D udp_v4_mcast_next(sk, uh->dest, daddr, uh->source, saddr, di=
f);
>  	if (sk) {
> @@ -1102,7 +1159,7 @@ static int __udp4_lib_mcast_deliver(struct net =
*net, struct sk_buff *skb,
>  		} while (sknext);
>  	} else
>  		kfree_skb(skb);
> -	read_unlock(&udp_hash_lock);
> +	spin_unlock(&hslot->lock);
>  	return 0;
>  }
> =20
> @@ -1148,7 +1205,7 @@ static inline int udp4_csum_init(struct sk_buff=
 *skb, struct udphdr *uh,
>   *	All we need to do is get the socket, and then do a checksum.
>   */
> =20
> -int __udp4_lib_rcv(struct sk_buff *skb, struct hlist_head udptable[]=
,
> +int __udp4_lib_rcv(struct sk_buff *skb, struct udp_table *udptable,
>  		   int proto)
>  {
>  	struct sock *sk;
> @@ -1246,7 +1303,7 @@ drop:
> =20
>  int udp_rcv(struct sk_buff *skb)
>  {
> -	return __udp4_lib_rcv(skb, udp_hash, IPPROTO_UDP);
> +	return __udp4_lib_rcv(skb, &udp_table, IPPROTO_UDP);
>  }
> =20
>  void udp_destroy_sock(struct sock *sk)
> @@ -1488,7 +1545,8 @@ struct proto udp_prot =3D {
>  	.sysctl_wmem	   =3D &sysctl_udp_wmem_min,
>  	.sysctl_rmem	   =3D &sysctl_udp_rmem_min,
>  	.obj_size	   =3D sizeof(struct udp_sock),
> -	.h.udp_hash	   =3D udp_hash,
> +	.slab_flags	   =3D SLAB_DESTROY_BY_RCU,
> +	.h.udp_table	   =3D &udp_table,
>  #ifdef CONFIG_COMPAT
>  	.compat_setsockopt =3D compat_udp_setsockopt,
>  	.compat_getsockopt =3D compat_udp_getsockopt,
> @@ -1498,20 +1556,23 @@ struct proto udp_prot =3D {
>  /* -----------------------------------------------------------------=
------- */
>  #ifdef CONFIG_PROC_FS
> =20
> -static struct sock *udp_get_first(struct seq_file *seq)
> +static struct sock *udp_get_first(struct seq_file *seq, int start)
>  {
>  	struct sock *sk;
>  	struct udp_iter_state *state =3D seq->private;
>  	struct net *net =3D seq_file_net(seq);
> =20
> -	for (state->bucket =3D 0; state->bucket < UDP_HTABLE_SIZE; ++state-=
>bucket) {
> +	for (state->bucket =3D start; state->bucket < UDP_HTABLE_SIZE; ++st=
ate->bucket) {
>  		struct hlist_node *node;
> -		sk_for_each(sk, node, state->hashtable + state->bucket) {
> +		struct udp_hslot *hslot =3D &state->udp_table->hash[state->bucket]=
;
> +		spin_lock_bh(&hslot->lock);
> +		sk_for_each_nulls(sk, node, &hslot->head, UDP_HTABLE_SIZE) {
>  			if (!net_eq(sock_net(sk), net))
>  				continue;
>  			if (sk->sk_family =3D=3D state->family)
>  				goto found;
>  		}
> +		spin_unlock_bh(&hslot->lock);
>  	}
>  	sk =3D NULL;
>  found:
> @@ -1525,20 +1586,18 @@ static struct sock *udp_get_next(struct seq_f=
ile *seq, struct sock *sk)
> =20
>  	do {
>  		sk =3D sk_next(sk);
> -try_again:
> -		;
>  	} while (sk && (!net_eq(sock_net(sk), net) || sk->sk_family !=3D st=
ate->family));
> =20
> -	if (!sk && ++state->bucket < UDP_HTABLE_SIZE) {
> -		sk =3D sk_head(state->hashtable + state->bucket);
> -		goto try_again;
> +	if (!sk) {
> +		spin_unlock_bh(&state->udp_table->hash[state->bucket].lock);
> +		return udp_get_first(seq, state->bucket + 1);
>  	}
>  	return sk;
>  }
> =20
>  static struct sock *udp_get_idx(struct seq_file *seq, loff_t pos)
>  {
> -	struct sock *sk =3D udp_get_first(seq);
> +	struct sock *sk =3D udp_get_first(seq, 0);
> =20
>  	if (sk)
>  		while (pos && (sk =3D udp_get_next(seq, sk)) !=3D NULL)
> @@ -1547,9 +1606,7 @@ static struct sock *udp_get_idx(struct seq_file=
 *seq, loff_t pos)
>  }
> =20
>  static void *udp_seq_start(struct seq_file *seq, loff_t *pos)
> -	__acquires(udp_hash_lock)
>  {
> -	read_lock(&udp_hash_lock);
>  	return *pos ? udp_get_idx(seq, *pos-1) : SEQ_START_TOKEN;
>  }
> =20
> @@ -1567,9 +1624,11 @@ static void *udp_seq_next(struct seq_file *seq=
, void *v, loff_t *pos)
>  }
> =20
>  static void udp_seq_stop(struct seq_file *seq, void *v)
> -	__releases(udp_hash_lock)
>  {
> -	read_unlock(&udp_hash_lock);
> +	struct udp_iter_state *state =3D seq->private;
> +
> +	if (state->bucket < UDP_HTABLE_SIZE)
> +		spin_unlock_bh(&state->udp_table->hash[state->bucket].lock);
>  }
> =20
>  static int udp_seq_open(struct inode *inode, struct file *file)
> @@ -1585,7 +1644,7 @@ static int udp_seq_open(struct inode *inode, st=
ruct file *file)
> =20
>  	s =3D ((struct seq_file *)file->private_data)->private;
>  	s->family		=3D afinfo->family;
> -	s->hashtable		=3D afinfo->hashtable;
> +	s->udp_table		=3D afinfo->udp_table;
>  	return err;
>  }
> =20
> @@ -1657,7 +1716,7 @@ int udp4_seq_show(struct seq_file *seq, void *v=
)
>  static struct udp_seq_afinfo udp4_seq_afinfo =3D {
>  	.name		=3D "udp",
>  	.family		=3D AF_INET,
> -	.hashtable	=3D udp_hash,
> +	.udp_table	=3D &udp_table,
>  	.seq_fops	=3D {
>  		.owner	=3D	THIS_MODULE,
>  	},
> @@ -1692,10 +1751,21 @@ void udp4_proc_exit(void)
>  }
>  #endif /* CONFIG_PROC_FS */
> =20
> +void __init udp_table_init(struct udp_table *table)
> +{
> +	int i;
> +=09
> +	for (i =3D 0; i < UDP_HTABLE_SIZE; i++) {
> +		table->hash[i].head.first =3D (struct hlist_node *)i;
> +		spin_lock_init(&table->hash[i].lock);
> +	}
> +}
> +
>  void __init udp_init(void)
>  {
>  	unsigned long limit;
> =20
> +	udp_table_init(&udp_table);
>  	/* Set the pressure threshold up by the same strategy of TCP. It is=
 a
>  	 * fraction of global memory that is up to 1/2 at 256 MB, decreasin=
g
>  	 * toward zero with the amount of memory, with a floor of 128 pages=
=2E
> @@ -1712,8 +1782,6 @@ void __init udp_init(void)
>  }
> =20
>  EXPORT_SYMBOL(udp_disconnect);
> -EXPORT_SYMBOL(udp_hash);
> -EXPORT_SYMBOL(udp_hash_lock);
>  EXPORT_SYMBOL(udp_ioctl);
>  EXPORT_SYMBOL(udp_prot);
>  EXPORT_SYMBOL(udp_sendmsg);
> diff --git a/net/ipv4/udp_impl.h b/net/ipv4/udp_impl.h
> index 2e9bad2..9f4a616 100644
> --- a/net/ipv4/udp_impl.h
> +++ b/net/ipv4/udp_impl.h
> @@ -5,8 +5,8 @@
>  #include <net/protocol.h>
>  #include <net/inet_common.h>
> =20
> -extern int  	__udp4_lib_rcv(struct sk_buff *, struct hlist_head [], =
int );
> -extern void 	__udp4_lib_err(struct sk_buff *, u32, struct hlist_head=
 []);
> +extern int  	__udp4_lib_rcv(struct sk_buff *, struct udp_table *, in=
t );
> +extern void 	__udp4_lib_err(struct sk_buff *, u32, struct udp_table =
*);
> =20
>  extern int	udp_v4_get_port(struct sock *sk, unsigned short snum);
> =20
> diff --git a/net/ipv4/udplite.c b/net/ipv4/udplite.c
> index 3c80796..c784891 100644
> --- a/net/ipv4/udplite.c
> +++ b/net/ipv4/udplite.c
> @@ -12,16 +12,17 @@
>   */
>  #include "udp_impl.h"
> =20
> -struct hlist_head 	udplite_hash[UDP_HTABLE_SIZE];
> +struct udp_table 	udplite_table;
> +EXPORT_SYMBOL(udplite_table);
> =20
>  static int udplite_rcv(struct sk_buff *skb)
>  {
> -	return __udp4_lib_rcv(skb, udplite_hash, IPPROTO_UDPLITE);
> +	return __udp4_lib_rcv(skb, &udplite_table, IPPROTO_UDPLITE);
>  }
> =20
>  static void udplite_err(struct sk_buff *skb, u32 info)
>  {
> -	__udp4_lib_err(skb, info, udplite_hash);
> +	__udp4_lib_err(skb, info, &udplite_table);
>  }
> =20
>  static	struct net_protocol udplite_protocol =3D {
> @@ -50,7 +51,8 @@ struct proto 	udplite_prot =3D {
>  	.unhash		   =3D udp_lib_unhash,
>  	.get_port	   =3D udp_v4_get_port,
>  	.obj_size	   =3D sizeof(struct udp_sock),
> -	.h.udp_hash	   =3D udplite_hash,
> +	.slab_flags	   =3D SLAB_DESTROY_BY_RCU,
> +	.h.udp_table	   =3D &udplite_table,
>  #ifdef CONFIG_COMPAT
>  	.compat_setsockopt =3D compat_udp_setsockopt,
>  	.compat_getsockopt =3D compat_udp_getsockopt,
> @@ -71,7 +73,7 @@ static struct inet_protosw udplite4_protosw =3D {
>  static struct udp_seq_afinfo udplite4_seq_afinfo =3D {
>  	.name		=3D "udplite",
>  	.family		=3D AF_INET,
> -	.hashtable	=3D udplite_hash,
> +	.udp_table 	=3D &udplite_table,
>  	.seq_fops	=3D {
>  		.owner	=3D	THIS_MODULE,
>  	},
> @@ -108,6 +110,7 @@ static inline int udplite4_proc_init(void)
> =20
>  void __init udplite4_register(void)
>  {
> +	udp_table_init(&udplite_table);
>  	if (proto_register(&udplite_prot, 1))
>  		goto out_register_err;
> =20
> @@ -126,5 +129,4 @@ out_register_err:
>  	printk(KERN_CRIT "%s: Cannot add UDP-Lite protocol.\n", __func__);
>  }
> =20
> -EXPORT_SYMBOL(udplite_hash);
>  EXPORT_SYMBOL(udplite_prot);
> diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
> index e51da8c..8c3671d 100644
> --- a/net/ipv6/udp.c
> +++ b/net/ipv6/udp.c
> @@ -54,62 +54,97 @@ int udp_v6_get_port(struct sock *sk, unsigned sho=
rt snum)
>  	return udp_lib_get_port(sk, snum, ipv6_rcv_saddr_equal);
>  }
> =20
> +static inline int compute_score(struct sock *sk, struct net *net,
> +				unsigned short hnum,
> +				struct in6_addr *saddr, __be16 sport,
> +				struct in6_addr *daddr, __be16 dport,
> +				int dif)
> +{
> +	int score =3D -1;
> +
> +	if (net_eq(sock_net(sk), net) && sk->sk_hash =3D=3D hnum &&
> +			sk->sk_family =3D=3D PF_INET6) {
> +		struct ipv6_pinfo *np =3D inet6_sk(sk);
> +		struct inet_sock *inet =3D inet_sk(sk);
> +
> +		score =3D 0;
> +		if (inet->dport) {
> +			if (inet->dport !=3D sport)
> +				return -1;
> +			score++;
> +		}
> +		if (!ipv6_addr_any(&np->rcv_saddr)) {
> +			if (!ipv6_addr_equal(&np->rcv_saddr, daddr))
> +				return -1;
> +			score++;
> +		}
> +		if (!ipv6_addr_any(&np->daddr)) {
> +			if (!ipv6_addr_equal(&np->daddr, saddr))
> +				return -1;
> +			score++;
> +		}
> +		if (sk->sk_bound_dev_if) {
> +			if (sk->sk_bound_dev_if !=3D dif)
> +				return -1;
> +			score++;
> +		}
> +	}
> +	return score;
> +}
> +
>  static struct sock *__udp6_lib_lookup(struct net *net,
>  				      struct in6_addr *saddr, __be16 sport,
>  				      struct in6_addr *daddr, __be16 dport,
> -				      int dif, struct hlist_head udptable[])
> +				      int dif, struct udp_table *udptable)
>  {
> -	struct sock *sk, *result =3D NULL;
> +	struct sock *sk, *result;
>  	struct hlist_node *node;
>  	unsigned short hnum =3D ntohs(dport);
> -	int badness =3D -1;
> -
> -	read_lock(&udp_hash_lock);
> -	sk_for_each(sk, node, &udptable[udp_hashfn(net, hnum)]) {
> -		struct inet_sock *inet =3D inet_sk(sk);
> -
> -		if (net_eq(sock_net(sk), net) && sk->sk_hash =3D=3D hnum &&
> -				sk->sk_family =3D=3D PF_INET6) {
> -			struct ipv6_pinfo *np =3D inet6_sk(sk);
> -			int score =3D 0;
> -			if (inet->dport) {
> -				if (inet->dport !=3D sport)
> -					continue;
> -				score++;
> -			}
> -			if (!ipv6_addr_any(&np->rcv_saddr)) {
> -				if (!ipv6_addr_equal(&np->rcv_saddr, daddr))
> -					continue;
> -				score++;
> -			}
> -			if (!ipv6_addr_any(&np->daddr)) {
> -				if (!ipv6_addr_equal(&np->daddr, saddr))
> -					continue;
> -				score++;
> -			}
> -			if (sk->sk_bound_dev_if) {
> -				if (sk->sk_bound_dev_if !=3D dif)
> -					continue;
> -				score++;
> -			}
> -			if (score =3D=3D 4) {
> -				result =3D sk;
> -				break;
> -			} else if (score > badness) {
> -				result =3D sk;
> -				badness =3D score;
> -			}
> +	unsigned int hash =3D udp_hashfn(net, hnum);
> +	struct udp_hslot *hslot =3D &udptable->hash[hash];
> +	int score, badness;
> +
> +	rcu_read_lock();
> +begin:
> +	result =3D NULL;
> +	badness =3D -1;
> +	sk_for_each_rcu_nulls(sk, node, &hslot->head, UDP_HTABLE_SIZE) {
> +		/*
> +		 * lockless reader, and SLAB_DESTROY_BY_RCU items:
> +		 * We must check this item was not moved to another chain
> +		 */
> +		if (udp_hashfn(net, sk->sk_hash) !=3D hash)
> +			goto begin;
> +		score =3D compute_score(sk, net, hnum, saddr, sport,
> +				      daddr, dport, dif);
> +		if (score > badness) {
> +			result =3D sk;
> +			badness =3D score;
>  		}
>  	}
> -	if (result)
> -		sock_hold(result);
> -	read_unlock(&udp_hash_lock);
> +	/*
> +	 * if the 'NULL' pointer we got at the end of this lookup is
> +	 * not the expected one, we must restart lookup.
> +	 */
> +	if ((unsigned long)node !=3D hash)
> +		goto begin;
> +
> +	if (result) {
> +		if (unlikely(!atomic_inc_not_zero(&result->sk_refcnt)))
> +			result =3D NULL;
> +		else if (unlikely(compute_score(result, net, hnum, saddr, sport,
> +					daddr, dport, dif) < badness)) {
> +			sock_put(result);
> +			goto begin;
> + 		}
> +	}
> +	rcu_read_unlock();
>  	return result;
>  }
> =20
>  static struct sock *__udp6_lib_lookup_skb(struct sk_buff *skb,
>  					  __be16 sport, __be16 dport,
> -					  struct hlist_head udptable[])
> +					  struct udp_table *udptable)
>  {
>  	struct sock *sk;
>  	struct ipv6hdr *iph =3D ipv6_hdr(skb);
> @@ -239,7 +274,7 @@ csum_copy_err:
> =20
>  void __udp6_lib_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
>  		    int type, int code, int offset, __be32 info,
> -		    struct hlist_head udptable[]                    )
> +		    struct udp_table *udptable)
>  {
>  	struct ipv6_pinfo *np;
>  	struct ipv6hdr *hdr =3D (struct ipv6hdr*)skb->data;
> @@ -275,7 +310,7 @@ static __inline__ void udpv6_err(struct sk_buff *=
skb,
>  				 struct inet6_skb_parm *opt, int type,
>  				 int code, int offset, __be32 info     )
>  {
> -	__udp6_lib_err(skb, opt, type, code, offset, info, udp_hash);
> +	__udp6_lib_err(skb, opt, type, code, offset, info, &udp_table);
>  }
> =20
>  int udpv6_queue_rcv_skb(struct sock * sk, struct sk_buff *skb)
> @@ -337,7 +372,7 @@ static struct sock *udp_v6_mcast_next(struct sock=
 *sk,
>  	struct sock *s =3D sk;
>  	unsigned short num =3D ntohs(loc_port);
> =20
> -	sk_for_each_from(s, node) {
> +	sk_for_each_from_nulls(s, node, UDP_HTABLE_SIZE) {
>  		struct inet_sock *inet =3D inet_sk(s);
> =20
>  		if (sock_net(s) !=3D sock_net(sk))
> @@ -374,14 +409,15 @@ static struct sock *udp_v6_mcast_next(struct so=
ck *sk,
>   */
>  static int __udp6_lib_mcast_deliver(struct net *net, struct sk_buff =
*skb,
>  		struct in6_addr *saddr, struct in6_addr *daddr,
> -		struct hlist_head udptable[])
> +		struct udp_table *udptable)
>  {
>  	struct sock *sk, *sk2;
>  	const struct udphdr *uh =3D udp_hdr(skb);
> +	struct udp_hslot *hslot =3D &udptable->hash[udp_hashfn(net, ntohs(u=
h->dest))];
>  	int dif;
> =20
> -	read_lock(&udp_hash_lock);
> -	sk =3D sk_head(&udptable[udp_hashfn(net, ntohs(uh->dest))]);
> +	spin_lock(&hslot->lock);
> +	sk =3D sk_head(&hslot->head);
>  	dif =3D inet6_iif(skb);
>  	sk =3D udp_v6_mcast_next(sk, uh->dest, daddr, uh->source, saddr, di=
f);
>  	if (!sk) {
> @@ -409,7 +445,7 @@ static int __udp6_lib_mcast_deliver(struct net *n=
et, struct sk_buff *skb,
>  		sk_add_backlog(sk, skb);
>  	bh_unlock_sock(sk);
>  out:
> -	read_unlock(&udp_hash_lock);
> +	spin_unlock(&hslot->lock);
>  	return 0;
>  }
> =20
> @@ -447,7 +483,7 @@ static inline int udp6_csum_init(struct sk_buff *=
skb, struct udphdr *uh,
>  	return 0;
>  }
> =20
> -int __udp6_lib_rcv(struct sk_buff *skb, struct hlist_head udptable[]=
,
> +int __udp6_lib_rcv(struct sk_buff *skb, struct udp_table *udptable,
>  		   int proto)
>  {
>  	struct sock *sk;
> @@ -544,7 +580,7 @@ discard:
> =20
>  static __inline__ int udpv6_rcv(struct sk_buff *skb)
>  {
> -	return __udp6_lib_rcv(skb, udp_hash, IPPROTO_UDP);
> +	return __udp6_lib_rcv(skb, &udp_table, IPPROTO_UDP);
>  }
> =20
>  /*
> @@ -1008,7 +1044,7 @@ int udp6_seq_show(struct seq_file *seq, void *v=
)
>  static struct udp_seq_afinfo udp6_seq_afinfo =3D {
>  	.name		=3D "udp6",
>  	.family		=3D AF_INET6,
> -	.hashtable	=3D udp_hash,
> +	.udp_table	=3D &udp_table,
>  	.seq_fops	=3D {
>  		.owner	=3D	THIS_MODULE,
>  	},
> @@ -1050,7 +1086,8 @@ struct proto udpv6_prot =3D {
>  	.sysctl_wmem	   =3D &sysctl_udp_wmem_min,
>  	.sysctl_rmem	   =3D &sysctl_udp_rmem_min,
>  	.obj_size	   =3D sizeof(struct udp6_sock),
> -	.h.udp_hash	   =3D udp_hash,
> +	.slab_flags	   =3D SLAB_DESTROY_BY_RCU,
> +	.h.udp_table	   =3D &udp_table,
>  #ifdef CONFIG_COMPAT
>  	.compat_setsockopt =3D compat_udpv6_setsockopt,
>  	.compat_getsockopt =3D compat_udpv6_getsockopt,
> diff --git a/net/ipv6/udp_impl.h b/net/ipv6/udp_impl.h
> index 92dd7da..2377920 100644
> --- a/net/ipv6/udp_impl.h
> +++ b/net/ipv6/udp_impl.h
> @@ -7,9 +7,9 @@
>  #include <net/inet_common.h>
>  #include <net/transp_v6.h>
> =20
> -extern int  	__udp6_lib_rcv(struct sk_buff *, struct hlist_head [], =
int );
> +extern int  	__udp6_lib_rcv(struct sk_buff *, struct udp_table *, in=
t );
>  extern void 	__udp6_lib_err(struct sk_buff *, struct inet6_skb_parm =
*,
> -			       int , int , int , __be32 , struct hlist_head []);
> +			       int , int , int , __be32 , struct udp_table *);
> =20
>  extern int	udp_v6_get_port(struct sock *sk, unsigned short snum);
> =20
> diff --git a/net/ipv6/udplite.c b/net/ipv6/udplite.c
> index 3cd1a1a..05ab176 100644
> --- a/net/ipv6/udplite.c
> +++ b/net/ipv6/udplite.c
> @@ -15,14 +15,14 @@
> =20
>  static int udplitev6_rcv(struct sk_buff *skb)
>  {
> -	return __udp6_lib_rcv(skb, udplite_hash, IPPROTO_UDPLITE);
> +	return __udp6_lib_rcv(skb, &udplite_table, IPPROTO_UDPLITE);
>  }
> =20
>  static void udplitev6_err(struct sk_buff *skb,
>  			  struct inet6_skb_parm *opt,
>  			  int type, int code, int offset, __be32 info)
>  {
> -	__udp6_lib_err(skb, opt, type, code, offset, info, udplite_hash);
> +	__udp6_lib_err(skb, opt, type, code, offset, info, &udplite_table);
>  }
> =20
>  static struct inet6_protocol udplitev6_protocol =3D {
> @@ -49,7 +49,8 @@ struct proto udplitev6_prot =3D {
>  	.unhash		   =3D udp_lib_unhash,
>  	.get_port	   =3D udp_v6_get_port,
>  	.obj_size	   =3D sizeof(struct udp6_sock),
> -	.h.udp_hash	   =3D udplite_hash,
> + 	.slab_flags	   =3D SLAB_DESTROY_BY_RCU,
> +	.h.udp_table	   =3D &udplite_table,
>  #ifdef CONFIG_COMPAT
>  	.compat_setsockopt =3D compat_udpv6_setsockopt,
>  	.compat_getsockopt =3D compat_udpv6_getsockopt,
> @@ -95,7 +96,7 @@ void udplitev6_exit(void)
>  static struct udp_seq_afinfo udplite6_seq_afinfo =3D {
>  	.name		=3D "udplite6",
>  	.family		=3D AF_INET6,
> -	.hashtable	=3D udplite_hash,
> +	.udp_table	=3D &udplite_table,
>  	.seq_fops	=3D {
>  		.owner	=3D	THIS_MODULE,
>  	},
