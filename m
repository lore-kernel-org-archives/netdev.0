From: zyjzyj2000@gmail.com
Subject: [PATCH 1/1] ixgbe: add fiber tranceiver plug/unplug notifier
Date: Wed, 15 Jun 2016 21:36:38 +0800
Message-ID: <1465997798-3261-2-git-send-email-zyjzyj2000@gmail.com>
References: <F6FB0E698C9B3143BDF729DF2228664696AC171C@ORSMSX116.amr.corp.intel.com>
 <1465997798-3261-1-git-send-email-zyjzyj2000@gmail.com>
Cc: Zhu Yanjun <zyjzyj2000@gmail.com>
To: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	donald.c.skidmore@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from [111.193.78.174] ([111.193.78.174]:35791 "EHLO mail.zhuyj.com"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S932130AbcFONp0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Jun 2016 09:45:26 -0400
In-Reply-To: <1465997798-3261-1-git-send-email-zyjzyj2000@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zhu Yanjun <zyjzyj2000@gmail.com>

When the fiber tranceiver is plugged/unplugged, a netdev notifier is
 sent. The userspace tools or kernel can receive this notifier.

Signed-off-by: Zhu Yanjun <zyjzyj2000@gmail.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |   24 +++++++++++++++++++++++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h |    2 ++
 2 files changed, 25 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 088c47c..1d8c1ff 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -5635,6 +5635,8 @@ static int ixgbe_sw_init(struct ixgbe_adapter *adapter)
 	hw->revision_id = pdev->revision;
 	hw->subsystem_vendor_id = pdev->subsystem_vendor;
 	hw->subsystem_device_id = pdev->subsystem_device;
+	hw->last_tranceiver_status = IXGBE_NOT_IMPLEMENTED;
+	hw->tranceiver_polltime = 0;
 
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
+	    time_after(jiffies, hw->tranceiver_polltime)) {
+		status = IXGBE_READ_REG(hw, IXGBE_ESDP) & IXGBE_ESDP_SDP2;
+		if (status != hw->last_tranceiver_status) {
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
+		hw->last_tranceiver_status = status;
+		hw->tranceiver_polltime = jiffies + 3 * HZ;
+	}
 
 	/* If crosstalk fix enabled verify the SFP+ cage is full */
 	if (adapter->need_crosstalk_fix) {
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
index da3d835..fe19899 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
@@ -3525,6 +3525,8 @@ struct ixgbe_hw {
 	bool				force_full_reset;
 	bool				allow_unsupported_sfp;
 	bool				wol_enabled;
+	s32				last_tranceiver_status;
+	unsigned long			tranceiver_polltime;
 };
 
 struct ixgbe_info {
-- 
1.7.9.5
