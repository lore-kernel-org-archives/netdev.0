From: Hayes Wang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH net 2/2] r8152: fix rx issue for runtime suspend
Date: Tue, 10 Jan 2017 17:04:07 +0800
Message-ID: <1394712342-15778-231-Taiwan-albertk@realtek.com>
References: <1394712342-15778-229-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Hayes Wang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
To: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1394712342-15778-229-Taiwan-albertk-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Pause the rx and make sure the rx fifo is empty when the autosuspend
occurs.

If the rx data comes when the driver is canceling the rx urb, the host
controller would stop getting the data from the device and continue
it after next rx urb is submitted. That is, one continuing data is
split into two different urb buffers. That let the driver take the
data as a rx descriptor, and unexpected behavior happens.

Signed-off-by: Hayes Wang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
---
 drivers/net/usb/r8152.c | 31 ++++++++++++++++++++++++++++---
 1 file changed, 28 insertions(+), 3 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index c5e6d88..be41856 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -3582,17 +3582,42 @@ static int rtl8152_rumtime_suspend(struct r8152 *tp)
 	int ret = 0;
 
 	if (netif_running(netdev) && test_bit(WORK_ENABLE, &tp->flags)) {
+		u32 rcr = 0;
+
 		if (delay_autosuspend(tp)) {
 			ret = -EBUSY;
 			goto out1;
 		}
 
+		if (netif_carrier_ok(netdev)) {
+			u32 ocp_data;
+
+			rcr = ocp_read_dword(tp, MCU_TYPE_PLA, PLA_RCR);
+			ocp_data = rcr & ~RCR_ACPT_ALL;
+			ocp_write_dword(tp, MCU_TYPE_PLA, PLA_RCR, ocp_data);
+			rxdy_gated_en(tp, true);
+			ocp_data = ocp_read_byte(tp, MCU_TYPE_PLA,
+						 PLA_OOB_CTRL);
+			if (!(ocp_data & RXFIFO_EMPTY)) {
+				rxdy_gated_en(tp, false);
+				ocp_write_dword(tp, MCU_TYPE_PLA, PLA_RCR, rcr);
+				ret = -EBUSY;
+				goto out1;
+			}
+		}
+
 		clear_bit(WORK_ENABLE, &tp->flags);
 		usb_kill_urb(tp->intr_urb);
-		napi_disable(&tp->napi);
-		rtl_stop_rx(tp);
+
 		tp->rtl_ops.autosuspend_en(tp, true);
-		napi_enable(&tp->napi);
+
+		if (netif_carrier_ok(netdev)) {
+			napi_disable(&tp->napi);
+			rtl_stop_rx(tp);
+			rxdy_gated_en(tp, false);
+			ocp_write_dword(tp, MCU_TYPE_PLA, PLA_RCR, rcr);
+			napi_enable(&tp->napi);
+		}
 	}
 
 	set_bit(SELECTIVE_SUSPEND, &tp->flags);
-- 
2.7.4

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
