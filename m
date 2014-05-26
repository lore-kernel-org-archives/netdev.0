From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 3/3] net: hisilicon: add hix5hd2 mac driver
Date: Mon, 26 May 2014 16:51:15 +0200
Message-ID: <201405261651.15998.arnd@arndb.de>
References: <1400504227-12047-1-git-send-email-zhangfei.gao@linaro.org> <1400504227-12047-4-git-send-email-zhangfei.gao@linaro.org>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, f.fainelli@gmail.com,
	sergei.shtylyov@cogentembedded.com, mark.rutland@arm.com,
	David.Laight@aculab.com, eric.dumazet@gmail.com,
	haifeng.yan@linaro.org, jchxue@gmail.com,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	devicetree@vger.kernel.org
To: Zhangfei Gao <zhangfei.gao@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.17.24]:51784 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752553AbaEZOv7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 May 2014 10:51:59 -0400
In-Reply-To: <1400504227-12047-4-git-send-email-zhangfei.gao@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 19 May 2014, Zhangfei Gao wrote:

I only noticed one real issue with the driver:

> +struct hix5hd2_desc {
> +	__le32 buff_addr;
> +	__le32 buff_len:11;
> +	__le32 reserve2:5;
> +	__le32 data_len:11;
> +	__le32 reserve1:2;
> +	__le32 fl:2;
> +	__le32 descvid:1;
> +} __aligned(32);
> +

You should generall not use bitfields in hardware data structures, as that is
not endian safe and will prevent running a big-endian kernel on this machine.
Better convert this to a set of __le32 fields and explicit shifts and masks.

Two smaller things you should think about, I'm not entirely sure about these:

> +static int hix5hd2_rx(struct net_device *dev, int limit)
> +{
> +	struct hix5hd2_priv *priv = netdev_priv(dev);
> +	struct sk_buff *skb;
> +	struct hix5hd2_desc *desc;
> +	dma_addr_t dma_addr;
> +	u32 start, end, num, pos, i, len;
> +
> +	/* software read pointer */
> +	start = dma_cnt(readl_relaxed(priv->base + RX_BQ_RD_ADDR));
> +	/* logic write pointer */
> +	end = dma_cnt(readl_relaxed(priv->base + RX_BQ_WR_ADDR));

I think one of these needs to be readl() instead of readl_relaxed(),
to ensure the data is correctly ordered with regard to the pointer
access.

> +	if (pos != start)
> +		writel(dma_byte(pos), priv->base + TX_RQ_RD_ADDR);

While this looks like it could be writel_relaxed().

	Arnd
