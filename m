From: zhangfei <zhangfei.gao-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 3/3] net: hisilicon: add hix5hd2 mac driver
Date: Tue, 27 May 2014 11:57:52 +0800
Message-ID: <53840D40.3000600@linaro.org>
References: <1400504227-12047-1-git-send-email-zhangfei.gao@linaro.org> <1400504227-12047-4-git-send-email-zhangfei.gao@linaro.org> <201405261651.15998.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org,
	David.Laight-JxhZ9S5GRejQT0dZR+AlfA@public.gmane.org, eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	haifeng.yan-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org, jchxue-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <201405261651.15998.arnd-r2nGTMty4D4@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Arnd,

Thanks for the kind suggestions.

On 05/26/2014 10:51 PM, Arnd Bergmann wrote:
> On Monday 19 May 2014, Zhangfei Gao wrote:
>
> I only noticed one real issue with the driver:
>
>> +struct hix5hd2_desc {
>> +	__le32 buff_addr;
>> +	__le32 buff_len:11;
>> +	__le32 reserve2:5;
>> +	__le32 data_len:11;
>> +	__le32 reserve1:2;
>> +	__le32 fl:2;
>> +	__le32 descvid:1;
>> +} __aligned(32);
>> +
>
> You should generall not use bitfields in hardware data structures, as that is
> not endian safe and will prevent running a big-endian kernel on this machine.
> Better convert this to a set of __le32 fields and explicit shifts and masks.

Got it, will update.

More knowledge about big-endian kernel is appreciated, in which case we 
should consider such kernel.
Can we only consider this driver is only running on arm, which is 
little-endian.

>
> Two smaller things you should think about, I'm not entirely sure about these:
>
>> +static int hix5hd2_rx(struct net_device *dev, int limit)
>> +{
>> +	struct hix5hd2_priv *priv = netdev_priv(dev);
>> +	struct sk_buff *skb;
>> +	struct hix5hd2_desc *desc;
>> +	dma_addr_t dma_addr;
>> +	u32 start, end, num, pos, i, len;
>> +
>> +	/* software read pointer */
>> +	start = dma_cnt(readl_relaxed(priv->base + RX_BQ_RD_ADDR));
>> +	/* logic write pointer */
>> +	end = dma_cnt(readl_relaxed(priv->base + RX_BQ_WR_ADDR));
>
> I think one of these needs to be readl() instead of readl_relaxed(),
> to ensure the data is correctly ordered with regard to the pointer
> access.
readl_relaxed can ensure the sequence.

>
>> +	if (pos != start)
>> +		writel(dma_byte(pos), priv->base + TX_RQ_RD_ADDR);
>
> While this looks like it could be writel_relaxed().
>
En, I think all three cases can use xxx_relaxed.
These accesses are just update pointer used by internal logic and get 
pointer updated by internal logic.

Thanks

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
