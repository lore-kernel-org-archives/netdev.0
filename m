From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 2/2 NEXT] rtlwifi: Fix static checker warnings for various drivers
Date: Thu,  2 Oct 2014 12:00:54 -0500
Message-ID: <1412269254-19983-3-git-send-email-Larry.Finger@lwfinger.net>
References: <1412269254-19983-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org, troy_tan@realsil.com.cn,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org, Dan Carpenter <dan.carpenter@oracle.com>
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f172.google.com ([209.85.214.172]:42704 "EHLO
	mail-ob0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752901AbaJBRBW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Oct 2014 13:01:22 -0400
In-Reply-To: <1412269254-19983-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Indenting errors yielded the following static checker warnings:

drivers/net/wireless/rtlwifi/rtl8192ee/hw.c:533 rtl92ee_set_hw_reg() warn: add curly braces? (if)
drivers/net/wireless/rtlwifi/rtl8192ee/hw.c:539 rtl92ee_set_hw_reg() warn: add curly braces? (if)

An unreleased version of the static checker also reported:

drivers/net/wireless/rtlwifi/rtl8723be/trx.c:550 rtl8723be_rx_query_desc() warn: 'hdr' can't be NULL.
drivers/net/wireless/rtlwifi/rtl8188ee/trx.c:621 rtl88ee_rx_query_desc() warn: 'hdr' can't be NULL.
drivers/net/wireless/rtlwifi/rtl8192ee/trx.c:567 rtl92ee_rx_query_desc() warn: 'hdr' can't be NULL.
drivers/net/wireless/rtlwifi/rtl8821ae/trx.c:758 rtl8821ae_rx_query_desc() warn: 'hdr' can't be NULL.
drivers/net/wireless/rtlwifi/rtl8723ae/trx.c:494 rtl8723e_rx_query_desc() warn: 'hdr' can't be NULL.
drivers/net/wireless/rtlwifi/rtl8192se/trx.c:315 rtl92se_rx_query_desc() warn: 'hdr' can't be NULL.
drivers/net/wireless/rtlwifi/rtl8192ce/trx.c:392 rtl92ce_rx_query_desc() warn: 'hdr' can't be NULL.

All of these are fixed.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Cc: Dan Carpenter <dan.carpenter@oracle.com>
---
 drivers/net/wireless/rtlwifi/rtl8188ee/trx.c |  7 -------
 drivers/net/wireless/rtlwifi/rtl8192ce/trx.c |  4 ----
 drivers/net/wireless/rtlwifi/rtl8192ee/hw.c  | 24 ++++++++++++------------
 drivers/net/wireless/rtlwifi/rtl8192ee/trx.c |  7 -------
 drivers/net/wireless/rtlwifi/rtl8192se/trx.c |  4 ----
 drivers/net/wireless/rtlwifi/rtl8723ae/trx.c |  6 ------
 drivers/net/wireless/rtlwifi/rtl8723be/trx.c |  7 -------
 drivers/net/wireless/rtlwifi/rtl8821ae/trx.c |  7 -------
 8 files changed, 12 insertions(+), 54 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/rtl8188ee/trx.c b/drivers/net/wireless/rtlwifi/rtl8188ee/trx.c
index cf56ec8..df549c9 100644
--- a/drivers/net/wireless/rtlwifi/rtl8188ee/trx.c
+++ b/drivers/net/wireless/rtlwifi/rtl8188ee/trx.c
@@ -618,13 +618,6 @@ bool rtl88ee_rx_query_desc(struct ieee80211_hw *hw,
 	 * to decrypt it
 	 */
 	if (status->decrypted) {
-		if (!hdr) {
-			WARN_ON_ONCE(true);
-			pr_err("decrypted is true but hdr NULL, from skb %p\n",
-			       rtl_get_hdr(skb));
-			return false;
-		}
-
 		if ((!_ieee80211_is_robust_mgmt_frame(hdr)) &&
 		    (ieee80211_has_protected(hdr->frame_control)))
 			rx_status->flag |= RX_FLAG_DECRYPTED;
diff --git a/drivers/net/wireless/rtlwifi/rtl8192ce/trx.c b/drivers/net/wireless/rtlwifi/rtl8192ce/trx.c
index c140123..2fb9c7a 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192ce/trx.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192ce/trx.c
@@ -389,10 +389,6 @@ bool rtl92ce_rx_query_desc(struct ieee80211_hw *hw,
 	 * to decrypt it
 	 */
 	if (stats->decrypted) {
-		if (!hdr) {
-			/* In testing, hdr was NULL here */
-			return false;
-		}
 		if ((_ieee80211_is_robust_mgmt_frame(hdr)) &&
 		    (ieee80211_has_protected(hdr->frame_control)))
 			rx_status->flag &= ~RX_FLAG_DECRYPTED;
diff --git a/drivers/net/wireless/rtlwifi/rtl8192ee/hw.c b/drivers/net/wireless/rtlwifi/rtl8192ee/hw.c
index 85d0d58..dfdc9b2 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192ee/hw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192ee/hw.c
@@ -530,18 +530,18 @@ void rtl92ee_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 			fac = (1 << (fac + 2));
 			if (fac > 0xf)
 				fac = 0xf;
-				for (i = 0; i < 4; i++) {
-					if ((reg[i] & 0xf0) > (fac << 4))
-						reg[i] = (reg[i] & 0x0f) |
-							(fac << 4);
-					if ((reg[i] & 0x0f) > fac)
-						reg[i] = (reg[i] & 0xf0) | fac;
-						rtl_write_byte(rtlpriv,
-						       (REG_AGGLEN_LMT + i),
-						       reg[i]);
-				}
-				RT_TRACE(rtlpriv, COMP_MLME, DBG_LOUD,
-					 "Set HW_VAR_AMPDU_FACTOR:%#x\n", fac);
+			for (i = 0; i < 4; i++) {
+				if ((reg[i] & 0xf0) > (fac << 4))
+					reg[i] = (reg[i] & 0x0f) |
+						(fac << 4);
+				if ((reg[i] & 0x0f) > fac)
+					reg[i] = (reg[i] & 0xf0) | fac;
+				rtl_write_byte(rtlpriv,
+					       (REG_AGGLEN_LMT + i),
+					       reg[i]);
+			}
+			RT_TRACE(rtlpriv, COMP_MLME, DBG_LOUD,
+				 "Set HW_VAR_AMPDU_FACTOR:%#x\n", fac);
 		}
 		}
 		break;
diff --git a/drivers/net/wireless/rtlwifi/rtl8192ee/trx.c b/drivers/net/wireless/rtlwifi/rtl8192ee/trx.c
index 83edd95..2fcbef1 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192ee/trx.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192ee/trx.c
@@ -564,13 +564,6 @@ bool rtl92ee_rx_query_desc(struct ieee80211_hw *hw,
 	 * to decrypt it
 	 */
 	if (status->decrypted) {
-		if (!hdr) {
-			WARN_ON_ONCE(true);
-			pr_err("decrypted is true but hdr NULL, from skb %p\n",
-			       rtl_get_hdr(skb));
-			return false;
-		}
-
 		if ((!_ieee80211_is_robust_mgmt_frame(hdr)) &&
 		    (ieee80211_has_protected(hdr->frame_control)))
 			rx_status->flag |= RX_FLAG_DECRYPTED;
diff --git a/drivers/net/wireless/rtlwifi/rtl8192se/trx.c b/drivers/net/wireless/rtlwifi/rtl8192se/trx.c
index 2b3c78b..b358ebc 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192se/trx.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192se/trx.c
@@ -312,10 +312,6 @@ bool rtl92se_rx_query_desc(struct ieee80211_hw *hw, struct rtl_stats *stats,
 		hdr = (struct ieee80211_hdr *)(skb->data +
 		       stats->rx_drvinfo_size + stats->rx_bufshift);
 
-		if (!hdr) {
-			/* during testing, hdr was NULL here */
-			return false;
-		}
 		if ((_ieee80211_is_robust_mgmt_frame(hdr)) &&
 			(ieee80211_has_protected(hdr->frame_control)))
 			rx_status->flag &= ~RX_FLAG_DECRYPTED;
diff --git a/drivers/net/wireless/rtlwifi/rtl8723ae/trx.c b/drivers/net/wireless/rtlwifi/rtl8723ae/trx.c
index 1da2367..d372cca 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723ae/trx.c
+++ b/drivers/net/wireless/rtlwifi/rtl8723ae/trx.c
@@ -491,12 +491,6 @@ bool rtl8723e_rx_query_desc(struct ieee80211_hw *hw,
 	 * to decrypt it
 	 */
 	if (status->decrypted) {
-		if (!hdr) {
-			WARN_ON_ONCE(true);
-			pr_err("decrypted is true but hdr NULL, from skb %p\n",
-			       rtl_get_hdr(skb));
-			return false;
-		}
 		if ((!_ieee80211_is_robust_mgmt_frame(hdr)) &&
 		    (ieee80211_has_protected(hdr->frame_control)))
 			rx_status->flag |= RX_FLAG_DECRYPTED;
diff --git a/drivers/net/wireless/rtlwifi/rtl8723be/trx.c b/drivers/net/wireless/rtlwifi/rtl8723be/trx.c
index 9679cd2..d6a1c70 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723be/trx.c
+++ b/drivers/net/wireless/rtlwifi/rtl8723be/trx.c
@@ -547,13 +547,6 @@ bool rtl8723be_rx_query_desc(struct ieee80211_hw *hw,
 	 * to decrypt it
 	 */
 	if (status->decrypted) {
-		if (!hdr) {
-			WARN_ON_ONCE(true);
-			pr_err("decrypted is true but hdr NULL, from skb %p\n",
-			       rtl_get_hdr(skb));
-			return false;
-		}
-
 		if ((!_ieee80211_is_robust_mgmt_frame(hdr)) &&
 		    (ieee80211_has_protected(hdr->frame_control)))
 			rx_status->flag |= RX_FLAG_DECRYPTED;
diff --git a/drivers/net/wireless/rtlwifi/rtl8821ae/trx.c b/drivers/net/wireless/rtlwifi/rtl8821ae/trx.c
index 7ece0ef..383b86b 100644
--- a/drivers/net/wireless/rtlwifi/rtl8821ae/trx.c
+++ b/drivers/net/wireless/rtlwifi/rtl8821ae/trx.c
@@ -755,13 +755,6 @@ bool rtl8821ae_rx_query_desc(struct ieee80211_hw *hw,
 	 * to decrypt it
 	 */
 	if (status->decrypted) {
-		if (!hdr) {
-			WARN_ON_ONCE(true);
-			pr_err("decrypted is true but hdr NULL, from skb %p\n",
-			       rtl_get_hdr(skb));
-			return false;
-		}
-
 		if ((!_ieee80211_is_robust_mgmt_frame(hdr)) &&
 		    (ieee80211_has_protected(hdr->frame_control)))
 			rx_status->flag |= RX_FLAG_DECRYPTED;
-- 
1.8.4.5
