From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] net: better IFF_XMIT_DST_RELEASE support
Date: Mon, 06 Oct 2014 17:50:15 -0400 (EDT)
Message-ID: <20141006.175015.2075737681876306575.davem@davemloft.net>
References: <1412559515.11091.46.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ja@ssi.bg
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38509 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750780AbaJFVuR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Oct 2014 17:50:17 -0400
In-Reply-To: <1412559515.11091.46.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 05 Oct 2014 18:38:35 -0700

> @@ -1001,7 +1001,8 @@ static netdev_features_t bond_fix_features(struct net_device *dev,
>  
>  static void bond_compute_features(struct bonding *bond)
>  {
> -	unsigned int flags, dst_release_flag = IFF_XMIT_DST_RELEASE;
> +	unsigned int dst_release_flag = IFF_XMIT_DST_RELEASE |
> +					IFF_XMIT_DST_RELEASE_PERM;
>  	netdev_features_t vlan_features = BOND_VLAN_FEATURES;
>  	netdev_features_t enc_features  = BOND_ENC_FEATURES;
>  	struct net_device *bond_dev = bond->dev;
> @@ -1037,8 +1038,10 @@ done:
>  	bond_dev->gso_max_segs = gso_max_segs;
>  	netif_set_gso_max_size(bond_dev, gso_max_size);
>  
> -	flags = bond_dev->priv_flags & ~IFF_XMIT_DST_RELEASE;
> -	bond_dev->priv_flags = flags | dst_release_flag;
> +	bond_dev->priv_flags &= ~IFF_XMIT_DST_RELEASE;
> +	if ((bond_dev->priv_flags & IFF_XMIT_DST_RELEASE_PERM) &&
> +	    dst_release_flag == (IFF_XMIT_DST_RELEASE | IFF_XMIT_DST_RELEASE_PERM))
> +		bond_dev->priv_flags |= IFF_XMIT_DST_RELEASE;

I think I might be missing something, but in all of these places where
you add this logic, it looks to me like:

	dst_release_flag = CONSTANT;
	...
	if (... &&
	    dst_release_flags == CONSTANT)

This 'dst_release_flag' variable never changes, so why bother with the
test at all?

Maybe I'm just being dense today...
