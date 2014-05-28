From: zhangfei <zhangfei.gao@linaro.org>
Subject: Re: [PATCH 3/3] net: hisilicon: add hix5hd2 mac driver
Date: Wed, 28 May 2014 13:17:33 +0800
Message-ID: <5385716D.9010308@linaro.org>
References: <1400504227-12047-1-git-send-email-zhangfei.gao@linaro.org> <201405261651.15998.arnd@arndb.de> <53840D40.3000600@linaro.org> <201405271525.46356.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, f.fainelli@gmail.com,
	sergei.shtylyov@cogentembedded.com, mark.rutland@arm.com,
	David.Laight@aculab.com, eric.dumazet@gmail.com,
	haifeng.yan@linaro.org, jchxue@gmail.com,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	devicetree@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f52.google.com ([209.85.160.52]:34126 "EHLO
	mail-pb0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751280AbaE1FRr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 May 2014 01:17:47 -0400
Received: by mail-pb0-f52.google.com with SMTP id rr13so10567419pbb.11
        for <netdev@vger.kernel.org>; Tue, 27 May 2014 22:17:46 -0700 (PDT)
In-Reply-To: <201405271525.46356.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 05/27/2014 09:25 PM, Arnd Bergmann wrote:
> On Tuesday 27 May 2014, zhangfei wrote:
>> On 05/26/2014 10:51 PM, Arnd Bergmann wrote:
>>> On Monday 19 May 2014, Zhangfei Gao wrote:
>>>
>>> I only noticed one real issue with the driver:
>>>
>>>> +struct hix5hd2_desc {
>>>> +    __le32 buff_addr;
>>>> +    __le32 buff_len:11;
>>>> +    __le32 reserve2:5;
>>>> +    __le32 data_len:11;
>>>> +    __le32 reserve1:2;
>>>> +    __le32 fl:2;
>>>> +    __le32 descvid:1;
>>>> +} __aligned(32);
>>>> +
>>>
>>> You should generall not use bitfields in hardware data structures, as that is
>>> not endian safe and will prevent running a big-endian kernel on this machine.
>>> Better convert this to a set of __le32 fields and explicit shifts and masks.
>>
>> Got it, will update.
>>
>> More knowledge about big-endian kernel is appreciated, in which case we
>> should consider such kernel.
>> Can we only consider this driver is only running on arm, which is
>> little-endian.
>
> The main user of big-endian kernels that I know of are network infrastructure
> people that have a ton of legacy user-space code written in non-portable
> big-endian style.
>
> There is no real technical advantage in running one endianess or the other
> on ARM, so generally everyone uses little-endian because that is what their
> user space is, except for the few people that have ported over their
> code from PowerPC or MIPSeb.
>
>>> Two smaller things you should think about, I'm not entirely sure about these:
>>>
>>>> +static int hix5hd2_rx(struct net_device *dev, int limit)
>>>> +{
>>>> +    struct hix5hd2_priv *priv = netdev_priv(dev);
>>>> +    struct sk_buff *skb;
>>>> +    struct hix5hd2_desc *desc;
>>>> +    dma_addr_t dma_addr;
>>>> +    u32 start, end, num, pos, i, len;
>>>> +
>>>> +    /* software read pointer */
>>>> +    start = dma_cnt(readl_relaxed(priv->base + RX_BQ_RD_ADDR));
>>>> +    /* logic write pointer */
>>>> +    end = dma_cnt(readl_relaxed(priv->base + RX_BQ_WR_ADDR));
>>>
>>> I think one of these needs to be readl() instead of readl_relaxed(),
>>> to ensure the data is correctly ordered with regard to the pointer
>>> access.
>> readl_relaxed can ensure the sequence.
>>
>>>
>>>> +    if (pos != start)
>>>> +            writel(dma_byte(pos), priv->base + TX_RQ_RD_ADDR);
>>>
>>> While this looks like it could be writel_relaxed().
>>>
>> En, I think all three cases can use xxx_relaxed.
>> These accesses are just update pointer used by internal logic and get
>> pointer updated by internal logic.
>
> You always need a barrier between the access to a buffer from the kernel
> and the register access communicating with the hardware about that
> buffer:
>
> For tx:
>
> 	a) write to DMA descriptor
> 	b) wmb()
> 	c) writel_relaxed(register)
>
> writel() is the short form of b+c. If you omit the __iowmb(), the decriptor
> access may still be inside of the CPU write buffer (or the cache on coherent
> systems) by the time the hardware reads the descriptor.
>
> for rx:
>
> 	a) readl_relaxed(register)
> 	b) rmb()
> 	c) read from descriptor or skb data
>
> If you leave out the __iormb() here, it's possible that the CPU can prefetch
> the access to the descriptor while waiting for the register data, and read
> stale data.
>
> If your particular machine doesn't need rmb() or wmb() (e.g. for
> non-SMP ARMv6 or older), the build process should replace them with
> do{}while(0) them automatically.

Thanks Arnd,
Yes, understand, barrier still required.

What I thought was the dma in this controller keeps running and not need 
desc to trigger, only update pointer, so no need barrier.
Even so, desc still need to be sync via barrier, otherwise, desc with 
stale info may be used.

Will add barrier accordingly.

Thanks
