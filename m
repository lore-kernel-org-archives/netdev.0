From: John Crispin <blogic@openwrt.org>
Subject: [PATCH 3/3] NET: MIPS: lantiq: return value of request_irq was not handled gracefully
Date: Wed, 16 Nov 2011 15:41:48 +0100
Message-ID: <1321454508-4754-3-git-send-email-blogic@openwrt.org>
References: <1321454508-4754-1-git-send-email-blogic@openwrt.org>
Cc: John Crispin <blogic@openwrt.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbd.name ([46.4.11.11]:38284 "EHLO nbd.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757225Ab1KPNmW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Nov 2011 08:42:22 -0500
In-Reply-To: <1321454508-4754-1-git-send-email-blogic@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The return values of request_irq() were not checked leading to the following
error message.

Signed-off-by: John Crispin <blogic@openwrt.org>
Cc: netdev@vger.kernel.org
---
 drivers/net/ethernet/lantiq_etop.c |   14 ++++++++------
 1 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/lantiq_etop.c b/drivers/net/ethernet/lantiq_etop.c
index 9fd6779..dddb9fe 100644
--- a/drivers/net/ethernet/lantiq_etop.c
+++ b/drivers/net/ethernet/lantiq_etop.c
@@ -312,6 +312,7 @@ ltq_etop_hw_init(struct net_device *dev)
 {
 	struct ltq_etop_priv *priv = netdev_priv(dev);
 	unsigned int mii_mode = priv->pldata->mii_mode;
+	int err = 0;
 	int i;
 
 	ltq_pmu_enable(PMU_PPE);
@@ -356,7 +357,7 @@ ltq_etop_hw_init(struct net_device *dev)
 
 	ltq_dma_init_port(DMA_PORT_ETOP);
 
-	for (i = 0; i < MAX_DMA_CHAN; i++) {
+	for (i = 0; i < MAX_DMA_CHAN && !err; i++) {
 		int irq = LTQ_DMA_ETOP + i;
 		struct ltq_etop_chan *ch = &priv->ch[i];
 
@@ -364,21 +365,22 @@ ltq_etop_hw_init(struct net_device *dev)
 
 		if (IS_TX(i)) {
 			ltq_dma_alloc_tx(&ch->dma);
-			request_irq(irq, ltq_etop_dma_irq, IRQF_DISABLED,
+			err = request_irq(irq, ltq_etop_dma_irq, IRQF_DISABLED,
 				"etop_tx", priv);
 		} else if (IS_RX(i)) {
 			ltq_dma_alloc_rx(&ch->dma);
 			for (ch->dma.desc = 0; ch->dma.desc < LTQ_DESC_NUM;
 					ch->dma.desc++)
 				if (ltq_etop_alloc_skb(ch))
-					return -ENOMEM;
+					err = -ENOMEM;
 			ch->dma.desc = 0;
-			request_irq(irq, ltq_etop_dma_irq, IRQF_DISABLED,
+			err = request_irq(irq, ltq_etop_dma_irq, IRQF_DISABLED,
 				"etop_rx", priv);
 		}
-		ch->dma.irq = irq;
+		if (!err)
+			ch->dma.irq = irq;
 	}
-	return 0;
+	return err;
 }
 
 static void
-- 
1.7.7.1
