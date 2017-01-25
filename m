From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net 4/4] r8152: check rx after napi is enabled
Date: Wed, 25 Jan 2017 10:50:54 +0800
Message-ID: <1394712342-15778-240-Taiwan-albertk@realtek.com>
References: <1394712342-15778-236-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
        <linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394712342-15778-236-Taiwan-albertk@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Schedule the napi after napi_enable() for rx, if it is necessary.

If the rx is completed when napi is disabled, the sheduling of napi
would be lost. Then, no one handles the rx packet until next napi
is scheduled.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index f65109b..f0f55b3 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -32,7 +32,7 @@
 #define NETNEXT_VERSION		"08"
 
 /* Information for net */
-#define NET_VERSION		"7"
+#define NET_VERSION		"8"
 
 #define DRIVER_VERSION		"v1." NETNEXT_VERSION "." NET_VERSION
 #define DRIVER_AUTHOR "Realtek linux nic maintainers <nic_swsd@realtek.com>"
@@ -3561,6 +3561,9 @@ static int rtl8152_post_reset(struct usb_interface *intf)
 	netif_wake_queue(netdev);
 	usb_submit_urb(tp->intr_urb, GFP_KERNEL);
 
+	if (!list_empty(&tp->rx_done))
+		napi_schedule(&tp->napi);
+
 	return 0;
 }
 
@@ -3696,6 +3699,8 @@ static int rtl8152_resume(struct usb_interface *intf)
 				rtl_start_rx(tp);
 			napi_enable(&tp->napi);
 			clear_bit(SELECTIVE_SUSPEND, &tp->flags);
+			if (!list_empty(&tp->rx_done))
+				napi_schedule(&tp->napi);
 		} else {
 			tp->rtl_ops.up(tp);
 			netif_carrier_off(tp->netdev);
-- 
2.7.4
