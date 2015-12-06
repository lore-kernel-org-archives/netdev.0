From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 5/6] IB/mlx4: Use the VF base-port when demuxing mad from wire
Date: Sun,  6 Dec 2015 18:07:42 +0200
Message-ID: <1449418063-8111-6-git-send-email-ogerlitz@mellanox.com>
References: <1449418063-8111-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Tal Alon <talal@mellanox.com>,
	Majd Dibbiny <majd@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Moni Shoua <monis@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:51634 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753999AbbLFQI2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 6 Dec 2015 11:08:28 -0500
In-Reply-To: <1449418063-8111-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Under HA mode, it's possible that the VF registered its GID
(and expects to get mads through the PV scheme) on a port which is
different from the one this mad arrived on, due to HA fail over.

Therefore, if the gid is not matched on the port that the packet arrived
on, check for a match on the other port if HA mode is active -- and if a
match is found on the other port, continue processing the mad using that
other port.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Reviewed-by: Jack Morgenstein <jackm@dev.mellanox.co.il>
---
 drivers/infiniband/hw/mlx4/mad.c | 17 ++++++++++++++---
 1 file changed, 14 insertions(+), 3 deletions(-)

diff --git a/drivers/infiniband/hw/mlx4/mad.c b/drivers/infiniband/hw/mlx4/mad.c
index 870e56b..26833bf 100644
--- a/drivers/infiniband/hw/mlx4/mad.c
+++ b/drivers/infiniband/hw/mlx4/mad.c
@@ -40,6 +40,7 @@
 #include <linux/gfp.h>
 #include <rdma/ib_pma.h>
 
+#include <linux/mlx4/driver.h>
 #include "mlx4_ib.h"
 
 enum {
@@ -606,8 +607,8 @@ static int mlx4_ib_demux_mad(struct ib_device *ibdev, u8 port,
 			struct ib_mad *mad)
 {
 	struct mlx4_ib_dev *dev = to_mdev(ibdev);
-	int err;
-	int slave;
+	int err, other_port;
+	int slave = -1;
 	u8 *slave_id;
 	int is_eth = 0;
 
@@ -625,7 +626,17 @@ static int mlx4_ib_demux_mad(struct ib_device *ibdev, u8 port,
 			mlx4_ib_warn(ibdev, "RoCE mgmt class is not CM\n");
 			return -EINVAL;
 		}
-		if (mlx4_get_slave_from_roce_gid(dev->dev, port, grh->dgid.raw, &slave)) {
+		err = mlx4_get_slave_from_roce_gid(dev->dev, port, grh->dgid.raw, &slave);
+		if (err && mlx4_is_mf_bonded(dev->dev)) {
+			other_port = (port == 1) ? 2 : 1;
+			err = mlx4_get_slave_from_roce_gid(dev->dev, other_port, grh->dgid.raw, &slave);
+			if (!err) {
+				port = other_port;
+				pr_debug("resolved slave %d from gid %pI6 wire port %d other %d\n",
+					 slave, grh->dgid.raw, port, other_port);
+			}
+		}
+		if (err) {
 			mlx4_ib_warn(ibdev, "failed matching grh\n");
 			return -ENOENT;
 		}
-- 
2.3.7
