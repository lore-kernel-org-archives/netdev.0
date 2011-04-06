From: Kurt Van Dijck <kurt.van.dijck@eia.be>
Subject: Re: [PATCH net-next-2.6 v2] can: convert protocol handling to RCU
Date: Wed, 6 Apr 2011 11:27:27 +0200
Message-ID: <20110406092727.GC342@kurt.e-circ.dyndns.org>
References: <4D9B58EC.9090903@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Urs Thuermann <urs@isnogud.escape.de>
To: Oliver Hartkopp <socketcan@hartkopp.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.eia.be ([194.78.71.18]:26071 "EHLO mail.eia.be"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755212Ab1DFJ1b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Apr 2011 05:27:31 -0400
Content-Disposition: inline
In-Reply-To: <4D9B58EC.9090903@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 05, 2011 at 08:01:16PM +0200, Oliver Hartkopp wrote:
> This patch removes spin_locks at CAN socket creation time by using RCU.
Good thing.

I'm interested in RCU also for my J1939 code.
I do have some questions below. These are mainly since I'm not yet used
to RCU. Btw, I must have missed v1 of the patch, so I may ask 'already
resolved' things...
> 
>  
> +static struct can_proto *can_try_module_get(int protocol)
> +{
> +	struct can_proto *cp;
> +
> +	rcu_read_lock();
> +	cp = rcu_dereference(proto_tab[protocol]);
> +	if (cp && !try_module_get(cp->prot->owner))
After the xxx_get, is the 'cp' pointer persistent?
> +		cp = NULL;
> +	rcu_read_unlock();
> +
> +	return cp;
> +}
> +
>  static int can_create(struct net *net, struct socket *sock, int protocol,
>  		      int kern)
>  {
> @@ -130,9 +143,12 @@ static int can_create(struct net *net, struct socket *sock, int protocol,
>  	if (!net_eq(net, &init_net))
>  		return -EAFNOSUPPORT;
>  
> +	cp = can_try_module_get(protocol);
> +
>  
[...]
>  	/* check for available protocol and correct usage */
>  
>  	if (!cp)
>  		return -EPROTONOSUPPORT;
>  
>  	if (cp->type != sock->type) {
I don't see how this will evaluate to true?
can_proto_register takes care of it.
> -		err = -EPROTONOSUPPORT;
> +		err = -EPROTOTYPE;
>  		goto errout;
>  	}
>  
