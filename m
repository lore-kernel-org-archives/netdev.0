From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH] ixgbe: only process one ixgbe_watchdog_task at a
	time.
Date: Sat, 23 Jan 2010 02:17:31 -0800
Message-ID: <20100123101644.12479.40925.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	John Fastabend <john.r.fastabend@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta09.westchester.pa.mail.comcast.net ([76.96.62.96]:37420
	"EHLO qmta09.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752151Ab0AWKRt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Jan 2010 05:17:49 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@intel.com>

Processing multiple ixgbe_watchdog_task calls may cause
the link_up variable and IXGBE_FLAG_NEED_LINK_UPDATE flag
to be set incorrectly.  In the worse case this is causing
the netif_carrier_off to be called inappropriately which
results in an interface that can't be brought up.

Although schedule_work() will only schedule the task if
it is not already on the work queue the WORK_STRUCT_PENDING
bits are cleared just before calling the work function.
This allows WORK_STRUCT_PENDING to be cleared, the work
function to start and meanwhile schedule another task.

This patch moves the IN_IXGBE_WATCHDOG_TASK flag into the
adapter state and uses test_and_set_bit/clear_bit operations
to guarentee this works as expected.

This bug is actualized by changing DCB settings or doing
extended cable pull tests.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe.h      |   20 ++++++++++----------
 drivers/net/ixgbe/ixgbe_main.c |    5 +++--
 2 files changed, 13 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/ixgbe/ixgbe.h
index e3909d3..cd6ed64 100644
--- a/drivers/net/ixgbe/ixgbe.h
+++ b/drivers/net/ixgbe/ixgbe.h
@@ -341,15 +341,14 @@ struct ixgbe_adapter {
 #define IXGBE_FLAG_VMDQ_ENABLED                 (u32)(1 << 19)
 #define IXGBE_FLAG_FAN_FAIL_CAPABLE             (u32)(1 << 20)
 #define IXGBE_FLAG_NEED_LINK_UPDATE             (u32)(1 << 22)
-#define IXGBE_FLAG_IN_WATCHDOG_TASK             (u32)(1 << 23)
-#define IXGBE_FLAG_IN_SFP_LINK_TASK             (u32)(1 << 24)
-#define IXGBE_FLAG_IN_SFP_MOD_TASK              (u32)(1 << 25)
-#define IXGBE_FLAG_FDIR_HASH_CAPABLE            (u32)(1 << 26)
-#define IXGBE_FLAG_FDIR_PERFECT_CAPABLE         (u32)(1 << 27)
-#define IXGBE_FLAG_FCOE_CAPABLE                 (u32)(1 << 28)
-#define IXGBE_FLAG_FCOE_ENABLED                 (u32)(1 << 29)
-#define IXGBE_FLAG_SRIOV_CAPABLE                (u32)(1 << 30)
-#define IXGBE_FLAG_SRIOV_ENABLED                (u32)(1 << 31)
+#define IXGBE_FLAG_IN_SFP_LINK_TASK             (u32)(1 << 23)
+#define IXGBE_FLAG_IN_SFP_MOD_TASK              (u32)(1 << 24)
+#define IXGBE_FLAG_FDIR_HASH_CAPABLE            (u32)(1 << 25)
+#define IXGBE_FLAG_FDIR_PERFECT_CAPABLE         (u32)(1 << 26)
+#define IXGBE_FLAG_FCOE_CAPABLE                 (u32)(1 << 27)
+#define IXGBE_FLAG_FCOE_ENABLED                 (u32)(1 << 28)
+#define IXGBE_FLAG_SRIOV_CAPABLE                (u32)(1 << 29)
+#define IXGBE_FLAG_SRIOV_ENABLED                (u32)(1 << 30)
 
 	u32 flags2;
 #define IXGBE_FLAG2_RSC_CAPABLE                 (u32)(1)
@@ -411,7 +410,8 @@ enum ixbge_state_t {
 	__IXGBE_RESETTING,
 	__IXGBE_DOWN,
 	__IXGBE_FDIR_INIT_DONE,
-	__IXGBE_SFP_MODULE_NOT_FOUND
+	__IXGBE_SFP_MODULE_NOT_FOUND,
+	__IXGBE_IN_WATCHDOG_TASK
 };
 
 enum ixgbe_boards {
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 8d206f7..cbc62db 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -5013,7 +5013,8 @@ static void ixgbe_watchdog_task(struct work_struct *work)
 	struct ixgbe_ring *tx_ring;
 	int some_tx_pending = 0;
 
-	adapter->flags |= IXGBE_FLAG_IN_WATCHDOG_TASK;
+	while (test_and_set_bit(__IXGBE_IN_WATCHDOG_TASK, &adapter->state))
+		msleep(1);
 
 	if (adapter->flags & IXGBE_FLAG_NEED_LINK_UPDATE) {
 		hw->mac.ops.check_link(hw, &link_speed, &link_up, false);
@@ -5102,7 +5103,7 @@ static void ixgbe_watchdog_task(struct work_struct *work)
 	}
 
 	ixgbe_update_stats(adapter);
-	adapter->flags &= ~IXGBE_FLAG_IN_WATCHDOG_TASK;
+	clear_bit(__IXGBE_IN_WATCHDOG_TASK, &adapter->state);
 }
 
 static int ixgbe_tso(struct ixgbe_adapter *adapter,

