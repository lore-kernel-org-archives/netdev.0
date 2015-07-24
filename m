From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net v2 3/3] r8152: don't enable napi before rx ready
Date: Fri, 24 Jul 2015 13:54:25 +0800
Message-ID: <1394712342-15778-155-Taiwan-albertk@realtek.com>
References: <1394712342-15778-148-Taiwan-albertk@realtek.com>
 <1394712342-15778-152-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394712342-15778-152-Taiwan-albertk@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adjust napi_disable() and napi_enable() to avoid r8152_poll() start
working before rx ready. Otherwise, it may have race condition for
rx_agg.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index d537c30..144dc64 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -2075,7 +2075,6 @@ static int rtl_start_rx(struct r8152 *tp)
 {
 	int i, ret = 0;
 
-	napi_disable(&tp->napi);
 	INIT_LIST_HEAD(&tp->rx_done);
 	for (i = 0; i < RTL8152_MAX_RX; i++) {
 		INIT_LIST_HEAD(&tp->rx_info[i].list);
@@ -2083,7 +2082,6 @@ static int rtl_start_rx(struct r8152 *tp)
 		if (ret)
 			break;
 	}
-	napi_enable(&tp->napi);
 
 	if (ret && ++i < RTL8152_MAX_RX) {
 		struct list_head rx_queue;
@@ -2951,8 +2949,10 @@ static void set_carrier(struct r8152 *tp)
 		if (!netif_carrier_ok(netdev)) {
 			tp->rtl_ops.enable(tp);
 			set_bit(RTL8152_SET_RX_MODE, &tp->flags);
+			napi_disable(&tp->napi);
 			netif_carrier_on(netdev);
 			rtl_start_rx(tp);
+			napi_enable(&tp->napi);
 		}
 	} else {
 		if (netif_carrier_ok(netdev)) {
@@ -3395,9 +3395,11 @@ static int rtl8152_resume(struct usb_interface *intf)
 		if (test_bit(SELECTIVE_SUSPEND, &tp->flags)) {
 			rtl_runtime_suspend_enable(tp, false);
 			clear_bit(SELECTIVE_SUSPEND, &tp->flags);
+			napi_disable(&tp->napi);
 			set_bit(WORK_ENABLE, &tp->flags);
 			if (netif_carrier_ok(tp->netdev))
 				rtl_start_rx(tp);
+			napi_enable(&tp->napi);
 		} else {
 			tp->rtl_ops.up(tp);
 			rtl8152_set_speed(tp, AUTONEG_ENABLE,
-- 
2.4.2
