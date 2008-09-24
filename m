From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 1/1] Use RCU for the UDP hash lock
Date: Wed, 24 Sep 2008 12:40:06 -0700
Message-ID: <20080924124006.6bb41b49@extreme>
References: <20080924172827.GA1573@minyard.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
To: minyard@acm.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:39962 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751528AbYIXTkK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Sep 2008 15:40:10 -0400
In-Reply-To: <20080924172827.GA1573@minyard.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 24 Sep 2008 12:28:27 -0500
Corey Minyard <minyard@acm.org> wrote:

> From: Corey Minyard <cminyard@mvista.com>
> 
> Convert access to the udp_hash table to use RCU.
> 
> Signed-off-by: Corey Minyard <cminyard@mvista.com>
> ---
>  include/linux/rculist.h |   19 +++++++++++++++++++
>  include/net/sock.h      |   39 +++++++++++++++++++++++++++++++++++++++
>  include/net/udp.h       |    9 +++++----
>  net/ipv4/udp.c          |   36 +++++++++++++++++++++---------------
>  net/ipv6/udp.c          |   13 +++++++------
>  5 files changed, 91 insertions(+), 25 deletions(-)
> 
> This patch is pretty straightforward; I've tested it a while and it
> seems to work properly with a test program that constantly creates and
> destroys UDP sockets while sending and receiving large numbers of
> packets on an SMP box.  I think I've covered all the bases, though RCU
> is subtle.
> 
> This doesn't make much difference when using no preempt or desktop,
> but it makes a huge difference when used with PREEMPT_RT.  More than
> 10 times more UDP throughput on a 16-way machine.
> 
> So I'm not sure if this belongs in the RT patch or in the mainstream
> kernel.
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
> +
> +
>  #endif	/* __KERNEL__ */
>  #endif
> diff --git a/include/net/sock.h b/include/net/sock.h
> index 06c5259..ada44ad 100644
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
> @@ -361,6 +362,27 @@ static __inline__ int sk_del_node_init(struct sock *sk)
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
> @@ -372,6 +394,18 @@ static __inline__ void sk_add_node(struct sock *sk, struct hlist_head *list)
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
> @@ -385,9 +419,14 @@ static __inline__ void sk_add_bind_node(struct sock *sk,
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
> index addcdc6..04181f8 100644
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
> +	synchronize_sched();

Could this be synchronize_rcu? You are using rcu_read_lock() protected sections.
