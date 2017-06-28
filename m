From: Yunsheng Lin <linyunsheng@huawei.com>
Subject: Re: [PATCH NET V5 2/2] net: hns: Use phy_driver to setup Phy loopback
Date: Wed, 28 Jun 2017 08:59:52 +0800
Message-ID: <3d382bc6-f7b6-9df3-8bb0-fee55b72ac74@huawei.com>
References: <1498443039-134503-1-git-send-email-linyunsheng@huawei.com>
 <1498443039-134503-3-git-send-email-linyunsheng@huawei.com>
 <20170626134235.GC2623@lunn.ch>
 <17132762-9b94-bc32-fee8-e90a6db5762a@huawei.com>
 <20170627132958.GA9921@lunn.ch>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([45.249.212.189]:8389 "EHLO
        szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752694AbdF1BAV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Jun 2017 21:00:21 -0400
In-Reply-To: <20170627132958.GA9921@lunn.ch>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, Andrew

On 2017/6/27 21:29, Andrew Lunn wrote:
>>>> -		phy_write(phy_dev, COPPER_CONTROL_REG, val);
>>>> +		err = phy_resume(phy_dev);
>>>
>>> Maybe this was discussed with an earlier version of these patches. Why
>>> are using phy_resume() and phy_suspend()?
>> When self_test is invoked with ETH_TEST_FL_OFFLINE option, hns mac driver
>> call dev_close to set net dev to offline state if net dev is online.
>> Doing the actual phy loolback test require phy is power up, So phy_resume
>> and phy_suspend are used.
> 
> O.K, so you at least need some comments, because this is not obvious.
> 
>>From your description, it sounds like you can call phy_resume() on a
> device which is not suspended. 
Do you mean after calling dev_close, the device is still not suspended?
If that is the case, is there any way I can ensure the device is suspended?

In general, suspend is expected to
> store away state which will be lost when powering down a
> device. Resume writes that state back into the device after it is
> powered up. So resuming a device which was never suspended could write
> bad state into it.
Do you mean phydev->suspended has bad state?

> 
> Also, what about if WOL has been set before closing the device?
phy_suspend will return errro.

int phy_suspend(struct phy_device *phydev)
{
	struct phy_driver *phydrv = to_phy_driver(phydev->mdio.dev.driver);
	struct ethtool_wolinfo wol = { .cmd = ETHTOOL_GWOL };
	int ret = 0;

	/* If the device has WOL enabled, we cannot suspend the PHY */
	phy_ethtool_get_wol(phydev, &wol);
	if (wol.wolopts)
		return -EBUSY;

	if (phydev->drv && phydrv->suspend)
		ret = phydrv->suspend(phydev);

	if (ret)
		return ret;

	phydev->suspended = true;

	return ret;
}

Best Regard
Yunsheng Lin
