From: zeal <zealcook@gmail.com>
Subject: [PATCH 1/2 v2] KS8695: fix ks8695_rx_irq() bug.
Date: Mon, 16 Nov 2009 22:58:09 +0800
Message-ID: <4b016886.1d255e0a.16f1.ffff866a@mx.google.com>
Cc: ben@simtec.co.uk, davem@davemloft.net, figo1802@gmail.com,
	zeal <zealcook@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f227.google.com ([209.85.218.227]:47442 "EHLO
	mail-bw0-f227.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751232AbZKPO6K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2009 09:58:10 -0500
Received: by bwz27 with SMTP id 27so5734017bwz.21
        for <netdev@vger.kernel.org>; Mon, 16 Nov 2009 06:58:15 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: zeal <zealcook@gmail.com>

Sorry for the previously patches. THEY'RE NOT RIGHT. It's my mistake.
Please forgive my noise.
Please review the following patches and ignore the last (v1).

ks8695 rx irq is edge-level. Before arriving at irq handler, the
corresponding status bit has been clear(irq's ack).
So we should not check it after that.

Signed-off-by: zeal <zealcook@gmail.com>
---
 drivers/net/arm/ks8695net.c |   22 +++++++---------------
 1 files changed, 7 insertions(+), 15 deletions(-)

diff --git a/drivers/net/arm/ks8695net.c b/drivers/net/arm/ks8695net.c
index 0073d19..e15451a 100644
--- a/drivers/net/arm/ks8695net.c
+++ b/drivers/net/arm/ks8695net.c
@@ -433,24 +433,16 @@ ks8695_rx_irq(int irq, void *dev_id)
 {
 	struct net_device *ndev = (struct net_device *)dev_id;
 	struct ks8695_priv *ksp = netdev_priv(ndev);
-	unsigned long status;
-
-	unsigned long mask_bit = 1 << ks8695_get_rx_enable_bit(ksp);
 
 	spin_lock(&ksp->rx_lock);
 
-	status = readl(KS8695_IRQ_VA + KS8695_INTST);
-
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
+		unsigned long status = readl(KS8695_IRQ_VA + KS8695_INTEN);
+		unsigned long mask_bit = 1 << ks8695_get_rx_enable_bit(ksp);
+		/*disable rx interrupt*/
+		status &= ~mask_bit;
+		writel(status , KS8695_IRQ_VA + KS8695_INTEN);
+		__napi_schedule(&ksp->napi);
 	}
 
 	spin_unlock(&ksp->rx_lock);
-- 
1.5.6.5

