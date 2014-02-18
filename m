From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next 07/14] r8152: combine PHY reset with set_speed
Date: Tue, 18 Feb 2014 21:49:04 +0800
Message-ID: <1392731351-25502-8-git-send-email-hayeswang@realtek.com>
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

PHY reset is necessary after some hw settings. However, it would
cause the linking down, and so does the set_speed function. Combine
the PHY reset with set_speed function. That could reduce the frequency
of linking down and accessing the PHY register.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 57 ++++++++++++++++++++++++++++++++++++++-----------
 1 file changed, 45 insertions(+), 12 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index c7bae39..b3155da 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -436,6 +436,7 @@ enum rtl8152_flags {
 	RTL8152_SET_RX_MODE,
 	WORK_ENABLE,
 	RTL8152_LINK_CHG,
+	PHY_RESET,
 };
 
 /* Define these values to match your device */
@@ -1796,6 +1797,29 @@ static void r8152_power_cut_en(struct r8152 *tp, bool enable)
 
 }
 
+static void rtl_phy_reset(struct r8152 *tp)
+{
+	u16 data;
+	int i;
+
+	clear_bit(PHY_RESET, &tp->flags);
+
+	data = r8152_mdio_read(tp, MII_BMCR);
+
+	/* don't reset again before the previous one complete */
+	if (data & BMCR_RESET)
+		return;
+
+	data |= BMCR_RESET;
+	r8152_mdio_write(tp, MII_BMCR, data);
+
+	for (i = 0; i < 50; i++) {
+		msleep(20);
+		if ((r8152_mdio_read(tp, MII_BMCR) & BMCR_RESET) == 0)
+			break;
+	}
+}
+
 static void rtl_clear_bp(struct r8152 *tp)
 {
 	ocp_write_dword(tp, MCU_TYPE_PLA, PLA_BP_0, 0);
@@ -1854,6 +1878,7 @@ static void r8152b_hw_phy_cfg(struct r8152 *tp)
 	}
 
 	r8152b_disable_aldps(tp);
+	set_bit(PHY_RESET, &tp->flags);
 }
 
 static void r8152b_exit_oob(struct r8152 *tp)
@@ -2042,6 +2067,8 @@ static void r8153_hw_phy_cfg(struct r8152 *tp)
 	data = sram_read(tp, SRAM_10M_AMP2);
 	data |= AMP_DN;
 	sram_write(tp, SRAM_10M_AMP2, data);
+
+	set_bit(PHY_RESET, &tp->flags);
 }
 
 static void r8153_u1u2en(struct r8152 *tp, bool enable)
@@ -2295,12 +2322,26 @@ static int rtl8152_set_speed(struct r8152 *tp, u8 autoneg, u16 speed, u8 duplex)
 		bmcr = BMCR_ANENABLE | BMCR_ANRESTART;
 	}
 
+	if (test_bit(PHY_RESET, &tp->flags))
+		bmcr |= BMCR_RESET;
+
 	if (tp->mii.supports_gmii)
 		r8152_mdio_write(tp, MII_CTRL1000, gbcr);
 
 	r8152_mdio_write(tp, MII_ADVERTISE, anar);
 	r8152_mdio_write(tp, MII_BMCR, bmcr);
 
+	if (test_bit(PHY_RESET, &tp->flags)) {
+		int i;
+
+		clear_bit(PHY_RESET, &tp->flags);
+		for (i = 0; i < 50; i++) {
+			msleep(20);
+			if ((r8152_mdio_read(tp, MII_BMCR) & BMCR_RESET) == 0)
+				break;
+		}
+	}
+
 out:
 
 	return ret;
@@ -2364,6 +2405,10 @@ static void rtl_work_func_t(struct work_struct *work)
 	if (test_bit(RTL8152_SET_RX_MODE, &tp->flags))
 		_rtl8152_set_rx_mode(tp->netdev);
 
+
+	if (test_bit(PHY_RESET, &tp->flags))
+		rtl_phy_reset(tp);
+
 out1:
 	return;
 }
@@ -2459,7 +2504,6 @@ static void r8152b_enable_fc(struct r8152 *tp)
 static void r8152b_init(struct r8152 *tp)
 {
 	u32 ocp_data;
-	int i;
 
 	rtl_clear_bp(tp);
 
@@ -2491,14 +2535,6 @@ static void r8152b_init(struct r8152 *tp)
 	r8152b_enable_aldps(tp);
 	r8152b_enable_fc(tp);
 
-	r8152_mdio_write(tp, MII_BMCR, BMCR_RESET | BMCR_ANENABLE |
-				       BMCR_ANRESTART);
-	for (i = 0; i < 100; i++) {
-		udelay(100);
-		if (!(r8152_mdio_read(tp, MII_BMCR) & BMCR_RESET))
-			break;
-	}
-
 	/* enable rx aggregation */
 	ocp_data = ocp_read_word(tp, MCU_TYPE_USB, USB_USB_CTRL);
 	ocp_data &= ~RX_AGG_DISABLE;
@@ -2569,9 +2605,6 @@ static void r8153_init(struct r8152 *tp)
 	r8153_enable_eee(tp);
 	r8153_enable_aldps(tp);
 	r8152b_enable_fc(tp);
-
-	r8152_mdio_write(tp, MII_BMCR, BMCR_RESET | BMCR_ANENABLE |
-				       BMCR_ANRESTART);
 }
 
 static int rtl8152_suspend(struct usb_interface *intf, pm_message_t message)
-- 
1.8.4.2
