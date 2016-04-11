From: Taku Izumi <izumi.taku@jp.fujitsu.com>
Subject: [PATCH net-next 10/11] fjes: Introduce spinlock for rx_status
Date: Mon, 11 Apr 2016 17:10:51 +0900
Message-ID: <1460362251-15423-1-git-send-email-izumi.taku@jp.fujitsu.com>
References: <1460362136-14968-1-git-send-email-izumi.taku@jp.fujitsu.com>
Cc: Taku Izumi <izumi.taku@jp.fujitsu.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgwkm01.jp.fujitsu.com ([202.219.69.168]:60064 "EHLO
	mgwkm01.jp.fujitsu.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753318AbcDKITN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Apr 2016 04:19:13 -0400
Received: from m3051.s.css.fujitsu.com (m3051.s.css.fujitsu.com [10.134.21.209])
	by kw-mxauth.gw.nic.fujitsu.com (Postfix) with ESMTP id 98411AC0058
	for <netdev@vger.kernel.org>; Mon, 11 Apr 2016 17:19:08 +0900 (JST)
In-Reply-To: <1460362136-14968-1-git-send-email-izumi.taku@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch introduces spinlock of rx_status for
proper excusive control.

Signed-off-by: Taku Izumi <izumi.taku@jp.fujitsu.com>
---
 drivers/net/fjes/fjes_hw.c   | 22 ++++++++++++++++-
 drivers/net/fjes/fjes_hw.h   |  2 ++
 drivers/net/fjes/fjes_main.c | 57 +++++++++++++++++++++++++++++++++++++-------
 3 files changed, 72 insertions(+), 9 deletions(-)

diff --git a/drivers/net/fjes/fjes_hw.c b/drivers/net/fjes/fjes_hw.c
index 4861e36..79599d0 100644
--- a/drivers/net/fjes/fjes_hw.c
+++ b/drivers/net/fjes/fjes_hw.c
@@ -216,6 +216,7 @@ static int fjes_hw_setup(struct fjes_hw *hw)
 	u8 mac[ETH_ALEN] = { 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 };
 	struct fjes_device_command_param param;
 	struct ep_share_mem_info *buf_pair;
+	unsigned long flags;
 	size_t mem_size;
 	int result;
 	int epidx;
@@ -264,10 +265,12 @@ static int fjes_hw_setup(struct fjes_hw *hw)
 			if (result)
 				return result;
 
+			spin_lock_irqsave(&hw->rx_status_lock, flags);
 			fjes_hw_setup_epbuf(&buf_pair->tx, mac,
 					    fjes_support_mtu[0]);
 			fjes_hw_setup_epbuf(&buf_pair->rx, mac,
 					    fjes_support_mtu[0]);
+			spin_unlock_irqrestore(&hw->rx_status_lock, flags);
 		}
 	}
 
@@ -329,6 +332,7 @@ int fjes_hw_init(struct fjes_hw *hw)
 	INIT_WORK(&hw->epstop_task, fjes_hw_epstop_task);
 
 	mutex_init(&hw->hw_info.lock);
+	spin_lock_init(&hw->rx_status_lock);
 
 	hw->max_epid = fjes_hw_get_max_epid(hw);
 	hw->my_epid = fjes_hw_get_my_epid(hw);
@@ -736,6 +740,7 @@ fjes_hw_get_partner_ep_status(struct fjes_hw *hw, int epid)
 void fjes_hw_raise_epstop(struct fjes_hw *hw)
 {
 	enum ep_partner_status status;
+	unsigned long flags;
 	int epidx;
 
 	for (epidx = 0; epidx < hw->max_epid; epidx++) {
@@ -756,8 +761,10 @@ void fjes_hw_raise_epstop(struct fjes_hw *hw)
 		set_bit(epidx, &hw->hw_info.buffer_unshare_reserve_bit);
 		set_bit(epidx, &hw->txrx_stop_req_bit);
 
+		spin_lock_irqsave(&hw->rx_status_lock, flags);
 		hw->ep_shm_info[epidx].tx.info->v1i.rx_status |=
 				FJES_RX_STOP_REQ_REQUEST;
+		spin_unlock_irqrestore(&hw->rx_status_lock, flags);
 	}
 }
 
@@ -939,6 +946,7 @@ static void fjes_hw_update_zone_task(struct work_struct *work)
 
 	struct fjes_adapter *adapter;
 	struct net_device *netdev;
+	unsigned long flags;
 
 	ulong unshare_bit = 0;
 	ulong share_bit = 0;
@@ -1031,8 +1039,10 @@ static void fjes_hw_update_zone_task(struct work_struct *work)
 			continue;
 
 		if (test_bit(epidx, &share_bit)) {
+			spin_lock_irqsave(&hw->rx_status_lock, flags);
 			fjes_hw_setup_epbuf(&hw->ep_shm_info[epidx].tx,
 					    netdev->dev_addr, netdev->mtu);
+			spin_unlock_irqrestore(&hw->rx_status_lock, flags);
 
 			mutex_lock(&hw->hw_info.lock);
 
@@ -1082,10 +1092,14 @@ static void fjes_hw_update_zone_task(struct work_struct *work)
 			hw->ep_shm_info[epidx].ep_stats
 					      .command_unregister_buffer_executed += 1;
 
-			if (ret == 0)
+			if (ret == 0) {
+				spin_lock_irqsave(&hw->rx_status_lock, flags);
 				fjes_hw_setup_epbuf(
 					&hw->ep_shm_info[epidx].tx,
 					netdev->dev_addr, netdev->mtu);
+				spin_unlock_irqrestore(&hw->rx_status_lock,
+						       flags);
+			}
 		}
 
 		if (test_bit(epidx, &irq_bit)) {
@@ -1095,9 +1109,11 @@ static void fjes_hw_update_zone_task(struct work_struct *work)
 					      .send_interrupts_unshare += 1;
 
 			set_bit(epidx, &hw->txrx_stop_req_bit);
+			spin_lock_irqsave(&hw->rx_status_lock, flags);
 			hw->ep_shm_info[epidx].tx.
 				info->v1i.rx_status |=
 					FJES_RX_STOP_REQ_REQUEST;
+			spin_unlock_irqrestore(&hw->rx_status_lock, flags);
 			set_bit(epidx, &hw->hw_info.buffer_unshare_reserve_bit);
 		}
 	}
@@ -1113,6 +1129,7 @@ static void fjes_hw_epstop_task(struct work_struct *work)
 {
 	struct fjes_hw *hw = container_of(work, struct fjes_hw, epstop_task);
 	struct fjes_adapter *adapter = (struct fjes_adapter *)hw->back;
+	unsigned long flags;
 
 	ulong remain_bit;
 	int epid_bit;
@@ -1120,9 +1137,12 @@ static void fjes_hw_epstop_task(struct work_struct *work)
 	while ((remain_bit = hw->epstop_req_bit)) {
 		for (epid_bit = 0; remain_bit; remain_bit >>= 1, epid_bit++) {
 			if (remain_bit & 1) {
+				spin_lock_irqsave(&hw->rx_status_lock, flags);
 				hw->ep_shm_info[epid_bit].
 					tx.info->v1i.rx_status |=
 						FJES_RX_STOP_REQ_DONE;
+				spin_unlock_irqrestore(&hw->rx_status_lock,
+						       flags);
 
 				clear_bit(epid_bit, &hw->epstop_req_bit);
 				set_bit(epid_bit,
diff --git a/drivers/net/fjes/fjes_hw.h b/drivers/net/fjes/fjes_hw.h
index 66cefd1..ca72474 100644
--- a/drivers/net/fjes/fjes_hw.h
+++ b/drivers/net/fjes/fjes_hw.h
@@ -329,6 +329,8 @@ struct fjes_hw {
 
 	bool trace_started;
 	u32 trace_mode;
+
+	spinlock_t rx_status_lock; /* spinlock for rx_status */
 };
 
 int fjes_hw_init(struct fjes_hw *);
diff --git a/drivers/net/fjes/fjes_main.c b/drivers/net/fjes/fjes_main.c
index 8ab0523..22bd175 100644
--- a/drivers/net/fjes/fjes_main.c
+++ b/drivers/net/fjes/fjes_main.c
@@ -293,6 +293,7 @@ static int fjes_close(struct net_device *netdev)
 {
 	struct fjes_adapter *adapter = netdev_priv(netdev);
 	struct fjes_hw *hw = &adapter->hw;
+	unsigned long flags;
 	int epidx;
 
 	netif_tx_stop_all_queues(netdev);
@@ -302,13 +303,18 @@ static int fjes_close(struct net_device *netdev)
 
 	napi_disable(&adapter->napi);
 
+	spin_lock_irqsave(&hw->rx_status_lock, flags);
 	for (epidx = 0; epidx < hw->max_epid; epidx++) {
 		if (epidx == hw->my_epid)
 			continue;
 
-		adapter->hw.ep_shm_info[epidx].tx.info->v1i.rx_status &=
-			~FJES_RX_POLL_WORK;
+		if (fjes_hw_get_partner_ep_status(hw, epidx) ==
+		    EP_PARTNER_SHARED)
+			adapter->hw.ep_shm_info[epidx]
+				   .tx.info->v1i.rx_status &=
+				~FJES_RX_POLL_WORK;
 	}
+	spin_unlock_irqrestore(&hw->rx_status_lock, flags);
 
 	fjes_free_irq(adapter);
 
@@ -333,6 +339,7 @@ static int fjes_setup_resources(struct fjes_adapter *adapter)
 	struct net_device *netdev = adapter->netdev;
 	struct ep_share_mem_info *buf_pair;
 	struct fjes_hw *hw = &adapter->hw;
+	unsigned long flags;
 	int result;
 	int epidx;
 
@@ -376,8 +383,10 @@ static int fjes_setup_resources(struct fjes_adapter *adapter)
 
 		buf_pair = &hw->ep_shm_info[epidx];
 
+		spin_lock_irqsave(&hw->rx_status_lock, flags);
 		fjes_hw_setup_epbuf(&buf_pair->tx, netdev->dev_addr,
 				    netdev->mtu);
+		spin_unlock_irqrestore(&hw->rx_status_lock, flags);
 
 		if (fjes_hw_epid_is_same_zone(hw, epidx)) {
 			mutex_lock(&hw->hw_info.lock);
@@ -410,6 +419,7 @@ static void fjes_free_resources(struct fjes_adapter *adapter)
 	struct ep_share_mem_info *buf_pair;
 	struct fjes_hw *hw = &adapter->hw;
 	bool reset_flag = false;
+	unsigned long flags;
 	int result;
 	int epidx;
 
@@ -429,8 +439,10 @@ static void fjes_free_resources(struct fjes_adapter *adapter)
 
 		buf_pair = &hw->ep_shm_info[epidx];
 
+		spin_lock_irqsave(&hw->rx_status_lock, flags);
 		fjes_hw_setup_epbuf(&buf_pair->tx,
 				    netdev->dev_addr, netdev->mtu);
+		spin_unlock_irqrestore(&hw->rx_status_lock, flags);
 
 		clear_bit(epidx, &hw->txrx_stop_req_bit);
 	}
@@ -789,6 +801,7 @@ static int fjes_change_mtu(struct net_device *netdev, int new_mtu)
 	struct fjes_adapter *adapter = netdev_priv(netdev);
 	bool running = netif_running(netdev);
 	struct fjes_hw *hw = &adapter->hw;
+	unsigned long flags;
 	int ret = -EINVAL;
 	int idx, epidx;
 
@@ -807,12 +820,15 @@ static int fjes_change_mtu(struct net_device *netdev, int new_mtu)
 		return ret;
 
 	if (running) {
+		spin_lock_irqsave(&hw->rx_status_lock, flags);
 		for (epidx = 0; epidx < hw->max_epid; epidx++) {
 			if (epidx == hw->my_epid)
 				continue;
 			hw->ep_shm_info[epidx].tx.info->v1i.rx_status &=
 				~FJES_RX_MTU_CHANGING_DONE;
 		}
+		spin_unlock_irqrestore(&hw->rx_status_lock, flags);
+
 		netif_tx_stop_all_queues(netdev);
 		netif_carrier_off(netdev);
 		cancel_work_sync(&adapter->tx_stall_task);
@@ -826,23 +842,25 @@ static int fjes_change_mtu(struct net_device *netdev, int new_mtu)
 	netdev->mtu = new_mtu;
 
 	if (running) {
+		spin_lock_irqsave(&hw->rx_status_lock, flags);
 		for (epidx = 0; epidx < hw->max_epid; epidx++) {
 			if (epidx == hw->my_epid)
 				continue;
 
-			local_irq_disable();
+			spin_lock_irqsave(&hw->rx_status_lock, flags);
 			fjes_hw_setup_epbuf(&hw->ep_shm_info[epidx].tx,
 					    netdev->dev_addr,
 					    netdev->mtu);
-			local_irq_enable();
 
 			hw->ep_shm_info[epidx].tx.info->v1i.rx_status |=
 				FJES_RX_MTU_CHANGING_DONE;
+			spin_unlock_irqrestore(&hw->rx_status_lock, flags);
 		}
 
 		netif_tx_wake_all_queues(netdev);
 		netif_carrier_on(netdev);
 		napi_enable(&adapter->napi);
+		napi_schedule(&adapter->napi);
 	}
 
 	return ret;
@@ -1096,6 +1114,7 @@ static void fjes_txrx_stop_req_irq(struct fjes_adapter *adapter,
 {
 	struct fjes_hw *hw = &adapter->hw;
 	enum ep_partner_status status;
+	unsigned long flags;
 
 	status = fjes_hw_get_partner_ep_status(hw, src_epid);
 	switch (status) {
@@ -1105,8 +1124,10 @@ static void fjes_txrx_stop_req_irq(struct fjes_adapter *adapter,
 		break;
 	case EP_PARTNER_WAITING:
 		if (src_epid < hw->my_epid) {
+			spin_lock_irqsave(&hw->rx_status_lock, flags);
 			hw->ep_shm_info[src_epid].tx.info->v1i.rx_status |=
 				FJES_RX_STOP_REQ_DONE;
+			spin_unlock_irqrestore(&hw->rx_status_lock, flags);
 
 			clear_bit(src_epid, &hw->txrx_stop_req_bit);
 			set_bit(src_epid, &adapter->unshare_watch_bitmask);
@@ -1132,14 +1153,17 @@ static void fjes_stop_req_irq(struct fjes_adapter *adapter, int src_epid)
 {
 	struct fjes_hw *hw = &adapter->hw;
 	enum ep_partner_status status;
+	unsigned long flags;
 
 	set_bit(src_epid, &hw->hw_info.buffer_unshare_reserve_bit);
 
 	status = fjes_hw_get_partner_ep_status(hw, src_epid);
 	switch (status) {
 	case EP_PARTNER_WAITING:
+		spin_lock_irqsave(&hw->rx_status_lock, flags);
 		hw->ep_shm_info[src_epid].tx.info->v1i.rx_status |=
 				FJES_RX_STOP_REQ_DONE;
+		spin_unlock_irqrestore(&hw->rx_status_lock, flags);
 		clear_bit(src_epid, &hw->txrx_stop_req_bit);
 		/* fall through */
 	case EP_PARTNER_UNSHARE:
@@ -1284,13 +1308,17 @@ static int fjes_poll(struct napi_struct *napi, int budget)
 	size_t frame_len;
 	void *frame;
 
+	spin_lock(&hw->rx_status_lock);
 	for (epidx = 0; epidx < hw->max_epid; epidx++) {
 		if (epidx == hw->my_epid)
 			continue;
 
-		adapter->hw.ep_shm_info[epidx].tx.info->v1i.rx_status |=
-			FJES_RX_POLL_WORK;
+		if (fjes_hw_get_partner_ep_status(hw, epidx) ==
+		    EP_PARTNER_SHARED)
+			adapter->hw.ep_shm_info[epidx]
+				   .tx.info->v1i.rx_status |= FJES_RX_POLL_WORK;
 	}
+	spin_unlock(&hw->rx_status_lock);
 
 	while (work_done < budget) {
 		prefetch(&adapter->hw);
@@ -1348,13 +1376,17 @@ static int fjes_poll(struct napi_struct *napi, int budget)
 		if (((long)jiffies - (long)adapter->rx_last_jiffies) < 3) {
 			napi_reschedule(napi);
 		} else {
+			spin_lock(&hw->rx_status_lock);
 			for (epidx = 0; epidx < hw->max_epid; epidx++) {
 				if (epidx == hw->my_epid)
 					continue;
-				adapter->hw.ep_shm_info[epidx]
-					   .tx.info->v1i.rx_status &=
+				if (fjes_hw_get_partner_ep_status(hw, epidx) ==
+				    EP_PARTNER_SHARED)
+					adapter->hw.ep_shm_info[epidx].tx
+						   .info->v1i.rx_status &=
 						~FJES_RX_POLL_WORK;
 			}
+			spin_unlock(&hw->rx_status_lock);
 
 			fjes_hw_set_irqmask(hw, REG_ICTL_MASK_RX_DATA, false);
 		}
@@ -1527,6 +1559,7 @@ static void fjes_watch_unshare_task(struct work_struct *work)
 	int max_epid, my_epid, epidx;
 	int stop_req, stop_req_done;
 	ulong unshare_watch_bitmask;
+	unsigned long flags;
 	int wait_time = 0;
 	int is_shared;
 	int ret;
@@ -1582,8 +1615,10 @@ static void fjes_watch_unshare_task(struct work_struct *work)
 			hw->ep_shm_info[epidx].ep_stats
 					      .command_unregister_buffer_executed += 1;
 
+			spin_lock_irqsave(&hw->rx_status_lock, flags);
 			fjes_hw_setup_epbuf(&hw->ep_shm_info[epidx].tx,
 					    netdev->dev_addr, netdev->mtu);
+			spin_unlock_irqrestore(&hw->rx_status_lock, flags);
 
 			clear_bit(epidx, &hw->txrx_stop_req_bit);
 			clear_bit(epidx, &unshare_watch_bitmask);
@@ -1624,9 +1659,12 @@ static void fjes_watch_unshare_task(struct work_struct *work)
 				hw->ep_shm_info[epidx].ep_stats
 						      .command_unregister_buffer_executed += 1;
 
+				spin_lock_irqsave(&hw->rx_status_lock, flags);
 				fjes_hw_setup_epbuf(
 					&hw->ep_shm_info[epidx].tx,
 					netdev->dev_addr, netdev->mtu);
+				spin_unlock_irqrestore(&hw->rx_status_lock,
+						       flags);
 
 				clear_bit(epidx, &hw->txrx_stop_req_bit);
 				clear_bit(epidx, &unshare_watch_bitmask);
@@ -1634,8 +1672,11 @@ static void fjes_watch_unshare_task(struct work_struct *work)
 			}
 
 			if (test_bit(epidx, &unshare_watch_bitmask)) {
+				spin_lock_irqsave(&hw->rx_status_lock, flags);
 				hw->ep_shm_info[epidx].tx.info->v1i.rx_status &=
 						~FJES_RX_STOP_REQ_DONE;
+				spin_unlock_irqrestore(&hw->rx_status_lock,
+						       flags);
 			}
 		}
 	}
-- 
2.4.3
