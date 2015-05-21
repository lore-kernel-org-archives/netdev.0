From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 3/6] net/mlx4_core: Modify port values when generting EQEs for VFs
Date: Thu, 21 May 2015 15:14:07 +0300
Message-ID: <1432210450-23408-4-git-send-email-ogerlitz@mellanox.com>
References: <1432210450-23408-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Matan Barak <matanb@mellanox.com>,
	Doug Ledford <dledford@redhat.com>,
	Amir Vadai <amirv@mellanox.com>, Tal Alon <talal@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns1327.ztomy.com ([193.47.165.129]:56572 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754657AbbEUMOn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 May 2015 08:14:43 -0400
In-Reply-To: <1432210450-23408-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As part of enabling single ported VFs over IB ports we need to handle
some of the flows for generting EQ events for VFs which don't come
into play under Eth ports.

This mainly includes port management events derived from changes of the
phyiscal port (lid change, client re-register, down/up, etc), VF pkey table
changes and VF guid changes initiated by the IB driver.

(1) make sure that events are generated only for VFs sitting on
    the relevant physical port (under the ALL_SLAVES flow).

(2) before generating the event, convert from physical (one or two)
    to VF port (always equals one).

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Signed-off-by: Jack Morgenstein <jackm@dev.mellanox.co.il>
---
 drivers/infiniband/hw/mlx4/alias_GUID.c |    7 ++++++-
 drivers/net/ethernet/mellanox/mlx4/eq.c |   24 ++++++++++++++++++++----
 2 files changed, 26 insertions(+), 5 deletions(-)

diff --git a/drivers/infiniband/hw/mlx4/alias_GUID.c b/drivers/infiniband/hw/mlx4/alias_GUID.c
index 0f00204..21cb41a 100644
--- a/drivers/infiniband/hw/mlx4/alias_GUID.c
+++ b/drivers/infiniband/hw/mlx4/alias_GUID.c
@@ -189,7 +189,7 @@ void mlx4_ib_notify_slaves_on_guid_change(struct mlx4_ib_dev *dev,
 {
 	int i;
 	u64 guid_indexes;
-	int slave_id;
+	int slave_id, slave_port;
 	enum slave_port_state new_state;
 	enum slave_port_state prev_state;
 	__be64 tmp_cur_ag, form_cache_ag;
@@ -217,6 +217,11 @@ void mlx4_ib_notify_slaves_on_guid_change(struct mlx4_ib_dev *dev,
 		slave_id = (block_num * NUM_ALIAS_GUID_IN_REC) + i ;
 		if (slave_id >= dev->dev->persist->num_vfs + 1)
 			return;
+
+		slave_port = mlx4_phys_to_slave_port(dev->dev, slave_id, port_num);
+		if (slave_port < 0) /* this port isn't available for the VF */
+			continue;
+
 		tmp_cur_ag = *(__be64 *)&p_data[i * GUID_REC_SIZE];
 		form_cache_ag = get_cached_alias_guid(dev, port_num,
 					(NUM_ALIAS_GUID_IN_REC * block_num) + i);
diff --git a/drivers/net/ethernet/mellanox/mlx4/eq.c b/drivers/net/ethernet/mellanox/mlx4/eq.c
index 2619c9f..80bcd64 100644
--- a/drivers/net/ethernet/mellanox/mlx4/eq.c
+++ b/drivers/net/ethernet/mellanox/mlx4/eq.c
@@ -145,7 +145,7 @@ void mlx4_gen_slave_eqe(struct work_struct *work)
 	struct mlx4_slave_event_eq *slave_eq = &mfunc->master.slave_eq;
 	struct mlx4_eqe *eqe;
 	u8 slave;
-	int i;
+	int i, phys_port, slave_port;
 
 	for (eqe = next_slave_event_eqe(slave_eq); eqe;
 	      eqe = next_slave_event_eqe(slave_eq)) {
@@ -154,9 +154,20 @@ void mlx4_gen_slave_eqe(struct work_struct *work)
 		/* All active slaves need to receive the event */
 		if (slave == ALL_SLAVES) {
 			for (i = 0; i <= dev->persist->num_vfs; i++) {
+				phys_port = 0;
+				if (eqe->type == MLX4_EVENT_TYPE_PORT_MNG_CHG_EVENT &&
+				    eqe->subtype == MLX4_DEV_PMC_SUBTYPE_PORT_INFO) {
+					phys_port  = eqe->event.port_mgmt_change.port;
+					slave_port = mlx4_phys_to_slave_port(dev, i, phys_port);
+					if (slave_port < 0) /* VF doesn't have this port */
+						continue;
+					eqe->event.port_mgmt_change.port = slave_port;
+				}
 				if (mlx4_GEN_EQE(dev, i, eqe))
 					mlx4_warn(dev, "Failed to generate event for slave %d\n",
 						  i);
+				if (phys_port)
+					eqe->event.port_mgmt_change.port = phys_port;
 			}
 		} else {
 			if (mlx4_GEN_EQE(dev, slave, eqe))
@@ -224,7 +235,7 @@ int mlx4_gen_pkey_eqe(struct mlx4_dev *dev, int slave, u8 port)
 
 	eqe.type = MLX4_EVENT_TYPE_PORT_MNG_CHG_EVENT;
 	eqe.subtype = MLX4_DEV_PMC_SUBTYPE_PKEY_TABLE;
-	eqe.event.port_mgmt_change.port = port;
+	eqe.event.port_mgmt_change.port = mlx4_phys_to_slave_port(dev, slave, port);
 
 	return mlx4_GEN_EQE(dev, slave, &eqe);
 }
@@ -241,7 +252,7 @@ int mlx4_gen_guid_change_eqe(struct mlx4_dev *dev, int slave, u8 port)
 
 	eqe.type = MLX4_EVENT_TYPE_PORT_MNG_CHG_EVENT;
 	eqe.subtype = MLX4_DEV_PMC_SUBTYPE_GUID_INFO;
-	eqe.event.port_mgmt_change.port = port;
+	eqe.event.port_mgmt_change.port = mlx4_phys_to_slave_port(dev, slave, port);
 
 	return mlx4_GEN_EQE(dev, slave, &eqe);
 }
@@ -251,6 +262,7 @@ int mlx4_gen_port_state_change_eqe(struct mlx4_dev *dev, int slave, u8 port,
 				   u8 port_subtype_change)
 {
 	struct mlx4_eqe eqe;
+	u8 slave_port = mlx4_phys_to_slave_port(dev, slave, port);
 
 	/*don't send if we don't have the that slave */
 	if (dev->persist->num_vfs < slave)
@@ -259,7 +271,7 @@ int mlx4_gen_port_state_change_eqe(struct mlx4_dev *dev, int slave, u8 port,
 
 	eqe.type = MLX4_EVENT_TYPE_PORT_CHANGE;
 	eqe.subtype = port_subtype_change;
-	eqe.event.port_change.port = cpu_to_be32(port << 28);
+	eqe.event.port_change.port = cpu_to_be32(slave_port << 28);
 
 	mlx4_dbg(dev, "%s: sending: %d to slave: %d on port: %d\n", __func__,
 		 port_subtype_change, slave, port);
@@ -589,6 +601,10 @@ static int mlx4_eq_int(struct mlx4_dev *dev, struct mlx4_eq *eq)
 						if (SLAVE_PORT_GEN_EVENT_DOWN ==  gen_event) {
 							if (i == mlx4_master_func_num(dev))
 								continue;
+							eqe->event.port_change.port =
+								cpu_to_be32(
+								(be32_to_cpu(eqe->event.port_change.port) & 0xFFFFFFF)
+								| (mlx4_phys_to_slave_port(dev, i, port) << 28));
 							mlx4_slave_event(dev, i, eqe);
 						}
 					}
-- 
1.7.1
