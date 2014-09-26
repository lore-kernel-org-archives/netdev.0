From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: [PATCH net-next] bonding: make global bonding stats more reliable
Date: Fri, 26 Sep 2014 10:52:16 +0200
Message-ID: <54252940.6070100@redhat.com>
References: <1411650996-2087-1-git-send-email-gospo@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: j.vosburgh@gmail.com, vfalico@gmail.com
To: Andy Gospodarek <gospo@cumulusnetworks.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47732 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754104AbaIZIw2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Sep 2014 04:52:28 -0400
In-Reply-To: <1411650996-2087-1-git-send-email-gospo@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 25/09/14 15:16, Andy Gospodarek wrote:
> As the code stands today, bonding stats are based simply on the stats
> from the member interfaces.  If a member was to be removed from a bond,
> the stats would instantly drop.  This would be confusing to an admin
> would would suddonly see interface stats drop while traffic is still
> flowing.
>
> In addition to preventing the stats drops mentioned above, new members
> will now be added to the bond and only traffic received after the member
> was added to the bond will be counted as part of bonding stats.
>
> Signed-off-by: Andy Gospodarek <gospo@cumulusnetworks.com>
> ---
Hi Andy,

>   drivers/net/bonding/bond_main.c | 63 +++++++++++++++++++++++++++--------------
>   drivers/net/bonding/bonding.h   |  3 ++
>   2 files changed, 44 insertions(+), 22 deletions(-)
>
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> index 5390475..4543c74 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -1149,11 +1149,19 @@ static struct slave *bond_alloc_slave(struct bonding *bond)
>   	if (!slave)
>   		return NULL;
>
> +	slave->slave_stats = kzalloc(sizeof(struct rtnl_link_stats64),
> +				     GFP_KERNEL);
> +	if (!slave->slave_stats) {
> +		kfree(slave);
> +		return NULL;
> +	}
> +
>   	if (BOND_MODE(bond) == BOND_MODE_8023AD) {
>   		SLAVE_AD_INFO(slave) = kzalloc(sizeof(struct ad_slave_info),
>   					       GFP_KERNEL);
>   		if (!SLAVE_AD_INFO(slave)) {
>   			kfree(slave);
> +			kfree(slave->slave_stats);
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Wrong order. 1. slave_stats, 2. slave.

>   			return NULL;
>   		}
>   	}
> @@ -1167,6 +1175,7 @@ static void bond_free_slave(struct slave *slave)
>   	if (BOND_MODE(bond) == BOND_MODE_8023AD)
>   		kfree(SLAVE_AD_INFO(slave));
>
> +	kfree(slave->slave_stats);
>   	kfree(slave);
>   }
>
> @@ -1344,6 +1353,8 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
>   	}
>
>   	slave_dev->priv_flags |= IFF_BONDING;
> +	/* initialize slave stats */
> +	dev_get_stats(new_slave->dev, new_slave->slave_stats);
>
>   	if (bond_is_lb(bond)) {
>   		/* bond_alb_init_slave() must be called before all other stages since
> @@ -3085,38 +3096,43 @@ static struct rtnl_link_stats64 *bond_get_stats(struct net_device *bond_dev,
>   	struct list_head *iter;
>   	struct slave *slave;
>
> -	memset(stats, 0, sizeof(*stats));
> +	memcpy(stats, bond->bond_stats, sizeof(*stats));
>
>   	bond_for_each_slave(bond, slave, iter) {
>   		const struct rtnl_link_stats64 *sstats =
>   			dev_get_stats(slave->dev, &temp);
> +		struct rtnl_link_stats64 *pstats = slave->slave_stats;
> +
> +		stats->rx_packets +=  sstats->rx_packets - pstats->rx_packets;
> +		stats->rx_bytes += sstats->rx_bytes - pstats->rx_bytes;
> +		stats->rx_errors += sstats->rx_errors - pstats->rx_errors;
> +		stats->rx_dropped += sstats->rx_dropped - pstats->rx_dropped;
>
> -		stats->rx_packets += sstats->rx_packets;
> -		stats->rx_bytes += sstats->rx_bytes;
> -		stats->rx_errors += sstats->rx_errors;
> -		stats->rx_dropped += sstats->rx_dropped;
> +		stats->tx_packets += sstats->tx_packets - pstats->tx_packets;;
> +		stats->tx_bytes += sstats->tx_bytes - pstats->tx_bytes;
> +		stats->tx_errors += sstats->tx_errors - pstats->tx_errors;
> +		stats->tx_dropped += sstats->tx_dropped - pstats->tx_dropped;
>
> -		stats->tx_packets += sstats->tx_packets;
> -		stats->tx_bytes += sstats->tx_bytes;
> -		stats->tx_errors += sstats->tx_errors;
> -		stats->tx_dropped += sstats->tx_dropped;
> +		stats->multicast += sstats->multicast - pstats->multicast;
> +		stats->collisions += sstats->collisions - pstats->collisions;
>
> -		stats->multicast += sstats->multicast;
> -		stats->collisions += sstats->collisions;
> +		stats->rx_length_errors += sstats->rx_length_errors - pstats->rx_length_errors;
> +		stats->rx_over_errors += sstats->rx_over_errors - pstats->rx_over_errors;
> +		stats->rx_crc_errors += sstats->rx_crc_errors - pstats->rx_crc_errors;
> +		stats->rx_frame_errors += sstats->rx_frame_errors - pstats->rx_frame_errors;
> +		stats->rx_fifo_errors += sstats->rx_fifo_errors - pstats->rx_fifo_errors;
> +		stats->rx_missed_errors += sstats->rx_missed_errors - pstats->rx_missed_errors;
>
> -		stats->rx_length_errors += sstats->rx_length_errors;
> -		stats->rx_over_errors += sstats->rx_over_errors;
> -		stats->rx_crc_errors += sstats->rx_crc_errors;
> -		stats->rx_frame_errors += sstats->rx_frame_errors;
> -		stats->rx_fifo_errors += sstats->rx_fifo_errors;
> -		stats->rx_missed_errors += sstats->rx_missed_errors;
> +		stats->tx_aborted_errors += sstats->tx_aborted_errors - pstats->tx_aborted_errors;
> +		stats->tx_carrier_errors += sstats->tx_carrier_errors - pstats->tx_carrier_errors;
> +		stats->tx_fifo_errors += sstats->tx_fifo_errors - pstats->tx_fifo_errors;
> +		stats->tx_heartbeat_errors += sstats->tx_heartbeat_errors - pstats->tx_heartbeat_errors;
> +		stats->tx_window_errors += sstats->tx_window_errors - pstats->tx_window_errors;
>
> -		stats->tx_aborted_errors += sstats->tx_aborted_errors;
> -		stats->tx_carrier_errors += sstats->tx_carrier_errors;
> -		stats->tx_fifo_errors += sstats->tx_fifo_errors;
> -		stats->tx_heartbeat_errors += sstats->tx_heartbeat_errors;
> -		stats->tx_window_errors += sstats->tx_window_errors;
> +		/* save off the slave stats for the next run */
> +		memcpy(pstats, sstats, sizeof(*sstats));
>   	}
> +	memcpy(bond->bond_stats, stats, sizeof(*stats));
>
>   	return stats;
>   }
> @@ -4258,6 +4274,9 @@ static int bond_init(struct net_device *bond_dev)
>   	    bond_dev->addr_assign_type == NET_ADDR_PERM)
>   		eth_hw_addr_random(bond_dev);
>
> +	/* initialize persistent stats for the bond */
> +	bond->bond_stats = kzalloc(sizeof(struct rtnl_link_stats64),
> +				   GFP_ATOMIC);
^^^^^^^^^^^^^^^^^^^^^^^^
I don't think this will get freed if the bond device is destroyed.

>   	return 0;
>   }
>
> diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
> index 6140bf0..fe25265 100644
> --- a/drivers/net/bonding/bonding.h
> +++ b/drivers/net/bonding/bonding.h
> @@ -24,6 +24,7 @@
>   #include <linux/inetdevice.h>
>   #include <linux/etherdevice.h>
>   #include <linux/reciprocal_div.h>
> +#include <linux/if_link.h>
>
>   #include "bond_3ad.h"
>   #include "bond_alb.h"
> @@ -175,6 +176,7 @@ struct slave {
>   	struct netpoll *np;
>   #endif
>   	struct kobject kobj;
> +	struct rtnl_link_stats64 *slave_stats;
>   };
>
>   /*
> @@ -224,6 +226,7 @@ struct bonding {
>   	/* debugging support via debugfs */
>   	struct	 dentry *debug_dir;
>   #endif /* CONFIG_DEBUG_FS */
> +	struct rtnl_link_stats64 *bond_stats;
>   };
>
>   #define bond_slave_get_rcu(dev) \
>
