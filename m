From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-2.6 2009-05-20
Date: Wed, 20 May 2009 15:34:47 -0400
Message-ID: <20090520193446.GA27441@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:44544 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755147AbZETTpV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2009 15:45:21 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

Another volley of fixes intended for 2.6.30 -- I know the velocity
is a bit high for this part of the cycle, but these are mostly small
and well-tested.

The one from me is a "brown paper bag" fix.  My earlier attempt to fix
the potential buffer overflow in airo was actually a no-op due to an
(unknown to me) type overflow... :-(

The ath5k fixes from Forrest Zhang and Pavel Roskin together fix some
regressions with 5GHz operation.  The one from Fabio Rossi avoids an
infinite loop reported by Stephen Rostedt.

The wext fix addresses a possible buffer overflow.  The cfg80211 fix
addresses a user-reported oops.  The one from Roel avoids and index
past the end of an array.

One of iwlwifi patches avoids a deadlock.  The other iwlwifi patch
simply enables the use of the firmware image they just released.
That one is worth taking for 2.6.30 because the new firmware fixes
a couple of bugs that show-up as kernel bug reports.

Please let me know if there are problems!

Thanks,

John

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/

---

The following changes since commit bc8a5397433e4effbaddfa7e462d10b3c060cabb:
  Frans Pop (1):
        ipv4: make default for INET_LRO consistent with help text

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git master

Fabio Rossi (1):
      ath5k: fix interpolation with equal power levels

Forrest Zhang (1):
      ath5k: fix exp off-by-one when computing OFDM delta slope

Jay Sternberg (1):
      iwlwifi: update 5000 ucode support to version 2 of API

Johannes Berg (1):
      wext: verify buffer size for SIOCSIWENCODEEXT

John W. Linville (1):
      airo: fix airo_get_encode{,ext} buffer overflow like I mean it...

Luis R. Rodriguez (1):
      cfg80211: fix race between core hint and driver's custom apply

Pavel Roskin (1):
      ath5k: fix scanning in AR2424

Reinette Chatre (1):
      iwlwifi: do not cancel delayed work inside spin_lock_irqsave

Roel Kluin (1):
      wireless: beyond ARRAY_SIZE of intf->crypto_stats

 drivers/net/wireless/airo.c                 |   23 ++++++++-----
 drivers/net/wireless/ath5k/phy.c            |   49 +++++++++++++++-----------
 drivers/net/wireless/ath5k/reset.c          |    8 ++--
 drivers/net/wireless/iwlwifi/iwl-5000.c     |    2 +-
 drivers/net/wireless/iwlwifi/iwl-agn.c      |    7 ----
 drivers/net/wireless/iwlwifi/iwl-scan.c     |    7 ++--
 drivers/net/wireless/iwlwifi/iwl3945-base.c |    9 +----
 drivers/net/wireless/rt2x00/rt2x00debug.c   |    2 +-
 net/wireless/reg.c                          |    7 ++++
 net/wireless/wext.c                         |    7 ++++
 10 files changed, 68 insertions(+), 53 deletions(-)

diff --git a/drivers/net/wireless/airo.c b/drivers/net/wireless/airo.c
index d734757..9eabf4d 100644
--- a/drivers/net/wireless/airo.c
+++ b/drivers/net/wireless/airo.c
@@ -6467,6 +6467,7 @@ static int airo_get_encode(struct net_device *dev,
 {
 	struct airo_info *local = dev->ml_priv;
 	int index = (dwrq->flags & IW_ENCODE_INDEX) - 1;
+	int wep_key_len;
 	u8 buf[16];
 
 	if (!local->wep_capable)
@@ -6500,11 +6501,13 @@ static int airo_get_encode(struct net_device *dev,
 	dwrq->flags |= index + 1;
 
 	/* Copy the key to the user buffer */
-	dwrq->length = get_wep_key(local, index, &buf[0], sizeof(buf));
-	if (dwrq->length != -1)
-		memcpy(extra, buf, dwrq->length);
-	else
+	wep_key_len = get_wep_key(local, index, &buf[0], sizeof(buf));
+	if (wep_key_len < 0) {
 		dwrq->length = 0;
+	} else {
+		dwrq->length = wep_key_len;
+		memcpy(extra, buf, dwrq->length);
+	}
 
 	return 0;
 }
@@ -6617,7 +6620,7 @@ static int airo_get_encodeext(struct net_device *dev,
 	struct airo_info *local = dev->ml_priv;
 	struct iw_point *encoding = &wrqu->encoding;
 	struct iw_encode_ext *ext = (struct iw_encode_ext *)extra;
-	int idx, max_key_len;
+	int idx, max_key_len, wep_key_len;
 	u8 buf[16];
 
 	if (!local->wep_capable)
@@ -6661,11 +6664,13 @@ static int airo_get_encodeext(struct net_device *dev,
 	memset(extra, 0, 16);
 	
 	/* Copy the key to the user buffer */
-	ext->key_len = get_wep_key(local, idx, &buf[0], sizeof(buf));
-	if (ext->key_len != -1)
-		memcpy(extra, buf, ext->key_len);
-	else
+	wep_key_len = get_wep_key(local, idx, &buf[0], sizeof(buf));
+	if (wep_key_len < 0) {
 		ext->key_len = 0;
+	} else {
+		ext->key_len = wep_key_len;
+		memcpy(extra, buf, ext->key_len);
+	}
 
 	return 0;
 }
diff --git a/drivers/net/wireless/ath5k/phy.c b/drivers/net/wireless/ath5k/phy.c
index 9e2faae..b48b29d 100644
--- a/drivers/net/wireless/ath5k/phy.c
+++ b/drivers/net/wireless/ath5k/phy.c
@@ -1487,28 +1487,35 @@ ath5k_get_linear_pcdac_min(const u8 *stepL, const u8 *stepR,
 {
 	s8 tmp;
 	s16 min_pwrL, min_pwrR;
-	s16 pwr_i = pwrL[0];
-
-	do {
-		pwr_i--;
-		tmp = (s8) ath5k_get_interpolated_value(pwr_i,
-						pwrL[0], pwrL[1],
-						stepL[0], stepL[1]);
-
-	} while (tmp > 1);
-
-	min_pwrL = pwr_i;
-
-	pwr_i = pwrR[0];
-	do {
-		pwr_i--;
-		tmp = (s8) ath5k_get_interpolated_value(pwr_i,
-						pwrR[0], pwrR[1],
-						stepR[0], stepR[1]);
-
-	} while (tmp > 1);
+	s16 pwr_i;
+
+	if (pwrL[0] == pwrL[1])
+		min_pwrL = pwrL[0];
+	else {
+		pwr_i = pwrL[0];
+		do {
+			pwr_i--;
+			tmp = (s8) ath5k_get_interpolated_value(pwr_i,
+							pwrL[0], pwrL[1],
+							stepL[0], stepL[1]);
+		} while (tmp > 1);
+
+		min_pwrL = pwr_i;
+	}
 
-	min_pwrR = pwr_i;
+	if (pwrR[0] == pwrR[1])
+		min_pwrR = pwrR[0];
+	else {
+		pwr_i = pwrR[0];
+		do {
+			pwr_i--;
+			tmp = (s8) ath5k_get_interpolated_value(pwr_i,
+							pwrR[0], pwrR[1],
+							stepR[0], stepR[1]);
+		} while (tmp > 1);
+
+		min_pwrR = pwr_i;
+	}
 
 	/* Keep the right boundary so that it works for both curves */
 	return max(min_pwrL, min_pwrR);
diff --git a/drivers/net/wireless/ath5k/reset.c b/drivers/net/wireless/ath5k/reset.c
index 7a17d31..5f72c11 100644
--- a/drivers/net/wireless/ath5k/reset.c
+++ b/drivers/net/wireless/ath5k/reset.c
@@ -26,7 +26,7 @@
 \*****************************/
 
 #include <linux/pci.h> 		/* To determine if a card is pci-e */
-#include <linux/bitops.h>	/* For get_bitmask_order */
+#include <linux/log2.h>
 #include "ath5k.h"
 #include "reg.h"
 #include "base.h"
@@ -69,10 +69,10 @@ static inline int ath5k_hw_write_ofdm_timings(struct ath5k_hw *ah,
 
 	/* Get exponent
 	 * ALGO: coef_exp = 14 - highest set bit position */
-	coef_exp = get_bitmask_order(coef_scaled);
+	coef_exp = ilog2(coef_scaled);
 
 	/* Doesn't make sense if it's zero*/
-	if (!coef_exp)
+	if (!coef_scaled || !coef_exp)
 		return -EINVAL;
 
 	/* Note: we've shifted coef_scaled by 24 */
@@ -359,7 +359,7 @@ int ath5k_hw_nic_wakeup(struct ath5k_hw *ah, int flags, bool initial)
 			mode |= AR5K_PHY_MODE_FREQ_5GHZ;
 
 			if (ah->ah_radio == AR5K_RF5413)
-				clock |= AR5K_PHY_PLL_40MHZ_5413;
+				clock = AR5K_PHY_PLL_40MHZ_5413;
 			else
 				clock |= AR5K_PHY_PLL_40MHZ;
 
diff --git a/drivers/net/wireless/iwlwifi/iwl-5000.c b/drivers/net/wireless/iwlwifi/iwl-5000.c
index e5ca251..9452461 100644
--- a/drivers/net/wireless/iwlwifi/iwl-5000.c
+++ b/drivers/net/wireless/iwlwifi/iwl-5000.c
@@ -46,7 +46,7 @@
 #include "iwl-6000-hw.h"
 
 /* Highest firmware API version supported */
-#define IWL5000_UCODE_API_MAX 1
+#define IWL5000_UCODE_API_MAX 2
 #define IWL5150_UCODE_API_MAX 2
 
 /* Lowest firmware API version supported */
diff --git a/drivers/net/wireless/iwlwifi/iwl-agn.c b/drivers/net/wireless/iwlwifi/iwl-agn.c
index 3bb28db..f46ba24 100644
--- a/drivers/net/wireless/iwlwifi/iwl-agn.c
+++ b/drivers/net/wireless/iwlwifi/iwl-agn.c
@@ -669,13 +669,6 @@ static int iwl_set_mode(struct iwl_priv *priv, int mode)
 	if (!iwl_is_ready_rf(priv))
 		return -EAGAIN;
 
-	cancel_delayed_work(&priv->scan_check);
-	if (iwl_scan_cancel_timeout(priv, 100)) {
-		IWL_WARN(priv, "Aborted scan still in progress after 100ms\n");
-		IWL_DEBUG_MAC80211(priv, "leaving - scan abort failed.\n");
-		return -EAGAIN;
-	}
-
 	iwl_commit_rxon(priv);
 
 	return 0;
diff --git a/drivers/net/wireless/iwlwifi/iwl-scan.c b/drivers/net/wireless/iwlwifi/iwl-scan.c
index e7c65c4..6330b91 100644
--- a/drivers/net/wireless/iwlwifi/iwl-scan.c
+++ b/drivers/net/wireless/iwlwifi/iwl-scan.c
@@ -227,9 +227,6 @@ static void iwl_rx_scan_complete_notif(struct iwl_priv *priv,
 	/* The HW is no longer scanning */
 	clear_bit(STATUS_SCAN_HW, &priv->status);
 
-	/* The scan completion notification came in, so kill that timer... */
-	cancel_delayed_work(&priv->scan_check);
-
 	IWL_DEBUG_INFO(priv, "Scan pass on %sGHz took %dms\n",
 		       (priv->scan_bands & BIT(IEEE80211_BAND_2GHZ)) ?
 						"2.4" : "5.2",
@@ -712,6 +709,8 @@ static void iwl_bg_request_scan(struct work_struct *data)
 
 	mutex_lock(&priv->mutex);
 
+	cancel_delayed_work(&priv->scan_check);
+
 	if (!iwl_is_ready(priv)) {
 		IWL_WARN(priv, "request scan called when driver not ready.\n");
 		goto done;
@@ -925,6 +924,8 @@ void iwl_bg_scan_completed(struct work_struct *work)
 
 	IWL_DEBUG_SCAN(priv, "SCAN complete scan\n");
 
+	cancel_delayed_work(&priv->scan_check);
+
 	ieee80211_scan_completed(priv->hw, false);
 
 	if (test_bit(STATUS_EXIT_PENDING, &priv->status))
diff --git a/drivers/net/wireless/iwlwifi/iwl3945-base.c b/drivers/net/wireless/iwlwifi/iwl3945-base.c
index 4cce661..ff4d0e4 100644
--- a/drivers/net/wireless/iwlwifi/iwl3945-base.c
+++ b/drivers/net/wireless/iwlwifi/iwl3945-base.c
@@ -782,13 +782,6 @@ static int iwl3945_set_mode(struct iwl_priv *priv, int mode)
 	if (!iwl_is_ready_rf(priv))
 		return -EAGAIN;
 
-	cancel_delayed_work(&priv->scan_check);
-	if (iwl_scan_cancel_timeout(priv, 100)) {
-		IWL_WARN(priv, "Aborted scan still in progress after 100ms\n");
-		IWL_DEBUG_MAC80211(priv, "leaving - scan abort failed.\n");
-		return -EAGAIN;
-	}
-
 	iwl3945_commit_rxon(priv);
 
 	return 0;
@@ -3298,6 +3291,8 @@ static void iwl3945_bg_request_scan(struct work_struct *data)
 
 	mutex_lock(&priv->mutex);
 
+	cancel_delayed_work(&priv->scan_check);
+
 	if (!iwl_is_ready(priv)) {
 		IWL_WARN(priv, "request scan called when driver not ready.\n");
 		goto done;
diff --git a/drivers/net/wireless/rt2x00/rt2x00debug.c b/drivers/net/wireless/rt2x00/rt2x00debug.c
index 07d378e..7b3ee8c 100644
--- a/drivers/net/wireless/rt2x00/rt2x00debug.c
+++ b/drivers/net/wireless/rt2x00/rt2x00debug.c
@@ -138,7 +138,7 @@ void rt2x00debug_update_crypto(struct rt2x00_dev *rt2x00dev,
 
 	if (cipher == CIPHER_TKIP_NO_MIC)
 		cipher = CIPHER_TKIP;
-	if (cipher == CIPHER_NONE || cipher > CIPHER_MAX)
+	if (cipher == CIPHER_NONE || cipher >= CIPHER_MAX)
 		return;
 
 	/* Remove CIPHER_NONE index */
diff --git a/net/wireless/reg.c b/net/wireless/reg.c
index 08265ca..487cb62 100644
--- a/net/wireless/reg.c
+++ b/net/wireless/reg.c
@@ -1551,6 +1551,13 @@ static int regulatory_hint_core(const char *alpha2)
 
 	queue_regulatory_request(request);
 
+	/*
+	 * This ensures last_request is populated once modules
+	 * come swinging in and calling regulatory hints and
+	 * wiphy_apply_custom_regulatory().
+	 */
+	flush_scheduled_work();
+
 	return 0;
 }
 
diff --git a/net/wireless/wext.c b/net/wireless/wext.c
index cb6a5bb..0e59f9a 100644
--- a/net/wireless/wext.c
+++ b/net/wireless/wext.c
@@ -786,6 +786,13 @@ static int ioctl_standard_iw_point(struct iw_point *iwp, unsigned int cmd,
 			err = -EFAULT;
 			goto out;
 		}
+
+		if (cmd == SIOCSIWENCODEEXT) {
+			struct iw_encode_ext *ee = (void *) extra;
+
+			if (iwp->length < sizeof(*ee) + ee->key_len)
+				return -EFAULT;
+		}
 	}
 
 	err = handler(dev, info, (union iwreq_data *) iwp, extra);
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
