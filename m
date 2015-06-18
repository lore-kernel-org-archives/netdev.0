From: Taku Izumi <izumi.taku@jp.fujitsu.com>
Subject: [PATCH 15/22] fjes: net_device_ops.ndo_vlan_rx_add/kill_vid
Date: Thu, 18 Jun 2015 09:49:40 +0900
Message-ID: <1434588587-25655-15-git-send-email-izumi.taku@jp.fujitsu.com>
References: <1434588359-25589-1-git-send-email-izumi.taku@jp.fujitsu.com>
 <1434588587-25655-1-git-send-email-izumi.taku@jp.fujitsu.com>
Cc: rkhan@redhat.com, alexander.h.duyck@redhat.com,
	netdev@vger.kernel.org, linux-acpi@vger.kernel.org,
	Taku Izumi <izumi.taku@jp.fujitsu.com>
To: platform-driver-x86@vger.kernel.org, dvhart@infradead.org
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <1434588587-25655-1-git-send-email-izumi.taku@jp.fujitsu.com>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds net_device_ops.ndo_vlan_rx_add_vid and
net_device_ops.ndo_vlan_rx_kill_vid callback.

Signed-off-by: Taku Izumi <izumi.taku@jp.fujitsu.com>
---
 drivers/platform/x86/fjes/fjes_hw.c   | 27 +++++++++++++++++++++++
 drivers/platform/x86/fjes/fjes_hw.h   |  2 ++
 drivers/platform/x86/fjes/fjes_main.c | 40 +++++++++++++++++++++++++++++++++++
 3 files changed, 69 insertions(+)

diff --git a/drivers/platform/x86/fjes/fjes_hw.c b/drivers/platform/x86/fjes/fjes_hw.c
index da509bd..85f9693 100644
--- a/drivers/platform/x86/fjes/fjes_hw.c
+++ b/drivers/platform/x86/fjes/fjes_hw.c
@@ -843,6 +843,33 @@ bool fjes_hw_check_vlan_id(struct epbuf_handler *epbh, u16 vlan_id)
 	return ret;
 }
 
+bool fjes_hw_set_vlan_id(struct epbuf_handler *epbh, u16 vlan_id)
+{
+	union ep_buffer_info *info = epbh->info;
+	int i;
+
+	for (i = 0; i < EP_BUFFER_SUPPORT_VLAN_MAX; i++) {
+		if (info->v1i.vlan_id[i] == 0) {
+			info->v1i.vlan_id[i] = vlan_id;
+			return true;
+		}
+	}
+	return false;
+}
+
+void fjes_hw_del_vlan_id(struct epbuf_handler *epbh, u16 vlan_id)
+{
+	union ep_buffer_info *info = epbh->info;
+	int i;
+
+	if (0 != vlan_id) {
+		for (i = 0; i < EP_BUFFER_SUPPORT_VLAN_MAX; i++) {
+			if (vlan_id == info->v1i.vlan_id[i])
+				info->v1i.vlan_id[i] = 0;
+		}
+	}
+}
+
 bool fjes_hw_epbuf_rx_is_empty(struct epbuf_handler *epbh)
 {
 	union ep_buffer_info *info;
diff --git a/drivers/platform/x86/fjes/fjes_hw.h b/drivers/platform/x86/fjes/fjes_hw.h
index 1ad0fcb..14e8db9 100644
--- a/drivers/platform/x86/fjes/fjes_hw.h
+++ b/drivers/platform/x86/fjes/fjes_hw.h
@@ -325,6 +325,8 @@ int fjes_hw_epid_is_shared(struct fjes_device_shared_info *, int);
 bool fjes_hw_check_epbuf_version(struct epbuf_handler *, u32);
 bool fjes_hw_check_mtu(struct epbuf_handler *, u32);
 bool fjes_hw_check_vlan_id(struct epbuf_handler *, u16);
+bool fjes_hw_set_vlan_id(struct epbuf_handler *, u16);
+void fjes_hw_del_vlan_id(struct epbuf_handler *, u16);
 bool fjes_hw_epbuf_rx_is_empty(struct epbuf_handler *);
 void *fjes_hw_epbuf_rx_curpkt_get_addr(struct epbuf_handler *,
 		size_t *);
diff --git a/drivers/platform/x86/fjes/fjes_main.c b/drivers/platform/x86/fjes/fjes_main.c
index 84727d8..f5df457 100644
--- a/drivers/platform/x86/fjes/fjes_main.c
+++ b/drivers/platform/x86/fjes/fjes_main.c
@@ -60,6 +60,8 @@ static irqreturn_t fjes_intr(int, void*);
 static struct rtnl_link_stats64
 *fjes_get_stats64(struct net_device *, struct rtnl_link_stats64 *);
 static int fjes_change_mtu(struct net_device *, int);
+static int fjes_vlan_rx_add_vid(struct net_device *, __be16 proto, u16);
+static int fjes_vlan_rx_kill_vid(struct net_device *, __be16 proto, u16);
 static void fjes_tx_retry(struct net_device *);
 
 static int fjes_acpi_add(struct acpi_device *);
@@ -230,6 +232,8 @@ static const struct net_device_ops fjes_netdev_ops = {
 	.ndo_get_stats64	= fjes_get_stats64,
 	.ndo_change_mtu		= fjes_change_mtu,
 	.ndo_tx_timeout		= fjes_tx_retry,
+	.ndo_vlan_rx_add_vid	= fjes_vlan_rx_add_vid,
+	.ndo_vlan_rx_kill_vid = fjes_vlan_rx_kill_vid,
 };
 
 /*
@@ -787,6 +791,42 @@ static int fjes_change_mtu(struct net_device *netdev, int new_mtu)
 	return -EINVAL;
 }
 
+static int fjes_vlan_rx_add_vid(struct net_device *netdev,
+		__be16 proto, u16 vid)
+{
+	struct fjes_adapter *adapter = netdev_priv(netdev);
+	bool ret = true;
+	int epid;
+
+	for (epid = 0; epid < adapter->hw.max_epid; epid++) {
+		if (epid == adapter->hw.my_epid)
+			continue;
+
+		if (!fjes_hw_check_vlan_id(
+			&(adapter->hw.ep_shm_info[epid].tx), vid))
+			ret = fjes_hw_set_vlan_id(
+				&(adapter->hw.ep_shm_info[epid].tx), vid);
+	}
+
+	return ret ? 0 : -ENOSPC;
+}
+
+static int fjes_vlan_rx_kill_vid(struct net_device *netdev,
+		__be16 proto, u16 vid)
+{
+	struct fjes_adapter *adapter = netdev_priv(netdev);
+	int epid;
+
+	for (epid = 0; epid < adapter->hw.max_epid; epid++) {
+		if (epid == adapter->hw.my_epid)
+			continue;
+
+		fjes_hw_del_vlan_id(&(adapter->hw.ep_shm_info[epid].tx), vid);
+	}
+
+	return 0;
+}
+
 static irqreturn_t fjes_intr(int irq, void *data)
 {
 	struct fjes_adapter *adapter = data;
-- 
1.8.3.1

