From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net] net: dsa: bcm_sf2: Fix race condition while unmasking interrupts
Date: Wed, 24 Aug 2016 11:01:20 -0700
Message-ID: <1472061680-24429-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:36716 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754475AbcHXSBr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 Aug 2016 14:01:47 -0400
Received: by mail-pf0-f196.google.com with SMTP id y134so1616200pfg.3
        for <netdev@vger.kernel.org>; Wed, 24 Aug 2016 11:01:24 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We kept shadow copies of which interrupt sources we have enabled and
disabled, but due to an order bug in how intrl2_mask_clear was defined,
we could run into the following scenario:

CPU0					CPU1
intrl2_1_mask_clear(..)
sets INTRL2_CPU_MASK_CLEAR
					bcm_sf2_switch_1_isr
					read INTRL2_CPU_STATUS and masks with stale
					irq1_mask value
updates irq1_mask value

Which would make us loop again and again trying to process and interrupt
we are not clearing since our copy of whether it was enabled before
still indicates it was not. Fix this by updating the shadow copy first,
and then unasking at the HW level.

Fixes: 246d7f773c13 ("net: dsa: add Broadcom SF2 switch driver")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/dsa/bcm_sf2.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/dsa/bcm_sf2.h b/drivers/net/dsa/bcm_sf2.h
index 463bed8cbe4c..dd446e466699 100644
--- a/drivers/net/dsa/bcm_sf2.h
+++ b/drivers/net/dsa/bcm_sf2.h
@@ -205,8 +205,8 @@ static inline void name##_writeq(struct bcm_sf2_priv *priv, u64 val,	\
 static inline void intrl2_##which##_mask_clear(struct bcm_sf2_priv *priv, \
 						u32 mask)		\
 {									\
-	intrl2_##which##_writel(priv, mask, INTRL2_CPU_MASK_CLEAR);	\
 	priv->irq##which##_mask &= ~(mask);				\
+	intrl2_##which##_writel(priv, mask, INTRL2_CPU_MASK_CLEAR);	\
 }									\
 static inline void intrl2_##which##_mask_set(struct bcm_sf2_priv *priv, \
 						u32 mask)		\
-- 
2.7.4
