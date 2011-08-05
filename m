From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [net-next-2.6 PATCH] enic: Add timestamp to network interface
 stats
Date: Thu, 4 Aug 2011 21:42:18 -0700
Message-ID: <20110804214218.30621022@nehalam.ftrdhcpuser.net>
References: <20110805001124.32402.42919.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Danny Guo <dannguo@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:58716 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750751Ab1HEEmL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Aug 2011 00:42:11 -0400
In-Reply-To: <20110805001124.32402.42919.stgit@savbu-pc100.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 04 Aug 2011 17:11:24 -0700
Danny Guo <dannguo@cisco.com> wrote:

> From: Danny Guo <dannguo@cisco.com>
> 
> This patch adds timestamps in ethtool stats. It makes it easier to provide scripts to users to calculate throughput, etc. It also allows software to synchronize timestamps with host time for correlating host events with stats collection.
> 
> Signed-off-by: Danny Guo <dannguo@cisco.com>
> Signed-off-by: Vasanthy Kolluri <vkolluri@cisco.com>
> Signed-off-by: Roopa Prabhu <roprabhu@cisco.com>
> Signed-off-by: David Wang <dwang2@cisco.com>


The concept is okay, but don't like drivers doing device specific
things all the time.

> ---
>  drivers/net/enic/enic.h       |    2 +-
>  drivers/net/enic/enic_main.c  |    7 ++++++-
>  drivers/net/enic/vnic_dev.c   |    1 +
>  drivers/net/enic/vnic_stats.h |    1 +
>  4 files changed, 9 insertions(+), 2 deletions(-)
> 
> 
> diff --git a/drivers/net/enic/enic.h b/drivers/net/enic/enic.h
> index ce76d9a..2e58bdc 100644
> --- a/drivers/net/enic/enic.h
> +++ b/drivers/net/enic/enic.h
> @@ -32,7 +32,7 @@
>  
>  #define DRV_NAME		"enic"
>  #define DRV_DESCRIPTION		"Cisco VIC Ethernet NIC Driver"
> -#define DRV_VERSION		"2.1.1.24"
> +#define DRV_VERSION		"2.1.1.25"
>  #define DRV_COPYRIGHT		"Copyright 2008-2011 Cisco Systems, Inc"
>  
>  #define ENIC_BARS_MAX		6
> diff --git a/drivers/net/enic/enic_main.c b/drivers/net/enic/enic_main.c
> index 67a27cd..a3f61c1 100644
> --- a/drivers/net/enic/enic_main.c
> +++ b/drivers/net/enic/enic_main.c
> @@ -121,6 +121,8 @@ static const struct enic_stat enic_rx_stats[] = {
>  static const unsigned int enic_n_tx_stats = ARRAY_SIZE(enic_tx_stats);
>  static const unsigned int enic_n_rx_stats = ARRAY_SIZE(enic_rx_stats);
>  
> +#define ENIC_TIMESTAMP_STAT_NAME	"timestamp(ns)"
> +
>  static int enic_is_dynamic(struct enic *enic)
>  {
>  	return enic->pdev->device == PCI_DEVICE_ID_CISCO_VIC_ENET_DYN;
> @@ -224,6 +226,8 @@ static void enic_get_strings(struct net_device *netdev, u32 stringset, u8 *data)
>  			memcpy(data, enic_rx_stats[i].name, ETH_GSTRING_LEN);
>  			data += ETH_GSTRING_LEN;
>  		}
> +		memcpy(data, ENIC_TIMESTAMP_STAT_NAME, ETH_GSTRING_LEN);
> +		data += ETH_GSTRING_LEN;
>  		break;
>  	}
>  }
> @@ -232,7 +236,7 @@ static int enic_get_sset_count(struct net_device *netdev, int sset)
>  {
>  	switch (sset) {
>  	case ETH_SS_STATS:
> -		return enic_n_tx_stats + enic_n_rx_stats;
> +		return enic_n_tx_stats + enic_n_rx_stats + 1;
>  	default:
>  		return -EOPNOTSUPP;
>  	}
> @@ -251,6 +255,7 @@ static void enic_get_ethtool_stats(struct net_device *netdev,
>  		*(data++) = ((u64 *)&vstats->tx)[enic_tx_stats[i].offset];
>  	for (i = 0; i < enic_n_rx_stats; i++)
>  		*(data++) = ((u64 *)&vstats->rx)[enic_rx_stats[i].offset];
> +	*(data++) = vstats->timestamp_ns;
>  }
>  
>  static u32 enic_get_msglevel(struct net_device *netdev)
> diff --git a/drivers/net/enic/vnic_dev.c b/drivers/net/enic/vnic_dev.c
> index 8c4c8cf..656871a 100644
> --- a/drivers/net/enic/vnic_dev.c
> +++ b/drivers/net/enic/vnic_dev.c
> @@ -467,6 +467,7 @@ int vnic_dev_stats_dump(struct vnic_dev *vdev, struct vnic_stats **stats)
>  		if (!vdev->stats)
>  			return -ENOMEM;
>  	}
> +	memset(vdev->stats, 0, sizeof(*vdev->stats));

No, reading stats should not clear them!


>  	*stats = vdev->stats;
>  	a0 = vdev->stats_pa;
> diff --git a/drivers/net/enic/vnic_stats.h b/drivers/net/enic/vnic_stats.h
> index 77750ec..9d5158d 100644
> --- a/drivers/net/enic/vnic_stats.h
> +++ b/drivers/net/enic/vnic_stats.h
> @@ -65,6 +65,7 @@ struct vnic_rx_stats {
>  struct vnic_stats {
>  	struct vnic_tx_stats tx;
>  	struct vnic_rx_stats rx;
> +	u64 timestamp_ns;
>  };

Two problems: one is that you are exposing a timestamp in a random unit, and
the other problem is that is never set (at least in this code).

