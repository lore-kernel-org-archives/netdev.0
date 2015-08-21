From: Taku Izumi <izumi.taku@jp.fujitsu.com>
Subject: [PATCH v3 16/22] fjes: interrupt_watch_task
Date: Fri, 21 Aug 2015 17:29:32 +0900
Message-ID: <1440145778-15941-16-git-send-email-izumi.taku@jp.fujitsu.com>
References: <1440145680-15851-1-git-send-email-izumi.taku@jp.fujitsu.com>
 <1440145778-15941-1-git-send-email-izumi.taku@jp.fujitsu.com>
Cc: platform-driver-x86@vger.kernel.org, dvhart@infradead.org,
	rkhan@redhat.com, alexander.h.duyck@redhat.com,
	linux-acpi@vger.kernel.org, joe@perches.com,
	sergei.shtylyov@cogentembedded.com, stephen@networkplumber.org,
	yasu.isimatu@gmail.com, Taku Izumi <izumi.taku@jp.fujitsu.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgwym02.jp.fujitsu.com ([211.128.242.41]:30428 "EHLO
	mgwym02.jp.fujitsu.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753505AbbHUIfQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Aug 2015 04:35:16 -0400
In-Reply-To: <1440145778-15941-1-git-send-email-izumi.taku@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds interrupt_watch_task.
This task is used to prevent delay of interrupts.

Signed-off-by: Taku Izumi <izumi.taku@jp.fujitsu.com>
---
 drivers/net/fjes/fjes.h      |  5 +++++
 drivers/net/fjes/fjes_main.c | 40 +++++++++++++++++++++++++++++++++++++++-
 2 files changed, 44 insertions(+), 1 deletion(-)

diff --git a/drivers/net/fjes/fjes.h b/drivers/net/fjes/fjes.h
index b04ea9d..1743dbb 100644
--- a/drivers/net/fjes/fjes.h
+++ b/drivers/net/fjes/fjes.h
@@ -32,6 +32,7 @@
 #define FJES_TX_RETRY_TIMEOUT	(100)
 #define FJES_TX_TX_STALL_TIMEOUT	(FJES_TX_RETRY_INTERVAL / 2)
 #define FJES_OPEN_ZONE_UPDATE_WAIT	(300) /* msec */
+#define FJES_IRQ_WATCH_DELAY	(HZ)
 
 /* board specific private data structure */
 struct fjes_adapter {
@@ -52,10 +53,14 @@ struct fjes_adapter {
 	bool irq_registered;
 
 	struct workqueue_struct *txrx_wq;
+	struct workqueue_struct *control_wq;
 
 	struct work_struct tx_stall_task;
 	struct work_struct raise_intr_rxdata_task;
 
+	struct delayed_work interrupt_watch_task;
+	bool interrupt_watch_enable;
+
 	struct fjes_hw hw;
 };
 
diff --git a/drivers/net/fjes/fjes_main.c b/drivers/net/fjes/fjes_main.c
index 4a4ce81..5fce33d 100644
--- a/drivers/net/fjes/fjes_main.c
+++ b/drivers/net/fjes/fjes_main.c
@@ -71,7 +71,7 @@ static int fjes_remove(struct platform_device *);
 
 static int fjes_sw_init(struct fjes_adapter *);
 static void fjes_netdev_setup(struct net_device *);
-
+static void fjes_irq_watch_task(struct work_struct *);
 static void fjes_rx_irq(struct fjes_adapter *, int);
 static int fjes_poll(struct napi_struct *, int);
 
@@ -197,6 +197,13 @@ static int fjes_request_irq(struct fjes_adapter *adapter)
 	struct net_device *netdev = adapter->netdev;
 	int result = -1;
 
+	adapter->interrupt_watch_enable = true;
+	if (!delayed_work_pending(&adapter->interrupt_watch_task)) {
+		queue_delayed_work(adapter->control_wq,
+				   &adapter->interrupt_watch_task,
+				   FJES_IRQ_WATCH_DELAY);
+	}
+
 	if (!adapter->irq_registered) {
 		result = request_irq(adapter->hw.hw_res.irq, fjes_intr,
 				     IRQF_SHARED, netdev->name, adapter);
@@ -213,6 +220,9 @@ static void fjes_free_irq(struct fjes_adapter *adapter)
 {
 	struct fjes_hw *hw = &adapter->hw;
 
+	adapter->interrupt_watch_enable = false;
+	cancel_delayed_work_sync(&adapter->interrupt_watch_task);
+
 	fjes_hw_set_irqmask(hw, REG_ICTL_MASK_ALL, true);
 
 	if (adapter->irq_registered) {
@@ -297,6 +307,7 @@ static int fjes_close(struct net_device *netdev)
 
 	fjes_free_irq(adapter);
 
+	cancel_delayed_work_sync(&adapter->interrupt_watch_task);
 	cancel_work_sync(&adapter->raise_intr_rxdata_task);
 	cancel_work_sync(&adapter->tx_stall_task);
 
@@ -996,11 +1007,15 @@ static int fjes_probe(struct platform_device *plat_dev)
 	adapter->open_guard = false;
 
 	adapter->txrx_wq = create_workqueue(DRV_NAME "/txrx");
+	adapter->control_wq = create_workqueue(DRV_NAME "/control");
 
 	INIT_WORK(&adapter->tx_stall_task, fjes_tx_stall_task);
 	INIT_WORK(&adapter->raise_intr_rxdata_task,
 		  fjes_raise_intr_rxdata_task);
 
+	INIT_DELAYED_WORK(&adapter->interrupt_watch_task, fjes_irq_watch_task);
+	adapter->interrupt_watch_enable = false;
+
 	res = platform_get_resource(plat_dev, IORESOURCE_MEM, 0);
 	hw->hw_res.start = res->start;
 	hw->hw_res.size = res->end - res->start + 1;
@@ -1040,8 +1055,11 @@ static int fjes_remove(struct platform_device *plat_dev)
 	struct fjes_adapter *adapter = netdev_priv(netdev);
 	struct fjes_hw *hw = &adapter->hw;
 
+	cancel_delayed_work_sync(&adapter->interrupt_watch_task);
 	cancel_work_sync(&adapter->raise_intr_rxdata_task);
 	cancel_work_sync(&adapter->tx_stall_task);
+	if (adapter->control_wq)
+		destroy_workqueue(adapter->control_wq);
 	if (adapter->txrx_wq)
 		destroy_workqueue(adapter->txrx_wq);
 
@@ -1077,6 +1095,26 @@ static void fjes_netdev_setup(struct net_device *netdev)
 	netdev->features |= NETIF_F_HW_CSUM | NETIF_F_HW_VLAN_CTAG_FILTER;
 }
 
+static void fjes_irq_watch_task(struct work_struct *work)
+{
+	struct fjes_adapter *adapter = container_of(to_delayed_work(work),
+			struct fjes_adapter, interrupt_watch_task);
+
+	local_irq_disable();
+	fjes_intr(adapter->hw.hw_res.irq, adapter);
+	local_irq_enable();
+
+	if (fjes_rxframe_search_exist(adapter, 0) >= 0)
+		napi_schedule(&adapter->napi);
+
+	if (adapter->interrupt_watch_enable) {
+		if (!delayed_work_pending(&adapter->interrupt_watch_task))
+			queue_delayed_work(adapter->control_wq,
+					   &adapter->interrupt_watch_task,
+					   FJES_IRQ_WATCH_DELAY);
+	}
+}
+
 /* fjes_init_module - Driver Registration Routine */
 static int __init fjes_init_module(void)
 {
-- 
1.8.3.1
