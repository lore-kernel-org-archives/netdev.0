From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH 2/2] e1000: fix possible reset_task running after adapter down
Date: Fri, 22 Nov 2013 12:20:29 +0400
Message-ID: <a0339f72560eeee5cad54c9363a5b5f196b83933.1385107870.git.vdavydov@parallels.com>
References: <0555e8c422c9d920758399edfa08f72df9120713.1385107870.git.vdavydov@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <e1000-devel@lists.sourceforge.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <devel@openvz.org>,
	Tushar Dave <tushar.n.dave@intel.com>,
	Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>
To: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <0555e8c422c9d920758399edfa08f72df9120713.1385107870.git.vdavydov@parallels.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
Cc: Tushar Dave <tushar.n.dave@intel.com>
Cc: Patrick McHardy <kaber@trash.net>
Cc: David S. Miller <davem@davemloft.net>
---
 drivers/net/ethernet/intel/e1000/e1000_main.c |   15 +++++++++++----
 1 file changed, 11 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/net/ethernet/intel/e1000/e1000_main.c
index ca0723f..2d914de 100644
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
1.7.10.4
