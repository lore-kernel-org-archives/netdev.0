From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH v3 4/9] ftgmac100: Add vlan HW offload
Date: Tue, 18 Apr 2017 08:37:01 +1000
Message-ID: <20170417223706.16483-5-benh@kernel.crashing.org>
References: <20170417223706.16483-1-benh@kernel.crashing.org>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:51405 "EHLO gate.crashing.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754784AbdDQWlF (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 17 Apr 2017 18:41:05 -0400
In-Reply-To: <20170417223706.16483-1-benh@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The chip supports HW vlan tag insertion and extraction. Add support
for it.

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---
 drivers/net/ethernet/faraday/ftgmac100.c | 46 +++++++++++++++++++++++++++++++-
 1 file changed, 45 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/faraday/ftgmac100.c b/drivers/net/ethernet/faraday/ftgmac100.c
index f4db6e2..40a03d5 100644
--- a/drivers/net/ethernet/faraday/ftgmac100.c
+++ b/drivers/net/ethernet/faraday/ftgmac100.c
@@ -33,6 +33,7 @@
 #include <linux/platform_device.h>
 #include <linux/property.h>
 #include <linux/crc32.h>
+#include <linux/if_vlan.h>
 #include <net/ip.h>
 #include <net/ncsi.h>
 
@@ -335,6 +336,10 @@ static void ftgmac100_start_hw(struct ftgmac100 *priv)
 	else if (netdev_mc_count(priv->netdev))
 		maccr |= FTGMAC100_MACCR_HT_MULTI_EN;
 
+	/* Vlan filtering enabled */
+	if (priv->netdev->features & NETIF_F_HW_VLAN_CTAG_RX)
+		maccr |= FTGMAC100_MACCR_RM_VLAN;
+
 	/* Hit the HW */
 	iowrite32(maccr, priv->base + FTGMAC100_OFFSET_MACCR);
 }
@@ -530,6 +535,12 @@ static bool ftgmac100_rx_packet(struct ftgmac100 *priv, int *processed)
 	/* Transfer received size to skb */
 	skb_put(skb, size);
 
+	/* Extract vlan tag */
+	if ((netdev->features & NETIF_F_HW_VLAN_CTAG_RX) &&
+	    (csum_vlan & FTGMAC100_RXDES1_VLANTAG_AVAIL))
+		__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q),
+				       csum_vlan & 0xffff);
+
 	/* Tear down DMA mapping, do necessary cache management */
 	map = le32_to_cpu(rxdes->rxdes3);
 
@@ -754,6 +765,13 @@ static int ftgmac100_hard_start_xmit(struct sk_buff *skb,
 	if (skb->ip_summed == CHECKSUM_PARTIAL &&
 	    !ftgmac100_prep_tx_csum(skb, &csum_vlan))
 		goto drop;
+
+	/* Add VLAN tag */
+	if (skb_vlan_tag_present(skb)) {
+		csum_vlan |= FTGMAC100_TXDES1_INS_VLANTAG;
+		csum_vlan |= skb_vlan_tag_get(skb) & 0xffff;
+	}
+
 	txdes->txdes1 = cpu_to_le32(csum_vlan);
 
 	/* Next descriptor */
@@ -1546,6 +1564,30 @@ static void ftgmac100_tx_timeout(struct net_device *netdev)
 	schedule_work(&priv->reset_task);
 }
 
+static int ftgmac100_set_features(struct net_device *netdev,
+				  netdev_features_t features)
+{
+	struct ftgmac100 *priv = netdev_priv(netdev);
+	netdev_features_t changed = netdev->features ^ features;
+
+	if (!netif_running(netdev))
+		return 0;
+
+	/* Update the vlan filtering bit */
+	if (changed & NETIF_F_HW_VLAN_CTAG_RX) {
+		u32 maccr;
+
+		maccr = ioread32(priv->base + FTGMAC100_OFFSET_MACCR);
+		if (priv->netdev->features & NETIF_F_HW_VLAN_CTAG_RX)
+			maccr |= FTGMAC100_MACCR_RM_VLAN;
+		else
+			maccr &= ~FTGMAC100_MACCR_RM_VLAN;
+		iowrite32(maccr, priv->base + FTGMAC100_OFFSET_MACCR);
+	}
+
+	return 0;
+}
+
 static const struct net_device_ops ftgmac100_netdev_ops = {
 	.ndo_open		= ftgmac100_open,
 	.ndo_stop		= ftgmac100_stop,
@@ -1555,6 +1597,7 @@ static const struct net_device_ops ftgmac100_netdev_ops = {
 	.ndo_do_ioctl		= ftgmac100_do_ioctl,
 	.ndo_tx_timeout		= ftgmac100_tx_timeout,
 	.ndo_set_rx_mode	= ftgmac100_set_rx_mode,
+	.ndo_set_features	= ftgmac100_set_features,
 };
 
 static int ftgmac100_setup_mdio(struct net_device *netdev)
@@ -1730,7 +1773,8 @@ static int ftgmac100_probe(struct platform_device *pdev)
 
 	/* Base feature set */
 	netdev->hw_features = NETIF_F_RXCSUM | NETIF_F_HW_CSUM |
-		NETIF_F_GRO | NETIF_F_SG;
+		NETIF_F_GRO | NETIF_F_SG | NETIF_F_HW_VLAN_CTAG_RX |
+		NETIF_F_HW_VLAN_CTAG_TX;
 
 	/* AST2400  doesn't have working HW checksum generation */
 	if (np && (of_device_is_compatible(np, "aspeed,ast2400-mac")))
-- 
2.9.3
