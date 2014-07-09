From: ethan zhao <ethan.zhao@oracle.com>
Subject: Re: [PATCH NET-NEXT V2] netxen: fix ethtool rx_dropped information
 in ethtool get_ethtool_stats()
Date: Wed, 09 Jul 2014 10:41:23 +0800
Message-ID: <53BCABD3.3050207@oracle.com>
References: <1404827830-22990-1-git-send-email-ethan.zhao@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: balbi@ti.com, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	sriharsha.devdas@oracle.com, ethan.kernel@gmail.com,
	vaughan <vaughan.cao@oracle.com>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1404827830-22990-1-git-send-email-ethan.zhao@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David,

    Please help to review and confirm this patch.

Thanks,
Ethan

On 2014/7/8 21:57, Ethan Zhao wrote:
> netxen driver has implemented netxen_nic_get_ethtool_stats() interface,
> but it doesn't collect stats.rxdropped in driver, so we will get
> different rx_dropped statistic information while using ifconfig and ethtool.
> this patch fills stats.rxdropped field with data from net core
> with dev_get_stats() just as ixgbe driver did for some of its stats.
>
> V2: only fix the stats.rxdropped field.
>
> Tested with last netxen 4.0.82
> Compiled with net-next branch 3.16-rc2
>
> Signed-off-by: Ethan Zhao <ethan.zhao@oracle.com>
> Tested-by: Sriharsha Yadagudde <sriharsha.devdas@oracle.com>
> ---
>   .../ethernet/qlogic/netxen/netxen_nic_ethtool.c    |   34 +++++++++++++++++---
>   1 files changed, 29 insertions(+), 5 deletions(-)
>
> diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_ethtool.c b/drivers/net/ethernet/qlogic/netxen/netxen_nic_ethtool.c
> index 4ca2c19..49e6a1b 100644
> --- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_ethtool.c
> +++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_ethtool.c
> @@ -33,22 +33,30 @@
>   #include "netxen_nic.h"
>   #include "netxen_nic_hw.h"
>   
> +enum {NETDEV_STATS, NETXEN_STATS};
> +
>   struct netxen_nic_stats {
>   	char stat_string[ETH_GSTRING_LEN];
> +	int type;
>   	int sizeof_stat;
>   	int stat_offset;
>   };
>   
> -#define NETXEN_NIC_STAT(m) sizeof(((struct netxen_adapter *)0)->m), \
> +#define NETXEN_NIC_STAT(m)	NETXEN_STATS, \
> +			sizeof(((struct netxen_adapter *)0)->m), \
>   			offsetof(struct netxen_adapter, m)
>   
> +#define NETXEN_NETDEV_STAT(m)	NETDEV_STATS, \
> +			sizeof(((struct rtnl_link_stats64 *)0)->m), \
> +			offsetof(struct rtnl_link_stats64, m)
> +
>   #define NETXEN_NIC_PORT_WINDOW 0x10000
>   #define NETXEN_NIC_INVALID_DATA 0xDEADBEEF
>   
>   static const struct netxen_nic_stats netxen_nic_gstrings_stats[] = {
>   	{"xmit_called", NETXEN_NIC_STAT(stats.xmitcalled)},
>   	{"xmit_finished", NETXEN_NIC_STAT(stats.xmitfinished)},
> -	{"rx_dropped", NETXEN_NIC_STAT(stats.rxdropped)},
> +	{"rx_dropped", NETXEN_NETDEV_STAT(rx_dropped)},
>   	{"tx_dropped", NETXEN_NIC_STAT(stats.txdropped)},
>   	{"csummed", NETXEN_NIC_STAT(stats.csummed)},
>   	{"rx_pkts", NETXEN_NIC_STAT(stats.rx_pkts)},
> @@ -679,11 +687,27 @@ netxen_nic_get_ethtool_stats(struct net_device *dev,
>   {
>   	struct netxen_adapter *adapter = netdev_priv(dev);
>   	int index;
> +	struct rtnl_link_stats64 temp;
> +	const struct rtnl_link_stats64 *net_stats;
> +	char *p = NULL;
>   
> +	net_stats = dev_get_stats(dev, &temp);
>   	for (index = 0; index < NETXEN_NIC_STATS_LEN; index++) {
> -		char *p =
> -		    (char *)adapter +
> -		    netxen_nic_gstrings_stats[index].stat_offset;
> +
> +		switch (netxen_nic_gstrings_stats[index].type) {
> +		case NETDEV_STATS:
> +			p = (char *)net_stats +
> +				netxen_nic_gstrings_stats[index].stat_offset;
> +			break;
> +		case NETXEN_STATS:
> +			p = (char *)adapter +
> +				netxen_nic_gstrings_stats[index].stat_offset;
> +			break;
> +		default:
> +			data[index] = 0;
> +			continue;
> +		}
> +
>   		data[index] =
>   		    (netxen_nic_gstrings_stats[index].sizeof_stat ==
>   		     sizeof(u64)) ? *(u64 *) p : *(u32 *) p;
