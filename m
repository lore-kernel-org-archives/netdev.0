From: "Yankejian (Hackim Yim)" <yankejian@huawei.com>
Subject: Re: [patch net-next 05/11] net: hns: add uniform interface for phy
 connection
Date: Mon, 16 May 2016 08:40:24 +0800
Message-ID: <573916F8.50005@huawei.com>
References: <1463127557-90824-1-git-send-email-Yisen.Zhuang@huawei.com>
 <1463127557-90824-6-git-send-email-Yisen.Zhuang@huawei.com>
 <1463144845.17131.342.camel@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <arnd@arndb.de>, <andrew@lunn.ch>, <geliangtang@163.com>,
	<ivecera@redhat.com>, <fengguang.wu@intel.com>,
	<charles.chenxin@huawei.com>, <haifeng.wei@huawei.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<linuxarm@huawei.com>
To: Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
	Yisen Zhuang <Yisen.Zhuang@huawei.com>, <davem@davemloft.net>,
	<rjw@rjwysocki.net>, <lenb@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1463144845.17131.342.camel@linux.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 2016/5/13 21:07, Andy Shevchenko wrote:
> On Fri, 2016-05-13 at 16:19 +0800, Yisen Zhuang wrote:
>> From: Kejian Yan <yankejian@huawei.com>
>>
>> As device_node is only used by OF case, HNS needs to treat the others
>> cases including ACPI. It needs to use uniform ways to handle both of
>> OF and ACPI. This patch chooses phy_device, and of_phy_connect and
>> of_phy_attach are only used by OF case. It needs to add uniform
>> interface
>> to handle that sequence by both OF and ACPI.
> --- a/drivers/net/ethernet/hisilicon/hns/hns_enet.c
>> +++ b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
>> @@ -987,6 +987,41 @@ static void hns_nic_adjust_link(struct net_device
>> *ndev)
>>  	h->dev->ops->adjust_link(h, ndev->phydev->speed, ndev-
>>> phydev->duplex);
>>  }
>>  
>> +static
>> +struct phy_device *hns_nic_phy_attach(struct net_device *dev,
>> +				      struct phy_device *phy,
>> +				      u32 flags,
>> +				      phy_interface_t iface)
>> +{
>> +	int ret;
>> +
>> +	if (!phy)
>> +		return NULL;
> No need to use defensive programming here.
>
>> +
>> +	ret = phy_attach_direct(dev, phy, flags, iface);
>> +
>> +	return ret ? NULL : phy;
> Shouldn't it return an error?
>
>
>> +}
>> +
>> +static
>> +struct phy_device *hns_nic_phy_connect(struct net_device *dev,
>> +				       struct phy_device *phy,
>> +				       void (*hndlr)(struct
>> net_device *),
>> +				       u32 flags,
>> +				       phy_interface_t iface)
>> +{
>> +	int ret;
>> +
>> +	if (!phy)
>> +		return NULL;
>> +
>> +	phy->dev_flags = flags;
>> +
>> +	ret = phy_connect_direct(dev, phy, hndlr, iface);
>> +
>> +	return ret ? NULL : phy;
>> +}
>> +
> For now looks that above functions are redundant and you may call them
> directly in below code.

Hi Andy,
Thanks for you suggestions, it will be fixed in next submit

MBR,
Kejian

>>  /**
>>   *hns_nic_init_phy - init phy
>>   *@ndev: net device
>> @@ -996,16 +1031,17 @@ static void hns_nic_adjust_link(struct
>> net_device *ndev)
>>  int hns_nic_init_phy(struct net_device *ndev, struct hnae_handle *h)
>>  {
>>  	struct hns_nic_priv *priv = netdev_priv(ndev);
>> -	struct phy_device *phy_dev = NULL;
>> +	struct phy_device *phy_dev = h->phy_dev;
>>  
>> -	if (!h->phy_node)
>> +	if (!h->phy_dev)
>>  		return 0;
>>  
>>  	if (h->phy_if != PHY_INTERFACE_MODE_XGMII)
>> -		phy_dev = of_phy_connect(ndev, h->phy_node,
>> -					 hns_nic_adjust_link, 0, h-
>>> phy_if);
>> +		phy_dev = hns_nic_phy_connect(ndev, phy_dev,
>> +					      hns_nic_adjust_link,
>> +					      0, h->phy_if);
>>  	else
>> -		phy_dev = of_phy_attach(ndev, h->phy_node, 0, h-
>>> phy_if);
>> +		phy_dev = hns_nic_phy_attach(ndev, phy_dev, 0, h-
>>> phy_if);
>
