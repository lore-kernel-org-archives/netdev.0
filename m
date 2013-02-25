From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH] b43: Fix lockdep splat on module unload
Date: Mon, 25 Feb 2013 10:09:24 -0600
Message-ID: <1361808564-22684-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org, Stable <stable@vger.kernel.org>
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f169.google.com ([209.85.214.169]:47741 "EHLO
	mail-ob0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759931Ab3BYQJo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Feb 2013 11:09:44 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On unload, b43 produces a lockdep warning that can be summarized in the
following way:

 ======================================================
 [ INFO: possible circular locking dependency detected ]
 3.8.0-wl+ #117 Not tainted
 -------------------------------------------------------
 modprobe/5557 is trying to acquire lock:
  ((&wl->firmware_load)){+.+.+.}, at: [<ffffffff81062160>] flush_work+0x0/0x2a0

 but task is already holding lock:
  (rtnl_mutex){+.+.+.}, at: [<ffffffff813bd7d2>] rtnl_lock+0x12/0x20

 which lock already depends on the new lock.
 [ INFO: possible circular locking dependency detected ]
 ======================================================

The full output is available at http://lkml.indiana.edu/hypermail/linux/kernel/1302.3/00060.html.
To summarize, commit 6b6fa58 added a 'cancel_work_sync(&wl->firmware_load)'
call in the wrong place.

The fix is to move the cancel_work_sync() call to b43_bcma_remove() and
b43_ssb_remove(). Thanks to Johannes Berg and Michael Buesch for help in
diagnosing the log output.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
Cc: Stable <stable@vger.kernel.org> [V3.5+]
---
 drivers/net/wireless/b43/main.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/wireless/b43/main.c b/drivers/net/wireless/b43/main.c
index 806e34c..0568273 100644
--- a/drivers/net/wireless/b43/main.c
+++ b/drivers/net/wireless/b43/main.c
@@ -4214,7 +4214,6 @@ redo:
 	mutex_unlock(&wl->mutex);
 	cancel_delayed_work_sync(&dev->periodic_work);
 	cancel_work_sync(&wl->tx_work);
-	cancel_work_sync(&wl->firmware_load);
 	mutex_lock(&wl->mutex);
 	dev = wl->current_dev;
 	if (!dev || b43_status(dev) < B43_STAT_STARTED) {
@@ -5434,6 +5433,7 @@ static void b43_bcma_remove(struct bcma_device *core)
 	/* We must cancel any work here before unregistering from ieee80211,
 	 * as the ieee80211 unreg will destroy the workqueue. */
 	cancel_work_sync(&wldev->restart_work);
+	cancel_work_sync(&wl->firmware_load);
 
 	B43_WARN_ON(!wl);
 	if (!wldev->fw.ucode.data)
@@ -5510,6 +5510,7 @@ static void b43_ssb_remove(struct ssb_device *sdev)
 	/* We must cancel any work here before unregistering from ieee80211,
 	 * as the ieee80211 unreg will destroy the workqueue. */
 	cancel_work_sync(&wldev->restart_work);
+	cancel_work_sync(&wl->firmware_load);
 
 	B43_WARN_ON(!wl);
 	if (!wldev->fw.ucode.data)
-- 
1.8.1.4
