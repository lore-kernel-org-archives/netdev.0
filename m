From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 6/9] igb[v],ixgbe: don't use flush_scheduled_work()
Date: Sun, 12 Dec 2010 16:53:02 +0100
Message-ID: <1292169185-10579-7-git-send-email-tj@kernel.org>
References: <1292169185-10579-1-git-send-email-tj@kernel.org>
Cc: Tejun Heo <tj@kernel.org>, e1000-devel@lists.sourceforge.net
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from hera.kernel.org ([140.211.167.34]:56563 "EHLO hera.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753343Ab0LLPx1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 12 Dec 2010 10:53:27 -0500
In-Reply-To: <1292169185-10579-1-git-send-email-tj@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

All three drivers use flush_scheduled_work() similarly during driver
detach.  Replace it with explicit cancels.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: e1000-devel@lists.sourceforge.net
Cc: netdev@vger.kernel.org
---
 drivers/net/igb/igb_main.c     |    9 ++++++---
 drivers/net/igbvf/netdev.c     |    7 ++++---
 drivers/net/ixgbe/ixgbe_main.c |   11 +++++++----
 3 files changed, 17 insertions(+), 10 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 041f8e6..62348fc 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -2050,13 +2050,16 @@ static void __devexit igb_remove(struct pci_dev *pdev)
 	struct igb_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
 
-	/* flush_scheduled work may reschedule our watchdog task, so
-	 * explicitly disable watchdog tasks from being rescheduled  */
+	/*
+	 * The watchdog timer may be rescheduled, so explicitly
+	 * disable watchdog from being rescheduled.
+	 */
 	set_bit(__IGB_DOWN, &adapter->state);
 	del_timer_sync(&adapter->watchdog_timer);
 	del_timer_sync(&adapter->phy_info_timer);
 
-	flush_scheduled_work();
+	cancel_work_sync(&adapter->reset_task);
+	cancel_work_sync(&adapter->watchdog_task);
 
 #ifdef CONFIG_IGB_DCA
 	if (adapter->flags & IGB_FLAG_DCA_ENABLED) {
diff --git a/drivers/net/igbvf/netdev.c b/drivers/net/igbvf/netdev.c
index 8dbde23..4fb023b 100644
--- a/drivers/net/igbvf/netdev.c
+++ b/drivers/net/igbvf/netdev.c
@@ -2825,13 +2825,14 @@ static void __devexit igbvf_remove(struct pci_dev *pdev)
 	struct e1000_hw *hw = &adapter->hw;
 
 	/*
-	 * flush_scheduled work may reschedule our watchdog task, so
-	 * explicitly disable watchdog tasks from being rescheduled
+	 * The watchdog timer may be rescheduled, so explicitly
+	 * disable it from being rescheduled.
 	 */
 	set_bit(__IGBVF_DOWN, &adapter->state);
 	del_timer_sync(&adapter->watchdog_timer);
 
-	flush_scheduled_work();
+	cancel_work_sync(&adapter->reset_task);
+	cancel_work_sync(&adapter->watchdog_task);
 
 	unregister_netdev(netdev);
 
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 8af0fc0..ca9036d 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -7373,13 +7373,15 @@ static void __devexit ixgbe_remove(struct pci_dev *pdev)
 	struct net_device *netdev = adapter->netdev;
 
 	set_bit(__IXGBE_DOWN, &adapter->state);
-	/* clear the module not found bit to make sure the worker won't
-	 * reschedule
+
+	/*
+	 * The timers may be rescheduled, so explicitly disable them
+	 * from being rescheduled.
 	 */
 	clear_bit(__IXGBE_SFP_MODULE_NOT_FOUND, &adapter->state);
 	del_timer_sync(&adapter->watchdog_timer);
-
 	del_timer_sync(&adapter->sfp_timer);
+
 	cancel_work_sync(&adapter->watchdog_task);
 	cancel_work_sync(&adapter->sfp_task);
 	cancel_work_sync(&adapter->multispeed_fiber_task);
@@ -7387,7 +7389,8 @@ static void __devexit ixgbe_remove(struct pci_dev *pdev)
 	if (adapter->flags & IXGBE_FLAG_FDIR_HASH_CAPABLE ||
 	    adapter->flags & IXGBE_FLAG_FDIR_PERFECT_CAPABLE)
 		cancel_work_sync(&adapter->fdir_reinit_task);
-	flush_scheduled_work();
+	if (adapter->flags2 & IXGBE_FLAG2_TEMP_SENSOR_CAPABLE)
+		cancel_work_sync(&adapter->check_overtemp_task);
 
 #ifdef CONFIG_IXGBE_DCA
 	if (adapter->flags & IXGBE_FLAG_DCA_ENABLED) {
-- 
1.7.1

