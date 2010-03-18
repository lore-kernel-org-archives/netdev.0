From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-2.6 2010-03-18
Date: Thu, 18 Mar 2010 16:35:32 -0400
Message-ID: <20100318203532.GE17357@tuxdriver.com>
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

Three more intended for 2.6.34...  The biggest one is for ath9k, which
removes some unused code along with the one-liner that makes the code
unused.  (Did you follow that?)  The others are a null-pointer fix and a
"hush dawg" for a noisy warning message.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 22001a13d09d82772e831dcdac0553994a4bac5d:
  Tilman Schmidt (1):
        gigaset: fix build failure

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git master

Adel Gadllah (1):
      iwlwifi: Silence tfds_in_queue message

Felix Fietkau (1):
      ath9k: fix BUG_ON triggered by PAE frames

Grazvydas Ignotas (1):
      wl1251: fix potential crash

 drivers/net/wireless/ath/ath9k/xmit.c        |   21 +--------------------
 drivers/net/wireless/iwlwifi/iwl-tx.c        |    2 +-
 drivers/net/wireless/wl12xx/wl1251_debugfs.c |    3 ++-
 3 files changed, 4 insertions(+), 22 deletions(-)

diff --git a/drivers/net/wireless/ath/ath9k/xmit.c b/drivers/net/wireless/ath/ath9k/xmit.c
index b2c8207..294b486 100644
--- a/drivers/net/wireless/ath/ath9k/xmit.c
+++ b/drivers/net/wireless/ath/ath9k/xmit.c
@@ -1353,25 +1353,6 @@ static enum ath9k_pkt_type get_hw_packet_type(struct sk_buff *skb)
 	return htype;
 }
 
-static bool is_pae(struct sk_buff *skb)
-{
-	struct ieee80211_hdr *hdr;
-	__le16 fc;
-
-	hdr = (struct ieee80211_hdr *)skb->data;
-	fc = hdr->frame_control;
-
-	if (ieee80211_is_data(fc)) {
-		if (ieee80211_is_nullfunc(fc) ||
-		    /* Port Access Entity (IEEE 802.1X) */
-		    (skb->protocol == cpu_to_be16(ETH_P_PAE))) {
-			return true;
-		}
-	}
-
-	return false;
-}
-
 static int get_hw_crypto_keytype(struct sk_buff *skb)
 {
 	struct ieee80211_tx_info *tx_info = IEEE80211_SKB_CB(skb);
@@ -1696,7 +1677,7 @@ static void ath_tx_start_dma(struct ath_softc *sc, struct ath_buf *bf,
 			goto tx_done;
 		}
 
-		if ((tx_info->flags & IEEE80211_TX_CTL_AMPDU) && !is_pae(skb)) {
+		if (tx_info->flags & IEEE80211_TX_CTL_AMPDU) {
 			/*
 			 * Try aggregation if it's a unicast data frame
 			 * and the destination is HT capable.
diff --git a/drivers/net/wireless/iwlwifi/iwl-tx.c b/drivers/net/wireless/iwlwifi/iwl-tx.c
index 1ed5206..8c12311 100644
--- a/drivers/net/wireless/iwlwifi/iwl-tx.c
+++ b/drivers/net/wireless/iwlwifi/iwl-tx.c
@@ -124,7 +124,7 @@ void iwl_free_tfds_in_queue(struct iwl_priv *priv,
 	if (priv->stations[sta_id].tid[tid].tfds_in_queue >= freed)
 		priv->stations[sta_id].tid[tid].tfds_in_queue -= freed;
 	else {
-		IWL_ERR(priv, "free more than tfds_in_queue (%u:%d)\n",
+		IWL_DEBUG_TX(priv, "free more than tfds_in_queue (%u:%d)\n",
 			priv->stations[sta_id].tid[tid].tfds_in_queue,
 			freed);
 		priv->stations[sta_id].tid[tid].tfds_in_queue = 0;
diff --git a/drivers/net/wireless/wl12xx/wl1251_debugfs.c b/drivers/net/wireless/wl12xx/wl1251_debugfs.c
index 0ccba57..05e4d68 100644
--- a/drivers/net/wireless/wl12xx/wl1251_debugfs.c
+++ b/drivers/net/wireless/wl12xx/wl1251_debugfs.c
@@ -466,7 +466,8 @@ out:
 
 void wl1251_debugfs_reset(struct wl1251 *wl)
 {
-	memset(wl->stats.fw_stats, 0, sizeof(*wl->stats.fw_stats));
+	if (wl->stats.fw_stats != NULL)
+		memset(wl->stats.fw_stats, 0, sizeof(*wl->stats.fw_stats));
 	wl->stats.retry_count = 0;
 	wl->stats.excessive_retries = 0;
 }
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
