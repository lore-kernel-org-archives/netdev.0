From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net 2/2] r8152: fix the runtime suspend issues
Date: Mon, 7 Sep 2015 11:57:44 +0800
Message-ID: <1394712342-15778-168-Taiwan-albertk@realtek.com>
References: <1394712342-15778-166-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394712342-15778-166-Taiwan-albertk@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix the runtime suspend issues result from the linking change.

Case 1:
a) link down occurs.
b) driver disable tx/rx.
c) autosuspend occurs.
d) hw linking up.
e) device suspends without enabling tx/rx.
f) couldn't wake up when receiving packets.

Case 2:
a) Nway results in linking down.
b) autosuspend occurs.
c) device suspends.
d) device may not wake up when linking up.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 59 +++++++++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 57 insertions(+), 2 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index 6bb48bc..d9427ca 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -30,7 +30,7 @@
 #define NETNEXT_VERSION		"08"
 
 /* Information for net */
-#define NET_VERSION		"1"
+#define NET_VERSION		"2"
 
 #define DRIVER_VERSION		"v1." NETNEXT_VERSION "." NET_VERSION
 #define DRIVER_AUTHOR "Realtek linux nic maintainers <nic_swsd@realtek.com>"
@@ -148,6 +148,7 @@
 #define OCP_EEE_ABLE		0xa5c4
 #define OCP_EEE_ADV		0xa5d0
 #define OCP_EEE_LPABLE		0xa5d2
+#define OCP_PHY_STATE		0xa708		/* nway state for 8153 */
 #define OCP_ADC_CFG		0xbc06
 
 /* SRAM Register */
@@ -432,6 +433,10 @@
 /* OCP_DOWN_SPEED */
 #define EN_10M_BGOFF		0x0080
 
+/* OCP_PHY_STATE */
+#define TXDIS_STATE		0x01
+#define ABD_STATE		0x02
+
 /* OCP_ADC_CFG */
 #define CKADSEL_L		0x0100
 #define ADC_EN			0x0080
@@ -609,6 +614,7 @@ struct r8152 {
 		void (*unload)(struct r8152 *);
 		int (*eee_get)(struct r8152 *, struct ethtool_eee *);
 		int (*eee_set)(struct r8152 *, struct ethtool_eee *);
+		bool (*in_nway)(struct r8152 *);
 	} rtl_ops;
 
 	int intr_interval;
@@ -2946,6 +2952,32 @@ static void rtl8153_down(struct r8152 *tp)
 	r8153_enable_aldps(tp);
 }
 
+static bool rtl8152_in_nway(struct r8152 *tp)
+{
+	u16 nway_state;
+
+	ocp_write_word(tp, MCU_TYPE_PLA, PLA_OCP_GPHY_BASE, 0x2000);
+	tp->ocp_base = 0x2000;
+	ocp_write_byte(tp, MCU_TYPE_PLA, 0xb014, 0x4c);		/* phy state */
+	nway_state = ocp_read_word(tp, MCU_TYPE_PLA, 0xb01a);
+
+	/* bit 15: TXDIS_STATE, bit 14: ABD_STATE */
+	if (nway_state & 0xc000)
+		return false;
+	else
+		return true;
+}
+
+static bool rtl8153_in_nway(struct r8152 *tp)
+{
+	u16 phy_state = ocp_reg_read(tp, OCP_PHY_STATE) & 0xff;
+
+	if (phy_state == TXDIS_STATE || phy_state == ABD_STATE)
+		return false;
+	else
+		return true;
+}
+
 static void set_carrier(struct r8152 *tp)
 {
 	struct net_device *netdev = tp->netdev;
@@ -3410,6 +3442,27 @@ static int rtl8152_post_reset(struct usb_interface *intf)
 	return 0;
 }
 
+static bool delay_autosuspend(struct r8152 *tp)
+{
+	bool sw_linking = !!netif_carrier_ok(tp->netdev);
+	bool hw_linking = !!(rtl8152_get_speed(tp) & LINK_STATUS);
+
+	/* This means a linking change occurs and the driver doesn't detect it,
+	 * yet. If the driver has disabled tx/rx and hw is linking on, the
+	 * device wouldn't wake up by receiving any packet.
+	 */
+	if (work_busy(&tp->schedule.work) || sw_linking != hw_linking)
+		return true;
+
+	/* If the linking down is occurred by nway, the device may miss the
+	 * linking change event. And it wouldn't wake when linking on.
+	 */
+	if (!sw_linking && tp->rtl_ops.in_nway(tp))
+		return true;
+	else
+		return false;
+}
+
 static int rtl8152_suspend(struct usb_interface *intf, pm_message_t message)
 {
 	struct r8152 *tp = usb_get_intfdata(intf);
@@ -3419,7 +3472,7 @@ static int rtl8152_suspend(struct usb_interface *intf, pm_message_t message)
 	mutex_lock(&tp->control);
 
 	if (PMSG_IS_AUTO(message)) {
-		if (netif_running(netdev) && work_busy(&tp->schedule.work)) {
+		if (netif_running(netdev) && delay_autosuspend(tp)) {
 			ret = -EBUSY;
 			goto out1;
 		}
@@ -4049,6 +4102,7 @@ static int rtl_ops_init(struct r8152 *tp)
 		ops->unload		= rtl8152_unload;
 		ops->eee_get		= r8152_get_eee;
 		ops->eee_set		= r8152_set_eee;
+		ops->in_nway		= rtl8152_in_nway;
 		break;
 
 	case RTL_VER_03:
@@ -4063,6 +4117,7 @@ static int rtl_ops_init(struct r8152 *tp)
 		ops->unload		= rtl8153_unload;
 		ops->eee_get		= r8153_get_eee;
 		ops->eee_set		= r8153_set_eee;
+		ops->in_nway		= rtl8153_in_nway;
 		break;
 
 	default:
-- 
2.4.3
