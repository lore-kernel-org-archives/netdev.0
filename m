From: "Wei Hu (Xavier)" <xavier.huwei@huawei.com>
Subject: Re: [PATCH v10 08/22] IB/hns: Add icm support
Date: Wed, 22 Jun 2016 11:53:17 +0800
Message-ID: <576A0BAD.1070803@huawei.com>
References: <1466087730-54856-1-git-send-email-oulijun@huawei.com>
 <1466087730-54856-9-git-send-email-oulijun@huawei.com>
 <20160617095834.GA5408@leon.nu> <57677314.70909@huawei.com>
 <20160620060614.GC1172@leon.nu> <5767A004.4060808@huawei.com>
 <20160620092719.GE1172@leon.nu> <5767BBDF.6010309@huawei.com>
 <20160620130422.GA4526@leon.nu> <5768C493.6000300@huawei.com>
 <20160621115554.GB9762@leon.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Lijun Ou <oulijun@huawei.com>, <dledford@redhat.com>,
	<sean.hefty@intel.com>, <hal.rosenstock@gmail.com>,
	<davem@davemloft.net>, <jeffrey.t.kirsher@intel.com>,
	<jiri@mellanox.com>, <ogerlitz@mellanox.com>,
	<linux-rdma@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>, <gongyangming@huawei.com>,
	<xiaokun@huawei.com>, <tangchaofei@huawei.com>,
	<haifeng.wei@huawei.com>, <yisen.zhuang@huawei.com>,
	<yankejian@huawei.com>, <charles.chenxin@huawei.com>,
	<linuxarm@huawei.com>
To: <leon@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:33132 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751572AbcFVDyI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jun 2016 23:54:08 -0400
In-Reply-To: <20160621115554.GB9762@leon.nu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2016/6/21 19:55, Leon Romanovsky wrote:
> On Tue, Jun 21, 2016 at 12:37:39PM +0800, Wei Hu (Xavier) wrote:
>>
>> On 2016/6/20 21:04, Leon Romanovsky wrote:
>>> On Mon, Jun 20, 2016 at 05:48:15PM +0800, Wei Hu (Xavier) wrote:
>>>> On 2016/6/20 17:27, Leon Romanovsky wrote:
>>>>> On Mon, Jun 20, 2016 at 03:49:24PM +0800, Wei Hu (Xavier) wrote:
>>>>>> On 2016/6/20 14:06, Leon Romanovsky wrote:
>>>>>>> On Mon, Jun 20, 2016 at 12:37:40PM +0800, Wei Hu (Xavier) wrote=
:
>>>>>>>> On 2016/6/17 17:58, Leon Romanovsky wrote:
>>>>>>>>> On Thu, Jun 16, 2016 at 10:35:16PM +0800, Lijun Ou wrote:
>>>>>>>>>> This patch mainly added icm support for RoCE. It initializes=
 icm
>>>>>>>>>> which managers the relative memory blocks for RoCE. The data
>>>>>>>>>> structures of RoCE will be located in it. For example, CQ ta=
ble,
>>>>>>>>>> QP table and MTPT table so on.
>>>>>>>>>>
>>>>>>>>>> Signed-off-by: Wei Hu <xavier.huwei@huawei.com>
>>>>>>>>>> Signed-off-by: Nenglong Zhao <zhaonenglong@hisilicon.com>
>>>>>>>>>> Signed-off-by: Lijun Ou <oulijun@huawei.com>
>>>>>>>>>> ---
>>>>>>>>> <...>
>>>>>>>>>
>>>>>>>>>> +
>>>>>>> Another question which you didn't answer [1].
>>>>>>>
>>>>>>> "I wonder if you have the same needs for ICM as it is in mlx4 d=
evice.
>>>>>>> Do you have firmware?"
>>>>>>>
>>>>>>> [1] http://marc.info/?l=3Dlinux-rdma&m=3D146545553104913&w=3D2
>>>>>> Hi, Leon
>>>>>>      Now we haven't firmware.
>>>>>>      But hardware still need memory for QPC\CQC\MTPT\mtt etc.
>>>>> ICM stands for InfiniHost (Interconnect) Context Memory is a spec=
ific
>>>>> memory place to share between host <-> FW and host <-> HW if HW i=
s
>>>>> aware of specific structures.
>>>>>
>>>>> I assume that in your case, it is enough to allocate memory regio=
n and
>>>>> supply it to HW. Am I right?
>>>> For Our hardware,
>>>> 1. ICM has a memory management method, It's very good for QPC\CQC\=
MTPT\mtt
>>>> etc. we need it.
>>> You need special HW to leverage its. AFAIK it is Mellanox specific.
>> For our hardware, we use ICM to memory management, the memory shared=
 with
>> host and HW.
>> QPC\CQC\MTPT\mtt has specific memory requirement.
>> QPC\CQC\MTPT need continuous memory. we use ICM to management the bl=
ock of
>> memory. It's very good=EF=BC=81
> I wasn't convinced why do you need to copy whole ICM logic which is
> specific to Mellanox. Your requirements can be implemented by standar=
d CMA
> and/or DMA.
Hi, Leon

In hip06 soc,
Hardware need multiple memory blocks for QPC\CQC\MTPT, every block has=20
continuous memory xxKbyte (like 128Kbyte),
We need to configure the first address of 128Kbyte to hardware.

=46or example:
//---------------------------------------------------------------------=
---
example 1:
In create qp,
1. If the xx Kbyte memory that include QPC related with qpn, has not=20
been allocated, do step 2.
    else do step 3.
2. dma_alloc xx Kbyte memory for QPC,  and configure the first address=20
of xx Kbyte to hardware.
3. find the QPC memory in xx Kbyte, get the dma_addr.
4. send mailbox command to hardware to create QP.

In step 2, we call xx_table_get function as below to perform logic.
int hns_roce_table_get(struct hns_roce_dev *hr_dev,
                struct hns_roce_icm_table *table, unsigned long obj)
{
     <snip>
     //dma_alloc_coherent 128Kbyte memory
     hns_roce_alloc_icm(hr_dev,
                   HNS_ROCE_TABLE_CHUNK_SIZE >> PAGE_SHIFT, xxxx);
     <snip>
     /*configure the first address of xx Kbyte to hardware*/
     hns_roce_map_icm(hr_dev, table, obj);
     <snip>
}

In step 3, we call xx_table_find function to perform logic.
void *hns_roce_table_find(struct hns_roce_icm_table *table, unsigned=20
long obj,
               dma_addr_t *dma_handle);


example 2:
In modify qp:
1. find the QPC memory,  get the virtual addr.
2. modify the fields of QPC.
3. send mailbox command to hardware to modify QP.

In step 1,  we call xx_table_find function to perform logic.
//---------------------------------------------------------------------=
-----


so, now we haven't a firmware, but ICM algorithm still suitable for=20
hip06 soc perfectly.

Regards
Wei Hu
>>>> 2. The meomry for QPC\CQC\MTPT\mtt only used for RoCE hardware and=
 driver,
>>>> we don't want use MR.
>>> I didn't mean Infiniband MR, but memory region returned from standa=
rd
>>> allocation functions (kmalloc, ...).
>>>
>>>> 3. Now we haven't firmware, maybe we need it next version.
>>> You are always invited to add support once it will be needed, no ne=
ed to
>>> add it in advance.
>>>
>>> Thanks
>>
