From: Neel Patel <neepatel@cisco.com>
Subject: [PATCH net-next] drivers/net: enic: Move ethtool code to a separate
 file
Date: Fri, 19 Jul 2013 13:28:23 -0700
Message-ID: <20130719202817.13313.56725.stgit@savbu-picasso-lnx1.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtv-iport-3.cisco.com ([173.36.130.14]:22112 "EHLO
	mtv-iport-3.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751680Ab3GSU20 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Jul 2013 16:28:26 -0400
Received: from savbu-picasso-lnx1.cisco.com (savbu-picasso-lnx1.cisco.com [10.193.199.106])
	by mtv-core-2.cisco.com (8.14.5/8.14.5) with ESMTP id r6JKSNHt018787
	for <netdev@vger.kernel.org>; Fri, 19 Jul 2013 20:28:23 GMT
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neel Patel <neepatel@cisco.com>

This patch moves all enic ethtool hooks from enic_main.c to a new file
enic_ethtool.c

Signed-off-by: Neel Patel <neepatel@cisco.com>
Signed-off-by: Christian Benvenuti <benve@cisco.com>
Signed-off-by: Nishank Trivedi <nistrive@cisco.com>
---
 drivers/net/ethernet/cisco/enic/Makefile       |    3 
 drivers/net/ethernet/cisco/enic/enic.h         |   48 ++++
 drivers/net/ethernet/cisco/enic/enic_dev.h     |    1 
 drivers/net/ethernet/cisco/enic/enic_ethtool.c |  252 ++++++++++++++++++++++
 drivers/net/ethernet/cisco/enic/enic_main.c    |  270 ------------------------
 5 files changed, 304 insertions(+), 270 deletions(-)
 create mode 100644 drivers/net/ethernet/cisco/enic/enic_ethtool.c


diff --git a/drivers/net/ethernet/cisco/enic/Makefile b/drivers/net/ethernet/cisco/enic/Makefile
index 9d4974b..e52296d 100644
--- a/drivers/net/ethernet/cisco/enic/Makefile
+++ b/drivers/net/ethernet/cisco/enic/Makefile
@@ -1,5 +1,6 @@
 obj-$(CONFIG_ENIC) := enic.o
 
 enic-y := enic_main.o vnic_cq.o vnic_intr.o vnic_wq.o \
-	enic_res.o enic_dev.o enic_pp.o vnic_dev.o vnic_rq.o vnic_vic.o
+	enic_res.o enic_dev.o enic_pp.o vnic_dev.o vnic_rq.o vnic_vic.o \
+	enic_ethtool.o
 
diff --git a/drivers/net/ethernet/cisco/enic/enic.h b/drivers/net/ethernet/cisco/enic/enic.h
index afe9b16..2e37c63 100644
--- a/drivers/net/ethernet/cisco/enic/enic.h
+++ b/drivers/net/ethernet/cisco/enic/enic.h
@@ -127,9 +127,57 @@ static inline struct device *enic_get_dev(struct enic *enic)
 	return &(enic->pdev->dev);
 }
 
+static inline unsigned int enic_cq_rq(struct enic *enic, unsigned int rq)
+{
+	return rq;
+}
+
+static inline unsigned int enic_cq_wq(struct enic *enic, unsigned int wq)
+{
+	return enic->rq_count + wq;
+}
+
+static inline unsigned int enic_legacy_io_intr(void)
+{
+	return 0;
+}
+
+static inline unsigned int enic_legacy_err_intr(void)
+{
+	return 1;
+}
+
+static inline unsigned int enic_legacy_notify_intr(void)
+{
+	return 2;
+}
+
+static inline unsigned int enic_msix_rq_intr(struct enic *enic,
+	unsigned int rq)
+{
+	return enic->cq[enic_cq_rq(enic, rq)].interrupt_offset;
+}
+
+static inline unsigned int enic_msix_wq_intr(struct enic *enic,
+	unsigned int wq)
+{
+	return enic->cq[enic_cq_wq(enic, wq)].interrupt_offset;
+}
+
+static inline unsigned int enic_msix_err_intr(struct enic *enic)
+{
+	return enic->rq_count + enic->wq_count;
+}
+
+static inline unsigned int enic_msix_notify_intr(struct enic *enic)
+{
+	return enic->rq_count + enic->wq_count + 1;
+}
+
 void enic_reset_addr_lists(struct enic *enic);
 int enic_sriov_enabled(struct enic *enic);
 int enic_is_valid_vf(struct enic *enic, int vf);
 int enic_is_dynamic(struct enic *enic);
+void enic_set_ethtool_ops(struct net_device *netdev);
 
 #endif /* _ENIC_H_ */
diff --git a/drivers/net/ethernet/cisco/enic/enic_dev.h b/drivers/net/ethernet/cisco/enic/enic_dev.h
index 08bded0..129b14a 100644
--- a/drivers/net/ethernet/cisco/enic/enic_dev.h
+++ b/drivers/net/ethernet/cisco/enic/enic_dev.h
@@ -20,6 +20,7 @@
 #define _ENIC_DEV_H_
 
 #include "vnic_dev.h"
+#include "vnic_vic.h"
 
 /*
  * Calls the devcmd function given by argument vnicdevcmdfn.
diff --git a/drivers/net/ethernet/cisco/enic/enic_ethtool.c b/drivers/net/ethernet/cisco/enic/enic_ethtool.c
new file mode 100644
index 0000000..7177f4c
--- /dev/null
+++ b/drivers/net/ethernet/cisco/enic/enic_ethtool.c
@@ -0,0 +1,252 @@
+/**
+ * Copyright 2013 Cisco Systems, Inc.  All rights reserved.
+ *
+ * This program is free software; you may redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; version 2 of the License.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ *
+ */
+
+#include <linux/netdevice.h>
+#include <linux/ethtool.h>
+
+#include "enic_res.h"
+#include "enic.h"
+#include "enic_dev.h"
+
+struct enic_stat {
+	char name[ETH_GSTRING_LEN];
+	unsigned int offset;
+};
+
+#define ENIC_TX_STAT(stat)	\
+	{ .name = #stat, .offset = offsetof(struct vnic_tx_stats, stat) / 8 }
+#define ENIC_RX_STAT(stat)	\
+	{ .name = #stat, .offset = offsetof(struct vnic_rx_stats, stat) / 8 }
+
+static const struct enic_stat enic_tx_stats[] = {
+	ENIC_TX_STAT(tx_frames_ok),
+	ENIC_TX_STAT(tx_unicast_frames_ok),
+	ENIC_TX_STAT(tx_multicast_frames_ok),
+	ENIC_TX_STAT(tx_broadcast_frames_ok),
+	ENIC_TX_STAT(tx_bytes_ok),
+	ENIC_TX_STAT(tx_unicast_bytes_ok),
+	ENIC_TX_STAT(tx_multicast_bytes_ok),
+	ENIC_TX_STAT(tx_broadcast_bytes_ok),
+	ENIC_TX_STAT(tx_drops),
+	ENIC_TX_STAT(tx_errors),
+	ENIC_TX_STAT(tx_tso),
+};
+
+static const struct enic_stat enic_rx_stats[] = {
+	ENIC_RX_STAT(rx_frames_ok),
+	ENIC_RX_STAT(rx_frames_total),
+	ENIC_RX_STAT(rx_unicast_frames_ok),
+	ENIC_RX_STAT(rx_multicast_frames_ok),
+	ENIC_RX_STAT(rx_broadcast_frames_ok),
+	ENIC_RX_STAT(rx_bytes_ok),
+	ENIC_RX_STAT(rx_unicast_bytes_ok),
+	ENIC_RX_STAT(rx_multicast_bytes_ok),
+	ENIC_RX_STAT(rx_broadcast_bytes_ok),
+	ENIC_RX_STAT(rx_drop),
+	ENIC_RX_STAT(rx_no_bufs),
+	ENIC_RX_STAT(rx_errors),
+	ENIC_RX_STAT(rx_rss),
+	ENIC_RX_STAT(rx_crc_errors),
+	ENIC_RX_STAT(rx_frames_64),
+	ENIC_RX_STAT(rx_frames_127),
+	ENIC_RX_STAT(rx_frames_255),
+	ENIC_RX_STAT(rx_frames_511),
+	ENIC_RX_STAT(rx_frames_1023),
+	ENIC_RX_STAT(rx_frames_1518),
+	ENIC_RX_STAT(rx_frames_to_max),
+};
+
+static const unsigned int enic_n_tx_stats = ARRAY_SIZE(enic_tx_stats);
+static const unsigned int enic_n_rx_stats = ARRAY_SIZE(enic_rx_stats);
+
+static int enic_get_settings(struct net_device *netdev,
+	struct ethtool_cmd *ecmd)
+{
+	struct enic *enic = netdev_priv(netdev);
+
+	ecmd->supported = (SUPPORTED_10000baseT_Full | SUPPORTED_FIBRE);
+	ecmd->advertising = (ADVERTISED_10000baseT_Full | ADVERTISED_FIBRE);
+	ecmd->port = PORT_FIBRE;
+	ecmd->transceiver = XCVR_EXTERNAL;
+
+	if (netif_carrier_ok(netdev)) {
+		ethtool_cmd_speed_set(ecmd, vnic_dev_port_speed(enic->vdev));
+		ecmd->duplex = DUPLEX_FULL;
+	} else {
+		ethtool_cmd_speed_set(ecmd, -1);
+		ecmd->duplex = -1;
+	}
+
+	ecmd->autoneg = AUTONEG_DISABLE;
+
+	return 0;
+}
+
+static void enic_get_drvinfo(struct net_device *netdev,
+	struct ethtool_drvinfo *drvinfo)
+{
+	struct enic *enic = netdev_priv(netdev);
+	struct vnic_devcmd_fw_info *fw_info;
+
+	enic_dev_fw_info(enic, &fw_info);
+
+	strlcpy(drvinfo->driver, DRV_NAME, sizeof(drvinfo->driver));
+	strlcpy(drvinfo->version, DRV_VERSION, sizeof(drvinfo->version));
+	strlcpy(drvinfo->fw_version, fw_info->fw_version,
+		sizeof(drvinfo->fw_version));
+	strlcpy(drvinfo->bus_info, pci_name(enic->pdev),
+		sizeof(drvinfo->bus_info));
+}
+
+static void enic_get_strings(struct net_device *netdev, u32 stringset,
+	u8 *data)
+{
+	unsigned int i;
+
+	switch (stringset) {
+	case ETH_SS_STATS:
+		for (i = 0; i < enic_n_tx_stats; i++) {
+			memcpy(data, enic_tx_stats[i].name, ETH_GSTRING_LEN);
+			data += ETH_GSTRING_LEN;
+		}
+		for (i = 0; i < enic_n_rx_stats; i++) {
+			memcpy(data, enic_rx_stats[i].name, ETH_GSTRING_LEN);
+			data += ETH_GSTRING_LEN;
+		}
+		break;
+	}
+}
+
+static int enic_get_sset_count(struct net_device *netdev, int sset)
+{
+	switch (sset) {
+	case ETH_SS_STATS:
+		return enic_n_tx_stats + enic_n_rx_stats;
+	default:
+		return -EOPNOTSUPP;
+	}
+}
+
+static void enic_get_ethtool_stats(struct net_device *netdev,
+	struct ethtool_stats *stats, u64 *data)
+{
+	struct enic *enic = netdev_priv(netdev);
+	struct vnic_stats *vstats;
+	unsigned int i;
+
+	enic_dev_stats_dump(enic, &vstats);
+
+	for (i = 0; i < enic_n_tx_stats; i++)
+		*(data++) = ((u64 *)&vstats->tx)[enic_tx_stats[i].offset];
+	for (i = 0; i < enic_n_rx_stats; i++)
+		*(data++) = ((u64 *)&vstats->rx)[enic_rx_stats[i].offset];
+}
+
+static u32 enic_get_msglevel(struct net_device *netdev)
+{
+	struct enic *enic = netdev_priv(netdev);
+	return enic->msg_enable;
+}
+
+static void enic_set_msglevel(struct net_device *netdev, u32 value)
+{
+	struct enic *enic = netdev_priv(netdev);
+	enic->msg_enable = value;
+}
+
+static int enic_get_coalesce(struct net_device *netdev,
+	struct ethtool_coalesce *ecmd)
+{
+	struct enic *enic = netdev_priv(netdev);
+
+	ecmd->tx_coalesce_usecs = enic->tx_coalesce_usecs;
+	ecmd->rx_coalesce_usecs = enic->rx_coalesce_usecs;
+
+	return 0;
+}
+
+static int enic_set_coalesce(struct net_device *netdev,
+	struct ethtool_coalesce *ecmd)
+{
+	struct enic *enic = netdev_priv(netdev);
+	u32 tx_coalesce_usecs;
+	u32 rx_coalesce_usecs;
+	unsigned int i, intr;
+
+	tx_coalesce_usecs = min_t(u32, ecmd->tx_coalesce_usecs,
+		vnic_dev_get_intr_coal_timer_max(enic->vdev));
+	rx_coalesce_usecs = min_t(u32, ecmd->rx_coalesce_usecs,
+		vnic_dev_get_intr_coal_timer_max(enic->vdev));
+
+	switch (vnic_dev_get_intr_mode(enic->vdev)) {
+	case VNIC_DEV_INTR_MODE_INTX:
+		if (tx_coalesce_usecs != rx_coalesce_usecs)
+			return -EINVAL;
+
+		intr = enic_legacy_io_intr();
+		vnic_intr_coalescing_timer_set(&enic->intr[intr],
+			tx_coalesce_usecs);
+		break;
+	case VNIC_DEV_INTR_MODE_MSI:
+		if (tx_coalesce_usecs != rx_coalesce_usecs)
+			return -EINVAL;
+
+		vnic_intr_coalescing_timer_set(&enic->intr[0],
+			tx_coalesce_usecs);
+		break;
+	case VNIC_DEV_INTR_MODE_MSIX:
+		for (i = 0; i < enic->wq_count; i++) {
+			intr = enic_msix_wq_intr(enic, i);
+			vnic_intr_coalescing_timer_set(&enic->intr[intr],
+				tx_coalesce_usecs);
+		}
+
+		for (i = 0; i < enic->rq_count; i++) {
+			intr = enic_msix_rq_intr(enic, i);
+			vnic_intr_coalescing_timer_set(&enic->intr[intr],
+				rx_coalesce_usecs);
+		}
+
+		break;
+	default:
+		break;
+	}
+
+	enic->tx_coalesce_usecs = tx_coalesce_usecs;
+	enic->rx_coalesce_usecs = rx_coalesce_usecs;
+
+	return 0;
+}
+
+static const struct ethtool_ops enic_ethtool_ops = {
+	.get_settings = enic_get_settings,
+	.get_drvinfo = enic_get_drvinfo,
+	.get_msglevel = enic_get_msglevel,
+	.set_msglevel = enic_set_msglevel,
+	.get_link = ethtool_op_get_link,
+	.get_strings = enic_get_strings,
+	.get_sset_count = enic_get_sset_count,
+	.get_ethtool_stats = enic_get_ethtool_stats,
+	.get_coalesce = enic_get_coalesce,
+	.set_coalesce = enic_set_coalesce,
+};
+
+void enic_set_ethtool_ops(struct net_device *netdev)
+{
+	SET_ETHTOOL_OPS(netdev, &enic_ethtool_ops);
+}
diff --git a/drivers/net/ethernet/cisco/enic/enic_main.c b/drivers/net/ethernet/cisco/enic/enic_main.c
index 992ec2e..b12b32b 100644
--- a/drivers/net/ethernet/cisco/enic/enic_main.c
+++ b/drivers/net/ethernet/cisco/enic/enic_main.c
@@ -31,7 +31,6 @@
 #include <linux/if.h>
 #include <linux/if_ether.h>
 #include <linux/if_vlan.h>
-#include <linux/ethtool.h>
 #include <linux/in.h>
 #include <linux/ip.h>
 #include <linux/ipv6.h>
@@ -73,57 +72,6 @@ MODULE_LICENSE("GPL");
 MODULE_VERSION(DRV_VERSION);
 MODULE_DEVICE_TABLE(pci, enic_id_table);
 
-struct enic_stat {
-	char name[ETH_GSTRING_LEN];
-	unsigned int offset;
-};
-
-#define ENIC_TX_STAT(stat)	\
-	{ .name = #stat, .offset = offsetof(struct vnic_tx_stats, stat) / 8 }
-#define ENIC_RX_STAT(stat)	\
-	{ .name = #stat, .offset = offsetof(struct vnic_rx_stats, stat) / 8 }
-
-static const struct enic_stat enic_tx_stats[] = {
-	ENIC_TX_STAT(tx_frames_ok),
-	ENIC_TX_STAT(tx_unicast_frames_ok),
-	ENIC_TX_STAT(tx_multicast_frames_ok),
-	ENIC_TX_STAT(tx_broadcast_frames_ok),
-	ENIC_TX_STAT(tx_bytes_ok),
-	ENIC_TX_STAT(tx_unicast_bytes_ok),
-	ENIC_TX_STAT(tx_multicast_bytes_ok),
-	ENIC_TX_STAT(tx_broadcast_bytes_ok),
-	ENIC_TX_STAT(tx_drops),
-	ENIC_TX_STAT(tx_errors),
-	ENIC_TX_STAT(tx_tso),
-};
-
-static const struct enic_stat enic_rx_stats[] = {
-	ENIC_RX_STAT(rx_frames_ok),
-	ENIC_RX_STAT(rx_frames_total),
-	ENIC_RX_STAT(rx_unicast_frames_ok),
-	ENIC_RX_STAT(rx_multicast_frames_ok),
-	ENIC_RX_STAT(rx_broadcast_frames_ok),
-	ENIC_RX_STAT(rx_bytes_ok),
-	ENIC_RX_STAT(rx_unicast_bytes_ok),
-	ENIC_RX_STAT(rx_multicast_bytes_ok),
-	ENIC_RX_STAT(rx_broadcast_bytes_ok),
-	ENIC_RX_STAT(rx_drop),
-	ENIC_RX_STAT(rx_no_bufs),
-	ENIC_RX_STAT(rx_errors),
-	ENIC_RX_STAT(rx_rss),
-	ENIC_RX_STAT(rx_crc_errors),
-	ENIC_RX_STAT(rx_frames_64),
-	ENIC_RX_STAT(rx_frames_127),
-	ENIC_RX_STAT(rx_frames_255),
-	ENIC_RX_STAT(rx_frames_511),
-	ENIC_RX_STAT(rx_frames_1023),
-	ENIC_RX_STAT(rx_frames_1518),
-	ENIC_RX_STAT(rx_frames_to_max),
-};
-
-static const unsigned int enic_n_tx_stats = ARRAY_SIZE(enic_tx_stats);
-static const unsigned int enic_n_rx_stats = ARRAY_SIZE(enic_rx_stats);
-
 int enic_is_dynamic(struct enic *enic)
 {
 	return enic->pdev->device == PCI_DEVICE_ID_CISCO_VIC_ENET_DYN;
@@ -148,222 +96,6 @@ int enic_is_valid_vf(struct enic *enic, int vf)
 #endif
 }
 
-static inline unsigned int enic_cq_rq(struct enic *enic, unsigned int rq)
-{
-	return rq;
-}
-
-static inline unsigned int enic_cq_wq(struct enic *enic, unsigned int wq)
-{
-	return enic->rq_count + wq;
-}
-
-static inline unsigned int enic_legacy_io_intr(void)
-{
-	return 0;
-}
-
-static inline unsigned int enic_legacy_err_intr(void)
-{
-	return 1;
-}
-
-static inline unsigned int enic_legacy_notify_intr(void)
-{
-	return 2;
-}
-
-static inline unsigned int enic_msix_rq_intr(struct enic *enic, unsigned int rq)
-{
-	return enic->cq[enic_cq_rq(enic, rq)].interrupt_offset;
-}
-
-static inline unsigned int enic_msix_wq_intr(struct enic *enic, unsigned int wq)
-{
-	return enic->cq[enic_cq_wq(enic, wq)].interrupt_offset;
-}
-
-static inline unsigned int enic_msix_err_intr(struct enic *enic)
-{
-	return enic->rq_count + enic->wq_count;
-}
-
-static inline unsigned int enic_msix_notify_intr(struct enic *enic)
-{
-	return enic->rq_count + enic->wq_count + 1;
-}
-
-static int enic_get_settings(struct net_device *netdev,
-	struct ethtool_cmd *ecmd)
-{
-	struct enic *enic = netdev_priv(netdev);
-
-	ecmd->supported = (SUPPORTED_10000baseT_Full | SUPPORTED_FIBRE);
-	ecmd->advertising = (ADVERTISED_10000baseT_Full | ADVERTISED_FIBRE);
-	ecmd->port = PORT_FIBRE;
-	ecmd->transceiver = XCVR_EXTERNAL;
-
-	if (netif_carrier_ok(netdev)) {
-		ethtool_cmd_speed_set(ecmd, vnic_dev_port_speed(enic->vdev));
-		ecmd->duplex = DUPLEX_FULL;
-	} else {
-		ethtool_cmd_speed_set(ecmd, -1);
-		ecmd->duplex = -1;
-	}
-
-	ecmd->autoneg = AUTONEG_DISABLE;
-
-	return 0;
-}
-
-static void enic_get_drvinfo(struct net_device *netdev,
-	struct ethtool_drvinfo *drvinfo)
-{
-	struct enic *enic = netdev_priv(netdev);
-	struct vnic_devcmd_fw_info *fw_info;
-
-	enic_dev_fw_info(enic, &fw_info);
-
-	strlcpy(drvinfo->driver, DRV_NAME, sizeof(drvinfo->driver));
-	strlcpy(drvinfo->version, DRV_VERSION, sizeof(drvinfo->version));
-	strlcpy(drvinfo->fw_version, fw_info->fw_version,
-		sizeof(drvinfo->fw_version));
-	strlcpy(drvinfo->bus_info, pci_name(enic->pdev),
-		sizeof(drvinfo->bus_info));
-}
-
-static void enic_get_strings(struct net_device *netdev, u32 stringset, u8 *data)
-{
-	unsigned int i;
-
-	switch (stringset) {
-	case ETH_SS_STATS:
-		for (i = 0; i < enic_n_tx_stats; i++) {
-			memcpy(data, enic_tx_stats[i].name, ETH_GSTRING_LEN);
-			data += ETH_GSTRING_LEN;
-		}
-		for (i = 0; i < enic_n_rx_stats; i++) {
-			memcpy(data, enic_rx_stats[i].name, ETH_GSTRING_LEN);
-			data += ETH_GSTRING_LEN;
-		}
-		break;
-	}
-}
-
-static int enic_get_sset_count(struct net_device *netdev, int sset)
-{
-	switch (sset) {
-	case ETH_SS_STATS:
-		return enic_n_tx_stats + enic_n_rx_stats;
-	default:
-		return -EOPNOTSUPP;
-	}
-}
-
-static void enic_get_ethtool_stats(struct net_device *netdev,
-	struct ethtool_stats *stats, u64 *data)
-{
-	struct enic *enic = netdev_priv(netdev);
-	struct vnic_stats *vstats;
-	unsigned int i;
-
-	enic_dev_stats_dump(enic, &vstats);
-
-	for (i = 0; i < enic_n_tx_stats; i++)
-		*(data++) = ((u64 *)&vstats->tx)[enic_tx_stats[i].offset];
-	for (i = 0; i < enic_n_rx_stats; i++)
-		*(data++) = ((u64 *)&vstats->rx)[enic_rx_stats[i].offset];
-}
-
-static u32 enic_get_msglevel(struct net_device *netdev)
-{
-	struct enic *enic = netdev_priv(netdev);
-	return enic->msg_enable;
-}
-
-static void enic_set_msglevel(struct net_device *netdev, u32 value)
-{
-	struct enic *enic = netdev_priv(netdev);
-	enic->msg_enable = value;
-}
-
-static int enic_get_coalesce(struct net_device *netdev,
-	struct ethtool_coalesce *ecmd)
-{
-	struct enic *enic = netdev_priv(netdev);
-
-	ecmd->tx_coalesce_usecs = enic->tx_coalesce_usecs;
-	ecmd->rx_coalesce_usecs = enic->rx_coalesce_usecs;
-
-	return 0;
-}
-
-static int enic_set_coalesce(struct net_device *netdev,
-	struct ethtool_coalesce *ecmd)
-{
-	struct enic *enic = netdev_priv(netdev);
-	u32 tx_coalesce_usecs;
-	u32 rx_coalesce_usecs;
-	unsigned int i, intr;
-
-	tx_coalesce_usecs = min_t(u32, ecmd->tx_coalesce_usecs,
-		vnic_dev_get_intr_coal_timer_max(enic->vdev));
-	rx_coalesce_usecs = min_t(u32, ecmd->rx_coalesce_usecs,
-		vnic_dev_get_intr_coal_timer_max(enic->vdev));
-
-	switch (vnic_dev_get_intr_mode(enic->vdev)) {
-	case VNIC_DEV_INTR_MODE_INTX:
-		if (tx_coalesce_usecs != rx_coalesce_usecs)
-			return -EINVAL;
-
-		intr = enic_legacy_io_intr();
-		vnic_intr_coalescing_timer_set(&enic->intr[intr],
-			tx_coalesce_usecs);
-		break;
-	case VNIC_DEV_INTR_MODE_MSI:
-		if (tx_coalesce_usecs != rx_coalesce_usecs)
-			return -EINVAL;
-
-		vnic_intr_coalescing_timer_set(&enic->intr[0],
-			tx_coalesce_usecs);
-		break;
-	case VNIC_DEV_INTR_MODE_MSIX:
-		for (i = 0; i < enic->wq_count; i++) {
-			intr = enic_msix_wq_intr(enic, i);
-			vnic_intr_coalescing_timer_set(&enic->intr[intr],
-				tx_coalesce_usecs);
-		}
-
-		for (i = 0; i < enic->rq_count; i++) {
-			intr = enic_msix_rq_intr(enic, i);
-			vnic_intr_coalescing_timer_set(&enic->intr[intr],
-				rx_coalesce_usecs);
-		}
-
-		break;
-	default:
-		break;
-	}
-
-	enic->tx_coalesce_usecs = tx_coalesce_usecs;
-	enic->rx_coalesce_usecs = rx_coalesce_usecs;
-
-	return 0;
-}
-
-static const struct ethtool_ops enic_ethtool_ops = {
-	.get_settings = enic_get_settings,
-	.get_drvinfo = enic_get_drvinfo,
-	.get_msglevel = enic_get_msglevel,
-	.set_msglevel = enic_set_msglevel,
-	.get_link = ethtool_op_get_link,
-	.get_strings = enic_get_strings,
-	.get_sset_count = enic_get_sset_count,
-	.get_ethtool_stats = enic_get_ethtool_stats,
-	.get_coalesce = enic_get_coalesce,
-	.set_coalesce = enic_set_coalesce,
-};
-
 static void enic_free_wq_buf(struct vnic_wq *wq, struct vnic_wq_buf *buf)
 {
 	struct enic *enic = vnic_dev_priv(wq->vdev);
@@ -2496,7 +2228,7 @@ static int enic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		netdev->netdev_ops = &enic_netdev_ops;
 
 	netdev->watchdog_timeo = 2 * HZ;
-	netdev->ethtool_ops = &enic_ethtool_ops;
+	enic_set_ethtool_ops(netdev);
 
 	netdev->features |= NETIF_F_HW_VLAN_CTAG_TX | NETIF_F_HW_VLAN_CTAG_RX;
 	if (ENIC_SETTING(enic, LOOP)) {
