From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 01/11] net: dsa: make EEE ops optional
Date: Tue, 1 Aug 2017 16:07:20 +0200
Message-ID: <20170801140720.GD23157@lunn.ch>
References: <20170731221719.16695-1-vivien.didelot@savoirfairelinux.com>
 <20170731221719.16695-2-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170731221719.16695-2-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Vivien

> @@ -646,38 +646,42 @@ static int dsa_slave_set_eee(struct net_device *dev, struct ethtool_eee *e)
>  {
>  	struct dsa_slave_priv *p = netdev_priv(dev);
>  	struct dsa_switch *ds = p->dp->ds;
> -	int ret;
> +	int err = -ENODEV;
>  
> -	if (!ds->ops->set_eee)
> -		return -EOPNOTSUPP;
> +	if (ds->ops->set_eee) {
> +		err = ds->ops->set_eee(ds, p->dp->index, p->phy, e);
> +		if (err)
> +			return err;
> +	}
>  
> -	ret = ds->ops->set_eee(ds, p->dp->index, p->phy, e);
> -	if (ret)
> -		return ret;
> +	if (p->phy) {
> +		err = phy_ethtool_set_eee(p->phy, e);
> +		if (err)
> +			return err;

I don't think you need this if (err). You unconditionally return err
as you exit the function.

> +	}
>  
> -	if (p->phy)
> -		ret = phy_ethtool_set_eee(p->phy, e);
> -
> -	return ret;
> +	return err;




>  }
>  
>  static int dsa_slave_get_eee(struct net_device *dev, struct ethtool_eee *e)
>  {
>  	struct dsa_slave_priv *p = netdev_priv(dev);
>  	struct dsa_switch *ds = p->dp->ds;
> -	int ret;
> +	int err = -ENODEV;
>  
> -	if (!ds->ops->get_eee)
> -		return -EOPNOTSUPP;
> +	if (ds->ops->get_eee) {
> +		err = ds->ops->get_eee(ds, p->dp->index, e);
> +		if (err)
> +			return err;
> +	}
>  
> -	ret = ds->ops->get_eee(ds, p->dp->index, e);
> -	if (ret)
> -		return ret;
> +	if (p->phy) {
> +		err = phy_ethtool_get_eee(p->phy, e);
> +		if (err)
> +			return err;

Same here.

> +	}
>  
> -	if (p->phy)
> -		ret = phy_ethtool_get_eee(p->phy, e);
> -
> -	return ret;
> +	return err;
>  }
>  
>  #ifdef CONFIG_NET_POLL_CONTROLLER
> -- 
> 2.13.3
> 
