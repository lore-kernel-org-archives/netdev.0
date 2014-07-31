From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [RFC alternate] ipv6: addrconf: clean up device type handling
Date: Thu, 31 Jul 2014 11:27:08 +0200
Message-ID: <1406798828.15894.31.camel@localhost>
References: <20140730153503.GJ801478@jupiter.n2.diac24.net>
	 <1406735921-122830-1-git-send-email-equinox@diac24.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>,
	Jiri Pirko <jiri@resnulli.us>
To: David Lamparter <equinox@diac24.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:36466 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932265AbaGaJ1K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jul 2014 05:27:10 -0400
Received: from compute4.internal (compute4.nyi.internal [10.202.2.44])
	by gateway1.nyi.internal (Postfix) with ESMTP id 1A419238CA
	for <netdev@vger.kernel.org>; Thu, 31 Jul 2014 05:27:10 -0400 (EDT)
In-Reply-To: <1406735921-122830-1-git-send-email-equinox@diac24.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mi, 2014-07-30 at 17:58 +0200, David Lamparter wrote:
> This realigns addrconf support for the various lower-layer device types,
> and removes a little bit of duplicate code.
> 
> For GRE devices, this includes a semantic change in that there is now a
> ff00::/8 route installed on address autogeneration.  This was previously
> missing and broke any kind of IPv6 multicast - unless another address
> was configured from userspace (which then added the missing ff00::/8).
> 
> Fixes: aee80b54b235 (ipv6: generate link local address for GRE tunnel)
> Signed-off-by: David Lamparter <equinox@diac24.net>
> Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Cc: Stephen Hemminger <stephen@networkplumber.org>
> Cc: Jiri Pirko <jiri@resnulli.us>
> ---
> 
> This is an alternate version, yanking the switch() down and removing
> dev_config/gre_config duplication.  I have no idea what rationale is behind
> prefix_route - the result is a fe80::/64 route, but no address, which is not a
> functioning configuration.  Jiri, you touched this just a few weeks ago, can
> you comment?  (The "XXX: why is GRE special?")

IIRC some time ago it was decided that randomizing the perm_addr and
generate LL addresses based on that is not the way to go and fragile. We
have this behaviour for ipv6 tunnels, but (IIRC) should not be expanded
and leave user space with this burden.

> -#if IS_ENABLED(CONFIG_NET_IPGRE)
> -static void addrconf_gre_config(struct net_device *dev)
> +static void addrconf_dev_config(struct net_device *dev)
>  {
>  	struct inet6_dev *idev;
> +	bool prefix_route;
>  
>  	ASSERT_RTNL();
>  
> -	if ((idev = ipv6_find_idev(dev)) == NULL) {
> -		pr_debug("%s: add_dev failed\n", __func__);
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

We can now also add ARPHRD_IP6GRE, maybe in a separate patch.

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Thanks,
Hannes
