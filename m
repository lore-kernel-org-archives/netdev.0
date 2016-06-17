From: "Wei Hu (Xavier)" <xavier.huwei@huawei.com>
Subject: Re: [PATCH v9 03/22] IB/hns: Add initial main frame driver and get
 cfg info
Date: Fri, 17 Jun 2016 09:29:45 +0800
Message-ID: <57635289.4090901@huawei.com>
References: <1464795484-77395-1-git-send-email-oulijun@huawei.com>
 <1464795484-77395-4-git-send-email-oulijun@huawei.com>
 <20160609063959.GO3663@leon.nu>
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
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160609063959.GO3663@leon.nu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 2016/6/9 14:39, Leon Romanovsky wrote:
> On Wed, Jun 01, 2016 at 11:37:45PM +0800, Lijun Ou wrote:
>> This patch mainly added the initial bare main driver. It
>> could get the relative configure information of net node.
>>
>> Signed-off-by: Wei Hu <xavier.huwei@huawei.com>
>> Signed-off-by: Nenglong Zhao <zhaonenglong@hisilicon.com>
>> Signed-off-by: Lijun Ou <oulijun@huawei.com>
>> ---
>>   drivers/infiniband/hw/hns/hns_roce_device.h |  72 ++++++++++
>>   drivers/infiniband/hw/hns/hns_roce_main.c   | 197 ++++++++++++++++++++++++++++
>>   2 files changed, 269 insertions(+)
>>   create mode 100644 drivers/infiniband/hw/hns/hns_roce_device.h
>>   create mode 100644 drivers/infiniband/hw/hns/hns_roce_main.c
>>
>> diff --git a/drivers/infiniband/hw/hns/hns_roce_device.h b/drivers/infiniband/hw/hns/hns_roce_device.h
>> new file mode 100644
>> index 0000000..f9de8e4
>> --- /dev/null
>> +++ b/drivers/infiniband/hw/hns/hns_roce_device.h
>> @@ -0,0 +1,72 @@
>> +/*
>> + * Copyright (c) 2016 Hisilicon Limited.
>> + *
>> + * This software is available to you under a choice of one of two
>> + * licenses.  You may choose to be licensed under the terms of the GNU
>> + * General Public License (GPL) Version 2, available from the file
>> + * COPYING in the main directory of this source tree, or the
>> + * OpenIB.org BSD license below:
>> + *
>> + *     Redistribution and use in source and binary forms, with or
>> + *     without modification, are permitted provided that the following
>> + *     conditions are met:
>> + *
>> + *      - Redistributions of source code must retain the above
>> + *        copyright notice, this list of conditions and the following
>> + *        disclaimer.
>> + *
>> + *      - Redistributions in binary form must reproduce the above
>> + *        copyright notice, this list of conditions and the following
>> + *        disclaimer in the documentation and/or other materials
>> + *        provided with the distribution.
>> + *
>> + * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
>> + * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
>> + * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
>> + * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
>> + * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
>> + * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
>> + * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
>> + * SOFTWARE.
>> + */
>> +
>> +#ifndef _HNS_ROCE_DEVICE_H
>> +#define _HNS_ROCE_DEVICE_H
>> +
>> +#include <linux/platform_device.h>
>> +#include <linux/radix-tree.h>
>> +#include <linux/semaphore.h>
>> +#include <rdma/ib_addr.h>
>> +#include <rdma/ib_smi.h>
>> +#include <rdma/ib_umem.h>
>> +#include <rdma/ib_user_verbs.h>
>> +#include <rdma/ib_verbs.h>
>> +
>> +#define DRV_NAME "hns_roce"
>> +
>> +#define HNS_ROCE_MAX_IRQ_NUM			34
>> +#define HNS_ROCE_MAX_PORTS			6
>> +
>> +struct hns_roce_ib_iboe {
>> +	struct net_device      *netdevs[HNS_ROCE_MAX_PORTS];
>> +	u8			phy_port[HNS_ROCE_MAX_PORTS];
>> +};
>> +
>> +struct hns_roce_caps {
>> +	u8			num_ports;
>> +};
>> +
>> +struct hns_roce_dev {
>> +	struct ib_device	ib_dev;
>> +	struct platform_device  *pdev;
>> +	struct hns_roce_ib_iboe iboe;
>> +
>> +	int			irq[HNS_ROCE_MAX_IRQ_NUM];
>> +	u8 __iomem		*reg_base;
>> +	struct hns_roce_caps	caps;
>> +
>> +	int			cmd_mod;
>> +	int			loop_idc;
>> +};
>> +
>> +#endif /* _HNS_ROCE_DEVICE_H */
>> diff --git a/drivers/infiniband/hw/hns/hns_roce_main.c b/drivers/infiniband/hw/hns/hns_roce_main.c
>> new file mode 100644
>> index 0000000..21c5e8e
>> --- /dev/null
>> +++ b/drivers/infiniband/hw/hns/hns_roce_main.c
>> @@ -0,0 +1,197 @@
>> +/*
>> + * Copyright (c) 2016 Hisilicon Limited.
>> + * Copyright (c) 2007, 2008 Mellanox Technologies. All rights reserved.
>> + *
>> + * This software is available to you under a choice of one of two
>> + * licenses.  You may choose to be licensed under the terms of the GNU
>> + * General Public License (GPL) Version 2, available from the file
>> + * COPYING in the main directory of this source tree, or the
>> + * OpenIB.org BSD license below:
>> + *
>> + *     Redistribution and use in source and binary forms, with or
>> + *     without modification, are permitted provided that the following
>> + *     conditions are met:
>> + *
>> + *      - Redistributions of source code must retain the above
>> + *        copyright notice, this list of conditions and the following
>> + *        disclaimer.
>> + *
>> + *      - Redistributions in binary form must reproduce the above
>> + *        copyright notice, this list of conditions and the following
>> + *        disclaimer in the documentation and/or other materials
>> + *        provided with the distribution.
>> + *
>> + * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
>> + * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
>> + * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
>> + * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
>> + * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
>> + * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
>> + * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
>> + * SOFTWARE.
>> + */
>> +
>> +#include <linux/cdev.h>
>> +#include <linux/delay.h>
>> +#include <linux/device.h>
>> +#include <linux/dma-mapping.h>
>> +#include <linux/ethtool.h>
>> +#include <linux/etherdevice.h>
>> +#include <linux/fs.h>
>> +#include <linux/init.h>
>> +#include <linux/interrupt.h>
>> +#include <linux/kernel.h>
>> +#include <linux/list.h>
>> +#include <linux/module.h>
>> +#include <linux/netdevice.h>
>> +#include <linux/of.h>
>> +#include <linux/of_address.h>
>> +#include <linux/of_net.h>
>> +#include <linux/of_platform.h>
>> +#include <linux/platform_device.h>
>> +#include <linux/slab.h>
>> +#include <linux/netdevice.h>
> You added this include (netdevice.h) 7 lines above.
Hi, leon
     We have fixed it.
     And Oulijun have sent PATCH V10. Thanks

Regards
Wei Hu
