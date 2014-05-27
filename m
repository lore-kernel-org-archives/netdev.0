From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [PATCH v2 2/2] net: hisilicon: add hix5hd2 mac driver
Date: Tue, 27 May 2014 14:57:27 +0100
Message-ID: <20140527135727.GC6969@leverpostej>
References: <1401194667-14445-1-git-send-email-zhangfei.gao@linaro.org>
 <1401194667-14445-3-git-send-email-zhangfei.gao@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"arnd@arndb.de" <arnd@arndb.de>,
	"f.fainelli@gmail.com" <f.fainelli@gmail.com>,
	"sergei.shtylyov@cogentembedded.com"
	<sergei.shtylyov@cogentembedded.com>,
	"David.Laight@ACULAB.COM" <David.Laight@ACULAB.COM>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	"haifeng.yan@linaro.org" <haifeng.yan@linaro.org>,
	"jchxue@gmail.com" <jchxue@gmail.com>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>
To: Zhangfei Gao <zhangfei.gao@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cam-admin0.cambridge.arm.com ([217.140.96.50]:50166 "EHLO
	cam-admin0.cambridge.arm.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752078AbaE0N6G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 May 2014 09:58:06 -0400
Content-Disposition: inline
In-Reply-To: <1401194667-14445-3-git-send-email-zhangfei.gao@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 27, 2014 at 01:44:27PM +0100, Zhangfei Gao wrote:
> Add support for the hix5hd2 XGMAC 1Gb ethernet device.
> The controller requires two queues for tx and two queues for rx.
> Controller fetch buffer from free queue and then push to used queue.
> Diver should prepare free queue and free buffer from used queue.
> 
> Signed-off-by: Zhangfei Gao <zhangfei.gao@linaro.org>
> ---
>  drivers/net/ethernet/Kconfig                  |    1 +
>  drivers/net/ethernet/Makefile                 |    1 +
>  drivers/net/ethernet/hisilicon/Kconfig        |   27 +
>  drivers/net/ethernet/hisilicon/Makefile       |    5 +
>  drivers/net/ethernet/hisilicon/hix5hd2_gmac.c | 1057 +++++++++++++++++++++++++
>  5 files changed, 1091 insertions(+)
>  create mode 100644 drivers/net/ethernet/hisilicon/Kconfig
>  create mode 100644 drivers/net/ethernet/hisilicon/Makefile
>  create mode 100644 drivers/net/ethernet/hisilicon/hix5hd2_gmac.c

[...]

> +struct hix5hd2_desc {
> +       __le32 buff_addr;
> +       __le32 cmd;
> +} __aligned(32);

[...]

> +static void hix5hd2_rx_refill(struct hix5hd2_priv *priv)
> +{
> +       struct hix5hd2_desc *desc;
> +       struct sk_buff *skb;
> +       u32 start, end, num, pos, i;
> +
> +       /* software write pointer */
> +       start = dma_cnt(readl_relaxed(priv->base + RX_FQ_WR_ADDR));
> +       /* logic read pointer */
> +       end = dma_cnt(readl_relaxed(priv->base + RX_FQ_RD_ADDR));
> +       num = CIRC_SPACE(start, end, RX_DESC_NUM);
> +
> +       for (i = 0, pos = start; i < num; i++) {
> +               if (priv->rx_skb[pos])
> +                       break;
> +               else {
> +                       skb = netdev_alloc_skb_ip_align(priv->netdev,
> +                               MAC_MAX_FRAME_SIZE);
> +                       if (unlikely(skb == NULL))
> +                               break;
> +               }
> +
> +               desc = priv->rx_fq.desc + pos;
> +               desc->buff_addr =
> +                       dma_map_single(priv->dev, skb->data,
> +                                       MAC_MAX_FRAME_SIZE, DMA_FROM_DEVICE);

buff_addr was declared as an __le32, but here we're pasting values of
the kernel's native endianness (which might not be little). You will
need to carefully convert the endianness of this value when dealing with
it.

> +               if (dma_mapping_error(priv->dev, desc->buff_addr)) {
> +                       dev_kfree_skb_any(skb);
> +                       break;
> +               }
> +
> +               priv->rx_skb[pos] = skb;
> +               desc->cmd = (MAC_MAX_FRAME_SIZE - 1) | DESC_VLD_FREE;

Likewise cmd was described as an __le32 and needs to be converted
appropriately.

Cheers,
Mark.
