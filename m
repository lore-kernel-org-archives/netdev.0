From: Ramkrishna Vepa <ram.vepa@neterion.com>
Subject: [net-2.6 PATCH 9/10] Neterion: New driver: Ethtool related
Date: 14 Mar 2009 00:22:01 -0800
Message-ID: <1237018915.4966.437.camel@flash>
Reply-To: ram.vepa@neterion.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Ramkrishna Vepa <ram.vepa@neterion.com>
To: Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:60410 "EHLO
	barracuda.s2io.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751870AbZCNHxS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Mar 2009 03:53:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch implements all ethtool related entry point functions for the driver.

Signed-off-by: Sivakumar Subramani <sivakumar.subramani@neterion.com>
Signed-off-by: Rastapur Santosh <santosh.rastapur@neterion.com>
Signed-off-by: Ramkrishna Vepa <ram.vepa@neterion.com>
---
diff -urpN patch_8/drivers/net/vxge/vxge-ethtool.c patch_9/drivers/net/vxge/vxge-ethtool.c
--- patch_8/drivers/net/vxge/vxge-ethtool.c	1969-12-31 16:00:00.000000000 -0800
+++ patch_9/drivers/net/vxge/vxge-ethtool.c	2009-03-13 00:15:35.000000000 -0700
@@ -0,0 +1,1450 @@
+/******************************************************************************
+ * This software may be used and distributed according to the terms of
+ * the GNU General Public License (GPL), incorporated herein by reference.
+ * Drivers based on or derived from this code fall under the GPL and must
+ * retain the authorship, copyright and license notice.  This file is not
+ * a complete program and may only be used when the entire operating
+ * system is licensed under the GPL.
+ * See the file COPYING in this distribution for more information.
+ ******************************************************************************/
+/*******************************************************************************
+ * vxge-ethtool.c: Driver for Neterion Inc's X3100 Series 10GbE PCIe I/O
+ *                 Virtualized Server Adapter.
+ * Copyright(c) 2002-2009 Neterion Inc.
+ ******************************************************************************/
+#include<linux/version.h>
+#include<linux/netdevice.h>
+#include<linux/if.h>
+#include<linux/ethtool.h>
+#include <linux/pci.h>
+#include <linux/etherdevice.h>
+
+#include "vxge-ethtool.h"
+
+/*
+ * vxge_ethtool_sset - Sets different link parameters.
+ * @dev: device pointer.
+ * @info: pointer to the structure with parameters given by ethtool to set
+ * link information.
+ *
+ * The function sets different link parameters provided by the user onto
+ * the NIC.
+ * Return value:
+ * 0 on success.
+ */
+
+static int vxge_ethtool_sset(struct net_device *dev, struct ethtool_cmd *info)
+{
+	if ((info->autoneg == AUTONEG_ENABLE) ||
+	    (info->speed != SPEED_10000) || (info->duplex != DUPLEX_FULL))
+		return -EINVAL;
+
+	if (netif_running(dev)) {
+		vxge_close(dev);
+		vxge_open(dev);
+	}
+
+	return 0;
+}
+
+/*
+ * vxge_ethtool_gset - Return link specific information.
+ * @dev: device pointer.
+ * @info: pointer to the structure with parameters given by ethtool
+ * to return link information.
+ *
+ * Returns link specific information like speed, duplex etc.. to ethtool.
+ * Return value :
+ * return 0 on success.
+ */
+int vxge_ethtool_gset(struct net_device *dev, struct ethtool_cmd
+*info)
+{
+	info->supported = (SUPPORTED_10000baseT_Full | SUPPORTED_FIBRE);
+
+#ifdef ADVERTISED_10000baseT_Full
+	info->advertising = ADVERTISED_10000baseT_Full;
+#else
+	info->advertising = SUPPORTED_10000baseT_Full;
+#endif
+
+#ifdef ADVERTISED_FIBRE
+	info->advertising  |= ADVERTISED_FIBRE;
+#else
+	info->advertising  |= SUPPORTED_FIBRE;
+#endif
+
+	info->port = PORT_FIBRE;
+	info->transceiver = XCVR_EXTERNAL;
+
+	if (netif_carrier_ok(dev)) {
+		info->speed = SPEED_10000;
+		info->duplex = DUPLEX_FULL;
+	} else {
+		info->speed = -1;
+		info->duplex = -1;
+	}
+
+	info->autoneg = AUTONEG_DISABLE;
+	return 0;
+}
+
+/*
+ * vxge_ethtool_gdrvinfo - Returns driver specific information.
+ * @dev: device pointer.
+ * @info: pointer to the structure with parameters given by ethtool to
+ * return driver information.
+ *
+ * Returns driver specefic information like name, version etc.. to ethtool.
+ */
+static void vxge_ethtool_gdrvinfo(struct net_device *dev,
+			struct ethtool_drvinfo *info)
+{
+	struct vxgedev *vdev;
+	char version[80];
+	vdev = (struct vxgedev *)netdev_priv(dev);
+	sprintf(version, "%s", DRV_VERSION);
+	strncpy(info->driver, VXGE_DRIVER_NAME, sizeof(VXGE_DRIVER_NAME));
+	strncpy(info->version, version, sizeof(version));
+	strncpy(info->fw_version, vdev->fw_version, VXGE_HW_FW_VERSION_LEN);
+	strncpy(info->bus_info, pci_name(vdev->pdev), sizeof(info->bus_info));
+	info->regdump_len = sizeof(struct vxge_hw_vpath_reg)
+				* vdev->no_of_vpath;
+	info->eedump_len = VXGE_HW_EEPROM_SIZE;
+	info->testinfo_len = VXGE_TEST_LEN;
+
+	info->n_stats = STAT_LEN;
+
+}
+
+/*
+ * vxge_ethtool_gregs - dumps the entire space of Titan into the buffer.
+ * @dev: device pointer.
+ * @regs: pointer to the structure with parameters given by ethtool for
+ * dumping the registers.
+ * @reg_space: The input argumnet into which all the registers are dumped.
+ *
+ * Dumps the entire register space of xFrame NIC into the user given
+ * buffer area.
+ */
+static void vxge_ethtool_gregs(struct net_device *dev,
+			struct ethtool_regs *regs, void *space)
+{
+	int index, offset;
+	enum vxge_hw_status status;
+	u64 reg;
+	u8 *reg_space = (u8 *) space;
+	struct vxgedev *vdev = (struct vxgedev *)netdev_priv(dev);
+	struct __hw_device  *hldev = (struct __hw_device *)
+					pci_get_drvdata(vdev->pdev);
+
+	regs->len = sizeof(struct vxge_hw_vpath_reg) * vdev->no_of_vpath;
+	regs->version = vdev->pdev->subsystem_device;
+	for (index = 0; index < vdev->no_of_vpath; index++) {
+		for (offset = 0; offset < sizeof(struct vxge_hw_vpath_reg);
+				offset += 8) {
+			status = vxge_hw_mgmt_reg_read(hldev,
+					vxge_hw_mgmt_reg_type_vpath,
+					vdev->vpaths[index].device_id,
+					offset, &reg);
+			if (status != VXGE_HW_OK) {
+				vxge_debug_init(VXGE_ERR,
+					"%s:%d Getting reg dump Failed",
+						__func__, __LINE__);
+				return;
+			}
+
+			memcpy((reg_space + offset), &reg, 8);
+		}
+	}
+}
+
+/**
+ * vxge_hw_phy_id  - timer function that alternates adapter LED.
+ * @data: address of the private member of the device structure, which
+ * is a pointer to the vxge_nic structure.
+ *
+ * This is actually the timer function that alternates the
+ * adapter LED bit of the adapter control bit to set/reset every time on
+ * invocation. The timer is set for 1/2 a second, hence tha NIC blinks
+ * once every second.
+ */
+static void vxge_phy_id(unsigned long data)
+{
+	struct vxgedev *vdev = (struct vxgedev *)data;
+	struct __hw_device  *hldev = (struct __hw_device  *) pci_get_drvdata(
+						vdev->pdev);
+	u32 port[3] = {0, 1, 2};
+	int i;
+
+	for (i = 0 ; i < 3; i++)
+		vxge_hw_device_flick_link_led(hldev, port[i]);
+
+	mod_timer(&vdev->id_timer, jiffies + HZ / 2);
+}
+
+/*
+ * vxge_ethtool_idnic - To physically identify the nic on the system.
+ * @dev : device pointer.
+ * @id : pointer to the structure with identification parameters given by
+ * ethtool.
+ *
+ * Used to physically identify the NIC on the system.
+ * The Link LED will blink for a time specified by the user for
+ * identification.
+ * NOTE: For XFrame 3 and lower Rev cards, the Link has to be Up
+ * to be able to blink the LED. Hence identification is possible
+ * only if it's link is up.
+ * Return value:
+ * 0 on success
+ */
+static int vxge_ethtool_idnic(struct net_device *dev, u32 data)
+{
+	u32 port[3] = {0, 1, 2};
+	int i;
+	struct vxgedev *vdev = (struct vxgedev *)netdev_priv(dev);
+	struct __hw_device  *hldev = (struct __hw_device  *)
+			pci_get_drvdata(vdev->pdev);
+
+	if (vdev->id_timer.function == NULL) {
+		init_timer(&vdev->id_timer);
+		vdev->id_timer.function = vxge_phy_id;
+		vdev->id_timer.data = (unsigned long) vdev;
+	}
+	mod_timer(&vdev->id_timer, jiffies);
+	set_current_state(TASK_INTERRUPTIBLE);
+	if (data)
+		schedule_timeout(data * HZ);
+	else
+		schedule_timeout(MAX_SCHEDULE_TIMEOUT);
+	del_timer_sync(&vdev->id_timer);
+
+	/*
+	 * Restore the original state of Link LED(ON/OFF).
+	 */
+	for (i = 0 ; i < 3; i++)
+		vxge_hw_device_restore_link_led(hldev, port[i]);
+
+	return 0;
+}
+
+/**
+ * vxge_ethtool_getpause_data -
+ */
+static void vxge_ethtool_getpause_data(struct net_device *dev,
+					struct ethtool_pauseparam *ep)
+{
+	struct vxgedev *vdev = (struct vxgedev *)netdev_priv(dev);
+	struct __hw_device  *hldev = (struct __hw_device  *)
+			pci_get_drvdata(vdev->pdev);
+	/* Calling only for port 0. Need check on this */
+	vxge_hw_device_getpause_data(hldev, 0, &ep->tx_pause, &ep->rx_pause);
+}
+
+/**
+ * vxge_ethtool_setpause_data -
+ */
+static int vxge_ethtool_setpause_data(struct net_device *dev,
+					struct ethtool_pauseparam *ep)
+{
+	struct vxgedev *vdev = (struct vxgedev *)netdev_priv(dev);
+	struct __hw_device  *hldev = (struct __hw_device  *)
+			pci_get_drvdata(vdev->pdev);
+
+	vxge_hw_device_setpause_data(hldev, 0, ep->tx_pause, ep->rx_pause);
+
+	vdev->config.tx_pause_enable = ep->tx_pause;
+	vdev->config.rx_pause_enable = ep->rx_pause;
+
+	return 0;
+}
+
+static void vxge_get_ethtool_stats(struct net_device *dev,
+			   struct ethtool_stats *estats, u64 *tmp_stats)
+{
+	int j, k;
+	enum vxge_hw_status status;
+	enum vxge_hw_status swstatus;
+	struct vxge_vpath *vpath = NULL;
+
+	struct vxgedev *vdev = (struct vxgedev *)netdev_priv(dev);
+	struct __hw_device  *hldev = (struct __hw_device  *) vdev->devh;
+	struct vxge_hw_xmac_stats *xmac_stats;
+	struct vxge_hw_device_stats_sw_info *sw_stats;
+	struct vxge_hw_device_stats_hw_info *hw_stats;
+
+	u64 *ptr = tmp_stats;
+
+	memset(tmp_stats, 0,
+		vxge_ethtool_get_stats_count(dev) * sizeof(u64));
+
+	xmac_stats = kmalloc(sizeof(struct vxge_hw_xmac_stats), GFP_KERNEL);
+	if (xmac_stats == NULL) {
+		vxge_debug_init(VXGE_ERR,
+			"%s : %d Memory Allocation failed for xmac_stats \n",
+				 __func__, __LINE__);
+		return;
+	}
+	memset(xmac_stats, 0, sizeof(struct vxge_hw_xmac_stats));
+
+	sw_stats = kmalloc(sizeof(struct vxge_hw_device_stats_sw_info),
+				GFP_KERNEL);
+	if (sw_stats == NULL) {
+		kfree(xmac_stats);
+		vxge_debug_init(VXGE_ERR,
+			"%s : %d Memory Allocation failed for sw_stats \n",
+			__func__, __LINE__);
+		return;
+	}
+	memset(sw_stats, 0, sizeof(struct vxge_hw_device_stats_sw_info));
+
+	hw_stats = kmalloc(sizeof(struct vxge_hw_device_stats_hw_info),
+				GFP_KERNEL);
+	if (hw_stats == NULL) {
+		kfree(xmac_stats);
+		kfree(sw_stats);
+		vxge_debug_init(VXGE_ERR,
+			"%s : %d Memory Allocation failed for hw_stats \n",
+			__func__, __LINE__);
+		return;
+	}
+	memset(hw_stats, 0, sizeof(struct vxge_hw_device_stats_hw_info));
+
+	*ptr++ = 0;
+	status = vxge_hw_device_xmac_stats_get(hldev, xmac_stats);
+	if (status != VXGE_HW_OK) {
+		if (status != VXGE_HW_ERR_PRIVILAGED_OPEARATION) {
+			vxge_debug_init(VXGE_ERR,
+				"%s : %d Failure in getting xmac stats\n",
+				__func__, __LINE__);
+		}
+	}
+	swstatus = vxge_hw_driver_stats_get(hldev, sw_stats);
+	if (swstatus != VXGE_HW_OK) {
+		vxge_debug_init(VXGE_ERR,
+			"%s : %d Failure in getting sw stats\n",
+			__func__, __LINE__);
+	}
+
+	if (vxge_hw_device_hw_stats_enable(hldev) != VXGE_HW_OK) {
+		vxge_debug_init(VXGE_ERR,
+			"%s : %d hw_stats_enable error\n",
+			__func__, __LINE__);
+	} else {
+		status = vxge_hw_device_stats_get(hldev, hw_stats);
+		if (status != VXGE_HW_OK) {
+			vxge_debug_init(VXGE_ERR,
+				"%s : %d hw_stats_get error\n",
+				__func__, __LINE__);
+		}
+	}
+
+	for (k = 0; k < vdev->no_of_vpath; k++) {
+		struct vxge_hw_vpath_stats_hw_info *vpath_info;
+
+		vpath = &vdev->vpaths[k];
+		j = vpath->device_id;
+		vpath_info = hw_stats->vpath_info[j];
+		if (!vpath_info) {
+			memset(ptr, 0, (VXGE_HW_VPATH_TX_STATS_LEN +
+				VXGE_HW_VPATH_RX_STATS_LEN) * sizeof(u64));
+			ptr += (VXGE_HW_VPATH_TX_STATS_LEN +
+				VXGE_HW_VPATH_RX_STATS_LEN);
+			continue;
+		}
+
+		*ptr++ = vpath_info->tx_stats.tx_ttl_eth_frms;
+		*ptr++ = vpath_info->tx_stats.tx_ttl_eth_octets;
+		*ptr++ = vpath_info->tx_stats.tx_data_octets;
+		*ptr++ = vpath_info->tx_stats.tx_mcast_frms;
+		*ptr++ = vpath_info->tx_stats.tx_bcast_frms;
+		*ptr++ = vpath_info->tx_stats.tx_ucast_frms;
+		*ptr++ = vpath_info->tx_stats.tx_tagged_frms;
+		*ptr++ = vpath_info->tx_stats.tx_vld_ip;
+		*ptr++ = vpath_info->tx_stats.tx_vld_ip_octets;
+		*ptr++ = vpath_info->tx_stats.tx_icmp;
+		*ptr++ = vpath_info->tx_stats.tx_tcp;
+		*ptr++ = vpath_info->tx_stats.tx_rst_tcp;
+		*ptr++ = vpath_info->tx_stats.tx_udp;
+		*ptr++ = vpath_info->tx_stats.tx_unknown_protocol;
+		*ptr++ = vpath_info->tx_stats.tx_lost_ip;
+		*ptr++ = vpath_info->tx_stats.tx_parse_error;
+		*ptr++ = vpath_info->tx_stats.tx_tcp_offload;
+		*ptr++ = vpath_info->tx_stats.tx_retx_tcp_offload;
+		*ptr++ = vpath_info->tx_stats.tx_lost_ip_offload;
+		*ptr++ = vpath_info->rx_stats.rx_ttl_eth_frms;
+		*ptr++ = vpath_info->rx_stats.rx_vld_frms;
+		*ptr++ = vpath_info->rx_stats.rx_offload_frms;
+		*ptr++ = vpath_info->rx_stats.rx_ttl_eth_octets;
+		*ptr++ = vpath_info->rx_stats.rx_data_octets;
+		*ptr++ = vpath_info->rx_stats.rx_offload_octets;
+		*ptr++ = vpath_info->rx_stats.rx_vld_mcast_frms;
+		*ptr++ = vpath_info->rx_stats.rx_vld_bcast_frms;
+		*ptr++ = vpath_info->rx_stats.rx_accepted_ucast_frms;
+		*ptr++ = vpath_info->rx_stats.rx_accepted_nucast_frms;
+		*ptr++ = vpath_info->rx_stats.rx_tagged_frms;
+		*ptr++ = vpath_info->rx_stats.rx_long_frms;
+		*ptr++ = vpath_info->rx_stats.rx_usized_frms;
+		*ptr++ = vpath_info->rx_stats.rx_osized_frms;
+		*ptr++ = vpath_info->rx_stats.rx_frag_frms;
+		*ptr++ = vpath_info->rx_stats.rx_jabber_frms;
+		*ptr++ = vpath_info->rx_stats.rx_ttl_64_frms;
+		*ptr++ = vpath_info->rx_stats.rx_ttl_65_127_frms;
+		*ptr++ = vpath_info->rx_stats.rx_ttl_128_255_frms;
+		*ptr++ = vpath_info->rx_stats.rx_ttl_256_511_frms;
+		*ptr++ = vpath_info->rx_stats.rx_ttl_512_1023_frms;
+		*ptr++ = vpath_info->rx_stats.rx_ttl_1024_1518_frms;
+		*ptr++ = vpath_info->rx_stats.rx_ttl_1519_4095_frms;
+		*ptr++ = vpath_info->rx_stats.rx_ttl_4096_8191_frms;
+		*ptr++ = vpath_info->rx_stats.rx_ttl_8192_max_frms;
+		*ptr++ = vpath_info->rx_stats.rx_ttl_gt_max_frms;
+		*ptr++ = vpath_info->rx_stats.rx_ip;
+		*ptr++ = vpath_info->rx_stats.rx_accepted_ip;
+		*ptr++ = vpath_info->rx_stats.rx_ip_octets;
+		*ptr++ = vpath_info->rx_stats.rx_err_ip;
+		*ptr++ = vpath_info->rx_stats.rx_icmp;
+		*ptr++ = vpath_info->rx_stats.rx_tcp;
+		*ptr++ = vpath_info->rx_stats.rx_udp;
+		*ptr++ = vpath_info->rx_stats.rx_err_tcp;
+		*ptr++ = vpath_info->rx_stats.rx_lost_frms;
+		*ptr++ = vpath_info->rx_stats.rx_lost_ip;
+		*ptr++ = vpath_info->rx_stats.rx_lost_ip_offload;
+		*ptr++ = vpath_info->rx_stats.rx_various_discard;
+		*ptr++ = vpath_info->rx_stats.rx_sleep_discard;
+		*ptr++ = vpath_info->rx_stats.rx_red_discard;
+		*ptr++ = vpath_info->rx_stats.rx_queue_full_discard;
+		*ptr++ = vpath_info->rx_stats.rx_mpa_ok_frms;
+	}
+	*ptr++ = 0;
+	for (j = 0; j < vdev->max_config_port; j++) {
+		*ptr++ = xmac_stats->aggr_stats[j].tx_frms;
+		*ptr++ = xmac_stats->aggr_stats[j].tx_data_octets;
+		*ptr++ = xmac_stats->aggr_stats[j].tx_mcast_frms;
+		*ptr++ = xmac_stats->aggr_stats[j].tx_bcast_frms;
+		*ptr++ = xmac_stats->aggr_stats[j].tx_discarded_frms;
+		*ptr++ = xmac_stats->aggr_stats[j].tx_errored_frms;
+		*ptr++ = xmac_stats->aggr_stats[j].rx_frms;
+		*ptr++ = xmac_stats->aggr_stats[j].rx_data_octets;
+		*ptr++ = xmac_stats->aggr_stats[j].rx_mcast_frms;
+		*ptr++ = xmac_stats->aggr_stats[j].rx_bcast_frms;
+		*ptr++ = xmac_stats->aggr_stats[j].rx_discarded_frms;
+		*ptr++ = xmac_stats->aggr_stats[j].rx_errored_frms;
+		*ptr++ = xmac_stats->aggr_stats[j].rx_unknown_slow_proto_frms;
+	}
+	*ptr++ = 0;
+	for (j = 0; j < vdev->max_config_port; j++) {
+		*ptr++ = xmac_stats->port_stats[j].tx_ttl_frms;
+		*ptr++ = xmac_stats->port_stats[j].tx_ttl_octets;
+		*ptr++ = xmac_stats->port_stats[j].tx_data_octets;
+		*ptr++ = xmac_stats->port_stats[j].tx_mcast_frms;
+		*ptr++ = xmac_stats->port_stats[j].tx_bcast_frms;
+		*ptr++ = xmac_stats->port_stats[j].tx_ucast_frms;
+		*ptr++ = xmac_stats->port_stats[j].tx_tagged_frms;
+		*ptr++ = xmac_stats->port_stats[j].tx_vld_ip;
+		*ptr++ = xmac_stats->port_stats[j].tx_vld_ip_octets;
+		*ptr++ = xmac_stats->port_stats[j].tx_icmp;
+		*ptr++ = xmac_stats->port_stats[j].tx_tcp;
+		*ptr++ = xmac_stats->port_stats[j].tx_rst_tcp;
+		*ptr++ = xmac_stats->port_stats[j].tx_udp;
+		*ptr++ = xmac_stats->port_stats[j].tx_parse_error;
+		*ptr++ = xmac_stats->port_stats[j].tx_unknown_protocol;
+		*ptr++ = xmac_stats->port_stats[j].tx_pause_ctrl_frms;
+		*ptr++ = xmac_stats->port_stats[j].tx_marker_pdu_frms;
+		*ptr++ = xmac_stats->port_stats[j].tx_lacpdu_frms;
+		*ptr++ = xmac_stats->port_stats[j].tx_drop_ip;
+		*ptr++ = xmac_stats->port_stats[j].tx_marker_resp_pdu_frms;
+		*ptr++ = xmac_stats->port_stats[j].tx_xgmii_char2_match;
+		*ptr++ = xmac_stats->port_stats[j].tx_xgmii_char1_match;
+		*ptr++ = xmac_stats->port_stats[j].tx_xgmii_column2_match;
+		*ptr++ = xmac_stats->port_stats[j].tx_xgmii_column1_match;
+		*ptr++ = xmac_stats->port_stats[j].tx_any_err_frms;
+		*ptr++ = xmac_stats->port_stats[j].tx_drop_frms;
+		*ptr++ = xmac_stats->port_stats[j].rx_ttl_frms;
+		*ptr++ = xmac_stats->port_stats[j].rx_vld_frms;
+		*ptr++ = xmac_stats->port_stats[j].rx_offload_frms;
+		*ptr++ = xmac_stats->port_stats[j].rx_ttl_octets;
+		*ptr++ = xmac_stats->port_stats[j].rx_data_octets;
+		*ptr++ = xmac_stats->port_stats[j].rx_offload_octets;
+		*ptr++ = xmac_stats->port_stats[j].rx_vld_mcast_frms;
+		*ptr++ = xmac_stats->port_stats[j].rx_vld_bcast_frms;
+		*ptr++ = xmac_stats->port_stats[j].rx_accepted_ucast_frms;
+		*ptr++ = xmac_stats->port_stats[j].rx_accepted_nucast_frms;
+		*ptr++ = xmac_stats->port_stats[j].rx_tagged_frms;
+		*ptr++ = xmac_stats->port_stats[j].rx_long_frms;
+		*ptr++ = xmac_stats->port_stats[j].rx_usized_frms;
+		*ptr++ = xmac_stats->port_stats[j].rx_osized_frms;
+		*ptr++ = xmac_stats->port_stats[j].rx_frag_frms;
+		*ptr++ = xmac_stats->port_stats[j].rx_jabber_frms;
+		*ptr++ = xmac_stats->port_stats[j].rx_ttl_64_frms;
+		*ptr++ = xmac_stats->port_stats[j].rx_ttl_65_127_frms;
+		*ptr++ = xmac_stats->port_stats[j].rx_ttl_128_255_frms;
+		*ptr++ = xmac_stats->port_stats[j].rx_ttl_256_511_frms;
+		*ptr++ = xmac_stats->port_stats[j].rx_ttl_512_1023_frms;
+		*ptr++ = xmac_stats->port_stats[j].rx_ttl_1024_1518_frms;
+		*ptr++ = xmac_stats->port_stats[j].rx_ttl_1519_4095_frms;
+		*ptr++ = xmac_stats->port_stats[j].rx_ttl_4096_8191_frms;
+		*ptr++ = xmac_stats->port_stats[j].rx_ttl_8192_max_frms;
+		*ptr++ = xmac_stats->port_stats[j].rx_ttl_gt_max_frms;
+		*ptr++ = xmac_stats->port_stats[j].rx_ip;
+		*ptr++ = xmac_stats->port_stats[j].rx_accepted_ip;
+		*ptr++ = xmac_stats->port_stats[j].rx_ip_octets;
+		*ptr++ = xmac_stats->port_stats[j].rx_err_ip;
+		*ptr++ = xmac_stats->port_stats[j].rx_icmp;
+		*ptr++ = xmac_stats->port_stats[j].rx_tcp;
+		*ptr++ = xmac_stats->port_stats[j].rx_udp;
+		*ptr++ = xmac_stats->port_stats[j].rx_err_tcp;
+		*ptr++ = xmac_stats->port_stats[j].rx_pause_count;
+		*ptr++ = xmac_stats->port_stats[j].rx_pause_ctrl_frms;
+		*ptr++ = xmac_stats->port_stats[j].rx_unsup_ctrl_frms;
+		*ptr++ = xmac_stats->port_stats[j].rx_fcs_err_frms;
+		*ptr++ = xmac_stats->port_stats[j].rx_in_rng_len_err_frms;
+		*ptr++ = xmac_stats->port_stats[j].rx_out_rng_len_err_frms;
+		*ptr++ = xmac_stats->port_stats[j].rx_drop_frms;
+		*ptr++ = xmac_stats->port_stats[j].rx_discarded_frms;
+		*ptr++ = xmac_stats->port_stats[j].rx_drop_ip;
+		*ptr++ = xmac_stats->port_stats[j].rx_drop_udp;
+		*ptr++ = xmac_stats->port_stats[j].rx_marker_pdu_frms;
+		*ptr++ = xmac_stats->port_stats[j].rx_lacpdu_frms;
+		*ptr++ = xmac_stats->port_stats[j].rx_unknown_pdu_frms;
+		*ptr++ = xmac_stats->port_stats[j].rx_marker_resp_pdu_frms;
+		*ptr++ = xmac_stats->port_stats[j].rx_fcs_discard;
+		*ptr++ = xmac_stats->port_stats[j].rx_illegal_pdu_frms;
+		*ptr++ = xmac_stats->port_stats[j].rx_switch_discard;
+		*ptr++ = xmac_stats->port_stats[j].rx_len_discard;
+		*ptr++ = xmac_stats->port_stats[j].rx_rpa_discard;
+		*ptr++ = xmac_stats->port_stats[j].rx_l2_mgmt_discard;
+		*ptr++ = xmac_stats->port_stats[j].rx_rts_discard;
+		*ptr++ = xmac_stats->port_stats[j].rx_trash_discard;
+		*ptr++ = xmac_stats->port_stats[j].rx_buff_full_discard;
+		*ptr++ = xmac_stats->port_stats[j].rx_red_discard;
+		*ptr++ = xmac_stats->port_stats[j].rx_xgmii_ctrl_err_cnt;
+		*ptr++ = xmac_stats->port_stats[j].rx_xgmii_data_err_cnt;
+		*ptr++ = xmac_stats->port_stats[j].rx_xgmii_char1_match;
+		*ptr++ = xmac_stats->port_stats[j].rx_xgmii_err_sym;
+		*ptr++ = xmac_stats->port_stats[j].rx_xgmii_column1_match;
+		*ptr++ = xmac_stats->port_stats[j].rx_xgmii_char2_match;
+		*ptr++ = xmac_stats->port_stats[j].rx_local_fault;
+		*ptr++ = xmac_stats->port_stats[j].rx_xgmii_column2_match;
+		*ptr++ = xmac_stats->port_stats[j].rx_jettison;
+		*ptr++ = xmac_stats->port_stats[j].rx_remote_fault;
+	}
+
+	*ptr++ = 0;
+	for (k = 0; k < vdev->no_of_vpath; k++) {
+		struct vxge_hw_vpath_stats_sw_info *vpath_info;
+
+		vpath = &vdev->vpaths[k];
+		j = vpath->device_id;
+		vpath_info = (struct vxge_hw_vpath_stats_sw_info *)
+				&sw_stats->vpath_info[j];
+		*ptr++ = vpath_info->soft_reset_cnt;
+		*ptr++ = vpath_info->error_stats.unknown_alarms;
+		*ptr++ = vpath_info->error_stats.network_sustained_fault;
+		*ptr++ = vpath_info->error_stats.network_sustained_ok;
+		*ptr++ = vpath_info->error_stats.kdfcctl_fifo0_overwrite;
+		*ptr++ = vpath_info->error_stats.kdfcctl_fifo0_poison;
+		*ptr++ = vpath_info->error_stats.kdfcctl_fifo0_dma_error;
+		*ptr++ = vpath_info->error_stats.kdfcctl_fifo1_overwrite;
+		*ptr++ = vpath_info->error_stats.kdfcctl_fifo1_poison;
+		*ptr++ = vpath_info->error_stats.kdfcctl_fifo1_dma_error;
+		*ptr++ = vpath_info->error_stats.kdfcctl_fifo2_overwrite;
+		*ptr++ = vpath_info->error_stats.kdfcctl_fifo2_poison;
+		*ptr++ = vpath_info->error_stats.kdfcctl_fifo2_dma_error;
+		*ptr++ = vpath_info->error_stats.dblgen_fifo0_overflow;
+		*ptr++ = vpath_info->error_stats.dblgen_fifo1_overflow;
+		*ptr++ = vpath_info->error_stats.dblgen_fifo2_overflow;
+		*ptr++ = vpath_info->error_stats.statsb_pif_chain_error;
+		*ptr++ = vpath_info->error_stats.statsb_drop_timeout;
+		*ptr++ = vpath_info->error_stats.target_illegal_access;
+		*ptr++ = vpath_info->error_stats.ini_serr_det;
+		*ptr++ = vpath_info->error_stats.pci_config_status_err;
+		*ptr++ = vpath_info->error_stats.pci_config_uncor_err;
+		*ptr++ = vpath_info->error_stats.pci_config_cor_err;
+		*ptr++ = vpath_info->error_stats.mrpcim_to_vpath_alarms;
+		*ptr++ = vpath_info->error_stats.srpcim_to_vpath_alarms;
+		*ptr++ = vpath_info->error_stats.srpcim_msg_to_vpath;
+		*ptr++ = vpath_info->error_stats.prc_ring_bumps;
+		*ptr++ = vpath_info->error_stats.prc_rxdcm_sc_err;
+		*ptr++ = vpath_info->error_stats.prc_rxdcm_sc_abort;
+		*ptr++ = vpath_info->error_stats.prc_quanta_size_err;
+		*ptr++ = vpath_info->ring_stats.common_stats.full_cnt;
+		*ptr++ = vpath_info->ring_stats.common_stats.usage_cnt;
+		*ptr++ = vpath_info->ring_stats.common_stats.usage_max;
+		*ptr++ = vpath_info->ring_stats.common_stats.
+					reserve_free_swaps_cnt;
+		*ptr++ = vpath_info->ring_stats.common_stats.
+					avg_compl_per_intr_cnt;
+		*ptr++ = vpath_info->ring_stats.common_stats.total_compl_cnt;
+		*ptr++ = vpath_info->ring_stats.rxd_t_code_err_cnt[0];
+		*ptr++ = vpath_info->ring_stats.rxd_t_code_err_cnt[1];
+		*ptr++ = vpath_info->ring_stats.rxd_t_code_err_cnt[2];
+		*ptr++ = vpath_info->ring_stats.rxd_t_code_err_cnt[3];
+		*ptr++ = vpath_info->ring_stats.rxd_t_code_err_cnt[4];
+		*ptr++ = vpath_info->ring_stats.rxd_t_code_err_cnt[5];
+		*ptr++ = vpath_info->ring_stats.rxd_t_code_err_cnt[6];
+		*ptr++ = vpath_info->ring_stats.rxd_t_code_err_cnt[7];
+		*ptr++ = vpath_info->ring_stats.rxd_t_code_err_cnt[8];
+		*ptr++ = vpath_info->ring_stats.rxd_t_code_err_cnt[9];
+		*ptr++ = vpath_info->ring_stats.rxd_t_code_err_cnt[10];
+		*ptr++ = vpath_info->ring_stats.rxd_t_code_err_cnt[11];
+		*ptr++ = vpath_info->ring_stats.rxd_t_code_err_cnt[12];
+		*ptr++ = vpath_info->ring_stats.rxd_t_code_err_cnt[13];
+		*ptr++ = vpath_info->ring_stats.rxd_t_code_err_cnt[14];
+		*ptr++ = vpath_info->ring_stats.rxd_t_code_err_cnt[15];
+
+		*ptr++ = vpath->ring.lro_mgr.stats.aggregated;
+		*ptr++ = vpath->ring.lro_mgr.stats.flushed;
+		*ptr++ = 0;
+		*ptr++ = vpath->ring.lro_mgr.stats.no_desc;
+
+		*ptr = 0;
+		if (*(ptr - 3))
+			*ptr =  (*(ptr - 4)) / (*(ptr - 3));
+		ptr++;
+		*ptr++ = 0;
+
+		*ptr++ = vpath_info->fifo_stats.common_stats.full_cnt;
+		*ptr++ = vpath_info->fifo_stats.common_stats.usage_cnt;
+		*ptr++ = vpath_info->fifo_stats.common_stats.usage_max;
+		*ptr++ = vpath_info->fifo_stats.common_stats.
+						reserve_free_swaps_cnt;
+		*ptr++ = vpath_info->fifo_stats.common_stats.
+						avg_compl_per_intr_cnt;
+		*ptr++ = vpath_info->fifo_stats.common_stats.total_compl_cnt;
+
+		*ptr++ = vpath_info->fifo_stats.total_posts;
+		*ptr++ = vpath_info->fifo_stats.total_buffers;
+		*ptr++ = vpath_info->fifo_stats.avg_buffers_per_post;
+		*ptr++ = vpath_info->fifo_stats.copied_frags;
+		*ptr++ = vpath_info->fifo_stats.copied_buffers;
+		*ptr++ = vpath_info->fifo_stats.avg_buffer_size;
+		*ptr++ = vpath_info->fifo_stats.avg_post_size;
+		*ptr++ = vpath_info->fifo_stats.total_posts_dang_dtrs;
+		*ptr++ = vpath_info->fifo_stats.total_posts_dang_frags;
+
+		*ptr++ = vpath_info->fifo_stats.txd_t_code_err_cnt[0];
+		*ptr++ = vpath_info->fifo_stats.txd_t_code_err_cnt[1];
+		*ptr++ = vpath_info->fifo_stats.txd_t_code_err_cnt[2];
+		*ptr++ = vpath_info->fifo_stats.txd_t_code_err_cnt[3];
+		*ptr++ = vpath_info->fifo_stats.txd_t_code_err_cnt[4];
+		*ptr++ = vpath_info->fifo_stats.txd_t_code_err_cnt[5];
+		*ptr++ = vpath_info->fifo_stats.txd_t_code_err_cnt[6];
+		*ptr++ = vpath_info->fifo_stats.txd_t_code_err_cnt[7];
+		*ptr++ = vpath_info->fifo_stats.txd_t_code_err_cnt[8];
+		*ptr++ = vpath_info->fifo_stats.txd_t_code_err_cnt[9];
+		*ptr++ = vpath_info->fifo_stats.txd_t_code_err_cnt[10];
+		*ptr++ = vpath_info->fifo_stats.txd_t_code_err_cnt[11];
+		*ptr++ = vpath_info->fifo_stats.txd_t_code_err_cnt[12];
+		*ptr++ = vpath_info->fifo_stats.txd_t_code_err_cnt[13];
+		*ptr++ = vpath_info->fifo_stats.txd_t_code_err_cnt[14];
+		*ptr++ = vpath_info->fifo_stats.txd_t_code_err_cnt[15];
+		*ptr++ = vpath_info->fifo_stats.total_frags;
+		*ptr++ = vpath_info->fifo_stats.copied_frags;
+	}
+
+	*ptr++ = 0;
+	for (k = 0; k < vdev->no_of_vpath; k++) {
+		struct vxge_hw_vpath_stats_hw_info *vpath_info;
+		vpath = &vdev->vpaths[k];
+		j = vpath->device_id;
+		vpath_info = hw_stats->vpath_info[j];
+		if (!vpath_info) {
+			memset(ptr, 0, VXGE_HW_VPATH_STATS_LEN * sizeof(u64));
+			ptr += VXGE_HW_VPATH_STATS_LEN;
+			continue;
+		}
+		*ptr++ = vpath_info->ini_num_mwr_sent;
+		*ptr++ = vpath_info->ini_num_mrd_sent;
+		*ptr++ = vpath_info->ini_num_cpl_rcvd;
+		*ptr++ = vpath_info->ini_num_mwr_byte_sent;
+		*ptr++ = vpath_info->ini_num_cpl_byte_rcvd;
+		*ptr++ = vpath_info->wrcrdtarb_xoff;
+		*ptr++ = vpath_info->rdcrdtarb_xoff;
+		*ptr++ = vpath_info->vpath_genstats_count0;
+		*ptr++ = vpath_info->vpath_genstats_count1;
+		*ptr++ = vpath_info->vpath_genstats_count2;
+		*ptr++ = vpath_info->vpath_genstats_count3;
+		*ptr++ = vpath_info->vpath_genstats_count4;
+		*ptr++ = vpath_info->vpath_genstats_count5;
+		*ptr++ = vpath_info->prog_event_vnum0;
+		*ptr++ = vpath_info->prog_event_vnum1;
+		*ptr++ = vpath_info->prog_event_vnum2;
+		*ptr++ = vpath_info->prog_event_vnum3;
+		*ptr++ = vpath_info->rx_multi_cast_frame_discard;
+		*ptr++ = vpath_info->rx_frm_transferred;
+		*ptr++ = vpath_info->rxd_returned;
+		*ptr++ = vpath_info->rx_mpa_len_fail_frms;
+		*ptr++ = vpath_info->rx_mpa_mrk_fail_frms;
+		*ptr++ = vpath_info->rx_mpa_crc_fail_frms;
+		*ptr++ = vpath_info->rx_permitted_frms;
+		*ptr++ = vpath_info->rx_vp_reset_discarded_frms;
+		*ptr++ = vpath_info->rx_wol_frms;
+		*ptr++ = vpath_info->tx_vp_reset_discarded_frms;
+	}
+
+	*ptr++ = 0;
+	*ptr++ = vdev->stats.vpaths_open;
+	*ptr++ = vdev->stats.vpath_open_fail;
+	*ptr++ = vdev->stats.link_up;
+	*ptr++ = vdev->stats.link_down;
+
+	for (k = 0; k < vdev->no_of_vpath; k++) {
+		*ptr += vdev->vpaths[k].fifo.stats.tx_frms;
+		*(ptr + 1) += vdev->vpaths[k].fifo.stats.tx_errors;
+		*(ptr + 2) += vdev->vpaths[k].fifo.stats.tx_bytes;
+		*(ptr + 3) += vdev->vpaths[k].fifo.stats.txd_not_free;
+		*(ptr + 4) += vdev->vpaths[k].fifo.stats.txd_out_of_desc;
+		*(ptr + 5) += vdev->vpaths[k].ring.stats.rx_frms;
+		*(ptr + 6) += vdev->vpaths[k].ring.stats.rx_errors;
+		*(ptr + 7) += vdev->vpaths[k].ring.stats.rx_bytes;
+		*(ptr + 8) += vdev->vpaths[k].ring.stats.rx_mcast;
+		*(ptr + 9) += vdev->vpaths[k].fifo.stats.pci_map_fail +
+				vdev->vpaths[k].ring.stats.pci_map_fail;
+		*(ptr + 10) += vdev->vpaths[k].ring.stats.skb_alloc_fail;
+	}
+
+	ptr += 12;
+
+	kfree(xmac_stats);
+	kfree(sw_stats);
+	kfree(hw_stats);
+}
+
+void add_print_string(char *prnt_string, int j, int *stat_size, u8 *data)
+{
+	char data_string[ETH_GSTRING_LEN] = {0};
+	sprintf(data_string, prnt_string, j);
+	memcpy(data + *stat_size, data_string, ETH_GSTRING_LEN);
+	*stat_size += ETH_GSTRING_LEN;
+}
+
+void vxge_ethtool_get_strings(struct net_device *dev,
+			      u32 stringset, u8 *data)
+{
+	int stat_size = 0, i;
+	struct vxgedev *vdev = (struct vxgedev *)netdev_priv(dev);
+	switch (stringset) {
+	case ETH_SS_TEST:
+		memcpy(data, vxge_gstrings, VXGE_STRINGS_LEN);
+		break;
+	case ETH_SS_STATS:
+		add_print_string("VPATH STATISTICS\t\t\t",
+			0, &stat_size, data);
+		for (i = 0; i < vdev->no_of_vpath; i++) {
+			add_print_string("tx_ttl_eth_frms_%d\t\t\t",
+					i, &stat_size, data);
+			add_print_string("tx_ttl_eth_octects_%d\t\t",
+					i, &stat_size, data);
+			add_print_string("tx_data_octects_%d\t\t\t",
+					i, &stat_size, data);
+			add_print_string("tx_mcast_frms_%d\t\t\t",
+					i, &stat_size, data);
+			add_print_string("tx_bcast_frms_%d\t\t\t",
+					i, &stat_size, data);
+			add_print_string("tx_ucast_frms_%d\t\t\t",
+					i, &stat_size, data);
+			add_print_string("tx_tagged_frms_%d\t\t\t",
+					i, &stat_size, data);
+			add_print_string("tx_vld_ip_%d\t\t\t",
+					i, &stat_size, data);
+			add_print_string("tx_vld_ip_octects_%d\t\t",
+					i, &stat_size, data);
+			add_print_string("tx_icmp_%d\t\t\t\t",
+					i, &stat_size, data);
+			add_print_string("tx_tcp_%d\t\t\t\t",
+					i, &stat_size, data);
+			add_print_string("tx_rst_tcp_%d\t\t\t",
+					i, &stat_size, data);
+			add_print_string("tx_udp_%d\t\t\t\t",
+					i, &stat_size, data);
+			add_print_string("tx_unknown_proto_%d\t\t\t",
+					i, &stat_size, data);
+			add_print_string("tx_lost_ip_%d\t\t\t",
+					i, &stat_size, data);
+			add_print_string("tx_parse_error_%d\t\t\t",
+					i, &stat_size, data);
+			add_print_string("tx_tcp_offload_%d\t\t\t",
+					i, &stat_size, data);
+			add_print_string("tx_retx_tcp_offload_%d\t\t",
+					i, &stat_size, data);
+			add_print_string("tx_lost_ip_offload_%d\t\t",
+					i, &stat_size, data);
+			add_print_string("rx_ttl_eth_frms_%d\t\t\t",
+					i, &stat_size, data);
+			add_print_string("rx_vld_frms_%d\t\t\t",
+					i, &stat_size, data);
+			add_print_string("rx_offload_frms_%d\t\t\t",
+					i, &stat_size, data);
+			add_print_string("rx_ttl_eth_octects_%d\t\t",
+					i, &stat_size, data);
+			add_print_string("rx_data_octects_%d\t\t\t",
+					i, &stat_size, data);
+			add_print_string("rx_offload_octects_%d\t\t",
+					i, &stat_size, data);
+			add_print_string("rx_vld_mcast_frms_%d\t\t",
+					i, &stat_size, data);
+			add_print_string("rx_vld_bcast_frms_%d\t\t",
+					i, &stat_size, data);
+			add_print_string("rx_accepted_ucast_frms_%d\t\t",
+					i, &stat_size, data);
+			add_print_string("rx_accepted_nucast_frms_%d\t\t",
+					i, &stat_size, data);
+			add_print_string("rx_tagged_frms_%d\t\t\t",
+					i, &stat_size, data);
+			add_print_string("rx_long_frms_%d\t\t\t",
+					i, &stat_size, data);
+			add_print_string("rx_usized_frms_%d\t\t\t",
+					i, &stat_size, data);
+			add_print_string("rx_osized_frms_%d\t\t\t",
+					i, &stat_size, data);
+			add_print_string("rx_frag_frms_%d\t\t\t",
+					i, &stat_size, data);
+			add_print_string("rx_jabber_frms_%d\t\t\t",
+					i, &stat_size, data);
+			add_print_string("rx_ttl_64_frms_%d\t\t\t",
+					i, &stat_size, data);
+			add_print_string("rx_ttl_65_127_frms_%d\t\t",
+					i, &stat_size, data);
+			add_print_string("rx_ttl_128_255_frms_%d\t\t",
+					i, &stat_size, data);
+			add_print_string("rx_ttl_256_511_frms_%d\t\t",
+					i, &stat_size, data);
+			add_print_string("rx_ttl_512_1023_frms_%d\t\t",
+					i, &stat_size, data);
+			add_print_string("rx_ttl_1024_1518_frms_%d\t\t",
+					i, &stat_size, data);
+			add_print_string("rx_ttl_1519_4095_frms_%d\t\t",
+					i, &stat_size, data);
+			add_print_string("rx_ttl_4096_8191_frms_%d\t\t",
+					i, &stat_size, data);
+			add_print_string("rx_ttl_8192_max_frms_%d\t\t",
+					i, &stat_size, data);
+			add_print_string("rx_ttl_gt_max_frms_%d\t\t",
+					i, &stat_size, data);
+			add_print_string("rx_ip%d\t\t\t\t",
+					i, &stat_size, data);
+			add_print_string("rx_accepted_ip_%d\t\t\t",
+					i, &stat_size, data);
+			add_print_string("rx_ip_octects_%d\t\t\t",
+					i, &stat_size, data);
+			add_print_string("rx_err_ip_%d\t\t\t",
+					i, &stat_size, data);
+			add_print_string("rx_icmp_%d\t\t\t\t",
+					i, &stat_size, data);
+			add_print_string("rx_tcp_%d\t\t\t\t",
+					i, &stat_size, data);
+			add_print_string("rx_udp_%d\t\t\t\t",
+					i, &stat_size, data);
+			add_print_string("rx_err_tcp_%d\t\t\t",
+					i, &stat_size, data);
+			add_print_string("rx_lost_frms_%d\t\t\t",
+					i, &stat_size, data);
+			add_print_string("rx_lost_ip_%d\t\t\t",
+					i, &stat_size, data);
+			add_print_string("rx_lost_ip_offload_%d\t\t",
+					i, &stat_size, data);
+			add_print_string("rx_various_discard_%d\t\t",
+					i, &stat_size, data);
+			add_print_string("rx_sleep_discard_%d\t\t\t",
+					i, &stat_size, data);
+			add_print_string("rx_red_discard_%d\t\t\t",
+					i, &stat_size, data);
+			add_print_string("rx_queue_full_discard_%d\t\t",
+					i, &stat_size, data);
+			add_print_string("rx_mpa_ok_frms_%d\t\t\t",
+					i, &stat_size, data);
+		}
+		add_print_string("\nAGGR STATISTICS\t\t\t\t",
+			0, &stat_size, data);
+		for (i = 0; i < vdev->max_config_port; i++) {
+			add_print_string("tx_frms_%d\t\t\t\t",
+				i, &stat_size, data);
+			add_print_string("tx_data_octects_%d\t\t\t",
+				i, &stat_size, data);
+			add_print_string("tx_mcast_frms_%d\t\t\t",
+				i, &stat_size, data);
+			add_print_string("tx_bcast_frms_%d\t\t\t",
+				i, &stat_size, data);
+			add_print_string("tx_discarded_frms_%d\t\t",
+				i, &stat_size, data);
+			add_print_string("tx_errored_frms_%d\t\t\t",
+				i, &stat_size, data);
+
+			add_print_string("rx_frms_%d\t\t\t\t",
+				i, &stat_size, data);
+			add_print_string("rx_data_octects_%d\t\t\t",
+				i, &stat_size, data);
+			add_print_string("rx_mcast_frms_%d\t\t\t",
+				i, &stat_size, data);
+			add_print_string("rx_bcast_frms_%d\t\t\t",
+				i, &stat_size, data);
+			add_print_string("rx_discarded_frms_%d\t\t",
+				i, &stat_size, data);
+			add_print_string("rx_errored_frms_%d\t\t\t",
+				i, &stat_size, data);
+			add_print_string("rx_unknown_slow_proto_frms_%d\t",
+				i, &stat_size, data);
+		}
+		add_print_string("\nPORT STATISTICS\t\t\t\t",
+			0, &stat_size, data);
+		for (i = 0; i < vdev->max_config_port; i++) {
+			add_print_string("tx_ttl_frms_%d\t\t\t",
+				i, &stat_size, data);
+			add_print_string("tx_ttl_octects_%d\t\t\t",
+				i, &stat_size, data);
+			add_print_string("tx_data_octects_%d\t\t\t",
+				i, &stat_size, data);
+			add_print_string("tx_mcast_frms_%d\t\t\t",
+				i, &stat_size, data);
+			add_print_string("tx_bcast_frms_%d\t\t\t",
+				i, &stat_size, data);
+			add_print_string("tx_ucast_frms_%d\t\t\t",
+				i, &stat_size, data);
+			add_print_string("tx_tagged_frms_%d\t\t\t",
+				i, &stat_size, data);
+			add_print_string("tx_vld_ip_%d\t\t\t",
+				i, &stat_size, data);
+			add_print_string("tx_vld_ip_octects_%d\t\t",
+				i, &stat_size, data);
+			add_print_string("tx_icmp_%d\t\t\t\t",
+				i, &stat_size, data);
+			add_print_string("tx_tcp_%d\t\t\t\t",
+				i, &stat_size, data);
+			add_print_string("tx_rst_tcp_%d\t\t\t",
+				i, &stat_size, data);
+			add_print_string("tx_udp_%d\t\t\t\t",
+				i, &stat_size, data);
+			add_print_string("tx_parse_error_%d\t\t\t",
+				i, &stat_size, data);
+			add_print_string("tx_unknown_protocol_%d\t\t",
+				i, &stat_size, data);
+			add_print_string("tx_pause_ctrl_frms_%d\t\t",
+				i, &stat_size, data);
+			add_print_string("tx_marker_pdu_frms_%d\t\t",
+				i, &stat_size, data);
+			add_print_string("tx_lacpdu_frms_%d\t\t\t",
+				i, &stat_size, data);
+			add_print_string("tx_drop_ip_%d\t\t\t",
+				i, &stat_size, data);
+			add_print_string("tx_marker_resp_pdu_frms_%d\t\t",
+				i, &stat_size, data);
+			add_print_string("tx_xgmii_char2_match_%d\t\t",
+				i, &stat_size, data);
+			add_print_string("tx_xgmii_char1_match_%d\t\t",
+				i, &stat_size, data);
+			add_print_string("tx_xgmii_column2_match_%d\t\t",
+				i, &stat_size, data);
+			add_print_string("tx_xgmii_column1_match_%d\t\t",
+			i, &stat_size, data);
+			add_print_string("tx_any_err_frms_%d\t\t\t",
+				i, &stat_size, data);
+			add_print_string("tx_drop_frms_%d\t\t\t",
+				i, &stat_size, data);
+			add_print_string("rx_ttl_frms_%d\t\t\t",
+				i, &stat_size, data);
+			add_print_string("rx_vld_frms_%d\t\t\t",
+				i, &stat_size, data);
+			add_print_string("rx_offload_frms_%d\t\t\t",
+				i, &stat_size, data);
+			add_print_string("rx_ttl_octects_%d\t\t\t",
+				i, &stat_size, data);
+			add_print_string("rx_data_octects_%d\t\t\t",
+				i, &stat_size, data);
+			add_print_string("rx_offload_octects_%d\t\t",
+				i, &stat_size, data);
+			add_print_string("rx_vld_mcast_frms_%d\t\t",
+				i, &stat_size, data);
+			add_print_string("rx_vld_bcast_frms_%d\t\t",
+				i, &stat_size, data);
+			add_print_string("rx_accepted_ucast_frms_%d\t\t",
+				i, &stat_size, data);
+			add_print_string("rx_accepted_nucast_frms_%d\t\t",
+				i, &stat_size, data);
+			add_print_string("rx_tagged_frms_%d\t\t\t",
+				i, &stat_size, data);
+			add_print_string("rx_long_frms_%d\t\t\t",
+				i, &stat_size, data);
+			add_print_string("rx_usized_frms_%d\t\t\t",
+				i, &stat_size, data);
+			add_print_string("rx_osized_frms_%d\t\t\t",
+				i, &stat_size, data);
+			add_print_string("rx_frag_frms_%d\t\t\t",
+				i, &stat_size, data);
+			add_print_string("rx_jabber_frms_%d\t\t\t",
+				i, &stat_size, data);
+			add_print_string("rx_ttl_64_frms_%d\t\t\t",
+				i, &stat_size, data);
+			add_print_string("rx_ttl_65_127_frms_%d\t\t",
+				i, &stat_size, data);
+			add_print_string("rx_ttl_128_255_frms_%d\t\t",
+				i, &stat_size, data);
+			add_print_string("rx_ttl_256_511_frms_%d\t\t",
+				i, &stat_size, data);
+			add_print_string("rx_ttl_512_1023_frms_%d\t\t",
+				i, &stat_size, data);
+			add_print_string("rx_ttl_1024_1518_frms_%d\t\t",
+				i, &stat_size, data);
+			add_print_string("rx_ttl_1519_4095_frms_%d\t\t",
+				i, &stat_size, data);
+			add_print_string("rx_ttl_4096_8191_frms_%d\t\t",
+				i, &stat_size, data);
+			add_print_string("rx_ttl_8192_max_frms_%d\t\t",
+				i, &stat_size, data);
+			add_print_string("rx_ttl_gt_max_frms_%d\t\t",
+				i, &stat_size, data);
+			add_print_string("rx_ip_%d\t\t\t\t",
+				i, &stat_size, data);
+			add_print_string("rx_accepted_ip_%d\t\t\t",
+				i, &stat_size, data);
+			add_print_string("rx_ip_octets_%d\t\t\t",
+				i, &stat_size, data);
+			add_print_string("rx_err_ip_%d\t\t\t",
+				i, &stat_size, data);
+			add_print_string("rx_icmp_%d\t\t\t\t",
+				i, &stat_size, data);
+			add_print_string("rx_tcp_%d\t\t\t\t",
+				i, &stat_size, data);
+			add_print_string("rx_udp_%d\t\t\t\t",
+				i, &stat_size, data);
+			add_print_string("rx_err_tcp_%d\t\t\t",
+				i, &stat_size, data);
+			add_print_string("rx_pause_count_%d\t\t\t",
+				i, &stat_size, data);
+			add_print_string("rx_pause_ctrl_frms_%d\t\t",
+				i, &stat_size, data);
+			add_print_string("rx_unsup_ctrl_frms_%d\t\t",
+				i, &stat_size, data);
+			add_print_string("rx_fcs_err_frms_%d\t\t\t",
+				i, &stat_size, data);
+			add_print_string("rx_in_rng_len_err_frms_%d\t\t",
+				i, &stat_size, data);
+			add_print_string("rx_out_rng_len_err_frms_%d\t\t",
+				i, &stat_size, data);
+			add_print_string("rx_drop_frms_%d\t\t\t",
+				i, &stat_size, data);
+			add_print_string("rx_discard_frms_%d\t\t\t",
+				i, &stat_size, data);
+			add_print_string("rx_drop_ip_%d\t\t\t",
+				i, &stat_size, data);
+			add_print_string("rx_drop_udp_%d\t\t\t",
+				i, &stat_size, data);
+			add_print_string("rx_marker_pdu_frms_%d\t\t",
+				i, &stat_size, data);
+			add_print_string("rx_lacpdu_frms_%d\t\t\t",
+				i, &stat_size, data);
+			add_print_string("rx_unknown_pdu_frms_%d\t\t",
+				i, &stat_size, data);
+			add_print_string("rx_marker_resp_pdu_frms_%d\t\t",
+				i, &stat_size, data);
+			add_print_string("rx_fcs_discard_%d\t\t\t",
+				i, &stat_size, data);
+			add_print_string("rx_illegal_pdu_frms_%d\t\t",
+				i, &stat_size, data);
+			add_print_string("rx_switch_discard_%d\t\t",
+				i, &stat_size, data);
+			add_print_string("rx_len_discard_%d\t\t\t",
+				i, &stat_size, data);
+			add_print_string("rx_rpa_discard_%d\t\t\t",
+				i, &stat_size, data);
+			add_print_string("rx_l2_mgmt_discard_%d\t\t",
+				i, &stat_size, data);
+			add_print_string("rx_rts_discard_%d\t\t\t",
+				i, &stat_size, data);
+			add_print_string("rx_trash_discard_%d\t\t\t",
+				i, &stat_size, data);
+			add_print_string("rx_buff_full_discard_%d\t\t",
+				i, &stat_size, data);
+			add_print_string("rx_red_discard_%d\t\t\t",
+				i, &stat_size, data);
+			add_print_string("rx_xgmii_ctrl_err_cnt_%d\t\t",
+				i, &stat_size, data);
+			add_print_string("rx_xgmii_data_err_cnt_%d\t\t",
+				i, &stat_size, data);
+			add_print_string("rx_xgmii_char1_match_%d\t\t",
+				i, &stat_size, data);
+			add_print_string("rx_xgmii_err_sym_%d\t\t\t",
+				i, &stat_size, data);
+			add_print_string("rx_xgmii_column1_match_%d\t\t",
+				i, &stat_size, data);
+			add_print_string("rx_xgmii_char2_match_%d\t\t",
+				i, &stat_size, data);
+			add_print_string("rx_local_fault_%d\t\t\t",
+				i, &stat_size, data);
+			add_print_string("rx_xgmii_column2_match_%d\t\t",
+				i, &stat_size, data);
+			add_print_string("rx_jettison_%d\t\t\t",
+				i, &stat_size, data);
+			add_print_string("rx_remote_fault_%d\t\t\t",
+				i, &stat_size, data);
+		}
+		add_print_string("\n SOFTWARE STATISTICS\t\t\t",
+			0, &stat_size, data);
+		for (i = 0; i < vdev->no_of_vpath; i++) {
+			add_print_string("soft_reset_cnt_%d\t\t\t",
+				i, &stat_size, data);
+			add_print_string("unknown_alarms_%d\t\t\t",
+				i, &stat_size, data);
+			add_print_string("network_sustained_fault_%d\t\t",
+				i, &stat_size, data);
+			add_print_string("network_sustained_ok_%d\t\t",
+				i, &stat_size, data);
+			add_print_string("kdfcctl_fifo0_overwrite_%d\t\t",
+				i, &stat_size, data);
+			add_print_string("kdfcctl_fifo0_poison_%d\t\t",
+				i, &stat_size, data);
+			add_print_string("kdfcctl_fifo0_dma_error_%d\t\t",
+				i, &stat_size, data);
+			add_print_string("kdfcctl_fifo1_overwrite_%d\t\t",
+				i, &stat_size, data);
+			add_print_string("kdfcctl_fifo1_poison_%d\t\t",
+				i, &stat_size, data);
+			add_print_string("kdfcctl_fifo1_dma_error_%d\t\t",
+				i, &stat_size, data);
+			add_print_string("kdfcctl_fifo2_overwrite_%d\t\t",
+				i, &stat_size, data);
+			add_print_string("kdfcctl_fifo2_poison_%d\t\t",
+				i, &stat_size, data);
+			add_print_string("kdfcctl_fifo2_dma_error_%d\t\t",
+				i, &stat_size, data);
+			add_print_string("dblgen_fifo0_overflow_%d\t\t",
+				i, &stat_size, data);
+			add_print_string("dblgen_fifo1_overflow_%d\t\t",
+				i, &stat_size, data);
+			add_print_string("dblgen_fifo2_overflow_%d\t\t",
+				i, &stat_size, data);
+			add_print_string("statsb_pif_chain_error_%d\t\t",
+				i, &stat_size, data);
+			add_print_string("statsb_drop_timeout_%d\t\t",
+				i, &stat_size, data);
+			add_print_string("target_illegal_access_%d\t\t",
+				i, &stat_size, data);
+			add_print_string("ini_serr_det_%d\t\t\t",
+				i, &stat_size, data);
+			add_print_string("pci_config_status_err_%d\t\t",
+				i, &stat_size, data);
+			add_print_string("pci_config_uncor_err_%d\t\t",
+				i, &stat_size, data);
+			add_print_string("pci_config_cor_err_%d\t\t",
+				i, &stat_size, data);
+			add_print_string("mrpcim_to_vpath_alarms_%d\t\t",
+				i, &stat_size, data);
+			add_print_string("srpcim_to_vpath_alarms_%d\t\t",
+				i, &stat_size, data);
+			add_print_string("srpcim_msg_to_vpath_%d\t\t",
+				i, &stat_size, data);
+			add_print_string("prc_ring_bumps_%d\t\t\t",
+				i, &stat_size, data);
+			add_print_string("prc_rxdcm_sc_err_%d\t\t\t",
+				i, &stat_size, data);
+			add_print_string("prc_rxdcm_sc_abort_%d\t\t",
+				i, &stat_size, data);
+			add_print_string("prc_quanta_size_err_%d\t\t",
+				i, &stat_size, data);
+			add_print_string("ring_full_cnt_%d\t\t\t",
+				i, &stat_size, data);
+			add_print_string("ring_usage_cnt_%d\t\t\t",
+				i, &stat_size, data);
+			add_print_string("ring_usage_max_%d\t\t\t",
+				i, &stat_size, data);
+			add_print_string("ring_reserve_free_swaps_cnt_%d\t",
+				i, &stat_size, data);
+			add_print_string("ring_avg_compl_per_intr_cnt_%d\t",
+				i, &stat_size, data);
+			add_print_string("ring_total_compl_cnt_%d\t\t",
+				i, &stat_size, data);
+			add_print_string("rxd_t_code_err_cnt0_%d\t\t",
+				i, &stat_size, data);
+			add_print_string("rxd_t_code_err_cnt1_%d\t\t",
+				i, &stat_size, data);
+			add_print_string("rxd_t_code_err_cnt2_%d\t\t",
+				i, &stat_size, data);
+			add_print_string("rxd_t_code_err_cnt3_%d\t\t",
+				i, &stat_size, data);
+			add_print_string("rxd_t_code_err_cnt4_%d\t\t",
+				i, &stat_size, data);
+			add_print_string("rxd_t_code_err_cnt5_%d\t\t",
+				i, &stat_size, data);
+			add_print_string("rxd_t_code_err_cnt6_%d\t\t",
+				i, &stat_size, data);
+			add_print_string("rxd_t_code_err_cnt7_%d\t\t",
+				i, &stat_size, data);
+			add_print_string("rxd_t_code_err_cnt8_%d\t\t",
+				i, &stat_size, data);
+			add_print_string("rxd_t_code_err_cnt9_%d\t\t",
+				i, &stat_size, data);
+			add_print_string("rxd_t_code_err_cnt10_%d\t\t",
+				i, &stat_size, data);
+			add_print_string("rxd_t_code_err_cnt11_%d\t\t",
+				i, &stat_size, data);
+			add_print_string("rxd_t_code_err_cnt12_%d\t\t",
+				i, &stat_size, data);
+			add_print_string("rxd_t_code_err_cnt13_%d\t\t",
+				i, &stat_size, data);
+			add_print_string("rxd_t_code_err_cnt14_%d\t\t",
+				i, &stat_size, data);
+			add_print_string("rxd_t_code_err_cnt15_%d\t\t",
+				i, &stat_size, data);
+
+			add_print_string("lro_aggregated_pkts_%d\t\t",
+				i, &stat_size, data);
+			add_print_string("lro_flush_both_count_%d\t\t",
+				i, &stat_size, data);
+			if (i < 10)
+				add_print_string(
+					"lro_out_of_sequence_pkts_%d\t\t",
+					i, &stat_size, data);
+			else
+			    add_print_string("lro_out_of_sequence_pkts_%d\t",
+				i, &stat_size, data);
+			add_print_string("lro_flush_due_to_max_pkts_%d\t",
+				i, &stat_size, data);
+			add_print_string("lro_avg_aggr_pkts_%d\t\t",
+				i, &stat_size, data);
+			add_print_string("lro_max_pkts_aggr_%d\t\t",
+				i, &stat_size, data);
+
+			add_print_string("fifo_full_cnt_%d\t\t\t",
+				i, &stat_size, data);
+			add_print_string("fifo_usage_cnt_%d\t\t\t",
+				i, &stat_size, data);
+			add_print_string("fifo_usage_max_%d\t\t\t",
+				i, &stat_size, data);
+			add_print_string("fifo_reserve_free_swaps_cnt_%d\t",
+				i, &stat_size, data);
+			add_print_string("fifo_avg_compl_per_intr_cnt_%d\t",
+				i, &stat_size, data);
+			add_print_string("fifo_total_compl_cnt_%d\t\t",
+				i, &stat_size, data);
+			add_print_string("fifo_total_posts_%d\t\t\t",
+				i, &stat_size, data);
+			add_print_string("fifo_total_buffers_%d\t\t",
+				i, &stat_size, data);
+			add_print_string("fifo_avg_buffers_per_post_%d\t",
+				i, &stat_size, data);
+			add_print_string("fifo_copied_frags_%d\t\t",
+				i, &stat_size, data);
+			add_print_string("fifo_copied_buffers_%d\t\t",
+				i, &stat_size, data);
+			add_print_string("fifo_avg_buffer_size_%d\t\t",
+				i, &stat_size, data);
+			add_print_string("fifo_avg_post_size_%d\t\t",
+				i, &stat_size, data);
+			add_print_string("fifo_total_posts_dang_dtrs_%d\t",
+				i, &stat_size, data);
+			add_print_string("fifo_total_posts_dang_frags_%d\t",
+				i, &stat_size, data);
+			add_print_string("txd_t_code_err_cnt0_%d\t\t",
+				i, &stat_size, data);
+			add_print_string("txd_t_code_err_cnt1_%d\t\t",
+				i, &stat_size, data);
+			add_print_string("txd_t_code_err_cnt2_%d\t\t",
+				i, &stat_size, data);
+			add_print_string("txd_t_code_err_cnt3_%d\t\t",
+				i, &stat_size, data);
+			add_print_string("txd_t_code_err_cnt4_%d\t\t",
+				i, &stat_size, data);
+			add_print_string("txd_t_code_err_cnt5_%d\t\t",
+				i, &stat_size, data);
+			add_print_string("txd_t_code_err_cnt6_%d\t\t",
+				i, &stat_size, data);
+			add_print_string("txd_t_code_err_cnt7_%d\t\t",
+				i, &stat_size, data);
+			add_print_string("txd_t_code_err_cnt8_%d\t\t",
+				i, &stat_size, data);
+			add_print_string("txd_t_code_err_cnt9_%d\t\t",
+				i, &stat_size, data);
+			add_print_string("txd_t_code_err_cnt10_%d\t\t",
+				i, &stat_size, data);
+			add_print_string("txd_t_code_err_cnt11_%d\t\t",
+				i, &stat_size, data);
+			add_print_string("txd_t_code_err_cnt12_%d\t\t",
+				i, &stat_size, data);
+			add_print_string("txd_t_code_err_cnt13_%d\t\t",
+				i, &stat_size, data);
+			add_print_string("txd_t_code_err_cnt14_%d\t\t",
+				i, &stat_size, data);
+			add_print_string("txd_t_code_err_cnt15_%d\t\t",
+				i, &stat_size, data);
+			add_print_string("fifo_total_frags_%d\t\t\t",
+				i, &stat_size, data);
+			add_print_string("fifo_copied_frags_%d\t\t",
+				i, &stat_size, data);
+		}
+
+		add_print_string("\n HARDWARE STATISTICS\t\t\t",
+				0, &stat_size, data);
+		for (i = 0; i < vdev->no_of_vpath; i++) {
+			add_print_string("ini_num_mwr_sent_%d\t\t\t",
+					i, &stat_size, data);
+			add_print_string("ini_num_mrd_sent_%d\t\t\t",
+					i, &stat_size, data);
+			add_print_string("ini_num_cpl_rcvd_%d\t\t\t",
+					i, &stat_size, data);
+			add_print_string("ini_num_mwr_byte_sent_%d\t\t",
+					i, &stat_size, data);
+			add_print_string("ini_num_cpl_byte_rcvd_%d\t\t",
+					i, &stat_size, data);
+			add_print_string("wrcrdtarb_xoff_%d\t\t\t",
+					i, &stat_size, data);
+			add_print_string("rdcrdtarb_xoff_%d\t\t\t",
+					i, &stat_size, data);
+			add_print_string("vpath_genstats_count0_%d\t\t",
+					i, &stat_size, data);
+			add_print_string("vpath_genstats_count1_%d\t\t",
+					i, &stat_size, data);
+			add_print_string("vpath_genstats_count2_%d\t\t",
+					i, &stat_size, data);
+			add_print_string("vpath_genstats_count3_%d\t\t",
+					i, &stat_size, data);
+			add_print_string("vpath_genstats_count4_%d\t\t",
+					i, &stat_size, data);
+			add_print_string("vpath_genstats_count5_%d\t\t",
+					i, &stat_size, data);
+			add_print_string("prog_event_vnum0_%d\t\t\t",
+					i, &stat_size, data);
+			add_print_string("prog_event_vnum1_%d\t\t\t",
+					i, &stat_size, data);
+			add_print_string("prog_event_vnum2_%d\t\t\t",
+					i, &stat_size, data);
+			add_print_string("prog_event_vnum3_%d\t\t\t",
+					i, &stat_size, data);
+			add_print_string("rx_multi_cast_frame_discard_%d\t",
+					i, &stat_size, data);
+			add_print_string("rx_frm_transferred_%d\t\t",
+					i, &stat_size, data);
+			add_print_string("rxd_returned_%d\t\t\t",
+					i, &stat_size, data);
+			add_print_string("rx_mpa_len_fail_frms_%d\t\t",
+					i, &stat_size, data);
+			add_print_string("rx_mpa_mrk_fail_frms_%d\t\t",
+					i, &stat_size, data);
+			add_print_string("rx_mpa_crc_fail_frms_%d\t\t",
+					i, &stat_size, data);
+			add_print_string("rx_permitted_frms_%d\t\t",
+					i, &stat_size, data);
+			add_print_string("rx_vp_reset_discarded_frms_%d\t",
+					i, &stat_size, data);
+			add_print_string("rx_wol_frms_%d\t\t\t",
+					i, &stat_size, data);
+			add_print_string("tx_vp_reset_discarded_frms_%d\t",
+					i, &stat_size, data);
+		}
+		/* Copying Driver relates stats string */
+		memcpy(data + stat_size, &ethtool_driver_stats_keys,
+			sizeof(ethtool_driver_stats_keys));
+
+		stat_size += sizeof(ethtool_driver_stats_keys);
+
+	}
+}
+
+int vxge_ethtool_get_regs_len(struct net_device *dev)
+{
+	struct vxgedev *vdev = (struct vxgedev *)netdev_priv(dev);
+	return sizeof(struct vxge_hw_vpath_reg) * vdev->no_of_vpath;
+}
+
+u32 vxge_get_rx_csum(struct net_device *dev)
+{
+	struct vxgedev *vdev = (struct vxgedev *)netdev_priv(dev);
+
+	return vdev->rx_csum;
+}
+
+int vxge_set_rx_csum(struct net_device *dev, u32 data)
+{
+	struct vxgedev *vdev = (struct vxgedev *)netdev_priv(dev);
+
+	if (data)
+		vdev->rx_csum = 1;
+	else
+		vdev->rx_csum = 0;
+
+	return 0;
+}
+
+int vxge_get_eeprom_len(struct net_device *dev)
+{
+	return VXGE_HW_EEPROM_SIZE;
+}
+
+static u32 vxge_ethtool_op_get_tso(struct net_device *dev)
+{
+	return (dev->features & NETIF_F_TSO) != 0;
+}
+
+static int vxge_ethtool_op_set_tso(struct net_device *dev, u32 data)
+{
+	if (data)
+		dev->features |= (NETIF_F_TSO | NETIF_F_TSO6);
+	else
+		dev->features &= ~(NETIF_F_TSO | NETIF_F_TSO6);
+
+	return 0;
+}
+
+int vxge_ethtool_self_test_count(struct net_device *dev)
+{
+	return VXGE_TEST_LEN;
+}
+
+static int vxge_ethtool_get_stats_count(struct net_device *dev)
+{
+	struct vxgedev *vdev = (struct vxgedev *)netdev_priv(dev);
+	return VXGE_TITLE_LEN + (vdev->no_of_vpath *
+		VXGE_HW_VPATH_STATS_LEN) +
+		(vdev->max_config_port * VXGE_HW_AGGR_STATS_LEN) +
+		(vdev->max_config_port * VXGE_HW_PORT_STATS_LEN) +
+		(vdev->no_of_vpath * VXGE_HW_VPATH_TX_STATS_LEN) +
+		(vdev->no_of_vpath * VXGE_HW_VPATH_RX_STATS_LEN) +
+
+		(vdev->no_of_vpath * VXGE_SW_STATS_LEN) + DRIVER_STAT_LEN;
+
+}
+
+int vxge_ethtool_op_set_tx_csum(struct net_device *dev, u32 data)
+{
+	if (data)
+		dev->features |= NETIF_F_HW_CSUM;
+	else
+		dev->features &= ~NETIF_F_HW_CSUM;
+
+	return 0;
+}
+
+struct ethtool_ops netdev_ethtool_ops = {
+	.get_settings = vxge_ethtool_gset,
+	.set_settings = vxge_ethtool_sset,
+	.get_drvinfo = vxge_ethtool_gdrvinfo,
+	.get_regs_len = vxge_ethtool_get_regs_len,
+	.get_regs = vxge_ethtool_gregs,
+	.get_link = ethtool_op_get_link,
+
+	.get_eeprom_len = vxge_get_eeprom_len,
+
+	.get_eeprom = NULL,
+	.set_eeprom = NULL,
+	.get_pauseparam = vxge_ethtool_getpause_data,
+	.set_pauseparam = vxge_ethtool_setpause_data,
+	.get_rx_csum = vxge_get_rx_csum,
+	.set_rx_csum = vxge_set_rx_csum,
+	.get_tx_csum = ethtool_op_get_tx_csum,
+	.set_tx_csum = vxge_ethtool_op_set_tx_csum,
+	.get_sg = ethtool_op_get_sg,
+	.set_sg = ethtool_op_set_sg,
+
+	.get_tso = vxge_ethtool_op_get_tso,
+	.set_tso = vxge_ethtool_op_set_tso,
+
+	.self_test_count = vxge_ethtool_self_test_count,
+	.self_test = NULL,
+	.get_strings = vxge_ethtool_get_strings,
+	.phys_id = vxge_ethtool_idnic,
+	.get_stats_count = vxge_ethtool_get_stats_count,
+	.get_ethtool_stats = vxge_get_ethtool_stats
+};
+
+void initialize_ethtool_ops(struct net_device *ndev)
+{
+	 SET_ETHTOOL_OPS(ndev, &netdev_ethtool_ops);
+}
diff -urpN patch_8/drivers/net/vxge/vxge-ethtool.h patch_9/drivers/net/vxge/vxge-ethtool.h
--- patch_8/drivers/net/vxge/vxge-ethtool.h	1969-12-31 16:00:00.000000000 -0800
+++ patch_9/drivers/net/vxge/vxge-ethtool.h	2009-03-13 00:15:40.000000000 -0700
@@ -0,0 +1,73 @@
+/******************************************************************************
+ * This software may be used and distributed according to the terms of
+ * the GNU General Public License (GPL), incorporated herein by reference.
+ * Drivers based on or derived from this code fall under the GPL and must
+ * retain the authorship, copyright and license notice.  This file is not
+ * a complete program and may only be used when the entire operating
+ * system is licensed under the GPL.
+ * See the file COPYING in this distribution for more information.
+ ******************************************************************************/
+/*******************************************************************************
+ * vxge-ethtool.h: Driver for Neterion Inc's X3100 Series 10GbE PCIe I/O
+ *                 Virtualized Server Adapter.
+ * Copyright(c) 2002-2009 Neterion Inc.
+ ******************************************************************************/
+#ifndef _VXGE_ETHTOOL_H
+#define _VXGE_ETHTOOL_H
+
+#include "vxge-main.h"
+
+/* Ethtool related variables and Macros. */
+#define INV(d)  (((d&0xff)<<24) | (((d>>8)&0xff)<<16) | \
+		 (((d>>16)&0xff)<<8) | ((d>>24)&0xff))
+
+static char vxge_gstrings[][ETH_GSTRING_LEN] = {
+	"Register test\t(offline)",
+	"Eeprom test\t(offline)",
+	"Link test\t(online)",
+	"RLDRAM test\t(offline)",
+	"BIST Test\t(offline)"
+};
+
+static int vxge_ethtool_get_stats_count(struct net_device *dev);
+
+static char ethtool_driver_stats_keys[][ETH_GSTRING_LEN] = {
+	{"\n DRIVER STATISTICS"},
+	{"vpaths_opened"},
+	{"vpath_open_fail_cnt"},
+	{"link_up_cnt"},
+	{"link_down_cnt"},
+	{"tx_frms"},
+	{"tx_errors"},
+	{"tx_bytes"},
+	{"txd_not_free"},
+	{"txd_out_of_desc"},
+	{"rx_frms"},
+	{"rx_errors"},
+	{"rx_bytes"},
+	{"rx_mcast"},
+	{"pci_map_fail_cnt"},
+	{"skb_alloc_fail_cnt"}
+};
+#define VXGE_TITLE_LEN			5
+#define VXGE_HW_VPATH_STATS_LEN 	27
+#define VXGE_HW_AGGR_STATS_LEN  	13
+#define VXGE_HW_PORT_STATS_LEN  	94
+#define VXGE_HW_VPATH_TX_STATS_LEN  	19
+#define VXGE_HW_VPATH_RX_STATS_LEN	42
+#define VXGE_SW_STATS_LEN		91
+#define VXGE_HW_STATS_LEN       (VXGE_HW_VPATH_STATS_LEN +\
+				VXGE_HW_AGGR_STATS_LEN +\
+				VXGE_HW_PORT_STATS_LEN +\
+				VXGE_HW_VPATH_TX_STATS_LEN +\
+				VXGE_HW_VPATH_RX_STATS_LEN)
+
+#define VXGE_MRPCIM_STATS_LEN	(178) /* Number of lines in output */
+#define DRIVER_STAT_LEN (sizeof(ethtool_driver_stats_keys)/ETH_GSTRING_LEN)
+#define STAT_LEN (VXGE_HW_STATS_LEN + DRIVER_STAT_LEN + VXGE_SW_STATS_LEN)
+#define VXGE_STAT_STRINGS_LEN (STAT_LEN * ETH_GSTRING_LEN)
+
+#define VXGE_TEST_LEN	(sizeof(vxge_gstrings) / ETH_GSTRING_LEN)
+#define VXGE_STRINGS_LEN	(VXGE_TEST_LEN * ETH_GSTRING_LEN)
+
+#endif /*_VXGE_ETHTOOL_H*/



