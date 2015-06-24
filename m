From: Taku Izumi <izumi.taku@jp.fujitsu.com>
Subject: [PATCH v2 21/22] fjes: handle receive cancellation request interrupt
Date: Wed, 24 Jun 2015 11:55:53 +0900
Message-ID: <1435114554-7151-22-git-send-email-izumi.taku@jp.fujitsu.com>
References: <1435114351-6961-1-git-send-email-izumi.taku@jp.fujitsu.com>
Cc: platform-driver-x86@vger.kernel.org, dvhart@infradead.org,
	rkhan@redhat.com, alexander.h.duyck@redhat.com,
	linux-acpi@vger.kernel.org, joe@perches.com,
	sergei.shtylyov@cogentembedded.com, stephen@networkplumber.org,
	yasu.isimatu@gmail.com, Taku Izumi <izumi.taku@jp.fujitsu.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <1435114351-6961-1-git-send-email-izumi.taku@jp.fujitsu.com>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds implementation of handling IRQ
of other receiver's receive cancellation request.

Signed-off-by: Taku Izumi <izumi.taku@jp.fujitsu.com>
---
 drivers/net/fjes/fjes_main.c | 79 ++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 79 insertions(+)

diff --git a/drivers/net/fjes/fjes_main.c b/drivers/net/fjes/fjes_main.c
index df4a292..1db1a7d 100644
--- a/drivers/net/fjes/fjes_main.c
+++ b/drivers/net/fjes/fjes_main.c
@@ -826,6 +826,75 @@ static int fjes_vlan_rx_kill_vid(struct net_device *netdev,
 	return 0;
 }
 
+static void fjes_txrx_stop_req_irq(struct fjes_adapter *adapter,
+				   int src_epid)
+{
+	struct fjes_hw *hw = &adapter->hw;
+	enum ep_partner_status status;
+
+	status = fjes_hw_get_partner_ep_status(hw, src_epid);
+	switch (status) {
+	case EP_PARTNER_UNSHARE:
+	default:
+		break;
+	case EP_PARTNER_COMPLETE:
+		break;
+	case EP_PARTNER_WAITING:
+		if (src_epid < hw->my_epid) {
+			hw->ep_shm_info[src_epid].tx.info->v1i.rx_status |=
+				FJES_RX_STOP_REQ_DONE;
+
+			clear_bit(src_epid, &hw->txrx_stop_req_bit);
+			set_bit(src_epid, &adapter->unshare_watch_bitmask);
+
+			if (!work_pending(&adapter->unshare_watch_task))
+				queue_work(adapter->control_wq,
+					   &adapter->unshare_watch_task);
+		}
+		break;
+	case EP_PARTNER_SHARED:
+		if (hw->ep_shm_info[src_epid].rx.info->v1i.rx_status
+				& FJES_RX_STOP_REQ_REQUEST) {
+			set_bit(src_epid, &hw->epstop_req_bit);
+			if (!work_pending(&hw->epstop_task))
+				queue_work(adapter->control_wq,
+					   &hw->epstop_task);
+		}
+		break;
+	}
+}
+
+static void fjes_stop_req_irq(struct fjes_adapter *adapter, int src_epid)
+{
+	struct fjes_hw *hw = &adapter->hw;
+	enum ep_partner_status status;
+
+	set_bit(src_epid, &hw->hw_info.buffer_unshare_reserve_bit);
+
+	status = fjes_hw_get_partner_ep_status(hw, src_epid);
+	switch (status) {
+	case EP_PARTNER_WAITING:
+		hw->ep_shm_info[src_epid].tx.info->v1i.rx_status |=
+				FJES_RX_STOP_REQ_DONE;
+		clear_bit(src_epid, &hw->txrx_stop_req_bit);
+		/* fall through */
+	case EP_PARTNER_UNSHARE:
+	case EP_PARTNER_COMPLETE:
+	default:
+		set_bit(src_epid, &adapter->unshare_watch_bitmask);
+		if (!work_pending(&adapter->unshare_watch_task))
+			queue_work(adapter->control_wq,
+				   &adapter->unshare_watch_task);
+		break;
+	case EP_PARTNER_SHARED:
+		set_bit(src_epid, &hw->epstop_req_bit);
+
+		if (!work_pending(&hw->epstop_task))
+			queue_work(adapter->control_wq, &hw->epstop_task);
+		break;
+	}
+}
+
 static void fjes_update_zone_irq(struct fjes_adapter *adapter,
 				 int src_epid)
 {
@@ -848,6 +917,16 @@ static irqreturn_t fjes_intr(int irq, void *data)
 		if (icr & REG_ICTL_MASK_RX_DATA)
 			fjes_rx_irq(adapter, icr & REG_IS_MASK_EPID);
 
+		if (icr & REG_ICTL_MASK_DEV_STOP_REQ)
+			fjes_stop_req_irq(adapter, icr & REG_IS_MASK_EPID);
+
+		if (icr & REG_ICTL_MASK_TXRX_STOP_REQ)
+			fjes_txrx_stop_req_irq(adapter, icr & REG_IS_MASK_EPID);
+
+		if (icr & REG_ICTL_MASK_TXRX_STOP_DONE)
+			fjes_hw_set_irqmask(hw,
+					    REG_ICTL_MASK_TXRX_STOP_DONE, true);
+
 		if (icr & REG_ICTL_MASK_INFO_UPDATE)
 			fjes_update_zone_irq(adapter, icr & REG_IS_MASK_EPID);
 
-- 
1.8.3.1

