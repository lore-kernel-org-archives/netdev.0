From: Yunsheng Lin <linyunsheng@huawei.com>
Subject: Re: [PATCH NET V5 2/2] net: hns: Use phy_driver to setup Phy loopback
Date: Tue, 27 Jun 2017 11:25:36 +0800
Message-ID: <17132762-9b94-bc32-fee8-e90a6db5762a@huawei.com>
References: <1498443039-134503-1-git-send-email-linyunsheng@huawei.com>
 <1498443039-134503-3-git-send-email-linyunsheng@huawei.com>
 <20170626134235.GC2623@lunn.ch>
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
In-Reply-To: <20170626134235.GC2623@lunn.ch>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi, Andrew

On 2017/6/26 21:42, Andrew Lunn wrote:
> On Mon, Jun 26, 2017 at 10:10:39AM +0800, Lin Yun Sheng wrote:
>> Use function set_loopback in phy_driver to setup phy loopback
>> when doing ethtool self test.
>>
>> Signed-off-by: Lin Yun Sheng <linyunsheng@huawei.com>
>> ---
>>  drivers/net/ethernet/hisilicon/hns/hnae.h        |  1 +
>>  drivers/net/ethernet/hisilicon/hns/hns_ethtool.c | 92 +++++++-----------------
>>  2 files changed, 26 insertions(+), 67 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/hisilicon/hns/hnae.h b/drivers/net/ethernet/hisilicon/hns/hnae.h
>> index 04211ac..7ba653a 100644
>> --- a/drivers/net/ethernet/hisilicon/hns/hnae.h
>> +++ b/drivers/net/ethernet/hisilicon/hns/hnae.h
>> @@ -360,6 +360,7 @@ enum hnae_loop {
>>  	MAC_INTERNALLOOP_MAC = 0,
>>  	MAC_INTERNALLOOP_SERDES,
>>  	MAC_INTERNALLOOP_PHY,
>> +	MAC_LOOP_PHY_NONE,
>>  	MAC_LOOP_NONE,
>>  };
>>  
>> diff --git a/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c b/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
>> index e95795b..10d82df 100644
>> --- a/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
>> +++ b/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
>> @@ -259,67 +259,24 @@ static int hns_nic_set_link_ksettings(struct net_device *net_dev,
>>  
>>  static int hns_nic_config_phy_loopback(struct phy_device *phy_dev, u8 en)
>>  {
>> -#define COPPER_CONTROL_REG 0
>> -#define PHY_POWER_DOWN BIT(11)
>> -#define PHY_LOOP_BACK BIT(14)
>> -	u16 val = 0;
>> -
>> -	if (phy_dev->is_c45) /* c45 branch adding for XGE PHY */
>> -		return -ENOTSUPP;
>> +	int err;
>>  
>>  	if (en) {
>> -		/* speed : 1000M */
>> -		phy_write(phy_dev, HNS_PHY_PAGE_REG, 2);
>> -		phy_write(phy_dev, 21, 0x1046);
>> -
>> -		phy_write(phy_dev, HNS_PHY_PAGE_REG, 0);
>> -		/* Force Master */
>> -		phy_write(phy_dev, 9, 0x1F00);
>> -
>> -		/* Soft-reset */
>> -		phy_write(phy_dev, 0, 0x9140);
>> -		/* If autoneg disabled,two soft-reset operations */
>> -		phy_write(phy_dev, 0, 0x9140);
>> -
>> -		phy_write(phy_dev, HNS_PHY_PAGE_REG, 0xFA);
>> -
>> -		/* Default is 0x0400 */
>> -		phy_write(phy_dev, 1, 0x418);
>> -
>> -		/* Force 1000M Link, Default is 0x0200 */
>> -		phy_write(phy_dev, 7, 0x20C);
>> -
>> -		/* Powerup Fiber */
>> -		phy_write(phy_dev, HNS_PHY_PAGE_REG, 1);
>> -		val = phy_read(phy_dev, COPPER_CONTROL_REG);
>> -		val &= ~PHY_POWER_DOWN;
>> -		phy_write(phy_dev, COPPER_CONTROL_REG, val);
>> -
>> -		/* Enable Phy Loopback */
>> -		phy_write(phy_dev, HNS_PHY_PAGE_REG, 0);
>> -		val = phy_read(phy_dev, COPPER_CONTROL_REG);
>> -		val |= PHY_LOOP_BACK;
>> -		val &= ~PHY_POWER_DOWN;
>> -		phy_write(phy_dev, COPPER_CONTROL_REG, val);
>> +		err = phy_resume(phy_dev);
> 
> Maybe this was discussed with an earlier version of these patches. Why
> are using phy_resume() and phy_suspend()?
When self_test is invoked with ETH_TEST_FL_OFFLINE option, hns mac driver
call dev_close to set net dev to offline state if net dev is online.
Doing the actual phy loolback test require phy is power up, So phy_resume
and phy_suspend are used.

> 
>>  static int __lb_setup(struct net_device *ndev,
>> @@ -332,10 +289,8 @@ static int __lb_setup(struct net_device *ndev,
>>  
>>  	switch (loop) {
>>  	case MAC_INTERNALLOOP_PHY:
>> -		if ((phy_dev) && (!phy_dev->is_c45)) {
>> -			ret = hns_nic_config_phy_loopback(phy_dev, 0x1);
>> -			ret |= h->dev->ops->set_loopback(h, loop, 0x1);
>> -		}
>> +		ret = hns_nic_config_phy_loopback(phy_dev, 0x1);
>> +		ret |= h->dev->ops->set_loopback(h, loop, 0x1);
> 
> Or'ing together two errno values does not make much sense:
> 
>> +	if (loop == MAC_INTERNALLOOP_PHY)
>> +		ret = __lb_setup(ndev, MAC_LOOP_PHY_NONE);
>> +	else
>> +		ret = __lb_setup(ndev, MAC_LOOP_NONE);
>>  	if (ret)
>>  		netdev_err(ndev, "%s: __lb_setup return error(%d)!\n",
>>  			   __func__,
> 
> And it looks like you even print the OR'ed version here!
> 
Thanks for pointing out, will modify it next version.

Best Regard
Yunsheng Lin
