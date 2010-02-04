From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH 13/23 v3] mlx4: Unicast Loopback support
Date: Thu, 04 Feb 2010 17:56:08 +0200
Message-ID: <4B6AEE18.1040104@mellanox.co.il>
References: <49BFC313.1030901@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: general@lists.openfabrics.org, netdev@vger.kernel.org,
	liranl@mellanox.co.il, tziporet@mellanox.co.il
To: Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:49768 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S933132Ab0BDP4L (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Feb 2010 10:56:11 -0500
In-Reply-To: <49BFC313.1030901@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

All packets are subject to loopback.
To enable ethernet loopback we write the dest mac to the wqe.

Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/mlx4/en_netdev.c |    2 +-
 drivers/net/mlx4/en_tx.c     |   14 ++++++++++++++
 drivers/net/mlx4/fw.c        |    3 +++
 drivers/net/mlx4/fw.h        |    1 +
 drivers/net/mlx4/main.c      |    1 +
 drivers/net/mlx4/mlx4_en.h   |    1 +
 include/linux/mlx4/device.h  |    1 +
 7 files changed, 22 insertions(+), 1 deletions(-)

diff --git a/drivers/net/mlx4/en_netdev.c b/drivers/net/mlx4/en_netdev.c
index fd96078..2987ada 100644
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
index 3d1396a..d4af0fe 100644
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
diff --git a/drivers/net/mlx4/fw.c b/drivers/net/mlx4/fw.c
index 2e60033..066db0e 100644
--- a/drivers/net/mlx4/fw.c
+++ b/drivers/net/mlx4/fw.c
@@ -228,6 +228,7 @@ int mlx4_QUERY_DEV_CAP(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
 #define QUERY_DEV_CAP_MAX_GID_OFFSET		0x3b
 #define QUERY_DEV_CAP_RATE_SUPPORT_OFFSET	0x3c
 #define QUERY_DEV_CAP_MAX_PKEY_OFFSET		0x3f
+#define QUERY_DEV_CAP_ETH_UC_LOOPBACK_OFFSET	0x43
 #define QUERY_DEV_CAP_FLAGS_OFFSET		0x44
 #define QUERY_DEV_CAP_RSVD_UAR_OFFSET		0x48
 #define QUERY_DEV_CAP_UAR_SZ_OFFSET		0x49
@@ -318,6 +319,8 @@ int mlx4_QUERY_DEV_CAP(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
 	dev_cap->max_msg_sz = 1 << (field & 0x1f);
 	MLX4_GET(stat_rate, outbox, QUERY_DEV_CAP_RATE_SUPPORT_OFFSET);
 	dev_cap->stat_rate_support = stat_rate;
+	MLX4_GET(field, outbox, QUERY_DEV_CAP_ETH_UC_LOOPBACK_OFFSET);
+	dev_cap->loopback_support = field & 0x1;
 	MLX4_GET(dev_cap->flags, outbox, QUERY_DEV_CAP_FLAGS_OFFSET);
 	MLX4_GET(field, outbox, QUERY_DEV_CAP_RSVD_UAR_OFFSET);
 	dev_cap->reserved_uars = field >> 4;
diff --git a/drivers/net/mlx4/fw.h b/drivers/net/mlx4/fw.h
index d066c69..f0d4f1c 100644
--- a/drivers/net/mlx4/fw.h
+++ b/drivers/net/mlx4/fw.h
@@ -74,6 +74,7 @@ struct mlx4_dev_cap {
 	u64 def_mac[MLX4_MAX_PORTS + 1];
 	u16 eth_mtu[MLX4_MAX_PORTS + 1];
 	u16 stat_rate_support;
+	int loopback_support;
 	u32 flags;
 	int reserved_uars;
 	int uar_size;
diff --git a/drivers/net/mlx4/main.c b/drivers/net/mlx4/main.c
index 6d5a8de..37293ca 100644
--- a/drivers/net/mlx4/main.c
+++ b/drivers/net/mlx4/main.c
@@ -241,6 +241,7 @@ static int mlx4_dev_cap(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
 	dev->caps.bmme_flags	     = dev_cap->bmme_flags;
 	dev->caps.reserved_lkey	     = dev_cap->reserved_lkey;
 	dev->caps.stat_rate_support  = dev_cap->stat_rate_support;
+	dev->caps.loopback_support   = dev_cap->loopback_support;
 	dev->caps.max_gso_sz	     = dev_cap->max_gso_sz;
 
 	dev->caps.log_num_macs  = log_num_mac;
diff --git a/drivers/net/mlx4/mlx4_en.h b/drivers/net/mlx4/mlx4_en.h
index 82c3ebc..5ea438e 100644
--- a/drivers/net/mlx4/mlx4_en.h
+++ b/drivers/net/mlx4/mlx4_en.h
@@ -563,6 +563,7 @@ int mlx4_SET_PORT_qpn_calc(struct mlx4_dev *dev, u8 port, u32 base_qpn,
 
 int mlx4_en_DUMP_ETH_STATS(struct mlx4_en_dev *mdev, u8 port, u8 reset);
 
+u64 mlx4_en_mac_to_u64(u8 *addr);
 /*
  * Globals
  */
diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
index 1da8c35..73a1856 100644
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -238,6 +238,7 @@ struct mlx4_caps {
 	u32			bmme_flags;
 	u32			reserved_lkey;
 	u16			stat_rate_support;
+	int			loopback_support;
 	u8			port_width_cap[MLX4_MAX_PORTS + 1];
 	int			max_gso_sz;
 	int                     reserved_qps_cnt[MLX4_NUM_QP_REGION];
-- 
1.6.1.3


