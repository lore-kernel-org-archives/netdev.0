From: zyjzyj2000@gmail.com
Subject: [PATCH net-next v2 1/1] ixgbe: add fiber tranceiver plug/unplug notifier
Date: Fri, 17 Jun 2016 00:04:24 +0800
Message-ID: <1466093064-14027-2-git-send-email-zyjzyj2000@gmail.com>
References: <1466093064-14027-1-git-send-email-zyjzyj2000@gmail.com>
Cc: Zhu Yanjun <zyjzyj2000@gmail.com>
To: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	donald.c.skidmore@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from [111.193.78.174] ([111.193.78.174]:33310 "EHLO mail.zhuyj.com"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753962AbcFPQE3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Jun 2016 12:04:29 -0400
In-Reply-To: <1466093064-14027-1-git-send-email-zyjzyj2000@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zhu Yanjun <zyjzyj2000@gmail.com>

When the fiber tranceiver is plugged/unplugged, a netdev notifier is
sent. The userspace tools or kernel can receive this notifier.

Signed-off-by: Zhu Yanjun <zyjzyj2000@gmail.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe.h      |    2 ++
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |   24 +++++++++++++++++++++++-
 include/linux/netdevice.h                     |    2 ++
 3 files changed, 27 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index 9f2db18..b3fe5d8 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -806,6 +806,8 @@ struct ixgbe_adapter {
 	u32 rss_key[IXGBE_RSS_KEY_SIZE / sizeof(u32)];
 
 	bool need_crosstalk_fix;
+	s32  last_tranceiver_status;
+	unsigned long tranceiver_polltime;
 };
 
 static inline u8 ixgbe_max_rss_indices(struct ixgbe_adapter *adapter)
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 088c47c..488adf1 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -5635,6 +5635,8 @@ static int ixgbe_sw_init(struct ixgbe_adapter *adapter)
 	hw->revision_id = pdev->revision;
 	hw->subsystem_vendor_id = pdev->subsystem_vendor;
 	hw->subsystem_device_id = pdev->subsystem_device;
+	adapter->last_tranceiver_status = IXGBE_NOT_IMPLEMENTED;
+	adapter->tranceiver_polltime = 0;
 
 	/* Set common capability flags and settings */
 	rss = min_t(int, ixgbe_max_rss_indices(adapter), num_online_cpus());
@@ -7067,7 +7069,27 @@ static void ixgbe_watchdog_subtask(struct ixgbe_adapter *adapter)
 static void ixgbe_sfp_detection_subtask(struct ixgbe_adapter *adapter)
 {
 	struct ixgbe_hw *hw = &adapter->hw;
-	s32 err;
+	s32 err, status;
+
+	if ((hw->mac.ops.get_media_type(hw) == ixgbe_media_type_fiber) &&
+	    time_after(jiffies, adapter->tranceiver_polltime)) {
+		status = IXGBE_READ_REG(hw, IXGBE_ESDP) & IXGBE_ESDP_SDP2;
+		if (status != adapter->last_tranceiver_status) {
+			unsigned long val;
+
+			if (!status) {
+				hw->phy.sfp_type = ixgbe_sfp_type_not_present;
+				val = NETDEV_FIBER_TRANCEIVER_UNPLUG;
+			} else {
+				val = NETDEV_FIBER_TRANCEIVER_PLUG;
+			}
+			rtnl_lock();
+			call_netdevice_notifiers(val, adapter->netdev);
+			rtnl_unlock();
+		}
+		adapter->last_tranceiver_status = status;
+		adapter->tranceiver_polltime = jiffies + 3 * HZ;
+	}
 
 	/* If crosstalk fix enabled verify the SFP+ cage is full */
 	if (adapter->need_crosstalk_fix) {
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index d101e4d..693ba92 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2253,6 +2253,8 @@ struct netdev_lag_lower_state_info {
 #define NETDEV_CHANGELOWERSTATE	0x001B
 #define NETDEV_OFFLOAD_PUSH_VXLAN	0x001C
 #define NETDEV_OFFLOAD_PUSH_GENEVE	0x001D
+#define NETDEV_FIBER_TRANCEIVER_PLUG	0x001E
+#define NETDEV_FIBER_TRANCEIVER_UNPLUG	0x001F
 
 int register_netdevice_notifier(struct notifier_block *nb);
 int unregister_netdevice_notifier(struct notifier_block *nb);
-- 
1.7.9.5
