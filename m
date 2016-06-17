From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 14/18] net/mlx5e: Set sniffer skbs packet type to offload kernel
Date: Fri, 17 Jun 2016 17:43:55 +0300
Message-ID: <1466174639-14576-15-git-send-email-saeedm@mellanox.com>
References: <1466174639-14576-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Doug Ledford <dledford@redhat.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Maor Gottlieb <maorg@mellanox.com>,
	Huy Nguyen <huyn@mellanox.com>, Tal Alon <talal@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:57585 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752796AbcFQOsi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Jun 2016 10:48:38 -0400
In-Reply-To: <1466174639-14576-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Huy Nguyen <huyn@mellanox.com>

Set skb->pkt_type to PACKET_OFFLOAD_KERNEL for sniffer packets in
mlx5e_build_rx_skb for them to skip the kernel net stack processing.

Signed-off-by: Maor Gottlieb <maorg@mellanox.com>
Signed-off-by: Huy Nguyen <huyn@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h    | 1 +
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c | 4 ++++
 include/linux/mlx5/device.h                     | 5 +++++
 3 files changed, 10 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index e8a6c33..05ee644 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -44,6 +44,7 @@
 #include <linux/mlx5/vport.h>
 #include <linux/mlx5/transobj.h>
 #include <linux/rhashtable.h>
+#include <linux/mlx5/fs.h>
 #include "wq.h"
 #include "mlx5_core.h"
 #include "en_stats.h"
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
index bd94770..b1aa9f2 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
@@ -33,6 +33,7 @@
 #include <linux/ip.h>
 #include <linux/ipv6.h>
 #include <linux/tcp.h>
+#include <linux/if_packet.h>
 #include <net/busy_poll.h>
 #include "en.h"
 #include "en_tc.h"
@@ -741,6 +742,9 @@ static inline void mlx5e_build_rx_skb(struct mlx5_cqe64 *cqe,
 
 	mlx5e_handle_csum(netdev, cqe, rq, skb, !!lro_num_seg);
 	skb->protocol = eth_type_trans(skb, netdev);
+	if (unlikely((mlx5_get_cqe_ft(cqe) ==
+		      cpu_to_be32(MLX5_FS_OFFLOAD_FLOW_TAG))))
+		skb->pkt_type = PACKET_OFFLOAD_KERNEL;
 }
 
 static inline void mlx5e_complete_rx_cqe(struct mlx5e_rq *rq,
diff --git a/include/linux/mlx5/device.h b/include/linux/mlx5/device.h
index 73a4847..a90f85b 100644
--- a/include/linux/mlx5/device.h
+++ b/include/linux/mlx5/device.h
@@ -754,6 +754,11 @@ static inline u64 get_cqe_ts(struct mlx5_cqe64 *cqe)
 	return (u64)lo | ((u64)hi << 32);
 }
 
+static inline __be32 mlx5_get_cqe_ft(struct mlx5_cqe64 *cqe)
+{
+	return cqe->sop_drop_qpn & cpu_to_be32(0xFFFFFF);
+}
+
 struct mpwrq_cqe_bc {
 	__be16	filler_consumed_strides;
 	__be16	byte_cnt;
-- 
2.8.0
