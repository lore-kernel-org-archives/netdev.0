From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH v2] net: add Faraday FTMAC100 10/100 Ethernet driver
Date: Mon, 17 Jan 2011 09:19:48 -0800
Message-ID: <1295284788.21277.65.camel@Joe-Laptop>
References: <1294919372-1904-1-git-send-email-ratbert.chuang@gmail.com>
	 <1295256060-2091-1-git-send-email-ratbert.chuang@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	ratbert@faraday-tech.com, bhutchings@solarflare.com,
	eric.dumazet@gmail.com, dilinger@queued.net
To: Po-Yu Chuang <ratbert.chuang@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1295256060-2091-1-git-send-email-ratbert.chuang@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2011-01-17 at 17:21 +0800, Po-Yu Chuang wrote:
> From: Po-Yu Chuang <ratbert@faraday-tech.com>
> FTMAC100 Ethernet Media Access Controller supports 10/100 Mbps and
> MII.  This driver has been working on some ARM/NDS32 SoC's including
> Faraday A320 and Andes AG101.

Hi again.

> Signed-off-by: Po-Yu Chuang <ratbert@faraday-tech.com>
> ---
> v2:
> always use NAPI
> do not use our own net_device_stats structure
> don't set trans_start and last_rx
> stats.rx_packets and stats.rx_bytes include dropped packets
> add missed netif_napi_del()
> initialize spinlocks in probe function
> remove rx_lock and hw_lock
> use netdev_[err/info/dbg] instead of dev_* ones
> use netdev_alloc_skb_ip_align()
> remove ftmac100_get_stats()
> use is_valid_ether_addr() instead of is_zero_ether_addr()
> add const to ftmac100_ethtool_ops and ftmac100_netdev_ops
> use net_ratelimit() instead of printk_ratelimit()
> no explicit inline
> use %pM to print MAC address
> add comment before wmb
> use napi poll() to handle all interrupts

This looks very clean, thanks for doing the rework.

Now the the really trivial...

> + * priveate data

private

> +static void ftmac100_enable_all_int(struct ftmac100 *priv)
> +{
> +	unsigned int imr;
> +
> +	imr = FTMAC100_INT_RPKT_FINISH | FTMAC100_INT_NORXBUF
> +	     | FTMAC100_INT_XPKT_OK | FTMAC100_INT_XPKT_LOST
> +	     | FTMAC100_INT_RPKT_LOST | FTMAC100_INT_AHB_ERR
> +	     | FTMAC100_INT_PHYSTS_CHG;

This could be a #define.

> +	maccr = FTMAC100_MACCR_XMT_EN |
> +		FTMAC100_MACCR_RCV_EN |
> +		FTMAC100_MACCR_XDMA_EN |
> +		FTMAC100_MACCR_RDMA_EN |
> +		FTMAC100_MACCR_CRC_APD |
> +		FTMAC100_MACCR_FULLDUP |
> +		FTMAC100_MACCR_RX_RUNT |
> +		FTMAC100_MACCR_RX_BROADPKT;

Here too.

> +static int ftmac100_rx_packet_error(struct ftmac100 *priv,
> +		struct ftmac100_rxdes *rxdes)
[]
> +	if (unlikely(ftmac100_rxdes_frame_too_long(rxdes))) {
> +		if (net_ratelimit())
> +			netdev_info(netdev, "rx frame too long\n");
> +
> +		netdev->stats.rx_length_errors++;
> +		error = 1;
> +	}
> +
> +	if (unlikely(ftmac100_rxdes_runt(rxdes))) {

else if ?

> +static int ftmac100_rx_packet(struct ftmac100 *priv, int *processed)
> +{
> +	struct net_device *netdev = priv->netdev;
> +	struct ftmac100_rxdes *rxdes;
> +	struct sk_buff *skb;
> +	int length;
> +	int copied = 0;
> +	int done = 0;

You could use bool/true/false here for copied and done
and all the other uses of an int for a logical bool.

> +static void ftmac100_txdes_set_dma_own(struct ftmac100_txdes *txdes)
> +{
> +	/*
> +	 * Make sure dma own bit will not be set before any other
> +	 * descriptor fiels.

field/fields

> +static int ftmac100_mdio_read(struct net_device *netdev, int phy_id, int reg)
> +{
> +	struct ftmac100 *priv = netdev_priv(netdev);
> +	int phycr;
> +	int i;
> +
> +	phycr = FTMAC100_PHYCR_PHYAD(phy_id) |
> +		FTMAC100_PHYCR_REGAD(reg) |
> +		FTMAC100_PHYCR_MIIRD;
> +
> +	iowrite32(phycr, priv->base + FTMAC100_OFFSET_PHYCR);
> +	for (i = 0; i < 10; i++) {
> +		phycr = ioread32(priv->base + FTMAC100_OFFSET_PHYCR);
> +
> +		if ((phycr & FTMAC100_PHYCR_MIIRD) == 0)
> +			return phycr & FTMAC100_PHYCR_MIIRDATA;
> +
> +		usleep_range(100, 1000);
> +	}
> +
> +	netdev_err(netdev, "mdio read timed out\n");
> +	return 0xffff;

0xffff is a rather odd return, perhaps a #define?

> +/******************************************************************************
> + * initialization / finalization
> + *****************************************************************************/
> +static int __init ftmac100_init(void)
> +{
> +	printk(KERN_INFO "Loading " DRV_NAME ": version " DRV_VERSION " ...\n");

You could use
#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
before any #include and
	pr_info("Loading version " DRV_VERSION " ...\n");

One last comment on split long line indentation style
and long function declarations.

There's no required style so you can use what you are
most comfortable doing.

Most of drivers/net uses an alignment to open parenthesis
using maximal tabs and minimal necessary spaces instead of
an extra tabstop.

Like:

static int some_long_function(type var1, type var2...
			      type varN)
and
	some_long_function(var1, var2, ...
			   varN);

not
static int some_long_function(type var1, type var2...
				type varN)
and
	some_long_function(var1, var2, ...
				varN);
