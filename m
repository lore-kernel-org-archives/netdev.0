From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH v4] net: ethernet: add driver for Aurora VLSI NB8800
 Ethernet controller
Date: Fri, 30 Oct 2015 23:28:42 +0100
Message-ID: <20151030222841.GA24712@electric-eye.fr.zoreil.com>
References: <1446137333-1822-1-git-send-email-mans@mansr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Mans Rullgard <mans@mansr.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1446137333-1822-1-git-send-email-mans@mansr.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mans Rullgard <mans@mansr.com> :
[...]
> diff --git a/drivers/net/ethernet/aurora/nb8800.c b/drivers/net/ethernet/aurora/nb8800.c
> new file mode 100644
> index 0000000..ce61439
> --- /dev/null
> +++ b/drivers/net/ethernet/aurora/nb8800.c
[...]
> +static int nb8800_mdio_read(struct mii_bus *bus, int phy_id, int reg)
> +{
> +	struct nb8800_priv *priv = bus->priv;
> +	int val;
> +
> +	if (!nb8800_mdio_wait(bus))
> +		return -ETIMEDOUT;
> +
> +	val = MIIAR_ADDR(phy_id) | MIIAR_REG(reg);
> +
> +	nb8800_writel(priv, NB8800_MDIO_CMD, val);
> +	udelay(10);
> +	nb8800_writel(priv, NB8800_MDIO_CMD, val | MDIO_CMD_GO);
> +
> +	if (!nb8800_mdio_wait(bus))
> +		return -ETIMEDOUT;

You may add a "nb8800_mdio_cmd" helper to factor the lines above in
nb8800_mdio_{read / write}. It could save some bytes.

[...]
> +static void nb8800_mac_tx(struct net_device *dev, bool enable)
> +{
> +	struct nb8800_priv *priv = netdev_priv(dev);
> +
> +	while (nb8800_readl(priv, NB8800_TXC_CR) & TCR_EN)
> +		cpu_relax();
> +
> +	if (enable)
> +		nb8800_set_bits(b, priv, NB8800_TX_CTL1, TX_EN);
> +	else
> +		nb8800_clear_bits(b, priv, NB8800_TX_CTL1, TX_EN);
[...]
> +	if (enable)
> +		nb8800_set_bits(b, priv, NB8800_RX_CTL, RX_EN);
> +	else
> +		nb8800_clear_bits(b, priv, NB8800_RX_CTL, RX_EN);
[...]
> +	if (enable)
> +		nb8800_set_bits(b, priv, NB8800_RX_CTL, RX_AF_EN);
> +	else
> +		nb8800_clear_bits(b, priv, NB8800_RX_CTL, RX_AF_EN);

Factor out ?

[...]
> +static int nb8800_poll(struct napi_struct *napi, int budget)
> +{
> +	struct net_device *dev = napi->dev;
> +	struct nb8800_priv *priv = netdev_priv(dev);
> +	struct nb8800_dma_desc *rx;
> +	int work = 0;
> +	int last = priv->rx_eoc;
> +	int next;
> +
> +	while (work < budget) {
> +		struct rx_buf *rx_buf;
> +		u32 report;
> +		int len;
> +
> +		next = (last + 1) & (RX_DESC_COUNT - 1);
> +
> +		rx_buf = &priv->rx_bufs[next];
> +		rx = &priv->rx_descs[next];
> +		report = rx->report;
> +
> +		if (!report)
> +			break;
> +
> +		if (IS_RX_ERROR(report)) {
> +			nb8800_rx_error(dev, report);
> +		} else if (likely(rx_buf->page)) {
> +			len = RX_BYTES_TRANSFERRED(report);
> +			nb8800_receive(dev, next, len);
> +		}
> +
> +		rx->report = 0;
> +		if (!rx_buf->page)
> +			nb8800_alloc_rx(dev, next, true);

It looks like it receives, then tries to allocate new resources. If so
it may deplete the ring and you should instead consider allocating new
resources first, then receive data if alloc + map suceeded.

-- 
Ueimor
