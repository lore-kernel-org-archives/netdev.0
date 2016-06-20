From: "Wei Hu (Xavier)" <xavier.huwei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v10 08/22] IB/hns: Add icm support
Date: Mon, 20 Jun 2016 15:49:24 +0800
Message-ID: <5767A004.4060808@huawei.com>
References: <1466087730-54856-1-git-send-email-oulijun@huawei.com>
 <1466087730-54856-9-git-send-email-oulijun@huawei.com>
 <20160617095834.GA5408@leon.nu> <57677314.70909@huawei.com>
 <20160620060614.GC1172@leon.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Lijun Ou <oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	<sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, <hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	<davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	<jiri-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	<linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <gongyangming-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<xiaokun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <tangchaofei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<haifeng.wei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <yisen.zhuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<yankejian-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <charles.chenxin-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<linuxarm-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
To: <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160620060614.GC1172-2ukJVAZIZ/Y@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org



On 2016/6/20 14:06, Leon Romanovsky wrote:
> On Mon, Jun 20, 2016 at 12:37:40PM +0800, Wei Hu (Xavier) wrote:
>>
>> On 2016/6/17 17:58, Leon Romanovsky wrote:
>>> On Thu, Jun 16, 2016 at 10:35:16PM +0800, Lijun Ou wrote:
>>>> This patch mainly added icm support for RoCE. It initializes icm
>>>> which managers the relative memory blocks for RoCE. The data
>>>> structures of RoCE will be located in it. For example, CQ table,
>>>> QP table and MTPT table so on.
>>>>
>>>> Signed-off-by: Wei Hu <xavier.huwei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
>>>> Signed-off-by: Nenglong Zhao <zhaonenglong-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>
>>>> Signed-off-by: Lijun Ou <oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
>>>> ---
>>> <...>
>>>
>>>> +
>>>> +static int hns_roce_alloc_icm_pages(struct scatterlist *mem, int =
order,
>>>> +				    gfp_t gfp_mask)
>>>> +{
>>>> +	struct page *page;
>>>> +
>>>> +	page =3D alloc_pages(gfp_mask, order);
>>>> +	if (!page)
>>>> +		return -ENOMEM;
>>>> +
>>>> +	sg_set_page(mem, page, PAGE_SIZE << order, 0);
>>>> +
>>>> +	return 0;
>>>> +}
>>>> +
>>>> +static int hns_roce_alloc_icm_coherent(struct device *dev,
>>>> +				       struct scatterlist *mem, int order,
>>>> +				       gfp_t gfp_mask)
>>>> +{
>>>> +	void *buf =3D dma_alloc_coherent(dev, PAGE_SIZE << order,
>>>> +				       &sg_dma_address(mem), gfp_mask);
>>>> +	if (!buf)
>>>> +		return -ENOMEM;
>>>> +
>>>> +	sg_set_buf(mem, buf, PAGE_SIZE << order);
>>>> +	WARN_ON(mem->offset);
>>>> +	sg_dma_len(mem) =3D PAGE_SIZE << order;
>>>> +	return 0;
>>>> +}
>>>> +
>>> <...>
>>>
>>>> +
>>>> +static void hns_roce_free_icm_pages(struct hns_roce_dev *hr_dev,
>>>> +				    struct hns_roce_icm_chunk *chunk)
>>>> +{
>>>> +	int i;
>>>> +
>>>> +	if (chunk->nsg > 0)
>>>> +		dma_unmap_sg(&hr_dev->pdev->dev, chunk->mem, chunk->npages,
>>>> +			     DMA_BIDIRECTIONAL);
>>>> +
>>>> +	for (i =3D 0; i < chunk->npages; ++i)
>>>> +		__free_pages(sg_page(&chunk->mem[i]),
>>>> +			     get_order(chunk->mem[i].length));
>>> You used alloc_pages for this allocation, so why are you using
>>> __free_pages instead of free_pages?
>> Hi, Leon
>>      The function prototype of these functions as below=EF=BC=9A
>>          static inline struct page * alloc_pages(gfp_t gfp_mask, uns=
igned int
>> order);
>>          void free_pages(unsigned long addr, unsigned int order);
>>          void __free_pages(struct page *page, unsigned int order);
>>
>>      The type of the first parameter of free_pages is same with the =
type of
>> return value of alloc_pages.
>>      Maybe it is better to call __free_pages to release memory that =
allocated
>> by calling alloc_pages.
> OK, I see.
>
> Another question which you didn't answer [1].
>
> "I wonder if you have the same needs for ICM as it is in mlx4 device.
> Do you have firmware?"
>
> [1] http://marc.info/?l=3Dlinux-rdma&m=3D146545553104913&w=3D2
Hi, Leon
     Now we haven't firmware.
     But hardware still need memory for QPC\CQC\MTPT\mtt etc.

Thanks
Wei Hu
>> Regards
>> Wei Hu
>>


--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
