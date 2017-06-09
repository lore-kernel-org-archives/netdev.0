From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] l2tp: cast l2tp traffic counter to unsigned
Date: Fri, 9 Jun 2017 15:16:21 -0700
Message-ID: <20170609151621.11e610a2@xeon-e3>
References: <20170609142947.16969-1-dheidler@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Tom Parkin <tparkin@katalix.com>
To: Dominik Heidler <dheidler@suse.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170609142947.16969-1-dheidler@suse.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri,  9 Jun 2017 16:29:47 +0200
Dominik Heidler <dheidler@suse.de> wrote:

> This fixes a counter problem on 32bit systems:
> When the rx_bytes counter reached 2 GiB, it jumpd to (2^64 Bytes - 2GiB) Bytes.
> 
> rtnl_link_stats64 has __u64 type and atomic_long_read returns
> atomic_long_t which is signed. Due to the conversation
> we get an incorrect value on 32bit systems if the MSB of
> the atomic_long_t value is set.
> 
> CC: Tom Parkin <tparkin@katalix.com>
> Fixes: 7b7c0719cd7a ("l2tp: avoid deadlock in l2tp stats update")
> Signed-off-by: Dominik Heidler <dheidler@suse.de>
> ---
>  net/l2tp/l2tp_eth.c | 13 +++++++------
>  1 file changed, 7 insertions(+), 6 deletions(-)
> 
> diff --git a/net/l2tp/l2tp_eth.c b/net/l2tp/l2tp_eth.c
> index 8b21af7321b9..668a75e002e9 100644
> --- a/net/l2tp/l2tp_eth.c
> +++ b/net/l2tp/l2tp_eth.c
> @@ -114,12 +114,13 @@ static void l2tp_eth_get_stats64(struct net_device *dev,
>  {
>  	struct l2tp_eth *priv = netdev_priv(dev);
>  
> -	stats->tx_bytes   = atomic_long_read(&priv->tx_bytes);
> -	stats->tx_packets = atomic_long_read(&priv->tx_packets);
> -	stats->tx_dropped = atomic_long_read(&priv->tx_dropped);
> -	stats->rx_bytes   = atomic_long_read(&priv->rx_bytes);
> -	stats->rx_packets = atomic_long_read(&priv->rx_packets);
> -	stats->rx_errors  = atomic_long_read(&priv->rx_errors);
> +	stats->tx_bytes   = (unsigned long) atomic_long_read(&priv->tx_bytes);
> +	stats->tx_packets = (unsigned long) atomic_long_read(&priv->tx_packets);
> +	stats->tx_dropped = (unsigned long) atomic_long_read(&priv->tx_dropped);
> +	stats->rx_bytes   = (unsigned long) atomic_long_read(&priv->rx_bytes);
> +	stats->rx_packets = (unsigned long) atomic_long_read(&priv->rx_packets);
> +	stats->rx_errors  = (unsigned long) atomic_long_read(&priv->rx_errors);
> +
>  }
>  
>  static const struct net_device_ops l2tp_eth_netdev_ops = {

This is not the right way to fix this.

1. shouldn't be using atomic's for network counters, look at other network devices.

2. should be using u64_stats_fetch  api to handle 64 bit counters.
