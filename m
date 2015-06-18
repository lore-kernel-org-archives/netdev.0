From: Taku Izumi <izumi.taku@jp.fujitsu.com>
Subject: [PATCH 10/22] fjes: tx_stall_task
Date: Thu, 18 Jun 2015 09:49:35 +0900
Message-ID: <1434588587-25655-10-git-send-email-izumi.taku@jp.fujitsu.com>
References: <1434588359-25589-1-git-send-email-izumi.taku@jp.fujitsu.com>
 <1434588587-25655-1-git-send-email-izumi.taku@jp.fujitsu.com>
Cc: rkhan@redhat.com, alexander.h.duyck@redhat.com,
	netdev@vger.kernel.org, linux-acpi@vger.kernel.org,
	Taku Izumi <izumi.taku@jp.fujitsu.com>
To: platform-driver-x86@vger.kernel.org, dvhart@infradead.org
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <1434588587-25655-1-git-send-email-izumi.taku@jp.fujitsu.com>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds tx_stall_task.
When receiver's buffer is full, sender stops
its tx queue. This task is used to monitor
receiver's status and when receiver's buffer
is avairable, it resumes tx queue.

Signed-off-by: Taku Izumi <izumi.taku@jp.fujitsu.com>
---
 drivers/platform/x86/fjes/fjes.h      |  2 ++
 drivers/platform/x86/fjes/fjes_main.c | 62 +++++++++++++++++++++++++++++++++++
 2 files changed, 64 insertions(+)

diff --git a/drivers/platform/x86/fjes/fjes.h b/drivers/platform/x86/fjes/fjes.h
index 89b95c8..1ca282c 100644
--- a/drivers/platform/x86/fjes/fjes.h
+++ b/drivers/platform/x86/fjes/fjes.h
@@ -31,6 +31,7 @@
 #define FJES_MAX_QUEUES		1
 #define FJES_TX_RETRY_INTERVAL	(20 * HZ)
 #define FJES_TX_RETRY_TIMEOUT	(100)
+#define FJES_TX_TX_STALL_TIMEOUT	(FJES_TX_RETRY_INTERVAL/2)
 #define FJES_OPEN_ZONE_UPDATE_WAIT	(300) /* msec */
 
 /* board specific private data structure */
@@ -54,6 +55,7 @@ struct fjes_adapter {
 
 	struct workqueue_struct *txrx_wq;
 
+	struct work_struct tx_stall_task;
 	struct work_struct raise_intr_rxdata_task;
 
 	struct fjes_hw hw;
diff --git a/drivers/platform/x86/fjes/fjes_main.c b/drivers/platform/x86/fjes/fjes_main.c
index 4d012f4..a2dddb2 100644
--- a/drivers/platform/x86/fjes/fjes_main.c
+++ b/drivers/platform/x86/fjes/fjes_main.c
@@ -55,6 +55,7 @@ static void fjes_free_resources(struct fjes_adapter *);
 static netdev_tx_t fjes_xmit_frame(struct sk_buff *,
 		struct net_device *);
 static void fjes_raise_intr_rxdata_task(struct work_struct *);
+static void fjes_tx_stall_task(struct work_struct *);
 static irqreturn_t fjes_intr(int, void*);
 
 static int fjes_acpi_add(struct acpi_device *);
@@ -287,6 +288,7 @@ static int fjes_close(struct net_device *netdev)
 	fjes_free_irq(adapter);
 
 	cancel_work_sync(&adapter->raise_intr_rxdata_task);
+	cancel_work_sync(&adapter->tx_stall_task);
 
 	fjes_hw_wait_epstop(hw);
 
@@ -422,6 +424,62 @@ static void fjes_free_resources(struct fjes_adapter *adapter)
 
 }
 
+static void fjes_tx_stall_task(struct work_struct *work)
+{
+	struct fjes_adapter *adapter = container_of(work,
+			struct fjes_adapter, tx_stall_task);
+	struct fjes_hw *hw = &adapter->hw;
+	struct net_device *netdev = adapter->netdev;
+	enum ep_partner_status pstatus;
+	int epid;
+	int max_epid, my_epid;
+	union ep_buffer_info *info;
+	int all_queue_available;
+	int i;
+	int sendable;
+
+	if (((long)jiffies -
+		(long)(netdev->trans_start)) > FJES_TX_TX_STALL_TIMEOUT) {
+		netif_wake_queue(netdev);
+		return;
+	}
+
+	my_epid = hw->my_epid;
+	max_epid = hw->max_epid;
+
+	for (i = 0; i < 5; i++) {
+		all_queue_available = 1;
+
+		for (epid = 0; epid < max_epid; epid++) {
+
+			if (my_epid == epid)
+				continue;
+
+			pstatus = fjes_hw_get_partner_ep_status(hw, epid);
+			sendable = (pstatus == EP_PARTNER_SHARED);
+			if (!sendable)
+				continue;
+
+			info = adapter->hw.ep_shm_info[epid].tx.info;
+
+			if (EP_RING_FULL(info->v1i.head, info->v1i.tail,
+				info->v1i.count_max)) {
+				all_queue_available = 0;
+				break;
+			}
+		}
+
+		if (all_queue_available) {
+			netif_wake_queue(netdev);
+			return;
+		}
+	}
+
+	usleep_range(50, 100);
+
+	queue_work(adapter->txrx_wq, &adapter->tx_stall_task);
+}
+
 static void fjes_raise_intr_rxdata_task(struct work_struct *work)
 {
 	struct fjes_adapter *adapter = container_of(work,
@@ -633,6 +691,8 @@ static netdev_tx_t fjes_xmit_frame(struct sk_buff *skb,
 
 					netdev->trans_start = jiffies;
 					netif_tx_stop_queue(cur_queue);
+					if (!work_pending(&adapter->tx_stall_task))
+						queue_work(adapter->txrx_wq, &adapter->tx_stall_task);
 
 					ret = NETDEV_TX_BUSY;
 				}
@@ -722,6 +782,7 @@ static int fjes_probe(struct platform_device *plat_dev)
 
 	adapter->txrx_wq = create_workqueue(DRV_NAME"/txrx");
 
+	INIT_WORK(&adapter->tx_stall_task, fjes_tx_stall_task);
 	INIT_WORK(&adapter->raise_intr_rxdata_task,
 			fjes_raise_intr_rxdata_task);
 
@@ -768,6 +829,7 @@ static int fjes_remove(struct platform_device *plat_dev)
 	struct fjes_hw *hw = &adapter->hw;
 
 	cancel_work_sync(&adapter->raise_intr_rxdata_task);
+	cancel_work_sync(&adapter->tx_stall_task);
 	if (adapter->txrx_wq)
 		destroy_workqueue(adapter->txrx_wq);
 
-- 
1.8.3.1

