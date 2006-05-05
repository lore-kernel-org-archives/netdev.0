From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC PATCH] [IPV6] ADDRCONF: Convert addrconf_lock to RCU.
Date: Fri, 05 May 2006 14:08:21 +1000
Message-ID: <E1Fbrc5-0002L7-00@gondolin.me.apana.org.au>
References: <20060505.122452.46183936.yoshfuji@linux-ipv6.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:29967 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S932276AbWEEEI2
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 May 2006 00:08:28 -0400
To: yoshfuji@linux-ipv6.org (YOSHIFUJI Hideaki / ????)
In-Reply-To: <20060505.122452.46183936.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

YOSHIFUJI Hideaki / ???? <yoshfuji@linux-ipv6.org> wrote:
>
> @@ -2291,10 +2287,9 @@ static int addrconf_ifdown(struct net_de
>                   Do not dev_put!
>         */
>        if (how == 1) {
> -               write_lock_bh(&addrconf_lock);
> -               dev->ip6_ptr = NULL;
> -               idev->dead = 1;
> -               write_unlock_bh(&addrconf_lock);
> +               set_wmb(idev->dead, 1);
> +               /* protected by rtnl_lock */
> +               rcu_assign_pointer(dev->ip6_ptr, NULL);

A pet peeve of mine: As a general rule you do not need to use
rcu_assign_pointer when clearing an RCU pointer.  The whole point
of that construct is to place a barrier between initialising an
object and assigning the address of that object to the pointer.
Since the object pointed to by NULL requires no initialisation, you
don't need the barrier.

I'd also like to know the purpose of the wmb after idev->dead = 1.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
