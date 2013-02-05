From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH v2 1/2] NET: ethernet/netlogic: Netlogic XLR/XLS GMAC
 driver
Date: Tue, 5 Feb 2013 19:48:16 +0000
Message-ID: <1360093696.2857.18.camel@bwh-desktop.uk.solarflarecom.com>
References: <1360063819-17555-1-git-send-email-ganesanr@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <linux-mips@linux-mips.org>, <netdev@vger.kernel.org>
To: <ganesanr@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:17755 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756689Ab3BETsU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Feb 2013 14:48:20 -0500
In-Reply-To: <1360063819-17555-1-git-send-email-ganesanr@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-02-05 at 17:00 +0530, ganesanr@broadcom.com wrote:
> From: Ganesan Ramalingam <ganesanr@broadcom.com>
> 
> Add support for the Network Accelerator Engine on Netlogic XLR/XLS
> MIPS SoCs. The XLR/XLS NAE blocks can be configured as one 10G
> interface or four 1G interfaces. This driver supports blocks
> with 1G ports.
> 
> Signed-off-by: Ganesan Ramalingam <ganesanr@broadcom.com>
> ---
>  This patch has to be merged through netdev tree.
> 
>  Changes since v1:
>  * Implementing ethtool using phylib
>  * Free skb buf incase of nlm_fmn_send() fail
>  * Use of ndo_get_stats64 instead of ndo_get_stats
>  * Watchdog timeo fix
[...]
> +static void xlr_stats(struct net_device *ndev, struct rtnl_link_stats64 *stats)
> +{
> +	struct xlr_net_priv *priv = netdev_priv(ndev);
> +
> +	stats->rx_packets = xlr_nae_rdreg(priv->base_addr, RX_PACKET_COUNTER);
> +	stats->tx_packets = xlr_nae_rdreg(priv->base_addr, TX_PACKET_COUNTER);
> +	stats->rx_bytes = xlr_nae_rdreg(priv->base_addr, RX_BYTE_COUNTER);
> +	stats->tx_bytes = xlr_nae_rdreg(priv->base_addr, TX_BYTE_COUNTER);
> +	stats->tx_errors = xlr_nae_rdreg(priv->base_addr, TX_FCS_ERROR_COUNTER);
> +	stats->rx_dropped = xlr_nae_rdreg(priv->base_addr,
> +			RX_DROP_PACKET_COUNTER);
> +	stats->tx_dropped = xlr_nae_rdreg(priv->base_addr,
> +			TX_DROP_FRAME_COUNTER);
[...]

But these are still 32-bit counters in hardware, yes?  So I think you
need to arrange to poll at least the byte counters every few seconds and
maintain the higher bits in software e.g.:

struct xlr_stats {
	spinlock_t lock;
	struct timer timer;
	u64 rx_bytes;
	u64 tx_bytes;
	...
};

static void xlr_poll_stats(struct xlr_net_priv *priv)
{
	struct xlr_stats = &priv->stats;
	u32 counter;

	spin_lock_bh(&stats->lock);
	counter = xlr_nae_rdreg(priv->base_addr, RX_BYTE_COUNTER);
	stats->rx_bytes += (u32)(counter - stats->rx_bytes);
	counter = xlr_nae_rdreg(priv->base_addr, TX_BYTE_COUNTER);
	stats->tx_bytes += (u32)(counter - stats->tx_bytes);
	...
	spin_unlock_bh(&stats->lock);
}

static void xlr_poll_stats_timer(void *data)
{
	struct xlr_net_priv *priv = data;

	xlr_poll_stats(priv);
	mod_timer(&priv->stats.timer, jiffies + 2 * HZ);
}

static void xlr_stats(struct net_device *ndev, struct rtnl_link_stats64 *stats)
{
	struct xlr_net_priv *priv = netdev_priv(ndev);

	xlr_poll_stats(priv);
	...
}

static int xlr_net_probe(struct platform_device *pdev)
{
	...
	spin_lock_init(&priv->stats.lock);
	setup_timer(&priv->stats.timer, xlr_poll_stats_timer, priv);
	...
}

Plus add_timer() and del_timer_sync() when starting/stopping the
interface.  Also you need to clear the software stats if you have to
reset the hardware.  All of which is a fair amount of work but you can't
avoid it if the hardware counters just aren't wide enough.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
