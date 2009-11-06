From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH 25/25 v2] mlx4_en: Loopback enable
Date: Fri, 06 Nov 2009 05:10:33 +0200
Message-ID: <4AF393A9.4030205@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
	liranl@mellanox.co.il, tziporet@mellanox.co.il,
	yevgenyp@mellanox.co.il
To: rdreier@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:43300 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1759235AbZKFAM5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Nov 2009 19:12:57 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

All packets are subject to loopback.
To enable loopback we write the dest mac to the wqe.

Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
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
1.5.3.7

From: Liran Liss <liranl@mellanox.co.il>





