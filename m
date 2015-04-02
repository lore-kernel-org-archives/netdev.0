From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 08/18] net/mlx4: Query device for QoS per VF support
Date: Thu,  2 Apr 2015 16:31:13 +0300
Message-ID: <1427981483-19317-9-git-send-email-ogerlitz@mellanox.com>
References: <1427981483-19317-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Ido Shamay <idos@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>, Tal Alon <talal@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns1327.ztomy.com ([193.47.165.129]:45755 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753035AbbDBNcU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Apr 2015 09:32:20 -0400
In-Reply-To: <1427981483-19317-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Shamay <idos@mellanox.com>

Checks in QUERY_DEV_CAP if the granular QoS per VF feature is
supported by the device. Disabled for guests.

Signed-off-by: Ido Shamay <idos@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/fw.c |   10 +++++++++-
 include/linux/mlx4/device.h             |    3 ++-
 2 files changed, 11 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/fw.c b/drivers/net/ethernet/mellanox/mlx4/fw.c
index 412e019..94e857e 100644
--- a/drivers/net/ethernet/mellanox/mlx4/fw.c
+++ b/drivers/net/ethernet/mellanox/mlx4/fw.c
@@ -147,7 +147,8 @@ static void dump_dev_cap_flags2(struct mlx4_dev *dev, u64 flags)
 		[21] = "Port Remap support",
 		[22] = "QCN support",
 		[23] = "QP rate limiting support",
-		[24] = "Ethernet Flow control statistics support"
+		[24] = "Ethernet Flow control statistics support",
+		[25] = "Granular QoS per VF support",
 	};
 	int i;
 
@@ -871,6 +872,8 @@ int mlx4_QUERY_DEV_CAP(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
 	MLX4_GET(size, outbox, QUERY_DEV_CAP_MAX_DESC_SZ_RQ_OFFSET);
 	dev_cap->max_rq_desc_sz = size;
 	MLX4_GET(field, outbox, QUERY_DEV_CAP_CQ_EQ_CACHE_LINE_STRIDE);
+	if (field & (1 << 4))
+		dev_cap->flags2 |= MLX4_DEV_CAP_FLAG2_QOS_VPP;
 	if (field & (1 << 5))
 		dev_cap->flags2 |= MLX4_DEV_CAP_FLAG2_ETH_PROT_CTRL;
 	if (field & (1 << 6))
@@ -1199,6 +1202,11 @@ int mlx4_QUERY_DEV_CAP_wrapper(struct mlx4_dev *dev, int slave,
 	field16 = 0;
 	MLX4_PUT(outbox->buf, field16, QUERY_DEV_CAP_QP_RATE_LIMIT_NUM_OFFSET);
 
+	/* turn off QoS per VF support for guests */
+	MLX4_GET(field, outbox->buf, QUERY_DEV_CAP_CQ_EQ_CACHE_LINE_STRIDE);
+	field &= 0xef;
+	MLX4_PUT(outbox->buf, field, QUERY_DEV_CAP_CQ_EQ_CACHE_LINE_STRIDE);
+
 	return 0;
 }
 
diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
index b676d0c..c37208f 100644
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -205,7 +205,8 @@ enum {
 	MLX4_DEV_CAP_FLAG2_PORT_REMAP		= 1LL <<  21,
 	MLX4_DEV_CAP_FLAG2_QCN			= 1LL <<  22,
 	MLX4_DEV_CAP_FLAG2_QP_RATE_LIMIT	= 1LL <<  23,
-	MLX4_DEV_CAP_FLAG2_FLOWSTATS_EN         = 1LL <<  24
+	MLX4_DEV_CAP_FLAG2_FLOWSTATS_EN         = 1LL <<  24,
+	MLX4_DEV_CAP_FLAG2_QOS_VPP		= 1LL <<  25,
 };
 
 enum {
-- 
1.7.1
