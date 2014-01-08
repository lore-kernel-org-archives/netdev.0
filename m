From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next V3 3/3] net: Add GRO support for vxlan traffic
Date: Wed, 08 Jan 2014 14:11:41 -0800
Message-ID: <1389219101.31367.21.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1389213278-2200-1-git-send-email-ogerlitz@mellanox.com>
	 <1389213278-2200-4-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: hkchu@google.com, edumazet@google.com, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org, davem@davemloft.net, yanb@mellanox.com,
	shlomop@mellanox.com
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:42125 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932077AbaAHWLc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jan 2014 17:11:32 -0500
Received: by mail-pd0-f174.google.com with SMTP id x10so2337585pdj.33
        for <netdev@vger.kernel.org>; Wed, 08 Jan 2014 14:11:31 -0800 (PST)
In-Reply-To: <1389213278-2200-4-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-01-08 at 22:34 +0200, Or Gerlitz wrote:

> +
>  /* Notify netdevs that UDP port started listening */
> -static void vxlan_notify_add_rx_port(struct sock *sk)
> +static void vxlan_notify_add_rx_port(struct vxlan_sock *vs)
>  {
>  	struct net_device *dev;
> +	struct sock *sk = vs->sock->sk;
>  	struct net *net = sock_net(sk);
>  	sa_family_t sa_family = sk->sk_family;
>  	__be16 port = inet_sk(sk)->inet_sport;
> @@ -569,12 +671,16 @@ static void vxlan_notify_add_rx_port(struct sock *sk)
>  							    port);
>  	}
>  	rcu_read_unlock();
> +
> +	if (sa_family == AF_INET)
> +		call_rcu(&vs->rcu, vxlan_add_udp_offload);

Why waiting RCU grace period here ?

>  }
>  
>  /* Notify netdevs that UDP port is no more listening */
> -static void vxlan_notify_del_rx_port(struct sock *sk)
> +static void vxlan_notify_del_rx_port(struct vxlan_sock *vs)
>  {
>  	struct net_device *dev;
> +	struct sock *sk = vs->sock->sk;
>  	struct net *net = sock_net(sk);
>  	sa_family_t sa_family = sk->sk_family;
>  	__be16 port = inet_sk(sk)->inet_sport;
> @@ -586,6 +692,9 @@ static void vxlan_notify_del_rx_port(struct sock *sk)
>  							    port);
>  	}
>  	rcu_read_unlock();
> +
> +	if (sa_family == AF_INET)
> +		call_rcu(&vs->rcu, vxlan_del_udp_offload);
>  }

This looks buggy.

You need to :

1) remove the offload structure from list
2) Then wait rcu grace period, and finally free the memory
