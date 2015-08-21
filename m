From: Taku Izumi <izumi.taku@jp.fujitsu.com>
Subject: [PATCH v3 21/22] fjes: handle receive cancellation request interrupt
Date: Fri, 21 Aug 2015 17:29:37 +0900
Message-ID: <1440145778-15941-21-git-send-email-izumi.taku@jp.fujitsu.com>
References: <1440145680-15851-1-git-send-email-izumi.taku@jp.fujitsu.com>
 <1440145778-15941-1-git-send-email-izumi.taku@jp.fujitsu.com>
Cc: platform-driver-x86@vger.kernel.org, dvhart@infradead.org,
	rkhan@redhat.com, alexander.h.duyck@redhat.com,
	linux-acpi@vger.kernel.org, joe@perches.com,
	sergei.shtylyov@cogentembedded.com, stephen@networkplumber.org,
	yasu.isimatu@gmail.com, Taku Izumi <izumi.taku@jp.fujitsu.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgwkm03.jp.fujitsu.com ([202.219.69.170]:35699 "EHLO
	mgwkm03.jp.fujitsu.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753564AbbHUIf1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Aug 2015 04:35:27 -0400
In-Reply-To: <1440145778-15941-1-git-send-email-izumi.taku@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds implementation of handling IRQ
of other receiver's receive cancellation request.

Signed-off-by: Taku Izumi <izumi.taku@jp.fujitsu.com>
---
 drivers/net/fjes/fjes_main.c | 78 ++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 78 insertions(+)

diff --git a/drivers/net/fjes/fjes_main.c b/drivers/net/fjes/fjes_main.c
index 5e77d0c..5f93e42 100644
--- a/drivers/net/fjes/fjes_main.c
+++ b/drivers/net/fjes/fjes_main.c
@@ -820,6 +820,74 @@ static int fjes_vlan_rx_kill_vid(struct net_device *netdev,
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
+	case EP_PARTNER_COMPLETE:
+	default:
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
+		if (hw->ep_shm_info[src_epid].rx.info->v1i.rx_status &
+		    FJES_RX_STOP_REQ_REQUEST) {
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
@@ -842,6 +910,16 @@ static irqreturn_t fjes_intr(int irq, void *data)
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
