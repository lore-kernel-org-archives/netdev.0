From: Yevgeny Petrilin <yevgenyp@mellanox.com>
Subject: RE: [PATCH 3/3] net/mlx4_en: Add HW timestamping (TS) support
Date: Fri, 28 Sep 2012 14:10:33 +0000
Message-ID: <953B660C027164448AE903364AC447D287223851@MTLDAG01.mtl.com>
References: <1348826603-17439-1-git-send-email-yevgenyp@mellanox.com>
 <1348826603-17439-4-git-send-email-yevgenyp@mellanox.com>
 <20120928111147.GA7474@netboy.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eugenia Emantayev <eugenia@mellanox.com>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog111.obsmtp.com ([207.126.144.131]:39464 "HELO
	eu1sys200aog111.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1756714Ab2I1OKj convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Sep 2012 10:10:39 -0400
In-Reply-To: <20120928111147.GA7474@netboy.at.omicron.at>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> > index edd9cb8..10fa453 100644
> > --- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> > +++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> > @@ -1517,6 +1517,60 @@ static int mlx4_en_change_mtu(struct net_device
> *dev, int new_mtu)
> >  	return 0;
> >  }
> >
> > +static int mlx4_en_hwtstamp_ioctl(struct net_device *dev, struct ifreq *ifr)
> > +{
> > +	struct mlx4_en_priv *priv = netdev_priv(dev);
> > +	struct mlx4_en_dev *mdev = priv->mdev;
> > +	struct hwtstamp_config config;
> > +
> > +	if (copy_from_user(&config, ifr->ifr_data, sizeof(config)))
> > +		return -EFAULT;
> > +
> > +	/* reserved for future extensions */
> > +	if (config.flags)
> > +		return -EINVAL;
> > +
> > +	/* device doesn't support time stamping */
> > +	if (!(mdev->dev->caps.flags2 & MLX4_DEV_CAP_FLAG2_TS_EN))
> > +		return -EINVAL;
> > +
> > +	/* TX HW timestamp */
> > +	switch (config.tx_type) {
> > +	case HWTSTAMP_TX_OFF:
> > +	case HWTSTAMP_TX_ON:
> > +		break;
> > +	default:
> > +		return -ERANGE;
> > +	}
> > +
> > +	/* RX HW timestamp */
> > +	switch (config.rx_filter) {
> > +	case HWTSTAMP_FILTER_NONE:
> > +	case HWTSTAMP_FILTER_ALL:
> > +		break;
> > +	default:
> 
> Instead of rejecting the HWTSTAMP_FILTER_PTP_ codes out of hand, you
> should just accept them, and return by promoting rx_filter to
> HWTSTAMP_FILTER_ALL.
> 
> [ See Documentation/networking/timestamping.txt ]
> 
> > +		return -ERANGE;
> > +	}
> > +
> > +	if (mlx4_en_timestamp_config(dev, config.tx_type, config.rx_filter)) {
> > +		config.tx_type = HWTSTAMP_TX_OFF;
> > +		config.rx_filter = HWTSTAMP_FILTER_NONE;
> > +	}
> > +
> > +	return copy_to_user(ifr->ifr_data, &config,
> > +			    sizeof(config)) ? -EFAULT : 0;
> > +}
> 
> ...
> 
> > @@ -363,6 +368,9 @@ struct mlx4_en_dev {
> >  	u32                     priv_pdn;
> >  	spinlock_t              uar_lock;
> >  	u8			mac_removed[MLX4_MAX_PORTS + 1];
> > +	struct cyclecounter	cycles;
> > +	struct timecounter	clock;
> > +	struct timecompare	compare;
> 
> I am working on a patch to remove the timecompare stuff altogether
> (after removing it from blackfin). It is and was a bad idea, I would
> hate to see new drivers using it.
> 
> I strongly recommend just offering raw hardware time stamps in
> nanosecond resolution. Also, why not expose your device as a PTP
> Hardware Clock?
> 
> Thanks,
> Richard

Hello Richard,
Thanks for your feedback,
Will address all your comments in V1 of this patchset.

Thanks,
Yevgeny 
