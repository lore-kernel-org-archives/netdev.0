From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net] r8152: return -EBUSY for runtime suspend
Date: Fri, 17 Oct 2014 16:55:08 +0800
Message-ID: <1394712342-15778-65-Taiwan-albertk@realtek.com>
References: <87zjcvgn1x.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87zjcvgn1x.fsf@nemi.mork.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove calling cancel_delayed_work_sync() for runtime suspend,
because it would cause dead lock. Instead, return -EBUSY to
avoid the device enters suspending if the net is running and
the delayed work is pending or running. The delayed work would
try to wake up the device later, so the suspending is not
necessary.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 22 +++++++++++++++-------
 1 file changed, 15 insertions(+), 7 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index 864159e..e3d84c3 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -3189,31 +3189,39 @@ static void r8153_init(struct r8152 *tp)
 static int rtl8152_suspend(struct usb_interface *intf, pm_message_t message)
 {
 	struct r8152 *tp = usb_get_intfdata(intf);
+	struct net_device *netdev = tp->netdev;
+	int ret = 0;
 
 	mutex_lock(&tp->control);
 
-	if (PMSG_IS_AUTO(message))
+	if (PMSG_IS_AUTO(message)) {
+		if (netif_running(netdev) && work_busy(&tp->schedule.work)) {
+			ret = -EBUSY;
+			goto out1;
+		}
+
 		set_bit(SELECTIVE_SUSPEND, &tp->flags);
-	else
-		netif_device_detach(tp->netdev);
+	} else {
+		netif_device_detach(netdev);
+	}
 
-	if (netif_running(tp->netdev)) {
+	if (netif_running(netdev)) {
 		clear_bit(WORK_ENABLE, &tp->flags);
 		usb_kill_urb(tp->intr_urb);
-		cancel_delayed_work_sync(&tp->schedule);
 		tasklet_disable(&tp->tl);
 		if (test_bit(SELECTIVE_SUSPEND, &tp->flags)) {
 			rtl_stop_rx(tp);
 			rtl_runtime_suspend_enable(tp, true);
 		} else {
+			cancel_delayed_work_sync(&tp->schedule);
 			tp->rtl_ops.down(tp);
 		}
 		tasklet_enable(&tp->tl);
 	}
-
+out1:
 	mutex_unlock(&tp->control);
 
-	return 0;
+	return ret;
 }
 
 static int rtl8152_resume(struct usb_interface *intf)
-- 
1.9.3
