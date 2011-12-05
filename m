From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 2/6] e1000e: hitting BUG_ON() from napi_enable
Date: Mon,  5 Dec 2011 00:20:37 -0800
Message-ID: <1323073241-21144-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1323073241-21144-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Mike McElroy <mike.mcelroy@stratus.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:55396 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752299Ab1LEIUq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Dec 2011 03:20:46 -0500
In-Reply-To: <1323073241-21144-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Based on a patch from Mike McElroy created against the out-of-tree e1000e
driver:

Hitting the BUG_ON in napi_enable(). Code inspection shows that this can
only be triggered by calling napi_enable() twice without an intervening
napi_disable().

I saw the following sequence of events in the stack trace:

1) We simulated a cable pull using an Extreme switch.
2) e1000_tx_timeout() was entered.
3) e1000_reset_task() was called. Saw the message from e_err() in the
console log.
4) e1000_reinit_locked was called. This function calls e1000_down() and
e1000_up(). These functions call napi_disable() and napi_enable()
respectively.
5) Then on another thread, a monitor task saw carrier was down and executed
'ip set link down' and 'ip set link up' commands.
6) Saw the '_E1000_RESETTING'warning fron the e1000_close function.
7) Either the e1000_open() executed between the e1000_down() and e1000_up()
calls in step 4 or the e1000_open() call executed after the e1000_up()
call.  In either case, napi_enable() is called twice which triggers the
BUG_ON.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Cc: Mike McElroy <mike.mcelroy@stratus.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/netdev.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index c12df69..93ae0c2 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -3516,7 +3516,6 @@ int e1000e_up(struct e1000_adapter *adapter)
 
 	clear_bit(__E1000_DOWN, &adapter->state);
 
-	napi_enable(&adapter->napi);
 	if (adapter->msix_entries)
 		e1000_configure_msix(adapter);
 	e1000_irq_enable(adapter);
@@ -3578,7 +3577,6 @@ void e1000e_down(struct e1000_adapter *adapter)
 	e1e_flush();
 	usleep_range(10000, 20000);
 
-	napi_disable(&adapter->napi);
 	e1000_irq_disable(adapter);
 
 	del_timer_sync(&adapter->watchdog_timer);
@@ -3901,6 +3899,8 @@ static int e1000_close(struct net_device *netdev)
 
 	pm_runtime_get_sync(&pdev->dev);
 
+	napi_disable(&adapter->napi);
+
 	if (!test_bit(__E1000_DOWN, &adapter->state)) {
 		e1000e_down(adapter);
 		e1000_free_irq(adapter);
-- 
1.7.6.4
