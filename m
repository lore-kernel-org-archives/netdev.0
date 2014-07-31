From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH 2/2] ipv6: addrconf: clean up device type handling
Date: Fri, 01 Aug 2014 00:13:35 +0200
Message-ID: <1406844815.13603.24.camel@localhost>
References: <20140731201926.GA754314@jupiter.n2.diac24.net>
	 <1406840034-140848-1-git-send-email-equinox@diac24.net>
	 <1406840034-140848-3-git-send-email-equinox@diac24.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: David Lamparter <equinox@diac24.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:36737 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752522AbaGaWNj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jul 2014 18:13:39 -0400
Received: from compute6.internal (compute6.nyi.internal [10.202.2.46])
	by gateway1.nyi.internal (Postfix) with ESMTP id 626ED2260F
	for <netdev@vger.kernel.org>; Thu, 31 Jul 2014 18:13:37 -0400 (EDT)
In-Reply-To: <1406840034-140848-3-git-send-email-equinox@diac24.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Do, 2014-07-31 at 22:53 +0200, David Lamparter wrote:
> This realigns addrconf support for the various lower-layer device types,
> and removes a little bit of duplicate code.  Behaviour should be exactly
> identical before and after the patch.
> 
> (Also adds a comment to explain the weird fe80::/64 on GRE.)
> 
> Signed-off-by: David Lamparter <equinox@diac24.net>
> Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Cc: Stephen Hemminger <stephen@networkplumber.org>
> Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> ---
>  net/ipv6/addrconf.c | 87 ++++++++++++++++++++++++-----------------------------
>  1 file changed, 39 insertions(+), 48 deletions(-)
> 
> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> index 7540a25..aa17ee6 100644
> --- a/net/ipv6/addrconf.c
> +++ b/net/ipv6/addrconf.c
> @@ -2756,31 +2756,6 @@ static void addrconf_addr_gen(struct inet6_dev *idev, bool prefix_route)
>  	}
>  }
>  
> -static void addrconf_dev_config(struct net_device *dev)
> -{
> -	struct inet6_dev *idev;
> -
> -	ASSERT_RTNL();
> -
> -	if ((dev->type != ARPHRD_ETHER) &&
> -	    (dev->type != ARPHRD_FDDI) &&
> -	    (dev->type != ARPHRD_ARCNET) &&
> -	    (dev->type != ARPHRD_INFINIBAND) &&
> -	    (dev->type != ARPHRD_IEEE802154) &&
> -	    (dev->type != ARPHRD_IEEE1394) &&
> -	    (dev->type != ARPHRD_TUNNEL6) &&
> -	    (dev->type != ARPHRD_6LOWPAN)) {
> -		/* Alas, we support only Ethernet autoconfiguration. */
> -		return;
> -	}
> -
> -	idev = addrconf_add_dev(dev);
> -	if (IS_ERR(idev))
> -		return;
> -
> -	addrconf_addr_gen(idev, false);
> -}
> -
>  #if IS_ENABLED(CONFIG_IPV6_SIT)
>  static void addrconf_sit_config(struct net_device *dev)
>  {
> @@ -2811,20 +2786,54 @@ static void addrconf_sit_config(struct net_device *dev)
>  }
>  #endif
>  
> -#if IS_ENABLED(CONFIG_NET_IPGRE)
> -static void addrconf_gre_config(struct net_device *dev)
> +static void addrconf_dev_config(struct net_device *dev)
>  {
>  	struct inet6_dev *idev;
> +	bool prefix_route;
>  
>  	ASSERT_RTNL();
>  
> +	switch (dev->type) {
> +	case ARPHRD_LOOPBACK:
> +		init_loopback(dev);
> +		return;
> +
> +	case ARPHRD_ETHER:
> +	case ARPHRD_FDDI:
> +	case ARPHRD_ARCNET:
> +	case ARPHRD_INFINIBAND:
> +	case ARPHRD_IEEE802154:
> +	case ARPHRD_IEEE1394:
> +	case ARPHRD_TUNNEL6:
> +	case ARPHRD_6LOWPAN:
> +		prefix_route = false;
> +		break;
> +
> +#if IS_ENABLED(CONFIG_NET_IPGRE)
> +	case ARPHRD_IPGRE:
> +		/* XXX: This special-case behaviour is there to have a
> +		 * fe80::/64 route around even if no link-local address gets
> +		 * generated, which happens when gre's local == 0.0.0.0.
> +		 * See commit 08b4465 for more information. */
> +		prefix_route = true;
> +		break;
> +#endif

I don't see a need for the macro protection any more. We can drop this
now.

David, can you respin this series without the macros and maybe add the

"case ARPHRD_IP6GRE:" stuff

as a separate patch (which should also go into net/stable). If you don't
want to do this, I also can take care of this, no problem.

You can then repost this one separate and state in the comment section
that this cleanup patch depends on the other two, so Dave can merge it
accordingly to net and net-next?

Otherwise this patch is fine, thanks!
