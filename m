From: sunil.kovvuri@gmail.com
Subject: [PATCH v2 21/21] net: thunderx: Don't set RX_PACKET_DIS while initializing
Date: Fri, 12 Aug 2016 16:51:44 +0530
Message-ID: <1471000904-21715-22-git-send-email-sunil.kovvuri@gmail.com>
References: <1471000904-21715-1-git-send-email-sunil.kovvuri@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	Sunil Goutham <sgoutham@cavium.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f68.google.com ([209.85.220.68]:35814 "EHLO
	mail-pa0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753162AbcHLLXX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Aug 2016 07:23:23 -0400
In-Reply-To: <1471000904-21715-1-git-send-email-sunil.kovvuri@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sunil Goutham <sgoutham@cavium.com>

Setting BGXX_SPUX_MISC_CONTROL::RX_PACKET_DIS is not needed as
packet reception is anyway disabled by BGXX_CMRX_CONFIG::DATA_PKT_RX_EN.
Also setting RX_PACKET_DIS causes a bogus remote fault condition
which delays link detection.

Signed-off-by: Sunil Goutham <sgoutham@cavium.com>
---
 drivers/net/ethernet/cavium/thunder/thunder_bgx.c | 18 +++++++-----------
 1 file changed, 7 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/cavium/thunder/thunder_bgx.c b/drivers/net/ethernet/cavium/thunder/thunder_bgx.c
index ca58d7f..8bbaedb 100644
--- a/drivers/net/ethernet/cavium/thunder/thunder_bgx.c
+++ b/drivers/net/ethernet/cavium/thunder/thunder_bgx.c
@@ -459,12 +459,14 @@ static int bgx_lmac_xaui_init(struct bgx *bgx, struct lmac *lmac)
 
 	bgx_reg_modify(bgx, lmacid, BGX_SPUX_CONTROL1, SPU_CTL_LOW_POWER);
 	/* Set interleaved running disparity for RXAUI */
-	if (lmac->lmac_type != BGX_MODE_RXAUI)
-		bgx_reg_modify(bgx, lmacid,
-			       BGX_SPUX_MISC_CONTROL, SPU_MISC_CTL_RX_DIS);
-	else
+	if (lmac->lmac_type == BGX_MODE_RXAUI)
 		bgx_reg_modify(bgx, lmacid, BGX_SPUX_MISC_CONTROL,
-			       SPU_MISC_CTL_RX_DIS | SPU_MISC_CTL_INTLV_RDISP);
+			       SPU_MISC_CTL_INTLV_RDISP);
+
+	/* Clear receive packet disable */
+	cfg = bgx_reg_read(bgx, lmacid, BGX_SPUX_MISC_CONTROL);
+	cfg &= ~SPU_MISC_CTL_RX_DIS;
+	bgx_reg_write(bgx, lmacid, BGX_SPUX_MISC_CONTROL, cfg);
 
 	/* clear all interrupts */
 	cfg = bgx_reg_read(bgx, lmacid, BGX_SMUX_RX_INT);
@@ -537,7 +539,6 @@ static int bgx_xaui_check_link(struct lmac *lmac)
 	int lmac_type = lmac->lmac_type;
 	u64 cfg;
 
-	bgx_reg_modify(bgx, lmacid, BGX_SPUX_MISC_CONTROL, SPU_MISC_CTL_RX_DIS);
 	if (lmac->use_training) {
 		cfg = bgx_reg_read(bgx, lmacid, BGX_SPUX_INT);
 		if (!(cfg & (1ull << 13))) {
@@ -607,11 +608,6 @@ static int bgx_xaui_check_link(struct lmac *lmac)
 		return -1;
 	}
 
-	/* Clear receive packet disable */
-	cfg = bgx_reg_read(bgx, lmacid, BGX_SPUX_MISC_CONTROL);
-	cfg &= ~SPU_MISC_CTL_RX_DIS;
-	bgx_reg_write(bgx, lmacid, BGX_SPUX_MISC_CONTROL, cfg);
-
 	/* Check for MAC RX faults */
 	cfg = bgx_reg_read(bgx, lmacid, BGX_SMUX_RX_CTL);
 	/* 0 - Link is okay, 1 - Local fault, 2 - Remote fault */
-- 
2.7.4
