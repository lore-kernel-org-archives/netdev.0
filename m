From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 1/3 RESUBMIT] b43: Fix lockdep splat
Date: Sat, 11 Jan 2014 13:54:52 -0600
Message-ID: <1389470092-13098-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org,
	Stanislaw Gruszka <gruszka@redhat.com>, netdev@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	Stable <stable@vger.kernel.org>
To: linville@tuxdriver.com
Return-path: <stable-owner@vger.kernel.org>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stanislaw Gruszka <gruszka@redhat.com>

In https://bugzilla.kernel.org/show_bug.cgi?id=67561, a locking dependency is reported
when b43 is used with hostapd, and rfkill is used to kill the radio output.

The lockdep splat (in part) is as follows:

======================================================
[ INFO: possible circular locking dependency detected ]
3.12.0 #1 Not tainted
-------------------------------------------------------
rfkill/10040 is trying to acquire lock:
 (rtnl_mutex){+.+.+.}, at: [<ffffffff8146f282>] rtnl_lock+0x12/0x20

but task is already holding lock:
 (rfkill_global_mutex){+.+.+.}, at: [<ffffffffa04832ca>] rfkill_fop_write+0x6a/0x170 [rfkill]

--snip--

Chain exists of:
  rtnl_mutex --> misc_mtx --> rfkill_global_mutex

The fix is to move the initialization of the hardware random number generator
outside the code range covered by the rtnl_mutex.

Reported-by: yury <urykhy@gmail.com>
Tested-by: yury <urykhy@gmail.com>
Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
Cc: Stable <stable@vger.kernel.org>
---
This patch was resubmitted because there was a typo in Stanislaw's address.

Larry
---
drivers/net/wireless/b43/main.c | 17 +++++++++++------
 1 file changed, 11 insertions(+), 6 deletions(-)

diff --git a/drivers/net/wireless/b43/main.c b/drivers/net/wireless/b43/main.c
index ccd24f0a..86b2030 100644
--- a/drivers/net/wireless/b43/main.c
+++ b/drivers/net/wireless/b43/main.c
@@ -2424,6 +2424,7 @@ error:
 
 static int b43_one_core_attach(struct b43_bus_dev *dev, struct b43_wl *wl);
 static void b43_one_core_detach(struct b43_bus_dev *dev);
+static int b43_rng_init(struct b43_wl *wl);
 
 static void b43_request_firmware(struct work_struct *work)
 {
@@ -2475,6 +2476,10 @@ start_ieee80211:
 		goto err_one_core_detach;
 	wl->hw_registred = true;
 	b43_leds_register(wl->current_dev);
+
+	/* Register HW RNG driver */
+	b43_rng_init(wl);
+
 	goto out;
 
 err_one_core_detach:
@@ -4636,9 +4641,6 @@ static void b43_wireless_core_exit(struct b43_wldev *dev)
 	if (!dev || b43_status(dev) != B43_STAT_INITIALIZED)
 		return;
 
-	/* Unregister HW RNG driver */
-	b43_rng_exit(dev->wl);
-
 	b43_set_status(dev, B43_STAT_UNINIT);
 
 	/* Stop the microcode PSM. */
@@ -4795,9 +4797,6 @@ static int b43_wireless_core_init(struct b43_wldev *dev)
 
 	b43_set_status(dev, B43_STAT_INITIALIZED);
 
-	/* Register HW RNG driver */
-	b43_rng_init(dev->wl);
-
 out:
 	return err;
 
@@ -5464,6 +5463,9 @@ static void b43_bcma_remove(struct bcma_device *core)
 
 	b43_one_core_detach(wldev->dev);
 
+	/* Unregister HW RNG driver */
+	b43_rng_exit(wl);
+
 	b43_leds_unregister(wl);
 
 	ieee80211_free_hw(wl->hw);
@@ -5541,6 +5543,9 @@ static void b43_ssb_remove(struct ssb_device *sdev)
 
 	b43_one_core_detach(dev);
 
+	/* Unregister HW RNG driver */
+	b43_rng_exit(wl);
+
 	if (list_empty(&wl->devlist)) {
 		b43_leds_unregister(wl);
 		/* Last core on the chip unregistered.
-- 
1.8.4
