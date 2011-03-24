From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-2.6 2011-03-24
Date: Thu, 24 Mar 2011 13:46:06 -0400
Message-ID: <20110324174606.GB2503@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dave,

A few more fixes intended for 2.6.39...

This includes an iwlagn fix where we were checking an address insted
of the value stored there in a wait_event_timeout (oops!), an ath9k
fix for an invalid memory access, another ath9k fix for a regression
that could cause a stuck tx queue, and an orinoco fix to zero-out an
invalid pointer to prevent a resulting invalid pointer dereference.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 8c64b4cc0201cf05b218ea3271a2abb4f86acb7b:

  Merge branch 'sfc-2.6.39' of git://git.kernel.org/pub/scm/linux/kernel/git/bwh/sfc-2.6 (2011-03-23 15:56:02 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git master

Johannes Berg (1):
      iwlagn: fix error in command waiting

Senthil Balasubramanian (2):
      ath9k: Fix kernel panic caused by invalid rate index access.
      ath9k: Fix TX queue stuck issue.

armadefuego@gmail.com (1):
      orinoco: Clear dangling pointer on hardware busy

 drivers/net/wireless/ath/ath9k/main.c      |    2 ++
 drivers/net/wireless/ath/ath9k/rc.c        |    2 +-
 drivers/net/wireless/iwlwifi/iwl-agn-lib.c |    2 +-
 drivers/net/wireless/orinoco/cfg.c         |    3 +++
 4 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/ath/ath9k/main.c b/drivers/net/wireless/ath/ath9k/main.c
index 115f162..5248257 100644
--- a/drivers/net/wireless/ath/ath9k/main.c
+++ b/drivers/net/wireless/ath/ath9k/main.c
@@ -2160,6 +2160,8 @@ static void ath9k_flush(struct ieee80211_hw *hw, bool drop)
 	if (!ath_drain_all_txq(sc, false))
 		ath_reset(sc, false);
 
+	ieee80211_wake_queues(hw);
+
 out:
 	ieee80211_queue_delayed_work(hw, &sc->tx_complete_work, 0);
 	mutex_unlock(&sc->mutex);
diff --git a/drivers/net/wireless/ath/ath9k/rc.c b/drivers/net/wireless/ath/ath9k/rc.c
index 960d717..a3241cd 100644
--- a/drivers/net/wireless/ath/ath9k/rc.c
+++ b/drivers/net/wireless/ath/ath9k/rc.c
@@ -1328,7 +1328,7 @@ static void ath_tx_status(void *priv, struct ieee80211_supported_band *sband,
 
 	hdr = (struct ieee80211_hdr *)skb->data;
 	fc = hdr->frame_control;
-	for (i = 0; i < IEEE80211_TX_MAX_RATES; i++) {
+	for (i = 0; i < sc->hw->max_rates; i++) {
 		struct ieee80211_tx_rate *rate = &tx_info->status.rates[i];
 		if (!rate->count)
 			break;
diff --git a/drivers/net/wireless/iwlwifi/iwl-agn-lib.c b/drivers/net/wireless/iwlwifi/iwl-agn-lib.c
index 2003c1d..08ccb94 100644
--- a/drivers/net/wireless/iwlwifi/iwl-agn-lib.c
+++ b/drivers/net/wireless/iwlwifi/iwl-agn-lib.c
@@ -2265,7 +2265,7 @@ signed long iwlagn_wait_notification(struct iwl_priv *priv,
 	int ret;
 
 	ret = wait_event_timeout(priv->_agn.notif_waitq,
-				 &wait_entry->triggered,
+				 wait_entry->triggered,
 				 timeout);
 
 	spin_lock_bh(&priv->_agn.notif_wait_lock);
diff --git a/drivers/net/wireless/orinoco/cfg.c b/drivers/net/wireless/orinoco/cfg.c
index 09fae2f..736bbb9 100644
--- a/drivers/net/wireless/orinoco/cfg.c
+++ b/drivers/net/wireless/orinoco/cfg.c
@@ -153,6 +153,9 @@ static int orinoco_scan(struct wiphy *wiphy, struct net_device *dev,
 	priv->scan_request = request;
 
 	err = orinoco_hw_trigger_scan(priv, request->ssids);
+	/* On error the we aren't processing the request */
+	if (err)
+		priv->scan_request = NULL;
 
 	return err;
 }
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
