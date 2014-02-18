From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next 02/14] r8152: add three functions
Date: Tue, 18 Feb 2014 21:48:59 +0800
Message-ID: <1392731351-25502-3-git-send-email-hayeswang@realtek.com>
References: <1392731351-25502-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1392731351-25502-1-git-send-email-hayeswang@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Replace some codes with the following three functions.
 - rtl_drop_queued_tx
 - rxdy_gated_en
 - r8152_power_cut_en

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 99 +++++++++++++++++++++++++------------------------
 1 file changed, 51 insertions(+), 48 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index f042a85..2d5e761 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -1478,6 +1478,17 @@ int r8152_submit_rx(struct r8152 *tp, struct rx_agg *agg, gfp_t mem_flags)
 	return usb_submit_urb(agg->urb, mem_flags);
 }
 
+static void rtl_drop_queued_tx(struct r8152 *tp)
+{
+	struct net_device_stats *stats = &tp->netdev->stats;
+	struct sk_buff *skb;
+
+	while ((skb = skb_dequeue(&tp->tx_queue))) {
+		dev_kfree_skb(skb);
+		stats->tx_dropped++;
+	}
+}
+
 static void rtl8152_tx_timeout(struct net_device *netdev)
 {
 	struct r8152 *tp = netdev_priv(netdev);
@@ -1613,6 +1624,18 @@ static void rtl_set_eee_plus(struct r8152 *tp)
 	}
 }
 
+static void rxdy_gated_en(struct r8152 *tp, bool enable)
+{
+	u32 ocp_data;
+
+	ocp_data = ocp_read_word(tp, MCU_TYPE_PLA, PLA_MISC_1);
+	if (enable)
+		ocp_data |= RXDY_GATED_EN;
+	else
+		ocp_data &= ~RXDY_GATED_EN;
+	ocp_write_word(tp, MCU_TYPE_PLA, PLA_MISC_1, ocp_data);
+}
+
 static int rtl_enable(struct r8152 *tp)
 {
 	u32 ocp_data;
@@ -1624,9 +1647,7 @@ static int rtl_enable(struct r8152 *tp)
 	ocp_data |= CR_RE | CR_TE;
 	ocp_write_byte(tp, MCU_TYPE_PLA, PLA_CR, ocp_data);
 
-	ocp_data = ocp_read_word(tp, MCU_TYPE_PLA, PLA_MISC_1);
-	ocp_data &= ~RXDY_GATED_EN;
-	ocp_write_word(tp, MCU_TYPE_PLA, PLA_MISC_1, ocp_data);
+	rxdy_gated_en(tp, false);
 
 	INIT_LIST_HEAD(&tp->rx_done);
 	ret = 0;
@@ -1681,8 +1702,6 @@ static int rtl8153_enable(struct r8152 *tp)
 
 static void rtl8152_disable(struct r8152 *tp)
 {
-	struct net_device_stats *stats = rtl8152_get_stats(tp->netdev);
-	struct sk_buff *skb;
 	u32 ocp_data;
 	int i;
 
@@ -1690,17 +1709,12 @@ static void rtl8152_disable(struct r8152 *tp)
 	ocp_data &= ~RCR_ACPT_ALL;
 	ocp_write_dword(tp, MCU_TYPE_PLA, PLA_RCR, ocp_data);
 
-	while ((skb = skb_dequeue(&tp->tx_queue))) {
-		dev_kfree_skb(skb);
-		stats->tx_dropped++;
-	}
+	rtl_drop_queued_tx(tp);
 
 	for (i = 0; i < RTL8152_MAX_TX; i++)
 		usb_kill_urb(tp->tx_info[i].urb);
 
-	ocp_data = ocp_read_word(tp, MCU_TYPE_PLA, PLA_MISC_1);
-	ocp_data |= RXDY_GATED_EN;
-	ocp_write_word(tp, MCU_TYPE_PLA, PLA_MISC_1, ocp_data);
+	rxdy_gated_en(tp, true);
 
 	for (i = 0; i < 1000; i++) {
 		ocp_data = ocp_read_byte(tp, MCU_TYPE_PLA, PLA_OOB_CTRL);
@@ -1721,6 +1735,23 @@ static void rtl8152_disable(struct r8152 *tp)
 	rtl8152_nic_reset(tp);
 }
 
+static void r8152_power_cut_en(struct r8152 *tp, bool enable)
+{
+	u32 ocp_data;
+
+	ocp_data = ocp_read_word(tp, MCU_TYPE_USB, USB_UPS_CTRL);
+	if (enable)
+		ocp_data |= POWER_CUT;
+	else
+		ocp_data &= ~POWER_CUT;
+	ocp_write_word(tp, MCU_TYPE_USB, USB_UPS_CTRL, ocp_data);
+
+	ocp_data = ocp_read_word(tp, MCU_TYPE_USB, USB_PM_CTRL_STATUS);
+	ocp_data &= ~RESUME_INDICATE;
+	ocp_write_word(tp, MCU_TYPE_USB, USB_PM_CTRL_STATUS, ocp_data);
+
+}
+
 static void rtl_clear_bp(struct r8152 *tp)
 {
 	ocp_write_dword(tp, MCU_TYPE_PLA, PLA_BP_0, 0);
@@ -1783,9 +1814,7 @@ static void r8152b_exit_oob(struct r8152 *tp)
 	ocp_data &= ~RCR_ACPT_ALL;
 	ocp_write_dword(tp, MCU_TYPE_PLA, PLA_RCR, ocp_data);
 
-	ocp_data = ocp_read_word(tp, MCU_TYPE_PLA, PLA_MISC_1);
-	ocp_data |= RXDY_GATED_EN;
-	ocp_write_word(tp, MCU_TYPE_PLA, PLA_MISC_1, ocp_data);
+	rxdy_gated_en(tp, true);
 
 	ocp_write_byte(tp, MCU_TYPE_PLA, PLA_CRWECR, CRWECR_NORAML);
 	ocp_write_byte(tp, MCU_TYPE_PLA, PLA_CR, 0x00);
@@ -1909,9 +1938,7 @@ static void r8152b_enter_oob(struct r8152 *tp)
 
 	ocp_write_byte(tp, MCU_TYPE_PLA, PLA_CONFIG5, LAN_WAKE_EN);
 
-	ocp_data = ocp_read_word(tp, MCU_TYPE_PLA, PLA_MISC_1);
-	ocp_data &= ~RXDY_GATED_EN;
-	ocp_write_word(tp, MCU_TYPE_PLA, PLA_MISC_1, ocp_data);
+	rxdy_gated_en(tp, false);
 
 	ocp_data = ocp_read_dword(tp, MCU_TYPE_PLA, PLA_RCR);
 	ocp_data |= RCR_APM | RCR_AM | RCR_AB;
@@ -2007,10 +2034,7 @@ static void r8153_first_init(struct r8152 *tp)
 	u32 ocp_data;
 	int i;
 
-	ocp_data = ocp_read_word(tp, MCU_TYPE_PLA, PLA_MISC_1);
-	ocp_data |= RXDY_GATED_EN;
-	ocp_write_word(tp, MCU_TYPE_PLA, PLA_MISC_1, ocp_data);
-
+	rxdy_gated_en(tp, true);
 	r8153_teredo_off(tp);
 
 	ocp_data = ocp_read_dword(tp, MCU_TYPE_PLA, PLA_RCR);
@@ -2125,9 +2149,7 @@ static void r8153_enter_oob(struct r8152 *tp)
 
 	ocp_write_byte(tp, MCU_TYPE_PLA, PLA_CONFIG5, LAN_WAKE_EN);
 
-	ocp_data = ocp_read_word(tp, MCU_TYPE_PLA, PLA_MISC_1);
-	ocp_data &= ~RXDY_GATED_EN;
-	ocp_write_word(tp, MCU_TYPE_PLA, PLA_MISC_1, ocp_data);
+	rxdy_gated_en(tp, false);
 
 	ocp_data = ocp_read_dword(tp, MCU_TYPE_PLA, PLA_RCR);
 	ocp_data |= RCR_APM | RCR_AM | RCR_AB;
@@ -2231,12 +2253,7 @@ out:
 
 static void rtl8152_down(struct r8152 *tp)
 {
-	u32	ocp_data;
-
-	ocp_data = ocp_read_word(tp, MCU_TYPE_USB, USB_UPS_CTRL);
-	ocp_data &= ~POWER_CUT;
-	ocp_write_word(tp, MCU_TYPE_USB, USB_UPS_CTRL, ocp_data);
-
+	r8152_power_cut_en(tp, false);
 	r8152b_disable_aldps(tp);
 	r8152b_enter_oob(tp);
 	r8152b_enable_aldps(tp);
@@ -2399,13 +2416,8 @@ static void r8152b_init(struct r8152 *tp)
 
 	r8152b_hw_phy_cfg(tp);
 
-	ocp_data = ocp_read_word(tp, MCU_TYPE_USB, USB_UPS_CTRL);
-	ocp_data &= ~POWER_CUT;
-	ocp_write_word(tp, MCU_TYPE_USB, USB_UPS_CTRL, ocp_data);
+	r8152_power_cut_en(tp, false);
 
-	ocp_data = ocp_read_word(tp, MCU_TYPE_USB, USB_PM_CTRL_STATUS);
-	ocp_data &= ~RESUME_INDICATE;
-	ocp_write_word(tp, MCU_TYPE_USB, USB_PM_CTRL_STATUS, ocp_data);
 
 	r8152b_exit_oob(tp);
 
@@ -2659,17 +2671,8 @@ static void r8152b_get_version(struct r8152 *tp)
 
 static void rtl8152_unload(struct r8152 *tp)
 {
-	u32	ocp_data;
-
-	if (tp->version != RTL_VER_01) {
-		ocp_data = ocp_read_word(tp, MCU_TYPE_USB, USB_UPS_CTRL);
-		ocp_data |= POWER_CUT;
-		ocp_write_word(tp, MCU_TYPE_USB, USB_UPS_CTRL, ocp_data);
-	}
-
-	ocp_data = ocp_read_word(tp, MCU_TYPE_USB, USB_PM_CTRL_STATUS);
-	ocp_data &= ~RESUME_INDICATE;
-	ocp_write_word(tp, MCU_TYPE_USB, USB_PM_CTRL_STATUS, ocp_data);
+	if (tp->version != RTL_VER_01)
+		r8152_power_cut_en(tp, true);
 }
 
 static void rtl8153_unload(struct r8152 *tp)
-- 
1.8.4.2
