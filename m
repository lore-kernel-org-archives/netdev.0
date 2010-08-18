From: Amerigo Wang <amwang@redhat.com>
Subject: [Patch 2/2] mlx4: remove num_lro parameter
Date: Wed, 18 Aug 2010 03:51:18 -0400
Message-ID: <20100818075540.5926.9432.sendpatchset@localhost.localdomain>
References: <20100818075530.5926.67960.sendpatchset@localhost.localdomain>
Cc: bhutchings@solarflare.com, Ramkrishna.Vepa@exar.com,
	sgruszka@redhat.com, Amerigo Wang <amwang@redhat.com>,
	davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51509 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751190Ab0HRHvX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Aug 2010 03:51:23 -0400
In-Reply-To: <20100818075530.5926.67960.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


As suggested by David, this parameter can die, we can use ethtool
to turn LRO on/off. Compile tests only.

Signed-off-by: WANG Cong <amwang@redhat.com>

---
diff --git a/drivers/net/mlx4/en_ethtool.c b/drivers/net/mlx4/en_ethtool.c
index b275238..398d541 100644
--- a/drivers/net/mlx4/en_ethtool.c
+++ b/drivers/net/mlx4/en_ethtool.c
@@ -398,8 +398,6 @@ static int mlx4_ethtool_op_set_flags(struct net_device *dev, u32 data)
 		return -EOPNOTSUPP;
 
 	if (data & ETH_FLAG_LRO) {
-		if (mdev->profile.num_lro == 0)
-			return -EOPNOTSUPP;
 		if (!(dev->features & NETIF_F_LRO))
 			changed = 1;
 	} else if (dev->features & NETIF_F_LRO) {
diff --git a/drivers/net/mlx4/en_main.c b/drivers/net/mlx4/en_main.c
index 97934f1..cacac4e 100644
--- a/drivers/net/mlx4/en_main.c
+++ b/drivers/net/mlx4/en_main.c
@@ -69,10 +69,6 @@ MLX4_EN_PARM_INT(rss_xor, 0, "Use XOR hash function for RSS");
 /* RSS hash type mask - default to <saddr, daddr, sport, dport> */
 MLX4_EN_PARM_INT(rss_mask, 0xf, "RSS hash type bitmask");
 
-/* Number of LRO sessions per Rx ring (rounded up to a power of two) */
-MLX4_EN_PARM_INT(num_lro, MLX4_EN_MAX_LRO_DESCRIPTORS,
-		 "Number of LRO sessions per ring or disabled (0)");
-
 /* Priority pausing */
 MLX4_EN_PARM_INT(pfctx, 0, "Priority based Flow Control policy on TX[7:0]."
 			   " Per priority bit mask");
@@ -109,7 +105,6 @@ static int mlx4_en_get_profile(struct mlx4_en_dev *mdev)
 
 	params->rss_xor = (rss_xor != 0);
 	params->rss_mask = rss_mask & 0x1f;
-	params->num_lro = min_t(int, num_lro , MLX4_EN_MAX_LRO_DESCRIPTORS);
 	for (i = 1; i <= MLX4_MAX_PORTS; i++) {
 		params->prof[i].rx_pause = 1;
 		params->prof[i].rx_ppp = pfcrx;
diff --git a/drivers/net/mlx4/en_netdev.c b/drivers/net/mlx4/en_netdev.c
index a0d8a26..d00bfe2 100644
--- a/drivers/net/mlx4/en_netdev.c
+++ b/drivers/net/mlx4/en_netdev.c
@@ -1038,8 +1038,7 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 	dev->features |= NETIF_F_HW_VLAN_TX |
 			 NETIF_F_HW_VLAN_RX |
 			 NETIF_F_HW_VLAN_FILTER;
-	if (mdev->profile.num_lro)
-		dev->features |= NETIF_F_LRO;
+	dev->features |= NETIF_F_LRO;
 	if (mdev->LSO_support) {
 		dev->features |= NETIF_F_TSO;
 		dev->features |= NETIF_F_TSO6;
diff --git a/drivers/net/mlx4/en_rx.c b/drivers/net/mlx4/en_rx.c
index 8e2fcb7..ee5a2cc 100644
--- a/drivers/net/mlx4/en_rx.c
+++ b/drivers/net/mlx4/en_rx.c
@@ -320,9 +320,9 @@ int mlx4_en_create_rx_ring(struct mlx4_en_priv *priv,
 	ring->lro.frag_align_pad = NET_IP_ALIGN;
 	ring->lro.ip_summed = CHECKSUM_UNNECESSARY;
 	ring->lro.ip_summed_aggr = CHECKSUM_UNNECESSARY;
-	ring->lro.max_desc = mdev->profile.num_lro;
+	ring->lro.max_desc = MLX4_EN_MAX_LRO_DESCRIPTORS;
 	ring->lro.max_aggr = MAX_SKB_FRAGS;
-	ring->lro.lro_arr = kzalloc(mdev->profile.num_lro *
+	ring->lro.lro_arr = kzalloc(MLX4_EN_MAX_LRO_DESCRIPTORS *
 				    sizeof(struct net_lro_desc),
 				    GFP_KERNEL);
 	if (!ring->lro.lro_arr) {
diff --git a/drivers/net/mlx4/mlx4_en.h b/drivers/net/mlx4/mlx4_en.h
index 4492109..9d09323 100644
--- a/drivers/net/mlx4/mlx4_en.h
+++ b/drivers/net/mlx4/mlx4_en.h
@@ -313,7 +313,6 @@ struct mlx4_en_port_profile {
 
 struct mlx4_en_profile {
 	int rss_xor;
-	int num_lro;
 	u8 rss_mask;
 	u32 active_ports;
 	u32 small_pkt_int;
