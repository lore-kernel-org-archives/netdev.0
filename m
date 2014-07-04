From: ethan zhao <ethan.zhao@oracle.com>
Subject: Re: [PATCH net-next] netxen: fix stats.rxdropped collection in get_ethtool_stats()
Date: Fri, 04 Jul 2014 11:09:45 +0800
Message-ID: <53B61AF9.707@oracle.com>
References: <1404485323-5194-1-git-send-email-ethan.zhao@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, balbi@ti.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, sriharsha.devdas@oracle.com,
	ethan.kernel@gmail.com
To: Ethan Zhao <ethan.zhao@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1404485323-5194-1-git-send-email-ethan.zhao@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Please drop this wrong post and see V2.

Thanks,
Ethan

On 2014/7/4 22:48, Ethan Zhao wrote:
> netxen driver has implemented netxen_nic_get_ethtool_stats() interface,
> but doesn't collect stats.rxdropped in driver, so we will get
> different statistic information while using ifconfig and ethtool.
> this patch fills stats.rxdropped field with data from net core
> with dev_get_stats() just as ixgbe driver does for some of its stats.
>
> Tested with last netxen driver 4.0.82
> Compiled with net-next branch 3.16-rc2
>
> Signed-off-by: Ethan Zhao <ethan.zhao@oracle.com>
> Tested-by: Sriharsha Yadagudde <sriharsha.devdas@oracle.com>
> ---
>   .../ethernet/qlogic/netxen/netxen_nic_ethtool.c    |   42 +++++++++++++++----
>   1 files changed, 33 insertions(+), 9 deletions(-)
>
> diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_ethtool.c b/drivers/net/ethernet/qlogic/netxen/netxen_nic_ethtool.c
> index 4ca2c19..97fc2db 100644
> --- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_ethtool.c
> +++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_ethtool.c
> @@ -33,28 +33,36 @@
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
> -	{"tx_dropped", NETXEN_NIC_STAT(stats.txdropped)},
> +	{"rx_dropped", NETXEN_NETDEV_STAT(rx_dropped)},
> +	{"tx_dropped", NETXEN_NIC_STAT(tx_dropped)},
>   	{"csummed", NETXEN_NIC_STAT(stats.csummed)},
> -	{"rx_pkts", NETXEN_NIC_STAT(stats.rx_pkts)},
> +	{"rx_pkts", NETXEN_NIC_STAT(rx_packets)},
>   	{"lro_pkts", NETXEN_NIC_STAT(stats.lro_pkts)},
> -	{"rx_bytes", NETXEN_NIC_STAT(stats.rxbytes)},
> -	{"tx_bytes", NETXEN_NIC_STAT(stats.txbytes)},
> +	{"rx_bytes", NETXEN_NIC_STAT(rx_bytes)},
> +	{"tx_bytes", NETXEN_NIC_STAT(tx_bytes)},
>   };
>   
>   #define NETXEN_NIC_STATS_LEN	ARRAY_SIZE(netxen_nic_gstrings_stats)
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
> +			data [index] = 0;
> +			continue;
> +		}
> +
>   		data[index] =
>   		    (netxen_nic_gstrings_stats[index].sizeof_stat ==
>   		     sizeof(u64)) ? *(u64 *) p : *(u32 *) p;
