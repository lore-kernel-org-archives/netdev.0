From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH v2] ixgbe: only process one ixgbe_watchdog_task
	at a time.
Date: Wed, 03 Feb 2010 16:23:32 -0800
Message-ID: <20100204002331.15847.40084.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	John Fastabend <john.r.fastabend@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta13.westchester.pa.mail.comcast.net ([76.96.59.243]:37440
	"EHLO qmta13.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932096Ab0BDAX4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2010 19:23:56 -0500
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

This patch adds a mutex to the watchdog task. This bug is
actualized by changing DCB settings or doing extended
cable pull or reset tests.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe.h      |   17 ++++++++---------
 drivers/net/ixgbe/ixgbe_main.c |   13 +++++++++----
 2 files changed, 17 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/ixgbe/ixgbe.h
index a1f1115..bffbe0d 100644
--- a/drivers/net/ixgbe/ixgbe.h
+++ b/drivers/net/ixgbe/ixgbe.h
@@ -342,15 +342,14 @@ struct ixgbe_adapter {
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
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 5914b9b..267fbdd 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -5043,6 +5043,8 @@ static void ixgbe_fdir_reinit_task(struct work_struct *work)
 	netif_tx_start_all_queues(adapter->netdev);
 }
 
+static DEFINE_MUTEX(ixgbe_watchdog_lock);
+
 /**
  * ixgbe_watchdog_task - worker thread to bring link up
  * @work: pointer to work_struct containing our data
@@ -5054,13 +5056,16 @@ static void ixgbe_watchdog_task(struct work_struct *work)
 	                                             watchdog_task);
 	struct net_device *netdev = adapter->netdev;
 	struct ixgbe_hw *hw = &adapter->hw;
-	u32 link_speed = adapter->link_speed;
-	bool link_up = adapter->link_up;
+	u32 link_speed;
+	bool link_up;
 	int i;
 	struct ixgbe_ring *tx_ring;
 	int some_tx_pending = 0;
 
-	adapter->flags |= IXGBE_FLAG_IN_WATCHDOG_TASK;
+	mutex_lock(&ixgbe_watchdog_lock);
+
+	link_up = adapter->link_up;
+	link_speed = adapter->link_speed;
 
 	if (adapter->flags & IXGBE_FLAG_NEED_LINK_UPDATE) {
 		hw->mac.ops.check_link(hw, &link_speed, &link_up, false);
@@ -5149,7 +5154,7 @@ static void ixgbe_watchdog_task(struct work_struct *work)
 	}
 
 	ixgbe_update_stats(adapter);
-	adapter->flags &= ~IXGBE_FLAG_IN_WATCHDOG_TASK;
+	mutex_unlock(&ixgbe_watchdog_lock);
 }
 
 static int ixgbe_tso(struct ixgbe_adapter *adapter,

