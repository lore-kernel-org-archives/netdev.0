From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 01/18] net/mlx4: Add RSS support for fragmented IP datagrams
Date: Thu,  2 Apr 2015 16:31:06 +0300
Message-ID: <1427981483-19317-2-git-send-email-ogerlitz@mellanox.com>
References: <1427981483-19317-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Ido Shamay <idos@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>, Tal Alon <talal@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns1327.ztomy.com ([193.47.165.129]:45633 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751521AbbDBNbt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Apr 2015 09:31:49 -0400
In-Reply-To: <1427981483-19317-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Shamay <idos@mellanox.com>

Enable RSS support for fragmented IP packets, when device supports it.
Until now, fragmented IP packets were directed only to the default_qpn.
Since IP fragments (datagram) have no upper protocols (L3 IP packets),
hash is performed on 3-tuple - dst MAC, source IP and dest IP. The HW
makes sure that this holds for the 1st fragment too, so all fragments
go to the same QP.

Signed-off-by: Ido Shamay <idos@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/fw.c   |   12 ++++++++++++
 drivers/net/ethernet/mellanox/mlx4/fw.h   |    1 +
 drivers/net/ethernet/mellanox/mlx4/main.c |    2 ++
 include/linux/mlx4/device.h               |    1 +
 4 files changed, 16 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/fw.c b/drivers/net/ethernet/mellanox/mlx4/fw.c
index 209a617..412e019 100644
--- a/drivers/net/ethernet/mellanox/mlx4/fw.c
+++ b/drivers/net/ethernet/mellanox/mlx4/fw.c
@@ -105,6 +105,7 @@ static void dump_dev_cap_flags(struct mlx4_dev *dev, u64 flags)
 		[41] = "Unicast VEP steering support",
 		[42] = "Multicast VEP steering support",
 		[48] = "Counters support",
+		[52] = "RSS IP fragments support",
 		[53] = "Port ETS Scheduler support",
 		[55] = "Port link type sensing support",
 		[59] = "Port management change event support",
@@ -1138,6 +1139,9 @@ int mlx4_QUERY_DEV_CAP_wrapper(struct mlx4_dev *dev, int slave,
 	}
 	for (; slave_port < dev->caps.num_ports; ++slave_port)
 		flags &= ~(MLX4_DEV_CAP_FLAG_WOL_PORT1 << slave_port);
+
+	/* Not exposing RSS IP fragments to guests */
+	flags &= ~MLX4_DEV_CAP_FLAG_RSS_IP_FRAG;
 	MLX4_PUT(outbox->buf, flags, QUERY_DEV_CAP_EXT_FLAGS_OFFSET);
 
 	MLX4_GET(field, outbox->buf, QUERY_DEV_CAP_VL_PORT_OFFSET);
@@ -1701,6 +1705,10 @@ int mlx4_INIT_HCA(struct mlx4_dev *dev, struct mlx4_init_hca_param *param)
 	if (dev->caps.flags & MLX4_DEV_CAP_FLAG_COUNTERS)
 		*(inbox + INIT_HCA_FLAGS_OFFSET / 4) |= cpu_to_be32(1 << 4);
 
+	/* Enable RSS spread to fragmented IP packets when supported */
+	if (dev->caps.flags & MLX4_DEV_CAP_FLAG_RSS_IP_FRAG)
+		*(inbox + INIT_HCA_FLAGS_OFFSET / 4) |= cpu_to_be32(1 << 13);
+
 	/* CX3 is capable of extending CQEs/EQEs from 32 to 64 bytes */
 	if (dev->caps.flags & MLX4_DEV_CAP_FLAG_64B_EQE) {
 		*(inbox + INIT_HCA_EQE_CQE_OFFSETS / 4) |= cpu_to_be32(1 << 29);
@@ -1889,6 +1897,10 @@ int mlx4_QUERY_HCA(struct mlx4_dev *dev,
 		else
 			param->steering_mode = MLX4_STEERING_MODE_A0;
 	}
+
+	if (dword_field & (1 << 13))
+		param->rss_ip_frags = 1;
+
 	/* steering attributes */
 	if (param->steering_mode == MLX4_STEERING_MODE_DEVICE_MANAGED) {
 		MLX4_GET(param->mc_base, outbox, INIT_HCA_FS_BASE_OFFSET);
diff --git a/drivers/net/ethernet/mellanox/mlx4/fw.h b/drivers/net/ethernet/mellanox/mlx4/fw.h
index 863655b..07cb7c2 100644
--- a/drivers/net/ethernet/mellanox/mlx4/fw.h
+++ b/drivers/net/ethernet/mellanox/mlx4/fw.h
@@ -203,6 +203,7 @@ struct mlx4_init_hca_param {
 	u64 dev_cap_enabled;
 	u16 cqe_size; /* For use only when CQE stride feature enabled */
 	u16 eqe_size; /* For use only when EQE stride feature enabled */
+	u8 rss_ip_frags;
 };
 
 struct mlx4_init_ib_param {
diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index 43aa767..ee0a670 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -885,6 +885,8 @@ static int mlx4_slave_cap(struct mlx4_dev *dev)
 	mlx4_warn(dev, "Timestamping is not supported in slave mode\n");
 
 	slave_adjust_steering_mode(dev, &dev_cap, &hca_param);
+	mlx4_dbg(dev, "RSS support for IP fragments is %s\n",
+		 hca_param.rss_ip_frags ? "on" : "off");
 
 	if (func_cap.extra_flags & MLX4_QUERY_FUNC_FLAGS_BF_RES_QP &&
 	    dev->caps.bf_reg_size)
diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
index ab7ebec..41eaafd 100644
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -174,6 +174,7 @@ enum {
 	MLX4_DEV_CAP_FLAG_VEP_UC_STEER	= 1LL << 41,
 	MLX4_DEV_CAP_FLAG_VEP_MC_STEER	= 1LL << 42,
 	MLX4_DEV_CAP_FLAG_COUNTERS	= 1LL << 48,
+	MLX4_DEV_CAP_FLAG_RSS_IP_FRAG   = 1LL << 52,
 	MLX4_DEV_CAP_FLAG_SET_ETH_SCHED = 1LL << 53,
 	MLX4_DEV_CAP_FLAG_SENSE_SUPPORT	= 1LL << 55,
 	MLX4_DEV_CAP_FLAG_PORT_MNG_CHG_EV = 1LL << 59,
-- 
1.7.1
