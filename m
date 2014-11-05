From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next] r8152: disable the tasklet by default
Date: Wed, 5 Nov 2014 10:17:02 +0800
Message-ID: <1394712342-15778-83-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtits2.realtek.com ([60.250.210.242]:57453 "EHLO
	rtits2.realtek.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752037AbaKECRW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Nov 2014 21:17:22 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Let the tasklet only be enabled after open(), and be disabled for
the other situation. The tasklet is only necessary after open() for
tx/rx, so it could be disabled by default.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index 8ded08e..fd41675 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -2943,6 +2943,8 @@ static int rtl8152_open(struct net_device *netdev)
 		netif_warn(tp, ifup, netdev, "intr_urb submit failed: %d\n",
 			   res);
 		free_all_mem(tp);
+	} else {
+		tasklet_enable(&tp->tl);
 	}
 
 	mutex_unlock(&tp->control);
@@ -2958,6 +2960,7 @@ static int rtl8152_close(struct net_device *netdev)
 	struct r8152 *tp = netdev_priv(netdev);
 	int res = 0;
 
+	tasklet_disable(&tp->tl);
 	clear_bit(WORK_ENABLE, &tp->flags);
 	usb_kill_urb(tp->intr_urb);
 	cancel_delayed_work_sync(&tp->schedule);
@@ -2975,9 +2978,7 @@ static int rtl8152_close(struct net_device *netdev)
 		 */
 		rtl_runtime_suspend_enable(tp, false);
 
-		tasklet_disable(&tp->tl);
 		tp->rtl_ops.down(tp);
-		tasklet_enable(&tp->tl);
 
 		mutex_unlock(&tp->control);
 
@@ -3887,12 +3888,15 @@ static int rtl8152_probe(struct usb_interface *intf,
 	else
 		device_set_wakeup_enable(&udev->dev, false);
 
+	tasklet_disable(&tp->tl);
+
 	netif_info(tp, probe, netdev, "%s\n", DRIVER_VERSION);
 
 	return 0;
 
 out1:
 	usb_set_intfdata(intf, NULL);
+	tasklet_kill(&tp->tl);
 out:
 	free_netdev(netdev);
 	return ret;
-- 
1.9.3
