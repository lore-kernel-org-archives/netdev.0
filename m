From: Nicholas Mc Guire <der.herr-kA1LtwSENNE@public.gmane.org>
Subject: [PATCH RFC] wlcore: match wait_for_completion_timeout return type
Date: Mon, 26 Jan 2015 07:26:12 +0100
Message-ID: <1422253572-19396-1-git-send-email-der.herr@hofr.at>
Cc: Eliad Peller <eliad-Ix1uc/W3ht7QT0dZR+AlfA@public.gmane.org>, Arik Nemtsov <arik-Ix1uc/W3ht7QT0dZR+AlfA@public.gmane.org>,
	Kobi L <kobi.lev100-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Nicholas Mc Guire <der.herr-kA1LtwSENNE@public.gmane.org>
To: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

return type of wait_for_completion_timeout is unsigned long not int, this
patch adds an appropriate return type and assignment.

Signed-off-by: Nicholas Mc Guire <der.herr-kA1LtwSENNE@public.gmane.org>
---

The return type of wait_for_completion_timeout is unsigned long not
int. This patch adds a separate variable of proper type for handling
of the wait_for_completion_timeout.

The alternative would be to fold it into the if condition and not use
a separate variable like so:

	if (!pending) {
		if (!wait_for_completion_timeout( &compl,
				msecs_to_jiffies(WL1271_WAKEUP_TIMEOUT)) {
			wl1271_error("ELP wakeup timeout!");		    
			wl12xx_queue_recovery_work(wl);
			ret = -ETIMEDOUT;
			goto err;
		}
	}

not sure if this or the below solution is preferable.

Patch was compile tested only for x86_64_defconfig + CONFIG_WL_TI=y, 
CONFIG_WLCORE=m

Patch is against 3.19.0-rc5 -next-20150123

 drivers/net/wireless/ti/wlcore/ps.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/ti/wlcore/ps.c b/drivers/net/wireless/ti/wlcore/ps.c
index 4cd316e..d5f918a4 100644
--- a/drivers/net/wireless/ti/wlcore/ps.c
+++ b/drivers/net/wireless/ti/wlcore/ps.c
@@ -109,6 +109,7 @@ int wl1271_ps_elp_wakeup(struct wl1271 *wl)
 	DECLARE_COMPLETION_ONSTACK(compl);
 	unsigned long flags;
 	int ret;
+	unsigned long timeout;
 	unsigned long start_time = jiffies;
 	bool pending = false;
 
@@ -145,9 +146,9 @@ int wl1271_ps_elp_wakeup(struct wl1271 *wl)
 	}
 
 	if (!pending) {
-		ret = wait_for_completion_timeout(
+		timeout = wait_for_completion_timeout(
 			&compl, msecs_to_jiffies(WL1271_WAKEUP_TIMEOUT));
-		if (ret == 0) {
+		if (timeout == 0) {
 			wl1271_error("ELP wakeup timeout!");
 			wl12xx_queue_recovery_work(wl);
 			ret = -ETIMEDOUT;
-- 
1.7.10.4

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
