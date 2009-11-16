From: zealcook@gmail.com
Subject: [PATCH 1/2] KS8695: fix ks8695_rx_irq() bug.
Date: Mon, 16 Nov 2009 22:30:18 +0800
Message-ID: <1258381819-10324-1-git-send-email-jie.zeng@soliton.com.cn>
Cc: ben@simtec.co.uk, davem@davemloft.net,
	"jie.zeng" <jie.zeng@soliton.com.cn>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f221.google.com ([209.85.220.221]:55184 "EHLO
	mail-fx0-f221.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753702AbZKPOaX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2009 09:30:23 -0500
Received: by fxm21 with SMTP id 21so2750860fxm.21
        for <netdev@vger.kernel.org>; Mon, 16 Nov 2009 06:30:28 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: jie.zeng <jie.zeng@soliton.com.cn>

ks8695 rx irq is edge-level. Before arriving at irq handler, the
corresponding status bit has been clear(irq's ack).
So we should not check it after that.

Signed-off-by: jie.zeng <jie.zeng@soliton.com.cn>
---
 drivers/net/arm/ks8695net.c |   20 +++++++-------------
 1 files changed, 7 insertions(+), 13 deletions(-)

diff --git a/drivers/net/arm/ks8695net.c b/drivers/net/arm/ks8695net.c
index 0073d19..64c683d 100644
--- a/drivers/net/arm/ks8695net.c
+++ b/drivers/net/arm/ks8695net.c
@@ -433,24 +433,18 @@ ks8695_rx_irq(int irq, void *dev_id)
 {
 	struct net_device *ndev = (struct net_device *)dev_id;
 	struct ks8695_priv *ksp = netdev_priv(ndev);
-	unsigned long status;
-
-	unsigned long mask_bit = 1 << ks8695_get_rx_enable_bit(ksp);
 
 	spin_lock(&ksp->rx_lock);
 
 	status = readl(KS8695_IRQ_VA + KS8695_INTST);
 
-	/*clean rx status bit*/
-	writel(status | mask_bit , KS8695_IRQ_VA + KS8695_INTST);
-
-	if (status & mask_bit) {
-		if (napi_schedule_prep(&ksp->napi)) {
-			/*disable rx interrupt*/
-			status &= ~mask_bit;
-			writel(status , KS8695_IRQ_VA + KS8695_INTEN);
-			__napi_schedule(&ksp->napi);
-		}
+	if (napi_schedule_prep(&ksp->napi)) {
+		unsigned long status;
+		unsigned long mask_bit = 1 << ks8695_get_rx_enable_bit(ksp);
+		/*disable rx interrupt*/
+		status &= ~mask_bit;
+		writel(status , KS8695_IRQ_VA + KS8695_INTEN);
+		__napi_schedule(&ksp->napi);
 	}
 
 	spin_unlock(&ksp->rx_lock);
-- 
1.4.4.4

