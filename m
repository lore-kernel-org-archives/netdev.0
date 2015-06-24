From: Taku Izumi <izumi.taku@jp.fujitsu.com>
Subject: [PATCH v2 19/22] fjes: update_zone_task
Date: Wed, 24 Jun 2015 11:55:51 +0900
Message-ID: <1435114554-7151-20-git-send-email-izumi.taku@jp.fujitsu.com>
References: <1435114351-6961-1-git-send-email-izumi.taku@jp.fujitsu.com>
Cc: platform-driver-x86@vger.kernel.org, dvhart@infradead.org,
	rkhan@redhat.com, alexander.h.duyck@redhat.com,
	linux-acpi@vger.kernel.org, joe@perches.com,
	sergei.shtylyov@cogentembedded.com, stephen@networkplumber.org,
	yasu.isimatu@gmail.com, Taku Izumi <izumi.taku@jp.fujitsu.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <platform-driver-x86-owner@vger.kernel.org>
In-Reply-To: <1435114351-6961-1-git-send-email-izumi.taku@jp.fujitsu.com>
Sender: platform-driver-x86-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds update_zone_task.
Zoning information can be changed by user.
This task is used to monitor if zoning information is
changed or not.

Signed-off-by: Taku Izumi <izumi.taku@jp.fujitsu.com>
---
 drivers/net/fjes/fjes_hw.c   | 171 +++++++++++++++++++++++++++++++++++++++++++
 drivers/net/fjes/fjes_hw.h   |   1 +
 drivers/net/fjes/fjes_main.c |  14 ++++
 3 files changed, 186 insertions(+)

diff --git a/drivers/net/fjes/fjes_hw.c b/drivers/net/fjes/fjes_hw.c
index 8363e22..8756d3e 100644
--- a/drivers/net/fjes/fjes_hw.c
+++ b/drivers/net/fjes/fjes_hw.c
@@ -22,6 +22,8 @@
 #include "fjes_hw.h"
 #include "fjes.h"
 
+static void fjes_hw_update_zone_task(struct work_struct *);
+
 /* supported MTU list */
 const u32 fjes_support_mtu[] = {
 	FJES_MTU_DEFINE(8 * 1024),
@@ -323,6 +325,8 @@ int fjes_hw_init(struct fjes_hw *hw)
 
 	fjes_hw_set_irqmask(hw, REG_ICTL_MASK_ALL, true);
 
+	INIT_WORK(&hw->update_zone_task, fjes_hw_update_zone_task);
+
 	mutex_init(&hw->hw_info.lock);
 
 	hw->max_epid = fjes_hw_get_max_epid(hw);
@@ -350,6 +354,8 @@ void fjes_hw_exit(struct fjes_hw *hw)
 	}
 
 	fjes_hw_cleanup(hw);
+
+	cancel_work_sync(&hw->update_zone_task);
 }
 
 static enum fjes_dev_command_response_e
@@ -919,3 +925,168 @@ int fjes_hw_epbuf_tx_pkt_send(struct epbuf_handler *epbh,
 	return 0;
 }
 
+static void fjes_hw_update_zone_task(struct work_struct *work)
+{
+	struct fjes_hw *hw = container_of(work,
+			struct fjes_hw, update_zone_task);
+	struct fjes_adapter *adapter = (struct fjes_adapter *)hw->back;
+	struct net_device *netdev = adapter->netdev;
+	int ret;
+	int epidx;
+	enum ep_partner_status pstatus;
+	unsigned long share_bit = 0;
+	unsigned long unshare_bit = 0;
+	unsigned long irq_bit = 0;
+	union fjes_device_command_res *res_buf = hw->hw_info.res_buf;
+	struct my_s {u8 es_status; u8 zone; } *info =
+		(struct my_s *)&res_buf->info.info;
+
+	mutex_lock(&hw->hw_info.lock);
+
+	ret = fjes_hw_request_info(hw);
+	switch (ret) {
+	case -ENOMSG:
+	case -EBUSY:
+	default:
+		if (!work_pending(&adapter->force_close_task)) {
+			adapter->force_reset = true;
+			schedule_work(&adapter->force_close_task);
+		}
+		break;
+
+	case 0:
+
+		for (epidx = 0; epidx < hw->max_epid; epidx++) {
+			if (epidx == hw->my_epid) {
+				hw->ep_shm_info[epidx].es_status =
+					info[epidx].es_status;
+				hw->ep_shm_info[epidx].zone =
+					info[epidx].zone;
+				continue;
+			}
+
+			pstatus = fjes_hw_get_partner_ep_status(hw, epidx);
+			switch (pstatus) {
+			case EP_PARTNER_UNSHARE:
+			default:
+				if ((info[epidx].zone !=
+					FJES_ZONING_ZONE_TYPE_NONE) &&
+				    (info[epidx].es_status ==
+					FJES_ZONING_STATUS_ENABLE) &&
+				    (info[epidx].zone ==
+					info[hw->my_epid].zone))
+					set_bit(epidx, &share_bit);
+				else
+					set_bit(epidx, &unshare_bit);
+				break;
+
+			case EP_PARTNER_COMPLETE:
+			case EP_PARTNER_WAITING:
+				if ((info[epidx].zone ==
+					FJES_ZONING_ZONE_TYPE_NONE) ||
+				    (info[epidx].es_status !=
+					FJES_ZONING_STATUS_ENABLE) ||
+				    (info[epidx].zone !=
+					info[hw->my_epid].zone)) {
+					set_bit(epidx,
+						&adapter->unshare_watch_bitmask);
+					set_bit(epidx,
+						&hw->hw_info.buffer_unshare_reserve_bit);
+				}
+				break;
+
+			case EP_PARTNER_SHARED:
+				if ((info[epidx].zone ==
+					FJES_ZONING_ZONE_TYPE_NONE) ||
+				    (info[epidx].es_status !=
+					FJES_ZONING_STATUS_ENABLE) ||
+				    (info[epidx].zone !=
+					info[hw->my_epid].zone))
+					set_bit(epidx, &irq_bit);
+				break;
+			}
+		}
+
+		hw->ep_shm_info[epidx].es_status = info[epidx].es_status;
+		hw->ep_shm_info[epidx].zone = info[epidx].zone;
+
+		break;
+	}
+
+	mutex_unlock(&hw->hw_info.lock);
+
+	for (epidx = 0; epidx < hw->max_epid; epidx++) {
+		if (epidx == hw->my_epid)
+			continue;
+
+		if (test_bit(epidx, &share_bit)) {
+			fjes_hw_setup_epbuf(&hw->ep_shm_info[epidx].tx,
+					    netdev->dev_addr, netdev->mtu);
+
+			mutex_lock(&hw->hw_info.lock);
+
+			ret = fjes_hw_register_buff_addr(
+				hw, epidx, &hw->ep_shm_info[epidx]);
+
+			switch (ret) {
+			case 0:
+				break;
+			case -ENOMSG:
+			case -EBUSY:
+			default:
+				if (!work_pending(&adapter->force_close_task)) {
+					adapter->force_reset = true;
+					schedule_work(
+					  &adapter->force_close_task);
+				}
+				break;
+			}
+			mutex_unlock(&hw->hw_info.lock);
+		}
+
+		if (test_bit(epidx, &unshare_bit)) {
+			mutex_lock(&hw->hw_info.lock);
+
+			ret = fjes_hw_unregister_buff_addr(hw, epidx);
+
+			switch (ret) {
+			case 0:
+				break;
+			case -ENOMSG:
+			case -EBUSY:
+			default:
+				if (!work_pending(&adapter->force_close_task)) {
+					adapter->force_reset = true;
+					schedule_work(
+					  &adapter->force_close_task);
+				}
+				break;
+			}
+
+			mutex_unlock(&hw->hw_info.lock);
+
+			if (ret == 0)
+				fjes_hw_setup_epbuf(
+					&hw->ep_shm_info[epidx].tx,
+					netdev->dev_addr, netdev->mtu);
+		}
+
+		if (test_bit(epidx, &irq_bit)) {
+			fjes_hw_raise_interrupt(hw, epidx,
+						REG_ICTL_MASK_TXRX_STOP_REQ);
+
+			set_bit(epidx, &hw->txrx_stop_req_bit);
+			hw->ep_shm_info[epidx].tx.
+				info->v1i.rx_status |=
+					FJES_RX_STOP_REQ_REQUEST;
+			set_bit(epidx, &hw->hw_info.buffer_unshare_reserve_bit);
+		}
+	}
+
+	if (irq_bit || adapter->unshare_watch_bitmask) {
+		if (!work_pending(&adapter->unshare_watch_task))
+			queue_work(adapter->control_wq,
+				   &adapter->unshare_watch_task);
+	}
+}
+
diff --git a/drivers/net/fjes/fjes_hw.h b/drivers/net/fjes/fjes_hw.h
index afad03e..d80b8c8 100644
--- a/drivers/net/fjes/fjes_hw.h
+++ b/drivers/net/fjes/fjes_hw.h
@@ -281,6 +281,7 @@ struct fjes_hw {
 
 	unsigned long txrx_stop_req_bit;
 	unsigned long epstop_req_bit;
+	struct work_struct update_zone_task;
 
 	int my_epid;
 	int max_epid;
diff --git a/drivers/net/fjes/fjes_main.c b/drivers/net/fjes/fjes_main.c
index 69a238c..b37e909 100644
--- a/drivers/net/fjes/fjes_main.c
+++ b/drivers/net/fjes/fjes_main.c
@@ -318,6 +318,8 @@ static int fjes_close(struct net_device *netdev)
 	cancel_work_sync(&adapter->raise_intr_rxdata_task);
 	cancel_work_sync(&adapter->tx_stall_task);
 
+	cancel_work_sync(&hw->update_zone_task);
+
 	fjes_hw_wait_epstop(hw);
 
 	fjes_free_resources(adapter);
@@ -823,6 +825,15 @@ static int fjes_vlan_rx_kill_vid(struct net_device *netdev,
 	return 0;
 }
 
+static void fjes_update_zone_irq(struct fjes_adapter *adapter,
+				 int src_epid)
+{
+	struct fjes_hw *hw = &adapter->hw;
+
+	if (!work_pending(&hw->update_zone_task))
+		queue_work(adapter->control_wq, &hw->update_zone_task);
+}
+
 static irqreturn_t fjes_intr(int irq, void *data)
 {
 	struct fjes_adapter *adapter = data;
@@ -836,6 +847,9 @@ static irqreturn_t fjes_intr(int irq, void *data)
 		if (icr & REG_ICTL_MASK_RX_DATA)
 			fjes_rx_irq(adapter, icr & REG_IS_MASK_EPID);
 
+		if (icr & REG_ICTL_MASK_INFO_UPDATE)
+			fjes_update_zone_irq(adapter, icr & REG_IS_MASK_EPID);
+
 		ret = IRQ_HANDLED;
 	} else {
 		ret = IRQ_NONE;
-- 
1.8.3.1
