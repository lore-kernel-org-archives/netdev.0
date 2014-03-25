From: Vipul Pandya <vipul.pandya@samsung.com>
Subject: Re: [PATCH V12 6/7] net: sxgbe: add ethtool related functions support
Date: Tue, 25 Mar 2014 14:13:37 +0530
Message-ID: <1395737017-16975-1-git-send-email-vipul.pandya@samsung.com>
Cc: bh74.an@samsung.com, netdev@vger.kernel.org,
	linux-samsung-soc@vger.kernel.org, devicetree@vger.kernel.org,
	davem@davemloft.net, ks.giri@samsung.com, siva.kallam@samsung.com,
	ilho215.lee@samsung.com
To: ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout2.samsung.com ([203.254.224.25]:31506 "EHLO
	mailout2.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753863AbaCYInJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2014 04:43:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vipul Pandya <vipul.pandya@samsung.com>

-- 
> Sorry I didn't look over this earlier.
>
> On Sat, 2014-03-22 at 21:04 -0700, Byungho An wrote:
> [...]
> > --- a/drivers/net/ethernet/samsung/sxgbe/sxgbe_common.h
> > +++ b/drivers/net/ethernet/samsung/sxgbe/sxgbe_common.h
> > @@ -42,8 +42,12 @@ struct sxgbe_mtl_ops;
> >  #define SXGBE_RX_QUEUES   16
> >  
> >  /* Max/Min RI Watchdog Timer count value */
> > -#define SXGBE_MAX_DMA_RIWT	0xff
> > -#define SXGBE_MIN_DMA_RIWT	0x20
> > +/* Calculated based how much time does it take to fill 256KB Rx memory
> > + * at 10Gb speed at 156MHz clock rate and considered little less then
> > + * the actual value.
> > + */
> > +#define SXGBE_MAX_DMA_RIWT	0x70
> > +#define SXGBE_MIN_DMA_RIWT	0x01
>
> This change should be folded into patch 2/7.
Ok.

> [...]
> > --- a/drivers/net/ethernet/samsung/sxgbe/sxgbe_ethtool.c
> > +++ b/drivers/net/ethernet/samsung/sxgbe/sxgbe_ethtool.c
> [...]
> > -static int sxgbe_ethtool_get_eee(struct net_device *dev,
> > -				 struct ethtool_eee *edata)
> > +static int sxgbe_get_eee(struct net_device *dev,
> > +			 struct ethtool_eee *edata)
> >  {
> >  	struct sxgbe_priv_data *priv = netdev_priv(dev);
> >  
> > @@ -55,8 +150,8 @@ static int sxgbe_ethtool_get_eee(struct net_device *dev,
> >  	return phy_ethtool_get_eee(priv->phydev, edata);
> >  }
> >  
> > -static int sxgbe_ethtool_set_eee(struct net_device *dev,
> > -				 struct ethtool_eee *edata)
> > +static int sxgbe_set_eee(struct net_device *dev,
> > +			 struct ethtool_eee *edata)
> >  {
> >  	struct sxgbe_priv_data *priv = netdev_priv(dev);
> >  
>
> These name changes should be folded into patch 2/7.
Ok.

> [...]
> > +static int sxgbe_getsettings(struct net_device *dev,
> > +			     struct ethtool_cmd *cmd)
> > +{
> > +	struct sxgbe_priv_data *priv = netdev_priv(dev);
> > +
> > +	if (priv->phydev)
> > +		return phy_ethtool_gset(priv->phydev, cmd);
> > +
> > +	return -ENODEV;
> > +}
> > +
> > +static int sxgbe_setsettings(struct net_device *dev, struct ethtool_cmd *cmd)
> > +{
> > +	struct sxgbe_priv_data *priv = netdev_priv(dev);
> > +
> > +	if (priv->phydev)
> > +		return phy_ethtool_sset(priv->phydev, cmd);
> > +
> > +	return -ENODEV;
> > +}
>
> I think these two operations should return -EOPNOTSUPP if there is no
> PHY.
Ok.

> [...]
> > +static int sxgbe_get_ts_info(struct net_device *dev,
> > +			     struct ethtool_ts_info *info)
> > +{
> > +	struct sxgbe_priv_data *priv = netdev_priv(dev);
> > +
> > +	if (!priv->hw_cap.atime_stamp)
> > +		return ethtool_op_get_ts_info(dev, info);
> > +
> > +	info->so_timestamping = (SOF_TIMESTAMPING_TX_SOFTWARE |
> > +				 SOF_TIMESTAMPING_RX_SOFTWARE |
> > +				 SOF_TIMESTAMPING_SOFTWARE |
> > +				 SOF_TIMESTAMPING_TX_HARDWARE |
> > +				 SOF_TIMESTAMPING_RX_HARDWARE |
> > +				 SOF_TIMESTAMPING_RAW_HARDWARE);
> > +
> > +	if (priv->ptp_clock)
> > +		info->phc_index = ptp_clock_index(priv->ptp_clock);
>
> priv->ptp_clock doesn't appear to be set anywhere; nor does the driver
> implement SIOCSHWTSTAMP.  So this function should not advertise any
> hardware timestamping features yet.
We already have in our plan to implement above things. However we will remove
this feature from this submission. We will submit this later along with other
required implementations.

> > +	info->tx_types = ((1 << HWTSTAMP_TX_OFF) |
> > +			  (1 << HWTSTAMP_TX_ON) |
> > +			  (1 << HWTSTAMP_TX_ONESTEP_SYNC));
> > +
> > +	info->rx_filters = ((1 << HWTSTAMP_FILTER_NONE) |
> > +			    (1 << HWTSTAMP_FILTER_PTP_V1_L4_EVENT) |
> > +			    (1 << HWTSTAMP_FILTER_PTP_V1_L4_SYNC) |
> > +			    (1 << HWTSTAMP_FILTER_PTP_V1_L4_DELAY_REQ) |
> > +			    (1 << HWTSTAMP_FILTER_PTP_V2_L4_EVENT) |
> > +			    (1 << HWTSTAMP_FILTER_PTP_V2_L4_SYNC) |
> > +			    (1 << HWTSTAMP_FILTER_PTP_V2_L4_DELAY_REQ) |
> > +			    (1 << HWTSTAMP_FILTER_PTP_V2_L2_EVENT) |
> > +			    (1 << HWTSTAMP_FILTER_PTP_V2_L2_SYNC) |
> > +			    (1 << HWTSTAMP_FILTER_PTP_V2_L2_DELAY_REQ) |
> > +			    (1 << HWTSTAMP_FILTER_PTP_V2_EVENT) |
> > +			    (1 << HWTSTAMP_FILTER_PTP_V2_SYNC) |
> > +			    (1 << HWTSTAMP_FILTER_PTP_V2_DELAY_REQ) |
> > +			    (1 << HWTSTAMP_FILTER_ALL));
> > +	return 0;
> > +}
> > +
> > +int sxgbe_set_flow_ctrl(struct sxgbe_priv_data *priv, int rx, int tx)
> > +{
> > +	return 0;
> > +}
> > +
> > +static void sxgbe_get_pauseparam(struct net_device *netdev,
> > +				 struct ethtool_pauseparam *pause)
> > +{
> > +	struct sxgbe_priv_data *priv = netdev_priv(netdev);
> > +
> > +	pause->rx_pause = priv->rx_pause;
> > +	pause->tx_pause = priv->tx_pause;
> > +}
> > +
> > +static int sxgbe_set_pauseparam(struct net_device *netdev,
> > +				struct ethtool_pauseparam *pause)
> > +{
> > +	struct sxgbe_priv_data *priv = netdev_priv(netdev);
> > +
> > +	if (pause->autoneg)
> > +		return -EINVAL;
> > +
> > +	return sxgbe_set_flow_ctrl(priv, pause->rx_pause, pause->tx_pause);
>
> But sxgbe_set_flow_ctrl() is empty, so this isn't a proper
> implementation.
We already have in our plan to implement sxgbe_set_flow_ctrl. However we will
remove this feature from this submission. We will submit this later along with
other required implementations.

> > +}
> [...]
> > +static int sxgbe_get_sset_count(struct net_device *netdev, int sset)
> > +{
> > +	int len;
> > +
> > +	switch (sset) {
> > +	case ETH_SS_STATS:
> > +		len = SXGBE_STATS_LEN;
> > +		return len;
> > +	default:
> > +		return -EOPNOTSUPP;
>
> You implement the operation, just not this particular argument value.
> So return -EINVAL.
Ok.

> > +	}
> > +}
> > +
> > +static void sxgbe_get_ethtool_stats(struct net_device *dev,
> > +				    struct ethtool_stats *dummy, u64 *data)
> > +{
> > +	struct sxgbe_priv_data *priv = netdev_priv(dev);
> > +	int i, j = 0;
> > +	char *p;
> > +
> > +	if (priv->eee_enabled) {
> > +		int val = phy_get_eee_err(priv->phydev);
> > +
> > +		if (val)
> > +			priv->xstats.eee_wakeup_error_n = val;
> > +	}
> > +
> > +	for (i = 0; i < SXGBE_STATS_LEN; i++) {
> > +		p = (char *)priv + sxgbe_gstrings_stats[i].stat_offset;
> > +		data[j++] = (sxgbe_gstrings_stats[i].sizeof_stat == sizeof(u64))
> > +			? (*(u64 *)p) : (*(u32 *)p);
> > +	}
> > +}
>
> It looks like you will always use the same value of i and j in each
> pass, so you don't need two separate variables.
Ok.

> [...]
> > +static int sxgbe_get_coalesce(struct net_device *dev,
> > +                             struct ethtool_coalesce *ec)
> > +{
> > +       struct sxgbe_priv_data *priv = netdev_priv(dev);
> > +
> > +       if (priv->use_riwt)
> > +               ec->rx_coalesce_usecs = sxgbe_riwt2usec(priv->rx_riwt, priv);
>
> Also set:
>
>	ec->rx_max_coalesced_frames = !priv->use_riwt;
>	ec->tx_coalesce_usecs = SXGBE_COAL_TX_TIMER;
>	ec->tx_max_coalesced_frames = SXGBE_TX_FRAMES;
Support for above additional parameters do not present in the hardware
controller. So, they are not set.

> > +       return 0;
> > +}
> > +
> > +static int sxgbe_set_coalesce(struct net_device *dev,
> > +			      struct ethtool_coalesce *ec)
> > +{
> > +	struct sxgbe_priv_data *priv = netdev_priv(dev);
> > +	unsigned int rx_riwt;
> > +
> > +	rx_riwt = sxgbe_usec2riwt(ec->rx_coalesce_usecs, priv);
> > +
> > +	if ((rx_riwt > SXGBE_MAX_DMA_RIWT) || (rx_riwt < SXGBE_MIN_DMA_RIWT))
> > +		return -EINVAL;
> > +	else if (!priv->use_riwt)
> > +		return -EOPNOTSUPP;
>
> Please check for attempts to change unsupported parameters:
>
>	if (ec->rx_max_coalesced_frames != !rx_riwt ||
>	    ec->tx_coalesce_usecs != SXGBE_COAL_TX_TIMER ||
>	    ec->tx_max_coalesced_frames != SXGBE_TX_FRAMES ||
>	    ec->use_adaptive_rx_coalesce ||
>	    ec->use_adaptive_tx_coalesce)
>		return -EINVAL;
There is only one supported parameter so I would rather check if the same is set
or not as shown below:

if (!ec->rx_coalesce_usecs)
	return -EINVAL;

> > +	priv->rx_riwt = rx_riwt;
> > +	priv->hw->dma->rx_watchdog(priv->ioaddr, priv->rx_riwt);
> > +
> > +	return 0;
> > +}
> [...]
> > +static int sxgbe_set_rss_hash_opt(struct sxgbe_priv_data *priv,
> > +				  struct ethtool_rxnfc *cmd)
> > +{
> > +	u32 reg_val = 0;
> > +
> > +	/* RSS does not support anything other than hashing
> > +	 * to queues on src and dst IPs and ports
> > +	 */
> > +	if (cmd->data & ~(RXH_IP_SRC | RXH_IP_DST |
> > +			  RXH_L4_B_0_1 | RXH_L4_B_2_3))
> > +		return -EINVAL;
> > +
> > +	switch (cmd->flow_type) {
> > +	case TCP_V4_FLOW:
> > +	case TCP_V6_FLOW:
> > +		if (!(cmd->data & RXH_IP_SRC) ||
> > +		    !(cmd->data & RXH_IP_DST) ||
> > +		    !(cmd->data & RXH_L4_B_0_1) ||
> > +		    !(cmd->data & RXH_L4_B_2_3))
> > +			return -EINVAL;
> > +		reg_val = SXGBE_CORE_RSS_CTL_TCP4TE;
> > +		break;
> > +	case UDP_V4_FLOW:
> > +	case UDP_V6_FLOW:
> > +		if (!(cmd->data & RXH_IP_SRC) ||
> > +		    !(cmd->data & RXH_IP_DST) ||
> > +		    !(cmd->data & RXH_L4_B_0_1) ||
> > +		    !(cmd->data & RXH_L4_B_2_3))
> > +			return -EINVAL;
> > +		reg_val = SXGBE_CORE_RSS_CTL_UDP4TE;
> > +		break;
> > +	case SCTP_V4_FLOW:
> > +	case AH_ESP_V4_FLOW:
> > +	case AH_V4_FLOW:
> > +	case ESP_V4_FLOW:
> > +	case AH_ESP_V6_FLOW:
> > +	case AH_V6_FLOW:
> > +	case ESP_V6_FLOW:
> > +	case SCTP_V6_FLOW:
> > +	case IPV4_FLOW:
> > +	case IPV6_FLOW:
> > +		if (!(cmd->data & RXH_IP_SRC) ||
> > +		    !(cmd->data & RXH_IP_DST) ||
> > +		    (cmd->data & RXH_L4_B_0_1) ||
> > +		    (cmd->data & RXH_L4_B_2_3))
> > +			return -EINVAL;
> > +		reg_val = SXGBE_CORE_RSS_CTL_IP2TE;
> > +		break;
> > +	default:
> > +		return -EINVAL;
> > +	}
>
> Unless I'm missing something, this only accepts the default values, so
> it's not actually possible to change the configuration.  Why are you
> implementing this operation at all?
It is possible to change the configuration. There is a register write to the
SXGBE_CORE_RSS_CTL_REG at the end of the function. I think you might have missed
it.

> [...]
> > +static void sxgbe_get_regs(struct net_device *dev,
> > +			   struct ethtool_regs *regs, void *space)
> > +{
> > +	struct sxgbe_priv_data *priv = netdev_priv(dev);
> > +	u32 *reg_space = (u32 *)space;
> > +	int reg_offset;
> > +	int reg_ix = 0;
> > +	void __iomem *ioaddr = priv->ioaddr;
> > +
> > +	memset(reg_space, 0x0, REG_SPACE_SIZE);
> > +
> > +	/* MAC registers */
> > +	for (reg_offset = START_MAC_REG_OFFSET;
> > +	     reg_offset <= MAX_MAC_REG_OFFSET; reg_offset += 4) {
> > +		reg_space[reg_ix] = readl(ioaddr + reg_offset);
> > +		reg_ix++;
> > +	}
> > +
> > +	/* MTL registers */
> > +	for (reg_offset = START_MTL_REG_OFFSET;
> > +	     reg_offset <= MAX_MTL_REG_OFFSET; reg_offset += 4) {
> > +		reg_space[reg_ix] = readl(ioaddr + reg_offset);
> > +		reg_ix++;
> > +	}
> > +
> > +	/* DMA registers */
> > +	for (reg_offset = START_DMA_REG_OFFSET;
> > +	     reg_offset <= MAX_DMA_REG_OFFSET; reg_offset += 4) {
> > +		reg_space[reg_ix] = readl(ioaddr + reg_offset);
> > +		reg_ix++;
> > +	}
> [...]
>
> Consider adding an assertion at the end:
>
>	BUG_ON(reg_ix * 4 > REG_SPACE_SIZE);
>
> Ben.
Ok. Thanks for the review comments.

Vipul
-- Ben Hutchings Everything should be made as simple as possible, but not simpler. - Albert Einstein
