From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 05/13] ixgbe: move flags and state into the same cacheline
Date: Sat, 14 May 2011 18:23:39 -0700
Message-ID: <1305422627-9583-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1305422627-9583-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:52581 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759489Ab1EOBXv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 14 May 2011 21:23:51 -0400
In-Reply-To: <1305422627-9583-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change moves flags and state into the same cacheline.  The reason for
this change is because both are frequently read around the same time and
infrequently written.  By combining them into the same cacheline this
should help to reduce memory utilization.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Evan Swanson <evan.swanson@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe.h |   88 +++++++++++++++++++++++----------------------
 1 files changed, 45 insertions(+), 43 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/ixgbe/ixgbe.h
index 91c1540..ec948ff 100644
--- a/drivers/net/ixgbe/ixgbe.h
+++ b/drivers/net/ixgbe/ixgbe.h
@@ -341,10 +341,48 @@ struct ixgbe_q_vector {
 
 /* board specific private data structure */
 struct ixgbe_adapter {
-	struct timer_list watchdog_timer;
+	unsigned long state;
+
+	/* Some features need tri-state capability,
+	 * thus the additional *_CAPABLE flags.
+	 */
+	u32 flags;
+#define IXGBE_FLAG_RX_CSUM_ENABLED              (u32)(1)
+#define IXGBE_FLAG_MSI_CAPABLE                  (u32)(1 << 1)
+#define IXGBE_FLAG_MSI_ENABLED                  (u32)(1 << 2)
+#define IXGBE_FLAG_MSIX_CAPABLE                 (u32)(1 << 3)
+#define IXGBE_FLAG_MSIX_ENABLED                 (u32)(1 << 4)
+#define IXGBE_FLAG_RX_1BUF_CAPABLE              (u32)(1 << 6)
+#define IXGBE_FLAG_RX_PS_CAPABLE                (u32)(1 << 7)
+#define IXGBE_FLAG_RX_PS_ENABLED                (u32)(1 << 8)
+#define IXGBE_FLAG_IN_NETPOLL                   (u32)(1 << 9)
+#define IXGBE_FLAG_DCA_ENABLED                  (u32)(1 << 10)
+#define IXGBE_FLAG_DCA_CAPABLE                  (u32)(1 << 11)
+#define IXGBE_FLAG_IMIR_ENABLED                 (u32)(1 << 12)
+#define IXGBE_FLAG_MQ_CAPABLE                   (u32)(1 << 13)
+#define IXGBE_FLAG_DCB_ENABLED                  (u32)(1 << 14)
+#define IXGBE_FLAG_RSS_ENABLED                  (u32)(1 << 16)
+#define IXGBE_FLAG_RSS_CAPABLE                  (u32)(1 << 17)
+#define IXGBE_FLAG_VMDQ_CAPABLE                 (u32)(1 << 18)
+#define IXGBE_FLAG_VMDQ_ENABLED                 (u32)(1 << 19)
+#define IXGBE_FLAG_FAN_FAIL_CAPABLE             (u32)(1 << 20)
+#define IXGBE_FLAG_NEED_LINK_UPDATE             (u32)(1 << 22)
+#define IXGBE_FLAG_IN_SFP_LINK_TASK             (u32)(1 << 23)
+#define IXGBE_FLAG_IN_SFP_MOD_TASK              (u32)(1 << 24)
+#define IXGBE_FLAG_FDIR_HASH_CAPABLE            (u32)(1 << 25)
+#define IXGBE_FLAG_FDIR_PERFECT_CAPABLE         (u32)(1 << 26)
+#define IXGBE_FLAG_FCOE_CAPABLE                 (u32)(1 << 27)
+#define IXGBE_FLAG_FCOE_ENABLED                 (u32)(1 << 28)
+#define IXGBE_FLAG_SRIOV_CAPABLE                (u32)(1 << 29)
+#define IXGBE_FLAG_SRIOV_ENABLED                (u32)(1 << 30)
+
+	u32 flags2;
+#define IXGBE_FLAG2_RSC_CAPABLE                 (u32)(1)
+#define IXGBE_FLAG2_RSC_ENABLED                 (u32)(1 << 1)
+#define IXGBE_FLAG2_TEMP_SENSOR_CAPABLE         (u32)(1 << 2)
+
 	unsigned long active_vlans[BITS_TO_LONGS(VLAN_N_VID)];
 	u16 bd_number;
-	struct work_struct reset_task;
 	struct ixgbe_q_vector *q_vector[MAX_MSIX_Q_VECTORS];
 
 	/* DCB parameters */
@@ -387,43 +425,6 @@ struct ixgbe_adapter {
 	u32 alloc_rx_page_failed;
 	u32 alloc_rx_buff_failed;
 
-	/* Some features need tri-state capability,
-	 * thus the additional *_CAPABLE flags.
-	 */
-	u32 flags;
-#define IXGBE_FLAG_RX_CSUM_ENABLED              (u32)(1)
-#define IXGBE_FLAG_MSI_CAPABLE                  (u32)(1 << 1)
-#define IXGBE_FLAG_MSI_ENABLED                  (u32)(1 << 2)
-#define IXGBE_FLAG_MSIX_CAPABLE                 (u32)(1 << 3)
-#define IXGBE_FLAG_MSIX_ENABLED                 (u32)(1 << 4)
-#define IXGBE_FLAG_RX_1BUF_CAPABLE              (u32)(1 << 6)
-#define IXGBE_FLAG_RX_PS_CAPABLE                (u32)(1 << 7)
-#define IXGBE_FLAG_RX_PS_ENABLED                (u32)(1 << 8)
-#define IXGBE_FLAG_IN_NETPOLL                   (u32)(1 << 9)
-#define IXGBE_FLAG_DCA_ENABLED                  (u32)(1 << 10)
-#define IXGBE_FLAG_DCA_CAPABLE                  (u32)(1 << 11)
-#define IXGBE_FLAG_IMIR_ENABLED                 (u32)(1 << 12)
-#define IXGBE_FLAG_MQ_CAPABLE                   (u32)(1 << 13)
-#define IXGBE_FLAG_DCB_ENABLED                  (u32)(1 << 14)
-#define IXGBE_FLAG_RSS_ENABLED                  (u32)(1 << 16)
-#define IXGBE_FLAG_RSS_CAPABLE                  (u32)(1 << 17)
-#define IXGBE_FLAG_VMDQ_CAPABLE                 (u32)(1 << 18)
-#define IXGBE_FLAG_VMDQ_ENABLED                 (u32)(1 << 19)
-#define IXGBE_FLAG_FAN_FAIL_CAPABLE             (u32)(1 << 20)
-#define IXGBE_FLAG_NEED_LINK_UPDATE             (u32)(1 << 22)
-#define IXGBE_FLAG_IN_SFP_LINK_TASK             (u32)(1 << 23)
-#define IXGBE_FLAG_IN_SFP_MOD_TASK              (u32)(1 << 24)
-#define IXGBE_FLAG_FDIR_HASH_CAPABLE            (u32)(1 << 25)
-#define IXGBE_FLAG_FDIR_PERFECT_CAPABLE         (u32)(1 << 26)
-#define IXGBE_FLAG_FCOE_CAPABLE                 (u32)(1 << 27)
-#define IXGBE_FLAG_FCOE_ENABLED                 (u32)(1 << 28)
-#define IXGBE_FLAG_SRIOV_CAPABLE                (u32)(1 << 29)
-#define IXGBE_FLAG_SRIOV_ENABLED                (u32)(1 << 30)
-
-	u32 flags2;
-#define IXGBE_FLAG2_RSC_CAPABLE                 (u32)(1)
-#define IXGBE_FLAG2_RSC_ENABLED                 (u32)(1 << 1)
-#define IXGBE_FLAG2_TEMP_SENSOR_CAPABLE         (u32)(1 << 2)
 /* default to trying for four seconds */
 #define IXGBE_TRY_LINK_TIMEOUT (4 * HZ)
 
@@ -444,7 +445,6 @@ struct ixgbe_adapter {
 	u32 rx_eitr_param;
 	u32 tx_eitr_param;
 
-	unsigned long state;
 	u64 tx_busy;
 	unsigned int tx_ring_count;
 	unsigned int rx_ring_count;
@@ -453,15 +453,18 @@ struct ixgbe_adapter {
 	bool link_up;
 	unsigned long link_check_timeout;
 
+	struct work_struct reset_task;
 	struct work_struct watchdog_task;
 	struct work_struct sfp_task;
-	struct timer_list sfp_timer;
 	struct work_struct multispeed_fiber_task;
 	struct work_struct sfp_config_module_task;
+	struct work_struct fdir_reinit_task;
+	struct work_struct check_overtemp_task;
+	struct timer_list watchdog_timer;
+	struct timer_list sfp_timer;
 	u32 fdir_pballoc;
 	u32 atr_sample_rate;
 	spinlock_t fdir_perfect_lock;
-	struct work_struct fdir_reinit_task;
 #ifdef IXGBE_FCOE
 	struct ixgbe_fcoe fcoe;
 #endif /* IXGBE_FCOE */
@@ -472,7 +475,6 @@ struct ixgbe_adapter {
 
 	int node;
 	u32 led_reg;
-	struct work_struct check_overtemp_task;
 	u32 interrupt_event;
 	char lsc_int_name[IFNAMSIZ + 9];
 
-- 
1.7.4.4

