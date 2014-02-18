From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next 10/14] r8152: support runtime suspend
Date: Tue, 18 Feb 2014 21:49:07 +0800
Message-ID: <1392731351-25502-11-git-send-email-hayeswang@realtek.com>
References: <1392731351-25502-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtits2.realtek.com ([60.250.210.242]:48410 "EHLO
	rtits2.realtek.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755595AbaBRNuE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Feb 2014 08:50:04 -0500
In-Reply-To: <1392731351-25502-1-git-send-email-hayeswang@realtek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Support runtime suspend for RTL8152 and RTL8153.

Move tx_bottom() from tasklet to delayed_work. That avoids to
transmit tx packets after calling autosuspend.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 181 ++++++++++++++++++++++++++++++++++++++++++------
 1 file changed, 158 insertions(+), 23 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index 5d520be..f303549 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -445,6 +445,7 @@ enum rtl8152_flags {
 	RTL8152_SET_RX_MODE,
 	WORK_ENABLE,
 	RTL8152_LINK_CHG,
+	SELECTIVE_SUSPEND,
 	PHY_RESET,
 };
 
@@ -877,11 +878,21 @@ static u16 sram_read(struct r8152 *tp, u16 addr)
 static int read_mii_word(struct net_device *netdev, int phy_id, int reg)
 {
 	struct r8152 *tp = netdev_priv(netdev);
+	int ret;
 
 	if (phy_id != R8152_PHY_ID)
 		return -EINVAL;
 
-	return r8152_mdio_read(tp, reg);
+	ret = usb_autopm_get_interface(tp->intf);
+	if (ret < 0)
+		goto out;
+
+	ret = r8152_mdio_read(tp, reg);
+
+	usb_autopm_put_interface(tp->intf);
+
+out:
+	return ret;
 }
 
 static
@@ -892,7 +903,12 @@ void write_mii_word(struct net_device *netdev, int phy_id, int reg, int val)
 	if (phy_id != R8152_PHY_ID)
 		return;
 
+	if (usb_autopm_get_interface(tp->intf) < 0)
+		return;
+
 	r8152_mdio_write(tp, reg, val);
+
+	usb_autopm_put_interface(tp->intf);
 }
 
 static
@@ -978,6 +994,8 @@ static void read_bulk_callback(struct urb *urb)
 	if (!netif_carrier_ok(netdev))
 		return;
 
+	usb_mark_last_busy(tp->udev);
+
 	switch (status) {
 	case 0:
 		if (urb->actual_length < ETH_ZLEN)
@@ -1045,6 +1063,8 @@ static void write_bulk_callback(struct urb *urb)
 	list_add_tail(&agg->list, &tp->tx_free);
 	spin_unlock_irqrestore(&tp->tx_lock, flags);
 
+	usb_autopm_put_interface_async(tp->intf);
+
 	if (!netif_carrier_ok(tp->netdev))
 		return;
 
@@ -1055,7 +1075,7 @@ static void write_bulk_callback(struct urb *urb)
 		return;
 
 	if (!skb_queue_empty(&tp->tx_queue))
-		tasklet_schedule(&tp->tl);
+		schedule_delayed_work(&tp->schedule, 0);
 }
 
 static void intr_callback(struct urb *urb)
@@ -1313,7 +1333,7 @@ static int r8152_tx_agg_fill(struct r8152 *tp, struct tx_agg *agg)
 {
 	struct sk_buff_head skb_head, *tx_queue = &tp->tx_queue;
 	unsigned long flags;
-	int remain;
+	int remain, ret;
 	u8 *tx_data;
 
 	__skb_queue_head_init(&skb_head);
@@ -1361,19 +1381,28 @@ static int r8152_tx_agg_fill(struct r8152 *tp, struct tx_agg *agg)
 		spin_unlock_irqrestore(&tx_queue->lock, flags);
 	}
 
-	netif_tx_lock(tp->netdev);
+	netif_tx_lock_bh(tp->netdev);
 
 	if (netif_queue_stopped(tp->netdev) &&
 	    skb_queue_len(&tp->tx_queue) < tp->tx_qlen)
 		netif_wake_queue(tp->netdev);
 
-	netif_tx_unlock(tp->netdev);
+	netif_tx_unlock_bh(tp->netdev);
+
+	ret = usb_autopm_get_interface(tp->intf);
+	if (ret < 0)
+		goto out_tx_fill;
 
 	usb_fill_bulk_urb(agg->urb, tp->udev, usb_sndbulkpipe(tp->udev, 2),
 			  agg->head, (int)(tx_data - (u8 *)agg->head),
 			  (usb_complete_t)write_bulk_callback, agg);
 
-	return usb_submit_urb(agg->urb, GFP_ATOMIC);
+	ret = usb_submit_urb(agg->urb, GFP_KERNEL);
+	if (ret < 0)
+		usb_autopm_put_interface(tp->intf);
+
+out_tx_fill:
+	return ret;
 }
 
 static void rx_bottom(struct r8152 *tp)
@@ -1511,7 +1540,6 @@ static void bottom_half(unsigned long data)
 		return;
 
 	rx_bottom(tp);
-	tx_bottom(tp);
 }
 
 static
@@ -1621,7 +1649,7 @@ static netdev_tx_t rtl8152_start_xmit(struct sk_buff *skb,
 		netif_stop_queue(netdev);
 
 	if (!list_empty(&tp->tx_free))
-		tasklet_schedule(&tp->tl);
+		schedule_delayed_work(&tp->schedule, 0);
 
 	return NETDEV_TX_OK;
 }
@@ -1876,6 +1904,25 @@ static void __rtl_set_wol(struct r8152 *tp, u32 wolopts)
 		device_set_wakeup_enable(&tp->udev->dev, false);
 }
 
+static void rtl_runtime_suspend_enable(struct r8152 *tp, bool enable)
+{
+	if (enable) {
+		u32 ocp_data;
+
+		__rtl_set_wol(tp, WAKE_ANY);
+
+		ocp_write_byte(tp, MCU_TYPE_PLA, PLA_CRWECR, CRWECR_CONFIG);
+
+		ocp_data = ocp_read_word(tp, MCU_TYPE_PLA, PLA_CONFIG34);
+		ocp_data |= LINK_OFF_WAKE_EN;
+		ocp_write_word(tp, MCU_TYPE_PLA, PLA_CONFIG34, ocp_data);
+
+		ocp_write_byte(tp, MCU_TYPE_PLA, PLA_CRWECR, CRWECR_NORAML);
+	} else {
+		__rtl_set_wol(tp, tp->saved_wolopts);
+	}
+}
+
 static void rtl_phy_reset(struct r8152 *tp)
 {
 	u16 data;
@@ -2467,6 +2514,9 @@ static void rtl_work_func_t(struct work_struct *work)
 {
 	struct r8152 *tp = container_of(work, struct r8152, schedule.work);
 
+	if (usb_autopm_get_interface(tp->intf) < 0)
+		return;
+
 	if (!test_bit(WORK_ENABLE, &tp->flags))
 		goto out1;
 
@@ -2479,12 +2529,14 @@ static void rtl_work_func_t(struct work_struct *work)
 	if (test_bit(RTL8152_SET_RX_MODE, &tp->flags))
 		_rtl8152_set_rx_mode(tp->netdev);
 
+	if (tp->speed & LINK_STATUS)
+		tx_bottom(tp);
 
 	if (test_bit(PHY_RESET, &tp->flags))
 		rtl_phy_reset(tp);
 
 out1:
-	return;
+	usb_autopm_put_interface(tp->intf);
 }
 
 static int rtl8152_open(struct net_device *netdev)
@@ -2496,6 +2548,21 @@ static int rtl8152_open(struct net_device *netdev)
 	if (res)
 		goto out;
 
+	res = usb_autopm_get_interface(tp->intf);
+	if (res < 0) {
+		free_all_mem(tp);
+		goto out;
+	}
+
+	/* The WORK_ENABLE may be set when autoresume occurs */
+	if (test_bit(WORK_ENABLE, &tp->flags)) {
+		clear_bit(WORK_ENABLE, &tp->flags);
+		usb_kill_urb(tp->intr_urb);
+		cancel_delayed_work_sync(&tp->schedule);
+		if (tp->speed & LINK_STATUS)
+			tp->rtl_ops.disable(tp);
+	}
+
 	tp->rtl_ops.up(tp);
 
 	rtl8152_set_speed(tp, AUTONEG_ENABLE,
@@ -2514,6 +2581,7 @@ static int rtl8152_open(struct net_device *netdev)
 		free_all_mem(tp);
 	}
 
+	usb_autopm_put_interface(tp->intf);
 
 out:
 	return res;
@@ -2528,9 +2596,26 @@ static int rtl8152_close(struct net_device *netdev)
 	usb_kill_urb(tp->intr_urb);
 	cancel_delayed_work_sync(&tp->schedule);
 	netif_stop_queue(netdev);
-	tasklet_disable(&tp->tl);
-	tp->rtl_ops.down(tp);
-	tasklet_enable(&tp->tl);
+
+	res = usb_autopm_get_interface(tp->intf);
+	if (res < 0) {
+		rtl_drop_queued_tx(tp);
+	} else {
+		/*
+		 * The autosuspend may have been enabled and wouldn't
+		 * be disable when autoresume occurs, because the
+		 * netif_running() would be false.
+		 */
+		if (test_bit(SELECTIVE_SUSPEND, &tp->flags)) {
+			rtl_runtime_suspend_enable(tp, false);
+			clear_bit(SELECTIVE_SUSPEND, &tp->flags);
+		}
+
+		tasklet_disable(&tp->tl);
+		tp->rtl_ops.down(tp);
+		tasklet_enable(&tp->tl);
+		usb_autopm_put_interface(tp->intf);
+	}
 
 	free_all_mem(tp);
 
@@ -2684,15 +2769,22 @@ static int rtl8152_suspend(struct usb_interface *intf, pm_message_t message)
 {
 	struct r8152 *tp = usb_get_intfdata(intf);
 
-	netif_device_detach(tp->netdev);
+	if (PMSG_IS_AUTO(message))
+		set_bit(SELECTIVE_SUSPEND, &tp->flags);
+	else
+		netif_device_detach(tp->netdev);
 
 	if (netif_running(tp->netdev)) {
 		clear_bit(WORK_ENABLE, &tp->flags);
 		usb_kill_urb(tp->intr_urb);
 		cancel_delayed_work_sync(&tp->schedule);
-		tasklet_disable(&tp->tl);
-		tp->rtl_ops.down(tp);
-		tasklet_enable(&tp->tl);
+		if (test_bit(SELECTIVE_SUSPEND, &tp->flags)) {
+			rtl_runtime_suspend_enable(tp, true);
+		} else {
+			tasklet_disable(&tp->tl);
+			tp->rtl_ops.down(tp);
+			tasklet_enable(&tp->tl);
+		}
 	}
 
 	return 0;
@@ -2702,13 +2794,23 @@ static int rtl8152_resume(struct usb_interface *intf)
 {
 	struct r8152 *tp = usb_get_intfdata(intf);
 
-	tp->rtl_ops.init(tp);
-	netif_device_attach(tp->netdev);
+	if (!test_bit(SELECTIVE_SUSPEND, &tp->flags)) {
+		tp->rtl_ops.init(tp);
+		netif_device_attach(tp->netdev);
+	}
+
 	if (netif_running(tp->netdev)) {
-		tp->rtl_ops.up(tp);
-		rtl8152_set_speed(tp, AUTONEG_ENABLE,
+		if (test_bit(SELECTIVE_SUSPEND, &tp->flags)) {
+			rtl_runtime_suspend_enable(tp, false);
+			clear_bit(SELECTIVE_SUSPEND, &tp->flags);
+			if (tp->speed & LINK_STATUS)
+				tp->rtl_ops.disable(tp);
+		} else {
+			tp->rtl_ops.up(tp);
+			rtl8152_set_speed(tp, AUTONEG_ENABLE,
 				tp->mii.supports_gmii ? SPEED_1000 : SPEED_100,
 				DUPLEX_FULL);
+		}
 		tp->speed = 0;
 		netif_carrier_off(tp->netdev);
 		set_bit(WORK_ENABLE, &tp->flags);
@@ -2722,18 +2824,31 @@ static void rtl8152_get_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 {
 	struct r8152 *tp = netdev_priv(dev);
 
+	if (usb_autopm_get_interface(tp->intf) < 0)
+		return;
+
 	wol->supported = WAKE_ANY;
 	wol->wolopts = __rtl_get_wol(tp);
+
+	usb_autopm_put_interface(tp->intf);
 }
 
 static int rtl8152_set_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 {
 	struct r8152 *tp = netdev_priv(dev);
+	int ret;
+
+	ret = usb_autopm_get_interface(tp->intf);
+	if (ret < 0)
+		goto out_set_wol;
 
 	__rtl_set_wol(tp, wol->wolopts);
 	tp->saved_wolopts = wol->wolopts & WAKE_ANY;
 
-	return 0;
+	usb_autopm_put_interface(tp->intf);
+
+out_set_wol:
+	return ret;
 }
 
 static void rtl8152_get_drvinfo(struct net_device *netdev,
@@ -2760,8 +2875,18 @@ int rtl8152_get_settings(struct net_device *netdev, struct ethtool_cmd *cmd)
 static int rtl8152_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
 	struct r8152 *tp = netdev_priv(dev);
+	int ret;
+
+	ret = usb_autopm_get_interface(tp->intf);
+	if (ret < 0)
+		goto out;
 
-	return rtl8152_set_speed(tp, cmd->autoneg, cmd->speed, cmd->duplex);
+	ret = rtl8152_set_speed(tp, cmd->autoneg, cmd->speed, cmd->duplex);
+
+	usb_autopm_put_interface(tp->intf);
+
+out:
+	return ret;
 }
 
 static struct ethtool_ops ops = {
@@ -2777,7 +2902,11 @@ static int rtl8152_ioctl(struct net_device *netdev, struct ifreq *rq, int cmd)
 {
 	struct r8152 *tp = netdev_priv(netdev);
 	struct mii_ioctl_data *data = if_mii(rq);
-	int res = 0;
+	int res;
+
+	res = usb_autopm_get_interface(tp->intf);
+	if (res < 0)
+		goto out;
 
 	switch (cmd) {
 	case SIOCGMIIPHY:
@@ -2800,6 +2929,9 @@ static int rtl8152_ioctl(struct net_device *netdev, struct ifreq *rq, int cmd)
 		res = -EOPNOTSUPP;
 	}
 
+	usb_autopm_put_interface(tp->intf);
+
+out:
 	return res;
 }
 
@@ -2962,6 +3094,8 @@ static int rtl8152_probe(struct usb_interface *intf,
 	tp->mii.phy_id = R8152_PHY_ID;
 	tp->mii.supports_gmii = 0;
 
+	intf->needs_remote_wakeup = 1;
+
 	r8152b_get_version(tp);
 	tp->rtl_ops.init(tp);
 	set_ethernet_addr(tp);
@@ -3023,6 +3157,7 @@ static struct usb_driver rtl8152_driver = {
 	.suspend =	rtl8152_suspend,
 	.resume =	rtl8152_resume,
 	.reset_resume =	rtl8152_resume,
+	.supports_autosuspend = 1,
 };
 
 module_usb_driver(rtl8152_driver);
-- 
1.8.4.2
