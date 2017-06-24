From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH NET V4 1/2] net: phy: Add phy loopback support in net phy
 framework
Date: Sat, 24 Jun 2017 15:44:36 +0200
Message-ID: <20170624134436.GJ4875@lunn.ch>
References: <1498290554-237317-1-git-send-email-linyunsheng@huawei.com>
 <1498290554-237317-2-git-send-email-linyunsheng@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, f.fainelli@gmail.com,
        huangdaode@hisilicon.com, xuwei5@hisilicon.com,
        liguozhu@hisilicon.com, Yisen.Zhuang@huawei.com,
        gabriele.paoloni@huawei.com, john.garry@huawei.com,
        linuxarm@huawei.com, salil.mehta@huawei.com, lipeng321@huawei.com,
        tremyfr@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Lin Yun Sheng <linyunsheng@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:33901 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751276AbdFXNo6 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 24 Jun 2017 09:44:58 -0400
Content-Disposition: inline
In-Reply-To: <1498290554-237317-2-git-send-email-linyunsheng@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> @@ -1087,7 +1087,7 @@ int phy_suspend(struct phy_device *phydev)
>  {
>  	struct phy_driver *phydrv = to_phy_driver(phydev->mdio.dev.driver);
>  	struct ethtool_wolinfo wol = { .cmd = ETHTOOL_GWOL };
> -	int ret = 0;
> +	int ret = -EOPNOTSUPP;
>  
>  	/* If the device has WOL enabled, we cannot suspend the PHY */
>  	phy_ethtool_get_wol(phydev, &wol);
> @@ -1109,7 +1109,7 @@ int phy_suspend(struct phy_device *phydev)
>  int phy_resume(struct phy_device *phydev)
>  {
>  	struct phy_driver *phydrv = to_phy_driver(phydev->mdio.dev.driver);
> -	int ret = 0;
> +	int ret = -EOPNOTSUPP;
>  
>  	if (phydev->drv && phydrv->resume)
>  		ret = phydrv->resume(phydev);
> @@ -1123,6 +1123,39 @@ int phy_resume(struct phy_device *phydev)
>  }

These changes should be in a separate patch, since they have nothing
to do with loopback. You want lots of small patches, making them
easier to both describe the why it is needed, and easier to review.

What are the implications of this change? Are you sure the power core
code does not understand EOPNOTSUPP as being a real error?

>  EXPORT_SYMBOL(phy_resume);
>  
> +int phy_loopback(struct phy_device *phydev, bool enable)
> +{
> +	struct phy_driver *phydrv = to_phy_driver(phydev->mdio.dev.driver);
> +	int ret = 0;
> +
> +	mutex_lock(&phydev->lock);
> +
> +	if (enable && phydev->loopback_enabled) {
> +		ret = -EBUSY;
> +		goto out;
> +	}
> +
> +	if (!enable && !phydev->loopback_enabled) {
> +		ret = -EINVAL;
> +		goto out;
> +	}
> +
> +	if (phydev->drv && phydrv->set_loopback)
> +		ret = phydrv->set_loopback(phydev, enable);
> +	else
> +		ret = -EOPNOTSUPP;
> +
> +	if (ret)
> +		goto out;
> +
> +	phydev->loopback_enabled = enable;
> +
> +out:
> +	mutex_unlock(&phydev->lock);
> +	return ret;
> +}
> +EXPORT_SYMBOL(phy_loopback);

This looks good now.

     Andrew
