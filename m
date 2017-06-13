From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next v2 2/2] r8152: move calling delay_autosuspend function
Date: Tue, 13 Jun 2017 15:14:40 +0800
Message-ID: <1394712342-15778-277-Taiwan-albertk@realtek.com>
References: <1394712342-15778-272-Taiwan-albertk@realtek.com>
 <1394712342-15778-275-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
        <linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394712342-15778-275-Taiwan-albertk@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Move calling delay_autosuspend() in rtl8152_runtime_suspend(). Calling
delay_autosuspend() as late as possible.

The original flows are
   1. check if the driver/device is busy now.
   2. set wake events.
   3. enter runtime suspend.

If the wake event occurs between (1) and (2), the device may miss it. Besides,
to avoid the runtime resume occurs after runtime suspend immediately, move the
checking to the end of rtl8152_runtime_suspend().

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 12 +++++-------
 1 file changed, 5 insertions(+), 7 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index 2d238b5..b916418 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -3752,13 +3752,6 @@ static int rtl8152_runtime_suspend(struct r8152 *tp)
 	if (netif_running(netdev) && test_bit(WORK_ENABLE, &tp->flags)) {
 		u32 rcr = 0;
 
-		if (delay_autosuspend(tp)) {
-			clear_bit(SELECTIVE_SUSPEND, &tp->flags);
-			smp_mb__after_atomic();
-			ret = -EBUSY;
-			goto out1;
-		}
-
 		if (netif_carrier_ok(netdev)) {
 			u32 ocp_data;
 
@@ -3792,6 +3785,11 @@ static int rtl8152_runtime_suspend(struct r8152 *tp)
 			ocp_write_dword(tp, MCU_TYPE_PLA, PLA_RCR, rcr);
 			napi_enable(napi);
 		}
+
+		if (delay_autosuspend(tp)) {
+			rtl8152_runtime_resume(tp);
+			ret = -EBUSY;
+		}
 	}
 
 out1:
-- 
2.7.4
