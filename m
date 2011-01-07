From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] sh: sh_eth: Add support ethtool
Date: Fri, 07 Jan 2011 14:35:55 +0000
Message-ID: <1294410955.4200.3.camel@bwh-desktop>
References: <1294385126-3098-1-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sh@vger.kernel.org,
	Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>
To: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <1294385126-3098-1-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2011-01-07 at 16:25 +0900, Nobuhiro Iwamatsu wrote:
> This commit supports following functions.
>  - get_drvinfo
>  - get_settings
>  - set_settings
>  - nway_reset
>  - get_msglevel
>  - set_msglevel
>  - get_link
>  - get_strings
>  - get_ethtool_stats
>  - get_sset_count
> 
> About other function, the device does not support.
> 
> Signed-off-by: Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>
> Signed-off-by: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
> ---
>  drivers/net/sh_eth.c |  190 ++++++++++++++++++++++++++++++++++++++++++++++----
>  1 files changed, 176 insertions(+), 14 deletions(-)
> 
> diff --git a/drivers/net/sh_eth.c b/drivers/net/sh_eth.c
> index 819c175..10493e8 100644
> --- a/drivers/net/sh_eth.c
> +++ b/drivers/net/sh_eth.c
> @@ -32,6 +32,7 @@
>  #include <linux/io.h>
>  #include <linux/pm_runtime.h>
>  #include <linux/slab.h>
> +#include <linux/ethtool.h>
>  #include <asm/cacheflush.h>
>  
>  #include "sh_eth.h"
> @@ -573,7 +574,7 @@ static int sh_eth_ring_init(struct net_device *ndev)
>  	}
>  
>  	/* Allocate all Rx descriptors. */
> -	rx_ringsize = sizeof(struct sh_eth_rxdesc) * RX_RING_SIZE;
> +	rx_ringsize = sizeof(struct sh_eth_rxdesc) *RX_RING_SIZE;

Please don't delete spaces just because checkpatch.pl is too stupid to
recognise a multiplication.

Also, don't mix formatting cleanup with actual feature changes.

[...]
> +static const char sh_eth_gstrings_stats[][ETH_GSTRING_LEN] = {
> +	"rx_packets", "tx_packets", "rx_bytes", "tx_bytes", "rx_errors",
> +	"tx_errors", "rx_dropped", "tx_dropped", "multicast", "collisions",
> +	"rx_length_errors", "rx_over_errors", "rx_crc_errors",
> +	"rx_frame_errors", "rx_fifo_errors", "rx_missed_errors",
> +	"tx_aborted_errors", "tx_carrier_errors", "tx_fifo_errors",
> +	"tx_heartbeat_errors", "tx_window_errors",
> +	/* device-specific stats */
> +	"rx_current", "tx_current",
> +	"rx_dirty", "tx_dirty",
> +};
> +#define SH_ETH_NET_STATS_LEN  21
> +#define SH_ETH_STATS_LEN  ARRAY_SIZE(sh_eth_gstrings_stats)
> +
> +static int sh_eth_get_sset_count(struct net_device *netdev, int sset)
> +{
> +	switch (sset) {
> +	case ETH_SS_STATS:
> +		return SH_ETH_STATS_LEN;
> +	default:
> +		return -EOPNOTSUPP;
> +	}
> +}
> +
> +static void sh_eth_get_ethtool_stats(struct net_device *ndev,
> +			struct ethtool_stats *stats, u64 *data)
> +{
> +	struct sh_eth_private *mdp = netdev_priv(ndev);
> +	int i;
> +
> +	for (i = 0; i < SH_ETH_NET_STATS_LEN; i++)
> +		data[i] = ((unsigned long *)&ndev->stats)[i];
[...]

There is no need to duplicate net_device_stats here.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

