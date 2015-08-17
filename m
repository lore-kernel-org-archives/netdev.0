From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next] bnx2: Fix bandwidth allocation for some MF modes
Date: Mon, 17 Aug 2015 08:28:25 +0300
Message-ID: <1439789305-4643-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Ariel.Elior@qlogic.com>, Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:57811 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750710AbbHQF2c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Aug 2015 01:28:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Management firmware tells driver in case bandwidth configuration for
a specific function exists, but [regretably] the same field has different
meanings depending on the multi-function mode - it can either be
a percentile value or an actual speed.

For newer multi-function modes current logic is incorrect -
driver understands values as actual speeds instead of percentages,
causing the resulting chip configuration to be incorrect.

Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
Hi Dave,

This is actually a bug fix - but as some of the targeted multi-function
modes exists only in 'net-next' at this time, I'm designating this fix
to 'net-next' as well.

Please consider applying this one.

Thanks,
Yuval
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h      | 4 ++++
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c  | 2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c | 2 +-
 3 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
index 5762c48..e28c90c 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
@@ -2571,6 +2571,10 @@ void bnx2x_notify_link_changed(struct bnx2x *bp);
 			(IS_MF_SD_STORAGE_PERSONALITY_ONLY(bp) ||	\
 			 IS_MF_SI_STORAGE_PERSONALITY_ONLY(bp))
 
+/* Determines whether BW configuration arrives in 100Mb units or in
+ * percentages from actual physical link speed.
+ */
+#define IS_MF_PERCENT_BW(bp) (IS_MF_SI(bp) || IS_MF_UFP(bp) || IS_MF_BD(bp))
 
 #define SET_FLAG(value, mask, flag) \
 	do {\
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index a2bb1f0..44173be 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -1190,7 +1190,7 @@ u16 bnx2x_get_mf_speed(struct bnx2x *bp)
 		/* Calculate the current MAX line speed limit for the MF
 		 * devices
 		 */
-		if (IS_MF_SI(bp))
+		if (IS_MF_PERCENT_BW(bp))
 			line_speed = (line_speed * maxCfg) / 100;
 		else { /* SD mode */
 			u16 vn_max_rate = maxCfg * 100;
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index ad73a60..eafd25d 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -2494,7 +2494,7 @@ static void bnx2x_calc_vn_max(struct bnx2x *bp, int vn,
 	else {
 		u32 maxCfg = bnx2x_extract_max_cfg(bp, vn_cfg);
 
-		if (IS_MF_SI(bp)) {
+		if (IS_MF_PERCENT_BW(bp)) {
 			/* maxCfg in percents of linkspeed */
 			vn_max_rate = (bp->link_vars.line_speed * maxCfg) / 100;
 		} else /* SD modes */
-- 
1.9.3
