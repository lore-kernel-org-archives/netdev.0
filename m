From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC 2/2] net: Add support for NTB virtual ethernet device
Date: Fri, 13 Jul 2012 17:08:26 -0700
Message-ID: <20120713170826.09210b80@nehalam.linuxnetplumber.net>
References: <1342215900-3358-1-git-send-email-jon.mason@intel.com>
	<1342215900-3358-2-git-send-email-jon.mason@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-pci@vger.kernel.org, Dave Jiang <dave.jiang@intel.com>
To: Jon Mason <jon.mason@intel.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <1342215900-3358-2-git-send-email-jon.mason@intel.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 13 Jul 2012 14:45:00 -0700
Jon Mason <jon.mason@intel.com> wrote:

> A virtual ethernet device that uses the NTB transport API to send/receive data.
> 
> Signed-off-by: Jon Mason <jon.mason@intel.com>
> ---
>  drivers/net/Kconfig      |    4 +
>  drivers/net/Makefile     |    1 +
>  drivers/net/ntb_netdev.c |  411 ++++++++++++++++++++++++++++++++++++++++++++++
>  3 files changed, 416 insertions(+), 0 deletions(-)
>  create mode 100644 drivers/net/ntb_netdev.c


> +static void ntb_get_drvinfo(__attribute__((unused)) struct net_device *dev,
> +			    struct ethtool_drvinfo *info)
> +{
> +	strlcpy(info->driver, KBUILD_MODNAME, sizeof(info->driver));
> +	strlcpy(info->version, NTB_NETDEV_VER, sizeof(info->version));
> +}
> +
> +static const char ntb_nic_stats[][ETH_GSTRING_LEN] = {
> +	"rx_packets", "rx_bytes", "rx_errors", "rx_dropped", "rx_length_errors",
> +	"rx_frame_errors", "rx_fifo_errors",
> +	"tx_packets", "tx_bytes", "tx_errors", "tx_dropped",
> +};
> +
> +static int ntb_get_stats_count(__attribute__((unused)) struct net_device *dev)
> +{
> +	return ARRAY_SIZE(ntb_nic_stats);
> +}
> +
> +static int ntb_get_sset_count(struct net_device *dev, int sset)
> +{
> +	switch (sset) {
> +	case ETH_SS_STATS:
> +		return ntb_get_stats_count(dev);
> +	default:
> +		return -EOPNOTSUPP;
> +	}
> +}
> +
> +static void ntb_get_strings(__attribute__((unused)) struct net_device *dev,
> +			    u32 sset, u8 *data)
> +{
> +	switch (sset) {
> +	case ETH_SS_STATS:
> +		memcpy(data, *ntb_nic_stats, sizeof(ntb_nic_stats));
> +	}
> +}
> +
> +static void
> +ntb_get_ethtool_stats(struct net_device *dev,
> +		      __attribute__((unused)) struct ethtool_stats *stats,
> +		      u64 *data)
> +{
> +	int i = 0;
> +
> +	data[i++] = dev->stats.rx_packets;
> +	data[i++] = dev->stats.rx_bytes;
> +	data[i++] = dev->stats.rx_errors;
> +	data[i++] = dev->stats.rx_dropped;
> +	data[i++] = dev->stats.rx_length_errors;
> +	data[i++] = dev->stats.rx_frame_errors;
> +	data[i++] = dev->stats.rx_fifo_errors;
> +	data[i++] = dev->stats.tx_packets;
> +	data[i++] = dev->stats.tx_bytes;
> +	data[i++] = dev->stats.tx_errors;
> +	data[i++] = dev->stats.tx_dropped;
> +}

These statistics add no value over existing network stats.
Don't implement ethtool stats unless device has something more
interesting to say.

> +static const struct ethtool_ops ntb_ethtool_ops = {
> +	.get_drvinfo = ntb_get_drvinfo,
> +	.get_sset_count = ntb_get_sset_count,
> +	.get_strings = ntb_get_strings,
> +	.get_ethtool_stats = ntb_get_ethtool_stats,
> +	.get_link = ethtool_op_get_link,
> +};

If you want to implement bonding or bridging then implementing
get_settings would help.

> +static int __init ntb_netdev_init_module(void)
> +{
> +	struct ntb_netdev *dev;
> +	int rc;
> +
> +	pr_info("%s: Probe\n", KBUILD_MODNAME);

Useless message

> +	netdev = alloc_etherdev(sizeof(struct ntb_netdev));
> +	if (!netdev)
> +		return -ENOMEM;
> +
> +	dev = netdev_priv(netdev);
> +	dev->ndev = netdev;
> +	netdev->features = NETIF_F_HIGHDMA;
> +
> +	netdev->hw_features = netdev->features;
> +	netdev->watchdog_timeo = msecs_to_jiffies(NTB_TX_TIMEOUT_MS);
> +
> +	random_ether_addr(netdev->perm_addr);
> +	memcpy(netdev->dev_addr, netdev->perm_addr, netdev->addr_len);
> +
> +	netdev->netdev_ops = &ntb_netdev_ops;
> +	SET_ETHTOOL_OPS(netdev, &ntb_ethtool_ops);
> +
> +	dev->qp = ntb_transport_create_queue(ntb_netdev_rx_handler,
> +					     ntb_netdev_tx_handler,
> +					     ntb_netdev_event_handler);
> +	if (!dev->qp) {
> +		rc = -EIO;
> +		goto err;
> +	}
> +
> +	netdev->mtu = ntb_transport_max_size(dev->qp) - ETH_HLEN;
> +
> +	rc = register_netdev(netdev);
> +	if (rc)
> +		goto err1;
> +
> +	pr_info("%s: %s created\n", KBUILD_MODNAME, netdev->name);
> +	return 0;
> +
> +err1:
> +	ntb_transport_free_queue(dev->qp);
> +err:
> +	free_netdev(netdev);
> +	return rc;
> +}
> +module_init(ntb_netdev_init_module);
> +
> +static void __exit ntb_netdev_exit_module(void)
> +{
> +	struct ntb_netdev *dev = netdev_priv(netdev);
> +
> +	unregister_netdev(netdev);
> +	ntb_transport_free_queue(dev->qp);
> +	free_netdev(netdev);
> +
> +	pr_info("%s: Driver removed\n", KBUILD_MODNAME);
> +}
> +module_exit(ntb_netdev_exit_module);
