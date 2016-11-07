From: =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5@gmail.com>
Subject: [PATCH net] net: bgmac: fix reversed checks for clock control flag
Date: Mon,  7 Nov 2016 13:53:27 +0100
Message-ID: <20161107125327.5375-1-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: f.fainelli@gmail.com, bcm-kernel-feedback-list@broadcom.com,
        =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <rafal@milecki.pl>,
        Jon Mason <jon.mason@broadcom.com>
To: "David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f66.google.com ([209.85.215.66]:34473 "EHLO
        mail-lf0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752060AbcKGMyl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Nov 2016 07:54:41 -0500
Received: by mail-lf0-f66.google.com with SMTP id o141so7832690lff.1
        for <netdev@vger.kernel.org>; Mon, 07 Nov 2016 04:54:41 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rafał Miłecki <rafal@milecki.pl>

This fixes regression introduced by patch adding feature flags. It was
already reported and patch followed (it got accepted) but it appears it
was incorrect. Instead of fixing reversed condition it broke a good one.

This patch was verified to actually fix SoC hanges caused by bgmac on
BCM47186B0.

Fixes: db791eb2970b ("net: ethernet: bgmac: convert to feature flags")
Fixes: 4af1474e6198 ("net: bgmac: Fix errant feature flag check")
Cc: Jon Mason <jon.mason@broadcom.com>
Signed-off-by: Rafał Miłecki <rafal@milecki.pl>
---
It seems 4af1474e6198 was never backported to the 4.8, so I'm not Cc-ing
stable. I'll send separated patch for 4.8 once this one gets accepted.
---
 drivers/net/ethernet/broadcom/bgmac.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/ethernet/broadcom/bgmac.c
index 91cbf92..49f4cafe 100644
--- a/drivers/net/ethernet/broadcom/bgmac.c
+++ b/drivers/net/ethernet/broadcom/bgmac.c
@@ -1049,9 +1049,9 @@ static void bgmac_enable(struct bgmac *bgmac)
 
 	mode = (bgmac_read(bgmac, BGMAC_DEV_STATUS) & BGMAC_DS_MM_MASK) >>
 		BGMAC_DS_MM_SHIFT;
-	if (!(bgmac->feature_flags & BGMAC_FEAT_CLKCTLST) || mode != 0)
+	if (bgmac->feature_flags & BGMAC_FEAT_CLKCTLST || mode != 0)
 		bgmac_set(bgmac, BCMA_CLKCTLST, BCMA_CLKCTLST_FORCEHT);
-	if (bgmac->feature_flags & BGMAC_FEAT_CLKCTLST && mode == 2)
+	if (!(bgmac->feature_flags & BGMAC_FEAT_CLKCTLST) && mode == 2)
 		bgmac_cco_ctl_maskset(bgmac, 1, ~0,
 				      BGMAC_CHIPCTL_1_RXC_DLL_BYPASS);
 
-- 
2.10.1
