From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH V3 2/8] net: sxgbe: add basic framework for Samsung 10Gb
 ethernet driver
Date: Mon, 17 Mar 2014 14:25:50 -0700
Message-ID: <1395091550.2556.50.camel@joe-AO722>
References: <00bf01cf4221$95373150$bfa593f0$@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-samsung-soc@vger.kernel.org,
	davem@davemloft.net, siva.kallam@samsung.com,
	vipul.pandya@samsung.com, ks.giri@samsung.com,
	ilho215.lee@samsung.com
To: Byungho An <bh74.an@samsung.com>
Return-path: <linux-samsung-soc-owner@vger.kernel.org>
In-Reply-To: <00bf01cf4221$95373150$bfa593f0$@samsung.com>
Sender: linux-samsung-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2014-03-17 at 13:43 -0700, Byungho An wrote:
> From: Siva Reddy <siva.kallam@samsung.com>
> 
> This patch adds support for Samsung 10Gb ethernet driver(sxgbe).

Sorry about the brevity, but this driver is very long and
I don't like to read that much at a time, so this is very
superficial and I didn't read the whole thing.

Trivial notes:

> diff --git a/drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c b/drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c

[]

> +static void sxgbe_clk_csr_set(struct sxgbe_priv_data *priv)
> +{
> +	u32 clk_rate = clk_get_rate(priv->sxgbe_clk);
> +
> +	/* assign the proper divider, this will be used during
> +	 * mdio communication
> +	 */
> +	if (clk_rate < SXGBE_CSR_F_150M)
> +		priv->clk_csr = SXGBE_CSR_100_150M;
> +	else if ((clk_rate >= SXGBE_CSR_F_150M) &&
> +		 (clk_rate <= SXGBE_CSR_F_250M))
> +		priv->clk_csr = SXGBE_CSR_150_250M;
> +	else if ((clk_rate >= SXGBE_CSR_F_250M) &&
> +		 (clk_rate <= SXGBE_CSR_F_300M))
> +		priv->clk_csr = SXGBE_CSR_250_300M;
> +	else if ((clk_rate >= SXGBE_CSR_F_300M) &&
> +		 (clk_rate <= SXGBE_CSR_F_350M))
> +		priv->clk_csr = SXGBE_CSR_300_350M;
> +	else if ((clk_rate >= SXGBE_CSR_F_350M) &&
> +		 (clk_rate <= SXGBE_CSR_F_400M))
> +		priv->clk_csr = SXGBE_CSR_350_400M;
> +	else if ((clk_rate >= SXGBE_CSR_F_400M) &&
> +		 (clk_rate <= SXGBE_CSR_F_500M))
> +		priv->clk_csr = SXGBE_CSR_400_500M;
> +}

This block is unnecessarily hard to read and would be
better without the superfluous tests as:

	if (clk_rate < SXGBE_CSR_F_150M)
		priv->clk_csr = SXGBE_CSR_100_150M;
	else if (clk_rate <= SXGBE_CSR_F_250M)
		priv->clk_csr = SXGBE_CSR_150_250M;
	else if (clk_rate <= SXGBE_CSR_F_300M)
		priv->clk_csr = SXGBE_CSR_250_300M;
	else if (clk_rate <= SXGBE_CSR_F_350M)
		priv->clk_csr = SXGBE_CSR_300_350M;
	else if (clk_rate <= SXGBE_CSR_F_400M)
		priv->clk_csr = SXGBE_CSR_350_400M;
	else if (clk_rate <= SXGBE_CSR_F_500M)
		priv->clk_csr = SXGBE_CSR_400_500M;

I don't understand why the first test is < and the
subsequent tests are <= though.

> +static int init_tx_ring(struct device *dev, u8 queue_no,
> +			struct sxgbe_tx_queue *tx_ring,	int tx_rsize)
> +{
[]
> +	/* allocate memory for TX descriptors */
> +	tx_ring->dma_tx = dma_zalloc_coherent(dev,
> +					      tx_rsize * sizeof(struct sxgbe_tx_norm_desc),
> +					      &tx_ring->dma_tx_phy, GFP_KERNEL);
> +	if (!tx_ring->dma_tx) {
> +		dev_err(dev, "No memory for TX desc of SXGBE\n");
> +		return -ENOMEM;
> +	}
> +
> +	/* allocate memory for TX skbuff array */
> +	tx_ring->tx_skbuff_dma = devm_kcalloc(dev, tx_rsize,
> +					      sizeof(dma_addr_t), GFP_KERNEL);
> +	if (!tx_ring->tx_skbuff_dma) {
> +		dev_err(dev, "No memory for TX skbuffs DMA of SXGBE\n");
> +		goto dmamem_err;
> +	}
> +
> +	tx_ring->tx_skbuff = devm_kcalloc(dev, tx_rsize,
> +					  sizeof(struct sk_buff *), GFP_KERNEL);
> +
> +	if (!tx_ring->tx_skbuff) {
> +		dev_err(dev, "No memory for TX skbuffs of SXGBE\n");
> +		goto dmamem_err;
> +	}

All the OOM messages like these are unnecessary as there is an
existing generic OOM on allocation failures and a dump_stack()

[]

> +static netdev_tx_t sxgbe_xmit(struct sk_buff *skb, struct net_device *dev)
> +{
[]
> +	/* display current ring */
> +	if (netif_msg_pktdata(priv)) {
> +		netdev_dbg(dev, "%s: curr %d dirty=%d entry=%d, first=%p, nfrags=%d\n",
> +			   __func__, (tqueue->cur_tx % tx_rsize),
> +			   (tqueue->dirty_tx % tx_rsize), entry,
> +			   first_desc, nr_frags);

These 2 lines can be combined (and unnecessary parentheses removed)
into:

	netif_dbg(priv, pktdata, dev, "%s: curr %d dirty=%d entry=%d, first=%p, nfrags=%d\n",
		  __func__, tqueue->cur_tx % tx_rsize,
		  tqueue->dirty_tx % tx_rsize, entry,
		  first_desc, nr_frags);

[]

> +/*  sxgbe_get_stats64 - entry point to see statistical information of device
> + *  @dev : device pointer.
> + *  @stats : pointer to hold all the statistical information of device.
> + *  Description:
> + *  This function is a driver entry point whenever ifconfig command gets
> + *  executed to see device statistics. Statistics are number of
> + *  bytes sent or received, errors occured etc.
> + *  Return value:
> + *  This function returns various statistical information of device.
> + */
> +static struct rtnl_link_stats64 *sxgbe_get_stats64(struct net_device *dev,
> +						   struct rtnl_link_stats64 *stats)
> +{
> +	struct sxgbe_priv_data *priv = netdev_priv(dev);
> +	void __iomem *ioaddr = priv->ioaddr;
> +	u64 count;
> +
> +	spin_lock(&priv->stats_lock);
> +	/* Freeze the counter registers before reading value otherwise it may
> +	 * get updated by hardware while we are reading them
> +	 */
> +	writel(SXGBE_MMC_CTRL_CNT_FRZ, ioaddr + SXGBE_MMC_CTL_REG);
> +
> +	stats->rx_bytes = readl(ioaddr + SXGBE_MMC_RXOCTETLO_GCNT_REG);
> +	stats->rx_bytes |= (u64)(readl(ioaddr + SXGBE_MMC_RXOCTETHI_GCNT_REG))
> +		<< 32;

Perhaps it'd be better to use a macro or a function
to return a u64 like:

static inline u64 sxgbe_get_stat64(void __iomem *ioaddr, int reg_lo, int reg_hi)
{
	u64 val = readl(ioaddr + reg_lo);
	val |= ((u64)readl(ioaddr + reg_hi)) << 32;
	return val;
}

> +	stats->rx_packets = readl(ioaddr + SXGBE_MMC_RXFRAMELO_GBCNT_REG);
> +	stats->rx_packets |=
> +		(u64)(readl(ioaddr + SXGBE_MMC_RXFRAMEHI_GBCNT_REG)) << 32;

So this would be:

	stats->rx_packets = sxgbe_get_stat64(ioaddr, SXGBE_MMC_RXFRAMELO_GBCNT_REG, SXGBE_MMC_RXFRAMEHI_GBCNT_REG);

It's a pity all of these registers don't have the same form
as there could then be a macro to simplify that long line
and maybe remove the SXGBE_MMC_<foo>_REG uses.

> +	stats->multicast = readl(ioaddr + SXGBE_MMC_RXMULTILO_GCNT_REG);
> +	stats->multicast |= (u64)(readl(ioaddr + SXGBE_MMC_RXMULTIHI_GCNT_REG))
> +		<< 32;
> +	stats->rx_crc_errors = readl(ioaddr + SXGBE_MMC_RXCRCERRLO_REG);
> +	stats->rx_crc_errors |= (u64)(readl(ioaddr + SXGBE_MMC_RXCRCERRHI_REG))
> +		<< 32;
> +	stats->rx_length_errors = readl(ioaddr + SXGBE_MMC_RXLENERRLO_REG);
> +	stats->rx_length_errors |=
> +		(u64)(readl(ioaddr + SXGBE_MMC_RXLENERRHI_REG))	<< 32;
