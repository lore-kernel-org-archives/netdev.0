From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH v4 net-next 10/10] qede: Add basic ethtool support
Date: Wed, 7 Oct 2015 14:25:27 +0300
Message-ID: <1444217127-17557-11-git-send-email-Yuval.Mintz@qlogic.com>
References: <1444217127-17557-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Ariel.Elior@qlogic.com>, <Yuval.Mintz@qlogic.com>,
	Sudarsana Kalluru <Sudarsana.Kalluru@qlogic.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:41390 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752541AbbJGL0X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2015 07:26:23 -0400
Received: from pps.filterd (m0085408.ppops.net [127.0.0.1])
	by mx0b-0016ce01.pphosted.com (8.15.0.59/8.15.0.59) with SMTP id t97BMgW2029170
	for <netdev@vger.kernel.org>; Wed, 7 Oct 2015 04:26:22 -0700
Received: from avcashub1.qlogic.com (avcashub3.qlogic.com [198.70.193.117])
	by mx0b-0016ce01.pphosted.com with ESMTP id 1xd13qr4p5-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 07 Oct 2015 04:26:22 -0700
In-Reply-To: <1444217127-17557-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sudarsana Kalluru <Sudarsana.Kalluru@qlogic.com>

This adds basic ethtool operations to the qed driver, allowing support in:
 - Statistics gathering [ethtool -S]
 - Setting of debug level [ethtool -s <interface> msglvl]
 - Getting basic information [ethtool, ethtool -i]

In addition it adds the ability to change the MTU.

Signed-off-by: Sudarsana Kalluru <Sudarsana.Kalluru@qlogic.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
Signed-off-by: Ariel Elior <Ariel.Elior@qlogic.com>
---
 drivers/net/ethernet/qlogic/qede/Makefile       |   2 +-
 drivers/net/ethernet/qlogic/qede/qede.h         |  74 +++++
 drivers/net/ethernet/qlogic/qede/qede_ethtool.c | 385 ++++++++++++++++++++++++
 drivers/net/ethernet/qlogic/qede/qede_main.c    | 137 ++++++++-
 4 files changed, 596 insertions(+), 2 deletions(-)
 create mode 100644 drivers/net/ethernet/qlogic/qede/qede_ethtool.c

diff --git a/drivers/net/ethernet/qlogic/qede/Makefile b/drivers/net/ethernet/qlogic/qede/Makefile
index bedfe9f..06ff90d 100644
--- a/drivers/net/ethernet/qlogic/qede/Makefile
+++ b/drivers/net/ethernet/qlogic/qede/Makefile
@@ -1,3 +1,3 @@
 obj-$(CONFIG_QEDE) := qede.o
 
-qede-y := qede_main.o
+qede-y := qede_main.o qede_ethtool.o
diff --git a/drivers/net/ethernet/qlogic/qede/qede.h b/drivers/net/ethernet/qlogic/qede/qede.h
index 7947942..ea00d5f 100644
--- a/drivers/net/ethernet/qlogic/qede/qede.h
+++ b/drivers/net/ethernet/qlogic/qede/qede.h
@@ -36,6 +36,70 @@
 
 #define DRV_MODULE_SYM		qede
 
+struct qede_stats {
+	u64 no_buff_discards;
+	u64 rx_ucast_bytes;
+	u64 rx_mcast_bytes;
+	u64 rx_bcast_bytes;
+	u64 rx_ucast_pkts;
+	u64 rx_mcast_pkts;
+	u64 rx_bcast_pkts;
+	u64 mftag_filter_discards;
+	u64 mac_filter_discards;
+	u64 tx_ucast_bytes;
+	u64 tx_mcast_bytes;
+	u64 tx_bcast_bytes;
+	u64 tx_ucast_pkts;
+	u64 tx_mcast_pkts;
+	u64 tx_bcast_pkts;
+	u64 tx_err_drop_pkts;
+	u64 coalesced_pkts;
+	u64 coalesced_events;
+	u64 coalesced_aborts_num;
+	u64 non_coalesced_pkts;
+	u64 coalesced_bytes;
+
+	/* port */
+	u64 rx_64_byte_packets;
+	u64 rx_127_byte_packets;
+	u64 rx_255_byte_packets;
+	u64 rx_511_byte_packets;
+	u64 rx_1023_byte_packets;
+	u64 rx_1518_byte_packets;
+	u64 rx_1522_byte_packets;
+	u64 rx_2047_byte_packets;
+	u64 rx_4095_byte_packets;
+	u64 rx_9216_byte_packets;
+	u64 rx_16383_byte_packets;
+	u64 rx_crc_errors;
+	u64 rx_mac_crtl_frames;
+	u64 rx_pause_frames;
+	u64 rx_pfc_frames;
+	u64 rx_align_errors;
+	u64 rx_carrier_errors;
+	u64 rx_oversize_packets;
+	u64 rx_jabbers;
+	u64 rx_undersize_packets;
+	u64 rx_fragments;
+	u64 tx_64_byte_packets;
+	u64 tx_65_to_127_byte_packets;
+	u64 tx_128_to_255_byte_packets;
+	u64 tx_256_to_511_byte_packets;
+	u64 tx_512_to_1023_byte_packets;
+	u64 tx_1024_to_1518_byte_packets;
+	u64 tx_1519_to_2047_byte_packets;
+	u64 tx_2048_to_4095_byte_packets;
+	u64 tx_4096_to_9216_byte_packets;
+	u64 tx_9217_to_16383_byte_packets;
+	u64 tx_pause_frames;
+	u64 tx_pfc_frames;
+	u64 tx_lpi_entry_count;
+	u64 tx_total_collisions;
+	u64 brb_truncates;
+	u64 brb_discards;
+	u64 tx_mac_ctrl_frames;
+};
+
 struct qede_dev {
 	struct qed_dev			*cdev;
 	struct net_device		*ndev;
@@ -84,6 +148,7 @@ struct qede_dev {
 	max_t(u64, 1UL << QEDE_RX_ALIGN_SHIFT,			\
 	      SKB_DATA_ALIGN(sizeof(struct skb_shared_info)))
 
+	struct qede_stats		stats;
 	struct qed_update_vport_rss_params	rss_params;
 	u16			q_num_rx_buffers; /* Must be a power of two */
 	u16			q_num_tx_buffers; /* Must be a power of two */
@@ -194,6 +259,15 @@ union qede_reload_args {
 	u16 mtu;
 };
 
+void qede_config_debug(uint debug, u32 *p_dp_module, u8 *p_dp_level);
+void qede_set_ethtool_ops(struct net_device *netdev);
+void qede_reload(struct qede_dev *edev,
+		 void (*func)(struct qede_dev *edev,
+			      union qede_reload_args *args),
+		 union qede_reload_args *args);
+int qede_change_mtu(struct net_device *dev, int new_mtu);
+void qede_fill_by_demand_stats(struct qede_dev *edev);
+
 #define RX_RING_SIZE_POW	13
 #define RX_RING_SIZE		BIT(RX_RING_SIZE_POW)
 #define NUM_RX_BDS_MAX		(RX_RING_SIZE - 1)
diff --git a/drivers/net/ethernet/qlogic/qede/qede_ethtool.c b/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
new file mode 100644
index 0000000..3a36247
--- /dev/null
+++ b/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
@@ -0,0 +1,385 @@
+/* QLogic qede NIC Driver
+* Copyright (c) 2015 QLogic Corporation
+*
+* This software is available under the terms of the GNU General Public License
+* (GPL) Version 2, available from the file COPYING in the main directory of
+* this source tree.
+*/
+
+#include <linux/version.h>
+#include <linux/types.h>
+#include <linux/netdevice.h>
+#include <linux/ethtool.h>
+#include <linux/string.h>
+#include <linux/pci.h>
+#include <linux/capability.h>
+#include "qede.h"
+
+#define QEDE_STAT_OFFSET(stat_name) (offsetof(struct qede_stats, stat_name))
+#define QEDE_STAT_STRING(stat_name) (#stat_name)
+#define _QEDE_STAT(stat_name, pf_only) \
+	 {QEDE_STAT_OFFSET(stat_name), QEDE_STAT_STRING(stat_name), pf_only}
+#define QEDE_PF_STAT(stat_name)		_QEDE_STAT(stat_name, true)
+#define QEDE_STAT(stat_name)		_QEDE_STAT(stat_name, false)
+
+#define QEDE_RQSTAT_OFFSET(stat_name) \
+	 (offsetof(struct qede_rx_queue, stat_name))
+#define QEDE_RQSTAT_STRING(stat_name) (#stat_name)
+#define QEDE_RQSTAT(stat_name) \
+	 {QEDE_RQSTAT_OFFSET(stat_name), QEDE_RQSTAT_STRING(stat_name)}
+static const struct {
+	u64 offset;
+	char string[ETH_GSTRING_LEN];
+} qede_rqstats_arr[] = {
+	QEDE_RQSTAT(rx_hw_errors),
+	QEDE_RQSTAT(rx_alloc_errors),
+};
+
+#define QEDE_NUM_RQSTATS ARRAY_SIZE(qede_rqstats_arr)
+#define QEDE_RQSTATS_DATA(dev, sindex, rqindex) \
+	(*((u64 *)(((char *)(dev->fp_array[(rqindex)].rxq)) +\
+		    qede_rqstats_arr[(sindex)].offset)))
+static const struct {
+	u64 offset;
+	char string[ETH_GSTRING_LEN];
+	bool pf_only;
+} qede_stats_arr[] = {
+	QEDE_STAT(rx_ucast_bytes),
+	QEDE_STAT(rx_mcast_bytes),
+	QEDE_STAT(rx_bcast_bytes),
+	QEDE_STAT(rx_ucast_pkts),
+	QEDE_STAT(rx_mcast_pkts),
+	QEDE_STAT(rx_bcast_pkts),
+
+	QEDE_STAT(tx_ucast_bytes),
+	QEDE_STAT(tx_mcast_bytes),
+	QEDE_STAT(tx_bcast_bytes),
+	QEDE_STAT(tx_ucast_pkts),
+	QEDE_STAT(tx_mcast_pkts),
+	QEDE_STAT(tx_bcast_pkts),
+
+	QEDE_PF_STAT(rx_64_byte_packets),
+	QEDE_PF_STAT(rx_127_byte_packets),
+	QEDE_PF_STAT(rx_255_byte_packets),
+	QEDE_PF_STAT(rx_511_byte_packets),
+	QEDE_PF_STAT(rx_1023_byte_packets),
+	QEDE_PF_STAT(rx_1518_byte_packets),
+	QEDE_PF_STAT(rx_1522_byte_packets),
+	QEDE_PF_STAT(rx_2047_byte_packets),
+	QEDE_PF_STAT(rx_4095_byte_packets),
+	QEDE_PF_STAT(rx_9216_byte_packets),
+	QEDE_PF_STAT(rx_16383_byte_packets),
+	QEDE_PF_STAT(tx_64_byte_packets),
+	QEDE_PF_STAT(tx_65_to_127_byte_packets),
+	QEDE_PF_STAT(tx_128_to_255_byte_packets),
+	QEDE_PF_STAT(tx_256_to_511_byte_packets),
+	QEDE_PF_STAT(tx_512_to_1023_byte_packets),
+	QEDE_PF_STAT(tx_1024_to_1518_byte_packets),
+	QEDE_PF_STAT(tx_1519_to_2047_byte_packets),
+	QEDE_PF_STAT(tx_2048_to_4095_byte_packets),
+	QEDE_PF_STAT(tx_4096_to_9216_byte_packets),
+	QEDE_PF_STAT(tx_9217_to_16383_byte_packets),
+
+	QEDE_PF_STAT(rx_mac_crtl_frames),
+	QEDE_PF_STAT(tx_mac_ctrl_frames),
+	QEDE_PF_STAT(rx_pause_frames),
+	QEDE_PF_STAT(tx_pause_frames),
+	QEDE_PF_STAT(rx_pfc_frames),
+	QEDE_PF_STAT(tx_pfc_frames),
+
+	QEDE_PF_STAT(rx_crc_errors),
+	QEDE_PF_STAT(rx_align_errors),
+	QEDE_PF_STAT(rx_carrier_errors),
+	QEDE_PF_STAT(rx_oversize_packets),
+	QEDE_PF_STAT(rx_jabbers),
+	QEDE_PF_STAT(rx_undersize_packets),
+	QEDE_PF_STAT(rx_fragments),
+	QEDE_PF_STAT(tx_lpi_entry_count),
+	QEDE_PF_STAT(tx_total_collisions),
+	QEDE_PF_STAT(brb_truncates),
+	QEDE_PF_STAT(brb_discards),
+	QEDE_STAT(no_buff_discards),
+	QEDE_PF_STAT(mftag_filter_discards),
+	QEDE_PF_STAT(mac_filter_discards),
+	QEDE_STAT(tx_err_drop_pkts),
+
+	QEDE_STAT(coalesced_pkts),
+	QEDE_STAT(coalesced_events),
+	QEDE_STAT(coalesced_aborts_num),
+	QEDE_STAT(non_coalesced_pkts),
+	QEDE_STAT(coalesced_bytes),
+};
+
+#define QEDE_STATS_DATA(dev, index) \
+	(*((u64 *)(((char *)(dev)) + offsetof(struct qede_dev, stats) \
+			+ qede_stats_arr[(index)].offset)))
+
+#define QEDE_NUM_STATS	ARRAY_SIZE(qede_stats_arr)
+
+static void qede_get_strings_stats(struct qede_dev *edev, u8 *buf)
+{
+	int i, j, k;
+
+	for (i = 0, j = 0; i < QEDE_NUM_STATS; i++) {
+		strcpy(buf + j * ETH_GSTRING_LEN,
+		       qede_stats_arr[i].string);
+		j++;
+	}
+
+	for (k = 0; k < QEDE_NUM_RQSTATS; k++, j++)
+		strcpy(buf + j * ETH_GSTRING_LEN,
+		       qede_rqstats_arr[k].string);
+}
+
+static void qede_get_strings(struct net_device *dev, u32 stringset, u8 *buf)
+{
+	struct qede_dev *edev = netdev_priv(dev);
+
+	switch (stringset) {
+	case ETH_SS_STATS:
+		qede_get_strings_stats(edev, buf);
+		break;
+	default:
+		DP_VERBOSE(edev, QED_MSG_DEBUG,
+			   "Unsupported stringset 0x%08x\n", stringset);
+	}
+}
+
+static void qede_get_ethtool_stats(struct net_device *dev,
+				   struct ethtool_stats *stats, u64 *buf)
+{
+	struct qede_dev *edev = netdev_priv(dev);
+	int sidx, cnt = 0;
+	int qid;
+
+	qede_fill_by_demand_stats(edev);
+
+	mutex_lock(&edev->qede_lock);
+
+	for (sidx = 0; sidx < QEDE_NUM_STATS; sidx++)
+		buf[cnt++] = QEDE_STATS_DATA(edev, sidx);
+
+	for (sidx = 0; sidx < QEDE_NUM_RQSTATS; sidx++) {
+		buf[cnt] = 0;
+		for (qid = 0; qid < edev->num_rss; qid++)
+			buf[cnt] += QEDE_RQSTATS_DATA(edev, sidx, qid);
+		cnt++;
+	}
+
+	mutex_unlock(&edev->qede_lock);
+}
+
+static int qede_get_sset_count(struct net_device *dev, int stringset)
+{
+	struct qede_dev *edev = netdev_priv(dev);
+	int num_stats = QEDE_NUM_STATS;
+
+	switch (stringset) {
+	case ETH_SS_STATS:
+		return num_stats + QEDE_NUM_RQSTATS;
+
+	default:
+		DP_VERBOSE(edev, QED_MSG_DEBUG,
+			   "Unsupported stringset 0x%08x\n", stringset);
+		return -EINVAL;
+	}
+}
+
+static int qede_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+{
+	struct qede_dev *edev = netdev_priv(dev);
+	struct qed_link_output current_link;
+
+	memset(&current_link, 0, sizeof(current_link));
+	edev->ops->common->get_link(edev->cdev, &current_link);
+
+	cmd->supported = current_link.supported_caps;
+	cmd->advertising = current_link.advertised_caps;
+	if ((edev->state == QEDE_STATE_OPEN) && (current_link.link_up)) {
+		ethtool_cmd_speed_set(cmd, current_link.speed);
+		cmd->duplex = current_link.duplex;
+	} else {
+		cmd->duplex = DUPLEX_UNKNOWN;
+		ethtool_cmd_speed_set(cmd, SPEED_UNKNOWN);
+	}
+	cmd->port = current_link.port;
+	cmd->autoneg = (current_link.autoneg) ? AUTONEG_ENABLE :
+						AUTONEG_DISABLE;
+	cmd->lp_advertising = current_link.lp_caps;
+
+	return 0;
+}
+
+static int qede_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+{
+	struct qede_dev *edev = netdev_priv(dev);
+	struct qed_link_output current_link;
+	struct qed_link_params params;
+	u32 speed;
+
+	if (edev->dev_info.common.is_mf) {
+		DP_INFO(edev,
+			"Link parameters can not be changed in MF mode\n");
+		return -EOPNOTSUPP;
+	}
+
+	memset(&current_link, 0, sizeof(current_link));
+	memset(&params, 0, sizeof(params));
+	edev->ops->common->get_link(edev->cdev, &current_link);
+
+	speed = ethtool_cmd_speed(cmd);
+	params.override_flags |= QED_LINK_OVERRIDE_SPEED_ADV_SPEEDS;
+	params.override_flags |= QED_LINK_OVERRIDE_SPEED_AUTONEG;
+	if (cmd->autoneg == AUTONEG_ENABLE) {
+		params.autoneg = true;
+		params.forced_speed = 0;
+		params.adv_speeds = cmd->advertising;
+	} else { /* forced speed */
+		params.override_flags |= QED_LINK_OVERRIDE_SPEED_FORCED_SPEED;
+		params.autoneg = false;
+		params.forced_speed = speed;
+		switch (speed) {
+		case SPEED_10000:
+			if (!(current_link.supported_caps &
+			    SUPPORTED_10000baseKR_Full)) {
+				DP_INFO(edev, "10G speed not supported\n");
+				return -EINVAL;
+			}
+			params.adv_speeds = SUPPORTED_10000baseKR_Full;
+			break;
+		case SPEED_40000:
+			if (!(current_link.supported_caps &
+			    SUPPORTED_40000baseLR4_Full)) {
+				DP_INFO(edev, "40G speed not supported\n");
+				return -EINVAL;
+			}
+			params.adv_speeds = SUPPORTED_40000baseLR4_Full;
+			break;
+		default:
+			DP_INFO(edev, "Unsupported speed %u\n", speed);
+			return -EINVAL;
+		}
+	}
+
+	params.link_up = true;
+	edev->ops->common->set_link(edev->cdev, &params);
+
+	return 0;
+}
+
+static void qede_get_drvinfo(struct net_device *ndev,
+			     struct ethtool_drvinfo *info)
+{
+	char mfw[ETHTOOL_FWVERS_LEN], storm[ETHTOOL_FWVERS_LEN];
+	struct qede_dev *edev = netdev_priv(ndev);
+
+	strlcpy(info->driver, "qede", sizeof(info->driver));
+	strlcpy(info->version, DRV_MODULE_VERSION, sizeof(info->version));
+
+	snprintf(storm, ETHTOOL_FWVERS_LEN, "%d.%d.%d.%d",
+		 edev->dev_info.common.fw_major,
+		 edev->dev_info.common.fw_minor,
+		 edev->dev_info.common.fw_rev,
+		 edev->dev_info.common.fw_eng);
+
+	snprintf(mfw, ETHTOOL_FWVERS_LEN, "%d.%d.%d.%d",
+		 (edev->dev_info.common.mfw_rev >> 24) & 0xFF,
+		 (edev->dev_info.common.mfw_rev >> 16) & 0xFF,
+		 (edev->dev_info.common.mfw_rev >> 8) & 0xFF,
+		 edev->dev_info.common.mfw_rev & 0xFF);
+
+	if ((strlen(storm) + strlen(mfw) + strlen("mfw storm  ")) <
+	    sizeof(info->fw_version)) {
+		snprintf(info->fw_version, sizeof(info->fw_version),
+			 "mfw %s storm %s", mfw, storm);
+	} else {
+		snprintf(info->fw_version, sizeof(info->fw_version),
+			 "%s %s", mfw, storm);
+	}
+
+	strlcpy(info->bus_info, pci_name(edev->pdev), sizeof(info->bus_info));
+}
+
+static u32 qede_get_msglevel(struct net_device *ndev)
+{
+	struct qede_dev *edev = netdev_priv(ndev);
+
+	return ((u32)edev->dp_level << QED_LOG_LEVEL_SHIFT) |
+	       edev->dp_module;
+}
+
+static void qede_set_msglevel(struct net_device *ndev, u32 level)
+{
+	struct qede_dev *edev = netdev_priv(ndev);
+	u32 dp_module = 0;
+	u8 dp_level = 0;
+
+	qede_config_debug(level, &dp_module, &dp_level);
+
+	edev->dp_level = dp_level;
+	edev->dp_module = dp_module;
+	edev->ops->common->update_msglvl(edev->cdev,
+					 dp_module, dp_level);
+}
+
+static u32 qede_get_link(struct net_device *dev)
+{
+	struct qede_dev *edev = netdev_priv(dev);
+	struct qed_link_output current_link;
+
+	memset(&current_link, 0, sizeof(current_link));
+	edev->ops->common->get_link(edev->cdev, &current_link);
+
+	return current_link.link_up;
+}
+
+static void qede_update_mtu(struct qede_dev *edev, union qede_reload_args *args)
+{
+	edev->ndev->mtu = args->mtu;
+}
+
+/* Netdevice NDOs */
+#define ETH_MAX_JUMBO_PACKET_SIZE	9600
+#define ETH_MIN_PACKET_SIZE		60
+int qede_change_mtu(struct net_device *ndev, int new_mtu)
+{
+	struct qede_dev *edev = netdev_priv(ndev);
+	union qede_reload_args args;
+
+	if ((new_mtu > ETH_MAX_JUMBO_PACKET_SIZE) ||
+	    ((new_mtu + ETH_HLEN) < ETH_MIN_PACKET_SIZE)) {
+		DP_ERR(edev, "Can't support requested MTU size\n");
+		return -EINVAL;
+	}
+
+	DP_VERBOSE(edev, (NETIF_MSG_IFUP | NETIF_MSG_IFDOWN),
+		   "Configuring MTU size of %d\n", new_mtu);
+
+	/* Set the mtu field and re-start the interface if needed*/
+	args.mtu = new_mtu;
+
+	if (netif_running(edev->ndev))
+		qede_reload(edev, &qede_update_mtu, &args);
+
+	qede_update_mtu(edev, &args);
+
+	return 0;
+}
+
+static const struct ethtool_ops qede_ethtool_ops = {
+	.get_settings = qede_get_settings,
+	.set_settings = qede_set_settings,
+	.get_drvinfo = qede_get_drvinfo,
+	.get_msglevel = qede_get_msglevel,
+	.set_msglevel = qede_set_msglevel,
+	.get_link = qede_get_link,
+	.get_strings = qede_get_strings,
+	.get_ethtool_stats = qede_get_ethtool_stats,
+	.get_sset_count = qede_get_sset_count,
+
+};
+
+void qede_set_ethtool_ops(struct net_device *dev)
+{
+	dev->ethtool_ops = &qede_ethtool_ops;
+}
diff --git a/drivers/net/ethernet/qlogic/qede/qede_main.c b/drivers/net/ethernet/qlogic/qede/qede_main.c
index f38a9d1..993e952 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_main.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_main.c
@@ -1056,6 +1056,118 @@ static int qede_set_ucast_rx_mac(struct qede_dev *edev,
 	return edev->ops->filter_config(edev->cdev, &filter_cmd);
 }
 
+void qede_fill_by_demand_stats(struct qede_dev *edev)
+{
+	struct qed_eth_stats stats;
+
+	edev->ops->get_vport_stats(edev->cdev, &stats);
+	edev->stats.no_buff_discards = stats.no_buff_discards;
+	edev->stats.rx_ucast_bytes = stats.rx_ucast_bytes;
+	edev->stats.rx_mcast_bytes = stats.rx_mcast_bytes;
+	edev->stats.rx_bcast_bytes = stats.rx_bcast_bytes;
+	edev->stats.rx_ucast_pkts = stats.rx_ucast_pkts;
+	edev->stats.rx_mcast_pkts = stats.rx_mcast_pkts;
+	edev->stats.rx_bcast_pkts = stats.rx_bcast_pkts;
+	edev->stats.mftag_filter_discards = stats.mftag_filter_discards;
+	edev->stats.mac_filter_discards = stats.mac_filter_discards;
+
+	edev->stats.tx_ucast_bytes = stats.tx_ucast_bytes;
+	edev->stats.tx_mcast_bytes = stats.tx_mcast_bytes;
+	edev->stats.tx_bcast_bytes = stats.tx_bcast_bytes;
+	edev->stats.tx_ucast_pkts = stats.tx_ucast_pkts;
+	edev->stats.tx_mcast_pkts = stats.tx_mcast_pkts;
+	edev->stats.tx_bcast_pkts = stats.tx_bcast_pkts;
+	edev->stats.tx_err_drop_pkts = stats.tx_err_drop_pkts;
+	edev->stats.coalesced_pkts = stats.tpa_coalesced_pkts;
+	edev->stats.coalesced_events = stats.tpa_coalesced_events;
+	edev->stats.coalesced_aborts_num = stats.tpa_aborts_num;
+	edev->stats.non_coalesced_pkts = stats.tpa_not_coalesced_pkts;
+	edev->stats.coalesced_bytes = stats.tpa_coalesced_bytes;
+
+	edev->stats.rx_64_byte_packets = stats.rx_64_byte_packets;
+	edev->stats.rx_127_byte_packets = stats.rx_127_byte_packets;
+	edev->stats.rx_255_byte_packets = stats.rx_255_byte_packets;
+	edev->stats.rx_511_byte_packets = stats.rx_511_byte_packets;
+	edev->stats.rx_1023_byte_packets = stats.rx_1023_byte_packets;
+	edev->stats.rx_1518_byte_packets = stats.rx_1518_byte_packets;
+	edev->stats.rx_1522_byte_packets = stats.rx_1522_byte_packets;
+	edev->stats.rx_2047_byte_packets = stats.rx_2047_byte_packets;
+	edev->stats.rx_4095_byte_packets = stats.rx_4095_byte_packets;
+	edev->stats.rx_9216_byte_packets = stats.rx_9216_byte_packets;
+	edev->stats.rx_16383_byte_packets = stats.rx_16383_byte_packets;
+	edev->stats.rx_crc_errors = stats.rx_crc_errors;
+	edev->stats.rx_mac_crtl_frames = stats.rx_mac_crtl_frames;
+	edev->stats.rx_pause_frames = stats.rx_pause_frames;
+	edev->stats.rx_pfc_frames = stats.rx_pfc_frames;
+	edev->stats.rx_align_errors = stats.rx_align_errors;
+	edev->stats.rx_carrier_errors = stats.rx_carrier_errors;
+	edev->stats.rx_oversize_packets = stats.rx_oversize_packets;
+	edev->stats.rx_jabbers = stats.rx_jabbers;
+	edev->stats.rx_undersize_packets = stats.rx_undersize_packets;
+	edev->stats.rx_fragments = stats.rx_fragments;
+	edev->stats.tx_64_byte_packets = stats.tx_64_byte_packets;
+	edev->stats.tx_65_to_127_byte_packets = stats.tx_65_to_127_byte_packets;
+	edev->stats.tx_128_to_255_byte_packets =
+				stats.tx_128_to_255_byte_packets;
+	edev->stats.tx_256_to_511_byte_packets =
+				stats.tx_256_to_511_byte_packets;
+	edev->stats.tx_512_to_1023_byte_packets =
+				stats.tx_512_to_1023_byte_packets;
+	edev->stats.tx_1024_to_1518_byte_packets =
+				stats.tx_1024_to_1518_byte_packets;
+	edev->stats.tx_1519_to_2047_byte_packets =
+				stats.tx_1519_to_2047_byte_packets;
+	edev->stats.tx_2048_to_4095_byte_packets =
+				stats.tx_2048_to_4095_byte_packets;
+	edev->stats.tx_4096_to_9216_byte_packets =
+				stats.tx_4096_to_9216_byte_packets;
+	edev->stats.tx_9217_to_16383_byte_packets =
+				stats.tx_9217_to_16383_byte_packets;
+	edev->stats.tx_pause_frames = stats.tx_pause_frames;
+	edev->stats.tx_pfc_frames = stats.tx_pfc_frames;
+	edev->stats.tx_lpi_entry_count = stats.tx_lpi_entry_count;
+	edev->stats.tx_total_collisions = stats.tx_total_collisions;
+	edev->stats.brb_truncates = stats.brb_truncates;
+	edev->stats.brb_discards = stats.brb_discards;
+	edev->stats.tx_mac_ctrl_frames = stats.tx_mac_ctrl_frames;
+}
+
+static struct rtnl_link_stats64 *qede_get_stats64(
+			    struct net_device *dev,
+			    struct rtnl_link_stats64 *stats)
+{
+	struct qede_dev *edev = netdev_priv(dev);
+
+	qede_fill_by_demand_stats(edev);
+
+	stats->rx_packets = edev->stats.rx_ucast_pkts +
+			    edev->stats.rx_mcast_pkts +
+			    edev->stats.rx_bcast_pkts;
+	stats->tx_packets = edev->stats.tx_ucast_pkts +
+			    edev->stats.tx_mcast_pkts +
+			    edev->stats.tx_bcast_pkts;
+
+	stats->rx_bytes = edev->stats.rx_ucast_bytes +
+			  edev->stats.rx_mcast_bytes +
+			  edev->stats.rx_bcast_bytes;
+
+	stats->tx_bytes = edev->stats.tx_ucast_bytes +
+			  edev->stats.tx_mcast_bytes +
+			  edev->stats.tx_bcast_bytes;
+
+	stats->tx_errors = edev->stats.tx_err_drop_pkts;
+	stats->multicast = edev->stats.rx_mcast_pkts +
+			   edev->stats.rx_bcast_pkts;
+
+	stats->rx_fifo_errors = edev->stats.no_buff_discards;
+
+	stats->collisions = edev->stats.tx_total_collisions;
+	stats->rx_crc_errors = edev->stats.rx_crc_errors;
+	stats->rx_frame_errors = edev->stats.rx_align_errors;
+
+	return stats;
+}
+
 static const struct net_device_ops qede_netdev_ops = {
 	.ndo_open = qede_open,
 	.ndo_stop = qede_close,
@@ -1063,6 +1175,8 @@ static const struct net_device_ops qede_netdev_ops = {
 	.ndo_set_rx_mode = qede_set_rx_mode,
 	.ndo_set_mac_address = qede_set_mac_addr,
 	.ndo_validate_addr = eth_validate_addr,
+	.ndo_change_mtu = qede_change_mtu,
+	.ndo_get_stats64 = qede_get_stats64,
 };
 
 /* -------------------------------------------------------------------------
@@ -1101,6 +1215,7 @@ static struct qede_dev *qede_alloc_etherdev(struct qed_dev *cdev,
 
 	SET_NETDEV_DEV(ndev, &pdev->dev);
 
+	memset(&edev->stats, 0, sizeof(edev->stats));
 	memcpy(&edev->dev_info, info, sizeof(*info));
 
 	edev->num_tc = edev->dev_info.num_tc;
@@ -1125,6 +1240,8 @@ static void qede_init_ndev(struct qede_dev *edev)
 
 	ndev->netdev_ops = &qede_netdev_ops;
 
+	qede_set_ethtool_ops(ndev);
+
 	/* user-changeble features */
 	hw_features = NETIF_F_GRO | NETIF_F_SG |
 		      NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
@@ -1153,7 +1270,7 @@ static void qede_init_ndev(struct qede_dev *edev)
  *
  * Notice that the level should be that of the lowest required logs.
  */
-static void qede_config_debug(uint debug, u32 *p_dp_module, u8 *p_dp_level)
+void qede_config_debug(uint debug, u32 *p_dp_module, u8 *p_dp_level)
 {
 	*p_dp_level = QED_LEVEL_NOTICE;
 	*p_dp_module = 0;
@@ -2218,6 +2335,24 @@ err0:
 	return rc;
 }
 
+void qede_reload(struct qede_dev *edev,
+		 void (*func)(struct qede_dev *, union qede_reload_args *),
+		 union qede_reload_args *args)
+{
+	qede_unload(edev, QEDE_UNLOAD_NORMAL);
+	/* Call function handler to update parameters
+	 * needed for function load.
+	 */
+	if (func)
+		func(edev, args);
+
+	qede_load(edev, QEDE_LOAD_NORMAL);
+
+	mutex_lock(&edev->qede_lock);
+	qede_config_rx_mode(edev->ndev);
+	mutex_unlock(&edev->qede_lock);
+}
+
 /* called with rtnl_lock */
 static int qede_open(struct net_device *ndev)
 {
-- 
1.9.3
