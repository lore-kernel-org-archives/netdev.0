From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next RFC 5/9] net: dsa: forward hardware timestamping
 ioctls to switch driver
Date: Thu, 28 Sep 2017 10:25:34 -0700
Message-ID: <cb36aecc-3649-e22a-0fd4-0babbb691c8c@gmail.com>
References: <1506612341-18061-1-git-send-email-brandon.streiff@ni.com>
 <1506612341-18061-6-git-send-email-brandon.streiff@ni.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Richard Cochran <richardcochran@gmail.com>,
        Erik Hons <erik.hons@ni.com>
To: Brandon Streiff <brandon.streiff@ni.com>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1506612341-18061-6-git-send-email-brandon.streiff@ni.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/28/2017 08:25 AM, Brandon Streiff wrote:
> This patch adds support to the dsa slave network device so that
> switch drivers can implement the SIOC[GS]HWTSTAMP ioctls and the
> ethtool timestamp-info interface.
> 
> Signed-off-by: Brandon Streiff <brandon.streiff@ni.com>
> ---

>  struct dsa_switch_driver {
> diff --git a/net/dsa/slave.c b/net/dsa/slave.c
> index bf8800d..2cf6a83 100644
> --- a/net/dsa/slave.c
> +++ b/net/dsa/slave.c
> @@ -264,10 +264,34 @@ dsa_slave_fdb_dump(struct sk_buff *skb, struct netlink_callback *cb,
>  
>  static int dsa_slave_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
>  {
> +	struct dsa_slave_priv *p = netdev_priv(dev);
> +	struct dsa_switch *ds = p->dp->ds;
> +	int port = p->dp->index;
> +
>  	if (!dev->phydev)
>  		return -ENODEV;
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
> +	case SIOCGHWTSTAMP:
> +		if (ds->ops->port_hwtstamp_get)
> +			return ds->ops->port_hwtstamp_get(ds, port, ifr);
> +		else
> +			return -EOPNOTSUPP;
> +	case SIOCSHWTSTAMP:
> +		if (ds->ops->port_hwtstamp_set)
> +			return ds->ops->port_hwtstamp_set(ds, port, ifr);
> +		else
> +			return -EOPNOTSUPP;
> +	default:
> +		return -EOPNOTSUPP;
> +	}

This echoes back to Andrew's comments in patch 2, but we may have to
prefer PHY timestamping over MAC timestamping if both are available?
Richard, is that usually how the preference should be made?
--
Florian
