From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [PATCH 1/2] stmmac: add memory barriers at appropriate places
Date: Mon, 18 Jul 2011 08:54:08 +0200
Message-ID: <1310972049-827-1-git-send-email-peppe.cavallaro@st.com>
Cc: Shiraz Hashim <shiraz.hashim@st.com>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog110.obsmtp.com ([207.126.144.129]:38217 "EHLO
	eu1sys200aog110.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750745Ab1GRGyn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2011 02:54:43 -0400
Received: from zeta.dmz-eu.st.com (ns2.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 9177BD0
	for <netdev@vger.kernel.org>; Mon, 18 Jul 2011 06:54:37 +0000 (GMT)
Received: from mail7.sgp.st.com (unknown [164.129.223.81])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 0743E1955
	for <netdev@vger.kernel.org>; Mon, 18 Jul 2011 06:54:37 +0000 (GMT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shiraz Hashim <shiraz.hashim@st.com>

This patch, provided by ST SPEAr developers,
has fixed a problem raised on ARM CA9 where
happened that the dma_transmission was enabled before
the dma descriptors were properly filled. To guarantee this
data memory barriers have been explicity used in the driver.

Signed-off-by: Shiraz Hashim <shiraz.hashim@st.com>
Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/stmmac/stmmac_main.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/drivers/net/stmmac/stmmac_main.c b/drivers/net/stmmac/stmmac_main.c
index e25e44a..f3d16d85 100644
--- a/drivers/net/stmmac/stmmac_main.c
+++ b/drivers/net/stmmac/stmmac_main.c
@@ -1045,6 +1045,7 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 					  len, DMA_TO_DEVICE);
 		priv->tx_skbuff[entry] = NULL;
 		priv->hw->desc->prepare_tx_desc(desc, 0, len, csum_insertion);
+		wmb();
 		priv->hw->desc->set_tx_owner(desc);
 	}
 
@@ -1056,6 +1057,9 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (likely(priv->tm->enable))
 		priv->hw->desc->clear_tx_ic(desc);
 #endif
+
+	wmb();
+
 	/* To avoid raise condition */
 	priv->hw->desc->set_tx_owner(first);
 
@@ -1116,6 +1120,7 @@ static inline void stmmac_rx_refill(struct stmmac_priv *priv)
 			}
 			RX_DBG(KERN_INFO "\trefill entry #%d\n", entry);
 		}
+		wmb();
 		priv->hw->desc->set_rx_owner(p + entry);
 	}
 }
-- 
1.7.4.4

