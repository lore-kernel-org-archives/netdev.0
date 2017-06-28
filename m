From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH NET V5 2/2] net: hns: Use phy_driver to setup Phy loopback
Date: Wed, 28 Jun 2017 22:28:19 +0200
Message-ID: <20170628202819.GA22815@lunn.ch>
References: <1498443039-134503-1-git-send-email-linyunsheng@huawei.com>
 <1498443039-134503-3-git-send-email-linyunsheng@huawei.com>
 <20170626134235.GC2623@lunn.ch>
 <17132762-9b94-bc32-fee8-e90a6db5762a@huawei.com>
 <20170627132958.GA9921@lunn.ch>
 <3d382bc6-f7b6-9df3-8bb0-fee55b72ac74@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, f.fainelli@gmail.com,
        huangdaode@hisilicon.com, xuwei5@hisilicon.com,
        liguozhu@hisilicon.com, Yisen.Zhuang@huawei.com,
        gabriele.paoloni@huawei.com, john.garry@huawei.com,
        linuxarm@huawei.com, salil.mehta@huawei.com, lipeng321@huawei.com,
        tremyfr@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Yunsheng Lin <linyunsheng@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <3d382bc6-f7b6-9df3-8bb0-fee55b72ac74@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> >>From your description, it sounds like you can call phy_resume() on a
> > device which is not suspended. 
> Do you mean after calling dev_close, the device is still not suspended?

You only call dev_close() if the device is running. What if somebody
runs the self test on an interface when it has never been opened? It
looks like you will call phy_resume(). But since it has never been
suspended, you could be in trouble.
> 
> In general, suspend is expected to
> > store away state which will be lost when powering down a
> > device. Resume writes that state back into the device after it is
> > powered up. So resuming a device which was never suspended could write
> > bad state into it.
>
> Do you mean phydev->suspended has bad state?

phy_resume() current does not check the phydev->suspended state.

> > Also, what about if WOL has been set before closing the device?
>
> phy_suspend will return errro.
> 
> int phy_suspend(struct phy_device *phydev)
> {
> 	struct phy_driver *phydrv = to_phy_driver(phydev->mdio.dev.driver);
> 	struct ethtool_wolinfo wol = { .cmd = ETHTOOL_GWOL };
> 	int ret = 0;
> 
> 	/* If the device has WOL enabled, we cannot suspend the PHY */
> 	phy_ethtool_get_wol(phydev, &wol);
> 	if (wol.wolopts)
> 		return -EBUSY;
> 
> 	if (phydev->drv && phydrv->suspend)
> 		ret = phydrv->suspend(phydev);
> 
> 	if (ret)
> 		return ret;
> 
> 	phydev->suspended = true;
> 
> 	return ret;
> }

Which means when you call phy_resume() in lb_setup() you are again
resuming a device which is not suspended...

	 Andrew
