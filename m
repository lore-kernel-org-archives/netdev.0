From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH 2/3] udp: Use hlist_nulls in UDP RCU code
Date: Wed, 19 Nov 2008 09:29:10 -0800
Message-ID: <20081119172910.GC6753@linux.vnet.ibm.com>
References: <20081029163739.GB6732@linux.vnet.ibm.com> <49089BE5.3090705@acm.org> <4908A134.4040705@cosmosbay.com> <4908AB3F.1060003@acm.org> <20081029185200.GE6732@linux.vnet.ibm.com> <4908C0CD.5050406@cosmosbay.com> <20081029201759.GF6732@linux.vnet.ibm.com> <4908DEDE.5030706@cosmosbay.com> <4909D551.9080309@cosmosbay.com> <491C2867.5030807@cosmosbay.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Corey Minyard <minyard@acm.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	benny+usenet@amorsen.dk,
	Linux Netdev List <netdev@vger.kernel.org>,
	Christoph Lameter <cl@linux-foundation.org>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	Christian Bell <christian@myri.com>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e8.ny.us.ibm.com ([32.97.182.138]:54623 "EHLO e8.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751671AbYKSR3d (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Nov 2008 12:29:33 -0500
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e8.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id mAJHP5eR008484
	for <netdev@vger.kernel.org>; Wed, 19 Nov 2008 12:25:05 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id mAJHTCcd141000
	for <netdev@vger.kernel.org>; Wed, 19 Nov 2008 12:29:12 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id mAJITGUo011634
	for <netdev@vger.kernel.org>; Wed, 19 Nov 2008 13:29:18 -0500
Content-Disposition: inline
In-Reply-To: <491C2867.5030807@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 13, 2008 at 02:15:19PM +0100, Eric Dumazet wrote:
> This is a straightforward patch, using hlist_nulls infrastructure.
>
> RCUification already done on UDP two weeks ago.
>
> Using hlist_nulls permits us to avoid some memory barriers, both
> at lookup time and delete time.
>
> Patch is large because it adds new macros to include/net/sock.h.
> These macros will be used by TCP & DCCP in next patch.

Looks good, one question below about the lockless searches.  If the
answer is that the search must complete undisturbed by deletions and
additions, then:

Reviewed-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>

> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
> ---
> include/linux/rculist.h |   17 -----------
> include/net/sock.h      |   57 ++++++++++++++++++++++++++++++--------
> include/net/udp.h       |    2 -
> net/ipv4/udp.c          |   47 ++++++++++++++-----------------
> net/ipv6/udp.c          |   26 +++++++++--------
> 5 files changed, 83 insertions(+), 66 deletions(-)
>

> diff --git a/include/linux/rculist.h b/include/linux/rculist.h
> index 3ba2998..e649bd3 100644
> --- a/include/linux/rculist.h
> +++ b/include/linux/rculist.h
> @@ -383,22 +383,5 @@ static inline void hlist_add_after_rcu(struct hlist_node *prev,
>  		({ tpos = hlist_entry(pos, typeof(*tpos), member); 1; }); \
>  		pos = rcu_dereference(pos->next))
> 
> -/**
> - * hlist_for_each_entry_rcu_safenext - iterate over rcu list of given type
> - * @tpos:	the type * to use as a loop cursor.
> - * @pos:	the &struct hlist_node to use as a loop cursor.
> - * @head:	the head for your list.
> - * @member:	the name of the hlist_node within the struct.
> - * @next:       the &struct hlist_node to use as a next cursor
> - *
> - * Special version of hlist_for_each_entry_rcu that make sure
> - * each next pointer is fetched before each iteration.
> - */
> -#define hlist_for_each_entry_rcu_safenext(tpos, pos, head, member, next) \
> -	for (pos = rcu_dereference((head)->first);			 \
> -		pos && ({ next = pos->next; smp_rmb(); prefetch(next); 1; }) &&	\
> -		({ tpos = hlist_entry(pos, typeof(*tpos), member); 1; }); \
> -		pos = rcu_dereference(next))
> -

Bonus points for getting rid of a list primitive!!!  ;-)

>  #endif	/* __KERNEL__ */
>  #endif
> diff --git a/include/net/sock.h b/include/net/sock.h
> index 8b2b821..0a63894 100644
> --- a/include/net/sock.h
> +++ b/include/net/sock.h
> @@ -42,6 +42,7 @@
> 
>  #include <linux/kernel.h>
>  #include <linux/list.h>
> +#include <linux/list_nulls.h>
>  #include <linux/timer.h>
>  #include <linux/cache.h>
>  #include <linux/module.h>
> @@ -52,6 +53,7 @@
>  #include <linux/security.h>
> 
>  #include <linux/filter.h>
> +#include <linux/rculist_nulls.h>
> 
>  #include <asm/atomic.h>
>  #include <net/dst.h>
> @@ -106,6 +108,7 @@ struct net;
>   *	@skc_reuse: %SO_REUSEADDR setting
>   *	@skc_bound_dev_if: bound device index if != 0
>   *	@skc_node: main hash linkage for various protocol lookup tables
> + *	@skc_nulls_node: main hash linkage for UDP/UDP-Lite protocol
>   *	@skc_bind_node: bind hash linkage for various protocol lookup tables
>   *	@skc_refcnt: reference count
>   *	@skc_hash: hash value used with various protocol lookup tables
> @@ -120,7 +123,10 @@ struct sock_common {
>  	volatile unsigned char	skc_state;
>  	unsigned char		skc_reuse;
>  	int			skc_bound_dev_if;
> -	struct hlist_node	skc_node;
> +	union {
> +		struct hlist_node	skc_node;
> +		struct hlist_nulls_node skc_nulls_node;
> +	};
>  	struct hlist_node	skc_bind_node;
>  	atomic_t		skc_refcnt;
>  	unsigned int		skc_hash;
> @@ -206,6 +212,7 @@ struct sock {
>  #define sk_reuse		__sk_common.skc_reuse
>  #define sk_bound_dev_if		__sk_common.skc_bound_dev_if
>  #define sk_node			__sk_common.skc_node
> +#define sk_nulls_node		__sk_common.skc_nulls_node
>  #define sk_bind_node		__sk_common.skc_bind_node
>  #define sk_refcnt		__sk_common.skc_refcnt
>  #define sk_hash			__sk_common.skc_hash
> @@ -300,12 +307,30 @@ static inline struct sock *sk_head(const struct hlist_head *head)
>  	return hlist_empty(head) ? NULL : __sk_head(head);
>  }
> 
> +static inline struct sock *__sk_nulls_head(const struct hlist_nulls_head *head)
> +{
> +	return hlist_nulls_entry(head->first, struct sock, sk_nulls_node);
> +}
> +
> +static inline struct sock *sk_nulls_head(const struct hlist_nulls_head *head)
> +{
> +	return hlist_nulls_empty(head) ? NULL : __sk_nulls_head(head);
> +}
> +
>  static inline struct sock *sk_next(const struct sock *sk)
>  {
>  	return sk->sk_node.next ?
>  		hlist_entry(sk->sk_node.next, struct sock, sk_node) : NULL;
>  }
> 
> +static inline struct sock *sk_nulls_next(const struct sock *sk)
> +{
> +	return (!is_a_nulls(sk->sk_nulls_node.next)) ?
> +		hlist_nulls_entry(sk->sk_nulls_node.next,
> +				  struct sock, sk_nulls_node) :
> +		NULL;
> +}
> +
>  static inline int sk_unhashed(const struct sock *sk)
>  {
>  	return hlist_unhashed(&sk->sk_node);
> @@ -321,6 +346,11 @@ static __inline__ void sk_node_init(struct hlist_node *node)
>  	node->pprev = NULL;
>  }
> 
> +static __inline__ void sk_nulls_node_init(struct hlist_nulls_node *node)
> +{
> +	node->pprev = NULL;
> +}
> +
>  static __inline__ void __sk_del_node(struct sock *sk)
>  {
>  	__hlist_del(&sk->sk_node);
> @@ -367,18 +397,18 @@ static __inline__ int sk_del_node_init(struct sock *sk)
>  	return rc;
>  }
> 
> -static __inline__ int __sk_del_node_init_rcu(struct sock *sk)
> +static __inline__ int __sk_nulls_del_node_init_rcu(struct sock *sk)
>  {
>  	if (sk_hashed(sk)) {
> -		hlist_del_init_rcu(&sk->sk_node);
> +		hlist_nulls_del_init_rcu(&sk->sk_nulls_node);
>  		return 1;
>  	}
>  	return 0;
>  }
> 
> -static __inline__ int sk_del_node_init_rcu(struct sock *sk)
> +static __inline__ int sk_nulls_del_node_init_rcu(struct sock *sk)
>  {
> -	int rc = __sk_del_node_init_rcu(sk);
> +	int rc = __sk_nulls_del_node_init_rcu(sk);
> 
>  	if (rc) {
>  		/* paranoid for a while -acme */
> @@ -399,15 +429,15 @@ static __inline__ void sk_add_node(struct sock *sk, struct hlist_head *list)
>  	__sk_add_node(sk, list);
>  }
> 
> -static __inline__ void __sk_add_node_rcu(struct sock *sk, struct hlist_head *list)
> +static __inline__ void __sk_nulls_add_node_rcu(struct sock *sk, struct hlist_nulls_head *list)
>  {
> -	hlist_add_head_rcu(&sk->sk_node, list);
> +	hlist_nulls_add_head_rcu(&sk->sk_nulls_node, list);
>  }
> 
> -static __inline__ void sk_add_node_rcu(struct sock *sk, struct hlist_head *list)
> +static __inline__ void sk_nulls_add_node_rcu(struct sock *sk, struct hlist_nulls_head *list)
>  {
>  	sock_hold(sk);
> -	__sk_add_node_rcu(sk, list);
> +	__sk_nulls_add_node_rcu(sk, list);
>  }
> 
>  static __inline__ void __sk_del_bind_node(struct sock *sk)
> @@ -423,11 +453,16 @@ static __inline__ void sk_add_bind_node(struct sock *sk,
> 
>  #define sk_for_each(__sk, node, list) \
>  	hlist_for_each_entry(__sk, node, list, sk_node)
> -#define sk_for_each_rcu_safenext(__sk, node, list, next) \
> -	hlist_for_each_entry_rcu_safenext(__sk, node, list, sk_node, next)
> +#define sk_nulls_for_each(__sk, node, list) \
> +	hlist_nulls_for_each_entry(__sk, node, list, sk_nulls_node)
> +#define sk_nulls_for_each_rcu(__sk, node, list) \
> +	hlist_nulls_for_each_entry_rcu(__sk, node, list, sk_nulls_node)
>  #define sk_for_each_from(__sk, node) \
>  	if (__sk && ({ node = &(__sk)->sk_node; 1; })) \
>  		hlist_for_each_entry_from(__sk, node, sk_node)
> +#define sk_nulls_for_each_from(__sk, node) \
> +	if (__sk && ({ node = &(__sk)->sk_nulls_node; 1; })) \
> +		hlist_nulls_for_each_entry_from(__sk, node, sk_nulls_node)
>  #define sk_for_each_continue(__sk, node) \
>  	if (__sk && ({ node = &(__sk)->sk_node; 1; })) \
>  		hlist_for_each_entry_continue(__sk, node, sk_node)
> diff --git a/include/net/udp.h b/include/net/udp.h
> index df2bfe5..90e6ce5 100644
> --- a/include/net/udp.h
> +++ b/include/net/udp.h
> @@ -51,7 +51,7 @@ struct udp_skb_cb {
>  #define UDP_SKB_CB(__skb)	((struct udp_skb_cb *)((__skb)->cb))
> 
>  struct udp_hslot {
> -	struct hlist_head	head;
> +	struct hlist_nulls_head	head;
>  	spinlock_t		lock;
>  } __attribute__((aligned(2 * sizeof(long))));
>  struct udp_table {
> diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
> index 54badc9..fea2d87 100644
> --- a/net/ipv4/udp.c
> +++ b/net/ipv4/udp.c
> @@ -127,9 +127,9 @@ static int udp_lib_lport_inuse(struct net *net, __u16 num,
>  						 const struct sock *sk2))
>  {
>  	struct sock *sk2;
> -	struct hlist_node *node;
> +	struct hlist_nulls_node *node;
> 
> -	sk_for_each(sk2, node, &hslot->head)
> +	sk_nulls_for_each(sk2, node, &hslot->head)
>  		if (net_eq(sock_net(sk2), net)			&&
>  		    sk2 != sk					&&
>  		    sk2->sk_hash == num				&&
> @@ -189,12 +189,7 @@ int udp_lib_get_port(struct sock *sk, unsigned short snum,
>  	inet_sk(sk)->num = snum;
>  	sk->sk_hash = snum;
>  	if (sk_unhashed(sk)) {
> -		/*
> -		 * We need that previous write to sk->sk_hash committed
> -		 * before write to sk->next done in following add_node() variant
> -		 */
> -		smp_wmb();
> -		sk_add_node_rcu(sk, &hslot->head);
> +		sk_nulls_add_node_rcu(sk, &hslot->head);
>  		sock_prot_inuse_add(sock_net(sk), sk->sk_prot, 1);
>  	}
>  	error = 0;
> @@ -261,7 +256,7 @@ static struct sock *__udp4_lib_lookup(struct net *net, __be32 saddr,
>  		int dif, struct udp_table *udptable)
>  {
>  	struct sock *sk, *result;
> -	struct hlist_node *node, *next;
> +	struct hlist_nulls_node *node;
>  	unsigned short hnum = ntohs(dport);
>  	unsigned int hash = udp_hashfn(net, hnum);
>  	struct udp_hslot *hslot = &udptable->hash[hash];
> @@ -271,13 +266,7 @@ static struct sock *__udp4_lib_lookup(struct net *net, __be32 saddr,
>  begin:
>  	result = NULL;
>  	badness = -1;
> -	sk_for_each_rcu_safenext(sk, node, &hslot->head, next) {
> -		/*
> -		 * lockless reader, and SLAB_DESTROY_BY_RCU items:
> -		 * We must check this item was not moved to another chain
> -		 */
> -		if (udp_hashfn(net, sk->sk_hash) != hash)
> -			goto begin;
> +	sk_nulls_for_each_rcu(sk, node, &hslot->head) {
>  		score = compute_score(sk, net, saddr, hnum, sport,
>  				      daddr, dport, dif);
>  		if (score > badness) {
> @@ -285,6 +274,14 @@ begin:
>  			badness = score;
>  		}
>  	}
> +	/*
> +	 * if the nulls value we got at the end of this lookup is
> +	 * not the expected one, we must restart lookup.
> +	 * We probably met an item that was moved to another chain.
> +	 */
> +	if (get_nulls_value(node) != hash)
> +		goto begin;
> +

Shouldn't this check go -after- the check for "result"?  Or is this a
case where the readers absolutely must have traversed a chain without
modification to be guaranteed of finding the correct result?

>  	if (result) {
>  		if (unlikely(!atomic_inc_not_zero(&result->sk_refcnt)))
>  			result = NULL;
> @@ -325,11 +322,11 @@ static inline struct sock *udp_v4_mcast_next(struct net *net, struct sock *sk,
>  					     __be16 rmt_port, __be32 rmt_addr,
>  					     int dif)
>  {
> -	struct hlist_node *node;
> +	struct hlist_nulls_node *node;
>  	struct sock *s = sk;
>  	unsigned short hnum = ntohs(loc_port);
> 
> -	sk_for_each_from(s, node) {
> +	sk_nulls_for_each_from(s, node) {
>  		struct inet_sock *inet = inet_sk(s);
> 
>  		if (!net_eq(sock_net(s), net)				||
> @@ -977,7 +974,7 @@ void udp_lib_unhash(struct sock *sk)
>  	struct udp_hslot *hslot = &udptable->hash[hash];
> 
>  	spin_lock_bh(&hslot->lock);
> -	if (sk_del_node_init_rcu(sk)) {
> +	if (sk_nulls_del_node_init_rcu(sk)) {
>  		inet_sk(sk)->num = 0;
>  		sock_prot_inuse_add(sock_net(sk), sk->sk_prot, -1);
>  	}
> @@ -1130,7 +1127,7 @@ static int __udp4_lib_mcast_deliver(struct net *net, struct sk_buff *skb,
>  	int dif;
> 
>  	spin_lock(&hslot->lock);
> -	sk = sk_head(&hslot->head);
> +	sk = sk_nulls_head(&hslot->head);
>  	dif = skb->dev->ifindex;
>  	sk = udp_v4_mcast_next(net, sk, uh->dest, daddr, uh->source, saddr, dif);
>  	if (sk) {
> @@ -1139,7 +1136,7 @@ static int __udp4_lib_mcast_deliver(struct net *net, struct sk_buff *skb,
>  		do {
>  			struct sk_buff *skb1 = skb;
> 
> -			sknext = udp_v4_mcast_next(net, sk_next(sk), uh->dest,
> +			sknext = udp_v4_mcast_next(net, sk_nulls_next(sk), uh->dest,
>  						   daddr, uh->source, saddr,
>  						   dif);
>  			if (sknext)
> @@ -1560,10 +1557,10 @@ static struct sock *udp_get_first(struct seq_file *seq, int start)
>  	struct net *net = seq_file_net(seq);
> 
>  	for (state->bucket = start; state->bucket < UDP_HTABLE_SIZE; ++state->bucket) {
> -		struct hlist_node *node;
> +		struct hlist_nulls_node *node;
>  		struct udp_hslot *hslot = &state->udp_table->hash[state->bucket];
>  		spin_lock_bh(&hslot->lock);
> -		sk_for_each(sk, node, &hslot->head) {
> +		sk_nulls_for_each(sk, node, &hslot->head) {
>  			if (!net_eq(sock_net(sk), net))
>  				continue;
>  			if (sk->sk_family == state->family)
> @@ -1582,7 +1579,7 @@ static struct sock *udp_get_next(struct seq_file *seq, struct sock *sk)
>  	struct net *net = seq_file_net(seq);
> 
>  	do {
> -		sk = sk_next(sk);
> +		sk = sk_nulls_next(sk);
>  	} while (sk && (!net_eq(sock_net(sk), net) || sk->sk_family != state->family));
> 
>  	if (!sk) {
> @@ -1753,7 +1750,7 @@ void __init udp_table_init(struct udp_table *table)
>  	int i;
> 
>  	for (i = 0; i < UDP_HTABLE_SIZE; i++) {
> -		INIT_HLIST_HEAD(&table->hash[i].head);
> +		INIT_HLIST_NULLS_HEAD(&table->hash[i].head, i);
>  		spin_lock_init(&table->hash[i].lock);
>  	}
>  }
> diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
> index 8dafa36..fd2d9ad 100644
> --- a/net/ipv6/udp.c
> +++ b/net/ipv6/udp.c
> @@ -98,7 +98,7 @@ static struct sock *__udp6_lib_lookup(struct net *net,
>  				      int dif, struct udp_table *udptable)
>  {
>  	struct sock *sk, *result;
> -	struct hlist_node *node, *next;
> +	struct hlist_nulls_node *node;
>  	unsigned short hnum = ntohs(dport);
>  	unsigned int hash = udp_hashfn(net, hnum);
>  	struct udp_hslot *hslot = &udptable->hash[hash];
> @@ -108,19 +108,21 @@ static struct sock *__udp6_lib_lookup(struct net *net,
>  begin:
>  	result = NULL;
>  	badness = -1;
> -	sk_for_each_rcu_safenext(sk, node, &hslot->head, next) {
> -		/*
> -		 * lockless reader, and SLAB_DESTROY_BY_RCU items:
> -		 * We must check this item was not moved to another chain
> -		 */
> -		if (udp_hashfn(net, sk->sk_hash) != hash)
> -			goto begin;
> +	sk_nulls_for_each_rcu(sk, node, &hslot->head) {
>  		score = compute_score(sk, net, hnum, saddr, sport, daddr, dport, dif);
>  		if (score > badness) {
>  			result = sk;
>  			badness = score;
>  		}
>  	}
> +	/*
> +	 * if the nulls value we got at the end of this lookup is
> +	 * not the expected one, we must restart lookup.
> +	 * We probably met an item that was moved to another chain.
> +	 */
> +	if (get_nulls_value(node) != hash)
> +		goto begin;
> +

Same question as before...

>  	if (result) {
>  		if (unlikely(!atomic_inc_not_zero(&result->sk_refcnt)))
>  			result = NULL;
> @@ -374,11 +376,11 @@ static struct sock *udp_v6_mcast_next(struct net *net, struct sock *sk,
>  				      __be16 rmt_port, struct in6_addr *rmt_addr,
>  				      int dif)
>  {
> -	struct hlist_node *node;
> +	struct hlist_nulls_node *node;
>  	struct sock *s = sk;
>  	unsigned short num = ntohs(loc_port);
> 
> -	sk_for_each_from(s, node) {
> +	sk_nulls_for_each_from(s, node) {
>  		struct inet_sock *inet = inet_sk(s);
> 
>  		if (!net_eq(sock_net(s), net))
> @@ -423,7 +425,7 @@ static int __udp6_lib_mcast_deliver(struct net *net, struct sk_buff *skb,
>  	int dif;
> 
>  	spin_lock(&hslot->lock);
> -	sk = sk_head(&hslot->head);
> +	sk = sk_nulls_head(&hslot->head);
>  	dif = inet6_iif(skb);
>  	sk = udp_v6_mcast_next(net, sk, uh->dest, daddr, uh->source, saddr, dif);
>  	if (!sk) {
> @@ -432,7 +434,7 @@ static int __udp6_lib_mcast_deliver(struct net *net, struct sk_buff *skb,
>  	}
> 
>  	sk2 = sk;
> -	while ((sk2 = udp_v6_mcast_next(net, sk_next(sk2), uh->dest, daddr,
> +	while ((sk2 = udp_v6_mcast_next(net, sk_nulls_next(sk2), uh->dest, daddr,
>  					uh->source, saddr, dif))) {
>  		struct sk_buff *buff = skb_clone(skb, GFP_ATOMIC);
>  		if (buff) {

