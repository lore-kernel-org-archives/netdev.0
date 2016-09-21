From: =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5@gmail.com>
Subject: [PATCH] brcmfmac: fix memory leak in brcmf_fill_bss_param
Date: Wed, 21 Sep 2016 08:23:24 +0200
Message-ID: <20160921062327.28729-1-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <rafal@milecki.pl>,
        Arend van Spriel <arend.vanspriel@broadcom.com>,
        Franky Lin <franky.lin@broadcom.com>,
        Hante Meuleman <hante.meuleman@broadcom.com>,
        Pieter-Paul Giesberts <pieter-paul.giesberts@broadcom.com>,
        "Franky (Zhenhui) Lin" <frankyl@broadcom.com>,
        linux-wireless@vger.kernel.org (open list:BROADCOM BRCM80211
        IEEE802.11n WIRELESS DRIVER),
        brcm80211-dev-list.pdl@broadcom.com (open list:BROADCOM BRCM80211
        IEEE802.11n WIRELESS DRIVER),
        netdev@vger.kernel.org (open list:NETWORKING DRIVERS),
        linux-kernel@vger.kernel.org (open list)
To: Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rafał Miłecki <rafal@milecki.pl>

This function is called from get_station callback which means that every
time user space was getting/dumping station(s) we were leaking 2 KiB.

Signed-off-by: Rafał Miłecki <rafal@milecki.pl>
Fixes: 1f0dc59a6de ("brcmfmac: rework .get_station() callback")
Cc: stable@vger.kernel.org # 4.2+
---
Kalle, ideally this should go as 4.8 fix, but I'm aware it's quite late.
If you are not planning to send another pull request, just get it for
the next release and let's let stable guys backport it.
---
 drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.c b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.c
index b8aec5e5..62a7675 100644
--- a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.c
+++ b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.c
@@ -2533,7 +2533,7 @@ static void brcmf_fill_bss_param(struct brcmf_if *ifp, struct station_info *si)
 				     WL_BSS_INFO_MAX);
 	if (err) {
 		brcmf_err("Failed to get bss info (%d)\n", err);
-		return;
+		goto out_kfree;
 	}
 	si->filled |= BIT(NL80211_STA_INFO_BSS_PARAM);
 	si->bss_param.beacon_interval = le16_to_cpu(buf->bss_le.beacon_period);
@@ -2545,6 +2545,9 @@ static void brcmf_fill_bss_param(struct brcmf_if *ifp, struct station_info *si)
 		si->bss_param.flags |= BSS_PARAM_FLAGS_SHORT_PREAMBLE;
 	if (capability & WLAN_CAPABILITY_SHORT_SLOT_TIME)
 		si->bss_param.flags |= BSS_PARAM_FLAGS_SHORT_SLOT_TIME;
+
+out_kfree:
+	kfree(buf);
 }
 
 static s32
-- 
2.9.3
