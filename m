From: Taku Izumi <izumi.taku@jp.fujitsu.com>
Subject: [PATCH 09/22] fjes: raise_intr_rxdata_task
Date: Thu, 18 Jun 2015 09:49:34 +0900
Message-ID: <1434588587-25655-9-git-send-email-izumi.taku@jp.fujitsu.com>
References: <1434588359-25589-1-git-send-email-izumi.taku@jp.fujitsu.com>
 <1434588587-25655-1-git-send-email-izumi.taku@jp.fujitsu.com>
Cc: rkhan@redhat.com, alexander.h.duyck@redhat.com,
	netdev@vger.kernel.org, linux-acpi@vger.kernel.org,
	Taku Izumi <izumi.taku@jp.fujitsu.com>
To: platform-driver-x86@vger.kernel.org, dvhart@infradead.org
Return-path: <platform-driver-x86-owner@vger.kernel.org>
In-Reply-To: <1434588587-25655-1-git-send-email-izumi.taku@jp.fujitsu.com>
Sender: platform-driver-x86-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch add raise_intr_rxdata_task.

Extended Socket Network Device is shared memory
based, so someone's transmission denotes other's
reception. In order to notify receivers, sender
has to raise interruption of receivers.
raise_intr_rxdata_task does this work.

Signed-off-by: Taku Izumi <izumi.taku@jp.fujitsu.com>
---
 drivers/platform/x86/fjes/fjes.h      |  4 ++
 drivers/platform/x86/fjes/fjes_main.c | 69 +++++++++++++++++++++++++++++++++++
 2 files changed, 73 insertions(+)

diff --git a/drivers/platform/x86/fjes/fjes.h b/drivers/platform/x86/fjes/fjes.h
index d8901aa..89b95c8 100644
--- a/drivers/platform/x86/fjes/fjes.h
+++ b/drivers/platform/x86/fjes/fjes.h
@@ -52,6 +52,10 @@ struct fjes_adapter {
 
 	bool irq_registered;
 
+	struct workqueue_struct *txrx_wq;
+
+	struct work_struct raise_intr_rxdata_task;
+
 	struct fjes_hw hw;
 };
 
diff --git a/drivers/platform/x86/fjes/fjes_main.c b/drivers/platform/x86/fjes/fjes_main.c
index 0d4bca6..4d012f4 100644
--- a/drivers/platform/x86/fjes/fjes_main.c
+++ b/drivers/platform/x86/fjes/fjes_main.c
@@ -54,6 +54,7 @@ static int fjes_setup_resources(struct fjes_adapter *);
 static void fjes_free_resources(struct fjes_adapter *);
 static netdev_tx_t fjes_xmit_frame(struct sk_buff *,
 		struct net_device *);
+static void fjes_raise_intr_rxdata_task(struct work_struct *);
 static irqreturn_t fjes_intr(int, void*);
 
 static int fjes_acpi_add(struct acpi_device *);
@@ -285,6 +286,8 @@ static int fjes_close(struct net_device *netdev)
 
 	fjes_free_irq(adapter);
 
+	cancel_work_sync(&adapter->raise_intr_rxdata_task);
+
 	fjes_hw_wait_epstop(hw);
 
 	fjes_free_resources(adapter);
@@ -419,6 +422,60 @@ static void fjes_free_resources(struct fjes_adapter *adapter)
 
 }
 
+static void fjes_raise_intr_rxdata_task(struct work_struct *work)
+{
+	struct fjes_adapter *adapter = container_of(work,
+			struct fjes_adapter, raise_intr_rxdata_task);
+	struct fjes_hw *hw = &adapter->hw;
+	int epid;
+	int max_epid, my_epid;
+	enum ep_partner_status pstatus;
+
+	my_epid = hw->my_epid;
+	max_epid = hw->max_epid;
+
+	for (epid = 0; epid < max_epid; epid++)
+		hw->ep_shm_info[epid].tx_status_work = 0;
+
+	for (epid = 0; epid < max_epid; epid++) {
+		if (epid == my_epid)
+			continue;
+
+		pstatus = fjes_hw_get_partner_ep_status(hw, epid);
+		if (pstatus == EP_PARTNER_SHARED) {
+
+			hw->ep_shm_info[epid].tx_status_work =
+				hw->ep_shm_info[epid].tx.info->v1i.tx_status;
+
+			if (hw->ep_shm_info[epid].tx_status_work ==
+				FJES_TX_DELAY_SEND_PENDING) {
+				hw->ep_shm_info[epid].tx.info->v1i.tx_status =
+					FJES_TX_DELAY_SEND_NONE;
+			}
+		}
+
+	}
+
+	for (epid = 0; epid < max_epid; epid++) {
+		if (epid == my_epid)
+			continue;
+
+		pstatus = fjes_hw_get_partner_ep_status(hw, epid);
+		if ((hw->ep_shm_info[epid].tx_status_work ==
+				FJES_TX_DELAY_SEND_PENDING) &&
+			(pstatus == EP_PARTNER_SHARED) &&
+			!(hw->ep_shm_info[epid].rx.info->v1i.rx_status)) {
+
+			fjes_hw_raise_interrupt(hw, epid, REG_ICTL_MASK_RX_DATA);
+
+		}
+
+	}
+
+	usleep_range(500, 1000);
+
+}
+
 static int fjes_tx_send(struct fjes_adapter *adapter, int dest,
 				void *data, size_t len)
 {
@@ -431,6 +488,9 @@ static int fjes_tx_send(struct fjes_adapter *adapter, int dest,
 
 	adapter->hw.ep_shm_info[dest].tx.info->v1i.tx_status =
 		FJES_TX_DELAY_SEND_PENDING;
+	if (!work_pending(&adapter->raise_intr_rxdata_task))
+		queue_work(adapter->txrx_wq,
+				   &adapter->raise_intr_rxdata_task);
 
 	retval = 0;
 	return retval;
@@ -660,6 +720,11 @@ static int fjes_probe(struct platform_device *plat_dev)
 	adapter->force_reset = false;
 	adapter->open_guard = false;
 
+	adapter->txrx_wq = create_workqueue(DRV_NAME"/txrx");
+
+	INIT_WORK(&adapter->raise_intr_rxdata_task,
+			fjes_raise_intr_rxdata_task);
+
 	res = platform_get_resource(plat_dev, IORESOURCE_MEM, 0);
 	hw->hw_res.start = res->start;
 	hw->hw_res.size = res->end - res->start;
@@ -702,6 +767,10 @@ static int fjes_remove(struct platform_device *plat_dev)
 	struct fjes_adapter *adapter = netdev_priv(netdev);
 	struct fjes_hw *hw = &adapter->hw;
 
+	cancel_work_sync(&adapter->raise_intr_rxdata_task);
+	if (adapter->txrx_wq)
+		destroy_workqueue(adapter->txrx_wq);
+
 	unregister_netdev(netdev);
 
 	fjes_hw_exit(hw);
-- 
1.8.3.1
