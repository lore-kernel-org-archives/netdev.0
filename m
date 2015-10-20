From: greearb@candelatech.com
Subject: [PATCH-v2 2/2] mac80211: ensure association req uses configured ratemask.
Date: Tue, 20 Oct 2015 10:22:30 -0700
Message-ID: <1445361750-24707-2-git-send-email-greearb@candelatech.com>
References: <1445361750-24707-1-git-send-email-greearb@candelatech.com>
Cc: Ben Greear <greearb@candelatech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.candelatech.com ([208.74.158.173]:58215 "EHLO
	mail2.candelatech.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752091AbbJTRWo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Oct 2015 13:22:44 -0400
In-Reply-To: <1445361750-24707-1-git-send-email-greearb@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>

When sending the association request, pay attention to the
legacy rates configured by the user, and do not advertise support
for any that are not configured.

This makes the assoc request packet look more correct when
making modern hardware act like a /b mode station, for instance.

Signed-off-by: Ben Greear <greearb@candelatech.com>
---
 net/mac80211/ieee80211_i.h |  2 +-
 net/mac80211/mlme.c        | 49 ++++++++++++++++++++++++++++++++++++++++++++--
 2 files changed, 48 insertions(+), 3 deletions(-)

diff --git a/net/mac80211/ieee80211_i.h b/net/mac80211/ieee80211_i.h
index 5e43e99..e9fcdc2 100644
--- a/net/mac80211/ieee80211_i.h
+++ b/net/mac80211/ieee80211_i.h
@@ -383,7 +383,7 @@ struct ieee80211_mgd_auth_data {
 
 struct ieee80211_mgd_assoc_data {
 	struct cfg80211_bss *bss;
-	const u8 *supp_rates;
+	u8 supp_rates[IEEE80211_MAX_SUPP_RATES];
 
 	unsigned long timeout;
 	int tries;
diff --git a/net/mac80211/mlme.c b/net/mac80211/mlme.c
index 9651e92..fdcf863 100644
--- a/net/mac80211/mlme.c
+++ b/net/mac80211/mlme.c
@@ -635,6 +635,8 @@ static void ieee80211_send_assoc(struct ieee80211_sub_if_data *sdata)
 						     assoc_data->supp_rates_len,
 						     &rates);
 	} else {
+		u32 msk = sdata->cfg_advert_bitrate_mask.control[chan->band].legacy;
+
 		/*
 		 * In case AP not provide any supported rates information
 		 * before association, we send information element(s) with
@@ -645,6 +647,9 @@ static void ieee80211_send_assoc(struct ieee80211_sub_if_data *sdata)
 			if ((rate_flags & sband->bitrates[i].flags)
 			    != rate_flags)
 				continue;
+			if (sdata->cfg_advert_bitrate_mask_set &&
+			    (!(msk & (1 << i))))
+				continue;
 			rates |= BIT(i);
 			rates_len++;
 		}
@@ -4840,8 +4845,48 @@ int ieee80211_mgd_assoc(struct ieee80211_sub_if_data *sdata,
 		sdata->smps_mode = ifmgd->req_smps;
 
 	assoc_data->capability = req->bss->capability;
-	assoc_data->supp_rates = bss->supp_rates;
-	assoc_data->supp_rates_len = bss->supp_rates_len;
+	if (sdata->cfg_advert_bitrate_mask_set) {
+		int band = req->bss->channel->band;
+		u32 msk = sdata->cfg_advert_bitrate_mask.control[band].legacy;
+		u8 all_rates[12] = { 2, 4, 11, 22,
+				     12, 18, 24, 36, 48, 72, 96, 108 };
+		int i;
+		int q = 0;
+
+		/* Skip CCK rates for 5Ghz band */
+		if (band == IEEE80211_BAND_5GHZ)
+			msk = msk << 4;
+
+#if 0
+		pr_err("mgt-assoc, band: %d msk: 0x%x  bss-rates-len: %d\n",
+		       band, msk, (int)(bss->supp_rates_len));
+		for (i = 0; i < bss->supp_rates_len; i++) {
+			pr_err("bss rate[%d] = %d (0x%x)\n",
+			       i, bss->supp_rates[i], bss->supp_rates[i]);
+		}
+#endif
+		for (i = 0; i < 12; i++) {
+			int j;
+
+			if (!(msk & (1 << i)))
+				break;
+
+			for (j = 0; j < bss->supp_rates_len; j++) {
+				/* Mask out the 'basic-rate' flag, 0x80 */
+				if ((bss->supp_rates[j] & 0x7f) == all_rates[i]) {
+					assoc_data->supp_rates[q] =
+						bss->supp_rates[j];
+					q++;
+					break;
+				}
+			}
+		}
+		assoc_data->supp_rates_len = q;
+	} else {
+		memcpy(assoc_data->supp_rates, bss->supp_rates,
+		       bss->supp_rates_len);
+		assoc_data->supp_rates_len = bss->supp_rates_len;
+	}
 
 	rcu_read_lock();
 	ht_ie = ieee80211_bss_get_ie(req->bss, WLAN_EID_HT_OPERATION);
-- 
2.4.3
