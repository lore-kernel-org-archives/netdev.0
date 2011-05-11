From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-2.6 2011-05-11
Date: Wed, 11 May 2011 15:27:42 -0400
Message-ID: <20110511192742.GG2490@tuxdriver.com>
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

Here are a few more late-breakers that I would like to see in 2.6.39.
The one from Luca fixes a problem that can cause devices to be unable
to (re-)associate after a disconnect.  The ath9k fix from Mohammed
fixes a WARNING, the one from Paul fixes a locking issue that can
lead to data corruption, and the one from Stanislaw fixes a crash
documented in bug 34452.  All are small and all but one are contained
within their respective drivers.

Please let me know if there are problems!

John

---

The following changes since commit 9bbc052d5e63512b0ce4e201ea97e12fba9fda82:

  Merge branch 'pablo/nf-2.6-updates' of git://1984.lsi.us.es/net-2.6 (2011-05-10 15:04:35 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git master

Luciano Coelho (1):
      mac80211: don't start the dynamic ps timer if not associated

Mohammed Shafi Shajakhan (1):
      ath9k: Fix a warning due to a queued work during S3 state

Paul Fox (1):
      libertas: fix cmdpendingq locking

Stanislaw Gruszka (1):
      iwlegacy: fix IBSS mode crashes

 drivers/net/wireless/ath/ath9k/main.c    |    8 ++++++++
 drivers/net/wireless/iwlegacy/iwl-core.c |    7 +++++++
 drivers/net/wireless/iwlegacy/iwl-dev.h  |    6 ++++++
 drivers/net/wireless/libertas/cmd.c      |    6 ++++--
 net/mac80211/tx.c                        |    4 ++++
 5 files changed, 29 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/ath/ath9k/main.c b/drivers/net/wireless/ath/ath9k/main.c
index 17d04ff..1482fa6 100644
--- a/drivers/net/wireless/ath/ath9k/main.c
+++ b/drivers/net/wireless/ath/ath9k/main.c
@@ -2141,6 +2141,8 @@ static void ath9k_set_coverage_class(struct ieee80211_hw *hw, u8 coverage_class)
 static void ath9k_flush(struct ieee80211_hw *hw, bool drop)
 {
 	struct ath_softc *sc = hw->priv;
+	struct ath_hw *ah = sc->sc_ah;
+	struct ath_common *common = ath9k_hw_common(ah);
 	int timeout = 200; /* ms */
 	int i, j;
 
@@ -2149,6 +2151,12 @@ static void ath9k_flush(struct ieee80211_hw *hw, bool drop)
 
 	cancel_delayed_work_sync(&sc->tx_complete_work);
 
+	if (sc->sc_flags & SC_OP_INVALID) {
+		ath_dbg(common, ATH_DBG_ANY, "Device not present\n");
+		mutex_unlock(&sc->mutex);
+		return;
+	}
+
 	if (drop)
 		timeout = 1;
 
diff --git a/drivers/net/wireless/iwlegacy/iwl-core.c b/drivers/net/wireless/iwlegacy/iwl-core.c
index 2b08efb..dcbb2ef 100644
--- a/drivers/net/wireless/iwlegacy/iwl-core.c
+++ b/drivers/net/wireless/iwlegacy/iwl-core.c
@@ -2155,6 +2155,13 @@ int iwl_legacy_mac_config(struct ieee80211_hw *hw, u32 changed)
 			goto set_ch_out;
 		}
 
+		if (priv->iw_mode == NL80211_IFTYPE_ADHOC &&
+		    !iwl_legacy_is_channel_ibss(ch_info)) {
+			IWL_DEBUG_MAC80211(priv, "leave - not IBSS channel\n");
+			ret = -EINVAL;
+			goto set_ch_out;
+		}
+
 		spin_lock_irqsave(&priv->lock, flags);
 
 		for_each_context(priv, ctx) {
diff --git a/drivers/net/wireless/iwlegacy/iwl-dev.h b/drivers/net/wireless/iwlegacy/iwl-dev.h
index 9ee849d..f43ac1e 100644
--- a/drivers/net/wireless/iwlegacy/iwl-dev.h
+++ b/drivers/net/wireless/iwlegacy/iwl-dev.h
@@ -1411,6 +1411,12 @@ iwl_legacy_is_channel_passive(const struct iwl_channel_info *ch)
 	return (!(ch->flags & EEPROM_CHANNEL_ACTIVE)) ? 1 : 0;
 }
 
+static inline int
+iwl_legacy_is_channel_ibss(const struct iwl_channel_info *ch)
+{
+	return (ch->flags & EEPROM_CHANNEL_IBSS) ? 1 : 0;
+}
+
 static inline void
 __iwl_legacy_free_pages(struct iwl_priv *priv, struct page *page)
 {
diff --git a/drivers/net/wireless/libertas/cmd.c b/drivers/net/wireless/libertas/cmd.c
index 7e8a658..f3ac624 100644
--- a/drivers/net/wireless/libertas/cmd.c
+++ b/drivers/net/wireless/libertas/cmd.c
@@ -1339,8 +1339,8 @@ int lbs_execute_next_command(struct lbs_private *priv)
 				    cpu_to_le16(PS_MODE_ACTION_EXIT_PS)) {
 					lbs_deb_host(
 					       "EXEC_NEXT_CMD: ignore ENTER_PS cmd\n");
-					list_del(&cmdnode->list);
 					spin_lock_irqsave(&priv->driver_lock, flags);
+					list_del(&cmdnode->list);
 					lbs_complete_command(priv, cmdnode, 0);
 					spin_unlock_irqrestore(&priv->driver_lock, flags);
 
@@ -1352,8 +1352,8 @@ int lbs_execute_next_command(struct lbs_private *priv)
 				    (priv->psstate == PS_STATE_PRE_SLEEP)) {
 					lbs_deb_host(
 					       "EXEC_NEXT_CMD: ignore EXIT_PS cmd in sleep\n");
-					list_del(&cmdnode->list);
 					spin_lock_irqsave(&priv->driver_lock, flags);
+					list_del(&cmdnode->list);
 					lbs_complete_command(priv, cmdnode, 0);
 					spin_unlock_irqrestore(&priv->driver_lock, flags);
 					priv->needtowakeup = 1;
@@ -1366,7 +1366,9 @@ int lbs_execute_next_command(struct lbs_private *priv)
 				       "EXEC_NEXT_CMD: sending EXIT_PS\n");
 			}
 		}
+		spin_lock_irqsave(&priv->driver_lock, flags);
 		list_del(&cmdnode->list);
+		spin_unlock_irqrestore(&priv->driver_lock, flags);
 		lbs_deb_host("EXEC_NEXT_CMD: sending command 0x%04x\n",
 			    le16_to_cpu(cmd->command));
 		lbs_submit_command(priv, cmdnode);
diff --git a/net/mac80211/tx.c b/net/mac80211/tx.c
index ce4596e..bd1224f 100644
--- a/net/mac80211/tx.c
+++ b/net/mac80211/tx.c
@@ -237,6 +237,10 @@ ieee80211_tx_h_dynamic_ps(struct ieee80211_tx_data *tx)
 				     &local->dynamic_ps_disable_work);
 	}
 
+	/* Don't restart the timer if we're not disassociated */
+	if (!ifmgd->associated)
+		return TX_CONTINUE;
+
 	mod_timer(&local->dynamic_ps_timer, jiffies +
 		  msecs_to_jiffies(local->hw.conf.dynamic_ps_timeout));
 
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
