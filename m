From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v6 02/10] dpaa_eth: add support for DPAA
 Ethernet
Date: Thu, 03 Nov 2016 15:58:16 -0400 (EDT)
Message-ID: <20161103.155816.642712588084106823.davem@davemloft.net>
References: <1478117854-8952-1-git-send-email-madalin.bucur@nxp.com>
        <1478117854-8952-3-git-send-email-madalin.bucur@nxp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
        linux-kernel@vger.kernel.org, oss@buserror.net,
        ppc@mindchasers.com, joe@perches.com, pebolle@tiscali.nl,
        joakim.tjernlund@transmode.se
To: madalin.bucur@nxp.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1478117854-8952-3-git-send-email-madalin.bucur@nxp.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Madalin Bucur <madalin.bucur@nxp.com>
Date: Wed, 2 Nov 2016 22:17:26 +0200

> This introduces the Freescale Data Path Acceleration Architecture
> +static inline size_t bpool_buffer_raw_size(u8 index, u8 cnt)
> +{
> +	u8 i;
> +	size_t res = DPAA_BP_RAW_SIZE / 2;

Always order local variable declarations from longest to shortest line,
also know as Reverse Christmas Tree Format.

Please audit your entire submission for this problem, it occurs
everywhere.

> +	/* we do not want shared skbs on TX */
> +	net_dev->priv_flags &= ~IFF_TX_SKB_SHARING;

Why?  By clearing this, you disallow an important fundamental way to do
performane testing, via pktgen.


> +	int numstats = sizeof(struct rtnl_link_stats64) / sizeof(u64);
 ...
> +		cpustats = (u64 *)&percpu_priv->stats;
> +
> +		for (j = 0; j < numstats; j++)
> +			netstats[j] += cpustats[j];

This is a memcpy() on well-typed datastructures which requires no
casting or special handling whatsoever, so use memcpy instead of
needlessly open coding the operation.

> +static int dpaa_change_mtu(struct net_device *net_dev, int new_mtu)
> +{
> +	const int max_mtu = dpaa_get_max_mtu();
> +
> +	/* Make sure we don't exceed the Ethernet controller's MAXFRM */
> +	if (new_mtu < 68 || new_mtu > max_mtu) {
> +		netdev_err(net_dev, "Invalid L3 mtu %d (must be between %d and %d).\n",
> +			   new_mtu, 68, max_mtu);
> +		return -EINVAL;
> +	}
> +	net_dev->mtu = new_mtu;
> +
> +	return 0;
> +}

MTU restrictions are handled in the net-next tree via net_dev->min_mtu and
net_dev->max_mtu.  Use that and do not define this NDO operation as you do
not need it.

> +static int dpaa_set_features(struct net_device *dev, netdev_features_t features)
> +{
> +	/* Not much to do here for now */
> +	dev->features = features;
> +	return 0;
> +}

Do not define unnecessary NDO operations, let the defaults do their job.

> +static netdev_features_t dpaa_fix_features(struct net_device *dev,
> +					   netdev_features_t features)
> +{
> +	netdev_features_t unsupported_features = 0;
> +
> +	/* In theory we should never be requested to enable features that
> +	 * we didn't set in netdev->features and netdev->hw_features at probe
> +	 * time, but double check just to be on the safe side.
> +	 */
> +	unsupported_features |= NETIF_F_RXCSUM;
> +
> +	features &= ~unsupported_features;
> +
> +	return features;
> +}

Unless you can show that your need this, do not "guess" by implement this
NDO operation.  You don't need it.

> +#ifdef CONFIG_FSL_DPAA_ETH_FRIENDLY_IF_NAME
> +static int dpaa_mac_hw_index_get(struct platform_device *pdev)
> +{
> +	struct device *dpaa_dev;
> +	struct dpaa_eth_data *eth_data;
> +
> +	dpaa_dev = &pdev->dev;
> +	eth_data = dpaa_dev->platform_data;
> +
> +	return eth_data->mac_hw_id;
> +}
> +
> +static int dpaa_mac_fman_index_get(struct platform_device *pdev)
> +{
> +	struct device *dpaa_dev;
> +	struct dpaa_eth_data *eth_data;
> +
> +	dpaa_dev = &pdev->dev;
> +	eth_data = dpaa_dev->platform_data;
> +
> +	return eth_data->fman_hw_id;
> +}
> +#endif

Do not play network device naming games like this, use the standard name
assignment done by the kernel and have userspace entities do geographic or
device type specific naming.

I want to see this code completely removed.

> +static int dpaa_set_mac_address(struct net_device *net_dev, void *addr)
> +{
> +	const struct dpaa_priv	*priv;
> +	int err;
> +	struct mac_device *mac_dev;
> +
> +	priv = netdev_priv(net_dev);
> +
> +	err = eth_mac_addr(net_dev, addr);
> +	if (err < 0) {
> +		netif_err(priv, drv, net_dev, "eth_mac_addr() = %d\n", err);
> +		return err;
> +	}
> +
> +	mac_dev = priv->mac_dev;
> +
> +	err = mac_dev->change_addr(mac_dev->fman_mac,
> +				   (enet_addr_t *)net_dev->dev_addr);
> +	if (err < 0) {
> +		netif_err(priv, drv, net_dev, "mac_dev->change_addr() = %d\n",
> +			  err);
> +		return err;
> +	}

You MUST NOT return an error at this point without rewinding the state change
performed by eth_mac_addr().  Otherwise device will be left in an inconsistent
state compared to what the software MAC address has recorded.

This driver is enormous, I don't have the time nor the patience to
review it further for what seems to be many fundamental errors like
the ones I have pointed out so far.

Sorry.
