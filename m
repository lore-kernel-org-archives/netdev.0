From: Yevgeny Petrilin <yevgenyp-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>
Subject: [PATCH 25/25] mlx4_en: Loopback enable
Date: Wed, 04 Nov 2009 17:32:27 +0200
Message-ID: <4AF19E8B.3000500@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	liranl-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org, tziporet-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org,
	yevgenyp-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org
To: rdreier-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

All packets are subject to loopback.
To enable loopback we write the dest mac to the wqe.

Signed-off-by: Yevgeny Petrilin <yevgenyp-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>
---
 drivers/net/mlx4/en_netdev.c |    2 +-
 drivers/net/mlx4/en_tx.c     |   14 ++++++++++++++
 drivers/net/mlx4/mlx4_en.h   |    1 +
 3 files changed, 16 insertions(+), 1 deletions(-)

diff --git a/drivers/net/mlx4/en_netdev.c b/drivers/net/mlx4/en_netdev.c
index 8406fbb..947fb2f 100644
--- a/drivers/net/mlx4/en_netdev.c
+++ b/drivers/net/mlx4/en_netdev.c
@@ -108,7 +108,7 @@ static void mlx4_en_vlan_rx_kill_vid(struct net_device *dev, unsigned short vid)
 	mutex_unlock(&mdev->state_lock);
 }
 
-static u64 mlx4_en_mac_to_u64(u8 *addr)
+u64 mlx4_en_mac_to_u64(u8 *addr)
 {
 	u64 mac = 0;
 	int i;
diff --git a/drivers/net/mlx4/en_tx.c b/drivers/net/mlx4/en_tx.c
index a893733..cfbe361 100644
--- a/drivers/net/mlx4/en_tx.c
+++ b/drivers/net/mlx4/en_tx.c
@@ -599,6 +599,7 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 	struct mlx4_wqe_data_seg *data;
 	struct skb_frag_struct *frag;
 	struct mlx4_en_tx_info *tx_info;
+	struct ethhdr *ethh;
 	int tx_ind = 0;
 	int nr_txbb;
 	int desc_size;
@@ -610,6 +611,8 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 	int i;
 	int lso_header_size;
 	void *fragptr;
+	u64 mac;
+	u32 mac_l, mac_h;
 
 	real_size = get_real_size(skb, dev, &lso_header_size);
 	if (unlikely(!real_size))
@@ -675,6 +678,17 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 		priv->port_stats.tx_chksum_offload++;
 	}
 
+	/* Copy dst mac address to wqe */
+	skb_reset_mac_header(skb);
+	ethh = eth_hdr(skb);
+	if (ethh && ethh->h_dest) {
+		mac = mlx4_en_mac_to_u64(ethh->h_dest);
+		mac_h = (u32) ((mac & 0xffff00000000) >> 16);
+		mac_l = (u32) (mac & 0xffffffff);
+		tx_desc->ctrl.srcrb_flags |= cpu_to_be32(mac_h);
+		tx_desc->ctrl.imm = cpu_to_be32(mac_l);
+	}
+
 	/* Handle LSO (TSO) packets */
 	if (lso_header_size) {
 		/* Mark opcode as LSO */
diff --git a/drivers/net/mlx4/mlx4_en.h b/drivers/net/mlx4/mlx4_en.h
index b4731d5..02d07e9 100644
--- a/drivers/net/mlx4/mlx4_en.h
+++ b/drivers/net/mlx4/mlx4_en.h
@@ -564,6 +564,7 @@ int mlx4_SET_PORT_qpn_calc(struct mlx4_dev *dev, u8 port, u32 base_qpn,
 
 int mlx4_en_DUMP_ETH_STATS(struct mlx4_en_dev *mdev, u8 port, u8 reset);
 
+u64 mlx4_en_mac_to_u64(u8 *addr);
 /*
  * Globals
  */
-- 
1.6.1.3




--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
