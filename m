From: Vasanthy Kolluri <vkolluri@cisco.com>
Subject: [net-next-2.6 PATCH 1/5] enic: Clean up: Organize devcmd wrapper
	routines
Date: Fri, 04 Feb 2011 18:17:05 -0800
Message-ID: <20110205021705.8510.20419.stgit@savbu-pc100.cisco.com>
References: <20110205021618.8510.34816.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-5.cisco.com ([171.68.10.87]:31097 "EHLO
	sj-iport-5.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752536Ab1BECRH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Feb 2011 21:17:07 -0500
In-Reply-To: <20110205021618.8510.34816.stgit@savbu-pc100.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasanthy Kolluri <vkolluri@cisco.com>

Organize the wrapper routines for firmware devcmds into a separate file.

Signed-off-by: Christian Benvenuti <benve@cisco.com>
Signed-off-by: Vasanthy Kolluri <vkolluri@cisco.com>
Signed-off-by: Roopa Prabhu <roprabhu@cisco.com>
Signed-off-by: David Wang <dwang2@cisco.com>
---
 drivers/net/enic/Makefile    |    2 
 drivers/net/enic/enic.h      |    2 
 drivers/net/enic/enic_dev.c  |  230 ++++++++++++++++++++++++++++++++++++++++++
 drivers/net/enic/enic_dev.h  |   42 ++++++++
 drivers/net/enic/enic_main.c |  207 --------------------------------------
 5 files changed, 275 insertions(+), 208 deletions(-)
 create mode 100644 drivers/net/enic/enic_dev.c
 create mode 100644 drivers/net/enic/enic_dev.h


diff --git a/drivers/net/enic/Makefile b/drivers/net/enic/Makefile
index e7b6c31..2e573be 100644
--- a/drivers/net/enic/Makefile
+++ b/drivers/net/enic/Makefile
@@ -1,5 +1,5 @@
 obj-$(CONFIG_ENIC) := enic.o
 
 enic-y := enic_main.o vnic_cq.o vnic_intr.o vnic_wq.o \
-	enic_res.o vnic_dev.o vnic_rq.o vnic_vic.o
+	enic_res.o enic_dev.o vnic_dev.o vnic_rq.o vnic_vic.o
 
diff --git a/drivers/net/enic/enic.h b/drivers/net/enic/enic.h
index 44865bb..1385a60 100644
--- a/drivers/net/enic/enic.h
+++ b/drivers/net/enic/enic.h
@@ -32,7 +32,7 @@
 
 #define DRV_NAME		"enic"
 #define DRV_DESCRIPTION		"Cisco VIC Ethernet NIC Driver"
-#define DRV_VERSION		"2.1.1.2a"
+#define DRV_VERSION		"2.1.1.3"
 #define DRV_COPYRIGHT		"Copyright 2008-2011 Cisco Systems, Inc"
 
 #define ENIC_BARS_MAX		6
diff --git a/drivers/net/enic/enic_dev.c b/drivers/net/enic/enic_dev.c
new file mode 100644
index 0000000..a52dbd2
--- /dev/null
+++ b/drivers/net/enic/enic_dev.c
@@ -0,0 +1,230 @@
+/*
+ * Copyright 2011 Cisco Systems, Inc.  All rights reserved.
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
+#include <linux/pci.h>
+#include <linux/etherdevice.h>
+
+#include "vnic_dev.h"
+#include "vnic_vic.h"
+#include "enic_res.h"
+#include "enic.h"
+#include "enic_dev.h"
+
+int enic_dev_fw_info(struct enic *enic, struct vnic_devcmd_fw_info **fw_info)
+{
+	int err;
+
+	spin_lock(&enic->devcmd_lock);
+	err = vnic_dev_fw_info(enic->vdev, fw_info);
+	spin_unlock(&enic->devcmd_lock);
+
+	return err;
+}
+
+int enic_dev_stats_dump(struct enic *enic, struct vnic_stats **vstats)
+{
+	int err;
+
+	spin_lock(&enic->devcmd_lock);
+	err = vnic_dev_stats_dump(enic->vdev, vstats);
+	spin_unlock(&enic->devcmd_lock);
+
+	return err;
+}
+
+int enic_dev_add_station_addr(struct enic *enic)
+{
+	int err = 0;
+
+	if (is_valid_ether_addr(enic->netdev->dev_addr)) {
+		spin_lock(&enic->devcmd_lock);
+		err = vnic_dev_add_addr(enic->vdev, enic->netdev->dev_addr);
+		spin_unlock(&enic->devcmd_lock);
+	}
+
+	return err;
+}
+
+int enic_dev_del_station_addr(struct enic *enic)
+{
+	int err = 0;
+
+	if (is_valid_ether_addr(enic->netdev->dev_addr)) {
+		spin_lock(&enic->devcmd_lock);
+		err = vnic_dev_del_addr(enic->vdev, enic->netdev->dev_addr);
+		spin_unlock(&enic->devcmd_lock);
+	}
+
+	return err;
+}
+
+int enic_dev_packet_filter(struct enic *enic, int directed, int multicast,
+	int broadcast, int promisc, int allmulti)
+{
+	int err;
+
+	spin_lock(&enic->devcmd_lock);
+	err = vnic_dev_packet_filter(enic->vdev, directed,
+		multicast, broadcast, promisc, allmulti);
+	spin_unlock(&enic->devcmd_lock);
+
+	return err;
+}
+
+int enic_dev_add_addr(struct enic *enic, u8 *addr)
+{
+	int err;
+
+	spin_lock(&enic->devcmd_lock);
+	err = vnic_dev_add_addr(enic->vdev, addr);
+	spin_unlock(&enic->devcmd_lock);
+
+	return err;
+}
+
+int enic_dev_del_addr(struct enic *enic, u8 *addr)
+{
+	int err;
+
+	spin_lock(&enic->devcmd_lock);
+	err = vnic_dev_del_addr(enic->vdev, addr);
+	spin_unlock(&enic->devcmd_lock);
+
+	return err;
+}
+
+int enic_dev_hw_version(struct enic *enic, enum vnic_dev_hw_version *hw_ver)
+{
+	int err;
+
+	spin_lock(&enic->devcmd_lock);
+	err = vnic_dev_hw_version(enic->vdev, hw_ver);
+	spin_unlock(&enic->devcmd_lock);
+
+	return err;
+}
+
+int enic_dev_notify_unset(struct enic *enic)
+{
+	int err;
+
+	spin_lock(&enic->devcmd_lock);
+	err = vnic_dev_notify_unset(enic->vdev);
+	spin_unlock(&enic->devcmd_lock);
+
+	return err;
+}
+
+int enic_dev_hang_notify(struct enic *enic)
+{
+	int err;
+
+	spin_lock(&enic->devcmd_lock);
+	err = vnic_dev_hang_notify(enic->vdev);
+	spin_unlock(&enic->devcmd_lock);
+
+	return err;
+}
+
+int enic_dev_set_ig_vlan_rewrite_mode(struct enic *enic)
+{
+	int err;
+
+	spin_lock(&enic->devcmd_lock);
+	err = vnic_dev_set_ig_vlan_rewrite_mode(enic->vdev,
+		IG_VLAN_REWRITE_MODE_PRIORITY_TAG_DEFAULT_VLAN);
+	spin_unlock(&enic->devcmd_lock);
+
+	return err;
+}
+
+int enic_dev_enable(struct enic *enic)
+{
+	int err;
+
+	spin_lock(&enic->devcmd_lock);
+	err = vnic_dev_enable_wait(enic->vdev);
+	spin_unlock(&enic->devcmd_lock);
+
+	return err;
+}
+
+int enic_dev_disable(struct enic *enic)
+{
+	int err;
+
+	spin_lock(&enic->devcmd_lock);
+	err = vnic_dev_disable(enic->vdev);
+	spin_unlock(&enic->devcmd_lock);
+
+	return err;
+}
+
+int enic_vnic_dev_deinit(struct enic *enic)
+{
+	int err;
+
+	spin_lock(&enic->devcmd_lock);
+	err = vnic_dev_deinit(enic->vdev);
+	spin_unlock(&enic->devcmd_lock);
+
+	return err;
+}
+
+int enic_dev_init_prov(struct enic *enic, struct vic_provinfo *vp)
+{
+	int err;
+
+	spin_lock(&enic->devcmd_lock);
+	err = vnic_dev_init_prov(enic->vdev,
+		(u8 *)vp, vic_provinfo_size(vp));
+	spin_unlock(&enic->devcmd_lock);
+
+	return err;
+}
+
+int enic_dev_init_done(struct enic *enic, int *done, int *error)
+{
+	int err;
+
+	spin_lock(&enic->devcmd_lock);
+	err = vnic_dev_init_done(enic->vdev, done, error);
+	spin_unlock(&enic->devcmd_lock);
+
+	return err;
+}
+
+/* rtnl lock is held */
+void enic_vlan_rx_add_vid(struct net_device *netdev, u16 vid)
+{
+	struct enic *enic = netdev_priv(netdev);
+
+	spin_lock(&enic->devcmd_lock);
+	enic_add_vlan(enic, vid);
+	spin_unlock(&enic->devcmd_lock);
+}
+
+/* rtnl lock is held */
+void enic_vlan_rx_kill_vid(struct net_device *netdev, u16 vid)
+{
+	struct enic *enic = netdev_priv(netdev);
+
+	spin_lock(&enic->devcmd_lock);
+	enic_del_vlan(enic, vid);
+	spin_unlock(&enic->devcmd_lock);
+}
diff --git a/drivers/net/enic/enic_dev.h b/drivers/net/enic/enic_dev.h
new file mode 100644
index 0000000..3ac6ba1
--- /dev/null
+++ b/drivers/net/enic/enic_dev.h
@@ -0,0 +1,42 @@
+/*
+ * Copyright 2011 Cisco Systems, Inc.  All rights reserved.
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
+#ifndef _ENIC_DEV_H_
+#define _ENIC_DEV_H_
+
+int enic_dev_fw_info(struct enic *enic, struct vnic_devcmd_fw_info **fw_info);
+int enic_dev_stats_dump(struct enic *enic, struct vnic_stats **vstats);
+int enic_dev_add_station_addr(struct enic *enic);
+int enic_dev_del_station_addr(struct enic *enic);
+int enic_dev_packet_filter(struct enic *enic, int directed, int multicast,
+	int broadcast, int promisc, int allmulti);
+int enic_dev_add_addr(struct enic *enic, u8 *addr);
+int enic_dev_del_addr(struct enic *enic, u8 *addr);
+void enic_vlan_rx_add_vid(struct net_device *netdev, u16 vid);
+void enic_vlan_rx_kill_vid(struct net_device *netdev, u16 vid);
+int enic_dev_hw_version(struct enic *enic, enum vnic_dev_hw_version *hw_ver);
+int enic_dev_notify_unset(struct enic *enic);
+int enic_dev_hang_notify(struct enic *enic);
+int enic_dev_set_ig_vlan_rewrite_mode(struct enic *enic);
+int enic_dev_enable(struct enic *enic);
+int enic_dev_disable(struct enic *enic);
+int enic_vnic_dev_deinit(struct enic *enic);
+int enic_dev_init_prov(struct enic *enic, struct vic_provinfo *vp);
+int enic_dev_init_done(struct enic *enic, int *done, int *error);
+
+#endif /* _ENIC_DEV_H_ */
diff --git a/drivers/net/enic/enic_main.c b/drivers/net/enic/enic_main.c
index 37f907b..3893370 100644
--- a/drivers/net/enic/enic_main.c
+++ b/drivers/net/enic/enic_main.c
@@ -44,6 +44,7 @@
 #include "vnic_vic.h"
 #include "enic_res.h"
 #include "enic.h"
+#include "enic_dev.h"
 
 #define ENIC_NOTIFY_TIMER_PERIOD	(2 * HZ)
 #define WQ_ENET_MAX_DESC_LEN		(1 << WQ_ENET_LEN_BITS)
@@ -190,18 +191,6 @@ static int enic_get_settings(struct net_device *netdev,
 	return 0;
 }
 
-static int enic_dev_fw_info(struct enic *enic,
-	struct vnic_devcmd_fw_info **fw_info)
-{
-	int err;
-
-	spin_lock(&enic->devcmd_lock);
-	err = vnic_dev_fw_info(enic->vdev, fw_info);
-	spin_unlock(&enic->devcmd_lock);
-
-	return err;
-}
-
 static void enic_get_drvinfo(struct net_device *netdev,
 	struct ethtool_drvinfo *drvinfo)
 {
@@ -246,17 +235,6 @@ static int enic_get_sset_count(struct net_device *netdev, int sset)
 	}
 }
 
-static int enic_dev_stats_dump(struct enic *enic, struct vnic_stats **vstats)
-{
-	int err;
-
-	spin_lock(&enic->devcmd_lock);
-	err = vnic_dev_stats_dump(enic->vdev, vstats);
-	spin_unlock(&enic->devcmd_lock);
-
-	return err;
-}
-
 static void enic_get_ethtool_stats(struct net_device *netdev,
 	struct ethtool_stats *stats, u64 *data)
 {
@@ -919,32 +897,6 @@ static int enic_set_mac_addr(struct net_device *netdev, char *addr)
 	return 0;
 }
 
-static int enic_dev_add_station_addr(struct enic *enic)
-{
-	int err = 0;
-
-	if (is_valid_ether_addr(enic->netdev->dev_addr)) {
-		spin_lock(&enic->devcmd_lock);
-		err = vnic_dev_add_addr(enic->vdev, enic->netdev->dev_addr);
-		spin_unlock(&enic->devcmd_lock);
-	}
-
-	return err;
-}
-
-static int enic_dev_del_station_addr(struct enic *enic)
-{
-	int err = 0;
-
-	if (is_valid_ether_addr(enic->netdev->dev_addr)) {
-		spin_lock(&enic->devcmd_lock);
-		err = vnic_dev_del_addr(enic->vdev, enic->netdev->dev_addr);
-		spin_unlock(&enic->devcmd_lock);
-	}
-
-	return err;
-}
-
 static int enic_set_mac_address_dynamic(struct net_device *netdev, void *p)
 {
 	struct enic *enic = netdev_priv(netdev);
@@ -989,41 +941,6 @@ static int enic_set_mac_address(struct net_device *netdev, void *p)
 	return enic_dev_add_station_addr(enic);
 }
 
-static int enic_dev_packet_filter(struct enic *enic, int directed,
-	int multicast, int broadcast, int promisc, int allmulti)
-{
-	int err;
-
-	spin_lock(&enic->devcmd_lock);
-	err = vnic_dev_packet_filter(enic->vdev, directed,
-		multicast, broadcast, promisc, allmulti);
-	spin_unlock(&enic->devcmd_lock);
-
-	return err;
-}
-
-static int enic_dev_add_addr(struct enic *enic, u8 *addr)
-{
-	int err;
-
-	spin_lock(&enic->devcmd_lock);
-	err = vnic_dev_add_addr(enic->vdev, addr);
-	spin_unlock(&enic->devcmd_lock);
-
-	return err;
-}
-
-static int enic_dev_del_addr(struct enic *enic, u8 *addr)
-{
-	int err;
-
-	spin_lock(&enic->devcmd_lock);
-	err = vnic_dev_del_addr(enic->vdev, addr);
-	spin_unlock(&enic->devcmd_lock);
-
-	return err;
-}
-
 static void enic_add_multicast_addr_list(struct enic *enic)
 {
 	struct net_device *netdev = enic->netdev;
@@ -1170,26 +1087,6 @@ static void enic_vlan_rx_register(struct net_device *netdev,
 	enic->vlan_group = vlan_group;
 }
 
-/* rtnl lock is held */
-static void enic_vlan_rx_add_vid(struct net_device *netdev, u16 vid)
-{
-	struct enic *enic = netdev_priv(netdev);
-
-	spin_lock(&enic->devcmd_lock);
-	enic_add_vlan(enic, vid);
-	spin_unlock(&enic->devcmd_lock);
-}
-
-/* rtnl lock is held */
-static void enic_vlan_rx_kill_vid(struct net_device *netdev, u16 vid)
-{
-	struct enic *enic = netdev_priv(netdev);
-
-	spin_lock(&enic->devcmd_lock);
-	enic_del_vlan(enic, vid);
-	spin_unlock(&enic->devcmd_lock);
-}
-
 /* netif_tx_lock held, BHs disabled */
 static void enic_tx_timeout(struct net_device *netdev)
 {
@@ -1197,40 +1094,6 @@ static void enic_tx_timeout(struct net_device *netdev)
 	schedule_work(&enic->reset);
 }
 
-static int enic_vnic_dev_deinit(struct enic *enic)
-{
-	int err;
-
-	spin_lock(&enic->devcmd_lock);
-	err = vnic_dev_deinit(enic->vdev);
-	spin_unlock(&enic->devcmd_lock);
-
-	return err;
-}
-
-static int enic_dev_init_prov(struct enic *enic, struct vic_provinfo *vp)
-{
-	int err;
-
-	spin_lock(&enic->devcmd_lock);
-	err = vnic_dev_init_prov(enic->vdev,
-		(u8 *)vp, vic_provinfo_size(vp));
-	spin_unlock(&enic->devcmd_lock);
-
-	return err;
-}
-
-static int enic_dev_init_done(struct enic *enic, int *done, int *error)
-{
-	int err;
-
-	spin_lock(&enic->devcmd_lock);
-	err = vnic_dev_init_done(enic->vdev, done, error);
-	spin_unlock(&enic->devcmd_lock);
-
-	return err;
-}
-
 static int enic_set_vf_mac(struct net_device *netdev, int vf, u8 *mac)
 {
 	struct enic *enic = netdev_priv(netdev);
@@ -1505,18 +1368,6 @@ static int enic_rq_alloc_buf_a1(struct vnic_rq *rq)
 	return 0;
 }
 
-static int enic_dev_hw_version(struct enic *enic,
-	enum vnic_dev_hw_version *hw_ver)
-{
-	int err;
-
-	spin_lock(&enic->devcmd_lock);
-	err = vnic_dev_hw_version(enic->vdev, hw_ver);
-	spin_unlock(&enic->devcmd_lock);
-
-	return err;
-}
-
 static int enic_set_rq_alloc_buf(struct enic *enic)
 {
 	enum vnic_dev_hw_version hw_ver;
@@ -1897,39 +1748,6 @@ static int enic_dev_notify_set(struct enic *enic)
 	return err;
 }
 
-static int enic_dev_notify_unset(struct enic *enic)
-{
-	int err;
-
-	spin_lock(&enic->devcmd_lock);
-	err = vnic_dev_notify_unset(enic->vdev);
-	spin_unlock(&enic->devcmd_lock);
-
-	return err;
-}
-
-static int enic_dev_enable(struct enic *enic)
-{
-	int err;
-
-	spin_lock(&enic->devcmd_lock);
-	err = vnic_dev_enable_wait(enic->vdev);
-	spin_unlock(&enic->devcmd_lock);
-
-	return err;
-}
-
-static int enic_dev_disable(struct enic *enic)
-{
-	int err;
-
-	spin_lock(&enic->devcmd_lock);
-	err = vnic_dev_disable(enic->vdev);
-	spin_unlock(&enic->devcmd_lock);
-
-	return err;
-}
-
 static void enic_notify_timer_start(struct enic *enic)
 {
 	switch (vnic_dev_get_intr_mode(enic->vdev)) {
@@ -2281,29 +2099,6 @@ static int enic_set_rss_nic_cfg(struct enic *enic)
 		rss_hash_bits, rss_base_cpu, rss_enable);
 }
 
-static int enic_dev_hang_notify(struct enic *enic)
-{
-	int err;
-
-	spin_lock(&enic->devcmd_lock);
-	err = vnic_dev_hang_notify(enic->vdev);
-	spin_unlock(&enic->devcmd_lock);
-
-	return err;
-}
-
-static int enic_dev_set_ig_vlan_rewrite_mode(struct enic *enic)
-{
-	int err;
-
-	spin_lock(&enic->devcmd_lock);
-	err = vnic_dev_set_ig_vlan_rewrite_mode(enic->vdev,
-		IG_VLAN_REWRITE_MODE_PRIORITY_TAG_DEFAULT_VLAN);
-	spin_unlock(&enic->devcmd_lock);
-
-	return err;
-}
-
 static void enic_reset(struct work_struct *work)
 {
 	struct enic *enic = container_of(work, struct enic, reset);

