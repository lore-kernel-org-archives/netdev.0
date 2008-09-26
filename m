From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/1] Use RCU for the UDP hash lock
Date: Thu, 25 Sep 2008 21:09:17 -0700
Message-ID: <20080926040917.GB7209@linux.vnet.ibm.com>
References: <20080926031832.GA27289@minyard.local>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, jarkao2@gmail.com, shemminger@vyatta.com
To: Corey Minyard <minyard@acm.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753434AbYIZEJy@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20080926031832.GA27289@minyard.local>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 25, 2008 at 10:18:33PM -0500, Corey Minyard wrote:
> From: Corey Minyard <cminyard@mvista.com>
> 
> Convert access to the udp_hash table to use RCU.

Looks much better!

Some rcu_dereference() fixes, a comment fix, and a question below.

							Thanx, Paul

> Signed-off-by: Corey Minyard <cminyard@mvista.com>
> ---
>  include/linux/rculist.h |   19 +++++++++++++++++
>  include/net/sock.h      |   51 +++++++++++++++++++++++++++++++++++++++++++++++
>  include/net/udp.h       |    9 ++++---
>  net/ipv4/udp.c          |   47 ++++++++++++++++++++++++------------------
>  net/ipv6/udp.c          |   17 ++++++++-------
>  5 files changed, 111 insertions(+), 32 deletions(-)
> 
> This patch is the second try; I believe I fixed all issues that people
> raised.  Thanks to everyone who commented on this.
> 
> I beat on this for a few hours with my test program, too.
> 
> diff --git a/include/linux/rculist.h b/include/linux/rculist.h
> index eb4443c..4d3cc58 100644
> --- a/include/linux/rculist.h
> +++ b/include/linux/rculist.h
> @@ -397,5 +397,24 @@ static inline void hlist_add_after_rcu(struct hlist_node *prev,
>  		({ tpos = hlist_entry(pos, typeof(*tpos), member); 1; }); \
>  		pos = rcu_dereference(pos->next))
> 
> +
> +/**
> + * hlist_for_each_entry_from_rcu - iterate over rcu list starting from pos
> + * @tpos:      the type * to use as a loop cursor.
> + * @pos:       the &struct hlist_node to use as a loop cursor.
> + * @head:      the head for your list.
> + * @member:    the name of the hlist_node within the struct.
> + *
> + * This list-traversal primitive may safely run concurrently with
> + * the _rcu list-mutation primitives such as hlist_add_head_rcu()
> + * as long as the traversal is guarded by rcu_read_lock().
> + */
> +#define hlist_for_each_entry_from_rcu(tpos, pos, member)                \
> +	for (;                                                          \
> +	     rcu_dereference(pos) && ({ prefetch(pos->next); 1; }) &&    \
> +	       ({ tpos = hlist_entry(pos, typeof(*tpos), member); 1; }); \
> +	     pos = pos->next)

Always apply rcu_dereference() to whatever it was that you
rcu_assign_pointer()ed to.  You don't need the first rcu_dereference()
because you (hopefully) used rcu_dereference() either directly or 
indirectly when picking up the pointer in the first place.  You -do-
need one on the ->next, however.

So something like this:

+#define hlist_for_each_entry_from_rcu(tpos, pos, member)                \
+	for (;                                                          \
+	     (pos) && ({ prefetch(pos->next); 1; }) &&    \
+	       ({ tpos = hlist_entry(pos, typeof(*tpos), member); 1; }); \
+	     pos = rcu_dereference((pos)->next))

Interesting, though -- you repeat whatever one you stopped on
previously, unlike the _continue_ variants.

> +
> +
>  #endif	/* __KERNEL__ */
>  #endif
> diff --git a/include/net/sock.h b/include/net/sock.h
> index 06c5259..65110a6 100644
> --- a/include/net/sock.h
> +++ b/include/net/sock.h
> @@ -42,6 +42,7 @@
> 
>  #include <linux/kernel.h>
>  #include <linux/list.h>
> +#include <linux/rculist.h>
>  #include <linux/timer.h>
>  #include <linux/cache.h>
>  #include <linux/module.h>
> @@ -294,12 +295,24 @@ static inline struct sock *sk_head(const struct hlist_head *head)
>  	return hlist_empty(head) ? NULL : __sk_head(head);
>  }
> 
> +static inline struct sock *sk_head_rcu(const struct hlist_head *head)
> +{
> +	struct hlist_node *first = rcu_dereference(head->first);
> +	return first ? hlist_entry(first, struct sock, sk_node) : NULL;
> +}
> +
>  static inline struct sock *sk_next(const struct sock *sk)
>  {
>  	return sk->sk_node.next ?
>  		hlist_entry(sk->sk_node.next, struct sock, sk_node) : NULL;
>  }
> 
> +static inline struct sock *sk_next_rcu(const struct sock *sk)
> +{
> +	struct hlist_node *next = rcu_dereference(sk->sk_node.next);
> +	return next ? hlist_entry(next, struct sock, sk_node) : NULL;
> +}
> +
>  static inline int sk_unhashed(const struct sock *sk)
>  {
>  	return hlist_unhashed(&sk->sk_node);
> @@ -361,6 +374,27 @@ static __inline__ int sk_del_node_init(struct sock *sk)
>  	return rc;
>  }
> 
> +static inline int __sk_del_node_rcu(struct sock *sk)
> +{
> +	if (sk_hashed(sk)) {
> +		hlist_del_rcu(&sk->sk_node);
> +		return 1;
> +	}
> +	return 0;
> +}
> +
> +static inline int sk_del_node_rcu(struct sock *sk)
> +{
> +	int rc = __sk_del_node_rcu(sk);
> +
> +	if (rc) {
> +		/* paranoid for a while -acme */
> +		WARN_ON(atomic_read(&sk->sk_refcnt) == 1);
> +		__sock_put(sk);
> +	}
> +	return rc;
> +}
> +
>  static __inline__ void __sk_add_node(struct sock *sk, struct hlist_head *list)
>  {
>  	hlist_add_head(&sk->sk_node, list);
> @@ -372,6 +406,18 @@ static __inline__ void sk_add_node(struct sock *sk, struct hlist_head *list)
>  	__sk_add_node(sk, list);
>  }
> 
> +static inline void __sk_add_node_rcu(struct sock *sk,
> +					 struct hlist_head *list)
> +{
> +	hlist_add_head_rcu(&sk->sk_node, list);
> +}
> +
> +static inline void sk_add_node_rcu(struct sock *sk, struct hlist_head *list)
> +{
> +	sock_hold(sk);
> +	__sk_add_node_rcu(sk, list);
> +}
> +
>  static __inline__ void __sk_del_bind_node(struct sock *sk)
>  {
>  	__hlist_del(&sk->sk_bind_node);
> @@ -385,9 +431,14 @@ static __inline__ void sk_add_bind_node(struct sock *sk,
> 
>  #define sk_for_each(__sk, node, list) \
>  	hlist_for_each_entry(__sk, node, list, sk_node)
> +#define sk_for_each_rcu(__sk, node, list) \
> +	hlist_for_each_entry_rcu(__sk, node, list, sk_node)
>  #define sk_for_each_from(__sk, node) \
>  	if (__sk && ({ node = &(__sk)->sk_node; 1; })) \
>  		hlist_for_each_entry_from(__sk, node, sk_node)
> +#define sk_for_each_from_rcu(__sk, node) \
> +	if (__sk && ({ node = &(__sk)->sk_node; 1; })) \
> +		hlist_for_each_entry_from_rcu(__sk, node, sk_node)
>  #define sk_for_each_continue(__sk, node) \
>  	if (__sk && ({ node = &(__sk)->sk_node; 1; })) \
>  		hlist_for_each_entry_continue(__sk, node, sk_node)
> diff --git a/include/net/udp.h b/include/net/udp.h
> index addcdc6..e97664b 100644
> --- a/include/net/udp.h
> +++ b/include/net/udp.h
> @@ -51,7 +51,7 @@ struct udp_skb_cb {
>  #define UDP_SKB_CB(__skb)	((struct udp_skb_cb *)((__skb)->cb))
> 
>  extern struct hlist_head udp_hash[UDP_HTABLE_SIZE];
> -extern rwlock_t udp_hash_lock;
> +extern spinlock_t udp_hash_wlock;
> 
> 
>  /* Note: this must match 'valbool' in sock_setsockopt */
> @@ -112,12 +112,13 @@ static inline void udp_lib_hash(struct sock *sk)
> 
>  static inline void udp_lib_unhash(struct sock *sk)
>  {
> -	write_lock_bh(&udp_hash_lock);
> -	if (sk_del_node_init(sk)) {
> +	spin_lock_bh(&udp_hash_wlock);
> +	if (sk_del_node_rcu(sk)) {
>  		inet_sk(sk)->num = 0;
>  		sock_prot_inuse_add(sock_net(sk), sk->sk_prot, -1);
>  	}
> -	write_unlock_bh(&udp_hash_lock);
> +	spin_unlock_bh(&udp_hash_wlock);
> +	synchronize_rcu();
>  }
> 
>  static inline void udp_lib_close(struct sock *sk, long timeout)
> diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
> index 57e26fa..082e075 100644
> --- a/net/ipv4/udp.c
> +++ b/net/ipv4/udp.c
> @@ -112,7 +112,8 @@ DEFINE_SNMP_STAT(struct udp_mib, udp_stats_in6) __read_mostly;
>  EXPORT_SYMBOL(udp_stats_in6);
> 
>  struct hlist_head udp_hash[UDP_HTABLE_SIZE];
> -DEFINE_RWLOCK(udp_hash_lock);
> +DEFINE_SPINLOCK(udp_hash_wlock);
> +EXPORT_SYMBOL(udp_hash_wlock);
> 
>  int sysctl_udp_mem[3] __read_mostly;
>  int sysctl_udp_rmem_min __read_mostly;
> @@ -155,7 +156,7 @@ int udp_lib_get_port(struct sock *sk, unsigned short snum,
>  	int    error = 1;
>  	struct net *net = sock_net(sk);
> 
> -	write_lock_bh(&udp_hash_lock);
> +	spin_lock_bh(&udp_hash_wlock);
> 
>  	if (!snum) {
>  		int i, low, high, remaining;
> @@ -225,12 +226,12 @@ gotit:
>  	sk->sk_hash = snum;
>  	if (sk_unhashed(sk)) {
>  		head = &udptable[udp_hashfn(net, snum)];
> -		sk_add_node(sk, head);
> +		sk_add_node_rcu(sk, head);
>  		sock_prot_inuse_add(sock_net(sk), sk->sk_prot, 1);
>  	}
>  	error = 0;
>  fail:
> -	write_unlock_bh(&udp_hash_lock);
> +	spin_unlock_bh(&udp_hash_wlock);
>  	return error;
>  }
> 
> @@ -260,8 +261,8 @@ static struct sock *__udp4_lib_lookup(struct net *net, __be32 saddr,
>  	unsigned short hnum = ntohs(dport);
>  	int badness = -1;
> 
> -	read_lock(&udp_hash_lock);
> -	sk_for_each(sk, node, &udptable[udp_hashfn(net, hnum)]) {
> +	rcu_read_lock();
> +	sk_for_each_rcu(sk, node, &udptable[udp_hashfn(net, hnum)]) {
>  		struct inet_sock *inet = inet_sk(sk);
> 
>  		if (net_eq(sock_net(sk), net) && sk->sk_hash == hnum &&
> @@ -296,9 +297,17 @@ static struct sock *__udp4_lib_lookup(struct net *net, __be32 saddr,
>  			}
>  		}
>  	}
> +	/*
> +	 * Note that this is safe, even with an RCU lock.
> +	 * udp_lib_unhash() is the removal function, it calls
> +	 * synchronize_sched() and the socket counter cannot go to

synchronize_rcu(), right?

> +	 * zero until it returns.  So if we increment it inside the
> +	 * RCU read lock, it should never go to zero and then be
> +	 * incremented again.

So the caller of udp_lib_unhash() does the decrement?  Looks like this
might be sk_common_release(), but too many pointers to functions.  One
could also argue for udp_disconnect()...

> +	 */
>  	if (result)
>  		sock_hold(result);
> -	read_unlock(&udp_hash_lock);
> +	rcu_read_unlock();
>  	return result;
>  }
> 
> @@ -311,7 +320,7 @@ static inline struct sock *udp_v4_mcast_next(struct sock *sk,
>  	struct sock *s = sk;
>  	unsigned short hnum = ntohs(loc_port);
> 
> -	sk_for_each_from(s, node) {
> +	sk_for_each_from_rcu(s, node) {
>  		struct inet_sock *inet = inet_sk(s);
> 
>  		if (s->sk_hash != hnum					||
> @@ -1094,8 +1103,8 @@ static int __udp4_lib_mcast_deliver(struct net *net, struct sk_buff *skb,
>  	struct sock *sk;
>  	int dif;
> 
> -	read_lock(&udp_hash_lock);
> -	sk = sk_head(&udptable[udp_hashfn(net, ntohs(uh->dest))]);
> +	rcu_read_lock();
> +	sk = sk_head_rcu(&udptable[udp_hashfn(net, ntohs(uh->dest))]);
>  	dif = skb->dev->ifindex;
>  	sk = udp_v4_mcast_next(sk, uh->dest, daddr, uh->source, saddr, dif);
>  	if (sk) {
> @@ -1104,8 +1113,9 @@ static int __udp4_lib_mcast_deliver(struct net *net, struct sk_buff *skb,
>  		do {
>  			struct sk_buff *skb1 = skb;
> 
> -			sknext = udp_v4_mcast_next(sk_next(sk), uh->dest, daddr,
> -						   uh->source, saddr, dif);
> +			sknext = udp_v4_mcast_next(sk_next_rcu(sk), uh->dest,
> +						   daddr, uh->source, saddr,
> +						   dif);
>  			if (sknext)
>  				skb1 = skb_clone(skb, GFP_ATOMIC);
> 
> @@ -1120,7 +1130,7 @@ static int __udp4_lib_mcast_deliver(struct net *net, struct sk_buff *skb,
>  		} while (sknext);
>  	} else
>  		kfree_skb(skb);
> -	read_unlock(&udp_hash_lock);
> +	rcu_read_unlock();
>  	return 0;
>  }
> 
> @@ -1543,13 +1553,13 @@ static struct sock *udp_get_next(struct seq_file *seq, struct sock *sk)
>  	struct net *net = seq_file_net(seq);
> 
>  	do {
> -		sk = sk_next(sk);
> +		sk = sk_next_rcu(sk);
>  try_again:
>  		;
>  	} while (sk && (!net_eq(sock_net(sk), net) || sk->sk_family != state->family));
> 
>  	if (!sk && ++state->bucket < UDP_HTABLE_SIZE) {
> -		sk = sk_head(state->hashtable + state->bucket);
> +		sk = sk_head_rcu(state->hashtable + state->bucket);
>  		goto try_again;
>  	}
>  	return sk;
> @@ -1566,9 +1576,8 @@ static struct sock *udp_get_idx(struct seq_file *seq, loff_t pos)
>  }
> 
>  static void *udp_seq_start(struct seq_file *seq, loff_t *pos)
> -	__acquires(udp_hash_lock)
>  {
> -	read_lock(&udp_hash_lock);
> +	rcu_read_lock();
>  	return *pos ? udp_get_idx(seq, *pos-1) : SEQ_START_TOKEN;
>  }
> 
> @@ -1586,9 +1595,8 @@ static void *udp_seq_next(struct seq_file *seq, void *v, loff_t *pos)
>  }
> 
>  static void udp_seq_stop(struct seq_file *seq, void *v)
> -	__releases(udp_hash_lock)
>  {
> -	read_unlock(&udp_hash_lock);
> +	rcu_read_unlock();
>  }
> 
>  static int udp_seq_open(struct inode *inode, struct file *file)
> @@ -1732,7 +1740,6 @@ void __init udp_init(void)
> 
>  EXPORT_SYMBOL(udp_disconnect);
>  EXPORT_SYMBOL(udp_hash);
> -EXPORT_SYMBOL(udp_hash_lock);
>  EXPORT_SYMBOL(udp_ioctl);
>  EXPORT_SYMBOL(udp_prot);
>  EXPORT_SYMBOL(udp_sendmsg);
> diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
> index a6aecf7..b807de7 100644
> --- a/net/ipv6/udp.c
> +++ b/net/ipv6/udp.c
> @@ -64,8 +64,8 @@ static struct sock *__udp6_lib_lookup(struct net *net,
>  	unsigned short hnum = ntohs(dport);
>  	int badness = -1;
> 
> -	read_lock(&udp_hash_lock);
> -	sk_for_each(sk, node, &udptable[udp_hashfn(net, hnum)]) {
> +	rcu_read_lock();
> +	sk_for_each_rcu(sk, node, &udptable[udp_hashfn(net, hnum)]) {
>  		struct inet_sock *inet = inet_sk(sk);
> 
>  		if (net_eq(sock_net(sk), net) && sk->sk_hash == hnum &&
> @@ -101,9 +101,10 @@ static struct sock *__udp6_lib_lookup(struct net *net,
>  			}
>  		}
>  	}
> +	/* See comment in __udp4_lib_lookup on why this is safe. */
>  	if (result)
>  		sock_hold(result);
> -	read_unlock(&udp_hash_lock);
> +	rcu_read_unlock();
>  	return result;
>  }
> 
> @@ -322,7 +323,7 @@ static struct sock *udp_v6_mcast_next(struct sock *sk,
>  	struct sock *s = sk;
>  	unsigned short num = ntohs(loc_port);
> 
> -	sk_for_each_from(s, node) {
> +	sk_for_each_from_rcu(s, node) {
>  		struct inet_sock *inet = inet_sk(s);
> 
>  		if (sock_net(s) != sock_net(sk))
> @@ -365,8 +366,8 @@ static int __udp6_lib_mcast_deliver(struct net *net, struct sk_buff *skb,
>  	const struct udphdr *uh = udp_hdr(skb);
>  	int dif;
> 
> -	read_lock(&udp_hash_lock);
> -	sk = sk_head(&udptable[udp_hashfn(net, ntohs(uh->dest))]);
> +	rcu_read_lock();
> +	sk = sk_head_rcu(&udptable[udp_hashfn(net, ntohs(uh->dest))]);
>  	dif = inet6_iif(skb);
>  	sk = udp_v6_mcast_next(sk, uh->dest, daddr, uh->source, saddr, dif);
>  	if (!sk) {
> @@ -375,7 +376,7 @@ static int __udp6_lib_mcast_deliver(struct net *net, struct sk_buff *skb,
>  	}
> 
>  	sk2 = sk;
> -	while ((sk2 = udp_v6_mcast_next(sk_next(sk2), uh->dest, daddr,
> +	while ((sk2 = udp_v6_mcast_next(sk_next_rcu(sk2), uh->dest, daddr,
>  					uh->source, saddr, dif))) {
>  		struct sk_buff *buff = skb_clone(skb, GFP_ATOMIC);
>  		if (buff) {
> @@ -394,7 +395,7 @@ static int __udp6_lib_mcast_deliver(struct net *net, struct sk_buff *skb,
>  		sk_add_backlog(sk, skb);
>  	bh_unlock_sock(sk);
>  out:
> -	read_unlock(&udp_hash_lock);
> +	rcu_read_unlock();
>  	return 0;
>  }
> 
> 
