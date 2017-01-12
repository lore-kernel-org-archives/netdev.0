From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net] net: systemport: Decouple flow control from __bcm_sysport_tx_reclaim
Date: Thu, 12 Jan 2017 12:09:09 -0800
Message-ID: <20170112200909.26825-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:35462 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750780AbdALVEd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2017 16:04:33 -0500
Received: by mail-pf0-f195.google.com with SMTP id f144so4980196pfa.2
        for <netdev@vger.kernel.org>; Thu, 12 Jan 2017 13:04:33 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The __bcm_sysport_tx_reclaim() function is used to reclaim transmit
resources in different places within the driver. Most of them should
not affect the state of the transit flow control.

Introduce bcm_sysport_tx_clean() which cleans the ring, but does not
re-enable flow control towards the networking stack, and make
bcm_sysport_tx_reclaim() do the actual transmit queue flow control.

Fixes: 80105befdb4b ("net: systemport: add Broadcom SYSTEMPORT Ethernet MAC driver")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/bcmsysport.c | 25 ++++++++++++++++++-------
 1 file changed, 18 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bcmsysport.c b/drivers/net/ethernet/broadcom/bcmsysport.c
index 7e8cf213fd81..744ed6ddaf37 100644
--- a/drivers/net/ethernet/broadcom/bcmsysport.c
+++ b/drivers/net/ethernet/broadcom/bcmsysport.c
@@ -710,11 +710,8 @@ static unsigned int __bcm_sysport_tx_reclaim(struct bcm_sysport_priv *priv,
 	unsigned int c_index, last_c_index, last_tx_cn, num_tx_cbs;
 	unsigned int pkts_compl = 0, bytes_compl = 0;
 	struct bcm_sysport_cb *cb;
-	struct netdev_queue *txq;
 	u32 hw_ind;
 
-	txq = netdev_get_tx_queue(ndev, ring->index);
-
 	/* Compute how many descriptors have been processed since last call */
 	hw_ind = tdma_readl(priv, TDMA_DESC_RING_PROD_CONS_INDEX(ring->index));
 	c_index = (hw_ind >> RING_CONS_INDEX_SHIFT) & RING_CONS_INDEX_MASK;
@@ -745,9 +742,6 @@ static unsigned int __bcm_sysport_tx_reclaim(struct bcm_sysport_priv *priv,
 
 	ring->c_index = c_index;
 
-	if (netif_tx_queue_stopped(txq) && pkts_compl)
-		netif_tx_wake_queue(txq);
-
 	netif_dbg(priv, tx_done, ndev,
 		  "ring=%d c_index=%d pkts_compl=%d, bytes_compl=%d\n",
 		  ring->index, ring->c_index, pkts_compl, bytes_compl);
@@ -759,16 +753,33 @@ static unsigned int __bcm_sysport_tx_reclaim(struct bcm_sysport_priv *priv,
 static unsigned int bcm_sysport_tx_reclaim(struct bcm_sysport_priv *priv,
 					   struct bcm_sysport_tx_ring *ring)
 {
+	struct netdev_queue *txq;
 	unsigned int released;
 	unsigned long flags;
 
+	txq = netdev_get_tx_queue(priv->netdev, ring->index);
+
 	spin_lock_irqsave(&ring->lock, flags);
 	released = __bcm_sysport_tx_reclaim(priv, ring);
+	if (released)
+		netif_tx_wake_queue(txq);
+
 	spin_unlock_irqrestore(&ring->lock, flags);
 
 	return released;
 }
 
+/* Locked version of the per-ring TX reclaim, but does not wake the queue */
+static void bcm_sysport_tx_clean(struct bcm_sysport_priv *priv,
+				 struct bcm_sysport_tx_ring *ring)
+{
+	unsigned long flags;
+
+	spin_lock_irqsave(&ring->lock, flags);
+	__bcm_sysport_tx_reclaim(priv, ring);
+	spin_unlock_irqrestore(&ring->lock, flags);
+}
+
 static int bcm_sysport_tx_poll(struct napi_struct *napi, int budget)
 {
 	struct bcm_sysport_tx_ring *ring =
@@ -1252,7 +1263,7 @@ static void bcm_sysport_fini_tx_ring(struct bcm_sysport_priv *priv,
 	napi_disable(&ring->napi);
 	netif_napi_del(&ring->napi);
 
-	bcm_sysport_tx_reclaim(priv, ring);
+	bcm_sysport_tx_clean(priv, ring);
 
 	kfree(ring->cbs);
 	ring->cbs = NULL;
-- 
2.9.3
