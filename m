From: Yunsheng Lin <linyunsheng@huawei.com>
Subject: Re: [PATCH NET v3 1/2] net: phy: Add phy loopback support in net phy
 framework
Date: Sat, 24 Jun 2017 14:15:27 +0800
Message-ID: <13778697-eebb-0787-33dc-a57112f45046@huawei.com>
References: <1498211042-240816-1-git-send-email-linyunsheng@huawei.com>
 <1498211042-240816-2-git-send-email-linyunsheng@huawei.com>
 <20170624031231.GG4875@lunn.ch>
 <0fa5d2df-741e-06ba-96f3-567f47f82e3e@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <f.fainelli@gmail.com>, <liguozhu@hisilicon.com>,
        <linuxarm@huawei.com>, <linux-kernel@vger.kernel.org>,
        <netdev@vger.kernel.org>, <davem@davemloft.net>,
        <tremyfr@gmail.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([45.249.212.189]:7936 "EHLO
        szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751215AbdFXGQA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 24 Jun 2017 02:16:00 -0400
In-Reply-To: <0fa5d2df-741e-06ba-96f3-567f47f82e3e@huawei.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2017/6/24 11:40, Yunsheng Lin wrote:
> Hi, Andrew
> 
> On 2017/6/24 11:12, Andrew Lunn wrote:
>>> +int phy_loopback(struct phy_device *phydev, bool enable)
>>> +{
>>> +	struct phy_driver *phydrv = to_phy_driver(phydev->mdio.dev.driver);
>>> +	int ret = 0;
>>> +
>>> +	if (enable && phydev->loopback_enabled)
>>> +		return -EBUSY;
>>> +
>>> +	if (!enable && !phydev->loopback_enabled)
>>> +		return -EINVAL;
>>> +
>>> +	if (phydev->drv && phydrv->set_loopback)
>>> +		ret = phydrv->set_loopback(phydev, enable);
>>
>>    	else
>> 		ret = -EOPNOTSUPP;
>>
>>> +
>>> +	if (ret)
>>> +		return ret;
>>> +
>>> +	phydev->loopback_enabled = enable;
>>> +
>>> +	return 0;
>>> +}
>>> +EXPORT_SYMBOL(phy_loopback);
>>
>> One of the comments we made of the PHY code in the hns driver is that
>> its locking is completely broken. You have made the same error
>> here. The core needs to hold the mutex while calling into the PHY
>> driver.
> Do you mean hns_nic_config_phy_loopback need to hold the mutex while
> calling phy_loopback? and other place that calling phy_* function?
I took some time looking into how to take mutex in phy core, here is what
I find:
phy_resume call phydrv->resume without take mutex.
if phy driver implement resume function, for example marvell_resume, then

static int marvell_resume(struct phy_device *phydev)
{
	int err;

	/* Resume the fiber mode first */
	if (!(phydev->supported & SUPPORTED_FIBRE)) {
		err = phy_write(phydev, MII_MARVELL_PHY_PAGE, MII_M1111_FIBER);
		if (err < 0)
			goto error;

		/* With the page set, use the generic resume */
		err = genphy_resume(phydev);
		if (err < 0)
			goto error;

		/* Then, the copper link */
		err = phy_write(phydev, MII_MARVELL_PHY_PAGE, MII_M1111_COPPER);
		if (err < 0)
			goto error;
	}

the code above executes without holding a mutex expect genphy_resume

	/* With the page set, use the generic resume */
	return genphy_resume(phydev);

error:
	phy_write(phydev, MII_MARVELL_PHY_PAGE, MII_M1111_COPPER);
	return err;
}

So I think the correct way to hold a lock is in phy_* function, not in genphy_*,
and current genphy_resume and phy_resume is broken in this way.
Please let me know if I misunderstand the mutex taking in phy core.

Best Regards
Yunsheng Lin
