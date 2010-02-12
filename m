From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH tip/core/rcu 05/13] net: add checking to
 rcu_dereference() primitives
Date: Fri, 12 Feb 2010 05:15:52 +0100
Message-ID: <1265948152.2891.25.camel@edumazet-laptop>
References: <20100212000016.GA25781@linux.vnet.ibm.com>
	 <1265932839-25899-5-git-send-email-paulmck@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, mingo@elte.hu, laijs@cn.fujitsu.com,
	dipankar@in.ibm.com, akpm@linux-foundation.org,
	mathieu.desnoyers@polymtl.ca, josh@joshtriplett.org,
	dvhltc@us.ibm.com, niv@us.ibm.com, tglx@linutronix.de,
	peterz@infradead.org, rostedt@goodmis.org, Valdis.Kletnieks@vt.edu,
	dhowells@redhat.com, David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1265932839-25899-5-git-send-email-paulmck@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le jeudi 11 f=C3=A9vrier 2010 =C3=A0 16:00 -0800, Paul E. McKenney a =C3=
=A9crit :
> Update rcu_dereference() primitives to use new lockdep-based checking=
=2E
> The rcu_dereference() in __in6_dev_get() may be protected either by
> rcu_read_lock() or RTNL, per Eric Dumazet.  The rcu_dereference()
> in __sk_free() is protected by the fact that it is never reached if a=
n
> update could change it.  Check for this by using rcu_dereference_chec=
k()
> to verify that the struct sock's ->sk_wmem_alloc counter is zero.
>=20
> Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>

CC to netdev and David Miller, network maintainer.

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Thanks Paul, great work !

> ---
>  include/linux/rtnetlink.h |    3 +++
>  include/net/addrconf.h    |    4 +++-
>  net/core/dev.c            |    2 +-
>  net/core/filter.c         |    6 +++---
>  net/core/rtnetlink.c      |    8 ++++++++
>  net/core/sock.c           |    3 ++-
>  net/decnet/dn_route.c     |   14 +++++++-------
>  net/ipv4/route.c          |   14 +++++++-------
>  net/packet/af_packet.c    |    2 +-
>  9 files changed, 35 insertions(+), 21 deletions(-)
>=20
> diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
> index 05330fc..5c52fa4 100644
> --- a/include/linux/rtnetlink.h
> +++ b/include/linux/rtnetlink.h
> @@ -735,6 +735,9 @@ extern void rtnl_lock(void);
>  extern void rtnl_unlock(void);
>  extern int rtnl_trylock(void);
>  extern int rtnl_is_locked(void);
> +#ifdef CONFIG_PROVE_LOCKING
> +extern int lockdep_rtnl_is_held(void);
> +#endif /* #ifdef CONFIG_PROVE_LOCKING */
> =20
>  extern void rtnetlink_init(void);
>  extern void __rtnl_unlock(void);
> diff --git a/include/net/addrconf.h b/include/net/addrconf.h
> index 0f7c378..45375b4 100644
> --- a/include/net/addrconf.h
> +++ b/include/net/addrconf.h
> @@ -177,7 +177,9 @@ extern int unregister_inet6addr_notifier(struct n=
otifier_block *nb);
>  static inline struct inet6_dev *
>  __in6_dev_get(struct net_device *dev)
>  {
> -	return rcu_dereference(dev->ip6_ptr);
> +	return rcu_dereference_check(dev->ip6_ptr,
> +				     rcu_read_lock_held() ||
> +				     lockdep_rtnl_is_held());
>  }
> =20
>  static inline struct inet6_dev *
> diff --git a/net/core/dev.c b/net/core/dev.c
> index be9924f..0d0ff82 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -2041,7 +2041,7 @@ gso:
>  	rcu_read_lock_bh();
> =20
>  	txq =3D dev_pick_tx(dev, skb);
> -	q =3D rcu_dereference(txq->qdisc);
> +	q =3D rcu_dereference_bh(txq->qdisc);
> =20
>  #ifdef CONFIG_NET_CLS_ACT
>  	skb->tc_verd =3D SET_TC_AT(skb->tc_verd, AT_EGRESS);
> diff --git a/net/core/filter.c b/net/core/filter.c
> index 08db7b9..3541aa4 100644
> --- a/net/core/filter.c
> +++ b/net/core/filter.c
> @@ -86,7 +86,7 @@ int sk_filter(struct sock *sk, struct sk_buff *skb)
>  		return err;
> =20
>  	rcu_read_lock_bh();
> -	filter =3D rcu_dereference(sk->sk_filter);
> +	filter =3D rcu_dereference_bh(sk->sk_filter);
>  	if (filter) {
>  		unsigned int pkt_len =3D sk_run_filter(skb, filter->insns,
>  				filter->len);
> @@ -521,7 +521,7 @@ int sk_attach_filter(struct sock_fprog *fprog, st=
ruct sock *sk)
>  	}
> =20
>  	rcu_read_lock_bh();
> -	old_fp =3D rcu_dereference(sk->sk_filter);
> +	old_fp =3D rcu_dereference_bh(sk->sk_filter);
>  	rcu_assign_pointer(sk->sk_filter, fp);
>  	rcu_read_unlock_bh();
> =20
> @@ -536,7 +536,7 @@ int sk_detach_filter(struct sock *sk)
>  	struct sk_filter *filter;
> =20
>  	rcu_read_lock_bh();
> -	filter =3D rcu_dereference(sk->sk_filter);
> +	filter =3D rcu_dereference_bh(sk->sk_filter);
>  	if (filter) {
>  		rcu_assign_pointer(sk->sk_filter, NULL);
>  		sk_filter_delayed_uncharge(sk, filter);
> diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
> index 794bcb8..4c7d3f6 100644
> --- a/net/core/rtnetlink.c
> +++ b/net/core/rtnetlink.c
> @@ -89,6 +89,14 @@ int rtnl_is_locked(void)
>  }
>  EXPORT_SYMBOL(rtnl_is_locked);
> =20
> +#ifdef CONFIG_PROVE_LOCKING
> +int lockdep_rtnl_is_held(void)
> +{
> +	return lockdep_is_held(&rtnl_mutex);
> +}
> +EXPORT_SYMBOL(lockdep_rtnl_is_held);
> +#endif /* #ifdef CONFIG_PROVE_LOCKING */
> +
>  static struct rtnl_link *rtnl_msg_handlers[NPROTO];
> =20
>  static inline int rtm_msgindex(int msgtype)
> diff --git a/net/core/sock.c b/net/core/sock.c
> index e1f6f22..305cba4 100644
> --- a/net/core/sock.c
> +++ b/net/core/sock.c
> @@ -1073,7 +1073,8 @@ static void __sk_free(struct sock *sk)
>  	if (sk->sk_destruct)
>  		sk->sk_destruct(sk);
> =20
> -	filter =3D rcu_dereference(sk->sk_filter);
> +	filter =3D rcu_dereference_check(sk->sk_filter,
> +				       atomic_read(&sk->sk_wmem_alloc) =3D=3D 0);
>  	if (filter) {
>  		sk_filter_uncharge(sk, filter);
>  		rcu_assign_pointer(sk->sk_filter, NULL);
> diff --git a/net/decnet/dn_route.c b/net/decnet/dn_route.c
> index a032840..a7bf03c 100644
> --- a/net/decnet/dn_route.c
> +++ b/net/decnet/dn_route.c
> @@ -1155,8 +1155,8 @@ static int __dn_route_output_key(struct dst_ent=
ry **pprt, const struct flowi *fl
> =20
>  	if (!(flags & MSG_TRYHARD)) {
>  		rcu_read_lock_bh();
> -		for(rt =3D rcu_dereference(dn_rt_hash_table[hash].chain); rt;
> -			rt =3D rcu_dereference(rt->u.dst.dn_next)) {
> +		for (rt =3D rcu_dereference_bh(dn_rt_hash_table[hash].chain); rt;
> +			rt =3D rcu_dereference_bh(rt->u.dst.dn_next)) {
>  			if ((flp->fld_dst =3D=3D rt->fl.fld_dst) &&
>  			    (flp->fld_src =3D=3D rt->fl.fld_src) &&
>  			    (flp->mark =3D=3D rt->fl.mark) &&
> @@ -1618,9 +1618,9 @@ int dn_cache_dump(struct sk_buff *skb, struct n=
etlink_callback *cb)
>  		if (h > s_h)
>  			s_idx =3D 0;
>  		rcu_read_lock_bh();
> -		for(rt =3D rcu_dereference(dn_rt_hash_table[h].chain), idx =3D 0;
> +		for(rt =3D rcu_dereference_bh(dn_rt_hash_table[h].chain), idx =3D =
0;
>  			rt;
> -			rt =3D rcu_dereference(rt->u.dst.dn_next), idx++) {
> +			rt =3D rcu_dereference_bh(rt->u.dst.dn_next), idx++) {
>  			if (idx < s_idx)
>  				continue;
>  			skb_dst_set(skb, dst_clone(&rt->u.dst));
> @@ -1654,12 +1654,12 @@ static struct dn_route *dn_rt_cache_get_first=
(struct seq_file *seq)
> =20
>  	for(s->bucket =3D dn_rt_hash_mask; s->bucket >=3D 0; --s->bucket) {
>  		rcu_read_lock_bh();
> -		rt =3D dn_rt_hash_table[s->bucket].chain;
> +		rt =3D rcu_dereference_bh(dn_rt_hash_table[s->bucket].chain);
>  		if (rt)
>  			break;
>  		rcu_read_unlock_bh();
>  	}
> -	return rcu_dereference(rt);
> +	return rt;
>  }
> =20
>  static struct dn_route *dn_rt_cache_get_next(struct seq_file *seq, s=
truct dn_route *rt)
> @@ -1674,7 +1674,7 @@ static struct dn_route *dn_rt_cache_get_next(st=
ruct seq_file *seq, struct dn_rou
>  		rcu_read_lock_bh();
>  		rt =3D dn_rt_hash_table[s->bucket].chain;
>  	}
> -	return rcu_dereference(rt);
> +	return rcu_dereference_bh(rt);
>  }
> =20
>  static void *dn_rt_cache_seq_start(struct seq_file *seq, loff_t *pos=
)
> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> index e446496..3476b3b 100644
> --- a/net/ipv4/route.c
> +++ b/net/ipv4/route.c
> @@ -287,12 +287,12 @@ static struct rtable *rt_cache_get_first(struct=
 seq_file *seq)
>  		if (!rt_hash_table[st->bucket].chain)
>  			continue;
>  		rcu_read_lock_bh();
> -		r =3D rcu_dereference(rt_hash_table[st->bucket].chain);
> +		r =3D rcu_dereference_bh(rt_hash_table[st->bucket].chain);
>  		while (r) {
>  			if (dev_net(r->u.dst.dev) =3D=3D seq_file_net(seq) &&
>  			    r->rt_genid =3D=3D st->genid)
>  				return r;
> -			r =3D rcu_dereference(r->u.dst.rt_next);
> +			r =3D rcu_dereference_bh(r->u.dst.rt_next);
>  		}
>  		rcu_read_unlock_bh();
>  	}
> @@ -314,7 +314,7 @@ static struct rtable *__rt_cache_get_next(struct =
seq_file *seq,
>  		rcu_read_lock_bh();
>  		r =3D rt_hash_table[st->bucket].chain;
>  	}
> -	return rcu_dereference(r);
> +	return rcu_dereference_bh(r);
>  }
> =20
>  static struct rtable *rt_cache_get_next(struct seq_file *seq,
> @@ -2687,8 +2687,8 @@ int __ip_route_output_key(struct net *net, stru=
ct rtable **rp,
>  	hash =3D rt_hash(flp->fl4_dst, flp->fl4_src, flp->oif, rt_genid(net=
));
> =20
>  	rcu_read_lock_bh();
> -	for (rth =3D rcu_dereference(rt_hash_table[hash].chain); rth;
> -		rth =3D rcu_dereference(rth->u.dst.rt_next)) {
> +	for (rth =3D rcu_dereference_bh(rt_hash_table[hash].chain); rth;
> +		rth =3D rcu_dereference_bh(rth->u.dst.rt_next)) {
>  		if (rth->fl.fl4_dst =3D=3D flp->fl4_dst &&
>  		    rth->fl.fl4_src =3D=3D flp->fl4_src &&
>  		    rth->fl.iif =3D=3D 0 &&
> @@ -3006,8 +3006,8 @@ int ip_rt_dump(struct sk_buff *skb,  struct net=
link_callback *cb)
>  		if (!rt_hash_table[h].chain)
>  			continue;
>  		rcu_read_lock_bh();
> -		for (rt =3D rcu_dereference(rt_hash_table[h].chain), idx =3D 0; rt=
;
> -		     rt =3D rcu_dereference(rt->u.dst.rt_next), idx++) {
> +		for (rt =3D rcu_dereference_bh(rt_hash_table[h].chain), idx =3D 0;=
 rt;
> +		     rt =3D rcu_dereference_bh(rt->u.dst.rt_next), idx++) {
>  			if (!net_eq(dev_net(rt->u.dst.dev), net) || idx < s_idx)
>  				continue;
>  			if (rt_is_expired(rt))
> diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
> index f126d18..939471e 100644
> --- a/net/packet/af_packet.c
> +++ b/net/packet/af_packet.c
> @@ -508,7 +508,7 @@ static inline unsigned int run_filter(struct sk_b=
uff *skb, struct sock *sk,
>  	struct sk_filter *filter;
> =20
>  	rcu_read_lock_bh();
> -	filter =3D rcu_dereference(sk->sk_filter);
> +	filter =3D rcu_dereference_bh(sk->sk_filter);
>  	if (filter !=3D NULL)
>  		res =3D sk_run_filter(skb, filter->insns, filter->len);
>  	rcu_read_unlock_bh();
