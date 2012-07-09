From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless 2012-07-09
Date: Mon, 9 Jul 2012 15:28:18 -0400
Message-ID: <20120709192818.GE1348@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

commit c1109736bcdd14b590392e9a96d66e7e823f9e67

Dave,

Please accept these fixes for the 3.5 stream...

Bing Zhao provides an mwifiex fix for a memory leak uncovered by
Coverity.

Eliad Peller provides a mac80211 fix to properly clean-up after an
association failure.

Emmanuel Grumbach gives us an iwlegacy fix to avoid some on-device
memory corruption that leads to a stuck queue.

Sasha Levin offers an NFC fix to prevent a NULL pointer dereference
in llcp_sock_getname.

Stanislaw Gruszka offers an rt2x00usb fix for an RX queue stall that
results from using the wrong argument order in a macro call.  He also
gives us an iwlegacy fix that corresponds to an already merged iwlwifi
fix, the effect of which is to avoid stuck queue detection failure.

Finally, Thomas Huehn provides a mac80211 fix to correct some kzalloc
arguments.  This was originally two patches, but I consolidated them.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit bb3bb3a5b839fa5c0a2c386640e865320a1fb64c:

  Merge branch 'master' of git://1984.lsi.us.es/nf (2012-07-09 02:47:59 -0700)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git for-davem

for you to fetch changes up to c1109736bcdd14b590392e9a96d66e7e823f9e67:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless into for-davem (2012-07-09 15:09:08 -0400)

----------------------------------------------------------------

Bing Zhao (1):
      mwifiex: fix Coverity SCAN CID 709078: Resource leak (RESOURCE_LEAK)

Eliad Peller (1):
      mac80211: destroy assoc_data correctly if assoc fails

Emmanuel Grumbach (1):
      iwlegacy: don't mess up the SCD when removing a key

John W. Linville (1):
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless into for-davem

Sasha Levin (1):
      NFC: Prevent NULL deref when getting socket name

Stanislaw Gruszka (2):
      rt2x00usb: fix indexes ordering on RX queue kick
      iwlegacy: always monitor for stuck queues

Thomas Huehn (1):
      mac80211: correct size the argument to kzalloc in minstrel_ht

 drivers/net/wireless/iwlegacy/4965-mac.c |    4 ++--
 drivers/net/wireless/iwlegacy/common.c   |   14 ++++++--------
 drivers/net/wireless/mwifiex/cfg80211.c  |    1 +
 drivers/net/wireless/rt2x00/rt2x00usb.c  |    2 +-
 net/mac80211/mlme.c                      |    6 ++----
 net/mac80211/rc80211_minstrel_ht.c       |    2 +-
 net/nfc/llcp/sock.c                      |    2 +-
 7 files changed, 14 insertions(+), 17 deletions(-)

diff --git a/drivers/net/wireless/iwlegacy/4965-mac.c b/drivers/net/wireless/iwlegacy/4965-mac.c
index 509301a..ff5d689 100644
--- a/drivers/net/wireless/iwlegacy/4965-mac.c
+++ b/drivers/net/wireless/iwlegacy/4965-mac.c
@@ -3405,7 +3405,7 @@ il4965_remove_dynamic_key(struct il_priv *il,
 		return 0;
 	}
 
-	if (il->stations[sta_id].sta.key.key_offset == WEP_INVALID_OFFSET) {
+	if (il->stations[sta_id].sta.key.key_flags & STA_KEY_FLG_INVALID) {
 		IL_WARN("Removing wrong key %d 0x%x\n", keyconf->keyidx,
 			key_flags);
 		spin_unlock_irqrestore(&il->sta_lock, flags);
@@ -3420,7 +3420,7 @@ il4965_remove_dynamic_key(struct il_priv *il,
 	memset(&il->stations[sta_id].sta.key, 0, sizeof(struct il4965_keyinfo));
 	il->stations[sta_id].sta.key.key_flags =
 	    STA_KEY_FLG_NO_ENC | STA_KEY_FLG_INVALID;
-	il->stations[sta_id].sta.key.key_offset = WEP_INVALID_OFFSET;
+	il->stations[sta_id].sta.key.key_offset = keyconf->hw_key_idx;
 	il->stations[sta_id].sta.sta.modify_mask = STA_MODIFY_KEY_MASK;
 	il->stations[sta_id].sta.mode = STA_CONTROL_MODIFY_MSK;
 
diff --git a/drivers/net/wireless/iwlegacy/common.c b/drivers/net/wireless/iwlegacy/common.c
index cbf2dc1..5d4807c 100644
--- a/drivers/net/wireless/iwlegacy/common.c
+++ b/drivers/net/wireless/iwlegacy/common.c
@@ -4767,14 +4767,12 @@ il_bg_watchdog(unsigned long data)
 		return;
 
 	/* monitor and check for other stuck queues */
-	if (il_is_any_associated(il)) {
-		for (cnt = 0; cnt < il->hw_params.max_txq_num; cnt++) {
-			/* skip as we already checked the command queue */
-			if (cnt == il->cmd_queue)
-				continue;
-			if (il_check_stuck_queue(il, cnt))
-				return;
-		}
+	for (cnt = 0; cnt < il->hw_params.max_txq_num; cnt++) {
+		/* skip as we already checked the command queue */
+		if (cnt == il->cmd_queue)
+			continue;
+		if (il_check_stuck_queue(il, cnt))
+			return;
 	}
 
 	mod_timer(&il->watchdog,
diff --git a/drivers/net/wireless/mwifiex/cfg80211.c b/drivers/net/wireless/mwifiex/cfg80211.c
index ce61b6f..5c7fd18 100644
--- a/drivers/net/wireless/mwifiex/cfg80211.c
+++ b/drivers/net/wireless/mwifiex/cfg80211.c
@@ -958,6 +958,7 @@ static int mwifiex_cfg80211_start_ap(struct wiphy *wiphy,
 	case NL80211_HIDDEN_SSID_ZERO_CONTENTS:
 		/* firmware doesn't support this type of hidden SSID */
 	default:
+		kfree(bss_cfg);
 		return -EINVAL;
 	}
 
diff --git a/drivers/net/wireless/rt2x00/rt2x00usb.c b/drivers/net/wireless/rt2x00/rt2x00usb.c
index d357d1e..74ecc33 100644
--- a/drivers/net/wireless/rt2x00/rt2x00usb.c
+++ b/drivers/net/wireless/rt2x00/rt2x00usb.c
@@ -436,8 +436,8 @@ void rt2x00usb_kick_queue(struct data_queue *queue)
 	case QID_RX:
 		if (!rt2x00queue_full(queue))
 			rt2x00queue_for_each_entry(queue,
-						   Q_INDEX_DONE,
 						   Q_INDEX,
+						   Q_INDEX_DONE,
 						   NULL,
 						   rt2x00usb_kick_rx_entry);
 		break;
diff --git a/net/mac80211/mlme.c b/net/mac80211/mlme.c
index a4bb856..0db5d34 100644
--- a/net/mac80211/mlme.c
+++ b/net/mac80211/mlme.c
@@ -2174,15 +2174,13 @@ ieee80211_rx_mgmt_assoc_resp(struct ieee80211_sub_if_data *sdata,
 		       sdata->name, mgmt->sa, status_code);
 		ieee80211_destroy_assoc_data(sdata, false);
 	} else {
-		printk(KERN_DEBUG "%s: associated\n", sdata->name);
-
 		if (!ieee80211_assoc_success(sdata, *bss, mgmt, len)) {
 			/* oops -- internal error -- send timeout for now */
-			ieee80211_destroy_assoc_data(sdata, true);
-			sta_info_destroy_addr(sdata, mgmt->bssid);
+			ieee80211_destroy_assoc_data(sdata, false);
 			cfg80211_put_bss(*bss);
 			return RX_MGMT_CFG80211_ASSOC_TIMEOUT;
 		}
+		printk(KERN_DEBUG "%s: associated\n", sdata->name);
 
 		/*
 		 * destroy assoc_data afterwards, as otherwise an idle
diff --git a/net/mac80211/rc80211_minstrel_ht.c b/net/mac80211/rc80211_minstrel_ht.c
index 2d1acc6..f9e51ef 100644
--- a/net/mac80211/rc80211_minstrel_ht.c
+++ b/net/mac80211/rc80211_minstrel_ht.c
@@ -809,7 +809,7 @@ minstrel_ht_alloc_sta(void *priv, struct ieee80211_sta *sta, gfp_t gfp)
 			max_rates = sband->n_bitrates;
 	}
 
-	msp = kzalloc(sizeof(struct minstrel_ht_sta), gfp);
+	msp = kzalloc(sizeof(*msp), gfp);
 	if (!msp)
 		return NULL;
 
diff --git a/net/nfc/llcp/sock.c b/net/nfc/llcp/sock.c
index 17a707d..e06d458 100644
--- a/net/nfc/llcp/sock.c
+++ b/net/nfc/llcp/sock.c
@@ -292,7 +292,7 @@ static int llcp_sock_getname(struct socket *sock, struct sockaddr *addr,
 
 	pr_debug("%p\n", sk);
 
-	if (llcp_sock == NULL)
+	if (llcp_sock == NULL || llcp_sock->dev == NULL)
 		return -EBADFD;
 
 	addr->sa_family = AF_NFC;
-- 
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
