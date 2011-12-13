From: Yevgeny Petrilin <yevgenyp-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>
Subject: [PATCH net-next V2 16/21] mlx4_en: Allow communication between functions
 on same host
Date: Tue, 13 Dec 2011 16:16:38 +0200
Message-ID: <4EE75E46.1010309@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org>, <yevgenyp-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>,
	<liranl-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>, <jackm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>,
	<eugenia-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>
To: <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Eugenia Emantayev <eugenia-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>

To enable internal loopback, always fill DMAC in control segment
when transmitting the packet, once this is done, the packet is subject
for loopback for if the DMAC mathces one of the multicast/unicast addresses
registered on the physical port.
In receive path if source MAC is our own MAC and we are not in selftest,
or not in force LB mode - drop this packet.

Signed-off-by: Eugenia Emantayev <eugenia-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>
Signed-off-by: Yevgeny Petrilin <yevgenyp-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>
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








--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
