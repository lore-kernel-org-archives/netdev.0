From: Yunsheng Lin <linyunsheng@huawei.com>
Subject: Re: [PATCH NET V5 2/2] net: hns: Use phy_driver to setup Phy loopback
Date: Thu, 29 Jun 2017 10:35:25 +0800
Message-ID: <1bff07ed-d423-dfa2-61e3-3f35c4536632@huawei.com>
References: <1498443039-134503-1-git-send-email-linyunsheng@huawei.com>
 <1498443039-134503-3-git-send-email-linyunsheng@huawei.com>
 <20170626134235.GC2623@lunn.ch>
 <17132762-9b94-bc32-fee8-e90a6db5762a@huawei.com>
 <20170627132958.GA9921@lunn.ch>
 <3d382bc6-f7b6-9df3-8bb0-fee55b72ac74@huawei.com>
 <20170628202819.GA22815@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <f.fainelli@gmail.com>,
        <huangdaode@hisilicon.com>, <xuwei5@hisilicon.com>,
        <liguozhu@hisilicon.com>, <Yisen.Zhuang@huawei.com>,
        <gabriele.paoloni@huawei.com>, <john.garry@huawei.com>,
        <linuxarm@huawei.com>, <salil.mehta@huawei.com>,
        <lipeng321@huawei.com>, <tremyfr@gmail.com>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170628202819.GA22815@lunn.ch>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi, Andrew

On 2017/6/29 4:28, Andrew Lunn wrote:
>>> >From your description, it sounds like you can call phy_resume() on a
>>> device which is not suspended. 
>> Do you mean after calling dev_close, the device is still not suspended?
> 
> You only call dev_close() if the device is running. What if somebody
> runs the self test on an interface when it has never been opened? It
> looks like you will call phy_resume(). But since it has never been
> suspended, you could be in trouble.
Here is what I can think of:
1. when the mac driver is first loaded, the phy has a default state. suspended?
2. If user runs the self test after using 'ifconfig ethX down', then I suppose
phy is already suspended.

Also I don't quite understand what do you mean by in trouble. Right now in phy
core, phy_resume return ok even the phy is not suspended.

Best Regards
Yunsheng Lin
>>
>> In general, suspend is expected to
>>> store away state which will be lost when powering down a
>>> device. Resume writes that state back into the device after it is
>>> powered up. So resuming a device which was never suspended could write
>>> bad state into it.
>>
>> Do you mean phydev->suspended has bad state?
> 
> phy_resume() current does not check the phydev->suspended state.
> 
>>> Also, what about if WOL has been set before closing the device?
>>
>> phy_suspend will return errro.
>>
>> int phy_suspend(struct phy_device *phydev)
>> {
>> 	struct phy_driver *phydrv = to_phy_driver(phydev->mdio.dev.driver);
>> 	struct ethtool_wolinfo wol = { .cmd = ETHTOOL_GWOL };
>> 	int ret = 0;
>>
>> 	/* If the device has WOL enabled, we cannot suspend the PHY */
>> 	phy_ethtool_get_wol(phydev, &wol);
>> 	if (wol.wolopts)
>> 		return -EBUSY;
>>
>> 	if (phydev->drv && phydrv->suspend)
>> 		ret = phydrv->suspend(phydev);
>>
>> 	if (ret)
>> 		return ret;
>>
>> 	phydev->suspended = true;
>>
>> 	return ret;
>> }
> 
> Which means when you call phy_resume() in lb_setup() you are again
> resuming a device which is not suspended...
> 
> 	 Andrew
> 
> .
> 
