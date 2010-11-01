From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 4/4] Ethtool: convert get_tx_csum/set_tx_csum calls to
 hw_features flags
Date: Mon, 01 Nov 2010 21:38:57 +0000
Message-ID: <1288647537.2231.81.camel@achroite.uk.solarflarecom.com>
References: <cover.1288496404.git.mirq-linux@rere.qmqm.pl>
	 <904bc8c98062fc793573ee6bc120ed0b8af292d2.1288496405.git.mirq-linux@rere.qmqm.pl>
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
Received: from exchange.solarflare.com ([216.237.3.220]:26651 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755220Ab0KAVjC convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Nov 2010 17:39:02 -0400
In-Reply-To: <904bc8c98062fc793573ee6bc120ed0b8af292d2.1288496405.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2010-10-31 at 02:09 +0200, Micha=C5=82 Miros=C5=82aw wrote:
[...]
> diff --git a/drivers/net/dm9000.c b/drivers/net/dm9000.c
> index 9f6aeef..5ba4535 100644
> --- a/drivers/net/dm9000.c
> +++ b/drivers/net/dm9000.c
> @@ -132,7 +132,6 @@ typedef struct board_info {
>  	u32		wake_state;
> =20
>  	int		rx_csum;
> -	int		can_csum;
>  	int		ip_summed;
>  } board_info_t;
> =20
> @@ -480,7 +479,7 @@ static int dm9000_set_rx_csum_unlocked(struct net=
_device *dev, uint32_t data)
>  {
>  	board_info_t *dm =3D to_dm9000_board(dev);
> =20
> -	if (dm->can_csum) {
> +	if (dev->hw_features & NETIF_F_IP_CSUM) {

This is a bit ugly because can_csum is being used to indicate RX
checksum offload capability whereas the checksum feature flags logicall=
y
indicate TX checksum offload capability.  Of course, the two hardware
features are highly correlated!

[...]
> diff --git a/net/core/ethtool.c b/net/core/ethtool.c
> index 9b0e598..95e8b7a 100644
> --- a/net/core/ethtool.c
> +++ b/net/core/ethtool.c
[...]
> @@ -1077,12 +1039,18 @@ static int __ethtool_set_sg(struct net_device=
 *dev, u32 data)
>  	return 0;
>  }
> =20
> +static u32 ethtool_get_tx_csum(struct net_device *dev)
> +{
> +	return (dev->features & (NETIF_F_ALL_CSUM|NETIF_F_SCTP_CSUM)) !=3D =
0;
> +}
> +
[...]

It seems to me that NETIF_F_SCTP_CSUM should be added to
NETIF_F_ALL_CSUM, though that may cause problems in some other places
NETIF_F_ALL_CSUM is used.

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

