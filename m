From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH 12/14] mlx4_en: UDP RSS support
Date: Tue, 24 Aug 2010 16:46:42 +0300
Message-ID: <4C73CD42.70503@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <yevgenyp@mellanox.co.il>,
	<eugenia@mellanox.co.il>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:50179 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755250Ab0HXNqp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Aug 2010 09:46:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adding capability for RSS for UDP traffic, hashing is done based on
IP addresses and UDP port number.
The support depends on HW/FW capabilities.

Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/mlx4/en_main.c  |   19 ++++++++++++-------
 drivers/net/mlx4/en_rx.c    |    8 ++++----
 drivers/net/mlx4/fw.c       |    3 +++
 drivers/net/mlx4/fw.h       |    1 +
 drivers/net/mlx4/main.c     |    1 +
 drivers/net/mlx4/mlx4_en.h  |    3 +++
 include/linux/mlx4/device.h |    1 +
 7 files changed, 25 insertions(+), 11 deletions(-)

diff --git a/drivers/net/mlx4/en_main.c b/drivers/net/mlx4/en_main.c
index 97934f1..2f25800 100644
--- a/drivers/net/mlx4/en_main.c
+++ b/drivers/net/mlx4/en_main.c
@@ -63,11 +63,12 @@ static const char mlx4_en_version[] =
  */
 
 
-/* Use a XOR rathern than Toeplitz hash function for RSS */
-MLX4_EN_PARM_INT(rss_xor, 0, "Use XOR hash function for RSS");
-
-/* RSS hash type mask - default to <saddr, daddr, sport, dport> */
-MLX4_EN_PARM_INT(rss_mask, 0xf, "RSS hash type bitmask");
+/* Enable RSS TCP traffic */
+MLX4_EN_PARM_INT(tcp_rss, 1,
+		 "Enable RSS for incomming TCP traffic or disabled (0)");
+/* Enable RSS UDP traffic */
+MLX4_EN_PARM_INT(udp_rss, 1,
+		 "Enable RSS for incomming UDP traffic or disabled (0)");
 
 /* Number of LRO sessions per Rx ring (rounded up to a power of two) */
 MLX4_EN_PARM_INT(num_lro, MLX4_EN_MAX_LRO_DESCRIPTORS,
@@ -107,8 +108,12 @@ static int mlx4_en_get_profile(struct mlx4_en_dev *mdev)
 	struct mlx4_en_profile *params = &mdev->profile;
 	int i;
 
-	params->rss_xor = (rss_xor != 0);
-	params->rss_mask = rss_mask & 0x1f;
+	params->tcp_rss = tcp_rss;
+	params->udp_rss = udp_rss;
+	if (params->udp_rss && !mdev->dev->caps.udp_rss) {
+		mlx4_warn(mdev, "UDP RSS is not supported on this device.\n");
+		params->udp_rss = 0;
+	}
 	params->num_lro = min_t(int, num_lro , MLX4_EN_MAX_LRO_DESCRIPTORS);
 	for (i = 1; i <= MLX4_MAX_PORTS; i++) {
 		params->prof[i].rx_pause = 1;
diff --git a/drivers/net/mlx4/en_rx.c b/drivers/net/mlx4/en_rx.c
index ae17baa..62604f5 100644
--- a/drivers/net/mlx4/en_rx.c
+++ b/drivers/net/mlx4/en_rx.c
@@ -859,8 +859,7 @@ int mlx4_en_config_rss_steer(struct mlx4_en_priv *priv)
 	struct mlx4_qp_context context;
 	struct mlx4_en_rss_context *rss_context;
 	void *ptr;
-	int rss_xor = mdev->profile.rss_xor;
-	u8 rss_mask = mdev->profile.rss_mask;
+	u8 rss_mask = 0x3f;
 	int i, qpn;
 	int err = 0;
 	int good_qps = 0;
@@ -906,9 +905,10 @@ int mlx4_en_config_rss_steer(struct mlx4_en_priv *priv)
 	rss_context->base_qpn = cpu_to_be32(ilog2(priv->rx_ring_num) << 24 |
 					    (rss_map->base_qpn));
 	rss_context->default_qpn = cpu_to_be32(rss_map->base_qpn);
-	rss_context->hash_fn = rss_xor & 0x3;
-	rss_context->flags = rss_mask << 2;
+	rss_context->flags = rss_mask;
 
+	if (priv->mdev->profile.udp_rss)
+		rss_context->base_qpn_udp = rss_context->default_qpn;
 	err = mlx4_qp_to_ready(mdev->dev, &priv->res.mtt, &context,
 			       &rss_map->indir_qp, &rss_map->indir_state);
 	if (err)
diff --git a/drivers/net/mlx4/fw.c b/drivers/net/mlx4/fw.c
index 515c634..b716e1a 100644
--- a/drivers/net/mlx4/fw.c
+++ b/drivers/net/mlx4/fw.c
@@ -179,6 +179,7 @@ int mlx4_QUERY_DEV_CAP(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
 #define QUERY_DEV_CAP_MAX_GID_OFFSET		0x3b
 #define QUERY_DEV_CAP_RATE_SUPPORT_OFFSET	0x3c
 #define QUERY_DEV_CAP_MAX_PKEY_OFFSET		0x3f
+#define QUERY_DEV_CAP_UDP_RSS_OFFSET		0x42
 #define QUERY_DEV_CAP_ETH_UC_LOOPBACK_OFFSET	0x43
 #define QUERY_DEV_CAP_FLAGS_OFFSET		0x44
 #define QUERY_DEV_CAP_RSVD_UAR_OFFSET		0x48
@@ -270,6 +271,8 @@ int mlx4_QUERY_DEV_CAP(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
 	dev_cap->max_msg_sz = 1 << (field & 0x1f);
 	MLX4_GET(stat_rate, outbox, QUERY_DEV_CAP_RATE_SUPPORT_OFFSET);
 	dev_cap->stat_rate_support = stat_rate;
+	MLX4_GET(field, outbox, QUERY_DEV_CAP_UDP_RSS_OFFSET);
+	dev_cap->udp_rss = field & 0x1;
 	MLX4_GET(field, outbox, QUERY_DEV_CAP_ETH_UC_LOOPBACK_OFFSET);
 	dev_cap->loopback_support = field & 0x1;
 	MLX4_GET(dev_cap->flags, outbox, QUERY_DEV_CAP_FLAGS_OFFSET);
diff --git a/drivers/net/mlx4/fw.h b/drivers/net/mlx4/fw.h
index 443e456..65cc72e 100644
--- a/drivers/net/mlx4/fw.h
+++ b/drivers/net/mlx4/fw.h
@@ -78,6 +78,7 @@ struct mlx4_dev_cap {
 	u16 wavelength[MLX4_MAX_PORTS + 1];
 	u64 trans_code[MLX4_MAX_PORTS + 1];
 	u16 stat_rate_support;
+	int udp_rss;
 	int loopback_support;
 	u32 flags;
 	int reserved_uars;
diff --git a/drivers/net/mlx4/main.c b/drivers/net/mlx4/main.c
index f4791fa..569fa3d 100644
--- a/drivers/net/mlx4/main.c
+++ b/drivers/net/mlx4/main.c
@@ -225,6 +225,7 @@ static int mlx4_dev_cap(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
 	dev->caps.bmme_flags	     = dev_cap->bmme_flags;
 	dev->caps.reserved_lkey	     = dev_cap->reserved_lkey;
 	dev->caps.stat_rate_support  = dev_cap->stat_rate_support;
+	dev->caps.udp_rss	     = dev_cap->udp_rss;
 	dev->caps.loopback_support   = dev_cap->loopback_support;
 	dev->caps.max_gso_sz	     = dev_cap->max_gso_sz;
 
diff --git a/drivers/net/mlx4/mlx4_en.h b/drivers/net/mlx4/mlx4_en.h
index 97c30ff..0662886 100644
--- a/drivers/net/mlx4/mlx4_en.h
+++ b/drivers/net/mlx4/mlx4_en.h
@@ -319,6 +319,8 @@ struct mlx4_en_port_profile {
 struct mlx4_en_profile {
 	int rss_xor;
 	int num_lro;
+	int tcp_rss;
+	int udp_rss;
 	u8 rss_mask;
 	u32 active_ports;
 	u32 small_pkt_int;
@@ -361,6 +363,7 @@ struct mlx4_en_rss_context {
 	u8 hash_fn;
 	u8 flags;
 	__be32 rss_key[10];
+	__be32 base_qpn_udp;
 };
 
 struct mlx4_en_port_state {
diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
index 2a36a34..7338654 100644
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -233,6 +233,7 @@ struct mlx4_caps {
 	u32			bmme_flags;
 	u32			reserved_lkey;
 	u16			stat_rate_support;
+	int			udp_rss;
 	int			loopback_support;
 	u8			port_width_cap[MLX4_MAX_PORTS + 1];
 	int			max_gso_sz;
-- 
1.6.1.3


