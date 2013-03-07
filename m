From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net 2/6] net/mlx4_core: Turn off device-managed FS bit in dev-cap wrapper if DMFS is not enabled
Date: Thu,  7 Mar 2013 15:46:53 +0200
Message-ID: <1362664017-30275-3-git-send-email-ogerlitz@mellanox.com>
References: <1362664017-30275-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, amirv@mellanox.com,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog103.obsmtp.com ([207.126.144.115]:43104 "EHLO
	eu1sys200aog103.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753397Ab3CGNrO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Mar 2013 08:47:14 -0500
In-Reply-To: <1362664017-30275-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jack Morgenstein <jackm@dev.mellanox.co.il>

Older kernels detect DMFS (device-managed flow steering) from the HCA
device capability directly, regardless of whether the capability was
enabled in INIT_HCA, this is fixed by commit 7b8157bed "mlx4_core: Adjustments
to Flow Steering activation logic for SR-IOV"

To protect against guests running kernels without this fix, the host driver
should turn off the DMFS capability bit in mlx4_QUERY_DEV_CAP_wrapper.

Signed-off-by: Jack Morgenstein <jackm@dev.mellanox.co.il>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/fw.c |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/fw.c b/drivers/net/ethernet/mellanox/mlx4/fw.c
index 50917eb..f624557 100644
--- a/drivers/net/ethernet/mellanox/mlx4/fw.c
+++ b/drivers/net/ethernet/mellanox/mlx4/fw.c
@@ -787,6 +787,14 @@ int mlx4_QUERY_DEV_CAP_wrapper(struct mlx4_dev *dev, int slave,
 	bmme_flags &= ~MLX4_BMME_FLAG_TYPE_2_WIN;
 	MLX4_PUT(outbox->buf, bmme_flags, QUERY_DEV_CAP_BMME_FLAGS_OFFSET);
 
+	/* turn off device-managed steering capability if not enabled */
+	if (dev->caps.steering_mode != MLX4_STEERING_MODE_DEVICE_MANAGED) {
+		MLX4_GET(field, outbox->buf,
+			 QUERY_DEV_CAP_FLOW_STEERING_RANGE_EN_OFFSET);
+		field &= 0x7f;
+		MLX4_PUT(outbox->buf, field,
+			 QUERY_DEV_CAP_FLOW_STEERING_RANGE_EN_OFFSET);
+	}
 	return 0;
 }
 
-- 
1.7.1
