From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Subject: [PATCH v2] net/wireless/brcm80211/brcmfmac: Make return type and name reflect actual semantics
Date: Sun, 22 Jun 2014 00:55:26 +0200
Message-ID: <1403391326-28086-1-git-send-email-linux@rasmusvillemoes.dk>
References: <1403299923-21533-1-git-send-email-linux@rasmusvillemoes.dk>
Cc: linux-wireless@vger.kernel.org, brcm80211-dev-list@broadcom.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Rasmus Villemoes <linux@rasmusvillemoes.dk>
To: Arend van Spriel <arend@broadcom.com>,
	Brett Rudley <brudley@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1403299923-21533-1-git-send-email-linux@rasmusvillemoes.dk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Applying ++ to a bool is equivalent to setting it true, regardless of
its initial value (bools are not uint1_t). Hence the function
wl_get_vif_state_all can only ever return true/false. The only in-tree
caller uses its return value as a boolean. So update its return type,
and since the list traversal and bit testing have no side effects,
just return true immediately. Its return value tells if any vif is up,
so also rename it to brcmf_get_vif_state_any.

Reviewed-by: Arend van Spriel <arend@broadcom.com>
Signed-off-by: Rasmus Villemoes <linux@rasmusvillemoes.dk>
---

Notes:
    v2: Rename wl_get_vif_state_all => brcmf_get_vif_state_any as
        requested by Arend.

 drivers/net/wireless/brcm80211/brcmfmac/p2p.c         | 2 +-
 drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c | 7 +++----
 drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.h | 2 +-
 3 files changed, 5 insertions(+), 6 deletions(-)

diff --git a/drivers/net/wireless/brcm80211/brcmfmac/p2p.c b/drivers/net/wireless/brcm80211/brcmfmac/p2p.c
index f3445ac..588fdbd 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/p2p.c
+++ b/drivers/net/wireless/brcm80211/brcmfmac/p2p.c
@@ -708,7 +708,7 @@ static s32 brcmf_p2p_escan(struct brcmf_p2p_info *p2p, u32 num_chans,
 		active = P2PAPI_SCAN_SOCIAL_DWELL_TIME_MS;
 	else if (num_chans == AF_PEER_SEARCH_CNT)
 		active = P2PAPI_SCAN_AF_SEARCH_DWELL_TIME_MS;
-	else if (wl_get_vif_state_all(p2p->cfg, BRCMF_VIF_STATUS_CONNECTED))
+	else if (brcmf_get_vif_state_any(p2p->cfg, BRCMF_VIF_STATUS_CONNECTED))
 		active = -1;
 	else
 		active = P2PAPI_SCAN_DWELL_TIME_MS;
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c b/drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c
index d8fa276..93b1809 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c
+++ b/drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c
@@ -5625,16 +5625,15 @@ enum nl80211_iftype brcmf_cfg80211_get_iftype(struct brcmf_if *ifp)
 	return wdev->iftype;
 }
 
-u32 wl_get_vif_state_all(struct brcmf_cfg80211_info *cfg, unsigned long state)
+bool brcmf_get_vif_state_any(struct brcmf_cfg80211_info *cfg, unsigned long state)
 {
 	struct brcmf_cfg80211_vif *vif;
-	bool result = 0;
 
 	list_for_each_entry(vif, &cfg->vif_list, list) {
 		if (test_bit(state, &vif->sme_state))
-			result++;
+			return true;
 	}
-	return result;
+	return false;
 }
 
 static inline bool vif_event_equals(struct brcmf_cfg80211_vif_event *event,
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.h b/drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.h
index 283c525..f9fb109 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.h
+++ b/drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.h
@@ -477,7 +477,7 @@ const struct brcmf_tlv *
 brcmf_parse_tlvs(const void *buf, int buflen, uint key);
 u16 channel_to_chanspec(struct brcmu_d11inf *d11inf,
 			struct ieee80211_channel *ch);
-u32 wl_get_vif_state_all(struct brcmf_cfg80211_info *cfg, unsigned long state);
+bool brcmf_get_vif_state_any(struct brcmf_cfg80211_info *cfg, unsigned long state);
 void brcmf_cfg80211_arm_vif_event(struct brcmf_cfg80211_info *cfg,
 				  struct brcmf_cfg80211_vif *vif);
 bool brcmf_cfg80211_vif_event_armed(struct brcmf_cfg80211_info *cfg);
-- 
1.9.2
