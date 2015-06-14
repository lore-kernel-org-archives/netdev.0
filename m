From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net] net/mlx4_core: Disable Granular QoS per VF under IB/Eth VPI configuration
Date: Sun, 14 Jun 2015 17:13:06 +0300
Message-ID: <1434291186-24953-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Doug Ledford <dledford@redhat.com>,
	Amir Vadai <amirv@mellanox.com>, Tal Alon <talal@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Ido Shamay <idos@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:35292 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751417AbbFNONa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 14 Jun 2015 10:13:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Due to firmware bug, under VPI configuration when port1 = IB and
port2 = Eth, Granular QoS per VF isn't working properly. More over,
the whole QP0/QP1 Para-Virtualization in the mlx4 IB driver is
broken on that config.

Hence, we must disable Granular QoS per VF under that configuration
till a fix is introduced. Once that happens, a new device capability
will be used to mark the feature support on that specific configuration.

Reported-by: Doug Ledford <dledford@redhat.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---

Hi Dave, 

This FW bug comes into play only on 4.1-rc1 and onward, so 
no need for -stable here, also I didn't put a Fixes: tag since 
the bug isn't in the driver commit itself.

Or.

 drivers/net/ethernet/mellanox/mlx4/main.c |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index ced5eca..68b5a55 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -479,6 +479,14 @@ static int mlx4_dev_cap(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
 		}
 	}
 
+	if (mlx4_is_master(dev) && (dev->caps.num_ports == 2) &&
+	    (port_type_array[0] == MLX4_PORT_TYPE_IB) &&
+	    (port_type_array[1] == MLX4_PORT_TYPE_ETH)) {
+		mlx4_warn(dev,
+			  "Granular QoS per VF not supported with IB/Eth configuration\n");
+		dev->caps.flags2 &= ~MLX4_DEV_CAP_FLAG2_QOS_VPP;
+	}
+
 	dev->caps.max_counters = 1 << ilog2(dev_cap->max_counters);
 
 	dev->caps.reserved_qps_cnt[MLX4_QP_REGION_FW] = dev_cap->reserved_qps;
-- 
1.7.1
