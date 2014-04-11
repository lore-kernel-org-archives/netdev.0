From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net] r8152: check RTL8152_UNPLUG
Date: Fri, 11 Apr 2014 17:54:31 +0800
Message-ID: <1394712342-15778-4-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, <sejeong.na@samsung.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When the device is unplugged, the driver would try to disable the
device. Add checking the flag of RTL8152_UNPLUG to skip setting
the device when it is unplugged. This could shorten the time of
unloading the driver.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 48 ++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 48 insertions(+)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index 18e12a3..3fbfb08 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -929,6 +929,9 @@ static int read_mii_word(struct net_device *netdev, int phy_id, int reg)
 	struct r8152 *tp = netdev_priv(netdev);
 	int ret;
 
+	if (test_bit(RTL8152_UNPLUG, &tp->flags))
+		return -ENODEV;
+
 	if (phy_id != R8152_PHY_ID)
 		return -EINVAL;
 
@@ -949,6 +952,9 @@ void write_mii_word(struct net_device *netdev, int phy_id, int reg, int val)
 {
 	struct r8152 *tp = netdev_priv(netdev);
 
+	if (test_bit(RTL8152_UNPLUG, &tp->flags))
+		return;
+
 	if (phy_id != R8152_PHY_ID)
 		return;
 
@@ -1962,6 +1968,9 @@ static int rtl_enable(struct r8152 *tp)
 
 static int rtl8152_enable(struct r8152 *tp)
 {
+	if (test_bit(RTL8152_UNPLUG, &tp->flags))
+		return -ENODEV;
+
 	set_tx_qlen(tp);
 	rtl_set_eee_plus(tp);
 
@@ -1994,6 +2003,9 @@ static void r8153_set_rx_agg(struct r8152 *tp)
 
 static int rtl8153_enable(struct r8152 *tp)
 {
+	if (test_bit(RTL8152_UNPLUG, &tp->flags))
+		return -ENODEV;
+
 	set_tx_qlen(tp);
 	rtl_set_eee_plus(tp);
 	r8153_set_rx_agg(tp);
@@ -2006,6 +2018,11 @@ static void rtl8152_disable(struct r8152 *tp)
 	u32 ocp_data;
 	int i;
 
+	if (test_bit(RTL8152_UNPLUG, &tp->flags)) {
+		rtl_drop_queued_tx(tp);
+		return;
+	}
+
 	ocp_data = ocp_read_dword(tp, MCU_TYPE_PLA, PLA_RCR);
 	ocp_data &= ~RCR_ACPT_ALL;
 	ocp_write_dword(tp, MCU_TYPE_PLA, PLA_RCR, ocp_data);
@@ -2232,6 +2249,9 @@ static void r8152b_exit_oob(struct r8152 *tp)
 	u32 ocp_data;
 	int i;
 
+	if (test_bit(RTL8152_UNPLUG, &tp->flags))
+		return;
+
 	ocp_data = ocp_read_dword(tp, MCU_TYPE_PLA, PLA_RCR);
 	ocp_data &= ~RCR_ACPT_ALL;
 	ocp_write_dword(tp, MCU_TYPE_PLA, PLA_RCR, ocp_data);
@@ -2460,6 +2480,9 @@ static void r8153_first_init(struct r8152 *tp)
 	u32 ocp_data;
 	int i;
 
+	if (test_bit(RTL8152_UNPLUG, &tp->flags))
+		return;
+
 	rxdy_gated_en(tp, true);
 	r8153_teredo_off(tp);
 
@@ -2687,6 +2710,11 @@ out:
 
 static void rtl8152_down(struct r8152 *tp)
 {
+	if (test_bit(RTL8152_UNPLUG, &tp->flags)) {
+		rtl_drop_queued_tx(tp);
+		return;
+	}
+
 	r8152_power_cut_en(tp, false);
 	r8152b_disable_aldps(tp);
 	r8152b_enter_oob(tp);
@@ -2695,6 +2723,11 @@ static void rtl8152_down(struct r8152 *tp)
 
 static void rtl8153_down(struct r8152 *tp)
 {
+	if (test_bit(RTL8152_UNPLUG, &tp->flags)) {
+		rtl_drop_queued_tx(tp);
+		return;
+	}
+
 	r8153_u1u2en(tp, false);
 	r8153_power_cut_en(tp, false);
 	r8153_disable_aldps(tp);
@@ -2904,6 +2937,9 @@ static void r8152b_init(struct r8152 *tp)
 {
 	u32 ocp_data;
 
+	if (test_bit(RTL8152_UNPLUG, &tp->flags))
+		return;
+
 	if (tp->version == RTL_VER_01) {
 		ocp_data = ocp_read_word(tp, MCU_TYPE_PLA, PLA_LED_FEATURE);
 		ocp_data &= ~LED_MODE_MASK;
@@ -2939,6 +2975,9 @@ static void r8153_init(struct r8152 *tp)
 	u32 ocp_data;
 	int i;
 
+	if (test_bit(RTL8152_UNPLUG, &tp->flags))
+		return;
+
 	r8153_u1u2en(tp, false);
 
 	for (i = 0; i < 500; i++) {
@@ -3213,6 +3252,9 @@ static int rtl8152_ioctl(struct net_device *netdev, struct ifreq *rq, int cmd)
 	struct mii_ioctl_data *data = if_mii(rq);
 	int res;
 
+	if (test_bit(RTL8152_UNPLUG, &tp->flags))
+		return -ENODEV;
+
 	res = usb_autopm_get_interface(tp->intf);
 	if (res < 0)
 		goto out;
@@ -3293,12 +3335,18 @@ static void r8152b_get_version(struct r8152 *tp)
 
 static void rtl8152_unload(struct r8152 *tp)
 {
+	if (test_bit(RTL8152_UNPLUG, &tp->flags))
+		return;
+
 	if (tp->version != RTL_VER_01)
 		r8152_power_cut_en(tp, true);
 }
 
 static void rtl8153_unload(struct r8152 *tp)
 {
+	if (test_bit(RTL8152_UNPLUG, &tp->flags))
+		return;
+
 	r8153_power_cut_en(tp, true);
 }
 
-- 
1.9.0
