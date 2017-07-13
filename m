From: "Aviad Krawczyk (A)" <aviad.krawczyk@huawei.com>
Subject: Re: [PATCH net 01/20] net/hinic: Initialize hw interface
Date: Thu, 13 Jul 2017 16:14:01 +0300
Message-ID: <52493b35-c0d7-99ae-cecf-0a26d904a31e@huawei.com>
References: <cover.1499865197.git.aviad.krawczyk@huawei.com>
 <281a172bd66298acb1a176a03a53710c1b777fb6.1499865197.git.aviad.krawczyk@huawei.com>
 <20170712152933.GF2557@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <linux-kernel@vger.kernel.org>,
        <netdev@vger.kernel.org>, <bc.y@huawei.com>,
        <victor.gissin@huawei.com>, <zhaochen6@huawei.com>,
        <tony.qu@huawei.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170712152933.GF2557@lunn.ch>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hi Andrew,

Now is the merge window and we need to resubmit.
We will fix it when we will resubmit.

The version number was used for the ethtool information and module version and
will be removed.

devm_kzalloc - will be used for the allocation of the memory at initialization.

We used pr_ for messages that point on errors or information in module,
and dev_ for errors in device and netif_ for errors in network device operations.
netif_ will be used for network device ops and dev_ for the others.

Aviad

On 7/12/2017 6:29 PM, Andrew Lunn wrote:
>> +
>> +#define HINIC_DRV_NAME		"HiNIC"
>> +#define HINIC_DRV_VERSION	"1.0"
> 
> Hi Aviad
> 
> Please don't add a driver version. There was a discussion about this
> recently, how pointless it is.
> 
>> +/**
>> + * hinic_init_hwdev - Initialize the NIC HW
>> + * @hwdev: the NIC HW device that is returned from the initialization
>> + * @pdev: the NIC pci device
>> + *
>> + * Return 0 - Success, negative - Failure
>> + *
>> + * Initialize the NIC HW device and return a pointer to it in the first arg
>> + **/
>> +int hinic_init_hwdev(struct hinic_hwdev **hwdev, struct pci_dev *pdev)
>> +{
>> +	struct hinic_pfhwdev *pfhwdev;
>> +	struct hinic_hwif *hwif;
>> +	int err;
>> +
>> +	hwif = kzalloc(sizeof(*hwif), GFP_KERNEL);
> 
> Using the devm_ functions makes your cleanup code simpler when
> handling memory.
> 
>> +/**
>> + * nic_dev_init - Initialize the NIC device
>> + * @pdev: the NIC pci device
>> + *
>> + * Return 0 - Success, negative - Failure
>> + **/
>> +static int nic_dev_init(struct pci_dev *pdev)
>> +{
>> +	struct hinic_dev *nic_dev;
>> +	struct net_device *netdev;
>> +	struct hinic_hwdev *hwdev;
>> +	int err, num_qps;
>> +
>> +	err = hinic_init_hwdev(&hwdev, pdev);
>> +	if (err) {
>> +		dev_err(&pdev->dev, "Failed to initialize HW device\n");
>> +		return err;
>> +	}
>> +
>> +	num_qps = hinic_hwdev_num_qps(hwdev);
>> +	if (num_qps <= 0) {
>> +		dev_err(&pdev->dev, "Invalid number of QPS\n");
>> +		err = -EINVAL;
>> +		goto num_qps_err;
>> +	}
>> +
>> +	netdev = alloc_etherdev_mq(sizeof(*nic_dev), num_qps);
>> +	if (!netdev) {
>> +		pr_err("Failed to allocate Ethernet device\n");
> 
> Above you used dev_err, here you used pr_err(). Please be consistent.
> 
>> +		err = -ENOMEM;
>> +		goto alloc_etherdev_err;
>> +	}
>> +
>> +	netdev->netdev_ops = &hinic_netdev_ops;
>> +
>> +	nic_dev = (struct hinic_dev *)netdev_priv(netdev);
>> +	nic_dev->hwdev = hwdev;
>> +	nic_dev->netdev = netdev;
>> +	nic_dev->msg_enable = MSG_ENABLE_DEFAULT;
>> +
>> +	pci_set_drvdata(pdev, netdev);
>> +
>> +	netif_carrier_off(netdev);
>> +
>> +	err = register_netdev(netdev);
>> +	if (err) {
>> +		netif_err(nic_dev, probe, netdev, "Failed to register netdev\n");
> 
> probably not a good idea to use netif_err, if register_netdev just
> failed. dev_err() would be better.
> 
> 
> .
>
