From: Taku Izumi <izumi.taku@jp.fujitsu.com>
Subject: [PATCH v3 09/22] fjes: raise_intr_rxdata_task
Date: Fri, 21 Aug 2015 17:29:25 +0900
Message-ID: <1440145778-15941-9-git-send-email-izumi.taku@jp.fujitsu.com>
References: <1440145680-15851-1-git-send-email-izumi.taku@jp.fujitsu.com>
 <1440145778-15941-1-git-send-email-izumi.taku@jp.fujitsu.com>
Cc: platform-driver-x86@vger.kernel.org, dvhart@infradead.org,
	rkhan@redhat.com, alexander.h.duyck@redhat.com,
	linux-acpi@vger.kernel.org, joe@perches.com,
	sergei.shtylyov@cogentembedded.com, stephen@networkplumber.org,
	yasu.isimatu@gmail.com, Taku Izumi <izumi.taku@jp.fujitsu.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgwkm03.jp.fujitsu.com ([202.219.69.170]:35513 "EHLO
	mgwkm03.jp.fujitsu.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752034AbbHUIfA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Aug 2015 04:35:00 -0400
In-Reply-To: <1440145778-15941-1-git-send-email-izumi.taku@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch add raise_intr_rxdata_task.
Extended Socket Network Device is shared memory
based, so someone's transmission denotes other's
reception. In order to notify receivers, sender
has to raise interruption of receivers.
raise_intr_rxdata_task does this work.

Signed-off-by: Taku Izumi <izumi.taku@jp.fujitsu.com>
---
 drivers/net/fjes/fjes.h      |  4 +++
 drivers/net/fjes/fjes_main.c | 63 ++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 67 insertions(+)

diff --git a/drivers/net/fjes/fjes.h b/drivers/net/fjes/fjes.h
index 7af4304..8e9899e 100644
--- a/drivers/net/fjes/fjes.h
+++ b/drivers/net/fjes/fjes.h
@@ -50,6 +50,10 @@ struct fjes_adapter {
 
 	bool irq_registered;
 
+	struct workqueue_struct *txrx_wq;
+
+	struct work_struct raise_intr_rxdata_task;
+
 	struct fjes_hw hw;
 };
 
diff --git a/drivers/net/fjes/fjes_main.c b/drivers/net/fjes/fjes_main.c
index 220ff3d..80e180f 100644
--- a/drivers/net/fjes/fjes_main.c
+++ b/drivers/net/fjes/fjes_main.c
@@ -52,6 +52,7 @@ static int fjes_close(struct net_device *);
 static int fjes_setup_resources(struct fjes_adapter *);
 static void fjes_free_resources(struct fjes_adapter *);
 static netdev_tx_t fjes_xmit_frame(struct sk_buff *, struct net_device *);
+static void fjes_raise_intr_rxdata_task(struct work_struct *);
 static irqreturn_t fjes_intr(int, void*);
 
 static int fjes_acpi_add(struct acpi_device *);
@@ -276,6 +277,8 @@ static int fjes_close(struct net_device *netdev)
 
 	fjes_free_irq(adapter);
 
+	cancel_work_sync(&adapter->raise_intr_rxdata_task);
+
 	fjes_hw_wait_epstop(hw);
 
 	fjes_free_resources(adapter);
@@ -404,6 +407,54 @@ static void fjes_free_resources(struct fjes_adapter *adapter)
 	}
 }
 
+static void fjes_raise_intr_rxdata_task(struct work_struct *work)
+{
+	struct fjes_adapter *adapter = container_of(work,
+			struct fjes_adapter, raise_intr_rxdata_task);
+	struct fjes_hw *hw = &adapter->hw;
+	enum ep_partner_status pstatus;
+	int max_epid, my_epid, epid;
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
+			hw->ep_shm_info[epid].tx_status_work =
+				hw->ep_shm_info[epid].tx.info->v1i.tx_status;
+
+			if (hw->ep_shm_info[epid].tx_status_work ==
+				FJES_TX_DELAY_SEND_PENDING) {
+				hw->ep_shm_info[epid].tx.info->v1i.tx_status =
+					FJES_TX_DELAY_SEND_NONE;
+			}
+		}
+	}
+
+	for (epid = 0; epid < max_epid; epid++) {
+		if (epid == my_epid)
+			continue;
+
+		pstatus = fjes_hw_get_partner_ep_status(hw, epid);
+		if ((hw->ep_shm_info[epid].tx_status_work ==
+		     FJES_TX_DELAY_SEND_PENDING) &&
+		    (pstatus == EP_PARTNER_SHARED) &&
+		    !(hw->ep_shm_info[epid].rx.info->v1i.rx_status)) {
+			fjes_hw_raise_interrupt(hw, epid,
+						REG_ICTL_MASK_RX_DATA);
+		}
+	}
+
+	usleep_range(500, 1000);
+}
+
 static int fjes_tx_send(struct fjes_adapter *adapter, int dest,
 			void *data, size_t len)
 {
@@ -416,6 +467,9 @@ static int fjes_tx_send(struct fjes_adapter *adapter, int dest,
 
 	adapter->hw.ep_shm_info[dest].tx.info->v1i.tx_status =
 		FJES_TX_DELAY_SEND_PENDING;
+	if (!work_pending(&adapter->raise_intr_rxdata_task))
+		queue_work(adapter->txrx_wq,
+			   &adapter->raise_intr_rxdata_task);
 
 	retval = 0;
 	return retval;
@@ -630,6 +684,11 @@ static int fjes_probe(struct platform_device *plat_dev)
 	adapter->force_reset = false;
 	adapter->open_guard = false;
 
+	adapter->txrx_wq = create_workqueue(DRV_NAME "/txrx");
+
+	INIT_WORK(&adapter->raise_intr_rxdata_task,
+		  fjes_raise_intr_rxdata_task);
+
 	res = platform_get_resource(plat_dev, IORESOURCE_MEM, 0);
 	hw->hw_res.start = res->start;
 	hw->hw_res.size = res->end - res->start + 1;
@@ -669,6 +728,10 @@ static int fjes_remove(struct platform_device *plat_dev)
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
