From: Aaron Brown <aaron.f.brown@intel.com>
Subject: [net-next 2/7] ixgbe: Indicate removal state explicitly
Date: Tue,  7 Jan 2014 23:40:42 -0800
Message-ID: <1389166847-3780-3-git-send-email-aaron.f.brown@intel.com>
References: <1389166847-3780-1-git-send-email-aaron.f.brown@intel.com>
Cc: Mark Rustad <mark.d.rustad@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Aaron Brown <aaron.f.brown@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:15337 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754956AbaAHHkM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Jan 2014 02:40:12 -0500
In-Reply-To: <1389166847-3780-1-git-send-email-aaron.f.brown@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Rustad <mark.d.rustad@intel.com>

Add a bit, __IXGBE_REMOVE, to indicate that the module is being
removed. The __IXGBE_DOWN bit had been overloaded for this purpose,
but that leads to trouble. A few places now check both __IXGBE_DOWN
and __IXGBE_REMOVE. Notably, setting either bit will prevent service
task execution.

Signed-off-by: Mark Rustad <mark.d.rustad@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Aaron Brown <aaron.f.brown@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe.h      |  1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 12 ++++++++----
 2 files changed, 9 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index 49531cd..8da263a 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -798,6 +798,7 @@ enum ixgbe_state_t {
 	__IXGBE_TESTING,
 	__IXGBE_RESETTING,
 	__IXGBE_DOWN,
+	__IXGBE_REMOVE,
 	__IXGBE_SERVICE_SCHED,
 	__IXGBE_IN_SFP_INIT,
 	__IXGBE_PTP_RUNNING,
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 90a0b4a..923b0fa 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -278,6 +278,7 @@ static void ixgbe_check_minimum_link(struct ixgbe_adapter *adapter,
 static void ixgbe_service_event_schedule(struct ixgbe_adapter *adapter)
 {
 	if (!test_bit(__IXGBE_DOWN, &adapter->state) &&
+	    !test_bit(__IXGBE_REMOVE, &adapter->state) &&
 	    !test_and_set_bit(__IXGBE_SERVICE_SCHED, &adapter->state))
 		schedule_work(&adapter->service_task);
 }
@@ -5876,8 +5877,9 @@ static void ixgbe_check_hang_subtask(struct ixgbe_adapter *adapter)
 	u64 eics = 0;
 	int i;
 
-	/* If we're down or resetting, just bail */
+	/* If we're down, removing or resetting, just bail */
 	if (test_bit(__IXGBE_DOWN, &adapter->state) ||
+	    test_bit(__IXGBE_REMOVE, &adapter->state) ||
 	    test_bit(__IXGBE_RESETTING, &adapter->state))
 		return;
 
@@ -6124,8 +6126,9 @@ static void ixgbe_spoof_check(struct ixgbe_adapter *adapter)
  **/
 static void ixgbe_watchdog_subtask(struct ixgbe_adapter *adapter)
 {
-	/* if interface is down do nothing */
+	/* if interface is down, removing or resetting, do nothing */
 	if (test_bit(__IXGBE_DOWN, &adapter->state) ||
+	    test_bit(__IXGBE_REMOVE, &adapter->state) ||
 	    test_bit(__IXGBE_RESETTING, &adapter->state))
 		return;
 
@@ -6343,8 +6346,9 @@ static void ixgbe_reset_subtask(struct ixgbe_adapter *adapter)
 
 	adapter->flags2 &= ~IXGBE_FLAG2_RESET_REQUESTED;
 
-	/* If we're already down or resetting, just bail */
+	/* If we're already down, removing or resetting, just bail */
 	if (test_bit(__IXGBE_DOWN, &adapter->state) ||
+	    test_bit(__IXGBE_REMOVE, &adapter->state) ||
 	    test_bit(__IXGBE_RESETTING, &adapter->state))
 		return;
 
@@ -8219,7 +8223,7 @@ static void ixgbe_remove(struct pci_dev *pdev)
 
 	ixgbe_dbg_adapter_exit(adapter);
 
-	set_bit(__IXGBE_DOWN, &adapter->state);
+	set_bit(__IXGBE_REMOVE, &adapter->state);
 	cancel_work_sync(&adapter->service_task);
 
 
-- 
1.8.5.GIT
