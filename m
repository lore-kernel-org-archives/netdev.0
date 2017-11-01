From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next] net: systemport: Only inspect valid switch port & queues
Date: Wed,  1 Nov 2017 11:29:47 -0700
Message-ID: <20171101182947.31886-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:51181 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751587AbdKAS3x (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Nov 2017 14:29:53 -0400
Received: by mail-pg0-f66.google.com with SMTP id y5so2805636pgq.7
        for <netdev@vger.kernel.org>; Wed, 01 Nov 2017 11:29:53 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hesoteric board configurations where port 0 is not available would still
make SYSTEMPORT inspect the switch port 0, queue 0, which, not being
enabled, would cause transmit timeouts over time. Just ignore those
unconfigured rings instead.

Fixes: 84ff33eeb23d ("net: systemport: Establish DSA network device queue mapping")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/bcmsysport.c | 9 +++++++--
 drivers/net/ethernet/broadcom/bcmsysport.h | 1 +
 2 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bcmsysport.c b/drivers/net/ethernet/broadcom/bcmsysport.c
index dcee843d05d7..e6da9b165bbe 100644
--- a/drivers/net/ethernet/broadcom/bcmsysport.c
+++ b/drivers/net/ethernet/broadcom/bcmsysport.c
@@ -1420,8 +1420,12 @@ static int bcm_sysport_init_tx_ring(struct bcm_sysport_priv *priv,
 	/* Configure QID and port mapping */
 	reg = tdma_readl(priv, TDMA_DESC_RING_MAPPING(index));
 	reg &= ~(RING_QID_MASK | RING_PORT_ID_MASK << RING_PORT_ID_SHIFT);
-	reg |= ring->switch_queue & RING_QID_MASK;
-	reg |= ring->switch_port << RING_PORT_ID_SHIFT;
+	if (ring->inspect) {
+		reg |= ring->switch_queue & RING_QID_MASK;
+		reg |= ring->switch_port << RING_PORT_ID_SHIFT;
+	} else {
+		reg |= RING_IGNORE_STATUS;
+	}
 	tdma_writel(priv, reg, TDMA_DESC_RING_MAPPING(index));
 	tdma_writel(priv, 0, TDMA_DESC_RING_PCP_DEI_VID(index));
 
@@ -2108,6 +2112,7 @@ static int bcm_sysport_map_queues(struct net_device *dev,
 		 */
 		ring->switch_queue = q;
 		ring->switch_port = port;
+		ring->inspect = true;
 		priv->ring_map[q + port * num_tx_queues] = ring;
 
 		/* Set all queues as being used now */
diff --git a/drivers/net/ethernet/broadcom/bcmsysport.h b/drivers/net/ethernet/broadcom/bcmsysport.h
index 82f70a6783cb..f5a984c1c986 100644
--- a/drivers/net/ethernet/broadcom/bcmsysport.h
+++ b/drivers/net/ethernet/broadcom/bcmsysport.h
@@ -714,6 +714,7 @@ struct bcm_sysport_tx_ring {
 	unsigned long	bytes;		/* bytes statistics */
 	unsigned int	switch_queue;	/* switch port queue number */
 	unsigned int	switch_port;	/* switch port queue number */
+	bool		inspect;	/* inspect switch port and queue */
 };
 
 /* Driver private structure */
-- 
2.9.3
