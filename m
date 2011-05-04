From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [net-next-2.6 PATCH] can: rename can_try_module_get to can_get_proto
Date: Wed, 04 May 2011 22:35:38 +0200
Message-ID: <4DC1B89A.3080904@hartkopp.net>
References: <20110504044204.GD278@e-circ.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: socketcan-core@lists.berlios.de, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.161]:32231 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753060Ab1EDUfk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2011 16:35:40 -0400
In-Reply-To: <20110504044204.GD278@e-circ.dyndns.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04.05.2011 06:42, Kurt Van Dijck wrote:
> can: rename can_try_module_get to can_get_proto
> 
> can_try_module_get does return a struct can_proto.
> The name explains what is done in so much detail that a caller
> may not notice that a struct can_proto is locked/unlocked.
> 
> Signed-off-by: Kurt Van Dijck <kurt.van.dijck@eia.be>

Acked-by: Oliver Hartkopp <socketcan@hartkopp.net>

> 
> diff --git a/net/can/af_can.c b/net/can/af_can.c
> index 5b52762..094fc53 100644
> --- a/net/can/af_can.c
> +++ b/net/can/af_can.c
> @@ -115,7 +115,7 @@ static void can_sock_destruct(struct sock *sk)
>  	skb_queue_purge(&sk->sk_receive_queue);
>  }
>  
> -static const struct can_proto *can_try_module_get(int protocol)
> +static const struct can_proto *can_get_proto(int protocol)
>  {
>  	const struct can_proto *cp;
>  
> @@ -128,6 +128,11 @@ static const struct can_proto *can_try_module_get(int protocol)
>  	return cp;
>  }
>  
> +static inline void can_put_proto(const struct can_proto *cp)
> +{
> +	module_put(cp->prot->owner);
> +}
> +
>  static int can_create(struct net *net, struct socket *sock, int protocol,
>  		      int kern)
>  {
> @@ -143,7 +148,7 @@ static int can_create(struct net *net, struct socket *sock, int protocol,
>  	if (!net_eq(net, &init_net))
>  		return -EAFNOSUPPORT;
>  
> -	cp = can_try_module_get(protocol);
> +	cp = can_get_proto(protocol);
>  
>  #ifdef CONFIG_MODULES
>  	if (!cp) {
> @@ -160,7 +165,7 @@ static int can_create(struct net *net, struct socket *sock, int protocol,
>  			printk(KERN_ERR "can: request_module "
>  			       "(can-proto-%d) failed.\n", protocol);
>  
> -		cp = can_try_module_get(protocol);
> +		cp = can_get_proto(protocol);
>  	}
>  #endif
>  
> @@ -195,7 +200,7 @@ static int can_create(struct net *net, struct socket *sock, int protocol,
>  	}
>  
>   errout:
> -	module_put(cp->prot->owner);
> +	can_put_proto(cp);
>  	return err;
>  }
>  
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

