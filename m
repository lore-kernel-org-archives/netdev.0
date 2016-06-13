From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next 2/3] r8152: move the setting for the default speed
Date: Mon, 13 Jun 2016 17:49:37 +0800
Message-ID: <1394712342-15778-177-Taiwan-albertk@realtek.com>
References: <1394712342-15778-175-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtits2.realtek.com ([60.250.210.242]:44632 "EHLO
	rtits2.realtek.com.tw" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964862AbcFMJuM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2016 05:50:12 -0400
In-Reply-To: <1394712342-15778-175-Taiwan-albertk@realtek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move calling set_speed() from open() to rtl_hw_phy_work_func_t().
Then, we would set the default speed only for first initialization
or after resuming.

Besides, the set_speed() could handle the flag of PHY_RESET which
would be set in rtl_ops.hw_phy_cfg().

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 11 ++++-------
 1 file changed, 4 insertions(+), 7 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index 46fe9a7..dcdc4fa 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -3051,6 +3051,10 @@ static void rtl_hw_phy_work_func_t(struct work_struct *work)
 
 	tp->rtl_ops.hw_phy_cfg(tp);
 
+	rtl8152_set_speed(tp, AUTONEG_ENABLE,
+			  tp->mii.supports_gmii ? SPEED_1000 : SPEED_100,
+			  DUPLEX_FULL);
+
 	mutex_unlock(&tp->control);
 
 	usb_autopm_put_interface(tp->intf);
@@ -3104,9 +3108,6 @@ static int rtl8152_open(struct net_device *netdev)
 
 	tp->rtl_ops.up(tp);
 
-	rtl8152_set_speed(tp, AUTONEG_ENABLE,
-			  tp->mii.supports_gmii ? SPEED_1000 : SPEED_100,
-			  DUPLEX_FULL);
 	netif_carrier_off(netdev);
 	netif_start_queue(netdev);
 	set_bit(WORK_ENABLE, &tp->flags);
@@ -3549,10 +3550,6 @@ static int rtl8152_resume(struct usb_interface *intf)
 			napi_enable(&tp->napi);
 		} else {
 			tp->rtl_ops.up(tp);
-			rtl8152_set_speed(tp, AUTONEG_ENABLE,
-					  tp->mii.supports_gmii ?
-					  SPEED_1000 : SPEED_100,
-					  DUPLEX_FULL);
 			netif_carrier_off(tp->netdev);
 			set_bit(WORK_ENABLE, &tp->flags);
 		}
-- 
2.4.11
