From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: [PATCHv5 2/2] tg3: Allow ethtool to enable/disable loopback.
Date: Sat, 7 May 2011 09:43:21 +0200
Message-ID: <20110507074321.GB4522@rere.qmqm.pl>
References: <1304559247-16111-1-git-send-email-maheshb@google.com>
 <1304749117-1989-1-git-send-email-maheshb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Matt Carlson <mcarlson@broadcom.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Michael Chan <mchan@broadcom.com>,
	Tom Herbert <therbert@google.com>
To: Mahesh Bandewar <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:45863 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752028Ab1EGHnW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 7 May 2011 03:43:22 -0400
Content-Disposition: inline
In-Reply-To: <1304749117-1989-1-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 06, 2011 at 11:18:37PM -0700, Mahesh Bandewar wrote:
> This patch adds tg3_set_features() to handle loopback mode. Currently=
 the
> capability is added for the devices which support internal MAC loopba=
ck mode.
> So when enabled, it enables internal-MAC loopback.
[...]
> diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
> index 7c7c9a8..b7270c2 100644
> --- a/drivers/net/tg3.c
> +++ b/drivers/net/tg3.c
[...]
> @@ -6319,6 +6356,24 @@ static u32 tg3_fix_features(struct net_device =
*dev, u32 features)
>  	return features;
>  }
> =20
> +static int tg3_set_features(struct net_device *dev, u32 features)
> +{
> +	struct tg3 *tp =3D netdev_priv(dev);
> +	u32 changed =3D dev->features ^ features;
> +
> +	if (changed & NETIF_F_LOOPBACK) {
> +		if (tg3_flag(tp, LOOPBACK_ENABLED))
> +			tg3_flag_clear(tp, LOOPBACK_ENABLED);
> +		else
> +			tg3_flag_set(tp, LOOPBACK_ENABLED);
> +
> +		if (netif_running(dev))
> +			tg3_set_loopback(dev);
> +	}
> +
> +	return 0;
> +}
> +
>  static inline void tg3_set_mtu(struct net_device *dev, struct tg3 *t=
p,
>  			       int new_mtu)
>  {
> @@ -9485,6 +9540,13 @@ static int tg3_open(struct net_device *dev)
> =20
>  	netif_tx_start_all_queues(dev);
> =20
> +	/*
> +	 * Reset loopback feature if it was turned on while the device was =
down
> +	 * make sure that it's installed properly now.
> +	 */
> +	if (tg3_flag(tp, LOOPBACK_ENABLED))
> +		tg3_set_loopback(dev);
> +
>  	return 0;
> =20
>  err_out3:
[...]

So, you've just implemented what I said about enabling loopback at the =
end
of tg3_open(), but you also added (redundant) flag that mirrors
dev->features & NETIF_F_LOOPBACK. Why?

Best Regards,
Micha=B3 Miros=B3aw
