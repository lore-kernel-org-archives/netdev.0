From: zhangfei <zhangfei.gao@linaro.org>
Subject: Re: [PATCH 3/3] net: hisilicon: new hip04 ethernet driver
Date: Tue, 08 Apr 2014 16:07:33 +0800
Message-ID: <5343AE45.4020308@linaro.org>
References: <1396672506-9296-1-git-send-email-zhangfei.gao@linaro.org>	<1396672506-9296-4-git-send-email-zhangfei.gao@linaro.org> <20140407.145356.928382660541891827.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux@arm.linux.org.uk, arnd@arndb.de, f.fainelli@gmail.com,
	sergei.shtylyov@cogentembedded.com, mark.rutland@arm.com,
	David.Laight@ACULAB.COM, eric.dumazet@gmail.com,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	devicetree@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f51.google.com ([209.85.160.51]:47211 "EHLO
	mail-pb0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756544AbaDHIHq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Apr 2014 04:07:46 -0400
Received: by mail-pb0-f51.google.com with SMTP id uo5so697666pbc.10
        for <netdev@vger.kernel.org>; Tue, 08 Apr 2014 01:07:46 -0700 (PDT)
In-Reply-To: <20140407.145356.928382660541891827.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear David

On 04/08/2014 02:53 AM, David Miller wrote:
> From: Zhangfei Gao <zhangfei.gao@linaro.org>
> Date: Sat,  5 Apr 2014 12:35:06 +0800
>
>> +struct tx_desc {
>> +	u32 send_addr;
>> +	u16 reserved_16;
>> +	u16 send_size;
>> +	u32 reserved_32;
>> +	u32 cfg;
>> +	u32 wb_addr;
>> +} ____cacheline_aligned;
>
> I do not think that ____cacheline_aligned is appropriate at all here.
>
> First of all, this is a hardware descriptor, so it has a fixed layout
> and therefore size.
>
> Secondly, unless you declare this object statically in the data section
> of the object file, the alignment doesn't matter.  These descriptors
> are always dynamically allocated, rather than instantiated in the
> kernel/driver image.

The ____cacheline_aligned used here is only for the requirement of 
alignment, and use dma_alloc_coherent, while at first dma_pool is used 
for the requirement of alignment.
Otherwise desc[1] is not aligned and can not be used directly, the 
structure is smaller.

>
>> +	val = (duplex) ? BIT(0) : 0;
>
> Parenthesis around duplex is not necessary, please remove.
OK
>
>> +static void hip04_reset_ppe(struct hip04_priv *priv)
>> +{
>> +	u32 val, tmp;
>> +
>> +	do {
>> +		regmap_read(priv->map, priv->port * 4 + PPE_CURR_BUF_CNT, &val);
>> +		regmap_read(priv->map, priv->port * 4 + PPE_CFG_RX_ADDR, &tmp);
>> +	} while (val & 0xfff);
>> +}
>
> This polling loop can loop forever, if the condition never triggers it will
> loop forever.  You must add some kind of limit or timeout, and subsequent
> error handing up the call chain to handle this.
OK
>
>> +	val = readl_relaxed(priv->base + PPE_CFG_STS_MODE);
>> +	val |= BIT(12);			/* PPE_HIS_RX_PKT_CNT read clear */
>> +	writel_relaxed(val, priv->base + PPE_CFG_STS_MODE);
>   ...
>> +	/* set bus ctrl */
>> +	val = BIT(14);			/* buffer locally release */
>> +	val |= BIT(0);			/* big endian */
>> +	writel_relaxed(val, priv->base + PPE_CFG_BUS_CTRL_REG);
>
> Instead of having to set only one bit at a time in every register and
> adding comments here, just define these register values using macros
> properly in a header file or similar.
>
> Then you can go val |= PPE_CFG_BUS_CTRL_VAL_THIS | PPE_CFG_BUS_CTRL_VAL_THAT
> on one line.
>
> Document the registers where you define the macros, that way people can learn
> what other bits are in these register and what they mean, even if you don't
> currently use them in the driver itself.
OK, got it.
However, some bits is not planed to open since used internally and may 
be removed later.

>
>> +static void hip04_tx_reclaim(struct net_device *ndev, bool force)
>   ...
>> +static void hip04_xmit_timer(unsigned long data)
>> +{
>> +	struct net_device *ndev = (void *) data;
>> +
>> +	hip04_tx_reclaim(ndev, false);
>> +}
>   ...
>> +	mod_timer(&priv->txtimer, jiffies + RECLAIM_PERIOD);
>
> And this is where I stop reading your driver, I've stated already that this
> kind of reclaim scheme is unacceptable.
>
> The kernel timers lack the granularity necessary to service TX reclaim
> with a reasonable amount of latency.
>
> You must use some kind of hardware notification of TX slots becomming
> available, I find it totally impossible that a modern ethernet controller
> was created without a TX done interrupt.
>

I am sorry, but unfortunately this series really does NOT have TX done 
interrupt after checked with hardware guy many times.
And next series will add TX done interrupt according to the feedback.

There are two reasons of removing the TX done interrupt when the chip is 
designed.
1. The specific product does not care the latency, only care the throughput.
2. When doing many experiment, the tx done interrupt will impact the 
throughput, as a result reclaim is moved to xmit as one of 
optimizations, then finally tx done interrupt is removed at all.

Is it acceptable of removing timer as well as latency handling, or any 
other work around of this kind of hardware?

Thanks
