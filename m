From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next RFC 5/9] net: dsa: forward hardware timestamping ioctls to switch driver
Date: Thu, 28 Sep 2017 15:31:44 -0400
Message-ID: <877ewiy5zz.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <1506612341-18061-1-git-send-email-brandon.streiff@ni.com> <1506612341-18061-6-git-send-email-brandon.streiff@ni.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-kernel@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Richard Cochran <richardcochran@gmail.com>,
        Erik Hons <erik.hons@ni.com>,
        Brandon Streiff <brandon.streiff@ni.com>
To: Brandon Streiff <brandon.streiff@ni.com>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1506612341-18061-6-git-send-email-brandon.streiff@ni.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Brandon,

Brandon Streiff <brandon.streiff@ni.com> writes:

>  static int dsa_slave_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
>  {
> +	struct dsa_slave_priv *p = netdev_priv(dev);
> +	struct dsa_switch *ds = p->dp->ds;
> +	int port = p->dp->index;
> +
>  	if (!dev->phydev)
>  		return -ENODEV;

Move this check below:

>  
> -	return phy_mii_ioctl(dev->phydev, ifr, cmd);
> +	switch (cmd) {
> +	case SIOCGMIIPHY:
> +	case SIOCGMIIREG:
> +	case SIOCSMIIREG:
> +		if (dev->phydev)
> +			return phy_mii_ioctl(dev->phydev, ifr, cmd);
> +		else
> +			return -EOPNOTSUPP;

                if (!dev->phydev)
                        return -ENODEV;

                return phy_mii_ioctl(dev->phydev, ifr, cmd);

> +	case SIOCGHWTSTAMP:
> +		if (ds->ops->port_hwtstamp_get)
> +			return ds->ops->port_hwtstamp_get(ds, port, ifr);
> +		else
> +			return -EOPNOTSUPP;

Here you can replace the else statement with break;

> +	case SIOCSHWTSTAMP:
> +		if (ds->ops->port_hwtstamp_set)
> +			return ds->ops->port_hwtstamp_set(ds, port, ifr);
> +		else
> +			return -EOPNOTSUPP;

Same here;

> +	default:
> +		return -EOPNOTSUPP;
> +	}

Then drop the default case and return -EOPNOTSUPP after the switch.

>  }


Thanks,

        Vivien
