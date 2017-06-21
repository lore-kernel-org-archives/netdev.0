From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH NET] net/hns:bugfix of ethtool -t phy self_test
Date: Wed, 21 Jun 2017 15:34:49 +0200
Message-ID: <20170621133449.GB27585@lunn.ch>
References: <1497605091-94725-1-git-send-email-linyunsheng@huawei.com>
 <7500513f-e263-838c-12a1-4343f7281f1a@gmail.com>
 <08ef77fc-29ab-8262-2126-c547960d5628@huawei.com>
 <20170620132705.GD13704@lunn.ch>
 <524e1181-f90d-0f05-200a-44cfa179dbf3@huawei.com>
 <20170621031320.GA1487@lunn.ch>
 <2a0e4db4-759d-4ce9-f42c-12303898b2c9@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>, davem@davemloft.net,
        huangdaode@hisilicon.com, xuwei5@hisilicon.com,
        liguozhu@hisilicon.com, Yisen.Zhuang@huawei.com,
        gabriele.paoloni@huawei.com, john.garry@huawei.com,
        linuxarm@huawei.com, salil.mehta@huawei.com, lipeng321@huawei.com,
        yankejian@huawei.com, tremyfr@gmail.com, xieqianqian@huawei.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: l00371289 <linyunsheng@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <2a0e4db4-759d-4ce9-f42c-12303898b2c9@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> drivers/net/ph/marvell.c
> marvell_set_loopback(struct phy_device *dev, bool enable)
> {
> 	/* do some device specific setting */
> 	........
> 
> 	return genphy_loopback(dev, enable);
> }
> 
> I don't know if this makes sense or not?

Nope, you want something in phy.c like this. Not compiled, not
tested....

int phy_loopback(struct phy_device *dev, bool enable)
{

	int err;

	mutex_lock(dev->mutex);

	if (enable && dev->loopback_enabled) {
	   err = -EBUSY;
	   goto out;
	}

	if (!enable && !dev->loopback_enabled) {
	   err = -EINVAL;
	   goto out;
	}

	if (dev->drv->loopback)
	   err = dev->drv->loopback(dev, enable);

	if (!err)
	   dev->loopback_enabled = enable

	mutex_unlock(dev->mutex);

out:
	return err;
}
EXPORT_SYMBOL(phy_loopback);

The interesting part is how to handle two attempts to enable loopback.
Should the MAC driver be responsible for preventing that? Or do it in
the PHY driver? And what will the MAC driver do if it gets EBUSY?
Return it to user space?

       Andrew
