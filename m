From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 3/4] Ethtool: convert get_tso/set_tso calls to
 hw_features flags
Date: Mon, 01 Nov 2010 21:25:54 +0000
Message-ID: <1288646754.2231.70.camel@achroite.uk.solarflarecom.com>
References: <cover.1288496404.git.mirq-linux@rere.qmqm.pl>
	 <db0a20ab6e4ab3f63d782bd2c4a9f7a873ea4a64.1288496404.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	Steve Glendinning <steve.glendinning@smsc.com>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	Rasesh Mody <rmody@brocade.com>,
	Debashis Dutt <ddutt@brocade.com>,
	Kristoffer Glembo <kristoffer@gaisler.com>,
	linux-driver@qlogic.com, linux-net-drivers@solarflare.com
To: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:25891 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752523Ab0KAVZ7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Nov 2010 17:25:59 -0400
In-Reply-To: <db0a20ab6e4ab3f63d782bd2c4a9f7a873ea4a64.1288496404.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2010-10-30 at 10:44 +0200, Micha=C5=82 Miros=C5=82aw wrote:
[...]
> @@ -1670,7 +1668,7 @@ struct net_device *nes_netdev_init(struct nes_d=
evice *nesdev,
>  	netdev->type =3D ARPHRD_ETHER;
>  	netdev->features =3D NETIF_F_HIGHDMA;
>  	netdev->netdev_ops =3D &nes_netdev_ops;
> -	netdev->hw_features |=3D NETIF_F_SG;
> +	netdev->hw_features |=3D NETIF_F_SG|NETIF_F_TSO;

There should be spaces on either side of the '|' operator.

[...]
> diff --git a/drivers/net/atlx/atl1.c b/drivers/net/atlx/atl1.c
> index 9e27bd6..814a06c 100644
> --- a/drivers/net/atlx/atl1.c
> +++ b/drivers/net/atlx/atl1.c
> @@ -2992,6 +2992,7 @@ static int __devinit atl1_probe(struct pci_dev =
*pdev,
>  	netdev->watchdog_timeo =3D 5 * HZ;
> =20
>  	netdev->hw_features |=3D NETIF_F_SG;
> +	netdev->hw_features |=3D NETIF_F_TSO;

Why not set both flags in the same statement?  You might as well make
the drivers consistent in this regard.

[...]
> diff --git a/net/core/ethtool.c b/net/core/ethtool.c
> index 017667c..9b0e598 100644
> --- a/net/core/ethtool.c
> +++ b/net/core/ethtool.c
[...]
> @@ -1065,10 +1048,13 @@ static int __ethtool_set_sg(struct net_device=
 *dev, u32 data)
>  {
>  	int err;
> =20
> -	if (!data && dev->ethtool_ops->set_tso) {
> -		err =3D dev->ethtool_ops->set_tso(dev, 0);
> -		if (err)
> -			return err;
> +	if (!data && (dev->hw_features & NETIF_F_ALL_TSO)) {
> +		if (dev->ethtool_ops->hw_set_tso) {
> +			err =3D dev->ethtool_ops->hw_set_tso(dev, 0);
> +			if (err < 0)
> +				return err;
> +		}
> +		dev->features &=3D dev->hw_features & NETIF_F_ALL_TSO;

Surely this should be:
		dev->features &=3D ~NETIF_F_ALL_TSO;

[...]
> @@ -1158,7 +1149,18 @@ static int ethtool_set_tso(struct net_device *=
dev, char __user *useraddr)
>  	if (edata.data && !(dev->features & NETIF_F_SG))
>  		return -EINVAL;
> =20
> -	return dev->ethtool_ops->set_tso(dev, edata.data);
> +	if (dev->ethtool_ops->hw_set_tso) {
> +		int err =3D dev->ethtool_ops->hw_set_tso(dev, edata.data);
> +		if (err)
> +			return min(err, 0);
[...]

Again, the odd semantics of a positive value need to be documented.

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

