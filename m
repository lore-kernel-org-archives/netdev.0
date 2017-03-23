From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 2/3] net: systemport: Clear status to reduce spurious interrupts
Date: Thu, 23 Mar 2017 10:36:47 -0700
Message-ID: <20170323173648.21143-3-f.fainelli@gmail.com>
References: <20170323173648.21143-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, opendmb@gmail.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:33492 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754821AbdCWRiB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 23 Mar 2017 13:38:01 -0400
Received: by mail-wm0-f67.google.com with SMTP id n11so583723wma.0
        for <netdev@vger.kernel.org>; Thu, 23 Mar 2017 10:38:00 -0700 (PDT)
In-Reply-To: <20170323173648.21143-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Do something similar to commit d5810ca3252a ("net: bcmgenet: clear
status to reduce spurious interrupts") and clear interrupts right before
servicing them. This reduces the number of interrupts by 10K
interrupts/sec for a TX TCP session 1Gbits/sec.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/bcmsysport.c | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bcmsysport.c b/drivers/net/ethernet/broadcom/bcmsysport.c
index 986fb05529fc..c915bcfae0af 100644
--- a/drivers/net/ethernet/broadcom/bcmsysport.c
+++ b/drivers/net/ethernet/broadcom/bcmsysport.c
@@ -669,6 +669,9 @@ static unsigned int bcm_sysport_desc_rx(struct bcm_sysport_priv *priv,
 	u16 len, status;
 	struct bcm_rsb *rsb;
 
+	/* Clear status before servicing to reduce spurious interrupts */
+	intrl2_0_writel(priv, INTRL2_0_RDMA_MBDONE, INTRL2_CPU_CLEAR);
+
 	/* Determine how much we should process since last call, SYSTEMPORT Lite
 	 * groups the producer and consumer indexes into the same 32-bit
 	 * which we access using RDMA_CONS_INDEX
@@ -814,6 +817,13 @@ static unsigned int __bcm_sysport_tx_reclaim(struct bcm_sysport_priv *priv,
 	struct bcm_sysport_cb *cb;
 	u32 hw_ind;
 
+	/* Clear status before servicing to reduce spurious interrupts */
+	if (!ring->priv->is_lite)
+		intrl2_1_writel(ring->priv, BIT(ring->index), INTRL2_CPU_CLEAR);
+	else
+		intrl2_0_writel(ring->priv, BIT(ring->index +
+				INTRL2_0_TDMA_MBDONE_SHIFT), INTRL2_CPU_CLEAR);
+
 	/* Compute how many descriptors have been processed since last call */
 	hw_ind = tdma_readl(priv, TDMA_DESC_RING_PROD_CONS_INDEX(ring->index));
 	c_index = (hw_ind >> RING_CONS_INDEX_SHIFT) & RING_CONS_INDEX_MASK;
-- 
2.9.3
