From: "Wei Hu (Xavier)" <xavier.huwei@huawei.com>
Subject: Re: [PATCH v9 11/22] IB/hns: Add IB device registration
Date: Sun, 12 Jun 2016 17:41:06 +0800
Message-ID: <575D2E32.8030109@huawei.com>
References: <1464795484-77395-1-git-send-email-oulijun@huawei.com>
 <1464795484-77395-12-git-send-email-oulijun@huawei.com>
 <20160609062631.GN3663@leon.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <dledford@redhat.com>, <sean.hefty@intel.com>,
	<hal.rosenstock@gmail.com>, <davem@davemloft.net>,
	<jeffrey.t.kirsher@intel.com>, <jiri@mellanox.com>,
	<ogerlitz@mellanox.com>, <linux-rdma@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	<gongyangming@huawei.com>, <xiaokun@huawei.com>,
	<tangchaofei@huawei.com>, <haifeng.wei@huawei.com>,
	<yisen.zhuang@huawei.com>, <yankejian@huawei.com>,
	<charles.chenxin@huawei.com>, <linuxarm@huawei.com>
To: <leon@kernel.org>, Lijun Ou <oulijun@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:5827 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750724AbcFLJsf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Jun 2016 05:48:35 -0400
In-Reply-To: <20160609062631.GN3663@leon.nu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2016/6/9 14:26, Leon Romanovsky wrote:
> On Wed, Jun 01, 2016 at 11:37:53PM +0800, Lijun Ou wrote:
>> This patch registered IB device when loaded, and unregistered
>> IB device when removed.
>>
>> Signed-off-by: Wei Hu <xavier.huwei@huawei.com>
>> Signed-off-by: Nenglong Zhao <zhaonenglong@hisilicon.com>
>> Signed-off-by: Lijun Ou <oulijun@huawei.com>
>> ---
>>   drivers/infiniband/hw/hns/hns_roce_main.c | 46 +++++++++++++++++++++++++++++++
>>   1 file changed, 46 insertions(+)
>>
>> diff --git a/drivers/infiniband/hw/hns/hns_roce_main.c b/drivers/infiniband/hw/hns/hns_roce_main.c
>> index 7fb0d34..f179a7f 100644
>> --- a/drivers/infiniband/hw/hns/hns_roce_main.c
>> +++ b/drivers/infiniband/hw/hns/hns_roce_main.c
>> @@ -62,6 +62,41 @@
>>   #include "hns_roce_device.h"
>>   #include "hns_roce_icm.h"
>>   
>> +void hns_roce_unregister_device(struct hns_roce_dev *hr_dev)
> You are not calling to this function in this patch.
>
>> +{
>> +	ib_unregister_device(&hr_dev->ib_dev);
>> +}
>> +
>> +int hns_roce_register_device(struct hns_roce_dev *hr_dev)
> This function should be static.
>
>> +{
>> +	int ret;
>> +	struct hns_roce_ib_iboe *iboe = NULL;
>> +	struct ib_device *ib_dev = NULL;
>> +	struct device *dev = &hr_dev->pdev->dev;
>> +
>> +	iboe = &hr_dev->iboe;
>> +
>> +	ib_dev = &hr_dev->ib_dev;
>> +	strlcpy(ib_dev->name, "hisi_%d", IB_DEVICE_NAME_MAX);
>> +
>> +	ib_dev->owner			= THIS_MODULE;
>> +	ib_dev->node_type		= RDMA_NODE_IB_CA;
>> +	ib_dev->dma_device		= dev;
>> +
>> +	ib_dev->phys_port_cnt		= hr_dev->caps.num_ports;
>> +	ib_dev->local_dma_lkey		= hr_dev->caps.reserved_lkey;
>> +	ib_dev->num_comp_vectors	= hr_dev->caps.num_comp_vectors;
>> +	ib_dev->uverbs_abi_ver		= 1;
>> +
>> +	ret = ib_register_device(ib_dev, NULL);
>> +	if (ret) {
>> +		dev_err(dev, "ib_register_device failed!\n");
>> +		return ret;
>> +	}
>> +
>> +	return 0;
>> +}
>> +
>>   int hns_roce_get_cfg(struct hns_roce_dev *hr_dev)
>>   {
>>   	int i;
>> @@ -363,6 +398,17 @@ static int hns_roce_probe(struct platform_device *pdev)
>>   		goto error_failed_engine_init;
>>   	}
>>   
>> +	ret = hns_roce_register_device(hr_dev);
>> +	if (ret) {
>> +		dev_err(dev, "register_device failed!\n");
> According to the current code, you will print this error together with
> error line in hns_roce_register_device for the same failure.
>
> "ib_register_device failed!"
> "register_device failed!"
Hi, leon
     In this patch [PATCH v9 11/22], there is only one error branch in 
funtion named hns_roce_register_device.
     In the following patch [PATCH v9 13/22], we add more operation, 
there are more
         than two error branch in this function as below.

  @@ -212,8 +402,27 @@ int hns_roce_register_device(struct hns_roce_dev *hr_dev)
  		goto error_failed_setup_mtu_gids;
  	}
  
	spin_lock_init(&iboe->lock);

	iboe->nb.notifier_call = hns_roce_netdev_event;
	ret = register_netdevice_notifier(&iboe->nb);
	if (ret) {
		dev_err(dev, "register_netdevice_notifier failed!\n");
		goto error_failed_setup_mtu_gids;
	}

	iboe->nb_inet.notifier_call = hns_roce_inet_event;
	ret = register_inetaddr_notifier(&iboe->nb_inet);
	if (ret) {
		dev_err(dev, "register inet addr notifier failed!\n");
		goto error_failed_register_inetaddr_notifier;
	}

  	return 0;
  
  error_failed_register_inetaddr_notifier:
	unregister_netdevice_notifier(&iboe->nb);

  error_failed_setup_mtu_gids:
  	ib_unregister_device(ib_dev);



     Regards
Wei Hu
>
>> +		goto error_failed_register_device;
>> +	}
>> +
>> +	return 0;
>> +
>> +error_failed_register_device:
>> +	hns_roce_engine_exit(hr_dev);
>> +
>>   error_failed_engine_init:
>>   	hns_roce_cleanup_bitmap(hr_dev);
>>   
>> -- 
>> 1.9.1
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
