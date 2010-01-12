From: Jesper Dangaard Brouer <hawk@comx.dk>
Subject: [net-next PATCH] igb: update adapter stats when reading /proc/net/dev.
Date: Tue, 12 Jan 2010 14:41:53 +0100
Message-ID: <20100112134153.27117.59960.stgit@firesoul.comx.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <hawk@comx.dk>, netdev@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lanfw001a.cxnet.dk ([87.72.215.196]:46574 "EHLO
	lanfw001a.cxnet.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751310Ab0ALNlz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jan 2010 08:41:55 -0500
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
index d967949..7207dd3 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -3862,11 +3862,17 @@ static void igb_reset_task(struct work_struct *work)
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
 
@@ -3940,7 +3946,7 @@ static int igb_change_mtu(struct net_device *netdev, int new_mtu)
 
 void igb_update_stats(struct igb_adapter *adapter)
 {
-	struct net_device_stats *net_stats = igb_get_stats(adapter->netdev);
+	struct net_device_stats *net_stats = &adapter->netdev->stats;
 	struct e1000_hw *hw = &adapter->hw;
 	struct pci_dev *pdev = adapter->pdev;
 	u32 rnbc;

