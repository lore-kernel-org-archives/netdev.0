From: Tobias Regnery <tobias.regnery@gmail.com>
Subject: [PATCH net-next 2/4] alx: factor out part of the interrupt handler
Date: Fri,  9 Sep 2016 12:19:53 +0200
Message-ID: <562afaca7ba46bc937da523245a9e40aaf7c4e15.1473404401.git.tobias.regnery@gmail.com>
References: <cover.1473404399.git.tobias.regnery@gmail.com>
Cc: davem@davemloft.net, feng.tang@intel.com, jarod@redhat.com,
        Tobias Regnery <tobias.regnery@gmail.com>
To: netdev@vger.kernel.org, jcliburn@gmail.com, chris.snook@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:33767 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754072AbcIIKUR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Sep 2016 06:20:17 -0400
Received: by mail-wm0-f67.google.com with SMTP id b187so2057939wme.0
        for <netdev@vger.kernel.org>; Fri, 09 Sep 2016 03:20:16 -0700 (PDT)
In-Reply-To: <cover.1473404399.git.tobias.regnery@gmail.com>
In-Reply-To: <cover.1473404399.git.tobias.regnery@gmail.com>
References: <cover.1473404399.git.tobias.regnery@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Factor out the handling of misc interrupts into a new function.
This function can be reused later for msi-x interrupts.

Signed-off-by: Tobias Regnery <tobias.regnery@gmail.com>
---
 drivers/net/ethernet/atheros/alx/main.c | 34 +++++++++++++++++++--------------
 1 file changed, 20 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/atheros/alx/main.c b/drivers/net/ethernet/atheros/alx/main.c
index 6dc1539205eb..b34f7b693cec 100644
--- a/drivers/net/ethernet/atheros/alx/main.c
+++ b/drivers/net/ethernet/atheros/alx/main.c
@@ -302,22 +302,15 @@ static int alx_poll(struct napi_struct *napi, int budget)
 	return work;
 }
 
-static irqreturn_t alx_intr_handle(struct alx_priv *alx, u32 intr)
+static bool alx_intr_handle_misc(struct alx_priv *alx, u32 intr)
 {
 	struct alx_hw *hw = &alx->hw;
-	bool write_int_mask = false;
-
-	spin_lock(&alx->irq_lock);
-
-	/* ACK interrupt */
-	alx_write_mem32(hw, ALX_ISR, intr | ALX_ISR_DIS);
-	intr &= alx->int_mask;
 
 	if (intr & ALX_ISR_FATAL) {
 		netif_warn(alx, hw, alx->dev,
 			   "fatal interrupt 0x%x, resetting\n", intr);
 		alx_schedule_reset(alx);
-		goto out;
+		return true;
 	}
 
 	if (intr & ALX_ISR_ALERT)
@@ -329,19 +322,32 @@ static irqreturn_t alx_intr_handle(struct alx_priv *alx, u32 intr)
 		 * is cleared, the interrupt status could be cleared.
 		 */
 		alx->int_mask &= ~ALX_ISR_PHY;
-		write_int_mask = true;
+		alx_write_mem32(hw, ALX_IMR, alx->int_mask);
 		alx_schedule_link_check(alx);
 	}
 
+	return false;
+}
+
+static irqreturn_t alx_intr_handle(struct alx_priv *alx, u32 intr)
+{
+	struct alx_hw *hw = &alx->hw;
+
+	spin_lock(&alx->irq_lock);
+
+	/* ACK interrupt */
+	alx_write_mem32(hw, ALX_ISR, intr | ALX_ISR_DIS);
+	intr &= alx->int_mask;
+
+	if (alx_intr_handle_misc(alx, intr))
+		goto out;
+
 	if (intr & (ALX_ISR_TX_Q0 | ALX_ISR_RX_Q0)) {
 		napi_schedule(&alx->napi);
 		/* mask rx/tx interrupt, enable them when napi complete */
 		alx->int_mask &= ~ALX_ISR_ALL_QUEUES;
-		write_int_mask = true;
-	}
-
-	if (write_int_mask)
 		alx_write_mem32(hw, ALX_IMR, alx->int_mask);
+	}
 
 	alx_write_mem32(hw, ALX_ISR, 0);
 
-- 
2.7.4
