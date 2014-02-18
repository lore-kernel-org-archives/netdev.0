From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next 08/14] r8152: move some functions from probe to open
Date: Tue, 18 Feb 2014 21:49:05 +0800
Message-ID: <1392731351-25502-9-git-send-email-hayeswang@realtek.com>
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

Add up method for rtl_ops and asign relative functions. Move
clear_bp() and hw_phy_cfg() from init method to up method of rtl_ops.
Call rtl_ops.up() for ndo_open() and rtl_ops.down for ndo_stop().

Replace allocating the memory in probe() with in ndo_open().

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 45 +++++++++++++++++++++++++--------------------
 1 file changed, 25 insertions(+), 20 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index b3155da..828572a 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -515,6 +515,7 @@ struct r8152 {
 		void (*init)(struct r8152 *);
 		int (*enable)(struct r8152 *);
 		void (*disable)(struct r8152 *);
+		void (*up)(struct r8152 *);
 		void (*down)(struct r8152 *);
 		void (*unload)(struct r8152 *);
 	} rtl_ops;
@@ -1878,6 +1879,10 @@ static void r8152b_hw_phy_cfg(struct r8152 *tp)
 	}
 
 	r8152b_disable_aldps(tp);
+
+	rtl_clear_bp(tp);
+
+	r8152b_enable_aldps(tp);
 	set_bit(PHY_RESET, &tp->flags);
 }
 
@@ -1891,6 +1896,7 @@ static void r8152b_exit_oob(struct r8152 *tp)
 	ocp_write_dword(tp, MCU_TYPE_PLA, PLA_RCR, ocp_data);
 
 	rxdy_gated_en(tp, true);
+	r8152b_hw_phy_cfg(tp);
 
 	ocp_write_byte(tp, MCU_TYPE_PLA, PLA_CRWECR, CRWECR_NORAML);
 	ocp_write_byte(tp, MCU_TYPE_PLA, PLA_CR, 0x00);
@@ -2033,6 +2039,8 @@ static void r8153_hw_phy_cfg(struct r8152 *tp)
 		r8152_mdio_write(tp, MII_BMCR, data);
 	}
 
+	r8153_clear_bp(tp);
+
 	if (tp->version == RTL_VER_03) {
 		data = ocp_reg_read(tp, OCP_EEE_CFG);
 		data &= ~CTAP_SHORT_EN;
@@ -2418,6 +2426,12 @@ static int rtl8152_open(struct net_device *netdev)
 	struct r8152 *tp = netdev_priv(netdev);
 	int res = 0;
 
+	res = alloc_all_mem(tp);
+	if (res)
+		goto out;
+
+	tp->rtl_ops.up(tp);
+
 	rtl8152_set_speed(tp, AUTONEG_ENABLE,
 			  tp->mii.supports_gmii ? SPEED_1000 : SPEED_100,
 			  DUPLEX_FULL);
@@ -2431,9 +2445,11 @@ static int rtl8152_open(struct net_device *netdev)
 			netif_device_detach(tp->netdev);
 		netif_warn(tp, ifup, netdev, "intr_urb submit failed: %d\n",
 			   res);
+		free_all_mem(tp);
 	}
 
 
+out:
 	return res;
 }
 
@@ -2447,9 +2463,11 @@ static int rtl8152_close(struct net_device *netdev)
 	cancel_delayed_work_sync(&tp->schedule);
 	netif_stop_queue(netdev);
 	tasklet_disable(&tp->tl);
-	tp->rtl_ops.disable(tp);
+	tp->rtl_ops.down(tp);
 	tasklet_enable(&tp->tl);
 
+	free_all_mem(tp);
+
 	return res;
 }
 
@@ -2505,21 +2523,14 @@ static void r8152b_init(struct r8152 *tp)
 {
 	u32 ocp_data;
 
-	rtl_clear_bp(tp);
-
 	if (tp->version == RTL_VER_01) {
 		ocp_data = ocp_read_word(tp, MCU_TYPE_PLA, PLA_LED_FEATURE);
 		ocp_data &= ~LED_MODE_MASK;
 		ocp_write_word(tp, MCU_TYPE_PLA, PLA_LED_FEATURE, ocp_data);
 	}
 
-	r8152b_hw_phy_cfg(tp);
-
 	r8152_power_cut_en(tp, false);
 
-
-	r8152b_exit_oob(tp);
-
 	ocp_data = ocp_read_word(tp, MCU_TYPE_PLA, PLA_PHY_PWR);
 	ocp_data |= TX_10M_IDLE_EN | PFM_PWM_SWITCH;
 	ocp_write_word(tp, MCU_TYPE_PLA, PLA_PHY_PWR, ocp_data);
@@ -2568,8 +2579,6 @@ static void r8153_init(struct r8152 *tp)
 	ocp_data &= ~TIMER11_EN;
 	ocp_write_word(tp, MCU_TYPE_USB, USB_WDT11_CTRL, ocp_data);
 
-	r8153_clear_bp(tp);
-
 	ocp_data = ocp_read_word(tp, MCU_TYPE_PLA, PLA_LED_FEATURE);
 	ocp_data &= ~LED_MODE_MASK;
 	ocp_write_word(tp, MCU_TYPE_PLA, PLA_LED_FEATURE, ocp_data);
@@ -2590,8 +2599,6 @@ static void r8153_init(struct r8152 *tp)
 	r8153_power_cut_en(tp, false);
 	r8153_u1u2en(tp, true);
 
-	r8153_first_init(tp);
-
 	ocp_write_word(tp, MCU_TYPE_PLA, PLA_MAC_PWR_CTRL, ALDPS_SPDWN_RATIO);
 	ocp_write_word(tp, MCU_TYPE_PLA, PLA_MAC_PWR_CTRL2, EEE_SPDWN_RATIO);
 	ocp_write_word(tp, MCU_TYPE_PLA, PLA_MAC_PWR_CTRL3,
@@ -2618,10 +2625,10 @@ static int rtl8152_suspend(struct usb_interface *intf, pm_message_t message)
 		usb_kill_urb(tp->intr_urb);
 		cancel_delayed_work_sync(&tp->schedule);
 		tasklet_disable(&tp->tl);
+		tp->rtl_ops.down(tp);
+		tasklet_enable(&tp->tl);
 	}
 
-	tp->rtl_ops.down(tp);
-
 	return 0;
 }
 
@@ -2632,6 +2639,7 @@ static int rtl8152_resume(struct usb_interface *intf)
 	tp->rtl_ops.init(tp);
 	netif_device_attach(tp->netdev);
 	if (netif_running(tp->netdev)) {
+		tp->rtl_ops.up(tp);
 		rtl8152_set_speed(tp, AUTONEG_ENABLE,
 				tp->mii.supports_gmii ? SPEED_1000 : SPEED_100,
 				DUPLEX_FULL);
@@ -2639,7 +2647,6 @@ static int rtl8152_resume(struct usb_interface *intf)
 		netif_carrier_off(tp->netdev);
 		set_bit(WORK_ENABLE, &tp->flags);
 		usb_submit_urb(tp->intr_urb, GFP_KERNEL);
-		tasklet_enable(&tp->tl);
 	}
 
 	return 0;
@@ -2780,6 +2787,7 @@ static int rtl_ops_init(struct r8152 *tp, const struct usb_device_id *id)
 			ops->init		= r8152b_init;
 			ops->enable		= rtl8152_enable;
 			ops->disable		= rtl8152_disable;
+			ops->up			= r8152b_exit_oob;
 			ops->down		= rtl8152_down;
 			ops->unload		= rtl8152_unload;
 			ret = 0;
@@ -2788,6 +2796,7 @@ static int rtl_ops_init(struct r8152 *tp, const struct usb_device_id *id)
 			ops->init		= r8153_init;
 			ops->enable		= rtl8153_enable;
 			ops->disable		= rtl8152_disable;
+			ops->up			= r8153_first_init;
 			ops->down		= rtl8153_down;
 			ops->unload		= rtl8153_unload;
 			ret = 0;
@@ -2803,6 +2812,7 @@ static int rtl_ops_init(struct r8152 *tp, const struct usb_device_id *id)
 			ops->init		= r8153_init;
 			ops->enable		= rtl8153_enable;
 			ops->disable		= rtl8152_disable;
+			ops->up			= r8153_first_init;
 			ops->down		= rtl8153_down;
 			ops->unload		= rtl8153_unload;
 			ret = 0;
@@ -2870,10 +2880,6 @@ static int rtl8152_probe(struct usb_interface *intf,
 	tp->rtl_ops.init(tp);
 	set_ethernet_addr(tp);
 
-	ret = alloc_all_mem(tp);
-	if (ret)
-		goto out;
-
 	usb_set_intfdata(intf, tp);
 
 	ret = register_netdev(netdev);
@@ -2903,7 +2909,6 @@ static void rtl8152_disconnect(struct usb_interface *intf)
 		tasklet_kill(&tp->tl);
 		unregister_netdev(tp->netdev);
 		tp->rtl_ops.unload(tp);
-		free_all_mem(tp);
 		free_netdev(tp->netdev);
 	}
 }
-- 
1.8.4.2
