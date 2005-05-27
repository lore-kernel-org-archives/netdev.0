From: "John W. Linville" <linville@tuxdriver.com>
Subject: [patch linux-2.6.12-rc5 1/1] e1000: revert watchdog task
Date: Fri, 27 May 2005 16:26:18 -0400
Message-ID: <20050527202617.GA22786@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, ganesh.venkatesan@intel.com, john.ronciak@intel.com,
        cramerj@intel.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Undo the previous addition of the e1000_watchdog_task workqueue.

Signed-off-by: John W. Linville <linville@tuxdriver.com>
---
After some discussion w/ the e1000 maintainers, we came to the
conclusion that the e1000_watchdog_task was at best unnecessary and
at worst caused more problems than it might solve.

This patch reverst the patch which created that workqueue (posted
3/14/2005).

 drivers/net/e1000/e1000.h      |    1 -
 drivers/net/e1000/e1000_main.c |   15 ++-------------
 2 files changed, 2 insertions(+), 14 deletions(-)

--- linux-2.6.12-rc5/drivers/net/e1000/e1000.h.orig	2005-05-27 16:15:47.478498035 -0400
+++ linux-2.6.12-rc5/drivers/net/e1000/e1000.h	2005-05-27 16:15:55.004463809 -0400
@@ -220,7 +220,6 @@ struct e1000_adapter {
 	spinlock_t stats_lock;
 	atomic_t irq_sem;
 	struct work_struct tx_timeout_task;
-	struct work_struct watchdog_task;
 	uint8_t fc_autoneg;
 
 	struct timer_list blink_timer;
--- linux-2.6.12-rc5/drivers/net/e1000/e1000_main.c.orig	2005-05-27 16:15:47.480497760 -0400
+++ linux-2.6.12-rc5/drivers/net/e1000/e1000_main.c	2005-05-27 16:15:55.006463534 -0400
@@ -123,7 +123,6 @@ static void e1000_clean_rx_ring(struct e
 static void e1000_set_multi(struct net_device *netdev);
 static void e1000_update_phy_info(unsigned long data);
 static void e1000_watchdog(unsigned long data);
-static void e1000_watchdog_task(struct e1000_adapter *adapter);
 static void e1000_82547_tx_fifo_stall(unsigned long data);
 static int e1000_xmit_frame(struct sk_buff *skb, struct net_device *netdev);
 static struct net_device_stats * e1000_get_stats(struct net_device *netdev);
@@ -641,9 +640,6 @@ e1000_probe(struct pci_dev *pdev,
 	adapter->watchdog_timer.function = &e1000_watchdog;
 	adapter->watchdog_timer.data = (unsigned long) adapter;
 
-	INIT_WORK(&adapter->watchdog_task,
-		(void (*)(void *))e1000_watchdog_task, adapter);
-
 	init_timer(&adapter->phy_info_timer);
 	adapter->phy_info_timer.function = &e1000_update_phy_info;
 	adapter->phy_info_timer.data = (unsigned long) adapter;
@@ -1752,20 +1748,13 @@ e1000_82547_tx_fifo_stall(unsigned long 
 
 /**
  * e1000_watchdog - Timer Call-back
- * @data: pointer to adapter cast into an unsigned long
+ * @data: pointer to netdev cast into an unsigned long
  **/
+
 static void
 e1000_watchdog(unsigned long data)
 {
 	struct e1000_adapter *adapter = (struct e1000_adapter *) data;
-
-	/* Do the rest outside of interrupt context */
-	schedule_work(&adapter->watchdog_task);
-}
-
-static void
-e1000_watchdog_task(struct e1000_adapter *adapter)
-{
 	struct net_device *netdev = adapter->netdev;
 	struct e1000_desc_ring *txdr = &adapter->tx_ring;
 	uint32_t link;
-- 
John W. Linville
linville@tuxdriver.com
