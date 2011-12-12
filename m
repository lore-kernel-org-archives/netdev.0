From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH net-next V1 16/21] mlx4_en: Allow communication between functions
 on same host
Date: Mon, 12 Dec 2011 16:46:24 +0200
Message-ID: <4EE613C0.80305@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-rdma@vger.kernel.org>,
	<roland@purestorage.com>, <yevgenyp@mellanox.co.il>,
	<liranl@mellanox.co.il>, <jackm@dev.mellanox.co.il>,
	<eugenia@mellanox.co.il>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aob108.obsmtp.com ([207.126.144.124]:37257 "HELO
	eu1sys200aob108.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753512Ab1LLQvL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Dec 2011 11:51:11 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eugenia Emantayev <eugenia@mellanox.co.il>

To enable internal loopback, always fill DMAC in control segment
when transmitting the packet, once this is done, the packet is subject
for loopback for if the DMAC mathces one of the multicast/unicast addresses
registered on the physical port.
In receive path if source MAC is our own MAC and we are not in selftest,
or not in force LB mode - drop this packet.

Signed-off-by: Eugenia Emantayev <eugenia@mellanox.co.il>
Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/ethernet/mellanox/mlx4/en_rx.c |   15 +++++++++++++++
 drivers/net/ethernet/mellanox/mlx4/en_tx.c |   20 +++++++++-----------
 2 files changed, 24 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index ce1bc57..630a7c1 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -541,6 +541,8 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 	unsigned int length;
 	int polled = 0;
 	int ip_summed;
+	struct ethhdr *ethh;
+	u64 s_mac;
 
 	if (!priv->port_up)
 		return 0;
@@ -577,6 +579,19 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 			goto next;
 		}
 
+		/* Get pointer to first fragment since we haven't skb yet and
+		 * cast it to ethhdr struct */
+		ethh = (struct ethhdr *)(page_address(skb_frags[0].page) +
+					 skb_frags[0].offset);
+		s_mac = mlx4_en_mac_to_u64(ethh->h_source);
+
+		/* If source MAC is equal to our own MAC and not performing
+		 * the selftest or flb disabled - drop the packet */
+		if (s_mac == priv->mac &&
+			(!(dev->features & NETIF_F_LOOPBACK) ||
+			 !priv->validate_loopback))
+			goto next;
+
 		/*
 		 * Packet is OK - process it.
 		 */
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
index 7e76862..9ef9038 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
@@ -688,17 +688,15 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 		ring->tx_csum++;
 	}
 
-	if (unlikely(priv->validate_loopback)) {
-		/* Copy dst mac address to wqe */
-		skb_reset_mac_header(skb);
-		ethh = eth_hdr(skb);
-		if (ethh && ethh->h_dest) {
-			mac = mlx4_en_mac_to_u64(ethh->h_dest);
-			mac_h = (u32) ((mac & 0xffff00000000ULL) >> 16);
-			mac_l = (u32) (mac & 0xffffffff);
-			tx_desc->ctrl.srcrb_flags |= cpu_to_be32(mac_h);
-			tx_desc->ctrl.imm = cpu_to_be32(mac_l);
-		}
+	/* Copy dst mac address to wqe */
+	skb_reset_mac_header(skb);
+	ethh = eth_hdr(skb);
+	if (ethh && ethh->h_dest) {
+		mac = mlx4_en_mac_to_u64(ethh->h_dest);
+		mac_h = (u32) ((mac & 0xffff00000000ULL) >> 16);
+		mac_l = (u32) (mac & 0xffffffff);
+		tx_desc->ctrl.srcrb_flags |= cpu_to_be32(mac_h);
+		tx_desc->ctrl.imm = cpu_to_be32(mac_l);
 	}
 
 	/* Handle LSO (TSO) packets */
-- 
1.7.7
