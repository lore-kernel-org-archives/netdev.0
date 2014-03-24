From: Rob Herring <robherring2@gmail.com>
Subject: Re: [PATCH 3/3] net: hisilicon: new hip04 ethernet driver
Date: Mon, 24 Mar 2014 09:17:31 -0500
Message-ID: <CAL_JsqLfH7Er-s5wjA5JGE4+-SGtTOvYTyQ=cYk+1ekHo39Crg@mail.gmail.com>
References: <1395132017-15928-1-git-send-email-zhangfei.gao@linaro.org>
	<1395132017-15928-4-git-send-email-zhangfei.gao@linaro.org>
	<20140318104616.GT21483@n2100.arm.linux.org.uk>
	<CAMj5BkiCXVZZPS-VyVxejCY0aiGD_HQjUdWd-FKD_ER_y_0wxQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Russell King - ARM Linux <linux@arm.linux.org.uk>,
	Zhangfei Gao <zhangfei.gao@linaro.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	linux-arm-kernel <linux-arm-kernel@lists.infradead.org>,
	netdev <netdev@vger.kernel.org>
To: Zhangfei Gao <zhangfei.gao@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f177.google.com ([209.85.220.177]:52635 "EHLO
	mail-vc0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752754AbaCXORc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Mar 2014 10:17:32 -0400
In-Reply-To: <CAMj5BkiCXVZZPS-VyVxejCY0aiGD_HQjUdWd-FKD_ER_y_0wxQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 20, 2014 at 4:51 AM, Zhangfei Gao <zhangfei.gao@gmail.com> wrote:
> Dear Russell
>
> Thanks for sparing time and giving so many perfect suggestion, really helpful.
>
> On Tue, Mar 18, 2014 at 6:46 PM, Russell King - ARM Linux
> <linux@arm.linux.org.uk> wrote:
>> I was just browsing this patch when I noticed some of these issues - I
>> haven't done a full review of this driver, I'm just commenting on the
>> things I've spotted.

[snip]

>>> +             dma_map_single(&ndev->dev, skb->data,
>>> +                     RX_BUF_SIZE, DMA_FROM_DEVICE);
>>
>> This is incorrect.
>>
>> buf = buffer alloc()
>> /* CPU owns buffer and can read/write it, device does not */
>> dev_addr = dma_map_single(dev, buf, ..., DMA_FROM_DEVICE);
>> /* Device owns buffer and can write it, CPU does not access it */
>> dma_unmap_single(dev, dev_addr, ..., DMA_FROM_DEVICE);
>> /* CPU owns buffer again and can read/write it, device does not */
>>
>> Please turn on DMA API debugging in the kernel debug options and verify
>> whether your driver causes it to complain (it will.)
>
> Yes, you are right.
> After change to dma_map/unmap_single, however, still get warning like
> "DMA-API: device driver failed to check map error", not sure whether
> it can be ignored?

If it could be ignored, there would be no warning. So yes you should
check the error. I guess correct error handling would be throwing away
the packet.


>>> +             dma_map_single(&ndev->dev, buf, RX_BUF_SIZE, DMA_TO_DEVICE);
>>> +             hip04_set_recv_desc(priv, virt_to_phys(buf));
>>
>> No need for virt_to_phys() here - dma_map_single() returns the device
>> address.
> Got it.
> Use virt_to_phys since find same result come out, it should be
> different for iommu case.
>
> In fact, the hardware can help to do the cache flushing, the function
> still not be enabled now.
> Then dma_map/unmap_single may be ignored.

If you don't need cache flushing, you should setup different
dma_map_ops for the device such as arm_coherent_dma_ops. The driver
should always have the dma_map calls. See highbank and mvebu for
examples.

Rob
