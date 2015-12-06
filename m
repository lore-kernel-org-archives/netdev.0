From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 2/6] net/mlx4_core: Use both physical ports to dispatch link state events to VF
Date: Sun,  6 Dec 2015 18:07:39 +0200
Message-ID: <1449418063-8111-3-git-send-email-ogerlitz@mellanox.com>
References: <1449418063-8111-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Tal Alon <talal@mellanox.com>,
	Majd Dibbiny <majd@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Moni Shoua <monis@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:51571 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753584AbbLFQIL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 6 Dec 2015 11:08:11 -0500
In-Reply-To: <1449418063-8111-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Moni Shoua <monis@mellanox.com>

Under HA mode, the link down event should be sent to VFs only if both
ports are down.

Signed-off-by: Moni Shoua <monis@mellanox.com>
Reviewed-by: Jack Morgenstein <jackm@dev.mellanox.co.il>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/eq.c | 24 ++++++++++++++++++++----
 1 file changed, 20 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/eq.c b/drivers/net/ethernet/mellanox/mlx4/eq.c
index 603d1c3..4696053 100644
--- a/drivers/net/ethernet/mellanox/mlx4/eq.c
+++ b/drivers/net/ethernet/mellanox/mlx4/eq.c
@@ -151,6 +151,17 @@ void mlx4_gen_slave_eqe(struct work_struct *work)
 	      eqe = next_slave_event_eqe(slave_eq)) {
 		slave = eqe->slave_id;
 
+		if (eqe->type == MLX4_EVENT_TYPE_PORT_CHANGE &&
+		    eqe->subtype == MLX4_PORT_CHANGE_SUBTYPE_DOWN &&
+		    mlx4_is_bonded(dev)) {
+			struct mlx4_port_cap port_cap;
+
+			if (!mlx4_QUERY_PORT(dev, 1, &port_cap) && port_cap.link_state)
+				goto consume;
+
+			if (!mlx4_QUERY_PORT(dev, 2, &port_cap) && port_cap.link_state)
+				goto consume;
+		}
 		/* All active slaves need to receive the event */
 		if (slave == ALL_SLAVES) {
 			for (i = 0; i <= dev->persist->num_vfs; i++) {
@@ -174,6 +185,7 @@ void mlx4_gen_slave_eqe(struct work_struct *work)
 				mlx4_warn(dev, "Failed to generate event for slave %d\n",
 					  slave);
 		}
+consume:
 		++slave_eq->cons;
 	}
 }
@@ -594,7 +606,9 @@ static int mlx4_eq_int(struct mlx4_dev *dev, struct mlx4_eq *eq)
 					break;
 				for (i = 0; i < dev->persist->num_vfs + 1;
 				     i++) {
-					if (!test_bit(i, slaves_port.slaves))
+					int reported_port = mlx4_is_bonded(dev) ? 1 : mlx4_phys_to_slave_port(dev, i, port);
+
+					if (!test_bit(i, slaves_port.slaves) && !mlx4_is_bonded(dev))
 						continue;
 					if (dev->caps.port_type[port] == MLX4_PORT_TYPE_ETH) {
 						if (i == mlx4_master_func_num(dev))
@@ -606,7 +620,7 @@ static int mlx4_eq_int(struct mlx4_dev *dev, struct mlx4_eq *eq)
 							eqe->event.port_change.port =
 								cpu_to_be32(
 								(be32_to_cpu(eqe->event.port_change.port) & 0xFFFFFFF)
-								| (mlx4_phys_to_slave_port(dev, i, port) << 28));
+								| (reported_port << 28));
 							mlx4_slave_event(dev, i, eqe);
 						}
 					} else {  /* IB port */
@@ -636,7 +650,9 @@ static int mlx4_eq_int(struct mlx4_dev *dev, struct mlx4_eq *eq)
 					for (i = 0;
 					     i < dev->persist->num_vfs + 1;
 					     i++) {
-						if (!test_bit(i, slaves_port.slaves))
+						int reported_port = mlx4_is_bonded(dev) ? 1 : mlx4_phys_to_slave_port(dev, i, port);
+
+						if (!test_bit(i, slaves_port.slaves) && !mlx4_is_bonded(dev))
 							continue;
 						if (i == mlx4_master_func_num(dev))
 							continue;
@@ -645,7 +661,7 @@ static int mlx4_eq_int(struct mlx4_dev *dev, struct mlx4_eq *eq)
 							eqe->event.port_change.port =
 								cpu_to_be32(
 								(be32_to_cpu(eqe->event.port_change.port) & 0xFFFFFFF)
-								| (mlx4_phys_to_slave_port(dev, i, port) << 28));
+								| (reported_port << 28));
 							mlx4_slave_event(dev, i, eqe);
 						}
 					}
-- 
2.3.7
