From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 5/5] net: systemport: Turn on ACB at the SYSTEMPORT level
Date: Wed, 11 Oct 2017 10:57:52 -0700
Message-ID: <20171011175752.22030-6-f.fainelli@gmail.com>
References: <20171011175752.22030-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f193.google.com ([209.85.216.193]:48607 "EHLO
        mail-qt0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757594AbdJKR7m (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2017 13:59:42 -0400
Received: by mail-qt0-f193.google.com with SMTP id f8so7755902qta.5
        for <netdev@vger.kernel.org>; Wed, 11 Oct 2017 10:59:42 -0700 (PDT)
In-Reply-To: <20171011175752.22030-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that we have established the queue mapping between the switch port
egress queues and the SYSTEMPORT egress queues, we can turn on Advanced
Congestion Buffering (ACB) at the SYSTEMPORT level. This enables the
Ethernet MAC controller to get out of band flow control information
directly from the switch port and queue that it monitors such that its
internal TDMA can be appropriately backpressured.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/bcmsysport.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bcmsysport.c b/drivers/net/ethernet/broadcom/bcmsysport.c
index 78bed9a84e81..dafc26690555 100644
--- a/drivers/net/ethernet/broadcom/bcmsysport.c
+++ b/drivers/net/ethernet/broadcom/bcmsysport.c
@@ -1422,10 +1422,14 @@ static int bcm_sysport_init_tx_ring(struct bcm_sysport_priv *priv,
 	reg &= ~(RING_QID_MASK | RING_PORT_ID_MASK << RING_PORT_ID_SHIFT);
 	reg |= ring->switch_queue & RING_QID_MASK;
 	reg |= ring->switch_port << RING_PORT_ID_SHIFT;
-	reg |= RING_IGNORE_STATUS;
 	tdma_writel(priv, reg, TDMA_DESC_RING_MAPPING(index));
 	tdma_writel(priv, 0, TDMA_DESC_RING_PCP_DEI_VID(index));
 
+	/* Enable ACB algorithm 2 */
+	reg = tdma_readl(priv, TDMA_CONTROL);
+	reg |= tdma_control_bit(priv, ACB_ALGO);
+	tdma_writel(priv, reg, TDMA_CONTROL);
+
 	/* Do not use tdma_control_bit() here because TSB_SWAP1 collides
 	 * with the original definition of ACB_ALGO
 	 */
-- 
2.9.3
