From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next v3 3/3] r8152: check RTL8152_UNPLUG and netif_running before autoresume
Date: Wed, 12 Nov 2014 10:05:05 +0800
Message-ID: <1394712342-15778-94-Taiwan-albertk@realtek.com>
References: <1394712342-15778-79-Taiwan-albertk@realtek.com>
 <1394712342-15778-91-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394712342-15778-91-Taiwan-albertk@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If the device is unplugged or !netif_running(), the workqueue
doesn't need to wake the device, and could return directly.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index ad9dd7d..0a30fd3 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -2857,15 +2857,18 @@ static void rtl_work_func_t(struct work_struct *work)
 {
 	struct r8152 *tp = container_of(work, struct r8152, schedule.work);
 
+	/* If the device is unplugged or !netif_running(), the workqueue
+	 * doesn't need to wake the device, and could return directly.
+	 */
+	if (test_bit(RTL8152_UNPLUG, &tp->flags) || !netif_running(tp->netdev))
+		return;
+
 	if (usb_autopm_get_interface(tp->intf) < 0)
 		return;
 
 	if (!test_bit(WORK_ENABLE, &tp->flags))
 		goto out1;
 
-	if (test_bit(RTL8152_UNPLUG, &tp->flags))
-		goto out1;
-
 	if (!mutex_trylock(&tp->control)) {
 		schedule_delayed_work(&tp->schedule, 0);
 		goto out1;
-- 
1.9.3
