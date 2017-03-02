From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 07/26] brcmsmac: reduce stack size with KASAN
Date: Thu,  2 Mar 2017 17:38:15 +0100
Message-ID: <20170302163834.2273519-8-arnd@arndb.de>
References: <20170302163834.2273519-1-arnd@arndb.de>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>,
        Alexander Potapenko <glider@google.com>,
        Dmitry Vyukov <dvyukov@google.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-media@vger.kernel.org,
        linux-wireless@vger.kernel.org,
        kernel-build-reports@lists.linaro.org,
        "David S . Miller" <davem@davemloft.net>,
        Arnd Bergmann <arnd@arndb.de>
To: kasan-dev@googlegroups.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.134]:49837 "EHLO
        mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752570AbdCBRLM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Mar 2017 12:11:12 -0500
In-Reply-To: <20170302163834.2273519-1-arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The wlc_phy_table_write_nphy/wlc_phy_table_read_nphy functions always put an object
on the stack, which will each require a redzone with KASAN and lead to possible
stack overflow:

drivers/net/wireless/broadcom/brcm80211/brcmsmac/phy/phy_n.c: In function 'wlc_phy_workarounds_nphy':
drivers/net/wireless/broadcom/brcm80211/brcmsmac/phy/phy_n.c:17135:1: warning: the frame size of 6312 bytes is larger than 1000 bytes [-Wframe-larger-than=]

This marks the two functions as noinline_for_kasan, avoiding the problem entirely.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/net/wireless/broadcom/brcm80211/brcmsmac/phy/phy_n.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/broadcom/brcm80211/brcmsmac/phy/phy_n.c b/drivers/net/wireless/broadcom/brcm80211/brcmsmac/phy/phy_n.c
index b3aab2fe96eb..42dc8e1f483d 100644
--- a/drivers/net/wireless/broadcom/brcm80211/brcmsmac/phy/phy_n.c
+++ b/drivers/net/wireless/broadcom/brcm80211/brcmsmac/phy/phy_n.c
@@ -14157,7 +14157,7 @@ static void wlc_phy_bphy_init_nphy(struct brcms_phy *pi)
 	write_phy_reg(pi, NPHY_TO_BPHY_OFF + BPHY_STEP, 0x668);
 }
 
-void
+noinline_for_kasan void
 wlc_phy_table_write_nphy(struct brcms_phy *pi, u32 id, u32 len, u32 offset,
 			 u32 width, const void *data)
 {
@@ -14171,7 +14171,7 @@ wlc_phy_table_write_nphy(struct brcms_phy *pi, u32 id, u32 len, u32 offset,
 	wlc_phy_write_table_nphy(pi, &tbl);
 }
 
-void
+noinline_for_kasan void
 wlc_phy_table_read_nphy(struct brcms_phy *pi, u32 id, u32 len, u32 offset,
 			u32 width, void *data)
 {
-- 
2.9.0
