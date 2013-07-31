From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH v3] net: Add MOXA ART SoCs ethernet driver
Date: Wed, 31 Jul 2013 11:56:38 -0700
Message-ID: <1375296998.5729.8.camel@joe-AO722>
References: <1374842890-20735-1-git-send-email-jonas.jensen@gmail.com>
	 <1375280401-5564-1-git-send-email-jonas.jensen@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	linux-doc@vger.kernel.org, devicetree@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	arm@kernel.org, florian@openwrt.org
To: Jonas Jensen <jonas.jensen@gmail.com>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <1375280401-5564-1-git-send-email-jonas.jensen@gmail.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2013-07-31 at 16:20 +0200, Jonas Jensen wrote:
> The MOXA UC-711X hardware(s) has an ethernet controller that seem to be
> developed internally. The IC used is "RTL8201CP".

Just some simple comments...

> diff --git a/drivers/net/ethernet/moxa/moxart_ether.c b/drivers/net/ethernet/moxa/moxart_ether.c
[]
> +static int moxart_rx_poll(struct napi_struct *napi, int budget)
[]
> +	while (1) {
[]
> +		if (ui & (RX_ERR | CRC_ERR | FTL | RUNT | RX_ODD_NB)) {
> +			netdev_err(ndev, "packet error\n");

This is generally a bad idea as it can flood
the log.  It's probably better to remove it.
If you really want logging, then at least use
net_ratelimit().  Generally, the stats are
enough.

> +			priv->stats.rx_dropped++;
> +			priv->stats.rx_errors++;
[]
> +static int moxart_mac_start_xmit(struct sk_buff *skb, struct net_device *ndev)
[]
> +	if (txdesc->txdes0.ubit.tx_dma_own) {
> +		netdev_err(ndev, "no TX space for packet\n");
> +		priv->stats.tx_dropped++;

here too.

> +static int moxart_mac_probe(struct platform_device *pdev)
[]
> +	priv->tx_buf_base = kmalloc(priv->tx_buf_size * TX_DESC_NUM,
> +				    GFP_ATOMIC);
> +	if (!priv->tx_buf_base) {
> +		netdev_err(ndev, "TX buffer alloc failed\n");
> +		goto init_fail;
> +	}
> +
> +	priv->rx_buf_base = kmalloc(priv->rx_buf_size * RX_DESC_NUM,
> +				    GFP_ATOMIC);
> +	if (!priv->rx_buf_base) {
> +		netdev_err(ndev, "RX buffer alloc failed\n");
> +		goto init_fail;
> +	}

Extra OOM messages aren't useful, there's a generic
OOM and a dump_stack from the kernel.

> +	netdev_dbg(ndev, "%s: IRQ=%d address=%02x:%02x:%02x:%02x:%02x:%02x\n",
> +		   __func__, ndev->irq,
> +		   ndev->dev_addr[0], ndev->dev_addr[1], ndev->dev_addr[2],
> +		   ndev->dev_addr[3], ndev->dev_addr[4], ndev->dev_addr[5]);

There's a mac address helper you can use:

	netdev_dbg(ndev, "%s: IRQ=%d address=%pM\n"
		   __func__, ndev->irq, ndev->dev_addr);


