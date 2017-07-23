From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH V4 net-next 7/8] net: hns3: Add Ethtool support to HNS3
 driver
Date: Sun, 23 Jul 2017 10:05:02 -0700
Message-ID: <23ddbe00-8bef-a09b-5783-3a5438086bd6@gmail.com>
References: <20170722220942.78852-1-salil.mehta@huawei.com>
 <20170722220942.78852-8-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Cc: yisen.zhuang@huawei.com, huangdaode@hisilicon.com,
        lipeng321@huawei.com, mehta.salil.lnk@gmail.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-rdma@vger.kernel.org, linuxarm@huawei.com
To: Salil Mehta <salil.mehta@huawei.com>, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170722220942.78852-8-salil.mehta@huawei.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 07/22/2017 03:09 PM, Salil Mehta wrote:
> This patch adds the support of the Ethtool interface to
> the HNS3 Ethernet driver. Various commands to read the
> statistics, configure the offloading, loopback selftest etc.
> are supported.
> 
> Signed-off-by: Daode Huang <huangdaode@hisilicon.com>
> Signed-off-by: lipeng <lipeng321@huawei.com>
> Signed-off-by: Salil Mehta <salil.mehta@huawei.com>
> Signed-off-by: Yisen Zhuang <yisen.zhuang@huawei.com>
> ---
> Patch V4: addressed below comments
>  1. Andrew Lunn
>     Removed the support of loop PHY back for now
> Patch V3: Address below comments
>  1. Stephen Hemminger
>     https://lkml.org/lkml/2017/6/13/974
>  2. Andrew Lunn
>     https://lkml.org/lkml/2017/6/13/1037
> Patch V2: No change
> Patch V1: Initial Submit
> ---
>  .../ethernet/hisilicon/hns3/hns3pf/hns3_ethtool.c  | 543 +++++++++++++++++++++
>  1 file changed, 543 insertions(+)
>  create mode 100644 drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_ethtool.c
> 
> diff --git a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_ethtool.c b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_ethtool.c
> new file mode 100644
> index 000000000000..82b0d4d829f8
> --- /dev/null
> +++ b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_ethtool.c
> @@ -0,0 +1,543 @@
> +/*
> + * Copyright (c) 2016~2017 Hisilicon Limited.
> + *
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License as published by
> + * the Free Software Foundation; either version 2 of the License, or
> + * (at your option) any later version.
> + */
> +
> +#include <linux/etherdevice.h>
> +#include "hns3_enet.h"
> +
> +struct hns3_stats {
> +	char stats_string[ETH_GSTRING_LEN];
> +	int stats_size;
> +	int stats_offset;
> +};
> +
> +/* netdev related stats */
> +#define HNS3_NETDEV_STAT(_string, _member)			\
> +	{ _string,						\
> +	  FIELD_SIZEOF(struct rtnl_link_stats64, _member),	\
> +	  offsetof(struct rtnl_link_stats64, _member),		\
> +	}

Can you make this macro use named initializers?

> +
> +static const struct hns3_stats hns3_netdev_stats[] = {
> +	/* misc. Rx/Tx statistics */
> +	HNS3_NETDEV_STAT("rx_packets", rx_packets),
> +	HNS3_NETDEV_STAT("tx_packets", tx_packets),
> +	HNS3_NETDEV_STAT("rx_bytes", rx_bytes),
> +	HNS3_NETDEV_STAT("tx_bytes", tx_bytes),
> +	HNS3_NETDEV_STAT("rx_errors", rx_errors),
> +	HNS3_NETDEV_STAT("tx_errors", tx_errors),
> +	HNS3_NETDEV_STAT("rx_dropped", rx_dropped),
> +	HNS3_NETDEV_STAT("tx_dropped", tx_dropped),
> +	HNS3_NETDEV_STAT("multicast", multicast),
> +	HNS3_NETDEV_STAT("collisions", collisions),
> +
> +	/* detailed Rx errors */
> +	HNS3_NETDEV_STAT("rx_length_errors", rx_length_errors),
> +	HNS3_NETDEV_STAT("rx_over_errors", rx_over_errors),
> +	HNS3_NETDEV_STAT("rx_crc_errors", rx_crc_errors),
> +	HNS3_NETDEV_STAT("rx_frame_errors", rx_frame_errors),
> +	HNS3_NETDEV_STAT("rx_fifo_errors", rx_fifo_errors),
> +	HNS3_NETDEV_STAT("rx_missed_errors", rx_missed_errors),
> +
> +	/* detailed Tx errors */
> +	HNS3_NETDEV_STAT("tx_aborted_errors", tx_aborted_errors),
> +	HNS3_NETDEV_STAT("tx_carrier_errors", tx_carrier_errors),
> +	HNS3_NETDEV_STAT("tx_fifo_errors", tx_fifo_errors),
> +	HNS3_NETDEV_STAT("tx_heartbeat_errors", tx_heartbeat_errors),
> +	HNS3_NETDEV_STAT("tx_window_errors", tx_window_errors),
> +
> +	/* for cslip etc */
> +	HNS3_NETDEV_STAT("rx_compressed", rx_compressed),
> +	HNS3_NETDEV_STAT("tx_compressed", tx_compressed),
> +};
> +
> +#define HNS3_NETDEV_STATS_COUNT ARRAY_SIZE(hns3_netdev_stats)
> +
> +/* tqp related stats */
> +#define HNS3_TQP_STAT(_string, _member)				\
> +	{ _string,						\
> +	  FIELD_SIZEOF(struct ring_stats, _member),		\
> +	  offsetof(struct hns3_enet_ring, stats),	\
> +	}
> +

Same here.

> +static const struct hns3_stats hns3_txq_stats[] = {
> +	/* Tx per-queue statistics */
> +	HNS3_TQP_STAT("tx_io_err_cnt", io_err_cnt),
> +	HNS3_TQP_STAT("tx_sw_err_cnt", sw_err_cnt),
> +	HNS3_TQP_STAT("tx_seg_pkt_cnt", seg_pkt_cnt),
> +	HNS3_TQP_STAT("tx_pkts", tx_pkts),
> +	HNS3_TQP_STAT("tx_bytes", tx_bytes),
> +	HNS3_TQP_STAT("tx_err_cnt", tx_err_cnt),
> +	HNS3_TQP_STAT("tx_restart_queue", restart_queue),
> +	HNS3_TQP_STAT("tx_busy", tx_busy),
> +};
> +
> +#define HNS3_TXQ_STATS_COUNT ARRAY_SIZE(hns3_txq_stats)
> +
> +static const struct hns3_stats hns3_rxq_stats[] = {
> +	/* Rx per-queue statistics */
> +	HNS3_TQP_STAT("rx_io_err_cnt", io_err_cnt),
> +	HNS3_TQP_STAT("rx_sw_err_cnt", sw_err_cnt),
> +	HNS3_TQP_STAT("rx_seg_pkt_cnt", seg_pkt_cnt),
> +	HNS3_TQP_STAT("rx_pkts", rx_pkts),
> +	HNS3_TQP_STAT("rx_bytes", rx_bytes),
> +	HNS3_TQP_STAT("rx_err_cnt", rx_err_cnt),
> +	HNS3_TQP_STAT("rx_reuse_pg_cnt", reuse_pg_cnt),
> +	HNS3_TQP_STAT("rx_err_pkt_len", err_pkt_len),
> +	HNS3_TQP_STAT("rx_non_vld_descs", non_vld_descs),
> +	HNS3_TQP_STAT("rx_err_bd_num", err_bd_num),
> +	HNS3_TQP_STAT("rx_l2_err", l2_err),
> +	HNS3_TQP_STAT("rx_l3l4_csum_err", l3l4_csum_err),
> +};
> +
> +#define HNS3_RXQ_STATS_COUNT ARRAY_SIZE(hns3_rxq_stats)
> +
> +#define HNS3_TQP_STATS_COUNT (HNS3_TXQ_STATS_COUNT + HNS3_RXQ_STATS_COUNT)
> +
> +struct hns3_link_mode_mapping {
> +	u32 hns3_link_mode;
> +	u32 ethtool_link_mode;
> +};
> +
> +static const struct hns3_link_mode_mapping hns3_lm_map[] = {
> +	{HNS3_LM_FIBRE_BIT, ETHTOOL_LINK_MODE_FIBRE_BIT},
> +	{HNS3_LM_AUTONEG_BIT, ETHTOOL_LINK_MODE_Autoneg_BIT},
> +	{HNS3_LM_TP_BIT, ETHTOOL_LINK_MODE_TP_BIT},
> +	{HNS3_LM_PAUSE_BIT, ETHTOOL_LINK_MODE_Pause_BIT},
> +	{HNS3_LM_BACKPLANE_BIT, ETHTOOL_LINK_MODE_Backplane_BIT},
> +	{HNS3_LM_10BASET_HALF_BIT, ETHTOOL_LINK_MODE_10baseT_Half_BIT},
> +	{HNS3_LM_10BASET_FULL_BIT, ETHTOOL_LINK_MODE_10baseT_Full_BIT},
> +	{HNS3_LM_100BASET_HALF_BIT, ETHTOOL_LINK_MODE_100baseT_Half_BIT},
> +	{HNS3_LM_100BASET_FULL_BIT, ETHTOOL_LINK_MODE_100baseT_Full_BIT},
> +	{HNS3_LM_1000BASET_FULL_BIT, ETHTOOL_LINK_MODE_1000baseT_Full_BIT},
> +};
> +
> +#define HNS3_DRV_TO_ETHTOOL_CAPS(caps, lk_ksettings, name)	\
> +{								\
> +	int i;							\
> +								\
> +	for (i = 0; i < ARRAY_SIZE(hns3_lm_map); i++) {		\
> +		if ((caps) & hns3_lm_map[i].hns3_link_mode)	\
> +			__set_bit(hns3_lm_map[i].ethtool_link_mode,\
> +				  (lk_ksettings)->link_modes.name); \
> +	}							\
> +}

How about making this an inline function such that you would get proper
type checking?

> +
> +static int hns3_get_sset_count(struct net_device *netdev, int stringset)
> +{
> +	struct hns3_nic_priv *priv = netdev_priv(netdev);
> +	struct hnae3_handle *h = priv->ae_handle;
> +	const struct hnae3_ae_ops *ops = h->ae_algo->ops;
> +
> +	if (!ops->get_sset_count) {
> +		netdev_err(netdev, "could not get string set count\n");
> +		return -EOPNOTSUPP;
> +	}

Is it really worth the error message? This might be called several times
during the driver's lifecycle.

> +
> +	switch (stringset) {
> +	case ETH_SS_STATS:
> +		return (HNS3_NETDEV_STATS_COUNT +
> +			(HNS3_TQP_STATS_COUNT * h->kinfo.num_tqps) +
> +			ops->get_sset_count(h, stringset));
> +
> +	case ETH_SS_TEST:
> +		return ops->get_sset_count(h, stringset);
> +	}
> +
> +	return 0;
> +}
> +
> +static u8 *hns3_get_strings_netdev(u8 *data)
> +{
> +	int i;

unsigned int i.

> +
> +	for (i = 0; i < HNS3_NETDEV_STATS_COUNT; i++) {
> +		memcpy(data, hns3_netdev_stats[i].stats_string,
> +		       ETH_GSTRING_LEN);
> +		data += ETH_GSTRING_LEN;
> +	}
> +
> +	return data;
> +}
> +
> +static u8 *hns3_get_strings_tqps(struct hnae3_handle *handle, u8 *data)
> +{
> +	struct hnae3_knic_private_info *kinfo = &handle->kinfo;
> +	int i, j;

Likewise, unsigned int i, j.

> +
> +	/* get strings for Tx */
> +	for (i = 0; i < kinfo->num_tqps; i++) {
> +		for (j = 0; j < HNS3_TXQ_STATS_COUNT; j++) {
> +			u8 gstr[ETH_GSTRING_LEN];

char gstr[ETH_GSTRING_LEN] and you can move it out of the loop since it
is just a temporary buffer for both loops here.

> +
> +			sprintf(gstr, "rcb_q%d_", i);

snprintf() just to be on the safe side.

> +			strcat(gstr, hns3_txq_stats[j].stats_string);
> +
> +			memcpy(data, gstr, ETH_GSTRING_LEN);

What ensures that you are NULL terminating this string?

> +			data += ETH_GSTRING_LEN;
> +		}
> +	}
> +
> +	/* get strings for Rx */
> +	for (i = 0; i < kinfo->num_tqps; i++) {
> +		for (j = 0; j < HNS3_RXQ_STATS_COUNT; j++) {
> +			u8 gstr[ETH_GSTRING_LEN];
> +
> +			sprintf(gstr, "rcb_q%d_", i);
> +			strcat(gstr, hns3_rxq_stats[j].stats_string);
> +
> +			memcpy(data, gstr, ETH_GSTRING_LEN);
> +			data += ETH_GSTRING_LEN;
> +		}
> +	}
> +
> +	return data;
> +}
> +
> +static void hns3_get_strings(struct net_device *netdev, u32 stringset, u8 *data)
> +{
> +	struct hns3_nic_priv *priv = netdev_priv(netdev);
> +	struct hnae3_handle *h = priv->ae_handle;
> +	const struct hnae3_ae_ops *ops = h->ae_algo->ops;
> +	char *buff = (char *)data;
> +
> +	if (!ops->get_strings) {
> +		netdev_err(netdev, "could not get strings!\n");
> +		return;
> +	}

Same here, does not sound like something you would want to print more
than once?

> +
> +	switch (stringset) {
> +	case ETH_SS_STATS:
> +		buff = hns3_get_strings_netdev(buff);
> +		buff = hns3_get_strings_tqps(h, buff);
> +		h->ae_algo->ops->get_strings(h, stringset, (u8 *)buff);
> +		break;
> +	case ETH_SS_TEST:
> +		ops->get_strings(h, stringset, data);
> +		break;
> +	}
> +}
> +
> +static u64 *hns3_get_stats_netdev(struct net_device *netdev, u64 *data)
> +{

You should implement the 64-bit version of this.

> +	const struct rtnl_link_stats64 *net_stats;
> +	struct rtnl_link_stats64 temp;
> +	u8 *stat;
> +	int i;

unsigned int i

> +
> +	net_stats = dev_get_stats(netdev, &temp);
> +
> +	for (i = 0; i < HNS3_NETDEV_STATS_COUNT; i++) {
> +		stat = (u8 *)net_stats + hns3_netdev_stats[i].stats_offset;
> +		*data++ = *(u64 *)stat;
> +	}
> +
> +	return data;
> +}
> +
> +static u64 *hns3_get_stats_tqps(struct hnae3_handle *handle, u64 *data)
> +{
> +	struct hns3_nic_priv *nic_priv = (struct hns3_nic_priv *)handle->priv;
> +	struct hnae3_knic_private_info *kinfo = &handle->kinfo;
> +	struct hns3_enet_ring *ring;
> +	u8 *stat;
> +	int i;

Same here.

> +
> +	/* get stats for Tx */
> +	for (i = 0; i < kinfo->num_tqps; i++) {
> +		ring = nic_priv->ring_data[i].ring;
> +		for (i = 0; i < HNS3_TXQ_STATS_COUNT; i++) {
> +			stat = (u8 *)ring + hns3_txq_stats[i].stats_offset;
> +			*data++ = *(u64 *)stat;
> +		}
> +	}
> +
> +	/* get stats for Rx */
> +	for (i = 0; i < kinfo->num_tqps; i++) {
> +		ring = nic_priv->ring_data[i + kinfo->num_tqps].ring;
> +		for (i = 0; i < HNS3_RXQ_STATS_COUNT; i++) {
> +			stat = (u8 *)ring + hns3_rxq_stats[i].stats_offset;
> +			*data++ = *(u64 *)stat;
> +		}
> +	}
> +
> +	return data;
> +}
> +
> +/* hns3_get_stats - get detail statistics.
> + * @netdev: net device
> + * @stats: statistics info.
> + * @data: statistics data.
> + */
> +void hns3_get_stats(struct net_device *netdev, struct ethtool_stats *stats,
> +		    u64 *data)
> +{
> +	struct hns3_nic_priv *priv = netdev_priv(netdev);
> +	struct hnae3_handle *h = priv->ae_handle;
> +	u64 *p = data;
> +
> +	if (!h->ae_algo->ops->get_stats || !h->ae_algo->ops->update_stats) {
> +		netdev_err(netdev, "could not get any statistics\n");
> +		return;
> +	}
> +
> +	h->ae_algo->ops->update_stats(h, &netdev->stats);
> +
> +	/* get netdev related stats */
> +	p = hns3_get_stats_netdev(netdev, p);
> +
> +	/* get per-queue stats */
> +	p = hns3_get_stats_tqps(h, p);
> +
> +	/* get MAC & other misc hardware stats */
> +	h->ae_algo->ops->get_stats(h, p);
> +}
> +
> +static void hns3_get_drvinfo(struct net_device *netdev,
> +			     struct ethtool_drvinfo *drvinfo)
> +{
> +	struct hns3_nic_priv *priv = netdev_priv(netdev);
> +	struct hnae3_handle *h = priv->ae_handle;
> +
> +	strncpy(drvinfo->version, HNAE_DRIVER_VERSION,
> +		sizeof(drvinfo->version));
> +	drvinfo->version[sizeof(drvinfo->version) - 1] = '\0';

strlcpy() would probably do that for you.

> +
> +	strncpy(drvinfo->driver, HNAE_DRIVER_NAME, sizeof(drvinfo->driver));
> +	drvinfo->driver[sizeof(drvinfo->driver) - 1] = '\0';

Same here

> +
> +	strncpy(drvinfo->bus_info, priv->dev->bus->name,
> +		sizeof(drvinfo->bus_info));> +	drvinfo->bus_info[ETHTOOL_BUSINFO_LEN - 1] = '\0';

And here.

The rest looked fine.
-- 
Florian
