From: Hayes Wang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH net-next 1/2] r8152: use test_and_clear_bit
Date: Thu, 7 Jan 2016 17:51:11 +0800
Message-ID: <1394712342-15778-172-Taiwan-albertk@realtek.com>
References: <1394712342-15778-171-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Hayes Wang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
To: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1394712342-15778-171-Taiwan-albertk-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Replace test_bit() followed by clear_bit() with test_and_clear_bit().

Signed-off-by: Hayes Wang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
---
 drivers/net/usb/r8152.c | 20 ++++++--------------
 1 file changed, 6 insertions(+), 14 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index 975e917..4f0bb67 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -1938,7 +1938,6 @@ static void _rtl8152_set_rx_mode(struct net_device *netdev)
 	__le32 tmp[2];
 	u32 ocp_data;
 
-	clear_bit(RTL8152_SET_RX_MODE, &tp->flags);
 	netif_stop_queue(netdev);
 	ocp_data = ocp_read_dword(tp, MCU_TYPE_PLA, PLA_RCR);
 	ocp_data &= ~RCR_ACPT_ALL;
@@ -2424,8 +2423,6 @@ static void rtl_phy_reset(struct r8152 *tp)
 	u16 data;
 	int i;
 
-	clear_bit(PHY_RESET, &tp->flags);
-
 	data = r8152_mdio_read(tp, MII_BMCR);
 
 	/* don't reset again before the previous one complete */
@@ -2884,10 +2881,9 @@ static int rtl8152_set_speed(struct r8152 *tp, u8 autoneg, u16 speed, u8 duplex)
 	r8152_mdio_write(tp, MII_ADVERTISE, anar);
 	r8152_mdio_write(tp, MII_BMCR, bmcr);
 
-	if (test_bit(PHY_RESET, &tp->flags)) {
+	if (test_and_clear_bit(PHY_RESET, &tp->flags)) {
 		int i;
 
-		clear_bit(PHY_RESET, &tp->flags);
 		for (i = 0; i < 50; i++) {
 			msleep(20);
 			if ((r8152_mdio_read(tp, MII_BMCR) & BMCR_RESET) == 0)
@@ -2896,7 +2892,6 @@ static int rtl8152_set_speed(struct r8152 *tp, u8 autoneg, u16 speed, u8 duplex)
 	}
 
 out:
-
 	return ret;
 }
 
@@ -2983,7 +2978,6 @@ static void set_carrier(struct r8152 *tp)
 	struct net_device *netdev = tp->netdev;
 	u8 speed;
 
-	clear_bit(RTL8152_LINK_CHG, &tp->flags);
 	speed = rtl8152_get_speed(tp);
 
 	if (speed & LINK_STATUS) {
@@ -3026,20 +3020,18 @@ static void rtl_work_func_t(struct work_struct *work)
 		goto out1;
 	}
 
-	if (test_bit(RTL8152_LINK_CHG, &tp->flags))
+	if (test_and_clear_bit(RTL8152_LINK_CHG, &tp->flags))
 		set_carrier(tp);
 
-	if (test_bit(RTL8152_SET_RX_MODE, &tp->flags))
+	if (test_and_clear_bit(RTL8152_SET_RX_MODE, &tp->flags))
 		_rtl8152_set_rx_mode(tp->netdev);
 
 	/* don't schedule napi before linking */
-	if (test_bit(SCHEDULE_NAPI, &tp->flags) &&
-	    netif_carrier_ok(tp->netdev)) {
-		clear_bit(SCHEDULE_NAPI, &tp->flags);
+	if (test_and_clear_bit(SCHEDULE_NAPI, &tp->flags) &&
+	    netif_carrier_ok(tp->netdev))
 		napi_schedule(&tp->napi);
-	}
 
-	if (test_bit(PHY_RESET, &tp->flags))
+	if (test_and_clear_bit(PHY_RESET, &tp->flags))
 		rtl_phy_reset(tp);
 
 	mutex_unlock(&tp->control);
-- 
2.4.3

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
