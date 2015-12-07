From: Peter Wu <peter@lekensteyn.nl>
Subject: [PATCH] r8152: fix lockup when runtime PM is enabled
Date: Mon,  7 Dec 2015 17:58:40 +0100
Message-ID: <1449507520-10671-1-git-send-email-peter@lekensteyn.nl>
Cc: Lu Baolu <baolu.lu@linux.intel.com>
To: "David S . Miller" <davem@davemloft.net>,
	hayeswang <hayeswang@realtek.com>, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When an interface is brought up which was previously suspended (via
runtime PM), it would hang. This happens because napi_disable is called
before napi_enable.

Solve this by avoiding napi_disable before the device is fully up.

While at it, remove WORK_ENABLE check from rtl8152_open (introduced with
the original change) because it cannot happen:

 - After this patch, runtime resume will not set it during rtl8152_open.
 - When link is up, rtl8152_open is not called.
 - When link is down during system/auto suspend/resume, it is not set.

Fixes: 41cec84cf285 ("r8152: don't enable napi before rx ready")
Link: https://lkml.kernel.org/r/20151205105912.GA1766@al
Signed-off-by: Peter Wu <peter@lekensteyn.nl>
---
 drivers/net/usb/r8152.c | 23 +++++++----------------
 1 file changed, 7 insertions(+), 16 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index d9427ca..b8b083e 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -3067,17 +3067,6 @@ static int rtl8152_open(struct net_device *netdev)
 
 	mutex_lock(&tp->control);
 
-	/* The WORK_ENABLE may be set when autoresume occurs */
-	if (test_bit(WORK_ENABLE, &tp->flags)) {
-		clear_bit(WORK_ENABLE, &tp->flags);
-		usb_kill_urb(tp->intr_urb);
-		cancel_delayed_work_sync(&tp->schedule);
-
-		/* disable the tx/rx, if the workqueue has enabled them. */
-		if (netif_carrier_ok(netdev))
-			tp->rtl_ops.disable(tp);
-	}
-
 	tp->rtl_ops.up(tp);
 
 	rtl8152_set_speed(tp, AUTONEG_ENABLE,
@@ -3516,11 +3505,13 @@ static int rtl8152_resume(struct usb_interface *intf)
 		if (test_bit(SELECTIVE_SUSPEND, &tp->flags)) {
 			rtl_runtime_suspend_enable(tp, false);
 			clear_bit(SELECTIVE_SUSPEND, &tp->flags);
-			napi_disable(&tp->napi);
-			set_bit(WORK_ENABLE, &tp->flags);
-			if (netif_carrier_ok(tp->netdev))
-				rtl_start_rx(tp);
-			napi_enable(&tp->napi);
+			if (tp->netdev->flags & IFF_UP) {
+				napi_disable(&tp->napi);
+				set_bit(WORK_ENABLE, &tp->flags);
+				if (netif_carrier_ok(tp->netdev))
+					rtl_start_rx(tp);
+				napi_enable(&tp->napi);
+			}
 		} else {
 			tp->rtl_ops.up(tp);
 			rtl8152_set_speed(tp, AUTONEG_ENABLE,
-- 
2.6.3
