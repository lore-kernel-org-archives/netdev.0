From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH NET] net/hns:bugfix of ethtool -t phy self_test
Date: Thu, 22 Jun 2017 05:35:05 +0200
Message-ID: <20170622033505.GA4813@lunn.ch>
References: <1497605091-94725-1-git-send-email-linyunsheng@huawei.com>
 <7500513f-e263-838c-12a1-4343f7281f1a@gmail.com>
 <08ef77fc-29ab-8262-2126-c547960d5628@huawei.com>
 <20170620132705.GD13704@lunn.ch>
 <524e1181-f90d-0f05-200a-44cfa179dbf3@huawei.com>
 <20170621031320.GA1487@lunn.ch>
 <2a0e4db4-759d-4ce9-f42c-12303898b2c9@huawei.com>
 <20170621133449.GB27585@lunn.ch>
 <ea80ee9c-f2e5-72ae-5c53-fda1dd755a45@huawei.com>
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
In-Reply-To: <ea80ee9c-f2e5-72ae-5c53-fda1dd755a45@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> I don't think returning to user space is an option, because it mean
> ethtool phy self test would fail because if availability of some software
> resoure, which is not some application would expect. here is what I can
> think of:
> 
> driver/net/ethernet/hisilicon/hns/hns_ethtool.c
> int phy_loopback_selftest(struct phy_device *dev)
> {
> 	int err;
> 
> 	mutex_lock(dev->mutex);
> 
> 	if (dev->drv->loopback)
> 		err = dev->drv->loopback(dev, 1);
> 
> 	if (err)
> 		goto out;
> 	
> 	/* mac driver do the test*/
> 	.................
> 
> 
> 	if (dev->drv->loopback)
> 		err = dev->drv->loopback(dev, 0);
> 
> 	if (err)
> 		goto out;
> 
> out:
> 	mutex_unlock(dev->mutex);
> 	return err;
> }

I don't think you need a mutex here. dev_ioctl.c:

       case SIOCETHTOOL:
                dev_load(net, ifr.ifr_name);
                rtnl_lock();
                ret = dev_ethtool(net, &ifr);
                rtnl_unlock();
 
So all ethtool operations are protected by the rtnl. You cannot have
two tests running at once.

> One question I can think of is that, how do we ensure mac driver enable and
> disable phy loopback in pair, enable loopback after dev->mutex is taken,
> disable loopback  before dev->mutex is released?
> I hope I am not missing something obvious, any suggestion and idea?

You cannot ensure this. But it would be a pretty obvious bug.

    Andrew
