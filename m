From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 19/28] brcmfmac: avoid maybe-uninitialized warning in brcmf_cfg80211_start_ap
Date: Tue, 18 Oct 2016 00:13:40 +0200
Message-ID: <20161017221355.1861551-7-arnd@arndb.de>
References: <20161017220342.1627073-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
        linux-kernel@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>,
        Hante Meuleman <hante.meuleman@broadcom.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        Franky Lin <franky.lin@broadcom.com>,
        Pieter-Paul Giesberts <pieter-paul.giesberts@broadcom.com>,
        "Franky (Zhenhui) Lin" <frankyl@broadcom.com>,
        =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <rafal@milecki.pl>,
        linux-wireless@vger.kernel.org,
        brcm80211-dev-list.pdl@broadcom.com, netdev@vger.kernel.org
To: Arend van Spriel <arend.vanspriel@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.130]:49231 "EHLO
        mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754096AbcJQWQO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Oct 2016 18:16:14 -0400
In-Reply-To: <20161017220342.1627073-1-arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A bugfix added a sanity check around the assignment and use of the
'is_11d' variable, which looks correct to me, but as the function is
rather complex already, this confuses the compiler to the point where
it can no longer figure out if the variable is always initialized
correctly:

brcm80211/brcmfmac/cfg80211.c: In function ‘brcmf_cfg80211_start_ap’:
brcm80211/brcmfmac/cfg80211.c:4586:10: error: ‘is_11d’ may be used uninitialized in this function [-Werror=maybe-uninitialized]

This adds an initialization for the newly introduced case in which
the variable should not really be used, in order to make the warning
go away.

Fixes: b3589dfe0212 ("brcmfmac: ignore 11d configuration errors")
Cc: Hante Meuleman <hante.meuleman@broadcom.com>
Cc: Arend van Spriel <arend.vanspriel@broadcom.com>
Cc: Kalle Valo <kvalo@codeaurora.org>
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.c b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.c
index b777e1b..78d9966 100644
--- a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.c
+++ b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.c
@@ -4516,7 +4516,7 @@ brcmf_cfg80211_start_ap(struct wiphy *wiphy, struct net_device *ndev,
 	/* store current 11d setting */
 	if (brcmf_fil_cmd_int_get(ifp, BRCMF_C_GET_REGULATORY,
 				  &ifp->vif->is_11d)) {
-		supports_11d = false;
+		is_11d = supports_11d = false;
 	} else {
 		country_ie = brcmf_parse_tlvs((u8 *)settings->beacon.tail,
 					      settings->beacon.tail_len,
-- 
2.9.0
