From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH V12 6/7] net: sxgbe: add ethtool related functions
 support Samsung sxgbe
Date: Mon, 24 Mar 2014 19:29:37 +0000
Message-ID: <1395689377.2832.63.camel@deadeye.wl.decadent.org.uk>
References: <008f01cf464d$0a48e810$1edab830$@samsung.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-jv3/2i0Sfx9gj5wwQxNz"
Cc: netdev@vger.kernel.org, linux-samsung-soc@vger.kernel.org,
	devicetree@vger.kernel.org, 'David Miller' <davem@davemloft.net>,
	'GIRISH K S' <ks.giri@samsung.com>,
	'SIVAREDDY KALLAM' <siva.kallam@samsung.com>,
	'Vipul Chandrakant' <vipul.pandya@samsung.com>,
	'Ilho Lee' <ilho215.lee@samsung.com>
To: Byungho An <bh74.an@samsung.com>
Return-path: <linux-samsung-soc-owner@vger.kernel.org>
In-Reply-To: <008f01cf464d$0a48e810$1edab830$@samsung.com>
Sender: linux-samsung-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-jv3/2i0Sfx9gj5wwQxNz
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Sorry I didn't look over this earlier.

On Sat, 2014-03-22 at 21:04 -0700, Byungho An wrote:
[...]
> --- a/drivers/net/ethernet/samsung/sxgbe/sxgbe_common.h
> +++ b/drivers/net/ethernet/samsung/sxgbe/sxgbe_common.h
> @@ -42,8 +42,12 @@ struct sxgbe_mtl_ops;
>  #define SXGBE_RX_QUEUES   16
> =20
>  /* Max/Min RI Watchdog Timer count value */
> -#define SXGBE_MAX_DMA_RIWT	0xff
> -#define SXGBE_MIN_DMA_RIWT	0x20
> +/* Calculated based how much time does it take to fill 256KB Rx memory
> + * at 10Gb speed at 156MHz clock rate and considered little less then
> + * the actual value.
> + */
> +#define SXGBE_MAX_DMA_RIWT	0x70
> +#define SXGBE_MIN_DMA_RIWT	0x01

This change should be folded into patch 2/7.

[...]
> --- a/drivers/net/ethernet/samsung/sxgbe/sxgbe_ethtool.c
> +++ b/drivers/net/ethernet/samsung/sxgbe/sxgbe_ethtool.c
[...]
> -static int sxgbe_ethtool_get_eee(struct net_device *dev,
> -				 struct ethtool_eee *edata)
> +static int sxgbe_get_eee(struct net_device *dev,
> +			 struct ethtool_eee *edata)
>  {
>  	struct sxgbe_priv_data *priv =3D netdev_priv(dev);
> =20
> @@ -55,8 +150,8 @@ static int sxgbe_ethtool_get_eee(struct net_device *de=
v,
>  	return phy_ethtool_get_eee(priv->phydev, edata);
>  }
> =20
> -static int sxgbe_ethtool_set_eee(struct net_device *dev,
> -				 struct ethtool_eee *edata)
> +static int sxgbe_set_eee(struct net_device *dev,
> +			 struct ethtool_eee *edata)
>  {
>  	struct sxgbe_priv_data *priv =3D netdev_priv(dev);
> =20

These name changes should be folded into patch 2/7.

[...]
> +static int sxgbe_getsettings(struct net_device *dev,
> +			     struct ethtool_cmd *cmd)
> +{
> +	struct sxgbe_priv_data *priv =3D netdev_priv(dev);
> +
> +	if (priv->phydev)
> +		return phy_ethtool_gset(priv->phydev, cmd);
> +
> +	return -ENODEV;
> +}
> +
> +static int sxgbe_setsettings(struct net_device *dev, struct ethtool_cmd =
*cmd)
> +{
> +	struct sxgbe_priv_data *priv =3D netdev_priv(dev);
> +
> +	if (priv->phydev)
> +		return phy_ethtool_sset(priv->phydev, cmd);
> +
> +	return -ENODEV;
> +}

I think these two operations should return -EOPNOTSUPP if there is no
PHY.

[...]
> +static int sxgbe_get_ts_info(struct net_device *dev,
> +			     struct ethtool_ts_info *info)
> +{
> +	struct sxgbe_priv_data *priv =3D netdev_priv(dev);
> +
> +	if (!priv->hw_cap.atime_stamp)
> +		return ethtool_op_get_ts_info(dev, info);
> +
> +	info->so_timestamping =3D (SOF_TIMESTAMPING_TX_SOFTWARE |
> +				 SOF_TIMESTAMPING_RX_SOFTWARE |
> +				 SOF_TIMESTAMPING_SOFTWARE |
> +				 SOF_TIMESTAMPING_TX_HARDWARE |
> +				 SOF_TIMESTAMPING_RX_HARDWARE |
> +				 SOF_TIMESTAMPING_RAW_HARDWARE);
> +
> +	if (priv->ptp_clock)
> +		info->phc_index =3D ptp_clock_index(priv->ptp_clock);

priv->ptp_clock doesn't appear to be set anywhere; nor does the driver
implement SIOCSHWTSTAMP.  So this function should not advertise any
hardware timestamping features yet.

> +	info->tx_types =3D ((1 << HWTSTAMP_TX_OFF) |
> +			  (1 << HWTSTAMP_TX_ON) |
> +			  (1 << HWTSTAMP_TX_ONESTEP_SYNC));
> +
> +	info->rx_filters =3D ((1 << HWTSTAMP_FILTER_NONE) |
> +			    (1 << HWTSTAMP_FILTER_PTP_V1_L4_EVENT) |
> +			    (1 << HWTSTAMP_FILTER_PTP_V1_L4_SYNC) |
> +			    (1 << HWTSTAMP_FILTER_PTP_V1_L4_DELAY_REQ) |
> +			    (1 << HWTSTAMP_FILTER_PTP_V2_L4_EVENT) |
> +			    (1 << HWTSTAMP_FILTER_PTP_V2_L4_SYNC) |
> +			    (1 << HWTSTAMP_FILTER_PTP_V2_L4_DELAY_REQ) |
> +			    (1 << HWTSTAMP_FILTER_PTP_V2_L2_EVENT) |
> +			    (1 << HWTSTAMP_FILTER_PTP_V2_L2_SYNC) |
> +			    (1 << HWTSTAMP_FILTER_PTP_V2_L2_DELAY_REQ) |
> +			    (1 << HWTSTAMP_FILTER_PTP_V2_EVENT) |
> +			    (1 << HWTSTAMP_FILTER_PTP_V2_SYNC) |
> +			    (1 << HWTSTAMP_FILTER_PTP_V2_DELAY_REQ) |
> +			    (1 << HWTSTAMP_FILTER_ALL));
> +	return 0;
> +}
> +
> +int sxgbe_set_flow_ctrl(struct sxgbe_priv_data *priv, int rx, int tx)
> +{
> +	return 0;
> +}
> +
> +static void sxgbe_get_pauseparam(struct net_device *netdev,
> +				 struct ethtool_pauseparam *pause)
> +{
> +	struct sxgbe_priv_data *priv =3D netdev_priv(netdev);
> +
> +	pause->rx_pause =3D priv->rx_pause;
> +	pause->tx_pause =3D priv->tx_pause;
> +}
> +
> +static int sxgbe_set_pauseparam(struct net_device *netdev,
> +				struct ethtool_pauseparam *pause)
> +{
> +	struct sxgbe_priv_data *priv =3D netdev_priv(netdev);
> +
> +	if (pause->autoneg)
> +		return -EINVAL;
> +
> +	return sxgbe_set_flow_ctrl(priv, pause->rx_pause, pause->tx_pause);

But sxgbe_set_flow_ctrl() is empty, so this isn't a proper
implementation.

> +}
[...]
> +static int sxgbe_get_sset_count(struct net_device *netdev, int sset)
> +{
> +	int len;
> +
> +	switch (sset) {
> +	case ETH_SS_STATS:
> +		len =3D SXGBE_STATS_LEN;
> +		return len;
> +	default:
> +		return -EOPNOTSUPP;

You implement the operation, just not this particular argument value.
So return -EINVAL.

> +	}
> +}
> +
> +static void sxgbe_get_ethtool_stats(struct net_device *dev,
> +				    struct ethtool_stats *dummy, u64 *data)
> +{
> +	struct sxgbe_priv_data *priv =3D netdev_priv(dev);
> +	int i, j =3D 0;
> +	char *p;
> +
> +	if (priv->eee_enabled) {
> +		int val =3D phy_get_eee_err(priv->phydev);
> +
> +		if (val)
> +			priv->xstats.eee_wakeup_error_n =3D val;
> +	}
> +
> +	for (i =3D 0; i < SXGBE_STATS_LEN; i++) {
> +		p =3D (char *)priv + sxgbe_gstrings_stats[i].stat_offset;
> +		data[j++] =3D (sxgbe_gstrings_stats[i].sizeof_stat =3D=3D sizeof(u64))
> +			? (*(u64 *)p) : (*(u32 *)p);
> +	}
> +}

It looks like you will always use the same value of i and j in each
pass, so you don't need two separate variables.

[...]
> +static int sxgbe_get_coalesce(struct net_device *dev,
> +                             struct ethtool_coalesce *ec)
> +{
> +       struct sxgbe_priv_data *priv =3D netdev_priv(dev);
> +
> +       if (priv->use_riwt)
> +               ec->rx_coalesce_usecs =3D sxgbe_riwt2usec(priv->rx_riwt, =
priv);

Also set:

	ec->rx_max_coalesced_frames =3D !priv->use_riwt;
	ec->tx_coalesce_usecs =3D SXGBE_COAL_TX_TIMER;
	ec->tx_max_coalesced_frames =3D SXGBE_TX_FRAMES;

> +       return 0;
> +}
> +
> +static int sxgbe_set_coalesce(struct net_device *dev,
> +			      struct ethtool_coalesce *ec)
> +{
> +	struct sxgbe_priv_data *priv =3D netdev_priv(dev);
> +	unsigned int rx_riwt;
> +
> +	rx_riwt =3D sxgbe_usec2riwt(ec->rx_coalesce_usecs, priv);
> +
> +	if ((rx_riwt > SXGBE_MAX_DMA_RIWT) || (rx_riwt < SXGBE_MIN_DMA_RIWT))
> +		return -EINVAL;
> +	else if (!priv->use_riwt)
> +		return -EOPNOTSUPP;

Please check for attempts to change unsupported parameters:

	if (ec->rx_max_coalesced_frames !=3D !rx_riwt ||
	    ec->tx_coalesce_usecs !=3D SXGBE_COAL_TX_TIMER ||
	    ec->tx_max_coalesced_frames !=3D SXGBE_TX_FRAMES ||
	    ec->use_adaptive_rx_coalesce ||
	    ec->use_adaptive_tx_coalesce)
		return -EINVAL;

> +	priv->rx_riwt =3D rx_riwt;
> +	priv->hw->dma->rx_watchdog(priv->ioaddr, priv->rx_riwt);
> +
> +	return 0;
> +}
[...]
> +static int sxgbe_set_rss_hash_opt(struct sxgbe_priv_data *priv,
> +				  struct ethtool_rxnfc *cmd)
> +{
> +	u32 reg_val =3D 0;
> +
> +	/* RSS does not support anything other than hashing
> +	 * to queues on src and dst IPs and ports
> +	 */
> +	if (cmd->data & ~(RXH_IP_SRC | RXH_IP_DST |
> +			  RXH_L4_B_0_1 | RXH_L4_B_2_3))
> +		return -EINVAL;
> +
> +	switch (cmd->flow_type) {
> +	case TCP_V4_FLOW:
> +	case TCP_V6_FLOW:
> +		if (!(cmd->data & RXH_IP_SRC) ||
> +		    !(cmd->data & RXH_IP_DST) ||
> +		    !(cmd->data & RXH_L4_B_0_1) ||
> +		    !(cmd->data & RXH_L4_B_2_3))
> +			return -EINVAL;
> +		reg_val =3D SXGBE_CORE_RSS_CTL_TCP4TE;
> +		break;
> +	case UDP_V4_FLOW:
> +	case UDP_V6_FLOW:
> +		if (!(cmd->data & RXH_IP_SRC) ||
> +		    !(cmd->data & RXH_IP_DST) ||
> +		    !(cmd->data & RXH_L4_B_0_1) ||
> +		    !(cmd->data & RXH_L4_B_2_3))
> +			return -EINVAL;
> +		reg_val =3D SXGBE_CORE_RSS_CTL_UDP4TE;
> +		break;
> +	case SCTP_V4_FLOW:
> +	case AH_ESP_V4_FLOW:
> +	case AH_V4_FLOW:
> +	case ESP_V4_FLOW:
> +	case AH_ESP_V6_FLOW:
> +	case AH_V6_FLOW:
> +	case ESP_V6_FLOW:
> +	case SCTP_V6_FLOW:
> +	case IPV4_FLOW:
> +	case IPV6_FLOW:
> +		if (!(cmd->data & RXH_IP_SRC) ||
> +		    !(cmd->data & RXH_IP_DST) ||
> +		    (cmd->data & RXH_L4_B_0_1) ||
> +		    (cmd->data & RXH_L4_B_2_3))
> +			return -EINVAL;
> +		reg_val =3D SXGBE_CORE_RSS_CTL_IP2TE;
> +		break;
> +	default:
> +		return -EINVAL;
> +	}

Unless I'm missing something, this only accepts the default values, so
it's not actually possible to change the configuration.  Why are you
implementing this operation at all?

[...]
> +static void sxgbe_get_regs(struct net_device *dev,
> +			   struct ethtool_regs *regs, void *space)
> +{
> +	struct sxgbe_priv_data *priv =3D netdev_priv(dev);
> +	u32 *reg_space =3D (u32 *)space;
> +	int reg_offset;
> +	int reg_ix =3D 0;
> +	void __iomem *ioaddr =3D priv->ioaddr;
> +
> +	memset(reg_space, 0x0, REG_SPACE_SIZE);
> +
> +	/* MAC registers */
> +	for (reg_offset =3D START_MAC_REG_OFFSET;
> +	     reg_offset <=3D MAX_MAC_REG_OFFSET; reg_offset +=3D 4) {
> +		reg_space[reg_ix] =3D readl(ioaddr + reg_offset);
> +		reg_ix++;
> +	}
> +
> +	/* MTL registers */
> +	for (reg_offset =3D START_MTL_REG_OFFSET;
> +	     reg_offset <=3D MAX_MTL_REG_OFFSET; reg_offset +=3D 4) {
> +		reg_space[reg_ix] =3D readl(ioaddr + reg_offset);
> +		reg_ix++;
> +	}
> +
> +	/* DMA registers */
> +	for (reg_offset =3D START_DMA_REG_OFFSET;
> +	     reg_offset <=3D MAX_DMA_REG_OFFSET; reg_offset +=3D 4) {
> +		reg_space[reg_ix] =3D readl(ioaddr + reg_offset);
> +		reg_ix++;
> +	}
[...]

Consider adding an assertion at the end:

	BUG_ON(reg_ix * 4 > REG_SPACE_SIZE);

Ben.

--=20
Ben Hutchings
Everything should be made as simple as possible, but not simpler.
                                                           - Albert Einstei=
n

--=-jv3/2i0Sfx9gj5wwQxNz
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAUzCHoee/yOyVhhEJAQpEdBAAqaLMd3Z90PlZ9WzGGRr2AYkqTYvgVyFM
9Pg4scP6ossNdoqovZnohUGJeNojcOV5zwA+XuryHMhCwryk/ybbHIP98eu7LIHJ
ShS04b7AGL/R1KMZ4LKrfrJiUfu40xEWH8nwizMnyXSl9wv92ihfLskvOw0iCyV+
kFXksbzaP1AWclPx8+wekVaRL5Z4FT7XPCQe19a8BQM35e9/6zjwnteh/+erDDZ6
n1eVk1CmjSANOgK/5/TDSKud2KICOXIq/iydQDMF5Gw1JTj3mcetEa2GqzrqH3Jo
vlFfy0nIghBRrlmRZFeIL7Bz+KEkZWfxpiVrKhalARHNX0ih6aWz2/vf5p/K7eu5
770QkGyhakLHljOUYbyXhoXSZARv6ATPI8d+YFxm4Y4Ghf2ucXZ6JrmOE5//f+Ok
u7msBygG0xU9fBXsUEWLRaval7KzvQwiU7KekQFioBwXxwWSD2vHTN/oNpE6+SqC
JwwVYyZcsLpwn0NELZy+OrtzTz6bdfOaVjMP4aYSzYivkO6UU8HJZk4RgU5VIPiV
p5yz0l2dCltOWwUwL8C6zmGSjPuC0J9qlBC+ZxpIcCdbAiO4WzBQqgGyRwIBrpz0
EwzgX9dBOV4DsyZmpMIeyPTP2qLKEvvZm2vLKVpdhpvpIBlAGi+J3s2ZWnIKZSvC
zBA5uCXC6y8=
=CoGG
-----END PGP SIGNATURE-----

--=-jv3/2i0Sfx9gj5wwQxNz--
