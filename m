From: Jon Mason <jon.mason@exar.com>
Subject: [PATCH 6/7] vxge: independent interrupt moderation
Date: Fri, 10 Dec 2010 18:03:01 -0600
Message-ID: <1292025782-16372-6-git-send-email-jon.mason@exar.com>
References: <1292025782-16372-1-git-send-email-jon.mason@exar.com>
Cc: netdev@vger.kernel.org,
	Sivakumar Subramani <sivakumar.subramani@exar.com>,
	Sreenivasa Honnur <sreenivasa.honnur@exar.com>,
	Ram Vepa <ram.vepa@exar.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f180.google.com ([209.85.161.180]:39224 "EHLO
	mail-gx0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756663Ab0LKADl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Dec 2010 19:03:41 -0500
Received: by gxk19 with SMTP id 19so2706482gxk.11
        for <netdev@vger.kernel.org>; Fri, 10 Dec 2010 16:03:40 -0800 (PST)
In-Reply-To: <1292025782-16372-1-git-send-email-jon.mason@exar.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Configure the workload clock register and TIM register for independent
interrupt moderation based on the individual vpath utilization instead
of common link utilization.  This greatly improves latency.

Signed-off-by: Jon Mason <jon.mason@exar.com>
Signed-off-by: Ram Vepa <ram.vepa@exar.com>
---
 drivers/net/vxge/vxge-config.c |   11 +++++++----
 1 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/drivers/net/vxge/vxge-config.c b/drivers/net/vxge/vxge-config.c
index 1169aa3..01c05f5 100644
--- a/drivers/net/vxge/vxge-config.c
+++ b/drivers/net/vxge/vxge-config.c
@@ -4422,8 +4422,7 @@ __vxge_hw_vpath_tim_configure(struct __vxge_hw_device *hldev, u32 vp_id)
 
 		if (config->tti.util_sel != VXGE_HW_USE_FLASH_DEFAULT) {
 			val64 &= ~VXGE_HW_TIM_CFG3_INT_NUM_UTIL_SEL(0x3f);
-			val64 |= VXGE_HW_TIM_CFG3_INT_NUM_UTIL_SEL(
-					config->tti.util_sel);
+			val64 |= VXGE_HW_TIM_CFG3_INT_NUM_UTIL_SEL(vp_id);
 		}
 
 		if (config->tti.ltimer_val != VXGE_HW_USE_FLASH_DEFAULT) {
@@ -4527,8 +4526,7 @@ __vxge_hw_vpath_tim_configure(struct __vxge_hw_device *hldev, u32 vp_id)
 
 		if (config->rti.util_sel != VXGE_HW_USE_FLASH_DEFAULT) {
 			val64 &= ~VXGE_HW_TIM_CFG3_INT_NUM_UTIL_SEL(0x3f);
-			val64 |= VXGE_HW_TIM_CFG3_INT_NUM_UTIL_SEL(
-					config->rti.util_sel);
+			val64 |= VXGE_HW_TIM_CFG3_INT_NUM_UTIL_SEL(vp_id);
 		}
 
 		if (config->rti.ltimer_val != VXGE_HW_USE_FLASH_DEFAULT) {
@@ -4549,6 +4547,11 @@ __vxge_hw_vpath_tim_configure(struct __vxge_hw_device *hldev, u32 vp_id)
 	writeq(val64, &vp_reg->tim_cfg2_int_num[VXGE_HW_VPATH_INTR_BMAP]);
 	writeq(val64, &vp_reg->tim_cfg3_int_num[VXGE_HW_VPATH_INTR_BMAP]);
 
+	val64 = VXGE_HW_TIM_WRKLD_CLC_WRKLD_EVAL_PRD(150);
+	val64 |= VXGE_HW_TIM_WRKLD_CLC_WRKLD_EVAL_DIV(0);
+	val64 |= VXGE_HW_TIM_WRKLD_CLC_CNT_RX_TX(3);
+	writeq(val64, &vp_reg->tim_wrkld_clc);
+
 	return status;
 }
 
-- 
1.7.0.4

