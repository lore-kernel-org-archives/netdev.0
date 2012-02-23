From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH net-next 2/3] mlx4_en: moderate frequency of TX completions
Date: Thu, 23 Feb 2012 15:34:27 +0200
Message-ID: <4F464063.1010001@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <yevgenyp@mellanox.co.il>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog109.obsmtp.com ([207.126.144.127]:38041 "HELO
	eu1sys200aog109.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754195Ab2BWNf2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Feb 2012 08:35:28 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


No need to ask for completion for every packet being sent.
So the method is to ask for a completion every 16 packets,
or when the queue is about to be full.

Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/ethernet/mellanox/mlx4/en_tx.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
index ff32505..e452bba 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
@@ -615,6 +615,7 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 	int lso_header_size;
 	void *fragptr;
 	bool bounce = false;
+	int ring_busy;
 
 	if (!priv->port_up)
 		goto tx_drop;
@@ -638,8 +639,8 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 		vlan_tag = vlan_tx_tag_get(skb);
 
 	/* Check available TXBBs And 2K spare for prefetch */
-	if (unlikely(((int)(ring->prod - ring->cons)) >
-		     ring->size - HEADROOM - MAX_DESC_TXBBS)) {
+	ring_busy = (int)(ring->prod - ring->cons) - (ring->size - HEADROOM - MAX_DESC_TXBBS);
+	if (unlikely(ring_busy > 0)) {
 		/* every full Tx ring stops queue */
 		netif_tx_stop_queue(netdev_get_tx_queue(dev, tx_ind));
 		ring->blocked = 1;
@@ -680,6 +681,8 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 		!!vlan_tx_tag_present(skb);
 	tx_desc->ctrl.fence_size = (real_size / 16) & 0x3f;
 	tx_desc->ctrl.srcrb_flags = priv->ctrl_flags;
+	if (!(!(index & 0xf) || vlan_tag || (ring_busy > -MAX_DESC_TXBBS)))
+		tx_desc->ctrl.srcrb_flags &= cpu_to_be32(~MLX4_WQE_CTRL_CQ_UPDATE);
 	if (likely(skb->ip_summed == CHECKSUM_PARTIAL)) {
 		tx_desc->ctrl.srcrb_flags |= cpu_to_be32(MLX4_WQE_CTRL_IP_CSUM |
 							 MLX4_WQE_CTRL_TCP_UDP_CSUM);
-- 
1.5.4.3
