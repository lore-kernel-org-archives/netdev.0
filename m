From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 4/6] ibmveth: Add ethtool driver stats hooks
Date: Tue, 07 Aug 2007 17:50:47 -0400
Message-ID: <46B8E937.7000901@garzik.org>
References: <11864293333377-patch-mail.ibm.com>
	<200708061942.l76JgZRK020999@d03av03.boulder.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, rcjenn@linux.vnet.ibm.com,
	santil@linux.vnet.ibm.com, netdev@vger.kernel.org
To: Brian King <brking@linux.vnet.ibm.com>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
In-Reply-To: <200708061942.l76JgZRK020999@d03av03.boulder.ibm.com>
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

Brian King wrote:
> Add ethtool hooks to ibmveth to retrieve driver statistics.
> 
> Signed-off-by: Brian King <brking@linux.vnet.ibm.com>
> ---
> 
>  drivers/net/ibmveth.c |   53 +++++++++++++++++++++++++++++++++++++++++++++++++-
>  1 file changed, 52 insertions(+), 1 deletion(-)
> 
> diff -puN drivers/net/ibmveth.c~ibmveth_ethtool_driver_stats drivers/net/ibmveth.c
> --- linux-2.6/drivers/net/ibmveth.c~ibmveth_ethtool_driver_stats	2007-07-19 11:18:41.000000000 -0500
> +++ linux-2.6-bjking1/drivers/net/ibmveth.c	2007-07-19 11:18:41.000000000 -0500
> @@ -112,6 +112,28 @@ MODULE_DESCRIPTION("IBM i/pSeries Virtua
>  MODULE_LICENSE("GPL");
>  MODULE_VERSION(ibmveth_driver_version);
>  
> +struct ibmveth_stat {
> +	char name[ETH_GSTRING_LEN];
> +	int offset;
> +};
> +
> +#define IBMVETH_STAT_OFF(stat) offsetof(struct ibmveth_adapter, stat)
> +#define IBMVETH_GET_STAT(a, off) *((u64 *)(((unsigned long)(a)) + off))
> +
> +struct ibmveth_stat ibmveth_stats[] = {
> +	{ "replenish_task_cycles", IBMVETH_STAT_OFF(replenish_task_cycles) },
> +	{ "replenish_no_mem", IBMVETH_STAT_OFF(replenish_no_mem) },
> +	{ "replenish_add_buff_failure", IBMVETH_STAT_OFF(replenish_add_buff_failure) },
> +	{ "replenish_add_buff_success", IBMVETH_STAT_OFF(replenish_add_buff_success) },
> +	{ "rx_invalid_buffer", IBMVETH_STAT_OFF(rx_invalid_buffer) },
> +	{ "rx_no_buffer", IBMVETH_STAT_OFF(rx_no_buffer) },
> +	{ "tx_multidesc_send", IBMVETH_STAT_OFF(tx_multidesc_send) },
> +	{ "tx_linearized", IBMVETH_STAT_OFF(tx_linearized) },
> +	{ "tx_linearize_failed", IBMVETH_STAT_OFF(tx_linearize_failed) },
> +	{ "tx_map_failed", IBMVETH_STAT_OFF(tx_map_failed) },
> +	{ "tx_send_failed", IBMVETH_STAT_OFF(tx_send_failed) }
> +};
> +
>  /* simple methods of getting data from the current rxq entry */
>  static inline int ibmveth_rxq_pending_buffer(struct ibmveth_adapter *adapter)
>  {
> @@ -751,6 +773,32 @@ static u32 ibmveth_get_rx_csum(struct ne
>  	return adapter->rx_csum;
>  }
>  
> +static void ibmveth_get_strings(struct net_device *dev, u32 stringset, u8 *data)
> +{
> +	int i;
> +
> +	if (stringset != ETH_SS_STATS)
> +		return;
> +
> +	for (i = 0; i < ARRAY_SIZE(ibmveth_stats); i++, data += ETH_GSTRING_LEN)
> +		memcpy(data, ibmveth_stats[i].name, ETH_GSTRING_LEN);
> +}
> +
> +static int ibmveth_get_stats_count(struct net_device *dev)
> +{
> +	return ARRAY_SIZE(ibmveth_stats);
> +}
> +
> +static void ibmveth_get_ethtool_stats(struct net_device *dev,
> +				      struct ethtool_stats *stats, u64 *data)
> +{
> +	int i;
> +	struct ibmveth_adapter *adapter = dev->priv;
> +
> +	for (i = 0; i < ARRAY_SIZE(ibmveth_stats); i++)
> +		data[i] = IBMVETH_GET_STAT(adapter, ibmveth_stats[i].offset);
> +}
> +
>  static const struct ethtool_ops netdev_ethtool_ops = {
>  	.get_drvinfo		= netdev_get_drvinfo,
>  	.get_settings		= netdev_get_settings,
> @@ -761,7 +809,10 @@ static const struct ethtool_ops netdev_e
>  	.get_rx_csum		= ibmveth_get_rx_csum,
>  	.set_rx_csum		= ibmveth_set_rx_csum,
>  	.get_tso			= ethtool_op_get_tso,
> -	.get_ufo			= ethtool_op_get_ufo
> +	.get_ufo			= ethtool_op_get_ufo,
> +	.get_strings		= ibmveth_get_strings,
> +	.get_stats_count		= ibmveth_get_stats_count,
> +	.get_ethtool_stats	= ibmveth_get_ethtool_stats

ACK, modulo comma-at-end-of-initializer per previous email
