From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next 3/8] i40e: driver ethtool core
Date: Wed, 19 Jun 2013 19:27:10 +0100
Message-ID: <1371666430.1956.102.camel@bwh-desktop.uk.level5networks.com>
References: <1371182122-26629-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1371182122-26629-4-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	<netdev@vger.kernel.org>, <gospo@redhat.com>,
	<sassmann@redhat.com>, "Shannon Nelson" <shannon.nelson@intel.com>,
	PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>,
	<e1000-devel@lists.sourceforge.net>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:34128 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935086Ab3FSS1P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jun 2013 14:27:15 -0400
In-Reply-To: <1371182122-26629-4-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-06-13 at 20:55 -0700, Jeff Kirsher wrote:
> From: Jesse Brandeburg <jesse.brandeburg@intel.com>
> 
> This patch contains the ethtool interface and implementation.
> 
> The goal in this patch series is minimal functionality while not
> including much in the way of "set support."
[...]
> --- /dev/null
> +++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
[...]
> +static const struct i40e_stats i40e_gstrings_net_stats[] = {
> +	I40E_NETDEV_STAT(rx_packets),
> +	I40E_NETDEV_STAT(tx_packets),
> +	I40E_NETDEV_STAT(rx_bytes),
> +	I40E_NETDEV_STAT(tx_bytes),
> +	I40E_NETDEV_STAT(rx_errors),
> +	I40E_NETDEV_STAT(tx_errors),
> +	I40E_NETDEV_STAT(rx_dropped),
> +	I40E_NETDEV_STAT(tx_dropped),
> +	I40E_NETDEV_STAT(multicast),
> +	I40E_NETDEV_STAT(collisions),
> +	I40E_NETDEV_STAT(rx_length_errors),
> +	I40E_NETDEV_STAT(rx_over_errors),
> +	I40E_NETDEV_STAT(rx_crc_errors),
> +	I40E_NETDEV_STAT(rx_frame_errors),
> +	I40E_NETDEV_STAT(rx_fifo_errors),
> +	I40E_NETDEV_STAT(tx_aborted_errors),
> +	I40E_NETDEV_STAT(tx_carrier_errors),
> +	I40E_NETDEV_STAT(tx_fifo_errors),
> +	I40E_NETDEV_STAT(tx_heartbeat_errors),
> +	I40E_NETDEV_STAT(tx_window_errors),
> +	I40E_NETDEV_STAT(rx_compressed),
> +	I40E_NETDEV_STAT(tx_compressed),
> +};

So you're doing VJ header compression over Ethernet now?  At least drop
the irrelevant counters.

> +static struct i40e_stats i40e_gstrings_stats[] = {
> +	I40E_PF_STAT("rx_bytes", stats.eth.rx_bytes),
> +	I40E_PF_STAT("tx_bytes", stats.eth.tx_bytes),
> +	I40E_PF_STAT("rx_errors", stats.eth.rx_errors),
> +	I40E_PF_STAT("tx_errors", stats.eth.tx_errors),

Duplicates.

[...]
> +#define I40E_QUEUE_STATS_LEN \
> +  ((((struct i40e_netdev_priv *)netdev_priv(netdev))->vsi->num_queue_pairs + \
> +    ((struct i40e_netdev_priv *)netdev_priv(netdev))->vsi->num_queue_pairs) * 2)

netdev should be a macro parameter.  Actually this could just as well be
a function.

[...]
> +/**
> + * i40e_get_settings - Get Link Speed and Duplex settings
> + * @netdev: network interface device structure
> + * @ecmd: ethtool command
> + *
> + * Reports speed/duplex settings based on media_type
> + **/
> +static int i40e_get_settings(struct net_device *netdev,
> +			     struct ethtool_cmd *ecmd)
> +{
> +	struct i40e_netdev_priv *np = netdev_priv(netdev);
> +	struct i40e_pf *pf = np->vsi->back;
> +	struct i40e_hw *hw = &pf->hw;
> +	struct i40e_link_status *hw_link_info = &hw->phy.link_info;
> +	u32 link_speed = hw_link_info->link_speed;
> +	bool link_up = false;
> +
> +	ecmd->supported = SUPPORTED_10000baseT_Full |
> +			  SUPPORTED_1000baseT_Full  |
> +			  SUPPORTED_Autoneg;
> +
> +	ecmd->advertising  = ADVERTISED_10000baseT_Full |
> +			     ADVERTISED_1000baseT_Full;
> +
> +	if (hw->phy.media_type == I40E_MEDIA_TYPE_BACKPLANE) {
> +		ecmd->supported |= (SUPPORTED_100baseT_Full |
> +				    SUPPORTED_Autoneg);
> +		ecmd->advertising |= ADVERTISED_100baseT_Full;

All the link modes are wrong for backplane.

> +	} else if (hw->phy.media_type == I40E_MEDIA_TYPE_BASET) {
> +		ecmd->supported |= SUPPORTED_TP;
> +		ecmd->advertising |= ADVERTISED_TP;
> +		ecmd->port = PORT_TP;
> +	} else {
> +		ecmd->supported |= SUPPORTED_FIBRE;
> +		ecmd->advertising |= ADVERTISED_FIBRE;
> +		ecmd->port = PORT_FIBRE;

And for fibre, though this is bodged in most drivers.  But for backplane
modes we do have ethtool link mode flags defined so there's no excuse.

> +	}
> +
> +	if (hw->phy.get_link_info == true)
> +		link_up = hw_link_info->link_info & I40E_AQ_LINK_UP;
> +
> +	ecmd->advertising = ADVERTISED_Autoneg;

So autoneg is always used, even over fibre?

> +	if (hw->phy.autoneg_advertised) {
> +		if (hw->phy.autoneg_advertised & I40E_LINK_SPEED_100MB)
> +			ecmd->advertising |= ADVERTISED_100baseT_Full;
> +		if (hw->phy.autoneg_advertised & I40E_LINK_SPEED_1GB)
> +			ecmd->advertising |= ADVERTISED_1000baseT_Full;
> +		if (hw->phy.autoneg_advertised & I40E_LINK_SPEED_10GB)
> +			ecmd->advertising |= ADVERTISED_10000baseT_Full;
> +	} else {
> +		ecmd->advertising |= (ADVERTISED_10000baseT_Full |
> +				      ADVERTISED_1000baseT_Full);
> +	}
> +
> +	ecmd->transceiver = XCVR_EXTERNAL;

Really?

> +	if (!in_interrupt()) {
> +		i40e_aq_get_link_info(&pf->hw, true, NULL, NULL);
> +	} else {
> +		/* Reinitialize link variables, a special workaround for RHEL5
> +		 * bonding that calls this routine from interrupt context
> +		 */
> +		link_speed = hw_link_info->link_speed;
> +		link_up = hw_link_info->link_info & I40E_AQ_LINK_UP;
> +	}

I know that bug.  In fact, it only got completely fixed in 3.9 (and some
stable branches).  But you can't put this workaround in-tree.

[...]
> +static void i40e_get_drvinfo(struct net_device *netdev,
> +			     struct ethtool_drvinfo *drvinfo)
> +{
> +	struct i40e_netdev_priv *np = netdev_priv(netdev);
> +	struct i40e_vsi *vsi = np->vsi;
> +	struct i40e_pf *pf = vsi->back;
> +	char firmware_version[32];
> +
> +	strncpy(drvinfo->driver, i40e_driver_name, sizeof(drvinfo->driver));
> +	strncpy(drvinfo->version, i40e_driver_version_str,
> +		sizeof(drvinfo->version));

Replace strncpy() with strlcpy() throughout this function.

> +	snprintf(firmware_version, sizeof(firmware_version),
> +		 "FW %d.%d API %d.%d NVM %02d.%02d.%02d",
> +		 pf->hw.aq.fw_maj_ver, pf->hw.aq.fw_min_ver,
> +		 pf->hw.aq.api_maj_ver, pf->hw.aq.api_min_ver,
> +		 ((pf->hw.nvm.version >> 12) & 0xf),
> +		 ((pf->hw.nvm.version >> 4) & 0xff),
> +		 (pf->hw.nvm.version & 0xf));
> +
> +	strncpy(drvinfo->fw_version, firmware_version,
> +		sizeof(drvinfo->fw_version));

What was the point of the intermediate buffer?

> +	strncpy(drvinfo->bus_info, pci_name(pf->pdev),
> +		sizeof(drvinfo->bus_info));
> +	if (vsi == pf->vsi[pf->lan_vsi])
> +		drvinfo->n_stats = I40E_PF_STATS_LEN;
> +	else
> +		drvinfo->n_stats = I40E_VSI_STATS_LEN;
> +	drvinfo->testinfo_len = I40E_TEST_LEN;
> +	drvinfo->regdump_len = i40e_get_regs_len(netdev);

Do not set n_stats or *_len; the ethtool core does that for you.

> +}
[...]
> +static int i40e_set_phys_id(struct net_device *netdev,
> +			    enum ethtool_phys_id_state state)
> +{
> +	struct i40e_netdev_priv *np = netdev_priv(netdev);
> +	struct i40e_pf *pf = np->vsi->back;
> +	struct i40e_hw *hw = &pf->hw;
> +	int blink_freq = 2;
> +	static u32 led_status;

Ugh, no.

Since ETHTOOL_PHYSID drops the RTNL between calls to set_phys_id, it's
possible to invoke it on multiple devices at the same time...

> +	switch (state) {
> +	case ETHTOOL_ID_ACTIVE:
> +		led_status = i40e_led_get(hw);
> +		return blink_freq;
> +	case ETHTOOL_ID_ON:
> +		i40e_led_set(hw, 0xF);
> +		break;
> +	case ETHTOOL_ID_OFF:
> +		i40e_led_set(hw, 0x0);
> +		break;
> +	case ETHTOOL_ID_INACTIVE:
> +		i40e_led_set(hw, led_status);
> +		break;
> +	}
> +
> +	return 0;
> +}
[...]

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
