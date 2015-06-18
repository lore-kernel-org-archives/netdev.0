From: Taku Izumi <izumi.taku@jp.fujitsu.com>
Subject: [PATCH 18/22] fjes: unshare_watch_task
Date: Thu, 18 Jun 2015 09:49:43 +0900
Message-ID: <1434588587-25655-18-git-send-email-izumi.taku@jp.fujitsu.com>
References: <1434588359-25589-1-git-send-email-izumi.taku@jp.fujitsu.com>
 <1434588587-25655-1-git-send-email-izumi.taku@jp.fujitsu.com>
Cc: rkhan@redhat.com, alexander.h.duyck@redhat.com,
	netdev@vger.kernel.org, linux-acpi@vger.kernel.org,
	Taku Izumi <izumi.taku@jp.fujitsu.com>
To: platform-driver-x86@vger.kernel.org, dvhart@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgwym02.jp.fujitsu.com ([211.128.242.41]:48657 "EHLO
	mgwym02.jp.fujitsu.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752906AbbFRAxa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jun 2015 20:53:30 -0400
In-Reply-To: <1434588587-25655-1-git-send-email-izumi.taku@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds unshare_watch_task.

Shared buffer's status can be changed into unshared.
This task is used to monitor shared buffer's status.

Signed-off-by: Taku Izumi <izumi.taku@jp.fujitsu.com>
---
 drivers/platform/x86/fjes/fjes.h      |   3 +
 drivers/platform/x86/fjes/fjes_main.c | 152 ++++++++++++++++++++++++++++++++++
 2 files changed, 155 insertions(+)

diff --git a/drivers/platform/x86/fjes/fjes.h b/drivers/platform/x86/fjes/fjes.h
index e50fd01..2e814bb 100644
--- a/drivers/platform/x86/fjes/fjes.h
+++ b/drivers/platform/x86/fjes/fjes.h
@@ -61,6 +61,9 @@ struct fjes_adapter {
 	struct work_struct tx_stall_task;
 	struct work_struct raise_intr_rxdata_task;
 
+	struct work_struct unshare_watch_task;
+	unsigned long unshare_watch_bitmask;
+
 	struct delayed_work interrupt_watch_task;
 	bool interrupt_watch_enable;
 
diff --git a/drivers/platform/x86/fjes/fjes_main.c b/drivers/platform/x86/fjes/fjes_main.c
index 3931bcc..1bba967 100644
--- a/drivers/platform/x86/fjes/fjes_main.c
+++ b/drivers/platform/x86/fjes/fjes_main.c
@@ -75,6 +75,7 @@ static int fjes_remove(struct platform_device *);
 static int fjes_sw_init(struct fjes_adapter *);
 static void fjes_netdev_setup(struct net_device *);
 static void fjes_irq_watch_task(struct work_struct *);
+static void fjes_watch_unshare_task(struct work_struct *);
 static void fjes_rx_irq(struct fjes_adapter *, int);
 static int fjes_poll(struct napi_struct *, int);
 
@@ -317,6 +318,8 @@ static int fjes_close(struct net_device *netdev)
 	fjes_free_irq(adapter);
 
 	cancel_delayed_work_sync(&adapter->interrupt_watch_task);
+	cancel_work_sync(&adapter->unshare_watch_task);
+	adapter->unshare_watch_bitmask = 0;
 	cancel_work_sync(&adapter->raise_intr_rxdata_task);
 	cancel_work_sync(&adapter->tx_stall_task);
 
@@ -1075,6 +1078,8 @@ static int fjes_probe(struct platform_device *plat_dev)
 	INIT_WORK(&adapter->tx_stall_task, fjes_tx_stall_task);
 	INIT_WORK(&adapter->raise_intr_rxdata_task,
 			fjes_raise_intr_rxdata_task);
+	INIT_WORK(&adapter->unshare_watch_task, fjes_watch_unshare_task);
+	adapter->unshare_watch_bitmask = 0;
 
 	INIT_DELAYED_WORK(&adapter->interrupt_watch_task, fjes_irq_watch_task);
 	adapter->interrupt_watch_enable = false;
@@ -1121,7 +1126,9 @@ static int fjes_remove(struct platform_device *plat_dev)
 	struct fjes_adapter *adapter = netdev_priv(netdev);
 	struct fjes_hw *hw = &adapter->hw;
 
+
 	cancel_delayed_work_sync(&adapter->interrupt_watch_task);
+	cancel_work_sync(&adapter->unshare_watch_task);
 	cancel_work_sync(&adapter->raise_intr_rxdata_task);
 	cancel_work_sync(&adapter->tx_stall_task);
 	if (adapter->control_wq)
@@ -1185,6 +1192,151 @@ static void fjes_irq_watch_task(struct work_struct *work)
 
 }
 
+static void fjes_watch_unshare_task(struct work_struct *work)
+{
+	struct fjes_adapter *adapter = container_of(work,
+			struct fjes_adapter, unshare_watch_task);
+	struct fjes_hw *hw = &adapter->hw;
+	struct net_device *netdev = adapter->netdev;
+	int epidx;
+	int max_epid, my_epid;
+	unsigned long unshare_watch_bitmask;
+	int wait_time = 0;
+	int is_shared;
+	int ret;
+
+	my_epid = hw->my_epid;
+	max_epid = hw->max_epid;
+
+	unshare_watch_bitmask = adapter->unshare_watch_bitmask;
+	adapter->unshare_watch_bitmask = 0;
+
+	while ((unshare_watch_bitmask || hw->txrx_stop_req_bit) &&
+			(wait_time < 3000)) {
+
+		for (epidx = 0; epidx < hw->max_epid; epidx++) {
+
+			if (epidx == hw->my_epid)
+				continue;
+
+			if (test_bit(epidx, &hw->txrx_stop_req_bit)) {
+
+				is_shared = fjes_hw_epid_is_shared(hw->hw_info.share, epidx);
+				if (!is_shared ||
+					(is_shared &&
+					 (FJES_RX_STOP_REQ_DONE &
+					  hw->ep_shm_info[epidx].rx.info->v1i.rx_status))) {
+
+					mutex_lock(&hw->hw_info.lock);
+					ret = fjes_hw_unregister_buff_addr(hw, epidx);
+					switch (ret) {
+					case 0:
+						break;
+					case -ENOMSG:
+					case -EBUSY:
+					default:
+
+						if (!work_pending(&adapter->force_close_task)) {
+							adapter->force_reset = true;
+							schedule_work(&adapter->force_close_task);
+						}
+						break;
+					}
+					mutex_unlock(&hw->hw_info.lock);
+
+					fjes_hw_setup_epbuf(&hw->ep_shm_info[epidx].tx,
+						netdev->dev_addr, netdev->mtu);
+
+					clear_bit(epidx, &hw->txrx_stop_req_bit);
+					clear_bit(epidx, &unshare_watch_bitmask);
+					clear_bit(epidx, &hw->hw_info.buffer_unshare_reserve_bit);
+
+				}
+			}
+
+			is_shared = fjes_hw_epid_is_shared(hw->hw_info.share, epidx);
+			if (!is_shared && test_bit(epidx, &unshare_watch_bitmask)) {
+
+				if (test_bit(epidx, &hw->hw_info.buffer_unshare_reserve_bit)) {
+
+					mutex_lock(&hw->hw_info.lock);
+					ret = fjes_hw_unregister_buff_addr(hw, epidx);
+					switch (ret) {
+					case 0:
+						break;
+					case -ENOMSG:
+					case -EBUSY:
+					default:
+
+						if (!work_pending(&adapter->force_close_task)) {
+							adapter->force_reset = true;
+							schedule_work(&adapter->force_close_task);
+						}
+						break;
+					}
+					mutex_unlock(&hw->hw_info.lock);
+
+					fjes_hw_setup_epbuf(&hw->ep_shm_info[epidx].tx,
+						netdev->dev_addr, netdev->mtu);
+
+					clear_bit(epidx, &hw->txrx_stop_req_bit);
+					clear_bit(epidx, &unshare_watch_bitmask);
+					clear_bit(epidx, &hw->hw_info.buffer_unshare_reserve_bit);
+
+				}
+			}
+
+		}
+		msleep(100);
+		wait_time += 100;
+	}
+
+	if (hw->hw_info.buffer_unshare_reserve_bit) {
+
+		for (epidx = 0; epidx < hw->max_epid; epidx++) {
+
+			if (epidx == hw->my_epid)
+				continue;
+
+			if (test_bit(epidx, &hw->hw_info.buffer_unshare_reserve_bit)) {
+
+				mutex_lock(&hw->hw_info.lock);
+
+				ret = fjes_hw_unregister_buff_addr(hw, epidx);
+				switch (ret) {
+				case 0:
+					break;
+				case -ENOMSG:
+				case -EBUSY:
+				default:
+
+					if (!work_pending(&adapter->force_close_task)) {
+						adapter->force_reset = true;
+						schedule_work(&adapter->force_close_task);
+					}
+					break;
+				}
+				mutex_unlock(&hw->hw_info.lock);
+
+				fjes_hw_setup_epbuf(&hw->ep_shm_info[epidx].tx,
+					netdev->dev_addr, netdev->mtu);
+
+				clear_bit(epidx, &hw->txrx_stop_req_bit);
+				clear_bit(epidx, &unshare_watch_bitmask);
+				clear_bit(epidx,
+				  &hw->hw_info.buffer_unshare_reserve_bit);
+			}
+
+			if (test_bit(epidx, &unshare_watch_bitmask)) {
+				hw->ep_shm_info[epidx].tx.info->v1i.rx_status &=
+						~FJES_RX_STOP_REQ_DONE;
+			}
+		}
+
+	}
+
+}
+
 /*
  *  fjes_init_module - Driver Registration Routine
  *
-- 
1.8.3.1
