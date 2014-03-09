From: Emil Goode <emilgoode@gmail.com>
Subject: [PATCH 1/2] brcmsmac: fix deadlock on missing firmware
Date: Sun,  9 Mar 2014 21:06:51 +0100
Message-ID: <1394395612-3510-1-git-send-email-emilgoode@gmail.com>
Cc: linux-wireless@vger.kernel.org, brcm80211-dev-list@broadcom.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Emil Goode <emilgoode@gmail.com>
To: Brett Rudley <brudley@broadcom.com>,
	Arend van Spriel <arend@broadcom.com>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>,
	Hante Meuleman <meuleman@broadcom.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Hauke Mehrtens <hauke@hauke-m.de>,
	Johannes Berg <johannes.berg@intel.com>,
	"Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When brcm80211 firmware is not installed networking hangs.
A deadlock happens because we call ieee80211_unregister_hw()
from the .start callback of struct ieee80211_ops. When .start
is called we are under rtnl lock and ieee80211_unregister_hw()
tries to take it again.

Function call stack:

dev_change_flags()
	__dev_change_flags()
		__dev_open()
			ASSERT_RTNL() <-- Assert rtnl lock
			ops->ndo_open()

.ndo_open = ieee80211_open,

ieee80211_open()
	ieee80211_do_open()
		drv_start()
			local->ops->start()

.start = brcms_ops_start,

brcms_ops_start()
	brcms_remove()
		ieee80211_unregister_hw()
			rtnl_lock() <-- Here we deadlock

Introduced by:
commit 25b5632fb35ca61b8ae3eee235edcdc2883f7a5e
("brcmsmac: request firmware in .start() callback")

This patch fixes the bug by removing the call to brcms_remove()
and moves the brcms_request_fw() call to the top of the .start
callback to not initiate anything unless firmware is installed.

Signed-off-by: Emil Goode <emilgoode@gmail.com>
---
 drivers/net/wireless/brcm80211/brcmsmac/mac80211_if.c |   14 ++++++--------
 1 file changed, 6 insertions(+), 8 deletions(-)

diff --git a/drivers/net/wireless/brcm80211/brcmsmac/mac80211_if.c b/drivers/net/wireless/brcm80211/brcmsmac/mac80211_if.c
index 925034b..93598cd 100644
--- a/drivers/net/wireless/brcm80211/brcmsmac/mac80211_if.c
+++ b/drivers/net/wireless/brcm80211/brcmsmac/mac80211_if.c
@@ -426,6 +426,12 @@ static int brcms_ops_start(struct ieee80211_hw *hw)
 	bool blocked;
 	int err;
 
+	if (!wl->ucode.bcm43xx_bomminor) {
+		err = brcms_request_fw(wl, wl->wlc->hw->d11core);
+		if (err)
+			return -ENOENT;
+	}
+
 	ieee80211_wake_queues(hw);
 	spin_lock_bh(&wl->lock);
 	blocked = brcms_rfkill_set_hw_state(wl);
@@ -433,14 +439,6 @@ static int brcms_ops_start(struct ieee80211_hw *hw)
 	if (!blocked)
 		wiphy_rfkill_stop_polling(wl->pub->ieee_hw->wiphy);
 
-	if (!wl->ucode.bcm43xx_bomminor) {
-		err = brcms_request_fw(wl, wl->wlc->hw->d11core);
-		if (err) {
-			brcms_remove(wl->wlc->hw->d11core);
-			return -ENOENT;
-		}
-	}
-
 	spin_lock_bh(&wl->lock);
 	/* avoid acknowledging frames before a non-monitor device is added */
 	wl->mute_tx = true;
-- 
1.7.10.4
