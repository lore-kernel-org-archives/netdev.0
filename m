From: subashab@codeaurora.org
Subject: Re: Crash due to mutex genl_lock called from RCU context
Date: Fri, 25 Nov 2016 22:59:38 -0700
Message-ID: <fdf041f4c3c43464067fd5d09452695b@codeaurora.org>
References: <c669cd06c3e50febd95b5ed4aaa78532@codeaurora.org>
 <1480133493.8455.584.camel@edumazet-glaptop3.roam.corp.google.com>
 <1480136078.8455.589.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, netdev@vger.kernel.org, netdev-owner@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:49084 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750757AbcKZF7j (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 26 Nov 2016 00:59:39 -0500
In-Reply-To: <1480136078.8455.589.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Oh well, this wont work, since sk->sk_destruct will be called from RCU
> callback.
> 
> Grabbing the mutex should not be done from netlink_sock_destruct() but
> from netlink_release()
> 
> Maybe this patch would be better :
> 
> diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
> index 62bea4591054..cce10e3c9b68 100644
> --- a/net/netlink/af_netlink.c
> +++ b/net/netlink/af_netlink.c
> @@ -324,16 +324,6 @@ static void netlink_skb_set_owner_r(struct
> sk_buff *skb, struct sock *sk)
> 
>  static void netlink_sock_destruct(struct sock *sk)
>  {
> -	struct netlink_sock *nlk = nlk_sk(sk);
> -
> -	if (nlk->cb_running) {
> -		if (nlk->cb.done)
> -			nlk->cb.done(&nlk->cb);
> -
> -		module_put(nlk->cb.module);
> -		kfree_skb(nlk->cb.skb);
> -	}
> -
>  	skb_queue_purge(&sk->sk_receive_queue);
> 
>  	if (!sock_flag(sk, SOCK_DEAD)) {
> @@ -456,8 +446,9 @@ static struct sock *netlink_lookup(struct net
> *net, int protocol, u32 portid)
> 
>  	rcu_read_lock();
>  	sk = __netlink_lookup(table, portid, net);
> -	if (sk)
> -		sock_hold(sk);
> +	if (sk && !atomic_inc_not_zero(&sk->sk_refcnt))
> +		sk = NULL;
> +
>  	rcu_read_unlock();
> 
>  	return sk;
> @@ -581,6 +572,7 @@ static int __netlink_create(struct net *net,
> struct socket *sock,
>  	}
>  	init_waitqueue_head(&nlk->wait);
> 
> +	sock_set_flag(sk, SOCK_RCU_FREE);
>  	sk->sk_destruct = netlink_sock_destruct;
>  	sk->sk_protocol = protocol;
>  	return 0;
> @@ -645,13 +637,6 @@ static int netlink_create(struct net *net, struct
> socket *sock, int protocol,
>  	goto out;
>  }
> 
> -static void deferred_put_nlk_sk(struct rcu_head *head)
> -{
> -	struct netlink_sock *nlk = container_of(head, struct netlink_sock, 
> rcu);
> -
> -	sock_put(&nlk->sk);
> -}
> -
>  static int netlink_release(struct socket *sock)
>  {
>  	struct sock *sk = sock->sk;
> @@ -724,7 +709,19 @@ static int netlink_release(struct socket *sock)
>  	local_bh_disable();
>  	sock_prot_inuse_add(sock_net(sk), &netlink_proto, -1);
>  	local_bh_enable();
> -	call_rcu(&nlk->rcu, deferred_put_nlk_sk);
> +	if (nlk->cb_running) {
> +		mutex_lock(nlk->cb_mutex);
> +		if (nlk->cb_running) {
> +			if (nlk->cb.done)
> +				nlk->cb.done(&nlk->cb);
> +
> +			module_put(nlk->cb.module);
> +			kfree_skb(nlk->cb.skb);
> +			nlk->cb_running = false;
> +		}
> +		mutex_unlock(nlk->cb_mutex);
> +	}
> +	sock_put(sk);
>  	return 0;
>  }
> 
> diff --git a/net/netlink/af_netlink.h b/net/netlink/af_netlink.h
> index 3cfd6cc60504..5dc08a7b0a2b 100644
> --- a/net/netlink/af_netlink.h
> +++ b/net/netlink/af_netlink.h
> @@ -32,7 +32,6 @@ struct netlink_sock {
>  	struct module		*module;
> 
>  	struct rhash_head	node;
> -	struct rcu_head		rcu;
>  };
> 
>  static inline struct netlink_sock *nlk_sk(struct sock *sk)

Thanks Eric! I'll try this and get back with results over this weekend.
