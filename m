From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 3/8] i40e: driver ethtool core
Date: Thu, 13 Jun 2013 20:55:17 -0700
Message-ID: <1371182122-26629-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1371182122-26629-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Shannon Nelson <shannon.nelson@intel.com>,
	PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>,
	e1000-devel@lists.sourceforge.net,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:14943 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751061Ab3FNDzm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Jun 2013 23:55:42 -0400
In-Reply-To: <1371182122-26629-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

This patch contains the ethtool interface and implementation.

The goal in this patch series is minimal functionality while not
including much in the way of "set support."

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
CC: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
CC: e1000-devel@lists.sourceforge.net
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 1198 ++++++++++++++++++++++++
 1 file changed, 1198 insertions(+)
 create mode 100644 drivers/net/ethernet/intel/i40e/i40e_ethtool.c

diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
new file mode 100644
index 0000000..fe4e9dc
--- /dev/null
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -0,0 +1,1198 @@
+/*******************************************************************************
+
+  Intel Ethernet Controller XL710 Family Linux Driver
+  Copyright(c) 2013 Intel Corporation.
+
+  This program is free software; you can redistribute it and/or modify it
+  under the terms and conditions of the GNU General Public License,
+  version 2, as published by the Free Software Foundation.
+
+  This program is distributed in the hope it will be useful, but WITHOUT
+  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+  more details.
+
+  You should have received a copy of the GNU General Public License along with
+  this program; if not, write to the Free Software Foundation, Inc.,
+  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
+
+  The full GNU General Public License is included in this distribution in
+  the file called "COPYING".
+
+  Contact Information:
+  e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
+  Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
+
+*******************************************************************************/
+
+/* ethtool support for i40e */
+
+#include "i40e.h"
+#include "i40e_diag.h"
+
+struct i40e_stats {
+	char stat_string[ETH_GSTRING_LEN];
+	int sizeof_stat;
+	int stat_offset;
+};
+
+#define I40E_STAT(_type, _name, _stat) { \
+	.stat_string = _name, \
+	.sizeof_stat = FIELD_SIZEOF(_type, _stat), \
+	.stat_offset = offsetof(_type, _stat) \
+}
+#define I40E_NETDEV_STAT(_net_stat) \
+		I40E_STAT(struct net_device_stats, #_net_stat, _net_stat)
+#define I40E_PF_STAT(_name, _stat) \
+		I40E_STAT(struct i40e_pf, _name, _stat)
+#define I40E_VSI_STAT(_name, _stat) \
+		I40E_STAT(struct i40e_vsi, _name, _stat)
+
+static const struct i40e_stats i40e_gstrings_net_stats[] = {
+	I40E_NETDEV_STAT(rx_packets),
+	I40E_NETDEV_STAT(tx_packets),
+	I40E_NETDEV_STAT(rx_bytes),
+	I40E_NETDEV_STAT(tx_bytes),
+	I40E_NETDEV_STAT(rx_errors),
+	I40E_NETDEV_STAT(tx_errors),
+	I40E_NETDEV_STAT(rx_dropped),
+	I40E_NETDEV_STAT(tx_dropped),
+	I40E_NETDEV_STAT(multicast),
+	I40E_NETDEV_STAT(collisions),
+	I40E_NETDEV_STAT(rx_length_errors),
+	I40E_NETDEV_STAT(rx_over_errors),
+	I40E_NETDEV_STAT(rx_crc_errors),
+	I40E_NETDEV_STAT(rx_frame_errors),
+	I40E_NETDEV_STAT(rx_fifo_errors),
+	I40E_NETDEV_STAT(tx_aborted_errors),
+	I40E_NETDEV_STAT(tx_carrier_errors),
+	I40E_NETDEV_STAT(tx_fifo_errors),
+	I40E_NETDEV_STAT(tx_heartbeat_errors),
+	I40E_NETDEV_STAT(tx_window_errors),
+	I40E_NETDEV_STAT(rx_compressed),
+	I40E_NETDEV_STAT(tx_compressed),
+};
+
+static struct i40e_stats i40e_gstrings_stats[] = {
+	I40E_PF_STAT("rx_bytes", stats.eth.rx_bytes),
+	I40E_PF_STAT("tx_bytes", stats.eth.tx_bytes),
+	I40E_PF_STAT("rx_errors", stats.eth.rx_errors),
+	I40E_PF_STAT("tx_errors", stats.eth.tx_errors),
+	I40E_PF_STAT("rx_dropped", stats.eth.rx_discards),
+	I40E_PF_STAT("tx_dropped", stats.eth.tx_discards),
+	I40E_PF_STAT("tx_dropped_link_down", stats.tx_dropped_link_down),
+	I40E_PF_STAT("crc_errors", stats.crc_errors),
+	I40E_PF_STAT("illegal_bytes", stats.illegal_bytes),
+	I40E_PF_STAT("mac_local_faults", stats.mac_local_faults),
+	I40E_PF_STAT("mac_remote_faults", stats.mac_remote_faults),
+	I40E_PF_STAT("rx_length_errors", stats.rx_length_errors),
+	I40E_PF_STAT("link_xon_rx", stats.link_xon_rx),
+	I40E_PF_STAT("link_xoff_rx", stats.link_xoff_rx),
+	I40E_PF_STAT("link_xon_tx", stats.link_xon_tx),
+	I40E_PF_STAT("link_xoff_tx", stats.link_xoff_tx),
+	I40E_PF_STAT("rx_size_64", stats.rx_size_64),
+	I40E_PF_STAT("rx_size_127", stats.rx_size_127),
+	I40E_PF_STAT("rx_size_255", stats.rx_size_255),
+	I40E_PF_STAT("rx_size_511", stats.rx_size_511),
+	I40E_PF_STAT("rx_size_1023", stats.rx_size_1023),
+	I40E_PF_STAT("rx_size_big", stats.rx_size_big),
+	I40E_PF_STAT("tx_size_64", stats.tx_size_64),
+	I40E_PF_STAT("tx_size_127", stats.tx_size_127),
+	I40E_PF_STAT("tx_size_255", stats.tx_size_255),
+	I40E_PF_STAT("tx_size_511", stats.tx_size_511),
+	I40E_PF_STAT("tx_size_1023", stats.tx_size_1023),
+	I40E_PF_STAT("tx_size_big", stats.tx_size_big),
+	I40E_PF_STAT("rx_undersize", stats.rx_undersize),
+	I40E_PF_STAT("rx_fragments", stats.rx_fragments),
+	I40E_PF_STAT("rx_oversize", stats.rx_oversize),
+	I40E_PF_STAT("rx_jabber", stats.rx_jabber),
+	I40E_PF_STAT("VF admin queue requests", vf_aq_requests),
+};
+
+#define I40E_QUEUE_STATS_LEN \
+  ((((struct i40e_netdev_priv *)netdev_priv(netdev))->vsi->num_queue_pairs + \
+    ((struct i40e_netdev_priv *)netdev_priv(netdev))->vsi->num_queue_pairs) * 2)
+#define I40E_GLOBAL_STATS_LEN	ARRAY_SIZE(i40e_gstrings_stats)
+#define I40E_NETDEV_STATS_LEN   ARRAY_SIZE(i40e_gstrings_net_stats)
+#define I40E_VSI_STATS_LEN (I40E_NETDEV_STATS_LEN + \
+			    I40E_QUEUE_STATS_LEN)
+#define I40E_PFC_STATS_LEN ( \
+		(FIELD_SIZEOF(struct i40e_pf, stats.priority_xoff_rx) + \
+		 FIELD_SIZEOF(struct i40e_pf, stats.priority_xon_rx) + \
+		 FIELD_SIZEOF(struct i40e_pf, stats.priority_xoff_tx) + \
+		 FIELD_SIZEOF(struct i40e_pf, stats.priority_xon_tx) + \
+		 FIELD_SIZEOF(struct i40e_pf, stats.priority_xon_2_xoff)) \
+		 / sizeof(u64))
+#define I40E_PF_STATS_LEN (I40E_GLOBAL_STATS_LEN + \
+			   I40E_PFC_STATS_LEN + \
+			   I40E_VSI_STATS_LEN)
+
+enum i40e_ethtool_test_id {
+	I40E_ETH_TEST_REG = 0,
+	I40E_ETH_TEST_EEPROM,
+	I40E_ETH_TEST_INTR,
+	I40E_ETH_TEST_LOOPBACK,
+	I40E_ETH_TEST_LINK,
+};
+
+static const char i40e_gstrings_test[][ETH_GSTRING_LEN] = {
+	"Register test  (offline)",
+	"Eeprom test    (offline)",
+	"Interrupt test (offline)",
+	"Loopback test  (offline)",
+	"Link test   (on/offline)"
+};
+
+#define I40E_TEST_LEN (sizeof(i40e_gstrings_test) / ETH_GSTRING_LEN)
+
+/**
+ * i40e_get_settings - Get Link Speed and Duplex settings
+ * @netdev: network interface device structure
+ * @ecmd: ethtool command
+ *
+ * Reports speed/duplex settings based on media_type
+ **/
+static int i40e_get_settings(struct net_device *netdev,
+			     struct ethtool_cmd *ecmd)
+{
+	struct i40e_netdev_priv *np = netdev_priv(netdev);
+	struct i40e_pf *pf = np->vsi->back;
+	struct i40e_hw *hw = &pf->hw;
+	struct i40e_link_status *hw_link_info = &hw->phy.link_info;
+	u32 link_speed = hw_link_info->link_speed;
+	bool link_up = false;
+
+	ecmd->supported = SUPPORTED_10000baseT_Full |
+			  SUPPORTED_1000baseT_Full  |
+			  SUPPORTED_Autoneg;
+
+	ecmd->advertising  = ADVERTISED_10000baseT_Full |
+			     ADVERTISED_1000baseT_Full;
+
+	if (hw->phy.media_type == I40E_MEDIA_TYPE_BACKPLANE) {
+		ecmd->supported |= (SUPPORTED_100baseT_Full |
+				    SUPPORTED_Autoneg);
+		ecmd->advertising |= ADVERTISED_100baseT_Full;
+	} else if (hw->phy.media_type == I40E_MEDIA_TYPE_BASET) {
+		ecmd->supported |= SUPPORTED_TP;
+		ecmd->advertising |= ADVERTISED_TP;
+		ecmd->port = PORT_TP;
+	} else {
+		ecmd->supported |= SUPPORTED_FIBRE;
+		ecmd->advertising |= ADVERTISED_FIBRE;
+		ecmd->port = PORT_FIBRE;
+	}
+
+	if (hw->phy.get_link_info == true)
+		link_up = hw_link_info->link_info & I40E_AQ_LINK_UP;
+
+	ecmd->advertising = ADVERTISED_Autoneg;
+
+	if (hw->phy.autoneg_advertised) {
+		if (hw->phy.autoneg_advertised & I40E_LINK_SPEED_100MB)
+			ecmd->advertising |= ADVERTISED_100baseT_Full;
+		if (hw->phy.autoneg_advertised & I40E_LINK_SPEED_1GB)
+			ecmd->advertising |= ADVERTISED_1000baseT_Full;
+		if (hw->phy.autoneg_advertised & I40E_LINK_SPEED_10GB)
+			ecmd->advertising |= ADVERTISED_10000baseT_Full;
+	} else {
+		ecmd->advertising |= (ADVERTISED_10000baseT_Full |
+				      ADVERTISED_1000baseT_Full);
+	}
+
+	ecmd->transceiver = XCVR_EXTERNAL;
+
+	if (!in_interrupt()) {
+		i40e_aq_get_link_info(&pf->hw, true, NULL, NULL);
+	} else {
+		/* Reinitialize link variables, a special workaround for RHEL5
+		 * bonding that calls this routine from interrupt context
+		 */
+		link_speed = hw_link_info->link_speed;
+		link_up = hw_link_info->link_info & I40E_AQ_LINK_UP;
+	}
+
+	if (link_up) {
+		switch (link_speed) {
+		case I40E_LINK_SPEED_10GB:
+			ecmd->speed = SPEED_10000;
+			break;
+		case I40E_LINK_SPEED_1GB:
+			ecmd->speed = SPEED_1000;
+			break;
+		case I40E_LINK_SPEED_100MB:
+			ecmd->speed = SPEED_100;
+			break;
+		default:
+			break;
+		}
+		ecmd->duplex = DUPLEX_FULL;
+	} else {
+		ecmd->speed = -1;
+		ecmd->duplex = -1;
+	}
+
+	return 0;
+}
+
+/**
+ * i40e_set_settings - Set Speed and Duplex
+ * @netdev: network interface device structure
+ * @ecmd: ethtool command
+ *
+ * Set speed/duplex per media_types advertised/forced
+ **/
+static int i40e_set_settings(struct net_device *netdev,
+			     struct ethtool_cmd *ecmd)
+{
+	return -EOPNOTSUPP;
+}
+
+/**
+ * i40e_get_pauseparam -  Get Flow Control status
+ * Return tx/rx-pause status
+ **/
+static void i40e_get_pauseparam(struct net_device *netdev,
+				struct ethtool_pauseparam *pause)
+{
+	struct i40e_netdev_priv *np = netdev_priv(netdev);
+	struct i40e_pf *pf = np->vsi->back;
+	struct i40e_hw *hw = &pf->hw;
+	struct i40e_link_status *hw_link_info = &hw->phy.link_info;
+
+	pause->autoneg =
+		((hw_link_info->an_info & I40E_AQ_AN_COMPLETED) ?
+		  AUTONEG_ENABLE : AUTONEG_DISABLE);
+
+	pause->rx_pause = 0;
+	pause->tx_pause = 0;
+	if (hw_link_info->an_info & I40E_AQ_LINK_PAUSE_RX)
+		pause->rx_pause = 1;
+	if (hw_link_info->an_info & I40E_AQ_LINK_PAUSE_TX)
+		pause->tx_pause = 1;
+}
+
+/**
+ * i40e_set_pauseparam - Set Flow Control parameter
+ * @netdev: network interface device structure
+ * @pause: return tx/rx flow control status
+ **/
+static int i40e_set_pauseparam(struct net_device *netdev,
+			       struct ethtool_pauseparam *pause)
+{
+	return -EOPNOTSUPP;
+}
+
+static u32 i40e_get_msglevel(struct net_device *netdev)
+{
+	struct i40e_netdev_priv *np = netdev_priv(netdev);
+	struct i40e_pf *pf = np->vsi->back;
+
+	return pf->msg_enable;
+}
+
+static void i40e_set_msglevel(struct net_device *netdev, u32 data)
+{
+	struct i40e_netdev_priv *np = netdev_priv(netdev);
+	struct i40e_pf *pf = np->vsi->back;
+
+	if (I40E_DEBUG_USER & data)
+		pf->hw.debug_mask = data;
+	pf->msg_enable = data;
+}
+
+static int i40e_get_regs_len(struct net_device *netdev)
+{
+	int reg_count = 0;
+	int i;
+
+	for (i = 0; i40e_reg_list[i].offset != 0; i++)
+		reg_count += i40e_reg_list[i].elements;
+
+	return reg_count * sizeof(u32);
+}
+
+static void i40e_get_regs(struct net_device *netdev, struct ethtool_regs *regs,
+			  void *p)
+{
+	struct i40e_netdev_priv *np = netdev_priv(netdev);
+	struct i40e_pf *pf = np->vsi->back;
+	struct i40e_hw *hw = &pf->hw;
+	u32 *reg_buf = p;
+	int i, j, ri;
+	u32 reg;
+
+	/* Tell ethtool which driver-version-specific regs output we have.
+	 *
+	 * At some point, if we have ethtool doing special formatting of
+	 * this data, it will rely on this version number to know how to
+	 * interpret things.  Hence, this needs to be updated if/when the
+	 * diags register table is changed.
+	 */
+	regs->version = 1;
+
+	/* loop through the diags reg table for what to print */
+	ri = 0;
+	for (i = 0; i40e_reg_list[i].offset != 0; i++) {
+		for (j = 0; j < i40e_reg_list[i].elements; j++) {
+			reg = i40e_reg_list[i].offset
+				+ (j * i40e_reg_list[i].stride);
+			reg_buf[ri++] = rd32(hw, reg);
+		}
+	}
+
+	return;
+}
+
+static int i40e_get_eeprom_len(struct net_device *netdev)
+{
+	return 0;
+}
+
+static int i40e_get_eeprom(struct net_device *netdev,
+			   struct ethtool_eeprom *eeprom, u8 *bytes)
+{
+	return 0;
+}
+
+static int i40e_set_eeprom(struct net_device *netdev,
+			   struct ethtool_eeprom *eeprom, u8 *bytes)
+{
+	return -EOPNOTSUPP;
+}
+
+static void i40e_get_drvinfo(struct net_device *netdev,
+			     struct ethtool_drvinfo *drvinfo)
+{
+	struct i40e_netdev_priv *np = netdev_priv(netdev);
+	struct i40e_vsi *vsi = np->vsi;
+	struct i40e_pf *pf = vsi->back;
+	char firmware_version[32];
+
+	strncpy(drvinfo->driver, i40e_driver_name, sizeof(drvinfo->driver));
+	strncpy(drvinfo->version, i40e_driver_version_str,
+		sizeof(drvinfo->version));
+
+	snprintf(firmware_version, sizeof(firmware_version),
+		 "FW %d.%d API %d.%d NVM %02d.%02d.%02d",
+		 pf->hw.aq.fw_maj_ver, pf->hw.aq.fw_min_ver,
+		 pf->hw.aq.api_maj_ver, pf->hw.aq.api_min_ver,
+		 ((pf->hw.nvm.version >> 12) & 0xf),
+		 ((pf->hw.nvm.version >> 4) & 0xff),
+		 (pf->hw.nvm.version & 0xf));
+
+	strncpy(drvinfo->fw_version, firmware_version,
+		sizeof(drvinfo->fw_version));
+	strncpy(drvinfo->bus_info, pci_name(pf->pdev),
+		sizeof(drvinfo->bus_info));
+	if (vsi == pf->vsi[pf->lan_vsi])
+		drvinfo->n_stats = I40E_PF_STATS_LEN;
+	else
+		drvinfo->n_stats = I40E_VSI_STATS_LEN;
+	drvinfo->testinfo_len = I40E_TEST_LEN;
+	drvinfo->regdump_len = i40e_get_regs_len(netdev);
+}
+
+static void i40e_get_ringparam(struct net_device *netdev,
+			       struct ethtool_ringparam *ring)
+{
+	struct i40e_netdev_priv *np = netdev_priv(netdev);
+	struct i40e_pf *pf = np->vsi->back;
+	struct i40e_vsi *vsi = pf->vsi[pf->lan_vsi];
+
+	ring->rx_max_pending = I40E_MAX_NUM_DESCRIPTORS;
+	ring->tx_max_pending = I40E_MAX_NUM_DESCRIPTORS;
+	ring->rx_mini_max_pending = 0;
+	ring->rx_jumbo_max_pending = 0;
+	ring->rx_pending = vsi->rx_rings[0].count;
+	ring->tx_pending = vsi->tx_rings[0].count;
+	ring->rx_mini_pending = 0;
+	ring->rx_jumbo_pending = 0;
+}
+
+static int i40e_set_ringparam(struct net_device *netdev,
+			      struct ethtool_ringparam *ring)
+{
+	struct i40e_netdev_priv *np = netdev_priv(netdev);
+	struct i40e_vsi *vsi = np->vsi;
+	struct i40e_pf *pf = vsi->back;
+	struct i40e_ring *tx_rings = NULL, *rx_rings = NULL;
+	u32 new_rx_count, new_tx_count;
+	int i, err = 0;
+
+	if ((ring->rx_mini_pending) || (ring->rx_jumbo_pending))
+		return -EINVAL;
+
+	new_tx_count = clamp_t(u32, ring->tx_pending,
+			       I40E_MIN_NUM_DESCRIPTORS,
+			       I40E_MAX_NUM_DESCRIPTORS);
+	new_tx_count = ALIGN(new_tx_count, I40E_REQ_DESCRIPTOR_MULTIPLE);
+
+	new_rx_count = clamp_t(u32, ring->rx_pending,
+			       I40E_MIN_NUM_DESCRIPTORS,
+			       I40E_MAX_NUM_DESCRIPTORS);
+	new_rx_count = ALIGN(new_rx_count, I40E_REQ_DESCRIPTOR_MULTIPLE);
+
+	/* if nothing to do return success */
+	if ((new_tx_count == vsi->tx_rings[0].count) &&
+	    (new_rx_count == vsi->rx_rings[0].count))
+		return 0;
+
+	while (test_and_set_bit(__I40E_CONFIG_BUSY, &pf->state))
+		usleep_range(1000, 2000);
+
+	if (!netif_running(vsi->netdev)) {
+		/* simple case - set for the next time the netdev is started */
+		for (i = 0; i < vsi->num_queue_pairs; i++) {
+			vsi->tx_rings[i].count = new_tx_count;
+			vsi->rx_rings[i].count = new_rx_count;
+		}
+		goto done;
+	}
+
+	/* We can't just free everything and then setup again,
+	 * because the ISRs in MSI-X mode get passed pointers
+	 * to the Tx and Rx ring structs.
+	 */
+
+	/* alloc updated Tx resources */
+	if (new_tx_count != vsi->tx_rings[0].count) {
+		netdev_info(netdev,
+			    "%s: Changing Tx descriptor count from %d to %d.\n",
+			    __func__, vsi->tx_rings[0].count, new_tx_count);
+		tx_rings = kcalloc(vsi->alloc_queue_pairs,
+				   sizeof(struct i40e_ring), GFP_KERNEL);
+		if (!tx_rings) {
+			err = -ENOMEM;
+			goto done;
+		}
+
+		for (i = 0; i < vsi->num_queue_pairs; i++) {
+			/* clone ring and setup updated count */
+			tx_rings[i] = vsi->tx_rings[i];
+			tx_rings[i].count = new_tx_count;
+			err = i40e_setup_tx_descriptors(&tx_rings[i]);
+			if (err) {
+				while (i) {
+					i--;
+					i40e_free_tx_resources(&tx_rings[i]);
+				}
+				kfree(tx_rings);
+				tx_rings = NULL;
+
+				goto done;
+			}
+		}
+	}
+
+	/* alloc updated Rx resources */
+	if (new_rx_count != vsi->rx_rings[0].count) {
+		netdev_info(netdev,
+			    "%s: Changing Rx descriptor count from %d to %d\n",
+			    __func__, vsi->rx_rings[0].count, new_rx_count);
+		rx_rings = kcalloc(vsi->alloc_queue_pairs,
+				   sizeof(struct i40e_ring), GFP_KERNEL);
+		if (!rx_rings) {
+			err = -ENOMEM;
+			goto free_tx;
+		}
+
+		for (i = 0; i < vsi->num_queue_pairs; i++) {
+			/* clone ring and setup updated count */
+			rx_rings[i] = vsi->rx_rings[i];
+			rx_rings[i].count = new_rx_count;
+			err = i40e_setup_rx_descriptors(&rx_rings[i]);
+			if (err) {
+				while (i) {
+					i--;
+					i40e_free_rx_resources(&rx_rings[i]);
+				}
+				kfree(rx_rings);
+				rx_rings = NULL;
+
+				goto free_tx;
+			}
+		}
+	}
+
+	/* Bring interface down, copy in the new ring info,
+	 * then restore the interface
+	 */
+	i40e_down(vsi);
+
+	if (tx_rings) {
+		for (i = 0; i < vsi->num_queue_pairs; i++) {
+			i40e_free_tx_resources(&vsi->tx_rings[i]);
+			vsi->tx_rings[i] = tx_rings[i];
+		}
+		kfree(tx_rings);
+		tx_rings = NULL;
+	}
+
+	if (rx_rings) {
+		for (i = 0; i < vsi->num_queue_pairs; i++) {
+			i40e_free_rx_resources(&vsi->rx_rings[i]);
+			vsi->rx_rings[i] = rx_rings[i];
+		}
+		kfree(rx_rings);
+		rx_rings = NULL;
+	}
+
+	i40e_up(vsi);
+
+free_tx:
+	/* error cleanup if the Rx allocations failed after getting Tx */
+	if (tx_rings) {
+		for (i = 0; i < vsi->num_queue_pairs; i++)
+			i40e_free_tx_resources(&tx_rings[i]);
+		kfree(tx_rings);
+		tx_rings = NULL;
+	}
+
+done:
+	clear_bit(__I40E_CONFIG_BUSY, &pf->state);
+
+	return err;
+}
+
+static int i40e_get_sset_count(struct net_device *netdev, int sset)
+{
+	struct i40e_netdev_priv *np = netdev_priv(netdev);
+	struct i40e_vsi *vsi = np->vsi;
+	struct i40e_pf *pf = vsi->back;
+
+	switch (sset) {
+	case ETH_SS_TEST:
+		return I40E_TEST_LEN;
+	case ETH_SS_STATS:
+		if (vsi == pf->vsi[pf->lan_vsi])
+			return I40E_PF_STATS_LEN;
+		else
+			return I40E_VSI_STATS_LEN;
+	default:
+		return -EOPNOTSUPP;
+	}
+}
+
+static void i40e_get_ethtool_stats(struct net_device *netdev,
+				   struct ethtool_stats *stats, u64 *data)
+{
+	struct i40e_netdev_priv *np = netdev_priv(netdev);
+	struct i40e_vsi *vsi = np->vsi;
+	struct i40e_pf *pf = vsi->back;
+	struct net_device_stats *net_stats = i40e_get_vsi_stats_struct(vsi);
+	char *p;
+	int i, j;
+
+	i40e_update_stats(vsi);
+
+	i = 0;
+	for (j = 0; j < I40E_NETDEV_STATS_LEN; j++) {
+		p = (char *)net_stats + i40e_gstrings_net_stats[j].stat_offset;
+		data[i++] = (i40e_gstrings_net_stats[j].sizeof_stat ==
+			sizeof(u64)) ? *(u64 *)p : *(u32 *)p;
+	}
+	if (vsi == pf->vsi[pf->lan_vsi]) {
+		for (j = 0; j < I40E_GLOBAL_STATS_LEN; j++) {
+			p = (char *)pf + i40e_gstrings_stats[j].stat_offset;
+			data[i++] = (i40e_gstrings_stats[j].sizeof_stat ==
+				   sizeof(u64)) ? *(u64 *)p : *(u32 *)p;
+		}
+		for (j = 0; j < I40E_MAX_USER_PRIORITY; j++) {
+			data[i++] = pf->stats.priority_xon_tx[j];
+			data[i++] = pf->stats.priority_xoff_tx[j];
+		}
+		for (j = 0; j < I40E_MAX_USER_PRIORITY; j++) {
+			data[i++] = pf->stats.priority_xon_rx[j];
+			data[i++] = pf->stats.priority_xoff_rx[j];
+		}
+		for (j = 0; j < I40E_MAX_USER_PRIORITY; j++)
+			data[i++] = pf->stats.priority_xon_2_xoff[j];
+	}
+	for (j = 0; j < vsi->num_queue_pairs; j++) {
+		data[i++] = vsi->tx_rings[j].tx_stats.packets;
+		data[i++] = vsi->tx_rings[j].tx_stats.bytes;
+	}
+	for (j = 0; j < vsi->num_queue_pairs; j++) {
+		data[i++] = vsi->rx_rings[j].rx_stats.packets;
+		data[i++] = vsi->rx_rings[j].rx_stats.bytes;
+	}
+
+	return;
+}
+
+static void i40e_get_strings(struct net_device *netdev, u32 stringset,
+			     u8 *data)
+{
+	struct i40e_netdev_priv *np = netdev_priv(netdev);
+	struct i40e_vsi *vsi = np->vsi;
+	struct i40e_pf *pf = vsi->back;
+	char *p = (char *)data;
+	int i;
+
+	switch (stringset) {
+	case ETH_SS_TEST:
+		for (i = 0; i < I40E_TEST_LEN; i++) {
+			memcpy(data, i40e_gstrings_test[i], ETH_GSTRING_LEN);
+			data += ETH_GSTRING_LEN;
+		}
+		break;
+	case ETH_SS_STATS:
+		for (i = 0; i < I40E_NETDEV_STATS_LEN; i++) {
+			snprintf(p, ETH_GSTRING_LEN, "%s-%s",
+				 netdev->name,
+				 i40e_gstrings_net_stats[i].stat_string);
+			p += ETH_GSTRING_LEN;
+		}
+		if (vsi == pf->vsi[pf->lan_vsi]) {
+			for (i = 0; i < I40E_GLOBAL_STATS_LEN; i++) {
+				snprintf(p, ETH_GSTRING_LEN, "mac-%s",
+					i40e_gstrings_stats[i].stat_string);
+				p += ETH_GSTRING_LEN;
+			}
+			for (i = 0; i < I40E_MAX_USER_PRIORITY; i++) {
+				snprintf(p, ETH_GSTRING_LEN,
+					 "mac-tx_priority_%u_xon", i);
+				p += ETH_GSTRING_LEN;
+				snprintf(p, ETH_GSTRING_LEN,
+					 "mac-tx_priority_%u_xoff", i);
+				p += ETH_GSTRING_LEN;
+			}
+			for (i = 0; i < I40E_MAX_USER_PRIORITY; i++) {
+				snprintf(p, ETH_GSTRING_LEN,
+					 "mac-rx_priority_%u_xon", i);
+				p += ETH_GSTRING_LEN;
+				snprintf(p, ETH_GSTRING_LEN,
+					 "mac-rx_priority_%u_xoff", i);
+				p += ETH_GSTRING_LEN;
+			}
+			for (i = 0; i < I40E_MAX_USER_PRIORITY; i++) {
+				snprintf(p, ETH_GSTRING_LEN,
+					 "mac-rx_priority_%u_xon_2_xoff", i);
+				p += ETH_GSTRING_LEN;
+			}
+		}
+		for (i = 0; i < vsi->num_queue_pairs; i++) {
+			snprintf(p, ETH_GSTRING_LEN, "%s-tx_queue_%u_packets",
+				 netdev->name, i);
+			p += ETH_GSTRING_LEN;
+			snprintf(p, ETH_GSTRING_LEN, "%s-tx_queue_%u_bytes",
+				 netdev->name, i);
+			p += ETH_GSTRING_LEN;
+		}
+		for (i = 0; i < vsi->num_queue_pairs; i++) {
+			snprintf(p, ETH_GSTRING_LEN, "%s-rx_queue_%u_packets",
+				 netdev->name, i);
+			p += ETH_GSTRING_LEN;
+			snprintf(p, ETH_GSTRING_LEN, "%s-rx_queue_%u_bytes",
+				 netdev->name, i);
+			p += ETH_GSTRING_LEN;
+		}
+		/* BUG_ON(p - data != I40E_STATS_LEN * ETH_GSTRING_LEN); */
+		break;
+	}
+}
+
+static int i40e_get_ts_info(struct net_device *dev,
+			    struct ethtool_ts_info *info)
+{
+	return ethtool_op_get_ts_info(dev, info);
+}
+
+static int i40e_link_test(struct i40e_pf *pf, u64 *data)
+{
+	bool link_up;
+
+	link_up = i40e_get_link_status(&pf->hw);
+	if (link_up)
+		*data = 0;
+	else
+		*data = 1;
+
+	return *data;
+}
+
+static int i40e_reg_test(struct i40e_pf *pf, u64 *data)
+{
+	enum i40e_status_code ret;
+
+	ret = i40e_diag_reg_test(&pf->hw);
+	*data = ret;
+
+	return ret;
+}
+
+static int i40e_eeprom_test(struct i40e_pf *pf, u64 *data)
+{
+	enum i40e_status_code ret;
+
+	ret = i40e_diag_eeprom_test(&pf->hw);
+	*data = ret;
+
+	return ret;
+}
+
+static int i40e_intr_test(struct i40e_pf *pf, u64 *data)
+{
+	*data = I40E_ERR_NOT_IMPLEMENTED;
+
+	return *data;
+}
+
+static int i40e_loopback_test(struct i40e_pf *pf, u64 *data)
+{
+	*data = I40E_ERR_NOT_IMPLEMENTED;
+
+	return *data;
+}
+
+static void i40e_diag_test(struct net_device *netdev,
+			   struct ethtool_test *eth_test, u64 *data)
+{
+	struct i40e_netdev_priv *np = netdev_priv(netdev);
+	struct i40e_pf *pf = np->vsi->back;
+
+	set_bit(__I40E_TESTING, &pf->state);
+	if (eth_test->flags == ETH_TEST_FL_OFFLINE) {
+		/* Offline tests */
+
+		netdev_info(netdev, "%s: offline testing starting\n", __func__);
+
+		/* Link test performed before hardware reset
+		 * so autoneg doesn't interfere with test result
+		 */
+		netdev_info(netdev, "%s: link test starting\n", __func__);
+		if (i40e_link_test(pf, &data[I40E_ETH_TEST_LINK]))
+			eth_test->flags |= ETH_TEST_FL_FAILED;
+
+		netdev_info(netdev, "%s: register test starting\n", __func__);
+		if (i40e_reg_test(pf, &data[I40E_ETH_TEST_REG]))
+			eth_test->flags |= ETH_TEST_FL_FAILED;
+
+		i40e_do_reset(pf, (1 << __I40E_PF_RESET_REQUESTED));
+		netdev_info(netdev, "%s: eeprom test starting\n", __func__);
+		if (i40e_eeprom_test(pf, &data[I40E_ETH_TEST_EEPROM]))
+			eth_test->flags |= ETH_TEST_FL_FAILED;
+
+		i40e_do_reset(pf, (1 << __I40E_PF_RESET_REQUESTED));
+		netdev_info(netdev, "%s: interrupt test starting\n", __func__);
+		if (i40e_intr_test(pf, &data[I40E_ETH_TEST_INTR]))
+			eth_test->flags |= ETH_TEST_FL_FAILED;
+
+		i40e_do_reset(pf, (1 << __I40E_PF_RESET_REQUESTED));
+		netdev_info(netdev, "%s: loopback test starting\n", __func__);
+		if (i40e_loopback_test(pf, &data[I40E_ETH_TEST_LOOPBACK]))
+			eth_test->flags |= ETH_TEST_FL_FAILED;
+
+	} else {
+		netdev_info(netdev, "%s: online test starting\n", __func__);
+		/* Online tests */
+		if (i40e_link_test(pf, &data[I40E_ETH_TEST_LINK]))
+			eth_test->flags |= ETH_TEST_FL_FAILED;
+
+		/* Offline only tests, not run in online; pass by default */
+		data[I40E_ETH_TEST_REG] = 0;
+		data[I40E_ETH_TEST_EEPROM] = 0;
+		data[I40E_ETH_TEST_INTR] = 0;
+		data[I40E_ETH_TEST_LOOPBACK] = 0;
+
+		clear_bit(__I40E_TESTING, &pf->state);
+	}
+}
+
+static void i40e_get_wol(struct net_device *netdev,
+			 struct ethtool_wolinfo *wol)
+{
+	wol->supported = 0;
+	wol->wolopts = 0;
+}
+
+static int i40e_set_wol(struct net_device *netdev, struct ethtool_wolinfo *wol)
+{
+	return -EOPNOTSUPP;
+}
+
+static int i40e_nway_reset(struct net_device *netdev)
+{
+	/* restart autonegotiation */
+	struct i40e_netdev_priv *np = netdev_priv(netdev);
+	struct i40e_pf *pf = np->vsi->back;
+	struct i40e_hw *hw = &pf->hw;
+	enum i40e_status_code ret = 0;
+
+	ret = i40e_aq_set_link_restart_an(hw, NULL);
+	if (ret != I40E_SUCCESS)
+		netdev_info(netdev, "%s: link restart failed, aq_err=%d\n",
+			    __func__, pf->hw.aq.asq_last_status);
+
+	return ret;
+}
+
+static int i40e_set_phys_id(struct net_device *netdev,
+			    enum ethtool_phys_id_state state)
+{
+	struct i40e_netdev_priv *np = netdev_priv(netdev);
+	struct i40e_pf *pf = np->vsi->back;
+	struct i40e_hw *hw = &pf->hw;
+	int blink_freq = 2;
+	static u32 led_status;
+
+	switch (state) {
+	case ETHTOOL_ID_ACTIVE:
+		led_status = i40e_led_get(hw);
+		return blink_freq;
+	case ETHTOOL_ID_ON:
+		i40e_led_set(hw, 0xF);
+		break;
+	case ETHTOOL_ID_OFF:
+		i40e_led_set(hw, 0x0);
+		break;
+	case ETHTOOL_ID_INACTIVE:
+		i40e_led_set(hw, led_status);
+		break;
+	}
+
+	return 0;
+}
+
+/* NOTE: i40e hardware uses a conversion factor of 2 for Interrupt
+ * Throttle Rate (ITR) ie. ITR(1) = 2us ITR(10) = 20 us, and also
+ * 125us (8000 interrupts per second) == ITR(62)
+ */
+
+static int i40e_get_coalesce(struct net_device *netdev,
+			     struct ethtool_coalesce *ec)
+{
+	struct i40e_netdev_priv *np = netdev_priv(netdev);
+	struct i40e_vsi *vsi = np->vsi;
+
+	ec->tx_max_coalesced_frames_irq = vsi->work_limit;
+	ec->rx_max_coalesced_frames_irq = vsi->work_limit;
+
+	if (ITR_IS_DYNAMIC(vsi->rx_itr_setting))
+		ec->rx_coalesce_usecs = 1;
+	else
+		ec->rx_coalesce_usecs = vsi->rx_itr_setting;
+
+	if (ITR_IS_DYNAMIC(vsi->tx_itr_setting))
+		ec->tx_coalesce_usecs = 1;
+	else
+		ec->tx_coalesce_usecs = vsi->tx_itr_setting;
+
+	return 0;
+}
+
+static int i40e_set_coalesce(struct net_device *netdev,
+			     struct ethtool_coalesce *ec)
+{
+	struct i40e_netdev_priv *np = netdev_priv(netdev);
+	struct i40e_vsi *vsi = np->vsi;
+	struct i40e_pf *pf = vsi->back;
+	struct i40e_hw *hw = &pf->hw;
+	u16 vector;
+	struct i40e_q_vector *q_vector;
+	int i;
+
+	if (ec->tx_max_coalesced_frames_irq || ec->rx_max_coalesced_frames_irq)
+		vsi->work_limit = ec->tx_max_coalesced_frames_irq;
+
+	switch (ec->rx_coalesce_usecs) {
+	case 0:
+		vsi->rx_itr_setting = 0;
+		break;
+	case 1:
+		vsi->rx_itr_setting = (I40E_ITR_DYNAMIC |
+				       ITR_REG_TO_USEC(I40E_ITR_RX_DEF));
+		break;
+	default:
+		if ((ec->rx_coalesce_usecs < (I40E_MIN_ITR << 1)) ||
+		    (ec->rx_coalesce_usecs > (I40E_MAX_ITR << 1)))
+			return -EINVAL;
+		vsi->rx_itr_setting = ec->rx_coalesce_usecs;
+		break;
+	}
+
+	switch (ec->tx_coalesce_usecs) {
+	case 0:
+		vsi->tx_itr_setting = 0;
+		break;
+	case 1:
+		vsi->tx_itr_setting = (I40E_ITR_DYNAMIC |
+				       ITR_REG_TO_USEC(I40E_ITR_TX_DEF));
+		break;
+	default:
+		if ((ec->tx_coalesce_usecs < (I40E_MIN_ITR << 1)) ||
+		    (ec->tx_coalesce_usecs > (I40E_MAX_ITR << 1)))
+			return -EINVAL;
+		vsi->tx_itr_setting = ec->tx_coalesce_usecs;
+		break;
+	}
+
+	vector = vsi->base_vector;
+	q_vector = vsi->q_vectors;
+	for (i = 0; i < vsi->num_q_vectors; i++, vector++, q_vector++) {
+		q_vector->rx.itr = ITR_TO_REG(vsi->rx_itr_setting);
+		wr32(hw, I40E_PFINT_ITRN(0, vector - 1), q_vector->rx.itr);
+		q_vector->tx.itr = ITR_TO_REG(vsi->tx_itr_setting);
+		wr32(hw, I40E_PFINT_ITRN(1, vector - 1), q_vector->tx.itr);
+		flush(hw);
+	}
+
+	return 0;
+}
+
+/**
+ * i40e_get_rss_hash_opts - Get RSS hash Input Set for each flow type
+ * @pf: pointer to the physical function struct
+ * @cmd: ethtool rxnfc command
+ *
+ * Returns Success if the flow is supported, else Invalid Input.
+ **/
+static int i40e_get_rss_hash_opts(struct i40e_pf *pf, struct ethtool_rxnfc *cmd)
+{
+	cmd->data = 0;
+
+	/* Report default options for RSS on i40e */
+	switch (cmd->flow_type) {
+	case TCP_V4_FLOW:
+	case UDP_V4_FLOW:
+		cmd->data |= RXH_L4_B_0_1 | RXH_L4_B_2_3;
+	/* fall through to add IP fields */
+	case SCTP_V4_FLOW:
+	case AH_ESP_V4_FLOW:
+	case AH_V4_FLOW:
+	case ESP_V4_FLOW:
+	case IPV4_FLOW:
+		cmd->data |= RXH_IP_SRC | RXH_IP_DST;
+		break;
+	case TCP_V6_FLOW:
+	case UDP_V6_FLOW:
+		cmd->data |= RXH_L4_B_0_1 | RXH_L4_B_2_3;
+	/* fall through to add IP fields */
+	case SCTP_V6_FLOW:
+	case AH_ESP_V6_FLOW:
+	case AH_V6_FLOW:
+	case ESP_V6_FLOW:
+	case IPV6_FLOW:
+		cmd->data |= RXH_IP_SRC | RXH_IP_DST;
+		break;
+	default:
+		return -EINVAL;
+	}
+
+	return 0;
+}
+
+/**
+ * i40e_get_rxnfc - command to get RX flow classification rules
+ * @netdev: network interface device structure
+ * @cmd: ethtool rxnfc command
+ *
+ * Returns Success if the command is supported.
+ **/
+static int i40e_get_rxnfc(struct net_device *netdev, struct ethtool_rxnfc *cmd,
+			  u32 *rule_locs)
+{
+	struct i40e_netdev_priv *np = netdev_priv(netdev);
+	struct i40e_vsi *vsi = np->vsi;
+	struct i40e_pf *pf = vsi->back;
+	int ret = -EOPNOTSUPP;
+
+	switch (cmd->cmd) {
+	case ETHTOOL_GRXRINGS:
+		cmd->data = vsi->alloc_queue_pairs;
+		ret = 0;
+		break;
+	case ETHTOOL_GRXFH:
+		ret = i40e_get_rss_hash_opts(pf, cmd);
+		break;
+	default:
+		break;
+	}
+
+	return ret;
+}
+
+/**
+ * i40e_set_rss_hash_opt - Enable/Disable flow types for RSS hash
+ * @pf: pointer to the physical function struct
+ * @cmd: ethtool rxnfc command
+ *
+ * Returns Success if the flow input set is supported.
+ **/
+static int i40e_set_rss_hash_opt(struct i40e_pf *pf, struct ethtool_rxnfc *nfc)
+{
+	struct i40e_hw *hw = &pf->hw;
+	u64 hena = (u64)rd32(hw, I40E_PFQF_HENA(0)) |
+		   ((u64)rd32(hw, I40E_PFQF_HENA(1)) << 32);
+
+	/* RSS does not support anything other than hashing
+	 * to queues on src and dst IPs and ports
+	 */
+	if (nfc->data & ~(RXH_IP_SRC | RXH_IP_DST |
+			  RXH_L4_B_0_1 | RXH_L4_B_2_3))
+		return -EINVAL;
+
+	/* We need at least the IP SRC and DEST fields for hashing */
+	if (!(nfc->data & RXH_IP_SRC) ||
+	    !(nfc->data & RXH_IP_DST))
+		return -EINVAL;
+
+	switch (nfc->flow_type) {
+	case TCP_V4_FLOW:
+		switch (nfc->data & (RXH_L4_B_0_1 | RXH_L4_B_2_3)) {
+		case 0:
+			hena &= ~((u64)1 << I40E_FILTER_PCTYPE_NONF_IPV4_TCP);
+			break;
+		case (RXH_L4_B_0_1 | RXH_L4_B_2_3):
+			hena |= ((u64)1 << I40E_FILTER_PCTYPE_NONF_IPV4_TCP);
+			break;
+		default:
+			return -EINVAL;
+		}
+		break;
+	case TCP_V6_FLOW:
+		switch (nfc->data & (RXH_L4_B_0_1 | RXH_L4_B_2_3)) {
+		case 0:
+			hena &= ~((u64)1 << I40E_FILTER_PCTYPE_NONF_IPV6_TCP);
+			break;
+		case (RXH_L4_B_0_1 | RXH_L4_B_2_3):
+			hena |= ((u64)1 << I40E_FILTER_PCTYPE_NONF_IPV6_TCP);
+			break;
+		default:
+			return -EINVAL;
+		}
+		break;
+	case UDP_V4_FLOW:
+		switch (nfc->data & (RXH_L4_B_0_1 | RXH_L4_B_2_3)) {
+		case 0:
+			hena &=
+			~(((u64)1 << I40E_FILTER_PCTYPE_NONF_UNICAST_IPV4_UDP) |
+			((u64)1 << I40E_FILTER_PCTYPE_NONF_MULTICAST_IPV4_UDP) |
+			((u64)1 << I40E_FILTER_PCTYPE_FRAG_IPV4));
+			break;
+		case (RXH_L4_B_0_1 | RXH_L4_B_2_3):
+			hena |=
+			(((u64)1 << I40E_FILTER_PCTYPE_NONF_UNICAST_IPV4_UDP)  |
+			((u64)1 << I40E_FILTER_PCTYPE_NONF_MULTICAST_IPV4_UDP) |
+			((u64)1 << I40E_FILTER_PCTYPE_FRAG_IPV4));
+			break;
+		default:
+			return -EINVAL;
+		}
+		break;
+	case UDP_V6_FLOW:
+		switch (nfc->data & (RXH_L4_B_0_1 | RXH_L4_B_2_3)) {
+		case 0:
+			hena &=
+			~(((u64)1 << I40E_FILTER_PCTYPE_NONF_UNICAST_IPV6_UDP) |
+			((u64)1 << I40E_FILTER_PCTYPE_NONF_MULTICAST_IPV6_UDP) |
+			((u64)1 << I40E_FILTER_PCTYPE_FRAG_IPV6));
+			break;
+		case (RXH_L4_B_0_1 | RXH_L4_B_2_3):
+			hena |=
+			(((u64)1 << I40E_FILTER_PCTYPE_NONF_UNICAST_IPV6_UDP)  |
+			((u64)1 << I40E_FILTER_PCTYPE_NONF_MULTICAST_IPV6_UDP) |
+			((u64)1 << I40E_FILTER_PCTYPE_FRAG_IPV6));
+			break;
+		default:
+			return -EINVAL;
+		}
+		break;
+	case AH_ESP_V4_FLOW:
+	case AH_V4_FLOW:
+	case ESP_V4_FLOW:
+	case SCTP_V4_FLOW:
+		if ((nfc->data & RXH_L4_B_0_1) ||
+		    (nfc->data & RXH_L4_B_2_3))
+			return -EINVAL;
+		hena |= ((u64)1 << I40E_FILTER_PCTYPE_NONF_IPV4_OTHER);
+		break;
+	case AH_ESP_V6_FLOW:
+	case AH_V6_FLOW:
+	case ESP_V6_FLOW:
+	case SCTP_V6_FLOW:
+		if ((nfc->data & RXH_L4_B_0_1) ||
+		    (nfc->data & RXH_L4_B_2_3))
+			return -EINVAL;
+		hena |= ((u64)1 << I40E_FILTER_PCTYPE_NONF_IPV6_OTHER);
+		break;
+	case IPV4_FLOW:
+		hena |= ((u64)1 << I40E_FILTER_PCTYPE_NONF_IPV4_OTHER) |
+			((u64)1 << I40E_FILTER_PCTYPE_FRAG_IPV4);
+		break;
+	case IPV6_FLOW:
+		hena |= ((u64)1 << I40E_FILTER_PCTYPE_NONF_IPV6_OTHER) |
+			((u64)1 << I40E_FILTER_PCTYPE_FRAG_IPV6);
+		break;
+	default:
+		return -EINVAL;
+	}
+
+	wr32(hw, I40E_PFQF_HENA(0), (u32)hena);
+	wr32(hw, I40E_PFQF_HENA(1), (u32)(hena >> 32));
+	flush(hw);
+
+	return 0;
+}
+
+/**
+ * i40e_set_rxnfc - command to set RX flow classification rules
+ * @netdev: network interface device structure
+ * @cmd: ethtool rxnfc command
+ *
+ * Returns Success if the command is supported.
+ **/
+static int i40e_set_rxnfc(struct net_device *netdev, struct ethtool_rxnfc *cmd)
+{
+	struct i40e_netdev_priv *np = netdev_priv(netdev);
+	struct i40e_vsi *vsi = np->vsi;
+	struct i40e_pf *pf = vsi->back;
+	int ret = -EOPNOTSUPP;
+
+	switch (cmd->cmd) {
+	case ETHTOOL_SRXFH:
+		ret = i40e_set_rss_hash_opt(pf, cmd);
+		break;
+	default:
+		break;
+	}
+
+	return ret;
+}
+
+static struct ethtool_ops i40e_ethtool_ops = {
+	.get_settings           = i40e_get_settings,
+	.set_settings           = i40e_set_settings,
+	.get_drvinfo            = i40e_get_drvinfo,
+	.get_regs_len           = i40e_get_regs_len,
+	.get_regs               = i40e_get_regs,
+	.get_wol                = i40e_get_wol,
+	.set_wol                = i40e_set_wol,
+	.nway_reset             = i40e_nway_reset,
+	.get_link               = ethtool_op_get_link,
+	.get_eeprom_len         = i40e_get_eeprom_len,
+	.get_eeprom             = i40e_get_eeprom,
+	.set_eeprom             = i40e_set_eeprom,
+	.get_ringparam          = i40e_get_ringparam,
+	.set_ringparam          = i40e_set_ringparam,
+	.get_pauseparam         = i40e_get_pauseparam,
+	.set_pauseparam         = i40e_set_pauseparam,
+	.get_msglevel           = i40e_get_msglevel,
+	.set_msglevel           = i40e_set_msglevel,
+	.get_rxnfc		= i40e_get_rxnfc,
+	.set_rxnfc		= i40e_set_rxnfc,
+	.self_test              = i40e_diag_test,
+	.get_strings            = i40e_get_strings,
+	.set_phys_id            = i40e_set_phys_id,
+	.get_sset_count         = i40e_get_sset_count,
+	.get_ethtool_stats      = i40e_get_ethtool_stats,
+	.get_coalesce           = i40e_get_coalesce,
+	.set_coalesce           = i40e_set_coalesce,
+	.get_ts_info            = i40e_get_ts_info,
+};
+
+void i40e_set_ethtool_ops(struct net_device *netdev)
+{
+	SET_ETHTOOL_OPS(netdev, &i40e_ethtool_ops);
+}
-- 
1.7.11.7
