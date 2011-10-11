From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [net-next 3/5] stmmac: protect tx process with lock
Date: Tue, 11 Oct 2011 09:30:44 +0200
Message-ID: <1318318246-1326-4-git-send-email-peppe.cavallaro@st.com>
References: <1318318246-1326-1-git-send-email-peppe.cavallaro@st.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog112.obsmtp.com ([207.126.144.133]:59208 "EHLO
	eu1sys200aog112.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751388Ab1JKHbJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Oct 2011 03:31:09 -0400
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id A75B5D3
	for <netdev@vger.kernel.org>; Tue, 11 Oct 2011 07:31:07 +0000 (GMT)
Received: from mail7.sgp.st.com (mail7.sgp.st.com [164.129.223.81])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 5C21D1A88
	for <netdev@vger.kernel.org>; Tue, 11 Oct 2011 07:31:07 +0000 (GMT)
In-Reply-To: <1318318246-1326-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes a problem raised on Orly ARM SMP platform
where, in case of fragmented frames, the descriptors
in the TX ring resulted broken. This was due to a missing lock
protection in the tx process.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Tested-by: Srinivas Kandagatla <srinivas.kandagatla@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac.h      |    1 +
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |    8 ++++++++
 2 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac.h b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
index 1434bdb..50e95d8 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac.h
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
@@ -70,6 +70,7 @@ struct stmmac_priv {
 
 	u32 msg_enable;
 	spinlock_t lock;
+	spinlock_t tx_lock;
 	int wolopts;
 	int wolenabled;
 	int wol_irq;
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 0a7d326..87767d5 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -620,6 +620,8 @@ static void stmmac_tx(struct stmmac_priv *priv)
 {
 	unsigned int txsize = priv->dma_tx_size;
 
+	spin_lock(&priv->tx_lock);
+
 	while (priv->dirty_tx != priv->cur_tx) {
 		int last;
 		unsigned int entry = priv->dirty_tx % txsize;
@@ -685,6 +687,7 @@ static void stmmac_tx(struct stmmac_priv *priv)
 		}
 		netif_tx_unlock(priv->dev);
 	}
+	spin_unlock(&priv->tx_lock);
 }
 
 static inline void stmmac_enable_irq(struct stmmac_priv *priv)
@@ -1161,6 +1164,8 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 		return NETDEV_TX_BUSY;
 	}
 
+	spin_lock(&priv->tx_lock);
+
 	entry = priv->cur_tx % txsize;
 
 #ifdef STMMAC_XMIT_DEBUG
@@ -1257,6 +1262,8 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	priv->hw->dma->enable_dma_transmission(priv->ioaddr);
 
+	spin_unlock(&priv->tx_lock);
+
 	return NETDEV_TX_OK;
 }
 
@@ -1824,6 +1831,7 @@ static int stmmac_probe(struct net_device *dev)
 			"please, use ifconfig or nwhwconfig!\n");
 
 	spin_lock_init(&priv->lock);
+	spin_lock_init(&priv->tx_lock);
 
 	ret = register_netdev(dev);
 	if (ret) {
-- 
1.7.4.4
