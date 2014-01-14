From: Vince Bridgers <vbridgers2013@gmail.com>
Subject: [PATCH net-next] stmmac: Add vlan rx for better GRO performance.
Date: Tue, 14 Jan 2014 11:34:06 -0600
Message-ID: <1389720846-6543-1-git-send-email-vbridgers2013@gmail.com>
Cc: peppe.cavallaro@st.com, rayagond@vayavyalabs.com,
	vbridgers2013@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:37244 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751437AbaANRjL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jan 2014 12:39:11 -0500
Received: by mail-pd0-f182.google.com with SMTP id v10so137884pde.41
        for <netdev@vger.kernel.org>; Tue, 14 Jan 2014 09:39:10 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

GRO requires VLANs to be removed before aggregation can occur.
The Synopsys EMAC does not strip VLAN tags so this must be
done by the driver.

Signed-off-by: Vince Bridgers <vbridgers2013@gmail.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |   18 ++++++++++++++++++
 1 file changed, 18 insertions(+)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index b8e3a4c..e3ff84e 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -1951,6 +1951,22 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 	return NETDEV_TX_OK;
 }
 
+static inline void stmmac_rx_vlan(struct net_device *dev, struct sk_buff *skb)
+{
+	struct ethhdr *ehdr;
+	u16 vlanid;
+	if ((dev->features & NETIF_F_HW_VLAN_CTAG_RX) ==
+		NETIF_F_HW_VLAN_CTAG_RX &&
+		!__vlan_get_tag(skb, &vlanid)) {
+		/* pop the vlan tag */
+		ehdr = (struct ethhdr *)skb->data;
+		memmove(skb->data + VLAN_HLEN, ehdr, ETH_ALEN * 2);
+		skb_pull(skb, VLAN_HLEN);
+		__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), vlanid);
+	}
+}
+
+
 /**
  * stmmac_rx_refill: refill used skb preallocated buffers
  * @priv: driver private structure
@@ -2102,6 +2118,8 @@ static int stmmac_rx(struct stmmac_priv *priv, int limit)
 				print_pkt(skb->data, frame_len);
 			}
 
+			stmmac_rx_vlan(priv->dev, skb);
+
 			skb->protocol = eth_type_trans(skb, priv->dev);
 
 			if (unlikely(!coe))
-- 
1.7.9.5
