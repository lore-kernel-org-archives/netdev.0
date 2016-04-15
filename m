From: Taku Izumi <izumi.taku@jp.fujitsu.com>
Subject: [PATCH net-next v2 5/6] fjes: Introduce spinlock for rx_status
Date: Fri, 15 Apr 2016 11:25:46 +0900
Message-ID: <1460687146-26749-1-git-send-email-izumi.taku@jp.fujitsu.com>
References: <1460686800-26427-1-git-send-email-izumi.taku@jp.fujitsu.com>
Cc: jiri@resnulli.us, isimatu.yasuaki@jp.fujitsu.com,
	Taku Izumi <izumi.taku@jp.fujitsu.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgwym01.jp.fujitsu.com ([211.128.242.40]:21104 "EHLO
	mgwym01.jp.fujitsu.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753079AbcDOCeU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Apr 2016 22:34:20 -0400
Received: from m3051.s.css.fujitsu.com (m3051.s.css.fujitsu.com [10.134.21.209])
	by yt-mxoi1.gw.nic.fujitsu.com (Postfix) with ESMTP id 23078AC0337
	for <netdev@vger.kernel.org>; Fri, 15 Apr 2016 11:34:10 +0900 (JST)
In-Reply-To: <1460686800-26427-1-git-send-email-izumi.taku@jp.fujitsu.com>
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
index e9f494b..0dbafed 100644
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
@@ -755,8 +760,10 @@ void fjes_hw_raise_epstop(struct fjes_hw *hw)
 		set_bit(epidx, &hw->hw_info.buffer_unshare_reserve_bit);
 		set_bit(epidx, &hw->txrx_stop_req_bit);
 
+		spin_lock_irqsave(&hw->rx_status_lock, flags);
 		hw->ep_shm_info[epidx].tx.info->v1i.rx_status |=
 				FJES_RX_STOP_REQ_REQUEST;
+		spin_unlock_irqrestore(&hw->rx_status_lock, flags);
 	}
 }
 
@@ -938,6 +945,7 @@ static void fjes_hw_update_zone_task(struct work_struct *work)
 
 	struct fjes_adapter *adapter;
 	struct net_device *netdev;
+	unsigned long flags;
 
 	ulong unshare_bit = 0;
 	ulong share_bit = 0;
@@ -1030,8 +1038,10 @@ static void fjes_hw_update_zone_task(struct work_struct *work)
 			continue;
 
 		if (test_bit(epidx, &share_bit)) {
+			spin_lock_irqsave(&hw->rx_status_lock, flags);
 			fjes_hw_setup_epbuf(&hw->ep_shm_info[epidx].tx,
 					    netdev->dev_addr, netdev->mtu);
+			spin_unlock_irqrestore(&hw->rx_status_lock, flags);
 
 			mutex_lock(&hw->hw_info.lock);
 
@@ -1075,10 +1085,14 @@ static void fjes_hw_update_zone_task(struct work_struct *work)
 
 			mutex_unlock(&hw->hw_info.lock);
 
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
@@ -1086,9 +1100,11 @@ static void fjes_hw_update_zone_task(struct work_struct *work)
 						REG_ICTL_MASK_TXRX_STOP_REQ);
 
 			set_bit(epidx, &hw->txrx_stop_req_bit);
+			spin_lock_irqsave(&hw->rx_status_lock, flags);
 			hw->ep_shm_info[epidx].tx.
 				info->v1i.rx_status |=
 					FJES_RX_STOP_REQ_REQUEST;
+			spin_unlock_irqrestore(&hw->rx_status_lock, flags);
 			set_bit(epidx, &hw->hw_info.buffer_unshare_reserve_bit);
 		}
 	}
@@ -1104,6 +1120,7 @@ static void fjes_hw_epstop_task(struct work_struct *work)
 {
 	struct fjes_hw *hw = container_of(work, struct fjes_hw, epstop_task);
 	struct fjes_adapter *adapter = (struct fjes_adapter *)hw->back;
+	unsigned long flags;
 
 	ulong remain_bit;
 	int epid_bit;
@@ -1111,9 +1128,12 @@ static void fjes_hw_epstop_task(struct work_struct *work)
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
index f40cf07..1445ac9 100644
--- a/drivers/net/fjes/fjes_hw.h
+++ b/drivers/net/fjes/fjes_hw.h
@@ -300,6 +300,8 @@ struct fjes_hw {
 	u8 *base;
 
 	struct fjes_hw_info hw_info;
+
+	spinlock_t rx_status_lock; /* spinlock for rx_status */
 };
 
 int fjes_hw_init(struct fjes_hw *);
diff --git a/drivers/net/fjes/fjes_main.c b/drivers/net/fjes/fjes_main.c
index 3c0c120..87b2474 100644
--- a/drivers/net/fjes/fjes_main.c
+++ b/drivers/net/fjes/fjes_main.c
@@ -290,6 +290,7 @@ static int fjes_close(struct net_device *netdev)
 {
 	struct fjes_adapter *adapter = netdev_priv(netdev);
 	struct fjes_hw *hw = &adapter->hw;
+	unsigned long flags;
 	int epidx;
 
 	netif_tx_stop_all_queues(netdev);
@@ -299,13 +300,18 @@ static int fjes_close(struct net_device *netdev)
 
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
 
@@ -330,6 +336,7 @@ static int fjes_setup_resources(struct fjes_adapter *adapter)
 	struct net_device *netdev = adapter->netdev;
 	struct ep_share_mem_info *buf_pair;
 	struct fjes_hw *hw = &adapter->hw;
+	unsigned long flags;
 	int result;
 	int epidx;
 
@@ -371,8 +378,10 @@ static int fjes_setup_resources(struct fjes_adapter *adapter)
 
 		buf_pair = &hw->ep_shm_info[epidx];
 
+		spin_lock_irqsave(&hw->rx_status_lock, flags);
 		fjes_hw_setup_epbuf(&buf_pair->tx, netdev->dev_addr,
 				    netdev->mtu);
+		spin_unlock_irqrestore(&hw->rx_status_lock, flags);
 
 		if (fjes_hw_epid_is_same_zone(hw, epidx)) {
 			mutex_lock(&hw->hw_info.lock);
@@ -402,6 +411,7 @@ static void fjes_free_resources(struct fjes_adapter *adapter)
 	struct ep_share_mem_info *buf_pair;
 	struct fjes_hw *hw = &adapter->hw;
 	bool reset_flag = false;
+	unsigned long flags;
 	int result;
 	int epidx;
 
@@ -418,8 +428,10 @@ static void fjes_free_resources(struct fjes_adapter *adapter)
 
 		buf_pair = &hw->ep_shm_info[epidx];
 
+		spin_lock_irqsave(&hw->rx_status_lock, flags);
 		fjes_hw_setup_epbuf(&buf_pair->tx,
 				    netdev->dev_addr, netdev->mtu);
+		spin_unlock_irqrestore(&hw->rx_status_lock, flags);
 
 		clear_bit(epidx, &hw->txrx_stop_req_bit);
 	}
@@ -766,6 +778,7 @@ static int fjes_change_mtu(struct net_device *netdev, int new_mtu)
 	struct fjes_adapter *adapter = netdev_priv(netdev);
 	bool running = netif_running(netdev);
 	struct fjes_hw *hw = &adapter->hw;
+	unsigned long flags;
 	int ret = -EINVAL;
 	int idx, epidx;
 
@@ -784,12 +797,15 @@ static int fjes_change_mtu(struct net_device *netdev, int new_mtu)
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
@@ -803,23 +819,25 @@ static int fjes_change_mtu(struct net_device *netdev, int new_mtu)
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
@@ -866,6 +884,7 @@ static void fjes_txrx_stop_req_irq(struct fjes_adapter *adapter,
 {
 	struct fjes_hw *hw = &adapter->hw;
 	enum ep_partner_status status;
+	unsigned long flags;
 
 	status = fjes_hw_get_partner_ep_status(hw, src_epid);
 	switch (status) {
@@ -875,8 +894,10 @@ static void fjes_txrx_stop_req_irq(struct fjes_adapter *adapter,
 		break;
 	case EP_PARTNER_WAITING:
 		if (src_epid < hw->my_epid) {
+			spin_lock_irqsave(&hw->rx_status_lock, flags);
 			hw->ep_shm_info[src_epid].tx.info->v1i.rx_status |=
 				FJES_RX_STOP_REQ_DONE;
+			spin_unlock_irqrestore(&hw->rx_status_lock, flags);
 
 			clear_bit(src_epid, &hw->txrx_stop_req_bit);
 			set_bit(src_epid, &adapter->unshare_watch_bitmask);
@@ -902,14 +923,17 @@ static void fjes_stop_req_irq(struct fjes_adapter *adapter, int src_epid)
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
@@ -1042,13 +1066,17 @@ static int fjes_poll(struct napi_struct *napi, int budget)
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
@@ -1106,13 +1134,17 @@ static int fjes_poll(struct napi_struct *napi, int budget)
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
@@ -1281,6 +1313,7 @@ static void fjes_watch_unshare_task(struct work_struct *work)
 	int max_epid, my_epid, epidx;
 	int stop_req, stop_req_done;
 	ulong unshare_watch_bitmask;
+	unsigned long flags;
 	int wait_time = 0;
 	int is_shared;
 	int ret;
@@ -1333,8 +1366,10 @@ static void fjes_watch_unshare_task(struct work_struct *work)
 			}
 			mutex_unlock(&hw->hw_info.lock);
 
+			spin_lock_irqsave(&hw->rx_status_lock, flags);
 			fjes_hw_setup_epbuf(&hw->ep_shm_info[epidx].tx,
 					    netdev->dev_addr, netdev->mtu);
+			spin_unlock_irqrestore(&hw->rx_status_lock, flags);
 
 			clear_bit(epidx, &hw->txrx_stop_req_bit);
 			clear_bit(epidx, &unshare_watch_bitmask);
@@ -1372,9 +1407,12 @@ static void fjes_watch_unshare_task(struct work_struct *work)
 				}
 				mutex_unlock(&hw->hw_info.lock);
 
+				spin_lock_irqsave(&hw->rx_status_lock, flags);
 				fjes_hw_setup_epbuf(
 					&hw->ep_shm_info[epidx].tx,
 					netdev->dev_addr, netdev->mtu);
+				spin_unlock_irqrestore(&hw->rx_status_lock,
+						       flags);
 
 				clear_bit(epidx, &hw->txrx_stop_req_bit);
 				clear_bit(epidx, &unshare_watch_bitmask);
@@ -1382,8 +1420,11 @@ static void fjes_watch_unshare_task(struct work_struct *work)
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
