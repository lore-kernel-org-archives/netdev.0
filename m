From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: RFC: netdev: allow ethtool physical id to drop rtnl_lock
Date: Fri, 30 Oct 2009 18:47:39 +0100
Message-ID: <4AEB26BB.1050007@gmail.com>
References: <20091030104201.6bb03b23@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:35712 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932601AbZJ3Rri (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Oct 2009 13:47:38 -0400
In-Reply-To: <20091030104201.6bb03b23@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger a =E9crit :
> The ethtool operation to blink LED can take an indeterminately long t=
ime,
> blocking out other operations (via rtnl_lock). This patch is an attem=
pt
> to work around the problem.
>=20
> It does need more discussion, because it will mean that drivers that =
formerly
> were protected from changes during blink aren't.  For example, user c=
ould
> start device blinking, and then plug in cable causing change netlink =
event
> to change state or pull cable and have device come down.
>=20
> The other possibility is to do this on a driver by driver basis
> which is more effort.
>=20
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>=20
>=20
> --- a/net/core/ethtool.c	2009-10-30 10:27:23.621917624 -0700
> +++ b/net/core/ethtool.c	2009-10-30 10:35:53.787670774 -0700
> @@ -17,6 +17,7 @@
>  #include <linux/errno.h>
>  #include <linux/ethtool.h>
>  #include <linux/netdevice.h>
> +#include <linux/rtnetlink.h>
>  #include <asm/uaccess.h>
> =20
>  /*
> @@ -781,6 +782,8 @@ static int ethtool_get_strings(struct ne
>  static int ethtool_phys_id(struct net_device *dev, void __user *user=
addr)
>  {
>  	struct ethtool_value id;
> +	int err;
> +	static int busy;
> =20
>  	if (!dev->ethtool_ops->phys_id)
>  		return -EOPNOTSUPP;
> @@ -788,7 +791,21 @@ static int ethtool_phys_id(struct net_de
>  	if (copy_from_user(&id, useraddr, sizeof(id)))
>  		return -EFAULT;
> =20
> -	return dev->ethtool_ops->phys_id(dev, id.data);
> +	if (busy)
> +		return -EBUSY;
> +
> +	/* This operation may take a long time, drop lock */
> +	busy =3D 1;
> +	dev_hold(dev);
> +	rtnl_unlock();
> +
> +	err =3D dev->ethtool_ops->phys_id(dev, id.data);
> +
> +	rtnl_lock();
> +	dev_put(dev);
> +	busy =3D 0;
> +
> +	return err;
>  }
> =20

It seems reasonable, but why have a global 'busy' flag, and not
private to each netdev ?

