From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next RFC 3/7] i40evf: core ethtool functionality
Date: Tue, 27 Aug 2013 18:27:52 +0100
Message-ID: <1377624472.13272.43.camel@bwh-desktop.uk.level5networks.com>
References: <1377233609-11627-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1377233609-11627-4-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>,
	Mitch A Williams <mitch.a.williams@intel.com>,
	<netdev@vger.kernel.org>, <gospo@redhat.com>, <sassmann@redhat.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:17866 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752209Ab3H0R15 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Aug 2013 13:27:57 -0400
In-Reply-To: <1377233609-11627-4-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-08-22 at 21:53 -0700, Jeff Kirsher wrote:
[...]
> --- /dev/null
> +++ b/drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c
[...]
> +/**
> + * i40evf_get_settings - Get Link Speed and Duplex settings
> + * @netdev: network interface device structure
> + * @ecmd: ethtool command
> + *
> + * Reports speed/duplex settings. Because this is a VF, we don't know what
> + * kind of link we really have, so we fake it.
> + **/
> +static int i40evf_get_settings(struct net_device *netdev,
> +			       struct ethtool_cmd *ecmd)
> +{
> +	ecmd->supported = SUPPORTED_10000baseT_Full;

This is silly.

> +	ecmd->autoneg = AUTONEG_DISABLE;
> +	ecmd->transceiver = XCVR_DUMMY1;
> +	ecmd->port = -1;

PORT_NONE, I think.

> +	return 0;
> +}
> +
> +/**
> + * i40evf_get_sset_count - Get length of string set
> + * @netdev: network interface device structure
> + * @sset: id of string set
> + *
> + * Reports size (in bytes) of string set.

Not in bytes.

>  This driver only supports
> + * strings for statistics.
> + **/
[...]
> +/**
> + * i40evf_get_strings - Get string set
> + * @netdev: network interface device structure
> + * @sset: id of string set
> + * @data: buffer for string data
> + *
> + * Strings are concatenated into the data buffer, separated by nulls.

This looks like a description of a Windows-style double-null-terminated
string list, not an ethtool string set.

> + **/
> +static void i40evf_get_strings(struct net_device *netdev, u32 sset, u8 *data)
> +{
> +	struct i40evf_adapter *adapter = netdev_priv(netdev);
> +	u8 *p = data;
> +	int i;
> +
> +	if (sset == ETH_SS_STATS) {
> +		for (i = 0; i < I40EVF_GLOBAL_STATS_LEN; i++) {
> +			memcpy(p, i40evf_gstrings_stats[i].stat_string,
> +			       ETH_GSTRING_LEN);
> +			p += ETH_GSTRING_LEN;
> +		}
> +		for (i = 0; i < adapter->vsi_res->num_queue_pairs; i++) {
> +			snprintf(p, ETH_GSTRING_LEN, "%s.tx_queue_%u.packets",
> +				 netdev->name, i);
> +			p += ETH_GSTRING_LEN;
> +			snprintf(p, ETH_GSTRING_LEN, "%s.tx_queue_%u.bytes",
> +				 netdev->name, i);
> +			p += ETH_GSTRING_LEN;
> +		}
> +		for (i = 0; i < adapter->vsi_res->num_queue_pairs; i++) {
> +			snprintf(p, ETH_GSTRING_LEN, "%s.rx_queue_%u.packets",
> +				 netdev->name, i);
> +			p += ETH_GSTRING_LEN;
> +			snprintf(p, ETH_GSTRING_LEN, "%s.rx_queue_%u.bytes",
> +				 netdev->name, i);
> +			p += ETH_GSTRING_LEN;

It is completely redundant to put the device name into statistic names,
and is liable to cause the names to be truncated.  There was also a
discussion about how to name per-queue statistics a while back, which
seemed to end in agreement:

http://thread.gmane.org/gmane.linux.network/273014/focus=12205

So I think the name formats should be "tx-%u.packets" etc.

[...]
> +/**
> + * i40evf_get_drvinto - Get driver info
> + * @netdev: network interface device structure
> + * @drvinfo: ethool driver info structure
> + *
> + * Returns information about the driver and device for display to the user.
> + **/
> +static void i40evf_get_drvinfo(struct net_device *netdev,
> +			       struct ethtool_drvinfo *drvinfo)
> +{
> +	struct i40evf_adapter *adapter = netdev_priv(netdev);
> +
> +	strncpy(drvinfo->driver, i40evf_driver_name, 32);
> +	strncpy(drvinfo->version, i40evf_driver_version, 32);
> +
> +	strncpy(drvinfo->fw_version, "N/A", 4);

If there is no firmware version then don't set fw_version at all.

> +	strncpy(drvinfo->bus_info, pci_name(adapter->pdev), 32);

Use strlcpy() not strncpy() for all of the other strings.

> +	drvinfo->n_stats = I40EVF_STATS_LEN;
> +	drvinfo->regdump_len = 0;

Don't set these at all, as they are initialised by the ethtool core
based on other driver operations.

[...]
> +static void i40evf_get_ringparam(struct net_device *netdev,
> +				  struct ethtool_ringparam *ring)
> +{
> +	struct i40evf_adapter *adapter = netdev_priv(netdev);
> +	struct i40e_ring *tx_ring = &adapter->tx_rings[0];
> +	struct i40e_ring *rx_ring = &adapter->rx_rings[0];
> +
> +	ring->rx_max_pending = I40EVF_MAX_RXD;
> +	ring->tx_max_pending = I40EVF_MAX_TXD;
> +	ring->rx_mini_max_pending = 0;
> +	ring->rx_jumbo_max_pending = 0;
> +	ring->rx_pending = rx_ring->count;
> +	ring->tx_pending = tx_ring->count;
> +	ring->rx_mini_pending = 0;
> +	ring->rx_jumbo_pending = 0;
> +}

No need to set the unsupported fields to 0.

[...]
> +static int i40evf_get_coalesce(struct net_device *netdev,
> +			     struct ethtool_coalesce *ec)
> +{
> +	struct i40evf_adapter *adapter = netdev_priv(netdev);
> +	struct i40e_vsi *vsi = &adapter->vsi;
> +
> +	ec->tx_max_coalesced_frames_irq = vsi->work_limit;
> +	ec->rx_max_coalesced_frames_irq = vsi->work_limit;

Use the fields without the '_irq' suffix.  The '_irq' suffixed fields
are there for some NICs that change coalescing behaviour depending on
whether the previous IRQ is still being handled.

[...]
> +static int i40evf_set_coalesce(struct net_device *netdev,
> +			     struct ethtool_coalesce *ec)
> +{
> +	struct i40evf_adapter *adapter = netdev_priv(netdev);
> +	struct i40e_hw *hw = &adapter->hw;
> +	struct i40e_vsi *vsi = &adapter->vsi;
> +	struct i40e_q_vector *q_vector;
> +	int i;
> +
> +	if (ec->tx_max_coalesced_frames_irq || ec->rx_max_coalesced_frames_irq)
> +		vsi->work_limit = ec->tx_max_coalesced_frames_irq;
[...]

Again, use the fields without the '_irq' suffix.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
