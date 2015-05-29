From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2 1/3] net: systemport: Pre-calculate and utilize cb->bd_addr
Date: Fri, 29 May 2015 09:42:15 -0700
Message-ID: <1432917737-16793-2-git-send-email-f.fainelli@gmail.com>
References: <1432917737-16793-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, pgynther@google.com,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:35992 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756950AbbE2QuL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2015 12:50:11 -0400
Received: by pdfh10 with SMTP id h10so57474177pdf.3
        for <netdev@vger.kernel.org>; Fri, 29 May 2015 09:50:10 -0700 (PDT)
In-Reply-To: <1432917737-16793-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is a 1:1 mapping between the software maintained control block in
priv->rx_cbs and the buffer address in priv->rx_bds, such that there is
no need to keep computing the buffer address when refiling a control
block.

Reviewed-by: Petri Gynther <pgynther@google.com>
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/bcmsysport.c | 18 +++++++++---------
 drivers/net/ethernet/broadcom/bcmsysport.h |  2 --
 2 files changed, 9 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bcmsysport.c b/drivers/net/ethernet/broadcom/bcmsysport.c
index 084a50a555de..267330ccd595 100644
--- a/drivers/net/ethernet/broadcom/bcmsysport.c
+++ b/drivers/net/ethernet/broadcom/bcmsysport.c
@@ -549,12 +549,7 @@ static int bcm_sysport_rx_refill(struct bcm_sysport_priv *priv,
 	}
 
 	dma_unmap_addr_set(cb, dma_addr, mapping);
-	dma_desc_set_addr(priv, priv->rx_bd_assign_ptr, mapping);
-
-	priv->rx_bd_assign_index++;
-	priv->rx_bd_assign_index &= (priv->num_rx_bds - 1);
-	priv->rx_bd_assign_ptr = priv->rx_bds +
-		(priv->rx_bd_assign_index * DESC_SIZE);
+	dma_desc_set_addr(priv, cb->bd_addr, mapping);
 
 	netif_dbg(priv, rx_status, ndev, "RX refill\n");
 
@@ -568,7 +563,7 @@ static int bcm_sysport_alloc_rx_bufs(struct bcm_sysport_priv *priv)
 	unsigned int i;
 
 	for (i = 0; i < priv->num_rx_bds; i++) {
-		cb = &priv->rx_cbs[priv->rx_bd_assign_index];
+		cb = &priv->rx_cbs[i];
 		if (cb->skb)
 			continue;
 
@@ -1330,14 +1325,14 @@ static inline int tdma_enable_set(struct bcm_sysport_priv *priv,
 
 static int bcm_sysport_init_rx_ring(struct bcm_sysport_priv *priv)
 {
+	struct bcm_sysport_cb *cb;
 	u32 reg;
 	int ret;
+	int i;
 
 	/* Initialize SW view of the RX ring */
 	priv->num_rx_bds = NUM_RX_DESC;
 	priv->rx_bds = priv->base + SYS_PORT_RDMA_OFFSET;
-	priv->rx_bd_assign_ptr = priv->rx_bds;
-	priv->rx_bd_assign_index = 0;
 	priv->rx_c_index = 0;
 	priv->rx_read_ptr = 0;
 	priv->rx_cbs = kcalloc(priv->num_rx_bds, sizeof(struct bcm_sysport_cb),
@@ -1347,6 +1342,11 @@ static int bcm_sysport_init_rx_ring(struct bcm_sysport_priv *priv)
 		return -ENOMEM;
 	}
 
+	for (i = 0; i < priv->num_rx_bds; i++) {
+		cb = priv->rx_cbs + i;
+		cb->bd_addr = priv->rx_bds + i * DESC_SIZE;
+	}
+
 	ret = bcm_sysport_alloc_rx_bufs(priv);
 	if (ret) {
 		netif_err(priv, hw, priv->netdev, "SKB allocation failed\n");
diff --git a/drivers/net/ethernet/broadcom/bcmsysport.h b/drivers/net/ethernet/broadcom/bcmsysport.h
index 42a4b4a0bc14..f28bf545d7f4 100644
--- a/drivers/net/ethernet/broadcom/bcmsysport.h
+++ b/drivers/net/ethernet/broadcom/bcmsysport.h
@@ -663,8 +663,6 @@ struct bcm_sysport_priv {
 
 	/* Receive queue */
 	void __iomem		*rx_bds;
-	void __iomem		*rx_bd_assign_ptr;
-	unsigned int		rx_bd_assign_index;
 	struct bcm_sysport_cb	*rx_cbs;
 	unsigned int		num_rx_bds;
 	unsigned int		rx_read_ptr;
-- 
2.1.0
