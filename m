From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 5/8] e1000: fix possible reset_task running after adapter down
Date: Wed, 27 Nov 2013 23:35:59 -0800
Message-ID: <1385624162-10116-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1385624162-10116-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Vladimir Davydov <VDavydov@parallels.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Tushar Dave <tushar.n.dave@intel.com>,
	Patrick McHardy <kaber@trash.net>,
	Vladimir Davydov <vdavydov@parallels.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:62417 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753122Ab3K1Hge (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Nov 2013 02:36:34 -0500
In-Reply-To: <1385624162-10116-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vladimir Davydov <VDavydov@parallels.com>

On e1000_down(), we should ensure every asynchronous work is canceled
before proceeding. Since the watchdog_task can schedule other works
apart from itself, it should be stopped first, but currently it is
stopped after the reset_task. This can result in the following race
leading to the reset_task running after the module unload:

e1000_down_and_stop():			e1000_watchdog():
----------------------			-----------------

cancel_work_sync(reset_task)
					schedule_work(reset_task)
cancel_delayed_work_sync(watchdog_task)

The patch moves cancel_delayed_work_sync(watchdog_task) at the beginning
of e1000_down_and_stop() thus ensuring the race is impossible.

Cc: Tushar Dave <tushar.n.dave@intel.com>
Cc: Patrick McHardy <kaber@trash.net>
Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000/e1000_main.c | 15 +++++++++++----
 1 file changed, 11 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/net/ethernet/intel/e1000/e1000_main.c
index 619b0cb..46e6544 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_main.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
@@ -494,13 +494,20 @@ static void e1000_down_and_stop(struct e1000_adapter *adapter)
 {
 	set_bit(__E1000_DOWN, &adapter->flags);
 
-	/* Only kill reset task if adapter is not resetting */
-	if (!test_bit(__E1000_RESETTING, &adapter->flags))
-		cancel_work_sync(&adapter->reset_task);
-
 	cancel_delayed_work_sync(&adapter->watchdog_task);
+
+	/*
+	 * Since the watchdog task can reschedule other tasks, we should cancel
+	 * it first, otherwise we can run into the situation when a work is
+	 * still running after the adapter has been turned down.
+	 */
+
 	cancel_delayed_work_sync(&adapter->phy_info_task);
 	cancel_delayed_work_sync(&adapter->fifo_stall_task);
+
+	/* Only kill reset task if adapter is not resetting */
+	if (!test_bit(__E1000_RESETTING, &adapter->flags))
+		cancel_work_sync(&adapter->reset_task);
 }
 
 void e1000_down(struct e1000_adapter *adapter)
-- 
1.8.3.1
