From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH V1 net 2/4] net/mlx4_core: Fix slave id computation for single port VF
Date: Sun,  4 May 2014 17:07:23 +0300
Message-ID: <1399212445-5070-3-git-send-email-ogerlitz@mellanox.com>
References: <1399212445-5070-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, roland@kernel.org,
	jackm@dev.mellanox.co.il, matanb@mellanox.com, amirv@mellanox.com,
	Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:41796 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753016AbaEDOHn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 4 May 2014 10:07:43 -0400
In-Reply-To: <1399212445-5070-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matan Barak <matanb@mellanox.com>

The code that deals with computing the slave id based on a given GID
gave wrong results when the number of single port VFs wasn't the
same for port 1 vs. port 2 and the relevant VF is single ported on
port 2. As a result, incoming CM MADs were dispatched to the wrong VF.
Fixed that and added documentation to clarify the computation steps.

Fixes: 449fc48 ('net/mlx4: Adapt code for N-Port VF')
Signed-off-by: Matan Barak <matanb@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/port.c |   35 ++++++++++++++++------------
 1 files changed, 20 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/port.c b/drivers/net/ethernet/mellanox/mlx4/port.c
index cfcad26..b5b3549 100644
--- a/drivers/net/ethernet/mellanox/mlx4/port.c
+++ b/drivers/net/ethernet/mellanox/mlx4/port.c
@@ -1106,6 +1106,9 @@ int mlx4_get_slave_from_roce_gid(struct mlx4_dev *dev, int port, u8 *gid,
 	}
 
 	if (found_ix >= 0) {
+		/* Calculate a slave_gid which is the slave number in the gid
+		 * table and not a globally unique slave number.
+		 */
 		if (found_ix < MLX4_ROCE_PF_GIDS)
 			slave_gid = 0;
 		else if (found_ix < MLX4_ROCE_PF_GIDS + (vf_gids % num_vfs) *
@@ -1118,41 +1121,43 @@ int mlx4_get_slave_from_roce_gid(struct mlx4_dev *dev, int port, u8 *gid,
 			  ((vf_gids % num_vfs) * ((vf_gids / num_vfs + 1)))) /
 			 (vf_gids / num_vfs)) + vf_gids % num_vfs + 1;
 
+		/* Calculate the globally unique slave id */
 		if (slave_gid) {
 			struct mlx4_active_ports exclusive_ports;
 			struct mlx4_active_ports actv_ports;
 			struct mlx4_slaves_pport slaves_pport_actv;
 			unsigned max_port_p_one;
-			int num_slaves_before = 1;
+			int num_vfs_before = 0;
+			int candidate_slave_gid;
 
+			/* Calculate how many VFs are on the previous port, if exists */
 			for (i = 1; i < port; i++) {
 				bitmap_zero(exclusive_ports.ports, dev->caps.num_ports);
-				set_bit(i, exclusive_ports.ports);
+				set_bit(i - 1, exclusive_ports.ports);
 				slaves_pport_actv =
 					mlx4_phys_to_slaves_pport_actv(
 							dev, &exclusive_ports);
-				num_slaves_before += bitmap_weight(
+				num_vfs_before += bitmap_weight(
 						slaves_pport_actv.slaves,
 						dev->num_vfs + 1);
 			}
 
-			if (slave_gid < num_slaves_before) {
-				bitmap_zero(exclusive_ports.ports, dev->caps.num_ports);
-				set_bit(port - 1, exclusive_ports.ports);
-				slaves_pport_actv =
-					mlx4_phys_to_slaves_pport_actv(
-							dev, &exclusive_ports);
-				slave_gid += bitmap_weight(
-						slaves_pport_actv.slaves,
-						dev->num_vfs + 1) -
-						num_slaves_before;
-			}
-			actv_ports = mlx4_get_active_ports(dev, slave_gid);
+			/* candidate_slave_gid isn't necessarily the correct slave, but
+			 * it has the same number of ports and is assigned to the same
+			 * ports as the real slave we're looking for. On dual port VF,
+			 * slave_gid = [single port VFs on port <port>] +
+			 * [offset of the current slave from the first dual port VF] +
+			 * 1 (for the PF).
+			 */
+			candidate_slave_gid = slave_gid + num_vfs_before;
+
+			actv_ports = mlx4_get_active_ports(dev, candidate_slave_gid);
 			max_port_p_one = find_first_bit(
 				actv_ports.ports, dev->caps.num_ports) +
 				bitmap_weight(actv_ports.ports,
 					      dev->caps.num_ports) + 1;
 
+			/* Calculate the real slave number */
 			for (i = 1; i < max_port_p_one; i++) {
 				if (i == port)
 					continue;
-- 
1.7.1
