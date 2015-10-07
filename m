From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH RFC] net: mvneta: add ethtool statistics
Date: Thu, 8 Oct 2015 01:03:33 +0200
Message-ID: <20151007230333.GL17952@lunn.ch>
References: <20151006165208.GE3557@lunn.ch>
 <E1ZjZ2q-00087d-Im@rmk-PC.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	netdev@vger.kernel.org
To: Russell King <rmk+kernel@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:40810 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750778AbbJGXDg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Oct 2015 19:03:36 -0400
Content-Disposition: inline
In-Reply-To: <E1ZjZ2q-00087d-Im@rmk-PC.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 06, 2015 at 09:41:08PM +0100, Russell King wrote:
> Add support for the ethtool statistic interface, returning the full set
> of statistics which both Armada 370 and Armada XP can support.
> 
> Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
> ---
> Andrew,
> 
> Here's the patch updated to use the example set by mv643xx_eth.c.

Hi Russell

I did some quick tests on an Armada XP based DLINK WRT1900AC. We have
some inconsistencies:

root@wrt1900ac:~# ethtool -S eth0
NIC statistics:
     good_octets_received: 4300691
     good_frames_received: 7655
     bad_octets_received: 0
     bad_frames_received: 0
     broadcast_frames_received: 0
     multicast_frames_received: 0
     unrec_mac_control_received: 0
     good_fc_received: 0
     bad_fc_received: 0
     undersize_received: 0
     fragments_received: 0
     oversize_received: 0
     jabber_received: 0
     mac_receive_error: 0
     bad_crc_event: 0
     collision: 0
     late_collision: 0
     rx_discard: 0
     rx_overrun: 0
     frames_64_octets: 2
     frames_65_to_127_octets: 9
     frames_128_to_255_octets: 1
     frames_256_to_511_octets: 0
     frames_512_to_1023_octets: 7652
     frames_1024_to_max_octets: 0
     good_octets_sent: 383562
     good_frames_sent: 7665
     excessive_collision: 0
     multicast_frames_sent: 8
     broadcast_frames_sent: 3
     fc_sent: 0
     internal_mac_transmit_err: 0
root@wrt1900ac:~# ifconfig eth0
eth0      Link encap:Ethernet  HWaddr 94:10:3e:80:bc:f3  
          inet6 addr: fe80::9610:3eff:fe80:bcf3/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:2 errors:0 dropped:0 overruns:0 frame:0
          TX packets:8 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:532 
          RX bytes:497 (497.0 B)  TX bytes:648 (648.0 B)
          Interrupt:27

I'm guessing ethtool is including the uboot TFTP packets, where as
ifconfig is just Linux? This would suggest the driver is not clearing
the statistics when it loads. Should it?

Apart from that, i pinged with a few different sizes and the right
frame size counter went up. I broadcast pinged and the broadcast
counter went up. So not exhaustive testing, but better than nothing.
Since clearing the statistics is a separate issue:

Tested-by: Andrew Lunn <andrew@lunn.ch>

Thanks
	Andrew

> 
>  drivers/net/ethernet/marvell/mvneta.c | 99 +++++++++++++++++++++++++++++++++++
>  1 file changed, 99 insertions(+)
> 
> diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
> index 514df76fc70f..9f048ba92d0e 100644
> --- a/drivers/net/ethernet/marvell/mvneta.c
> +++ b/drivers/net/ethernet/marvell/mvneta.c
> @@ -277,6 +277,50 @@
>  
>  #define MVNETA_RX_BUF_SIZE(pkt_size)   ((pkt_size) + NET_SKB_PAD)
>  
> +struct mvneta_statistic {
> +	unsigned short offset;
> +	unsigned short type;
> +	const char name[ETH_GSTRING_LEN];
> +};
> +
> +#define T_REG_32	32
> +#define T_REG_64	64
> +
> +static const struct mvneta_statistic mvneta_statistics[] = {
> +	{ 0x3000, T_REG_64, "good_octets_received", },
> +	{ 0x3010, T_REG_32, "good_frames_received", },
> +	{ 0x3008, T_REG_32, "bad_octets_received", },
> +	{ 0x3014, T_REG_32, "bad_frames_received", },
> +	{ 0x3018, T_REG_32, "broadcast_frames_received", },
> +	{ 0x301c, T_REG_32, "multicast_frames_received", },
> +	{ 0x3050, T_REG_32, "unrec_mac_control_received", },
> +	{ 0x3058, T_REG_32, "good_fc_received", },
> +	{ 0x305c, T_REG_32, "bad_fc_received", },
> +	{ 0x3060, T_REG_32, "undersize_received", },
> +	{ 0x3064, T_REG_32, "fragments_received", },
> +	{ 0x3068, T_REG_32, "oversize_received", },
> +	{ 0x306c, T_REG_32, "jabber_received", },
> +	{ 0x3070, T_REG_32, "mac_receive_error", },
> +	{ 0x3074, T_REG_32, "bad_crc_event", },
> +	{ 0x3078, T_REG_32, "collision", },
> +	{ 0x307c, T_REG_32, "late_collision", },
> +	{ 0x2484, T_REG_32, "rx_discard", },
> +	{ 0x2488, T_REG_32, "rx_overrun", },
> +	{ 0x3020, T_REG_32, "frames_64_octets", },
> +	{ 0x3024, T_REG_32, "frames_65_to_127_octets", },
> +	{ 0x3028, T_REG_32, "frames_128_to_255_octets", },
> +	{ 0x302c, T_REG_32, "frames_256_to_511_octets", },
> +	{ 0x3030, T_REG_32, "frames_512_to_1023_octets", },
> +	{ 0x3034, T_REG_32, "frames_1024_to_max_octets", },
> +	{ 0x3038, T_REG_64, "good_octets_sent", },
> +	{ 0x3040, T_REG_32, "good_frames_sent", },
> +	{ 0x3044, T_REG_32, "excessive_collision", },
> +	{ 0x3048, T_REG_32, "multicast_frames_sent", },
> +	{ 0x304c, T_REG_32, "broadcast_frames_sent", },
> +	{ 0x3054, T_REG_32, "fc_sent", },
> +	{ 0x300c, T_REG_32, "internal_mac_transmit_err", },
> +};
> +
>  struct mvneta_pcpu_stats {
>  	struct	u64_stats_sync syncp;
>  	u64	rx_packets;
> @@ -312,6 +356,8 @@ struct mvneta_port {
>  	unsigned int speed;
>  	unsigned int tx_csum_limit;
>  	int use_inband_status:1;
> +
> +	u64 ethtool_stats[ARRAY_SIZE(mvneta_statistics)];
>  };
>  
>  /* The mvneta_tx_desc and mvneta_rx_desc structures describe the
> @@ -2875,6 +2921,56 @@ static int mvneta_ethtool_set_ringparam(struct net_device *dev,
>  	return 0;
>  }
>  
> +static void mvneta_ethtool_get_strings(struct net_device *netdev, u32 sset,
> +				       u8 *data)
> +{
> +	if (sset == ETH_SS_STATS) {
> +		int i;
> +
> +		for (i = 0; i < ARRAY_SIZE(mvneta_statistics); i++)
> +			memcpy(data + i * ETH_GSTRING_LEN,
> +			       mvneta_statistics[i].name, ETH_GSTRING_LEN);
> +	}
> +}
> +
> +static void mvneta_ethtool_get_stats(struct net_device *dev,
> +				     struct ethtool_stats *stats, u64 *data)
> +{
> +	struct mvneta_port *pp = netdev_priv(dev);
> +	const struct mvneta_statistic *s;
> +	void __iomem *base = pp->base;
> +	u32 high, low, val;
> +	int i;
> +
> +	for (i = 0, s = mvneta_statistics;
> +	     s < mvneta_statistics + ARRAY_SIZE(mvneta_statistics);
> +	     s++, i++) {
> +		val = 0;
> +
> +		switch (s->type) {
> +		case T_REG_32:
> +			val = readl_relaxed(base + s->offset);
> +			break;
> +		case T_REG_64:
> +			/* Docs say to read low 32-bit then high */
> +			low = readl_relaxed(base + s->offset);
> +			high = readl_relaxed(base + s->offset + 4);
> +			val = (u64)high << 32 | low;
> +			break;
> +		}
> +
> +		pp->ethtool_stats[i] += val;
> +		*data++ = pp->ethtool_stats[i];
> +	}
> +}
> +
> +static int mvneta_ethtool_get_sset_count(struct net_device *dev, int sset)
> +{
> +	if (sset == ETH_SS_STATS)
> +		return ARRAY_SIZE(mvneta_statistics);
> +	return -EOPNOTSUPP;
> +}
> +
>  static const struct net_device_ops mvneta_netdev_ops = {
>  	.ndo_open            = mvneta_open,
>  	.ndo_stop            = mvneta_stop,
> @@ -2896,6 +2992,9 @@ const struct ethtool_ops mvneta_eth_tool_ops = {
>  	.get_drvinfo    = mvneta_ethtool_get_drvinfo,
>  	.get_ringparam  = mvneta_ethtool_get_ringparam,
>  	.set_ringparam	= mvneta_ethtool_set_ringparam,
> +	.get_strings	= mvneta_ethtool_get_strings,
> +	.get_ethtool_stats = mvneta_ethtool_get_stats,
> +	.get_sset_count	= mvneta_ethtool_get_sset_count,
>  };
>  
>  /* Initialize hw */
> -- 
> 2.1.0
> 
