From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] net: Convert TCP/DCCP listening hash tables to use RCU
Date: Sun, 23 Nov 2008 07:59:32 -0800
Message-ID: <20081123155932.GB7932@linux.vnet.ibm.com>
References: <49089BE5.3090705@acm.org> <4908A134.4040705@cosmosbay.com> <4908AB3F.1060003@acm.org> <20081029185200.GE6732@linux.vnet.ibm.com> <4908C0CD.5050406@cosmosbay.com> <20081029201759.GF6732@linux.vnet.ibm.com> <4908DEDE.5030706@cosmosbay.com> <4909D551.9080309@cosmosbay.com> <491C2873.60004@cosmosbay.com> <49292368.2060201@cosmosbay.com>
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
Received: from e1.ny.us.ibm.com ([32.97.182.141]:48417 "EHLO e1.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751087AbYKWP7g (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 23 Nov 2008 10:59:36 -0500
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e1.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id mANFxGHI012858
	for <netdev@vger.kernel.org>; Sun, 23 Nov 2008 10:59:16 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id mANFxXLd131250
	for <netdev@vger.kernel.org>; Sun, 23 Nov 2008 10:59:35 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id mANGxeD4004474
	for <netdev@vger.kernel.org>; Sun, 23 Nov 2008 11:59:41 -0500
Content-Disposition: inline
In-Reply-To: <49292368.2060201@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Nov 23, 2008 at 10:33:28AM +0100, Eric Dumazet wrote:
> Hi David
>
> Please find patch to convert TCP/DCCP listening hash tables
> to RCU.
>
> A followup patch will cleanup all sk_node fields and macros
> that are not used anymore.
>
> Thanks
>
> [PATCH] net: Convert TCP/DCCP listening hash tables to use RCU
>
> This is the last step to be able to perform full RCU lookups
> in __inet_lookup() : After established/timewait tables, we
> add RCU lookups to listening hash table.
>
> The only trick here is that a socket of a given type (TCP ipv4,
> TCP ipv6, ...) can now flight between two different tables
> (established and listening) during a RCU grace period, so we
> must use different 'nulls' end-of-chain values for two tables.
>
> We define a large value :
>
> #define LISTENING_NULLS_BASE (1U << 29)

I do like this use of the full set up upper bits!  However, wouldn't it
be a good idea to use a larger base value for 64-bit systems, perhaps
using CONFIG_64BIT to choose?  500M entries might not seem like that
many in a few years time...

						Thanx, Paul

> So that slots in listening table are guaranteed to have different
> end-of-chain values than slots in established table. A reader can
> still detect it finished its lookup in the right chain.
>
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
> ---
> include/net/inet_hashtables.h |    9 +
> net/ipv4/inet_diag.c          |    4
> net/ipv4/inet_hashtables.c    |  148 ++++++++++++++++----------------
> net/ipv4/tcp_ipv4.c           |    8 -
> net/ipv6/inet6_hashtables.c   |   94 ++++++++++++--------
> 5 files changed, 147 insertions(+), 116 deletions(-)

> diff --git a/include/net/inet_hashtables.h b/include/net/inet_hashtables.h
> index ec7ee2e..df90118 100644
> --- a/include/net/inet_hashtables.h
> +++ b/include/net/inet_hashtables.h
> @@ -99,9 +99,16 @@ struct inet_bind_hashbucket {
>  	struct hlist_head	chain;
>  };
> 
> +/*
> + * Sockets can be hashed in established or listening table
> + * We must use different 'nulls' end-of-chain value for listening
> + * hash table, or we might find a socket that was closed and
> + * reallocated/inserted into established hash table
> + */
> +#define LISTENING_NULLS_BASE (1U << 29)
>  struct inet_listen_hashbucket {
>  	spinlock_t		lock;
> -	struct hlist_head	head;
> +	struct hlist_nulls_head	head;
>  };
> 
>  /* This is for listening sockets, thus all sockets which possess wildcards. */
> diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
> index 998a78f..588a779 100644
> --- a/net/ipv4/inet_diag.c
> +++ b/net/ipv4/inet_diag.c
> @@ -720,13 +720,13 @@ static int inet_diag_dump(struct sk_buff *skb, struct netlink_callback *cb)
> 
>  		for (i = s_i; i < INET_LHTABLE_SIZE; i++) {
>  			struct sock *sk;
> -			struct hlist_node *node;
> +			struct hlist_nulls_node *node;
>  			struct inet_listen_hashbucket *ilb;
> 
>  			num = 0;
>  			ilb = &hashinfo->listening_hash[i];
>  			spin_lock_bh(&ilb->lock);
> -			sk_for_each(sk, node, &ilb->head) {
> +			sk_nulls_for_each(sk, node, &ilb->head) {
>  				struct inet_sock *inet = inet_sk(sk);
> 
>  				if (num < s_num) {
> diff --git a/net/ipv4/inet_hashtables.c b/net/ipv4/inet_hashtables.c
> index 4c273a9..11fcb87 100644
> --- a/net/ipv4/inet_hashtables.c
> +++ b/net/ipv4/inet_hashtables.c
> @@ -110,78 +110,79 @@ void __inet_inherit_port(struct sock *sk, struct sock *child)
> 
>  EXPORT_SYMBOL_GPL(__inet_inherit_port);
> 
> +static inline int compute_score(struct sock *sk, struct net *net,
> +				const unsigned short hnum, const __be32 daddr,
> +				const int dif)
> +{
> +	int score = -1;
> +	struct inet_sock *inet = inet_sk(sk);
> +
> +	if (net_eq(sock_net(sk), net) && inet->num == hnum &&
> +			!ipv6_only_sock(sk)) {
> +		__be32 rcv_saddr = inet->rcv_saddr;
> +		score = sk->sk_family == PF_INET ? 1 : 0;
> +		if (rcv_saddr) {
> +			if (rcv_saddr != daddr)
> +				return -1;
> +			score += 2;
> +		}
> +		if (sk->sk_bound_dev_if) {
> +			if (sk->sk_bound_dev_if != dif)
> +				return -1;
> +			score += 2;
> +		}
> +	}
> +	return score;
> +}
> +
>  /*
>   * Don't inline this cruft. Here are some nice properties to exploit here. The
>   * BSD API does not allow a listening sock to specify the remote port nor the
>   * remote address for the connection. So always assume those are both
>   * wildcarded during the search since they can never be otherwise.
>   */
> -static struct sock *inet_lookup_listener_slow(struct net *net,
> -					      const struct hlist_head *head,
> -					      const __be32 daddr,
> -					      const unsigned short hnum,
> -					      const int dif)
> -{
> -	struct sock *result = NULL, *sk;
> -	const struct hlist_node *node;
> -	int hiscore = -1;
> -
> -	sk_for_each(sk, node, head) {
> -		const struct inet_sock *inet = inet_sk(sk);
> -
> -		if (net_eq(sock_net(sk), net) && inet->num == hnum &&
> -				!ipv6_only_sock(sk)) {
> -			const __be32 rcv_saddr = inet->rcv_saddr;
> -			int score = sk->sk_family == PF_INET ? 1 : 0;
> -
> -			if (rcv_saddr) {
> -				if (rcv_saddr != daddr)
> -					continue;
> -				score += 2;
> -			}
> -			if (sk->sk_bound_dev_if) {
> -				if (sk->sk_bound_dev_if != dif)
> -					continue;
> -				score += 2;
> -			}
> -			if (score == 5)
> -				return sk;
> -			if (score > hiscore) {
> -				hiscore	= score;
> -				result	= sk;
> -			}
> -		}
> -	}
> -	return result;
> -}
> 
> -/* Optimize the common listener case. */
> +
>  struct sock *__inet_lookup_listener(struct net *net,
>  				    struct inet_hashinfo *hashinfo,
>  				    const __be32 daddr, const unsigned short hnum,
>  				    const int dif)
>  {
> -	struct sock *sk = NULL;
> -	struct inet_listen_hashbucket *ilb;
> +	struct sock *sk, *result;
> +	struct hlist_nulls_node *node;
> +	unsigned int hash = inet_lhashfn(net, hnum);
> +	struct inet_listen_hashbucket *ilb = &hashinfo->listening_hash[hash];
> +	int score, hiscore;
> 
> -	ilb = &hashinfo->listening_hash[inet_lhashfn(net, hnum)];
> -	spin_lock(&ilb->lock);
> -	if (!hlist_empty(&ilb->head)) {
> -		const struct inet_sock *inet = inet_sk((sk = __sk_head(&ilb->head)));
> -
> -		if (inet->num == hnum && !sk->sk_node.next &&
> -		    (!inet->rcv_saddr || inet->rcv_saddr == daddr) &&
> -		    (sk->sk_family == PF_INET || !ipv6_only_sock(sk)) &&
> -		    !sk->sk_bound_dev_if && net_eq(sock_net(sk), net))
> -			goto sherry_cache;
> -		sk = inet_lookup_listener_slow(net, &ilb->head, daddr, hnum, dif);
> +	rcu_read_lock();
> +begin:
> +	result = NULL;
> +	hiscore = -1;
> +	sk_nulls_for_each_rcu(sk, node, &ilb->head) {
> +		score = compute_score(sk, net, hnum, daddr, dif);
> +		if (score > hiscore) {
> +			result = sk;
> +			hiscore = score;
> +		}
>  	}
> -	if (sk) {
> -sherry_cache:
> -		sock_hold(sk);
> +	/*
> +	 * if the nulls value we got at the end of this lookup is
> +	 * not the expected one, we must restart lookup.
> +	 * We probably met an item that was moved to another chain.
> +	 */
> +	if (get_nulls_value(node) != hash + LISTENING_NULLS_BASE)
> +		goto begin;
> +	if (result) {
> +		if (unlikely(!atomic_inc_not_zero(&result->sk_refcnt)))
> +			result = NULL;
> +		else if (unlikely(compute_score(result, net, hnum, daddr,
> +				  dif) < hiscore)) {
> +			sock_put(result);
> +			goto begin;
> +		}
>  	}
> -	spin_unlock(&ilb->lock);
> -	return sk;
> +	rcu_read_unlock();
> +	return result;
>  }
>  EXPORT_SYMBOL_GPL(__inet_lookup_listener);
> 
> @@ -370,7 +371,7 @@ static void __inet_hash(struct sock *sk)
>  	ilb = &hashinfo->listening_hash[inet_sk_listen_hashfn(sk)];
> 
>  	spin_lock(&ilb->lock);
> -	__sk_add_node(sk, &ilb->head);
> +	__sk_nulls_add_node_rcu(sk, &ilb->head);
>  	sock_prot_inuse_add(sock_net(sk), sk->sk_prot, 1);
>  	spin_unlock(&ilb->lock);
>  }
> @@ -388,26 +389,22 @@ EXPORT_SYMBOL_GPL(inet_hash);
>  void inet_unhash(struct sock *sk)
>  {
>  	struct inet_hashinfo *hashinfo = sk->sk_prot->h.hashinfo;
> +	spinlock_t *lock;
> +	int done;
> 
>  	if (sk_unhashed(sk))
>  		return;
> 
> -	if (sk->sk_state == TCP_LISTEN) {
> -		struct inet_listen_hashbucket *ilb;
> +	if (sk->sk_state == TCP_LISTEN)
> +		lock = &hashinfo->listening_hash[inet_sk_listen_hashfn(sk)].lock;
> +	else
> +		lock = inet_ehash_lockp(hashinfo, sk->sk_hash);
> 
> -		ilb = &hashinfo->listening_hash[inet_sk_listen_hashfn(sk)];
> -		spin_lock_bh(&ilb->lock);
> -		if (__sk_del_node_init(sk))
> -			sock_prot_inuse_add(sock_net(sk), sk->sk_prot, -1);
> -		spin_unlock_bh(&ilb->lock);
> -	} else {
> -		spinlock_t *lock = inet_ehash_lockp(hashinfo, sk->sk_hash);
> -
> -		spin_lock_bh(lock);
> -		if (__sk_nulls_del_node_init_rcu(sk))
> -			sock_prot_inuse_add(sock_net(sk), sk->sk_prot, -1);
> -		spin_unlock_bh(lock);
> -	}
> +	spin_lock_bh(lock);
> +	done =__sk_nulls_del_node_init_rcu(sk);
> +	spin_unlock_bh(lock);
> +	if (done)
> +		sock_prot_inuse_add(sock_net(sk), sk->sk_prot, -1);
>  }
>  EXPORT_SYMBOL_GPL(inet_unhash);
> 
> @@ -526,8 +523,11 @@ void inet_hashinfo_init(struct inet_hashinfo *h)
>  {
>  	int i;
> 
> -	for (i = 0; i < INET_LHTABLE_SIZE; i++)
> +	for (i = 0; i < INET_LHTABLE_SIZE; i++) {
>  		spin_lock_init(&h->listening_hash[i].lock);
> +		INIT_HLIST_NULLS_HEAD(&h->listening_hash[i].head,
> +				      i + LISTENING_NULLS_BASE);
> +		}
>  }
> 
>  EXPORT_SYMBOL_GPL(inet_hashinfo_init);
> diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
> index a81caa1..cab2458 100644
> --- a/net/ipv4/tcp_ipv4.c
> +++ b/net/ipv4/tcp_ipv4.c
> @@ -1868,7 +1868,7 @@ static inline struct inet_timewait_sock *tw_next(struct inet_timewait_sock *tw)
>  static void *listening_get_next(struct seq_file *seq, void *cur)
>  {
>  	struct inet_connection_sock *icsk;
> -	struct hlist_node *node;
> +	struct hlist_nulls_node *node;
>  	struct sock *sk = cur;
>  	struct inet_listen_hashbucket *ilb;
>  	struct tcp_iter_state *st = seq->private;
> @@ -1878,7 +1878,7 @@ static void *listening_get_next(struct seq_file *seq, void *cur)
>  		st->bucket = 0;
>  		ilb = &tcp_hashinfo.listening_hash[0];
>  		spin_lock_bh(&ilb->lock);
> -		sk = sk_head(&ilb->head);
> +		sk = sk_nulls_head(&ilb->head);
>  		goto get_sk;
>  	}
>  	ilb = &tcp_hashinfo.listening_hash[st->bucket];
> @@ -1914,7 +1914,7 @@ get_req:
>  		sk = sk_next(sk);
>  	}
>  get_sk:
> -	sk_for_each_from(sk, node) {
> +	sk_nulls_for_each_from(sk, node) {
>  		if (sk->sk_family == st->family && net_eq(sock_net(sk), net)) {
>  			cur = sk;
>  			goto out;
> @@ -1935,7 +1935,7 @@ start_req:
>  	if (++st->bucket < INET_LHTABLE_SIZE) {
>  		ilb = &tcp_hashinfo.listening_hash[st->bucket];
>  		spin_lock_bh(&ilb->lock);
> -		sk = sk_head(&ilb->head);
> +		sk = sk_nulls_head(&ilb->head);
>  		goto get_sk;
>  	}
>  	cur = NULL;
> diff --git a/net/ipv6/inet6_hashtables.c b/net/ipv6/inet6_hashtables.c
> index e0fd681..8fe267f 100644
> --- a/net/ipv6/inet6_hashtables.c
> +++ b/net/ipv6/inet6_hashtables.c
> @@ -33,7 +33,7 @@ void __inet6_hash(struct sock *sk)
> 
>  		ilb = &hashinfo->listening_hash[inet_sk_listen_hashfn(sk)];
>  		spin_lock(&ilb->lock);
> -		__sk_add_node(sk, &ilb->head);
> +		__sk_nulls_add_node_rcu(sk, &ilb->head);
>  		spin_unlock(&ilb->lock);
>  	} else {
>  		unsigned int hash;
> @@ -118,47 +118,71 @@ out:
>  }
>  EXPORT_SYMBOL(__inet6_lookup_established);
> 
> +static int inline compute_score(struct sock *sk, struct net *net,
> +				const unsigned short hnum,
> +				const struct in6_addr *daddr,
> +				const int dif)
> +{
> +	int score = -1;
> +
> +	if (net_eq(sock_net(sk), net) && inet_sk(sk)->num == hnum &&
> +	    sk->sk_family == PF_INET6) {
> +		const struct ipv6_pinfo *np = inet6_sk(sk);
> +
> +		score = 1;
> +		if (!ipv6_addr_any(&np->rcv_saddr)) {
> +			if (!ipv6_addr_equal(&np->rcv_saddr, daddr))
> +				return -1;
> +			score++;
> +		}
> +		if (sk->sk_bound_dev_if) {
> +			if (sk->sk_bound_dev_if != dif)
> +				return -1;
> +			score++;
> +		}
> +	}
> +	return score;
> +}
> +
>  struct sock *inet6_lookup_listener(struct net *net,
>  		struct inet_hashinfo *hashinfo, const struct in6_addr *daddr,
>  		const unsigned short hnum, const int dif)
>  {
>  	struct sock *sk;
> -	const struct hlist_node *node;
> -	struct sock *result = NULL;
> -	int score, hiscore = 0;
> -	struct inet_listen_hashbucket *ilb;
> -
> -	ilb = &hashinfo->listening_hash[inet_lhashfn(net, hnum)];
> -	spin_lock(&ilb->lock);
> -	sk_for_each(sk, node, &ilb->head) {
> -		if (net_eq(sock_net(sk), net) && inet_sk(sk)->num == hnum &&
> -				sk->sk_family == PF_INET6) {
> -			const struct ipv6_pinfo *np = inet6_sk(sk);
> -
> -			score = 1;
> -			if (!ipv6_addr_any(&np->rcv_saddr)) {
> -				if (!ipv6_addr_equal(&np->rcv_saddr, daddr))
> -					continue;
> -				score++;
> -			}
> -			if (sk->sk_bound_dev_if) {
> -				if (sk->sk_bound_dev_if != dif)
> -					continue;
> -				score++;
> -			}
> -			if (score == 3) {
> -				result = sk;
> -				break;
> -			}
> -			if (score > hiscore) {
> -				hiscore = score;
> -				result = sk;
> -			}
> +	const struct hlist_nulls_node *node;
> +	struct sock *result;
> +	int score, hiscore;
> +	unsigned int hash = inet_lhashfn(net, hnum);
> +	struct inet_listen_hashbucket *ilb = &hashinfo->listening_hash[hash];
> +
> +	rcu_read_lock();
> +begin:
> +	result = NULL;
> +	hiscore = -1;
> +	sk_nulls_for_each(sk, node, &ilb->head) {
> +		score = compute_score(sk, net, hnum, daddr, dif);
> +		if (score > hiscore) {
> +			hiscore = score;
> +			result = sk;
>  		}
>  	}
> -	if (result)
> -		sock_hold(result);
> -	spin_unlock(&ilb->lock);
> +	/*
> +	 * if the nulls value we got at the end of this lookup is
> +	 * not the expected one, we must restart lookup.
> +	 * We probably met an item that was moved to another chain.
> +	 */
> +	if (get_nulls_value(node) != hash + LISTENING_NULLS_BASE)
> +		goto begin;
> +	if (result) {
> +		if (unlikely(!atomic_inc_not_zero(&result->sk_refcnt)))
> +			result = NULL;
> +		else if (unlikely(compute_score(result, net, hnum, daddr,
> +				  dif) < hiscore)) {
> +			sock_put(result);
> +			goto begin;
> +		}
> +	}
> +	rcu_read_unlock();
>  	return result;
>  }
> 

