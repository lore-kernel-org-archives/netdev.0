From: Divy Le Ray <divy@chelsio.com>
Subject: [PATCH 2.6.30 1/4] cxgb3: fix link fault handling
Date: Fri, 17 Apr 2009 15:21:11 -0700
Message-ID: <20090417222111.8472.45439.stgit@speedy5>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:7088 "EHLO
	stargate.chelsio.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756776AbZDQXDa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Apr 2009 19:03:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Divy Le Ray <divy@chelsio.com>

Use the existing periodic task to handle link faults.
The link fault interrupt handler is also called in work queue context,
which is wrong and might cause potential deadlocks.

Signed-off-by: Divy Le Ray <divy@chelsio.com>
---

 drivers/net/cxgb3/cxgb3_main.c |   22 ++--------------------
 drivers/net/cxgb3/t3_hw.c      |   11 +----------
 2 files changed, 3 insertions(+), 30 deletions(-)

diff --git a/drivers/net/cxgb3/cxgb3_main.c b/drivers/net/cxgb3/cxgb3_main.c
index ab0e5fe..9fdfe0b 100644
--- a/drivers/net/cxgb3/cxgb3_main.c
+++ b/drivers/net/cxgb3/cxgb3_main.c
@@ -2493,6 +2493,7 @@ static void check_link_status(struct adapter *adapter)
 
 		spin_lock_irq(&adapter->work_lock);
 		if (p->link_fault) {
+			t3_link_fault(adapter, i);
 			spin_unlock_irq(&adapter->work_lock);
 			continue;
 		}
@@ -2554,9 +2555,7 @@ static void t3_adap_check_task(struct work_struct *work)
 
 	adapter->check_task_cnt++;
 
-	/* Check link status for PHYs without interrupts */
-	if (p->linkpoll_period)
-		check_link_status(adapter);
+	check_link_status(adapter);
 
 	/* Accumulate MAC stats if needed */
 	if (!p->linkpoll_period ||
@@ -2680,21 +2679,6 @@ void t3_os_ext_intr_handler(struct adapter *adapter)
 	spin_unlock(&adapter->work_lock);
 }
 
-static void link_fault_task(struct work_struct *work)
-{
-	struct adapter *adapter = container_of(work, struct adapter,
-					       link_fault_handler_task);
-	int i;
-
-	for_each_port(adapter, i) {
-		struct net_device *netdev = adapter->port[i];
-		struct port_info *pi = netdev_priv(netdev);
-
-		if (pi->link_fault)
-			t3_link_fault(adapter, i);
-	}
-}
-
 void t3_os_link_fault_handler(struct adapter *adapter, int port_id)
 {
 	struct net_device *netdev = adapter->port[port_id];
@@ -2702,7 +2686,6 @@ void t3_os_link_fault_handler(struct adapter *adapter, int port_id)
 
 	spin_lock(&adapter->work_lock);
 	pi->link_fault = 1;
-	queue_work(cxgb3_wq, &adapter->link_fault_handler_task);
 	spin_unlock(&adapter->work_lock);
 }
 
@@ -3082,7 +3065,6 @@ static int __devinit init_one(struct pci_dev *pdev,
 
 	INIT_LIST_HEAD(&adapter->adapter_list);
 	INIT_WORK(&adapter->ext_intr_handler_task, ext_intr_task);
-	INIT_WORK(&adapter->link_fault_handler_task, link_fault_task);
 	INIT_WORK(&adapter->fatal_error_handler_task, fatal_error_task);
 	INIT_DELAYED_WORK(&adapter->adap_check_task, t3_adap_check_task);
 
diff --git a/drivers/net/cxgb3/t3_hw.c b/drivers/net/cxgb3/t3_hw.c
index 31ed31a..e1bd690 100644
--- a/drivers/net/cxgb3/t3_hw.c
+++ b/drivers/net/cxgb3/t3_hw.c
@@ -1202,7 +1202,6 @@ void t3_link_changed(struct adapter *adapter, int port_id)
 	struct cphy *phy = &pi->phy;
 	struct cmac *mac = &pi->mac;
 	struct link_config *lc = &pi->link_config;
-	int force_link_down = 0;
 
 	phy->ops->get_link_status(phy, &link_ok, &speed, &duplex, &fc);
 
@@ -1218,14 +1217,9 @@ void t3_link_changed(struct adapter *adapter, int port_id)
 		status = t3_read_reg(adapter, A_XGM_INT_STATUS + mac->offset);
 		if (status & F_LINKFAULTCHANGE) {
 			mac->stats.link_faults++;
-			force_link_down = 1;
+			pi->link_fault = 1;
 		}
 		t3_open_rx_traffic(mac, rx_cfg, rx_hash_high, rx_hash_low);
-
-		if (force_link_down) {
-			t3_os_link_fault_handler(adapter, port_id);
-			return;
-		}
 	}
 
 	if (lc->requested_fc & PAUSE_AUTONEG)
@@ -1292,9 +1286,6 @@ void t3_link_fault(struct adapter *adapter, int port_id)
 		/* Account link faults only when the phy reports a link up */
 		if (link_ok)
 			mac->stats.link_faults++;
-
-		msleep(1000);
-		t3_os_link_fault_handler(adapter, port_id);
 	} else {
 		if (link_ok)
 			t3_write_reg(adapter, A_XGM_XAUI_ACT_CTRL + mac->offset,

