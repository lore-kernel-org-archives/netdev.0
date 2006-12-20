From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/4] net: move softnet_data
Date: Wed, 20 Dec 2006 10:39:58 -0800 (PST)
Message-ID: <20061220.103958.72709464.davem@davemloft.net>
References: <20061214204814.631279000@osdl.org>
	<20061214204900.958451000@osdl.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp-2
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43270
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1030272AbWLTSj7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Dec 2006 13:39:59 -0500
To: shemminger@osdl.org
In-Reply-To: <20061214204900.958451000@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@osdl.org>
Date: Thu, 14 Dec 2006 12:48:17 -0800

> Make softnet_data local to dev.c.  
> 
> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

Slight mistake here, I think:

> +#ifdef CONFIG_NETPOLL
> +extern void		netpoll_do_completion(void);
> +#endif

Ok.

> --- linux-2.6.20-rc1.orig/net/core/dev.c
> +++ linux-2.6.20-rc1/net/core/dev.c
 ...
> @@ -1673,6 +1686,34 @@ static inline struct net_device *skb_bon
>  	return dev;
>  }
>  
> +#ifdef CONFIG_NETPOLL
> +void netpoll_do_completion(void)
> +{

Ok.

> --- linux-2.6.20-rc1.orig/net/core/netpoll.c
> +++ linux-2.6.20-rc1/net/core/netpoll.c
  ...
> @@ -181,7 +180,7 @@ static void refill_skbs(void)
>  	spin_unlock_irqrestore(&skb_pool.lock, flags);
>  }
>  
> -static void zap_completion_queue(void)
> +static void netpoll_do_completion(void)
>  {
>  	unsigned long flags;
>  	struct softnet_data *sd = &get_cpu_var(softnet_data);
> @@ -212,7 +211,7 @@ static struct sk_buff *find_skb(struct n
>  	int count = 0;
>  	struct sk_buff *skb;
>  
> -	zap_completion_queue();
> +	netpoll_do_completion();
>  	refill_skbs();
>  repeat:

-ENOTESTED, I think this makes netpoll_do_completion() call itself,
ie. the local static version here, not the one you are exporting from
net/core/dev.c

Because of the extern you added, I can't see how the compiler
didn't complain loudly about this mismatch.

I had to see this, so I compiled it myself, and it doesn't even
build:

  CC      net/core/netpoll.o
net/core/netpoll.c:184: error: static declaration of $,1rx(Bnetpoll_do_completion$,1ry(B follows non-static declaration
include/linux/netdevice.h:604: error: previous declaration of $,1rx(Bnetpoll_do_completion$,1ry(B was here
net/core/netpoll.c: In function $,1rx(Bnetpoll_do_completion$,1ry(B:
net/core/netpoll.c:186: error: $,1rx(Bper_cpu__softnet_data$,1ry(B undeclared (first use in this function)
net/core/netpoll.c:186: error: (Each undeclared identifier is reported only once
net/core/netpoll.c:186: error: for each function it appears in.)
net/core/netpoll.c:188: error: dereferencing pointer to incomplete type
net/core/netpoll.c:192: error: dereferencing pointer to incomplete type
net/core/netpoll.c:193: error: dereferencing pointer to incomplete type

Stephen... come on :-)

