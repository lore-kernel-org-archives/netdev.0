From: Simon Horman <horms@verge.net.au>
Subject: Re: [RFC PATCH v2 04/12] ixgbevf: Driver main and ethool interface
 module and main header
Date: Mon, 21 Dec 2009 18:59:54 +1100
Message-ID: <20091221075951.GD21782@verge.net.au>
References: <20091218225043.10698.58897.stgit@localhost.localdomain>
 <20091218225158.10698.67726.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Greg Rose <gregory.v.rose@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:34508 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751557AbZLUH75 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Dec 2009 02:59:57 -0500
Content-Disposition: inline
In-Reply-To: <20091218225158.10698.67726.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 18, 2009 at 02:51:58PM -0800, Jeff Kirsher wrote:
> From: Greg Rose <gregory.v.rose@intel.com>
> 
> These modules and header contain the Linux OS network interface code and core
> interrupt and network send/receive handlers.
> 
> Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
> 
>  drivers/net/ixgbevf/ethtool.c      |  718 +++++++
>  drivers/net/ixgbevf/ixgbevf.h      |  318 +++
>  drivers/net/ixgbevf/ixgbevf_main.c | 3594 ++++++++++++++++++++++++++++++++++++
>  3 files changed, 4630 insertions(+), 0 deletions(-)
>  create mode 100644 drivers/net/ixgbevf/ethtool.c
>  create mode 100644 drivers/net/ixgbevf/ixgbevf.h
>  create mode 100644 drivers/net/ixgbevf/ixgbevf_main.c
> 
> diff --git a/drivers/net/ixgbevf/ethtool.c b/drivers/net/ixgbevf/ethtool.c
> new file mode 100644
> index 0000000..6cf0110
> --- /dev/null
> +++ b/drivers/net/ixgbevf/ethtool.c
> @@ -0,0 +1,718 @@
> +/*******************************************************************************
> +
> +  Intel 82599 Virtual Function driver
> +  Copyright(c) 1999 - 2009 Intel Corporation.
> +
> +  This program is free software; you can redistribute it and/or modify it
> +  under the terms and conditions of the GNU General Public License,
> +  version 2, as published by the Free Software Foundation.
> +
> +  This program is distributed in the hope it will be useful, but WITHOUT
> +  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
> +  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
> +  more details.
> +
> +  You should have received a copy of the GNU General Public License along with
> +  this program; if not, write to the Free Software Foundation, Inc.,
> +  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
> +
> +  The full GNU General Public License is included in this distribution in
> +  the file called "COPYING".
> +
> +  Contact Information:
> +  e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
> +  Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
> +
> +*******************************************************************************/
> +
> +/* ethtool support for ixgbevf */
> +
> +#include <linux/types.h>
> +#include <linux/module.h>
> +#include <linux/pci.h>
> +#include <linux/netdevice.h>
> +#include <linux/ethtool.h>
> +#include <linux/vmalloc.h>
> +#include <linux/if_vlan.h>
> +#include <linux/uaccess.h>
> +
> +#include "ixgbevf.h"
> +
> +#define IXGBE_ALL_RAR_ENTRIES 16
> +
> +#ifdef ETHTOOL_GSTATS
> +struct ixgbe_stats {
> +	char stat_string[ETH_GSTRING_LEN];
> +	int sizeof_stat;
> +	int stat_offset;
> +	int base_stat_offset;
> +};
> +
> +#define IXGBEVF_STAT(m, b)  sizeof(((struct ixgbevf_adapter *)0)->m), \
> +			    offsetof(struct ixgbevf_adapter, m),      \
> +			    offsetof(struct ixgbevf_adapter, b)
> +static struct ixgbe_stats ixgbe_gstrings_stats[] = {
> +	{"rx_packets", IXGBEVF_STAT(stats.vfgprc, stats.base_vfgprc)},
> +	{"tx_packets", IXGBEVF_STAT(stats.vfgptc, stats.base_vfgptc)},
> +	{"rx_bytes", IXGBEVF_STAT(stats.vfgorc, stats.base_vfgorc)},
> +	{"tx_bytes", IXGBEVF_STAT(stats.vfgotc, stats.base_vfgotc)},
> +	{"tx_busy", IXGBEVF_STAT(tx_busy, zero_base)},
> +	{"multicast", IXGBEVF_STAT(stats.vfmprc, stats.base_vfmprc)},
> +	{"rx_csum_offload_good", IXGBEVF_STAT(hw_csum_rx_good, zero_base)},
> +	{"rx_csum_offload_errors", IXGBEVF_STAT(hw_csum_rx_error, zero_base)},
> +	{"tx_csum_offload_ctxt", IXGBEVF_STAT(hw_csum_tx_good, zero_base)},
> +	{"rx_header_split", IXGBEVF_STAT(rx_hdr_split, zero_base)},
> +};
> +
> +#define IXGBE_QUEUE_STATS_LEN 0
> +#define IXGBE_GLOBAL_STATS_LEN	ARRAY_SIZE(ixgbe_gstrings_stats)
> +
> +#define IXGBEVF_STATS_LEN (IXGBE_GLOBAL_STATS_LEN + IXGBE_QUEUE_STATS_LEN)
> +#endif /* ETHTOOL_GSTATS */
> +#ifdef ETHTOOL_TEST
> +static const char ixgbe_gstrings_test[][ETH_GSTRING_LEN] = {
> +	"Register test  (offline)",
> +	"Link test   (on/offline)"
> +};
> +#define IXGBE_TEST_LEN (sizeof(ixgbe_gstrings_test) / ETH_GSTRING_LEN)
> +#endif /* ETHTOOL_TEST */
> +
> +static int ixgbevf_get_settings(struct net_device *netdev,
> +				struct ethtool_cmd *ecmd)
> +{
> +	struct ixgbevf_adapter *adapter = netdev_priv(netdev);
> +	struct ixgbe_hw *hw = &adapter->hw;
> +	u32 link_speed = 0;
> +	bool link_up;
> +
> +	ecmd->supported = SUPPORTED_10000baseT_Full;
> +	ecmd->autoneg = AUTONEG_DISABLE;
> +	ecmd->transceiver = XCVR_DUMMY1;
> +	ecmd->port = -1;
> +
> +	hw->mac.ops.check_link(hw, &link_speed, &link_up, false);
> +
> +	if (link_up) {
> +		ecmd->speed = (link_speed == IXGBE_LINK_SPEED_10GB_FULL) ?
> +			       SPEED_10000 : SPEED_1000;
> +		ecmd->duplex = DUPLEX_FULL;
> +	} else {
> +		ecmd->speed = -1;
> +		ecmd->duplex = -1;
> +	}
> +
> +	return 0;
> +}
> +
> +static u32 ixgbevf_get_rx_csum(struct net_device *netdev)
> +{
> +	struct ixgbevf_adapter *adapter = netdev_priv(netdev);
> +	return adapter->flags & IXGBE_FLAG_RX_CSUM_ENABLED;
> +}
> +
> +static int ixgbevf_set_rx_csum(struct net_device *netdev, u32 data)
> +{
> +	struct ixgbevf_adapter *adapter = netdev_priv(netdev);
> +	if (data)
> +		adapter->flags |= IXGBE_FLAG_RX_CSUM_ENABLED;
> +	else
> +		adapter->flags &= ~IXGBE_FLAG_RX_CSUM_ENABLED;
> +
> +	if (netif_running(netdev)) {
> +		if (!adapter->dev_closed)
> +			ixgbevf_reinit_locked(adapter);
> +	} else {
> +		ixgbevf_reset(adapter);
> +	}
> +
> +	return 0;
> +}
> +
> +static int ixgbevf_set_tso(struct net_device *netdev, u32 data)
> +{
> +	if (data) {
> +		netdev->features |= NETIF_F_TSO;
> +		netdev->features |= NETIF_F_TSO6;
> +	} else {
> +		netif_tx_stop_all_queues(netdev);
> +		netdev->features &= ~NETIF_F_TSO;
> +		netdev->features &= ~NETIF_F_TSO6;
> +		netif_tx_start_all_queues(netdev);
> +	}
> +	return 0;
> +}
> +
> +static u32 ixgbevf_get_msglevel(struct net_device *netdev)
> +{
> +	struct ixgbevf_adapter *adapter = netdev_priv(netdev);
> +	return adapter->msg_enable;
> +}
> +
> +static void ixgbevf_set_msglevel(struct net_device *netdev, u32 data)
> +{
> +	struct ixgbevf_adapter *adapter = netdev_priv(netdev);
> +	adapter->msg_enable = data;
> +}
> +
> +#define IXGBE_GET_STAT(_A_, _R_) (_A_->stats._R_)
> +
> +static char *ixgbevf_reg_names[] = {
> +	"IXGBE_VFCTRL",
> +	"IXGBE_VFSTATUS",
> +	"IXGBE_VFLINKS",
> +	"IXGBE_VFRXMEMWRAP",
> +	"IXGBE_VFRTIMER",
> +	"IXGBE_VTEICR",
> +	"IXGBE_VTEICS",
> +	"IXGBE_VTEIMS",
> +	"IXGBE_VTEIMC",
> +	"IXGBE_VTEIAC",
> +	"IXGBE_VTEIAM",
> +	"IXGBE_VTEITR",
> +	"IXGBE_VTIVAR",
> +	"IXGBE_VTIVAR_MISC",
> +	"IXGBE_VFRDBAL0",
> +	"IXGBE_VFRDBAL1",
> +	"IXGBE_VFRDBAH0",
> +	"IXGBE_VFRDBAH1",
> +	"IXGBE_VFRDLEN0",
> +	"IXGBE_VFRDLEN1",
> +	"IXGBE_VFRDH0",
> +	"IXGBE_VFRDH1",
> +	"IXGBE_VFRDT0",
> +	"IXGBE_VFRDT1",
> +	"IXGBE_VFRXDCTL0",
> +	"IXGBE_VFRXDCTL1",
> +	"IXGBE_VFSRRCTL0",
> +	"IXGBE_VFSRRCTL1",
> +	"IXGBE_VFPSRTYPE",
> +	"IXGBE_VFTDBAL0",
> +	"IXGBE_VFTDBAL1",
> +	"IXGBE_VFTDBAH0",
> +	"IXGBE_VFTDBAH1",
> +	"IXGBE_VFTDLEN0",
> +	"IXGBE_VFTDLEN1",
> +	"IXGBE_VFTDH0",
> +	"IXGBE_VFTDH1",
> +	"IXGBE_VFTDT0",
> +	"IXGBE_VFTDT1",
> +	"IXGBE_VFTXDCTL0",
> +	"IXGBE_VFTXDCTL1",
> +	"IXGBE_VFTDWBAL0",
> +	"IXGBE_VFTDWBAL1",
> +	"IXGBE_VFTDWBAH0",
> +	"IXGBE_VFTDWBAH1"
> +};
> +
> +
> +static int ixgbevf_get_regs_len(struct net_device *netdev)
> +{
> +	return (ARRAY_SIZE(ixgbevf_reg_names)) * sizeof(u32);
> +}
> +
> +static void ixgbevf_get_regs(struct net_device *netdev,
> +			     struct ethtool_regs *regs,
> +			     void *p)
> +{
> +	struct ixgbevf_adapter *adapter = netdev_priv(netdev);
> +	struct ixgbe_hw *hw = &adapter->hw;
> +	u32 *regs_buff = p;
> +	u32 regs_len = ixgbevf_get_regs_len(netdev);
> +	u8 i;
> +
> +	memset(p, 0, regs_len);
> +
> +	regs->version = (1 << 24) | hw->revision_id << 16 | hw->device_id;
> +
> +	/* General Registers */
> +	regs_buff[0] = IXGBE_READ_REG(hw, IXGBE_VFCTRL);
> +	regs_buff[1] = IXGBE_READ_REG(hw, IXGBE_VFSTATUS);
> +	regs_buff[2] = IXGBE_READ_REG(hw, IXGBE_VFLINKS);
> +	regs_buff[3] = IXGBE_READ_REG(hw, IXGBE_VFRXMEMWRAP);
> +	regs_buff[4] = IXGBE_READ_REG(hw, IXGBE_VFRTIMER);
> +
> +	/* Interrupt */
> +	/* don't read EICR because it can clear interrupt causes, instead
> +	 * read EICS which is a shadow but doesn't clear EICR */
> +	regs_buff[5] = IXGBE_READ_REG(hw, IXGBE_VTEICS);
> +	regs_buff[6] = IXGBE_READ_REG(hw, IXGBE_VTEICS);
> +	regs_buff[7] = IXGBE_READ_REG(hw, IXGBE_VTEIMS);
> +	regs_buff[8] = IXGBE_READ_REG(hw, IXGBE_VTEIMC);
> +	regs_buff[9] = IXGBE_READ_REG(hw, IXGBE_VTEIAC);
> +	regs_buff[10] = IXGBE_READ_REG(hw, IXGBE_VTEIAM);
> +	regs_buff[11] = IXGBE_READ_REG(hw, IXGBE_VTEITR(0));
> +	regs_buff[12] = IXGBE_READ_REG(hw, IXGBE_VTIVAR(0));
> +	regs_buff[13] = IXGBE_READ_REG(hw, IXGBE_VTIVAR_MISC);
> +
> +	/* Receive DMA */
> +	for (i = 0; i < 2; i++)
> +		regs_buff[14 + i] = IXGBE_READ_REG(hw, IXGBE_VFRDBAL(i));
> +	for (i = 0; i < 2; i++)
> +		regs_buff[16 + i] = IXGBE_READ_REG(hw, IXGBE_VFRDBAH(i));
> +	for (i = 0; i < 2; i++)
> +		regs_buff[18 + i] = IXGBE_READ_REG(hw, IXGBE_VFRDLEN(i));
> +	for (i = 0; i < 2; i++)
> +		regs_buff[20 + i] = IXGBE_READ_REG(hw, IXGBE_VFRDH(i));
> +	for (i = 0; i < 2; i++)
> +		regs_buff[22 + i] = IXGBE_READ_REG(hw, IXGBE_VFRDT(i));
> +	for (i = 0; i < 2; i++)
> +		regs_buff[24 + i] = IXGBE_READ_REG(hw, IXGBE_VFRXDCTL(i));
> +	for (i = 0; i < 2; i++)
> +		regs_buff[26 + i] = IXGBE_READ_REG(hw, IXGBE_VFSRRCTL(i));
> +
> +	/* Receive */
> +	regs_buff[28] = IXGBE_READ_REG(hw, IXGBE_VFPSRTYPE);
> +
> +	/* Transmit */
> +	for (i = 0; i < 2; i++)
> +		regs_buff[29 + i] = IXGBE_READ_REG(hw, IXGBE_VFTDBAL(i));
> +	for (i = 0; i < 2; i++)
> +		regs_buff[31 + i] = IXGBE_READ_REG(hw, IXGBE_VFTDBAH(i));
> +	for (i = 0; i < 2; i++)
> +		regs_buff[33 + i] = IXGBE_READ_REG(hw, IXGBE_VFTDLEN(i));
> +	for (i = 0; i < 2; i++)
> +		regs_buff[35 + i] = IXGBE_READ_REG(hw, IXGBE_VFTDH(i));
> +	for (i = 0; i < 2; i++)
> +		regs_buff[37 + i] = IXGBE_READ_REG(hw, IXGBE_VFTDT(i));
> +	for (i = 0; i < 2; i++)
> +		regs_buff[39 + i] = IXGBE_READ_REG(hw, IXGBE_VFTXDCTL(i));
> +	for (i = 0; i < 2; i++)
> +		regs_buff[41 + i] = IXGBE_READ_REG(hw, IXGBE_VFTDWBAL(i));
> +	for (i = 0; i < 2; i++)
> +		regs_buff[43 + i] = IXGBE_READ_REG(hw, IXGBE_VFTDWBAH(i));
> +
> +	for (i = 0; i < regs_len; i++)
> +		printk(KERN_INFO "%s\t%8.8x\n",
> +		       ixgbevf_reg_names[i], regs_buff[i]);
> +}
> +
> +static void ixgbevf_get_drvinfo(struct net_device *netdev,
> +				struct ethtool_drvinfo *drvinfo)
> +{
> +	struct ixgbevf_adapter *adapter = netdev_priv(netdev);
> +
> +	strlcpy(drvinfo->driver, ixgbevf_driver_name, 32);
> +	strlcpy(drvinfo->version, ixgbevf_driver_version, 32);
> +
> +	strlcpy(drvinfo->fw_version, "N/A", 4);
> +	strlcpy(drvinfo->bus_info, pci_name(adapter->pdev), 32);
> +}
> +
> +static void ixgbevf_get_ringparam(struct net_device *netdev,
> +				  struct ethtool_ringparam *ring)
> +{
> +	struct ixgbevf_adapter *adapter = netdev_priv(netdev);
> +	struct ixgbevf_ring *tx_ring = adapter->tx_ring;
> +	struct ixgbevf_ring *rx_ring = adapter->rx_ring;
> +
> +	ring->rx_max_pending = IXGBEVF_MAX_RXD;
> +	ring->tx_max_pending = IXGBEVF_MAX_TXD;
> +	ring->rx_mini_max_pending = 0;
> +	ring->rx_jumbo_max_pending = 0;
> +	ring->rx_pending = rx_ring->count;
> +	ring->tx_pending = tx_ring->count;
> +	ring->rx_mini_pending = 0;
> +	ring->rx_jumbo_pending = 0;
> +}
> +
> +static int ixgbevf_set_ringparam(struct net_device *netdev,
> +				 struct ethtool_ringparam *ring)
> +{
> +	struct ixgbevf_adapter *adapter = netdev_priv(netdev);
> +	struct ixgbevf_ring *tx_ring, *rx_ring;
> +	int i, err;
> +	u32 new_rx_count, new_tx_count;
> +	bool need_update = false;
> +
> +	if ((ring->rx_mini_pending) || (ring->rx_jumbo_pending))
> +		return -EINVAL;
> +
> +	new_rx_count = max(ring->rx_pending, (u32)IXGBEVF_MIN_RXD);
> +	new_rx_count = min(new_rx_count, (u32)IXGBEVF_MAX_RXD);
> +	new_rx_count = ALIGN(new_rx_count, IXGBE_REQ_RX_DESCRIPTOR_MULTIPLE);
> +
> +	new_tx_count = max(ring->tx_pending, (u32)IXGBEVF_MIN_TXD);
> +	new_tx_count = min(new_tx_count, (u32)IXGBEVF_MAX_TXD);
> +	new_tx_count = ALIGN(new_tx_count, IXGBE_REQ_TX_DESCRIPTOR_MULTIPLE);
> +
> +	if ((new_tx_count == adapter->tx_ring->count) &&
> +	    (new_rx_count == adapter->rx_ring->count)) {
> +		/* nothing to do */
> +		return 0;
> +	}
> +
> +	while (test_and_set_bit(__IXGBEVF_RESETTING, &adapter->state))
> +		msleep(1);
> +
> +	tx_ring = kcalloc(adapter->num_tx_queues,
> +			       sizeof(struct ixgbevf_ring), GFP_KERNEL);
> +	if (!tx_ring) {
> +		err = -ENOMEM;
> +		goto err_setup;
> +	}
> +
> +	if (new_tx_count != adapter->tx_ring_count) {
> +		memcpy(tx_ring, adapter->tx_ring,
> +		       adapter->num_tx_queues * sizeof(struct ixgbevf_ring));
> +		for (i = 0; i < adapter->num_tx_queues; i++) {
> +			tx_ring[i].count = new_tx_count;
> +			err = ixgbevf_setup_tx_resources(adapter,
> +							 &tx_ring[i]);
> +			if (err) {
> +				while (i) {
> +					i--;
> +					ixgbevf_free_tx_resources(adapter,
> +								  &tx_ring[i]);
> +				}
> +				goto err_setup;
> +			}
> +			tx_ring[i].v_idx = adapter->tx_ring[i].v_idx;
> +		}
> +		need_update = true;
> +	}

> +
> +	rx_ring = kcalloc(adapter->num_rx_queues,
> +			       sizeof(struct ixgbevf_ring), GFP_KERNEL);
> +	if ((!rx_ring) && (need_update)) {
> +		for (i = 0; i < adapter->num_tx_queues; i++)
> +			ixgbevf_free_tx_resources(adapter, &tx_ring[i]);
> +		kfree(tx_ring);
> +		err = -ENOMEM;
> +		goto err_setup;
> +	}
> +
> +	if (new_rx_count != adapter->rx_ring_count) {
> +		memcpy(rx_ring, adapter->rx_ring,
> +		       adapter->num_rx_queues * sizeof(struct ixgbevf_ring));
> +		for (i = 0; i < adapter->num_rx_queues; i++) {
> +			rx_ring[i].count = new_rx_count;
> +			err = ixgbevf_setup_rx_resources(adapter,
> +							 &rx_ring[i]);
> +			if (err) {
> +				while (i) {
> +					i--;
> +					ixgbevf_free_rx_resources(adapter,
> +								  &rx_ring[i]);
> +				}
> +				goto err_setup;

				Are some calls to ixgbevf_free_tx_resources()
				needed here? Perhaps the ones for
				on rx_ring failure could be moved down
				to an err_tx_clear or similar?
				(sorry for the shoddy name)


> +			}
> +			rx_ring[i].v_idx = adapter->rx_ring[i].v_idx;
> +		}
> +		need_update = true;
> +	}
> +
> +	/* if rings need to be updated, here's the place to do it in one shot */
> +	if (need_update) {
> +		if (netif_running(netdev))
> +			ixgbevf_down(adapter);
> +
> +		/* tx */
> +		if (new_tx_count != adapter->tx_ring_count) {
> +			kfree(adapter->tx_ring);
> +			adapter->tx_ring = tx_ring;
> +			tx_ring = NULL;
> +			adapter->tx_ring_count = new_tx_count;
> +		}
> +
> +		/* rx */
> +		if (new_rx_count != adapter->rx_ring_count) {
> +			kfree(adapter->rx_ring);
> +			adapter->rx_ring = rx_ring;
> +			rx_ring = NULL;
> +			adapter->rx_ring_count = new_rx_count;
> +		}
> +	}

	Can tx_ring and rx_ring leak here?
> +
> +	/* success! */
> +	err = 0;
> +	if (netif_running(netdev))
> +		ixgbevf_up(adapter);
> +
> +err_setup:
> +	clear_bit(__IXGBEVF_RESETTING, &adapter->state);
> +	return err;
> +}

Dinner calls...
