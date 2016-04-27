From: oulijun <oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v5 09/21] IB/hns: Add hca support
Date: Wed, 27 Apr 2016 11:37:01 +0800
Message-ID: <572033DD.9050501@huawei.com>
References: <1461407219-72027-1-git-send-email-oulijun@huawei.com>
 <1461407219-72027-10-git-send-email-oulijun@huawei.com>
 <20160424075424.GE7974@leon.nu> <571F0C04.2010005@huawei.com>
 <20160426141821.GJ7974@leon.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	<hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	<jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, <jiri-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	<ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, <linuxarm-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <gongyangming-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<xiaokun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <tangchaofei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<haifeng.wei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <yisen.zhuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<yankejian-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <lisheng011-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<charles.chenxin-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
To: <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160426141821.GJ7974-2ukJVAZIZ/Y@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 2016/4/26 22:18, Leon Romanovsky wrote:
> On Tue, Apr 26, 2016 at 02:34:44PM +0800, oulijun wrote:
>> On 2016/4/24 15:54, Leon Romanovsky wrote:
>>> On Sat, Apr 23, 2016 at 06:26:47PM +0800, Lijun Ou wrote:
>>>> This patch mainly setup hca for RoCE. it will do a series of
>>>> initial works as follows:
>>>>       1. init uar table, allocate uar resource
>>>>       2. init pd table
>>>>       3. init cq table
>>>>       4. init mr table
>>>>       5. init qp table
>>>>
>>>> Signed-off-by: Lijun Ou <oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
>>>> Signed-off-by: Wei Hu(Xavier) <xavier.huwei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
>>>> ---
>>>>  drivers/infiniband/hw/hns/hns_roce_alloc.c  | 104 ++++++++++++++++
>>>>  drivers/infiniband/hw/hns/hns_roce_cq.c     |  25 ++++
>>>>  drivers/infiniband/hw/hns/hns_roce_device.h |  69 ++++++++++
>>>>  drivers/infiniband/hw/hns/hns_roce_eq.c     |   1 -
>>>>  drivers/infiniband/hw/hns/hns_roce_icm.c    |  88 +++++++++++++
>>>>  drivers/infiniband/hw/hns/hns_roce_icm.h    |   9 ++
>>>>  drivers/infiniband/hw/hns/hns_roce_main.c   |  79 ++++++++++++
>>>>  drivers/infiniband/hw/hns/hns_roce_mr.c     | 187 ++++++++++++++++++++++++++++
>>>>  drivers/infiniband/hw/hns/hns_roce_pd.c     |  65 ++++++++++
>>>>  drivers/infiniband/hw/hns/hns_roce_qp.c     |  30 +++++
>>>>  10 files changed, 656 insertions(+), 1 deletion(-)
>>>>  create mode 100644 drivers/infiniband/hw/hns/hns_roce_alloc.c
>>>>  create mode 100644 drivers/infiniband/hw/hns/hns_roce_mr.c
>>>>  create mode 100644 drivers/infiniband/hw/hns/hns_roce_pd.c
>>>>
>>>> diff --git a/drivers/infiniband/hw/hns/hns_roce_alloc.c b/drivers/infiniband/hw/hns/hns_roce_alloc.c
>>>> new file mode 100644
>>>> index 0000000..0c76f1b
>>>> --- /dev/null
>>>> +++ b/drivers/infiniband/hw/hns/hns_roce_alloc.c
>>>> @@ -0,0 +1,104 @@
>>>> +/*
>>>> + * Copyright (c) 2016 Hisilicon Limited.
>>>> + *
>>>> + * This program is free software; you can redistribute it and/or modify
>>>> + * it under the terms of the GNU General Public License as published by
>>>> + * the Free Software Foundation; either version 2 of the License, or
>>>> + * (at your option) any later version.
>>>> + */
>>>> +
>>>> +#include <linux/bitmap.h>
>>>> +#include <linux/dma-mapping.h>
>>>> +#include <linux/errno.h>
>>>> +#include <linux/mm.h>
>>>> +#include <linux/slab.h>
>>>> +#include <linux/vmalloc.h>
>>>> +#include "hns_roce_device.h"
>>>> +
>>>> +int hns_roce_bitmap_alloc(struct hns_roce_bitmap *bitmap, u32 *obj)
>>>> +{
>>>> +	int ret = 0;
>>>> +
>>>> +	spin_lock(&bitmap->lock);
>>>> +	*obj = find_next_zero_bit(bitmap->table, bitmap->max, bitmap->last);
>>>> +	if (*obj >= bitmap->max) {
>>>> +		bitmap->top = (bitmap->top + bitmap->max + bitmap->reserved_top)
>>>> +			       & bitmap->mask;
>>>> +		*obj = find_first_zero_bit(bitmap->table, bitmap->max);
>>>
>>> find_first_zero_bit function returns "unsigned long" which may or may
>>> not be equal to u32 on some architectures.
>>>
>> Hi Leon,
>>     I appreciate your keen eye. this code is meant for ARM64bit therefore should run corretly for 64-bit AARCH64.
>> I will consider changing it as part of good partice and better portability "
>> I will give a primary plan to modified it.
>> for example:
>>     *obj = (u32)find_next_zero_bit(bitmap->table, bitmap->max, bitmap->last);
>> Beause the max size of bitmap->table is u32 in current version.
>>
>> int hns_roce_bitmap_init(struct hns_roce_bitmap *bitmap, u32 num, u32 mask,
>> 			 u32 reserved_bot, u32 reserved_top)
>> {
>> 	u32 i;
>>
>> 	if (num != roundup_pow_of_two(num))
>> 		return -EINVAL;
>>
>> 	bitmap->last = 0;
>> 	bitmap->top = 0;
>> 	bitmap->max = num - reserved_top;
>> 	bitmap->mask = mask;
>> 	bitmap->reserved_top = reserved_top;
>> 	spin_lock_init(&bitmap->lock);
>> 	bitmap->table = kcalloc(BITS_TO_LONGS(bitmap->max), sizeof(long),
>> 				GFP_KERNEL);
>>
>> Is this plan ok?
> 
> No,
> You are submitting new driver, please do it properly (without casting)
> from the beginning.
> 
oh, i see. I will give a better plan to modify it.

Thanks
Lijun Ou
>>
>> Thanks
>> Lijun Ou
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
>> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html


--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
