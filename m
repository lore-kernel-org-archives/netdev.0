From: =?UTF-8?q?Pali=20Roh=C3=A1r?= <pali.rohar@gmail.com>
Subject: [PATCH 12/16] wl1251: disable retry and ACK policy for injected packets
Date: Sat, 26 Oct 2013 22:34:11 +0200
Message-ID: <1382819655-30430-13-git-send-email-pali.rohar@gmail.com>
References: <1382819655-30430-1-git-send-email-pali.rohar@gmail.com>
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, freemangordon@abv.bg,
	aaro.koskinen@iki.fi, pavel@ucw.cz, sre@ring0.de,
	joni.lapilainen@gmail.com, pali.rohar@gmail.com,
	David Gnedt <david.gnedt@davizone.at>
To: Luciano Coelho <luca@coelho.fi>,
	"John W. Linville" <linville@tuxdriver.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1382819655-30430-1-git-send-email-pali.rohar@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Gnedt <david.gnedt@davizone.at>

Set the retry limit to 0 and disable the ACK policy for injected packets.

Signed-off-by: David Gnedt <david.gnedt@davizone.at>
---
 drivers/net/wireless/ti/wl1251/acx.c |    8 +++++++-
 drivers/net/wireless/ti/wl1251/tx.c  |    7 ++++++-
 2 files changed, 13 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/ti/wl1251/acx.c b/drivers/net/wireless/ti/wl1251/acx.c
index 14da6de..f98d46f 100644
--- a/drivers/net/wireless/ti/wl1251/acx.c
+++ b/drivers/net/wireless/ti/wl1251/acx.c
@@ -943,12 +943,18 @@ int wl1251_acx_rate_policies(struct wl1251 *wl)
 	}
 
 	/* configure one default (one-size-fits-all) rate class */
-	acx->rate_class_cnt = 1;
+	acx->rate_class_cnt = 2;
 	acx->rate_class[0].enabled_rates = ACX_RATE_MASK_UNSPECIFIED;
 	acx->rate_class[0].short_retry_limit = ACX_RATE_RETRY_LIMIT;
 	acx->rate_class[0].long_retry_limit = ACX_RATE_RETRY_LIMIT;
 	acx->rate_class[0].aflags = 0;
 
+	/* no-retry rate class */
+	acx->rate_class[1].enabled_rates = ACX_RATE_MASK_UNSPECIFIED;
+	acx->rate_class[1].short_retry_limit = 0;
+	acx->rate_class[1].long_retry_limit = 0;
+	acx->rate_class[1].aflags = 0;
+
 	ret = wl1251_cmd_configure(wl, ACX_RATE_POLICY, acx, sizeof(*acx));
 	if (ret < 0) {
 		wl1251_warning("Setting of rate policies failed: %d", ret);
diff --git a/drivers/net/wireless/ti/wl1251/tx.c b/drivers/net/wireless/ti/wl1251/tx.c
index 1de4ccb..e559bc4 100644
--- a/drivers/net/wireless/ti/wl1251/tx.c
+++ b/drivers/net/wireless/ti/wl1251/tx.c
@@ -90,8 +90,12 @@ static void wl1251_tx_control(struct tx_double_buffer_desc *tx_hdr,
 	/* 802.11 packets */
 	tx_hdr->control.packet_type = 0;
 
-	if (control->flags & IEEE80211_TX_CTL_NO_ACK)
+	/* Also disable retry and ACK policy for injected packets */
+	if ((control->flags & IEEE80211_TX_CTL_NO_ACK) ||
+	    (control->flags & IEEE80211_TX_CTL_INJECTED)) {
+		tx_hdr->control.rate_policy = 1;
 		tx_hdr->control.ack_policy = 1;
+	}
 
 	tx_hdr->control.tx_complete = 1;
 
@@ -414,6 +418,7 @@ static void wl1251_tx_packet_cb(struct wl1251 *wl,
 	info = IEEE80211_SKB_CB(skb);
 
 	if (!(info->flags & IEEE80211_TX_CTL_NO_ACK) &&
+	    !(info->flags & IEEE80211_TX_CTL_INJECTED) &&
 	    (result->status == TX_SUCCESS))
 		info->flags |= IEEE80211_TX_STAT_ACK;
 
-- 
1.7.10.4
