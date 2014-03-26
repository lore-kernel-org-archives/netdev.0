From: Zhangfei Gao <zhangfei.gao@gmail.com>
Subject: Re: [PATCH 3/3] net: hisilicon: new hip04 ethernet driver
Date: Wed, 26 Mar 2014 22:22:35 +0800
Message-ID: <CAMj5Bkg1_a=tAw1sxOTzSG6eWUHT8QVPXOzx2C+oCyf+dPr7Uw@mail.gmail.com>
References: <1395132017-15928-1-git-send-email-zhangfei.gao@linaro.org>
	<1395132017-15928-4-git-send-email-zhangfei.gao@linaro.org>
	<20140318104616.GT21483@n2100.arm.linux.org.uk>
	<CAMj5BkiCXVZZPS-VyVxejCY0aiGD_HQjUdWd-FKD_ER_y_0wxQ@mail.gmail.com>
	<CAL_JsqLfH7Er-s5wjA5JGE4+-SGtTOvYTyQ=cYk+1ekHo39Crg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Russell King - ARM Linux <linux@arm.linux.org.uk>,
	Zhangfei Gao <zhangfei.gao@linaro.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	linux-arm-kernel <linux-arm-kernel@lists.infradead.org>,
	netdev <netdev@vger.kernel.org>
To: Rob Herring <robherring2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f41.google.com ([74.125.83.41]:43907 "EHLO
	mail-ee0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754488AbaCZOWg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2014 10:22:36 -0400
In-Reply-To: <CAL_JsqLfH7Er-s5wjA5JGE4+-SGtTOvYTyQ=cYk+1ekHo39Crg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear Rob

On Mon, Mar 24, 2014 at 10:17 PM, Rob Herring <robherring2@gmail.com> wrote:

>
>>>> +             dma_map_single(&ndev->dev, skb->data,
>>>> +                     RX_BUF_SIZE, DMA_FROM_DEVICE);
>>>
>>> This is incorrect.
>>>
>>> buf = buffer alloc()
>>> /* CPU owns buffer and can read/write it, device does not */
>>> dev_addr = dma_map_single(dev, buf, ..., DMA_FROM_DEVICE);
>>> /* Device owns buffer and can write it, CPU does not access it */
>>> dma_unmap_single(dev, dev_addr, ..., DMA_FROM_DEVICE);
>>> /* CPU owns buffer again and can read/write it, device does not */
>>>
>>> Please turn on DMA API debugging in the kernel debug options and verify
>>> whether your driver causes it to complain (it will.)
>>
>> Yes, you are right.
>> After change to dma_map/unmap_single, however, still get warning like
>> "DMA-API: device driver failed to check map error", not sure whether
>> it can be ignored?
>
> If it could be ignored, there would be no warning. So yes you should
> check the error. I guess correct error handling would be throwing away
> the packet.

The warning is solved via adding dma_mapping_error check after every
dma_map_single.

>
>
>>>> +             dma_map_single(&ndev->dev, buf, RX_BUF_SIZE, DMA_TO_DEVICE);
>>>> +             hip04_set_recv_desc(priv, virt_to_phys(buf));
>>>
>>> No need for virt_to_phys() here - dma_map_single() returns the device
>>> address.
>> Got it.
>> Use virt_to_phys since find same result come out, it should be
>> different for iommu case.
>>
>> In fact, the hardware can help to do the cache flushing, the function
>> still not be enabled now.
>> Then dma_map/unmap_single may be ignored.
>
> If you don't need cache flushing, you should setup different
> dma_map_ops for the device such as arm_coherent_dma_ops. The driver
> should always have the dma_map calls. See highbank and mvebu for
> examples.

That would be very helpful, still not sure how to enable this feature.
Could you help clarify which file.
Not find highbank and mvebu under drivers/iommu/.

Thanks
