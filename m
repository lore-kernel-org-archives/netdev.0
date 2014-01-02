From: Hauke Mehrtens <hauke@hauke-m.de>
Subject: [PATCH 3/5] bgmac: add support for new BGMAC_CMDCFG_SR position on core rev >= 4
Date: Thu,  2 Jan 2014 20:19:00 +0100
Message-ID: <1388690342-27213-3-git-send-email-hauke@hauke-m.de>
References: <1388690342-27213-1-git-send-email-hauke@hauke-m.de>
Cc: zajec5@gmail.com, netdev@vger.kernel.org,
	Hauke Mehrtens <hauke@hauke-m.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from server19320154104.serverpool.info ([193.201.54.104]:51592 "EHLO
	hauke-m.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751406AbaABTTQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Jan 2014 14:19:16 -0500
In-Reply-To: <1388690342-27213-1-git-send-email-hauke@hauke-m.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The BGMAC_CMDCFG_SR register is at a different position on core rev >= 4

Signed-off-by: Hauke Mehrtens <hauke@hauke-m.de>
---
 drivers/net/ethernet/broadcom/bgmac.c |    8 ++++----
 drivers/net/ethernet/broadcom/bgmac.h |    4 +++-
 2 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/ethernet/broadcom/bgmac.c
index aa5e289..88ec69e 100644
--- a/drivers/net/ethernet/broadcom/bgmac.c
+++ b/drivers/net/ethernet/broadcom/bgmac.c
@@ -768,13 +768,13 @@ static void bgmac_cmdcfg_maskset(struct bgmac *bgmac, u32 mask, u32 set,
 	u32 cmdcfg = bgmac_read(bgmac, BGMAC_CMDCFG);
 	u32 new_val = (cmdcfg & mask) | set;
 
-	bgmac_set(bgmac, BGMAC_CMDCFG, BGMAC_CMDCFG_SR);
+	bgmac_set(bgmac, BGMAC_CMDCFG, BGMAC_CMDCFG_SR(bgmac->core->id.rev));
 	udelay(2);
 
 	if (new_val != cmdcfg || force)
 		bgmac_write(bgmac, BGMAC_CMDCFG, new_val);
 
-	bgmac_mask(bgmac, BGMAC_CMDCFG, ~BGMAC_CMDCFG_SR);
+	bgmac_mask(bgmac, BGMAC_CMDCFG, ~BGMAC_CMDCFG_SR(bgmac->core->id.rev));
 	udelay(2);
 }
 
@@ -977,7 +977,7 @@ static void bgmac_chip_reset(struct bgmac *bgmac)
 			     BGMAC_CMDCFG_PROM |
 			     BGMAC_CMDCFG_NLC |
 			     BGMAC_CMDCFG_CFE |
-			     BGMAC_CMDCFG_SR,
+			     BGMAC_CMDCFG_SR(core->id.rev),
 			     false);
 	bgmac->mac_speed = SPEED_UNKNOWN;
 	bgmac->mac_duplex = DUPLEX_UNKNOWN;
@@ -1020,7 +1020,7 @@ static void bgmac_enable(struct bgmac *bgmac)
 
 	cmdcfg = bgmac_read(bgmac, BGMAC_CMDCFG);
 	bgmac_cmdcfg_maskset(bgmac, ~(BGMAC_CMDCFG_TE | BGMAC_CMDCFG_RE),
-			     BGMAC_CMDCFG_SR, true);
+			     BGMAC_CMDCFG_SR(bgmac->core->id.rev), true);
 	udelay(2);
 	cmdcfg |= BGMAC_CMDCFG_TE | BGMAC_CMDCFG_RE;
 	bgmac_write(bgmac, BGMAC_CMDCFG, cmdcfg);
diff --git a/drivers/net/ethernet/broadcom/bgmac.h b/drivers/net/ethernet/broadcom/bgmac.h
index 71adac9..ceeaac6 100644
--- a/drivers/net/ethernet/broadcom/bgmac.h
+++ b/drivers/net/ethernet/broadcom/bgmac.h
@@ -197,7 +197,9 @@
 #define  BGMAC_CMDCFG_TAI			0x00000200
 #define  BGMAC_CMDCFG_HD			0x00000400	/* Set if in half duplex mode */
 #define  BGMAC_CMDCFG_HD_SHIFT			10
-#define  BGMAC_CMDCFG_SR			0x00000800	/* Set to reset mode */
+#define  BGMAC_CMDCFG_SR_REVO			0x00000800	/* Set to reset mode, for other revs */
+#define  BGMAC_CMDCFG_SR_REV4			0x00002000	/* Set to reset mode, only for core rev 4 */
+#define  BGMAC_CMDCFG_SR(rev)  ((rev >= 4) ? BGMAC_CMDCFG_SR_REV4 : BGMAC_CMDCFG_SR_REVO)
 #define  BGMAC_CMDCFG_ML			0x00008000	/* Set to activate mac loopback mode */
 #define  BGMAC_CMDCFG_AE			0x00400000
 #define  BGMAC_CMDCFG_CFE			0x00800000
-- 
1.7.10.4
