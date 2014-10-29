From: Hayes Wang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH net 2/3] r8152: reset tp->speed before autoresuming in open function
Date: Wed, 29 Oct 2014 11:12:16 +0800
Message-ID: <1394712342-15778-71-Taiwan-albertk@realtek.com>
References: <1394712342-15778-69-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Hayes Wang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
To: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1394712342-15778-69-Taiwan-albertk-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

If (tp->speed & LINK_STATUS) is not zero, the rtl8152_resume()
would call rtl_start_rx() before enabling the tx/rx. Avoid this
by resetting it to zero.

Signed-off-by: Hayes Wang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
---
 drivers/net/usb/r8152.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index a17ca58..f224231 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -2891,6 +2891,9 @@ static int rtl8152_open(struct net_device *netdev)
 	if (res)
 		goto out;
 
+	/* set speed to 0 to avoid autoresume try to submit rx */
+	tp->speed = 0;
+
 	res = usb_autopm_get_interface(tp->intf);
 	if (res < 0) {
 		free_all_mem(tp);
@@ -2904,6 +2907,8 @@ static int rtl8152_open(struct net_device *netdev)
 		clear_bit(WORK_ENABLE, &tp->flags);
 		usb_kill_urb(tp->intr_urb);
 		cancel_delayed_work_sync(&tp->schedule);
+
+		/* disable the tx/rx, if the workqueue has enabled them. */
 		if (tp->speed & LINK_STATUS)
 			tp->rtl_ops.disable(tp);
 	}
-- 
1.9.3

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
