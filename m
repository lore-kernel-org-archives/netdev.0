From: oulijun <oulijun@huawei.com>
Subject: Re: [PATCH 2/3] net: hns: add Hisilicon RoCE support
Date: Sat, 19 Mar 2016 19:17:49 +0800
Message-ID: <56ED355D.7050604@huawei.com>
References: <1457692631-9290-1-git-send-email-oulijun@huawei.com>
 <1457692631-9290-3-git-send-email-oulijun@huawei.com>
 <20160312104301.GB15703@leon.nu> <56E60FFC.3000007@huawei.com>
 <20160314064921.GA26456@leon.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
To: "Yankejian (Hackim Yim)" <yankejian@huawei.com>,
	<dledford@redhat.com>, <sean.hefty@intel.com>,
	<hal.rosenstock@gmail.com>, <davem@davemloft.net>,
	<jeffrey.t.kirsher@intel.com>, <jiri@mellanox.com>,
	<ogerlitz@mellanox.com>, <linux-rdma@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	<gongyangming@huawei.com>, <xiaokun@huawei.com>,
	<tangchaofei@huawei.com>, <haifeng.wei@huawei.com>,
	<yisen.zhuang@huawei.com>, <lisheng011@huawei.com>,
	<charles.chenxin@huawei.com>, <linuxarm@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:24678 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754270AbcCSLSS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Mar 2016 07:18:18 -0400
In-Reply-To: <20160314064921.GA26456@leon.nu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2016/3/14 14:49, Leon Romanovsky wrote:
> On Mon, Mar 14, 2016 at 09:12:28AM +0800, Yankejian (Hackim Yim) wrote:
>>
>>
>> On 2016/3/12 18:43, Leon Romanovsky wrote:
>>> On Fri, Mar 11, 2016 at 06:37:10PM +0800, Lijun Ou wrote:
>>>> It added hns_dsaf_roce_reset routine for roce driver.
>>>> RoCE is a feature of hns.
>>>> In hip06 SOC, in roce reset process, it's needed to configure
>>>> dsaf channel reset,port and sl map info.
>>>>
>>>> Signed-off-by: Lijun Ou <oulijun@huawei.com>
>>>> Signed-off-by: Wei Hu(Xavier) <xavier.huwei@huawei.com>
>>>> Signed-off-by: Lisheng <lisheng011@huawei.com>
>>>> ---
>>>>  drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c | 84 ++++++++++++++++++++++
>>>>  drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h | 14 ++++
>>>>  drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c | 62 +++++++++++++---
>>>>  drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h  | 13 ++++
>>>>  4 files changed, 163 insertions(+), 10 deletions(-)
>>>>
>>>> diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
>>>> index 38fc5be..a0f0d4f 100644
>>>> --- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
>>>> +++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
>>>> @@ -12,6 +12,7 @@
>>>>  #include <linux/init.h>
>>>>  #include <linux/interrupt.h>
>>>>  #include <linux/netdevice.h>
>>>> +#include <linux/of_platform.h>
>>>>  #include <linux/platform_device.h>
>>>>  #include <linux/of.h>
>>>>  #include <linux/of_address.h>
>>>> @@ -2593,6 +2594,89 @@ static struct platform_driver g_dsaf_driver = {
>>>>  
>>>>  module_platform_driver(g_dsaf_driver);
>>>>  
>>>> +/**
>>>> + * hns_dsaf_roce_reset - reset dsaf and roce
>>>> + * @dsaf_fwnode: Pointer to framework node for the dasf
>>>> + * @val: 0 - request reset , 1 - drop reset
>>>> + * retuen 0 - success , negative --fail
>>>> + */
>>>> +int hns_dsaf_roce_reset(struct fwnode_handle *dsaf_fwnode, u32 val)
>>>> +{
>>>> +	struct dsaf_device *dsaf_dev;
>>>> +	struct platform_device *pdev;
>>>> +	unsigned int mp;
>>>> +	unsigned int sl;
>>>> +	unsigned int credit;
>>>> +	int i;
>>>> +	const u32 port_map[DSAF_ROCE_CREDIT_CHN][DSAF_ROCE_CHAN_MODE] = {
>>>> +		{0, 0, 0},
>>>> +		{1, 0, 0},
>>>> +		{2, 1, 0},
>>>> +		{3, 1, 0},
>>>> +		{4, 2, 1},
>>>> +		{4, 2, 1},
>>>> +		{5, 3, 1},
>>>> +		{5, 3, 1},
>>>> +	};
>>>> +	const u32 sl_map[DSAF_ROCE_CREDIT_CHN][DSAF_ROCE_CHAN_MODE] = {
>>>> +		{0, 0, 0},
>>>> +		{0, 1, 1},
>>>> +		{0, 0, 2},
>>>> +		{0, 1, 3},
>>>> +		{0, 0, 0},
>>>> +		{1, 1, 1},
>>>> +		{0, 0, 2},
>>>> +		{1, 1, 3},
>>>> +	};
>>> Do you have a plan to send a version with enums/defines for this
>>> numbers? Especially for _CHAN_MODE.
>>>
>>> .
>>
>> Hi leon,
>>
>>     it seems the enums is added in hns_dsaf_main.h, as belows:
>>
>> diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h
>> index 5fea226..c917b9a 100644
>> --- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h
>> +++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h
>> @@ -40,6 +40,16 @@ struct hns_mac_cb;
>>  #define DSAF_DUMP_REGS_NUM 504
>>  #define DSAF_STATIC_NUM 28
>>  
>> +#define DSAF_ROCE_CREDIT_CHN 8
>> +#define DSAF_ROCE_CHAN_MODE 3
>> +
>> +enum dsaf_roce_port_port_mode {
>> +	DSAF_ROCE_6PORT_MODE,
>> +	DSAF_ROCE_4PORT_MODE,
>> +	DSAF_ROCE_2PORT_MODE,
>> +	DSAF_ROCE_CHAN_MODE_NUM
>> +};
>> +
> 
> These defines are used as an index entry into si_map and port_map arrays
> and seems as not related to the actual data.
> 
> I suggest you to take this code back to drawing table, redesign it,
> clean unused functions and defines and resubmit it.
> 
> Thanks.
>

Hi Leon Romanovsky

   I have redesigned the port_map and sl_map structures. Please refer to the
hns_dsaf_main.c and hns_dsaf_main.h.

thanks
Lijun Ou

>>
>> MBR, Kejian
>>
>>
>>
>>
>>
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> .
> 
