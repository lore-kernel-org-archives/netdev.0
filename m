From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [net-next 8/8] stmmac: limit max_mtu in case of 4KiB and use __netdev_alloc_skb.
Date: Tue, 18 Oct 2011 12:01:25 +0200
Message-ID: <1318932085-14927-9-git-send-email-peppe.cavallaro@st.com>
References: <1318932085-14927-1-git-send-email-peppe.cavallaro@st.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog112.obsmtp.com ([207.126.144.133]:55099 "EHLO
	eu1sys200aog112.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757433Ab1JRKCZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Oct 2011 06:02:25 -0400
In-Reply-To: <1318932085-14927-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Problem using big mtu around 4096 bytes is you end allocating (4096
+NET_SKB_PAD + NET_IP_ALIGN + sizeof(struct skb_shared_info) bytes ->
8192 bytes : order-1 pages

It's better to limit the mtu to SKB_MAX_HEAD(NET_SKB_PAD),
to have no more than one page per skb.

Also the patch changes the netdev_alloc_skb_ip_align() done in
init_dma_desc_rings() and uses a variant allowing GFP_KERNEL allocations
allowing the driver to load even in case of memory pressure.

Reported-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |   13 +++++++++----
 1 files changed, 9 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 1848a16..f5ca3be 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -474,11 +474,13 @@ static void init_dma_desc_rings(struct net_device *dev)
 	for (i = 0; i < rxsize; i++) {
 		struct dma_desc *p = priv->dma_rx + i;
 
-		skb = netdev_alloc_skb_ip_align(dev, bfsize);
+		skb = __netdev_alloc_skb(dev, bfsize + NET_IP_ALIGN,
+					 GFP_KERNEL);
 		if (unlikely(skb == NULL)) {
 			pr_err("%s: Rx init fails; skb is NULL\n", __func__);
 			break;
 		}
+		skb_reserve(skb, NET_IP_ALIGN);
 		priv->rx_skbuff[i] = skb;
 		priv->rx_skbuff_dma[i] = dma_map_single(priv->device, skb->data,
 						bfsize, DMA_FROM_DEVICE);
@@ -1176,12 +1178,15 @@ static inline void stmmac_rx_refill(struct stmmac_priv *priv)
 
 			skb = __skb_dequeue(&priv->rx_recycle);
 			if (skb == NULL)
-				skb = netdev_alloc_skb_ip_align(priv->dev,
-								bfsize);
+				skb = __netdev_alloc_skb(priv->dev, bfsize +
+							 NET_IP_ALIGN,
+							 GFP_KERNEL);
 
 			if (unlikely(skb == NULL))
 				break;
 
+			skb_reserve(skb, NET_IP_ALIGN);
+
 			priv->rx_skbuff[entry] = skb;
 			priv->rx_skbuff_dma[entry] =
 			    dma_map_single(priv->device, skb->data, bfsize,
@@ -1401,7 +1406,7 @@ static int stmmac_change_mtu(struct net_device *dev, int new_mtu)
 	if (priv->plat->enh_desc)
 		max_mtu = JUMBO_LEN;
 	else
-		max_mtu = BUF_SIZE_4KiB;
+		max_mtu = SKB_MAX_HEAD(NET_SKB_PAD);
 
 	if ((new_mtu < 46) || (new_mtu > max_mtu)) {
 		pr_err("%s: invalid MTU, max MTU is: %d\n", dev->name, max_mtu);
-- 
1.7.4.4
