From: Jesper Dangaard Brouer <hawk@comx.dk>
Subject: [net-next PATCH] igb: update adapter stats when reading /proc/net/dev.
Date: Tue, 05 Oct 2010 16:18:33 +0200
Message-ID: <20101005141833.20929.10943.stgit@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from albpd42.cxnet.dk ([87.72.130.6]:46116 "EHLO albpd42.cxnet.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753553Ab0JEOYv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Oct 2010 10:24:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Network driver igb: Improve the accuracy of stats in /proc/net/dev, by
updating the adapter stats when reading /proc/net/dev.  Currently the
stats are updated by the watchdog timer every 2 sec, or when getting
stats via ethtool -S.

A number of userspace apps read these /proc/net/dev stats every second,
e.g. ifstat, which then gives a perceived very bursty traffic pattern,
which is actually false.

Signed-off-by: Jesper Dangaard Brouer <hawk@comx.dk>
---
 drivers/net/igb/igb_main.c |   12 +++++++++---
 1 files changed, 9 insertions(+), 3 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 55edcb7..6cec297 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -4218,11 +4218,17 @@ static void igb_reset_task(struct work_struct *work)
  * @netdev: network interface device structure
  *
  * Returns the address of the device statistics structure.
- * The statistics are actually updated from the timer callback.
+ * The statistics are also updated from the timer callback
+ * igb_watchdog_task().
  **/
 static struct net_device_stats *igb_get_stats(struct net_device *netdev)
 {
-	/* only return the current stats */
+	struct igb_adapter *adapter = netdev_priv(netdev);
+
+	/* update stats */
+	igb_update_stats(adapter);
+
+	/* return the current stats */
 	return &netdev->stats;
 }
 
@@ -4307,7 +4313,7 @@ static int igb_change_mtu(struct net_device *netdev, int new_mtu)
 
 void igb_update_stats(struct igb_adapter *adapter)
 {
-	struct net_device_stats *net_stats = igb_get_stats(adapter->netdev);
+	struct net_device_stats *net_stats = &adapter->netdev->stats;
 	struct e1000_hw *hw = &adapter->hw;
 	struct pci_dev *pdev = adapter->pdev;
 	u32 reg, mpc;

