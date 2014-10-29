From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net 1/3] r8152: clear SELECTIVE_SUSPEND when autoresuming
Date: Wed, 29 Oct 2014 11:12:15 +0800
Message-ID: <1394712342-15778-70-Taiwan-albertk@realtek.com>
References: <1394712342-15778-69-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394712342-15778-69-Taiwan-albertk@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The flag of SELECTIVE_SUSPEND should be cleared when autoresuming.
Otherwise, when the system suspend and resume occur, it may have
the wrong flow.

Besides, because the flag of SELECTIVE_SUSPEND couldn't be used
to check if the hw enables the relative feature, it should alwayes
be disabled in close().

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index e3d84c3..a17ca58 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -2955,10 +2955,7 @@ static int rtl8152_close(struct net_device *netdev)
 		 * be disable when autoresume occurs, because the
 		 * netif_running() would be false.
 		 */
-		if (test_bit(SELECTIVE_SUSPEND, &tp->flags)) {
-			rtl_runtime_suspend_enable(tp, false);
-			clear_bit(SELECTIVE_SUSPEND, &tp->flags);
-		}
+		rtl_runtime_suspend_enable(tp, false);
 
 		tasklet_disable(&tp->tl);
 		tp->rtl_ops.down(tp);
@@ -3253,6 +3250,8 @@ static int rtl8152_resume(struct usb_interface *intf)
 			set_bit(WORK_ENABLE, &tp->flags);
 		}
 		usb_submit_urb(tp->intr_urb, GFP_KERNEL);
+	} else if (test_bit(SELECTIVE_SUSPEND, &tp->flags)) {
+		clear_bit(SELECTIVE_SUSPEND, &tp->flags);
 	}
 
 	mutex_unlock(&tp->control);
-- 
1.9.3
