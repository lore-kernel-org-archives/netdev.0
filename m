From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next] ipv6: addrconf: fix mcast route for GRE devices
Date: Wed, 30 Jul 2014 17:14:42 +0200
Message-ID: <1406733282.5122.12.camel@localhost>
References: <1406681743-104844-1-git-send-email-equinox@diac24.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>
To: David Lamparter <equinox@diac24.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:59284 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753151AbaG3POq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jul 2014 11:14:46 -0400
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by gateway1.nyi.internal (Postfix) with ESMTP id B68602397B
	for <netdev@vger.kernel.org>; Wed, 30 Jul 2014 11:14:44 -0400 (EDT)
In-Reply-To: <1406681743-104844-1-git-send-email-equinox@diac24.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Mi, 2014-07-30 at 02:55 +0200, David Lamparter wrote:
> GRE devices, for some reason, were coming up with an autoconfigured
> address, but no ff00::/8 route in the local table.  This breaks any kind
> of multicast, in particular OSPFv3, mDNS, - and ND.  In fact, IPv6 only
> works at all because there is little need for ND on PtP devices.
> 
> Adding any other IPv6 address on the device would rectify this issue
> through inet6_addr_add()/addrconf_add_dev() - and would leave the route
> around even if the address was later removed.  (This is probably why
> this issue was not discovered earlier.  AFAICS it has been there from
> the beginning, e.g. aee80b5 "generate link local address for GRE
> tunnel")

Yep, this is poor, but changing this will break user space...

> (Note: multicast is supported on GRE devices of all kinds, including PtP
> GRE, P-t-Mcast GRE and NBMA-GRE.)
> 
> Fixes: aee80b54b235 (ipv6: generate link local address for GRE tunnel)
> Signed-off-by: David Lamparter <equinox@diac24.net>
> Cc: Stephen Hemminger <stephen@networkplumber.org>

We should install routes before joining LL, I would go with

        idev = addrconf_add_dev(dev);
        if (IS_ERR(idev))
                return;

in addrconf_gre_config etc.

Looks like we don't correctly configure ARPHRD_IP6GRE gre tunnels...

> ---
>  net/ipv6/addrconf.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> index 0b239fc..655a0df 100644
> --- a/net/ipv6/addrconf.c
> +++ b/net/ipv6/addrconf.c
> @@ -2824,6 +2824,7 @@ static void addrconf_gre_config(struct net_device *dev)
>  	}
>  
>  	addrconf_addr_gen(idev, true);
> +	addrconf_add_mroute(dev);
>  }
>  #endif
>  

Thanks,
Hannes
