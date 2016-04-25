From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] soreuseport: Resolve merge conflict for v4/v6
 ordering fix
Date: Mon, 25 Apr 2016 10:33:48 -0700
Message-ID: <1461605628.5535.22.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1461595332-16994-1-git-send-email-kraigatgoog@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Craig Gallek <kraigatgoog@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:36322 "EHLO
	mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932627AbcDYRdw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Apr 2016 13:33:52 -0400
Received: by mail-pf0-f173.google.com with SMTP id c189so24371169pfb.3
        for <netdev@vger.kernel.org>; Mon, 25 Apr 2016 10:33:51 -0700 (PDT)
In-Reply-To: <1461595332-16994-1-git-send-email-kraigatgoog@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-04-25 at 10:42 -0400, Craig Gallek wrote:
> From: Craig Gallek <kraig@google.com>
...
>  static inline void __sk_nulls_add_node_rcu(struct sock *sk, struct hlist_nulls_head *list)
> diff --git a/net/ipv4/inet_hashtables.c b/net/ipv4/inet_hashtables.c
> index fcadb670f50b..b76b0d7e59c1 100644
> --- a/net/ipv4/inet_hashtables.c
> +++ b/net/ipv4/inet_hashtables.c
> @@ -479,7 +479,11 @@ int __inet_hash(struct sock *sk, struct sock *osk,
>  		if (err)
>  			goto unlock;
>  	}
> -	hlist_add_head_rcu(&sk->sk_node, &ilb->head);
> +	if (IS_ENABLED(CONFIG_IPV6) && sk->sk_reuseport &&
> +		sk->sk_family == AF_INET6)

Nit : alignment was wrong here.

cond1 & cond2 should be aligned as in :

if (cond1 &&
    cond2)


> +		hlist_add_tail_rcu(&sk->sk_node, &ilb->head);
> +	else
> +		hlist_add_head_rcu(&sk->sk_node, &ilb->head);
>  	sock_set_flag(sk, SOCK_RCU_FREE);
>  	sock_prot_inuse_add(sock_net(sk), sk->sk_prot, 1);
>  unlock:
