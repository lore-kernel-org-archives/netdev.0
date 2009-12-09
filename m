From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC PATCH 10/12] ixgbevf: Driver main and ethool interface
	module and main header
Date: Wed, 09 Dec 2009 17:57:14 +0000
Message-ID: <1260381434.2786.47.camel@achroite.uk.solarflarecom.com>
References: <20091208221258.28373.16663.stgit@localhost.localdomain>
	 <20091208221612.28373.74512.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Greg Rose <gregory.v.rose@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:33911 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753617AbZLIR5Q convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Dec 2009 12:57:16 -0500
In-Reply-To: <20091208221612.28373.74512.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I had a look at the ethtool part of this:

On Tue, 2009-12-08 at 14:16 -0800, Jeff Kirsher wrote:
[...]
> +#ifdef SIOCETHTOOL

What?!

> +#include <linux/uaccess.h>
> +
> +#include "ixgbevf.h"
> +
> +#ifndef ETH_GSTRING_LEN
> +#define ETH_GSTRING_LEN 32
> +#endif

You can omit most of these #ifdefs in the in-tree driver.

[...]
> +static int ixgbevf_get_settings(struct net_device *netdev,
> +				struct ethtool_cmd *ecmd)
> +{
> +	struct ixgbevf_adapter *adapter =3D netdev_priv(netdev);
> +	struct ixgbe_hw *hw =3D &adapter->hw;
> +	u32 link_speed =3D 0;
> +	bool link_up;
> +
> +	ecmd->supported =3D SUPPORTED_10000baseT_Full;

Not likely...

> +	ecmd->autoneg =3D AUTONEG_DISABLE;
> +	ecmd->transceiver =3D XCVR_DUMMY1;
> +	ecmd->port =3D -1;
> +
> +	if (!in_interrupt()) {

This is bogus; get_settings() must be called in process context with
rtnl_lock held.  (If this is a workaround for the old bonding driver
locking bugs, it doesn't belong in an in-tree driver.)

> +		hw->mac.ops.check_link(hw, &link_speed, &link_up, false);
> +	} else {
> +		/*
> +		 * this is a special workaround for cases where bonding
> +		 * calls this routine from interrupt context
> +		 */
> +		link_speed =3D adapter->link_speed;
> +		link_up =3D adapter->link_up;
> +	}
> +
> +	if (link_up) {
> +		ecmd->speed =3D (link_speed =3D=3D IXGBE_LINK_SPEED_10GB_FULL) ?
> +			       SPEED_10000 : SPEED_1000;
> +		ecmd->duplex =3D DUPLEX_FULL;
> +	} else {
> +		ecmd->speed =3D -1;
> +		ecmd->duplex =3D -1;
> +	}
> +
> +	return 0;
> +}
> +
> +static int ixgbevf_set_settings(struct net_device *netdev,
> +				struct ethtool_cmd *ecmd)
> +{
> +	return -EINVAL;
> +}

Should be -EOPNOTSUPP; the settings may or may not be valid.  In fact,
you should just not fill in the set_settings operation.

[...]
> +static u32 ixgbevf_get_tx_csum(struct net_device *netdev)
> +{
> +	return (netdev->features & NETIF_F_IP_CSUM) !=3D 0;
> +}

This is redundant; the default implementation does the right thing.

> +static int ixgbevf_set_tx_csum(struct net_device *netdev, u32 data)
> +{
> +	if (data)
> +#ifdef NETIF_F_IPV6_CSUM
> +		netdev->features |=3D (NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM);
> +	else
> +		netdev->features &=3D ~(NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM);
> +#else
> +		netdev->features |=3D NETIF_F_IP_CSUM;
> +	else
> +		netdev->features &=3D ~NETIF_F_IP_CSUM;
> +#endif
> +
> +	return 0;
> +}

Use ethtool_op_set_tx_ipv6_csum.

> +#undef ethtool_op_set_tso
> +#ifdef NETIF_F_TSO
> +static int ixgbevf_set_tso(struct net_device *netdev, u32 data)
> +{
> +#ifndef HAVE_NETDEV_VLAN_FEATURES
> +	struct ixgbevf_adapter *adapter =3D netdev_priv(netdev);
> +#endif /* HAVE_NETDEV_VLAN_FEATURES */
> +	if (data) {
> +		netdev->features |=3D NETIF_F_TSO;
> +#ifdef NETIF_F_TSO6
> +		netdev->features |=3D NETIF_F_TSO6;
> +#endif
> +	} else {
> +		netif_tx_stop_all_queues(netdev);
> +		netdev->features &=3D ~NETIF_F_TSO;
> +#ifdef NETIF_F_TSO6
> +		netdev->features &=3D ~NETIF_F_TSO6;
> +#endif
> +#ifndef HAVE_NETDEV_VLAN_FEATURES
> +#ifdef NETIF_F_HW_VLAN_TX
> +		/* disable TSO on all VLANs if they're present */
> +		if (adapter->vlgrp) {
> +			int i;
> +			struct net_device *v_netdev;
> +			for (i =3D 0; i < VLAN_GROUP_ARRAY_LEN; i++) {
> +				v_netdev =3D
> +				       vlan_group_get_device(adapter->vlgrp, i);
> +				if (v_netdev) {
> +					v_netdev->features &=3D ~NETIF_F_TSO;
> +#ifdef NETIF_F_TSO6
> +					v_netdev->features &=3D ~NETIF_F_TSO6;
> +#endif
> +					vlan_group_set_device(adapter->vlgrp, i,
> +							      v_netdev);
> +				}
> +			}
> +		}
> +#endif
> +#endif /* HAVE_NETDEV_VLAN_FEATURES */
> +		netif_tx_start_all_queues(netdev);
> +	}
> +	return 0;
> +}
> +#endif /* NETIF_F_TSO */

Ew.

[...]
> +static int ixgbevf_get_regs_len(struct net_device *netdev)
> +{
> +#define IXGBE_REGS_LEN  45
> +	return IXGBE_REGS_LEN * sizeof(u32);
> +}
=EF=BB=BF> +
> +#define IXGBE_GET_STAT(_A_, _R_) (_A_->stats._R_)
> +
> +static char *ixgbevf_reg_names[] =3D {
> +	"IXGBE_VFCTRL",
> +	"IXGBE_VFSTATUS",
[...]

If you move ixgbevf_get_regs_len() after ixgbevf_reg_names() you can
then use ARRAY_SIZE() instead of having to keep IXGBE_REGS_LEN in sync
manually.

> +static int ixgbevf_get_eeprom(struct net_device *netdev,
> +			      struct ethtool_eeprom *eeprom, u8 *bytes)
> +{
> +	return -EOPNOTSUPP;
> +}
> +
> +static int ixgbevf_set_eeprom(struct net_device *netdev,
> +			      struct ethtool_eeprom *eeprom, u8 *bytes)
> +{
> +	return -EOPNOTSUPP;
> +}

Just don't fill in the operations.

> +static void ixgbevf_get_drvinfo(struct net_device *netdev,
> +				struct ethtool_drvinfo *drvinfo)
> +{
> +	struct ixgbevf_adapter *adapter =3D netdev_priv(netdev);
> +
> +	strncpy(drvinfo->driver, ixgbevf_driver_name, 32);
> +	strncpy(drvinfo->version, ixgbevf_driver_version, 32);
> +
> +	strncpy(drvinfo->fw_version, "N/A", 4);
> +	strncpy(drvinfo->bus_info, pci_name(adapter->pdev), 32);

These are expected to be null-terminated, so use strlcpy().

> +	drvinfo->n_stats =3D IXGBEVF_STATS_LEN;
> +	drvinfo->testinfo_len =3D IXGBE_TEST_LEN;
> +	drvinfo->regdump_len =3D ixgbevf_get_regs_len(netdev);

The ethtool core initialises these.

[...]
> +static int ixgbevf_link_test(struct ixgbevf_adapter *adapter, u64
> *data)
> +{
> +	struct ixgbe_hw *hw =3D &adapter->hw;
> +	bool link_up;
> +	u32 link_speed =3D 0;
> +	*data =3D 0;
> +
> +	hw->mac.ops.check_link(hw, &link_speed, &link_up, true);
> +	if (link_up)
> +		return *data;
> +	else
> +		*data =3D 1;
> +	return *data;

This is just messy.

[...]
> +static u32 ixgbevf_get_link(struct net_device *dev)
> +{
> +	return netif_carrier_ok(dev) ? 1 : 0;
> +}
[...]

Use ethtool_op_get_link().

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

