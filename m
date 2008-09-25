From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH 1/1] Use RCU for the UDP hash lock
Date: Thu, 25 Sep 2008 08:45:09 +0000
Message-ID: <20080925084509.GA5090@ff.dom.local>
References: <48DB2925.2070908@poczta.onet.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
To: minyard@acm.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.184]:33837 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752782AbYIYIpQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Sep 2008 04:45:16 -0400
Received: by fk-out-0910.google.com with SMTP id 18so312445fkq.5
        for <netdev@vger.kernel.org>; Thu, 25 Sep 2008 01:45:14 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080924172827.GA1573@minyard.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 24-09-2008 19:28, Corey Minyard wrote:
...
> From: Corey Minyard <cminyard@mvista.com>
> 
> Convert access to the udp_hash table to use RCU.
> 
> Signed-off-by: Corey Minyard <cminyard@mvista.com>
> ---
...
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

Why sk_node_init() part (or hlist_del_init_rcu) isn't used?

> +
> +	if (rc) {
> +		/* paranoid for a while -acme */
> +		WARN_ON(atomic_read(&sk->sk_refcnt) == 1);
> +		__sock_put(sk);
> +	}
> +	return rc;
> +}
> +
...
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
>  }
>  
>  static inline void udp_lib_close(struct sock *sk, long timeout)
> diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
> index 57e26fa..3aa04da 100644
> --- a/net/ipv4/udp.c
> +++ b/net/ipv4/udp.c
...
> @@ -1094,7 +1103,7 @@ static int __udp4_lib_mcast_deliver(struct net *net, struct sk_buff *skb,
>  	struct sock *sk;
>  	int dif;
>  
> -	read_lock(&udp_hash_lock);
> +	rcu_read_lock();
>  	sk = sk_head(&udptable[udp_hashfn(net, ntohs(uh->dest))]);

Probably sk_head_rcu() is needed too.

>  	dif = skb->dev->ifindex;
>  	sk = udp_v4_mcast_next(sk, uh->dest, daddr, uh->source, saddr, dif);
> @@ -1120,7 +1129,7 @@ static int __udp4_lib_mcast_deliver(struct net *net, struct sk_buff *skb,
>  		} while (sknext);
>  	} else
>  		kfree_skb(skb);
> -	read_unlock(&udp_hash_lock);
> +	rcu_read_unlock();
>  	return 0;
>  }
...

Aren't other functions like sk_next() or sk_unhashed() used on the
read side and need _rcu versions?

Jarek P.
